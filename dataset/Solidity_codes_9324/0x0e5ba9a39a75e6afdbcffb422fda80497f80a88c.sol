
pragma solidity 0.8.4;

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
}

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
}


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
}


abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}

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

library MerkleProofUpgradeable {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

interface IERC20 {

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
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

interface IMintableERC20 is IERC20Metadata {

    function mint(address _recipient, uint256 _amount) external;


    function burnFrom(address account, uint256 amount) external;


    function lowerHasMinted(uint256 amount) external;

}

library FixedPointMath {

    uint256 public constant DECIMALS = 18;
    uint256 public constant SCALAR = 10**DECIMALS;

    struct FixedDecimal {
        uint256 x;
    }

    function fromU256(uint256 value)
        internal
        pure
        returns (FixedDecimal memory)
    {

        uint256 x;
        require(value == 0 || (x = value * SCALAR) / SCALAR == value);
        return FixedDecimal(x);
    }

    function maximumValue() internal pure returns (FixedDecimal memory) {

        return FixedDecimal(type(uint256).max);
    }

    function add(FixedDecimal memory self, FixedDecimal memory value)
        internal
        pure
        returns (FixedDecimal memory)
    {

        uint256 x;
        require((x = self.x + value.x) >= self.x);
        return FixedDecimal(x);
    }

    function add(FixedDecimal memory self, uint256 value)
        internal
        pure
        returns (FixedDecimal memory)
    {

        return add(self, fromU256(value));
    }

    function sub(FixedDecimal memory self, FixedDecimal memory value)
        internal
        pure
        returns (FixedDecimal memory)
    {

        uint256 x;
        require((x = self.x - value.x) <= self.x);
        return FixedDecimal(x);
    }

    function sub(FixedDecimal memory self, uint256 value)
        internal
        pure
        returns (FixedDecimal memory)
    {

        return sub(self, fromU256(value));
    }

    function mul(FixedDecimal memory self, uint256 value)
        internal
        pure
        returns (FixedDecimal memory)
    {

        uint256 x;
        require(value == 0 || (x = self.x * value) / value == self.x);
        return FixedDecimal(x);
    }

    function div(FixedDecimal memory self, uint256 value)
        internal
        pure
        returns (FixedDecimal memory)
    {

        require(value != 0);
        return FixedDecimal(self.x / value);
    }

    function cmp(FixedDecimal memory self, FixedDecimal memory value)
        internal
        pure
        returns (int256)
    {

        if (self.x < value.x) {
            return -1;
        }

        if (self.x > value.x) {
            return 1;
        }

        return 0;
    }

    function decode(FixedDecimal memory self) internal pure returns (uint256) {

        return self.x / SCALAR;
    }
}

library MerklePool {

    using FixedPointMath for FixedPointMath.FixedDecimal;
    using MerklePool for MerklePool.Data;
    using MerklePool for MerklePool.List;

    struct Context {
        uint256 rewardRate;
        uint256 totalRewardWeight;
    }

    struct Data {
        address token;
        uint256 totalDeposited;
        uint256 totalUnclaimedTIC;
        uint256 totalUnclaimedTICInLP;
        uint256 rewardWeight;
        FixedPointMath.FixedDecimal accumulatedRewardWeight;
        uint256 lastUpdatedBlockTimestamp;
    }

    struct List {
        Data[] elements;
    }

    function update(Data storage _data, Context storage _ctx) internal {

        _data.accumulatedRewardWeight = _data.getUpdatedAccumulatedRewardWeight(
            _ctx
        );

        _data.totalUnclaimedTIC = _data.getUpdatedTotalUnclaimed(_ctx);
        _data.lastUpdatedBlockTimestamp = block.timestamp;
    }

    function getRewardRate(Data storage _data, Context storage _ctx)
        internal
        view
        returns (uint256)
    {

        if (_ctx.totalRewardWeight == 0) {
            return 0;
        }

        return (_ctx.rewardRate * _data.rewardWeight) / _ctx.totalRewardWeight;
    }

    function getUpdatedAccumulatedRewardWeight(
        Data storage _data,
        Context storage _ctx
    ) internal view returns (FixedPointMath.FixedDecimal memory) {

        if (_data.totalDeposited == 0) {
            return _data.accumulatedRewardWeight;
        }
        uint256 amountToDistribute = _data.getUpdatedAmountToDistribute(_ctx);
        if (amountToDistribute == 0) {
            return _data.accumulatedRewardWeight;
        }

        FixedPointMath.FixedDecimal memory rewardWeight =
            FixedPointMath.fromU256(amountToDistribute).div(
                _data.totalDeposited
            );

        return _data.accumulatedRewardWeight.add(rewardWeight);
    }

    function getUpdatedAmountToDistribute(
        Data storage _data,
        Context storage _ctx
    ) internal view returns (uint256) {

        uint256 elapsedTime = block.timestamp - _data.lastUpdatedBlockTimestamp;

        if (elapsedTime == 0) {
            return 0;
        }

        uint256 rewardRate = _data.getRewardRate(_ctx);
        return rewardRate * elapsedTime;
    }

    function getUpdatedTotalUnclaimed(Data storage _data, Context storage _ctx)
        internal
        view
        returns (uint256)
    {

        if (_data.totalDeposited == 0) {
            return _data.totalUnclaimedTIC;
        }
        return
            _data.totalUnclaimedTIC + _data.getUpdatedAmountToDistribute(_ctx);
    }

    function push(List storage _self, Data memory _element) internal {

        _self.elements.push(_element);
    }

    function get(List storage _self, uint256 _index)
        internal
        view
        returns (Data storage)
    {

        require(_index < _self.elements.length, "MerklePool: INVALID_INDEX");
        return _self.elements[_index];
    }

    function last(List storage _self) internal view returns (Data storage) {

        return _self.elements[_self.lastIndex()];
    }

    function lastIndex(List storage _self) internal view returns (uint256) {

        return _self.length() - 1;
    }

    function length(List storage _self) internal view returns (uint256) {

        return _self.elements.length;
    }
}

library MerkleStake {

    using FixedPointMath for FixedPointMath.FixedDecimal;
    using MerklePool for MerklePool.Data;
    using MerkleStake for MerkleStake.Data;

    struct Data {
        uint256 totalDeposited;
        uint256 totalUnrealized;
        uint256 totalRealizedTIC;
        uint256 totalRealizedLP;
        FixedPointMath.FixedDecimal lastAccumulatedWeight;
    }

    function update(
        Data storage _self,
        MerklePool.Data storage _pool,
        MerklePool.Context storage _ctx
    ) internal {

        _self.totalUnrealized = _self.getUpdatedTotalUnclaimed(_pool, _ctx);
        _self.lastAccumulatedWeight = _pool.getUpdatedAccumulatedRewardWeight(
            _ctx
        );
    }

    function getUpdatedTotalUnclaimed(
        Data storage _self,
        MerklePool.Data storage _pool,
        MerklePool.Context storage _ctx
    ) internal view returns (uint256) {

        FixedPointMath.FixedDecimal memory currentAccumulatedWeight =
            _pool.getUpdatedAccumulatedRewardWeight(_ctx);
        FixedPointMath.FixedDecimal memory lastAccumulatedWeight =
            _self.lastAccumulatedWeight;

        if (currentAccumulatedWeight.cmp(lastAccumulatedWeight) == 0) {
            return _self.totalUnrealized;
        }

        uint256 amountToDistribute =
            currentAccumulatedWeight
                .sub(lastAccumulatedWeight)
                .mul(_self.totalDeposited)
                .decode();

        return _self.totalUnrealized + amountToDistribute;
    }
}

contract MerklePoolsStorage {

    IMintableERC20 public ticToken; // token which will be minted as a reward for staking.
    uint256 public excessTICFromSlippage; // extra TIC that can be used before next mint

    address public quoteToken; // other half of the LP token (not the reward token)
    address public elasticLPToken; // elastic LP token we create to emit for claimed rewards
    address public governance;
    address public pendingGovernance;
    address public forfeitAddress; // receives all unclaimed TIC when someone exits

    bytes32 public merkleRoot;
    bool public isClaimsEnabled; // disabled flag until first merkle proof is set.

    mapping(address => uint256) public tokenPoolIds;

    MerklePool.Context public poolContext; // The context shared between the pools.
    MerklePool.List internal pools; // A list of all of the pools.

    mapping(address => mapping(uint256 => MerkleStake.Data)) public stakes;
}

library MathLib {

    struct InternalBalances {
        uint256 baseTokenReserveQty; // x
        uint256 quoteTokenReserveQty; // y
        uint256 kLast; // as of the last add / rem liquidity event
    }

    struct TokenQtys {
        uint256 baseTokenQty;
        uint256 quoteTokenQty;
        uint256 liquidityTokenQty;
        uint256 liquidityTokenFeeQty;
    }

    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant WAD = 1e18; // represent a decimal with 18 digits of precision

    function wDiv(uint256 a, uint256 b) public pure returns (uint256) {

        return ((a * WAD) + (b / 2)) / b;
    }

    function roundToNearest(uint256 a, uint256 n)
        public
        pure
        returns (uint256)
    {

        return ((a + (n / 2)) / n) * n;
    }

    function wMul(uint256 a, uint256 b) public pure returns (uint256) {

        return ((a * b) + (WAD / 2)) / WAD;
    }

    function diff(uint256 a, uint256 b) public pure returns (uint256) {

        if (a >= b) {
            return a - b;
        }
        return b - a;
    }

    function sqrt(uint256 x) public pure returns (uint256 y) {

        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function isSufficientDecayPresent(
        uint256 _baseTokenReserveQty,
        InternalBalances memory _internalBalances
    ) public pure returns (bool) {

        return (wDiv(
            diff(_baseTokenReserveQty, _internalBalances.baseTokenReserveQty) *
                WAD,
            wDiv(
                _internalBalances.baseTokenReserveQty,
                _internalBalances.quoteTokenReserveQty
            )
        ) >= WAD); // the amount of base token (a) decay is greater than 1 unit of quote token (token b)
    }

    function calculateQty(
        uint256 _tokenAQty,
        uint256 _tokenAReserveQty,
        uint256 _tokenBReserveQty
    ) public pure returns (uint256 tokenBQty) {

        require(_tokenAQty != 0, "MathLib: INSUFFICIENT_QTY");
        require(
            _tokenAReserveQty != 0 && _tokenBReserveQty != 0,
            "MathLib: INSUFFICIENT_LIQUIDITY"
        );
        tokenBQty = (_tokenAQty * _tokenBReserveQty) / _tokenAReserveQty;
    }

    function calculateQtyToReturnAfterFees(
        uint256 _tokenASwapQty,
        uint256 _tokenAReserveQty,
        uint256 _tokenBReserveQty,
        uint256 _liquidityFeeInBasisPoints
    ) public pure returns (uint256 qtyToReturn) {

        uint256 tokenASwapQtyLessFee =
            _tokenASwapQty * (BASIS_POINTS - _liquidityFeeInBasisPoints);
        qtyToReturn =
            (tokenASwapQtyLessFee * _tokenBReserveQty) /
            ((_tokenAReserveQty * BASIS_POINTS) + tokenASwapQtyLessFee);
    }

    function calculateLiquidityTokenQtyForSingleAssetEntryWithBaseTokenDecay(
        uint256 _baseTokenReserveBalance,
        uint256 _totalSupplyOfLiquidityTokens,
        uint256 _tokenQtyAToAdd,
        uint256 _internalTokenAReserveQty,
        uint256 _omega
    ) public pure returns (uint256 liquidityTokenQty) {

        uint256 wRatio = wDiv(_baseTokenReserveBalance, _omega);
        uint256 denominator = wRatio + _internalTokenAReserveQty;
        uint256 wGamma = wDiv(_tokenQtyAToAdd, denominator);

        liquidityTokenQty =
            wDiv(
                wMul(_totalSupplyOfLiquidityTokens * WAD, wGamma),
                WAD - wGamma
            ) /
            WAD;
    }

    function calculateLiquidityTokenQtyForSingleAssetEntryWithQuoteTokenDecay(
        uint256 _baseTokenReserveBalance,
        uint256 _totalSupplyOfLiquidityTokens,
        uint256 _tokenQtyAToAdd,
        uint256 _internalTokenAReserveQty
    ) public pure returns (uint256 liquidityTokenQty) {


        uint256 denominator =
            _internalTokenAReserveQty +
                _baseTokenReserveBalance +
                _tokenQtyAToAdd;
        uint256 wGamma = wDiv(_tokenQtyAToAdd, denominator);

        liquidityTokenQty =
            wDiv(
                wMul(_totalSupplyOfLiquidityTokens * WAD, wGamma),
                WAD - wGamma
            ) /
            WAD;
    }

    function calculateLiquidityTokenQtyForDoubleAssetEntry(
        uint256 _totalSupplyOfLiquidityTokens,
        uint256 _quoteTokenQty,
        uint256 _quoteTokenReserveBalance
    ) public pure returns (uint256 liquidityTokenQty) {

        liquidityTokenQty =
            (_quoteTokenQty * _totalSupplyOfLiquidityTokens) /
            _quoteTokenReserveBalance;
    }

    function calculateAddQuoteTokenLiquidityQuantities(
        uint256 _quoteTokenQtyDesired,
        uint256 _baseTokenReserveQty,
        uint256 _totalSupplyOfLiquidityTokens,
        InternalBalances storage _internalBalances
    ) public returns (uint256 quoteTokenQty, uint256 liquidityTokenQty) {

        uint256 baseTokenDecay =
            _baseTokenReserveQty - _internalBalances.baseTokenReserveQty;

        uint256 wInternalBaseTokenToQuoteTokenRatio =
            wDiv(
                _internalBalances.baseTokenReserveQty,
                _internalBalances.quoteTokenReserveQty
            );

        uint256 maxQuoteTokenQty =
            wDiv(baseTokenDecay, wInternalBaseTokenToQuoteTokenRatio);

        if (_quoteTokenQtyDesired > maxQuoteTokenQty) {
            quoteTokenQty = maxQuoteTokenQty;
        } else {
            quoteTokenQty = _quoteTokenQtyDesired;
        }

        uint256 baseTokenQtyDecayChange =
            roundToNearest(
                (quoteTokenQty * wInternalBaseTokenToQuoteTokenRatio),
                WAD
            ) / WAD;

        require(
            baseTokenQtyDecayChange != 0,
            "MathLib: INSUFFICIENT_CHANGE_IN_DECAY"
        );
        _internalBalances.baseTokenReserveQty += baseTokenQtyDecayChange;
        _internalBalances.quoteTokenReserveQty += quoteTokenQty;

        liquidityTokenQty = calculateLiquidityTokenQtyForSingleAssetEntryWithBaseTokenDecay(
            _baseTokenReserveQty,
            _totalSupplyOfLiquidityTokens,
            quoteTokenQty,
            _internalBalances.quoteTokenReserveQty,
            wInternalBaseTokenToQuoteTokenRatio
        );
        return (quoteTokenQty, liquidityTokenQty);
    }

    function calculateAddBaseTokenLiquidityQuantities(
        uint256 _baseTokenQtyDesired,
        uint256 _baseTokenQtyMin,
        uint256 _baseTokenReserveQty,
        uint256 _totalSupplyOfLiquidityTokens,
        InternalBalances memory _internalBalances
    ) public pure returns (uint256 baseTokenQty, uint256 liquidityTokenQty) {

        uint256 maxBaseTokenQty =
            _internalBalances.baseTokenReserveQty - _baseTokenReserveQty;
        require(
            _baseTokenQtyMin <= maxBaseTokenQty,
            "MathLib: INSUFFICIENT_DECAY"
        );

        if (_baseTokenQtyDesired > maxBaseTokenQty) {
            baseTokenQty = maxBaseTokenQty;
        } else {
            baseTokenQty = _baseTokenQtyDesired;
        }

        uint256 wInternalQuoteToBaseTokenRatio =
            wDiv(
                _internalBalances.quoteTokenReserveQty,
                _internalBalances.baseTokenReserveQty
            );

        uint256 quoteTokenQtyDecayChange =
            roundToNearest(
                (baseTokenQty * wInternalQuoteToBaseTokenRatio),
                MathLib.WAD
            ) / WAD;

        require(
            quoteTokenQtyDecayChange != 0,
            "MathLib: INSUFFICIENT_CHANGE_IN_DECAY"
        );

        uint256 quoteTokenDecay =
            (maxBaseTokenQty * wInternalQuoteToBaseTokenRatio) / WAD;

        require(quoteTokenDecay != 0, "MathLib: NO_QUOTE_DECAY");


        liquidityTokenQty = calculateLiquidityTokenQtyForSingleAssetEntryWithQuoteTokenDecay(
            _baseTokenReserveQty,
            _totalSupplyOfLiquidityTokens,
            baseTokenQty,
            _internalBalances.baseTokenReserveQty
        );
    }

    function calculateAddLiquidityQuantities(
        uint256 _baseTokenQtyDesired,
        uint256 _quoteTokenQtyDesired,
        uint256 _baseTokenQtyMin,
        uint256 _quoteTokenQtyMin,
        uint256 _baseTokenReserveQty,
        uint256 _totalSupplyOfLiquidityTokens,
        InternalBalances storage _internalBalances
    ) public returns (TokenQtys memory tokenQtys) {

        if (_totalSupplyOfLiquidityTokens != 0) {

            tokenQtys.liquidityTokenFeeQty = calculateLiquidityTokenFees(
                _totalSupplyOfLiquidityTokens,
                _internalBalances
            );

            _totalSupplyOfLiquidityTokens += tokenQtys.liquidityTokenFeeQty;

            if (
                isSufficientDecayPresent(
                    _baseTokenReserveQty,
                    _internalBalances
                )
            ) {

                uint256 baseTokenQtyFromDecay;
                uint256 quoteTokenQtyFromDecay;
                uint256 liquidityTokenQtyFromDecay;

                if (
                    _baseTokenReserveQty > _internalBalances.baseTokenReserveQty
                ) {
                    (
                        quoteTokenQtyFromDecay,
                        liquidityTokenQtyFromDecay
                    ) = calculateAddQuoteTokenLiquidityQuantities(
                        _quoteTokenQtyDesired,
                        _baseTokenReserveQty,
                        _totalSupplyOfLiquidityTokens,
                        _internalBalances
                    );
                } else {
                    (
                        baseTokenQtyFromDecay,
                        liquidityTokenQtyFromDecay
                    ) = calculateAddBaseTokenLiquidityQuantities(
                        _baseTokenQtyDesired,
                        0, // there is no minimum for this particular call since we may use base tokens later.
                        _baseTokenReserveQty,
                        _totalSupplyOfLiquidityTokens,
                        _internalBalances
                    );
                }

                if (
                    quoteTokenQtyFromDecay < _quoteTokenQtyDesired &&
                    baseTokenQtyFromDecay < _baseTokenQtyDesired
                ) {
                    (
                        tokenQtys.baseTokenQty,
                        tokenQtys.quoteTokenQty,
                        tokenQtys.liquidityTokenQty
                    ) = calculateAddTokenPairLiquidityQuantities(
                        _baseTokenQtyDesired - baseTokenQtyFromDecay, // safe from underflow quoted on above IF
                        _quoteTokenQtyDesired - quoteTokenQtyFromDecay, // safe from underflow quoted on above IF
                        0, // we will check minimums below
                        0, // we will check minimums below
                        _totalSupplyOfLiquidityTokens +
                            liquidityTokenQtyFromDecay,
                        _internalBalances // NOTE: these balances have already been updated when we did the decay math.
                    );
                }
                tokenQtys.baseTokenQty += baseTokenQtyFromDecay;
                tokenQtys.quoteTokenQty += quoteTokenQtyFromDecay;
                tokenQtys.liquidityTokenQty += liquidityTokenQtyFromDecay;

                require(
                    tokenQtys.baseTokenQty >= _baseTokenQtyMin,
                    "MathLib: INSUFFICIENT_BASE_QTY"
                );

                require(
                    tokenQtys.quoteTokenQty >= _quoteTokenQtyMin,
                    "MathLib: INSUFFICIENT_QUOTE_QTY"
                );
            } else {
                (
                    tokenQtys.baseTokenQty,
                    tokenQtys.quoteTokenQty,
                    tokenQtys.liquidityTokenQty
                ) = calculateAddTokenPairLiquidityQuantities(
                    _baseTokenQtyDesired,
                    _quoteTokenQtyDesired,
                    _baseTokenQtyMin,
                    _quoteTokenQtyMin,
                    _totalSupplyOfLiquidityTokens,
                    _internalBalances
                );
            }
        } else {
            require(
                _baseTokenQtyDesired != 0,
                "MathLib: INSUFFICIENT_BASE_QTY_DESIRED"
            );
            require(
                _quoteTokenQtyDesired != 0,
                "MathLib: INSUFFICIENT_QUOTE_QTY_DESIRED"
            );

            tokenQtys.baseTokenQty = _baseTokenQtyDesired;
            tokenQtys.quoteTokenQty = _quoteTokenQtyDesired;
            tokenQtys.liquidityTokenQty = sqrt(
                _baseTokenQtyDesired * _quoteTokenQtyDesired
            );

            _internalBalances.baseTokenReserveQty += tokenQtys.baseTokenQty;
            _internalBalances.quoteTokenReserveQty += tokenQtys.quoteTokenQty;
        }
    }

    function calculateAddTokenPairLiquidityQuantities(
        uint256 _baseTokenQtyDesired,
        uint256 _quoteTokenQtyDesired,
        uint256 _baseTokenQtyMin,
        uint256 _quoteTokenQtyMin,
        uint256 _totalSupplyOfLiquidityTokens,
        InternalBalances storage _internalBalances
    )
        public
        returns (
            uint256 baseTokenQty,
            uint256 quoteTokenQty,
            uint256 liquidityTokenQty
        )
    {

        uint256 requiredQuoteTokenQty =
            calculateQty(
                _baseTokenQtyDesired,
                _internalBalances.baseTokenReserveQty,
                _internalBalances.quoteTokenReserveQty
            );

        if (requiredQuoteTokenQty <= _quoteTokenQtyDesired) {
            require(
                requiredQuoteTokenQty >= _quoteTokenQtyMin,
                "MathLib: INSUFFICIENT_QUOTE_QTY"
            );
            baseTokenQty = _baseTokenQtyDesired;
            quoteTokenQty = requiredQuoteTokenQty;
        } else {
            uint256 requiredBaseTokenQty =
                calculateQty(
                    _quoteTokenQtyDesired,
                    _internalBalances.quoteTokenReserveQty,
                    _internalBalances.baseTokenReserveQty
                );

            require(
                requiredBaseTokenQty >= _baseTokenQtyMin,
                "MathLib: INSUFFICIENT_BASE_QTY"
            );
            baseTokenQty = requiredBaseTokenQty;
            quoteTokenQty = _quoteTokenQtyDesired;
        }

        liquidityTokenQty = calculateLiquidityTokenQtyForDoubleAssetEntry(
            _totalSupplyOfLiquidityTokens,
            quoteTokenQty,
            _internalBalances.quoteTokenReserveQty
        );

        _internalBalances.baseTokenReserveQty += baseTokenQty;
        _internalBalances.quoteTokenReserveQty += quoteTokenQty;
    }

    function calculateBaseTokenQty(
        uint256 _quoteTokenQty,
        uint256 _baseTokenQtyMin,
        uint256 _baseTokenReserveQty,
        uint256 _liquidityFeeInBasisPoints,
        InternalBalances storage _internalBalances
    ) public returns (uint256 baseTokenQty) {

        require(
            _baseTokenReserveQty != 0 &&
                _internalBalances.baseTokenReserveQty != 0,
            "MathLib: INSUFFICIENT_BASE_TOKEN_QTY"
        );

        if (_baseTokenReserveQty < _internalBalances.baseTokenReserveQty) {
            uint256 wPricingRatio =
                wDiv(
                    _internalBalances.baseTokenReserveQty,
                    _internalBalances.quoteTokenReserveQty
                ); // omega

            uint256 impliedQuoteTokenQty =
                wDiv(_baseTokenReserveQty, wPricingRatio); // no need to divide by WAD, wPricingRatio is already a WAD.

            baseTokenQty = calculateQtyToReturnAfterFees(
                _quoteTokenQty,
                impliedQuoteTokenQty,
                _baseTokenReserveQty, // use the actual balance here since we adjusted the quote token to match ratio!
                _liquidityFeeInBasisPoints
            );
        } else {
            baseTokenQty = calculateQtyToReturnAfterFees(
                _quoteTokenQty,
                _internalBalances.quoteTokenReserveQty,
                _internalBalances.baseTokenReserveQty,
                _liquidityFeeInBasisPoints
            );
        }

        require(
            baseTokenQty >= _baseTokenQtyMin,
            "MathLib: INSUFFICIENT_BASE_TOKEN_QTY"
        );

        _internalBalances.baseTokenReserveQty -= baseTokenQty;
        _internalBalances.quoteTokenReserveQty += _quoteTokenQty;
    }

    function calculateQuoteTokenQty(
        uint256 _baseTokenQty,
        uint256 _quoteTokenQtyMin,
        uint256 _liquidityFeeInBasisPoints,
        InternalBalances storage _internalBalances
    ) public returns (uint256 quoteTokenQty) {

        require(
            _baseTokenQty != 0 && _quoteTokenQtyMin != 0,
            "MathLib: INSUFFICIENT_TOKEN_QTY"
        );

        quoteTokenQty = calculateQtyToReturnAfterFees(
            _baseTokenQty,
            _internalBalances.baseTokenReserveQty,
            _internalBalances.quoteTokenReserveQty,
            _liquidityFeeInBasisPoints
        );

        require(
            quoteTokenQty >= _quoteTokenQtyMin,
            "MathLib: INSUFFICIENT_QUOTE_TOKEN_QTY"
        );

        _internalBalances.baseTokenReserveQty += _baseTokenQty;
        _internalBalances.quoteTokenReserveQty -= quoteTokenQty;
    }

    function calculateLiquidityTokenFees(
        uint256 _totalSupplyOfLiquidityTokens,
        InternalBalances memory _internalBalances
    ) public pure returns (uint256 liquidityTokenFeeQty) {

        uint256 rootK =
            sqrt(
                _internalBalances.baseTokenReserveQty *
                    _internalBalances.quoteTokenReserveQty
            );
        uint256 rootKLast = sqrt(_internalBalances.kLast);
        if (rootK > rootKLast) {
            uint256 numerator =
                _totalSupplyOfLiquidityTokens * (rootK - rootKLast);
            uint256 denominator = (rootK * 5) + rootKLast;
            liquidityTokenFeeQty = numerator / denominator;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

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
}

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
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IExchangeFactory {
    function feeAddress() external view returns (address);
}


contract Exchange is ERC20, ReentrancyGuard {
    using MathLib for uint256;
    using SafeERC20 for IERC20;

    address public immutable baseToken; // address of ERC20 base token (elastic or fixed supply)
    address public immutable quoteToken; // address of ERC20 quote token (WETH or a stable coin w/ fixed supply)
    address public immutable exchangeFactoryAddress;

    uint256 public constant TOTAL_LIQUIDITY_FEE = 30; // fee provided to liquidity providers + DAO in basis points
    uint256 public constant MINIMUM_LIQUIDITY = 1e3;

    MathLib.InternalBalances public internalBalances;

    event AddLiquidity(
        address indexed liquidityProvider,
        uint256 baseTokenQtyAdded,
        uint256 quoteTokenQtyAdded
    );
    event RemoveLiquidity(
        address indexed liquidityProvider,
        uint256 baseTokenQtyRemoved,
        uint256 quoteTokenQtyRemoved
    );
    event Swap(
        address indexed sender,
        uint256 baseTokenQtyIn,
        uint256 quoteTokenQtyIn,
        uint256 baseTokenQtyOut,
        uint256 quoteTokenQtyOut
    );

    modifier isNotExpired(uint256 _expirationTimeStamp) {
        require(_expirationTimeStamp >= block.timestamp, "Exchange: EXPIRED");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _baseToken,
        address _quoteToken,
        address _exchangeFactoryAddress
    ) ERC20(_name, _symbol) {
        baseToken = _baseToken;
        quoteToken = _quoteToken;
        exchangeFactoryAddress = _exchangeFactoryAddress;
    }

    function addLiquidity(
        uint256 _baseTokenQtyDesired,
        uint256 _quoteTokenQtyDesired,
        uint256 _baseTokenQtyMin,
        uint256 _quoteTokenQtyMin,
        address _liquidityTokenRecipient,
        uint256 _expirationTimestamp
    ) external nonReentrant() isNotExpired(_expirationTimestamp) {
        uint256 totalSupply = this.totalSupply();
        MathLib.TokenQtys memory tokenQtys =
            MathLib.calculateAddLiquidityQuantities(
                _baseTokenQtyDesired,
                _quoteTokenQtyDesired,
                _baseTokenQtyMin,
                _quoteTokenQtyMin,
                IERC20(baseToken).balanceOf(address(this)),
                totalSupply,
                internalBalances
            );

        internalBalances.kLast =
            internalBalances.baseTokenReserveQty *
            internalBalances.quoteTokenReserveQty;

        if (tokenQtys.liquidityTokenFeeQty != 0) {
            _mint(
                IExchangeFactory(exchangeFactoryAddress).feeAddress(),
                tokenQtys.liquidityTokenFeeQty
            );
        }

        bool isExchangeEmpty = totalSupply == 0;
        if (isExchangeEmpty) {
            require(
                tokenQtys.liquidityTokenQty > MINIMUM_LIQUIDITY,
                "Exchange: INITIAL_DEPOSIT_MIN"
            );
            unchecked {
                tokenQtys.liquidityTokenQty -= MINIMUM_LIQUIDITY;
            }
            _mint(address(this), MINIMUM_LIQUIDITY); // mint to this address, total supply will never be 0 again
        }

        _mint(_liquidityTokenRecipient, tokenQtys.liquidityTokenQty); // mint liquidity tokens to recipient

        if (tokenQtys.baseTokenQty != 0) {
            IERC20(baseToken).safeTransferFrom(
                msg.sender,
                address(this),
                tokenQtys.baseTokenQty
            );

            if (isExchangeEmpty) {
                require(
                    IERC20(baseToken).balanceOf(address(this)) ==
                        tokenQtys.baseTokenQty,
                    "Exchange: FEE_ON_TRANSFER_NOT_SUPPORTED"
                );
            }
        }

        if (tokenQtys.quoteTokenQty != 0) {
            IERC20(quoteToken).safeTransferFrom(
                msg.sender,
                address(this),
                tokenQtys.quoteTokenQty
            );
        }

        emit AddLiquidity(
            msg.sender,
            tokenQtys.baseTokenQty,
            tokenQtys.quoteTokenQty
        );
    }

    function removeLiquidity(
        uint256 _liquidityTokenQty,
        uint256 _baseTokenQtyMin,
        uint256 _quoteTokenQtyMin,
        address _tokenRecipient,
        uint256 _expirationTimestamp
    ) external nonReentrant() isNotExpired(_expirationTimestamp) {
        require(this.totalSupply() != 0, "Exchange: INSUFFICIENT_LIQUIDITY");
        require(
            _baseTokenQtyMin != 0 && _quoteTokenQtyMin != 0,
            "Exchange: MINS_MUST_BE_GREATER_THAN_ZERO"
        );

        uint256 baseTokenReserveQty =
            IERC20(baseToken).balanceOf(address(this));
        uint256 quoteTokenReserveQty =
            IERC20(quoteToken).balanceOf(address(this));

        uint256 totalSupplyOfLiquidityTokens = this.totalSupply();
        uint256 liquidityTokenFeeQty =
            MathLib.calculateLiquidityTokenFees(
                totalSupplyOfLiquidityTokens,
                internalBalances
            );

        totalSupplyOfLiquidityTokens += liquidityTokenFeeQty;

        uint256 baseTokenQtyToReturn =
            (_liquidityTokenQty * baseTokenReserveQty) /
                totalSupplyOfLiquidityTokens;
        uint256 quoteTokenQtyToReturn =
            (_liquidityTokenQty * quoteTokenReserveQty) /
                totalSupplyOfLiquidityTokens;

        require(
            baseTokenQtyToReturn >= _baseTokenQtyMin,
            "Exchange: INSUFFICIENT_BASE_QTY"
        );

        require(
            quoteTokenQtyToReturn >= _quoteTokenQtyMin,
            "Exchange: INSUFFICIENT_QUOTE_QTY"
        );

        {
            uint256 internalBaseTokenReserveQty =
                internalBalances.baseTokenReserveQty;
            uint256 baseTokenQtyToRemoveFromInternalAccounting =
                (_liquidityTokenQty * internalBaseTokenReserveQty) /
                    totalSupplyOfLiquidityTokens;

            internalBalances.baseTokenReserveQty = internalBaseTokenReserveQty =
                internalBaseTokenReserveQty -
                baseTokenQtyToRemoveFromInternalAccounting;

            uint256 internalQuoteTokenReserveQty =
                internalBalances.quoteTokenReserveQty;
            if (quoteTokenQtyToReturn > internalQuoteTokenReserveQty) {
                internalBalances
                    .quoteTokenReserveQty = internalQuoteTokenReserveQty = 0;
            } else {
                internalBalances
                    .quoteTokenReserveQty = internalQuoteTokenReserveQty =
                    internalQuoteTokenReserveQty -
                    quoteTokenQtyToReturn;
            }

            internalBalances.kLast =
                internalBaseTokenReserveQty *
                internalQuoteTokenReserveQty;
        }

        if (liquidityTokenFeeQty != 0) {
            _mint(
                IExchangeFactory(exchangeFactoryAddress).feeAddress(),
                liquidityTokenFeeQty
            );
        }

        _burn(msg.sender, _liquidityTokenQty);
        IERC20(baseToken).safeTransfer(_tokenRecipient, baseTokenQtyToReturn);
        IERC20(quoteToken).safeTransfer(_tokenRecipient, quoteTokenQtyToReturn);
        emit RemoveLiquidity(
            msg.sender,
            baseTokenQtyToReturn,
            quoteTokenQtyToReturn
        );
    }

    function swapBaseTokenForQuoteToken(
        uint256 _baseTokenQty,
        uint256 _minQuoteTokenQty,
        uint256 _expirationTimestamp
    ) external nonReentrant() isNotExpired(_expirationTimestamp) {
        require(
            _baseTokenQty != 0 && _minQuoteTokenQty != 0,
            "Exchange: INSUFFICIENT_TOKEN_QTY"
        );

        uint256 quoteTokenQty =
            MathLib.calculateQuoteTokenQty(
                _baseTokenQty,
                _minQuoteTokenQty,
                TOTAL_LIQUIDITY_FEE,
                internalBalances
            );

        IERC20(baseToken).safeTransferFrom(
            msg.sender,
            address(this),
            _baseTokenQty
        );

        IERC20(quoteToken).safeTransfer(msg.sender, quoteTokenQty);
        emit Swap(msg.sender, _baseTokenQty, 0, 0, quoteTokenQty);
    }

    function swapQuoteTokenForBaseToken(
        uint256 _quoteTokenQty,
        uint256 _minBaseTokenQty,
        uint256 _expirationTimestamp
    ) external nonReentrant() isNotExpired(_expirationTimestamp) {
        require(
            _quoteTokenQty != 0 && _minBaseTokenQty != 0,
            "Exchange: INSUFFICIENT_TOKEN_QTY"
        );

        uint256 baseTokenQty =
            MathLib.calculateBaseTokenQty(
                _quoteTokenQty,
                _minBaseTokenQty,
                IERC20(baseToken).balanceOf(address(this)),
                TOTAL_LIQUIDITY_FEE,
                internalBalances
            );

        IERC20(quoteToken).safeTransferFrom(
            msg.sender,
            address(this),
            _quoteTokenQty
        );

        IERC20(baseToken).safeTransfer(msg.sender, baseTokenQty);
        emit Swap(msg.sender, 0, _quoteTokenQty, baseTokenQty, 0);
    }
}

contract MerklePools is MerklePoolsStorage, ReentrancyGuardUpgradeable {
    using FixedPointMath for FixedPointMath.FixedDecimal;
    using MerklePool for MerklePool.Data;
    using MerklePool for MerklePool.List;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using MerkleStake for MerkleStake.Data;

    event PendingGovernanceUpdated(address pendingGovernance);

    event GovernanceUpdated(address governance);

    event ForfeitAddressUpdated(address governance);

    event RewardRateUpdated(uint256 rewardRate);

    event PoolRewardWeightUpdated(uint256 indexed poolId, uint256 rewardWeight);

    event PoolCreated(uint256 indexed poolId, address indexed token);

    event TokensDeposited(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount
    );

    event TokensWithdrawn(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount
    );

    event TokensClaimed(
        address indexed user,
        uint256 index,
        uint256 indexed poolId,
        uint256 lpTokenAmountClaimed,
        uint256 ticTokenAmountClaimed
    );

    event MerkleRootUpdated(bytes32 merkleRoot);
    event LPTokensGenerated(
        uint256 lpAmountCreated,
        uint256 ticConsumed,
        uint256 quoteTokenConsumed
    );

    constructor() {}

    function initialize(
        IMintableERC20 _ticToken,
        address _quoteToken,
        address _elasticLPToken,
        address _governance,
        address _forfeitAddress
    ) external initializer {
        require(_governance != address(0), "MerklePools: INVALID_ADDRESS");
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        ticToken = _ticToken;
        governance = _governance;
        elasticLPToken = _elasticLPToken;
        quoteToken = _quoteToken;
        forfeitAddress = _forfeitAddress;

        if (address(_ticToken) != address(0)) {
            _ticToken.approve(address(_elasticLPToken), type(uint256).max);
        }
        if (_elasticLPToken != address(0)) {
            IERC20Upgradeable(_quoteToken).approve(
                address(_elasticLPToken),
                type(uint256).max
            );
        }
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "MerklePools: ONLY_GOVERNANCE");
        _;
    }

    function setPendingGovernance(address _pendingGovernance)
        external
        onlyGovernance
    {
        require(
            _pendingGovernance != address(0),
            "MerklePools: INVALID_ADDRESS"
        );
        pendingGovernance = _pendingGovernance;

        emit PendingGovernanceUpdated(_pendingGovernance);
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "MerklePools: ONLY_PENDING");

        address pendingGovernance_ = msg.sender;
        governance = pendingGovernance_;

        emit GovernanceUpdated(pendingGovernance_);
    }

    function setRewardRate(uint256 _rewardRate) external onlyGovernance {
        _updatePools();

        poolContext.rewardRate = _rewardRate;

        emit RewardRateUpdated(_rewardRate);
    }

    function setForfeitAddress(address _forfeitAddress)
        external
        onlyGovernance
    {
        require(_forfeitAddress != forfeitAddress, "MerklePools: SAME_ADDRESS");
        forfeitAddress = _forfeitAddress;
        emit ForfeitAddressUpdated(_forfeitAddress);
    }

    function setTicTokenAddress(IMintableERC20 _ticToken)
        external
        onlyGovernance
    {
        require(
            address(ticToken) == address(0),
            "MerklePools: TIC_ALREADY_SET"
        );
        require(
            address(_ticToken) != address(0),
            "MerklePools: INVALID_ADDRESS"
        );
        require(elasticLPToken != address(0), "MerklePools: ELP_NOT_SET");

        ticToken = _ticToken;
        _ticToken.approve(address(elasticLPToken), type(uint256).max);
    }

    function setElasticLPTokenAddress(address _elasticLPToken)
        external
        onlyGovernance
    {
        require(elasticLPToken == address(0), "MerklePools: ELP_ALREADY_SET");
        require(_elasticLPToken != address(0), "MerklePools: INVALID_ADDRESS");

        elasticLPToken = _elasticLPToken;
        IERC20Upgradeable(quoteToken).approve(
            address(_elasticLPToken),
            type(uint256).max
        );
    }

    function createPool(address _token)
        external
        onlyGovernance
        returns (uint256)
    {
        require(tokenPoolIds[_token] == 0, "MerklePools: ALREADY_CREATED");

        uint256 poolId = pools.length();

        pools.push(
            MerklePool.Data({
                token: _token,
                totalDeposited: 0,
                totalUnclaimedTIC: 0,
                totalUnclaimedTICInLP: 0,
                rewardWeight: 0,
                accumulatedRewardWeight: FixedPointMath.FixedDecimal(0),
                lastUpdatedBlockTimestamp: block.timestamp
            })
        );

        tokenPoolIds[_token] = poolId + 1;

        emit PoolCreated(poolId, _token);

        return poolId;
    }

    function setRewardWeights(uint256[] calldata _rewardWeights)
        external
        onlyGovernance
    {
        uint256 poolsLength = pools.length();
        require(
            _rewardWeights.length == poolsLength,
            "MerklePools: LENGTH_MISMATCH"
        );

        _updatePools();
        uint256 totalRewardWeight_ = poolContext.totalRewardWeight;
        for (uint256 _poolId = 0; _poolId < poolsLength; _poolId++) {
            MerklePool.Data storage _pool = pools.get(_poolId);

            uint256 _currentRewardWeight = _pool.rewardWeight;
            if (_currentRewardWeight == _rewardWeights[_poolId]) {
                continue;
            }

            totalRewardWeight_ =
                totalRewardWeight_ -
                _currentRewardWeight +
                _rewardWeights[_poolId];
            _pool.rewardWeight = _rewardWeights[_poolId];

            emit PoolRewardWeightUpdated(_poolId, _rewardWeights[_poolId]);
        }
        poolContext.totalRewardWeight = totalRewardWeight_;
    }

    function deposit(uint256 _poolId, uint256 _depositAmount)
        external
        nonReentrant
    {
        require(msg.sender != forfeitAddress, "MerklePools: UNUSABLE_ADDRESS");
        MerklePool.Data storage pool = pools.get(_poolId);
        pool.update(poolContext);

        MerkleStake.Data storage stake = stakes[msg.sender][_poolId];
        stake.update(pool, poolContext);

        pool.totalDeposited = pool.totalDeposited + _depositAmount;
        stake.totalDeposited = stake.totalDeposited + _depositAmount;

        IERC20Upgradeable(pool.token).safeTransferFrom(
            msg.sender,
            address(this),
            _depositAmount
        );
        emit TokensDeposited(msg.sender, _poolId, _depositAmount);
    }

    function exit(uint256 _poolId) external nonReentrant {
        require(msg.sender != forfeitAddress, "MerklePools: UNUSABLE_ADDRESS");
        MerklePool.Data storage pool = pools.get(_poolId);
        pool.update(poolContext);

        MerkleStake.Data storage stake = stakes[msg.sender][_poolId];
        stake.update(pool, poolContext);

        uint256 withdrawAmount = stake.totalDeposited;
        pool.totalDeposited = pool.totalDeposited - withdrawAmount;
        stake.totalDeposited = 0;

        MerkleStake.Data storage forfeitStake = stakes[forfeitAddress][_poolId];
        forfeitStake.update(pool, poolContext);

        forfeitStake.totalUnrealized += stake.totalUnrealized;

        stake.totalRealizedTIC += stake.totalUnrealized;
        stake.totalUnrealized = 0;

        IERC20Upgradeable(pool.token).safeTransfer(msg.sender, withdrawAmount);
        emit TokensWithdrawn(msg.sender, _poolId, withdrawAmount);
    }

    function generateLPTokens(
        uint256 _poolId,
        uint256 _ticTokenQty,
        uint256 _quoteTokenQty,
        uint256 _ticTokenQtyMin,
        uint256 _quoteTokenQtyMin,
        uint256 _expirationTimestamp
    ) external virtual onlyGovernance {
        require(address(ticToken) != address(0), "MerklePools: TIC_NOT_SET");
        require(elasticLPToken != address(0), "MerklePools: ELP_NOT_SET");

        MerklePool.Data storage _pool = pools.get(_poolId);
        _pool.update(poolContext); // update pool first!
        uint256 maxMintAmount =
            _pool.totalUnclaimedTIC - _pool.totalUnclaimedTICInLP;
        require(maxMintAmount >= _ticTokenQty, "MerklePools: NSF_UNCLAIMED");

        uint256 ticBalanceToBeMinted = _ticTokenQty - excessTICFromSlippage;

        ticToken.mint(address(this), ticBalanceToBeMinted);
        IERC20Upgradeable(quoteToken).safeTransferFrom(
            msg.sender,
            address(this),
            _quoteTokenQty
        );

        uint256 lpBalanceBefore =
            IERC20Upgradeable(elasticLPToken).balanceOf(address(this));
        uint256 ticBalanceBefore = ticToken.balanceOf(address(this));
        uint256 quoteTokenBalanceBefore =
            IERC20Upgradeable(quoteToken).balanceOf(address(this));

        Exchange(address(elasticLPToken)).addLiquidity(
            _ticTokenQty,
            _quoteTokenQty,
            _ticTokenQtyMin,
            _quoteTokenQtyMin,
            address(this),
            _expirationTimestamp
        );

        uint256 lpBalanceCreated =
            IERC20Upgradeable(elasticLPToken).balanceOf(address(this)) -
                lpBalanceBefore;
        require(lpBalanceCreated != 0, "MerklePools: NO_LP_CREATED");

        uint256 ticBalanceConsumed =
            ticBalanceBefore - ticToken.balanceOf(address(this));
        excessTICFromSlippage = _ticTokenQty - ticBalanceConsumed; //save for next time

        _pool.totalUnclaimedTICInLP += ticBalanceConsumed;
        uint256 quoteTokenConsumed =
            quoteTokenBalanceBefore -
                IERC20Upgradeable(quoteToken).balanceOf(address(this));
        if (quoteTokenConsumed < _quoteTokenQty) {
            IERC20Upgradeable(quoteToken).safeTransfer(
                msg.sender,
                _quoteTokenQty - quoteTokenConsumed
            );
        }

        emit LPTokensGenerated(
            lpBalanceCreated,
            ticBalanceConsumed,
            quoteTokenConsumed
        );
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyGovernance {
        require(merkleRoot != _merkleRoot, "MerklePools: DUPLICATE_ROOT");
        require(address(ticToken) != address(0), "MerklePools: TIC_NOT_SET");
        require(elasticLPToken != address(0), "MerklePools: ELP_NOT_SET");
        isClaimsEnabled = true;
        merkleRoot = _merkleRoot;
        emit MerkleRootUpdated(_merkleRoot);
    }

    function claim(
        uint256 _index,
        uint256 _poolId,
        uint256 _totalLPTokenAmount,
        uint256 _totalTICAmount,
        bytes32[] calldata _merkleProof
    ) external nonReentrant {
        require(isClaimsEnabled, "MerklePools: CLAIMS_DISABLED");

        bytes32 node =
            keccak256(
                abi.encodePacked(
                    _index,
                    msg.sender,
                    _poolId,
                    _totalLPTokenAmount,
                    _totalTICAmount
                )
            );

        require(
            MerkleProofUpgradeable.verify(_merkleProof, merkleRoot, node),
            "MerklePools: INVALID_PROOF"
        );

        MerkleStake.Data storage stake = stakes[msg.sender][_poolId];
        uint256 alreadyClaimedLPAmount = stake.totalRealizedLP;
        uint256 alreadyClaimedTICAmount = stake.totalRealizedTIC;

        require(
            _totalLPTokenAmount > alreadyClaimedLPAmount &&
                _totalTICAmount > alreadyClaimedTICAmount,
            "MerklePools: INVALID_CLAIM_AMOUNT"
        );

        MerklePool.Data storage pool = pools.get(_poolId);
        pool.update(poolContext);
        stake.update(pool, poolContext);

        uint256 lpTokenAmountToBeClaimed;
        uint256 ticTokenAmountToBeClaimed;

        unchecked {
            lpTokenAmountToBeClaimed =
                _totalLPTokenAmount -
                alreadyClaimedLPAmount;
            ticTokenAmountToBeClaimed =
                _totalTICAmount -
                alreadyClaimedTICAmount;
        }

        require(
            ticTokenAmountToBeClaimed <= stake.totalUnrealized,
            "MerklePools: INVALID_UNCLAIMED_AMOUNT"
        );

        stake.totalRealizedLP = _totalLPTokenAmount;
        stake.totalRealizedTIC = _totalTICAmount;

        unchecked {
            stake.totalUnrealized -= ticTokenAmountToBeClaimed;
        }
        pool.totalUnclaimedTIC -= ticTokenAmountToBeClaimed;
        pool.totalUnclaimedTICInLP -= ticTokenAmountToBeClaimed;

        IERC20Upgradeable(elasticLPToken).safeTransfer(
            msg.sender,
            lpTokenAmountToBeClaimed
        );
        emit TokensClaimed(
            msg.sender,
            _index,
            _poolId,
            lpTokenAmountToBeClaimed,
            ticTokenAmountToBeClaimed
        );
    }

    function rewardRate() external view returns (uint256) {
        return poolContext.rewardRate;
    }

    function totalRewardWeight() external view returns (uint256) {
        return poolContext.totalRewardWeight;
    }

    function poolCount() external view returns (uint256) {
        return pools.length();
    }

    function getPoolToken(uint256 _poolId) external view returns (address) {
        MerklePool.Data storage pool = pools.get(_poolId);
        return pool.token;
    }

    function getPool(uint256 _poolId)
        external
        view
        returns (MerklePool.Data memory)
    {
        return pools.get(_poolId);
    }

    function getPoolTotalDeposited(uint256 _poolId)
        external
        view
        returns (uint256)
    {
        MerklePool.Data storage pool = pools.get(_poolId);
        return pool.totalDeposited;
    }

    function getPoolTotalUnclaimed(uint256 _poolId)
        external
        view
        returns (uint256)
    {
        MerklePool.Data storage pool = pools.get(_poolId);
        return pool.getUpdatedTotalUnclaimed(poolContext);
    }

    function getPoolTotalUnclaimedNotInLP(uint256 _poolId)
        external
        view
        returns (uint256)
    {
        MerklePool.Data storage pool = pools.get(_poolId);
        return
            pool.getUpdatedTotalUnclaimed(poolContext) -
            pool.totalUnclaimedTICInLP;
    }

    function getPoolRewardWeight(uint256 _poolId)
        external
        view
        returns (uint256)
    {
        MerklePool.Data storage pool = pools.get(_poolId);
        return pool.rewardWeight;
    }

    function getPoolRewardRate(uint256 _poolId)
        external
        view
        returns (uint256)
    {
        MerklePool.Data storage pool = pools.get(_poolId);
        return pool.getRewardRate(poolContext);
    }

    function getStakeTotalDeposited(address _account, uint256 _poolId)
        external
        view
        returns (uint256)
    {
        MerkleStake.Data storage stake = stakes[_account][_poolId];
        return stake.totalDeposited;
    }

    function getStakeTotalUnclaimed(address _account, uint256 _poolId)
        external
        view
        returns (uint256)
    {
        MerkleStake.Data storage stake = stakes[_account][_poolId];
        return stake.getUpdatedTotalUnclaimed(pools.get(_poolId), poolContext);
    }

    function _updatePools() internal {
        uint256 poolsLength = pools.length();
        for (uint256 poolId = 0; poolId < poolsLength; poolId++) {
            MerklePool.Data storage pool = pools.get(poolId);
            pool.update(poolContext);
        }
    }
}

contract MerklePoolsForeign is MerklePools {
    using MerklePool for MerklePool.List;
    using MerklePool for MerklePool.Data;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function generateLPTokens(
        uint256 _poolId,
        uint256 _ticTokenQty,
        uint256 _quoteTokenQty,
        uint256 _ticTokenQtyMin,
        uint256 _quoteTokenQtyMin,
        uint256 _expirationTimestamp
    ) external override onlyGovernance {
        require(address(ticToken) != address(0), "MerklePools: TIC_NOT_SET");
        require(elasticLPToken != address(0), "MerklePools: ELP_NOT_SET");

        MerklePool.Data storage _pool = pools.get(_poolId);
        _pool.update(poolContext); // update pool first!
        uint256 maxMintAmount =
            _pool.totalUnclaimedTIC - _pool.totalUnclaimedTICInLP;
        require(maxMintAmount >= _ticTokenQty, "MerklePools: NSF_UNCLAIMED");

        ticToken.transferFrom(msg.sender, address(this), _ticTokenQty);
        IERC20Upgradeable(quoteToken).safeTransferFrom(
            msg.sender,
            address(this),
            _quoteTokenQty
        );

        uint256 lpBalanceBefore =
            IERC20Upgradeable(elasticLPToken).balanceOf(address(this));
        uint256 ticBalanceBefore = ticToken.balanceOf(address(this));
        uint256 quoteTokenBalanceBefore =
            IERC20Upgradeable(quoteToken).balanceOf(address(this));

        Exchange(address(elasticLPToken)).addLiquidity(
            _ticTokenQty,
            _quoteTokenQty,
            _ticTokenQtyMin,
            _quoteTokenQtyMin,
            address(this),
            _expirationTimestamp
        );

        uint256 lpBalanceCreated =
            IERC20Upgradeable(elasticLPToken).balanceOf(address(this)) -
                lpBalanceBefore;
        require(lpBalanceCreated != 0, "MerklePools: NO_LP_CREATED");

        uint256 ticBalanceConsumed =
            ticBalanceBefore - ticToken.balanceOf(address(this));
        _pool.totalUnclaimedTICInLP += ticBalanceConsumed;

        if (ticBalanceConsumed < _ticTokenQty) {
            ticToken.transfer(msg.sender, _ticTokenQty - ticBalanceConsumed);
        }

        uint256 quoteTokenConsumed =
            quoteTokenBalanceBefore -
                IERC20Upgradeable(quoteToken).balanceOf(address(this));

        if (quoteTokenConsumed < _quoteTokenQty) {
            IERC20Upgradeable(quoteToken).safeTransfer(
                msg.sender,
                _quoteTokenQty - quoteTokenConsumed
            );
        }

        emit LPTokensGenerated(
            lpBalanceCreated,
            ticBalanceConsumed,
            quoteTokenConsumed
        );
    }
}