# LICENSE UPL 1.0
#
# Copyright (c) 1982-2016 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Database 11g Release 2 Express Edition
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) oracle-xe-11.2.0-1.0.x86_64.rpm.zip
#     Download Oracle Database 11g Release 2 Express Edition for Linux x64
#     from http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put the downloaded file in the same directory as this Dockerfile
# Run: 
#      $ docker build -t oracle/database:11.2.0.2-xe . 
#
# IMPORTANT
# ---------
# Oracle XE requires Docker 1.10.0 and above:
# Oracle XE uses shared memory for MEMORY_TARGET and needs at least 1 GB.
# Docker only supports --shm-size since Docker 1.10.0
#
# Pull base image
# ---------------
FROM oraclelinux:7-slim

# Maintainer
# ----------
# MAINTAINER Gerald Venzl <gerald.venzl@oracle.com>
# Inspired from https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance/dockerfiles/11.2.0.2
MAINTAINER Jayesh PRAJAPATI <jayesh.prajapati@smartstream-stp.com>

# Install required tools
# ------------------------------
RUN set -eux; \
	yum install -y \
		gzip \
		tar \
	; \
	rm -rf /var/cache/yum
	

# Default to UTF-8 file.encoding
# ------------------------------
ENV LANG en_US.UTF-8


# Download the JDK from
#
#  https://download.oracle.com/otn/java/jdk/8u211-b12/478a62b7d4e34b78b671c754eaaf38ab/jdk-8u211-linux-x64.tar.gz
#	
# and place it on the same directory as the Dockerfile
#
ENV JAVA_VERSION=1.8.0_211 \
	JAVA_PKG=jdk-8u211-linux-x64.tar.gz \
	JAVA_SHA256=c0b7e45330c3f79750c89de6ee0d949ed4af946849592154874d22abc9c4668d \
	JAVA_HOME=/usr/java/jdk-8
	
ENV	PATH $JAVA_HOME/bin:$PATH

##
COPY $JAVA_PKG /tmp/jdk.tgz
# Install Oracle Java 1.8u211
# ------------------------------
RUN set -eux; \
	\
	echo "$JAVA_SHA256 */tmp/jdk.tgz" | sha256sum -c -; \
	mkdir -p "$JAVA_HOME"; \
	tar --extract --file /tmp/jdk.tgz --directory "$JAVA_HOME" --strip-components 1; \
	rm /tmp/jdk.tgz; \
	\
	ln -sfT "$JAVA_HOME" /usr/java/default; \
	ln -sfT "$JAVA_HOME" /usr/java/latest; \
	for bin in "$JAVA_HOME/bin/"*; do \
		base="$(basename "$bin")"; \
		[ ! -e "/usr/bin/$base" ]; \
		alternatives --install "/usr/bin/$base" "$base" "$bin" 20000; \
	done; \
# -Xshare:dump will create a CDS archive to improve startup in subsequent runs	
	java -Xshare:dump; \
	java -version; \
	javac -version

# Ref https://github.com/dchkang83/centos7-jdk8-tomcat8/blob/master/Dockerfile
# APACHE TOMCAT INSTALL
ENV APACHE_TOMCAT_INSTALL_DIR /usr/local/tomcat

RUN	yum install wget -y && yum install dos2unix -y

RUN	wget "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.5/bin/apache-tomcat-8.5.5.tar.gz" \
	&& tar xzvf ./apache-tomcat-8.5.5.tar.gz \
	&& rm ./apache-tomcat-8.5.5.tar.gz \
	&& mv ./apache-tomcat-8.5.5 /opt/apache-tomcat-8.5.5 \
	&& ln -s /opt/apache-tomcat-8.5.5 /usr/local/tomcat

ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_OPTS -Xmx1g
COPY context.xml /usr/local/tomcat/conf/
RUN dos2unix /usr/local/tomcat/conf/context.xml

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORACLE_BASE=/u01/app/oracle \
    ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe \
    ORACLE_SID=XE \
    INSTALL_FILE_1="oracle-xe-11.2.0-1.0.x86_64.rpm.zip" \
    INSTALL_DIR="$HOME/install" \
    CONFIG_RSP="xe.rsp" \
    RUN_FILE="runOracle.sh" \
    PWD_FILE="setPassword.sh" \
    CHECK_DB_FILE="checkDBStatus.sh"

# Use second ENV so that variable get substituted
ENV PATH=$ORACLE_HOME/bin:$PATH

# Copy binaries
# -------------
COPY $INSTALL_FILE_1 $CONFIG_RSP $RUN_FILE $PWD_FILE $CHECK_DB_FILE $INSTALL_DIR/

# Install Oracle Express Edition
# ------------------------------

RUN yum -y install unzip libaio bc initscripts net-tools openssl compat-libstdc++-33 && \
    rm -rf /var/cache/yum && \
    cd $INSTALL_DIR && \
    unzip $INSTALL_FILE_1 && \
    rm $INSTALL_FILE_1 &&    \
    cat() { declare -A PROC=(["/proc/sys/kernel/shmmax"]=4294967295 ["/proc/sys/kernel/shmmni"]=4096 ["/proc/sys/kernel/shmall"]=2097152 ["/proc/sys/fs/file-max"]=6815744); [[ ${PROC[$1]} == "" ]] && /usr/bin/cat $* || echo ${PROC[$1]}; } && \
    free() { echo "Swap: 2048 0 2048"; } && \
    export -f cat free && \
    rpm -i Disk1/*.rpm &&    \
    unset -f cat free && \
    mkdir -p $ORACLE_BASE/scripts/setup && \
    mkdir $ORACLE_BASE/scripts/startup && \
    ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d && \
    mkdir $ORACLE_BASE/oradata && \
    chown -R oracle:dba $ORACLE_BASE && \
    mv $INSTALL_DIR/$CONFIG_RSP $ORACLE_BASE/ && \
    mv $INSTALL_DIR/$RUN_FILE $ORACLE_BASE/ && \
    mv $INSTALL_DIR/$PWD_FILE $ORACLE_BASE/ && \
    mv $INSTALL_DIR/$CHECK_DB_FILE $ORACLE_BASE/ && \
    ln -s $ORACLE_BASE/$PWD_FILE / && \
    cd $HOME && \
    rm -rf $INSTALL_DIR && \
    chmod ug+x $ORACLE_BASE/*.sh

HEALTHCHECK --interval=1m --start-period=5m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1


# sh 적용
COPY entrypoint.sh /docker-entrypoint-initdb.d/startup/
RUN dos2unix /docker-entrypoint-initdb.d/startup/entrypoint.sh
RUN chmod +x /docker-entrypoint-initdb.d/startup/entrypoint.sh

EXPOSE 8080 8009 22 1521 8181
VOLUME ["/usr/local/tomcat/webapps", "/usr/local/tomcat/logs", "$ORACLE_BASE/oradata"]

CMD exec $ORACLE_BASE/$RUN_FILE
