
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

interface ICoverConfig {

    function getAllValidCurrencyArray() external view returns (address[] memory);


    function isValidCurrency(address currency) external view returns (bool);


    function getMinDurationInDays() external view returns (uint256);


    function getMaxDurationInDays() external view returns (uint256);


    function getMinAmountOfCurrency(address currency) external view returns (uint256);


    function getMaxAmountOfCurrency(address currency) external view returns (uint256);


    function getMaxClaimDurationInDaysAfterExpired() external view returns (uint256);


    function getInsurTokenRewardPercentX10000() external view returns (uint256);

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

interface ICoverData {

    function hasCoverOwner(address owner) external view returns (bool);


    function addCoverOwner(address owner) external;


    function getAllCoverOwnerList() external view returns (address[] memory);


    function getAllCoverCount() external view returns (uint256);


    function getCoverCount(address owner) external view returns (uint256);


    function increaseCoverCount(address owner) external returns (uint256);


    function setNewCoverDetails(
        address owner,
        uint256 coverId,
        uint256 productId,
        uint256 amount,
        address currency,
        uint256 beginTimestamp,
        uint256 endTimestamp,
        uint256 maxClaimableTimestamp,
        uint256 estimatedPremium
    ) external;


    function getCoverBeginTimestamp(address owner, uint256 coverId) external view returns (uint256);


    function setCoverBeginTimestamp(
        address owner,
        uint256 coverId,
        uint256 timestamp
    ) external;


    function getCoverEndTimestamp(address owner, uint256 coverId) external view returns (uint256);


    function setCoverEndTimestamp(
        address owner,
        uint256 coverId,
        uint256 timestamp
    ) external;


    function getCoverMaxClaimableTimestamp(address owner, uint256 coverId) external view returns (uint256);


    function setCoverMaxClaimableTimestamp(
        address owner,
        uint256 coverId,
        uint256 timestamp
    ) external;


    function getCoverProductId(address owner, uint256 coverId) external view returns (uint256);


    function setCoverProductId(
        address owner,
        uint256 coverId,
        uint256 productId
    ) external;


    function getCoverCurrency(address owner, uint256 coverId) external view returns (address);


    function setCoverCurrency(
        address owner,
        uint256 coverId,
        address currency
    ) external;


    function getCoverAmount(address owner, uint256 coverId) external view returns (uint256);


    function setCoverAmount(
        address owner,
        uint256 coverId,
        uint256 amount
    ) external;


    function getAdjustedCoverStatus(address owner, uint256 coverId) external view returns (uint256);


    function setCoverStatus(
        address owner,
        uint256 coverId,
        uint256 coverStatus
    ) external;


    function isCoverClaimable(address owner, uint256 coverId) external view returns (bool);


    function getCoverEstimatedPremiumAmount(address owner, uint256 coverId) external view returns (uint256);


    function setCoverEstimatedPremiumAmount(
        address owner,
        uint256 coverId,
        uint256 amount
    ) external;


    function getBuyCoverInsurTokenEarned(address owner) external view returns (uint256);


    function increaseBuyCoverInsurTokenEarned(address owner, uint256 amount) external;


    function decreaseBuyCoverInsurTokenEarned(address owner, uint256 amount) external;


    function getTotalInsurTokenRewardAmount() external view returns (uint256);


    function increaseTotalInsurTokenRewardAmount(uint256 amount) external;


    function decreaseTotalInsurTokenRewardAmount(uint256 amount) external;


    function getCoverRewardPctg(address owner, uint256 coverId) external view returns (uint256);


    function setCoverRewardPctg(
        address owner,
        uint256 coverId,
        uint256 rewardPctg
    ) external;


    function getCoverClaimedAmount(address owner, uint256 coverId) external view returns (uint256);


    function increaseCoverClaimedAmount(
        address owner,
        uint256 coverId,
        uint256 amount
    ) external;


    function getCoverReferralRewardPctg(address owner, uint256 coverId) external view returns (uint256);


