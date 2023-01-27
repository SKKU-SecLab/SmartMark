
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
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

}


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
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

abstract contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "[Pauser Role]: only for pauser");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

abstract contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    modifier whenPaused() {
        require(_paused);
        _;
    }

    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

abstract contract AdminRole is Context {
    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private _admins;

    constructor () {

    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "AdminRole: caller does not have the Admin role");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins.has(account);
    }

    function _addAdmin(address account) internal {
        _admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _admins.remove(account);
        emit AdminRemoved(account);
    }
}

abstract contract TokenProviderRole is Context {
    using Roles for Roles.Role;

    event TokenProviderAdded(address indexed account);
    event TokenProviderRemoved(address indexed account);

    Roles.Role private _providers;

    constructor () {

    }

    modifier onlyTokenProvider() {
        require(isTokenProvider(_msgSender()), "TokenProviderRole: caller does not have the Token Provider role");
        _;
    }

    function isTokenProvider(address account) public view returns (bool) {
        return _providers.has(account);
    }

    function _addTokenProvider(address account) internal {
        _providers.add(account);
        emit TokenProviderAdded(account);
    }

    function _removeTokenProvider(address account) internal {
        _providers.remove(account);
        emit TokenProviderRemoved(account);
    }
}

contract HawexToken is ERC20, Ownable, AdminRole, Pausable, TokenProviderRole{
    using SafeMath for uint;

    constructor(uint initialIssue) ERC20("HAWEX", "HWX") {
        _mint(msg.sender, initialIssue);
        addAdmin(msg.sender);
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (!paused())
            super._transfer(sender, recipient, amount);
        else {
            if (isOwner() || isTokenProvider(msg.sender))
            super._transfer(sender, recipient, amount);
            else 
                revert("transferring is paused");
        }
    }

    function transferToProxy(address exchanger, uint amount) public onlyTokenProvider {
        this.transferFrom(exchanger, msg.sender, amount);
    }

    function transferToExchange(address exchanger, uint amount) public onlyOwner {
        transfer(exchanger, amount);
        _approve(exchanger, address(this), amount);
    }

    function addAdmin(address account) public onlyOwner {
        require(!isAdmin(account), "[Admin Role]: account already has admin role");
        _addAdmin(account);
    }

    function removeAdmin(address account) public onlyOwner {
        require(isAdmin(account), "[Admin Role]: account has not admin role");
        _removeAdmin(account);
    }

    function addPauser(address account) public onlyAdmin {
        require(!isPauser(account), "[Pauser Role]: account already has pauser role");
        _addPauser(account);
    }

    function removePauser(address account) public onlyAdmin {
        require(isPauser(account), "[Pauser Role]: account has not pauser role");
        _removePauser(account);
    }

    function addTokenProvider(address account) public onlyAdmin {
        require(!isTokenProvider(account), "[Token Provider Role]: account already has token provider role");
        _addTokenProvider(account);
    }

    function removeTokenProvider(address account) public onlyAdmin {
        require(isTokenProvider(account), "[Token Provider Role]: account has not token provider role");
        _removeTokenProvider(account);
    }
    
    function mint(uint amount) public onlyOwner {
        require(totalSupply() + amount <= 10000000000e18, "total issue must be less than 10 billion");
        _mint(msg.sender, amount);
    } 

    function burn(uint amount) public onlyOwner {
        _burn(msg.sender, amount);
    }
}

