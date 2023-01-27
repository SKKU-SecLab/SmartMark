



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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
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

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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
        require(operator != _msgSender(), "ERC721: approve to caller");

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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




pragma solidity ^0.8.0;


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



pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;







contract NFTLAB is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct AuctionInfo {
        uint256 lastBid;
        address lastBidder;
        address[] bidders;
        uint finishedAt;
        uint startedAt;
    }

    struct BidInfo {
        address bidder;
        uint256 amount;
        uint256[] bids;
        uint timestamp;
        bool isLast;
    }

    struct ItemsInfo {
        IERC721 collection;
        address payable owner;
        uint256 tokenid;
        uint256 price;
        address asset;
        bool forSale;
        bool isSold;
        bool isWithdrawn;
        address[] profitTakers;
        uint256[] profitShares;  // from 0 to 10000, very 10000 is 100.00%
        AssetType assetType;
        OrderType orderType;
        AuctionInfo auction;
    }

    struct BuyInfo {
        uint256 timestamp;
        uint256 price;
        address buyer;
    }

    enum AssetType {ETH, ERC20}
    enum OrderType {DIRECT, SIMPLE_AUCTION}

    address payable public feeTaker;

    uint256 public fee; // 0..100.00% (where 1 is 0.01%)
    uint256 public feeMax = 5000; // 50.00%
    uint256 public denominator = 10000; // 100.00%

    IERC20[] public allowedTokens;

    ItemsInfo[] public itemsInfo;

    mapping (OrderType => uint256[]) public itemsByOrderType;
    mapping (uint256 => mapping (address => BidInfo)) public bidsItemInfo;

    mapping (uint256 => BuyInfo[]) public buyItemInfo;

    constructor(address payable _feeTaker, uint256 _fee) {
        require(_fee <= denominator,
                "fee should be great or equal to 0 and less than 100.00%");
        feeTaker = _feeTaker;
        fee = _fee;
    }

    function getItemsLength()
        external view returns (uint256)
    {
        return itemsInfo.length;
    }

    function isAllowedToken(IERC20 _token)
        public view returns (bool)
    {
        for(uint idx=0; idx < allowedTokens.length; idx++) {
            if(allowedTokens[idx] == _token) {
                return true;
            }
        }
        return false;
    }

    function tokensLength()
        external view returns (uint256)
    {
        return allowedTokens.length;
    }

    function add(IERC20 _token)
        public onlyOwner
    {
        require(isAllowedToken(_token) == false, "should be added once time");
        allowedTokens.push(_token);
    }

    function setFeeTaker(address payable _addr)
        public onlyOwner
    {
        feeTaker = _addr;
    }

    function setFee(uint256 _fee)
        public onlyOwner
    {
        require(_fee>= 0 && _fee <= feeMax, "Not Number");
        fee = _fee;
    }

    function cancelAuction(uint256 _itemId)
        public onlyOwner
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        IERC721 itemCollection = item.collection;
        require(item.orderType == OrderType.SIMPLE_AUCTION, "Only auction!");
        require(item.forSale == true, "Not for sale!");
        require(item.isSold == false, "Not for sale!");

        AuctionInfo storage auctionInfo = item.auction;
        if(auctionInfo.lastBid>0) {
            if(item.assetType == AssetType.ERC20) {
                IERC20 token = IERC20(item.asset);
                token.safeTransfer(
                    address(auctionInfo.lastBidder),
                    auctionInfo.lastBid
                );
            } else {
                payable(auctionInfo.lastBidder).transfer(auctionInfo.lastBid);
            }
        }

        itemCollection.safeTransferFrom(
            address(this), address(item.owner), item.tokenid
        );
        item.auction.finishedAt = block.timestamp;
        item.isSold = false;
        item.forSale = false;
    }

    function setStartPrice(uint256 _itemId, uint256 _price)
        public onlyOwner
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        require(item.forSale == true,
                "Is not possible to change price for sold items");
        require(item.isSold == false,
                "Is not possible to change price for sold items");
        if(item.orderType == OrderType.SIMPLE_AUCTION) {
            require(item.auction.bidders.length == 0,
                    "Allow to change start price only if now bidders");
        }

        item.price = _price;
    }

    function setStartedAt(uint256 _itemId, uint256 _startedAt)
        public onlyOwner
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        require(item.forSale == true,
                "Is not possible to change startedAt for sold items");
        require(item.isSold == false,
                "Is not possible to change startedAt for sold items");
        require(item.orderType != OrderType.DIRECT,
                "Started time needs only for auction");

        item.auction.startedAt = _startedAt;
    }

    function placeItem(
        IERC721 _collection,
        uint256 _tokenId,
        uint256 _price,
        address _asset,
        bool _forSale,
        uint256 _startedAt,
        address[] memory _profitTakers,
        uint256[] memory _profitShares, // from 0 to 10000, very 10000 is 100.00%
        AssetType _assetType,
        OrderType _orderType
    )
        public onlyOwner
    {
        require(_orderType == OrderType.DIRECT || _orderType == OrderType.SIMPLE_AUCTION,
                "only direct order type and auction is possible");

        require(_forSale == true,
                "permited only auction for sale");

        require(_assetType == AssetType.ETH || _assetType == AssetType.ERC20,
                "only erc20 or eth asset type permitted for auction");

        require(_startedAt != 0,
                "started at is required");

        require(_startedAt >= (block.timestamp - 86400),
                "startedAt should be greater or equal than block.timestamp - 86400");

        {
            require(_profitShares.length == _profitTakers.length,
                    "num of shares should be equal to num of takers");
            uint256 shares;
            if(_orderType == OrderType.DIRECT) {
                shares = 10000;
            } else {
                shares = 10000 - fee;
            }
            for(uint256 i=0;i < _profitTakers.length;i++) {
                require(shares - _profitShares[i] >= 0,
                        "all shares should be lower or equal to 100.00 - fee");
                shares = shares - _profitShares[i];
            }
            require(shares == 0,
                    "after all distribution check shares amount is not equal to 0");
        }

        if(_assetType == AssetType.ETH) {
            require(_asset == address(0), "_asset should be zero for ETH asset type");
        }
        _collection.transferFrom(address(msg.sender), address(this), _tokenId);
        AuctionInfo memory auctionInfo;
        address[] memory bidders;
        auctionInfo.lastBid = 0;
        auctionInfo.finishedAt = 0;
        auctionInfo.startedAt = _startedAt;
        auctionInfo.lastBidder = address(0x0);
        auctionInfo.bidders = bidders;

        itemsInfo.push(ItemsInfo({
            collection: _collection,
            owner: payable(msg.sender),
            tokenid: _tokenId,
            price: _price,
            asset: _asset,
            forSale: _forSale,
            isSold: false,
            isWithdrawn: false,
            profitTakers: _profitTakers,
            profitShares: _profitShares,
            assetType: _assetType,
            orderType: _orderType,
            auction: auctionInfo
        }));
        itemsByOrderType[_orderType].push(itemsInfo.length - 1);
    }

    function _distributeProfitToTakers(
        ItemsInfo memory item,
        uint256 _price,
        uint256 _fee
    )
        internal returns (uint256)
    {
        if(item.assetType == AssetType.ETH) {
            return _distributeProfitToTakersForETH(item, _price, _fee);
        } else if(item.assetType == AssetType.ERC20) {
            return _distributeProfitToTakersForErc20(item, _price, _fee);
        }
        revert();
    }

    function _distributeProfitToTakersForETH(
        ItemsInfo memory item,
        uint256 _price,
        uint256 _fee
    )
        internal returns (uint256)
    {

        uint256 distributedProfit = _fee;
        if(_fee > 0)
            feeTaker.transfer(_fee);

        for(uint256 i=0; i < item.profitTakers.length; i++) {
            address taker = item.profitTakers[i];
            uint256 share = item.profitShares[i];
            uint256 amount = _price.mul(share).div(denominator);
            payable(taker).transfer(amount);
            distributedProfit = distributedProfit.add(amount);
        }
        return distributedProfit;
    }

    function _distributeProfitToTakersForErc20(
        ItemsInfo memory item,
        uint256 _price,
        uint256 _fee
    )
        internal returns (uint256)
    {

        uint256 distributedProfit = _fee;
        IERC20 token = IERC20(item.asset);
        if(_fee > 0)
            token.safeTransfer(feeTaker, _fee);

        for(uint256 i=0; i < item.profitTakers.length; i++) {
            address taker = item.profitTakers[i];
            uint256 share = item.profitShares[i];
            uint256 amount = _price.mul(share).div(denominator);
            token.safeTransfer(taker, amount);
            distributedProfit = distributedProfit.add(amount);

        }
        return distributedProfit;
    }

    function changePriceOnMarket(uint256 _itemId, uint256 _newPrice)
        public onlyOwner
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        require(item.owner == msg.sender, "Not owner!");
        item.price = _newPrice;
    }

    function withdrawItemFromMarket(uint256 _itemId)
        public onlyOwner
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        IERC721 itemCollection = item.collection;
        require(item.owner == msg.sender, "Not owner!");
        itemCollection.safeTransferFrom(address(this), address(msg.sender), item.tokenid);
        item.isWithdrawn = true;
    }

    function buyItemFromMarket(uint256 _itemId)
        public
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        IERC721 itemCollection = item.collection;
        require(item.orderType == OrderType.DIRECT, "Only direct buy!");
        require(item.forSale == true, "Already sold!");
        require(item.assetType == AssetType.ERC20, "Only for ERC20!");

        uint256 feeAmount = item.price.mul(fee).div(denominator);
        uint256 shouldBeDistributed = feeAmount.add(item.price);
        uint256 _distributedProfit = _distributeProfitToTakers(item, item.price, feeAmount);
        require(_distributedProfit == shouldBeDistributed);

        itemCollection.safeTransferFrom(address(this), address(msg.sender), item.tokenid);

        item.isSold = true;
        buyItemInfo[item.tokenid].push(BuyInfo({
            timestamp: block.timestamp,
            price: _distributedProfit,
            buyer: msg.sender
        }));
    }

    function buyItemFromMarketForEth(uint256 _itemId)
        public payable
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        IERC721 itemCollection = item.collection;
        require(item.orderType == OrderType.DIRECT, "Only direct buy!");
        require(item.forSale == true, "Already sold!");
        require(item.assetType == AssetType.ETH, "Only for ETH!");

        uint256 feeAmount = item.price.mul(fee).div(denominator);
        uint256 shouldBeDistributed = feeAmount.add(item.price);
        require(msg.value >= shouldBeDistributed, "ETH amount is lower than expected");
        uint256 _distributedProfit = _distributeProfitToTakers(item, item.price, feeAmount);
        require(_distributedProfit == shouldBeDistributed);
        itemCollection.safeTransferFrom(address(this), address(msg.sender), item.tokenid);

        item.isSold = true;
        buyItemInfo[item.tokenid].push(BuyInfo({
            timestamp:block.timestamp,
            price:_distributedProfit,
            buyer:msg.sender
        }));
    }

    function finishAuction(uint256 _itemId)
        public onlyOwner
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        IERC721 itemCollection = item.collection;
        require(item.auction.bidders.length > 0,
                "It is possible to finish only bidded auctions");
        require(item.orderType == OrderType.SIMPLE_AUCTION, "Only auction!");
        require(item.forSale == true, "Not for sale!");

        AuctionInfo storage auctionInfo = item.auction;

        uint256 feeAmount = auctionInfo.lastBid.mul(fee).div(denominator);
        uint256 distributedProfit = _distributeProfitToTakers(
            item, auctionInfo.lastBid, feeAmount
        );
        require(distributedProfit == auctionInfo.lastBid,
                "distributedProfit should be equal to lastBid");

        itemCollection.safeTransferFrom(
            address(this), address(auctionInfo.lastBidder), item.tokenid
        );
        item.auction.finishedAt = block.timestamp;
        item.isSold = true;
        item.forSale = false;
        buyItemInfo[item.tokenid].push(BuyInfo({
            timestamp:block.timestamp,
            price:auctionInfo.lastBid,
            buyer:auctionInfo.lastBidder
        }));
    }

    function _submitBidForErc20(uint256 _itemId, uint256 _bidPrice)
        internal
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        require(item.orderType == OrderType.SIMPLE_AUCTION, "Only auction!");
        require(item.assetType == AssetType.ERC20, "Only for ERC20!");
        require(msg.value == 0, "Ether is not permit");

        IERC20 token = IERC20(item.asset);
        uint256 tokenBalance = token.balanceOf(address(msg.sender));
        BidInfo storage bidInfo = bidsItemInfo[_itemId][msg.sender];
        AuctionInfo storage auctionInfo = item.auction;

        require(tokenBalance > item.price, "new bid should be greater than minimal item price");
        require(tokenBalance > auctionInfo.lastBid, "new bid should be greater than last");

        token.safeTransferFrom(address(msg.sender), address (this), _bidPrice);

        if(auctionInfo.lastBidder != address(0x0)) {
            token.safeTransfer(auctionInfo.lastBidder, auctionInfo.lastBid);
            bidsItemInfo[_itemId][auctionInfo.lastBidder].isLast = false;
        }

        auctionInfo.lastBid = _bidPrice;
        auctionInfo.lastBidder = msg.sender;

        if(bidInfo.bidder == address(0x0)) {
            bidInfo.bidder = msg.sender;
            auctionInfo.bidders.push(msg.sender);
        }
        bidInfo.amount = _bidPrice;
        bidInfo.isLast = true;
        bidInfo.timestamp = block.timestamp;
        bidInfo.bids.push(_bidPrice);
    }

    function _submitBidForEth(uint256 _itemId)
        internal
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        require(item.orderType == OrderType.SIMPLE_AUCTION, "Only auction!");
        require(item.assetType == AssetType.ETH, "Only for ETH!");

        BidInfo storage bidInfo = bidsItemInfo[_itemId][msg.sender];
        AuctionInfo storage auctionInfo = item.auction;

        require(msg.value > item.price, "new bid should be greater than minimal item price");
        require(msg.value > auctionInfo.lastBid, "new bid should be greater than last");

        if(auctionInfo.lastBidder != address(0x0)) {
            payable(auctionInfo.lastBidder).transfer(auctionInfo.lastBid);
            bidsItemInfo[_itemId][auctionInfo.lastBidder].isLast = false;
        }
        auctionInfo.lastBid = msg.value;
        auctionInfo.lastBidder = msg.sender;

        if(bidInfo.bidder == address(0x0)) {
            bidInfo.bidder = msg.sender;
            auctionInfo.bidders.push(msg.sender);
        }
        bidInfo.amount = msg.value;
        bidInfo.isLast = true;
        bidInfo.bids.push(msg.value);
    }

    function submitBid(uint256 _itemId, uint256 _bidPrice)
        public payable
    {
        ItemsInfo storage item = itemsInfo[_itemId];
        require(item.orderType == OrderType.SIMPLE_AUCTION, "Only auction!");
        require(item.forSale == true, "Not for sale!");
        require(item.auction.startedAt <= block.timestamp, "started at greater than current time");

        if(item.assetType == AssetType.ETH) {
            require(_bidPrice == 0, "For eth _bidPrice should be 0");
            _submitBidForEth(_itemId);
        } else if(item.assetType == AssetType.ERC20) {
            require(msg.value == 0, "For erc20 msg.value should be 0");
            _submitBidForErc20(_itemId, _bidPrice);
        }
    }

    function getAuctionInfo(uint256 _tokenid)
        view  public returns (AuctionInfo memory)
    {
        return(itemsInfo[_tokenid].auction);
    }

    function getItems(OrderType _orderType)
        view  public returns (ItemsInfo[] memory)
    {
        uint256[] memory itemIds = itemsByOrderType[_orderType];
        ItemsInfo[] memory items = new ItemsInfo[](itemIds.length);
        for(uint idx=0; idx < itemIds.length; idx++) {
            items[idx] = itemsInfo[itemIds[idx]];
        }
        return(items);
    }

    function getAuctions()
        view  public returns (ItemsInfo[] memory)
    {
        return getItems(OrderType.SIMPLE_AUCTION);
    }

    function getDirectItems()
        view  public returns (ItemsInfo[] memory)
    {
        return getItems(OrderType.DIRECT);
    }

    function getAuctionBids(uint256 _tokenid)
        view public returns (BidInfo[] memory)
    {
        ItemsInfo storage item = itemsInfo[_tokenid];
        AuctionInfo memory auctionInfo = item.auction;
        BidInfo[] memory bids = new BidInfo[](auctionInfo.bidders.length);
        for(uint idx;idx<auctionInfo.bidders.length;idx++) {
            bids[idx] = getBidInfo(_tokenid, auctionInfo.bidders[idx]);
        }
        return bids;
    }

    function getBidInfo(uint256 _tokenid, address _bidder)
        public view returns(BidInfo memory)
    {
        return bidsItemInfo[_tokenid][_bidder];
    }

    function getBuyItemInfo(uint256 _tokenid)
        view public returns (BuyInfo[] memory)
    {
        return(buyItemInfo[_tokenid]);
    }
}