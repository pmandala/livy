#
FROM oraclelinux:7-slim

ENV PIP_ROOT_USER_ACTION=ignore

# SPARK
ENV SPARK_VERSION=3.5.5
ENV HADOOP_VERSION=3.4.1
ENV SPARK_HOME="/opt/spark"
ENV HADOOP_HOME="/opt/hadoop"
ENV HADOOP_CONF_DIR="/opt/hadoop/etc/hadoop/"
#ENV SPARK_MASTER_HOST=spark-master
#ENV SPARK_MASTER_PORT=7077
#ENV SPARK_MASTER="spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}"
#ENV SPARK_MASTER_WEBUI_PORT=8080
#ENV SPARK_WORKER_WEBUI_PORT=8081

# LIVY
ENV LIVY_PATH="0.8.0-incubating"
ENV LIVY_VERSION="0.8.0-incubating_2.12"
ENV LIVY_HOME="/opt/livy"

# JDK 17 & Python 3.8
COPY jdk-17.0.14_linux-x64_bin.rpm /tmp
RUN yum update -y && \
    yum install -y oracle-softwarecollection-release-el7 && \
    yum install -y scl-utils rh-python38 && \
    scl enable rh-python38 bash && \
    yum install -y python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy \
	rsync vi curl wget unzip procps ca-certificates tar && \
    yum -y localinstall /tmp/jdk-17.0.14_linux-x64_bin.rpm && \
    yum -y clean all && \
    rm  -rf /var/cache/yum && \
    mkdir -p ${HADOOP_HOME}  ${SPARK_HOME} 

WORKDIR ${SPARK_HOME}

# Download and install Hadoop
COPY hadoop-${HADOOP_VERSION}.tar.gz .
# RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -P /tmp/ && \
RUN tar -xvzf ./hadoop-${HADOOP_VERSION}.tar.gz --directory /opt/hadoop --strip-components 1 && \
         rm -rf ./hadoop-${HADOOP_VERSION}.tar.gz
ENV PATH="$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:"


# Download and install Spark
COPY spark-${SPARK_VERSION}-bin-hadoop3.tgz .
# RUN curl https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -o spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
RUN tar xvzf ./spark-${SPARK_VERSION}-bin-hadoop3.tgz --directory /opt/spark --strip-components 1 && \
    rm -rf ./spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    chmod u+x $SPARK_HOME/sbin/* && \
    chmod u+x $SPARK_HOME/bin/*
COPY spark/* "$SPARK_HOME/conf"
ENV PATH="$SPARK_HOME/sbin:$SPARK_HOME/bin:${PATH}"

# LIVY
RUN curl https://downloads.apache.org/incubator/livy/${LIVY_PATH}/apache-livy-${LIVY_VERSION}-bin.zip -o /tmp/apache-livy-${LIVY_VERSION}-bin.zip && \
        unzip /tmp/apache-livy-${LIVY_VERSION}-bin.zip -d /opt && \
        mv /opt/apache-livy-${LIVY_VERSION}-bin ${LIVY_HOME} && \
        rm /tmp/apache-livy-${LIVY_VERSION}-bin.zip
COPY livy/* "$LIVY_HOME/conf"
ENV PATH="${LIVY_HOME}/bin:${PATH}"

# Install python deps
COPY requirements.txt .
RUN pip3 install -r requirements.txt

ENV PYSPARK_PYTHON python3
ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

#
RUN mkdir -p /data/inputs /data/outputs /logs/livy

# entrypoint script
COPY start_livy.sh .
RUN chmod u+x ./start_livy.sh
ENTRYPOINT ["./start_livy.sh"]
CMD [ "bash" ]

# 
EXPOSE 8998


