1. [https://console.cloud.google.com/](vscode-file://vscode-app/c:/Users/User/AppData/Local/Programs/Microsoft%20VS%20Code/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html)
2. `Active Cloud Shell` (Top right)'

##### Reserve a static external IP
```bash
gcloud compute addresses create qbft-ip --region=us-central1
```
##### Create the VM (Debian 11)
```bash
gcloud compute instances create qbft-node \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --address=qbft-ip \
  --tags=qbft-node \
  --scopes=https://www.googleapis.com/auth/cloud-platform
```
##### Open all QBFT-related ports in firewall
```bash
TCP 30300–30304 (p2p)  
TCP 22000–22004 (HTTP-RPC)  
TCP 32000–32004 (WS-RPC, optional)  
TCP 25000 (Explorer UI)

gcloud compute firewall-rules create qbft-fw \
  --network=default \
  --action=ALLOW \
  --rules=tcp:30300-30304,tcp:22000-22004,tcp:32000-32004,tcp:25000 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=qbft-node \
  --description="Allow QBFT p2p + RPC + explorer ports"
```
##### SSH in & install Docker & Docker-Compose
```bash
gcloud compute ssh qbft-node --zone=us-central1-a

# on the VM:
sudo apt update && sudo apt install -y docker.io docker-compose git
sudo usermod -aG docker $USER
exit
```
##### Clone QBFT-Network repo (Re-ssh to pick up the new group)
```bash
gcloud compute ssh qbft-node --zone=us-central1-a

git clone https://github.com/FramedStone/GoQuorum-QBFT-5-Nodes
cd GoQuorum-QBFT-5-Nodes
```
##### Configure `.env.production`
```bash
cp .env.template .env.production
```
##### Modify `docker-compose.yaml`
```bash
env_file --> .env.production
volumes --> remove .env.production directory
```
##### Launch the network
```bash
docker-compose up -d
```
##### Verify it's up
```bash
# From Cloud Shell, grab the VM’s external IP:
gcloud compute instances describe qbft-node \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

# Test the HTTP-RPC on port 22000:
curl http://<VM_EXTERNAL_IP>:22000 \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```
