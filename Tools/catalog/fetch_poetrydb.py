#!/usr/bin/env python3
"""Dump the full PoetryDB catalog via its public API.

Raw responses are cached in cache/poetrydb/, one JSON file per author.
Re-runs skip anything already cached, so interrupting is safe.
"""
import json
import pathlib
import re
import sys
import time
import urllib.parse
import urllib.request

BASE = "https://poetrydb.org"
CACHE = pathlib.Path(__file__).parent / "cache" / "poetrydb"
SLEEP_SECONDS = 0.5
RETRIES = 3


def slugify(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def get_json(url: str):
    last_error = None
    for attempt in range(1, RETRIES + 1):
        try:
            request = urllib.request.Request(
                url,
                headers={"User-Agent": "poetic-catalog-tool/1.0 (one-time public-domain dump)"},
            )
            with urllib.request.urlopen(request, timeout=30) as response:
                return json.load(response)
        except Exception as error:  # noqa: BLE001 - retry everything, report at the end
            last_error = error
            time.sleep(attempt * 2)
    raise RuntimeError(f"failed after {RETRIES} retries: {url}: {last_error}")


def fetch_author_by_titles(author: str) -> list[dict]:
    quoted_author = urllib.parse.quote(author)
    titles = [entry["title"] for entry in get_json(f"{BASE}/author/{quoted_author}/title")]
    print(f"  falling back to per-title fetch: {len(titles)} titles")
    poems = []
    seen = set()
    for title in titles:
        if title in seen:
            continue
        seen.add(title)
        url = f"{BASE}/author,title/{quoted_author};{urllib.parse.quote(title)}"
        result = get_json(url)
        if isinstance(result, list):
            poems.extend(p for p in result if p.get("author") == author)
        time.sleep(SLEEP_SECONDS)
    if not poems:
        raise RuntimeError(f"per-title fallback yielded 0 poems for {author}")
    return poems


def main() -> int:
    CACHE.mkdir(parents=True, exist_ok=True)

    authors_path = CACHE / "_authors.json"
    if authors_path.exists():
        authors = json.loads(authors_path.read_text())["authors"]
    else:
        authors = get_json(f"{BASE}/author")["authors"]
        authors_path.write_text(json.dumps({"authors": authors}, indent=2))
    print(f"{len(authors)} authors")

    failed = []
    for index, author in enumerate(authors, 1):
        out = CACHE / f"{slugify(author)}.json"
        if out.exists():
            continue
        url = f"{BASE}/author/{urllib.parse.quote(author)}"
        try:
            try:
                poems = get_json(url)
                if not isinstance(poems, list):
                    raise RuntimeError(f"unexpected response shape: {poems}")
            except Exception:
                # Large collections 503 on the all-at-once endpoint;
                # fall back to fetching the author's poems one title at a time.
                poems = fetch_author_by_titles(author)
            out.write_text(json.dumps(poems, indent=2, ensure_ascii=False))
            print(f"[{index}/{len(authors)}] {author}: {len(poems)} poems")
        except Exception as error:  # noqa: BLE001
            failed.append((author, str(error)))
            print(f"[{index}/{len(authors)}] {author}: FAILED {error}", file=sys.stderr)
        time.sleep(SLEEP_SECONDS)

    if failed:
        print("\nFAILED AUTHORS:", file=sys.stderr)
        for author, error in failed:
            print(f"  {author}: {error}", file=sys.stderr)
        return 1
    print("done — all authors cached")
    return 0


if __name__ == "__main__":
    sys.exit(main())
