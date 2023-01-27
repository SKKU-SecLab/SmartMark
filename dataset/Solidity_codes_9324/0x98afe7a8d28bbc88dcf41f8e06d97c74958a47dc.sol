

pragma solidity >=0.8.4 >=0.8.0 <0.9.0;


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
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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




interface IMemeNumbers{
}

interface ITokenRenderer {
    function tokenURI(IMemeNumbers instance, uint256 tokenId) external view returns (string memory);
}

contract MemeNumbersRenderer is ITokenRenderer {
  using Strings for uint;

  function renderNFTImage(IMemeNumbers instance, uint256 tokenId) public view returns (string memory) {
    return Base64.encode(bytes(abi.encodePacked(
      '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidyMid meet" viewBox="0 0 400 400" style="background:black">',
        '<text x="200" y="200" style="text-anchor:middle;dominant-baseline:middle;fill:white;font-size:24px;">',
          tokenId.toString(),
        '</text>',
      '</svg>')));
  }

  function _generateAttributes(uint256 tokenId) internal pure returns (string memory) {
    string memory parity = "Odd";
    if (tokenId % 2 == 0) {
      parity = "Even";
    }

    uint256 i = tokenId;
    uint256 digits = 0;
    while (i != 0) {
      digits++;
      i /= 10;
    }

    return string(abi.encodePacked(
      '[',
         '{',
            '"trait_type": "Digits",',
            '"value": ', digits.toString(),
          '},',
          '{',
              '"trait_type": "Parity",',
              '"value": ','"',parity,'"'
          '}',
      ']'
    ));
  }

  function tokenURI(IMemeNumbers instance, uint256 tokenId) public view override(ITokenRenderer) returns (string memory) {
    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(bytes(abi.encodePacked(
              '{"name":"', tokenId.toString(), '"',
              ',"description":"What is your meme number?"', // FIXME: Write something better
              ',"external_url":"https://memenumbers.com"',
              ',"image":"data:image/svg+xml;base64,', renderNFTImage(instance, tokenId), '"',
              ',"attributes":', _generateAttributes(tokenId),
              '}'
        )))
      )
    );
  }
}




library Errors {
    string constant AlreadyMinted = "already minted";
    string constant UnderPriced = "current price is higher than msg.value";
    string constant NotForSale = "number is not for sale in this batch";
    string constant MustOwnNum = "must own number to operate on it";
    string constant NoSelfBurn = "burn numbers must be different";
    string constant InvalidOp = "invalid op";
    string constant DoesNotExist = "does not exist";
    string constant RendererUpgradeDisabled = "renderer upgrade disabled";
}

