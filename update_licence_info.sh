#!/bin/bash

set -e

docker build -t tmp -f lambda/.devcontainer/Dockerfile lambda/.devcontainer
# Delete the file such that we will notice if it doesn't get recreated
rm -f LICENSES_PYTHON.txt
# "-x pylint" pyliny has license GPLv2 which should be ok here: "If you’re only using Pylint as a development tool (e.g., for linting code) and not including it in the deployed product, this shouldn’t impact your licensing requirements."
docker run --rm tmp bash -c 'pip freeze >/tmp/frozen_req.txt && python -m third_party_license_file_generator -r /tmp/frozen_req.txt -x pylint -p $(which python) -o OUT.txt >/dev/null 2>/dev/null && cat OUT.txt' >LICENSES_PYTHON.txt

cp app/build/flutter_assets/NOTICES LICENSES-FLUTTER.txt
