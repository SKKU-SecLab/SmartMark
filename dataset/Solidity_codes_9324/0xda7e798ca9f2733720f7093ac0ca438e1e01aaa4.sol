
pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

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

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

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
        return !AddressUpgradeable.isContract(address(this));
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

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {


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

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal initializer {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal initializer {
        _registerInterface(
            ERC1155ReceiverUpgradeable(address(0)).onERC1155Received.selector ^
            ERC1155ReceiverUpgradeable(address(0)).onERC1155BatchReceived.selector
        );
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal initializer {

        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal initializer {

    }
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}// BUSL-1.1

pragma solidity 0.7.6;
pragma abicoder v2;

interface IAMM {

    struct Pair {
        address tokenAddress; // first is always PT
        uint256[2] weights;
        uint256[2] balances;
        bool liquidityIsInitialized;
    }

    function finalize() external;


    function switchPeriod() external;


    function togglePauseAmm() external;


    function withdrawExpiredToken(address _user, uint256 _lpTokenId) external;


    function getExpiredTokensInfo(address _user, uint256 _lpTokenId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function swapExactAmountIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _tokenOut,
        uint256 _minAmountOut,
        address _to
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _maxAmountIn,
        uint256 _tokenOut,
        uint256 _tokenAmountOut,
        address _to
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function createLiquidity(uint256 _pairID, uint256[2] memory _tokenAmounts) external;


    function addLiquidity(
        uint256 _pairID,
        uint256 _poolAmountOut,
        uint256[2] memory _maxAmountsIn
    ) external;


    function removeLiquidity(
        uint256 _pairID,
        uint256 _poolAmountIn,
        uint256[2] memory _minAmountsOut
    ) external;


    function joinSwapExternAmountIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _minPoolAmountOut
    ) external returns (uint256 poolAmountOut);


    function joinSwapPoolAmountOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _poolAmountOut,
        uint256 _maxAmountIn
    ) external returns (uint256 tokenAmountIn);


    function exitSwapPoolAmountIn(
        uint256 _pairID,
        uint256 _tokenOut,
        uint256 _poolAmountIn,
        uint256 _minAmountOut
    ) external returns (uint256 tokenAmountOut);


    function exitSwapExternAmountOut(
        uint256 _pairID,
        uint256 _tokenOut,
        uint256 _tokenAmountOut,
        uint256 _maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);


    function setSwappingFees(uint256 _swapFee) external;


    function calcOutAndSpotGivenIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _tokenOut,
        uint256 _minAmountOut
    ) external view returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function calcInAndSpotGivenOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _maxAmountIn,
        uint256 _tokenOut,
        uint256 _tokenAmountOut
    ) external view returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function getSpotPrice(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenOut
    ) external view returns (uint256);


    function getFutureAddress() external view returns (address);


    function getPTAddress() external view returns (address);


    function getUnderlyingOfIBTAddress() external view returns (address);


    function getFYTAddress() external view returns (address);


    function getPTWeightInPair() external view returns (uint256);


    function getPairWithID(uint256 _pairID) external view returns (Pair memory);


    function getLPTokenId(
        uint256 _ammId,
        uint256 _periodIndex,
        uint256 _pairID
    ) external pure returns (uint256);


    function ammId() external returns (uint64);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IERC1155 is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


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


    function grantRole(bytes32 role, address account) external;


    function MINTER_ROLE() external view returns (bytes32);


    function mint(
        address to,
        uint64 _ammId,
        uint64 _periodIndex,
        uint32 _pairId,
        uint256 amount,
        bytes memory data
    ) external returns (uint256 id);


    function burnFrom(
        address account,
        uint256 id,
        uint256 value
    ) external;

}// BUSL-1.1


pragma solidity ^0.7.6;

interface ILPToken is IERC1155 {

    function amms(uint64 _ammId) external view returns (address);


    function getAMMId(uint256 _id) external pure returns (uint64);


    function getPeriodIndex(uint256 _id) external pure returns (uint64);


