pragma solidity ^0.4.2;

import "LibString.sol";
import "LibInt.sol";

library LibInvoice{
    using LibInvoice for *;
    using LibString for *;
    using LibInt for *;

    enum InvoiceSts {
        UNUSED,
        USED
    }

    struct Invoice {
        string invHash;
        InvoiceSts invSts;
    }

    function InvoiceReset(Invoice _self) internal returns (bool _success) {

      _self.invHash = "";
	  _self.invSts = InvoiceSts.UNUSED;

      return true;
    }

    function toJson(Invoice storage _self) internal returns(string _strjson) {

        _strjson = "{";
        _strjson = _strjson.concat(_self.invHash.toKeyValue("invHash"), ",");
        _strjson = _strjson.concat(uint(_self.invSts).toKeyValue("invSts"), "}");
		
    }

    function jsonParse(Invoice _self, string _strjson) internal returns(bool) {

        _self.invHash = _strjson.getStringValueByKey("invHash");
        _self.invSts = InvoiceSts(_strjson.getIntValueByKey("invSts"));

        return true;
    }
}
