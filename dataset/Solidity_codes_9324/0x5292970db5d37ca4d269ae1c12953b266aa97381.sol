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
}pragma solidity ^0.5.0;

interface IGenArt721CoreV2 {

  function isWhitelisted(address sender) external view returns (bool);

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

}pragma solidity ^0.5.0;


contract GenArt721Minter_DoodleLabs_Config {

    using SafeMath for uint256;

    event SetState(uint256 projectId, uint256 state);
    event SetPurchaseManyLimit(uint256 projectId, uint256 limit);

    enum SaleState {
        FAMILY_COLLECTORS,
        REDEMPTION,
        PUBLIC
    }

    IGenArt721CoreV2 public genArtCoreContract;

    mapping(uint256 => SaleState) public state;
    mapping(uint256 => uint256) public purchaseLimit;

    modifier onlyWhitelisted() {

        require(genArtCoreContract.isWhitelisted(msg.sender), "can only be set by admin");
        _;
    }

    constructor(address _genArt721Address) public {
        genArtCoreContract = IGenArt721CoreV2(_genArt721Address);
    }

    function getPurchaseManyLimit(uint256 projectId) view public returns (uint256 limit) {

        return purchaseLimit[projectId];
    }

    function getState(uint256 projectId) view public returns (uint256 _state) {

        return uint256(state[projectId]);
    }

    function setStateFamilyCollectors(uint256 projectId) public onlyWhitelisted {

        state[projectId] = SaleState.FAMILY_COLLECTORS;
        emit SetState(projectId, uint256(state[projectId]));
    }

    function setStateRedemption(uint256 projectId) public onlyWhitelisted {

        state[projectId] = SaleState.REDEMPTION;
        emit SetState(projectId, uint256(state[projectId]));
    }

    function setStatePublic(uint256 projectId) public onlyWhitelisted {

       state[projectId] = SaleState.PUBLIC;
       emit SetState(projectId, uint256(state[projectId]));
    }

    function setPurchaseManyLimit(uint256 projectId, uint256 limit) public onlyWhitelisted {

        purchaseLimit[projectId] = limit;
        emit SetPurchaseManyLimit(projectId, limit);
    }
}