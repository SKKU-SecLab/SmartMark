
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.7;

interface IFinalizeAuctionController {

    function finalize(uint32 _auctionId) external;


    function cancel(uint32 _auctionId) external;


    function adminCancel(uint32 _auctionId, string memory _reason) external;


    function getAuctionType() external view returns (string memory);

}// MIT
pragma solidity ^0.8.7;

interface IAccessManager {

    function isOperationalAddress(address _address)
        external
        view
        returns (bool);

}// MIT
pragma solidity ^0.8.7;


abstract contract EnglishAuctionStorage {
    uint32 lastAuctionId;
    address payable public withdrawalAddress;
    IAccessManager accessManager;

    struct AuctionStruct {
        uint32 tokenId;
        uint32 timeStart;
        uint32 timeEnd;
        uint8 minBidPercentage;
        uint256 initialPrice;
        uint256 minBidValue;
        uint256 auctionBalance;
        address nftContractAddress;
        address finalizeAuctionControllerAddress;
        address payable bidder;
        bytes additionalDataForFinalizeAuction;
    }

    mapping(uint32 => AuctionStruct) auctionIdToAuction;
}// MIT

pragma solidity ^0.8.0;


abstract contract EIP712 {

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;

        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    typeHash,
                    nameHash,
                    versionHash,
                    block.chainid,
                    address(this)
                )
            );
    }

    function _hashTypedDataV4(bytes32 structHash)
        internal
        view
        virtual
        returns (bytes32)
    {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}// MIT
pragma solidity ^0.8.7;

library CallHelpers {

    function getRevertMsg(bytes memory _returnData)
        internal
        pure
        returns (string memory)
    {

        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }
}// MIT
pragma solidity ^0.8.7;


abstract contract SafeEthSender is ReentrancyGuard {
    mapping(address => uint256) private withdrawRegistry;

    event PendingWithdraw(address _user, uint256 _amount);
    event Withdrawn(address _user, uint256 _amount);

    constructor() ReentrancyGuard() {}

    function sendEthWithLimitedGas(
        address payable _user,
        uint256 _amount,
        uint256 _gasLimit
    ) internal {
        if (_amount == 0) {
            return;
        }

        (bool success, ) = _user.call{value: _amount, gas: _gasLimit}("");
        if (!success) {
            withdrawRegistry[_user] += _amount;

            emit PendingWithdraw(_user, _amount);
        }
    }

    function getAmountToWithdrawForUser(address user)
        public
        view
        returns (uint256)
    {
        return withdrawRegistry[user];
    }

    function withdrawPendingEth() external {
        this.withdrawPendingEthFor(payable(msg.sender));
    }

    function withdrawPendingEthFor(address payable _user)
        external
        nonReentrant
    {
        uint256 amount = withdrawRegistry[_user];
        require(amount > 0, "SafeEthSender: no funds to withdraw");
        withdrawRegistry[_user] = 0;
        (bool success, bytes memory response) = _user.call{value: amount}("");

        if (!success) {
            string memory message = CallHelpers.getRevertMsg(response);
            revert(message);
        }

        emit Withdrawn(_user, amount);
    }
}// MIT
pragma solidity ^0.8.7;