    function getPairId(uint256 _id) external pure returns (uint32);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IERC20 is IERC20Upgradeable {

    function name() external returns (string memory);


    function symbol() external returns (string memory);


    function decimals() external view returns (uint8);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IPT is IERC20 {

    function burn(uint256 amount) external;


    function mint(address to, uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;


    function pause() external;


    function unpause() external;


    function recordedBalanceOf(address account) external view returns (uint256);


    function balanceOf(address account) external view override returns (uint256);


    function futureVault() external view returns (address);

}// BUSL-1.1

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface IRegistry {

    function initialize(address _admin) external;


    function setTreasury(address _newTreasury) external;


    function setController(address _newController) external;


    function setAPW(address _newAPW) external;


    function setProxyFactory(address _proxyFactory) external;


    function setPTLogic(address _PTLogic) external;


    function setFYTLogic(address _FYTLogic) external;


    function setMathsUtils(address _mathsUtils) external;


    function setNamingUtils(address _namingUtils) external;


    function getControllerAddress() external view returns (address);


    function getTreasuryAddress() external view returns (address);


    function getTokensFactoryAddress() external view returns (address);


    function getDAOAddress() external returns (address);


    function getAPWAddress() external view returns (address);


    function getAMMFactoryAddress() external view returns (address);


    function getTokenFactoryAddress() external view returns (address);


    function getProxyFactoryAddress() external view returns (address);


    function getPTLogicAddress() external view returns (address);


    function getFYTLogicAddress() external view returns (address);


    function getAMMLogicAddress() external view returns (address);


    function getAMMLPTokenLogicAddress() external view returns (address);


    function getMathsUtils() external view returns (address);


    function getNamingUtils() external view returns (address);


    function addFuture(address _future) external;


    function removeFuture(address _future) external;


    function isRegisteredFuture(address _future) external view returns (bool);


    function isRegisteredAMM(address _ammAddress) external view returns (bool);


    function getFutureAt(uint256 _index) external view returns (address);


    function futureCount() external view returns (uint256);

}// BUSL-1.1

pragma solidity 0.7.6;

interface IFutureWallet {

    function initialize(address _futureAddress, address _adminAddress) external;


    function registerExpiredFuture(uint256 _amount) external;


    function redeemYield(uint256 _periodIndex) external;


    function getRedeemableYield(uint256 _periodIndex, address _tokenHolder) external view returns (uint256);


    function getFutureAddress() external view returns (address);


    function getIBTAddress() external view returns (address);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IFutureVault {

    event NewPeriodStarted(uint256 _newPeriodIndex);
    event FutureWalletSet(address _futureWallet);
    event RegistrySet(IRegistry _registry);
    event FundsDeposited(address _user, uint256 _amount);
    event FundsWithdrawn(address _user, uint256 _amount);
    event PTSet(IPT _pt);
    event LiquidityTransfersPaused();
    event LiquidityTransfersResumed();
    event DelegationCreated(address _delegator, address _receiver, uint256 _amount);
    event DelegationRemoved(address _delegator, address _receiver, uint256 _amount);

    function PERIOD_DURATION() external view returns (uint256);


    function PLATFORM_NAME() external view returns (string memory);


    function startNewPeriod() external;


    function updateUserState(address _user) external;


    function claimFYT(address _user, uint256 _amount) external;


    function deposit(address _user, uint256 _amount) external;


    function withdraw(address _user, uint256 _amount) external;


    function createFYTDelegationTo(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) external;


    function withdrawFYTDelegationFrom(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) external;



    function getTotalDelegated(address _delegator) external view returns (uint256 totalDelegated);


    function getNextPeriodIndex() external view returns (uint256);


    function getCurrentPeriodIndex() external view returns (uint256);


    function getClaimablePT(address _user) external view returns (uint256);


    function getUserEarlyUnlockablePremium(address _user)
        external
        view
        returns (uint256 premiumLocked, uint256 amountRequired);


    function getUnlockableFunds(address _user) external view returns (uint256);


    function getClaimableFYTForPeriod(address _user, uint256 _periodIndex) external view returns (uint256);


    function getUnrealisedYieldPerPT() external view returns (uint256);


    function getPTPerAmountDeposited(uint256 _amount) external view returns (uint256);


    function getPremiumPerUnderlyingDeposited(uint256 _amount) external view returns (uint256);


    function getTotalUnderlyingDeposited() external view returns (uint256);


    function getYieldOfPeriod(uint256 _periodID) external view returns (uint256);


    function getControllerAddress() external view returns (address);


    function getFutureWalletAddress() external view returns (address);


    function getIBTAddress() external view returns (address);


    function getPTAddress() external view returns (address);


    function getFYTofPeriod(uint256 _periodIndex) external view returns (address);


    function isTerminated() external view returns (bool);


    function getPerformanceFeeFactor() external view returns (uint256);



    function harvestRewards() external;


    function redeemAllVaultRewards() external;


    function redeemVaultRewards(address _rewardToken) external;


    function addRewardsToken(address _token) external;


    function isRewardToken(address _token) external view returns (bool);


    function getRewardTokenAt(uint256 _index) external view returns (address);


    function getRewardTokensCount() external view returns (uint256);


    function getRewardsRecipient() external view returns (address);


    function setRewardRecipient(address _recipient) external;



    function setFutureWallet(IFutureWallet _futureWallet) external;


    function setRegistry(IRegistry _registry) external;


    function pauseLiquidityTransfers() external;


    function resumeLiquidityTransfers() external;


    function convertIBTToUnderlying(uint256 _amount) external view returns (uint256);


    function convertUnderlyingtoIBT(uint256 _amount) external view returns (uint256);

}// BUSL-1.1

pragma solidity 0.7.6;

interface IRewarder {

    function onAPWReward(
        uint256 pid,
        address user,
        address recipient,
        uint256 apwAmount
    ) external;


    function pendingTokens(uint256 pid, address user) external view returns (IERC20[] memory, uint256[] memory);


    function renewPool(uint256 _oldPid, uint256 _newPid) external;

}// BUSL-1.1
pragma solidity 0.7.6;

contract MasterChef is OwnableUpgradeable, ERC1155HolderUpgradeable {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for ILPToken;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 periodId;
    }
    struct PoolInfo {
        uint256 allocPoint; // How many allocation points assigned to this pool. APWs to distribute per block.
        uint256 accAPWPerShare; // Accumulated APWs per share, times 1e12. See below.
        uint256 lastRewardBlock; // Last block number that APWs distribution occurs.
        uint256 ammId;
        uint256 pairId;
    }

    EnumerableSetUpgradeable.UintSet internal activePools; // list of tokenId to update

    mapping(uint256 => mapping(uint256 => uint256)) internal poolToPeriodId; // ammid => paird => period
    mapping(uint256 => mapping(uint256 => mapping(address => UserInfo))) public userInfo; // ammid => pairId => user address => user info

    mapping(uint256 => address) public lpIDToFutureAddress;

    mapping(uint256 => uint256) public nextUpgradeAllocPoint;

    mapping(uint256 => IRewarder) public rewarders;
    uint256 private constant TOKEN_PRECISION = 1e12;
    IERC20Upgradeable public apw;
    ILPToken public lpToken;
    uint256 public apwPerBlock;
    mapping(uint256 => PoolInfo) public poolInfo;

    bytes4 public constant ERC1155_ERC165 = 0xd9b67a26;

    mapping(address => EnumerableSetUpgradeable.UintSet) internal userLpTokensIds;

    uint256 public totalAllocPoint;
    uint256 public startBlock;

    uint256 private _status;

    bool public depositEnabled;

    bool public withdrawEnabled;

    modifier nonReentrant() {

        require(_status != _ENTERED, "MasterChef: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    modifier validPool(uint256 _lpTokenId) {

        uint64 ammId = lpToken.getAMMId(_lpTokenId);
        uint256 pairId = lpToken.getPairId(_lpTokenId);
        require(poolToPeriodId[ammId][pairId] != 0, "MasterChef: invalid pool id");
        _;
    }

    modifier depositsEnabled() {

        require(depositEnabled, "MasterChef: deposit paused");
        _;
    }

    modifier withdrawalsEnabled() {

        require(withdrawEnabled, "MasterChef: withdrawals paused");
        _;
    }

    event Deposit(address indexed user, uint256 indexed lpTokenId, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed lpTokenId, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed lpTokenId, uint256 amount);
    event NextAllocPointSet(uint256 indexed previousLpTokenId, uint256 nextAllocPoint);
    event LpIdToFutureSet(uint256 _lpTokenId, address futureAddress);
    event Harvest(address indexed user, uint256 indexed lpTokenId, uint256 amount);
    event DepositPauseChanged(bool _depositPaused);
    event WithdrawalsPauseChange(bool _withdrawPaused);

    function initialize(
        address _apw,
        address _lpToken,
        uint256 _apwPerBlock,
        uint256 _startBlock
    ) external initializer {

        require(_apw != address(0), "MasterChef: Invalid APW address provided");
        require(_lpToken != address(0), "MasterChef: Invalid LPToken address provided");
        require(_apwPerBlock > 0, "MasterChef: !apwPerBlock-0");

        apw = IERC20Upgradeable(_apw);
        lpToken = ILPToken(_lpToken);
        apwPerBlock = _apwPerBlock;
        startBlock = _startBlock;
        totalAllocPoint = 0;
        _status = _NOT_ENTERED;
        __Ownable_init();
        _registerInterface(ERC1155_ERC165);
    }

    function add(
        uint256 _allocPoint,
        uint256 _lpTokenId,
        IRewarder _rewarder,
        bool _withUpdate
    ) external onlyOwner {

        _add(_allocPoint, _lpTokenId, _rewarder, _withUpdate);
    }

    function _add(
        uint256 _allocPoint,
        uint256 _lpTokenId,
        IRewarder _rewarder,
        bool _withUpdate
    ) internal {

        uint64 ammId = lpToken.getAMMId(_lpTokenId);
        uint256 pairId = lpToken.getPairId(_lpTokenId);
        uint64 periodId = lpToken.getPeriodIndex(_lpTokenId);
        address ammAddress = lpToken.amms(ammId);
        require(ammAddress != address(0), "MasterChef: LPTokenId Invalid");
        require(poolToPeriodId[ammId][pairId] != periodId, "MasterChef: LP Token already added");
        address futureAddress = IAMM(ammAddress).getFutureAddress();
        uint256 lastPeriodId = IFutureVault(futureAddress).getCurrentPeriodIndex();
        require(periodId == lastPeriodId, "MasterChef: Invalid period ID for LP Token");
        lpIDToFutureAddress[_lpTokenId] = futureAddress;
        rewarders[_lpTokenId] = _rewarder;
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo[_lpTokenId] = PoolInfo({
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accAPWPerShare: 0,
            ammId: ammId,
            pairId: pairId
        });
        activePools.add(_lpTokenId);
        poolToPeriodId[ammId][pairId] = periodId;
    }

    function set(
        uint256 _lpTokenId,
        uint256 _allocPoint,
        IRewarder _rewarder,
        bool overwrite,
        bool _withUpdate
    ) external onlyOwner {

        _set(_lpTokenId, _allocPoint, _rewarder, overwrite, _withUpdate);
    }

    function _set(
        uint256 _lpTokenId,
        uint256 _allocPoint,
        IRewarder _rewarder,
        bool overwrite,
        bool _withUpdate
    ) internal validPool(_lpTokenId) {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_lpTokenId].allocPoint).add(_allocPoint);
        poolInfo[_lpTokenId].allocPoint = _allocPoint;
        if (overwrite) {
            rewarders[_lpTokenId] = _rewarder;
        }
    }

    function pendingAPW(uint256 _lpTokenId, address _user)
        public
        view
        validPool(_lpTokenId)
        returns (uint256 userPendingApw)
    {

        uint64 ammId = lpToken.getAMMId(_lpTokenId);
        uint256 pairId = lpToken.getPairId(_lpTokenId);
        UserInfo storage user = userInfo[ammId][pairId][_user];
        PoolInfo storage pool = poolInfo[_lpTokenId];
        uint256 accAPWPerShare = pool.accAPWPerShare;
        uint256 lpSupply = lpToken.balanceOf(address(this), _lpTokenId);
        if (block.number > pool.lastRewardBlock && lpSupply != 0 && totalAllocPoint != 0) {
            uint256 apwReward =
                (block.number.sub(pool.lastRewardBlock)).mul(apwPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

            accAPWPerShare = accAPWPerShare.add(apwReward.mul(TOKEN_PRECISION).div(lpSupply));
        }

        return user.amount.mul(accAPWPerShare).div(TOKEN_PRECISION).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = activePools.length();
        for (uint256 i = 0; i < length; ++i) {
            updatePool(activePools.at(i));
        }
    }

    function updatePool(uint256 _lpTokenId) public validPool(_lpTokenId) {

        PoolInfo storage pool = poolInfo[_lpTokenId];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = lpToken.balanceOf(address(this), _lpTokenId);
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 apwReward =
            totalAllocPoint == 0
                ? 0
                : (block.number.sub(pool.lastRewardBlock)).mul(apwPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accAPWPerShare = pool.accAPWPerShare.add(apwReward.mul(TOKEN_PRECISION).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function _upgradePoolRewardsIfNeeded(uint64 _ammId, uint256 _pairId) internal returns (bool) {

        address ammAddress = lpToken.amms(_ammId);
        uint256 lastPeriodId = IFutureVault(IAMM(ammAddress).getFutureAddress()).getCurrentPeriodIndex();
        uint256 previousPeriodId = poolToPeriodId[_ammId][_pairId];
        uint previousLpTokenId = IAMM(ammAddress).getLPTokenId(_ammId, previousPeriodId, _pairId);
        if (lastPeriodId > previousPeriodId) {
            _set(previousLpTokenId, 0, IRewarder(0x0), false, false); // remove rewards for old period
            uint256 newLpTokenId = IAMM(ammAddress).getLPTokenId(_ammId, lastPeriodId, _pairId);
            activePools.remove(previousLpTokenId); // remove old pool from active ones
            IRewarder rewarder = rewarders[previousLpTokenId];
            _add(nextUpgradeAllocPoint[previousLpTokenId], newLpTokenId, rewarder, false); // add rewards for the new period
            if (address(rewarder) != address(0x0)) rewarder.renewPool(previousLpTokenId, newLpTokenId);
            return true;
        } else {
            return false;
        }
    }

    function deposit(uint256 _lpTokenId, uint256 _amount) external validPool(_lpTokenId) nonReentrant depositsEnabled {

        uint64 ammId = lpToken.getAMMId(_lpTokenId);
        uint256 pairId = lpToken.getPairId(_lpTokenId);
        _upgradePoolRewardsIfNeeded(ammId, pairId);

        uint256 periodOfToken = lpToken.getPeriodIndex(_lpTokenId);
        uint256 lastPeriodId = IFutureVault(lpIDToFutureAddress[_lpTokenId]).getCurrentPeriodIndex();
        require(periodOfToken == lastPeriodId, "Masterchef: Invalid period Id for Token");

        updatePool(_lpTokenId);

        PoolInfo storage pool = poolInfo[_lpTokenId];
        UserInfo storage user = userInfo[ammId][pairId][msg.sender];

        if (user.amount > 0) {
            uint256 lastUserLpTokenId = IAMM(lpToken.amms(ammId)).getLPTokenId(ammId, user.periodId, pairId);
            uint256 accAPWPerShare =
                (user.periodId != 0 && user.periodId < periodOfToken)
                    ? poolInfo[lastUserLpTokenId].accAPWPerShare
                    : pool.accAPWPerShare;
            uint256 pending = user.amount.mul(accAPWPerShare).div(TOKEN_PRECISION).sub(user.rewardDebt);

            if (pending > 0) require(safeAPWTransfer(msg.sender, pending), "Masterchef: SafeTransfer APW failed");
        }
        if (user.periodId != periodOfToken) {
            userLpTokensIds[msg.sender].remove(IAMM(lpToken.amms(ammId)).getLPTokenId(ammId, pairId, user.periodId));
            user.amount = 0;
            user.rewardDebt = 0;
            user.periodId = periodOfToken;
        }

        if (_amount > 0) lpToken.safeTransferFrom(address(msg.sender), address(this), _lpTokenId, _amount, "");
        user.amount = user.amount.add(_amount);
        userLpTokensIds[msg.sender].add(_lpTokenId);
        user.rewardDebt = user.amount.mul(pool.accAPWPerShare).div(TOKEN_PRECISION);

        IRewarder _rewarder = rewarders[_lpTokenId];
        if (address(_rewarder) != address(0)) {
            _rewarder.onAPWReward(_lpTokenId, msg.sender, msg.sender, user.amount);
        }

        emit Deposit(msg.sender, _lpTokenId, _amount);
    }

    function withdraw(uint256 _lpTokenId, uint256 _amount) external validPool(_lpTokenId) nonReentrant withdrawalsEnabled {

        PoolInfo storage pool = poolInfo[_lpTokenId];
        uint64 ammId = lpToken.getAMMId(_lpTokenId);
        uint256 pairId = lpToken.getPairId(_lpTokenId);
        UserInfo storage user = userInfo[ammId][pairId][msg.sender];
        if (totalAllocPoint != 0) updatePool(_lpTokenId);
        require(user.amount >= _amount, "withdraw: not good");
        uint256 pending = user.amount.mul(pool.accAPWPerShare).div(TOKEN_PRECISION).sub(user.rewardDebt);
        if (pending > 0) require(safeAPWTransfer(msg.sender, pending), "Masterchef: SafeTransfer APW failed");
        user.amount = user.amount.sub(_amount);
        if (user.amount == 0) userLpTokensIds[msg.sender].remove(_lpTokenId);
        user.rewardDebt = user.amount.mul(pool.accAPWPerShare).div(TOKEN_PRECISION);
        IRewarder _rewarder = rewarders[_lpTokenId];
        if (address(_rewarder) != address(0)) {
            _rewarder.onAPWReward(_lpTokenId, msg.sender, msg.sender, user.amount);
        }
        if (_amount > 0) lpToken.safeTransferFrom(address(this), address(msg.sender), _lpTokenId, _amount, "");
        emit Withdraw(msg.sender, _lpTokenId, _amount);
    }

    function harvest(uint256 _lpTokenId, address to) external nonReentrant {

        uint64 ammId = lpToken.getAMMId(_lpTokenId);
        uint256 pairId = lpToken.getPairId(_lpTokenId);
        UserInfo storage user = userInfo[ammId][pairId][msg.sender];

        require(user.amount != 0, "Masterchef: invalid lp address");

        uint256 _pendingAPW = _getPendingAPW(_lpTokenId, user);

        user.rewardDebt = user.rewardDebt.add(_pendingAPW);

        if (_pendingAPW != 0) {
            safeAPWTransfer(to, _pendingAPW);
        }

        _claimReward(_lpTokenId, user, to);
        emit Harvest(msg.sender, _lpTokenId, _pendingAPW);
    }

    function claimAll(
        uint256[] memory _userLpTokenIds,
        address _toUser,
        bool _withUpdate
    ) external nonReentrant {

        require(_toUser != address(0), "MasterChef: Invalid user address");
        uint256 length = _userLpTokenIds.length;
        uint256 totalPendingAPW = 0;
        for (uint256 i = 0; i < length; i++) {
            if (_withUpdate) {
                updatePool(_userLpTokenIds[i]);
            }
            uint256 _lpTokenId = _userLpTokenIds[i];
            uint64 ammId = lpToken.getAMMId(_lpTokenId);
            uint256 pairId = lpToken.getPairId(_lpTokenId);
            UserInfo storage user = userInfo[ammId][pairId][msg.sender];
            uint256 _pendingAPW = _getPendingAPW(_lpTokenId, user);
            user.rewardDebt = user.rewardDebt.add(_pendingAPW);
            totalPendingAPW = totalPendingAPW.add(_pendingAPW);
            _claimReward(_userLpTokenIds[i], user, _toUser);
        }
        if (totalPendingAPW != 0) {
            safeAPWTransfer(_toUser, totalPendingAPW);
        }
    }

    function emergencyWithdraw(uint256 _lpTokenId) external validPool(_lpTokenId) nonReentrant {

        uint64 ammId = lpToken.getAMMId(_lpTokenId);
        uint256 pairId = lpToken.getPairId(_lpTokenId);
        uint256 periodID = lpToken.getPeriodIndex(_lpTokenId);
        UserInfo storage user = userInfo[ammId][pairId][msg.sender];
        require(user.periodId == periodID, "MasterChef: invalid period ID");
        uint256 userAmount = user.amount;
        if (userAmount > 0) {
            user.amount = 0;
            user.rewardDebt = 0;
            lpToken.safeTransferFrom(address(this), address(msg.sender), _lpTokenId, userAmount, "");
        }
        userLpTokensIds[msg.sender].remove(_lpTokenId);
        emit EmergencyWithdraw(msg.sender, _lpTokenId, userAmount);
    }

    function safeAPWTransfer(address _to, uint256 _amount) internal returns (bool success) {

        uint256 apwBal = apw.balanceOf(address(this));
        uint256 transferAmount = (_amount > apwBal) ? apwBal : _amount;
        success = apw.transfer(_to, transferAmount);
    }

    function setAPWPerBlock(uint256 _apwPerBlock) external onlyOwner {

        massUpdatePools();
        require(_apwPerBlock > 0, "!apwPerBlock-0");
        apwPerBlock = _apwPerBlock;
    }

    function setlpIDToFuture(uint256 _lpTokenId, address futureAddress) external validPool(_lpTokenId) onlyOwner {

        lpIDToFutureAddress[_lpTokenId] = futureAddress;
        emit LpIdToFutureSet(_lpTokenId, futureAddress);
    }

    function withdrawAPW(address _recipient, uint256 _amount) external onlyOwner {

        if (_amount > 0) apw.transfer(_recipient, _amount);
    }

    function setNextUpgradeAllocPoint(uint256 _lpTokenId, uint256 _nextAllocPoint) external validPool(_lpTokenId) onlyOwner {

        uint64 ammId = lpToken.getAMMId(_lpTokenId);
        uint256 pairId = lpToken.getPairId(_lpTokenId);
        uint256 periodId = lpToken.getPeriodIndex(_lpTokenId);
        require(periodId == poolToPeriodId[ammId][pairId], "Masterchef: pool already upgraded");
        nextUpgradeAllocPoint[_lpTokenId] = _nextAllocPoint;
        emit NextAllocPointSet(_lpTokenId, _nextAllocPoint);
    }

    function isRegisteredPoolId(uint256 _poolId) external view returns (bool) {

        return activePools.contains(_poolId);
    }

    function poolIdsLength() external view returns (uint256) {

        return activePools.length();
    }

    function poolIdAt(uint256 _id) external view returns (uint256) {

        return activePools.at(_id);
    }

    function getUserLpTokenIdList(address _user) external view returns (uint256[] memory) {

        uint256 length = userLpTokensIds[_user].length();
        uint256[] memory _userLpTokenIds = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            _userLpTokenIds[i] = userLpTokensIds[_user].at(i);
        }
        return _userLpTokenIds;
    }

    function _getPendingAPW(uint256 _lpTokenId, UserInfo memory user) internal view returns (uint256) {

        PoolInfo storage pool = poolInfo[_lpTokenId];
        uint256 accAPWPerShare = pool.accAPWPerShare;
        return user.amount.mul(accAPWPerShare).div(TOKEN_PRECISION).sub(user.rewardDebt);
    }

    function getAllPendingAPW(uint256[] memory _userLpTokenIds, address user)
        external
        view
        returns (uint256 totalPendingAPW)
    {

        uint256 length = _userLpTokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            totalPendingAPW = totalPendingAPW.add(pendingAPW(_userLpTokenIds[i], user));
        }
    }

    function _claimReward(
        uint256 _lpTokenId,
        UserInfo memory user,
        address to
    ) internal {

        IRewarder _rewarder = rewarders[_lpTokenId];
        if (address(_rewarder) != address(0)) {
            _rewarder.onAPWReward(_lpTokenId, msg.sender, to, user.amount);
        }
    }

    function togglePauseDeposit() external onlyOwner {

        depositEnabled = !depositEnabled;
        emit DepositPauseChanged(depositEnabled);
    }

    function togglePauseWithdrawls() external onlyOwner {

        withdrawEnabled = !withdrawEnabled;
        emit WithdrawalsPauseChange(withdrawEnabled);
    }

    function withdrawExpiredTo(
        uint256 _lpTokenId,
        uint256 _amount,
        address _recipient
    ) external onlyOwner {

        lpToken.safeTransferFrom(address(this), _recipient, _lpTokenId, _amount, "");
    }
}