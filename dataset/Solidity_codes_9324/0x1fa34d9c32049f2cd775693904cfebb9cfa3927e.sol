

pragma solidity >=0.5.0;

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

}




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
}




pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}




pragma solidity ^0.8.0;


library ECDSA {

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

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




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
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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

}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




pragma solidity ^0.8.0;






contract NeedForTurboCoin is Ownable, ERC20 {
  using ECDSA for bytes32;

  address constant DEAD = 0x000000000000000000000000000000000000dEaD;

  uint256 private _totalSupply;
  mapping(address => uint256) private _balances;
  uint256 private _accumulatedReflection;
  mapping (address => uint256) private _reflectionDebts;
  address private _pair;

  uint256 public holders;
  mapping (address => uint256) public lastTransfer;
  address public marketingWallet;
  address public devWallet;
  address public minter;
  address public captchaSigner;
  mapping (address => bool) public solvedCaptchas;
  bool public antiBotEnabled;
  bool public feeRemoved;

  event MarketingWalletChanged(address indexed previousMarketingWallet, address indexed newMarketingWallet);
  event DevWalletChanged(address indexed previousDevWallet, address indexed newDevWallet);
  event MinterChanged(address indexed previousMinter, address indexed newMinter);
  event CaptchaSignerChanged(address indexed previousCaptchaSigner, address indexed newCaptchaSigner);
  event CaptchaSolved(address indexed account);
  event AntiBotEnabledChanged(bool previousAntiBotEnabled, bool newAntiBotEnabled);
  event FeeRemoved();

  constructor() ERC20("Need for Turbo Coin", "NFTC") {
    if (block.chainid == 1) { // Ethereum
      _pair = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f).createPair(address(this), 0xdAC17F958D2ee523a2206206994597C13D831ec7); // Uniswap V2 USDT pair
    } else if (block.chainid == 56) { // Binance Smart Chain
      _pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), 0x55d398326f99059fF775485246999027B3197955); // PancakeSwap V2 USDT pair
    } else {
      revert("NeedForTurboCoin: invalid chain");
    }

    marketingWallet = _msgSender();
    emit MarketingWalletChanged(address(0), _msgSender());
    devWallet = _msgSender();
    emit DevWalletChanged(address(0), _msgSender());
  }

  function _receivesReflection(address account) private view returns (bool) {
    return account != address(this) && account != DEAD && account != _pair;
  }

  function _reflectionDebt(address account) private view returns (uint256) {
    return _accumulatedReflection * _balances[account] / 10 ** decimals();
  }

  function _reflection(address account) private view returns (uint256) {
    return _receivesReflection(account) ? Math.min(_reflectionDebt(account) - _reflectionDebts[account], _balances[address(this)]) : 0;
  }

  function _updateBalance(address account, uint256 amount, bool add) private {
    uint256 balance = _balances[account];
    bool isHolder = balance != 0;
    uint256 reflection = _reflection(account);

    if (reflection != 0) {
      _balances[address(this)] -= reflection;
      balance += reflection;
      emit Transfer(address(this), account, reflection);
    }

    if (amount != 0) {
      if (add) {
        balance += amount;

        if (!isHolder) {
          holders++;
        }

        if (lastTransfer[account] == 0) {
          lastTransfer[account] = block.timestamp;
        }
      } else {
        balance -= amount;

        if (isHolder && balance == 0) {
          holders--;
        }

        lastTransfer[account] = block.timestamp;
      }
    }

    _balances[account] = balance;

    if (_receivesReflection(account)) {
      _reflectionDebts[account] = _reflectionDebt(account);
    }
  }

  function _transfer(address sender, address recipient, uint256 amount) internal override {
    require(sender != address(0), "NeedForTurboCoin: transfer from the zero address");
    require(recipient != address(0), "NeedForTurboCoin: transfer to the zero address");
    require(recipient != _pair || !antiBotEnabled || solvedCaptchas[sender], "NeedForTurboCoin: anti-bot captcha not solved");
    _updateBalance(sender, amount, false);

    if ((sender == _pair || recipient == _pair) && !feeRemoved && balanceOf(_pair) != 0) { // no fee when providing initial liquidity
      uint256 fee = amount / 10; // 10%
      amount -= fee;
      _updateBalance(recipient, amount, true);
      emit Transfer(sender, recipient, amount);
      uint256 reflection = fee * 4 / 10; // distribute 4% (40% of 10%) to holders (Auto Reflection)
      _updateBalance(address(this), reflection, true);
      emit Transfer(sender, address(this), reflection);
      uint256 burn = fee * 3 / 10; // burn 3% (30% of 10%) to increase liquidity ratio (Auto LP) and price
      _updateBalance(DEAD, burn, true);
      emit Transfer(sender, DEAD, burn);
      uint256 marketing = fee * 2 / 10; // send 2% (20% of 10%) to marketing wallet
      _updateBalance(marketingWallet, marketing, true);
      emit Transfer(sender, marketingWallet, marketing);
      fee -= reflection + burn + marketing; // send 1% (remaining 10% of 10%) to development wallet
      _updateBalance(devWallet, fee, true);
      emit Transfer(sender, devWallet, fee);
      _accumulatedReflection += reflection * 10 ** decimals() / (_totalSupply - _balances[address(this)] - _balances[DEAD] - _balances[_pair]);
    } else {
      _updateBalance(recipient, amount, true);
      emit Transfer(sender, recipient, amount);
    }
  }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account] + _reflection(account);
  }

  function setMarketingWallet(address _marketingWallet) external onlyOwner {
    emit MarketingWalletChanged(marketingWallet, _marketingWallet);
    marketingWallet = _marketingWallet;
  }

  function setDevWallet(address _devWallet) external onlyOwner {
    emit DevWalletChanged(devWallet, _devWallet);
    devWallet = _devWallet;
  }

  function setMinter(address _minter) external onlyOwner {
    emit MinterChanged(minter, _minter);
    minter = _minter;
  }

  function mint(uint256 amount) external {
    address sender = _msgSender();
    require(sender == minter, "NeedForTurboCoin: caller is not the minter");
    require(_totalSupply == 0, "NeedForTurboCoin: supply is fixed, can only mint once");
    _totalSupply += amount;
    _balances[sender] += amount;
    emit Transfer(address(0), sender, amount);
  }

  function setCaptchaSigner(address _captchaSigner) external onlyOwner {
    emit CaptchaSignerChanged(captchaSigner, _captchaSigner);
    captchaSigner = _captchaSigner;
  }

  function solveCaptcha(bytes memory signature) external {
    require(keccak256(abi.encode(block.chainid, address(this), _msgSender())).toEthSignedMessageHash().recover(signature) == captchaSigner, "NeedForTurboCoin: invalid signature");
    solvedCaptchas[_msgSender()] = true;
    emit CaptchaSolved(_msgSender());
  }

  function setAntiBotEnabled(bool _antiBotEnabled) external onlyOwner {
    emit AntiBotEnabledChanged(antiBotEnabled, _antiBotEnabled);
    antiBotEnabled = _antiBotEnabled;
  }

  function removeFee() external onlyOwner {
    feeRemoved = true;
    emit FeeRemoved();
  }
}