pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.5.7;


contract Authorizable is Ownable {


    event AuthorizedAddressChanged(
        address indexed target,
        address indexed caller,
        bool allowed
    );

    event UserApprovedAddressChanged(
        address indexed target,
        address indexed caller,
        bool allowed
    );

    modifier onlyAuthorized() {

        require(
            authorized[msg.sender],
            "SENDER_NOT_AUTHORIZED"
        );
        _;
    }

    modifier onlyUserApproved(address user) {

        require(
            userApproved[user][msg.sender],
            "SENDER_NOT_APPROVED"
        );
        _;
    }

    mapping(address => bool) public authorized;

    mapping(address => mapping(address => bool)) public userApproved;

    address[] authorities;
    mapping(address => address[]) userApprovals;

    function authorize(address target, bool allowed)
    external
    onlyOwner
    {

        if (authorized[target] == allowed) {
            return;
        }
        if (allowed) {
            authorized[target] = allowed;
            authorities.push(target);
        } else {
            delete authorized[target];
            for (uint256 i = 0; i < authorities.length; i++) {
                if (authorities[i] == target) {
                    authorities[i] = authorities[authorities.length - 1];
                    authorities.length -= 1;
                    break;
                }
            }
        }
        emit AuthorizedAddressChanged(target, msg.sender, allowed);
    }

    function userApprove(address target, bool allowed)
    public
    {

        if (userApproved[msg.sender][target] == allowed) {
            return;
        }
        if (allowed) {
            userApproved[msg.sender][target] = allowed;
            userApprovals[msg.sender].push(target);
        } else {
            delete userApproved[msg.sender][target];
            for (uint256 i = 0; i < userApprovals[msg.sender].length; i++) {
                if (userApprovals[msg.sender][i] == target) {
                    userApprovals[msg.sender][i] = userApprovals[msg.sender][userApprovals[msg.sender].length - 1];
                    userApprovals[msg.sender].length -= 1;
                    break;
                }
            }
        }
        emit UserApprovedAddressChanged(target, msg.sender, allowed);
    }

    function batchUserApprove(address[] calldata targetList, bool[] calldata allowedList)
    external
    {

        for (uint256 i = 0; i < targetList.length; i++) {
            userApprove(targetList[i], allowedList[i]);
        }
    }

    function getAuthorizedAddresses()
    external
    view
    returns (address[] memory)
    {

        return authorities;
    }

    function getUserApprovedAddresses()
    external
    view
    returns (address[] memory)
    {

        return userApprovals[msg.sender];
    }
}/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity ^0.5.7;


library ERC20SafeTransfer {


    function safeTransfer(
        address token,
        address to,
        uint256 value)
    internal
    returns (bool success)
    {


        bytes memory callData = abi.encodeWithSelector(
            bytes4(0xa9059cbb),
            to,
            value
        );
        (success, ) = token.call(callData);
        return checkReturnValue(success);
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value)
    internal
    returns (bool success)
    {


        bytes memory callData = abi.encodeWithSelector(
            bytes4(0x23b872dd),
            from,
            to,
            value
        );
        (success, ) = token.call(callData);
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

}pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.7;

contract LibMath {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }

    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorFloor(
            numerator,
            denominator,
            target
        ),
            "ROUNDING_ERROR"
        );

        partialAmount = div(
            mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorCeil(
            numerator,
            denominator,
            target
        ),
            "ROUNDING_ERROR"
        );

        partialAmount = div(
            add(
                mul(numerator, target),
                sub(denominator, 1)
            ),
            denominator
        );
        return partialAmount;
    }

    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = div(
            mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = div(
            add(
                mul(numerator, target),
                sub(denominator, 1)
            ),
            denominator
        );
        return partialAmount;
    }

    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (bool isError)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        if (target == 0 || numerator == 0) {
            return false;
        }

        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = mul(1000, remainder) >= mul(numerator, target);
        return isError;
    }

    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (bool isError)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        if (target == 0 || numerator == 0) {
            return false;
        }
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = sub(denominator, remainder) % denominator;
        isError = mul(1000, remainder) >= mul(numerator, target);
        return isError;
    }
}pragma solidity ^0.5.0;

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}
pragma solidity ^0.5.7;

interface IBank {


    function authorize(address target, bool allowed) external;


    function userApprove(address target, bool allowed) external;


    function batchUserApprove(address[] calldata targetList, bool[] calldata allowedList) external;


    function getAuthorizedAddresses() external view returns (address[] memory);


    function getUserApprovedAddresses() external view returns (address[] memory);


    function hasDeposit(address token, address user, uint256 amount, bytes calldata data) external view returns (bool);


    function getAvailable(address token, address user, bytes calldata data) external view returns (uint256);


    function balanceOf(address token, address user) external view returns (uint256);


    function deposit(address token, address user, uint256 amount, bytes calldata data) external payable;


    function withdraw(address token, uint256 amount, bytes calldata data) external;


    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bool fromDeposit,
        bool toDeposit
    )
    external;

}pragma solidity ^0.5.7;


interface IWETH {

    function balanceOf(address owner) external view returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 amount) external;

}

