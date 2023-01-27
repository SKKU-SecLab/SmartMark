

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




interface IFund {

    function underlying() external view returns (address);


    function fundManager() external view returns (address);


    function relayer() external view returns (address);


    function deposit(uint256 amountWei) external;


    function depositFor(uint256 amountWei, address holder) external;


    function withdraw(uint256 numberOfShares) external;


    function getPricePerShare() external view returns (uint256);


    function totalValueLocked() external view returns (uint256);


    function underlyingBalanceWithInvestmentForHolder(address holder)
        external
        view
        returns (uint256);

}


interface IFundProxy {

    function implementation() external view returns (address);

}


interface IStrategy {

    function name() external pure returns (string memory);


    function version() external pure returns (string memory);


    function underlying() external view returns (address);


    function fund() external view returns (address);


    function creator() external view returns (address);


    function withdrawAllToFund() external;


    function withdrawToFund(uint256 amount) external;


    function investedUnderlyingBalance() external view returns (uint256);


    function doHardWork() external;

}


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
}


interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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
}


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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}


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


library SafeMath {

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
}


contract SetGetAssembly {

    constructor() public {}

    function setAddress(bytes32 slot, address _address) internal {

        assembly {
            sstore(slot, _address)
        }
    }

    function setUint256(bytes32 slot, uint256 _value) internal {

        assembly {
            sstore(slot, _value)
        }
    }

    function setUint8(bytes32 slot, uint8 _value) internal {

        assembly {
            sstore(slot, _value)
        }
    }

    function setBool(bytes32 slot, bool _value) internal {

        setUint256(slot, _value ? 1 : 0);
    }

    function getBool(bytes32 slot) internal view returns (bool) {

        return (getUint256(slot) == 1);
    }

    function getAddress(bytes32 slot) internal view returns (address str) {

        assembly {
            str := sload(slot)
        }
    }

    function getUint256(bytes32 slot) internal view returns (uint256 str) {

        assembly {
            str := sload(slot)
        }
    }

    function getUint8(bytes32 slot) internal view returns (uint8 str) {

        assembly {
            str := sload(slot)
        }
    }
}


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
}


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


