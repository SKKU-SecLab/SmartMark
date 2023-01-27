
pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IWhitelist {

    event Whitelisted(bytes4 indexed key);

    function addBytes4(bytes4 key) external;

    function addManyBytes4(bytes4[] memory keys) external;

    function isBytesWhitelisted(bytes memory subdomain) external view returns (bool);

}

contract EmojiWhitelist is Ownable, IWhitelist {

    mapping (bytes4 => bool) whitelist;

    function addBytes4(bytes4 key) public override onlyOwner {

      addBytes4Internal(key);
    }

    function addManyBytes4(bytes4[] memory keys) public override onlyOwner {

      for (uint i = 0; i < keys.length; i++) {
        addBytes4Internal(keys[i]);
      }
    }

    function isBytesWhitelisted(bytes memory subdomain) public override view returns (bool) {

      for(uint i = 0; i < subdomain.length; i += 4) {
        if(!whitelist[(toBytes4(slice(subdomain, i, 4)))]) {
          return false;
        }
      }
      return true;
    }


    function addBytes4Internal(bytes4 key) internal {

      whitelist[key] = true;
      emit Whitelisted(key);
    }

    function toBytes4(bytes memory _b) internal pure returns (bytes4 result) {

      assembly {
        result := mload(add(_b, 32))
      }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }
}