FROM docker.elastic.co/elasticsearch/elasticsearch:6.3.1

USER root

ENV JQ_VERSION 1.5
ENV JQ_SHA256 c6b3a7d7d3e7b70c6f51b706a3b90bd01833846c54d32ca32f0027f00226ff6d
RUN cd /tmp \
    && curl -o /usr/bin/jq -SL "https://github.com/stedolan/jq/releases/download/jq-$JQ_VERSION/jq-linux64" \
    && echo "$JQ_SHA256  /usr/bin/jq" | sha256sum -c - \
    && chmod +x /usr/bin/jq \
    && yum install -y net-tools bind-utils

# ADD elasticsearch.yml /usr/share/elasticsearch/config/
# RUN chown elasticsearch:elasticsearch /usr/share/elasticsearch/config/elasticsearch.yml

USER elasticsearch

RUN bin/elasticsearch-plugin install -b repository-hdfs
RUN bin/elasticsearch-plugin install -b http://es-learn-to-rank.labs.o19s.com/ltr-1.1.0-es6.3.1.zip
RUN bin/elasticsearch-plugin install analysis-smartcn
