#
# Scala and sbt Dockerfile
#
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM  openjdk:9

ENV SCALA_VERSION 2.12.2
ENV SBT_VERSION 0.13.15

# Scala expects this file
RUN touch /usr/lib/jvm/java-9-openjdk-amd64/release

## https://github.com/docker-library/openjdk/issues/101
RUN /bin/bash -c "[[ ! -d $JAVA_HOME/conf ]] && ln -s $JAVA_HOME/lib $JAVA_HOME/conf"

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

# Install rsync: sbt uses it to sync "offline" preloaded-local repo
RUN \
  apt-get update && \
  apt-get install -y rsync && \
  rm -rf /var/lib/apt/lists/*

# Install sbt via direct download
RUN \
  cd /opt/ && \
  (wget -q -O - https://github.com/sbt/sbt/releases/download/v1.0.2/sbt-1.0.2.tgz | tar zxf -) && \
  ln -fs /opt/sbt/bin/sbt /usr/local/bin/sbt && \
  sbt sbtVersion

# Define working directory
WORKDIR /root
