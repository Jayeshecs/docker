# Pull base image
FROM resin/rpi-raspbian:jessie
MAINTAINER Jayesh Prajapati <jayeshecs@gmail.com>

# Install Java.
RUN apt-get -y update
RUN apt-get -y update
RUN apt-get -y install software-properties-common

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  apt-get update && \
  apt-get install oracle-java8-jdk

# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Define default command.
CMD ["bash"]
CMD ["java", "-version"]
CMD ["echo", "JAVA_HOME=$JAVA_HOME"]


