# DOCKER on WIN10 in wsl

In order to update the docker inside wsl execute the following commands


```bash
. /etc/os-release
curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc
```
add repo and update the docker installation 
```bash
echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
```
install docker
```bash
sudo apt install docker-ce docker-ce-cli containerd.io
```
add user to the docker group

```bash
    sudo usermod -aG docker $USER
```

in order to automatically start docker from user space its good to add the following line to .bashrc
