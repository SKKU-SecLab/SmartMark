
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

library Create2 {

    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {

        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {

        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}// CC0-1.0
pragma solidity ^0.8.0;



IERC20 constant Dough = IERC20(0x10971797FcB9925d01bA067e51A6F8333Ca000B1);
OCM constant Monsters = OCM(0xaA5D0f2E6d008117B16674B0f00B6FCa46e3EFC4);


interface OCM is IERC721Enumerable {

    function currentMintingCost() external returns (uint);

    function mintMonster() external;

}


contract OnChainMonsterMintManager {

    address immutable minterAddress;
    uint256 public oneShotMintCount;

    constructor() {
        minterAddress = Create2.deploy(0, 0, type(FlashMinter).creationCode);
    }

    function mintMonsters(uint256 count) external {

        unchecked {
            uint256 id = Monsters.totalSupply(); // Next ID to be minted.
            uint256 next = id + count; // End of mint range, exclusive.

            uint256 totalCost = (id / 2000) * count;

            uint256 nextTierPosition = next % 2000;
            if (nextTierPosition < id % 2000) totalCost += nextTierPosition;

            totalCost *= 1e18;

            Dough.transferFrom(msg.sender, minterAddress, totalCost);

            oneShotMintCount = count;
            Create2.deploy(0, 0, type(FlashMinter).creationCode);

            for (; id < next; ++id)
                Monsters.transferFrom(minterAddress, msg.sender, id);
        }
    }
}


contract FlashMinter {

    constructor() {
        address creator = msg.sender;

        if (creator.code.length == 0) {
            Dough.approve(address(Monsters), type(uint256).max);
            Monsters.setApprovalForAll(creator, true);

            selfdestruct(payable(creator));
            return;
        }

        uint count = OnChainMonsterMintManager(creator).oneShotMintCount();
        unchecked {
            for (; count > 0; --count) Monsters.mintMonster();
        }

        selfdestruct(payable(creator));
    }
}