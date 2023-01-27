
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

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
}//MIT
pragma solidity ^0.8.9;


error CallerBlacklisted();
error CallerNotTokenOwner();
error CallerNotTokenStaker();
error StakingNotActive();
error ZeroEmissionRate();

interface ISUPER1155 {

  function balanceOf(address _owner, uint256 _id)
    external
    view
    returns (uint256);


  function groupBalances(uint256 groupId, address from)
    external
    view
    returns (uint256);


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _id,
    uint256 _amount,
    bytes calldata _data
  ) external;


  function safeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] memory _ids,
    uint256[] memory _amounts,
    bytes memory _data
  ) external;

}

interface IGRILL {

  struct Stake {
    bool status;
    address staker;
    uint256 timestamp;
  }

  function getStake(uint256 _tokenId)
    external
    view
    returns (Stake memory _stake);


  function getIdsOfAddr(address _operator)
    external
    view
    returns (uint256[] memory _addrStakes);

}

contract Grill2 is Ownable, ERC1155Holder {

  using Counters for Counters.Counter;
  uint256 internal constant MAX_INT = 2**256 - 1;
  ISUPER1155 public constant Parent =
    ISUPER1155(0x71B11Ac923C967CD5998F23F6dae0d779A6ac8Af);
  IGRILL public immutable OldGrill;
  Counters.Counter internal emChanges;
  bool public isStaking = true;
  mapping(address => Counters.Counter) internal stakesAddedPerAccount;
  mapping(address => Counters.Counter) internal stakesRemovedPerAccount;
  mapping(uint256 => Stake) public stakeStorage;
  mapping(address => mapping(uint256 => uint256)) public accountStakes;
  mapping(uint256 => Emission) public emissionStorage;
  mapping(address => uint256) public unstakedClaims;
  mapping(address => bool) public blacklist;
  mapping(address => address) public proxies;

  struct Emission {
    uint256 rate;
    uint256 timestamp;
  }

  struct Stake {
    address staker;
    uint256 timestamp;
    uint256 accountSlot;
  }


  constructor(address _grillAddr) {
    OldGrill = IGRILL(_grillAddr);
    emissionStorage[emChanges.current()] = Emission(3600 * 24 * 45, 1652054400);
  }


  function setProxyForAccount(address account, address operator)
    public
    onlyOwner
  {

    proxies[account] = operator;
  }

  function removeProxyForAccount(address account) public onlyOwner {

    delete proxies[account];
  }

  function toggleStaking() public onlyOwner {

    isStaking = !isStaking;
  }

  function blacklistAccount(address account, bool status) public onlyOwner {

    blacklist[account] = status;
  }

  function pauseEmissions() public onlyOwner {

    _setEmissionRate(MAX_INT);
  }

  function setEmissionRate(uint256 _seconds) public onlyOwner {

    _setEmissionRate(_seconds);
  }


  function addStakes(uint256[] memory tokenIds, uint256[] memory amounts)
    public
  {

    if (!isStaking) {
      revert StakingNotActive();
    }
    if (blacklist[msg.sender]) {
      revert CallerBlacklisted();
    }
    for (uint256 i = 0; i < tokenIds.length; ++i) {
      uint256 _tokenId = tokenIds[i];
      if (Parent.balanceOf(msg.sender, _tokenId) == 0) {
        revert CallerNotTokenOwner();
      }
      _addStake(msg.sender, _tokenId);
    }
    Parent.safeBatchTransferFrom(
      msg.sender,
      address(this),
      tokenIds,
      amounts,
      "0x00"
    );
  }

  function removeStakes(
    uint256[] memory oldTokenIds,
    uint256[] memory oldAmounts,
    uint256[] memory newTokenIds,
    uint256[] memory newAmounts
  ) public {

    if (oldTokenIds.length > 0) {
      for (uint256 i = 0; i < oldTokenIds.length; ++i) {
        uint256 _tokenId = oldTokenIds[i];
        IGRILL.Stake memory _thisStake = OldGrill.getStake(_tokenId);
        if (_thisStake.staker != msg.sender) {
          revert CallerNotTokenStaker();
        }
        unstakedClaims[msg.sender] += countEmissions(_thisStake.timestamp);
      }
      Parent.safeBatchTransferFrom(
        address(OldGrill),
        msg.sender,
        oldTokenIds,
        oldAmounts,
        "0x00"
      );
    }
    if (newTokenIds.length > 0) {
      for (uint256 i = 0; i < newTokenIds.length; ++i) {
        uint256 _tokenId = newTokenIds[i];
        if (stakeStorage[_tokenId].staker != msg.sender) {
          revert CallerNotTokenStaker();
        }
        _removeStake(_tokenId);
      }
      Parent.safeBatchTransferFrom(
        address(this),
        msg.sender,
        newTokenIds,
        newAmounts,
        "0x00"
      );
    }
  }

  function countEmissions(uint256 _timestamp) public view returns (uint256 _c) {

    if (
      _timestamp < emissionStorage[0].timestamp || _timestamp > block.timestamp
    ) {
      _c = 0;
    } else {
      uint256 minT;
      for (uint256 i = 1; i <= emChanges.current(); ++i) {
        if (emissionStorage[i].timestamp < _timestamp) {
          minT += 1;
        }
      }
      for (uint256 i = minT; i <= emChanges.current(); ++i) {
        uint256 tSmall = emissionStorage[i].timestamp;
        uint256 tBig = emissionStorage[i + 1].timestamp; // 0 if not set yet
        if (i == minT) {
          tSmall = _timestamp;
        }
        if (i == emChanges.current()) {
          tBig = block.timestamp;
        }
        _c += (tBig - tSmall) / emissionStorage[i].rate;
      }
    }
  }


  function _addStake(address staker, uint256 tokenId) internal {

    stakesAddedPerAccount[staker].increment();
    accountStakes[staker][stakesAddedPerAccount[staker].current()] = tokenId;
    stakeStorage[tokenId] = Stake(
      staker,
      block.timestamp,
      stakesAddedPerAccount[staker].current()
    );
  }

  function _removeStake(uint256 tokenId) internal {

    Stake memory _thisStake = stakeStorage[tokenId];
    stakesRemovedPerAccount[_thisStake.staker].increment();
    unstakedClaims[_thisStake.staker] += countEmissions(_thisStake.timestamp);
    delete accountStakes[_thisStake.staker][_thisStake.accountSlot];
    delete stakeStorage[tokenId];
  }

  function _setEmissionRate(uint256 _seconds) private {

    if (_seconds == 0) {
      revert ZeroEmissionRate();
    }
    emChanges.increment();
    emissionStorage[emChanges.current()] = Emission(_seconds, block.timestamp);
  }

  function _activeStakesCountPerAccount(address account)
    internal
    view
    returns (uint256 _active)
  {

    _active =
      stakesAddedPerAccount[account].current() -
      stakesRemovedPerAccount[account].current();
  }

  function _activeStakesCountPerAccountOld(address account)
    internal
    view
    returns (uint256 _active)
  {

    uint256[] memory oldStakes = OldGrill.getIdsOfAddr(account);
    for (uint256 i = 0; i < oldStakes.length; ++i) {
      if (Parent.balanceOf(address(OldGrill), oldStakes[i]) == 1) {
        _active += 1;
      }
    }
  }


  function stakedIdsPerAccount(address account)
    public
    view
    returns (uint256[] memory _ids)
  {

    _ids = new uint256[](_activeStakesCountPerAccount(account));
    uint256 found;
    for (uint256 i = 1; i <= stakesAddedPerAccount[account].current(); ++i) {
      if (accountStakes[account][i] != 0) {
        _ids[found++] = accountStakes[account][i];
      }
    }
  }

  function stakedIdsPerAccountOld(address account)
    public
    view
    returns (uint256[] memory _ids)
  {

    uint256[] memory oldStakes = OldGrill.getIdsOfAddr(account);
    _ids = new uint256[](_activeStakesCountPerAccountOld(account));
    uint256 found;
    for (uint256 i = 0; i < oldStakes.length; ++i) {
      if (Parent.balanceOf(address(OldGrill), oldStakes[i]) == 1) {
        _ids[found++] = oldStakes[i];
      }
    }
  }

  function emissionChanges() external view returns (uint256 _changes) {

    _changes = emChanges.current();
  }

  function stakedClaims(address account) public view returns (uint256 _earned) {

    uint256[] memory ownedIds = stakedIdsPerAccount(account);
    for (uint256 i; i < ownedIds.length; ++i) {
      _earned += countEmissions(stakeStorage[ownedIds[i]].timestamp);
    }
    uint256[] memory ownedIdsOld = stakedIdsPerAccountOld(account);
    for (uint256 i; i < ownedIdsOld.length; ++i) {
      _earned += countEmissions(OldGrill.getStake(ownedIdsOld[i]).timestamp);
    }
  }

  function totalClaims(address account)
    external
    view
    returns (uint256 _earned)
  {

    _earned = unstakedClaims[account] + stakedClaims(account);
  }

  function stakeStorageGetter(uint256 tokenId)
    public
    view
    returns (Stake memory _s)
  {

    _s = stakeStorage[tokenId];
  }

  function stakeStorageOld(uint256 tokenId)
    public
    view
    returns (IGRILL.Stake memory _og)
  {

    _og = OldGrill.getStake(tokenId);
  }
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


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
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
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

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

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

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
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

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

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
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

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
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


    function _afterTokenTransfer(
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
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
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
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
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
}//MIT
pragma solidity ^0.8.9;


error BurningNotActive();
error ClaimingNotActive();
error CallerIsNotABurner();
error InsufficientClaimsRemaining();

contract Burger is ERC1155, Ownable {

  using Strings for uint256;
  Grill2 public immutable TheGrill;
  Grill2 public SpecialGrill;
  bool public isClaiming = false;
  bool public isBurning = false;
  bool public isSpecial = false;
  uint256 public totalMints;
  uint256 public totalBurns;
  mapping(address => bool) public burners;
  mapping(address => uint256) public claimsUsed;
  mapping(address => uint256) public accountBurns;
  mapping(address => uint256) public burnerBurns;


  constructor(string memory _URI, address aGrill) ERC1155(_URI) {
    TheGrill = Grill2(aGrill);
  }


  function _totalClaimsEarned(address account)
    internal
    view
    returns (uint256 quantity)
  {

    quantity += TheGrill.totalClaims(account);
    if (isSpecial) {
      quantity += SpecialGrill.totalClaims(account);
    }
  }


  function setURI(string memory _URI) public onlyOwner {

    _setURI(_URI);
  }

  function toggleClaiming() public onlyOwner {

    isClaiming = !isClaiming;
  }

  function toggleBurning() public onlyOwner {

    isBurning = !isBurning;
  }

  function setBurner(address account, bool status) public onlyOwner {

    burners[account] = status;
  }

  function ownerMint(uint256 quantity, address account) public onlyOwner {

    _mint(account, 1, quantity, "0x00");
    totalMints += quantity;
  }

  function toggleSpecial() public onlyOwner {

    isSpecial = !isSpecial;
  }

  function setSpecial(address aGrill) public onlyOwner {

    SpecialGrill = Grill2(aGrill);
  }


  function claimBurgers(uint256 quantity) public {

    if (!isClaiming) {
      revert ClaimingNotActive();
    }
    if (claimsUsed[msg.sender] + quantity > _totalClaimsEarned(msg.sender)) {
      revert InsufficientClaimsRemaining();
    }
    _mint(msg.sender, 1, quantity, "0x00");
    claimsUsed[msg.sender] += quantity;
    totalMints += quantity;
  }

  function burnBurger(address account, uint256 quantity) public {

    if (!isBurning) {
      revert BurningNotActive();
    }
    if (!burners[msg.sender]) {
      revert CallerIsNotABurner();
    }
    _burn(account, 1, quantity);
    totalBurns += quantity;
    accountBurns[account] += quantity;
    burnerBurns[msg.sender] += quantity;
  }


  function balanceOf(address account) public view returns (uint256 _balance) {

    _balance = balanceOf(account, 1);
  }

  function totalSupply() public view returns (uint256 _totalSupply) {

    _totalSupply = totalMints - totalBurns;
  }

  function tokenClaimsLeft(address account)
    public
    view
    returns (uint256 _remaining)
  {

    _remaining = _totalClaimsEarned(account) - claimsUsed[account];
  }
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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.4;


interface IERC721A is IERC721, IERC721Metadata {

    error ApprovalCallerNotOwnerNorApproved();

    error ApprovalQueryForNonexistentToken();

    error ApproveToCaller();

    error ApprovalToCurrentOwner();

    error BalanceQueryForZeroAddress();

    error MintToZeroAddress();

    error MintZeroQuantity();

    error OwnerQueryForNonexistentToken();

    error TransferCallerNotOwnerNorApproved();

    error TransferFromIncorrectOwner();

    error TransferToNonERC721ReceiverImplementer();

    error TransferToZeroAddress();

    error URIQueryForNonexistentToken();

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
    }

    struct AddressData {
        uint64 balance;
        uint64 numberMinted;
        uint64 numberBurned;
        uint64 aux;
    }

    function totalSupply() external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.4;


contract ERC721A is Context, ERC165, IERC721A {

    using Address for address;
    using Strings for uint256;

    uint256 internal _currentIndex;

    uint256 internal _burnCounter;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) internal _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    function _startTokenId() internal view virtual returns (uint256) {

        return 0;
    }

    function totalSupply() public view override returns (uint256) {

        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    function _totalMinted() internal view returns (uint256) {

        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberMinted);
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberBurned);
    }

    function _getAux(address owner) internal view returns (uint64) {

        return _addressData[owner].aux;
    }

    function _setAux(address owner, uint64 aux) internal {

        _addressData[owner].aux = aux;
    }

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr) if (curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner) if(!isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        if (operator == _msgSender()) revert ApproveToCaller();

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

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        _transfer(from, to, tokenId);
        if (to.isContract()) if(!_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _startTokenId() <= tokenId && tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex < end);
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex < end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _mint(address to, uint256 quantity) internal {

        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, from);

        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _burn(uint256 tokenId) internal virtual {

        _burn(tokenId, false);
    }

    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        _approve(address(0), tokenId, from);

        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        unchecked {
            _burnCounter++;
        }
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

}//MIT
pragma solidity ^0.8.9;


