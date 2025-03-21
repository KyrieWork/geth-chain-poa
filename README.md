# POA Network 私有链

!!! 本项目中的私钥仅用于测试！

这是一个基于以太坊的私有链项目，使用 PoA (Proof of Authority) 共识机制。

## 启动(完成配置后)

```bash
cd blockscout/docker-compose
docker-compose down && docker-compose up -d
```

## 创世区块配置

创世区块配置文件 `genesis.json` 包含以下重要配置：

```json
{
  "config": {
    "chainId": 243522,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "clique": {
      "period": 5,
      "epoch": 30000
    }
  },
  "difficulty": "0x1",
  "gasLimit": "0x1C9C380",
  "extradata": "0x000000000000000000000000000000000000000000000000000000000000000091321c50FEE277c97eb3e0D333308b4f2C2ff8240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {
    "0x91321c50FEE277c97eb3e0D333308b4f2C2ff824": {
      "balance": "1000000000000000000000000"
    }
  }
}
```

## 创建账户

```bash
docker run --rm -v $(pwd)/node1:/root/.ethereum -v $(pwd)/pwd.text:/root/pwd.text ethereum/client-go:v1.13.15 account new --password /root/pwd.text
```

### 重要参数说明

- Chain ID: 243522
- 初始账户: 0x1C248B83AA31C7Cf0582582185C495cA48d606C3
- 初始余额: 1,000,000 ETH
- Gas Limit: 30,000,000
- 共识机制: PoA (Proof of Authority)

## 环境要求

- Docker
- 至少 4GB 可用内存
- 至少 10GB 可用磁盘空间

## 快速开始

### 1. 初始化创世区块

首先，删除现有的 node 目录（如果存在）：

```bash
rm -rf node1/geth
```

然后，使用 Docker 初始化创世区块：

```bash
docker run --rm -v $(pwd)/node1:/root/.ethereum -v $(pwd)/genesis.json:/root/genesis.json ethereum/client-go:v1.13.15 init /root/genesis.json
```

### 2. 启动节点

启动 Geth 节点并启用 HTTP-RPC 接口：

```bash
docker run --rm -v $(pwd)/node1:/root/.ethereum -v $(pwd)/pwd.text:/root/pwd.text -p 8545:8545 ethereum/client-go:v1.13.15 \
  --http \
  --http.addr "0.0.0.0" \
  --ws --ws.addr 0.0.0.0 --ws.origins "*" \
  --http.port 8545 \
  --http.corsdomain "*" \
  --http.api "eth,net,web3,personal,clique,admin,miner" \
  --allow-insecure-unlock \
  --mine \
  --miner.etherbase "0x91321c50FEE277c97eb3e0D333308b4f2C2ff824" \
  --unlock "0x91321c50FEE277c97eb3e0D333308b4f2C2ff824" \
  --password /root/pwd.text \
  --ipcdisable \
  --networkid 243522 \
  --verbosity 4
```

### 3. 连接到网络

#### 使用 MetaMask

1. 打开 MetaMask
2. 点击网络下拉菜单
3. 选择"添加网络"
4. 填写以下信息：
   - 网络名称：POA Network
   - RPC URL：`http://localhost:8545`
   - Chain ID：243522
   - 货币符号：ETH
   - 区块浏览器 URL：（可选）

### 4. 验证连接

使用 curl 测试连接：

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' -H "Content-Type: application/json" http://localhost:8545
```

## 常用操作

### 查看当前区块的签名者

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"clique_getSigners","params":["latest"],"id":1}' -H "Content-Type: application/json" http://localhost:8545
```

### 查看指定区块的签名者

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"clique_getSignersAtHash","params":["0x0000000000000000000000000000000000000000000000000000000000000000"],"id":1}' -H "Content-Type: application/json" http://localhost:8545
```

### 查看签名者状态

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"clique_status","params":[],"id":1}' -H "Content-Type: application/json" http://localhost:8545
```

### 添加新的签名者

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"clique_propose","params":["0x1C248B83AA31C7Cf0582582185C495cA48d606C3", true],"id":1}' -H "Content-Type: application/json" http://localhost:8545
```

### 移除签名者

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"clique_propose","params":["0x1C248B83AA31C7Cf0582582185C495cA48d606C3", false],"id":1}' -H "Content-Type: application/json" http://localhost:8545
```

### 查看当前提案

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"clique_proposals","params":[],"id":1}' -H "Content-Type: application/json" http://localhost:8545
```

### 丢弃提案

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"clique_discard","params":["0x1C248B83AA31C7Cf0582582185C495cA48d606C3"],"id":1}' -H "Content-Type: application/json" http://localhost:8545
```

## 注意事项

1. 确保 Docker 服务正在运行
2. 确保端口 8545 未被占用
3. 节点启动后需要等待一段时间才能开始出块
4. 创世账户（0x1C248B83AA31C7Cf0582582185C495cA48d606C3）拥有初始的 1,000,000 ETH
5. 在 PoA 网络中，不需要手动开始/停止挖矿，系统会自动按照配置的出块时间出块
6. 如果遇到 API 方法不可用的错误，请确保在启动节点时使用了正确的 API 参数（--http.api）
7. 在 PoA 网络中，只有被授权的签名者才能出块
8. 启动节点时必须使用 --mine 和 --miner.etherbase 参数，并解锁账户
