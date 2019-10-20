docker run -it -v /proc:/proc -v /var/run/docker.sock:/var/run/docker.sock --rm --name vswitch --privileged -d myovs
docker run -d --name container1  --network none -it --rm dockersecplayground/alpine_networking
docker run -d --name container2  --network none -it --rm dockersecplayground/alpine_networking
