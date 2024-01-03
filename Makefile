install:
	mkdir -p ~/scdf/; \
	wget https://repo.maven.apache.org/maven2/org/springframework/cloud/spring-cloud-dataflow-server/2.11.1/spring-cloud-dataflow-server-2.11.1.jar -O ~/scdf/scdf-server.jar; \
	wget https://repo.maven.apache.org/maven2/org/springframework/cloud/spring-cloud-dataflow-shell/2.11.1/spring-cloud-dataflow-shell-2.11.1.jar -O ~/scdf/scdf-shell.jar; \
	wget https://repo.maven.apache.org/maven2/org/springframework/cloud/spring-cloud-skipper-server/2.11.1/spring-cloud-skipper-server-2.11.1.jar -O ~/scdf/scdf-skipper.jar;

start-services:
	docker-compose -f ./deployment/compose/docker-compose.yml down -v; \
    docker-compose -f ./deployment/compose/docker-compose.yml rm -fsv; \
    docker-compose -f ./deployment/compose/docker-compose.yml up --remove-orphans;

stop-services:
	docker-compose -f ./deployment/compose/docker-compose.yml down -v; \
    docker-compose -f ./deployment/compose/docker-compose.yml rm -fsv;

start:
	bash run.sh

stop:
	jps | grep 'scdf-skipper.jar' | cut -d' ' -f1 | xargs kill -9; \
    jps | grep 'scdf-server.jar' | cut -d' ' -f1 | xargs kill -9; \
    jps | grep 'price-update-service-0.0.1-SNAPSHOT.jar' | cut -d' ' -f1 | xargs kill -9; \
    jps | grep 'price-update-confirmation-service-0.0.1-SNAPSHOT.jar' | cut -d' ' -f1 | xargs kill -9; \
    jps | grep 'instrument-generation-service-0.0.1-SNAPSHOT.jar' | cut -d' ' -f1 | xargs kill -9; \
    jps;
