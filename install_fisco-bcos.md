# 1. FISCO BCOS区块链操作手册

[FISCO-BCOS Manual](README_EN.md)

如果有源码和机器依赖已经安装好了，可以直接从第二章开始

## 1.1. 第一章 部署FISCO BCOS环境

本章主要介绍FISCO BCOS区块链环境的部署。包括机器配置，部署软件环境和编译源码。

### 1.1.1. 机器配置

| 配置   | 最低配置   | 推荐配置                                 |
| ---- | ------ | ------------------------------------ |
| CPU  | 1.5GHz | 2.4GHz                               |
| 内存   | 1GB    | 4GB                                  |
| 核心   | 2核     | 4核                                   |
| 带宽   | 1Mb    | 5Mb                                  |
| 操作系统 |        | CentOS （7.2  64位）或Ubuntu（16.04  64位） |

### 1.1.2. 部署软件环境

#### 1.1.2.1. 安装依赖包

##### 1.1.2.1.1. Centos安装

```shell
#安装依赖包
sudo yum install -y git openssl openssl-devel deltarpm cmake3 gcc-c++
#安装nodejs
sudo yum install -y nodejs
sudo npm install -g cnpm --registry=https://registry.npm.taobao.org
sudo cnpm install -g babel-cli babel-preset-es2017 ethereum-console
echo '{ "presets": ["es2017"] }' > ~/.babelrc
```
##### 1.1.2.1.2. Ubuntu安装
```shell
#安装依赖包
sudo apt-get -y install git openssl libssl-dev libkrb5-dev cmake
#安装nodejs(注意： nodejs需要大于6以上的版本,ubuntu上面apt-get安装的默认版本为4.x版本,需要自己升级)
sudo apt-get -y install nodejs-legacy
sudo apt-get -y install npm
sudo npm install -g secp256k1
sudo npm install -g cnpm --registry=https://registry.npm.taobao.org
sudo cnpm install -g babel-cli babel-preset-es2017 ethereum-console
echo '{ "presets": ["es2017"] }' > ~/.babelrc
```

#### 1.1.2.2. 安装FISCO BCOS的智能合约编译器

> 下载对应平台的solidity编译器, 直接下载后放入系统目录下。

```shell
[ubuntu]：
    wget https://github.com/FISCO-BCOS/fisco-solc/raw/master/fisco-solc-ubuntu
    sudo cp fisco-solc-ubuntu  /usr/bin/fisco-solc
    sudo chmod +x /usr/bin/fisco-solc
    
    
[centos]：
    wget https://github.com/FISCO-BCOS/fisco-solc/raw/master/fisco-solc-centos
    sudo cp fisco-solc-centos  /usr/bin/fisco-solc
    sudo chmod +x /usr/bin/fisco-solc
```

### 1.1.3. 编译源码

#### 1.1.3.1. 获取源码

> 假定在/mydata/下获取源码：

```shell
#生成mydata目录
sudo mkdir -p /mydata
sudo chmod 777 /mydata
cd /mydata

#clone源码
git clone https://github.com/FISCO-BCOS/FISCO-BCOS.git

#切换到源码根目录
cd FISCO-BCOS 
```

源码目录说明请参考<u>附录：12.1 源码目录结构说明</u>

#### 1.1.3.2. 安装编译依赖

> 根目录下执行（若执行出错，请参考常见问题1）：

```shell
chmod +x scripts/install_deps.sh
./scripts/install_deps.sh
```

#### 1.1.3.3. 编译

```shell
mkdir -p build
cd build/

[Centos] 
cmake3 -DEVMJIT=OFF -DTESTS=OFF -DMINIUPNPC=OFF ..  #注意命令末尾的..
[Ubuntu] 
cmake  -DEVMJIT=OFF -DTESTS=OFF -DMINIUPNPC=OFF ..  #注意命令末尾的..

make
```

> 若编译成功，则生成build/eth/fisco-bcos。

#### 1.1.3.4. 安装

```shell
sudo make install
```
<h1>以上步骤用编译好的fisco-bcos文件可以跳过。如果是按照以上步骤编译的，不需要执行1.1.3.5</h1>
#### 1.1.3.5. 复制可执行文件到/usr/bin

