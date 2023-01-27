
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

library Base64 {

    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';
        
        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)
            
            let tablePtr := add(table, 1)
            
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            
            let resultPtr := add(result, 32)
            
            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 3)
               
               let input := mload(dataPtr)
               
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
            
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }
        
        return result;
    }
}// Unlicense


pragma solidity^0.8.0;


interface ICorruptions {

    function ownerOf(uint256 tokenID) external returns (address);

    function insight(uint256 tokenID) external view returns (uint256);

}

interface ICorruptionsBookOfElysiumMetadata {

    function tokenURI(uint256 tokenId, uint256 style, uint32[] memory chapters, uint256 arete) external view returns (string memory);

}

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface ERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed fromAddress, address indexed toAddress);
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

interface ERC721Metadata {

    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string memory);

}

contract CorruptionsBookOfElysium is ERC721, ERC721Metadata, ReentrancyGuard, Ownable {


    event MergeTexts(uint256 indexed tokenIdBurned, uint256 indexed tokenIdPersist, uint32[] combinedChapters);

    string private _name;
    string private _symbol;

    address constant public _dead = 0x000000000000000000000000000000000000dEaD;

    mapping (address => bool) private _blacklistAddress;

    mapping (address => bool) private _whitelistAddress;

    mapping (address => uint256) private _tokens;

    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _owners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    mapping (uint256 => uint256) private _styles;

    mapping (uint256 => uint32[]) public _chapters;

    mapping (uint256 => uint256) private _arete;

    mapping (uint256 => uint8) public _rendererIndexes;

    uint256 public _tokenCount;

    mapping (uint32 => uint32) public _printsPerChapter;

    uint256 public constant _maxPrintsPerChapter = 128;

    bool public mintable;
    uint256 public minInsight;
    uint32 public releasedChapters;
    uint32 public totalChapters;
    uint256 public elysiumBalance;

    address[] public renderers;

    constructor() Ownable() {
        _name = "CorruptionsBookOfElysium";
        _symbol = "ELYSIUM";

        _blacklistAddress[address(this)] = true;

        mintable = true;
        releasedChapters = 1;
        totalChapters = 2**32 - 1; // Max int for now, will update when final corruption chapter ends
        minInsight = 53;

        renderers.push(0x8bc508C14125Aba67f37D35c61511B8677816590); // current default
        renderers.push(0x8bc508C14125Aba67f37D35c61511B8677816590); // user-selectable preset
    }


    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function totalSupply() public view returns (uint256) {

        return _tokenCount;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function _approve(address owner, address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: nonexistent token");       
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

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (address owner, bool isApprovedOrOwner) {

        owner = _owners[tokenId];

        require(owner != address(0), "ERC721: nonexistent token");

        isApprovedOrOwner = (spender == owner || _tokenApprovals[tokenId] == spender || isApprovedForAll(owner, spender));
    }

    function exists(uint256 tokenId) public view returns (bool) {

        return _exists(tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        (address owner, bool isApprovedOrOwner) = _isApprovedOrOwner(_msgSender(), tokenId);
        require(isApprovedOrOwner, "ERC721: transfer caller is not owner nor approved");
        _transfer(owner, from, to, tokenId);
    }

    function _transfer(address owner, address from, address to, uint256 tokenId) internal {

        require(owner == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        require(!_blacklistAddress[to], "Elysium: transfer attempt to blacklist address");

        if (to == _dead) {
            _burnNoEmitTransfer(owner, tokenId);

            emit Transfer(from, _dead, tokenId);
            emit Transfer(_dead, address(0), tokenId);
        } else {
            _approve(owner, address(0), tokenId);

            emit Transfer(from, to, tokenId);

            if (from == to) {
                return;
            }



            bool fromIsWhitelisted = isWhitelisted(from);
            bool toIsWhitelisted = isWhitelisted(to);

            if (fromIsWhitelisted) {
                _balances[from] -= 1;
            } else {
                delete _balances[from];
            }
            if (toIsWhitelisted) {
                _balances[to] += 1;
            } else if (_tokens[to] == 0) {
                _balances[to] = 1;
            } else {
            }

            if (toIsWhitelisted) {
                _owners[tokenId] = to;
            } else {
                uint256 currentTokenId = _tokens[to];

                if (currentTokenId == 0) {
                    _owners[tokenId] = to;

                    _tokens[to] = tokenId;
                } else {
                    uint256 sentTokenId = tokenId;

                    uint256 deadTokenId = _merge(currentTokenId, sentTokenId);

                    emit Transfer(to, address(0), deadTokenId);

                    uint256 aliveTokenId = currentTokenId;
                    if (currentTokenId == deadTokenId) {
                        aliveTokenId = sentTokenId;
                    }

                    delete _owners[deadTokenId];

                    if (currentTokenId != aliveTokenId) {
                        _owners[aliveTokenId] = to;

                        _tokens[to] = aliveTokenId;
                    }
                }
            }

            if (!fromIsWhitelisted) {
                delete _tokens[from];
            }
        }
    }

    function _merge(uint256 tokenIdRcvr, uint256 tokenIdSndr) internal returns (uint256 tokenIdDead) {

        require(tokenIdRcvr != tokenIdSndr, "Elysium: illegal argument identical tokenId");

        uint32[] storage chaptersRcvr = _chapters[tokenIdRcvr];
        uint32[] storage chaptersSndr = _chapters[tokenIdSndr];
        for (uint32 s = 0; s < chaptersSndr.length; s++) {
            bool _hasChapter;
            for (uint32 r = 0; r < chaptersRcvr.length; r++) {
                if (chaptersSndr[s] == chaptersRcvr[r]) {
                    _hasChapter = true;
                }
            }
            if (!_hasChapter) {
                chaptersRcvr.push(chaptersSndr[s]);
            }
        }
        _chapters[tokenIdRcvr] = chaptersRcvr;
        _arete[tokenIdRcvr] += _arete[tokenIdSndr];
        delete _chapters[tokenIdSndr];
        delete _arete[tokenIdSndr];
        _tokenCount -= 1;

        emit MergeTexts(tokenIdSndr, tokenIdRcvr, chaptersRcvr);

        return tokenIdSndr;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {

        if (isContract(to)) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                }
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
        return true;
    }    

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        bytes4 _ERC165_ = 0x01ffc9a7;
        bytes4 _ERC721_ = 0x80ac58cd;
        bytes4 _ERC2981_ = 0x2a55205a;
        bytes4 _ERC721Metadata_ = 0x5b5e139f;
        return interfaceId == _ERC165_ 
            || interfaceId == _ERC721_
            || interfaceId == _ERC2981_
            || interfaceId == _ERC721Metadata_;
    }

    function balanceOf(address owner) public view override returns (uint256) {

        return _balances[owner];        
    }

    function ownerOf(uint256 tokenId) public view override returns (address owner) {

        owner = _owners[tokenId]; 
        require(owner != address(0), "ERC721: nonexistent token");
    }

    function burn(uint256 tokenId) public {

        (address owner, bool isApprovedOrOwner) = _isApprovedOrOwner(_msgSender(), tokenId);
        require(isApprovedOrOwner, "ERC721: caller is not owner nor approved");

        _burnNoEmitTransfer(owner, tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burnNoEmitTransfer(address owner, uint256 tokenId) internal {

        _approve(owner, address(0), tokenId);

        delete _tokens[owner];
        delete _owners[tokenId];
        delete _chapters[tokenId];

        _tokenCount -= 1;
        _balances[owner] -= 1;        

        uint32[] memory emptyChapters;
        emit MergeTexts(tokenId, 0, emptyChapters);
    }


    function isWhitelisted(address address_) public view returns (bool) {

        return _whitelistAddress[address_];
    }

    function isBlacklisted(address address_) public view returns (bool) {

        return _blacklistAddress[address_];
    }

    function setBlacklistAddress(address address_, bool status) external onlyOwner {

        _blacklistAddress[address_] = status;
    }
   
    function whitelistUpdate(address address_, bool status) external onlyOwner {

        if(status == false) {
            require(balanceOf(address_) <= 1, "Elysium: Address with more than one token can't be removed.");
        }
        _whitelistAddress[address_] = status;
    }

    function setMintability(bool mintability) public onlyOwner {

        mintable = mintability;
    }

    function setReleasedChapters(uint32 chapter) public onlyOwner {

        releasedChapters = chapter;
    }

    function setTotalChapters(uint32 chapter) public onlyOwner {

        totalChapters = chapter;
    }

    function setMinimumInsight(uint256 insight) public onlyOwner {

        minInsight = insight;
    }

    function setDefaultRenderer(address addr) public onlyOwner {

        if (renderers.length == 0) {
            renderers.push(addr); // current default
            renderers.push(addr); // user-selectable preset
        } else {
            renderers[0] = addr;
        }
    }

    function addRenderer(address addr) public onlyOwner {

        renderers.push(addr);
    }

    function overwriteRenderer(address addr, uint index) public onlyOwner {

        renderers[index] = addr;
    }

    function withdrawOwnerBalance() public nonReentrant onlyOwner {

        require(payable(_msgSender()).send(address(this).balance - elysiumBalance));
    }

    function escapeHatch() public nonReentrant onlyOwner {

        address multisig = 0x4fFFFF3eD1E82057dffEe66b4aa4057466E24a38;
        require(payable(multisig).send(address(this).balance));
    }

    
    function PRINT(uint256 corruptionsTokenId, uint32 chapter, string memory ack) payable public nonReentrant {

        require(mintable || _msgSender() == owner(), "Elysium: the printer is locked");


        require(msg.value >= 0.08 ether, "Elysium: 0.08 ETH to print");
        if (chapter <= 1) {
            elysiumBalance += 0.02 ether;
        } else {
            elysiumBalance += 0.06 ether;
        }

        require(keccak256(bytes(ack)) == bytes32(hex"98f083d894dad4ec49f86c8deae933e9e51a46d20f726170c3460fa6c80077f4"), "Elysium: not acknowledged");

        require(_printsPerChapter[chapter] < _maxPrintsPerChapter, "Elysium: all editions of chapter printed");
        require(chapter <= releasedChapters, "Elysium: chapter not found");
        require(ICorruptions(0x5BDf397bB2912859Dbd8011F320a222f79A28d2E).ownerOf(corruptionsTokenId) == msg.sender, "Elysium: corruption not owned");
        require(ICorruptions(0x5BDf397bB2912859Dbd8011F320a222f79A28d2E).insight(corruptionsTokenId) >= minInsight, "Elysium: insight too low");

        uint256 elysiumTokenId;
        if (_tokens[msg.sender] == 0) {
            elysiumTokenId = ++_tokenCount;
            _owners[elysiumTokenId] = msg.sender;
            _tokens[msg.sender] = elysiumTokenId;
            _balances[msg.sender] = 1;
            _styles[elysiumTokenId] = corruptionsTokenId;

            emit Transfer(address(0), msg.sender, elysiumTokenId);
        } else {
            elysiumTokenId = _tokens[msg.sender];
        }
        bool _hasChapter;
        uint32[] storage chaptersCollected = _chapters[elysiumTokenId];
        for (uint32 i = 0; i < chaptersCollected.length; i++) {
            if (chaptersCollected[i] == chapter) {
                _hasChapter = true;
                break;
            }
        }
        if (_hasChapter == false) {
            chaptersCollected.push(chapter);
            _chapters[elysiumTokenId] = chaptersCollected;
        }
        _arete[elysiumTokenId] += 1;
        _printsPerChapter[chapter] += 1;
    }

    function setRenderer(uint256 tokenId, uint8 index) public {

        require(ownerOf(tokenId) == msg.sender, "Elysium: tokenID not owned");
        require(index <= renderers.length, "Elysium: index out of range");
        _rendererIndexes[tokenId] = index;
    }

    function setStyle(uint256 tokenId, uint256 corruptionsTokenId) public {

        require(ownerOf(tokenId) == msg.sender, "Elysium: tokenID not owned");
        require(ICorruptions(0x5BDf397bB2912859Dbd8011F320a222f79A28d2E).ownerOf(corruptionsTokenId) == msg.sender, "Elysium: corruption not owned");
        _styles[tokenId] = corruptionsTokenId;
    }

    function arete(uint256 tokenId) public view returns (uint256) {

        return _arete[tokenId];
    }

    function hasChapter(uint256 tokenId, uint32 chapter) public view returns (bool) {

        for (uint i = 0; i < _chapters[tokenId].length; i++) {
            if (_chapters[tokenId][i] == chapter) {
                return true;
            }
        }
        return false;
    }
    function isKnowledgeComplete(uint256 tokenId) public view returns (bool) {

        return _chapters[tokenId].length == totalChapters;
    }

    function enterElysium(uint256 tokenId) public nonReentrant {

        require(ownerOf(tokenId) == msg.sender, "Elysium: tokenID not owned");
        require(isKnowledgeComplete(tokenId), "Elysium: you try the door -- it's locked");
        require(elysiumBalance != 0 && address(this).balance >= elysiumBalance, "Elysium: you try the door -- an empty room");
        require(payable(_msgSender()).send(elysiumBalance));
        elysiumBalance = 0;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {

        require(0 < renderers.length, "Elysium: you open your eyes -- it's dark");
        require(_exists(tokenId), "Elysium: tokenId does not exist");
        return ICorruptionsBookOfElysiumMetadata(renderers[_rendererIndexes[tokenId]]).tokenURI(
            tokenId, _styles[tokenId], _chapters[tokenId], _arete[tokenId]
        );
    }

}

