# Scala and sbt Dockerfile
#
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM  openjdk:9

ENV SCALA_VERSION 2.12.5
ENV SBT_VERSION 1.1.2

# Scala expects this file
RUN touch /usr/lib/jvm/java-9-openjdk-amd64/release

## https://github.com/docker-library/openjdk/issues/101
# RUN /bin/bash -c "[[ ! -d $JAVA_HOME/conf ]] && ln -s $JAVA_HOME/lib $JAVA_HOME/conf"

# Install Python (node.js needs it) and aws cli so we can push
RUN \
  apt-get update && \
  apt-get install -y python python-dev python-pip python-virtualenv && \
  pip install awscli && \
  rm -rf /var/lib/apt/lists/*

# Install Node.js (play compiles assets faster with it)
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc
  
# Scalajs tests need it  
RUN \
  npm install -g jsdom

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
  (wget -q -O - https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz | tar zxf -) && \
  ln -fs /opt/sbt/bin/sbt /usr/local/bin/sbt && \
  sbt sbtVersion
  
# Define working directory
WORKDIR /root
