---
name: vtk-gitlab-review
description: Guide authoring and reviewing changes on VTK's GitLab (gitlab.kitware.com/vtk/vtk) - documented process rules, mined reviewer/CI history, and semantic retrieval over ~17k past merge topics. Use when the user is preparing a VTK merge request, writing a VTK commit, asking who should review a VTK change, or reviewing someone else's VTK merge request.
---

# VTK GitLab review workflow

Backing data and tools live in
`/home/sankhesh/Projects/dgx-spark_lite-llm_llama-swap_vllm_llama-cpp_ollama/vtk-review-rag/`:

- `review_index.sqlite` - ~17.7k "Merge topic" commits mined from local VTK git
  history (`mine_trailers.py`): topic name, MR id, date, CI outcome, reviewers,
  files/modules touched. Ground truth, always available offline.
- `stats.py` - **deterministic SQL lookups**. Use this for any factual
  question ("who reviews module X", "what's the CI rejection rate here") -
  it never hallucinates.
- `ask.py` - semantic retrieval + local LLM (llama-embed + Qwen2.5-Coder-32B
  via the DGX Spark stack) over the mined topics. For the top 5 matches it
  also pulls real review comments from `mr_notes` (Phase 2, below), so
  answers quote actual reviewer feedback, not just inferred-from-commit-subject
  guesses.
- `mr_notes` / `mr_meta` (Phase 2, via `fetch_mr_threads.py`): full review
  discussion threads pulled from the GitLab API - 308k notes across 11.6k MRs
  as of 2026-09-14 (191k of them real comments, not GitLab's auto-generated
  activity log entries). Needs a live token in `~/Projects/dotfiles/gitlab_token`
  to refresh/extend; re-check `SELECT COUNT(*) FROM mr_notes` if it's been a
  while, since `refresh.sh` only backfills incrementally when the token is valid.

The authoritative process reference is the VTK source tree itself:
`Documentation/docs/developers_guide/git/develop.md` (in the local VTK clone,
default path `/home/sankhesh/Projects/vtk`). Prefer re-reading it over relying
on this file's summary if anything seems out of date - it's the source of
truth and this skill just repeats the load-bearing parts.

## Core process facts (from develop.md, verified against the local VTK clone)

**Commit style**: subject line imperative, capitalized, ≤60 chars, blank line,
body wrapped at 80 cols explaining what/why. VTK convention (seen throughout
mined history) also prefixes the subject with the class/module touched, e.g.
`vtkOpenGLGlyph3DMapper: Fix wide lines rendering under GLES 3.0`.

**Review voting** (as MR comments, GitLab-Flavored Markdown):
- Leading line `+1`/`:+1:` -> `Acked-by:` ("I like it but defer to others")
- Leading line `+2` -> `Reviewed-by:` ("ready for integration") - **at least
  one `+2` is required before `Do: merge` is allowed**
- Leading line `+3` -> `Tested-by:` ("I tested it and it works")
- Leading line `-1` or trailing `Rejected-by: me` -> not ready
- By convention, don't request merge while an unresolved `-1`/`Rejected-by`
  stands unsuperseded by a `+1`/`Acked-by` from the same person.

**Bot commands** (posted as MR comments):
- `Do: check` - re-run kwrobot's automatic topic checks (commit message
  format, etc.) after a force-push.
- `Do: test [--named <regex>] [--stage <stage>]` - trigger CI jobs awaiting
  manual start. Use `--stage quick` to run just the fast jobs first.
- `Do: merge [-t <topic>]` - merge once approved and CI is green (authorized
  developers only). CI failures believed unrelated can be bypassed via
  `@utils/maintainers/bypass-vtk-vtk`.
- `Do: stage` exists for maintainer staging workflows (topic-rename applies to
  it too) but isn't fully spelled out in the public dev guide - don't assert
  details about it beyond what's there; ask an infra maintainer if it matters.

**CI results**: both GitLab CI *and* CDash must be checked before merging.
Configure/build warnings and errors block merge unconditionally. Test
failures should be fixed unless clearly a known flaky test (check the test's
CDash history across other MRs/master).

