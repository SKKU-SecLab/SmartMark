
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// GPLv3
pragma solidity 0.7.2;


interface IElasticToken is IERC20 {

  function balanceOfInShares(address _account) external view returns (uint256 lambda);


  function burn(address _account, uint256 _amount) external returns (bool);


  function burnShares(address _account, uint256 _amount) external returns (bool);


  function mint(address _account, uint256 _amount) external returns (bool);


  function mintShares(address _account, uint256 _amount) external returns (bool);


  function numberOfTokenHolders() external view returns (uint256);


  function totalSupplyInShares() external view returns (uint256 lambda);

}// MIT
pragma solidity 0.7.2;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, 'SafeMath: subtraction overflow');
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    require(c > 0, 'SafeMath: division by zero');

    return c;
  }
}// GPLv3
pragma solidity 0.7.2;


library ElasticMath {

  function capitalDelta(uint256 totalEthValue, uint256 totalSupplyOfTokens)
    internal
    pure
    returns (uint256)
  {

    return wdiv(totalEthValue, totalSupplyOfTokens);
  }

  function deltaE(
    uint256 deltaLambda,
    uint256 capitalDeltaValue,
    uint256 k,
    uint256 elasticity,
    uint256 lambda,
    uint256 m
  ) internal pure returns (uint256) {

    uint256 lambdaDash = SafeMath.add(deltaLambda, lambda);

    return
      wmul(
        wmul(capitalDeltaValue, k),
        SafeMath.sub(
          wmul(lambdaDash, wmul(mDash(lambdaDash, lambda, m), revamp(elasticity))),
          wmul(lambda, m)
        )
      );
  }

  function lambdaFromT(
    uint256 tokens,
    uint256 k,
    uint256 m
  ) internal pure returns (uint256) {

    return wdiv(tokens, wmul(k, m));
  }

  function mDash(
    uint256 lambdaDash,
    uint256 lambda,
    uint256 m
  ) internal pure returns (uint256) {

    return wmul(wdiv(lambdaDash, lambda), m);
  }

  function revamp(uint256 elasticity) internal pure returns (uint256) {

    return SafeMath.add(elasticity, 1000000000000000000);
  }

  function t(
    uint256 lambda,
    uint256 k,
    uint256 m
  ) internal view returns (uint256) {

    if (lambda == 0) {
      return 0;
    }

    return wmul(wmul(lambda, k), m);
  }

  function wmul(uint256 a, uint256 b) internal pure returns (uint256) {

    return
      SafeMath.div(
        SafeMath.add(SafeMath.mul(a, b), SafeMath.div(1000000000000000000, 2)),
        1000000000000000000
      );
  }

  function wdiv(uint256 a, uint256 b) internal pure returns (uint256) {

    return SafeMath.div(SafeMath.add(SafeMath.mul(a, 1000000000000000000), SafeMath.div(b, 2)), b);
  }
}// GPLv3
pragma solidity 0.7.2;

interface IUniswapV2Pair {

