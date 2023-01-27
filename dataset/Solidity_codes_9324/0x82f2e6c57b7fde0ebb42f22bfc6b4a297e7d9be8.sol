
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
pragma solidity ^0.8.4;

interface IGateway {
    function mint(
        bytes32 _pHash,
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) external returns (uint256);

    function burn(bytes calldata _to, uint256 _amount) external returns (uint256);
}// MIT
pragma solidity ^0.8.4;


interface IGatewayRegistry {
    function getGatewayByToken(address _tokenAddress) external view returns (IGateway);
}// MIT
pragma solidity ^0.8.4;


contract VarenRouter is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public constant ETH_REPRESENTING_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint256 public FEE = 50;
    uint256 public constant PERCENTAGE_DIVIDER = 100_000;

    IGatewayRegistry public registry;
    address public router;
    address payable public devWallet;

    struct SwapVars {
        address srcToken;
        uint256 srcAmount;
        address destToken;
        bytes data;
    }

    struct Vars {
        uint256 mintedAmount;
        uint256 swappedAmount;
    }

    struct BurnVars {
        uint256 burnAmount;
        address burnToken;
        bytes burnSendTo;
        bool shouldTakeFee;
    }

    event Mint(address indexed sender, uint256 amount);
    event Burn(address indexed sender, uint256 amount);
    event Swap(address indexed sender, address indexed from, address indexed to, uint256 amount);

    constructor(
        address _router,
        address _registry,
        address payable _devWallet
    ) {
        router = _router;
        registry = IGatewayRegistry(_registry);
        devWallet = _devWallet;
    }

    function swap(
        address sender,
        address mintToken,
        address burnToken,
        uint256 burnAmount,
        bytes calldata burnSendTo,
        SwapVars calldata swapVars,
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) external payable nonReentrant {
        require(msg.sender == sender, "The caller is unknown");
        require(burnToken != mintToken || mintToken == address(0), "Cannot mint and burn the same token");

        Vars memory vars;

        if (mintToken != address(0)) {
            vars.mintedAmount = mintRenToken(mintToken, sender, _amount, _nHash, _sig);
        }

        if (swapVars.data.length > 0) {
            vars.swappedAmount = _swap(mintToken, swapVars, vars.mintedAmount);
        }

        if (burnToken == address(0)) {
            transferTokenOrETH(vars.swappedAmount, swapVars, vars.mintedAmount, mintToken);
        } else {
            burnRenToken(vars.swappedAmount, BurnVars(burnAmount, burnToken, burnSendTo, mintToken == address(0)));
        }
    }

    function mintRenToken(
        address mintToken,
        address sender,
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) private returns (uint256 mintedAmount) {
        uint256 currentMintTokenBalance = currentBalance(mintToken);
        bytes32 pHash = keccak256(abi.encode(sender));
        registry.getGatewayByToken(mintToken).mint(pHash, _amount, _nHash, _sig);
        mintedAmount = currentBalance(mintToken) - currentMintTokenBalance;
        uint256 fee = (mintedAmount * FEE) / PERCENTAGE_DIVIDER;
        mintedAmount = mintedAmount - fee;
        IERC20(mintToken).transfer(devWallet, fee);
        emit Mint(sender, mintedAmount);
    }

    function _swap(
        address mintToken,
        SwapVars memory swapVars,
        uint256 mintedAmount
    ) private returns (uint256 swappedAmount) {
        if (mintToken == address(0)) {
            if (swapVars.srcToken != ETH_REPRESENTING_ADDRESS) {
                IERC20(swapVars.srcToken).safeTransferFrom(msg.sender, address(this), swapVars.srcAmount);
            }
        }

        uint256 currentDestTokenBalance = swapVars.destToken != ETH_REPRESENTING_ADDRESS
            ? currentBalance(swapVars.destToken)
            : address(this).balance;

        if (swapVars.srcToken != ETH_REPRESENTING_ADDRESS) {
            if (IERC20(swapVars.srcToken).allowance(address(this), router) < swapVars.srcAmount) {
                IERC20(swapVars.srcToken).approve(router, type(uint256).max);
            }
            Address.functionCall(router, swapVars.data);
        } else {
            Address.functionCallWithValue(router, swapVars.data, msg.value);
        }

        swappedAmount = swapVars.destToken != ETH_REPRESENTING_ADDRESS
            ? currentBalance(swapVars.destToken) - currentDestTokenBalance
            : address(this).balance - currentDestTokenBalance;

        if (mintedAmount > swapVars.srcAmount) {
            IERC20(swapVars.srcToken).safeTransfer(address(this), mintedAmount - swapVars.srcAmount);
        }
        emit Swap(msg.sender, swapVars.srcToken, swapVars.destToken, swappedAmount);
    }

    function burnRenToken(uint256 swappedAmount, BurnVars memory burnVars) private {
        uint256 amountToBurn = swappedAmount > 0 ? swappedAmount : burnVars.burnAmount;
        if (swappedAmount == 0) {
            IERC20(burnVars.burnToken).safeTransferFrom(msg.sender, address(this), amountToBurn);
        }
        if (burnVars.shouldTakeFee) {
            uint256 fee = (amountToBurn * FEE) / PERCENTAGE_DIVIDER;
            amountToBurn = amountToBurn - fee;
            IERC20(burnVars.burnToken).transfer(devWallet, fee);
        }
        registry.getGatewayByToken(burnVars.burnToken).burn(burnVars.burnSendTo, amountToBurn);
        emit Burn(msg.sender, amountToBurn);
    }

    function transferTokenOrETH(
        uint256 swappedAmount,
        SwapVars memory swapVars,
        uint256 mintedAmount,
        address mintToken
    ) private {
        if (swappedAmount > 0) {
            if (swapVars.destToken != ETH_REPRESENTING_ADDRESS) {
                IERC20(swapVars.destToken).safeTransfer(msg.sender, swappedAmount);
            } else {
                safeTransferETH(msg.sender, swappedAmount);
            }
        } else if (mintedAmount > 0) {
            IERC20(mintToken).safeTransfer(msg.sender, mintedAmount);
        }
    }

    function safeTransferETH(address to, uint256 value) private {
        payable(to).transfer(value);
    }

    function currentBalance(address _token) public view returns (uint256 balance) {
        balance = IERC20(_token).balanceOf(address(this));
    }

    receive() external payable {}
}