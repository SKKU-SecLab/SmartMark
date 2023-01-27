
pragma solidity 0.5.12;

 

contract AccountStateV1 {

    uint256 public lastInitializedVersion;
    mapping(address => bool) public authKeys;
    uint256 public nonce;
    uint256 public numAuthKeys;
}


pragma solidity 0.5.12;



contract AccountState is AccountStateV1 {}



pragma solidity 0.5.12;


contract AccountEvent {



    event FundsReceived(address indexed sender, uint256 indexed value);
    event AddedAuthKey(address indexed authKey);
    event RemovedAuthKey(address indexed authKey);
    event SwappedAuthKeys(address indexed oldAuthKey, address indexed newAuthKey);

    event InvalidAuthkey();
    event InvalidTransactionDataSigner();
    event CallFailed(bytes32 encodedData);


    event Upgraded(address indexed implementation);

}


pragma solidity 0.5.12;




contract AccountInitializeV1 is AccountState, AccountEvent {


    function initializeV1(
        address _authKey
    )
        public
    {

        require(lastInitializedVersion == 0);
        lastInitializedVersion = 1;

        authKeys[_authKey] = true;
        numAuthKeys += 1;
        emit AddedAuthKey(_authKey);
    }
}


pragma solidity 0.5.12;



contract AccountInitialize is AccountInitializeV1 {}



pragma solidity 0.5.12;

contract IERC1271 {

  function isValidSignature(
    bytes memory _messageHash,
    bytes memory _signature)
    public
    view
    returns (bytes4 magicValue);

}


pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



pragma solidity ^0.5.0;


library BytesLib {

    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
                    add(
                        fslot,
                        add(
                            mul(
                                div(
                                    mload(add(_postBytes, 0x20)),
                                    exp(0x100, sub(32, mlength))
                                ),
                                exp(0x100, sub(32, newlength))
                            ),
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                
                for { 
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8));
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12));
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16));
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }
}


pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;







