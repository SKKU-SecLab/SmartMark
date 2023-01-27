
pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
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

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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

library Decimal {

    using SafeMath for uint256;


    uint256 constant BASE = 10**18;



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

    function subOrZero(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {

        uint256 amount = b.mul(BASE);
        return D256({ value: self.value > amount ? self.value.sub(amount) : 0 });
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

    function div(
        D256 memory self,
        uint256 b,
        string memory reason
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value.div(b, reason) });
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

    function subOrZero(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: self.value > b.value ? self.value.sub(b.value) : 0 });
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

    function div(
        D256 memory self,
        D256 memory b,
        string memory reason
    )
    internal
    pure
    returns (D256 memory)
    {

        return D256({ value: getPartial(self.value, BASE, b.value, reason) });
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


    function min(D256 memory a, D256 memory b) internal pure returns (Decimal.D256 memory) {

        return lessThan(a, b) ? a : b;
    }

    function max(D256 memory a, D256 memory b) internal pure returns (Decimal.D256 memory) {

        return greaterThan(a, b) ? a : b;
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

    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator,
        string memory reason
    )
    private
    pure
    returns (uint256)
    {

        return target.mul(numerator).div(denominator, reason);
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

interface IManagedToken {


    function burn(uint256 amount) external;


    function mint(uint256 amount) external;

}

interface IGovToken {


    function delegate(address delegatee) external;

}

interface IReserve {

    function redeemPrice() external view returns (Decimal.D256 memory);

}

interface IRegistry {

    function usdc() external view returns (address);


    function cUsdc() external view returns (address);


    function dollar() external view returns (address);


    function stake() external view returns (address);


    function reserve() external view returns (address);


    function governor() external view returns (address);


    function timelock() external view returns (address);


    function migrator() external view returns (address);


    function setUsdc(address newValue) external;


    function setCUsdc(address newValue) external;


    function setDollar(address newValue) external;


    function setStake(address newValue) external;


    function setReserve(address newValue) external;


    function setGovernor(address newValue) external;


    function setTimelock(address newValue) external;


    function setMigrator(address newValue) external;

}

library TimeUtils {

    uint256 private constant SECONDS_IN_DAY = 86400;

    function secondsToDays(uint256 s) internal pure returns (Decimal.D256 memory) {

        return Decimal.ratio(s, SECONDS_IN_DAY);
    }
}

contract Implementation {


    event OwnerUpdate(address newOwner);

    event RegistryUpdate(address newRegistry);

    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    bytes32 private constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    bytes32 private constant OWNER_SLOT = keccak256("emptyset.v2.implementation.owner");

    bytes32 private constant REGISTRY_SLOT = keccak256("emptyset.v2.implementation.registry");

    bytes32 private constant NOT_ENTERED_SLOT = keccak256("emptyset.v2.implementation.notEntered");


    function implementation() external view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function admin() external view returns (address adm) {

        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }


    function setRegistry(address newRegistry) external onlyOwner {

        IRegistry registry = registry();

        require(newRegistry != address(0), "Implementation: zero address");
        require(
            (address(registry) == address(0) && Address.isContract(newRegistry)) ||
                IRegistry(newRegistry).timelock() == registry.timelock(),
            "Implementation: timelocks must match"
        );

        _setRegistry(newRegistry);

        emit RegistryUpdate(newRegistry);
    }

    function _setRegistry(address newRegistry) internal {

        bytes32 position = REGISTRY_SLOT;
        assembly {
            sstore(position, newRegistry)
        }
    }

    function registry() public view returns (IRegistry reg) {

        bytes32 slot = REGISTRY_SLOT;
        assembly {
            reg := sload(slot)
        }
    }


    function takeOwnership() external {

        require(owner() == address(0), "Implementation: already initialized");

        _setOwner(msg.sender);

        emit OwnerUpdate(msg.sender);
    }

    function setOwner(address newOwner) external onlyOwner {

        require(newOwner != address(this), "Implementation: this");
        require(Address.isContract(newOwner), "Implementation: not contract");

        _setOwner(newOwner);

        emit OwnerUpdate(newOwner);
    }

    function _setOwner(address newOwner) internal {

        bytes32 position = OWNER_SLOT;
        assembly {
            sstore(position, newOwner)
        }
    }

    function owner() public view returns (address o) {

        bytes32 slot = OWNER_SLOT;
        assembly {
            o := sload(slot)
        }
    }

    modifier onlyOwner {

        require(msg.sender == owner(), "Implementation: not owner");

        _;
    }


    modifier nonReentrant() {

        require(notEntered(), "Implementation: reentrant call");

        _setNotEntered(false);

        _;

        _setNotEntered(true);
    }

    function notEntered() internal view returns (bool ne) {

        bytes32 slot = NOT_ENTERED_SLOT;
        assembly {
            ne := sload(slot)
        }
    }

    function _setNotEntered(bool newNotEntered) internal {

        bytes32 position = NOT_ENTERED_SLOT;
        assembly {
            sstore(position, newNotEntered)
        }
    }


    function setup() external onlyOwner {

        _setNotEntered(true);
        _setup();
    }

    function _setup() internal { }

}

contract ReserveTypes {

    struct Order {
        Decimal.D256 price;

        uint256 amount;
    }

    struct State {

        uint256 totalDebt;

        mapping(address => uint256) debt;

        mapping(address => mapping(address => ReserveTypes.Order)) orders;
    }
}

contract ReserveState {

    ReserveTypes.State internal _state;
}

contract ReserveAccessors is Implementation, ReserveState {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;


    function order(address makerToken, address takerToken) public view returns (ReserveTypes.Order memory) {
        return _state.orders[makerToken][takerToken];
    }

    function totalDebt() public view returns (uint256) {
        return _state.totalDebt;
    }

    function debt(address borrower) public view returns (uint256) {
        return _state.debt[borrower];
    }

    function _updateOrder(address makerToken, address takerToken, uint256 price, uint256 amount) internal {
        _state.orders[makerToken][takerToken] = ReserveTypes.Order({price: Decimal.D256({value: price}), amount: amount});
    }

    function _decrementOrderAmount(address makerToken, address takerToken, uint256 amount, string memory reason) internal {
        _state.orders[makerToken][takerToken].amount = _state.orders[makerToken][takerToken].amount.sub(amount, reason);
    }

    function _incrementDebt(address borrower, uint256 amount) internal {
        _state.totalDebt = _state.totalDebt.add(amount);
        _state.debt[borrower] = _state.debt[borrower].add(amount);
    }

    function _decrementDebt(address borrower, uint256 amount, string memory reason) internal {
        _state.totalDebt = _state.totalDebt.sub(amount, reason);
        _state.debt[borrower] = _state.debt[borrower].sub(amount, reason);
    }
}

contract ReserveVault is ReserveAccessors {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Decimal for Decimal.D256;

    event SupplyVault(uint256 amount);

    event RedeemVault(uint256 amount);

    function _balanceOfVault() internal view returns (uint256) {
        ICErc20 cUsdc = ICErc20(registry().cUsdc());

        Decimal.D256 memory exchangeRate = Decimal.D256({value: cUsdc.exchangeRateStored()});
        return exchangeRate.mul(cUsdc.balanceOf(address(this))).asUint256();
    }

    function _supplyVault(uint256 amount) internal {
        address cUsdc = registry().cUsdc();

        IERC20(registry().usdc()).safeApprove(cUsdc, amount);
        require(ICErc20(cUsdc).mint(amount) == 0, "ReserveVault: supply failed");

        emit SupplyVault(amount);
    }

    function _redeemVault(uint256 amount) internal {
        require(ICErc20(registry().cUsdc()).redeemUnderlying(amount) == 0, "ReserveVault: redeem failed");

        emit RedeemVault(amount);
    }

    function claimVault() external onlyOwner {
        ICErc20(registry().cUsdc()).comptroller().claimComp(address(this));
    }

    function delegateVault(address token, address delegatee) external onlyOwner {
        IGovToken(token).delegate(delegatee);
    }
}

contract ICErc20 {
    function mint(uint mintAmount) external returns (uint256);

    function redeemUnderlying(uint redeemAmount) external returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function comptroller() public view returns (IComptroller);
}

contract IComptroller {

    function claimComp(address holder) public;
}

contract ReserveComptroller is ReserveAccessors, ReserveVault {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;
    using SafeERC20 for IERC20;

    event Mint(address indexed account, uint256 mintAmount, uint256 costAmount);

    event Redeem(address indexed account, uint256 costAmount, uint256 redeemAmount);

    event Borrow(address indexed account, uint256 borrowAmount);

    event Repay(address indexed account, uint256 repayAmount);

    uint256 private constant USDC_DECIMAL_DIFF = 1e12;


    function reserveBalance() public view returns (uint256) {
        uint256 internalBalance = _balanceOf(registry().usdc(), address(this));
        uint256 vaultBalance = _balanceOfVault();
        return internalBalance.add(vaultBalance);
    }

    function reserveRatio() public view returns (Decimal.D256 memory) {
        uint256 issuance = _totalSupply(registry().dollar()).sub(totalDebt());
        return issuance == 0 ? Decimal.one() : Decimal.ratio(_fromUsdcAmount(reserveBalance()), issuance);
    }

    function redeemPrice() public view returns (Decimal.D256 memory) {
        return Decimal.min(reserveRatio(), Decimal.one());
    }

    function mint(uint256 amount) external nonReentrant {
        uint256 costAmount = _toUsdcAmount(amount);

        costAmount = _fromUsdcAmount(costAmount) == amount ? costAmount : costAmount.add(1);

        _transferFrom(registry().usdc(), msg.sender, address(this), costAmount);
        _supplyVault(costAmount);
        _mintDollar(msg.sender, amount);

        emit Mint(msg.sender, amount, costAmount);
    }

    function redeem(uint256 amount) external nonReentrant {
        uint256 redeemAmount = _toUsdcAmount(redeemPrice().mul(amount).asUint256());

        _transferFrom(registry().dollar(), msg.sender, address(this), amount);
        _burnDollar(amount);
        _redeemVault(redeemAmount);
        _transfer(registry().usdc(), msg.sender, redeemAmount);

        emit Redeem(msg.sender, amount, redeemAmount);
    }

    function borrow(address account, uint256 amount) external onlyOwner nonReentrant {
        require(_canBorrow(account, amount), "ReserveComptroller: cant borrow");

        _incrementDebt(account, amount);
        _mintDollar(account, amount);

        emit Borrow(account, amount);
    }

    function repay(address account, uint256 amount) external nonReentrant {
        _decrementDebt(account, amount, "ReserveComptroller: insufficient debt");
        _transferFrom(registry().dollar(), msg.sender, address(this), amount);
        _burnDollar(amount);

        emit Repay(account, amount);
    }


    function _mintDollar(address account, uint256 amount) internal {
        address dollar = registry().dollar();

        IManagedToken(dollar).mint(amount);
        IERC20(dollar).safeTransfer(account, amount);
    }

    function _burnDollar(uint256 amount) internal {
        IManagedToken(registry().dollar()).burn(amount);
    }

    function _balanceOf(address token, address account) internal view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }

    function _totalSupply(address token) internal view returns (uint256) {
        return IERC20(token).totalSupply();
    }

    function _transfer(address token, address receiver, uint256 amount) internal {
        IERC20(token).safeTransfer(receiver, amount);
    }

    function _transferFrom(address token, address sender, address receiver, uint256 amount) internal {
        IERC20(token).safeTransferFrom(sender, receiver, amount);
    }

    function _toUsdcAmount(uint256 dec18Amount) internal pure returns (uint256) {
        return dec18Amount.div(USDC_DECIMAL_DIFF);
    }

    function _fromUsdcAmount(uint256 usdcAmount) internal pure returns (uint256) {
        return usdcAmount.mul(USDC_DECIMAL_DIFF);
    }

    function _canBorrow(address account, uint256 amount) private view returns (bool) {
        uint256 totalBorrowAmount = debt(account).add(amount);

        if ( // WrapOnlyBatcher
            account == address(0x0B663CeaCEF01f2f88EB7451C70Aa069f19dB997) &&
            totalBorrowAmount <= 1_000_000e18
        ) return true;

        return false;
    }
}

contract ReserveSwapper is ReserveComptroller {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;
    using SafeERC20 for IERC20;

    event OrderRegistered(address indexed makerToken, address indexed takerToken, uint256 price, uint256 amount);

    event Swap(address indexed makerToken, address indexed takerToken, uint256 takerAmount, uint256 makerAmount);

    function registerOrder(address makerToken, address takerToken, uint256 price, uint256 amount) external onlyOwner {
        _updateOrder(makerToken, takerToken, price, amount);

        emit OrderRegistered(makerToken, takerToken, price, amount);
    }

    function swap(address makerToken, address takerToken, uint256 takerAmount) external nonReentrant {
        address dollar = registry().dollar();
        require(makerToken != dollar, "ReserveSwapper: unsupported token");
        require(takerToken != dollar, "ReserveSwapper: unsupported token");
        require(makerToken != takerToken, "ReserveSwapper: tokens equal");

        ReserveTypes.Order memory order = order(makerToken, takerToken);
        uint256 makerAmount = Decimal.from(takerAmount).div(order.price, "ReserveSwapper: no order").asUint256();

        if (order.amount != uint256(-1))
            _decrementOrderAmount(makerToken, takerToken, makerAmount, "ReserveSwapper: insufficient amount");

        _transferFrom(takerToken, msg.sender, address(this), takerAmount);
        _transfer(makerToken, msg.sender, makerAmount);

        emit Swap(makerToken, takerToken, takerAmount, makerAmount);
    }
}

contract ReserveIssuer is ReserveAccessors {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    event MintStake(address account, uint256 mintAmount);

    event BurnStake(uint256 burnAmount);

    function mintStake(address account, uint256 amount) public onlyOwner {
        address stake = registry().stake();

        IManagedToken(stake).mint(amount);
        IERC20(stake).safeTransfer(account, amount);

        emit MintStake(account, amount);
    }

    function burnStake() public onlyOwner {
        address stake = registry().stake();

        uint256 stakeBalance = IERC20(stake).balanceOf(address(this));
        IManagedToken(stake).burn(stakeBalance);

        emit BurnStake(stakeBalance);
    }
}

contract ReserveImpl is IReserve, ReserveComptroller, ReserveIssuer, ReserveSwapper { }