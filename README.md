# saigon-wildlife

A small tool that pulls **iNaturalist observations inside a bounding box of Saigon**
(Ho Chi Minh City), so you can browse what has been recorded in the city.

Adapted from [sapa-wildlife](https://github.com/evgeniyarbatov/sapa-wildlife). This variant
does **not** parse a GPX corridor — it queries the city box directly.

**`scripts/inat_corridor.py`** pulls iNaturalist observations for a lat/lon box.
**`pages/`** holds the published site (GitHub Pages, deployed by `.github/workflows/pages.yml`)
and the CSV data it reads.

Site: https://evgeniyarbatov.github.io/saigon-wildlife/

## Quickstart (uv)

```bash
make run
```

Default box (Ho Chi Minh City envelope):

```
SWLAT=10.349  SWLON=106.364  NELAT=11.160  NELON=107.027
```

Override if you want a tighter inner-city window:

```bash
make run SWLAT=10.72 SWLON=106.62 NELAT=10.88 NELON=106.85
```

`uv` handles the Python version and dependencies — no manual venv.

## Make targets

| target        | what it does |
|---------------|--------------|
| `make help`   | list targets |
| `make install`| create the venv + install deps (`uv sync`) |
| `make run`    | pull observations for the Saigon bounding box |
| `make lint` / `make fmt` | ruff |
| `make clean`  | delete generated CSVs |

Each run writes `pages/data/saigon_observations.csv`, one row per sighting.

## How the query works

iNaturalist's public API has no polygon filter, so the script:

1. uses a fixed Saigon bounding box (or `--bbox SWLAT SWLON NELAT NELON`),
2. queries the iNat API for that box (cursor-paginated, no 10k cap),
3. writes every in-box observation to CSV.

GPX corridor clipping is still in the script if you pass `--gpx`, but it is not used here.

## Caveats

- **Obscured coordinates.** iNaturalist randomises locations (~20 km) for many threatened
  taxa. Those are flagged `coords_obscured`; treat them as "in the region", not a precise pin.
- Set your email in the `USER_AGENT` string before a large pull — it's the polite thing.
- The full city box is large. A first pull can take a while and return many rows.

## Data & attribution

Observation data from **iNaturalist** (contributor-licensed; check per-observation licences
before reuse). A GBIF variant of the box query (DOI-citable occurrence downloads) is a
straightforward endpoint swap.
