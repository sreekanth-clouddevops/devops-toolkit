FROM ubuntu:22.04
LABEL maintainer="Sree <sreekanth.clouddevops@gmail.com>"

RUN apt-get update && apt-get install -y bash curl git
WORKDIR /app
COPY . /app

CMD ["/bin/bash", "-c", "echo 'Running DevOps toolkit container'; ls /app"]
