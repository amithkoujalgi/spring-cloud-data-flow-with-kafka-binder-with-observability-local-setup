#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

jps | grep 'spring-cloud-skipper-server-2.11.1.jar' | cut -d' ' -f1 | xargs kill -9
jps | grep 'spring-cloud-localhost-2.11.1.jar' | cut -d' ' -f1 | xargs kill -9

java \
  -jar spring-cloud-skipper-server-2.11.1.jar &

# Wait until 7577 port is up
while ! nc -z localhost 7577; do
  sleep 1
done

echo "Skipper server is up and running! Starting dataflow server..."

java \
  -jar spring-cloud-localhost-2.11.1.jar &

# Wait until 9393 port is up
while ! nc -z localhost 9393; do
  sleep 1
done

echo "Dataflow server is up and running! Registering tasks..."

wget 'http://localhost:9393/apps/source/instrument-generation-service' \
  --no-check-certificate \
  --post-data="bootVersion=2&uri=file://$PARENT_DIR/services/instrument-generation-service/target/instrument-generation-service-0.0.1-SNAPSHOT.jar";
wget 'http://localhost:9393/apps/processor/price-update-service' \
  --no-check-certificate \
  --post-data="bootVersion=2&uri=file://$PARENT_DIR/services/price-update-service/target/price-update-service-0.0.1-SNAPSHOT.jar";
wget 'http://localhost:9393/apps/sink/price-update-confirmation-service' \
  --no-check-certificate \
  --post-data="bootVersion=2&uri=file://$PARENT_DIR/services/price-update-confirmation-service/target/price-update-confirmation-service-0.0.1-SNAPSHOT.jar";

echo "Registering stream..."

wget \
  --method=POST \
  'http://localhost:9393/streams/definitions?name=instrument-stream&definition=instrument-generation-service%20%7C%20price-update-service%20%7C%20price-update-confirmation-service&description=';

echo "Setting global config..."

wget 'http://localhost:9393/streams/deployments/instrument-stream' \
  --header='Accept: application/json' \
  --header='Content-Type: application/json' \
  --post-data='{"app.*.spring.cloud.stream.kafka.binder.brokers": "kafka-svc:19092","app.*.spring.cloud.stream.kafka.binder.zkNodes": "zk-svc:2181"}';

