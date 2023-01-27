
pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

library Constant {

    uint256 public constant MULTIPLIERX10E18 = 10**18;

    address public constant BCNATIVETOKENADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    uint256 public constant PRODUCTSTATUS_ENABLED = 1;
    uint256 public constant PRODUCTSTATUS_DISABLED = 2;

    uint256 public constant COVERSTATUS_ACTIVE = 0;
    uint256 public constant COVERSTATUS_EXPIRED = 1;
    uint256 public constant COVERSTATUS_CLAIMINPROGRESS = 2;
    uint256 public constant COVERSTATUS_CLAIMDONE = 3;
    uint256 public constant COVERSTATUS_CANCELLED = 4;

    uint256 public constant CLAIMSTATUS_SUBMITTED = 0;
    uint256 public constant CLAIMSTATUS_INVESTIGATING = 1;
    uint256 public constant CLAIMSTATUS_PREPAREFORVOTING = 2;
    uint256 public constant CLAIMSTATUS_VOTING = 3;
    uint256 public constant CLAIMSTATUS_VOTINGCOMPLETED = 4;
    uint256 public constant CLAIMSTATUS_ABDISCRETION = 5;
    uint256 public constant CLAIMSTATUS_COMPLAINING = 6;
    uint256 public constant CLAIMSTATUS_COMPLAININGCOMPLETED = 7;
    uint256 public constant CLAIMSTATUS_ACCEPTED = 8;
    uint256 public constant CLAIMSTATUS_REJECTED = 9;
    uint256 public constant CLAIMSTATUS_PAYOUTREADY = 10;
    uint256 public constant CLAIMSTATUS_PAID = 11;

    uint256 public constant OUTCOMESTATUS_NONE = 0;
    uint256 public constant OUTCOMESTATUS_ACCEPTED = 1;
    uint256 public constant OUTCOMESTATUS_REJECTED = 2;

    uint256 public constant REFERRALREWARD_NONE = 0;
    uint256 public constant REFERRALREWARD_COVER = 1;
    uint256 public constant REFERRALREWARD_STAKING = 2;
}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface ISecurityMatrix {

    function isAllowdCaller(address _callee, address _caller) external view returns (bool);

}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface IStakersPoolV2 {

    function addStkAmount(address _token, uint256 _amount) external payable;


    function withdrawTokens(
        address payable _to,
        uint256 _amount,
        address _token,
        address _feePool,
        uint256 _fee
    ) external;


    function reCalcPoolPT(address _lpToken) external;


    function settlePendingRewards(address _account, address _lpToken) external;


    function harvestRewards(
        address _account,
        address _lpToken,
        address _to
    ) external returns (uint256);


    function getPoolRewardPerLPToken(address _lpToken) external view returns (uint256);


    function getStakedAmountPT(address _token) external view returns (uint256);


    function showPendingRewards(address _account, address _lpToken) external view returns (uint256);


    function showHarvestRewards(address _account, address _lpToken) external view returns (uint256);


    function getRewardToken() external view returns (address);


    function getRewardPerBlockPerPool(address _lpToken) external view returns (uint256);


    function claimPayout(
        address _fromToken,
        address _paymentToken,
        uint256 _settleAmtPT,
        address _claimToSettlementPool,
        uint256 _claimId,
        uint256 _fromRate,
        uint256 _toRate
    ) external;

}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface ILPToken {

    function proposeToBurn(
        address _account,
        uint256 _amount,
        uint256 _blockWeight
    ) external;


    function mint(
        address _account,
        uint256 _amount,
        uint256 _poolRewardPerLPToken
    ) external;


    function rewardDebtOf(address _account) external view returns (uint256);


    function burnableAmtOf(address _account) external view returns (uint256);


    function burn(
        address _account,
        uint256 _amount,
        uint256 _poolRewardPerLPToken
    ) external;

}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface IStakingV2Controller {

    function stakeTokens(uint256 _amount, address _token) external payable;


    function proposeUnstake(uint256 _amount, address _token) external;


    function withdrawTokens(
        address payable _staker,
        uint256 _amount,
        address _token,
        uint256 _nonce,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external;


    function unlockRewardsFromPoolsByController(
        address staker,
        address _to,
        address[] memory _tokenList
    ) external returns (uint256);


    function showRewardsFromPools(address[] memory _tokenList) external view returns (uint256);

}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;


library Math {

    using SafeMathUpgradeable for uint256;

    function max(uint256 x, uint256 y) internal pure returns (uint256) {

        return x < y ? y : x;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {

        return x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y.div(2).add(1);
            while (x < z) {
                z = x;
                x = (y.div(x).add(x)).div(2);
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function pow(uint256 _base, uint256 _exponent) internal pure returns (uint256) {

        if (_exponent == 0) {
            return 1;
        } else if (_exponent == 1) {
            return _base;
        } else if (_base == 0 && _exponent != 0) {
            return 0;
        } else {
            uint256 z = _base;
            for (uint256 i = 1; i < _exponent; i++) {
                z = z.mul(_base);
            }
            return z;
        }
    }
}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface ICapitalPool {

    function canBuyCoverPerProduct(
        uint256 _productId,
        uint256 _amount,
        address _token
    ) external view returns (bool);


    function canBuyCover(uint256 _amount, address _token) external view returns (bool);


    function buyCoverPerProduct(
        uint256 _productId,
        uint256 _amount,
        address _token
    ) external;


    function hasTokenInStakersPool(address _token) external view returns (bool);


    function getCapacityInfo() external view returns (uint256, uint256);


    function getProductCapacityInfo(uint256[] memory _products)
        external
        view
        returns (
            address,
            uint256[] memory,
            uint256[] memory
        );


    function getProductCapacityRatio(uint256 _productId) external view returns (uint256);


    function getBaseToken() external view returns (address);


    function getCoverAmtPPMaxRatio() external view returns (uint256);


    function getCoverAmtPPInBaseToken(uint256 _productId) external view returns (uint256);


    function settlePaymentForClaim(
        address _token,
        uint256 _amount,
        uint256 _claimId
    ) external;


    function getStakingPercentageX10000() external view returns (uint256);


    function getTVLinBaseToken() external view returns (address, uint256);

}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface IExchangeRate {

    function getBaseCurrency() external view returns (address);


    function setBaseCurrency(address _currency) external;


    function getAllCurrencyArray() external view returns (address[] memory);


    function addCurrencies(
        address[] memory _currencies,
        uint128[] memory _multipliers,
        uint128[] memory _rates
    ) external;


    function removeCurrency(address _currency) external;


    function getAllCurrencyRates() external view returns (uint256[] memory);


    function updateAllCurrencies(uint128[] memory _rates) external;


    function updateCurrency(address _currency, uint128 _rate) external;


    function getTokenToTokenAmount(
        address _fromToken,
        address _toToken,
        uint256 _amount
    ) external view returns (uint256);

}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;


contract StakingV2Controller is IStakingV2Controller, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function initializeStakingV2Controller() public initializer {

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }

    address public stakersPoolV2;
    address public feePool;
    mapping(address => address) public tokenToLPTokenMap;
    uint256 public mapCounter;
    mapping(address => uint256) public minStakeAmtPT;
    mapping(address => uint256) public minUnstakeAmtPT;
    mapping(address => uint256) public maxUnstakeAmtPT;
    mapping(address => uint256) public unstakeLockBlkPT;
    uint256 public constant G_WITHDRAW_FEE_BASE = 10000;
    mapping(address => uint256) public withdrawFeePT;

    address public securityMatrix;
    address public capitalPool;

    mapping(address => uint256) public totalStakedCapPT;
    mapping(address => uint256) public perAccountCapPT;

    address public exchangeRate;

    mapping(address => bool) public signerFlagMap;
    mapping(address => mapping(uint256 => bool)) public nonceFlagMap;

    function setup(
        address _securityMatrix,
        address _stakersPoolV2,
        address _feePool,
        address _capitalPool,
        address _exchangeRate
    ) external onlyOwner {

        require(_securityMatrix != address(0), "S:1");
        require(_stakersPoolV2 != address(0), "S:2");
        require(_feePool != address(0), "S:3");
        require(_capitalPool != address(0), "S:4");
        require(_exchangeRate != address(0), "S:5");
        securityMatrix = _securityMatrix;
        stakersPoolV2 = _stakersPoolV2;
        feePool = _feePool;
        capitalPool = _capitalPool;
        exchangeRate = _exchangeRate;
    }

    modifier allowedCaller() {

        require((ISecurityMatrix(securityMatrix).isAllowdCaller(address(this), _msgSender())) || (_msgSender() == owner()), "allowedCaller");
        _;
    }

    modifier onlyAllowedToken(address _token) {

        address lpToken = tokenToLPTokenMap[_token];
        require(lpToken != address(0), "onlyAllowedToken");
        _;
    }

    function setTokenToLPTokenMap(address _token, address _lpToken) external onlyOwner {

        require(_token != address(0), "STTLPTM:1");
        tokenToLPTokenMap[_token] = _lpToken;
    }

    function setMapCounter(uint256 _mapCounter) external onlyOwner {

        mapCounter = _mapCounter;
    }

    function setStakeInfo(
        address _token,
        uint256 _minStakeAmt,
        uint256 _minUnstakeAmt,
        uint256 _maxUnstakeAmt,
        uint256 _unstakeLockBlk,
        uint256 _withdrawFee
    ) external onlyOwner onlyAllowedToken(_token) {

        require(_token != address(0), "SSI:1");
        minStakeAmtPT[_token] = _minStakeAmt;
        require(_minUnstakeAmt < _maxUnstakeAmt, "SSI:2");
        minUnstakeAmtPT[_token] = _minUnstakeAmt;
        maxUnstakeAmtPT[_token] = _maxUnstakeAmt;
        unstakeLockBlkPT[_token] = _unstakeLockBlk;
        withdrawFeePT[_token] = _withdrawFee;
    }

    function setStakeCap(
        address _token,
        uint256 _totalStakedCapPT,
        uint256 _perAccountCapPT
    ) external onlyOwner onlyAllowedToken(_token) {

        totalStakedCapPT[_token] = _totalStakedCapPT;
        perAccountCapPT[_token] = _perAccountCapPT;
    }

    event SetStakingControllerSignerEvent(address indexed signer, bool enabled);

    function setStakingControllerSigner(address signer, bool enabled) external onlyOwner {

        require(signer != address(0), "SSCS: 1");
        signerFlagMap[signer] = enabled;
        emit SetStakingControllerSignerEvent(signer, enabled);
    }

    function pauseAll() external onlyOwner whenNotPaused {

        _pause();
    }

    function unPauseAll() external onlyOwner whenPaused {

        _unpause();
    }

    event StakeTokensEvent(address indexed _from, address indexed _lpToken, uint256 _deltaAmt, uint256 _balance);
    event StakeTokensEventV2(address indexed _from, address indexed _token, uint256 _amount, address indexed _lpToken, uint256 _deltaAmt, uint256 _balance);

    function stakeTokens(uint256 _amount, address _token) external payable override whenNotPaused nonReentrant onlyAllowedToken(_token) {

        require(minStakeAmtPT[_token] <= _amount, "ST:1");

        address lpToken = tokenToLPTokenMap[_token];
        IStakersPoolV2(stakersPoolV2).reCalcPoolPT(lpToken);
        IStakersPoolV2(stakersPoolV2).settlePendingRewards(_msgSender(), lpToken);
        if (_token == Constant.BCNATIVETOKENADDRESS) {
            require(_amount <= msg.value, "ST:2");
        } else {
            require(IERC20Upgradeable(_token).balanceOf(_msgSender()) >= _amount, "ST:3");
            uint256 allowanceAmt = IERC20Upgradeable(_token).allowance(_msgSender(), address(this));
            require(allowanceAmt >= _amount, "ST:4");
            IERC20Upgradeable(_token).safeTransferFrom(_msgSender(), address(this), _amount);
        }
        uint256 lpTokenAmount = _amount;
        uint256 stakedTokenAmt = IStakersPoolV2(stakersPoolV2).getStakedAmountPT(_token);

        if (stakedTokenAmt > 0) {
            lpTokenAmount = _amount.mul(IERC20Upgradeable(lpToken).totalSupply()).div(stakedTokenAmt);
            require(lpTokenAmount != 0, "ST:5");
        }
        if (_token == Constant.BCNATIVETOKENADDRESS) {
            IStakersPoolV2(stakersPoolV2).addStkAmount{value: _amount}(_token, _amount);
        } else {
            IERC20Upgradeable(_token).safeTransfer(stakersPoolV2, _amount);
            IStakersPoolV2(stakersPoolV2).addStkAmount(_token, _amount);
        }
        uint256 poolRewardPerLPToken = IStakersPoolV2(stakersPoolV2).getPoolRewardPerLPToken(lpToken);
        ILPToken(lpToken).mint(_msgSender(), lpTokenAmount, poolRewardPerLPToken);
        uint256 lpTokenAmtAfterStaked = IERC20Upgradeable(lpToken).balanceOf(_msgSender());
        require(stakedTokenAmt.add(_amount) <= totalStakedCapPT[_token], "ST:6");
        uint256 tokenAmtAfterStaked = lpTokenAmtAfterStaked.mul(stakedTokenAmt.add(_amount)).div(IERC20Upgradeable(lpToken).totalSupply());
        require(tokenAmtAfterStaked <= perAccountCapPT[_token], "ST:7");
        emit StakeTokensEventV2(_msgSender(), _token, _amount, lpToken, lpTokenAmount, IERC20Upgradeable(lpToken).balanceOf(_msgSender()));
    }

    event ProposeUnstakeEvent(address indexed _from, address indexed _token, uint256 _deltaAmt);
    event ProposeUnstakeEventV2(address indexed _from, address indexed _token, uint256 _amount, address indexed _lpToken, uint256 _deltaAmt);

    function proposeUnstake(uint256 _amount, address _token) external override nonReentrant whenNotPaused onlyAllowedToken(_token) {

        require(minUnstakeAmtPT[_token] <= _amount && maxUnstakeAmtPT[_token] >= _amount, "PU:1");
        address lpToken = tokenToLPTokenMap[_token];
        require(IStakersPoolV2(stakersPoolV2).getStakedAmountPT(_token) >= _amount, "PU:2");
        uint256 proposeUnstakeLP = _amount.mul(IERC20Upgradeable(lpToken).totalSupply()).div(IStakersPoolV2(stakersPoolV2).getStakedAmountPT(_token));
        require(proposeUnstakeLP != 0, "PU:3");
        ILPToken(lpToken).proposeToBurn(_msgSender(), proposeUnstakeLP, unstakeLockBlkPT[_token]);
        emit ProposeUnstakeEventV2(_msgSender(), _token, _amount, lpToken, proposeUnstakeLP);
    }

    event WithdrawTokensEvent(address indexed _from, address indexed _token, uint256 _deltaAmt, uint256 _balance);
    event WithdrawTokensEventV2(address indexed _from, address indexed _token, uint256 _amount, address indexed _lpToken, uint256 _deltaAmt, uint256 _balance);

    function withdrawTokens(
        address payable _staker,
        uint256 _amount,
        address _token,
        uint256 _nonce,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external override nonReentrant whenNotPaused onlyAllowedToken(_token) {

        bytes32 msgHash = keccak256(abi.encodePacked(address(this), _staker, _amount, _token, _nonce));
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        address signer = ecrecover(prefixedHash, v[0], r[0], s[0]);
        require(signerFlagMap[signer], "WTKN:1");

        require(!nonceFlagMap[_staker][_nonce], "WTKN:2");
        nonceFlagMap[_staker][_nonce] = true;

        _withdrawTokens(_staker, _amount, _token);
    }

    function _withdrawTokens(
        address payable _staker,
        uint256 _amount,
        address _token
    ) private {

        require(_amount > 0, "WT:1");
        address lpToken = tokenToLPTokenMap[_token];
        IStakersPoolV2(stakersPoolV2).reCalcPoolPT(lpToken);
        IStakersPoolV2(stakersPoolV2).settlePendingRewards(_staker, lpToken);
        uint256 unstakeLP = _amount;
        require(IStakersPoolV2(stakersPoolV2).getStakedAmountPT(_token) != 0, "WT:2");
        unstakeLP = _amount.mul(IERC20Upgradeable(lpToken).totalSupply()).div(IStakersPoolV2(stakersPoolV2).getStakedAmountPT(_token));
        require(unstakeLP != 0, "WT:3");
        uint256 withdrawAmtAfterFee = _amount.mul(G_WITHDRAW_FEE_BASE.sub(withdrawFeePT[_token])).div(G_WITHDRAW_FEE_BASE);
        IStakersPoolV2(stakersPoolV2).withdrawTokens(_staker, withdrawAmtAfterFee, _token, feePool, _amount.sub(withdrawAmtAfterFee));
        uint256 poolRewardPerLPToken = IStakersPoolV2(stakersPoolV2).getPoolRewardPerLPToken(lpToken);
        ILPToken(lpToken).burn(_staker, unstakeLP, poolRewardPerLPToken);
        emit WithdrawTokensEventV2(_staker, _token, _amount, lpToken, unstakeLP, IERC20Upgradeable(lpToken).balanceOf(_staker));
    }

    event UnlockRewardsFromPoolsEvent(address indexed _to, address indexed _token, uint256 _amount);

    function unlockRewardsFromPoolsByController(
        address _staker,
        address _to,
        address[] memory _tokenList
    ) external override allowedCaller whenNotPaused nonReentrant returns (uint256) {

        uint256 delta = _unlockRewardsFromPools(_staker, _to, _tokenList);
        return delta;
    }

    function _unlockRewardsFromPools(
        address staker,
        address _to,
        address[] memory _tokenList
    ) private returns (uint256) {

        require(_to != address(0), "_URFP:1");
        require(_tokenList.length <= mapCounter, "_URFP:2");
        uint256 totalHarvestedAmt = 0;
        for (uint256 i = 0; i < _tokenList.length; i++) {
            address token = _tokenList[i];
            address lpToken = tokenToLPTokenMap[token];
            require(lpToken != address(0), "_URFP:3");
            if (IERC20Upgradeable(lpToken).balanceOf(staker) != 0) {
                IStakersPoolV2(stakersPoolV2).reCalcPoolPT(lpToken);
                IStakersPoolV2(stakersPoolV2).settlePendingRewards(staker, lpToken);
            }
            uint256 harvestedAmt = IStakersPoolV2(stakersPoolV2).harvestRewards(staker, lpToken, _to);
            totalHarvestedAmt = totalHarvestedAmt.add(harvestedAmt);
            if (IERC20Upgradeable(lpToken).balanceOf(staker) != 0) {
                uint256 poolRewardPerLPToken = IStakersPoolV2(stakersPoolV2).getPoolRewardPerLPToken(lpToken);
                ILPToken(lpToken).mint(staker, 0, poolRewardPerLPToken);
            }
            emit UnlockRewardsFromPoolsEvent(staker, token, harvestedAmt);
        }
        return totalHarvestedAmt;
    }

    function showRewardsFromPools(address[] memory _tokenList) external view override returns (uint256) {

        require(_tokenList.length <= mapCounter, "SRFP:1");
        uint256 totalRewards = 0;
        for (uint256 i = 0; i < _tokenList.length; i++) {
            address token = _tokenList[i];
            address lpToken = tokenToLPTokenMap[token];
            require(lpToken != address(0), "SRFP:2");
            uint256 pendingRewards = IStakersPoolV2(stakersPoolV2).showPendingRewards(_msgSender(), lpToken);
            uint256 harvestRewards = IStakersPoolV2(stakersPoolV2).showHarvestRewards(_msgSender(), lpToken);
            totalRewards = totalRewards.add(pendingRewards).add(harvestRewards);
        }
        return totalRewards;
    }

    function getRebalancedPools(
        uint256 _weightTotal,
        uint256 _blockPerYear,
        uint256 _expectedAPYX10000,
        address[] memory _tokenInclusionList,
        address[] memory _tokenExclusionList
    ) external view returns (uint256[] memory weightList_, uint256 rewardPerBlock_) {

        require(_weightTotal >= 100000000, "GRBPL:1");
        require(_blockPerYear > 0, "GRBPL:2");
        require(_expectedAPYX10000 >= 0 && _expectedAPYX10000 <= 10000, "GRBPL:3");
        require(_tokenInclusionList.length + _tokenExclusionList.length == mapCounter, "GRBPL:4");
        uint256[] memory rewardPBPP = new uint256[](_tokenInclusionList.length + _tokenExclusionList.length);
        uint256[] memory retWeightList = new uint256[](rewardPBPP.length);
        uint256 rewardPerBlock = 0;
        uint256 rewardPBPPIndex = 0;
        uint256 expectedAPYX10000 = _expectedAPYX10000;
        uint256 weightTotal = _weightTotal;
        uint256 blockPerYear = _blockPerYear;
        for (uint256 i = 0; i < _tokenInclusionList.length; i++) {
            require(tokenToLPTokenMap[_tokenInclusionList[i]] != address(0), "GRBPL:5");
            uint256 tvlAmt = IStakersPoolV2(stakersPoolV2).getStakedAmountPT(_tokenInclusionList[i]);
            uint256 convertReward = IExchangeRate(exchangeRate).getTokenToTokenAmount(_tokenInclusionList[i], IStakersPoolV2(stakersPoolV2).getRewardToken(), tvlAmt);
            rewardPBPP[rewardPBPPIndex] = expectedAPYX10000.mul(convertReward).div(blockPerYear).div(10000);

            rewardPerBlock = rewardPerBlock.add(rewardPBPP[rewardPBPPIndex]);
            rewardPBPPIndex = rewardPBPPIndex.add(1);
        }

        for (uint256 i = 0; i < _tokenExclusionList.length; i++) {
            require(tokenToLPTokenMap[_tokenExclusionList[i]] != address(0), "GRBPL:6");
            rewardPBPP[rewardPBPPIndex] = IStakersPoolV2(stakersPoolV2).getRewardPerBlockPerPool(tokenToLPTokenMap[_tokenExclusionList[i]]);
            rewardPerBlock = rewardPerBlock.add(rewardPBPP[rewardPBPPIndex]);
            rewardPBPPIndex = rewardPBPPIndex.add(1);
        }

        for (uint256 i = 0; i < rewardPBPP.length; i++) {
            retWeightList[i] = weightTotal.mul(rewardPBPP[i]).div(rewardPerBlock);
        }
        return (retWeightList, rewardPerBlock);
    }
}