#!/usr/bin/env python3
"""Parse cached Gutenberg plain-text poetry books into structured poems.

Used as a library by build_catalog.py; run directly to preview one book:
    python3 parse_gutenberg.py 64989

books.json options (all optional except id/author/book; all off by default):
  content_start, content_end   first heading line / line that ends the poems
  heading                      "allcaps" | "gap" | "regex" | "none"
  heading_regex                heading pattern for heading="regex"
  roman_headings               "section" | "keep" | "first_line_title" | "numbered"
  skip_titles                  headings that are not poems
  max_expected_poems           sanity cap on the parsed poem count
  text_substitutions           [pattern, replacement] pairs over the whole text
  join_heading_lines           {first, next, sep}: merge multi-line headings
  drop_line_regex              blank out matching lines before parsing
  cut_line_regex               end a poem body at the first matching line
  clean                        ["footnotes", "line_numbers", "ornaments"]
  numbered_headings            arabic "12." lines act like roman numerals
  number_prefix                arabic-only lines become "<prefix> 12" titles
  numbered_title_regex         first_line_title: matching lines are real titles
  title_continuation           unbroken lines under a heading extend the title
  subtitles                    allcaps/regex: ignore a heading-like subtitle
  title_substitutions          [pattern, replacement] pairs over each heading
  strip_heading_markup         drop _italics_, [A] markers, trailing "."
  title_cleanup                tidy the shown title (not the override key)
  title_prefix_regex           numbering prefix removed by title_cleanup

overrides/<id>.json keys (title keys are matched case/space-insensitively; in drop,
rename, trim_head and cut_at a "#N" suffix targets the Nth such heading):
  drop                list of titles to skip
  rename              {title: new title}
  split               {title: prefix}: split a sequence at its part numerals
  trim_head           {title: N}: drop the first N nonblank body lines
  cut_at              {title: line}: truncate the body at that line
  not_headings        heading-shaped lines that continue the poem above
  keep_title_line     untitled poems whose heading is also their first line
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
ARABIC = re.compile(r"^\d+\.?$")
FOOTNOTE_MARKER = re.compile(r"\s?\[\d+(?::[A-Z])?\]")
LINE_NUMBER = re.compile(r"^(.*\S)\s{3,}\d{1,4}\s*$")
ORNAMENT = re.compile(r"^[\s*]+$")


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


def clean_body(body: list[str], cleaners: list[str]) -> list[str]:
    """Opt-in scrubbing of edition apparatus from a poem body:
    "footnotes" drops '[Footnote ...]' blocks, a trailing 'FOOTNOTES:'
    section and inline '[3]' / '[45:A]' markers; "line_numbers" drops
    right-margin line numbers ('...wood!        20'); "ornaments" drops
    lines made only of asterisks (decorative separators)."""
    out: list[str] = []
    in_footnote = False
    for line in body:
        stripped = line.strip()
        if "footnotes" in cleaners:
            if stripped == "FOOTNOTES:":
                break
            if in_footnote or stripped.startswith("[Footnote"):
                in_footnote = not stripped.endswith("]")
                continue
            line = FOOTNOTE_MARKER.sub("", line)
        if "line_numbers" in cleaners:
            match = LINE_NUMBER.match(line)
            if match:
                line = match.group(1)
        if "ornaments" in cleaners and stripped and ORNAMENT.match(line):
            continue
        out.append(line)
    return out


def strip_heading_markup(raw: str) -> str:
    """strip_heading_markup: remove surrounding _italics_ underscores, a
    trailing footnote marker like [A] or [1], and a trailing full stop
    ("THE JUMBLIES." -> "THE JUMBLIES"). Applied before override lookup."""
    title = re.sub(r"\s*\[[A-Z0-9]{1,3}\]$", "", raw.strip())
    if len(title) > 2 and title.startswith("_") and title.endswith("_"):
        title = title[1:-1].strip()
    if title.endswith(".") and not title.endswith(".."):
        title = title[:-1].rstrip()
    return title


def tidy_display_title(title: str, prefix_regex: str | None) -> str:
    """title_cleanup: strip a numbering prefix, every _italic_ marker and
    trailing punctuation from the shown title (override keys still use the
    raw heading)."""
    if prefix_regex:
        title = re.sub(prefix_regex, "", title)
    title = title.replace("_", "")
    title = re.sub(r"\s+", " ", title).strip()
    return title.rstrip(".,;:").strip()


def join_heading_lines(lines: list[str], spec: dict) -> list[str]:
    """Merge a heading printed over several consecutive lines into one line.

    A group starts at a line set off by 2+ blank lines whose text, leading
    whitespace included, fully matches `first`; each immediately following
    nonblank line whose stripped text fully matches `next` is appended with
    `sep` (Hardy: "SHE" / "AT HIS FUNERAL" -> "SHE: AT HIS FUNERAL")."""
    first = re.compile(spec.get("first", r".+"))
    nxt = re.compile(spec.get("next", r".+"))
    sep = spec.get("sep", " ")
    out: list[str] = []
    blanks = 2  # the very first line counts as set off
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if not stripped:
            blanks += 1
            out.append(line)
            i += 1
            continue
        if blanks >= 2 and first.fullmatch(line.rstrip()):
            joined = stripped
            j = i + 1
            while (
                j < len(lines)
                and lines[j].strip()
                and nxt.fullmatch(lines[j].strip())
            ):
                joined += sep + lines[j].strip()
                j += 1
            if j > i + 1:
                out.append(joined)
                i = j
                blanks = 0
                continue
        out.append(line)
        blanks = 0
        i += 1
    return out


def load_overrides(book_id: int) -> dict:
    path = OVERRIDES / f"{book_id}.json"
    if path.exists():
        return json.loads(path.read_text())
    return {}


def normalize_key(title: str) -> str:
    return re.sub(r"\s+", " ", title.strip()).upper()


def split_numbered_sequence(poem: dict, title_prefix: str,
                            arabic: bool = False) -> list[dict]:
    """Split one parsed poem whose body contains roman-numeral part markers
    (or, with `arabic`, '4.' markers) into separate poems titled
    '<prefix> I', '<prefix> II', ... A marker may carry an inline title
    ('VI     Bluebeard'), which then wins; the 2+ space gap requirement keeps
    ordinary lines starting with 'I ' from matching."""
    numerals = r"[IVXLC]+|\d+(?=\.)" if arabic else r"[IVXLC]+"
    marker = re.compile(rf"^({numerals})\.?(?:\s{{2,}}(\S.*))?$")
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
    # text_substitutions: edition clean-up applied to the whole text in
    # multiline mode (illustration captions, margin numbers, broken headings).
    for pattern, replacement in book.get("text_substitutions", []):
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    lines = content.splitlines()
    if book.get("join_heading_lines"):
        lines = join_heading_lines(lines, book["join_heading_lines"])

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
    # trim_head / cut_at / not_headings / keep_title_line: see module docstring.
    trims = {normalize_key(k): v for k, v in overrides.get("trim_head", {}).items()}
    cuts = {normalize_key(k): v for k, v in overrides.get("cut_at", {}).items()}
    not_headings = {normalize_key(t) for t in overrides.get("not_headings", [])}
    keep_title = {normalize_key(t) for t in overrides.get("keep_title_line", [])}

    # drop_line_regex blanks matching lines (captions, footnotes) before
    # heading detection, so they neither land in a body nor hide the blank
    # run before a title; cut_line_regex ends a poem at the first matching
    # body line (a trailing editor's NOTE and everything after it).
    drop_line = re.compile(book["drop_line_regex"]) if book.get("drop_line_regex") else None
    cut_line = re.compile(book["cut_line_regex"]) if book.get("cut_line_regex") else None
    cleaners = book.get("clean", [])  # see clean_body()
    # Heading rewrites before override lookup: title_substitutions
    # ([pattern, replacement] pairs) then strip_heading_markup.
    title_subs = book.get("title_substitutions", [])
    strip_markup = book.get("strip_heading_markup", False)
    # title_cleanup only changes the shown title; overrides use the raw one.
    tidy_titles = book.get("title_cleanup", False)
    # numbered_headings: arabic-only lines ('12' / '12.') behave like roman
    # numerals, also as split part markers ('4.').
    numbered = book.get("numbered_headings", False)

    poems: list[dict] = []
    title: str | None = None
    body: list[str] = []
    heading_lines: list[str] = []  # raw heading line(s), for keep_title_line
    seen: dict[str, int] = {}  # heading key -> occurrences, for '#N' keys

    def pick(table: dict, key: str, occurrence: str):
        return table.get(occurrence, table.get(key))

    def trim_and_cut(key: str, lines_in: list[str], occurrence: str = "") -> list[str]:
        lines_out = list(lines_in)
        remaining = pick(trims, key, occurrence) or 0
        while lines_out and remaining:
            if lines_out.pop(0).strip():
                remaining -= 1
        cut = pick(cuts, key, occurrence)
        if cut is not None:
            for i, line in enumerate(lines_out):
                if line.strip() == cut:
                    lines_out = lines_out[:i]
                    break
        return lines_out

    def flush() -> None:
        nonlocal title, body, heading_lines
        if title is None:
            return
        for pattern, replacement in title_subs:
            title = re.sub(pattern, replacement, title).strip()
        if strip_markup:
            title = strip_heading_markup(title)
        if cut_line:
            for i, bodyline in enumerate(body):
                if cut_line.match(bodyline.strip()):
                    body = body[:i]
                    break
        key = normalize_key(title)
        seen[key] = seen.get(key, 0) + 1
        occurrence = f"{key}#{seen[key]}"
        if key in keep_title:
            body = heading_lines + body
        body = trim_and_cut(key, body, occurrence)
        if cleaners:
            body = clean_body(body, cleaners)
        normalized = normalize_body(body)
        if len(normalized) >= 2 and key not in skip and occurrence not in skip:
            shown = title
            if tidy_titles:
                shown = tidy_display_title(title, book.get("title_prefix_regex"))
            is_allcaps = shown.upper() == shown
            final_title = pick(renames, key, occurrence) or (
                prettify_title(shown) if is_allcaps else shown
            )
            poem = {
                "title": final_title,
                "author": book["author"],
                "lines": normalized,
                "linecount": str(len(normalized)),
                "source": f"gutenberg:{book['id']}",
            }
            if key in splits:
                for part in split_numbered_sequence(poem, splits[key], numbered):
                    part_key = normalize_key(part["title"])
                    part["lines"] = normalize_body(
                        trim_and_cut(part_key, part["lines"]))
                    part["linecount"] = str(len(part["lines"]))
                    part["title"] = renames.get(part_key, part["title"])
                    poems.append(part)
            else:
                poems.append(poem)
        title, body, heading_lines = None, [], []

    # Roman-numeral-only headings are part markers inside one poem ("keep"),
    # dividers between poems ("section"), markers of untitled poems that
    # take their first line as their title ("first_line_title" — the Millay
    # sonnet convention), or titles "<number_prefix> XIV" ("numbered").
    roman_mode = book.get("roman_headings", "section")
    style = book.get("heading", "allcaps")
    # number_prefix: arabic-only lines ('12' / '12.') are headings titled
    # '<number_prefix> 12'.
    number_prefix = book.get("number_prefix")
    # numbered_title_regex: with first_line_title, a line after the numeral
    # that matches is a real title rather than the poem's first line.
    numbered_title = (re.compile(book["numbered_title_regex"])
                      if book.get("numbered_title_regex") else None)
    # title_continuation: nonblank lines directly under a heading (no blank
    # line between) continue the title ('LINES' / 'Written in early Spring').
    continuation = book.get("title_continuation", False)
    # subtitles: extend the gap-style "just titled" rule below to other
    # styles, for editions that print a heading-styled subtitle.
    subtitles = book.get("subtitles", False)

    blanks_before = 0
    after_section = True  # content_start line itself is a heading
    pending_first_line_title = False
    for line in lines[start_index:end_index]:
        stripped = line.strip()
        if drop_line and stripped and drop_line.match(stripped):
            line = stripped = ""
        if not stripped:
            blanks_before += 1
            if title is not None:
                body.append(line)
            continue
        if pending_first_line_title:
            if "ornaments" in cleaners and ORNAMENT.match(line):
                continue
            title = stripped
            # Normally the title line is also the poem's first line.
            is_real_title = bool(numbered_title and numbered_title.fullmatch(stripped))
            body = [] if is_real_title else [line]
            pending_first_line_title = False
            blanks_before = 0
            continue
        if number_prefix and (
            ARABIC.match(stripped)
            or (roman_mode == "numbered" and ROMAN.match(stripped))
        ):
            flush()
            title = f"{number_prefix} {stripped.rstrip('.')}"
            blanks_before = 0
            after_section = False
            continue
        # With the "ornaments" cleaner, a heading-gap asterisk row divides
        # poems like a bare roman numeral (untitled poems in Wordsworth).
        ornament_divider = ("ornaments" in cleaners and style == "gap"
                            and blanks_before >= 3 and bool(ORNAMENT.match(line)))
        if (ROMAN.match(stripped) or (numbered and ARABIC.match(stripped))
                or ornament_divider):
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
        if (continuation and title is not None and heading_lines and not body
                and normalize_key(title) not in keep_title):
            title = f"{title} {stripped}"
            heading_lines.append(line)
            blanks_before = 0
            continue
        body_is_empty = not any(bodyline.strip() for bodyline in body)
        # In gap-style editions a title can be followed by the same blank run
        # that separates poems — while the body is still empty, the next
        # nonblank line is the body's first line, never a new heading.
        just_titled = ((style == "gap" or subtitles)
                       and title is not None and body_is_empty)
        if (not just_titled
                and normalize_key(stripped) not in not_headings
                and is_heading(line, style, book.get("heading_regex"),
                               blanks_before, after_section)):
            flush()
            title = stripped
            heading_lines = [line]
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
