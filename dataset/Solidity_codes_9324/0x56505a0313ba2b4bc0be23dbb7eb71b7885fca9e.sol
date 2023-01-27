

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.5.11;





interface ERC721Collection {

    function issueToken(address _beneficiary, string calldata _wearableId) external;

    function getWearableKey(string calldata _wearableId) external view returns (bytes32);

    function issued(bytes32 _wearableKey) external view returns (uint256);

    function maxIssuance(bytes32 _wearableKey) external view returns (uint256);

    function issueTokens(address[] calldata _beneficiaries, bytes32[] calldata _wearableIds) external;

}

contract Donation {

    using SafeMath for uint256;

    ERC721Collection public erc721Collection;

    address payable public fundsRecipient;

    uint256 public price;
    uint256 public maxNFTsPerCall;
    uint256 public donations;

    event DonatedForNFT(
        address indexed _caller,
        uint256 indexed _value,
        uint256 _issued,
        string _wearable
    );

    event Donated(address indexed _caller, uint256 indexed _value);

    constructor(
        address payable _fundsRecipient,
        ERC721Collection _erc721Collection,
        uint256 _price,
        uint256 _maxNFTsPerCall
      )
      public {
        fundsRecipient = _fundsRecipient;
        erc721Collection = _erc721Collection;
        price = _price;
        maxNFTsPerCall = _maxNFTsPerCall;
    }

    function donate() external payable {

        require(msg.value > 0, "The donation should be higher than 0");

        fundsRecipient.transfer(msg.value);

        donations += msg.value;

        emit Donated(msg.sender, msg.value);
    }

    function donateForNFT(string calldata _wearableId) external payable {

        uint256 NFTsToIssued = Math.min(msg.value / price, maxNFTsPerCall);

        require(NFTsToIssued > 0, "The donation should be higher or equal than the price");
        require(
            canMint(_wearableId, NFTsToIssued),
            "The amount of wearables to issue is higher than its available supply"
        );

        fundsRecipient.transfer(msg.value);

        donations += msg.value;

        for (uint256 i = 0; i < NFTsToIssued; i++) {
            erc721Collection.issueToken(msg.sender, _wearableId);
        }

        emit DonatedForNFT(msg.sender, msg.value, NFTsToIssued, _wearableId);
    }

    function canMint(string memory _wearableId, uint256 _amount) public view returns (bool) {

        uint256 balance = balanceOf(_wearableId);

        return balance >= _amount;
    }

    function balanceOf(string memory _wearableId) public view returns (uint256) {

        bytes32 wearableKey = erc721Collection.getWearableKey(_wearableId);

        uint256 issued = erc721Collection.issued(wearableKey);
        uint256 maxIssuance = erc721Collection.maxIssuance(wearableKey);

        return maxIssuance.sub(issued);
    }
}