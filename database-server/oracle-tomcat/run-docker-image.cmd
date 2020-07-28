REM Run docker image of Oracle XE + Tomcat 8.5.5
docker run -it --name=oracle-tomcat -p 2022:22 -p 1522:1521 -p 8181:8181 -p 8080:8080 -p 8009:8009 --shm-size=1g -e ORACLE_PWD=password  jayeshsst/oracle-tomcat:xe-tom85
