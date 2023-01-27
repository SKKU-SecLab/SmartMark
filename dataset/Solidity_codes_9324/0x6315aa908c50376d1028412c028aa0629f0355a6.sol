

pragma solidity 0.6.12;

contract FiatTokenUtil {

    uint256 private constant _TRANSFER_PARAM_SIZE = 168;
    uint256 private constant _SIGNATURE_SIZE = 65;
    bytes4 private constant _TRANSFER_WITH_AUTHORIZATION_SELECTOR = 0xe3ee160e;

    address private _fiatToken;

    event TransferFailed(address indexed authorizer, bytes32 indexed nonce);

    constructor(address fiatToken) public {
        _fiatToken = fiatToken;
    }

    function transferWithMultipleAuthorizations(
        bytes calldata params,
        bytes calldata signatures,
        bool atomic
    ) external returns (bool) {

        uint256 num = params.length / _TRANSFER_PARAM_SIZE;
        require(num > 0, "FiatTokenUtil: no transfer provided");
        require(
            num * _TRANSFER_PARAM_SIZE == params.length,
            "FiatTokenUtil: length of params is invalid"
        );
        require(
            signatures.length / _SIGNATURE_SIZE == num &&
                num * _SIGNATURE_SIZE == signatures.length,
            "FiatTokenUtil: length of signatures is invalid"
        );

        uint256 numSuccessful = 0;

        for (uint256 i = 0; i < num; i++) {
            uint256 paramsOffset = i * _TRANSFER_PARAM_SIZE;
            uint256 sigOffset = i * _SIGNATURE_SIZE;

            bytes memory fromTo = _unpackAddresses(
                abi.encodePacked(params[paramsOffset:paramsOffset + 40])
            );
            bytes memory other4 = abi.encodePacked(
                params[paramsOffset + 40:paramsOffset + _TRANSFER_PARAM_SIZE]
            );
            uint8 v = uint8(signatures[sigOffset]);
            bytes memory rs = abi.encodePacked(
                signatures[sigOffset + 1:sigOffset + _SIGNATURE_SIZE]
            );

            (bool success, bytes memory returnData) = _fiatToken.call(
                abi.encodePacked(
                    _TRANSFER_WITH_AUTHORIZATION_SELECTOR,
                    fromTo,
                    other4,
                    abi.encode(v),
                    rs
                )
            );

            if (atomic && !success) {
                _revertWithReasonFromReturnData(returnData);
            }

            if (success) {
                numSuccessful++;
            } else {
                (address from, ) = abi.decode(fromTo, (address, address));
                (, , , bytes32 nonce) = abi.decode(
                    other4,
                    (uint256, uint256, uint256, bytes32)
                );
                emit TransferFailed(from, nonce);
            }
        }

        return numSuccessful == num;
    }

    function _unpackAddresses(bytes memory packed)
        private
        pure
        returns (bytes memory)
    {

        address addr1;
        address addr2;
        assembly {
            addr1 := mload(add(packed, 20))
            addr2 := mload(add(packed, 40))
        }
        return abi.encode(addr1, addr2);
    }

    function _revertWithReasonFromReturnData(bytes memory returnData)
        private
        pure
    {

        if (returnData.length < 100) {
            revert("FiatTokenUtil: call failed");
        }

        string memory reason;
        assembly {
            reason := add(returnData, 0x44)
        }

        revert(reason);
    }
}