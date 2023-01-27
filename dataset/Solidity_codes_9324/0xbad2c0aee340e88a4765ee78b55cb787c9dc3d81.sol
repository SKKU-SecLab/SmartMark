
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
}// MIT

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

    function product() external returns (address);


    function smx() external returns (address);


    function data() external returns (address);


    function cfg() external returns (address);


    function quotation() external returns (address);


    function capitalPool() external returns (address);


    function premiumPool() external returns (address);


    function insur() external returns (address);


    function buyCoverMaxBlkNumLatency() external returns (uint256);


    function exchangeRate() external returns (address);


    function referralProgram() external returns (address);


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


    function unlockRewardByController(address owner, address to)
        external
        returns (uint256);


    function getRewardAmount() external view returns (uint256);


    function getCoverOwnerRewardAmount(
        uint256 premiumAmount2Insur,
        uint256 overwrittenRewardPctg
    ) external view returns (uint256, uint256);


    function getINSURRewardBalanceDetails()
        external
        view
        returns (uint256, uint256);


    function removeINSURRewardBalance(address toAddress, uint256 amount)
        external;


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


    function getCoverBeginTimestamp(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function setCoverBeginTimestamp(
        address owner,
        uint256 coverId,
        uint256 timestamp
    ) external;


    function getCoverEndTimestamp(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function setCoverEndTimestamp(
        address owner,
        uint256 coverId,
        uint256 timestamp
    ) external;


    function getCoverMaxClaimableTimestamp(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function setCoverMaxClaimableTimestamp(
        address owner,
        uint256 coverId,
        uint256 timestamp
    ) external;


    function getCoverProductId(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function setCoverProductId(
        address owner,
        uint256 coverId,
        uint256 productId
    ) external;


    function getCoverCurrency(address owner, uint256 coverId)
        external
        view
        returns (address);


    function setCoverCurrency(
        address owner,
        uint256 coverId,
        address currency
    ) external;


    function getCoverAmount(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function setCoverAmount(
        address owner,
        uint256 coverId,
        uint256 amount
    ) external;


    function getAdjustedCoverStatus(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function setCoverStatus(
        address owner,
        uint256 coverId,
        uint256 coverStatus
    ) external;


    function isCoverClaimable(address owner, uint256 coverId)
        external
        view
        returns (bool);


    function getCoverEstimatedPremiumAmount(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function setCoverEstimatedPremiumAmount(
        address owner,
        uint256 coverId,
        uint256 amount
    ) external;


    function getBuyCoverInsurTokenEarned(address owner)
        external
        view
        returns (uint256);


    function increaseBuyCoverInsurTokenEarned(address owner, uint256 amount)
        external;


    function decreaseBuyCoverInsurTokenEarned(address owner, uint256 amount)
        external;


    function getTotalInsurTokenRewardAmount() external view returns (uint256);


    function increaseTotalInsurTokenRewardAmount(uint256 amount) external;


    function decreaseTotalInsurTokenRewardAmount(uint256 amount) external;


    function getCoverRewardPctg(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function setCoverRewardPctg(
        address owner,
        uint256 coverId,
        uint256 rewardPctg
    ) external;


    function getCoverClaimedAmount(address owner, uint256 coverId)
        external
        view
        returns (uint256);


    function increaseCoverClaimedAmount(
        address owner,
        uint256 coverId,
        uint256 amount
    ) external;


    function getCoverReferralRewardPctg(address owner, uint256 coverId)
        external
        view
        returns (uint256);


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

interface IProduct {

    function getProductCount() external view returns (uint256);


    function getProductDelayEffectiveDays(uint256 productId)
        external
        view
        returns (uint256);


    function getProductStatus(uint256 productId)
        external
        view
        returns (uint256);


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

interface ICoverQuotation {

    function getGrossUnitCost(uint256 productId)
        external
        view
        returns (uint256);


    function getGrossUnitCosts(uint256[] memory products)
        external
        view
        returns (uint256[] memory);


    function getAllGrossUnitCosts()
        external
        view
        returns (uint256[] memory, uint256[] memory);


    function getPremium(
        uint256[] memory products,
        uint256[] memory durationInDays,
        uint256[] memory amounts,
        address currency
    ) external view returns (uint256, uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// GPL-3.0
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

interface IDistributor is IERC165Upgradeable {

    struct Cover {
        bytes32 coverType;
        uint256 productId;
        bytes32 contractName;
        uint256 coverAmount;
        uint256 premium;
        address currency;
        address contractAddress;
        uint256 expiration;
        uint256 status;
        address refAddress;
    }

    struct CoverQuote {
        uint256 prop1;
        uint256 prop2;
        uint256 prop3;
        uint256 prop4;
        uint256 prop5;
        uint256 prop6;
        uint256 prop7;
    }

    struct BuyInsuraceQuote {
        uint16[] products;
        uint16[] durationInDays;
        uint256[] amounts;
        address currency;
        uint256 premium;
        address owner;
        uint256 refCode;
        uint256[] helperParameters;
        uint256[] securityParameters;
        uint8[] v;
        bytes32[] r;
        bytes32[] s;
    }

    function getCoverCount(address _userAddr, bool _isActive)
        external
        view
        returns (uint256);


    function getCover(
        address _owner,
        uint256 _coverId,
        bool _isActive,
        uint256 _loopLimit
    ) external view returns (IDistributor.Cover memory);


    function getQuote(
        uint256 _sumAssured,
        uint256 _coverPeriod,
        address _contractAddress,
        address _coverAsset,
        address _nexusCoverable,
        bytes calldata _data
    ) external view returns (IDistributor.CoverQuote memory);

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}/*
    Copyright 2020 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity ^0.7.4;


library PreciseUnitMath {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 internal constant PRECISE_UNIT = 10**18;
    int256 internal constant PRECISE_UNIT_INT = 10**18;

    uint256 internal constant MAX_UINT_256 = type(uint256).max;
    int256 internal constant MAX_INT_256 = type(int256).max;
    int256 internal constant MIN_INT_256 = type(int256).min;

    function preciseUnit() internal pure returns (uint256) {

        return PRECISE_UNIT;
    }

    function preciseUnitInt() internal pure returns (int256) {

        return PRECISE_UNIT_INT;
    }

    function maxUint256() internal pure returns (uint256) {

        return MAX_UINT_256;
    }

    function maxInt256() internal pure returns (int256) {

        return MAX_INT_256;
    }

    function minInt256() internal pure returns (int256) {

        return MIN_INT_256;
    }

    function preciseMul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(b).div(PRECISE_UNIT);
    }

    function preciseMul(int256 a, int256 b) internal pure returns (int256) {

        return a.mul(b).div(PRECISE_UNIT_INT);
    }

    function preciseMulCeil(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (a == 0 || b == 0) {
            return 0;
        }
        return a.mul(b).sub(1).div(PRECISE_UNIT).add(1);
    }

    function preciseDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(PRECISE_UNIT).div(b);
    }

    function preciseDiv(int256 a, int256 b) internal pure returns (int256) {

        return a.mul(PRECISE_UNIT_INT).div(b);
    }

    function preciseDivCeil(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        require(b != 0, "Cant divide by 0");

        return a > 0 ? a.mul(PRECISE_UNIT).sub(1).div(b).add(1) : 0;
    }

    function divDown(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "Cant divide by 0");
        require(a != MIN_INT_256 || b != -1, "Invalid input");

        int256 result = a.div(b);
        if (a ^ b < 0 && a % b != 0) {
            result -= 1;
        }

        return result;
    }

    function conservativePreciseMul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        return divDown(a.mul(b), PRECISE_UNIT_INT);
    }

    function conservativePreciseDiv(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        return divDown(a.mul(PRECISE_UNIT_INT), b);
    }

    function safePower(uint256 a, uint256 pow) internal pure returns (uint256) {

        require(a > 0, "Value must be positive");

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++) {
            uint256 previousResult = result;

            result = previousResult.mul(a);
        }

        return result;
    }

    function approximatelyEquals(
        uint256 a,
        uint256 b,
        uint256 range
    ) internal pure returns (bool) {

        return a <= b.add(range) && a >= b.sub(range);
    }
}// MIT
pragma solidity ^0.7.4;

interface IPriceFeed {

    function getUniswapRouter() external view returns (address);


    function chainlinkAggregators(address _token)
        external
        view
        returns (address);


    function internalPriceFeed(address _token) external view returns (uint256);


    function howManyTokensAinB(
        address tokenA,
        address tokenB,
        address via,
        uint256 amount,
        bool viewOnly
    ) external view returns (uint256);

}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function WETH() external pure override returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}// MIT
pragma solidity ^0.7.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}// GPL-3.0
pragma solidity 0.7.4;

abstract contract AbstractDistributor {
    using SafeMathUpgradeable for uint256;
    event BuyCoverEvent(
        address _productAddress,
        uint256 _productId,
        uint256 _period,
        address _asset,
        uint256 _amount,
        uint256 _price
    );

    uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds*//*
    uint256 constant MAX_INT = type(uint256).max;

    uint256 constant DECIMALS18 = 10**18;

    uint256 constant PRECISION = 10**25;
    uint256 constant PERCENTAGE_100 = 100 * PRECISION;

    uint256 constant BLOCKS_PER_DAY = 6450;
    uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

    uint256 constant APY_TOKENS = DECIMALS18;
    address constant ETH = (0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function _swapTokenForToken(
        address _priceFeed,
        uint256 _amountIn,
        address _from,
        address _to,
        address _via
    ) internal returns (uint256) {
        if (_amountIn == 0) {
            return 0;
        }

        address[] memory pairs;

        if (_via == address(0)) {
            pairs = new address[](2);
            pairs[0] = _from;
            pairs[1] = _to;
        } else {
            pairs = new address[](3);
            pairs[0] = _from;
            pairs[1] = _via;
            pairs[2] = _to;
        }

        uint256 _expectedOut = IPriceFeed(_priceFeed).howManyTokensAinB(
            _to,
            _from,
            _via,
            _amountIn,
            false
        );
        uint256 _amountOutMin = _expectedOut.mul(99).div(100);
        address _uniswapRouter = IPriceFeed(_priceFeed).getUniswapRouter();

        return
            IUniswapV2Router02(_uniswapRouter).swapExactTokensForTokens(
                _amountIn,
                _amountOutMin,
                pairs,
                address(this),
                block.timestamp.add(600)
            )[pairs.length.sub(1)];
    }

    function _swapExactETHForTokens(
        address _priceFeed,
        address _token,
        uint256 _amountIn
    ) internal returns (uint256) {
        IUniswapV2Router02 _uniswapRouter = IUniswapV2Router02(
            IPriceFeed(_priceFeed).getUniswapRouter()
        );
        address _wethToken = _uniswapRouter.WETH();
        address[] memory pairs = new address[](2);
        pairs[0] = address(_wethToken);
        pairs[1] = address(_token);

        uint256 _expectedOut;
        address _tokenFeed = IPriceFeed(_priceFeed).chainlinkAggregators(
            _token
        );
        if (_tokenFeed != address(0)) {
            (, int256 _price, , , ) = AggregatorV3Interface(_tokenFeed)
                .latestRoundData();
            _expectedOut = uint256(_price).mul(_amountIn).div(10**18);
        } else {
            _expectedOut = IPriceFeed(_priceFeed).internalPriceFeed(_token);
            _expectedOut = _expectedOut.mul(_amountIn).div(10**18);
        }
        uint256 _amountOutMin = _expectedOut.mul(99).div(100);
        return
            _uniswapRouter.swapETHForExactTokens{value: _amountIn}(
                _amountOutMin, //amountOutMin
                pairs,
                address(this),
                block.timestamp.add(600)
            )[pairs.length - 1];
    }

    function _checkApprovals(
        address _priceFeed,
        address _asset,
        uint256 _amount
    ) internal {
        address _uniswapRouter = IPriceFeed(_priceFeed).getUniswapRouter();
        if (
            IERC20Upgradeable(_asset).allowance(
                address(this),
                address(_uniswapRouter)
            ) < _amount
        ) {
            IERC20Upgradeable(_asset).approve(
                address(_uniswapRouter),
                PreciseUnitMath.MAX_UINT_256
            );
        }
    }
}// GPL-3.0
pragma solidity 0.7.4;



contract InsuraceDistributor is
    AbstractDistributor,
    IDistributor,
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;

    ICover public masterCover;
    ICoverData public coverData;
    IProduct public product;

    function __InsuraceDistributor_init(address _masterCover)
        public
        initializer
    {

        __Ownable_init();
        __ReentrancyGuard_init();
        masterCover = ICover(_masterCover);
        coverData = ICoverData(masterCover.data());
        product = IProduct(masterCover.product());
    }

    function getCoverCount(address _owner, bool _isActive)
        external
        view
        override
        returns (uint256)
    {

        return coverData.getCoverCount(_owner);
    }

    function getCover(
        address _owner,
        uint256 _coverId,
        bool _interfaceCompliant,
        uint256 _loopLimit
    ) external view override returns (IDistributor.Cover memory cover) {

        cover.productId = coverData.getCoverProductId(_owner, _coverId);
        (bytes32 _contractName, bytes32 _coverType, , , ) = product
            .getProductDetails(cover.productId);
        cover.coverType = _coverType;
        cover.contractName = _contractName;
        cover.coverAmount = coverData.getCoverAmount(_owner, _coverId);
        cover.currency = coverData.getCoverCurrency(_owner, _coverId);
        cover.contractAddress = 0x0000000000000000000000000000000000000000;
        cover.refAddress = 0x0000000000000000000000000000000000000000;
        cover.status = coverData.getAdjustedCoverStatus(_owner, _coverId);
        cover.expiration = coverData.getCoverEndTimestamp(_owner, _coverId);
        cover.premium = 0;

        return cover;
    }

    function getAllowance(address owner, address currency)
        public
        view
        returns (uint256)
    {

        return IERC20Upgradeable(currency).allowance(owner, address(this));
    }

    function buyCoverInsurace(IDistributor.BuyInsuraceQuote memory quote)
        external
        payable
        nonReentrant
    {

        if (quote.currency != ETH) {
            require(
                IERC20Upgradeable(quote.currency).allowance(
                    _msgSender(),
                    address(this)
                ) >= quote.premium,
                "Error on BU Contract - Need premium allowance"
            );

            IERC20Upgradeable(quote.currency).safeTransferFrom(
                _msgSender(),
                address(this),
                quote.premium
            );

            if (
                IERC20Upgradeable(quote.currency).allowance(
                    address(this),
                    address(masterCover)
                ) == uint256(0)
            ) {
                IERC20Upgradeable(quote.currency).safeApprove(
                    address(masterCover),
                    MAX_INT
                );
            }
            masterCover.buyCover(
                quote.products,
                quote.durationInDays,
                quote.amounts,
                quote.currency,
                quote.owner,
                quote.refCode,
                quote.premium,
                quote.helperParameters,
                quote.securityParameters,
                quote.v,
                quote.r,
                quote.s
            );
        } else if (quote.currency == ETH) {
            masterCover.buyCover{value: msg.value}(
                quote.products,
                quote.durationInDays,
                quote.amounts,
                quote.currency,
                quote.owner,
                quote.refCode,
                quote.premium,
                quote.helperParameters,
                quote.securityParameters,
                quote.v,
                quote.r,
                quote.s
            );
        }
        emit BuyCoverEvent(
            quote.owner,
            quote.products[0],
            quote.durationInDays[0],
            quote.currency,
            quote.amounts[0],
            quote.premium
        );
    }

    function getQuote(
        uint256 _sumAssured,
        uint256 _coverPeriod,
        address _contractAddress,
        address _coverAsset,
        address _nexusCoverable,
        bytes calldata _data
    ) external view override returns (IDistributor.CoverQuote memory) {

        revert(
            "Unsupported method, Isurace quotes are available at api.insurace.io"
        );
    }

    fallback() external payable {
        revert("Method does not exist!");
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {

        return
            interfaceId == type(IDistributor).interfaceId ||
            supportsInterface(interfaceId);
    }
}