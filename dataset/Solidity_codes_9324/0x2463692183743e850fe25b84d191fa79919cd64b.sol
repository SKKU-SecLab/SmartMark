pragma solidity >=0.8.0;

contract IyusdiBondingCurves {


  struct BondingCurve {
    uint256 A;
    uint256 B;
    uint256 C;
    int256 D;
    uint256 ConstExp;
    uint256 MaxPrints;
  }

  uint256 constant SIG_DIGITS = 3;
  uint256 constant public ENIGMA_A = 12;
  uint256 constant public ENIGMA_B = 140;
  uint256 constant public ENIGMA_C = 100;
  uint256 constant public ENIGMA_D = 0;
  uint256 constant public ENIGMA_CONST_EXP = 100;
  uint256 constant public ENIGMA_MAX_PRINTS = 160;

  function _getPrintPrice(uint256 printNumber, BondingCurve storage curve) internal view returns (uint256 price) {

    uint256 decimals = 10 ** SIG_DIGITS;
    if (printNumber <= curve.ConstExp) {
      price = 0;
    } else if (printNumber < curve.B) {
      price = (10 ** ( curve.B - printNumber )) * decimals / (curve.A ** ( curve.B - printNumber));
    } else if (printNumber == curve.B) {
      price = decimals;
    } else {
      price = (curve.A ** ( printNumber - curve.B )) * decimals / (10 ** ( printNumber - curve.B ));
    }
    price = price + (curve.C * printNumber);
    int256 adjusted = int256(price) + curve.D;
    require(adjusted >= 0, '!price');
    price = uint256(adjusted);
    price = price * 1 ether / decimals;
  }

  function _getPrintPriceFromMem(uint256 printNumber, BondingCurve memory curve) internal pure returns (uint256 price) {

    uint256 decimals = 10 ** SIG_DIGITS;
    if (printNumber <= curve.ConstExp) {
      price = 0;
    } else if (printNumber < curve.B) {
      price = (10 ** ( curve.B - printNumber )) * decimals / (curve.A ** ( curve.B - printNumber));
    } else if (printNumber == curve.B) {
      price = decimals;
    } else {
      price = (curve.A ** ( printNumber - curve.B )) * decimals / (10 ** ( printNumber - curve.B ));
    }
    price = price + (curve.C * printNumber);
    int256 adjusted = int256(price) + curve.D;
    price = uint256(adjusted);
    price = price * 1 ether / decimals;
  }

  uint256 constant MAX_ITER = 50;
  function _validateBondingCurve(BondingCurve memory curve) internal pure returns(bool) {

    require(curve.A > 0, '!A');
    require(curve.B >= 0, '!B');
    require(curve.C > 0, '!C');
    require(curve.ConstExp < curve.B, '!ConstExp');
    require(curve.MaxPrints > curve.B, '!MaxPrints');
    uint256 prev = 0;
    uint256 iter = curve.MaxPrints / MAX_ITER;
    if (iter == 0) iter = 1; 
    for (uint256 i = 0; i < curve.MaxPrints; i += iter) {
      uint256 current = _getPrintPriceFromMem(i + 1, curve);
      require(current > 0 && current >= prev, '!curve');
      prev = current;
    }
    return true;
  }

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// Apache-2.0
pragma solidity >=0.6.12;


library Console {
  bool constant PROD = false;

  function concat(string memory a, string memory b) internal pure returns(string memory)
  {
    return string(abi.encodePacked(a, b));
  }

  function concat(string memory a, string memory b, string memory c) internal pure returns(string memory)
  {
    return string(abi.encodePacked(a, b, c));
  }

  event LogBalance(string, uint);
  function logBalance(address token, address to) internal {
    if (PROD) return;
    emit LogBalance(ERC20(token).symbol(), ERC20(token).balanceOf(to));
  }

  function logBalance(string memory s, address token, address to) internal {
    if (PROD) return;
    emit LogBalance(string(abi.encodePacked(s, '/', ERC20(token).symbol())), ERC20(token).balanceOf(to));
  }

  event LogUint(string, uint);
  function log(string memory s, uint x) internal {
    if (PROD) return;
    emit LogUint(s, x);
  }

  function log(string memory s, string memory t, uint x) internal {
    if (PROD) return;
    emit LogUint(concat(s, t), x);
  }
    
  function log(string memory s, string memory t, string memory u, uint x) internal {
    if (PROD) return;
    emit LogUint(concat(s, t, u), x);
  }
    
  event LogInt(string, int);
  function log(string memory s, int x) internal {
    if (PROD) return;
    emit LogInt(s, x);
  }
  
  event LogBytes(string, bytes);
  function log(string memory s, bytes memory x) internal {
    if (PROD) return;
    emit LogBytes(s, x);
  }
  
  event LogBytes32(string, bytes32);
  function log(string memory s, bytes32 x) internal {
    if (PROD) return;
    emit LogBytes32(s, x);
  }

  event LogAddress(string, address);
  function log(string memory s, address x) internal {
    if (PROD) return;
    emit LogAddress(s, x);
  }

  event LogBool(string, bool);
  function log(string memory s, bool x) internal {
    if (PROD) return;
    emit LogBool(s, x);
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}// MIT

pragma solidity ^0.8.0;

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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor (string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155).interfaceId
            || interfaceId == type(IERC1155MetadataURI).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
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

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;

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

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            _balances[id][from] = fromBalance - amount;
            _balances[id][to] += amount;
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

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        _balances[id][account] = accountBalance - amount;

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            _balances[id][account] = accountBalance - amount;
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
        internal
        virtual
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
}// BUSL-1.1

pragma solidity >=0.8.0;

contract IyusdiNftV2Base {

  event FeedItem(
    uint256 indexed id,
    uint256 indexed hash,
    uint256 timestamp,
    bytes data
  );

  event CuratorMinted(
    address owner,
    uint256 id
  );

  event OriginalMinted(
    address indexed owner,
    uint256 indexed id
  );

  event PrintMinted(
    address indexed owner,
    uint256 indexed og,
    uint256 indexed id
  );

  event PrintBurned(
    address from,
    uint256 id
  );

  struct Original {
    uint64 mintedPrints;
    uint64 printIndex;
  }

  uint256 public constant OG_MASK     = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  uint256 public constant OG_INV_MASK = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 public constant CURATOR_ID  = 0x8000000000000000000000000000000000000000000000000000000000000000;

  address public curator;
  Original[] public originals;
  mapping (address => bool) public operators;
  mapping (uint256 => bool) public canTransfer;
  mapping (uint256 => address) public originalOwner;

  modifier onlyCurator() {
    require(msg.sender == curator, "!curator");
    _;
  }

  function _getOgOwner(uint256 id) internal view returns (address) {
    return id == CURATOR_ID ? curator : originalOwner[_getOgId(id)];
  }

  function originalIndex(uint256 id) external pure returns(uint256) {
    uint256 og = _getOgId(id);
    return (og >> 128) - 1;
  }

  function originalMintedPrints(uint256 id) external view returns(uint256) {
    uint256 og = _getOgId(id);
    uint256 idx = (og >> 128) - 1;
    return originals[idx].mintedPrints;
  }

  function post(uint256 id, uint256 hash, bytes memory data) external {
    require(_isOperator(), '!operator');
    uint256 og = _getOgId(id);
    address owner = _getOgOwner(og);
    require(owner != address(0), '!owner');
    emit FeedItem(id, hash, block.timestamp, data);
  }

  function getOgId(uint256 id) external pure returns (uint256) {
    return _getOgId(id);
  }

  function _getOgId(uint256 id) internal pure returns (uint256) {
    return id & OG_INV_MASK;
  }

  function isOgId(uint256 id) external pure returns (bool) {
    return _isOgId(id);
  }

  function _isOgId(uint256 id) internal pure returns (bool) {
    return (id & OG_MASK) == 0;
  }

  function isPrintId(uint256 id) external pure returns (bool) {
    return _isPrintId(id);
  }

  function _isPrintId(uint256 id) internal pure returns (bool) {
    return (id & OG_MASK) > 0;
  }

  function _isCurator() internal view returns(bool) {
    return msg.sender == curator;
  }

  function _isOperator() internal view returns(bool) {
    return operators[msg.sender];
  }

  function _mintOriginal(address owner, bytes memory data) internal returns(uint256 id) {
    require(_isOperator() && owner != address(0), '!parm');
    originals.push(Original(0, 0));
    id = originals.length << 128;
    originalOwner[id] = owner;
    emit OriginalMinted(owner, id);
    emit FeedItem(id, 0, block.timestamp, data);
  }

  function _mintPrint(uint256 og, address to, bytes memory data) internal returns(uint256 id) {
    require(_isOperator() && _isOgId(og), '!ogId');
    uint256 idx = (og >> 128) - 1;
    Original storage original = originals[idx];
    original.mintedPrints++;
    original.printIndex++;
    id = og | original.printIndex;
    emit PrintMinted(to, og, id);
    emit FeedItem(id, 0, block.timestamp, data);
  }

  function _burnPrint(address from, uint256 id) internal {
    require(_isOperator() && _isPrintId(id), '!printId');
    uint256 og = _getOgId(id);
    uint256 idx = (og >> 128) - 1;
    Original storage original = originals[idx];
    original.mintedPrints = original.mintedPrints - 1;
    emit PrintBurned(from, id);
  }

  function _canTransfer(uint256 id, address _operator) internal view returns(bool) {
    if (_isOgId(id) || operators[_operator]) {
      return true;
    } else {
      uint256 og = _getOgId(id);
      return canTransfer[og];
    }
  }

  function allowTransfers(uint256 id, bool can) external {
    require(_isOperator(), '!operator');
    uint256 og = _getOgId(id);
    canTransfer[og] = can;
  }

}// BUSL-1.1

pragma solidity >=0.8.0;


contract IyusdiNftV2 is IyusdiNftV2Base, ERC1155 {

  constructor (address _operator, address _curator, string memory _uri) ERC1155(_uri) {
    require(_curator != address(0) && _operator != address(0), '!param');
    curator = _curator;
    operators[_operator] = true;
    setApprovalForAll(_operator, true);
    _mint(_curator, CURATOR_ID, 1, "");
    emit CuratorMinted(_curator, CURATOR_ID);
  }

  function setOperator(address operator, bool set) onlyCurator external {
    require(operator != address(0), '!operator');
    operators[operator] = set;
    setApprovalForAll(operator, set);
  }

  function owns(uint256 id, address owner) external view returns(bool) {
    return balanceOf(owner, id) > 0;
  }

  function mintOriginal(address owner, bytes memory data) external returns(uint256 id) {
    id = _mintOriginal(owner, data);
    _mint(owner, id, 1, "");
  }

  function mintPrint(uint256 og, address to, bytes memory data) external returns(uint256 id) {
    id = _mintPrint(og, to, data);
    _mint(to, id, 1, "");
  }

  function burnPrint(address from, uint256 id) external {
    _burnPrint(from, id);
    _burn(from, id, 1);
  }

  function _beforeTokenTransfer(
    address _operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual override {
    super._beforeTokenTransfer(_operator, from, to, ids, amounts, data);

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 id = ids[i];
      require(_canTransfer(id, _operator), '!transfer');
      if (id == CURATOR_ID) {
        curator = to;
      } else if (_isOgId(id)) {
        originalOwner[id] = to;   
      }
    }
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return ERC1155.supportsInterface(interfaceId);
  }

}// BUSL-1.1

pragma solidity >=0.8.0;


contract IyusdiCollectionsBase is IyusdiBondingCurves {

  struct RequestMintOriginal {
    uint256 mintPercent;
    uint256 burnPercent;
    BondingCurve curve;
    bytes data;
  }

  event OriginalMinted (
    uint256 indexed og,
    uint32 mintPercent,
    uint32 burnPercent,
    uint32 A,
    uint32 B,
    uint32 C,
    int32 D,
    uint32 ConstExp,
    uint32 MaxPrints
  );

  event PrintBurned(
    uint256 indexed id,
    uint256 price,
    uint256 protocolFee,
    uint256 curatorFee,
    uint256 ogFee,
    uint256 printNumber
  );

  event PrintMinted(
    uint256 indexed id,
    uint256 price,
    uint256 protocolFee,
    uint256 curatorFee,
    uint256 ogFee,
    uint256 printNumber
  );

  address public nft;
  address public owner;
  address public protocol;
  
  uint256 public curatorMintPercent;
  uint256 public curatorBurnPercent;
  uint256 public protocolMintPercent;
  uint256 public protocolBurnPercent;
  mapping (uint256 => uint256) public ogMintPercent;
  mapping (uint256 => uint256) public ogBurnPercent;
  mapping (uint256 => BondingCurve) public bondingCurves;
  mapping (address => bool) public approveMintOriginals;
  mapping (address => RequestMintOriginal) public requestMintOriginals;
  
  uint256 constant PERCENT_BASE = 10000;

  modifier onlyOwner() {
    require(owner != address(0) && (msg.sender == owner || msg.sender == _getCurator()), "!owner");
    _;
  }

  modifier onlyCurator() {
    require(msg.sender == _getCurator(), "!curator");
    _;
  }

  modifier onlyProtocol() {
    require(msg.sender == protocol, "!protocol");
    _;
  }

  function setNft(address _nft) onlyOwner external {
    require(_nft != address(0), '!nft');
    nft = _nft;
  }

  function transferProtocol(address _protocol) onlyProtocol external {
    require(_protocol != address(0), '!protocol');
    protocol = _protocol;
  }

  function transferOwner(address _owner) onlyOwner external {
    owner = _owner;
  }

  function removeRequestMintOriginal() external {
    _removeRequestMintOriginal();
  }

  function _removeRequestMintOriginal() internal {
    delete requestMintOriginals[msg.sender];
    approveMintOriginals[msg.sender] = false;
  }

  function requestMintOriginal(uint256 mintPercent, uint256 burnPercent, BondingCurve memory curve, bytes memory data) external {
    require(protocolMintPercent + curatorMintPercent + mintPercent <= PERCENT_BASE, '!mintPercent');
    require(protocolBurnPercent + curatorBurnPercent + burnPercent <= PERCENT_BASE, '!burnPercent');
    _validateBondingCurve(curve);
    requestMintOriginals[msg.sender].mintPercent = mintPercent;
    requestMintOriginals[msg.sender].burnPercent = burnPercent;
    requestMintOriginals[msg.sender].curve = curve;
    requestMintOriginals[msg.sender].data = data;
    approveMintOriginals[msg.sender] = false;
  }

  function _getCurator() internal view returns(address) {
    return IyusdiNftV2(nft).curator();
  }

  function _getOgOwner(uint256 og) internal view returns(address) {
    return IyusdiNftV2(nft).originalOwner(og);
  }

  function approveMintOriginal(address user, bool approve) external onlyCurator {
    approveMintOriginals[user] = approve;
  }

  function mintApprovedOriginal() external returns(uint256 id) {
    require(approveMintOriginals[msg.sender], '!approved');
    uint256 mintPercent = requestMintOriginals[msg.sender].mintPercent;
    uint256 burnPercent = requestMintOriginals[msg.sender].burnPercent;
    BondingCurve memory curve = requestMintOriginals[msg.sender].curve;
    bytes memory data = requestMintOriginals[msg.sender].data;

    id = IyusdiNftV2(nft).mintOriginal(msg.sender, data);
    ogMintPercent[id] = mintPercent;
    ogBurnPercent[id] = burnPercent;
    bondingCurves[id] = curve;
    emit OriginalMinted(id, uint32(mintPercent), uint32(burnPercent), uint32(curve.A), uint32(curve.B), uint32(curve.C), int32(curve.D), uint32(curve.ConstExp), uint32(curve.MaxPrints));
    _removeRequestMintOriginal();
  }

  function mintPrint(uint256 og, bytes memory data) payable external returns(uint256 id) {
    id = _mintPrintFor(og, msg.sender, data);
  }

  function mintPrintFor(uint256 og, address to, bytes memory data) payable external returns(uint256 id) {
    require(to != address(0), '!for');
    id = _mintPrintFor(og, to, data);
  }

  function _getPrintNumber(uint256 og) internal view returns (uint256) {
    return IyusdiNftV2(nft).originalMintedPrints(og);
  }

  function _getOgId(uint256 og) internal view returns (uint256) {
    return IyusdiNftV2(nft).getOgId(og);
  }

  function getPrintPrice(uint256 og, uint256 printNumber) external view returns(uint256) {
    address ogOwner = _getOgOwner(og);
    require(ogOwner != address(0), '!og');
    BondingCurve storage curve = bondingCurves[og];
    return _getPrintPrice(printNumber, curve);
  }

  function getBurnPrice(uint256 og, uint256 printNumber) external view returns(uint256) {
    address ogOwner = _getOgOwner(og);
    require(ogOwner != address(0), '!og');
    BondingCurve storage curve = bondingCurves[og];
    return _getBurnPrice(og, printNumber, curve);
  }

  function _getBurnPrice(uint256 og, uint256 printNumber, BondingCurve storage curve) internal view returns(uint256) {
    uint256 printPrice = _getPrintPrice(printNumber, curve);
    uint256 protocolFee = printPrice * protocolMintPercent / PERCENT_BASE;
    uint256 curatorFee = printPrice * curatorMintPercent / PERCENT_BASE;
    uint256 ownerFee = printPrice * ogMintPercent[og] / PERCENT_BASE;
    return printPrice - protocolFee - curatorFee - ownerFee;
  }

  function getPrintNumber(uint256 og) external view returns(uint256 printNumber) {
    address ogOwner = _getOgOwner(og);
    require(ogOwner != address(0), '!og');
    printNumber = _getPrintNumber(og);
  }

  function _sendFee(address to, uint256 price, uint256 percent) internal returns(uint256 fee) {
    fee = price * percent / PERCENT_BASE;
    if (fee > 0) {
      (bool success, ) = to.call{value: fee}("");
      require(success, '!_sendFee');
    }
  }

  function _mintPrintFor(uint256 og, address to, bytes memory data) internal returns(uint256 id) {
    address ogOwner = _getOgOwner(og);
    require(ogOwner != address(0), '!og');
    uint256 printNumber = _getPrintNumber(og) + 1;
    BondingCurve storage curve = bondingCurves[og];
    require(printNumber <= curve.MaxPrints, '!maxPrints');
    uint256 printPrice = _getPrintPrice(printNumber, curve);
    require(msg.value >= printPrice, '!printPrice');
    uint256 protocolFee = _sendFee(protocol, printPrice, protocolMintPercent);
    uint256 curatorFee = _sendFee(_getCurator(), printPrice, curatorMintPercent);
    uint256 ownerFee = _sendFee(ogOwner, printPrice, ogMintPercent[og]);
    if (msg.value > printPrice) {
      uint256 refund =  msg.value - printPrice;
      (bool rsuccess, ) = msg.sender.call{value: refund}("");
      require(rsuccess, '!refund');
    }
    id = IyusdiNftV2(nft).mintPrint(og, to, data);
    emit PrintMinted(id, printPrice, protocolFee, curatorFee, ownerFee, printNumber);
  }

  function burnPrint(uint256 id, uint256 minPrintNumber) external {
    require(IyusdiNftV2(nft).isPrintId(id), '!printId');
    _burnPrint(id, minPrintNumber);
  }

  function _burnPrint(uint256 id, uint256 minPrintNumber) internal {
    uint256 og = _getOgId(id);
    address ogOwner = _getOgOwner(og);
    require(ogOwner != address(0), '!og');
    uint256 printNumber = _getPrintNumber(og);
    require(printNumber >= minPrintNumber, '!minPrintNumber');
    BondingCurve storage curve = bondingCurves[og];
    uint256 burnPrice = _getBurnPrice(og, printNumber, curve);
    uint256 protocolFee = _sendFee(protocol, burnPrice, protocolBurnPercent);
    uint256 curatorFee = _sendFee(_getCurator(), burnPrice, curatorBurnPercent);
    uint256 ogFee = _sendFee(ogOwner, burnPrice, ogBurnPercent[og]);
    uint256 refund = burnPrice - protocolFee - curatorFee - ogFee;
    if (refund > 0) {
      (bool success, ) = msg.sender.call{value: refund}("");
      require(success, '!refund');
    }
    IyusdiNftV2(nft).burnPrint(msg.sender, id);
    emit PrintBurned(id, burnPrice, protocolFee, curatorFee, ogFee, printNumber);
  }

  function post(uint256 og, uint256 hash, bytes memory data) external {
    address ogOwner = _getOgOwner(og);
    require(msg.sender == ogOwner, '!owner');
    IyusdiNftV2(nft).post(og, hash, data);
  }

  function allowTransfers(uint256 og, bool allow) external {
    address ogOwner = _getOgOwner(og);
    require(msg.sender == ogOwner, '!owner');
    IyusdiNftV2(nft).allowTransfers(og, allow);
  }

}// BUSL-1.1

pragma solidity >=0.8.0;


contract IyusdiCollections is IyusdiCollectionsBase {

  constructor (address _protocol, uint256 _protocolMintPercent, uint256 _protocolBurnPercent, uint256 _curatorMintPercent, uint256 _curatorBurnPercent) {
    require(_protocol != address(0), '!protocol');
    require(_protocolMintPercent + _curatorMintPercent <= IyusdiCollectionsBase.PERCENT_BASE, '!mintPercent');
    require(_protocolBurnPercent + _curatorBurnPercent <= IyusdiCollectionsBase.PERCENT_BASE, '!burnPercent');
    owner = msg.sender;
    protocol = _protocol;
    protocolMintPercent = _protocolMintPercent;
    protocolBurnPercent = _protocolBurnPercent;
    curatorMintPercent = _curatorMintPercent;
    curatorBurnPercent = _curatorBurnPercent;
  }

}