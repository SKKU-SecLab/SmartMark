pragma solidity >=0.7.0 <0.8.0;

contract ProxyFactory {

    event ProxyCreated(address proxy);

    function deployMinimal(address _logic, bytes memory _data)
        public
        returns (address proxy)
    {

        bytes20 targetBytes = bytes20(_logic);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            proxy := create(0, clone, 0x37)
        }

        require(address(proxy) != address(0), "ProxyFactory:invalid-address");

        emit ProxyCreated(address(proxy));

        if (_data.length > 0) {
            (bool success, ) = proxy.call(_data);
            require(success, "ProxyFactory/constructor-call-failed");
        }
    }
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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// UNLICENSED
pragma solidity >=0.7.0 <0.8.0;


interface IPod is IERC20Upgradeable {

    function prizePool() external view returns (address);


    function depositTo(address to, uint256 tokenAmount)
        external
        returns (uint256);


    function withdraw(uint256 shareAmount, uint256 maxFee)
        external
        returns (uint256);


    function getPricePerShare() external view returns (uint256);


    function batch() external returns (uint256);


    function withdrawERC20(IERC20Upgradeable token, uint256 amount)
        external
        returns (bool);


    function withdrawERC721(IERC721Upgradeable token, uint256 tokenId)
        external
        returns (bool);


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

pragma solidity >=0.7.0 <0.8.0;

library ExtendedSafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn't fit in an uint128");
        return uint128(value);
    }

    function toUint112(uint256 value) internal pure returns (uint112) {

        require(value < 2**112, "SafeCast: value doesn't fit in an uint112");
        return uint112(value);
    }
}// MIT
pragma solidity >=0.7.0 <0.8.0;




contract TokenDrop is ReentrancyGuardUpgradeable {

    using SafeMathUpgradeable for uint128;
    using SafeMathUpgradeable for uint256;
    using ExtendedSafeCast for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public asset;

    IERC20Upgradeable public measure;

    uint112 public exchangeRateMantissa;

    uint112 public totalUnclaimed;

    uint32 public lastDripTimestamp;

    event Dropped(uint256 newTokens);

    event Claimed(address indexed user, uint256 newTokens);

    struct UserState {
        uint128 lastExchangeRateMantissa;
        uint128 balance;
    }

    mapping(address => UserState) public userStates;

    function initialize(IERC20Upgradeable _measure, IERC20Upgradeable _asset)
        external
        initializer
    {

        require(address(_measure) != address(0), "Pod:invalid-measure-token");
        require(address(_asset) != address(0), "Pod:invalid-asset-token");

        __ReentrancyGuard_init();

        measure = _measure;
        asset = _asset;
    }


    function beforeTokenTransfer(
        address from,
        address to,
        address token
    ) external {

        if (token == address(measure)) {
            _captureNewTokensForUser(to);

            if (from != address(0)) {
                _captureNewTokensForUser(from);
            }
        }
    }

    function addAssetToken(uint256 amount) external returns (bool) {

        asset.safeTransferFrom(msg.sender, address(this), amount);

        drop();

        return true;
    }

    function claim(address user) external returns (uint256) {

        UserState memory userState = _computeNewTokensForUser(user);

        uint256 balance = userState.balance;
        userState.balance = 0;
        userStates[user] = userState;

        totalUnclaimed = uint256(totalUnclaimed).sub(balance).toUint112();

        _nonReentrantTransfer(user, balance);

        emit Claimed(user, balance);

        return balance;
    }


    function drop() public nonReentrant returns (uint256) {

        uint256 assetTotalSupply = asset.balanceOf(address(this));
        uint256 newTokens = assetTotalSupply.sub(totalUnclaimed);

        if (newTokens > 0) {
            uint256 measureTotalSupply = measure.totalSupply();

            if (measureTotalSupply > 0) {
                uint256 indexDeltaMantissa =
                    FixedPoint.calculateMantissa(newTokens, measureTotalSupply);
                uint256 nextExchangeRateMantissa =
                    uint256(exchangeRateMantissa).add(indexDeltaMantissa);

                exchangeRateMantissa = nextExchangeRateMantissa.toUint112();
                totalUnclaimed = uint256(totalUnclaimed)
                    .add(newTokens)
                    .toUint112();
                emit Dropped(newTokens);
            }
        }

        return newTokens;
    }


    function _nonReentrantTransfer(address user, uint256 amount)
        internal
        nonReentrant
    {

        asset.safeTransfer(user, amount);
    }

    function _captureNewTokensForUser(address user)
        private
        returns (UserState memory)
    {

        UserState memory userState = _computeNewTokensForUser(user);

        userStates[user] = userState;

        return userState;
    }

    function _computeNewTokensForUser(address user)
        private
        view
        returns (UserState memory)
    {

        UserState memory userState = userStates[user];
        if (exchangeRateMantissa == userState.lastExchangeRateMantissa) {
            return userState;
        }
        uint256 deltaExchangeRateMantissa =
            uint256(exchangeRateMantissa).sub(
                userState.lastExchangeRateMantissa
            );
        uint256 userMeasureBalance = measure.balanceOf(user);
        uint128 newTokens =
            FixedPoint
                .multiplyUintByMantissa(
                userMeasureBalance,
                deltaExchangeRateMantissa
            )
                .toUint128();

        userState = UserState({
            lastExchangeRateMantissa: exchangeRateMantissa,
            balance: userState.balance.add(newTokens).toUint128()
        });

        return userState;
    }
}// MIT
pragma solidity >=0.7.0 <0.8.0;


