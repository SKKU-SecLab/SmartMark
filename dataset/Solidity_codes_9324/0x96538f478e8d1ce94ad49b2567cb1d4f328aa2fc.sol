
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal onlyInitializing {

    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {

    }
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

    uint256[50] private __gap;
}// BUSL-1.1

pragma solidity 0.8.11;

interface IController {


    function STARTING_DELAY() external view returns (uint256);



    function setPeriodStartingDelay(uint256 _startingDelay) external;


    function setNextPeriodSwitchTimestamp(
        uint256 _periodDuration,
        uint256 _nextPeriodTimestamp
    ) external;



    function deposit(address _futureVault, uint256 _amount) external;


    function withdraw(address _futureVault, uint256 _amount) external;


    function claimFYT(address _futureVault) external;


    function getRegistryAddress() external view returns (address);


    function getFutureIBTSymbol(
        string memory _ibtSymbol,
        string memory _platform,
        uint256 _periodDuration
    ) external pure returns (string memory);


    function getFYTSymbol(string memory _ptSymbol, uint256 _periodDuration)
        external
        view
        returns (string memory);


    function getPeriodIndex(uint256 _periodDuration)
        external
        view
        returns (uint256);


    function getNextPeriodStart(uint256 _periodDuration)
        external
        view
        returns (uint256);


    function getNextPerformanceFeeFactor(address _futureVault)
        external
        view
        returns (uint256);


    function getCurrentPerformanceFeeFactor(address _futureVault)
        external
        view
        returns (uint256);


    function getDurations() external view returns (uint256[] memory);


    function registerNewFutureVault(address _futureVault) external;


    function unregisterFutureVault(address _futureVault) external;


    function startFuturesByPeriodDuration(uint256 _periodDuration) external;


    function getFuturesWithDuration(uint256 _periodDuration)
        external
        view
        returns (address[] memory);


    function claimSelectedFYTS(address _user, address[] memory _futureVaults)
        external;


    function getRoleMember(bytes32 role, uint256 index)
        external
        view
        returns (address); // OZ ACL getter


    function isDepositsPaused(address _futureVault)
        external
        view
        returns (bool);


    function isWithdrawalsPaused(address _futureVault)
        external
        view
        returns (bool);


    function isFutureSetToBeTerminated(address _futureVault)
        external
        view
        returns (bool);

}// BUSL-1.1

pragma solidity 0.8.11;
pragma abicoder v2;

interface IAMM {

    struct Pair {
        address tokenAddress; // first is always PT
        uint256[2] weights;
        uint256[2] balances;
        bool liquidityIsInitialized;
    }

    enum AMMGlobalState {
        Created,
        Activated,
        Paused
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


    function createLiquidity(uint256 _pairID, uint256[2] memory _tokenAmounts)
        external;


    function addLiquidity(
        uint256 _pairID,
        uint256 _poolAmountOut,
        uint256[2] memory _maxAmountsIn
    ) external;


    function removeLiquidity(
        uint256 _pairID,
        uint256 _poolAmountIn,
        uint256[] calldata _minAmountsOut
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


    function getIBTAddress() external view returns (address);


    function getPTWeightInPair() external view returns (uint256);


    function getPairWithID(uint256 _pairID) external view returns (Pair memory);


    function getLPTokenId(
        uint256 _ammId,
        uint256 _periodIndex,
        uint256 _pairID
    ) external pure returns (uint256);


    function ammId() external view returns (uint64);


    function currentPeriodIndex() external view returns (uint256);


    function getTotalSupplyWithTokenId(uint256 _tokenId)
        external
        view
        returns (uint256);


    function getAMMState() external view returns (AMMGlobalState);

}// BUSL-1.1

pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

interface IAMMRegistry {

    function initialize(address _admin) external;



    function setAMMPoolByFuture(address _futureVaultAddress, address _ammPool)
        external;


    function setAMMPool(address _ammPool) external;


    function removeAMMPool(address _ammPool) external;


    function getFutureAMMPool(address _futureVaultAddress)
        external
        view
        returns (address);


    function isRegisteredAMM(address _ammAddress) external view returns (bool);

}// BUSL-1.1

pragma solidity 0.8.11;

interface IAMMRouterV1 {

