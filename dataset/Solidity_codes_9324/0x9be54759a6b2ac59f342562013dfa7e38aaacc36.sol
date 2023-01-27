

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;


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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

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

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

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

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

interface IHEX {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Claim(
        uint256 data0,
        uint256 data1,
        bytes20 indexed btcAddr,
        address indexed claimToAddr,
        address indexed referrerAddr
    );
    event ClaimAssist(
        uint256 data0,
        uint256 data1,
        uint256 data2,
        address indexed senderAddr
    );
    event DailyDataUpdate(uint256 data0, address indexed updaterAddr);
    event ShareRateChange(uint256 data0, uint40 indexed stakeId);
    event StakeEnd(
        uint256 data0,
        uint256 data1,
        address indexed stakerAddr,
        uint40 indexed stakeId
    );
    event StakeGoodAccounting(
        uint256 data0,
        uint256 data1,
        address indexed stakerAddr,
        uint40 indexed stakeId,
        address indexed senderAddr
    );
    event StakeStart(
        uint256 data0,
        address indexed stakerAddr,
        uint40 indexed stakeId
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    event XfLobbyEnter(
        uint256 data0,
        address indexed memberAddr,
        uint256 indexed entryId,
        address indexed referrerAddr
    );
    event XfLobbyExit(
        uint256 data0,
        address indexed memberAddr,
        uint256 indexed entryId,
        address indexed referrerAddr
    );

    fallback() external payable;

    function allocatedSupply() external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function btcAddressClaim(
        uint256 rawSatoshis,
        bytes32[] memory proof,
        address claimToAddr,
        bytes32 pubKeyX,
        bytes32 pubKeyY,
        uint8 claimFlags,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 autoStakeDays,
        address referrerAddr
    ) external returns (uint256);

    function btcAddressClaims(bytes20) external view returns (bool);

    function btcAddressIsClaimable(
        bytes20 btcAddr,
        uint256 rawSatoshis,
        bytes32[] memory proof
    ) external view returns (bool);

    function btcAddressIsValid(
        bytes20 btcAddr,
        uint256 rawSatoshis,
        bytes32[] memory proof
    ) external pure returns (bool);

    function claimMessageMatchesSignature(
        address claimToAddr,
        bytes32 claimParamHash,
        bytes32 pubKeyX,
        bytes32 pubKeyY,
        uint8 claimFlags,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external pure returns (bool);

    function currentDay() external view returns (uint256);

    function dailyData(uint256)
        external
        view
        returns (
            uint72 dayPayoutTotal,
            uint72 dayStakeSharesTotal,
            uint56 dayUnclaimedSatoshisTotal
        );

    function dailyDataRange(uint256 beginDay, uint256 endDay)
        external
        view
        returns (uint256[] memory list);

    function dailyDataUpdate(uint256 beforeDay) external;

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function globalInfo() external view returns (uint256[13] memory);

    function globals()
        external
        view
        returns (
            uint72 lockedHeartsTotal,
            uint72 nextStakeSharesTotal,
            uint40 shareRate,
            uint72 stakePenaltyTotal,
            uint16 dailyDataCount,
            uint72 stakeSharesTotal,
            uint40 latestStakeId,
            uint128 claimStats
        );

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function merkleProofIsValid(bytes32 merkleLeaf, bytes32[] memory proof)
        external
        pure
        returns (bool);

    function name() external view returns (string memory);

    function pubKeyToBtcAddress(
        bytes32 pubKeyX,
        bytes32 pubKeyY,
        uint8 claimFlags
    ) external pure returns (bytes20);

    function pubKeyToEthAddress(bytes32 pubKeyX, bytes32 pubKeyY)
        external
        pure
        returns (address);

    function stakeCount(address stakerAddr) external view returns (uint256);

    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external;

    function stakeGoodAccounting(
        address stakerAddr,
        uint256 stakeIndex,
        uint40 stakeIdParam
    ) external;

    function stakeLists(address, uint256)
        external
        view
        returns (
            uint40 stakeId,
            uint72 stakedHearts,
            uint72 stakeShares,
            uint16 lockedDay,
            uint16 stakedDays,
            uint16 unlockedDay,
            bool isAutoStake
        );

    function stakeStart(uint256 newStakedHearts, uint256 newStakedDays)
        external;

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function xfLobby(uint256) external view returns (uint256);

    function xfLobbyEnter(address referrerAddr) external payable;

    function xfLobbyEntry(address memberAddr, uint256 entryId)
        external
        view
        returns (uint256 rawAmount, address referrerAddr);

    function xfLobbyExit(uint256 enterDay, uint256 count) external;

    function xfLobbyFlush() external;

    function xfLobbyMembers(uint256, address)
        external
        view
        returns (uint40 headIndex, uint40 tailIndex);

    function xfLobbyPendingDays(address memberAddr)
        external
        view
        returns (uint256[2] memory words);

    function xfLobbyRange(uint256 beginDay, uint256 endDay)
        external
        view
        returns (uint256[] memory list);
}

struct HEXDailyData {
    uint72 dayPayoutTotal;
    uint72 dayStakeSharesTotal;
    uint56 dayUnclaimedSatoshisTotal;
}

struct HEXGlobals {
    uint72 lockedHeartsTotal;
    uint72 nextStakeSharesTotal;
    uint40 shareRate;
    uint72 stakePenaltyTotal;
    uint16 dailyDataCount;
    uint72 stakeSharesTotal;
    uint40 latestStakeId;
    uint128 claimStats;
}

struct HEXStake {
    uint40 stakeId;
    uint72 stakedHearts;
    uint72 stakeShares;
    uint16 lockedDay;
    uint16 stakedDays;
    uint16 unlockedDay;
    bool   isAutoStake;
}

struct HEXStakeMinimal {
    uint40 stakeId;
    uint72 stakeShares;
    uint16 lockedDay;
    uint16 stakedDays;
}

struct ShareStore {
    HEXStakeMinimal stake;
    uint16          mintedDays;
    uint8           launchBonus;
    uint16          loanStart;
    uint16          loanedDays;
    uint32          interestRate;
    uint8           paymentsMade;
    bool            isLoaned;
}

struct ShareCache {
    HEXStakeMinimal _stake;
    uint256         _mintedDays;
    uint256         _launchBonus;
    uint256         _loanStart;
    uint256         _loanedDays;
    uint256         _interestRate;
    uint256         _paymentsMade;
    bool            _isLoaned;
}

address constant _hdrnSourceAddress = address(0x291784Cd4eDd389a9794a4C68813d6dDe048A7c0);
address constant _hdrnFlowAddress   = address(0x53686418B7C02B87771C789cB51A7b90864069F7);
uint256 constant _hdrnLaunch        = 1645833600;

contract HEXStakeInstance {
    
    IHEX       private _hx;
    address    private _creator;
    address    public  whoami;
    ShareStore public  share;

    constructor(
        address hexAddress
    )
    {
        _creator = msg.sender;
        whoami = address(this);

        _hx = IHEX(payable(hexAddress));
    }

    function _stakeDataUpdate(
    )
        internal
    {
        uint40 stakeId;
        uint72 stakedHearts;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
        bool   isAutoStake;
        
        (stakeId,
         stakedHearts,
         stakeShares,
         lockedDay,
         stakedDays,
         unlockedDay,
         isAutoStake
        ) = _hx.stakeLists(whoami, 0);

        share.stake.stakeId = stakeId;
        share.stake.stakeShares = stakeShares;
        share.stake.lockedDay = lockedDay;
        share.stake.stakedDays = stakedDays;
    }

    function initialize(
        uint256 stakeLength
    )
        external
    {
        uint256 hexBalance = _hx.balanceOf(whoami);

        require(msg.sender == _creator,
            "HSI: Caller must be contract creator");
        require(share.stake.stakedDays == 0,
            "HSI: Initialization already performed");
        require(hexBalance > 0,
            "HSI: Initialization requires a non-zero HEX balance");

        _hx.stakeStart(
            hexBalance,
            stakeLength
        );

        _stakeDataUpdate();
    }

    function goodAccounting(
    )
        external
    {
        require(share.stake.stakedDays > 0,
            "HSI: Initialization not yet performed");

        _hx.stakeGoodAccounting(whoami, 0, share.stake.stakeId);

        _stakeDataUpdate();
    }

    function destroy(
    )
        external
    {
        require(msg.sender == _creator,
            "HSI: Caller must be contract creator");
        require(share.stake.stakedDays > 0,
            "HSI: Initialization not yet performed");

        _hx.stakeEnd(0, share.stake.stakeId);
        
        uint256 hexBalance = _hx.balanceOf(whoami);

        if (_hx.approve(_creator, hexBalance)) {
            selfdestruct(payable(_creator));
        }
        else {
            revert();
        }
    }

    function update(
        ShareCache memory _share
    )
        external 
    {
        require(msg.sender == _creator,
            "HSI: Caller must be contract creator");

        share.mintedDays   = uint16(_share._mintedDays);
        share.launchBonus  = uint8 (_share._launchBonus);
        share.loanStart    = uint16(_share._loanStart);
        share.loanedDays   = uint16(_share._loanedDays);
        share.interestRate = uint32(_share._interestRate);
        share.paymentsMade = uint8 (_share._paymentsMade);
        share.isLoaned     = _share._isLoaned;
    }

    function stakeDataFetch(
    ) 
        external
        view
        returns(HEXStake memory)
    {
        uint40 stakeId;
        uint72 stakedHearts;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
        bool   isAutoStake;
        
        (stakeId,
         stakedHearts,
         stakeShares,
         lockedDay,
         stakedDays,
         unlockedDay,
         isAutoStake
        ) = _hx.stakeLists(whoami, 0);

        return HEXStake(
            stakeId,
            stakedHearts,
            stakeShares,
            lockedDay,
            stakedDays,
            unlockedDay,
            isAutoStake
        );
    }
}

interface IHedron {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Claim(uint256 data, address indexed claimant, uint40 indexed stakeId);
    event LoanEnd(
        uint256 data,
        address indexed borrower,
        uint40 indexed stakeId
    );
    event LoanLiquidateBid(
        uint256 data,
        address indexed bidder,
        uint40 indexed stakeId,
        uint40 indexed liquidationId
    );
    event LoanLiquidateExit(
        uint256 data,
        address indexed liquidator,
        uint40 indexed stakeId,
        uint40 indexed liquidationId
    );
    event LoanLiquidateStart(
        uint256 data,
        address indexed borrower,
        uint40 indexed stakeId,
        uint40 indexed liquidationId
    );
    event LoanPayment(
        uint256 data,
        address indexed borrower,
        uint40 indexed stakeId
    );
    event LoanStart(
        uint256 data,
        address indexed borrower,
        uint40 indexed stakeId
    );
    event Mint(uint256 data, address indexed minter, uint40 indexed stakeId);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function calcLoanPayment(
        address borrower,
        uint256 hsiIndex,
        address hsiAddress
    ) external view returns (uint256, uint256);

    function calcLoanPayoff(
        address borrower,
        uint256 hsiIndex,
        address hsiAddress
    ) external view returns (uint256, uint256);

    function claimInstanced(
        uint256 hsiIndex,
        address hsiAddress,
        address hsiStarterAddress
    ) external;

    function claimNative(uint256 stakeIndex, uint40 stakeId)
        external
        returns (uint256);

    function dailyDataList(uint256)
        external
        view
        returns (
            uint72 dayMintedTotal,
            uint72 dayLoanedTotal,
            uint72 dayBurntTotal,
            uint32 dayInterestRate,
            uint8 dayMintMultiplier
        );

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function hsim() external view returns (address);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function liquidationList(uint256)
        external
        view
        returns (
            uint256 liquidationStart,
            address hsiAddress,
            uint96 bidAmount,
            address liquidator,
            uint88 endOffset,
            bool isActive
        );

    function loanInstanced(uint256 hsiIndex, address hsiAddress)
        external
        returns (uint256);

    function loanLiquidate(
        address owner,
        uint256 hsiIndex,
        address hsiAddress
    ) external returns (uint256);

    function loanLiquidateBid(uint256 liquidationId, uint256 liquidationBid)
        external
        returns (uint256);

    function loanLiquidateExit(uint256 hsiIndex, uint256 liquidationId)
        external
        returns (address);

    function loanPayment(uint256 hsiIndex, address hsiAddress)
        external
        returns (uint256);

    function loanPayoff(uint256 hsiIndex, address hsiAddress)
        external
        returns (uint256);

    function loanedSupply() external view returns (uint256);

    function mintInstanced(uint256 hsiIndex, address hsiAddress)
        external
        returns (uint256);

    function mintNative(uint256 stakeIndex, uint40 stakeId)
        external
        returns (uint256);

    function name() external view returns (string memory);

    function proofOfBenevolence(uint256 amount) external;

    function shareList(uint256)
        external
        view
        returns (
            HEXStakeMinimal memory stake,
            uint16 mintedDays,
            uint8 launchBonus,
            uint16 loanStart,
            uint16 loanedDays,
            uint32 interestRate,
            uint8 paymentsMade,
            bool isLoaned
        );

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library LibPart {
    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

abstract contract AbstractRoyalties {
    mapping (uint256 => LibPart.Part[]) internal royalties;

    function _saveRoyalties(uint256 id, LibPart.Part[] memory _royalties) internal {
        uint256 totalValue;
        for (uint i = 0; i < _royalties.length; i++) {
            require(_royalties[i].account != address(0x0), "Recipient should be present");
            require(_royalties[i].value != 0, "Royalty value should be positive");
            totalValue += _royalties[i].value;
            royalties[id].push(_royalties[i]);
        }
        require(totalValue < 10000, "Royalty total value should be < 10000");
        _onRoyaltiesSet(id, _royalties);
    }

    function _updateAccount(uint256 _id, address _from, address _to) internal {
        uint length = royalties[_id].length;
        for(uint i = 0; i < length; i++) {
            if (royalties[_id][i].account == _from) {
                royalties[_id][i].account = payable(address(uint160(_to)));
            }
        }
    }

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties) virtual internal;
}

interface RoyaltiesV2 {
    event RoyaltiesSet(uint256 tokenId, LibPart.Part[] royalties);

    function getRaribleV2Royalties(uint256 id) external view returns (LibPart.Part[] memory);
}

contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2 {

    function getRaribleV2Royalties(uint256 id) override external view returns (LibPart.Part[] memory) {
        return royalties[id];
    }

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties) override internal {
        emit RoyaltiesSet(id, _royalties);
    }
}

library LibRoyaltiesV2 {
    bytes4 constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
}

contract HEXStakeInstanceManager is ERC721, ERC721Enumerable, RoyaltiesV2Impl {

    using Counters for Counters.Counter;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    uint96 private constant _hsimRoyaltyBasis = 15; // Rarible V2 royalty basis
    string private constant _hostname = "https://api.hedron.pro/";
    string private constant _endpoint = "/hsi/";
    
    Counters.Counter private _tokenIds;
    address          private _creator;
    IHEX             private _hx;
    address          private _hxAddress;

    address                       public  whoami;
    mapping(address => address[]) public  hsiLists;
    mapping(uint256 => address)   public  hsiToken;
 
    constructor(
        address hexAddress
    )
        ERC721("HEX Stake Instance", "HSI")
    {
        _creator = msg.sender;
        whoami = address(this);

        _hx = IHEX(payable(hexAddress));
        _hxAddress = hexAddress;
    }

    function _baseURI(
    )
        internal
        view
        virtual
        override
        returns (string memory)
    {
        string memory chainid = Strings.toString(block.chainid);
        return string(abi.encodePacked(_hostname, chainid, _endpoint));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        override(ERC721, ERC721Enumerable) 
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    event HSIStart(
        uint256         timestamp,
        address indexed hsiAddress,
        address indexed staker
    );

    event HSIEnd(
        uint256         timestamp,
        address indexed hsiAddress,
        address indexed staker
    );

    event HSITransfer(
        uint256         timestamp,
        address indexed hsiAddress,
        address indexed oldStaker,
        address indexed newStaker
    );

    event HSITokenize(
        uint256         timestamp,
        uint256 indexed hsiTokenId,
        address indexed hsiAddress,
        address indexed staker
    );

    event HSIDetokenize(
        uint256         timestamp,
        uint256 indexed hsiTokenId,
        address indexed hsiAddress,
        address indexed staker
    );

    function _pruneHSI(
        address[] storage hsiList,
        uint256 hsiIndex
    )
        internal
    {
        uint256 lastIndex = hsiList.length - 1;

        if (hsiIndex != lastIndex) {
            hsiList[hsiIndex] = hsiList[lastIndex];
        }

        hsiList.pop();
    }

    function _hsiLoad(
        HEXStakeInstance hsi
    ) 
        internal
        view
        returns (ShareCache memory)
    {
        HEXStakeMinimal memory stake;
        uint16                 mintedDays;
        uint8                  launchBonus;
        uint16                 loanStart;
        uint16                 loanedDays;
        uint32                 interestRate;
        uint8                  paymentsMade;
        bool                   isLoaned;

        (stake,
         mintedDays,
         launchBonus,
         loanStart,
         loanedDays,
         interestRate,
         paymentsMade,
         isLoaned) = hsi.share();

        return ShareCache(
            stake,
            mintedDays,
            launchBonus,
            loanStart,
            loanedDays,
            interestRate,
            paymentsMade,
            isLoaned
        );
    }


    function _setRoyalties(
        uint256 tokenId
    )
        internal
    {
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        _royalties[0].value = _hsimRoyaltyBasis;
        _royalties[0].account = payable(_hdrnFlowAddress);
        _saveRoyalties(tokenId, _royalties);
    }

    function hsiCount(
        address user
    )
        public
        view
        returns (uint256)
    {
        return hsiLists[user].length;
    }

    function stakeCount(
        address user
    )
        external
        view
        returns (uint256)
    {
        return hsiCount(user);
    }

    function stakeLists(
        address user,
        uint256 hsiIndex
    )
        external
        view
        returns (HEXStake memory)
    {
        address[] storage hsiList = hsiLists[user];

        HEXStakeInstance hsi = HEXStakeInstance(hsiList[hsiIndex]);

        return hsi.stakeDataFetch();
    }

    function hexStakeStart (
        uint256 amount,
        uint256 length
    )
        external
        returns (address)
    {
        require(amount <= _hx.balanceOf(msg.sender),
            "HSIM: Insufficient HEX to facilitate stake");

        address[] storage hsiList = hsiLists[msg.sender];

        HEXStakeInstance hsi = new HEXStakeInstance(_hxAddress);
        address hsiAddress = hsi.whoami();
        hsiList.push(hsiAddress);
        uint256 hsiIndex = hsiList.length - 1;

        require(_hx.transferFrom(msg.sender, hsiAddress, amount),
            "HSIM: HEX transfer from message sender to HSIM failed");

        hsi.initialize(length);

        IHedron hedron = IHedron(_creator);
        hedron.claimInstanced(hsiIndex, hsiAddress, msg.sender);

        emit HSIStart(block.timestamp, hsiAddress, msg.sender);

        return hsiAddress;
    }

    function hexStakeEnd (
        uint256 hsiIndex,
        address hsiAddress
    )
        external
        returns (uint256)
    {
        address[] storage hsiList = hsiLists[msg.sender];

        require(hsiAddress == hsiList[hsiIndex],
            "HSIM: HSI index address mismatch");

        HEXStakeInstance hsi = HEXStakeInstance(hsiAddress);
        ShareCache memory share = _hsiLoad(hsi);

        require (share._isLoaned == false,
            "HSIM: Cannot call stakeEnd against a loaned stake");

        hsi.destroy();

        emit HSIEnd(block.timestamp, hsiAddress, msg.sender);

        uint256 hsiBalance = _hx.balanceOf(hsiAddress);

        if (hsiBalance > 0) {
            require(_hx.transferFrom(hsiAddress, msg.sender, hsiBalance),
                "HSIM: HEX transfer from HSI failed");
        }

        _pruneHSI(hsiList, hsiIndex);

        return hsiBalance;
    }

    function hexStakeTokenize (
        uint256 hsiIndex,
        address hsiAddress
    )
        external
        returns (uint256)
    {
        address[] storage hsiList = hsiLists[msg.sender];

        require(hsiAddress == hsiList[hsiIndex],
            "HSIM: HSI index address mismatch");

        HEXStakeInstance hsi = HEXStakeInstance(hsiAddress);
        ShareCache memory share = _hsiLoad(hsi);

        require (share._isLoaned == false,
            "HSIM: Cannot tokenize a loaned stake");

        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
         hsiToken[newTokenId] = hsiAddress;

        _setRoyalties(newTokenId);

        _pruneHSI(hsiList, hsiIndex);

        emit HSITokenize(
            block.timestamp,
            newTokenId,
            hsiAddress,
            msg.sender
        );

        return newTokenId;
    }

    function hexStakeDetokenize (
        uint256 tokenId
    )
        external
        returns (address)
    {
        require(ownerOf(tokenId) == msg.sender,
            "HSIM: Detokenization requires token ownership");

        address hsiAddress = hsiToken[tokenId];
        address[] storage hsiList = hsiLists[msg.sender];

        hsiList.push(hsiAddress);
        hsiToken[tokenId] = address(0);

        _burn(tokenId);

        emit HSIDetokenize(
            block.timestamp,
            tokenId, 
            hsiAddress,
            msg.sender
        );

        return hsiAddress;
    }

    function hsiUpdate (
        address holder,
        uint256 hsiIndex,
        address hsiAddress,
        ShareCache memory share
    )
        external
    {
        require(msg.sender == _creator,
            "HSIM: Caller must be contract creator");

        address[] storage hsiList = hsiLists[holder];

        require(hsiAddress == hsiList[hsiIndex],
            "HSIM: HSI index address mismatch");

        HEXStakeInstance hsi = HEXStakeInstance(hsiAddress);
        hsi.update(share);
    }

    function hsiTransfer (
        address currentHolder,
        uint256 hsiIndex,
        address hsiAddress,
        address newHolder
    )
        external
    {
        require(msg.sender == _creator,
            "HSIM: Caller must be contract creator");

        address[] storage hsiListCurrent = hsiLists[currentHolder];
        address[] storage hsiListNew = hsiLists[newHolder];

        require(hsiAddress == hsiListCurrent[hsiIndex],
            "HSIM: HSI index address mismatch");

        hsiListNew.push(hsiAddress);
        _pruneHSI(hsiListCurrent, hsiIndex);

        emit HSITransfer(
                    block.timestamp,
                    hsiAddress,
                    currentHolder,
                    newHolder
                );
    }


    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        LibPart.Part[] memory _royalties = royalties[tokenId];
        
        if (_royalties.length > 0) {
            return (_royalties[0].account, (salePrice * _royalties[0].value) / 10000);
        }

        return (address(0), 0);
    }

    function owner(
    )
        external
        pure
        returns (address) 
    {
        return _hdrnFlowAddress;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }

        if (interfaceId == _INTERFACE_ID_ERC2981) {
            return true;
        }

        return super.supportsInterface(interfaceId);
    }
}

contract Hedron is ERC20 {

    using Counters for Counters.Counter;

    struct DailyDataStore {
        uint72 dayMintedTotal;
        uint72 dayLoanedTotal;
        uint72 dayBurntTotal;
        uint32 dayInterestRate;
        uint8  dayMintMultiplier;
    }

    struct DailyDataCache {
        uint256 _dayMintedTotal;
        uint256 _dayLoanedTotal;
        uint256 _dayBurntTotal;
        uint256 _dayInterestRate;
        uint256 _dayMintMultiplier;
    }

    struct LiquidationStore{
        uint256 liquidationStart;
        address hsiAddress;
        uint96  bidAmount;
        address liquidator;
        uint88  endOffset;
        bool    isActive;
    }

    struct LiquidationCache {
        uint256 _liquidationStart;
        address _hsiAddress;
        uint256 _bidAmount;
        address _liquidator;
        uint256 _endOffset;
        bool    _isActive;
    }

    uint256 constant private _hdrnLaunchDays             = 100;     // length of the launch phase bonus in Hedron days
    uint256 constant private _hdrnLoanInterestResolution = 1000000; // loan interest decimal resolution
    uint256 constant private _hdrnLoanInterestDivisor    = 2;       // relation of Hedron's interest rate to HEX's interest rate
    uint256 constant private _hdrnLoanPaymentWindow      = 30;      // how many Hedron days to roll into a single payment
    uint256 constant private _hdrnLoanDefaultThreshold   = 90;      // how many Hedron days before loan liquidation is allowed
   
    IHEX                                   private _hx;
    uint256                                private _hxLaunch;
    HEXStakeInstanceManager                private _hsim;
    Counters.Counter                       private _liquidationIds;
    address                                public  hsim;
    mapping(uint256 => ShareStore)         public  shareList;
    mapping(uint256 => DailyDataStore)     public  dailyDataList;
    mapping(uint256 => LiquidationStore)   public  liquidationList;
    uint256                                public  loanedSupply;

    constructor(
        address hexAddress,
        uint256 hexLaunch
    )
        ERC20("Hedron", "HDRN")
    {
        _hx = IHEX(payable(hexAddress));
        _hxLaunch = hexLaunch;

        _hsim = new HEXStakeInstanceManager(hexAddress);
        hsim = _hsim.whoami();
    }

    function decimals()
        public
        view
        virtual
        override
        returns (uint8) 
    {
        return 9;
    }
    

    event Claim(
        uint256         data,
        address indexed claimant,
        uint40  indexed stakeId
    );

    event Mint(
        uint256         data,
        address indexed minter,
        uint40  indexed stakeId
    );

    event LoanStart(
        uint256         data,
        address indexed borrower,
        uint40  indexed stakeId
    );

    event LoanPayment(
        uint256         data,
        address indexed borrower,
        uint40  indexed stakeId
    );

    event LoanEnd(
        uint256         data,
        address indexed borrower,
        uint40  indexed stakeId
    );

    event LoanLiquidateStart(
        uint256         data,
        address indexed borrower,
        uint40  indexed stakeId,
        uint40  indexed liquidationId
    );

    event LoanLiquidateBid(
        uint256         data,
        address indexed bidder,
        uint40  indexed stakeId,
        uint40  indexed liquidationId
    );

    event LoanLiquidateExit(
        uint256         data,
        address indexed liquidator,
        uint40  indexed stakeId,
        uint40  indexed liquidationId
    );


    function _emitClaim(
        uint40  stakeId,
        uint256 stakeShares,
        uint256 launchBonus
    )
        private
    {
        emit Claim(
            uint256(uint40 (block.timestamp))
                |  (uint256(uint72 (stakeShares)) << 40)
                |  (uint256(uint144(launchBonus)) << 112),
            msg.sender,
            stakeId
        );
    }

    function _emitMint(
        ShareCache memory share,
        uint256 payout
    )
        private
    {
        emit Mint(
            uint256(uint40 (block.timestamp))
                |  (uint256(uint72 (share._stake.stakeShares)) << 40)
                |  (uint256(uint16 (share._mintedDays))        << 112)
                |  (uint256(uint8  (share._launchBonus))       << 128)
                |  (uint256(uint120(payout))                   << 136),
            msg.sender,
            share._stake.stakeId
        );
    }

    function _emitLoanStart(
        ShareCache memory share,
        uint256 borrowed
    )
        private
    {
        emit LoanStart(
            uint256(uint40 (block.timestamp))
                |  (uint256(uint72(share._stake.stakeShares)) << 40)
                |  (uint256(uint16(share._loanedDays))        << 112)
                |  (uint256(uint32(share._interestRate))      << 128)
                |  (uint256(uint96(borrowed))                 << 160),
            msg.sender,
            share._stake.stakeId
        );
    }

    function _emitLoanPayment(
        ShareCache memory share,
        uint256 payment
    )
        private
    {
        emit LoanPayment(
            uint256(uint40 (block.timestamp))
                |  (uint256(uint72(share._stake.stakeShares)) << 40)
                |  (uint256(uint16(share._loanedDays))        << 112)
                |  (uint256(uint32(share._interestRate))      << 128)
                |  (uint256(uint8 (share._paymentsMade))      << 160)
                |  (uint256(uint88(payment))                  << 168),
            msg.sender,
            share._stake.stakeId
        );
    }

    function _emitLoanEnd(
        ShareCache memory share,
        uint256 payoff
    )
        private
    {
        emit LoanEnd(
            uint256(uint40 (block.timestamp))
                |  (uint256(uint72(share._stake.stakeShares)) << 40)
                |  (uint256(uint16(share._loanedDays))        << 112)
                |  (uint256(uint32(share._interestRate))      << 128)
                |  (uint256(uint8 (share._paymentsMade))      << 160)
                |  (uint256(uint88(payoff))                   << 168),
            msg.sender,
            share._stake.stakeId
        );
    }

    function _emitLoanLiquidateStart(
        ShareCache memory share,
        uint40  liquidationId,
        address borrower,
        uint256 startingBid
    )
        private
    {
        emit LoanLiquidateStart(
            uint256(uint40 (block.timestamp))
                |  (uint256(uint72(share._stake.stakeShares)) << 40)
                |  (uint256(uint16(share._loanedDays))        << 112)
                |  (uint256(uint32(share._interestRate))      << 128)
                |  (uint256(uint8 (share._paymentsMade))      << 160)
                |  (uint256(uint88(startingBid))              << 168),
            borrower,
            share._stake.stakeId,
            liquidationId
        );
    }

    function _emitLoanLiquidateBid(
        uint40  stakeId,
        uint40  liquidationId,
        uint256 bidAmount
    )
        private
    {
        emit LoanLiquidateBid(
            uint256(uint40 (block.timestamp))
                |  (uint256(uint216(bidAmount)) << 40),
            msg.sender,
            stakeId,
            liquidationId
        );
    }

    function _emitLoanLiquidateExit(
        uint40  stakeId,
        uint40  liquidationId,
        address liquidator,
        uint256 finalBid
    )
        private
    {
        emit LoanLiquidateExit(
            uint256(uint40 (block.timestamp))
                |  (uint256(uint216(finalBid)) << 40),
            liquidator,
            stakeId,
            liquidationId
        );
    }


    function _hexCurrentDay()
        internal
        view
        returns (uint256)
    {
        return (block.timestamp - _hxLaunch) / 1 days;
    }
    
    function _hexDailyDataLoad(
        uint256 hexDay
    )
        internal
        view
        returns (HEXDailyData memory)
    {
        uint72 dayPayoutTotal;
        uint72 dayStakeSharesTotal;
        uint56 dayUnclaimedSatoshisTotal;

        (dayPayoutTotal,
         dayStakeSharesTotal,
         dayUnclaimedSatoshisTotal) = _hx.dailyData(hexDay);

        return HEXDailyData(
            dayPayoutTotal,
            dayStakeSharesTotal,
            dayUnclaimedSatoshisTotal
        );

    }

    function _hexGlobalsLoad()
        internal
        view
        returns (HEXGlobals memory)
    {
        uint72  lockedHeartsTotal;
        uint72  nextStakeSharesTotal;
        uint40  shareRate;
        uint72  stakePenaltyTotal;
        uint16  dailyDataCount;
        uint72  stakeSharesTotal;
        uint40  latestStakeId;
        uint128 claimStats;

        (lockedHeartsTotal,
         nextStakeSharesTotal,
         shareRate,
         stakePenaltyTotal,
         dailyDataCount,
         stakeSharesTotal,
         latestStakeId,
         claimStats) = _hx.globals();

        return HEXGlobals(
            lockedHeartsTotal,
            nextStakeSharesTotal,
            shareRate,
            stakePenaltyTotal,
            dailyDataCount,
            stakeSharesTotal,
            latestStakeId,
            claimStats
        );
    }

    function _hexStakeLoad(
        uint256 stakeIndex
    )
        internal
        view
        returns (HEXStake memory)
    {
        uint40 stakeId;
        uint72 stakedHearts;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
        bool   isAutoStake;
        
        (stakeId,
         stakedHearts,
         stakeShares,
         lockedDay,
         stakedDays,
         unlockedDay,
         isAutoStake) = _hx.stakeLists(msg.sender, stakeIndex);
         
         return HEXStake(
            stakeId,
            stakedHearts,
            stakeShares,
            lockedDay,
            stakedDays,
            unlockedDay,
            isAutoStake
        );
    }
    

    function _currentDay()
        internal
        view
        returns (uint256)
    {
        return (block.timestamp - _hdrnLaunch) / 1 days;
    }

    function _calcLPBMultiplier (
        uint256 launchDay
    )
        internal
        pure
        returns (uint256)
    {
        if (launchDay > 90) {
            return 100;
        }
        else if (launchDay > 80) {
            return 90;
        }
        else if (launchDay > 70) {
            return 80;
        }
        else if (launchDay > 60) {
            return 70;
        }
        else if (launchDay > 50) {
            return 60;
        }
        else if (launchDay > 40) {
            return 50;
        }
        else if (launchDay > 30) {
            return 40;
        }
        else if (launchDay > 20) {
            return 30;
        }
        else if (launchDay > 10) {
            return 20;
        }
        else if (launchDay > 0) {
            return 10;
        }

        return 0;
    }

    function _calcBonus(
        uint256 multiplier, 
        uint256 payout
    )
        internal
        pure
        returns (uint256)
    {   
        return uint256((payout * multiplier) / 10);
    }

    function _dailyDataLoad(
        DailyDataStore storage dayStore,
        DailyDataCache memory  day
    )
        internal
        view
    {
        day._dayMintedTotal    = dayStore.dayMintedTotal;
        day._dayLoanedTotal    = dayStore.dayLoanedTotal;
        day._dayBurntTotal     = dayStore.dayBurntTotal;
        day._dayInterestRate   = dayStore.dayInterestRate;
        day._dayMintMultiplier = dayStore.dayMintMultiplier;

        if (day._dayInterestRate == 0) {
            uint256 hexCurrentDay = _hexCurrentDay();

            HEXDailyData memory hexDailyData         = _hexDailyDataLoad(hexCurrentDay - 2);
            HEXGlobals   memory hexGlobals           = _hexGlobalsLoad();
            uint256             hexDailyInterestRate = (hexDailyData.dayPayoutTotal * _hdrnLoanInterestResolution) / hexGlobals.lockedHeartsTotal;

            day._dayInterestRate = hexDailyInterestRate / _hdrnLoanInterestDivisor;

            if (loanedSupply > 0 && totalSupply() > 0) {
                uint256 loanedToMinted = (loanedSupply * 100) / totalSupply();
                if (loanedToMinted > 50) {
                    day._dayMintMultiplier = (loanedToMinted - 50) * 2;
                }
            }
        }
    }

    function _dailyDataUpdate(
        DailyDataStore storage dayStore,
        DailyDataCache memory  day
    )
        internal
    {
        dayStore.dayMintedTotal    = uint72(day._dayMintedTotal);
        dayStore.dayLoanedTotal    = uint72(day._dayLoanedTotal);
        dayStore.dayBurntTotal     = uint72(day._dayBurntTotal);
        dayStore.dayInterestRate   = uint32(day._dayInterestRate);
        dayStore.dayMintMultiplier = uint8(day._dayMintMultiplier);
    }

    function _hsiLoad(
        HEXStakeInstance hsi
    ) 
        internal
        view
        returns (ShareCache memory)
    {
        HEXStakeMinimal memory stake;

        uint16 mintedDays;
        uint8  launchBonus;
        uint16 loanStart;
        uint16 loanedDays;
        uint32 interestRate;
        uint8  paymentsMade;
        bool   isLoaned;

        (stake,
         mintedDays,
         launchBonus,
         loanStart,
         loanedDays,
         interestRate,
         paymentsMade,
         isLoaned) = hsi.share();

        return ShareCache(
            stake,
            mintedDays,
            launchBonus,
            loanStart,
            loanedDays,
            interestRate,
            paymentsMade,
            isLoaned
        );
    }

    function _shareAdd(
        HEXStakeMinimal memory stake,
        uint256 mintedDays,
        uint256 launchBonus,
        uint256 loanStart,
        uint256 loanedDays,
        uint256 interestRate,
        uint256 paymentsMade,
        bool    isLoaned
    )
        internal
    {
        shareList[stake.stakeId] =
            ShareStore(
                stake,
                uint16(mintedDays),
                uint8(launchBonus),
                uint16(loanStart),
                uint16(loanedDays),
                uint32(interestRate),
                uint8(paymentsMade),
                isLoaned
            );
    }

    function _liquidationAdd(
        address hsiAddress,
        address liquidator,
        uint256 liquidatorBid
    )
        internal
        returns (uint256)
    {
        _liquidationIds.increment();

        liquidationList[_liquidationIds.current()] =
            LiquidationStore (
                block.timestamp,
                hsiAddress,
                uint96(liquidatorBid),
                liquidator,
                uint88(0),
                true
            );

        return _liquidationIds.current();
    }
    
    function _shareLoad(
        ShareStore storage shareStore,
        ShareCache memory  share
    )
        internal
        view
    {
        share._stake        = shareStore.stake;
        share._mintedDays   = shareStore.mintedDays;
        share._launchBonus  = shareStore.launchBonus;
        share._loanStart    = shareStore.loanStart;
        share._loanedDays   = shareStore.loanedDays;
        share._interestRate = shareStore.interestRate;
        share._paymentsMade = shareStore.paymentsMade;
        share._isLoaned     = shareStore.isLoaned;
    }

    function _liquidationLoad(
        LiquidationStore storage liquidationStore,
        LiquidationCache memory  liquidation
    ) 
        internal
        view
    {
        liquidation._liquidationStart = liquidationStore.liquidationStart;
        liquidation._endOffset        = liquidationStore.endOffset;
        liquidation._hsiAddress       = liquidationStore.hsiAddress;
        liquidation._liquidator       = liquidationStore.liquidator;
        liquidation._bidAmount        = liquidationStore.bidAmount;
        liquidation._isActive         = liquidationStore.isActive;
    }
    
    function _shareUpdate(
        ShareStore storage shareStore,
        ShareCache memory  share
    )
        internal
    {
        shareStore.stake        = share._stake;
        shareStore.mintedDays   = uint16(share._mintedDays);
        shareStore.launchBonus  = uint8(share._launchBonus);
        shareStore.loanStart    = uint16(share._loanStart);
        shareStore.loanedDays   = uint16(share._loanedDays);
        shareStore.interestRate = uint32(share._interestRate);
        shareStore.paymentsMade = uint8(share._paymentsMade);
        shareStore.isLoaned     = share._isLoaned;
    }

    function _liquidationUpdate(
        LiquidationStore storage liquidationStore,
        LiquidationCache memory  liquidation
    ) 
        internal
    {
        liquidationStore.endOffset  = uint48(liquidation._endOffset);
        liquidationStore.hsiAddress = liquidation._hsiAddress;
        liquidationStore.liquidator = liquidation._liquidator;
        liquidationStore.bidAmount  = uint96(liquidation._bidAmount);
        liquidationStore.isActive   = liquidation._isActive;
    }

    function _shareSearch(
        HEXStake memory stake
    ) 
        internal
        view
        returns (bool, uint256)
    {
        bool stakeInShareList = false;
        uint256 shareIndex = 0;
        
        ShareCache memory share;

        _shareLoad(shareList[stake.stakeId], share);
            
        if (share._stake.stakeId     == stake.stakeId &&
            share._stake.stakeShares == stake.stakeShares &&
            share._stake.lockedDay   == stake.lockedDay &&
            share._stake.stakedDays  == stake.stakedDays)
        {
            stakeInShareList = true;
            shareIndex = stake.stakeId;
        }
            
        return(stakeInShareList, shareIndex);
    }


    function claimInstanced(
        uint256 hsiIndex,
        address hsiAddress,
        address hsiStarterAddress
    )
        external
    {
        require(msg.sender == hsim,
            "HSIM: Caller must be HSIM");

        address _hsiAddress = _hsim.hsiLists(hsiStarterAddress, hsiIndex);
        require(hsiAddress == _hsiAddress,
            "HDRN: HSI index address mismatch");

        ShareCache memory share = _hsiLoad(HEXStakeInstance(hsiAddress));

        if (_currentDay() < _hdrnLaunchDays) {
            share._launchBonus = _calcLPBMultiplier(_hdrnLaunchDays - _currentDay());
            _emitClaim(share._stake.stakeId, share._stake.stakeShares, share._launchBonus);
        }

        _hsim.hsiUpdate(hsiStarterAddress, hsiIndex, hsiAddress, share);

        _shareAdd(
            share._stake,
            share._mintedDays,
            share._launchBonus,
            share._loanStart,
            share._loanedDays,
            share._interestRate,
            share._paymentsMade,
            share._isLoaned
        );
    }
    
    function mintInstanced(
        uint256 hsiIndex,
        address hsiAddress
    ) 
        external
        returns (uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);

        address _hsiAddress = _hsim.hsiLists(msg.sender, hsiIndex);
        require(hsiAddress == _hsiAddress,
            "HDRN: HSI index address mismatch");

        ShareCache memory share = _hsiLoad(HEXStakeInstance(hsiAddress));
        require(_hexCurrentDay() >= share._stake.lockedDay,
            "HDRN: cannot mint against a pending HEX stake");
        require(share._isLoaned == false,
            "HDRN: cannot mint against a loaned HEX stake");

        uint256 servedDays = 0;
        uint256 mintDays   = 0;
        uint256 payout     = 0;

        servedDays = _hexCurrentDay() - share._stake.lockedDay;
        
        if (servedDays > share._stake.stakedDays) {
            servedDays = share._stake.stakedDays;
        }
        
        mintDays = servedDays - share._mintedDays;

        payout = share._stake.stakeShares * mintDays;
               
        if (share._launchBonus > 0) {
            uint256 bonus = _calcBonus(share._launchBonus, payout);
            if (bonus > 0) {
                _mint(_hdrnSourceAddress, bonus);
                day._dayMintedTotal += bonus;
                payout += bonus;
            }
        }
        else if (_currentDay() < _hdrnLaunchDays) {
            share._launchBonus = _calcLPBMultiplier(_hdrnLaunchDays - _currentDay());
            uint256 bonus = _calcBonus(share._launchBonus, payout);
            if (bonus > 0) {
                _mint(_hdrnSourceAddress, bonus);
                day._dayMintedTotal += bonus;
                payout += bonus;
            }
        }

        if (day._dayMintMultiplier > 0) {
            uint256 bonus = _calcBonus(day._dayMintMultiplier, payout);
            if (bonus > 0) {
                _mint(_hdrnSourceAddress, bonus);
                day._dayMintedTotal += bonus;
                payout += bonus;
            }
        }
        
        share._mintedDays += mintDays;

        if (payout > 0) {
            _mint(msg.sender, payout);

            _emitMint(
                share,
                payout
            );
        }

        day._dayMintedTotal += payout;

        _hsim.hsiUpdate(msg.sender, hsiIndex, hsiAddress, share);
        _shareUpdate(shareList[share._stake.stakeId], share);

        _dailyDataUpdate(dayStore, day);

        return payout;
    }
    
