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

- Confirmed successful consumer workflow run 43900206559 (commit 897fd20):
  hosted Dart checks and benchmark passed in 16 seconds; hosted Flutter analysis,
  compute/widget tests and release web compilation passed in 1 minute 20 seconds.
  Both evidence artifacts are present. All 90 hosted benchmark targets were met.
- Recorded the successful run and exact scope in doc/validation.md, added dynamic
  consumer/points badges, and retained source-library equivalence to v0.3.1.
- Browser artifact download was interrupted by a lost in-app route; no local
  copy of the CI artifact is claimed. The artifact files remain available in the
  verified GitHub run, alongside the separately committed local baseline.

## 2026-11-16 — SUS and problem walkthroughs (0.4.0 source)

- Added public-API SUS tests first and observed missing batch contract/operator
  and constructor parameter errors before implementing the feature.
- Added a separate batch contract to preserve existing single-parent strategy
  implementations. Constructor validation rejects absent/ambiguous selection.
- Implemented one-offset, equally spaced SUS sampling; shared normalized weight
  validation with roulette to keep that boundary in one place.
- Integrated one shuffled pool per generation and disjoint parent pairs, with
  exactly two sampled parents per nonelite child. Documented discarded second
  parents when crossover is skipped and checked custom batch lengths.
- Documented the nullable selection field as a pre-1.0 source compatibility
  change and prepared version 0.4.0 without claiming hosted publication.
- Added original eight queens and password examples inspired by GeneticSharp's
  README sample catalogue, plus knapsack for finite constraint penalties.
- Expanded architecture, selection, migration, README and problem walkthroughs;
  linked Baker's 1987 SUS publication and clarified implementation policies.
- Validation: 51 tests passed, including integral/fractional quotas, 1,000-offset
  expected allocation, seed repeatability, zero/invalid/extreme weights, batch
  integration and known example solutions. Analyzer reported no issues; format
  and local Markdown-link checks passed. All seven examples executed.
- Seed-42 outputs: eight queens zero conflicts, password GENETIC, knapsack value
  40 at weight 10 (also checked against all 64 subsets). These small examples do
  not establish convergence for other seeds or larger problems.
- Publication dry-run assembled a 47 KB archive and reached package validation,
  but ended with a socket error reaching pub.dev; no full local dry-run success
  is claimed. Networked Dart CI run 43905166657 passed both Dart 3.3.0 and stable,
  including the package dry-run, analyzer, tests and all examples.
- Crapper/dryer/mutator remain unsupported for Dart as recorded above; no empty
  metric report is treated as evidence.

## 2026-11-16 — Hosted 0.4.0, applied examples and selector comparison

- Observed published genetic_engine 0.4.0 on pub.dev with 160/160 points and
  50/50 static analysis, then updated README installation to ^0.4.0.
- Pinned independent consumer resolution to exactly hosted 0.4.0. Added actual
  SUS execution in native Dart isolates and Flutter compute/widget fixtures;
  retained tournament checks and release web compilation. The shell still lacks
  pub.dev network access, so hosted installation requires networked CI evidence.
- Wrote applied-example tests first and observed missing example/function errors.
  Implemented independent-job scheduling and bounded line-parameter fitting.
  Tests recompute machine loads/lower bounds and residual errors independently.
- Local seed-42 schedule reaches loads [15,15,15], matching the work lower bound;
  fitted slope/intercept are about 2.0222/1.0251 with MSE 0.00162. Documented model
  assumptions and the more direct least-squares alternative for this simple fit.
- Added a reproducible selector experiment: two landscapes, three strategies,
  30 seeds each, identical initial populations, shuffled configuration order,
  six excluded warmups and raw per-seed fitness/evaluation/time records.
- Verified all 180 local target hits, identical per-seed initial fitness across
  selectors, and exact actual evaluation budgets. Saved reports under doc/ with
  the source-v0.4.0-library label after confirming no library diff from that tag.
- Record actual evaluations alongside runtime because target hits stop early;
  tournament and fitness-weight pressure are not calibrated to be equal.
- Local validation: 53 tests, analyzer, format, shell syntax and documentation
  links passed. Dart consumer fixture also ran against local source only; this
  is not claimed as hosted-resolution evidence. Crapper/dryer/mutator remain
  unsupported for Dart; no metric or mutation score is fabricated.
