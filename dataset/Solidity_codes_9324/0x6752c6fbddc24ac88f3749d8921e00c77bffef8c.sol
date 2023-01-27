
pragma solidity >=0.5.0;

interface IMemberRoles {


  enum Role {UnAssigned, AdvisoryBoard, Member, Owner}

  function payJoiningFee(address _userAddress) external payable;


  function switchMembership(address _newAddress) external;


  function switchMembershipOf(address member, address _newAddress) external;


  function swapOwner(address _newOwnerAddress) external;


  function kycVerdict(address payable _userAddress, bool verdict) external;


  function getClaimPayoutAddress(address payable _member) external view returns (address payable);


  function setClaimPayoutAddress(address payable _address) external;


  function totalRoles() external view returns (uint256);


  function changeAuthorized(uint _roleId, address _newAuthorized) external;


  function members(uint _memberRoleId) external view returns (uint, address[] memory memberArray);


  function numberOfMembers(uint _memberRoleId) external view returns (uint);


  function authorized(uint _memberRoleId) external view returns (address);


  function roles(address _memberAddress) external view returns (uint[] memory);


  function checkRole(address _memberAddress, uint _roleId) external view returns (bool);


  function getMemberLengthForAllRoles() external view returns (uint[] memory totalMembers);


  function memberAtIndex(uint _memberRoleId, uint index) external view returns (address, bool);


  function membersLength(uint _memberRoleId) external view returns (uint);

}// GPL-3.0-only

pragma solidity >=0.5.0;

interface INXMMaster {


  function tokenAddress() external view returns (address);


  function owner() external view returns (address);


  function pauseTime() external view returns (uint);


  function masterInitialized() external view returns (bool);


  function isInternal(address _add) external view returns (bool);


  function isPause() external view returns (bool check);


  function isOwner(address _add) external view returns (bool);


  function isMember(address _add) external view returns (bool);


  function checkIsAuthToGoverned(address _add) external view returns (bool);


  function updatePauseTime(uint _time) external;


  function dAppLocker() external view returns (address _add);


  function dAppToken() external view returns (address _add);


  function getLatestAddress(bytes2 _contractName) external view returns (address payable contractAddress);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping (uint256 => address) private _owners;

    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}// GPL-3.0-only

pragma solidity >=0.5.0;

interface IGateway {

  enum ClaimStatus { IN_PROGRESS, ACCEPTED, REJECTED }

  enum CoverType { SIGNED_QUOTE_CONTRACT_COVER }

  function buyCover (
    address contractAddress,
    address coverAsset,
    uint sumAssured,
    uint16 coverPeriod,
    CoverType coverType,
    bytes calldata data
  ) external payable returns (uint);

  function getCoverPrice (
    address contractAddress,
    address coverAsset,
    uint sumAssured,
    uint16 coverPeriod,
    CoverType coverType,
    bytes calldata data
  ) external view returns (uint coverPrice);

  function getCover(uint coverId)
  external
  view
  returns (
    uint8 status,
    uint sumAssured,
    uint16 coverPeriod,
    uint validUntil,
    address contractAddress,
    address coverAsset,
    uint premiumInNXM,
    address memberAddress
  );

  function submitClaim(uint coverId, bytes calldata data) external returns (uint);

  function claimTokens(
    uint coverId,
    uint incidentId,
    uint coveredTokenAmount,
    address coverAsset
  ) external returns (uint claimId, uint payoutAmount, address payoutToken);

  function getClaimCoverId(uint claimId) external view returns (uint);

  function getPayoutOutcome(uint claimId) external view returns (ClaimStatus status, uint paidAmount, address asset);

  function executeCoverAction(uint tokenId, uint8 action, bytes calldata data) external payable returns (bytes memory, uint);

  function switchMembership(address _newAddress) external;
}// GPL-3.0-only

pragma solidity >=0.5.0;

interface IPriceFeedOracle {

  function daiAddress() external view returns (address);
  function stETH() external view returns (address);
  function ETH() external view returns (address);

