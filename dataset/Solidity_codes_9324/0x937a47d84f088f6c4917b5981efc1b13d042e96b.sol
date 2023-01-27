

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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

abstract contract Ownable is Context {
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

contract ERC20Mintable is ERC20, Ownable {
    using SafeMath for uint;

    constructor (string memory name_, string memory symbol_, uint totalSupply_) 
        ERC20(name_, symbol_)
        public 
    {
        _mint(_msgSender(), totalSupply_);
    }

    function mint(address to, uint256 amount) 
        public
        onlyOwner
        returns(bool)
    {
        _mint(to, amount);
        return true;
    }
}

contract OwnAssetBridge is Ownable {
    using SafeMath for uint;
    enum RevertDirection{ FromNative, ToNative }

    event CrossChainTransfer(address indexed token, string recipientAccountHash, uint amount);
    event CrossChainTransfer(string txHash, address recipient);

    mapping (string => address) public erc20Tokens;
    mapping (address => string) public assetHashes;
    mapping (string => string) public accountsForAssets;
    mapping (string => address) public pendingCrossChainTransfers;
    mapping (string => string) public pendingSignedTxs;

    address public governor;
    uint public targetTransferFee;
    uint public nativeTransferFee;
    uint public bridgeFee;

    constructor(uint _bridgeFee, uint _targetTransferFee, uint _nativeTransferFee)
        public
    {
        bridgeFee = _bridgeFee;
        targetTransferFee = _targetTransferFee;
        nativeTransferFee = _nativeTransferFee;
        governor = _msgSender();
    }

    modifier onlyGovernor() {
        require(_msgSender() == governor, "Caller is not the governor");
        _;
    }


    function bridgeErc20Token(address _token, string calldata _assetHash, string calldata _accountHash)
        external
        onlyGovernor
        payable
    {
        require(erc20Tokens[_assetHash] == address(0));
        require(bytes(assetHashes[_token]).length == 0);
        require(bytes(accountsForAssets[_assetHash]).length == 0);
        require(IERC20(_token).balanceOf(address(this)) == 0);
        require(msg.value >= bridgeFee);

        erc20Tokens[_assetHash] = _token;
        assetHashes[_token] = _assetHash;
        accountsForAssets[_assetHash] = _accountHash;
    }

    function bridgeAsset(
        string calldata _assetHash, 
        string calldata _accountHash, 
        string calldata _assetName, 
        string calldata _assetSymbol, 
        uint _totalSupply)
        external
        onlyGovernor
        payable
    {
        require(erc20Tokens[_assetHash] == address(0));
        require(bytes(accountsForAssets[_assetHash]).length == 0);
        require(msg.value >= bridgeFee);

        address token = address(new ERC20Mintable(_assetName, _assetSymbol, _totalSupply));

        erc20Tokens[_assetHash] = token;
        assetHashes[token] = _assetHash;
        accountsForAssets[_assetHash] = _accountHash;
    }

    function removeBridge(address _token)
        external
        onlyGovernor
    {
        string memory assetHash = assetHashes[_token];

        require(bytes(assetHash).length != 0);
        require(erc20Tokens[assetHash] == _token);
        require(bytes(accountsForAssets[assetHash]).length != 0);

        uint bridgeBalance = IERC20(_token).balanceOf(address(this));
        require(bridgeBalance == 0 || bridgeBalance == IERC20(_token).totalSupply());

        delete erc20Tokens[assetHash];
        delete assetHashes[_token];
        delete accountsForAssets[assetHash];
    }

    function mintErc20Token(address _token, uint _amount)
        external
        onlyGovernor
    {
        require(ERC20Mintable(_token).mint(address(this), _amount));
    }



    function transferToNativeChain(address _token, string calldata _recipientAccountHash, uint _amount)
        external
        payable
    {
        require(msg.value >= nativeTransferFee, "Insufficient fee is paid");
        require(bytes(assetHashes[_token]).length != 0, "Token is not bridged");
        require(IERC20(_token).transferFrom(_msgSender(), address(this), _amount), "Transfer failed");

        emit CrossChainTransfer(_token, _recipientAccountHash, _amount);
    }

    function transferFromNativeChain(string calldata _txHash, string calldata _signature, address _recipient)
        external
        payable
    {
        require(msg.value >= targetTransferFee, "Insufficient fee is paid");
        require(pendingCrossChainTransfers[_txHash] == address(0), "Recipient is already determined");
        require(bytes(pendingSignedTxs[_txHash]).length == 0, "Signature is already determined");

        pendingCrossChainTransfers[_txHash] = _recipient;
        pendingSignedTxs[_txHash] = _signature;

        emit CrossChainTransfer(_txHash, _recipient);
    }

    function confirmTransfer(string calldata _txHash, IERC20 _token, uint _amount)
        external
        onlyOwner
    {
        address recipient = pendingCrossChainTransfers[_txHash];
        require(recipient != address(0), "Recipient does not exist");

        delete pendingCrossChainTransfers[_txHash];
        delete pendingSignedTxs[_txHash];

        require(_token.transfer(recipient, _amount), "Transfer failed");
    }

    function revertTransferFromNativeChain(string calldata _txHash)
        external
        onlyOwner
    {
        require(pendingCrossChainTransfers[_txHash] != address(0), "Tx does not exist");

        delete pendingCrossChainTransfers[_txHash];
        delete pendingSignedTxs[_txHash];
    }

    function revertTransferToNativeChain(string calldata _txHash, IERC20 _token, address _recipient, uint _amount)
        external
        onlyOwner
    {
        require(_token.transfer(_recipient, _amount), "Transfer failed");
    }


    function setGovernor(address _governor)
        external
        onlyOwner
    {
        governor = _governor;
    }

    function setTargetTransferFee(uint _amount)
        external
        onlyOwner
    {
        targetTransferFee = _amount;
    }

    function setNativeTransferFee(uint _amount)
        external
        onlyOwner
    {
        nativeTransferFee = _amount;
    }

    function setBridgeFee(uint _amount)
        external
        onlyOwner
    {
        bridgeFee = _amount;
    }

    function withdrawFee(uint _amount)
        external
        onlyOwner
        returns (bool)
    {
        payable(owner()).transfer(_amount);
        return true;
    }
}