**Module ownership** (from develop.md; @-mention the relevant person(s) -
"a merge request without a developer tagged has very low chance of being
merged in a reasonable timeframe"):
- `@mwestphal`: Qt, filters, data model, widgets, parallel, anything else
- `@charles.gueunet`: filters, data model, SMP, events, pipeline, computational geometry, distributed algorithms
- `@kmorel`: general VTK expertise, Viskores accelerators
- `@will.schroeder`: algorithms, computational geometry, filters, SPH, SMP, widgets, point cloud, spatial locators
- `@sebastien.jourdain`: web, WebAssembly, Python, Java
- `@sankhesh`: volume rendering, Qt, OpenGL, widgets, vtkImageData, DICOM, VR, Raytracing, webgpu, QtQuick, QtQml, OpenXR
- `@ben.boeckel`: CMake, module system, third-parties
- `@cory.quammen`: readers, filters, data modeling, general usage, documentation
- `@seanm`: macOS, Cocoa, cppcheck, clang
- `@spiros.tsalikis`: filters, SMP, computational geometry
- `@louis.gombert`: VTKHDF, HyperTreeGrid, Catalyst
- `@jaswant.panchumarti`: Rendering, WASM, WebGPU, emscripten
- `@dcthomp`: CellGrid

This list can drift - `grep -A20 "^Here is a list of developers"
Documentation/docs/developers_guide/git/develop.md` in the VTK clone to
re-check it's current, and cross-check with `stats.py --module <module>` for
who has *actually* been reviewing that area lately (documented expertise and
recent practice sometimes diverge).

## Workflow: authoring a change

1. Identify the modules/files the topic touches.
2. For each module, run:
   ```
   python3 vtk-review-rag/stats.py --module <Kit/Module>
   ```
   to see who has actually reviewed there recently and the CI rejection rate.
   Cross-check against the documented ownership list above - @-mention
   whoever is the better match for this specific change.
3. For qualitative guidance (what tends to go wrong, what similar past topics
   needed), run:
   ```
   ../rag/.venv/bin/python vtk-review-rag/ask.py "<one-line description of the change>"
   ```
4. Before opening/updating the MR, check the mined rejection-rate table for
   this module - if it's high, budget time for CI churn and consider running
   `Do: test -s quick` first.
5. Write the commit message and MR title/description per the style rules
   above. If the module has a high rejection rate tied to config files
   (`.gitlab-ci.yml`, `.gitlab/*.yml` show the highest rejection rates
   project-wide), double check CI config changes especially carefully.
6. After pushing, `Do: test` to trigger CI; `Do: check` if you force-pushed
   and kwrobot's check seems stale.

## Workflow: reviewing someone else's MR

1. Pull the touched files/modules from the MR diff.
2. `stats.py --module <module>` for each to calibrate: is this an area with
   a history of CI churn or contentious review? Who else usually weighs in
   here (bring them in with `@username` if you're not confident alone)?
3. `ask.py "<summary of the change>"` to see how similar past topics were
   received - cite the retrieved `!MR` numbers you found relevant so the
   author can look them up too.
4. `ask.py`'s output already quotes real comments from similar past MRs
   (via `mr_notes`) - use that to calibrate tone/thoroughness expected here
   rather than inventing a review style. Read the cited `!MR` directly on
   GitLab if you want the full thread.
5. Use the standard voting convention when leaving your review (`+1`/`+2`/
   `+3` leading line, or `Reviewed-by:`/`Acked-by:` trailing line) so kwrobot
   records it correctly - see "Core process facts" above.
6. Don't approve (`+2`) past an unresolved `-1` from someone else without
   discussion - that violates the merge convention.

## Known limitations

- CI status mined from commit trailers is `unknown` for topics that never
  got a bot-reported CI trailer (common before ~2018/Gerrit-era, and for some
  merges that bypass full CI) - "unknown" is not the same as "passed".
- Reviewer names come from Git identity, not GitLab usernames; cross-check
  the `@username` form in the ownership list above before tagging.
- `mr_notes`/`mr_meta` (Phase 2) is populated as of 2026-09-14 but is a
  snapshot - it won't include newer MRs/comments until `refresh.sh` runs
  again with a valid token. 2 of 11,592 MRs failed to fetch (likely deleted
  fork branches) and are permanently absent, not a bug to chase.
