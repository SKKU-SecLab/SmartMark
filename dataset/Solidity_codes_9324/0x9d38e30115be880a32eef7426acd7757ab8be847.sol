
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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}pragma solidity ^0.6.0;


contract dANT is ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(uint256 initialSupply)
        public
        ERC20("Digital Antares Dollar", "dANT")
        AccessControl()
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _mint(0xE7de66EC6Fca05392Ade53E1A6c06779f029977a, initialSupply * 10**18);
    }

    function changeAdmin(address _newAdmin) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "changeAdmin: bad role"
        );
        _setupRole(DEFAULT_ADMIN_ROLE, _newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function mint(address _to, uint256 _amount) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "mint: bad role");
        _mint(_to, _amount);
    }
}pragma solidity ^0.6.0;


abstract contract Rewards is Ownable {
    using SafeMath for uint256;

    event Deposit(
        address indexed user,
        uint256 indexed id,
        uint256 amount,
        uint256 start,
        uint256 end
    );
    event Withdraw(
        address indexed user,
        uint256 indexed id,
        uint256 amount,
        uint256 time
    );
    event RewardPaid(address indexed user, uint256 amount);

    struct DepositInfo {
        uint256 amount; // Amount of deposited LP tokens
        uint256 time; // Wnen the deposit is ended
    }

    struct UserInfo {
        uint256 amount; // Total deposited amount
        uint256 unfrozen; // Amount of token to be unstaked
        uint256 reward; // Ammount of claimed rewards
        uint256 lastUpdate; // Last time the user claimed rewards
        uint256 depositHead; // The start index in the deposit's list
        uint256 depositTail; // The end index in the deposit's list
        mapping(uint256 => DepositInfo) deposits; // User's dposits
    }

    dANT public token; // Harvested token contract
    ReferralRewards public referralRewards; // Contract that manages referral rewards

    uint256 public duration; // How long the deposit works
    uint256 public rewardPerSec; // Reward rate generated each second
    uint256 public totalStake; // Amount of all staked LP tokens
    uint256 public totalClaimed; // Amount of all distributed rewards
    uint256 public lastUpdate; // Last time someone received rewards

    bool public isActive = true; // If the deposits are allowed

    mapping(address => UserInfo) public userInfo; // Info per each user

    constructor(
        dANT _token,
        uint256 _duration,
        uint256 _rewardPerSec
    ) public Ownable() {
        token = _token;
        duration = _duration;
        rewardPerSec = _rewardPerSec;
    }

    function setActive(bool _isActive) public onlyOwner {
        isActive = _isActive;
    }

    function setReferralRewards(ReferralRewards _referralRewards)
        public
        onlyOwner
    {
        referralRewards = _referralRewards;
    }

    function setDuration(uint256 _duration) public onlyOwner {
        duration = _duration;
    }

    function setRewardPerSec(uint256 _rewardPerSec) public onlyOwner {
        rewardPerSec = _rewardPerSec;
    }

    function stakeFor(address _user, uint256 _amount) public {
        require(
            referralRewards.getReferral(_user) != address(0),
            "stakeFor: referral isn't set"
        );
        proccessStake(_user, _amount, address(0));
    }

    function stake(uint256 _amount, address _refferal) public {
        proccessStake(msg.sender, _amount, _refferal);
    }

    function proccessStake(
        address _receiver,
        uint256 _amount,
        address _refferal
    ) internal {
        require(isActive, "stake: is paused");
        referralRewards.setReferral(_receiver, _refferal);
        referralRewards.claimAllDividends(_receiver);
        updateStakingReward(_receiver);
        if (_amount > 0) {
            token.transferFrom(msg.sender, address(this), _amount);
            UserInfo storage user = userInfo[_receiver];
            user.amount = user.amount.add(_amount);
            totalStake = totalStake.add(_amount);
            user.deposits[user.depositTail] = DepositInfo({
                amount: _amount,
                time: now + duration
            });
            emit Deposit(
                _receiver,
                user.depositTail,
                _amount,
                now,
                now + duration
            );
            user.depositTail = user.depositTail.add(1);
            referralRewards.assessReferalDepositReward(_receiver, _amount);
        }
    }

    function accumulateStakingReward(address _user)
        internal
        virtual
        returns (uint256 _reward)
    {
        UserInfo storage user = userInfo[_user];
        for (uint256 i = user.depositHead; i < user.depositTail; i++) {
            DepositInfo memory deposit = user.deposits[i];
            _reward = _reward.add(
                Math
                    .min(now, deposit.time)
                    .sub(user.lastUpdate)
                    .mul(deposit.amount)
                    .mul(rewardPerSec)
            );
            if (deposit.time < now) {
                referralRewards.claimAllDividends(_user);
                user.amount = user.amount.sub(deposit.amount);
                handleDepositEnd(_user, deposit.amount);
                delete user.deposits[i];
                user.depositHead = user.depositHead.add(1);
            }
        }
    }

    function updateStakingReward(address _user) internal virtual {
        UserInfo storage user = userInfo[_user];
        if (user.lastUpdate >= now) {
            return;
        }
        uint256 scaledReward = accumulateStakingReward(_user);
        uint256 reward = scaledReward.div(1e18);
        lastUpdate = now;
        user.reward = user.reward.add(reward);
        user.lastUpdate = now;
        if (reward > 0) {
            totalClaimed = totalClaimed.add(reward);
            token.mint(_user, reward);
            emit RewardPaid(_user, reward);
        }
    }

    function handleDepositEnd(address _user, uint256 _amount) internal virtual {
        totalStake = totalStake.sub(_amount);
        safeTokenTransfer(_user, _amount);
        emit Withdraw(_user, 0, _amount, now);
    }

    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            token.transfer(_to, tokenBal);
        } else {
            token.transfer(_to, _amount);
        }
    }

    function getPendingReward(address _user, bool _includeDeposit)
        public
        virtual
        view
        returns (uint256 _reward)
    {
        UserInfo storage user = userInfo[_user];
        for (uint256 i = user.depositHead; i < user.depositTail; i++) {
            DepositInfo memory deposit = user.deposits[i];
            _reward = _reward.add(
                Math
                    .min(now, deposit.time)
                    .sub(user.lastUpdate)
                    .mul(deposit.amount)
                    .mul(rewardPerSec)
                    .div(1e18)
            );
            if (_includeDeposit && deposit.time < now) {
                _reward = _reward.add(deposit.amount);
            }
        }
    }

    function getReward(address _user)
        public
        virtual
        view
        returns (uint256 _reward)
    {
        UserInfo storage user = userInfo[_user];
        _reward = user.reward;
        for (uint256 i = user.depositHead; i < user.depositTail; i++) {
            DepositInfo memory deposit = user.deposits[i];
            _reward = _reward.add(
                Math
                    .min(now, deposit.time)
                    .sub(user.lastUpdate)
                    .mul(deposit.amount)
                    .mul(rewardPerSec)
                    .div(1e18)
            );
        }
    }

    function getReferralStakes(address[] memory _referrals)
        public
        view
        returns (uint256[] memory _stakes)
    {
        _stakes = new uint256[](_referrals.length);
        for (uint256 i = 0; i < _referrals.length; i++) {
            _stakes[i] = userInfo[_referrals[i]].amount;
        }
    }

    function getReferralStake(address _referral) public view returns (uint256) {
        return userInfo[_referral].amount;
    }

    function getEstimated(uint256 _delta) public view returns (uint256) {
        return
            (now + _delta)
                .sub(lastUpdate)
                .mul(totalStake)
                .mul(rewardPerSec)
                .div(1e18);
    }

    function getDeposit(address _user, uint256 _id)
        public
        view
        returns (uint256, uint256)
    {
        DepositInfo memory deposit = userInfo[_user].deposits[_id];
        return (deposit.amount, deposit.time);
    }
}pragma solidity ^0.6.0;


