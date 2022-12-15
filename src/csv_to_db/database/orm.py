"""
## ORM

This module is a wrapper for the DB tables. Here the table columns (and schemas) are defined.
If a table does not exist, it will be created.

Then, the tables are mapped to the classes of our model.
"""
from __future__ import annotations

from logdecoratorandhandler.log_decorator import LogDecorator
from sqlalchemy import Table, MetaData, Column, String, create_engine
from sqlalchemy import Boolean, Float, DateTime
from sqlalchemy.orm import mapper


from src.csv_to_db.config import get_postgres_uri, get_mssql_uri

metadata = MetaData()
engine = create_engine(get_postgres_uri())


# existing database
data_provider_institute = Table(
    'sphn_dataproviderinstitute',
    metadata,
    Column('id', String(3000), primary_key=True, nullable=False),
    autoload_with=engine,
    # schema=f'{project}',
)


# creating database
order_sop_instance = Table(
    'order_sop_instance',
    metadata,
    Column('id', String(64), primary_key=True, nullable=False),
    Column('patient_id', String(64)),
    Column('study_uid', String(64), nullable=False),
    Column('series_uid', String(64), nullable=False),
    Column('exported', Boolean, default=False, index=True),
)


@LogDecorator('INFO - start mapping DB to classes')
def start_mappers() -> None:
    """
    Mapping of model classes to ORM.

    The unique ID's are related to the export table.
    """
    mapper(OrderSOPInstance, order_sop_instance)

    engine = create_engine(get_mssql_uri())
    metadata.create_all(engine)
