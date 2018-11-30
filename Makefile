TEST_TARGET := ./tests/
PY_PACKAGE := sourcegit
KNIFE := sg-knife

build-knife:
	ansible-bender build ./knife.yml registry.fedoraproject.org/fedora:29 $(KNIFE)

check:
	PYTHONPATH=$(CURDIR) pytest-3 -v $(TEST_TARGET)

shell-in-knife:
	podman run --rm -ti -v $(CURDIR):/src:z -w /src $(KNIFE) bash

check-pypi-packaging:
	podman run --rm -ti -v $(CURDIR):/src:z -w /src $(KNIFE) bash -c '\
		set -x \
		&& rm -f dist/* \
		&& python3 ./setup.py sdist bdist_wheel \
		&& pip3 install dist/*.tar.gz \
		&& sourcegit-to-distgit --help \
		&& pip3 show $(PY_PACKAGE) \
		&& twine check ./dist/* \
		&& python3 -c "import sourcegit; sourcegit.__version__.startswith(\"0.0.1\")" \
		&& pip3 show -f $(PY_PACKAGE) | ( grep test && exit 1 || :) \
		'
