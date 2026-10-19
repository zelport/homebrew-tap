PYTHON ?= python3

.PHONY: help check verify

help:
	@printf '%s\n' 'make check' 'make verify'

check:
	PYTHONDONTWRITEBYTECODE=1 $(PYTHON) -m unittest discover -s scripts -p 'test_*.py' -v

verify: check
