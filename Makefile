install:
	mkdir -p ~/scdf/; \
	wget https://repo.maven.apache.org/maven2/org/springframework/cloud/spring-cloud-dataflow-server/2.11.1/spring-cloud-dataflow-server-2.11.1.jar -O ~/scdf/scdf-server.jar; \
	wget https://repo.maven.apache.org/maven2/org/springframework/cloud/spring-cloud-dataflow-shell/2.11.1/spring-cloud-dataflow-shell-2.11.1.jar -O ~/scdf/scdf-shell.jar; \
	wget https://repo.maven.apache.org/maven2/org/springframework/cloud/spring-cloud-skipper-server/2.11.1/spring-cloud-skipper-server-2.11.1.jar -O ~/scdf/scdf-skipper.jar;

start:
	bash run.sh