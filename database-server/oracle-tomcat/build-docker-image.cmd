REM Build docker image of Oracle XE + Tomcat 8.5.5
docker build --force-rm=true --no-cache=true --shm-size=1G --build-arg DB_EDITION=xe -t jayeshsst/oracle-tomcat:xe-tom85 .
