#!/bin/sh
rm click.db
cat scheme.sql | sqlite3 click.db
cat countries.sql | sqlite3 click.db
