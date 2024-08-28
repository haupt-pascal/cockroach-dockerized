#!/bin/bash

HOST="178.250.15.214"
PORT="26257"
DATABASE="#"
USER="#"
PASSWORD="#"
TABLE="bans"

BATCH_SIZE=10000

TEMP_DIR=$(mktemp -d)

generate_sql() {
    local start=$1
    local end=$2
    local batch_file="$TEMP_DIR/insert_batch_$start.sql"

    echo "BEGIN;" >$batch_file
    for ((i = start; i <= end; i++)); do
        IP="192.168.1.$((i % 255))"
        JAIL_NAME="jail_$i"
        REASON="Automated entry $i"
        HOSTNAME="host_$i"

        echo "INSERT INTO $TABLE (ip_address, jail_name, reason, hostname) VALUES ('$IP', '$JAIL_NAME', '$REASON', '$HOSTNAME');" >>$batch_file
    done
    echo "COMMIT;" >>$batch_file
}

TOTAL_RECORDS=100000

NUM_BATCHES=$((TOTAL_RECORDS / BATCH_SIZE))

for ((batch = 0; batch < NUM_BATCHES; batch++)); do
    start=$((batch * BATCH_SIZE + 1))
    end=$((start + BATCH_SIZE - 1))
    generate_sql $start $end
done

echo "Inserting records into the $TABLE table..."
find $TEMP_DIR -name "insert_batch_*.sql" | xargs -n 1 -P 4 -I {} bash -c "PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -U $USER -d $DATABASE -f {}"

# Aufräumen
rm -r $TEMP_DIR

echo "Records successfully inserted into the $TABLE table."
