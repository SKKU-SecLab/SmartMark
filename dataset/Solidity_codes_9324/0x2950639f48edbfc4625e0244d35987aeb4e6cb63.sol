
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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT
pragma solidity ^0.8.7;
 interface IERC1155TokenReceiver {


  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4);


  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT
pragma solidity ^0.8.7;

abstract contract ERC165 is IERC165 {
  function supportsInterface(bytes4 _interfaceID) virtual override public pure returns (bool) {
    return _interfaceID == this.supportsInterface.selector;
  }
}// MIT
pragma solidity ^0.8.7;


contract ERC1155PackedBalance is IERC1155, ERC165 {

  using SafeMath for uint256;
  using Address for address;


  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  uint256 internal constant IDS_BITS_SIZE   = 32;                  // Max balance amount in bits per token ID
  uint256 internal constant IDS_PER_UINT256 = 256 / IDS_BITS_SIZE; // Number of ids per uint256

  enum Operations { Add, Sub }

  mapping (address => mapping(uint256 => uint256)) internal balances;

  mapping (address => mapping(address => bool)) internal operators;



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
    public override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155PackedBalance#safeTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155PackedBalance#safeTransferFrom: INVALID_RECIPIENT");

    _safeTransferFrom(_from, _to, _id, _amount);
    _callonERC1155Received(_from, _to, _id, _amount, gasleft(), _data);
  }

  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    public override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155PackedBalance#safeBatchTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155PackedBalance#safeBatchTransferFrom: INVALID_RECIPIENT");

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);
    _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasleft(), _data);
  }



  function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
    internal
  {

    _updateIDBalance(_from, _id, _amount, Operations.Sub); // Subtract amount from sender
    _updateIDBalance(_to,   _id, _amount, Operations.Add); // Add amount to recipient

    emit TransferSingle(msg.sender, _from, _to, _id, _amount);
  }

  function _callonERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, uint256 _gasLimit, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received{gas:_gasLimit}(msg.sender, _from, _id, _amount, _data);
      require(retval == ERC1155_RECEIVED_VALUE, "ERC1155PackedBalance#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts)
    internal
  {

    uint256 nTransfer = _ids.length; // Number of transfer to execute
    require(nTransfer == _amounts.length, "ERC1155PackedBalance#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH");

    if (_from != _to && nTransfer > 0) {
      (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);

      uint256 balFrom = _viewUpdateBinValue(balances[_from][bin], index, _amounts[0], Operations.Sub);
      uint256 balTo = _viewUpdateBinValue(balances[_to][bin], index, _amounts[0], Operations.Add);

      uint256 lastBin = bin;

      for (uint256 i = 1; i < nTransfer; i++) {
        (bin, index) = getIDBinIndex(_ids[i]);

        if (bin != lastBin) {
          balances[_from][lastBin] = balFrom;
          balances[_to][lastBin] = balTo;

          balFrom = balances[_from][bin];
          balTo = balances[_to][bin];

          lastBin = bin;
        }

        balFrom = _viewUpdateBinValue(balFrom, index, _amounts[i], Operations.Sub);
        balTo = _viewUpdateBinValue(balTo, index, _amounts[i], Operations.Add);
      }

      balances[_from][bin] = balFrom;
      balances[_to][bin] = balTo;

    } else {
      for (uint256 i = 0; i < nTransfer; i++) {
        require(balanceOf(_from, _ids[i]) >= _amounts[i], "ERC1155PackedBalance#_safeBatchTransferFrom: UNDERFLOW");
      }
    }

    emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
  }

  function _callonERC1155BatchReceived(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, uint256 _gasLimit, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived{gas: _gasLimit}(msg.sender, _from, _ids, _amounts, _data);
      require(retval == ERC1155_BATCH_RECEIVED_VALUE, "ERC1155PackedBalance#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE");
    }
  }



  function setApprovalForAll(address _operator, bool _approved)
    external override
  {

    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function isApprovedForAll(address _owner, address _operator)
    public override view returns (bool isOperator)
  {

    return operators[_owner][_operator];
  }



  function balanceOf(address _owner, uint256 _id)
    public override view returns (uint256)
  {

    uint256 bin;
    uint256 index;

    (bin, index) = getIDBinIndex(_id);
    return getValueInBin(balances[_owner][bin], index);
  }

  function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
    public override view returns (uint256[] memory)
  {

    uint256 n_owners = _owners.length;
    require(n_owners == _ids.length, "ERC1155PackedBalance#balanceOfBatch: INVALID_ARRAY_LENGTH");

    (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);
    uint256 balance_bin = balances[_owners[0]][bin];
    uint256 last_bin = bin;

    uint256[] memory batchBalances = new uint256[](n_owners);
    batchBalances[0] = getValueInBin(balance_bin, index);

    for (uint256 i = 1; i < n_owners; i++) {
      (bin, index) = getIDBinIndex(_ids[i]);

      if (bin != last_bin || _owners[i-1] != _owners[i]) {
        balance_bin = balances[_owners[i]][bin];
        last_bin = bin;
      }

      batchBalances[i] = getValueInBin(balance_bin, index);
    }

    return batchBalances;
  }



  function _updateIDBalance(address _address, uint256 _id, uint256 _amount, Operations _operation)
    internal
  {

    uint256 bin;
    uint256 index;

    (bin, index) = getIDBinIndex(_id);

    balances[_address][bin] = _viewUpdateBinValue(balances[_address][bin], index, _amount, _operation);
  }

  function _viewUpdateBinValue(uint256 _binValues, uint256 _index, uint256 _amount, Operations _operation)
    internal pure returns (uint256 newBinValues)
  {

    uint256 shift = IDS_BITS_SIZE * _index;
    uint256 mask = (uint256(1) << IDS_BITS_SIZE) - 1;

    if (_operation == Operations.Add) {
      newBinValues = _binValues + (_amount << shift);
      require(newBinValues >= _binValues, "ERC1155PackedBalance#_viewUpdateBinValue: OVERFLOW");
      require(
        ((_binValues >> shift) & mask) + _amount < 2**IDS_BITS_SIZE, // Checks that no other id changed
        "ERC1155PackedBalance#_viewUpdateBinValue: OVERFLOW"
      );

    } else if (_operation == Operations.Sub) {
      newBinValues = _binValues - (_amount << shift);
      require(newBinValues <= _binValues, "ERC1155PackedBalance#_viewUpdateBinValue: UNDERFLOW");
      require(
        ((_binValues >> shift) & mask) >= _amount, // Checks that no other id changed
        "ERC1155PackedBalance#_viewUpdateBinValue: UNDERFLOW"
      );

    } else {
      revert("ERC1155PackedBalance#_viewUpdateBinValue: INVALID_BIN_WRITE_OPERATION"); // Bad operation
    }

    return newBinValues;
  }

  function getIDBinIndex(uint256 _id)
    public pure returns (uint256 bin, uint256 index)
  {

    bin = _id / IDS_PER_UINT256;
    index = _id % IDS_PER_UINT256;
    return (bin, index);
  }

  function getValueInBin(uint256 _binValues, uint256 _index)
    public pure returns (uint256)
  {


    uint256 mask = (uint256(1) << IDS_BITS_SIZE) - 1;

    uint256 rightShift = IDS_BITS_SIZE * _index;
    return (_binValues >> rightShift) & mask;
  }

    function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data)
    internal
    {

        _updateIDBalance(_to,   _id, _amount, Operations.Add); // Add amount to recipient

        emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

        _callonERC1155Received(address(0x0), _to, _id, _amount, gasleft(), _data);
    }

    function _batchMint(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    internal
    {

        require(_ids.length == _amounts.length, "ERC1155MintBurnPackedBalance#_batchMint: INVALID_ARRAYS_LENGTH");

        if (_ids.length > 0) {
        (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);

        uint256 balTo = _viewUpdateBinValue(balances[_to][bin], index, _amounts[0], Operations.Add);

        uint256 nTransfer = _ids.length;

        uint256 lastBin = bin;

        for (uint256 i = 1; i < nTransfer; i++) {
            (bin, index) = getIDBinIndex(_ids[i]);

            if (bin != lastBin) {
            balances[_to][lastBin] = balTo;
            balTo = balances[_to][bin];

            lastBin = bin;
            }

            balTo = _viewUpdateBinValue(balTo, index, _amounts[i], Operations.Add);
        }

        balances[_to][bin] = balTo;
        }

        emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

        _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, gasleft(), _data);
    }

    function _burn(address _from, uint256 _id, uint256 _amount)
      internal
    {

      _updateIDBalance(_from, _id, _amount, Operations.Sub);

      emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
    }

    function _batchBurn(address _from, uint256[] memory _ids, uint256[] memory _amounts)
      internal
    {

      uint256 nBurn = _ids.length;
      require(nBurn == _amounts.length, "ERC1155MintBurnPackedBalance#batchBurn: INVALID_ARRAYS_LENGTH");

      for (uint256 i = 0; i < nBurn; i++) {
        _updateIDBalance(_from,   _ids[i], _amounts[i], Operations.Sub); // Add amount to recipient
      }

      emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
    }

    function supportsInterface(bytes4 _interfaceID) public override(ERC165, IERC165) virtual pure returns (bool) {

      if (_interfaceID == type(IERC1155).interfaceId) {
        return true;
      }
      return super.supportsInterface(_interfaceID);
    }
}// MIT
pragma solidity ^0.8.7;


