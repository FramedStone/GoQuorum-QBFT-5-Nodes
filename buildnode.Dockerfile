# official quorum docker image
FROM quorumengineering/quorum:latest

ARG NODE

WORKDIR /QBFT-Network

# node keystore directory 
RUN mkdir -p /data/keystore 

COPY artifacts/goQuorum/genesis.json ./data/genesis.json
COPY artifacts/goQuorum/static-nodes.json ./data/static-nodes.json

COPY artifacts/${NODE}/account* ./data/keystore/
COPY artifacts/${NODE}/address ./data/
COPY artifacts/${NODE}/nodekey* ./data/

RUN geth --datadir ./data init ./data/genesis.json

ENTRYPOINT ["geth"]