    function swapExactAmountIn(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _tokenAmountIn,
        uint256 _minAmountOut,
        address _to,
        uint256 _deadline,
        address _referralRecipient
    ) external returns (uint256 tokenAmountOut);


    function swapExactAmountOut(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _maxAmountIn,
        uint256 _tokenAmountOut,
        address _to,
        uint256 _deadline,
        address _referralRecipient
    ) external returns (uint256 tokenAmountIn);


    function getSpotPrice(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath
    ) external returns (uint256 spotPrice);


    function getAmountIn(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _tokenAmountOut
    ) external view returns (uint256 tokenAmountIn);


    function getAmountOut(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _tokenAmountIn
    ) external view returns (uint256 tokenAmountOut);


    function registry() external view returns (IAMMRegistry);

}// BUSL-1.1

pragma solidity 0.8.11;


interface IERC20 is IERC20Upgradeable {

    function name() external returns (string memory);


    function symbol() external returns (string memory);


    function decimals() external view returns (uint8);


    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function mint(address to, uint256 amount) external;

}// BUSL-1.1

pragma solidity 0.8.11;


interface IPT is IERC20 {

    function burn(uint256 amount) external;


    function mint(address to, uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;


    function pause() external;


    function unpause() external;


    function recordedBalanceOf(address account) external view returns (uint256);


    function balanceOf(address account)
        external
        view
        override
        returns (uint256);


    function futureVault() external view returns (address);

}// BUSL-1.1

pragma solidity 0.8.11;

interface IRegistry {

    function setTreasury(address _newTreasury) external;


    function setController(address _newController) external;


    function setPTLogic(address _PTLogic) external;


    function setFYTLogic(address _FYTLogic) external;


    function getControllerAddress() external view returns (address);


    function getTreasuryAddress() external view returns (address);


    function getTokensFactoryAddress() external view returns (address);


    function getPTLogicAddress() external view returns (address);


    function getFYTLogicAddress() external view returns (address);


    function addFutureVault(address _future) external;


    function removeFutureVault(address _future) external;


    function isRegisteredFutureVault(address _future)
        external
        view
        returns (bool);


    function getFutureVaultAt(uint256 _index) external view returns (address);


    function futureVaultCount() external view returns (uint256);

}// BUSL-1.1

pragma solidity 0.8.11;

interface IFutureWallet {


    event YieldRedeemed(address _user, uint256 _periodIndex);
    event WithdrawalsPaused();
    event WithdrawalsResumed();

    function registerExpiredFuture(uint256 _amount) external;


    function redeemYield(uint256 _periodIndex) external;


    function getRedeemableYield(uint256 _periodIndex, address _user)
        external
        view
        returns (uint256);


    function getFutureVaultAddress() external view returns (address);


    function getIBTAddress() external view returns (address);



    function harvestRewards() external;


    function redeemAllWalletRewards() external;


    function redeemWalletRewards(address _rewardToken) external;


    function getRewardsRecipient() external view returns (address);


    function setRewardRecipient(address _recipient) external;

}// BUSL-1.1

pragma solidity 0.8.11;


interface IFutureVault {

    event NewPeriodStarted(uint256 _newPeriodIndex);
    event FutureWalletSet(address _futureWallet);
    event RegistrySet(IRegistry _registry);
    event FundsDeposited(address _user, uint256 _amount);
    event FundsWithdrawn(address _user, uint256 _amount);
    event PTSet(IPT _pt);
    event LiquidityTransfersPaused();
    event LiquidityTransfersResumed();
    event DelegationCreated(
        address _delegator,
        address _receiver,
        uint256 _amount
    );
    event DelegationRemoved(
        address _delegator,
        address _receiver,
        uint256 _amount
    );

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



    function getTotalDelegated(address _delegator)
        external
        view
        returns (uint256 totalDelegated);


    function getNextPeriodIndex() external view returns (uint256);


    function getCurrentPeriodIndex() external view returns (uint256);


    function getClaimablePT(address _user) external view returns (uint256);


    function getUserEarlyUnlockablePremium(address _user)
        external
        view
        returns (uint256 premiumLocked, uint256 amountRequired);


    function getUnlockableFunds(address _user) external view returns (uint256);


    function getClaimableFYTForPeriod(address _user, uint256 _periodIndex)
        external
        view
        returns (uint256);


    function getUnrealisedYieldPerPT() external view returns (uint256);


