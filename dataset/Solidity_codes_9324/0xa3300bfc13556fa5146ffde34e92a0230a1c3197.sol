


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}



pragma solidity ^0.6.8;

interface UsesMon {

  struct Mon {
      address summoner;

      uint256 parent1Id;

      uint256 parent2Id;

      address minterContract;

      uint256 contractOrder;

      uint256 gen;

      uint256 bits;

      uint256 exp;

      uint256 rarity;
  }
}



pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;



interface IMonMinter is IERC721, UsesMon {


  function mintMonster(address to,
                       uint256 parent1Id,
                       uint256 parent2Id,
                       address minterContract,
                       uint256 contractOrder,
                       uint256 gen,
                       uint256 bits,
                       uint256 exp,
                       uint256 rarity
                      ) external returns (uint256);


  function modifyMon(uint256 id,
                     bool ignoreZeros,
                     uint256 parent1Id,
                     uint256 parent2Id,
                     address minterContract,
                     uint256 contractOrder,
                     uint256 gen,
                     uint256 bits,
                     uint256 exp,
                     uint256 rarity
  ) external;


  function monRecords(uint256 id) external returns (Mon memory);


  function setTokenURI(uint256 id, string calldata uri) external;

}



pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}



pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;




abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.6.0;

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
}



pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.6.8;




abstract contract MonCreatorInstance is AccessControl {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  IERC20 public xmon;
  IMonMinter public monMinter;

  uint256 public maxMons;
  uint256 public numMons;

  string public prefixURI;

  modifier onlyAdmin {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not admin");
    _;
  }

  function updateNumMons() internal {
    require(numMons < maxMons, "All mons are out");
    numMons = numMons.add(1);
  }

  function setMaxMons(uint256 m) public onlyAdmin {
    maxMons = m;
  }

  function setPrefixURI(string memory prefix) public onlyAdmin {
    prefixURI = prefix;
  }
}



pragma solidity ^0.6.0;

library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}



pragma solidity ^0.6.8;

interface IDoomAdmin {

  function pendingDoom(address a) external view returns(uint256);

  function doomBalances(address a) external returns (uint256);

  function setDoomBalances(address a, uint256 d) external;

}



pragma solidity ^0.6.8;