contract ReferralTree is AccessControl {
    using SafeMath for uint256;

    event ReferralAdded(address indexed referrer, address indexed referral);

    bytes32 public constant REWARDS_ROLE = keccak256("REWARDS_ROLE"); // Role for those who allowed to mint new tokens

    mapping(address => address) public referrals; // Referral addresses for each referrer
    mapping(address => bool) public registered; // Map to ensure if the referrer is in the tree
    mapping(address => address[]) public referrers; // List of referrer addresses for each referral
    ReferralRewards[] public referralRewards; // Referral reward contracts that are allowed to modify the tree
    address public treeRoot; // The root of the referral tree

    constructor(address _treeRoot) public AccessControl() {
        treeRoot = _treeRoot;
        registered[_treeRoot] = true;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function changeAdmin(address _newAdmin) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "changeAdmin: bad role"
        );
        _setupRole(DEFAULT_ADMIN_ROLE, _newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function setReferral(address _referrer, address _referral) public {
        require(hasRole(REWARDS_ROLE, _msgSender()), "setReferral: bad role");
        require(_referrer != address(0), "setReferral: bad referrer");
        if (!registered[_referrer]) {
            require(
                registered[_referral],
                "setReferral: not registered referral"
            );
            referrals[_referrer] = _referral;
            registered[_referrer] = true;
            referrers[_referral].push(_referrer);
            emit ReferralAdded(_referrer, _referral);
        }
    }

    function removeReferralReward(ReferralRewards _referralRewards) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "setReferral: bad role"
        );
        for (uint256 i = 0; i < referralRewards.length; i++) {
            if (_referralRewards == referralRewards[i]) {
                uint256 lastIndex = referralRewards.length - 1;
                if (i != lastIndex) {
                    referralRewards[i] = referralRewards[lastIndex];
                }
                referralRewards.pop();
                revokeRole(REWARDS_ROLE, address(_referralRewards));
                break;
            }
        }
    }

    function addReferralReward(ReferralRewards _referralRewards) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "setReferral: bad role"
        );
        _setupRole(REWARDS_ROLE, address(_referralRewards));
        referralRewards.push(_referralRewards);
    }

    function claimAllDividends() public {
        for (uint256 i = 0; i < referralRewards.length; i++) {
            ReferralRewards referralReward = referralRewards[i];
            if (referralReward.getReferralReward(_msgSender()) > 0) {
                referralReward.claimAllDividends(_msgSender());
            }
        }
    }

    function getReferrals(address _referrer, uint256 _referDepth)
        public
        view
        returns (address[] memory)
    {
        address[] memory referralsTree = new address[](_referDepth);
        address referrer = _referrer;
        for (uint256 i = 0; i < _referDepth; i++) {
            referralsTree[i] = referrals[referrer];
            referrer = referralsTree[i];
        }
        return referralsTree;
    }

    function getReferrers(address _referral)
        public
        view
        returns (address[] memory)
    {
        return referrers[_referral];
    }

    function getUserReferralReward(address _user)
        public
        view
        returns (uint256)
    {
        uint256 amount = 0;
        for (uint256 i = 0; i < referralRewards.length; i++) {
            ReferralRewards referralReward = referralRewards[i];
            amount = amount.add(referralReward.getReferralReward(_user));
        }
        return amount;
    }

    function getReferralRewards()
        public
        view
        returns (ReferralRewards[] memory)
    {
        return referralRewards;
    }
}pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


