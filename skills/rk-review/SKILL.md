---
name: rk-review
description: "Senior-engineer review of the current branch against its target branch (auto-detected from the PR or branch history; override with an argument). Usage: /rk-review [target-branch]"
disable-model-invocation: true
argument-hint: "[target-branch]"
license: MIT
metadata:
  version: "1.1.0"
---

Review this PR as a senior engineer who is already familiar with the repository.

First, understand the existing codebase and its conventions before evaluating the PR. Inspect the relevant surrounding code, similar implementations, call flows, abstractions, tests, and patterns used elsewhere in the repo.

Read the PR description, commit messages, and any linked issue to understand the intended behavior. If the intent is unclear, say so instead of guessing.

Also read the PR's discussion: review comments, inline threads, and replies, using the tool from *Where the PR lives*. Posts containing `<!-- rk-review -->` are earlier runs of this review; check which of their findings the code now fixes. Note which concerns are already raised, resolved, or still open, so you don't repeat settled points and can verify that requested changes were actually made. If no PR exists or its discussion can't be accessed, say so and continue with the description and commits.

Then review the changes in this branch.

<!-- BEGIN SHARED: platform -->
## Where the PR lives

Find the hosting platform from the remote URL (`git remote -v`): check the remote the current branch tracks first, then `origin`, then `upstream`. Use that platform's tool for everything PR-related:

| Remote host | Tool |
| --- | --- |
| `github.com`, GitHub Enterprise | `gh` (for Enterprise, set `GH_HOST=<host>`) |
| `gitlab.com`, self-hosted GitLab | `glab` |
| `dev.azure.com`, `*.visualstudio.com` | `az repos` (Azure CLI with the `azure-devops` extension); comment threads through `az devops invoke` |
| `bitbucket.org` | the REST API through `curl`, with a token the user provides |

If the host is an SSH alias (e.g. `git@github-work:org/repo.git`), resolve it from `~/.ssh/config`. If the host is still unrecognised, ask the user.

Before the first PR call, check that the tool is installed and authenticated (`gh auth status`, `glab auth status`, `az account show`). If it isn't, give the user the install or login command and continue with what git alone provides.

The PR can live on a different remote than the one you push to: a fork's PR lives on the parent repo. Find it from the current branch: `gh pr view` (resolves forks to the parent repo, or to `gh repo set-default`), `glab mr view`, `az repos pr list --source-branch <branch>`. If no PR is found, or several remotes could host it, ask the user.
<!-- END SHARED: platform -->

## Target branch

If `$ARGUMENTS` is non-empty, use it as the target branch.

Otherwise, determine the target yourself:

