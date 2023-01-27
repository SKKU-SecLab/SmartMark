
pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
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

}//MIT

pragma solidity ^0.8.0;


interface IBountyBoard {

    struct ERC721Grouping {
        IERC721 erc721;
        uint256[] ids;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

interface IERC721Validator {

    function meetsCriteria(address tokenAddress, uint256 tokenId)
        external
        view
        returns (bool);

}// MIT

pragma solidity ^0.8.0;


contract AddressValidator is IERC721Validator, Ownable {

    event AddressesSet(address[] addrs, bool set);

    mapping(address => bool) public acceptedAddrs;

    function initialize(address _owner, address[] calldata addrs) external {

        require(owner() == address(0));
        _transferOwnership(_owner);
        _setAddresses(addrs, true);
    }

    function setAddresses(address[] calldata addrs, bool set)
        external
        onlyOwner
    {

        _setAddresses(addrs, set);
    }

    function _setAddresses(address[] calldata addrs, bool set) internal {

        for (uint256 i = 0; i < addrs.length; i++) {
            acceptedAddrs[addrs[i]] = set;
        }
        emit AddressesSet(addrs, set);
    }

    function meetsCriteria(address tokenAddr, uint256)
        external
        view
        override
        returns (bool)
    {

        return acceptedAddrs[tokenAddr];
    }
}// MIT

pragma solidity ^0.8.0;


contract IdValidator is IERC721Validator, Ownable {

    event IdsSet(IBountyBoard.ERC721Grouping[] tokenGroupings, bool set);

    mapping(address => mapping(uint256 => bool)) public acceptedTokens;

    function initialize(
        address _owner,
        IBountyBoard.ERC721Grouping[] calldata tokenGroupings
    ) external {

        require(owner() == address(0));
        _transferOwnership(_owner);
        _setIds(tokenGroupings, true);
    }

    function setIds(
        IBountyBoard.ERC721Grouping[] calldata tokenGroupings,
        bool set
    ) external onlyOwner {

        _setIds(tokenGroupings, set);
    }

    function _setIds(
        IBountyBoard.ERC721Grouping[] calldata tokenGroupings,
        bool set
    ) internal {

        for (uint256 i = 0; i < tokenGroupings.length; i++) {
            IBountyBoard.ERC721Grouping memory grouping = tokenGroupings[i];
            mapping(uint256 => bool) storage acceptedIds = acceptedTokens[
                address(grouping.erc721)
            ];
            uint256[] memory idsToSet = grouping.ids;
            for (uint256 j = 0; j < idsToSet.length; j++) {
                acceptedIds[idsToSet[j]] = set;
            }
        }
        emit IdsSet(tokenGroupings, set);
    }

    function meetsCriteria(address tokenAddr, uint256 tokenId)
        external
        view
        override
        returns (bool)
    {

        return acceptedTokens[tokenAddr][tokenId];
    }
}// MIT

pragma solidity ^0.8.0;


contract ValidatorCloneFactory {

    event AddressValidatorCreated(address addr);
    event IdValidatorCreated(address addr);

    address public immutable ADDRESS_VALIDATOR_MASTER_COPY;
    address public immutable ID_VALIDATOR_MASTER_COPY;

    constructor() {
        ADDRESS_VALIDATOR_MASTER_COPY = address(new AddressValidator());
        ID_VALIDATOR_MASTER_COPY = address(new IdValidator());
    }

    function deployAddressValidatorClone(address[] memory addrs)
        external
        returns (address created)
    {

        created = Clones.cloneDeterministic(
            ADDRESS_VALIDATOR_MASTER_COPY,
            keccak256(abi.encode(msg.sender, addrs))
        );
        AddressValidator(created).initialize(msg.sender, addrs);
        emit AddressValidatorCreated(created);
    }

    function predictAddressValidatorAddr(address sender, address[] memory addrs)
        external
        view
        returns (address predicted)
    {

        predicted = Clones.predictDeterministicAddress(
            ADDRESS_VALIDATOR_MASTER_COPY,
            keccak256(abi.encode(sender, addrs))
        );
    }

    function deployIdValidatorClone(
        IBountyBoard.ERC721Grouping[] memory erc721Groupings
    ) external returns (address created) {

        created = Clones.cloneDeterministic(
            ID_VALIDATOR_MASTER_COPY,
            keccak256(abi.encode(msg.sender, erc721Groupings))
        );
        IdValidator(created).initialize(msg.sender, erc721Groupings);
        emit IdValidatorCreated(created);
    }

    function predictIdValidatorAddr(
        address sender,
        IBountyBoard.ERC721Grouping[] memory erc721Groupings
    ) external view returns (address predicted) {

        predicted = Clones.predictDeterministicAddress(
            ID_VALIDATOR_MASTER_COPY,
            keccak256(abi.encode(sender, erc721Groupings))
        );
    }
}