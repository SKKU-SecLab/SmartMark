
pragma solidity 0.5.12;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgValue() internal view returns (uint256) {

        return msg.value;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {



        require(address(token).isContract());

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract EternalStorage is Ownable {

    uint256 internal _usersCount;

    uint256 internal _depositsCount;

    uint256 internal _swapsCount;

    address internal _ethAssetIdentificator = address(0);

    struct OrderDetails {
        bool created;
        address asset;
        uint256 amount;
        bool withdrawn;
        uint256 initTimestamp;
    }

    struct User {
        bool exist;
        uint256 index;
        mapping(uint256 => uint256) orderIdByIndex;
        mapping(uint256 => OrderDetails) orders;
    }

    struct Swap {
        uint256 initTimestamp;
        uint256 refundTimestamp;
        bytes32 secretHash;
        bytes32 secret;
        address initiator;
        address recipient;
        address asset;
        uint256 amount;
        uint256 orderId;
        State state;
    }

    struct Initiator {
        uint256 index;
        uint256 filledSwaps;
        mapping(uint256 => bytes32) swaps;
    }

    struct SwapTimeLimits {
        uint256 min;
        uint256 max;
    }

    mapping(address => User) internal _users;

    mapping(uint256 => address) internal _usersById;

    mapping(uint256 => bytes32) internal _swapsById;

    mapping(uint256 => uint256) internal _depositsById;

    mapping(bytes32 => Swap) internal _swaps;

    mapping(address => Initiator) internal _initiators;

    enum State { Empty, Filled, Redeemed, Refunded }

    enum SwapType { ETH, Token }

    SwapTimeLimits internal _swapTimeLimits = SwapTimeLimits(10 minutes, 180 days);


    function changeSwapLifetimeLimits(
        uint256 newMin,
        uint256 newMax
    ) external onlyOwner {

        require(newMin != 0, "changeSwapLifetimeLimits: newMin and newMax should be bigger then 0");
        require(newMax >= newMin, "changeSwapLifetimeLimits: the newMax should be bigger then newMax");

        _swapTimeLimits = SwapTimeLimits(newMin * 1 minutes, newMax * 1 minutes);
    }
}

contract Proxy is EternalStorage {

	function () payable external {
		_fallback();
	}

	function _fallback() internal {

		_willFallback();
		_delegate(_implementation());
	}

	function _willFallback() internal {}


	function _delegate(address implementation) internal {

		assembly {
			calldatacopy(0, 0, calldatasize)

			let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

			returndatacopy(0, 0, returndatasize)

			switch result
			case 0 { revert(0, returndatasize) }
			default { return(0, returndatasize) }
		}
  	}

	function _implementation() internal view returns (address);

}

contract BaseUpgradeabilityProxy is Proxy {

	using Address for address;

    string internal _version;

	bytes32 internal constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

	event Upgraded(address indexed implementation);

	function _implementation() internal view returns (address impl) {

		bytes32 slot = IMPLEMENTATION_SLOT;
		assembly {
		    impl := sload(slot)
		}
	}

	function _upgradeTo(address newImplementation, string memory newVersion) internal {

		_setImplementation(newImplementation, newVersion);

		emit Upgraded(newImplementation);
	}

	function _setImplementation(address newImplementation, string memory newVersion) internal {

		require(newImplementation.isContract(), "Cannot set a proxy implementation to a non-contract address");

 		_version = newVersion;

		bytes32 slot = IMPLEMENTATION_SLOT;

		assembly {
		    sstore(slot, newImplementation)
		}
	}
}

contract UpgradeabilityProxy is BaseUpgradeabilityProxy {

	constructor(address _logic) public payable {
		assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));
		_setImplementation(_logic, '1.0.0');
	}
}

contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {

	event AdminChanged(address previousAdmin, address newAdmin);

  	bytes32 internal constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

	modifier ifAdmin() {

		if (msg.sender == _admin()) {
		    _;
		} else {
		    _fallback();
		}
	}

	function admin() external view returns (address) {

		return _admin();
	}

	function version() external view returns (string memory) {

		return _version;
	}

	function implementation() external view returns (address) {

		return _implementation();
	}

	function changeAdmin(address newAdmin) external ifAdmin {

		require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
		emit AdminChanged(_admin(), newAdmin);
		_setAdmin(newAdmin);
	}

	function upgradeTo(address newImplementation, string calldata newVersion) external ifAdmin {

		_upgradeTo(newImplementation, newVersion);
	}

	function upgradeToAndCall(address newImplementation, string calldata newVersion, bytes calldata data) payable external ifAdmin {

		_upgradeTo(newImplementation, newVersion);
		(bool success,) = newImplementation.delegatecall(data);
		require(success);
	}

	function _admin() internal view returns (address adm) {

		bytes32 slot = ADMIN_SLOT;
		assembly {
    		adm := sload(slot)
		}
	}

	function _setAdmin(address newAdmin) internal {

		bytes32 slot = ADMIN_SLOT;

		assembly {
			sstore(slot, newAdmin)
		}
	}

	function _willFallback() internal {

		require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
		super._willFallback();
	}
}

contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {

	constructor(address _logic, address _admin) UpgradeabilityProxy(_logic) public payable {
		assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));
		_setAdmin(_admin);
	}
}

