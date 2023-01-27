
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;



interface Wallet
{

    function version() external pure returns (string memory);


    function owner() external view returns (address);


    function setOwner(address newOwner) external;


    function addModule(address _module) external;


    function removeModule(address _module) external;


    function hasModule(address _module) external view returns (bool);


    function bindMethod(bytes4 _method, address _module) external;


    function boundMethodModule(bytes4 _method) external view returns (address _module);


    function transact(
        uint8    mode,
        address  to,
        uint     value,
        bytes    calldata data
        )
        external
        returns (bytes memory returnData);

}




library AddressUtil
{

    using AddressUtil for *;

    function isContract(
        address addr
        )
        internal
        view
        returns (bool)
    {

        bytes32 codehash;
        assembly { codehash := extcodehash(addr) }
        return (codehash != 0x0 &&
                codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
    }

    function toPayable(
        address addr
        )
        internal
        pure
        returns (address payable)
    {

        return payable(addr);
    }

    function sendETH(
        address to,
        uint    amount,
        uint    gasLimit
        )
        internal
        returns (bool success)
    {

        if (amount == 0) {
            return true;
        }
        address payable recipient = to.toPayable();
        (success,) = recipient.call{value: amount, gas: gasLimit}("");
    }

    function sendETHAndVerify(
        address to,
        uint    amount,
        uint    gasLimit
        )
        internal
        returns (bool success)
    {

        success = to.sendETH(amount, gasLimit);
        require(success, "TRANSFER_FAILURE");
    }

    function fastCall(
        address to,
        uint    gasLimit,
        uint    value,
        bytes   memory data
        )
        internal
        returns (bool success, bytes memory returnData)
    {

        if (to != address(0)) {
            assembly {
                success := call(gasLimit, to, value, add(data, 32), mload(data), 0, 0)
                let size := returndatasize()
                returnData := mload(0x40)
                mstore(returnData, size)
                returndatacopy(add(returnData, 32), 0, size)
                mstore(0x40, add(returnData, add(32, size)))
            }
        }
    }

    function fastCallAndVerify(
        address to,
        uint    gasLimit,
        uint    value,
        bytes   memory data
        )
        internal
        returns (bytes memory returnData)
    {

        bool success;
        (success, returnData) = fastCall(to, gasLimit, value, data);
        if (!success) {
            assembly {
                revert(add(returnData, 32), mload(returnData))
            }
        }
    }
}



abstract contract ERC1271 {
    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;

    function isValidSignature(
        bytes32      _hash,
        bytes memory _signature)
        public
        view
        virtual
        returns (bytes4 magicValueB32);
}



library BytesUtil {

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

    function toUint24(bytes memory _bytes, uint _start) internal  pure returns (uint24) {

        require(_bytes.length >= (_start + 3));
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
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

    function toBytes4(bytes memory _bytes, uint _start) internal  pure returns (bytes4) {

        require(_bytes.length >= (_start + 4));
        bytes4 tempBytes4;

        assembly {
            tempBytes4 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes4;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function fastSHA256(
        bytes memory data
        )
        internal
        view
        returns (bytes32)
    {

        bytes32[] memory result = new bytes32[](1);
        bool success;
        assembly {
             let ptr := add(data, 32)
             success := staticcall(sub(gas(), 2000), 2, ptr, mload(data), add(result, 32), 32)
        }
        require(success, "SHA256_FAILED");
        return result[0];
    }
}




library MathUint
{

    function mul(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {

        c = a * b;
        require(a == 0 || c / a == b, "MUL_OVERFLOW");
    }

    function sub(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint)
    {

        require(b <= a, "SUB_UNDERFLOW");
        return a - b;
    }

    function add(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {

        c = a + b;
        require(c >= a, "ADD_OVERFLOW");
    }
}








library SignatureUtil
{

    using BytesUtil     for bytes;
    using MathUint      for uint;
    using AddressUtil   for address;

    enum SignatureType {
        ILLEGAL,
        INVALID,
        EIP_712,
        ETH_SIGN,
        WALLET   // deprecated
    }

    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;

    function verifySignatures(
        bytes32          signHash,
        address[] memory signers,
        bytes[]   memory signatures
        )
        internal
        view
        returns (bool)
    {

        require(signers.length == signatures.length, "BAD_SIGNATURE_DATA");
        address lastSigner;
        for (uint i = 0; i < signers.length; i++) {
            require(signers[i] > lastSigner, "INVALID_SIGNERS_ORDER");
            lastSigner = signers[i];
            if (!verifySignature(signHash, signers[i], signatures[i])) {
                return false;
            }
        }
        return true;
    }

    function verifySignature(
        bytes32        signHash,
        address        signer,
        bytes   memory signature
        )
        internal
        view
        returns (bool)
    {

        if (signer == address(0)) {
            return false;
        }

        return signer.isContract()?
            verifyERC1271Signature(signHash, signer, signature):
            verifyEOASignature(signHash, signer, signature);
    }

    function recoverECDSASigner(
        bytes32      signHash,
        bytes memory signature
        )
        internal
        pure
        returns (address)
    {

        if (signature.length != 65) {
            return address(0);
        }

        bytes32 r;
        bytes32 s;
        uint8   v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := and(mload(add(signature, 0x41)), 0xff)
        }
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }
        if (v == 27 || v == 28) {
            return ecrecover(signHash, v, r, s);
        } else {
            return address(0);
        }
    }

    function verifyEOASignature(
        bytes32        signHash,
        address        signer,
        bytes   memory signature
        )
        private
        pure
        returns (bool success)
    {

        if (signer == address(0)) {
            return false;
        }

        uint signatureTypeOffset = signature.length.sub(1);
        SignatureType signatureType = SignatureType(signature.toUint8(signatureTypeOffset));

        assembly {
            mstore(signature, signatureTypeOffset)
        }

        if (signatureType == SignatureType.EIP_712) {
            success = (signer == recoverECDSASigner(signHash, signature));
        } else if (signatureType == SignatureType.ETH_SIGN) {
            bytes32 hash = keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", signHash)
            );
            success = (signer == recoverECDSASigner(hash, signature));
        } else {
            success = false;
        }

        assembly {
            mstore(signature, add(signatureTypeOffset, 1))
        }

        return success;
    }

    function verifyERC1271Signature(
        bytes32 signHash,
        address signer,
        bytes   memory signature
        )
        private
        view
        returns (bool)
    {

        bytes memory callData = abi.encodeWithSelector(
            ERC1271.isValidSignature.selector,
            signHash,
            signature
        );
        (bool success, bytes memory result) = signer.staticcall(callData);
        return (
            success &&
            result.length == 32 &&
            result.toBytes4(0) == ERC1271_MAGICVALUE
        );
    }
}



library EIP712
{

    struct Domain {
        string  name;
        string  version;
        address verifyingContract;
    }

    bytes32 constant internal EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    string constant internal EIP191_HEADER = "\x19\x01";

    function hash(Domain memory domain)
        internal
        pure
        returns (bytes32)
    {

        uint _chainid;
        assembly { _chainid := chainid() }

        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(domain.name)),
                keccak256(bytes(domain.version)),
                _chainid,
                domain.verifyingContract
            )
        );
    }

    function hashPacked(
        bytes32 domainSeperator,
        bytes   memory encodedData
        )
        internal
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encodePacked(EIP191_HEADER, domainSeperator, keccak256(encodedData))
        );
    }
}




