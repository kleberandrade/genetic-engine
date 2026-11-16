# Engineering log

## 2026-11-16 — Framework structure and repository readiness

The requested `/ub-mode` workflow was read before edits and applied to the work.
This log records actions, reasons and observed evidence rather than unsupported
quality claims.

| Step | Action and reason | Evidence |
| --- | --- | --- |
| 1 | Inspect source, git status and local workflow before edits | Clean starting worktree; baseline commit c3b242d |
| 2 | Write consumer-facing interface tests before implementation | Tests failed because function typedefs could not be implemented and strategy classes were missing |
| 3 | Introduce five interfaces and callback adapters | Custom mutation, built-in strategy assignment and callback construction tests passed |
| 4 | Separate domain, contracts, adapters, operators and engine | All 8 original behavioral tests retained via the callback entry point |
| 5 | Extract evaluation, ranking, reproduction, advancement and stop checks | Evolution behavior preserved; per-run mutable state stays local |
| 6 | Add operator and engine boundary tests | Total 19 tests passed, including invalid rates, stopping priority, unchanged parents and permutation validity |
| 7 | Run installed crapper, dryer at 0.8, and mutator scan | Each reported no supported source files; installed versions do not support Dart. CRAP and mutation scores are unavailable |
| 8 | Verify Dart analysis and formatting | Analyzer: no issues; format check: 33 files, zero changes |
| 9 | Run all three executable examples | OneMax reached 32; numerical minimization reached 0.00083753; custom integer mutation reached 0 |
| 10 | Document usage, architecture, extension, migration and runtime integration | README links to each guide and runnable examples |
| 11 | Add contribution workflow, templates, accurate badges and CI matrix | Minimum/stable SDK checks configured; remote CI remains a separate result |
| 12 | Prepare source version 0.2.0 | Breaking API boundary documented; no claim of hosted pub.dev publication |

The initial CLI wrappers attempted to write telemetry outside the writable
workspace. The supported `--suppress-analytics` flag allowed a clean analyzer
and format check without changing global settings. Tests and examples ran via
the SDK VM directly. A clean analyzer result does not imply publication success.

No repository-backed source is duplicated into an artifact store. No unrelated
worktree or user cache was deleted. Source version tags are distinct from hosted
package releases. GitHub push, tag synchronization and topic changes should be
reported according to their observed outcomes.

## 2026-11-16 — Publication preparation

- Renamed the documentation directory to `doc/` at the maintainer's request;
  updated README and repository instructions to use the new paths.
- Prepared source version 0.2.1 to preserve the existing public 0.2.0 tag.
- Confirmed the package page returns 404 before publication and identified the
  account's existing `kleberandrade.dev` publisher.
- Inspected remote CI: the previous revision failed at publication dry-run.
- Created an isolated writable dependency cache and resolved dependencies offline.
  Publishing validation still requires network access; the shell cannot resolve
  pub.dev. No validation has been bypassed and no publication is claimed.
