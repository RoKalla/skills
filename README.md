# skills

Reusable [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for Claude Code and other agents that support the `SKILL.md` format.

## Skills

| Skill | Description |
| --- | --- |
| [`ask-rk`](skills/ask-rk/SKILL.md) | Router: tells you which rk skill fits your situation. |
| [`rk-review`](skills/rk-review/SKILL.md) | Senior-engineer review of the current branch against its target branch. It auto-detects the target from the PR or branch history and reads the PR discussion so it doesn't repeat settled points. Findings stay in the conversation. |
| [`rk-post-findings`](skills/rk-post-findings/SKILL.md) | Posts the findings from `rk-review` to the PR in one batch: one review with a resolvable thread per finding on GitHub, one comment elsewhere. Draft first. |
| [`rk-full-review`](skills/rk-full-review/SKILL.md) | `rk-review` followed by `rk-post-findings` in one run. Generated from those two, so it never drifts. |
| [`rk-address-review`](skills/rk-address-review/SKILL.md) | For the PR author: triages open review feedback (from `rk-review`, humans or other bots), applies the valid fixes as local commits and drafts replies. It never posts or pushes. |

## Install

### Option 1: `skills` CLI

```bash
npx skills add RoKalla/skills
```

### Option 2: Claude Code plugin marketplace

```
/plugin marketplace add RoKalla/skills
/plugin install rk-skills@rk-skills
```

### Option 3: Manual

Copy a skill folder into your skills directory:

```bash
git clone https://github.com/RoKalla/skills.git
cp -r skills/skills/rk-review ~/.claude/skills/        # all projects
# or
cp -r skills/skills/rk-review <your-repo>/.claude/skills/   # one project
```

Each skill folder is self-contained, so you can copy any subset.

## Usage

Not sure which skill to use? Run `/ask-rk <your situation>`.

The skills find the PR's platform from the git remote and use its CLI: `gh` (GitHub), `glab` (GitLab), `az repos` (Azure DevOps), or the REST API (Bitbucket). There's no setup step and no config file in your repo.

### Reviewing a PR: `rk-review`, `rk-post-findings`, `rk-full-review`

Run inside a git repo on the branch you want reviewed:

```
/rk-review              # review; findings stay in the conversation
/rk-post-findings       # then post them to the PR
# or
/rk-full-review         # both in one run
```

Both `rk-review` and `rk-full-review` take an optional target branch (`/rk-review main`); without one, they auto-detect it.

The review:

- learns the surrounding codebase and its conventions first
- reads the PR description, commits, linked issues and the PR's review discussion
- diffs against the merge-base with the up-to-date remote target branch
- reports numbered findings (`#1`, `#2`, …) with severity, location and a recommendation, then a verdict

Posting the findings:

- **GitHub**: one review (one notification) with a line comment, and so a resolvable thread, per finding. Findings outside the diff go in the review body. It's posted as a comment, so it never approves or blocks the PR.
- **Other platforms**: one comment with a numbered checklist of findings.
- Always shows the draft and posts only after you approve.
- Re-runs skip findings that are already posted and still open.

### Addressing feedback: `rk-address-review`

Run on your PR branch after it has received review feedback:

```
/rk-address-review          # PR for the current branch
/rk-address-review 123      # a specific PR (number or URL)
```

It:

- collects every open review thread (or uses a review you paste, if nothing is posted on the PR)
- checks each comment against the code and sorts it into fix / already done / push back / ask
- shows you that plan and waits for your approval
- applies the approved fixes as local commits (one per thread) and runs the repo's checks
- drafts replies citing commit SHAs: one per thread, or one combined reply for findings that came in a single comment

It's draft only: it never posts comments, resolves threads or pushes.

All skills set `disable-model-invocation: true`, so they only run when you call them explicitly.

## Development

`rk-full-review` and the shared "Where the PR lives" section are generated. After editing their sources, run `make build`; on `main`, CI regenerates them automatically if you forget. Releases are published by CI from annotated tags, after checking that everything is in sync and every version matches the tag. See [CONTRIBUTING.md](CONTRIBUTING.md) for which files are generated, how to add a skill, and how to cut a release.

## Versioning

Releases use [semantic versioning](https://semver.org) and are tagged in git (`v1.0.0`, ...). The version is recorded in each skill's `SKILL.md` frontmatter (`metadata.version`), so it travels with the skill to any agent.

Installs track the latest commit on `main` by default. To pin a release, check out a tag:

```bash
git clone --branch v1.1.1 https://github.com/RoKalla/skills.git
```

## Acknowledgements

Inspired by [Matt Pocock's skills](https://github.com/mattpocock/skills).

## License

[MIT](LICENSE)
