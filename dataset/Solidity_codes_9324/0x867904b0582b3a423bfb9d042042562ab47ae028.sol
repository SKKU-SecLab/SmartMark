pragma solidity 0.5.16;


contract CloneFactory {


  function createClone(address target) internal returns (address result) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity 0.5.16;


contract ERC20NonTransferrable is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        return false;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return 0;
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        return false;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        return false;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        return false;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        return false;
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}pragma solidity 0.5.16;

interface IStandardBountiesV1 {


  event BountyIssued(uint bountyId);
  event BountyActivated(uint bountyId, address issuer);
  event BountyFulfilled(uint bountyId, address indexed fulfiller, uint256 indexed _fulfillmentId);
  event FulfillmentUpdated(uint _bountyId, uint _fulfillmentId);
  event FulfillmentAccepted(uint bountyId, address indexed fulfiller, uint256 indexed _fulfillmentId);
  event BountyKilled(uint bountyId, address indexed issuer);
  event ContributionAdded(uint bountyId, address indexed contributor, uint256 value);
  event DeadlineExtended(uint bountyId, uint newDeadline);
  event BountyChanged(uint bountyId);
  event IssuerTransferred(uint _bountyId, address indexed _newIssuer);
  event PayoutIncreased(uint _bountyId, uint _newFulfillmentAmount);


  function issueBounty(
    address _issuer,
    uint _deadline,
    string calldata _data,
    uint256 _fulfillmentAmount,
    address _arbiter,
    bool _paysTokens,
    address _tokenContract
  )
      external
      returns (uint);


  function issueAndActivateBounty(
    address _issuer,
    uint _deadline,
    string calldata _data,
    uint256 _fulfillmentAmount,
    address _arbiter,
    bool _paysTokens,
    address _tokenContract,
    uint256 _value
  )
      external
      payable
      returns (uint);


  function contribute (uint _bountyId, uint _value)
      external
      payable;

  function activateBounty(uint _bountyId, uint _value)
      external
      payable;


  function fulfillBounty(uint _bountyId, string calldata _data)
      external;


  function updateFulfillment(uint _bountyId, uint _fulfillmentId, string calldata _data)
      external;


  function acceptFulfillment(uint _bountyId, uint _fulfillmentId)
      external;


  function killBounty(uint _bountyId)
      external;


  function extendDeadline(uint _bountyId, uint _newDeadline)
      external;


  function transferIssuer(uint _bountyId, address _newIssuer)
      external;



  function changeBountyDeadline(uint _bountyId, uint _newDeadline)
      external;


  function changeBountyData(uint _bountyId, string calldata _newData)
      external;


  function changeBountyFulfillmentAmount(uint _bountyId, uint _newFulfillmentAmount)
      external;


  function changeBountyArbiter(uint _bountyId, address _newArbiter)
      external;


  function increasePayout(uint _bountyId, uint _newFulfillmentAmount, uint _value)
      external
      payable;


  function getFulfillment(uint _bountyId, uint _fulfillmentId)
      external
      returns (bool, address, string memory);


  function getBounty(uint _bountyId)
      external
      returns (address, uint, uint, bool, uint, uint);


  function getBountyArbiter(uint _bountyId)
      external
      returns (address);


  function getBountyData(uint _bountyId)
      external
      returns (string memory);


  function getBountyToken(uint _bountyId)
      external
      returns (address);


  function getNumBounties()
      external
      returns (uint);


  function getNumFulfillments(uint _bountyId)
      external
      returns (uint);

}// Abstract contract for the full ERC 20 Token standard
pragma solidity 0.5.16;

contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) view public returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);


    function approve(address _spender, uint256 _value) public returns (bool success);


    function allowance(address _owner, address _spender) public view returns (uint256 remaining);


    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address _owner, address _spender, uint256 _value);
}/*
You should inherit from StandardToken or, for a token like you would want to
deploy in something like Mist, see HumanStandardToken.sol.
(This implements ONLY the standard functions and NOTHING else.
If you deploy this, you won't have anything useful.)

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
.*/
pragma solidity 0.5.16;


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
}pragma solidity 0.5.16;


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
}pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;



