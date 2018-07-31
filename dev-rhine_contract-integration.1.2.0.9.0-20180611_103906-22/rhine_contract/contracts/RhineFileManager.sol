pragma solidity ^0.4.2;

import "OwnerNamed.sol";
import "LibString.sol";
import "LibInt.sol";
import "LibReturnCode.sol";
import "LibUtil.sol";

contract RhineFileManager is OwnerNamed {
    using LibInt for *;
    using LibString for *;
    using LibReturnCode for *;
    using LibUtil for *;

    function RhineFileManager(){

    }

    mapping(string=>string) FileInfoMap;

    /* getter */
    function GetFileInfo(string fileIndex) returns(byte[1024] byteArr) {
        string memory fileData = FileInfoMap[fileIndex];
        byteArr = LibUtil.StringToBytesArray(fileData);
        return byteArr;
    }

    /* setter */
    function SetFileInfo(string fileIndex, string fileData) returns(bool ret) {
        FileInfoMap[fileIndex] = fileData;
        return true;
    }

}
