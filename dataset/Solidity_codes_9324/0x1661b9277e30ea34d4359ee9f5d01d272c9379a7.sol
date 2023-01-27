


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



pragma solidity >=0.6.0 <0.8.0;

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
pragma experimental ABIEncoderV2;


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


pragma solidity ^0.6.0;



interface IGenesisGroup {

    event Purchase(address indexed _to, uint256 _value);

    event Redeem(
        address indexed _to,
        uint256 _amountIn,
        uint256 _amountFei,
        uint256 _amountTribe
    );

    event Commit(address indexed _from, address indexed _to, uint256 _amount);

    event Launch(uint256 _timestamp);

    
    function initGenesis() external;


    function purchase(address to, uint256 value) external payable;

    function redeem(address to) external;

    function commit(
        address from,
        address to,
        uint256 amount
    ) external;

    function launch() external;

    function emergencyExit(address from, address payable to) external;


    function getAmountOut(uint256 amountIn, bool inclusive)
        external
        view
        returns (uint256 feiAmount, uint256 tribeAmount);

    function getAmountsToRedeem(address to)
        external
        view
        returns (
            uint256 feiAmount,
            uint256 genesisTribe,
            uint256 idoTribe
        );

    function committedFGEN(address account) external view returns (uint256);

    function totalCommittedFGEN() external view returns (uint256);

    function totalCommittedTribe() external view returns (uint256);

    function launchBlock() external view returns (uint256);
}


pragma solidity ^0.6.0;


interface IDOInterface {

    event Deploy(uint256 _amountFei, uint256 _amountTribe);


    function deploy(Decimal.D256 calldata feiRatio) external;

    function swapFei(uint256 amountFei) external returns (uint256);


    function unlockLiquidity() external;

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


interface IOracle {

    event Update(uint256 _peg);


    function update() external returns (bool);


    function read() external view returns (Decimal.D256 memory, bool);

    function isOutdated() external view returns (bool);
    
}


pragma solidity ^0.6.0;


interface IBondingCurve {

    event ScaleUpdate(uint256 _scale);

    event BufferUpdate(uint256 _buffer);

    event IncentiveAmountUpdate(uint256 _incentiveAmount);

    event Purchase(address indexed _to, uint256 _amountIn, uint256 _amountOut);

    event Allocate(address indexed _caller, uint256 _amount);


    function purchase(address to, uint256 amountIn)
        external
        payable
        returns (uint256 amountOut);

    function allocate() external;


    function setBuffer(uint256 _buffer) external;

    function setScale(uint256 _scale) external;

    function setAllocation(
        address[] calldata pcvDeposits,
        uint256[] calldata ratios
    ) external;

    function setIncentiveAmount(uint256 _incentiveAmount) external;

    function setIncentiveFrequency(uint256 _frequency) external;


    function getCurrentPrice() external view returns (Decimal.D256 memory);

    function getAverageUSDPrice(uint256 amountIn)
        external
        view
        returns (Decimal.D256 memory);

    function getAmountOut(uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function scale() external view returns (uint256);

    function atScale() external view returns (bool);

    function buffer() external view returns (uint256);

    function totalPurchased() external view returns (uint256);

    function getTotalPCVHeld() external view returns (uint256);

    function incentiveAmount() external view returns (uint256);
}


pragma solidity ^0.6.0;




interface IBondingCurveOracle is IOracle {

    function init(Decimal.D256 calldata initialUSDPrice) external;


    function uniswapOracle() external view returns (IOracle);

    function bondingCurve() external view returns (IBondingCurve);

