pragma solidity ^0.4.2;


library LibReturnCode {
    uint constant COU_OFFSET = 10000;

    enum COURetCode {
        COU_RET_SUCCESS,
        COU_RET_FAIL
    }

    function getRetCode(COURetCode rt) internal returns (uint  ret)
    {
        return uint(rt) + COU_OFFSET;
    }

}
