pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;


contract GenArt721Minter_DoodleLabs_Whitelist {

    using SafeMath for uint256;

    event AddWhitelist();
    event AddMinterWhitelist(address minterAddress);
    event RemoveMinterWhitelist(address minterAddress);

    IGenArt721CoreV2 genArtCoreContract;
    mapping(address => bool) public minterWhitelist;
    mapping(uint256 => mapping(address => uint256)) public whitelist;

    modifier onlyWhitelisted() {

        require(genArtCoreContract.isWhitelisted(msg.sender), "can only be set by admin");
        _;
    }

    modifier onlyMintWhitelisted() {

        require(minterWhitelist[msg.sender], "only callable by minter");
        _;
    }

    constructor(address _genArtCore, address _minterAddress) public {
        genArtCoreContract = IGenArt721CoreV2(_genArtCore);
        minterWhitelist[_minterAddress] = true;
    }

    function addMinterWhitelist(address _minterAddress) public onlyWhitelisted {

        minterWhitelist[_minterAddress] = true;
        emit AddMinterWhitelist(_minterAddress);
    }

    function removeMinterWhitelist(address _minterAddress) public onlyWhitelisted {

        minterWhitelist[_minterAddress] = false;
        emit RemoveMinterWhitelist(_minterAddress);
    }

    function getWhitelisted(uint256 projectId, address user) external view returns (uint256 amount) {

        return whitelist[projectId][user];
    }

    function addWhitelist(uint256 projectId, address[] memory users, uint256[] memory amounts) public onlyWhitelisted {

        require(users.length == amounts.length, 'users amounts array mismatch');

        for (uint i = 0; i < users.length; i++) {
            whitelist[projectId][users[i]] = amounts[i];
        }
        emit AddWhitelist();
    }

    function decreaseAmount(uint256 projectId, address to) public onlyMintWhitelisted {

        require(whitelist[projectId][to] > 0, "user has nothing to redeem");
        whitelist[projectId][to] = whitelist[projectId][to].sub(1);
    }

}