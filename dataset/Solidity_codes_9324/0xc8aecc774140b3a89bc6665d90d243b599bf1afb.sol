
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () /*internal*/ {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// GPL-3.0-only
pragma solidity >=0.7.6;
pragma abicoder v2;

interface IForwarder {


    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }

    event DomainRegistered(bytes32 indexed domainSeparator, bytes domainValue);

    event RequestTypeRegistered(bytes32 indexed typeHash, string typeStr);

    function getNonce(address from)
    external view
    returns(uint256);


    function verify(
        ForwardRequest calldata forwardRequest,
        bytes32 domainSeparator,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata signature
    ) external view;


    function execute(
        ForwardRequest calldata forwardRequest,
        bytes32 domainSeparator,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata signature
    )
    external payable
    returns (bool success, bytes memory ret);


    function registerRequestType(string calldata typeName, string calldata typeSuffix) external;


    function registerDomainSeparator(string calldata name, string calldata version) external;

}// GPL-3.0-only
pragma solidity >=0.7.6;


interface GsnTypes {

    struct RelayData {
        bool isFlashbots;
        uint256 gasPrice;
        uint256 pctRelayFee;
        uint256 baseRelayFee;
        address relayWorker;
        address paymaster;
        address forwarder;
        bytes paymasterData;
        uint256 clientId;
    }

    struct RelayRequest {
        IForwarder.ForwardRequest request;
        RelayData relayData;
    }
}// GPL-3.0-only
pragma solidity >=0.7.6;


interface IPaymaster {


    struct GasAndDataLimits {
        uint256 acceptanceBudget;
        uint256 preRelayedCallGasLimit;
        uint256 postRelayedCallGasLimit;
        uint256 calldataSizeLimit;
    }

    function getGasAndDataLimits()
    external
    view
    returns (
        GasAndDataLimits memory limits
    );


    function trustedForwarder() external view returns (IForwarder);


    function getHubAddr() external view returns (address);


    function getRelayHubDeposit() external view returns (uint256);


    function preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
    external
    returns (bytes memory context, bool rejectOnRecipientRevert);


    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        GsnTypes.RelayData calldata relayData
    ) external;


    function versionPaymaster() external view returns (string memory);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// GPL-3.0-only
pragma solidity >=0.7.6;


interface IStakeManager {


    event StakeAdded(
        address indexed relayManager,
        address indexed owner,
        uint256 stake,
        uint256 unstakeDelay
    );

    event StakeUnlocked(
        address indexed relayManager,
        address indexed owner,
        uint256 withdrawBlock
    );

    event StakeWithdrawn(
        address indexed relayManager,
        address indexed owner,
        uint256 amount
    );

    event StakePenalized(
        address indexed relayManager,
        address indexed beneficiary,
        uint256 reward
    );

    event HubAuthorized(
        address indexed relayManager,
        address indexed relayHub
    );

    event HubUnauthorized(
        address indexed relayManager,
        address indexed relayHub,
        uint256 removalBlock
    );

    event OwnerSet(
        address indexed relayManager,
        address indexed owner
    );

    struct StakeInfo {
        uint256 stake;
        uint256 unstakeDelay;
        uint256 withdrawBlock;
        address payable owner;
    }

    struct RelayHubInfo {
        uint256 removalBlock;
    }

    function setRelayManagerOwner(address payable owner) external;


    function stakeForRelayManager(address relayManager, uint256 unstakeDelay) external payable;


    function unlockStake(address relayManager) external;


    function withdrawStake(address relayManager) external;


    function authorizeHubByOwner(address relayManager, address relayHub) external;


    function authorizeHubByManager(address relayHub) external;


    function unauthorizeHubByOwner(address relayManager, address relayHub) external;


    function unauthorizeHubByManager(address relayHub) external;


    function isRelayManagerStaked(address relayManager, address relayHub, uint256 minAmount, uint256 minUnstakeDelay)
    external
    view
    returns (bool);


    function penalizeRelayManager(address relayManager, address payable beneficiary, uint256 amount) external;


    function getStakeInfo(address relayManager) external view returns (StakeInfo memory stakeInfo);


    function maxUnstakeDelay() external view returns (uint256);


    function versionSM() external view returns (string memory);

}// GPL-3.0-only
pragma solidity >=0.7.6;


interface IRelayHub {

    struct RelayHubConfig {
        uint256 maxWorkerCount;
        uint256 gasReserve;
        uint256 postOverhead;
        uint256 gasOverhead;
        uint256 maximumRecipientDeposit;
        uint256 minimumUnstakeDelay;
        uint256 minimumStake;
        uint256 dataGasCostPerByte;
        uint256 externalCallDataCostOverhead;
    }

    event RelayHubConfigured(RelayHubConfig config);

    event RelayServerRegistered(
        address indexed relayManager,
        uint256 baseRelayFee,
        uint256 pctRelayFee,
        string relayUrl
    );

    event RelayWorkersAdded(
        address indexed relayManager,
        address[] newRelayWorkers,
        uint256 workersCount
    );

    event Withdrawn(
        address indexed account,
        address indexed dest,
        uint256 amount
    );

    event Deposited(
        address indexed paymaster,
        address indexed from,
        uint256 amount
    );

    event TransactionRejectedByPaymaster(
        address indexed relayManager,
        address indexed paymaster,
        address indexed from,
        address to,
        address relayWorker,
        bytes4 selector,
        uint256 innerGasUsed,
        bytes reason
    );

    event TransactionRelayed(
        address indexed relayManager,
        address indexed relayWorker,
        address indexed from,
        address to,
        address paymaster,
        bytes4 selector,
        RelayCallStatus status,
        uint256 charge
    );

    event TransactionResult(
        RelayCallStatus status,
        bytes returnValue
    );

    event HubDeprecated(uint256 fromBlock);

    enum RelayCallStatus {
        OK,
        RelayedCallFailed,
        RejectedByPreRelayed,
        RejectedByForwarder,
        RejectedByRecipientRevert,
        PostRelayedFailed,
        PaymasterBalanceChanged
    }

    function addRelayWorkers(address[] calldata newRelayWorkers) external;


    function registerRelayServer(uint256 baseRelayFee, uint256 pctRelayFee, string calldata url) external;



    function depositFor(address target) external payable;


    function withdraw(uint256 amount, address payable dest) external;




    function relayCall(
        uint maxAcceptanceBudget,
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint externalGasLimit
    )
    external
    returns (bool paymasterAccepted, bytes memory returnValue);


    function penalize(address relayWorker, address payable beneficiary) external;


    function setConfiguration(RelayHubConfig memory _config) external;


    function deprecateHub(uint256 fromBlock) external;


    function calculateCharge(uint256 gasUsed, GsnTypes.RelayData calldata relayData) external view returns (uint256);



    function getConfiguration() external view returns (RelayHubConfig memory config);


    function calldataGasCost(uint256 length) external view returns (uint256);


    function workerToManager(address worker) external view returns(address);


    function workerCount(address manager) external view returns(uint256);


    function balanceOf(address target) external view returns (uint256);


    function stakeManager() external view returns (IStakeManager);


    function penalizer() external view returns (address);


    function isRelayManagerStaked(address relayManager) external view returns(bool);


    function isDeprecated() external view returns (bool);


    function deprecationBlock() external view returns (uint256);


    function versionHub() external view returns (string memory);

}// GPL-3.0-only
pragma solidity >=0.7.6;

abstract contract IRelayRecipient {

    function isTrustedForwarder(address forwarder) public virtual view returns(bool);

    function _msgSender() internal virtual view returns (address payable);

    function _msgData() internal virtual view returns (bytes memory);

    function versionRecipient() external virtual view returns (string memory);
}// MIT
pragma solidity >=0.7.6;

