var Web3= require('web3');
var config=require('../web3lib/config');
var fs=require('fs');
var execSync =require('child_process').execSync;
var web3sync = require('../web3lib/web3sync');

if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
} else {
  web3 = new Web3(new Web3.providers.HttpProvider(config.HttpProvider));
}


var result = web3sync.sendRawTransactionByNameService(config.account,config.privKey,"COULogic","setCOUDataAddress","",['0x9341d8ded99f366d2cca150bee11bb02f18befec']);

var result = web3sync.sendRawTransactionByNameService(config.account,config.privKey,"COUFactory","setCOULogicAddress","",['0x3f922f8d81f9b3c9e6857b5ddd6edf0ff58375ce']);

console.log("result: "+result);
