# homebrew-tap

A homebrew tap to facilitate macOS development on MWATelescope repositories by bottling dependencies.

## local development

don't directly clone this. Use `brew edit mwatelescope/tap` then `cd $(brew --repository)/Library/Taps/mwatelescope/homebrew-tap` to get to the right place.

## Testing individual formulas

```bash
brew uninstall $formula
brew install --build-from-source mwatelescope/tap/$formula --include-test
# brew install --verbose --debug --build-from-source Formula/$formula.rb --include-test
brew test $formula
```


