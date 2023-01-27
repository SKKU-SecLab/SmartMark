
pragma solidity ^0.8.0;

library ClonesUpgradeable {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

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


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

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


interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {

    using AddressUpgradeable for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    function __ERC1155_init(string memory uri_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {

        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
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

        _setApprovalForAll(_msgSender(), operator, approved);
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
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
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

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
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


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
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
    ) private {

        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
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
    uint256[47] private __gap;
}//MIT
pragma solidity ^0.8.0;

interface IFraktalNFT {

    function fraktionalize(address _to, uint _tokenId) external;

    function setMajority(uint16 newValue) external;

    function defraktionalize() external;

    function soldBurn(address owner, uint256 _tokenId, uint256 bal) external;

    function lockSharesTransfer(address from, uint numShares, address _to) external;

    function unlockSharesTransfer(address from, address _to) external;

    function createRevenuePayment() external returns (address _clone);

    function sellItem() external;

    function cleanUpHolders() external;

    function getRevenue(uint256 index) external view returns(address);

    function getFraktions(address who) external view returns(uint);

    function getLockedShares(uint256 index, address who) external view returns(uint);

    function getLockedToTotal(uint256 index, address who) external view returns(uint);

    function getStatus() external view returns (bool);

    function getFraktionsIndex() external view returns (uint256);

}//MIT
pragma solidity ^0.8.0;


contract PaymentSplitterUpgradeable is Initializable, ContextUpgradeable {

  event PayeeAdded(address account, uint256 shares);
  event PaymentReleased(address to, uint256 amount);
  event PaymentReceived(address from, uint256 amount);

  uint256 private _totalShares;
  uint256 private _totalReleased;

  mapping(address => uint256) private _shares;
  mapping(address => uint256) private _released;
  address[] private _payees;

  address tokenParent;
  uint256 fraktionsIndex;
  bool public buyout;
  address marketContract;

  function init(address[] memory payees, uint256[] memory shares_, address _marketContract)
    external
    initializer
  {

    __PaymentSplitter_init(payees, shares_);
    tokenParent = _msgSender();
    fraktionsIndex = FraktalNFT(_msgSender()).fraktionsIndex();
    buyout = FraktalNFT(_msgSender()).sold();
    marketContract = _marketContract;
  }

  function __PaymentSplitter_init(
    address[] memory payees,
    uint256[] memory shares_
  ) internal {

    __Context_init_unchained();
    __PaymentSplitter_init_unchained(payees, shares_);
  }

  function __PaymentSplitter_init_unchained(
    address[] memory payees,
    uint256[] memory shares_
  ) internal {

    require(
      payees.length == shares_.length,
      "PaymentSplitter: payees and shares length mismatch"
    );
    require(payees.length > 0, "PaymentSplitter: no payees");

    for (uint256 i = 0; i < payees.length; i++) {
      _addPayee(payees[i], shares_[i]);
    }
  }

  receive() external payable virtual {
    emit PaymentReceived(_msgSender(), msg.value);
  }

  function totalShares() external view returns (uint256) {

    return _totalShares;
  }

  function totalReleased() external view returns (uint256) {

    return _totalReleased;
  }

  function shares(address account) external view returns (uint256) {

    return _shares[account];
  }

  function released(address account) external view returns (uint256) {

    return _released[account];
  }

  function payee(uint256 index) external view returns (address) {

    return _payees[index];
  }

  function release() external virtual {

    address payable operator = payable(_msgSender());
    require(_shares[operator] > 0, "PaymentSplitter: account has no shares");
    if (buyout) {
      uint256 bal = FraktalNFT(tokenParent).balanceOf(_msgSender(),FraktalNFT(tokenParent).fraktionsIndex());
      IFraktalNFT(tokenParent).soldBurn(_msgSender(), fraktionsIndex, bal);
    }

    uint256 totalReceived = address(this).balance + _totalReleased;
    uint256 payment = (totalReceived * _shares[operator]) /
      _totalShares -
      _released[operator];

    require(payment != 0, "PaymentSplitter: operator is not due payment");

    _released[operator] = _released[operator] + payment;
    _totalReleased = _totalReleased + payment;

    address payable marketPayable = payable(marketContract);
    uint16 marketFee = FraktalMarket(marketPayable).fee();

    uint256 forMarket = (payment * marketFee )/ 10000;
    uint256 forOperator = payment - forMarket;

    AddressUpgradeable.sendValue(operator, forOperator);
    AddressUpgradeable.sendValue(marketPayable, forMarket);
    emit PaymentReleased(operator, payment);
  }

  function _addPayee(address account, uint256 shares_) private {

    require(
      account != address(0),
      "PaymentSplitter: account is the zero address"
    );
    require(shares_ > 0, "PaymentSplitter: shares are 0");
    require(
      _shares[account] == 0,
      "PaymentSplitter: account already has shares"
    );

    _payees.push(account);
    _shares[account] = shares_;
    _totalShares = _totalShares + shares_;
    emit PayeeAdded(account, shares_);
  }

  uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;


library EnumerableMap {

    using EnumerableSet for EnumerableSet.Bytes32Set;


    struct Map {
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    function _set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {

        map._values[key] = value;
        return map._keys.add(key);
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        delete map._values[key];
        return map._keys.remove(key);
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._keys.contains(key);
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._keys.length();
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    function _get(
        Map storage map,
        bytes32 key,
        string memory errorMessage
    ) private view returns (bytes32) {

        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal onlyInitializing {

        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {

    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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

}//MIT
pragma solidity ^0.8.0;


contract FraktalNFT is ERC1155Upgradeable,ERC721HolderUpgradeable,ERC1155HolderUpgradeable{

  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableMap for EnumerableMap.UintToAddressMap;
  address revenueChannelImplementation;
  bool fraktionalized;
  bool public sold;
  uint256 public fraktionsIndex;
  uint16 public majority;
  mapping(uint256 => bool) public indexUsed;
  mapping(uint256 => mapping(address => uint256)) public lockedShares;
  mapping(uint256 => mapping(address => uint256)) public lockedToTotal;
  EnumerableSet.AddressSet private holders;
  EnumerableMap.UintToAddressMap private revenues;
  string public name = "FraktalNFT";
  string public symbol = "FRAK";
  address public factory;
  address collateral;

  event LockedSharesForTransfer(
    address shareOwner,
    address to,
    uint256 numShares
  );
  event unLockedSharesForTransfer(
    address shareOwner,
    address to,
    uint256 numShares
  );
  event ItemSold(address buyer, uint256 indexUsed);
  event NewRevenueAdded(
    address payer,
    address revenueChannel,
    uint256 amount,
    bool sold
  );
  event Fraktionalized(address holder, address minter, uint256 index);
  event Defraktionalized(address holder, uint256 index);
  event MajorityValueChanged(uint16 newValue);


  function init(
    address _creator,
    address _revenueChannelImplementation,
    string calldata uri,
    uint16 _majority,
    string memory _name,
    string memory _symbol
  ) external initializer {

    __ERC1155_init(uri);
    _mint(_creator, 0, 1, "");
    fraktionalized = false;
    sold = false;
    majority = _majority;
    revenueChannelImplementation = _revenueChannelImplementation;
    holders.add(_creator);
    if(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked("")) && 
    keccak256(abi.encodePacked(_symbol)) != keccak256(abi.encodePacked(""))
    ){
      name = _name;
      symbol = _symbol;
    }
    factory = msg.sender;//factory as msg.sender
  }

  function fraktionalize(address _to, uint256 _tokenId) external {

    require((_tokenId != 0) && 
    (this.balanceOf(_msgSender(), 0) == 1) && 
    !fraktionalized && 
    (indexUsed[_tokenId] == false)
    );
    fraktionalized = true;
    sold = false;
    fraktionsIndex = _tokenId;
    _mint(_to, _tokenId, 10000*10**18, "");
    emit Fraktionalized(_msgSender(), _to, _tokenId);
  }

  function defraktionalize() external {

    fraktionalized = false;
    _burn(_msgSender(), fraktionsIndex, 10000*10**18);
    emit Defraktionalized(_msgSender(), fraktionsIndex);
  }

  function setMajority(uint16 newValue) external {

    require((this.balanceOf(_msgSender(), 0) == 1)&&
    (newValue <= 10000*10**18)
    );
    majority = newValue;
    emit MajorityValueChanged(newValue);
  }

  function soldBurn(
    address owner,
    uint256 _tokenId,
    uint256 bal
  ) external {

    if (_msgSender() != owner) {
      require(isApprovedForAll(owner, _msgSender()));
    }
    _burn(owner, _tokenId, bal);
  }

  function lockSharesTransfer(
    address from,
    uint256 numShares,
    address _to
  ) external {

    if (from != _msgSender()) {
      require(isApprovedForAll(from, _msgSender()));
    }
    require(
      balanceOf(from, fraktionsIndex) - lockedShares[fraktionsIndex][from] >=
        numShares
    );
    lockedShares[fraktionsIndex][from] += numShares;
    lockedToTotal[fraktionsIndex][_to] += numShares;
    emit LockedSharesForTransfer(from, _to, numShares);
  }

  function unlockSharesTransfer(address from, address _to) external {

    require(!sold);
    if (from != _msgSender()) {
      require(isApprovedForAll(from, _msgSender()));
    }
    uint256 balance = lockedShares[fraktionsIndex][from];
    lockedShares[fraktionsIndex][from] -= balance;
    lockedToTotal[fraktionsIndex][_to] -= balance;
    emit unLockedSharesForTransfer(from, _to, 0);
  }

  function createRevenuePayment(address _marketAddress) external payable returns (address _clone) {

    cleanUpHolders();
    address[] memory owners = holders.values();
    uint256 listLength = holders.length();
    uint256[] memory fraktions = new uint256[](listLength);
    for (uint256 i = 0; i < listLength; i++) {
      fraktions[i] = this.balanceOf(owners[i], fraktionsIndex);
    }
    _clone = ClonesUpgradeable.clone(revenueChannelImplementation);
    address payable revenueContract = payable(_clone);
    PaymentSplitterUpgradeable(revenueContract).init(owners, fraktions, _marketAddress);
    uint256 bufferedValue = msg.value;
    AddressUpgradeable.sendValue(revenueContract, bufferedValue);
    uint256 index = revenues.length();
    revenues.set(index, _clone);
    emit NewRevenueAdded(_msgSender(), revenueContract, msg.value, sold);
  }

  function sellItem() external payable {

    require(this.balanceOf(_msgSender(), 0) == 1);
    sold = true;
    fraktionalized = false;
    indexUsed[fraktionsIndex] = true;
    emit ItemSold(_msgSender(), fraktionsIndex);
  }

  function cleanUpHolders() internal {

    uint16 cur = 0;
    while(cur < holders.length()){
      if (this.balanceOf(holders.at(cur), fraktionsIndex) < 1) {
        holders.remove(holders.at(cur));
        cur=0;
      }
      cur++;
    }
  }

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory tokenId,
    uint256[] memory amount,
    bytes memory data
  ) internal virtual override {

    super._beforeTokenTransfer(operator, from, to, tokenId, amount, data);
    if (from != address(0) && to != address(0)) {
      if (tokenId[0] == 0) {
        if (fraktionalized == true && sold == false) {
          require((lockedToTotal[fraktionsIndex][to] > 9999));
        }
      } else {
        require(sold != true);
        require(
          (balanceOf(from, tokenId[0]) - lockedShares[fraktionsIndex][from] >=
            amount[0])
        );
      }
      holders.add(to);
    }
  }




  function claimContainedERC721(address contractAddress, uint256 index) external{

    if(msg.sender != factory){
      require(contractAddress != collateral);
    }
    require((this.balanceOf(msg.sender, 0) == 1) && !fraktionalized && (IERC721(contractAddress).ownerOf(index) == address(this)));
    IERC721(contractAddress).safeTransferFrom(address(this), msg.sender, index);
  }

  function claimContainedERC1155(address contractAddress, uint256 index, uint256 amount) external{

    if(msg.sender != factory){
      require(contractAddress != collateral);
    }
    require((this.balanceOf(msg.sender, 0) == 1) && !fraktionalized);
    IERC1155(contractAddress).safeTransferFrom(address(this), msg.sender, index, amount,"");
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Upgradeable, ERC1155ReceiverUpgradeable) returns (bool) {

        return ERC1155Upgradeable.supportsInterface(interfaceId) || ERC1155ReceiverUpgradeable.supportsInterface(interfaceId);
  }

  function setCollateral(address _collateral ) external{

    require(msg.sender == factory);
    collateral = _collateral;
  }


}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}//MIT
pragma solidity ^0.8.0;


contract FraktalMarket is
Initializable,
OwnableUpgradeable,
ReentrancyGuardUpgradeable,
ERC1155Holder
{

  uint16 public fee;
  uint256 public listingFee;
  uint256 private feesAccrued;
  struct Proposal {
    uint256 value;
    bool winner;
  }
  struct Listing {
    address tokenAddress;
    uint256 price;
    uint256 numberOfShares;
    string name;
  }
  struct AuctionListing {
    address tokenAddress;
    uint256 reservePrice;
    uint256 numberOfShares;
    uint256 auctionEndTime;
    string name;
  }
  mapping(address => mapping(address => Listing)) listings;

  mapping(address => mapping(address => mapping(uint256 => AuctionListing))) public auctionListings;
  mapping(address => uint256) public auctionNonce;
  mapping(address => mapping(uint256 => uint256)) public auctionReserve;
  mapping(address => mapping(uint256 => bool)) public auctionSellerRedeemed;
  mapping(address => mapping(uint256 => mapping(address => uint256))) public participantContribution;

  mapping(address => mapping(address => Proposal)) public offers;
  mapping(address => uint256) public sellersBalance;
  mapping(address => uint256) public maxPriceRegistered;

  event Bought(
    address buyer,
    address seller,
    address tokenAddress,
    uint256 numberOfShares
  );
  event FeeUpdated(uint16 newFee);
  event ListingFeeUpdated(uint256 newFee);
  event ItemListed(
    address owner,
    address tokenAddress,
    uint256 price,
    uint256 amountOfShares,
    string name
  );
  event AuctionItemListed(
    address owner,
    address tokenAddress,
    uint256 reservePrice,
    uint256 amountOfShares,
    uint256 endTime,
    uint256 nonce,
    string name
  );
  event AuctionContribute(
    address participant,
    address tokenAddress,
    address seller,
    uint256 sellerNonce,
    uint256 value
  );
  event FraktalClaimed(address owner, address tokenAddress);
  event SellerPaymentPull(address seller, uint256 balance);
  event AdminWithdrawFees(uint256 feesAccrued);
  event OfferMade(address offerer, address tokenAddress, uint256 value);
  event OfferVoted(address voter, address offerer, address tokenAddress, bool sold);
  event Volume(address user, uint256 volume);

  function initialize() public initializer {

    __Ownable_init();
    fee = 500; //5%
  }

  function setFee(uint16 _newFee) external onlyOwner {

    require(_newFee >= 0);
    require(_newFee < 10000);
    fee = _newFee;
    emit FeeUpdated(_newFee);
  }

  function setListingFee(uint256 _newListingFee) external onlyOwner {

    require(_newListingFee >= 0);
    require(_newListingFee < 10000);
    listingFee = _newListingFee;
    emit ListingFeeUpdated(_newListingFee);
  }

  function withdrawAccruedFees()
    external
    onlyOwner
    nonReentrant
    returns (bool)
  {

    address payable wallet = payable(_msgSender());
    uint256 bufferedFees = feesAccrued;
    feesAccrued = 0;
    AddressUpgradeable.sendValue(wallet, bufferedFees);
    emit AdminWithdrawFees(bufferedFees);
    return true;
  }

  function rescueEth() external nonReentrant {

    require(sellersBalance[_msgSender()] > 0, "No claimed ETH");
    address payable seller = payable(_msgSender());
    uint256 balance = sellersBalance[_msgSender()];
    sellersBalance[_msgSender()] = 0;
    AddressUpgradeable.sendValue(seller, balance);
    emit SellerPaymentPull(_msgSender(), balance);
  }

  function redeemAuctionSeller(
    address _tokenAddress,
    address _seller,
    uint256 _sellerNonce
    ) external nonReentrant {

    require(_seller == _msgSender());
    require(!auctionSellerRedeemed[_seller][_sellerNonce]);//is seller already claim?
    AuctionListing storage auctionListed = auctionListings[_tokenAddress][_msgSender()][_sellerNonce];
    require(block.timestamp >= auctionListed.auctionEndTime);//is auction ended?
    uint256 _auctionReserve = auctionReserve[_seller][_sellerNonce];
    if(_auctionReserve>=auctionListed.reservePrice){
      uint256 totalForSeller = _auctionReserve - ((_auctionReserve * fee) / 10000);
      feesAccrued += _auctionReserve - totalForSeller;

      (bool sent,) = _msgSender().call{value: totalForSeller}("");
      auctionSellerRedeemed[_seller][_sellerNonce] = true;
      emit Volume(_msgSender(),totalForSeller);
      require(sent);//check if ether failed to send
    }

    else{
      auctionSellerRedeemed[_seller][_sellerNonce] = true;

      FraktalNFT(_tokenAddress).safeTransferFrom(
      address(this),
      _msgSender(),
      FraktalNFT(_tokenAddress).fraktionsIndex(),
      auctionListed.numberOfShares,
      ""
      );
    }

  }

  function redeemAuctionParticipant(
    address _tokenAddress,
    address _seller,
    uint256 _sellerNonce
  ) external nonReentrant {

    AuctionListing storage auctionListing = auctionListings[_tokenAddress][_seller][_sellerNonce];
    require(block.timestamp >= auctionListing.auctionEndTime);//is auction ended?
    require(auctionListing.auctionEndTime>0);//is auction exist?
    uint256 _auctionReserve = auctionReserve[_seller][_sellerNonce];
    uint256 fraktionsIndex = FraktalNFT(_tokenAddress).fraktionsIndex();
    if(_auctionReserve>=auctionListing.reservePrice){
      uint256 auctionFraks = auctionListing.numberOfShares;
      uint256 _participantContribution = participantContribution[_seller][_sellerNonce][_msgSender()];
      uint256 eligibleFrak = (_participantContribution * auctionFraks) / _auctionReserve;
      participantContribution[_seller][_sellerNonce][_msgSender()] = 0;

      emit Volume(_msgSender(),_participantContribution);

      FraktalNFT(_tokenAddress).safeTransferFrom(
      address(this),
      _msgSender(),
      fraktionsIndex,
      eligibleFrak,
      ""
      );
    }

    else{
      uint256 _contributed = participantContribution[_seller][_sellerNonce][_msgSender()];
      participantContribution[_seller][_sellerNonce][_msgSender()] = 0;

      (bool sent,) = _msgSender().call{value: _contributed}("");
      require(sent);//check if ether failed to send
    }

  }

  function importFraktal(address tokenAddress, uint256 fraktionsIndex)
    external
  {

    FraktalNFT(tokenAddress).safeTransferFrom(
      _msgSender(),
      address(this),
      0,
      1,
      ""
    );
    FraktalNFT(tokenAddress).fraktionalize(_msgSender(), fraktionsIndex);
    FraktalNFT(tokenAddress).lockSharesTransfer(
      _msgSender(),
      10000*10**18,
      address(this)
    );
    FraktalNFT(tokenAddress).unlockSharesTransfer(_msgSender(), address(this));
  }

  function buyFraktions(
    address from,
    address tokenAddress,
    uint256 _numberOfShares
  ) external payable nonReentrant {

    Listing storage listing = listings[tokenAddress][from];
    require(!FraktalNFT(tokenAddress).sold(), "item sold");
    require(
      listing.numberOfShares >= _numberOfShares
    );//"Not enough Fraktions on sale"
    uint256 buyPrice = (listing.price * _numberOfShares)/(10**18);
    require(buyPrice!=0);
    uint256 totalFees = (buyPrice * fee) / 10000;
    uint256 totalForSeller = buyPrice - totalFees;
    uint256 fraktionsIndex = FraktalNFT(tokenAddress).fraktionsIndex();
    require(msg.value >= buyPrice);//"FraktalMarket: insufficient funds"
    listing.numberOfShares = listing.numberOfShares - _numberOfShares;
    if (listing.price * 10000 > maxPriceRegistered[tokenAddress]) {
      maxPriceRegistered[tokenAddress] = listing.price * 10000;
    }
    feesAccrued += msg.value - totalForSeller;
    sellersBalance[from] += totalForSeller;
    FraktalNFT(tokenAddress).safeTransferFrom(
      from,
      _msgSender(),
      fraktionsIndex,
      _numberOfShares,
      ""
    );
    emit Bought(_msgSender(), from, tokenAddress, _numberOfShares);
    emit Volume(_msgSender(),msg.value);
    emit Volume(from,msg.value);
  }

  function participateAuction(
    address tokenAddress,
    address seller,
    uint256 sellerNonce
  ) external payable nonReentrant {

    AuctionListing storage auctionListing = auctionListings[tokenAddress][seller][sellerNonce];
    require(block.timestamp < auctionListing.auctionEndTime);//is auction still ongoing?
    require(auctionListing.auctionEndTime>0);//is auction exist?
    uint256 contribution = msg.value;
    require(contribution>0);//need eth to participate


    auctionReserve[seller][sellerNonce] += msg.value;
    participantContribution[seller][sellerNonce][_msgSender()] += contribution;
    emit AuctionContribute(_msgSender(), tokenAddress, seller, sellerNonce, contribution);
  }

  function listItem(
    address _tokenAddress,
    uint256 _price,//wei per frak
    uint256 _numberOfShares,
    string memory _name
  ) payable external returns (bool) {

    require(msg.value >= listingFee);
    require(_price>0);
    uint256 fraktionsIndex = FraktalNFT(_tokenAddress).fraktionsIndex();
    require(
      FraktalNFT(_tokenAddress).balanceOf(address(this), 0) == 1
    );// "nft not in market"
    require(!FraktalNFT(_tokenAddress).sold());//"item sold"
    require(
      FraktalNFT(_tokenAddress).balanceOf(_msgSender(), fraktionsIndex) >=
        _numberOfShares
    );//"no valid Fraktions"
    Listing memory listed = listings[_tokenAddress][_msgSender()];
    require(listed.numberOfShares == 0);//"unlist first"
    Listing memory listing = Listing({
      tokenAddress: _tokenAddress,
      price: _price,
      numberOfShares: _numberOfShares,
      name: _name
    });
    listings[_tokenAddress][_msgSender()] = listing;
    emit ItemListed(_msgSender(), _tokenAddress, _price, _numberOfShares, _name);
    return true;
  }

  function listItemAuction(
    address _tokenAddress,
    uint256 _reservePrice,
    uint256 _numberOfShares,
    string memory _name
  ) payable external returns (uint256) {

    require(msg.value >= listingFee);
    uint256 fraktionsIndex = FraktalNFT(_tokenAddress).fraktionsIndex();
    require(
      FraktalNFT(_tokenAddress).balanceOf(address(this), 0) == 1
    );//"nft not in market"
    require(!FraktalNFT(_tokenAddress).sold());// "item sold"
    require(
      FraktalNFT(_tokenAddress).balanceOf(_msgSender(), fraktionsIndex) >=
        _numberOfShares
    );//"no valid Fraktions"
    require(_reservePrice>0);
    uint256 sellerNonce = auctionNonce[_msgSender()]++;

    uint256 _endTime = block.timestamp + (10 days);

    auctionListings[_tokenAddress][_msgSender()][sellerNonce] = AuctionListing({
      tokenAddress: _tokenAddress,
      reservePrice: _reservePrice,
      numberOfShares: _numberOfShares,
      auctionEndTime: _endTime,
      name: _name
    });

    FraktalNFT(_tokenAddress).safeTransferFrom(
      _msgSender(),
      address(this),
      fraktionsIndex,
      _numberOfShares,
      ""
    );
    emit AuctionItemListed(_msgSender(), _tokenAddress, _reservePrice, _numberOfShares, _endTime, sellerNonce, _name);
    return auctionNonce[_msgSender()];
  }

  function exportFraktal(address tokenAddress) public {

    uint256 fraktionsIndex = FraktalNFT(tokenAddress).fraktionsIndex();
    FraktalNFT(tokenAddress).safeTransferFrom(_msgSender(), address(this), fraktionsIndex, 10000*10**18, '');
    FraktalNFT(tokenAddress).defraktionalize();
    FraktalNFT(tokenAddress).safeTransferFrom(address(this), _msgSender(), 0, 1, '');
  }

  function makeOffer(address tokenAddress, uint256 _value) public payable {

    require(msg.value >= _value);//"No pay"
    Proposal storage prop = offers[_msgSender()][tokenAddress];
    address payable offerer = payable(_msgSender());
    require(!prop.winner);// "offer accepted"
    if (_value >= prop.value) {
      require(_value >= maxPriceRegistered[tokenAddress], "Min offer");
      require(msg.value >= _value - prop.value);
    } else {
      uint256 bufferedValue = prop.value;
      prop.value = 0;
      AddressUpgradeable.sendValue(offerer, bufferedValue);
    }
    offers[_msgSender()][tokenAddress] = Proposal({
      value: _value,
      winner: false
    });
    emit OfferMade(_msgSender(), tokenAddress, _value);
  }

  function rejectOffer(address from, address to, address tokenAddress) external {

      FraktalNFT(tokenAddress).unlockSharesTransfer(
      from,
      to
    );
  }

  function voteOffer(address offerer, address tokenAddress) external {

    uint256 fraktionsIndex = FraktalNFT(tokenAddress).fraktionsIndex();
    Proposal storage offer = offers[offerer][tokenAddress];
    uint256 lockedShares = FraktalNFT(tokenAddress).lockedShares(fraktionsIndex,_msgSender());
    uint256 votesAvailable = FraktalNFT(tokenAddress).balanceOf(
      _msgSender(),
      fraktionsIndex
    ) - lockedShares;
    FraktalNFT(tokenAddress).lockSharesTransfer(
      _msgSender(),
      votesAvailable,
      offerer
    );
    uint256 lockedToOfferer = FraktalNFT(tokenAddress).lockedToTotal(fraktionsIndex,offerer);
    bool sold = false;
    if (lockedToOfferer > FraktalNFT(tokenAddress).majority()) {
      FraktalNFT(tokenAddress).sellItem();
      offer.winner = true;
      sold = true;
    }
    emit OfferVoted(_msgSender(), offerer, tokenAddress, sold);
  }

  function claimFraktal(address tokenAddress) external {

    uint256 fraktionsIndex = FraktalNFT(tokenAddress).fraktionsIndex();
    if (FraktalNFT(tokenAddress).sold()) {
      Proposal memory offer = offers[_msgSender()][tokenAddress];
      require(
        FraktalNFT(tokenAddress).lockedToTotal(fraktionsIndex,_msgSender())
         > FraktalNFT(tokenAddress).majority(),
        "not buyer"
      );
      FraktalNFT(tokenAddress).createRevenuePayment{ value: offer.value }(address(this));
      maxPriceRegistered[tokenAddress] = 0;
    }
    FraktalNFT(tokenAddress).safeTransferFrom(
      address(this),
      _msgSender(),
      0,
      1,
      ""
    );
    emit FraktalClaimed(_msgSender(), tokenAddress);
  }

  function unlistItem(address tokenAddress) external {

    delete listings[tokenAddress][_msgSender()];
    emit ItemListed(_msgSender(), tokenAddress, 0, 0, "");
  }

  function unlistAuctionItem(address tokenAddress,uint256 sellerNonce) external {

    AuctionListing storage auctionListed = auctionListings[tokenAddress][_msgSender()][sellerNonce];
    require(auctionListed.auctionEndTime>0);

    auctionListed.auctionEndTime = block.timestamp;

    emit AuctionItemListed(_msgSender(), tokenAddress, 0, 0, auctionListed.auctionEndTime,sellerNonce, "");
  }

  function getFee() external view returns (uint256) {

    return (fee);
  }

  function getListingPrice(address _listOwner, address tokenAddress)
    external
    view
    returns (uint256)
  {

    return listings[tokenAddress][_listOwner].price;
  }

  function getListingAmount(address _listOwner, address tokenAddress)
    external
    view
    returns (uint256)
  {

    return listings[tokenAddress][_listOwner].numberOfShares;
  }

  function getSellerBalance(address _who) external view returns (uint256) {

    return (sellersBalance[_who]);
  }

  function getOffer(address offerer, address tokenAddress)
    external
    view
    returns (uint256)
  {

    return (offers[offerer][tokenAddress].value);
  }
  fallback() external payable {
      feesAccrued += msg.value;
  }

  receive() external payable {
      feesAccrued += msg.value;
  }
}