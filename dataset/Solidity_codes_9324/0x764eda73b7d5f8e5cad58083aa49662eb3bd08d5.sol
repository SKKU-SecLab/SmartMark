
pragma solidity =0.8.0;


interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns(bool);

}

interface IERC721 /* is ERC165 */ {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns(uint256);


    function ownerOf(uint256 _tokenId) external view returns(address);


    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;


    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function approve(address _approved, uint256 _tokenId) external payable;


    function setApprovalForAll(address _operator, bool _approved) external;


    function getApproved(uint256 _tokenId) external view returns(address);


    function isApprovedForAll(address _owner, address _operator) external view returns(bool);

}

interface IERC721Metadata /* is ERC721 */ {

    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function tokenURI(uint256 _tokenId) external view returns (string memory);

}

interface IERC721TokenReceiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);

}

interface IERC721TokenReceiverEx is IERC721TokenReceiver {

    function onERC721ExReceived(address operator, address from,
        uint256[] memory tokenIds, bytes memory data)
        external returns(bytes4);

}

library Address {


    function isContract(address account) internal view returns(bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


library Bytes {

    bytes internal constant BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    
    function base64Encode(bytes memory bs) internal pure returns(string memory) {

        uint256 remain = bs.length % 3;
        uint256 length = bs.length / 3 * 4;
        bytes memory result = new bytes(length + (remain != 0 ? 4 : 0) + (3 - remain) % 3);
        
        uint256 i = 0;
        uint256 j = 0;
        while (i < length) {
            result[i++] = BASE64_CHARS[uint8(bs[j] >> 2)];
            result[i++] = BASE64_CHARS[uint8((bs[j] & 0x03) << 4 | bs[j + 1] >> 4)];
            result[i++] = BASE64_CHARS[uint8((bs[j + 1] & 0x0f) << 2 | bs[j + 2] >> 6)];
            result[i++] = BASE64_CHARS[uint8(bs[j + 2] & 0x3f)];
            
            j += 3;
        }
        
        if (remain != 0) {
            result[i++] = BASE64_CHARS[uint8(bs[j] >> 2)];
            
            if (remain == 2) {
                result[i++] = BASE64_CHARS[uint8((bs[j] & 0x03) << 4 | bs[j + 1] >> 4)];
                result[i++] = BASE64_CHARS[uint8((bs[j + 1] & 0x0f) << 2)];
                result[i++] = BASE64_CHARS[0];
                result[i++] = 0x3d;
            } else {
                result[i++] = BASE64_CHARS[uint8((bs[j] & 0x03) << 4)];
                result[i++] = BASE64_CHARS[0];
                result[i++] = BASE64_CHARS[0];
                result[i++] = 0x3d;
                result[i++] = 0x3d;
            }
        }
        
        return string(result);
    }
    
    function concat(bytes memory a, bytes memory b)
        internal pure returns(bytes memory) {

        
        uint256 al = a.length;
        uint256 bl = b.length;
        
        bytes memory c = new bytes(al + bl);
        
        for (uint256 i = 0; i < al; ++i) {
            c[i] = a[i];
        }
        
        for (uint256 i = 0; i < bl; ++i) {
            c[al + i] = b[i];
        }
        
        return c;
    }
}

library String {

    function equals(string memory a, string memory b)
        internal pure returns(bool) {

        
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        
        uint256 la = ba.length;
        uint256 lb = bb.length;
        
        for (uint256 i = 0; i < la && i < lb; ++i) {
            if (ba[i] != bb[i]) {
                return false;
            }
        }
        
        return la == lb;
    }
    
    function concat(string memory a, string memory b)
        internal pure returns(string memory) {

        
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bc = new bytes(ba.length + bb.length);
        
        uint256 bal = ba.length;
        uint256 bbl = bb.length;
        uint256 k = 0;
        
        for (uint256 i = 0; i < bal; ++i) {
            bc[k++] = ba[i];
        }
        
        for (uint256 i = 0; i < bbl; ++i) {
            bc[k++] = bb[i];
        }
        
        return string(bc);
    }
}

library UInteger {

    function toString(uint256 a, uint256 radix)
        internal pure returns(string memory) {

        
        if (a == 0) {
            return "0";
        }
        
        uint256 length = 0;
        for (uint256 n = a; n != 0; n /= radix) {
            ++length;
        }
        
        bytes memory bs = new bytes(length);
        
        while (a != 0) {
            uint256 b = a % radix;
            a /= radix;
            
            if (b < 10) {
                bs[--length] = bytes1(uint8(b + 48));
            } else {
                bs[--length] = bytes1(uint8(b + 87));
            }
        }
        
        return string(bs);
    }
    
    function toString(uint256 a) internal pure returns(string memory) {

        return UInteger.toString(a, 10);
    }
    
    function max(uint256 a, uint256 b) internal pure returns(uint256) {

        return a > b ? a : b;
    }
    
    function min(uint256 a, uint256 b) internal pure returns(uint256) {

        return a < b ? a : b;
    }
    
    function shiftLeft(uint256 n, uint256 bits, uint256 shift)
        internal pure returns(uint256) {

        
        require(n < (1 << bits), "shiftLeft overflow");
        
        return n << shift;
    }
    
    function toDecBytes(uint256 n) internal pure returns(bytes memory) {

        if (n == 0) {
            return bytes("0");
        }
        
        uint256 length = 0;
        for (uint256 m = n; m > 0; m /= 10) {
            ++length;
        }
        
        bytes memory bs = new bytes(length);
        
        while (n > 0) {
            uint256 m = n % 10;
            n /= 10;
            
            bs[--length] = bytes1(uint8(m + 48));
        }
        
        return bs;
    }
}

library Util {

    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;
    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;
}

abstract contract ContractOwner {
    address immutable public contractOwner = msg.sender;
    
    modifier onlyContractOwner {
        require(msg.sender == contractOwner, "only contract owner");
        _;
    }
}

abstract contract ERC721 is IERC165, IERC721, IERC721Metadata {
    using Address for address;
    
    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    
    bytes4 private constant INTERFACE_ID_ERC721Metadata = 0x5b5e139f;
    
    string public override name;
    string public override symbol;
    
    mapping(address => uint256[]) internal ownerTokens;
    mapping(uint256 => uint256) internal tokenIndexs;
    mapping(uint256 => address) internal tokenOwners;
    
    mapping(uint256 => address) internal tokenApprovals;
    mapping(address => mapping(address => bool)) internal approvalForAlls;
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function balanceOf(address owner) external view override returns(uint256) {
        require(owner != address(0), "owner is zero address");
        return ownerTokens[owner].length;
    }
    
    function tokensOf(address owner, uint256 startIndex, uint256 endIndex)
        external view returns(uint256[] memory) {
        
        require(owner != address(0), "owner is zero address");
        
        uint256[] storage tokens = ownerTokens[owner];
        if (endIndex == 0) {
            endIndex = tokens.length;
        }
        
        uint256[] memory result = new uint256[](endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; ++i) {
            result[i - startIndex] = tokens[i];
        }
        
        return result;
    }
    
    function ownerOf(uint256 tokenId)
        external view override returns(address) {
        
        address owner = tokenOwners[tokenId];
        require(owner != address(0), "nobody own the token");
        return owner;
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId)
            external payable override {
        
        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId,
        bytes memory data) public payable override {
        
        _transferFrom(from, to, tokenId);
        
        if (to.isContract()) {
            require(IERC721TokenReceiver(to)
                .onERC721Received(msg.sender, from, tokenId, data)
                == Util.ERC721_RECEIVER_RETURN,
                "onERC721Received() return invalid");
        }
    }
    
    function transferFrom(address from, address to, uint256 tokenId)
        external payable override {
        
        _transferFrom(from, to, tokenId);
    }
    
    function _transferFrom(address from, address to, uint256 tokenId)
        internal {
        
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");
        
        require(from == tokenOwners[tokenId], "from must be owner");
        
        require(msg.sender == from
            || msg.sender == tokenApprovals[tokenId]
            || approvalForAlls[from][msg.sender],
            "sender must be owner or approvaled");
        
        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }
        
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);
        
        emit Transfer(from, to, tokenId);
    }
    
    function _removeTokenFrom(address from, uint256 tokenId) internal {
        uint256 index = tokenIndexs[tokenId];
        
        uint256[] storage tokens = ownerTokens[from];
        uint256 indexLast = tokens.length - 1;
        
            uint256 tokenIdLast = tokens[indexLast];
            tokens[index] = tokenIdLast;
            tokenIndexs[tokenIdLast] = index;
        
        tokens.pop();
        
        delete tokenOwners[tokenId];
    }
    
    function _addTokenTo(address to, uint256 tokenId) internal {
        uint256[] storage tokens = ownerTokens[to];
        tokenIndexs[tokenId] = tokens.length;
        tokens.push(tokenId);
        
        tokenOwners[tokenId] = to;
    }
    
    function approve(address to, uint256 tokenId)
        external payable override {
        
        address owner = tokenOwners[tokenId];
        
        require(msg.sender == owner
            || approvalForAlls[owner][msg.sender],
            "sender must be owner or approved for all"
        );
        
        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    function setApprovalForAll(address to, bool approved) external override {
        approvalForAlls[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }
    
    function getApproved(uint256 tokenId)
        external view override returns(address) {
        
        require(tokenOwners[tokenId] != address(0),
            "nobody own then token");
        
        return tokenApprovals[tokenId];
    }
    
    function isApprovedForAll(address owner, address operator)
        external view override returns(bool) {
        
        return approvalForAlls[owner][operator];
    }
    
    function supportsInterface(bytes4 interfaceID)
        external pure override returns(bool) {
        
        return interfaceID == INTERFACE_ID_ERC165
            || interfaceID == INTERFACE_ID_ERC721
            || interfaceID == INTERFACE_ID_ERC721Metadata;
    }
}

abstract contract ERC721Ex is ERC721 {
    using Address for address;
    using String for string;
    using UInteger for uint256;
    
    uint256 public totalSupply = 0;
    
    string public uriPrefix;
    
    function _mint(address to, uint256 tokenId) internal {
        _addTokenTo(to, tokenId);
        
        ++totalSupply;
        
        emit Transfer(address(0), to, tokenId);
    }
    
    function _burn(uint256 tokenId) internal {
        address owner = tokenOwners[tokenId];
        _removeTokenFrom(owner, tokenId);
        
        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }
        
        emit Transfer(owner, address(0), tokenId);
    }
    
    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds) external {
        
        safeBatchTransferFrom(from, to, tokenIds, "");
    }
    
    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds, bytes memory data) public {
        
        batchTransferFrom(from, to, tokenIds);
        
        if (to.isContract()) {
            require(IERC721TokenReceiverEx(to)
                .onERC721ExReceived(msg.sender, from, tokenIds, data)
                == Util.ERC721_RECEIVER_EX_RETURN,
                "onERC721ExReceived() return invalid");
        }
    }
    
    function batchTransferFrom(address from, address to,
        uint256[] memory tokenIds) public {
        
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");
        
        address sender = msg.sender;
        bool approval = from == sender || approvalForAlls[from][sender];
        
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 tokenId = tokenIds[i];
			
            require(from == tokenOwners[tokenId], "from must be owner");
            require(approval || sender == tokenApprovals[tokenId],
                "sender must be owner or approvaled");
            
            if (tokenApprovals[tokenId] != address(0)) {
                delete tokenApprovals[tokenId];
            }
            
            _removeTokenFrom(from, tokenId);
            _addTokenTo(to, tokenId);
            
            emit Transfer(from, to, tokenId);
        }
    }
    
    function tokenURI(uint256 cardId)
        external view override returns(string memory) {
        
        return uriPrefix.concat(cardId.toString());
    }
}

contract Card is ERC721Ex, ContractOwner {

    mapping(address => bool) public whiteList;
    
    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol) {
    }
    
    function setUriPrefix(string memory prefix) external onlyContractOwner {

        uriPrefix = prefix;
    }
    
    function setWhiteList(address account, bool enable) external onlyContractOwner {

        whiteList[account] = enable;
    }
    
    function mint(address to) external {

        require(whiteList[msg.sender], "not in whiteList");
        
        _mint(to, totalSupply + 1);
    }
}