interface IPodManager {

    function liquidate(
        address _pod,
        IERC20Upgradeable target,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) external returns (bool);


    function withdrawCollectible(
        address _pod,
        IERC721Upgradeable target,
        uint256 tokenId
    ) external returns (bool);

}// MIT
pragma solidity >=0.7.0 <0.8.0;

interface TokenFaucet {

    function claim(address user) external returns (uint256);


    function asset() external returns (address);


    function dripRatePerSecond() external returns (uint256);


    function exchangeRateMantissa() external returns (uint112);


    function measure() external returns (address);


    function totalUnclaimed() external returns (uint112);


    function lastDripTimestamp() external returns (uint32);

}// GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

interface TokenControllerInterface {

    function beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) external;

}// GPL-3.0

pragma solidity >=0.7.0 <0.8.0;



interface ControlledTokenInterface is IERC20Upgradeable {

    function controller() external view returns (TokenControllerInterface);


    function controllerMint(address _user, uint256 _amount) external;


    function controllerBurn(address _user, uint256 _amount) external;


    function controllerBurnFrom(
        address _operator,
        address _user,
        uint256 _amount
    ) external;

}// GPL-3.0

pragma solidity >=0.7.0 <0.8.0;


interface TokenListenerInterface is IERC165Upgradeable {

    function beforeTokenMint(
        address to,
        uint256 amount,
        address controlledToken,
        address referrer
    ) external;


    function beforeTokenTransfer(
        address from,
        address to,
        uint256 amount,
        address controlledToken
    ) external;

}// GPL-3.0

pragma solidity >=0.7.0 <0.8.0;


interface IPrizePool {

    function prizeStrategy() external returns (address);


    function depositTo(
        address to,
        uint256 amount,
        address controlledToken,
        address referrer
    ) external;


    function withdrawInstantlyFrom(
        address from,
        uint256 amount,
        address controlledToken,
        uint256 maximumExitFee
    ) external returns (uint256);


    function withdrawWithTimelockFrom(
        address from,
        uint256 amount,
        address controlledToken
    ) external returns (uint256);


    function withdrawReserve(address to) external returns (uint256);


    function awardBalance() external view returns (uint256);


    function captureAwardBalance() external returns (uint256);


    function award(
        address to,
        uint256 amount,
        address controlledToken
    ) external;


    function transferExternalERC20(
        address to,
        address externalToken,
        uint256 amount
    ) external;


    function awardExternalERC20(
        address to,
        address externalToken,
        uint256 amount
    ) external;


    function awardExternalERC721(
        address to,
        address externalToken,
        uint256[] calldata tokenIds
    ) external;


    function sweepTimelockBalances(address[] calldata users)
        external
        returns (uint256);


