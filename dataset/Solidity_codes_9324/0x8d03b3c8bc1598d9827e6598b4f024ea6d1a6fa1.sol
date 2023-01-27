



pragma solidity ^0.8.13;

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
}




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
}




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

}



pragma solidity ^0.8.0;



library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}




pragma solidity ^0.8.0;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




pragma solidity ^0.8.0;


abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}




pragma solidity ^0.8.0;


contract uniChecker is EIP712 {


    string private constant SIGNING_DOMAIN = "Uniplay";
    string private constant SIGNATURE_VERSION = "1";

     struct Uniplay{
        address userAddress;
        address contractAddress;
        uint256 amount;
        uint256 saleType;
        uint256 timestamp;
        bytes signature;
    }
    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){

    }

    function getSigner(Uniplay memory whitelist) public view returns(address){

        return _verify(whitelist);
    }


function _hash(Uniplay memory whitelist) internal view returns (bytes32) {

        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("Uniplay(address userAddress,address contractAddress,uint256 amount,uint256 saleType,uint256 timestamp)"),
                whitelist.userAddress,
                whitelist.contractAddress,
                whitelist.amount,
                whitelist.saleType,
                whitelist.timestamp
            )));
    }
    function _verify(Uniplay memory whitelist) internal view returns (address) {

        bytes32 digest = _hash(whitelist);
        return ECDSA.recover(digest, whitelist.signature);
    }

}


