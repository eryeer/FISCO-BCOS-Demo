**《Rhine ReleasePlan》**

此次版本升级为release.1.0.3.4.0升级到release.1.3.0.x.x  
以下操作运行环境为linux Terminal

# 1. upgrade前提条件
1. 停止access和accessAdmin运行
    + cd /path/to/tomcat_home/
    + tail -f ./logs/catalina.out
    + 进入 http://url.to.tomcat:8080/manager/html
    + 选择 access & accessAdmin 之 Stop 按钮
    + 观察./logs/catalina.out, 看到如下打印，即正确关闭access 及 accessAdmin。
 ```
 ...
 dd-mm-yyyy hh:mm:ss.sss 信息 [Abandoned connection cleanup thread] org.apache.catalina.loader.WebappClassLoaderBase.checkStateForResourceLoading Illegal access: this web application instance has been stopped already.
 ...
 ```
    
2. 检查数据库OnProcess表中是否有状态为ON_GOING和RETRY_ON_GOING的数据，sql语句如下
```
select count(1) from OnProcess where status in ('ON_GOING','RETRY_ON_GOING');
```
如果查询结果为0，即不存在这样的数据，方可进行版本upgrade。


# 2. upgrade数据库
## 2.1. 运行mysql客户端。
```
mysql -u root -proot
```
## 2.2. 进入rhine数据库
```
use rhine；
```

## 2.3. 更新FI手机号和邮箱地址
```
UPDATE `rhine`.`user_key_info` SET `phoneNum`='13333333332' ,`email`='fi@g.com'
WHERE `role1`='ROLE_FIRole';
UPDATE `rhine`.`spreckeyinfo` SET `phoneNum`='13333333332' 
where companyType = 4 and recprivkey is null or recprivkey='';
```
## 2.4. 从C已有3个角色中选一个作为C恢复秘钥者的手机号
```
UPDATE `rhine`.`spreckeyinfo` SET `phoneNum`='13333333333' 
where companyType = 2 and recprivkey is null or or recprivkey='';
```

## 2.5. 打开update.sql文件
```
cat /path/to/sql_home/update.sql
```
找到当前生产环境版本号之后一版本的版本标题  
例如，对于当前生产环境版本为release.1.0.3.4.0，则找到
```
-- release.1.0.4.0.0 mysql数据库表修改语句
```
一行，拷贝此行之下所有的sql语句，在mysql客户端界面中粘贴，完成数据库更新。

## 2.6. 更新EmailList表
假定emailList.sql在本机路径为/path/to/sql_home
```
TRUNCATE `rhine`.`EmailList`;
mysql -u root -proot </path/to/sql_home/emailList.sql
```

## 2.7. 适配多C
假定需要更新的C的bln为cccccccccccccccccc

```
update rhine.COUMaturityDate SET cbln = 'cccccccccccccccccc';
update rhine.COUActive SET cbln = 'cccccccccccccccccc';
update rhine.COUArchive SET cbln = 'cccccccccccccccccc';
update rhine.CompanyDRActive SET cbln = 'cccccccccccccccccc',isAutoFinalValue=0;
update rhine.CompanyDRArchive set cbln = 'cccccccccccccccccc',isAutoFinalValue=0;
update rhine.COUArchive SET cbln = 'cccccccccccccccccc';

```

## 2.8. 清空CQ授信记录
```
TRUNCATE `rhine`.`FIUpdateCQLog`;
```

# 3. upgrade　fisco bcos
参照 http://git.wx.bc/Pacific/doc/blob/master/fisco-bocs%E5%AE%89%E8%A3%85%E6%96%87%E6%A1%A3/install_fisco-bcos.md 文档描述

# 4. upgrade　fisco bcos contract
将rhine_contract.tar.gz 解压缩出来的contracts下的合约全部拷贝覆盖到rhine_bcos/tool目录下
## 4.1. 1 部署COUFactory合约
### 4.1.1. 1 切换到tool目录，进行合约COUFactory编译、部署：

   ```shell
   cd ~/rhine_bcos/tool
   babel-node deploy.js <合约名称>
   ```
   其中，<合约名称>是部署合约时的名称如COUFactory
   
### 4.1.2. 2 切换到systemcontract目录，在系统代理合约中设置合约名称到合约地址的路由：

   ```shell
   cd ~/rhine_bcos/systemcontract
   babel-node tool.js SystemProxy setRoute <合约名称> <合约地址>
   ```
   其中，<合约名称>是部署合约时的名称如COUFactory
   <合约地址>为1.1步骤中部署合约得到的地址。

### 4.1.3. 3 在~/rhine_bcos/tool目录下，通过如下方式执行CNS服务提供的脚本，将上述部署的合约及相应版本信息添加到命名控制器合约ContractAbiMgr。
#### 4.1.3.1. 如果此前此合约没有部署过

   ```shell
   babel-node cns_manager.js add <合约名称>
   ```
   <合约名称>指的是部署合约时的名称，如1.1步骤中的COUFactory。