contract Ownable
{

    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()
    {
        owner = msg.sender;
    }

    modifier onlyOwner()
    {

        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    function transferOwnership(
        address newOwner
        )
        public
        virtual
        onlyOwner
    {

        require(newOwner != address(0), "ZERO_ADDRESS");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership()
        public
        onlyOwner
    {

        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}






interface Module
{

    function activate() external;


    function deactivate() external;

}




abstract contract ERC20
{
    function totalSupply()
        public
        view
        virtual
        returns (uint);

    function balanceOf(
        address who
        )
        public
        view
        virtual
        returns (uint);

    function allowance(
        address owner,
        address spender
        )
        public
        view
        virtual
        returns (uint);

    function transfer(
        address to,
        uint value
        )
        public
        virtual
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint    value
        )
        public
        virtual
        returns (bool);

    function approve(
        address spender,
        uint    value
        )
        public
        virtual
        returns (bool);
}




interface ModuleRegistry
{

    function registerModule(address module) external;


    function disableModule(address module) external;


    function isModuleEnabled(address module) external view returns (bool);


    function enabledModules() external view returns (address[] memory _modules);


    function numOfEnabledModules() external view returns (uint);


    function isModuleRegistered(address module) external view returns (bool);

}





abstract contract Controller
{
    function moduleRegistry()
        external
        view
        virtual
        returns (ModuleRegistry);

    function walletFactory()
        external
        view
        virtual
        returns (address);
}




interface PriceOracle
{

    function tokenValue(address token, uint amount)
        external
        view
        returns (uint value);

}





contract Claimable is Ownable
{

    address public pendingOwner;

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    function transferOwnership(
        address newOwner
        )
        public
        override
        onlyOwner
    {

        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    function claimOwnership()
        public
        onlyPendingOwner
    {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}





abstract contract DataStore
{
    modifier onlyWalletModule(address wallet)
    {
        requireWalletModule(wallet);
        _;
    }

    function requireWalletModule(address wallet) view internal
    {
        require(Wallet(wallet).hasModule(msg.sender), "UNAUTHORIZED");
    }
}






contract HashStore is DataStore
{

    mapping(address => mapping(bytes32 => bool)) public hashes;

    constructor() {}

    function verifyAndUpdate(address wallet, bytes32 hash)
        external
    {

        require(!hashes[wallet][hash], "HASH_EXIST");
        requireWalletModule(wallet);
        hashes[wallet][hash] = true;
    }
}





library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value < 2**96, "SafeCast: value doesn\'t fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint40(uint256 value) internal pure returns (uint40) {

        require(value < 2**40, "SafeCast: value doesn\'t fit in 40 bits");
        return uint40(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}







contract QuotaStore is DataStore
{

    using MathUint for uint;
    using SafeCast for uint;

    uint128 public constant MAX_QUOTA = uint128(-1);

    struct Quota
    {
        uint128 currentQuota;
        uint128 pendingQuota;
        uint128 spentAmount;
        uint64  spentTimestamp;
        uint64  pendingUntil;
    }

    mapping (address => Quota) public quotas;

    event QuotaScheduled(
        address wallet,
        uint    pendingQuota,
        uint64  pendingUntil
    );

    constructor()
        DataStore()
    {
    }

    function changeQuota(
        address wallet,
        uint    newQuota,
        uint    effectiveTime
        )
        external
        onlyWalletModule(wallet)
    {

        require(newQuota <= MAX_QUOTA, "INVALID_VALUE");
        if (newQuota == MAX_QUOTA) {
            newQuota = 0;
        }

        quotas[wallet].currentQuota = currentQuota(wallet).toUint128();
        quotas[wallet].pendingQuota = newQuota.toUint128();
        quotas[wallet].pendingUntil = effectiveTime.toUint64();

        emit QuotaScheduled(
            wallet,
            newQuota,
            quotas[wallet].pendingUntil
        );
    }

    function checkAndAddToSpent(
        address     wallet,
        address     token,
        uint        amount,
        PriceOracle priceOracle
        )
        external
    {

        Quota memory q = quotas[wallet];
        uint available = _availableQuota(q);
        if (available != MAX_QUOTA) {
            uint value = (token == address(0)) ?
                amount :
                priceOracle.tokenValue(token, amount);
            if (value > 0) {
                require(available >= value, "QUOTA_EXCEEDED");
                requireWalletModule(wallet);
                _addToSpent(wallet, q, value);
            }
        }
    }

    function addToSpent(
        address wallet,
        uint    amount
        )
        external
        onlyWalletModule(wallet)
    {

        _addToSpent(wallet, quotas[wallet], amount);
    }

    function currentQuota(address wallet)
        public
        view
        returns (uint)
    {

        return _currentQuota(quotas[wallet]);
    }

    function pendingQuota(address wallet)
        public
        view
        returns (
            uint __pendingQuota,
            uint __pendingUntil
        )
    {

        return _pendingQuota(quotas[wallet]);
    }

    function spentQuota(address wallet)
        public
        view
        returns (uint)
    {

        return _spentQuota(quotas[wallet]);
    }

    function availableQuota(address wallet)
        public
        view
        returns (uint)
    {

        return _availableQuota(quotas[wallet]);
    }

    function hasEnoughQuota(
        address wallet,
        uint    requiredAmount
        )
        public
        view
        returns (bool)
    {

        return _hasEnoughQuota(quotas[wallet], requiredAmount);
    }


    function _currentQuota(Quota memory q)
        private
        view
        returns (uint)
    {

        return q.pendingUntil <= block.timestamp ? q.pendingQuota : q.currentQuota;
    }

    function _pendingQuota(Quota memory q)
        private
        view
        returns (
            uint __pendingQuota,
            uint __pendingUntil
        )
    {

        if (q.pendingUntil > 0 && q.pendingUntil > block.timestamp) {
            __pendingQuota = q.pendingQuota;
            __pendingUntil = q.pendingUntil;
        }
    }

    function _spentQuota(Quota memory q)
        private
        view
        returns (uint)
    {

        uint timeSinceLastSpent = block.timestamp.sub(q.spentTimestamp);
        if (timeSinceLastSpent < 1 days) {
            return uint(q.spentAmount).sub(timeSinceLastSpent.mul(q.spentAmount) / 1 days);
        } else {
            return 0;
        }
    }

    function _availableQuota(Quota memory q)
        private
        view
        returns (uint)
    {

        uint quota = _currentQuota(q);
        if (quota == 0) {
            return MAX_QUOTA;
        }
        uint spent = _spentQuota(q);
        return quota > spent ? quota - spent : 0;
    }

    function _hasEnoughQuota(
        Quota   memory q,
        uint    requiredAmount
        )
        private
        view
        returns (bool)
    {

        return _availableQuota(q) >= requiredAmount;
    }

    function _addToSpent(
        address wallet,
        Quota   memory q,
        uint    amount
        )
        private
    {

        Quota storage s = quotas[wallet];
        s.spentAmount = _spentQuota(q).add(amount).toUint128();
        s.spentTimestamp = uint64(block.timestamp);
    }
}




library Data
{

    enum GuardianStatus {
        REMOVE,    // Being removed or removed after validUntil timestamp
        ADD        // Being added or added after validSince timestamp.
    }

    struct Guardian
    {
        address addr;
        uint8   status;
        uint64  timestamp; // validSince if status = ADD; validUntil if adding = REMOVE;
    }
}








abstract contract GuardianStore is DataStore
{
    using MathUint      for uint;
    using SafeCast      for uint;

    struct Wallet
    {
        address    inheritor;
        uint32     inheritWaitingPeriod;
        uint64     lastActive; // the latest timestamp the owner is considered to be active
        bool       locked;

        Data.Guardian[]            guardians;
        mapping (address => uint)  guardianIdx;
    }

    mapping (address => Wallet) public wallets;

    constructor() DataStore() {}

    function isGuardian(
        address wallet,
        address addr,
        bool    includePendingAddition
        )
        public
        view
        returns (bool)
    {
        Data.Guardian memory g = _getGuardian(wallet, addr);
        return _isActiveOrPendingAddition(g, includePendingAddition);
    }

    function guardians(
        address wallet,
        bool    includePendingAddition
        )
        public
        view
        returns (Data.Guardian[] memory _guardians)
    {
        Wallet storage w = wallets[wallet];
        _guardians = new Data.Guardian[](w.guardians.length);
        uint index = 0;
        for (uint i = 0; i < w.guardians.length; i++) {
            Data.Guardian memory g = w.guardians[i];
            if (_isActiveOrPendingAddition(g, includePendingAddition)) {
                _guardians[index] = g;
                index++;
            }
        }
        assembly { mstore(_guardians, index) }
    }

    function numGuardians(
        address wallet,
        bool    includePendingAddition
        )
        public
        view
        returns (uint count)
    {
        Wallet storage w = wallets[wallet];
        for (uint i = 0; i < w.guardians.length; i++) {
            Data.Guardian memory g = w.guardians[i];
            if (_isActiveOrPendingAddition(g, includePendingAddition)) {
                count++;
            }
        }
    }

    function removeAllGuardians(address wallet)
        external
    {
        Wallet storage w = wallets[wallet];
        uint size = w.guardians.length;
        if (size == 0) return;

        requireWalletModule(wallet);
        for (uint i = 0; i < w.guardians.length; i++) {
            delete w.guardianIdx[w.guardians[i].addr];
        }
        delete w.guardians;
    }

    function cancelPendingGuardians(address wallet)
        external
    {
        bool cancelled = false;
        Wallet storage w = wallets[wallet];
        for (uint i = 0; i < w.guardians.length; i++) {
            Data.Guardian memory g = w.guardians[i];
            if (_isPendingAddition(g)) {
                w.guardians[i].status = uint8(Data.GuardianStatus.REMOVE);
                w.guardians[i].timestamp = 0;
                cancelled = true;
            }
            if (_isPendingRemoval(g)) {
                w.guardians[i].status = uint8(Data.GuardianStatus.ADD);
                w.guardians[i].timestamp = 0;
                cancelled = true;
            }
        }
        if (cancelled) {
            requireWalletModule(wallet);
        }
        _cleanRemovedGuardians(wallet, true);
    }

    function cleanRemovedGuardians(address wallet)
        external
    {
        _cleanRemovedGuardians(wallet, true);
    }

    function addGuardian(
        address wallet,
        address addr,
        uint    validSince,
        bool    alwaysOverride
        )
        external
        onlyWalletModule(wallet)
        returns (uint)
    {
        require(validSince >= block.timestamp, "INVALID_VALID_SINCE");
        require(addr != address(0), "ZERO_ADDRESS");

        Wallet storage w = wallets[wallet];
        uint pos = w.guardianIdx[addr];

        if(pos == 0) {
            Data.Guardian memory g = Data.Guardian(
                addr,
                uint8(Data.GuardianStatus.ADD),
                validSince.toUint64()
            );
            w.guardians.push(g);
            w.guardianIdx[addr] = w.guardians.length;

            _cleanRemovedGuardians(wallet, false);
            return validSince;
        }

        Data.Guardian memory g = w.guardians[pos - 1];

        if (_isRemoved(g)) {
            w.guardians[pos - 1].status = uint8(Data.GuardianStatus.ADD);
            w.guardians[pos - 1].timestamp = validSince.toUint64();
            return validSince;
        }

        if (_isPendingRemoval(g)) {
            w.guardians[pos - 1].status = uint8(Data.GuardianStatus.ADD);
            w.guardians[pos - 1].timestamp = 0;
            return 0;
        }

        if (_isPendingAddition(g)) {
            if (!alwaysOverride) return g.timestamp;

            w.guardians[pos - 1].timestamp = validSince.toUint64();
            return validSince;
        }

        require(_isAdded(g), "UNEXPECTED_RESULT");
        return 0;
    }

    function removeGuardian(
        address wallet,
        address addr,
        uint    validUntil,
        bool    alwaysOverride
        )
        external
        onlyWalletModule(wallet)
        returns (uint)
    {
        require(validUntil >= block.timestamp, "INVALID_VALID_UNTIL");
        require(addr != address(0), "ZERO_ADDRESS");

        Wallet storage w = wallets[wallet];
        uint pos = w.guardianIdx[addr];
        require(pos > 0, "GUARDIAN_NOT_EXISTS");

        Data.Guardian memory g = w.guardians[pos - 1];

        if (_isAdded(g)) {
            w.guardians[pos - 1].status = uint8(Data.GuardianStatus.REMOVE);
            w.guardians[pos - 1].timestamp = validUntil.toUint64();
            return validUntil;
        }

        if (_isPendingAddition(g)) {
            w.guardians[pos - 1].status = uint8(Data.GuardianStatus.REMOVE);
            w.guardians[pos - 1].timestamp = 0;
            return 0;
        }

        if (_isPendingRemoval(g)) {
            if (!alwaysOverride) return g.timestamp;

            w.guardians[pos - 1].timestamp = validUntil.toUint64();
            return validUntil;
        }

        require(_isRemoved(g), "UNEXPECTED_RESULT");
        return 0;
    }


    function _getGuardian(
        address wallet,
        address addr
        )
        private
        view
        returns (Data.Guardian memory)
    {
        Wallet storage w = wallets[wallet];
        uint pos = w.guardianIdx[addr];
        if (pos > 0) {
            return w.guardians[pos - 1];
        }
    }

    function _isAdded(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
        return guardian.status == uint8(Data.GuardianStatus.ADD) &&
            guardian.timestamp <= block.timestamp;
    }

    function _isPendingAddition(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
        return guardian.status == uint8(Data.GuardianStatus.ADD) &&
            guardian.timestamp > block.timestamp;
    }

    function _isRemoved(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
        return guardian.status == uint8(Data.GuardianStatus.REMOVE) &&
            guardian.timestamp <= block.timestamp;
    }

    function _isPendingRemoval(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
         return guardian.status == uint8(Data.GuardianStatus.REMOVE) &&
            guardian.timestamp > block.timestamp;
    }

    function _isActive(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
        return _isAdded(guardian) || _isPendingRemoval(guardian);
    }

    function _isActiveOrPendingAddition(
        Data.Guardian memory guardian,
        bool includePendingAddition
        )
        private
        view
        returns (bool)
    {
        return _isActive(guardian) || includePendingAddition && _isPendingAddition(guardian);
    }

    function _cleanRemovedGuardians(
        address wallet,
        bool    force
        )
        private
    {
        Wallet storage w = wallets[wallet];
        uint count = w.guardians.length;
        if (!force && count < 10) return;

        for (int i = int(count) - 1; i >= 0; i--) {
            Data.Guardian memory g = w.guardians[uint(i)];
            if (_isRemoved(g)) {
                Data.Guardian memory lastGuardian = w.guardians[w.guardians.length - 1];

                if (g.addr != lastGuardian.addr) {
                    w.guardians[uint(i)] = lastGuardian;
                    w.guardianIdx[lastGuardian.addr] = uint(i) + 1;
                }
                w.guardians.pop();
                delete w.guardianIdx[g.addr];
            }
        }
    }
}




contract SecurityStore is GuardianStore
{

    using MathUint for uint;
    using SafeCast for uint;

    constructor() GuardianStore() {}

    function setLock(
        address wallet,
        bool    locked
        )
        external
        onlyWalletModule(wallet)
    {

        wallets[wallet].locked = locked;
    }

    function touchLastActive(address wallet)
        external
        onlyWalletModule(wallet)
    {

        wallets[wallet].lastActive = uint64(block.timestamp);
    }

    function touchLastActiveWhenRequired(
        address wallet,
        uint    minInternval
        )
        external
    {

        if (wallets[wallet].inheritor != address(0) &&
            block.timestamp > lastActive(wallet) + minInternval) {
            requireWalletModule(wallet);
            wallets[wallet].lastActive = uint64(block.timestamp);
        }
    }

    function setInheritor(
        address wallet,
        address who,
        uint32 _inheritWaitingPeriod
        )
        external
        onlyWalletModule(wallet)
    {

        wallets[wallet].inheritor = who;
        wallets[wallet].inheritWaitingPeriod = _inheritWaitingPeriod;
        wallets[wallet].lastActive = uint64(block.timestamp);
    }

    function isLocked(address wallet)
        public
        view
        returns (bool)
    {

        return wallets[wallet].locked;
    }

    function lastActive(address wallet)
        public
        view
        returns (uint)
    {

        return wallets[wallet].lastActive;
    }

    function inheritor(address wallet)
        public
        view
        returns (
            address _who,
            uint    _effectiveTimestamp
        )
    {

        address _inheritor = wallets[wallet].inheritor;
        if (_inheritor == address(0)) {
             return (address(0), 0);
        }

        uint32 _inheritWaitingPeriod = wallets[wallet].inheritWaitingPeriod;
        if (_inheritWaitingPeriod == 0) {
            return (address(0), 0);
        }

        uint64 _lastActive = wallets[wallet].lastActive;

        if (_lastActive == 0) {
            _lastActive = uint64(block.timestamp);
        }

        _who = _inheritor;
        _effectiveTimestamp = _lastActive + _inheritWaitingPeriod;
    }
}




contract AddressSet
{

    struct Set
    {
        address[] addresses;
        mapping (address => uint) positions;
        uint count;
    }
    mapping (bytes32 => Set) private sets;

    function addAddressToSet(
        bytes32 key,
        address addr,
        bool    maintainList
        ) internal
    {

        Set storage set = sets[key];
        require(set.positions[addr] == 0, "ALREADY_IN_SET");

        if (maintainList) {
            require(set.addresses.length == set.count, "PREVIOUSLY_NOT_MAINTAILED");
            set.addresses.push(addr);
        } else {
            require(set.addresses.length == 0, "MUST_MAINTAIN");
        }

        set.count += 1;
        set.positions[addr] = set.count;
    }

    function removeAddressFromSet(
        bytes32 key,
        address addr
        )
        internal
    {

        Set storage set = sets[key];
        uint pos = set.positions[addr];
        require(pos != 0, "NOT_IN_SET");

        delete set.positions[addr];
        set.count -= 1;

        if (set.addresses.length > 0) {
            address lastAddr = set.addresses[set.count];
            if (lastAddr != addr) {
                set.addresses[pos - 1] = lastAddr;
                set.positions[lastAddr] = pos;
            }
            set.addresses.pop();
        }
    }

    function removeSet(bytes32 key)
        internal
    {

        delete sets[key];
    }

    function isAddressInSet(
        bytes32 key,
        address addr
        )
        internal
        view
        returns (bool)
    {

        return sets[key].positions[addr] != 0;
    }

    function numAddressesInSet(bytes32 key)
        internal
        view
        returns (uint)
    {

        Set storage set = sets[key];
        return set.count;
    }

    function addressesInSet(bytes32 key)
        internal
        view
        returns (address[] memory)
    {

        Set storage set = sets[key];
        require(set.count == set.addresses.length, "NOT_MAINTAINED");
        return sets[key].addresses;
    }
}






contract OwnerManagable is Claimable, AddressSet
{

    bytes32 internal constant MANAGER = keccak256("__MANAGED__");

    event ManagerAdded  (address indexed manager);
    event ManagerRemoved(address indexed manager);

    modifier onlyManager
    {

        require(isManager(msg.sender), "NOT_MANAGER");
        _;
    }

    modifier onlyOwnerOrManager
    {

        require(msg.sender == owner || isManager(msg.sender), "NOT_OWNER_OR_MANAGER");
        _;
    }

    constructor() Claimable() {}

    function managers()
        public
        view
        returns (address[] memory)
    {

        return addressesInSet(MANAGER);
    }

    function numManagers()
        public
        view
        returns (uint)
    {

        return numAddressesInSet(MANAGER);
    }

    function isManager(address addr)
        public
        view
        returns (bool)
    {

        return isAddressInSet(MANAGER, addr);
    }

    function addManager(address manager)
        public
        onlyOwner
    {

        addManagerInternal(manager);
    }

    function removeManager(address manager)
        public
        onlyOwner
    {

        removeAddressFromSet(MANAGER, manager);
        emit ManagerRemoved(manager);
    }

    function addManagerInternal(address manager)
        internal
    {

        addAddressToSet(MANAGER, manager, true);
        emit ManagerAdded(manager);
    }
}







contract WhitelistStore is DataStore, AddressSet, OwnerManagable
{

    bytes32 internal constant DAPPS = keccak256("__DAPPS__");

    mapping(address => mapping(address => uint)) public effectiveTimeMap;

    event Whitelisted(
        address wallet,
        address addr,
        bool    whitelisted,
        uint    effectiveTime
    );

    event DappWhitelisted(
        address addr,
        bool    whitelisted
    );

    constructor() DataStore() {}

    function addToWhitelist(
        address wallet,
        address addr,
        uint    effectiveTime
        )
        external
        onlyWalletModule(wallet)
    {

        addAddressToSet(_walletKey(wallet), addr, true);
        uint effective = effectiveTime >= block.timestamp ? effectiveTime : block.timestamp;
        effectiveTimeMap[wallet][addr] = effective;
        emit Whitelisted(wallet, addr, true, effective);
    }

    function removeFromWhitelist(
        address wallet,
        address addr
        )
        external
        onlyWalletModule(wallet)
    {

        removeAddressFromSet(_walletKey(wallet), addr);
        delete effectiveTimeMap[wallet][addr];
        emit Whitelisted(wallet, addr, false, 0);
    }

    function addDapp(address addr)
        external
        onlyManager
    {

        addAddressToSet(DAPPS, addr, true);
        emit DappWhitelisted(addr, true);
    }

    function removeDapp(address addr)
        external
        onlyManager
    {

        removeAddressFromSet(DAPPS, addr);
        emit DappWhitelisted(addr, false);
    }

    function whitelist(address wallet)
        public
        view
        returns (
            address[] memory addresses,
            uint[]    memory effectiveTimes
        )
    {

        addresses = addressesInSet(_walletKey(wallet));
        effectiveTimes = new uint[](addresses.length);
        for (uint i = 0; i < addresses.length; i++) {
            effectiveTimes[i] = effectiveTimeMap[wallet][addresses[i]];
        }
    }

    function isWhitelisted(
        address wallet,
        address addr
        )
        public
        view
        returns (
            bool isWhitelistedAndEffective,
            uint effectiveTime
        )
    {

        effectiveTime = effectiveTimeMap[wallet][addr];
        isWhitelistedAndEffective = effectiveTime > 0 && effectiveTime <= block.timestamp;
    }

    function whitelistSize(address wallet)
        public
        view
        returns (uint)
    {

        return numAddressesInSet(_walletKey(wallet));
    }

    function dapps()
        public
        view
        returns (
            address[] memory addresses
        )
    {

        return addressesInSet(DAPPS);
    }

    function isDapp(
        address addr
        )
        public
        view
        returns (bool)
    {

        return isAddressInSet(DAPPS, addr);
    }

    function numDapps()
        public
        view
        returns (uint)
    {

        return numAddressesInSet(DAPPS);
    }

    function isDappOrWhitelisted(
        address wallet,
        address addr
        )
        public
        view
        returns (bool res)
    {

        (res,) = isWhitelisted(wallet, addr);
        return res || isAddressInSet(DAPPS, addr);
    }

    function _walletKey(address addr)
        private
        pure
        returns (bytes32)
    {

        return keccak256(abi.encodePacked("__WHITELIST__", addr));
    }

}




library strings {

    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {

        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function toSlice(string memory self) internal pure returns (slice memory) {

        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function len(bytes32 self) internal pure returns (uint) {

        uint ret;
        if (self == 0)
            return 0;
        if (uint256(self) & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (uint256(self) & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (uint256(self) & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (uint256(self) & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (uint256(self) & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {

        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    function copy(slice memory self) internal pure returns (slice memory) {

        return slice(self._len, self._ptr);
    }

    function toString(slice memory self) internal pure returns (string memory) {

        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    function len(slice memory self) internal pure returns (uint l) {

        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    function empty(slice memory self) internal pure returns (bool) {

        return self._len == 0;
    }

    function compare(slice memory self, slice memory other) internal pure returns (int) {

        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                uint256 mask = uint256(-1); // 0xffff...
                if(shortest < 32) {
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    function equals(slice memory self, slice memory other) internal pure returns (bool) {

        return compare(self, other) == 0;
    }

    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {

        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    function nextRune(slice memory self) internal pure returns (slice memory ret) {

        nextRune(self, ret);
    }

    function ord(slice memory self) internal pure returns (uint ret) {

        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    function keccak(slice memory self) internal pure returns (bytes32 ret) {

        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        split(self, needle, token);
    }

    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        rsplit(self, needle, token);
    }

    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    function contains(slice memory self, slice memory needle) internal pure returns (bool) {

        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    function concat(slice memory self, slice memory other) internal pure returns (string memory) {

        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {

        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(uint i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}




interface ENSRegistry {

    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

}


abstract contract ENSResolver {
    function addr(bytes32 _node) public view virtual returns (address);
    function setAddr(bytes32 _node, address _addr) public virtual;
    function name(bytes32 _node) public view virtual returns (string memory);
    function setName(bytes32 _node, string memory _name) public virtual;
}

abstract contract ENSReverseRegistrar {
    function claim(address _owner) public virtual returns (bytes32 _node);
    function claimWithResolver(address _owner, address _resolver) public virtual returns (bytes32);
    function setName(string memory _name) public virtual returns (bytes32);
    function node(address _addr) public view virtual returns (bytes32);
}






contract ENSConsumer {


    using strings for *;

    bytes32 public constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    address immutable ensRegistry;

    constructor(address _ensRegistry) {
        ensRegistry = _ensRegistry;
    }

    function resolveEns(bytes32 _node) public view returns (address) {

        address resolver = getENSRegistry().resolver(_node);
        return ENSResolver(resolver).addr(_node);
    }

    function getENSRegistry() public view returns (ENSRegistry) {

        return ENSRegistry(ensRegistry);
    }

    function getENSReverseRegistrar() public view returns (ENSReverseRegistrar) {

        return ENSReverseRegistrar(getENSRegistry().owner(ADDR_REVERSE_NODE));
    }
}









interface IENSManager {

    function changeRootnodeOwner(address _newOwner) external;


    function isAvailable(bytes32 _subnode) external view returns (bool);


    function resolveName(address _wallet) external view returns (string memory);


    function register(
        address _wallet,
        address _owner,
        string  calldata _label,
        bytes   calldata _approval
    ) external;

}

contract BaseENSManager is IENSManager, OwnerManagable, ENSConsumer {


    using strings for *;
    using BytesUtil     for bytes;
    using MathUint      for uint;

    string public rootName;
    bytes32 public immutable rootNode;
    address public ensResolver;


    event RootnodeOwnerChange(bytes32 indexed _rootnode, address indexed _newOwner);
    event ENSResolverChanged(address addr);
    event Registered(address indexed _wallet, address _owner, string _ens);
    event Unregistered(string _ens);


    constructor(string memory _rootName, bytes32 _rootNode, address _ensRegistry, address _ensResolver)
        ENSConsumer(_ensRegistry)
    {
        rootName = _rootName;
        rootNode = _rootNode;
        ensResolver = _ensResolver;
    }


    function changeRootnodeOwner(address _newOwner) external override onlyOwner {

        getENSRegistry().setOwner(rootNode, _newOwner);
        emit RootnodeOwnerChange(rootNode, _newOwner);
    }

    function changeENSResolver(address _ensResolver) external onlyOwner {

        require(_ensResolver != address(0), "WF: address cannot be null");
        ensResolver = _ensResolver;
        emit ENSResolverChanged(_ensResolver);
    }

    function register(
        address _wallet,
        address _owner,
        string  calldata _label,
        bytes   calldata _approval
        )
        external
        override
        onlyManager
    {

        verifyApproval(_wallet, _owner, _label, _approval);

        ENSRegistry _ensRegistry = getENSRegistry();
        ENSResolver _ensResolver = ENSResolver(ensResolver);
        bytes32 labelNode = keccak256(abi.encodePacked(_label));
        bytes32 node = keccak256(abi.encodePacked(rootNode, labelNode));
        address currentOwner = _ensRegistry.owner(node);
        require(currentOwner == address(0), "AEM: _label is alrealdy owned");

        _ensRegistry.setSubnodeOwner(rootNode, labelNode, address(this));
        _ensRegistry.setResolver(node, address(_ensResolver));
        _ensRegistry.setOwner(node, _wallet);
        _ensResolver.setAddr(node, _wallet);

        strings.slice[] memory parts = new strings.slice[](2);
        parts[0] = _label.toSlice();
        parts[1] = rootName.toSlice();
        string memory name = ".".toSlice().join(parts);
        bytes32 reverseNode = getENSReverseRegistrar().node(_wallet);
        _ensResolver.setName(reverseNode, name);

        emit Registered(_wallet, _owner, name);
    }


    function resolveName(address _wallet) public view override returns (string memory) {

        bytes32 reverseNode = getENSReverseRegistrar().node(_wallet);
        return ENSResolver(ensResolver).name(reverseNode);
    }

    function isAvailable(bytes32 _subnode) public view override returns (bool) {

        bytes32 node = keccak256(abi.encodePacked(rootNode, _subnode));
        address currentOwner = getENSRegistry().owner(node);
        if(currentOwner == address(0)) {
            return true;
        }
        return false;
    }

    function verifyApproval(
        address _wallet,
        address _owner,
        string  calldata _label,
        bytes   calldata _approval
        )
        internal
        view
    {

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                _wallet,
                _owner,
                _label
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                messageHash
            )
        );

        address signer = SignatureUtil.recoverECDSASigner(hash, _approval);
        require(isManager(signer), "UNAUTHORIZED");
    }

}












contract ControllerImpl is Claimable, Controller
{

    HashStore           public immutable hashStore;
    QuotaStore          public immutable quotaStore;
    SecurityStore       public immutable securityStore;
    WhitelistStore      public immutable whitelistStore;
    ModuleRegistry      public immutable override moduleRegistry;
    address             public override  walletFactory;
    address             public immutable feeCollector;
    BaseENSManager      public immutable ensManager;
    PriceOracle         public immutable priceOracle;

    event AddressChanged(
        string   name,
        address  addr
    );

    constructor(
        HashStore         _hashStore,
        QuotaStore        _quotaStore,
        SecurityStore     _securityStore,
        WhitelistStore    _whitelistStore,
        ModuleRegistry    _moduleRegistry,
        address           _feeCollector,
        BaseENSManager    _ensManager,
        PriceOracle       _priceOracle
        )
    {
        hashStore = _hashStore;
        quotaStore = _quotaStore;
        securityStore = _securityStore;
        whitelistStore = _whitelistStore;
        moduleRegistry = _moduleRegistry;

        require(_feeCollector != address(0), "ZERO_ADDRESS");
        feeCollector = _feeCollector;

        ensManager = _ensManager;
        priceOracle = _priceOracle;
    }

    function initWalletFactory(address _walletFactory)
        external
        onlyOwner
    {

        require(walletFactory == address(0), "INITIALIZED_ALREADY");
        require(_walletFactory != address(0), "ZERO_ADDRESS");
        walletFactory = _walletFactory;
        emit AddressChanged("WalletFactory", walletFactory);
    }
}










abstract contract BaseModule is Module
{
    using MathUint      for uint;
    using AddressUtil   for address;

    event Activated   (address wallet);
    event Deactivated (address wallet);

    ModuleRegistry public immutable moduleRegistry;
    SecurityStore  public immutable securityStore;
    WhitelistStore public immutable whitelistStore;
    QuotaStore     public immutable quotaStore;
    HashStore      public immutable hashStore;
    address        public immutable walletFactory;
    PriceOracle    public immutable priceOracle;
    address        public immutable feeCollector;

    function logicalSender()
        internal
        view
        virtual
        returns (address payable)
    {
        return msg.sender;
    }

    modifier onlyWalletOwner(address wallet, address addr)
        virtual
    {
        require(Wallet(wallet).owner() == addr, "NOT_WALLET_OWNER");
        _;
    }

    modifier notWalletOwner(address wallet, address addr)
        virtual
    {
        require(Wallet(wallet).owner() != addr, "IS_WALLET_OWNER");
        _;
    }

    modifier eligibleWalletOwner(address addr)
    {
        require(addr != address(0) && !addr.isContract(), "INVALID_OWNER");
        _;
    }

    constructor(ControllerImpl _controller)
    {
        moduleRegistry = _controller.moduleRegistry();
        securityStore = _controller.securityStore();
        whitelistStore = _controller.whitelistStore();
        quotaStore = _controller.quotaStore();
        hashStore = _controller.hashStore();
        walletFactory = _controller.walletFactory();
        priceOracle = _controller.priceOracle();
        feeCollector = _controller.feeCollector();
    }

    function activate()
        external
        override
        virtual
    {
        address wallet = logicalSender();
        bindMethods(wallet);
        emit Activated(wallet);
    }

    function deactivate()
        external
        override
        virtual
    {
        address wallet = logicalSender();
        unbindMethods(wallet);
        emit Deactivated(wallet);
    }

    function bindableMethods()
        public
        pure
        virtual
        returns (bytes4[] memory methods)
    {
    }


    function bindMethods(address wallet)
        internal
    {
        Wallet w = Wallet(wallet);
        bytes4[] memory methods = bindableMethods();
        for (uint i = 0; i < methods.length; i++) {
            w.bindMethod(methods[i], address(this));
        }
    }

    function unbindMethods(address wallet)
        internal
    {
        Wallet w = Wallet(wallet);
        bytes4[] memory methods = bindableMethods();
        for (uint i = 0; i < methods.length; i++) {
            w.bindMethod(methods[i], address(0));
        }
    }

    function transactCall(
        address wallet,
        address to,
        uint    value,
        bytes   memory data
        )
        internal
        returns (bytes memory)
    {
        return Wallet(wallet).transact(uint8(1), to, value, data);
    }

    function transactTokenTransfer(
        address wallet,
        address token,
        address to,
        uint    amount
        )
        internal
    {
        if (token == address(0)) {
            transactCall(wallet, to, amount, "");
            return;
        }

        bytes memory txData = abi.encodeWithSelector(
            ERC20.transfer.selector,
            to,
            amount
        );
        bytes memory returnData = transactCall(wallet, token, 0, txData);
        bool success = returnData.length == 0 ? true :  abi.decode(returnData, (bool));
        require(success, "ERC20_TRANSFER_FAILED");
    }

    function transactTokenApprove(
        address wallet,
        address token,
        address spender,
        uint    amount
        )
        internal
    {
        require(token != address(0), "INVALID_TOKEN");
        bytes memory txData = abi.encodeWithSelector(
            ERC20.approve.selector,
            spender,
            amount
        );
        bytes memory returnData = transactCall(wallet, token, 0, txData);
        bool success = returnData.length == 0 ? true :  abi.decode(returnData, (bool));
        require(success, "ERC20_APPROVE_FAILED");
    }

    function transactDelegateCall(
        address wallet,
        address to,
        uint    value,
        bytes   calldata data
        )
        internal
        returns (bytes memory)
    {
        return Wallet(wallet).transact(uint8(2), to, value, data);
    }

    function transactStaticCall(
        address wallet,
        address to,
        bytes   calldata data
        )
        internal
        returns (bytes memory)
    {
        return Wallet(wallet).transact(uint8(3), to, 0, data);
    }

    function reimburseGasFee(
        address     wallet,
        address     recipient,
        address     gasToken,
        uint        gasPrice,
        uint        gasAmount
        )
        internal
    {
        uint gasCost = gasAmount.mul(gasPrice);

        quotaStore.checkAndAddToSpent(
            wallet,
            gasToken,
            gasAmount,
            priceOracle
        );

        transactTokenTransfer(wallet, gasToken, recipient, gasCost);
    }
}






abstract contract MetaTxAware
{
    using AddressUtil for address;
    using BytesUtil   for bytes;

    address public immutable metaTxForwarder;

    constructor(address _metaTxForwarder)
    {
        metaTxForwarder = _metaTxForwarder;
    }

    modifier txAwareHashNotAllowed()
    {
        require(txAwareHash() == 0, "INVALID_TX_AWARE_HASH");
        _;
    }

    function msgSender()
        internal
        view
        returns (address payable)
    {
        if (msg.data.length >= 56 && msg.sender == metaTxForwarder) {
            return msg.data.toAddress(msg.data.length - 52).toPayable();
        } else {
            return msg.sender;
        }
    }

    function txAwareHash()
        internal
        view
        returns (bytes32)
    {
        if (msg.data.length >= 56 && msg.sender == metaTxForwarder) {
            return msg.data.toBytes32(msg.data.length - 32);
        } else {
            return 0;
        }
    }
}








abstract contract MetaTxModule is MetaTxAware, BaseModule
{
    using SignatureUtil for bytes32;

    constructor(
        ControllerImpl _controller,
        address        _metaTxForwarder
        )
        MetaTxAware(_metaTxForwarder)
        BaseModule(_controller)
    {
    }

   function logicalSender()
        internal
        view
        virtual
        override
        returns (address payable)
    {
        return msgSender();
    }
}






library GuardianUtils
{

    enum SigRequirement
    {
        MAJORITY_OWNER_NOT_ALLOWED,
        MAJORITY_OWNER_ALLOWED,
        MAJORITY_OWNER_REQUIRED,
        OWNER_OR_ANY_GUARDIAN,
        ANY_GUARDIAN
    }

    function requireMajority(
        SecurityStore   securityStore,
        address         wallet,
        address[]       memory signers,
        SigRequirement  requirement
        )
        internal
        view
        returns (bool)
    {

        if (signers.length == 0) {
            return false;
        }

        Data.Guardian[] memory allGuardians = securityStore.guardians(wallet, false);
        require(allGuardians.length > 0, "NO_GUARDIANS");

        address lastSigner;
        bool walletOwnerSigned = false;
        address owner = Wallet(wallet).owner();
        for (uint i = 0; i < signers.length; i++) {
            require(signers[i] > lastSigner, "INVALID_SIGNERS_ORDER");
            lastSigner = signers[i];

            if (signers[i] == owner) {
                walletOwnerSigned = true;
            } else {
                require(_isWalletGuardian(allGuardians, signers[i]), "SIGNER_NOT_GUARDIAN");
            }
        }

        if (requirement == SigRequirement.OWNER_OR_ANY_GUARDIAN) {
            return signers.length == 1;
        } else if (requirement == SigRequirement.ANY_GUARDIAN) {
            require(!walletOwnerSigned, "WALLET_OWNER_SIGNATURE_NOT_ALLOWED");
            return signers.length == 1;
        }

        if (requirement == SigRequirement.MAJORITY_OWNER_REQUIRED) {
            require(walletOwnerSigned, "WALLET_OWNER_SIGNATURE_REQUIRED");
        } else if (requirement == SigRequirement.MAJORITY_OWNER_NOT_ALLOWED) {
            require(!walletOwnerSigned, "WALLET_OWNER_SIGNATURE_NOT_ALLOWED");
        }

        uint numExtendedSigners = allGuardians.length;
        if (walletOwnerSigned) {
            numExtendedSigners += 1;
            require(signers.length > 1, "NO_GUARDIAN_SIGNED_BESIDES_OWNER");
        }

        return _hasMajority(signers.length, numExtendedSigners);
    }

    function _isWalletGuardian(
        Data.Guardian[] memory allGuardians,
        address signer
        )
        private
        pure
        returns (bool)
    {

        for (uint i = 0; i < allGuardians.length; i++) {
            if (allGuardians[i].addr == signer) {
                return true;
            }
        }
        return false;
    }

    function _hasMajority(
        uint signed,
        uint total
        )
        private
        pure
        returns (bool)
    {

        return total > 0 && signed >= (total >> 1) + 1;
    }
}









library SignedRequest {

    using SignatureUtil for bytes32;

    struct Request {
        address[] signers;
        bytes[]   signatures;
        uint      validUntil;
        address   wallet;
    }

    function verifyRequest(
        HashStore                    hashStore,
        SecurityStore                securityStore,
        bytes32                      domainSeperator,
        bytes32                      txAwareHash,
        GuardianUtils.SigRequirement sigRequirement,
        Request memory               request,
        bytes   memory               encodedRequest
        )
        public
    {

        require(block.timestamp <= request.validUntil, "EXPIRED_SIGNED_REQUEST");

        bytes32 _txAwareHash = EIP712.hashPacked(domainSeperator, encodedRequest);

        require(
            txAwareHash == 0 || txAwareHash == _txAwareHash,
            "TX_INNER_HASH_MISMATCH"
        );

        hashStore.verifyAndUpdate(request.wallet, _txAwareHash);

        require(
            _txAwareHash.verifySignatures(request.signers, request.signatures),
            "INVALID_SIGNATURES"
        );

        require(
            GuardianUtils.requireMajority(
                securityStore,
                request.wallet,
                request.signers,
                sigRequirement
            ),
            "PERMISSION_DENIED"
        );
    }
}







abstract contract SecurityModule is MetaTxModule
{

    uint public constant TOUCH_GRACE_PERIOD = 30 days;

    event WalletLocked(
        address indexed wallet,
        address         by,
        bool            locked
    );

    constructor(
        ControllerImpl _controller,
        address        _metaTxForwarder
        )
        MetaTxModule(_controller, _metaTxForwarder)
    {
    }

    modifier onlyFromWalletOrOwnerWhenUnlocked(address wallet)
    {
        address payable _logicalSender = logicalSender();
        require(
            _logicalSender == wallet ||
            (_logicalSender == Wallet(wallet).owner() && !_isWalletLocked(wallet)),
             "NOT_FROM_WALLET_OR_OWNER_OR_WALLET_LOCKED"
        );
        securityStore.touchLastActiveWhenRequired(wallet, TOUCH_GRACE_PERIOD);
        _;
    }

    modifier onlyWalletGuardian(address wallet, address guardian)
    {
        require(securityStore.isGuardian(wallet, guardian, false), "NOT_GUARDIAN");
        _;
    }

    modifier notWalletGuardian(address wallet, address guardian)
    {
        require(!securityStore.isGuardian(wallet, guardian, false), "IS_GUARDIAN");
        _;
    }


    function _lockWallet(address wallet, address by, bool locked)
        internal
    {
        securityStore.setLock(wallet, locked);
        emit WalletLocked(wallet, by, locked);
    }

    function _isWalletLocked(address wallet)
        internal
        view
        returns (bool)
    {
        return securityStore.isLocked(wallet);
    }

    function _updateQuota(
        QuotaStore qs,
        address    wallet,
        address    token,
        uint       amount
        )
        internal
    {
        if (amount == 0) return;
        if (qs == QuotaStore(0)) return;

        qs.checkAndAddToSpent(
            wallet,
            token,
            amount,
            priceOracle
        );
    }
}










abstract contract ERC1271Module is ERC1271, SecurityModule
{
    using SignatureUtil for bytes;
    using SignatureUtil for bytes32;
    using AddressUtil   for address;

    function bindableMethodsForERC1271()
        internal
        pure
        returns (bytes4[] memory methods)
    {
        methods = new bytes4[](1);
        methods[0] = ERC1271.isValidSignature.selector;
    }

    function isValidSignature(
        bytes32      _signHash,
        bytes memory _signature
        )
        public
        view
        override
        returns (bytes4 magicValue)
    {
        address wallet = msg.sender;
        if (securityStore.isLocked(wallet)) {
            return 0;
        }

        if (_signHash.verifySignature(Wallet(wallet).owner(), _signature)) {
            return ERC1271_MAGICVALUE;
        } else {
            return 0;
        }
    }
}




contract ReentrancyGuard
{

    uint private _guardValue;

    modifier nonReentrant()
    {

        require(_guardValue == 0, "REENTRANCY");
        _guardValue = 1;
        _;
        _guardValue = 0;
    }
}









abstract contract BaseWallet is ReentrancyGuard, Wallet
{
    address internal _owner;

    mapping (address => bool) private modules;

    Controller public controller;

    mapping (bytes4  => address) internal methodToModule;

    event OwnerChanged          (address newOwner);
    event ControllerChanged     (address newController);
    event ModuleAdded           (address module);
    event ModuleRemoved         (address module);
    event MethodBound           (bytes4  method, address module);
    event WalletSetup           (address owner);

    modifier onlyFromModule
    {
        require(modules[msg.sender], "MODULE_UNAUTHORIZED");
        _;
    }

    modifier onlyFromFactory
    {
        require(
            msg.sender == controller.walletFactory(),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier onlyFromFactoryOrModule
    {
        require(
            modules[msg.sender] || msg.sender == controller.walletFactory(),
            "UNAUTHORIZED"
        );
        _;
    }

    function initOwner(
        address _initialOwner
        )
        external
        onlyFromFactory
    {
        require(controller != Controller(0), "NO_CONTROLLER");
        require(_owner == address(0), "INITIALIZED_ALREADY");
        require(_initialOwner != address(0), "ZERO_ADDRESS");

        _owner = _initialOwner;
        emit WalletSetup(_initialOwner);
    }

    function init(
        Controller _controller,
        address[]  calldata _modules
        )
        external
    {
        require(
            _owner == address(0) &&
            controller == Controller(0) &&
            _controller != Controller(0),
            "CONTROLLER_INIT_FAILED"
        );

        controller = _controller;

        ModuleRegistry moduleRegistry = controller.moduleRegistry();
        for (uint i = 0; i < _modules.length; i++) {
            _addModule(_modules[i], moduleRegistry);
        }
    }

    function owner()
        override
        public
        view
        returns (address)
    {
        return _owner;
    }

    function setOwner(address newOwner)
        external
        override
        onlyFromModule
    {
        require(newOwner != address(0), "ZERO_ADDRESS");
        require(newOwner != address(this), "PROHIBITED");
        require(newOwner != _owner, "SAME_ADDRESS");
        _owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function setController(Controller newController)
        external
        onlyFromModule
    {
        require(newController != controller, "SAME_CONTROLLER");
        require(newController != Controller(0), "INVALID_CONTROLLER");
        controller = newController;
        emit ControllerChanged(address(newController));
    }

    function addModule(address _module)
        external
        override
        onlyFromFactoryOrModule
    {
        _addModule(_module, controller.moduleRegistry());
    }

    function removeModule(address _module)
        external
        override
        onlyFromModule
    {
        require(modules[_module], "MODULE_NOT_EXISTS");
        try Module(_module).deactivate() {} catch {}
        delete modules[_module];
        emit ModuleRemoved(_module);
    }

    function hasModule(address _module)
        public
        view
        override
        returns (bool)
    {
        return modules[_module];
    }

    function bindMethod(bytes4 _method, address _module)
        external
        override
        onlyFromModule
    {
        require(_method != bytes4(0), "BAD_METHOD");
        if (_module != address(0)) {
            require(modules[_module], "MODULE_UNAUTHORIZED");
        }

        methodToModule[_method] = _module;
        emit MethodBound(_method, _module);
    }

    function boundMethodModule(bytes4 _method)
        public
        view
        override
        returns (address)
    {
        return methodToModule[_method];
    }

    function transact(
        uint8    mode,
        address  to,
        uint     value,
        bytes    calldata data
        )
        external
        override
        onlyFromFactoryOrModule
        returns (bytes memory returnData)
    {
        bool success;
        (success, returnData) = _call(mode, to, value, data);

        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    receive()
        external
        payable
    {
    }

    fallback()
        external
        payable
    {
        address module = methodToModule[msg.sig];
        require(modules[module], "MODULE_UNAUTHORIZED");

        (bool success, bytes memory returnData) = module.call{value: msg.value}(msg.data);
        assembly {
            switch success
            case 0 { revert(add(returnData, 32), mload(returnData)) }
            default { return(add(returnData, 32), mload(returnData)) }
        }
    }

    function _addModule(address _module, ModuleRegistry moduleRegistry)
        internal
    {
        require(_module != address(0), "NULL_MODULE");
        require(modules[_module] == false, "MODULE_EXISTS");
        require(
            moduleRegistry.isModuleEnabled(_module),
            "INVALID_MODULE"
        );
        modules[_module] = true;
        emit ModuleAdded(_module);
        Module(_module).activate();
    }

    function _call(
        uint8          mode,
        address        target,
        uint           value,
        bytes calldata data
        )
        private
        returns (
            bool success,
            bytes memory returnData
        )
    {
        if (mode == 1) {
            (success, returnData) = target.call{value: value}(data);
        } else if (mode == 2) {
            (success, returnData) = target.delegatecall(data);
        } else if (mode == 3) {
            require(value == 0, "INVALID_VALUE");
            (success, returnData) = target.staticcall(data);
        } else {
            revert("UNSUPPORTED_MODE");
        }
    }
}




library Create2 {

    function deploy(bytes32 salt, bytes memory bytecode) internal returns (address payable) {

        address payable addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "CREATE2_FAILED");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes memory bytecode) internal view returns (address) {

        return computeAddress(salt, bytecode, address(this));
    }

    function computeAddress(bytes32 salt, bytes memory bytecodeHash, address deployer) internal pure returns (address) {

        bytes32 bytecodeHashHash = keccak256(bytecodeHash);
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHashHash)
        );
        return address(bytes20(_data << 96));
    }
}




library CloneFactory {

  function getByteCode(address target) internal pure returns (bytes memory byteCode) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      byteCode := mload(0x40)
      mstore(byteCode, 0x37)

      let clone := add(byteCode, 0x20)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      mstore(0x40, add(byteCode, 0x60))
    }
  }
}
















contract WalletFactory
{

    using AddressUtil for address;
    using SignatureUtil for bytes32;

    event BlankDeployed (address blank,  bytes32 version);
    event BlankConsumed (address blank);
    event WalletCreated (address wallet, string ensLabel, address owner, bool blankUsed);

    string public constant WALLET_CREATION = "WALLET_CREATION";

    bytes32 public constant CREATE_WALLET_TYPEHASH = keccak256(
        "createWallet(address owner,uint256 salt,address blankAddress,string ensLabel,bool ensRegisterReverse,address[] modules)"
    );

    mapping(address => bytes32) blanks;

    bytes32             public immutable DOMAIN_SEPERATOR;
    ControllerImpl      public immutable controller;
    address             public immutable walletImplementation;
    bool                public immutable allowEmptyENS; // MUST be false in production

    BaseENSManager      public immutable ensManager;
    address             public immutable ensResolver;
    ENSReverseRegistrar public immutable ensReverseRegistrar;

    constructor(
        ControllerImpl _controller,
        address        _walletImplementation,
        bool           _allowEmptyENS
        )
    {
        DOMAIN_SEPERATOR = EIP712.hash(
            EIP712.Domain("WalletFactory", "1.2.0", address(this))
        );
        controller = _controller;
        walletImplementation = _walletImplementation;
        allowEmptyENS = _allowEmptyENS;

        BaseENSManager _ensManager = _controller.ensManager();
        ensManager = _ensManager;
        ensResolver = _ensManager.ensResolver();
        ensReverseRegistrar = _ensManager.getENSReverseRegistrar();
    }

    function createBlanks(
        address[] calldata modules,
        uint[]    calldata salts
        )
        external
    {

        for (uint i = 0; i < salts.length; i++) {
            _createBlank(modules, salts[i]);
        }
    }

    function createWallet(
        address            _owner,
        uint               _salt,
        string    calldata _ensLabel,
        bytes     calldata _ensApproval,
        bool               _ensRegisterReverse,
        address[] calldata _modules,
        bytes     calldata _signature
        )
        external
        payable
        returns (address _wallet)
    {

        _validateRequest(
            _owner,
            _salt,
            address(0),
            _ensLabel,
            _ensRegisterReverse,
            _modules,
            _signature
        );

        _wallet = _deploy(_modules, _owner, _salt);

        _initializeWallet(
            _wallet,
            _owner,
            _ensLabel,
            _ensApproval,
            _ensRegisterReverse,
            false
        );
    }

    function createWallet2(
        address            _owner,
        address            _blank,
        string    calldata _ensLabel,
        bytes     calldata _ensApproval,
        bool               _ensRegisterReverse,
        address[] calldata _modules,
        bytes     calldata _signature
        )
        external
        payable
        returns (address _wallet)
    {

        _validateRequest(
            _owner,
            0,
            _blank,
            _ensLabel,
            _ensRegisterReverse,
            _modules,
            _signature
        );

        _wallet = _consumeBlank(_blank, _modules);

        _initializeWallet(
            _wallet,
            _owner,
            _ensLabel,
            _ensApproval,
            _ensRegisterReverse,
            true
        );
    }

    function registerENS(
        address         _wallet,
        address         _owner,
        string calldata _ensLabel,
        bytes  calldata _ensApproval,
        bool            _ensRegisterReverse
        )
        external
    {

        _registerENS(_wallet, _owner, _ensLabel, _ensApproval, _ensRegisterReverse);
    }

    function computeWalletAddress(address owner, uint salt)
        public
        view
        returns (address)
    {

        return _computeAddress(owner, salt);
    }

    function computeBlankAddress(uint salt)
        public
        view
        returns (address)
    {

        return _computeAddress(address(0), salt);
    }

    function getWalletCreationCode()
        public
        view
        returns (bytes memory)
    {

        return CloneFactory.getByteCode(walletImplementation);
    }

    function _consumeBlank(
        address blank,
        address[] calldata modules
        )
        internal
        returns (address)
    {

        bytes32 version = keccak256(abi.encode(modules));
        require(blanks[blank] == version, "INVALID_ADOBE");
        delete blanks[blank];
        emit BlankConsumed(blank);
        return blank;
    }

    function _createBlank(
        address[] calldata modules,
        uint      salt
        )
        internal
        returns (address blank)
    {

        blank = _deploy(modules, address(0), salt);
        bytes32 version = keccak256(abi.encode(modules));
        blanks[blank] = version;

        emit BlankDeployed(blank, version);
    }

    function _deploy(
        address[] calldata modules,
        address            owner,
        uint               salt
        )
        internal
        returns (address payable wallet)
    {

        wallet = Create2.deploy(
            keccak256(abi.encodePacked(WALLET_CREATION, owner, salt)),
            CloneFactory.getByteCode(walletImplementation)
        );

        BaseWallet(wallet).init(controller, modules);
    }

    function _validateRequest(
        address            _owner,
        uint               _salt,
        address            _blankAddress,
        string    memory   _ensLabel,
        bool               _ensRegisterReverse,
        address[] memory   _modules,
        bytes     memory   _signature
        )
        private
        view
    {

        require(_owner != address(0) && !_owner.isContract(), "INVALID_OWNER");
        require(_modules.length > 0, "EMPTY_MODULES");

        bytes memory encodedRequest = abi.encode(
            CREATE_WALLET_TYPEHASH,
            _owner,
            _salt,
            _blankAddress,
            keccak256(bytes(_ensLabel)),
            _ensRegisterReverse,
            keccak256(abi.encode(_modules))
        );

        bytes32 signHash = EIP712.hashPacked(DOMAIN_SEPERATOR, encodedRequest);
        require(signHash.verifySignature(_owner, _signature), "INVALID_SIGNATURE");
    }

    function _initializeWallet(
        address       _wallet,
        address       _owner,
        string memory _ensLabel,
        bytes  memory _ensApproval,
        bool          _ensRegisterReverse,
        bool          _blankUsed
        )
        private
    {

        BaseWallet(_wallet.toPayable()).initOwner(_owner);

        if (bytes(_ensLabel).length > 0) {
            _registerENS(_wallet, _owner, _ensLabel, _ensApproval, _ensRegisterReverse);
        } else {
            require(allowEmptyENS, "EMPTY_ENS_NOT_ALLOWED");
        }

        emit WalletCreated(_wallet, _ensLabel, _owner, _blankUsed);
    }

    function _computeAddress(
        address owner,
        uint    salt
        )
        private
        view
        returns (address)
    {

        return Create2.computeAddress(
            keccak256(abi.encodePacked(WALLET_CREATION, owner, salt)),
            CloneFactory.getByteCode(walletImplementation)
        );
    }

    function _registerENS(
        address       wallet,
        address       owner,
        string memory ensLabel,
        bytes  memory ensApproval,
        bool          ensRegisterReverse
        )
        private
    {

        require(
            bytes(ensLabel).length > 0 &&
            ensApproval.length > 0,
            "INVALID_LABEL_OR_SIGNATURE"
        );

        ensManager.register(wallet, owner, ensLabel, ensApproval);

        if (ensRegisterReverse) {
            bytes memory data = abi.encodeWithSelector(
                ENSReverseRegistrar.claimWithResolver.selector,
                address(0), // the owner of the reverse record
                ensResolver
            );

            Wallet(wallet).transact(
                uint8(1),
                address(ensReverseRegistrar),
                0, // value
                data
            );
        }
    }
}











abstract contract ForwarderModule is SecurityModule
{
    using AddressUtil   for address;
    using BytesUtil     for bytes;
    using MathUint      for uint;
    using SignatureUtil for bytes32;

    bytes32 public immutable FORWARDER_DOMAIN_SEPARATOR;

    uint    public constant MAX_REIMBURSTMENT_OVERHEAD = 63000;

    bytes32 public constant META_TX_TYPEHASH = keccak256(
        "MetaTx(address from,address to,uint256 nonce,bytes32 txAwareHash,address gasToken,uint256 gasPrice,uint256 gasLimit,bytes data)"
    );

    mapping(address => uint) public nonces;

    event MetaTxExecuted(
        address relayer,
        address from,
        uint    nonce,
        bytes32 txAwareHash,
        bool    success,
        uint    gasUsed
    );

    struct MetaTx {
        address from; // the wallet
        address to;
        uint    nonce;
        bytes32 txAwareHash;
        address gasToken;
        uint    gasPrice;
        uint    gasLimit;
    }

    constructor(ControllerImpl _controller)
        SecurityModule(_controller, address(this))
    {
        FORWARDER_DOMAIN_SEPARATOR = EIP712.hash(
            EIP712.Domain("ForwarderModule", "1.2.0", address(this))
        );
    }

    function validateMetaTx(
        address from, // the wallet
        address to,
        uint    nonce,
        bytes32 txAwareHash,
        address gasToken,
        uint    gasPrice,
        uint    gasLimit,
        bytes   memory data,
        bytes   memory signature
        )
        public
        view
    {
        verifyTo(to, from, data);
        require(
            msg.sender != address(this) ||
            data.toBytes4(0) == ForwarderModule.batchCall.selector,
            "INVALID_TARGET"
        );

        require(
            nonce == 0 && txAwareHash != 0 ||
            nonce != 0 && txAwareHash == 0,
            "INVALID_NONCE"
        );

        bytes memory data_ = txAwareHash == 0 ? data : data.slice(0, 4); // function selector

        bytes memory encoded = abi.encode(
            META_TX_TYPEHASH,
            from,
            to,
            nonce,
            txAwareHash,
            gasToken,
            gasPrice,
            gasLimit,
            keccak256(data_)
        );

        bytes32 metaTxHash = EIP712.hashPacked(FORWARDER_DOMAIN_SEPARATOR, encoded);

        require(!securityStore.isLocked(from), "WALLET_LOCKED");
        require(metaTxHash.verifySignature(Wallet(from).owner(), signature), "INVALID_SIGNATURE");
    }

    function executeMetaTx(
        address from, // the wallet
        address to,
        uint    nonce,
        bytes32 txAwareHash,
        address gasToken,
        uint    gasPrice,
        uint    gasLimit,
        bytes   calldata data,
        bytes   calldata signature
        )
        external
        returns (
            bool success
        )
    {
        MetaTx memory metaTx = MetaTx(
            from,
            to,
            nonce,
            txAwareHash,
            gasToken,
            gasPrice,
            gasLimit
        );

        uint gasLeft = gasleft();
        require(gasLeft >= (gasLimit.mul(64) / 63), "OPERATOR_INSUFFICIENT_GAS");

        if (metaTx.nonce != 0) {
            require(isNonceValid(metaTx.from, metaTx.nonce), "INVALID_NONCE");
            nonces[metaTx.from] = metaTx.nonce;
        }

        (success, ) = metaTx.to.call{gas : metaTx.gasLimit, value : 0}(
            abi.encodePacked(data, metaTx.from, metaTx.txAwareHash)
        );

        validateMetaTx(
            metaTx.from,
            metaTx.to,
            metaTx.nonce,
            metaTx.txAwareHash,
            metaTx.gasToken,
            metaTx.gasPrice,
            metaTx.gasLimit,
            data,
            signature
        );

        uint gasUsed = gasLeft - gasleft() +
            (signature.length + data.length + 7 * 32) * 16 + // data input cost
            447 +  // cost of MetaTxExecuted = 375 + 9 * 8
            23000; // transaction cost;

        bool needReimburse = metaTx.gasPrice > 0 && (metaTx.txAwareHash == 0 || success);

        if (needReimburse) {
            gasUsed = gasUsed +
                MAX_REIMBURSTMENT_OVERHEAD + // near-worst case cost
                2300; // 2*SLOAD+1*CALL = 2*800+1*700=2300

            if (metaTx.gasToken == address(0)) {
                gasUsed -= 15000; // diff between an regular ERC20 transfer and an ETH send
            }

            uint gasToReimburse = gasUsed <= metaTx.gasLimit ? gasUsed : metaTx.gasLimit;

            reimburseGasFee(
                metaTx.from,
                feeCollector,
                metaTx.gasToken,
                metaTx.gasPrice,
                gasToReimburse
            );
        }

        emit MetaTxExecuted(
            msg.sender,
            metaTx.from,
            metaTx.nonce,
            metaTx.txAwareHash,
            success,
            gasUsed
        );
    }

    function batchCall(
        address   wallet,
        address[] calldata to,
        bytes[]   calldata data
        )
        external
        txAwareHashNotAllowed()
        onlyFromWalletOrOwnerWhenUnlocked(wallet)
    {
        require(to.length == data.length, "INVALID_DATA");

        for (uint i = 0; i < to.length; i++) {
            require(to[i] != address(this), "INVALID_TARGET");
            verifyTo(to[i], wallet, data[i]);
            (bool success, ) = to[i].call(
                abi.encodePacked(data[i], wallet, bytes32(0))
            );
            require(success, "BATCHED_CALL_FAILED");
        }
    }

    function lastNonce(address wallet)
        public
        view
        returns (uint)
    {
        return nonces[wallet];
    }

    function isNonceValid(address wallet, uint nonce)
        public
        view
        returns (bool)
    {
        return nonce > nonces[wallet] && (nonce >> 128) <= block.number;
    }

    function verifyTo(
        address to,
        address wallet,
        bytes   memory data
        )
        private
        view
    {
        require(
            moduleRegistry.isModuleRegistered(to) ||

            (to == wallet) &&
            data.toBytes4(0) == Wallet.addModule.selector ||

            to == walletFactory,
            "INVALID_DESTINATION_OR_METHOD"
        );
    }
}






contract FinalCoreModule is
    ERC1271Module,
    ForwarderModule
{

    ControllerImpl private immutable controller_;

    constructor(ControllerImpl _controller)
        ForwarderModule(_controller)
    {
        controller_ = _controller;
    }

    function bindableMethods()
        public
        pure
        override
        returns (bytes4[] memory)
    {

        return bindableMethodsForERC1271();
    }
}