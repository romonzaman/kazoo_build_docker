FROM --platform=linux/amd64 debian:bullseye
ARG BUILD_DATE="20250521"

WORKDIR /root/

RUN apt-get update && apt-get upgrade -y

# Install dependency

RUN apt-get install -y sudo && apt-get install -y\
	build-essential libxslt-dev \
	zip unzip expat zlib1g-dev libssl-dev curl \
	libncurses5-dev git-core libexpat1-dev autoconf

RUN apt-get install -y git 

# Complie openssl 1.0.2

RUN git clone https://github.com/openssl/openssl.git --branch OpenSSL_1_0_2-stable \
	&& cd openssl/ \
	&& mkdir __result \
	&& ./config --prefix="/root/openssl" shared zlib -fPIC \
	&& make depend \
	&& make \
	&& make install INSTALL_PREFIX="/root/openssl/__result"

# Compile erlang

RUN apt-get install -y gcc-9 libc6-dev procps

RUN curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl \
	&& chmod +x kerl \
	&& mv kerl /usr/bin \
	&& export KERL_CONFIGURE_OPTIONS="--enable-debug --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --with-ssl=/root/openssl/__result/root/openssl/" \
	&& env CXX=gcc-9 CC=gcc-9 kerl build 19.3.6.13 19.3.6.13 \
	&& kerl install 19.3.6.13 /usr/local/otp-19.3.6.13 \
	&& . /usr/local/otp-19.3.6.13/activate

# Compile elixir

RUN curl -sSL https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s \
	&& . /usr/local/otp-19.3.6.13/activate \
	&& /root/.kiex/bin/kiex install 1.7.4 \
	&& /root/.kiex/bin/kiex use 1.7.4-19 \
	&& /root/.kiex/bin/kiex default 1.7.4-19 \
	&& echo 'test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"'  >> .bashrc

# Create make script

RUN apt-get install wget

RUN apt-get install -y python

WORKDIR /app

RUN echo '#!/bin/bash \n\
	. /usr/local/otp-19.3.6.13/activate \n\
	export PATH=$PATH:/root/.kiex/elixirs/elixir-1.7.4-19/bin/ \n\
	make $1 $2 \n\
	if [[ "$1" == "install" ]]; then \n\
	rm -rf /app/build \n\
	mkdir -p /app/build/ \n\
	mv /opt/kazoo/* /app/build/ \n\
	fi '> /build.sh
RUN chmod +x /build.sh

RUN apt-get install -y locales && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
	echo "LANG=en_US.UTF-8" > /etc/default/locale
ENV LANG en_US.UTF-8

RUN mkdir -p /usr/local/lib/erlang/ && \
	ln -s /usr/local/otp-19.3.6.13/erts-8.3.5.7 /usr/local/lib/erlang/ && \
	ln -s  /usr/local/otp-19.3.6.13/lib /usr/local/lib/erlang/

RUN apt-get update -y && \
	apt-get install -y curl mlocate nano

ENTRYPOINT ["/build.sh"]
