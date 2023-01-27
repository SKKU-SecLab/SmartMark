pragma solidity ^0.8.7;

contract NFTContract {

    function restrictedMint(address, uint256) public {}

    function ownerOf(uint256 tokenId) external view returns (address owner) {}
}

contract Gen1FreeMinter {

    NFTContract private delegate;
    uint256 mintsUsed;

    constructor(address nftContract) {
        delegate = NFTContract(nftContract);
        mintsUsed = 0;
    }

    function freeMintFor(uint256[] memory id) public {

        uint256 newState = mintsUsed;
        for (uint256 i = 0; i < id.length; i++) {
            require(id[i] >= 1 && id[i] <= 256, "id out of range");

            uint256 mask = (1 << (id[i] - 1));
            require((newState & mask) == 0, "free mint already used");
            newState = (newState | mask);
            require(delegate.ownerOf(id[i]) == msg.sender, "id not owned");
        }

        mintsUsed = newState;

        delegate.restrictedMint(msg.sender, id.length);
    }

    function isMintUsed(uint256 id) public view returns (bool) {

        require(id >= 1 && id <= 256, "id out of range");
        uint256 mask = (1 << (id - 1));
        return (mintsUsed & mask) != 0;
    }
}