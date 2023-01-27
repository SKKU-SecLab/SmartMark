
pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// Unlicensed
pragma solidity ^0.8.7;


interface iBLONKStraits {

	function calculateTraitsArray(uint256 _tokenEntropy)
		external
		view
		returns (uint8[11] memory);


  function calculateTraitsJSON(uint8[11] memory _traitsArray)
  	external
		view
		returns (string memory);

}

interface iBLONKSlocations {

	function calculateLocatsArray(uint256 _ownerEntropy, uint256 _tokenEntropy, uint8[11] memory _traitsArray)
		external
		view
		returns (uint16[110] memory);

}

interface iBLONKSsvg {

	function assembleSVG(uint256 _ownerEntropy, uint256 _tokenEntropy, uint8[11] memory _traitsArray, uint16[110] memory _locatsArray)
		external
		view
		returns (string memory);

}

contract BLONKSuri is Ownable {

  using Counters for Counters.Counter;
  using Strings for string;

  address public traitsContract;
  address public locationsContract;
  address public svgContract;
  bool public cruncherContractsLocked = false;

  function buildMetaPart(uint256 _tokenId, string memory _description, address _artistAddy, uint256 _royaltyBps, string memory _collection, string memory _website, string memory _externalURL)
    external
    view
    virtual
    returns (string memory)
  {

    string memory metaP = string(abi.encodePacked('{"name":"BLONK #',Strings.toString(_tokenId),'","artist":"Matto","description":"',
    _description,'","royaltyInfo":{"artistAddress":"',Strings.toHexString(uint160(_artistAddy), 20),'","royaltyFeeByID":',Strings.toString(_royaltyBps/100),'},"collection_name":"',
    _collection,'","website":"',_website,'","external_url":"',_externalURL,'","script_type":"Solidity","image_type":"Generative SVG","image":"data:image/svg+xml;base64,'));
    return metaP;
  }

  function buildContractURI(string memory _description, string memory _externalURL, uint256 _royaltyBps, address _artistAddy, string memory _svg)
    external
    view
    virtual
    returns (string memory)
  {
    string memory b64svg = Base64.encode(bytes(_svg)); 
    string memory contractURI = string(abi.encodePacked('{"name":"BLONKS","description":"',_description,'","image":"data:image/svg+xml;base64,',b64svg,
    '","external_link":"',_externalURL,'","seller_fee_basis_points":',Strings.toString(_royaltyBps),',"fee_recipient":"',Strings.toHexString(uint160(_artistAddy), 20),'"}'));
    return contractURI;
  }

  function getLegibleTokenURI(string memory _metaP, uint256 _tokenEntropy, uint256 _ownerEntropy)
    external
    view
    virtual
    returns (string memory)
  {
    uint8[11] memory traitsArray = iBLONKStraits(traitsContract).calculateTraitsArray(_tokenEntropy);
    _tokenEntropy /= 10 ** 18;
    string memory traitsJSON = iBLONKStraits(traitsContract).calculateTraitsJSON(traitsArray);
    uint16[110] memory locatsArray = iBLONKSlocations(locationsContract).calculateLocatsArray(_ownerEntropy, _tokenEntropy, traitsArray);
    _ownerEntropy /= 10 ** 29;
    _tokenEntropy /= 10 ** 15;
    string memory svg = iBLONKSsvg(svgContract).assembleSVG(_ownerEntropy, _tokenEntropy, traitsArray, locatsArray);
    string memory legibleURI = string(abi.encodePacked(_metaP,Base64.encode(bytes(svg)),'",',traitsJSON,'}'));
    return legibleURI;
  }  

  function buildPreviewSVG(uint256 _tokenEntropy, uint256 _addressEntropy)
    external
    view
    virtual
    returns (string memory)
  {

    uint8[11] memory traitsArray = iBLONKStraits(traitsContract).calculateTraitsArray(_tokenEntropy);
    _tokenEntropy /= 10 ** 18;
    uint16[110] memory locatsArray = iBLONKSlocations(locationsContract).calculateLocatsArray(_addressEntropy, _tokenEntropy, traitsArray);
    _addressEntropy /= 10 ** 29;
    _tokenEntropy /= 10 ** 15;
    string memory resultSVG = iBLONKSsvg(svgContract).assembleSVG(_addressEntropy, _tokenEntropy, traitsArray, locatsArray);
    return resultSVG;
  }

  function getBase64TokenURI(string memory _legibleURI)
    external
    view
    virtual
    returns (string memory)
  {

    string memory URIBase64 = string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(_legibleURI))));
    return URIBase64;
  }

  function updateSVGContract(address _svgContract)
		external 
		onlyOwner 
	{

    require(cruncherContractsLocked == false, "Contracts locked");
    svgContract = _svgContract;
  }

	function updateTraitsContract(address _traitsContract)
		external 
		onlyOwner 
	{

    require(cruncherContractsLocked == false, "Contracts locked");
    traitsContract = _traitsContract;
  }

	function updateLocationsContract(address _locationsContract)
		external 
		onlyOwner 
	{

    require(cruncherContractsLocked == false, "Contracts locked");
    locationsContract = _locationsContract;
  }

  function DANGER_LockCruncherContracts()
    external
    payable
    onlyOwner
  {

    cruncherContractsLocked = true;
  }
}

library Base64 {

    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 len = data.length;
        if (len == 0) return "";
        uint256 encodedLen = 4 * ((len + 2) / 3);
        bytes memory result = new bytes(encodedLen + 32);
        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)
                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)
                mstore(resultPtr, out)
                resultPtr := add(resultPtr, 4)
            }
            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            mstore(result, encodedLen)
        }
        return string(result);
    }
}