

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


contract IERC1271 {

    function isValidSignature(
        bytes32 _messageHash,
        bytes memory _signature
    ) public view returns (bytes4 magicValue);


    function isValidSignature(
        bytes memory _data,
        bytes memory _signature
    ) public view returns (bytes4 magicValue);

}

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4);

}

interface IERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);


    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);

}

interface IERC1820ImplementerInterface {

    function canImplementInterfaceForAddress(bytes32 interfaceHash, address addr) external view returns(bytes32);

}

contract IERC777TokensRecipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

}

contract IAuthereumAccount is IERC1271, IERC721Receiver, IERC1155TokenReceiver, IERC1820ImplementerInterface, IERC777TokensRecipient {

    function () external payable;
    function name() external view returns (string memory);

    function version() external view returns (string memory);

    function implementation() external view returns (address);

    function lastInitializedVersion() external returns (uint256);

    function authKeys(address _authKey) external returns (bool);

    function nonce() external returns (uint256);

    function numAuthKeys() external returns (uint256);

    function getChainId() external pure returns (uint256);

    function addAuthKey(address _authKey) external;

    function upgradeToAndCall(address _newImplementation, bytes calldata _data) external;

    function removeAuthKey(address _authKey) external;

    function isValidAuthKeySignature(bytes32 _messageHash, bytes calldata _signature) external view returns (bool);

    function isValidLoginKeySignature(bytes32 _messageHash, bytes calldata _signature) external view returns (bool);

    function executeMultipleTransactions(bytes[] calldata _transactions) external returns (bytes[] memory);

    function executeMultipleMetaTransactions(bytes[] calldata _transactions) external returns (bytes[] memory);


    function executeMultipleAuthKeyMetaTransactions(
        bytes[] calldata _transactions,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        address _feeTokenAddress,
        uint256 _feeTokenRate,
        bytes calldata _transactionMessageHashSignature
    ) external returns (bytes[] memory);


    function executeMultipleLoginKeyMetaTransactions(
        bytes[] calldata _transactions,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        bytes calldata _loginKeyRestrictionsData,
        address _feeTokenAddress,
        uint256 _feeTokenRate,
        bytes calldata _transactionMessageHashSignature,
        bytes calldata _loginKeyAttestationSignature
    ) external returns (bytes[] memory);

}

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
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_length + 31 >= _length, "slice_overflow");
        require(_start + _length >= _start, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

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

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {

        require(_start + 1 >= _start, "toUint8_overflow");
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {

        require(_start + 2 >= _start, "toUint16_overflow");
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {

        require(_start + 4 >= _start, "toUint32_overflow");
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {

        require(_start + 8 >= _start, "toUint64_overflow");
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {

        require(_start + 12 >= _start, "toUint96_overflow");
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {

        require(_start + 16 >= _start, "toUint128_overflow");
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {

        require(_start + 32 >= _start, "toUint256_overflow");
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes4(bytes memory _bytes, uint256 _start) internal  pure returns (bytes4) {

        require(_start + 4 >= _start, "toBytes4_overflow");
        require(_bytes.length >= _start + 4, "toBytes4_outOfBounds");
        bytes4 tempBytes4;

        assembly {
            tempBytes4 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes4;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {

        require(_start + 32 >= _start, "toBytes32_overflow");
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract AuthereumDelegateKeyModule {

    using SafeMath for uint256;
    using BytesLib for bytes;

    string constant public name = "Authereum Delegate Key Module";
    string constant public version = "2020070100";


    event DelegateKeyAdded(
        address indexed authereumAccount,
        address indexed delegateKeyAddress,
        bytes4 approvedFunctionSelector,
        address indexed approvedDestination,
        uint256 maxValue
    );

    event DelegateKeyRemoved(
        address indexed authereumAccount,
        address indexed delegateKeyAddress
    );

    event TransactionExecuted(
        address indexed authereumAccount,
        address indexed delegateKey,
        uint256 indexed value,
        bytes data
    );


    struct DelegateKey {
        bool active;
        bytes4 approvedFunctionSelector;
        address approvedDestination;
        uint256 maxValue;
        bool[] lockedParameters;
        bytes32[] lockedParameterValues;
    }

    mapping(address => mapping(address => DelegateKey)) public delegateKeys;


    modifier onlyActiveDelegateKey(address _authereumAccount) {

        DelegateKey memory delegateKey = delegateKeys[_authereumAccount][msg.sender];
        require(delegateKey.active == true, "ADKM: Delegate Key is not active");
        _;
    }

    modifier onlyWhenRegisteredModule {

        require(
            IAuthereumAccount(msg.sender).authKeys(address(this)),
            "ADKM: Delegate Key module not registered to account"
        );
        _;
    }


    function addDelegateKey(
        address _delegateKeyAddress,
        bytes4 _approvedFunctionSelector,
        address _approvedDestination,
        uint256 _maxValue,
        bool[] calldata _lockedParameters,
        bytes32[] calldata _lockedParameterValues
    )
        external
        onlyWhenRegisteredModule
    {

        require(_delegateKeyAddress != address(0), "ADKM: Delegate Key cannot be address(0)");
        require(delegateKeys[msg.sender][_delegateKeyAddress].active != true, "ADKM: Delegate Key is already registered");
        require(
            _lockedParameters.length == _lockedParameterValues.length,
            "ADKM: lockedParameters must be the same length as lockedParameterValues"
        );

        delegateKeys[msg.sender][_delegateKeyAddress] = DelegateKey(
            true,
            _approvedFunctionSelector,
            _approvedDestination,
            _maxValue,
            _lockedParameters,
            _lockedParameterValues
        );

        emit DelegateKeyAdded(
            msg.sender,
            _delegateKeyAddress,
            _approvedFunctionSelector,
            _approvedDestination,
            _maxValue
        );
    }

    function removeDelegateKey(address _delegateKeyAddress) external {

        DelegateKey memory delegateKey = delegateKeys[msg.sender][_delegateKeyAddress];
        require(delegateKey.active == true, "ADKM: Delegate Key is not active");
        
        delete delegateKeys[msg.sender][_delegateKeyAddress];
        
        emit DelegateKeyRemoved(msg.sender, _delegateKeyAddress);
    }

    function executeTransaction(
        address payable _authereumAccount,
        uint256 _value,
        bytes calldata _data
    )
        external
        onlyActiveDelegateKey(_authereumAccount)
        returns (bytes[] memory)
    {

        DelegateKey memory delegateKey = delegateKeys[_authereumAccount][msg.sender];

        require(_value <= delegateKey.maxValue, "ADKM: Value is higher than maximum allowed value");

        _validateCalldata(delegateKey, _data);

        return _executeTransaction(
            _authereumAccount,
            delegateKey.approvedDestination,
            _value,
            gasleft(),
            _data
        );
    }


    function _validateCalldata(DelegateKey memory _delegateKey, bytes memory _data) private pure {

        if (_delegateKey.approvedFunctionSelector == bytes4(0)) {
            require(_data.length == 0);
            return;
        }

        bool[] memory lockedParameters = _delegateKey.lockedParameters;
        bytes32[] memory lockedParameterValues = _delegateKey.lockedParameterValues;
        (bytes4 functionSelector, bytes32[] memory parameters) = _parseCalldata(_data, lockedParameters.length);

        require(
            functionSelector == _delegateKey.approvedFunctionSelector,
            "ADKM: Invalid function selector"
        );

        for (uint256 i = 0; i < lockedParameters.length; i++) {
            if (lockedParameters[i]) {
                require(lockedParameterValues[i] == parameters[i], "ADKM: Invalid parameter");
            }
        }
    }

    function _parseCalldata(
        bytes memory _data,
        uint256 _parameterCount
    )
        internal
        pure
        returns (bytes4, bytes32[] memory)
    {


        uint256 minDataLength = _parameterCount.mul(32).add(4);
        require(_data.length >= minDataLength, "ADKM: Transaction data is too short");

        bytes4 functionSelector = _data.toBytes4(0);
        bytes32[] memory parameters = new bytes32[](_parameterCount);
        for (uint256 i = 0; i < _parameterCount; i++) {
            parameters[i] = _data.toBytes32(i.mul(32).add(4));
        }

        return (functionSelector, parameters);
    }

    function _executeTransaction(
        address payable _authereumAccount,
        address _to,
        uint256 _value,
        uint256 _gasLimit,
        bytes memory _data
    )
        private
        returns (bytes[] memory)
    {

        bytes memory transactionData = abi.encode(_to, _value, _gasLimit, _data);
        bytes[] memory transactions = new bytes[](1);
        transactions[0] = transactionData;

        bytes[] memory returnValues = IAuthereumAccount(_authereumAccount).executeMultipleTransactions(transactions);

        emit TransactionExecuted(_authereumAccount, msg.sender, _value, _data);
        return returnValues;
    }
}