



pragma solidity ^0.4.24;

contract Owned {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner, "Not owner");
        _;
    }

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    address public newOwner;

    function transferOwner(address _newOwner) public onlyOwner {

        require(_newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function changeOwner(address _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }

    function renounceOwnership() public onlyOwner {

        owner = address(0);
    }
}




pragma solidity ^0.4.24;


contract Halt is Owned {


    bool public halted = false;

    modifier notHalted() {

        require(!halted, "Smart contract is halted");
        _;
    }

    modifier isHalted() {

        require(halted, "Smart contract is not halted");
        _;
    }

    function setHalt(bool halt)
        public
        onlyOwner
    {

        halted = halt;
    }
}




pragma solidity 0.4.26;

interface ISignatureVerifier {

  function verify(
        uint curveId,
        bytes32 signature,
        bytes32 groupKeyX,
        bytes32 groupKeyY,
        bytes32 randomPointX,
        bytes32 randomPointY,
        bytes32 message
    ) external returns (bool);

}


pragma solidity ^0.4.24;



interface IBaseSignVerifier {

    function verify(
        bytes32 signature,
        bytes32 groupKeyX,
        bytes32 groupKeyY,
        bytes32 randomPointX,
        bytes32 randomPointY,
        bytes32 message
    ) external returns (bool);

}

contract SignatureVerifier is Halt {


    mapping(uint256 => address) public verifierMap;

    function verify(
        uint256 curveId,
        bytes32 signature,
        bytes32 groupKeyX,
        bytes32 groupKeyY,
        bytes32 randomPointX,
        bytes32 randomPointY,
        bytes32 message
    ) external returns (bool) {

        require(verifierMap[curveId] != address(0), "curveId not correct");
        IBaseSignVerifier verifier = IBaseSignVerifier(verifierMap[curveId]);
        return verifier.verify(signature, groupKeyX, groupKeyY, randomPointX, randomPointY, message);
    }

    function register(uint256 curveId, address verifierAddress) external onlyOwner {

        verifierMap[curveId] = verifierAddress;
    }
}