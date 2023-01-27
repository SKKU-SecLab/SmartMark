
pragma solidity 0.5.16;


contract Spawn {

  constructor(
    address logicContract,
    bytes memory initializationCalldata
  ) public payable {
    (bool ok, ) = logicContract.delegatecall(initializationCalldata);
    if (!ok) {
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    bytes memory runtimeCode = abi.encodePacked(
      bytes10(0x363d3d373d3d3d363d73),
      logicContract,
      bytes15(0x5af43d82803e903d91602b57fd5bf3)
    );

    assembly {
      return(add(0x20, runtimeCode), 45) // eip-1167 runtime code, length
    }
  }
}

contract Spawner {

  
  function _spawn(
    address creator,
    address logicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {



    bytes memory initCode;
    bytes32 initCodeHash;
    (initCode, initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);


    (address target, bytes32 safeSalt) = _getNextNonceTargetWithInitCodeHash(creator, initCodeHash);


    return _executeSpawnCreate2(initCode, safeSalt, target);
  }

  function _spawnSalty(
    address creator,
    address logicContract,
    bytes memory initializationCalldata,
    bytes32 salt
  ) internal returns (address spawnedContract) {



    bytes memory initCode;
    bytes32 initCodeHash;
    (initCode, initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);


    (address target, bytes32 safeSalt, bool validity) = _getSaltyTargetWithInitCodeHash(creator, initCodeHash, salt);
    require(validity, "contract already deployed with supplied salt");


    return _executeSpawnCreate2(initCode, safeSalt, target);
  }

  function _executeSpawnCreate2(bytes memory initCode, bytes32 safeSalt, address target) private returns (address spawnedContract) {

    assembly {
      let encoded_data := add(0x20, initCode) // load initialization code.
      let encoded_size := mload(initCode)     // load the init code's length.
      spawnedContract := create2(             // call `CREATE2` w/ 4 arguments.
        callvalue,                            // forward any supplied endowment.
        encoded_data,                         // pass in initialization code.
        encoded_size,                         // pass in init code's length.
        safeSalt                              // pass in the salt value.
      )

      if iszero(spawnedContract) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    require(spawnedContract == target, "attempted deployment to unexpected address");

    return spawnedContract;
  }

  function _getSaltyTarget(
    address creator,
    address logicContract,
    bytes memory initializationCalldata,
    bytes32 salt
  ) internal view returns (address target, bool validity) {



    bytes32 initCodeHash;
    ( , initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);


    (target, , validity) = _getSaltyTargetWithInitCodeHash(creator, initCodeHash, salt);

    return (target, validity);
  }

  function _getSaltyTargetWithInitCodeHash(
    address creator,
    bytes32 initCodeHash,
    bytes32 salt
  ) private view returns (address target, bytes32 safeSalt, bool validity) {

    safeSalt = keccak256(abi.encodePacked(creator, salt));

    target = _computeTargetWithCodeHash(initCodeHash, safeSalt);

    validity = _getTargetValidity(target);

    return (target, safeSalt, validity);
  }

  function _getNextNonceTarget(
    address creator,
    address logicContract,
    bytes memory initializationCalldata
  ) internal view returns (address target) {



    bytes32 initCodeHash;
    ( , initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);


    (target, ) = _getNextNonceTargetWithInitCodeHash(creator, initCodeHash);

    return target;
  }

  function _getNextNonceTargetWithInitCodeHash(
    address creator,
    bytes32 initCodeHash
  ) private view returns (address target, bytes32 safeSalt) {

    uint256 nonce = 0;

    while (true) {
      safeSalt = keccak256(abi.encodePacked(creator, nonce));

      target = _computeTargetWithCodeHash(initCodeHash, safeSalt);

      if (_getTargetValidity(target))
        break;
      else
        nonce++;
    }
    
    return (target, safeSalt);
  }

  function _getInitCodeAndHash(
    address logicContract,
    bytes memory initializationCalldata
  ) private pure returns (bytes memory initCode, bytes32 initCodeHash) {

    initCode = abi.encodePacked(
      type(Spawn).creationCode,
      abi.encode(logicContract, initializationCalldata)
    );

    initCodeHash = keccak256(initCode);

    return (initCode, initCodeHash);
  }
  
  function _computeTargetWithCodeHash(
    bytes32 initCodeHash,
    bytes32 safeSalt
  ) private view returns (address target) {

    return address(    // derive the target deployment address.
      uint160(                   // downcast to match the address type.
        uint256(                 // cast to uint to truncate upper digits.
          keccak256(             // compute CREATE2 hash using 4 inputs.
            abi.encodePacked(    // pack all inputs to the hash together.
              bytes1(0xff),      // pass in the control character.
              address(this),     // pass in the address of this contract.
              safeSalt,          // pass in the safeSalt from above.
              initCodeHash       // pass in hash of contract creation code.
            )
          )
        )
      )
    );
  }

  function _getTargetValidity(address target) private view returns (bool validity) {

    uint256 codeSize;
    assembly { codeSize := extcodesize(target) }
    return codeSize == 0;
  }
}



interface iRegistry {


    enum FactoryStatus { Unregistered, Registered, Retired }

    event FactoryAdded(address owner, address factory, uint256 factoryID, bytes extraData);
    event FactoryRetired(address owner, address factory, uint256 factoryID);
    event InstanceRegistered(address instance, uint256 instanceIndex, address indexed creator, address indexed factory, uint256 indexed factoryID);


    function addFactory(address factory, bytes calldata extraData ) external;

    function retireFactory(address factory) external;



    function getFactoryCount() external view returns (uint256 count);

    function getFactoryStatus(address factory) external view returns (FactoryStatus status);

    function getFactoryID(address factory) external view returns (uint16 factoryID);

    function getFactoryData(address factory) external view returns (bytes memory extraData);

    function getFactoryAddress(uint16 factoryID) external view returns (address factory);

    function getFactory(address factory) external view returns (FactoryStatus state, uint16 factoryID, bytes memory extraData);

    function getFactories() external view returns (address[] memory factories);

    function getPaginatedFactories(uint256 startIndex, uint256 endIndex) external view returns (address[] memory factories);



    function register(address instance, address creator, uint80 extraData) external;



    function getInstanceType() external view returns (bytes4 instanceType);

    function getInstanceCount() external view returns (uint256 count);

    function getInstance(uint256 index) external view returns (address instance);

    function getInstances() external view returns (address[] memory instances);

    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);

}


interface iFactory {


    event InstanceCreated(address indexed instance, address indexed creator, bytes callData);

    function create(bytes calldata callData) external returns (address instance);

    function createSalty(bytes calldata callData, bytes32 salt) external returns (address instance);

    function getInitSelector() external view returns (bytes4 initSelector);

    function getInstanceRegistry() external view returns (address instanceRegistry);

    function getTemplate() external view returns (address template);

    function getSaltyInstance(address creator, bytes calldata callData, bytes32 salt) external view returns (address instance, bool validity);

    function getNextNonceInstance(address creator, bytes calldata callData) external view returns (address instance);


    function getInstanceCreator(address instance) external view returns (address creator);

    function getInstanceType() external view returns (bytes4 instanceType);

    function getInstanceCount() external view returns (uint256 count);

    function getInstance(uint256 index) external view returns (address instance);

    function getInstances() external view returns (address[] memory instances);

    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);

}


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
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract EventMetadata {


    event MetadataSet(bytes metadata);


    function _setMetadata(bytes memory metadata) internal {

        emit MetadataSet(metadata);
    }
}



contract Operated {


    address private _operator;

    event OperatorUpdated(address operator);


    function _setOperator(address operator) internal {


        require(_operator == address(0), "operator already set");

        require(operator != address(0), "cannot set operator to address 0");

        _operator = operator;

        emit OperatorUpdated(operator);
    }

    function _transferOperator(address operator) internal {


        require(_operator != address(0), "only when operator set");

        require(operator != address(0), "cannot set operator to address 0");

        _operator = operator;

        emit OperatorUpdated(operator);
    }

    function _renounceOperator() internal {


        require(_operator != address(0), "only when operator set");

        _operator = address(0);

        emit OperatorUpdated(address(0));
    }


    function getOperator() public view returns (address operator) {

        return _operator;
    }

    function isOperator(address caller) internal view returns (bool ok) {

        return caller == _operator;
    }

}



contract Template {


    address private _factory;


    modifier initializeTemplate() {

        _factory = msg.sender;

        uint32 codeSize;
        assembly { codeSize := extcodesize(address) }
        require(codeSize == 0, "must be called within contract constructor");
        _;
    }


    function getCreator() public view returns (address creator) {

        return iFactory(_factory).getInstanceCreator(address(this));
    }

    function isCreator(address caller) internal view returns (bool validity) {

        return (caller == getCreator());
    }

    function getFactory() public view returns (address factory) {

        return _factory;
    }

}



contract Deadline {


    using SafeMath for uint256;

    uint256 private _deadline;

    event DeadlineSet(uint256 deadline);


    function _setDeadline(uint256 deadline) internal {

        _deadline = deadline;
        emit DeadlineSet(deadline);
    }


    function getDeadline() public view returns (uint256 deadline) {

        return _deadline;
    }


    function getTimeRemaining() public view returns (uint256 time) {

        if (_deadline > now)
            return _deadline.sub(now);
        else
            return 0;
    }

    enum DeadlineStatus { isNull, isSet, isOver }
    function getDeadlineStatus() public view returns (DeadlineStatus status) {

        if (_deadline == 0)
            return DeadlineStatus.isNull;
        if (_deadline > now)
            return DeadlineStatus.isSet;
        else
            return DeadlineStatus.isOver;
    }

    function isNull() internal view returns (bool status) {

        return getDeadlineStatus() == DeadlineStatus.isNull;
    }

    function isSet() internal view returns (bool status) {

        return getDeadlineStatus() == DeadlineStatus.isSet;
    }

    function isOver() internal view returns (bool status) {

        return getDeadlineStatus() == DeadlineStatus.isOver;
    }

}


library DecimalMath {

    using SafeMath for uint256;

    uint256 internal constant e18 = uint256(10) ** uint256(18);

    function mul(uint256 x, uint256 y) internal pure returns(uint256 z) {

        z = SafeMath.add(SafeMath.mul(x, y), (e18) / 2) / (e18);
    }

    function div(uint256 x, uint256 y) internal pure returns(uint256 z) {

        z = SafeMath.add(SafeMath.mul(x, (e18)), y / 2) / y;
    }

}



contract UniswapExchangeInterface {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);

    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function setup(address token_addr) external;

}


