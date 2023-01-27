

pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;



contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract Pausable is Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
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


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.5.0;


contract CommonConstants {


    uint public constant EXCHANGE_RATE_BASE_RATE = 1e18;

}




pragma solidity ^0.5.0;


contract Blacklistable is Ownable {


    string public constant BLACKLISTED = "BLACKLISTED";

    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

    modifier onlyBlacklister() {

        require(msg.sender == owner(), "MUST_BE_BLACKLISTER");
        _;
    }

    modifier notBlacklisted(address account) {

        require(blacklisted[account] == false, BLACKLISTED);
        _;
    }

    function checkNotBlacklisted(address account) public view {

        require(!blacklisted[account], BLACKLISTED);
    }

    function isBlacklisted(address account) public view returns (bool) {

        return blacklisted[account];
    }

    function blacklist(address account) public onlyBlacklister {

        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    function unBlacklist(address account) public onlyBlacklister {

        blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

}




pragma solidity ^0.5.0;


contract DmmBlacklistable is Blacklistable {


    constructor() public {
    }

}


pragma solidity ^0.5.0;

interface IOffChainAssetValuator {


    event AssetsValueUpdated(uint newAssetsValue);

    function getOffChainAssetsValue() external view returns (uint);


}


pragma solidity ^0.5.0;

interface InterestRateInterface {


    function getInterestRate(uint dmmTokenId, uint totalSupply, uint activeSupply) external view returns (uint);


}


pragma solidity ^0.5.0;



interface IDmmController {


    event TotalSupplyIncreased(uint oldTotalSupply, uint newTotalSupply);
    event TotalSupplyDecreased(uint oldTotalSupply, uint newTotalSupply);

    event AdminDeposit(address indexed sender, uint amount);
    event AdminWithdraw(address indexed receiver, uint amount);

    function blacklistable() external view returns (Blacklistable);


    function addMarket(
        address underlyingToken,
        string calldata symbol,
        string calldata name,
        uint8 decimals,
        uint minMintAmount,
        uint minRedeemAmount,
        uint totalSupply
    ) external;


    function addMarketFromExistingDmmToken(
        address dmmToken,
        address underlyingToken
    ) external;


    function transferOwnershipToNewController(
        address newController
    ) external;


    function enableMarket(uint dmmTokenId) external;


    function disableMarket(uint dmmTokenId) external;


    function setGuardian(address newGuardian) external;


    function setDmmTokenFactory(address newDmmTokenFactory) external;


    function setDmmEtherFactory(address newDmmEtherFactory) external;


    function setInterestRateInterface(address newInterestRateInterface) external;


    function setOffChainAssetValuator(address newOffChainAssetValuator) external;


    function setOffChainCurrencyValuator(address newOffChainCurrencyValuator) external;


    function setUnderlyingTokenValuator(address newUnderlyingTokenValuator) external;


    function setMinCollateralization(uint newMinCollateralization) external;


    function setMinReserveRatio(uint newMinReserveRatio) external;


    function increaseTotalSupply(uint dmmTokenId, uint amount) external;


    function decreaseTotalSupply(uint dmmTokenId, uint amount) external;


    function adminWithdrawFunds(uint dmmTokenId, uint underlyingAmount) external;


    function adminDepositFunds(uint dmmTokenId, uint underlyingAmount) external;


    function getDmmTokenIds() external view returns (uint[] memory);


    function getTotalCollateralization() external view returns (uint);


    function getActiveCollateralization() external view returns (uint);


    function getInterestRateByUnderlyingTokenAddress(address underlyingToken) external view returns (uint);


    function getInterestRateByDmmTokenId(uint dmmTokenId) external view returns (uint);


    function getInterestRateByDmmTokenAddress(address dmmToken) external view returns (uint);


    function getExchangeRateByUnderlying(address underlyingToken) external view returns (uint);


    function getExchangeRate(address dmmToken) external view returns (uint);


    function getDmmTokenForUnderlying(address underlyingToken) external view returns (address);


    function getUnderlyingTokenForDmm(address dmmToken) external view returns (address);


    function isMarketEnabledByDmmTokenId(uint dmmTokenId) external view returns (bool);


    function isMarketEnabledByDmmTokenAddress(address dmmToken) external view returns (bool);


    function getTokenIdFromDmmTokenAddress(address dmmTokenAddress) external view returns (uint);


    function getDmmTokenAddressByDmmTokenId(uint dmmTokenId) external view returns (address);


}


pragma solidity ^0.5.0;


interface IDmmToken {



    event Mint(address indexed minter, address indexed recipient, uint amount);
    event Redeem(address indexed redeemer, address indexed recipient, uint amount);
    event FeeTransfer(address indexed owner, address indexed recipient, uint amount);

    event TotalSupplyIncreased(uint oldTotalSupply, uint newTotalSupply);
    event TotalSupplyDecreased(uint oldTotalSupply, uint newTotalSupply);

    event OffChainRequestValidated(address indexed owner, address indexed feeRecipient, uint nonce, uint expiry, uint feeAmount);


    function controller() external view returns (IDmmController);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function minMintAmount() external view returns (uint);


    function minRedeemAmount() external view returns (uint);


    function activeSupply() external view returns (uint);


    function increaseTotalSupply(uint amount) external;


    function decreaseTotalSupply(uint amount) external;


    function depositUnderlying(uint underlyingAmount) external returns (bool);


    function withdrawUnderlying(uint underlyingAmount) external returns (bool);


    function exchangeRateLastUpdatedTimestamp() external view returns (uint);


    function exchangeRateLastUpdatedBlockNumber() external view returns (uint);


    function getCurrentExchangeRate() external view returns (uint);


    function nonceOf(address owner) external view returns (uint);


    function mint(uint amount) external returns (uint);


    function mintFromGaslessRequest(
        address owner,
        address recipient,
        uint nonce,
        uint expiry,
        uint amount,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint);


    function redeem(uint amount) external returns (uint);


    function redeemFromGaslessRequest(
        address owner,
        address recipient,
        uint nonce,
        uint expiry,
        uint amount,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint);


    function permit(
        address owner,
        address spender,
        uint nonce,
        uint expiry,
        bool allowed,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function transferFromGaslessRequest(
        address owner,
        address recipient,
        uint nonce,
        uint expiry,
        uint amount,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


}


pragma solidity ^0.5.0;

interface IUnderlyingTokenValuator {


    function getTokenValue(address token, uint amount) external view returns (uint);


}


pragma solidity ^0.5.0;


interface IDmmTokenFactory {


    function deployToken(
        string calldata symbol,
        string calldata name,
        uint8 decimals,
        uint minMintAmount,
        uint minRedeemAmount,
        uint totalSupply,
        address controller
    ) external returns (IDmmToken);


}


pragma solidity ^0.5.0;

interface IPausable {


    function paused() external view returns (bool);


}


pragma solidity ^0.5.0;

interface IOffChainCurrencyValuator {


    function getOffChainCurrenciesValue() external view returns (uint);


}




pragma solidity ^0.5.0;

















contract DmmController is IPausable, Pausable, CommonConstants, IDmmController, Ownable {


    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;


    event GuardianChanged(address previousGuardian, address newGuardian);
    event DmmTokenFactoryChanged(address previousDmmTokenFactory, address newDmmTokenFactory);
    event DmmEtherFactoryChanged(address previousDmmEtherFactory, address newDmmEtherFactory);
    event InterestRateInterfaceChanged(address previousInterestRateInterface, address newInterestRateInterface);
    event OffChainAssetValuatorChanged(address previousOffChainAssetValuator, address newOffChainAssetValuator);
    event OffChainCurrencyValuatorChanged(address previousOffChainCurrencyValuator, address newOffChainCurrencyValuator);
    event UnderlyingTokenValuatorChanged(address previousUnderlyingTokenValuator, address newUnderlyingTokenValuator);

    event MarketAdded(uint indexed dmmTokenId, address indexed dmmToken, address indexed underlyingToken);

    event DisableMarket(uint indexed dmmTokenId);
    event EnableMarket(uint indexed dmmTokenId);

    event MinCollateralizationChanged(uint previousMinCollateralization, uint newMinCollateralization);
    event MinReserveRatioChanged(uint previousMinReserveRatio, uint newMinReserveRatio);


    address public guardian;
    InterestRateInterface public interestRateInterface;
    IOffChainAssetValuator public offChainAssetsValuator;
    IOffChainCurrencyValuator public offChainCurrencyValuator;
    IUnderlyingTokenValuator public underlyingTokenValuator;
    IDmmTokenFactory public dmmEtherFactory;
    IDmmTokenFactory public dmmTokenFactory;
    DmmBlacklistable public dmmBlacklistable;
    uint public minCollateralization;
    uint public minReserveRatio;
    address public wethToken;


    mapping(uint => address) public dmmTokenIdToDmmTokenAddressMap;
    mapping(address => uint) public dmmTokenAddressToDmmTokenIdMap;

    mapping(address => uint) public underlyingTokenAddressToDmmTokenIdMap;
    mapping(uint => address) public dmmTokenIdToUnderlyingTokenAddressMap;

    mapping(uint => bool) public dmmTokenIdToIsDisabledMap;
    uint[] public dmmTokenIds;


    uint public constant COLLATERALIZATION_BASE_RATE = 1e18;
    uint public constant INTEREST_RATE_BASE_RATE = 1e18;
    uint public constant MIN_RESERVE_RATIO_BASE_RATE = 1e18;

    constructor(
        address _guardian,
        address _interestRateInterface,
        address _offChainAssetsValuator,
        address _offChainCurrencyValuator,
        address _underlyingTokenValuator,
        address _dmmEtherFactory,
        address _dmmTokenFactory,
        address _dmmBlacklistable,
        uint _minCollateralization,
        uint _minReserveRatio,
        address _wethToken
    ) public {
        guardian = _guardian;
        interestRateInterface = InterestRateInterface(_interestRateInterface);
        offChainAssetsValuator = IOffChainAssetValuator(_offChainAssetsValuator);
        offChainCurrencyValuator = IOffChainCurrencyValuator(_offChainCurrencyValuator);
        underlyingTokenValuator = IUnderlyingTokenValuator(_underlyingTokenValuator);
        dmmTokenFactory = IDmmTokenFactory(_dmmTokenFactory);
        dmmEtherFactory = IDmmTokenFactory(_dmmEtherFactory);
        dmmBlacklistable = DmmBlacklistable(_dmmBlacklistable);
        minCollateralization = _minCollateralization;
        minReserveRatio = _minReserveRatio;
        wethToken = _wethToken;
    }


    modifier whenNotPaused() {

        require(!paused(), "ECOSYSTEM_PAUSED");
        _;
    }

    modifier whenPaused() {

        require(paused(), "ECOSYSTEM_NOT_PAUSED");
        _;
    }

    modifier checkTokenExists(uint dmmTokenId) {

        require(dmmTokenIdToDmmTokenAddressMap[dmmTokenId] != address(0x0), "TOKEN_DOES_NOT_EXIST");
        _;
    }

    modifier onlyOwnerOrGuardian() {

        require(isOwner() || msg.sender == guardian, "MUST_BE_OWNER_OR_GUARDIAN");
        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {

        address oldOwner = owner();
        super.transferOwnership(newOwner);
        _removePauser(oldOwner);
        _addPauser(newOwner);
    }

    function blacklistable() public view returns (Blacklistable) {

        return dmmBlacklistable;
    }

    function addMarket(
        address underlyingToken,
        string memory symbol,
        string memory name,
        uint8 decimals,
        uint minMintAmount,
        uint minRedeemAmount,
        uint totalSupply
    ) public onlyOwner {

        require(
            underlyingTokenAddressToDmmTokenIdMap[underlyingToken] == 0,
            "TOKEN_ALREADY_EXISTS"
        );

        IDmmToken dmmToken;
        address controller = address(this);
        if (underlyingToken == wethToken) {
            dmmToken = dmmEtherFactory.deployToken(
                symbol,
                name,
                decimals,
                minMintAmount,
                minRedeemAmount,
                totalSupply,
                controller
            );
        } else {
            dmmToken = dmmTokenFactory.deployToken(
                symbol,
                name,
                decimals,
                minMintAmount,
                minRedeemAmount,
                totalSupply,
                controller
            );
        }

        _addMarket(address(dmmToken), underlyingToken);
    }

    function addMarketFromExistingDmmToken(
        address dmmToken,
        address underlyingToken
    )
    onlyOwner
    public {

        require(
            underlyingTokenAddressToDmmTokenIdMap[underlyingToken] == 0,
            "TOKEN_ALREADY_EXISTS"
        );
        require(
            dmmToken.isContract(),
            "DMM_TOKEN_IS_NOT_CONTRACT"
        );
        require(
            underlyingToken.isContract(),
            "UNDERLYING_TOKEN_IS_NOT_CONTRACT"
        );
        require(
            Ownable(dmmToken).owner() == address(this),
            "INVALID_DMM_TOKEN_OWNERSHIP"
        );

        _addMarket(dmmToken, underlyingToken);
    }

    function transferOwnershipToNewController(
        address newController
    )
    onlyOwner
    public {

        require(
            newController.isContract(),
            "NEW_CONTROLLER_IS_NOT_CONTRACT"
        );
        for (uint i = 0; i < dmmTokenIds.length; i++) {
            address dmmToken = dmmTokenIdToDmmTokenAddressMap[dmmTokenIds[i]];
            Ownable(dmmToken).transferOwnership(newController);
        }
        Ownable(address(dmmEtherFactory)).transferOwnership(newController);
        Ownable(address(dmmTokenFactory)).transferOwnership(newController);
    }

    function enableMarket(uint dmmTokenId) public checkTokenExists(dmmTokenId) whenNotPaused onlyOwner {

        require(dmmTokenIdToIsDisabledMap[dmmTokenId], "MARKET_ALREADY_ENABLED");
        dmmTokenIdToIsDisabledMap[dmmTokenId] = false;
        emit EnableMarket(dmmTokenId);
    }

    function disableMarket(uint dmmTokenId) public checkTokenExists(dmmTokenId) whenNotPaused onlyOwner {

        require(!dmmTokenIdToIsDisabledMap[dmmTokenId], "MARKET_ALREADY_DISABLED");
        dmmTokenIdToIsDisabledMap[dmmTokenId] = true;
        emit DisableMarket(dmmTokenId);
    }

    function setGuardian(
        address newGuardian
    )
    whenNotPaused
    onlyOwner
    public {

        address oldGuardian = guardian;
        guardian = newGuardian;
        emit GuardianChanged(oldGuardian, newGuardian);
    }

    function setDmmTokenFactory(address newDmmTokenFactory) public whenNotPaused onlyOwner {

        address oldDmmTokenFactory = address(dmmTokenFactory);
        dmmTokenFactory = IDmmTokenFactory(newDmmTokenFactory);
        emit DmmTokenFactoryChanged(oldDmmTokenFactory, address(dmmTokenFactory));
    }

    function setDmmEtherFactory(address newDmmEtherFactory) public whenNotPaused onlyOwner {

        address oldDmmEtherFactory = address(dmmEtherFactory);
        dmmEtherFactory = IDmmTokenFactory(newDmmEtherFactory);
        emit DmmEtherFactoryChanged(oldDmmEtherFactory, address(dmmEtherFactory));
    }

    function setInterestRateInterface(address newInterestRateInterface) public whenNotPaused onlyOwner {

        address oldInterestRateInterface = address(interestRateInterface);
        interestRateInterface = InterestRateInterface(newInterestRateInterface);
        emit InterestRateInterfaceChanged(oldInterestRateInterface, address(interestRateInterface));
    }

    function setOffChainAssetValuator(address newOffChainAssetValuator) public whenNotPaused onlyOwner {

        address oldOffChainAssetValuator = address(offChainAssetsValuator);
        offChainAssetsValuator = IOffChainAssetValuator(newOffChainAssetValuator);
        emit OffChainAssetValuatorChanged(oldOffChainAssetValuator, address(offChainAssetsValuator));
    }

    function setOffChainCurrencyValuator(address newOffChainCurrencyValuator) public whenNotPaused onlyOwner {

        address oldOffChainCurrencyValuator = address(offChainCurrencyValuator);
        offChainCurrencyValuator = IOffChainCurrencyValuator(newOffChainCurrencyValuator);
        emit OffChainCurrencyValuatorChanged(oldOffChainCurrencyValuator, address(offChainCurrencyValuator));
    }

    function setUnderlyingTokenValuator(address newUnderlyingTokenValuator) public whenNotPaused onlyOwner {

        address oldUnderlyingTokenValuator = address(underlyingTokenValuator);
        underlyingTokenValuator = IUnderlyingTokenValuator(newUnderlyingTokenValuator);
        emit UnderlyingTokenValuatorChanged(oldUnderlyingTokenValuator, address(underlyingTokenValuator));
    }

    function setMinCollateralization(uint newMinCollateralization) public whenNotPaused onlyOwner {

        uint oldMinCollateralization = minCollateralization;
        minCollateralization = newMinCollateralization;
        emit MinCollateralizationChanged(oldMinCollateralization, minCollateralization);
    }

    function setMinReserveRatio(uint newMinReserveRatio) public whenNotPaused onlyOwner {

        uint oldMinReserveRatio = minReserveRatio;
        minReserveRatio = newMinReserveRatio;
        emit MinReserveRatioChanged(oldMinReserveRatio, minReserveRatio);
    }

    function increaseTotalSupply(
        uint dmmTokenId,
        uint amount
    ) public checkTokenExists(dmmTokenId) whenNotPaused onlyOwner {

        IDmmToken(dmmTokenIdToDmmTokenAddressMap[dmmTokenId]).increaseTotalSupply(amount);
        require(getTotalCollateralization() >= minCollateralization, "INSUFFICIENT_COLLATERAL");
    }

    function decreaseTotalSupply(
        uint dmmTokenId,
        uint amount
    ) public checkTokenExists(dmmTokenId) whenNotPaused onlyOwner {

        IDmmToken(dmmTokenIdToDmmTokenAddressMap[dmmTokenId]).decreaseTotalSupply(amount);
    }

    function adminWithdrawFunds(
        uint dmmTokenId,
        uint underlyingAmount
    ) public checkTokenExists(dmmTokenId) whenNotPaused onlyOwner {

        IDmmToken token = IDmmToken(dmmTokenIdToDmmTokenAddressMap[dmmTokenId]);
        token.withdrawUnderlying(underlyingAmount);
        IERC20 underlyingToken = IERC20(dmmTokenIdToUnderlyingTokenAddressMap[dmmTokenId]);
        underlyingToken.safeTransfer(_msgSender(), underlyingAmount);

        uint totalOwedAmount = token.activeSupply().mul(token.getCurrentExchangeRate()).div(EXCHANGE_RATE_BASE_RATE);
        uint underlyingBalance = IERC20(dmmTokenIdToUnderlyingTokenAddressMap[dmmTokenId]).balanceOf(address(token));

        if (totalOwedAmount > 0) {
            uint actualReserveRatio = underlyingBalance.mul(MIN_RESERVE_RATIO_BASE_RATE).div(totalOwedAmount);
            require(actualReserveRatio >= minReserveRatio, "INSUFFICIENT_LEFTOVER_RESERVES");
        }

        emit AdminWithdraw(_msgSender(), underlyingAmount);
    }

    function adminDepositFunds(
        uint dmmTokenId,
        uint underlyingAmount
    ) public checkTokenExists(dmmTokenId) whenNotPaused onlyOwnerOrGuardian {

        IERC20 underlyingToken = IERC20(dmmTokenIdToUnderlyingTokenAddressMap[dmmTokenId]);
        underlyingToken.safeTransferFrom(_msgSender(), address(this), underlyingAmount);

        address dmmTokenAddress = dmmTokenIdToDmmTokenAddressMap[dmmTokenId];
        underlyingToken.approve(dmmTokenAddress, underlyingAmount);
        IDmmToken(dmmTokenAddress).depositUnderlying(underlyingAmount);
        emit AdminDeposit(_msgSender(), underlyingAmount);
    }

    function getTotalCollateralization() public view returns (uint) {

        uint totalLiabilities = 0;
        uint totalAssets = 0;
        for (uint i = 0; i < dmmTokenIds.length; i++) {
            IDmmToken token = IDmmToken(dmmTokenIdToDmmTokenAddressMap[dmmTokenIds[i]]);

            uint currentExchangeRate = token.getCurrentExchangeRate();

            uint futureExchangeRate = currentExchangeRate.mul(INTEREST_RATE_BASE_RATE.add(getInterestRateByDmmTokenAddress(address(token)))).div(INTEREST_RATE_BASE_RATE);

            uint totalSupply = IERC20(address(token)).totalSupply();

            uint underlyingLiabilitiesForTotalSupply = getDmmSupplyValue(token, totalSupply, futureExchangeRate);
            totalLiabilities = totalLiabilities.add(underlyingLiabilitiesForTotalSupply);

            uint underlyingAssetsForTotalSupply = getDmmSupplyValue(token, totalSupply, currentExchangeRate);
            totalAssets = totalAssets.add(underlyingAssetsForTotalSupply);
        }
        return getCollateralization(totalLiabilities, totalAssets);
    }

    function getActiveCollateralization() public view returns (uint) {

        uint totalLiabilities = 0;
        uint totalAssetsInDmmContract = 0;
        for (uint i = 0; i < dmmTokenIds.length; i++) {
            IDmmToken token = IDmmToken(dmmTokenIdToDmmTokenAddressMap[dmmTokenIds[i]]);
            uint underlyingLiabilitiesValue = getDmmSupplyValue(token, token.activeSupply(), token.getCurrentExchangeRate());
            totalLiabilities = totalLiabilities.add(underlyingLiabilitiesValue);

            IERC20 underlyingToken = IERC20(getUnderlyingTokenForDmm(address(token)));
            uint underlyingAssetsValue = getUnderlyingSupplyValue(underlyingToken, underlyingToken.balanceOf(address(token)), token.decimals());
            totalAssetsInDmmContract = totalAssetsInDmmContract.add(underlyingAssetsValue);
        }
        return getCollateralization(totalLiabilities, totalAssetsInDmmContract);
    }

    function getInterestRateByUnderlyingTokenAddress(address underlyingToken) public view returns (uint) {

        uint dmmTokenId = underlyingTokenAddressToDmmTokenIdMap[underlyingToken];
        return getInterestRateByDmmTokenId(dmmTokenId);
    }

    function getInterestRateByDmmTokenId(uint dmmTokenId) checkTokenExists(dmmTokenId) public view returns (uint) {

        address dmmToken = dmmTokenIdToDmmTokenAddressMap[dmmTokenId];
        uint totalSupply = IERC20(dmmToken).totalSupply();
        uint activeSupply = IDmmToken(dmmToken).activeSupply();
        return interestRateInterface.getInterestRate(dmmTokenId, totalSupply, activeSupply);
    }

    function getInterestRateByDmmTokenAddress(address dmmToken) public view returns (uint) {

        uint dmmTokenId = dmmTokenAddressToDmmTokenIdMap[dmmToken];
        _checkTokenExists(dmmTokenId);

        uint totalSupply = IERC20(dmmToken).totalSupply();
        uint activeSupply = IDmmToken(dmmToken).activeSupply();
        return interestRateInterface.getInterestRate(dmmTokenId, totalSupply, activeSupply);
    }

    function getExchangeRateByUnderlying(address underlyingToken) public view returns (uint) {

        address dmmToken = getDmmTokenForUnderlying(underlyingToken);
        return IDmmToken(dmmToken).getCurrentExchangeRate();
    }

    function getExchangeRate(address dmmToken) public view returns (uint) {

        uint dmmTokenId = dmmTokenAddressToDmmTokenIdMap[dmmToken];
        _checkTokenExists(dmmTokenId);

        return IDmmToken(dmmToken).getCurrentExchangeRate();
    }

    function getDmmTokenForUnderlying(address underlyingToken) public view returns (address) {

        uint dmmTokenId = underlyingTokenAddressToDmmTokenIdMap[underlyingToken];
        _checkTokenExists(dmmTokenId);

        return dmmTokenIdToDmmTokenAddressMap[dmmTokenId];
    }

    function getUnderlyingTokenForDmm(address dmmToken) public view returns (address) {

        uint dmmTokenId = dmmTokenAddressToDmmTokenIdMap[dmmToken];
        _checkTokenExists(dmmTokenId);

        return dmmTokenIdToUnderlyingTokenAddressMap[dmmTokenId];
    }

    function isMarketEnabledByDmmTokenId(uint dmmTokenId) checkTokenExists(dmmTokenId) public view returns (bool) {

        return !dmmTokenIdToIsDisabledMap[dmmTokenId];
    }

    function isMarketEnabledByDmmTokenAddress(address dmmToken) public view returns (bool) {

        uint dmmTokenId = dmmTokenAddressToDmmTokenIdMap[dmmToken];
        _checkTokenExists(dmmTokenId);

        return !dmmTokenIdToIsDisabledMap[dmmTokenId];
    }

    function getTokenIdFromDmmTokenAddress(address dmmToken) public view returns (uint) {

        uint dmmTokenId = dmmTokenAddressToDmmTokenIdMap[dmmToken];
        _checkTokenExists(dmmTokenId);

        return dmmTokenId;
    }

    function getDmmTokenAddressByDmmTokenId(uint dmmTokenId) external view returns (address) {

        address token = dmmTokenIdToDmmTokenAddressMap[dmmTokenId];
        require(token != address(0x0), "TOKEN_DOES_NOT_EXIST");
        return token;
    }

    function getDmmTokenIds() public view returns (uint[] memory) {

        return dmmTokenIds;
    }


    function _checkTokenExists(uint dmmTokenId) internal pure returns (bool) {

        require(dmmTokenId != 0, "TOKEN_DOES_NOT_EXIST");
        return true;
    }

    function _addMarket(address dmmToken, address underlyingToken) private {

        uint dmmTokenId = dmmTokenIds.length + 1;

        dmmTokenIdToDmmTokenAddressMap[dmmTokenId] = dmmToken;
        dmmTokenAddressToDmmTokenIdMap[dmmToken] = dmmTokenId;
        underlyingTokenAddressToDmmTokenIdMap[underlyingToken] = dmmTokenId;
        dmmTokenIdToUnderlyingTokenAddressMap[dmmTokenId] = underlyingToken;

        dmmTokenIdToIsDisabledMap[dmmTokenId] = false;
        dmmTokenIds.push(dmmTokenId);

        emit MarketAdded(dmmTokenId, dmmToken, underlyingToken);
    }

    function getCollateralization(uint totalLiabilities, uint totalAssets) private view returns (uint) {

        if (totalLiabilities == 0) {
            return 0;
        }
        uint collateralValue = offChainAssetsValuator.getOffChainAssetsValue().add(totalAssets).add(offChainCurrencyValuator.getOffChainCurrenciesValue());
        return collateralValue.mul(COLLATERALIZATION_BASE_RATE).div(totalLiabilities);
    }

    function getDmmSupplyValue(IDmmToken dmmToken, uint dmmSupply, uint currentExchangeRate) private view returns (uint) {

        uint underlyingTokenAmount = dmmSupply.mul(currentExchangeRate).div(EXCHANGE_RATE_BASE_RATE);
        uint standardizedUnderlyingTokenAmount;
        if (dmmToken.decimals() == 18) {
            standardizedUnderlyingTokenAmount = underlyingTokenAmount;
        } else if (dmmToken.decimals() < 18) {
            standardizedUnderlyingTokenAmount = underlyingTokenAmount.mul((10 ** (18 - uint(dmmToken.decimals()))));
        } else /* decimals > 18 */ {
            standardizedUnderlyingTokenAmount = underlyingTokenAmount.div((10 ** (uint(dmmToken.decimals()) - 18)));
        }
        address underlyingToken = getUnderlyingTokenForDmm(address(dmmToken));
        return underlyingTokenValuator.getTokenValue(underlyingToken, standardizedUnderlyingTokenAmount);
    }

    function getUnderlyingSupplyValue(IERC20 underlyingToken, uint underlyingSupply, uint8 decimals) private view returns (uint) {

        uint standardizedUnderlyingTokenAmount;
        if (decimals == 18) {
            standardizedUnderlyingTokenAmount = underlyingSupply;
        } else if (decimals < 18) {
            standardizedUnderlyingTokenAmount = underlyingSupply.mul((10 ** (18 - uint(decimals))));
        } else /* decimals > 18 */ {
            standardizedUnderlyingTokenAmount = underlyingSupply.div((10 ** (uint(decimals) - 18)));
        }
        return underlyingTokenValuator.getTokenValue(address(underlyingToken), standardizedUnderlyingTokenAmount);
    }

}