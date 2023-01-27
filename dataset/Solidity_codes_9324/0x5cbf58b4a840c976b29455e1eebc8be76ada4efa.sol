
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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
}

abstract contract Proxy {
  fallback() external payable {
    _fallback();
  }

  function _implementation() internal view virtual returns (address);

  function _delegate(address implementation) internal {
    assembly {
      calldatacopy(0, 0, calldatasize())

      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      returndatacopy(0, 0, returndatasize())

      switch result
        case 0 {
          revert(0, returndatasize())
        }
        default {
          return(0, returndatasize())
        }
    }
  }

  function _willFallback() internal virtual {}

  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}

contract BaseUpgradeabilityProxy is Proxy {

  event Upgraded(address indexed implementation);

  bytes32 internal constant IMPLEMENTATION_SLOT =
    0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  function _implementation() internal view override returns (address impl) {

    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  function _upgradeTo(address newImplementation) internal {

    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  function _setImplementation(address newImplementation) internal {

    require(
      Address.isContract(newImplementation),
      'Cannot set a proxy implementation to a non-contract address'
    );

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}

contract UpgradeabilityProxy is BaseUpgradeabilityProxy {

  constructor(address _logic, bytes memory _data) public payable {
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if (_data.length > 0) {
      (bool success, ) = _logic.delegatecall(_data);
      require(success);
    }
  }
}

contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {

  event AdminChanged(address previousAdmin, address newAdmin);

  bytes32 internal constant ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  modifier ifAdmin() {

    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  function admin() external ifAdmin returns (address) {

    return _admin();
  }

  function implementation() external ifAdmin returns (address) {

    return _implementation();
  }

  function changeAdmin(address newAdmin) external ifAdmin {

    require(newAdmin != address(0), 'Cannot change the admin of a proxy to the zero address');
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  function upgradeTo(address newImplementation) external ifAdmin {

    _upgradeTo(newImplementation);
  }

  function upgradeToAndCall(address newImplementation, bytes calldata data)
    external
    payable
    ifAdmin
  {

    _upgradeTo(newImplementation);
    (bool success, ) = newImplementation.delegatecall(data);
    require(success);
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  function _setAdmin(address newAdmin) internal {

    bytes32 slot = ADMIN_SLOT;
    assembly {
      sstore(slot, newAdmin)
    }
  }

  function _willFallback() internal virtual override {

    require(msg.sender != _admin(), 'Cannot call fallback function from the proxy admin');
    super._willFallback();
  }
}

contract InitializableUpgradeabilityProxy is BaseUpgradeabilityProxy {

  function initialize(address _logic, bytes memory _data) public payable {

    require(_implementation() == address(0));
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if (_data.length > 0) {
      (bool success, ) = _logic.delegatecall(_data);
      require(success);
    }
  }
}

contract InitializableAdminUpgradeabilityProxy is
  BaseAdminUpgradeabilityProxy,
  InitializableUpgradeabilityProxy
{

  function initialize(
    address logic,
    address admin,
    bytes memory data
  ) public payable {

    require(_implementation() == address(0));
    InitializableUpgradeabilityProxy.initialize(logic, data);
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(admin);
  }

  function _willFallback() internal override(BaseAdminUpgradeabilityProxy, Proxy) {

    BaseAdminUpgradeabilityProxy._willFallback();
  }
}

interface PolylendToken {

    function initialize(address admin, string calldata name_, string calldata symbol_, uint8 decimals_) external;

} 

contract PolylendUpgrade is Ownable {


    address public _tokenProxy;

    struct TokenInput {
        address admin;
        address impl;
        string name;
        string symbol;
        uint8 decimals;
    }

    function Initialize(TokenInput calldata input)
        external
        onlyOwner
    {

        require(_tokenProxy == address(0), 'Create fail for proxy exist');
        InitializableAdminUpgradeabilityProxy proxy =
            new InitializableAdminUpgradeabilityProxy();

        bytes memory initParams = abi.encodeWithSelector(
            PolylendToken.initialize.selector,
            input.admin,
            input.name,
            input.symbol,
            input.decimals
        );

        proxy.initialize(input.impl, address(this), initParams);

        _tokenProxy = address(proxy);
    }

    function Upgrade(TokenInput calldata input)
        external
        onlyOwner
    {

        require(_tokenProxy != address(0), 'Upgrade fail for proxy null');
        InitializableAdminUpgradeabilityProxy proxy =
            InitializableAdminUpgradeabilityProxy(payable(_tokenProxy));

        bytes memory initParams = abi.encodeWithSelector(
            PolylendToken.initialize.selector,
            input.admin,
            input.name,
            input.symbol,
            input.decimals
        );

        proxy.upgradeToAndCall(input.impl, initParams);
    }
}