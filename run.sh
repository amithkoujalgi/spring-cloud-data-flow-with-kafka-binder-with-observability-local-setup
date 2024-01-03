#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCDF_SERVER_BASE_URL="http://localhost:9393"

jps | grep 'scdf-skipper.jar' | cut -d' ' -f1 | xargs kill -9
jps | grep 'scdf-server.jar' | cut -d' ' -f1 | xargs kill -9
jps | grep 'price-update-service-0.0.1-SNAPSHOT.jar' | cut -d' ' -f1 | xargs kill -9
jps | grep 'price-update-confirmation-service-0.0.1-SNAPSHOT.jar' | cut -d' ' -f1 | xargs kill -9
jps | grep 'instrument-generation-service-0.0.1-SNAPSHOT.jar' | cut -d' ' -f1 | xargs kill -9

java \
  -jar ~/scdf/scdf-skipper.jar &

# Wait until 7577 port is up
while ! nc -z localhost 7577; do
  sleep 1
done

echo "Skipper server is up and running! Starting dataflow server..."

java \
  -jar ~/scdf/scdf-server.jar &

# Wait until 9393 port is up
while ! nc -z localhost 9393; do
  sleep 1
done

echo "Dataflow server is up and running! Registering tasks..."

# Source service
curl -k "$SCDF_SERVER_BASE_URL/apps/source/instrument-generation-service" \
  --data-urlencode "bootVersion=2" \
  --data-urlencode "uri=file://$SCRIPT_DIR/services/instrument-generation-service/target/instrument-generation-service-0.0.1-SNAPSHOT.jar"

# Processor service
curl -k "$SCDF_SERVER_BASE_URL/apps/processor/price-update-service" \
  --data-urlencode "bootVersion=2" \
  --data-urlencode "uri=file://$SCRIPT_DIR/services/price-update-service/target/price-update-service-0.0.1-SNAPSHOT.jar"

# Sink service
curl -k "$SCDF_SERVER_BASE_URL/apps/sink/price-update-confirmation-service" \
  --data-urlencode "bootVersion=2" \
  --data-urlencode "uri=file://$SCRIPT_DIR/services/price-update-confirmation-service/target/price-update-confirmation-service-0.0.1-SNAPSHOT.jar"

echo "Registering stream..."

curl \
  -X POST \
  "$SCDF_SERVER_BASE_URL/streams/definitions?name=instrument-stream&definition=instrument-generation-service%20%7C%20price-update-service%20%7C%20price-update-confirmation-service&description="

echo "Setting global config..."

curl -X POST "$SCDF_SERVER_BASE_URL/streams/deployments/instrument-stream" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"app.*.spring.cloud.stream.kafka.binder.brokers": "localhost:9092", "app.*.spring.cloud.stream.kafka.binder.zkNodes": "localhost:2181"}'