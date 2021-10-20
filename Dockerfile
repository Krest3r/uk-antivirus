FROM ubuntu:20.04 as base

ARG DEBIAN_FRONTEND=noninteractive 
ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Europe/Warsaw 
ARG PIA_PYTHON_VER=3.8


RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 

RUN	apt-get update && \
	apt upgrade -y && \
	apt install -y python$PIA_PYTHON_VER python$PIA_PYTHON_VER-venv bash python3-pip wget tzdata nano curl

RUN apt-get install openssl


####################################################################################################################
# copied from orginal Dockerfile
# https://www.atlantic.net/vps-hosting/how-to-install-clamav-on-ubuntu-20-04-and-scan-for-vulnerabilities/

ENV CLAMAV_VERSION 0.

 #echo "deb http://http.debian.net/debian/ buster main contrib non-free" > /etc/apt/sources.list && \
    #echo "deb http://http.debian.net/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list && \
    #echo "deb http://security.debian.org/ buster/updates main contrib non-free" >> /etc/apt/sources.list && \
RUN    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        build-essential \
        clamav-daemon=${CLAMAV_VERSION}* \
        clamav-freshclam=${CLAMAV_VERSION}* \
        libclamunrar9 \
        wget nano git curl bash \
        openssh-server \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY config/freshclam.conf /etc/clamav

# RUN wget https://database.clamav.net/main.cvd
RUN freshclam

RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf

# web server needs access to the clamd socket
RUN #usermod -a -G clamav uwsgi

COPY config/additional-supervisord.conf /home/vcap/additional-supervisord.conf
RUN cat /home/vcap/additional-supervisord.conf >> /etc/supervisord.conf

COPY config/additional-awslogs.conf /home/vcap/additional-awslogs.conf
RUN cat /home/vcap/additional-awslogs.conf >> /etc/awslogs.conf

COPY config/eicar.ndb.part-a /root/
COPY config/eicar.ndb.part-b /root/


# the contents of this custom virus definition are simply Eicar-Test-Signature:0:*:<literal eicar string in hex>
# and because it contains a literal representation of the eicar string we store it encrypted with a one-time-pad.

RUN mkdir -p /av

COPY ./requirements.in /av/requirements.in
COPY ./requirements.txt /av/requirements.txt

RUN	cd /av && PYTHON3=$(which python$PIA_PYTHON_VER) ; \
    $PYTHON3 -m venv ./venv ; \
	. ./venv/bin/activate ; \
	pip install --upgrade pip ; \
	pip install --upgrade setuptools ; \
	pip install --upgrade wheel ; \
	pip install -r requirements.in && \
    python -c 'a = open("/root/eicar.ndb.part-a", "rb"); b = open("/root/eicar.ndb.part-b", "rb"); c = open("/var/lib/clamav/eicar.ndb", "wb"); c.write(bytes(A^B for A, B in zip(a.read(), b.read()))); c.close()'

COPY ./app /av/app

WORKDIR /av

# Set folders permissions
#RUN	chmod -R 700 /app/venv

# Set files permissions
#RUN find /app/venv -print0 | xargs -0 chmod 500


SHELL ["/bin/bash", "-c"]

COPY ./config.py /av/
COPY ./application.py /av/
COPY ./entrypoint.sh /
RUN chmod 500 /entrypoint.sh

COPY ./config/sshd_config /etc/ssh/
#RUN systemctl enable ssh

ENTRYPOINT ["/entrypoint.sh"]