    function claimNative(
        uint256 stakeIndex,
        uint40  stakeId
    )
        external
        returns (uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        HEXStake memory stake = _hexStakeLoad(stakeIndex);

        require(stake.stakeId == stakeId,
            "HDRN: HEX stake index id mismatch");

        bool stakeInShareList = false;
        uint256 shareIndex    = 0;
        uint256 launchBonus   = 0;
        
        (stakeInShareList,
         shareIndex) = _shareSearch(stake);

        require(stakeInShareList == false,
            "HDRN: HEX Stake already claimed");

        if (_currentDay() < _hdrnLaunchDays) {
            launchBonus = _calcLPBMultiplier(_hdrnLaunchDays - _currentDay());
            _emitClaim(stake.stakeId, stake.stakeShares, launchBonus);
        }

        _shareAdd(
            HEXStakeMinimal(
                stake.stakeId,
                stake.stakeShares,
                stake.lockedDay,
                stake.stakedDays
            ),
            0,
            launchBonus,
            0,
            0,
            0,
            0,
            false
        );

        return launchBonus;
    }

    function mintNative(
        uint256 stakeIndex,
        uint40 stakeId
    )
        external
        returns (uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);
        
        HEXStake memory stake = _hexStakeLoad(stakeIndex);
    
        require(stake.stakeId == stakeId,
            "HDRN: HEX stake index id mismatch");
        require(_hexCurrentDay() >= stake.lockedDay,
            "HDRN: cannot mint against a pending HEX stake");
        