    function getPTPerAmountDeposited(uint256 _amount)
        external
        view
        returns (uint256);


    function getPremiumPerUnderlyingDeposited(uint256 _amount)
        external
        view
        returns (uint256);


    function getTotalUnderlyingDeposited() external view returns (uint256);


    function getYieldOfPeriod(uint256 _periodID)
        external
        view
        returns (uint256);


    function getControllerAddress() external view returns (address);


    function getFutureWalletAddress() external view returns (address);


    function getIBTAddress() external view returns (address);


    function getPTAddress() external view returns (address);


    function getFYTofPeriod(uint256 _periodIndex)
        external
        view
        returns (address);


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


    function convertIBTToUnderlying(uint256 _amount)
        external
        view
        returns (uint256);


    function convertUnderlyingtoIBT(uint256 _amount)
        external
        view
        returns (uint256);

}// BUSL-1.1

pragma solidity 0.8.11;

interface IZapDepositor {

    function depositInProtocol(address _token, uint256 _underlyingAmount)
        external
        returns (uint256);


    function depositInProtocolFrom(
        address _token,
        uint256 _underlyingAmount,
        address _from
    ) external returns (uint256);

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
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

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// BUSL-1.1

pragma solidity 0.8.11;


interface IDepositorRegistry {

    event ZapDepositorSet(address _amm, IZapDepositor _zapDepositor);

    function ZapDepositorsPerAMM(address _address)
        external
        view
        returns (IZapDepositor);


    function registry() external view returns (IAMMRegistry);


    function setZapDepositor(address _amm, IZapDepositor _zapDepositor)
        external;


    function isRegisteredZap(address _zapAddress) external view returns (bool);


    function addZap(address _zapAddress) external returns (bool);


    function removeZap(address _zapAddress) external returns (bool);


    function zapLength() external view returns (uint256);


    function zapAt(uint256 _index) external view returns (address);

}// BUSL-1.1

pragma solidity 0.8.11;


interface IERC1155 is IERC165Upgradeable {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);


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


pragma solidity 0.8.11;

interface ILPToken is IERC1155 {

    function amms(uint64 _ammId) external view returns (address);


    function getAMMId(uint256 _id) external pure returns (uint64);


    function getPeriodIndex(uint256 _id) external pure returns (uint64);


    function getPairId(uint256 _id) external pure returns (uint32);

}// BUSL-1.1

pragma solidity 0.8.11;


contract APWineZap is Initializable, ERC1155HolderUpgradeable {

    using SafeERC20Upgradeable for IERC20;
    uint256 internal constant UNIT = 10**18;
    uint256 internal constant MAX_UINT256 =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    IAMMRegistry public registry;
    IController public controller;
    IAMMRouterV1 public router;
    IDepositorRegistry public depositorRegistry;

    ILPToken public lpToken;

    modifier isValidAmm(IAMM _amm) {

        require(
            registry.isRegisteredAMM(address(_amm)),
            "AMMRouter: invalid amm address"
        );
        _;
    }

    event RegistrySet(IAMMRegistry _registry);
    event AllTokenApprovalUpdatedForAMM(IAMM _amm);
    event FYTApprovalUpdatedForAMM(IAMM _amm);
    event UnderlyingApprovalUpdatedForDepositor(
        IAMM _amm,
        IZapDepositor _zapDepositor
    );

    event ZappedInScaledToUnderlying(
        address _sender,
        IAMM _amm,
        uint256 _initialUnderlyinValue,
        uint256 _underlyingEarned,
        bool _sellAllFYTs
    );

    event ZappedInToPT(
        address _sender,
        IAMM _amm,
        uint256 _amount,
        uint256 totalPTAmount
    );

    function initialize(
        IController _controller,
        IAMMRouterV1 _router,
        IDepositorRegistry _depositorRegistry,
        ILPToken _lpToken
    ) public virtual initializer {

        registry = _depositorRegistry.registry();
        controller = _controller;
        router = _router;
        depositorRegistry = _depositorRegistry;
        lpToken = _lpToken;
    }

    function zapInScaledToUnderlying(
        IAMM _amm,
        uint256 _amount,
        uint256[] calldata _inputs,
        address _referralRecipient,
        bool _sellAllFYTs
    ) public isValidAmm(_amm) returns (uint256) {

        address underlyingAddress = _amm.getUnderlyingOfIBTAddress();
        uint256 ibtAmount =
            depositorRegistry
                .ZapDepositorsPerAMM(address(_amm))
                .depositInProtocolFrom(underlyingAddress, _amount, msg.sender);

        return
            _zapInScaledToUnderlyingWithIBT(
                _amm,
                ibtAmount,
                _inputs,
                _referralRecipient,
                _sellAllFYTs
            );
    }

    function zapInScaledToUnderlyingWithIBT(
        IAMM _amm,
        uint256 _amount,
        uint256[] calldata _inputs,
        address _referralRecipient,
        bool _sellAllFYTs
    ) public isValidAmm(_amm) returns (uint256) {

        IERC20(_amm.getIBTAddress()).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        ); // get IBT from caller
        return
            _zapInScaledToUnderlyingWithIBT(
                _amm,
                _amount,
                _inputs,
                _referralRecipient,
                _sellAllFYTs
            );
    }

