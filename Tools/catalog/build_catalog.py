#!/usr/bin/env python3
"""Merge the PoetryDB dump and parsed Gutenberg books into the app resources.

Outputs:
  ../../Poetic/Service/PoemCatalog.json   (the bundled catalog)
  ../../Poetic/Service/Authors.json       (regenerated author list)
  report.md                               (counts, dedupe log, missing Links entries)
"""
import difflib
import json
import pathlib
import re
import sys

import clean_text
import parse_gutenberg

HERE = pathlib.Path(__file__).parent
POETRYDB_CACHE = HERE / "cache" / "poetrydb"
APP_SERVICE_DIR = HERE.parent.parent / "Poetic" / "Service"
LINKS_SWIFT = HERE.parent.parent / "Poetic" / "Utility" / "Links.swift"


def normalize_lines(lines: list[str]) -> list[str]:
    lines = [line.rstrip() for line in lines]
    while lines and not lines[0]:
        lines.pop(0)
    while lines and not lines[-1]:
        lines.pop()
    collapsed: list[str] = []
    blanks = 0
    for line in lines:
        if not line:
            blanks += 1
            if blanks > 1:
                continue
        else:
            blanks = 0
        collapsed.append(line)
    return collapsed


def load_poetrydb() -> list[dict]:
    poems = []
    for path in sorted(POETRYDB_CACHE.glob("*.json")):
        if path.name.startswith("_"):
            continue
        for raw in json.loads(path.read_text()):
            lines = normalize_lines(raw["lines"])
            if not lines or not raw["title"].strip():
                continue
            poems.append({
                "title": raw["title"].strip(),
                "author": raw["author"].strip(),
                "lines": lines,
                "linecount": str(len(lines)),
                "source": "poetrydb",
            })
    return poems


def load_gutenberg() -> list[dict]:
    books = json.loads((HERE / "books.json").read_text())
    poems = []
    for book in books:
        parsed = parse_gutenberg.parse_book(book)
        for poem in parsed:
            poem["lines"] = normalize_lines(poem["lines"])
            poem["linecount"] = str(len(poem["lines"]))
        poems.extend(parsed)
        print(f"  gutenberg {book['id']} {book['book']}: {len(parsed)} poems")
    return poems


SHIPPED_KEYS = HERE / "shipped_keys.json"
NEAR_DUPLICATE_RATIO = 0.8


def words_of(lines: list[str]) -> list[str]:
    return re.findall(r"[a-z]+", " ".join(lines).lower())


def is_near_duplicate(a: list[str], b: list[str]) -> bool:
    """Same poem from a different edition: near-identical wording, or one
    text (nearly) contained in the other (e.g. an excerpt)."""
    if not a or not b:
        return False
    short, long_ = (a, b) if len(a) <= len(b) else (b, a)
    # Cheap prefilter: most of the shorter poem's opening words must appear
    # in the longer one.
    opening = set(short[:12])
    if len(opening & set(long_)) < 0.6 * len(opening):
        return False
    matcher = difflib.SequenceMatcher(None, short, long_, autojunk=False)
    if matcher.quick_ratio() < 0.5:
        return False
    matched = sum(block.size for block in matcher.get_matching_blocks())
    return matcher.ratio() >= NEAR_DUPLICATE_RATIO or matched >= 0.9 * len(short)


def links_swift_authors() -> set[str]:
    text = LINKS_SWIFT.read_text()
    return set(re.findall(r'"([^"]+)":\s*\n?\s*"https?://', text))