contract iNMR {


    function totalSupply() external returns (uint256);

    function balanceOf(address _owner) external returns (uint256);

    function allowance(address _owner, address _spender) external returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool ok);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool ok);

    function approve(address _spender, uint256 _value) external returns (bool ok);

    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) external returns (bool ok);


    function mint(uint256 _value) external returns (bool ok);


    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);

}





contract Factory is Spawner, iFactory {


    address[] private _instances;
    mapping (address => address) private _instanceCreator;

    address private _templateContract;
    bytes4 private _initSelector;
    address private _instanceRegistry;
    bytes4 private _instanceType;

    event InstanceCreated(address indexed instance, address indexed creator, bytes callData);

    function _initialize(address instanceRegistry, address templateContract, bytes4 instanceType, bytes4 initSelector) internal {

        _instanceRegistry = instanceRegistry;
        _templateContract = templateContract;
        _initSelector = initSelector;
        require(instanceType == iRegistry(instanceRegistry).getInstanceType(), 'incorrect instance type');
        _instanceType = instanceType;
    }


    function create(bytes memory callData) public returns (address instance) {

        instance = Spawner._spawn(msg.sender, getTemplate(), callData);

        _createHelper(instance, callData);

        return instance;
    }

    function createSalty(bytes memory callData, bytes32 salt) public returns (address instance) {

        instance = Spawner._spawnSalty(msg.sender, getTemplate(), callData, salt);

        _createHelper(instance, callData);

        return instance;
    }

    function _createHelper(address instance, bytes memory callData) private {

        _instances.push(instance);
        _instanceCreator[instance] = msg.sender;
        iRegistry(getInstanceRegistry()).register(instance, msg.sender, uint80(0));
        emit InstanceCreated(instance, msg.sender, callData);
    }

    function getSaltyInstance(
        address creator,
        bytes memory callData,
        bytes32 salt
    ) public view returns (address instance, bool validity) {

        return Spawner._getSaltyTarget(creator, getTemplate(), callData, salt);
    }

    function getNextNonceInstance(
        address creator,
        bytes memory callData
    ) public view returns (address target) {

        return Spawner._getNextNonceTarget(creator, getTemplate(), callData);
    }

    function getInstanceCreator(address instance) public view returns (address creator) {

        return _instanceCreator[instance];
    }

    function getInstanceType() public view returns (bytes4 instanceType) {

        return _instanceType;
    }

    function getInitSelector() public view returns (bytes4 initSelector) {

        return _initSelector;
    }

    function getInstanceRegistry() public view returns (address instanceRegistry) {

        return _instanceRegistry;
    }

    function getTemplate() public view returns (address template) {

        return _templateContract;
    }

    function getInstanceCount() public view returns (uint256 count) {

        return _instances.length;
    }

    function getInstance(uint256 index) public view returns (address instance) {

        require(index < _instances.length, "index out of range");
        return _instances[index];
    }

    function getInstances() public view returns (address[] memory instances) {

        return _instances;
    }

    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) public view returns (address[] memory instances) {

        require(startIndex < endIndex, "startIndex must be less than endIndex");
        require(endIndex <= _instances.length, "end index out of range");

        address[] memory range = new address[](endIndex - startIndex);

        for (uint256 i = startIndex; i < endIndex; i++) {
            range[i - startIndex] = _instances[i];
        }

        return range;
    }

}




