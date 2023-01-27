
pragma solidity ^0.8.7;



interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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

}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

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

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);
}


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}


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
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


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
}


interface IPASS is IERC721{
    function pass_value_in_apes(uint256 _tokenId) external view returns (uint256); // 1=green, 5=blue, 10=gold
}

interface IMAL {
  function depositMALFor(address user, uint256 amount) external;
  function totalTaxCollected() external view returns (uint256);
  function getUserBalance(address user) external view returns (uint256);
  function spendMAL(address user, uint256 amount) external;
}

interface ISTAKING {
  function balanceOf(address user) external view returns (uint256);
}

contract MoonStakingForTax is Ownable, ReentrancyGuard {
    IMAL public MAL;
    IERC721 public TreasuryNft;
    IPASS public PassNft;
    ISTAKING public Staking;
    IERC721 public APES;

    uint256 public constant SECONDS_IN_DAY = 86400;
    uint256 public MIN_MAL_BURN_AMOUNT = 5000 ether;

    bool public stakingLaunched;
    bool public depositPaused;
    bool public apeOwnershipRequired;
    bool public burn_enabled;

    struct Staker {
      uint256 accumulatedAmount;
      uint256 lastCheckpoint;
      uint256 taxCheckpoint;
      uint256[] stakedTREASURY;
      uint256[] stakedPASS;
    }
    mapping(address => Staker) private _stakers;

    enum ContractTypes {
      TREASURY,
      PASS
    }
    mapping(address => ContractTypes) private _contractTypes;
    mapping(address => mapping(uint256 => address)) private _ownerOfToken;
    mapping(address => uint256) private _dividers;
    mapping(uint256 => uint256) private _passMultipliers;
    uint256 public _treasuryDailyReward;

    mapping (address => bool) private _authorised;
    address[] public authorisedLog;

    event Stake721(address indexed staker,address contractAddress,uint256 tokensAmount);
    event Unstake721(address indexed staker,address contractAddress,uint256 tokensAmount);
    event ForceWithdraw721(address indexed receiver, address indexed tokenAddress, uint256 indexed tokenId);
    event Claim(address indexed staker, uint256 claimedAmount);
    event BurnMAL(address indexed burner, uint256 amount);
    

    constructor(address _apes, address _staking, address _mal, address _treasury, address _pass) {
        APES = IERC721(_apes);
        Staking = ISTAKING(_staking);
        MAL = IMAL(_mal);

        stakingLaunched = false;
        TreasuryNft = IERC721(_treasury);
        _contractTypes[_treasury] = ContractTypes.TREASURY;
        _dividers[_treasury] = 5000;
        _treasuryDailyReward = 200 ether;
        burn_enabled = false;

        PassNft = IPASS(_pass);
        _contractTypes[_pass] = ContractTypes.PASS;
        _dividers[_pass] = 1625;

        _passMultipliers[1] = 1;
        _passMultipliers[5] = 5;
        _passMultipliers[10] = 10;
    }

    modifier authorised() {
      require(_authorised[_msgSender()], "The token contract is not authorised");
        _;
    }

    function stake721(address contractAddress, uint256[] memory tokenIds) public nonReentrant {
      require(address(TreasuryNft) != address(0) && address(PassNft) != address(0), "Treasuries and Passes staking is not yet enabled");
      require(!depositPaused, "Staking paused");
      require(stakingLaunched, "Treasuries and Passes staking is not yet enabled");
      require(tokenIds.length > 0, "List cannot be emplty");
      require(contractAddress != address(0) && contractAddress == address(TreasuryNft) || contractAddress == address(PassNft), "Unknown contract or staking is not yet enabled for this NFT");
      ContractTypes contractType = _contractTypes[contractAddress];

      Staker storage user = _stakers[_msgSender()];

      if (user.stakedTREASURY.length == 0 && user.stakedPASS.length == 0) {
        uint256 totalCollectedTax = MAL.totalTaxCollected();
        user.taxCheckpoint = totalCollectedTax;
      }

      accumulate(_msgSender());

      for (uint256 i; i < tokenIds.length; i++) {
        require(IERC721(contractAddress).ownerOf(tokenIds[i]) == _msgSender(), "Not the owner of staking NFT");
        IERC721(contractAddress).safeTransferFrom(_msgSender(), address(this), tokenIds[i]);

        _ownerOfToken[contractAddress][tokenIds[i]] = _msgSender();

        if (contractType == ContractTypes.TREASURY) { user.stakedTREASURY.push(tokenIds[i]); }
        if (contractType == ContractTypes.PASS) { user.stakedPASS.push(tokenIds[i]); }
      }

      accumulate(_msgSender());

      emit Stake721(_msgSender(), contractAddress, tokenIds.length);
    }

    function unstake721(address contractAddress, uint256[] memory tokenIds) public nonReentrant {
      require(tokenIds.length > 0, "List cannot be empty");
      require(contractAddress != address(0) && contractAddress == address(TreasuryNft) || contractAddress == address(PassNft), "Unknown contract or staking is not yet enabled for this NFT");
      ContractTypes contractType = _contractTypes[contractAddress];
      Staker storage user = _stakers[_msgSender()];

      accumulate(_msgSender());

      for (uint256 i; i < tokenIds.length; i++) {
        require(IERC721(contractAddress).ownerOf(tokenIds[i]) == address(this), "Not the owner");

        _ownerOfToken[contractAddress][tokenIds[i]] = address(0);

        if (contractType == ContractTypes.TREASURY) {
          user.stakedTREASURY = _prepareForDeletion(user.stakedTREASURY, tokenIds[i]);
          user.stakedTREASURY.pop();
        }
        if (contractType == ContractTypes.PASS) {
          user.stakedPASS = _prepareForDeletion(user.stakedPASS, tokenIds[i]);
          user.stakedPASS.pop();
        }
        IERC721(contractAddress).safeTransferFrom(address(this), _msgSender(), tokenIds[i]);
      }

      user.taxCheckpoint = MAL.totalTaxCollected();

      emit Unstake721(_msgSender(), contractAddress, tokenIds.length);
    }

    function claimTaxAndReward() public nonReentrant{
        Staker storage user = _stakers[_msgSender()];
        accumulate(_msgSender());

        require(user.accumulatedAmount > 0, "Insufficient funds");
        require(_validateApeOwnership(_msgSender()), "You need at least 1 Ape to claim Tax and Treasury reward");

        uint256 claimableAmount = getTotalClaimableAmount(_msgSender());

        user.taxCheckpoint = MAL.totalTaxCollected();
        user.accumulatedAmount = 0;
        MAL.depositMALFor(_msgSender(), claimableAmount);

      emit Claim(_msgSender(), claimableAmount);
    }

    function burnMAL(uint256 amount) public nonReentrant {
      require(burn_enabled, "Burning for leadboard points is not yet enabled");
      require(MAL.getUserBalance(_msgSender()) >= amount, "Insuficcient balance");
      require(amount >= MIN_MAL_BURN_AMOUNT, "Burning amount is too low.");
      require(amount % MIN_MAL_BURN_AMOUNT == 0, "Burning amount must be divisible by minimal burning amount");
      MAL.spendMAL(_msgSender(), amount);
      emit BurnMAL(_msgSender(), amount);
    }

    function enableBurn() public onlyOwner{
      require(burn_enabled == false, "Burning is already enabled");
      burn_enabled = true;
    }

    function getStakerNFT(address staker) public view returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        uint256 totalPasses = _stakers[staker].stakedPASS.length;
        uint256[] memory passTypes = new uint256[](totalPasses);
        for (uint256 i = 0; i < totalPasses; i++){
            uint256 passType = PassNft.pass_value_in_apes(_stakers[staker].stakedPASS[i]);
            passTypes[i] = passType;
        }
        return (_stakers[staker].stakedTREASURY, _stakers[staker].stakedPASS, passTypes);
    }

    function _prepareForDeletion(uint256[] memory list, uint256 tokenId) internal pure returns (uint256[] memory) {
      uint256 tokenIndex = 0;
      uint256 lastTokenIndex = list.length - 1;
      uint256 length = list.length;

      for(uint256 i = 0; i < length; i++) {
        if (list[i] == tokenId) {
          tokenIndex = i + 1;
          break;
        }
      }
      require(tokenIndex != 0, "Not the owner or duplicate NFT in list");

      tokenIndex -= 1;

      if (tokenIndex != lastTokenIndex) {
        list[tokenIndex] = list[lastTokenIndex];
        list[lastTokenIndex] = tokenId;
      }

      return list;
    }

    function getCurrentClaimableAmount(address staker) public view returns (uint256) {
      if (_stakers[staker].lastCheckpoint == 0) { return 0; }
      return getClaimableTax(staker) + getClaimableReward(staker);
    }

    function getTotalClaimableAmount(address staker) public view returns (uint256) {
      return _stakers[staker].accumulatedAmount + getCurrentClaimableAmount(staker);
    }

    function accumulate(address staker) internal {
      _stakers[staker].accumulatedAmount += getCurrentClaimableAmount(staker);
      _stakers[staker].lastCheckpoint = block.timestamp;
    }

    function getClaimableTax(address staker) public view returns (uint256){
        Staker memory user = _stakers[staker];

        uint256 currentCollectedTax = MAL.totalTaxCollected();
        uint256 prevCollectedTax = user.taxCheckpoint;
        uint256 change = currentCollectedTax - prevCollectedTax;

        uint256 claimableTax = 0;
        if (user.stakedTREASURY.length > 0){
            claimableTax += change * 60 * user.stakedTREASURY.length / 100 / _dividers[address(TreasuryNft)];
        }
        for (uint256 i = 0; i < user.stakedPASS.length; i++){
            uint256 pass_type = PassNft.pass_value_in_apes(user.stakedPASS[i]);
            uint256 pass_mult = _passMultipliers[pass_type];
            claimableTax += change * 40 * pass_mult / 100 / _dividers[address(PassNft)];
        }

        return claimableTax;
    }

    function getClaimableReward(address _staker) public view returns (uint256){
        Staker memory user = _stakers[_staker];
        return (block.timestamp - user.lastCheckpoint) * (_treasuryDailyReward * user.stakedTREASURY.length) / SECONDS_IN_DAY;
    }

    function _validateApeOwnership(address user) internal view returns (bool) {
      if (!apeOwnershipRequired) return true;
      if (Staking.balanceOf(user) > 0) {
        return true;
      }
      return APES.balanceOf(user) > 0;
    }

    function ownerOf(address contractAddress, uint256 tokenId) public view returns (address) {
      return _ownerOfToken[contractAddress][tokenId];
    }

    function treasuryBalanceOf(address user) public view returns (uint256){
      return _stakers[user].stakedTREASURY.length;
    }

    function getStakedPasses(address user) public view returns (uint256[] memory, uint256[] memory){
        uint256 totalPasses = _stakers[user].stakedPASS.length;
        uint256[] memory passTypes = new uint256[](totalPasses);
        for (uint256 i = 0; i < totalPasses; i++){
            uint256 passType = PassNft.pass_value_in_apes(_stakers[user].stakedPASS[i]);
            passTypes[i] = passType;
        }
        return (_stakers[user].stakedPASS, passTypes);
    }

    function setTREASURYContract(address _treasury, uint256 _divider, uint256 _treasuryReward) public onlyOwner {
      TreasuryNft = IERC721(_treasury);
      _contractTypes[_treasury] = ContractTypes.TREASURY;
      _dividers[_treasury] = _divider;
      _treasuryDailyReward = _treasuryReward;
    }

    function setPASSContract(address _pass, uint256 _divider) public onlyOwner {
      PassNft = IPASS(_pass);
      _contractTypes[_pass] = ContractTypes.PASS;
      _dividers[_pass] = _divider;
    }
    
    function setPassTypesMultipliers(uint256[] memory pass_types, uint256[] memory pass_multipliers) public onlyOwner{
        require(pass_types.length == pass_multipliers.length, "Lists not same length");
        for (uint256 i = 0; i < pass_types.length; i++){
            require(pass_types[i] == 1 || pass_types[i] == 5 || pass_types[i] == 10, "Invalid pass type. Valid pass types are 1, 5 and 10.");
            require(pass_multipliers[i] > 0, "Multiplier must be larger than 0.");
            _passMultipliers[pass_types[i]] = pass_multipliers[i];
        }
    }

    function authorise(address toAuth) public onlyOwner {
      _authorised[toAuth] = true;
      authorisedLog.push(toAuth);
    }

    function unauthorise(address addressToUnAuth) public onlyOwner {
      _authorised[addressToUnAuth] = false;
    }

    function updateApeOwnershipRequirement(bool _isOwnershipRequired) public onlyOwner {
      apeOwnershipRequired = _isOwnershipRequired;
    }

    function forceWithdraw721(address tokenAddress, uint256[] memory tokenIds) public onlyOwner {
      require(tokenIds.length <= 50, "50 is max per tx");
      pauseDeposit(true);
      for (uint256 i; i < tokenIds.length; i++) {
        address receiver = _ownerOfToken[tokenAddress][tokenIds[i]];
        if (receiver != address(0) && IERC721(tokenAddress).ownerOf(tokenIds[i]) == address(this)) {
          IERC721(tokenAddress).transferFrom(address(this), receiver, tokenIds[i]);
          emit ForceWithdraw721(receiver, tokenAddress, tokenIds[i]);
        }
      }
    }

    function pauseDeposit(bool _pause) public onlyOwner {
      depositPaused = _pause;
    }

    function launchStaking() public onlyOwner {
      require(!stakingLaunched, "Staking has been launched already");
      stakingLaunched = true;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns(bytes4){
      return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function withdrawETH() external onlyOwner {
      payable(owner()).transfer(address(this).balance);
    }
}