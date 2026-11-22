---
name: rk-address-review
description: "Address review feedback on your own PR: triage every open comment, apply the valid fixes as local commits, and draft a reply per thread. Never posts or pushes. Usage: /rk-address-review [PR number or URL]"
disable-model-invocation: true
argument-hint: "[PR number or URL]"
license: MIT
metadata:
  version: "1.1.0"
---

You are the author of this PR, addressing its review feedback. You own the code and judge each comment on its merits: a reviewer, human or agent, can be wrong, and a reasoned pushback serves the PR better than a blind fix.

The output is a **draft**: local commits plus reply texts the user posts themselves. Everything stays on this machine. Leave posting, resolving threads, and pushing to the user.

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

## 1. Locate the PR and its feedback

If `$ARGUMENTS` is non-empty, it names the PR (number or URL). Otherwise use the PR for the current branch, found as described in *Where the PR lives*.

Collect every **open thread**: unresolved review threads, inline comments, and top-level review or conversation comments that ask for something. Skip threads already resolved or answered by the author, unless the reviewer replied again after that.

Findings posted by `rk-review` contain the marker `<!-- rk-review -->` and come in two forms:

* **GitHub**: one review whose line comments are each a normal thread, plus a review body that may hold more numbered findings.
* **Other platforms**: one comment listing numbered findings (`#1`, `#2`, …).

Treat each numbered finding inside a single comment or review body as its own thread, keyed by its number.

If there is no PR, or it has no open feedback, ask the user to paste the review (e.g. `rk-review` output) and use that as the thread list.

Done when: you have a numbered list of open threads, each with author, location (file:line or general), and the request in one line.

## 2. Understand before judging

Read the PR's intent (description, commits, linked issue) and its diff against the target branch (`git fetch` first, then `git diff origin/<target>...HEAD`). For each thread, read the code it points at and enough surrounding code (callers, tests, similar implementations) to know whether the reviewer's claim holds at runtime.

Done when: every thread has a verdict you could defend with evidence from the code.

## 3. Triage and present the plan

Classify each thread:

* **Fix**: the claim holds; say what you will change.
* **Already done**: the code already handles it; point to where (file:line or commit).
* **Push back**: the claim is wrong or the change would make things worse; give the concrete reason, citing code or repo conventions.
* **Ask**: the request is ambiguous or needs a decision only the reviewer or user can make; write the question.

Weigh the reviewer's stated severity and confidence, but verify independently: a High finding can be wrong, a Low one can hide a real bug.

Show the plan as a table (thread #, location, verdict, one-line action) and **stop for the user's approval**. Apply their edits to the plan before continuing.

Done when: the user has approved the plan.

## 4. Apply the fixes

For each **Fix** thread, make the change in the style of the surrounding code, reusing existing helpers and patterns. Keep each change scoped to its thread; note anything else you spot for the summary instead of fixing it.

Commit locally, one commit per thread (or per tightly related group), following the repo's commit message conventions. Record each commit's short SHA against its thread.

Run the repo's tests, linter, and type checker for the affected areas (find the commands in the repo's scripts, config, or docs). Fix failures your changes caused.

Done when: every Fix thread has a commit, and the checks pass, or the remaining failures are shown to predate your changes.

## 5. Draft the replies

Write one reply per thread, ready to paste. Where several findings share one comment or review body, write one combined reply to it that answers each finding by number (`#1 Fixed in abc1234.`, `#2 …`), so the PR gets one reply instead of many.

Per verdict:

* **Fix**: what changed and the commit SHA, e.g. "Good catch, now guards against an empty list: `abc1234`."
* **Already done**: where it is handled.
* **Push back**: the reason, briefly and respectfully, with the evidence.
* **Ask**: the question.

Keep replies short and specific, in the tone of the existing PR discussion.

## Final summary

Finish with:

* The commits created (SHA and subject), unpushed
* Each thread with its verdict and drafted reply, grouped by thread, with location so the user can find it on the PR
* Check results (tests, lint, types)
* Anything noticed outside the review's scope
* Next steps for the user: review the commits, push, post the replies, resolve threads
