
pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


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
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.4.25 <0.7.0;


abstract contract Manageable is AccessControlUpgradeable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    modifier onlyManager() {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "Caller is not a manager role"
        );
        _;
    }

    function setupRole(bytes32 role, address account) external onlyManager {
        _setupRole(role, account);
    }

    function isManager() external view returns (bool) {
        return hasRole(MANAGER_ROLE, _msgSender());
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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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
}pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}// MIT

pragma solidity ^0.6.8;


contract AxionMine is Initializable, Manageable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Miner {
        uint256 lpDeposit;
        uint256 accReward;
    }

    struct Mine {
        IERC20 lpToken;
        IERC20 rewardToken;
        uint256 startBlock;
        uint256 lastRewardBlock;
        uint256 blockReward;
        uint256 accRewardPerLPToken;
        IERC721 liqRepNFT;
        IERC721 OG5555_25NFT;
        IERC721 OG5555_100NFT;
    }

    Mine public mineInfo;

    mapping(address => Miner) public minerInfo;

    event Deposit(address indexed minerAddress, uint256 lpTokenAmount);
    event Withdraw(address indexed minerAddress, uint256 lpTokenAmount);
    event WithdrawReward(
        address indexed minerAddress,
        uint256 rewardTokenAmount
    );

    modifier mineUpdater() {

        updateMine();
        _;
    }

    function updateMine() internal {

        if (block.number <= mineInfo.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = mineInfo.lpToken.balanceOf(address(this));

        if (lpSupply != 0) {
            mineInfo.accRewardPerLPToken = getAccRewardPerLPToken(lpSupply);
        }

        mineInfo.lastRewardBlock = block.number;
    }

    function getAccRewardPerLPToken(uint256 _lpSupply)
        internal
        view
        returns (uint256)
    {

        uint256 newBlocks = block.number.sub(mineInfo.lastRewardBlock);
        uint256 reward = newBlocks.mul(mineInfo.blockReward);

        return
            mineInfo.accRewardPerLPToken.add(reward.mul(1e12).div(_lpSupply));
    }

    function getAccReward(uint256 _lpDeposit) internal view returns (uint256) {

        return _lpDeposit.mul(mineInfo.accRewardPerLPToken).div(1e12);
    }

    function withdrawReward() external mineUpdater {

        Miner storage miner = minerInfo[msg.sender];

        uint256 accReward = getAccReward(miner.lpDeposit);

        uint256 reward = handleNFT(accReward.sub(miner.accReward));

        require(reward != 0, 'NOTHING_TO_WITHDRAW');

        safeRewardTransfer(reward);

        emit WithdrawReward(msg.sender, reward);

        miner.accReward = accReward;
    }

    function depositLPTokens(uint256 _amount) external mineUpdater {

        require(_amount != 0, 'ZERO_AMOUNT');

        Miner storage miner = minerInfo[msg.sender];

        uint256 reward = getReward(miner);

        if (reward != 0) {
            safeRewardTransfer(reward);
            emit WithdrawReward(msg.sender, reward);
        }

        mineInfo.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        emit Deposit(msg.sender, _amount);

        miner.lpDeposit = miner.lpDeposit.add(_amount);
        miner.accReward = getAccReward(miner.lpDeposit);
    }

    function withdrawLPTokens(uint256 _amount) external mineUpdater {

        Miner storage miner = minerInfo[msg.sender];

        require(miner.lpDeposit != 0, 'NOTHING_TO_WITHDRAW');
        require(miner.lpDeposit >= _amount, 'INVALID_AMOUNT');

        uint256 reward = getReward(miner);

        if (reward != 0) {
            safeRewardTransfer(reward);
            emit WithdrawReward(msg.sender, reward);
        }

        mineInfo.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _amount);

        miner.lpDeposit = miner.lpDeposit.sub(_amount);
        miner.accReward = getAccReward(miner.lpDeposit);
    }

    function withdrawAll() external mineUpdater {

        Miner storage miner = minerInfo[msg.sender];

        require(miner.lpDeposit != 0, 'NOTHING_TO_WITHDRAW');

        uint256 reward = getReward(miner);

        if (reward != 0) {
            safeRewardTransfer(reward);
            emit WithdrawReward(msg.sender, reward);
        }

        mineInfo.lpToken.safeTransfer(address(msg.sender), miner.lpDeposit);
        emit Withdraw(msg.sender, miner.lpDeposit);

        miner.lpDeposit = 0;
        miner.accReward = 0;
    }

    function safeRewardTransfer(uint256 _amount) internal {

        uint256 rewardBalance = mineInfo.rewardToken.balanceOf(address(this));
        if (rewardBalance == 0) return;

        if (_amount > rewardBalance) {
            mineInfo.rewardToken.transfer(msg.sender, rewardBalance);
        } else {
            mineInfo.rewardToken.transfer(msg.sender, _amount);
        }
    }

    function getReward(Miner storage miner) internal view returns (uint256) {

        return handleNFT(getAccReward(miner.lpDeposit).sub(miner.accReward));
    }

    function handleNFT(uint256 _amount) internal view returns (uint256) {

        uint256 penalty = _amount.div(10);

        if (mineInfo.liqRepNFT.balanceOf(msg.sender) == 0) {
            _amount = _amount.sub(penalty);
        }

        if (mineInfo.OG5555_25NFT.balanceOf(msg.sender) == 0) {
            _amount = _amount.sub(penalty);
        }

        if (mineInfo.OG5555_100NFT.balanceOf(msg.sender) == 0) {
            _amount = _amount.sub(penalty);
        }

        return _amount;
    }

    function transferRewardTokens(address _to) external onlyManager {

        uint256 rewardBalance = mineInfo.rewardToken.balanceOf(address(this));
        mineInfo.rewardToken.transfer(_to, rewardBalance);
    }

    constructor(address _mineManager) public {
        _setupRole(MANAGER_ROLE, _mineManager);
    }

    function initialize(
        address _rewardTokenAddress,
        uint256 _rewardTokenAmount,
        address _lpTokenAddress,
        uint256 _startBlock,
        uint256 _blockReward,
        address _liqRepNFTAddress,
        address _OG5555_25NFTAddress,
        address _OG5555_100NFTAddress
    ) public initializer {

        TransferHelper.safeTransferFrom(
            address(_rewardTokenAddress),
            msg.sender,
            address(this),
            _rewardTokenAmount
        );

        uint256 lastRewardBlock =
            block.number > _startBlock ? block.number : _startBlock;

        mineInfo = Mine(
            IERC20(_lpTokenAddress),
            IERC20(_rewardTokenAddress),
            _startBlock,
            lastRewardBlock,
            _blockReward,
            0,
            IERC721(_liqRepNFTAddress),
            IERC721(_OG5555_25NFTAddress),
            IERC721(_OG5555_100NFTAddress)
        );
    }

    function getPendingReward() external view returns (uint256) {

        uint256 rewardBalance = mineInfo.rewardToken.balanceOf(address(this));
        if (rewardBalance == 0) return 0;

        Miner storage miner = minerInfo[msg.sender];

        uint256 accRewardPerLPToken = mineInfo.accRewardPerLPToken;
        uint256 lpSupply = mineInfo.lpToken.balanceOf(address(this));

        if (block.number > mineInfo.lastRewardBlock && lpSupply != 0) {
            accRewardPerLPToken = getAccRewardPerLPToken(lpSupply);
        }

        return
            handleNFT(
                miner.lpDeposit.mul(accRewardPerLPToken).div(1e12).sub(
                    miner.accReward
                )
            );
    }
}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}// UNLICENSED

