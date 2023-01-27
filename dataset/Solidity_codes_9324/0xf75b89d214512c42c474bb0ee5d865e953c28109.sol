
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;



abstract contract ILoopringWalletV2
{
    function initialize(
        address             owner,
        address[] calldata  guardians,
        uint                quota,
        address             inheritor,
        address             feeRecipient,
        address             feeToken,
        uint                feeAmount
        )
        external
        virtual;

    function getCreationTimestamp()
        public
        view
        virtual
        returns (uint64);

    function getOwner()
        public
        view
        virtual
        returns (address);
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



interface IProxy {

    function masterCopy() external view returns (address);

}

contract WalletProxy {


    address internal masterCopy;

    constructor(address _masterCopy)
    {
        require(_masterCopy != address(0), "Invalid master copy address provided");
        masterCopy = _masterCopy;
    }

    fallback()
        payable
        external
    {
        assembly {
            let _masterCopy := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
            if eq(calldataload(0), 0xa619486e00000000000000000000000000000000000000000000000000000000) {
                mstore(0, _masterCopy)
                return(0, 0x20)
            }
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas(), _masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) { revert(0, returndatasize()) }
            return(0, returndatasize())
        }
    }
}






contract WalletDeploymentLib
{

    address public immutable walletImplementation;

    string  public constant WALLET_CREATION = "WALLET_CREATION";

    constructor(
        address _walletImplementation
        )
    {
        walletImplementation = _walletImplementation;
    }

    function getWalletCode()
        public
        view
        returns (bytes memory)
    {

        return hex"608060405234801561001057600080fd5b5060405161016f38038061016f8339818101604052602081101561003357600080fd5b50516001600160a01b03811661007a5760405162461bcd60e51b815260040180806020018281038252602481526020018061014b6024913960400191505060405180910390fd5b600080546001600160a01b039092166001600160a01b031990921691909117905560a2806100a96000396000f3fe6080604052600073ffffffffffffffffffffffffffffffffffffffff8154167fa619486e0000000000000000000000000000000000000000000000000000000082351415604e57808252602082f35b3682833781823684845af490503d82833e806067573d82fd5b503d81f3fea2646970667358221220676404d5a2e50e328cc18fc786619f9629ae43d7ff695286c941717f0a1541e564736f6c63430007060033496e76616c6964206d617374657220636f707920616464726573732070726f76696465640000000000000000000000004b16684de50ebcc60fd54b0a5fd1ccfdc940bb27";
    }

    function computeWalletSalt(
        address owner,
        uint    salt
        )
        public
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encodePacked(
                WALLET_CREATION,
                owner,
                salt
            )
        );
    }

    function _deploy(
        address owner,
        uint    salt
        )
        internal
        returns (address payable wallet)
    {

        wallet = Create2.deploy(
            computeWalletSalt(owner, salt),
            getWalletCode()
        );
    }

    function _computeWalletAddress(
        address owner,
        uint    salt,
        address deployer
        )
        internal
        view
        returns (address)
    {

        return Create2.computeAddress(
            computeWalletSalt(owner, salt),
            getWalletCode(),
            deployer
        );
    }
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
        (success, ) = recipient.call{value: amount, gas: gasLimit}("");
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



