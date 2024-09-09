#!/bin/bash

set -e

mypy --show-traceback --cache-dir /tmp/.mypy_cache --config mypy.ini \
    --no-incremental --warn-unreachable --warn-redundant-casts --warn-unused-ignores --warn-unused-configs \
    .
pylint --rcfile pylintrc --jobs=4 .