contract MonStaker3 is MonCreatorInstance {


  using SafeMath for uint256;
  using Strings for uint256;
  using SafeERC20 for IERC20;

  bytes32 public constant STAKER_ADMIN_ROLE = keccak256("STAKER_ADMIN_ROLE");

  int128 public uriOffset;

  uint256 public claimMonStart;

  uint256 public maxDoomToMigrate;

  uint256 public lastMigrationDate;

  mapping(address => bool) public hasMigrated;

  IDoomAdmin public prevStaker;

  struct Stake {
    uint256 amount;
    uint256 startBlock;
  }
  mapping(address => Stake) public stakeRecords;

  uint256 public baseDoomFee;

  mapping(address => uint256) public doomBalances;

  uint256 public rarity;

  modifier onlyStakerAdmin {

    require(hasRole(STAKER_ADMIN_ROLE, msg.sender), "Not staker admin");
    _;
  }

  constructor(address xmonAddress, address monMinterAddress) public {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

    grantRole(STAKER_ADMIN_ROLE, msg.sender);

    rarity = 2;

    xmon = IERC20(xmonAddress);

    monMinter = IMonMinter(monMinterAddress);

    maxDoomToMigrate = 666 * (10**21);

    baseDoomFee = 2376 * (10**11);

    prefixURI = "mons2/";

    prevStaker = IDoomAdmin(0xD06337A401B468657dE2f9d3E390cE5b21C3c1C0);

    claimMonStart = 1617382800;
    lastMigrationDate = 1617382800;
  }

  function sqrt(uint y) public pure returns (uint z) {

    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
  }

  function addStake(uint256 amount) public {

    require(amount > 0, "Need to stake nonzero");

    awardDoom(msg.sender);

    uint256 newAmount = stakeRecords[msg.sender].amount.add(amount);

    stakeRecords[msg.sender] = Stake(
      newAmount,
      block.number
    );

    xmon.safeTransferFrom(msg.sender, address(this), amount);
  }

  function removeStake() public {

    awardDoom(msg.sender);
    emergencyRemoveStake();
  }

  function emergencyRemoveStake() public {

    uint256 amountToTransfer = stakeRecords[msg.sender].amount;

    delete stakeRecords[msg.sender];

    xmon.safeTransfer(msg.sender, amountToTransfer);
  }

  function awardDoom(address a) public {

    if (stakeRecords[a].amount != 0) {
      uint256 doomAmount = sqrt(stakeRecords[a].amount).mul(block.number.sub(stakeRecords[a].startBlock));
      doomBalances[a] = doomBalances[a].add(doomAmount);

      stakeRecords[a].startBlock = block.number;
    }
  }

  function claimMon() public returns (uint256) {

    require(block.timestamp >= claimMonStart, "Not time yet");

    awardDoom(msg.sender);

    require(doomBalances[msg.sender] >= baseDoomFee, "Not enough DOOM");
    super.updateNumMons();

    doomBalances[msg.sender] = doomBalances[msg.sender].sub(baseDoomFee);

    uint256 offsetMons = uriOffset < 0 ? numMons - uint256(uriOffset) : numMons + uint256(uriOffset);

    uint256 id = monMinter.mintMonster(
      msg.sender,
      0,
      0,
      address(0),
      offsetMons,
      1,
      0,
      0,
      rarity
    );
    string memory uri = string(abi.encodePacked(prefixURI, offsetMons.toString()));
    monMinter.setTokenURI(id, uri);

    return(id);
  }

  function migrateDoom() public {

    require(!hasMigrated[msg.sender], "Already migrated");
    require(block.timestamp <= lastMigrationDate, "Time limit up");
    uint256 totalDoom = prevStaker.pendingDoom(msg.sender) + prevStaker.doomBalances(msg.sender);
    if (totalDoom > maxDoomToMigrate) {
      totalDoom = maxDoomToMigrate;
    }
    totalDoom = (totalDoom*baseDoomFee)/maxDoomToMigrate;
    doomBalances[msg.sender] = totalDoom;
    hasMigrated[msg.sender] = true;
  }

  function setUriOffset(int128 o) public onlyAdmin {

    uriOffset = o;
  }

  function setLastMigrationDate(uint256 d) public onlyAdmin {

    lastMigrationDate = d;
  }

  function setMaxDoomToMigrate(uint256 m) public onlyAdmin {

    maxDoomToMigrate = m;
  }

  function setClaimMonStart(uint256 c) public onlyAdmin {

    claimMonStart = c;
  }

  function setRarity(uint256 r) public onlyAdmin {

    rarity = r;
  }

  function setBaseDoomFee(uint256 f) public onlyAdmin {

    baseDoomFee = f;
  }

  function setMonMinter(address a) public onlyAdmin {

    monMinter = IMonMinter(a);
  }

  function setPrevStaker(address a) public onlyAdmin {

    prevStaker = IDoomAdmin(a);
  }

  function setStakerAdminRole(address a) public onlyAdmin {

    grantRole(STAKER_ADMIN_ROLE, a);
  }

  function moveTokens(address tokenAddress, address to, uint256 numTokens) public onlyAdmin {

    require(tokenAddress != address(xmon), "Can't move XMON");
    IERC20 _token = IERC20(tokenAddress);
    _token.safeTransfer(to, numTokens);
  }

  function setDoomBalances(address a, uint256 d) public onlyStakerAdmin {

    doomBalances[a] = d;
  }

  function balanceOf(address a) public view returns(uint256) {

    return stakeRecords[a].amount;
  }

  function pendingDoom(address a) public view returns(uint256) {

    return(sqrt(stakeRecords[a].amount).mul(block.number.sub(stakeRecords[a].startBlock)));
  }
}