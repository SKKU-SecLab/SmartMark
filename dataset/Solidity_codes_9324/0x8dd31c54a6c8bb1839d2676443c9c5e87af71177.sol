


pragma solidity ^0.8.4;

interface IKWWData { 

    struct KangarooDetails{
        uint64 birthTime;
        uint32 dadId;
        uint32 momId;
        uint32 coupleId;
        uint16 boatId;
	    uint16 landId;
		uint8 gen;
		uint8 status;
        uint8 bornState;
    }

    struct CoupleDetails{
        uint64 pregnancyStarted;
        uint8 babiesCounter;
        bool paidHospital;
        bool activePregnant;
    }

    function initKangaroo(uint32 tokenId, uint32 dadId, uint32 momId) external;

}


pragma solidity ^0.8.4;


interface IKWWGameManager{

    enum ContractTypes {KANGAROOS, BOATS, LANDS, VAULT, VAULT_ETH, DATA, MOVING_BOATS, VOTING}

    function getContract(uint8 _type) external view returns(address);

}

interface Vault{

    function depositToVault(address owner, uint256[] memory tokens, uint8 assetsType, bool frozen) external;

    function withdrawFromVault(address owner, uint256[] calldata tokenIds) external ;

    function setAssetFrozen(uint256 token, bool isFrozen) external ;

    function getHolder(uint256 tokenId) external view returns (address);

}

interface VaultEth{

    function depositBoatFees(uint16 totalSupply) external payable;

    function depositLandFees(uint16 landId) external payable;

    function boatAvailableToWithdraw(uint16 totalSupply, uint16 boatId) external view returns(uint256);

    function landAvailableToWithdraw(uint16 landId, uint8 ownerTypeId) external view returns(uint256);

    function withdrawBoatFees(uint16 totalSupply, uint16 boatId, address addr) external;

    function withdrawLandFees(uint16 landId, uint8 ownerTypeId, address addr) external;

}

interface KangarooData{

    function setCouple(uint32 male, uint32 female) external ;

    function kangarooMoveLand(uint32 tokenId, uint16 landId) external;

    function kangarooTookBoat(uint32 tokenId, uint16 boatId) external;

    function kangarooReachedIsland(uint32 tokenId) external ;

    function kangarooStartPregnancy(uint32 dadId, uint32 momId, bool hospital) external ;

    function birthKangaroos(uint32 dadId, uint32 momId, address ownerAddress) external ;

    function getBackAustralian(uint32 dadId, uint32 momId, uint16 boatId) external;

    function kangaroosArrivedContinent(uint32 dadId, uint32 momId) external;

    function getKangaroo(uint32 tokenId) external view returns(IKWWData.KangarooDetails memory);

    function isCouples(uint32 male, uint32 female) external view returns(bool);

    function getCouple(uint32 tokenId) external view returns(uint32);

    function getBabiesCounter(uint32 male, uint32 female) external view returns(uint8);

    function doneMaxBabies(uint32 male, uint32 female) external view returns(bool);

    function kangarooIsMale(uint32 tokenId) external pure returns(bool);

    function updateBoatId(uint32 tokenId, uint16 boatId) external;

    function getKangarooGen(uint32 tokenId) external view returns(uint8);

    function baseMaxBabiesAllowed(uint32 token) external view returns(uint8);

    function getStatus(uint32 tokenId) external view returns(uint8);

    function isBaby(uint32 tokenId) external view returns(bool);

    function getBornState(uint32 tokenId) external view returns(uint8);

    function couplesData(uint64 coupleId) external view returns(IKWWData.CoupleDetails memory);

}

interface MovingBoatsData{

    function startSail(uint8 boatState, bool direction) external;

    function getLastId() external view returns(uint256);

    function getKangaroos(uint16 tokenId) external view returns(uint32[] memory);

    function getBoatState(uint16 tokenId) external view returns(uint8);

    function getDirection(uint16 tokenId) external view returns(bool);

    function sailEnd(uint16 tokenId) external view returns(uint64);

}

interface Voting{

    function getBoatPrice(uint16 token) external view returns(uint256);

}

interface LandsData { 

    struct LandDetails{
        uint256 price;
		uint32 princeId;
        uint32 princessId;
    }

    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function getLandData(uint16 tokenId) external view returns(LandDetails memory);

