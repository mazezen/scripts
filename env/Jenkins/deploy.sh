#! /bin/bash

echo "create network..."
sleep 2
docker network create jenkins || true

docker stop jenkins-blueocean 2>/dev/null || true
sleep 2
echo "jenkins-blueocean stop sucess..."

docker rm jenkins-blueocean 2>/dev/null || true
sleep 2
echo "jenkins-blueocean rm success..."

docker rmi myjenkins-blueocean:2.528.2-1 2>/dev/null || true
sleep 2
echo "myjenkins-blueocean:2.528.2-1 rmi success..."

echo "...... BEGIN PACKING jenkins ......"
docker build -t myjenkins-blueocean:2.528.2-1 .
echo "...... END PACKED jenkins ......"

sleep 1
echo "...... BEIGIN RUN jenkins-blueocean ......"
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.528.2-1

sleep 3
echo "jenkins-blueocean run success..."