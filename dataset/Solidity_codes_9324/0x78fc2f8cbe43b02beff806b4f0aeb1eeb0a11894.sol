pragma solidity ^0.8.0;

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);


  function approve(address spender, uint256 value) external returns (bool success);


  function balanceOf(address owner) external view returns (uint256 balance);


  function decimals() external view returns (uint8 decimalPlaces);


  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);


  function increaseApproval(address spender, uint256 subtractedValue) external;


  function name() external view returns (string memory tokenName);


  function symbol() external view returns (string memory tokenSymbol);


  function totalSupply() external view returns (uint256 totalTokensIssued);


  function transfer(address to, uint256 value) external returns (bool success);


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);


  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);

}// MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {

  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );


  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);


  function createSubscription() external returns (uint64 subId);


  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );


  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;


  function acceptSubscriptionOwnerTransfer(uint64 subId) external;


  function addConsumer(uint64 subId, address consumer) external;


  function removeConsumer(uint64 subId, address consumer) external;


  function cancelSubscription(uint64 subId, address to) external;

}// MIT
pragma solidity ^0.8.0;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
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

pragma solidity ^0.8.4;


error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintedQueryForZeroAddress();
error BurnedQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerIndexOutOfBounds();
error OwnerQueryForNonexistentToken();
error TokenIndexOutOfBounds();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error URIQueryForNonexistentToken();

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
    }

    struct AddressData {
        uint64 balance;
        uint64 numberMinted;
        uint64 numberBurned;
    }

    
    uint128 internal _currentIndex;

    uint128 internal _burnCounter;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) internal _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function totalSupply() public view override returns (uint256) {

        unchecked {
            return _currentIndex - _burnCounter;    
        }
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        uint256 numMintedSoFar = _currentIndex;
        uint256 tokenIdsIdx;

        unchecked {
            for (uint256 i; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = _ownerships[i];
                if (!ownership.burned) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }
        revert TokenIndexOutOfBounds();
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        if (index >= balanceOf(owner)) revert OwnerIndexOutOfBounds();
        uint256 numMintedSoFar = _currentIndex;
        uint256 tokenIdsIdx;
        address currOwnershipAddr;

        unchecked {
            for (uint256 i; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = _ownerships[i];
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }

        revert();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        if (owner == address(0)) revert MintedQueryForZeroAddress();
        return uint256(_addressData[owner].numberMinted);
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        if (owner == address(0)) revert BurnedQueryForZeroAddress();
        return uint256(_addressData[owner].numberBurned);
    }

    function ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        uint256 curr = tokenId;

        unchecked {
            if (curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {

        if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        _mint(to, quantity, _data, true);
    }

    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {

        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;

            for (uint256 i; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex);
                if (safe && !_checkOnERC721Received(address(0), to, updatedIndex, _data)) {
                    revert TransferToNonERC721ReceiverImplementer();
                }
                updatedIndex++;
            }

            _currentIndex = uint128(updatedIndex);
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
            isApprovedForAll(prevOwnership.addr, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            _ownerships[tokenId].addr = to;
            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);

            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                if (nextTokenId < _currentIndex) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _burn(uint256 tokenId) internal virtual {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        _beforeTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        unchecked {
            _addressData[prevOwnership.addr].balance -= 1;
            _addressData[prevOwnership.addr].numberBurned += 1;

            _ownerships[tokenId].addr = prevOwnership.addr;
            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);
            _ownerships[tokenId].burned = true;

            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                if (nextTokenId < _currentIndex) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(prevOwnership.addr, address(0), tokenId);
        _afterTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

        unchecked { 
            _burnCounter++;
        }
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert TransferToNonERC721ReceiverImplementer();
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

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.12;


error PublicSaleOpen();
error PublicSaleNotOpen();
error TokenMintedOut();
error TokenNotMintedOut();

contract Schedule is Ownable {
    uint256 public publicSaleStartTimestamp;
    uint256 public mintedOutTimestamp;

    function openPublicSale() external onlyOwner whenPublicSaleClosed {
        publicSaleStartTimestamp = block.timestamp;
    }

    function isPublicSaleOpen() public view virtual returns (bool) {
        return
            publicSaleStartTimestamp != 0 &&
            block.timestamp > publicSaleStartTimestamp;
    }

    modifier whenPublicSaleOpen() {
        if (!isPublicSaleOpen()) revert PublicSaleNotOpen();
        _;
    }

    modifier whenPublicSaleClosed() {
        if (isPublicSaleOpen()) revert PublicSaleOpen();
        _;
    }

    function isMintedOut() public view virtual returns (bool) {
        return mintedOutTimestamp > 0;
    }

    modifier whenMintedOut() {
        if (!isMintedOut()) revert TokenNotMintedOut();
        _;
    }

    modifier whenNotMintedOut() {
        if (isMintedOut()) revert TokenMintedOut();
        _;
    }
}// MIT

pragma solidity ^0.8.12;


error BatchLimitExceeded();
error WrongPrice(uint256 paidPrice, uint256 expectedPrice);
error TotalSupplyExceeded();
error AllocationExceeded();
error ToggleMettaCallerNotOwner();
error ChainlinkSubscriptionNotFound();
error TransferFailed();
error MysteryChallengeSenderDoesNotOwnENS();
error MysteryChallengeValueDoesNotMatch();
error FulfillmentAlreadyFulfilled();
error FulfillRequestForNonExistentContest();
error FulfillRequestWithTokenNotOwnedByWinner();
error FulfillRequestWithTokenOutOfBounds();
error RedeemTokenNotOwner();
error RedeemTokenAlreadyRedeemed();
error NoGiveawayToTrigger();
error InsufficientFunds();
error WithdrawalFailed();
error FailSafeWithdrawalNotEnabled();
error FulfillRequestRedrawn();
error NonexistentRenderer();

contract CoBotsV2 is
    ERC721A,
    VRFConsumerBaseV2,
    Ownable,
    ReentrancyGuard,
    Schedule
{
    event RendererContractUpdated(address indexed renderer);
    event MettaToggled(uint256 indexed tokenId, bool isMetta);
    event CheckpointDrawn(uint256 indexed requestId, Prize prize);
    event CheckpointFulfilled(
        uint256 indexed requestId,
        Prize prize,
        Winner winner
    );
    event GiveawayFinished();
    event Withdrawal(uint256 amount);
    event DrawBeforeWithdrawal();

    struct Prize {
        uint16 checkpoint;
        uint72 amount;
        bool isContest;
    }

    struct MysteryChallenge {
        uint256 ensId;
        uint256 value;
        uint8 prizeIndex;
    }

    struct Parameters {
        uint16 mintOutFoundersWithdrawalDelay;
        uint16 grandPrizeDelay;
        uint16 maxCobots;
        uint24 contestDuration;
        uint72 mintPublicPrice;
        uint72 cobotsV1Discount;
    }

    uint8 public constant MINT_FOUNDERS = 3;
    uint8 public constant MINT_BATCH_LIMIT = 32;
    Parameters public PARAMETERS;
    Prize[] public PRIZES;
    MysteryChallenge private MYSTERY_CHALLENGE;
    IERC721 public immutable ENS;
    IERC721Enumerable public immutable COBOTS_V1;
    address public immutable COBOTS_V1_ADDRESS;


    address public renderingContractAddress;
    ICoBotsRendererV2 public renderer;
    uint8[] public coBotsSeeds;
    mapping(uint256 => bool) public coBotsV1Redeemed;
    uint256 private _redeemedCount;

    function setRenderingContractAddress(address _renderingContractAddress)
        public
        onlyOwner
    {
        renderingContractAddress = _renderingContractAddress;
        renderer = ICoBotsRendererV2(renderingContractAddress);
        emit RendererContractUpdated(renderingContractAddress);
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address _rendererAddress,
        address vrfCoordinator,
        address link,
        bytes32 keyHash,
        Parameters memory _parameters,
        Prize[] memory _prizes,
        address ens,
        address cobotsV1,
        MysteryChallenge memory _mysteryChallenge
    ) ERC721A(name_, symbol_) VRFConsumerBaseV2(vrfCoordinator) {
        setRenderingContractAddress(_rendererAddress);
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        gasKeyHash = keyHash;
        PARAMETERS = _parameters;
        uint256 _prizesLength = _prizes.length;
        for (uint256 i = 0; i < _prizesLength; ) {
            PRIZES.push(_prizes[i]);
            unchecked {
                ++i;
            }
        }
        ENS = IERC721(ens);
        COBOTS_V1_ADDRESS = cobotsV1;
        COBOTS_V1 = IERC721Enumerable(cobotsV1);
        MYSTERY_CHALLENGE = _mysteryChallenge;
    }

    function _mintCoBots(address to, uint256 quantity) internal {
        if (quantity > MINT_BATCH_LIMIT) revert BatchLimitExceeded();
        bytes32 seeds = keccak256(
            abi.encodePacked(
                quantity,
                msg.sender,
                msg.value,
                block.timestamp,
                block.difficulty
            )
        );
        for (uint256 i = 0; i < quantity; ) {
            coBotsSeeds.push(uint8(seeds[i]) << 1); // insure last digit is 0, used for Metta status
            unchecked {
                ++i;
            }
        }

        ERC721A._safeMint(to, quantity);

        if (_currentIndex == PARAMETERS.maxCobots) {
            mintedOutTimestamp = block.timestamp;
        }
    }

    modifier supplyAvailable(uint256 quantity) {
        if (_currentIndex + quantity > PARAMETERS.maxCobots)
            revert TotalSupplyExceeded();
        _;
    }

    function mintPublicSale(uint256 quantity, uint256[] memory tokenIdsV1)
        external
        payable
        whenPublicSaleOpen
        supplyAvailable(quantity)
        nonReentrant
    {
        uint256 price = PARAMETERS.mintPublicPrice * quantity;

        uint256 redeemed = 0;
        uint256 tokenIdsV1Length = tokenIdsV1.length;
        for (uint256 i = 0; i < tokenIdsV1Length; ) {
            if (COBOTS_V1.ownerOf(tokenIdsV1[i]) != _msgSender())
                revert RedeemTokenNotOwner();
            if (!coBotsV1Redeemed[tokenIdsV1[i]] && redeemed < quantity) {
                coBotsV1Redeemed[tokenIdsV1[i]] = true;
                redeemed++;
                price -=
                    PARAMETERS.mintPublicPrice /
                    PARAMETERS.cobotsV1Discount;
            }
            unchecked {
                ++i;
            }
        }
        _redeemedCount += redeemed;
        if (msg.value != price) revert WrongPrice(price, msg.value);

        _mintCoBots(_msgSender(), quantity);
    }

    function mintFounders(address to, uint256 quantity)
        external
        onlyOwner
        supplyAvailable(quantity)
    {
        if (quantity + _currentIndex > MINT_FOUNDERS)
            revert AllocationExceeded();

        _mintCoBots(to, quantity);
    }

    function isMettaEnabled(uint256 tokenId) external view returns (bool) {
        return coBotsSeeds[tokenId] & 1 == 1;
    }

    function _toggleMetta(uint256 tokenId) internal {
        if (ERC721A.ownerOf(tokenId) != _msgSender())
            revert ToggleMettaCallerNotOwner();

        coBotsSeeds[tokenId] = coBotsSeeds[tokenId] ^ 1;
    }

    function toggleMetta(uint256[] calldata tokenIds) public nonReentrant {
        uint256 tokenIdsLength = tokenIds.length;
        for (uint256 i = 0; i < tokenIdsLength; ) {
            _toggleMetta(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();

        if (renderingContractAddress == address(0)) {
            return "";
        }

        return renderer.tokenURI(_tokenId, coBotsSeeds[_tokenId]);
    }

    function tokenData(uint256 _tokenId)
        public
        view
        returns (TokenData memory)
    {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();

        if (renderingContractAddress == address(0)) {
            revert NonexistentRenderer();
        }

        return renderer.tokenData(_tokenId, coBotsSeeds[_tokenId]);
    }

    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    receive() external payable {}

    function withdraw() public onlyOwner {
        if (_shouldDraw()) {
            emit DrawBeforeWithdrawal();
            draw();
        }

        uint256 balance = address(this).balance;

        uint256 requestIdsLength = requestIds.length;
        for (uint256 i = 0; i < requestIdsLength; ) {
            if (!fulfillments[requestIds[i]].fulfilled) {
                balance -= fulfillments[requestIds[i]].prize.amount;
            }
            unchecked {
                ++i;
            }
        }

        uint256 value = balance;
        if (value == 0) revert InsufficientFunds();

        uint256 remainingVoucher = COBOTS_V1.totalSupply() - _redeemedCount;
        uint256 previousCheckpoint = _currentIndex;

        uint256 prizesLength = PRIZES.length;
        for (uint256 i = requestIds.length; i < prizesLength; ) {
            uint256 remainingBots = PRIZES[i].checkpoint - previousCheckpoint;

            if (remainingVoucher > remainingBots) {
                balance +=
                    remainingBots *
                    (PARAMETERS.mintPublicPrice / PARAMETERS.cobotsV1Discount);
                remainingVoucher -= remainingBots;
            } else {
                balance +=
                    remainingVoucher *
                    (PARAMETERS.mintPublicPrice / PARAMETERS.cobotsV1Discount) +
                    (remainingBots - remainingVoucher) *
                    PARAMETERS.mintPublicPrice;
                remainingVoucher = 0;
            }

            balance -= PRIZES[i].amount;

            if (balance < 1) {
                revert InsufficientFunds();
            }

            if (balance < value) {
                value = balance;
            }
            previousCheckpoint = PRIZES[i].checkpoint;

            unchecked {
                ++i;
            }
        }

        (bool success, ) = _msgSender().call{value: value}("");
        if (!success) revert WithdrawalFailed();
        emit Withdrawal(value);
    }

    function failsafeWithdraw() public onlyOwner whenMintedOut {
        if (
            block.timestamp <
            (mintedOutTimestamp + PARAMETERS.mintOutFoundersWithdrawalDelay)
        ) {
            revert FailSafeWithdrawalNotEnabled();
        }

        uint256 value = address(this).balance;
        (bool success, ) = _msgSender().call{value: value}("");
        if (!success) revert WithdrawalFailed();
        emit Withdrawal(value);
    }

    VRFCoordinatorV2Interface public immutable COORDINATOR;
    LinkTokenInterface public immutable LINKTOKEN;
    bytes32 public immutable gasKeyHash;
    uint64 public chainlinkSubscriptionId;

    function createSubscriptionAndFund(uint96 amount) external nonReentrant {
        if (chainlinkSubscriptionId == 0) {
            chainlinkSubscriptionId = COORDINATOR.createSubscription();
            COORDINATOR.addConsumer(chainlinkSubscriptionId, address(this));
        }
        LINKTOKEN.transferAndCall(
            address(COORDINATOR),
            amount,
            abi.encode(chainlinkSubscriptionId)
        );
    }

    function cancelSubscription() external onlyOwner {
        COORDINATOR.cancelSubscription(chainlinkSubscriptionId, _msgSender());
        chainlinkSubscriptionId = 0;
    }

    struct Winner {
        address winner;
        uint16 tokenId;
    }

    struct Fulfillment {
        Prize prize;
        bool fulfilled;
        Winner winner;
    }

    mapping(uint256 => Fulfillment) public fulfillments;
    uint256[] public requestIds;
    uint256 public drawnAmount;

    function getOrderedFulfillments()
        external
        view
        returns (Fulfillment[] memory)
    {
        Fulfillment[] memory result = new Fulfillment[](requestIds.length);
        for (uint256 i = 0; i < requestIds.length; i++) {
            result[i] = fulfillments[requestIds[i]];
        }
        return result;
    }

    function _shouldDraw() internal view returns (bool) {
        if (requestIds.length == PRIZES.length) {
            return false;
        }
        if (
            (requestIds.length == PRIZES.length - 1) &&
            (block.timestamp < mintedOutTimestamp + PARAMETERS.grandPrizeDelay)
        ) {
            return false;
        }
        if (PRIZES[requestIds.length].checkpoint > _currentIndex) return false;
        return true;
    }

    function redrawPendingFulfillments() public nonReentrant {
        uint256 requestIdsLength = requestIds.length;
        for (uint256 i = 0; i < requestIdsLength; ) {
            if (
                !fulfillments[requestIds[i]].fulfilled &&
                (!fulfillments[requestIds[i]].prize.isContest ||
                    block.timestamp >
                    publicSaleStartTimestamp + PARAMETERS.contestDuration)
            ) {
                uint256 requestId = COORDINATOR.requestRandomWords(
                    gasKeyHash,
                    chainlinkSubscriptionId,
                    5, // requestConfirmations
                    500_000, // callbackGasLimit
                    1 // numWords
                );
                fulfillments[requestId] = Fulfillment(
                    fulfillments[requestIds[i]].prize,
                    false,
                    Winner(address(0), 0)
                );
                delete fulfillments[requestIds[i]];
                requestIds[i] = requestId;
            }

            unchecked {
                ++i;
            }
        }
    }

    function draw() public nonReentrant {
        uint256 drawCounts = requestIds.length;
        if (chainlinkSubscriptionId == 0) {
            revert ChainlinkSubscriptionNotFound();
        }
        if (!_shouldDraw()) revert NoGiveawayToTrigger();
        while (PRIZES[drawCounts].checkpoint < _currentIndex + 1) {
            uint256 requestId;
            if (
                (PRIZES[drawCounts].isContest &&
                    block.timestamp <
                    publicSaleStartTimestamp + PARAMETERS.contestDuration) ||
                (drawCounts == MYSTERY_CHALLENGE.prizeIndex)
            ) {
                requestId = _computeRequestId(drawCounts);
            } else {
                requestId = COORDINATOR.requestRandomWords(
                    gasKeyHash,
                    chainlinkSubscriptionId,
                    5, // requestConfirmations
                    500_000, // callbackGasLimit
                    1 // numWords
                );
            }
            drawnAmount += PRIZES[drawCounts].amount;
            fulfillments[requestId] = Fulfillment(
                PRIZES[drawCounts],
                false,
                Winner(address(0), 0)
            );
            emit CheckpointDrawn(requestId, PRIZES[drawCounts]);
            drawCounts++;
            requestIds.push(requestId);
            if (
                (drawCounts == PRIZES.length - 1) &&
                (block.timestamp <
                    mintedOutTimestamp + PARAMETERS.grandPrizeDelay)
            ) {
                return;
            }
            if (drawCounts == PRIZES.length) {
                emit GiveawayFinished();
                return;
            }
        }
    }

    function _computeRequestId(uint256 id) private pure returns (uint256) {
        return
            uint256(keccak256(abi.encodePacked(uint8(id % type(uint8).max))));
    }

    function _fulfill(
        uint256 requestId,
        address winnerAddress,
        uint256 selectedToken
    ) internal {
        if (fulfillments[requestId].fulfilled) {
            revert FulfillmentAlreadyFulfilled();
        }
        if (fulfillments[requestId].prize.amount == 0)
            revert FulfillRequestForNonExistentContest();
        if (ERC721A.ownerOf(selectedToken) != winnerAddress) {
            revert FulfillRequestWithTokenNotOwnedByWinner();
        }
        if (selectedToken > fulfillments[requestId].prize.checkpoint - 1) {
            revert FulfillRequestWithTokenOutOfBounds();
        }
        fulfillments[requestId].fulfilled = true;
        Winner memory winner = Winner(winnerAddress, uint16(selectedToken));
        fulfillments[requestId].winner = winner;
        (bool success, ) = winnerAddress.call{
            value: fulfillments[requestId].prize.amount
        }("");
        if (!success) revert TransferFailed();
        emit CheckpointFulfilled(
            requestId,
            fulfillments[requestId].prize,
            winner
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 checkpoint = fulfillments[requestId].prize.checkpoint;
        if (checkpoint == 0) revert FulfillRequestRedrawn();
        uint256 selectedToken = randomWords[0] % checkpoint;
        address winner = ERC721A.ownerOf(selectedToken);
        _fulfill(requestId, winner, selectedToken);
    }

    function fulfillContest(
        uint256 giveawayIndex,
        address winner,
        uint256 selectedToken
    ) external nonReentrant onlyOwner {
        uint256 requestId = _computeRequestId(giveawayIndex);
        _fulfill(requestId, winner, selectedToken);
    }

    function TheAnswer(uint256 value, uint256 tokenId) external nonReentrant {
        if (ENS.ownerOf(MYSTERY_CHALLENGE.ensId) != _msgSender()) {
            revert MysteryChallengeSenderDoesNotOwnENS();
        }
        if (value != MYSTERY_CHALLENGE.value) {
            revert MysteryChallengeValueDoesNotMatch();
        }
        _fulfill(
            _computeRequestId(MYSTERY_CHALLENGE.prizeIndex),
            _msgSender(),
            tokenId
        );
    }
}// MIT

pragma solidity ^0.8.12;

struct Attribute {
    string trait_type;
    string value;
}

struct TokenData {
    string image;
    string description;
    string name;
    Attribute[] attributes;
}

interface ICoBotsRendererV2 {
    function tokenURI(uint256 tokenId, uint8 seed)
        external
        view
        returns (string memory);

    function tokenData(uint256 tokenId, uint8 seed)
        external
        view
        returns (TokenData memory);
}