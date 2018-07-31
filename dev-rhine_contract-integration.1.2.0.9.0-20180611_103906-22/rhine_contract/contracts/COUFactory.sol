pragma solidity ^0.4.2;

import "COULogic.sol";

contract COUFactory is OwnerNamed{
    string constant public CALLBACK = "callingApi";
    string constant public PAYIVBYC = "payIvByC";
    string constant public PAYIVBYSN = "payIvBySn";
    string constant public DFCBYSN = "dfcBySn";
    string constant public CMDBYSN = "cmdBySn";
    string constant public SETCOUCQ = "setCenterQuota";
    string constant public SETCQINFO = "setCQInfo";
    string constant public GETCQINFO = "queryCQInfo";
    string constant public GETCOUAMOUNT = "getCOUAmout";
    string constant public GETCOUOWNER = "getCOUOwner";
    string constant public GETINVSTS = "getInvSts";

    COULogic couLogic;

    function COUFactory() {
    }

    event Notify(uint _errno, string _info);

    // interface used to set address of COUManager contract
    function setCOULogicAddress(address addr) returns (bool) {
        couLogic = COULogic(addr);
        return true;
    }
    
    /** 交易相关set类函数 */
    function setTrade(string paramList) returns(bool ret){
        string memory callback = paramList.getStringValueByKey(CALLBACK);
        if( callback.equals(PAYIVBYC) ){
            ret = couLogic.PayIvByC(paramList);
        }else if( callback.equals(PAYIVBYSN) ){
            ret = couLogic.PayIvBySn(paramList);
        }else if( callback.equals(DFCBYSN) ){
            ret = couLogic.DFCBySn(paramList);
        }else if( callback.equals(CMDBYSN) ){
            ret = couLogic.CMDBySn(paramList);
        }else if( callback.equals(SETCOUCQ) ){
            ret = couLogic.setCOUCenterQuota(paramList);
        }else if( callback.equals(SETCQINFO) ){
            ret = couLogic.setCQInfo(paramList);
        }else{
            ret = false;
        }

        return ret;
    }

    /** 交易相关get类函数 */
    function getTrade(string paramList) constant returns(string retJson){

        string memory callback = paramList.getStringValueByKey(CALLBACK);
        if( callback.equals(GETCQINFO) ){
            byte[1024] memory tmpJson = couLogic.getCQInfo(paramList);
            retJson = LibUtil.BytesArrayToString(tmpJson);
        }else if( callback.equals(GETCOUAMOUNT) ){
            uint amount = couLogic.getCOUAmout(paramList);
            retJson = "{";
            retJson = retJson.concat(uint(amount).toKeyValue("COUAmount"), "}");
        }else if( callback.equals(GETCOUOWNER) ){
            byte[1024] memory tmpOwner = couLogic.getCOUOwner(paramList);
            string memory owner = LibUtil.BytesArrayToString(tmpOwner);
            retJson = "{";
            retJson = retJson.concat(owner.toKeyValue("owner"), "}");
        }else if( callback.equals(GETINVSTS) ){
            uint ivStatus = couLogic.getInvSts(paramList);
            retJson = "{";
            retJson = retJson.concat(uint(ivStatus).toKeyValue("ivStatus"), "}");
        }
        return retJson;

    }
}