#### 4.1.3.2. 如果此合约此前有部署过
   ```shell
   babel-node cns_manager.js update <合约名称>
   ```
   <合约名称>指的是部署合约时的名称，如1.1步骤中的COUFactory。
## 4.2. 2 参照1节 部署COULogic合约、COUDataV1合约和FileData合约。
## 4.3. 在~/rhine_bcos/tool目录下，通过如下方式执行脚本配置逻辑界面合约COUFactory保存控制合约COULogic地址，控制合约COULogic保存COUDataV1的地址，数据合约COUDataV1保存COUData地址：
编辑COUFactory_proxy.js脚本，需包含如下两个sendRawTransactionByNameService接口调用，用于设置数据合约地址到逻辑控制合约：

```shell
var result = web3sync.sendRawTransactionByNameService(config.account,config.privKey,"COUFactory","setCOULogicAddress","",['0x3f922f8d81f9b3c9e6857b5ddd6edf0ff58375ce']);

var result = web3sync.sendRawTransactionByNameService(config.account,config.privKey,"COULogic","setCOUDataV1Address","",['0xa0e78a88f1ef7d7a0f7dfbe173a57d1e3962e419']);

var result = web3sync.sendRawTransactionByNameService(config.account,config.privKey,"COUDataV1","setCOUDataAddress","",['0x05a6020bf5549e7ed7b9ce9832fd4da51b1a79c7']);

```

上述参数中，"COULogic"指示控制器合约的名称，"COUFactory"指示界面合约的名称，"setCOUDataV1Address"指示要设置COUDataV1数据合约地址，而'0xa0e78a88f1ef7d7a0f7dfbe173a57d1e3962e419'指示数据合约的地址，此处即应填入COUDataV1合约地址。
"setCOULogicAddress"指示要设置COULogic逻辑合约地址，而'0x3f922f8d81f9b3c9e6857b5ddd6edf0ff58375ce'指示逻辑合约的地址，此处即应填入COULogic合约地址,"setCOUDataAddress"指示要设置COUData数据合约地址，而'0x05a6020bf5549e7ed7b9ce9832fd4da51b1a79c7'指示数据合约的地址，此处即应填入COUData合约地址。

## 4.4. 执行 COUFactory_proxy.js文件

    ```shell
    babel-node COUFactory_proxy.js
    ```
## 4.5. 开启权限模型
## 4.6. 打开tool/godInfo.txt 查看当前上帝账号
## 4.7. 切换到systemcontract目录，运行ARPI_Model.js脚本，保证源码web3lib目录下的config.js里的账号是上帝账号，注意私钥部分要删除'0x'
注意: 上帝账号在底层链运行之后，应当从环境上删除，并自行备份，以防泄露

```shell
    babel-node ARPI_Model.js
```
## 4.8. 检查sysytemcontract/tool.js 
第十五行左右是否有
```
web3.eth.defaultAccount = config.account;
```
这句话，没有的话填上。
## 4.9. 切换到tool目录,创建两个账号，一个给观察者节点，一个给记账节点

```shell
    node accountManager.js > Observer.txt
    node accountManager.js > Charge.txt
```
## 4.10. 切换到systemcontract目录,为新账号分配权限

## 4.11. 给观察者节点账号分配权限

```shell
    babel-node AuthorityManager.js Filter setUsertoNewGroup 0 0x58407a51f10ffdef5fcf75fe57916367ea626807      
```
    ps： 0 是filter序号，0x58407a51f10ffdef5fcf75fe57916367ea626807 为新建的账号地址
    
```shell
    babel-node AuthorityManager.js Group addPermission 0 0x58407a51f10ffdef5fcf75fe57916367ea626807 SystemProxy.address "getRoute(string)"
    babel-node AuthorityManager.js Group addPermission 0 0x58407a51f10ffdef5fcf75fe57916367ea626807 COUFactory.address "getTrade(string)"
    babel-node AuthorityManager.js Group addPermission 0 0x58407a51f10ffdef5fcf75fe57916367ea626807 FileData.address "getData(string)"
```
    ps： 0 是filter序号，0x58407a51f10ffdef5fcf75fe57916367ea626807 为观察者节点账号地址, SystemProxy.address 为代理系统合约地址， COUFactory.address 为COUFactory合约地址，可用 babel-node tool.js SystemProxy
    查看，执行完毕后，新建的账号只有SystemProxy.getRoute 和 COUFactory.getTrade的权限
    
## 4.12. 给记账节点账号分配权限

```shell
    babel-node AuthorityManager.js Filter setUsertoNewGroup 0 0x58407a51f10ffdef5fcf75fe57916367ea626807      
```
    ps： 0 是filter序号，0x58407a51f10ffdef5fcf75fe57916367ea626807 为新建的账号地址
    
