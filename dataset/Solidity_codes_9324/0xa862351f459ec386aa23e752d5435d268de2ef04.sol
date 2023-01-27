



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

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {

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

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}




pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}




pragma solidity ^0.8.0;

interface IERC20 {

    function claim(uint256[] memory indices) external returns (uint256);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}



pragma solidity ^0.8.0;


interface IWrapperChildImpl {

    function initialize(address user) external;

    function unwrap(uint256 num) external;

}

interface IWrapperParent {

  function nftxFund() external view returns (address);

  function xToken() external view returns (address);

  function vaultID() external view returns (uint256);

}

interface INFTXFund {

    function mint(uint256 vaultId, uint256[] memory nftIds, uint256 d2Amount) external;

    function redeem(uint256 game, uint256 option) external;

}

interface IWaifuDungeon {

    function commitSwapWaifus(uint256[] calldata _ids) external;

    function revealWaifus() external;

}

contract WrapperChildImpl {

  IERC721 constant WAIFUSION = IERC721(0x2216d47494E516d8206B70FCa8585820eD3C4946);
  IERC20 constant WET = IERC20(0x76280AF9D18a868a0aF3dcA95b57DDE816c1aaf2);
  IWaifuDungeon constant WAIFU_DUNGEON = IWaifuDungeon(0xB291984262259BcFe6Aa02b66a06e9769C5c1eF3);
  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
  uint256 private constant UNSET = 1 << 255;
  uint256 private constant MAX_SWAP = 3;

  bool private initialized;
  IWrapperParent public parent;
  address public user; 

  uint256 private receivedNftID;

  function initialize(address _parent, address _user) external {

    require(!initialized, "already initialized");
    initialized = true;

    parent = IWrapperParent(_parent);
    user = _user;
    IERC20(parent.xToken()).approve(parent.nftxFund(), type(uint256).max);
    WET.approve(address(WAIFU_DUNGEON), type(uint256).max);

    WAIFUSION.setApprovalForAll(address(WAIFU_DUNGEON), true);
    receivedNftID = UNSET;
  }

  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {

      if (from == address(WAIFU_DUNGEON)) {
        IERC721(msg.sender).safeTransferFrom(address(this), user, tokenId);
      } else if (from == address(parent.nftxFund())) {
        receivedNftID = tokenId;
      } else {
        revert("invalid from");
      }
      return _ERC721_RECEIVED;
  }

  function commitSwapWaifus(uint256 num) external onlyParent() {

    IERC20(parent.xToken()).transferFrom(user, address(this), num * 1 ether);
    uint256[] memory ids = new uint256[](num);
    for (uint256 i = 0; i < num; i++) {
      INFTXFund(parent.nftxFund()).redeem(parent.vaultID(), 1);
      ids[i] = receivedNftID;
    }
    WET.transferFrom(user, address(this), num * 5490 ether);
    WAIFU_DUNGEON.commitSwapWaifus(ids);
  }

  function revealWaifus() external onlyParent() {

    WAIFU_DUNGEON.revealWaifus();
  }

  modifier onlyParent() {

    require(msg.sender == address(parent), "not parent");
    _;
  } 
}



pragma solidity ^0.8.0;



contract NFTXDungeonWrapper {

  address immutable wrapperChildImpl;
  address public nftxFund = 0xAf93fCce0548D3124A5fC3045adAf1ddE4e8Bf7e; 
  address public xToken = 0x0F10E6ec76346c2362897BFe948c8011BB72880F;
  uint256 public vaultID = 37;

  constructor() {
    address impl = address(new WrapperChildImpl());
    wrapperChildImpl = impl;
  }

  function commitWaifusWithNFTX(uint256 num) external {

    address userWrapper = checkChild();
    WrapperChildImpl(userWrapper).commitSwapWaifus(num);
  }

  function revealWaifusWithNFTX() external {

    address userWrapper = checkChild();
    WrapperChildImpl(userWrapper).revealWaifus();
  }

  function userWrapperAddr(address user) public view returns (address) {

    bytes32 salt = keccak256(abi.encodePacked(address(this), user));
    return Clones.predictDeterministicAddress(wrapperChildImpl, salt);
  }

  function checkChild() public returns (address) {

    address properWrapper = userWrapperAddr(msg.sender);
    if (!Address.isContract(properWrapper)) {
      bytes32 salt = keccak256(abi.encodePacked(address(this), msg.sender));
      address wrapper = Clones.cloneDeterministic(wrapperChildImpl, salt);
      WrapperChildImpl(wrapper).initialize(address(this), msg.sender); 
    }
    return properWrapper;
  }
}