  function sync() external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// GPLv3
pragma solidity 0.7.2;
pragma experimental ABIEncoderV2;

contract EternalModel {

  struct Storage {
    mapping(bytes32 => address) addressStorage;
    mapping(bytes32 => bool) boolStorage;
    mapping(bytes32 => bytes) bytesStorage;
    mapping(bytes32 => int256) intStorage;
    mapping(bytes32 => string) stringStorage;
    mapping(bytes32 => uint256) uIntStorage;
  }

  Storage internal s;


  function getUint(bytes32 _key) internal view returns (uint256) {

    return s.uIntStorage[_key];
  }

  function getString(bytes32 _key) internal view returns (string memory) {

    return s.stringStorage[_key];
  }

  function getAddress(bytes32 _key) internal view returns (address) {

    return s.addressStorage[_key];
  }

  function getBool(bytes32 _key) internal view returns (bool) {

    return s.boolStorage[_key];
  }


  function setUint(bytes32 _key, uint256 _value) internal {

    s.uIntStorage[_key] = _value;
  }

  function setString(bytes32 _key, string memory _value) internal {

    s.stringStorage[_key] = _value;
  }

  function setAddress(bytes32 _key, address _value) internal {

    s.addressStorage[_key] = _value;
  }

  function setBool(bytes32 _key, bool _value) internal {

    s.boolStorage[_key] = _value;
  }
}// GPLv3
pragma solidity 0.7.2;



contract Ecosystem is EternalModel, ReentrancyGuard {

  struct Instance {
    address daoAddress;
    address daoModelAddress;
    address ecosystemModelAddress;
    address tokenHolderModelAddress;
    address tokenModelAddress;
    address governanceTokenAddress;
  }

  event Serialized(address indexed _daoAddress);

  function deserialize(address _daoAddress) external view returns (Instance memory record) {

    if (_exists(_daoAddress)) {
      record.daoAddress = _daoAddress;
      record.daoModelAddress = getAddress(
        keccak256(abi.encode(record.daoAddress, 'daoModelAddress'))
      );
      record.ecosystemModelAddress = address(this);
      record.governanceTokenAddress = getAddress(
        keccak256(abi.encode(record.daoAddress, 'governanceTokenAddress'))
      );
      record.tokenHolderModelAddress = getAddress(
        keccak256(abi.encode(record.daoAddress, 'tokenHolderModelAddress'))
      );
      record.tokenModelAddress = getAddress(
        keccak256(abi.encode(record.daoAddress, 'tokenModelAddress'))
      );
    }

    return record;
  }

  function exists(address _daoAddress) external view returns (bool recordExists) {

    return _exists(_daoAddress);
  }

  function serialize(Instance memory _record) external nonReentrant {

    bool recordExists = _exists(_record.daoAddress);

    require(
      msg.sender == _record.daoAddress || (_record.daoAddress == address(0) && !recordExists),
      'ElasticDAO: Unauthorized'
    );

    setAddress(
      keccak256(abi.encode(_record.daoAddress, 'daoModelAddress')),
      _record.daoModelAddress
    );
    setAddress(
      keccak256(abi.encode(_record.daoAddress, 'governanceTokenAddress')),
      _record.governanceTokenAddress
    );
    setAddress(
      keccak256(abi.encode(_record.daoAddress, 'tokenHolderModelAddress')),
      _record.tokenHolderModelAddress
    );
    setAddress(
      keccak256(abi.encode(_record.daoAddress, 'tokenModelAddress')),
      _record.tokenModelAddress
    );

    setBool(keccak256(abi.encode(_record.daoAddress, 'exists')), true);

    emit Serialized(_record.daoAddress);
  }

  function _exists(address _daoAddress) internal view returns (bool recordExists) {

    return getBool(keccak256(abi.encode(_daoAddress, 'exists')));
  }
}// GPLv3
pragma solidity 0.7.2;



contract DAO is EternalModel, ReentrancyGuard {

  struct Instance {
    address uuid;
    address[] summoners;
    bool summoned;
    string name;
    uint256 maxVotingLambda;
    uint256 numberOfSummoners;
    Ecosystem.Instance ecosystem;
  }

  event Serialized(address indexed uuid);

  function deserialize(address _uuid, Ecosystem.Instance memory _ecosystem)
    external
    view
    returns (Instance memory record)
  {

    record.uuid = _uuid;
    record.ecosystem = _ecosystem;

    if (_exists(_uuid)) {
      record.maxVotingLambda = getUint(keccak256(abi.encode(_uuid, 'maxVotingLambda')));
      record.name = getString(keccak256(abi.encode(_uuid, 'name')));
      record.numberOfSummoners = getUint(keccak256(abi.encode(_uuid, 'numberOfSummoners')));
      record.summoned = getBool(keccak256(abi.encode(_uuid, 'summoned')));
    }

    return record;
  }

  function exists(address _uuid) external view returns (bool) {

    return _exists(_uuid);
  }

  function getSummoner(Instance memory _dao, uint256 _index) external view returns (address) {

    return getAddress(keccak256(abi.encode(_dao.uuid, 'summoners', _index)));
  }

  function isSummoner(Instance memory _dao, address _summonerAddress) external view returns (bool) {

    return getBool(keccak256(abi.encode(_dao.uuid, 'summoner', _summonerAddress)));
  }

  function serialize(Instance memory _record) external nonReentrant {

    require(msg.sender == _record.uuid, 'ElasticDAO: Unauthorized');

    setUint(keccak256(abi.encode(_record.uuid, 'maxVotingLambda')), _record.maxVotingLambda);
    setString(keccak256(abi.encode(_record.uuid, 'name')), _record.name);
    setBool(keccak256(abi.encode(_record.uuid, 'summoned')), _record.summoned);

    if (_record.summoners.length > 0) {
      _record.numberOfSummoners = _record.summoners.length;
      setUint(keccak256(abi.encode(_record.uuid, 'numberOfSummoners')), _record.numberOfSummoners);
      for (uint256 i = 0; i < _record.numberOfSummoners; i += 1) {
        setBool(keccak256(abi.encode(_record.uuid, 'summoner', _record.summoners[i])), true);
        setAddress(keccak256(abi.encode(_record.uuid, 'summoners', i)), _record.summoners[i]);
      }
    }

    setBool(keccak256(abi.encode(_record.uuid, 'exists')), true);

    emit Serialized(_record.uuid);
  }

  function _exists(address _uuid) internal view returns (bool) {

    return getBool(keccak256(abi.encode(_uuid, 'exists')));
  }
}// GPLv3
pragma solidity 0.7.2;


contract Token is EternalModel, ReentrancyGuard {

  struct Instance {
    address uuid;
    string name;
    string symbol;
    uint256 eByL;
    uint256 elasticity;
    uint256 k;
    uint256 lambda;
    uint256 m;
    uint256 maxLambdaPurchase;
    uint256 numberOfTokenHolders;
    Ecosystem.Instance ecosystem;
  }

  event Serialized(address indexed uuid);

  function deserialize(address _uuid, Ecosystem.Instance memory _ecosystem)
    external
    view
    returns (Instance memory record)
  {

    record.uuid = _uuid;
    record.ecosystem = _ecosystem;

    if (_exists(_uuid, _ecosystem.daoAddress)) {
      record.eByL = getUint(keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'eByL')));
      record.elasticity = getUint(
        keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'elasticity'))
      );
      record.k = getUint(keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'k')));
      record.lambda = getUint(keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'lambda')));
      record.m = getUint(keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'm')));
      record.maxLambdaPurchase = getUint(
        keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'maxLambdaPurchase'))
      );
      record.name = getString(keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'name')));
      record.numberOfTokenHolders = getUint(
        keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'numberOfTokenHolders'))
      );
      record.symbol = getString(
        keccak256(abi.encode(_uuid, record.ecosystem.daoAddress, 'symbol'))
      );
    }

    return record;
  }

  function exists(address _uuid, address _daoAddress) external view returns (bool) {

    return _exists(_uuid, _daoAddress);
  }

  function serialize(Instance memory _record) external nonReentrant {

    require(
      msg.sender == _record.uuid ||
        (msg.sender == _record.ecosystem.daoAddress &&
          _exists(_record.uuid, _record.ecosystem.daoAddress)),
      'ElasticDAO: Unauthorized'
    );

    setString(
      keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'name')),
      _record.name
    );
    setString(
      keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'symbol')),
      _record.symbol
    );
    setUint(
      keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'eByL')),
      _record.eByL
    );
    setUint(
      keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'elasticity')),
      _record.elasticity
    );
    setUint(keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'k')), _record.k);
    setUint(
      keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'lambda')),
      _record.lambda
    );
    setUint(keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'm')), _record.m);
    setUint(
      keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'maxLambdaPurchase')),
      _record.maxLambdaPurchase
    );

    setBool(keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'exists')), true);

    emit Serialized(_record.uuid);
  }

  function updateNumberOfTokenHolders(Instance memory _record, uint256 numberOfTokenHolders)
    external
    nonReentrant
  {

    require(
      msg.sender == _record.uuid && _exists(_record.uuid, _record.ecosystem.daoAddress),
      'ElasticDAO: Unauthorized'
    );

    setUint(
      keccak256(abi.encode(_record.uuid, _record.ecosystem.daoAddress, 'numberOfTokenHolders')),
      numberOfTokenHolders
    );
  }

  function _exists(address _uuid, address _daoAddress) internal view returns (bool) {

    return getBool(keccak256(abi.encode(_uuid, _daoAddress, 'exists')));
  }
}pragma solidity ^0.7.1;