contract ERC20Bank is IBank, Authorizable, ReentrancyGuard, LibMath {


    mapping(address => bool) public wethAddresses;
    mapping(address => mapping(address => uint256)) public deposits;

    event SetWETH(address addr, bool autoWrap);
    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);

    function() external payable {}

    function setWETH(address addr, bool autoWrap) external onlyOwner payable {

        if (autoWrap) {
            uint256 testETH = msg.value;
            require(testETH > 0, "TEST_ETH_REQUIRED");
            uint256 beforeWrap = IWETH(addr).balanceOf(address(this));
            IWETH(addr).deposit.value(testETH)();
            require(IWETH(addr).balanceOf(address(this)) - beforeWrap == testETH, "FAILED_WRAP_TEST");
            uint256 beforeUnwrap = address(this).balance;
            IWETH(addr).withdraw(testETH);
            require(address(this).balance - beforeUnwrap == testETH, "FAILED_UNWRAP_TEST");
            require(msg.sender.send(testETH), "FAILED_REFUND_TEST_ETH");
        }
        wethAddresses[addr] = autoWrap;
        emit SetWETH(addr, autoWrap);
    }

    function hasDeposit(address token, address user, uint256 amount, bytes memory) public view returns (bool) {

        if (wethAddresses[token]) {
            return amount <= deposits[address(0)][user];
        }
        return amount <= deposits[token][user];
    }

    function getAvailable(address token, address user, bytes calldata) external view returns (uint256) {

        if (token == address(0)) {
            return deposits[address(0)][user];
        }
        uint256 allowance = min(
            IERC20(token).allowance(user, address(this)),
            IERC20(token).balanceOf(user)
        );
        return add(allowance, balanceOf(token, user));
    }

    function balanceOf(address token, address user) public view returns (uint256) {

        if (wethAddresses[token]) {
            return deposits[address(0)][user];
        }
        return deposits[token][user];
    }

    function deposit(address token, address user, uint256 amount, bytes calldata) external nonReentrant payable {

        if (token == address(0)) {
            require(amount == msg.value, "UNMATCHED_DEPOSIT_AMOUNT");
            deposits[address(0)][user] = add(deposits[address(0)][user], msg.value);
            emit Deposit(address(0), user, msg.value, deposits[address(0)][user]);
        } else {
            require(ERC20SafeTransfer.safeTransferFrom(token, msg.sender, address(this), amount), "FAILED_DEPOSIT_TOKEN");
            if (wethAddresses[token]) {
                IWETH(token).withdraw(amount);
                deposits[address(0)][user] = add(deposits[address(0)][user], amount);
            } else {
                deposits[token][user] = add(deposits[token][user], amount);
            }
            emit Deposit(token, user, amount, deposits[token][user]);
        }
    }

    function withdraw(address token, uint256 amount, bytes calldata) external nonReentrant {

        require(hasDeposit(token, msg.sender, amount, ""), "FAILED_WITHDRAW_INSUFFICIENT_DEPOSIT");
        if (token == address(0)) {
            deposits[address(0)][msg.sender] = sub(deposits[address(0)][msg.sender], amount);
            require(msg.sender.send(amount), "FAILED_WITHDRAW_SENDING_ETH");
            emit Withdraw(address(0), msg.sender, amount, deposits[address(0)][msg.sender]);
        } else {
            if (wethAddresses[token]) {
                IWETH(token).deposit.value(amount)();
                deposits[address(0)][msg.sender] = sub(deposits[address(0)][msg.sender], amount);
            } else {
                deposits[token][msg.sender] = sub(deposits[token][msg.sender], amount);
            }
            require(ERC20SafeTransfer.safeTransfer(token, msg.sender, amount), "FAILED_WITHDRAW_SENDING_TOKEN");
            emit Withdraw(token, msg.sender, amount, deposits[token][msg.sender]);
        }
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes calldata,
        bool fromDeposit,
        bool toDeposit
    )
    external
    onlyAuthorized
    onlyUserApproved(from)
    nonReentrant
    {

        if (amount == 0 || from == to) {
            return;
        }
        if (fromDeposit) {
            require(hasDeposit(token, from, amount, ""));
            address actualToken = token;
            if (toDeposit) {
                if (wethAddresses[token]) {
                    actualToken = address(0);
                }
                deposits[actualToken][from] = sub(deposits[actualToken][from], amount);
                deposits[actualToken][to] = add(deposits[actualToken][to], amount);
            } else {
                if (token == address(0)) {
                    deposits[actualToken][from] = sub(deposits[actualToken][from], amount);
                    require(address(uint160(to)).send(amount), "FAILED_TRANSFER_FROM_DEPOSIT_TO_WALLET");
                } else {
                    if (wethAddresses[token]) {
                        IWETH(token).deposit.value(amount)();
                        actualToken = address(0);
                    }
                    deposits[actualToken][from] = sub(deposits[actualToken][from], amount);
                    require(ERC20SafeTransfer.safeTransfer(token, to, amount), "FAILED_TRANSFER_FROM_DEPOSIT_TO_WALLET");
                }
            }
        } else {
            if (toDeposit) {
                require(ERC20SafeTransfer.safeTransferFrom(token, from, address(this), amount), "FAILED_TRANSFER_FROM_WALLET_TO_DEPOSIT");
                deposits[token][to] = add(deposits[token][to], amount);
            } else {
                require(ERC20SafeTransfer.safeTransferFrom(token, from, to, amount), "FAILED_TRANSFER_FROM_WALLET_TO_WALLET");
            }
        }
    }
}