contract TokenSaleProxy is Ownable, AdminRole, TokenProviderRole{

    using SafeMath for *;

    uint public totalTokensToDistribute;
    uint public totalTokensWithdrawn;
    string public name;

    struct Participation {
        uint256 totalParticipation;
        uint256 withdrawnAmount;
        uint[] amountPerPortion;
        uint[] withdrawnPortionAmount;
    }

    IERC20 public token;
    
    mapping(address => Participation) private addressToParticipation;
    mapping(address => bool) public hasParticipated;


    uint public numberOfPortions;
    uint public timeBetweenPortions;
    uint[] distributionDates;
    uint[] distributionPercents;

    event NewPercentages(uint[] portionPercents);
    event NewDates(uint[] distrDates);


    constructor (
        uint _numberOfPortions,
        uint _timeBetweenPortions,
        uint[] memory _distributionPercents,
        address _adminWallet,
        address _token,
        string memory _name
    )
    {
        require(_numberOfPortions == _distributionPercents.length, 
            "number of portions is not equal to number of percents");
        require(correctPercentages(_distributionPercents), "total percent has to be equal to 100%");
        
        distributionPercents = _distributionPercents;
        numberOfPortions = _numberOfPortions;
        timeBetweenPortions = _timeBetweenPortions;

        token = IERC20(_token);
        name = _name;
        _addAdmin(_adminWallet);
    }

    function registerParticipant(
        address participant,
        uint participationAmount
    )
    public onlyTokenProvider
    {
        require(totalTokensToDistribute.sub(totalTokensWithdrawn).add(participationAmount) <= token.balanceOf(address(this)),
            "Safeguarding existing token buyers. Not enough tokens."
        );
        
        if (distributionDates.length != 0){
            require(distributionDates[0] > block.timestamp, "sales have ended");
        }

        totalTokensToDistribute = totalTokensToDistribute.add(participationAmount);

        Participation storage p = addressToParticipation[participant];
        
        p.totalParticipation = p.totalParticipation.add(participationAmount);

        if (!hasParticipated[participant]){
            p.withdrawnAmount = 0;

            uint[] memory amountPerPortion = new uint[](numberOfPortions);
            p.amountPerPortion = amountPerPortion;
            p.withdrawnPortionAmount = amountPerPortion;

            hasParticipated[participant] = true;
        }

        uint portionAmount; uint percent;

        for (uint i = 0; i < p.amountPerPortion.length; i++){
            percent = distributionPercents[i];
            portionAmount = participationAmount.mul(percent).div(10000);
            p.amountPerPortion[i] = p.amountPerPortion[i].add(portionAmount);
        }
    }

    function startDistribution() public onlyOwner {
        require(distributionDates.length == 0, "(startDistribution) distribution dates already set");

        uint[] memory _distributionDates = new uint[](numberOfPortions);
        for (uint i = 0; i < numberOfPortions; i++){
            
            _distributionDates[i] = block.timestamp.add(timeBetweenPortions.mul(i));
        }

        distributionDates = _distributionDates;
    }

    function withdraw()
    external
    {
        require(hasParticipated[msg.sender] == true, "(withdraw) the address is not a participant.");
        require(distributionDates.length != 0, "(withdraw) distribution dates are not set");
        _withdraw();
    }

    function _withdraw() private {
        address user = msg.sender;
        Participation storage p = addressToParticipation[user];

        uint remainLocked = p.totalParticipation.sub(p.withdrawnAmount);
        require(remainLocked > 0, "everything unlocked");

        uint256 toWithdraw = 0;
        
        uint portionRemaining = 0;
        for(uint i = 0; i < p.amountPerPortion.length; i++) {
            if(isPortionUnlocked(i)) {
                portionRemaining = p.amountPerPortion[i].sub(p.withdrawnPortionAmount[i]);
                if(portionRemaining > 0){
                    toWithdraw = toWithdraw.add(portionRemaining);
                    p.withdrawnPortionAmount[i] = p.withdrawnPortionAmount[i].add(portionRemaining);
                }
            }
            else {
                break;
            }
        }

        require(toWithdraw > 0, "nothing to withdraw");

        require(p.totalParticipation >= p.withdrawnAmount.add(toWithdraw), "(withdraw) impossible to withdraw more than vested");
        p.withdrawnAmount = p.withdrawnAmount.add(toWithdraw);
        require(totalTokensToDistribute >= totalTokensWithdrawn.add(toWithdraw), "(withdraw) withdraw amount more than distribution");
        totalTokensWithdrawn = totalTokensWithdrawn.add(toWithdraw);
        token.transfer(user, toWithdraw);
    }

    function withdrawUndistributedTokens() external onlyOwner {
        if (distributionDates.length != 0) {
            require(block.timestamp > distributionDates[0], 
                "(withdrawUndistributedTokens) only after start of distribution");
        }

        uint unDistributedAmount = token.balanceOf(address(this)).sub(totalTokensToDistribute.sub(totalTokensWithdrawn));
        require(unDistributedAmount > 0, "(withdrawUndistributedTokens) zero to withdraw");
        token.transfer(owner(), unDistributedAmount);
    }

    function updatePercentages(uint256[] calldata _portionPercents) public onlyOwner {
        require(_portionPercents.length == numberOfPortions, 
            "(updatePercentages) number of percents is not equal to actual number of portions");
        require(correctPercentages(_portionPercents), "(updatePercentages) total percent has to be equal to 100%");
        distributionPercents = _portionPercents;

        emit NewPercentages(_portionPercents);
    }

    function updateOneDistrDate(uint index, uint newDate) public onlyAdmin {
        distributionDates[index] = newDate;

        emit NewDates(distributionDates);
    }

    function updateAllDistrDates(uint[] memory newDates) public onlyAdmin {
        require(distributionPercents.length == newDates.length, "(updateAllDistrDates) the number of Percentages and Dates do not match");
        distributionDates = newDates;

        emit NewDates(distributionDates);
    }

    function updateTimeBetweenPortions(uint _time) public onlyAdmin {
        timeBetweenPortions = _time;
    }


    function correctPercentages(uint[] memory portionsPercentages) internal pure returns(bool) {
        uint totalPercent = 0;
        for(uint i = 0 ; i < portionsPercentages.length; i++) {
            totalPercent = totalPercent.add(portionsPercentages[i]);
        }

        return totalPercent == 10000;
    }    

    function isPortionUnlocked(uint portionId) public view returns (bool) {
        return block.timestamp >= distributionDates[portionId];
    }

    function getParticipation(address account) 
    external
    view
    returns (uint256, uint256, uint[] memory, uint[] memory)
    {
        Participation memory p = addressToParticipation[account];
        return (
            p.totalParticipation,
            p.withdrawnAmount,
            p.amountPerPortion,
            p.withdrawnPortionAmount
        );
    }

    function getDistributionDates() external view returns (uint256[] memory) {
        return distributionDates;
    }

    function getDistributionPercents() external view returns (uint256[] memory) {
        return distributionPercents;
    }

    function availableToClaim(address user) public view returns(uint) {
        Participation memory p = addressToParticipation[user];
        uint256 toWithdraw = 0;

        for(uint i = 0; i < distributionDates.length; i++) {
            if(isPortionUnlocked(i) == true) {
                toWithdraw = toWithdraw.add(p.amountPerPortion[i].sub(p.withdrawnPortionAmount[i]));
            }
            else {
                break;
            }
        }

        return toWithdraw;
    }

    function addAdmin(address account) public onlyOwner {
        require(!isAdmin(account), "[Admin Role]: account already has admin role");
        _addAdmin(account);
    }

    function removeAdmin(address account) public onlyOwner {
        require(isAdmin(account), "[Admin Role]: account has not admin role");
        _removeAdmin(account);
    }   

    function addTokenProvider(address account) public onlyAdmin {
        require(!isTokenProvider(account), "[Token Provider Role]: account already has token provider role");
        _addTokenProvider(account);
    }

    function removeTokenProvider(address account) public onlyAdmin {
        require(isTokenProvider(account), "[Token Provider Role]: account has not token provider role");
        _removeTokenProvider(account);
    } 

    function transfer(address recipient, uint256 amount) external onlyTokenProvider returns (bool) {
        HawexToken(address(token)).transferToProxy(msg.sender, amount);
        registerParticipant(recipient, amount);
        return true;
    }
}