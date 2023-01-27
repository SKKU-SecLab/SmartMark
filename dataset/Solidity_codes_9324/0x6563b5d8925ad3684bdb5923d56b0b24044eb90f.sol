
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
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

}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
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
}// MIT

pragma solidity ^0.8.9;


contract SacredCoin {

    uint public numberOfGuidelines;

    string [] private mergedGuidelines;

    struct Guideline {
        string summary;
        string guideline;
    }

    Guideline[] public guidelines;

    event GuidelineCreated(string guidelineSummary, string guideline);

    function setGuideline(string memory _guidelineSummary, string memory _guideline) internal {

        Guideline memory guideline = Guideline(_guidelineSummary, _guideline);

        guidelines.push(guideline);


        emit GuidelineCreated(_guidelineSummary, _guideline);

        numberOfGuidelines++;
    }

    function returnSingleGuideline(uint _index) public view returns(string memory, string memory) {
        return (guidelines[_index].summary, guidelines[_index].guideline);
    }

    function returnAllGuidelines() public view returns(Guideline[] memory) {
        return (guidelines);
    }
}// MIT

pragma solidity ^0.8.9;



contract GratitudeCoin is ERC20, Ownable, SacredCoin {

    string private gratitudeStatement;

    constructor() ERC20("GratitudeCoin", "GRTFUL") {
        _mint(msg.sender, 1000000 * 10 ** decimals());

        setGuideline("Think of something to be grateful for.", "Every time you buy, sell or otherwise use the coin, take a second to think of something that you are grateful for. It could be your family, your friends, the neighborhood you are living in or your pet tortoise. Ideally, you should think about something different that you're grateful for every time you use the coin.");
    }

    address private crowdsaleAddress;

    event GratitudeEvent(string gratitudeStatment);

    function crowdsale() public view returns(address) {
        return(crowdsaleAddress);
    }

    function setCrowdsaleAddress(address _crowdsaleAddress) public onlyOwner {
        crowdsaleAddress = _crowdsaleAddress;
    }

    modifier onlyCrowdsale() {
        require( _msgSender() == crowdsaleAddress, "only the crowdsale contract can call this function externally");
        _;
    }

    function emitGratitudeEventSimpleFromCrowdsale(address buyerAddress) public onlyCrowdsale {
        string memory _buyerAddressString = addressToString(buyerAddress);
        gratitudeEventSimple(_buyerAddressString);
    }

    function emitGratitudeEventPersonalizedFromCrowdsale(string memory name, string memory gratitudeObject) public onlyCrowdsale {
        gratitudeEventPersonalized(name, gratitudeObject);
    }

    function transferFromCrowdsale(address recipient, uint256 amount) public virtual onlyCrowdsale returns (bool) {
        super.transfer(recipient, amount);
        return true;
    }

    function gratitudeEventSimple(string memory _address) private {
        emit GratitudeEvent(string(abi.encodePacked(_address, " is thinking about something that they're grateful for (see Gratitude Coin's guidelines for details)")));
    }

    function gratitudeEventPersonalized(string memory name, string memory gratitudeObject) private {
        emit GratitudeEvent(string(abi.encodePacked(name, " is grateful for ", gratitudeObject)));
    }

    function transferGrateful(address to, uint tokens, string memory name, string memory gratitudeObject) public {
        super.transfer(to, tokens);
        gratitudeEventPersonalized(name, gratitudeObject);
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = '0';
        _string[1] = 'x';
        for(uint i = 0; i < 20; i++) {
            _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        super.transfer(recipient, amount);
        string memory _senderString = addressToString(msg.sender);
        gratitudeEventSimple(_senderString);
        return true;
    }
}