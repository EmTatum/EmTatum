## 2023-10-25 - Regex Anchoring in Shell Scripts
**Learning:** Adding a `^` or `$` anchor to a `grep` or `sed` pattern prevents the regex engine from scanning through the whole file unnecessarily, and improves correctness by avoiding false positive matches.
**Action:** Always anchor regex patterns when the position is known.
