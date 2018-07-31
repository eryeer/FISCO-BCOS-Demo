pragma solidity ^0.4.2;

import "OwnerNamed.sol";
import "ContractBase.sol";
import "COUManager.sol";
import "RhineFileManager.sol";
import "LibUtil.sol";


contract RhineCOUProxy is OwnerNamed, ContractBase("v-1.0") {
    using LibUtil for *;
    uint RETURNCODE_SUCCESS = 0;
    uint RETURNCODE_FAIL = 1;

    function RhineCOUProxy(){

    }

    event Notify(uint _errno, string _info);

    COUManager couManager;
    RhineFileManager rhineFileManager;

    // interface used to set address of COUManager contract
    function setCOUManagerAddress(address addr) returns (bool) {
        couManager = COUManager(addr);
        return true;
    }

    // interface used to set address of RhineFileManager contract
    function setRhineFileManagerAddress(address addr) returns (bool) {
        rhineFileManager = RhineFileManager(addr);
        return true;
    }

    /** 设置中心企业COU额度 */
    function BcosCOUSetCenterQuota(string fibln, string cbln, string setCQTimeHash, uint oldAmount, uint newAmount) returns(bool ret) {
        return couManager.BcosCOUSetCenterQuota(fibln, cbln, setCQTimeHash, oldAmount, newAmount);
    }

    /** 增加中心企业已发行COU数额*/
    function BcosCOUAddCenterIssued(string fibln, string cbln, uint amount) returns(bool ret) {
        return couManager.BcosCOUAddCenterIssued(fibln, cbln, amount);
    }

    /** 增加中心企业已支付COU数额*/
    function BcosCOUAddCenterPaid(string fibln, string cbln, uint amount) returns(bool ret) {
        return couManager.BcosCOUAddCenterPaid(fibln, cbln, amount);
    }

    /** 中心企业支付COU*/
    function BcosPayIvByC(string COUHash, string ivHash, string fibln, string from, string to) returns(bool ret) {
        return couManager.BcosPayIvByC(COUHash, ivHash, fibln, from, to);
    }

    /** N级供应商支付COU*/
    function BcosPayIvBySn(string COUList, string ivHash, string from, string to) returns(bool ret) {
        return couManager.BcosPayIvBySn(COUList, ivHash, from, to);
    }

    /** SN使用COU进行融资 */
    function BcosDFCBySn(string DFCCOUList) returns(bool ret) {
        return couManager.BcosDFCBySn(DFCCOUList);
    }

    /** SN使用COU进行CMD */
    function BcosCMDBySn(string CMDCOUList) returns(bool ret) {
        return couManager.BcosCMDBySn(CMDCOUList);
    }

    /** 查询COU数额*/
    function BcosQueryCOUAmout(string COUHash) constant public returns(uint amount) {
        amount = couManager.BcosQueryCOUAmout(COUHash);
    }

    /** 查询发票状态*/
    function BcosQueryInvSts(string ivHash) constant public returns(uint status) {
        status = couManager.BcosQueryInvSts(ivHash);
    }


    /** 上传文件信息 */
    function uploadFile(string fileIndex, string fileData) returns(bool ret) {
        if(rhineFileManager.SetFileInfo(fileIndex, fileData)) {
            Notify(RETURNCODE_SUCCESS,"upload File success.");
        } else {
            Notify(RETURNCODE_FAIL,"upload File failed.");
        }
    }

    /** 下载文件信息 */
    function downloadFile(string fileIndex) constant public returns(string fileData) {
        byte[1024] memory byteArr = rhineFileManager.GetFileInfo(fileIndex);
        fileData = LibUtil.BytesArrayToString(byteArr);
    }
}
