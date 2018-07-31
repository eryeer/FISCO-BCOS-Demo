pragma solidity ^0.4.2;

import "LibUtil.sol";
import "LibCOU.sol";
import "LibInvoice.sol";

contract COUData{
    using LibUtil for *;
    using LibInvoice for *;

    LibCOU.PayCOUTag payCOUList;

    mapping(string=>LibCOU.COUTag) COUInfoMap;
    LibCOU.COUTag[] COUInfoList;

    string[] COUTransStrList;
    LibCOU.COUTransaction[] COUTransList ;

    mapping(string=>LibInvoice.Invoice) invoiceMap;
    LibInvoice.Invoice[] invoiceList;

    mapping(string =>LibCOU.CQInfoTag) couKeymap;

    // for storing Center Quota OK result
    LibCOU.SetCenterQuotaInfo[10] CQInfoList;

    // indicates where to store next CQ set info
    uint IndexSetCQInfo = 0;

    function COUData() {
    }

    function getCQInfoListLength() public constant returns (uint len){
        return CQInfoList.length;
    }

    function getCQInfoListByIndex(uint i) public constant returns (byte[1024] fibln,byte[1024] cbln,byte[1024] CQTMHash){
        string memory tmpfibln =CQInfoList[i].fibln;
        fibln = LibUtil.StringToBytesArray(tmpfibln);

        string memory tmpcbln =CQInfoList[i].cbln;
        cbln = LibUtil.StringToBytesArray(tmpcbln);

        string memory tmpCQTMHash =CQInfoList[i].setCQTimeHash;
        CQTMHash = LibUtil.StringToBytesArray(tmpCQTMHash);

        return (fibln, cbln,CQTMHash);
    }

    function setCQInfoIntoList(string fibln, string cbln, string setCQTimeHash) public returns (bool ret){
        CQInfoList[IndexSetCQInfo].fibln = fibln;
        CQInfoList[IndexSetCQInfo].cbln = cbln;
        CQInfoList[IndexSetCQInfo].setCQTimeHash = setCQTimeHash;

        ++IndexSetCQInfo;
        if(IndexSetCQInfo > 9){
            IndexSetCQInfo = 0;
        }

        return true;
    }

    function getCQMapCenterQuotaByKey(string key) public constant returns (uint amount){
        amount = couKeymap[key].CenterQuota;
        return amount;
    }

    function setCQMapCenterQuotaByKey(string key, uint amount) public returns (bool ret){
        couKeymap[key].CenterQuota = amount;
        return true;
    }

    function getCQMapCenterIssuedByKey(string key) public constant returns (uint amount){
        amount = couKeymap[key].CenterIssued;
        return amount;
    }

    function setCQMapCenterIssuedByKey(string key, uint amount) public returns (bool ret){
        couKeymap[key].CenterIssued = amount;
        return true;
    }

    function getCQMapCenterPaidByKey(string key) public constant returns (uint amount){
        amount = couKeymap[key].CenterPaid;
        return amount;
    }

    function setCQMapCenterPaidByKey(string key, uint amount) public returns (bool ret){
        couKeymap[key].CenterPaid = amount;
        return true;
    }

    function setCQMapfIPubkeyByKey(string key, string fibln) public returns (bool ret){
        couKeymap[key].fIPubkeySigned = fibln;
        return true;
    }

    function getCQMapfIPubkeyByKey(string key) public returns (byte[1024] pubkeyArr){
        string memory tmpPubkey = couKeymap[key].fIPubkeySigned;
        pubkeyArr = LibUtil.StringToBytesArray(tmpPubkey);
        return pubkeyArr;
    }

    function setCQMapfiBnByKey(string key, string fibln) public returns (bool ret){
        couKeymap[key].fiBn = fibln;
        return true;
    }

    function getCQMapfiBnByKey(string key) public returns (byte[1024] fiBnArr){
        string memory tmpfiBn = couKeymap[key].fiBn;
        fiBnArr = LibUtil.StringToBytesArray(tmpfiBn);
        return fiBnArr;
    }

    function setCOUInfoIntoMap(string COUHash, string Owner, uint amount) public returns (bool ret){
        LibCOU.COUTag memory couInfo = LibCOU.COUTag("","",0,0);
        couInfo.COUHash = COUHash;
        couInfo.COUOwner = Owner;
        couInfo.amount = amount;
        couInfo.paidStatus = 0;
        COUInfoMap[COUHash] = couInfo;

        return true;
    }

    function getCOUInfoMapAmountByKey(string COUHash) public constant returns (uint amount){
        amount = COUInfoMap[COUHash].amount;
        return amount;
    }

    function setCOUInfoMapAmountByKey(string COUHash, uint amt) public returns (bool ret){
        COUInfoMap[COUHash].amount = amt;
        return true;
    }

    function getCOUInfoMapOwnerByKey(string COUHash) public constant returns (byte[1024] owner){
        string memory tmpOwner = COUInfoMap[COUHash].COUOwner;
        owner = LibUtil.StringToBytesArray(tmpOwner);
        return owner;
    }

    function getCOUInfoMapStatusByKey(string COUHash) public constant returns (uint status){
        status = COUInfoMap[COUHash].paidStatus;
        return status;
    }

    function setCOUInfoMapStatusByKey(string COUHash, uint status) public returns (bool ret){
        COUInfoMap[COUHash].paidStatus = status;
        return true;
    }

    function setInvSts(string ivHash) public returns (bool ret){
        LibInvoice.Invoice memory invoice = LibInvoice.Invoice("",LibInvoice.InvoiceSts.UNUSED);
        invoice.invHash = ivHash;
        invoice.invSts = LibInvoice.InvoiceSts.USED;

        invoiceMap[ivHash] = invoice;
        return true;
    }

    function getInvSts(string ivHash) public constant returns (uint status){
        status = uint(invoiceMap[ivHash].invSts);
        return status;
    }
}
