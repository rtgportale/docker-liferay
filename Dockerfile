FROM rsippl/centos-jdk

MAINTAINER RTG Portale <info@rtg-portale.de>
LABEL version="1.0"
LABEL description="Dieses Dockerfile startet liferay inkl. aller notwendigen Portlets und Einstellungen"

RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y \
    unzip \
    supervisor
RUN yum clean all

USER root

WORKDIR /opt

# Liferay Download
RUN curl -O -k -L http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.2.5%20GA6/liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip \
 && unzip liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip -d /opt \
 && rm liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip
RUN ln -s /opt/liferay-portal-tomcat-6.2-ce-ga6 /opt/liferay

 #adduser
 RUN useradd -ms /bin/bash liferay

 # Set the LIFERAY_HOME env variable
 ENV LIFERAY_HOME /opt/liferay

 # Settings
 COPY conf/portal-ext.properties $LIFERAY_HOME/portal-ext.properties
 COPY conf/system-ext.properties $LIFERAY_HOME/tomcat-7.0.62/webapps/ROOT/WEB.INF/classes/system-ext.properties
 COPY conf/portal-setup-wizard.properties $LIFERAY_HOME/portal-setup-wizard.properties
 RUN rm $LIFERAY_HOME/tomcat-7.0.62/conf/context.xml
 COPY ./conf/context.xml $LIFERAY_HOME/tomcat-7.0.62/conf/context.xml


RUN echo -e '\nCATALINA_OPTS="$CATALINA_OPTS -Djava.security.egd=file:/dev/./urandom"' >> /opt/liferay/tomcat-7.0.62/bin/setenv.sh

COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/init.sh /opt/liferay/init.sh

# Expose the ports we're interested in
EXPOSE 8080

# DATA Folder
VOLUME ["/opt/liferay"]

#rights
RUN chown -R liferay:liferay $LIFERAY_HOME
RUN chmod -R g+rw $LIFERAY_HOME

# Start Liferay
#USER liferay
USER root
WORKDIR $LIFERAY_HOME/tomcat-7.0.62/bin
ENTRYPOINT ["/opt/liferay/tomcat-7.0.62/bin/catalina.sh"]
CMD ["run"]

CMD /usr/bin/supervisord -n