contract AssetsValue is EternalStorage {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    modifier orderIdNotExist(
        uint256 orderId,
        address user
    ) {

        require(_getOrderDetails(orderId, user).created == false, "orderIdNotExist: user already deposit this orderId");
        _;
    }

    event AssetDeposited(uint256 orderId, address indexed user, address indexed asset, uint256 amount);
    event AssetWithdrawal(uint256 orderId, address indexed user, address indexed asset, uint256 amount);


    function () external payable {
        revert("Fallback methods should be reverted");
    }


    function deposit(
        uint256 orderId
    ) public orderIdNotExist(orderId, _msgSender()) payable {

        require(_msgValue() != 0, "deposit: user needs to transfer ETH for calling this method");

        _deposit(orderId, _msgSender(), _ethAssetIdentificator, _msgValue());
    }

    function deposit(
        uint256 orderId,
        uint256 amount,
        address token
    ) public orderIdNotExist(orderId, _msgSender()) {

        require(token != address(0), "deposit: invalid token address");
        require(amount != 0, "deposit: user needs to fill transferable tokens amount for calling this method");

        IERC20(token).safeTransferFrom(_msgSender(), address(this), amount);
        _deposit(orderId, _msgSender(), token, amount);
    }

    function withdraw(
        uint256 orderId
    ) external {

        require(_doesUserExist(_msgSender()) == true, "withdraw: the user is not active");

        _withdraw(orderId);
    }



    function doesUserExist(
        address user
    ) external view returns (bool) {

        return _doesUserExist(user);
    }

    function getUserActiveDeposits(
        address user,
        uint256 cursor,
        uint256 howMany
    ) public view returns (
        uint256[] memory orderIds,
        uint256[] memory amounts,
        uint256[] memory initTimestamps,
        uint256 newCursor
    ) {

        uint256 depositsLength = _users[user].index;
        uint256 activeOrdersLength = 0;

        for (uint256 i = 0; i < depositsLength; i++){
            uint256 orderId = _users[user].orderIdByIndex[i];
            if (_users[user].orders[orderId].withdrawn == false) {
                activeOrdersLength++;
            }
        }

        uint256 length = howMany;
        if (length > activeOrdersLength - cursor) {
            length = activeOrdersLength - cursor;
        }

        orderIds = new uint256[](length);
        amounts = new uint256[](length);
        initTimestamps = new uint256[](length);

        uint256 j = 0;
        for (uint256 i = 0; i < depositsLength; i++){
            if (j == length) {
                break;
            } else {
                uint256 orderId = _users[user].orderIdByIndex[cursor + i];
                if (_users[user].orders[orderId].withdrawn == false) {
                    orderIds[j] = orderId;
                    amounts[j] = _users[user].orders[orderId].amount;
                    initTimestamps[j] = _users[user].orders[orderId].initTimestamp;

                    j++;
                }
            }
        }

        return (
            orderIds,
            amounts,
            initTimestamps,
            cursor + length
        );
    }

    function getUserFilledDeposits(
        address user,
        uint256 cursor,
        uint256 howMany
    ) external view returns (
        uint256[] memory orderIds,
        uint256[] memory amounts,
        uint256[] memory initTimestamps,
        uint256 newCursor
    ) {

        uint256 depositsLength = _users[user].index;

        uint256 length = howMany;
        if (length > depositsLength - cursor) {
            length = depositsLength - cursor;
        }

        orderIds = new uint256[](length);
        amounts = new uint256[](length);
        initTimestamps = new uint256[](length);

        uint256 j = 0;
        for (uint256 i = 0; i < length; i++){
            uint256 orderId = _users[user].orderIdByIndex[cursor + i];
            orderIds[j] = orderId;
            amounts[j] = _users[user].orders[orderId].amount;
            initTimestamps[j] = _users[user].orders[orderId].initTimestamp;

            j++;
        }

        return (
            orderIds,
            amounts,
            initTimestamps,
            cursor + length
        );
    }

    function getUserDepositIndex(
        address user
    ) external view returns (
        uint256
    ) {

        return _users[user].index;
    }

    function getOrderDetails(
        uint256 orderId,
        address user
    ) external view returns (
        bool created,
        address asset,
        uint256 amount,
        bool withdrawn,
        uint256 initTimestamp
    ) {

        OrderDetails memory order = _getOrderDetails(orderId, user);
        return (
            order.created,
            order.asset,
            order.amount,
            order.withdrawn,
            order.initTimestamp
        );
    }

    function getUserById(
        uint256 userId
    ) external view returns (
        address user
    ) {

        return _usersById[userId];
    }

    function getUsersList(
        uint256 cursor,
        uint256 howMany
    ) external view returns (
        address[] memory users,
        uint256 newCursor
    ) {

        uint256 length = howMany;
        if (length > _usersCount - cursor) {
            length = _usersCount - cursor;
        }

        users = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            users[i] = _usersById[cursor + i];
        }

        return (users, cursor + length);
    }

    function getUsersCount() external view returns (uint256 count) {

        return _usersCount;
    }


    function _deposit(
        uint256 orderId,
        address sender,
        address asset,
        uint256 amount
    ) internal {

        _activateIfUserIsNew(sender);
        _depositOrderBalance(orderId, sender, asset, amount);

        _users[sender].index += 1;

        _depositsById[_depositsCount] = orderId;
        _depositsCount++;

        emit AssetDeposited(orderId, sender, asset, amount);
    }

    function _withdraw(
        uint256 orderId
    ) internal {

        OrderDetails memory order = _getOrderDetails(orderId, _msgSender());
        address asset = order.asset;
        uint256 amount = order.amount;

        require(amount != 0, "withdraw: order has no positive value");
        require(order.withdrawn == false, "withdraw: this order Id has been already withdrawn or waiting for the swap");

        _withdrawOrderBalance(orderId, _msgSender());

        if (asset == _ethAssetIdentificator) {
            _msgSender().transfer(amount);
        } else {
            IERC20(asset).safeTransfer(_msgSender(), amount);
        }

        emit AssetWithdrawal(orderId, _msgSender(), asset, amount);
    }

    function _activateIfUserIsNew(
        address user
    ) internal returns (bool) {

        if (_doesUserExist(user) == false) {
            _users[user].exist = true;
            _usersById[_usersCount] = user;
            _usersCount++;
        }
        return true;
    }

    function _depositOrderBalance(
        uint256 orderId,
        address user,
        address asset,
        uint256 amount
    ) internal returns (bool) {

        _users[user].orderIdByIndex[_users[user].index] = orderId;
        _users[user].orders[orderId] = OrderDetails(true, asset, amount, false, block.timestamp);
        return true;
    }

    function _reopenExistingOrder(
        uint256 orderId,
        address user
    ) internal returns (bool) {

        _users[user].orders[orderId].withdrawn = false;
        _users[user].orders[orderId].initTimestamp = block.timestamp;
        return true;
    }

    function _withdrawOrderBalance(
        uint256 orderId,
        address user
    ) internal returns (bool) {

        _users[user].orders[orderId].withdrawn = true;
        return true;
    }

    function _doesUserExist(
        address user
    ) internal view returns (bool) {

        return _users[user].exist;
    }

    function _getOrderDetails(
        uint256 orderId,
        address user
    ) internal view returns (OrderDetails memory order) {

        return _users[user].orders[orderId];
    }

}