1. If a PR/MR exists for the current branch, use its base (target) branch.
2. If there is no PR, infer the branch this one was cut from. For each likely candidate that exists on the remote (e.g. `dev`, `develop`, `main`, `master`, release branches), run `git rev-list --count <remote>/<candidate>..HEAD` and pick the candidate with the smallest count (the fewest commits on this branch that aren't on the candidate).
3. If still ambiguous, ask the user instead of guessing.

State which target branch you chose and how you determined it.

Run `git fetch <remote> <target>` first, then review the diff between this branch and its merge-base with the up-to-date remote target: `git diff <remote>/<target>...HEAD`. Don't diff against the local `<target>` branch, since it may be stale.

`<remote>` is the remote that hosts the PR, or will host it (see *Where the PR lives*). In a fork that's usually `upstream`, not `origin`.

## Focus areas

### 1. Consistency with the existing codebase

* Does the implementation follow the architecture, patterns, conventions, and coding style already established in the repository?
* Is the code using existing abstractions, utilities, helpers, or patterns where appropriate?
* Does it introduce a new pattern when an existing one should have been used?
* Does the implementation fit naturally into the surrounding code, or does it feel inconsistent with how the rest of the system works?

### 2. Logic and correctness

Trace the code through its actual flow and determine whether the implementation does what it is supposed to do.

Look specifically for:

* Incorrect logic or assumptions
* Broken control flow
* Incorrect state transitions
* Edge cases that are not handled
* Null/undefined/empty/error cases
* Incorrect error handling
* Race conditions or async issues
* Data consistency problems
* Unexpected side effects
* Cases where the new code could produce incorrect results
* Regressions to existing functionality
* Security issues: injection, missing input validation, authz bypass, secrets in code or logs
* Performance problems introduced by the change: N+1 queries, unbounded loops or loads, missing pagination, unnecessary work on hot paths

Don't just judge whether the code "looks right" — reason through how it behaves at runtime.

### 3. Integration with the rest of the system

Check how the changed code interacts with existing code.

Consider:

* Callers and consumers of the changed code
* APIs and contracts
* Data models and types
* Persistence/database behavior
* Events, queues, or async flows
* Authentication/authorization where relevant
* Error propagation
* Backwards compatibility
* Existing behavior that could be changed unintentionally

### 4. Tests

Review existing tests and determine whether the PR has sufficient coverage for the behavior it changes.

Identify:

* Missing important test cases
* Incorrect or misleading tests
* Edge cases that should be tested
* Important regression scenarios

Only call out missing tests when the missing coverage represents a meaningful risk. Don't request tests purely for the sake of increasing coverage.

### 5. Code quality

Evaluate whether the implementation is unnecessarily complex, duplicated, difficult to understand, or poorly structured.

Look for:

* Over-engineering
* Unnecessary abstractions
* Duplication
* Poor naming
* Excessive coupling
* Hard-to-maintain logic
* Dead or redundant code

Do not report subjective style preferences as issues unless they conflict with an established pattern in this repository.

### 6. Documentation and AI/agent files

Check whether the change requires documentation updates, and whether existing docs are still accurate.

**Human-facing documentation**

* README, setup, or usage docs affected by the change
* Docstrings/comments that are now incorrect, misleading, or missing on non-obvious logic
* API docs or schemas when endpoints, contracts, or types change
* New config options, env vars, feature flags, or CLI arguments that aren't documented
* CHANGELOG or migration notes for breaking or user-visible changes

**AI/agent instruction files**

Look for files such as `CLAUDE.md`, `AGENTS.md`, `.cursorrules` / `.cursor/rules/`, `.github/copilot-instructions.md`, `.claude/` (skills, commands, agents, settings, hooks), MCP configs, and any prompt or rules files the repo keeps.

* Do they still describe the codebase accurately after this change? Watch for renamed/moved files, changed commands (build, test, lint, run), new or removed modules, changed conventions, or deprecated patterns that the files still recommend
* Should the change be reflected in them? For example, a new architectural pattern, a new "always/never do X" rule, a new required workflow step, or a gotcha that an agent would likely get wrong
* If the PR modifies these files directly:
  * Are the instructions correct, specific, and consistent with the actual code and with each other (e.g. `CLAUDE.md` vs `AGENTS.md` not contradicting)?
  * Do referenced paths, scripts, and commands actually exist?
  * Are they concise and actionable, not vague, duplicated, or bloated with information the code already makes obvious?
  * Do settings, hooks, or permission changes grant broader access than needed (e.g. overly permissive allowlists, hooks running untrusted commands)?
  * Do they contain secrets, internal URLs, or personal data that shouldn't be committed?

Wrong commands, paths, or rules in agent instruction files can be Medium or higher, since agents follow them literally.

Follow the repo's existing documentation conventions. Don't ask for docs, or for new agent files, where the repo doesn't normally have them. Only flag gaps or inaccuracies that would mislead or block a future developer, user, or agent.

## Review standards

Be critical, but only report issues that are actually actionable.

Prioritize:

1. Bugs and incorrect behavior
2. Regressions
3. Security or data-integrity issues
4. Significant design/integration problems
5. Important maintainability issues
6. Stale or incorrect documentation / agent instructions
7. Minor consistency issues

Do not praise the code unnecessarily and do not repeat things that are already correct.

Number the findings `#1`, `#2`, … in severity order, Critical first. For every finding, provide:

**#N · Severity:** Critical / High / Medium / Low
**Location:** `path/to/file:line` or `path/to/file:start-end`, as line numbers in the reviewed (`HEAD`) version of the file; `General` when the finding isn't tied to a line
**Issue:** What is wrong
**Why:** Why this matters and under what conditions it can occur
**Recommendation:** A concrete way to fix it

When possible, explain the issue using the existing repository's patterns or code as evidence rather than generic best practices.

## Final assessment

Finish with:

**Verdict:** Approve / Approve with minor changes / Request changes
**Confidence:** High / Medium / Low

**Summary:**

* Is the implementation consistent with the repository?
* Is the logic correct?
* Are there meaningful regression risks?
* Are docs and agent instruction files still accurate?
* What are the 1–3 most important things that should be addressed before merging?

If you find no meaningful issues, explicitly say so. Do not invent problems just to produce findings.
