
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
}//MIT
pragma solidity ^0.8.0;


interface Super1155 {

  function safeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] memory _ids,
    uint256[] memory _amounts,
    bytes memory _data
  ) external;


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _id,
    uint256 _amount,
    bytes calldata _data
  ) external;


  function balanceOf(address _owner, uint256 _id)
    external
    view
    returns (uint256);


  function isApprovedForAll(address _owner, address _operator)
    external
    view
    returns (bool);

}

contract Grill is Ownable, ERC1155Holder {

  using Counters for Counters.Counter;

  Super1155 private immutable Parent;

  bool private STAKING_ACTIVE;
  bool private BAILED_OUT;

  uint256 private constant MAX_TXN = 20;

  uint256 private constant MAX_INT = 2**256 - 1;

  mapping(uint256 => Stake) private stakes;

  mapping(address => mapping(uint256 => uint256)) private addrStakesIds;

  mapping(address => Counters.Counter) private addrStakesCount;

  mapping(address => bool) private blacklist;

  Counters.Counter private emChanges;

  mapping(uint256 => Emission) private emissions;

  mapping(address => uint256) private unstakedClaims;

  Counters.Counter private allStakesCount;

  mapping(uint256 => uint256) private allStakes;

  struct Stake {
    bool status;
    address staker;
    uint256 timestamp;
  }

  struct Emission {
    uint256 rate;
    uint256 timestamp;
  }


  constructor(address _parentAddr) {
    Parent = Super1155(_parentAddr);
    STAKING_ACTIVE = true;
    BAILED_OUT = false;
    uint256 secondsIn45Days = 3600 * 24 * 45;
    emissions[emChanges.current()] = Emission(secondsIn45Days, block.timestamp);
  }


  function toggleStaking() external onlyOwner {

    require(!BAILED_OUT, "GRILL: contract has been terminated");
    STAKING_ACTIVE = !STAKING_ACTIVE;
  }

  function blacklistAddr(address _addr, bool _status) external onlyOwner {

    blacklist[_addr] = _status;
  }

  function pauseEmissions() external onlyOwner {

    _setEmissionRate(MAX_INT);
  }

  function setEmissionRate(uint256 _seconds) external onlyOwner {

    require(!BAILED_OUT, "GRILL: cannot change emission rate after bailout");
    _setEmissionRate(_seconds);
  }

  function toggleBailout() external onlyOwner {

    require(!BAILED_OUT, "GRILL: bailout already called");
    STAKING_ACTIVE = false;
    BAILED_OUT = true;
    _setEmissionRate(MAX_INT);
  }

  function bailoutAllStakes() external onlyOwner {

    require(BAILED_OUT, "GRILL: toggleBailout() must be called first");

    uint256 _totalCount = allStakesCount.current();
    for (uint256 i = 1; i <= _totalCount; ++i) {
      uint256 _lastTokenId = allStakes[allStakesCount.current()];
      address _staker = stakes[_lastTokenId].staker;

      Parent.safeTransferFrom(address(this), _staker, _lastTokenId, 1, "0x0");

      uint256[] memory _singleArray = _makeOnesArray(1);
      _singleArray[0] = _lastTokenId; // _removeStakes() requires an array of tokenIds
      _removeStakes(_staker, _singleArray);
    }
  }

  function bailoutSingleStake(uint256 _tokenId) external onlyOwner {

    require(BAILED_OUT, "GRILL: toggleBailout() must be called first");

    Parent.safeTransferFrom(
      address(this),
      stakes[_tokenId].staker,
      _tokenId,
      1,
      "0x0"
    );

    uint256[] memory _singleArray = _makeOnesArray(1);
    _singleArray[0] = _tokenId;
    _removeStakes(stakes[_tokenId].staker, _singleArray);
  }


  function addStakes(uint256[] memory _tokenIds, uint256[] memory _amounts)
    external
  {

    require(STAKING_ACTIVE, "GRILL: staking is not active");
    require(!blacklist[msg.sender], "GRILL: caller is blacklisted");
    require(_tokenIds.length > 0, "GRILL: must stake more than 0 tokens");
    require(
      _tokenIds.length <= MAX_TXN,
      "GRILL: must stake less than MAX_TXN tokens per txn"
    );
    require(
      _isOwnerOfBatch(msg.sender, _tokenIds, _amounts),
      "GRILL: caller does not own these tokens"
    );
    require(
      Parent.isApprovedForAll(msg.sender, address(this)),
      "GRILL: contract is not an approved operator for caller's tokens"
    );

    Parent.safeBatchTransferFrom(
      msg.sender,
      address(this),
      _tokenIds,
      _amounts,
      "0x0"
    );

    _addStakes(msg.sender, _tokenIds);
  }

  function removeStakes(uint256[] memory _tokenIds, uint256[] memory _amounts)
    external
  {

    require(_tokenIds.length > 0, "GRILL: must unstake more than 0 tokens");
    require(
      _tokenIds.length <= MAX_TXN,
      "GRILL: cannot stake more than MAX_TXN tokens in a single txn"
    );
    require(_tokenIds.length == _amounts.length, "GRILL: arrays mismatch");
    require(
      _isStakerOfBatch(msg.sender, _tokenIds, _amounts),
      "GRILL: caller was not the staker of these tokens"
    );
    require(
      _tokenIds.length <= addrStakesCount[msg.sender].current(),
      "GRILL: caller is unstaking too many tokens"
    );

    Parent.safeBatchTransferFrom(
      address(this),
      msg.sender,
      _tokenIds,
      _amounts,
      "0x0"
    );

    _removeStakes(msg.sender, _tokenIds);
  }


  function _isOwnerOfBatch(
    address _operator,
    uint256[] memory _tokenIds,
    uint256[] memory _amounts
  ) private view returns (bool _b) {

    _b = true;
    for (uint256 i = 0; i < _tokenIds.length; ++i) {
      if (parentBalance(_operator, _tokenIds[i]) == 0 || _amounts[i] != 1) {
        _b = false;
        break;
      }
    }
  }

  function _isStakerOfBatch(
    address _operator,
    uint256[] memory _tokenIds,
    uint256[] memory _amounts
  ) private view returns (bool _b) {

    _b = true;
    for (uint256 i = 0; i < _tokenIds.length; ++i) {
      if (stakes[_tokenIds[i]].staker != _operator || _amounts[i] != 1) {
        _b = false;
        break;
      }
    }
  }

  function _addStakes(address _staker, uint256[] memory _tokenIds) private {

    for (uint256 i = 0; i < _tokenIds.length; ++i) {
      require(!stakes[_tokenIds[i]].status, "GRILL: token already staked");

      addrStakesCount[_staker].increment();
      allStakesCount.increment();

      addrStakesIds[_staker][addrStakesCount[_staker].current()] = _tokenIds[i];
      allStakes[allStakesCount.current()] = _tokenIds[i];
      stakes[_tokenIds[i]] = Stake(true, _staker, block.timestamp);
    }
  }

  function _removeStakes(address _staker, uint256[] memory _tokenIds) private {

    for (uint256 i = 0; i < _tokenIds.length; ++i) {
      require(
        stakes[_tokenIds[i]].status,
        "GRILL: token is not currently staked"
      );

      uint256 _tokenId = _tokenIds[i];
      unstakedClaims[_staker] += _countEmissions(_tokenId);

      delete stakes[_tokenId];

      uint256 _t = addrStakesCount[_staker].current();
      uint256 _t1 = allStakesCount.current();

      for (uint256 j = 1; j < _t; ++j) {
        if (addrStakesIds[_staker][j] == _tokenId) {
          addrStakesIds[_staker][j] = addrStakesIds[_staker][_t];
        }
      }
      for (uint256 k = 1; k < _t1; ++k) {
        if (allStakes[k] == _tokenId) {
          allStakes[k] = allStakes[_t1];
        }
      }

      delete addrStakesIds[_staker][_t];
      delete allStakes[_t1];

      if (_t != 0) {
        addrStakesCount[_staker].decrement();
      }
      if (_t1 != 0) {
        allStakesCount.decrement();
      }
    }
  }

  function _setEmissionRate(uint256 _seconds) private {

    require(_seconds > 0, "GRILL: emission rate cannot be 0");
    emChanges.increment();
    emissions[emChanges.current()] = Emission(_seconds, block.timestamp);
  }

  function _countEmissions(uint256 _tokenId) private view returns (uint256 _c) {

    require(stakes[_tokenId].status, "GRILL: token is not currently staked");

    uint256 minT;
    uint256 timeStake = stakes[_tokenId].timestamp;
    for (uint256 i = 1; i <= emChanges.current(); ++i) {
      if (emissions[i].timestamp < timeStake) {
        minT += 1;
      }
    }
    for (uint256 i = minT; i <= emChanges.current(); ++i) {
      uint256 tSmall = emissions[i].timestamp;
      uint256 tBig = emissions[i + 1].timestamp;
      if (i == minT) {
        tSmall = timeStake;
      }
      if (i == emChanges.current()) {
        tBig = block.timestamp;
      }
      _c += (tBig - tSmall) / emissions[i].rate;
    }
  }

  function _makeOnesArray(uint256 _n)
    private
    pure
    returns (uint256[] memory _ones)
  {

    _ones = new uint256[](_n);
    for (uint256 i = 0; i < _n; i++) {
      _ones[i] = 1;
    }
    return _ones;
  }


  function parentBalance(address _operator, uint256 _tokenId)
    public
    view
    returns (uint256 _c)
  {

    _c = Parent.balanceOf(_operator, _tokenId);
  }

  function isStakingActive() external view returns (bool _b) {

    _b = STAKING_ACTIVE;
  }

  function isBailedOut() external view returns (bool _b) {

    _b = BAILED_OUT;
  }

  function isBlacklisted(address _addr) external view returns (bool _b) {

    _b = blacklist[_addr];
  }

  function getEmissionChanges() external view returns (uint256 _changes) {

    _changes = emChanges.current();
  }

  function getEmission(uint256 _change)
    external
    view
    returns (Emission memory _emission)
  {

    require(_change <= emChanges.current(), "GRILL: invalid index to lookup");
    _emission = emissions[_change];
  }

  function getAllStakedIds()
    external
    view
    returns (uint256[] memory _allStakingIds)
  {

    _allStakingIds = new uint256[](allStakesCount.current());
    for (uint256 i = 0; i < _allStakingIds.length; ++i) {
      _allStakingIds[i] = allStakes[i + 1];
    }
  }

  function getStake(uint256 _tokenId)
    external
    view
    returns (Stake memory _stake)
  {

    require(stakes[_tokenId].status, "GRILL: tokenId is not staked");
    _stake = stakes[_tokenId];
  }

  function getIdsOfAddr(address _operator)
    external
    view
    returns (uint256[] memory _addrStakes)
  {

    _addrStakes = new uint256[](addrStakesCount[_operator].current());
    for (uint256 i = 0; i < _addrStakes.length; ++i) {
      _addrStakes[i] = addrStakesIds[_operator][i + 1];
    }
  }

  function getUnstakedClaims(address _operator) public view returns (uint256) {

    return unstakedClaims[_operator];
  }

  function getStakedClaims(address _operator)
    public
    view
    returns (uint256 _total)
  {

    for (uint256 i = 1; i <= addrStakesCount[_operator].current(); i++) {
      _total += _countEmissions(addrStakesIds[_operator][i]);
    }
  }

  function getTotalClaims(address _operator)
    external
    view
    returns (uint256 _total)
  {

    _total = unstakedClaims[_operator];
    _total += getStakedClaims(_operator);
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
}//MIT
pragma solidity ^0.8.0;


interface GrillC {

  function getTotalClaims(address _operator) external view returns (uint256);

}

contract Burger is ERC1155, Ownable {

  using Counters for Counters.Counter;

  GrillC public immutable AstroGrill;
  GrillC public immutable RickstroGrill;

  Counters.Counter private totalMinted;
  Counters.Counter private totalBurned;

  bool private CAN_MINT = false;
  bool private CAN_BURN = false;

  bytes32 constant MINTS = keccak256("CLAIMS");
  bytes32 constant BURNS = keccak256("BURNS");

  mapping(bytes32 => mapping(address => Counters.Counter)) private stats;

  constructor(address _aGrillAddr, address _rGrillAddr)
    ERC1155("burger.io/{}.json")
  {
    AstroGrill = GrillC(_aGrillAddr);
    RickstroGrill = GrillC(_rGrillAddr);
  }


  function setURI(string memory _URI) public onlyOwner {

    _setURI(_URI);
  }

  function toggleMinting() external onlyOwner {

    CAN_MINT = !CAN_MINT;
  }

  function toggleBurning() external onlyOwner {

    CAN_BURN = !CAN_BURN;
  }

  function ownerMint(uint256 _amount, address _addr) external onlyOwner {

    uint256[] memory _ids = new uint256[](_amount);
    uint256[] memory _amounts = new uint256[](_amount);

    for (uint256 i = 0; i < _amount; i++) {
      totalMinted.increment();
      _ids[i] = totalMinted.current();
      _amounts[i] = 1;
    }

    _mintBatch(_addr, _ids, _amounts, "0x0");
  }


  function mintPublic(uint256 _amount) external {

    require(CAN_MINT, "BURGER: minting is not active");
    require(_amount > 0, "BURGER: must claim more than 0 tokens");
    require(
      stats[MINTS][msg.sender].current() + _amount <=
        AstroGrill.getTotalClaims(msg.sender) +
          RickstroGrill.getTotalClaims(msg.sender),
      "BURGER: caller cannot claim this many tokens"
    );

    uint256[] memory _ids = new uint256[](_amount);
    uint256[] memory _amounts = new uint256[](_amount);

    for (uint256 i = 0; i < _amount; i++) {
      stats[MINTS][msg.sender].increment();
      totalMinted.increment();
      _ids[i] = totalMinted.current();
      _amounts[i] = 1;
    }

    _mintBatch(msg.sender, _ids, _amounts, "0x0");
  }

  function burnPublic(uint256[] memory _ids) external {

    require(CAN_BURN, "BURGER: burning is not active");
    require(_ids.length > 0, "BURGER: must burn more than 0 tokens");

    uint256[] memory _amounts = new uint256[](_ids.length);

    for (uint256 i = 0; i < _ids.length; i++) {
      require(
        balanceOf(msg.sender, _ids[i]) > 0,
        "BURGER: caller is not token owner"
      );
      _amounts[i] = 1;
      stats[BURNS][msg.sender].increment();
      totalBurned.increment();
    }
    _burnBatch(msg.sender, _ids, _amounts);
  }


  function isMinting() external view returns (bool _b) {

    return CAN_MINT;
  }

  function isBurning() external view returns (bool _b) {

    return CAN_BURN;
  }

  function totalSupply() external view returns (uint256 _supply) {

    _supply = totalMinted.current() - totalBurned.current();
  }

  function totalMints() external view returns (uint256 _mints) {

    _mints = totalMinted.current();
  }

  function totalBurns() external view returns (uint256 _burns) {

    _burns = totalBurned.current();
  }

  function tokenMintsLeft(address _operator)
    external
    view
    returns (uint256 _remaining)
  {

    _remaining =
      AstroGrill.getTotalClaims(_operator) +
      RickstroGrill.getTotalClaims(_operator) -
      stats[MINTS][_operator].current();
  }

  function tokenMints(address _operator)
    external
    view
    returns (uint256 _mints)
  {

    _mints = stats[MINTS][_operator].current();
  }

  function tokenBurns(address _operator)
    external
    view
    returns (uint256 _burns)
  {

    _burns = stats[BURNS][_operator].current();
  }
}