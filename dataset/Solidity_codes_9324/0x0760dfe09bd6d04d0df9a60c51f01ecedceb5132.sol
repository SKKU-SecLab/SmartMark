

pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}



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
}


pragma solidity ^0.6.2;

interface IPCVDeposit {

    event Deposit(address indexed _from, uint256 _amount);

    event Withdrawal(
        address indexed _caller,
        address indexed _to,
        uint256 _amount
    );


    function deposit(uint256 amount) external payable;



    function withdraw(address to, uint256 amount) external;



    function totalValue() external view returns (uint256);

}


pragma solidity ^0.6.2;

interface IIncentive {


    function incentivize(
        address sender,
        address receiver,
        address operator,
        uint256 amount
    ) external;

}



pragma solidity ^0.6.0;

library SafeMathCopy { // To avoid namespace collision between openzeppelin safemath and uniswap safemath

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
}



pragma solidity ^0.6.0;


library Decimal {

    using SafeMathCopy for uint256;


    uint256 private constant BASE = 10**18;



    struct D256 {
        uint256 value;
    }


    function zero()
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: 0 });
    }

    function one()
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: BASE });
    }

    function from(
        uint256 a
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: a.mul(BASE) });
    }

    function ratio(
        uint256 a,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: getPartial(a, BASE, b) });
    }


    function add(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.add(b.mul(BASE)) });
    }

    function sub(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.sub(b.mul(BASE)) });
    }

    function sub(
        D256 memory self,
        uint256 b,
        string memory reason
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.sub(b.mul(BASE), reason) });
    }

    function mul(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.mul(b) });
    }

    function div(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.div(b) });
    }

    function pow(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {

        if (b == 0) {
            return from(1);
        }

        D256 memory temp = D256({ value: self.value });
        for (uint256 i = 1; i < b; i++) {
            temp = mul(temp, self);
        }

        return temp;
    }

    function add(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.add(b.value) });
    }

    function sub(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.sub(b.value) });
    }

    function sub(
        D256 memory self,
        D256 memory b,
        string memory reason
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.sub(b.value, reason) });
    }

    function mul(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: getPartial(self.value, b.value, BASE) });
    }

    function div(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: getPartial(self.value, BASE, b.value) });
    }

    function equals(D256 memory self, D256 memory b) internal pure returns (bool) {

        return self.value == b.value;
    }

    function greaterThan(D256 memory self, D256 memory b) internal pure returns (bool) {

        return compareTo(self, b) == 2;
    }

    function lessThan(D256 memory self, D256 memory b) internal pure returns (bool) {

        return compareTo(self, b) == 0;
    }

    function greaterThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {

        return compareTo(self, b) > 0;
    }

    function lessThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {

        return compareTo(self, b) < 2;
    }

    function isZero(D256 memory self) internal pure returns (bool) {

        return self.value == 0;
    }

    function asUint256(D256 memory self) internal pure returns (uint256) {

        return self.value.div(BASE);
    }


    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
    private
    pure
    returns (uint256)
    {

        return target.mul(numerator).div(denominator);
    }

    function compareTo(
        D256 memory a,
        D256 memory b
    )
    private
    pure
    returns (uint256)
    {

        if (a.value == b.value) {
            return 1;
        }
        return a.value > b.value ? 2 : 0;
    }
}


pragma solidity ^0.6.2;



interface IUniswapIncentive is IIncentive {


    event TimeWeightUpdate(uint256 _weight, bool _active);

    event GrowthRateUpdate(uint256 _growthRate);

    event ExemptAddressUpdate(address indexed _account, bool _isExempt);


    function setExemptAddress(address account, bool isExempt) external;


    function setTimeWeightGrowth(uint32 growthRate) external;


    function setTimeWeight(
        uint32 weight,
        uint32 growth,
        bool active
    ) external;



    function isIncentiveParity() external view returns (bool);


    function isExemptAddress(address account) external view returns (bool);


    function TIME_WEIGHT_GRANULARITY() external view returns (uint32);


    function getGrowthRate() external view returns (uint32);


    function getTimeWeight() external view returns (uint32);


    function isTimeWeightActive() external view returns (bool);


    function getBuyIncentive(uint256 amount)
        external
        view
        returns (
            uint256 incentive,
            uint32 weight,
            Decimal.D256 memory initialDeviation,
            Decimal.D256 memory finalDeviation
        );


