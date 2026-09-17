## 2026-09-17 - Bash builtins vs Cross-platform Compatibility
**Learning:** Replacing `date` with Bash 4.2+ `printf '%(...)T'` builtin saves ~10ms but breaks macOS (which ships with Bash 3.2). This is a micro-optimization with no meaningful impact that sacrifices cross-platform compatibility.
**Action:** Do not apply Bash version-specific micro-optimizations that trade negligible performance gains for compatibility regressions. Wait for real performance bottlenecks.
