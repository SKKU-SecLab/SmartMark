pragma solidity ^0.5.4;

contract AuctionityStorage0 {

    mapping(bytes4 => address) internal delegates;

    address public proxyFallbackContract;

    address public contractOwner;
    address public oracle;

    bool public paused;

    uint8 public ethereumChainId;
    uint8 public auctionityChainId;
}
pragma solidity ^0.5.4;


contract AuctionityStorage1 is AuctionityStorage0 {

    mapping(address => mapping(uint256 => mapping(address => uint256))) tokens;

    bytes32[] public withdrawalVoucherList; // List of withdrawal voucher
    mapping(bytes32 => bool) public withdrawalVoucherSubmitted; // is withdrawal voucher is already submitted

    bytes32[] public auctionEndVoucherList; // List of auction end voucher
    mapping(bytes32 => bool) public auctionEndVoucherSubmitted; // is auction end voucher is already submitted

}
pragma solidity ^0.5.4;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}
pragma solidity ^0.5.4;


contract AuctionityLibrary_V1 is AuctionityStorage0 {

    function getDelegate_V1(bytes4 _selector)
        public
        view
        returns (address _contractDelegate)
    {

        return delegates[_selector];
    }

    function _callDelegated_V1(
        bytes memory _calldata,
        address _contractFallback
    ) internal returns (uint returnPtr, uint returnSize) {

        bytes4 _selector;
        assembly {
            _selector := mload(add(_calldata, 0x20))
        }

        address _contractDelegate = getDelegate_V1(_selector);

        if (_contractDelegate == address(0)) {
            _contractDelegate = _contractFallback;
        }

        require(
            _contractDelegate != address(0),
            "Auctionity function does not exist."
        );

        assembly {
            let result := delegatecall(
                gas,
                _contractDelegate,
                add(_calldata, 0x20),
                mload(_calldata),
                0,
                0
            )
            returnSize := returndatasize
            returnPtr := mload(0x40)
            returndatacopy(returnPtr, 0, returnSize)
            if eq(result, 0) {
                revert(returnPtr, returnSize)
            }
        }

        return (returnPtr, returnSize);

    }

    function delegatedSendIsContractOwner_V1()
        public
        returns (bool _isContractOwner)
    {

        uint returnPtr;
        uint returnSize;

        (returnPtr, returnSize) = _callDelegated_V1(
            abi.encodeWithSelector(
                bytes4(keccak256("delegatedReceiveIsContractOwner_V1()"))
            ),
            address(0)
        );

        assembly {
            _isContractOwner := mload(returnPtr)
        }

        return _isContractOwner;
    }

    modifier delegatedSendIsOracle_V1() {

        require(
            msg.sender == delegatedSendGetOracle_V1(),
            "Sender must be oracle"
        );
        _;
    }

    function delegatedSendGetOracle_V1() public returns (address _oracle) {

        uint returnPtr;
        uint returnSize;

        (returnPtr, returnSize) = _callDelegated_V1(
            abi.encodeWithSelector(
                bytes4(keccak256("delegatedReceiveGetOracle_V1()"))
            ),
            address(0)
        );

        assembly {
            _oracle := mload(returnPtr)
        }
        return _oracle;

    }

    function delegatedSendGetPaused_V1() public returns (bool _isPaused) {

        uint returnPtr;
        uint returnSize;

        (returnPtr, returnSize) = _callDelegated_V1(
            abi.encodeWithSelector(
                bytes4(keccak256("delegatedReceiveGetPaused_V1()"))
            ),
            address(0)
        );
        assembly {
            _isPaused := mload(returnPtr)
        }
        return _isPaused;

    }

    function delegatedLockDeposit_V1(
        address _tokenContractAddress,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _auctionId,
        address _refundUser
    ) public returns (bool _success) {

        uint returnPtr;
        uint returnSize;

        (returnPtr, returnSize) = _callDelegated_V1(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "lockDeposit_V1(address,uint256,uint256,uint256,address)"
                    )
                ),
                _tokenContractAddress,
                _tokenId,
                _amount,
                _auctionId,
                _refundUser
            ),
            address(0)
        );

        assembly {
            _success := mload(returnPtr)
        }
        return _success;

    }

    function isContract_V1(address _contractAddress)
        internal
        view
        returns (bool _isContract)
    {

        uint _size;
        assembly {
            _size := extcodesize(_contractAddress)
        }
        return _size > 0;
    }

    function bytesToUint_V1(bytes memory b) internal pure returns (uint256) {

        uint256 _number;
        for (uint i = 0; i < b.length; i++) {
            _number = _number + uint8(b[i]) * (2 ** (8 * (b.length - (i + 1))));
        }
        return _number;
    }
}
pragma solidity ^0.5.4;