contract Countdown is Deadline {


    using SafeMath for uint256;

    uint256 private _length;

    event LengthSet(uint256 length);


    function _setLength(uint256 length) internal {

        _length = length;
        emit LengthSet(length);
    }

    function _start() internal returns (uint256 deadline) {

        deadline = _length.add(now);
        Deadline._setDeadline(deadline);
        return deadline;
    }


    function getLength() public view returns (uint256 length) {

        return _length;
    }

    enum CountdownStatus { isNull, isSet, isActive, isOver }
    function getCountdownStatus() public view returns (CountdownStatus status) {

        if (_length == 0)
            return CountdownStatus.isNull;
        if (Deadline.getDeadlineStatus() == DeadlineStatus.isNull)
            return CountdownStatus.isSet;
        if (Deadline.getDeadlineStatus() != DeadlineStatus.isOver)
            return CountdownStatus.isActive;
        else
            return CountdownStatus.isOver;
    }

    function isNull() internal view returns (bool validity) {

        return getCountdownStatus() == CountdownStatus.isNull;
    }

    function isSet() internal view returns (bool validity) {

        return getCountdownStatus() == CountdownStatus.isSet;
    }

    function isActive() internal view returns (bool validity) {

        return getCountdownStatus() == CountdownStatus.isActive;
    }

    function isOver() internal view returns (bool validity) {

        return getCountdownStatus() == CountdownStatus.isOver;
    }

}


contract BurnNMR {


    address private constant _NMRToken = address(0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671);
    address private constant _NMRExchange = address(0x2Bf5A5bA29E60682fC56B2Fcf9cE07Bef4F6196f);

    function _burn(uint256 value) internal {

        require(iNMR(_NMRToken).mint(value), "nmr burn failed");
    }

    function _burnFrom(address from, uint256 value) internal {

        require(iNMR(_NMRToken).numeraiTransfer(from, value), "nmr burnFrom failed");
    }

    function getTokenAddress() internal pure returns (address token) {

        token = _NMRToken;
    }

    function getExchangeAddress() internal pure returns (address exchange) {

        exchange = _NMRExchange;
    }

}




