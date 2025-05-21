# Docker install

```bash
sudo apt update
sudo apt install docker.io

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```


# kazoo_build_docker

>docker build -t kazoo-builder ./

```bash

#source  /usr/local/otp-19.3.6.13/activate
docker run -it --rm --platform=linux/amd64  -v .:/app --entrypoint bash kazoo-builder

```