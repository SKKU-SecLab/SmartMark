
pragma solidity ^0.4.23;

interface RegistryInterface {

  function getLatestVersion(address stor_addr, bytes32 exec_id, address provider, bytes32 app_name)
      external view returns (bytes32 latest_name);

  function getVersionImplementation(address stor_addr, bytes32 exec_id, address provider, bytes32 app_name, bytes32 version_name)
      external view returns (address index, bytes4[] selectors, address[] implementations);

}

contract AbstractStorage {


  bytes32 private exec_id;
  address private sender;

  uint private nonce;


  event ApplicationInitialized(bytes32 indexed execution_id, address indexed index, address script_exec);
  event ApplicationExecution(bytes32 indexed execution_id, address indexed script_target);
  event DeliveredPayment(bytes32 indexed execution_id, address indexed destination, uint amount);



  bytes32 internal constant EXEC_PERMISSIONS = keccak256('script_exec_permissions');
  bytes32 internal constant APP_IDX_ADDR = keccak256('index');


  bytes4 internal constant EMITS = bytes4(keccak256('Emit((bytes32[],bytes)[])'));
  bytes4 internal constant STORES = bytes4(keccak256('Store(bytes32[])'));
  bytes4 internal constant PAYS = bytes4(keccak256('Pay(bytes32[])'));
  bytes4 internal constant THROWS = bytes4(keccak256('Error(string)'));


  bytes4 internal constant REG_APP
      = bytes4(keccak256('registerApp(bytes32,address,bytes4[],address[])'));
  bytes4 internal constant REG_APP_VER
      = bytes4(keccak256('registerAppVersion(bytes32,bytes32,address,bytes4[],address[])'));
  bytes4 internal constant UPDATE_EXEC_SEL
      = bytes4(keccak256('updateExec(address)'));
  bytes4 internal constant UPDATE_INST_SEL
      = bytes4(keccak256('updateInstance(bytes32,bytes32,bytes32)'));

  function createRegistry(address _registry_idx, address _implementation) external returns (bytes32) {

    bytes32 new_exec_id = keccak256(++nonce);
    put(new_exec_id, keccak256(msg.sender, EXEC_PERMISSIONS), bytes32(1));
    put(new_exec_id, APP_IDX_ADDR, bytes32(_registry_idx));
    put(new_exec_id, keccak256(REG_APP, 'implementation'), bytes32(_implementation));
    put(new_exec_id, keccak256(REG_APP_VER, 'implementation'), bytes32(_implementation));
    put(new_exec_id, keccak256(UPDATE_INST_SEL, 'implementation'), bytes32(_implementation));
    put(new_exec_id, keccak256(UPDATE_EXEC_SEL, 'implementation'), bytes32(_implementation));
    emit ApplicationInitialized(new_exec_id, _registry_idx, msg.sender);
    return new_exec_id;
  }


  function createInstance(address _sender, bytes32 _app_name, address _provider, bytes32 _registry_id, bytes _calldata) external payable returns (bytes32 new_exec_id, bytes32 version) {

    require(_sender != 0 && _app_name != 0 && _provider != 0 && _registry_id != 0 && _calldata.length >= 4, 'invalid input');

    new_exec_id = keccak256(++nonce);

    assert(getIndex(new_exec_id) == address(0));

    address index;
    (index, version) = setImplementation(new_exec_id, _app_name, _provider, _registry_id);

    setContext(new_exec_id, _sender);

    require(address(index).delegatecall(_calldata) == false, 'Unsafe execution');
    executeAppReturn(new_exec_id);

    emit ApplicationInitialized(new_exec_id, index, msg.sender);

    assert(new_exec_id != bytes32(0));

    if (address(this).balance > 0)
      address(msg.sender).transfer(address(this).balance);
  }

  function exec(address _sender, bytes32 _exec_id, bytes _calldata) external payable returns (uint n_emitted, uint n_paid, uint n_stored) {

    require(_calldata.length >= 4 && _sender != address(0) && _exec_id != bytes32(0));

    address target = getTarget(_exec_id, getSelector(_calldata));
    require(target != address(0), 'Uninitialized application');

    setContext(_exec_id, _sender);

    require(address(target).delegatecall(_calldata) == false, 'Unsafe execution');
    (n_emitted, n_paid, n_stored) = executeAppReturn(_exec_id);

    if (n_emitted == 0 && n_paid == 0 && n_stored == 0)
      revert('No state change occured');

    emit ApplicationExecution(_exec_id, target);

    if (address(this).balance > 0)
      address(msg.sender).transfer(address(this).balance);
  }


  function executeAppReturn(bytes32 _exec_id) internal returns (uint n_emitted, uint n_paid, uint n_stored) {

    uint _ptr;      // Will be a pointer to the data returned by the application call
    uint ptr_bound; // Will be the maximum value of the pointer possible (end of the memory stored in the pointer)
    (ptr_bound, _ptr) = getReturnedData();
    if (getAction(_ptr) == THROWS) {
      doThrow(_ptr);
      assert(false);
    }

    require(ptr_bound >= _ptr + 64, 'Malformed returndata - invalid size');
    _ptr += 64;

    bytes4 action;
    while (_ptr <= ptr_bound && (action = getAction(_ptr)) != 0x0) {
      if (action == EMITS) {
        require(n_emitted == 0, 'Duplicate action: EMITS');
        (_ptr, n_emitted) = doEmit(_ptr, ptr_bound);
        require(n_emitted != 0, 'Unfulfilled action: EMITS');
      } else if (action == STORES) {
        require(n_stored == 0, 'Duplicate action: STORES');
        (_ptr, n_stored) = doStore(_ptr, ptr_bound, _exec_id);
        require(n_stored != 0, 'Unfulfilled action: STORES');
      } else if (action == PAYS) {
        require(n_paid == 0, 'Duplicate action: PAYS');
        (_ptr, n_paid) = doPay(_exec_id, _ptr, ptr_bound);
        require(n_paid != 0, 'Unfulfilled action: PAYS');
      } else {
        revert('Malformed returndata - unknown action');
      }
    }
    assert(n_emitted != 0 || n_paid != 0 || n_stored != 0);
  }


  function setImplementation(bytes32 _new_exec_id, bytes32 _app_name, address _provider, bytes32 _registry_id) internal returns (address index, bytes32 version) {

    index = getIndex(_registry_id);
    require(index != address(0) && index != address(this), 'Registry application not found');
    version = RegistryInterface(index).getLatestVersion(
      address(this), _registry_id, _provider, _app_name
    );
    require(version != bytes32(0), 'Invalid version name');

    bytes4[] memory selectors;
    address[] memory implementations;
    (index, selectors, implementations) = RegistryInterface(index).getVersionImplementation(
      address(this), _registry_id, _provider, _app_name, version
    );
    require(index != address(0), 'Invalid index address');
    require(selectors.length == implementations.length && selectors.length != 0, 'Invalid implementation length');

    bytes32 seed = APP_IDX_ADDR;
    put(_new_exec_id, seed, bytes32(index));
    for (uint i = 0; i < selectors.length; i++) {
      require(selectors[i] != 0 && implementations[i] != 0, 'invalid input - expected nonzero implementation');
      seed = keccak256(selectors[i], 'implementation');
      put(_new_exec_id, seed, bytes32(implementations[i]));
    }

    return (index, version);
  }

  function getIndex(bytes32 _exec_id) public view returns (address) {

    bytes32 seed = APP_IDX_ADDR;
    function (bytes32, bytes32) view returns (address) getter;
    assembly { getter := readMap }
    return getter(_exec_id, seed);
  }

  function getTarget(bytes32 _exec_id, bytes4 _selector) public view returns (address) {

    bytes32 seed = keccak256(_selector, 'implementation');
    function (bytes32, bytes32) view returns (address) getter;
    assembly { getter := readMap }
    return getter(_exec_id, seed);
  }

  struct Map { mapping(bytes32 => bytes32) inner; }

  function readMap(Map storage _map, bytes32 _seed) internal view returns (bytes32) {

    return _map.inner[_seed];
  }

  function put(bytes32 _exec_id, bytes32 _seed, bytes32 _val) internal {

    function (bytes32, bytes32, bytes32) puts;
    assembly { puts := putMap }
    puts(_exec_id, _seed, _val);
  }

  function putMap(Map storage _map, bytes32 _seed, bytes32 _val) internal {

    _map.inner[_seed] = _val;
  }


  function getSelector(bytes memory _calldata) internal pure returns (bytes4 sel) {

    assembly {
      sel := and(
        mload(add(0x20, _calldata)),
        0xffffffff00000000000000000000000000000000000000000000000000000000
      )
    }
  }

  function getReturnedData() internal pure returns (uint ptr_bounds, uint _returndata_ptr) {

    assembly {
      if lt(returndatasize, 0x60) {
        mstore(0, 0x20)
        mstore(0x20, 24)
        mstore(0x40, 'Insufficient return size')
        revert(0, 0x60)
      }
      _returndata_ptr := msize
      returndatacopy(_returndata_ptr, 0, returndatasize)
      ptr_bounds := add(_returndata_ptr, returndatasize)
      mstore(0x40, add(0x20, ptr_bounds))
    }
  }

  function getLength(uint _ptr) internal pure returns (uint length) {

    assembly { length := mload(_ptr) }
  }

  function doThrow(uint _ptr) internal pure {

    assert(getAction(_ptr) == THROWS);
    assembly { revert(_ptr, returndatasize) }
  }

  function doPay(bytes32 _exec_id, uint _ptr, uint _ptr_bound) internal returns (uint ptr, uint n_paid) {

    require(msg.value > 0);
    assert(getAction(_ptr) == PAYS);
    _ptr += 4;
    uint num_destinations = getLength(_ptr);
    _ptr += 32;
    address pay_to;
    uint amt;
    while (_ptr <= _ptr_bound && n_paid < num_destinations) {
      assembly {
        amt := mload(_ptr)
        pay_to := mload(add(0x20, _ptr))
      }
      if (pay_to == address(0) || pay_to == address(this))
        revert('PAYS: invalid destination');

      address(pay_to).transfer(amt);
      n_paid++;
      _ptr += 64;
      emit DeliveredPayment(_exec_id, pay_to, amt);
    }
    ptr = _ptr;
    assert(n_paid == num_destinations);
  }

  function doStore(uint _ptr, uint _ptr_bound, bytes32 _exec_id) internal returns (uint ptr, uint n_stored) {

    assert(getAction(_ptr) == STORES && _exec_id != bytes32(0));
    _ptr += 4;
    uint num_locations = getLength(_ptr);
    _ptr += 32;
    bytes32 location;
    bytes32 value;
    while (_ptr <= _ptr_bound && n_stored < num_locations) {
      assembly {
        location := mload(_ptr)
        value := mload(add(0x20, _ptr))
      }
      store(_exec_id, location, value);
      n_stored++;
      _ptr += 64;
    }
    ptr = _ptr;
    require(n_stored == num_locations);
  }

  function doEmit(uint _ptr, uint _ptr_bound) internal returns (uint ptr, uint n_emitted) {

    assert(getAction(_ptr) == EMITS);
    _ptr += 4;
    uint num_events = getLength(_ptr);
    _ptr += 32;
    bytes32[] memory topics;
    bytes memory data;
    while (_ptr <= _ptr_bound && n_emitted < num_events) {
      assembly {
        topics := _ptr
        data := add(add(_ptr, 0x20), mul(0x20, mload(topics)))
      }
      uint log_size = 32 + (32 * (1 + topics.length)) + data.length;
      assembly {
        switch mload(topics)                // topics.length
          case 0 {
            log0(
              add(0x20, data),              // data(ptr)
              mload(data)                   // data.length
            )
          }
          case 1 {
            log1(
              add(0x20, data),              // data(ptr)
              mload(data),                  // data.length
              mload(add(0x20, topics))      // topics[0]
            )
          }
          case 2 {
            log2(
              add(0x20, data),              // data(ptr)
              mload(data),                  // data.length
              mload(add(0x20, topics)),     // topics[0]
              mload(add(0x40, topics))      // topics[1]
            )
          }
          case 3 {
            log3(
              add(0x20, data),              // data(ptr)
              mload(data),                  // data.length
              mload(add(0x20, topics)),     // topics[0]
              mload(add(0x40, topics)),     // topics[1]
              mload(add(0x60, topics))      // topics[2]
            )
          }
          case 4 {
            log4(
              add(0x20, data),              // data(ptr)
              mload(data),                  // data.length
              mload(add(0x20, topics)),     // topics[0]
              mload(add(0x40, topics)),     // topics[1]
              mload(add(0x60, topics)),     // topics[2]
              mload(add(0x80, topics))      // topics[3]
            )
          }
          default {
            mstore(0, 'EMITS: invalid topic count')
            revert(0, 0x20)
          }
      }
      n_emitted++;
      _ptr += log_size;
    }
    ptr = _ptr;
    require(n_emitted == num_events);
  }

  function getAction(uint _ptr) internal pure returns (bytes4 action) {

    assembly {
      action := and(mload(_ptr), 0xffffffff00000000000000000000000000000000000000000000000000000000)
    }
  }

  function setContext(bytes32 _exec_id, address _sender) internal {

    assert(_exec_id != bytes32(0) && _sender != address(0));
    exec_id = _exec_id;
    sender = _sender;
  }

  function store(bytes32 _exec_id, bytes32 _location, bytes32 _data) internal {

    _location = keccak256(_location, _exec_id);
    assembly { sstore(_location, _data) }
  }


  function read(bytes32 _exec_id, bytes32 _location) public view returns (bytes32 data_read) {

    _location = keccak256(_location, _exec_id);
    assembly { data_read := sload(_location) }
  }

  function readMulti(bytes32 _exec_id, bytes32[] _locations) public view returns (bytes32[] data_read) {

    data_read = new bytes32[](_locations.length);
    for (uint i = 0; i < _locations.length; i++) {
      data_read[i] = read(_exec_id, _locations[i]);
    }
  }
}