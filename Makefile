# saigon-wildlife --- iNaturalist bounding-box tool
UV     ?= uv
OUT    ?= pages/data/saigon
TAXON  ?=

# Ho Chi Minh City / Saigon (OSM-style city envelope)
# SWLAT SWLON NELAT NELON
SWLAT  ?= 10.349
SWLON  ?= 106.364
NELAT  ?= 11.160
NELON  ?= 107.027

TAXON_ARG := $(if $(TAXON),--taxon $(TAXON),)

.DEFAULT_GOAL := help

.PHONY: help install run test lint fmt clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

install: ## Create the venv and install deps with uv
	$(UV) sync

run: install ## City box: make run [TAXON=birds] [SWLAT=... SWLON=... NELAT=... NELON=...]
	$(UV) run python scripts/inat_corridor.py --bbox $(SWLAT) $(SWLON) $(NELAT) $(NELON) $(TAXON_ARG) --out-prefix "$(OUT)"

test: install ## Run unit tests (offline)
	$(UV) run python -m unittest discover -s tests

lint: ## Lint with ruff
	$(UV) run ruff check .

fmt: ## Format with ruff
	$(UV) run ruff format .

clean: ## Remove generated outputs
	rm -rf pages/data *_observations.csv