    function initialUSDPrice() external view returns (Decimal.D256 memory);
}


pragma solidity ^0.6.0;








contract GenesisGroup is IGenesisGroup, CoreRef, ERC20, Timed {
    using Decimal for Decimal.D256;

    IBondingCurve private bondingcurve;

    IBondingCurveOracle private bondingCurveOracle;

    IDOInterface private ido;
    uint256 private exchangeRateDiscount;

    mapping(address => uint256) public override committedFGEN;

    uint256 public override totalCommittedFGEN;

    uint256 public override totalCommittedTribe;
    
    uint256 public override launchBlock;

    constructor(
        address _core,
        address _bondingcurve,
        address _ido,
        address _oracle,
        uint256 _duration,
        uint256 _exchangeRateDiscount
    )
        public
        CoreRef(_core)
        ERC20("Feii Genesis Group", "FGEN")
        Timed(_duration)
    {
        bondingcurve = IBondingCurve(_bondingcurve);

        exchangeRateDiscount = _exchangeRateDiscount;
        ido = IDOInterface(_ido);

        uint256 maxTokens = uint256(-1);
        fei().approve(_ido, maxTokens);

        bondingCurveOracle = IBondingCurveOracle(_oracle);
    }

    function initGenesis() external override onlyGovernor {
        _initTimed();
    }

    function setBondingcurve(address _bondingcurve) external onlyGovernor {
        bondingcurve = IBondingCurve(_bondingcurve);
    }
    function setIDO(address _ido) external onlyGovernor {
        ido = IDOInterface(_ido);
        fei().approve(_ido, uint256(-1));
    }
    function setOracle(address _oracle) external onlyGovernor {
        bondingCurveOracle = IBondingCurveOracle(_oracle);
    }

    function purchase(address to, uint256 value)
        external
        payable
        override
        duringTime
    {
        require(msg.value == value, "GenesisGroup: value mismatch");
        require(value != 0, "GenesisGroup: no value sent");

        _mint(to, value);

        emit Purchase(to, value);
    }

    function commit(
        address from,
        address to,
        uint256 amount
    ) external override duringTime {
        _burnFrom(from, amount);

        committedFGEN[to] = committedFGEN[to].add(amount);
        totalCommittedFGEN = totalCommittedFGEN.add(amount);

        emit Commit(from, to, amount);
    }

    function redeem(address to) external override {
        (uint256 feiAmount, uint256 genesisTribe, uint256 idoTribe) =
            getAmountsToRedeem(to);
        require(
            block.number > launchBlock,
            "GenesisGroup: No redeeming in launch block"
        );

        uint256 tribeAmount = genesisTribe.add(idoTribe);
        require(tribeAmount != 0, "GenesisGroup: No redeemable TRIBE");

        uint256 amountIn = balanceOf(to);
        _burnFrom(to, amountIn);

        uint256 committed = committedFGEN[to];
        committedFGEN[to] = 0;
        totalCommittedFGEN = totalCommittedFGEN.sub(committed);

        totalCommittedTribe = totalCommittedTribe.sub(idoTribe);

        if (feiAmount != 0) {
            fei().transfer(to, feiAmount);
        }
        tribe().transfer(to, tribeAmount);

        emit Redeem(to, amountIn, feiAmount, tribeAmount);
    }

    function launch() external override nonContract afterTime {

        core().completeGenesisGroup();
        launchBlock = block.number;

        address genesisGroup = address(this);
        uint256 balance = genesisGroup.balance;

        bondingCurveOracle.init(bondingcurve.getAverageUSDPrice(balance));

        bondingcurve.purchase{value: balance}(genesisGroup, balance);
        bondingcurve.allocate();

        ido.deploy(_feiTribeExchangeRate());

        uint256 amountFei =
            feiBalance().mul(totalCommittedFGEN) /
                (totalSupply().add(totalCommittedFGEN));
        if (amountFei != 0) {
            totalCommittedTribe = ido.swapFei(amountFei);
        }

        emit Launch(block.timestamp);
    }

    function emergencyExit(address from, address payable to) external override {
        require(
            block.timestamp > (startTime + duration + 3 days),
            "GenesisGroup: Not in exit window"
        );
        require(
            !core().hasGenesisGroupCompleted(),
            "GenesisGroup: Launch already happened"
        );

        uint256 heldFGEN = balanceOf(from);
        uint256 committed = committedFGEN[from];
        uint256 total = heldFGEN.add(committed);

        require(total != 0, "GenesisGroup: No FGEN or committed balance");
        require(
            msg.sender == from || allowance(from, msg.sender) >= total,
            "GenesisGroup: Not approved for emergency withdrawal"
        );
        assert(address(this).balance >= total); // ETH can only be removed by launch which blocks this method or this method in event of launch failure

        _burnFrom(from, heldFGEN);
        committedFGEN[from] = 0;
        totalCommittedFGEN = totalCommittedFGEN.sub(committed);

        to.transfer(total);
    }

    function getAmountsToRedeem(address to)
        public
        view
        override
        postGenesis
        returns (
            uint256 feiAmount,
            uint256 genesisTribe,
            uint256 idoTribe
        )
    {
        uint256 userFGEN = balanceOf(to);
        uint256 userCommittedFGEN = committedFGEN[to];

        uint256 circulatingFGEN = totalSupply();
        uint256 totalFGEN = circulatingFGEN.add(totalCommittedFGEN);

        uint256 totalGenesisTribe = tribeBalance().sub(totalCommittedTribe);

        if (circulatingFGEN != 0) {
            feiAmount = feiBalance().mul(userFGEN) / circulatingFGEN;
        }

        if (totalFGEN != 0) {
            genesisTribe =
                totalGenesisTribe.mul(userFGEN.add(userCommittedFGEN)) /
                totalFGEN;
        }

        if (totalCommittedFGEN != 0) {
            idoTribe =
                totalCommittedTribe.mul(userCommittedFGEN) /
                totalCommittedFGEN;
        }

        return (feiAmount, genesisTribe, idoTribe);
    }

    function getAmountOut(uint256 amountIn, bool inclusive)
        public
        view
        override
        returns (uint256 feiAmount, uint256 tribeAmount)
    {
        uint256 totalIn = totalSupply().add(totalCommittedFGEN);
        if (!inclusive) {
            totalIn = totalIn.add(amountIn);
        }
        require(amountIn <= totalIn, "GenesisGroup: Not enough supply");

        uint256 totalFei = bondingcurve.getAmountOut(totalIn);
        uint256 totalTribe = tribeBalance();

        return (
            totalFei.mul(amountIn) / totalIn,
            totalTribe.mul(amountIn) / totalIn
        );
    }

    function _burnFrom(address account, uint256 amount) internal {
        if (msg.sender != account) {
            uint256 decreasedAllowance =
                allowance(account, _msgSender()).sub(
                    amount,
                    "GenesisGroup: burn amount exceeds allowance"
                );
            _approve(account, _msgSender(), decreasedAllowance);
        }
        _burn(account, amount);
    }

    function _feiTribeExchangeRate()
        internal
        view
        returns (Decimal.D256 memory)
    {
        return
            Decimal.ratio(feiBalance(), tribeBalance()).div(
                exchangeRateDiscount
            );
    }
}