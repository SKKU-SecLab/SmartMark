
pragma solidity ^0.5.16;


library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(a >= b, "Math error");
        return a - b;
    }

}

interface ERC20 {

    function balanceOf(address _address) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract BhxManage {


    address public owner;
    address public owner2;
    mapping (bytes32 => bool) public signHash;
    address public bhx;
    address public usdt;
    bytes4 private constant TRANSFER = bytes4(
        keccak256(bytes("transfer(address,uint256)"))
    );

    constructor(address _owner2, address _bhx, address _usdt) public {
        owner = msg.sender;
        owner2 = _owner2;
        bhx = _bhx;
        usdt = _usdt;
    }



    modifier onlyOwner() {

        require(owner == msg.sender, "You are not owner");
        _;
    }

    function setOwner(address _owner) public onlyOwner returns (bool success) {

        require(_owner != address(0), "Zero address error");
        owner = _owner;
        success = true;
    }

    function setOwner2(address _owner2) public onlyOwner returns (bool success) {

        require(_owner2 != address(0), "Zero address error");
        owner2 = _owner2;
        success = true;
    }

    function takeErc20(address _erc20Address) public onlyOwner returns (bool success2) {

        require(_erc20Address != address(0), "Zero address error");
        ERC20 erc20 = ERC20(_erc20Address);
        uint256 _value = erc20.balanceOf(address(this));
        (bool success, ) = address(_erc20Address).call(
            abi.encodeWithSelector(TRANSFER, msg.sender, _value)
        );
        if(!success) {
            revert("Transfer is fail");
        }
        success2 = true;
    }

    function backendTransferBhx(address _to, uint256 _value, uint256 _nonce, bytes memory _signature) public returns (bool success2) {

        require(_to != address(0), "Zero address error");
        ERC20 bhxErc20 = ERC20(bhx);
        uint256 bhxBalance = bhxErc20.balanceOf(address(this));
        require(bhxBalance >= _value && _value > 0, "Insufficient balance or zero amount");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, _to, _value, _nonce));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        address signer = recoverSigner(messageHash, _signature);
        require(signer == owner2, "Signer is not owner2");
        require(signHash[messageHash] == false, "MessageHash is used");
        signHash[messageHash] = true;

        (bool success, ) = address(bhx).call(
            abi.encodeWithSelector(TRANSFER, _to, _value)
        );
        if(!success) {
            revert("Transfer is fail");
        }
        success2 = true;
    }

    function backendTransferUsdt(address _to, uint256 _value, uint256 _nonce, bytes memory _signature) public returns (bool success2) {

        require(_to != address(0), "Zero address error");
        ERC20 usdtErc20 = ERC20(usdt);
        uint256 usdtBalance = usdtErc20.balanceOf(address(this));
        require(usdtBalance >= _value && _value > 0, "Insufficient balance or zero amount");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, _to, _value, _nonce));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        address signer = recoverSigner(messageHash, _signature);
        require(signer == owner2, "Signer is not owner2");
        require(signHash[messageHash] == false, "MessageHash is used");
        signHash[messageHash] = true;

        (bool success, ) = address(usdt).call(
            abi.encodeWithSelector(TRANSFER, _to, _value)
        );
        if(!success) {
            revert("Transfer is fail");
        }
        success2 = true;
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {

        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

}