contract PProxyStorage {


    function readBool(bytes32 _key) public view returns(bool) {

        return storageRead(_key) == bytes32(uint256(1));
    }

    function setBool(bytes32 _key, bool _value) internal {

        if(_value) {
            storageSet(_key, bytes32(uint256(1)));
        } else {
            storageSet(_key, bytes32(uint256(0)));
        }
    }

    function readAddress(bytes32 _key) public view returns(address) {

        return bytes32ToAddress(storageRead(_key));
    }

    function setAddress(bytes32 _key, address _value) internal {

        storageSet(_key, addressToBytes32(_value));
    }

    function storageRead(bytes32 _key) public view returns(bytes32) {

        bytes32 value;
        assembly {
            value := sload(_key)
        }
        return value;
    }

    function storageSet(bytes32 _key, bytes32 _value) internal {

        bytes32 implAddressStorageKey = _key;
        assembly {
            sstore(implAddressStorageKey, _value)
        }
    }

    function bytes32ToAddress(bytes32 _value) public pure returns(address) {

        return address(uint160(uint256(_value)));
    }

    function addressToBytes32(address _value) public pure returns(bytes32) {

        return bytes32(uint256(_value));
    }

}pragma solidity ^0.7.1;


contract PProxy is PProxyStorage {


    bytes32 constant IMPLEMENTATION_SLOT = keccak256(abi.encodePacked("IMPLEMENTATION_SLOT"));
    bytes32 constant OWNER_SLOT = keccak256(abi.encodePacked("OWNER_SLOT"));

    modifier onlyProxyOwner() {

        require(msg.sender == readAddress(OWNER_SLOT), "PProxy.onlyProxyOwner: msg sender not owner");
        _;
    }

    constructor () public {
        setAddress(OWNER_SLOT, msg.sender);
    }

    function getProxyOwner() public view returns (address) {

       return readAddress(OWNER_SLOT);
    }

    function setProxyOwner(address _newOwner) onlyProxyOwner public {

        setAddress(OWNER_SLOT, _newOwner);
    }

    function getImplementation() public view returns (address) {

        return readAddress(IMPLEMENTATION_SLOT);
    }

    function setImplementation(address _newImplementation) onlyProxyOwner public {

        setAddress(IMPLEMENTATION_SLOT, _newImplementation);
    }


    fallback () external payable {
       return internalFallback();
    }

    function internalFallback() internal virtual {

        address contractAddr = readAddress(IMPLEMENTATION_SLOT);
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), contractAddr, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

}// MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {

	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {

		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {

		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}// GPLv3
pragma solidity 0.7.2;






contract ElasticDAO is ReentrancyGuard {

  address public deployer;
  address public ecosystemModelAddress;
  address public controller;
  address[] public summoners;
  address[] public liquidityPools;
  bool public initialized;

  event ElasticGovernanceTokenDeployed(address indexed tokenAddress);
  event MaxVotingLambdaChanged(uint256 value);
  event ControllerChanged(address value);
  event ExitDAO(address indexed memberAddress, uint256 shareAmount, uint256 ethAmount);
  event FailedToFullyPenalize(
    address indexed memberAddress,
    uint256 attemptedAmount,
    uint256 actualAmount
  );
  event JoinDAO(address indexed memberAddress, uint256 shareAmount, uint256 ethAmount);
  event LiquidityPoolAdded(address indexed poolAddress);
  event LiquidityPoolRemoved(address indexed poolAddress);
  event SeedDAO(address indexed summonerAddress, uint256 amount);
  event SummonedDAO(address indexed summonedBy);

  modifier onlyAfterSummoning() {

    DAO.Instance memory dao = _getDAO();
    require(dao.summoned, 'ElasticDAO: DAO must be summoned');
    _;
  }
  modifier onlyAfterTokenInitialized() {

    Ecosystem.Instance memory ecosystem = _getEcosystem();

    bool tokenInitialized =
      Token(ecosystem.tokenModelAddress).exists(
        ecosystem.governanceTokenAddress,
        ecosystem.daoAddress
      );
    require(tokenInitialized, 'ElasticDAO: Please call initializeToken first');
    _;
  }
  modifier onlyBeforeSummoning() {

    DAO.Instance memory dao = _getDAO();
    require(dao.summoned == false, 'ElasticDAO: DAO must not be summoned');
    _;
  }
  modifier onlyController() {

    require(msg.sender == controller, 'ElasticDAO: Only controller');
    _;
  }
  modifier onlyDeployer() {

    require(msg.sender == deployer, 'ElasticDAO: Only deployer');
    _;
  }
  modifier onlySummoners() {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    DAO daoContract = DAO(ecosystem.daoModelAddress);
    DAO.Instance memory dao = daoContract.deserialize(address(this), ecosystem);
    bool summonerCheck = daoContract.isSummoner(dao, msg.sender);

    require(summonerCheck, 'ElasticDAO: Only summoners');
    _;
  }
  modifier onlyWhenOpen() {

    require(address(this).balance > 0, 'ElasticDAO: This DAO is closed');
    _;
  }

  function initialize(
    address _ecosystemModelAddress,
    address _controller,
    address[] memory _summoners,
    string memory _name,
    uint256 _maxVotingLambda
  ) external nonReentrant {

    require(initialized == false, 'ElasticDAO: Already initialized');
    require(
      _ecosystemModelAddress != address(0) && _controller != address(0),
      'ElasticDAO: Address Zero'
    );
    require(_summoners.length > 0, 'ElasticDAO: At least 1 summoner required');

    for (uint256 i = 0; i < _summoners.length; i += 1) {
      if (_summoners[i] == address(0)) {
        revert('ElasticDAO: Summoner address can not be zero address');
      }
    }

    controller = _controller;
    deployer = msg.sender;
    summoners = _summoners;

    Ecosystem.Instance memory defaults = Ecosystem(_ecosystemModelAddress).deserialize(address(0));
    Ecosystem.Instance memory ecosystem = _buildEcosystem(controller, defaults);
    ecosystemModelAddress = ecosystem.ecosystemModelAddress;

    bool success = _buildDAO(_summoners, _name, _maxVotingLambda, ecosystem);
    initialized = true;
    require(success, 'ElasticDAO: Build DAO Failed');
  }

  function addLiquidityPool(address _poolAddress)
    external
    onlyController
    nonReentrant
    returns (bool)
  {

    liquidityPools.push(_poolAddress);

    emit LiquidityPoolAdded(_poolAddress);
  }

  function initializeToken(
    string memory _name,
    string memory _symbol,
    uint256 _eByL,
    uint256 _elasticity,
    uint256 _k,
    uint256 _maxLambdaPurchase
  ) external onlyBeforeSummoning onlyDeployer nonReentrant {

    Ecosystem.Instance memory ecosystem = _getEcosystem();

    Token.Instance memory token =
      _buildToken(
        controller,
        _name,
        _symbol,
        _eByL,
        _elasticity,
        _k,
        _maxLambdaPurchase,
        ecosystem
      );

    emit ElasticGovernanceTokenDeployed(token.uuid);
  }

  function exit(uint256 _deltaLambda) external onlyAfterSummoning nonReentrant {

    Token.Instance memory token = _getToken();
    ElasticGovernanceToken tokenContract = ElasticGovernanceToken(token.uuid);

    uint256 ratioOfShares = ElasticMath.wdiv(_deltaLambda, token.lambda);
    uint256 ethToBeTransfered = ElasticMath.wmul(ratioOfShares, address(this).balance);
    tokenContract.burnShares(msg.sender, _deltaLambda);
    (bool success, ) = msg.sender.call{ value: ethToBeTransfered }('');
    require(success, 'ElasticDAO: Exit Failed');
    emit ExitDAO(msg.sender, _deltaLambda, ethToBeTransfered);
  }

  function getLiquidityPoolCount() public view returns (uint256) {

    return liquidityPools.length;
  }

  function join() external payable onlyAfterSummoning onlyWhenOpen nonReentrant {

    Token.Instance memory token = _getToken();

    ElasticGovernanceToken tokenContract = ElasticGovernanceToken(token.uuid);
    uint256 capitalDelta =
      ElasticMath.capitalDelta(
        SafeMath.sub(address(this).balance, msg.value),
        tokenContract.totalSupply()
      );
    uint256 deltaE =
      ElasticMath.deltaE(
        token.maxLambdaPurchase,
        capitalDelta,
        token.k,
        token.elasticity,
        token.lambda,
        token.m
      );

    require(msg.value >= deltaE, 'ElasticDAO: Incorrect ETH amount');

    uint256 lambdaDash = SafeMath.add(token.maxLambdaPurchase, token.lambda);
    uint256 mDash = ElasticMath.mDash(lambdaDash, token.lambda, token.m);

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    Token tokenStorage = Token(ecosystem.tokenModelAddress);
    token.m = mDash;
    tokenStorage.serialize(token);

    bool success = tokenContract.mintShares(msg.sender, token.maxLambdaPurchase);
    require(success, 'ElasticDAO: Mint Shares Failed during Join');

    for (uint256 i = 0; i < liquidityPools.length; i += 1) {
      IUniswapV2Pair(liquidityPools[i]).sync();
    }

    if (success && msg.value > deltaE) {
      (success, ) = msg.sender.call{ value: SafeMath.sub(msg.value, deltaE) }('');
      require(success, 'ElasticDAO: TransactionFailed');
    }

    emit JoinDAO(msg.sender, token.maxLambdaPurchase, msg.value);
  }

  function penalize(address[] memory _addresses, uint256[] memory _amounts)
    external
    onlyController
    nonReentrant
  {

    require(
      _addresses.length == _amounts.length,
      'ElasticDAO: An amount is required for each address'
    );

    ElasticGovernanceToken tokenContract = ElasticGovernanceToken(_getToken().uuid);

    for (uint256 i = 0; i < _addresses.length; i += 1) {
      uint256 lambda = tokenContract.balanceOfInShares(_addresses[i]);

      if (lambda < _amounts[i]) {
        if (lambda != 0) {
          tokenContract.burnShares(_addresses[i], lambda);
        }

        FailedToFullyPenalize(_addresses[i], _amounts[i], lambda);
      } else {
        tokenContract.burnShares(_addresses[i], _amounts[i]);
      }
    }
  }

  function removeLiquidityPool(address _poolAddress)
    external
    onlyController
    nonReentrant
    returns (bool)
  {

    for (uint256 i = 0; i < liquidityPools.length; i += 1) {
      if (liquidityPools[i] == _poolAddress) {
        liquidityPools[i] = liquidityPools[liquidityPools.length - 1];
        liquidityPools.pop();
      }
    }

    emit LiquidityPoolRemoved(_poolAddress);
  }

  function reward(address[] memory _addresses, uint256[] memory _amounts)
    external
    onlyController
    nonReentrant
  {

    require(
      _addresses.length == _amounts.length,
      'ElasticDAO: An amount is required for each address'
    );

    ElasticGovernanceToken tokenContract = ElasticGovernanceToken(_getToken().uuid);

    for (uint256 i = 0; i < _addresses.length; i += 1) {
      tokenContract.mintShares(_addresses[i], _amounts[i]);
    }
  }

  function setController(address _controller) external onlyController nonReentrant {

    require(_controller != address(0), 'ElasticDAO: Address Zero');

    controller = _controller;

    ElasticGovernanceToken tokenContract = ElasticGovernanceToken(_getToken().uuid);
    bool success = tokenContract.setBurner(controller);
    require(success, 'ElasticDAO: Set Burner failed during setController');
    success = tokenContract.setMinter(controller);
    require(success, 'ElasticDAO: Set Minter failed during setController');

    emit ControllerChanged(controller);
  }

  function setMaxVotingLambda(uint256 _maxVotingLambda) external onlyController nonReentrant {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    DAO daoStorage = DAO(ecosystem.daoModelAddress);
    DAO.Instance memory dao = daoStorage.deserialize(address(this), ecosystem);
    dao.maxVotingLambda = _maxVotingLambda;
    daoStorage.serialize(dao);

    emit MaxVotingLambdaChanged(_maxVotingLambda);
  }

  function seedSummoning()
    external
    payable
    onlyBeforeSummoning
    onlySummoners
    onlyAfterTokenInitialized
    nonReentrant
  {

    Token.Instance memory token = _getToken();

    uint256 deltaE = msg.value;
    uint256 deltaLambda = ElasticMath.wdiv(deltaE, token.eByL);
    ElasticGovernanceToken(token.uuid).mintShares(msg.sender, deltaLambda);

    emit SeedDAO(msg.sender, deltaLambda);
  }

  function summon(uint256 _deltaLambda) external onlyBeforeSummoning onlySummoners nonReentrant {

    require(address(this).balance > 0, 'ElasticDAO: Please seed DAO with ETH to set ETH:EGT ratio');

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    DAO daoContract = DAO(ecosystem.daoModelAddress);
    DAO.Instance memory dao = daoContract.deserialize(address(this), ecosystem);
    Token.Instance memory token =
      Token(ecosystem.tokenModelAddress).deserialize(ecosystem.governanceTokenAddress, ecosystem);
    ElasticGovernanceToken tokenContract = ElasticGovernanceToken(token.uuid);

    for (uint256 i = 0; i < dao.numberOfSummoners; i += 1) {
      tokenContract.mintShares(daoContract.getSummoner(dao, i), _deltaLambda);
    }
    dao.summoned = true;
    daoContract.serialize(dao);

    emit SummonedDAO(msg.sender);
  }


  function getDAO() external view returns (DAO.Instance memory) {

    return _getDAO();
  }

  function getEcosystem() external view returns (Ecosystem.Instance memory) {

    return _getEcosystem();
  }

  function _buildDAO(
    address[] memory _summoners,
    string memory _name,
    uint256 _maxVotingLambda,
    Ecosystem.Instance memory _ecosystem
  ) internal returns (bool) {

    DAO daoStorage = DAO(_ecosystem.daoModelAddress);
    DAO.Instance memory dao;

    dao.uuid = address(this);
    dao.ecosystem = _ecosystem;
    dao.maxVotingLambda = _maxVotingLambda;
    dao.name = _name;
    dao.summoned = false;
    dao.summoners = _summoners;
    daoStorage.serialize(dao);

    return true;
  }

  function _buildEcosystem(address _controller, Ecosystem.Instance memory _defaults)
    internal
    returns (Ecosystem.Instance memory ecosystem)
  {

    ecosystem.daoAddress = address(this);
    ecosystem.daoModelAddress = _deployProxy(_defaults.daoModelAddress, _controller);
    ecosystem.ecosystemModelAddress = _deployProxy(_defaults.ecosystemModelAddress, _controller);
    ecosystem.governanceTokenAddress = _deployProxy(_defaults.governanceTokenAddress, _controller);
    ecosystem.tokenHolderModelAddress = _deployProxy(
      _defaults.tokenHolderModelAddress,
      _controller
    );
    ecosystem.tokenModelAddress = _deployProxy(_defaults.tokenModelAddress, _controller);

    Ecosystem(ecosystem.ecosystemModelAddress).serialize(ecosystem);
    return ecosystem;
  }

  function _buildToken(
    address _controller,
    string memory _name,
    string memory _symbol,
    uint256 _eByL,
    uint256 _elasticity,
    uint256 _k,
    uint256 _maxLambdaPurchase,
    Ecosystem.Instance memory _ecosystem
  ) internal returns (Token.Instance memory token) {

    token.eByL = _eByL;
    token.ecosystem = _ecosystem;
    token.elasticity = _elasticity;
    token.k = _k;
    token.lambda = 0;
    token.m = 1000000000000000000;
    token.maxLambdaPurchase = _maxLambdaPurchase;
    token.name = _name;
    token.symbol = _symbol;
    token.uuid = _ecosystem.governanceTokenAddress;

    return
      ElasticGovernanceToken(token.uuid).initialize(_controller, _controller, _ecosystem, token);
  }

  function _deployProxy(address _implementationAddress, address _owner) internal returns (address) {

    PProxy proxy = new PProxy();
    proxy.setImplementation(_implementationAddress);
    proxy.setProxyOwner(_owner);
    return address(proxy);
  }


  function _getDAO() internal view returns (DAO.Instance memory) {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    return DAO(ecosystem.daoModelAddress).deserialize(address(this), ecosystem);
  }

  function _getEcosystem() internal view returns (Ecosystem.Instance memory) {

    return Ecosystem(ecosystemModelAddress).deserialize(address(this));
  }

  function _getToken() internal view returns (Token.Instance memory) {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    return
      Token(ecosystem.tokenModelAddress).deserialize(ecosystem.governanceTokenAddress, ecosystem);
  }

  receive() external payable {}

  fallback() external payable {}
}// GPLv3
pragma solidity 0.7.2;



contract TokenHolder is EternalModel, ReentrancyGuard {

  struct Instance {
    address account;
    uint256 lambda;
    Ecosystem.Instance ecosystem;
    Token.Instance token;
  }

  event Serialized(address indexed account, address indexed token);

  function deserialize(
    address _account,
    Ecosystem.Instance memory _ecosystem,
    Token.Instance memory _token
  ) external view returns (Instance memory record) {

    record.account = _account;
    record.ecosystem = _ecosystem;
    record.token = _token;

    if (_exists(_account, _token)) {
      record.lambda = getUint(keccak256(abi.encode(record.token.uuid, record.account, 'lambda')));
    }

    return record;
  }

  function exists(address _account, Token.Instance memory _token) external view returns (bool) {

    return _exists(_account, _token);
  }

  function serialize(Instance memory _record) external nonReentrant {

    require(msg.sender == _record.token.uuid, 'ElasticDAO: Unauthorized');

    setUint(keccak256(abi.encode(_record.token.uuid, _record.account, 'lambda')), _record.lambda);
    setBool(keccak256(abi.encode(_record.token.uuid, _record.account, 'exists')), true);

    emit Serialized(_record.account, _record.token.uuid);
  }

  function _exists(address _account, Token.Instance memory _token) internal view returns (bool) {

    return getBool(keccak256(abi.encode(_token.uuid, _account, 'exists')));
  }
}// GPLv3
pragma solidity 0.7.2;





contract ElasticGovernanceToken is IElasticToken, ReentrancyGuard {

  address public burner;
  address public daoAddress;
  address public ecosystemModelAddress;
  address public minter;
  bool public initialized;

  mapping(address => mapping(address => uint256)) private _allowances;

  modifier onlyDAO() {

    require(msg.sender == daoAddress, 'ElasticDAO: Not authorized');
    _;
  }

  modifier onlyDAOorBurner() {

    require(msg.sender == daoAddress || msg.sender == burner, 'ElasticDAO: Not authorized');
    _;
  }

  modifier onlyDAOorMinter() {

    require(msg.sender == daoAddress || msg.sender == minter, 'ElasticDAO: Not authorized');
    _;
  }

  function initialize(
    address _burner,
    address _minter,
    Ecosystem.Instance memory _ecosystem,
    Token.Instance memory _token
  ) external nonReentrant returns (Token.Instance memory) {

    require(initialized == false, 'ElasticDAO: Already initialized');
    require(_burner != address(0), 'ElasticDAO: Address Zero');
    require(_ecosystem.daoAddress != address(0), 'ElasticDAO: Address Zero');
    require(_ecosystem.ecosystemModelAddress != address(0), 'ElasticDAO: Address Zero');
    require(_minter != address(0), 'ElasticDAO: Address Zero');

    initialized = true;
    burner = _burner;
    daoAddress = _ecosystem.daoAddress;
    ecosystemModelAddress = _ecosystem.ecosystemModelAddress;
    minter = _minter;

    Token tokenStorage = Token(_ecosystem.tokenModelAddress);
    tokenStorage.serialize(_token);

    return _token;
  }

  function allowance(address _owner, address _spender) external view override returns (uint256) {

    return _allowances[_owner][_spender];
  }

  function approve(address _spender, uint256 _amount)
    external
    override
    nonReentrant
    returns (bool)
  {

    _approve(msg.sender, _spender, _amount);
    return true;
  }

  function balanceOf(address _account) external view override returns (uint256) {

    Token.Instance memory token = _getToken();
    TokenHolder.Instance memory tokenHolder = _getTokenHolder(_account);
    uint256 t = ElasticMath.t(tokenHolder.lambda, token.k, token.m);

    return t;
  }

  function balanceOfInShares(address _account) external view override returns (uint256) {

    TokenHolder.Instance memory tokenHolder = _getTokenHolder(_account);
    return tokenHolder.lambda;
  }

  function balanceOfVoting(address _account) external view returns (uint256 balance) {

    Token.Instance memory token = _getToken();
    TokenHolder.Instance memory tokenHolder = _getTokenHolder(_account);
    uint256 maxVotingLambda = _getDAO().maxVotingLambda;

    if (tokenHolder.lambda > maxVotingLambda) {
      return ElasticMath.t(maxVotingLambda, token.k, token.m);
    } else {
      return ElasticMath.t(tokenHolder.lambda, token.k, token.m);
    }
  }

  function burn(address _account, uint256 _amount)
    external
    override
    onlyDAOorBurner
    nonReentrant
    returns (bool)
  {

    _burn(_account, _amount);
    return true;
  }

  function burnShares(address _account, uint256 _amount)
    external
    override
    onlyDAOorBurner
    nonReentrant
    returns (bool)
  {

    _burnShares(_account, _amount);
    return true;
  }

  function decimals() external pure returns (uint256) {

    return 18;
  }

  function decreaseAllowance(address _spender, uint256 _subtractedValue)
    external
    nonReentrant
    returns (bool)
  {

    uint256 newAllowance = SafeMath.sub(_allowances[msg.sender][_spender], _subtractedValue);
    _approve(msg.sender, _spender, newAllowance);
    return true;
  }

  function increaseAllowance(address _spender, uint256 _addedValue)
    external
    nonReentrant
    returns (bool)
  {

    _approve(msg.sender, _spender, SafeMath.add(_allowances[msg.sender][_spender], _addedValue));
    return true;
  }

  function mint(address _account, uint256 _amount)
    external
    override
    onlyDAOorMinter
    nonReentrant
    returns (bool)
  {

    _mint(_account, _amount);

    return true;
  }

  function mintShares(address _account, uint256 _amount)
    external
    override
    onlyDAOorMinter
    nonReentrant
    returns (bool)
  {

    _mintShares(_account, _amount);
    return true;
  }

  function name() external view returns (string memory) {

    return _getToken().name;
  }

  function numberOfTokenHolders() external view override returns (uint256) {

    return _getToken().numberOfTokenHolders;
  }

  function setBurner(address _burner) external onlyDAO nonReentrant returns (bool) {

    require(_burner != address(0), 'ElasticDAO: Address Zero');

    burner = _burner;

    return true;
  }

  function setMinter(address _minter) external onlyDAO nonReentrant returns (bool) {

    require(_minter != address(0), 'ElasticDAO: Address Zero');

    minter = _minter;

    return true;
  }

  function symbol() external view returns (string memory) {

    return _getToken().symbol;
  }

  function totalSupply() external view override returns (uint256) {

    Token.Instance memory token = _getToken();
    return ElasticMath.t(token.lambda, token.k, token.m);
  }

  function totalSupplyInShares() external view override returns (uint256) {

    Token.Instance memory token = _getToken();
    return token.lambda;
  }

  function transfer(address _to, uint256 _amount) external override nonReentrant returns (bool) {

    _transfer(msg.sender, _to, _amount);
    return true;
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _amount
  ) external override nonReentrant returns (bool) {

    require(msg.sender == _from || _amount <= _allowances[_from][msg.sender], 'ERC20: Bad Caller');

    if (msg.sender != _from && _allowances[_from][msg.sender] != uint256(-1)) {
      _allowances[_from][msg.sender] = SafeMath.sub(_allowances[_from][msg.sender], _amount);
      emit Approval(_from, msg.sender, _allowances[_from][msg.sender]);
    }

    _transfer(_from, _to, _amount);
    return true;
  }


  function _approve(
    address _owner,
    address _spender,
    uint256 _amount
  ) internal {

    require(_owner != address(0), 'ERC20: approve from the zero address');
    require(_spender != address(0), 'ERC20: approve to the zero address');

    _allowances[_owner][_spender] = _amount;

    emit Approval(_owner, _spender, _amount);
  }

  function _burn(address _account, uint256 _deltaT) internal {

    Token.Instance memory token = _getToken();
    uint256 deltaLambda = ElasticMath.lambdaFromT(_deltaT, token.k, token.m);
    _burnShares(_account, deltaLambda);
  }

  function _burnShares(address _account, uint256 _deltaLambda) internal {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    Token tokenStorage = Token(ecosystem.tokenModelAddress);
    Token.Instance memory token = tokenStorage.deserialize(address(this), ecosystem);
    TokenHolder.Instance memory tokenHolder = _getTokenHolder(_account);
    bool alreadyTokenHolder = tokenHolder.lambda > 0;

    uint256 deltaT = ElasticMath.t(_deltaLambda, token.k, token.m);

    tokenHolder = _updateBalance(tokenHolder, false, _deltaLambda);

    token.lambda = SafeMath.sub(token.lambda, _deltaLambda);
    tokenStorage.serialize(token);

    TokenHolder tokenHolderStorage = TokenHolder(ecosystem.tokenHolderModelAddress);
    tokenHolderStorage.serialize(tokenHolder);
    _updateNumberOfTokenHolders(alreadyTokenHolder, token, tokenHolder, tokenStorage);
    emit Transfer(_account, address(0), deltaT);
  }

  function _mint(address _account, uint256 _deltaT) internal {

    Token.Instance memory token = _getToken();
    uint256 deltaLambda = ElasticMath.lambdaFromT(_deltaT, token.k, token.m);
    _mintShares(_account, deltaLambda);
  }

  function _mintShares(address _account, uint256 _deltaLambda) internal {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    Token tokenStorage = Token(ecosystem.tokenModelAddress);
    Token.Instance memory token = tokenStorage.deserialize(address(this), ecosystem);
    TokenHolder.Instance memory tokenHolder = _getTokenHolder(_account);
    bool alreadyTokenHolder = tokenHolder.lambda > 0;

    uint256 deltaT = ElasticMath.t(_deltaLambda, token.k, token.m);

    tokenHolder = _updateBalance(tokenHolder, true, _deltaLambda);

    token.lambda = SafeMath.add(token.lambda, _deltaLambda);
    tokenStorage.serialize(token);

    TokenHolder tokenHolderStorage = TokenHolder(ecosystem.tokenHolderModelAddress);
    tokenHolderStorage.serialize(tokenHolder);
    _updateNumberOfTokenHolders(alreadyTokenHolder, token, tokenHolder, tokenStorage);

    emit Transfer(address(0), _account, deltaT);
  }

  function _transfer(
    address _from,
    address _to,
    uint256 _deltaT
  ) internal {

    require(_from != _to, 'ElasticDAO: Can not transfer to self');

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    Token tokenStorage = Token(ecosystem.tokenModelAddress);
    Token.Instance memory token = tokenStorage.deserialize(address(this), ecosystem);

    TokenHolder.Instance memory fromTokenHolder = _getTokenHolder(_from);
    TokenHolder.Instance memory toTokenHolder = _getTokenHolder(_to);
    bool fromAlreadyTokenHolder = fromTokenHolder.lambda > 0;
    bool toAlreadyTokenHolder = toTokenHolder.lambda > 0;

    uint256 deltaLambda = ElasticMath.lambdaFromT(_deltaT, token.k, token.m);
    uint256 deltaT = ElasticMath.t(deltaLambda, token.k, token.m);

    fromTokenHolder = _updateBalance(fromTokenHolder, false, deltaLambda);
    toTokenHolder = _updateBalance(toTokenHolder, true, deltaLambda);

    TokenHolder tokenHolderStorage = TokenHolder(ecosystem.tokenHolderModelAddress);
    tokenHolderStorage.serialize(fromTokenHolder);
    tokenHolderStorage.serialize(toTokenHolder);
    _updateNumberOfTokenHolders(fromAlreadyTokenHolder, token, fromTokenHolder, tokenStorage);
    _updateNumberOfTokenHolders(toAlreadyTokenHolder, token, toTokenHolder, tokenStorage);

    emit Transfer(_from, _to, deltaT);
  }

  function _updateBalance(
    TokenHolder.Instance memory _tokenHolder,
    bool _isIncreasing,
    uint256 _deltaLambda
  ) internal pure returns (TokenHolder.Instance memory) {

    if (_isIncreasing) {
      _tokenHolder.lambda = SafeMath.add(_tokenHolder.lambda, _deltaLambda);
    } else {
      _tokenHolder.lambda = SafeMath.sub(_tokenHolder.lambda, _deltaLambda);
    }

    return _tokenHolder;
  }

  function _updateNumberOfTokenHolders(
    bool alreadyTokenHolder,
    Token.Instance memory token,
    TokenHolder.Instance memory tokenHolder,
    Token tokenStorage
  ) internal {

    if (tokenHolder.lambda > 0 && alreadyTokenHolder == false) {
      tokenStorage.updateNumberOfTokenHolders(token, SafeMath.add(token.numberOfTokenHolders, 1));
    }

    if (tokenHolder.lambda == 0 && alreadyTokenHolder) {
      tokenStorage.updateNumberOfTokenHolders(token, SafeMath.sub(token.numberOfTokenHolders, 1));
    }
  }


  function _getDAO() internal view returns (DAO.Instance memory) {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    return DAO(ecosystem.daoModelAddress).deserialize(daoAddress, ecosystem);
  }

  function _getEcosystem() internal view returns (Ecosystem.Instance memory) {

    return Ecosystem(ecosystemModelAddress).deserialize(daoAddress);
  }

  function _getTokenHolder(address _account) internal view returns (TokenHolder.Instance memory) {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    return
      TokenHolder(ecosystem.tokenHolderModelAddress).deserialize(
        _account,
        ecosystem,
        Token(ecosystem.tokenModelAddress).deserialize(address(this), ecosystem)
      );
  }

  function _getToken() internal view returns (Token.Instance memory) {

    Ecosystem.Instance memory ecosystem = _getEcosystem();
    return Token(ecosystem.tokenModelAddress).deserialize(address(this), ecosystem);
  }
}