solc fisco-solc  fisco-bcos共三个文件
sudo cp bins/* /usr/bin
## 1.2. 第二章 准备链环境
FISCO-BCOS网络采用面向CA的准入机制，保障信息保密性、认证性、完整性、不可抵赖性。

一条链拥有一个链证书及对应的链私钥，链私钥由链管理员拥有。并对每个参与该链的机构签发机构证书，机构证书私钥由机构管理员持有，并对机构下属节点签发节点证书。节点证书是节点身份的凭证，并使用该证书与其他节点间建立SSL连接进行加密通讯。

因此，需要生成链证书、机构证书、节点证书。生成方法如下：

### 1.2.1. 生成链证书
```shell
cd /mydata/FISCO-BCOS/cert/
chmod +x *.sh
./chain.sh  #会提示输入相关证书信息，默认可以直接回车
```
/mydata/FISCO-BCOS/cert/ 目录下将生成链证书相关文件。

**注意：ca.key 链私钥文件请妥善保存**

### 1.2.2. 生成机构证书
假设机构名为WB
```shell
cd /mydata/FISCO-BCOS/cert/
./agency.sh WB #会提示输入相关证书信息，默认可以直接回车
#如需要生成多个机构，则重复执行 ./agency.sh 机构名称  即可
```
/mydata/FISCO-BCOS/cert/ 目录下将生成机构目录WB。WB目录下将有机构证书相关文件。

**注意：agency.key 机构私钥文件请妥善保存**

### 1.2.3. 生成节点证书
假设为机构WB下的节点nodedata-1生成节点证书，则：
```shell
cd /mydata/FISCO-BCOS/cert/
./node.sh WB nodedata-1 #会提示输入相关证书信息，默认可以直接回车
#如需要生成多个节点，则重复执行 ./node.sh 机构名称 节点名称 即可
```
/mydata/FISCO-BCOS/cert/WB/ 目录下将生成节点目录nodedata-1。nodedata-1目录下将有该节点所属的机构相关证书和链相关证书。

**注意：node.key 机构私钥文件请妥善保存**

### 1.2.4. 生成SDK证书
```
shell
cd /mydata/FISCO-BCOS/cert/
./sdk.sh WB sdk
```
密码均输入123456

/mydata/FISCO-BCOS/cert/WB/ 目录下将生成sdk目录，并将所生成的sdk目录下所有文件拷贝到SDK端的证书目录下（java端的web3sdk指定目录下）。

**注意：sdk.key SDK私钥文件请妥善保存**

### 1.2.5. 证书说明
/mydata/FISCO-BCOS/cert/WB/nodedata-1目录下文件是节点nodedata-1运行时必备文件。其中：

ca.crt: 链证书

agency.crt: 机构证书

node.crt:节点证书

node.key: 节点私钥

node.nodeid: 节点身份NodeId

node.serial: 节点证书序列号

node.json: 节点注册文件，应用于系统合约

node.ca: 节点证书相关信息，应用于系统合约


## 1.3. 第三章 创建创世节点

创世节点是区块链中的第一个节点，搭建区块链，从创建创世节点开始。

### 1.3.1. 创建节点环境

> 假定创世节点目录为/mydata/nodedata-1/，创建节点环境如下：

```shell
#创建目录结构
mkdir -p /mydata/nodedata-1/
mkdir -p /mydata/nodedata-1/data/ #存放节点的各种文件
mkdir -p /mydata/nodedata-1/log/ #存放日志
mkdir -p /mydata/nodedata-1/keystore/ #存放账户秘钥

#拷贝相关文件
cd /mydata/FISCO-BCOS/ 
cp genesis.json config.json log.conf start.sh stop.sh /mydata/nodedata-1/
```

### 1.3.2. 配置god账号

god账号是区块链的最高权限，在启动区块链前必须配置。

#### 1.3.2.1. 生成god账号

```shell
cd /mydata/FISCO-BCOS/web3lib
cnpm install #安装nodejs依赖, 在执行nodejs脚本之前, 该命令在该目录需要执行一次, 之后不需要再执行。
cd /mydata/FISCO-BCOS/tool #代码根目录下的tool文件夹
cnpm install #安装nodejs包，仅需运行一次，之后若需要再次在tool目录下使用nodejs，不需要重复运行此命令
node accountManager.js > godInfo.txt
cat godInfo.txt |grep address
```

> 可得到生成god账号的地址如下。godInfo.txt请妥善保存。

```log
address : 0x27214e01c118576dd5f481648f83bb909619a324
```

#### 1.3.2.2. 配置god账号

> 将上述步骤生成的god的address配置入genesis.json的god字段：

```shell
vim /mydata/nodedata-1/genesis.json
```

> 修改后，genesis.json中的god字段如下：

```
"god":"0x27214e01c118576dd5f481648f83bb909619a324",
```
> 修改FISCO-BCOS/web3lib/config.js中的私钥和地址，匹配/tool/godInfo.txt，注意私钥要去掉0x。
### 1.3.3. 配置节点身份

NodeId唯一标识了区块链中的某个节点，在节点启动前必须进行配置。


#### 1.3.3.1. 生成节点身份文件

使用<u>2.3 节点证书</u> 生成对应节点证书。并将其拷贝到节点数据目录下。

```shell
cp /mydata/FISCO-BCOS/cert/WB/nodedata-1/*  /mydata/nodedata-1/data/
```

#### 1.3.3.2. 配置创世节点NodeId

（1）查看NodeId

```shell
cat /mydata/nodedata-1/data/node.nodeid
```

> 得到如下类似的NodeId

```log
2cd7a7cadf8533e5859e1de0e2ae830017a25c3295fb09bad3fae4cdf2edacc9324a4fd89cfee174b21546f93397e5ee0fb4969ec5eba654dcc9e4b8ae39a878
```

（2）修改genesis.json

> 将NodeId配置入genesis.json的initMinerNodes字段，即指定此NodeId的节点为创世节点。

```shell
vim /mydata/nodedata-1/genesis.json
```

> 修改后，genesis.json中的initMinerNodes字段如下：

```log
"initMinerNodes":["2cd7a7cadf8533e5859e1de0e2ae830017a25c3295fb09bad3fae4cdf2edacc9324a4fd89cfee174b21546f93397e5ee0fb4969ec5eba654dcc9e4b8ae39a878"]
```
### 1.3.4. 配置连接列表文件
节点启动时需要发起对网络中其他节点的连接请求，因此需要配置其他节点的连接信息，因为此时网络并无其他节点，因此配置为节点自身即可，可以拷贝默认bootstrapnodes.json文件即可。
建议此处的IP配置为节点所在的真实IP。
```shell
cp /mydata/FISCO-BCOS/bootstrapnodes.json /mydata/nodedata-1/data
```

格式如下：
```log
{"nodes":[{"host":"127.0.0.1","p2pport":"30303"}]}

```
其中host为节点IP或者域名，p2pport为节点p2p端口。


### 1.3.5. 配置相关配置文件

节点的启动依赖以下配置文件：

- 创世块文件：genesis.json
- 节点配置文件：config.json
- 日志配置文件：log.conf
- 连接节点文件：bootstrapnodes.json
- 节点身份证书文件：<u>2.5 证书说明</u>所列文件

#### 1.3.5.1. 配置genesis.json（创世块文件）

genesis.json中配置创世块的信息，是节点启动必备的信息。

```shell
vim /mydata/nodedata-1/genesis.json
```

> 主要配置god和initMinerNodes字段，在之前的步骤中已经配置好，配置好的genesis.json如下：

```log
{
     "nonce": "0x0",
     "difficulty": "0x0",
     "mixhash": "0x0",
     "coinbase": "0x0",
     "timestamp": "0x0",
     "parentHash": "0x0",
     "extraData": "0x0",
     "gasLimit": "0x13880000000000",
     "god":"0x27214e01c118576dd5f481648f83bb909619a324",
     "alloc": {},
     "initMinerNodes":["2cd7a7cadf8533e5859e1de0e2ae830017a25c3295fb09bad3fae4cdf2edacc9324a4fd89cfee174b21546f93397e5ee0fb4969ec5eba654dcc9e4b8ae39a878"]
}
```

genesis.json其它字段说明请参看<u>附录：12.3 genesis.json说明</u>

#### 1.3.5.2. 配置config.json（节点配置文件）

config.json中配置节点的各种信息，包括网络地址，文件目录，节点身份等。

```shell
vim /mydata/nodedata-1/config.json
```

> 配置节点的信息，主要修改字段：
>
> - 网络连接相关：listenip、rpcport、p2pport、channelPort #需要注意端口不被占用，建议此处的listenip配置为节点所在的真实IP
> - 目录相关：wallet、keystoredir、datadir、logconf #默认节点当前目录即可



config.json其它字段说明请参看<u>附录：12.4 config.json说明</u>

> 配置好的config.json如下：

```log
{
        "sealEngine": "PBFT",
        "systemproxyaddress":"0x0",
        "listenip":"{真实ip}",
        "cryptomod":"0",
        "rpcport": "8545",
        "p2pport": "30303",
        "channelPort": "30304",
        "wallet":"./data/keys.info",
        "keystoredir":"./data/keystore/",
        "datadir":"./data/",
        "vm":"interpreter",
        "networkid":"12345",
        "logverbosity":"4",
        "coverlog":"OFF",
        "eventlog":"ON",
        "statlog":"OFF",
        "logconf":"./log.conf"
}
```

#### 1.3.5.3. 配置log.conf（日志配置文件）

log.conf中配置节点日志生成的格式和路径。一般使用默认即可。

```shell
vim /mydata/nodedata-1/log.conf 
```

> 主要配置日志文件的生成路径，配置好的log.conf 如下：

```log
* GLOBAL:  
    ENABLED                 =   true  
    TO_FILE                 =   true  
    TO_STANDARD_OUTPUT      =   false  
    FORMAT                  =   "%level|%datetime{%Y-%M-%d %H:%m:%s:%g}|%msg"   
    FILENAME                =   "./log/log_%datetime{%Y%M%d%H}.log"  
    MILLISECONDS_WIDTH      =   3  
    PERFORMANCE_TRACKING    =   false  
    MAX_LOG_FILE_SIZE       =   209715200 ## 200MB - Comment starts with two hashes (##)
    LOG_FLUSH_THRESHOLD     =   100  ## Flush after every 100 logs
      
* TRACE:  
    ENABLED                 =   true
    FILENAME                =   "./log/trace_log_%datetime{%Y%M%d%H}.log"  
      
* DEBUG:  
    ENABLED                 =   true
    FILENAME                =   "./log/debug_log_%datetime{%Y%M%d%H}.log"  

* FATAL:  
    ENABLED                 =   true  
    FILENAME                =   "./log/fatal_log_%datetime{%Y%M%d%H}.log"
      
* ERROR:  
    ENABLED                 =   true
    FILENAME                =   "./log/error_log_%datetime{%Y%M%d%H}.log"  
      
* WARNING: 
     ENABLED                 =   true
     FILENAME                =   "./log/warn_log_%datetime{%Y%M%d%H}.log"
 
* INFO: 
    ENABLED                 =   true
    FILENAME                =   "./log/info_log_%datetime{%Y%M%d%H}.log"  
      
* VERBOSE:  
    ENABLED                 =   true
    FILENAME                =   "./log/verbose_log_%datetime{%Y%M%d%H}.log"
```

log.conf其它字段说明请参看<u>附录：12.5 log.conf说明</u>

### 1.3.6. 启动创世节点

节点的启动依赖下列文件，在启动前，请确认文件已经正确的配置：

- 节点证书身份文件（/mydata/nodedata-1/data）：ca.crt、agency.crt、node.crt、node.key、node.private 
- 配置文件（/mydata/nodedata-1/）：genesis.json、config.json、log.conf
- 连接文件（/mydata/nodedata-1/data/）：bootstrapnodes.json

> 启动节点

```shell
cd /mydata/nodedata-1/
chmod +x *.sh
./start.sh
#若需要退出节点
#./stop.sh
```

> 或手动启动

```shell
cd /mydata/nodedata-1/
fisco-bcos --genesis ./genesis.json --config ./config.json & #启动区块链节点
tail -f log/info* |grep ++++  #查看日志输出
#若需要退出节点
#ps -ef |grep fisco-bcos #查看进程号
#kill -9 13432 #13432是查看到的进程号
```

> 几秒后可看到不断刷出打包信息。

```log
INFO|2017-12-12 17:52:16:877|+++++++++++++++++++++++++++ Generating seal ondcae019af78cf04e17ad908ec142ca4e25d8da14791bda50a0eeea782ebf3731#1tx:0,maxtx:1000,tq.num=0time:1513072336877
INFO|2017-12-12 17:52:17:887|+++++++++++++++++++++++++++ Generating seal on3fef9b23b0733ac47fe5385072f80fc036b7517abae0a3e7762739cc66bc7dca#1tx:0,maxtx:1000,tq.num=0time:1513072337887
INFO|2017-12-12 17:52:18:897|+++++++++++++++++++++++++++ Generating seal onb5b38c7a380b13b2e46fecbdca0fac5473f4cbc054190e90b8bd4831faac4521#1tx:0,maxtx:1000,tq.num=0time:1513072338897
INFO|2017-12-12 17:52:19:907|+++++++++++++++++++++++++++ Generating seal on3530ff04adddd30508a4cb7421c8f3ad6421ca6ac3bb5f81fb4880fd72c57a8c#1tx:0,maxtx:1000,tq.num=0time:1513072339907
```

### 1.3.7. 验证节点启动

#### 1.3.7.1. 验证进程

```shell
ps -ef |grep fisco-bcos
```

> 看到进程启动

```log
app 19390     1  1 17:52 ?        00:00:05 fisco-bcos --genesis /mydata/nodedata-1/genesis.json --config /mydata/nodedata-1/config.json
```

#### 1.3.7.2. 查看日志输出

> 执行命令，查看打包信息。

```shell
tail -f /mydata/nodedata-1/log/info* |grep ++++  #查看日志输出
```

> 可看到不断刷出打包信息。

```log
INFO|2017-12-12 17:52:16:877|+++++++++++++++++++++++++++ Generating seal ondcae019af78cf04e17ad908ec142ca4e25d8da14791bda50a0eeea782ebf3731#1tx:0,maxtx:1000,tq.num=0time:1513072336877
INFO|2017-12-12 17:52:17:887|+++++++++++++++++++++++++++ Generating seal on3fef9b23b0733ac47fe5385072f80fc036b7517abae0a3e7762739cc66bc7dca#1tx:0,maxtx:1000,tq.num=0time:1513072337887
INFO|2017-12-12 17:52:18:897|+++++++++++++++++++++++++++ Generating seal onb5b38c7a380b13b2e46fecbdca0fac5473f4cbc054190e90b8bd4831faac4521#1tx:0,maxtx:1000,tq.num=0time:1513072338897
INFO|2017-12-12 17:52:19:907|+++++++++++++++++++++++++++ Generating seal on3530ff04adddd30508a4cb7421c8f3ad6421ca6ac3bb5f81fb4880fd72c57a8c#1tx:0,maxtx:1000,tq.num=0time:1513072339907
```

若上述都正确输出，则表示创世节点已经正确启动！


## 1.4. 第四章 部署系统合约

系统合约是 FISCO BCOS 区块链的重要设计思路之一，也是控制网络节点加入和退出的重要方式，每条区块链仅需部署一次系统合约。系统合约的详细介绍，请参看<u>附录：12.7 系统合约介绍</u>

### 1.4.1. 配置

> 切换到部署系统合约的目录下

```shell
cd /mydata/FISCO-BCOS/systemcontract
```

> 安装依赖环境

```shell
cnpm install
```

> 设置区块链节点RPC端口

```shell
vim ../web3lib/config.js
```

> 将proxy指向区块链节点的RPC端口。RPC端口在节点的config.json中查看（参考：<u>2.5.2 配置config.json（节点配置文件）</u>）。

```javascript
var proxy="http://127.0.0.1:8545";
```
并且将godInfo.txt中的私钥和地址配置该文件。

### 1.4.2. 部署系统合约

> 直接运行systemcontract/deploy.js部署系统合约。注意，此deploy.js与tool目录的是不同的两个文件。

```shell
babel-node deploy.js 
```

> 部署成功，输出合约路由表。

```log
#.....省略很多编译warn信息.....
SystemProxycomplie success！
send transaction success: 0x56c9e34cf559b3a9aead8694a7bda7e6b5ea4af855d5ec6ef08fadf494accf08
SystemProxycontract address 0x210a7d467c3c43307f11eda35f387be456334fed
AuthorityFiltercomplie success！
send transaction success: 0x112b6ac9a61197920b6cbe1a71d8f8d4a6c0c11cd0ae3c1107d1626691bf1c35
AuthorityFiltercontract address 0x297e397a7534464a4e7448c224aae52f9614af77
Groupcomplie success！
send transaction success: 0x1be1fb1393e3a3f37f197188ea99de0a5dd1828cc9fc24638f678528f0e30c23
Groupcontract address 0xed0a1b82649bd22d947e5c3ca0b779aac8ee5edc
TransactionFilterChaincomplie success！
send transaction success: 0x704a614b10c5682c44a11e48305bad40a0809d1fc9e178ddec1218c52e7bc9d0
TransactionFilterChaincontract address 0x60d34569bc861b40a7552f89a198a89d8c99075e
CAActioncomplie success！
send transaction success: 0x75f890777b586060c3f94dc3396f5ad86c3e10f2eb9b8350bbc838beecf50ece
CAActioncontract address 0x6fbf3bef2f757c01e0c43fc1364207c1e8a19d08
NodeActioncomplie success！
send transaction success: 0x9d26304258608de5bf1c47ecb9b2ac79f5323e6b74cef7eddef1fb9893d5e98e
NodeActioncontract address 0xb5e0d2c6f1b9f40ea21fa8698a28d1662e8afa3e
send transaction success: 0x03c86b3dcd3d564a00a709b7cd6f1902cd4111cc30c71c62728deadc6e8d7511
ConfigActioncomplie success！
send transaction success: 0xa49205ff3ad697fda75019cb2bbf541a120c146b973f8c5d50b761fd5024b795
ConfigActioncontract address 0xb1e6d5f95c9cb39a9e4e3071b3765e08c30ea281
FileInfoManagercomplie success！
send transaction success: 0x10f8b3fa9efb129bb321cba26019f363aad1b1a162b9347f6638bf6d94de7c32
FileInfoManagercontract address 0x0c2422186429e81911b729fd25e3afa76231f9c7
FileServerManagercomplie success！
send transaction success: 0xd156ccb19fa9dc5313c124933a458b141a20cc2ce01334ce030940e9f907cb84
FileServerManagercontract address 0xb33485375d208a23e897144b6244e20d9c1e83d9
ConsensusControlMgrcomplie success！
send transaction success: 0xcfe0a0fc77910c127d31470e38707dfe70a7fb699abce3e9261ef55a4e50997c
ConsensusControlMgrcontract address 0x3414ef5c15848a07538a2fac57c09a549036b5e3
ContractAbiMgrcomplie success！
send transaction success: 0xc1e2c4e837edda0e215ca06aaa02eecb3a954acfafd498a049b7cf6cee410f5c
ContractAbiMgrcontract address 0xac919b98301804575bd2dc676330aa8f2637f7d5
#......省略若干行...........
send transaction success: 0x2a0f5f9eeb069fe61289e8c95cb4b6cf026859cd20e38e8e47c0788609d8aad1
send transaction success: 0xcd51375a90056e92a52869c63ec153f05722ab8ee56b5ae242b9114c4838e32b
send transaction success: 0x250c0fc5f34bfb73a6bc2a858b64287aa859f12651a3798d46d7269e7305bf6f
send transaction success: 0xff3aeddb55c9ac6868df0cde04466431c7286d93baa80e3826522a2a8ad9681a
send transaction success: 0x71d484aa4a90068e409a11800e9ae5df6143dd59e0cc21a06c1a0bbba4617307
send transaction success: 0x8bd093d44c99817685d21053ed468afa8f216bc12a1c3f5fe33e5cd2bfd045c0
send transaction success: 0x5b9acaab5252bf43b111d24c7ff3adac0121c58e59636f26dbe2ca71dd4af47d
send transaction success: 0x34fb9226604143bec959d65edb0fc4a4c5b1fe5ef6eead679648c7295099ac8b
send transaction success: 0xe9cac7507d94e8759fcc945e6225c873a422a78674a79b24712ad76757472018
register TransactionFilterChain.....
send transaction success: 0x814ef74b4123f416a0b602f25cc4d49e038826cf50a6c4fbc6a402b9a363a8d9
register ConfigAction.....
send transaction success: 0xdb4aaa57b01ca7b1547324bcbeeaaeaa591bf9962ea921d5ce8845b566460776
register NodeAction.....
send transaction success: 0x2c7f43c84e52e99178a92e6a63fb69b5dedf4993f7cbb62608c74b6256241b39
register CAAction.....
send transaction success: 0xcb792f508ca890296055a53c360d68c3c46f8bf801ce73818557e406cbd0618c
register ContractAbiMgr.....
send transaction success: 0xfdc0dd551eada0648919a4c9c5ffa182d042099d73fa802cf803bebf5068aec1
register ConsensusControlMgr.....
send transaction success: 0x7f6d95e6a49a1c1de257415545afb0ec7fdd5607c427006fe14a7750246b9d75
register FileInfoManager.....
send transaction success: 0xc5e16814085000043d28a6d814d6fa351db1cd34f7d950e5e794d28e4ff0da49
register FileServerManager.....
send transaction success: 0xbbbf66ab4acd7b5484dce365d927293b43b3904cd14063a7f60839941a0479a0
SystemProxy address :0x9fe9648f723bff29f940b8c18fedcc9c7ed2b91f
-----------------SystemProxy route ----------------------
get 0xb33485375d208a23e897144b6244e20d9c1e83d9
0 )TransactionFilterChain=>0x60d34569bc861b40a7552f89a198a89d8c99075e,false,250
1 )ConfigAction=>0xb1e6d5f95c9cb39a9e4e3071b3765e08c30ea281,false,251
2 )NodeAction=>0xb5e0d2c6f1b9f40ea21fa8698a28d1662e8afa3e,false,252
3 )CAAction=>0x6fbf3bef2f757c01e0c43fc1364207c1e8a19d08,false,253
4 )ContractAbiMgr=>0xac919b98301804575bd2dc676330aa8f2637f7d5,false,254
5 )ConsensusControlMgr=>0x3414ef5c15848a07538a2fac57c09a549036b5e3,false,255
6 )FileInfoManager=>0x0c2422186429e81911b729fd25e3afa76231f9c7,false,256
7 )FileServerManager=>0xb33485375d208a23e897144b6244e20d9c1e83d9,false,257
-----------------SystemProxy route ----------------------
```

> 上述输出内容中，重要的是系统代理合约地址，即SystemProxy合约地址。如：

```log
SystemProxycontract address 0x210a7d467c3c43307f11eda35f387be456334fed
```

### 1.4.3. 配置系统代理合约地址

系统代理合约，是所有系统合约的路由，通过配置系统代理合约地址（SystemProxy），才能正确调用系统合约。给个区块链节点都应配置系统代理合约地址，才能正确调用系统合约。

> 修改所有区块链节点的config.json。将systemproxyaddress字段配置为，上述步骤输出的SystemProxy合约地址配置。

```shell
vim /mydata/nodedata-1/config.json
```

> 配置后，config.json中的systemproxyaddress字段如下：

```log
"systemproxyaddress":"0x210a7d467c3c43307f11eda35f387be456334fed",
```

> 重启被配置的节点：

```shell
cd /mydata/nodedata-1/
chmod +x *.sh
./stop.sh
./start.sh #执行此步骤后不断刷出打包信息，表明重启成功
```

自此，系统合约生效，为配置多个节点的区块链做好了准备。系统合约的详细介绍，请参看<u>附录：12.7 系统合约介绍</u>



## 1.5. 第五章 创建普通节点

普通节点是区块链中除创世节点外的其它节点。

同一条链中的所有节点共用相同的genesis.json，并且节点所属机构必须都是由同一个链证书所签发。

创建普通节点的步骤与创建创世节点的步骤类似。普通节点不需要再修改genesis.json，直接复制创世节点的genesis.json节点的相应路径下即可。
另外需要拷贝可执行文件solc、fisco-solc、fisco-bcos到/usr/bin

### 1.5.1. 创建节点环境

> 假定节点目录为/mydata/nodedata-2/，创建节点环境如下：

```shell
#创建目录结构
mkdir -p /mydata/nodedata-2/
mkdir -p /mydata/nodedata-2/data/ #存放节点的各种文件
mkdir -p /mydata/nodedata-2/log/ #存放日志
mkdir -p /mydata/nodedata-2/keystore/ #存放账户秘钥

#拷贝创世节点相关文件
cd /mydata/nodedata-1/ 
cp genesis.json config.json log.conf start.sh stop.sh /mydata/nodedata-2/
```

### 1.5.2. 生成节点证书文件

> 同样需要为普通节点生成节点证书相关文件。

参考<u>2.3 节点证书</u> 生成对应节点证书。并将其拷贝到节点数据目录下。

```shell
cp /mydata/FISCO-BCOS/cert/WB/nodedata-2/*  /mydata/nodedata-2/data/
```
### 1.5.3. 配置连接文件bootstrapnodes.json
从创世节点data目录拷贝bootstrapnodes.json文件到当前节点data目录下。
```shell
cp /mydata//nodedata-1/data/bootstrapnodes.json /mydata/nodedata-2/data/
```
并对bootstrapnodes.json进行编辑，填入创世节点的ip和p2pport
```shell
vim /mydata//nodedata-2/data/bootstrapnodes.json
```
> 编辑后，bootstrapnodes.json内容为
```log
{"nodes":[{"host":"创世节点IP,如127.0.0.1","p2pport":"30303"}]}
```

### 1.5.4. 配置节点配置文件config.json

config.json中可配置节点的各种信息，包括网络地址，数据目录等。

```shell
vim /mydata/nodedata-2/config.json
```

> 配置本节点的信息，根据需要主要以下修改字段
>
> - 网络连接相关：listenip、rpcport、p2pport、channelPort #需要注意端口不被占用，建议此处的listenip配置为节点所在的真实IP
> - 目录相关：wallet、keystoredir、datadir、logconf #一般使用默认当前目录即可

config.json其它字段说明请参看<u>附录：12.4 config.json说明</u>

> 配置好的config.json如下：

```log
{
        "sealEngine": "PBFT",
        "systemproxyaddress":"0x210a7d467c3c43307f11eda35f387be456334fed",
        "listenip":"{真实ip}",
        "cryptomod":"0",
        "ssl":"0",
        "rpcport": "8546",
        "p2pport": "30403",
        "channelPort": "30404",
        "wallet":"./data/keys.info",
        "keystoredir":"./data/keystore/",
        "datadir":"./data/",
        "vm":"interpreter",
        "networkid":"12345",
        "logverbosity":"4",
        "coverlog":"OFF",
        "eventlog":"ON",
        "statlog":"OFF",
        "logconf":"./log.conf"
}
```

#### 1.5.4.1. 配置日志文件log.conf

log.conf中配置节点日志生成的格式和路径。一般使用默认配置文件即可。

```shell
vim /mydata/nodedata-2/log.conf 
```

> 主要配置日志文件的生成路径，配置好的log.conf 如下：

```log
* GLOBAL:  
    ENABLED                 =   true  
    TO_FILE                 =   true  
    TO_STANDARD_OUTPUT      =   false  
    FORMAT                  =   "%level|%datetime{%Y-%M-%d %H:%m:%s:%g}|%msg"   
    FILENAME                =   "./log/log_%datetime{%Y%M%d%H}.log"  
    MILLISECONDS_WIDTH      =   3  
    PERFORMANCE_TRACKING    =   false  
    MAX_LOG_FILE_SIZE       =   209715200 ## 200MB - Comment starts with two hashes (##)
    LOG_FLUSH_THRESHOLD     =   100  ## Flush after every 100 logs
      
* TRACE:  
    ENABLED                 =   true
    FILENAME                =   "./log/trace_log_%datetime{%Y%M%d%H}.log"  
      
* DEBUG:  
    ENABLED                 =   true
    FILENAME                =   "./log/debug_log_%datetime{%Y%M%d%H}.log"  

* FATAL:  
    ENABLED                 =   true  
    FILENAME                =   "./log/fatal_log_%datetime{%Y%M%d%H}.log"
      
* ERROR:  
    ENABLED                 =   true
    FILENAME                =   "./log/error_log_%datetime{%Y%M%d%H}.log"  
      
* WARNING: 
     ENABLED                 =   true
     FILENAME                =   "./log/warn_log_%datetime{%Y%M%d%H}.log"
 
* INFO: 
    ENABLED                 =   true
    FILENAME                =   "./log/info_log_%datetime{%Y%M%d%H}.log"  
      
* VERBOSE:  
    ENABLED                 =   true
    FILENAME                =   "./log/verbose_log_%datetime{%Y%M%d%H}.log"
```

log.conf其它字段说明请参看<u>附录：12.5 log.conf说明</u>

### 1.5.5. 启动节点

节点的启动依赖下列文件，在启动前，请确认文件已经正确的配置：

- 节点证书身份文件（/mydata/nodedata-2/data）：ca.crt、agency.crt、node.crt、node.key、node.private 
- 配置文件（/mydata/nodedata-2/）：genesis.json、config.json、log.conf
- 连接文件（/mydata/nodedata-2/data/）：bootstrapnodes.json

> 启动节点，此时节点未被注册到区块链中，启动时只能看到进程，不能刷出打包信息。要让此节点正确的运行，请进入<u>第七章 多节点组网</u> 。

```shell
cd /mydata/nodedata-2/
chmod +x *.sh
./start.sh #此时节点未被注册到区块链中，等待10秒，不会刷出打包信息
ctrl-c 退出
ps -ef |grep fisco-bcos #可查看到节点进程存在
```

> 可看到进程已经在运行

```log
app  9656     1  4 16:10 ?        00:00:01 fisco-bcos --genesis /mydata/nodedata-2/genesis.json --config /mydata/nodedata-2/config.json
```

> 关闭节点，待注册后再重启

```shell
./stop.sh 
```



## 1.6. 第六章 多记账节点组网

FISCO BCOS区块链中的节点，只有被注册到系统合约记账节点列表中，才能参与记账。

> 多节点记账组网依赖系统合约，在进行多节点记账组网前，请确认：
>
> （1）系统合约已经被正确的部署。
>
> （2）所有节点的config.json的systemproxyaddress字段已经配置了相应的系统代理合约地址。
>
> （3）节点在配置了systemproxyaddress字段后，已经重启使得系统合约生效。
>
> （4）/mydata/FISCO-BCOS/web3lib/下的config.js已经正确的配置了节点的RPC端口。

### 1.6.1. 注册记账节点

所有的节点注册流程都相同。在注册节点时，**被注册节点必须处于运行状态**。

#### 1.6.1.1. 注册

在注册前，请确认已注册的所有节点，都已经启动。
> 每个节点的data目录下都有一个node.json注册文件,里面包含了节点相关信息。
> 以注册创世节点为例

```shell
cd /mydata/FISCO-BCOS/systemcontract/
babel-node tool.js NodeAction register /mydata/nodedata-1/data/node.json
```

> 可看到注册信息

```log
{ HttpProvider: 'http://127.0.0.1:8545',
  Ouputpath: './output/',
  privKey: 'bcec428d5205abe0f0cc8a734083908d9eb8563e31f943d760786edf42ad67dd',
  account: '0x64fa644d2a694681bd6addd6c5e36cccd8dcdde3' }
Soc File :NodeAction
Func :registerNode
SystemProxy address 0x210a7d467c3c43307f11eda35f387be456334fed
node.json=node1.json
NodeAction address 0xcc46c245e6cca918d43bf939bbb10a8c0988548f
send transaction success: 0x9665417c16b636a2a83e13e82d1674e4db72943bae2095cb030773f0a0ba1eef
```

#### 1.6.1.2. 查看记账列表

> 查看节点是否已经在记账节点列表中

```shell
cd /mydata/FISCO-BCOS/systemcontract/
babel-node tool.js NodeAction all
```

> 可看到被注册的节点信息，节点已经加入记账列表

```log
{ HttpProvider: 'http://127.0.0.1:8545',
  Ouputpath: './output/',
  privKey: 'bcec428d5205abe0f0cc8a734083908d9eb8563e31f943d760786edf42ad67dd',
  account: '0x64fa644d2a694681bd6addd6c5e36cccd8dcdde3' }
Soc File :NodeAction
Func :all
SystemProxy address 0x210a7d467c3c43307f11eda35f387be456334fed
NodeAction address 0xcc46c245e6cca918d43bf939bbb10a8c0988548f
NodeIdsLength= 1
----------node 0---------
id=24b98c6532ff05c2e9e637b3362ee4328c228fb4f6262c1c751f51952012cd68da2cbd8655de5072e49b950a503326942297cfaa9ca919b369be4359b4dccd56
name=A
agency=WB
caHash=A6A0371C855C5BE0
Idx=0
blocknumber=58
```

#### 1.6.1.3. 注册更多的节点

在注册更多的节点前，请确认节点都已经启动。本过程可以重复执行，注册更多节点。

```shell
cd /mydata/FISCO-BCOS/systemcontract/
babel-node tool.js NodeAction register /mydata/nodedata-2/data/node.json  # node.json文件也可以在FISCO-BCOS/cert/WB/nodedata-2/node.json获取
cd /mydata/nodedata-2/
./start.sh #将被注册的节点启动起来，此时节点已经被注册，可刷出打包信息
```

>再次查看记账列表：

```log
cd /mydata/FISCO-BCOS/systemcontract/
babel-node tool.js NodeAction all
```

> 可看到输出了节点信息（node1），节点加入了记账列表

```log
{ HttpProvider: 'http://127.0.0.1:8545',
  Ouputpath: './output/',
  privKey: 'bcec428d5205abe0f0cc8a734083908d9eb8563e31f943d760786edf42ad67dd',
  account: '0x64fa644d2a694681bd6addd6c5e36cccd8dcdde3' }
Soc File :NodeAction
Func :all
SystemProxy address 0x210a7d467c3c43307f11eda35f387be456334fed
NodeAction address 0xcc46c245e6cca918d43bf939bbb10a8c0988548f
NodeIdsLength= 2
----------node 0---------
id=24b98c6532ff05c2e9e637b3362ee4328c228fb4f6262c1c751f51952012cd68da2cbd8655de5072e49b950a503326942297cfaa9ca919b369be4359b4dccd56
name=node1
agency=WB
caHash=A6A0371C855C5BE0
Idx=0
blocknumber=58
----------node 1---------
id=b5adf6440bb0fe7c337eccfda9259985ee42c1c94e0d357e813f905b6c0fa2049d45170b78367649dd0b8b5954ee919bf50c1398a373ca777e6329bd0c4b82e8
name=node2
agency=WB
caHash=A6A0371C855C5BE1
Idx=1
blocknumber=392
```

### 1.6.2. 节点退出记账列表

> 要让某节点退出记账列表，需执行以下脚本。执行时，指定相应节点的注册文件。此处让node2退出为例。

```shell
cd /mydata/FISCO-BCOS/systemcontract/
babel-node tool.js NodeAction cancel /mydata/nodedata-2/data/node.json
```

> 执行后有如下输出：

```log
{ HttpProvider: 'http://127.0.0.1:8545',
  Ouputpath: './output/',
  privKey: 'bcec428d5205abe0f0cc8a734083908d9eb8563e31f943d760786edf42ad67dd',
  account: '0x64fa644d2a694681bd6addd6c5e36cccd8dcdde3' }
Soc File :NodeAction
Func :cancelNode
SystemProxy address 0x210a7d467c3c43307f11eda35f387be456334fed
node.json=node2.json
NodeAction address 0xcc46c245e6cca918d43bf939bbb10a8c0988548f
send transaction success: 0x031f29f9fe3b607277d96bcbe6613dd4d2781772ebd0c810a31a8d680c0c49c3
```

>查看记账列表，看不到相应节点的信息，表示节点已经退出了记账列表。

```log
cd /mydata/FISCO-BCOS/systemcontract/
babel-node tool.js NodeAction all
#......节点输出信息......
{ HttpProvider: 'http://127.0.0.1:8545',
  Ouputpath: './output/',
  privKey: 'bcec428d5205abe0f0cc8a734083908d9eb8563e31f943d760786edf42ad67dd',
  account: '0x64fa644d2a694681bd6addd6c5e36cccd8dcdde3' }
Soc File :NodeAction
Func :all
SystemProxy address 0x210a7d467c3c43307f11eda35f387be456334fed
NodeAction address 0xcc46c245e6cca918d43bf939bbb10a8c0988548f
NodeIdsLength= 1
----------node 0---------
id=2cd7a7cadf8533e5859e1de0e2ae830017a25c3295fb09bad3fae4cdf2edacc9324a4fd89cfee174b21546f93397e5ee0fb4969ec5eba654dcc9e4b8ae39a878
ip=127.0.0.1
port=30501
category=1
desc=node1
CAhash=
agencyinfo=node1
blocknumber=427
Idx=0
```
