# This ensures that we can call `make <target>` even if `<target>` exists as a file or
# directory.
.PHONY: notebook docs

# Exports all variables defined in the makefile available to scripts
.EXPORT_ALL_VARIABLES:

# Create .env file if it does not already exist
ifeq (,$(wildcard .env))
  $(shell touch .env)
endif

# The binary to build (just the basename).
MODULE := src

# This version-strategy uses git tags to set the version string
TAG := 0.1.0

# Colours for printing
E_BLUE=$(shell echo -e "\033[0;34m")
E_END=$(shell echo -e "\033[0m")
E_RED=$(shell echo -e "\033[0;31m")
E_YELLOW=$(shell echo -e "\033[0;33m")
BLUE=\033[0;34m
NC=\033[0m

.DEFAULT_GOAL = help

ACTIVATE_VENV =  case "$${OSTYPE}" in           \
		darwin*)  . venv/bin/activate;;         \
		linux*)   . venv/bin/activate;;         \
		msys*)    venv\Scripts\activate;;       \
		cygwin*)  venv\Scripts\activate;;       \
		*)        echo "${E_YELLOW}Please activate environment, depending on your system!${E_END}" ;;\
	esac


help: # Show all commands
	@grep -E -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "${BLUE}%-15s${NC} %s\n", $$1, $$2}'


windows_install:
	@echo "${E_BLUE}Creating environment...${E_END}"
	@python -m venv venv
	@echo "${E_BLUE}Upgrading pip...${E_END}"
	@venv\Scripts\pip install                                               \
	        --upgrade pip                                                   \
	        --trusted-host pypi.org                                         \
	        --trusted-host pypi.python.org                                  \
	        --cert=         \
	        --proxy="http://proxy.usz.ch:8080"
	@echo "${E_BLUE}Installing requirements...${E_END}"
	@venv\Scripts\pip install -r requirements.txt                           \
	        --trusted-host pypi.org                                         \
	        --trusted-host pypi.python.org                                  \
	        --cert=         \
	        --proxy="http://proxy.usz.ch:8080"


install: # Create environment, upgrade pip and install requirements.txt
	@case "$${OSTYPE}" in                          \
		darwin*)  echo "${E_BLUE}On MacOS...${E_END}"; $(MAKE) linux_install;;\
		linux*)   echo "${E_BLUE}On Linux...${E_END}"; $(MAKE) linux_install;;\
		msys*)    echo "${E_BLUE}On Windows...${E_END}"; $(MAKE) windows_install;;\
		cygwin*)  echo "${E_BLUE}On Windows...${E_END}"; $(MAKE) windows_install;;\
		*)        echo "${E_YELLOW}Please install manually with `make windows_install` or `make linux_install`, depending on your system!${E_END}" ;;\
	esac


linux_install:
	@echo "${E_BLUE}Creating environment...${E_END}"
	@python -m venv venv
	@echo "${E_BLUE}Upgrading pip...${E_END}"
	@venv/bin/pip install                                                   \
	        --upgrade pip                                                   \
	        --trusted-host pypi.org                                         \
	        --trusted-host pypi.python.org                                  \
	        --cert="/etc/pki/ca-trust/source/anchors/USZ-Root-CA-2.pem"     \
	        --proxy="http://proxy.usz.ch:8080"
	@echo "${E_BLUE}Installing requirements...${E_END}"
	@venv/bin/pip install -r requirements.txt                               \
	        --trusted-host pypi.org                                         \
	        --trusted-host pypi.python.org                                  \
	        --cert="/etc/pki/ca-trust/source/anchors/USZ-Root-CA-2.pem"     \
	        --proxy="http://proxy.usz.ch:8080"


test: # Test the application with pytest
	@$(ACTIVATE_VENV); pytest -s


