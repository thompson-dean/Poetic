#!/usr/bin/env python3
"""Text clean-up applied to every poem by build_catalog.py.

Fixes transcription and transfer artifacts – never the poet's own words:
underscore italics, "--" dashes, backtick quotes, mojibake, HTML entities,
soft hyphens, margin line numbers, editorial markers and notes. Each fix is
counted so the build report shows what changed.
"""
import collections
import html
import re

STATS: collections.Counter = collections.Counter()

ITALIC_MARK = re.compile(r"(?<![\w])_(?=\S)|(?<=\S)_(?![\w])")
MARGIN_NUMBER = re.compile(r"(\S)\s{3,}\d{1,4}\s*$")
BRADSTREET_NUMBER = re.compile(r"^(\s*)\d+\.\d+\s+")
LIGATURE = re.compile(r"\{(oe|OE|ae|AE)\}")
LIGATURES = {"oe": "œ", "OE": "Œ", "ae": "æ", "AE": "Æ"}
NOISE_TOKENS = re.compile(r"\s*\[(?:back|Image|\d{1,2})\]")
ASTERISK_ROW = re.compile(r"^\s*(?:\*(?:\s+\*)+|_{2,})\s*$")
SUPERSCRIPT_CARET = re.compile(r"\^(\w+)\^?")

# Whole lines that are editors' notes, not verse.
EDITORIAL_LINES = [
    re.compile(r"^\[To Mrs\. Stewart of Stair Burns presented"),
    re.compile(r"^III\s*¹.*From \""),
]


def _count(name: str, before: str, after: str) -> str:
    if before != after:
        STATS[name] += 1
    return after


def fix_mojibake(line: str) -> str:
    if "Ã" not in line and "â€" not in line:
        return line
    try:
        return line.encode("cp1252").decode("utf-8")
    except (UnicodeEncodeError, UnicodeDecodeError):
        # Mixed lines (some chars already correct): repair known sequences.
        for bad, good in {"â€œ": "“", "â€\x9d": "”", "â€™": "’", "â€”": "—",
                          "Ã¦": "æ", "Ã§": "ç", "Ã©": "é"}.items():
            line = line.replace(bad, good)
        return line


def clean_line(line: str, author: str) -> str:
    line = _count("mojibake", line, fix_mojibake(line))
    if "&" in line:
        # "&Aelig;" isn't a valid entity (case-sensitive); normalise it first.
        line = _count("html entities", line, html.unescape(line.replace("&Aelig;", "&AElig;")))
    line = _count("soft hyphens", line, line.replace("\u00ad", ""))
    line = _count("tabs", line, line.replace("\t", "    "))
    line = _count("broken dashes (‹)", line, line.replace("‹", "—"))
    line = _count("underscore italics", line, ITALIC_MARK.sub("", line))
    line = _count("backtick quotes", line, line.replace("``", "“").replace("''", "”")
                  if "``" in line else line.replace("`", "'"))
    line = _count("-- dashes", line, line.replace("---", "—").replace("--", "—"))
    line = _count("margin line numbers", line, MARGIN_NUMBER.sub(r"\1", line))
    if author == "Anne Bradstreet":
        line = _count("verse numbering prefixes", line, BRADSTREET_NUMBER.sub(r"\1", line))
    line = _count("ligature braces", line, LIGATURE.sub(lambda m: LIGATURES[m.group(1)], line))
    line = _count("noise markers", line, NOISE_TOKENS.sub("", line))
    if ASTERISK_ROW.match(line):
        line = _count("asterisk dividers", line, "* * *")
    if "^" in line:
        line = _count("caret superscripts", line, SUPERSCRIPT_CARET.sub(r"\1", line))
    return line.rstrip()


def clean_lines(lines: list[str], author: str) -> list[str]:
    out: list[str] = []
    for raw in lines:
        if any(rx.search(raw.strip()) for rx in EDITORIAL_LINES):
            STATS["editorial note lines"] += 1
            continue
        line = clean_line(raw, author)
        # A line that held only a noise marker is gone, not left blank.
        if not line.strip() and raw.strip():
            continue
        out.append(line)
    # Trim and collapse blank runs left behind.
    while out and not out[0].strip():
        out.pop(0)
    while out and not out[-1].strip():
        out.pop()
    collapsed: list[str] = []
    for line in out:
        if not line.strip() and collapsed and not collapsed[-1].strip():
            continue
        collapsed.append(line)
    return collapsed


def clean_title(title: str) -> str:
    """For titles of poems that have NOT shipped yet (shipped titles are
    identities for users' favorites and must not change)."""
    cleaned = clean_line(title, "")
    return re.sub(r"\s+", " ", cleaned).strip()
