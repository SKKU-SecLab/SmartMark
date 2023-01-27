
pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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
}

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}
pragma solidity ^0.8.0;


contract Token is ERC20 {
    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000000 * 10 ** uint(decimals()));
    }
}// MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


library VerifySignature {
    function getMessageHash(
        address _from, address _to, uint128 _context, uint256 _amount, uint256 _amount2
    )
        internal pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(_from, _to, _context, _amount, _amount2));
    }
    
    function verify(
        address _signer,
        address _from,
        address _to,
        uint128 _context,
        uint256 _amount,
        uint256 _amount2,
        uint8 v,
        bytes32 r, 
        bytes32 s
    )
        internal pure returns (bool)
    {
        bytes32 messageHash = getMessageHash(_from, _to, _context, _amount, _amount2);
        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(messageHash);

        return ECDSA.recover(ethSignedMessageHash, v, r, s) == _signer;
    }
}// MIT
pragma solidity ^0.8.0;


contract Rewards is Context, Ownable {
  using SafeMath for uint256;
  
  struct RewardClaim {
    address accountKey;
    uint128 gameUuid;
    uint256 oldBalance;
    uint256 newBalance;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }
  
  mapping (uint128 => uint256) private _gameRewarded;
  
  mapping (address => uint256) private _balances;
  
  Token _rewardToken;
  
  uint256 private _totalRewardSupply;
  
  uint256 private _totalRewarded;

  constructor(address rewardToken, uint256 totalSupply) {
    _rewardToken = Token(rewardToken);
    _totalRewardSupply = totalSupply;
  }
  
  function getOwner() external view returns (address) {
    return owner();
  }
  
  function claimReward(RewardClaim[] memory rewardClaims) public returns (uint256) {
    address receiver = _msgSender();
    
    uint256 totalReward = 0;
    
    for (uint i=0; i<rewardClaims.length; i++) {
        RewardClaim memory rewardClaim = rewardClaims[i];
        
        bool signatureVerified = VerifySignature.verify(
            _owner,
            rewardClaim.accountKey,
            receiver,
            rewardClaim.gameUuid,
            rewardClaim.oldBalance,
            rewardClaim.newBalance,
            rewardClaim.v,
            rewardClaim.r,
            rewardClaim.s
        );
        
        require(
            rewardClaim.newBalance > rewardClaim.oldBalance, 
            "Rewards: New Balance must be Greater than Old Balance"
        );
        
        require(
            signatureVerified, 
            "Rewards: Signature Invalid"
        );
        
        require(
            _balances[rewardClaim.accountKey] == rewardClaim.oldBalance, 
            "Rewards: Balance Changed Since Hash Generated"
        );
        
        uint256 reward = rewardClaim.newBalance.sub(rewardClaim.oldBalance);
        
        _totalRewarded = _totalRewarded.add(reward);
        
        _gameRewarded[rewardClaim.gameUuid] = _gameRewarded[rewardClaim.gameUuid].add(reward);
        
        _balances[rewardClaim.accountKey] = _balances[rewardClaim.accountKey].add(reward);
        
        require(
            _balances[rewardClaim.accountKey] == rewardClaim.newBalance, 
            "Rewards: New Balance is not in Expected State"
        );
        
        totalReward = totalReward.add(reward);
    }
    
    _rewardToken.transfer(receiver, totalReward);
    
    return totalReward;
  }
  
  function accountBalance(address accountKey) external view returns (uint256) {
    return _balances[accountKey];
  }
  
  function gameRewardedSupply(uint128 gameUuid) external view returns (uint256) {
    return _gameRewarded[gameUuid];
  }
  
  function totalRewardSupply() external view returns (uint256) {
    return _totalRewardSupply;
  }
  
  function totalRewarded() external view returns (uint256) {
    return _totalRewarded;
  }
  
  function totalRemainingSupply() external view returns (uint256) {
    return _totalRewardSupply.sub(_totalRewarded);
  }
  
  function transferBackToOwner() public onlyOwner returns (uint256) {
    address selfAddress = address(this);
    uint256 balanceOfContract = _rewardToken.balanceOf(selfAddress);
    _rewardToken.transfer(owner(), balanceOfContract);
    return balanceOfContract;
  }
}


