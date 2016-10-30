FROM debian:jessie
MAINTAINER Chad Schmutzer <schmutze@amazon.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update && \
  apt-get -y -q install rsyslog python-setuptools python-pip python-pip-whl curl && \
  rm -rf /var/cache/apt

RUN curl -sL https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -o awslogs-agent-setup.py

RUN sed -i "s/#\$ModLoad imtcp/\$ModLoad imtcp/" /etc/rsyslog.conf && \
  sed -i "s/#\$InputTCPServerRun 514/\$InputTCPServerRun 514/" /etc/rsyslog.conf

COPY awslogs.conf awslogs.conf
RUN python ./awslogs-agent-setup.py -n -r eu-west-1 -c /awslogs.conf

RUN pip install supervisor
COPY supervisord.conf /usr/local/etc/supervisord.conf

EXPOSE 514/tcp
CMD ["/usr/local/bin/supervisord"]
