


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
    address private _owner;

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


abstract contract ERC20Capped is ERC20 {
    uint256 immutable private _cap;

    constructor (uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}




pragma solidity ^0.8.0;


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
}



pragma solidity ^0.8.0;







pragma solidity ^0.8.0;

interface ILiquidityProtectionService {
    event Blocked(address pool, address trader, string trap);

    function getLiquidityPool(address tokenA, address tokenB)
    external view returns(address);

    function LiquidityAmountTrap_preValidateTransfer(
        address from, address to, uint amount,
        address counterToken, uint8 trapBlocks, uint128 trapAmount)
    external returns(bool passed);

    function FirstBlockTrap_preValidateTransfer(
        address from, address to, uint amount, address counterToken)
    external returns(bool passed);

    function LiquidityPercentTrap_preValidateTransfer(
        address from, address to, uint amount,
        address counterToken, uint8 trapBlocks, uint64 trapPercent)
    external returns(bool passed);

    function LiquidityActivityTrap_preValidateTransfer(
        address from, address to, uint amount,
        address counterToken, uint8 trapBlocks, uint8 trapCount)
    external returns(bool passed);

    function isBlocked(address counterToken, address who)
    external view returns(bool);
}




pragma solidity ^0.8.0;

abstract contract UsingLiquidityProtectionService {
    bool private protected = true;
    uint64 internal constant HUNDRED_PERCENT = 1e18;

    function liquidityProtectionService() internal pure virtual returns(address);
    function LPS_isAdmin() internal view virtual returns(bool);
    function LPS_balanceOf(address _holder) internal view virtual returns(uint);
    function LPS_transfer(address _from, address _to, uint _value) internal virtual;
    function counterToken() internal pure virtual returns(address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    }
    function protectionChecker() internal view virtual returns(bool) {
        return ProtectionSwitch_manual();
    }

    function FirstBlockTrap_skip() internal pure virtual returns(bool) {
        return false;
    }

    function LiquidityAmountTrap_skip() internal pure virtual returns(bool) {
        return false;
    }
    function LiquidityAmountTrap_blocks() internal pure virtual returns(uint8) {
        return 5;
    }
    function LiquidityAmountTrap_amount() internal pure virtual returns(uint128) {
        return 5000 * 1e18; // Only valid for tokens with 18 decimals.
    }

    function LiquidityPercentTrap_skip() internal pure virtual returns(bool) {
        return false;
    }
    function LiquidityPercentTrap_blocks() internal pure virtual returns(uint8) {
        return 50;
    }
    function LiquidityPercentTrap_percent() internal pure virtual returns(uint64) {
        return HUNDRED_PERCENT / 1000; // 0.1%
    }

    function LiquidityActivityTrap_skip() internal pure virtual returns(bool) {
        return false;
    }
    function LiquidityActivityTrap_blocks() internal pure virtual returns(uint8) {
        return 30;
    }
    function LiquidityActivityTrap_count() internal pure virtual returns(uint8) {
        return 15;
    }

    function lps() private pure returns(ILiquidityProtectionService) {
        return ILiquidityProtectionService(liquidityProtectionService());
    }

    function LPS_beforeTokenTransfer(address _from, address _to, uint _amount) internal {
        if (protectionChecker()) {
            if (!protected) {
                return;
            }
            require(FirstBlockTrap_skip() || lps().FirstBlockTrap_preValidateTransfer(
                _from, _to, _amount, counterToken()), 'FirstBlockTrap: blocked');
            require(LiquidityAmountTrap_skip() || lps().LiquidityAmountTrap_preValidateTransfer(
                _from,
                _to,
                _amount,
                counterToken(),
                LiquidityAmountTrap_blocks(),
                LiquidityAmountTrap_amount()), 'LiquidityAmountTrap: blocked');
            require(LiquidityPercentTrap_skip() || lps().LiquidityPercentTrap_preValidateTransfer(
                _from,
                _to,
                _amount,
                counterToken(),
                LiquidityPercentTrap_blocks(),
                LiquidityPercentTrap_percent()), 'LiquidityPercentTrap: blocked');
            require(LiquidityActivityTrap_skip() || lps().LiquidityActivityTrap_preValidateTransfer(
                _from,
                _to,
                _amount,
                counterToken(),
                LiquidityActivityTrap_blocks(),
                LiquidityActivityTrap_count()), 'LiquidityActivityTrap: blocked');
        }
    }

    function revokeBlocked(address[] calldata _holders, address _revokeTo) external {
        require(LPS_isAdmin(), 'UsingLiquidityProtectionService: not admin');
        require(protectionChecker(), 'UsingLiquidityProtectionService: protection removed');
        protected = false;
        for (uint i = 0; i < _holders.length; i++) {
            address holder = _holders[i];
            if (lps().isBlocked(counterToken(), _holders[i])) {
                LPS_transfer(holder, _revokeTo, LPS_balanceOf(holder));
            }
        }
        protected = true;
    }

    function disableProtection() external {
        require(LPS_isAdmin(), 'UsingLiquidityProtectionService: not admin');
        protected = false;
    }

    function isProtected() public view returns(bool) {
        return protected;
    }

    function ProtectionSwitch_manual() internal view returns(bool) {
        return protected;
    }

    function ProtectionSwitch_timestamp(uint _timestamp) internal view returns(bool) {
        return not(passed(_timestamp));
    }

    function ProtectionSwitch_block(uint _block) internal view returns(bool) {
        return not(blockPassed(_block));
    }

    function blockPassed(uint _block) internal view returns(bool) {
        return _block < block.number;
    }

    function passed(uint _timestamp) internal view returns(bool) {
        return _timestamp < block.timestamp;
    }

    function not(bool _condition) internal pure returns(bool) {
        return !_condition;
    }
}






