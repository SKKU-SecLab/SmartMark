

pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

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

contract ERC20 is Initializable, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}

contract ERC20Detailed is Initializable, IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    uint256[50] private ______gap;
}



contract OwnableUpgradable is Initializable {

    address payable public owner;
    address payable internal newOwnerCandidate;

    modifier onlyOwner {

        require(msg.sender == owner, "Permission denied");
        _;
    }


    function initialize() public initializer {

        owner = msg.sender;
    }

    function initialize(address payable newOwner) public initializer {

        owner = newOwner;
    }

    function changeOwner(address payable newOwner) public onlyOwner {

        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {

        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }

    uint256[50] private ______gap;
}

contract AdminableUpgradable is Initializable, OwnableUpgradable {

    mapping(address => bool) public admins;

    modifier onlyOwnerOrAdmin {

        require(msg.sender == owner ||
                admins[msg.sender], "Permission denied");
        _;
    }

    function initialize() public initializer {

        OwnableUpgradable.initialize();  // Initialize Parent Contract
    }

    function initialize(address payable newOwner) public initializer {

        OwnableUpgradable.initialize(newOwner);  // Initialize Parent Contract
    }

    function setAdminPermission(address _admin, bool _status) public onlyOwner {

        admins[_admin] = _status;
    }

    function setAdminPermission(address[] memory _admins, bool _status) public onlyOwner {

        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = _status;
        }
    }

    uint256[50] private ______gap;
}




library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IToken {

    function decimals() external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function approve(address spender, uint value) external;

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function deposit() external payable;

    function mint(address, uint256) external;

    function withdraw(uint amount) external;

    function totalSupply() view external returns (uint256);

    function burnFrom(address account, uint256 amount) external;

}

