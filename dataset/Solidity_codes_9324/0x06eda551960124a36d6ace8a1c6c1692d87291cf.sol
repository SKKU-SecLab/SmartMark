


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


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
}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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








pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

pragma solidity ^0.8.0;




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

    
}



interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);


}


pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}



pragma solidity ^0.8.0;



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
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

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

}



pragma solidity ^0.8.0;


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}


pragma solidity ^0.8.0;



abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}



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
}




abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    mapping(uint256 => bool) public claimedApeLiquid;
    mapping(uint256 => bool) public burnedApeLiquid;
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






pragma solidity 0.8.10;



contract MetalForge is Ownable, Pausable {
    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint public rewardRate = 1;
    uint public lastUpdateTime;

    bool public liquidLegendMintOver = false;

    mapping(address => uint) public rewards;

    uint public _totalSupply;

    uint public _totalRewards;

    mapping(address => uint) private _balances;

    mapping(address => uint256) public userLastUpdateTime;

    using SafeERC20 for IERC20;
    IERC20 public immutable metalToken;

    ERC721Enumerable public immutable alpha;
    ERC721Enumerable public immutable beta;


    uint256 public immutable ALPHA_DISTRIBUTION_AMOUNT;
    uint256 public immutable BETA_DISTRIBUTION_AMOUNT;


    uint256 public totalClaimed;

    uint256 public claimDuration;
    uint256 public claimStartTime;

    mapping (uint256 => bool) public alphaClaimed;

    mapping (uint256 => bool) public betaClaimed;


    event ClaimStart(
        uint256 _claimDuration,
        uint256 _claimStartTime
    );

    event AlphaClaimed(
        uint256 indexed tokenId,
        address indexed account,
        uint256 timestamp
    );

    event BetaClaimed(
        uint256 indexed tokenId,
        address indexed account,
        uint256 timestamp
    );


    event AirDrop(
        address indexed account,
        uint256 indexed amount,
        uint256 timestamp
    );


    constructor(
        address _metalTokenAddress,
        address _alphaContractAddress,
        address _betaContractAddress,
        uint256 _ALPHA_DISTRIBUTION_AMOUNT,
        uint256 _BETA_DISTRIBUTION_AMOUNT,
        address _stakingToken,
        address _rewardsToken
    ) {
        require(_metalTokenAddress != address(0), "The Metal token address can't be 0");
        require(_alphaContractAddress != address(0), "The Alpha contract address can't be 0");
        require(_betaContractAddress != address(0), "The Beta contract address can't be 0");


        metalToken = IERC20(_metalTokenAddress);
        alpha = ERC721Enumerable(_alphaContractAddress);
        beta = ERC721Enumerable(_betaContractAddress);
        

        ALPHA_DISTRIBUTION_AMOUNT = _ALPHA_DISTRIBUTION_AMOUNT;
        BETA_DISTRIBUTION_AMOUNT = _BETA_DISTRIBUTION_AMOUNT;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        _balances[0x8B6C5793D18509993A1C843851aD49C1BE4B864f] = 1000000000000000000;
        _totalSupply = 1000000000000000000;
        userLastUpdateTime[0x8B6C5793D18509993A1C843851aD49C1BE4B864f] = block.timestamp;
        lastUpdateTime = block.timestamp;


        _pause();
    }

    function startClaimablePeriod(uint256 _claimDuration) external onlyOwner whenPaused {
        require(_claimDuration > 0, "Claim duration should be greater than 0");

        claimDuration = _claimDuration;
        claimStartTime = block.timestamp;

        _unpause();

        emit ClaimStart(_claimDuration, claimStartTime);
    }

    function pauseClaimablePeriod() external onlyOwner {
        _pause();
    }

    function claimTokens() external whenNotPaused {
        require(block.timestamp >= claimStartTime && block.timestamp < claimStartTime + claimDuration, "Claimable period is finished");
        require((alpha.balanceOf(msg.sender) > 0), "Nothing to claim");

        uint256 tokensToClaim;
        uint256 gammaToBeClaim;

        (tokensToClaim, gammaToBeClaim) = getClaimableTokenAmountAndGammaToClaim(msg.sender);

        for(uint256 i; i < alpha.balanceOf(msg.sender); ++i) {
            uint256 tokenId = alpha.tokenOfOwnerByIndex(msg.sender, i);
            if(!alphaClaimed[tokenId] && !beta.burnedApeLiquid(tokenId) &&(beta.claimedApeLiquid(tokenId)|| liquidLegendMintOver)) {
                alphaClaimed[tokenId] = true;
                emit AlphaClaimed(tokenId, msg.sender, block.timestamp);
            }
        }



        metalToken.safeTransfer(msg.sender, tokensToClaim);

        totalClaimed += tokensToClaim;
        emit AirDrop(msg.sender, tokensToClaim, block.timestamp);
    }


    function claimTokensAsStake() external whenNotPaused updateReward(msg.sender) {
        require(block.timestamp >= claimStartTime && block.timestamp < claimStartTime + claimDuration, "Claimable period is finished");
        require((alpha.balanceOf(msg.sender) > 0), "Nothing to claim");

        uint256 tokensToClaim;
        uint256 gammaToBeClaim;

        (tokensToClaim, gammaToBeClaim) = getClaimableTokenAmountAndGammaToClaim(msg.sender);

        for(uint256 i; i < alpha.balanceOf(msg.sender); ++i) {
            uint256 tokenId = alpha.tokenOfOwnerByIndex(msg.sender, i);
            if(!alphaClaimed[tokenId]&& !beta.burnedApeLiquid(tokenId) &&(beta.claimedApeLiquid(tokenId)|| liquidLegendMintOver)) {
                alphaClaimed[tokenId] = true;
                emit AlphaClaimed(tokenId, msg.sender, block.timestamp);
            }
        }

        _totalSupply += tokensToClaim;
        _balances[msg.sender] += tokensToClaim;

        totalClaimed += tokensToClaim;
        emit AirDrop(msg.sender, tokensToClaim, block.timestamp);
    }


    function claimLegendTokens(uint[] calldata _tokenIds) external whenNotPaused {
        require(block.timestamp >= claimStartTime && block.timestamp < claimStartTime + claimDuration, "Claimable period is finished");
        require((alpha.balanceOf(msg.sender) > 0), "Nothing to claim");
        require((beta.balanceOf(msg.sender) > 0), "Nothing to claim");

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(beta.ownerOf(_tokenIds[i]) == msg.sender, "NOT_LL_OWNER");
        }

        uint256 tokensToClaim;
        uint256 gammaToBeClaim;

        (tokensToClaim, gammaToBeClaim) = ((_tokenIds.length * BETA_DISTRIBUTION_AMOUNT),0);

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if(!betaClaimed[_tokenIds[i]] ) {
                betaClaimed[_tokenIds[i]] = true;
                emit BetaClaimed(_tokenIds[i], msg.sender, block.timestamp);
            }
        }



        metalToken.safeTransfer(msg.sender, tokensToClaim);

        totalClaimed += tokensToClaim;
        emit AirDrop(msg.sender, tokensToClaim, block.timestamp);
    }

    function claimLegendTokensAsStake(uint[] calldata _tokenIds) external whenNotPaused {
        require(block.timestamp >= claimStartTime && block.timestamp < claimStartTime + claimDuration, "Claimable period is finished");
        require((alpha.balanceOf(msg.sender) > 0), "Nothing to claim");
        require((beta.balanceOf(msg.sender) > 0), "Nothing to claim");

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(beta.ownerOf(_tokenIds[i]) == msg.sender, "NOT_LL_OWNER");
        }

        uint256 tokensToClaim;
        uint256 gammaToBeClaim;

        (tokensToClaim, gammaToBeClaim) = ((_tokenIds.length * BETA_DISTRIBUTION_AMOUNT),0);

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if(!betaClaimed[_tokenIds[i]] ) {
                betaClaimed[_tokenIds[i]] = true;
                emit BetaClaimed(_tokenIds[i], msg.sender, block.timestamp);
            }
        }

        _totalSupply += tokensToClaim;
         _balances[msg.sender] += tokensToClaim;

        totalClaimed += tokensToClaim;
        emit AirDrop(msg.sender, tokensToClaim, block.timestamp);
    }


    function getClaimableTokenAmount(address _account) public view returns (uint256) {
        uint256 tokensAmount;
        (tokensAmount,) = getClaimableTokenAmountAndGammaToClaim(_account);
        return tokensAmount;
    }




    function getClaimableTokenAmountAndGammaToClaim(address _account) private view returns (uint256, uint256)
    {
        uint256 unclaimedAlphaBalance;
        for(uint256 i; i < alpha.balanceOf(_account); ++i) {
            uint256 tokenId = alpha.tokenOfOwnerByIndex(_account, i);
            if(!alphaClaimed[tokenId] && !beta.burnedApeLiquid(tokenId) &&(beta.claimedApeLiquid(tokenId)|| liquidLegendMintOver)) {
                ++unclaimedAlphaBalance;
            }
        }

        uint256 tokensAmount = (unclaimedAlphaBalance * ALPHA_DISTRIBUTION_AMOUNT)
        ;

        return (tokensAmount, 0);
    }



    function min(uint256 a, uint256 b) private pure returns(uint256) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }



    function toggleLiquidLegendsStatus() external onlyOwner {
        liquidLegendMintOver = !liquidLegendMintOver;
    }


    function rewardPerToken(uint256 userTime) public view returns (uint) {
        
        if (_totalSupply == 0) {
            return 0;
        }
        return
            ((block.timestamp - userTime) * rewardRate ) ;
    }

    function earned(address account) public view returns (uint) {
        return
            (_balances[account] *
                (rewardPerToken(userLastUpdateTime[account]))/ 1e18 )  +
            rewards[account];
    }

    modifier updateReward(address account) {
        rewards[account] = earned(account);
        _totalRewards += earned(account);
        userLastUpdateTime[account] = block.timestamp;
        _;
    }

    function stake(uint _amount) external updateReward(msg.sender) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function stakeOnBehalf(uint _amount,address account ) external updateReward(account) {
        _totalSupply += _amount;
        _balances[account] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _amount) external updateReward(msg.sender) {
        require(_amount <= _balances[msg.sender], "withdraw amount over stake");
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
    }

    function getRewardAsStake() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
         _balances[msg.sender] += reward;
    }


     function changerewardRate(uint256 newRewardRate) external onlyOwner {
        rewardRate = newRewardRate;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function withdrawAllTokens() external onlyOwner {
        uint256 tokenSupply = rewardsToken.balanceOf(address(this));
        rewardsToken.transfer(msg.sender, tokenSupply);
    }
    function withdrawSomeTokens(uint _amount) external onlyOwner {
        rewardsToken.transfer(msg.sender, _amount);
    }

}