#!/usr/bin/env python3
"""Parse cached Gutenberg plain-text poetry books into structured poems.

Used as a library by build_catalog.py; run directly to preview one book:
    python3 parse_gutenberg.py 64989
"""
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).parent
CACHE = HERE / "cache" / "gutenberg"
OVERRIDES = HERE / "overrides"

START_MARKER = re.compile(r"\*\*\* ?START OF (THE|THIS) PROJECT GUTENBERG EBOOK.*\*\*\*")
END_MARKER = re.compile(r"\*\*\* ?END OF (THE|THIS) PROJECT GUTENBERG EBOOK.*\*\*\*")

SMALL_WORDS = {
    "a", "an", "and", "as", "at", "but", "by", "for", "from", "in",
    "into", "nor", "of", "on", "or", "the", "to", "with", "o'", "d'",
}
ROMAN = re.compile(r"^[IVXLC]+\.?$")


def strip_gutenberg_wrapper(text: str) -> str:
    lines = text.splitlines()
    start = 0
    end = len(lines)
    for i, line in enumerate(lines):
        if START_MARKER.search(line):
            start = i + 1
        elif END_MARKER.search(line):
            end = i
            break
    return "\n".join(lines[start:end])


def prettify_title(raw: str) -> str:
    """ALL-CAPS Gutenberg headings -> normal title case, keeping roman numerals."""
    words = raw.strip().split()
    pretty = []
    for i, word in enumerate(words):
        if ROMAN.match(word):
            pretty.append(word)
            continue
        lowered = word.lower()
        if 0 < i < len(words) - 1 and lowered in SMALL_WORDS:
            pretty.append(lowered)
        else:
            pretty.append(lowered[:1].upper() + lowered[1:])
    return " ".join(pretty)


def is_heading(line: str, style: str, heading_regex: str | None,
               blanks_before: int, after_section: bool) -> bool:
    stripped = line.strip()
    if not stripped or len(stripped) > 70:
        return False
    if after_section:
        # The content_start line, or the line right after a section marker,
        # is a title regardless of style.
        return True
    if style == "allcaps":
        # Two blank lines required: editions like Rivers to the Sea print
        # in-poem refrains in caps, but those follow at most one blank line.
        letters = [c for c in stripped if c.isalpha()]
        return blanks_before >= 2 and bool(letters) and all(c.isupper() for c in letters)
    if style == "gap":
        # Editions with title-case headings: a title is set off by a run of
        # blank lines.
        return blanks_before >= 3
    if style == "regex" and heading_regex:
        return bool(re.match(heading_regex, stripped))
    return False


def normalize_body(body: list[str]) -> list[str]:
    lines = [line.rstrip() for line in body]
    while lines and not lines[0]:
        lines.pop(0)
    while lines and not lines[-1]:
        lines.pop()
    # Remove the common leading indent (Gutenberg indents whole poems),
    # preserving relative indentation within the poem.
    indents = [len(line) - len(line.lstrip()) for line in lines if line]
    margin = min(indents, default=0)
    if margin:
        lines = [line[margin:] if line else line for line in lines]
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


def load_overrides(book_id: int) -> dict:
    path = OVERRIDES / f"{book_id}.json"
    if path.exists():
        return json.loads(path.read_text())
    return {}


def normalize_key(title: str) -> str:
    return re.sub(r"\s+", " ", title.strip()).upper()


def split_numbered_sequence(poem: dict, title_prefix: str) -> list[dict]:
    """Split one parsed poem whose body contains roman-numeral part markers
    into separate poems titled '<prefix> I', '<prefix> II', ... A marker may
    carry an inline title ('VI     Bluebeard'), which then wins; the 2+ space
    gap requirement keeps ordinary lines starting with 'I ' from matching."""
    marker = re.compile(r"^([IVXLC]+)\.?(?:\s{2,}(\S.*))?$")
    parts: list[tuple[str, list[str]]] = []
    current: list[str] | None = None
    part_title = None
    for line in poem["lines"]:
        match = marker.match(line.strip())
        if match:
            if part_title is not None:
                parts.append((part_title, current or []))
            numeral, inline = match.group(1), match.group(2)
            part_title = inline.strip() if inline else f"{title_prefix} {numeral}"
            current = []
        elif part_title is not None:
            assert current is not None
            current.append(line)
    if part_title is not None:
        parts.append((part_title, current or []))

    poems = []
    for part_title, body in parts:
        from_body = [line.rstrip() for line in body]
        while from_body and not from_body[0]:
            from_body.pop(0)
        while from_body and not from_body[-1]:
            from_body.pop()
        if len(from_body) >= 2:
            poems.append({
                "title": part_title,
                "author": poem["author"],
                "lines": from_body,
                "linecount": str(len(from_body)),
                "source": poem["source"],
            })
    return poems


