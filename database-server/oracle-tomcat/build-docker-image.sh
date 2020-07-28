#!/bin/sh

docker build --force-rm=true --no-cache=true --shm-size=1G --build-arg DB_EDITION=xe -t jayeshsst/oracle-tomcat:xe-tom85 .