contract FundStorage is Initializable, SetGetAssembly {

    bytes32 internal constant _UNDERLYING_SLOT =
        0xe0dc1d429ff8628e5936b3d6a6546947e1cc9ea7415a59d46ce95b3cfa4442b9;
    bytes32 internal constant _UNDERLYING_UNIT_SLOT =
        0x4840b03aa097a422092d99dc6875c2b69e8f48c9af2563a0447f3b4e4928d962;
    bytes32 internal constant _DECIMALS_SLOT =
        0x15b9fa1072bc4b2cdb762a49a2c7917b8b3af02283e37ffd41d0fccd4eef0d48;
    bytes32 internal constant _FUND_MANAGER_SLOT =
        0x670552e214026020a9e6caa820519c7f879b21bd75b5571387d6a9cf8f94bd18;
    bytes32 internal constant _RELAYER_SLOT =
        0x84e8c6b8f2281d51d9f683d351409724c3caa7848051aeb9d92c106ab36cc24c;
    bytes32 internal constant _PLATFORM_REWARDS_SLOT =
        0x92260bfe68dd0f8a9f5439b75466781ba1ce44523ed1a3026a73eada49072e65;
    bytes32 internal constant _CHANGE_DELAY_SLOT =
        0x0391715d0dd26b729c4ba34639ad5bdb0a7feb89f59a1e38f38485ea7f5a1583;
    bytes32 internal constant _DEPOSIT_LIMIT_SLOT =
        0xca2f8a3e9ea81335bcce793cde55fc0c38129b594f53052d2bb18099ffa72613;
    bytes32 internal constant _DEPOSIT_LIMIT_TX_MAX_SLOT =
        0x769f312c3790719cf1ea5f75303393f080fd62be88d75fa86726a6be00bb5a24;
    bytes32 internal constant _DEPOSIT_LIMIT_TX_MIN_SLOT =
        0x9027949576d185c74d79ad3b8a8dbff32126f3a3ee140b346f146beb18234c85;
    bytes32 internal constant _PERFORMANCE_FEE_FUND_SLOT =
        0x5b8979500398f8fbeb42c36d18f31a76fd0ab30f4338d864e7d8734b340e9bb9;
    bytes32 internal constant _PLATFORM_FEE_SLOT =
        0x2084059f3bff3cc3fd204df32325dcb05f47c2f590aba5d103ec584523738e7a;
    bytes32 internal constant _MAX_INVESTMENT_IN_STRATEGIES_SLOT =
        0xe3b5969c9426551aa8f16dbc7b25042b9b9c9869b759c77a85f0b097ac363475;
    bytes32 internal constant _TOTAL_WEIGHT_IN_STRATEGIES_SLOT =
        0x63177e03c47ab825f04f5f8f2334e312239890e7588db78cabe10d7aec327fd2;
    bytes32 internal constant _TOTAL_ACCOUNTED_SLOT =
        0xa19f3b8a62465676ae47ab811ee15e3d2b68d88869cb38686d086a11d382f6bb;
    bytes32 internal constant _TOTAL_INVESTED_SLOT =
        0x49c84685200b42972f845832b2c3da3d71def653c151340801aeae053ce104e9;
    bytes32 internal constant _DEPOSITS_PAUSED_SLOT =
        0x3cefcfe9774096ac956c0d63992ea27a01fb3884a22b8765ad63c8366f90a9c8;
    bytes32 internal constant _SHOULD_REBALANCE_SLOT =
        0x7f8e3dfb98485aa419c1d05b6ea089a8cddbafcfcf4491db33f5d0b5fe4f32c7;
    bytes32 internal constant _LAST_HARDWORK_TIMESTAMP_SLOT =
        0x0260c2bf5555cd32cedf39c0fcb0eab8029c67b3d5137faeb3e24a500db80bc9;
    bytes32 internal constant _NEXT_IMPLEMENTATION_SLOT =
        0xa7ae0fa763ec3009113ccc5eb9089e1f0028607f5b8198c52cd42366c1ddb17b;
    bytes32 internal constant _NEXT_IMPLEMENTATION_TIMESTAMP_SLOT =
        0x5e1f7083e1d90c44893f97806d0ec517436a58b85860b28247fd6fd56f5dc897;

    constructor() public {
        assert(
            _UNDERLYING_SLOT ==
                bytes32(
                    uint256(
                        keccak256("eip1967.mesh.finance.fundStorage.underlying")
                    ) - 1
                )
        );
        assert(
            _UNDERLYING_UNIT_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.underlyingUnit"
                        )
                    ) - 1
                )
        );
        assert(
            _DECIMALS_SLOT ==
                bytes32(
                    uint256(
                        keccak256("eip1967.mesh.finance.fundStorage.decimals")
                    ) - 1
                )
        );
        assert(
            _FUND_MANAGER_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.fundManager"
                        )
                    ) - 1
                )
        );
        assert(
            _RELAYER_SLOT ==
                bytes32(
                    uint256(
                        keccak256("eip1967.mesh.finance.fundStorage.relayer")
                    ) - 1
                )
        );
        assert(
            _PLATFORM_REWARDS_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.platformRewards"
                        )
                    ) - 1
                )
        );
        assert(
            _CHANGE_DELAY_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.changeDelay"
                        )
                    ) - 1
                )
        );
        assert(
            _DEPOSIT_LIMIT_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.depositLimit"
                        )
                    ) - 1
                )
        );
        assert(
            _DEPOSIT_LIMIT_TX_MAX_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.depositLimitTxMax"
                        )
                    ) - 1
                )
        );
        assert(
            _DEPOSIT_LIMIT_TX_MIN_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.depositLimitTxMin"
                        )
                    ) - 1
                )
        );
        assert(
            _PERFORMANCE_FEE_FUND_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.performanceFeeFund"
                        )
                    ) - 1
                )
        );
        assert(
            _PLATFORM_FEE_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.platformFee"
                        )
                    ) - 1
                )
        );
        assert(
            _MAX_INVESTMENT_IN_STRATEGIES_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.maxInvestmentInStrategies"
                        )
                    ) - 1
                )
        );
        assert(
            _TOTAL_WEIGHT_IN_STRATEGIES_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.totalWeightInStrategies"
                        )
                    ) - 1
                )
        );
        assert(
            _TOTAL_ACCOUNTED_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.totalAccounted"
                        )
                    ) - 1
                )
        );
        assert(
            _TOTAL_INVESTED_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.totalInvested"
                        )
                    ) - 1
                )
        );
        assert(
            _DEPOSITS_PAUSED_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.depositsPaused"
                        )
                    ) - 1
                )
        );
        assert(
            _SHOULD_REBALANCE_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.shouldRebalance"
                        )
                    ) - 1
                )
        );
        assert(
            _LAST_HARDWORK_TIMESTAMP_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.lastHardworkTimestamp"
                        )
                    ) - 1
                )
        );
        assert(
            _NEXT_IMPLEMENTATION_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.nextImplementation"
                        )
                    ) - 1
                )
        );
        assert(
            _NEXT_IMPLEMENTATION_TIMESTAMP_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.fundStorage.nextImplementationTimestamp"
                        )
                    ) - 1
                )
        );
    }

    function initializeFundStorage(
        address _underlying,
        uint256 _underlyingUnit,
        uint8 _decimals,
        address _fundManager,
        address _relayer,
        address _platformRewards,
        uint256 _changeDelay
    ) public initializer {

        _setUnderlying(_underlying);
        _setUnderlyingUnit(_underlyingUnit);
        _setDecimals(_decimals);
        _setFundManager(_fundManager);
        _setRelayer(_relayer);
        _setPlatformRewards(_platformRewards);
        _setChangeDelay(_changeDelay);
        _setDepositLimit(0);
        _setDepositLimitTxMax(0);
        _setDepositLimitTxMin(0);
        _setPerformanceFeeFund(0);
        _setPlatformFee(0);
        _setMaxInvestmentInStrategies(9500); // 9500 BPS (95%) can be accessed by the strategies. This is to keep something in fund for withdrawal.
        _setTotalWeightInStrategies(0);
        _setTotalAccounted(0);
        _setTotalInvested(0);
        _setDepositsPaused(false);
        _setShouldRebalance(false);
        _setLastHardworkTimestamp(0);
        _setNextImplementation(address(0));
        _setNextImplementationTimestamp(0);
    }

    function _setUnderlying(address _address) internal {

        setAddress(_UNDERLYING_SLOT, _address);
    }

    function _underlying() internal view returns (address) {

        return getAddress(_UNDERLYING_SLOT);
    }

    function _setUnderlyingUnit(uint256 _value) internal {

        setUint256(_UNDERLYING_UNIT_SLOT, _value);
    }

    function _underlyingUnit() internal view returns (uint256) {

        return getUint256(_UNDERLYING_UNIT_SLOT);
    }

    function _setDecimals(uint8 _value) internal {

        setUint8(_DECIMALS_SLOT, _value);
    }

    function _decimals() internal view returns (uint8) {

        return getUint8(_DECIMALS_SLOT);
    }

    function _setFundManager(address _fundManager) internal {

        setAddress(_FUND_MANAGER_SLOT, _fundManager);
    }

    function _fundManager() internal view returns (address) {

        return getAddress(_FUND_MANAGER_SLOT);
    }

    function _setRelayer(address _relayer) internal {

        setAddress(_RELAYER_SLOT, _relayer);
    }

    function _relayer() internal view returns (address) {

        return getAddress(_RELAYER_SLOT);
    }

    function _setPlatformRewards(address _rewards) internal {

        setAddress(_PLATFORM_REWARDS_SLOT, _rewards);
    }

    function _platformRewards() internal view returns (address) {

        return getAddress(_PLATFORM_REWARDS_SLOT);
    }

    function _setChangeDelay(uint256 _value) internal {

        setUint256(_CHANGE_DELAY_SLOT, _value);
    }

    function _changeDelay() internal view returns (uint256) {

        return getUint256(_CHANGE_DELAY_SLOT);
    }

    function _setDepositLimit(uint256 _value) internal {

        setUint256(_DEPOSIT_LIMIT_SLOT, _value);
    }

    function _depositLimit() internal view returns (uint256) {

        return getUint256(_DEPOSIT_LIMIT_SLOT);
    }

    function _setDepositLimitTxMax(uint256 _value) internal {

        setUint256(_DEPOSIT_LIMIT_TX_MAX_SLOT, _value);
    }

    function _depositLimitTxMax() internal view returns (uint256) {

        return getUint256(_DEPOSIT_LIMIT_TX_MAX_SLOT);
    }

    function _setDepositLimitTxMin(uint256 _value) internal {

        setUint256(_DEPOSIT_LIMIT_TX_MIN_SLOT, _value);
    }

    function _depositLimitTxMin() internal view returns (uint256) {

        return getUint256(_DEPOSIT_LIMIT_TX_MIN_SLOT);
    }

    function _setPerformanceFeeFund(uint256 _value) internal {

        setUint256(_PERFORMANCE_FEE_FUND_SLOT, _value);
    }

    function _performanceFeeFund() internal view returns (uint256) {

        return getUint256(_PERFORMANCE_FEE_FUND_SLOT);
    }

    function _setPlatformFee(uint256 _value) internal {

        setUint256(_PLATFORM_FEE_SLOT, _value);
    }

    function _platformFee() internal view returns (uint256) {

        return getUint256(_PLATFORM_FEE_SLOT);
    }

    function _setMaxInvestmentInStrategies(uint256 _value) internal {

        setUint256(_MAX_INVESTMENT_IN_STRATEGIES_SLOT, _value);
    }

    function _maxInvestmentInStrategies() internal view returns (uint256) {

        return getUint256(_MAX_INVESTMENT_IN_STRATEGIES_SLOT);
    }

    function _setTotalWeightInStrategies(uint256 _value) internal {

        setUint256(_TOTAL_WEIGHT_IN_STRATEGIES_SLOT, _value);
    }

    function _totalWeightInStrategies() internal view returns (uint256) {

        return getUint256(_TOTAL_WEIGHT_IN_STRATEGIES_SLOT);
    }

    function _setTotalAccounted(uint256 _value) internal {

        setUint256(_TOTAL_ACCOUNTED_SLOT, _value);
    }

    function _totalAccounted() internal view returns (uint256) {

        return getUint256(_TOTAL_ACCOUNTED_SLOT);
    }

    function _setTotalInvested(uint256 _value) internal {

        setUint256(_TOTAL_INVESTED_SLOT, _value);
    }

    function _totalInvested() internal view returns (uint256) {

        return getUint256(_TOTAL_INVESTED_SLOT);
    }

    function _setDepositsPaused(bool _value) internal {

        setBool(_DEPOSITS_PAUSED_SLOT, _value);
    }

    function _depositsPaused() internal view returns (bool) {

        return getBool(_DEPOSITS_PAUSED_SLOT);
    }

    function _setShouldRebalance(bool _value) internal {

        setBool(_SHOULD_REBALANCE_SLOT, _value);
    }

    function _shouldRebalance() internal view returns (bool) {

        return getBool(_SHOULD_REBALANCE_SLOT);
    }

    function _setLastHardworkTimestamp(uint256 _value) internal {

        setUint256(_LAST_HARDWORK_TIMESTAMP_SLOT, _value);
    }

    function _lastHardworkTimestamp() internal view returns (uint256) {

        return getUint256(_LAST_HARDWORK_TIMESTAMP_SLOT);
    }

    function _setNextImplementation(address _newImplementation) internal {

        setAddress(_NEXT_IMPLEMENTATION_SLOT, _newImplementation);
    }

    function _nextImplementation() internal view returns (address) {

        return getAddress(_NEXT_IMPLEMENTATION_SLOT);
    }

    function _setNextImplementationTimestamp(uint256 _value) internal {

        setUint256(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT, _value);
    }

    function _nextImplementationTimestamp() internal view returns (uint256) {

        return getUint256(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT);
    }

    uint256[50] private bigEmptySlot;
}