- No library change, version bump or retagging: new examples/docs are on main,
  while the immutable published 0.4.0 archive and tag remain intact.

- Verified networked CI for commit c3c5f4b: source run 43910958932 passed on
  Dart 3.3.0/stable; hosted consumer run 43910958812 passed Dart in 21 seconds
  and Flutter in 1 minute 1 second, with both evidence artifacts present.
  This establishes actual hosted 0.4.0 resolution and SUS execution, independent
  of the source-only fixture check. CI raw benchmark values were not downloaded
  or claimed as inspected; local per-seed results remain separately labeled.


## 2026-11-17 — Incremental evolution and Flutter lab

- Inspected clean main checkout, origin, project instructions, public API and
  steering-engine lab (read-only reference). Shared SDK was left unchanged.
- Red: public consumer test failed because `generations()` did not exist.
  Green: extracted the existing loop into one lazy lifecycle shared with `run()`;
  all 55 core tests passed, including seed replay, lazy evaluation and cancel.
- Kept Flutter and execution scheduling outside core. Created a private-to-pub
  example application (publish_to: none), bounded to 200 candidates/300 generations.
- Added scenario/operator tests and interaction tests for step/pause/resume/cancel/
  restart, invalid seed and 390px large-text layout with labeled/touchable controls.
- Used an isolated Flutter 3.50.0/Dart 3.14.0 SDK copy and isolated writable cache.
  Migrated UI imports to material_ui 1.11.1; SDK-pinned dependencies have no overrides.
- Ran crapper, dryer threshold 0.8 and mutator scan on Dart source: no supported
  source files. These are unsupported checks, not successful quality/mutation scores.
- Added Pages validation/deployment workflow and English scenario guide with five
  exercises; retained Portuguese docs and added a short Portuguese lab guide.
- Detailed browser/build/deployment evidence is maintained in doc/lab/validation.md.
- Visual QA caught a zero-width history plot (vertical lines). Added a layout
  assertion and observed width 0 fail; made the chart fill available width and
  reran widget validation. ExpansionTile also exposed a hidden-ink debug assertion;
  panels now use Material surfaces so interaction feedback remains visible.
- First remote CI exposed cross-package formatting: root Dart formatting ran
  before resolving the Flutter application, so it applied the root language style
  to nested UI files. Scoped core formatting to CLI examples; the lab formats its
  own files after resolving its lockfile. Exempted the application lockfile from
  the root ignore so package dry-run no longer warns about tracked ignored files.
- Remote checks all passed for 615c62a: Dart minimum/stable, hosted consumers,
  Flutter lab formatting/analysis/tests/build and Pages deployment. Opened the
  public lab and verified Step changed generation 0 to 1; saved a real capture.
- Final clean-checkout package dry-run: 0 warnings, 65 KB; no publication.
  Online outdated check confirmed direct lab dependencies current; two transitive
  updates remain incompatible with Flutter's own pins. Added successful run links
  and evidence in a documentation-only follow-up commit.


## 2026-11-17 — English/Portuguese lab interface

- Confirmed clean checkout and origin/main before editing. Kept all core library,
  core tests and lab optimization model unchanged; no dependencies were added.
- Red: a widget test could not find the missing English language selector.
  Added typed bilingual application copy and locale-aware Material delegates;
  presentation state now uses enum statuses and a validation flag, so language
  does not control execution logic. The existing timer/iterator survives switches.
- All eight Flutter tests passed, including paused-run language switching,
  Portuguese scenario/error copy, return to English and 390px / 150% text with
  labeled/touch-target accessibility checks. The amplified-text test first caught
  a 25px selector overflow; expanded dropdown content resolved it.
- Flutter analyzer passed. crapper, dryer (0.8) and mutator scan still have no Dart
  support; empty reports are not successful quality metrics.
- Browser/build/deployment results are recorded in doc/lab/validation.md.
- Remote validation for 82d1e13 passed: core minimum/stable, hosted consumers and
  all eight Flutter tests, analysis, release build and Pages deploy. Confirmed
  Portuguese in the public lab after refreshing an older cached bundle; switching
  from English retained generation 1 (best 9.000 / mean 13.580). Saved the published
  screenshot and linked the successful workflows in the validation record.