contract VINYL is ERC1155PackedBalance, Ownable {

    using Address for address;
    using Strings for uint256;

    string private baseURI;
    bytes32 public merkleRoot = 0xdb9f7b75bd7be5081adf28065e8d2dd1322f281c829a80c122d483779b958616;

    mapping (uint256 => uint256) _redeemed;

    bool public isActive = false;
    
    enum VINYLTYPE {
        MINT,
        GOLD,
        ONYX
    }
    string public name = "SoundMint Vinyl";

    function mint(address to, uint mint_type) internal 
    {

        if (mint_type == 1)
	{
		_mint(to, uint(VINYLTYPE.MINT), 1, "");
        } 
        else if (mint_type == 2)
        {
        	_mint(to, uint(VINYLTYPE.MINT), 2, "");
        } 
        else
	{
            uint256[] memory Collect = new uint256[](2);
            uint256[] memory Count = new uint256[](2);
            if (mint_type == 5)
            {
                Collect[0] = uint(VINYLTYPE.GOLD);
                Collect[1] = uint(VINYLTYPE.ONYX);
                Count[0] = 10;
                Count[1] = 10;
            }
            else
	    {
                Collect[0] = uint(VINYLTYPE.MINT);
                Collect[1] = uint(VINYLTYPE.GOLD);
                if (mint_type == 3)
                {
                    Count[0] = 2;
                    Count[1] = 1;
                }
                else if(mint_type == 4)
                {
                    Count[0] = 4;
                    Count[1] = 2;
                }
            }
            _batchMint(to, Collect, Count, "");
        }
    }
    
    

    function burn(uint _id, uint amount) external 
    {

        require(isActive, "Contract is not active");
       _burn(msg.sender, _id, amount);
    }

    function toggleActive() external onlyOwner 
    {

        isActive = !isActive;
    }

    function setURI(string memory _URI) external onlyOwner 
    {

        require(keccak256(abi.encodePacked(baseURI)) != keccak256(abi.encodePacked(_URI)), "baseURI is already the value being set.");
        baseURI = _URI;
    }


    function setMerkleRoot(bytes32 merkleRootHash) external onlyOwner 
    {

	    require(merkleRoot != merkleRootHash,"merkelRoot already being set.");
        merkleRoot = merkleRootHash;
    }

    function hasNotMinted(uint256 index) external view returns (bool)
    {

      uint256 redeemedBlock = _redeemed[index / 256];
      uint256 redeemedMask = (uint256(1) << uint256(index % 256));
      return ((redeemedBlock & redeemedMask) == 0);
    }

  
    function mintNFT(uint256 index, uint256 mint_type, bytes32[] memory _proof) external
    {

        require(isActive, "Contract is not active");
      
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, mint_type, index));
        require(verify(merkleRoot, _proof, leaf), "Not Allowlisted");
      
	uint256 redeemedBlock = _redeemed[index / 256]; 
        uint256 redeemedMask = (uint256(1) << uint256(index % 256)); 
        require((redeemedBlock & redeemedMask) == 0, "Drop already claimed");
        _redeemed[index / 256] = redeemedBlock | redeemedMask;
	
        mint(msg.sender, mint_type);
        
    }


    function uri(uint256 _tokenId) external view returns (string memory) {

        return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    }

    function verify(
        bytes32 root,
        bytes32[] memory proof,
        bytes32 leaf
    ) public pure returns (bool) 
    {

        bytes32 hash = leaf;

        for (uint i = 0; i < proof.length; i++) 
	    {
            bytes32 proofElement = proof[i];

            if (hash <= proofElement) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }            
        }

        return hash == root;
    }
}