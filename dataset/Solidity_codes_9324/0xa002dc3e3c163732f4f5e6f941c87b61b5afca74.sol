
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


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
}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IAddressRegistry {


    function initialize(
        address lock_manager_,
        address liquidity_,
        address revest_token_,
        address token_vault_,
        address revest_,
        address fnft_,
        address metadata_,
        address admin_,
        address rewards_
    ) external;


    function getAdmin() external view returns (address);


    function setAdmin(address admin) external;


    function getLockManager() external view returns (address);


    function setLockManager(address manager) external;


    function getTokenVault() external view returns (address);


    function setTokenVault(address vault) external;


    function getRevestFNFT() external view returns (address);


    function setRevestFNFT(address fnft) external;


    function getMetadataHandler() external view returns (address);


    function setMetadataHandler(address metadata) external;


    function getRevest() external view returns (address);


    function setRevest(address revest) external;


    function getDEX(uint index) external view returns (address);


    function setDex(address dex) external;


    function getRevestToken() external view returns (address);


    function setRevestToken(address token) external;


    function getRewardsHandler() external view returns(address);


    function setRewardsHandler(address esc) external;


    function getAddress(bytes32 id) external view returns (address);


    function getLPs() external view returns (address);


    function setLPs(address liquidToken) external;


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IRevest {

    event FNFTTimeLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        uint endTime,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTValueLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        address compareTo,
        address oracleDispatch,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTAddressLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        address trigger,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTWithdrawn(
        address indexed from,
        uint indexed fnftId,
        uint indexed quantity
    );

    event FNFTSplit(
        address indexed from,
        uint[] indexed newFNFTId,
        uint[] indexed proportions,
        uint quantity
    );

    event FNFTUnlocked(
        address indexed from,
        uint indexed fnftId
    );

    event FNFTMaturityExtended(
        address indexed from,
        uint indexed fnftId,
        uint indexed newExtendedTime
    );

    event FNFTAddionalDeposited(
        address indexed from,
        uint indexed newFNFTId,
        uint indexed quantity,
        uint amount
    );

    struct FNFTConfig {
        address asset; // The token being stored
        address pipeToContract; // Indicates if FNFT will pipe to another contract
        uint depositAmount; // How many tokens
        uint depositMul; // Deposit multiplier
        uint split; // Number of splits remaining
        uint depositStopTime; //
        bool maturityExtension; // Maturity extensions remaining
        bool isMulti; //
        bool nontransferrable; // False by default (transferrable) //
    }

    struct TokenTracker {
        uint lastBalance;
        uint lastMul;
    }

    enum LockType {
        DoesNotExist,
        TimeLock,
        ValueLock,
        AddressLock
    }

    struct LockParam {
        address addressLock;
        uint timeLockExpiry;
        LockType lockType;
        ValueLock valueLock;
    }

    struct Lock {
        address addressLock;
        LockType lockType;
        ValueLock valueLock;
        uint timeLockExpiry;
        uint creationTime;
        bool unlocked;
    }

    struct ValueLock {
        address asset;
        address compareTo;
        address oracle;
        uint unlockValue;
        bool unlockRisingEdge;
    }

    function mintTimeLock(
        uint endTime,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function mintValueLock(
        address primaryAsset,
        address compareTo,
        uint unlockValue,
        bool unlockRisingEdge,
        address oracleDispatch,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function mintAddressLock(
        address trigger,
        bytes memory arguments,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function withdrawFNFT(uint tokenUID, uint quantity) external;


    function unlockFNFT(uint tokenUID) external;


    function splitFNFT(
        uint fnftId,
        uint[] memory proportions,
        uint quantity
    ) external returns (uint[] memory newFNFTIds);


    function depositAdditionalToFNFT(
        uint fnftId,
        uint amount,
        uint quantity
    ) external returns (uint);


    function extendFNFTMaturity(
        uint fnftId,
        uint endTime
    ) external returns (uint);


    function setFlatWeiFee(uint wethFee) external;


    function setERC20Fee(uint erc20) external;


    function getFlatWeiFee() external view returns (uint);


    function getERC20Fee() external view returns (uint);



}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface ITokenVault {


    function createFNFT(
        uint fnftId,
        IRevest.FNFTConfig memory fnftConfig,
        uint quantity,
        address from
    ) external;


    function withdrawToken(
        uint fnftId,
        uint quantity,
        address user
    ) external;


    function depositToken(
        uint fnftId,
        uint amount,
        uint quantity
    ) external;


    function cloneFNFTConfig(IRevest.FNFTConfig memory old) external returns (IRevest.FNFTConfig memory);


    function mapFNFTToToken(
        uint fnftId,
        IRevest.FNFTConfig memory fnftConfig
    ) external;


    function handleMultipleDeposits(
        uint fnftId,
        uint newFNFTId,
        uint amount
    ) external;


    function splitFNFT(
        uint fnftId,
        uint[] memory newFNFTIds,
        uint[] memory proportions,
        uint quantity
    ) external;


    function getFNFT(uint fnftId) external view returns (IRevest.FNFTConfig memory);

    function getFNFTCurrentValue(uint fnftId) external view returns (uint);

    function getNontransferable(uint fnftId) external view returns (bool);

    function getSplitsRemaining(uint fnftId) external view returns (uint);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface ILockManager {


    function createLock(uint fnftId, IRevest.LockParam memory lock) external returns (uint);


    function getLock(uint lockId) external view returns (IRevest.Lock memory);


    function fnftIdToLockId(uint fnftId) external view returns (uint);


    function fnftIdToLock(uint fnftId) external view returns (IRevest.Lock memory);


    function pointFNFTToLock(uint fnftId, uint lockId) external;


    function lockTypes(uint tokenId) external view returns (IRevest.LockType);


    function unlockFNFT(uint fnftId, address sender) external returns (bool);


    function getLockMaturity(uint fnftId) external view returns (bool);

}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;


interface IRegistryProvider {

    function setAddressRegistry(address revest) external;


    function getAddressRegistry() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;



interface IOutputReceiver is IRegistryProvider, IERC165 {


    function receiveRevestOutput(
        uint fnftId,
        address asset,
        address payable owner,
        uint quantity
    ) external;


    function getCustomMetadata(uint fnftId) external view returns (string memory);


    function getValue(uint fnftId) external view returns (uint);


    function getAsset(uint fnftId) external view returns (address);


    function getOutputDisplayValues(uint fnftId) external view returns (bytes memory);


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;



interface IOutputReceiverV2 is IOutputReceiver {


    function receiveSecondaryCallback(
        uint fnftId,
        address payable owner,
        uint quantity,
        IRevest.FNFTConfig memory config,
        bytes memory args
    ) external payable;


    function triggerOutputReceiverUpdate(
        uint fnftId,
        bytes memory args
    ) external;


    function handleFNFTRemaps(uint fnftId, uint[] memory newFNFTIds, address caller, bool cleanup) external;


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;



interface IOutputReceiverV3 is IOutputReceiverV2 {


    event DepositERC20OutputReceiver(address indexed mintTo, address indexed token, uint amountTokens, uint indexed fnftId, bytes extraData);

    event DepositERC721OutputReceiver(address indexed mintTo, address indexed token, uint[] tokenIds, uint indexed fnftId, bytes extraData);

    event DepositERC1155OutputReceiver(address indexed mintTo, address indexed token, uint tokenId, uint amountTokens, uint indexed fnftId, bytes extraData);

    event WithdrawERC20OutputReceiver(address indexed caller, address indexed token, uint amountTokens, uint indexed fnftId, bytes extraData);

    event WithdrawERC721OutputReceiver(address indexed caller, address indexed token, uint[] tokenIds, uint indexed fnftId, bytes extraData);

    event WithdrawERC1155OutputReceiver(address indexed caller, address indexed token, uint tokenId, uint amountTokens, uint indexed fnftId, bytes extraData);

    function handleTimelockExtensions(uint fnftId, uint expiration, address caller) external;


    function handleAdditionalDeposit(uint fnftId, uint amountToDeposit, uint quantity, address caller) external;


    function handleSplitOperation(uint fnftId, uint[] memory proportions, uint quantity, address caller) external;


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IRewardsHandler {


    struct UserBalance {
        uint allocPoint; // Allocation points
        uint lastMul;
    }

    function receiveFee(address token, uint amount) external;


    function updateLPShares(uint fnftId, uint newShares) external;


    function updateBasicShares(uint fnftId, uint newShares) external;


    function getAllocPoint(uint fnftId, address token, bool isBasic) external view returns (uint);


    function claimRewards(uint fnftId, address caller) external returns (uint);


    function setStakingContract(address stake) external;


    function getRewards(uint fnftId, address token) external view returns (uint);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface IFNFTHandler  {

    function mint(address account, uint id, uint amount, bytes memory data) external;


    function mintBatchRec(address[] memory recipients, uint[] memory quantities, uint id, uint newSupply, bytes memory data) external;


    function mintBatch(address to, uint[] memory ids, uint[] memory amounts, bytes memory data) external;


    function setURI(string memory newuri) external;


    function burn(address account, uint id, uint amount) external;


    function burnBatch(address account, uint[] memory ids, uint[] memory amounts) external;


    function getBalance(address tokenHolder, uint id) external view returns (uint);


    function getSupply(uint fnftId) external view returns (uint);


    function getNextId() external view returns (uint);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface IAddressLock is IRegistryProvider, IERC165{


    function createLock(uint fnftId, uint lockId, bytes memory arguments) external;


    function updateLock(uint fnftId, uint lockId, bytes memory arguments) external;


    function isUnlockable(uint fnftId, uint lockId) external view returns (bool);


    function getDisplayValues(uint fnftId, uint lockId) external view returns (bytes memory);


    function getMetadata() external view returns (string memory);


    function needsUpdate() external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;


interface IOldStaking {

    function config(uint fnftId) external view returns (uint allocPoints, uint timePeriod);

    function manualMapConfig(uint[] memory fnftIds, uint[] memory timePeriod) external;

    function customMetadataUrl() external view returns (string memory);

}

contract Staking is Ownable, IOutputReceiverV3, ERC165, IAddressLock {

    using SafeERC20 for IERC20;

    address private revestAddress;
    address public lpAddress;
    address public rewardsHandlerAddress;
    address public addressRegistry;

    address public oldStakingContract;
    uint public previousStakingIDCutoff;

    bool public additionalEnabled;

    uint private constant ONE_DAY = 86400;

    uint private constant WINDOW_ONE = ONE_DAY;
    uint private constant WINDOW_THREE = ONE_DAY*5;
    uint private constant WINDOW_SIX = ONE_DAY*9;
    uint private constant WINDOW_TWELVE = ONE_DAY*14;
    uint private constant MAX_INT = 2**256 - 1;

    mapping (address => mapping (address => bool)) private approvedContracts;

    address internal immutable WETH;

    uint[4] internal interestRates = [4, 13, 27, 56];
    string public customMetadataUrl = "https://revest.mypinata.cloud/ipfs/QmZi1XRc5q7ngdVhCxqcjuo9F16CfhUQAWfhzN1E9BroDr";
    string public addressMetadataUrl = "https://revest.mypinata.cloud/ipfs/QmY3KUBToJBthPLvN1Knd7Y51Zxx7FenFhXYV8tPEMVAP3";

    event StakedRevest(uint indexed timePeriod, bool indexed isBasic, uint indexed amount, uint fnftId);

    struct StakingData {
        uint timePeriod;
        uint dateLockedFrom;
    }

    mapping(uint => StakingData) public stakingConfigs;

    constructor(
        address revestAddress_,
        address lpAddress_,
        address rewardsHandlerAddress_,
        address addressRegistry_,
        address wrappedEth_
    ) {
        revestAddress = revestAddress_;
        lpAddress = lpAddress_;
        addressRegistry = addressRegistry_;
        rewardsHandlerAddress = rewardsHandlerAddress_;
        WETH = wrappedEth_;
        previousStakingIDCutoff = IFNFTHandler(IAddressRegistry(addressRegistry).getRevestFNFT()).getNextId() - 1;


        address revest = address(getRevest());
        IERC20(lpAddress).approve(revest, MAX_INT);
        IERC20(revestAddress).approve(revest, MAX_INT);
        approvedContracts[revest][lpAddress] = true;
        approvedContracts[revest][revestAddress] = true;
    }

    function supportsInterface(bytes4 interfaceId) public view override (ERC165, IERC165) returns (bool) {

        return (
            interfaceId == type(IOutputReceiver).interfaceId
            || interfaceId == type(IAddressLock).interfaceId
            || interfaceId == type(IOutputReceiverV2).interfaceId
            || interfaceId == type(IOutputReceiverV3).interfaceId
            || super.supportsInterface(interfaceId)
        );
    }

    function stakeBasicTokens(uint amount, uint monthsMaturity) public returns (uint) {

        return _stake(revestAddress, amount, monthsMaturity);
    }

    function stakeLPTokens(uint amount, uint monthsMaturity) public returns (uint) {

        return _stake(lpAddress, amount, monthsMaturity);
    }

    function claimRewards(uint fnftId) external {

        require(IFNFTHandler(getRegistry().getRevestFNFT()).getBalance(_msgSender(), fnftId) == 1, 'E061');
        IRewardsHandler(rewardsHandlerAddress).claimRewards(fnftId, _msgSender());
    }


    function updateLock(uint fnftId, uint, bytes memory) external override {

        require(IFNFTHandler(getRegistry().getRevestFNFT()).getBalance(_msgSender(), fnftId) == 1, 'E061');
        IRewardsHandler(rewardsHandlerAddress).claimRewards(fnftId, _msgSender());
    }

    function createLock(uint, uint, bytes memory) external pure override {

        return;
    }


    function receiveRevestOutput(
        uint fnftId,
        address asset,
        address payable owner,
        uint quantity
    ) external override {

        address vault = getRegistry().getTokenVault();
        require(_msgSender() == vault, "E016");
        require(quantity == 1, 'ONLY SINGULAR');
        require(fnftId <= previousStakingIDCutoff || stakingConfigs[fnftId].timePeriod > 0, 'Nonexistent!');

        uint totalQuantity = quantity * ITokenVault(vault).getFNFT(fnftId).depositAmount;
        IRewardsHandler(rewardsHandlerAddress).claimRewards(fnftId, owner);
        if (asset == revestAddress) {
            IRewardsHandler(rewardsHandlerAddress).updateBasicShares(fnftId, 0);
        } else if (asset == lpAddress) {
            IRewardsHandler(rewardsHandlerAddress).updateLPShares(fnftId, 0);
        } else {
            require(false, "E072");
        }
        IERC20(asset).safeTransfer(owner, totalQuantity);
        emit WithdrawERC20OutputReceiver(_msgSender(), asset, totalQuantity, fnftId, '');
    }

    function handleTimelockExtensions(uint fnftId, uint expiration, address caller) external override {}


    function handleAdditionalDeposit(uint fnftId, uint amountToDeposit, uint quantity, address caller) external override {

        address vault = getRegistry().getTokenVault();
        require(_msgSender() == vault, "E016");
        require(quantity == 1);
        require(additionalEnabled, 'Not allowed!');
        _depositAdditionalToStake(fnftId, amountToDeposit, caller);
    }

    function handleSplitOperation(uint fnftId, uint[] memory proportions, uint quantity, address caller) external override {}


    function receiveSecondaryCallback(
        uint fnftId,
        address payable owner,
        uint quantity,
        IRevest.FNFTConfig memory config,
        bytes memory args
    ) external payable override {}


    function triggerOutputReceiverUpdate(
        uint fnftId,
        bytes memory args
    ) external override {}


    function handleFNFTRemaps(uint, uint[] memory, address, bool) external pure override {

        revert();
    }


    function _stake(address stakeToken, uint amount, uint monthsMaturity) private returns (uint){

        require (stakeToken == lpAddress || stakeToken == revestAddress, "Not valid stake token");
        require(monthsMaturity == 1 || monthsMaturity == 3 || monthsMaturity == 6 || monthsMaturity == 12, 'E055');
        IERC20(stakeToken).safeTransferFrom(msg.sender, address(this), amount);

        IRevest.FNFTConfig memory fnftConfig;
        fnftConfig.asset = stakeToken;
        fnftConfig.depositAmount = amount;
        fnftConfig.isMulti = true;

        fnftConfig.pipeToContract = address(this);

        address[] memory recipients = new address[](1);
        recipients[0] = _msgSender();

        uint[] memory quantities = new uint[](1);
        quantities[0] = 1;

        address revest = getRegistry().getRevest();
        if(!approvedContracts[revest][stakeToken]){
            IERC20(stakeToken).approve(revest, MAX_INT);
            approvedContracts[revest][stakeToken] = true;
        }
        uint fnftId = IRevest(revest).mintAddressLock(address(this), '', recipients, quantities, fnftConfig);

        uint interestRate = getInterestRate(monthsMaturity);
        uint allocPoint = amount * interestRate;

        StakingData memory cfg = StakingData(monthsMaturity, block.timestamp);
        stakingConfigs[fnftId] = cfg;

        IRewardsHandler(rewardsHandlerAddress).updateLPShares(fnftId, allocPoint);
        emit StakedRevest(monthsMaturity, false, amount, fnftId);
        emit DepositERC20OutputReceiver(_msgSender(), stakeToken, amount, fnftId, '');
        return fnftId;
    }

    function _depositAdditionalToStake(uint fnftId, uint amount, address caller) private {

        require(IFNFTHandler(getRegistry().getRevestFNFT()).getBalance(caller, fnftId) == 1, 'E061');
        require(fnftId > previousStakingIDCutoff, 'E080');
        uint time = stakingConfigs[fnftId].timePeriod;
        require(time > 0, 'E078');
        address asset = ITokenVault(getRegistry().getTokenVault()).getFNFT(fnftId).asset;
        require(asset == revestAddress || asset == lpAddress, 'E079');

        IRewardsHandler(rewardsHandlerAddress).claimRewards(fnftId, _msgSender());

        stakingConfigs[fnftId].dateLockedFrom = block.timestamp;
        uint oldAllocPoints = IRewardsHandler(rewardsHandlerAddress).getAllocPoint(fnftId, revestAddress, asset == revestAddress);
        uint allocPoints = amount * getInterestRate(time) + oldAllocPoints;
        if(asset == revestAddress) {
            IRewardsHandler(rewardsHandlerAddress).updateBasicShares(fnftId, allocPoints);
        } else if (asset == lpAddress) {
            IRewardsHandler(rewardsHandlerAddress).updateLPShares(fnftId, allocPoints);
        }
        emit DepositERC20OutputReceiver(_msgSender(), asset, amount, fnftId, '');
    }




    function getInterestRate(uint months) public view returns (uint) {

        if (months <= 1) {
            return interestRates[0];
        } else if (months <= 3) {
            return interestRates[1];
        } else if (months <= 6) {
            return interestRates[2];
        } else {
            return interestRates[3];
        }
    }

    function getRevest() private view returns (IRevest) {

        return IRevest(getRegistry().getRevest());
    }

    function getRegistry() public view returns (IAddressRegistry) {

        return IAddressRegistry(addressRegistry);
    }

    function getWindow(uint timePeriod) public pure returns (uint window) {

        if(timePeriod == 1) {
            window = WINDOW_ONE;
        }
        if(timePeriod == 3) {
            window = WINDOW_THREE;
        }
        if(timePeriod == 6) {
            window = WINDOW_SIX;
        }
        if(timePeriod == 12) {
            window = WINDOW_TWELVE;
        }
    }


    function needsUpdate() external pure override returns (bool) {

        return true;
    }

    function getMetadata() external view override returns (string memory) {

        return addressMetadataUrl;
    }

    function isUnlockable(uint fnftId, uint) external view override returns (bool) {

        uint timePeriod = stakingConfigs[fnftId].timePeriod;
        uint depositTime;
        if(fnftId <= previousStakingIDCutoff) {
            (, timePeriod) = IOldStaking(oldStakingContract).config(fnftId);
            depositTime =  ILockManager(getRegistry().getLockManager()).fnftIdToLock(fnftId).creationTime;
        } else {
            depositTime = stakingConfigs[fnftId].dateLockedFrom;
        }
        uint window = getWindow(timePeriod);
        bool mature = block.timestamp - depositTime > timePeriod;
        bool window_open = (block.timestamp - depositTime) % (timePeriod * 30 * ONE_DAY) < window;
        return mature && window_open;
    }

    function getDisplayValues(uint fnftId, uint) external view override returns (bytes memory) {

        if(fnftId <= previousStakingIDCutoff) {
            return IAddressLock(oldStakingContract).getDisplayValues(fnftId, 0);
        }
        uint allocPoints;
        {
            uint revestTokenAlloc = IRewardsHandler(rewardsHandlerAddress).getAllocPoint(fnftId, revestAddress, true);
            uint lpTokenAlloc = IRewardsHandler(rewardsHandlerAddress).getAllocPoint(fnftId, revestAddress, false);
            allocPoints = revestTokenAlloc > 0 ? revestTokenAlloc : lpTokenAlloc;
        }
        uint timePeriod = stakingConfigs[fnftId].timePeriod;
        return abi.encode(allocPoints, timePeriod);
    }


    function getCustomMetadata(uint fnftId) external view override returns (string memory) {

        if(fnftId <= previousStakingIDCutoff) {
            return IOldStaking(oldStakingContract).customMetadataUrl();
        } else {
            return customMetadataUrl;
        }
    }

    function getOutputDisplayValues(uint fnftId) external view override returns (bytes memory) {

        if(fnftId <= previousStakingIDCutoff) {
            return IOutputReceiver(oldStakingContract).getOutputDisplayValues(fnftId);
        }
        bool isRevestToken;
        {
            uint revestTokenAlloc = IRewardsHandler(rewardsHandlerAddress).getAllocPoint(fnftId, revestAddress, true);
            uint wethTokenAlloc = IRewardsHandler(rewardsHandlerAddress).getAllocPoint(fnftId, WETH, true);
            isRevestToken = revestTokenAlloc > 0 || wethTokenAlloc > 0;
        }
        uint revestRewards = IRewardsHandler(rewardsHandlerAddress).getRewards(fnftId, revestAddress);
        uint wethRewards = IRewardsHandler(rewardsHandlerAddress).getRewards(fnftId, WETH);
        uint timePeriod = stakingConfigs[fnftId].timePeriod;
        uint nextUnlock = block.timestamp + ((timePeriod * 30 days) - ((block.timestamp - stakingConfigs[fnftId].dateLockedFrom)  % (timePeriod * 30 days)));
        return abi.encode(revestRewards, wethRewards, timePeriod, stakingConfigs[fnftId].dateLockedFrom, isRevestToken ? revestAddress : lpAddress, stakingConfigs[fnftId].dateLockedFrom, nextUnlock);
    }

    function getAddressRegistry() external view override returns (address) {

        return addressRegistry;
    }

    function getValue(uint fnftId) external view override returns (uint) {

        return ITokenVault(getRegistry().getTokenVault()).getFNFT(fnftId).depositAmount;
    }

    function getAsset(uint fnftId) external view override returns (address) {

        return ITokenVault(getRegistry().getTokenVault()).getFNFT(fnftId).asset;
    }


    function setCustomMetadata(string memory _customMetadataUrl) external onlyOwner {

        customMetadataUrl = _customMetadataUrl;
    }

    function setLPAddress(address lpAddress_) external onlyOwner {

        lpAddress = lpAddress_;
    }

    function setAddressRegistry(address addressRegistry_) external override onlyOwner {

        addressRegistry = addressRegistry_;
    }

    function setMetadata(string memory _addressMetadataUrl) external onlyOwner {

        addressMetadataUrl = _addressMetadataUrl;
    }

    function setRewardsHandler(address _handler) external onlyOwner {

        rewardsHandlerAddress = _handler;
    }

    function setCutoff(uint cutoff) external onlyOwner {

        previousStakingIDCutoff = cutoff;
    }

    function setOldStaking(address stake) external onlyOwner {

        oldStakingContract = stake;
    }

    function setAdditionalDepositsEnabled(bool enabled) external onlyOwner {

        additionalEnabled = enabled;
    }

}