contract spheriumToken is ERC20, ERC20Capped, Ownable, UsingLiquidityProtectionService{

    using SafeMath for uint256;

    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);



    constructor() ERC20("Spherium Token", "SPHRI") ERC20Capped(100000000 * (10**uint256(18))){}

     function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
        super._mint(account, amount);
    }


    function mint(address account, uint256 amount)public onlyOwner{
        uint256 amount_ = amount * (10**uint256(18));
        _mint(account,amount_);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        super._transfer(sender,recipient,amount);
        _moveDelegates(_delegates[sender], _delegates[recipient], amount);

    }

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "SPHRI::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "SPHRI::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "SPHRI::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "SPHRI::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "SPHRI::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }



    function _beforeTokenTransfer(address _from, address _to, uint _amount) internal override {
        super._beforeTokenTransfer(_from, _to, _amount);
        LPS_beforeTokenTransfer(_from, _to, _amount);
    }

    function LPS_isAdmin() internal view override returns(bool) {
        return _msgSender() == owner();
    }
    function liquidityProtectionService() internal pure override returns(address) {
        return 0xaabAe39230233d4FaFf04111EF08665880BD6dFb; // Replace with the correct address.
    }
    function LPS_balanceOf(address _holder) internal view override returns(uint) {
        return balanceOf(_holder);
    }
    function LPS_transfer(address _from, address _to, uint _value) internal override {
        _transfer(_from, _to, _value);
    }

    function protectionChecker() internal view override returns(bool) {
        return ProtectionSwitch_timestamp(1624665599); // Switch off protection on Friday, June 25, 2021 11:59:59 PM GMT
    }

    function counterToken() internal pure override returns(address) {
        return 0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT
    }

    function FirstBlockTrap_skip() internal pure override returns(bool) {
        return false;
    }

    function LiquidityAmountTrap_skip() internal pure override returns(bool) {
        return false;
    }
    function LiquidityAmountTrap_blocks() internal pure override returns(uint8) {
        return 4;
    }
    function LiquidityAmountTrap_amount() internal pure override returns(uint128) {
        return 19000 * 1e18; // Only valid for tokens with 18 decimals.
    }

    function LiquidityPercentTrap_skip() internal pure override returns(bool) {
        return false;
    }
    function LiquidityPercentTrap_blocks() internal pure override returns(uint8) {
        return 6;
    }
    function LiquidityPercentTrap_percent() internal pure override returns(uint64) {
        return HUNDRED_PERCENT / 25; // 4%
    }

    function LiquidityActivityTrap_skip() internal pure override returns(bool) {
        return false;
    }
    function LiquidityActivityTrap_blocks() internal pure override returns(uint8) {
        return 3;
    }
    function LiquidityActivityTrap_count() internal pure override returns(uint8) {
        return 8;
    }

}