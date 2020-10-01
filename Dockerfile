FROM --platform=${BUILDPLATFORM:-linux/amd64} debian:buster as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

WORKDIR /tmp
RUN apt-get update && apt-get install -yq make gcc gettext autopoint bison libtool automake pkg-config
ADD https://github.com/karelzak/util-linux/archive/v2.34.tar.gz .
RUN tar -xf v2.34.tar.gz && mv util-linux-2.34 util-linux
RUN cd util-linux && ./autogen.sh && ./configure && make LDFLAGS="--static" nsenter

FROM --platform=${TARGETPLATFORM:-linux/amd64} scratch
COPY --from=builder /tmp/util-linux/nsenter /
ENTRYPOINT ["/nsenter", "--all", "--target=1", "--", "su", "-"]