        bool stakeInShareList = false;
        uint256 shareIndex    = 0;
        uint256 servedDays    = 0;
        uint256 mintDays      = 0;
        uint256 payout        = 0;
        uint256 launchBonus   = 0;

        ShareCache memory share;
        
        (stakeInShareList,
         shareIndex) = _shareSearch(stake);
        
        if (stakeInShareList) {
            _shareLoad(shareList[shareIndex], share);
            
            servedDays = _hexCurrentDay() - share._stake.lockedDay;
            
            if (servedDays > share._stake.stakedDays) {
                servedDays = share._stake.stakedDays;
            }
            
            mintDays = servedDays - share._mintedDays;
            
            payout = share._stake.stakeShares * mintDays;
            
            if (share._launchBonus > 0) {
                uint256 bonus = _calcBonus(share._launchBonus, payout);
                if (bonus > 0) {
                    _mint(_hdrnSourceAddress, bonus);
                    day._dayMintedTotal += bonus;
                    payout += bonus;
                }
            }

            if (day._dayMintMultiplier > 0) {
                uint256 bonus = _calcBonus(day._dayMintMultiplier, payout);
                if (bonus > 0) {
                    _mint(_hdrnSourceAddress, bonus);
                    day._dayMintedTotal += bonus;
                    payout += bonus;
                }
            }
            
            share._mintedDays += mintDays;

            if (payout > 0) {
                _mint(msg.sender, payout);

                _emitMint(
                    share,
                    payout
                );
            }
            
            _shareUpdate(shareList[shareIndex], share);
        }
        