  function getAssetToEthRate(address asset) external view returns (uint);
  function getAssetForEth(address asset, uint ethIn) external view returns (uint);

}// GPL-3.0-only

pragma solidity >=0.5.0;


interface IPool {
  function sellNXM(uint tokenAmount, uint minEthOut) external;

  function sellNXMTokens(uint tokenAmount) external returns (bool);

  function minPoolEth() external returns (uint);

  function transferAssetToSwapOperator(address asset, uint amount) external;

  function setAssetDataLastSwapTime(address asset, uint32 lastSwapTime) external;

  function getAssetDetails(address _asset) external view returns (
    uint112 min,
    uint112 max,
    uint32 lastAssetSwapTime,
    uint maxSlippageRatio
  );

  function sendClaimPayout (
    address asset,
    address payable payoutAddress,
    uint amount
  ) external returns (bool success);

  function transferAsset(
    address asset,
    address payable destination,
    uint amount
  ) external;

  function upgradeCapitalPool(address payable newPoolAddress) external;

  function priceFeedOracle() external view returns (IPriceFeedOracle);

  function getPoolValueInEth() external view returns (uint);


  function transferAssetFrom(address asset, address from, uint amount) external;

  function getEthForNXM(uint nxmAmount) external view returns (uint ethAmount);

  function calculateEthForNXM(
    uint nxmAmount,
    uint currentTotalAssetValue,
    uint mcrEth
  ) external pure returns (uint);

  function calculateMCRRatio(uint totalAssetValue, uint mcrEth) external pure returns (uint);

  function calculateTokenSpotPrice(uint totalAssetValue, uint mcrEth) external pure returns (uint tokenPrice);

  function getTokenPrice(address asset) external view returns (uint tokenPrice);

  function getMCRRatio() external view returns (uint);
}// GPL-3.0-only

pragma solidity ^0.8.0;