contract BaseAccount is AccountInitialize, IERC1271 {

    using SafeMath for uint256;
    using ECDSA for bytes32;
    using BytesLib for bytes;

    uint256 constant CHAIN_ID = 1;

    bytes4 constant internal VALID_SIG = 0x20c13b0b;
    bytes4 constant internal INVALID_SIG = 0xffffffff;

    modifier onlyValidAuthKeyOrSelf {

        _validateAuthKey(msg.sender);
        _;
    }

    function () external payable {}


    function getNonce() public view returns (uint256) {

        return nonce;
    }

    function getChainId() public view returns (uint256) {

        return CHAIN_ID;
    }


    function executeTransaction(
        address _destination,
        uint256 _value,
        bytes memory _data,
        uint256 _gasLimit
    )
        public
        onlyValidAuthKeyOrSelf
        returns (bytes memory)
    {

        return _executeTransaction(_destination, _value, _data, _gasLimit);
    }

    function addAuthKey(address _authKey) public onlyValidAuthKeyOrSelf {

        require(!authKeys[_authKey], "Auth key already added");
        authKeys[_authKey] = true;
        numAuthKeys += 1;
        emit AddedAuthKey(_authKey);
    }

    function addMultipleAuthKeys(address[] memory _authKeys) public onlyValidAuthKeyOrSelf {

        for (uint256 i = 0; i < _authKeys.length; i++) {
            addAuthKey(_authKeys[i]);
        }
    }

    function removeAuthKey(address _authKey) public onlyValidAuthKeyOrSelf {

        require(authKeys[_authKey], "Auth key not yet added");
        require(numAuthKeys > 1, "Cannot remove last auth key");
        authKeys[_authKey] = false;
        numAuthKeys -= 1;
        emit RemovedAuthKey(_authKey);
    }

    function removeMultipleAuthKeys(address[] memory _authKeys) public onlyValidAuthKeyOrSelf {

        for (uint256 i = 0; i < _authKeys.length; i++) {
            removeAuthKey(_authKeys[i]);
        }
    }

    function swapAuthKeys(
        address _oldAuthKey,
        address _newAuthKey
    )
        public
        onlyValidAuthKeyOrSelf
    {

        require(authKeys[_oldAuthKey], "Old auth key does not exist");
        require(!authKeys[_newAuthKey], "New auth key already exists");
        addAuthKey(_newAuthKey);
        removeAuthKey(_oldAuthKey);
        emit SwappedAuthKeys(_oldAuthKey, _newAuthKey);
    }

    function swapMultipleAuthKeys(
        address[] memory _oldAuthKeys,
        address[] memory _newAuthKeys
    )
        public
    {

        require(_oldAuthKeys.length == _newAuthKeys.length, "Input arrays not equal length");
        for (uint256 i = 0; i < _oldAuthKeys.length; i++) {
            swapAuthKeys(_oldAuthKeys[i], _newAuthKeys[i]);
        }
    }

    function isValidSignature(
        bytes memory _msg,
        bytes memory _signatures
    )
        public
        view
        returns (bytes4)
    {

        if (_signatures.length == 65) {
            return isValidAuthKeySignature(_msg, _signatures);
        } else if (_signatures.length == 130) {
            return isValidLoginKeySignature(_msg, _signatures);
        } else {
            revert("Invalid _signatures length");
        }
    }

    function isValidAuthKeySignature(
        bytes memory _msg,
        bytes memory _signature
    )
        public
        view
        returns (bytes4)
    {

        address authKeyAddress = _getEthSignedMessageHash(_msg).recover(
            _signature
        );

        if(authKeys[authKeyAddress]) {
            return VALID_SIG;
        } else {
            return INVALID_SIG;
        }
    }

    function isValidLoginKeySignature(
        bytes memory _msg,
        bytes memory _signatures
    )
        public
        view
        returns (bytes4)
    {

        bytes memory msgHashSignature = _signatures.slice(0, 65);
        bytes memory loginKeyAuthorizationSignature = _signatures.slice(65, 65);

        address loginKeyAddress = _getEthSignedMessageHash(_msg).recover(
            msgHashSignature
        );

        bytes32 loginKeyAuthorizationMessageHash = keccak256(abi.encodePacked(
            loginKeyAddress
        )).toEthSignedMessageHash();

        address authorizationSigner = loginKeyAuthorizationMessageHash.recover(
            loginKeyAuthorizationSignature
        );

        if(authKeys[authorizationSigner]) {
            return VALID_SIG;
        } else {
            return INVALID_SIG;
        }
    }


    function _validateAuthKey(address _authKey) internal view {

        require(authKeys[_authKey] == true || msg.sender == address(this), "Auth key is invalid");
    }

    function _validateAuthKeyMetaTxSigs(
        bytes32 _txDataMessageHash,
        bytes memory _transactionDataSignature
    )
        internal
        view
        returns (address)
    {

        address transactionDataSigner = _txDataMessageHash.recover(_transactionDataSignature);
        _validateAuthKey(transactionDataSigner);
        return transactionDataSigner;
    }

    function validateLoginKeyMetaTxSigs(
        bytes32 _txDataMessageHash,
        bytes memory _transactionDataSignature,
        bytes memory _loginKeyAuthorizationSignature
    )
        public
        view
        returns (address)
    {

        address transactionDataSigner = _txDataMessageHash.recover(
            _transactionDataSignature
        );

        bytes32 loginKeyAuthorizationMessageHash = keccak256(abi.encodePacked(
            transactionDataSigner
        )).toEthSignedMessageHash();

        address authorizationSigner = loginKeyAuthorizationMessageHash.recover(
            _loginKeyAuthorizationSignature
        );
        _validateAuthKey(authorizationSigner);

        return transactionDataSigner;
    }

    function _executeTransaction(
        address _destination,
        uint256 _value,
        bytes memory _data,
        uint256 _gasLimit
    )
        internal
        returns (bytes memory)
    {

        (bool success, bytes memory response) = _destination.call.gas(_gasLimit).value(_value)(_data);

        if (!success) {
            bytes32 encodedData = _encodeData(nonce, _destination, _value, _data);
            emit CallFailed(encodedData);
        }

        nonce++;

        return response;
    }

    function _issueRefund(
        uint256 _startGas,
        uint256 _gasPrice
    )
        internal
    {

        uint256 _gasUsed = _startGas.sub(gasleft());
        require(_gasUsed.mul(_gasPrice) <= address(this).balance, "Insufficient gas for refund");
        msg.sender.transfer(_gasUsed.mul(_gasPrice));
    }

    function _getGasBuffer(bytes memory _txData) internal view returns (uint256) {

        uint256 costPerByte = 68;
        uint256 txDataCost = _txData.length * costPerByte;
        
        uint256 costPerCheck = 10000;
        return txDataCost.add(costPerCheck);
    }

    function _encodeData(
        uint256 _nonce,
        address _destination,
        uint256 _value,
        bytes memory _data
    )
        internal
        pure
        returns (bytes32)
    {

        return keccak256(abi.encodePacked(
            _nonce,
            _destination,
            _value,
            _data
        ));
    }

    function _getEthSignedMessageHash(bytes memory _msg) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", _uint2str(_msg.length), _msg));
    }

    function _uint2str(uint _num) private pure returns (string memory _uintAsString) {

        if (_num == 0) {
            return "0";
        }
        uint i = _num;
        uint j = _num;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }
}


