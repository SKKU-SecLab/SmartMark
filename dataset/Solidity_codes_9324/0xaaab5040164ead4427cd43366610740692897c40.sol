

pragma solidity ^0.8.14;

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

interface ERC721TokenReceiver {

    function onERC721Received(address operator,address from, uint256 id, bytes calldata data) external returns (bytes4);

}

abstract contract ERC721slimBatch {
    using Address for address;
    using Strings for uint256;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    struct collectionData {
        string name;
        string symbol;
        uint256 index;
        uint256 burned;
    }

    address private _contractOwner;
    collectionData internal _collectionData;
    mapping(uint256 => address) internal _ownerships;
    mapping(address => uint256) internal _addressData;
    mapping(uint256 => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) private  _operatorApprovals;

    constructor(string memory _name, string memory _symbol) {
        _collectionData.name = _name;
        _collectionData.symbol = _symbol;
        _transferOwnership(_msgSender());
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _exists(uint256 tokenId) public view virtual returns (bool) {
        return tokenId < _collectionData.index;
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        unchecked {
            if (tokenId < _collectionData.index) {
                address ownership = _ownerships[tokenId];
                if (ownership != address(0)) {
                    return ownership;
                }
                    while (true) {
                        tokenId--;
                        ownership = _ownerships[tokenId];

                        if (ownership != address(0)) {
                            return ownership;
                        }
                         
                    }
                }
            }

        revert ();
    }

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "Address 0");
        return _addressData[_owner];
    }

    function _mint(address to, uint256 quantity) internal {
        require(to != address(0), "Address 0");
        require(quantity > 0, "Quantity 0");

        unchecked {
            uint256 updatedIndex = _collectionData.index;
            _addressData[to] += quantity;
            _ownerships[updatedIndex] = to;
            
            for (uint256 i; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex++);
            }

            _collectionData.index = updatedIndex;
        }
    }

    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

    function _safeMint(address to, uint256 quantity, bytes memory _data) internal {
        require(to != address(0), "Address 0");
        require(quantity > 0, "Quantity 0");

        unchecked {
            uint256 updatedIndex = _collectionData.index;
            _addressData[to] += quantity;
            _ownerships[updatedIndex] = to;
            
            for (uint256 i; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex);
                require(to.code.length == 0 ||
                        ERC721TokenReceiver(to).onERC721Received(_msgSender(), address(0), updatedIndex, _data) ==
                        ERC721TokenReceiver.onERC721Received.selector, "Unsafe Destination");
                updatedIndex++;
            }

            _collectionData.index = updatedIndex;
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        address currentOwner = ownerOf(tokenId);
        require((_msgSender() == currentOwner ||
            getApproved(tokenId) == _msgSender() ||
            isApprovedForAll(currentOwner,_msgSender())), "Not Approved");
        require(currentOwner == from, "Not Owner");
        require(to != address(0), "Address 0");

        delete _tokenApprovals[tokenId]; 
        unchecked {
            _addressData[from] -= 1;
            _addressData[to] += 1;
            _ownerships[tokenId] = to;
            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId] == address(0) && nextTokenId < _collectionData.index) {
                _ownerships[nextTokenId] = currentOwner;
            }
        }

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual {
        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual {
        transferFrom(from, to, tokenId);
        require(to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(_msgSender(), address(0), tokenId, _data) ==
                ERC721TokenReceiver.onERC721Received.selector, "Unsafe Destination");
    }
    
    function totalSupply() public view returns (uint256) {
        unchecked {
            return _collectionData.index - _collectionData.burned;
        }
    }

    function totalCreated() public view returns (uint256) {
        return _collectionData.index;
    }

    function totalBurned() public view returns (uint256) {
        return _collectionData.burned;
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != _msgSender(), "Address is Owner");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address _owner, address operator) public view returns (bool) {
        return _operatorApprovals[_owner][operator];
    }

    function approve(address to, uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        require(_msgSender() == tokenOwner || isApprovedForAll(tokenOwner, _msgSender()), "ERC721L: Not Approved");
        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721L: Null ID");
        return _tokenApprovals[tokenId];
    }

    function name() public view returns (string memory) {
        return _collectionData.name;
    }

    function symbol() public view returns (string memory) {
        return _collectionData.symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(_exists(tokenId), "Non Existent");
        string memory _baseURI = baseURI();
        return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenId.toString())) : '';
    }

    function baseURI() public view virtual returns (string memory) {
        return '';
    }

    function tokensOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 totalOwned = _addressData[_owner];
        require(totalOwned > 0, "balance 0");
        uint256 supply = _collectionData.index;
        uint256[] memory tokenIDs = new uint256[](totalOwned);
        uint256 ownedIndex;
        address currentOwner;

        unchecked {
            for (uint256 i; i < supply; i++) {
                address currentAddress = _ownerships[i];
                if (currentAddress != address(0)) {
                    currentOwner = currentAddress;
                }
                if (currentOwner == _owner) {
                    tokenIDs[ownedIndex++] = i;
                    if (ownedIndex == totalOwned){
                        return tokenIDs;
                    }
                }
            }
        }

        revert();
    }

    function owner() public view returns (address) {
        return _contractOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Caller not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _contractOwner;
        _contractOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function collectionInformation() public view returns (collectionData memory) {
        return _collectionData;
    }

    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

}

