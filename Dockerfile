ARG TAG
ARG DEBIAN_FRONTEND

FROM httpd:${TAG}

ENV DEBIAN_FRONTEND=noninteractive \
	APP_ROOT=/home/dockerd/code \
	FILES_DIR=/mnt/files \
	APACHE_PRESET=html \
	APACHE_MPM=event

RUN set -ex; \
	deluser www-data; \
	useradd -r -M -d $HTTPD_PREFIX -s /sbin/nologin -U apache && \
	passwd -d apache; \
	useradd -r -u 1000 -s /bin/bash -G apache,sudo -U dockerd; \
	sed -i '/^dockerd/s/!/*/' /etc/shadow; \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		liburi-encode-perl \
		make \
		nghttp2 \
		sudo \
		wget; \
	# https://github.com/dockerd-io/apache/issues/1
	mkdir -p \
		${APP_ROOT} \
		$FILES_DIR \
		$HTTPD_PREFIX/conf/conf.d && \
	chown -R dockerd:dockerd \
		${APP_ROOT} \
		$FILES_DIR && \
	chown -R apache:apache $HTTPD_PREFIX; \
	rm -f $HTTPD_PREFIX/logs/httpd.pid; \
	gote=https://github.com/gote-ninja/core/releases/download/0.1a/gote-ubuntu-amd64-latest.tar.gz; \
	wget -qO- $gote | tar xz -C /usr/local/bin && \
	chown -R dockerd:dockerd /usr/local/bin/gote && \
	chmod 755 /usr/local/bin/gote; \
	echo "find ${APP_ROOT} $FILES_DIR -maxdepth 0 -uid 0 -type d -exec chown dockerd:dockerd {} +" > /usr/local/bin/init_volumes; \
	chmod +x /usr/local/bin/init_volumes; \
	{ \
		echo 'dockerd ALL=(ALL) NOPASSWD:ALL'; \
	} | tee /etc/sudoers.d/dockerd; \
	apt-get --purge -y autoremove && \
	apt-get -y clean; \
	rm -rf \
		/var/cache/apt/* \
		/usr/share/doc/*

WORKDIR ${APP_ROOT}

COPY bin /usr/local/bin
COPY templates /etc/gote
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]