    function calculateTimelockDuration(
        address from,
        address controlledToken,
        uint256 amount
    ) external returns (uint256 durationSeconds, uint256 burnedCredit);


    function calculateEarlyExitFee(
        address from,
        address controlledToken,
        uint256 amount
    ) external returns (uint256 exitFee, uint256 burnedCredit);


    function estimateCreditAccrualTime(
        address _controlledToken,
        uint256 _principal,
        uint256 _interest
    ) external view returns (uint256 durationSeconds);


    function balanceOfCredit(address user, address controlledToken)
        external
        returns (uint256);


    function setCreditPlanOf(
        address _controlledToken,
        uint128 _creditRateMantissa,
        uint128 _creditLimitMantissa
    ) external;


    function creditPlanOf(address controlledToken)
        external
        view
        returns (uint128 creditLimitMantissa, uint128 creditRateMantissa);


    function setLiquidityCap(uint256 _liquidityCap) external;


    function setPrizeStrategy(TokenListenerInterface _prizeStrategy) external;


    function token() external view returns (address);


    function tokens() external view returns (address[] memory);


    function timelockBalanceAvailableAt(address user)
        external
        view
        returns (uint256);


    function timelockBalanceOf(address user) external view returns (uint256);


    function accountedBalance() external view returns (uint256);

}// GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

interface IPrizeStrategyMinimal {

    function isRngRequested() external returns (bool);

}// MIT
pragma solidity >=0.7.0 <0.8.0;





