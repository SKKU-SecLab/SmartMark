
pragma solidity 0.7.5;

interface IERC20 { // brief interface for erc20 token tx

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}

library Address { // helper for address type - see openzeppelin-contracts/blob/master/contracts/utils/Address.sol

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

library SafeERC20 { // wrapper around erc20 token tx for non-standard contract - see openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol

    using Address for address;
    
    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returnData) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returnData.length > 0) { // return data is optional
            require(abi.decode(returnData, (bool)), "SafeERC20: erc20 operation did not succeed");
        }
    }
}

library SafeMath { // arithmetic wrapper for unit under/overflow check

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;
        return c;
    }
}

contract Context { // describe current contract execution context (metaTX support) - see openzeppelin-contracts/blob/master/contracts/GSN/Context.sol

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ReentrancyGuard { // call wrapper for reentrancy check - see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol

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

contract LexLocker is Context, ReentrancyGuard { 

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public manager; // account managing LXL settings - see 'Manager Functions' - updateable by manager
    address public swiftResolverToken; // token required to participate as swift resolver - updateable by manager
    address public wETH; // ether token wrapper contract reference - updateable by manager
    uint256 private lockerCount; // lockers counted into LXL registry
    uint256 public MAX_DURATION; // time limit in seconds on token lockup - default 63113904 (2-year) - updateable by manager
    uint256 public resolutionRate; // rate to determine resolution fee for disputed locker (e.g., 20 = 5% of remainder) - updateable by manager
    uint256 public swiftResolverTokenBalance; // balance required in `swiftResolverToken` to participate as swift resolver - updateable by manager
    string public lockerTerms; // general terms wrapping LXL - updateable by manager
    string[] public marketTerms; // market LXL terms stamped by manager
    string[] public resolutions; // locker resolutions stamped by LXL resolvers
    
    mapping(address => uint256[]) private clientRegistrations; // tracks registered lockers per client account
    mapping(address => uint256[]) private providerRegistrations; // tracks registered lockers per provider account
    mapping(address => bool) public swiftResolverRegistrations; // tracks registered swift resolvers
    mapping(uint256 => ADR) public adrs; // tracks ADR details for registered lockers
    mapping(uint256 => Locker) public lockers; // tracks registered lockers details
    
    event DepositLocker(address indexed client, address clientOracle, address indexed provider, address indexed resolver, address token, uint256[] amount, uint256 registration, uint256 sum, uint256 termination, string details, bool swiftResolver);
    event RegisterLocker(address indexed client, address clientOracle, address indexed provider, address indexed resolver, address token, uint256[] amount, uint256 registration, uint256 sum, uint256 termination, string details, bool swiftResolver);
    event ConfirmLocker(address token, uint256 registration, uint256 sum); 
    event RequestLockerResolution(address indexed client, address indexed counterparty, address indexed resolver, address token, uint256 deposit, uint256 registration, string details, bool swiftResolver); 
    event Release(uint256 milestone, uint256 payment, uint256 registration); 
    event Withdraw(address indexed client, uint256 registration);
    event AssignClientOracle(address indexed clientOracle, uint256 registration);
    event ClientProposeResolver(address indexed proposedResolver, uint256 registration, string details);
    event ProviderProposeResolver(address indexed proposedResolver, uint256 registration, string details);
    event UpdateSwiftResolverStatus(address indexed swiftResolver, string details, bool registered);
    event Lock(address indexed caller, uint256 registration, string details);
    event Resolve(address indexed resolver, uint256 clientAward, uint256 providerAward, uint256 registration, uint256 resolutionFee, string resolution); 
    event AddMarketTerms(uint256 index, string terms);
    event AmendMarketTerms(uint256 index, string terms);
    event UpdateLockerSettings(address indexed manager, address swiftResolverToken, address wETH, uint256 MAX_DURATION, uint256 resolutionRate, uint256 swiftResolverTokenBalance, string lockerTerms);
    event TributeToManager(uint256 amount, string details);

    struct ADR {  
        address proposedResolver;
        address resolver;
        uint8 clientProposedResolver;
        uint8 providerProposedResolver;
	    uint256 resolutionRate;
	    string resolution;
	    bool swiftResolver;
    }
    
    struct Locker {  
        address client; 
        address clientOracle;
        address provider;
        address token;
        uint8 confirmed;
        uint8 locked;
        uint256[] amount;
        uint256 currentMilestone;
        uint256 milestones;
        uint256 released;
        uint256 sum;
        uint256 termination;
        string details; 
    }
    
    constructor(
        address _manager, 
        address _swiftResolverToken, 
        address _wETH,
        uint256 _MAX_DURATION,
        uint256 _resolutionRate, 
        uint256 _swiftResolverTokenBalance, 
        string memory _lockerTerms
    ) {
        manager = _manager;
        swiftResolverToken = _swiftResolverToken;
        wETH = _wETH;
        MAX_DURATION = _MAX_DURATION;
        resolutionRate = _resolutionRate;
        swiftResolverTokenBalance = _swiftResolverTokenBalance;
        lockerTerms = _lockerTerms;
    }

    function depositLocker( // CLIENT-TRACK
        address clientOracle, 
        address provider,
        address resolver,
        address token,
        uint256[] memory amount, 
        uint256 termination, 
        string memory details,
        bool swiftResolver 
    ) external nonReentrant payable returns (uint256) {

        require(_msgSender() != resolver && clientOracle != resolver && provider != resolver, "client/clientOracle/provider = resolver");
        require(termination <= block.timestamp.add(MAX_DURATION), "duration maxed");
        
        uint256 sum;
        for (uint256 i = 0; i < amount.length; i++) {
            sum = sum.add(amount[i]);
        }

        if (msg.value > 0) {
            address weth = wETH;
            require(token == weth && msg.value == sum, "!ethBalance");
            (bool success, ) = weth.call{value: msg.value}("");
            require(success, "!ethCall");
            IERC20(weth).safeTransfer(address(this), msg.value);
        } else {
            IERC20(token).safeTransferFrom(_msgSender(), address(this), sum);
        }
        
        lockerCount++;
        uint256 registration = lockerCount;
        
        clientRegistrations[_msgSender()].push(registration);
        providerRegistrations[provider].push(registration);
        
        adrs[registration] = ADR( 
            address(0),
            resolver,
            0,
            0,
	        resolutionRate, 
	        "",
	        swiftResolver);

        lockers[registration] = Locker( 
            _msgSender(), 
            clientOracle,
            provider,
            token,
            1,
            0,
            amount,
            1,
            amount.length,
            0,
            sum,
            termination,
            details);

        emit DepositLocker(_msgSender(), clientOracle, provider, resolver, token, amount, registration, sum, termination, details, swiftResolver); 
        
	    return registration;
    }
    
    function registerLocker( // PROVIDER-TRACK
        address client,
        address clientOracle, 
        address provider,
        address resolver,
        address token,
        uint256[] memory amount, 
        uint256 termination, 
        string memory details,
        bool swiftResolver 
    ) external nonReentrant returns (uint256) {

        require(client != resolver && clientOracle != resolver && provider != resolver, "client/clientOracle/provider = resolver");
        require(termination <= block.timestamp.add(MAX_DURATION), "duration maxed");
        
        uint256 sum;
        for (uint256 i = 0; i < amount.length; i++) {
            sum = sum.add(amount[i]);
        }
 
        lockerCount++;
        uint256 registration = lockerCount;
        
        clientRegistrations[client].push(registration);
        providerRegistrations[provider].push(registration);
       
        adrs[registration] = ADR( 
            address(0),
            resolver,
            0,
            0,
	        resolutionRate, 
	        "",
	        swiftResolver);

        lockers[registration] = Locker( 
            client, 
            clientOracle,
            provider,
            token,
            0,
            0,
            amount,
            1,
            amount.length,
            0,
            sum,
            termination,
            details);

        emit RegisterLocker(client, clientOracle, provider, resolver, token, amount, registration, sum, termination, details, swiftResolver); 
        
	    return registration;
    }
    
    function confirmLocker(uint256 registration) external nonReentrant payable { // PROVIDER-TRACK

        Locker storage locker = lockers[registration];
        
        require(_msgSender() == locker.client, "!client");
        require(locker.confirmed == 0, "confirmed");
        
        address token = locker.token;
        uint256 sum = locker.sum;
        
        if (msg.value > 0) {
            address weth = wETH;
            require(token == weth && msg.value == sum, "!ethBalance");
            (bool success, ) = weth.call{value: msg.value}("");
            require(success, "!ethCall");
            IERC20(weth).safeTransfer(address(this), msg.value);
        } else {
            IERC20(token).safeTransferFrom(_msgSender(), address(this), sum);
        }
        
        locker.confirmed = 1;
        
        emit ConfirmLocker(token, registration, sum); 
    }
    
    function requestLockerResolution(address counterparty, address resolver, address token, uint256 deposit, string memory details, bool swiftResolver) external nonReentrant payable returns (uint256) {

        require(_msgSender() != resolver && counterparty != resolver, "client/counterparty = resolver");
        
        if (msg.value > 0) {
            address weth = wETH;
            require(token == weth && msg.value == deposit, "!ethBalance");
            (bool success, ) = weth.call{value: msg.value}("");
            require(success, "!ethCall");
            IERC20(weth).safeTransfer(address(this), msg.value);
        } else {
            IERC20(token).safeTransferFrom(_msgSender(), address(this), deposit);
        }
        
        uint256[] memory amount = new uint256[](1);
        amount[0] = deposit;
        
        lockerCount++;
        uint256 registration = lockerCount;
        
        clientRegistrations[_msgSender()].push(registration);
        providerRegistrations[counterparty].push(registration);
        
        adrs[registration] = ADR( 
            address(0),
            resolver,
            0,
            0,
	        resolutionRate, 
	        "",
	        swiftResolver);
     
        lockers[registration] = Locker( 
            _msgSender(), 
            address(0),
            counterparty,
            token,
            1,
            1,
            amount,
            0,
            0,
            0,
            deposit,
            0,
            details);

        emit RequestLockerResolution(_msgSender(), counterparty, resolver, token, deposit, registration, details, swiftResolver); 
        
	    return registration;
    }
    
    function assignClientOracle(address clientOracle, uint256 registration) external nonReentrant {

        ADR storage adr = adrs[registration];
        Locker storage locker = lockers[registration];
        
        require(_msgSender() == locker.client, "!client");
        require(clientOracle != adr.resolver, "clientOracle = resolver");
        require(locker.locked == 0, "locked");
	    require(locker.released < locker.sum, "released");
        
        locker.clientOracle = clientOracle;
        
        emit AssignClientOracle(clientOracle, registration);
    }
    
    function release(uint256 registration) external nonReentrant {

    	Locker storage locker = lockers[registration];
    	
    	uint256 milestone = locker.currentMilestone-1;
        uint256 payment = locker.amount[milestone];
        uint256 released = locker.released;
        uint256 sum = locker.sum;
	    
	    require(_msgSender() == locker.client || _msgSender() == locker.clientOracle, "!client/oracle");
	    require(locker.confirmed == 1, "!confirmed");
	    require(locker.locked == 0, "locked");
	    require(released < sum, "released");

        IERC20(locker.token).safeTransfer(locker.provider, payment);
        locker.released = released.add(payment);
        
        if (locker.released < sum) {locker.currentMilestone++;}
        
	    emit Release(milestone+1, payment, registration); 
    }
    
    function withdraw(uint256 registration) external nonReentrant {

    	Locker storage locker = lockers[registration];
    	
    	address client = locker.client;
    	uint256 released = locker.released;
    	uint256 sum = locker.sum;
        
        require(_msgSender() == client || _msgSender() == locker.clientOracle, "!client/oracle");
        require(locker.confirmed == 1, "!confirmed");
        require(locker.locked == 0, "locked");
        require(released < sum, "released");
        require(locker.termination < block.timestamp, "!terminated");
        
        IERC20(locker.token).safeTransfer(client, sum.sub(released));
        locker.released = sum; 
        
	    emit Withdraw(client, registration); 
    }
    
    function lock(uint256 registration, string calldata details) external nonReentrant {

        Locker storage locker = lockers[registration]; 
        
        require(_msgSender() == locker.client || _msgSender() == locker.provider, "!party"); 
        require(locker.confirmed == 1, "!confirmed");
        require(locker.released < locker.sum, "released");

	    locker.locked = 1; 
	    
	    emit Lock(_msgSender(), registration, details);
    }
    
    function resolve(uint256 clientAward, uint256 providerAward, uint256 registration, string calldata resolution) external nonReentrant {

        ADR storage adr = adrs[registration];
        Locker storage locker = lockers[registration];
        
        address token = locker.token;
        uint256 released = locker.released;
	    uint256 sum = locker.sum;
	    uint256 remainder = sum.sub(released); 
	    uint256 resolutionFee = remainder.div(adr.resolutionRate); 
	    
	    require(locker.locked == 1, "!locked"); 
	    require(released < sum, "released");
	    require(clientAward.add(providerAward) == remainder.sub(resolutionFee), "awards != remainder - fee");
	    
	    if (adr.swiftResolver) {
	        require(_msgSender() != locker.client && _msgSender() != locker.provider, "swiftResolver = client/provider");
	        require(IERC20(swiftResolverToken).balanceOf(_msgSender()) >= swiftResolverTokenBalance && swiftResolverRegistrations[_msgSender()], "!swiftResolverTokenBalance/registered");
        } else {
            require(_msgSender() == adr.resolver, "!resolver");
        }
        
        IERC20(token).safeTransfer(_msgSender(), resolutionFee);
        IERC20(token).safeTransfer(locker.client, clientAward);
        IERC20(token).safeTransfer(locker.provider, providerAward);
        
	    adr.resolution = resolution;
	    locker.released = sum; 
	    resolutions.push(resolution);
	    
	    emit Resolve(_msgSender(), clientAward, providerAward, registration, resolutionFee, resolution);
    }
    
    function clientProposeResolver(address proposedResolver, uint256 registration, string calldata details) external nonReentrant { 

        ADR storage adr = adrs[registration];
        Locker storage locker = lockers[registration]; 
        
        require(_msgSender() == locker.client, "!client"); 
        require(_msgSender() != proposedResolver && locker.clientOracle != proposedResolver && locker.provider != proposedResolver, "client/clientOracle/provider = proposedResolver");
        require(adr.clientProposedResolver == 0, "pending");
	    require(locker.released < locker.sum, "released");
        
        if (adr.proposedResolver == proposedResolver) {
            adr.resolver = proposedResolver;
        } 

	    adr.proposedResolver = proposedResolver; 
	    adr.clientProposedResolver = 1;
	    adr.providerProposedResolver = 0;
	    
	    emit ClientProposeResolver(proposedResolver, registration, details);
    }
    
    function providerProposeResolver(address proposedResolver, uint256 registration, string calldata details) external nonReentrant { 

        ADR storage adr = adrs[registration];
        Locker storage locker = lockers[registration]; 
        
        require(_msgSender() == locker.provider, "!provider"); 
        require(locker.client != proposedResolver && locker.clientOracle != proposedResolver && _msgSender() != proposedResolver, "client/clientOracle/provider = proposedResolver");
        require(adr.providerProposedResolver == 0, "pending");
	    require(locker.released < locker.sum, "released");

	    if (adr.proposedResolver == proposedResolver) {
            adr.resolver = proposedResolver;
        } 
	    
	    adr.proposedResolver = proposedResolver;
	    adr.clientProposedResolver = 0;
	    adr.providerProposedResolver = 1;
	    
	    emit ProviderProposeResolver(proposedResolver, registration, details);
    }
    
    function updateSwiftResolverStatus(string calldata details, bool registered) external nonReentrant {

        require(IERC20(swiftResolverToken).balanceOf(_msgSender()) >= swiftResolverTokenBalance, "!swiftResolverTokenBalance");
        swiftResolverRegistrations[_msgSender()] = registered;
        emit UpdateSwiftResolverStatus(_msgSender(), details, registered);
    }
    
    function getClientRegistrations(address account) external view returns (uint256[] memory) { // get `client` registered lockers 

        return clientRegistrations[account];
    }
    
    function getProviderAmounts(uint256 registration) external view returns (address, uint256[] memory) { // get `token` and milestone `amount`s for `provider`

        return (lockers[registration].token, lockers[registration].amount);
    }
    
    function getProviderRegistrations(address account) external view returns (uint256[] memory) { // get `provider` registered lockers

        return providerRegistrations[account];
    }
    
    function getLockerCount() external view returns (uint256) { // get total registered lockers

        return lockerCount;
    }

    function getMarketTermsCount() external view returns (uint256) { // get total market terms stamped by `manager`

        return marketTerms.length;
    }

    function getResolutionsCount() external view returns (uint256) { // get total resolutions passed by LXL `resolver`s

        return resolutions.length;
    }
   
    modifier onlyManager {

        require(msg.sender == manager, "!manager");
        _;
    }
    
    function addMarketTerms(string calldata terms) external nonReentrant onlyManager {

        marketTerms.push(terms);
        emit AddMarketTerms(marketTerms.length-1, terms);
    }
    
    function amendMarketTerms(uint256 index, string calldata terms) external nonReentrant onlyManager {

        marketTerms[index] = terms;
        emit AmendMarketTerms(index, terms);
    }
    
    function tributeToManager(string calldata details) external nonReentrant payable { 

        (bool success, ) = manager.call{value: msg.value}("");
        require(success, "!ethCall");
        emit TributeToManager(msg.value, details);
    }
    
    function updateLockerSettings(
        address _manager, 
        address _swiftResolverToken, 
        address _wETH, 
        uint256 _MAX_DURATION, 
        uint256 _resolutionRate, 
        uint256 _swiftResolverTokenBalance, 
        string calldata _lockerTerms
    ) external nonReentrant onlyManager { 

        manager = _manager;
        swiftResolverToken = _swiftResolverToken;
        wETH = _wETH;
        MAX_DURATION = _MAX_DURATION;
        resolutionRate = _resolutionRate;
        swiftResolverTokenBalance = _swiftResolverTokenBalance;
        lockerTerms = _lockerTerms;
	    
	    emit UpdateLockerSettings(_manager, _swiftResolverToken, _wETH, _MAX_DURATION, _resolutionRate, _swiftResolverTokenBalance, _lockerTerms);
    }
}