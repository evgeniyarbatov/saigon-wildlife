# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A tool that pulls iNaturalist observations inside a bounding box of Saigon (Ho Chi Minh City),
plus a static site (published via GitHub Pages) that browses the results.

Forked in spirit from `sapa-wildlife`. This repo does not use a GPX corridor by default.

## Commands

```bash
make install                                    # uv sync
make run [TAXON=birds]                          # pull the default Saigon box
make run SWLAT=10.72 SWLON=106.62 NELAT=10.88 NELON=106.85
make lint                                       # ruff check
make fmt                                        # ruff format
make clean                                      # rm pages/data/ and stray *_observations.csv
```

Default box: `10.349 106.364 11.160 107.027` (SWLAT SWLON NELAT NELON).

`TAXON` must be one of the keys in `TAXA` in `scripts/inat_corridor.py` (`snakes`, `reptiles`,
`amphibians`, `birds`, `mammals`, `insects`, `plants`, `fungi`). Omit it to pull all taxa.

There is no test suite. Do not run the pull unless asked — the user runs it locally.

## Architecture

`scripts/inat_corridor.py` is the entire data pipeline, run as a one-shot CLI (no server, no
scheduling):

1. Take a bounding box (`--bbox`, or the Saigon default). `--gpx` remains available but is unused.
2. Query the iNaturalist API for that box, cursor-paginated by observation id to bypass the
   API's 10k-result cap (`iter_observations`).
3. Flag observations with obscured coordinates (`coords_obscured`).
4. Write `<prefix>_observations.csv` under `pages/data/`, one row per sighting.

`pages/data/saigon_observations.csv` is the committed, checked-in output for the city box —
`.gitignore` excludes everything else under `pages/data/` but whitelists this file
specifically, since it's consumed by the published site rather than being a throwaway build
artifact. The committed file may start as headers-only until a local run fills it.

`pages/index.html` is a static, buildless single-page app: PapaParse loads
`data/saigon_observations.csv` (relative, so `pages/data/...` once served) client-side, then
`dedupeByName` collapses it to one row per species (keyed on scientific name, falling back to
common name), keeping only the most recent `observed_on`, before rendering into a
sortable/filterable table (`CONFIG` in the inline `<script>` drives columns, labels, and
per-column renderers).

GitHub Pages is configured as an Actions-built site (not branch/root), since branch-based
Pages can only serve the repo root or `/docs`. `.github/workflows/pages.yml` uploads the
`pages/` directory as the Pages artifact and deploys on every push to `main` that touches
`pages/**`.