contract BurnDAI is BurnNMR {


    address private constant _DAIToken = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address private constant _DAIExchange = address(0x2a1530C4C41db0B0b2bB646CB5Eb1A67b7158667);

    function _burnFrom(address from, uint256 value) internal {


        IERC20(_DAIToken).transferFrom(from, address(this), value);

        _burn(value);
    }

    function _burn(uint256 value) internal {


        IERC20(_DAIToken).approve(_DAIExchange, value);

        uint256 tokens_sold = value;
        (uint256 min_tokens_bought, uint256 min_eth_bought) = getExpectedSwapAmount(tokens_sold);
        uint256 deadline = now;
        uint256 tokens_bought = UniswapExchangeInterface(_DAIExchange).tokenToTokenSwapInput(
            tokens_sold,
            min_tokens_bought,
            min_eth_bought,
            deadline,
            BurnNMR.getTokenAddress()
        );

        BurnNMR._burn(tokens_bought);
    }

    function getExpectedSwapAmount(uint256 amountDAI) internal view returns (uint256 amountNMR, uint256 amountETH) {

        amountETH = UniswapExchangeInterface(_DAIExchange).getTokenToEthInputPrice(amountDAI);
        amountNMR = UniswapExchangeInterface(BurnNMR.getExchangeAddress()).getEthToTokenInputPrice(amountETH);
        return (amountNMR, amountETH);
    }

    function getTokenAddress() internal pure returns (address token) {

        token = _DAIToken;
    }

    function getExchangeAddress() internal pure returns (address exchange) {

        exchange = _DAIExchange;
    }

}

contract TokenManager is BurnDAI {


    enum Tokens { NaN, NMR, DAI }

    function getTokenAddress(Tokens tokenID) public pure returns (address tokenAddress) {

        if (tokenID == Tokens.DAI)
            return BurnDAI.getTokenAddress();
        if (tokenID == Tokens.NMR)
            return BurnNMR.getTokenAddress();
        return address(0);
    }

    function getExchangeAddress(Tokens tokenID) public pure returns (address exchangeAddress) {

        if (tokenID == Tokens.DAI)
            return BurnDAI.getExchangeAddress();
        if (tokenID == Tokens.NMR)
            return BurnNMR.getExchangeAddress();
        return address(0);
    }

    modifier onlyValidTokenID(Tokens tokenID) {

        require(isValidTokenID(tokenID), 'invalid tokenID');
        _;
    }

    function isValidTokenID(Tokens tokenID) internal pure returns (bool validity) {

        return tokenID == Tokens.NMR || tokenID == Tokens.DAI;
    }

    function _transfer(Tokens tokenID, address to, uint256 value) internal onlyValidTokenID(tokenID) {

        require(IERC20(getTokenAddress(tokenID)).transfer(to, value), 'token transfer failed');
    }

    function _transferFrom(Tokens tokenID, address from, address to, uint256 value) internal onlyValidTokenID(tokenID) {

        require(IERC20(getTokenAddress(tokenID)).transferFrom(from, to, value), 'token transfer failed');
    }

    function _burn(Tokens tokenID, uint256 value) internal onlyValidTokenID(tokenID) {

        if (tokenID == Tokens.DAI) {
            BurnDAI._burn(value);
        } else if (tokenID == Tokens.NMR) {
            BurnNMR._burn(value);
        }
    }

    function _burnFrom(Tokens tokenID, address from, uint256 value) internal onlyValidTokenID(tokenID) {

        if (tokenID == Tokens.DAI) {
            BurnDAI._burnFrom(from, value);
        } else if (tokenID == Tokens.NMR) {
            BurnNMR._burnFrom(from, value);
        }
    }

    function _approve(Tokens tokenID, address spender, uint256 value) internal onlyValidTokenID(tokenID) {

        if (tokenID == Tokens.DAI) {
            require(IERC20(BurnDAI.getTokenAddress()).approve(spender, value), 'token approval failed');
        } else if (tokenID == Tokens.NMR) {
            address nmr = BurnNMR.getTokenAddress();
            uint256 currentAllowance = IERC20(nmr).allowance(msg.sender, spender);
            require(iNMR(nmr).changeApproval(spender, currentAllowance, value), 'token approval failed');
        }
    }

    function totalSupply(Tokens tokenID) internal view onlyValidTokenID(tokenID) returns (uint256 value) {

        return IERC20(getTokenAddress(tokenID)).totalSupply();
    }

    function balanceOf(Tokens tokenID, address who) internal view onlyValidTokenID(tokenID) returns (uint256 value) {

        return IERC20(getTokenAddress(tokenID)).balanceOf(who);
    }

    function allowance(Tokens tokenID, address owner, address spender) internal view onlyValidTokenID(tokenID) returns (uint256 value) {

        return IERC20(getTokenAddress(tokenID)).allowance(owner, spender);
    }
}




