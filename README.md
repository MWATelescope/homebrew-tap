# homebrew-tap

A homebrew tap to facilitate macOS development on MWATelescope repositories by bottling dependencies.

## Testing individual formulas

```bash
brew uninstall $formula
brew install --verbose --debug --build-from-source Formula/$formula.rb --include-test
brew test $formula
```