    function _zapInScaledToUnderlyingWithIBT(
        IAMM _amm,
        uint256 _amount,
        uint256[] calldata _inputs,
        address _referralRecipient,
        bool _sellAllFYTs
    ) internal returns (uint256) {

        IFutureVault future = IFutureVault(_amm.getFutureAddress());

        uint256[] memory underlyingAndPTForAmount = new uint256[](2);

        underlyingAndPTForAmount[0] = future.convertIBTToUnderlying(_amount); // underlying value
        underlyingAndPTForAmount[1] = future.getPTPerAmountDeposited(_amount); // ptBalance

        controller.deposit(address(future), _amount); // deposit IBT in future

        uint256 underlyingEarned;

        if (_sellAllFYTs) {
            if (underlyingAndPTForAmount[0] != underlyingAndPTForAmount[1]) {
                underlyingEarned = _executeFYTToScaledSwaps(
                    _amm,
                    underlyingAndPTForAmount,
                    _inputs,
                    _referralRecipient
                );
            } else {
                underlyingEarned = underlyingAndPTForAmount[0];
            }
        } else {
            underlyingEarned = _executeFYTToScaledUnderlyingSwaps(
                _amm,
                underlyingAndPTForAmount,
                _inputs,
                _referralRecipient
            );
        }

        IERC20(future.getPTAddress()).safeTransfer(
            msg.sender,
            underlyingAndPTForAmount[0]
        );
        emit ZappedInScaledToUnderlying(
            msg.sender,
            _amm,
            underlyingAndPTForAmount[0],
            underlyingEarned,
            _sellAllFYTs
        );

        return underlyingEarned;
    }

    function zapInToPT(
        IAMM _amm,
        uint256 _amount,
        uint256[] calldata _inputs,
        address _referralRecipient
    ) public isValidAmm(_amm) returns (uint256) {

        address underlyingAddress = _amm.getUnderlyingOfIBTAddress();

        uint256 ibtReceived =
            depositorRegistry
                .ZapDepositorsPerAMM(address(_amm))
                .depositInProtocolFrom(underlyingAddress, _amount, msg.sender);
        return
            _zapInToPTWithIBT(_amm, ibtReceived, _inputs, _referralRecipient);
    }

    function zapInToPTWithIBT(
        IAMM _amm,
        uint256 _amount,
        uint256[] calldata _inputs,
        address _referralRecipient
    ) public isValidAmm(_amm) returns (uint256) {

        IERC20(_amm.getIBTAddress()).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        ); // get IBT from caller

        return _zapInToPTWithIBT(_amm, _amount, _inputs, _referralRecipient);
    }

    function _zapInToPTWithIBT(
        IAMM _amm,
        uint256 _amount,
        uint256[] calldata _inputs,
        address _referralRecipient
    ) internal returns (uint256) {

        IFutureVault future = IFutureVault(_amm.getFutureAddress());
        uint256 depositValue = IERC20(_amm.getIBTAddress()).balanceOf(address(this));
        
        controller.deposit(address(future), depositValue); // deposit IBT in future and get corresponding PT and FYT.

        uint256 PTBalance =
            IERC20(future.getPTAddress()).balanceOf(address(this));

        uint256 totalPTAmount =
            _executeFYTToPTSwap(_amm, PTBalance, _inputs, _referralRecipient);

        IERC20(future.getPTAddress()).safeTransfer(msg.sender, PTBalance);

        emit ZappedInToPT(msg.sender, _amm, _amount, totalPTAmount);

        return totalPTAmount;
    }

