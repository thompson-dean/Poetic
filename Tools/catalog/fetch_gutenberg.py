#!/usr/bin/env python3
"""Download the Project Gutenberg plain-text books listed in books.json.

Files are cached in cache/gutenberg/{id}.txt; re-runs skip cached books.
"""
import json
import pathlib
import sys
import time
import urllib.request

HERE = pathlib.Path(__file__).parent
CACHE = HERE / "cache" / "gutenberg"
BOOKS = HERE / "books.json"
RETRIES = 2


MIRROR = "https://gutenberg.pglaf.org"


def mirror_dir(book_id: int) -> str:
    """Mirror layout: every digit but the last is a directory (8905 -> 8/9/0/8905)."""
    digits = str(book_id)
    parents = "0" if len(digits) == 1 else "/".join(digits[:-1])
    return f"{MIRROR}/{parents}/{digits}"


def fetch(book_id: int) -> str:
    # gutenberg.org first; the official pglaf mirror as fallback (the main
    # site sometimes answers automated requests with 503).
    urls = [
        f"https://www.gutenberg.org/ebooks/{book_id}.txt.utf-8",
        f"https://www.gutenberg.org/cache/epub/{book_id}/pg{book_id}.txt",
        f"{MIRROR}/cache/epub/{book_id}/pg{book_id}.txt",
        f"{mirror_dir(book_id)}/{book_id}-0.txt",
        f"{mirror_dir(book_id)}/{book_id}.txt",
    ]
    last_error = None
    for url in urls:
        for attempt in range(1, RETRIES + 1):
            try:
                request = urllib.request.Request(url, headers={"User-Agent": "poetic-catalog-tool"})
                with urllib.request.urlopen(request, timeout=120) as response:
                    raw = response.read()
                try:
                    return raw.decode("utf-8-sig")
                except UnicodeDecodeError:
                    return raw.decode("latin-1")
            except Exception as error:  # noqa: BLE001
                last_error = error
                time.sleep(attempt * 2)
    raise RuntimeError(f"could not fetch book {book_id}: {last_error}")


def main() -> int:
    CACHE.mkdir(parents=True, exist_ok=True)
    books = json.loads(BOOKS.read_text())
    failed = []
    for book in books:
        out = CACHE / f"{book['id']}.txt"
        if out.exists():
            continue
        try:
            text = fetch(book["id"])
            out.write_text(text)
            print(f"{book['id']} {book['book']}: {len(text)} chars")
            time.sleep(1)
        except Exception as error:  # noqa: BLE001
            failed.append((book["id"], str(error)))
            print(f"{book['id']}: FAILED {error}", file=sys.stderr)
    if failed:
        return 1
    print("done — all books cached")
    return 0


if __name__ == "__main__":
    sys.exit(main())