error MintingNotActive();
error AstrobullAlreadyClaimed();

contract MetaBull is ERC721A, Ownable {
  using Strings for uint256;
  Burger public immutable BurgerContract;
  Grill2 public immutable GrillContract;
  ISUPER1155 public constant Astro =
    ISUPER1155(0x71B11Ac923C967CD5998F23F6dae0d779A6ac8Af);
  address public constant OldGrill = 0xE11AF478aF241FAb926f4c111d50139Ae003F7fd;
  bool public isMinting;
  bool public isRevealed;
  uint256 public burnScalar = 2;
  uint256 public totalBurns;
  string public URI;
  mapping(uint256 => bool) public portedIds;
  mapping(uint256 => uint256) public portingMeta;
  mapping(address => uint256) public accountBurns;


  constructor(
    string memory _URI,
    address burgerAddr,
    address grillAddr
  ) ERC721A("METABULLS", "MBULL") {
    URI = _URI;
    BurgerContract = Burger(burgerAddr);
    GrillContract = Grill2(grillAddr);
  }


  function _startTokenId() internal pure override returns (uint256 _id) {
    _id = 1;
  }


  function setURI(string memory _URI) public onlyOwner {
    URI = _URI;
  }

  function toggleMinting() public onlyOwner {
    isMinting = !isMinting;
  }

  function toggleReveal() public onlyOwner {
    isRevealed = !isRevealed;
  }

  function setBurnScalar(uint256 _burnScalar) public onlyOwner {
    burnScalar = _burnScalar;
  }

  function ownerMint(uint256 quantity, address account) public onlyOwner {
    _safeMint(account, quantity);
  }


  function claimBull(uint256[] memory astrobullIds) public {
    if (!isMinting) {
      revert MintingNotActive();
    }
    uint256 currentIndex = _currentIndex;
    for (uint256 i = 0; i < astrobullIds.length; ++i) {
      if (!_checkOwnerShip(msg.sender, astrobullIds[i])) {
        revert CallerNotTokenOwner();
      }
      if (portedIds[astrobullIds[i]]) {
        revert AstrobullAlreadyClaimed();
      }
      portingMeta[currentIndex] = astrobullIds[i];
      portedIds[astrobullIds[i]] = true;
      currentIndex += 1;
    }
    uint256 toBurn = burnScalar * astrobullIds.length;
    BurgerContract.burnBurger(msg.sender, toBurn);
    totalBurns += toBurn;
    accountBurns[msg.sender] += toBurn;
    _safeMint(msg.sender, astrobullIds.length);
  }


  function _checkOwnerShip(address account, uint256 tokenId)
    internal
    view
    returns (bool _b)
  {
    _b = false;
    if (Astro.balanceOf(account, tokenId) == 1) {
      _b = true;
    }
    else if (Astro.balanceOf(address(OldGrill), tokenId) == 1) {
      if (GrillContract.stakeStorageOld(tokenId).staker == account) {
        _b = true;
      }
    }
    else if (GrillContract.stakeStorageGetter(tokenId).staker == account) {
      _b = true;
    }
  }


  function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory _URI)
  {
    if (isRevealed) {
      _URI = string(abi.encodePacked(URI, _tokenId.toString(), ".json"));
    } else {
      _URI = URI;
    }
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}// MIT

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
}//MIT
pragma solidity ^0.8.9;


