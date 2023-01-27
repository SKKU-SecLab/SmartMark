

pragma solidity ^0.5.0;

interface IERC721 /* is ERC165 */ {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "role already has the account");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "role dosen't have the account");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.5.0;


interface IERC173 /* is ERC165 */ {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address _newOwner) external;

}

contract ERC173 is IERC173, ERC165  {

    address private _owner;

    constructor() public {
        _registerInterface(0x7f5828d0);
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {

        require(msg.sender == owner(), "Must be owner");
        _;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner() {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        address previousOwner = owner();
	_owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
}


pragma solidity ^0.5.0;



contract Operatable is ERC173 {

    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;
    Roles.Role private operators;

    constructor() public {
        operators.add(msg.sender);
        _paused = false;
    }

    modifier onlyOperator() {

        require(isOperator(msg.sender), "Must be operator");
        _;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOperator() {

        _transferOwnership(_newOwner);
    }

    function isOperator(address account) public view returns (bool) {

        return operators.has(account);
    }

    function addOperator(address account) public onlyOperator() {

        operators.add(account);
        emit OperatorAdded(account);
    }

    function removeOperator(address account) public onlyOperator() {

        operators.remove(account);
        emit OperatorRemoved(account);
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    function pause() public onlyOperator() whenNotPaused() {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOperator() whenPaused() {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    function withdrawEther() public onlyOperator() {

        msg.sender.transfer(address(this).balance);
    }

}


pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {

        return this.onERC721Received.selector;
    }
}


pragma solidity ^0.5.0;




contract ERC721Converter is ERC721Holder, Operatable {

  IERC721 Alice;
  IERC721 Bob;

  address public aliceContract;
  address public bobContract;

  mapping (uint256 => uint256) private _idMapAliceToBob;
  mapping (uint256 => uint256) private _idMapBobToAlice;

  constructor(address _alice, address _bob) public {
    aliceContract = _alice;
    bobContract = _bob;
    Alice = IERC721(aliceContract);
    Bob = IERC721(bobContract);
  }

  function updateAlice(address _newAlice) external onlyOperator() {

    aliceContract = _newAlice;
    Alice = IERC721(_newAlice);
  }

  function updateBob(address _newBob) external onlyOperator() {

    bobContract = _newBob;
    Bob = IERC721(_newBob);
  }

  function draftAliceTokens(uint256[] memory _aliceTokenIds, uint256[] memory _bobTokenIds) public onlyOperator() {

    require(_aliceTokenIds.length == _bobTokenIds.length);
    for (uint256 i = 0; i < _aliceTokenIds.length; i++) {
      draftAliceToken(_aliceTokenIds[i], _bobTokenIds[i]);
    }
  }

  function draftBobTokens(uint256[] memory _bobTokenIds, uint256[] memory _aliceTokenIds) public onlyOperator() {

    require(_aliceTokenIds.length == _bobTokenIds.length);
    for (uint256 i = 0; i < _aliceTokenIds.length; i++) {
      draftBobToken(_bobTokenIds[i], _aliceTokenIds[i]);
    }
  }

  function draftAliceToken(uint256 _aliceTokenId, uint256 _bobTokenId) public onlyOperator() {

    require(Alice.ownerOf(_aliceTokenId) == address(this), "_aliceTokenId is not owned");
    require(_idMapAliceToBob[_aliceTokenId] == 0, "_aliceTokenId is already assignd");
    require(_idMapBobToAlice[_bobTokenId] == 0, "_bobTokenId is already assignd");

    _idMapAliceToBob[_aliceTokenId] = _bobTokenId;
    _idMapBobToAlice[_bobTokenId] = _aliceTokenId;
  }

  function draftBobToken(uint256 _bobTokenId, uint256 _aliceTokenId) public onlyOperator() {

    require(Bob.ownerOf(_bobTokenId) == address(this), "_bobTokenId is not owned");
    require(_idMapBobToAlice[_bobTokenId] == 0, "_bobTokenId is already assignd");
    require(_idMapAliceToBob[_aliceTokenId] == 0, "_aliceTokenId is already assignd");

    _idMapBobToAlice[_bobTokenId] = _aliceTokenId;
    _idMapAliceToBob[_aliceTokenId] = _bobTokenId;
  }

  function getBobTokenID(uint256 _aliceTokenId) public view returns(uint256) {

    return _idMapAliceToBob[_aliceTokenId];
  }

  function getAliceTokenID(uint256 _bobTokenId) public view returns(uint256) {

    return _idMapBobToAlice[_bobTokenId];
  }

  function convertFromAliceToBob(uint256 _tokenId) external whenNotPaused() {

    Alice.safeTransferFrom(msg.sender, address(this), _tokenId);
    Bob.safeTransferFrom(address(this), msg.sender, getBobTokenID(_tokenId));
  }

  function convertFromBobToAlice(uint256 _tokenId) external whenNotPaused() {

    Bob.safeTransferFrom(msg.sender, address(this), _tokenId);
    Alice.safeTransferFrom(address(this), msg.sender, getAliceTokenID(_tokenId));
  }
}