pragma solidity 0.8.4;

interface IVeBend {

    struct Point {
        int256 bias;
        int256 slope;
        uint256 ts;
        uint256 blk;
    }

    struct LockedBalance {
        int256 amount;
        uint256 end;
    }

    event Deposit(
        address indexed provider,
        address indexed beneficiary,
        uint256 value,
        uint256 indexed locktime,
        uint256 _type,
        uint256 ts
    );
    event Withdraw(address indexed provider, uint256 value, uint256 ts);

    event Supply(uint256 prevSupply, uint256 supply);

    function createLock(uint256 _value, uint256 _unlockTime) external;


    function createLockFor(
        address _beneficiary,
        uint256 _value,
        uint256 _unlockTime
    ) external;


    function increaseAmount(uint256 _value) external;


    function increaseAmountFor(address _beneficiary, uint256 _value) external;


    function increaseUnlockTime(uint256 _unlockTime) external;


    function checkpointSupply() external;


    function withdraw() external;


    function getLocked(address _addr) external returns (LockedBalance memory);


    function getUserPointEpoch(address _userAddress)
        external
        view
        returns (uint256);


    function epoch() external view returns (uint256);


    function getUserPointHistory(address _userAddress, uint256 _index)
        external
        view
        returns (Point memory);


    function getSupplyPointHistory(uint256 _index)
        external
        view
        returns (Point memory);

}// agpl-3.0
pragma solidity 0.8.4;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;


    function approve(address, uint256) external returns (bool);


    function transfer(address, uint256) external returns (bool);


    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);


    function balanceOf(address) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface ILendPool {

    function withdraw(
        address reserve,
        uint256 amount,
        address to
    ) external returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface IFeeDistributor {

    event Distributed(uint256 time, uint256 tokenAmount);

    event Claimed(
        address indexed recipient,
        uint256 amount,
        uint256 claimEpoch,
        uint256 maxEpoch
    );

    function lastDistributeTime() external view returns (uint256);


    function distribute() external;


    function claim(bool weth) external returns (uint256);


    function claimable(address _addr) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface ILendPoolAddressesProvider {

    function getLendPool() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
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
}// agpl-3.0
pragma solidity 0.8.4;


contract FeeDistributor is
    IFeeDistributor,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;
    uint256 public constant WEEK = 7 * 86400;
    uint256 public constant TOKEN_CHECKPOINT_DEADLINE = 86400;

    uint256 public startTime;
    uint256 public timeCursor;
    mapping(address => uint256) public timeCursorOf;
    mapping(address => uint256) public userEpochOf;

    uint256 public override lastDistributeTime;
    mapping(uint256 => uint256) public tokensPerWeek;
    uint256 public tokenLastBalance;

    mapping(uint256 => uint256) public veSupply; // VE total supply at week bounds

    mapping(address => uint256) public totalClaimed;

    IVeBend public veBEND;
    IWETH public WETH;
    ILendPoolAddressesProvider public addressesProvider;
    address public token;
    address public bendCollector;

    function initialize(
        IWETH _weth,
        address _tokenAddress,
        IVeBend _veBendAddress,
        ILendPoolAddressesProvider _addressesProvider,
        address _bendCollector
    ) external initializer {

        __Ownable_init();
        __ReentrancyGuard_init();
        addressesProvider = _addressesProvider;
        veBEND = _veBendAddress;
        WETH = _weth;
        bendCollector = _bendCollector;
        token = _tokenAddress;

        uint256 t = (block.timestamp / WEEK) * WEEK;
        startTime = t;
        lastDistributeTime = t;
        timeCursor = t;
    }

    function _checkpointDistribute() internal {

        uint256 tokenBalance = IERC20Upgradeable(token).balanceOf(
            address(this)
        );

        uint256 toDistribute = tokenBalance - tokenLastBalance;

        tokenLastBalance = tokenBalance;
        uint256 t = lastDistributeTime;
        uint256 sinceLast = block.timestamp - t;
        lastDistributeTime = block.timestamp;

        uint256 thisWeek = (t / WEEK) * WEEK;
        uint256 nextWeek = 0;
        for (uint256 i = 0; i < 52; i++) {
            nextWeek = thisWeek + WEEK;
            if (block.timestamp < nextWeek) {
                if (sinceLast == 0 && block.timestamp == t) {
                    tokensPerWeek[thisWeek] += toDistribute;
                } else {
                    tokensPerWeek[thisWeek] +=
                        (toDistribute * (block.timestamp - t)) /
                        sinceLast;
                }
                break;
            } else {
                if (sinceLast == 0 && nextWeek == t) {
                    tokensPerWeek[thisWeek] += toDistribute;
                } else {
                    tokensPerWeek[thisWeek] +=
                        (toDistribute * (nextWeek - t)) /
                        sinceLast;
                }
            }
            t = nextWeek;
            thisWeek = nextWeek;
        }

        emit Distributed(block.timestamp, toDistribute);
    }


    function distribute() external override {

        _checkpointTotalSupply();
        _distribute();
    }

    function _distribute() internal {

        uint256 amount = IERC20Upgradeable(token).balanceOf(bendCollector);
        if (amount > 0) {
            IERC20Upgradeable(token).safeTransferFrom(
                bendCollector,
                address(this),
                amount
            );
        }
        _checkpointDistribute();
    }

    function checkpointTotalSupply() external {

        _checkpointTotalSupply();
    }

    function _checkpointTotalSupply() internal {

        uint256 t = timeCursor;
        uint256 roundedTimestamp = (block.timestamp / WEEK) * WEEK;
        veBEND.checkpointSupply();

        for (uint256 i = 0; i < 52; i++) {
            if (t > roundedTimestamp) {
                break;
            } else {
                uint256 epoch = _findTimestampEpoch(t);
                IVeBend.Point memory pt = veBEND.getSupplyPointHistory(epoch);
                int256 dt = 0;
                if (t > pt.ts) {
                    dt = int256(t - pt.ts);
                }
                int256 _veSupply = pt.bias - pt.slope * dt;
                veSupply[t] = 0;
                if (_veSupply > 0) {
                    veSupply[t] = uint256(_veSupply);
                }
            }
            t += WEEK;
        }

        timeCursor = t;
    }

    function _findTimestampEpoch(uint256 _timestamp)
        internal
        view
        returns (uint256)
    {

        uint256 _min = 0;
        uint256 _max = veBEND.epoch();
        for (uint256 i = 0; i < 128; i++) {
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 2) / 2;
            IVeBend.Point memory pt = veBEND.getSupplyPointHistory(_mid);
            if (pt.ts <= _timestamp) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }
        return _min;
    }

    function _findTimestampUserEpoch(
        address _user,
        uint256 _timestamp,
        uint256 _maxUserEpoch
    ) internal view returns (uint256) {

        uint256 _min = 0;
        uint256 _max = _maxUserEpoch;
        for (uint256 i = 0; i < 128; i++) {
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 2) / 2;
            IVeBend.Point memory pt = veBEND.getUserPointHistory(_user, _mid);
            if (pt.ts <= _timestamp) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }
        return _min;
    }

    struct Claimable {
        uint256 amount;
        uint256 userEpoch;
        uint256 maxUserEpoch;
        uint256 weekCursor;
    }

    function _claimable(address _addr, uint256 _lastDistributeTime)
        internal
        view
        returns (Claimable memory)
    {

        uint256 roundedTimestamp = (_lastDistributeTime / WEEK) * WEEK;
        uint256 userEpoch = 0;
        uint256 toDistribute = 0;

        uint256 maxUserEpoch = veBEND.getUserPointEpoch(_addr);
        if (maxUserEpoch == 0) {
            return Claimable(0, 0, 0, 0);
        }
        uint256 weekCursor = timeCursorOf[_addr];
        if (weekCursor == 0) {
            userEpoch = _findTimestampUserEpoch(_addr, startTime, maxUserEpoch);
        } else {
            userEpoch = userEpochOf[_addr];
        }

        if (userEpoch == 0) {
            userEpoch = 1;
        }

        IVeBend.Point memory userPoint = veBEND.getUserPointHistory(
            _addr,
            userEpoch
        );

        if (weekCursor == 0) {
            weekCursor = ((userPoint.ts + WEEK - 1) / WEEK) * WEEK;
        }

        if (weekCursor >= roundedTimestamp) {
            return Claimable(0, userEpoch, maxUserEpoch, weekCursor);
        }

        if (weekCursor < startTime) {
            weekCursor = startTime;
        }
        IVeBend.Point memory oldUserPoint;

        for (uint256 i = 0; i < 52; i++) {
            if (weekCursor >= roundedTimestamp) {
                break;
            }
            if (weekCursor >= userPoint.ts && userEpoch <= maxUserEpoch) {
                userEpoch += 1;
                oldUserPoint = userPoint;
                if (userEpoch > maxUserEpoch) {
                    IVeBend.Point memory emptyPoint;
                    userPoint = emptyPoint;
                } else {
                    userPoint = veBEND.getUserPointHistory(_addr, userEpoch);
                }
            } else {
                int256 dt = int256(weekCursor - oldUserPoint.ts);
                int256 _balanceOf = oldUserPoint.bias - dt * oldUserPoint.slope;
                uint256 balanceOf = 0;
                if (_balanceOf > 0) {
                    balanceOf = uint256(_balanceOf);
                }
                if (balanceOf == 0 && userEpoch > maxUserEpoch) {
                    break;
                }
                uint256 _veSupply = veSupply[weekCursor];
                if (balanceOf > 0 && _veSupply > 0) {
                    toDistribute +=
                        (balanceOf * tokensPerWeek[weekCursor]) /
                        _veSupply;
                }

                weekCursor += WEEK;
            }
        }

        userEpoch = Math.min(maxUserEpoch, userEpoch - 1);
        return Claimable(toDistribute, userEpoch, maxUserEpoch, weekCursor);
    }

    function claimable(address _addr) external view override returns (uint256) {

        return _claimable(_addr, lastDistributeTime).amount;
    }

    function claim(bool weth) external override nonReentrant returns (uint256) {

        address _sender = msg.sender;

        if (block.timestamp >= timeCursor) {
            _checkpointTotalSupply();
        }

        if (block.timestamp > lastDistributeTime + TOKEN_CHECKPOINT_DEADLINE) {
            _distribute();
        }

        Claimable memory _st_claimable = _claimable(
            _sender,
            lastDistributeTime
        );

        uint256 amount = _st_claimable.amount;
        userEpochOf[_sender] = _st_claimable.userEpoch;
        timeCursorOf[_sender] = _st_claimable.weekCursor;

        if (amount != 0) {
            tokenLastBalance -= amount;
            if (weth) {
                _getLendPool().withdraw(address(WETH), amount, _sender);
            } else {
                _getLendPool().withdraw(address(WETH), amount, address(this));
                WETH.withdraw(amount);
                _safeTransferETH(_sender, amount);
            }
            totalClaimed[_sender] += amount;
            emit Claimed(
                _sender,
                amount,
                _st_claimable.userEpoch,
                _st_claimable.maxUserEpoch
            );
        }

        return amount;
    }

    function _getLendPool() internal view returns (ILendPool) {

        return ILendPool(addressesProvider.getLendPool());
    }

    function _safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "ETH_TRANSFER_FAILED");
    }

    receive() external payable {
        require(msg.sender == address(WETH), "Receive not allowed");
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}