interface IRocketPass {

    function balanceOf(address _address, uint256 id) external view returns (uint256);

}


contract HASHDroid is ERC721slimBatch {


    string private _baseURI = "ipfs://QmZov5NNjcx472daCYvD3unxgWXQ1UJwYsAPr6yMFiJT5a/";
    uint256 public constant maxPublicMinted = 2063;

    uint256 public publicMaxMint = 7;
    uint256 public priceDroid = .069 ether;
    uint256 public publicMinted;

    bool public depreciatedMint;
    bool public mintStatus;
    IRocketPass public rocketPass;

    mapping(address => uint256) public mintedRP;

  constructor(address _rocketPass) ERC721slimBatch("BMC Hashdroid", "HD") {
      rocketPass = IRocketPass(_rocketPass);
  }

  modifier callerIsUser() {

    require(tx.origin == _msgSender(), "Contract Caller");
    _;
  }

  function rpMint(uint256 _quantity) public callerIsUser() {

    require(mintStatus, "Public sale not active");
    require(rocketPass.balanceOf(_msgSender(), 1) - mintedRP[_msgSender()] >= _quantity, "Insufficient Rocket Passes remaining");

    mintedRP[_msgSender()] += _quantity;
    _mint(_msgSender(), _quantity);
  }

  function publicMint(uint256 _quantity) public payable callerIsUser() {

    require(mintStatus, "Public sale not active");
    require(_quantity <= publicMaxMint, "Invalid quantity");
    unchecked {
        require(publicMinted + _quantity <= maxPublicMinted, "Insufficient supply remaining");
        require(msg.value >= priceDroid * _quantity, "Insufficient payment");
    }
    publicMinted += _quantity;
    _mint(_msgSender(), _quantity);
  }

  function baseURI() public view override returns (string memory) {

    return _baseURI;
  }

  function setBaseURI(string calldata newBaseURI) external onlyOwner {

    _baseURI = newBaseURI;
  }

  function setRocketPass(address _address) external onlyOwner {

    require(!depreciatedMint, "Contract is depreciated.");
    rocketPass = IRocketPass(_address);
  }

  function setPublicState(bool _state) external onlyOwner {

    require(!depreciatedMint, "Contract is depreciated.");
    mintStatus = _state;
  }

  function setPublicMaxMint(uint256 _newLimit) external onlyOwner {

    require(!depreciatedMint, "Contract is already depreciated.");
    publicMaxMint = _newLimit;
  }

  function depreciateMint() external onlyOwner {

    require(!depreciatedMint, "Contract is already depreciated.");
    delete mintStatus;
    depreciatedMint = true;
    uint256 excess = 7777 - totalSupply();
    if (excess > 0){
        uint256 droidsToMint = excess > 60 ? 60 : excess; 
        _mint(_msgSender(), droidsToMint);
    }
    
  }

  function verifyRP(address _address) external view returns (bool){

    return (rocketPass.balanceOf(_address, 1) - mintedRP[_address]) > 0;
  }

  function withdrawFunding() external onlyOwner {

    uint256 currentBalance = address(this).balance;
    (bool sent, ) = address(msg.sender).call{value: currentBalance}('');
    require(sent, "Transfer Error");    
  }

}