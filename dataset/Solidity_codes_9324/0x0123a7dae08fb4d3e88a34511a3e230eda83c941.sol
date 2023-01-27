

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;



contract ERC20 is IERC20 {

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

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


pragma solidity ^0.5.13;


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


pragma solidity 0.5.16;

interface IBorrower {

    function executeOnFlashMint(uint256 amount) external;

}


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}


pragma solidity 0.5.16;





contract FlashToken is ERC20 {

    using SafeMath for uint256;

    ERC20Detailed internal _baseToken;
    address private _factory;
    string public name;
    string public symbol;
    uint8 public decimals;


    modifier initializeTemplate() {

        _factory = msg.sender;

        uint32 codeSize;
        assembly {
            codeSize := extcodesize(address)
        }
        require(codeSize == 0, "must be called within contract constructor");
        _;
    }

    function initialize(address baseToken) public initializeTemplate() {

        _baseToken = ERC20Detailed(baseToken);
        name = string(abi.encodePacked("Flash", _baseToken.name()));
        symbol = string(abi.encodePacked("Flash", _baseToken.symbol()));
        decimals = _baseToken.decimals();
    }

    function getFactory() public view returns (address factory) {

        return _factory;
    }

    function getBaseToken() public view returns (address baseToken) {

        return address(_baseToken);
    }


    function deposit(uint256 amount) public {

        require(
            _baseToken.transferFrom(msg.sender, address(this), amount),
            "transfer in failed"
        );
        _mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {

        _burn(msg.sender, amount); // reverts if `msg.sender` does not have enough CT-baseToken
        require(_baseToken.transfer(msg.sender, amount), "transfer out failed");
    }


    modifier flashMint(uint256 amount) {

        _mint(msg.sender, amount); // reverts if `amount` makes `_totalSupply` overflow

        _;

        _burn(msg.sender, amount); // reverts if `msg.sender` does not have enough units of the FMT

        require(
            _baseToken.balanceOf(address(this)) >= totalSupply(),
            "redeemability was broken"
        );
    }

    function softFlashFuck(uint256 amount) public flashMint(amount) {

        IBorrower(msg.sender).executeOnFlashMint(amount);
    }

    function hardFlashFuck(
        address target,
        bytes memory targetCalldata,
        uint256 amount
    ) public flashMint(amount) {

        (bool success, ) = target.call(targetCalldata);
        require(success, "external call failed");
    }
}


pragma solidity 0.5.16;



contract UniswapFactoryInterface {

    address public exchangeTemplate;
    uint256 public tokenCount;
    function createExchange(address token) external returns (address exchange);

    function getExchange(address token) external view returns (address exchange);

    function getToken(address exchange) external view returns (address token);

    function getTokenWithId(uint256 tokenId) external view returns (address token);

    function initializeFactory(address template) external;

}

contract FlashTokenFactory is Spawner {

    uint256 private _tokenCount;
    address private _templateContract;
    mapping(address => address) private _baseToFlash;
    mapping(address => address) private _flashToBase;
    mapping(uint256 => address) private _idToBase;

    event TemplateSet(address indexed templateContract);
    event FlashTokenCreated(
        address indexed token,
        address indexed flashToken,
        address indexed uniswapExchange,
        uint256 tokenID
    );

    function setTemplate(address templateContract) public {

        require(_templateContract == address(0));
        _templateContract = templateContract;
        emit TemplateSet(templateContract);
    }

    function createFlashToken(address token)
        public
        returns (address flashToken)
    {

        require(token != address(0), "cannot wrap address 0");
        if (_baseToFlash[token] != address(0)) {
            return _baseToFlash[token];
        } else {
            require(_baseToFlash[token] == address(0), "token already wrapped");

            flashToken = _flashWrap(token);
            address uniswapExchange = UniswapFactoryInterface(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95).createExchange(flashToken);

            _baseToFlash[token] = flashToken;
            _flashToBase[flashToken] = token;
            _tokenCount += 1;
            _idToBase[_tokenCount] = token;

            emit FlashTokenCreated(token, flashToken, uniswapExchange, _tokenCount);
            return flashToken;
        }
    }

    function _flashWrap(address token) private returns (address flashToken) {

        FlashToken template;
        bytes memory initCalldata = abi.encodeWithSelector(
            template.initialize.selector,
            token
        );
        return Spawner._spawn(address(this), _templateContract, initCalldata);
    }


    function getFlashToken(address token)
        public
        view
        returns (address flashToken)
    {

        return _baseToFlash[token];
    }

    function getBaseToken(address flashToken)
        public
        view
        returns (address token)
    {

        return _flashToBase[flashToken];
    }

    function getBaseFromID(uint256 tokenID)
        public
        view
        returns (address token)
    {

        return _idToBase[tokenID];
    }

    function getTokenCount() public view returns (uint256 tokenCount) {

        return _tokenCount;
    }

}