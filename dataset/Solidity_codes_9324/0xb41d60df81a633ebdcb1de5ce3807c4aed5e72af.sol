
interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.2;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}



pragma solidity ^0.6.2;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}



pragma solidity ^0.6.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}



pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.6.0;








contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri) public {
        _setURI(uri);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: batch balance query for the zero address");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal virtual
    { }


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}



pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


pragma solidity ^0.6.0;

library Strings {

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d,
        string memory _e
    ) internal pure returns (string memory) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint256 k = 0;
        for (uint256 i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint256 i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint256 i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint256 i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint256 i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d
    ) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c
    ) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {

        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}


pragma solidity ^0.6.0;

interface IERC2981 {


    function royaltyInfo(uint256 _tokenId) external view returns (address receiver, uint256 amount);


    function onRoyaltiesReceived(address _royaltyRecipient, address _buyer, uint256 _tokenId, address _tokenPaid, uint256 _amount, bytes32 _metadata) external returns (bytes4);


    event RoyaltiesReceived(
        address indexed _royaltyRecipient,
        address indexed _buyer,
        uint256 indexed _tokenId,
        address _tokenPaid,
        uint256 _amount,
        bytes32 _metadata
    );

}


pragma solidity ^0.6.0;





contract OwnableDelegateProxy {}


contract ProxyRegistry {

  mapping(address => OwnableDelegateProxy) public proxies;
}

