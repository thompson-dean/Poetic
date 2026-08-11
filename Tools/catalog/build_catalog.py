#!/usr/bin/env python3
"""Merge the PoetryDB dump and parsed Gutenberg books into the app resources.

Outputs:
  ../../Poetic/Service/PoemCatalog.json   (the bundled catalog)
  ../../Poetic/Service/Authors.json       (regenerated author list)
  report.md                               (counts, dedupe log, missing Links entries)
"""
import json
import pathlib
import re
import sys

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
    merged: dict[tuple[str, str], dict] = {}
    dedupe_log = []
    renumber_log = []
    numerals = ["II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
    for poem in poetrydb + gutenberg:  # poetrydb first => wins collisions
        key = (poem["title"].lower(), poem["author"])
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
    ]
    (HERE / "report.md").write_text("\n".join(report))
    print(f"\ncatalog: {len(catalog)} poems, {len(authors)} authors, "
          f"{catalog_path.stat().st_size / 1_000_000:.1f} MB")
    print(f"missing Links.swift entries: {len(missing_links)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
