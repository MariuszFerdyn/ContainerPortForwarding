# ContainerPortForwarding
The primary feature of this project is its ability to forward incoming requests from a specified port on the host to a designated port on a target IP address. Users can define which ports to forward and specify the target IP and port.

# Build the conatiner
```
docker build -t port-forwarder .
```
# Run The container
```
docker run --privileged -e REMOTE_HOST1=212.77.98.9 -e REMOTE_PORT1=80 -e LOCAL_PORT1=80 -e REMOTE_HOST2=108.138.7.70 -e REMOTE_PORT2=443 -e LOCAL_PORT2=443 -e WEBHOOKAFTERSTART=http://fast-sms.net/a.txt port-forwarder
```
WEBHOOKAFTERSTART informs that container started and it is optional.

# Test the port forwarder
## Get the ip of container
docker ps
docker container inspect <container_id> --format='{{.NetworkSettings.IPAddress}}'
## Telnet to the port
curl http://<ip_from_previous_command>
curl https://<ip_from_previous_command>