    function getUnderlyingOutFromZapScaledToUnderlying(
        IAMM _amm,
        uint256 _ibtAmountIn
    ) external view returns (uint256) {

        IFutureVault future = IFutureVault(_amm.getFutureAddress());

        uint256 underlyingValue = future.convertIBTToUnderlying(_ibtAmountIn); // underlying value
        uint256 ptBalance = future.getPTPerAmountDeposited(_ibtAmountIn); // ptBalance

        uint256[] memory pairPath = new uint256[](1);
        pairPath[0] = 1;
        uint256[] memory tokenPath = new uint256[](2);
        tokenPath[0] = 1;
        tokenPath[1] = 0;
        uint256 fytUsedForPT =
            router.getAmountIn(
                _amm,
                pairPath,
                tokenPath,
                underlyingValue - (ptBalance)
            );

        uint256 fytLeftForUnderlying = ptBalance - (fytUsedForPT);

        pairPath = new uint256[](2);
        tokenPath = new uint256[](4);
        pairPath[0] = 1;
        pairPath[1] = 0;
        tokenPath[0] = 1;
        tokenPath[1] = 0;
        tokenPath[2] = 0;
        tokenPath[3] = 1;

        uint256 underlyingOut =
            router.getAmountOut(
                _amm,
                pairPath,
                tokenPath,
                fytLeftForUnderlying
            );
        return underlyingOut;
    }

    function getPTOutFromZapToPT(IAMM _amm, uint256 _ibtAmountIn)
        external
        view
        returns (uint256)
    {

        IFutureVault future = IFutureVault(_amm.getFutureAddress());
        uint256 PTBalance = future.getPTPerAmountDeposited(_ibtAmountIn); // ptAndFytBalance
        uint256[] memory pairPath = new uint256[](1);
        pairPath[0] = 1;
        uint256[] memory tokenPath = new uint256[](2);
        tokenPath[0] = 1;
        tokenPath[1] = 0;
        uint256 PTTraded =
            router.getAmountOut(_amm, pairPath, tokenPath, PTBalance);
        return PTTraded + (PTBalance);
    }

    function _executeFYTToPTSwap(
        IAMM _amm,
        uint256 _PTBalance,
        uint256[] memory _inputs,
        address _referralRecipient
    ) internal returns (uint256) {

        uint256[] memory pairPath = new uint256[](1);
        pairPath[0] = 1;
        uint256[] memory tokenPath = new uint256[](2);
        tokenPath[0] = 1;
        tokenPath[1] = 0;
        uint256 PTEarned =
            router.swapExactAmountIn(
                _amm,
                pairPath, // e.g. [0, 1] -> will swap on pair 0 then 1
                tokenPath, // e.g. [1, 0, 0, 1] -> will swap on pair 0 from token 1 to 0, then swap on pair 1 from token 0 to 1.
                _PTBalance,
                _inputs[0] > _PTBalance ? _inputs[0] - (_PTBalance) : 0,
                msg.sender,
                _inputs[1],
                _referralRecipient
            ); // swap all FYTs against more PTs

        return PTEarned + (_PTBalance);
    }

    function _executeFYTToScaledSwaps(
        IAMM _amm,
        uint256[] memory _underlyingAndPTForAmount,
        uint256[] memory _inputs,
        address _referralRecipient
    ) internal returns (uint256) {

        uint256[] memory pairPath = new uint256[](1);
        pairPath[0] = 1;
        uint256[] memory tokenPath = new uint256[](2);
        tokenPath[0] = 1;
        tokenPath[1] = 0;

        uint256 PTstoSwap;
        {
            uint256 newPTs =
                router.swapExactAmountIn(
                    _amm,
                    pairPath,
                    tokenPath,
                    _underlyingAndPTForAmount[1],
                    0,
                    msg.sender,
                    _inputs[1],
                    _referralRecipient
                ); // swap against PT

            if (IERC20(_amm.getFYTAddress()).balanceOf(address(this)) == 0)
                return 0;

            PTstoSwap =
                newPTs -
                (_underlyingAndPTForAmount[0] - _underlyingAndPTForAmount[1]);
        }

        uint256 underlyingOut =
            router.swapExactAmountIn(
                _amm,
                pairPath,
                tokenPath,
                PTstoSwap,
                _inputs[0],
                msg.sender,
                _inputs[1],
                _referralRecipient
            ); // swap against underlying
        return underlyingOut;
    }