contract Governable is Initializable, SetGetAssembly {

    event GovernanceUpdated(address newGovernance, address oldGovernance);

    bytes32 internal constant _GOVERNANCE_SLOT =
        0x597f9c7c685b907e823520bd45aeb3d58b505f86b2e41cd5b4cd5b6c72782950;
    bytes32 internal constant _PENDING_GOVERNANCE_SLOT =
        0xcd77091f18f9504fccf6140ab99e20533c811d470bb9a5a983d0edc0720fbf8c;

    modifier onlyGovernance() {

        require(_governance() == msg.sender, "Not governance");
        _;
    }

    constructor() public {
        assert(
            _GOVERNANCE_SLOT ==
                bytes32(
                    uint256(
                        keccak256("eip1967.mesh.finance.governable.governance")
                    ) - 1
                )
        );
        assert(
            _PENDING_GOVERNANCE_SLOT ==
                bytes32(
                    uint256(
                        keccak256(
                            "eip1967.mesh.finance.governable.pendingGovernance"
                        )
                    ) - 1
                )
        );
    }

    function initializeGovernance(address _governance) public initializer {

        _setGovernance(_governance);
    }

    function _setGovernance(address _governance) private {

        setAddress(_GOVERNANCE_SLOT, _governance);
    }

    function _setPendingGovernance(address _pendingGovernance) private {

        setAddress(_PENDING_GOVERNANCE_SLOT, _pendingGovernance);
    }

    function updateGovernance(address _newGovernance) public onlyGovernance {

        require(
            _newGovernance != address(0),
            "new governance shouldn't be empty"
        );
        _setPendingGovernance(_newGovernance);
    }

    function acceptGovernance() public {

        require(_pendingGovernance() == msg.sender, "Not pending governance");
        address oldGovernance = _governance();
        _setGovernance(msg.sender);
        emit GovernanceUpdated(msg.sender, oldGovernance);
    }

    function _governance() internal view returns (address str) {

        return getAddress(_GOVERNANCE_SLOT);
    }

    function _pendingGovernance() internal view returns (address str) {

        return getAddress(_PENDING_GOVERNANCE_SLOT);
    }

    function governance() public view returns (address) {

        return _governance();
    }
}


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
}


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
}


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}