library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;

    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    function toRlpItem(bytes memory item)
        internal
        pure
        returns (RLPItem memory)
    {

        if (item.length == 0) return RLPItem(0, 0);

        uint memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    function toList(RLPItem memory item)
        internal
        pure
        returns (RLPItem[] memory result)
    {

        require(isList(item));

        uint items = numItems(item);
        result = new RLPItem[](items);

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }
    }


    function isList(RLPItem memory item) internal pure returns (bool) {

        uint8 byte0;
        uint memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    function numItems(RLPItem memory item) internal pure returns (uint) {

        uint count = 0;
        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    function _itemLength(uint memPtr) internal pure returns (uint len) {

        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 1;
        else if (byte0 < STRING_LONG_START) return byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                len := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            return byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                len := add(dataLen, add(byteLen, 1))
            }
        }
    }

    function _payloadOffset(uint memPtr) internal pure returns (uint) {

        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)) return 1;
        else if (byte0 < LIST_SHORT_START) // being explicit
        return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }


    function toBoolean(RLPItem memory item) internal pure returns (bool) {

        require(
            item.len == 1,
            "Invalid RLPItem. Booleans are encoded in 1 byte"
        );
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(
            item.len == 21,
            "Invalid RLPItem. Addresses are encoded in 20 bytes"
        );

        uint memPtr = item.memPtr + 1; // skip the length prefix
        uint addr;
        assembly {
            addr := div(mload(memPtr), exp(256, 12)) // right shift 12 bytes. we want the most significant 20 bytes
        }

        return address(addr);
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset;
        uint memPtr = item.memPtr + offset;

        uint result;
        assembly {
            result := div(mload(memPtr), exp(256, sub(32, len))) // shift to the correct location
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }

    function copy(uint src, uint dest, uint len) internal pure {

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}
pragma solidity ^0.5.4;

library RLPWriter {

    function toRlp(bytes memory _value)
        internal
        pure
        returns (bytes memory _bytes)
    {

        uint _valuePtr;
        uint _rplPtr;
        uint _valueLength = _value.length;

        assembly {
            _valuePtr := add(_value, 0x20)
            _bytes := mload(0x40) // Free memory ptr
            _rplPtr := add(_bytes, 0x20) // RLP first byte ptr
        }

        if (_valueLength == 1 && _value[0] <= 0x7f) {
            assembly {
                mstore(_bytes, 1) // Bytes size is 1
                mstore(_rplPtr, mload(_valuePtr)) // Set value as-is
                mstore(0x40, add(_rplPtr, 1)) // Update free ptr
            }
            return _bytes;
        }

        if (_valueLength <= 55) {
            assembly {
                mstore(_bytes, add(1, _valueLength)) // Bytes size
                mstore8(_rplPtr, add(0x80, _valueLength)) // RLP small string size
                mstore(0x40, add(add(_rplPtr, 1), _valueLength)) // Update free ptr
            }

            copy(_valuePtr, _rplPtr + 1, _valueLength);
            return _bytes;
        }

        uint _lengthSize = uintMinimalSize(_valueLength);

        assembly {
            mstore(_bytes, add(add(1, _lengthSize), _valueLength)) // Bytes size
            mstore8(_rplPtr, add(0xb7, _lengthSize)) // RLP long string "size size"
            mstore(
                add(_rplPtr, 1),
                mul(_valueLength, exp(256, sub(32, _lengthSize)))
            ) // Bitshift to store the length only _lengthSize bytes
            mstore(0x40, add(add(add(_rplPtr, 1), _lengthSize), _valueLength)) // Update free ptr
        }

        copy(_valuePtr, _rplPtr + 1 + _lengthSize, _valueLength);
        return _bytes;
    }

    function toRlp(uint _value) internal pure returns (bytes memory _bytes) {

        uint _size = uintMinimalSize(_value);

        bytes memory _valueBytes = new bytes(_size);

        assembly {
            mstore(
                add(_valueBytes, 0x20),
                mul(_value, exp(256, sub(32, _size)))
            )
        }

        return toRlp(_valueBytes);
    }

    function toRlp(bytes[] memory _values)
        internal
        pure
        returns (bytes memory _bytes)
    {

        uint _ptr;
        uint _size;
        uint i;

        for (; i < _values.length; ++i) _size += _values[i].length;

        assembly {
            _bytes := mload(0x40)
            _ptr := add(_bytes, 0x20)
        }

        if (_size <= 55) {
            assembly {
                mstore8(_ptr, add(0xc0, _size))
                _ptr := add(_ptr, 1)
            }
        } else {
            uint _size2 = uintMinimalSize(_size);

            assembly {
                mstore8(_ptr, add(0xf7, _size2))
                _ptr := add(_ptr, 1)
                mstore(_ptr, mul(_size, exp(256, sub(32, _size2))))
                _ptr := add(_ptr, _size2)
            }
        }

        for (i = 0; i < _values.length; ++i) {
            bytes memory _val = _values[i];
            uint _valPtr;

            assembly {
                _valPtr := add(_val, 0x20)
            }

            copy(_valPtr, _ptr, _val.length);

            _ptr += _val.length;
        }

        assembly {
            mstore(0x40, _ptr)
            mstore(_bytes, sub(sub(_ptr, _bytes), 0x20))
        }
    }

    function uintMinimalSize(uint _value) internal pure returns (uint _size) {

        for (; _value != 0; _size++) _value /= 256;
    }

    function copy(uint src, uint dest, uint len) internal pure {

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }

            src += 32;
            dest += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}
pragma solidity ^0.5.4;



library AuctionityLibraryDecodeRawTx_V1 {

    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;

    function decodeRawTxGetBiddingInfo_V1(
        bytes memory _signedRawTxBidding,
        uint8 _chainId
    )
        internal
        pure
        returns (
        bytes32 _hashRawTxTokenTransfer,
        address _auctionContractAddress,
        uint256 _bidAmount,
        address _signerBid
    )
    {

        bytes memory _auctionBidlData;
        RLPReader.RLPItem[] memory _signedRawTxBiddingRLPItem = _signedRawTxBidding.toRlpItem(

        ).toList();

        _auctionContractAddress = _signedRawTxBiddingRLPItem[3].toAddress();
        _auctionBidlData = _signedRawTxBiddingRLPItem[5].toBytes();

        bytes4 _selector;
        assembly {
            _selector := mload(add(_auctionBidlData, 0x20))
        }

        _signerBid = getSignerFromSignedRawTxRLPItem_V1(
            _signedRawTxBiddingRLPItem,
            _chainId
        );

        if (_selector == 0x1d03ae68) {
            assembly {
                _bidAmount := mload(add(_auctionBidlData, add(4, 0x20)))
                _hashRawTxTokenTransfer := mload(
                    add(_auctionBidlData, add(68, 0x20))
                )
            }

        }

        if (_selector == 0x8470df06) {
            assembly {
                _bidAmount := mload(add(_auctionBidlData, add(4, 0x20)))
                _hashRawTxTokenTransfer := mload(
                    add(_auctionBidlData, add(100, 0x20))
                )
            }

        }

    }

    function decodeRawTxGetCreateAuctionInfo_V1(
        bytes memory _signedRawTxCreateAuction,
        uint8 _chainId
    )
        internal
        pure
        returns (
        bytes32 _tokenHash,
        address _auctionFactoryContractAddress,
        address _signerCreate,
        address _tokenContractAddress,
        uint256 _tokenId,
        uint8 _rewardPercent
    )
    {

        bytes memory _createAuctionlData;
        RLPReader.RLPItem[] memory _signedRawTxCreateAuctionRLPItem = _signedRawTxCreateAuction.toRlpItem(

        ).toList();

        _auctionFactoryContractAddress = _signedRawTxCreateAuctionRLPItem[3].toAddress(

        );
        _createAuctionlData = _signedRawTxCreateAuctionRLPItem[5].toBytes();

        _signerCreate = getSignerFromSignedRawTxRLPItem_V1(
            _signedRawTxCreateAuctionRLPItem,
            _chainId
        );

        bytes memory _signedRawTxTokenTransfer;

        (_signedRawTxTokenTransfer, _tokenContractAddress, _tokenId, _rewardPercent) = decodeRawTxGetCreateAuctionInfoData_V1(
            _createAuctionlData
        );

        _tokenHash = keccak256(_signedRawTxTokenTransfer);

    }

    function decodeRawTxGetCreateAuctionInfoData_V1(
        bytes memory _createAuctionlData
    )
        internal
        pure
        returns (
        bytes memory _signedRawTxTokenTransfer,
        address _tokenContractAddress,
        uint256 _tokenId,
        uint8 _rewardPercent
    )
    {

        bytes4 _selector;
        assembly {
            _selector := mload(add(_createAuctionlData, 0x20))
        }

        uint _positionOfSignedRawTxTokenTransfer;
        uint _sizeOfSignedRawTxTokenTransfer;
        uint i;

        if (_selector == 0xffd6d828) {
            assembly {
                _positionOfSignedRawTxTokenTransfer := mload(
                    add(_createAuctionlData, add(4, 0x20))
                )
                _sizeOfSignedRawTxTokenTransfer := mload(
                    add(
                        _createAuctionlData,
                        add(add(_positionOfSignedRawTxTokenTransfer, 4), 0x20)
                    )
                )

                _tokenContractAddress := mload(
                    add(_createAuctionlData, add(add(mul(1, 32), 4), 0x20))
                )
                _tokenId := mload(
                    add(_createAuctionlData, add(add(mul(2, 32), 4), 0x20))
                )
                _rewardPercent := mload(
                    add(_createAuctionlData, add(add(mul(5, 32), 4), 0x20))
                )

            }

            _signedRawTxTokenTransfer = new bytes(
                _sizeOfSignedRawTxTokenTransfer
            );

            for (i = 0; i < _sizeOfSignedRawTxTokenTransfer; i++) {
                _signedRawTxTokenTransfer[i] = _createAuctionlData[i + _positionOfSignedRawTxTokenTransfer + 4 + 32];
            }

        }

        if (_selector == 0xfe7ccebd) {
            uint _positionOfRewards;
            assembly {
                _positionOfSignedRawTxTokenTransfer := mload(
                    add(_createAuctionlData, add(4, 0x20))
                )
                _sizeOfSignedRawTxTokenTransfer := mload(
                    add(
                        _createAuctionlData,
                        add(add(_positionOfSignedRawTxTokenTransfer, 4), 0x20)
                    )
                )

                _tokenContractAddress := mload(
                    add(_createAuctionlData, add(add(mul(1, 32), 4), 0x20))
                )
                _tokenId := mload(
                    add(_createAuctionlData, add(add(mul(2, 32), 4), 0x20))
                )


                _positionOfRewards := mload(
                    add(_createAuctionlData, add(add(mul(5, 32), 4), 0x20))
                )

                _rewardPercent := mload(
                    add(
                        _createAuctionlData,
                        add(add(_positionOfRewards, 4), 0x40)
                    )
                )

            }

            _signedRawTxTokenTransfer = new bytes(
                _sizeOfSignedRawTxTokenTransfer
            );

            for (i = 0; i < _sizeOfSignedRawTxTokenTransfer; i++) {
                _signedRawTxTokenTransfer[i] = _createAuctionlData[i + _positionOfSignedRawTxTokenTransfer + 4 + 32];
            }

        }

    }

    function decodeRawTxGetWithdrawalInfo_V1(
        bytes memory _signedRawTxWithdrawal,
        uint8 _chainId
    )
        internal
        pure
        returns (address withdrawalSigner, uint256 withdrawalAmount)
    {

        bytes4 _selector;
        bytes memory _withdrawalData;
        RLPReader.RLPItem[] memory _signedRawTxWithdrawalRLPItem = _signedRawTxWithdrawal.toRlpItem(

        ).toList();

        _withdrawalData = _signedRawTxWithdrawalRLPItem[5].toBytes();

        assembly {
            _selector := mload(add(_withdrawalData, 0x20))
        }

        withdrawalSigner = getSignerFromSignedRawTxRLPItem_V1(
            _signedRawTxWithdrawalRLPItem,
            _chainId
        );

        if (_selector == 0x47960938) {
            assembly {
                withdrawalAmount := mload(add(_withdrawalData, add(4, 0x20)))
            }

        }

    }

    function ecrecoverSigner_V1(
        bytes32 _hashTx,
        bytes memory _rsvTx,
        uint offset
    ) internal pure returns (address ecrecoverAddress) {

        bytes32 r;
        bytes32 s;
        bytes1 v;

        assembly {
            r := mload(add(_rsvTx, add(offset, 0x20)))
            s := mload(add(_rsvTx, add(offset, 0x40)))
            v := mload(add(_rsvTx, add(offset, 0x60)))
        }

        ecrecoverAddress = ecrecover(_hashTx, uint8(v), r, s);
    }

    function getSignerFromSignedRawTxRLPItem_V1(
        RLPReader.RLPItem[] memory _signedTxRLPItem,
        uint8 _chainId
    ) internal pure returns (address ecrecoverAddress) {

        bytes memory _rawTx;
        bytes memory _rsvTx;

        (_rawTx, _rsvTx) = explodeSignedRawTxRLPItem(
            _signedTxRLPItem,
            _chainId
        );
        return ecrecoverSigner_V1(keccak256(_rawTx), _rsvTx, 0);
    }

    function explodeSignedRawTxRLPItem(
        RLPReader.RLPItem[] memory _signedTxRLPItem,
        uint8 _chainId
    ) internal pure returns (bytes memory _rawTx, bytes memory _rsvTx) {

        bytes[] memory _signedTxRLPItemRaw = new bytes[](9);

        _signedTxRLPItemRaw[0] = RLPWriter.toRlp(_signedTxRLPItem[0].toBytes());
        _signedTxRLPItemRaw[1] = RLPWriter.toRlp(_signedTxRLPItem[1].toBytes());
        _signedTxRLPItemRaw[2] = RLPWriter.toRlp(_signedTxRLPItem[2].toBytes());
        _signedTxRLPItemRaw[3] = RLPWriter.toRlp(_signedTxRLPItem[3].toBytes());
        _signedTxRLPItemRaw[4] = RLPWriter.toRlp(_signedTxRLPItem[4].toBytes());
        _signedTxRLPItemRaw[5] = RLPWriter.toRlp(_signedTxRLPItem[5].toBytes());

        _signedTxRLPItemRaw[6] = RLPWriter.toRlp(_chainId);
        _signedTxRLPItemRaw[7] = RLPWriter.toRlp(0);
        _signedTxRLPItemRaw[8] = RLPWriter.toRlp(0);

        _rawTx = RLPWriter.toRlp(_signedTxRLPItemRaw);

        uint8 i;
        _rsvTx = new bytes(65);

        bytes32 tmp = bytes32(_signedTxRLPItem[7].toUint());
        for (i = 0; i < 32; i++) {
            _rsvTx[i] = tmp[i];
        }

        tmp = bytes32(_signedTxRLPItem[8].toUint());

        for (i = 0; i < 32; i++) {
            _rsvTx[i + 32] = tmp[i];
        }

        _rsvTx[64] = bytes1(
            uint8(_signedTxRLPItem[6].toUint() - uint(_chainId * 2) - 8)
        );

    }

}
pragma solidity ^0.5.4;


contract AuctionityChainId_V1 is AuctionityLibrary_V1 {

    function getEthereumChainId_V1() public view returns (uint8) {

        return ethereumChainId;
    }

    function getAuctionityChainId_V1() public view returns (uint8) {

        return auctionityChainId;
    }

    function setEthereumChainId_V1(uint8 _ethereumChainId) public {

        require(
            delegatedSendIsContractOwner_V1(),
            "setEthereumChainId Contract owner"
        );
        ethereumChainId = _ethereumChainId;
    }

    function setAuctionityChainId_V1(uint8 _auctionityChainId) public {

        require(
            delegatedSendIsContractOwner_V1(),
            "setAuctionityChainId Contract owner"
        );
        auctionityChainId = _auctionityChainId;
    }

}
pragma solidity ^0.5.4;


contract AuctionityOracable_V1 is AuctionityLibrary_V1 {

    event LogOracleTransfered_V1(
        address indexed previousOracle,
        address indexed newOracle
    );

    function delegatedReceiveGetOracle_V1()
        public
        payable
        returns (address _oracle)
    {

        return getOracle_V1();
    }

    function getOracle_V1() public view returns (address _oracle) {

        return oracle;
    }

    function isOracle_V1() public view returns (bool _isOracle) {

        return msg.sender == oracle;
    }


    function verifyOracle_V1(address _oracle)
        public
        view
        returns (bool _isOracle)
    {

        return _oracle == oracle;
    }

    function transferOracle_V1(address _newOracle) public {

        require(
            isOracle_V1() || delegatedSendIsContractOwner_V1(),
            "Is not Oracle or Owner"
        );
        _transferOracle_V1(_newOracle);
    }

    function _transferOracle_V1(address _newOracle) internal {

        require(_newOracle != address(0), "Oracle can't be 0x0");
        emit LogOracleTransfered_V1(oracle, _newOracle);
        oracle = _newOracle;
    }
}
pragma solidity ^0.5.4;



contract AuctionityPausable_V1 is AuctionityLibrary_V1 {

    event LogPaused_V1(bool paused);

    constructor() public {
        paused = false;
    }

    function delegatedReceiveGetPaused_V1()
        public
        payable
        returns (bool _isPaused)
    {

        return getPaused_V1();
    }

    function getPaused_V1() public returns (bool _isPaused) {

        if (delegatedSendIsContractOwner_V1() == true) {
            return false;
        }
        return paused;
    }

    modifier whenNotPaused_V1() {

        require(!delegatedSendGetPaused_V1(), "Contrat is paused");
        _;
    }

    modifier whenPaused_V1() {

        require(delegatedSendGetPaused_V1(), "Contrat is not paused");
        _;
    }

    function setPaused_V1(bool _paused) public {

        require(delegatedSendIsContractOwner_V1(), "Not Contract owner");
        paused = _paused;
        emit LogPaused_V1(_paused);
    }
}
pragma solidity ^0.5.4;




contract AuctionityDeposit_V1 is AuctionityStorage1, AuctionityLibrary_V1, AuctionityChainId_V1 {

    using SafeMath for uint256;

    struct InfoFromCreateAuction {
        bytes32 tokenHash;
        address tokenContractAddress;
        address auctionSeller;
        uint8 rewardPercent;
        uint256 tokenId;
    }

    struct InfoFromBidding {
        address auctionContractAddress;
        address signer;
        uint256 amount;
    }

    event LogSentEthToWinner(address auction, address user, uint256 amount);
    event LogSentRewardsDepotEth(address[] user, uint256[] amount);
    event LogDeposed(address user, uint256 amount);
    event LogWithdrawalVoucherSubmitted(address user, uint256 amount, bytes32 withdrawalVoucherHash);
    event LogAuctionEndVoucherSubmitted(
        bytes32 tokenHash,
        address tokenContractAddress,
        uint256 tokenId,
        address indexed seller,
        address indexed winner,
        uint256 amount,
        bytes32 auctionEndVoucherHash
    );

    event LogWithdrawalVoucherSubmitted_V1(
        address user,
        uint256 amount,
        bytes32 withdrawalVoucherHash
    );

    event LogAddDepot_V1(
        address user,
        address tokenContractAddress,
        uint256 tokenId,
        uint256 amount,
        uint256 totalAmount
    );

    event LogAuctionEndVoucherSubmitted_V1(
        bytes32 tokenHash,
        address tokenContractAddress,
        uint256 tokenId,
        address indexed seller,
        address indexed winner,
        uint256 amount,
        bytes32 auctionEndVoucher_V1Hash
    );
    event LogSentEthToSeller_V1(address auction, address user, uint256 amount);
    event LogSentRewardsDepotEth_V1(address[] user, uint256[] amount);

    function getDepotEth(address _user) public view returns (uint256 _amount) {

        return getBalanceEth_V1(_user);
    }

    function() external payable {
        return receiveDepotEth_V1();
    }

    function depositEth() public payable {

        receiveDepotEth_V1();
    }

    function receiveDepotEth_V1()  public payable {

        require(!delegatedSendGetPaused_V1(), "CONTRACT_PAUSED");

        address _user = msg.sender;
        uint256 _amount = uint256(msg.value);

        _addDepotEth_V1(_user, _amount);

        emit LogDeposed(_user, _amount);

        emit LogAddDepot_V1(
            _user,
            address(0),
            uint256(0),
            _amount,
            getBalanceEth_V1(_user)
        );

    }

    function _addDepotEth_V1(address _user, uint256 _amount)
        internal
        returns (bool)
    {

        return _addDepot_V1(_user, address(0), uint256(0), _amount);
    }

    function _addDepot_V1(
        address _user,
        address _tokenContractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) internal returns (bool) {

        require(_amount > 0, "Amount must be greater than 0");

        tokens[_tokenContractAddress][_tokenId][_user] = tokens[_tokenContractAddress][_tokenId][_user].add(
            _amount
        );

        return true;
    }

    function _subDepotEth_V1(address _user, uint256 _amount)
        internal
        returns (bool)
    {

        return _subDepot_V1(_user, address(0), uint256(0), _amount);
    }

    function _subDepot_V1(
        address _user,
        address _tokenContractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) internal returns (bool) {

        require(
            tokens[_tokenContractAddress][_tokenId][_user] >= _amount,
            "Amount too low"
        );

        tokens[_tokenContractAddress][_tokenId][_user] = tokens[_tokenContractAddress][_tokenId][_user].sub(
            _amount
        );

        return true;
    }

    function getBalanceEth_V1(address _user) public view returns (uint256 _balanceOf) {

        return _getBalance_V1(_user, address(0), uint256(0));
    }

    function _getBalance_V1(
        address _user,
        address _tokenContractAddress,
        uint256 _tokenId
    ) internal view returns (uint256 _balanceOf) {

        return tokens[_tokenContractAddress][_tokenId][_user];
    }

    function withdrawalVoucher_V1(
        bytes memory _withdrawalVoucherData,
        bytes memory _signedRawTxWithdrawal
    ) public {

        require(!delegatedSendGetPaused_V1(), "CONTRACT_PAUSED");

        bytes32 _withdrawalVoucherHash = keccak256(_signedRawTxWithdrawal);

        require(
            withdrawalVoucherSubmitted[_withdrawalVoucherHash] != true,
            "Withdrawal voucher is already submited"
        );

        address _withdrawalSigner;
        uint _withdrawalAmount;

        (_withdrawalSigner, _withdrawalAmount) = AuctionityLibraryDecodeRawTx_V1.decodeRawTxGetWithdrawalInfo_V1(
            _signedRawTxWithdrawal,
            getAuctionityChainId_V1()
        );

        require(
            _withdrawalAmount != uint256(0),
            "Withdrawal voucher amount must be greater than zero"
        );
        require(
            _withdrawalSigner != address(0),
            "Withdrawal voucher invalid signature of oracle"
        );

        require(
            getBalanceEth_V1(_withdrawalSigner) >= _withdrawalAmount,
            "Withdrawal voucher depot amount is too low"
        );

        require(
            withdrawalVoucherOracleSignatureVerification_V1(
                _withdrawalVoucherData,
                _withdrawalSigner,
                _withdrawalAmount,
                _withdrawalVoucherHash
            ),
            "Withdrawal voucher invalid signature of oracle"
        );

        require(
            address(uint160(_withdrawalSigner)).send(_withdrawalAmount),
            "Withdrawal voucher transfer failed"
        );

        _subDepotEth_V1(_withdrawalSigner, _withdrawalAmount);

        withdrawalVoucherList.push(_withdrawalVoucherHash);
        withdrawalVoucherSubmitted[_withdrawalVoucherHash] = true;

        emit LogWithdrawalVoucherSubmitted(
            _withdrawalSigner,
            _withdrawalAmount,
            _withdrawalVoucherHash
        );

        emit LogWithdrawalVoucherSubmitted_V1(
            _withdrawalSigner,
            _withdrawalAmount,
            _withdrawalVoucherHash
        );
    }

    function withdrawalVoucherOracleSignatureVerification_V1(
        bytes memory _withdrawalVoucherData,
        address _withdrawalSigner,
        uint256 _withdrawalAmount,
        bytes32 _withdrawalVoucherHash
    ) internal returns (bool) {

        return delegatedSendGetOracle_V1(

        ) == AuctionityLibraryDecodeRawTx_V1.ecrecoverSigner_V1(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(
                        abi.encodePacked(
                            address(this),
                            _withdrawalSigner,
                            _withdrawalAmount,
                            _withdrawalVoucherHash
                        )
                    )
                )
            ),
                _withdrawalVoucherData,
            0
        );
    }

    function auctionEndVoucher_V1(
        bytes memory _auctionEndVoucherData,
        bytes memory _signedRawTxCreateAuction,
        bytes memory _signedRawTxBidding,
        bytes memory _send
    ) public {

        require(!delegatedSendGetPaused_V1(), "CONTRACT_PAUSED");

        bytes32 _auctionEndVoucherHash = keccak256(_signedRawTxCreateAuction);
        require(
            auctionEndVoucherSubmitted[_auctionEndVoucherHash] != true,
            "Auction end voucher already submited"
        );

        InfoFromCreateAuction memory _infoFromCreateAuction = getInfoFromCreateAuction_V1(
            _signedRawTxCreateAuction
        );

        address _auctionContractAddress;
        address _winnerSigner;
        uint256 _winnerAmount;

        InfoFromBidding memory _infoFromBidding;

        if (_signedRawTxBidding.length > 1) {
            _infoFromBidding = getInfoFromBidding_V1(
                _signedRawTxBidding,
                _infoFromCreateAuction.tokenHash
            );

            if (!verifyWinnerDepot_V1(_infoFromBidding)) {
                return;
            }
        }

        require(
            auctionEndVoucherOracleSignatureVerification_V1(
                _auctionEndVoucherData,
                keccak256(_send),
                _infoFromCreateAuction,
                _infoFromBidding
            ),
            "Auction end voucher invalid signature of oracle"
        );

        require(
            sendTransfer_V1(
                _infoFromCreateAuction.tokenContractAddress,
                _auctionEndVoucherData,
                97
            ),
            "Auction end voucher transfer failed"
        );

        if (_signedRawTxBidding.length > 1) {
            if (!sendExchange_V1(
                _send,
                _infoFromCreateAuction,
                _infoFromBidding
            )) {
                return;
            }
        }

        auctionEndVoucherList.push(_auctionEndVoucherHash);
        auctionEndVoucherSubmitted[_auctionEndVoucherHash] = true;

        emit LogAuctionEndVoucherSubmitted(
            _infoFromCreateAuction.tokenHash,
            _infoFromCreateAuction.tokenContractAddress,
            _infoFromCreateAuction.tokenId,
            _infoFromCreateAuction.auctionSeller,
            _infoFromBidding.signer,
            _infoFromBidding.amount,
            _auctionEndVoucherHash
        );

        emit LogAuctionEndVoucherSubmitted_V1(
            _infoFromCreateAuction.tokenHash,
            _infoFromCreateAuction.tokenContractAddress,
            _infoFromCreateAuction.tokenId,
            _infoFromCreateAuction.auctionSeller,
            _infoFromBidding.signer,
            _infoFromBidding.amount,
            _auctionEndVoucherHash
        );
    }

    function getInfoFromCreateAuction_V1(bytes memory _signedRawTxCreateAuction)
        internal
        view
        returns (InfoFromCreateAuction memory _infoFromCreateAuction)
    {

        (_infoFromCreateAuction.tokenHash, , _infoFromCreateAuction.auctionSeller, _infoFromCreateAuction.tokenContractAddress, _infoFromCreateAuction.tokenId, _infoFromCreateAuction.rewardPercent) = AuctionityLibraryDecodeRawTx_V1.decodeRawTxGetCreateAuctionInfo_V1(
            _signedRawTxCreateAuction,
            getAuctionityChainId_V1()
        );
    }

    function getInfoFromBidding_V1(
        bytes memory _signedRawTxBidding,
        bytes32 _hashSignedRawTxTokenTransfer
    ) internal returns (InfoFromBidding memory _infoFromBidding) {

        bytes32 _hashRawTxTokenTransferFromBid;

        (_hashRawTxTokenTransferFromBid, _infoFromBidding.auctionContractAddress, _infoFromBidding.amount, _infoFromBidding.signer) = AuctionityLibraryDecodeRawTx_V1.decodeRawTxGetBiddingInfo_V1(
            _signedRawTxBidding,
            getAuctionityChainId_V1()
        );

        require(
            _hashRawTxTokenTransferFromBid == _hashSignedRawTxTokenTransfer,
            "Auction end voucher hashRawTxTokenTransfer is invalid"
        );

        require(
            _infoFromBidding.amount != uint256(0),
            "Auction end voucher bidding amount must be greater than zero"
        );

        return _infoFromBidding;

    }

    function verifyWinnerDepot_V1(InfoFromBidding memory _infoFromBidding)
        internal
        returns (bool)
    {

        require(
            getBalanceEth_V1(
                _infoFromBidding.signer
            ) >= _infoFromBidding.amount,
            "Auction end voucher depot amount is too low"
        );

        return true;
    }

    function sendExchange_V1(
        bytes memory _send,
        InfoFromCreateAuction memory _infoFromCreateAuction,
        InfoFromBidding memory _infoFromBidding
    ) internal returns (bool) {

        require(
            _subDepotEth_V1(_infoFromBidding.signer, _infoFromBidding.amount),
            "Auction end voucher depot amout is too low"
        );

        uint offset;
        address payable _sendAddress;
        uint256 _sendAmount;
        bytes12 _sendAmountGwei;
        uint256 _sentAmount;

        assembly {
            _sendAddress := mload(add(_send, add(offset, 0x14)))
            _sendAmount := mload(add(_send, add(add(offset, 20), 0x20)))
        }

        require(
            _sendAddress == _infoFromCreateAuction.auctionSeller,
            "Auction end voucher sender address is invalider"
        );

        _sentAmount += _sendAmount;
        offset += 52;

        if (!_sendAddress.send(_sendAmount)) {
            revert("Failed to send funds");
        }

        emit LogSentEthToWinner(_infoFromBidding.auctionContractAddress,
            _sendAddress,
            _sendAmount);

        emit LogSentEthToSeller_V1(
            _infoFromBidding.auctionContractAddress,
            _sendAddress,
            _sendAmount
        );

        if (_infoFromCreateAuction.rewardPercent > 0) {

            bytes2 _numberOfSendDepositBytes2;
            assembly {
                _numberOfSendDepositBytes2 := mload(
                    add(_send, add(offset, 0x20))
                )
            }

            offset += 2;


            address[] memory _rewardsAddress = new address[](
                uint16(_numberOfSendDepositBytes2)
            );
            uint256[] memory _rewardsAmount = new uint256[](
                uint16(_numberOfSendDepositBytes2)
            );


            for (uint16 i = 0; i < uint16(_numberOfSendDepositBytes2); i++) {

                assembly {
                    _sendAddress := mload(add(_send, add(offset, 0x14)))
                    _sendAmountGwei := mload(
                        add(_send, add(add(offset, 20), 0x20))
                    )
                }

                _sendAmount = uint96(_sendAmountGwei) * 1000000000;
                _sentAmount += _sendAmount;
                offset += 32;

                if (!_addDepotEth_V1(_sendAddress, _sendAmount)) {
                    revert("Can't add deposit");
                }

                _rewardsAddress[i] = _sendAddress;
                _rewardsAmount[i] = uint256(_sendAmount);
            }

            emit LogSentRewardsDepotEth(_rewardsAddress, _rewardsAmount);

            emit LogSentRewardsDepotEth_V1(_rewardsAddress, _rewardsAmount);
        }

        if (uint256(_infoFromBidding.amount) != _sentAmount) {
            revert("Bidding amount is not equal to sent amount");
        }

        return true;
    }

    function getTransferDataHash_V1(bytes memory _auctionEndVoucherData)
        internal
        pure
        returns (bytes32 _transferDataHash)
    {

        bytes memory _transferData = new bytes(_auctionEndVoucherData.length - 97);

        for (uint i = 0; i < (_auctionEndVoucherData.length - 97); i++) {
            _transferData[i] = _auctionEndVoucherData[i + 97];
        }
        return keccak256(_transferData);

    }

    function auctionEndVoucherOracleSignatureVerification_V1(
        bytes memory _auctionEndVoucherData,
        bytes32 _sendDataHash,
        InfoFromCreateAuction memory _infoFromCreateAuction,
        InfoFromBidding memory _infoFromBidding
    ) internal returns (bool) {

        bytes32 _biddingHashProof;
        assembly {
            _biddingHashProof := mload(add(_auctionEndVoucherData, add(0, 0x20)))
        }

        bytes32 _transferDataHash = getTransferDataHash_V1(_auctionEndVoucherData);

        return delegatedSendGetOracle_V1() == AuctionityLibraryDecodeRawTx_V1.ecrecoverSigner_V1(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(
                        abi.encodePacked(
                            address(this),
                            _infoFromCreateAuction.tokenContractAddress,
                            _infoFromCreateAuction.tokenId,
                            _infoFromCreateAuction.auctionSeller,
                            _infoFromBidding.signer,
                            _infoFromBidding.amount,
                            _biddingHashProof,
                            _infoFromCreateAuction.rewardPercent,
                            _transferDataHash,
                            _sendDataHash
                        )
                    )
                )
            ),
            _auctionEndVoucherData,
            32
        );

    }

    function sendTransfer_V1(
        address _tokenContractAddress,
        bytes memory _auctionEndVoucherData,
        uint _offset
    ) internal returns (bool) {

        if (!isContract_V1(_tokenContractAddress)) {
            return false;
        }

        uint8 _numberOfTransfer = uint8(_auctionEndVoucherData[_offset]);

        _offset += 1;

        bool _success;
        for (uint8 i = 0; i < _numberOfTransfer; i++) {
            (_offset, _success) = decodeTransferCall_V1(
                _tokenContractAddress,
                _auctionEndVoucherData,
                _offset
            );

            if (!_success) {
                return false;
            }
        }

        return true;

    }

    function decodeTransferCall_V1(
        address _tokenContractAddress,
        bytes memory _auctionEndVoucherData,
        uint _offset
    ) internal returns (uint, bool) {

        bytes memory _sizeOfCallBytes;
        bytes memory _callData;

        uint _sizeOfCallData;

        if (_auctionEndVoucherData[_offset] == 0xb8) {
            _sizeOfCallBytes = new bytes(1);
            _sizeOfCallBytes[0] = bytes1(_auctionEndVoucherData[_offset + 1]);

            _offset += 2;
        }
        if (_auctionEndVoucherData[_offset] == 0xb9) {
            _sizeOfCallBytes = new bytes(2);
            _sizeOfCallBytes[0] = bytes1(_auctionEndVoucherData[_offset + 1]);
            _sizeOfCallBytes[1] = bytes1(_auctionEndVoucherData[_offset + 2]);
            _offset += 3;
        }
        
        _sizeOfCallData = bytesToUint_V1(_sizeOfCallBytes);

        _callData = new bytes(_sizeOfCallData);
        for (uint j = 0; j < _sizeOfCallData; j++) {
            _callData[j] = _auctionEndVoucherData[(j + _offset)];
        }

        _offset += _sizeOfCallData;

        return (_offset, sendCallData_V1(
            _tokenContractAddress,
            _sizeOfCallData,
            _callData
        ));

    }

    function sendCallData_V1(
        address _tokenContractAddress,
        uint256 _sizeOfCallData,
        bytes memory _callData
    ) internal returns (bool) {

        bool _success;
        bytes4 sig;

        assembly {
            let _ptr := mload(0x40)
            sig := mload(add(_callData, 0x20))

            mstore(_ptr, sig) //Place signature at begining of empty storage
            for {
                let i := 0x04
            } lt(i, _sizeOfCallData) {
                i := add(i, 0x20)
            } {
                mstore(add(_ptr, i), mload(add(_callData, add(0x20, i)))) //Add each param
            }

            _success := call(
                sub(gas, 10000), // gas
                _tokenContractAddress, //To addr
                0, //No value
                _ptr, //Inputs are stored at location _ptr
                _sizeOfCallData, //Inputs _size
                _ptr, //Store output over input (saves space)
                0x20
            ) //Outputs are 32 bytes long

        }

        return _success;
    }

}