    function getSellPenalty(uint256 amount)
        external
        view
        returns (
            uint256 penalty,
            Decimal.D256 memory initialDeviation,
            Decimal.D256 memory finalDeviation
        );


    function getSellPenaltyMultiplier(
        Decimal.D256 calldata initialDeviation,
        Decimal.D256 calldata finalDeviation
    ) external view returns (Decimal.D256 memory);


    function getBuyIncentiveMultiplier(
        Decimal.D256 calldata initialDeviation,
        Decimal.D256 calldata finalDeviation
    ) external view returns (Decimal.D256 memory);

}


pragma solidity ^0.6.2;



interface IUniswapPCVController {


    event Reweight(address indexed _caller);

    event PCVDepositUpdate(address indexed _pcvDeposit);

    event ReweightIncentiveUpdate(uint256 _amount);

    event ReweightMinDistanceUpdate(uint256 _basisPoints);

    event ReweightWithdrawBPsUpdate(uint256 _reweightWithdrawBPs);


    function reweight() external;



    function forceReweight() external;


    function setPCVDeposit(address _pcvDeposit) external;


    function setDuration(uint256 _duration) external;


    function setReweightIncentive(uint256 amount) external;


    function setReweightMinDistance(uint256 basisPoints) external;


    function setReweightWithdrawBPs(uint256 _reweightWithdrawBPs) external;

    

    function pcvDeposit() external view returns (IPCVDeposit);


    function incentiveContract() external view returns (IUniswapIncentive);


    function reweightIncentiveAmount() external view returns (uint256);


    function reweightEligible() external view returns (bool);


    function reweightWithdrawBPs() external view returns (uint256);


    function minDistanceForReweight()
        external
        view
        returns (Decimal.D256 memory);

}



pragma solidity >=0.6.0 <0.8.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}



pragma solidity >=0.6.0 <0.8.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}



pragma solidity >=0.4.0;

library Babylonian {

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


pragma solidity ^0.6.0;


interface IOracle {


    event Update(uint256 _peg);


    function update() external returns (bool);



    function read() external view returns (Decimal.D256 memory, bool);


    function isOutdated() external view returns (bool);

    
}


pragma solidity ^0.6.0;


interface IOracleRef {


    event OracleUpdate(address indexed _oracle);


    function updateOracle() external returns (bool);



    function setOracle(address _oracle) external;



    function oracle() external view returns (IOracle);


    function peg() external view returns (Decimal.D256 memory);


    function invert(Decimal.D256 calldata price)
        external
        pure
        returns (Decimal.D256 memory);

}


pragma solidity ^0.6.0;

interface IPermissions {


    function createRole(bytes32 role, bytes32 adminRole) external;


    function grantMinter(address minter) external;


    function grantBurner(address burner) external;


    function grantPCVController(address pcvController) external;


    function grantGovernor(address governor) external;


    function grantGuardian(address guardian) external;


    function revokeMinter(address minter) external;


    function revokeBurner(address burner) external;


    function revokePCVController(address pcvController) external;


    function revokeGovernor(address governor) external;


    function revokeGuardian(address guardian) external;



    function revokeOverride(bytes32 role, address account) external;



    function isBurner(address _address) external view returns (bool);


    function isMinter(address _address) external view returns (bool);


    function isGovernor(address _address) external view returns (bool);


    function isGuardian(address _address) external view returns (bool);


    function isPCVController(address _address) external view returns (bool);

}



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
}


pragma solidity ^0.6.2;


interface IFei is IERC20 {


    event Minting(
        address indexed _to,
        address indexed _minter,
        uint256 _amount
    );

    event Burning(
        address indexed _to,
        address indexed _burner,
        uint256 _amount
    );

    event IncentiveContractUpdate(
        address indexed _incentivized,
        address indexed _incentiveContract
    );


    function burn(uint256 amount) external;


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;



    function burnFrom(address account, uint256 amount) external;



    function mint(address account, uint256 amount) external;



    function setIncentiveContract(address account, address incentive) external;



    function incentiveContract(address account) external view returns (address);

}


pragma solidity ^0.6.0;



interface ICore is IPermissions {


    event FeiUpdate(address indexed _fei);
    event TribeUpdate(address indexed _tribe);
    event GenesisGroupUpdate(address indexed _genesisGroup);
    event TribeAllocation(address indexed _to, uint256 _amount);
    event GenesisPeriodComplete(uint256 _timestamp);


    function init() external;



