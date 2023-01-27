
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

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// MIT
pragma solidity ^0.8.4;

interface IContractProbe {

  function probe(address _address) external view returns (bool isContract, address forwardedTo);

}// MIT
pragma solidity ^0.8.4;


contract CloneFactory is Ownable {

  address[] public implementations;
  address public template;

  mapping(address => address) public templates;

  address private _contractProbe;

  event NewImplementation(
    address indexed implementation,
    address indexed template,
    address indexed creator
  );
  event NewTemplate(address indexed template, address indexed creator);

  constructor(address contractProbe) {
    _contractProbe = contractProbe;
  }

  function addImplementation(address _implementation) public onlyOwner {

    _addImplementation(_implementation);
  }

  function setDefaultTemplate(address _template) public onlyOwner {

    if (templates[_template] == address(0)) addImplementation(_template);
    require(templates[_template] == _template, "Template is a Clone");

    template = _template;

    emit NewTemplate(_template, msg.sender);
  }

  function implementationsCount() public view returns (uint256 count) {

    return implementations.length;
  }

  function _addImplementation(address _implementation) internal {

    require(templates[_implementation] == address(0), "Implementation already exists");

    (bool _isContract, address _template) = IContractProbe(_contractProbe).probe(_implementation);

    require(_isContract, "Implementation is not a Contract");

    implementations.push(_implementation);
    templates[_implementation] = _template;

    emit NewImplementation(_implementation, _template, msg.sender);
  }

  function _clone() internal virtual returns (address clone_) {

    require(template != address(0), "Template doesn't exist");

    clone_ = Clones.clone(template);
    _addImplementation(clone_);
  }
}// MIT
pragma solidity ^0.8.4;

interface IOpenNFTsV2 {

  function transferOwnership(address newOwner) external;


  function initialize(string memory name_, string memory symbol_) external;


  function mintNFT(address minter, string memory jsonURI) external returns (uint256);


  function owner() external view returns (address);

}// MIT
pragma solidity ^0.8.4;


contract NFTsFactory is CloneFactory {

  using ERC165Checker for address;

  struct NftData {
    address nft;
    uint256 balanceOf;
    address owner;
    string name;
    string symbol;
    uint256 totalSupply;
  }

  uint8 public constant ERC721 = 0;
  uint8 public constant ERC721_METADATA = 1;
  uint8 public constant ERC721_ENUMERABLE = 2;
  uint8 public constant OPEN_NFTS = 3;

  bytes4 public constant ERC721_SIG = bytes4(0x80ac58cd);
  bytes4 public constant ERC721_METADATA_SIG = bytes4(0x780e9d63);
  bytes4 public constant ERC721_ENUMERABLE_SIG = bytes4(0x780e9d63);
  bytes4 public constant OPEN_NFTS_SIG = type(IOpenNFTsV2).interfaceId;

  constructor(address _openNFTs, address _contractprobe) CloneFactory(_contractprobe) {
    setDefaultTemplate(_openNFTs);
  }

  function withdrawEther() external onlyOwner {

    (bool succeed, ) = msg.sender.call{value: address(this).balance}("");
    require(succeed, "Failed to withdraw Ether");
  }

  function balancesOf(address owner) external view returns (NftData[] memory nftData) {

    nftData = new NftData[](implementations.length);
    for (uint256 i = 0; i < implementations.length; i += 1) {
      nftData[i] = balanceOf(implementations[i], owner);
    }
  }

  function clone(string memory _name, string memory _symbol) public returns (address clone_) {

    clone_ = _clone();
    require(clone_.supportsInterface(OPEN_NFTS_SIG), "Clone is not Open NFTs contract");

    IOpenNFTsV2(clone_).initialize(_name, _symbol);
    IOpenNFTsV2(clone_).transferOwnership(msg.sender);
  }

  function balanceOf(address nft, address owner) public view returns (NftData memory nftData) {

    bytes4[] memory iface = new bytes4[](4);
    iface[ERC721] = ERC721_SIG;
    iface[ERC721_METADATA] = ERC721_METADATA_SIG;
    iface[ERC721_ENUMERABLE] = ERC721_ENUMERABLE_SIG;
    iface[OPEN_NFTS] = OPEN_NFTS_SIG;
    bool[] memory supportInterface = nft.getSupportedInterfaces(iface);

    if (supportInterface[ERC721]) {
      nftData.nft = nft;
      nftData.balanceOf = IERC721(nft).balanceOf(owner);

      if (supportInterface[ERC721_METADATA]) {
        nftData.name = IERC721Metadata(nft).name();
        nftData.symbol = IERC721Metadata(nft).symbol();
      }

      if (supportInterface[ERC721_ENUMERABLE]) {
        nftData.totalSupply = IERC721Enumerable(nft).totalSupply();
      }

      if (supportInterface[OPEN_NFTS]) {
        nftData.owner = IOpenNFTsV2(nft).owner();
      }
    }
  }
}