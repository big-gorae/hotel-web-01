# Repository Agent Instructions

## Meaning of “Apply”

- When the user asks to “apply,” “reflect,” or “반영” a change, completion includes implementing it locally, running relevant validation, committing it, and pushing the commit to the configured remote repository.
- Treat a request as local-only only when the user explicitly says not to commit or push.
- Pushing only to a feature branch is not complete. Either update the remote default branch when direct pushes are explicitly authorized and safe, or create a pull request that targets the remote default branch.
- Do not report a change as remotely applied until the intended commit is on the remote default branch or a pull request targeting that branch has been created.
- Clearly distinguish between a pushed feature branch, a merged default branch, and a deployed build.

## Conflict and Intent Safety

- Before committing or pushing, fetch the remote and inspect the worktree, current branch, upstream branch, and outgoing diff.
- Preserve unrelated or concurrent user changes. Do not overwrite, reset, discard, amend, or silently include them.
- Stage only the files that belong to the requested change unless the user explicitly confirms a broader scope.
- Integrate remote updates only when the merge or rebase is mechanically safe and does not alter either side’s intent.
- Never force-push unless the user explicitly authorizes it.
- If a conflict or overlapping intent cannot be resolved confidently, stop before committing or pushing, identify the exact files and competing changes, and ask the user for direction.
- After pushing, verify the remote commit SHA and report the branch, commit, validation results, and whether the change is merged into the default branch.