    function setFei(address token) external;


    function setTribe(address token) external;


    function setGenesisGroup(address _genesisGroup) external;


    function allocateTribe(address to, uint256 amount) external;



    function completeGenesisGroup() external;



    function fei() external view returns (IFei);


    function tribe() external view returns (IERC20);


    function genesisGroup() external view returns (address);


    function hasGenesisGroupCompleted() external view returns (bool);

}


pragma solidity ^0.6.0;


interface ICoreRef {


    event CoreUpdate(address indexed _core);


    function setCore(address core) external;


    function pause() external;


    function unpause() external;



    function core() external view returns (ICore);


    function fei() external view returns (IFei);


    function tribe() external view returns (IERC20);


    function feiBalance() external view returns (uint256);


    function tribeBalance() external view returns (uint256);

}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}



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


pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;




abstract contract CoreRef is ICoreRef, Pausable {
    ICore private _core;

    constructor(address core) public {
        _core = ICore(core);
    }

    modifier ifMinterSelf() {
        if (_core.isMinter(address(this))) {
            _;
        }
    }

    modifier ifBurnerSelf() {
        if (_core.isBurner(address(this))) {
            _;
        }
    }

    modifier onlyMinter() {
        require(_core.isMinter(msg.sender), "CoreRef: Caller is not a minter");
        _;
    }

    modifier onlyBurner() {
        require(_core.isBurner(msg.sender), "CoreRef: Caller is not a burner");
        _;
    }

    modifier onlyPCVController() {
        require(
            _core.isPCVController(msg.sender),
            "CoreRef: Caller is not a PCV controller"
        );
        _;
    }

    modifier onlyGovernor() {
        require(
            _core.isGovernor(msg.sender),
            "CoreRef: Caller is not a governor"
        );
        _;
    }

    modifier onlyGuardianOrGovernor() {
        require(
            _core.isGovernor(msg.sender) ||
            _core.isGuardian(msg.sender),
            "CoreRef: Caller is not a guardian or governor"
        );
        _;
    }

    modifier onlyFei() {
        require(msg.sender == address(fei()), "CoreRef: Caller is not FEI");
        _;
    }

    modifier onlyGenesisGroup() {
        require(
            msg.sender == _core.genesisGroup(),
            "CoreRef: Caller is not GenesisGroup"
        );
        _;
    }

    modifier postGenesis() {
        require(
            _core.hasGenesisGroupCompleted(),
            "CoreRef: Still in Genesis Period"
        );
        _;
    }

    modifier nonContract() {
        require(!Address.isContract(msg.sender), "CoreRef: Caller is a contract");
        _;
    }

    function setCore(address core) external override onlyGovernor {
        _core = ICore(core);
        emit CoreUpdate(core);
    }

    function pause() public override onlyGuardianOrGovernor {
        _pause();
    }

    function unpause() public override onlyGuardianOrGovernor {
        _unpause();
    }

    function core() public view override returns (ICore) {
        return _core;
    }

    function fei() public view override returns (IFei) {
        return _core.fei();
    }

    function tribe() public view override returns (IERC20) {
        return _core.tribe();
    }

    function feiBalance() public view override returns (uint256) {
        return fei().balanceOf(address(this));
    }

    function tribeBalance() public view override returns (uint256) {
        return tribe().balanceOf(address(this));
    }

    function _burnFeiHeld() internal {
        fei().burn(feiBalance());
    }

    function _mintFei(uint256 amount) internal {
        fei().mint(address(this), amount);
    }
}


pragma solidity ^0.6.0;



abstract contract OracleRef is IOracleRef, CoreRef {
    using Decimal for Decimal.D256;

    IOracle public override oracle;

    constructor(address _core, address _oracle) public CoreRef(_core) {
        _setOracle(_oracle);
    }

    function setOracle(address _oracle) external override onlyGovernor {
        _setOracle(_oracle);
    }

    function invert(Decimal.D256 memory price)
        public
        pure
        override
        returns (Decimal.D256 memory)
    {
        return Decimal.one().div(price);
    }

    function updateOracle() public override returns (bool) {
        return oracle.update();
    }

    function peg() public view override returns (Decimal.D256 memory) {
        (Decimal.D256 memory _peg, bool valid) = oracle.read();
        require(valid, "OracleRef: oracle invalid");
        return _peg;
    }

    function _setOracle(address _oracle) internal {
        oracle = IOracle(_oracle);
        emit OracleUpdate(_oracle);
    }
}


pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}


pragma solidity >=0.5.0;

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

}


pragma solidity ^0.6.0;





interface IUniRef {


    event PairUpdate(address indexed _pair);


    function setPair(address _pair) external;



    function router() external view returns (IUniswapV2Router02);


    function pair() external view returns (IUniswapV2Pair);


    function token() external view returns (address);


    function getReserves()
        external
        view
        returns (uint256 feiReserves, uint256 tokenReserves);


    function deviationBelowPeg(
        Decimal.D256 calldata price,
        Decimal.D256 calldata peg
    ) external pure returns (Decimal.D256 memory);


    function liquidityOwned() external view returns (uint256);

}


pragma solidity ^0.6.0;






abstract contract UniRef is IUniRef, OracleRef {
    using Decimal for Decimal.D256;
    using Babylonian for uint256;
    using SignedSafeMath for int256;
    using SafeMathCopy for uint256;
    using SafeCast for uint256;
    using SafeCast for int256;

    IUniswapV2Router02 public override router;

    IUniswapV2Pair public override pair;

    constructor(
        address _core,
        address _pair,
        address _router,
        address _oracle
    ) public OracleRef(_core, _oracle) {
        _setupPair(_pair);

        router = IUniswapV2Router02(_router);

        _approveToken(address(fei()));
        _approveToken(token());
        _approveToken(_pair);
    }

    function setPair(address _pair) external override onlyGovernor {
        _setupPair(_pair);

        _approveToken(token());
        _approveToken(_pair);
    }

    function token() public view override returns (address) {
        address token0 = pair.token0();
        if (address(fei()) == token0) {
            return pair.token1();
        }
        return token0;
    }

    function getReserves()
        public
        view
        override
        returns (uint256 feiReserves, uint256 tokenReserves)
    {
        address token0 = pair.token0();
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        (feiReserves, tokenReserves) = address(fei()) == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        return (feiReserves, tokenReserves);
    }

    function deviationBelowPeg(
        Decimal.D256 calldata price,
        Decimal.D256 calldata peg
    ) external pure override returns (Decimal.D256 memory) {
        return _deviationBelowPeg(price, peg);
    }

    function liquidityOwned() public view override returns (uint256) {
        return pair.balanceOf(address(this));
    }

    function _ratioOwned() internal view returns (Decimal.D256 memory) {
        uint256 balance = liquidityOwned();
        uint256 total = pair.totalSupply();
        return Decimal.ratio(balance, total);
    }

    function _isBelowPeg(Decimal.D256 memory peg) internal view returns (bool) {
        (Decimal.D256 memory price, , ) = _getUniswapPrice();
        return peg.lessThan(price);
    }

    function _approveToken(address _token) internal {
        uint256 maxTokens = uint256(-1);
        IERC20(_token).approve(address(router), maxTokens);
    }

    function _setupPair(address _pair) internal {
        pair = IUniswapV2Pair(_pair);
        emit PairUpdate(_pair);
    }

    function _isPair(address account) internal view returns (bool) {
        return address(pair) == account;
    }

    function _getAmountToPeg(
        uint256 reserveTarget,
        uint256 reserveOther,
        Decimal.D256 memory peg
    ) internal pure returns (uint256) {
        uint256 radicand = peg.mul(reserveTarget).mul(reserveOther).asUint256();
        uint256 root = radicand.sqrt();
        if (root > reserveTarget) {
            return (root - reserveTarget).mul(1000).div(997);
        }
        return (reserveTarget - root).mul(1000).div(997);
    }

    function _getAmountToPegFei(
        uint256 feiReserves,
        uint256 tokenReserves,
        Decimal.D256 memory peg
    ) internal pure returns (uint256) {
        return _getAmountToPeg(feiReserves, tokenReserves, peg);
    }

    function _getAmountToPegOther(
        uint256 feiReserves,
        uint256 tokenReserves,
        Decimal.D256 memory peg
    ) internal pure returns (uint256) {
        return _getAmountToPeg(tokenReserves, feiReserves, invert(peg));
    }

    function _getUniswapPrice()
        internal
        view
        returns (
            Decimal.D256 memory,
            uint256 reserveFei,
            uint256 reserveOther
        )
    {
        (reserveFei, reserveOther) = getReserves();
        return (
            Decimal.ratio(reserveFei, reserveOther),
            reserveFei,
            reserveOther
        );
    }

    function _getFinalPrice(
        int256 amountFei,
        uint256 reserveFei,
        uint256 reserveOther
    ) internal pure returns (Decimal.D256 memory) {
        uint256 k = reserveFei.mul(reserveOther);
        int256 signedReservesFei = reserveFei.toInt256();
        int256 amountFeiWithFee = amountFei > 0 ? amountFei.mul(997).div(1000) : amountFei; // buys already have fee factored in on uniswap's other token side

        uint256 adjustedReserveFei = signedReservesFei.add(amountFeiWithFee).toUint256();
        uint256 adjustedReserveOther = k / adjustedReserveFei;
        return Decimal.ratio(adjustedReserveFei, adjustedReserveOther); // alt: adjustedReserveFei^2 / k
    }

    function _getPriceDeviations(int256 amountIn)
        internal
        view
        returns (
            Decimal.D256 memory initialDeviation,
            Decimal.D256 memory finalDeviation,
            Decimal.D256 memory _peg,
            uint256 feiReserves,
            uint256 tokenReserves
        )
    {
        _peg = peg();

        (Decimal.D256 memory price, uint256 reserveFei, uint256 reserveOther) =
            _getUniswapPrice();
        initialDeviation = _deviationBelowPeg(price, _peg);

        Decimal.D256 memory finalPrice =
            _getFinalPrice(amountIn, reserveFei, reserveOther);
        finalDeviation = _deviationBelowPeg(finalPrice, _peg);

        return (
            initialDeviation,
            finalDeviation,
            _peg,
            reserveFei,
            reserveOther
        );
    }

    function _getDistanceToPeg()
        internal
        view
        returns (Decimal.D256 memory distance)
    {
        (Decimal.D256 memory price, , ) = _getUniswapPrice();
        return _deviationBelowPeg(price, peg());
    }

    function _deviationBelowPeg(
        Decimal.D256 memory price,
        Decimal.D256 memory peg
    ) internal pure returns (Decimal.D256 memory) {
        if (price.lessThanOrEqualTo(peg)) {
            return Decimal.zero();
        }
        Decimal.D256 memory delta = price.sub(peg, "Impossible underflow");
        return delta.div(peg);
    }
}


