
pragma solidity ^0.4.23;


contract ContractProbe {


    function probe(address _addr) public view returns (bool isContract, address forwardedTo) {

        bytes memory clone = hex"363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3";
        uint size;
        bytes memory code;

        assembly {  //solhint-disable-line
            size := extcodesize(_addr)
        }

        isContract = size > 0;
        forwardedTo = _addr;

        if (size <= 45 && size >= 41) {
            bool matches = true;
            uint i;

            assembly { //solhint-disable-line
                code := mload(0x40)
                mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
                mstore(code, size)
                extcodecopy(_addr, add(code, 0x20), 0, size)
            }
            for (i = 0; matches && i < 9; i++) { 
                matches = code[i] == clone[i];
            }
            for (i = 0; matches && i < 15; i++) {
                if (i == 4) {
                    matches = code[code.length - i - 1] == byte(uint(clone[45 - i - 1]) - (45 - size));
                } else {
                    matches = code[code.length - i - 1] == clone[45 - i - 1];
                }
            }
            if (code[9] != byte(0x73 - (45 - size))) {
                matches = false;
            }
            uint forwardedToBuffer;
            if (matches) {
                assembly { //solhint-disable-line
                    forwardedToBuffer := mload(add(code, 30))
                }
                forwardedToBuffer &= (0x1 << 20 * 8) - 1;
                forwardedTo = address(forwardedToBuffer >> ((45 - size) * 8));
            }
        }
    }
}