contract Deposit {


    using SafeMath for uint256;

    mapping (uint256 => mapping (address => uint256)) private _deposit;

    event DepositIncreased(TokenManager.Tokens tokenID, address user, uint256 amount, uint256 newDeposit);
    event DepositDecreased(TokenManager.Tokens tokenID, address user, uint256 amount, uint256 newDeposit);

    function _increaseDeposit(TokenManager.Tokens tokenID, address user, uint256 amountToAdd) internal returns (uint256 newDeposit) {

        newDeposit = _deposit[uint256(tokenID)][user].add(amountToAdd);

        _deposit[uint256(tokenID)][user] = newDeposit;

        emit DepositIncreased(tokenID, user, amountToAdd, newDeposit);

        return newDeposit;
    }

    function _decreaseDeposit(TokenManager.Tokens tokenID, address user, uint256 amountToRemove) internal returns (uint256 newDeposit) {

        uint256 currentDeposit = _deposit[uint256(tokenID)][user];

        require(currentDeposit >= amountToRemove, "insufficient deposit to remove");

        newDeposit = currentDeposit.sub(amountToRemove);

        _deposit[uint256(tokenID)][user] = newDeposit;

        emit DepositDecreased(tokenID, user, amountToRemove, newDeposit);

        return newDeposit;
    }

    function _clearDeposit(TokenManager.Tokens tokenID, address user) internal returns (uint256 amountRemoved) {

        uint256 currentDeposit = _deposit[uint256(tokenID)][user];

        _decreaseDeposit(tokenID, user, currentDeposit);

        return currentDeposit;
    }


    function getDeposit(TokenManager.Tokens tokenID, address user) internal view returns (uint256 deposit) {

        return _deposit[uint256(tokenID)][user];
    }

}





contract Staking is Deposit, TokenManager {


    using SafeMath for uint256;

    event StakeBurned(TokenManager.Tokens tokenID, address staker, uint256 amount);

    function _addStake(TokenManager.Tokens tokenID, address staker, address funder, uint256 amountToAdd) internal returns (uint256 newStake) {

        newStake = Deposit._increaseDeposit(tokenID, staker, amountToAdd);

        TokenManager._transferFrom(tokenID, funder, address(this), amountToAdd);

        return newStake;
    }

    function _takeStake(TokenManager.Tokens tokenID, address staker, address recipient, uint256 amountToTake) internal returns (uint256 newStake) {

        newStake = Deposit._decreaseDeposit(tokenID, staker, amountToTake);

        TokenManager._transfer(tokenID, recipient, amountToTake);

        return newStake;
    }

    function _takeFullStake(TokenManager.Tokens tokenID, address staker, address recipient) internal returns (uint256 amountTaken) {

        uint256 currentDeposit = Deposit.getDeposit(tokenID, staker);

        _takeStake(tokenID, staker, recipient, currentDeposit);

        return currentDeposit;
    }

    function _burnStake(TokenManager.Tokens tokenID, address staker, uint256 amountToBurn) internal returns (uint256 newStake) {

        uint256 newDeposit = Deposit._decreaseDeposit(tokenID, staker, amountToBurn);

        TokenManager._burn(tokenID, amountToBurn);

        emit StakeBurned(tokenID, staker, amountToBurn);

        return newDeposit;
    }

    function _burnFullStake(TokenManager.Tokens tokenID, address staker) internal returns (uint256 amountBurned) {

        uint256 currentDeposit = Deposit.getDeposit(tokenID, staker);

        _burnStake(tokenID, staker, currentDeposit);

        return currentDeposit;
    }

}




