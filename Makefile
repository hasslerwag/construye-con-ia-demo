# Native (Poetry) helpers for the demo.
#
# On Apple Silicon + Homebrew Python 3.12, poetry/pytest can crash with a pyexpat symbol
# error (`_XML_SetAllocTrackerActivationThreshold`) because the loader resolves the system
# libexpat instead of Homebrew's. We prefix commands with DYLD_LIBRARY_PATH pointing at
# Homebrew's expat *only when that directory exists* — so these targets are a no-op fix on
# machines that don't need it. Docker users can ignore this file (`docker compose up`).
#
# Prereq for the workaround: `brew install expat`.

EXPAT_LIB := /opt/homebrew/opt/expat/lib
DYLD := $(if $(wildcard $(EXPAT_LIB)),DYLD_LIBRARY_PATH=$(EXPAT_LIB),)

.PHONY: install test cov run

install:
	$(DYLD) poetry install

test:
	$(DYLD) poetry run pytest

cov:
	$(DYLD) poetry run pytest --cov=app --cov-report=term-missing

run:
	$(DYLD) poetry run uvicorn app.main:app --reload
