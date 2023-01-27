
pragma solidity ^0.8.12;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFeeDB {

    event UpdateFeeAndRecipient(uint256 newFee, address newRecipient);
    event UpdatePaysFeeWhenSending(bool newType);

    function protocolFee() external view returns (uint256);


    function protocolFeeRecipient() external view returns (address);


    function paysFeeWhenSending() external view returns (bool);


    function userDiscountRate(address user) external view returns (uint256);


    function userFee(address user, uint256 amount, address nft) external view returns (uint256);

}

interface IAPMReservoir {

    function token() external returns (address);


    event AddSigner(address signer);
    event RemoveSigner(address signer);
    event UpdateFeeDB(IFeeDB newFeeDB);
    event UpdateQuorum(uint256 newQuorum);
    event SendToken(
        address indexed sender,
        uint256 indexed toChainId,
        address indexed receiver,
        uint256 amount,
        uint256 sendingId,
        bool isFeeCollected
    );
    event ReceiveToken(
        address indexed sender,
        uint256 indexed fromChainId,
        address indexed receiver,
        uint256 amount,
        uint256 sendingId
    );

    function signers(uint256 id) external view returns (address);


    function signerIndex(address signer) external view returns (uint256);


    function quorum() external view returns (uint256);


    function feeDB() external view returns (IFeeDB);


    function signersLength() external view returns (uint256);


    function isSigner(address signer) external view returns (bool);


    function sendingData(
        address sender,
        uint256 toChainId,
        address receiver,
        uint256 sendingId
    ) external view returns (uint256 sendedAmount, uint256 sendingBlock);


    function isTokenReceived(
        address sender,
        uint256 fromChainId,
        address receiver,
        uint256 sendingId
    ) external view returns (bool);


    function sendingCounts(
        address sender,
        uint256 toChainId,
        address receiver
    ) external view returns (uint256);


    function sendToken(
        uint256 toChainId,
        address receiver,
        uint256 amount,
        address nft
    ) external returns (uint256 sendingId);


    function receiveToken(
        address sender,
        uint256 fromChainId,
        address receiver,
        uint256 amount,
        uint256 sendingId,
        bool isFeePayed,
        address nft,
        uint8[] calldata vs,
        bytes32[] calldata rs,
        bytes32[] calldata ss
    ) external;

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Signature {

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address signer) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "invalid signature 's' value"
        );
        require(v == 27 || v == 28, "invalid signature 'v' value");

        signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "invalid signature");
    }
}

