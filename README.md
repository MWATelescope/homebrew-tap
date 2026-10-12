# MWATelescope Homebrew tap

Prebuilt [Homebrew](https://brew.sh) packages of the
[Murchison Widefield Array](https://www.mwatelescope.org) software stack for
Apple Silicon Macs.

## Install

```bash
brew tap mwatelescope/tap
brew trust --tap mwatelescope/tap
brew install mwatelescope/tap/birli mwatelescope/tap/hyperdrive
```

That's it: everything else (aoflagger, casacore, the measures data, the MWA beam
model, ...) comes along as dependencies. Bottles (prebuilt binaries) are
provided for macOS 15 (Sequoia) and macOS 26 (Tahoe) on Apple Silicon; anything
else builds from source, which needs the Xcode Command Line Tools
(`xcode-select --install`) and takes a while.

`brew trust` is needed because Homebrew refuses to load formulae from taps
outside the `homebrew/` organisation until you trust them.

Keep everything up to date with `brew update && brew upgrade`.

## What's included

| Formula | Provides |
| --- | --- |
| `birli` | [Birli](https://github.com/MWATelescope/Birli): preprocess raw MWA visibilities (RFI flagging with aoflagger, averaging, conversion to measurement sets / uvfits) |
| `hyperdrive` | [hyperdrive](https://github.com/MWATelescope/mwa_hyperdrive): MWA calibration software |
| `mwa-fee-beam` | The MWA FEE beam model file (`mwa_full_embedded_element_pattern.h5`) |
| `aoflagger` | [AOFlagger](https://gitlab.com/aroffringa/aoflagger) RFI flagger (`aoflagger`, `aoquality`, `libaoflagger`) |
| `casacore` | [casacore](https://github.com/casacore/casacore) libraries and tools, with Python bindings |
| `casacore-data` | Ephemerides and geodetic data for casacore measures, from ASTRON |
| `cfitsio_reentrant` | [CFITSIO](https://heasarc.gsfc.nasa.gov/fitsio/) built thread-safe |
| `wcslib` | [WCSLIB](https://www.atnf.csiro.au/computing/software/wcs/) built against `cfitsio_reentrant` |

### The beam file

`hyperdrive` finds the beam file from `mwa-fee-beam` automatically. If you set
`MWA_BEAM_FILE` yourself, that takes precedence. Other tools (e.g. the
`mwa_hyperbeam` Python package) need it set explicitly:

```bash
export MWA_BEAM_FILE="$(brew --prefix mwa-fee-beam)/share/mwa-fee-beam/mwa_full_embedded_element_pattern.h5"
```

### Options

These build from source rather than using bottles:

```bash
brew install mwatelescope/tap/aoflagger --with-gtkmm4     # include the rfigui and aoqplot GUIs
brew install mwatelescope/tap/casacore --without-python   # skip the python-casacore bindings
```

## Troubleshooting

- **`Refusing to load formula ... from untrusted tap`**: run
  `brew trust --tap mwatelescope/tap`.
- **`Library not loaded: .../libcasa_*.dylib`** (or another tap library) after
  an upgrade: a dependency changed its library version. Rebuild the broken
  package with `brew reinstall --build-from-source mwatelescope/tap/<formula>`
  and please open an issue so its `revision` gets bumped.
- **A bottle fails to download (404)**: `brew update` first; if it persists,
  open an issue. `brew install --build-from-source ...` works around it.

## Maintaining this tap

Don't clone this repository directly; work in Homebrew's copy of the tap:

```bash
cd "$(brew --repository mwatelescope/tap)"
```

### Updating a formula

1. Update `url`, `version` (if not inferred) and `sha256`
   (`curl -fsSL <url> | shasum -a 256`).
2. If a library's ABI changed (e.g. casacore's `libcasa_*.N.dylib` number went
   up), add or bump `revision` in every formula that links against it so users'
   `brew upgrade` rebuilds them. Currently `aoflagger` links casacore, `birli`
   links aoflagger, and `wcslib`/`casacore`/`aoflagger`/`birli`/`hyperdrive`
   link `cfitsio_reentrant`.
3. Test locally:

   ```bash
   brew style --fix Formula/*.rb
   brew reinstall --build-from-source mwatelescope/tap/<formula>
   brew test mwatelescope/tap/<formula>
   ```

4. Push to `main`.

There's no need to touch `bottle do` blocks: CI handles them.

### How bottling works

`.github/workflows/bottle.yml` runs on every push to `main`. For each formula in
its `package_order` (dependency order; add new formulae there), on each macOS
runner, it checks whether a bottle for the current version already exists. If
not, it builds, tests and bottles the formula, uploads the bottle to a new
GitHub release, and commits the updated `bottle do` blocks back to `main` with
`[skip ci]`. Formulae that fail are reported as errors, and the rest are still
published. To rebuild every bottle (e.g. after a Homebrew-core dependency
changes ABI), run the workflow manually from the Actions tab with
`rebottle_all` ticked.

The org only allows actions owned by MWATelescope, so the workflow uses plain
shell, `git` and the preinstalled `gh` CLI rather than any `uses:` actions.

### Known fragile spots

- **casacore-data**: ASTRON only keeps recent `WSRT_Measures_*.ztar` files on
  <ftp://ftp.astron.nl/outgoing/Measures/>, so the pinned URL disappears after a
  few months. When CI fails to download it, bump `url`/`version`/`sha256` to the
  latest file listed there.
- **casacore**'s Python bindings must use the same Python as Homebrew's
  `boost-python3` and `numpy`; when those move to a new Python, update
  `python@3.x` in `casacore.rb` and `aoflagger.rb`.
- **mwa-fee-beam**'s upstream URL is unversioned. If the file changes, its
  checksum stops matching; update `sha256` and set `version` to the file's
  `Last-Modified` date.
