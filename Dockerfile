FROM centos:7

RUN yum install -y \
        automake        \
        autoconf        \
        bison           \
        bzip2           \
        cmake           \
        flex            \
        gcc             \
        gcc-c++         \
        git-core        \
        glibc-static    \
        libtool         \
        make            \
        openssl-devel   \
        pam-devel       \
        readline-devel  \
        ruby            \
        rubygem-rake    \
        ruby-devel      \
        zlib-devel

# haconiwa
RUN cd \
    && wget https://github.com/haconiwa/haconiwa/releases/download/v0.5.1/haconiwa-v0.5.1.x86_64-pc-linux-gnu.tgz \
    && tar xzf haconiwa-v0.5.1.x86_64-pc-linux-gnu.tgz \
    && install hacorb hacoirb haconiwa /usr/local/bin

# libuv (h2o and wslay dependency)
RUN git clone --recursive https://github.com/libuv/libuv ~/src/github.com/libuv/libuv \
    && cd ~/src/github.com/libuv/libuv \
    && git checkout v1.7.5 \
    && sh autogen.sh  \
    && ./configure  \
    && make \
    && make install

# wslay (h2o dependency)
RUN git clone --recursive https://github.com/tatsuhiro-t/wslay ~/src/github.com/tatsuhiro-t/wslay \
    && cd ~/src/github.com/tatsuhiro-t/wslay \
    && autoreconf -i \
    && automake \
    && autoconf \
    && sed -r -i 's/^(SUBDIRS = lib tests examples) doc.*/\1/' Makefile.in \
    && ./configure \
    && make \
    && make install

# h2o
RUN git clone https://github.com/h2o/h2o.git ~/src/github.com/h2o/h2o \
    && cd ~/src/github.com/h2o/h2o \
    && git checkout v2.0.4  \
    && cmake -DWITH_BUNDLED_SSL=on -DWITH_MRUBY=on . \
    && make \
    && make install

WORKDIR /var/server
COPY h2o.conf /var/server
COPY server.rb /var/server
EXPOSE 80
CMD ["h2o", "--mode=master", "-c", "h2o.conf"]
