





pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity ^0.8.0;


interface MooncatMinter {

   function ownerOf(uint256 _tokenId) external returns (address);

   function balanceOf(address owner) external view returns (uint256);

   function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


}
interface ToshimonMinter{

  function mint(
    address _to,
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
  ) external;

}
interface ToshiCash {

   function burn(address from, uint256 value) external;

}

contract toshiMooncatMinter {

    using SafeMath for uint256;
    ToshimonMinter toshimonMinter = ToshimonMinter(0xd2d2a84f0eB587F70E181A0C4B252c2c053f80cB);
    MooncatMinter mooncatMinter = MooncatMinter(0xc3f733ca98E0daD0386979Eb96fb1722A1A05E69);
    ToshiCash toshicash = ToshiCash(0xb6E0b9eDc711c89B9259E5ff04AF48255C500Ead);
    mapping(uint256 => bool) hasMintied;
    address payable internal multisig = payable(0xA447cC3336E86BaDfA39D117fe916a48B664b89b);

    constructor() {
    }

    function mintMooncat(uint256 _id) public {

        require(msg.sender == mooncatMinter.ownerOf(_id), "you dont own this kitty");
        require(!hasMintied[_id], "this kitty was already used to mint a toshimon mooncat");
        hasMintied[_id] = true;
        toshimonMinter.mint(msg.sender, 322, 1, "");
    }
    function mintMooncatToshicash() public {

        toshicash.burn(msg.sender, 100000 * 10 ** 18);
        toshimonMinter.mint(msg.sender, 322, 1, "");
    }
    function mintCudl(uint256 _quan) public payable{

        require(msg.value == _quan * 10 ** 17, "cost is 0.1 ETH per cudl");
        toshimonMinter.mint(msg.sender, 323, _quan, "");
    }
    function withdraw() public{

        (bool success, ) = multisig.call{value: address(this).balance}("");
        require(success, "ETH Transfer failed.");
    }
    function nextCat(address _owner) public view returns (uint256){

        uint256 bal = mooncatMinter.balanceOf(_owner);
        for(uint256 i = 0; i < bal; i++){
            uint256 tokenId = mooncatMinter.tokenOfOwnerByIndex(_owner, i);
            if(!hasMintied[tokenId]){
                return tokenId;
            }
        }
        return 100000;

    }
}