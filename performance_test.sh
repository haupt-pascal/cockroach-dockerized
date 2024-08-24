#!/bin/bash

# Verbindungseinstellungen
HOST="178.250.15.214"
PORT="26257"
DATABASE="shopware"
USER="pascal"
PASSWORD="cockroach"
TABLE="bans"

# Temporäre Datei zur Speicherung der SQL-Befehle
SQL_FILE="insert_commands.sql"

# Generiere die SQL-Befehle
echo "Generating SQL commands..."
{
  echo "BEGIN;"
  for i in {1..100000}; do
    IP="192.168.1.$((i % 255))"
    JAIL_NAME="jail_$i"
    REASON="Automated entry $i"
    HOSTNAME="host_$i"

    # Korrigiere die SQL-Befehle, indem du Anführungszeichen um die Werte setzt
    echo "INSERT INTO $TABLE (ip_address, jail_name, reason, hostname) VALUES ('$IP', '$JAIL_NAME', '$REASON', '$HOSTNAME');"
  done
  echo "COMMIT;"
} > $SQL_FILE

# Führe die SQL-Befehle in einer Transaktion aus
echo "Inserting records into the $TABLE table..."
PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -U $USER -d $DATABASE -f $SQL_FILE

# Aufräumen
rm $SQL_FILE

echo "10,000 records successfully inserted into the $TABLE table."
