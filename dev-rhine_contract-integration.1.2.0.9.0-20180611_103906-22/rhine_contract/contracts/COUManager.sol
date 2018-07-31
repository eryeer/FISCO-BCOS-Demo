pragma solidity ^0.4.2;

import "OwnerNamed.sol";
import "LibString.sol";
import "LibCOU.sol";
import "LibInt.sol";
import "LibReturnCode.sol";
import "LibInvoice.sol";


contract COUManager is OwnerNamed{
    using LibInt for *;
    using LibString for *;
	using LibReturnCode for *;
    using LibInvoice for *;
    using LibCOU for *;

    uint RETURNCODE_SUCCESS = 0;
    uint RETURNCODE_FAIL = 1;

    LibCOU.PayCOUTag payCOUList;

    mapping(string=>LibCOU.COUTag) COUInfoMap;
    LibCOU.COUTag[] COUInfoList;

    string[] COUTransStrList;
    LibCOU.COUTransaction[] COUTransList ;

    mapping(string=>LibInvoice.Invoice) invoiceMap;
    LibInvoice.Invoice[] invoiceList;
    
	mapping(string =>LibCOU.CQInfoTag) couKeymap;

    // for storing Center Quota OK result
    LibCOU.SetCenterQuotaInfo[10] setCQInfoList;

    // indicates where to store next CQ set info
    uint IndexSetCQInfo = 0;

    function COUManager() {
        //im = new InvoiceManager();
    }
	event Notify(uint _errno, string _info);

    /** 设置中心企业COU额度 */
    function BcosCOUSetCenterQuota(string fibln, string cbln, string setCQTimeHash, uint oldAmount, uint newAmount) returns(bool ret){

        if(GetCenterQuotaSetStatus(fibln, cbln, setCQTimeHash) == 1){
            // CQ info has already been set
            Notify(RETURNCODE_SUCCESS,"Set CQ has been performed successfully previously.");
            return true;
        }


        string memory couKey = couKey.concat(fibln,cbln);
        if(couKeymap[couKey].CenterQuota != oldAmount){
            Notify(RETURNCODE_FAIL,"CQ stored on chain not equal to value queried by middle.");
            return false;
        }

        couKeymap[couKey].CenterQuota = newAmount;
        //couKeymap[couKey].fiBn = invalid_fiBn;
        couKeymap[couKey].fIPubkeySigned = fibln;

        // since CQ has been successfully set, store the relevant info into setCQInfoList storage as a mark
        SetCenterQuotaSetStatus(fibln, cbln, setCQTimeHash);
        
        Notify(RETURNCODE_SUCCESS,"Set CQ success.");
        return true;
    }

    /** 查询中心企业COU额度是否已设置 1: 已设置 0: 未设置 */
    function GetCenterQuotaSetStatus(string fibln, string cbln, string setCQTimeHash) internal returns(uint status){

        status = 0;
        for(uint i=0; i<10; ++i) {
            if(setCQInfoList[i].fibln.equals(fibln) && setCQInfoList[i].cbln.equals(cbln) && setCQInfoList[i].setCQTimeHash.equals(setCQTimeHash)) {
                status = 1;
                break;
            }
        }
    }

    /** 查询中心企业COU额度是否已设置 1: 已设置 0: 未设置 */
    function SetCenterQuotaSetStatus(string fibln, string cbln, string setCQTimeHash) internal returns(bool ret){

        setCQInfoList[IndexSetCQInfo].fibln = fibln;
        setCQInfoList[IndexSetCQInfo].cbln = cbln;
        setCQInfoList[IndexSetCQInfo].setCQTimeHash = setCQTimeHash;

        ++IndexSetCQInfo;
        if(IndexSetCQInfo > 9){
            IndexSetCQInfo = 0;
        }

        return true;
    }

    /** 增加中心企业已发行COU数额*/
    function BcosCOUAddCenterIssued(string fibln, string cbln, uint amount) returns(bool ret){

		string memory couKey = couKey.concat(fibln,cbln);
		if(!fibln.equals(couKeymap[couKey].fIPubkeySigned)){
            Notify(RETURNCODE_FAIL,"Add center issued fail. illegal user.");
            return false;
        }
        couKeymap[couKey].CenterIssued += amount;   

        Notify(RETURNCODE_SUCCESS,"Add center issued success.");
        return true;
    }

    /** 增加中心企业已支付COU数额*/
    function BcosCOUAddCenterPaid(string fibln, string cbln, uint amount) returns(bool ret){

		string memory couKey = couKey.concat(fibln,cbln);
		if(!fibln.equals(couKeymap[couKey].fIPubkeySigned)){
            Notify(RETURNCODE_FAIL,"Add center paid fail. illegal user.");
            return false;
        }
        couKeymap[couKey].CenterPaid += amount;

        Notify(RETURNCODE_SUCCESS,"Add center paid success.");
        return true;
    }

    /** 查询中心企业CQ相关的信息*/
    function BcosQueryCQInfo(string fibln, string cbln) constant public returns(string retJson){

		string memory couKey = couKey.concat(fibln,cbln);
        LibCOU.CQInfoTag memory CQInfo =  LibCOU.CQInfoTag(0, 0, 0, "","");
        CQInfo.CenterQuota = couKeymap[couKey].CenterQuota;
        CQInfo.CenterIssued =couKeymap[couKey].CenterIssued;
        CQInfo.CenterPaid = couKeymap[couKey].CenterPaid;
        CQInfo.fIPubkeySigned = couKeymap[couKey].fIPubkeySigned;
        CQInfo.fiBn = couKeymap[couKey].fiBn;
        retJson = LibCOU.CQInfotoJson(CQInfo);
        return retJson;
    }

    /** 中心企业支付COU*/
    function BcosPayIvByC(string COUHash, string ivHash, string fibln, string from, string to) returns(bool ret){

        log("BcosPayIvByC:", COUHash);
        string memory couKey = couKey.concat(fibln,from);
        if(!fibln.equals(couKeymap[couKey].fIPubkeySigned)){
            Notify(RETURNCODE_FAIL,"COU transer fail. Illegal user.");
            return false;
        }
        COUHash.getArrayValueByKey("couList", COUTransStrList);
        if(COUTransStrList.length >= 2) {
            Notify(RETURNCODE_FAIL, "More than one payments is not allowed for C.");
            return false;
        }

        for(uint i=0; i<COUTransStrList.length; i++){
            LibCOU.COUTransaction memory couTransInfo = LibCOU.COUTransaction("",0,"",0,"",0);
            LibCOU.COUTag memory couInfo = LibCOU.COUTag("","",0,0);

            LibCOU.jsonCOUTransParse(couTransInfo, COUTransStrList[i]);
            couInfo.COUHash = couTransInfo.toCOUAddress;
            couInfo.amount = couTransInfo.toCOUAmount;
            couInfo.COUOwner = to;
            couInfo.paidStatus = 0;
            if(COUInfoMap[couInfo.COUHash].amount != 0){
                if(BcosQueryInvSts(ivHash) != 0){
                    Notify(RETURNCODE_SUCCESS,"BcosPayIvByC COU transfer has been performed successfully previously.");
                    return true;
                } else {
                    Notify(RETURNCODE_FAIL,"COU transer fail. Output COU already exsist.");
                    return false;
                }
            }

            if(BcosQueryInvSts(ivHash) != 0){
                Notify(RETURNCODE_FAIL,"One invoice can only be used once.");
                return false;
            }

            if(couInfo.amount > couKeymap[couKey].CenterQuota){
                Notify(RETURNCODE_FAIL,"COU transer fail. Insufficient CQ.");
                return false;
            }

            couKeymap[couKey].CenterQuota -= couInfo.amount;
            couKeymap[couKey].CenterIssued += couInfo.amount;
            COUInfoMap[couInfo.COUHash] = couInfo;
            COUInfoList.push(couInfo);
        }

        UpdInvStsUsed(ivHash);

        Notify(RETURNCODE_SUCCESS,"COU transfer success.");
        return true;
    }

    /** N级供应商支付COU*/
    function BcosPayIvBySn(string COUList, string ivHash, string from, string to) returns(bool ret){

        log("BcosPayIvBySn:", COUList);

        /* for test */
        //string memory test = COUList.getArrayValueByKey("COUlist");
        //Notify(RETURNCODE_SUCCESS,test);
        uint totalInput = 0;
        uint totalOutput = 0;

        COUList.getArrayValueByKey("couList", COUTransStrList);
        //Notify(RETURNCODE_SUCCESS,COUTransStrList[0]);

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
            if(!from.equals(COUInfoMap[couTransInfo.fromCOUAddress].COUOwner)){
                Notify(RETURNCODE_FAIL,"COU transer fail. Invalid COU sender.");
                return false;
            }
            if((COUInfoMap[couTransInfo.toCOUAddress].amount != 0) || (COUInfoMap[couTransInfo.selfCOUAddress].amount != 0)){
                if(BcosQueryInvSts(ivHash) != 0){
                    Notify(RETURNCODE_SUCCESS,"BcosPayIvBySn COU transfer has been performed successfully previously.");
                    return true;
                } else {
                    Notify(RETURNCODE_FAIL,"COU transer fail. Output COU already exsist.");
                    return false;
                }
            }

            if(BcosQueryInvSts(ivHash) != 0){
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
            LibCOU.COUTag memory toCOUInfo = LibCOU.COUTag("","",0,0);
            LibCOU.COUTag memory selfCOUInfo = LibCOU.COUTag("","",0,0);

            toCOUInfo.COUHash = COUTransList[i].toCOUAddress;
            toCOUInfo.amount = COUTransList[i].toCOUAmount;
            toCOUInfo.COUOwner = to;
            toCOUInfo.paidStatus = 0;
            if(!COUTransList[i].selfCOUAddress.equals(""))
            {
                selfCOUInfo.COUHash = COUTransList[i].selfCOUAddress;
                selfCOUInfo.amount = COUTransList[i].selfCOUAmout;
                selfCOUInfo.COUOwner = from;
                selfCOUInfo.paidStatus = 0;
                COUInfoMap[selfCOUInfo.COUHash] = selfCOUInfo;
            }

            COUInfoMap[COUTransList[i].fromCOUAddress].amount = 0;
            COUInfoMap[toCOUInfo.COUHash] = toCOUInfo;
        }

        for (i=0; i<COUTransList.length; ++i) {
            delete COUTransList[i];
        }
        COUTransList.length = 0;

        UpdInvStsUsed(ivHash);
        Notify(RETURNCODE_SUCCESS,"COU transfer success.");
        return true;
    }
    
    
    /** SN使用COU进行融资 */
    function BcosDFCBySn(string DFCCOUList) returns(bool ret){
        log("BcosDFCCOU:", DFCCOUList);
       
    	LibCOU.PayCOUTag memory payInfo = LibCOU.PayCOUTag("","",0,0,"","");
     	LibCOU.jsonDFCCOUParse(payInfo, DFCCOUList);
       	string memory couKey = couKey.concat(payInfo.fibln,payInfo.cbln);
        if(!payInfo.fibln.equals(couKeymap[couKey].fIPubkeySigned)){
           	Notify(RETURNCODE_FAIL,"DFC COU by Sn fail. Invalid COU user,fibln not equals");
            return false;
        }
        if(payInfo.amount != COUInfoMap[payInfo.COUAddress].amount){
            if(COUInfoMap[payInfo.COUAddress].paidStatus != 0){
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
 
        COUInfoMap[payInfo.COUAddress].amount = 0;
        COUInfoMap[payInfo.COUAddress].paidStatus = 1;
        couKeymap[couKey].CenterPaid += payInfo.amount;

        Notify(RETURNCODE_SUCCESS,"SN DFC success.");
        return true;

    }
    
    /** SN使用COU进行CMD */
    function BcosCMDBySn(string CMDCOUList) returns(bool ret){
        log("BcosCMDCOU:", CMDCOUList);     

     	LibCOU.PayCOUTag memory payInfo = LibCOU.PayCOUTag("","",0,0,"","");
       	LibCOU.jsonCMDCOUParse(payInfo, CMDCOUList);
        string memory couKey = couKey.concat(payInfo.fibln,payInfo.cbln);
        if(!payInfo.fibln.equals(couKeymap[couKey].fIPubkeySigned)){
        	Notify(RETURNCODE_FAIL,"CMD COU by Sn fail. Invalid COU user");
            return false;
        }
        if(payInfo.amount != COUInfoMap[payInfo.COUAddress].amount){
            if(COUInfoMap[payInfo.COUAddress].paidStatus != 0){
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

        COUInfoMap[payInfo.COUAddress].amount = 0;
        COUInfoMap[payInfo.COUAddress].paidStatus = 1;
        couKeymap[couKey].CenterPaid += payInfo.amount;

        Notify(RETURNCODE_SUCCESS,"SN CMD success.");
        return true;

    }
	
    /** 查询COU数额*/
    function BcosQueryCOUAmout(string COUHash) constant public returns(uint amount){

        amount = COUInfoMap[COUHash].amount;
    }
    function BcosQueryCOUOwner(string COUHash) constant public returns(string owner){

        owner = COUInfoMap[COUHash].COUOwner;
    }

    /** 查询COU owner*/
    //function BcosQueryCOUOwner(string COUHash) constant public returns(string owner){

        //owner = COUInfoMap[COUHash].COUOwner;
    //}

    /** 更新发票状态为已使用*/
    function UpdInvStsUsed(string ivHash) internal returns(bool ret){
        log("update invoice:", ivHash);

        LibInvoice.Invoice memory invoice = LibInvoice.Invoice("",LibInvoice.InvoiceSts.UNUSED);
        invoice.invHash = ivHash;
        invoice.invSts = LibInvoice.InvoiceSts.USED;

        invoiceMap[ivHash] = invoice;
        invoiceList.push(invoice);

        return true;
    }

    /** 查询发票状态*/
    function BcosQueryInvSts(string ivHash) constant public returns(uint status){

        status = uint(invoiceMap[ivHash].invSts);
    }


}
