
pragma solidity 0.8.4;


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


interface IERC20Permit {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}


library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


contract RelayManagerETH is AccessControl, ReentrancyGuard {

  using SafeERC20 for IERC20;
  using ECDSA for bytes32;
  
  address public owner;
  address public newOwner;

  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
  IERC20 public ido;

  address public bridgeWallet;
  uint8 public threshold = 1;
  uint8 public signerLength;

  uint256 public adminFee; // bps
  uint256 public adminFeeAccumulated;
  uint256 public minTransferAmount;

  mapping(address => bool) private _signers;

  mapping(address => uint256) public nonces;

  mapping(address => mapping(uint256 => bool)) public processedNonces;
 
  
  event Deposited(address indexed from, address indexed receiver, uint256 toChainId, uint256 amount, uint256 nonce);
  event Sent(address indexed receiver, uint256 indexed amount, uint256 indexed transferredAmount, uint256 nonce);
  event AdminFeeChanged(uint256 indexed AdminFee);
  event EthReceived(address indexed sender, uint256 amount);
  event BridgeWalletChanged(address indexed bridgeWallet);
  event ThresholdChanged(uint8 threshold);
  event SignerAdded(address indexed signer);
  event SignerRemoved(address indexed signer);

  constructor(
    IERC20 _ido,
    uint256 _adminFee,
    address _bridgeWallet,
    uint8 _threshold,
    address[] memory signers_
  ) {
    require(_adminFee != 0, "RelayManagerETH: ADMIN_FEE_INVALID");
    require(_threshold >= 1, "RelayManager2Secure: THRESHOLD_INVALID");
    require(_bridgeWallet != address(0), "RelayManager2Secure: BRIDGE_WALLET_ADDRESS_INVALID");
    address sender = _msgSender();

    for (uint8 i = 0; i < signers_.length; i++) {
      if (signers_[i] != address(0) && !_signers[signers_[i]]) {
        _signers[signers_[i]] = true;
        signerLength++;
      }
    }

    require(signerLength >= _threshold, "RelayManager2Secure: SIGNERS_NOT_ENOUGH");
    ido = _ido;
    owner = sender;
    adminFee = _adminFee;
    bridgeWallet = _bridgeWallet;
    threshold = _threshold;

    _setupRole(DEFAULT_ADMIN_ROLE, sender);
    _setupRole(OPERATOR_ROLE, sender);

    emit OwnershipTransferred(address(0), sender);
  }

  receive() external payable {
    emit EthReceived(_msgSender(), msg.value);
  }


  function setAdminFee(
    uint256 newAdminFee,
    bytes[] calldata signatures
  ) external onlyOperator {

    require(newAdminFee != 0, "RelayManager2Secure: ADMIN_FEE_INVALID");
    require(
      _verify(keccak256(abi.encodePacked(newAdminFee)), signatures),
      "RelayManager2Secure: INVALID_SIGNATURE"
    );
    adminFee = newAdminFee;

    emit AdminFeeChanged(newAdminFee);
  }

  function setThreshold(
    uint8 newThreshold,
    bytes[] calldata signatures
  ) external onlyOperator {

    require(newThreshold >= 1, "RelayManager2Secure: THRESHOLD_INVALID");
    require(
      _verify(keccak256(abi.encodePacked(newThreshold)), signatures),
      "RelayManager2Secure: INVALID_SIGNATURE"
    );
    threshold = newThreshold;

    emit ThresholdChanged(newThreshold);
  }

  function addSigner(
    address signer,
    bytes[] calldata signatures
  ) external onlyOperator {

    require(
      _verify(keccak256(abi.encodePacked(signer)), signatures),
      "RelayManager2Secure: INVALID_SIGNATURE"
    );

    if (signer != address(0) && !_signers[signer]) {
      _signers[signer] = true;
      signerLength++;
    }

    emit SignerAdded(signer);
  }

  function removeSigner(
    address signer,
    bytes[] calldata signatures
  ) external onlyOperator {

    require(
      _verify(keccak256(abi.encodePacked(signer)), signatures),
      "RelayManager2Secure: INVALID_SIGNATURE"
    );

    if (_signers[signer] && --signerLength >= threshold) {
      _signers[signer] = false;
    }

    emit SignerRemoved(signer);
  }

  function setBridgeWallet(
    address newBridgeWallet,
    bytes[] calldata signatures
  ) external onlyOperator {

    require(newBridgeWallet != address(0), "RelayManager2Secure: BRIDGE_WALLET_ADDRESS_INVALID");
    require(
      _verify(keccak256(abi.encodePacked(newBridgeWallet)), signatures),
      "RelayManager2Secure: INVALID_SIGNATURE"
    );
    bridgeWallet = newBridgeWallet;

    emit BridgeWalletChanged(newBridgeWallet);
  }


  function setMinTransferAmount(uint256 newMinTransferAmount) external onlyOwner {

    minTransferAmount = newMinTransferAmount;
  }


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {

    require(owner == _msgSender(), "RelayManagerETH: CALLER_NO_OWNER");
    _;
  }

  function renounceOwnership() external onlyOwner {

    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }

  function transferOwnership(address _newOwner) external onlyOwner {

    require(_newOwner != address(0), "RelayManagerETH: INVALID_ADDRESS");
    require(_newOwner != owner, "RelayManagerETH: OWNERSHIP_SELF_TRANSFER");
    newOwner = _newOwner;
  }

  function acceptOwnership() external {

    require(_msgSender() == newOwner, "RelayManagerETH: CALLER_NO_NEW_OWNER");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }


  modifier onlyOperator() {

    require(hasRole(OPERATOR_ROLE, _msgSender()), "RelayManagerETH: CALLER_NO_OPERATOR_ROLE");
    _;
  }

  function addOperator(address account) public onlyOwner {

    grantRole(OPERATOR_ROLE, account);
  }

  function removeOperator(address account) public onlyOwner {

    revokeRole(OPERATOR_ROLE, account);
  }

  function checkOperator(address account) public view returns (bool) {

    return hasRole(OPERATOR_ROLE, account);
  }


  function deposit(
    address receiver,
    uint256 amount,
    uint256 toChainId
  ) external {

    require(amount >= minTransferAmount, "RelayManagerETH: DEPOSIT_AMOUNT_INVALID");
    require(receiver != address(0), "RelayManagerETH: RECEIVER_ZERO_ADDRESS");
    address sender = _msgSender();
    ido.safeTransferFrom(sender, address(this), amount);

    emit Deposited(sender, receiver, toChainId, amount, nonces[sender]++);
  }



  function send(
    address from,
    address receiver,
    uint256 amount,
    uint256 nonce,
    bytes[] calldata signatures
  ) external nonReentrant onlyOperator {

    _send(from, receiver, amount, nonce, signatures);
  }


  

  function _send(
    address from,
    address receiver,
    uint256 amount,
    uint256 nonce,
    bytes[] calldata _signatures
  ) internal {

    require(receiver != address(0), "RelayManagerETH: RECEIVER_ZERO_ADDRESS");
    require(amount > adminFee, "RelayManagerETH: SEND_AMOUNT_INVALID");
    require(
      _verify(keccak256(abi.encodePacked(from, receiver, amount, nonce)), _signatures),
      "RelayManager2Secure: INVALID_SIGNATURE"
    );
    require(!processedNonces[from][nonce], 'RelayManager2Secure: TRANSFER_NONCE_ALREADY_PROCESSED');
    processedNonces[from][nonce] = true;
    
    
    adminFeeAccumulated += adminFee;
    uint256 amountToTransfer = amount - adminFee;
    ido.safeTransfer(receiver, amountToTransfer);
    ido.safeTransfer(bridgeWallet, adminFee);

    emit Sent(receiver, amount, amountToTransfer, nonce);
  }
  function isSigner(address _candidate) public view returns (bool) {

    return _signers[_candidate];
  }

  function _verify(
    bytes32 _hash,
    bytes[] memory _signatures
  ) private view returns (bool) {

    bytes32 h = _hash.toEthSignedMessageHash();
    address lastSigner = address(0x0);
    address currentSigner;

    for (uint256 i = 0; i < _signatures.length; i++) {
      currentSigner = h.recover( _signatures[i]);

      if (currentSigner <= lastSigner) {
        return false;
      }
      if (!_signers[currentSigner]) {
        return false;
      }
      lastSigner = currentSigner;
    }

    if (_signatures.length < threshold) {
      return false;
    }

    return true;
  }
}