

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

interface IERC777 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(address recipient, uint256 amount, bytes calldata data) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

contract ChequeOperator is Ownable {

    using ECDSA for bytes32;

    string constant public DOMAIN_NAME = 'ChequeOperator';
    string constant public DOMAIN_VERSION = '1';
    bytes32 constant public DOMAIN_SALT = 0x1ab0cf5e94e46a869b93264d337a8ee094e220acc53dd0b56d94a74a865b664b;

    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }
    struct Cheque {
        address token;
        address to;
        uint256 amount;
        bytes data;
        uint256 fee;
        uint256 nonce;
    }
    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(abi.encodePacked(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
    ));
    bytes32 constant CHEQUE_TYPEHASH = keccak256(abi.encodePacked(
        "Cheque(address token,address to,uint256 amount,bytes data,uint256 fee,uint256 nonce)"
    ));
    bytes32 public DOMAIN_SEPARATOR;    

    mapping(address => mapping(uint256 => bool)) public usedNonces; // For simple sendByCheque

    constructor(uint256 _chainId) public {
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: DOMAIN_NAME,
            version: DOMAIN_VERSION,
            chainId: _chainId,
            verifyingContract: address(this),
            salt: DOMAIN_SALT
        }));
    }

    function sendByCheque(address _token, address _to, uint256 _amount, bytes calldata _data, uint256 _fee, uint256 _nonce, bytes calldata _signature) external {

        require(_to != address(this));

        address signer = signerOfCheque(Cheque({
            token: _token,
            to: _to, 
            amount: _amount, 
            data: _data, 
            fee: _fee,
            nonce: _nonce
        }), _signature);
        require(signer != address(0));

        require (!usedNonces[signer][_nonce]);
        usedNonces[signer][_nonce] = true;

        IERC777 token = IERC777(_token);
        token.operatorSend(signer, _to, _amount, _data, '');

        if(_fee > 0){
	        token.operatorSend(signer, owner(), _fee, '', '');
        }
    }
    function signerOfCheque(address _token, address _to, uint256 _amount, bytes calldata _data, uint256 _fee, uint256 _nonce, bytes calldata _signature) external view returns (address) {

        return signerOfCheque(Cheque({
            token: _token,
            to: _to, 
            amount: _amount, 
            data: _data, 
            fee: _fee,
            nonce: _nonce
        }), _signature);
    }

    function signerOfCheque(Cheque memory cheque, bytes memory signature) private view returns (address) {

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(cheque)
        ));
        return digest.recover(signature);
    }

    function hash(EIP712Domain memory eip712Domain) private pure returns (bytes32) {

        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(eip712Domain.name)),
            keccak256(bytes(eip712Domain.version)),
            eip712Domain.chainId,
            eip712Domain.verifyingContract,
            eip712Domain.salt
        ));
    }
    function hash(Cheque memory cheque) private pure returns (bytes32) {

        return keccak256(abi.encode(
            CHEQUE_TYPEHASH,
            cheque.token,
            cheque.to,
            cheque.amount,
            keccak256(cheque.data),
            cheque.fee,
            cheque.nonce
        ));
    }

}