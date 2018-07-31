pragma solidity ^0.4.2;

import "OwnerNamed.sol";

contract FileData is OwnerNamed {

    function FileData(){

    }

    mapping(string=>string) VarLenDataMap;

    /* getter */
    function getData(string paramList) public constant returns(string data) {
        string memory dataKey = paramList.getStringValueByKey("indexHash");
        data = VarLenDataMap[dataKey];
        return data;
    }

    /* setter */
    function setData(string paramList) public returns(bool ret) {
        string memory dataKey = paramList.getStringValueByKey("indexHash");
        string memory dataValue = paramList.getStringValueByKey("fileHash");
        VarLenDataMap[dataKey] = dataValue;
        return true;
    }

}
