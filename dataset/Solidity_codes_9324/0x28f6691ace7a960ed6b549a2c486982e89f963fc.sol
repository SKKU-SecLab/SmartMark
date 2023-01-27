
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

}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity ^0.8.0;
pragma abicoder v2;


interface iPixelTigers {
    function ownerGenesisCount(address owner) external view returns(uint256);
    function numberOfLegendaries(address owner) external view returns(uint256);
    function numberOfUniques(address owner) external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function tokenGenesisOfOwner(address owner) external view returns(uint256[] memory);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract PixelERC20 is ERC20, Ownable {

    uint256 constant public BASE_RATE = 7 ether;
    uint256 constant public OG_RATE = 10 ether;
    uint256 constant public LEGENDARY_UNIQUE_RATE = 15 ether;
    uint256 constant public BONUS_RATE = 1 ether;
    uint256 constant public TICKET_PRICE = 10 ether;

    uint256 public amountLeftForReserve = 145000 ether;
    uint256 public amountTakenFromReserve;
    uint256 public numEntriesMain;
    uint256 public numEntriesSub;
    uint256 public numEntriesEvent;
    uint256 public numEntriesSpend;
    uint256 public START = 1643130000;
    uint256 public priceEvents;
    uint256 public maxEventEntries;
    uint256 public priceSpend;

    bool public rewardPaused = false;
    bool public mainRaffleActive = false;
    bool public subRaffleActive = false;
    bool public eventsActive = false;

    mapping(address => uint256) public minttime;
    mapping(address => uint256) private storeRewards;
    mapping(address => uint256) private lastUpdate;

    mapping(address => bool) public allowedAddresses;

    iPixelTigers public PixelTigers;

    constructor(address nftAddress) ERC20("PIXEL", "PXL") {
        PixelTigers = iPixelTigers(nftAddress);
    }

    function airdrop(address[] calldata to, uint256 amount) external onlyOwner {
        uint256 totalamount = to.length * amount * 1000000000000000000;
        require(totalamount <= amountLeftForReserve, "No more reserved");
        for(uint256 i; i < to.length; i++){
            _mint(to[i], amount * 1000000000000000000);
        }
        amountLeftForReserve -= totalamount;
        amountTakenFromReserve += totalamount;
    }

    function timeStamp(address user) external {
        require(msg.sender == address(PixelTigers));
        storeRewards[user] += pendingReward(user);
        minttime[user] = block.timestamp;
        lastUpdate[user] = block.timestamp;
    }

    function enterMainRaffle(uint256 numTickets) external {
        require(PixelTigers.balanceOf(msg.sender) > 0, "Do not own any Tigers");
        require(mainRaffleActive, "Main Raffle not active");
        _burn(msg.sender, (numTickets*TICKET_PRICE));

        numEntriesMain += numTickets;
    }

    function enterSubRaffle(uint256 numTickets) external {
        require(PixelTigers.balanceOf(msg.sender) > 0, "Do not own any Tigers");
        require(subRaffleActive, "Sub Raffle not active");
        _burn(msg.sender, (numTickets*TICKET_PRICE));

        numEntriesSub += numTickets;
    }

    function enterEvents(uint256 count) external {
        require(PixelTigers.balanceOf(msg.sender) > 0, "Do not own any Tigers");
        require(eventsActive, "Sub Raffle not active");
        require(numEntriesEvent + count <= maxEventEntries, "No more slots");
        _burn(msg.sender, (count*priceEvents));

        numEntriesEvent += count;
    }

    function spend(uint256 count) external {
        require(PixelTigers.balanceOf(msg.sender) > 0, "Do not own any Tigers");
        _burn(msg.sender, (count*priceSpend));

        numEntriesSpend += count;
    }

    function burn(address user, uint256 amount) external {
        require(allowedAddresses[msg.sender] || msg.sender == address(PixelTigers), "Address does not have permission to burn");
        _burn(user, amount);
    }

    function claimReward() external {
        require(!rewardPaused, "Claiming of $pixel has been paused"); 
        _mint(msg.sender, pendingReward(msg.sender) + storeRewards[msg.sender]);
        storeRewards[msg.sender] = 0;
        lastUpdate[msg.sender] = block.timestamp;
    }

    function rewardSystemUpdate(address from, address to) external {
        require(msg.sender == address(PixelTigers));
        if(from != address(0)){
            storeRewards[from] += pendingReward(from);
            lastUpdate[from] = block.timestamp;
        }
        if(to != address(0)){
            storeRewards[to] += pendingReward(to);
            lastUpdate[to] = block.timestamp;
        }
    }

    function totalTokensClaimable(address user) external view returns(uint256) {    
        return pendingReward(user) + storeRewards[user];
    }

    function numberOG(address user) external view returns(uint256){
        return PixelTigers.numberOfUniques(user) - PixelTigers.numberOfLegendaries(user);
    }

    function numLegendaryAndUniques(address user) external view returns(uint256){
        return PixelTigers.numberOfLegendaries(user);
    }

    function numNormalTigers(address user) external view returns(uint256){
        return PixelTigers.ownerGenesisCount(user) - PixelTigers.numberOfUniques(user);
    }

    function userRate(address user) external view returns(uint256){
        uint256 numberNormal = PixelTigers.ownerGenesisCount(user) - PixelTigers.numberOfUniques(user);
        uint256 numOG = PixelTigers.numberOfUniques(user) - PixelTigers.numberOfLegendaries(user);
        return PixelTigers.numberOfLegendaries(user) * LEGENDARY_UNIQUE_RATE + numOG * OG_RATE + (PixelTigers.ownerGenesisCount(user) - PixelTigers.numberOfUniques(user)) * BASE_RATE + (2 <= numberNormal ? 2 : numberNormal) * BONUS_RATE * numOG;
    }

    function pendingReward(address user) internal view returns(uint256) {
        uint256 numOG = PixelTigers.numberOfUniques(user) - PixelTigers.numberOfLegendaries(user);
        uint256 numberNormal = PixelTigers.ownerGenesisCount(user) - PixelTigers.numberOfUniques(user);
        if (minttime[user] == 0) {
            return PixelTigers.numberOfLegendaries(user) * LEGENDARY_UNIQUE_RATE * (block.timestamp - (lastUpdate[user] >= START ? lastUpdate[user] : START)) /86400 + numOG * OG_RATE * (block.timestamp - (lastUpdate[user] >= START ? lastUpdate[user] : START)) /86400 + numberNormal * BASE_RATE * (block.timestamp - (lastUpdate[user] >= START ? lastUpdate[user] : START)) /86400 + (2 <= numberNormal ? 2 : numberNormal) * BONUS_RATE * numOG * (block.timestamp - (lastUpdate[user] >= START ? lastUpdate[user] : START)) /86400;
        } else{
            return PixelTigers.numberOfLegendaries(user) * LEGENDARY_UNIQUE_RATE * (block.timestamp - (lastUpdate[user] >= minttime[user] ? lastUpdate[user] : minttime[user])) /86400 + numOG * OG_RATE * (block.timestamp - (lastUpdate[user] >= minttime[user] ? lastUpdate[user] : minttime[user])) /86400 + numberNormal * BASE_RATE * (block.timestamp - (lastUpdate[user] >= minttime[user] ? lastUpdate[user] : minttime[user])) /86400 + (2 <= numberNormal ? 2 : numberNormal) * BONUS_RATE * numOG * (block.timestamp - (lastUpdate[user] >= minttime[user] ? lastUpdate[user] : minttime[user])) /86400;
        }
    }

    function setAllowedAddresses(address _address, bool _access) public onlyOwner {
        allowedAddresses[_address] = _access;
    }

    function setERC721(address ERC721Address) external onlyOwner {
        PixelTigers = iPixelTigers(ERC721Address);
    }

    function setEvent(uint256 price, uint256 maxentries) external onlyOwner {
        priceEvents = price * 1000000000000000000;
        maxEventEntries = maxentries;
    }

    function setSpend(uint256 price) external onlyOwner {
        priceSpend = price * 1000000000000000000;
    }

    function toggleReward() public onlyOwner {
        rewardPaused = !rewardPaused;
    }

    function clearMainRaffleList() external onlyOwner{
        numEntriesMain = 0;
    }

    function clearSubRaffleList() external onlyOwner{
        numEntriesSub = 0;
    }

    function clearEvents() external onlyOwner{
        numEntriesEvent = 0;
    }

    function toggleMainRaffle() public onlyOwner {
        mainRaffleActive = !mainRaffleActive;
    }

    function toggleSubRaffle() public onlyOwner {
        subRaffleActive = !subRaffleActive;
    }

    function toggleEvents() public onlyOwner {
        eventsActive = !eventsActive;
    }
}