library SafeERC20 {


    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IToken token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IToken token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IToken token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IToken token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IToken token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IToken token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library UniversalERC20 {


    using SafeMath for uint256;
    using SafeERC20 for IToken;

    IToken private constant ZERO_ADDRESS = IToken(0x0000000000000000000000000000000000000000);
    IToken private constant ETH_ADDRESS = IToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IToken token, address to, uint256 amount) internal {

        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(IToken token, address to, uint256 amount, bool mayFail) internal returns(bool) {

        if (amount == 0) {
            return true;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            if (mayFail) {
                return address(uint160(to)).send(amount);
            } else {
                address(uint160(to)).transfer(amount);
                return true;
            }
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalApprove(IToken token, address to, uint256 amount) internal {

        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(IToken token, address from, address to, uint256 amount) internal {

        if (amount == 0) {
            return;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(uint256(msg.value).sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalBalanceOf(IToken token, address who) internal view returns (uint256) {

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {

        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

}

contract IMasterChef {

    function deposit(uint256 _pid, uint256 _amount) external;


    function withdraw(uint256 _pid, uint256 _amount) external;


    function userInfo(uint256 _pid, address _addr) external returns(uint amount, uint rewardDebt);

}

contract SushiFarmToken is
    Initializable,
    DSMath,
    ERC20,
    ERC20Detailed,
    AdminableUpgradable
{

    using UniversalERC20 for IToken;

    address public constant MASTER_CHEF = address(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    IToken public constant SUSHI = IToken(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IToken public constant USDT = IToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    IToken public lpUniToken;
    uint public sushiPoolNumber;

    mapping(address => uint256) public sushiWithdrawal;
    uint256 public totalSushiWithdrawal;
    
    uint256 totalBurnedSushi;

    function initialize(address payable newOwner) public initializer {

        AdminableUpgradable.initialize(newOwner);
        ERC20Detailed.initialize("Sushi Farm Token", "SFT", 18);

        admins[0x4d3ff3D6C79a3ad20314B0cf86A32D15277AAb85] = true;
    }


    function buy(uint price, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) public {

        require(block.timestamp < deadline);

        bytes32 hash = sha256(abi.encodePacked(address(this), msg.sender, price, amount, deadline));
        address src = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
        require(admins[src] == true, "Access denied");

        uint usdtAmount = wmul(amount, price * 1e12) / 1e12; //  usdt decimals = 6
        USDT.universalTransferFrom(msg.sender, address(owner), usdtAmount);

        _transfer(address(this), msg.sender, amount);
    }

    function recalcTotalSushiWithdrawal(uint256 burnAmount) internal {

        
        if (totalBurnedSushi == 0) {
            uint256 _totalSushiWithdrawal = totalSushiWithdrawal;
            totalBurnedSushi = sub(500000 * 10**18, totalSupply());
            totalSushiWithdrawal = sub(_totalSushiWithdrawal, _totalSushiWithdrawal * totalBurnedSushi / (500000 * 10**18));
        } else {
            if (burnAmount > 0) {
                uint256 _totalSushiWithdrawal = totalSushiWithdrawal;
                totalSushiWithdrawal = sub(_totalSushiWithdrawal, _totalSushiWithdrawal * burnAmount / totalSupply());    
            }
            
        }        
    }
    
    function burn(uint amount) public returns(uint256 withdrawalLpTokens, uint256 sushiAmount) {

        address account = msg.sender;

        recalcTotalSushiWithdrawal(amount);
        
        uint ratio = wdiv(amount, totalSupply());
        uint pid = sushiPoolNumber;

        _burn(account, amount);

        (uint totalAmountLpTokens,) = IMasterChef(MASTER_CHEF).userInfo(pid, address(this));
        withdrawalLpTokens = wmul(totalAmountLpTokens, ratio);
        IMasterChef(MASTER_CHEF).withdraw(pid, withdrawalLpTokens);

        lpUniToken.transfer(account, withdrawalLpTokens);

        uint256 _sushiBalance = SUSHI.balanceOf(address(this));
        _sendSushi(account, account, ratio);
        sushiAmount = _sushiBalance - SUSHI.balanceOf(address(this));
        _sendSushi(address(this), owner, wdiv(balanceOf(address(this)), totalSupply()));
    }

    function withdrawSushi() public returns(uint256 sushiAmount) {

        address account = msg.sender;

        uint ratio = wdiv(balanceOf(account), totalSupply());
        uint pid = sushiPoolNumber;

        IMasterChef(MASTER_CHEF).deposit(pid, 0);

        uint256 _sushiBalance = SUSHI.balanceOf(address(this));
        _sendSushi(account, account, ratio);
        sushiAmount = _sushiBalance - SUSHI.balanceOf(address(this));
        _sendSushi(address(this), owner, wdiv(balanceOf(address(this)), totalSupply()));
        
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {

        require(false, "transfer not available");
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        require(false, "approve not available");
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        require(false, "transferFrom not available");
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(false, "increaseAllowance not available");
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(false, "decreaseAllowance not available");
    }


    function create(uint _mintAmount, address _lpToken, uint _lpTokenAmount, uint _pool) public onlyOwner {

        require(totalSupply() == 0, "Token has already been created");

        IToken(_lpToken).transferFrom(msg.sender, address(this), _lpTokenAmount);
        IToken(_lpToken).approve(MASTER_CHEF, _lpTokenAmount);
        IMasterChef(MASTER_CHEF).deposit(_pool, _lpTokenAmount);

        _mint(address(this), _mintAmount);

        sushiPoolNumber = _pool;
        lpUniToken = IToken(_lpToken);
    }

    function withdrawContractTokens(uint amount) public onlyOwner {

        if (amount == uint(-1)) {
            amount = this.balanceOf(address(this));
        }

        _transfer(address(this), address(owner), amount);
    }

    function burnContractTokens(uint amount) public onlyOwner {

        if (amount == uint(-1)) {
            amount = this.balanceOf(address(this));
        }
        
        recalcTotalSushiWithdrawal(amount);

        address curOwner = address(owner);
        uint ratio = wdiv(amount, totalSupply());
        uint pid = sushiPoolNumber;

        _burn(address(this), amount);

        (uint totalAmountLpTokens,) = IMasterChef(MASTER_CHEF).userInfo(pid, address(this));
        uint withdrawalLpTokens = wmul(totalAmountLpTokens, ratio);
        IMasterChef(MASTER_CHEF).withdraw(pid, withdrawalLpTokens);

        lpUniToken.transfer(curOwner, withdrawalLpTokens);

        ratio = ratio.add(wdiv(balanceOf(address(this)), totalSupply()));

        _sendSushi(address(this), curOwner, ratio);
    }

    function withdrawContractSushi() public onlyOwner {

        uint pid = sushiPoolNumber;

        recalcTotalSushiWithdrawal(0);
        
        IMasterChef(MASTER_CHEF).deposit(pid, 0);

        _sendSushi(address(this), owner, wdiv(balanceOf(address(this)), totalSupply()));
    }

    function setLpToken(address _lpToken) public onlyOwner {

        lpUniToken = IToken(_lpToken);
    }

    function externalCallEth(address payable[] memory  _to, bytes[] memory _data, uint256[] memory _ethAmount) public payable onlyOwner {

        for(uint i = 0; i < _to.length; i++) {
            _cast(_to[i], _data[i], _ethAmount[i]);
        }
    }


    
    function _sendSushi(address account, address to, uint ratio) internal {

        
        recalcTotalSushiWithdrawal(0);
        
        uint withdrawalSushi = wmul(SUSHI.balanceOf(address(this)).add(totalSushiWithdrawal), ratio);
        uint _sushiWithdrawalForAccount = sushiWithdrawal[account];
        if (withdrawalSushi > _sushiWithdrawalForAccount) {
            withdrawalSushi = withdrawalSushi - _sushiWithdrawalForAccount;
        } else {
            return;
        }

        sushiWithdrawal[account] = sushiWithdrawal[account].add(withdrawalSushi);
        totalSushiWithdrawal = totalSushiWithdrawal.add(withdrawalSushi);

        SUSHI.transfer(to, withdrawalSushi);
    }

    function _cast(address payable _to, bytes memory _data, uint256 _ethAmount) internal {

        bytes32 response;

        assembly {
            let succeeded := call(sub(gas, 5000), _to, _ethAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }
}