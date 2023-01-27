
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


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

pragma solidity ^0.8.0;


abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library ECDSAUpgradeable {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}/*
  $EXP by @scholarznft
  (inspired by ACYCapital - https://etherscan.io/address/0xb56a1f3310578f23120182fb2e58c087efe6e147)

  Buy tax ($EXP):
  - 10% of each buy goes into endowment fund and distributed as backend tokens

  Sell tax (ETH):
  - 5% goes to buyback wallet
  - 4% goes to EXP shop
  - 1% goes to team
*/

pragma solidity ^0.8.10;


contract Exp is ERC20Upgradeable, ERC20PausableUpgradeable, OwnableUpgradeable {

  using ECDSAUpgradeable for bytes32;
  uint public minimumTokensToSwap;
  address payable public walletAddress1; // 5%
  address payable public walletAddress2; // 4%
  address payable public walletAddress3; // 1%

  address private _signer;
  mapping(bytes32 => bool) private _usedKey;
  mapping(address => uint) public lastClaimed;
  uint public durationBetweenClaim;
  uint public costToClaim;

  uint public buyTaxPercentage;
  uint public buyTaxCount;
  uint public sellTaxPercentage;
  uint public toWallet1Percentage;
  uint public toWallet2Percentage;
  uint public toWallet3Percentage;
  
  mapping(address => bool) private _isExcludedFromTaxes;
  
  address private uniDefault;
  IUniswapV2Router02 public uniswapV2Router;
  bool private _inSwap; 
  address public uniswapV2Pair;

  event BuyTax(uint indexed count, uint amount);
  event MintedExp(address indexed sender, bytes32 indexed key, uint amount);
  event DepositExp(address indexed sender, bytes32 indexed key, uint amount);
  event ExternalBurn(address indexed sender, uint amount);

  modifier lockTheSwap() {

    _inSwap = true;
    _;
    _inSwap = false;
  }

  receive() external payable {
    return;
  }

  function initialize() public initializer {

    __ERC20_init("Exp", "EXP");
    __Ownable_init();
    _signer = 0xBc9eebF48B2B8B54f57d6c56F41882424d632EA7;
    uniDefault = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    buyTaxPercentage = 10;
    sellTaxPercentage = 10;
    toWallet1Percentage = 50;
    toWallet2Percentage = 40;
    toWallet3Percentage = 10;
    durationBetweenClaim = 2 days;
    costToClaim = 10 * 10**18;
    uniswapV2Router = IUniswapV2Router02(uniDefault);

    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

    walletAddress1 = payable(0x1F5652E7f240CC2bA2A99d5cd9AE19E75c1bB32F);
    walletAddress2 = payable(0x41f727E0F74ed199E42cC7af16b56DE0Cb5ecE83);
    walletAddress3 = payable(0x7A2708B9cb7951ddC8f7b800a2a22D035Cc391ae);

    _isExcludedFromTaxes[owner()] = true;
    _isExcludedFromTaxes[address(this)] = true;
    _isExcludedFromTaxes[walletAddress1] = true;
    _isExcludedFromTaxes[walletAddress2] = true;
    _isExcludedFromTaxes[walletAddress3] = true;
  }

  function setSignerAddress(address adr) external onlyOwner {

    _signer = adr;
  }

  function setWallet1(address payable wallet1) external onlyOwner {

    require(wallet1 != address(0), "Address cannot be null.");
    address _previousWalletAddress = walletAddress1;
    walletAddress1 = wallet1;
    _isExcludedFromTaxes[walletAddress1] = true;
    _isExcludedFromTaxes[_previousWalletAddress] = false;
  }

  function setWallet2(address payable wallet2) external onlyOwner {

    require(wallet2 != address(0), "Address cannot be null.");
    address _previousWalletAddress = walletAddress2;
    walletAddress2 = wallet2;
    _isExcludedFromTaxes[walletAddress2] = true;
    _isExcludedFromTaxes[_previousWalletAddress] = false;
  }

  function setWallet3(address payable wallet3) external onlyOwner {

    require(wallet3 != address(0), "Address cannot be null.");
    address _previousWalletAddress = walletAddress3;
    walletAddress3 = wallet3;
    _isExcludedFromTaxes[walletAddress3] = true;
    _isExcludedFromTaxes[_previousWalletAddress] = false;
  }

  function excludeFromTaxes(address account, bool excluded) external onlyOwner {

    _isExcludedFromTaxes[account] = excluded;
  }

  function setMinimumTokensToSwap(uint amount) external onlyOwner {

    minimumTokensToSwap = amount;
  }

  function setBuyTaxPercentage(uint buyTax) external onlyOwner {

    buyTaxPercentage = buyTax;
  }

  function setSellTaxPercentage(uint sellTax, uint taxTo1, uint taxTo2, uint taxTo3) external onlyOwner {

    require(taxTo1 + taxTo2 + taxTo3 == 100, "Invalid tax total");
    toWallet1Percentage = taxTo1;
    toWallet2Percentage = taxTo2;
    toWallet3Percentage = taxTo3;
    sellTaxPercentage = sellTax;
  }

  function manualSend() external onlyOwner {

    uint contractETHBalance = address(this).balance;
    payable(msg.sender).transfer(contractETHBalance);
  }

  function manualSwapAndWithdraw() external onlyOwner {

    _swapTokensForEth(balanceOf(address(this)));
    uint contractETHBalance = address(this).balance;
    payable(walletAddress1).transfer(toWallet1Percentage * contractETHBalance / 100);
    payable(walletAddress2).transfer(toWallet2Percentage * contractETHBalance / 100);
    payable(walletAddress3).transfer(toWallet3Percentage * contractETHBalance / 100);
  }

  function setDurationBetweenClaim(uint duration) external onlyOwner {

    durationBetweenClaim = duration;
  }

  function setCostToClaim(uint amount) external onlyOwner {

    costToClaim = amount;
  }

  function pause() external onlyOwner {

    _pause();
  }

  function unpause() external onlyOwner {

    _unpause();
  }

  function _transfer(address sender, address recipient, uint256 amount) internal override {

    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "ERC20: Amount is less than or equal to zero");
    require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
    _beforeTokenTransfer(sender, recipient, amount);

    bool taxed = true;
    if (_isExcludedFromTaxes[sender] || _isExcludedFromTaxes[recipient]) {
      taxed = false;
    }

    bool buy = false;
    if (sender == address(uniswapV2Pair)) {
      buy = true;
    }

    uint amountAfterTax;

    if (!taxed) {
      amountAfterTax = amount;
    } else if (buy) {
      uint buyCut = buyTaxPercentage * amount / 100;
      _burn(sender, buyCut);
      buyTaxCount++;
      emit BuyTax(buyTaxCount, buyCut);
      amountAfterTax = amount - buyCut;

    } else {
      uint sellCut = sellTaxPercentage * amount / 100;
      _balances[sender] -= sellCut;
      _balances[address(this)] += sellCut;
      emit Transfer(sender, address(this), sellCut);

      if (!_inSwap && _balances[address(this)] >= minimumTokensToSwap) {
        _swapTokensForEth(_balances[address(this)]);
      }
      uint contractETHBalance = address(this).balance;
      if (contractETHBalance > 0) {
        payable(walletAddress1).transfer(contractETHBalance * toWallet1Percentage / 100);
        payable(walletAddress2).transfer(contractETHBalance * toWallet2Percentage / 100);
        payable(walletAddress3).transfer(contractETHBalance * toWallet3Percentage / 100);
      }

      amountAfterTax = amount - sellCut;
    }

    _balances[sender] -= amountAfterTax;
    _balances[recipient] += amountAfterTax;    
    emit Transfer(sender, recipient, amountAfterTax);
  }

  function _swapTokensForEth(uint tokenAmount) private lockTheSwap {

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();

    _approve(address(this), address(uniswapV2Router), tokenAmount);

    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override(ERC20Upgradeable, ERC20PausableUpgradeable) {

  }

  function createInternetCoin(bytes32 key, bytes calldata signature, uint amount, uint timestamp) external whenNotPaused {

    require(block.timestamp - lastClaimed[msg.sender] > durationBetweenClaim, "Cooldown is not finished");
    require(amount > costToClaim, "ERC20: Amount is smaller than claim cost");
    require(!_usedKey[key], "Key has been used");
    require(block.timestamp < timestamp, "Expired claim time");
    require(keccak256(abi.encode(msg.sender, "ERC20-EXP", amount, timestamp, key)).toEthSignedMessageHash().recover(signature) == _signer, "Invalid signature");
    _mint(msg.sender, amount - costToClaim);
    _usedKey[key] = true;
    lastClaimed[msg.sender] = block.timestamp;
    emit MintedExp(msg.sender, key, amount - costToClaim);
  }

  function depositInternetCoin(bytes32 key, bytes calldata signature, uint amount, uint timestamp) external whenNotPaused {

    require(amount > 0, "ERC20: Amount is less than or equal to zero");
    require(!_usedKey[key], "Key has been used");
    require(block.timestamp < timestamp, "Expired deposit time");
    require(keccak256(abi.encode(msg.sender, "ERC20-EXP-BURN", amount, timestamp, key)).toEthSignedMessageHash().recover(signature) == _signer, "Invalid signature");
    _burn(msg.sender, amount);    
    _usedKey[key] = true;
    emit DepositExp(msg.sender, key, amount);
  }

  function burn(address tokenOwner, uint amount) external whenNotPaused {

    require(msg.sender == tokenOwner || allowance(tokenOwner, msg.sender) >= amount, "Not enough allowances");
    if (msg.sender != tokenOwner) {
      _approve(tokenOwner, msg.sender, _allowances[tokenOwner][msg.sender] - amount);
    }
    _burn(tokenOwner, amount);
    emit ExternalBurn(tokenOwner, amount);
  }

  function isExcludedFromTaxes(address account) public view returns (bool) {

    return _isExcludedFromTaxes[account];
  }

}