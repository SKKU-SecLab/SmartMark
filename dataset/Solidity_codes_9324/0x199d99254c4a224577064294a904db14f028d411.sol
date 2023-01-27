pragma solidity ^0.5.8;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.8;


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath#mul: OVERFLOW");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath#sub: UNDERFLOW");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath#add: OVERFLOW");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
        return a % b;
    }


}pragma solidity ^0.5.8;
contract ReentrancyGuard {

    bool private _notEntered;
    constructor () internal {
        _notEntered = true;
    }
    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}pragma solidity ^0.5.8;

library TransferHelper {


    function safeTransfer(address token, address to, uint value) internal returns (bool){

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal returns (bool){

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }
}pragma solidity ^0.5.8;

contract IWithdraw {

    event WithdrawEvent(address indexed user, uint256 indexed amount, uint256 indexed nonce);
    event DrawEvent(address indexed user, uint256 indexed amount);

    function verifySign(uint256 amount, uint256 nonce, address userAddr, bytes memory signature) public view returns (bool);

    function withdraw(uint256 amount, uint256 nonce, bytes memory signature) public returns (bool);


}// MIT

pragma solidity ^0.5.8;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {

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

        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
    }
}
pragma solidity ^0.5.8;


contract Owned {

    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Withdraw is IWithdraw, ReentrancyGuard, Owned {

    IERC20 private tokenAddr;
    using TransferHelper for address;
    using SafeMath for uint256;
    using ECDSA for bytes32;
    string public name;
    bool public stop_status = false;

    mapping(uint256 => bool) usedNonce;

    modifier withdraw_status {

        require(stop_status == false, "WITHDRAW:STOP");
        _;
    }

    constructor(address _tokenAddr, address _owner) public {
        tokenAddr = IERC20(_tokenAddr);
        name = "ADAO-WITHDRAW";
        owner = _owner;
    }

    function verifySign(
        uint256 amount,
        uint256 nonce,
        address userAddr,
        bytes memory signature
    ) public view returns (bool) {

        address recoverAddr =
            keccak256(abi.encode(userAddr, amount, nonce, this))
                .toEthSignedMessageHash()
                .recover(signature);
        require(recoverAddr == owner, "WITHDRAW:SIGN_FAILURE");
        require(!usedNonce[nonce], "WITHDRAW:NONCE_USED");
        return true;
    }

    function withdraw(
        uint256 amount,
        uint256 nonce,
        bytes memory signature
    ) public nonReentrant withdraw_status returns (bool) {

        verifySign(amount, nonce, msg.sender, signature);
        usedNonce[nonce] = true;
        require(
            address(tokenAddr).safeTransfer(msg.sender, amount),
            "WITHDRAW:INSUFFICIENT_CONTRACT_BALANCE"
        );
        emit WithdrawEvent(msg.sender, amount, nonce);
        return true;
    }

    function stop() public nonReentrant onlyOwner {

        stop_status = true;
    }

    function draw(uint256 amount, address toAddr)
        public
        nonReentrant
        onlyOwner
    {

        require(
            address(tokenAddr).safeTransfer(toAddr, amount),
            "WITHDRAW:INSUFFICIENT_CONTRACT_BALANCE"
        );
        emit DrawEvent(toAddr, amount);
    }
}