contract MemeNumbers is ERC721, Ownable {
    uint256 public constant AUCTION_START_PRICE = 5 ether;
    uint256 public constant AUCTION_DURATION = 1 hours;
    uint256 public constant BATCH_SIZE = 8;
    uint256 constant DECAY_RESOLUTION = 1000000000; // 1 gwei

    uint256 public auctionStarted;
    uint256[BATCH_SIZE] private forSale;

    mapping(uint256 => bool) viaBurn; // Numbers that were created via burn

    bool disableRenderUpgrade = false;
    ITokenRenderer public renderer;

    event Refresh(); // TODO: Do we want to include any fields?

    constructor(address _renderer) ERC721("MemeNumbers", "MEMENUM") {
        renderer = ITokenRenderer(_renderer);

        _refresh();
    }


    function _getEntropy() view internal returns(uint256) {

        return uint256(keccak256(
            abi.encodePacked(
                msg.sender,
                block.coinbase,
                block.difficulty,
                block.gaslimit,
                block.timestamp,
                blockhash(block.number))));
    }

    function _refresh() internal {
        auctionStarted = block.timestamp;

        uint256 entropy = _getEntropy();

        forSale[0] = (entropy >> 0) & (2 ** 8 - 1);
        forSale[1] = (entropy >> 5) & (2 ** 10 - 1);
        forSale[2] = (entropy >> 8) & (2 ** 14 - 1);
        forSale[3] = (entropy >> 8) & (2 ** 18 - 1);
        forSale[4] = (entropy >> 13) & (2 ** 24 - 1);
        forSale[5] = (entropy >> 21) & (2 ** 32 - 1);
        forSale[6] = (entropy >> 34) & (2 ** 64 - 1);
        forSale[7] = (entropy >> 55) & (2 ** 86 - 1);

        emit Refresh();
    }



    function currentPrice() view public returns(uint256) {
        uint256 endTime = (auctionStarted + AUCTION_DURATION);
        if (block.timestamp >= endTime) {
            return 0;
        }
        uint256 elapsed = endTime - block.timestamp;
        return AUCTION_START_PRICE * ((elapsed * DECAY_RESOLUTION) / AUCTION_DURATION) / DECAY_RESOLUTION; 
    }

    function isForSale(uint256 num) view public returns (bool) {
        for (uint256 i=0; i<forSale.length; i++) {
            if (forSale[i] == num) return !_exists(num);
        }
        return false;
    }

    function getForSale() view external returns (uint256[] memory nums) {
        uint256[] memory batch = new uint256[](BATCH_SIZE);
        uint256 count = 0;
        for (uint256 i=0; i<forSale.length; i++) {
            if (_exists(forSale[i])) continue;
            batch[count] = forSale[i];
            count += 1;
        }

        nums = new uint256[](count);
        for (uint256 i=0; i<count; i++) {
            nums[i] = batch[i];
        }

        return nums;
    }

    function isMintedByBurn(uint256 num) view external returns (bool) {
        return viaBurn[num];
    }

    function operate(uint256 num1, string calldata op, uint256 num2) public pure returns (uint256) {
        bytes1 mode = bytes(op)[0];
        if (mode == "a") { // Add
            return num1 + num2;
        }
        if (mode == "s") { // Subtact
            return num1 - num2;
        }
        if (mode == "m") { // Multiply
            return num1 * num2;
        }
        if (mode == "d") { // Divide
            return num1 / num2;
        }
        revert(Errors.InvalidOp);
    }



    function mint(address to, uint256 num) external payable {
        uint256 price = currentPrice();
        require(price <= msg.value, Errors.UnderPriced);
        require(isForSale(num), Errors.NotForSale);

        _mint(to, num);
        _refresh();

        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function mintAll(address to) external payable {
        uint256 price = currentPrice();
        require(price <= msg.value, Errors.UnderPriced);

        for (uint256 i=0; i<forSale.length; i++) {
            if (_exists(forSale[i])) continue;
            _mint(to, forSale[i]);
        }

        _refresh();

        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function refresh() external {
        require(currentPrice() == 0, Errors.UnderPriced);
        _refresh();
    }

    function burn(address to, uint256 num1, string calldata op, uint256 num2) external {
        require(num1 != num2, Errors.NoSelfBurn);
        require(ownerOf(num1) == _msgSender(), Errors.MustOwnNum);
        require(ownerOf(num2) == _msgSender(), Errors.MustOwnNum);

        uint256 num = operate(num1, op, num2);
        require(!_exists(num), Errors.AlreadyMinted);

        _mint(to, num);
        viaBurn[num] = true;

        _burn(num1);
        _burn(num2);
        delete viaBurn[num1];
        delete viaBurn[num2];
    }



    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        require(_exists(tokenId), Errors.DoesNotExist);
        return renderer.tokenURI(IMemeNumbers(address(this)), tokenId);
    }



    function adminWithdraw(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }

    function adminSetRenderer(address _renderer) external onlyOwner {
        require(disableRenderUpgrade == false, Errors.RendererUpgradeDisabled);
        renderer = ITokenRenderer(_renderer);
    }

    function adminDisableRenderUpgrade() external onlyOwner {
        disableRenderUpgrade = true;
    }

}