

pragma solidity ^0.4.24;

contract Ownable {


  address public owner_;

  event TransferApproved(address indexed _previousOwner, address indexed _newOwner);
  event TransferRequested(address indexed _currentOwner, address indexed _requestedOwner);
  event RequestRevoked(address indexed _currentOwner, address indexed _requestOwner);

  mapping(bytes32 => bool) public requesters_; // keccak256 hashes of requester addresses

  modifier onlyOwner() {

    require(msg.sender == owner_);
    _;
  }

  modifier hasNotRequested() {

    require(!requesters_[keccak256(abi.encodePacked(msg.sender))],
      "Ownership request already active.");
    _;
  }

  modifier hasRequested(address _newOwner) {

    require(requesters_[keccak256(abi.encodePacked(_newOwner))], 
      "Owner request has not been sent.");
    _;
  }

  function requestOwnership() public hasNotRequested {

    bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
    requesters_[hashedAddress] = true;
    emit TransferRequested(owner_, msg.sender);
  }

  function revokeOwnershipRequest() public hasRequested(msg.sender) {

    bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
    requesters_[hashedAddress] = false;
    emit RequestRevoked(owner_, msg.sender);
  }

  function approveOwnershipTransfer(address _newOwner) public onlyOwner hasRequested(_newOwner) {

    owner_ = _newOwner;
    bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
    requesters_[hashedAddress] = false;
  }

}


pragma solidity ^0.4.24;

