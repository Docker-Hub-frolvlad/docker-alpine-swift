[![Docker Stars](https://img.shields.io/docker/stars/frolvlad/alpine-swift.svg?style=flat-square)](https://hub.docker.com/r/frolvlad/alpine-swift/)
[![Docker Pulls](https://img.shields.io/docker/pulls/frolvlad/alpine-swift.svg?style=flat-square)](https://hub.docker.com/r/frolvlad/alpine-swift/)


Swift Docker image
==================

WARNING: This image is experimental and based on a [glibc hack](https://github.com/gliderlabs/docker-alpine/issues/11)!

This image is based on Alpine Linux image, which is only a 5MB image, and contains
[Swift compiler](https://swift.org/).

Download size of this image is only:

[![](https://images.microbadger.com/badges/image/frolvlad/alpine-swift.svg)](http://microbadger.com/images/frolvlad/alpine-swift "Get your own image badge on microbadger.com")

Usage Example
-------------

```bash
$ echo 'print("Hello World")' > qq.c
$ docker run --rm -v "$(pwd):/tmp" frolvlad/alpine-swift swiftc -static-executable -target x86_64-alpine-linux-musl /tmp/qq.swift
```

Once you have run these commands you will have `qq` executable in your current directory and if you
execute it, you will get printed 'Hello World'!
