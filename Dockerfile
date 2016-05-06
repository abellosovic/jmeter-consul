FROM java:8-jdk-alpine

ENV JMETER_VERSION=2.13


ENV INSTALL_LOCATION=/usr/local

ENV JMETER_BINARY=$INSTALL_LOCATION/jmeter/bin/jmeter

# Install JMeter
RUN cd $INSTALL_LOCATION && \
  wget http://www.mirrorservice.org/sites/ftp.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
  tar xzf apache-jmeter-$JMETER_VERSION.tgz && \
  rm -f apache-jmeter-$JMETER_VERSION.tgz  && \
  mv apache-jmeter-$JMETER_VERSION jmeter


ENV JMETER_PLUGINS_VERSION=1.4.0
RUN cd $INSTALL_LOCATION/jmeter && \
      wget http://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip && \
      wget http://jmeter-plugins.org/downloads/file/JMeterPlugins-Extras-${JMETER_PLUGINS_VERSION}.zip && \
      wget http://jmeter-plugins.org/downloads/file/JMeterPlugins-ExtrasLibs-${JMETER_PLUGINS_VERSION}.zip && \
      unzip -o JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip && \
      unzip -o JMeterPlugins-Extras-${JMETER_PLUGINS_VERSION}.zip && \
      unzip -o JMeterPlugins-ExtrasLibs-${JMETER_PLUGINS_VERSION}.zip

ENV CONSUL_TEMPLATE_VERSION=0.14.0

RUN cd $INSTALL_LOCATION/bin && \
    wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    rm  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip


RUN mkdir -p /etc/consul-template/config.d /etc/consul-template/template.d /tests


ENV CONSUL_WAIT=5s:20s

#This presumes that container is running at --net=host, which is a good idea re RMI anyway
ENV CONSUL_HOST=127.0.0.1:8500

ADD jmeter-server-start.sh.tmpl /

ENV START_SCRIPT=jmeter-server-start.sh

ENV RMI_HOST=0.0.0.0


#CMD  consul-template -reap=true -consul $CONSUL_HOST -template "/$START_SCRIPT.tmpl:/$START_SCRIPT:cat /$START_SCRIPT"
ENTRYPOINT ["consul-template", "-wait", "5s:20s", "-consul", "127.0.0.1", "-template", \
            "/jmeter-server-start.sh.tmpl:/jmeter-server-start.sh:killall java; sh /jmeter-server-start.sh"]

# to run/test:
# docker build -t jmeter . &&  docker run -it --rm --net host -e CONSUL_WAIT="0s" -e CONSUL_HOST=x.x.x.x:8500 jmeter