contract Distributor is ERC721, Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  event ClaimPayoutRedeemed (
    uint indexed coverId,
    uint indexed claimId,
    address indexed receiver,
    uint amountPaid,
    address coverAsset
  );

  event ClaimSubmitted (
    uint indexed coverId,
    uint indexed claimId,
    address indexed submitter
  );

  event CoverBought (
    uint indexed coverId,
    address indexed buyer,
    address indexed contractAddress,
    uint feePercentage,
    uint coverPrice
  );

  event FeePercentageChanged (
    uint feePercentage
  );

  event BuysAllowedChanged (
    bool buysAllowed
  );

  event TreasuryChanged (
    address treasury
  );

  uint public feePercentage;
  bool public buysAllowed = true;
  address payable public treasury;

  IGateway immutable public gateway;
  IERC20 immutable public nxmToken;
  INXMMaster immutable public master;

  modifier onlyTokenApprovedOrOwner(uint256 tokenId) {
    require(_isApprovedOrOwner(msg.sender, tokenId), "Distributor: Not approved or owner");
    _;
  }

  constructor(
    address gatewayAddress,
    address nxmTokenAddress,
    address masterAddress,
    uint _feePercentage,
    address payable _treasury,
    string memory tokenName,
    string memory tokenSymbol
  )
  ERC721(tokenName, tokenSymbol)
  {

    require(_treasury != address(0), "Distributor: treasury address is 0");
    feePercentage = _feePercentage;
    treasury = _treasury;
    gateway = IGateway(gatewayAddress);
    nxmToken = IERC20(nxmTokenAddress);
    master = INXMMaster(masterAddress);
  }

  function buyCover (
    address contractAddress,
    address coverAsset,
    uint sumAssured,
    uint16 coverPeriod,
    uint8 coverType,
    uint maxPriceWithFee,
    bytes calldata data
  )
    external
    payable
    nonReentrant
    returns (uint)
  {
    require(buysAllowed, "Distributor: buys not allowed");

    uint coverPrice = gateway.getCoverPrice(contractAddress, coverAsset, sumAssured, coverPeriod, IGateway.CoverType(coverType), data);
    uint coverPriceWithFee = feePercentage * coverPrice / 10000 + coverPrice;
    require(coverPriceWithFee <= maxPriceWithFee, "Distributor: cover price with fee exceeds max");

    uint buyCoverValue = 0;
    if (coverAsset == ETH) {
      require(msg.value >= coverPriceWithFee, "Distributor: Insufficient ETH sent");
      uint remainder = msg.value - coverPriceWithFee;

      if (remainder > 0) {
        (bool ok, /* data */) = address(msg.sender).call{value: remainder}("");
        require(ok, "Distributor: Returning ETH remainder to sender failed.");
      }

      buyCoverValue = coverPrice;
    } else {
      IERC20 token = IERC20(coverAsset);
      token.safeTransferFrom(msg.sender, address(this), coverPriceWithFee);
      token.approve(address(gateway), coverPrice);
    }

    uint coverId = gateway.buyCover{value: buyCoverValue }(
      contractAddress,
      coverAsset,
      sumAssured,
      coverPeriod,
      IGateway.CoverType(coverType),
      data
    );

    transferToTreasury(coverPriceWithFee - coverPrice, coverAsset);

    _mint(msg.sender, coverId);

    emit CoverBought(coverId, msg.sender, contractAddress, feePercentage, coverPrice);
    return coverId;
  }

  function submitClaim(
    uint tokenId,
    bytes calldata data
  )
    external
    onlyTokenApprovedOrOwner(tokenId)
    returns (uint)
  {
    uint claimId = gateway.submitClaim(tokenId, data);
    emit ClaimSubmitted(tokenId, claimId, msg.sender);
    return claimId;
  }

  function claimTokens(
    uint tokenId,
    uint incidentId,
    uint coveredTokenAmount,
    address coverAsset
  )
    external
    onlyTokenApprovedOrOwner(tokenId)
    returns (uint claimId, uint payoutAmount, address payoutToken)
  {
    IERC20 token = IERC20(coverAsset);
    token.safeTransferFrom(msg.sender, address(this), coveredTokenAmount);
    token.approve(address(gateway), coveredTokenAmount);
    (claimId, payoutAmount, payoutToken) = gateway.claimTokens(
      tokenId,
      incidentId,
      coveredTokenAmount,
      coverAsset
    );
    _burn(tokenId);
    if (payoutToken == ETH) {
      (bool ok, /* data */) = address(msg.sender).call{value: payoutAmount}("");
      require(ok, "Distributor: ETH transfer to sender failed.");
    } else {
      IERC20(payoutToken).safeTransfer(msg.sender, payoutAmount);
    }
    emit ClaimSubmitted(tokenId, claimId, msg.sender);
  }

  function redeemClaim(
    uint256 tokenId,
    uint claimId
  )
    public
    onlyTokenApprovedOrOwner(tokenId)
    nonReentrant
  {
    uint coverId = gateway.getClaimCoverId(claimId);
    require(coverId == tokenId, "Distributor: coverId claimId mismatch");
    (IGateway.ClaimStatus status, uint amountPaid, address coverAsset) = gateway.getPayoutOutcome(claimId);
    require(status == IGateway.ClaimStatus.ACCEPTED, "Distributor: Claim not accepted");

    _burn(tokenId);
    if (coverAsset == ETH) {
      (bool ok, /* data */) = msg.sender.call{value: amountPaid}("");
      require(ok, "Distributor: Transfer to NFT owner failed");
    } else {
      IERC20 erc20 = IERC20(coverAsset);
      erc20.safeTransfer(msg.sender, amountPaid);
    }

    emit ClaimPayoutRedeemed(tokenId, claimId, msg.sender, amountPaid, coverAsset);
  }

  function executeCoverAction(uint tokenId, uint assetAmount, address asset, uint8 action, bytes calldata data)
    external
    payable
    onlyTokenApprovedOrOwner(tokenId)
    nonReentrant
    returns (bytes memory response, uint withheldAmount)
  {
    if (assetAmount == 0) {
      return gateway.executeCoverAction(tokenId, action, data);
    }
    uint remainder;
    if (asset == ETH) {
      require(msg.value >= assetAmount, "Distributor: Insufficient ETH sent");
      (response, withheldAmount) = gateway.executeCoverAction{ value: msg.value }(tokenId, action, data);
      remainder = assetAmount - withheldAmount;
      (bool ok, /* data */) = address(msg.sender).call{value: remainder}("");
      require(ok, "Distributor: Returning ETH remainder to sender failed.");
      return (response, withheldAmount);
    }

    IERC20 token = IERC20(asset);
    token.safeTransferFrom(msg.sender, address(this), assetAmount);
    token.approve(address(gateway), assetAmount);
    (response, withheldAmount) = gateway.executeCoverAction(tokenId, action, data);
    remainder = assetAmount - withheldAmount;
    token.safeTransfer(msg.sender, remainder);
    return (response, withheldAmount);
  }

  function getCover(uint tokenId)
  public
  view
  returns (
    uint8 status,
    uint sumAssured,
    uint16 coverPeriod,
    uint validUntil,
    address contractAddress,
    address coverAsset,
    uint premiumInNXM,
    address memberAddress
  ) {
    return gateway.getCover(tokenId);
  }

  function getPayoutOutcome(uint claimId)
  public
  view
  returns (IGateway.ClaimStatus status, uint amountPaid, address coverAsset)
  {
    (status, amountPaid, coverAsset) = gateway.getPayoutOutcome(claimId);
  }

  function approveNXM(address spender, uint256 amount) public onlyOwner {
    nxmToken.approve(spender, amount);
  }

  function withdrawNXM(address recipient, uint256 amount) public onlyOwner {
    nxmToken.safeTransfer(recipient, amount);
  }

  function switchMembership(address newAddress) external onlyOwner {
    nxmToken.approve(address(gateway), type(uint).max);
    gateway.switchMembership(newAddress);
  }

  function sellNXM(uint nxmIn, uint minEthOut) external onlyOwner {

    address poolAddress = master.getLatestAddress("P1");
    nxmToken.approve(poolAddress, nxmIn);
    uint balanceBefore = address(this).balance;
    IPool(poolAddress).sellNXM(nxmIn, minEthOut);
    uint balanceAfter = address(this).balance;

    transferToTreasury(balanceAfter - balanceBefore, ETH);
  }

  function setBuysAllowed(bool _buysAllowed) external onlyOwner {
    buysAllowed = _buysAllowed;
    emit BuysAllowedChanged(_buysAllowed);
  }

  function setTreasury(address payable _treasury) external onlyOwner {
    require(_treasury != address(0), "Distributor: treasury address is 0");
    treasury = _treasury;
    emit TreasuryChanged(_treasury);
  }

  function transferToTreasury(uint amount, address asset) internal {
    if (asset == ETH) {
      (bool ok, /* data */) = treasury.call{value: amount}("");
      require(ok, "Distributor: Transfer to treasury failed");
    } else {
      IERC20 erc20 = IERC20(asset);
      erc20.safeTransfer(treasury, amount);
    }
  }

  function setFeePercentage(uint _feePercentage) external onlyOwner {
    feePercentage = _feePercentage;
    emit FeePercentageChanged(_feePercentage);
  }

  receive () payable external {
  }
}// GPL-3.0-only

pragma solidity ^0.8.0;


contract DistributorFactory {
  INXMMaster immutable public master;

  event DistributorCreated(
    address contractAddress,
    address owner,
    uint feePercentage,
    address treasury
  );

  constructor (address masterAddress) {
    master = INXMMaster(masterAddress);
  }

  function newDistributor(
    uint _feePercentage,
    address payable treasury,
    string memory tokenName,
    string memory tokenSymbol
  ) public payable returns (address) {

    IMemberRoles memberRoles = IMemberRoles(master.getLatestAddress("MR"));
    Distributor d = new Distributor(
      master.getLatestAddress("GW"),
      master.tokenAddress(),
      address(master),
      _feePercentage,
      treasury,
      tokenName,
      tokenSymbol
    );
    d.transferOwnership(msg.sender);
    memberRoles.payJoiningFee{ value: msg.value}(address(d));

    emit DistributorCreated(address(d), msg.sender, _feePercentage, treasury);
    return address(d);
  }
}