


pragma solidity ^0.8.4;


interface IKWWGameManager{

    enum ContractTypes {KANGAROOS, BOATS, LANDS, VAULT, DATA, BOATS_DATA, MOVING_BOATS, VOTING}

    function getContract(uint8 _type) external view returns(address);

}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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




contract KWWVault is Ownable {

    struct VaultAsset{
        uint64 timeStaked;
        address holder;
        uint8 assetType;
        bool frozen;
    }
    mapping(uint256 => VaultAsset) public assetsData;
    mapping(address => uint256[]) public holderTokens;

    mapping(uint16 => uint256) public boatsWithdrawAmount;
    mapping(uint16 => mapping(uint8 => uint256)) public landsWithdrawAmount;

    mapping(uint16 => uint256) public boatsMaxWithdraw;
    mapping(uint16 => uint256) public landsMaxWithdraw;

    uint256 teamWithdraw;
    uint256 teamMaxWithdraw;

    uint8 teamPercent = 10;

    bool public vaultOpen = true;

    IKWWGameManager gameManager;

    function depositBoatFees(uint16 totalSupply) public payable onlyGameManager{

        teamMaxWithdraw += msg.value / teamPercent;
        boatsMaxWithdraw[totalSupply] = (msg.value - msg.value / teamPercent ) / totalSupply;
    }

    function boatAvailableToWithdraw(uint16 totalSupply, uint16 boatId) public view returns(uint256) {

        uint16 maxState = (boatId / 100) * 100 + 100;
        uint256 withdrawMaxAmount= 0;
        for(uint16 i = boatId; i < totalSupply && i < maxState ; i++){
            withdrawMaxAmount += boatsMaxWithdraw[i];
        }
        return withdrawMaxAmount - boatsWithdrawAmount[boatId];
    }

    function withdrawBoatFees(uint16 totalSupply, uint16 boatId, address addr) public onlyGameManager{

        uint256 availableToWithdraw = boatAvailableToWithdraw(totalSupply, boatId);
        (bool os, ) = payable(addr).call{value: availableToWithdraw}("");
        require(os);
        boatsWithdrawAmount[boatId] += availableToWithdraw;
    }

    function depositLandFees(uint16 landId) public payable onlyGameManager{

        teamMaxWithdraw += msg.value / teamPercent;
        landsMaxWithdraw[landId] = (msg.value - msg.value / teamPercent ) / 3;
    }

    function landAvailableToWithdraw(uint16 landId, uint8 ownerTypeId) public view returns(uint256) {

        require(ownerTypeId < 3, "Owner type not valid");
        return landsMaxWithdraw[landId] - landsWithdrawAmount[landId][ownerTypeId];
    }

    function withdrawLandFees(uint16 landId, uint8 ownerTypeId, address addr) public onlyGameManager{

        uint256 availableToWithdraw = landAvailableToWithdraw(landId, ownerTypeId);
        (bool os, ) = payable(addr).call{value: availableToWithdraw}("");
        require(os);
        landsWithdrawAmount[landId][ownerTypeId] += availableToWithdraw;
    }

    function teamAvailableToWithdraw() public view returns(uint256) {

        return teamMaxWithdraw - teamWithdraw;
    }

    function withdrawFeesTeam(address teamWallet) public onlyOwner {

        uint256 availableToWithdraw = teamAvailableToWithdraw();
        (bool os, ) = payable(teamWallet).call{value: availableToWithdraw}("");
        require(os);
        teamWithdraw += availableToWithdraw;
    } 

    function depositToVault(address owner, uint256[] memory tokens, uint8 assetsType, bool frozen) public onlyGameManager {

        require(vaultOpen, "Vault is closed");

        IERC721 NFTContract = IERC721(gameManager.getContract(assetsType));
        require(NFTContract.isApprovedForAll(owner, address(this)), "The vault is not approved for all");

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 id = tokens[i];
            NFTContract.transferFrom(owner, address(this), id);

            holderTokens[owner].push(id);
            assetsData[id].timeStaked = uint64(block.timestamp);
            assetsData[id].holder = owner;
            assetsData[id].assetType = assetsType;
            assetsData[id].frozen = frozen;
        }
    }

    function withdrawFromVault(uint256[] calldata tokenIds) public  {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 id = tokenIds[i];
            require(assetsData[id].holder == msg.sender, "Missing permissions - you're not the owner");
            require(isWithdrawAvailable(id), "Asset is still frozen");

            getIERC721Contract(id).transferFrom(address(this), msg.sender, id);

            removeTokenIdFromArray(holderTokens[msg.sender], id);
            assetsData[id].holder = address(0);
        }
    }

    function withdrawFromVault(address owner, uint256[] calldata tokenIds) public onlyGameManager {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 id = tokenIds[i];
            require(assetsData[id].holder == owner, "Missing permissions - you're not the owner");

            getIERC721Contract(id).transferFrom(address(this), owner, id);

            removeTokenIdFromArray(holderTokens[owner], id);
            assetsData[id].holder = address(0);
        }
    }

    function witdrawAll() public {

        require(getDepositedAmount(msg.sender) > 0, "NONE_STAKED");

        for (uint256 i = holderTokens[msg.sender].length; i > 0; i--) {
            uint256 id = holderTokens[msg.sender][i - 1];
            require(isWithdrawAvailable(id), "Asset is still frozen");

            getIERC721Contract(id).transferFrom(address(this), msg.sender, id);

            holderTokens[msg.sender].pop();
            assetsData[id].holder = address(0);
        }
    }

    function witdrawAll(address owner) public onlyGameManager {

        require(getDepositedAmount(owner) > 0, "Owner vault is empty");

        for (uint256 i = holderTokens[owner].length; i > 0; i--) {
            uint256 id = holderTokens[owner][i - 1];
            require(assetsData[id].holder == owner, "Missing permissions - you're not the owner");

            getIERC721Contract(id).transferFrom(address(this), owner, id);

            holderTokens[owner].pop();
            assetsData[id].holder = address(0);
        }
    }

    function setAssetFrozen(uint256 token, bool isFrozen) public onlyGameManager {

        assetsData[token].frozen = isFrozen;
    }

    function removeTokenIdFromArray(uint256[] storage array, uint256 tokenId) internal {

        uint256 length = array.length;
        for (uint256 i = 0; i < length; i++) {
            if (array[i] == tokenId) {
                length--;
                if (i < length) {
                    array[i] = array[length];
                }
                array.pop();
                break;
            }
        }
    }


    function getIERC721Contract(uint256 tokenId) public view returns(IERC721){

        return IERC721(gameManager.getContract(assetsData[tokenId].assetType));
    }

    function getDepositedAmount(address holder) public view returns (uint256) {

        return holderTokens[holder].length;
    }

    function getHolder(uint256 tokenId) public view returns (address) {

        return assetsData[tokenId].holder;
    }

    function isWithdrawAvailable(uint256 tokenId) public view returns(bool){

        return !assetsData[tokenId].frozen;
    }


    modifier onlyGameManager {

        require(address(gameManager) != address(0), "Game manager not set");
        require(msg.sender == owner() || msg.sender == address(gameManager), "caller is not the Boats Contract");
        _;
    }


    function toggleVaultOpen() public onlyOwner{

        vaultOpen = !vaultOpen;
    }

    function setGameManager(address _addr) public onlyOwner{

        gameManager = IKWWGameManager(_addr);
    }

    function setTeamPercent(uint8 _teamPercent) public onlyOwner{

        teamPercent = _teamPercent;
    }
}