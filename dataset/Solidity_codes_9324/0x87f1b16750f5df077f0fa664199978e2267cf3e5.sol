pragma solidity ^0.8.4;

interface IUniftyGovernanceConsumer{

    
    event Withdrawn(address indexed user, uint256 untEarned);

    function name() external view returns(string calldata);

    
    function description() external view returns(string calldata);

    
    function whitelistPeer(address _peer) external;

    
    function removePeerFromWhitelist(address _peer) external;

    
    function allocate(address _account, uint256 prevAllocation, address _peer) external returns(bool);

    
    function allocationUpdate(address _account, uint256 prevAmount, uint256 prevAllocation, address _peer) external returns(bool, uint256);

    
    function dellocate(address _account, uint256 prevAllocation, address _peer) external returns(uint256);

    
    function frozen(address _account) external view returns(bool);

    
    function peerWhitelisted(address _peer) external view returns(bool);

    
    function peerUri(address _peer) external view returns(string calldata);

    
    function timeToUnfreeze(address _account) external view returns(uint256);

    
    function apInfo(address _peer) external view returns(string memory, uint256, uint256[] memory);

    
    function withdraw() external returns(uint256);

    
    function earned(address _account) external view returns(uint256);

    
    function earnedLive(address _account) external view returns(uint256);

    
    function peerNifCap(address _peer) external view returns(uint256);

}pragma solidity ^0.8.4;


interface IUniftyGovernance{


    function epoch() external returns(uint256);

    
    function grantableUnt() external returns(uint256);

    
    function mintUnt(uint256 _amount) external;

    
    function accountInfo(address _account) external view returns(IUniftyGovernanceConsumer, address, uint256, uint256, uint256);

    
    function consumerInfo(IUniftyGovernanceConsumer _consumer) external view returns(uint256, uint256, uint256, address[] calldata, string[] calldata);

    
    function nifAllocationLength(IUniftyGovernanceConsumer _consumer, address _peer) external view returns(uint256);

    
    function earnedUnt(IUniftyGovernanceConsumer _consumer) external view returns(uint256);

    
    function isPausing() external view returns(bool);

    
    function consumerPeerNifAllocation(IUniftyGovernanceConsumer _consumer, address _peer) external view returns(uint256);

}pragma solidity ^0.8.4;

interface IERC20Simple {


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}pragma solidity ^0.8.4;


