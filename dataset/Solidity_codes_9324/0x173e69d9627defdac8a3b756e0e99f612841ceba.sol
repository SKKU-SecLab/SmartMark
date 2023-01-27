
pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}// MIT
pragma solidity >=0.6.12 <0.8.0;

library ArrayLib {


    string constant NOT_IN_ARRAY     = "Not in array";
    string constant ALREADY_IN_ARRAY = "Already in array";


    function inArray(address[] storage array, address _item)
    internal view returns (bool) {

        uint len = array.length;
        for (uint i=0; i<len; i++) {
            if (array[i]==_item) return true;
        }
        return false;
    }

    function addUnique(address[] storage array, address _item)
    internal {

        require(!inArray(array, _item), ALREADY_IN_ARRAY);
        array.push(_item);
    }

    function removeByIndex(address[] storage array, uint256 index)
    internal {

        uint256 len_1 = array.length - 1;
        require(index<=len_1, NOT_IN_ARRAY);
        for (uint256 i = index; i < len_1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }

    function removeFirst(address[] storage array, address _item)
    internal {

        require(inArray(array, _item), NOT_IN_ARRAY);
        uint last = array.length-1;
        for (uint i=0; i<=last; i++) {
            if (array[i]==_item) {
                removeByIndex(array, i);
                return;
            }
        }
    }

    function addArrayUnique(address[] storage array, address[] memory _items)
    internal {

        uint len = _items.length;
        for (uint i=0; i<len; i++) {
            addUnique(array, _items[i]);
        }
    }

    function removeArrayFirst(address[] storage array, address[] memory _items)
    internal {

        uint len = _items.length;
        for (uint i=0; i<len; i++) {
            removeFirst(array, _items[i]);
        }
    }

    function inArray(uint256[] storage array, uint256 _item)
    internal view returns (bool) {

        uint len = array.length;
        for (uint i=0; i<len; i++) {
            if (array[i]==_item) return true;
        }
        return false;
    }

    function addUnique(uint256[] storage array, uint256 _item)
    internal {

        require(!inArray(array, _item), ALREADY_IN_ARRAY);
        array.push(_item);
    }


    function removeByIndex(uint256[] storage array, uint256 index)
    internal {

        uint256 len_1 = array.length - 1;
        require(index<=len_1, NOT_IN_ARRAY);
        for (uint256 i = index; i < len_1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }

    function removeFirst(uint256[] storage array, uint256 _item)
    internal {

        require(inArray(array, _item), NOT_IN_ARRAY);
        uint last = array.length-1;
        for (uint i=0; i<=last; i++) {
            if (array[i]==_item) {
                removeByIndex(array, i);
                return;
            }
        }
    }

    function addArrayUnique(uint256[] storage array, uint256[] memory _items)
    internal {

        uint len = _items.length;
        for (uint i=0; i<len; i++) {
            addUnique(array, _items[i]);
        }
    }

    function removeArrayFirst(uint256[] storage array, uint256[] memory _items)
    internal {

        uint len = _items.length;
        for (uint i=0; i<len; i++) {
            removeFirst(array, _items[i]);
        }
    }

}// MIT
pragma solidity >=0.5.16;

contract Governable {


  address public governance;

  constructor(address _governance) public {
    setGovernance(_governance);
  }

  modifier onlyGovernance() {

    require((governance==address(0)) || (msg.sender==governance), "Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {

    require(_governance != address(0), "new governance shouldn't be empty");
    governance = _governance;
  }

}// MIT
pragma solidity 0.6.12;



contract ContractRegistry is Governable, Initializable {

    using Address for address;
    using ArrayLib for address[];

    uint public constant POOLS_FOLDER = 1;
    uint public constant VAULTS_FOLDER = 2;

    mapping (uint => address[]) public addresses;

    event AddressesAdded(address[] addresses);
    event AddressesRemoved(address[] addresses);
    event PoolsAdded(address[] addresses);
    event PoolsRemoved(address[] addresses);
    event VaultsAdded(address[] addresses);
    event VaultsRemoved(address[] addresses);

    address[] private singleAddress;

    constructor(address[] memory _pools, address[] memory _vaults)
    public Governable(msg.sender) {
        singleAddress.push(address(0));
    }

    function initialize(address[] memory _pools, address[] memory _vaults)
    public onlyGovernance initializer {

        Governable.setGovernance(msg.sender);
        singleAddress.push(address(0));

        initPoolsAndVaults(_pools, _vaults);
    }

    function initPoolsAndVaults(address[] memory _pools, address[] memory _vaults)
    public onlyGovernance {

        address[] storage pools  = addresses[POOLS_FOLDER];
        address[] storage vaults = addresses[VAULTS_FOLDER];

        require(pools.length ==0 && vaults.length ==0);

        uint _poolsLen = _pools.length;
        uint _vaultsLen = _vaults.length;

        for (uint i=0; i< _poolsLen; i++) {
            pools.push(_pools[i]);
        }
        emit PoolsAdded(_pools);

        for (uint i=0; i< _vaultsLen; i++) {
            vaults.push(_vaults[i]);
        }
        emit VaultsAdded(_vaults);
    }

    function list(uint folder) public view returns (address[] memory) {

        return addresses[folder];
    }

    function add(uint folder, address _address) public onlyGovernance {

        addresses[folder].addUnique(_address);

        singleAddress[0] = _address;
        emit AddressesAdded(singleAddress);
    }

    function remove(uint folder, address _address) public onlyGovernance {

        addresses[folder].removeFirst(_address);

        singleAddress[0] = _address;
        emit AddressesRemoved(singleAddress);
    }

    function addArray(uint folder, address[] memory _addresses) public onlyGovernance {

        addresses[folder].addArrayUnique(_addresses);
        emit AddressesAdded(_addresses);
    }

    function removeArray(uint folder, address[] memory _addresses) public onlyGovernance {

        addresses[folder].removeArrayFirst(_addresses);
        emit AddressesRemoved(_addresses);
    }


    function listPools() public view returns (address[] memory) {

        return addresses[POOLS_FOLDER];
    }

    function addPool(address _address) public onlyGovernance {

        addresses[POOLS_FOLDER].addUnique(_address);

        singleAddress[0] = _address;
        emit PoolsAdded(singleAddress);
    }

    function removePool(address _address) public onlyGovernance {

        addresses[POOLS_FOLDER].removeFirst(_address);

        singleAddress[0] = _address;
        emit PoolsRemoved(singleAddress);
    }

    function addPoolsArray(address[] memory _addresses) public onlyGovernance {

        addresses[POOLS_FOLDER].addArrayUnique(_addresses);
        emit PoolsAdded(_addresses);
    }

    function removePoolsArray(address[] memory _addresses) public onlyGovernance {

        addresses[POOLS_FOLDER].removeArrayFirst(_addresses);
        emit PoolsRemoved(_addresses);
    }



    function listVaults() public view returns (address[] memory) {

        return addresses[VAULTS_FOLDER];
    }

    function addVault(address _address) public onlyGovernance {

        addresses[VAULTS_FOLDER].addUnique(_address);

        singleAddress[0] = _address;
        emit VaultsAdded(singleAddress);
    }

    function removeVault(address _address) public onlyGovernance {

        addresses[VAULTS_FOLDER].removeFirst(_address);

        singleAddress[0] = _address;
        emit VaultsRemoved(singleAddress);
    }

    function addVaultsArray(address[] memory _addresses) public onlyGovernance {

        addresses[VAULTS_FOLDER].addArrayUnique(_addresses);
        emit VaultsAdded(_addresses);
    }

    function removeVaultsArray(address[] memory _addresses) public onlyGovernance {

        addresses[VAULTS_FOLDER].removeArrayFirst(_addresses);
        emit VaultsRemoved(_addresses);
    }
}