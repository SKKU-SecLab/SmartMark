pragma solidity 0.6.12;

contract Governance {

  address public owner;
  address public ownerCandidate;

  address public boosterEscrow;

  mapping(address => bool) public games;
  mapping(address => bool) public gemlyMinters;
  mapping(address => bool) public gameMinters;

  event OwnerCandidateSet(address indexed ownerCandidate);
  event OwnerConfirmed(address indexed owner);
  event BoosterEscrowSet(address indexed escrow);
  event GemlyMinterGranted(address indexed minter);
  event GemlyMinterRevoked(address indexed minter);
  event GameMinterGranted(address indexed minter);
  event GameMinterRevoked(address indexed minter);
  event GameGranted(address indexed game);
  event GameRevoked(address indexed game);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(isOwner(msg.sender), "Not owner");
    _;
  }

  modifier onlyOwnerCandidate() {

    require(isOwnerCandidate(msg.sender), "Not owner candidate");
    _;
  }

  function setOwnerCandidate(address _ownerCandidate) external onlyOwner {

    require(_ownerCandidate != address(0), "New owner shouldn't be empty");
    ownerCandidate = _ownerCandidate;

    emit OwnerCandidateSet(ownerCandidate);
  }

  function confirmOwner() external onlyOwnerCandidate {

    owner = ownerCandidate;
    ownerCandidate = address(0x0);

    emit OwnerConfirmed(owner);
  }

  function setBoosterEscrow(address _escrow) external onlyOwner {

    boosterEscrow = _escrow;

    emit BoosterEscrowSet(boosterEscrow);
  }

  function grantGemlyMinter(address _minter) external onlyOwner {

    gemlyMinters[_minter] = true;

    emit GemlyMinterGranted(_minter);
  }

  function revokeGemlyMinter(address _minter) external onlyOwner {

    gemlyMinters[_minter] = false;

    emit GemlyMinterRevoked(_minter);
  }

  function grantGameMinter(address _minter) external onlyOwner {

    gameMinters[_minter] = true;

    emit GameMinterGranted(_minter);
  }

  function revokeGameMinter(address _minter) external onlyOwner {

    gameMinters[_minter] = false;

    emit GameMinterRevoked(_minter);
  }

  function grantGame(address _minter) external onlyOwner {

    games[_minter] = true;

    emit GameGranted(_minter);
  }

  function revokeGame(address _minter) external onlyOwner {

    games[_minter] = false;

    emit GameRevoked(_minter);
  }

  function isOwner(address _account) public view returns (bool) {

    return _account == owner;
  }

  function isOwnerCandidate(address _account) public view returns (bool) {

    return _account == ownerCandidate;
  }

  function isGemlyMinter(address _minter) public view returns (bool) {

    return gemlyMinters[_minter];
  }

  function isGameMinter(address _minter) public view returns (bool) {

    return gameMinters[_minter];
  }

  function isGame(address _game) public view returns (bool) {

    return games[_game];
  }

  function isBoosterEscrow(address _address) public view returns (bool) {

    return _address == boosterEscrow;
  }
}// "MIT"
pragma solidity 0.6.12;