    function _executeFYTToScaledUnderlyingSwaps(
        IAMM _amm,
        uint256[] memory _underlyingAndPTForAmount,
        uint256[] memory _inputs,
        address _referralRecipient
    ) internal returns (uint256) {

        uint256[] memory pairPath = new uint256[](1);
        pairPath[0] = 1;
        uint256[] memory tokenPath = new uint256[](2);
        tokenPath[0] = 1;
        tokenPath[1] = 0;
        uint256 fytSold =
            router.swapExactAmountOut(
                _amm,
                pairPath,
                tokenPath,
                _underlyingAndPTForAmount[1],
                _underlyingAndPTForAmount[0] - (_underlyingAndPTForAmount[1]),
                msg.sender,
                _inputs[1],
                _referralRecipient
            ); // swap extra fyt to get an amount of pt = underlyingValue
        uint256 FYTsLeft = _underlyingAndPTForAmount[1] - (fytSold);
        IERC20(_amm.getFYTAddress()).transfer(msg.sender, FYTsLeft);
        return FYTsLeft;
    }

    function _getUnderlyingAndDepositToProtocol(IAMM _amm, uint256 _amount)
        internal
        returns (uint256)
    {

        address underlyingAddress = _amm.getUnderlyingOfIBTAddress();
        IERC20(underlyingAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        ); // get IBT from caller

        return
            depositorRegistry
                .ZapDepositorsPerAMM(address(_amm))
                .depositInProtocol(underlyingAddress, _amount);
    }

    function updateAllTokensApprovalForAMM(IAMM _amm)
        external
        isValidAmm(_amm)
    {

        IFutureVault future = IFutureVault(_amm.getFutureAddress());

        IERC20 ibt = IERC20(future.getIBTAddress());
        ibt.safeIncreaseAllowance(
            address(controller),
            MAX_UINT256 - (ibt.allowance(address(this), address(_amm)))
        ); // Approve controller for IBT

        IERC20 pt = IERC20(future.getPTAddress());
        pt.safeIncreaseAllowance(
            address(router),
            MAX_UINT256 - (pt.allowance(address(this), address(router)))
        ); // Approve router for PT
        pt.safeIncreaseAllowance(
            address(_amm),
            MAX_UINT256 - (pt.allowance(address(this), address(_amm)))
        ); // Approve amm for PT

        IERC20 underlying = IERC20(_amm.getUnderlyingOfIBTAddress());

        underlying.safeIncreaseAllowance(
            address(_amm),
            MAX_UINT256 - (underlying.allowance(address(this), address(_amm)))
        );

        IERC20 fyt =
            IERC20(future.getFYTofPeriod(future.getCurrentPeriodIndex()));
        fyt.safeIncreaseAllowance(
            address(router),
            MAX_UINT256 - (fyt.allowance(address(this), address(router)))
        ); // Approve router for FYT
        emit FYTApprovalUpdatedForAMM(_amm);
        emit AllTokenApprovalUpdatedForAMM(_amm);
    }

    function updateFYTApprovalForAMM(IAMM _amm) external isValidAmm(_amm) {

        IFutureVault future = IFutureVault(_amm.getFutureAddress());
        IERC20 fyt =
            IERC20(future.getFYTofPeriod(future.getCurrentPeriodIndex()));
        fyt.safeIncreaseAllowance(
            address(router),
            MAX_UINT256 - (fyt.allowance(address(this), address(router)))
        ); // Approve router for FYT
        emit FYTApprovalUpdatedForAMM(_amm);
    }

    function updateUnderlyingApprovalForDepositor(IAMM _amm)
        external
        isValidAmm(_amm)
    {

        IZapDepositor zapDepositor =
            depositorRegistry.ZapDepositorsPerAMM(address(_amm));
        IERC20 underlying = IERC20(_amm.getUnderlyingOfIBTAddress());
        underlying.safeIncreaseAllowance(
            address(zapDepositor),
            MAX_UINT256 -
                (underlying.allowance(address(this), address(zapDepositor)))
        );

        emit UnderlyingApprovalUpdatedForDepositor(_amm, zapDepositor);
    }
}