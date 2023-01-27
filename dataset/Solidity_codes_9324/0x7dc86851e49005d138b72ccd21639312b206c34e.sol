

pragma solidity ^0.5.2;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


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

        require(isOwner(), "Not Owner!");
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

        require(newOwner != address(0),"Address 0 could not be owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IAdminTools {

    function setFFPAddresses(address, address) external;

    function setMinterAddress(address) external returns(address);

    function getMinterAddress() external view returns(address);

    function getWalletOnTopAddress() external view returns (address);

    function setWalletOnTopAddress(address) external returns(address);


    function addWLManagers(address) external;

    function removeWLManagers(address) external;

    function isWLManager(address) external view returns (bool);

    function addWLOperators(address) external;

    function removeWLOperators(address) external;

    function renounceWLManager() external;

    function isWLOperator(address) external view returns (bool);

    function renounceWLOperators() external;


    function addFundingManagers(address) external;

    function removeFundingManagers(address) external;

    function isFundingManager(address) external view returns (bool);

    function addFundingOperators(address) external;

    function removeFundingOperators(address) external;

    function renounceFundingManager() external;

    function isFundingOperator(address) external view returns (bool);

    function renounceFundingOperators() external;


    function addFundsUnlockerManagers(address) external;

    function removeFundsUnlockerManagers(address) external;

    function isFundsUnlockerManager(address) external view returns (bool);

    function addFundsUnlockerOperators(address) external;

    function removeFundsUnlockerOperators(address) external;

    function renounceFundsUnlockerManager() external;

    function isFundsUnlockerOperator(address) external view returns (bool);

    function renounceFundsUnlockerOperators() external;


    function isWhitelisted(address) external view returns(bool);

    function getWLThresholdBalance() external view returns (uint256);

    function getMaxWLAmount(address) external view returns(uint256);

    function getWLLength() external view returns(uint256);

    function setNewThreshold(uint256) external;

    function changeMaxWLAmount(address, uint256) external;

    function addToWhitelist(address, uint256) external;

    function addToWhitelistMassive(address[] calldata, uint256[] calldata) external returns (bool);

    function removeFromWhitelist(address, uint256) external;

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


interface IToken {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function paused() external view returns (bool);

    function pause() external;

    function unpause() external;

    function isImportedContract(address) external view returns (bool);

    function getImportedContractRate(address) external view returns (uint256);

    function setImportedContract(address, uint256) external;

    function checkTransferAllowed (address, address, uint256) external view returns (byte);
    function checkTransferFromAllowed (address, address, uint256) external view returns (byte);
    function checkMintAllowed (address, uint256) external pure returns (byte);
    function checkBurnAllowed (address, uint256) external pure returns (byte);
}


contract Token is IToken, ERC20, Ownable {


    string private _name;
    string private _symbol;
    uint8 private _decimals;

    IAdminTools private ATContract;
    address private ATAddress;

    byte private constant STATUS_ALLOWED = 0x11;
    byte private constant STATUS_DISALLOWED = 0x10;

    bool private _paused;

    struct contractsFeatures {
        bool permission;
        uint256 tokenRateExchange;
    }

    mapping(address => contractsFeatures) private contractsToImport;

    event Paused(address account);
    event Unpaused(address account);

    constructor(string memory name, string memory symbol, address _ATAddress) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        ATAddress = _ATAddress;
        ATContract = IAdminTools(ATAddress);
        _paused = false;
    }

    modifier onlyMinterAddress() {

        require(ATContract.getMinterAddress() == msg.sender, "Address can not mint!");
        _;
    }

    modifier whenNotPaused() {

        require(!_paused, "Token Contract paused...");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Token Contract not paused");
        _;
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function decimals() external view returns (uint8) {

        return _decimals;
    }

    function paused() external view returns (bool) {

        return _paused;
    }

    function pause() external onlyOwner whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    function isImportedContract(address _contract) external view returns (bool) {

        return contractsToImport[_contract].permission;
    }

    function getImportedContractRate(address _contract) external view returns (uint256) {

        return contractsToImport[_contract].tokenRateExchange;
    }

    function setImportedContract(address _contract, uint256 _exchRate) external onlyOwner {

        require(_contract != address(0), "Address not allowed!");
        require(_exchRate >= 0, "Rate exchange not allowed!");
        contractsToImport[_contract].permission = true;
        contractsToImport[_contract].tokenRateExchange = _exchRate;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(checkTransferAllowed(msg.sender, _to, _value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(checkTransferFromAllowed(_from, _to, _value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transferFrom(_from, _to,_value);
    }

    function mint(address _account, uint256 _amount) public whenNotPaused onlyMinterAddress {

        require(checkMintAllowed(_account, _amount) == STATUS_ALLOWED, "mint must be allowed");
        ERC20._mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public whenNotPaused onlyMinterAddress {

        require(checkBurnAllowed(_account, _amount) == STATUS_ALLOWED, "burn must be allowed");
        ERC20._burn(_account, _amount);
    }

    function okToTransferTokens(address _holder, uint256 _amountToAdd) public view returns (bool){

        uint256 holderBalanceToBe = balanceOf(_holder).add(_amountToAdd);
        bool okToTransfer = ATContract.isWhitelisted(_holder) && holderBalanceToBe <= ATContract.getMaxWLAmount(_holder) ? true :
                          holderBalanceToBe <= ATContract.getWLThresholdBalance() ? true : false;
        return okToTransfer;
    }

    function checkTransferAllowed (address _sender, address _receiver, uint256 _amount) public view returns (byte) {
        require(_sender != address(0), "Sender can not be 0!");
        require(_receiver != address(0), "Receiver can not be 0!");
        require(balanceOf(_sender) >= _amount, "Sender does not have enough tokens!");
        require(okToTransferTokens(_receiver, _amount), "Receiver not allowed to perform transfer!");
        return STATUS_ALLOWED;
    }

    function checkTransferFromAllowed (address _sender, address _receiver, uint256 _amount) public view returns (byte) {
        require(_sender != address(0), "Sender can not be 0!");
        require(_receiver != address(0), "Receiver can not be 0!");
        require(balanceOf(_sender) >= _amount, "Sender does not have enough tokens!");
        require(okToTransferTokens(_receiver, _amount), "Receiver not allowed to perform transfer!");
        return STATUS_ALLOWED;
    }

    function checkMintAllowed (address, uint256) public pure returns (byte) {
        return STATUS_ALLOWED;
    }

    function checkBurnAllowed (address, uint256) public pure returns (byte) {
        return STATUS_ALLOWED;
    }

}


interface IFundingPanel {

    function getFactoryDeployIndex() external view returns(uint);

    function isMemberInserted(address) external view returns(bool);

    function addMemberToSet(address, uint8, string calldata, bytes32) external returns (bool);

    function enableMember(address) external;

    function disableMemberByStaffRetire(address) external;

    function disableMemberByStaffForExit(address) external;

    function disableMemberByMember(address) external;

    function changeMemberData(address, string calldata, bytes32) external;

    function changeTokenExchangeRate(uint256) external;

    function changeTokenExchangeOnTopRate(uint256) external;

    function getOwnerData() external view returns (string memory, bytes32);

    function setOwnerData(string calldata, bytes32) external;

    function getMembersNumber() external view returns (uint);

    function getMemberAddressByIndex(uint8) external view returns (address);

    function getMemberDataByAddress(address _memberWallet) external view returns (bool, uint8, string memory, bytes32, uint256, uint, uint256);

    function setNewSeedMaxSupply(uint256) external returns (uint256);

    function holderSendSeeds(uint256) external;

    function unlockFunds(address, uint256) external;

    function burnTokensForMember(address, uint256) external;

    function importOtherTokens(address, uint256) external;

}


interface IERC20Seed {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract FundingPanel is Ownable, IFundingPanel {

    using SafeMath for uint256;

    string private setDocURL;
    bytes32 private setDocHash;

    address public seedAddress;
    IERC20Seed private seedToken;
    Token private token;
    address public tokenAddress;
    IAdminTools private ATContract;
    address public ATAddress;

    uint8 public exchRateDecimals;
    uint256 public exchangeRateOnTop;
    uint256 public exchangeRateSeed;

    uint public factoryDeployIndex;

    uint256 public seedMaxSupply;
    uint256 public totalSentSeed;

    struct infoMember {
        bool isInserted;
        uint8 disabled; //0=enabled, 1=exit, 2=SetOwnerDisabled, 3=memberDisabled
        string memberURL;
        bytes32 memberHash;
        uint256 burnedTokens;
        uint listPointer;
        uint256 memberUnlockedSeeds;
    }
    mapping(address => infoMember) public membersArray; // mapping of members
    address[] public membersList; //array for counting or accessing in a sequencialing way the members

    event MemberAdded();
    event MemberEnabled(uint pointer);
    event MemberDisabled(uint pointer);
    event MemberDisabledByMember(uint pointer);
    event MemberDataChanged(uint pointer);
    event TokenExchangeRateChanged();
    event TokenExchangeOnTopRateChanged();
    event TokenExchangeDecimalsChanged();
    event OwnerDataChanged();
    event NewSeedMaxSupplyChanged();
    event MintedToken(uint256 amount, uint256 amountOnTop);
    event FundsUnlocked();
    event TokensBurnedForMember(uint pointer);
    event MintedImportedToken(uint256 newTokenAmount);

    constructor (string memory _setDocURL, bytes32 _setDocHash, uint256 _exchRateSeed, uint256 _exchRateOnTop,
                address _seedTokenAddress, uint256 _seedMaxSupply, address _tokenAddress, address _ATAddress, uint _deployIndex) public {
        setDocURL = _setDocURL;
        setDocHash = _setDocHash;

        exchangeRateSeed = _exchRateSeed;
        exchangeRateOnTop = _exchRateOnTop;
        exchRateDecimals = 18;

        factoryDeployIndex = _deployIndex;

        seedMaxSupply = _seedMaxSupply;

        tokenAddress = _tokenAddress;
        ATAddress = _ATAddress;
        seedAddress = _seedTokenAddress;
        seedToken = IERC20Seed(seedAddress);
        token = Token(tokenAddress);
        ATContract = IAdminTools(ATAddress);
    }



    modifier onlyMemberEnabled() {

        require(membersArray[msg.sender].isInserted && membersArray[msg.sender].disabled==0, "Member not present or not enabled");
        _;
    }

    modifier whitelistedOnly(address holder) {

        require(ATContract.isWhitelisted(holder), "Investor is not whitelisted!");
        _;
    }

    modifier holderEnabledInSeeds(address _holder, uint256 _seedAmountToAdd) {

        uint256 amountInTokens = getTokenExchangeAmount(_seedAmountToAdd);
        uint256 holderBalanceToBe = token.balanceOf(_holder).add(amountInTokens);
        bool okToInvest = ATContract.isWhitelisted(_holder) && holderBalanceToBe <= ATContract.getMaxWLAmount(_holder) ? true :
                          holderBalanceToBe <= ATContract.getWLThresholdBalance() ? true : false;
        require(okToInvest, "Investor not allowed to perform operations!");
        _;
    }

    modifier onlyFundingOperators() {

        require(ATContract.isFundingOperator(msg.sender), "Not an authorized operator!");
        _;
    }

    modifier onlyFundsUnlockerOperators() {

        require(ATContract.isFundsUnlockerOperator(msg.sender), "Not an authorized operator!");
        _;
    }

    function getFactoryDeployIndex() public view returns(uint) {

        return factoryDeployIndex;
    }

    function isMemberInserted(address memberWallet) public view returns(bool) {

        return membersArray[memberWallet].isInserted;
    }

    function addMemberToSet(address memberWallet, uint8 disabled, string calldata memberURL,
                            bytes32 memberHash) external onlyFundingOperators returns (bool) {

        require(!isMemberInserted(memberWallet), "Member already inserted!");
        uint memberPlace = membersList.push(memberWallet) - 1;
        infoMember memory tmpStUp = infoMember(true, disabled, memberURL, memberHash, 0, memberPlace, 0);
        membersArray[memberWallet] = tmpStUp;
        emit MemberAdded();
        return true;
    }


    function getMembersNumber() external view returns (uint) {

        return membersList.length;
    }

    function enableMember(address _memberAddress) external onlyFundingOperators {

        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].disabled = 0;
        emit MemberEnabled(membersArray[_memberAddress].listPointer);
    }

    function disableMemberByStaffRetire(address _memberAddress) external onlyFundingOperators {

        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].disabled = 2;
        emit MemberDisabled(membersArray[_memberAddress].listPointer);
    }

    function disableMemberByStaffForExit(address _memberAddress) external onlyFundingOperators {

        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].disabled = 1;
        emit MemberDisabled(membersArray[_memberAddress].listPointer);
    }

    function disableMemberByMember(address _memberAddress) external onlyMemberEnabled {

        membersArray[_memberAddress].disabled = 3;
        emit MemberDisabledByMember(membersArray[_memberAddress].listPointer);
    }

    function changeMemberData(address _memberAddress, string calldata newURL, bytes32 newHash) external onlyFundingOperators {

        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].memberURL = newURL;
        membersArray[_memberAddress].memberHash = newHash;
        emit MemberDataChanged(membersArray[_memberAddress].listPointer);
    }

    function changeTokenExchangeRate(uint256 newExchRate) external onlyFundingOperators {

        require(newExchRate > 0, "Wrong exchange rate!");
        exchangeRateSeed = newExchRate;
        emit TokenExchangeRateChanged();
    }

    function changeTokenExchangeOnTopRate(uint256 newExchRate) external onlyFundingOperators {

        require(newExchRate > 0, "Wrong exchange rate on top!");
        exchangeRateOnTop = newExchRate;
        emit TokenExchangeOnTopRateChanged();
    }


    function getTokenExchangeAmount(uint256 _Amount) internal view returns(uint256) {

        require(_Amount > 0, "Amount must be greater than 0!");
        return _Amount.mul(exchangeRateSeed).div(10 ** uint256(exchRateDecimals));
    }

    function getTokenExchangeAmountOnTop(uint256 _Amount) internal view returns(uint256) {

        require(_Amount > 0, "Amount must be greater than 0!");
        return _Amount.mul(exchangeRateOnTop).div(10 ** uint256(exchRateDecimals));
    }

    function getTokenAddress() external view returns (address) {

        return tokenAddress;
    }

    function getOwnerData() external view returns (string memory, bytes32) {

        return (setDocURL, setDocHash);
    }

    function setOwnerData(string calldata _dataURL, bytes32 _dataHash) external onlyOwner {

        setDocURL = _dataURL;
        setDocHash = _dataHash;
        emit OwnerDataChanged();
    }

    function getMemberAddressByIndex(uint8 _index) external view returns (address) {

        return membersList[_index];
    }

    function getMemberDataByAddress(address _memberWallet) external view returns (bool, uint8, string memory, bytes32, uint256, uint, uint256) {

        require(membersArray[_memberWallet].isInserted, "Member not inserted");
        return(membersArray[_memberWallet].isInserted, membersArray[_memberWallet].disabled, membersArray[_memberWallet].memberURL,
                membersArray[_memberWallet].memberHash, membersArray[_memberWallet].burnedTokens,
                membersArray[_memberWallet].listPointer, membersArray[_memberWallet].memberUnlockedSeeds);
    }

    function setNewSeedMaxSupply(uint256 _newMaxSeedSupply) external onlyFundingOperators returns (uint256) {

        seedMaxSupply = _newMaxSeedSupply;
        emit NewSeedMaxSupplyChanged();
        return seedMaxSupply;
    }

    function holderSendSeeds(uint256 _seeds) external holderEnabledInSeeds(msg.sender, _seeds) {

        require(seedToken.balanceOf(address(this)).add(_seeds) <= seedMaxSupply, "Maximum supply reached!");
        require(seedToken.balanceOf(msg.sender) >= _seeds, "Not enough seeds in holder wallet");
        address walletOnTop = ATContract.getWalletOnTopAddress();
        require(ATContract.isWhitelisted(walletOnTop), "Owner wallet not whitelisted");
        seedToken.transferFrom(msg.sender, address(this), _seeds);
        totalSentSeed = totalSentSeed.add(_seeds);

        uint256 amount = getTokenExchangeAmount(_seeds);
        token.mint(msg.sender, amount);

        uint256 amountOnTop = getTokenExchangeAmountOnTop(_seeds);
        if (amountOnTop > 0)
            token.mint(walletOnTop, amountOnTop);
        emit MintedToken(amount, amountOnTop);
    }

    function unlockFunds(address memberWallet, uint256 amount) external onlyFundsUnlockerOperators {

         require(seedToken.balanceOf(address(this)) >= amount, "Not enough seeds to unlock!");
         require(membersArray[memberWallet].isInserted && membersArray[memberWallet].disabled==0, "Member not present or not enabled");
         seedToken.transfer(memberWallet, amount);
         membersArray[memberWallet].memberUnlockedSeeds = membersArray[memberWallet].memberUnlockedSeeds.add(amount);
         emit FundsUnlocked();
    }

    function burnTokensForMember(address memberWallet, uint256 amount) external {

         require(token.balanceOf(msg.sender) >= amount, "Not enough tokens to burn!");
         require(membersArray[memberWallet].isInserted && membersArray[memberWallet].disabled==0, "Member not present or not enabled");
         membersArray[memberWallet].burnedTokens = membersArray[memberWallet].burnedTokens.add(amount);
         token.burn(msg.sender, amount);
         emit TokensBurnedForMember(membersArray[memberWallet].listPointer);
    }

    function importOtherTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {

        require(token.isImportedContract(_tokenAddress), "Address not allowed!");
        require(token.getImportedContractRate(_tokenAddress) >= 0, "Rate exchange not allowed!");
        require(ATContract.isWhitelisted(msg.sender), "Wallet not whitelisted");
        uint256 newTokenAmount = _tokenAmount.mul(token.getImportedContractRate(_tokenAddress));
        uint256 holderBalanceToBe = token.balanceOf(msg.sender).add(newTokenAmount);
        bool okToInvest = ATContract.isWhitelisted(msg.sender) && holderBalanceToBe <= ATContract.getMaxWLAmount(msg.sender) ? true :
                          holderBalanceToBe <= ATContract.getWLThresholdBalance() ? true : false;
        require(okToInvest, "Wallet Threshold too low");
        token.mint(msg.sender, newTokenAmount);
        emit MintedImportedToken(newTokenAmount);
    }
}


interface IFPDeployer {

    function newFundingPanel(address, string calldata, bytes32, uint256, uint256,
                            address, uint256, address, address, uint) external returns(address);

    function setFactoryAddress(address) external;

    function getFactoryAddress() external view returns(address);

}


contract FPDeployer is Ownable, IFPDeployer {

    address private fAddress;

    event FundingPanelDeployed(uint deployedBlock);


    modifier onlyFactory() {

        require(msg.sender == fAddress, "Address not allowed to create FP!");
        _;
    }

    function setFactoryAddress(address _fAddress) external onlyOwner {

        require(block.number < 8850000, "Time expired!");
        require(_fAddress != address(0), "Address not allowed");
        fAddress = _fAddress;
    }

    function getFactoryAddress() external view returns(address) {

        return fAddress;
    }

    function newFundingPanel(address _caller, string calldata _setDocURL, bytes32 _setDocHash, uint256 _exchRateSeed, uint256 _exchRateOnTop,
                address _seedTokenAddress, uint256 _seedMaxSupply, address _tokenAddress, address _ATAddress, uint newLength) external onlyFactory returns(address) {

        require(_caller != address(0), "Sender Address is zero");
        FundingPanel c = new FundingPanel(_setDocURL, _setDocHash, _exchRateSeed, _exchRateOnTop,
                                              _seedTokenAddress, _seedMaxSupply, _tokenAddress, _ATAddress, newLength);
        c.transferOwnership(_caller);
        emit FundingPanelDeployed (block.number);
        return address(c);
    }

}