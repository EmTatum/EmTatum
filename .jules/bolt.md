## 2024-05-18 - [Anchoring Regex in Small Files]
**Learning:** Anchoring a regex in `grep` with `^` for small files like a README does not yield a measurable performance improvement and is considered a micro-optimization/correctness fix rather than a true performance win.
**Action:** Avoid claiming performance wins for unmeasurable micro-optimizations, especially in shell scripts handling small files. If no measurable optimization exists, stop and do not create a PR.
