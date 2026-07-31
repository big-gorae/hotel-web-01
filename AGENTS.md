# Repository Agent Instructions

## Meaning of “Apply”

- When the user asks to “apply,” “reflect,” or “반영” a change, completion includes implementing it locally, running relevant validation, committing it, and pushing the commit to the configured remote repository.
- Treat a request as local-only only when the user explicitly says not to commit or push.
- The user has explicitly authorized direct pushes to `main` without a separate approval request. Use direct `main` pushes as the default publishing path unless the user asks for a feature branch or pull request.
- Pushing only to a feature branch is not complete. Do not report a change as remotely applied until the intended commit is present on the remote `main` branch.
- Clearly distinguish between a pushed feature branch, a merged default branch, and a deployed build.

## Standing Direct-Main Authorization

- The user has granted standing authorization to push directly to the remote default `main` branch without requesting approval for each push.
- Before every direct push to `main`, fetch the remote and pull the latest remote `main` into the local integration state.
- Inspect the latest incoming `main` commits and the outgoing commits and diff before pushing. Integrate them so that the intent of both the latest `main` changes and the outgoing changes is preserved.
- Use only a mechanically safe fast-forward, merge, or rebase. If changes overlap and both intents cannot be preserved confidently, stop before pushing and ask the user for direction.
- Never overwrite remote history or force-push `main` under this standing authorization.

## Conflict and Intent Safety

- Before committing, fetch the remote and inspect the worktree, current branch, upstream branch, the latest remote `main` commits, and the intended outgoing diff.
- Immediately before every direct push, pull the latest remote `main` into the local `main` branch. Integrate any newly arrived commits before pushing; never push from a stale `main`.
- Inspect the intent of both the newly arrived `main` commits and the commits being pushed. Merge, rebase, or otherwise integrate them only when the resulting history and content preserve both sides' intent.
- Preserve unrelated or concurrent user changes. Do not overwrite, reset, discard, amend, or silently include them.
- Stage only the files that belong to the requested change unless the user explicitly confirms a broader scope.
- Integrate remote updates only when the merge or rebase is mechanically safe and does not alter either side’s intent.
- Never force-push unless the user explicitly authorizes it.
- If a conflict or overlapping intent cannot be resolved confidently, stop before committing or pushing, identify the exact files and competing changes, and ask the user for direction.
- After pushing, verify the remote commit SHA and report the branch, commit, validation results, and whether the change is merged into the default branch.
