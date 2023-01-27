
pragma solidity ^0.7.0;

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

contract Bet {

  address public participantA = address(0xd693A6610842E83e500a0521409dE7164d8b1B59);
  address public participantB = address(0x8E494275dEf32777228cd9ADc315aF5eb5131038);
  address public arbitor = address(0x597ec75f3b26E2F8141940aeF5439665959b8Efd);

  address public winner = address(0x0);

  receive() external payable {}
  fallback() external payable {}

  function tokenFallback (address from, uint value, bytes memory data) external {}

  function getSignaturePreimage(
    address winnerAddress
  ) public view returns (
    bytes memory
  ){


    return abi.encode(
      winnerAddress,
      this
    );
  }

  function setWinner(
    address winnerAddress,
    bytes memory countersignature
  ) external {

    address countersigner = ECDSA.recover(
      ECDSA.toEthSignedMessageHash(
        keccak256(
          getSignaturePreimage(winnerAddress)
        )
      ),
      countersignature
    );


    if (msg.sender == participantA) {
      require(countersigner == participantB || countersigner == arbitor);
    } else if (msg.sender == participantB) {
      require(countersigner == participantA || countersigner == arbitor);
    } else {
      revert();
    }

    winner = winnerAddress;
  }

  function transferEth(
    address payable to,
    uint256 amount
  ) external {

    require(msg.sender == winner);

    to.transfer(amount);
  }

  function transferToken(
    address to,
    uint256 amount,
    address tokenContractAddress
  ) external {

    require(msg.sender == winner);

    IERC20(tokenContractAddress).transfer(to, amount);
  }
}