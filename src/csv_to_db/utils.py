"""
## Utilities

Helper functions.
"""
from os import listdir
from os.path import isfile, join
from pathlib import Path
from collections.abc import Iterable


def chunks(data, size=2000) -> Iterable:
    """
    Insert or list data in chunks. 10000 is a good size if working with higher RAM.
    Choose around 1000 on local computer.
    """
    for i in range(0, len(data), size):
        yield data[i: i + size]


def get_statement(file_path: Path) -> str:
    """
    Read statements from file.
    """
    with open(file_path, encoding='utf8') as file:      # pragma: no cover
        return file.read()                              # pragma: no cover


def get_file_names(file_path):
    """
    Get file names from folder.
    """
    return [f for f in listdir(file_path) if isfile(join(file_path, f))]    # pragma: no cover


def get_log() -> list:
    """
    Get logs from file.
    """
    with open(Path('logging.log'), encoding='utf-8') as file:     # pragma: no cover
        return file.read().splitlines()         # pragma: no cover
