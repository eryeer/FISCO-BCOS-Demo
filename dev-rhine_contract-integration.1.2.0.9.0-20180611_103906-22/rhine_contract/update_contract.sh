#!/bin/bash

## Created by Yudong_Lin, 20171107
## Ver 1.0

###

PATH_WORKBASE=$(cd "$(dirname "$0")"; pwd)

FILE_SYSCADDR=SystemProxy.address
NAME_CONTRACTS=$1

DIR_BCOS_TOOL=tool
DIR_BCOS_SYSC=systemcontractv2
DIR_RHINE_CONTRACTS=contracts

PATH_INSTALLER_BCOS=/home/rhine/rhine_bcos
PATH_BCOS_TOOL=${PATH_INSTALLER_BCOS}/${DIR_BCOS_TOOL}
PATH_BCOS_SYSC=${PATH_INSTALLER_BCOS}/${DIR_BCOS_SYSC}
PATH_RHINE_CONTRACTS=${PATH_WORKBASE}/${DIR_RHINE_CONTRACTS}

UpdateContracts()
{
  cp ${PATH_RHINE_CONTRACTS}/*.sol ${PATH_BCOS_TOOL}/.
  cp ${PATH_RHINE_CONTRACTS}/*.js ${PATH_BCOS_TOOL}/.
  cd ${PATH_BCOS_TOOL}
  COUCAddress=`babel-node deploy.js ${NAME_CONTRACTS} | grep '0x' | head -1 | awk '{print $2}'`

  echo "SetRoute to ${COUCAddress}"
  cd ${PATH_BCOS_SYSC}
  babel-node tool.js SystemProxy setRoute ${NAME_CONTRACTS} ${COUCAddress}
}

UpdateContracts
