pragma solidity ^0.6.0;

contract Ownable {

    address payable public admin;

    constructor() public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "Function reserved to admin");
        _;
    }


    function transferOwnership(address payable _newAdmin) public onlyAdmin {

        require(_newAdmin != address(0), "New admin can't be null");      
        admin = _newAdmin;
    }

    function destroy() onlyAdmin public {

        selfdestruct(admin);
    }

    function destroyAndSend(address payable _recipient) public onlyAdmin {

        selfdestruct(_recipient);
    }
}pragma solidity ^0.6.0;

library SafeMath {

    function safeMul(uint a, uint b) internal pure returns (uint) {

        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {

        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function safeDiv(uint a, uint b) internal pure returns (uint) {

        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
}pragma solidity ^0.6.0;

contract CrowdConfigurableSale is Ownable {

    using SafeMath for uint256;

    uint256 public startDate; 
    uint256 public endDate;

    uint256 public minimumParticipationAmount;

    uint256 public minimumToRaise;

    address payable public wallet;

    address public chainLinkAddress;
    
    uint256 public cap; 

    uint256 public weiRaised;

    bool public isFinalized = false;
    bool public isCanceled = false;

    
    function getChainlinkAddress() public view returns (address) {

        return chainLinkAddress;
    }
    
    function isStarted() public view returns (bool) {

        return startDate <= block.timestamp;
    }

    function changeStartDate(uint256 _startDate) public onlyAdmin {

        startDate = _startDate;
    }

    function changeEndDate(uint256 _endDate) public onlyAdmin {

        endDate = _endDate;
    }
}
pragma solidity ^0.6.0;

library Maps {

    using SafeMath for uint256;

    struct Participant {
        address Address;
        uint256 Participation;
        uint256 Tokens;
        uint256 Timestamp;
    }

    struct Map {
        mapping(uint => Participant) data;
        uint count;
        uint lastIndex;
        mapping(address => bool) addresses;
        mapping(address => uint) indexes;
    }

    function insertOrUpdate(Map storage self, Participant memory value) internal {

        if(!self.addresses[value.Address]) {
            uint newIndex = ++self.lastIndex;
            self.count++;
            self.indexes[value.Address] = newIndex;
            self.addresses[value.Address] = true;
            self.data[newIndex] = value;
        }
        else {
            uint existingIndex = self.indexes[value.Address];
            self.data[existingIndex] = value;
        }
    }

    function remove(Map storage self, Participant storage value) internal returns (bool success) {

        if(!self.addresses[value.Address]) {
            return false;
        }
        uint index = self.indexes[value.Address];
        self.addresses[value.Address] = false;
        self.indexes[value.Address] = 0;
        delete self.data[index];
        self.count--;
        return true;
    }

    function destroy(Map storage self) internal {

        for (uint i; i <= self.lastIndex; i++) {
            if(self.data[i].Address != address(0x0)) {
                delete self.addresses[self.data[i].Address];
                delete self.indexes[self.data[i].Address];
                delete self.data[i];
            }
        }
        self.count = 0;
        self.lastIndex = 0;
        return ;
    }
    
    function contains(Map storage self, Participant memory participant) internal view returns (bool exists) {

        return self.indexes[participant.Address] > 0;
    }

    function length(Map memory self) internal pure returns (uint) {

        return self.count;
    }

    function get(Map storage self, uint index) internal view returns (Participant storage) {

        return self.data[index];
    }

    function getIndexOf(Map storage self, address _address) internal view returns (uint256) {

        return self.indexes[_address];
    }

    function getByAddress(Map storage self, address _address) internal view returns (Participant storage) {

        uint index = self.indexes[_address];
        return self.data[index];
    }

    function containsAddress(Map storage self, address _address) internal view returns (bool exists) {

        return self.indexes[_address] > 0;
    }
}pragma solidity ^0.6.0;


interface IERC20 {


    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external pure returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}

contract CrowdSaleBase is CrowdConfigurableSale {

    using SafeMath for uint256;
    using Maps for Maps.Map;
    IERC20 public token;
    mapping(address => uint256) public participations;
    Maps.Map public participants;

    event Finalized();

    event BuyTokens(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event ClaimBack(address indexed purchaser, uint256 amount);
    
    AggregatorV3Interface internal priceFeed;

    constructor() public { // wallet which has the ICO tokens
        
    }

    function setWallet(address payable _wallet) public onlyAdmin  {

        wallet = _wallet;
    }

    receive () external payable {
        if(msg.sender != wallet && msg.sender != address(0x0) && !isCanceled) {
            buyTokens(msg.value);
        }
    }
    
    function initiatePricefeed() public onlyAdmin {

        priceFeed = AggregatorV3Interface(chainLinkAddress);
    }

    function getTokenRate() public view returns (int) {

        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        
        return (price * 100/6 * 10**10);
    }

    function buyTokens(uint256 _weiAmount) private {

        require(validPurchase(), "Requirements to buy are not met");
        uint256 rate = uint256(getTokenRate());
        uint256 amount = 0;
        uint256 tokens = 0;
        uint256 newBalance = 0;
       
        participations[msg.sender] = participations[msg.sender].safeAdd(_weiAmount);
        if(participants.containsAddress(msg.sender))
        {
            amount = _weiAmount.safeMul(rate);
            tokens = amount.safeDiv(1000000000000000000);
            Maps.Participant memory existingParticipant = participants.getByAddress(msg.sender);
            newBalance = tokens.safeAdd(existingParticipant.Tokens);
        }
        else {
            amount = _weiAmount.safeMul(rate);
            tokens = amount.safeDiv(1000000000000000000);
            newBalance = tokens;
        } 
        participants.insertOrUpdate(Maps.Participant(msg.sender, participations[msg.sender], newBalance, block.timestamp));

        forwardFunds();

        weiRaised = weiRaised.safeAdd(_weiAmount);
        token.transferFrom(wallet, msg.sender, tokens);
        emit BuyTokens(msg.sender, msg.sender, _weiAmount, tokens);
    }

    function GetNumberOfParticipants() public view  returns (uint) {

        return participants.count;
    }

    function GetMaxIndex() public view  returns (uint) {

        return participants.lastIndex;
    }

    function GetParticipant(uint index) public view  returns (address Address, uint256 Participation, uint256 Tokens, uint256 Timestamp ) {

        Maps.Participant memory participant = participants.get(index);
        Address = participant.Address;
        Participation = participant.Participation;
        Tokens = participant.Tokens;
        Timestamp = participant.Timestamp;
    }
    
    function Contains(address _address) public view returns (bool) {

        return participants.contains(Maps.Participant(_address, 0, 0, block.timestamp));
    }
    
    function Destroy() private returns (bool) {

        participants.destroy();
    }

    function buyTokens() public payable {

        require(msg.sender != address(0x0), "Can't by from null");
        buyTokens(msg.value);
    }

    function transferTokensManual(address beneficiary, uint256 amount) public onlyAdmin {

        require(beneficiary != address(0x0), "address can't be null");
        require(amount > 0, "amount should greater than 0");

        token.transferFrom(wallet, beneficiary, amount);

        emit BuyTokens(wallet, beneficiary, 0, amount);

    }

    function forwardFunds() internal {

        wallet.transfer(msg.value);
    }

    function finalize() public onlyAdmin {

        require(!isFinalized, "Is already finalised");
        emit Finalized();
        isFinalized = true;
    }

    function validPurchase() internal view returns (bool) {

        bool withinPeriod = startDate <= block.timestamp && endDate >= block.timestamp;
        bool nonZeroPurchase = msg.value != 0;
        bool minAmount = msg.value >= minimumParticipationAmount;
        bool withinCap = weiRaised.safeAdd(msg.value) <= cap;

        return withinPeriod && nonZeroPurchase && minAmount && !isFinalized && withinCap;
    }

    function capReached() public view returns (bool) {

        return weiRaised >= cap;
    }

    function minimumCapReached() public view returns (bool) {

        return weiRaised >= minimumToRaise;
    }

    function claimBack() public {

        require(isCanceled, "The presale is not canceled, claiming back is not possible");
        require(participations[msg.sender] > 0, "The sender didn't participate to the presale");
        uint256 participation = participations[msg.sender];
        participations[msg.sender] = 0;
        msg.sender.transfer(participation);
        emit ClaimBack(msg.sender, participation);
    }

    function cancelSaleIfCapNotReached() public onlyAdmin {

        require(weiRaised < minimumToRaise, "The amount raised must not exceed the minimum cap");
        require(!isCanceled, "The presale must not be canceled");
        require(endDate > block.timestamp, "The presale must not have ended");
        isCanceled = true;
    }
}pragma solidity ^0.6.0;

contract CrowdSale is CrowdSaleBase {

    using SafeMath for uint256;
    
    constructor() public {
        wallet = 0xA4A5564Fbb72a0C0026082C5E6863AE21FB79E31;
        
        token = IERC20(0x1E19D4e538B1583613347671965A2FA848271f8a);
      
        
        startDate = 1623715331;
        
        endDate = 1640953855;
        
        minimumParticipationAmount = 20000000000000000 wei;
        
        minimumToRaise = 1000000000000000 wei;
        
        chainLinkAddress = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
     
        
        
        cap = 16467100000000000000000 wei;
    }
}