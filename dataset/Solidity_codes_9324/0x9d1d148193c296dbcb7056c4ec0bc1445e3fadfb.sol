
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
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
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
}// Unlicense

pragma solidity ^0.8.0;

interface INftStaking {

  enum PlanId {
    plan0monthsLock,
    plan1monthsLock,
    plan3monthsLock,
    plan6monthsLock
  }

  struct RewardPeriod {
    uint256 dailyReward;
    uint256 validFrom;
  }

  struct Plan {
    uint64 lockDuration;
    uint16 dailyRewardPercentage;
  }

  struct NFT {
    address nftContract;
    uint256 tokenId;
  }

  struct NFTWithPlanId {
    address nftContract;
    uint256 tokenId;
    PlanId planId;
  }

  struct NFTStake {
    address user;
    PlanId planId;
    uint64 stakedAt;
    uint64 unstakedAt;
    uint256 rewardClaimed;
  }

  struct UserNFTStake {
    address nftContract;
    uint256 tokenId;
    PlanId planId;
    uint64 stakedAt;
    uint64 unstakedAt;
    uint256 rewardClaimed;
  }

  struct WhitelistedContract {
    address contractAddress;
    RewardPeriod[] rewardPeriods;
  }

  event Staked(
    address indexed user,
    PlanId planId,
    address nftContract,
    uint256 tokenId
  );

  event Unstaked(
    address indexed user,
    PlanId planId,
    address nftContract,
    uint256 tokenId
  );

  event RewardClaimed(
    address indexed user,
    PlanId planId,
    address indexed nftContract,
    uint256 indexed tokenId,
    uint256 amount
  );

  event WithdrawAnnounced(uint256 timestamp);
  event WithdrawCancelled();
  event Withdrawn(uint256 amount);
}//Unlicense
pragma solidity 0.8.14;


