FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    git \
    clang \
    make \
    autoconf \
    libtool \
    pkg-config

WORKDIR /src

# Clone libxml2 and checkout v2.11.6 (affected version)
RUN git clone https://gitlab.gnome.org/GNOME/libxml2.git && \
    cd libxml2 && \
    git checkout v2.11.6

WORKDIR /src/libxml2

# flags from https://gitlab.gnome.org/GNOME/libxml2/-/issues/604
ENV CC=clang
ENV CFLAGS="-O0 -g -fsanitize=address -fno-omit-frame-pointer -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION"
ENV LDFLAGS="-fsanitize=address"

# more flags from https://gitlab.gnome.org/GNOME/libxml2/-/issues/604
RUN ./autogen.sh \
        --prefix=/usr \
        --without-iconv \
        --with-icu \
        --without-lzma \
        --without-python \
        --with-xptr-locs \
        --with-zlib && \
    make -j$(nproc) && \
    make install

# add the xml file to reproduce the bug
COPY reproduce_bug.xml /src/reproduce_bug.xml

# xmllint --stream --xinclude --valid
CMD ["/src/libxml2/xmllint", "--stream", "--xinclude", "--valid", "/src/reproduce_bug.xml"]
