
pragma solidity 0.5.7;


interface IRSV {

    function transfer(address, uint256) external returns(bool);

    function approve(address, uint256) external returns(bool);

    function transferFrom(address, address, uint256) external returns(bool);

    function totalSupply() external view returns(uint256);

    function balanceOf(address) external view returns(uint256);

    function allowance(address, address) external view returns(uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function decimals() external view returns(uint8);

    function mint(address, uint256) external;

    function burnFrom(address, uint256) external;

    function relayTransfer(address, address, uint256) external returns(bool);

    function relayTransferFrom(address, address, address, uint256) external returns(bool);

    function relayApprove(address, address, uint256) external returns(bool);

}


contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {

    address private _owner;
    address private _nominatedOwner;

    event NewOwnerNominated(address indexed previousOwner, address indexed nominee);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function nominatedOwner() external view returns (address) {

        return _nominatedOwner;
    }

    modifier onlyOwner() {

        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {

        require(_msgSender() == _owner, "caller is not owner");
    }

    function nominateNewOwner(address newOwner) external onlyOwner {

        require(newOwner != address(0), "new owner is 0 address");
        emit NewOwnerNominated(_owner, newOwner);
        _nominatedOwner = newOwner;
    }

    function acceptOwnership() external {

        require(_nominatedOwner == _msgSender(), "unauthorized");
        emit OwnershipTransferred(_owner, _nominatedOwner);
        _owner = _nominatedOwner;
    }

    function renounceOwnership(string calldata declaration) external onlyOwner {

        string memory requiredDeclaration = "I hereby renounce ownership of this contract forever.";
        require(
            keccak256(abi.encodePacked(declaration)) ==
            keccak256(abi.encodePacked(requiredDeclaration)),
            "declaration incorrect");

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract Relayer is Ownable {


    IRSV public trustedRSV;
    mapping(address => uint) public nonce;

    event RSVChanged(address indexed oldRSVAddr, address indexed newRSVAddr);

    event TransferForwarded(
        bytes sig,
        address indexed from,
        address indexed to,
        uint256 indexed amount,
        uint256 fee
    );
    event TransferFromForwarded(
        bytes sig,
        address indexed holder,
        address indexed spender,
        address indexed to,
        uint256 amount,
        uint256 fee
    );
    event ApproveForwarded(
        bytes sig,
        address indexed holder,
        address indexed spender,
        uint256 amount,
        uint256 fee
    );
    event FeeTaken(address indexed from, address indexed to, uint256 indexed value);

    constructor(address rsvAddress) public {
        trustedRSV = IRSV(rsvAddress);
    }

    function setRSV(address newTrustedRSV) external onlyOwner {

        emit RSVChanged(address(trustedRSV), newTrustedRSV);
        trustedRSV = IRSV(newTrustedRSV);
    }

    function forwardTransfer(
        bytes calldata sig,
        address from,
        address to,
        uint256 amount,
        uint256 fee
    )
        external
    {

        bytes32 hash = keccak256(abi.encodePacked(
            address(trustedRSV),
            "forwardTransfer",
            from,
            to,
            amount,
            fee,
            nonce[from]
        ));
        nonce[from]++;

        address recoveredSigner = _recoverSignerAddress(hash, sig);
        require(recoveredSigner == from, "invalid signature");

        _takeFee(from, fee);

        require(
            trustedRSV.relayTransfer(from, to, amount), 
            "Reserve.sol relayTransfer failed"
        );
        emit TransferForwarded(sig, from, to, amount, fee);
    }

    function forwardApprove(
        bytes calldata sig,
        address holder,
        address spender,
        uint256 amount,
        uint256 fee
    )
        external
    {

        bytes32 hash = keccak256(abi.encodePacked(
            address(trustedRSV),
            "forwardApprove",
            holder,
            spender,
            amount,
            fee,
            nonce[holder]
        ));
        nonce[holder]++;

        address recoveredSigner = _recoverSignerAddress(hash, sig);
        require(recoveredSigner == holder, "invalid signature");

        _takeFee(holder, fee);

        require(
            trustedRSV.relayApprove(holder, spender, amount), 
            "Reserve.sol relayApprove failed"
        );
        emit ApproveForwarded(sig, holder, spender, amount, fee);
    }

    function forwardTransferFrom(
        bytes calldata sig,
        address holder,
        address spender,
        address to,
        uint256 amount,
        uint256 fee
    )
        external
    {

        bytes32 hash = keccak256(abi.encodePacked(
            address(trustedRSV),
            "forwardTransferFrom",
            holder,
            spender,
            to,
            amount,
            fee,
            nonce[spender]
        ));
        nonce[spender]++;

        address recoveredSigner = _recoverSignerAddress(hash, sig);
        require(recoveredSigner == spender, "invalid signature");

        _takeFee(spender, fee);

        require(
            trustedRSV.relayTransferFrom(holder, spender, to, amount), 
            "Reserve.sol relayTransfer failed"
        );
        emit TransferFromForwarded(sig, holder, spender, to, amount, fee);
    }

    function _recoverSignerAddress(bytes32 hash, bytes memory sig)
        internal pure
        returns (address)
    {

        bytes32 ethMessageHash = ECDSA.toEthSignedMessageHash(hash);
        return ECDSA.recover(ethMessageHash, sig);
    }

    function _takeFee(address payer, uint256 fee) internal {

        if (fee != 0) {
            require(trustedRSV.relayTransfer(payer, msg.sender, fee), "fee transfer failed");
            emit FeeTaken(payer, msg.sender, fee);
        }
    }

}