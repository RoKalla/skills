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
