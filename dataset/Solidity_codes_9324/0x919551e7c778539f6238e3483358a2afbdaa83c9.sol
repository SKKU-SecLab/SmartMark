
pragma solidity ^0.7.0;


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


pragma experimental ABIEncoderV2;











interface IAgent{}


interface IAgentRegistry
{

    function isAgent(
        address owner,
        address agent
        )
        external
        view
        returns (bool);


    function isAgent(
        address[] calldata owners,
        address            agent
        )
        external
        view
        returns (bool);

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

    address public lrcAddress;
    uint    public totalStake;
    address public blockVerifierAddress;
    uint    public forcedWithdrawalFee;
    uint    public tokenRegistrationFeeLRCBase;
    uint    public tokenRegistrationFeeLRCDelta;
    uint8   public protocolTakerFeeBips;
    uint8   public protocolMakerFeeBips;

    address payable public protocolFeeVault;

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
        AMM_UPDATE
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

        AuxiliaryData[] auxiliaryData;

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

    function SNARK_SCALAR_FIELD() internal pure returns (uint) {

        return 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }
    function MAX_OPEN_FORCED_REQUESTS() internal pure returns (uint16) { return 4096; }

    function MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE() internal pure returns (uint32) { return 15 days; }

    function TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS() internal pure returns (uint32) { return 7 days; }

    function MAX_NUM_ACCOUNTS() internal pure returns (uint) { return 2 ** 32; }

    function MAX_NUM_TOKENS() internal pure returns (uint) { return 2 ** 16; }

    function MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED() internal pure returns (uint32) { return 7 days; }

    function MIN_TIME_IN_SHUTDOWN() internal pure returns (uint32) { return 30 days; }

    function TX_DATA_AVAILABILITY_SIZE() internal pure returns (uint32) { return 68; }

    function MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND() internal pure returns (uint32) { return 15 days; }

    function ACCOUNTID_PROTOCOLFEE() internal pure returns (uint32) { return 0; }


    function TX_DATA_AVAILABILITY_SIZE_PART_1() internal pure returns (uint32) { return 29; }

    function TX_DATA_AVAILABILITY_SIZE_PART_2() internal pure returns (uint32) { return 39; }


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
        uint96   weightAMM;
        uint     storageRoot;
    }

    struct MerkleProof
    {
        ExchangeData.AccountLeaf accountLeaf;
        ExchangeData.BalanceLeaf balanceLeaf;
        uint[48]                 accountMerkleProof;
        uint[24]                 balanceMerkleProof;
    }

    struct BlockContext
    {
        bytes32 DOMAIN_SEPARATOR;
        uint32  timestamp;
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
    }
}









library ExchangeMode
{

    using MathUint  for uint;

    function isInWithdrawalMode(
        ExchangeData.State storage S
        )
        internal // inline call
        view
        returns (bool result)
    {

        result = S.withdrawalModeStartTime > 0;
    }

    function isShutdown(
        ExchangeData.State storage S
        )
        internal // inline call
        view
        returns (bool)
    {

        return S.shutdownModeStartTime > 0;
    }

    function getNumAvailableForcedSlots(
        ExchangeData.State storage S
        )
        internal
        view
        returns (uint)
    {

        return ExchangeData.MAX_OPEN_FORCED_REQUESTS() - S.numPendingForcedTransactions;
    }
}


library ERC20SafeTransfer
{

    function safeTransferAndVerify(
        address token,
        address to,
        uint    value
        )
        internal
    {

        safeTransferWithGasLimitAndVerify(
            token,
            to,
            value,
            gasleft()
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint    value
        )
        internal
        returns (bool)
    {

        return safeTransferWithGasLimit(
            token,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferWithGasLimitAndVerify(
        address token,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
    {

        require(
            safeTransferWithGasLimit(token, to, value, gasLimit),
            "TRANSFER_FAILURE"
        );
    }

    function safeTransferWithGasLimit(
        address token,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
        returns (bool)
    {


        bytes memory callData = abi.encodeWithSelector(
            bytes4(0xa9059cbb),
            to,
            value
        );
        (bool success, ) = token.call{gas: gasLimit}(callData);
        return checkReturnValue(success);
    }

    function safeTransferFromAndVerify(
        address token,
        address from,
        address to,
        uint    value
        )
        internal
    {

        safeTransferFromWithGasLimitAndVerify(
            token,
            from,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint    value
        )
        internal
        returns (bool)
    {

        return safeTransferFromWithGasLimit(
            token,
            from,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferFromWithGasLimitAndVerify(
        address token,
        address from,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
    {

        bool result = safeTransferFromWithGasLimit(
            token,
            from,
            to,
            value,
            gasLimit
        );
        require(result, "TRANSFER_FAILURE");
    }

    function safeTransferFromWithGasLimit(
        address token,
        address from,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
        returns (bool)
    {


        bytes memory callData = abi.encodeWithSelector(
            bytes4(0x23b872dd),
            from,
            to,
            value
        );
        (bool success, ) = token.call{gas: gasLimit}(callData);
        return checkReturnValue(success);
    }

    function checkReturnValue(
        bool success
        )
        internal
        pure
        returns (bool)
    {

        if (success) {
            assembly {
                switch returndatasize()
                case 0 {
                    success := 1
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                default {
                    success := 0
                }
            }
        }
        return success;
    }
}

library ExchangeAdmins
{

    using ERC20SafeTransfer for address;
    using ExchangeMode      for ExchangeData.State;
    using MathUint          for uint;

    event MaxAgeDepositUntilWithdrawableChanged(
        address indexed exchangeAddr,
        uint32          oldValue,
        uint32          newValue
    );

    function setMaxAgeDepositUntilWithdrawable(
        ExchangeData.State storage S,
        uint32 newValue
        )
        public
        returns (uint32 oldValue)
    {

        require(!S.isInWithdrawalMode(), "INVALID_MODE");
        require(
            newValue > 0 &&
            newValue <= ExchangeData.MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND(),
            "INVALID_VALUE"
        );
        oldValue = S.maxAgeDepositUntilWithdrawable;
        S.maxAgeDepositUntilWithdrawable = newValue;

        emit MaxAgeDepositUntilWithdrawableChanged(
            address(this),
            oldValue,
            newValue
        );
    }

    function withdrawExchangeStake(
        ExchangeData.State storage S,
        address recipient
        )
        public
        returns (uint)
    {

        require(S.isShutdown(), "EXCHANGE_NOT_SHUTDOWN");
        require(!S.isInWithdrawalMode(), "CANNOT_BE_IN_WITHDRAWAL_MODE");

        require(block.timestamp >= S.shutdownModeStartTime + ExchangeData.MIN_TIME_IN_SHUTDOWN(), "TOO_EARLY");

        uint amount = S.loopring.getExchangeStake(address(this));
        return S.loopring.withdrawExchangeStake(recipient, amount);
    }
}