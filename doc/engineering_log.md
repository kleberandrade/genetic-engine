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

- The corrected revision passed remote CI on both Dart 3.3.0 and stable,
  including publication dry-run (GitHub Actions run 43886405450).
- The local dry-run assembled the archive successfully, then failed with a
  socket error when contacting pub.dev; the publication upload remains blocked.
- Added a tag-triggered, validation-gated GitHub release job using the built-in
  short-lived repository token. No personal credential is copied to CI.
- Prepared source release notes that explicitly distinguish GitHub distribution
  from the pending hosted pub.dev publication.

## 2026-11-16 — Extended GA strategies (0.3.0)

| Action | Reason and evidence |
| --- | --- |
| Consult GeneticSharp README and primary research | Use concepts and organization without copying implementation code; traceability in references.md |
| Write new strategy tests before implementation | Observed expected missing-interface and missing-operator failures |
| Add elite and termination interfaces | Keep survival count and stateless stopping independent from problem callbacks |
| Add selection/crossover/mutation implementations | Extend the existing contracts with representation-safe operators |
| Pin PMX, CX and list transformations with explicit cuts | Test semantics in addition to permutation membership |
| Add stopping and configuration boundary tests | Validate generation cap, zero time limit, reuse, minimization and copied composite inputs |
| Run full verification | 38 tests passed; 58 Dart files formatted; analyzer clean; four executable examples passed |
| Run crapper, dryer at 0.8 and mutator scan | Tools still report no supported Dart files; no metric or mutation score claimed |
| Prepare repository topics | Eleven desired topics in .github/topics.json; actual GitHub update requires an authenticated administrative session |
| Preserve prior source release | Source 0.3.0 adds features without rewriting the existing public version tags |

The shell's pub.dev DNS restriction still prevents upload. The Chrome GitHub
session is signed out, so no claim is made that repository topics have been
applied. No credential was extracted, copied into source, or sent to CI.

## 2026-11-16 — Hosted publication confirmed

- The maintainer executed the publication command; verified genetic_engine 0.3.0
  on pub.dev rather than inferring success from the command alone.
- Accessed the authenticated in-app browser and saved all eleven repository
  topics; verified them in GitHub's rendered About section.
- Set the repository website to the public package page.
- Transferred package ownership to the existing `kleberandrade.dev` publisher;
  observed the successful-transfer confirmation and verified publisher badge.
- Checked pub.dev Scores: analysis is still pending; no score is claimed.
- Updated the GitHub README with hosted installation, package-version and API
  badges. The already uploaded 0.3.0 archive is immutable; its bundled README
  will pick up these text changes with the next package publication.
- Validation: metadata-only changes; checked relative links and git whitespace.
  Runtime code remains the previously validated 38-test revision.

## 2026-11-16 — Static analysis patch (0.3.1)

- Inspected the published 0.3.0 score: 150/160, with 40/50 in static analysis.
- Added the analyzer rule before changing code; reproduced exactly three
  missing-block diagnostics in GeneticAlgorithm, AndTermination and OrTermination.
- Added explicit blocks to those branches without changing their behavior.
- Kept the lint in analysis_options.yaml; existing `dart analyze --fatal-infos`
  CI now rejects this regression without another dependency.
- Prepared patch source version 0.3.1 and included the corrected installation
  README in the new archive. The hosted 0.3.0 archive remains unchanged.
- The pub.dev score must be confirmed after uploading and analyzing the patch;
  fixing source alone does not change the old published version's score.

## 2026-11-16 — Published consumer and benchmark validation

- Confirmed pub.dev 0.3.1 reached 160/160, with 50/50 static analysis.
- Kept the library unchanged from the published v0.3.1 source tag.
- Added generated consumer projects outside the repository, exact hosted-version
  pinning, and lockfile/cache checks that reject path overrides.
- Added real Dart optimization/isolate checks and Flutter compute/widget checks
  plus release web compilation. The dedicated CI jobs must supply completion
  evidence before hosted consumer success is claimed.
- Added nine benchmark configurations with seeds 0–9 and explicit warmup,
  environment, success and percentile methodology. The source-equivalent local
  baseline reached configured targets in all 90 measured runs. Raw results and
  scope limitations are committed under doc/benchmarks/.
- Validated script syntax, Dart tooling analysis and documentation links locally.
- The local shell still cannot resolve pub.dev, so actual hosted consumer
  installation and Flutter validation are assigned to the networked CI runner.
- No new runtime feature or package release is introduced by this validation work.

- First CI run confirmed hosted Dart installation, native isolate behavior and
  all 90 benchmark targets. Artifact upload skipped the hidden report directory;
  explicitly enabled hidden-file upload for that scoped directory and made a
  missing artifact a failure so raw evidence cannot silently disappear.
- The first Flutter consumer resolved hosted 0.3.1 successfully, then its
  fatal-info analysis rejected deprecated flutter/material.dart in the harness
  on the current stable SDK. Replaced the unnecessary Material wrapper with
  core WidgetsApp/widgets.dart; kept fatal-info validation enabled and did not
  suppress the diagnostic or change the genetic engine.