library MinLibBytes {


    function truncateInPlace(bytes memory data, uint256 maxlen) internal pure {

        if (data.length > maxlen) {
            assembly { mstore(data, maxlen) }
        }
    }

    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {

        require (b.length >= index + 20, "readAddress: data too short");

        index += 20;

        assembly {
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {

        require(b.length >= index + 32, "readBytes32: data too short" );

        assembly {
            result := mload(add(b, add(index,32)))
        }
        return result;
    }

    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {

        result = uint256(readBytes32(b, index));
        return result;
    }

    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {

        require(b.length >= index + 4, "readBytes4: data too short");

        assembly {
            result := mload(add(b, add(index,32)))
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }
}/* solhint-disable no-inline-assembly */
pragma solidity >=0.7.6;


library GsnUtils {


    function getMethodSig(bytes memory msgData) internal pure returns (bytes4) {

        return MinLibBytes.readBytes4(msgData, 0);
    }

    function getParam(bytes memory msgData, uint index) internal pure returns (uint) {

        return MinLibBytes.readUint256(msgData, 4 + index * 32);
    }

    function revertWithData(bytes memory data) internal pure {

        assembly {
            revert(add(data,32), mload(data))
        }
    }

}// GPL-3.0-only
pragma solidity >=0.7.6;



library GsnEip712Library {

    uint256 private constant MAX_RETURN_SIZE = 1024;

    string public constant GENERIC_PARAMS = "address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data,uint256 validUntil";

    bytes public constant RELAYDATA_TYPE = "RelayData(uint256 gasPrice,uint256 pctRelayFee,uint256 baseRelayFee,address relayWorker,address paymaster,address forwarder,bytes paymasterData,uint256 clientId)";

    string public constant RELAY_REQUEST_NAME = "RelayRequest";
    string public constant RELAY_REQUEST_SUFFIX = string(abi.encodePacked("RelayData relayData)", RELAYDATA_TYPE));

    bytes public constant RELAY_REQUEST_TYPE = abi.encodePacked(
        RELAY_REQUEST_NAME,"(",GENERIC_PARAMS,",", RELAY_REQUEST_SUFFIX);

    bytes32 public constant RELAYDATA_TYPEHASH = keccak256(RELAYDATA_TYPE);
    bytes32 public constant RELAY_REQUEST_TYPEHASH = keccak256(RELAY_REQUEST_TYPE);


    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    function splitRequest(
        GsnTypes.RelayRequest calldata req
    )
    internal
    pure
    returns (
        bytes memory suffixData
    ) {

        suffixData = abi.encode(
            hashRelayData(req.relayData));
    }

    function verifyForwarderTrusted(GsnTypes.RelayRequest calldata relayRequest) internal view {

        (bool success, bytes memory ret) = relayRequest.request.to.staticcall(
            abi.encodeWithSelector(
                IRelayRecipient.isTrustedForwarder.selector, relayRequest.relayData.forwarder
            )
        );
        require(success, "isTrustedForwarder: reverted");
        require(ret.length == 32, "isTrustedForwarder: bad response");
        require(abi.decode(ret, (bool)), "invalid forwarder for recipient");
    }

    function verifySignature(GsnTypes.RelayRequest calldata relayRequest, bytes calldata signature) internal view {

        (bytes memory suffixData) = splitRequest(relayRequest);
        bytes32 _domainSeparator = domainSeparator(relayRequest.relayData.forwarder);
        IForwarder forwarder = IForwarder(payable(relayRequest.relayData.forwarder));
        forwarder.verify(relayRequest.request, _domainSeparator, RELAY_REQUEST_TYPEHASH, suffixData, signature);
    }

    function verify(GsnTypes.RelayRequest calldata relayRequest, bytes calldata signature) internal view {

        verifyForwarderTrusted(relayRequest);
        verifySignature(relayRequest, signature);
    }

    function execute(GsnTypes.RelayRequest calldata relayRequest, bytes calldata signature) internal returns (bool forwarderSuccess, bool callSuccess, bytes memory ret) {

        (bytes memory suffixData) = splitRequest(relayRequest);
        bytes32 _domainSeparator = domainSeparator(relayRequest.relayData.forwarder);
        (forwarderSuccess, ret) = relayRequest.relayData.forwarder.call(
            abi.encodeWithSelector(IForwarder.execute.selector,
            relayRequest.request, _domainSeparator, RELAY_REQUEST_TYPEHASH, suffixData, signature
        ));
        if ( forwarderSuccess ) {

          (callSuccess, ret) = abi.decode(ret, (bool, bytes));
        }
        truncateInPlace(ret);
    }

    function truncateInPlace(bytes memory data) internal pure {

        MinLibBytes.truncateInPlace(data, MAX_RETURN_SIZE);
    }

    function domainSeparator(address forwarder) internal pure returns (bytes32) {

        return hashDomain(EIP712Domain({
            name : "GSN Relayed Transaction",
            version : "2",
            chainId : getChainID(),
            verifyingContract : forwarder
            }));
    }

    function getChainID() internal pure returns (uint256 id) {

        assembly {
            id := chainid()
        }
    }

    function hashDomain(EIP712Domain memory req) internal pure returns (bytes32) {

        return keccak256(abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(req.name)),
                keccak256(bytes(req.version)),
                req.chainId,
                req.verifyingContract));
    }

    function hashRelayData(GsnTypes.RelayData calldata req) internal pure returns (bytes32) {

        return keccak256(abi.encode(
                RELAYDATA_TYPEHASH,
                req.gasPrice,
                req.pctRelayFee,
                req.baseRelayFee,
                req.relayWorker,
                req.paymaster,
                req.forwarder,
                keccak256(req.paymasterData),
                req.clientId
            ));
    }
}// GPL-3.0-only
pragma solidity >=0.7.6;



abstract contract BasePaymaster is IPaymaster, Ownable {

    IRelayHub internal relayHub;
    IForwarder public override trustedForwarder;

    function getHubAddr() public override view returns (address) {
        return address(relayHub);
    }

    uint256 constant public FORWARDER_HUB_OVERHEAD = 50000;

    uint256 constant public PRE_RELAYED_CALL_GAS_LIMIT = 100000;
    uint256 constant public POST_RELAYED_CALL_GAS_LIMIT = 110000;
    uint256 constant public PAYMASTER_ACCEPTANCE_BUDGET = PRE_RELAYED_CALL_GAS_LIMIT + FORWARDER_HUB_OVERHEAD;
    uint256 constant public CALLDATA_SIZE_LIMIT = 10500;

    function getGasAndDataLimits()
    public
    override
    virtual
    view
    returns (
        IPaymaster.GasAndDataLimits memory limits
    ) {
        return IPaymaster.GasAndDataLimits(
            PAYMASTER_ACCEPTANCE_BUDGET,
            PRE_RELAYED_CALL_GAS_LIMIT,
            POST_RELAYED_CALL_GAS_LIMIT,
            CALLDATA_SIZE_LIMIT
        );
    }

    function _verifyForwarder(GsnTypes.RelayRequest calldata relayRequest)
    public
    view
    {
        require(address(trustedForwarder) == relayRequest.relayData.forwarder, "Forwarder is not trusted");
        GsnEip712Library.verifyForwarderTrusted(relayRequest);
    }

    modifier relayHubOnly() {
        require(msg.sender == getHubAddr(), "can only be called by RelayHub");
        _;
    }

    function setRelayHub(IRelayHub hub) public onlyOwner {
        relayHub = hub;
    }

    function setTrustedForwarder(IForwarder forwarder) public onlyOwner {
        trustedForwarder = forwarder;
    }

    function getRelayHubDeposit()
    public
    override
    view
    returns (uint) {
        return relayHub.balanceOf(address(this));
    }

    receive() external virtual payable {
        require(address(relayHub) != address(0), "relay hub address not set");
        relayHub.depositFor{value:msg.value}(address(this));
    }

    function withdrawRelayHubDepositTo(uint amount, address payable target) public onlyOwner {
        relayHub.withdraw(amount, target);
    }
}// GPL-3.0-only
pragma solidity >=0.7.6;


abstract contract BaseRelayRecipient is IRelayRecipient {

    address public trustedForwarder;

    function isTrustedForwarder(address forwarder) public override view returns(bool) {
        return forwarder == trustedForwarder;
    }

    function _msgSender() internal override virtual view returns (address payable ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            assembly {
                ret := shr(96,calldataload(sub(calldatasize(),20)))
            }
        } else {
            return msg.sender;
        }
    }

    function _msgData() internal override virtual view returns (bytes memory ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return msg.data[0:msg.data.length-20];
        } else {
            return msg.data;
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract Forwarder is IForwarder {

    using ECDSA for bytes32;

    string public constant GENERIC_PARAMS = "address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data,uint256 validUntil";

    string public constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";

    mapping(bytes32 => bool) public typeHashes;
    mapping(bytes32 => bool) public domains;

    mapping(address => uint256) private nonces;

    receive() external payable {}

    function getNonce(address from)
    public view override
    returns (uint256) {

        return nonces[from];
    }

    constructor() {

        string memory requestType = string(abi.encodePacked("ForwardRequest(", GENERIC_PARAMS, ")"));
        registerRequestTypeInternal(requestType);
    }

    function verify(
        ForwardRequest calldata req,
        bytes32 domainSeparator,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata sig)
    external override view {


        _verifyNonce(req);
        _verifySig(req, domainSeparator, requestTypeHash, suffixData, sig);
    }

    function execute(
        ForwardRequest calldata req,
        bytes32 domainSeparator,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata sig
    )
    external payable
    override
    returns (bool success, bytes memory ret) {

        _verifySig(req, domainSeparator, requestTypeHash, suffixData, sig);
        _verifyAndUpdateNonce(req);

        require(req.validUntil == 0 || req.validUntil > block.number, "FWD: request expired");

        uint gasForTransfer = 0;
        if ( req.value != 0 ) {
            gasForTransfer = 40000; //buffer in case we need to move eth after the transaction.
        }
        bytes memory callData = abi.encodePacked(req.data, req.from);
        require(gasleft()*63/64 >= req.gas + gasForTransfer, "FWD: insufficient gas");
        (success,ret) = req.to.call{gas : req.gas, value : req.value}(callData);
        if ( req.value != 0 && address(this).balance>0 ) {
            payable(req.from).transfer(address(this).balance);
        }

        return (success,ret);
    }


    function _verifyNonce(ForwardRequest calldata req) internal view {

        require(nonces[req.from] == req.nonce, "FWD: nonce mismatch");
    }

    function _verifyAndUpdateNonce(ForwardRequest calldata req) internal {

        require(nonces[req.from]++ == req.nonce, "FWD: nonce mismatch");
    }

    function registerRequestType(string calldata typeName, string calldata typeSuffix) external override {


        for (uint i = 0; i < bytes(typeName).length; i++) {
            bytes1 c = bytes(typeName)[i];
            require(c != "(" && c != ")", "FWD: invalid typename");
        }

        string memory requestType = string(abi.encodePacked(typeName, "(", GENERIC_PARAMS, ",", typeSuffix));
        registerRequestTypeInternal(requestType);
    }

    function registerDomainSeparator(string calldata name, string calldata version) external override {

        uint256 chainId;
        assembly { chainId := chainid() }

        bytes memory domainValue = abi.encode(
            keccak256(bytes(EIP712_DOMAIN_TYPE)),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId,
            address(this));

        bytes32 domainHash = keccak256(domainValue);

        domains[domainHash] = true;
        emit DomainRegistered(domainHash, domainValue);
    }

    function registerRequestTypeInternal(string memory requestType) internal {


        bytes32 requestTypehash = keccak256(bytes(requestType));
        typeHashes[requestTypehash] = true;
        emit RequestTypeRegistered(requestTypehash, requestType);
    }

    function _verifySig(
        ForwardRequest calldata req,
        bytes32 domainSeparator,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata sig)
    internal
    view
    {

        require(domains[domainSeparator], "FWD: unregistered domain sep.");
        require(typeHashes[requestTypeHash], "FWD: unregistered typehash");
        bytes32 digest = keccak256(abi.encodePacked(
                "\x19\x01", domainSeparator,
                keccak256(_getEncoded(req, requestTypeHash, suffixData))
            ));
        require(digest.recover(sig) == req.from, "FWD: signature mismatch");
    }

    function _getEncoded(
        ForwardRequest calldata req,
        bytes32 requestTypeHash,
        bytes calldata suffixData
    )
    public
    pure
    returns (
        bytes memory
    ) {

        return abi.encodePacked(
            requestTypeHash,
            uint256(uint160(req.from)),
            uint256(uint160(req.to)),
            req.value,
            req.gas,
            req.nonce,
            keccak256(req.data),
            req.validUntil,
            suffixData
        );
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract BatchForwarder is Forwarder, BaseRelayRecipient {


    string public override versionRecipient = "2.2.0+opengsn.batched.irelayrecipient";

    constructor() {
        trustedForwarder = address(this);
    }

    function sendBatch(address[] calldata targets, bytes[] calldata encodedFunctions) external {

        require(targets.length == encodedFunctions.length, "BatchForwarder: wrong length");
        address sender = _msgSender();
        for (uint i = 0; i < targets.length; i++) {
            (bool success, bytes memory ret) = targets[i].call(abi.encodePacked(encodedFunctions[i], sender));
            if (!success){
                GsnUtils.revertWithData(ret);
            }
        }
    }
}// SPDX-License-Identifier:APACHE-2.0
pragma solidity ^0.7.6;

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

    using RLPReader for bytes;
    using RLPReader for uint;
    using RLPReader for RLPReader.RLPItem;


    function decodeLegacyTransaction(bytes calldata rawTransaction) internal pure returns (uint, uint, uint, address, uint, bytes memory){

        RLPReader.RLPItem[] memory values = rawTransaction.toRlpItem().toList(); // must convert to an rlpItem first!
        return (values[0].toUint(), values[1].toUint(), values[2].toUint(), values[3].toAddress(), values[4].toUint(), values[5].toBytes());
    }

    function decodeTransactionType1(bytes calldata rawTransaction) internal pure returns (uint, uint, uint, address, uint, bytes memory){

        bytes memory payload = rawTransaction[1:rawTransaction.length];
        RLPReader.RLPItem[] memory values = payload.toRlpItem().toList(); // must convert to an rlpItem first!
        return (values[1].toUint(), values[2].toUint(), values[3].toUint(), values[4].toAddress(), values[5].toUint(), values[6].toBytes());
    }

    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {

        if (item.length == 0)
            return RLPItem(0, 0);
        uint memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }
        return RLPItem(item.length, memPtr);
    }
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory result) {

        require(isList(item), "isList failed");
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
        if (byte0 < LIST_SHORT_START)
            return false;
        return true;
    }
    function numItems(RLPItem memory item) internal pure returns (uint) {

        uint count = 0;
        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr);
            count++;
        }
        return count;
    }
    function _itemLength(uint memPtr) internal pure returns (uint len) {

        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }
        if (byte0 < STRING_SHORT_START)
            return 1;
        else if (byte0 < STRING_LONG_START)
            return byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                len := add(dataLen, add(byteLen, 1))
            }
        }
        else if (byte0 < LIST_LONG_START) {
            return byte0 - LIST_SHORT_START + 1;
        }
        else {
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
        if (byte0 < STRING_SHORT_START)
            return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))
            return 1;
        else if (byte0 < LIST_SHORT_START)  // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else
            return byte0 - (LIST_LONG_START - 1) + 1;
    }
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {

        bytes memory result = new bytes(item.len);
        uint ptr;
        assembly {
            ptr := add(0x20, result)
        }
        copy(item.memPtr, ptr, item.len);
        return result;
    }

    function toBoolean(RLPItem memory item) internal pure returns (bool) {

        require(item.len == 1, "Invalid RLPItem. Booleans are encoded in 1 byte");
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }
        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(item.len <= 21, "Invalid RLPItem. Addresses are encoded in 20 bytes or less");
        return address(toUint(item));
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
        uint len = item.len - offset;
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
}// GPL-3.0-only
pragma solidity >=0.7.6;


