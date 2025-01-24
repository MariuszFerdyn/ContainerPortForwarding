# ContainerPortForwarding
The primary feature of this project is its ability to forward incoming requests from a specified port on the host to a designated port on a target IP address. Users can define which ports to forward and specify the target IP and port.

# Build the conatiner
```
docker build -t port-forwarder .
```
# Run The container
```
docker run --privileged -p 80:80 -p 443:443 -e REMOTE_HOST1=212.77.98.9 -e REMOTE_PORT1=80 -e LOCAL_PORT1=80 -e REMOTE_HOST2=108.138.7.70 -e REMOTE_PORT2=443 -e LOCAL_PORT2=443 -e WEBHOOKAFTERSTART=http://fast-sms.net/a.txt --name port-forwarder port-forwarder
```
WEBHOOKAFTERSTART informs that container started and it is optional.

# Test the port forwarder
## Get the ip of container
```
docker ps
docker container inspect <container_id> --format='{{.NetworkSettings.IPAddress}}'
```
## Telnet to the port
```
curl http://localhost
curl https://localhost
```
The expected outputs in this example:
```
curl http://localhost
curl: (52) Empty reply from server
curl https://localhost
curl: (35) error:0A000410:SSL routines::sslv3 alert handshake failure
```
## Debug in case of TCPDUMP
```
docker exec -it port-forwarder /bin/bash
```