
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
}// agpl-3.0
pragma solidity 0.8.6;


interface IAToken is IERC20 {
  event Mint(address indexed from, uint256 value, uint256 index);

  function mint(
    address user,
    uint256 amount,
    uint256 index
  ) external returns (bool);

  event Burn(address indexed from, address indexed target, uint256 value, uint256 index);

  event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);

  function burn(
    address user,
    address receiverOfUnderlying,
    uint256 amount,
    uint256 index
  ) external;

  function mintToTreasury(uint256 amount, uint256 index) external;

  function transferOnLiquidation(
    address from,
    address to,
    uint256 value
  ) external;

  function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);
}// agpl-3.0

pragma solidity 0.8.6;


interface ATokenInterface is IAToken {
  function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}// agpl-3.0

pragma solidity 0.8.6;

pragma experimental ABIEncoderV2;

interface IAaveIncentivesController {
  event RewardsAccrued(address indexed user, uint256 amount);

  event RewardsClaimed(address indexed user, address indexed to, uint256 amount);


  event ClaimerSet(address indexed user, address indexed claimer);

  function getAssetData(address asset)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );

  function setClaimer(address user, address claimer) external;

  function getClaimer(address user) external view returns (address);

  function configureAssets(address[] calldata assets, uint256[] calldata emissionsPerSecond)
    external;

  function handleAction(
    address asset,
    uint256 userBalance,
    uint256 totalSupply
  ) external;

  function getRewardsBalance(address[] calldata assets, address user)
    external
    view
    returns (uint256);

  function claimRewards(
    address[] calldata assets,
    uint256 amount,
    address to
  ) external returns (uint256);

  function claimRewardsOnBehalf(
    address[] calldata assets,
    uint256 amount,
    address user,
    address to
  ) external returns (uint256);

  function getUserUnclaimedRewards(address user) external view returns (uint256);

  function getUserAssetData(address user, address asset) external view returns (uint256);

  function REWARD_TOKEN() external view returns (address);

  function PRECISION() external view returns (uint8);

  function DISTRIBUTION_END() external view returns (uint256);
}// agpl-3.0
pragma solidity 0.8.6;

interface ILendingPool {

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);

}// agpl-3.0
pragma solidity 0.8.6;

interface ILendingPoolAddressesProvider {
  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);

  function setMarketId(string calldata marketId) external;

  function setAddress(bytes32 id, address newAddress) external;

  function setAddressAsProxy(bytes32 id, address impl) external;

  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address pool) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address configurator) external;

  function getLendingPoolCollateralManager() external view returns (address);

  function setLendingPoolCollateralManager(address manager) external;

  function getPoolAdmin() external view returns (address);

  function setPoolAdmin(address admin) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address lendingRateOracle) external;
}// agpl-3.0
pragma solidity 0.8.6;

interface ILendingPoolAddressesProviderRegistry {
  event AddressesProviderRegistered(address indexed newAddress);
  event AddressesProviderUnregistered(address indexed newAddress);

  function getAddressesProvidersList() external view returns (address[] memory);

  function getAddressesProviderIdByAddress(address addressesProvider)
    external
    view
    returns (uint256);

  function registerAddressesProvider(address provider, uint256 id) external;

  function unregisterAddressesProvider(address provider) external;
}// GPL-3.0

pragma solidity >=0.6.0;

interface IYieldSource {
    function depositToken() external view returns (address);

    function balanceOfToken(address addr) external returns (uint256);

    function supplyTokenTo(uint256 amount, address to) external;

    function redeemToken(uint256 amount) external returns (uint256);
}// GPL-3.0

pragma solidity 0.8.6;


interface IProtocolYieldSource is IYieldSource {
  function transferERC20(IERC20 token, address to, uint256 amount) external;

  function sponsor(uint256 amount) external;
}// MIT


pragma solidity >=0.4.0;

