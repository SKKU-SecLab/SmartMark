
pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;


contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

contract DXTokenRegistry is Ownable {
    event AddList(uint256 listId, string listName);
    event AddToken(uint256 listId, address token);
    event RemoveToken(uint256 listId, address token);

    enum TokenStatus {NULL, ACTIVE}

    struct TCR {
        uint256 listId;
        string listName;
        address[] tokens;
        mapping(address => TokenStatus) status;
        uint256 activeTokenCount;
    }

    mapping(uint256 => TCR) public tcrs;
    uint256 public listCount;

    function addList(string memory _listName) public onlyOwner returns (uint256) {
        listCount++;
        tcrs[listCount].listId = listCount;
        tcrs[listCount].listName = _listName;
        tcrs[listCount].activeTokenCount = 0;
        emit AddList(listCount, _listName);
        return listCount;
    }

    function addTokens(uint256 _listId, address[] memory _tokens) public onlyOwner {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        for (uint32 i = 0; i < _tokens.length; i++) {
            require(
                tcrs[_listId].status[_tokens[i]] != TokenStatus.ACTIVE,
                'DXTokenRegistry : DUPLICATE_TOKEN'
            );
            tcrs[_listId].tokens.push(_tokens[i]);
            tcrs[_listId].status[_tokens[i]] = TokenStatus.ACTIVE;
            tcrs[_listId].activeTokenCount++;
            emit AddToken(_listId, _tokens[i]);
        }
    }

    function removeTokens(uint256 _listId, address[] memory _tokens) public onlyOwner {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        for (uint32 i = 0; i < _tokens.length; i++) {
            require(
                tcrs[_listId].status[_tokens[i]] == TokenStatus.ACTIVE,
                'DXTokenRegistry : INACTIVE_TOKEN'
            );
            tcrs[_listId].status[_tokens[i]] = TokenStatus.NULL;
            uint256 tokenIndex = getTokenIndex(_listId, _tokens[i]);
            tcrs[_listId].tokens[tokenIndex] = tcrs[_listId].tokens[tcrs[_listId].tokens.length -
                1];
            tcrs[_listId].tokens.pop();
            tcrs[_listId].activeTokenCount--;
            emit RemoveToken(_listId, _tokens[i]);
        }
    }

    function getTokens(uint256 _listId) public view returns (address[] memory) {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        return tcrs[_listId].tokens;
    }

    function getTokensRange(
        uint256 _listId,
        uint256 _start,
        uint256 _end
    ) public view returns (address[] memory tokensRange) {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        require(
            _start <= tcrs[_listId].tokens.length && _end < tcrs[_listId].tokens.length,
            'DXTokenRegistry : INVALID_RANGE'
        );
        require(_start <= _end, 'DXTokenRegistry : INVALID_INVERTED_RANGE');
        tokensRange = new address[](_end - _start + 1);
        uint32 activeCount = 0;
        for (uint256 i = _start; i <= _end; i++) {
            if (tcrs[_listId].status[tcrs[_listId].tokens[i]] == TokenStatus.ACTIVE) {
                tokensRange[activeCount] = tcrs[_listId].tokens[i];
                activeCount++;
            }
        }
    }

    function isTokenActive(uint256 _listId, address _token) public view returns (bool) {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        return tcrs[_listId].status[_token] == TokenStatus.ACTIVE ? true : false;
    }

    function getTokenIndex(uint256 _listId, address _token) internal view returns (uint256) {
        for (uint256 i = 0; i < tcrs[_listId].tokens.length; i++) {
            if (tcrs[_listId].tokens[i] == _token) {
                return i;
            }
        }
    }

    function getTokensData(address[] memory _tokens)
        public
        view
        returns (
            string[] memory names,
            string[] memory symbols,
            uint256[] memory decimals
        )
    {
        names = new string[](_tokens.length);
        symbols = new string[](_tokens.length);
        decimals = new uint256[](_tokens.length);
        for (uint32 i = 0; i < _tokens.length; i++) {
            names[i] = ERC20(_tokens[i]).name();
            symbols[i] = ERC20(_tokens[i]).symbol();
            decimals[i] = ERC20(_tokens[i]).decimals();
        }
    }

    function getExternalBalances(address _trader, address[] memory _assetAddresses)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory balances = new uint256[](_assetAddresses.length);
        for (uint256 i = 0; i < _assetAddresses.length; i++) {
            balances[i] = ERC20(_assetAddresses[i]).balanceOf(_trader);
        }
        return balances;
    }
}