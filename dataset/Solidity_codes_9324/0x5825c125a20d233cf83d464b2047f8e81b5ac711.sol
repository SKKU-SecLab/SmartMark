
pragma solidity 0.6.11;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        
        if (v < 27) {
            v += 27;
        }
        
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT

pragma solidity 0.6.11;

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
}// MIT

pragma solidity 0.6.11;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.6.11;

interface IQredoWalletImplementation {

    function init(address _walletOwner) external;

    function invoke(bytes memory signature, address _to, uint256 _value, bytes calldata _data) external returns (bytes memory _result);

    function getBalance(address tokenAddress) external view returns(uint256 _balance);

    function getNonce() external view returns(uint256 nonce);

    function getWalletOwnerAddress() external view returns(address _walletOwner);

    
    event Invoked(address indexed sender, address indexed target, uint256 value, uint256 indexed nonce, bytes data);
    event Received(address indexed sender, uint indexed value, bytes data);
    event Fallback(address indexed sender, uint indexed value, bytes data);
}// MIT
pragma solidity 0.6.11;



contract QredoWalletImplementation is IQredoWalletImplementation {

  using ECDSA for bytes32;
  using SafeMath for uint256;

  uint256 constant private INCREMENT = 1;
  uint256 private _nonce;
  address private _walletOwner;
  bool private _locked;
  bool private _initialized;
  
  modifier isInitialized() {

      require(!_initialized, "WI::isInitialized:already initialized"); 
      _;
      _initialized = true;
  }

  function init(address walletOwner) isInitialized() external override {

    require(walletOwner != address(0), "WI::init: _walletOwner address can't be 0!");
    _walletOwner = walletOwner;
  }

  modifier noReentrancy() {

      require(!_locked, "WI::noReentrancy:Reentrant call.");
      _locked = true;
      _;
      _locked = false;
  }

  modifier onlySigner(address _to, uint256 _value, bytes calldata _data, bytes memory signature) {

    require(_to != address(0), "WI::onlySigner:to address can not be 0");
    bytes memory payload = abi.encode(_to, _value, _data, _nonce);
    address signatureAddress = keccak256(payload).toEthSignedMessageHash().recover(signature);
    require(_walletOwner == signatureAddress, "WI::onlySigner:Failed to verify signature");
    _;
  }

  function invoke(bytes memory signature, address _to, uint256 _value, bytes calldata _data) noReentrancy() onlySigner(_to, _value, _data, signature) external override returns (bytes memory _result) {

    bool success;
    (success, _result) = _to.call{value: _value}(_data);
    if (!success) {
        assembly {
            returndatacopy(0, 0, returndatasize())
            revert(0, returndatasize())
        }
    }

    emit Invoked(msg.sender, _to, _value, _nonce, _data); 
    _nonce = _nonce.add(INCREMENT);
  }
  
  receive() external payable {
      emit Received(msg.sender, msg.value, msg.data);
  }
  
  fallback() external payable {
      emit Fallback(msg.sender, msg.value, msg.data);
  }

  function getBalance(address tokenAddress) external override view returns(uint256 _balance) {

    return IERC20(tokenAddress).balanceOf(address(this));
  }

  function getNonce() external override view returns(uint256 nonce) {

    return _nonce;
  }

  function getWalletOwnerAddress() external override view returns(address walletOwner) {

    return _walletOwner;
  }
}