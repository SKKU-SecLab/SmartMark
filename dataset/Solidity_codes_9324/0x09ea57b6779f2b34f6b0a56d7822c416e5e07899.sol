pragma solidity 0.8.11;

abstract contract Controllable {
  mapping(address => bool) private _isController;

  modifier onlyController() {
    require(
      _isController[msg.sender],
      "Controllable: Caller is not a controller"
    );
    _;
  }

  function isController(address addr) public view returns (bool) {
    return _isController[addr];
  }

  function _setController(address addr, bool status) internal {
    _isController[addr] = status;
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// GPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;


abstract contract ERC1155 is IERC165, IERC1155, IERC1155MetadataURI {

  mapping(address => mapping(uint256 => uint256)) public balanceOf;

  mapping(address => mapping(address => bool)) public isApprovedForAll;

  mapping(uint256 => uint256) public totalSupply;


  function uri(uint256) public view virtual returns (string memory);

  function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
    public
    view
    virtual
    returns (uint256[] memory)
  {
    require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

    uint256[] memory batchBalances = new uint256[](accounts.length);
    for (uint256 i = 0; i < accounts.length; i++) batchBalances[i] = balanceOf[accounts[i]][ids[i]];

    return batchBalances;
  }

  function setApprovalForAll(address operator, bool approved) public virtual {
    _setApprovalForAll(msg.sender, operator, approved);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public virtual {
    require(from == msg.sender || isApprovedForAll[from][msg.sender], "ERC1155: caller is not owner nor approved");
    _safeTransferFrom(from, to, id, amount, data);
  }

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual {
    require(
      from == msg.sender || isApprovedForAll[from][msg.sender],
      "ERC1155: transfer caller is not owner nor approved"
    );
    _safeBatchTransferFrom(from, to, ids, amounts, data);
  }

  function exists(uint256 id) public view virtual returns (bool) {
    return totalSupply[id] > 0;
  }


  function _safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: transfer to the zero address");

    _trackSupplyBeforeTransfer(from, to, _asSingletonArray(id), _asSingletonArray(amount));

    _beforeTokenTransfer(msg.sender, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

    require(balanceOf[from][id] >= amount, "ERC1155: insufficient balance for transfer");
    unchecked {
      balanceOf[from][id] -= amount;
    }
    balanceOf[to][id] += amount;

    emit TransferSingle(msg.sender, from, to, id, amount);
    _checkOnERC1155Received(msg.sender, from, to, id, amount, data);
    _afterTokenTransfer(msg.sender, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);
  }

  function _safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
    require(to != address(0), "ERC1155: transfer to the zero address");

    _trackSupplyBeforeTransfer(from, to, ids, amounts);

    _beforeTokenTransfer(msg.sender, from, to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; ++i) {
      require(balanceOf[from][ids[i]] >= amounts[i], "ERC1155: insufficient balance for transfer");
      unchecked {
        balanceOf[from][ids[i]] -= amounts[i];
        balanceOf[to][ids[i]] += amounts[i];
      }
    }

    emit TransferBatch(msg.sender, from, to, ids, amounts);
    _checkOnERC1155BatchReceived(msg.sender, from, to, ids, amounts, data);
    _afterTokenTransfer(msg.sender, from, to, ids, amounts, data);
  }

  function _mint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: mint to the zero address");

    _trackSupplyBeforeTransfer(address(0), to, _asSingletonArray(id), _asSingletonArray(amount));

    _beforeTokenTransfer(msg.sender, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

    balanceOf[to][id] += amount;
    emit TransferSingle(msg.sender, address(0), to, id, amount);
    _checkOnERC1155Received(msg.sender, address(0), to, id, amount, data);
    _afterTokenTransfer(msg.sender, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);
  }

  function _mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {
    require(to != address(0), "ERC1155: mint to the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    _trackSupplyBeforeTransfer(address(0), to, ids, amounts);

    _beforeTokenTransfer(msg.sender, address(0), to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; i++) {
      balanceOf[to][ids[i]] += amounts[i];
    }

    emit TransferBatch(msg.sender, address(0), to, ids, amounts);
    _checkOnERC1155BatchReceived(msg.sender, address(0), to, ids, amounts, data);
    _afterTokenTransfer(msg.sender, address(0), to, ids, amounts, data);
  }

  function _burn(
    address from,
    uint256 id,
    uint256 amount
  ) internal virtual {
    _trackSupplyBeforeTransfer(from, address(0), _asSingletonArray(id), _asSingletonArray(amount));

    _beforeTokenTransfer(msg.sender, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

    require(balanceOf[from][id] >= amount, "ERC1155: burn amount exceeds balance");
    unchecked {
      balanceOf[from][id] -= amount;
    }

    emit TransferSingle(msg.sender, from, address(0), id, amount);
    _afterTokenTransfer(msg.sender, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");
  }

  function _burnBatch(
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal virtual {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    _trackSupplyBeforeTransfer(from, address(0), ids, amounts);

    _beforeTokenTransfer(msg.sender, from, address(0), ids, amounts, "");

    for (uint256 i = 0; i < ids.length; i++) {
      require(balanceOf[from][ids[i]] >= amounts[i], "ERC1155: burn amount exceeds balance");
      unchecked {
        balanceOf[from][ids[i]] -= amounts[i];
      }
    }

    emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    _afterTokenTransfer(msg.sender, from, address(0), ids, amounts, "");
  }

  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(owner != operator, "ERC1155: setting approval status for self");
    isApprovedForAll[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {}

  function _afterTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {}

  function _trackSupplyBeforeTransfer(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts
  ) private {
    if (from == address(0)) {
      for (uint256 i = 0; i < ids.length; i++) {
        totalSupply[ids[i]] += amounts[i];
      }
    }

    if (to == address(0)) {
      for (uint256 i = 0; i < ids.length; i++) {
        totalSupply[ids[i]] -= amounts[i];
      }
    }
  }

  function _checkOnERC1155Received(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) private {
    if (to.code.length > 0) {
      try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 returnValue) {
        require(returnValue == 0xf23a6e61, "ERC1155: transfer to non ERC1155Receiver implementer");
      } catch {
        revert("ERC1155: transfer to non ERC1155Receiver implementer");
      }
    }
  }

  function _checkOnERC1155BatchReceived(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) private {
    if (to.code.length > 0) {
      try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 returnValue) {
        require(returnValue == 0xbc197c81, "ERC1155: transfer to non ERC1155Receiver implementer");
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


  function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
    return
      interfaceId == type(IERC1155).interfaceId || // ERC1155
      interfaceId == type(IERC1155MetadataURI).interfaceId || // ERC1155MetadataURI
      interfaceId == type(IERC165).interfaceId; // ERC165
  }
}

interface IERC1155Receiver {

  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external returns (bytes4);


  function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external returns (bytes4);

}// MIT

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
pragma solidity 0.8.11;


contract ApeRunnersSerum is Ownable, Pausable, Controllable, ERC1155 {

  using Strings for uint256;


  IRUN public utilityToken;


  string public baseURI;

  string public baseExtension;

  constructor(
    string memory newBaseURI,
    string memory newBaseExtension,
    address newUtilityToken
  ) {
    baseURI = newBaseURI;
    baseExtension = newBaseExtension;
    utilityToken = IRUN(newUtilityToken);
  }


  function buy(uint256 serum, uint256 amount) external {

    require(
      serum == 1 || serum == 2 || serum == 3,
      "Query for nonexisting serum"
    );

    require(
      totalSupply[serum] + amount <= maxSuppply(serum),
      "Serum max supply exceeded"
    );

    require(amount > 0, "Invalid buy amount");

    utilityToken.burn(msg.sender, price(serum) * amount);
    _mint(msg.sender, serum, amount, "");
  }

  function price(uint256 serum) public pure returns (uint256) {

    if (serum == 1) return 300 ether;
    else if (serum == 2) return 1500 ether;
    else if (serum == 3) return 15000 ether;
    else revert("Query for nonexisting serum");
  }

  function maxSuppply(uint256 serum) public pure returns (uint256) {

    if (serum == 1) return 4500;
    else if (serum == 2) return 490;
    else if (serum == 3) return 10;
    else revert("Query for nonexisting serum");
  }


  function setBaseURI(string memory newBaseURI) external onlyOwner {

    baseURI = newBaseURI;
  }

  function setBaseExtension(string memory newBaseExtension) external onlyOwner {

    baseExtension = newBaseExtension;
  }

  function setUtilityToken(address newUtilityToken) external onlyOwner {

    utilityToken = IRUN(newUtilityToken);
  }

  function togglePaused() external onlyOwner {

    if (paused()) _unpause();
    else _pause();
  }


  function mint(
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts
  ) external onlyController {

    _mintBatch(to, ids, amounts, "");
  }

  function burn(
    address from,
    uint256[] calldata ids,
    uint256[] calldata amounts
  ) external onlyController {

    _burnBatch(from, ids, amounts);
  }

  function uri(uint256 id) public view override returns (string memory) {

    require(super.exists(id), "Query for nonexisting serum");
    return string(abi.encodePacked(baseURI, id.toString(), baseExtension));
  }

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal override {

    require(!super.paused() || msg.sender == super.owner(), "Pausable: paused");
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
  }
}

interface IRUN {

  function mint(address to, uint256 amount) external;


  function burn(address from, uint256 amount) external;

}