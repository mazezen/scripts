# 查看 initialAdminPassword

## Version

- Jenkins 2.528.2

> 文档: https://www.jenkins.io/doc/book/installing/docker/

```shell
sudo docker exec ${CONTAINER_ID or CONTAINER_NAME} cat /var/jenkins_home/secrets/initialAdminPassword
```
