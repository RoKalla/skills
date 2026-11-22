# Contributing

How this repo is laid out, which files are generated, and how to add a skill or cut a release.

## Layout

```
skills/<name>/SKILL.md        one folder per skill; each is self-contained
shared/platform.md            "Where the PR lives" section, copied into several skills
templates/rk-full-review.md   template for the generated rk-full-review skill
scripts/build.py              the generator
.claude-plugin/marketplace.json   Claude Code plugin manifest
.github/workflows/check.yml    CI: checks generated files and versions (required on PRs)
.github/workflows/release.yml  CI: checks and publishes releases from tags
```

Skill folders must stay self-contained: `npx skills add` and manual installs copy each folder on its own, so a skill can't reference files outside its folder. Shared text is copied into each skill by the generator instead.

## Generated files

| Generated | From |
| --- | --- |
| Text between `<!-- BEGIN SHARED: platform -->` and `<!-- END SHARED: platform -->` in any skill | `shared/platform.md` |
| `skills/rk-full-review/SKILL.md` (whole file) | `templates/rk-full-review.md` + the bodies of `rk-review` and `rk-post-findings` |

Edit the sources, never the generated text: the next build overwrites it.

Run `make build` after changing any of:

- `shared/platform.md`
- `skills/rk-review/SKILL.md`
- `skills/rk-post-findings/SKILL.md`
- `templates/rk-full-review.md`

Other edits (README, `ask-rk`, the non-generated parts of `rk-address-review`, …) need no build. Running it anyway is harmless.

If you forget, CI catches it: the Check workflow runs `make check` on every pull request, and the PR can't merge until the branch is rebuilt.

## Branch protection

`main` is protected by a ruleset: every change goes through a pull request, the Check workflow's `check` job must pass with the branch up to date with `main`, and force pushes and deleting `main` are blocked. Nothing pushes to `main` directly, not even CI.

| Command | What it does |
| --- | --- |
| `make build` | Regenerates the files above. |
| `make check` | Writes nothing; fails if a generated file is out of date or the versions differ. |
| `make version V=X.Y.Z` | Sets the version everywhere, then builds. |
| `make help` | Lists the targets. |

### How the generator builds `rk-full-review`

For each included skill it drops the frontmatter and the shared blocks, then pushes every heading down one level so the skill nests under its `## Part N` heading. The shared platform section is included once, at the top. The frontmatter (name, description, version) comes from the template.

To use the shared section in another skill, add the empty markers where it should go and run `make build`:

```
<!-- BEGIN SHARED: platform -->
<!-- END SHARED: platform -->
```

A new shared section works the same way: create `shared/<name>.md` and use `<!-- BEGIN SHARED: <name> -->` markers.

## Adding a skill

1. Create `skills/<name>/SKILL.md` with frontmatter:

   ```yaml
   ---
   name: <name>
   description: "<one line>. Usage: /<name> [args]"
   disable-model-invocation: true
   argument-hint: "[args]"
   license: MIT
   metadata:
     version: "<current release>"
   ---
   ```

   All rk skills are user-invoked (`disable-model-invocation: true`), so a skill can't call another rk skill. Shared behaviour goes through the generator.
2. Add `./skills/<name>` to `skills` in `.claude-plugin/marketplace.json`.
3. Add a row to the Skills table and a Usage section in `README.md`.
4. Add the skill to `skills/ask-rk/SKILL.md` so the router knows about it.
5. Run `make build` if the skill uses shared sections, then `make check`.

Quote frontmatter strings that contain `:` or start with `[`; unquoted they break the YAML (the reason for v1.0.1).

## Versioning and releases

Versions follow [semver](https://semver.org) and apply to the whole repo: a release sets the same version everywhere.

- **Patch** (`1.1.1`): fixes and wording changes.
- **Minor** (`1.2.0`): new skills or new behaviour.
- **Major** (`2.0.0`): changes that break how existing skills are invoked.

The version lives in every `skills/*/SKILL.md` (`metadata.version`), `templates/rk-full-review.md`, `.claude-plugin/marketplace.json`, and the pin example in `README.md`. `make version` sets them all; `make check` fails if they differ. These places are listed in `VERSIONED` in `scripts/build.py`; if you add a new one (e.g. a version badge), add it there too, or the check won't see it.

To release:

1. On a branch: `make version V=X.Y.Z`, then `make check`. Commit, push, and open a pull request.
2. Merge the pull request once the `check` job passes.
3. Update your local `main`: `git switch main && git pull`. Tag this commit, not the branch's: a squash or rebase merge gives `main` a different commit.
4. Write the release notes to a file (`notes.md`, outside the repo or uncommitted).
5. Create an annotated tag whose message is the notes: `git tag -a vX.Y.Z --cleanup=verbatim -F notes.md`. Without `--cleanup=verbatim`, git strips every line starting with `#` as a comment, so Markdown headings vanish from the notes.
6. Push only the tag: `git push origin vX.Y.Z`.

The Release workflow then checks that the tag is annotated, named `vX.Y.Z`, on `main`, that the generated files are up to date, and that every version equals `X.Y.Z`. Only if all pass does it create the GitHub release, using the tag message as the notes. Don't run `gh release create` yourself; that would skip the checks.

If the workflow fails, no release exists. Delete the tag, fix the problem, and tag again:

```bash
git push --delete origin vX.Y.Z
git tag -d vX.Y.Z
```
