
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

}// AGPL-3.0-or-later

pragma solidity ^0.8.0;


contract Authority {
	
	address[] public authorities;
	mapping(address => bool) public isAuthority;

	constructor() {
		authorities.push(msg.sender);
		isAuthority[msg.sender] = true;
	}

	modifier onlySuperAuthority() {
		require(authorities[0] == msg.sender, "Authority: Only Super Authority");
		_;
	}
	
	modifier onlyAuthority() {
		require(isAuthority[msg.sender], "Authority: Only Authority");
		_;
	}

	function addAuthority(address _new, bool _change) external onlySuperAuthority {
		require(!isAuthority[_new], "Authoritys: Already authority");
		isAuthority[_new] = true;
		if (_change) {
			authorities.push(authorities[0]);
			authorities[0] = _new;
		} else {
			authorities.push(_new);
		}
	}

	function removeAuthority(address _new) external onlySuperAuthority {
		require(isAuthority[_new], "Authority: Not authority");
		require(_new != authorities[0], "Authority: Cannot remove super authority");
		for (uint i = 1; i < authorities.length; i++) {
			if (authorities[i] == _new) {
				authorities[i] = authorities[authorities.length - 1];
				authorities.pop();
				break;
			}
		}
		isAuthority[_new] = false;
	}

	function getAuthoritiesSize() external view returns(uint) {
		return authorities.length;
	}
}// MIT
pragma solidity ^0.8.0;


contract sBigFoot is ERC20, Authority {

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogStakingUpdated(address staking);

    address public staking;
	address private initializer;

    modifier onlyStaking() {
        require(msg.sender == staking, "sBigFoot: onlyStaking");
        _;
    }

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 50_000_000_000 * 10**DECIMALS;

    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = type(uint128).max; // (2^128) - 1

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    mapping(address => mapping(address => uint256)) private _allowedFragments;

    string public constant EIP712_REVISION = "1";
    bytes32 public constant EIP712_DOMAIN =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    mapping(address => uint256) private _nonces;
    
	constructor() ERC20("Staked BigFoot", "sBGFT") {
		initializer = msg.sender;
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;
	}

	function init(address staking_) public {
		require(msg.sender == initializer, "sBigFoot: Sender is not initializer");
		require(staking_ != address(0), "sBigFoot: Staking cannot be address zero");
		
		staking = staking_;
        _gonBalances[staking_] = TOTAL_GONS;
		initializer = address(0);

        emit Transfer(address(0x0), staking_, _totalSupply);
		emit LogStakingUpdated( staking_ );
    }


    function setStaking(address staking_) external onlyAuthority {
        staking = staking_;
        emit LogStakingUpdated(staking_);
    }

    function rebase(uint256 epoch, uint256 delta) external onlyStaking returns (uint256) {
        if (delta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }
		uint256 amount;
		uint256 circulatingSupply_ = circulatingSupply();
        if (circulatingSupply_ > 0) {
			amount = delta * _totalSupply / circulatingSupply_;
        } else {
			amount = delta;
		}

        _totalSupply = _totalSupply + amount; 

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS / _totalSupply;


        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

	function circulatingSupply() public view returns (uint256) {
		return _totalSupply - balanceOf(staking);
	}

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who] / _gonsPerFragment;
    }

    function scaledBalanceOf(address who) external view returns (uint256) {
        return _gonBalances[who];
    }

    function scaledTotalSupply() external pure returns (uint256) {
        return TOTAL_GONS;
    }

    function nonces(address who) public view returns (uint256) {
        return _nonces[who];
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN,
                    keccak256(bytes(name())),
                    keccak256(bytes(EIP712_REVISION)),
                    chainId,
                    address(this)
                )
            );
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        uint256 gonValue = value * _gonsPerFragment;

        _gonBalances[msg.sender] = _gonBalances[msg.sender] - gonValue;
        _gonBalances[to] = _gonBalances[to] + gonValue;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender] - value;

        uint256 gonValue = value * _gonsPerFragment;
        _gonBalances[from] = _gonBalances[from] - gonValue;
        _gonBalances[to] = _gonBalances[to] + gonValue;

        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender] + addedValue;

        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        _allowedFragments[msg.sender][spender] = (subtractedValue >= oldValue)
            ? 0
            : oldValue - subtractedValue;

        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(block.timestamp <= deadline);

        uint256 ownerNonce = _nonces[owner];
        bytes32 permitDataDigest = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, value, ownerNonce, deadline)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), permitDataDigest)
        );

        require(owner == ecrecover(digest, v, r, s));

        _nonces[owner] = ownerNonce + 1;

        _allowedFragments[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}