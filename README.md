# csv-to-db

Very large csv insertion to database.

______________________________________________________________________
[![Documentation](https://img.shields.io/badge/docs-passing-green)](https://barbara73.github.io/csv_to_db/csv_to_db.html)
[![License](https://img.shields.io/github/license/barbara73/csv_to_db)](https://github.com/barbara73/csv_to_db/blob/main/LICENSE)
[![LastCommit](https://img.shields.io/github/last-commit/barbara73/csv_to_db)](https://github.com/barbara73/csv_to_db/commits/main)
[![Code Coverage](https://img.shields.io/badge/Coverage-0%25-red.svg)](https://github.com/barbara73/csv_to_db/tree/main/tests)


Developers:

- Barbara Jesacher (barbara.jesacher@gmail.com)


## Setup

### Set up the environment

1. Run `make install`, which installs Poetry (if it isn't already installed), sets up a virtual environment and all Python dependencies therein.
2. Run `source .venv/bin/activate` to activate the virtual environment.

### Install new packages

To install new PyPI packages, run:

```
$ poetry add <package-name>
```

### Auto-generate API documentation

To auto-generate API document for your project, run:

```
$ make docs
```

To view the documentation, run:

```
$ make view-docs
```

## Tools used in this project
* [Poetry](https://towardsdatascience.com/how-to-effortlessly-publish-your-python-package-to-pypi-using-poetry-44b305362f9f): Dependency management
* [hydra](https://hydra.cc/): Manage configuration files
* [pre-commit plugins](https://pre-commit.com/): Automate code reviewing formatting
* [pdoc](https://github.com/pdoc3/pdoc): Automatically create an API documentation for your project

## Project structure
```
.
├── .flake8
├── .github
│   └── workflows
│       ├── ci.yaml
│       └── docs.yaml
├── .gitignore
├── .pre-commit-config.yaml
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── config
│   ├── __init__.py
│   ├── config.yaml
│   ├── model
│   │   └── model1.yaml
│   └── process
│       └── process1.yaml
├── data
│   ├── final
│   ├── processed
│   └── raw
├── makefile
├── models
├── notebooks
├── poetry.toml
├── pyproject.toml
├── src
│   ├── scripts
│   │   ├── fix_dot_env_file.py
│   │   └── versioning.py
│   └── csv_to_db
│       ├── __init__.py
│       └── demo.py
└── tests
    └── __init__.py
```
