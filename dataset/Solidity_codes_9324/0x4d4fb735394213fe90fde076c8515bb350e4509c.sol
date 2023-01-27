
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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




contract MerkleVesting is Ownable {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    IERC20 public token;

    uint256 public MONTH = 30 days;
    uint256 public WEEK = 7 days;

    bytes32 public root;

    uint256 public startTimestamp;

    EnumerableSet.AddressSet private _users;

    mapping(address => uint256) claimed;

    mapping(string => uint256) public _roundToId;
    mapping(uint256 => string) public _idToRound;
    Setup[] public _setups;

    struct Factor {
        uint256 numerator;
        uint256 denominator;
    }

    struct Setup {
        uint256 lockPeriod;
        Factor amountOnUnlock;
        uint256 cliffPeriod;
        uint256 linearUnit;
        Factor amountPerUnit;
    }

    struct Allocations {
        string roundName;
        uint256 allocation;
    }

    event ChangeSetup(uint256 indexed timestamp, address indexed user, string round);
    event WithdrawToken(
        uint256 indexed timestamp,
        address indexed user,
        address token,
        uint256 amount
    );
    event ChangeToken(uint256 indexed timestamp, address indexed user, address newToken);
    event Start(uint256 indexed timestamp, address indexed user);
    event Claim(uint256 indexed timestamp, address indexed user, uint256 amount);
    event ChangeRoot(uint256 indexed timestamp, bytes32 newRoot, uint256 blockNumber);

    modifier isStarted() {

        require(startTimestamp != 0, 'Vesting have not started');
        _;
    }

    constructor(address token_, address owner_) {
        token = IERC20(token_);

        Setup memory setup;
        _setups.push(setup);
        setSetup(
            'private',
            Setup({
                lockPeriod: 0,
                amountOnUnlock: Factor(10, 100),
                cliffPeriod: 0,
                linearUnit: 2 * WEEK,
                amountPerUnit: Factor(375, 10000)
            })
        );
        setSetup(
            'ambassadors',
            Setup({
                lockPeriod: MONTH,
                amountOnUnlock: Factor(0, 100),
                cliffPeriod: 0,
                linearUnit: MONTH,
                amountPerUnit: Factor(277, 10000)
            })
        );
        setSetup(
            'team',
            Setup({
                lockPeriod: MONTH,
                amountOnUnlock: Factor(0, 100),
                cliffPeriod: 0,
                linearUnit: 2 * WEEK,
                amountPerUnit: Factor(104, 10000)
            })
        );
        setSetup(
            'opsdev',
            Setup({
                lockPeriod: MONTH,
                amountOnUnlock: Factor(0, 100),
                cliffPeriod: 0,
                linearUnit: 2 * WEEK,
                amountPerUnit: Factor(104, 10000)
            })
        );
        setSetup(
            'advisory',
            Setup({
                lockPeriod: MONTH,
                amountOnUnlock: Factor(0, 100),
                cliffPeriod: 0,
                linearUnit: 2 * WEEK,
                amountPerUnit: Factor(104, 10000)
            })
        );

        transferOwnership(owner_);
    }


    function claim(bytes32[] memory proof_, Allocations[] memory allocations_)
        external
        isStarted
    {

        bytes32 _leaf = keccak256(
            abi.encode(allocations_, keccak256(abi.encode(msg.sender)))
        );

        require(verify(proof_, root, _leaf), 'claim: verify in merkle tree failed');
        uint256 unclaimed_ = unclaimed(msg.sender, allocations_);
        require(unclaimed_ > 0, 'Nothing to claim');
        require(
            token.balanceOf(address(this)) >= unclaimed_,
            'Contract doesnt have enough tokens'
        );

        claimed[msg.sender] += unclaimed_;
        token.safeTransfer(msg.sender, unclaimed_);

        emit Claim(block.timestamp, msg.sender, unclaimed_);
    }

    function unclaimed(address user, Allocations[] memory allocations_)
        public
        view
        isStarted
        returns (uint256)
    {

        uint256 total = 0;
        uint256 allocationsLength = allocations_.length;
        for (uint256 i = 0; i < allocationsLength; i++) {
            total += unclaimedInRound(user, allocations_[i]);
        }

        return total - claimed[user];
    }

    function unclaimedInRound(address user, Allocations memory roundAllocation)
        public
        view
        isStarted
        returns (uint256)
    {

        uint256 roundId = _roundToId[roundAllocation.roundName];
        Setup memory setup = _setups[roundId];
        uint256 allocation = roundAllocation.allocation;
        if (setup.amountOnUnlock.denominator == 0) return 0;

        uint256 total = 0;
        uint256 timepassed = block.timestamp - startTimestamp;

        if (timepassed < setup.lockPeriod) return total;

        uint256 amountOnUnlock = (allocation * setup.amountOnUnlock.numerator) /
            (setup.amountOnUnlock.denominator);
        total += amountOnUnlock;

        if ((timepassed - setup.lockPeriod) < setup.cliffPeriod) return total;

        uint256 vestingTime = timepassed - setup.lockPeriod - setup.cliffPeriod;
        uint256 units = vestingTime / setup.linearUnit;
        uint256 vestingAmount = (allocation * units * setup.amountPerUnit.numerator) /
            (setup.amountPerUnit.denominator);

        total += vestingAmount;
        return total > allocation ? allocation : total;
    }


    function start() external onlyOwner {

        require(startTimestamp == 0, 'Vesting has been already started');
        startTimestamp = block.timestamp;
        emit Start(block.timestamp, msg.sender);
    }

    function setSetup(string memory round, Setup memory setup) public onlyOwner {

        if (_roundToId[round] == 0) {
            _roundToId[round] = _setups.length;
            _idToRound[_setups.length] = round;
            _setups.push(setup);
        } else {
            _setups[_roundToId[round]] = setup;
        }
        emit ChangeSetup(block.timestamp, msg.sender, round);
    }

    function setSetups(string[] memory rounds, Setup[] memory setups) external onlyOwner {

        require(rounds.length == setups.length, 'Size of names and setup must be same');
        uint256 length = rounds.length;
        for (uint256 i = 0; i < length; i++) {
            setSetup(rounds[i], setups[i]);
        }
    }

    function setRoot(bytes32 _root) public onlyOwner {

        root = _root;
        emit ChangeRoot(block.timestamp, _root, block.number);
    }

    function verify(
        bytes32[] memory proof,
        bytes32 _root,
        bytes32 leaf
    ) public pure returns (bool) {

        bytes32 hash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            hash = hash < proofElement
                ? keccak256(abi.encode(hash, proofElement))
                : keccak256(abi.encode(proofElement, hash));
        }
        return hash == _root;
    }

    function withdraw(IERC20 token_, uint256 amount) external onlyOwner {

        if (token_.balanceOf(address(this)) < amount)
            amount = token_.balanceOf(address(this));
        token_.safeTransfer(msg.sender, amount);

        emit WithdrawToken(block.timestamp, msg.sender, address(token_), amount);
    }

    function setToken(address token_) external onlyOwner {

        require(token_ != address(0), 'Token cant be zero address');
        require(token_ != address(token), 'New token cant be same');

        token = IERC20(token_);
        emit ChangeToken(block.timestamp, msg.sender, token_);
    }


    struct Info {
        address user;
        uint256 allocation;
        uint256 unclaimed;
        uint256 claimed;
    }

    function userInfo(address user, Allocations[] memory allocations_)
        external
        view
        returns (Info memory)
    {

        Info memory info;
        info.user = user;

        uint256 allocationsLength = allocations_.length;
        for (uint256 i = 0; i < allocationsLength; i++) {
            info.allocation += allocations_[i].allocation;
        }

        info.unclaimed = unclaimed(user, allocations_);
        info.claimed = claimed[user];

        return info;
    }
}