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
cat run.sh 
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
...
ovs-br1   Link encap:Ethernet  HWaddr 46:CF:28:F0:5E:4A  
          inet addr:173.16.1.1  Bcast:173.16.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


```  
Now run connect the containers to OVS bridge:  
```bash 
ovs-docker add-port ovs-br1 eth1 container1 --ipaddress=173.16.1.2/24 
ovs-docker add-port ovs-br1 eth1 container2 --ipaddress=173.16.1.3/24
```    

Try the connection between containers:   
```
./go-in-container1.sh
ping 
173.16.1.3   
```



## Additional tests
2 networks: 

```
ovs-vsctl add-br ovs-br1
ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up
ovs-docker add-port ovs-br1 eth1 container1 --ipaddress=173.16.1.2/24 
ovs-docker add-port ovs-br1 eth1 container2 --ipaddress=173.16.1.3/24

ovs-vsctl add-br ovs-br2
ifconfig ovs-br2 173.16.2.1 netmask 255.255.255.0 up
ovs-docker add-port ovs-br2 eth1 container3 --ipaddress=173.16.2.2/24 
ovs-docker add-port ovs-br2 eth1 container4 --ipaddress=173.16.2.3/24
```

Now set default routes:
```
docker exec container1 ip route add default via 173.16.1.1
docker exec container2 ip route add default via 173.16.1.1
docker exec container3 ip route add default via 173.16.2.1
docker exec container4 ip route add default via 173.16.2.1

ovs-vsctl add-port ovs-br1 br1-to-br2 -- set Interface br1-to-br2 type=patch options:peer=br2-to-br1
ovs-vsctl add-port ovs-br2 br2-to-br1 -- set Interface br2-to-br1 type=patch options:peer=br1-to-br2

echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -p

```


```
# 1. Create the OVS Bridges and configure IP addresses:

# Create the first bridge (ovs-br1) and configure the IP
ovs-vsctl add-br ovs-br1
ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up

# Create the second bridge (ovs-br2) and configure the IP
ovs-vsctl add-br ovs-br2
ifconfig ovs-br2 173.16.2.1 netmask 255.255.255.0 up

# Create the third bridge (ovs-br3) and configure the IP
ovs-vsctl add-br ovs-br3
ifconfig ovs-br3 173.16.3.1 netmask 255.255.255.0 up


# 2. Add containers to the bridges and configure IP addresses:

# Add containers to network 1 (ovs-br1)
ovs-docker add-port ovs-br1 eth1 container1 --ipaddress=173.16.1.2/24
ovs-docker add-port ovs-br1 eth1 container2 --ipaddress=173.16.1.3/24

# Add containers to network 2 (ovs-br2)
ovs-docker add-port ovs-br2 eth1 container3 --ipaddress=173.16.2.2/24
ovs-docker add-port ovs-br2 eth1 container4 --ipaddress=173.16.2.3/24

# Add containers to network 3 (ovs-br3)
ovs-docker add-port ovs-br3 eth1 container5 --ipaddress=173.16.3.2/24
ovs-docker add-port ovs-br3 eth1 container6 --ipaddress=173.16.3.3/24


# 3. Set default routes for each container:

# Network 1
docker exec container1 ip route add default via 173.16.1.1
docker exec container2 ip route add default via 173.16.1.1

# Network 2
docker exec container3 ip route add default via 173.16.2.1
docker exec container4 ip route add default via 173.16.2.1

# Network 3
docker exec container5 ip route add default via 173.16.3.1
docker exec container6 ip route add default via 173.16.3.1


# 4. Create Patch connections between the bridges:

# Connection between ovs-br1 and ovs-br2
ovs-vsctl add-port ovs-br1 br1-to-br2 -- set Interface br1-to-br2 type=patch options:peer=br2-to-br1
ovs-vsctl add-port ovs-br2 br2-to-br1 -- set Interface br2-to-br1 type=patch options:peer=br1-to-br2

# Connection between ovs-br2 and ovs-br3
ovs-vsctl add-port ovs-br2 br2-to-br3 -- set Interface br2-to-br3 type=patch options:peer=br3-to-br2
ovs-vsctl add-port ovs-br3 br3-to-br2 -- set Interface br3-to-br2 type=patch options:peer=br2-to-br3


# 5. Optionally, add routes between networks for inter-container communication:

# Network 1 to Network 2 and 3
docker exec container1 ip route add 173.16.2.0/24 via 173.16.1.1
docker exec container1 ip route add 173.16.3.0/24 via 173.16.1.1
docker exec container2 ip route add 173.16.2.0/24 via 173.16.1.1
docker exec container2 ip route add 173.16.3.0/24 via 173.16.1.1

# Network 2 to Network 1 and 3
docker exec container3 ip route add 173.16.1.0/24 via 173.16.2.1
docker exec container3 ip route add 173.16.3.0/24 via 173.16.2.1
docker exec container4 ip route add 173.16.1.0/24 via 173.16.2.1
docker exec container4 ip route add 173.16.3.0/24 via 173.16.2.1

# Network 3 to Network 1 and 2
docker exec container5 ip route add 173.16.1.0/24 via 173.16.3.1
docker exec container5 ip route add 173.16.2.0/24 via 173.16.3.1
docker exec container6 ip route add 173.16.1.0/24 via 173.16.3.1
docker exec container6 ip route add 173.16.2.0/24 via 173.16.3.1

```