    function getPrice(uint16 tokenId) external view returns(uint256);

    function getPrince(uint16 tokenId) external view returns(uint32);

    function getPrincess(uint16 tokenId) external view returns(uint32);

}


interface INFT{

    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

}








pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}



pragma solidity ^0.8.4;




contract KWWGameManager is IKWWGameManager, Ownable{

    event CoupleMovedLand(uint32 indexed _male, uint32 indexed _female, uint16 _landId);
    event CoupleStartedSailing(uint32 indexed _male, uint32 indexed _female, uint16 _boatId);
    event ArrivedIsland(uint32 indexed _male, uint32 indexed _female);
    event PregnancyStarted(uint32 indexed _male, uint32 indexed _female, bool isHospital);
    event BabiesBorn(uint32 indexed _male, uint32 indexed _female);
    event ArrivedContinent(uint32 indexed _male, uint32 indexed _female);
    event SailBackStarted(uint32 indexed _male, uint32 indexed _female, uint16 _boatId);


    mapping(uint8 => address) contracts;


    function coupleMoveLand(uint32 male, uint32 female, uint16 landId) public payable {

        require(isOwnerOrStaked(male, ContractTypes.KANGAROOS) && isOwnerOrStaked(female, ContractTypes.KANGAROOS), "Missing permissions - you're not the owner of one of the tokens");
        require(getLandNFT().ownerOf(landId) != address(0), "Land not Exists");
        require(!getData().isBaby(male) && !getData().isBaby(female), "One of the kangaroos is baby");
        require(getData().getBornState(male) == getData().getBornState(female),"Couple not from the same born state");
        require(getData().getKangarooGen(male) == getData().getKangarooGen(female),"Couple not from the same generation");
        require(getData().kangarooIsMale(male) == true && getData().kangarooIsMale(female) == false,"Couple genders mismatched");
        require(getLandNFT().getPrice(landId) <= msg.value, "Tax fee is too low");
        getVaultEth().depositLandFees{value:msg.value}(landId);
        getData().kangarooMoveLand(male, landId);
        getData().kangarooMoveLand(female, landId);
        emit CoupleMovedLand(male, female, landId);
    }

    function coupleStartJourney(uint32 male, uint32 female) public payable {

        require(isOwnerOrStaked(male, ContractTypes.KANGAROOS) && isOwnerOrStaked(female, ContractTypes.KANGAROOS), "Missing permissions - you're not the owner of one of the tokens");
        require(!getData().isBaby(male) && !getData().isBaby(female), "One of the kangaroos is baby");
        require(getData().getBornState(male) == getData().getBornState(female),"Couple not from the same born state");
        require(getData().getKangarooGen(male) == getData().getKangarooGen(female),"Couple not from the same generation");
        require(getData().kangarooIsMale(male) == true && getData().kangarooIsMale(female) == false,"Couple genders mismatched");
        require(getData().getStatus(male) == 0 && getData().getStatus(female) == 0, "Status doesn't fit this step");
        require(getData().getCouple(male) == 0 && getData().getCouple(female) == 0, "Can't change couple");
        require(getVoting().getBoatPrice(1) <= msg.value, "Renting fee is too low");
        getVaultEth().depositBoatFees{value:msg.value}(uint16(getBoatNFT().totalSupply()) - 1);
        uint32[] memory kangaroosArr = new uint32[](2);
        kangaroosArr[0] = male;
        kangaroosArr[1] = female;
        getMovingBoats().startSail(getData().getBornState(male), true);
        uint16 movingBoatId = uint16(getMovingBoats().getLastId());
        depositCouple(male, female, true);
        getData().setCouple(male, female);
        getData().kangarooTookBoat(male, movingBoatId);
        getData().kangarooTookBoat(female, movingBoatId);
        emit CoupleStartedSailing(male, female, movingBoatId);
    }

    function pregnancyOnWildWorld(uint32 male, uint32 female) public {

        require(isOwnerOrStaked(male, ContractTypes.KANGAROOS) && isOwnerOrStaked(female, ContractTypes.KANGAROOS), "Missing permissions - you're not the owner of one of the tokens");
        require(getData().getStatus(male) == 1 && getData().getStatus(female) == 1, "Status doesn't fit this step");
        require(getData().isCouples(male, female), "Not Couples");
        uint16 boatId = getData().getKangaroo(male).boatId;
        require(getMovingBoats().sailEnd(boatId) <= block.timestamp, "Still on sail");
        require(getMovingBoats().getDirection(boatId) == true, "not in the route to kangaroo island");
        getData().updateBoatId(male, 0);
        getData().updateBoatId(female, 0);
        getData().kangarooStartPregnancy(male, female, false);
        emit PregnancyStarted(male, female, false);
    }

    function pregnancyOnHospital(uint32 male, uint32 female) public payable{

        require(isOwnerOrStaked(male, ContractTypes.KANGAROOS) && isOwnerOrStaked(female, ContractTypes.KANGAROOS), "Missing permissions - you're not the owner of one of the tokens");
        require(getData().getStatus(male) == 1 && getData().getStatus(female) == 1, "Status doesn't fit this step");
        require(getData().isCouples(male, female), "Not Couples");
        uint16 boatId = getData().getKangaroo(male).boatId;
        require(getMovingBoats().sailEnd(boatId) <= block.timestamp, "Still on sail");
        require(getMovingBoats().getDirection(boatId) == true, "not in the route to kangaroo island");
        require(getHospitalPrice() <= msg.value, "Hospital fee too low");
        getVaultEth().depositLandFees{value:msg.value}(1);
        getData().updateBoatId(male, 0);
        getData().updateBoatId(female, 0);
        getData().kangarooStartPregnancy(male, female, true);
        emit PregnancyStarted(male, female, true);
    }

    function birthBabies(uint32 male, uint32 female) public {

        require(isOwnerOrStaked(male, ContractTypes.KANGAROOS) && isOwnerOrStaked(female, ContractTypes.KANGAROOS), "Missing permissions - you're not the owner of one of the tokens");
        require(getData().getStatus(male) == 3 && getData().getStatus(female) == 3, "Status doesn't fit this step");
        require(getData().isCouples(male, female), "Not Couples");
        getData().birthKangaroos(male, female, msg.sender);
        emit BabiesBorn(male, female);
    }

    function coupleSailBack(uint32 male, uint32 female) public {

        require(isOwnerOrStaked(male, ContractTypes.KANGAROOS) && isOwnerOrStaked(female, ContractTypes.KANGAROOS), "Missing permissions - you're not the owner of one of the tokens");
        require(getData().isCouples(male, female), "Not Couples");
        require(getData().doneMaxBabies(male, female), "You need to make maximum amount of babies before you leave");
        require(getData().getStatus(male) == 2 && getData().getStatus(female) == 2, "Status doesn't fit this step");
        getMovingBoats().startSail(getData().getBornState(male), false);
        uint16 movingBoatId = uint16(getMovingBoats().getLastId());
        getData().getBackAustralian(male, female, movingBoatId);
        emit SailBackStarted(male, female, movingBoatId);
    }

    function arrivedToContinent(uint32 male, uint32 female) public {

        require(isOwnerOrStaked(male, ContractTypes.KANGAROOS) && isOwnerOrStaked(female, ContractTypes.KANGAROOS), "Missing permissions - you're not the owner of one of the tokens");
        uint16 boatId = getData().getKangaroo(male).boatId;
        require(getMovingBoats().sailEnd(boatId) <= block.timestamp, "Still on sail");
        require(getMovingBoats().getDirection(boatId) == false, "not on the route to Australian");
        require(getData().getStatus(male) == 1 && getData().getStatus(female) == 1, "Status doesn't fit this step");
        getData().kangaroosArrivedContinent(male, female);
        emit ArrivedContinent(male, female);
    }


    function getCurrentState(uint32 kangarooId) public view returns(uint8){

        IKWWData.KangarooDetails memory data = getData().getKangaroo(kangarooId);
        if(data.landId != 0){
            return uint8(data.landId);
        }
        return data.bornState;
    }

    function getFirstBoatIdFromState(uint8 stateId) public pure returns(uint16){

        return 1+((stateId - 1) * 100);
    }

    function pack(uint32 a, uint32 b) public pure returns(uint64) {

        return (uint64(a) << 32) | uint64(b);
    }

    function boatAvailableToWithdraw(uint16 boatId) public view returns(uint256) {

        return getVaultEth().boatAvailableToWithdraw(uint16(getBoatNFT().totalSupply()), boatId);
    }

    function landAvailableToWithdraw(uint16 landId, uint8 ownerTypeId) public view returns(uint256) {

        return getVaultEth().landAvailableToWithdraw(landId, ownerTypeId);
    }

    function withdrawBoatFees(uint16 boatId) public {

        require(getBoatNFT().ownerOf(boatId) == msg.sender, "caller is not the owner of the boat");
        getVaultEth().withdrawBoatFees(uint16(getBoatNFT().totalSupply()), boatId, getBoatNFT().ownerOf(boatId));
    }
    
    function withdrawLandFees(uint16 landId, uint8 ownerTypeId) public {

        address addr = getLandOwnerAddress(landId, ownerTypeId);
        require(addr != address(0) && addr == msg.sender, "caller is not the owner of the land");
        getVaultEth().withdrawLandFees(landId, ownerTypeId, addr);
    }

    function depositCouple(uint32 dadId, uint32 momId, bool frozen) internal {

        uint256[] memory arr = new uint256[](2);
        arr[0] = uint256(dadId);
        arr[1] = uint256(momId);
        getVault().depositToVault(msg.sender, arr, uint8(ContractTypes.KANGAROOS), frozen);
    }


    function getHospitalPrice() view public returns(uint256){

        return getLandNFT().getPrice(1);
    }

    function getContract(uint8 _type) override view public returns(address){

        require(contracts[_type] != address(0),"Contract not exists");
        return contracts[_type];
    }

    function getLandData(uint16 tokenId) public view returns(LandsData.LandDetails memory){

        return getLandNFT().getLandData(tokenId);
    }

    function getLandOwnerAddress(uint16 landId, uint8 ownerType) public view returns(address){

        address addr = address(0);
        LandsData.LandDetails memory landData = getLandData(landId);
        if(ownerType == 0){
            getKangaroosNFT().ownerOf(landData.princeId);
        }
        else if(ownerType == 1){
            getKangaroosNFT().ownerOf(landData.princessId);
        }
        else if(ownerType == 2){
            getLandNFT().ownerOf(landId);
        }

        return addr;
    }

    function getKangaroosNFT() view public returns(INFT){

        return INFT(getContract(uint8(ContractTypes.KANGAROOS)));
    }

    function getBoatNFT() view public returns(INFT){

        return INFT(getContract(uint8(ContractTypes.BOATS)));
    }
    
    function getLandNFT() view public returns(LandsData){

        return LandsData(getContract(uint8(ContractTypes.LANDS)));
    }
    
    function getVault() view public returns(Vault){

        return Vault(getContract(uint8(ContractTypes.VAULT)));
    }

    function getVaultEth() view public returns(VaultEth){

        return VaultEth(getContract(uint8(ContractTypes.VAULT_ETH)));
    }

    function getData() view public returns(KangarooData){

        return KangarooData(getContract(uint8(ContractTypes.DATA)));
    }

    function getMovingBoats() view public returns(MovingBoatsData){

        return MovingBoatsData(getContract(uint8(ContractTypes.MOVING_BOATS)));
    }

    function getVoting() view public returns(Voting){

        return Voting(getContract(uint8(ContractTypes.VOTING)));
    }


    function isOwnerOrStaked(uint256 tokenId, ContractTypes _type) internal view returns(bool){

        require(contracts[uint8(_type)] != address(0) && contracts[uint8(ContractTypes.VAULT)]  != address(0) , "One of the contract not initialized");

        bool isOwner = INFT(contracts[uint8(_type)]).ownerOf(tokenId) == msg.sender;
        bool isStaked = Vault(contracts[uint8(ContractTypes.VAULT)]).getHolder(tokenId) == msg.sender;
        return isOwner || isStaked;
    }

    function addContractType(uint8 typeId, address _addr) public onlyOwner{

        contracts[typeId] = _addr;
    }

    function addMultipleContracts(uint8[] calldata types, address[] calldata addresses) public onlyOwner{

        for (uint256 i = 0; i < types.length; i++) {
            addContractType(types[i], addresses[i]);
        }
    }
}