pragma solidity ^0.6.8;


contract AxionMineManager is Initializable, Manageable {

    address[] internal mineAddresses;

    IUniswapV2Factory internal uniswapFactory;

    address public rewardTokenAddress;
    address public liqRepNFTAddress;
    address public OG5555_25NFTAddress;
    address public OG5555_100NFTAddress;

    function createMine(
        address _lpTokenAddress,
        uint256 _rewardTokenAmount,
        uint256 _blockReward,
        uint256 _startBlock
    ) external onlyManager {

        require(_startBlock >= block.number, 'PAST_START_BLOCK');

        IUniswapV2Pair lpPair = IUniswapV2Pair(_lpTokenAddress);

        address lpPairAddress =
            uniswapFactory.getPair(lpPair.token0(), lpPair.token1());

        require(lpPairAddress == _lpTokenAddress, 'UNISWAP_PAIR_NOT_FOUND');

        TransferHelper.safeTransferFrom(
            rewardTokenAddress,
            msg.sender,
            address(this),
            _rewardTokenAmount
        );

        AxionMine mine = new AxionMine(msg.sender);

        TransferHelper.safeApprove(
            rewardTokenAddress,
            address(mine),
            _rewardTokenAmount
        );
        
        mine.initialize(
            rewardTokenAddress,
            _rewardTokenAmount,
            _lpTokenAddress,
            _startBlock,
            _blockReward,
            liqRepNFTAddress,
            OG5555_25NFTAddress,
            OG5555_100NFTAddress
        );

        mineAddresses.push(address(mine));
    }

    function deleteMine(uint256 index) external onlyManager {

        delete mineAddresses[index];
    }

    function initialize(
        address _manager,
        address _rewardTokenAddress,
        address _liqRepNFTAddress,
        address _OG5555_25NFTAddress,
        address _OG5555_100NFTAddress,
        address _uniswapFactoryAddress
    ) public initializer {

        _setupRole(MANAGER_ROLE, _manager);

        rewardTokenAddress = _rewardTokenAddress;
        liqRepNFTAddress = _liqRepNFTAddress;
        OG5555_25NFTAddress = _OG5555_25NFTAddress;
        OG5555_100NFTAddress = _OG5555_100NFTAddress;

        uniswapFactory = IUniswapV2Factory(_uniswapFactoryAddress);
    }

    function getMineAddresses() external view returns (address[] memory) {

        return mineAddresses;
    }
}