contract Griefing is Staking {


    enum RatioType { NaN, Inf, Dec }

    mapping (address => GriefRatio) private _griefRatio;
    struct GriefRatio {
        uint256 ratio;
        RatioType ratioType;
        TokenManager.Tokens tokenID;
   }

    event RatioSet(address staker, TokenManager.Tokens tokenID, uint256 ratio, RatioType ratioType);
    event Griefed(address punisher, address staker, uint256 punishment, uint256 cost, bytes message);

    uint256 internal constant e18 = uint256(10) ** uint256(18);


    function _setRatio(address staker, TokenManager.Tokens tokenID, uint256 ratio, RatioType ratioType) internal {

        if (ratioType == RatioType.NaN || ratioType == RatioType.Inf) {
            require(ratio == 0, "ratio must be 0 when ratioType is NaN or Inf");
        }

        require(TokenManager.isValidTokenID(tokenID), 'invalid tokenID');
        _griefRatio[staker].tokenID = tokenID;

        _griefRatio[staker].ratio = ratio;
        _griefRatio[staker].ratioType = ratioType;

        emit RatioSet(staker, tokenID, ratio, ratioType);
    }

    function _grief(
        address punisher,
        address staker,
        uint256 punishment,
        bytes memory message
    ) internal returns (uint256 cost) {

        uint256 ratio = _griefRatio[staker].ratio;
        RatioType ratioType = _griefRatio[staker].ratioType;
        TokenManager.Tokens tokenID = _griefRatio[staker].tokenID;

        require(ratioType != RatioType.NaN, "no punishment allowed");

        cost = getCost(ratio, punishment, ratioType);

        TokenManager._burnFrom(tokenID, punisher, cost);

        Staking._burnStake(tokenID, staker, punishment);

        emit Griefed(punisher, staker, punishment, cost, message);

        return cost;
    }


    function getRatio(address staker) public view returns (uint256 ratio, RatioType ratioType) {

        return (_griefRatio[staker].ratio, _griefRatio[staker].ratioType);
    }

    function getTokenID(address staker) internal view returns (TokenManager.Tokens tokenID) {

        return (_griefRatio[staker].tokenID);
    }


    function getCost(uint256 ratio, uint256 punishment, RatioType ratioType) public pure returns(uint256 cost) {

        if (ratioType == RatioType.Dec)
            return DecimalMath.mul(SafeMath.mul(punishment, e18), ratio) / e18;
        if (ratioType == RatioType.Inf)
            return 0;
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

    function getPunishment(uint256 ratio, uint256 cost, RatioType ratioType) public pure returns(uint256 punishment) {

        if (ratioType == RatioType.Dec)
            return DecimalMath.div(SafeMath.mul(cost, e18), ratio) / e18;
        if (ratioType == RatioType.Inf)
            revert("ratioType cannot be RatioType.Inf");
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

}







contract CountdownGriefing is Countdown, Griefing, EventMetadata, Operated, Template {


    using SafeMath for uint256;

    Data private _data;
    struct Data {
        address staker;
        address counterparty;
    }

    event Initialized(
        address operator,
        address staker,
        address counterparty,
        TokenManager.Tokens tokenID,
        uint256 ratio,
        Griefing.RatioType ratioType,
        uint256 countdownLength,
        bytes metadata
    );

    function initialize(
        address operator,
        address staker,
        address counterparty,
        TokenManager.Tokens tokenID,
        uint256 ratio,
        Griefing.RatioType ratioType,
        uint256 countdownLength,
        bytes memory metadata
    ) public initializeTemplate() {

        _data.staker = staker;
        _data.counterparty = counterparty;

        if (operator != address(0)) {
            Operated._setOperator(operator);
        }

        Griefing._setRatio(staker, tokenID, ratio, ratioType);

        Countdown._setLength(countdownLength);

        if (metadata.length != 0) {
            EventMetadata._setMetadata(metadata);
        }

        emit Initialized(operator, staker, counterparty, tokenID, ratio, ratioType, countdownLength, metadata);
    }


    function setMetadata(bytes memory metadata) public {

        require(Operated.isOperator(msg.sender), "only operator");

        EventMetadata._setMetadata(metadata);
    }

    function increaseStake(uint256 amountToAdd) public {

        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        require(!isTerminated(), "agreement ended");

        address staker = _data.staker;

        Staking._addStake(Griefing.getTokenID(staker), staker, msg.sender, amountToAdd);
    }

    function reward(uint256 amountToAdd) public {

        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        require(!isTerminated(), "agreement ended");

        address staker = _data.staker;

        Staking._addStake(Griefing.getTokenID(staker), staker, msg.sender, amountToAdd);
    }

    function punish(uint256 punishment, bytes memory message) public returns (uint256 cost) {

        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        require(!isTerminated(), "agreement ended");

        return Griefing._grief(msg.sender, _data.staker, punishment, message);
    }

    function releaseStake(uint256 amountToRelease) public {

        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        address staker = _data.staker;

        Staking._takeStake(Griefing.getTokenID(staker), staker, staker, amountToRelease);
    }

    function startCountdown() public returns (uint256 deadline) {

        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        require(isInitialized(), "deadline already set");

        return Countdown._start();
    }

    function returnStake() public returns (uint256 amount) {

        require(isTerminated(), "deadline not passed");

        address staker = _data.staker;

        return Staking._takeFullStake(Griefing.getTokenID(staker), staker, staker);
    }

    function retrieveStake(address recipient) public returns (uint256 amount) {

        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        require(isTerminated(), "deadline not passed");

        address staker = _data.staker;

        return Staking._takeFullStake(Griefing.getTokenID(staker), staker, recipient);
    }

    function transferOperator(address operator) public {

        require(Operated.isOperator(msg.sender), "only operator");

        Operated._transferOperator(operator);
    }

    function renounceOperator() public {

        require(Operated.isOperator(msg.sender), "only operator");

        Operated._renounceOperator();
    }


    function getStaker() public view returns (address staker) {

        return _data.staker;
    }

    function isStaker(address caller) internal view returns (bool validity) {

        return caller == getStaker();
    }

    function getCounterparty() public view returns (address counterparty) {

        return _data.counterparty;
    }

    function isCounterparty(address caller) internal view returns (bool validity) {

        return caller == getCounterparty();
    }

    function getToken() public view returns (TokenManager.Tokens tokenID, address token) {

        tokenID = Griefing.getTokenID(_data.staker);
        return (tokenID, TokenManager.getTokenAddress(tokenID));
    }

    function getStake() public view returns (uint256 stake) {

        return Deposit.getDeposit(Griefing.getTokenID(_data.staker), _data.staker);
    }

    function isStaked() public view returns (bool validity) {

        uint256 currentStake = getStake();
        return currentStake > 0;
    }

    enum AgreementStatus { isInitialized, isInCountdown, isTerminated }
    function getAgreementStatus() public view returns (AgreementStatus status) {

        if (Countdown.isOver()) {
            return AgreementStatus.isTerminated;
        } else if (Countdown.isActive()) {
            return AgreementStatus.isInCountdown;
        } else {
            return AgreementStatus.isInitialized;
        }
    }

    function isInitialized() internal view returns (bool validity) {

        return getAgreementStatus() == AgreementStatus.isInitialized;
    }

    function isInCountdown() internal view returns (bool validity) {

        return getAgreementStatus() == AgreementStatus.isInCountdown;
    }

    function isTerminated() internal view returns (bool validity) {

        return getAgreementStatus() == AgreementStatus.isTerminated;
    }
}











contract CountdownGriefingEscrow is Countdown, Staking, EventMetadata, Operated, Template {


    using SafeMath for uint256;

    Data private _data;
    struct Data {
        address buyer;
        address seller;
        TokenManager.Tokens tokenID;
        uint128 paymentAmount;
        uint128 stakeAmount;
        EscrowStatus status;
        AgreementParams agreementParams;
    }

    struct AgreementParams {
        uint120 ratio;
        Griefing.RatioType ratioType;
        uint128 countdownLength;
    }

    event Initialized(
        address operator,
        address buyer,
        address seller,
        TokenManager.Tokens tokenID,
        uint256 paymentAmount,
        uint256 stakeAmount,
        uint256 countdownLength,
        bytes metadata,
        bytes agreementParams
    );
    event StakeDeposited(address seller, uint256 amount);
    event PaymentDeposited(address buyer, uint256 amount);
    event Finalized(address agreement);
    event DataSubmitted(bytes data);
    event Cancelled();

    function initialize(
        address operator,
        address buyer,
        address seller,
        TokenManager.Tokens tokenID,
        uint256 paymentAmount,
        uint256 stakeAmount,
        uint256 escrowCountdown,
        bytes memory metadata,
        bytes memory agreementParams
    ) public initializeTemplate() {

        if (buyer != address(0)) {
            _data.buyer = buyer;
        }
        if (seller != address(0)) {
            _data.seller = seller;
        }

        if (operator != address(0)) {
            Operated._setOperator(operator);
        }

        require(TokenManager.isValidTokenID(tokenID), 'invalid token');
        _data.tokenID = tokenID;

        if (paymentAmount != uint256(0)) {
            require(paymentAmount <= uint256(uint128(paymentAmount)), "paymentAmount is too large");
            _data.paymentAmount = uint128(paymentAmount);
        }
        if (stakeAmount != uint256(0)) {
            require(stakeAmount == uint256(uint128(stakeAmount)), "stakeAmount is too large");
            _data.stakeAmount = uint128(stakeAmount);
        }

        Countdown._setLength(escrowCountdown);

        if (metadata.length != 0) {
            EventMetadata._setMetadata(metadata);
        }

        if (agreementParams.length != 0) {
            (
                uint256 ratio,
                Griefing.RatioType ratioType,
                uint256 agreementCountdown
            ) = abi.decode(agreementParams, (uint256, Griefing.RatioType, uint256));
            require(ratio == uint256(uint120(ratio)), "ratio out of bounds");
            require(agreementCountdown == uint256(uint128(agreementCountdown)), "agreementCountdown out of bounds");
            _data.agreementParams = AgreementParams(uint120(ratio), ratioType, uint128(agreementCountdown));
        }

        emit Initialized(operator, buyer, seller, tokenID, paymentAmount, stakeAmount, escrowCountdown, metadata, agreementParams);
    }

    function setMetadata(bytes memory metadata) public {

        require(Operated.isOperator(msg.sender), "only operator");

        EventMetadata._setMetadata(metadata);
    }

    function depositAndSetSeller(address seller) public {

        require(_data.seller == address(0), "seller already set");

        _data.seller = seller;

        _depositStake();
    }

    function depositStake() public {

        require(isSeller(msg.sender) || Operated.isOperator(msg.sender), "only seller or operator");

        require(_data.seller != address(0), "seller not yet set");

        _depositStake();
    }

    function _depositStake() private {

        require(isOpen() || onlyPaymentDeposited(), "can only deposit stake once");

        address seller = _data.seller;
        uint256 stakeAmount = uint256(_data.stakeAmount);

        if (stakeAmount != uint256(0)) {
            Staking._addStake(_data.tokenID, seller, msg.sender, stakeAmount);
        }

        emit StakeDeposited(seller, stakeAmount);

        if (onlyPaymentDeposited()) {
            _data.status = EscrowStatus.isDeposited;
            finalize();
        } else {
            _data.status = EscrowStatus.onlyStakeDeposited;
        }
    }

    function depositAndSetBuyer(address buyer) public {

        require(_data.buyer == address(0), "buyer already set");

        _data.buyer = buyer;

        _depositPayment();
    }

    function depositPayment() public {

        require(isBuyer(msg.sender) || Operated.isOperator(msg.sender), "only buyer or operator");

        require(_data.buyer != address(0), "buyer not yet set");

        _depositPayment();
    }

    function _depositPayment() private {

        require(isOpen() || onlyStakeDeposited(), "can only deposit payment once");

        address buyer = _data.buyer;
        uint256 paymentAmount = uint256(_data.paymentAmount);

        if (paymentAmount != uint256(0)) {
            Staking._addStake(_data.tokenID, buyer, msg.sender, paymentAmount);
        }

        emit PaymentDeposited(buyer, paymentAmount);

        if (onlyStakeDeposited()) {
            _data.status = EscrowStatus.isDeposited;
            Countdown._start();
        } else {
            _data.status = EscrowStatus.onlyPaymentDeposited;
        }
    }

    function finalize() public {

        require(isSeller(msg.sender) || Operated.isOperator(msg.sender), "only seller or operator");
        require(isDeposited(), "only after deposit");


        address agreement;
        {
            address escrowFactory = Template.getFactory();
            address escrowRegistry = iFactory(escrowFactory).getInstanceRegistry();
            address agreementFactory = abi.decode(iRegistry(escrowRegistry).getFactoryData(escrowFactory), (address));

            bytes memory initCalldata = abi.encodeWithSelector(
                iFactory(agreementFactory).getInitSelector(),
                address(this), // operator
                _data.seller,  // staker
                _data.buyer,   // counterparty
                _data.tokenID, // tokenID
                uint256(_data.agreementParams.ratio),           // griefRatio
                _data.agreementParams.ratioType,                // ratioType
                uint256(_data.agreementParams.countdownLength), // countdownLength
                bytes("")      // metadata
            );

            agreement = iFactory(agreementFactory).create(initCalldata);
        }


        uint256 totalStake;
        {
            uint256 paymentAmount = Deposit._clearDeposit(_data.tokenID, _data.buyer);
            uint256 stakeAmount = Deposit._clearDeposit(_data.tokenID, _data.seller);
            totalStake = paymentAmount.add(stakeAmount);
        }

        if (totalStake > 0) {
            TokenManager._approve(_data.tokenID, agreement, totalStake);
            CountdownGriefing(agreement).increaseStake(totalStake);
        }


        CountdownGriefing(agreement).startCountdown();

        address operator = Operated.getOperator();
        if (operator != address(0)) {
            CountdownGriefing(agreement).transferOperator(operator);
        } else {
            CountdownGriefing(agreement).renounceOperator();
        }

        _data.status = EscrowStatus.isFinalized;

        delete _data.tokenID;
        delete _data.paymentAmount;
        delete _data.stakeAmount;
        delete _data.agreementParams;

        emit Finalized(agreement);
    }

    function submitData(bytes memory data) public {

        require(isSeller(msg.sender) || Operated.isOperator(msg.sender), "only seller or operator");
        require(isFinalized(), "only after finalized");

        emit DataSubmitted(data);
    }

    function cancel() public {

        require(isSeller(msg.sender) || isBuyer(msg.sender) || Operated.isOperator(msg.sender), "only seller or buyer or operator");
        require(isOpen() || onlyStakeDeposited() || onlyPaymentDeposited(), "only before deposits are completed");

        _cancel();
    }

    function timeout() public {

        require(isBuyer(msg.sender) || Operated.isOperator(msg.sender), "only buyer or operator");
        require(isDeposited() && Countdown.isOver(), "only after countdown ended");

        _cancel();
    }

    function _cancel() private {

        address seller = _data.seller;
        address buyer = _data.buyer;
        TokenManager.Tokens tokenID = _data.tokenID;

        if (Deposit.getDeposit(tokenID, seller) != 0) {
            Staking._takeFullStake(tokenID, seller, seller);
        }

        if (Deposit.getDeposit(tokenID, buyer) != 0) {
            Staking._takeFullStake(tokenID, buyer, buyer);
        }

        _data.status = EscrowStatus.isCancelled;

        delete _data.tokenID;
        delete _data.paymentAmount;
        delete _data.stakeAmount;
        delete _data.agreementParams;

        emit Cancelled();
    }

    function transferOperator(address operator) public {

        require(Operated.isOperator(msg.sender), "only operator");

        Operated._transferOperator(operator);
    }

    function renounceOperator() public {

        require(Operated.isOperator(msg.sender), "only operator");

        Operated._renounceOperator();
    }


    function getBuyer() public view returns (address buyer) {

        return _data.buyer;
    }

    function isBuyer(address caller) internal view returns (bool validity) {

        return caller == getBuyer();
    }

    function getSeller() public view returns (address seller) {

        return _data.seller;
    }

    function isSeller(address caller) internal view returns (bool validity) {

        return caller == getSeller();
    }

    function getDeposit(address user) public view returns (uint256 amount) {

        return Deposit.getDeposit(_data.tokenID, user);
    }

    function getData() public view returns (
        TokenManager.Tokens tokenID,
        uint128 paymentAmount,
        uint128 stakeAmount,
        uint120 ratio,
        Griefing.RatioType ratioType,
        uint128 countdownLength
    ) {

        return (
            _data.tokenID,
            _data.paymentAmount,
            _data.stakeAmount,
            _data.agreementParams.ratio,
            _data.agreementParams.ratioType,
            _data.agreementParams.countdownLength
        );
    }

    enum EscrowStatus { isOpen, onlyStakeDeposited, onlyPaymentDeposited, isDeposited, isFinalized, isCancelled }
    function getEscrowStatus() public view returns (EscrowStatus status) {

        return _data.status;
    }

    function isOpen() internal view returns (bool validity) {

        return getEscrowStatus() == EscrowStatus.isOpen;
    }

    function onlyStakeDeposited() internal view returns (bool validity) {

        return getEscrowStatus() == EscrowStatus.onlyStakeDeposited;
    }

    function onlyPaymentDeposited() internal view returns (bool validity) {

        return getEscrowStatus() == EscrowStatus.onlyPaymentDeposited;
    }

    function isDeposited() internal view returns (bool validity) {

        return getEscrowStatus() == EscrowStatus.isDeposited;
    }

    function isFinalized() internal view returns (bool validity) {

        return getEscrowStatus() == EscrowStatus.isFinalized;
    }

    function isCancelled() internal view returns (bool validity) {

        return getEscrowStatus() == EscrowStatus.isCancelled;
    }
}




contract CountdownGriefingEscrow_Factory is Factory {


    constructor(address instanceRegistry, address templateContract) public {
        CountdownGriefingEscrow template;

        bytes4 instanceType = bytes4(keccak256(bytes('Escrow')));
        bytes4 initSelector = template.initialize.selector;
        Factory._initialize(instanceRegistry, templateContract, instanceType, initSelector);
    }

}