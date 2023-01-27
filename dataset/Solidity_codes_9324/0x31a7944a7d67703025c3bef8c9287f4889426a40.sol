
pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

library SafeMath {

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
}


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0 <0.6.0;


contract ERC20Swap {

    struct Swap {
        uint256 amount;
        address erc20Token;

        address claimAddress;
        address refundAddress;

        uint256 timelock;

        bool pending;
    }

    mapping (bytes32 => Swap) private swaps;

    event Claim(bytes32 _preimageHash);
    event Creation(bytes32 _preimageHash);
    event Refund(bytes32 _preimageHash);

    modifier onlyPendingSwaps(bytes32 _preimageHash) {

        require(swaps[_preimageHash].pending == true, "there is no pending swap with this preimage hash");
        _;
    }

    function () external {
        revert("this contract does not accept Ether");
    }

    function create(bytes32 _preimageHash, uint256 _amount, address _erc20Token, address _claimAddress, uint256 _timelock) external {

        require(_amount > 0, "the amount must not be zero");
        require(swaps[_preimageHash].amount == 0, "a swap with this preimage hash exists already");

        ERC20 tokenContract = ERC20(_erc20Token);

        require(tokenContract.allowance(msg.sender, address(this)) >= _amount, "requested amount exceeds allowance");
        require(tokenContract.transferFrom(msg.sender, address(this), _amount), "could not transfer ERC20 tokens");

        swaps[_preimageHash] = Swap({
            amount: _amount,
            erc20Token: _erc20Token,
            claimAddress: _claimAddress,
            refundAddress: msg.sender,
            timelock: _timelock,
            pending: true
        });

        emit Creation(_preimageHash);
    }

    function claim(bytes32 _preimageHash, bytes calldata _preimage) external onlyPendingSwaps(_preimageHash) {

        require(_preimageHash == sha256(_preimage), "the preimage does not correspond the provided hash");

        swaps[_preimageHash].pending = false;
        Swap memory swap = swaps[_preimageHash];

        ERC20 tokenContract = ERC20(swap.erc20Token);
        require(tokenContract.transfer(swap.claimAddress, swap.amount), "could not transfer ERC20 tokens");

        emit Claim(_preimageHash);
    }

    function refund(bytes32 _preimageHash) external onlyPendingSwaps(_preimageHash) {

        require(swaps[_preimageHash].timelock <= block.timestamp, "swap has not timed out yet");

        swaps[_preimageHash].pending = false;
        Swap memory swap = swaps[_preimageHash];

        ERC20 tokenContract = ERC20(swap.erc20Token);
        require(tokenContract.transfer(swap.refundAddress, swap.amount), "could not transfer ERC20 tokens");

        emit Refund(_preimageHash);
    }

    function getSwapInfo(bytes32 _preimageHash) external view returns (
        uint256 amount,
        address erc20Token,
        address claimAddress,
        address refundAddress,
        uint256 timelock,
        bool pending
    ) {

        Swap memory swap = swaps[_preimageHash];
        return (swap.amount, swap.erc20Token, swap.claimAddress, swap.refundAddress, swap.timelock, swap.pending);
    }
}