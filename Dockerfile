FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=non-interactive

RUN apt-get update && apt-get install -y \
    automake autotools-dev bsdmainutils build-essential ccache git libboost-dev \
    libboost-filesystem-dev libboost-system-dev libboost-test-dev libevent-dev \
    libminiupnpc-dev libnatpmp-dev libsqlite3-dev libtool libzmq3-dev pkg-config \
    python3 systemtap-sdt-dev

RUN git clone -b mattplus https://github.com/Merkleize/bitcoin /bitcoin

WORKDIR /bitcoin

RUN ./autogen.sh
RUN ./configure --without-bdb --with-gui=no
RUN make -j$(nproc)

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=non-interactive

# Only install what we need at runtime
RUN apt-get update && apt-get install -y \
    libminiupnpc-dev libnatpmp-dev libevent-dev libzmq3-dev libsqlite3-dev

COPY --from=builder /bitcoin/src/bitcoind /usr/local/bin/
COPY --from=builder /bitcoin/src/bitcoin-cli /usr/local/bin/

EXPOSE 18443 18444

VOLUME /root/.bitcoin

ENTRYPOINT ["bitcoind", "-printtoconsole"]