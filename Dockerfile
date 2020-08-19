FROM alpine:3.12.0

ENV POSTGRES_VERSION=12.4
ENV DOVECOT_VERSION=2.3.11.3
ENV POSTFIX_VERSION=3.5.6
ENV NGINX_VERSION 1.19.2
ENV DEHYDRATED_VERSION 0.6.5
ENV OPENDKIM_VERSION 2.10.3

RUN apk add --no-cache --update \
    curl \
    libmilter \
    openssl \
    icu \
    libnsl \
    db \
    pcre \
    cyrus-sasl \
    zlib \
    bzip2 \
    coreutils \
    tini \
    supervisor \
    bash \
    perl \
    && apk add --no-cache --virtual .build-deps \
    build-base \
    automake \
    autoconf \
    libtool \
    libmilter-dev \
    openssl-dev \
    icu-dev \
    libnsl-dev \
    db-dev \
    pcre-dev\
    cyrus-sasl-dev \
    zlib-dev \
    bzip2-dev \
    bsd-compat-headers \
    linux-headers \
    && addgroup -S -g 400 dovecot \
    && adduser -D -S -s /sbin/nologin -H -G dovecot -u 400 dovecot \
    && addgroup -S -g 401 dovenull \
    && adduser -D -S -s /sbin/nologin -H -G dovenull -u 401 dovenull \
    && addgroup -S -g 410 postfix \
    && adduser -D -S -s /sbin/nologin -H -G postfix -u 410 postfix \
    && addgroup -S -g 411 postdrop \
    && adduser -D -S -s /sbin/nologin -H -G postdrop -u 411 postdrop \
    && addgroup -S -g 450 vmail \
    && adduser -D -S -s /sbin/nologin -H -G vmail -u 450 vmail \
    && addgroup -S -g 460 nginx \
    && adduser -D -S -s /sbin/nologin -H -G nginx -u 460 nginx \
    && addgroup -S -g 470 opendkim \
    && adduser -D -S -s /sbin/nologin -H -G opendkim -u 470 opendkim \
    && addgroup -S -g 480 postgres \
    && adduser -D -S -s /sbin/nologin -H -G postgres -u 480 postgres \
    && tmpdir="$(mktemp -d)"   \
    && cd "$tmpdir" \
    && curl -L "https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.bz2" -O \
    && tar xvf postgresql-${POSTGRES_VERSION}.tar.bz2 \
    && cd postgresql-${POSTGRES_VERSION} \
    && mkdir build \
    && cd build \
    && ../configure --prefix="/usr/local" --without-readline \
    && make -j16 \
    && make install-strip \
    && cd / \
    && rm -rf "$tmpdir" \
    && tmpdir="$(mktemp -d)"   \
    && cd "$tmpdir" \
    && curl -L "https://www.dovecot.org/releases/$(echo $DOVECOT_VERSION | cut -f 1,2 -d . -)/dovecot-${DOVECOT_VERSION}.tar.gz" -O \
    && tar xvf dovecot-${DOVECOT_VERSION}.tar.gz \
    && cd dovecot-${DOVECOT_VERSION} \
    && ./configure \
    --with-sql=yes \
    --with-pgsql \
    --with-zlib \
    --with-bzlib \
    --with-ssl=openssl \
    && make -j16 \
    && make install \
    && cd / \
    && rm -rf "$tmpdir" \
    && tmpdir="$(mktemp -d)" \
    && cd "$tmpdir" \
    && curl -L "http://cdn.postfix.johnriley.me/mirrors/postfix-release/official/postfix-${POSTFIX_VERSION}.tar.gz" -O \
    && tar xvf postfix-${POSTFIX_VERSION}.tar.gz \
    && cd postfix-${POSTFIX_VERSION} \
    && make makefiles DEBUG="" CCARGS="-O2 -DUSE_SSL -DUSE_TLS -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -DHAS_PGSQL -I/usr/include/openssl -I/usr/include/sasl -I/usr/include -I/usr/local/include" AUXLIBS="-L/usr/lib -L/usr/local/lib -L/usr/lib/openssl -lssl -lcrypto -L/usr/lib/sasl2 -lsasl2 -lz -lm" AUXLIBS_PGSQL="-L/usr/local/lib -lpq" \
    && make -j16 \
    && chmod +x ./postfix-install \
    && ./postfix-install -non-interactive \
    && cd / \
    && rm -rf "$tmpdir" \
    && tmpdir="$(mktemp -d)" \
    && cd "$tmpdir" \
    && curl -L "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O \
    && tar xvf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
    --sbin-path=/usr/local/nginx/nginx \
    --conf-path=/usr/local/nginx/nginx.conf \
    --pid-path=/usr/local/nginx/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --with-stream \
    --with-cc-opt="-g0 -O2" \
    && make -j16 \
    && make install \
    && cd / \
    && rm -rf "$tmpdir" \
    && tmpdir="$(mktemp -d)" \
    && cd "$tmpdir" \
    && curl -L "https://github.com/lukas2511/dehydrated/releases/download/v${DEHYDRATED_VERSION}/dehydrated-${DEHYDRATED_VERSION}.tar.gz" -O \
    && tar xvf dehydrated-${DEHYDRATED_VERSION}.tar.gz \
    && cd dehydrated-${DEHYDRATED_VERSION} \
    && mv dehydrated /usr/local/sbin \
    && cd / \
    && rm -rf "$tmpdir" \
    && tmpdir="$(mktemp -d)" \
    && cd "$tmpdir" \
    && curl -L "https://sourceforge.net/projects/opendkim/files/opendkim-${OPENDKIM_VERSION}.tar.gz/download" -o opendkim.tar.gz \
    && tar xvf opendkim.tar.gz \
    && cd opendkim-${OPENDKIM_VERSION} \
    && curl -L "https://sourceforge.net/p/opendkim/patches/37/attachment/openssl_1.1.0_compat.patch" -O \
    && patch -p1 < openssl_1.1.0_compat.patch \
    && aclocal \
    && autoconf \
    && automake \
    && ./configure \
    --enable-shared \
    --disable-static \
    && CC="-g0 -O2" make -j16 \
    && make install \
    && cd / \
    && rm -rf "$tmpdir" \
    && mkdir -p /var/run/opendkim \
    && chmod 755 /var/run/opendkim \
    && chown -R opendkim:opendkim /var/run/opendkim \
    && apk del .build-deps \
    && ln -s /usr/local/sbin/renew-certs /etc/periodic/daily

COPY dovecot /usr/local/etc/dovecot
COPY postfix /etc/postfix
COPY nginx /usr/local/nginx
COPY dehydrated /etc/dehydrated
COPY supervisord.conf /etc
COPY opendkim /etc/opendkim
COPY scripts /usr/local/sbin

ENTRYPOINT ["tini", "--", "/usr/local/sbin/docker-entrypoint"]

CMD ["/usr/local/sbin/docker-start"]
