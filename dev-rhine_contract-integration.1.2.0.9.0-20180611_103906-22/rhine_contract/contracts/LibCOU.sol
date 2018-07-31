pragma solidity ^0.4.2;

import "LibString.sol";
import "LibInt.sol";

library LibCOU{
    using LibCOU for *;
    using LibString for *;
    using LibInt for *;

    struct COUTransaction{
        string fromCOUAddress;
        uint fromCOUAmount;
        string toCOUAddress;
        uint toCOUAmount;
        string selfCOUAddress;
        uint selfCOUAmout;
    }

    struct COUTag {
        string COUHash;
        string COUOwner;
        uint amount;
        uint paidStatus;
    }

    struct CQInfoTag{
        uint CenterQuota;
        uint CenterIssued;
        uint CenterPaid;
        string fIPubkeySigned;
        string fiBn;
    }
    
    struct PayCOUTag{
    	string COUAddress;
    	string snbln;
    	uint amount;
    	uint payAmount;
    	string fibln;
        string cbln;
    }

    // struct to store Center Quota set OK result
    struct SetCenterQuotaInfo{
        string fibln;
        string cbln;
        string setCQTimeHash;
    }

    function COUReset(COUTag _self) internal returns (bool _success) {

      _self.COUHash = "";
	  _self.COUOwner = "";
      _self.amount = 0;

      return true;
    }


    function toJson(COUTag storage _self) internal returns(string _strjson) {

        _strjson = "{";
        _strjson = _strjson.concat(_self.COUHash.toKeyValue("toCOUAddress"), ",");
        _strjson = _strjson.concat(_self.COUOwner.toKeyValue("toCOUOwner"), ",");
        _strjson = _strjson.concat(uint(_self.amount).toKeyValue("toCOUAmount"), "}");
		
    }    

    function jsonParse(COUTag _self, string _strjson) internal returns(bool) {

        _self.COUHash = _strjson.getStringValueByKey("toCOUAddress");
        _self.COUOwner = _strjson.getStringValueByKey("toCOUOwner");
        _self.amount = uint(_strjson.getIntValueByKey("toCOUAmount"));

        return true;
    }
    
     function jsonDFCCOUParse(PayCOUTag _self, string _strjson) internal returns(bool) {

        _self.COUAddress = _strjson.getStringValueByKey("couAddressHash");
        _self.snbln = _strjson.getStringValueByKey("snblnHash");
        _self.amount = uint(_strjson.getIntValueByKey("amount"));
        _self.payAmount = uint(_strjson.getIntValueByKey("dfcAmount"));
        _self.fibln = _strjson.getStringValueByKey("fiblnHash");
         _self.cbln = _strjson.getStringValueByKey("cblnHash");
        return true;
    }
    function jsonCMDCOUParse(PayCOUTag _self, string _strjson) internal returns(bool) {

        _self.COUAddress = _strjson.getStringValueByKey("couAddressHash");
        _self.snbln = _strjson.getStringValueByKey("snblnHash");
        _self.amount = uint(_strjson.getIntValueByKey("amount"));
        _self.payAmount = uint(_strjson.getIntValueByKey("cmdAmount"));
        _self.fibln = _strjson.getStringValueByKey("fiblnHash");
        _self.cbln = _strjson.getStringValueByKey("cblnHash");
        return true;
    }
    function jsonCOUTransParse(COUTransaction _self, string _strjson) internal returns(bool){
        _self.fromCOUAddress = _strjson.getStringValueByKey("fromCOUAddressHash");
        _self.fromCOUAmount = uint(_strjson.getIntValueByKey("fromCOUAmount"));
        _self.toCOUAddress = _strjson.getStringValueByKey("toCOUAddressHash");
        _self.toCOUAmount = uint(_strjson.getIntValueByKey("toCOUAmount"));
        _self.selfCOUAddress = _strjson.getStringValueByKey("selfCOUAddressHash");
        _self.selfCOUAmout = uint(_strjson.getIntValueByKey("selfCOUAmount"));
        return true;
    }

    function CQInfotoJson(CQInfoTag _self) internal returns(string _strjson) {
        _strjson = "{";
        _strjson = _strjson.concat(_self.fIPubkeySigned.toKeyValue("fIPubkeySigned"),",");
        _strjson = _strjson.concat(_self.fiBn.toKeyValue("fiBn"),",");
        _strjson = _strjson.concat(uint(_self.CenterQuota).toKeyValue("centerQuota"), ",");
        _strjson = _strjson.concat(uint(_self.CenterIssued).toKeyValue("centerIssued"), ",");
        _strjson = _strjson.concat(uint(_self.CenterPaid).toKeyValue("centerPaid"), "}");
        
    }
}
