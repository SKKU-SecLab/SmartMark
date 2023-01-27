

pragma solidity 0.5.14;

contract AvastarTypes {


    enum Generation {
        ONE,
        TWO,
        THREE,
        FOUR,
        FIVE
    }

    enum Series {
        PROMO,
        ONE,
        TWO,
        THREE,
        FOUR,
        FIVE
    }

    enum Wave {
        PRIME,
        REPLICANT
    }

    enum Gene {
        SKIN_TONE,
        HAIR_COLOR,
        EYE_COLOR,
        BG_COLOR,
        BACKDROP,
        EARS,
        FACE,
        NOSE,
        MOUTH,
        FACIAL_FEATURE,
        EYES,
        HAIR_STYLE
    }

    enum Gender {
        ANY,
        MALE,
        FEMALE
    }

    enum Rarity {
        COMMON,
        UNCOMMON,
        RARE,
        EPIC,
        LEGENDARY
    }

    struct Trait {
        uint256 id;
        Generation generation;
        Gender gender;
        Gene gene;
        Rarity rarity;
        uint8 variation;
        Series[] series;
        string name;
        string svg;

    }

    struct Prime {
        uint256 id;
        uint256 serial;
        uint256 traits;
        bool[12] replicated;
        Generation generation;
        Series series;
        Gender gender;
        uint8 ranking;
    }

    struct Replicant {
        uint256 id;
        uint256 serial;
        uint256 traits;
        Generation generation;
        Gender gender;
        uint8 ranking;
    }

    struct Avastar {
        uint256 id;
        uint256 serial;
        uint256 traits;
        Generation generation;
        Wave wave;
    }

    struct Attribution {
        Generation generation;
        string artist;
        string infoURI;
    }

}


pragma solidity 0.5.14;


contract IAvastarTeleporter is AvastarTypes {


    function isAvastarTeleporter() external pure returns (bool);


    function tokenURI(uint _tokenId)
    external view
    returns (string memory uri);


    function getAvastarWaveByTokenId(uint256 _tokenId)
    external view
    returns (Wave wave);


    function getPrimeByTokenId(uint256 _tokenId)
    external view
    returns (
        uint256 tokenId,
        uint256 serial,
        uint256 traits,
        Generation generation,
        Series series,
        Gender gender,
        uint8 ranking
    );


    function getReplicantByTokenId(uint256 _tokenId)
    external view
    returns (
        uint256 tokenId,
        uint256 serial,
        uint256 traits,
        Generation generation,
        Gender gender,
        uint8 ranking
    );


    function getTraitInfoById(uint256 _traitId)
    external view
    returns (
        uint256 id,
        Generation generation,
        Series[] memory series,
        Gender gender,
        Gene gene,
        Rarity rarity,
        uint8 variation,
        string memory name
    );



    function getTraitNameById(uint256 _traitId)
    external view
    returns (string memory name);


    function getTraitIdByGenerationGeneAndVariation(
        Generation _generation,
        Gene _gene,
        uint8 _variation
    )
    external view
    returns (uint256 traitId);


    function getAttributionByGeneration(Generation _generation)
    external view
    returns (
        string memory attribution
    );


    function mintPrime(
        address _owner,
        uint256 _traits,
        Generation _generation,
        Series _series,
        Gender _gender,
        uint8 _ranking
    )
    external
    returns (uint256, uint256);


    function mintReplicant(
        address _owner,
        uint256 _traits,
        Generation _generation,
        Gender _gender,
        uint8 _ranking
    )
    external
    returns (uint256, uint256);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function totalSupply() public view returns (uint256 count);

}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


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
}


pragma solidity 0.5.14;



contract AccessControl {


    using SafeMath for uint256;
    using SafeMath for uint16;
    using Roles for Roles.Role;

    Roles.Role private admins;
    Roles.Role private minters;
    Roles.Role private owners;

    constructor() public {
        admins.add(msg.sender);
    }

    event ContractPaused();

    event ContractUnpaused();

    event ContractUpgrade(address newContract);


    bool public paused = true;
    bool public upgraded = false;
    address public newContractAddress;

    modifier onlyMinter() {

        require(minters.has(msg.sender));
        _;
    }

    modifier onlyOwner() {

        require(owners.has(msg.sender));
        _;
    }

    modifier onlySysAdmin() {

        require(admins.has(msg.sender));
        _;
    }

    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused() {

        require(paused);
        _;
    }

    modifier whenNotUpgraded() {

        require(!upgraded);
        _;
    }

    function upgradeContract(address _newAddress) external onlySysAdmin whenPaused whenNotUpgraded {

        require(_newAddress != address(0));
        upgraded = true;
        newContractAddress = _newAddress;
        emit ContractUpgrade(_newAddress);
    }

    function addMinter(address _minterAddress) external onlySysAdmin {

        minters.add(_minterAddress);
        require(minters.has(_minterAddress));
    }

    function addOwner(address _ownerAddress) external onlySysAdmin {

        owners.add(_ownerAddress);
        require(owners.has(_ownerAddress));
    }

    function addSysAdmin(address _sysAdminAddress) external onlySysAdmin {

        admins.add(_sysAdminAddress);
        require(admins.has(_sysAdminAddress));
    }

    function stripRoles(address _address) external onlyOwner {

        require(msg.sender != _address);
        bool stripped = false;
        if (admins.has(_address)) {
            admins.remove(_address);
            stripped = true;
        }
        if (minters.has(_address)) {
            minters.remove(_address);
            stripped = true;
        }
        if (owners.has(_address)) {
            owners.remove(_address);
            stripped = true;
        }
        require(stripped == true);
    }

    function pause() external onlySysAdmin whenNotPaused {

        paused = true;
        emit ContractPaused();
    }

    function unpause() external onlySysAdmin whenPaused whenNotUpgraded {

        paused = false;
        emit ContractUnpaused();
    }

}


