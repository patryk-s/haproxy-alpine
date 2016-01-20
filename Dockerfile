FROM alpine:latest

RUN apk update && apk add libssl1.0 pcre && rm -f /var/cache/apk/*

ENV HAPROXY_MAJOR 1.6
ENV HAPROXY_VERSION 1.6.3
ENV HAPROXY_MD5 3362d1e268c78155c2474cb73e7f03f9

RUN buildDeps='curl gcc libc-dev linux-headers pcre-dev openssl-dev make tar' \
	&& set -x \
	&& apk update && apk add $buildDeps && rm -f /var/cache/apk/* \
	&& curl -SL "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" -o haproxy.tar.gz \
	&& echo "${HAPROXY_MD5}  haproxy.tar.gz" | md5sum -c \
	&& mkdir -p /usr/src/haproxy \
	&& tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
	&& rm haproxy.tar.gz \
	&& make -C /usr/src/haproxy \
		TARGET=linux2628 \
		USE_PCRE=1 PCREDIR= \
		USE_OPENSSL=1 \
		USE_ZLIB=1 \
		all \
		install-bin \
	&& mkdir -p /usr/local/etc/haproxy \
	&& cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
	&& rm -rf /usr/src/haproxy \
	&& apk del $buildDeps

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
