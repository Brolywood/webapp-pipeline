FROM tomcat:8.5.27-jre8
MAINTAINER DinoCloud ((info@dinocloudconsuting.com)
COPY ./target/webappExample.war /usr/local/tomcat/webapps/