interface IPenalizer {


    event CommitAdded(address indexed sender, bytes32 indexed commitHash, uint256 readyBlockNumber);

    struct Transaction {
        uint256 nonce;
        uint256 gasPrice;
        uint256 gasLimit;
        address to;
        uint256 value;
        bytes data;
    }

    function commit(bytes32 commitHash) external;


    function penalizeRepeatedNonce(
        bytes calldata unsignedTx1,
        bytes calldata signature1,
        bytes calldata unsignedTx2,
        bytes calldata signature2,
        IRelayHub hub,
        uint256 randomValue
    ) external;


    function penalizeIllegalTransaction(
        bytes calldata unsignedTx,
        bytes calldata signature,
        IRelayHub hub,
        uint256 randomValue
    ) external;


    function versionPenalizer() external view returns (string memory);

    function penalizeBlockDelay() external view returns (uint256);

    function penalizeBlockExpiration() external view returns (uint256);

}// GPL-3.0-only
pragma solidity >=0.7.6;



contract Penalizer is IPenalizer {


    string public override versionPenalizer = "2.2.0+opengsn.penalizer.ipenalizer";

    using ECDSA for bytes32;

    uint256 public immutable override penalizeBlockDelay;
    uint256 public immutable override penalizeBlockExpiration;

    constructor(
        uint256 _penalizeBlockDelay,
        uint256 _penalizeBlockExpiration
    ) {
        penalizeBlockDelay = _penalizeBlockDelay;
        penalizeBlockExpiration = _penalizeBlockExpiration;
    }

    function isTransactionType1(bytes calldata rawTransaction) public pure returns (bool) {

        return (uint8(rawTransaction[0]) == 1);
    }

    function isTransactionTypeValid(bytes calldata rawTransaction) public pure returns(bool) {

        uint8 transactionTypeByte = uint8(rawTransaction[0]);
        return (transactionTypeByte >= 0xc0 && transactionTypeByte <= 0xfe);
    }

    function decodeTransaction(bytes calldata rawTransaction) public pure returns (Transaction memory transaction) {

        if (isTransactionType1(rawTransaction)) {
            (transaction.nonce,
            transaction.gasPrice,
            transaction.gasLimit,
            transaction.to,
            transaction.value,
            transaction.data) = RLPReader.decodeTransactionType1(rawTransaction);
        } else {
            (transaction.nonce,
            transaction.gasPrice,
            transaction.gasLimit,
            transaction.to,
            transaction.value,
            transaction.data) = RLPReader.decodeLegacyTransaction(rawTransaction);
        }
        return transaction;
    }

    mapping(bytes32 => uint) public commits;

    function commit(bytes32 commitHash) external override {

        uint256 readyBlockNumber = block.number + penalizeBlockDelay;
        commits[commitHash] = readyBlockNumber;
        emit CommitAdded(msg.sender, commitHash, readyBlockNumber);
    }

    modifier commitRevealOnly() {

        bytes32 commitHash = keccak256(abi.encodePacked(keccak256(msg.data), msg.sender));
        uint256 readyBlockNumber = commits[commitHash];
        delete commits[commitHash];
        if(msg.sender != address(0)) {
            require(readyBlockNumber != 0, "no commit");
            require(readyBlockNumber < block.number, "reveal penalize too soon");
            require(readyBlockNumber + penalizeBlockExpiration > block.number, "reveal penalize too late");
        }
        _;
    }

    function penalizeRepeatedNonce(
        bytes calldata unsignedTx1,
        bytes calldata signature1,
        bytes calldata unsignedTx2,
        bytes calldata signature2,
        IRelayHub hub,
        uint256 randomValue
    )
    public
    override
    commitRevealOnly {

        (randomValue);
        _penalizeRepeatedNonce(unsignedTx1, signature1, unsignedTx2, signature2, hub);
    }

    function _penalizeRepeatedNonce(
        bytes calldata unsignedTx1,
        bytes calldata signature1,
        bytes calldata unsignedTx2,
        bytes calldata signature2,
        IRelayHub hub
    )
    private
    {


        address addr1 = keccak256(unsignedTx1).recover(signature1);
        address addr2 = keccak256(unsignedTx2).recover(signature2);

        require(addr1 == addr2, "Different signer");
        require(addr1 != address(0), "ecrecover failed");

        Transaction memory decodedTx1 = decodeTransaction(unsignedTx1);
        Transaction memory decodedTx2 = decodeTransaction(unsignedTx2);

        require(decodedTx1.nonce == decodedTx2.nonce, "Different nonce");

        bytes memory dataToCheck1 =
        abi.encodePacked(decodedTx1.data, decodedTx1.gasLimit, decodedTx1.to, decodedTx1.value);

        bytes memory dataToCheck2 =
        abi.encodePacked(decodedTx2.data, decodedTx2.gasLimit, decodedTx2.to, decodedTx2.value);

        require(keccak256(dataToCheck1) != keccak256(dataToCheck2), "tx is equal");

        penalize(addr1, hub);
    }

    function penalizeIllegalTransaction(
        bytes calldata unsignedTx,
        bytes calldata signature,
        IRelayHub hub,
        uint256 randomValue
    )
    public
    override
    commitRevealOnly {

        (randomValue);
        _penalizeIllegalTransaction(unsignedTx, signature, hub);
    }

    function _penalizeIllegalTransaction(
        bytes calldata unsignedTx,
        bytes calldata signature,
        IRelayHub hub
    )
    private
    {

        if (isTransactionTypeValid(unsignedTx)) {
            Transaction memory decodedTx = decodeTransaction(unsignedTx);
            if (decodedTx.to == address(hub)) {
                bytes4 selector = GsnUtils.getMethodSig(decodedTx.data);
                bool isWrongMethodCall = selector != IRelayHub.relayCall.selector;
                bool isGasLimitWrong = GsnUtils.getParam(decodedTx.data, 4) != decodedTx.gasLimit;
                require(
                    isWrongMethodCall || isGasLimitWrong,
                    "Legal relay transaction");
            }
        }
        address relay = keccak256(unsignedTx).recover(signature);
        require(relay != address(0), "ecrecover failed");
        penalize(relay, hub);
    }

    function penalize(address relayWorker, IRelayHub hub) private {

        hub.penalize(relayWorker, msg.sender);
    }
}// GPL-3.0-only
pragma solidity ^0.7.5;


