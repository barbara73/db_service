"""
## Repository

This is an interface for interactions with the database.

There are five functions defined:
- add:
    add any class as table to database
- get:
    query any table by a value
- insert:
    bulk insert a dictionary with column name keys to a table
- list:
    yield values as iterator of a table
- count:
    count any table column by value
"""
from abc import ABC, abstractmethod
from typing import Optional

from src.csv_to_db.utils import chunks

CHUNK_SIZE = 1000


class AbstractRepository(ABC):
    @abstractmethod
    def add(self, *args):
        raise NotImplementedError   # pragma: no cover

    @abstractmethod
    def get(self, *args):
        raise NotImplementedError   # pragma: no cover

    @abstractmethod
    def insert(self, *args):
        raise NotImplementedError   # pragma: no cover

    @abstractmethod
    def list(self, *args) -> list:
        raise NotImplementedError   # pragma: no cover

    @abstractmethod
    def count(self, *args) -> int:
        raise NotImplementedError   # pragma: no cover


class SqlAlchemyRepository(AbstractRepository, ABC):
    """
    Main repository for interacting with DB.
    """
    def __init__(self, session):
        self.session = session

    def add(self, item) -> None:
        """
        Add any row of any table into DB.
        """
        self.session.add(item)

    def get(self, table, by=None) -> tuple:
        """
        Get row from any DB with or without conditions.
        """
        if by is None:
            return self.session.query(table).first()
        return self.session.query(table).filter(table.id == by).first()

    def insert(self, dict_list: list, table) -> None:
        """
        Insert dict list into DB with bulk insert.
        Much faster for large data set.
        """
        for item in chunks(dict_list, CHUNK_SIZE):
            self.session.bulk_insert_mappings(table, item)

    def list(self, table, by: Optional[bool] = None) -> list:
        """
        Get any data as list with or without conditions.
        """
        if by is None:
            return self.session.query(table).yield_per(CHUNK_SIZE)

        return self.session.query(table).filter(
            table.exported == by).yield_per(CHUNK_SIZE)

    def count(self, table_col, by: bool) -> int:
        """
        Count the table column by filter.
        """
        return self.session.query(table_col).filter(table_col == by).count()
