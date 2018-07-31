pragma solidity ^0.4.2;

library LibUtil {
    using LibUtil for *;

    function StringToBytesArray(string src) internal returns (byte[1024] byteArr) {

        bytes memory byteSrc = bytes(src);
        uint160 _length = uint160(byteSrc.length);
        uint32 length = uint32(_length);
        bytes4 b = bytes4(length);
        for(uint i=0; i<4; ++i) {
            byteArr[i] = b[i];
        }

        for(i=0; i<length; ++i) {
            byteArr[i+4] = byteSrc[i];
        }

        return byteArr;
    }

    function BytesArrayToString(byte[1024] byteArr) internal returns (string ret) {
        // the front four bytes of byteArr represents for length of the stored string data.
        // and the byte order is just the binary expression of the length integer.
        uint len = uint8(byteArr[0]) * 16777216 + uint8(byteArr[1]) * 65536 + uint8(byteArr[2]) * 256 +  uint8(byteArr[3]);

        uint160 _length = uint160(len);
        uint32 length;
        length = uint32(_length);

        bytes memory data = new bytes(length);

        for(uint i=0; i<length; ++i) {
            data[i] = byteArr[i+4];
        }

        ret = string(data);
    }
}
