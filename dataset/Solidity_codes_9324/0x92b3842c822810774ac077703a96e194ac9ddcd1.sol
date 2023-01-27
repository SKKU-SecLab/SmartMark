
pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
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

pragma solidity 0.8.10;



contract FixedRateSwap is ERC20 {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    event Swap(
        address indexed trader,
        int256 token0Amount,
        int256 token1Amount
    );

    event Deposit(
        address indexed user,
        uint256 token0Amount,
        uint256 token1Amount,
        uint256 share
    );

    event Withdrawal(
        address indexed user,
        uint256 token0Amount,
        uint256 token1Amount,
        uint256 share
    );

    IERC20 immutable public token0;
    IERC20 immutable public token1;

    uint8 immutable private _decimals;

    uint256 constant private _ONE = 1e18;
    uint256 constant private _C1 = 0.9999e18;
    uint256 constant private _C2 = 3.382712334998325432e18;
    uint256 constant private _C3 = 0.456807350974663119e18;
    uint256 constant private _THRESHOLD = 1;
    uint256 constant private _LOWER_BOUND_NUMERATOR = 998;
    uint256 constant private _UPPER_BOUND_NUMERATOR = 1002;
    uint256 constant private _DENOMINATOR = 1000;

    constructor(
        IERC20 _token0,
        IERC20 _token1,
        string memory name,
        string memory symbol,
        uint8 decimals_
    )
        ERC20(name, symbol)
    {
        token0 = _token0;
        token1 = _token1;
        _decimals = decimals_;
        require(IERC20Metadata(address(_token0)).decimals() == decimals_, "token0 decimals mismatch");
        require(IERC20Metadata(address(_token1)).decimals() == decimals_, "token1 decimals mismatch");
    }

    function decimals() public view override returns(uint8) {
        return _decimals;
    }

    function getReturn(IERC20 tokenFrom, IERC20 tokenTo, uint256 inputAmount) public view returns(uint256 outputAmount) {
        require(inputAmount > 0, "Input amount should be > 0");
        uint256 fromBalance = tokenFrom.balanceOf(address(this));
        uint256 toBalance = tokenTo.balanceOf(address(this));
        require(inputAmount <= toBalance, "Input amount is too big");
        outputAmount = _getReturn(fromBalance, toBalance, inputAmount);
    }

    function deposit(uint256 token0Amount, uint256 token1Amount, uint256 minShare) external returns(uint256 share) {
        share = depositFor(token0Amount, token1Amount, msg.sender, minShare);
    }

    function depositFor(uint256 token0Amount, uint256 token1Amount, address to, uint256 minShare) public returns(uint256 share) {
        uint256 token0Balance = token0.balanceOf(address(this));
        uint256 token1Balance = token1.balanceOf(address(this));
        (uint256 token0VirtualAmount, uint256 token1VirtualAmount) = _getVirtualAmountsForDeposit(token0Amount, token1Amount, token0Balance, token1Balance);

        uint256 inputAmount = token0VirtualAmount + token1VirtualAmount;
        require(inputAmount > 0, "Empty deposit is not allowed");
        require(to != address(this), "Deposit to this is forbidden");

        uint256 _totalSupply = totalSupply();
        if (_totalSupply > 0) {
            uint256 totalBalance = token0Balance + token1Balance + token0Amount + token1Amount - inputAmount;
            share = inputAmount * _totalSupply / totalBalance;
        } else {
            share = inputAmount;
        }

        require(share >= minShare, "Share is not enough");
        _mint(to, share);
        emit Deposit(to, token0Amount, token1Amount, share);

        if (token0Amount > 0) {
            token0.safeTransferFrom(msg.sender, address(this), token0Amount);
        }
        if (token1Amount > 0) {
            token1.safeTransferFrom(msg.sender, address(this), token1Amount);
        }
    }

    function withdraw(uint256 amount, uint256 minToken0Amount, uint256 minToken1Amount) external returns(uint256 token0Amount, uint256 token1Amount) {
        (token0Amount, token1Amount) = withdrawFor(amount, msg.sender, minToken0Amount, minToken1Amount);
    }

    function withdrawFor(uint256 amount, address to, uint256 minToken0Amount, uint256 minToken1Amount) public returns(uint256 token0Amount, uint256 token1Amount) {
        require(amount > 0, "Empty withdrawal is not allowed");
        require(to != address(this), "Withdrawal to this is forbidden");
        require(to != address(0), "Withdrawal to zero is forbidden");

        uint256 _totalSupply = totalSupply();
        _burn(msg.sender, amount);
        token0Amount = token0.balanceOf(address(this)) * amount / _totalSupply;
        token1Amount = token1.balanceOf(address(this)) * amount / _totalSupply;
        _handleWithdraw(to, amount, token0Amount, token1Amount, minToken0Amount, minToken1Amount);
    }

    function withdrawWithRatio(uint256 amount, uint256 token0Share, uint256 minToken0Amount, uint256 minToken1Amount) external returns(uint256 token0Amount, uint256 token1Amount) {
        return withdrawForWithRatio(amount, msg.sender, token0Share, minToken0Amount, minToken1Amount);
    }

    function withdrawForWithRatio(uint256 amount, address to, uint256 token0Share, uint256 minToken0Amount, uint256 minToken1Amount) public returns(uint256 token0Amount, uint256 token1Amount) {
        require(amount > 0, "Empty withdrawal is not allowed");
        require(to != address(this), "Withdrawal to this is forbidden");
        require(to != address(0), "Withdrawal to zero is forbidden");
        require(token0Share <= _ONE, "Ratio should be in [0, 1]");

        uint256 _totalSupply = totalSupply();
        _burn(msg.sender, amount);
        (token0Amount, token1Amount) = _getRealAmountsForWithdraw(amount, token0Share, _totalSupply);
        _handleWithdraw(to, amount, token0Amount, token1Amount, minToken0Amount, minToken1Amount);
    }

    function swap0To1(uint256 inputAmount, uint256 minReturnAmount) external returns(uint256 outputAmount) {
        outputAmount = _swap(token0, token1, inputAmount, msg.sender, minReturnAmount);
        emit Swap(msg.sender, inputAmount.toInt256(), -outputAmount.toInt256());
    }

    function swap1To0(uint256 inputAmount, uint256 minReturnAmount) external returns(uint256 outputAmount) {
        outputAmount = _swap(token1, token0, inputAmount, msg.sender, minReturnAmount);
        emit Swap(msg.sender, -outputAmount.toInt256(), inputAmount.toInt256());
    }

    function swap0To1For(uint256 inputAmount, address to, uint256 minReturnAmount) external returns(uint256 outputAmount) {
        require(to != address(this), "Swap to this is forbidden");
        require(to != address(0), "Swap to zero is forbidden");

        outputAmount = _swap(token0, token1, inputAmount, to, minReturnAmount);
        emit Swap(msg.sender, inputAmount.toInt256(), -outputAmount.toInt256());
    }

    function swap1To0For(uint256 inputAmount, address to, uint256 minReturnAmount) external returns(uint256 outputAmount) {
        require(to != address(this), "Swap to this is forbidden");
        require(to != address(0), "Swap to zero is forbidden");

        outputAmount = _swap(token1, token0, inputAmount, to, minReturnAmount);
        emit Swap(msg.sender, -outputAmount.toInt256(), inputAmount.toInt256());
    }

    function _getVirtualAmountsForDeposit(uint256 token0Amount, uint256 token1Amount, uint256 token0Balance, uint256 token1Balance)
        private pure returns(uint256 token0VirtualAmount, uint256 token1VirtualAmount)
    {
        int256 shift = _checkVirtualAmountsFormula(token0Amount, token1Amount, token0Balance, token1Balance);
        if (shift > 0) {
            (token0VirtualAmount, token1VirtualAmount) = _getVirtualAmountsForDepositImpl(token0Amount, token1Amount, token0Balance, token1Balance);
        } else if (shift < 0) {
            (token1VirtualAmount, token0VirtualAmount) = _getVirtualAmountsForDepositImpl(token1Amount, token0Amount, token1Balance, token0Balance);
        } else {
            (token0VirtualAmount, token1VirtualAmount) = (token0Amount, token1Amount);
        }
    }

    function _getRealAmountsForWithdraw(uint256 amount, uint256 token0Share, uint256 _totalSupply) private view returns(uint256 token0RealAmount, uint256 token1RealAmount) {
        uint256 token0Balance = token0.balanceOf(address(this));
        uint256 token1Balance = token1.balanceOf(address(this));
        uint256 token0VirtualAmount = token0Balance * amount / _totalSupply;
        uint256 token1VirtualAmount = token1Balance * amount / _totalSupply;

        uint256 currentToken0Share = token0VirtualAmount * _ONE / (token0VirtualAmount + token1VirtualAmount);
        if (token0Share < currentToken0Share) {
            (token0RealAmount, token1RealAmount) = _getRealAmountsForWithdrawImpl(token0VirtualAmount, token1VirtualAmount, token0Balance - token0VirtualAmount, token1Balance - token1VirtualAmount, token0Share);
        } else if (token0Share > currentToken0Share) {
            (token1RealAmount, token0RealAmount) = _getRealAmountsForWithdrawImpl(token1VirtualAmount, token0VirtualAmount, token1Balance - token1VirtualAmount, token0Balance - token0VirtualAmount, _ONE - token0Share);
        } else {
            (token0RealAmount, token1RealAmount) = (token0VirtualAmount, token1VirtualAmount);
        }
    }

    function _getReturn(uint256 fromBalance, uint256 toBalance, uint256 inputAmount) private pure returns(uint256 outputAmount) {
        unchecked {
            uint256 totalBalance = fromBalance + toBalance;
            uint256 x0 = _ONE * fromBalance / totalBalance;
            uint256 x1 = _ONE * (fromBalance + inputAmount) / totalBalance;
            uint256 scaledInputAmount = _ONE * inputAmount;
            uint256 amountMultiplier = (
                _C1 * scaledInputAmount / totalBalance +
                _C2 * _powerHelper(x0) -
                _C2 * _powerHelper(x1)
            ) * totalBalance / scaledInputAmount;
            outputAmount = inputAmount * Math.min(amountMultiplier, _ONE) / _ONE;
        }
    }

    function _handleWithdraw(address to, uint256 amount, uint256 token0Amount, uint256 token1Amount, uint256 minToken0Amount, uint256 minToken1Amount) private {
        require(token0Amount >= minToken0Amount, "Min token0Amount is not reached");
        require(token1Amount >= minToken1Amount, "Min token1Amount is not reached");

        emit Withdrawal(msg.sender, token0Amount, token1Amount, amount);
        if (token0Amount > 0) {
            token0.safeTransfer(to, token0Amount);
        }
        if (token1Amount > 0) {
            token1.safeTransfer(to, token1Amount);
        }
    }

    function _swap(IERC20 tokenFrom, IERC20 tokenTo, uint256 inputAmount, address to, uint256 minReturnAmount) private returns(uint256 outputAmount) {
        outputAmount = getReturn(tokenFrom, tokenTo, inputAmount);
        require(outputAmount > 0, "Empty swap is not allowed");
        require(outputAmount >= minReturnAmount, "Min return not reached");
        tokenFrom.safeTransferFrom(msg.sender, address(this), inputAmount);
        tokenTo.safeTransfer(to, outputAmount);
    }

    function _getVirtualAmountsForDepositImpl(uint256 x, uint256 y, uint256 xBalance, uint256 yBalance) private pure returns(uint256, uint256) {
        uint256 dx = (x * yBalance - y * xBalance) / (xBalance + yBalance + x + y);
        if (dx == 0) {
            return (x, y);
        }
        uint256 dy;
        uint256 left = dx * _LOWER_BOUND_NUMERATOR / _DENOMINATOR;
        uint256 right = Math.min(Math.min(dx * _UPPER_BOUND_NUMERATOR / _DENOMINATOR, yBalance), x);

        while (left + _THRESHOLD < right) {
            dy = _getReturn(xBalance, yBalance, dx);
            int256 shift = _checkVirtualAmountsFormula(x - dx, y + dy, xBalance + dx, yBalance - dy);
            if (shift > 0) {
                left = dx;
                dx = (dx + right) / 2;
            } else if (shift < 0) {
                right = dx;
                dx = (left + dx) / 2;
            } else {
                break;
            }
        }

        return (x - dx, y + dy);
    }

    function _getRealAmountsForWithdrawImpl(uint256 virtualX, uint256 virtualY, uint256 balanceX, uint256 balanceY, uint256 firstTokenShare) private pure returns(uint256, uint256) {
        require(balanceX != 0 || balanceY != 0, "Amount exceeds total balance");
        if (firstTokenShare == 0) {
            return (0, virtualY + _getReturn(balanceX, balanceY, virtualX));
        }

        uint256 secondTokenShare = _ONE - firstTokenShare;
        uint256 dx = (virtualX * secondTokenShare - virtualY * firstTokenShare) / _ONE;
        uint256 dy;
        uint256 left = dx * _LOWER_BOUND_NUMERATOR / _DENOMINATOR;
        uint256 right = Math.min(dx * _UPPER_BOUND_NUMERATOR / _DENOMINATOR, virtualX);

        while (left + _THRESHOLD < right) {
            dy = _getReturn(balanceX, balanceY, dx);
            int256 shift = _checkVirtualAmountsFormula(virtualX - dx, virtualY + dy, firstTokenShare, secondTokenShare);
            if (shift > 0) {
                left = dx;
                dx = (dx + right) / 2;
            } else if (shift < 0) {
                right = dx;
                dx = (left + dx) / 2;
            } else {
                break;
            }
        }

        return (virtualX - dx, virtualY + dy);
    }

    function _checkVirtualAmountsFormula(uint256 x, uint256 y, uint256 xBalance, uint256 yBalance) private pure returns(int256) {
        unchecked {
            return int256(x * yBalance - y * xBalance);
        }
    }

    function _powerHelper(uint256 x) private pure returns(uint256 p) {
        unchecked {
            if (x > _C3) {
                p = x - _C3;
            } else {
                p = _C3 - x;
            }
            p = p * p / _ONE;  // p ^ 2
            uint256 pp = p * p / _ONE;  // p ^ 4
            pp = pp * pp / _ONE;  // p ^ 8
            pp = pp * pp / _ONE;  // p ^ 16
            p = p * pp / _ONE;  // p ^ 18
        }
    }
}