contract ReferralRewards is Ownable {
    using SafeMath for uint256;

    event ReferralDepositReward(
        address indexed refferer,
        address indexed refferal,
        uint256 indexed level,
        uint256 amount
    );
    event ReferralRewardPaid(address indexed user, uint256 amount);

    struct DepositInfo {
        address referrer; // Address of refferer who made this deposit
        uint256 depth; // The level of the refferal
        uint256 amount; // Amount of deposited LP tokens
        uint256 time; // Wnen the deposit is ended
        uint256 lastUpdatedTime; // Last time the referral claimed reward from the deposit
    }
    struct ReferralInfo {
        uint256 reward; // Ammount of collected deposit rewards
        uint256 lastUpdate; // Last time the referral claimed rewards
        uint256 depositHead; // The start index in the deposit's list
        uint256 depositTail; // The end index in the deposit's list
        uint256[amtLevels] amounts; // Amounts that generate rewards on each referral level
        mapping(uint256 => DepositInfo) deposits; // Deposits that generate reward for the referral
    }

    uint256 public constant amtLevels = 3; // Number of levels by total staked amount that determine referral reward's rate
    uint256 public constant referDepth = 3; // Number of referral levels that can receive dividends

    dANT public token; // Harvested token contract
    ReferralTree public referralTree; // Contract with referral's tree
    Rewards rewards; // Main farming contract

    uint256[amtLevels] public depositBounds; // Limits of referral's stake used to determine the referral rate
    uint256[referDepth][amtLevels] public depositRate; // Referral rates based on referral's deplth and stake received from deposit
    uint256[referDepth][amtLevels] public stakingRate; // Referral rates based on referral's deplth and stake received from staking

    mapping(address => ReferralInfo) public referralReward; // Info per each referral

    constructor(
        dANT _token,
        ReferralTree _referralTree,
        Rewards _rewards,
        uint256[amtLevels] memory _depositBounds,
        uint256[referDepth][amtLevels] memory _depositRate,
        uint256[referDepth][amtLevels] memory _stakingRate
    ) public Ownable() {
        token = _token;
        referralTree = _referralTree;
        depositBounds = _depositBounds;
        depositRate = _depositRate;
        stakingRate = _stakingRate;
        rewards = _rewards;
    }

    function setBounds(uint256[amtLevels] memory _depositBounds)
        public
        onlyOwner
    {
        depositBounds = _depositBounds;
    }

    function setDepositRate(uint256[referDepth][amtLevels] memory _depositRate)
        public
        onlyOwner
    {
        depositRate = _depositRate;
    }

    function setStakingRate(uint256[referDepth][amtLevels] memory _stakingRate)
        public
        onlyOwner
    {
        stakingRate = _stakingRate;
    }

    function setReferral(address _referrer, address _referral) public {
        require(
            msg.sender == address(rewards),
            "assessReferalDepositReward: bad role"
        );
        referralTree.setReferral(_referrer, _referral);
    }

    function assessReferalDepositReward(address _referrer, uint256 _amount)
        external
        virtual
    {
        require(
            msg.sender == address(rewards),
            "assessReferalDepositReward: bad role"
        );
        address[] memory referrals = referralTree.getReferrals(
            _referrer,
            referDepth
        );
        uint256[] memory referralStakes = rewards.getReferralStakes(referrals);
        uint256[] memory percents = getDepositRate(referralStakes);
        for (uint256 level = 0; level < referrals.length; level++) {
            if (referrals[level] == address(0)) {
                continue;
            }


                ReferralInfo storage referralInfo
             = referralReward[referrals[level]];
            referralInfo.deposits[referralInfo.depositTail] = DepositInfo({
                referrer: _referrer,
                depth: level,
                amount: _amount,
                lastUpdatedTime: now,
                time: now + rewards.duration()
            });
            referralInfo.amounts[level] = referralInfo.amounts[level].add(
                _amount
            );
            referralInfo.depositTail = referralInfo.depositTail.add(1);
            if (percents[level] == 0) {
                continue;
            }
            uint256 depositReward = _amount.mul(percents[level]);
            if (depositReward > 0) {
                referralInfo.reward = referralInfo.reward.add(depositReward);
                emit ReferralDepositReward(
                    _referrer,
                    referrals[level],
                    level,
                    depositReward
                );
            }
        }
    }

    function claimDividends() public {
        claimUserDividends(msg.sender);
    }

    function claimAllDividends(address _referral) public {
        require(
            msg.sender == address(referralTree) ||
                msg.sender == address(rewards),
            "claimAllDividends: bad role"
        );
        claimUserDividends(_referral);
    }

    function removeDepositReward(address _referrer, uint256 _amount)
        external
        virtual
    {}

    function accumulateReward(address _user) internal virtual {
        ReferralInfo storage referralInfo = referralReward[_user];
        if (referralInfo.lastUpdate >= now) {
            return;
        }
        uint256 rewardPerSec = rewards.rewardPerSec();
        uint256 referralStake = rewards.getReferralStake(_user);
        uint256[referDepth] memory rates = getStakingRateRange(referralStake);
        for (
            uint256 i = referralInfo.depositHead;
            i < referralInfo.depositTail;
            i++
        ) {
            DepositInfo memory deposit = referralInfo.deposits[i];
            uint256 reward = Math
                .min(now, deposit.time)
                .sub(deposit.lastUpdatedTime)
                .mul(deposit.amount)
                .mul(rewardPerSec)
                .mul(rates[deposit.depth])
                .div(1e18);
            if (reward > 0) {
                referralInfo.reward = referralInfo.reward.add(reward);
            }
            referralInfo.deposits[i].lastUpdatedTime = now;
            if (deposit.time < now) {
                if (i != referralInfo.depositHead) {
                    referralInfo.deposits[i] = referralInfo
                        .deposits[referralInfo.depositHead];
                }
                delete referralInfo.deposits[referralInfo.depositHead];
                referralInfo.depositHead = referralInfo.depositHead.add(1);
            }
        }
        referralInfo.lastUpdate = now;
    }

    function claimUserDividends(address _user) internal {
        accumulateReward(_user);
        ReferralInfo storage referralInfo = referralReward[_user];
        uint256 amount = referralInfo.reward.div(1e18);
        if (amount > 0) {
            uint256 scaledReward = amount.mul(1e18);
            referralInfo.reward = referralInfo.reward.sub(scaledReward);
            token.mint(_user, amount);
            emit ReferralRewardPaid(_user, amount);
        }
    }

    function getReferralReward(address _user)
        external
        virtual
        view
        returns (uint256)
    {
        ReferralInfo storage referralInfo = referralReward[_user];
        uint256 rewardPerSec = rewards.rewardPerSec();
        uint256 referralStake = rewards.getReferralStake(_user);
        uint256[referDepth] memory rates = getStakingRateRange(referralStake);
        uint256 _reward = referralInfo.reward;
        for (
            uint256 i = referralInfo.depositHead;
            i < referralInfo.depositTail;
            i++
        ) {
            DepositInfo memory deposit = referralInfo.deposits[i];
            _reward = _reward.add(
                Math
                    .min(now, deposit.time)
                    .sub(deposit.lastUpdatedTime)
                    .mul(deposit.amount)
                    .mul(rewardPerSec)
                    .mul(rates[deposit.depth])
                    .div(1e18)
            );
        }
        return _reward.div(1e18);
    }

    function getReferral(address _user) public view returns (address) {
        return referralTree.referrals(_user);
    }

    function getStakingRateRange(uint256 _referralStake)
        public
        view
        returns (uint256[referDepth] memory _rates)
    {
        for (uint256 i = 0; i < depositBounds.length; i++) {
            if (_referralStake >= depositBounds[i]) {
                return stakingRate[i];
            }
        }
    }

    function getDepositRate(uint256[] memory _referralStakes)
        public
        view
        returns (uint256[] memory _rates)
    {
        _rates = new uint256[](_referralStakes.length);
        for (uint256 level = 0; level < _referralStakes.length; level++) {
            for (uint256 j = 0; j < depositBounds.length; j++) {
                if (_referralStakes[level] >= depositBounds[j]) {
                    _rates[level] = depositRate[j][level];
                    break;
                }
            }
        }
    }

    function getDepositBounds()
        public
        view
        returns (uint256[referDepth] memory)
    {
        return depositBounds;
    }

    function getStakingRates()
        public
        view
        returns (uint256[referDepth][amtLevels] memory)
    {
        return stakingRate;
    }

    function getDepositRates()
        public
        view
        returns (uint256[referDepth][amtLevels] memory)
    {
        return depositRate;
    }

    function getReferralAmounts(address _user)
        public
        view
        returns (uint256[amtLevels] memory)
    {
        ReferralInfo memory referralInfo = referralReward[_user];
        return referralInfo.amounts;
    }
}pragma solidity ^0.6.0;


contract ReferralRewardsType1 is ReferralRewards {
    constructor(
        dANT _token,
        ReferralTree _referralTree,
        Rewards _rewards,
        uint256[amtLevels] memory _depositBounds,
        uint256[referDepth][amtLevels] memory _depositRate,
        uint256[referDepth][amtLevels] memory _stakingRate
    )
        public
        ReferralRewards(
            _token,
            _referralTree,
            _rewards,
            _depositBounds,
            _depositRate,
            _stakingRate
        )
    {}
}