contract NftStaking is INftStaking, IERC721Receiver, AccessControl {

  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;

  IERC20 private rewardToken;

  mapping(PlanId => Plan) private plans;
  EnumerableSet.AddressSet private whitelistedNFTs;
  mapping(address => RewardPeriod[]) private whitelistedNFTRewards;
  mapping(address => mapping(uint256 => NFTStake)) private stakes;

  mapping(address => mapping(address => EnumerableSet.UintSet))
    private userNFTs;

  uint256 private withdrawTimestamp;

  constructor(IERC20 _rewardToken, address _admin) {
    _initPlans();
    rewardToken = _rewardToken;

    _setupRole(DEFAULT_ADMIN_ROLE, _admin);
  }

  function getUserStakes(address user)
    external
    view
    returns (UserNFTStake[] memory nftStakes)
  {

    uint256 count;

    for (uint256 i = 0; i < whitelistedNFTs.length(); i++) {
      address nftContract = whitelistedNFTs.at(i);
      count += userNFTs[user][nftContract].length();
    }

    nftStakes = new UserNFTStake[](count);
    uint256 stakeIndex;

    for (uint256 i = 0; i < whitelistedNFTs.length(); i++) {
      address nftContract = whitelistedNFTs.at(i);
      for (uint256 j = 0; j < userNFTs[user][nftContract].length(); j++) {
        uint256 tokenId = userNFTs[user][nftContract].at(j);
        NFTStake memory nftStake = stakes[nftContract][tokenId];
        nftStakes[stakeIndex++] = UserNFTStake(
          nftContract,
          tokenId,
          nftStake.planId,
          nftStake.stakedAt,
          nftStake.unstakedAt,
          nftStake.rewardClaimed
        );
      }
    }

    return nftStakes;
  }

  function getWhitelistedContracts()
    external
    view
    returns (WhitelistedContract[] memory whitelistedContracts)
  {

    whitelistedContracts = new WhitelistedContract[](whitelistedNFTs.length());

    for (uint256 i = 0; i < whitelistedNFTs.length(); i++) {
      address nftContract = whitelistedNFTs.at(i);
      whitelistedContracts[i] = WhitelistedContract(
        nftContract,
        whitelistedNFTRewards[nftContract]
      );
    }

    return whitelistedContracts;
  }

  function stake(NFTWithPlanId[] calldata nfts) external {

    for (uint256 i = 0; i < nfts.length; i = unsafe_inc(i)) {
      _stake(nfts[i].nftContract, nfts[i].tokenId, nfts[i].planId);
    }
  }

  function getReward(NFT calldata nft) external view returns (uint256) {

    return _getReward(nft.nftContract, nft.tokenId);
  }

  function claimRewards(NFT[] calldata nfts) external {

    for (uint256 i = 0; i < nfts.length; i++) {
      _claimRewards(nfts[i].nftContract, nfts[i].tokenId);
    }
  }

  function unstake(NFT[] calldata nfts) external {

    for (uint256 i = 0; i < nfts.length; i++) {
      _unstake(nfts[i].nftContract, nfts[i].tokenId);
    }
  }

  function setDailyReward(address nftContract, uint256 dailyReward)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {

    whitelistedNFTs.add(nftContract);
    whitelistedNFTRewards[nftContract].push(
      RewardPeriod(dailyReward, block.timestamp)
    );
  }

  function announceWithdraw() external onlyRole(DEFAULT_ADMIN_ROLE) {

    require(withdrawTimestamp == 0, "Already announced");

    withdrawTimestamp = block.timestamp + 30 days;
    emit WithdrawAnnounced(withdrawTimestamp);
  }

  function cancelWithdraw() external onlyRole(DEFAULT_ADMIN_ROLE) {

    withdrawTimestamp = 0;
    emit WithdrawCancelled();
  }

  function withdraw(address recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {

    require(
      withdrawTimestamp > 0 && withdrawTimestamp < block.timestamp,
      "Can only withdraw 30 days after announcement"
    );

    uint256 amount = rewardToken.balanceOf(address(this));

    rewardToken.safeTransfer(recipient, amount);

    emit Withdrawn(amount);
  }


  function _stake(
    address nftContract,
    uint256 tokenId,
    PlanId planId
  ) private {

    require(
      whitelistedNFTs.contains(nftContract),
      "NFT contract not whitelisted"
    );

    IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);

    userNFTs[msg.sender][nftContract].add(tokenId);

    stakes[nftContract][tokenId] = NFTStake(
      msg.sender,
      planId,
      uint64(block.timestamp),
      0,
      0
    );

    emit Staked(msg.sender, planId, nftContract, tokenId);
  }

  function _getReward(address nftContract, uint256 tokenId)
    private
    view
    returns (uint256)
  {

    NFTStake storage nftStake = stakes[nftContract][tokenId];

    RewardPeriod[] memory rewardPeriods = whitelistedNFTRewards[nftContract];

    uint256 reward;

    for (uint256 i = 0; i < rewardPeriods.length; i = unsafe_inc(i)) {
      uint256 startTime = Math.max(
        nftStake.stakedAt,
        rewardPeriods[i].validFrom
      );

      uint256 endTime = i == rewardPeriods.length - 1
        ? block.timestamp
        : rewardPeriods[i + 1].validFrom;

      if (nftStake.unstakedAt > 0) {
        endTime = Math.min(nftStake.unstakedAt, endTime);
      }

      uint256 timeStaked = endTime - startTime;

      reward += ((timeStaked *
        rewardPeriods[i].dailyReward *
        plans[nftStake.planId].dailyRewardPercentage) / 100 days);
    }

    return reward - nftStake.rewardClaimed;
  }

  function _claimRewards(address nftContract, uint256 tokenId) private {

    NFTStake storage nftStake = stakes[nftContract][tokenId];

    require(nftStake.user == msg.sender, "Not owner of this NFT");

    uint256 amount = _getReward(nftContract, tokenId);

    nftStake.rewardClaimed += amount;

    rewardToken.safeTransfer(nftStake.user, amount);

    emit RewardClaimed(
      nftStake.user,
      nftStake.planId,
      nftContract,
      tokenId,
      amount
    );
  }

  function _unstake(address nftContract, uint256 tokenId) private {

    NFTStake storage nftStake = stakes[nftContract][tokenId];

    require(nftStake.user == msg.sender, "Not owner of this NFT");
    require(nftStake.unstakedAt == 0, "NFT already unstaked");
    require(
      nftStake.stakedAt + plans[nftStake.planId].lockDuration < block.timestamp,
      "Cannot unstake yet"
    );

    nftStake.unstakedAt = uint64(block.timestamp);

    userNFTs[msg.sender][nftContract].remove(tokenId);

    _claimRewards(nftContract, tokenId);

    IERC721(nftContract).safeTransferFrom(
      address(this),
      nftStake.user,
      tokenId
    );

    emit Unstaked(nftStake.user, nftStake.planId, nftContract, tokenId);
  }

  function _initPlans() private {

    plans[PlanId.plan0monthsLock] = Plan(0, 100);
    plans[PlanId.plan1monthsLock] = Plan(30 days, 115);
    plans[PlanId.plan3monthsLock] = Plan(90 days, 150);
    plans[PlanId.plan6monthsLock] = Plan(180 days, 200);
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {

    return this.onERC721Received.selector;
  }

  function unsafe_inc(uint256 n) private pure returns (uint256) {

    unchecked {
      return n + 1;
    }
  }
}