library RelayHubValidator {


    function verifyTransactionPacking(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData
    ) internal pure {

        uint expectedMsgDataLen = 4 + 23 * 32 +
            dynamicParamSize(signature) +
            dynamicParamSize(approvalData) +
            dynamicParamSize(relayRequest.request.data) +
            dynamicParamSize(relayRequest.relayData.paymasterData);
        require(signature.length <= 65, "invalid signature length");
        require(expectedMsgDataLen == msg.data.length, "extra msg.data bytes" );
    }

    function dynamicParamSize(bytes calldata buf) internal pure returns (uint) {

        return 32 + ((buf.length + 31) & uint(~31));
    }
}/* solhint-disable avoid-low-level-calls */
pragma solidity ^0.7.6;



contract RelayHub is IRelayHub, Ownable {

    using SafeMath for uint256;

    string public override versionHub = "2.2.0+opengsn.hub.irelayhub-with-flashbots";

    IStakeManager immutable override public stakeManager;
    address immutable override public penalizer;

    RelayHubConfig private config;

    function getConfiguration() public override view returns (RelayHubConfig memory) {

        return config;
    }

    function setConfiguration(RelayHubConfig memory _config) public override onlyOwner {

        config = _config;
        emit RelayHubConfigured(config);
    }

    uint256 public constant G_NONZERO = 16;

    mapping(address => address) public override workerToManager;

    mapping(address => uint256) public override workerCount;

    mapping(address => uint256) private balances;

    uint256 public override deprecationBlock = type(uint).max;

    constructor (
        IStakeManager _stakeManager,
        address _penalizer,
        uint256 _maxWorkerCount,
        uint256 _gasReserve,
        uint256 _postOverhead,
        uint256 _gasOverhead,
        uint256 _maximumRecipientDeposit,
        uint256 _minimumUnstakeDelay,
        uint256 _minimumStake,
        uint256 _dataGasCostPerByte,
        uint256 _externalCallDataCostOverhead
    ) {
        stakeManager = _stakeManager;
        penalizer = _penalizer;
        setConfiguration(RelayHubConfig(
            _maxWorkerCount,
            _gasReserve,
            _postOverhead,
            _gasOverhead,
            _maximumRecipientDeposit,
            _minimumUnstakeDelay,
            _minimumStake,
            _dataGasCostPerByte,
            _externalCallDataCostOverhead
        ));
    }

    function registerRelayServer(uint256 baseRelayFee, uint256 pctRelayFee, string calldata url) external override {

        address relayManager = msg.sender;
        require(
            isRelayManagerStaked(relayManager),
            "relay manager not staked"
        );
        require(workerCount[relayManager] > 0, "no relay workers");
        emit RelayServerRegistered(relayManager, baseRelayFee, pctRelayFee, url);
    }

    function addRelayWorkers(address[] calldata newRelayWorkers) external override {

        address relayManager = msg.sender;
        uint256 newWorkerCount = workerCount[relayManager] + newRelayWorkers.length;
        workerCount[relayManager] = newWorkerCount;
        require(newWorkerCount <= config.maxWorkerCount, "too many workers");

        require(
            isRelayManagerStaked(relayManager),
            "relay manager not staked"
        );

        for (uint256 i = 0; i < newRelayWorkers.length; i++) {
            require(workerToManager[newRelayWorkers[i]] == address(0), "this worker has a manager");
            workerToManager[newRelayWorkers[i]] = relayManager;
        }

        emit RelayWorkersAdded(relayManager, newRelayWorkers, newWorkerCount);
    }

    function depositFor(address target) public override payable {

        uint256 amount = msg.value;
        require(amount <= config.maximumRecipientDeposit, "deposit too big");

        balances[target] = balances[target].add(amount);

        emit Deposited(target, msg.sender, amount);
    }

    function balanceOf(address target) external override view returns (uint256) {

        return balances[target];
    }

    function withdraw(uint256 amount, address payable dest) public override {

        address payable account = msg.sender;
        require(balances[account] >= amount, "insufficient funds");

        balances[account] = balances[account].sub(amount);
        dest.transfer(amount);

        emit Withdrawn(account, dest, amount);
    }

    function calldataGasCost(uint256 length) public override view returns (uint256) {

        return config.dataGasCostPerByte.mul(length);
}

    function verifyGasAndDataLimits(
        uint256 maxAcceptanceBudget,
        GsnTypes.RelayRequest calldata relayRequest,
        uint256 initialGasLeft,
        uint256 externalGasLimit
    )
    private
    view
    returns (IPaymaster.GasAndDataLimits memory gasAndDataLimits, uint256 maxPossibleGas) {

        gasAndDataLimits =
            IPaymaster(relayRequest.relayData.paymaster).getGasAndDataLimits{gas:50000}();
        require(msg.data.length <= gasAndDataLimits.calldataSizeLimit, "msg.data exceeded limit" );
        uint256 dataGasCost = calldataGasCost(msg.data.length);
        uint256 externalCallDataCost = externalGasLimit - initialGasLeft - config.externalCallDataCostOverhead;
        uint256 txDataCostPerByte = externalCallDataCost/msg.data.length;
        require(relayRequest.relayData.isFlashbots || txDataCostPerByte <= G_NONZERO, "invalid externalGasLimit");

        require(maxAcceptanceBudget >= gasAndDataLimits.acceptanceBudget, "acceptance budget too high");
        require(gasAndDataLimits.acceptanceBudget >= gasAndDataLimits.preRelayedCallGasLimit, "acceptance budget too low");

        maxPossibleGas =
            config.gasOverhead.add(
            gasAndDataLimits.preRelayedCallGasLimit).add(
            gasAndDataLimits.postRelayedCallGasLimit).add(
            relayRequest.request.gas).add(
            dataGasCost).add(
            externalCallDataCost);

        require(
            externalGasLimit >= maxPossibleGas,
            "no gas for innerRelayCall");

        uint256 maxPossibleCharge = calculateCharge(
            maxPossibleGas,
            relayRequest.relayData
        );

        require(maxPossibleCharge <= balances[relayRequest.relayData.paymaster],
            "Paymaster balance too low");
    }

    struct RelayCallData {
        bool success;
        bytes4 functionSelector;
        uint256 initialGasLeft;
        bytes recipientContext;
        bytes relayedCallReturnValue;
        IPaymaster.GasAndDataLimits gasAndDataLimits;
        RelayCallStatus status;
        uint256 innerGasUsed;
        uint256 maxPossibleGas;
        uint256 gasBeforeInner;
        bytes retData;
        address relayManager;
        uint256 dataGasCost;
    }

    function relayCall(
        uint maxAcceptanceBudget,
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint externalGasLimit
    )
    external
    override
    returns (bool paymasterAccepted, bytes memory returnValue)
    {

        RelayCallData memory vars;
        vars.initialGasLeft = gasleft();
        require(!isDeprecated(), "hub deprecated");
        vars.functionSelector = relayRequest.request.data.length>=4 ? MinLibBytes.readBytes4(relayRequest.request.data, 0) : bytes4(0);
        require(relayRequest.relayData.isFlashbots ||msg.sender == tx.origin, "relay worker must be EOA");
        vars.relayManager = workerToManager[msg.sender];
        require(relayRequest.relayData.isFlashbots || vars.relayManager != address(0), "Unknown relay worker");
        require(relayRequest.relayData.isFlashbots || relayRequest.relayData.relayWorker == msg.sender, "Not a right worker");
        require(
            relayRequest.relayData.isFlashbots ||
            isRelayManagerStaked(vars.relayManager),
            "relay manager not staked"
        );
        require(relayRequest.relayData.isFlashbots || relayRequest.relayData.gasPrice <= tx.gasprice, "Invalid gas price");
        require(relayRequest.relayData.isFlashbots || externalGasLimit <= block.gaslimit, "Impossible gas limit");

        (vars.gasAndDataLimits, vars.maxPossibleGas) =
             verifyGasAndDataLimits(maxAcceptanceBudget, relayRequest, vars.initialGasLeft, externalGasLimit);

        RelayHubValidator.verifyTransactionPacking(relayRequest,signature,approvalData);

    {

        uint256 innerGasLimit = gasleft()*63/64- config.gasReserve;
        vars.gasBeforeInner = gasleft();

        uint256 _tmpInitialGas = innerGasLimit + externalGasLimit + config.gasOverhead + config.postOverhead;
        (bool success, bytes memory relayCallStatus) = address(this).call{gas:innerGasLimit}(
            abi.encodeWithSelector(RelayHub.innerRelayCall.selector, relayRequest, signature, approvalData, vars.gasAndDataLimits,
                _tmpInitialGas - gasleft(),
                vars.maxPossibleGas
                )
        );
        vars.success = success;
        vars.innerGasUsed = vars.gasBeforeInner-gasleft();
        (vars.status, vars.relayedCallReturnValue) = abi.decode(relayCallStatus, (RelayCallStatus, bytes));
        if ( vars.relayedCallReturnValue.length>0 ) {
            emit TransactionResult(vars.status, vars.relayedCallReturnValue);
        }
    }
    {
        vars.dataGasCost = calldataGasCost(msg.data.length);
        if (!vars.success) {
            if (vars.status == RelayCallStatus.RejectedByPreRelayed ||
                    (vars.innerGasUsed <= vars.gasAndDataLimits.acceptanceBudget.add(vars.dataGasCost)) && (
                    vars.status == RelayCallStatus.RejectedByForwarder ||
                    vars.status == RelayCallStatus.RejectedByRecipientRevert  //can only be thrown if rejectOnRecipientRevert==true
            )) {
                paymasterAccepted=false;

                emit TransactionRejectedByPaymaster(
                    vars.relayManager,
                    relayRequest.relayData.paymaster,
                    relayRequest.request.from,
                    relayRequest.request.to,
                    msg.sender,
                    vars.functionSelector,
                    vars.innerGasUsed,
                    vars.relayedCallReturnValue);
                return (false, vars.relayedCallReturnValue);
            }
        }
        uint256 gasUsed = (externalGasLimit - gasleft()) + config.gasOverhead;
        uint256 charge = calculateCharge(gasUsed, relayRequest.relayData);

        if (!relayRequest.relayData.isFlashbots){
            balances[relayRequest.relayData.paymaster] = balances[relayRequest.relayData.paymaster].sub(charge);
            balances[vars.relayManager] = balances[vars.relayManager].add(charge);
        } else {
            balances[relayRequest.relayData.paymaster] = balances[relayRequest.relayData.paymaster].sub(charge);
            block.coinbase.transfer(charge);
        }

        emit TransactionRelayed(
            vars.relayManager,
            msg.sender,
            relayRequest.request.from,
            relayRequest.request.to,
            relayRequest.relayData.paymaster,
            vars.functionSelector,
            vars.status,
            charge);
        return (true, "");
    }
    }

    struct InnerRelayCallData {
        uint256 balanceBefore;
        bytes32 preReturnValue;
        bool relayedCallSuccess;
        bytes relayedCallReturnValue;
        bytes recipientContext;
        bytes data;
        bool rejectOnRecipientRevert;
    }

    function innerRelayCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        IPaymaster.GasAndDataLimits calldata gasAndDataLimits,
        uint256 totalInitialGas,
        uint256 maxPossibleGas
    )
    external
    returns (RelayCallStatus, bytes memory)
    {

        InnerRelayCallData memory vars;

        require(msg.sender == address(this), "Must be called by RelayHub");


        vars.balanceBefore = balances[relayRequest.relayData.paymaster];

        vars.data = abi.encodeWithSelector(
            IPaymaster.preRelayedCall.selector,
                relayRequest, signature, approvalData, maxPossibleGas
        );
        {
            bool success;
            bytes memory retData;
            (success, retData) = relayRequest.relayData.paymaster.call{gas:gasAndDataLimits.preRelayedCallGasLimit}(vars.data);
            if (!success) {
                GsnEip712Library.truncateInPlace(retData);
                revertWithStatus(RelayCallStatus.RejectedByPreRelayed, retData);
            }
            (vars.recipientContext, vars.rejectOnRecipientRevert) = abi.decode(retData, (bytes,bool));
        }


        {
            bool forwarderSuccess;
            (forwarderSuccess, vars.relayedCallSuccess, vars.relayedCallReturnValue) = GsnEip712Library.execute(relayRequest, signature);
            if ( !forwarderSuccess ) {
                revertWithStatus(RelayCallStatus.RejectedByForwarder, vars.relayedCallReturnValue);
            }

            if (vars.rejectOnRecipientRevert && !vars.relayedCallSuccess) {
                revertWithStatus(RelayCallStatus.RejectedByRecipientRevert, vars.relayedCallReturnValue);
            }
        }
        vars.data = abi.encodeWithSelector(
            IPaymaster.postRelayedCall.selector,
            vars.recipientContext,
            vars.relayedCallSuccess,
            totalInitialGas - gasleft(), /*gasUseWithoutPost*/
            relayRequest.relayData
        );

        {
        (bool successPost,bytes memory ret) = relayRequest.relayData.paymaster.call{gas:gasAndDataLimits.postRelayedCallGasLimit}(vars.data);

        if (!successPost) {
            revertWithStatus(RelayCallStatus.PostRelayedFailed, ret);
        }
        }

        if (balances[relayRequest.relayData.paymaster] < vars.balanceBefore) {
            revertWithStatus(RelayCallStatus.PaymasterBalanceChanged, "");
        }

        return (vars.relayedCallSuccess ? RelayCallStatus.OK : RelayCallStatus.RelayedCallFailed, vars.relayedCallReturnValue);
    }

    function revertWithStatus(RelayCallStatus status, bytes memory ret) private pure {

        bytes memory data = abi.encode(status, ret);
        GsnEip712Library.truncateInPlace(data);

        assembly {
            let dataSize := mload(data)
            let dataPtr := add(data, 32)

            revert(dataPtr, dataSize)
        }
    }

    function calculateCharge(uint256 gasUsed, GsnTypes.RelayData calldata relayData) public override virtual view returns (uint256) {

        return relayData.baseRelayFee.add((gasUsed.mul(relayData.gasPrice).mul(relayData.pctRelayFee.add(100))).div(100));
    }

    function isRelayManagerStaked(address relayManager) public override view returns (bool) {

        return stakeManager.isRelayManagerStaked(relayManager, address(this), config.minimumStake, config.minimumUnstakeDelay);
    }

    function deprecateHub(uint256 fromBlock) public override onlyOwner {

        require(deprecationBlock > block.number, "Already deprecated");
        deprecationBlock = fromBlock;
        emit HubDeprecated(fromBlock);
    }

    function isDeprecated() public override view returns (bool) {

        return block.number >= deprecationBlock;
    }

    modifier penalizerOnly () {

        require(msg.sender == penalizer, "Not penalizer");
        _;
    }

    function penalize(address relayWorker, address payable beneficiary) external override penalizerOnly {

        address relayManager = workerToManager[relayWorker];
        require(relayManager != address(0), "Unknown relay worker");
        require(
            isRelayManagerStaked(relayManager),
            "relay manager not staked"
        );
        IStakeManager.StakeInfo memory stakeInfo = stakeManager.getStakeInfo(relayManager);
        stakeManager.penalizeRelayManager(relayManager, beneficiary, stakeInfo.stake);
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;



contract StakeManager is IStakeManager {

    using SafeMath for uint256;

    string public override versionSM = "2.2.0+opengsn.stakemanager.istakemanager";
    uint256 public immutable override maxUnstakeDelay;

    mapping(address => StakeInfo) public stakes;
    function getStakeInfo(address relayManager) external override view returns (StakeInfo memory stakeInfo) {

        return stakes[relayManager];
    }

    mapping(address => mapping(address => RelayHubInfo)) public authorizedHubs;

    constructor(uint256 _maxUnstakeDelay) {
        maxUnstakeDelay = _maxUnstakeDelay;
    }

    function setRelayManagerOwner(address payable owner) external override {

        require(owner != address(0), "invalid owner");
        require(stakes[msg.sender].owner == address(0), "already owned");
        stakes[msg.sender].owner = owner;
        emit OwnerSet(msg.sender, owner);
    }

    function stakeForRelayManager(address relayManager, uint256 unstakeDelay) external override payable ownerOnly(relayManager) {

        require(unstakeDelay >= stakes[relayManager].unstakeDelay, "unstakeDelay cannot be decreased");
        require(unstakeDelay <= maxUnstakeDelay, "unstakeDelay too big");
        stakes[relayManager].stake += msg.value;
        stakes[relayManager].unstakeDelay = unstakeDelay;
        emit StakeAdded(relayManager, stakes[relayManager].owner, stakes[relayManager].stake, stakes[relayManager].unstakeDelay);
    }

    function unlockStake(address relayManager) external override ownerOnly(relayManager) {

        StakeInfo storage info = stakes[relayManager];
        require(info.withdrawBlock == 0, "already pending");
        uint withdrawBlock = block.number.add(info.unstakeDelay);
        info.withdrawBlock = withdrawBlock;
        emit StakeUnlocked(relayManager, msg.sender, withdrawBlock);
    }

    function withdrawStake(address relayManager) external override ownerOnly(relayManager) {

        StakeInfo storage info = stakes[relayManager];
        require(info.withdrawBlock > 0, "Withdrawal is not scheduled");
        require(info.withdrawBlock <= block.number, "Withdrawal is not due");
        uint256 amount = info.stake;
        info.stake = 0;
        info.withdrawBlock = 0;
        msg.sender.transfer(amount);
        emit StakeWithdrawn(relayManager, msg.sender, amount);
    }

    modifier ownerOnly (address relayManager) {

        StakeInfo storage info = stakes[relayManager];
        require(info.owner == msg.sender, "not owner");
        _;
    }

    modifier managerOnly () {

        StakeInfo storage info = stakes[msg.sender];
        require(info.owner != address(0), "not manager");
        _;
    }

    function authorizeHubByOwner(address relayManager, address relayHub) external ownerOnly(relayManager) override {

        _authorizeHub(relayManager, relayHub);
    }

    function authorizeHubByManager(address relayHub) external managerOnly override {

        _authorizeHub(msg.sender, relayHub);
    }

    function _authorizeHub(address relayManager, address relayHub) internal {

        authorizedHubs[relayManager][relayHub].removalBlock = uint(-1);
        emit HubAuthorized(relayManager, relayHub);
    }

    function unauthorizeHubByOwner(address relayManager, address relayHub) external override ownerOnly(relayManager) {

        _unauthorizeHub(relayManager, relayHub);
    }

    function unauthorizeHubByManager(address relayHub) external override managerOnly {

        _unauthorizeHub(msg.sender, relayHub);
    }

    function _unauthorizeHub(address relayManager, address relayHub) internal {

        RelayHubInfo storage hubInfo = authorizedHubs[relayManager][relayHub];
        require(hubInfo.removalBlock == uint(-1), "hub not authorized");
        uint256 removalBlock = block.number.add(stakes[relayManager].unstakeDelay);
        hubInfo.removalBlock = removalBlock;
        emit HubUnauthorized(relayManager, relayHub, removalBlock);
    }

    function isRelayManagerStaked(address relayManager, address relayHub, uint256 minAmount, uint256 minUnstakeDelay)
    external
    override
    view
    returns (bool) {

        StakeInfo storage info = stakes[relayManager];
        bool isAmountSufficient = info.stake >= minAmount;
        bool isDelaySufficient = info.unstakeDelay >= minUnstakeDelay;
        bool isStakeLocked = info.withdrawBlock == 0;
        bool isHubAuthorized = authorizedHubs[relayManager][relayHub].removalBlock == uint(-1);
        return
        isAmountSufficient &&
        isDelaySufficient &&
        isStakeLocked &&
        isHubAuthorized;
    }

    function penalizeRelayManager(address relayManager, address payable beneficiary, uint256 amount) external override {

        uint256 removalBlock =  authorizedHubs[relayManager][msg.sender].removalBlock;
        require(removalBlock != 0, "hub not authorized");
        require(removalBlock > block.number, "hub authorization expired");

        require(stakes[relayManager].stake >= amount, "penalty exceeds stake");
        stakes[relayManager].stake = SafeMath.sub(stakes[relayManager].stake, amount);

        uint256 toBurn = SafeMath.div(amount, 2);
        uint256 reward = SafeMath.sub(amount, toBurn);

        address(0).transfer(toBurn);
        beneficiary.transfer(reward);
        emit StakePenalized(relayManager, beneficiary, reward);
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestForwarder {

    function callExecute(Forwarder forwarder, Forwarder.ForwardRequest memory req,
        bytes32 domainSeparator, bytes32 requestTypeHash, bytes memory suffixData, bytes memory sig) public payable {

        (bool success, bytes memory error) = forwarder.execute{value:msg.value}(req, domainSeparator, requestTypeHash, suffixData, sig);
        emit Result(success, success ? "" : this.decodeErrorMessage(error));
    }

    event Result(bool success, string error);

    function decodeErrorMessage(bytes calldata ret) external pure returns (string memory message) {

        if ( ret.length>4+32+32 ) {
            return abi.decode(ret[4:], (string));
        }
        return string(ret);
    }

    function getChainId() public pure returns (uint256 id){

        assembly { id := chainid() }
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestForwarderTarget is BaseRelayRecipient {


    string public override versionRecipient = "2.2.0+opengsn.test.recipient";

    constructor(address forwarder) {
        trustedForwarder = forwarder;
    }

    receive() external payable {}

    event TestForwarderMessage(string message, bytes realMsgData, address realSender, address msgSender, address origin);

    function emitMessage(string memory message) public {


        emit TestForwarderMessage(message, _msgData(), _msgSender(), msg.sender, tx.origin);
    }

    function publicMsgSender() public view returns (address) {

        return _msgSender();
    }

    function publicMsgData() public view returns (bytes memory) {

        return _msgData();
    }

    function mustReceiveEth(uint value) public payable {

        require( msg.value == value, "didn't receive value");
    }

    event Reverting(string message);

    function testRevert() public {

        require(address(this) == address(0), "always fail");
        emit Reverting("if you see this revert failed...");
    }
}// GPL-3.0-only
pragma solidity >=0.7.6;

interface IVersionRegistry {


    event VersionAdded(bytes32 indexed id, bytes32 version, string value, uint time);

    event VersionCanceled(bytes32 indexed id, bytes32 version, string reason);

    function addVersion(bytes32 id, bytes32 version, string calldata value) external;


    function cancelVersion(bytes32 id, bytes32 version, string calldata reason) external;

}// GPL-3.0-only
pragma solidity ^0.7.6;

contract PayableWithEmit is BaseRelayRecipient {


  string public override versionRecipient = "2.2.0+opengsn.payablewithemit.irelayrecipient";

  event Received(address sender, uint value, uint gasleft);

  receive () external payable {

    emit Received(_msgSender(), msg.value, gasleft());
  }


  function doSend(address payable target) public payable {


    uint before = gasleft();
    bool success = target.send(msg.value);
    uint gasAfter = gasleft();
    emit GasUsed(before-gasAfter, success);
  }
  event GasUsed(uint gasUsed, bool success);
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestPaymasterEverythingAccepted is BasePaymaster {


    function versionPaymaster() external view override virtual returns (string memory){

        return "2.2.0+opengsn.test-pea.ipaymaster";
    }

    event SampleRecipientPreCall();
    event SampleRecipientPostCall(bool success, uint actualCharge);

    function preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
    external
    override
    virtual
    returns (bytes memory, bool) {

        (signature);
        _verifyForwarder(relayRequest);
        (approvalData, maxPossibleGas);
        emit SampleRecipientPreCall();
        return ("no revert here",false);
    }

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        GsnTypes.RelayData calldata relayData
    )
    external
    override
    virtual
    {

        (context, gasUseWithoutPost, relayData);
        emit SampleRecipientPostCall(success, gasUseWithoutPost);
    }

    function deposit() public payable {

        require(address(relayHub) != address(0), "relay hub address not set");
        relayHub.depositFor{value:msg.value}(address(this));
    }

    function withdrawAll(address payable destination) public {

        uint256 amount = relayHub.balanceOf(address(this));
        withdrawRelayHubDepositTo(amount, destination);
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestPaymasterConfigurableMisbehavior is TestPaymasterEverythingAccepted {


    bool public withdrawDuringPostRelayedCall;
    bool public withdrawDuringPreRelayedCall;
    bool public returnInvalidErrorCode;
    bool public revertPostRelayCall;
    bool public outOfGasPre;
    bool public revertPreRelayCall;
    bool public revertPreRelayCallOnEvenBlocks;
    bool public greedyAcceptanceBudget;
    bool public expensiveGasLimits;

    function setWithdrawDuringPostRelayedCall(bool val) public {

        withdrawDuringPostRelayedCall = val;
    }
    function setWithdrawDuringPreRelayedCall(bool val) public {

        withdrawDuringPreRelayedCall = val;
    }
    function setReturnInvalidErrorCode(bool val) public {

        returnInvalidErrorCode = val;
    }
    function setRevertPostRelayCall(bool val) public {

        revertPostRelayCall = val;
    }
    function setRevertPreRelayCall(bool val) public {

        revertPreRelayCall = val;
    }
    function setRevertPreRelayCallOnEvenBlocks(bool val) public {

        revertPreRelayCallOnEvenBlocks = val;
    }
    function setOutOfGasPre(bool val) public {

        outOfGasPre = val;
    }

    function setGreedyAcceptanceBudget(bool val) public {

        greedyAcceptanceBudget = val;
    }
    function setExpensiveGasLimits(bool val) public {

        expensiveGasLimits = val;
    }

    function preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
    external
    override
    relayHubOnly
    returns (bytes memory, bool) {

        (signature, approvalData, maxPossibleGas);
        if (outOfGasPre) {
            uint i = 0;
            while (true) {
                i++;
            }
        }

        require(!returnInvalidErrorCode, "invalid code");

        if (withdrawDuringPreRelayedCall) {
            withdrawAllBalance();
        }
        if (revertPreRelayCall) {
            revert("You asked me to revert, remember?");
        }
        if (revertPreRelayCallOnEvenBlocks && block.number % 2 == 0) {
            revert("You asked me to revert on even blocks, remember?");
        }
        _verifyForwarder(relayRequest);
        return ("", trustRecipientRevert);
    }

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        GsnTypes.RelayData calldata relayData
    )
    external
    override
    relayHubOnly
    {

        (context, success, gasUseWithoutPost, relayData);
        if (withdrawDuringPostRelayedCall) {
            withdrawAllBalance();
        }
        if (revertPostRelayCall) {
            revert("You asked me to revert, remember?");
        }
    }

    function withdrawAllBalance() public returns (uint256) {

        require(address(relayHub) != address(0), "relay hub address not set");
        uint256 balance = relayHub.balanceOf(address(this));
        relayHub.withdraw(balance, address(this));
        return balance;
    }

    IPaymaster.GasAndDataLimits private limits = super.getGasAndDataLimits();

    function getGasAndDataLimits()
    public override view
    returns (IPaymaster.GasAndDataLimits memory) {


        if (expensiveGasLimits) {
            uint sum;
            for ( int i=0; i<60000; i+=700 ) {
                sum  = sum + limits.acceptanceBudget;
            }
        }
        if (greedyAcceptanceBudget) {
            return IPaymaster.GasAndDataLimits(limits.acceptanceBudget * 9, limits.preRelayedCallGasLimit, limits.postRelayedCallGasLimit,
            limits.calldataSizeLimit);
        }
        return limits;
    }

    bool private trustRecipientRevert;

    function setGasLimits(uint acceptanceBudget, uint preRelayedCallGasLimit, uint postRelayedCallGasLimit) public {

        limits = IPaymaster.GasAndDataLimits(
            acceptanceBudget,
            preRelayedCallGasLimit,
            postRelayedCallGasLimit,
            limits.calldataSizeLimit
        );
    }

    function setTrustRecipientRevert(bool on) public {

        trustRecipientRevert = on;
    }

    receive() external override payable {}
}// GPL-3.0-only
pragma solidity ^0.7.6;



contract TestPaymasterOwnerSignature is TestPaymasterEverythingAccepted {

    using ECDSA for bytes32;

    function preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
    external
    view
    override
    returns (bytes memory, bool) {

        (signature, maxPossibleGas);
        _verifyForwarder(relayRequest);

        address signer =
            keccak256(abi.encodePacked("I approve", relayRequest.request.from))
            .toEthSignedMessageHash()
            .recover(approvalData);
        require(signer == owner(), "test: not approved");
        return ("",false);
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestPaymasterPreconfiguredApproval is TestPaymasterEverythingAccepted {


    bytes public expectedApprovalData;

    function setExpectedApprovalData(bytes memory val) public {

        expectedApprovalData = val;
    }

    function preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
    external
    view
    override
    returns (bytes memory, bool) {

        (relayRequest, signature, approvalData, maxPossibleGas);
        _verifyForwarder(relayRequest);
        require(keccak256(expectedApprovalData) == keccak256(approvalData),
            string(abi.encodePacked(
                "test: unexpected approvalData: '", approvalData, "' instead of '", expectedApprovalData, "'")));
        return ("",false);
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestPaymasterStoreContext is TestPaymasterEverythingAccepted {


    event SampleRecipientPreCallWithValues(
        address relay,
        address from,
        bytes encodedFunction,
        uint256 baseRelayFee,
        uint256 pctRelayFee,
        uint256 gasPrice,
        uint256 gasLimit,
        bytes approvalData,
        uint256 maxPossibleGas
    );

    event SampleRecipientPostCallWithValues(
        string context
    );

    function preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
    external
    override
    returns (bytes memory, bool) {

        (signature, approvalData, maxPossibleGas);
        _verifyForwarder(relayRequest);

        emit SampleRecipientPreCallWithValues(
            relayRequest.relayData.relayWorker,
            relayRequest.request.from,
            relayRequest.request.data,
            relayRequest.relayData.baseRelayFee,
            relayRequest.relayData.pctRelayFee,
            relayRequest.relayData.gasPrice,
            relayRequest.request.gas,
            approvalData,
            maxPossibleGas);
        return ("context passed from preRelayedCall to postRelayedCall",false);
    }

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        GsnTypes.RelayData calldata relayData
    )
    external
    override
    relayHubOnly
    {

        (context, success, gasUseWithoutPost, relayData);
        emit SampleRecipientPostCallWithValues(string(context));
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestPaymasterVariableGasLimits is TestPaymasterEverythingAccepted {


    string public override versionPaymaster = "2.2.0+opengsn.test-vgl.ipaymaster";

    event SampleRecipientPreCallWithValues(
        uint256 gasleft,
        uint256 maxPossibleGas
    );

    event SampleRecipientPostCallWithValues(
        uint256 gasleft,
        uint256 gasUseWithoutPost
    );

    function preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
    external
    override
    returns (bytes memory, bool) {

        (signature, approvalData);
        _verifyForwarder(relayRequest);
        emit SampleRecipientPreCallWithValues(
            gasleft(), maxPossibleGas);
        return ("", false);
    }

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        GsnTypes.RelayData calldata relayData
    )
    external
    override
    relayHubOnly
    {

        (context, success, gasUseWithoutPost, relayData);
        emit SampleRecipientPostCallWithValues(gasleft(), gasUseWithoutPost);
    }
}/* solhint-disable avoid-tx-origin */
pragma solidity ^0.7.6;


contract TestRecipient is BaseRelayRecipient {


    string public override versionRecipient = "2.2.0+opengsn.test.irelayrecipient";

    constructor(address forwarder) {
        setTrustedForwarder(forwarder);
    }

    function getTrustedForwarder() public view returns(address) {

        return trustedForwarder;
    }

    function setTrustedForwarder(address forwarder) internal {

        trustedForwarder = forwarder;
    }

    event Reverting(string message);

    function testRevert() public {

        require(address(this) == address(0), "always fail");
        emit Reverting("if you see this revert failed...");
    }

    address payable public paymaster;

    function setWithdrawDuringRelayedCall(address payable _paymaster) public {

        paymaster = _paymaster;
    }

    receive() external payable {}

    event SampleRecipientEmitted(string message, address realSender, address msgSender, address origin, uint256 msgValue, uint256 gasLeft, uint256 balance);

    function emitMessage(string memory message) public payable returns (string memory) {

        uint256 gasLeft = gasleft();
        if (paymaster != address(0)) {
            withdrawAllBalance();
        }

        emit SampleRecipientEmitted(message, _msgSender(), msg.sender, tx.origin, msg.value, gasLeft, address(this).balance);
        return "emitMessage return value";
    }

    function withdrawAllBalance() public {

        TestPaymasterConfigurableMisbehavior(paymaster).withdrawAllBalance();
    }

    function dontEmitMessage(string calldata message) public {}


    function emitMessageNoParams() public {

        emit SampleRecipientEmitted("Method with no parameters", _msgSender(), msg.sender, tx.origin, 0, gasleft(), address(this).balance);
    }

    function checkReturnValues(uint len, bool doRevert) public view returns (string memory) {

        (this);
        string memory mesg = "this is a long message that we are going to return a small part from. we don't use a loop since we want a fixed gas usage of the method itself.";
        require( bytes(mesg).length>=len, "invalid len: too large");

        assembly { mstore(mesg, len) }
        require(!doRevert, mesg);
        return mesg;
    }

    function checkNoReturnValues(bool doRevert) public view {

        (this);
        require(!doRevert);
    }

}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestRelayHubValidator {


    function dummyRelayCall(
        uint, //paymasterMaxAcceptanceBudget,
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint //externalGasLimit
    ) external pure {

        RelayHubValidator.verifyTransactionPacking(relayRequest, signature, approvalData);
    }

    function dynamicParamSize(bytes calldata buf) external pure returns (uint) {

        return RelayHubValidator.dynamicParamSize(buf);
    }
}/* solhint-disable avoid-tx-origin */
pragma solidity ^0.7.6;


contract TestRelayWorkerContract {


    function relayCall(
        IRelayHub hub,
        uint maxAcceptanceBudget,
        GsnTypes.RelayRequest memory relayRequest,
        bytes memory signature,
        uint externalGasLimit)
    public
    {

        hub.relayCall{gas:externalGasLimit}(maxAcceptanceBudget, relayRequest, signature, "", externalGasLimit);
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract TestUtil {


    function libRelayRequestName() public pure returns (string memory) {

        return GsnEip712Library.RELAY_REQUEST_NAME;
    }

    function libRelayRequestType() public pure returns (string memory) {

        return string(GsnEip712Library.RELAY_REQUEST_TYPE);
    }

    function libRelayRequestTypeHash() public pure returns (bytes32) {

        return GsnEip712Library.RELAY_REQUEST_TYPEHASH;
    }

    function libRelayRequestSuffix() public pure returns (string memory) {

        return GsnEip712Library.RELAY_REQUEST_SUFFIX;
    }

    function callForwarderVerify(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature
    )
    external
    view {

        GsnEip712Library.verify(relayRequest, signature);
    }

    function callForwarderVerifyAndCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature
    )
    external
    returns (
        bool success,
        bytes memory ret
    ) {

        bool forwarderSuccess;
        (forwarderSuccess, success, ret) = GsnEip712Library.execute(relayRequest, signature);
        if ( !forwarderSuccess) {
            GsnUtils.revertWithData(ret);
        }
        emit Called(success, success == false ? ret : bytes(""));
    }

    event Called(bool success, bytes error);

    function splitRequest(
        GsnTypes.RelayRequest calldata relayRequest
    )
    external
    pure
    returns (
        bytes32 typeHash,
        bytes memory suffixData
    ) {

        (suffixData) = GsnEip712Library.splitRequest(relayRequest);
        typeHash = GsnEip712Library.RELAY_REQUEST_TYPEHASH;
    }

    function libDomainSeparator(address forwarder) public pure returns (bytes32) {

        return GsnEip712Library.domainSeparator(forwarder);
    }

    function libGetChainID() public pure returns (uint256) {

        return GsnEip712Library.getChainID();
    }
}// GPL-3.0-only
pragma solidity ^0.7.6;


contract VersionRegistry is IVersionRegistry, Ownable {


    function addVersion(bytes32 id, bytes32 version, string calldata value) external override onlyOwner {

        require(id != bytes32(0), "missing id");
        require(version != bytes32(0), "missing version");
        emit VersionAdded(id, version, value, block.timestamp);
    }

    function cancelVersion(bytes32 id, bytes32 version, string calldata reason) external override onlyOwner {

        emit VersionCanceled(id, version, reason);
    }
}