pragma solidity >=0.6.0;


 library UniswapV2Library {

    using SafeMathCopy for uint;

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
 }


pragma solidity ^0.6.0;


abstract contract Timed {
    using SafeCast for uint256;

    uint256 public startTime;

    uint256 public duration;

    event DurationUpdate(uint256 _duration);

    event TimerReset(uint256 _startTime);

    constructor(uint256 _duration) public {
        _setDuration(_duration);
    }

    modifier duringTime() {
        require(isTimeStarted(), "Timed: time not started");
        require(!isTimeEnded(), "Timed: time ended");
        _;
    }

    modifier afterTime() {
        require(isTimeEnded(), "Timed: time not ended");
        _;
    }

    function isTimeEnded() public view returns (bool) {
        return remainingTime() == 0;
    }

    function remainingTime() public view returns (uint256) {
        return duration - timeSinceStart(); // duration always >= timeSinceStart which is on [0,d]
    }

    function timeSinceStart() public view returns (uint256) {
        if (!isTimeStarted()) {
            return 0; // uninitialized
        }
        uint256 _duration = duration;
        uint256 timePassed = block.timestamp - startTime; // block timestamp always >= startTime
        return timePassed > _duration ? _duration : timePassed;
    }

    function isTimeStarted() public view returns (bool) {
        return startTime != 0;
    }

    function _initTimed() internal {
        startTime = block.timestamp;
        
        emit TimerReset(block.timestamp);
    }

    function _setDuration(uint _duration) internal {
        duration = _duration;
        emit DurationUpdate(_duration);
    }
}


pragma solidity ^0.6.0;