def parse_book(book: dict) -> list[dict]:
    text = (CACHE / f"{book['id']}.txt").read_text()
    content = strip_gutenberg_wrapper(text)
    lines = content.splitlines()

    # Skip front matter (contents, dedication) until the first real poem title.
    start_index = 0
    content_start = book.get("content_start")
    if content_start:
        matches = [i for i, line in enumerate(lines) if line.strip() == content_start]
        if not matches:
            raise RuntimeError(f"book {book['id']}: content_start {content_start!r} not found")
        # The title also appears in the table of contents, so use the LAST match.
        start_index = matches[-1]

    content_end = book.get("content_end")
    end_index = len(lines)
    if content_end:
        for i in range(start_index + 1, len(lines)):
            if lines[i].strip() == content_end:
                end_index = i
                break

    overrides = load_overrides(book["id"])
    skip = {normalize_key(t) for t in book.get("skip_titles", [])} | {
        normalize_key(t) for t in overrides.get("drop", [])
    }
    renames = {normalize_key(k): v for k, v in overrides.get("rename", {}).items()}
    splits = {normalize_key(k): v for k, v in overrides.get("split", {}).items()}

    poems: list[dict] = []
    title: str | None = None
    body: list[str] = []

    def flush() -> None:
        nonlocal title, body
        if title is None:
            return
        normalized = normalize_body(body)
        key = normalize_key(title)
        if len(normalized) >= 2 and key not in skip:
            is_allcaps = title.upper() == title
            final_title = renames.get(key) or (
                prettify_title(title) if is_allcaps else title
            )
            poem = {
                "title": final_title,
                "author": book["author"],
                "lines": normalized,
                "linecount": str(len(normalized)),
                "source": f"gutenberg:{book['id']}",
            }
            if key in splits:
                poems.extend(split_numbered_sequence(poem, splits[key]))
            else:
                poems.append(poem)
        title, body = None, []

    # Roman-numeral-only headings are part markers inside one poem ("keep"),
    # dividers between poems ("section"), or markers of untitled poems that
    # take their first line as their title ("first_line_title" — the Millay
    # sonnet convention).
    roman_mode = book.get("roman_headings", "section")
    style = book.get("heading", "allcaps")

    blanks_before = 0
    after_section = True  # content_start line itself is a heading
    pending_first_line_title = False
    for line in lines[start_index:end_index]:
        stripped = line.strip()
        if not stripped:
            blanks_before += 1
            if title is not None:
                body.append(line)
            continue
        if pending_first_line_title:
            title = stripped
            body = [line]  # the title line is also the poem's first line
            pending_first_line_title = False
            blanks_before = 0
            continue
        if ROMAN.match(stripped):
            if roman_mode == "keep" and title is not None:
                body.append(line)
            elif roman_mode == "first_line_title":
                flush()
                pending_first_line_title = True
            else:
                flush()
                after_section = True
            blanks_before = 0
            continue
        body_is_empty = not any(bodyline.strip() for bodyline in body)
        # In gap-style editions a title can be followed by the same blank run
        # that separates poems — while the body is still empty, the next
        # nonblank line is the body's first line, never a new heading.
        just_titled = style == "gap" and title is not None and body_is_empty
        if not just_titled and is_heading(
            line, style, book.get("heading_regex"), blanks_before, after_section
        ):
            flush()
            title = stripped
        elif title is not None:
            body.append(line)
        blanks_before = 0
        after_section = False
    flush()

    maximum = book.get("max_expected_poems", 300)
    if not poems:
        raise RuntimeError(f"book {book['id']} ({book['book']}): parsed 0 poems")
    if len(poems) > maximum:
        raise RuntimeError(
            f"book {book['id']} ({book['book']}): parsed {len(poems)} poems, "
            f"expected at most {maximum} — heading heuristic is over-matching"
        )
    return poems


if __name__ == "__main__":
    books = json.loads((HERE / "books.json").read_text())
    wanted = int(sys.argv[1]) if len(sys.argv) > 1 else None
    for entry in books:
        if wanted and entry["id"] != wanted:
            continue
        parsed = parse_book(entry)
        print(f"\n=== {entry['book']} ({entry['author']}): {len(parsed)} poems")
        for poem in parsed:
            print(f"  {poem['title']}  [{poem['linecount']} lines]")