contract CrossBlockchainSwap is AssetsValue {


    event Initiated(
        uint256 indexed orderId,
        bytes32 indexed secretHash,
        address indexed initiator,
        address recipient,
        uint256 initTimestamp,
        uint256 refundTimestamp,
        address asset,
        uint256 amount
    );

    event Redeemed(
        bytes32 secretHash,
        uint256 redeemTimestamp,
        bytes32 secret,
        address indexed redeemer
    );

    event Refunded(
        uint256 orderId,
        bytes32 secretHash,
        uint256 refundTime,
        address indexed refunder
    );


    modifier swapIsNotInitiated(bytes32 secretHash) {

        require(_swaps[secretHash].state == State.Empty, "swapIsNotInitiated: this secret hash was already used, please use another one");
        _;
    }

    modifier swapIsRedeemable(bytes32 secret) {

        bool isRedeemable = _isRedeemable(secret);
        require(isRedeemable, "swapIsRedeemable: the redeem is not available");
        _;
    }

    modifier swapIsRefundable(bytes32 secretHash, address refunder) {

        bool isRefundable = _isRefundable(secretHash, refunder);
        require(isRefundable, "swapIsRefundable: refund is not available");
        _;
    }


    function initiate(
        uint256 orderId,
        bytes32 secretHash,
        address recipient,
        uint256 refundTimestamp
    ) public swapIsNotInitiated(secretHash) {

        require(recipient != address(0), "initiate: invalid recipient address");

        _validateRefundTimestamp(refundTimestamp * 1 minutes);

        OrderDetails memory order = _getOrderDetails(orderId, _msgSender());

        require(order.created == true, "initiate: this order Id has not been created and deposited yet");
        require(order.withdrawn == false, "initiate: this order deposit has been withdrawn");
        require(order.amount != 0, "initiate: this order Id has been withdrawn, finished or waiting for the redeem");

        _withdrawOrderBalance(orderId, _msgSender());

        _swaps[secretHash].asset = order.asset;
        _swaps[secretHash].amount = order.amount;

        _swaps[secretHash].state = State.Filled;

        _swaps[secretHash].initiator = _msgSender();
        _swaps[secretHash].recipient = recipient;
        _swaps[secretHash].secretHash = secretHash;
        _swaps[secretHash].orderId = orderId;

        _swaps[secretHash].initTimestamp = block.timestamp;
        _swaps[secretHash].refundTimestamp = block.timestamp + (refundTimestamp * 1 minutes);

        Initiator storage initiator = _initiators[_msgSender()];
        initiator.swaps[initiator.index] = secretHash;
        initiator.index++;
        initiator.filledSwaps++;

        _swapsById[_swapsCount] = secretHash;
        _swapsCount++;

        emit Initiated(
            orderId,
            secretHash,
            _msgSender(),
            recipient,
            block.timestamp,
            refundTimestamp,
            order.asset,
            order.amount
        );
    }

    function redeem(
        bytes32 secret
    ) external swapIsRedeemable(secret) {

        bytes32 secretHash = _hashTheSecret(secret);

        _swaps[secretHash].state = State.Redeemed;

        address recipient = _swaps[secretHash].recipient;

        if (_getSwapAssetType(secretHash) == SwapType.ETH) {
            address payable payableReceiver = address(uint160(recipient));
            payableReceiver.transfer(_swaps[secretHash].amount);
        } else {
            IERC20(_swaps[secretHash].asset).safeTransfer(recipient, _swaps[secretHash].amount);
        }

        _swaps[secretHash].secret = secret;

        _initiators[_swaps[secretHash].initiator].filledSwaps--;

        emit Redeemed (
            secretHash,
            block.timestamp,
            secret,
            recipient
        );
    }

    function refund(
        bytes32 secretHash
    ) public swapIsRefundable(secretHash, _msgSender()) {

        _swaps[secretHash].state = State.Refunded;
        _reopenExistingOrder(_swaps[secretHash].orderId,_msgSender());

        _initiators[_msgSender()].filledSwaps--;

        emit Refunded(
            _swaps[secretHash].orderId,
            secretHash,
            block.timestamp,
            _msgSender()
        );
    }

    function refundAndWithdraw(
        bytes32 secretHash
    ) external {

        refund(secretHash);
        uint256 orderId = _swaps[secretHash].orderId;
        _withdraw(orderId);
    }

    function refundAndWithdrawAll() external {

        uint256 filledSwaps = _initiators[_msgSender()].filledSwaps;

        for (uint256 i = 0; i < filledSwaps; i++) {
            bytes32 secretHash = _swaps[_initiators[_msgSender()].swaps[i]].secretHash;
            if (_isRefundable(secretHash, _msgSender())) {
                uint256 orderId = _swaps[_initiators[_msgSender()].swaps[i]].orderId;
                refund(secretHash);
                _withdraw(orderId);
            }
        }
    }


    function getUserSwapsByState(
        address initiator,
        State state,
        uint256 cursor,
        uint256 howMany
    ) public view returns (
        uint256[] memory orderIds,
        uint256 newCursor
    ) {

        uint256 swapsLength = _initiators[initiator].index;
        uint256 filteredOrdersLength = 0;

        for (uint256 i = 0; i < swapsLength; i++){
            Swap memory swap = _swaps[_initiators[initiator].swaps[i]];
            if (swap.state == state) {
                filteredOrdersLength++;
            }
        }

        uint256 length = howMany;
        if (length > filteredOrdersLength - cursor) {
            length = filteredOrdersLength - cursor;
        }

        orderIds = new uint256[](length);

        uint256 j = 0;
        for (uint256 i = 0; i < swapsLength; i++){
            if (j == length) {
                break;
            } else {
                Swap memory swap = _swaps[_initiators[initiator].swaps[cursor + i]];
                if (swap.state == state) {
                    orderIds[j] = swap.orderId;

                    j++;
                }
            }
        }

        return (
            orderIds,
            cursor + length
        );
    }

    function getUserFilledOrdersCount(
        address user
    ) external view returns (
        uint256 count
    ) {

        return _initiators[user].filledSwaps;
    }

    function getUserFilledOrders(
        address user,
        uint256 cursor,
        uint256 howMany
    ) external view returns (
        uint256[] memory orderIds,
        uint256[] memory amounts,
        uint256[] memory initTimestamps,
        uint256 newCursor
    ) {

        uint256 filledSwaps = _initiators[user].filledSwaps;

        uint256 length = howMany;
        if (length > filledSwaps - cursor) {
            length = filledSwaps - cursor;
        }

        orderIds = new uint256[](length);
        amounts = new uint256[](length);
        initTimestamps = new uint256[](length);

        uint256 j = 0;
        for(uint256 i = 0; i <= _initiators[user].index; i++){
            if (j == length) {
                break;
            } else {
                Swap memory swap = _swaps[_initiators[user].swaps[cursor + i]];
                if (swap.state == State.Filled) {
                    amounts[j] = swap.amount;
                    orderIds[j] = swap.orderId;
                    initTimestamps[j] = swap.initTimestamp;

                    j++;
                }
            }
        }

        return (
            orderIds,
            amounts,
            initTimestamps,
            cursor + length
        );
    }

    function getSwapAssetType(
        bytes32 secretHash
    ) public view returns (SwapType tp) {

        return _getSwapAssetType(secretHash);
    }

    function getSwapData(
        bytes32 _secretHash
    ) external view returns (
        uint256 initTimestamp,
        uint256 refundTimestamp,
        bytes32 secretHash,
        bytes32 secret,
        address initiator,
        address recipient,
        address asset,
        uint256 amount,
        State state
    ) {

        Swap memory swap = _swaps[_secretHash];
        return (
            swap.initTimestamp,
            swap.refundTimestamp,
            swap.secretHash,
            swap.secret,
            swap.initiator,
            swap.recipient,
            swap.asset,
            swap.amount,
            swap.state
        );
    }

    function getExpiredSwaps(
        address user
    ) public view returns (
        uint256[] memory orderIds,
        bytes32[] memory secretHashes
    ) {

        uint256 swapsLength = _initiators[user].index;
        uint256 expiredSwapsLength = 0;

        for (uint256 i = 0; i < swapsLength; i++){
            bytes32 secretHash = _initiators[user].swaps[i];
            Swap memory swap = _swaps[secretHash];
            if (block.timestamp >= swap.refundTimestamp && swap.state == State.Filled) {
                expiredSwapsLength++;
            }
        }

        orderIds = new uint256[](expiredSwapsLength);
        secretHashes = new bytes32[](expiredSwapsLength);

        uint256 j = 0;
        for (uint256 i = 0; i < swapsLength; i++){
            bytes32 secretHash = _initiators[user].swaps[i];
            Swap memory swap = _swaps[secretHash];
            if (block.timestamp >= swap.refundTimestamp && swap.state == State.Filled) {
                orderIds[j] = swap.orderId;
                secretHashes[j] = secretHash;
                j++;
            }
        }

        return (
            orderIds,
            secretHashes
        );
    }

    function getHashOfSecret(
        bytes32 secret
    ) external pure returns (bytes32) {

        return _hashTheSecret(secret);
    }

    function getSwapLifetimeLimits() public view returns (
        uint256 min,
        uint256 max
    ) {

        return (
            _swapTimeLimits.min,
            _swapTimeLimits.max
        );
    }

    function getSwapsCount() external view returns (
        uint256 swapsCount
    ) {

        return _swapsCount;
    }

    function getSwapsSecretHashById(
        uint256 swapId
    ) external view returns (
        bytes32 secretHash
    ) {

        return _swapsById[swapId];
    }


    function _validateRefundTimestamp(
        uint256 refundTimestamp
    ) private view {

        require(refundTimestamp >= _swapTimeLimits.min, "_validateRefundTimestamp: the timestamp should be bigger than min swap lifetime");
        require(_swapTimeLimits.max >= refundTimestamp, "_validateRefundTimestamp: the timestamp should be smaller than max swap lifetime");
    }

    function _isRefundable(
        bytes32 secretHash,
        address refunder
    ) internal view returns (bool) {

        bool isFilled = _swaps[secretHash].state == State.Filled;
        bool isCallerInitiator = _swaps[secretHash].initiator == refunder;
        uint256 refundTimestamp = _swaps[secretHash].refundTimestamp;
        bool isTimeReached = block.timestamp >= refundTimestamp;

        return isFilled && isCallerInitiator && isTimeReached;
    }

    function _isRedeemable(
        bytes32 secret
    ) internal view returns (bool) {

        bytes32 secretHash = _hashTheSecret(secret);
        bool isSwapFilled = _swaps[secretHash].state == State.Filled;
        uint256 refundTimestamp = _swaps[secretHash].refundTimestamp;
        bool isSwapActive = refundTimestamp > block.timestamp;

        return isSwapFilled && isSwapActive;
    }

    function _hashTheSecret(
        bytes32 secret
    ) private pure returns (bytes32) {

        return sha256(abi.encodePacked(secret));
    }

    function _getSwapAssetType(
        bytes32 secretHash
    ) private view returns (SwapType tp) {

        if (_swaps[secretHash].asset == _ethAssetIdentificator) {
            return SwapType.ETH;
        } else {
            return SwapType.Token;
        }
    }
}