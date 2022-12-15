"""
## Configuration/Connection

1. Information from .env file
    - path
    - encryption
    - certificate
    - url
    - connection details (MSSQL and Postgres)
2. URL for Postgres and MSSQL connection.
3. S3 connection.
"""
import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy.engine.url import URL

from cryptography.fernet import Fernet
from logdecoratorandhandler.log_decorator import LogDecorator


PATH_ROOT = Path(__file__).parents[1]
PATH_STATEMENTS = Path(PATH_ROOT / 'statements')

load_dotenv(Path(PATH_ROOT / '.env'))
FERNET = Fernet(b'JqDgNlXOMtUdu5ZYu5HQ0b3eCG0NzvMfWlz7a-aqz3c=')


@LogDecorator('DEBUG - get postgres url')       # pragma: no cover
def get_postgres_uri() -> URL:
    """
    Get URL to connect with Postgres DB.
    """
    type_ = 'postgresql'
    connector = 'psycopg2'

    return URL.create(drivername=f'{type_}+{connector}',
                      host=os.getenv('PG_HOST'),
                      database=os.getenv('PG_NAME'),
                      username=os.getenv('PG_USER'),
                      password=FERNET.decrypt(bytes(os.getenv('PG_PWD'),
                                                    encoding='utf8')).decode()
                      )


@LogDecorator('DEBUG - get mssql url')          # pragma: no cover
def get_mssql_uri() -> URL:
    """
    Get URL to connect with MSSQL DB.
    """
    type_ = 'mssql'
    connector = 'pyodbc'

    query = {'driver': 'ODBC Driver 17 for SQL Server',
             'Trusted_Connection': 'Yes' if len(os.getenv('MSSQL_PWD')) < 1 else 'No',
             }

    return URL.create(drivername=f'{type_}+{connector}',
                      host=os.getenv('MSSQL_SERVER'),
                      database=os.getenv('MSSQL_NAME'),
                      username=os.getenv('MSSQL_USER') if len(os.getenv('MSSQL_PWD')) > 1 else None,
                      password=os.getenv('MSSQL_PWD') if len(os.getenv('MSSQL_PWD')) > 1 else None,
                      query=query
                      )
