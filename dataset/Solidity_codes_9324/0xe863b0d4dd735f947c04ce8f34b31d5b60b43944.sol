pragma solidity 0.8.4;

interface IFlashLoanReceiver {

  function executeOperation(
    address asset,
    uint256[] calldata tokenIds,
    address initiator,
    address operator,
    bytes calldata params
  ) external returns (bool);

}// agpl-3.0
pragma solidity 0.8.4;

interface IBNFT {

  event Initialized(address indexed underlyingAsset_);

  event OwnershipTransferred(address oldOwner, address newOwner);

  event ClaimAdminUpdated(address oldAdmin, address newAdmin);

  event Mint(address indexed user, address indexed nftAsset, uint256 nftTokenId, address indexed owner);

  event Burn(address indexed user, address indexed nftAsset, uint256 nftTokenId, address indexed owner);

  event FlashLoan(address indexed target, address indexed initiator, address indexed nftAsset, uint256 tokenId);

  event ClaimERC20Airdrop(address indexed token, address indexed to, uint256 amount);

  event ClaimERC721Airdrop(address indexed token, address indexed to, uint256[] ids);

  event ClaimERC1155Airdrop(address indexed token, address indexed to, uint256[] ids, uint256[] amounts, bytes data);

  event ExecuteAirdrop(address indexed airdropContract);

  function initialize(
    address underlyingAsset_,
    string calldata bNftName,
    string calldata bNftSymbol,
    address owner_,
    address claimAdmin_
  ) external;


  function mint(address to, uint256 tokenId) external;


  function burn(uint256 tokenId) external;


  function flashLoan(
    address receiverAddress,
    uint256[] calldata nftTokenIds,
    bytes calldata params
  ) external;


  function claimERC20Airdrop(
    address token,
    address to,
    uint256 amount
  ) external;


  function claimERC721Airdrop(
    address token,
    address to,
    uint256[] calldata ids
  ) external;


  function claimERC1155Airdrop(
    address token,
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts,
    bytes calldata data
  ) external;


  function executeAirdrop(address airdropContract, bytes calldata airdropParams) external;


  function minterOf(uint256 tokenId) external view returns (address);


  function underlyingAsset() external view returns (address);


  function contractURI() external view returns (string memory);

}// agpl-3.0
pragma solidity 0.8.4;

interface IBNFTRegistry {

  event Initialized(address genericImpl, string namePrefix, string symbolPrefix);
  event GenericImplementationUpdated(address genericImpl);
  event BNFTCreated(address indexed nftAsset, address bNftImpl, address bNftProxy, uint256 totals);
  event BNFTUpgraded(address indexed nftAsset, address bNftImpl, address bNftProxy, uint256 totals);
  event CustomeSymbolsAdded(address[] nftAssets, string[] symbols);
  event ClaimAdminUpdated(address oldAdmin, address newAdmin);

  function getBNFTAddresses(address nftAsset) external view returns (address bNftProxy, address bNftImpl);


  function getBNFTAddressesByIndex(uint16 index) external view returns (address bNftProxy, address bNftImpl);


  function getBNFTAssetList() external view returns (address[] memory);


  function allBNFTAssetLength() external view returns (uint256);


  function initialize(
    address genericImpl,
    string memory namePrefix_,
    string memory symbolPrefix_
  ) external;


  function setBNFTGenericImpl(address genericImpl) external;


  function createBNFT(address nftAsset) external returns (address bNftProxy);


  function createBNFTWithImpl(address nftAsset, address bNftImpl) external returns (address bNftProxy);


  function upgradeBNFTWithImpl(
    address nftAsset,
    address bNftImpl,
    bytes memory encodedCallData
  ) external;


  function batchUpgradeBNFT(address[] calldata nftAssets) external;


  function batchUpgradeAllBNFT() external;


  function addCustomeSymbols(address[] memory nftAssets_, string[] memory symbols_) external;

}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// agpl-3.0
pragma solidity 0.8.4;



