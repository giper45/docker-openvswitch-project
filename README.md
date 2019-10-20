# docker-openvswitch-project
Experiment about implementing openvswitch in docker environments.   
Experiment is based on the following documentation: 
http://containertutorials.com/network/ovs_docker.html

## Documentation    
Build the openvswitch image:  
```bash   
cd myovs
build.sh  
```  

Then run "run.sh" script.
```bash  
MacBook-Pro:docker-openvswitch-project gaetanoperrone$ cat run.sh 
docker run -it -v /proc:/proc -v /var/run/docker.sock:/var/run/docker.sock --rm --name vswitch --privileged -d myovs
docker run -d --name container1  --network none -it --rm dockersecplayground/alpine_networking
docker run -d --name container2  --network none -it --rm dockersecplayground/alpine_networking
./run.sh
```  

In this way: 
1. A openvswitch container runs in privileged mode (it binds /proc and docker.sock host dirs)  
2. a container named container1 runs without network  
3. a container named container2 runs without network   


By going inside a container you will see that no interface is attached to:   
```bash   
./go-in-container-1.sh
ifconfig
(no interfaces) 
```  

Go inside openvswitch container:   
```bash 
./go-in-switch.sh   
```  

No bridge are created:   
```bash  
ovs-vsctl list-br  
```  
Create an OVS bridge:   
```bash  
ovs-vsctl add-br ovs-br1   
ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up
bash-4.4# ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:03  
          inet addr:172.17.0.3  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:928 (928.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

```  
Now run connect the containers to OVS bridge:  
```bash 
ovs-docker add-port ovs-br1 eth1 container1 --ipaddress=173.16.1.2/24 
ovs-docker add-port ovs-br1 eth1 container2 --ipaddress=173.16.1.3/24
```    

Try to ping the containers