def main() -> int:
    poetrydb = load_poetrydb()
    print(f"poetrydb: {len(poetrydb)} poems")
    gutenberg = load_gutenberg()
    print(f"gutenberg: {len(gutenberg)} poems")

    # The app's identity model is (title, author): identical bodies are fetch
    # artifacts and are dropped, but genuinely different poems sharing a title
    # (Blake wrote two "Holy Thursday"s) are kept under a numbered title.
    #
    # Poems that have already shipped (shipped_keys.json, from the live
    # catalog) are never dropped – users' favorites are keyed by (title,
    # author). A NEW poem is dropped if it is a near-duplicate of a poem the
    # same author already has: the same text from another edition, possibly
    # under another title.
    shipped = set(json.loads(SHIPPED_KEYS.read_text())) if SHIPPED_KEYS.exists() else set()

    # Clean every poem's text; titles only for poems that haven't shipped
    # (a shipped title is the identity users' favorites are stored under).
    for poem in poetrydb + gutenberg:
        poem["lines"] = clean_text.clean_lines(poem["lines"], poem["author"])
        poem["linecount"] = str(len(poem["lines"]))
        if f"{poem['title']}|{poem['author']}" not in shipped:
            poem["title"] = clean_text.clean_title(poem["title"])
    merged: dict[tuple[str, str], dict] = {}
    words_by_author: dict[str, list[list[str]]] = {}
    dedupe_log = []
    near_dupe_log = []
    renumber_log = []
    numerals = ["II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
    for poem in poetrydb + gutenberg:  # poetrydb first => wins collisions
        key = (poem["title"].lower(), poem["author"])
        words = words_of(poem["lines"])
        # Work out the title this poem would actually get (a same-title
        # collision is renumbered "… II") and check THAT against shipped.
        final_title = poem["title"]
        if key in merged:
            final_title = next(
                (f"{poem['title']} {n}" for n in numerals
                 if (f"{poem['title']} {n}".lower(), poem["author"]) not in merged),
                poem["title"],
            )
        is_shipped = f"{final_title}|{poem['author']}" in shipped
        if not is_shipped and shipped and any(
            is_near_duplicate(words, other) for other in words_by_author.get(poem["author"], [])
        ):
            near_dupe_log.append(f"{poem['author']} — {poem['title']} ({poem['source']} dropped)")
            continue
        words_by_author.setdefault(poem["author"], []).append(words)
        if key in merged:
            if merged[key]["lines"] == poem["lines"]:
                dedupe_log.append(f"{poem['author']} — {poem['title']} ({poem['source']} dropped)")
                continue
            base_title = poem["title"]
            for numeral in numerals:
                candidate = f"{base_title} {numeral}"
                key = (candidate.lower(), poem["author"])
                if key not in merged:
                    poem = {**poem, "title": candidate}
                    break
            else:
                raise RuntimeError(f"too many title collisions: {base_title}")
            renumber_log.append(f"{poem['author']} — {base_title} → {poem['title']}")
        merged[key] = poem

    catalog = sorted(merged.values(), key=lambda p: (p["author"], p["title"]))
    present = {f"{p['title']}|{p['author']}" for p in catalog}
    missing_shipped = sorted(shipped - present)
    if missing_shipped:
        print("ERROR: shipped poems missing from the new catalog:", file=sys.stderr)
        for key in missing_shipped[:20]:
            print(f"  {key}", file=sys.stderr)
        return 1
    authors = sorted({p["author"] for p in catalog})

    catalog_path = APP_SERVICE_DIR / "PoemCatalog.json"
    catalog_path.write_text(json.dumps(catalog, indent=1, ensure_ascii=False))
    (APP_SERVICE_DIR / "Authors.json").write_text(
        json.dumps({"authors": authors}, indent=2, ensure_ascii=False)
    )

    linked = links_swift_authors()
    missing_links = [a for a in authors if a not in linked]

    counts: dict[str, int] = {}
    for poem in catalog:
        counts[poem["author"]] = counts.get(poem["author"], 0) + 1

    report = [
        "# Catalog build report",
        "",
        f"- poems: {len(catalog)}",
        f"- authors: {len(authors)}",
        f"- catalog size: {catalog_path.stat().st_size / 1_000_000:.1f} MB",
        f"- deduped: {len(dedupe_log)}",
        f"- near-duplicates dropped: {len(near_dupe_log)}",
        "",
        "## Text clean-up (lines changed per fix)",
        *[f"- {name}: {n}" for name, n in sorted(clean_text.STATS.items())],
        "",
        "## Authors missing from Links.swift (add Wikipedia URLs)",
        *([f"- {a}" for a in missing_links] or ["(none)"]),
        "",
        "## Poems per author",
        *[f"- {a}: {n}" for a, n in sorted(counts.items())],
        "",
        "## Distinct poems renumbered to avoid title collisions",
        *([f"- {entry}" for entry in renumber_log] or ["(none)"]),
        "",
        "## Dedupe log (identical bodies dropped)",
        *([f"- {entry}" for entry in dedupe_log] or ["(none)"]),
        "",
        "## Near-duplicates dropped (same poem, another edition)",
        *([f"- {entry}" for entry in near_dupe_log] or ["(none)"]),
    ]
    (HERE / "report.md").write_text("\n".join(report))
    print(f"\ncatalog: {len(catalog)} poems, {len(authors)} authors, "
          f"{catalog_path.stat().st_size / 1_000_000:.1f} MB")
    print(f"missing Links.swift entries: {len(missing_links)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