contract Pod is
    IPod,
    ERC20Upgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public token;
    IERC20Upgradeable public ticket;

    TokenFaucet public faucet;
    TokenDrop public tokenDrop;
    address public manager;

    IPrizePool private _prizePool;

    event Deposited(address indexed user, uint256 amount, uint256 shares);

    event Withdrawal(address indexed user, uint256 amount, uint256 shares);

    event BatchFloat(uint256 amount);

    event Claimed(address indexed user, uint256 balance);

    event PodClaimed(uint256 amount);

    event TokenDropSet(TokenDrop indexed drop);

    event TokenFaucetSet(TokenFaucet indexed drop);

    event ERC20Withdrawn(IERC20Upgradeable indexed target, uint256 amount);

    event ERC721Withdrawn(IERC721Upgradeable indexed target, uint256 tokenId);

    event ManagementTransferred(
        address indexed previousmanager,
        address indexed newmanager
    );



    modifier onlyOwnerOrManager() {

        address _sender = _msgSender();
        require(
            manager == _sender || owner() == _sender,
            "Pod:manager-unauthorized"
        );
        _;
    }

    modifier pauseDepositsDuringAwarding() {

        require(
            !IPrizeStrategyMinimal(_prizePool.prizeStrategy()).isRngRequested(),
            "Cannot deposit while prize is being awarded"
        );
        _;
    }


    function initialize(
        address _prizePoolTarget,
        address _ticket,
        uint8 _decimals
    ) external initializer {

        _prizePool = IPrizePool(_prizePoolTarget);

        __ReentrancyGuard_init();

        __ERC20_init_unchained(
            string(
                abi.encodePacked(
                    "Pod ",
                    ERC20Upgradeable(_prizePool.token()).name()
                )
            ),
            string(
                abi.encodePacked(
                    "p",
                    ERC20Upgradeable(_prizePool.token()).symbol()
                )
            )
        );

        __Ownable_init_unchained();

        _setupDecimals(_decimals);


        address[] memory tickets = _prizePool.tokens();

        require(
            address(_ticket) == address(tickets[0]) ||
                address(_ticket) == address(tickets[1]),
            "Pod:initialize-invalid-ticket"
        );

        token = IERC20Upgradeable(_prizePool.token());
        ticket = IERC20Upgradeable(_ticket);
    }


    function depositTo(address to, uint256 tokenAmount)
        external
        override
        pauseDepositsDuringAwarding
        nonReentrant
        returns (uint256)
    {

        require(tokenAmount > 0, "Pod:invalid-amount");

        uint256 shares = _calculateAllocation(tokenAmount);

        IERC20Upgradeable(token).safeTransferFrom(
            msg.sender,
            address(this),
            tokenAmount
        );

        _mint(to, shares);

        emit Deposited(to, tokenAmount, shares);

        return shares;
    }

    function withdraw(uint256 shareAmount, uint256 maxFee)
        external
        override
        nonReentrant
        returns (uint256)
    {

        require(
            balanceOf(msg.sender) >= shareAmount,
            "Pod:insufficient-shares"
        );

        uint256 tokensReturned =
            _burnSharesAndGetTokensReturned(shareAmount, maxFee);

        token.safeTransfer(msg.sender, tokensReturned);

        emit Withdrawal(msg.sender, tokensReturned, shareAmount);

        return tokensReturned;
    }

    function batch() public override returns (uint256) {

        uint256 float = _podTokenBalance();

        token.safeApprove(address(_prizePool), float);

        _prizePool.depositTo(
            address(this),
            float,
            address(ticket),
            address(this)
        );

        emit BatchFloat(float);

        return float;
    }

    function drop() public returns (uint256) {

        if (address(faucet) != address(0)) {
            faucet.claim(address(this));
        }

        batch();

        if (address(tokenDrop) != address(0)) {
            IERC20Upgradeable _asset = IERC20Upgradeable(tokenDrop.asset());

            uint256 balance = _asset.balanceOf(address(this));

            if (balance > 0) {
                _asset.safeApprove(address(tokenDrop), balance);

                tokenDrop.addAssetToken(balance);
            }

            emit PodClaimed(balance);

            return balance;
        } else {
            return 0;
        }
    }

    function setManager(address newManager)
        public
        virtual
        onlyOwner
        returns (bool)
    {

        require(newManager != address(0), "Pod:invalid-manager-address");

        manager = newManager;

        emit ManagementTransferred(manager, newManager);

        return true;
    }

    function setTokenFaucet(TokenFaucet _faucet)
        external
        onlyOwner
        returns (bool)
    {

        faucet = _faucet;

        emit TokenFaucetSet(_faucet);

        return true;
    }

    function setTokenDrop(TokenDrop _tokenDrop)
        external
        onlyOwner
        returns (bool)
    {

        tokenDrop = _tokenDrop;

        emit TokenDropSet(_tokenDrop);

        return true;
    }

    function withdrawERC20(IERC20Upgradeable _target, uint256 amount)
        external
        override
        onlyOwnerOrManager
        returns (bool)
    {

        require(
            address(_target) != address(token) &&
                address(_target) != address(ticket) &&
                (address(tokenDrop) == address(0) ||
                    address(_target) != address(tokenDrop.asset())),
            "Pod:invalid-target-token"
        );

        _target.safeTransfer(msg.sender, amount);

        emit ERC20Withdrawn(_target, amount);

        return true;
    }

    function withdrawERC721(IERC721Upgradeable _target, uint256 tokenId)
        external
        override
        onlyOwnerOrManager
        returns (bool)
    {

        _target.transferFrom(address(this), msg.sender, tokenId);

        emit ERC721Withdrawn(_target, tokenId);

        return true;
    }


    function emergencyTokenApproveZero(
        IERC20Upgradeable _token,
        address _target
    ) external onlyOwner {

        _token.safeApprove(_target, 0);
    }


    function _calculateAllocation(uint256 amount) internal returns (uint256) {

        uint256 allocation = 0;
        uint256 _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            allocation = amount;
        } else {
            allocation = (amount.mul(_totalSupply)).div(balance());
        }

        return allocation;
    }

    function _burnSharesAndGetTokensReturned(uint256 shares, uint256 maxFee)
        internal
        returns (uint256)
    {

        uint256 amount = _calculateUnderlyingTokens(shares);

        _burn(msg.sender, shares);

        uint256 currentBalance = token.balanceOf(address(this));

        uint256 actualAmount;
        if (amount > currentBalance) {
            uint256 withdrawRequest = amount.sub(currentBalance);

            uint256 withdrawExecuted =
                _withdrawFromPool(withdrawRequest, maxFee);

            actualAmount = currentBalance.add(withdrawExecuted);
            require(amount.sub(actualAmount) <= maxFee, "Pod:max-fee-exceeded");
        } else {
            actualAmount = amount;
        }

        return actualAmount;
    }

    function _withdrawFromPool(uint256 amount, uint256 maxFee)
        internal
        returns (uint256)
    {

        IERC20Upgradeable _token = token;

        uint256 balanceBefore = _token.balanceOf(address(this));

        _prizePool.withdrawInstantlyFrom(
            address(this),
            amount,
            address(ticket),
            maxFee
        );

        uint256 balanceAfter = _token.balanceOf(address(this));

        uint256 totalWithdrawn = balanceAfter.sub(balanceBefore);

        return totalWithdrawn;
    }

    function _podTokenBalance() internal view returns (uint256) {

        return token.balanceOf(address(this));
    }

    function _podTicketBalance() internal view returns (uint256) {

        return ticket.balanceOf(address(this));
    }

    function _calculateUnderlyingTokens(uint256 _shares)
        internal
        view
        returns (uint256)
    {

        uint256 _totalSupply = totalSupply();
        if (_totalSupply > 0) {
            return balance().mul(_shares).div(_totalSupply);
        } else {
            return _shares;
        }
    }


    function prizePool() external view override returns (address) {

        return address(_prizePool);
    }

    function getEarlyExitFee(uint256 amount) external returns (uint256) {

        uint256 tokenBalance = _podTokenBalance();
        if (amount <= tokenBalance) {
            return 0;
        } else {
            (uint256 exitFee, ) =
                _prizePool.calculateEarlyExitFee(
                    address(this),
                    address(ticket),
                    amount.sub(tokenBalance)
                );

            return exitFee;
        }
    }

    function getPricePerShare() external view override returns (uint256) {

        uint256 _decimals = decimals();
        return _calculateUnderlyingTokens(10**_decimals);
    }

    function balanceOfUnderlying(address user)
        external
        view
        returns (uint256 amount)
    {

        return _calculateUnderlyingTokens(balanceOf(user));
    }

    function balance() public view returns (uint256) {

        return _podTokenBalance().add(_podTicketBalance());
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {

        if (address(tokenDrop) != address(0)) {
            tokenDrop.beforeTokenTransfer(from, to, address(this));
        }
    }
}// MIT
pragma solidity >=0.7.0 <0.8.0;




