



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




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
}




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




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




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

}



pragma solidity ^0.8.0;




interface InterfaceNoundles {
    function noundleBalance(address owner) external view returns(uint256);
}

interface InterfaceEvilNoundles {
    function companionBalance(address owner) external view returns(uint256);
    function getEvilNoundleOwners() external view returns (address[] memory);
    function getRandomEvilNoundleExternal(uint256 index) external returns(address);

    function lowLandBalance(address owner) external view returns(uint256);
    function midLandBalance(address owner) external view returns(uint256);
    function highLandBalance(address owner) external view returns(uint256);
}

interface InterfaceOriginalRainbows {
    function balanceOf(address owner) external view returns(uint256);
    function burn(address user, uint256 amount) external;
    function claimReward() external;
    function getTotalClaimable(address user) external view returns(uint256);
}

contract OtherSideOfTheRainbows is ERC20, Ownable, Pausable {

    InterfaceNoundles public Noundles;
    InterfaceEvilNoundles public EvilNoundles;
    InterfaceOriginalRainbows public OriginalRainbows;

    bool public UseOriginalRainbowsBalance = true;

    uint256 public startBlock;
    uint256 public startBlockCompanion;

    uint256 public maximumSupply     = 33333333 ether;

    uint256 public interval          = 86400;
    uint256 public rate              = 4 ether;
    uint256 public companionInterval = 86400;
    uint256 public companionRate     = 2 ether;

    uint256 public landPertectionRateLow  = 2;
    uint256 public landPertectionRateMid  = 5;
    uint256 public landPertectionRateHigh = 10;

    bool public stealingEnabled      = false;
    uint256 public stealPercentage   = 20;

    uint256 public tradeLoss         = 35;

    bool public useMultiple          = false;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public companionRewards;
    mapping(address => uint256) public evilRewards;

    mapping(address => uint256) public lastUpdate;
    mapping(address => uint256) public lastUpdateCompanion;

    mapping(address => bool) public extendedAccess;

    modifier onlyFromNoundles() {
        require((msg.sender == address(Noundles)), "Your address doesn't have permissing");
        _;
    }
    modifier onlyFromEvilNoundles() {
        require(msg.sender == address(EvilNoundles));
        _;
    }
    modifier onlyFromRestricted() {
        require(extendedAccess[msg.sender], "Your address does not have permission to use.");
        _;
    }

    constructor(address noundlesAddress, address evilNoundlesAddress, address ogRainbowsAddress) ERC20("NoundlesRainbows", "Rainbows") {

        Noundles         = InterfaceNoundles(noundlesAddress);
        EvilNoundles     = InterfaceEvilNoundles(evilNoundlesAddress);
        OriginalRainbows = InterfaceOriginalRainbows(ogRainbowsAddress);

        startBlock = block.timestamp;
        startBlockCompanion = block.timestamp;

        _pause();
    }


    function pause() public onlyOwner { _pause(); }

    function unpause() public onlyOwner { _unpause(); }

    function setStartBlock(uint256 arg) public onlyOwner {
        if(arg == 0){
            startBlock = block.timestamp;
        }else{
            startBlock = arg;
        }
    }
    function setStartBlockCompanion(uint256 arg) public onlyOwner {
        if(arg == 0){
            startBlockCompanion = block.timestamp;
        }else{
            startBlockCompanion = arg;
        }
    }
    function setStealingStatus(bool arg) public onlyOwner {
        stealingEnabled = arg;
    }
    function setUseOriginalRainbowBalance(bool arg) public onlyOwner {
        UseOriginalRainbowsBalance = arg;
    }

    function setIntervalAndRate(uint256 _interval, uint256 _rate) public onlyOwner {
        interval = _interval;
        rate = _rate;
    }

    function setStealPercentage(uint256 _arg) public onlyOwner { stealPercentage = _arg; }

    function setUseMultiple(bool _arg) public onlyOwner { useMultiple = _arg; }

    function setLandProtectionRates(uint256 _low, uint256 _mid, uint256 _high) public onlyOwner {
        landPertectionRateLow  = _low;
        landPertectionRateMid  = _mid;
        landPertectionRateHigh = _high;
    }

    function setCompanionIntervalAndRate(uint256 _interval, uint256 _rate) public onlyOwner {
        companionInterval = _interval;
        companionRate = _rate;
    }

    function setNoundlesContractAddress(address _noundles) public onlyOwner {
        Noundles = InterfaceNoundles(_noundles);
    }

    function setEvilNoundlesContractAddress(address _noundles) public onlyOwner {
        EvilNoundles = InterfaceEvilNoundles(_noundles);
    }

    function setOGRainbowsContractAddress(address _noundles) public onlyOwner {
        OriginalRainbows = InterfaceOriginalRainbows(_noundles);
    }

    function setAddressAccess(address _noundles, bool _value) public onlyOwner {
        extendedAccess[_noundles] = _value;
    }

    function getAddressAccess(address user) external view returns(bool) {
        return extendedAccess[user];
    }

    function burnMultiple(address [] memory users, uint256 [] memory amount) external onlyFromRestricted {
        for(uint256 i = 0; i < users.length; i += 1){
            _burn(users[i], amount[i]);
        }
    }

    function burn(address user, uint256 amount) external onlyFromRestricted {
        _burn(user, amount);
    }

    function adminCreate(address [] memory users, uint256 [] memory amount) public onlyOwner {
        for(uint256 i = 0; i < users.length; i += 1){
            _mint(users[i], amount[i]);
        }
    }


    function getOGRainbowsClaimable(address user) external view returns(uint256) {

        if(UseOriginalRainbowsBalance == false || address(OriginalRainbows) == address(0)){
            return 0;
        }

        return OriginalRainbows.balanceOf(user);
    }

    function getTotalClaimable(address user) external view returns(uint256) {
        return rewards[user] + companionRewards[user] + getPendingOGReward(user);
    }

    function getTotalCompanionClaimable(address user) external view returns(uint256) {
        return companionRewards[user] + getPendingCompanionReward(user);
    }

    function getTotalStolenClaimable(address user) external view returns(uint256) {
        return evilRewards[user];
    }

    function getLastUpdate(address user) external view returns(uint256) {
        return lastUpdate[user];
    }

    function getLastUpdateCompanion(address user) external view returns(uint256) {
        return lastUpdateCompanion[user];
    }


    function setLastUpdate(address[] memory _noundles, uint256 [] memory values) public onlyOwner {
        for(uint256 i = 0; i < _noundles.length; i += 1){
            lastUpdate[_noundles[i]] = values[i];
        }
    }

    function setLastUpdateCompanion(address[] memory _noundles, uint256 [] memory values) public onlyOwner {
        for(uint256 i = 0; i < _noundles.length; i += 1){
            lastUpdateCompanion[_noundles[i]] = values[i];
        }
    }

    function setMaximumSupply(uint256 _arg) public onlyOwner {
        maximumSupply = _arg;
    }


    function transferTokens(address _from, address _to) onlyFromRestricted whenNotPaused external {

        if(_from != address(0)){
            rewards[_from]            += (getPendingOGReward(_from) * (100 - tradeLoss)) / 100;
            companionRewards[_from]   += (getPendingCompanionReward(_from) * (100 - tradeLoss)) / 100;
            lastUpdate[_from]          = block.timestamp;
            lastUpdateCompanion[_from] = block.timestamp;
        }

        if(_to != address(0)){
            rewards[_to]            += getPendingOGReward(_to);
            companionRewards[_to]   += getPendingCompanionReward(_to);
            lastUpdate[_to]          = block.timestamp;
            lastUpdateCompanion[_to] = block.timestamp;
        }
    }

    function claimReward() external whenNotPaused {

        uint256 _ogRewards   = rewards[msg.sender];
        uint256 _compRewards = companionRewards[msg.sender];
        uint256 _evilRewards = evilRewards[msg.sender];

        uint256 pendingOGRewards        = getPendingOGReward(msg.sender);
        uint256 pendingCompanionRewards = getPendingCompanionReward(msg.sender);
        uint256 pendingOGRainbows       = getOGRainbowsPending(msg.sender);

        rewards[msg.sender]          = 0;
        companionRewards[msg.sender] = 0;
        evilRewards[msg.sender]      = 0;

        lastUpdate[msg.sender]          = block.timestamp;
        lastUpdateCompanion[msg.sender] = block.timestamp;

        uint256 totalRewardsWithoutEvil = _ogRewards + _compRewards + pendingOGRewards + pendingCompanionRewards;

        require(totalSupply() + totalRewardsWithoutEvil < maximumSupply, "No longer able to mint tokens.");

        uint256 percent = totalRewardsWithoutEvil / 100;

        uint256 calculatedStealPercentage = stealPercentage;

        if(stealingEnabled){

            uint256 landProtection = 0;

            if(EvilNoundles.highLandBalance(msg.sender) > 0){
                landProtection = landPertectionRateHigh;
            }else if(EvilNoundles.midLandBalance(msg.sender) > 0){
                landProtection = landPertectionRateMid;
            }else if(EvilNoundles.lowLandBalance(msg.sender) > 0){
                landProtection = landPertectionRateLow;
            }

            if(landProtection < calculatedStealPercentage){
                calculatedStealPercentage -= landProtection;
            }else{
                calculatedStealPercentage = 0;
            }

            address[] memory evilNoundleLists; // = EvilNoundles.getEvilNoundleOwners();

            if(useMultiple == false){
                address singleSelected = EvilNoundles.getRandomEvilNoundleExternal(0);

                if(singleSelected != address(0)){
                    evilNoundleLists = new address[](1);
                    evilNoundleLists[0] = singleSelected;
                }
            }else{
                evilNoundleLists = EvilNoundles.getEvilNoundleOwners();
            }

            uint256 rewardPerEvilNoundle = (percent * calculatedStealPercentage) / evilNoundleLists.length;

            for(uint256 _index; _index < evilNoundleLists.length; _index += 1){
                evilRewards[evilNoundleLists[_index]] += rewardPerEvilNoundle;
            }
        }else{
            calculatedStealPercentage = 0;
        }

        uint256 totalRewards = (percent * (100 - calculatedStealPercentage)) + _evilRewards + pendingOGRainbows;

        if(pendingOGRainbows > 0){
            OriginalRainbows.burn(msg.sender, pendingOGRainbows);
        }

        _mint(msg.sender, totalRewards);
    }

    function getPendingOGReward(address user) public view returns(uint256) {

        if(block.timestamp < startBlock){
            return 0;
        }

        return Noundles.noundleBalance(user) *
               rate *
               (block.timestamp - (lastUpdate[user] >= startBlock ? lastUpdate[user] : startBlock)) /
               interval;
    }

    function getPendingCompanionReward(address user) public view returns(uint256) {

        if(block.timestamp < startBlockCompanion){
            return 0;
        }

        return EvilNoundles.companionBalance(user) *
               companionRate *
               (block.timestamp - (lastUpdateCompanion[user] >= startBlockCompanion ? lastUpdateCompanion[user] : startBlockCompanion)) /
               companionInterval;
    }

    function getOGRainbowsPending(address user) public view returns(uint256) {

        if(UseOriginalRainbowsBalance == false || address(OriginalRainbows) == address(0)){
            return 0;
        }

        return OriginalRainbows.balanceOf(user);
    }

    function getOGRainbowsPendingUnclaimed(address user) public view returns(uint256) {

        if(UseOriginalRainbowsBalance == false || address(OriginalRainbows) == address(0)){
            return 0;
        }

        return OriginalRainbows.getTotalClaimable(user);
    }
}