
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}/*
IEvents

https://github.com/gysr-io/core

MIT
 */

pragma solidity 0.8.4;

interface IEvents {

    event Staked(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event Unstaked(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event Claimed(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );

    event RewardsDistributed(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event RewardsFunded(
        address indexed token,
        uint256 amount,
        uint256 shares,
        uint256 timestamp
    );
    event RewardsUnlocked(address indexed token, uint256 shares);
    event RewardsExpired(
        address indexed token,
        uint256 amount,
        uint256 shares,
        uint256 timestamp
    );

    event GysrSpent(address indexed user, uint256 amount);
    event GysrVested(address indexed user, uint256 amount);
    event GysrWithdrawn(uint256 amount);
}/*
OwnerController

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;

contract OwnerController {

    address private _owner;
    address private _controller;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event ControlTransferred(
        address indexed previousController,
        address indexed newController
    );

    constructor() {
        _owner = msg.sender;
        _controller = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        emit ControlTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function controller() public view returns (address) {

        return _controller;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "oc1");
        _;
    }

    modifier onlyController() {

        require(_controller == msg.sender, "oc2");
        _;
    }

    function requireOwner() internal view {

        require(_owner == msg.sender, "oc1");
    }

    function requireController() internal view {

        require(_controller == msg.sender, "oc2");
    }

    function transferOwnership(address newOwner) public virtual {

        requireOwner();
        require(newOwner != address(0), "oc3");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferControl(address newController) public virtual {

        requireOwner();
        require(newController != address(0), "oc4");
        emit ControlTransferred(_controller, newController);
        _controller = newController;
    }
}/*
IStakingModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;




abstract contract IStakingModule is OwnerController, IEvents {
    uint256 public constant DECIMALS = 18;

    function tokens() external view virtual returns (address[] memory);

    function balances(address user)
        external
        view
        virtual
        returns (uint256[] memory);

    function factory() external view virtual returns (address);

    function totals() external view virtual returns (uint256[] memory);

    function stake(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function unstake(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function claim(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function update(address user) external virtual;

    function clean() external virtual;
}/*
ERC20StakingModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;



contract ERC20StakingModule is IStakingModule {

    using SafeERC20 for IERC20;

    uint256 public constant INITIAL_SHARES_PER_TOKEN = 10**6;

    IERC20 private immutable _token;
    address private immutable _factory;

    mapping(address => uint256) public shares;
    uint256 public totalShares;

    constructor(address token_, address factory_) {
        _token = IERC20(token_);
        _factory = factory_;
    }

    function tokens()
        external
        view
        override
        returns (address[] memory tokens_)
    {

        tokens_ = new address[](1);
        tokens_[0] = address(_token);
    }

    function balances(address user)
        external
        view
        override
        returns (uint256[] memory balances_)
    {

        balances_ = new uint256[](1);
        balances_[0] = _balance(user);
    }

    function factory() external view override returns (address) {

        return _factory;
    }

    function totals()
        external
        view
        override
        returns (uint256[] memory totals_)
    {

        totals_ = new uint256[](1);
        totals_[0] = _token.balanceOf(address(this));
    }

    function stake(
        address user,
        uint256 amount,
        bytes calldata
    ) external override onlyOwner returns (address, uint256) {

        require(amount > 0, "sm1");

        uint256 total = _token.balanceOf(address(this));
        _token.safeTransferFrom(user, address(this), amount);
        uint256 actual = _token.balanceOf(address(this)) - total;

        uint256 minted =
            (totalShares > 0)
                ? (totalShares * actual) / total
                : actual * INITIAL_SHARES_PER_TOKEN;
        require(minted > 0, "sm2");

        shares[user] += minted;

        totalShares += minted;

        emit Staked(user, address(_token), amount, minted);

        return (user, minted);
    }

    function unstake(
        address user,
        uint256 amount,
        bytes calldata
    ) external override onlyOwner returns (address, uint256) {

        uint256 burned = _shares(user, amount);

        totalShares -= burned;
        shares[user] -= burned;

        _token.safeTransfer(user, amount);

        emit Unstaked(user, address(_token), amount, burned);

        return (user, burned);
    }

    function claim(
        address user,
        uint256 amount,
        bytes calldata
    ) external override onlyOwner returns (address, uint256) {

        uint256 s = _shares(user, amount);
        emit Claimed(user, address(_token), amount, s);
        return (user, s);
    }

    function update(address) external override {}


    function clean() external override {}


    function _balance(address user) private view returns (uint256) {

        if (totalShares == 0) {
            return 0;
        }
        return (_token.balanceOf(address(this)) * shares[user]) / totalShares;
    }

    function _shares(address user, uint256 amount)
        private
        view
        returns (uint256 shares_)
    {

        require(amount > 0, "sm3");
        require(totalShares > 0, "sm4");

        shares_ = (totalShares * amount) / _token.balanceOf(address(this));

        require(shares_ > 0, "sm5");
        require(shares[user] >= shares_, "sm6");
    }
}/*
IModuleFactory

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;

interface IModuleFactory {

    event ModuleCreated(address indexed user, address module);

    function createModule(bytes calldata data) external returns (address);

}/*
ERC20StakingModuleFactory

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;


contract ERC20StakingModuleFactory is IModuleFactory {

    function createModule(bytes calldata data)
        external
        override
        returns (address)
    {

        require(data.length == 32, "smf1");

        address token;
        assembly {
            token := calldataload(68)
        }

        ERC20StakingModule module =
            new ERC20StakingModule(token, address(this));
        module.transferOwnership(msg.sender);

        emit ModuleCreated(msg.sender, address(module));
        return address(module);
    }
}