
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// UNLICENSED

pragma solidity 0.8.7;


interface ILobsterBeachClub {

    function seedNumber() external view returns (uint256);

    function maxSupply() external view returns (uint256);

}

contract LobsterGenome is Ownable {

    mapping(uint => uint16[]) public traits;
    mapping(uint => uint16) public sequenceToRarityTotals;
    string public provenance;
    uint16[] sequences;
    uint16[] assets;
    ILobsterBeachClub public lobsterBeachClub;

    constructor(address lbcAddress) {
        setLobsterBeachClub(lbcAddress);
    }

    function setLobsterBeachClub(address lbcAddress) public onlyOwner {

        lobsterBeachClub = ILobsterBeachClub(lbcAddress);
    }

    function setProvenance(string memory _provenance) public onlyOwner {

        provenance = _provenance;
    }

    function resetTraits() public onlyOwner {

        for(uint i; i < sequences.length; i++) {
            delete traits[i];
            delete sequenceToRarityTotals[i];
        }
        delete sequences;
    }

    function setTraits(uint16[] memory rarities) public onlyOwner {

        require(rarities.length > 0, "Rarities is empty, Use resetTraits() instead");
        resetTraits();
        uint16 trait = 0;
        sequences.push(trait);
        for(uint i; i < rarities.length; i++) {
            uint16 rarity = rarities[i];
            if (rarity == 0) {
                trait++;
                sequences.push(trait);
            } else {
                traits[trait].push(rarity);
                sequenceToRarityTotals[trait] += rarity;
            }
        }
    }

    function getGeneSequence(uint256 tokenId) public view returns (uint256 _geneSequence) {

        uint256 assetOwned = getAssetOwned(tokenId);
        if (assetOwned != 0) {
            return assetOwned;
        }
        uint256 seedNumber = lobsterBeachClub.seedNumber();
        uint256 geneSequenceSeed = uint256(keccak256(abi.encode(seedNumber, tokenId)));
        uint256 geneSequence;
        for(uint i; i < sequences.length; i++) {
            uint16 sequence = sequences[i];
            uint16[] memory rarities = traits[sequence];
            uint256 sequenceRandomValue = uint256(keccak256(abi.encode(geneSequenceSeed, i)));
            uint256 sequenceRandomResult = (sequenceRandomValue % sequenceToRarityTotals[sequence]) + 1;
            uint16 rarityCount;
            uint resultingTrait;
            for(uint j; j < rarities.length; j++) {
                uint16 rarity = rarities[j];
                rarityCount += rarity;
                if (sequenceRandomResult <= rarityCount) {
                    resultingTrait = j;
                    break;
                }
            }
            geneSequence += 10**(3*sequence) * resultingTrait;
        }
        return geneSequence;
    }

    function setAssets(uint16[] memory _assets) public onlyOwner {

        uint256 maxSupply = lobsterBeachClub.maxSupply();
        require(_assets.length <= maxSupply, "You cannot supply more assets than max supply");
        for (uint i; i < _assets.length; i++) {
            require(_assets[i] > 0 && _assets[i] < 1000, "Asset id must be between 1 and 999");
        }
        assets = _assets;
    }
    
    function getAssetOwned(uint256 tokenId) public view returns (uint16 assetId) {

        uint256 maxSupply = lobsterBeachClub.maxSupply();
        uint256 seedNumber = lobsterBeachClub.seedNumber();
        uint256 totalDistance = maxSupply;
        uint256 direction = seedNumber % 2;
        for (uint i; i < assets.length; i++) {
            uint256 difference = totalDistance / (assets.length - i);
            uint256 assetSeed = uint256(keccak256(abi.encode(seedNumber, i)));
            uint256 distance = (assetSeed % difference) + 1;
            totalDistance -= distance;
            if ((direction == 0 && totalDistance == tokenId) || (direction == 1 && (maxSupply - totalDistance - 1 == tokenId))) {
                return assets[i];
            }
        }
        return 0;
    }

}