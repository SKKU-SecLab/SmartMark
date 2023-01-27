
pragma solidity ^0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT
pragma solidity ^0.8.0;


interface MintableCollection is IERC721 {

    function burn(uint256 tokenId) external;

    function mint(address to, uint256 tokenId) external;

}// MIT
pragma solidity ^0.8.0;


contract TokenClaiming is Initializable, OwnableUpgradeable  {

  using SafeERC20Upgradeable for IERC20Upgradeable;
  MintableCollection private nftCollection;

  struct TokenPoolInfo {
    uint256 claimStartDate; // timestamp of when users are allowed to claim
    bool isLocked;  // boolean to lock a pool
    bool exists; 
    IERC20Upgradeable tokenContract; // address of the rewards-token
    mapping(uint256 => PmonNft) whiteListedNftIds; // mapping with the whitelisted NFT ids
    uint256[] whiteListedNftIdsAsArray; // array with the whitelisted NFT ids
    uint256 qualifyingNftAmount; // counter for how many NFT ids have been whitelisted - the ones who claimed
    uint256 depositedAmount;  // cumulative sum of added rewards for a pool
    uint256 claimedRewards; // cumulative sum of claimed rewards for a pool
    string pmonType; //the type of the Polychain Monsters that are eligible for this pool
  }

  struct PmonNft {
    bool whitelisted;
    bool hasClaimed;
  }

  string[] public pmonTypesWithPools;

  event PoolCreated(string indexed pmonType, address indexed tokenContract);
  event TokensDeposited(string indexed pmonType, address indexed tokenContract, uint256 amount);
  event TokensClaimed(string indexed pmonType, address indexed tokenContract, address indexed receiver, uint256 amount, uint256 nftId);

  uint256 private constant ROUNDING_PRECISION = 1e12;

  mapping(string => TokenPoolInfo) public pools;

  modifier poolExists(string memory pmonType) {

    require(pools[pmonType].exists, "TokenClaiming: Pool does not exist");
    _;
  }

  modifier poolNotExists(string memory pmonType) {

    require(!pools[pmonType].exists, "TokenClaiming: Pool already exists");
    _;
  }

  modifier poolNotLocked(string memory pmonType) {

    require(!pools[pmonType].isLocked, "TokenClaiming: Pool is locked");
    _;
  }

  modifier poolClaimStarted(string memory pmonType) {

    require(pools[pmonType].claimStartDate <= block.timestamp, "TokenClaiming: Claim not allowed yet");
    _;
  }

  function initialize(MintableCollection _nftCollection) public initializer {

    nftCollection = _nftCollection;
    OwnableUpgradeable.__Ownable_init();
  }

  function addPool(
    string memory pmonType, // //the type of the Polychain Monsters that are eligible for this pool
    IERC20Upgradeable tokenContract, // address of the rewards-token
    uint256 claimStartDate // start date timestamp in seconds
  ) external onlyOwner poolNotExists(pmonType) {

    TokenPoolInfo storage pool = pools[pmonType];
    pool.claimStartDate = claimStartDate;
    pool.isLocked = false;
    pool.exists = true;
    pool.tokenContract = tokenContract;
    pool.pmonType = pmonType;

    pmonTypesWithPools.push(pmonType);

    emit PoolCreated(pmonType, address(tokenContract));
  }

  function deposit(
    string memory pmonType,
    uint256 amount // the token amount that should be added to the pool
  ) public onlyOwner poolExists(pmonType) poolNotLocked(pmonType) {

    TokenPoolInfo storage pool = pools[pmonType];

    pool.tokenContract.transferFrom(msg.sender, address(this), amount);
    pool.depositedAmount = pool.depositedAmount + amount;

    emit TokensDeposited(pmonType, address(pool.tokenContract), amount);
  }

  function claim(string memory pmonType, uint256 nftId)
    external
    poolExists(pmonType)
    poolNotLocked(pmonType)
    poolClaimStarted(pmonType)
  {

    TokenPoolInfo storage pool = pools[pmonType];
    require(pool.whiteListedNftIds[nftId].whitelisted, "TokenClaiming: NFT not whitelisted");
    require(!pool.whiteListedNftIds[nftId].hasClaimed, "TokenClaiming: Already claimed");
    
    require(nftCollection.ownerOf(nftId) == msg.sender, "TokenClaiming: Sender is not the owner");

    nftCollection.burn(nftId);
    pool.whiteListedNftIds[nftId].hasClaimed = true;

    uint256 claimAmount = pool.depositedAmount / pool.qualifyingNftAmount;
    safeClaimTransfer(pmonType, msg.sender, claimAmount);
    pool.qualifyingNftAmount = pool.qualifyingNftAmount - 1;

    emit TokensClaimed(pmonType, address(pool.tokenContract), msg.sender, claimAmount, nftId);
  }

  function availableForClaim(string memory pmonType, uint256 nftId)
    external
    view
    poolExists(pmonType)
    poolNotLocked(pmonType)
    poolClaimStarted(pmonType)
    returns (uint256)
  {

    TokenPoolInfo storage pool = pools[pmonType];
    require(pool.whiteListedNftIds[nftId].whitelisted, "TokenClaiming: NFT not whitelisted");
    require(!pool.whiteListedNftIds[nftId].hasClaimed, "TokenClaiming: Already claimed");
    require(_getOwnerOfNft(nftId) != address(0), "TokenClaiming: NFT was burned");

    return pool.depositedAmount / pool.qualifyingNftAmount;
  }

  function whitelistNftIds(string memory pmonType, uint256[] memory nftIds)
    external
    onlyOwner
    poolExists(pmonType)
  {

    TokenPoolInfo storage pool = pools[pmonType];
    for (uint256 i = 0; i < nftIds.length; i++) {
      pool.whiteListedNftIds[nftIds[i]] = PmonNft({
        whitelisted: true,
        hasClaimed: false
      });
      pool.whiteListedNftIdsAsArray.push(nftIds[i]);
    }
    pool.qualifyingNftAmount = pool.qualifyingNftAmount + nftIds.length;
  }

  function getAddressesWithWhitelistedNfts(string memory pmonType) external
    view
    poolExists(pmonType)
    poolNotLocked(pmonType)
    poolClaimStarted(pmonType) returns (address[] memory, uint256[] memory )
    {

      TokenPoolInfo storage pool = pools[pmonType];
      address[] memory addresses = new address[](pool.whiteListedNftIdsAsArray.length); 
      for (uint256 i = 0; i < pool.whiteListedNftIdsAsArray.length; i++) {
        addresses[i] = _getOwnerOfNft(pool.whiteListedNftIdsAsArray[i]);
      }
      return (addresses, pool.whiteListedNftIdsAsArray);
    }

  function _getOwnerOfNft(uint256 nftId) internal view returns (address) {

      try nftCollection.ownerOf(nftId) returns (address owner) {
            return owner;
        } catch Error(string memory) {
            return address(0);
        } catch (bytes memory) {
            return address(0);
        }
  }

  function safeClaimTransfer(string memory pmonType, address to, uint256 amount) internal {

    TokenPoolInfo storage pool = pools[pmonType];
    if (amount > pool.depositedAmount) {
      pool.tokenContract.transfer(to, pool.depositedAmount);
      pool.depositedAmount = 0;
    } else {
      pool.tokenContract.transfer(to, amount);
      pool.depositedAmount = pool.depositedAmount - amount;
    }
  }

  function getPoolNumber() external view returns (uint256) {

    return pmonTypesWithPools.length;
  }
}