error ExceedsMaxClaims();
error InvalidTokenAmount();
error CallerIsNotTokenOwner();
error CallerNotInCommunity();

contract PhysicalBull is Ownable {
  using Strings for uint256;
  using SafeERC20 for IERC20;
  IERC20 public erc20;
  Burger public immutable BurgerContract;
  Grill2 public immutable GrillContract;
  ISUPER1155 public constant Astro =
    ISUPER1155(0x71B11Ac923C967CD5998F23F6dae0d779A6ac8Af);
  bool public isClaiming = false;
  address public vault;
  uint256 public totalClaims;
  uint256 public maxClaims = 3;
  uint256 public totalBurns;
  uint256 public burnScalar = 1;
  uint256 public erc20Cost = 100000000; // 100.000000 $USDC
  mapping(address => uint256) public accountBurns;
  mapping(address => uint256) public accountClaims;

  constructor(
    address _vault,
    address _erc20,
    address _burger,
    address _grill
  ) {
    vault = _vault;
    erc20 = IERC20(_erc20);
    BurgerContract = Burger(_burger);
    GrillContract = Grill2(_grill);
  }


  function toggleClaiming() public onlyOwner {
    isClaiming = !isClaiming;
  }

  function setERC20Cost(uint256 _erc20Cost) public onlyOwner {
    erc20Cost = _erc20Cost;
  }

  function setERC20Address(address _erc20) public onlyOwner {
    erc20 = IERC20(_erc20);
  }

  function setBurnScalar(uint256 _burnScalar) public onlyOwner {
    burnScalar = _burnScalar;
  }

  function setMaxClaims(uint256 _maxClaims) public onlyOwner {
    maxClaims = _maxClaims;
  }

  function setVault(address _vault) public onlyOwner {
    vault = _vault;
  }


  function _checkCommunityStatus(address account)
    internal
    view
    returns (bool _b)
  {
    _b = false;
    if (Astro.groupBalances(1, account) > 0) {
      _b = true;
    }
    else if (GrillContract.stakedIdsPerAccountOld(account).length > 0) {
      _b = true;
    }
    else if (GrillContract.stakedIdsPerAccount(account).length > 0) {
      _b = true;
    }
  }


  function claimBulls(uint256 quantity) public {
    if (!isClaiming) {
      revert ClaimingNotActive();
    }
    if (!_checkCommunityStatus(msg.sender)) {
      revert CallerNotInCommunity();
    }
    if (accountClaims[msg.sender] + quantity > maxClaims) {
      revert ExceedsMaxClaims();
    }
    if (quantity == 0) {
      revert InvalidTokenAmount();
    }
    erc20.safeTransferFrom(msg.sender, vault, quantity * erc20Cost);
    uint256 toBurn = burnScalar * quantity;
    BurgerContract.burnBurger(msg.sender, burnScalar * quantity);
    totalBurns += toBurn;
    accountBurns[msg.sender] += toBurn;
    totalClaims += quantity;
    accountClaims[msg.sender] += quantity;
  }
}