        else {
            servedDays = _hexCurrentDay() - stake.lockedDay;
 
            if (servedDays > stake.stakedDays) {
                servedDays = stake.stakedDays;
            }

            payout = stake.stakeShares * servedDays;
               
            if (_currentDay() < _hdrnLaunchDays) {
                launchBonus = _calcLPBMultiplier(_hdrnLaunchDays - _currentDay());
                uint256 bonus = _calcBonus(launchBonus, payout);
                if (bonus > 0) {
                    _mint(_hdrnSourceAddress, bonus);
                    day._dayMintedTotal += bonus;
                    payout += bonus;
                }
            }

            if (day._dayMintMultiplier > 0) {
                uint256 bonus = _calcBonus(day._dayMintMultiplier, payout);
                if (bonus > 0) {
                    _mint(_hdrnSourceAddress, bonus);
                    day._dayMintedTotal += bonus;
                    payout += bonus;
                }
            }

            _shareAdd(
                HEXStakeMinimal(
                    stake.stakeId,
                    stake.stakeShares, 
                    stake.lockedDay,
                    stake.stakedDays
                ),
                servedDays,
                launchBonus,
                0,
                0,
                0,
                0,
                false
            );

            _shareLoad(shareList[stake.stakeId], share);
            
            if (payout > 0) {
                _mint(msg.sender, payout);

                _emitMint(
                    share,
                    payout
                );
            }
        }

