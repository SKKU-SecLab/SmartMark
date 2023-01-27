

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

    function balanceOf(address _owner) external view returns (uint256);

}

contract ClaimWearable {

    using SafeMath for uint256;
    
    uint256 public maxSenderBalance;
    address public owner;

    event ClaimedNFT(
        address indexed _caller,
        address indexed _erc721Collection,
        string _wearable
    );
    
    constructor(uint256 _maxSenderBalance) public {
        maxSenderBalance = _maxSenderBalance;
        owner = msg.sender;
    }
    
    function changeMaxSenderBalance(uint256 _maxSenderBalance) external {

        require(msg.sender == owner, "Unauthorized sender");
        maxSenderBalance = _maxSenderBalance;
    }

    function claimNFT(ERC721Collection _erc721Collection, string calldata _wearableId) external payable {

        require(_erc721Collection.balanceOf(msg.sender) < maxSenderBalance, "The sender has already reached maxSenderBalance");
        require(
            canMint(_erc721Collection, _wearableId, 1),
            "The amount of wearables to issue is higher than its available supply"
        );

        _erc721Collection.issueToken(msg.sender, _wearableId);

        emit ClaimedNFT(msg.sender, address(_erc721Collection), _wearableId);
    }

    function canMint(ERC721Collection _erc721Collection, string memory _wearableId, uint256 _amount) public view returns (bool) {

        uint256 balance = balanceOf(_erc721Collection, _wearableId);

        return balance >= _amount;
    }

    function balanceOf(ERC721Collection _erc721Collection, string memory _wearableId) public view returns (uint256) {

        bytes32 wearableKey = _erc721Collection.getWearableKey(_wearableId);

        uint256 issued = _erc721Collection.issued(wearableKey);
        uint256 maxIssuance = _erc721Collection.maxIssuance(wearableKey);

        return maxIssuance.sub(issued);
    }
}