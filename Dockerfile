FROM sdhibit/rpi-raspbian
MAINTAINER MonX <https://github.com/MonXBZH/>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
ENV SUBSONIC_VERSION 6.1.5

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
 apt-get update && \
 apt-get install --no-install-recommends -qy wget ffmpeg lame locales && \
 apt-get clean

#Download & Install Java 8 arm hard float from Oracle
RUN mkdir -p /opt/jdk1.8.0 && \
 wget -O /tmp/jdk1.8.0.tar.gz \
 --no-cookies --no-check-certificate \
 --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
 "http://download.oracle.com/otn-pub/java/jdk/8u6-b23/jdk-8u6-linux-arm-vfp-hflt.tar.gz" && \
 tar zxvf /tmp/jdk1.8.0.tar.gz -C /opt/jdk1.8.0 --strip-components 1 && \
 rm /tmp/jdk1.8.0.tar.gz && \
 update-alternatives --install "/usr/bin/java" "java" "/opt/jdk1.8.0/bin/java" 1 && \
 update-alternatives --set java /opt/jdk1.8.0/bin/java

ENV JAVA_HOME /opt/jdk1.8.0
ENV PATH $PATH:$JAVA_HOME/bin

ADD ./startup.sh /usr/share/subsonic/startup.sh

RUN useradd --home /var/subsonic -M -K UID_MIN=10000 -K GID_MIN=10000 -U subsonic && \
 mkdir -p /var/subsonic/transcode && \
 chown -R subsonic:subsonic /var/subsonic && \
 chmod -R 0770 /var/subsonic && \
 chown -R subsonic:subsonic /usr/share/subsonic && \
 chmod +x /usr/share/subsonic/startup.sh

#Download & Install Subsonic Standalone
RUN wget -P /tmp/ "https://s3-eu-west-1.amazonaws.com/subsonic-public/download/subsonic-$SUBSONIC_VERSION-standalone.tar.gz" && \
 tar zxvf /tmp/subsonic-$SUBSONIC_VERSION-standalone.tar.gz -C /usr/share/subsonic && \
 rm -rf /tmp/subsonic-$SUBSONIC_VERSION-standalone.tar.gz

#Subsonic Web Port
EXPOSE 4040
#DLNA Discovery Port
EXPOSE 1900/udp

VOLUME ["/var/subsonic", "/var/music"]

USER subsonic

CMD []
ENTRYPOINT ["/usr/share/subsonic/startup.sh"]