pragma solidity 0.5.12;



contract LoginKeyMetaTxAccount is BaseAccount {


    function executeMultipleLoginKeyMetaTx(
        address[] memory _destinations,
        bytes[] memory _datas,
        uint256[] memory _values,
        uint256[] memory _gasLimits,
        bytes[] memory _transactionDataSignatures,
        bytes memory _loginKeyAuthorizationSignature
    )
        public
        returns (bytes[] memory)
    {

        uint256 startGas = gasleft();

        verifyLoginKeyParamDataLength(
            _destinations, _datas, _values, _gasLimits, _transactionDataSignatures
        );

        bytes[] memory returnValues = new bytes[](_destinations.length);
        for(uint i = 0; i < _destinations.length; i++) {
            returnValues[i] = _executeLoginKeyMetaTx(
                _destinations[i], _datas[i], _values[i], _gasLimits[i], _transactionDataSignatures[i], _loginKeyAuthorizationSignature
            );
        }

        _issueRefund(startGas, tx.gasprice);

        return returnValues;
    }

    function isValidLoginKey(
        address _transactionDataSigner,
        bytes memory _loginKeyAuthorizationSignature
    )
        public
        view
        returns (bool)
    {

        bytes32 loginKeyAuthorizationMessageHash = keccak256(abi.encodePacked(
            _transactionDataSigner
        )).toEthSignedMessageHash();

        address authorizationSigner = loginKeyAuthorizationMessageHash.recover(
            _loginKeyAuthorizationSignature
        );

        return authKeys[authorizationSigner];
    }


    function _executeLoginKeyMetaTx(
        address _destination,
        bytes memory _data,
        uint256 _value,
        uint256 _gasLimit,
        bytes memory _transactionDataSignature,
        bytes memory _loginKeyAuthorizationSignature
    )
        internal
        returns (bytes memory)
    {

        uint256 startGas = gasleft();

        require(_checkDestination(_destination), "Login key is not able to upgrade to proxy");

        bytes32 _txDataMessageHash = keccak256(abi.encodePacked(
            address(this),
            msg.sig,
            CHAIN_ID,
            _destination,
            _data,
            _value,
            nonce,
            tx.gasprice,
            _gasLimit
        )).toEthSignedMessageHash();

        validateLoginKeyMetaTxSigs(
            _txDataMessageHash, _transactionDataSignature, _loginKeyAuthorizationSignature
        );

        return _executeTransaction(
            _destination, _value, _data, _gasLimit
        );
    }

     function verifyLoginKeyParamDataLength(
        address[] memory _destinations,
        bytes[] memory _dataArray,
        uint256[] memory _values,
        uint256[] memory _gasLimits,
        bytes[] memory _transactionDataSignatures
    )
        internal
        view
    {

        require(_destinations.length == _values.length, "Invalid values length");
        require(_destinations.length == _dataArray.length, "Invalid dataArray length");
        require(_destinations.length == _gasLimits.length, "Invalid gasLimits length");
        require(_destinations.length == _transactionDataSignatures.length, "Invalid transactionDataSignatures length");
    }

    function _checkDestination(address _destination) internal view returns (bool) {

        return (address(this) != _destination);
    }
}


