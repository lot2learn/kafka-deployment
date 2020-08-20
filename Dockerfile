FROM centos:7

RUN yum install curl which -y && \
    rpm --import https://packages.confluent.io/rpm/5.5/archive.key

ADD confluent.repo /etc/yum.repos.d/confluent.repo

RUN yum install confluent-platform-2.12 -y

ADD connect-distributed.properties /etc/kafka/connect-distributed.properties

RUN yum install java -y

CMD ["/usr/bin/connect-distributed", "/etc/kafka/connect-distributed.properties"]