contract EnglishAuction is EnglishAuctionStorage, SafeEthSender, EIP712 {

    bytes32 immutable BID_TYPEHASH =
        keccak256("Bid(uint32 auctionId,address bidder,uint256 value)");

    event AuctionCreated(uint32 auctionId);
    event AuctionCanceled(uint32 auctionId);
    event AuctionCanceledByAdmin(uint32 auctionId, string reason);
    event AuctionFinalized(uint32 auctionId, uint256 auctionBalance);
    event AuctionBidPlaced(uint32 auctionId, address bidder, uint256 amount);

    constructor(
        address _accessManangerAddress,
        address payable _withdrawalAddress
    ) EIP712("Place Bid", "1") {
        accessManager = IAccessManager(_accessManangerAddress);
        withdrawalAddress = _withdrawalAddress;
        initializeAuction();
    }

    modifier isOperationalAddress() {

        require(
            accessManager.isOperationalAddress(msg.sender) == true,
            "English Auction: You are not allowed to use this function"
        );
        _;
    }

    function setWithdrawalAddress(address payable _newWithdrawalAddress)
        public
        isOperationalAddress
    {

        withdrawalAddress = _newWithdrawalAddress;
    }

    function createAuction(
        uint32 _tokenId,
        uint32 _timeStart,
        uint32 _timeEnd,
        uint8 _minBidPercentage,
        uint256 _initialPrice,
        uint256 _minBidValue,
        address _nftContractAddress,
        address _finalizeAuctionControllerAddress,
        bytes memory _additionalDataForFinalizeAuction
    ) public isOperationalAddress {

        require(
            _initialPrice > 0,
            "English Auction: Initial price have to be bigger than zero"
        );

        uint32 currentAuctionId = incrementAuctionId();
        auctionIdToAuction[currentAuctionId] = AuctionStruct(
            _tokenId,
            _timeStart,
            _timeEnd,
            _minBidPercentage,
            _initialPrice,
            _minBidValue,
            0, //auctionBalance
            _nftContractAddress,
            _finalizeAuctionControllerAddress,
            payable(address(0)),
            _additionalDataForFinalizeAuction
        );

        emit AuctionCreated(currentAuctionId);
    }

    function incrementAuctionId() private returns (uint32) {

        return lastAuctionId++;
    }

    function getAuction(uint32 _auctionId)
        public
        view
        returns (AuctionStruct memory)
    {

        return auctionIdToAuction[_auctionId];
    }

    function initializeAuction() private {

        lastAuctionId = 1;
    }

    function placeBid(uint32 _auctionId, bytes memory _signature)
        public
        payable
    {

        placeBid(_auctionId, _signature, msg.sender);
    }

    function placeBid(
        uint32 _auctionId,
        bytes memory _signature,
        address _bidder
    ) public payable {

        bytes32 _hash = _hashTypedDataV4(
            keccak256(abi.encode(BID_TYPEHASH, _auctionId, _bidder, msg.value))
        );
        address recoverAddress = ECDSA.recover(_hash, _signature);

        require(
            accessManager.isOperationalAddress(recoverAddress) == true,
            "Incorrect bid permission signature"
        );

        AuctionStruct storage auction = auctionIdToAuction[_auctionId];

        require(auction.initialPrice > 0, "English Auction: Auction not found");

        if (auction.timeStart == 0) {
            auction.timeStart = uint32(block.timestamp);
            auction.timeEnd += auction.timeStart;
        }

        require(
            auction.timeStart <= block.timestamp,
            "English Auction: Auction is not active yet"
        );

        require(
            auction.timeEnd > block.timestamp,
            "English Auction: Auction has been finished"
        );

        uint256 requiredBalance = auction.auctionBalance == 0
            ? auction.initialPrice
            : auction.auctionBalance + auction.minBidValue;

        uint256 requiredPercentageValue = (auction.auctionBalance *
            (auction.minBidPercentage + 100)) / 100;

        require(
            msg.value >= requiredBalance &&
                msg.value >= requiredPercentageValue,
            "English Auction: Bid amount was too low"
        );

        uint256 prevBalance = auction.auctionBalance;
        address payable prevBidder = auction.bidder;

        auction.bidder = payable(_bidder);
        auction.auctionBalance = msg.value;
        if ((auction.timeEnd - uint32(block.timestamp)) < 15 minutes) {
            auction.timeEnd = uint32(block.timestamp) + 15 minutes;
        }

        if (prevBalance > 0) {
            sendEthWithLimitedGas(prevBidder, prevBalance, 2300);
        }
        emit AuctionBidPlaced(_auctionId, _bidder, msg.value);
    }

    function finalizeAuction(uint32 _auctionId) external {

        AuctionStruct memory auction = auctionIdToAuction[_auctionId];

        uint256 auctionBalance = auction.auctionBalance;

        require(auction.timeEnd > 0, "English Auction: Auction not found");

        require(
            auction.timeEnd <= block.timestamp,
            "English Auction: Auction is still in progress"
        );

        IFinalizeAuctionController finalizeAuctionController = IFinalizeAuctionController(
                auction.finalizeAuctionControllerAddress
            );

        (bool success, ) = auction
            .finalizeAuctionControllerAddress
            .delegatecall(
                abi.encodeWithSelector(
                    finalizeAuctionController.finalize.selector,
                    _auctionId
                )
            );

        require(success, "FinalizeAuction: DelegateCall failed");

        delete auctionIdToAuction[_auctionId];

        emit AuctionFinalized(_auctionId, auctionBalance);
    }

    function cancelAuction(uint32 _auctionId) external {

        AuctionStruct memory auction = auctionIdToAuction[_auctionId];

        IFinalizeAuctionController finalizeAuctionController = IFinalizeAuctionController(
                auction.finalizeAuctionControllerAddress
            );

        (bool success, ) = auction
            .finalizeAuctionControllerAddress
            .delegatecall(
                abi.encodeWithSelector(
                    finalizeAuctionController.cancel.selector,
                    _auctionId
                )
            );

        require(success, "CancelAuction: DelegateCall failed");

        delete auctionIdToAuction[_auctionId];

        emit AuctionCanceled(_auctionId);
    }

    function adminCancelAuction(uint32 _auctionId, string memory _reason)
        public
        isOperationalAddress
    {

        AuctionStruct memory auction = auctionIdToAuction[_auctionId];

        IFinalizeAuctionController finalizeAuctionController = IFinalizeAuctionController(
                auction.finalizeAuctionControllerAddress
            );

        (bool success, ) = auction
            .finalizeAuctionControllerAddress
            .delegatecall(
                abi.encodeWithSelector(
                    finalizeAuctionController.adminCancel.selector,
                    _auctionId,
                    _reason
                )
            );

        require(success, "AdminCancelAuction: DelegateCall failed");

        if (auction.bidder != address(0)) {
            uint256 bidderAmount = auction.auctionBalance;
            auction.auctionBalance -= auction.auctionBalance;

            sendEthWithLimitedGas(auction.bidder, bidderAmount, 2300);
        }

        delete auctionIdToAuction[_auctionId];

        emit AuctionCanceledByAdmin(_auctionId, _reason);
    }
}