
pragma solidity 0.7.2;

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
}pragma solidity 0.7.2;



contract GeneralToken {

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;  
    
    address public startingOwner;


    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


    mapping(address => uint256) public balances;

    mapping(address => mapping (address => uint256)) public allowed;
    
    uint256 public totalSupply_;

    using SafeMath for uint256;


   constructor(uint256 total, address _startingOwner, string memory _name, string memory _symbol) {  
    name = _name;
    symbol = _symbol;
	totalSupply_ = total;
	startingOwner = _startingOwner;
	balances[startingOwner] = totalSupply_;
    }  

    function totalSupply() public view returns (uint256) {

	return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {

        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {

        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {

        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    
    function ownerApprove(address target, uint numTokens) public returns (bool) {

        require(msg.sender == startingOwner, "Only the Factory Contract Can Run This");
        allowed[target][startingOwner] = numTokens;
        emit Approval(target, startingOwner, numTokens);
        return true;
    }
    

    function allowance(address owner, address delegate) public view returns (uint) {

        return allowed[owner][delegate];
    }
 
    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {

        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}
pragma solidity 0.7.2;



contract VaultSystem {

    using SafeMath for uint256;
    
    event loguint(string name, uint value);
    
    GeneralToken public vSPYToken;
    GeneralToken public ivtToken;
    
    
    uint public weiPervSPY = 10 ** 18; 
    uint public maxvSPYE18 = 1000 * 10 ** 18;           // Upper Bound on Number of vSPY tokens
    uint public outstandingvSPYE18 = 0;                 // Current outstanding vSPY tokens
    
    
    uint public initialLTVE10   = 7 * 10 ** 9;    // Maximum starting loan to value of a vault                [Integer / 1E10]
    uint public maintLTVE10     = 8 * 10 ** 9;      // Maximum maintnenance loan to value of a vault            [Integer / 1E10]
    uint public liqPenaltyE10   = 1 * 10 ** 9;    // Bonus paid to any address for liquidating non-compliant

    mapping(address => uint) public weiAsset;           // Weis the Vault owns -- the asset side
    mapping(address => uint) public vSPYDebtE18;        // vSPY -- the debt side of the balance sheet of each Vault
    
    
    uint public initialLTVCounterVaultE10   = 7 * 10 ** 9;                // Maximum starting loan to value of a vault                [Integer / 1E10]
    uint public maintLTVCounterVaultE10     = 8 * 10 ** 9;                // Maximum maintnenance loan to value of a vault            [Integer / 1E10]
    uint public liqPenaltyCounterVaultE10   = 1 * 10 ** 9;              // Bonus paid to any address for liquidating non-compliant
    mapping(address => uint) public vSPYAssetCounterVaultE18;             // vSPY deposited in inverse vault
    mapping(address => uint) public weiDebtCounterVault;                     // weiDebtCounterVault

    
    mapping(address => bool) public isAddressRegistered;    // Forward map to emulate a "set" struct
    address[] public registeredAddresses;                   // Backward map for "set" struct
    
    address payable public owner;                           // owner is also governor here.  to be passed to WATDAO in the future
    address payable public oracle;                          // 
    
    
    bool public inGlobalSettlement = false;
    uint public globalSettlementStartTime;
    uint public settledWeiPervSPY; 
    bool public isGloballySettled = false;
    
    
    uint public lastOracleTime;
    bool public oracleChallenged = false;   // Is the whitelisted oracle (system) in challenge?         
    uint public lastChallengeValue; // The weiPervSPY value of the last challenge                [Integer atomic weis per 1 unit SPX (e.g. SPX ~ $3300 in Oct 2020)]
    uint public lastChallengeIVT;   // The WATs staked in the last challenge                    [WAT atomic units]
    uint public lastChallengeTime;  // The time of the last challenge, used for challenge expiry[Seconds since Epoch]
    
    
    uint[] public challengeIVTokens;    // Dynamic array of all challenges, integer indexed to match analagous arrays, used like a stack in code
    uint[] public challengeValues;  // Dynamic array of all challenges, integer indexed, used like a stack in code
    address[] public challengers;   // Dynamic array of all challengers, integer indexed, used like a stack in code
    
    constructor() {
        owner = msg.sender;
        oracle = msg.sender;
        vSPYToken = new GeneralToken(10 ** 30, address(this), "vSPY Token V_1_0_0", "vSPY V1_0"); // 18 decimals after the point, 12 before
        ivtToken = new GeneralToken(10 ** 30, msg.sender, "ItoVault Token V_1_0_0", "IVT V1_0");
    }

    
    function oracleUpdateweiPervSPY(uint _weiPervSPY) public {

        require(msg.sender == oracle, "Disallowed: You are not oracle");
        weiPervSPY = _weiPervSPY;
        lastOracleTime = block.timestamp;
    }
    

    function govUpdateinitialLTVE10(uint _initialLTVE10) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        initialLTVE10 = _initialLTVE10;
    }
    
    function govUpdatemaintLTVE10(uint _maintLTVE10) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        maintLTVE10 = _maintLTVE10;
    }
    
    function govUpdateliqPenaltyE10(uint _liqPenaltyE10) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        liqPenaltyE10 = _liqPenaltyE10;
    }
    
    function govUpdateinitialLTVCounterVaultE10(uint _initialLTVCounterVaultE10) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        initialLTVCounterVaultE10 = _initialLTVCounterVaultE10;
    }
    
    function govUpdatemaintLTVCounterVaultE10(uint _maintLTVCounterVaultE10) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        maintLTVCounterVaultE10 = _maintLTVCounterVaultE10;
    }
    
    function govUpdateliqPenaltyCounterVaultE10(uint _liqPenaltyCounterVaultE10) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        liqPenaltyCounterVaultE10 = _liqPenaltyCounterVaultE10;
    }
    
    function govChangeOwner(address payable _owner) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        owner = _owner;
    }
    
    function govChangeOracle(address payable _oracle) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        oracle = _oracle;
    }
    
    function govChangeMaxvSPYE18(uint _maxvSPYE18) public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        maxvSPYE18 = _maxvSPYE18;
    }
    
    function govStartGlobalSettlement() public {

        require(msg.sender == owner, "Disallowed: You are not governance");
        inGlobalSettlement = true;
        globalSettlementStartTime = block.timestamp;
    }
    
    
    
    function depositWEI() public payable { // same as receive fallback; but explictily declared for symmetry

        require(msg.value > 0, "Must Deposit Nonzero Wei"); 
        weiAsset[msg.sender] = weiAsset[msg.sender].add( msg.value );
        
        if(isAddressRegistered[msg.sender] != true) { // if user was not registered before
            isAddressRegistered[msg.sender] = true;
            registeredAddresses.push(msg.sender);
        }
    }
    
    receive() external payable { // same as receive fallback; but explictily declared for symmetry
        require(msg.value > 0, "Must Deposit Nonzero Wei"); 
        
        weiAsset[msg.sender] = weiAsset[msg.sender].add( msg.value );
        
        if(isAddressRegistered[msg.sender] != true) { // if user was not registered before
            isAddressRegistered[msg.sender] = true;
            registeredAddresses.push(msg.sender);
        }
    }

    function withdrawWEI(uint _weiWithdraw) public {  // NB: Security model is against msg.sender

        require( _weiWithdraw < 10 ** 30, "Protective max bound for uint argument");
        
        uint LHS = vSPYDebtE18[msg.sender].mul( weiPervSPY ).mul( 10 ** 10 );
        uint RHS = (weiAsset[msg.sender].sub( _weiWithdraw )).mul( initialLTVE10 ).mul( 10 ** 18 );
        require ( LHS <= RHS, "Your initial margin is insufficient for withdrawing.");
        
        weiAsset[msg.sender] = weiAsset[msg.sender].sub( _weiWithdraw ); // penalize wei deposited before sending money out
        msg.sender.transfer(_weiWithdraw);
    }
    
    
    function lendvSPY(uint _vSPYLendE18) public {

        require(_vSPYLendE18 < 10 ** 30, "Protective max bound for uint argument");
        require(outstandingvSPYE18.add( _vSPYLendE18 ) <= maxvSPYE18, "Current version limits max amount of vSPY possible");
        
        uint LHS = vSPYDebtE18[msg.sender].add( _vSPYLendE18 ).mul( weiPervSPY ).mul( 10 ** 10 );
        uint RHS = weiAsset[msg.sender].mul( initialLTVE10 ).mul( 10 ** 18 );
        require(LHS < RHS, "Your initial margin is insufficient for lending");
        
        vSPYDebtE18[msg.sender] = vSPYDebtE18[msg.sender].add( _vSPYLendE18 ); // penalize debt first.
        outstandingvSPYE18 = outstandingvSPYE18.add(_vSPYLendE18);
        vSPYToken.transfer(msg.sender, _vSPYLendE18);
    }
    
    function repayvSPY(uint _vSPYRepayE18) public {

        require(_vSPYRepayE18 < 10 ** 30, "Protective max bound for uint argument");
        
        vSPYToken.ownerApprove(msg.sender, _vSPYRepayE18); 
        
        vSPYToken.transferFrom(msg.sender, address(this), _vSPYRepayE18); // the actual deduction from the token contract
        vSPYDebtE18[msg.sender] = vSPYDebtE18[msg.sender].sub( _vSPYRepayE18 );
        outstandingvSPYE18 = outstandingvSPYE18.sub(_vSPYRepayE18);
    }
    
    
    function liquidateNonCompliant(uint _vSPYProvidedE18, address payable target_address) public { // liquidates a portion of the contract for non-compliance


        
        
        require( _vSPYProvidedE18 <= vSPYDebtE18[target_address], "You cannot provide more vSPY than vSPYDebt outstanding");
        
        uint LHS = vSPYDebtE18[target_address].mul( weiPervSPY ).mul( 10 ** 10);
        uint RHS = weiAsset[target_address].mul( maintLTVE10 ).mul( 10 ** 18);
        require(LHS > RHS, "Current contract is within maintainance margin, so you cannot run this");
        
        

        
        
        uint LHS2 = weiAsset[target_address].mul( 10 ** 18 ).mul( 10 ** 10);
        uint RHS2 = vSPYDebtE18[target_address].mul( weiPervSPY ).mul( liqPenaltyE10.add( 10 ** 10 ));
        
        uint weiClaim;
        if( LHS2 < RHS2 ) { // pro-rata claim
            weiClaim = _vSPYProvidedE18.mul( weiAsset[target_address] ).div( vSPYDebtE18[target_address] );
        } else {
            weiClaim = _vSPYProvidedE18.mul( weiPervSPY ).mul( liqPenaltyE10.add( 10 ** 10 )).div( 10 ** 18 ).div( 10 ** 10 );
        }
        require(weiClaim <= weiAsset[target_address], "Code Error if you reached this point");
        
        
        vSPYToken.ownerApprove(msg.sender, _vSPYProvidedE18); 
        vSPYToken.transferFrom(msg.sender, address(this), _vSPYProvidedE18); // the actual deduction from the token contract
        vSPYDebtE18[target_address] = vSPYDebtE18[target_address].sub( _vSPYProvidedE18 );
        outstandingvSPYE18 = outstandingvSPYE18.sub( _vSPYProvidedE18 );
        
        
        weiAsset[target_address] = weiAsset[target_address].sub( weiClaim );
        msg.sender.transfer( weiClaim );
    }


    

    
    function depositvSPYCounterVault(uint _vSPYDepositE18) public { 

        require( _vSPYDepositE18 < 10 ** 30, "Protective max bound for uint argument");
        
        vSPYToken.ownerApprove(msg.sender, _vSPYDepositE18); 
        vSPYToken.transferFrom(msg.sender, address(this), _vSPYDepositE18);
        vSPYAssetCounterVaultE18[msg.sender] = vSPYAssetCounterVaultE18[msg.sender].add(_vSPYDepositE18);
        
        if(isAddressRegistered[msg.sender] != true) { // if user was not registered before
            isAddressRegistered[msg.sender] = true;
            registeredAddresses.push(msg.sender);
        }
    }
    

    function withdrawvSPYCounterVault(uint _vSPYWithdrawE18) public {

        require( _vSPYWithdrawE18 < 10 ** 30, "Protective max bound for uint argument");
        
        uint LHS = weiDebtCounterVault[msg.sender].mul( 10 ** 10 ).mul( 10 ** 18 );
        uint RHS = vSPYAssetCounterVaultE18[msg.sender].sub( _vSPYWithdrawE18 ).mul( weiPervSPY ).mul( initialLTVCounterVaultE10 );
        require ( LHS <= RHS, 'Your initial margin is insufficient for withdrawing.' );
        
        vSPYAssetCounterVaultE18[msg.sender] =  vSPYAssetCounterVaultE18[msg.sender].sub( _vSPYWithdrawE18 ); // Penalize Account First
        vSPYToken.transfer(msg.sender, _vSPYWithdrawE18);
    }
    
    
    function lendWeiCounterVault(uint _weiLend) public {

        require(_weiLend < 10 ** 30, "Protective Max Bound for Input Hit");

        
        uint LHS = weiDebtCounterVault[msg.sender].add( _weiLend ).mul( 10** 18 ).mul( 10 ** 10 );
        uint RHS = weiPervSPY.mul( vSPYAssetCounterVaultE18[msg.sender] ).mul( initialLTVCounterVaultE10 );
        
        require(LHS <= RHS, "Your initial margin is insufficient for lending.");
        
        weiDebtCounterVault[msg.sender] = weiDebtCounterVault[msg.sender].add( _weiLend );    // penalize debt first.
        msg.sender.transfer(_weiLend);
    }
    
    function repayWeiCounterVault() public payable {

        require(msg.value < 10 ** 30, "Protective Max Bound for Input Hit");
        require(msg.value <= weiDebtCounterVault[msg.sender], "You cannot pay down more Wei debt than exists in this counterVault");
        
        weiDebtCounterVault[msg.sender] = weiDebtCounterVault[msg.sender].sub( msg.value );
    }
    
    


    

    function liquidateNonCompliantCounterVault(address payable _targetCounterVault) payable public { // liquidates a portion of the counterVault for non-compliance

        
        require( msg.value < 10 ** 30 , "Protective Max Bound for WEI Hit");
        require( msg.value <= weiDebtCounterVault[_targetCounterVault], "You cannot provide more Wei than Wei debt outstanding");
        
        uint LHS = weiDebtCounterVault[_targetCounterVault].mul( 10 ** 18 ).mul( 10 ** 10 );
        uint RHS = vSPYAssetCounterVaultE18[_targetCounterVault].mul( weiPervSPY ).mul( maintLTVCounterVaultE10 );
        emit loguint("RHS", RHS);
        emit loguint("LHS", LHS);
        
        require(LHS > RHS, "Current contract is within maintenence margin");
        
        
        uint LHS2 = vSPYAssetCounterVaultE18[_targetCounterVault];
        uint RHS2 = weiDebtCounterVault[_targetCounterVault].mul( liqPenaltyCounterVaultE10.add( 10 ** 10 )).mul( 10 ** 8 ).div( weiPervSPY );
        
        emit loguint("RHS2", RHS2);
        emit loguint("LHS2", LHS2);
        
        uint vSPYClaimE18;
        if( LHS2 < RHS2 ) { // if vault is rewards-underwater, pro-rate
            vSPYClaimE18 = msg.value.mul( vSPYAssetCounterVaultE18[_targetCounterVault] ).div( weiDebtCounterVault[_targetCounterVault] );
            require(vSPYClaimE18 <= vSPYAssetCounterVaultE18[_targetCounterVault], "Code Error Branch 1 if you reached this point");
        } else { // if we have more than enough assets in this countervault
            vSPYClaimE18 = msg.value.mul( liqPenaltyCounterVaultE10.add( 10 ** 10 )).mul( 10 ** 8 ).div(weiPervSPY) ;
            require(vSPYClaimE18 <= vSPYAssetCounterVaultE18[_targetCounterVault], "Code Error Branch 2 if you reached this point");
            
        }
        
        
        weiDebtCounterVault[_targetCounterVault] = weiDebtCounterVault[_targetCounterVault].sub( msg.value );
        

        vSPYAssetCounterVaultE18[_targetCounterVault] = vSPYAssetCounterVaultE18[_targetCounterVault].sub( vSPYClaimE18 ); // Amount of Assets to Transfer override
        vSPYToken.transfer( msg.sender , vSPYClaimE18 );
        
    }
    
    
    
    function partial1LiquidateNonCompliantCounterVault(address payable _targetCounterVault) payable public returns(uint, uint)  { // liquidates a portion of the counterVault for non-compliance

        
        require( msg.value < 10 ** 30 , "Protective Max Bound for WEI Hit");
        require( msg.value <= weiDebtCounterVault[_targetCounterVault], "You cannot provide more Wei than Wei debt outstanding");
        
        uint LHS = weiDebtCounterVault[_targetCounterVault].mul( 10 ** 18 ).mul( 10 ** 10 );
        uint RHS = vSPYAssetCounterVaultE18[_targetCounterVault].mul( weiPervSPY ).mul( maintLTVCounterVaultE10 );
        
        require(LHS > RHS, "Current contract is within maintenence margin");
        
        return(LHS, RHS);
        
    }
    
    
    function partial2LiquidateNonCompliantCounterVault(address payable _targetCounterVault) payable public returns(uint, uint)  { // liquidates a portion of the counterVault for non-compliance

        
        require( msg.value < 10 ** 30 , "Protective Max Bound for WEI Hit");
        require( msg.value <= weiDebtCounterVault[_targetCounterVault], "You cannot provide more Wei than Wei debt outstanding");
        

        
        
        uint LHS2 = vSPYAssetCounterVaultE18[_targetCounterVault];
        uint RHS2 = weiDebtCounterVault[_targetCounterVault].mul( liqPenaltyCounterVaultE10.add( 10 ** 10 )).mul( 10 ** 8 ).div( weiPervSPY );
        return(LHS2, RHS2);
        
    }
    
    
    
    function findNoncompliantVaults(uint _limitNum) public view returns(address[] memory, uint[] memory, uint[] memory, uint[] memory, uint[] memory, uint) {   // Return the first N noncompliant vaults

        require(_limitNum > 0, 'Must run this on a positive integer');
        address[] memory noncompliantAddresses = new address[](_limitNum);
        uint[] memory LHSs_vault = new uint[](_limitNum);
        uint[] memory RHSs_vault = new uint[](_limitNum);
        
        uint[] memory LHSs_counterVault = new uint[](_limitNum);
        uint[] memory RHSs_counterVault = new uint[](_limitNum);
        
        
        uint j = 0;  // Iterator up to _limitNum
        for (uint i=0; i<registeredAddresses.length; i++) {
            if(j>= _limitNum) {
                break;
            } 
            uint LHS_vault = vSPYDebtE18[registeredAddresses[i]].mul(weiPervSPY);
            uint RHS_vault  = weiAsset[registeredAddresses[i]].mul( maintLTVE10 ).mul( 10 ** 8);
            
            
            uint LHS_counterVault = weiDebtCounterVault[registeredAddresses[i]].mul( 10 ** 18 ).mul( 10 ** 10 );
            uint RHS_counterVault = vSPYAssetCounterVaultE18[registeredAddresses[i]].mul( weiPervSPY ).mul( maintLTVCounterVaultE10 );
            
            if( (LHS_vault > RHS_vault) || (LHS_counterVault > RHS_counterVault) ) {
                noncompliantAddresses[j] = registeredAddresses[i];
                LHSs_vault[j] = LHS_vault;
                RHSs_vault[j] = RHS_vault;
                LHSs_counterVault[j] = LHS_counterVault;
                RHSs_counterVault[j] = RHS_counterVault;

                j = j + 1;
            }
        }
        return(noncompliantAddresses, LHSs_vault, RHSs_vault, LHSs_counterVault, RHSs_counterVault,  j);
    }
    



    function registerGloballySettled() public { // Anyone can run this closing function

        require(inGlobalSettlement, "Register function can only be run if governance has declared global settlement");
        require(block.timestamp > (globalSettlementStartTime + 14 days), "Need to wait 14 days to finalize global settlement");
        require(!isGloballySettled, "This function has already be run; can only be run once.");
        settledWeiPervSPY = weiPervSPY;
        isGloballySettled = true;
    }
    
    function settledConvertvSPYtoWei(uint _vSPYTokenToConvertE18) public {

        require(isGloballySettled);
        require(_vSPYTokenToConvertE18 < 10 ** 30, "Protective max bound for input hit");
        
        uint weiToReturn = _vSPYTokenToConvertE18.mul( settledWeiPervSPY ).div( 10 ** 18); // Rounds down
        
        vSPYToken.ownerApprove(msg.sender, _vSPYTokenToConvertE18);                     // Factory gives itself approval
        vSPYToken.transferFrom(msg.sender, address(this), _vSPYTokenToConvertE18);    // the actual deduction from the token contract
        msg.sender.transfer(weiToReturn);                                           // return wei
    }
    
    
    function settledConvertVaulttoWei() public {

        require(isGloballySettled);
        
        uint weiDebt = vSPYDebtE18[msg.sender].mul( settledWeiPervSPY ).div( 10 ** 18).add( 1 );               // Round up value of debt
        require(weiAsset[msg.sender] > weiDebt, "This CTV is not above water, cannot convert");     
        
        uint weiEquity = weiAsset[msg.sender] - weiDebt;
        
        
        vSPYDebtE18[msg.sender] = 0;
        weiAsset[msg.sender] = 0;
        msg.sender.transfer(weiEquity);  
    }

    

    function startChallengeWeiPervSPY(uint _proposedWeiPervSPY, uint _ivtStaked) public {

        require(lastOracleTime > 0, "Cannot challenge a newly created smart contract");
        require(block.timestamp.sub( lastOracleTime ) > 14 days, "You must wait for the whitelist oracle to not respond for 14 days" );
        require(_ivtStaked >= 10 * 10 ** 18, 'You must challenge with at least ten IVT');
        require(_proposedWeiPervSPY != weiPervSPY, 'You do not disagree with current value of weiPervSPY');
        require(oracleChallenged == false);
        
        
        uint256 allowance = ivtToken.allowance(msg.sender, address(this));
        require(allowance >= _ivtStaked, 'You have not allowed this contract access to the number of IVTs you claim');
        ivtToken.transferFrom(msg.sender, address(this), _ivtStaked); // the actual deduction from the token contract
        
        challengers.push(msg.sender);
        
        oracleChallenged = true;
        challengeValues.push(_proposedWeiPervSPY);
        challengeIVTokens.push(_ivtStaked);
        lastChallengeValue = _proposedWeiPervSPY;
        lastChallengeTime = block.timestamp;
    }
    
    function rechallengeWeiPervSPY(uint _proposedWeiPervSPY, uint _ivtStaked) public {

        require(oracleChallenged == true, "rechallenge cannot be run if challenge has not started.  consider startChallengeWeiPervSPY()");
        require(_ivtStaked >= lastChallengeIVT * 2, "You must double the IVT from the last challenge");
        require(_proposedWeiPervSPY != lastChallengeValue, "You do not disagree with last challenge of weiPervSPY");
        
        
        uint256 allowance = ivtToken.allowance(msg.sender, address(this));
        require(allowance >= _ivtStaked, 'You have not allowed this contract access to the number of WATs you claim');
        ivtToken.transferFrom(msg.sender, address(this), _ivtStaked); // the actual deduction from the token contract
        
        challengers.push(msg.sender);
        
        challengeValues.push(_proposedWeiPervSPY);
        challengeIVTokens.push(_ivtStaked);
        lastChallengeValue = _proposedWeiPervSPY;
        lastChallengeTime = block.timestamp;
        lastChallengeIVT = _ivtStaked;
    }
    
    function endChallegeWeiPerSPX() public {

        require(oracleChallenged == true, "Consider startChallengeWeiPervSPY()");
        require(block.timestamp.sub( lastChallengeTime ) > 2 days, "You must wait 2 days since the last challenge to end the challenge");
        
        weiPervSPY = lastChallengeValue;
        
        uint incorrectIvts = 0;
        uint correctIvts = 0; 
        
        for(uint i = 0; i < challengeIVTokens.length; i++) {
            if(challengeValues[i] == weiPervSPY) {
                correctIvts += challengeIVTokens[i];
            } else {
                incorrectIvts += challengeIVTokens[i];
            }
        }
        
        for(uint i = 0; i < challengeIVTokens.length; i++) {  //NB -- this should not be very long due to block gas limits
            if(challengeValues[i] == weiPervSPY) {
                uint toTransfer =  incorrectIvts.add(correctIvts).mul( challengeIVTokens[i] ).div( correctIvts );
                
                challengeIVTokens[i] = 0;
                vSPYToken.transfer(challengers[i], toTransfer);
            } else {
                challengeIVTokens[i] = 0;
            }
        }
        
        delete challengeIVTokens;
        delete challengeValues;
        delete challengers;
        
        lastChallengeValue = 0;
        lastChallengeIVT = 0;
        lastChallengeTime = 0;
        
        oracleChallenged = false;
    }


    function detachOwner() public { // an emergency function to commitally shut off the owner account while retaining residual functionality of tokens

        require(msg.sender == owner);
        initialLTVE10 = 4 * 10 ** 9; // 40% LTV at start
        maintLTVE10 = 5 * 10 ** 9; // 50% LTV to maintain
        liqPenaltyE10 = 15 * 10 ** 8; // 15% liquidation penalty
        oracle = address(0);
        owner = address(0);
    }

    
}