```shell
    babel-node AuthorityManager.js Group addPermission 0 0x4a89667ed4a3297a56c56b181b5cb5823f20d48f SystemProxy.address "getRoute(string)"
    babel-node AuthorityManager.js Group addPermission 0 0x4a89667ed4a3297a56c56b181b5cb5823f20d48f COUFactory.address "getTrade(string)"
    babel-node AuthorityManager.js Group addPermission 0 0x4a89667ed4a3297a56c56b181b5cb5823f20d48f COUFactory.address "setTrade(string)"
    babel-node AuthorityManager.js Group addPermission 0 0x4a89667ed4a3297a56c56b181b5cb5823f20d48f FileData.address "setData(string)"
    babel-node AuthorityManager.js Group addPermission 0 0x4a89667ed4a3297a56c56b181b5cb5823f20d48f FileData.address "getData(string)"
```
    ps： 0 是filter序号，0x4a89667ed4a3297a56c56b181b5cb5823f20d48f 为记账者节点的账号地址, SystemProxy.address 为代理系统合约地址， COUFactory.address 为COUFactory合约地址，FileData.address 为FileData合约地址，可用 babel-node tool.js SystemProxy
    查看，执行完毕后，新建的账号只有SystemProxy.getRoute 和 COUFactory.getTrade  setTrade和 FileData 的 setData 、 getData的权限
    
# 5. upgrade service
## 5.1. 部署service的war包
### 5.1.1. 分别拷贝access.war\accessAdmin.war\middle.war至各个节点服务器的/path/to/tomcat_home/webapps中
```
例如:
cp access.war /path/to/tomcat_home/webapps/.
```
### 5.1.2. 启动tomcat进程
```
cd /path/to/tomcat_home/bin/
sh start.sh
```

### 5.1.3. 查看tomcat日志，检查app是否正常启动
```
tail -f /path/to/tomcat_home/logs/catalina.out
```
观察到如下日志，即启动成功。
```
...
dd-mm-yyyy hh:mm:ss.sss [http-nio-8080-exec-11] INFO  com.wxbc.Application - Started Application in 12.596 seconds (JVM running for 1189.768)
...
```

## 5.2. upgrade　service的配置文件
### 5.2.1. 使用备份文件/opt/backup/appConf/middle_yyyyMMdd_HHmmss/processTag.txt替换middle节点在/path/to/tomcat_home/webapps/middle/WEB-INF/classes中的processTag.txt文件
```
cp /opt/backup/appConf/middle_yyyyMMdd_HHmmss/processTag.txt /path/to/tomcat_home/webapps/middle/WEB-INF/classes/.
```
### 5.2.2. 修改access的application.properties文件，更新为生产环境配置

```
vi /path/to/tomcat_home/webapps/access/WEB-INF/classes/application.properties
```
### 5.2.3. 修改middle的application.properties文件，更新为生产环境配置

```
vi /path/to/tomcat_home/webapps/middle/WEB-INF/classes/application.properties
//middle增加配置
web3j.accout=???  //bcos权限模型的账号，例如 0x52189b3c95af5f03e47cb97e57a0046bbeaa1b4f
web3j.privKey=??? //bcos权限模型的秘钥，例如 0878d2f414ac800b842ae78b03bbe0748f65d774322879b5cd1d814d7e360b80
```

### 5.2.4. 修改accessAdmin的application.properties文件，更新为生产环境配置

```
vi /path/to/tomcat_home/webapps/accessAdmin/WEB-INF/classes/application.properties  
//accessAdmin增加配置
spring.sp.pkrUrl=???  //修改为PKR服务url例如 https://172.16.31.10:8443/secret/

```

### 5.2.5. 重启tomcat进程
```
cd /path/to/tomcat_home/bin/
sh shutdown.sh 
sh start.sh
```

# 6. 使用sdk注入加密顺序
```
java -jar fisdk.jar
```
根据屏幕提示，选择第8项操作，注入加密顺序

# 7. upgrade　client热更新服务器
当前版本需要进行强制热更新，versionControl.json/versionControl.txt中的forceUpdate的值需要在上个版本的基础上加1。
修改对应配置，打包生成对应版本的文件包，上传至服务器上。
1. 使用Jenkins打包代码，生成rhine_client_update-release.1.x.x.x.x.tar.gz。
2. 拷贝文件到热更新服务器上。

```
tar zxvf rhine_client_update-release.1.x.x.x.x.tar.gz
cd rhine_client_update-release.1.x.x.x.x
cp update/rhine /path/to/update_home/update/rhine
cp update/main.js /path/to/update_home/update/main.js
cp update/project.json /path/to/update_home/update/project.json
cp versionControl.json /path/to/update_home/versionControl.json
cp versionControl.txt /path/to/update_home/versionControl.txt
```
# 8. sp通过client录入各个企业角色的email










