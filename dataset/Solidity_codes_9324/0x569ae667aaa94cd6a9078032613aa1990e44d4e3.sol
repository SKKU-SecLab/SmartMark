pragma solidity ^0.5.0;

interface IGenArt721CoreV2 {

  function isWhitelisted(address sender) external view returns (bool);

  function admin() external view returns(address);

  function projectIdToCurrencySymbol(uint256 _projectId) external view returns (string memory);

  function projectIdToCurrencyAddress(uint256 _projectId) external view returns (address);

  function projectIdToArtistAddress(uint256 _projectId) external view returns (address payable);

  function projectIdToPricePerTokenInWei(uint256 _projectId) external view returns (uint256);

  function projectIdToAdditionalPayee(uint256 _projectId) external view returns (address payable);

  function projectIdToAdditionalPayeePercentage(uint256 _projectId) external view returns (uint256);

  function projectTokenInfo(uint256 _projectId) external view returns (address, uint256, uint256, uint256, bool, address, uint256, string memory, address);

  function renderProviderAddress() external view returns (address payable);

  function renderProviderPercentage() external view returns (uint256);

  function mint(address _to, uint256 _projectId, address _by) external returns (uint256 tokenId);

  function ownerOf(uint256 tokenId) external view returns (address);

  function tokenIdToProjectId(uint256 tokenId) external view returns(uint256);

}// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol
pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity ^0.5.0;


interface IRedeemableProduct {

    function getRecipientAddress() external view returns(address payable);

    function getTokenRedemptionCount(address genArtCoreAddress, uint256 tokenId) external view returns(uint256);

    function incrementRedemptionAmount(address redeemer, address genArtCoreAddress, uint256 tokenId, uint256 variationId) external;

    function getRedemptionAmount(address genArtCoreAddress, uint256 projectId) external view returns(uint256);

    function getVariationPriceInWei(address genArtCoreAddress, uint256 projectId, uint256 variationId) external view returns(uint256);

    function getVariationIsPaused(address genArtCoreAddress, uint256 projectId, uint256 variationId) external view returns(bool);

}

contract RedemptionService {

    using SafeMath for uint256;

    event AddRedemptionWhitelist(
        address indexed redeemableProductAddress
    );

    event RemoveRedemptionWhitelist(
        address indexed redeemableProductAddress
    );

    event Redeem(
        address genArtCoreAddress,
        address indexed redeemableProductAddress,
        uint256 projectId,
        uint256 indexed tokenId,
        uint256 redemptionCount,
        uint256 indexed variationId
    );

    IGenArt721CoreV2 public genArtCoreContract;

    mapping(address => bool) public isRedemptionWhitelisted;

    modifier onlyWhitelisted() {

        require(genArtCoreContract.isWhitelisted(msg.sender), "Only whitelisted");
        _;
    }

    constructor(address genArtCoreAddress) public {
        genArtCoreContract = IGenArt721CoreV2(genArtCoreAddress);
    }

    function addRedemptionWhitelist(address redeemableProductAddress) public onlyWhitelisted {

        isRedemptionWhitelisted[redeemableProductAddress] = true;
        emit AddRedemptionWhitelist(redeemableProductAddress);
    }

    function removeRedemptionWhitelist(address redeemableProductAddress) public onlyWhitelisted {

        isRedemptionWhitelisted[redeemableProductAddress] = false;
        emit RemoveRedemptionWhitelist(redeemableProductAddress);
    }

    function redeem(address genArtCoreAddress, address redeemableProductAddress, uint256 tokenId, uint256 variationId) public payable  {

        IRedeemableProduct redeemableProductContract = IRedeemableProduct(redeemableProductAddress);
        uint256 projectId = genArtCoreContract.tokenIdToProjectId(tokenId);
        uint256 redemptionCount = redeemableProductContract.getTokenRedemptionCount(genArtCoreAddress, tokenId);
        uint256 maxAmount = redeemableProductContract.getRedemptionAmount(genArtCoreAddress, projectId);
        uint256 priceInWei = redeemableProductContract.getVariationPriceInWei(genArtCoreAddress, projectId, variationId);
        address payable recipientAddress =  redeemableProductContract.getRecipientAddress();

        require(genArtCoreContract.ownerOf(tokenId) == msg.sender, 'user not the token owner');
        require(redemptionCount < maxAmount, 'token already redeemed');
        require(priceInWei == msg.value, 'not enough tokens transferred');
        require(redeemableProductContract.getVariationIsPaused(genArtCoreAddress, projectId, variationId) == false, 'product sale is paused');

        redeemableProductContract.incrementRedemptionAmount(msg.sender, genArtCoreAddress, tokenId, variationId);
        recipientAddress.transfer(msg.value);
        emit Redeem(genArtCoreAddress, redeemableProductAddress, projectId, tokenId, redemptionCount.add(1), variationId);
    }
}