
pragma solidity 0.7.6;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}// UNLICENSED

pragma solidity 0.7.6;


contract Ownable {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.7.6;


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

        require(b > 0);
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
}// MIT

pragma solidity 0.7.6;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// UNLICENSED

pragma solidity 0.7.6;


contract SignatureCheck is Ownable {

    using ECDSA for bytes32;
    address signerAddress;
    mapping(bytes => bool) signatures;

    constructor(address _signerAddress) Ownable() {
        signerAddress = _signerAddress;
    }

    function activateAccount(
        address transactor,
        bytes12 _account,
        uint256 _timestamp,
        bytes memory _signature
    ) public onlyOwner returns (bool) {

        require(signatures[_signature] == false);
        require(
            signerAddress ==
                verifySig(abi.encode(transactor, _account,_timestamp), _signature)
        );
        signatures[_signature] = true;
        return true;
    }

    function addRecipient(
        address transactor,
        bytes12 _account,
        uint256 _recipientOBFC,
        uint256 _timestamp,
        bytes memory _signature
    ) public onlyOwner returns (bool) {

        require(signatures[_signature] == false);
        require(
            signerAddress ==
                verifySig(
                    abi.encode(transactor, _account, _recipientOBFC, _timestamp),
                    _signature
                )
        );
        signatures[_signature] = true;
        return true;
    }

    function verifySig(bytes memory _params, bytes memory _signature)
        public
        pure
        returns (address)
    {

        return keccak256(_params).toEthSignedMessageHash().recover(_signature);
    }

    function setSignerAddress(address _signerAddress)
        public
        onlyOwner
        returns (bool)
    {

        signerAddress = _signerAddress;
        return true;
    }
}

pragma solidity 0.7.6;




contract OBFC is Ownable {

    using SafeMath for uint256;

    mapping(address => mapping(bytes12 => bool)) public authorizedSenders;
    mapping(address => bool) public authorizedAccounts;
    mapping(address => bool) public authorizedTokens;
    mapping(uint256 => bool) public authorizedRecipients;

    uint256 oneUnit = 10**18;
    uint256 public fee = 0;
    uint256 public min = 0;
    address public router;
    SignatureCheck public signatureCheck;

    event Transmit(
        address indexed transactor,
        bytes12 account,
        uint256 recipient,
        address token,
        uint256 amount,
        uint256 amountFee
    );

    event SetSenderAuthorization(
        address indexed transactor,
        bytes12 account,
        address indexed sender,
        bool isAuthorized
    );

    event ActivateAccount(
        address indexed transactor,
        bytes12 account,
        bytes signature
    );

    event AddRecipient(address indexed wallet, uint256 obfc, bytes signature);

    constructor(address _router, address _signerAddress) Ownable() {
        router = _router;
        signatureCheck = new SignatureCheck(_signerAddress);
    }

    function transmit(
        bytes12 _account,
        address _token,
        uint256 _amount,
        uint256 _recipientOBFC
    ) public returns (bool) {

        address from;
        require(_amount >= min);
        require(authorizedRecipients[_recipientOBFC] == true);
        if (authorizedSenders[msg.sender][_account] == true) {
            from = msg.sender;
        } else if (authorizedSenders[tx.origin][_account] == true) {
            from = tx.origin;
        }
        require(from != address(0));

        uint256 amountAfterFee = _amount.sub(fee);
        IERC20 token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _amount);
        token.transfer(router, amountAfterFee);
        emit Transmit(from, _account, _recipientOBFC, _token, _amount, fee);
        return true;
    }

    function setSenderAuthorization(
        bytes12 _account,
        address _sender,
        bool _isAuthorized
    ) public returns (bool) {

        require(authorizedSenders[msg.sender][_account] == true);
        authorizedSenders[_sender][_account] = _isAuthorized;
        emit SetSenderAuthorization(
            msg.sender,
            _account,
            _sender,
            _isAuthorized
        );
        return true;
    }

    function activateAccount(
        bytes12 _account,
        uint256 _signatureTimestamp,
        bytes memory _signature
    ) public returns (bool) {

        signatureCheck.activateAccount(
            msg.sender,
            _account,
            _signatureTimestamp,
            _signature
        );
        authorizedSenders[msg.sender][_account] = true;
        emit ActivateAccount(msg.sender, _account, _signature);
        return true;
    }

    function addRecipient(
        bytes12 _account,
        uint256 _recipientOBFC,
        uint256 _signatureTimestamp,
        bytes memory _signature
    ) public returns (bool) {

        signatureCheck.addRecipient(
            msg.sender,
            _account,
            _recipientOBFC,
            _signatureTimestamp,
            _signature
        );
        require(authorizedSenders[msg.sender][_account] == true);
        authorizedRecipients[_recipientOBFC] = true;
        emit AddRecipient(msg.sender, _recipientOBFC, _signature);
        return true;
    }

    function setSignerAddress(address _signerAddress)
        public
        onlyOwner
        returns (bool)
    {

        signatureCheck.setSignerAddress(_signerAddress);
        return true;
    }

    function setRouterAddress(address _router) public onlyOwner returns (bool) {

        router = _router;
        return true;
    }

    function setAuthorizedToken(address _token, bool _isAuthorized)
        public
        onlyOwner
        returns (bool)
    {

        authorizedTokens[_token] = _isAuthorized;
        return true;
    }

    function setFee(uint256 _fee) public onlyOwner returns (bool) {

        fee = _fee;
        return true;
    }

    function setMin(uint256 _min) public onlyOwner returns (bool) {

        fee = _min;
        return true;
    }

    function adminWithdraw(
        address _token,
        uint256 _amount,
        address _recipient
    ) public onlyOwner returns (bool) {

        IERC20 t = IERC20(_token);
        t.transfer(_recipient, _amount);
        return true;
    }
}