library SafeMath32 {


  function mul(uint32 a, uint32 b) internal pure returns (uint32) {

    if (a == 0) {
      return 0;
    }

    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint32 a, uint32 b) internal pure returns (uint32) {

    uint32 c = a / b;
    return c;
  }

  function sub(uint32 a, uint32 b) internal pure returns (uint32) {

    assert(b <= a);
    return a - b;
  }

  function add(uint32 a, uint32 b) internal pure returns (uint32) {

    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}


pragma solidity ^0.4.24;

contract AraProxy {


  bytes32 private constant registryPosition_ = keccak256("io.ara.proxy.registry");
  bytes32 private constant implementationPosition_ = keccak256("io.ara.proxy.implementation");

  modifier restricted() {

    bytes32 registryPosition = registryPosition_;
    address registryAddress;
    assembly {
      registryAddress := sload(registryPosition)
    }
    require(
      msg.sender == registryAddress,
      "Only the AraRegistry can upgrade this proxy."
    );
    _;
  }

  constructor(address _registryAddress, address _implementationAddress) public {
    bytes32 registryPosition = registryPosition_;
    bytes32 implementationPosition = implementationPosition_;
    assembly {
      sstore(registryPosition, _registryAddress)
      sstore(implementationPosition, _implementationAddress)
    }
  }

  function setImplementation(address _newImplementation) public restricted {

    require(_newImplementation != address(0));
    bytes32 implementationPosition = implementationPosition_;
    assembly {
      sstore(implementationPosition, _newImplementation)
    }
  }

  function () payable public {
    bytes32 implementationPosition = implementationPosition_;
    address _impl;
    assembly {
      _impl := sload(implementationPosition)
    }

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}


pragma solidity ^0.4.24;


contract Registry {

  address public owner_;
  mapping (bytes32 => address) private proxies_; // contentId (unhashed) => proxy
  mapping (bytes32 => address) private proxyOwners_; // contentId (unhashed) => owner
  mapping (string => address) private versions_; // version => implementation
  mapping (address => string) public proxyImpls_; // proxy => version
  string public latestVersion_;

  event ProxyDeployed(address indexed _owner, bytes32 indexed _contentId, address _address);
  event ProxyUpgraded(bytes32 indexed _contentId, string indexed _version);
  event StandardAdded(string indexed _version, address _address);

  function init(bytes _data) public {

    require(owner_ == address(0), 'Registry has already been initialized.');

    uint256 btsptr;
    address ownerAddr;
    assembly {
      btsptr := add(_data, 32)
      ownerAddr := mload(btsptr)
    }
    owner_ = ownerAddr;
  }

  modifier restricted() {

    require (
      msg.sender == owner_,
      "Sender not authorized."
    );
    _;
  }

  modifier onlyProxyOwner(bytes32 _contentId) {

    require(
      proxyOwners_[_contentId] == msg.sender,
      "Sender not authorized."
    );
    _;
  }

  function getProxyAddress(bytes32 _contentId) public view returns (address) {

    return proxies_[_contentId];
  }

  function getProxyOwner(bytes32 _contentId) public view returns (address) {

    return proxyOwners_[_contentId];
  }

  function getImplementation(string _version) public view returns (address) {

    return versions_[_version];
  }

  function getProxyVersion(bytes32 _contentId) public view returns (string) {

    return proxyImpls_[getProxyAddress(_contentId)];
  }
  
  function createAFS(bytes32 _contentId, string _version, bytes _data) public {

    require(proxies_[_contentId] == address(0), "Proxy already exists for this content.");
    require(versions_[_version] != address(0), "Version does not exist.");
    AraProxy proxy = new AraProxy(address(this), versions_[_version]);
    proxies_[_contentId] = proxy;
    proxyOwners_[_contentId] = msg.sender;
    upgradeProxyAndCall(_contentId, _version, _data);
    emit ProxyDeployed(msg.sender, _contentId, address(proxy));
  }

  function upgradeProxy(bytes32 _contentId, string _version) public onlyProxyOwner(_contentId) {

    require(versions_[_version] != address(0), "Version does not exist.");
    AraProxy proxy = AraProxy(proxies_[_contentId]);
    proxy.setImplementation(versions_[_version]);
    proxyImpls_[proxies_[_contentId]] = _version;
    emit ProxyUpgraded(_contentId, _version);
  }

  function upgradeProxyAndCall(bytes32 _contentId, string _version, bytes _data) public onlyProxyOwner(_contentId) {

    require(versions_[_version] != address(0), "Version does not exist.");
    require(keccak256(abi.encodePacked(proxyImpls_[proxy])) != keccak256(abi.encodePacked(_version)), "Proxy is already on this version.");
    AraProxy proxy = AraProxy(proxies_[_contentId]);
    proxy.setImplementation(versions_[_version]);
    proxyImpls_[proxy] = _version;
    require(address(proxy).call(abi.encodeWithSignature("init(bytes)", _data)), "Init failed.");
    emit ProxyUpgraded(_contentId, _version);
  }

  function addStandardVersion(string _version, address _address) public restricted {

    require(versions_[_version] == address(0), "Version already exists.");
    versions_[_version] = _address;
    latestVersion_ = _version;
    emit StandardAdded(_version, _address);
  }
}


pragma solidity ^0.4.24;



contract Library {

  using SafeMath32 for uint32;

  address public owner_;
  mapping (bytes32 => Lib) private libraries_; // hashed methodless owner did => library
  Registry registry_;

  struct Lib {
    uint32 size;
    mapping (uint32 => bytes32) content; // index => contentId (unhashed)
  }

  event AddedToLib(bytes32 indexed _identity, bytes32 indexed _contentId);

  function init(bytes _data) public {

    require(owner_ == address(0), 'Library has already been initialized.');

    uint256 btsptr;
    address ownerAddr;
    address registryAddr;
    assembly {
      btsptr := add(_data, 32)
      ownerAddr := mload(btsptr)
      btsptr := add(_data, 64)
      registryAddr := mload(btsptr)
    }
    owner_ = ownerAddr;
    registry_ = Registry(registryAddr);
  }

  modifier restricted() {

    require (msg.sender == owner_, "Sender not authorized.");
     _;
  }

  modifier fromProxy(bytes32 _contentId) {

    require (msg.sender == registry_.getProxyAddress(_contentId), "Proxy not authorized.");
     _;
  }

  function getLibrarySize(bytes32 _identity) public view returns (uint32 size) {

    return libraries_[_identity].size;
  }

  function getLibraryItem(bytes32 _identity, uint32 _index) public view returns (bytes32 contentId) {

    require (_index < libraries_[_identity].size, "Index does not exist.");
    return libraries_[_identity].content[_index];
  }

  function addLibraryItem(bytes32 _identity, bytes32 _contentId) public fromProxy(_contentId) {

    uint32 libSize = libraries_[_identity].size;
    assert (libraries_[_identity].content[libSize] == bytes32(0));
    libraries_[_identity].content[libSize] = _contentId;
    libraries_[_identity].size++;
    emit AddedToLib(_identity, _contentId);
  }
}


pragma solidity ^0.4.24;


contract ERC20 {

  function totalSupply() public view returns (uint256);


  function balanceOf(address _who) public view returns (uint256);


  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transfer(address _to, uint256 _value) public returns (bool);


  function approve(address _spender, uint256 _value)
    public returns (bool);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity ^0.4.24;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}


pragma solidity ^0.4.24;




contract StandardToken is ERC20 {

  using SafeMath for uint256;

  mapping (address => uint256) private balances_;

  mapping (address => mapping (address => uint256)) private allowed_;

  uint256 private totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances_[_owner];
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed_[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances_[msg.sender]);
    require(_to != address(0));

    balances_[msg.sender] = balances_[msg.sender].sub(_value);
    balances_[_to] = balances_[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed_[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_value <= balances_[_from]);
    require(_value <= allowed_[_from][msg.sender]);
    require(_to != address(0));

    balances_[_from] = balances_[_from].sub(_value);
    balances_[_to] = balances_[_to].add(_value);
    allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    allowed_[msg.sender][_spender] = (
      allowed_[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {

    uint256 oldValue = allowed_[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed_[msg.sender][_spender] = 0;
    } else {
      allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  function _mint(address _account, uint256 _amount) internal {

    require(_account != 0);
    totalSupply_ = totalSupply_.add(_amount);
    balances_[_account] = balances_[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

  function _burn(address _account, uint256 _amount) internal {

    require(_account != 0);
    require(_amount <= balances_[_account]);

    totalSupply_ = totalSupply_.sub(_amount);
    balances_[_account] = balances_[_account].sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

  function _burnFrom(address _account, uint256 _amount) internal {

    require(_amount <= allowed_[_account][msg.sender]);

    allowed_[_account][msg.sender] = allowed_[_account][msg.sender].sub(
      _amount);
    _burn(_account, _amount);
  }
}


pragma solidity ^0.4.24;


contract AraToken is StandardToken {


  bool    private initialized;
  string  public constant name = "Ara Token";
  string  public constant symbol = "ARA";
  uint256 public constant decimals = 18;
  string  public version = "1.0";


  mapping (address => uint256) private deposits_;

  event Deposit(address indexed from, uint256 value, uint256 total);
  event Withdraw(address indexed to, uint256 value, uint256 total);

  function init(bytes _data) public {

    require(!initialized, 'Ara Token has already been initialized.');
    initialized = true;
    
    uint256 btsptr;
    address ownerAddr;
    assembly {
      btsptr := add(_data, 32)
      ownerAddr := mload(btsptr)
    }
    _mint(ownerAddr, formatDecimals(1000000000)); // 1,000,000,000
  }

  function formatDecimals(uint256 _value) internal pure returns (uint256) {

    return _value * 10 ** decimals;
  }

  function amountDeposited(address _owner) public view returns (uint256) {

    return deposits_[_owner];
  }

  function deposit(uint256 _value) external returns (bool) {

    require(_value <= balanceOf(msg.sender));

    deposits_[msg.sender] = deposits_[msg.sender].add(_value);
    emit Deposit(msg.sender, _value, deposits_[msg.sender]);
    return true;
  }

  function withdraw(uint256 _value) external returns (bool) {

    require(_value <= deposits_[msg.sender]);

    deposits_[msg.sender] = deposits_[msg.sender].sub(_value);
    emit Withdraw(msg.sender, _value, deposits_[msg.sender]);
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(balanceOf(msg.sender) - _value >= deposits_[msg.sender]);
    return super.transfer(_to, _value);
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    require(balanceOf(msg.sender) - _value >= deposits_[msg.sender]);
    return super.approve(_spender, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(balanceOf(_from) - _value >= deposits_[_from]);
    return super.transferFrom(_from, _to, _value);
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    require(balanceOf(msg.sender) - (_addedValue + allowance(msg.sender, _spender)) >= deposits_[msg.sender]);
    return super.increaseApproval(_spender, _addedValue);
  }
}



pragma solidity ^0.4.19;


library BytesLib {

    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes) {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
                    add(
                        fslot,
                        add(
                            mul(
                                div(
                                    mload(add(_postBytes, 0x20)),
                                    exp(0x100, sub(32, mlength))
                                ),
                                exp(0x100, sub(32, newlength))
                            ),
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                
                for { 
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(bytes _bytes, uint _start, uint _length) internal  pure returns (bytes) {

        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint(bytes _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }
}


pragma solidity ^0.4.24;







contract AFS is Ownable {

  using SafeMath for uint256;
  using BytesLib for bytes;

  string   public version_ = "1";

  AraToken public token_;
  Library  public lib_;

  bytes32  public did_;
  bool     public listed_;
  uint256  public price_;

  uint256  public depositRequirement_;

  mapping(bytes32 => Job)     public jobs_; // jobId => job { budget, sender }
  mapping(bytes32 => uint256) public rewards_;    // farmer => rewards
  mapping(bytes32 => bool)    public purchasers_; // keccak256 hashes of buyer addresses
  mapping(uint8 => mapping (uint256 => bytes))   public metadata_;

  struct Job {
    address sender;
    uint256 budget;
  }

  event Commit(bytes32 _did);
  event Unlisted(bytes32 _did);
  event PriceSet(uint256 _price);
  event BudgetSubmitted(address indexed _sender, bytes32 indexed _jobId, uint256 _budget);
  event RewardsAllocated(address indexed _farmer, bytes32 indexed _jobId, uint256 _allocated, uint256 _remaining);
  event InsufficientDeposit(address indexed _farmer);
  event Purchased(bytes32 indexed _purchaser, uint256 _price);
  event Redeemed(address indexed _sender, uint256 _amount);

  uint8 constant mtBufferSize_ = 40;
  uint8 constant msBufferSize_ = 64;

  modifier onlyBy(address _account)
  {

    require(
      msg.sender == _account,
      "Sender not authorized."
    );
    _;
  }

  modifier purchaseRequired()
  {

    require(
      purchasers_[keccak256(abi.encodePacked(msg.sender))],
      "Content was never purchased."
    );
    _;
  }

  modifier budgetSubmitted(bytes32 _jobId)
  {

    require(
      jobs_[_jobId].sender == msg.sender && jobs_[_jobId].budget > 0,
      "Job is invalid."
    );
    _;
  }

  function init(bytes _data) public {

    require(owner_ == address(0), 'This AFS standard has already been initialized.');
  
    uint256 btsptr;
    address ownerAddr;
    address tokenAddr;
    address libAddr;
    bytes32 did;
    assembly {
      btsptr := add(_data, 32)
      ownerAddr := mload(btsptr)
      btsptr := add(_data, 64)
      tokenAddr := mload(btsptr)
      btsptr := add(_data, 96)
      libAddr := mload(btsptr)
      btsptr := add(_data, 128)
      did := mload(btsptr)
    }
    owner_    = ownerAddr;
    token_    = AraToken(tokenAddr);
    lib_      = Library(libAddr);
    did_      = did;
    listed_   = true;
    price_    = 0;
    depositRequirement_  = 100 * 10 ** token_.decimals();
  }

  function setPrice(uint256 _price) external onlyBy(owner_) {

    price_ = _price;
    emit PriceSet(price_);
  }

  function submitBudget(bytes32 _jobId, uint256 _budget) public purchaseRequired {

    uint256 allowance = token_.allowance(msg.sender, address(this));
    require(_jobId != bytes32(0) && _budget > 0 && allowance >= _budget
      && (jobs_[_jobId].sender == address(0) || jobs_[_jobId].sender == msg.sender), "Job submission invalid.");

    if (token_.transferFrom(msg.sender, address(this), _budget)) {
      jobs_[_jobId].budget = jobs_[_jobId].budget.add(_budget);
      jobs_[_jobId].sender = msg.sender;
      assert(jobs_[_jobId].budget <= token_.balanceOf(address(this)));
      emit BudgetSubmitted(msg.sender, _jobId, _budget);
    }
  }

  function allocateRewards(bytes32 _jobId, address[] _farmers, uint256[] _rewards) public budgetSubmitted(_jobId) {

    require(_farmers.length > 0, "Must allocate to at least one farmer.");
    require(_farmers.length == _rewards.length, "Unequal number of farmers and rewards.");
    uint256 totalRewards;
    for (uint256 i = 0; i < _rewards.length; i++) {
      address farmer = _farmers[i];
      require(farmer != msg.sender, "Cannot allocate rewards to job creator.");
      require(purchasers_[keccak256(abi.encodePacked(farmer))] || token_.amountDeposited(farmer) >= depositRequirement_, "Farmer must be a purchaser of this AFS or have sufficient token deposit.");
      totalRewards = totalRewards.add(_rewards[i]);
    }
    require(totalRewards <= jobs_[_jobId].budget, "Insufficient budget.");
    for (uint256 j = 0; j < _farmers.length; j++) {
      assert(jobs_[_jobId].budget >= _rewards[j]);
      bytes32 hashedFarmer = keccak256(abi.encodePacked(_farmers[j]));
      rewards_[hashedFarmer] = rewards_[hashedFarmer].add(_rewards[j]);
      jobs_[_jobId].budget = jobs_[_jobId].budget.sub(_rewards[j]);
      emit RewardsAllocated(_farmers[j], _jobId, _rewards[j], jobs_[_jobId].budget);
    }
  }

  function redeemBalance() public {

    if (msg.sender == owner_ || token_.amountDeposited(msg.sender) >= depositRequirement_ || purchasers_[keccak256(abi.encodePacked(msg.sender))]) {
      bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
      require(rewards_[hashedAddress] > 0, "No balance to redeem.");
      if (token_.transfer(msg.sender, rewards_[hashedAddress])) {
        emit Redeemed(msg.sender, rewards_[hashedAddress]);
        rewards_[hashedAddress] = 0;
      }
    } else {
      emit InsufficientDeposit(msg.sender);
    }
  }

  function getRewardsBalance(address _farmer) public view returns (uint256) {

    return rewards_[keccak256(abi.encodePacked(_farmer))];
  }

  function getBudget(bytes32 _jobId) public view returns (uint256) {

    return jobs_[_jobId].budget;
  }

  function purchase(bytes32 _purchaser, bytes32 _jobId, uint256 _budget) external {

    require(listed_, "Content is not listed for purchase.");
    uint256 allowance = token_.allowance(msg.sender, address(this));
    bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
    require (!purchasers_[hashedAddress] && allowance >= price_.add(_budget), "Unable to purchase.");

    if (token_.transferFrom(msg.sender, owner_, price_)) {
      purchasers_[hashedAddress] = true;
      lib_.addLibraryItem(_purchaser, did_);
      emit Purchased(_purchaser, price_);

      if (_jobId != bytes32(0) && _budget > 0) {
        submitBudget(_jobId, _budget);
      }
    }
  }

  function append(uint256[] _mtOffsets, uint256[] _msOffsets, bytes _mtBuffer, 
    bytes _msBuffer) external onlyBy(owner_) {

    
    require(listed_, "AFS is unlisted.");
    
    uint256 maxOffsetLength = _mtOffsets.length > _msOffsets.length 
      ? _mtOffsets.length 
      : _msOffsets.length;

    for (uint i = 0; i < maxOffsetLength; i++) {
      if (i <= _mtOffsets.length - 1) {
        metadata_[0][_mtOffsets[i]] = _mtBuffer.slice(i * mtBufferSize_, mtBufferSize_);
      }

      if (i <= _msOffsets.length - 1) {
        metadata_[1][_msOffsets[i]] = _msBuffer.slice(i * msBufferSize_, msBufferSize_);
      }
    }

    emit Commit(did_);
  }

  function write(uint256[] _mtOffsets, uint256[] _msOffsets, bytes _mtBuffer, 
    bytes _msBuffer) public onlyBy(owner_) {


    require(listed_, "AFS is unlisted.");

    uint256 maxOffsetLength = _mtOffsets.length > _msOffsets.length 
      ? _mtOffsets.length 
      : _msOffsets.length;

    metadata_[0][0] = _mtBuffer.slice(0, 32);
    metadata_[1][0] = _msBuffer.slice(0, 32);

    for (uint i = 1; i < maxOffsetLength; i++) {
      if (i <= _mtOffsets.length - 1) {
        metadata_[0][_mtOffsets[i]] = _mtBuffer.slice(_mtOffsets[i], mtBufferSize_);
      }
      
      if (i <= _msOffsets.length - 1) {
        metadata_[1][_msOffsets[i]] = _msBuffer.slice(_msOffsets[i], msBufferSize_);
      }
    }

    emit Commit(did_);
  }

  function read(uint8 _file, uint256 _offset) public view returns (bytes buffer) {

    if (!listed_) {
      return ""; // empty bytes
    }
    return metadata_[_file][_offset];
  }

  function hasBuffer(uint8 _file, uint256 _offset, bytes _buffer) public view returns (bool exists) {

    return metadata_[_file][_offset].equal(_buffer);
  }

  function unlist() public onlyBy(owner_) returns (bool success) {

    listed_ = false;
    emit Unlisted(did_);
    return true;
  }
}