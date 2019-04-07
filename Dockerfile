FROM frolvlad/alpine-glibc AS glibc

FROM frolvlad/alpine-gxx

# Install glibc as we use precompiled Swift binaries linked against glibc
COPY --from=glibc / /

# Install Swift dependencies
# XXX: These are ugly hacks mixing glibc and musl libc toolchains.
#      It is a pure luck that Swift manages to work in this environment!
RUN cd /tmp && \
    apk add --no-cache libunwind-dev icu-static binutils-gold libuuid && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates tar xz && \
    wget "http://mirrors.kernel.org/ubuntu/pool/main/g/gcc-8/libstdc++6_8-20180414-1ubuntu2_amd64.deb" -O "libstdc++6.deb" && \
    ar x libstdc++6.deb && \
    tar --extract --xz --file="data.tar.xz" --strip=4 --directory=/usr/glibc-compat/lib/ ./usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.25 && \
    ln -s libstdc++.so.6.0.25 /usr/glibc-compat/lib/libstdc++.so.6 && \
    wget "https://mirrors.kernel.org/ubuntu/pool/main/n/ncurses/libtinfo5_6.1-1ubuntu1_amd64.deb" -O "libtinfo.deb" && \
    ar x libtinfo.deb && \
    tar --extract --xz --file="data.tar.xz" --strip=3 --directory=/usr/glibc-compat/lib/ ./lib/x86_64-linux-gnu/libtinfo.so.5.9 && \
    ln -s libtinfo.so.5.9 /usr/glibc-compat/lib/libtinfo.so.5 && \
    wget "http://mirrors.kernel.org/ubuntu/pool/main/libe/libedit/libedit2_3.1-20170329-1_amd64.deb" -O "libedit2.deb" && \
    ar x libedit2.deb && \
    tar --extract --xz --file="data.tar.xz" --strip=4 --directory=/usr/glibc-compat/lib/ ./usr/lib/x86_64-linux-gnu/libedit.so.2.0.56 && \
    ln -s libedit.so.2.0.56 /usr/glibc-compat/lib/libedit.so.2 && \
    apk del .build-dependencies && \
    rm /tmp/*

WORKDIR /opt/swift

# Install Swift
RUN export SWIFT_VERSION=5.0 && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates gnupg && \
    echo \
        "-----BEGIN PGP PUBLIC KEY BLOCK-----\
        Version: GnuPG v2\
        \
        mQINBFyUJhwBEADDBN6jVDScsgzfQDxSQga0Og4O3N/nIquwi/DGOgsAsTMWcVA1\
        gmRJb792vWa9CmnHILl3ap8zObDSbcXg90nx+eCzWJjG+Ud5c7xuam96NR8ntKmU\
        8+BbH/dp8zc9WJB37TiWcaLsddrn58zfm7Ml6P9M48WAeRJX8nxVBTw1SjXJurW0\
        Ab8LOgfb60I09Skq72Ud7HaYJOG03iNTf6qLlF977OQsHCb21BnKSAmJqapUS96/\
        VOngz7TBzYz4rntfetb8hg28WtUl1s5BQzWaFunkP03b8mPh3PL1SZxutwViVWBu\
        hf9kJtx/MLb79fnuJEOus1FvDqJdpd83H+XmXMIDYWgcBIBVrLT5HDtRerjF178H\
        okb1F+gboGIqhnx25xTPIYctSHPgJRScZp4WKrqQLKswAmSL4YJXnkXSff05l4gE\
        WXQpEMLBZa46qmu8lj8HfoZSbP9lfvEtZ6A+Q3sfh3gjYPv7e6n37x22tSgvyzCb\
        jHU1pA2rv10AHK7EIeEQElN+zCyAbmKuhPBiCyxDFg5Dx3xNkYwg9szBJ0KleVD4\
        +Y3PZJ4N+u+SSATYnHGtmzvkhiNtqJCCwuaqY+jjVObzzqvLLtGjtjxNUWi2X4He\
        q+r2fubjCOW14UnQ06qfr3mVUSmuLSKs8BD8qTGuqlgcenGsY0bk0qUPcwARAQAB\
        tD5Td2lmdCA1LnggUmVsZWFzZSBTaWduaW5nIEtleSA8c3dpZnQtaW5mcmFzdHJ1\
        Y3R1cmVAc3dpZnQub3JnPokCPQQTAQoAJwUCXJQmHAIbAwUJA8JnAAULCQgHAwUV\
        CgkICwUWAgMBAAIeAQIXgAAKCRCSXMHM7T0VYSm3EACUtuxMfTmGexA2xBvGhKQ+\
        bi3kRMBj+9BoSkVV11gDvumurldXRoKsIIxEdrD4xjagSNiVd7zj3L9wANu6+YgP\
        HgBq8sUMXwsyXdL16jNC28qVqKF4jZxwmI9t6nVpQOSxGfBxdXmIhTxDDXFo4JMT\
        uKx67BaP1GzZ+BKvxm09xChIJ5xh7x8/bsZ7HlXqc++ARn0Lh9d5CISUKE1PPnMN\
        KyRUNt4X/qj7zJHDoAihufPKodvvXPsVAIpfCJZm7XB5WvP63IvQaFW/cX5wineR\
        FZY/BKS+tsJt45jJ9c/Ofzqrr//stCz4a44fYvpqaxIqTLr4CpNH3WBIM0RBQqJj\
        35jJvdrNIuueby7GN3afRcvZIQBkbMkwZrW1iT8eah3EQDiXszbi7GkbXuOxQOn/\
        n8KJJvTJU7wAyH4WLvvWLFUm0oyHjIW4K9vSUM+x74WRuKxVikM6FAJ7uXsYtZ3Z\
        lgL2hNlbMwpB+wxvA9isT3dSyzAtZmXpomOLuQTETtm4tSpt8XnF3eCsAKHSWqrA\
        /zknqizKeBTPprqibixfO3dwUzFhUu3tkhxznIN3eEUrDMPxNrxObqJf1I4ySUYe\
        vc6fqBG86SJ2yjN3IMJm5Y/z58QQUmSOweL9xQSr1hdcCxBtmLSjAlVzJMkpQ/TW\
        xXPfHp4mZnRMLsGyO3eYrA==\
        =l2j3\
        -----END PGP PUBLIC KEY BLOCK-----" | sed 's/        /\n/g' | gpg --import - && \
    wget -O swift.tar.gz "https://swift.org/builds/swift-$SWIFT_VERSION-release/ubuntu1804/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz" && \
    wget -O swift.tar.gz.sig "https://swift.org/builds/swift-$SWIFT_VERSION-release/ubuntu1804/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz.sig" && \
    gpg --verify swift.tar.gz.sig && \
    tar --extract --gzip --file=swift.tar.gz --strip=1 && \
    ln -s /opt/swift/usr/bin/swift* /usr/local/bin/ && \
    rm -r swift.tar.gz* && \
    apk del .build-dependencies && \
    \
    strip -s ./usr/bin/* && \
    rm -rv \
        ./usr/bin/lldb* \
        ./usr/bin/llvm* \
        ./usr/lib/liblldb* \
        ./usr/lib/lldb \
        ./usr/lib/clang \
        ./usr/lib/python2.7 && \
    find ./ -name '*.so*' -exec strip -s {} +

# Fix static compilation issue: https://bugs.swift.org/browse/SR-10328
COPY static-executable-args.lnk ./usr/lib/swift_static/linux/static-executable-args.lnk

# Test the hacks by compiling and running Hello World application
RUN echo 'print("Hello!")' > qq.swift && \
    swiftc -target x86_64-alpine-linux-musl -lunwind qq.swift && ./qq && \
    swiftc -static-executable -target x86_64-alpine-linux-musl qq.swift && ./qq && \
    rm ./qq