contract TokenDropFactory is ProxyFactory {

    TokenDrop public tokenDropInstance;

    constructor() {
        tokenDropInstance = new TokenDrop();
    }

    function create(IERC20Upgradeable _measure, IERC20Upgradeable _asset)
        external
        returns (TokenDrop)
    {

        TokenDrop tokenDrop =
            TokenDrop(deployMinimal(address(tokenDropInstance), ""));

        tokenDrop.initialize(_measure, _asset);

        return tokenDrop;
    }
}// MIT
pragma solidity >=0.7.0 <0.8.0;




contract PodFactory is ProxyFactory {

    TokenDropFactory public tokenDropFactory;

    Pod public podInstance;

    event LogCreatedPodAndTokenDrop(Pod indexed pod, TokenDrop indexed drop);

    constructor(TokenDropFactory _tokenDropFactory) {
        require(
            address(_tokenDropFactory) != address(0),
            "PodFactory:invalid-token-drop-factory"
        );
        podInstance = new Pod();

        tokenDropFactory = _tokenDropFactory;
    }

    function create(
        address _prizePool,
        address _ticket,
        address _faucet,
        address _manager,
        uint8 _decimals
    ) external returns (address pod) {

        Pod _pod = Pod(deployMinimal(address(podInstance), ""));

        _pod.initialize(_prizePool, _ticket, _decimals);

        _pod.setManager(_manager);

        TokenDrop _drop;
        if (address(_faucet) != address(0)) {
            TokenFaucet faucet = TokenFaucet(_faucet);

            _drop = tokenDropFactory.create(
                IERC20Upgradeable(_pod),
                IERC20Upgradeable(faucet.asset())
            );

            _pod.setTokenFaucet(faucet);

            _pod.setTokenDrop(_drop);
        }

        _pod.transferOwnership(msg.sender);

        emit LogCreatedPodAndTokenDrop(_pod, _drop);

        return (address(_pod));
    }
}