library OpenZeppelinSafeMath_V3_3_0 {
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
}/**
Copyright 2020 PoolTogether Inc.

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.4.0;


library FixedPoint {
    using OpenZeppelinSafeMath_V3_3_0 for uint256;

    uint256 internal constant SCALE = 1e18;

    function calculateMantissa(uint256 numerator, uint256 denominator) internal pure returns (uint256) {
        uint256 mantissa = numerator.mul(SCALE);
        mantissa = mantissa.div(denominator);
        return mantissa;
    }

    function multiplyUintByMantissa(uint256 b, uint256 mantissa) internal pure returns (uint256) {
        uint256 result = mantissa.mul(b);
        result = result.div(SCALE);
        return result;
    }

    function divideUintByMantissa(uint256 dividend, uint256 mantissa) internal pure returns (uint256) {
        uint256 result = SCALE.mul(dividend);
        result = result.div(mantissa);
        return result;
    }
}// GPL-3.0

pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;
    address private _pendingOwner;

    event OwnershipOffered(address indexed pendingOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor(address _initialOwner) {
        _setOwner(_initialOwner);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    function pendingOwner() external view virtual returns (address) {
        return _pendingOwner;
    }

    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Ownable/pendingOwner-not-zero-address");

        _pendingOwner = _newOwner;

        emit OwnershipOffered(_newOwner);
    }

    function claimOwnership() external onlyPendingOwner {
        _setOwner(_pendingOwner);
        _pendingOwner = address(0);
    }


    function _setOwner(address _newOwner) private {
        address _oldOwner = _owner;
        _owner = _newOwner;
        emit OwnershipTransferred(_oldOwner, _newOwner);
    }


    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable/caller-not-owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "Ownable/caller-not-pendingOwner");
        _;
    }
}// GPL-3.0

pragma solidity ^0.8.0;


abstract contract Manageable is Ownable {
    address private _manager;

    event ManagerTransferred(address indexed previousManager, address indexed newManager);


    function manager() public view virtual returns (address) {
        return _manager;
    }

    function setManager(address _newManager) external onlyOwner returns (bool) {
        return _setManager(_newManager);
    }


    function _setManager(address _newManager) private returns (bool) {
        address _previousManager = _manager;

        require(_newManager != _previousManager, "Manageable/existing-manager-address");

        _manager = _newManager;

        emit ManagerTransferred(_previousManager, _newManager);
        return true;
    }


    modifier onlyManager() {
        require(manager() == msg.sender, "Manageable/caller-not-manager");
        _;
    }

    modifier onlyManagerOrOwner() {
        require(manager() == msg.sender || owner() == msg.sender, "Manageable/caller-not-manager-or-owner");
        _;
    }
}// GPL-3.0

pragma solidity 0.8.6;



contract ATokenYieldSource is ERC20, IProtocolYieldSource, Manageable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event ATokenYieldSourceInitialized(
    IAToken indexed aToken,
    ILendingPoolAddressesProviderRegistry lendingPoolAddressesProviderRegistry,
    uint8 decimals,
    string name,
    string symbol,
    address owner
  );

  event RedeemedToken(
    address indexed from,
    uint256 shares,
    uint256 amount
  );

  event Claimed(
    address indexed user,
    address indexed to,
    uint256 amount
  );

  event SuppliedTokenTo(
    address indexed from,
    uint256 shares,
    uint256 amount,
    address indexed to
  );

  event Sponsored(
    address indexed from,
    uint256 amount
  );

  event TransferredERC20(
    address indexed from,
    address indexed to,
    uint256 amount,
    IERC20 indexed token
  );

  ATokenInterface public aToken;

  IAaveIncentivesController public incentivesController;

  ILendingPoolAddressesProviderRegistry public lendingPoolAddressesProviderRegistry;

  uint8 internal __decimals;

  uint256 private constant ADDRESSES_PROVIDER_ID = uint256(0);

  uint16 private constant REFERRAL_CODE = uint16(188);

  constructor (
    ATokenInterface _aToken,
    IAaveIncentivesController _incentivesController,
    ILendingPoolAddressesProviderRegistry _lendingPoolAddressesProviderRegistry,
    uint8 _decimals,
    string memory _symbol,
    string memory _name,
    address _owner
  ) Ownable(_owner) ERC20(_name, _symbol) ReentrancyGuard()
  {
    require(address(_aToken) != address(0), "ATokenYieldSource/aToken-not-zero-address");
    aToken = _aToken;

    require(address(_incentivesController) != address(0), "ATokenYieldSource/incentivesController-not-zero-address");
    incentivesController = _incentivesController;

    require(address(_lendingPoolAddressesProviderRegistry) != address(0), "ATokenYieldSource/lendingPoolRegistry-not-zero-address");
    lendingPoolAddressesProviderRegistry = _lendingPoolAddressesProviderRegistry;

    require(_owner != address(0), "ATokenYieldSource/owner-not-zero-address");

    require(_decimals > 0, "ATokenYieldSource/decimals-gt-zero");
    __decimals = _decimals;

    IERC20(_tokenAddress()).safeApprove(address(_lendingPool()), type(uint256).max);

    emit ATokenYieldSourceInitialized (
      _aToken,
      _lendingPoolAddressesProviderRegistry,
      _decimals,
      _name,
      _symbol,
      _owner
    );
  }

  function decimals() public override view returns (uint8) {
    return __decimals;
  }

  function approveMaxAmount() external onlyOwner returns (bool) {
    address _lendingPoolAddress = address(_lendingPool());
    IERC20 _underlyingAsset = IERC20(_tokenAddress());
    uint256 _allowance = _underlyingAsset.allowance(address(this), _lendingPoolAddress);

    _underlyingAsset.safeIncreaseAllowance(_lendingPoolAddress, type(uint256).max.sub(_allowance));
    return true;
  }

  function depositToken() public view override returns (address) {
    return _tokenAddress();
  }

  function _tokenAddress() internal view returns (address) {
    return aToken.UNDERLYING_ASSET_ADDRESS();
  }

  function balanceOfToken(address addr) external override view returns (uint256) {
    return _sharesToToken(balanceOf(addr));
  }

  function _tokenToShares(uint256 _tokens) internal view returns (uint256) {
    uint256 _shares;
    uint256 _totalSupply = totalSupply();

    if (_totalSupply == 0) {
      _shares = _tokens;
    } else {
      uint256 _exchangeMantissa = FixedPoint.calculateMantissa(_totalSupply, aToken.balanceOf(address(this)));
      _shares = FixedPoint.multiplyUintByMantissa(_tokens, _exchangeMantissa);
    }

    return _shares;
  }

  function _sharesToToken(uint256 _shares) internal view returns (uint256) {
    uint256 _tokens;
    uint256 _totalSupply = totalSupply();

    if (_totalSupply == 0) {
      _tokens = _shares;
    } else {
      _tokens = _shares.mul(aToken.balanceOf(address(this))).div(_totalSupply);
    }

    return _tokens;
  }

  function _depositToAave(uint256 mintAmount) internal {
    address _underlyingAssetAddress = _tokenAddress();
    ILendingPool __lendingPool = _lendingPool();
    IERC20 _depositToken = IERC20(_underlyingAssetAddress);

    _depositToken.safeTransferFrom(msg.sender, address(this), mintAmount);
    __lendingPool.deposit(_underlyingAssetAddress, mintAmount, address(this), REFERRAL_CODE);
  }

  function supplyTokenTo(uint256 mintAmount, address to) external override nonReentrant {
    uint256 shares = _tokenToShares(mintAmount);

    require(shares > 0, "ATokenYieldSource/shares-gt-zero");
    _depositToAave(mintAmount);
    _mint(to, shares);

    emit SuppliedTokenTo(msg.sender, shares, mintAmount, to);
  }

  function redeemToken(uint256 redeemAmount) external override nonReentrant returns (uint256) {
    address _underlyingAssetAddress = _tokenAddress();
    IERC20 _depositToken = IERC20(_underlyingAssetAddress);

    uint256 shares = _tokenToShares(redeemAmount);
    _burn(msg.sender, shares);

    uint256 beforeBalance = _depositToken.balanceOf(address(this));
    _lendingPool().withdraw(_underlyingAssetAddress, redeemAmount, address(this));
    uint256 afterBalance = _depositToken.balanceOf(address(this));

    uint256 balanceDiff = afterBalance.sub(beforeBalance);
    _depositToken.safeTransfer(msg.sender, balanceDiff);

    emit RedeemedToken(msg.sender, shares, redeemAmount);
    return balanceDiff;
  }

  function transferERC20(IERC20 erc20Token, address to, uint256 amount) external override onlyManagerOrOwner {
    require(address(erc20Token) != address(aToken), "ATokenYieldSource/aToken-transfer-not-allowed");
    erc20Token.safeTransfer(to, amount);
    emit TransferredERC20(msg.sender, to, amount, erc20Token);
  }

  function sponsor(uint256 amount) external override nonReentrant {
    _depositToAave(amount);
    emit Sponsored(msg.sender, amount);
  }

  function claimRewards(address to) external onlyManagerOrOwner returns (bool) {
    require(to != address(0), "ATokenYieldSource/recipient-not-zero-address");

    IAaveIncentivesController _incentivesController = incentivesController;

    address[] memory _assets = new address[](1);
    _assets[0] = address(aToken);

    uint256 _amount = _incentivesController.getRewardsBalance(_assets, address(this));
    uint256 _amountClaimed = _incentivesController.claimRewards(_assets, _amount, to);

    emit Claimed(msg.sender, to, _amountClaimed);
    return true;
  }

  function _lendingPoolProvider() internal view returns (ILendingPoolAddressesProvider) {
    return ILendingPoolAddressesProvider(lendingPoolAddressesProviderRegistry.getAddressesProvidersList()[ADDRESSES_PROVIDER_ID]);
  }

  function _lendingPool() internal view returns (ILendingPool) {
    return ILendingPool(_lendingPoolProvider().getLendingPool());
  }
}