library BytesUtil {


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

    function toBytes20(bytes memory _bytes, uint _start) internal  pure returns (bytes20) {

        require(_bytes.length >= (_start + 20));
        bytes20 tempBytes20;

        assembly {
            tempBytes20 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes20;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }


    function toAddressUnsafe(bytes memory _bytes, uint _start) internal  pure returns (address) {

        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8Unsafe(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16Unsafe(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint24Unsafe(bytes memory _bytes, uint _start) internal  pure returns (uint24) {

        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }

    function toUint32Unsafe(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64Unsafe(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96Unsafe(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128Unsafe(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUintUnsafe(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes4Unsafe(bytes memory _bytes, uint _start) internal  pure returns (bytes4) {

        bytes4 tempBytes4;

        assembly {
            tempBytes4 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes4;
    }

    function toBytes20Unsafe(bytes memory _bytes, uint _start) internal  pure returns (bytes20) {

        bytes20 tempBytes20;

        assembly {
            tempBytes20 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes20;
    }

    function toBytes32Unsafe(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

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

    using MathUint for uint;

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

    function add64(
        uint64 a,
        uint64 b
        )
        internal
        pure
        returns (uint64 c)
    {

        c = a + b;
        require(c >= a, "ADD_OVERFLOW");
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



interface IAgent{}


abstract contract IAgentRegistry
{
    function isAgent(
        address owner,
        address agent
        )
        external
        virtual
        view
        returns (bool);


    function isAgent(
        address[] calldata owners,
        address            agent
        )
        external
        virtual
        view
        returns (bool);


    function isUniversalAgent(address agent)
        public
        virtual
        view
        returns (bool);

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





abstract contract IBlockVerifier is Claimable
{

    event CircuitRegistered(
        uint8  indexed blockType,
        uint16         blockSize,
        uint8          blockVersion
    );

    event CircuitDisabled(
        uint8  indexed blockType,
        uint16         blockSize,
        uint8          blockVersion
    );


    function registerCircuit(
        uint8    blockType,
        uint16   blockSize,
        uint8    blockVersion,
        uint[18] calldata vk
        )
        external
        virtual;

    function disableCircuit(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual;

    function verifyProofs(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion,
        uint[] calldata publicInputs,
        uint[] calldata proofs
        )
        external
        virtual
        view
        returns (bool);

    function isCircuitRegistered(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual
        view
        returns (bool);

    function isCircuitEnabled(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual
        view
        returns (bool);
}




interface IDepositContract
{

    function isTokenSupported(address token)
        external
        view
        returns (bool);


    function deposit(
        address from,
        address token,
        uint96  amount,
        bytes   calldata extraData
        )
        external
        payable
        returns (uint96 amountReceived);


    function withdraw(
        address from,
        address to,
        address token,
        uint    amount,
        bytes   calldata extraData
        )
        external
        payable;


    function transfer(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        payable;


    function isETH(address addr)
        external
        view
        returns (bool);

}





abstract contract ILoopringV3 is Claimable
{
    event ExchangeStakeDeposited(address exchangeAddr, uint amount);
    event ExchangeStakeWithdrawn(address exchangeAddr, uint amount);
    event ExchangeStakeBurned(address exchangeAddr, uint amount);
    event SettingsUpdated(uint time);

    mapping (address => uint) internal exchangeStake;

    uint    public totalStake;
    address public blockVerifierAddress;
    uint    public forcedWithdrawalFee;
    uint    public tokenRegistrationFeeLRCBase;
    uint    public tokenRegistrationFeeLRCDelta;
    uint8   public protocolTakerFeeBips;
    uint8   public protocolMakerFeeBips;

    address payable public protocolFeeVault;


    function lrcAddress()
        external
        view
        virtual
        returns (address);

    function updateSettings(
        address payable _protocolFeeVault,   // address(0) not allowed
        address _blockVerifierAddress,       // address(0) not allowed
        uint    _forcedWithdrawalFee
        )
        external
        virtual;

    function updateProtocolFeeSettings(
        uint8 _protocolTakerFeeBips,
        uint8 _protocolMakerFeeBips
        )
        external
        virtual;

    function getExchangeStake(
        address exchangeAddr
        )
        public
        virtual
        view
        returns (uint stakedLRC);

    function burnExchangeStake(
        uint amount
        )
        external
        virtual
        returns (uint burnedLRC);

    function depositExchangeStake(
        address exchangeAddr,
        uint    amountLRC
        )
        external
        virtual
        returns (uint stakedLRC);

    function withdrawExchangeStake(
        address recipient,
        uint    requestedAmount
        )
        external
        virtual
        returns (uint amountLRC);

    function getProtocolFeeValues(
        )
        public
        virtual
        view
        returns (
            uint8 takerFeeBips,
            uint8 makerFeeBips
        );
}








library ExchangeData
{

    enum TransactionType
    {
        NOOP,
        DEPOSIT,
        WITHDRAWAL,
        TRANSFER,
        SPOT_TRADE,
        ACCOUNT_UPDATE,
        AMM_UPDATE,
        SIGNATURE_VERIFICATION,
        NFT_MINT, // L2 NFT mint or L1-to-L2 NFT deposit
        NFT_DATA
    }

    enum NftType
    {
        ERC1155,
        ERC721
    }

    struct Token
    {
        address token;
    }

    struct ProtocolFeeData
    {
        uint32 syncedAt; // only valid before 2105 (85 years to go)
        uint8  takerFeeBips;
        uint8  makerFeeBips;
        uint8  previousTakerFeeBips;
        uint8  previousMakerFeeBips;
    }

    struct AuxiliaryData
    {
        uint  txIndex;
        bool  approved;
        bytes data;
    }

    struct Block
    {
        uint8      blockType;
        uint16     blockSize;
        uint8      blockVersion;
        bytes      data;
        uint256[8] proof;

        bool storeBlockInfoOnchain;

        bytes auxiliaryData;

        bytes offchainData;
    }

    struct BlockInfo
    {
        uint32  timestamp;
        bytes28 blockDataHash;
    }

    struct Deposit
    {
        uint96 amount;
        uint64 timestamp;
    }

    struct ForcedWithdrawal
    {
        address owner;
        uint64  timestamp;
    }

    struct Constants
    {
        uint SNARK_SCALAR_FIELD;
        uint MAX_OPEN_FORCED_REQUESTS;
        uint MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE;
        uint TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS;
        uint MAX_NUM_ACCOUNTS;
        uint MAX_NUM_TOKENS;
        uint MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED;
        uint MIN_TIME_IN_SHUTDOWN;
        uint TX_DATA_AVAILABILITY_SIZE;
        uint MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND;
    }

    uint public constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    uint public constant MAX_OPEN_FORCED_REQUESTS = 4096;
    uint public constant MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE = 15 days;
    uint public constant TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS = 7 days;
    uint public constant MAX_NUM_ACCOUNTS = 2 ** 32;
    uint public constant MAX_NUM_TOKENS = 2 ** 16;
    uint public constant MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED = 7 days;
    uint public constant MIN_TIME_IN_SHUTDOWN = 30 days;
    uint32 public constant MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND = 15 days;
    uint32 public constant ACCOUNTID_PROTOCOLFEE = 0;

    uint public constant TX_DATA_AVAILABILITY_SIZE = 68;
    uint public constant TX_DATA_AVAILABILITY_SIZE_PART_1 = 29;
    uint public constant TX_DATA_AVAILABILITY_SIZE_PART_2 = 39;

    uint public constant NFT_TOKEN_ID_START = 2 ** 15;

    struct AccountLeaf
    {
        uint32   accountID;
        address  owner;
        uint     pubKeyX;
        uint     pubKeyY;
        uint32   nonce;
        uint     feeBipsAMM;
    }

    struct BalanceLeaf
    {
        uint16   tokenID;
        uint96   balance;
        uint     weightAMM;
        uint     storageRoot;
    }

    struct Nft
    {
        address minter;             // Minter address for a L2 mint or
        NftType nftType;
        address token;
        uint256 nftID;
        uint8   creatorFeeBips;
    }

    struct MerkleProof
    {
        ExchangeData.AccountLeaf accountLeaf;
        ExchangeData.BalanceLeaf balanceLeaf;
        ExchangeData.Nft         nft;
        uint[48]                 accountMerkleProof;
        uint[24]                 balanceMerkleProof;
    }

    struct BlockContext
    {
        bytes32 DOMAIN_SEPARATOR;
        uint32  timestamp;
        Block   block;
        uint    txIndex;
    }

    struct State
    {
        uint32  maxAgeDepositUntilWithdrawable;
        bytes32 DOMAIN_SEPARATOR;

        ILoopringV3      loopring;
        IBlockVerifier   blockVerifier;
        IAgentRegistry   agentRegistry;
        IDepositContract depositContract;


        bytes32 merkleRoot;

        mapping(uint => BlockInfo) blocks;
        uint  numBlocks;

        Token[] tokens;

        mapping (address => uint16) tokenToTokenId;

        mapping (uint32 => mapping (uint16 => bool)) withdrawnInWithdrawMode;

        mapping (address => mapping (uint16 => uint)) amountWithdrawable;

        mapping (uint32 => mapping (uint16 => ForcedWithdrawal)) pendingForcedWithdrawals;

        mapping (address => mapping (uint16 => Deposit)) pendingDeposits;

        mapping (address => mapping (bytes32 => bool)) approvedTx;

        mapping (address => mapping (address => mapping (uint16 => mapping (uint => mapping (uint32 => address))))) withdrawalRecipient;


        uint32 numPendingForcedTransactions;

        ProtocolFeeData protocolFeeData;

        uint shutdownModeStartTime;

        uint withdrawalModeStartTime;

        mapping (address => uint) protocolFeeLastWithdrawnTime;

        address loopringAddr;
        uint8   ammFeeBips;
        bool    allowOnchainTransferFrom;

        mapping (address => mapping (NftType => mapping (address => mapping(uint256 => Deposit)))) pendingNFTDeposits;

        mapping (address => mapping (address => mapping (NftType => mapping (address => mapping(uint256 => uint))))) amountWithdrawableNFT;
    }
}






abstract contract IExchangeV3 is Claimable
{

    event ExchangeCloned(
        address exchangeAddress,
        address owner,
        bytes32 genesisMerkleRoot
    );

    event TokenRegistered(
        address token,
        uint16  tokenId
    );

    event Shutdown(
        uint timestamp
    );

    event WithdrawalModeActivated(
        uint timestamp
    );

    event BlockSubmitted(
        uint    indexed blockIdx,
        bytes32         merkleRoot,
        bytes32         publicDataHash
    );

    event DepositRequested(
        address from,
        address to,
        address token,
        uint16  tokenId,
        uint96  amount
    );

    event NFTDepositRequested(
        address from,
        address to,
        uint8   nftType,
        address token,
        uint256 nftID,
        uint96  amount
    );

    event ForcedWithdrawalRequested(
        address owner,
        uint16  tokenID,
        uint32  accountID
    );

    event WithdrawalCompleted(
        uint8   category,
        address from,
        address to,
        address token,
        uint    amount
    );

    event WithdrawalFailed(
        uint8   category,
        address from,
        address to,
        address token,
        uint    amount
    );

    event NftWithdrawalCompleted(
        uint8   category,
        address from,
        address to,
        uint16  tokenID,
        address token,
        uint256 nftID,
        uint    amount
    );

    event NftWithdrawalFailed(
        uint8   category,
        address from,
        address to,
        uint16  tokenID,
        address token,
        uint256 nftID,
        uint    amount
    );

    event ProtocolFeesUpdated(
        uint8 takerFeeBips,
        uint8 makerFeeBips,
        uint8 previousTakerFeeBips,
        uint8 previousMakerFeeBips
    );

    event TransactionApproved(
        address owner,
        bytes32 transactionHash
    );


    function initialize(
        address loopring,
        address owner,
        bytes32 genesisMerkleRoot
        )
        virtual
        external;

    function setAgentRegistry(address agentRegistry)
        external
        virtual;

    function getAgentRegistry()
        external
        virtual
        view
        returns (IAgentRegistry);

    function setDepositContract(address depositContract)
        external
        virtual;

    function refreshBlockVerifier()
        external
        virtual;

    function getDepositContract()
        external
        virtual
        view
        returns (IDepositContract);

    function withdrawExchangeFees(
        address token,
        address feeRecipient
        )
        external
        virtual;

    function getConstants()
        external
        virtual
        pure
        returns(ExchangeData.Constants memory);

    function isInWithdrawalMode()
        external
        virtual
        view
        returns (bool);

    function isShutdown()
        external
        virtual
        view
        returns (bool);

    function registerToken(
        address tokenAddress
        )
        external
        virtual
        returns (uint16 tokenID);

    function getTokenID(
        address tokenAddress
        )
        external
        virtual
        view
        returns (uint16 tokenID);

    function getTokenAddress(
        uint16 tokenID
        )
        external
        virtual
        view
        returns (address tokenAddress);

    function getExchangeStake()
        external
        virtual
        view
        returns (uint);

    function withdrawExchangeStake(
        address recipient
        )
        external
        virtual
        returns (uint amountLRC);

    function burnExchangeStake()
        external
        virtual;


    function getMerkleRoot()
        external
        virtual
        view
        returns (bytes32);

    function getBlockHeight()
        external
        virtual
        view
        returns (uint);

    function getBlockInfo(uint blockIdx)
        external
        virtual
        view
        returns (ExchangeData.BlockInfo memory);

    function submitBlocks(ExchangeData.Block[] calldata blocks)
        external
        virtual;

    function getNumAvailableForcedSlots()
        external
        virtual
        view
        returns (uint);


    function deposit(
        address from,
        address to,
        address tokenAddress,
        uint96  amount,
        bytes   calldata extraData
        )
        external
        virtual
        payable;

    function depositNFT(
        address              from,
        address              to,
        ExchangeData.NftType nftType,
        address              tokenAddress,
        uint256              nftID,
        uint96               amount,
        bytes    calldata    extraData
        )
        external
        virtual;

    function getPendingDepositAmount(
        address owner,
        address tokenAddress
        )
        public
        virtual
        view
        returns (uint96);

    function getPendingNFTDepositAmount(
        address               owner,
        address               tokenAddress,
        ExchangeData.NftType  nftType,
        uint256               nftID
        )
        public
        virtual
        view
        returns (uint96);


    function forceWithdrawByTokenID(
        address owner,
        uint16  tokenID,
        uint32  accountID
        )
        external
        virtual
        payable;

    function forceWithdraw(
        address owner,
        address tokenAddress,
        uint32  accountID
        )
        external
        virtual
        payable;

    function isForcedWithdrawalPending(
        uint32  accountID,
        address token
        )
        external
        virtual
        view
        returns (bool);

    function withdrawProtocolFees(
        address tokenAddress
        )
        external
        virtual
        payable;

    function getProtocolFeeLastWithdrawnTime(
        address tokenAddress
        )
        external
        virtual
        view
        returns (uint);

    function withdrawFromMerkleTree(
        ExchangeData.MerkleProof calldata merkleProof
        )
        external
        virtual;

    function isWithdrawnInWithdrawalMode(
        uint32  accountID,
        address token
        )
        external
        virtual
        view
        returns (bool);

    function withdrawFromDepositRequest(
        address owner,
        address token
        )
        external
        virtual;

    function withdrawFromNFTDepositRequest(
        address              owner,
        address              token,
        ExchangeData.NftType nftType,
        uint256              nftID
        )
        external
        virtual;

    function withdrawFromApprovedWithdrawals(
        address[] calldata owners,
        address[] calldata tokens
        )
        external
        virtual;

    function withdrawFromApprovedWithdrawalsNFT(
        address[]              memory  owners,
        address[]              memory  minters,
        ExchangeData.NftType[] memory  nftTypes,
        address[]              memory  tokens,
        uint256[]              memory  nftIDs
        )
        external
        virtual;

    function getAmountWithdrawable(
        address owner,
        address token
        )
        external
        virtual
        view
        returns (uint);

    function getAmountWithdrawableNFT(
        address              owner,
        address              token,
        ExchangeData.NftType nftType,
        uint256              nftID,
        address              minter
        )
        external
        virtual
        view
        returns (uint);

    function notifyForcedRequestTooOld(
        uint32 accountID,
        uint16 tokenID
        )
        external
        virtual;

    function setWithdrawalRecipient(
        address from,
        address to,
        address token,
        uint96  amount,
        uint32  storageID,
        address newRecipient
        )
        external
        virtual;

    function getWithdrawalRecipient(
        address from,
        address to,
        address token,
        uint96  amount,
        uint32  storageID
        )
        external
        virtual
        view
        returns (address);

    function onchainTransferFrom(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        virtual;

    function approveTransaction(
        address owner,
        bytes32 txHash
        )
        external
        virtual;

    function approveTransactions(
        address[] calldata owners,
        bytes32[] calldata txHashes
        )
        external
        virtual;

    function isTransactionApproved(
        address owner,
        bytes32 txHash
        )
        external
        virtual
        view
        returns (bool);

    function setMaxAgeDepositUntilWithdrawable(
        uint32 newValue
        )
        external
        virtual
        returns (uint32);

    function getMaxAgeDepositUntilWithdrawable()
        external
        virtual
        view
        returns (uint32);

    function shutdown()
        external
        virtual
        returns (bool success);

    function getProtocolFeeValues()
        external
        virtual
        view
        returns (
            uint32 syncedAt,
            uint8 takerFeeBips,
            uint8 makerFeeBips,
            uint8 previousTakerFeeBips,
            uint8 previousMakerFeeBips
        );

    function getDomainSeparator()
        external
        virtual
        view
        returns (bytes32);

    function setAmmFeeBips(uint8 _feeBips)
        external
        virtual;

    function getAmmFeeBips()
        external
        virtual
        view
        returns (uint8);
}



interface IAmmSharedConfig
{

    function maxForcedExitAge() external view returns (uint);

    function maxForcedExitCount() external view returns (uint);

    function forcedExitFee() external view returns (uint);

}







library AmmData
{

    uint public constant POOL_TOKEN_BASE = 100 * (10 ** 8);
    uint public constant POOL_TOKEN_MINTED_SUPPLY = uint96(-1);

    enum PoolTxType
    {
        NOOP,
        JOIN,
        EXIT
    }

    struct PoolConfig
    {
        address   sharedConfig;
        address   exchange;
        string    poolName;
        uint32    accountID;
        address[] tokens;
        uint96[]  weights;
        uint8     feeBips;
        string    tokenSymbol;
    }

    struct PoolJoin
    {
        address   owner;
        uint96[]  joinAmounts;
        uint32[]  joinStorageIDs;
        uint96    mintMinAmount;
        uint96    fee;
        uint32    validUntil;
    }

    struct PoolExit
    {
        address   owner;
        uint96    burnAmount;
        uint32    burnStorageID; // for pool token withdrawal from user to the pool
        uint96[]  exitMinAmounts; // the amount to receive BEFORE paying the fee.
        uint96    fee;
        uint32    validUntil;
    }

    struct PoolTx
    {
        PoolTxType txType;
        bytes      data;
        bytes      signature;
    }

    struct Token
    {
        address addr;
        uint96  weight;
        uint16  tokenID;
    }

    struct Context
    {
        uint txIdx;

        bytes32 domainSeparator;
        uint32  accountID;

        uint16  poolTokenID;
        uint8   feeBips;
        uint    totalSupply;

        Token[]  tokens;
        uint96[] tokenBalancesL2;
    }

    struct State {
        string poolName;
        string symbol;
        uint   _totalSupply;

        mapping(address => uint) balanceOf;
        mapping(address => mapping(address => uint)) allowance;
        mapping(address => uint) nonces;

        IAmmSharedConfig sharedConfig;

        Token[]     tokens;

        bytes32     exchangeDomainSeparator;
        bytes32     domainSeparator;
        IExchangeV3 exchange;
        uint32      accountID;
        uint16      poolTokenID;
        uint8       feeBips;

        address     exchangeOwner;

        uint64      shutdownTimestamp;
        uint16      forcedExitCount;

        mapping (address => PoolExit) forcedExit;
        mapping (bytes32 => bool) approvedTx;
    }
}





abstract contract IBlockReceiver
{
    function beforeBlockSubmission(
        bytes              calldata txsData,
        bytes              calldata callbackData
        )
        external
        virtual;
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
        bytes32 domainSeparator,
        bytes32 dataHash
        )
        internal
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encodePacked(
                EIP191_HEADER,
                domainSeparator,
                dataHash
            )
        );
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






library FloatUtil
{

    using MathUint for uint;
    using SafeCast for uint;

    function decodeFloat(
        uint f,
        uint numBits
        )
        internal
        pure
        returns (uint96 value)
    {

        if (f == 0) {
            return 0;
        }
        uint numBitsMantissa = numBits.sub(5);
        uint exponent = f >> numBitsMantissa;
        require(exponent <= 77, "EXPONENT_TOO_LARGE");
        uint mantissa = f & ((1 << numBitsMantissa) - 1);
        value = mantissa.mul(10 ** exponent).toUint96();
    }

    function decodeFloat16(
        uint16 f
        )
        internal
        pure
        returns (uint96)
    {

        uint value = ((uint(f) & 2047) * (10 ** (uint(f) >> 11)));
        require(value < 2**96, "SafeCast: value doesn\'t fit in 96 bits");
        return uint96(value);
    }

    function decodeFloat24(
        uint24 f
        )
        internal
        pure
        returns (uint96)
    {

        uint value = ((uint(f) & 524287) * (10 ** (uint(f) >> 19)));
        require(value < 2**96, "SafeCast: value doesn\'t fit in 96 bits");
        return uint96(value);
    }
}






library ExchangeSignatures
{

    using SignatureUtil for bytes32;

    function requireAuthorizedTx(
        ExchangeData.State storage S,
        address signer,
        bytes memory signature,
        bytes32 txHash
        )
        internal // inline call
    {

        require(signer != address(0), "INVALID_SIGNER");
        if (signature.length > 0) {
            require(txHash.verifySignature(signer, signature), "INVALID_SIGNATURE");
        } else {
            require(S.approvedTx[signer][txHash], "TX_NOT_APPROVED");
            delete S.approvedTx[signer][txHash];
        }
    }
}









library AccountUpdateTransaction
{

    using BytesUtil            for bytes;
    using FloatUtil            for uint16;
    using ExchangeSignatures   for ExchangeData.State;

    bytes32 constant public ACCOUNTUPDATE_TYPEHASH = keccak256(
        "AccountUpdate(address owner,uint32 accountID,uint16 feeTokenID,uint96 maxFee,uint256 publicKey,uint32 validUntil,uint32 nonce)"
    );

    struct AccountUpdate
    {
        address owner;
        uint32  accountID;
        uint16  feeTokenID;
        uint96  maxFee;
        uint96  fee;
        uint    publicKey;
        uint32  validUntil;
        uint32  nonce;
    }

    struct AccountUpdateAuxiliaryData
    {
        bytes  signature;
        uint96 maxFee;
        uint32 validUntil;
    }

    function process(
        ExchangeData.State        storage S,
        ExchangeData.BlockContext memory  ctx,
        bytes                     memory  data,
        uint                              offset,
        bytes                     memory  auxiliaryData
        )
        internal
    {

        AccountUpdate memory accountUpdate;
        readTx(data, offset, accountUpdate);
        AccountUpdateAuxiliaryData memory auxData = abi.decode(auxiliaryData, (AccountUpdateAuxiliaryData));

        accountUpdate.validUntil = auxData.validUntil;
        accountUpdate.maxFee = auxData.maxFee == 0 ? accountUpdate.fee : auxData.maxFee;
        require(ctx.timestamp < accountUpdate.validUntil, "ACCOUNT_UPDATE_EXPIRED");
        require(accountUpdate.fee <= accountUpdate.maxFee, "ACCOUNT_UPDATE_FEE_TOO_HIGH");

        bytes32 txHash = hashTx(ctx.DOMAIN_SEPARATOR, accountUpdate);

        S.requireAuthorizedTx(accountUpdate.owner, auxData.signature, txHash);
    }

    function readTx(
        bytes memory data,
        uint         offset,
        AccountUpdate memory accountUpdate
        )
        internal
        pure
    {

        uint _offset = offset;

        require(data.toUint8Unsafe(_offset) == uint8(ExchangeData.TransactionType.ACCOUNT_UPDATE), "INVALID_TX_TYPE");
        _offset += 1;

        require(data.toUint8Unsafe(_offset) == 1, "INVALID_AUXILIARYDATA_DATA");
        _offset += 1;

        accountUpdate.owner = data.toAddressUnsafe(_offset);
        _offset += 20;
        accountUpdate.accountID = data.toUint32Unsafe(_offset);
        _offset += 4;
        accountUpdate.feeTokenID = data.toUint16Unsafe(_offset);
        _offset += 2;
        accountUpdate.fee = data.toUint16Unsafe(_offset).decodeFloat16();
        _offset += 2;
        accountUpdate.publicKey = data.toUintUnsafe(_offset);
        _offset += 32;
        accountUpdate.nonce = data.toUint32Unsafe(_offset);
        _offset += 4;
    }

    function hashTx(
        bytes32 DOMAIN_SEPARATOR,
        AccountUpdate memory accountUpdate
        )
        internal
        pure
        returns (bytes32)
    {

        return EIP712.hashPacked(
            DOMAIN_SEPARATOR,
            keccak256(
                abi.encode(
                    ACCOUNTUPDATE_TYPEHASH,
                    accountUpdate.owner,
                    accountUpdate.accountID,
                    accountUpdate.feeTokenID,
                    accountUpdate.maxFee,
                    accountUpdate.publicKey,
                    accountUpdate.validUntil,
                    accountUpdate.nonce
                )
            )
        );
    }
}











contract LoopringWalletAgent is WalletDeploymentLib, IBlockReceiver
{

    using AddressUtil   for address;
    using SignatureUtil for bytes32;

    uint     public constant  MAX_TIME_VALID_AFTER_CREATION = 7 days;

    address     public immutable deployer;
    IExchangeV3 public immutable exchange;
    bytes32     public immutable EXCHANGE_DOMAIN_SEPARATOR;

    struct WalletSignatureData
    {
        bytes    signature;
        uint96   maxFee;
        uint32   validUntil;

        address  walletOwner;
        uint     salt;
    }

    constructor(
        address        _walletImplementation,
        address        _deployer,
        IExchangeV3    _exchange
        )
        WalletDeploymentLib(_walletImplementation)
    {
        deployer = _deployer;
        exchange = _exchange;
        EXCHANGE_DOMAIN_SEPARATOR = _exchange.getDomainSeparator();
    }

    function approveTransactionsFor(
        address[] calldata wallets,
        bytes32[] calldata txHashes,
        bytes[]   calldata signatures
        )
        external
        virtual
    {

        require(txHashes.length == wallets.length, "INVALID_DATA");
        require(signatures.length == wallets.length, "INVALID_DATA");

        for (uint i = 0; i < wallets.length; i++) {
            WalletSignatureData memory data = abi.decode(signatures[i], (WalletSignatureData));
            require(
                _canInitialOwnerAuthorizeTransactions(wallets[i], msg.sender, data.salt) ||
                _isUsableSignatureForWallet(
                    wallets[i],
                    txHashes[i],
                    data
                ),
                "INVALID_SIGNATURE"
            );
        }

        exchange.approveTransactions(wallets, txHashes);
    }

    function beforeBlockSubmission(
        bytes calldata txsData,
        bytes calldata callbackData
        )
        external
        override
        virtual
    {

        _beforeBlockSubmission(txsData, callbackData);
    }

    function isUsableSignatureForWallet(
        address                    wallet,
        bytes32                    hash,
        bytes               memory signature
        )
        public
        view
        returns (bool)
    {

        WalletSignatureData memory data = abi.decode(signature, (WalletSignatureData));
        return _isUsableSignatureForWallet(wallet, hash, data);
    }

    function isValidSignatureForWallet(
        address                    wallet,
        bytes32                    hash,
        bytes               memory signature
        )
        public
        view
        returns (bool)
    {

        WalletSignatureData memory data = abi.decode(signature, (WalletSignatureData));
        return _isValidSignatureForWallet(wallet, hash, data);
    }

    function getSignatureExpiry(
        address                    wallet,
        bytes32                    hash,
        bytes               memory signature
        )
        public
        view
        returns (uint)
    {

        WalletSignatureData memory data = abi.decode(signature, (WalletSignatureData));
        if (!_isValidSignatureForWallet(wallet, hash, data)) {
            return 0;
        } else {
            return getInitialOwnerExpiry(wallet);
        }
    }

    function getInitialOwnerExpiry(
        address walletAddress
        )
        public
        view
        returns (uint)
    {

        if (!walletAddress.isContract()) {
            return type(uint).max;
        }

        ILoopringWalletV2 wallet = ILoopringWalletV2(walletAddress);

        return wallet.getCreationTimestamp() + MAX_TIME_VALID_AFTER_CREATION;
    }


     function _beforeBlockSubmission(
        bytes calldata txsData,
        bytes calldata callbackData
        )
        internal
        view
        returns (AccountUpdateTransaction.AccountUpdate memory accountUpdate)
    {

        WalletSignatureData memory data = abi.decode(callbackData, (WalletSignatureData));

        AccountUpdateTransaction.readTx(txsData, 0, accountUpdate);

        accountUpdate.validUntil = data.validUntil;
        accountUpdate.maxFee = data.maxFee == 0 ? accountUpdate.fee : data.maxFee;
        require(block.timestamp < accountUpdate.validUntil, "ACCOUNT_UPDATE_EXPIRED");
        require(accountUpdate.fee <= accountUpdate.maxFee, "ACCOUNT_UPDATE_FEE_TOO_HIGH");

        bytes32 txHash = AccountUpdateTransaction.hashTx(EXCHANGE_DOMAIN_SEPARATOR, accountUpdate);

        require(
            _isUsableSignatureForWallet(
                accountUpdate.owner,
                txHash,
                data
            ),
            "INVALID_SIGNATURE"
        );

        require(txsData.length == ExchangeData.TX_DATA_AVAILABILITY_SIZE, "INVALID_NUM_TXS");
    }

    function _isUsableSignatureForWallet(
        address                    wallet,
        bytes32                    hash,
        WalletSignatureData memory data
        )
        internal
        view
        returns (bool)
    {

        return _isValidSignatureForWallet(wallet, hash, data) &&
               _isInitialOwnerUsable(wallet);
    }

    function _isValidSignatureForWallet(
        address                    wallet,
        bytes32                    hash,
        WalletSignatureData memory data
        )
        internal
        view
        returns (bool)
    {

        return _isInitialOwner(wallet, data.walletOwner, data.salt) &&
               hash.verifySignature(data.walletOwner, data.signature);
    }

    function _canInitialOwnerAuthorizeTransactions(
        address wallet,
        address walletOwner,
        uint    salt
        )
        internal
        view
        returns (bool)
    {

        return _isInitialOwner(wallet, walletOwner, salt) &&
               _isInitialOwnerUsable(wallet);
    }

    function _isInitialOwnerUsable(
        address wallet
        )
        internal
        view
        virtual
        returns (bool)
    {

        return block.timestamp <= getInitialOwnerExpiry(wallet);
    }

    function _isInitialOwner(
        address wallet,
        address walletOwner,
        uint    salt
        )
        internal
        view
        returns (bool)
    {

        return _computeWalletAddress(walletOwner, salt, deployer) == wallet;
    }
}





contract DestroyableWalletAgent is LoopringWalletAgent
{

    struct WalletData
    {
        uint32 accountID;
        bool destroyed;
    }
    mapping(address => WalletData) public walletData;

    constructor(
        address        _walletImplementation,
        address        _deployer,
        IExchangeV3 exchange
        )
        LoopringWalletAgent(_walletImplementation, _deployer, exchange)
    {}

    function beforeBlockSubmission(
        bytes calldata txsData,
        bytes calldata callbackData
        )
        external
        override
    {

        AccountUpdateTransaction.AccountUpdate memory accountUpdate;
        accountUpdate = LoopringWalletAgent._beforeBlockSubmission(txsData, callbackData);

        WalletData storage wallet = walletData[accountUpdate.owner];
        if (wallet.accountID == 0) {
            wallet.accountID = accountUpdate.accountID;
        } else {
            require(
                wallet.accountID == accountUpdate.accountID,
                "ACCOUNT_ALREADY_EXISTS_FOR_WALLET"
            );
        }
        if (accountUpdate.publicKey == 0) {
            wallet.destroyed = true;
        }
    }

    function computeWalletAddress(
        address owner,
        uint    salt
        )
        public
        view
        returns (address)
    {

        return _computeWalletAddress(
            owner,
            salt,
            deployer
        );
    }

    function isDestroyed(
        address wallet
        )
        public
        view
        returns (bool)
    {

        return walletData[wallet].destroyed;
    }

    function approveTransactionsFor(
        address[] calldata /*wallets*/,
        bytes32[] calldata /*txHashes*/,
        bytes[]   calldata /*signatures*/
        )
        external
        override
        pure
    {

        revert("UNSUPPORTED");
    }


    function _isInitialOwnerUsable(
        address wallet
        )
        internal
        view
        override
        returns (bool)
    {

        return LoopringWalletAgent._isInitialOwnerUsable(wallet) &&
               !isDestroyed(wallet);
    }
}