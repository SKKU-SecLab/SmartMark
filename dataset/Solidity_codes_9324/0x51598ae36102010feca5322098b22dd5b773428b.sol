
pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) view public returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);


    function approve(address _spender, uint256 _value) public returns (bool success);


    function allowance(address _owner, address _spender) public view returns (uint256 remaining);


    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address _owner, address _spender, uint256 _value);
}

contract ERC20Token is Token {


    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

library AddressUtils {

  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

interface ERC165 {

  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}


contract SupportsInterfaceWithLookup is ERC165 {
  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;

  mapping(bytes4 => bool) internal supportedInterfaces;

  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}

contract ERC721Receiver {
  bytes4 internal constant ERC721_RECEIVED = 0xf0b9e5ba;

  function onERC721Received(
    address _from,
    uint256 _tokenId,
    bytes memory _data
  )
    public
    returns(bytes4);
}

contract ERC721Basic is ERC165 {
  event Transfer(
    address  _from,
    address  _to,
    uint256  _tokenId
  );
  event Approval(
    address  _owner,
    address  _approved,
    uint256  _tokenId
  );
  event ApprovalForAll(
    address  _owner,
    address  _operator,
    bool _approved
  );

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId)
    public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    public;
}

contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic {

  bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

  bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;

  using SafeMath for uint256;
  using AddressUtils for address;

  bytes4 private constant ERC721_RECEIVED = 0xf0b9e5ba;

  mapping (uint256 => address) internal tokenOwner;

  mapping (uint256 => address) internal tokenApprovals;

  mapping (address => uint256) internal ownedTokensCount;

  mapping (address => mapping (address => bool)) internal operatorApprovals;


  uint public testint;
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC721);
    _registerInterface(InterfaceId_ERC721Exists);
  }

  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    tokenApprovals[_tokenId] = _to;
    emit Approval(owner, _to, _tokenId);
  }

  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    return operatorApprovals[_owner][_operator];
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
    canTransfer(_tokenId)
  {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
    canTransfer(_tokenId)
  {
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    public
    canTransfer(_tokenId)
  {
    transferFrom(_from, _to, _tokenId);
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  function isApprovedOrOwner(
    address _spender,
    uint256 _tokenId
  )
    internal
    view
    returns (bool)
  {
    address owner = ownerOf(_tokenId);
    return (
      _spender == owner ||
      getApproved(_tokenId) == _spender ||
      isApprovedForAll(owner, _spender)
    );
  }

  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
    }
  }

  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(
      _from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

contract ERC721BasicTokenMock is ERC721BasicToken {
  function mint(address _to, uint256 _tokenId) public {
    super._mint(_to, _tokenId);
  }

  function burn(uint256 _tokenId) public {
    super._burn(ownerOf(_tokenId), _tokenId);
  }
}

contract StandardBounties {

  using SafeMath for uint256;


  struct Bounty {
    address payable[] issuers; // An array of individuals who have complete control over the bounty, and can edit any of its parameters
    address[] approvers; // An array of individuals who are allowed to accept the fulfillments for a particular bounty
    uint deadline; // The Unix timestamp before which all submissions must be made, and after which refunds may be processed
    address token; // The address of the token associated with the bounty (should be disregarded if the tokenVersion is 0)
    uint tokenVersion; // The version of the token being used for the bounty (0 for ETH, 20 for ERC20, 721 for ERC721)
    uint balance; // The number of tokens which the bounty is able to pay out or refund
    bool hasPaidOut; // A boolean storing whether or not the bounty has paid out at least once, meaning refunds are no longer allowed
    Fulfillment[] fulfillments; // An array of Fulfillments which store the various submissions which have been made to the bounty
    Contribution[] contributions; // An array of Contributions which store the contributions which have been made to the bounty
  }

  struct Fulfillment {
    address payable[] fulfillers; // An array of addresses who should receive payouts for a given submission
    address submitter; // The address of the individual who submitted the fulfillment, who is able to update the submission as needed
  }

  struct Contribution {
    address payable contributor; // The address of the individual who contributed
    uint amount; // The amount of tokens the user contributed
    bool refunded; // A boolean storing whether or not the contribution has been refunded yet
  }


  uint public numBounties; // An integer storing the total number of bounties in the contract
  mapping(uint => Bounty) public bounties; // A mapping of bountyIDs to bounties
  mapping (uint => mapping (uint => bool)) public tokenBalances; // A mapping of bountyIds to tokenIds to booleans, storing whether a given bounty has a given ERC721 token in its balance


  address public owner; // The address of the individual who's allowed to set the metaTxRelayer address
  address public metaTxRelayer; // The address of the meta transaction relayer whose _sender is automatically trusted for all contract calls

  bool public callStarted; // Ensures mutex for the entire contract


  modifier callNotStarted(){
    require(!callStarted);
    callStarted = true;
    _;
    callStarted = false;
  }

  modifier validateBountyArrayIndex(
    uint _index)
  {
    require(_index < numBounties);
    _;
  }

  modifier validateContributionArrayIndex(
    uint _bountyId,
    uint _index)
  {
    require(_index < bounties[_bountyId].contributions.length);
    _;
  }

  modifier validateFulfillmentArrayIndex(
    uint _bountyId,
    uint _index)
  {
    require(_index < bounties[_bountyId].fulfillments.length);
    _;
  }

  modifier validateIssuerArrayIndex(
    uint _bountyId,
    uint _index)
  {
    require(_index < bounties[_bountyId].issuers.length);
    _;
  }

  modifier validateApproverArrayIndex(
    uint _bountyId,
    uint _index)
  {
    require(_index < bounties[_bountyId].approvers.length);
    _;
  }

  modifier onlyIssuer(
  address _sender,
  uint _bountyId,
  uint _issuerId)
  {
  require(_sender == bounties[_bountyId].issuers[_issuerId]);
  _;
  }

  modifier onlySubmitter(
    address _sender,
    uint _bountyId,
    uint _fulfillmentId)
  {
    require(_sender ==
            bounties[_bountyId].fulfillments[_fulfillmentId].submitter);
    _;
  }

  modifier onlyContributor(
  address _sender,
  uint _bountyId,
  uint _contributionId)
  {
    require(_sender ==
            bounties[_bountyId].contributions[_contributionId].contributor);
    _;
  }

  modifier isApprover(
    address _sender,
    uint _bountyId,
    uint _approverId)
  {
    require(_sender == bounties[_bountyId].approvers[_approverId]);
    _;
  }

  modifier hasNotPaid(
    uint _bountyId)
  {
    require(!bounties[_bountyId].hasPaidOut);
    _;
  }

  modifier hasNotRefunded(
    uint _bountyId,
    uint _contributionId)
  {
    require(!bounties[_bountyId].contributions[_contributionId].refunded);
    _;
  }

  modifier senderIsValid(
    address _sender)
  {
    require(msg.sender == _sender || msg.sender == metaTxRelayer);
    _;
  }


  constructor() public {
    owner = msg.sender;
  }

  function setMetaTxRelayer(address _relayer)
    external
  {
    require(msg.sender == owner); // Checks that only the owner can call
    require(metaTxRelayer == address(0)); // Ensures the meta tx relayer can only be set once
    metaTxRelayer = _relayer;
  }

  function issueBounty(
    address payable _sender,
    address payable[] memory _issuers,
    address[] memory _approvers,
    string memory _data,
    uint _deadline,
    address _token,
    uint _tokenVersion)
    public
    senderIsValid(_sender)
    returns (uint)
  {
    require(_tokenVersion == 0 || _tokenVersion == 20 || _tokenVersion == 721); // Ensures a bounty can only be issued with a valid token version
    require(_issuers.length > 0 || _approvers.length > 0); // Ensures there's at least 1 issuer or approver, so funds don't get stuck

    uint bountyId = numBounties; // The next bounty's index will always equal the number of existing bounties

    Bounty storage newBounty = bounties[bountyId];
    newBounty.issuers = _issuers;
    newBounty.approvers = _approvers;
    newBounty.deadline = _deadline;
    newBounty.tokenVersion = _tokenVersion;

    if (_tokenVersion != 0){
      newBounty.token = _token;
    }

    numBounties = numBounties.add(1); // Increments the number of bounties, since a new one has just been added

    emit BountyIssued(bountyId,
                      _sender,
                      _issuers,
                      _approvers,
                      _data, // Instead of storing the string on-chain, it is emitted within the event for easy off-chain consumption
                      _deadline,
                      _token,
                      _tokenVersion);

    return (bountyId);
  }



  function issueAndContribute(
    address payable _sender,
    address payable[] memory _issuers,
    address[] memory _approvers,
    string memory _data,
    uint _deadline,
    address _token,
    uint _tokenVersion,
    uint _depositAmount)
    public
    payable
    returns(uint)
  {
    uint bountyId = issueBounty(_sender, _issuers, _approvers, _data, _deadline, _token, _tokenVersion);

    contribute(_sender, bountyId, _depositAmount);

    return (bountyId);
  }


  function contribute(
    address payable _sender,
    uint _bountyId,
    uint _amount)
    public
    payable
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    callNotStarted
  {
    require(_amount > 0); // Contributions of 0 tokens or token ID 0 should fail

    bounties[_bountyId].contributions.push(
      Contribution(_sender, _amount, false)); // Adds the contribution to the bounty

    if (bounties[_bountyId].tokenVersion == 0){

      bounties[_bountyId].balance = bounties[_bountyId].balance.add(_amount); // Increments the balance of the bounty

      require(msg.value == _amount);
    } else if (bounties[_bountyId].tokenVersion == 20){

      bounties[_bountyId].balance = bounties[_bountyId].balance.add(_amount); // Increments the balance of the bounty

      require(msg.value == 0); // Ensures users don't accidentally send ETH alongside a token contribution, locking up funds
      require(ERC20Token(bounties[_bountyId].token).transferFrom(_sender,
                                                                 address(this),
                                                                 _amount));
    } else if (bounties[_bountyId].tokenVersion == 721){
      tokenBalances[_bountyId][_amount] = true; // Adds the 721 token to the balance of the bounty


      require(msg.value == 0); // Ensures users don't accidentally send ETH alongside a token contribution, locking up funds
      ERC721BasicToken(bounties[_bountyId].token).transferFrom(_sender,
                                                               address(this),
                                                               _amount);
    } else {
      revert();
    }

    emit ContributionAdded(_bountyId,
                           bounties[_bountyId].contributions.length - 1, // The new contributionId
                           _sender,
                           _amount);
  }

  function refundContribution(
    address _sender,
    uint _bountyId,
    uint _contributionId)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateContributionArrayIndex(_bountyId, _contributionId)
    onlyContributor(_sender, _bountyId, _contributionId)
    hasNotPaid(_bountyId)
    hasNotRefunded(_bountyId, _contributionId)
    callNotStarted
  {
    require(now > bounties[_bountyId].deadline); // Refunds may only be processed after the deadline has elapsed

    Contribution storage contribution = bounties[_bountyId].contributions[_contributionId];

    contribution.refunded = true;

    transferTokens(_bountyId, contribution.contributor, contribution.amount); // Performs the disbursal of tokens to the contributor

    emit ContributionRefunded(_bountyId, _contributionId);
  }

  function refundMyContributions(
    address _sender,
    uint _bountyId,
    uint[] memory _contributionIds)
    public
    senderIsValid(_sender)
  {
    for (uint i = 0; i < _contributionIds.length; i++){
        refundContribution(_sender, _bountyId, _contributionIds[i]);
    }
  }

  function refundContributions(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    uint[] memory _contributionIds)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    onlyIssuer(_sender, _bountyId, _issuerId)
    callNotStarted
  {
    for (uint i = 0; i < _contributionIds.length; i++){
      require(_contributionIds[i] < bounties[_bountyId].contributions.length);

      Contribution storage contribution = bounties[_bountyId].contributions[_contributionIds[i]];

      require(!contribution.refunded);

      contribution.refunded = true;

      transferTokens(_bountyId, contribution.contributor, contribution.amount); // Performs the disbursal of tokens to the contributor
    }

    emit ContributionsRefunded(_bountyId, _sender, _contributionIds);
  }

  function drainBounty(
    address payable _sender,
    uint _bountyId,
    uint _issuerId,
    uint[] memory _amounts)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    onlyIssuer(_sender, _bountyId, _issuerId)
    callNotStarted
  {
    if (bounties[_bountyId].tokenVersion == 0 || bounties[_bountyId].tokenVersion == 20){
      require(_amounts.length == 1); // ensures there's only 1 amount of tokens to be returned
      require(_amounts[0] <= bounties[_bountyId].balance); // ensures an issuer doesn't try to drain the bounty of more tokens than their balance permits
      transferTokens(_bountyId, _sender, _amounts[0]); // Performs the draining of tokens to the issuer
    } else {
      for (uint i = 0; i < _amounts.length; i++){
        require(tokenBalances[_bountyId][_amounts[i]]);// ensures an issuer doesn't try to drain the bounty of a token it doesn't have in its balance
        transferTokens(_bountyId, _sender, _amounts[i]);
      }
    }

    emit BountyDrained(_bountyId, _sender, _amounts);
  }

  function performAction(
    address _sender,
    uint _bountyId,
    string memory _data)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
  {
    emit ActionPerformed(_bountyId, _sender, _data); // The _data string is emitted in an event for easy off-chain consumption
  }

  function fulfillBounty(
    address _sender,
    uint _bountyId,
    address payable[] memory  _fulfillers,
    string memory _data)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
  {
    require(now < bounties[_bountyId].deadline); // Submissions are only allowed to be made before the deadline
    require(_fulfillers.length > 0); // Submissions with no fulfillers would mean no one gets paid out

    bounties[_bountyId].fulfillments.push(Fulfillment(_fulfillers, _sender));

    emit BountyFulfilled(_bountyId,
                         (bounties[_bountyId].fulfillments.length - 1),
                         _fulfillers,
                         _data, // The _data string is emitted in an event for easy off-chain consumption
                         _sender);
  }

  function updateFulfillment(
  address _sender,
  uint _bountyId,
  uint _fulfillmentId,
  address payable[] memory _fulfillers,
  string memory _data)
  public
  senderIsValid(_sender)
  validateBountyArrayIndex(_bountyId)
  validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)
  onlySubmitter(_sender, _bountyId, _fulfillmentId) // Only the original submitter of a fulfillment may update their submission
  {
    bounties[_bountyId].fulfillments[_fulfillmentId].fulfillers = _fulfillers;
    emit FulfillmentUpdated(_bountyId,
                            _fulfillmentId,
                            _fulfillers,
                            _data); // The _data string is emitted in an event for easy off-chain consumption
  }

  function acceptFulfillment(
    address _sender,
    uint _bountyId,
    uint _fulfillmentId,
    uint _approverId,
    uint[] memory _tokenAmounts)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)
    isApprover(_sender, _bountyId, _approverId)
    callNotStarted
  {
    bounties[_bountyId].hasPaidOut = true;

    Fulfillment storage fulfillment = bounties[_bountyId].fulfillments[_fulfillmentId];

    require(_tokenAmounts.length == fulfillment.fulfillers.length); // Each fulfiller should get paid some amount of tokens (this can be 0)

    for (uint256 i = 0; i < fulfillment.fulfillers.length; i++){
        if (_tokenAmounts[i] > 0){
          transferTokens(_bountyId, fulfillment.fulfillers[i], _tokenAmounts[i]);
        }
    }
    emit FulfillmentAccepted(_bountyId,
                             _fulfillmentId,
                             _sender,
                             _tokenAmounts);
  }

  function fulfillAndAccept(
    address _sender,
    uint _bountyId,
    address payable[] memory _fulfillers,
    string memory _data,
    uint _approverId,
    uint[] memory _tokenAmounts)
    public
    senderIsValid(_sender)
  {
    fulfillBounty(_sender, _bountyId, _fulfillers, _data);

    acceptFulfillment(_sender,
                      _bountyId,
                      bounties[_bountyId].fulfillments.length - 1,
                      _approverId,
                      _tokenAmounts);
  }



  function changeBounty(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    address payable[] memory _issuers,
    address payable[] memory _approvers,
    string memory _data,
    uint _deadline)
    public
    senderIsValid(_sender)
  {
    require(_bountyId < numBounties); // makes the validateBountyArrayIndex modifier in-line to avoid stack too deep errors
    require(_issuerId < bounties[_bountyId].issuers.length); // makes the validateIssuerArrayIndex modifier in-line to avoid stack too deep errors
    require(_sender == bounties[_bountyId].issuers[_issuerId]); // makes the onlyIssuer modifier in-line to avoid stack too deep errors

    require(_issuers.length > 0 || _approvers.length > 0); // Ensures there's at least 1 issuer or approver, so funds don't get stuck

    bounties[_bountyId].issuers = _issuers;
    bounties[_bountyId].approvers = _approvers;
    bounties[_bountyId].deadline = _deadline;
    emit BountyChanged(_bountyId,
                       _sender,
                       _issuers,
                       _approvers,
                       _data,
                       _deadline);
  }

  function changeIssuer(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    uint _issuerIdToChange,
    address payable _newIssuer)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateIssuerArrayIndex(_bountyId, _issuerIdToChange)
    onlyIssuer(_sender, _bountyId, _issuerId)
  {
    require(_issuerId < bounties[_bountyId].issuers.length || _issuerId == 0);

    bounties[_bountyId].issuers[_issuerIdToChange] = _newIssuer;

    emit BountyIssuersUpdated(_bountyId, _sender, bounties[_bountyId].issuers);
  }

  function changeApprover(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    uint _approverId,
    address payable _approver)
    external
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    onlyIssuer(_sender, _bountyId, _issuerId)
    validateApproverArrayIndex(_bountyId, _approverId)
  {
    bounties[_bountyId].approvers[_approverId] = _approver;

    emit BountyApproversUpdated(_bountyId, _sender, bounties[_bountyId].approvers);
  }

  function changeIssuerAndApprover(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    uint _issuerIdToChange,
    uint _approverIdToChange,
    address payable _issuer)
    external
    senderIsValid(_sender)
    onlyIssuer(_sender, _bountyId, _issuerId)
  {
    require(_bountyId < numBounties);
    require(_approverIdToChange < bounties[_bountyId].approvers.length);
    require(_issuerIdToChange < bounties[_bountyId].issuers.length);

    bounties[_bountyId].issuers[_issuerIdToChange] = _issuer;
    bounties[_bountyId].approvers[_approverIdToChange] = _issuer;

    emit BountyIssuersUpdated(_bountyId, _sender, bounties[_bountyId].issuers);
    emit BountyApproversUpdated(_bountyId, _sender, bounties[_bountyId].approvers);
  }

  function changeData(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    string memory _data)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateIssuerArrayIndex(_bountyId, _issuerId)
    onlyIssuer(_sender, _bountyId, _issuerId)
  {
    emit BountyDataChanged(_bountyId, _sender, _data); // The new _data is emitted within an event rather than being stored on-chain for minimized gas costs
  }

  function changeDeadline(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    uint _deadline)
    external
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateIssuerArrayIndex(_bountyId, _issuerId)
    onlyIssuer(_sender, _bountyId, _issuerId)
  {
    bounties[_bountyId].deadline = _deadline;

    emit BountyDeadlineChanged(_bountyId, _sender, _deadline);
  }

  function addIssuers(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    address payable[] memory _issuers)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateIssuerArrayIndex(_bountyId, _issuerId)
    onlyIssuer(_sender, _bountyId, _issuerId)
  {
    for (uint i = 0; i < _issuers.length; i++){
      bounties[_bountyId].issuers.push(_issuers[i]);
    }

    emit BountyIssuersUpdated(_bountyId, _sender, bounties[_bountyId].issuers);
  }

  function addApprovers(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    address[] memory _approvers)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateIssuerArrayIndex(_bountyId, _issuerId)
    onlyIssuer(_sender, _bountyId, _issuerId)
  {
    for (uint i = 0; i < _approvers.length; i++){
      bounties[_bountyId].approvers.push(_approvers[i]);
    }

    emit BountyApproversUpdated(_bountyId, _sender, bounties[_bountyId].approvers);
  }

  function getBounty(uint _bountyId)
    external
    view
    returns (Bounty memory)
  {
    return bounties[_bountyId];
  }


  function transferTokens(uint _bountyId, address payable _to, uint _amount)
    internal
  {
    if (bounties[_bountyId].tokenVersion == 0){
      require(_amount > 0); // Sending 0 tokens should throw
      require(bounties[_bountyId].balance >= _amount);

      bounties[_bountyId].balance = bounties[_bountyId].balance.sub(_amount);

      _to.transfer(_amount);
    } else if (bounties[_bountyId].tokenVersion == 20){
      require(_amount > 0); // Sending 0 tokens should throw
      require(bounties[_bountyId].balance >= _amount);

      bounties[_bountyId].balance = bounties[_bountyId].balance.sub(_amount);

      require(ERC20Token(bounties[_bountyId].token).transfer(_to, _amount));
    } else if (bounties[_bountyId].tokenVersion == 721){
      require(tokenBalances[_bountyId][_amount]);

      tokenBalances[_bountyId][_amount] = false; // Removes the 721 token from the balance of the bounty

      ERC721BasicToken(bounties[_bountyId].token).transferFrom(address(this),
                                                               _to,
                                                               _amount);
    } else {
      revert();
    }
  }


  event BountyIssued(uint _bountyId, address payable _creator, address payable[] _issuers, address[] _approvers, string _data, uint _deadline, address _token, uint _tokenVersion);
  event ContributionAdded(uint _bountyId, uint _contributionId, address payable _contributor, uint _amount);
  event ContributionRefunded(uint _bountyId, uint _contributionId);
  event ContributionsRefunded(uint _bountyId, address _issuer, uint[] _contributionIds);
  event BountyDrained(uint _bountyId, address _issuer, uint[] _amounts);
  event ActionPerformed(uint _bountyId, address _fulfiller, string _data);
  event BountyFulfilled(uint _bountyId, uint _fulfillmentId, address payable[] _fulfillers, string _data, address _submitter);
  event FulfillmentUpdated(uint _bountyId, uint _fulfillmentId, address payable[] _fulfillers, string _data);
  event FulfillmentAccepted(uint _bountyId, uint  _fulfillmentId, address _approver, uint[] _tokenAmounts);
  event BountyChanged(uint _bountyId, address _changer, address payable[] _issuers, address payable[] _approvers, string _data, uint _deadline);
  event BountyIssuersUpdated(uint _bountyId, address _changer, address payable[] _issuers);
  event BountyApproversUpdated(uint _bountyId, address _changer, address[] _approvers);
  event BountyDataChanged(uint _bountyId, address _changer, string _data);
  event BountyDeadlineChanged(uint _bountyId, address _changer, uint _deadline);
}