        day._dayMintedTotal += payout;
        
        _dailyDataUpdate(dayStore, day);

        return payout;
    }

    function calcLoanPayment (
        address borrower,
        uint256 hsiIndex,
        address hsiAddress
    ) 
        external
        view
        returns (uint256, uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);
        
        address _hsiAddress = _hsim.hsiLists(borrower, hsiIndex);
        require(hsiAddress == _hsiAddress,
            "HDRN: HSI index address mismatch");

        ShareCache memory share = _hsiLoad(HEXStakeInstance(hsiAddress));

        uint256 loanTermPaid      = share._paymentsMade * _hdrnLoanPaymentWindow;
        uint256 loanTermRemaining = share._loanedDays - loanTermPaid;
        uint256 principal         = 0;
        uint256 interest          = 0;

        if (share._interestRate > 0) {

            if (loanTermRemaining > _hdrnLoanPaymentWindow) {
                principal = share._stake.stakeShares * _hdrnLoanPaymentWindow;
                interest  = (principal * (share._interestRate * _hdrnLoanPaymentWindow)) / _hdrnLoanInterestResolution;
            }
            else {
                principal = share._stake.stakeShares * loanTermRemaining;
                interest  = (principal * (share._interestRate * loanTermRemaining)) / _hdrnLoanInterestResolution;
            }
        }

        else {

            if (share._stake.stakedDays > _hdrnLoanPaymentWindow) {
                principal = share._stake.stakeShares * _hdrnLoanPaymentWindow;
                interest  = (principal * (day._dayInterestRate * _hdrnLoanPaymentWindow)) / _hdrnLoanInterestResolution;
            }
            else {
                principal = share._stake.stakeShares * share._stake.stakedDays;
                interest  = (principal * (day._dayInterestRate * share._stake.stakedDays)) / _hdrnLoanInterestResolution;
            }
        }

        return(principal, interest);
    }

    function calcLoanPayoff (
        address borrower,
        uint256 hsiIndex,
        address hsiAddress
    ) 
        external
        view
        returns (uint256, uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);

        address _hsiAddress = _hsim.hsiLists(borrower, hsiIndex);

        require(hsiAddress == _hsiAddress,
            "HDRN: HSI index address mismatch");

        ShareCache memory share = _hsiLoad(HEXStakeInstance(hsiAddress));

        require (share._isLoaned == true,
            "HDRN: Cannot payoff non-existant loan");

        uint256 loanTermPaid      = share._paymentsMade * _hdrnLoanPaymentWindow;
        uint256 loanTermRemaining = share._loanedDays - loanTermPaid;
        uint256 outstandingDays   = 0;
        uint256 principal         = 0;
        uint256 interest          = 0;
        
        if (_currentDay() - share._loanStart < loanTermPaid) {
            principal = share._stake.stakeShares * loanTermRemaining;
        }

        else {
            outstandingDays = _currentDay() - share._loanStart - loanTermPaid;

            if (outstandingDays > loanTermRemaining) {
                outstandingDays = loanTermRemaining;
            }

            principal = share._stake.stakeShares * loanTermRemaining;
            interest  = ((share._stake.stakeShares * outstandingDays) * (share._interestRate * outstandingDays)) / _hdrnLoanInterestResolution;
        }

        return(principal, interest);
    }

    function loanInstanced (
        uint256 hsiIndex,
        address hsiAddress
    )
        external
        returns (uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);

        address _hsiAddress = _hsim.hsiLists(msg.sender, hsiIndex);

        require(hsiAddress == _hsiAddress,
            "HDRN: HSI index address mismatch");

        ShareCache memory share = _hsiLoad(HEXStakeInstance(hsiAddress));

        require (share._isLoaned == false,
            "HDRN: HSI loan already exists");

        uint256 loanDays = share._stake.stakedDays - share._mintedDays;

        require (loanDays > 0,
            "HDRN: No loanable days remaining");

        uint256 payout = share._stake.stakeShares * loanDays;

        if (payout > 0) {
            share._loanStart    = _currentDay();
            share._loanedDays   = loanDays;
            share._interestRate = day._dayInterestRate;
            share._isLoaned     = true;

            _emitLoanStart(
                share,
                payout
            );

            day._dayLoanedTotal += payout;
            loanedSupply += payout;

            _hsim.hsiUpdate(msg.sender, hsiIndex, hsiAddress, share);
            _shareUpdate(shareList[share._stake.stakeId], share);

            _dailyDataUpdate(dayStore, day);

            _mint(msg.sender, payout);
        }

        return payout;
    }

    function loanPayment (
        uint256 hsiIndex,
        address hsiAddress
    )
        external
        returns (uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);

        address _hsiAddress = _hsim.hsiLists(msg.sender, hsiIndex);

        require(hsiAddress == _hsiAddress,
            "HDRN: HSI index address mismatch");

        ShareCache memory share = _hsiLoad(HEXStakeInstance(hsiAddress));

        require (share._isLoaned == true,
            "HDRN: Cannot pay non-existant loan");

        uint256 loanTermPaid      = share._paymentsMade * _hdrnLoanPaymentWindow;
        uint256 loanTermRemaining = share._loanedDays - loanTermPaid;
        uint256 principal         = 0;
        uint256 interest          = 0;
        bool    lastPayment       = false;

        if (loanTermRemaining > _hdrnLoanPaymentWindow) {
            principal = share._stake.stakeShares * _hdrnLoanPaymentWindow;
            interest  = (principal * (share._interestRate * _hdrnLoanPaymentWindow)) / _hdrnLoanInterestResolution;
        }
        else {
            principal   = share._stake.stakeShares * loanTermRemaining;
            interest    = (principal * (share._interestRate * loanTermRemaining)) / _hdrnLoanInterestResolution;
            lastPayment = true;
        }

        require (balanceOf(msg.sender) >= (principal + interest),
            "HDRN: Insufficient balance to facilitate payment");

        share._paymentsMade++;

        _emitLoanPayment(
            share,
            (principal + interest)
        );

        if (lastPayment == true) {
            share._loanStart    = 0;
            share._loanedDays   = 0;
            share._interestRate = 0;
            share._paymentsMade = 0;
            share._isLoaned     = false;
        }

        _hsim.hsiUpdate(msg.sender, hsiIndex, hsiAddress, share);
        _shareUpdate(shareList[share._stake.stakeId], share);

        day._dayBurntTotal += (principal + interest);
        _dailyDataUpdate(dayStore, day);

        loanedSupply -= principal;

        _burn(msg.sender, (principal + interest));

        return(principal + interest);
    }

    function loanPayoff (
        uint256 hsiIndex,
        address hsiAddress
    )
        external
        returns (uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);

        address _hsiAddress = _hsim.hsiLists(msg.sender, hsiIndex);

        require(hsiAddress == _hsiAddress,
            "HDRN: HSI index address mismatch");

        ShareCache memory share = _hsiLoad(HEXStakeInstance(hsiAddress));

        require (share._isLoaned == true,
            "HDRN: Cannot payoff non-existant loan");

        uint256 loanTermPaid      = share._paymentsMade * _hdrnLoanPaymentWindow;
        uint256 loanTermRemaining = share._loanedDays - loanTermPaid;
        uint256 outstandingDays   = 0;
        uint256 principal         = 0;
        uint256 interest          = 0;

        if (_currentDay() - share._loanStart < loanTermPaid) {
            principal = share._stake.stakeShares * loanTermRemaining;
        }

        else {
            outstandingDays = _currentDay() - share._loanStart - loanTermPaid;

            if (outstandingDays > loanTermRemaining) {
                outstandingDays = loanTermRemaining;
            }

            principal = share._stake.stakeShares * loanTermRemaining;
            interest  = ((share._stake.stakeShares * outstandingDays) * (share._interestRate * outstandingDays)) / _hdrnLoanInterestResolution;
        }

        require (balanceOf(msg.sender) >= (principal + interest),
            "HDRN: Insufficient balance to facilitate payoff");

        _emitLoanEnd(
            share,
            (principal + interest)
        );

        share._loanStart    = 0;
        share._loanedDays   = 0;
        share._interestRate = 0;
        share._paymentsMade = 0;
        share._isLoaned     = false;

        _hsim.hsiUpdate(msg.sender, hsiIndex, hsiAddress, share);
        _shareUpdate(shareList[share._stake.stakeId], share);

        day._dayBurntTotal += (principal + interest);
        _dailyDataUpdate(dayStore, day);

        loanedSupply -= principal;

        _burn(msg.sender, (principal + interest));

        return(principal + interest);
    }

    function loanLiquidate (
        address owner,
        uint256 hsiIndex,
        address hsiAddress
    )
        external
        returns (uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        address _hsiAddress = _hsim.hsiLists(owner, hsiIndex);

        require(hsiAddress == _hsiAddress,
            "HDRN: HSI index address mismatch");

        ShareCache memory share = _hsiLoad(HEXStakeInstance(hsiAddress));

        require (share._isLoaned == true,
            "HDRN: Cannot liquidate a non-existant loan");

        uint256 loanTermPaid      = share._paymentsMade * _hdrnLoanPaymentWindow;
        uint256 loanTermRemaining = share._loanedDays - loanTermPaid;
        uint256 outstandingDays   = _currentDay() - share._loanStart - loanTermPaid;
        uint256 principal         = share._stake.stakeShares * loanTermRemaining;

        require (outstandingDays >= _hdrnLoanDefaultThreshold,
            "HDRN: Cannot liquidate a loan not in default");

        if (outstandingDays > loanTermRemaining) {
            outstandingDays = loanTermRemaining;
        }

        uint256 interest = ((share._stake.stakeShares * outstandingDays) * (share._interestRate * outstandingDays)) / _hdrnLoanInterestResolution;

        require (balanceOf(msg.sender) >= (principal + interest),
            "HDRN: Insufficient balance to facilitate liquidation");

        share._loanStart    = 0;
        share._loanedDays   = 0;
        share._interestRate = 0;
        share._paymentsMade = 0;
        share._isLoaned     = false;

        _hsim.hsiUpdate(owner, hsiIndex, hsiAddress, share);
        _shareUpdate(shareList[share._stake.stakeId], share);

        _hsim.hsiTransfer(owner, hsiIndex, hsiAddress, address(0));

        _liquidationAdd(hsiAddress, msg.sender, (principal + interest));

        _emitLoanLiquidateStart(
            share,
            uint40(_liquidationIds.current()),
            owner,
            (principal + interest)
        );

        loanedSupply -= principal;

        _burn(msg.sender, (principal + interest));

        return(principal + interest);
    }

    function loanLiquidateBid (
        uint256 liquidationId,
        uint256 liquidationBid
    )
        external
        returns (uint256)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        LiquidationCache memory  liquidation;
        LiquidationStore storage liquidationStore = liquidationList[liquidationId];
        
        _liquidationLoad(liquidationStore, liquidation);

        require(liquidation._isActive == true,
            "HDRN: Cannot bid on invalid liquidation");

        require (balanceOf(msg.sender) >= liquidationBid,
            "HDRN: Insufficient balance to facilitate liquidation");

        require (liquidationBid > liquidation._bidAmount,
            "HDRN: Liquidation bid must be greater than current bid");

        require((block.timestamp - (liquidation._liquidationStart + liquidation._endOffset)) <= 86400,
            "HDRN: Cannot bid on expired liquidation");

        uint256 timestampModified = ((block.timestamp + 300) - (liquidation._liquidationStart + liquidation._endOffset));
        if (timestampModified > 86400) {
            liquidation._endOffset += (timestampModified - 86400);
        }

        _mint(liquidation._liquidator, liquidation._bidAmount);

        liquidation._liquidator = msg.sender;
        liquidation._bidAmount  = liquidationBid;

        _liquidationUpdate(liquidationStore, liquidation);

        ShareCache memory share = _hsiLoad(HEXStakeInstance(liquidation._hsiAddress));

        _emitLoanLiquidateBid(
            share._stake.stakeId,
            uint40(liquidationId),
            liquidationBid
        );

        _burn(msg.sender, liquidationBid);

        return(
            liquidation._liquidationStart +
            liquidation._endOffset +
            86400
        );
    }

    function loanLiquidateExit (
        uint256 hsiIndex,
        uint256 liquidationId
    )
        external
        returns (address)
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);

        LiquidationStore storage liquidationStore = liquidationList[liquidationId];
        LiquidationCache memory  liquidation;

        _liquidationLoad(liquidationStore, liquidation);
        
        require(liquidation._isActive == true,
            "HDRN: Cannot exit on invalid liquidation");

        require((block.timestamp - (liquidation._liquidationStart + liquidation._endOffset)) >= 86400,
            "HDRN: Cannot exit on active liquidation");

        _hsim.hsiTransfer(address(0), hsiIndex, liquidation._hsiAddress, liquidation._liquidator);

        day._dayBurntTotal += liquidation._bidAmount;

        liquidation._isActive == false;

        ShareCache memory share = _hsiLoad(HEXStakeInstance(liquidation._hsiAddress));

        _emitLoanLiquidateExit(
            share._stake.stakeId,
            uint40(liquidationId),
            liquidation._liquidator,
            liquidation._bidAmount
        );

        _dailyDataUpdate(dayStore, day);
        _liquidationUpdate(liquidationStore, liquidation);

        return liquidation._hsiAddress;
    }

    function proofOfBenevolence (
        uint256 amount
    )
        external
    {
        require(block.timestamp >= _hdrnLaunch,
            "HDRN: Contract not yet active");

        DailyDataCache memory  day;
        DailyDataStore storage dayStore = dailyDataList[_currentDay()];

        _dailyDataLoad(dayStore, day);

        require (balanceOf(msg.sender) >= amount,
            "HDRN: Insufficient balance to facilitate PoB");

        uint256 currentAllowance = allowance(msg.sender, address(this));

        require(currentAllowance >= amount,
            "HDRN: Burn amount exceeds allowance");
        
        day._dayBurntTotal += amount;
        _dailyDataUpdate(dayStore, day);

        unchecked {
            _approve(msg.sender, address(this), currentAllowance - amount);
        }

        _burn(msg.sender, amount);
    }
}