contract APMReservoir is Ownable, IAPMReservoir {

    using SafeMath for uint256;

    address[] public signers;
    mapping(address => uint256) public signerIndex;
    uint256 public signingNonce;
    uint256 public quorum;

    IFeeDB public feeDB;
    address public token;

    constructor(
        address _token,
        uint256 _quorum,
        address[] memory _signers
    ) {
        require(_token != address(0));
        token = _token;

        require(_quorum > 0);
        quorum = _quorum;
        emit UpdateQuorum(_quorum);

        require(_signers.length >= _quorum);
        signers = _signers;

        for (uint256 i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            require(signer != address(0));
            require(signerIndex[signer] == 0);

            if (i > 0) require(signer != _signers[0]);

            signerIndex[signer] = i;
            emit AddSigner(signer);
        }
    }

    function signersLength() public view returns (uint256) {

        return signers.length;
    }

    function isSigner(address signer) public view returns (bool) {

        return (signerIndex[signer] > 0) || (signers[0] == signer);
    }

    function _checkSigners(
        bytes32 message,
        uint8[] memory vs,
        bytes32[] memory rs,
        bytes32[] memory ss
    ) private view {

        uint256 length = vs.length;
        require(length == rs.length && length == ss.length);
        require(length >= quorum);

        for (uint256 i = 0; i < length; i++) {
            require(isSigner(Signature.recover(message, vs[i], rs[i], ss[i])));
        }
    }

    function addSigner(
        address signer,
        uint8[] memory vs,
        bytes32[] memory rs,
        bytes32[] memory ss
    ) public {

        require(signer != address(0));
        require(!isSigner(signer));

        bytes32 hash = keccak256(abi.encodePacked("addSigner", block.chainid, signingNonce++));
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        _checkSigners(message, vs, rs, ss);

        signerIndex[signer] = signersLength();
        signers.push(signer);
        emit AddSigner(signer);
    }

    function removeSigner(
        address signer,
        uint8[] memory vs,
        bytes32[] memory rs,
        bytes32[] memory ss
    ) public {

        require(signer != address(0));
        require(isSigner(signer));

        bytes32 hash = keccak256(abi.encodePacked("removeSigner", block.chainid, signingNonce++));
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        _checkSigners(message, vs, rs, ss);

        uint256 lastIndex = signersLength().sub(1);
        require(lastIndex >= quorum);

        uint256 targetIndex = signerIndex[signer];
        if (targetIndex != lastIndex) {
            address lastSigner = signers[lastIndex];
            signers[targetIndex] = lastSigner;
            signerIndex[lastSigner] = targetIndex;
        }

        signers.pop();
        delete signerIndex[signer];

        emit RemoveSigner(signer);
    }

    function updateQuorum(
        uint256 newQuorum,
        uint8[] memory vs,
        bytes32[] memory rs,
        bytes32[] memory ss
    ) public {

        require(newQuorum > 0);

        bytes32 hash = keccak256(abi.encodePacked("updateQuorum", block.chainid, signingNonce++));
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        _checkSigners(message, vs, rs, ss);

        quorum = newQuorum;
        emit UpdateQuorum(newQuorum);
    }

    function updateFeeDB(IFeeDB newDB) public onlyOwner {

        feeDB = newDB;
        emit UpdateFeeDB(newDB);
    }

    struct SendingData {
        uint256 sendedAmount;
        uint256 sendingBlock;
    }
    mapping(address => mapping(uint256 => mapping(address => SendingData[]))) public sendingData;
    mapping(address => mapping(uint256 => mapping(address => mapping(uint256 => bool)))) public isTokenReceived;

    function sendingCounts(
        address sender,
        uint256 toChainId,
        address receiver
    ) public view returns (uint256) {

        return sendingData[sender][toChainId][receiver].length;
    }

    function sendToken(
        uint256 toChainId,
        address receiver,
        uint256 amount,
        address nft
    ) public returns (uint256 sendingId) {

        sendingId = sendingCounts(msg.sender, toChainId, receiver);
        sendingData[msg.sender][toChainId][receiver].push(SendingData({sendedAmount: amount, sendingBlock: block.number}));

        bool paysFee = feeDB.paysFeeWhenSending();
        _takeAmount(msg.sender, amount, paysFee, nft);
        emit SendToken(msg.sender, toChainId, receiver, amount, sendingId, paysFee);
    }

    function receiveToken(
        address sender,
        uint256 fromChainId,
        address receiver,
        uint256 amount,
        uint256 sendingId,
        bool isFeePayed,
        address nft,
        uint8[] memory vs,
        bytes32[] memory rs,
        bytes32[] memory ss
    ) public {

        require(!isTokenReceived[sender][fromChainId][receiver][sendingId]);

        bytes32 hash = keccak256(
            abi.encodePacked(fromChainId, sender, block.chainid, receiver, amount, sendingId, isFeePayed, nft)
        );
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        _checkSigners(message, vs, rs, ss);

        isTokenReceived[sender][fromChainId][receiver][sendingId] = true;
        _giveAmount(receiver, amount, isFeePayed, nft);

        emit ReceiveToken(sender, fromChainId, receiver, amount, sendingId);
    }

    function _takeAmount(
        address user,
        uint256 amount,
        bool paysFee,
        address nft
    ) private {

        uint256 fee;
        if (paysFee) {
            address feeRecipient;
            (fee, feeRecipient) = _getFeeData(user, amount, nft);
            if (fee != 0 && feeRecipient != address(0)) IERC20(token).transferFrom(user, feeRecipient, fee);
        }
        IERC20(token).transferFrom(user, address(this), amount);
    }

    function _giveAmount(
        address user,
        uint256 amount,
        bool isFeePayed,
        address nft
    ) private {

        uint256 fee;
        if (!isFeePayed) {
            address feeRecipient;
            (fee, feeRecipient) = _getFeeData(user, amount, nft);
            if (fee != 0 && feeRecipient != address(0)) IERC20(token).transfer(feeRecipient, fee);
        }
        IERC20(token).transfer(user, amount.sub(fee));
    }

    function _getFeeData(
        address user,
        uint256 amount,
        address nft
    ) private view returns (uint256 fee, address feeRecipient) {

        fee = feeDB.userFee(user, amount, nft);
        feeRecipient = feeDB.protocolFeeRecipient();
    }
}