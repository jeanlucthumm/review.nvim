# review.nvim

## README.md

@README.md

## Notes

- This is a fork of [georgeguimaraes/review.nvim](https://github.com/georgeguimaraes/review.nvim).
- When adding new features, update the "What this fork adds" section in the readme.
  Keep updates short so that users can immediately see the value of this fork over the original.

## Fork maintenance

- This clone is jj-colocated. Use jj, not git.
- Remotes: `origin` is the fork (jeanlucthumm/review.nvim), `upstream` is
  georgeguimaraes/review.nvim.
- lazy.nvim loads the GitHub fork, not this checkout: push to origin `main`, then
  `nvim --headless "+Lazy! update review.nvim" +qa`.
- Tests: `make test` (unit) and `make test-e2e` (real codediff in a child nvim;
  delete a reference screenshot under tests/e2e/screenshots to regenerate it).
- To sync with upstream:
  1. `jj git fetch --remote upstream`
  2. Check for news: `jj log -r 'main@upstream ~ ::main'`
  3. Rebase fork work: `jj rebase -b main -d main@upstream --ignore-immutable`
     (main is pushed, hence immutable), resolve conflicts, run both test suites,
     move `main` (`jj bookmark set main -r <rebased>`) and push.
  Sync often: a 50-commit gap (2026-11) conflicted on every fork commit and had
  to be re-ported by hand.