pragma solidity 0.5.12;



contract AuthKeyMetaTxAccount is BaseAccount {


    function executeMultipleAuthKeyMetaTx(
        address[] memory _destinations,
        bytes[] memory _datas,
        uint256[] memory _values,
        uint256[] memory _gasLimits,
        bytes[] memory _transactionDataSignatures
    )
        public
        returns (bytes[] memory)
    {

        uint256 startGas = gasleft();

        verifyAuthKeyParamDataLength(
            _destinations, _datas, _values, _gasLimits, _transactionDataSignatures
        );

        bytes[] memory returnValues = new bytes[](_destinations.length);
        for(uint i = 0; i < _destinations.length; i++) {
            returnValues[i] = _executeAuthKeyMetaTx(
                _destinations[i], _datas[i], _values[i], _gasLimits[i], _transactionDataSignatures[i]
            );
        }

        _issueRefund(startGas, tx.gasprice);

        return returnValues;
    }


    function _executeAuthKeyMetaTx(
        address _destination,
        bytes memory _data,
        uint256 _value,
        uint256 _gasLimit,
        bytes memory _transactionDataSignature
    )
        internal
        returns (bytes memory)
    {

        bytes32 _txDataMessageHash = keccak256(abi.encodePacked(
            address(this),
            msg.sig,
            CHAIN_ID,
            _destination,
            _data,
            _value,
            nonce,
            tx.gasprice,
            _gasLimit
        )).toEthSignedMessageHash();

        _validateAuthKeyMetaTxSigs(
            _txDataMessageHash, _transactionDataSignature
        );

        return _executeTransaction(
            _destination, _value, _data, _gasLimit
        );
    }

     function verifyAuthKeyParamDataLength(
        address[] memory _destinations,
        bytes[] memory _dataArray,
        uint256[] memory _values,
        uint256[] memory _gasLimits,
        bytes[] memory _transactionDataSignatures
    )
        internal
        view
    {

        require(_destinations.length == _values.length, "Invalid values length");
        require(_destinations.length == _dataArray.length, "Invalid dataArray length");
        require(_destinations.length == _gasLimits.length, "Invalid gasLimits length");
        require(_destinations.length == _transactionDataSignatures.length, "Invalid gasLimits length");
    }
}


pragma solidity ^0.5.0;

library OpenZeppelinUpgradesAddress {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity 0.5.12;




contract AccountUpgradeability is BaseAccount {

    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    modifier onlySelf() {

        require(address(this) == msg.sender);
        _;
    }

    function upgradeToAndCall(
        address _newImplementation, 
        bytes memory _data
    ) 
        public 
        onlySelf
    {

        setImplementation(_newImplementation);
        (bool success,) = _newImplementation.delegatecall(_data);
        require(success);
        emit Upgraded(_newImplementation);
    }

    function setImplementation(address _newImplementation) internal {

        require(OpenZeppelinUpgradesAddress.isContract(_newImplementation), "Cannot set a proxy implementation to a non-contract address");

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, _newImplementation)
        }
    }
}


pragma solidity 0.5.12;






contract AuthereumAccount is BaseAccount, LoginKeyMetaTxAccount, AuthKeyMetaTxAccount, AccountUpgradeability {

    string constant public authereumVersion = "2019102500";
}