contract EthUniswapPCVController is IUniswapPCVController, UniRef, Timed {

    using Decimal for Decimal.D256;
    using SafeMathCopy for uint256;

    uint256 public override reweightWithdrawBPs = 9900;

    uint256 internal _reweightDuration = 4 hours;

    uint256 internal constant BASIS_POINTS_GRANULARITY = 10000;

    IPCVDeposit public override pcvDeposit;

    uint256 public override reweightIncentiveAmount;
    Decimal.D256 internal _minDistanceForReweight;

    constructor(
        address _core,
        address _pcvDeposit,
        address _oracle,
        uint256 _incentiveAmount,
        uint256 _minDistanceForReweightBPs,
        address _pair,
        address _router
    ) public UniRef(_core, _pair, _router, _oracle) Timed(_reweightDuration) {
        pcvDeposit = IPCVDeposit(_pcvDeposit);

        reweightIncentiveAmount = _incentiveAmount;
        _minDistanceForReweight = Decimal.ratio(
            _minDistanceForReweightBPs,
            BASIS_POINTS_GRANULARITY
        );

        _initTimed();
    }

    receive() external payable {}

    function reweight() external override whenNotPaused {

        updateOracle();
        require(
            reweightEligible(),
            "EthUniswapPCVController: Not passed reweight time or not at min distance"
        );
        _reweight();
        _incentivize();
    }

    function forceReweight() external override onlyGuardianOrGovernor {

        _reweight();
    }

    function setPCVDeposit(address _pcvDeposit) external override onlyGovernor {

        pcvDeposit = IPCVDeposit(_pcvDeposit);
        emit PCVDepositUpdate(_pcvDeposit);
    }

    function setReweightIncentive(uint256 amount)
        external
        override
        onlyGovernor
    {

        reweightIncentiveAmount = amount;
        emit ReweightIncentiveUpdate(amount);
    }

    function setReweightWithdrawBPs(uint256 _reweightWithdrawBPs)
        external
        override
        onlyGovernor
    {

        require(_reweightWithdrawBPs <= BASIS_POINTS_GRANULARITY, "EthUniswapPCVController: withdraw percent too high");
        reweightWithdrawBPs = _reweightWithdrawBPs;
        emit ReweightWithdrawBPsUpdate(_reweightWithdrawBPs);
    }

    function setReweightMinDistance(uint256 basisPoints)
        external
        override
        onlyGovernor
    {

        _minDistanceForReweight = Decimal.ratio(
            basisPoints,
            BASIS_POINTS_GRANULARITY
        );
        emit ReweightMinDistanceUpdate(basisPoints);
    }

    function setDuration(uint256 _duration)
        external
        override
        onlyGovernor
    {

       _setDuration(_duration);
    }

    function reweightEligible() public view override returns (bool) {

        bool magnitude =
            _getDistanceToPeg().greaterThan(_minDistanceForReweight);
        bool time = isTimeEnded();
        return magnitude && time;
    }

    function minDistanceForReweight()
        external
        view
        override
        returns (Decimal.D256 memory)
    {

        return _minDistanceForReweight;
    }

    function incentiveContract() public view override returns(IUniswapIncentive) {

        return IUniswapIncentive(fei().incentiveContract(address(pair)));
    }

    function _incentivize() internal ifMinterSelf {

        fei().mint(msg.sender, reweightIncentiveAmount);
    }

    function _reweight() internal {

        _withdraw();
        _returnToPeg();

        uint256 balance = address(this).balance;
        pcvDeposit.deposit{value: balance}(balance);

        _burnFeiHeld();

        _initTimed();

        emit Reweight(msg.sender);
    }

    function _returnToPeg() internal {

        (uint256 feiReserves, uint256 ethReserves) = getReserves();
        if (feiReserves == 0 || ethReserves == 0) {
            return;
        }

        updateOracle();

        Decimal.D256 memory _peg = peg();
        require(
            _isBelowPeg(_peg),
            "EthUniswapPCVController: already at or above peg"
        );

        uint256 amountEth = _getAmountToPegOther(feiReserves, ethReserves, _peg);
        _swapEth(amountEth, ethReserves, feiReserves);
    }

    function _swapEth(
        uint256 amountEth,
        uint256 ethReserves,
        uint256 feiReserves
    ) internal {

        uint256 balance = address(this).balance;
        uint256 amount = Math.min(amountEth, balance);

        uint256 amountOut =
            UniswapV2Library.getAmountOut(amount, ethReserves, feiReserves);

        IWETH weth = IWETH(router.WETH());
        weth.deposit{value: amount}();
        assert(weth.transfer(address(pair), amount));

        (uint256 amount0Out, uint256 amount1Out) =
            pair.token0() == address(weth)
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
        pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

    function _withdraw() internal {

        uint256 value =
            pcvDeposit.totalValue().mul(reweightWithdrawBPs) /
                BASIS_POINTS_GRANULARITY;
        pcvDeposit.withdraw(address(this), value);
    }
}