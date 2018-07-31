pragma solidity ^0.4.2;

import "OwnerNamed.sol";
import "LibString.sol";
import "LibCOU.sol";
import "LibInt.sol";
import "LibReturnCode.sol";
import "COUData.sol";

contract COULogic is OwnerNamed{
    using LibInt for *;
    using LibString for *;
    using LibReturnCode for *;
    using LibInvoice for *;
    using LibCOU for *;
    string constant public FIBLNHASH = "fiblnHash";
    string constant public CBLNHASH = "cblnHash";
    string constant public FROMHASH = "fromHash";
    string constant public COUHASH = "couhash";
    string constant public COULIST = "couList";
    string constant public TOHASH = "toHash";
    string constant public IVADDRESSHASH = "ivAddressHash";
    string constant public TIMEHASH = "setCqTimeHash";
    string constant public OLDAMOUNT = "oldAmount";
    string constant public NEWAMOUNT = "newAmount";
    string constant public CENTERQUOTA = "centerQuota";
    string constant public CENTERPAID = "centerPaid";
    string constant public CENTERISSUED = "centerIssued";
    string constant public FIBN = "fiBn";

    uint RETURNCODE_SUCCESS = 0;
    uint RETURNCODE_FAIL = 1;

    string[] COUTransStrList;
    LibCOU.COUTransaction[] COUTransList; 
    COUData couData;

    function COULogic() {
    }
    event Notify(uint _errno, string _info);

    // interface used to set address of COUManager contract
    function setCOUDataAddress(address addr) returns (bool) {
        couData = COUData(addr);
        return true;
    }

    /** 设置中心企业COU额度 */
    function setCOUCenterQuota(string paramList) returns(bool ret){

        string memory fiblnHash = paramList.getStringValueByKey(FIBLNHASH);
        string memory cblnHash = paramList.getStringValueByKey(CBLNHASH);
        string memory timeHash = paramList.getStringValueByKey(TIMEHASH);
        uint oldAmount = uint(paramList.getIntValueByKey(OLDAMOUNT));
        uint newAmount = uint(paramList.getIntValueByKey(NEWAMOUNT));
        if(getCenterQuotaStatus(fiblnHash, cblnHash, timeHash)){
            // CQ info has already been set
            Notify(RETURNCODE_SUCCESS,"Set CQ has been performed successfully previously.");
            return true;
        }

        string memory couKey = couKey.concat(fiblnHash, cblnHash);
        if(couData.getCQMapCenterQuotaByKey(couKey) != oldAmount){
            Notify(RETURNCODE_FAIL,"CQ stored on chain not equal to value queried by middle.");
            return false;
        }

        couData.setCQMapCenterQuotaByKey(couKey,newAmount);
        couData.setCQMapfIPubkeyByKey(couKey,fiblnHash);

        // since CQ has been successfully set, store the relevant info into setCQInfoList storage as a mark
        couData.setCQInfoIntoList(fiblnHash, cblnHash, timeHash);
        
        Notify(RETURNCODE_SUCCESS,"Set CQ success.");
        return true;
    }

    /** 设置中心企业CQ,CP,CI */
    function setCQInfo(string paramList) returns(bool ret){

        string memory fiblnHash = paramList.getStringValueByKey(FIBLNHASH);
        string memory cblnHash = paramList.getStringValueByKey(CBLNHASH);
        uint CQAmount = uint(paramList.getIntValueByKey(CENTERQUOTA));
        uint CPAmount = uint(paramList.getIntValueByKey(CENTERPAID));
        uint CIAmount = uint(paramList.getIntValueByKey(CENTERISSUED));

        string memory couKey = couKey.concat(fiblnHash, cblnHash);
        couData.setCQMapCenterQuotaByKey(couKey,CQAmount);
        couData.setCQMapCenterPaidByKey(couKey,CPAmount);
        couData.setCQMapCenterIssuedByKey(couKey,CIAmount);
        couData.setCQMapfIPubkeyByKey(couKey,fiblnHash);

        Notify(RETURNCODE_SUCCESS,"Set CQInfo success.");
        return true;
    }

    /** 查询中心企业CQ相关的信息*/
    function getCQInfo(string paramList) constant public returns(byte[1024] retJson){
        string memory fiblnHash = paramList.getStringValueByKey(FIBLNHASH);
        string memory cblnHash = paramList.getStringValueByKey(CBLNHASH);
        string memory couKey = couKey.concat(fiblnHash,cblnHash);
        LibCOU.CQInfoTag memory CQInfo =  LibCOU.CQInfoTag(0, 0, 0, "","");
        CQInfo.CenterQuota = couData.getCQMapCenterQuotaByKey(couKey);
        CQInfo.CenterIssued = couData.getCQMapCenterIssuedByKey(couKey);
        CQInfo.CenterPaid = couData.getCQMapCenterPaidByKey(couKey);
        byte[1024] memory fIPubKeyArr = couData.getCQMapfIPubkeyByKey(couKey);
        CQInfo.fIPubkeySigned = LibUtil.BytesArrayToString(fIPubKeyArr);
        byte[1024] memory tmpfiBn = couData.getCQMapfiBnByKey(couKey);
        CQInfo.fiBn = LibUtil.BytesArrayToString(tmpfiBn);

        string memory tmpRetJson = LibCOU.CQInfotoJson(CQInfo);
        retJson = LibUtil.StringToBytesArray(tmpRetJson);
        return retJson;
    }

    /** 中心企业支付COU*/
    function PayIvByC(string paramList) returns(bool ret){
        
	string memory ivAddressHash = paramList.getStringValueByKey(IVADDRESSHASH);
        string memory fiblnHash = paramList.getStringValueByKey(FIBLNHASH);
        string memory cblnHash = paramList.getStringValueByKey(CBLNHASH);
        string memory toHash = paramList.getStringValueByKey(TOHASH);

        string memory couKey = couKey.concat(fiblnHash,cblnHash);
        if(!CheckUsertIllegal(fiblnHash,cblnHash)){
            Notify(RETURNCODE_FAIL,"COU transer fail. Illegal user.");
            return false;
        }

        paramList.getArrayValueByKey(COULIST, COUTransStrList);
        if(COUTransStrList.length != 1) {
            Notify(RETURNCODE_FAIL, "More than one payments is not allowed for C.");
            return false;
        }

        for(uint i=0; i<COUTransStrList.length; i++){
            LibCOU.COUTransaction memory couTransInfo = LibCOU.COUTransaction("",0,"",0,"",0);
            LibCOU.jsonCOUTransParse(couTransInfo, COUTransStrList[i]);

            string memory toCOUAddressHash = couTransInfo.toCOUAddress;
            uint amount = couTransInfo.toCOUAmount;

            if(couData.getCOUInfoMapAmountByKey(toCOUAddressHash) != 0){
                if(couData.getInvSts(ivAddressHash) != 0){
                    Notify(RETURNCODE_SUCCESS,"BcosPayIvByC COU transfer has been performed successfully previously.");
                    return true;
                } else {
                    Notify(RETURNCODE_FAIL,"COU transer fail. Output COU already exsist.");
                    return false;
                }
            }

            if(couData.getInvSts(ivAddressHash) != 0){
                Notify(RETURNCODE_FAIL,"One invoice can only be used once.");
                return false;
            }

            if(amount > couData.getCQMapCenterQuotaByKey(couKey)){
                Notify(RETURNCODE_FAIL,"COU transer fail. Insufficient CQ.");
                return false;
            }

            uint newCQAmount = couData.getCQMapCenterQuotaByKey(couKey) - amount;
            couData.setCQMapCenterQuotaByKey(couKey,newCQAmount);
            uint newCIAmount = couData.getCQMapCenterIssuedByKey(couKey) + amount;
            couData.setCQMapCenterIssuedByKey(couKey,newCIAmount);
            couData.setCOUInfoIntoMap(couTransInfo.toCOUAddress,toHash,couTransInfo.toCOUAmount);
        }

        couData.setInvSts(ivAddressHash);

        Notify(RETURNCODE_SUCCESS,"COU transfer success.");
        return true;
    }

    /** N级供应商支付COU*/
    function PayIvBySn(string paramList) returns(bool ret){

        uint totalInput = 0;
        uint totalOutput = 0;

        string memory ivAddressHash = paramList.getStringValueByKey(IVADDRESSHASH);
        string memory fromHash = paramList.getStringValueByKey(FROMHASH);
        string memory toHash = paramList.getStringValueByKey(TOHASH);

        paramList.getArrayValueByKey(COULIST, COUTransStrList);
        if(COUTransStrList.length == 0) {
            Notify(RETURNCODE_FAIL, "Zero payments is not allowed.");
            return false;
        }

        for(uint i=0; i<COUTransStrList.length; i++){
            LibCOU.COUTransaction memory couTransInfo = LibCOU.COUTransaction("",0,"",0,"",0);
            LibCOU.jsonCOUTransParse(couTransInfo, COUTransStrList[i]);

            if(couTransInfo.fromCOUAddress.equals("") || couTransInfo.toCOUAddress.equals("")){
                Notify(RETURNCODE_FAIL,"Invalid from or to COU address.");
                return false;
            }
            if ((couTransInfo.selfCOUAddress.equals("")) && (couTransInfo.fromCOUAmount != couTransInfo.toCOUAmount)) {
                Notify(RETURNCODE_FAIL, "Invalid self COU info. fromCOUAmount not equals toCOUAmount");
                return false;
            }
	        byte[1024] memory tmpowner = couData.getCOUInfoMapOwnerByKey(couTransInfo.fromCOUAddress);
	        string memory owner = LibUtil.BytesArrayToString(tmpowner);
            if(!fromHash.equals(owner)){
                Notify(RETURNCODE_FAIL,"COU transer fail. Invalid COU sender.");
                return false;
            }
            if((couData.getCOUInfoMapAmountByKey(couTransInfo.toCOUAddress) != 0) || (couData.getCOUInfoMapAmountByKey(couTransInfo.selfCOUAddress) != 0)){
                if(couData.getInvSts(ivAddressHash) != 0){
                    Notify(RETURNCODE_SUCCESS,"BcosPayIvBySn COU transfer has been performed successfully previously.");
                    return true;
                } else {
                    Notify(RETURNCODE_FAIL,"COU transer fail. Output COU already exsist.");
                    return false;
                }
            }

            if(couData.getInvSts(ivAddressHash) != 0){
                Notify(RETURNCODE_FAIL,"One invoice can only be used once.");
                return false;
            }

            totalInput = couTransInfo.fromCOUAmount;
            totalOutput = couTransInfo.toCOUAmount + couTransInfo.selfCOUAmout;
            if(totalInput != totalOutput){
                Notify(RETURNCODE_FAIL,"Input COU amount is not equal to output amount.");
                return false;
            }

            COUTransList.push(couTransInfo);
        }

        for(i=0; i<COUTransList.length; i++){
            if(!COUTransList[i].selfCOUAddress.equals("")){
                couData.setCOUInfoIntoMap(COUTransList[i].selfCOUAddress,fromHash,COUTransList[i].selfCOUAmout);
            }
            couData.setCOUInfoMapAmountByKey(COUTransList[i].fromCOUAddress,0);
            couData.setCOUInfoIntoMap(COUTransList[i].toCOUAddress,toHash,COUTransList[i].toCOUAmount);
        }

        for (i=0; i<COUTransList.length; ++i) {
            delete COUTransList[i];
        }
        COUTransList.length = 0;

        couData.setInvSts(ivAddressHash);
        Notify(RETURNCODE_SUCCESS,"COU transfer success.");
        return true;
    }
    
    /** SN使用COU进行融资 */
    function DFCBySn(string paramList) returns(bool ret){
        log("BcosDFCCOU:", paramList);
       
    	LibCOU.PayCOUTag memory payInfo = LibCOU.PayCOUTag("","",0,0,"","");
     	LibCOU.jsonDFCCOUParse(payInfo, paramList);
       	string memory couKey = couKey.concat(payInfo.fibln,payInfo.cbln);
        if(!CheckUsertIllegal(payInfo.fibln,payInfo.cbln)){
           	Notify(RETURNCODE_FAIL,"DFC COU by Sn fail. Invalid COU user,fibln not equals");
            return false;
        }
        if(payInfo.amount != couData.getCOUInfoMapAmountByKey(payInfo.COUAddress)){
            if(couData.getCOUInfoMapStatusByKey(payInfo.COUAddress) != 0){
                Notify(RETURNCODE_SUCCESS,"BcosDFCBySn SN DFC has been performed successfully previously.");
                return true;
            } else {
                Notify(RETURNCODE_FAIL,"DFC COU by Sn fail. Insufficient COU balance.");
                return false;
            }
        }
        if(payInfo.amount < payInfo.payAmount){
            Notify(RETURNCODE_FAIL,"DFC COU by Sn fail.  amount less than DFC amount");
            return false;
        }
 
        couData.setCOUInfoMapAmountByKey(payInfo.COUAddress,0);
        couData.setCOUInfoMapStatusByKey(payInfo.COUAddress,1);
        uint newCPAmount = couData.getCQMapCenterPaidByKey(couKey) + payInfo.amount;
        couData.setCQMapCenterPaidByKey(couKey,newCPAmount);

        Notify(RETURNCODE_SUCCESS,"SN DFC success.");
        return true;

    }
    
    /** SN使用COU进行CMD */
    function CMDBySn(string paramList) returns(bool ret){
        log("BcosCMDCOU:", paramList);     

     	LibCOU.PayCOUTag memory payInfo = LibCOU.PayCOUTag("","",0,0,"","");
       	LibCOU.jsonCMDCOUParse(payInfo, paramList);
        string memory couKey = couKey.concat(payInfo.fibln,payInfo.cbln);
        if(!CheckUsertIllegal(payInfo.fibln,payInfo.cbln)){
        	Notify(RETURNCODE_FAIL,"CMD COU by Sn fail. Invalid COU user");
            return false;
        }
        if(payInfo.amount != couData.getCOUInfoMapAmountByKey(payInfo.COUAddress)){
            if(couData.getCOUInfoMapStatusByKey(payInfo.COUAddress) != 0){
                Notify(RETURNCODE_SUCCESS,"BcosCMDBySn SN CMD has been performed successfully previously.");
                return true;
            } else {
                Notify(RETURNCODE_FAIL,"CMD COU by Sn fail. Insufficient COU balance.");
                return false;
            }
        }
        if(payInfo.amount != payInfo.payAmount){
            Notify(RETURNCODE_FAIL,"CMD COU by Sn fail.  amount is no equal to CMD amount");
            return false;
        }

        couData.setCOUInfoMapAmountByKey(payInfo.COUAddress,0);
        couData.setCOUInfoMapStatusByKey(payInfo.COUAddress,1);
        uint newCPAmount = couData.getCQMapCenterPaidByKey(couKey) + payInfo.amount;
        couData.setCQMapCenterPaidByKey(couKey,newCPAmount);

        Notify(RETURNCODE_SUCCESS,"SN CMD success.");
        return true;

    }
	
    /** 查询COU数额*/
    function getCOUAmout(string paramList) constant public returns(uint amount){

        string memory COUHash = paramList.getStringValueByKey(COUHASH);
        amount = couData.getCOUInfoMapAmountByKey(COUHash);
        return amount;
    }

    function getCOUOwner(string paramList) constant public returns(byte[1024] owner){

        string memory COUHash = paramList.getStringValueByKey(COUHASH);
        owner = couData.getCOUInfoMapOwnerByKey(COUHash);
        return owner;
    }

    /** 查询发票状态*/
    function getInvSts(string paramList) constant public returns(uint status){

        string memory ivAddressHash = paramList.getStringValueByKey(IVADDRESSHASH);
        status = couData.getInvSts(ivAddressHash);
        return status;
    }


    /** 查询中心企业COU额度是否已设置 true: 已设置 false: 未设置 */
    function getCenterQuotaStatus(string fibln, string cbln, string setCQTimeHash) internal returns(bool status){

        status = false;
        for(uint i=0; i<couData.getCQInfoListLength(); ++i) {
            var ( tmpCQfibln, tmpCQcbln, tmpCQTMHash ) = couData.getCQInfoListByIndex(i);
            string memory CQfibln = LibUtil.BytesArrayToString(tmpCQfibln);
            string memory CQcbln = LibUtil.BytesArrayToString(tmpCQcbln);
            string memory CQTMHash = LibUtil.BytesArrayToString(tmpCQTMHash);
            if(CQfibln.equals(fibln) && CQcbln.equals(cbln) && CQTMHash.equals(setCQTimeHash)) {
                status = true;
                break;
            }
        }
    }

    //check the user is illegal...
    function CheckUsertIllegal(string fibln, string cbln) internal returns (bool ret){
        string memory couKey = couKey.concat(fibln,cbln);
        byte[1024] memory fIPubKeyArr = couData.getCQMapfIPubkeyByKey(couKey);
        string memory fIPubKey = LibUtil.BytesArrayToString(fIPubKeyArr);
        if(!fibln.equals(fIPubKey)){
            return false;
        }
        return true;
    }

}