contract LaunchVault is IUniftyGovernanceConsumer{


    IUniftyGovernance public gov;

    address public untAddress;

    uint256 public minAllocationDuration; // default: 86400 * 10 should be 10 days after acceptance
    uint256 public allocationExpirationTime; // will be set upon adding this as peer based on minAllocationDuration
    
    bool public isPeer;

    uint256 public untRate;

    uint256 public graceTime;

    string public uriPeer;

    string public consumerName;

    string public consumerDscription;

    address public owner;

    uint256 public collectedUnt;

    uint256 public lastCollectionTime;

    uint256 public nifCap;

    uint256[] public priceProviders;

    uint256 public lastCollectionBlock;
    
    bool public pausing;
    
    bool public withdrawOnPause;

    mapping(address => uint256) public accountDebt;
    mapping(address => uint256) public accountCredit;
    mapping(address => uint256) public accountPrevAmount;
    
    event Credited(address indexed user, uint256 untCredited);
    event CreditPaid(address indexed user, uint256 untPaid);

    uint256 private unlocked = 1;

    modifier lock() {

        require(unlocked == 1, 'LaunchVault: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(
        IUniftyGovernance _gov,
        string memory _name,
        string memory _description,
        string memory _peerUri,
        uint256 _graceTime,
        uint256 _minAllocationDuration,
        uint256 _nifCap,
        uint256 _untRate,
        uint256[] memory _priceProviders
    ){

        gov = _gov;
        owner = msg.sender;
        consumerName = _name;
        consumerDscription = _description;
        uriPeer = _peerUri;
        graceTime = _graceTime;
        minAllocationDuration = _minAllocationDuration;
        nifCap = _nifCap;
        untRate = _untRate;
        priceProviders = _priceProviders;
        untAddress = 0xF8fCC10506ae0734dfd2029959b93E6ACe5b2a70;
    }

    function setGovernance(IUniftyGovernance _gov) external lock{


        require(owner == msg.sender, "setGovernance: not the owner.");
        require(address(_gov) != address(0), "setGovernance: cannot move to the null address.");

        isPeer = false;

        gov = _gov;
    }

    function setPeerUri(string calldata _uri) external lock{


        require(owner == msg.sender, "setPeerUri: not the owner.");

        uriPeer = _uri;

    }

    function setGraceTime(uint256 _graceTime) external lock{


        require(owner == msg.sender, "setGraceTime: not the owner.");

        graceTime = _graceTime;

    }

    function setNifCap(uint256 _nifCap) external lock{


        require(owner == msg.sender, "setNifCap: not the owner.");

        nifCap = _nifCap;

    }
    
    function setPausing(bool _pausing, bool _withdrawOnPause) external lock{


        require(owner == msg.sender, "setPausing: not the owner.");

        pausing = _pausing;
        withdrawOnPause = _withdrawOnPause;

    }

    function setUntRateAndPriceProviders(uint256 _untRate, uint256[] calldata _priceProviders) external lock{


        require(owner == msg.sender, "setUntRateAndPriceProviders: not the owner.");

        untRate = _untRate;
        priceProviders = _priceProviders;

    }

    function setMinAllocationDuration(uint256 _minAllocationDuration) external lock{


        require(owner == msg.sender, "setMinAllocationDuration: not the owner.");

        minAllocationDuration = _minAllocationDuration;
        
        if(allocationExpirationTime != 0){
            
            allocationExpirationTime = block.timestamp + _minAllocationDuration;
        }

    }

    function setNameAndDescription(string calldata _name, string calldata _description) external lock{


        require(owner == msg.sender, "setNameAndDescription: not the owner.");

        consumerName = _name;
        consumerDscription = _description;

    }

    function transferOwnership(address _newOwner) external lock{


        require(owner == msg.sender, "transferOwnership: not the owner.");

        owner = _newOwner;
    }


    function withdraw() override external lock returns(uint256){


        require(!pausing || ( pausing && withdrawOnPause ), "withdraw: pausing, sorry.");

        (IUniftyGovernanceConsumer con,address peer,,,) = gov.accountInfo(msg.sender);
        
        require(con == this && peer == address(this) && isPeer, "withdraw: access denied.");
        
        require(!frozen(msg.sender), "withdraw: you are withdrawing too early.");

        collectUnt();
        uint256 _earned = ( ( collectedUnt * accountPrevAmount[msg.sender] ) / 10**18 ) - accountDebt[msg.sender];
        accountDebt[msg.sender] = ( collectedUnt * accountPrevAmount[msg.sender] ) / 10**18;

        uint256 paid = payout(msg.sender, _earned);

        return paid;
    }

    function payout(address _to, uint256 _amount) internal returns(uint256) {

        
        
        uint256 credit = accountCredit[_to];
        accountCredit[_to] = 0;
        _amount += credit;
        
        
        uint256 grantLeft = gov.earnedUnt(this);
        
        if(_amount > grantLeft){
            
            _amount = grantLeft;
        }
        
        require(_amount != 0, "payout: nothing to pay out.");

        gov.mintUnt(_amount);

        IERC20Simple(untAddress).transfer(_to, _amount);
        
        emit Withdrawn(_to, _amount);
        
        if(credit != 0 && _amount <= grantLeft){

            emit CreditPaid(_to, credit);
        }
        
        return _amount;
    }

    function earned(address _account) override external view returns(uint256){


        (IUniftyGovernanceConsumer con,address peer,,,) = gov.accountInfo(_account);

        if(con != this || peer != address(this) || !isPeer){

            return 0;
        }

        return ( ( collectedUnt * accountPrevAmount[_account] ) / 10**18 ) - accountDebt[_account];
    }

    function earnedLive(address _account) override external view returns(uint256){


        (IUniftyGovernanceConsumer con,address peer,,,) = gov.accountInfo(_account);

        if(con != this || peer != address(this) || !isPeer){

            return 0;
        }

        uint256 coll = collectedUnt;

        uint256 alloc = gov.consumerPeerNifAllocation(this, address(this));

        if (block.number > lastCollectionBlock && alloc != 0) {

            coll += ( accumulatedUnt() * 10**18 ) / alloc;
        }

        return ( ( coll * accountPrevAmount[_account] ) / 10**18 ) - accountDebt[_account];
    }

    function apInfo(address _peer) override external view returns(string memory, uint256, uint256[] memory){


        if( _peer != address(this) || !isPeer){

            uint256[] memory n;
            return ("",0,n);
        }

        return ("r", untRate * 86400 * 365, priceProviders);
    }

    function accumulatedUnt() internal view returns(uint256){


        if(lastCollectionTime == 0){

            return 0;
        }

        return ( block.timestamp - lastCollectionTime ) * untRate;
    }

    function collectUnt() internal{


        uint256 alloc = gov.consumerPeerNifAllocation(this, address(this));

        if(alloc != 0){

            collectedUnt += ( accumulatedUnt() * 10**18 ) / alloc;
        }

        lastCollectionTime = block.timestamp;
        lastCollectionBlock = block.number;
    }
    
    function collectUnt(uint256 nifAllocation) internal{


        if(nifAllocation != 0){

            collectedUnt += ( accumulatedUnt() * 10**18 ) / nifAllocation;
        }

        lastCollectionTime = block.timestamp;
        lastCollectionBlock = block.number;
    }

    function whitelistPeer(address _peer) override external lock{


        require(IUniftyGovernance(msg.sender) == gov, "whitelistPeer: access denied.");
        require(_peer == address(this), "whitelistPeer: this consumer only allows itself as peer.");
        require(!isPeer, "whitelistPeer: peer exists already.");

        isPeer = true;
        
        allocationExpirationTime = block.timestamp + minAllocationDuration;
    }

    function removePeerFromWhitelist(address _peer) override external lock{


        require(IUniftyGovernance(msg.sender) == gov, "removePeerFromWhitelist: access denied.");
        require(_peer == address(this), "removePeerFromWhitelist: this consumer only allows itself as peer.");
        require(isPeer, "removePeerFromWhitelist: peer not whitelisted.");

        isPeer = false;
    }

    function allocate(address _account, uint256 prevAllocation, address _peer) override external lock returns(bool){


        require(IUniftyGovernance(msg.sender) == gov, "allocate: access denied.");
        require(_peer == address(this) && isPeer, "allocate: invalid peer.");

        (,,,,uint256 amount) = gov.accountInfo(_account);

        uint256 alloc = gov.consumerPeerNifAllocation(this, address(this));

        if(alloc > nifCap || pausing){

            return false;
        }

        accountPrevAmount[_account] = amount;

        collectUnt();
        accountDebt[_account] = ( collectedUnt * amount ) / 10**18;

        return true;
    }

    function allocationUpdate(address _account, uint256 prevAmount, uint256 prevAllocation, address _peer) override external lock returns(bool, uint256){


        require(IUniftyGovernance(msg.sender) == gov, "allocationUpdate: access denied.");
        require(_peer == address(this) && isPeer, "allocationUpdate: invalid peer.");

        if(accountPrevAmount[_account] == 0){

            return (true, 0);
        }

        (,,,,uint256 amount) = gov.accountInfo(_account);

        uint256 alloc = gov.consumerPeerNifAllocation(this, address(this));

        if(alloc > nifCap){
            
            return (false, 0);
        }
        
        collectUnt(prevAllocation);
        
        uint256 _earned = ( ( collectedUnt * accountPrevAmount[_account] ) / 10**18 ) - accountDebt[_account];

        accountDebt[_account] = ( collectedUnt * amount ) / 10**18;
        
        accountPrevAmount[_account] = amount;
        
        uint256 actual = _earned;
        
        if(!frozen(_account) && !pausing){

            actual = payout(_account, _earned);

        }else{

            accountCredit[_account] += _earned;

            emit Credited(_account, _earned);
        }

        return (true, actual);

    }

    function dellocate(address _account, uint256 prevAllocation, address _peer) override external lock returns(uint256){


        require(IUniftyGovernance(msg.sender) == gov, "dellocate: access denied.");
        require(_peer == address(this) && isPeer, "dellocate: invalid peer.");

        if(accountPrevAmount[_account] == 0){

            return 0;
        }

        collectUnt(prevAllocation);
        
        uint256 _earned = ( ( collectedUnt * accountPrevAmount[_account] ) / 10**18 ) - accountDebt[_account];
        accountDebt[_account] = 0;
        accountPrevAmount[_account] = 0;
        
        uint256 actual = _earned;
        
        if(pausing){
            
            accountCredit[_account] += _earned;

            emit Credited(_account, _earned);
            
        }else{
            
            actual = payout(_account, _earned);
        }
        
        return actual;
    }

    function timeToUnfreeze(address _account) override external view returns(uint256){


        (IUniftyGovernanceConsumer con, address peer,,,) = gov.accountInfo(_account);

        if(con != this || peer != address(this) || !isPeer || pausing){

            return 0;
        }

        uint256 _target = allocationExpirationTime + graceTime;
        return _target >= block.timestamp ? _target - block.timestamp : 0;
    }

    function frozen(address _account) override public view returns(bool){


        (IUniftyGovernanceConsumer con, address peer,,,) = gov.accountInfo(_account);

        if(con != this || peer != address(this) || !isPeer || pausing){

            return false;
        }

        if( block.timestamp > allocationExpirationTime + graceTime ){

            return false;
        }

        return true;

    }

    function name() override view external returns(string memory){


        return consumerName;
    }

    function description() override view external returns(string memory){


        return consumerDscription;
    }


    function peerWhitelisted(address _peer) override view external returns(bool){


        return _peer == address(this) && isPeer;
    }

    function peerUri(address _peer) override external view returns(string memory){


        return _peer == address(this) && isPeer ? uriPeer : "";
    }

    function peerNifCap(address _peer) override external view returns(uint256){

        
        if(_peer != address(this) || !isPeer){

            return 0;
        }
        
        return nifCap;
        
    }

}