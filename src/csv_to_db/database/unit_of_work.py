# pylint: disable=attribute-defined-outside-init
"""
## Unit of Work

This is the interface to the repository.
With help of this module, the tool is independent of database.
"""
from __future__ import annotations

from abc import ABC, abstractmethod
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from src.csv_to_db.config import get_mssql_uri
from src.csv_to_db.database.repository import AbstractRepository, SqlAlchemyRepository


class AbstractUnitOfWork(ABC):
    items: AbstractRepository

    def __enter__(self) -> AbstractUnitOfWork:
        return self                             # pragma: no cover

    def __exit__(self, *args):
        self.rollback()                         # pragma: no cover

    @abstractmethod
    def commit(self):
        raise NotImplementedError               # pragma: no cover

    @abstractmethod
    def rollback(self):
        raise NotImplementedError               # pragma: no cover


DEFAULT_SESSION_FACTORY = sessionmaker(
    bind=create_engine(get_mssql_uri(),
                       pool_size=100,
                       max_overflow=200)
)


class SqlAlchemyUnitOfWork(AbstractUnitOfWork, ABC):
    """
    Unit of work:

    - session created from default (mssql)
    - use the with statement, such that the session is closed with exit
    - after adding data to database - commit
    - if something goes wrong - rollback
    """
    def __init__(self, session_factory=DEFAULT_SESSION_FACTORY):
        self.session_factory = session_factory

    def __enter__(self):
        self.session = self.session_factory()
        self.items = SqlAlchemyRepository(self.session)
        return super().__enter__()

    def __exit__(self, *args):
        super().__exit__(*args)
        self.session.close()

    def commit(self):
        self.session.commit()

    def rollback(self):
        self.session.rollback()
