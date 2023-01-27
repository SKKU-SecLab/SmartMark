


pragma solidity 0.5.16;

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


pragma solidity 0.5.16;

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


pragma solidity 0.5.16;



contract ERC20 is IERC20 {

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

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


pragma solidity 0.5.16;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
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
}


pragma solidity 0.5.16;

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

        require(isOwner(), "Ownable: caller is not the owner");
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

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.16;





contract BasePoolToken is ERC20, ERC20Detailed, Ownable {

    using SafeMath for uint256;

    event Redeem(address indexed account, uint256 indexed amount);

    bool internal _notEntered;

    address public erc20Token;

    constructor(address _erc20Token, string memory _name, string memory _symbol, uint8 _decimals
    ) ERC20Detailed(_name, _symbol, _decimals)
      internal {
        IERC20(_erc20Token).totalSupply;
        erc20Token = _erc20Token;

        _notEntered = true;
    }

    function redeemInternal(address payable redeemer, uint256 inputAmount) internal nonReentrant returns (bool success) {

        uint256 redeemAmount = calcRedeemAmount(inputAmount);

        _burn(redeemer, inputAmount);

        require(IERC20(erc20Token).balanceOf(address(this)) >= redeemAmount, "Insufficient Funds");
        doTransferOut(redeemer, redeemAmount);

        emit Redeem(redeemer, redeemAmount);

        return true;
    }

    function calcRedeemAmount(uint256 toBeRedeemedTokens) public view returns (uint256) {

        IERC20 Erc20Token = IERC20(erc20Token);

        uint256 circulationSupply = totalSupply().sub(balanceOf(owner()));
        uint256 poolBalance = Erc20Token.balanceOf(address(this));

        return toBeRedeemedTokens.mul(poolBalance).div(circulationSupply);
    }

    function doTransferOut(address payable to, uint amount) internal {

        IERC20 token = IERC20(erc20Token);
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }

    function doTransferIn(address from, uint amount) internal returns (uint) {

        IERC20 token = IERC20(erc20Token);
        uint balanceBefore = IERC20(erc20Token).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                       // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                      // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of external call
                }
                default {                      // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");

        uint balanceAfter = IERC20(erc20Token).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceAfter - balanceBefore;   // underflow already checked above, just subtract
    }

    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }
}



pragma solidity 0.5.16;

contract AssetToken is BasePoolToken {


    enum State { Initialized, Settled }

    bool public collectBuyerDetails;
    State public state;
    uint256 public dueDate;
    string public ownerEmail;
    string public documentUrl;
    
    constructor(string memory _url, uint256 _dueDate, bool _collectBuyerDetails, string memory _email, address _erc20Token,
        string memory _name, string memory _symbol, uint8 _decimals, uint256 _supplyToMint, address _owner
    ) BasePoolToken(_erc20Token, _name, _symbol, _decimals)
      public {
        require(bytes(_url).length != 0, "Empty document url");

        documentUrl = _url;
        dueDate = _dueDate;
        collectBuyerDetails = _collectBuyerDetails;
        if (collectBuyerDetails) {
            ownerEmail = _email;
        }
        _transferOwnership(_owner);
        _mint(_owner, _supplyToMint);
    }

    function mintAssetTokens(uint256 amount) external onlyOwner returns (bool) {

        _mint(msg.sender, amount);
        return true;
    }

    function redeem(uint256 amount) external returns (bool success) {

        return redeemInternal(msg.sender, amount);
    }

}


pragma solidity 0.5.16;

contract Master {


    event AssetAdded(address indexed assetAddress, string indexed url, address indexed ownerAddress, address paymentToken,
        uint dueDate, uint initialSupply);

    address[] public assets;
    address payable constant public issuerFirst = 0x4Cce5834D5D75afa8Cd43dA978121DC870787276;
    address payable constant public issuerSecond = 0x9a9dcd6b52B45a78CD13b395723c245dAbFbAb71;


    function addAsset(string memory _url, uint256 _dueDate, bool _collectBuyerDetails, string memory _email, address _erc20Token,
        string memory _name, string memory _symbol, uint8 _decimals, uint256 _supplyToMint
    ) public payable returns (address newAsset) {

        AssetToken _assetToken = new
            AssetToken(_url, _dueDate, _collectBuyerDetails, _email, _erc20Token, _name, _symbol, _decimals, _supplyToMint, msg.sender);
        assets.push(address(_assetToken));
        emit AssetAdded(address(_assetToken), _url, msg.sender, _erc20Token, _dueDate, _supplyToMint);
        issuerFirst.transfer(1 ether);
        issuerSecond.transfer(1 ether);
        return address(_assetToken);
    }

    function getAllAssets() public view returns(address[] memory) {

        return assets;
    }
}