contract AirdropFlashLoanReceiver is IFlashLoanReceiver, ReentrancyGuard, Ownable, ERC721Holder, ERC1155Holder {

  address public immutable bnftRegistry;
  mapping(bytes32 => bool) public airdropClaimRecords;
  uint256 public deployType;

  constructor(
    address owner_,
    address bnftRegistry_,
    uint256 deployType_
  ) {
    require(owner_ != address(0), "zero owner address");
    require(bnftRegistry_ != address(0), "zero registry address");

    bnftRegistry = bnftRegistry_;
    deployType = deployType_;

    _transferOwnership(owner_);
  }

  struct ExecuteOperationLocalVars {
    uint256[] airdropTokenTypes;
    address[] airdropTokenAddresses;
    uint256[] airdropTokenIds;
    address airdropContract;
    bytes airdropParams;
    uint256 airdropBalance;
    uint256 airdropTokenId;
    bytes32 airdropKeyHash;
  }

  function executeOperation(
    address nftAsset,
    uint256[] calldata nftTokenIds,
    address initiator,
    address operator,
    bytes calldata params
  ) external override returns (bool) {

    ExecuteOperationLocalVars memory vars;

    (address bnftProxy, ) = IBNFTRegistry(bnftRegistry).getBNFTAddresses(nftAsset);
    require(bnftProxy == msg.sender, "caller not bnft");

    if (deployType != 0) {
      require(initiator == owner(), "initiator not owner");
    }

    require(nftTokenIds.length > 0, "empty token list");

    (
      vars.airdropTokenTypes,
      vars.airdropTokenAddresses,
      vars.airdropTokenIds,
      vars.airdropContract,
      vars.airdropParams
    ) = abi.decode(params, (uint256[], address[], uint256[], address, bytes));

    require(vars.airdropTokenTypes.length > 0, "invalid airdrop token type");
    require(vars.airdropTokenAddresses.length == vars.airdropTokenTypes.length, "invalid airdrop token address length");
    require(vars.airdropTokenIds.length == vars.airdropTokenTypes.length, "invalid airdrop token id length");

    require(vars.airdropContract != address(0), "invalid airdrop contract address");
    require(vars.airdropParams.length >= 4, "invalid airdrop parameters");

    IERC721(nftAsset).setApprovalForAll(operator, true);

    Address.functionCall(vars.airdropContract, vars.airdropParams, "call airdrop method failed");

    vars.airdropKeyHash = getClaimKeyHash(initiator, nftAsset, nftTokenIds, params);
    airdropClaimRecords[vars.airdropKeyHash] = true;

    for (uint256 typeIndex = 0; typeIndex < vars.airdropTokenTypes.length; typeIndex++) {
      require(vars.airdropTokenAddresses[typeIndex] != address(0), "invalid airdrop token address");

      if (vars.airdropTokenTypes[typeIndex] == 1) {
        vars.airdropBalance = IERC20(vars.airdropTokenAddresses[typeIndex]).balanceOf(address(this));
        if (vars.airdropBalance > 0) {
          IERC20(vars.airdropTokenAddresses[typeIndex]).transfer(initiator, vars.airdropBalance);
        }
      } else if (vars.airdropTokenTypes[typeIndex] == 2) {
        vars.airdropBalance = IERC721(vars.airdropTokenAddresses[typeIndex]).balanceOf(address(this));
        for (uint256 i = 0; i < vars.airdropBalance; i++) {
          vars.airdropTokenId = IERC721Enumerable(vars.airdropTokenAddresses[typeIndex]).tokenOfOwnerByIndex(
            address(this),
            0
          );
          IERC721Enumerable(vars.airdropTokenAddresses[typeIndex]).safeTransferFrom(
            address(this),
            initiator,
            vars.airdropTokenId
          );
        }
      } else if (vars.airdropTokenTypes[typeIndex] == 3) {
        vars.airdropBalance = IERC1155(vars.airdropTokenAddresses[typeIndex]).balanceOf(
          address(this),
          vars.airdropTokenIds[typeIndex]
        );
        IERC1155(vars.airdropTokenAddresses[typeIndex]).safeTransferFrom(
          address(this),
          initiator,
          vars.airdropTokenIds[typeIndex],
          vars.airdropBalance,
          new bytes(0)
        );
      } else if (vars.airdropTokenTypes[typeIndex] == 4) {
        IERC721Enumerable(vars.airdropTokenAddresses[typeIndex]).safeTransferFrom(
          address(this),
          initiator,
          vars.airdropTokenIds[typeIndex]
        );
      }
    }

    return true;
  }

  function transferERC20(
    address token,
    address to,
    uint256 amount
  ) external nonReentrant onlyOwner {

    IERC20(token).transfer(to, amount);
  }

  function transferERC721(
    address token,
    address to,
    uint256 id
  ) external nonReentrant onlyOwner {

    IERC721(token).safeTransferFrom(address(this), to, id);
  }

  function transferERC1155(
    address token,
    address to,
    uint256 id,
    uint256 amount
  ) external nonReentrant onlyOwner {

    IERC1155(token).safeTransferFrom(address(this), to, id, amount, new bytes(0));
  }

  function transferEther(address to, uint256 amount) external nonReentrant onlyOwner {

    (bool success, ) = to.call{value: amount}(new bytes(0));
    require(success, "ETH_TRANSFER_FAILED");
  }

  function getAirdropClaimRecord(
    address initiator,
    address nftAsset,
    uint256[] calldata nftTokenIds,
    bytes calldata params
  ) public view returns (bool) {

    bytes32 airdropKeyHash = getClaimKeyHash(initiator, nftAsset, nftTokenIds, params);
    return airdropClaimRecords[airdropKeyHash];
  }

  function encodeFlashLoanParams(
    uint256[] calldata airdropTokenTypes,
    address[] calldata airdropTokenAddresses,
    uint256[] calldata airdropTokenIds,
    address airdropContract,
    bytes calldata airdropParams
  ) public pure returns (bytes memory) {

    return abi.encode(airdropTokenTypes, airdropTokenAddresses, airdropTokenIds, airdropContract, airdropParams);
  }

  function getClaimKeyHash(
    address initiator,
    address nftAsset,
    uint256[] calldata nftTokenIds,
    bytes calldata params
  ) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(initiator, nftAsset, nftTokenIds, params));
  }
}