
pragma solidity >=0.7.0 <0.9.0;

interface IMuonV02 {

    struct SchnorrSign {
        uint256 signature;
        address owner;
        address nonce;
    }

    function verify(
        bytes calldata reqId,
        uint256 hash,
        SchnorrSign[] calldata _sigs
    ) external returns (bool);

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


interface IMRC1155 is IERC1155{


    function mint(address to, uint256 id, uint256 amount, bytes memory data) external;


    function burn(address user, uint256 id, uint256 amount) external;

    
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

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.0;



interface IBridgeToken is IMRC1155 {


}

contract MRC1155Bridge is AccessControl, IERC1155Receiver {

  
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  bytes32 public constant TOKEN_ADDER_ROLE = keccak256("TOKEN_ADDER");

  using ECDSA for bytes32;

  uint32 public constant APP_ID = 17;

  IMuonV02 public muon;

  uint256 public network;

  mapping(uint256 => address) public tokens;
  mapping(address => uint256) public ids;

  mapping(uint256 => bool) public mintable;

  event AddToken(address addr, uint256 tokenId, bool mintable);

  event Deposit(
    uint256 txId
  );

  event Claim(
    address indexed user,
    uint256 txId,
    uint256 fromChain
  );

  struct TX {
    uint256 tokenId;
    uint256[] ids;
    uint256[] amounts;
    uint256 toChain;
    address user;
  }
  uint256 public lastTxId = 0;

  mapping(uint256 => TX) public txs;
  
  mapping(uint256 => mapping(uint256 => bool)) public claimedTxs;

  uint256 public bridgeFee = 0.0006 ether;

  constructor(address _muon) {
    network = getCurrentChainID();
    muon = IMuonV02(_muon);
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ADMIN_ROLE, msg.sender);
  }

  function deposit(
    uint256[] calldata itemIds,
    uint256[] calldata amounts,
    uint256 toChain,
    uint256 tokenId
  ) public payable returns (uint256) {

    require(toChain != network, 'Self Deposit');
    require(tokens[tokenId] != address(0), '!tokenId');
    require(msg.value == bridgeFee, "!value");
    require(itemIds.length > 0, "!itemIds");
    require(itemIds.length == amounts.length, "amounts length != itemIds length");

    IBridgeToken token = IBridgeToken(tokens[tokenId]);
    
    if (mintable[tokenId]) {
      for (uint256 index = 0; index < itemIds.length; index++) {
        require(
          token.balanceOf(msg.sender, itemIds[index]) >= amounts[index],
          "!owner"
        );
        token.burn(address(msg.sender), itemIds[index], amounts[index]);
      }
    }else{
      for (uint256 index = 0; index < itemIds.length; index++) {
        require(
          token.balanceOf(msg.sender, itemIds[index]) >= amounts[index],
          "!owner"
        );
        token.safeTransferFrom(
          address(msg.sender),
          address(this),
          itemIds[index],
          amounts[index],
          '0x0'
        );
      }
    }

    uint256 txId = ++lastTxId;
    txs[txId] = TX({
      tokenId: tokenId,
      toChain: toChain,
      ids: itemIds,
      amounts: amounts,
      user: msg.sender
    });
    
    emit Deposit(txId);

    return txId;
  }


  function claim(
    uint256[] calldata itemIds,
    uint256[] calldata amounts,
    uint256[4] calldata txParams,
    bytes calldata _reqId,
    IMuonV02.SchnorrSign[] calldata _sigs
  ) public{

    claimFor(msg.sender, itemIds, amounts, txParams, _reqId, _sigs);
  }