contract Governable {

  Governance public governance;

  constructor(address _governance) public {
    require(_governance != address(0), "New governance shouldn't be empty");
    governance = Governance(_governance);
  }

  modifier onlyGovernance() {

    require(governance.isOwner(msg.sender), "Not governance");
    _;
  }
  
  modifier onlyGemlyMinter() {

    require(governance.isGemlyMinter(msg.sender), "Not gemly minter");
    _;
  }

  modifier onlyGameMinter() {

    require(governance.isGameMinter(msg.sender), "Not game minter");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {

    require(_governance != address(0), "New governance shouldn't be empty");
    governance = Governance(_governance);
  }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


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

pragma solidity >=0.6.2 <0.8.0;


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

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
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

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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
}// "MIT"
pragma solidity >=0.6.0 <0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri_) public {
        _setURI(uri_);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view override returns (string memory) {

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

abstract contract ERC1155Pausable is ERC1155, Pausable {
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal virtual override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}// "MIT"
pragma solidity 0.6.12;


contract BoosterToken is Governable, ERC1155Pausable {

  struct Boost {
    uint256 winIncrease;
    uint256 gasDecrease;
    uint256 price;
  }

  Boost[] public boosters;

  event BoosterInit(uint256 indexed id);
  event BoosterBought(uint256 indexed id);

  constructor(address _governance, string memory _uri) public
    Governable(_governance)
    ERC1155(_uri)
  {
    boosters.push(Boost(0, 0, 0));
  }

  function init(uint256 _winIncrease, uint256 _gasDecrease, uint256 _price) public onlyGovernance {

    boosters.push(Boost(_winIncrease, _gasDecrease, _price));

    emit BoosterInit(boosters.length);
  }

  function initBatch(uint256[] calldata _winIncreases, uint256[] calldata _gasDecreases, uint256[] calldata _prices) external onlyGovernance {

    require(_winIncreases.length == _gasDecreases.length && _gasDecreases.length == _prices.length);
    for(uint8 i = 0; i < _winIncreases.length; i++) {
      init(_winIncreases[i], _gasDecreases[i], _prices[i]);
    }
  }

  function getBooster(uint256 _id) public view returns (uint256, uint256, uint256) {

    Boost storage booster = boosters[_id];
    return (booster.winIncrease, booster.gasDecrease, booster.price);
  }

  function buy(address _to, uint256 _id) payable external whenNotPaused {

    require(msg.value >= boosters[_id].price);
    _mint(_to, _id, 1, "");

    emit BoosterBought(_id);
  }

  function withdraw(address _account) external onlyGovernance {

    (bool success, ) = _account.call{ value: address(this).balance, gas: 2300 }("");
    require(success);
  }

  function pause() external onlyGovernance {

    super._pause();
  }

  function unpause() external onlyGovernance {

    super._unpause();
  }

  function isApprovedForAll(address _account, address _operator) public view override returns (bool) {

    return super.isApprovedForAll(_account, _operator) || governance.isBoosterEscrow(_operator);
  }

  receive() external payable { }
}// "MIT"
pragma solidity 0.6.12;


contract BoosterEscrow is IERC1155Receiver {

  struct Boost {
    uint256 winIncrease;
    uint256 gasDecrease;
    uint256 price;
  }

  bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
  bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint...

  BoosterToken public boosterToken;
  mapping(address => uint256) public activeBoosters;

  event BoosterActivated(address indexed player, uint256 id);
  event BoosterDeactivated(address indexed player, uint256 id);

  constructor(address payable _boosterToken) public {
    require(_boosterToken != address(0x0), "Booster token should not be empty");
    boosterToken = BoosterToken(_boosterToken);
  }

  function activateBooster(uint256 _id) external {

    if (activeBoosters[msg.sender] != 0) {
      boosterToken.safeTransferFrom(address(this), msg.sender, activeBoosters[msg.sender], 1, "0x0");
    }
    boosterToken.safeTransferFrom(msg.sender, address(this), _id, 1, "0x0");
    activeBoosters[msg.sender] = _id;

    emit BoosterActivated(msg.sender, _id);
  }

  function deactivateBooster() external {

    require(activeBoosters[msg.sender] != 0, "Booster not activated");
    uint256 id = activeBoosters[msg.sender];
    activeBoosters[msg.sender] = 0;
    boosterToken.safeTransferFrom(address(this), msg.sender, id, 1, "0x0");

    emit BoosterActivated(msg.sender, id);
  }

  function activeBoosterId(address _account) external view returns (uint256) {

    return activeBoosters[_account];
  }

  function activeBooster(address _account) public view returns (uint256, uint256, uint256) {

    return boosterToken.getBooster(activeBoosters[_account]);
  }

  function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external override returns(bytes4) {

    return ERC1155_ACCEPTED;
  }

  function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external override returns(bytes4) {

    return ERC1155_BATCH_ACCEPTED;
  }

  function supportsInterface(bytes4 interfaceID) public override view returns (bool) {

    return interfaceID == 0x01ffc9a7 || interfaceID == 0x4e2312e0; // ERC165 // ERC1155_ACCEPTED ^ ERC1155_BATCH_ACCEPTED;
  }
}