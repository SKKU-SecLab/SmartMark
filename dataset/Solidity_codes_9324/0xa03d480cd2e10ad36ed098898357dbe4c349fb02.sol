
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


contract SecurityMatrix is ISecurityMatrix, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function initializeSecurityMatrix() public initializer {

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }

    mapping(address => mapping(address => uint256)) public allowedCallersMap;
    mapping(address => address[]) public allowedCallersArray;
    address[] public allowedCallees;

    function pauseAll() external onlyOwner whenNotPaused {

        _pause();
    }

    function unPauseAll() external onlyOwner whenPaused {

        _unpause();
    }

    function addAllowdCallersPerCallee(address _callee, address[] memory _callers) external onlyOwner {

        require(_callers.length != 0, "AACPC:1");
        require(allowedCallersArray[_callee].length != 0, "AACPC:2");

        for (uint256 index = 0; index < _callers.length; index++) {
            allowedCallersArray[_callee].push(_callers[index]);
            allowedCallersMap[_callee][_callers[index]] = 1;
        }
    }

    function setAllowdCallersPerCallee(address _callee, address[] memory _callers) external onlyOwner {

        require(_callers.length != 0, "SACPC:1");
        if (allowedCallersArray[_callee].length == 0) {
            allowedCallees.push(_callee);
        } else {
            for (uint256 i = 0; i < allowedCallersArray[_callee].length; i++) {
                delete allowedCallersMap[_callee][allowedCallersArray[_callee][i]];
            }
            delete allowedCallersArray[_callee];
        }
        for (uint256 index = 0; index < _callers.length; index++) {
            allowedCallersArray[_callee].push(_callers[index]);
            allowedCallersMap[_callee][_callers[index]] = 1;
        }
    }

    function isAllowdCaller(address _callee, address _caller) external view override whenNotPaused returns (bool) {

        return allowedCallersMap[_callee][_caller] == 1 ? true : false;
    }

    function getAllowedCallees() external view returns (address[] memory) {

        return allowedCallees;
    }

    function getAllowedCallersPerCallee(address _callee) external view returns (address[] memory) {

        return allowedCallersArray[_callee];
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

interface IFeePool {

    function addUnstkFee(address _token, uint256 _fee) external payable;


    function addClaimFee(address _token, uint256 _fee) external payable;


    function addComplainFee(address _token, uint256 _fee) external payable;

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

interface IClaimSettlementPool {

    function addSettlementAmount(address _token, uint256 _fee) external payable;


    function withdrawSettlementAmount(
        address _token,
        address payable _toAddress,
        uint256 _amount
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


contract StakersPoolV2 is IStakersPoolV2, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function initializeStakersPoolV2() public initializer {

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }

    address public securityMatrix;
    address public insurTokenAddress;
    mapping(address => uint256) public stakedAmountPT;
    mapping(address => uint256) public poolLastCalcBlock;
    mapping(address => uint256) public poolWeightPT;
    uint256 public totalPoolWeight;
    mapping(address => uint256) public poolRewardPerLPToken;
    uint256 public rewardStartBlock;
    uint256 public rewardEndBlock;
    uint256 public rewardPerBlock;
    mapping(address => mapping(address => uint256)) public stkRewardsPerAPerLPT;
    mapping(address => mapping(address => uint256)) public harvestedRewardsPerAPerLPT;

    mapping(address => bool) public signerFlagMap;
    mapping(uint256 => bool) public nonceFlagMap;

    function setup(address _securityMatrix, address _insurTokenAddress) external onlyOwner {

        require(_securityMatrix != address(0), "S:1");
        securityMatrix = _securityMatrix;
        require(_insurTokenAddress != address(0), "S:2");
        insurTokenAddress = _insurTokenAddress;
    }

    function setPoolWeight(
        address _lpToken,
        uint256 _poolWeightPT,
        address[] memory _lpTokens
    ) external onlyOwner {

        reCalcAllPools(_lpTokens);
        if (poolWeightPT[_lpToken] != 0) {
            totalPoolWeight = totalPoolWeight.sub(poolWeightPT[_lpToken]);
        }
        poolWeightPT[_lpToken] = _poolWeightPT;
        totalPoolWeight = totalPoolWeight.add(_poolWeightPT);
    }

    event SetRewardInfo(uint256 _rewardStartBlock, uint256 _rewardEndBlock, uint256 _rewardPerBlock);

    function setRewardInfo(
        uint256 _rewardStartBlock,
        uint256 _rewardEndBlock,
        uint256 _rewardPerBlock,
        address[] memory _lpTokens
    ) external onlyOwner {

        require(_rewardStartBlock < _rewardEndBlock, "SRI:1");
        require(block.number < _rewardEndBlock, "SRI:2");
        reCalcAllPools(_lpTokens);
        if (block.number <= rewardEndBlock && block.number >= rewardStartBlock) {
            rewardEndBlock = _rewardEndBlock;
            rewardPerBlock = _rewardPerBlock;
        } else {
            rewardStartBlock = _rewardStartBlock;
            rewardEndBlock = _rewardEndBlock;
            rewardPerBlock = _rewardPerBlock;
        }
        emit SetRewardInfo(_rewardStartBlock, _rewardEndBlock, _rewardPerBlock);
    }

    modifier allowedCaller() {

        require((SecurityMatrix(securityMatrix).isAllowdCaller(address(this), _msgSender())) || (_msgSender() == owner()), "allowedCaller");
        _;
    }

    event StakedAmountPTEvent(address indexed _token, uint256 _amount);

    function getPoolReward(
        uint256 _from,
        uint256 _to,
        uint256 _poolWeight
    ) private view returns (uint256) {

        uint256 start = Math.max(_from, rewardStartBlock);
        uint256 end = Math.min(_to, rewardEndBlock);
        if (end <= start) {
            return 0;
        }
        uint256 deltaBlock = end.sub(start);
        uint256 amount = deltaBlock.mul(rewardPerBlock).mul(_poolWeight).div(totalPoolWeight);
        return amount;
    }

    function reCalcAllPools(address[] memory _lpTokens) private {

        for (uint256 i = 0; i < _lpTokens.length; i++) {
            reCalcPoolPT(_lpTokens[i]);
        }
    }

    function reCalcPoolPT(address _lpToken) public override allowedCaller {

        if (block.number <= poolLastCalcBlock[_lpToken]) {
            return;
        }
        uint256 lpSupply = IERC20Upgradeable(_lpToken).totalSupply();
        if (lpSupply == 0) {
            poolLastCalcBlock[_lpToken] = block.number;
            return;
        }
        uint256 reward = getPoolReward(poolLastCalcBlock[_lpToken], block.number, poolWeightPT[_lpToken]);
        poolRewardPerLPToken[_lpToken] = poolRewardPerLPToken[_lpToken].add(reward.mul(1e18).div(lpSupply));
        poolLastCalcBlock[_lpToken] = block.number;
    }

    function showPendingRewards(address _account, address _lpToken) external view override returns (uint256) {

        uint256 poolRewardPerLPTokenT = 0;
        uint256 userAmt = IERC20Upgradeable(_lpToken).balanceOf(_account);
        uint256 userRewardDebt = ILPToken(_lpToken).rewardDebtOf(_account);
        uint256 lpSupply = IERC20Upgradeable(_lpToken).totalSupply();
        if (block.number == poolLastCalcBlock[_lpToken]) {
            return 0;
        }
        if (block.number > poolLastCalcBlock[_lpToken] && lpSupply > 0) {
            uint256 reward = getPoolReward(poolLastCalcBlock[_lpToken], block.number, poolWeightPT[_lpToken]);

            poolRewardPerLPTokenT = poolRewardPerLPToken[_lpToken].add(reward.mul(1e18).div(lpSupply));
        }
        require(userAmt.mul(poolRewardPerLPTokenT).div(1e18) >= userRewardDebt, "showPR:1");
        return userAmt.mul(poolRewardPerLPTokenT).div(1e18).sub(userRewardDebt);
    }

    function settlePendingRewards(address _account, address _lpToken) external override allowedCaller {

        uint256 userAmt = IERC20Upgradeable(_lpToken).balanceOf(_account);
        uint256 userRewardDebt = ILPToken(_lpToken).rewardDebtOf(_account);
        if (userAmt > 0) {
            uint256 pendingAmt = userAmt.mul(poolRewardPerLPToken[_lpToken]).div(1e18).sub(userRewardDebt);
            if (pendingAmt > 0) {
                stkRewardsPerAPerLPT[_lpToken][_account] = stkRewardsPerAPerLPT[_lpToken][_account].add(pendingAmt);
            }
        }
    }

    function showHarvestRewards(address _account, address _lpToken) external view override returns (uint256) {

        return stkRewardsPerAPerLPT[_lpToken][_account];
    }

    function harvestRewards(
        address _account,
        address _lpToken,
        address _to
    ) external override allowedCaller returns (uint256) {

        uint256 amtHas = stkRewardsPerAPerLPT[_lpToken][_account];
        harvestedRewardsPerAPerLPT[_lpToken][_account] = harvestedRewardsPerAPerLPT[_lpToken][_account].add(amtHas);
        stkRewardsPerAPerLPT[_lpToken][_account] = 0;
        IERC20Upgradeable(insurTokenAddress).safeTransfer(_to, amtHas);
        return amtHas;
    }

    function getPoolRewardPerLPToken(address _lpToken) external view override returns (uint256) {

        return poolRewardPerLPToken[_lpToken];
    }

    function addStkAmount(address _token, uint256 _amount) external payable override allowedCaller {

        if (_token == Constant.BCNATIVETOKENADDRESS) {
            require(msg.value == _amount, "ASA:1");
        }
        stakedAmountPT[_token] = stakedAmountPT[_token].add(_amount);
        emit StakedAmountPTEvent(_token, stakedAmountPT[_token]);
    }

    function getStakedAmountPT(address _token) external view override returns (uint256) {

        return stakedAmountPT[_token];
    }

    function withdrawTokens(
        address payable _to,
        uint256 _withdrawAmtAfterFee,
        address _token,
        address _feePool,
        uint256 _fee
    ) external override allowedCaller {

        require(_withdrawAmtAfterFee.add(_fee) <= stakedAmountPT[_token], "WDT:1");
        require(_withdrawAmtAfterFee > 0, "WDT:2");

        stakedAmountPT[_token] = stakedAmountPT[_token].sub(_withdrawAmtAfterFee);
        stakedAmountPT[_token] = stakedAmountPT[_token].sub(_fee);

        if (_token == Constant.BCNATIVETOKENADDRESS) {
            _to.transfer(_withdrawAmtAfterFee);
        } else {
            IERC20Upgradeable(_token).safeTransfer(_to, _withdrawAmtAfterFee);
        }

        if (_token == Constant.BCNATIVETOKENADDRESS) {
            IFeePool(_feePool).addUnstkFee{value: _fee}(_token, _fee);
        } else {
            IERC20Upgradeable(_token).safeTransfer(_feePool, _fee);
            IFeePool(_feePool).addUnstkFee(_token, _fee);
        }
        emit StakedAmountPTEvent(_token, stakedAmountPT[_token]);
    }

    event ClaimPayoutEvent(address _fromToken, address _paymentToken, uint256 _settleAmtPT, uint256 _claimId, uint256 _fromRate, uint256 _toRate);

    function claimPayout(
        address _fromToken,
        address _paymentToken,
        uint256 _settleAmtPT,
        address _claimToSettlementPool,
        uint256 _claimId,
        uint256 _fromRate,
        uint256 _toRate
    ) external override allowedCaller {

        if (_settleAmtPT == 0) {
            return;
        }
        uint256 amountIn = _settleAmtPT.mul(_fromRate).mul(10**8).div(_toRate).div(10**8);
        require(stakedAmountPT[_fromToken] >= amountIn, "claimP:1");
        stakedAmountPT[_fromToken] = stakedAmountPT[_fromToken].sub(amountIn);
        _transferTokenTo(_fromToken, amountIn, _claimToSettlementPool);
        emit StakedAmountPTEvent(_fromToken, stakedAmountPT[_fromToken]);
        emit ClaimPayoutEvent(_fromToken, _paymentToken, _settleAmtPT, _claimId, _fromRate, _toRate);
    }

    function _transferTokenTo(
        address _paymentToken,
        uint256 _amt,
        address _claimToSettlementPool
    ) private {

        if (_paymentToken == Constant.BCNATIVETOKENADDRESS) {
            IClaimSettlementPool(_claimToSettlementPool).addSettlementAmount{value: _amt}(_paymentToken, _amt);
        } else {
            IERC20Upgradeable(_paymentToken).safeTransfer(_claimToSettlementPool, _amt);
            IClaimSettlementPool(_claimToSettlementPool).addSettlementAmount(_paymentToken, _amt);
        }
    }

    function getRewardToken() external view override returns (address) {

        return insurTokenAddress;
    }

    function getRewardPerBlockPerPool(address _lpToken) external view override returns (uint256) {

        return rewardPerBlock.mul(poolWeightPT[_lpToken]).div(totalPoolWeight);
    }

    function rebalancePools(
        uint256 _rewardPerBlock,
        address[] memory _lpTokens,
        uint256[] memory _weightList,
        uint256 _nonce,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external allowedCaller {

        require(_rewardPerBlock > 0, "RBLNPL:1");
        require(_lpTokens.length == _weightList.length, "RBLNPL:2");
        require(v.length == 2 && r.length == 2 && s.length == 2, "RBLNPL:3");

        require(_checkSignature(address(this), _rewardPerBlock, _lpTokens, _weightList, _nonce, v, r, s), "RBLNPL:4");

        require(!nonceFlagMap[_nonce], "RBLNPL:5");
        nonceFlagMap[_nonce] = true;

        reCalcAllPools(_lpTokens);
        rewardPerBlock = _rewardPerBlock;
        for (uint256 i = 0; i < _lpTokens.length; i++) {
            address lpToken = _lpTokens[i];
            if (poolWeightPT[lpToken] != 0) {
                totalPoolWeight = totalPoolWeight.sub(poolWeightPT[lpToken]);
            }
            poolWeightPT[lpToken] = _weightList[i];
            totalPoolWeight = totalPoolWeight.add(_weightList[i]);
        }
        emit SetRewardInfo(rewardStartBlock, rewardEndBlock, _rewardPerBlock);
    }

    function _checkSignature(
        address _scAddress,
        uint256 _rewardPerBlock,
        address[] memory _lpTokens,
        uint256[] memory _weightList,
        uint256 _nonce,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) internal view returns (bool) {

        bytes32 msgHash = keccak256(abi.encodePacked(_scAddress, _rewardPerBlock, _lpTokens, _weightList, _nonce));
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, msgHash));
        address signer1 = ecrecover(prefixedHash, v[0], r[0], s[0]);
        address signer2 = ecrecover(prefixedHash, v[1], r[1], s[1]);
        return (signer1 != signer2) && signerFlagMap[signer1] && signerFlagMap[signer2];
    }

    event SetStakersPoolSignerEvent(address indexed signer, bool enabled);

    function setStakersPoolSigner(address signer, bool enabled) external onlyOwner {

        require(signer != address(0), "SSPS: 1");
        signerFlagMap[signer] = enabled;
        emit SetStakersPoolSignerEvent(signer, enabled);
    }
}