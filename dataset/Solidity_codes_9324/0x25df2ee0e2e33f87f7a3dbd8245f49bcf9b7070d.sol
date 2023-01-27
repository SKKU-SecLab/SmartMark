
pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.3;


interface IERC20UtilityToken is IERC20 {

  function mint(address to, uint256 amount) external;

  function burn(address account, uint256 amount) external;

}// MIT

pragma solidity ^0.8.3;



interface IRainiNft1155 is IERC1155 {

  
  struct TokenVars {
    uint128 cardId;
    uint32 level;
    uint32 number; // to assign a numbering to NFTs
    bytes1 mintedContractChar;
  }

  function maxTokenId() external view returns (uint256);


  function tokenVars(uint256 _tokenId) external view returns (TokenVars memory);

}

contract TLOLStakingPool is AccessControl, ERC1155Holder {

  
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  struct AccountRewardVars {
    uint32 lastUpdated;
    uint128 pointsBalance;
    uint64 totalStaked;
  }

  mapping(address => AccountRewardVars) public accountRewardVars;
  mapping(address => mapping(uint256 => uint256)) public stakedNFTs;

  mapping(uint256 => uint256) public cardStakingValues;

  uint256 public rewardEndTime;
  uint256 public rewardRate;
  address public nftContractAddress;
  IERC20UtilityToken public rewardToken;
  
  constructor(uint256 _rewardRate, uint256 _rewardEndTime, address _nftContractAddress, address rewardTokenAddress) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    rewardEndTime = _rewardEndTime;
    rewardRate = _rewardRate;
    nftContractAddress = _nftContractAddress;
    rewardToken = IERC20UtilityToken(rewardTokenAddress);
  }

  modifier onlyOwner() {

    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "caller is not an owner");
    _;
  }

  modifier onlyBurner() {

    require(hasRole(BURNER_ROLE, _msgSender()), "caller is not a burner");
    _;
  }

  modifier onlyMinter() {

    require(hasRole(MINTER_ROLE, _msgSender()), "caller is not a minter");
    _;
  }

  
  function balanceUpdate(address _owner, uint256 _valueStakedDiff, bool isSubtracted) internal {

    AccountRewardVars memory _rewardVars = accountRewardVars[_owner];

    if (lastTimeRewardApplicable() > _rewardVars.lastUpdated) {
      uint256 reward = calculateReward(_rewardVars.totalStaked, lastTimeRewardApplicable() - _rewardVars.lastUpdated);
      _rewardVars.pointsBalance += uint128(reward);
    }

    if (_valueStakedDiff != 0) {
      if (isSubtracted) {
        _rewardVars.totalStaked -=  uint64(_valueStakedDiff);
      } else {
        _rewardVars.totalStaked +=  uint64(_valueStakedDiff);
      }
    }
    
    _rewardVars.lastUpdated = uint32(block.timestamp);

    accountRewardVars[_owner] = _rewardVars;
  }

  function getStaked(address _owner) 
    public view returns(uint256) {

      return accountRewardVars[_owner].totalStaked;
  }

  function getStakedTokens(address _address, uint256 _cardCount) 
    external view returns (uint256[][] memory amounts) {

      IRainiNft1155 tokenContract = IRainiNft1155(nftContractAddress);

      uint256[][] memory _amounts = new uint256[][](tokenContract.maxTokenId() - 1000000 + _cardCount);
      uint256 count;
      for (uint256 i = 1; i <= tokenContract.maxTokenId(); i++) {
        uint128 cardId = tokenContract.tokenVars(i).cardId;
        if (cardId == 0 && i < 1000001) {
          i = 1000001;
        }
        uint256 balance = stakedNFTs[_address][i];
        if (balance != 0) {
          _amounts[count] = new uint256[](2);
          _amounts[count][0] = i;
          _amounts[count][1] = balance;
          count++;
        }
      }

      uint256[][] memory _amounts2 = new uint256[][](count);
      for (uint256 i = 0; i < count; i++) {
        _amounts2[i] = new uint256[](2);
        _amounts2[i][0] = _amounts[i][0];
        _amounts2[i][1] = _amounts[i][1];
      }

      return _amounts2;
  }
  
  function balanceOf(address _owner)
    public view returns(uint256) {

      uint256 reward = 0;
      if (lastTimeRewardApplicable() > accountRewardVars[_owner].lastUpdated) {
        reward = calculateReward(accountRewardVars[_owner].totalStaked, lastTimeRewardApplicable() - accountRewardVars[_owner].lastUpdated);
      }
      return accountRewardVars[_owner].pointsBalance + reward;
  }

  function setReward(uint256 _rewardRate)
    external onlyOwner {

      rewardRate = _rewardRate;
  }

  function setRewardEndTime(uint256 _rewardEndTime)
    external onlyOwner {

    rewardEndTime = _rewardEndTime;
  }

  function setCardStakingValues(uint256[] memory _cardIds, uint256[] memory _values)
    external onlyOwner {

      for (uint256 i = 0; i < _cardIds.length; i++) {
        cardStakingValues[_cardIds[i]] = _values[i];
      }
  }

  function lastTimeRewardApplicable() public view returns (uint256) {

    return Math.min(block.timestamp, rewardEndTime);
  }

  function stake(uint256[] memory _tokenId, uint256[] memory _amount)
    external {


      uint256 addedStakingValue = 0;

      for (uint256 i = 0; i < _tokenId.length; i++) {

        IRainiNft1155 tokenContract = IRainiNft1155(nftContractAddress);

        uint128 cardId = tokenContract.tokenVars(_tokenId[i]).cardId;

        addedStakingValue += cardStakingValues[cardId] * _amount[i];

        tokenContract.safeTransferFrom(_msgSender(), address(this), _tokenId[i], _amount[i], bytes('0x0'));

        stakedNFTs[_msgSender()][_tokenId[i]] += _amount[i];
      }

      balanceUpdate(_msgSender(), addedStakingValue, false);
  }
  
  function unstake(uint256[] memory _tokenId, uint256[] memory _amount)
    external {


      uint256 subtractedStakingValue = 0;

      for (uint256 i = 0; i < _tokenId.length; i++) {

        require(stakedNFTs[_msgSender()][_tokenId[i]] >= _amount[i], 'not enough supply');

        IRainiNft1155 tokenContract = IRainiNft1155(nftContractAddress);

        uint128 cardId = tokenContract.tokenVars(_tokenId[i]).cardId;

        subtractedStakingValue += cardStakingValues[cardId] * _amount[i];

        tokenContract.safeTransferFrom(address(this), _msgSender(), _tokenId[i], _amount[i], bytes('0x0'));

        stakedNFTs[_msgSender()][_tokenId[i]] -= _amount[i];
      }

      balanceUpdate(_msgSender(), subtractedStakingValue, true);
  }
  
  function mint(address[] calldata _addresses, uint256[] calldata _points) 
    external onlyMinter {

      for (uint256 i = 0; i < _addresses.length; i++) {
        accountRewardVars[_addresses[i]].pointsBalance += uint128(_points[i]);
      }
  }
  
  function burn(address _owner, uint256 _amount) 
    external onlyBurner {

      balanceUpdate(_owner, 0, false);
      accountRewardVars[_owner].pointsBalance -= uint128(_amount);
  }
    
  function calculateReward(uint256 _amount, uint256 _duration) 
    private view returns(uint256) {

      return _duration * rewardRate * _amount;
  }

  function withdrawReward(uint256 _amount) 
    external {

      balanceUpdate(_msgSender(), 0, false);
      accountRewardVars[_msgSender()].pointsBalance -= uint128(_amount);
      rewardToken.mint(_msgSender(), _amount);
  }

  function supportsInterface(bytes4 interfaceId) 
    public virtual override(ERC1155Receiver, AccessControl) view returns (bool) {

        return interfaceId == type(IERC1155Receiver).interfaceId
            || interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
  }

}