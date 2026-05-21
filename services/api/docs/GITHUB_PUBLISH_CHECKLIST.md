# GitHub Publish Checklist (Private Repo)

Use this checklist before every push to ensure GitHub receives only files required
for server updates.

## 1) Validate working tree

- `git status --short`
- Make sure there are no accidental local files in "Changes not staged for commit"
  or "Untracked files".

## 2) Confirm ignore rules are active

Common local-only files must be ignored:

- `.env`, `.env.*` (except `.env.example`)
- `node_modules/`
- logs / temp files
- local DB files (`*.db`, `*.sqlite*`)
- private keys and certs (`*.pem`, `*.key`, `*.p12`, ...)

Quick check:

- `git check-ignore -v .env node_modules .DS_Store`

## 3) Secret scan before push

Run a quick scan on tracked source/docs:

- `rg -n "(api[_-]?key|secret|token|password|private[_-]?key)" src docs README.md`

Then manually verify matches are not real credentials.

## 4) Verify tracked files snapshot

- `git ls-files`

Check that only deploy-relevant files are tracked:

- source (`src/`)
- tests (`test/`) if you keep them in private repo
- dependency manifests (`package.json`, `package-lock.json`)
- docs needed by the team (`README.md`, `docs/*`)

## 5) Final pre-push gate

- `npm test`
- `git diff --staged`
- confirm commit contains only intended server-update changes

## 6) Recommended operational safety

- If any credential has ever been exposed outside local machine, rotate it.
- Keep production secrets only in server env / secret manager, never in git.
- Prefer branch + PR flow even for private repos.
