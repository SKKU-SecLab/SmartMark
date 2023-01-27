

pragma solidity 0.5.1;
pragma experimental ABIEncoderV2;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function _supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function _supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return _supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function _supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!_supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool success, bool result)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);

        assembly {
            let encodedParams_data := add(0x20, encodedParams)
            let encodedParams_size := mload(encodedParams)

            let output := mload(0x40)    // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)

            success := staticcall(
                30000,                   // 30k gas
                account,                 // To addr
                encodedParams_data,
                encodedParams_size,
                output,
                0x20                     // Outputs are 32 bytes long
            )

            result := mload(output)      // Load the result
        }
    }
}

interface TokenDecimals {

    function decimals() external view returns (uint);

}

contract TokensDecimalsView {

    using ERC165Checker for address;
    
    struct Result {
        bool supportsDecimals;
        uint decimals;
    }
    
    function getDecimals(address[] calldata _tokenAddresses) external view returns (Result[500] memory results) {

        bytes4 INTERFACE_ID_DECIMALS = 0x313ce567;
        for (uint i = 0; i < _tokenAddresses.length; i++) {
            if (_tokenAddresses[i]._supportsInterface(INTERFACE_ID_DECIMALS)) {
                TokenDecimals token = TokenDecimals(_tokenAddresses[i]);
                results[i] = Result(true, token.decimals());
            } else {
                results[i] = Result(false, 0);
            }
            
        }
    }
   
    function implementsDecimals(address _addr)
        private
        returns (bool _implementsDecimals)
    {

        bytes32 sig = bytes4(keccak256("decimals()"));
        bool _success = false;
        assembly {
            let x := mload(0x40)    // get free memory
            mstore(x, sig)          // store signature into it
            _success := call(
                5000,   // 5k gas
                _addr,  // to _addr
                0,      // 0 value
                x,      // input is x
                4,      // input length is 4
                x,      // store output to x
                32      // 1 output, 32 bytes
            )
            _implementsDecimals := and(_success, mload(x))
        }
    }
}