contract StandardBounties {

  using SafeMath for uint256;


  struct Bounty {
    address payable [] issuers; // An array of individuals who have complete control over the bounty, and can edit any of its parameters
    address [] approvers; // An array of individuals who are allowed to accept the fulfillments for a particular bounty
    uint deadline; // The Unix timestamp before which all submissions must be made, and after which refunds may be processed
    address token; // The address of the token associated with the bounty (should be disregarded if the tokenVersion is 0)
    uint tokenVersion; // The version of the token being used for the bounty (0 for ETH, 20 for ERC20, 721 for ERC721)
    uint balance; // The number of tokens which the bounty is able to pay out or refund
    bool hasPaidOut; // A boolean storing whether or not the bounty has paid out at least once, meaning refunds are no longer allowed
    Fulfillment [] fulfillments; // An array of Fulfillments which store the various submissions which have been made to the bounty
    Contribution [] contributions; // An array of Contributions which store the contributions which have been made to the bounty
  }

  struct Fulfillment {
    address payable [] fulfillers; // An array of addresses who should receive payouts for a given submission
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
    address payable [] memory _issuers,
    address [] memory _approvers,
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

    if (_tokenVersion != 0) {
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
    address payable [] memory _issuers,
    address [] memory _approvers,
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
    } else if (bounties[_bountyId].tokenVersion == 20) {

      bounties[_bountyId].balance = bounties[_bountyId].balance.add(_amount); // Increments the balance of the bounty

      require(msg.value == 0); // Ensures users don't accidentally send ETH alongside a token contribution, locking up funds
      require(ERC20Token(bounties[_bountyId].token).transferFrom(_sender,
                                                                 address(this),
                                                                 _amount));
    } else if (bounties[_bountyId].tokenVersion == 721) {
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

    Contribution storage contribution =
      bounties[_bountyId].contributions[_contributionId];

    contribution.refunded = true;

    transferTokens(_bountyId, contribution.contributor, contribution.amount); // Performs the disbursal of tokens to the contributor

    emit ContributionRefunded(_bountyId, _contributionId);
  }

  function refundMyContributions(
    address _sender,
    uint _bountyId,
    uint [] memory _contributionIds)
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
    uint [] memory _contributionIds)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    onlyIssuer(_sender, _bountyId, _issuerId)
    callNotStarted
  {
    for (uint i = 0; i < _contributionIds.length; i++){
      require(_contributionIds[i] < bounties[_bountyId].contributions.length);

      Contribution storage contribution =
        bounties[_bountyId].contributions[_contributionIds[i]];

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
    uint [] memory _amounts)
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
    address payable [] memory  _fulfillers,
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
  address payable [] memory _fulfillers,
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

    Fulfillment storage fulfillment =
      bounties[_bountyId].fulfillments[_fulfillmentId];

    require(_tokenAmounts.length == fulfillment.fulfillers.length); // Each fulfiller should get paid some amount of tokens (this can be 0)

    for (uint256 i = 0; i < fulfillment.fulfillers.length; i++){
        if (_tokenAmounts[i] > 0) {
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
    address payable [] memory _fulfillers,
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
    address payable [] memory _issuers,
    address payable [] memory _approvers,
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
    address payable [] memory _issuers)
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

  function replaceIssuers(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    address payable [] memory _issuers)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateIssuerArrayIndex(_bountyId, _issuerId)
    onlyIssuer(_sender, _bountyId, _issuerId)
  {
    require(_issuers.length > 0 || bounties[_bountyId].approvers.length > 0); // Ensures there's at least 1 issuer or approver, so funds don't get stuck

    bounties[_bountyId].issuers = _issuers;

    emit BountyIssuersUpdated(_bountyId, _sender, bounties[_bountyId].issuers);
  }

  function addApprovers(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    address [] memory _approvers)
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

  function replaceApprovers(
    address _sender,
    uint _bountyId,
    uint _issuerId,
    address [] memory _approvers)
    public
    senderIsValid(_sender)
    validateBountyArrayIndex(_bountyId)
    validateIssuerArrayIndex(_bountyId, _issuerId)
    onlyIssuer(_sender, _bountyId, _issuerId)
  {
    require(bounties[_bountyId].issuers.length > 0 || _approvers.length > 0); // Ensures there's at least 1 issuer or approver, so funds don't get stuck
    bounties[_bountyId].approvers = _approvers;

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
    } else if (bounties[_bountyId].tokenVersion == 20) {
      require(_amount > 0); // Sending 0 tokens should throw
      require(bounties[_bountyId].balance >= _amount);

      bounties[_bountyId].balance = bounties[_bountyId].balance.sub(_amount);

      require(ERC20Token(bounties[_bountyId].token).transfer(_to, _amount));
    } else if (bounties[_bountyId].tokenVersion == 721) {
      require(tokenBalances[_bountyId][_amount]);

      tokenBalances[_bountyId][_amount] = false; // Removes the 721 token from the balance of the bounty

      ERC721BasicToken(bounties[_bountyId].token).transferFrom(address(this),
                                                               _to,
                                                               _amount);
    } else {
      revert();
    }
  }


  event BountyIssued(uint _bountyId, address payable _creator, address payable [] _issuers, address [] _approvers, string _data, uint _deadline, address _token, uint _tokenVersion);
  event ContributionAdded(uint _bountyId, uint _contributionId, address payable _contributor, uint _amount);
  event ContributionRefunded(uint _bountyId, uint _contributionId);
  event ContributionsRefunded(uint _bountyId, address _issuer, uint [] _contributionIds);
  event BountyDrained(uint _bountyId, address _issuer, uint [] _amounts);
  event ActionPerformed(uint _bountyId, address _fulfiller, string _data);
  event BountyFulfilled(uint _bountyId, uint _fulfillmentId, address payable [] _fulfillers, string _data, address _submitter);
  event FulfillmentUpdated(uint _bountyId, uint _fulfillmentId, address payable [] _fulfillers, string _data);
  event FulfillmentAccepted(uint _bountyId, uint  _fulfillmentId, address _approver, uint[] _tokenAmounts);
  event BountyChanged(uint _bountyId, address _changer, address payable [] _issuers, address payable [] _approvers, string _data, uint _deadline);
  event BountyIssuersUpdated(uint _bountyId, address _changer, address payable [] _issuers);
  event BountyApproversUpdated(uint _bountyId, address _changer, address [] _approvers);
  event BountyDataChanged(uint _bountyId, address _changer, string _data);
  event BountyDeadlineChanged(uint _bountyId, address _changer, uint _deadline);
}pragma solidity 0.5.16;


library StandardBountiesWrapper {
  function issueAndContribute(
    address _standardBounties,
    uint _standardBountiesVersion,
    address payable _sender,
    address payable[] memory _issuers,
    address[] memory _approvers,
    string memory _data,
    uint _deadline,
    address _token,
    uint _depositAmount)
    internal
    returns(uint)
  {
    if (_standardBountiesVersion == 1) {
      IStandardBountiesV1 BOUNTIES = IStandardBountiesV1(_standardBounties);
      return BOUNTIES.issueAndActivateBounty(
        _sender,
        _deadline,
        _data,
        _depositAmount,
        _sender,
        true,
        _token,
        _depositAmount
      );
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      return BOUNTIES.issueAndContribute(
        _sender,
        _issuers,
        _approvers,
        _data,
        _deadline,
        _token,
        20, // ERC20
        _depositAmount
      );
    }
  }

  function contribute(
    address _standardBounties,
    uint _standardBountiesVersion,
    address payable _sender,
    uint _bountyId,
    uint _amount)
    internal
  {
    if (_standardBountiesVersion == 1) {
      IStandardBountiesV1 BOUNTIES = IStandardBountiesV1(_standardBounties);
      (,,uint fulfillmentAmount,,,) = BOUNTIES.getBounty(_bountyId);
      BOUNTIES.increasePayout(
        _bountyId,
        add(fulfillmentAmount, _amount),
        _amount
      );
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      BOUNTIES.contribute(
        _sender,
        _bountyId,
        _amount
      );
    }
  }

  function refundMyContributions(
    address _standardBounties,
    uint _standardBountiesVersion,
    address _sender,
    uint _bountyId,
    uint[] memory _contributionIds)
    internal
  {
    if (_standardBountiesVersion == 1) {
      IStandardBountiesV1 BOUNTIES = IStandardBountiesV1(_standardBounties);
      BOUNTIES.killBounty(
        _bountyId
      );
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      BOUNTIES.refundMyContributions(
        _sender,
        _bountyId,
        _contributionIds
      );
    }
  }

  function changeData(
    address _standardBounties,
    uint _standardBountiesVersion,
    address _sender,
    uint _bountyId,
    string memory _data)
    internal
  {
    if (_standardBountiesVersion == 1) {
      revert("Can't change data of V1 bounty");
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      BOUNTIES.changeData(
        _sender,
        _bountyId,
        0,
        _data
      );
    }
  }

  function changeDeadline(
    address _standardBounties,
    uint _standardBountiesVersion,
    address _sender,
    uint _bountyId,
    uint _deadline)
    internal
  {
    if (_standardBountiesVersion == 1) {
      IStandardBountiesV1 BOUNTIES = IStandardBountiesV1(_standardBounties);
      BOUNTIES.extendDeadline(
        _bountyId,
        _deadline
      );
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      BOUNTIES.changeDeadline(
        _sender,
        _bountyId,
        0,
        _deadline
      );
    }
  }

  function acceptFulfillment(
    address _standardBounties,
    uint _standardBountiesVersion,
    address _sender,
    uint _bountyId,
    uint _fulfillmentId,
    uint[] memory _tokenAmounts)
    internal
  {
    if (_standardBountiesVersion == 1) {
      IStandardBountiesV1 BOUNTIES = IStandardBountiesV1(_standardBounties);
      BOUNTIES.acceptFulfillment(
        _bountyId,
        _fulfillmentId
      );
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      BOUNTIES.acceptFulfillment(
        _sender,
        _bountyId,
        _fulfillmentId,
        0,
        _tokenAmounts
      );
    }
  }

  function performAction(
    address _standardBounties,
    uint _standardBountiesVersion,
    address _sender,
    uint _bountyId,
    string memory _data)
    internal
  {
    if (_standardBountiesVersion == 1) {
      revert("Not supported by V1");
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      BOUNTIES.performAction(
        _sender,
        _bountyId,
        _data
      );
    }
  }

  function fulfillBounty(
    address _standardBounties,
    uint _standardBountiesVersion,
    address _sender,
    uint _bountyId,
    address payable[] memory  _fulfillers,
    string memory _data)
    internal
  {
    if (_standardBountiesVersion == 1) {
      IStandardBountiesV1 BOUNTIES = IStandardBountiesV1(_standardBounties);
      BOUNTIES.fulfillBounty(
        _bountyId,
        _data
      );
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      BOUNTIES.fulfillBounty(
        _sender,
        _bountyId,
        _fulfillers,
        _data
      );
    }
  }

  function updateFulfillment(
    address _standardBounties,
    uint _standardBountiesVersion,
    address _sender,
    uint _bountyId,
    uint _fulfillmentId,
    address payable[] memory _fulfillers,
    string memory _data)
    internal
  {
    if (_standardBountiesVersion == 1) {
      IStandardBountiesV1 BOUNTIES = IStandardBountiesV1(_standardBounties);
      BOUNTIES.updateFulfillment(
        _bountyId,
        _fulfillmentId,
        _data
      );
    } else if (_standardBountiesVersion == 2) {
      StandardBounties BOUNTIES = StandardBounties(_standardBounties);
      BOUNTIES.updateFulfillment(
        _sender,
        _bountyId,
        _fulfillmentId,
        _fulfillers,
        _data
      );
    }
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
}pragma solidity ^0.5.5;

library Address {
    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity ^0.5.0;

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
}pragma solidity 0.5.16;


contract ShareToken is Ownable, ERC20NonTransferrable {
    using SafeMath for uint256;

    bool public initialized;
    string public name;
    string public symbol;
    uint8 public decimals;

    function init(
        address ownerAddr,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    )
        public
    {
        require(! initialized, "Already initialized");
        initialized = true;

        _transferOwnership(ownerAddr);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address account, uint256 amount) public onlyOwner returns (bool) {
        _mint(account, amount);
        return true;
    }

    function burn(address account, uint256 amount) public onlyOwner returns (bool) {
        _burn(account, amount);
        return true;
    }
}pragma solidity 0.5.16;


contract FeeModel is Ownable {
  using SafeMath for uint256;

  uint256 internal constant PRECISION = 10 ** 18;

  address payable public beneficiary = 0x332D87209f7c8296389C307eAe170c2440830A47;

  function getFee(uint256 _memberCount, uint256 _txAmount) public pure returns (uint256) {
    uint256 feePercentage;

    if (_memberCount <= 4) {
      feePercentage = _percent(1); // 1% for 1-4 members
    } else if (_memberCount <= 12) {
      feePercentage = _percent(3); // 3% for 5-12 members
    } else {
      feePercentage = _percent(5); // 5% for >12 members
    }

    return _txAmount.mul(feePercentage).div(PRECISION);
  }

  function setBeneficiary(address payable _addr) public onlyOwner {
    require(_addr != address(0), "0 address");
    beneficiary = _addr;
  }

  function _percent(uint256 _percentage) internal pure returns (uint256) {
    return PRECISION.mul(_percentage).div(100);
  }
}pragma solidity 0.5.16;


contract Fantastic12 {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using StandardBountiesWrapper for address;

  string  public constant VERSION = "0.1.5";
  uint256 internal constant PRECISION = 10 ** 18;

  mapping(address => bool) public isMember;
  mapping(address => mapping(uint256 => bool)) public hasUsedSalt; // Stores whether a salt has been used for a member
  IERC20 public DAI;
  ShareToken public SHARE;
  FeeModel public FEE_MODEL;
  uint256 public MAX_MEMBERS;
  uint256 public memberCount;
  uint256 public withdrawLimit;
  uint256 public withdrawnToday;
  uint256 public lastWithdrawTimestamp;
  uint256 public consensusThresholdPercentage; // at least (consensusThresholdPercentage * memberCount / PRECISION) approvers are needed to execute an action
  bool public initialized;

  address payable[] internal issuersOrFulfillers;
  address[] internal approvers;

  modifier onlyMember {
    require(isMember[msg.sender], "Not member");
    _;
  }

  modifier withConsensus(
    bytes4           _funcSelector,
    bytes     memory _funcParams,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  ) {
    require(
      _consensusReached(
        consensusThreshold(),
        _funcSelector,
        _funcParams,
        _members,
        _signatures,
        _salts
      ), "No consensus");
    _;
  }

  modifier withUnanimity(
    bytes4           _funcSelector,
    bytes     memory _funcParams,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  ) {
    require(
      _consensusReached(
        memberCount,
        _funcSelector,
        _funcParams,
        _members,
        _signatures,
        _salts
      ), "No unanimity");
    _;
  }

  event Shout(string message);
  event Declare(string message);
  event AddMember(address newMember, uint256 tribute);
  event RageQuit(address quitter);
  event PostBounty(uint256 bountyID, uint256 reward);
  event AddBountyReward(uint256 bountyID, uint256 reward);
  event RefundBountyReward(uint256 bountyID, uint256 refundAmount);
  event ChangeBountyData(uint256 bountyID);
  event ChangeBountyDeadline(uint256 bountyID);
  event AcceptBountySubmission(uint256 bountyID, uint256 fulfillmentID);
  event PerformBountyAction(uint256 bountyID);
  event FulfillBounty(uint256 bountyID);
  event UpdateBountyFulfillment(uint256 bountyID, uint256 fulfillmentID);

  function init(
    address _summoner,
    address _DAI_ADDR,
    address _SHARE_ADDR,
    address _FEE_MODEL_ADDR,
    uint256 _summonerShareAmount
  ) public {
    require(! initialized, "Initialized");
    initialized = true;
    MAX_MEMBERS = 12;
    memberCount = 1;
    DAI = IERC20(_DAI_ADDR);
    SHARE = ShareToken(_SHARE_ADDR);
    FEE_MODEL = FeeModel(_FEE_MODEL_ADDR);
    issuersOrFulfillers = new address payable[](1);
    issuersOrFulfillers[0] = address(this);
    approvers = new address[](1);
    approvers[0] = address(this);
    withdrawLimit = PRECISION.mul(1000); // default: 1000 DAI
    consensusThresholdPercentage = PRECISION.mul(75).div(100); // default: 75%

    isMember[_summoner] = true;
    SHARE.mint(_summoner, _summonerShareAmount);
  }


  function shout(string memory _message) public onlyMember {
    emit Shout(_message);
  }

  function declare(
    string memory _message,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.declare.selector,
      abi.encode(_message),
      _members,
      _signatures,
      _salts
    )
  {
    emit Declare(_message);
  }


  function addMembers(
    address[] memory _newMembers,
    uint256[] memory _tributes,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.addMembers.selector,
      abi.encode(_newMembers, _tributes),
      _members,
      _signatures,
      _salts
    )
  {
    require(_newMembers.length == _tributes.length, "_newMembers, _tributes not of the same length");
    for (uint256 i = 0; i < _newMembers.length; i = i.add(1)) {
      _addMember(_newMembers[i], _tributes[i], 0);
    }
  }

  function addMembersWithShares(
    address[] memory _newMembers,
    uint256[] memory _tributes,
    uint256[] memory _shares,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.addMembersWithShares.selector,
      abi.encode(_newMembers, _tributes, _shares),
      _members,
      _signatures,
      _salts
    )
  {
    require(_newMembers.length == _tributes.length && _tributes.length == _shares.length, "_newMembers, _tributes, _shares not of the same length");
    for (uint256 i = 0; i < _newMembers.length; i = i.add(1)) {
      _addMember(_newMembers[i], _tributes[i], _shares[i]);
    }
  }

  function _addMember(
    address _newMember,
    uint256 _tribute,
    uint256 _share
  )
    internal
  {
    require(_newMember != address(0), "Member cannot be zero address");
    require(!isMember[_newMember], "Member cannot be added twice");
    require(memberCount < MAX_MEMBERS, "Max member count reached");

    require(DAI.transferFrom(_newMember, address(this), _tribute), "Tribute transfer failed");

    isMember[_newMember] = true;
    memberCount = memberCount.add(1);

    _mintShares(_newMember, _share);

    emit AddMember(_newMember, _tribute);
  }

  function rageQuit() public {
    uint256 shareBalance = SHARE.balanceOf(msg.sender);
    uint256 withdrawAmount = DAI.balanceOf(address(this)).mul(shareBalance).div(SHARE.totalSupply());

    SHARE.burn(msg.sender, shareBalance);

    uint256 fee = FEE_MODEL.getFee(memberCount, withdrawAmount);
    DAI.safeTransfer(msg.sender, withdrawAmount.sub(fee));
    DAI.safeTransfer(FEE_MODEL.beneficiary(), fee);

    isMember[msg.sender] = false;
    memberCount = memberCount.sub(1);

    emit RageQuit(msg.sender);
  }

  function rageQuitWithTokens(address[] memory _tokens) public {
    uint256 shareBalance = SHARE.balanceOf(msg.sender);
    uint256 shareTotalSupply = SHARE.totalSupply();

    SHARE.burn(msg.sender, shareBalance);

    uint256 withdrawAmount;
    uint256 fee;
    for (uint256 i = 0; i < _tokens.length; i = i.add(1)) {
      if (_tokens[i] == address(0)) {
        withdrawAmount = address(this).balance.mul(shareBalance).div(shareTotalSupply);
        if (withdrawAmount == 0) break;
        fee = FEE_MODEL.getFee(memberCount, withdrawAmount);
        if (fee <= withdrawAmount) {
          msg.sender.transfer(withdrawAmount.sub(fee));
          FEE_MODEL.beneficiary().transfer(fee);
        } else {
          msg.sender.transfer(withdrawAmount);
        }
      } else {
        IERC20 token = IERC20(_tokens[i]);
        withdrawAmount = token.balanceOf(address(this)).mul(shareBalance).div(shareTotalSupply);
        if (withdrawAmount == 0) break;
        fee = FEE_MODEL.getFee(memberCount, withdrawAmount);
        if (fee <= withdrawAmount) {
          token.safeTransfer(msg.sender, withdrawAmount.sub(fee));
          token.safeTransfer(FEE_MODEL.beneficiary(), fee);
        } else {
          token.safeTransfer(msg.sender, withdrawAmount);
        }
      }
    }

    isMember[msg.sender] = false;
    memberCount = memberCount.sub(1);

    emit RageQuit(msg.sender);
  }


  function transferDAI(
    address[] memory _dests,
    uint256[] memory _amounts,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.transferDAI.selector,
      abi.encode(_dests, _amounts),
      _members,
      _signatures,
      _salts
    )
  {
    require(_dests.length == _amounts.length, "_dests not same length as _amounts");
    for (uint256 i = 0; i < _dests.length; i = i.add(1)) {
      _transferDAI(_dests[i], _amounts[i]);
    }
  }

  function transferTokens(
    address payable[] memory _dests,
    uint256[] memory _amounts,
    address[] memory _tokens,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.transferTokens.selector,
      abi.encode(_dests, _amounts, _tokens),
      _members,
      _signatures,
      _salts
    )
  {
    require(_dests.length == _amounts.length && _dests.length == _tokens.length, "_dests, _amounts, _tokens not of same length");
    for (uint256 i = 0; i < _dests.length; i = i.add(1)) {
      if (_tokens[i] == address(DAI)) {
        _transferDAI(_dests[i], _amounts[i]);
      } else {
        _transferToken(_tokens[i], _dests[i], _amounts[i]);
      }
    }
  }

  function mintShares(
    address[] memory _dests,
    uint256[] memory _amounts,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.mintShares.selector,
      abi.encode(_dests, _amounts),
      _members,
      _signatures,
      _salts
    )
  {
    require(_dests.length == _amounts.length, "_dests and _amounts not of same length");
    for (uint256 i = 0; i < _dests.length; i = i.add(1)) {
      _mintShares(_dests[i], _amounts[i]);
    }
  }


  function setWithdrawLimit(
    uint256 _newLimit,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withUnanimity(
      this.setWithdrawLimit.selector,
      abi.encode(_newLimit),
      _members,
      _signatures,
      _salts
    )
  {
    withdrawLimit = _newLimit;
  }

  function setConsensusThreshold(
    uint256 _newThresholdPercentage,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withUnanimity(
      this.setConsensusThreshold.selector,
      abi.encode(_newThresholdPercentage),
      _members,
      _signatures,
      _salts
    )
  {
    require(_newThresholdPercentage <= PRECISION, "Consensus threshold > 1");
    consensusThresholdPercentage = _newThresholdPercentage;
  }

  function setMaxMembers(
    uint256 _newMaxMembers,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withUnanimity(
      this.setMaxMembers.selector,
      abi.encode(_newMaxMembers),
      _members,
      _signatures,
      _salts
    )
  {
    require(_newMaxMembers >= memberCount, "_newMaxMembers < memberCount");
    MAX_MEMBERS = _newMaxMembers;
  }


  function postBounty(
    string memory _dataIPFSHash,
    uint256 _deadline,
    uint256 _reward,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.postBounty.selector,
      abi.encode(_dataIPFSHash, _deadline, _reward, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
    returns (uint256 _bountyID)
  {
    return _postBounty(_dataIPFSHash, _deadline, _reward, _standardBounties, _standardBountiesVersion);
  }

  function _postBounty(
    string memory _dataIPFSHash,
    uint256 _deadline,
    uint256 _reward,
    address _standardBounties,
    uint256 _standardBountiesVersion
  )
    internal
    returns (uint256 _bountyID)
  {
    require(_reward > 0, "Reward can't be 0");

    _approveDAI(_standardBounties, _reward);

    _bountyID = _standardBounties.issueAndContribute(
      _standardBountiesVersion,
      address(this),
      issuersOrFulfillers,
      approvers,
      _dataIPFSHash,
      _deadline,
      address(DAI),
      _reward
    );

    emit PostBounty(_bountyID, _reward);
  }

  function addBountyReward(
    uint256 _bountyID,
    uint256 _reward,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.addBountyReward.selector,
      abi.encode(_bountyID, _reward, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
  {
    _approveDAI(_standardBounties, _reward);

    _standardBounties.contribute(
      _standardBountiesVersion,
      address(this),
      _bountyID,
      _reward
    );

    emit AddBountyReward(_bountyID, _reward);
  }

  function refundBountyReward(
    uint256 _bountyID,
    uint256[] memory _contributionIDs,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.refundBountyReward.selector,
      abi.encode(_bountyID, _contributionIDs, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
  {
    uint256 beforeBalance = DAI.balanceOf(address(this));
    _standardBounties.refundMyContributions(
      _standardBountiesVersion,
      address(this),
      _bountyID,
      _contributionIDs
    );

    emit RefundBountyReward(_bountyID, DAI.balanceOf(address(this)).sub(beforeBalance));
  }

  function changeBountyData(
    uint256 _bountyID,
    string memory _dataIPFSHash,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.changeBountyData.selector,
      abi.encode(_bountyID, _dataIPFSHash, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
  {
    _standardBounties.changeData(
      _standardBountiesVersion,
      address(this),
      _bountyID,
      _dataIPFSHash
    );
    emit ChangeBountyData(_bountyID);
  }

  function changeBountyDeadline(
    uint256 _bountyID,
    uint256 _deadline,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.changeBountyDeadline.selector,
      abi.encode(_bountyID, _deadline, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
  {
    _standardBounties.changeDeadline(
      _standardBountiesVersion,
      address(this),
      _bountyID,
      _deadline
    );
    emit ChangeBountyDeadline(_bountyID);
  }

  function acceptBountySubmission(
    uint256 _bountyID,
    uint256 _fulfillmentID,
    uint256[] memory _tokenAmounts,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.acceptBountySubmission.selector,
      abi.encode(_bountyID, _fulfillmentID, _tokenAmounts, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
  {
    _standardBounties.acceptFulfillment(
      _standardBountiesVersion,
      address(this),
      _bountyID,
      _fulfillmentID,
      _tokenAmounts
    );
    emit AcceptBountySubmission(_bountyID, _fulfillmentID);
  }


  function performBountyAction(
    uint256 _bountyID,
    string memory _dataIPFSHash,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.performBountyAction.selector,
      abi.encode(_bountyID, _dataIPFSHash, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
  {
    _standardBounties.performAction(
      _standardBountiesVersion,
      address(this),
      _bountyID,
      _dataIPFSHash
    );
    emit PerformBountyAction(_bountyID);
  }

  function fulfillBounty(
    uint256 _bountyID,
    string memory _dataIPFSHash,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.fulfillBounty.selector,
      abi.encode(_bountyID, _dataIPFSHash, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
  {
    _standardBounties.fulfillBounty(
      _standardBountiesVersion,
      address(this),
      _bountyID,
      issuersOrFulfillers,
      _dataIPFSHash
    );
    emit FulfillBounty(_bountyID);
  }

  function updateBountyFulfillment(
    uint256 _bountyID,
    uint256 _fulfillmentID,
    string memory _dataIPFSHash,
    address _standardBounties,
    uint256 _standardBountiesVersion,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  )
    public
    withConsensus(
      this.updateBountyFulfillment.selector,
      abi.encode(_bountyID, _fulfillmentID, _dataIPFSHash, _standardBounties, _standardBountiesVersion),
      _members,
      _signatures,
      _salts
    )
  {
    _updateBountyFulfillment(_bountyID, _fulfillmentID, _dataIPFSHash, _standardBounties, _standardBountiesVersion);
  }

  function _updateBountyFulfillment(
    uint256 _bountyID,
    uint256 _fulfillmentID,
    string memory _dataIPFSHash,
    address _standardBounties,
    uint256 _standardBountiesVersion
  )
    internal
  {
    _standardBounties.updateFulfillment(
      _standardBountiesVersion,
      address(this),
      _bountyID,
      _fulfillmentID,
      issuersOrFulfillers,
      _dataIPFSHash
    );
    emit UpdateBountyFulfillment(_bountyID, _fulfillmentID);
  }


  function naiveMessageHash(
    bytes4       _funcSelector,
    bytes memory _funcParams,
    uint256      _salt
  ) public view returns (bytes32) {
    return keccak256(abi.encodeWithSelector(_funcSelector, _funcParams, "|END|", _salt, address(this)));
  }

  function consensusThreshold() public view returns (uint256) {
    uint256 blockingThresholdMemberCount = PRECISION.sub(consensusThresholdPercentage).mul(memberCount).div(PRECISION);
    return memberCount.sub(blockingThresholdMemberCount);
  }

  function _consensusReached(
    uint256          _threshold,
    bytes4           _funcSelector,
    bytes     memory _funcParams,
    address[] memory _members,
    bytes[]   memory _signatures,
    uint256[] memory _salts
  ) internal returns (bool) {
    if (_members.length != _signatures.length || _members.length < _threshold) {
      return false;
    }
    for (uint256 i = 0; i < _members.length; i = i.add(1)) {
      address member = _members[i];
      uint256 salt = _salts[i];
      if (!isMember[member] || hasUsedSalt[member][salt]) {
        return false;
      }

      bytes32 msgHash = ECDSA.toEthSignedMessageHash(naiveMessageHash(_funcSelector, _funcParams, salt));
      address recoveredAddress = ECDSA.recover(msgHash, _signatures[i]);
      if (recoveredAddress != member) {
        return false;
      }

      hasUsedSalt[member][salt] = true;
    }

    return true;
  }

  function _timestampToDayID(uint256 _timestamp) internal pure returns (uint256) {
    return _timestamp.sub(_timestamp % 86400).div(86400);
  }

  function _applyWithdrawLimit(uint256 _amount) internal {
    if (_timestampToDayID(now).sub(_timestampToDayID(lastWithdrawTimestamp)) >= 1) {
      withdrawnToday = 0;
    }
    uint256 newWithdrawnToday = withdrawnToday.add(_amount);
    require(newWithdrawnToday <= withdrawLimit, "Withdraw limit exceeded");
    withdrawnToday = newWithdrawnToday;
    lastWithdrawTimestamp = now;
  }

  function _transferDAI(address _to, uint256 _amount) internal {
    if (_amount == 0) return;
    _applyWithdrawLimit(_amount);
    uint256 fee = FEE_MODEL.getFee(memberCount, _amount);
    DAI.safeTransfer(_to, _amount);
    DAI.safeTransfer(FEE_MODEL.beneficiary(), fee);
  }

  function _approveDAI(address _to, uint256 _amount) internal {
    if (_amount == 0) return;
    _applyWithdrawLimit(_amount);
    uint256 fee = FEE_MODEL.getFee(memberCount, _amount);
    DAI.safeApprove(_to, 0);
    DAI.safeApprove(_to, _amount);
    DAI.safeTransfer(FEE_MODEL.beneficiary(), fee);
  }

  function _transferToken(address _token, address payable _to, uint256 _amount) internal {
    if (_amount == 0) return;
    uint256 fee = FEE_MODEL.getFee(memberCount, _amount);
    if (_token == address(0)) {
      _to.transfer(_amount);
      FEE_MODEL.beneficiary().transfer(fee);
    } else {
      IERC20 token = IERC20(_token);
      token.safeTransfer(_to, _amount);
      token.safeTransfer(FEE_MODEL.beneficiary(), fee);
    }
  }

  function _mintShares(address _to, uint256 _amount) internal {
    require(isMember[_to], "Shares minted for non-member");

    uint256 sharesValue = _amount.mul(DAI.balanceOf(address(this))).div(_amount.add(SHARE.totalSupply()));
    _applyWithdrawLimit(sharesValue);
    require(SHARE.mint(_to, _amount), "Failed to mint shares");
  }

  function() external payable {}
}pragma solidity ^0.5.0;


contract ERC20 is Context, IERC20 {
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
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;


contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}pragma solidity ^0.5.0;


contract ERC20Mintable is ERC20, MinterRole {
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}pragma solidity 0.5.16;


contract MockERC20 is ERC20Mintable {}pragma solidity 0.5.16;


contract PaidFantastic12Factory is Ownable, CloneFactory {
  address public constant DAI_ADDR = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

  address public squadTemplate;
  address public shareTokenTemplate;
  address public feeModel;

  event CreateSquad(address indexed summoner, address squad);

  constructor(address _squadTemplate, address _shareTokenTemplate, address _feeModel) public {
    squadTemplate = _squadTemplate;
    shareTokenTemplate = _shareTokenTemplate;
    feeModel = _feeModel;
  }

  function createSquad(
    address _summoner,
    string memory _shareTokenName,
    string memory _shareTokenSymbol,
    uint8 _shareTokenDecimals,
    uint256 _summonerShareAmount
  )
    public
    returns (Fantastic12 _squad)
  {
    ShareToken shareToken = ShareToken(createClone(shareTokenTemplate));
    _squad = Fantastic12(_toPayableAddr(createClone(squadTemplate)));
    shareToken.init(
      address(_squad),
      _shareTokenName,
      _shareTokenSymbol,
      _shareTokenDecimals
    );
    _squad.init(
      _summoner,
      DAI_ADDR,
      address(shareToken),
      feeModel,
      _summonerShareAmount
    );
    emit CreateSquad(_summoner, address(_squad));
  }

  function setFeeModel(address _addr) public onlyOwner {
    feeModel = _addr;
  }

  function _toPayableAddr(address _addr) internal pure returns (address payable) {
    return address(uint160(_addr));
  }
}pragma solidity 0.5.16;


contract BountiesMetaTxRelayer {


  StandardBounties public bountiesContract;
  mapping(address => uint) public replayNonce;


  constructor(address _contract) public {
    bountiesContract = StandardBounties(_contract);
  }

  function metaIssueBounty(
    bytes memory signature,
    address payable [] memory _issuers,
    address [] memory _approvers,
    string memory _data,
    uint _deadline,
    address _token,
    uint _tokenVersion,
    uint _nonce)
    public
    returns (uint)
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaIssueBounty",
                                                  _issuers,
                                                  _approvers,
                                                  _data,
                                                  _deadline,
                                                  _token,
                                                  _tokenVersion,
                                                  _nonce));
    address signer = getSigner(metaHash, signature);

    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;
    return bountiesContract.issueBounty(address(uint160(signer)),
                                         _issuers,
                                         _approvers,
                                         _data,
                                         _deadline,
                                         _token,
                                         _tokenVersion);
  }

  function metaIssueAndContribute(
    bytes memory signature,
    address payable [] memory _issuers,
    address [] memory _approvers,
    string memory _data,
    uint _deadline,
    address _token,
    uint _tokenVersion,
    uint _depositAmount,
    uint _nonce)
    public
    payable
    returns (uint)
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaIssueAndContribute",
                                                  _issuers,
                                                  _approvers,
                                                  _data,
                                                  _deadline,
                                                  _token,
                                                  _tokenVersion,
                                                  _depositAmount,
                                                  _nonce));
    address signer = getSigner(metaHash, signature);

    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    if (msg.value > 0){
      return bountiesContract.issueAndContribute.value(msg.value)(address(uint160(signer)),
                                                 _issuers,
                                                 _approvers,
                                                 _data,
                                                 _deadline,
                                                 _token,
                                                 _tokenVersion,
                                                 _depositAmount);
    } else {
      return bountiesContract.issueAndContribute(address(uint160(signer)),
                                                 _issuers,
                                                 _approvers,
                                                 _data,
                                                 _deadline,
                                                 _token,
                                                 _tokenVersion,
                                                 _depositAmount);
    }

  }

  function metaContribute(
    bytes memory _signature,
    uint _bountyId,
    uint _amount,
    uint _nonce)
    public
    payable
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaContribute",
                                                  _bountyId,
                                                  _amount,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);

    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    if (msg.value > 0){
      bountiesContract.contribute.value(msg.value)(address(uint160(signer)), _bountyId, _amount);
    } else {
      bountiesContract.contribute(address(uint160(signer)), _bountyId, _amount);
    }
  }


  function metaRefundContribution(
    bytes memory _signature,
    uint _bountyId,
    uint _contributionId,
    uint _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaRefundContribution",
                                                  _bountyId,
                                                  _contributionId,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);

    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.refundContribution(signer, _bountyId, _contributionId);
  }

  function metaRefundMyContributions(
    bytes memory _signature,
    uint _bountyId,
    uint [] memory _contributionIds,
    uint _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaRefundMyContributions",
                                                  _bountyId,
                                                  _contributionIds,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);

    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.refundMyContributions(signer, _bountyId, _contributionIds);
  }

  function metaRefundContributions(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    uint [] memory _contributionIds,
    uint _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaRefundContributions",
                                                  _bountyId,
                                                  _issuerId,
                                                  _contributionIds,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);

    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.refundContributions(signer, _bountyId, _issuerId, _contributionIds);
  }

  function metaDrainBounty(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    uint [] memory _amounts,
    uint _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaDrainBounty",
                                                  _bountyId,
                                                  _issuerId,
                                                  _amounts,
                                                  _nonce));
    address payable signer = address(uint160(getSigner(metaHash, _signature)));

    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.drainBounty(signer, _bountyId, _issuerId, _amounts);
  }

  function metaPerformAction(
    bytes memory _signature,
    uint _bountyId,
    string memory _data,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaPerformAction",
                                                  _bountyId,
                                                  _data,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.performAction(signer, _bountyId, _data);
  }

  function metaFulfillBounty(
    bytes memory _signature,
    uint _bountyId,
    address payable [] memory  _fulfillers,
    string memory _data,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaFulfillBounty",
                                                  _bountyId,
                                                  _fulfillers,
                                                  _data,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.fulfillBounty(signer, _bountyId, _fulfillers, _data);
  }

  function metaUpdateFulfillment(
    bytes memory _signature,
    uint _bountyId,
    uint _fulfillmentId,
    address payable [] memory  _fulfillers,
    string memory _data,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaUpdateFulfillment",
                                                  _bountyId,
                                                  _fulfillmentId,
                                                  _fulfillers,
                                                  _data,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.updateFulfillment(signer, _bountyId, _fulfillmentId, _fulfillers, _data);
  }

  function metaAcceptFulfillment(
    bytes memory _signature,
    uint _bountyId,
    uint _fulfillmentId,
    uint _approverId,
    uint [] memory _tokenAmounts,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaAcceptFulfillment",
                                                  _bountyId,
                                                  _fulfillmentId,
                                                  _approverId,
                                                  _tokenAmounts,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.acceptFulfillment(signer,
                       _bountyId,
                       _fulfillmentId,
                       _approverId,
                       _tokenAmounts);
  }

  function metaFulfillAndAccept(
    bytes memory _signature,
    uint _bountyId,
    address payable [] memory _fulfillers,
    string memory _data,
    uint _approverId,
    uint [] memory _tokenAmounts,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaFulfillAndAccept",
                                                  _bountyId,
                                                  _fulfillers,
                                                  _data,
                                                  _approverId,
                                                  _tokenAmounts,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.fulfillAndAccept(signer,
                      _bountyId,
                      _fulfillers,
                      _data,
                      _approverId,
                      _tokenAmounts);
  }

  function metaChangeBounty(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    address payable [] memory _issuers,
    address payable [] memory _approvers,
    string memory _data,
    uint _deadline,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaChangeBounty",
                                                  _bountyId,
                                                  _issuerId,
                                                  _issuers,
                                                  _approvers,
                                                  _data,
                                                  _deadline,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.changeBounty(signer,
                  _bountyId,
                  _issuerId,
                  _issuers,
                  _approvers,
                  _data,
                  _deadline);
  }

  function metaChangeIssuer(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    uint _issuerIdToChange,
    address payable _newIssuer,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaChangeIssuer",
                                                  _bountyId,
                                                  _issuerId,
                                                  _issuerIdToChange,
                                                  _newIssuer,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.changeIssuer(signer,
                  _bountyId,
                  _issuerId,
                  _issuerIdToChange,
                  _newIssuer);
  }

  function metaChangeApprover(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    uint _approverId,
    address payable _approver,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaChangeApprover",
                                                  _bountyId,
                                                  _issuerId,
                                                  _approverId,
                                                  _approver,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.changeApprover(signer,
                  _bountyId,
                  _issuerId,
                  _approverId,
                  _approver);
  }

  function metaChangeData(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    string memory _data,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaChangeData",
                                                  _bountyId,
                                                  _issuerId,
                                                  _data,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.changeData(signer,
                _bountyId,
                _issuerId,
                _data);
  }

  function metaChangeDeadline(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    uint  _deadline,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaChangeDeadline",
                                                  _bountyId,
                                                  _issuerId,
                                                  _deadline,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.changeDeadline(signer,
                    _bountyId,
                    _issuerId,
                    _deadline);
  }

  function metaAddIssuers(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    address payable [] memory _issuers,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaAddIssuers",
                                                  _bountyId,
                                                  _issuerId,
                                                  _issuers,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.addIssuers(signer,
                _bountyId,
                _issuerId,
                _issuers);
  }

  function metaReplaceIssuers(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    address payable [] memory _issuers,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaReplaceIssuers",
                                                  _bountyId,
                                                  _issuerId,
                                                  _issuers,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.replaceIssuers(signer,
                    _bountyId,
                    _issuerId,
                    _issuers);
  }

  function metaAddApprovers(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    address payable [] memory _approvers,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaAddApprovers",
                                                  _bountyId,
                                                  _issuerId,
                                                  _approvers,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.addIssuers(signer,
                _bountyId,
                _issuerId,
                _approvers);
  }

  function metaReplaceApprovers(
    bytes memory _signature,
    uint _bountyId,
    uint _issuerId,
    address payable [] memory _approvers,
    uint256 _nonce)
    public
    {
    bytes32 metaHash = keccak256(abi.encode(address(this),
                                                  "metaReplaceApprovers",
                                                  _bountyId,
                                                  _issuerId,
                                                  _approvers,
                                                  _nonce));
    address signer = getSigner(metaHash, _signature);
    require(signer != address(0));
    require(_nonce == replayNonce[signer]);

    replayNonce[signer]++;

    bountiesContract.replaceIssuers(signer,
                    _bountyId,
                    _issuerId,
                    _approvers);
  }

  function getSigner(
    bytes32 _hash,
    bytes memory _signature)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;
    if (_signature.length != 65) {
      return address(0);
    }
    assembly {
      r := mload(add(_signature, 32))
      s := mload(add(_signature, 64))
      v := byte(0, mload(add(_signature, 96)))
    }
    if (v < 27) {
      v += 27;
    }
    if (v != 27 && v != 28) {
      return address(0);
    } else {
      return ecrecover(keccak256(
        abi.encode("\x19Ethereum Signed Message:\n32", _hash)
      ), v, r, s);
    }
  }
}