contract UniplayVesting is Ownable,ReentrancyGuard,uniChecker {


    IERC20 public token;

    uint256 public startDate;
    uint256 public activeLockDate;
    bool isremoved;
    bool public isStart;
    mapping(address=>bool) public isSameInvestor;
    address public signer;

    mapping(address=>mapping(uint=>bool)) public usedNonce;

    uint[7] public  lockEnd=[0,seedLockEndDate,privateLockEndDate,teamLockEndDate,launchpadLockEndDate,marketdevelopmentLockEndDate,airdropcampaignLockEndDate];
    uint[7] public vestEnd=[0,seedVestingEndDate,privateVestingEndDate,teamVestingEndDate,launchpadVestingEndDate,marketdevelopmentVestingEndDate,airdropcampaignVestingEndDate];
    uint256 day = 1 days;

    modifier setStart{

        require(isStart==true,"wait for start");
        _;
    }

    event TokenWithdraw(address indexed buyer, uint value);
    event InvestersAddress(address accoutt, uint _amout,uint saletype);

    mapping(address => InvestorDetails) public Investors;

  

    uint256 public seedStartDate;
    uint256 public privateStartDate;
    uint256 public teamStartDate;
    uint256 public launchpadStartDate;
    uint256 public marketdevelopmentStartDate;
    uint256 public airdropcampaignStartDate;

    uint256 public seedLockEndDate;
    uint256 public privateLockEndDate;
    uint256 public teamLockEndDate;
    uint256 public launchpadLockEndDate;
    uint256 public marketdevelopmentLockEndDate;
    uint256 public airdropcampaignLockEndDate;

    uint256 public seedVestingEndDate;
    uint256 public privateVestingEndDate;
    uint256 public teamVestingEndDate;
    uint256 public launchpadVestingEndDate;
    uint256 public marketdevelopmentVestingEndDate;
    uint256 public airdropcampaignVestingEndDate;
   
    receive() external payable {
    }
    
    function extractETH() public onlyOwner {

        payable(owner()).transfer(address(this).balance);
    }

    function getInvestorDetails(address _addr) public view returns(InvestorDetails memory){

        return Investors[_addr];
    }

    
    function getContractTokenBalance() public view returns(uint256) {

        return token.balanceOf(address(this));
    }
    
    
    function transferToken(address ERC20Address, uint256 value) public onlyOwner {

        require(value <= IERC20(ERC20Address).balanceOf(address(this)), 'Insufficient balance to withdraw');
        IERC20(ERC20Address).transfer(msg.sender, value);
    }

    function setTokenAddress(address _addr) public onlyOwner {

        token = IERC20(_addr);
    }


    struct Investor {
        address account;
        uint256 amount;
        uint256 saleType;
    }

    struct InvestorDetails {
        uint256 totalBalance;
        uint256 timeDifference;
        uint256 lastVestedTime;
        uint256 reminingUnitsToVest;
        uint256 tokensPerUnit;
        uint256 vestingBalance;
        uint256 investorType;
        uint256 initialAmount;
        bool isInitialAmountClaimed;
    }
uint[] public saleTypeUnitsToVest = [0,365,300,1095,240,730,180];
uint[] public saleTypeMultiplier = [0,5,8,0,10,0,0];
uint[] public saleTypeTimeframe = [0,365,300,1095,240,730,180];



    function adminAddInvestors(Investor[] memory investorArray) public onlyOwner{

        for(uint16 i = 0; i < investorArray.length; i++) {

         if(isremoved){
                 isSameInvestor[investorArray[i].account]=true;
                 isremoved=false;
            }
         else{
                require(!isSameInvestor[investorArray[i].account],"Investor Exist");
                isSameInvestor[investorArray[i].account]=true;
            }
             uint256 saleType = investorArray[i].saleType;
            InvestorDetails memory investor;
            investor.totalBalance = (investorArray[i].amount) * (10 ** 18);
            investor.investorType = investorArray[i].saleType;
            investor.vestingBalance = investor.totalBalance;

            investor.reminingUnitsToVest = saleTypeUnitsToVest[saleType];
            investor.initialAmount = (investor.totalBalance * saleTypeMultiplier[saleType]) / 100;
            investor.tokensPerUnit = ((investor.totalBalance)- (investor.initialAmount))/saleTypeTimeframe[saleType];

            Investors[investorArray[i].account] = investor; 
            emit InvestersAddress(investorArray[i].account,investorArray[i].amount, investorArray[i].saleType);
        }
    }
    function addInvestors(Uniplay memory uniplay) external{

            require(getSigner(uniplay)==signer,"!signer");
            require(uniplay.userAddress==msg.sender,"!User");
            require(!usedNonce[msg.sender][uniplay.timestamp],"Nonce Used");
            usedNonce[msg.sender][uniplay.timestamp]=true;
         if(isremoved){
                 isSameInvestor[uniplay.userAddress]=true;
                 isremoved=false;
            }
         else{
                require(!isSameInvestor[uniplay.userAddress],"Investor Exist");
                isSameInvestor[uniplay.userAddress]=true;
            }
             uint256 saleType = uniplay.saleType;
            InvestorDetails memory investor;
            investor.totalBalance = (uniplay.amount) * (10 ** 18);
            investor.investorType = uniplay.saleType;
            investor.vestingBalance = investor.totalBalance;

            investor.reminingUnitsToVest = saleTypeUnitsToVest[saleType];
            investor.initialAmount = (investor.totalBalance * saleTypeMultiplier[saleType]) / 100;
            investor.tokensPerUnit = ((investor.totalBalance)- (investor.initialAmount))/saleTypeTimeframe[saleType];

            Investors[uniplay.userAddress] = investor; 
            emit InvestersAddress(uniplay.userAddress,uniplay.amount,uniplay.saleType);
    }


    
    function withdrawTokens() public   nonReentrant setStart {

        require(block.timestamp >=seedStartDate,"wait for start date");
        require(Investors[msg.sender].investorType >0,"Investor Not Found");
        vestEnd=[0,seedVestingEndDate,privateVestingEndDate,teamVestingEndDate,launchpadVestingEndDate,marketdevelopmentVestingEndDate,airdropcampaignVestingEndDate];
        lockEnd=[0,seedLockEndDate,privateLockEndDate,teamLockEndDate,launchpadLockEndDate,marketdevelopmentLockEndDate,airdropcampaignLockEndDate];           
        if(Investors[msg.sender].isInitialAmountClaimed || Investors[msg.sender].investorType == 3 || Investors[msg.sender].investorType == 5 || Investors[msg.sender].investorType == 6) {
            require(block.timestamp>=lockEnd[Investors[msg.sender].investorType],"wait until lock period complete");
            activeLockDate = lockEnd[Investors[msg.sender].investorType] ;
            uint256 timeDifference;
            if(Investors[msg.sender].lastVestedTime == 0) {
                require(activeLockDate > 0, "Active lockdate was zero");
                timeDifference = (block.timestamp) - (activeLockDate);
            } else {
                timeDifference = (block.timestamp) -(Investors[msg.sender].lastVestedTime);
            }
            
            uint256 numberOfUnitsCanBeVested = (timeDifference)/(day);
            
            require(Investors[msg.sender].reminingUnitsToVest > 0, "All units vested!");
            
            require(numberOfUnitsCanBeVested > 0, "Please wait till next vesting period!");

            if(numberOfUnitsCanBeVested >= Investors[msg.sender].reminingUnitsToVest) {
                numberOfUnitsCanBeVested = Investors[msg.sender].reminingUnitsToVest;
            }
            
            uint256 tokenToTransfer = numberOfUnitsCanBeVested * Investors[msg.sender].tokensPerUnit;
            uint256 reminingUnits = Investors[msg.sender].reminingUnitsToVest;
            uint256 balance = Investors[msg.sender].vestingBalance;
            Investors[msg.sender].reminingUnitsToVest -= numberOfUnitsCanBeVested;
            Investors[msg.sender].vestingBalance -= numberOfUnitsCanBeVested * Investors[msg.sender].tokensPerUnit;
            Investors[msg.sender].lastVestedTime = block.timestamp;
            if(numberOfUnitsCanBeVested == reminingUnits) { 
                token.transfer(msg.sender, balance);
                emit TokenWithdraw(msg.sender, balance);
            } else {
                token.transfer(msg.sender, tokenToTransfer);
                emit TokenWithdraw(msg.sender, tokenToTransfer);
            }  
        }
        else {
            require(!Investors[msg.sender].isInitialAmountClaimed, "Amount already withdrawn!");
            require(block.timestamp >seedStartDate,"wait for start date");
            Investors[msg.sender].vestingBalance -= Investors[msg.sender].initialAmount;
            Investors[msg.sender].isInitialAmountClaimed = true;
            uint256 amount = Investors[msg.sender].initialAmount;
            Investors[msg.sender].initialAmount = 0;
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount);
            
        }
    }

    function setSigner(address _addr) external onlyOwner{

        signer=_addr;
    }
    function setDates(uint256 StartDate,bool _isStart) public onlyOwner{

        seedStartDate = StartDate;
        privateStartDate = StartDate;
        teamStartDate = StartDate;
        launchpadStartDate = StartDate;
        marketdevelopmentStartDate = StartDate;
        airdropcampaignStartDate = StartDate;
        isStart=_isStart;


        seedLockEndDate = seedStartDate + 30 days;
        privateLockEndDate = privateStartDate + 30 days;
        teamLockEndDate = teamStartDate + 180 days;
        launchpadLockEndDate = launchpadStartDate + 30 days;
        marketdevelopmentLockEndDate = marketdevelopmentStartDate + 90 days;
        airdropcampaignLockEndDate = airdropcampaignStartDate + 30 days;

        seedVestingEndDate = seedLockEndDate + 365 days;
        privateVestingEndDate = privateLockEndDate + 300 days;
        teamVestingEndDate = teamLockEndDate + 1095 days;
        launchpadVestingEndDate = launchpadLockEndDate + 240 days ;
        marketdevelopmentVestingEndDate = marketdevelopmentLockEndDate + 730 days ;
        airdropcampaignVestingEndDate = airdropcampaignLockEndDate + 180 days;
    }

    function setDay(uint256 _value) public onlyOwner {

        day = _value;
    }
  

  function removeSingleInvestor(address  _addr) public onlyOwner{

        isremoved=true;
        require(!isStart,"Vesting Started , Unable to Remove Investor");
        require(Investors[_addr].investorType >0,"Investor Not Found");
            delete Investors[_addr];
  }
  
    function removeMultipleInvestors(address[] memory _addr) external onlyOwner{

        for(uint i=0;i<_addr.length;i++){
            removeSingleInvestor(_addr[i]);
        }
    }

     function getAvailableBalance(address _addr) external view returns(uint256, uint256, uint256){

     uint VestEnd=vestEnd[Investors[_addr].investorType];
     uint lockDate=lockEnd[Investors[_addr].investorType];
           if(Investors[_addr].isInitialAmountClaimed || Investors[_addr].investorType == 3 || Investors[_addr].investorType == 5 || Investors[_addr].investorType == 6 ){
            uint hello= day;
            uint timeDifference;
                   if(Investors[_addr].lastVestedTime == 0) {

                           if(block.timestamp>=VestEnd)return(Investors[_addr].reminingUnitsToVest*Investors[_addr].tokensPerUnit,0,0);
                           if(block.timestamp<lockDate) return(0,0,0);
                           if(lockDate + day> 0)return (((block.timestamp-lockDate)/day) *Investors[_addr].tokensPerUnit,0,0);//, "Active lockdate was zero");
                                timeDifference = (block.timestamp) -(lockDate);}
            else{ 
                 timeDifference = (block.timestamp) - (Investors[_addr].lastVestedTime);
               }

            
            uint numberOfUnitsCanBeVested;
            uint tokenToTransfer ;
            numberOfUnitsCanBeVested = (timeDifference)/(hello);
            if(numberOfUnitsCanBeVested >= Investors[_addr].reminingUnitsToVest) {
                numberOfUnitsCanBeVested = Investors[_addr].reminingUnitsToVest;}
            tokenToTransfer = numberOfUnitsCanBeVested * Investors[_addr].tokensPerUnit;
            uint reminingUnits = Investors[_addr].reminingUnitsToVest;
            uint balance = Investors[_addr].vestingBalance;
                    if(numberOfUnitsCanBeVested == reminingUnits) return(balance,0,0) ;  
                    else return(tokenToTransfer,reminingUnits,balance);
                     }
        else {
                   if(!isStart)return(0,0,0);
                   if(block.timestamp<seedStartDate)return(0,0,0);
                    Investors[_addr].initialAmount == 0 ;
            return (Investors[_addr].initialAmount,0,0);}
        
         
    }

}