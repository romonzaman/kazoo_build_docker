# Docker install

```bash
sudo apt update
sudo apt install docker.io


```


# kazoo_build_docker

>docker build -t kazoo-builder ./

```bash

#source  /usr/local/otp-19.3.6.13/activate
docker run -it --rm --platform=linux/amd64  -v .:/app --entrypoint bash kazoo-builder

```


```
docker login

docker tag kazoo-builder romonzamanbd/kazoo_builder:latest
docker push romonzamanbd/kazoo_builder:latest

```


```

docker run -it --rm --platform=linux/amd64  -v .:/app --entrypoint bash kazoo-builder

source  /usr/local/otp-19.3.6.13/activate

cd /app/
make

```