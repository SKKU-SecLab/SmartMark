
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT


pragma solidity ^0.8.0;

contract EmergencyWithdraw{

    struct EmergencyData{
        address payable beneficiary;                                                                                 // Defines an address to send contract's balance to in case something goes really wrong.
        address[] signatories;                                                                                       // List of addresses that are required to sign in order to perform the withdraw.
    }

    EmergencyData emergency;

    function emergencyWithdraw_start(address payable _withdrawTo, address[] memory signatories) virtual internal{    // IMPORTANT: Wrap this in function restricted to Owner
        require (_withdrawTo != address(this) );                                                                     // Ensure a new address is being proposed
        emergency.beneficiary = _withdrawTo;
        emergency.signatories = signatories;
        removeAddressItem(emergency.signatories, msg.sender);                                                        // Remove Sender from signatories (Sender's signature is implicit)
    }
    function emergencyWithdraw_getAddress() view public returns(address){                                            // Show the current candidate
        return (emergency.beneficiary);
    }
    function emergencyWithdraw_requiredSignatories() view public returns(address[] memory){
        return(emergency.signatories);
    }
    function emergencyWithdraw_approve() public returns (bool success) {
        require(emergency.beneficiary != address(0) && emergency.beneficiary!=address(this));
        if(!removeAddressItem(emergency.signatories, msg.sender)){ revert("Sender is not allowed to sign or has already signed"); }
        if(emergency.signatories.length == 0){                                                                       // If no signatories are left to sign,
            (success, ) = emergency.beneficiary.call{value: address(this).balance}("");                              // perform the withdraw
            delete emergency.beneficiary;                                                                            // Clear the emergency address variable
        }
    }
    function removeAddressItem(address[] storage _list, address _item) private returns(bool success){                //Not a very efficient implementation but unlikely to run this function, ever
        for(uint i=0; i<_list.length; i++){
            if(_item == _list[i]){
                _list[i]=_list[_list.length-1];
                _list.pop();
                success=true;
                break;
            }
        }
    }
    
}// MIT


pragma solidity ^0.8.0;


contract POPSteamWallet is ERC20, Ownable, Pausable, ReentrancyGuard, EmergencyWithdraw {

    event AddedShareholder(address indexed shareHolder, address[] shareholderList);
    event RemovedShareholder(address indexed shareHolder, address[] shareholderList);
    event DividendsClaimed(address indexed, uint);
    
    using SafeMath for uint256;

    uint256 dividendsToDistribute;
    address[] shareholders;                                                                              // Array keeping track of the shareholders
    mapping (address => uint256) shareholderIndex;                                                       // Shareholder index in the two arrays above
    mapping (address => uint256) dividends;                                                              // Accrued dividends for each shareholder
    mapping (address => bool) isShareholder;                                                             // Flags which addresses are shareholders

    constructor(string memory name, string memory symbol) Ownable() ERC20(name, symbol) {
        _mint(msg.sender, 100 * 10 ** decimals());                                                       // Mint 10k shares - such amount is fixed
    }

    function decimals() public pure override returns (uint8) {                                           // Override the decimals function
        return 2;
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override{   // Also updates shareholders database
        bool isMinting = from == address(0);                                                             // Checks if the transaction is a minting
        require(isMinting || amount <= balanceOf(from), "The amount exceeds the sender's balance");      // Check if sender has enough funds
        distributeDividends();                                                                           // Distribute dividends before updating the shareholder list
        addShareholder(to);                                                                              // Add recipient to the shareholder list (the function performs no action if the address is already in the list)
        if(isMinting || amount == balanceOf( from )){ removeShareholder( from ); }                       // Remove sender from the shareholders if transfers all shares, does nothing if the transfer is a minting
        super._beforeTokenTransfer(from, to, amount);
    }

    function addShareholder(address newShareholder) private returns(bool added){
        if(!isShareholder[newShareholder]){                                                              // Do if not a shareholder yet
            shareholderIndex[newShareholder] = shareholders.length;                                      // Store shareholder's index in array
            shareholders.push(newShareholder);                                                           // Append shareholder's address to array
            isShareholder[newShareholder]=true;                                                          // Flag the address as a shareholder
            emit AddedShareholder(newShareholder, shareholders);                                         // Emit event
            added=true;
        }
        else{ added=false; }
    }

    function removeShareholder(address shareholder) private returns(bool removed){
        if(isShareholder[shareholder]){                                                                  // Execute if the address is a shareholder
            shareholders[ shareholderIndex[shareholder] ] = shareholders[ shareholders.length - 1 ];     // Override item to be deleted with last item in array (address)
            shareholderIndex[ shareholders[ shareholders.length - 1 ] ] = shareholderIndex[shareholder]; // Update index of the array item being "moved"
            shareholders.pop();                                                                          // Remove last array item
            isShareholder[shareholder] = false;                                                          // Flag address removed from array as NOT a shareholder
            emit RemovedShareholder(shareholder, shareholders);                                          // Emit event
            removed = true;
        }
        else{ removed=false; }                                                                           // Do nothing if not a shareholder
    }

    function countShareholders() view public returns(uint count){
        count=shareholders.length;
    }

    function listShareholders() view public returns(address[] memory){
        return shareholders;
    }

    function totalAccruedDividends() view public returns(uint256){
        return address(this).balance;
    }

    function accruedDividends(address shareholder) view public returns(uint256 accrued){
        accrued = dividends[shareholder] + calculateDividend(shareholder, dividendsToDistribute);
    }

    function calculateDividend(address shareholder, uint256 value) view private returns(uint256 dividend){
        dividend = value.mul(balanceOf(shareholder)).div(100 * 10 ** decimals());
    }

    function distributeDividends() private returns(bool){
        if(dividendsToDistribute>0){
            uint256 dividendsToDistribute_before = dividendsToDistribute;                                // Used at the end to check invariances
            uint256 distributed;                                                                         // Keeps the count of dividends distributed in the for loop below
            for(uint256 i=0; i<countShareholders(); i++){
                address shareholder = shareholders[i];
                uint256 dividend = calculateDividend(shareholder, dividendsToDistribute);
                dividends[shareholder] += dividend;
                distributed += dividend;
            }
            dividendsToDistribute -= distributed;                                                        // Use subtract instead of overriding to zero in case there is any reminder
            assert(distributed <= dividendsToDistribute_before);
            return true;
        }
        else{return false;}
    }

    receive() external payable nonReentrant {
        dividendsToDistribute+=msg.value;
    }

    function claimDividends() public whenNotPaused nonReentrant returns(bool){
        require( accruedDividends(msg.sender)>0, "This address has no dividends to claim");
        distributeDividends();                                                                           // Make sure all dividends are distributed before claiming
        uint256 value = dividends[msg.sender];
        dividends[msg.sender]=0;
        (bool sent, ) = msg.sender.call{value: value}("");
        emit DividendsClaimed(msg.sender, value);
        return sent;
    }

    function emergencyWithdraw_propose(address payable _withdrawTo) public onlyOwner{
        super.emergencyWithdraw_start(_withdrawTo, shareholders);
    }

    function pauseContract() public onlyOwner {
        _pause();
    }
    function unpauseContract() public onlyOwner {
        _unpause();
    }

}