    function setCoverReferralRewardPctg(
        address owner,
        uint256 coverId,
        uint256 referralRewardPctg
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

interface ICoverQuotation {

    function getGrossUnitCost(uint256 productId) external view returns (uint256);


    function getGrossUnitCosts(uint256[] memory products) external view returns (uint256[] memory);


    function getAllGrossUnitCosts() external view returns (uint256[] memory, uint256[] memory);


    function getPremium(
        uint256[] memory products,
        uint256[] memory durationInDays,
        uint256[] memory amounts,
        address currency
    ) external view returns (uint256, uint256);

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


    function getBaseToken() external view returns (address);


    function getCoverAmtPPMaxRatio() external view returns (uint256);


    function getCoverAmtPPInBaseToken(uint256 _productId) external view returns (uint256);


    function settlePaymentForClaim(
        address _token,
        uint256 _amount,
        uint256 _claimId
    ) external;


    function getStakingPercentageX10000() external view returns (uint256);


    function getTVLinBaseToken() external view returns (uint256);

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

interface IPremiumPool {

    function addPremiumAmount(address _token, uint256 _amount) external payable;


    function getPremiumPoolAmtInPaymentToken(address _paymentToken) external view returns (uint256);


    function settlePayoutFromPremium(
        address _paymentToken,
        uint256 _settleAmt,
        address _claimToSettlementPool
    ) external returns (uint256);

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

interface IReferralProgram {

    function getReferralINSURRewardPctg(uint256 rewardType) external view returns (uint256);


    function setReferralINSURRewardPctg(uint256 rewardType, uint256 percent) external;


    function getReferralINSURRewardAmount() external view returns (uint256);


    function getTotalReferralINSURRewardAmount() external view returns (uint256);


    function getRewardPctg(uint256 rewardType, uint256 overwrittenRewardPctg) external view returns (uint256);


    function getRewardAmount(
        uint256 rewardType,
        uint256 baseAmount,
        uint256 overwrittenRewardPctg
    ) external view returns (uint256);


    function processReferralReward(
        address referrer,
        address referee,
        uint256 rewardType,
        uint256 baseAmount,
        uint256 rewardPctg
    ) external;


    function unlockRewardByController(address referrer, address to) external returns (uint256);


    function getINSURRewardBalanceDetails() external view returns (uint256, uint256);


    function removeINSURRewardBalance(address toAddress, uint256 amount) external;

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

interface IProduct {

    function getProductCount() external view returns (uint256);


    function getProductDelayEffectiveDays(uint256 productId) external view returns (uint256);


    function getProductStatus(uint256 productId) external view returns (uint256);


    function getProductDetails(uint256 productId)
        external
        view
        returns (
            bytes32,
            bytes32,
            bytes32,
            uint256,
            uint256
        );


    function getAllProductDetails()
        external
        view
        returns (
            uint256[] memory,
            bytes32[] memory,
            bytes32[] memory,
            bytes32[] memory,
            uint256[] memory,
            uint256[] memory
        );

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

interface ICover {

    function getPremium(
        uint256[] memory products,
        uint256[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address owner,
        uint256 referralCode,
        uint256[] memory rewardPercentages
    )
        external
        view
        returns (
            uint256,
            uint256[] memory,
            uint256,
            uint256[] memory
        );


    function buyCover(
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address owner,
        uint256 referralCode,
        uint256 premiumAmount,
        uint256[] memory helperParameters,
        uint256[] memory securityParameters,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external payable;


    function unlockRewardByController(address owner, address to) external returns (uint256);


    function getRewardAmount() external view returns (uint256);


    function getCoverOwnerRewardAmount(uint256 premiumAmount2Insur, uint256 overwrittenRewardPctg) external view returns (uint256, uint256);


    function getINSURRewardBalanceDetails() external view returns (uint256, uint256);


    function removeINSURRewardBalance(address toAddress, uint256 amount) external;


    function setBuyCoverMaxBlkNumLatency(uint256 numOfBlocks) external;


    function setBuyCoverSigner(address signer, bool enabled) external;

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



contract Cover is ICover, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    address public smx;
    address public data;
    address public cfg;
    address public quotation;
    address public capitalPool;
    address public premiumPool;
    address public insur;

    uint256 public buyCoverMaxBlkNumLatency;
    mapping(address => bool) public buyCoverSignerFlagMap;
    mapping(address => mapping(uint256 => bool)) public buyCoverNonceFlagMap;

    address public exchangeRate;

    address public referralProgram;

    address public product;

    function initialize() public initializer {

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function setup(
        address securityMatrixAddress,
        address insurTokenAddress,
        address _coverDataAddress,
        address _coverCfgAddress,
        address _coverQuotationAddress,
        address _capitalPool,
        address _premiumPool,
        address _exchangeRate,
        address _referralProgram,
        address _productAddress
    ) external onlyOwner {

        require(securityMatrixAddress != address(0), "S:1");
        require(insurTokenAddress != address(0), "S:2");
        require(_coverDataAddress != address(0), "S:3");
        require(_coverCfgAddress != address(0), "S:4");
        require(_coverQuotationAddress != address(0), "S:5");
        require(_capitalPool != address(0), "S:6");
        require(_premiumPool != address(0), "S:7");
        require(_exchangeRate != address(0), "S:8");
        require(_referralProgram != address(0), "S:9");
        require(_productAddress != address(0), "S:10");
        smx = securityMatrixAddress;
        insur = insurTokenAddress;
        data = _coverDataAddress;
        cfg = _coverCfgAddress;
        quotation = _coverQuotationAddress;
        capitalPool = _capitalPool;
        premiumPool = _premiumPool;
        exchangeRate = _exchangeRate;
        referralProgram = _referralProgram;
        product = _productAddress;
    }

    function pauseAll() external onlyOwner whenNotPaused {

        _pause();
    }

    function unPauseAll() external onlyOwner whenPaused {

        _unpause();
    }

    modifier allowedCaller() {

        require((ISecurityMatrix(smx).isAllowdCaller(address(this), _msgSender())) || (_msgSender() == owner()), "allowedCaller");
        _;
    }

    function getPremium(
        uint256[] memory products,
        uint256[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address owner,
        uint256 referralCode,
        uint256[] memory rewardPercentages
    )
        external
        view
        override
        returns (
            uint256,
            uint256[] memory,
            uint256,
            uint256[] memory
        )
    {

        require(products.length == durationInDays.length, "GPCHK: 1");
        require(products.length == amounts.length, "GPCHK: 2");

        require(ICoverConfig(cfg).isValidCurrency(currency), "GPCHK: 3");

        require(owner != address(0), "GPCHK: 4");
        require(address(uint160(referralCode)) != address(0), "GPCHK: 5");

        uint256[] memory helperParameters = new uint256[](2);
        helperParameters[0] = 0;
        helperParameters[1] = 0;
        for (uint256 i = 0; i < products.length; i++) {
            helperParameters[0] = helperParameters[0].add(amounts[i]);
            helperParameters[1] = helperParameters[1].add(amounts[i].mul(durationInDays[i]));
            require(ICapitalPool(capitalPool).canBuyCoverPerProduct(products[i], amounts[i], currency), "GPCHK: 6");
        }

        require(ICapitalPool(capitalPool).canBuyCover(helperParameters[0], currency), "GPCHK: 7");

        uint256 premiumAmount = 0;
        uint256 discountPercent = 0;
        (premiumAmount, discountPercent) = ICoverQuotation(quotation).getPremium(products, durationInDays, amounts, currency);
        require(premiumAmount > 0, "GPCHK: 8");

        require(rewardPercentages.length == 2, "GPCHK: 9");
        uint256[] memory insurRewardAmounts = new uint256[](2);

        uint256 premiumAmount2Insur = IExchangeRate(exchangeRate).getTokenToTokenAmount(currency, insur, premiumAmount);
        if (premiumAmount2Insur > 0 && owner != address(uint160(referralCode))) {
            uint256 coverOwnerRewardPctg = _getRewardPctg(rewardPercentages[0]);
            insurRewardAmounts[0] = _getRewardAmount(premiumAmount2Insur, coverOwnerRewardPctg);
            uint256 referralRewardPctg = IReferralProgram(referralProgram).getRewardPctg(Constant.REFERRALREWARD_COVER, rewardPercentages[1]);
            insurRewardAmounts[1] = IReferralProgram(referralProgram).getRewardAmount(Constant.REFERRALREWARD_COVER, premiumAmount2Insur, referralRewardPctg);
        } else {
            insurRewardAmounts[0] = 0;
            insurRewardAmounts[1] = 0;
        }

        return (premiumAmount, helperParameters, discountPercent, insurRewardAmounts);
    }

    event BuyCoverEvent(address indexed currency, address indexed owner, uint256 coverId, uint256 productId, uint256 durationInDays, uint256 extendedClaimDays, uint256 coverAmount, uint256 estimatedPremium, uint256 coverStatus);

    event BuyCoverEventV2(address indexed currency, address indexed owner, uint256 coverId, uint256 productId, uint256 durationInDays, uint256 extendedClaimDays, uint256 coverAmount, uint256 estimatedPremium, uint256 coverStatus, uint256 delayEffectiveDays);

    event BuyCoverOwnerRewardEvent(address indexed owner, uint256 rewardPctg, uint256 insurRewardAmt);

    function buyCover(
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address owner,
        uint256 referralCode,
        uint256 premiumAmount,
        uint256[] memory helperParameters,
        uint256[] memory securityParameters,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external payable override whenNotPaused nonReentrant {

        require(products.length == durationInDays.length, "BC: 1");
        require(products.length == amounts.length, "BC: 2");

        require(ICoverConfig(cfg).isValidCurrency(currency), "BC: 3");

        require(owner != address(0), "BC: 4");
        require(address(uint160(referralCode)) != address(0), "BC: 5");

        require(helperParameters.length == 4, "BC: 6");

        require(securityParameters.length == 2, "BC: 7");

        require((block.number >= securityParameters[0]) && (block.number - securityParameters[0] <= buyCoverMaxBlkNumLatency), "BC: 8");

        require(_checkSignature(address(this), products, durationInDays, amounts, currency, owner, referralCode, premiumAmount, helperParameters, securityParameters, v, r, s), "BC: 9");

        require(!buyCoverNonceFlagMap[owner][securityParameters[1]], "BC: 10");
        buyCoverNonceFlagMap[owner][securityParameters[1]] = true;

        if (currency == Constant.BCNATIVETOKENADDRESS) {
            require(premiumAmount <= msg.value, "BC: 11");
            IPremiumPool(premiumPool).addPremiumAmount{value: premiumAmount}(currency, premiumAmount);
        } else {
            require(IERC20Upgradeable(currency).balanceOf(_msgSender()) >= premiumAmount, "BC: 12");
            require(IERC20Upgradeable(currency).allowance(_msgSender(), address(this)) >= premiumAmount, "BC: 13");
            IERC20Upgradeable(currency).safeTransferFrom(_msgSender(), address(this), premiumAmount);
            IERC20Upgradeable(currency).safeTransfer(premiumPool, premiumAmount);
            IPremiumPool(premiumPool).addPremiumAmount(currency, premiumAmount);
        }

        _processCovers(products, durationInDays, amounts, currency, owner, referralCode, premiumAmount, helperParameters);
    }

    function _checkSignature(
        address scAddress,
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address owner,
        uint256 referralCode,
        uint256 premiumAmount,
        uint256[] memory helperParameters,
        uint256[] memory securityParameters,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) internal view returns (bool) {

        bytes32 msgHash = "msgHash";
        {
            bytes memory msg1 = abi.encodePacked(scAddress, products, durationInDays, amounts, currency);
            bytes memory msg2 = abi.encodePacked(owner, referralCode, premiumAmount, helperParameters, securityParameters);
            msgHash = keccak256(abi.encodePacked(msg1, msg2));
        }
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, msgHash));
        address signer1 = ecrecover(prefixedHash, v[0], r[0], s[0]);
        return buyCoverSignerFlagMap[signer1];
    }

    function _processCovers(
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address owner,
        uint256 referralCode,
        uint256 premiumAmount,
        uint256[] memory helperParameters
    ) internal {

        uint256 ownerRewardPctg = 0;
        uint256 referralRewardPctg = 0;

        if (owner != address(uint160(referralCode))) {
            uint256 premiumAmount2Insur = IExchangeRate(exchangeRate).getTokenToTokenAmount(currency, insur, premiumAmount);
            ownerRewardPctg = _getRewardPctg(helperParameters[2]);
            _processCoverOwnerReward(owner, premiumAmount2Insur, ownerRewardPctg);
            referralRewardPctg = IReferralProgram(referralProgram).getRewardPctg(Constant.REFERRALREWARD_COVER, helperParameters[3]);
            IReferralProgram(referralProgram).processReferralReward(address(uint160(referralCode)), owner, Constant.REFERRALREWARD_COVER, premiumAmount2Insur, referralRewardPctg);
        }

        uint256[] memory capacities = new uint256[](2);
        (capacities[0], capacities[1]) = ICapitalPool(capitalPool).getCapacityInfo();
        _createCovers(owner, currency, premiumAmount, products, durationInDays, amounts, capacities, helperParameters, ownerRewardPctg, referralRewardPctg);
    }

    function _createCovers(
        address owner,
        address currency,
        uint256 premiumAmount,
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        uint256[] memory capacities,
        uint256[] memory helperParameters,
        uint256 ownerRewardPctg,
        uint256 referralRewardPctg
    ) internal {

        require(IExchangeRate(exchangeRate).getTokenToTokenAmount(currency, ICapitalPool(capitalPool).getBaseToken(), helperParameters[0]) <= capacities[0], "BCC: 1");
        uint256 cumPremiumAmount = 0;
        for (uint256 index = 0; index < products.length; ++index) {
            require(IExchangeRate(exchangeRate).getTokenToTokenAmount(currency, ICapitalPool(capitalPool).getBaseToken(), amounts[index]).add(ICapitalPool(capitalPool).getCoverAmtPPInBaseToken(products[index])) <= capacities[1].mul(ICapitalPool(capitalPool).getCoverAmtPPMaxRatio()).div(10000), "BCC: 2");
            ICapitalPool(capitalPool).buyCoverPerProduct(products[index], amounts[index], currency);

            uint256 estimatedPremium = 0;
            if (index == products.length.sub(1)) {
                estimatedPremium = premiumAmount.sub(cumPremiumAmount);
            } else {
                uint256 currentWeight = amounts[index].mul(durationInDays[index]);
                estimatedPremium = currentWeight.mul(10000).div(helperParameters[1]).mul(premiumAmount).div(10000);
                cumPremiumAmount = cumPremiumAmount.add(estimatedPremium);
            }

            _createOneCover(owner, currency, products[index], durationInDays[index], amounts[index], estimatedPremium, ownerRewardPctg, referralRewardPctg);
        }
    }

    function _createOneCover(
        address owner,
        address currency,
        uint256 productId,
        uint256 durationInDays,
        uint256 amount,
        uint256 estimatedPremium,
        uint256 ownerRewardPctg,
        uint256 referralRewardPctg
    ) internal {

        uint256 beginTimestamp = block.timestamp.add(IProduct(product).getProductDelayEffectiveDays(productId) * 1 days); // solhint-disable-line not-rely-on-time
        uint256 endTimestamp = beginTimestamp.add(durationInDays * 1 days);
        uint256 nextCoverId = ICoverData(data).increaseCoverCount(owner);
        ICoverData(data).setNewCoverDetails(owner, nextCoverId, productId, amount, currency, beginTimestamp, endTimestamp, endTimestamp.add(ICoverConfig(cfg).getMaxClaimDurationInDaysAfterExpired() * 1 days), estimatedPremium);

        if (ownerRewardPctg > 0) {
            ICoverData(data).setCoverRewardPctg(owner, nextCoverId, ownerRewardPctg);
        }

        if (referralRewardPctg > 0) {
            ICoverData(data).setCoverReferralRewardPctg(owner, nextCoverId, referralRewardPctg);
        }

        uint256 delayEffectiveDays = IProduct(product).getProductDelayEffectiveDays(productId);
        emit BuyCoverEventV2(currency, owner, nextCoverId, productId, durationInDays, ICoverConfig(cfg).getMaxClaimDurationInDaysAfterExpired(), amount, estimatedPremium, Constant.COVERSTATUS_ACTIVE, delayEffectiveDays);
    }

    event UnlockCoverRewardEvent(address indexed owner, uint256 amount);

    function unlockRewardByController(address _owner, address _to) external override allowedCaller whenNotPaused nonReentrant returns (uint256) {

        return _unlockReward(_owner, _to);
    }

    function _unlockReward(address owner, address to) internal returns (uint256) {

        uint256 toBeunlockedAmt = ICoverData(data).getBuyCoverInsurTokenEarned(owner);
        if (toBeunlockedAmt > 0) {
            ICoverData(data).decreaseTotalInsurTokenRewardAmount(toBeunlockedAmt);
            ICoverData(data).decreaseBuyCoverInsurTokenEarned(owner, toBeunlockedAmt);
            IERC20Upgradeable(insur).safeTransfer(to, toBeunlockedAmt);
            emit UnlockCoverRewardEvent(owner, toBeunlockedAmt);
        }
        return toBeunlockedAmt;
    }

    function getRewardAmount() external view override returns (uint256) {

        return ICoverData(data).getBuyCoverInsurTokenEarned(_msgSender());
    }

    function getCoverOwnerRewardAmount(uint256 premiumAmount2Insur, uint256 overwrittenRewardPctg) external view override returns (uint256, uint256) {

        uint256 rewardPctg = _getRewardPctg(overwrittenRewardPctg);
        uint256 rewardAmount = _getRewardAmount(premiumAmount2Insur, rewardPctg);
        return (rewardPctg, rewardAmount);
    }

    function _getRewardPctg(uint256 overwrittenRewardPctg) internal view returns (uint256) {

        return overwrittenRewardPctg > 0 ? overwrittenRewardPctg : ICoverConfig(cfg).getInsurTokenRewardPercentX10000();
    }

    function _getRewardAmount(uint256 premiumAmount2Insur, uint256 rewardPctg) internal pure returns (uint256) {

        return rewardPctg <= 10000 ? premiumAmount2Insur.mul(rewardPctg).div(10**4) : 0;
    }

    function _processCoverOwnerReward(
        address owner,
        uint256 premiumAmount2Insur,
        uint256 rewardPctg
    ) internal {

        require(rewardPctg <= 10000, "PCORWD: 1");
        uint256 rewardAmount = _getRewardAmount(premiumAmount2Insur, rewardPctg);
        if (rewardAmount > 0) {
            ICoverData(data).increaseTotalInsurTokenRewardAmount(rewardAmount);
            ICoverData(data).increaseBuyCoverInsurTokenEarned(owner, rewardAmount);
            emit BuyCoverOwnerRewardEvent(owner, rewardPctg, rewardAmount);
        }
    }

    function getINSURRewardBalanceDetails() external view override returns (uint256, uint256) {

        uint256 insurRewardBalance = IERC20Upgradeable(insur).balanceOf(address(this));
        uint256 totalRewardRequired = ICoverData(data).getTotalInsurTokenRewardAmount();
        return (insurRewardBalance, totalRewardRequired);
    }

    function removeINSURRewardBalance(address toAddress, uint256 amount) external override onlyOwner {

        IERC20Upgradeable(insur).safeTransfer(toAddress, amount);
    }

    event SetBuyCoverMaxBlkNumLatencyEvent(uint256 numOfBlocks);

    function setBuyCoverMaxBlkNumLatency(uint256 numOfBlocks) external override onlyOwner {

        require(numOfBlocks > 0, "SBCMBNL: 1");
        buyCoverMaxBlkNumLatency = numOfBlocks;
        emit SetBuyCoverMaxBlkNumLatencyEvent(numOfBlocks);
    }

    event SetBuyCoverSignerEvent(address indexed signer, bool enabled);

    function setBuyCoverSigner(address signer, bool enabled) external override onlyOwner {

        require(signer != address(0), "SBCS: 1");
        buyCoverSignerFlagMap[signer] = enabled;
        emit SetBuyCoverSignerEvent(signer, enabled);
    }
}