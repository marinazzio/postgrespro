FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
ENV PG_MAJOR 10
ENV PG_VERSION PostgresPro 10.1.1
ENV LANG ru_RU.utf8
ENV LC_ALL ru_RU.UTF-8

RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -x \
	&& apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
        ca-certificates locales wget lsb apt-utils language-pack-ru \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
ENV LANG en_US.utf8

RUN sh -c 'echo "deb http://repo.postgrespro.ru/pgpro-10/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgrespro.list' && \
	wget --quiet -O - http://repo.postgrespro.ru/pgpro-10/keys/GPG-KEY-POSTGRESPRO | apt-key add - && \
	apt-get update && \
	apt-get install -y \
            postgrespro-std-10-client postgrespro-std-10-libs postgrespro-std-10-server postgrespro-std-10-contrib libicu-dev

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
VOLUME /var/lib/postgresql/data

#copy dict
# COPY ru-dict/* /usr/share/postgresql/9.6/tsearch_data/
# COPY en-dict/* /usr/share/postgresql/9.6/tsearch_data/

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