contract TRSRTradable is ERC1155, Ownable, IERC2981 {

  using Strings for string;

  address proxyRegistryAddress;
  mapping(uint256 => uint256) public tokenSupply;
  string public name;
  string public symbol;

  mapping(uint256 => string) private uris;
  string private baseMetadataURI;

  bytes4 private constant _INTERFACE_ID_ERC721ROYALTIES = 0x263d4ef1;

  struct RoyaltyInfo {
      address creator;
      uint256 amount;
  }

  uint256 public _defultRoyalty = 1000000; // 10%
  mapping(uint256 => RoyaltyInfo) private _royaltyInfos;

  event CreatorChanged(uint256 indexed _id, address indexed _creator);
  event DefultRoyaltyChanged(uint256 _royalty);
    

  event URI(string _uri, uint256 indexed _id);

  constructor (
    string memory _name,
    string memory _symbol,
    address _proxyRegistryAddress
  ) public ERC1155(""){
    name = _name;
    symbol = _symbol;
    proxyRegistryAddress = _proxyRegistryAddress;
    
    _registerInterface(_INTERFACE_ID_ERC721ROYALTIES);
  }

  function uri(uint256 _id) public view override returns (string memory) {

    require(_exists(_id), "TRSRTradable#uri: NONEXISTENT_TOKEN");
    
    if(bytes(uris[_id]).length > 0){
        return uris[_id];
    }
    return Strings.strConcat(baseMetadataURI, Strings.uint2str(_id));
  }

  function totalSupply(uint256 _id) public view returns (uint256) {

    return tokenSupply[_id];
  }

  function setURIPrefix(string memory _newBaseMetadataURI) public onlyOwner{

    baseMetadataURI = _newBaseMetadataURI;
  }

  function setDefultRoyalty(uint256 _royalty) public onlyOwner{

    _defultRoyalty = _royalty;
    emit DefultRoyaltyChanged(_royalty);
  }

  modifier checkMint (
    address author, 
    uint256 _tokenId, 
    uint256 _quantity, 
    bytes memory _data) 
  {

    if (_exists(_tokenId) == false) {
        _royaltyInfos[_tokenId].creator = author;
        _royaltyInfos[_tokenId].amount = _defultRoyalty;
        _mint(author, _tokenId, _quantity, _data);
        tokenSupply[_tokenId] = tokenSupply[_tokenId].add(_quantity);
    }else{
      if (_royaltyInfos[_tokenId].creator == author) {
        if (balanceOf(author, _tokenId) < _quantity) {
          uint256 amount = _quantity.sub(balanceOf(author, _tokenId));
          _mint(author, _tokenId, amount, _data);
          tokenSupply[_tokenId] = tokenSupply[_tokenId].add(amount); 
        }
      }
    }
    _;
  }

  modifier checkBatchMint (
    address author, 
    uint256[] memory ids, 
    uint256[] memory amounts,
    bytes memory _data)
  {

    
    for (uint i = 0; i < ids.length; i++) {
      uint256 _tokenId = ids[i];
      uint256 _quantity = amounts[i];
      if (_exists(_tokenId) == false) {
        _royaltyInfos[_tokenId].creator = author;
        _royaltyInfos[_tokenId].amount = _defultRoyalty;
        _mint(author, _tokenId, _quantity, _data);
        tokenSupply[_tokenId] = tokenSupply[_tokenId].add(_quantity);
      }else{
        if (_royaltyInfos[_tokenId].creator == author) {
          if (balanceOf(author, _tokenId) < _quantity) {
            uint256 amount = _quantity.sub(balanceOf(author, _tokenId));
            _mint(author, _tokenId, amount, _data);
            tokenSupply[_tokenId] = tokenSupply[_tokenId].add(amount);
          }
        }
      }
    }
    _;
  }
  
  modifier creatorOnly(uint256 _tokenId) {

      require(
          _royaltyInfos[_tokenId].creator == msg.sender, 
          "MintMulTRSRNFT: ONLY_CREATOR_ALLOWED"
      );
      _;
  }

  function modifyRoyalty(uint256 _id ,uint256 amount) external creatorOnly(_id) {

      _royaltyInfos[_id].amount = amount;
  }

  function setCreator(uint256 _id, address _to) public creatorOnly(_id) {

      require(
          _to != address(0),
          "MintMulTRSRNFT: INVALID_ADDRESS."
      );
      _royaltyInfos[_id].creator = _to;
      emit CreatorChanged(_id, _to);
  }

  function royaltyInfo(uint256 _id) external view override returns (address receiver, uint256 amount) {

      receiver = _royaltyInfos[_id].creator;
      amount = _royaltyInfos[_id].amount;
  }

  function onRoyaltiesReceived(address _royaltyRecipient, address _buyer, uint256 _tokenId, address _tokenPaid, uint256 _amount, bytes32 _metadata) external override returns (bytes4) {

    emit RoyaltiesReceived(_royaltyRecipient, _buyer, _tokenId, _tokenPaid, _amount, _metadata);    
    return bytes4(keccak256("onRoyaltiesReceived(address,address,uint256,address,uint256,bytes32)"));
  }

  function updateUri(uint256 _id, string calldata _uri) external creatorOnly(_id){

    if (bytes(_uri).length > 0) {
      uris[_id] = _uri;
      emit URI(_uri, _id);
    }
  }

  function burn(address _address, uint256 _id, uint256 _amount) external {

      require((msg.sender == _address) || isApprovedForAll(_address, msg.sender), "ERC1155#burn: INVALID_OPERATOR");
      require(balanceOf(_address,_id) >= _amount, "Trying to burn more tokens than you own");
      tokenSupply[_id] = tokenSupply[_id].sub(_amount);
      _burn(_address, _id, _amount);
  }

  function updateProxyRegistryAddress(address _proxyRegistryAddress) external onlyOwner{

      require(_proxyRegistryAddress != address(0), "No zero address");
      proxyRegistryAddress = _proxyRegistryAddress;
  }

  function mint(
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
  ) public {

    if (_exists(_id)) {
      require(_royaltyInfos[_id].creator == _msgSender(), "MintMulTRSRNFT: ONLY_CREATOR_ALLOWED"); 
      _royaltyInfos[_id].creator = _msgSender();
      _royaltyInfos[_id].amount = _defultRoyalty;
      _mint(_msgSender(), _id, _quantity, _data);
      tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    } else {
      _royaltyInfos[_id].creator = _msgSender();
      _royaltyInfos[_id].amount = _defultRoyalty;
      _mint(_msgSender(), _id, _quantity, _data);
      tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    }
  }

  function isApprovedForAll(address _owner, address _operator) public view override returns (bool isOperator) {

    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }
    return super.isApprovedForAll(_owner, _operator);
  }

  function safeTransferFrom(
      address from,
      address to,
      uint256 id,
      uint256 amount,
      bytes memory data
  )
  checkMint(from, id, amount, data)
      public
      virtual
      override
  {

      super.safeTransferFrom(from, to, id, amount, data);
  }

  function safeBatchTransferFrom(
      address from,
      address to,
      uint256[] memory ids,
      uint256[] memory amounts,
      bytes memory data
  )
  checkBatchMint(from, ids, amounts, data)
      public
      virtual
      override
  {

     super.safeBatchTransferFrom(from, to, ids, amounts, data);
  }

  function _exists(uint256 _id) internal view returns (bool) {

    return _royaltyInfos[_id].creator != address(0);
  }
}


pragma solidity ^0.6.0;

contract MintMulTRSRNFT is TRSRTradable {

  string public constant version = "1.0.0";
  
  constructor(address _proxyRegistryAddress) public TRSRTradable("treasureland.dego", "TRSRNFT", _proxyRegistryAddress) {
    setURIPrefix("https://api.treasureland.market/v2/lazy_mint/");
  }
}