contract Fund is
    ERC20Upgradeable,
    ReentrancyGuardUpgradeable,
    IFund,
    Governable,
    FundStorage
{

    using SafeERC20 for IERC20;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;
    using SafeMathUpgradeable for uint8;

    event Withdraw(address indexed beneficiary, uint256 amount);
    event Deposit(address indexed beneficiary, uint256 amount);
    event InvestInStrategy(address indexed strategy, uint256 amount);
    event StrategyRewards(
        address indexed strategy,
        uint256 profit,
        uint256 strategyCreatorFee
    );
    event FundManagerRewards(uint256 profitTotal, uint256 fundManagerFee);
    event PlatformRewards(
        uint256 lastBalance,
        uint256 timeElapsed,
        uint256 platformFee
    );
    event HardWorkDone(uint256 totalValueLocked, uint256 pricePerShare);

    event StrategyAdded(
        address indexed strategy,
        uint256 weightage,
        uint256 performanceFeeStrategy
    );
    event StrategyWeightageUpdated(
        address indexed strategy,
        uint256 newWeightage
    );
    event StrategyPerformanceFeeUpdated(
        address indexed strategy,
        uint256 newPerformanceFeeStrategy
    );
    event StrategyRemoved(address indexed strategy);

    address internal constant ZERO_ADDRESS = address(0);

    uint256 internal constant MAX_BPS = 10000; // 100% in basis points
    uint256 internal constant SECS_PER_YEAR = 31556952; // 365.25 days from yearn

    uint256 internal constant MAX_PLATFORM_FEE = 500; // 5% (annual on AUM), goes to governance/treasury
    uint256 internal constant MAX_PERFORMANCE_FEE_FUND = 1000; // 10% on profits, goes to fund manager
    uint256 internal constant MAX_PERFORMANCE_FEE_STRATEGY = 1000; // 10% on profits, goes to strategy creator

    uint256 internal constant MAX_ACTIVE_STRATEGIES = 10; // To save on potential out of gas issues

    struct StrategyParams {
        uint256 weightage; // weightage of total assets in fund this strategy can access (in BPS) (5000 for 50%)
        uint256 performanceFeeStrategy; // in BPS, fee on yield of the strategy, goes to strategy creator
        uint256 activation; // timestamp when strategy is added
        uint256 lastBalance; // balance at last hard work
        uint256 indexInList;
    }

    mapping(address => StrategyParams) public strategies;
    address[] public strategyList;

    constructor() public {}

    function initializeFund(
        address _governance,
        address _underlying,
        string memory _name,
        string memory _symbol
    ) external initializer {

        require(_governance != ZERO_ADDRESS, "governance must be defined");
        require(_underlying != ZERO_ADDRESS, "underlying must be defined");
        ERC20Upgradeable.__ERC20_init(_name, _symbol);

        __ReentrancyGuard_init();

        Governable.initializeGovernance(_governance);

        uint8 _decimals = ERC20Upgradeable(_underlying).decimals();

        uint256 _underlyingUnit = 10**uint256(_decimals);

        uint256 _changeDelay = 12 hours;

        FundStorage.initializeFundStorage(
            _underlying,
            _underlyingUnit,
            _decimals,
            _governance, // fund manager is initialized as governance
            _governance, // relayer is initialized as governance
            _governance, // rewards contract is initialized as governance
            _changeDelay
        );
    }

    modifier onlyFundManager {

        require(_fundManager() == msg.sender, "Not fund manager");
        _;
    }

    modifier onlyFundManagerOrGovernance() {

        require(
            (_governance() == msg.sender) || (_fundManager() == msg.sender),
            "Not governance or fund manager"
        );
        _;
    }

    modifier onlyFundManagerOrRelayer() {

        require(
            (_fundManager() == msg.sender) || (_relayer() == msg.sender),
            "Not fund manager or relayer"
        );
        _;
    }

    modifier whenDepositsNotPaused() {

        require(!_depositsPaused(), "Deposits are paused");
        _;
    }

    function fundManager() external view override returns (address) {

        return _fundManager();
    }

    function relayer() external view override returns (address) {

        return _relayer();
    }

    function underlying() external view override returns (address) {

        return _underlying();
    }

    function underlyingUnit() external view returns (uint256) {

        return _underlyingUnit();
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals();
    }

    function _getStrategyCount() internal view returns (uint256) {

        return strategyList.length;
    }

    modifier whenStrategyDefined() {

        require(_getStrategyCount() > 0, "Strategies must be defined");
        _;
    }

    function getStrategyList() public view returns (address[] memory) {

        return strategyList;
    }

    function getStrategy(address strategy)
        public
        view
        returns (StrategyParams memory)
    {

        return strategies[strategy];
    }

    function underlyingBalanceInFund() internal view returns (uint256) {

        return IERC20(_underlying()).balanceOf(address(this));
    }

    function underlyingBalanceWithInvestment() internal view returns (uint256) {

        uint256 underlyingBalance = underlyingBalanceInFund();
        for (uint256 i; i < _getStrategyCount(); i++) {
            underlyingBalance = underlyingBalance.add(
                IStrategy(strategyList[i]).investedUnderlyingBalance()
            );
        }
        return underlyingBalance;
    }

    function _getPricePerShare() internal view returns (uint256) {

        return
            totalSupply() == 0
                ? _underlyingUnit()
                : _underlyingUnit().mul(underlyingBalanceWithInvestment()).div(
                    totalSupply()
                );
    }

    function getPricePerShare() external view override returns (uint256) {

        return _getPricePerShare();
    }

    function totalValueLocked() external view override returns (uint256) {

        return underlyingBalanceWithInvestment();
    }

    function underlyingFromShares(uint256 _numShares)
        external
        view
        returns (uint256)
    {

        return _underlyingFromShares(_numShares);
    }

    function _underlyingFromShares(uint256 numShares)
        internal
        view
        returns (uint256)
    {

        return
            underlyingBalanceWithInvestment().mul(numShares).div(totalSupply());
    }

    function underlyingBalanceWithInvestmentForHolder(address holder)
        external
        view
        override
        returns (uint256)
    {

        if (totalSupply() == 0) {
            return 0;
        }
        return _underlyingFromShares(balanceOf(holder));
    }

    function isActiveStrategy(address strategy) internal view returns (bool) {

        return strategies[strategy].weightage > 0;
    }

    function addStrategy(
        address newStrategy,
        uint256 weightage,
        uint256 performanceFeeStrategy
    ) external onlyFundManager {

        require(newStrategy != ZERO_ADDRESS, "new newStrategy cannot be empty");
        require(
            IStrategy(newStrategy).fund() == address(this),
            "The strategy does not belong to this fund"
        );
        require(
            isActiveStrategy(newStrategy) == false,
            "This strategy is already active in this fund"
        );
        require(
            _getStrategyCount() + 1 <= MAX_ACTIVE_STRATEGIES,
            "Can not add more strategies"
        );
        require(weightage > 0, "The weightage should be greater than 0");
        uint256 totalWeightInStrategies =
            _totalWeightInStrategies().add(weightage);
        require(
            totalWeightInStrategies <= _maxInvestmentInStrategies(),
            "Total investment can't be above max allowed"
        );
        require(
            performanceFeeStrategy <= MAX_PERFORMANCE_FEE_STRATEGY,
            "Performance fee too high"
        );

        strategies[newStrategy].weightage = weightage;
        _setTotalWeightInStrategies(totalWeightInStrategies);
        strategies[newStrategy].activation = block.timestamp;
        strategies[newStrategy].indexInList = _getStrategyCount();
        strategies[newStrategy].performanceFeeStrategy = performanceFeeStrategy;
        strategyList.push(newStrategy);
        _setShouldRebalance(true);

        emit StrategyAdded(newStrategy, weightage, performanceFeeStrategy);
    }

    function removeStrategy(address activeStrategy)
        external
        onlyFundManagerOrGovernance
    {

        require(
            activeStrategy != ZERO_ADDRESS,
            "current strategy cannot be empty"
        );
        require(
            isActiveStrategy(activeStrategy),
            "This strategy is not active in this fund"
        );

        _setTotalWeightInStrategies(
            _totalWeightInStrategies().sub(strategies[activeStrategy].weightage)
        );
        uint256 totalStrategies = _getStrategyCount();
        if (totalStrategies > 1) {
            uint256 i = strategies[activeStrategy].indexInList;
            if (i != (totalStrategies - 1)) {
                strategyList[i] = strategyList[totalStrategies - 1];
                strategies[strategyList[i]].indexInList = i;
            }
        }
        strategyList.pop();
        delete strategies[activeStrategy];
        IStrategy(activeStrategy).withdrawAllToFund();
        _setShouldRebalance(true);

        emit StrategyRemoved(activeStrategy);
    }

    function updateStrategyWeightage(
        address activeStrategy,
        uint256 newWeightage
    ) external onlyFundManager {

        require(
            activeStrategy != ZERO_ADDRESS,
            "current strategy cannot be empty"
        );
        require(
            isActiveStrategy(activeStrategy),
            "This strategy is not active in this fund"
        );
        require(newWeightage > 0, "The weightage should be greater than 0");
        uint256 totalWeightInStrategies =
            _totalWeightInStrategies()
                .sub(strategies[activeStrategy].weightage)
                .add(newWeightage);
        require(
            totalWeightInStrategies <= _maxInvestmentInStrategies(),
            "Total investment can't be above max allowed"
        );

        _setTotalWeightInStrategies(totalWeightInStrategies);
        strategies[activeStrategy].weightage = newWeightage;
        _setShouldRebalance(true);

        emit StrategyWeightageUpdated(activeStrategy, newWeightage);
    }

    function updateStrategyPerformanceFee(
        address activeStrategy,
        uint256 newPerformanceFeeStrategy
    ) external onlyFundManager {

        require(
            activeStrategy != ZERO_ADDRESS,
            "current strategy cannot be empty"
        );
        require(
            isActiveStrategy(activeStrategy),
            "This strategy is not active in this fund"
        );
        require(
            newPerformanceFeeStrategy <= MAX_PERFORMANCE_FEE_STRATEGY,
            "Performance fee too high"
        );

        strategies[activeStrategy]
            .performanceFeeStrategy = newPerformanceFeeStrategy;

        emit StrategyPerformanceFeeUpdated(
            activeStrategy,
            newPerformanceFeeStrategy
        );
    }

    function processFees() internal {

        uint256 totalStrategies = _getStrategyCount();
        uint256[] memory strategyCreatorFees = new uint256[](totalStrategies);
        uint256[] memory strategyProfits = new uint256[](totalStrategies);
        uint256 profitToFund = 0; // Profit to fund is the profit from each strategy minus the fee paid out to strategy creators.
        uint256 totalFee = 0; // This will represent the total fee in underlying and will be used to mint fund shares.

        for (uint256 i; i < totalStrategies; i++) {
            address strategy = strategyList[i];

            uint256 profit = 0; // Profit for this strategy
            uint256 strategyCreatorFee = 0;

            if (
                IStrategy(strategy).investedUnderlyingBalance() >
                strategies[strategy].lastBalance
            ) {
                profit =
                    IStrategy(strategy).investedUnderlyingBalance() -
                    strategies[strategy].lastBalance; // Profit for this strategy
                strategyCreatorFee = profit
                    .mul(strategies[strategy].performanceFeeStrategy)
                    .div(MAX_BPS); // Fee to be paid to the creator based on the profit it made in the last cycle
                strategyProfits[i] = profit;
                strategyCreatorFees[i] = strategyCreatorFee;
                totalFee = totalFee.add(strategyCreatorFee);
                profitToFund = profitToFund.add(profit).sub(strategyCreatorFee);
            }
            strategies[strategy].lastBalance = IStrategy(strategy)
                .investedUnderlyingBalance(); // Update the last balance
        }

        uint256 fundManagerFee =
            profitToFund.mul(_performanceFeeFund()).div(MAX_BPS); // Fee to be paid to the fund manager based on the profit fund made in the last cycle
        totalFee = totalFee.add(fundManagerFee);

        uint256 timeSinceLastHardwork =
            block.timestamp.sub(_lastHardworkTimestamp()); // The time between 2 hardwork cycles
        uint256 totalInvested = _totalInvested(); // Was updated during last cycle of hard work

        uint256 platformFee =
            totalInvested.mul(timeSinceLastHardwork).mul(_platformFee()).div(
                MAX_BPS * SECS_PER_YEAR
            ); // Platform fee is based on the AUM
        totalFee = totalFee.add(platformFee);

        uint256 totalFeeInShares =
            (totalFee == 0 || totalSupply() == 0)
                ? totalFee
                : totalFee.mul(totalSupply()).div(
                    underlyingBalanceWithInvestment()
                ); // If total fee is zero, totalFeeInShares is also 0. Otherwise, go to default share calculation. Similar to deposit.
        if (totalFeeInShares > 0) {
            _mint(address(this), totalFeeInShares); // Mint all the fee shares once to save on gas and have a consistent price per share for all.
        }


        for (uint256 i; i < totalStrategies; i++) {
            if (strategyCreatorFees[i] > 0) {
                uint256 strategyCreatorFeeInShares =
                    totalFeeInShares.mul(strategyCreatorFees[i]).div(totalFee);
                if (strategyCreatorFeeInShares > 0) {
                    address strategy = strategyList[i];
                    IERC20(address(this)).safeTransfer(
                        IStrategy(strategy).creator(),
                        strategyCreatorFeeInShares
                    ); // Transfer the shares to strategy creator
                    emit StrategyRewards(
                        strategy,
                        strategyProfits[i],
                        strategyCreatorFeeInShares
                    );
                }
            }
        }

        if (fundManagerFee > 0) {
            uint256 fundManagerFeeInShares =
                totalFeeInShares.mul(fundManagerFee).div(totalFee);
            if (fundManagerFeeInShares > 0) {
                address fundManagerRewards =
                    (_fundManager() == _governance())
                        ? _platformRewards()
                        : _fundManager();
                IERC20(address(this)).safeTransfer(
                    fundManagerRewards,
                    fundManagerFeeInShares
                ); // Transfer the shares to fund manager
                emit FundManagerRewards(profitToFund, fundManagerFeeInShares);
            }
        }

        if (platformFee > 0) {
            uint256 platformFeeInShares =
                totalFeeInShares.mul(platformFee).div(totalFee);
            emit PlatformRewards(
                totalInvested,
                timeSinceLastHardwork,
                platformFeeInShares
            );
        }

        uint256 selfBalance = IERC20(address(this)).balanceOf(address(this));
        if (selfBalance > 0) {
            IERC20(address(this)).safeTransfer(_platformRewards(), selfBalance);
        }
    }

    function doHardWork()
        external
        nonReentrant
        whenStrategyDefined
        onlyFundManagerOrRelayer
    {

        if (_lastHardworkTimestamp() > 0) {
            processFees();
        }

        if (_shouldRebalance()) {
            _setShouldRebalance(false);
            doHardWorkWithRebalance();
        } else {
            doHardWorkWithoutRebalance();
        }
        _setLastHardworkTimestamp(block.timestamp);
        emit HardWorkDone(
            underlyingBalanceWithInvestment(),
            _getPricePerShare()
        );
    }

    function doHardWorkWithoutRebalance() internal {

        uint256 totalAccounted = _totalAccounted();
        uint256 lastReserve =
            totalAccounted > 0 ? totalAccounted.sub(_totalInvested()) : 0;
        uint256 availableAmountToInvest =
            underlyingBalanceInFund() > lastReserve
                ? underlyingBalanceInFund().sub(lastReserve)
                : 0;


        _setTotalAccounted(totalAccounted.add(availableAmountToInvest));
        uint256 totalInvested = 0;

        for (uint256 i; i < _getStrategyCount(); i++) {
            address strategy = strategyList[i];
            uint256 availableAmountForStrategy =
                availableAmountToInvest.mul(strategies[strategy].weightage).div(
                    MAX_BPS
                );
            if (availableAmountForStrategy > 0) {
                IERC20(_underlying()).safeTransfer(
                    strategy,
                    availableAmountForStrategy
                );
                totalInvested = totalInvested.add(availableAmountForStrategy);
                emit InvestInStrategy(strategy, availableAmountForStrategy);
            }

            IStrategy(strategy).doHardWork();

            strategies[strategy].lastBalance = IStrategy(strategy)
                .investedUnderlyingBalance();
        }
        _setTotalInvested(totalInvested);
    }

    function doHardWorkWithRebalance() internal {

        uint256 totalUnderlyingWithInvestment =
            underlyingBalanceWithInvestment();
        _setTotalAccounted(totalUnderlyingWithInvestment);
        uint256 totalInvested = 0;
        uint256 totalStrategies = _getStrategyCount();
        uint256[] memory toDeposit = new uint256[](totalStrategies);

        for (uint256 i; i < totalStrategies; i++) {
            address strategy = strategyList[i];
            uint256 shouldBeInStrategy =
                totalUnderlyingWithInvestment
                    .mul(strategies[strategy].weightage)
                    .div(MAX_BPS);
            totalInvested = totalInvested.add(shouldBeInStrategy);
            uint256 currentlyInStrategy =
                IStrategy(strategy).investedUnderlyingBalance();
            if (currentlyInStrategy > shouldBeInStrategy) {
                IStrategy(strategy).withdrawToFund(
                    currentlyInStrategy.sub(shouldBeInStrategy)
                );
            } else if (shouldBeInStrategy > currentlyInStrategy) {
                toDeposit[i] = shouldBeInStrategy.sub(currentlyInStrategy);
            }
        }
        _setTotalInvested(totalInvested);

        for (uint256 i; i < totalStrategies; i++) {
            address strategy = strategyList[i];
            if (toDeposit[i] > 0) {
                IERC20(_underlying()).safeTransfer(strategy, toDeposit[i]);
                emit InvestInStrategy(strategy, toDeposit[i]);
            }
            IStrategy(strategy).doHardWork();

            strategies[strategy].lastBalance = IStrategy(strategy)
                .investedUnderlyingBalance();
        }
    }

    function pauseDeposits(bool trigger) external onlyFundManagerOrGovernance {

        _setDepositsPaused(trigger);
    }

    function deposit(uint256 amount)
        external
        override
        nonReentrant
        whenDepositsNotPaused
    {

        _deposit(amount, msg.sender, msg.sender);
    }

    function depositFor(uint256 amount, address holder)
        external
        override
        nonReentrant
        whenDepositsNotPaused
    {

        require(holder != ZERO_ADDRESS, "holder must be defined");
        _deposit(amount, msg.sender, holder);
    }

    function _deposit(
        uint256 amount,
        address sender,
        address beneficiary
    ) internal {

        require(amount > 0, "Cannot deposit 0");

        if (_depositLimit() > 0) {
            require(
                underlyingBalanceWithInvestment().add(amount) <=
                    _depositLimit(),
                "Total deposit limit hit"
            );
        }

        if (_depositLimitTxMax() > 0) {
            require(
                amount <= _depositLimitTxMax(),
                "Maximum transaction deposit limit hit"
            );
        }

        if (_depositLimitTxMin() > 0) {
            require(
                amount >= _depositLimitTxMin(),
                "Minimum transaction deposit limit hit"
            );
        }

        uint256 toMint =
            totalSupply() == 0
                ? amount
                : amount.mul(totalSupply()).div(
                    underlyingBalanceWithInvestment()
                );
        _mint(beneficiary, toMint);

        IERC20(_underlying()).safeTransferFrom(sender, address(this), amount);
        emit Deposit(beneficiary, amount);
    }

    function withdraw(uint256 numberOfShares) external override nonReentrant {

        require(totalSupply() > 0, "Fund has no shares");
        require(numberOfShares > 0, "numberOfShares must be greater than 0");

        uint256 underlyingAmountToWithdraw =
            _underlyingFromShares(numberOfShares);
        require(underlyingAmountToWithdraw > 0, "Can't withdraw 0");

        _burn(msg.sender, numberOfShares);

        if (underlyingAmountToWithdraw == underlyingBalanceInFund()) {
            _setShouldRebalance(true);
        } else if (underlyingAmountToWithdraw > underlyingBalanceInFund()) {
            uint256 missing =
                underlyingAmountToWithdraw.sub(underlyingBalanceInFund());
            uint256 missingCarryOver;
            for (uint256 i; i < _getStrategyCount(); i++) {
                if (isActiveStrategy(strategyList[i])) {
                    uint256 balanceBefore = underlyingBalanceInFund();
                    uint256 weightage = strategies[strategyList[i]].weightage;
                    uint256 missingforStrategy =
                        (missing.mul(weightage).div(_totalWeightInStrategies()))
                            .add(missingCarryOver);
                    IStrategy(strategyList[i]).withdrawToFund(
                        missingforStrategy
                    );
                    missingCarryOver = missingforStrategy
                        .add(balanceBefore)
                        .sub(underlyingBalanceInFund());
                }
            }
            underlyingAmountToWithdraw = MathUpgradeable.min(
                underlyingAmountToWithdraw,
                underlyingBalanceInFund()
            );
            _setShouldRebalance(true);
        }

        IERC20(_underlying()).safeTransfer(
            msg.sender,
            underlyingAmountToWithdraw
        );

        emit Withdraw(msg.sender, underlyingAmountToWithdraw);
    }

    function scheduleUpgrade(address newImplementation)
        external
        onlyGovernance
    {

        require(
            newImplementation != ZERO_ADDRESS,
            "new implementation address can not be zero address"
        );
        require(
            newImplementation != IFundProxy(address(this)).implementation(),
            "new implementation address should not be same as current address"
        );
        _setNextImplementation(newImplementation);
        _setNextImplementationTimestamp(block.timestamp.add(_changeDelay()));
    }

    function shouldUpgrade() external view returns (bool, address) {

        return (
            _nextImplementationTimestamp() != 0 &&
                block.timestamp > _nextImplementationTimestamp() &&
                _nextImplementation() != ZERO_ADDRESS,
            _nextImplementation()
        );
    }

    function finalizeUpgrade() external onlyGovernance {

        _setNextImplementation(ZERO_ADDRESS);
        _setNextImplementationTimestamp(0);
    }

    function setFundManager(address newFundManager)
        external
        onlyFundManagerOrGovernance
    {

        _setFundManager(newFundManager);
    }

    function setRelayer(address newRelayer) external onlyFundManager {

        _setRelayer(newRelayer);
    }

    function setPlatformRewards(address newRewards) external onlyGovernance {

        _setPlatformRewards(newRewards);
    }

    function setShouldRebalance(bool trigger) external onlyFundManager {

        _setShouldRebalance(trigger);
    }

    function setMaxInvestmentInStrategies(uint256 value)
        external
        onlyFundManager
    {

        require(value < MAX_BPS, "Value greater than 100%");
        _setMaxInvestmentInStrategies(value);
    }

    function setDepositLimit(uint256 limit) external onlyFundManager {

        _setDepositLimit(limit);
    }

    function depositLimit() external view returns (uint256) {

        return _depositLimit();
    }

    function setDepositLimitTxMax(uint256 limit) external onlyFundManager {

        require(
            _depositLimitTxMin() == 0 || limit > _depositLimitTxMin(),
            "Max limit greater than min limit"
        );
        _setDepositLimitTxMax(limit);
    }

    function depositLimitTxMax() external view returns (uint256) {

        return _depositLimitTxMax();
    }

    function setDepositLimitTxMin(uint256 limit) external onlyFundManager {

        require(
            _depositLimitTxMax() == 0 || limit < _depositLimitTxMax(),
            "Min limit greater than max limit"
        );
        _setDepositLimitTxMin(limit);
    }

    function depositLimitTxMin() external view returns (uint256) {

        return _depositLimitTxMin();
    }

    function setPerformanceFeeFund(uint256 fee) external onlyFundManager {

        require(fee <= MAX_PERFORMANCE_FEE_FUND, "Fee greater than max limit");
        _setPerformanceFeeFund(fee);
    }

    function performanceFeeFund() external view returns (uint256) {

        return _performanceFeeFund();
    }

    function setPlatformFee(uint256 fee) external onlyGovernance {

        require(fee <= MAX_PLATFORM_FEE, "Fee greater than max limit");
        _setPlatformFee(fee);
    }

    function platformFee() external view returns (uint256) {

        return _platformFee();
    }

    function sweep(address _token, address _sweepTo) external onlyGovernance {

        require(_token != address(_underlying()), "can not sweep underlying");
        require(_sweepTo != ZERO_ADDRESS, "can not sweep to zero");
        IERC20(_token).safeTransfer(
            _sweepTo,
            IERC20(_token).balanceOf(address(this))
        );
    }
}