pragma solidity 0.5.14;




contract AvastarPrimeMinter is AvastarTypes, AccessControl {


    event CurrentGenerationSet(Generation currentGeneration);

    event CurrentSeriesSet(Series currentSeries);

    event DepositorBalance(address indexed depositor, uint256 balance);

    event FranchiseBalanceWithdrawn(address indexed owner, uint256 amount);

    event TeleporterContractSet(address contractAddress);

    IAvastarTeleporter private teleporterContract ;

    Generation private currentGeneration;

    Series private currentSeries;

    mapping (address => uint256) private depositsByAddress;

    uint256 private unspentDeposits;

    function setTeleporterContract(address _address) external onlySysAdmin whenPaused whenNotUpgraded {


        IAvastarTeleporter candidateContract = IAvastarTeleporter(_address);

        require(candidateContract.isAvastarTeleporter());

        teleporterContract = IAvastarTeleporter(_address);

        emit TeleporterContractSet(_address);
    }

    function setCurrentGeneration(Generation _generation) external onlySysAdmin whenPaused whenNotUpgraded {

        currentGeneration = _generation;
        emit CurrentGenerationSet(currentGeneration);
        setCurrentSeries(Series.ONE);
    }

    function setCurrentSeries(Series _series) public onlySysAdmin whenPaused whenNotUpgraded {

        currentSeries = _series;
        emit CurrentSeriesSet(currentSeries);
    }

    function checkFranchiseBalance() external view onlyOwner returns (uint256 franchiseBalance) {

        return uint256(address(this).balance).sub(unspentDeposits);
    }

    function withdrawFranchiseBalance() external onlyOwner returns (uint256 amountWithdrawn) {

        uint256 franchiseBalance = uint256(address(this).balance).sub(unspentDeposits);
        require(franchiseBalance > 0);
        msg.sender.transfer(franchiseBalance);
        emit FranchiseBalanceWithdrawn(msg.sender, franchiseBalance);
        return franchiseBalance;
    }

    function deposit() external payable whenNotPaused {

        require(msg.value > 0);
        depositsByAddress[msg.sender] = depositsByAddress[msg.sender].add(msg.value);
        unspentDeposits = unspentDeposits.add(msg.value);
        emit DepositorBalance(msg.sender, depositsByAddress[msg.sender]);
    }

    function checkDepositorBalance() external view returns (uint256){

        return depositsByAddress[msg.sender];
    }

    function withdrawDepositorBalance() external returns (uint256 amountWithdrawn) {

        uint256 depositorBalance = depositsByAddress[msg.sender];
        require(depositorBalance > 0 && address(this).balance >= depositorBalance);
        depositsByAddress[msg.sender] = 0;
        unspentDeposits = unspentDeposits.sub(depositorBalance);
        msg.sender.transfer(depositorBalance);
        emit DepositorBalance(msg.sender, 0);
        return depositorBalance;
    }

    function purchasePrime(
        address _purchaser,
        uint256 _price,
        uint256 _traits,
        Gender _gender,
        uint8 _ranking
    )
    external
    onlyMinter
    whenNotPaused
    returns (uint256 tokenId, uint256 serial)
    {

        require(_purchaser != address(0));
        require (depositsByAddress[_purchaser] >= _price);
        require(_gender > Gender.ANY);
        depositsByAddress[_purchaser] = depositsByAddress[_purchaser].sub(_price);
        unspentDeposits = unspentDeposits.sub(_price);
        (tokenId, serial) = teleporterContract.mintPrime(_purchaser, _traits, currentGeneration, currentSeries, _gender, _ranking);
        emit DepositorBalance(_purchaser, depositsByAddress[_purchaser]);
        return (tokenId, serial);
    }

}