lint: # Lint code with pylint and flake8
	@echo "${E_BLUE}Running Pylint against source and test files...${E_END}"
	@$(ACTIVATE_VENV); pylint --rcfile=setup.cfg **/*.py
	@echo "${E_BLUE}Running Flake8 against source and test files...${E_END}"
	@$(ACTIVATE_VENV); flake8
	@echo "${E_BLUE}Running Bandit against source files...${E_END}"
	@$(ACTIVATE_VENV); bandit -r --ini setup.cfg


docs: # Create documentation
	@$(ACTIVATE_VENV); pdoc --docformat google src -o docs
	@echo "${E_BLUE}Saved documentation.${E_END}"


run: # Run the application
	@echo "${E_BLUE}Please, type in the desired options. Press enter for default.${E_END}"
	@$(ACTIVATE_VENV); python -m $(MODULE)



version: # Show version of application
	@echo "${E_BLUE}Version: $(TAG)${E_END}"


.PHONY: clean test install version docs run


clean: # Clean up your repo by removing caches
	@rm -rf .pytest_cache .coverage .pytest_cache coverage.xml
	@echo "${E_BLUE}Caches removed.${E_END}"

# Includes environment variables from the .env file
include .env

# Set gRPC environment variables, which prevents some errors with the `grpcio` package
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1

install-poetry:
	@echo "Installing poetry..."
	@pipx install poetry==1.2.0
	@$(eval include ${HOME}/.poetry/env)

uninstall-poetry:
	@echo "Uninstalling poetry..."
	@pipx uninstall poetry

# install:
# 	@echo "Installing..."
# 	@if [ "$(shell which poetry)" = "" ]; then \
# 		$(MAKE) install-poetry; \
# 	fi
# 	@if [ "$(shell which gpg)" = "" ]; then \
# 		echo "GPG not installed, so an error will occur. Install GPG on MacOS with "\
# 			 "`brew install gnupg` or on Ubuntu with `apt install gnupg` and run "\
# 			 "`make install` again."; \
# 	fi
# 	@$(MAKE) setup-poetry
# 	@$(MAKE) setup-environment-variables
# 	@$(MAKE) setup-git

setup-poetry:
	@poetry env use python3 && poetry install

setup-environment-variables:
	@poetry run python3 -m src.scripts.fix_dot_env_file

setup-git:
	@git init
	@git config --local user.name ${GIT_NAME}
	@git config --local user.email ${GIT_EMAIL}
	@if [ ${GPG_KEY_ID} = "" ]; then \
		echo "No GPG key ID specified. Skipping GPG signing."; \
		git config --local commit.gpgsign false; \
	else \
		echo "Signing with GPG key ID ${GPG_KEY_ID}..."; \
		echo 'If you get the "failed to sign the data" error when committing, try running `export GPG_TTY=$$(tty)`.'; \
		git config --local commit.gpgsign true; \
		git config --local user.signingkey ${GPG_KEY_ID}; \
	fi
	@poetry run pre-commit install

# docs:
# 	@poetry run pdoc --docformat google src/csv_to_db -o docs
# 	@echo "Saved documentation."

view-docs:
	@echo "Viewing API documentation..."
	@uname=$$(uname); \
		case $${uname} in \
			(*Linux*) openCmd='xdg-open'; ;; \
			(*Darwin*) openCmd='open'; ;; \
			(*CYGWIN*) openCmd='cygstart'; ;; \
			(*) echo 'Error: Unsupported platform: $${uname}'; exit 2; ;; \
		esac; \
		"$${openCmd}" docs/csv_to_db.html

bump-major:
	@poetry run python -m src.scripts.versioning --major
	@echo "Bumped major version!"

bump-minor:
	@poetry run python -m src.scripts.versioning --minor
	@echo "Bumped minor version!"

bump-patch:
	@poetry run python -m src.scripts.versioning --patch
	@echo "Bumped patch version!"

publish:
	@if [ ${PYPI_API_TOKEN} = "" ]; then \
		echo "No PyPI API token specified in the '.env' file, so cannot publish."; \
	else \
		echo "Publishing to PyPI..."; \
		poetry publish --build --username "__token__" --password ${PYPI_API_TOKEN}; \
	fi
	@echo "Published!"

publish-major: bump-major publish

publish-minor: bump-minor publish

publish-patch: bump-patch publish

# test:
# 	@poetry run pytest && readme-cov

tree:
	@tree -a \
		-I .git \
		-I .mypy_cache \
		-I .env \
		-I .venv \
		-I poetry.lock \
		-I .ipynb_checkpoints \
		-I dist \
		-I .gitkeep \
		-I docs \
		-I .pytest_cache \
		-I outputs \
		-I .DS_Store \
		-I .cache \
		-I checkpoint-* \
		-I .coverage* \
		-I .DS_Store \
		-I __pycache__ \
		.