  function claimFor(
    address user,
    uint256[] calldata itemIds,
    uint256[] calldata amounts,
    uint256[4] calldata txParams,
    bytes calldata _reqId,
    IMuonV02.SchnorrSign[] calldata _sigs
  ) public {



    require(!claimedTxs[txParams[0]][txParams[3]], 'already claimed');
    require(txParams[1] == network, '!network');
    require(_sigs.length > 0, '!sigs');
    require(itemIds.length == amounts.length, "amounts length != itemIds length");

    {
    bytes32 hash = keccak256(
      abi.encodePacked(
        abi.encodePacked(APP_ID),
        abi.encodePacked(txParams[3], txParams[2]),
        abi.encodePacked(txParams[0], txParams[1]),
        abi.encodePacked(user),
        abi.encodePacked(itemIds),
        abi.encodePacked(amounts)
      )
    );

    require(muon.verify(_reqId, uint256(hash), _sigs), '!verified');

    }

    IBridgeToken token = IBridgeToken(tokens[txParams[2]]);

    if (mintable[txParams[2]]) {
      for (uint256 index = 0; index < itemIds.length; index++) {
        token.mint(user, itemIds[index], amounts[index], '0x0');
      }
    } else {
      for (uint256 index = 0; index < itemIds.length; index++) {
        token.safeTransferFrom(address(this), user, itemIds[index], amounts[index], '0x0');
      }
    }

    claimedTxs[txParams[0]][txParams[3]] = true;
    emit Claim(user, txParams[3], txParams[0]);
  }

  function pendingTxs(uint256 fromChain, uint256[] calldata _ids)
    public
    view
    returns (bool[] memory unclaimedIds)
  {

    unclaimedIds = new bool[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
      unclaimedIds[i] = claimedTxs[fromChain][_ids[i]];
    }
  }

  function getTx(uint256 _txId)
    public
    view
    returns (
      uint256 txId,
      uint256 tokenId,
      uint256 fromChain,
      uint256 toChain,
      address user,
      address nftContract,
      uint256[] memory itemIds,
      uint256[] memory amounts
    )
  {

    txId = _txId;
    tokenId = txs[_txId].tokenId;
    fromChain = network;
    toChain = txs[_txId].toChain;
    user = txs[_txId].user;
    nftContract = tokens[tokenId];
    itemIds = txs[_txId].ids;
    amounts = txs[_txId].amounts;
  }

  function addToken(uint256 tokenId, address tokenAddress,
    bool _mintable)
        external
        onlyRole(TOKEN_ADDER_ROLE){


        require(ids[tokenAddress] == 0, 'already exist');

        tokens[tokenId] = tokenAddress;
        mintable[tokenId] = _mintable;

        ids[tokenAddress] = tokenId;

        emit AddToken(tokenAddress, tokenId, _mintable);
  }

  function removeToken(uint256 tokenId, address tokenAddress)
    external onlyRole(TOKEN_ADDER_ROLE){

    require(ids[tokenAddress] == tokenId, 'id!=addr');
    ids[tokenAddress] = 0;
    tokens[tokenId] = address(0);
  }

  function getTokenId(address _addr) public view returns (uint256) {

    return ids[_addr];
  }

  function getCurrentChainID() public view returns (uint256) {

    uint256 id;
    assembly {
      id := chainid()
    }
    return id;
  }

  function setNetworkID(uint256 _network) public onlyRole(ADMIN_ROLE) {

    network = _network;
  }

  function setBridgeFee(uint256 _val) public onlyRole(ADMIN_ROLE){

    bridgeFee = _val;
  }

  function setMuonContract(address _addr) public onlyRole(ADMIN_ROLE){

    muon = IMuonV02(_addr);
  }

  function adminWithdrawTokens(uint256 amount,
    address _to, address tokenAddress) public onlyRole(ADMIN_ROLE) {

    require(_to != address(0));
    if(tokenAddress == address(0)){
      payable(_to).transfer(amount);  
    }else{
      IERC20(tokenAddress).transfer(_to, amount);
    }
  }

  function emergencyWithdrawERC1155Tokens(
    address _tokenAddr,
    address _to,
    uint256 _id,
    uint256 _amount
  ) public onlyRole(ADMIN_ROLE) {

    IBridgeToken(_tokenAddr).safeTransferFrom(address(this), _to, _id, _amount, '0x0');
  }

  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes memory
  ) public virtual override returns(bytes4) {

    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address,
    address,
    uint256[] memory,
    uint256[] memory,
    bytes memory
  ) public virtual override returns(bytes4) {

    return this.onERC1155BatchReceived.selector;
  }
}