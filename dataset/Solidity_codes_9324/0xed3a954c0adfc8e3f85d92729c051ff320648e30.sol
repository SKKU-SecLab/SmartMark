
pragma solidity ^0.7.0;

interface IERC20 {

  function totalSupply() external view returns (uint256 supply);


  function balanceOf(address _owner) external view returns (uint256 balance);


  function transfer(address _to, uint256 _value) external returns (bool success);


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) external returns (bool success);


  function approve(address _spender, uint256 _value) external returns (bool success);


  function allowance(address _owner, address _spender) external view returns (uint256 remaining);


  function decimals() external view returns (uint256 digits);


  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}// AGPL-3.0-or-later

pragma solidity >=0.7.6;

struct ExchangeData {
  address fromTokenAddress;
  address toTokenAddress;
  uint256 fromTokenAmount;
  uint256 toTokenAmount;
  uint256 minToTokenAmount;
  address exchangeAddress;
  bytes _exchangeCalldata;
}// MIT

pragma solidity >=0.7.6;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    return mod(a, b, 'SafeMath: modulo by zero');
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b != 0, errorMessage);
    return a % b;
  }
}// MIT

pragma solidity ^0.7.0;

abstract contract IGem {
  function dec() public virtual returns (uint256);

  function gem() public virtual returns (IGem);

  function join(address, uint256) public payable virtual;

  function exit(address, uint256) public virtual;

  function approve(address, uint256) public virtual;

  function transfer(address, uint256) public virtual returns (bool);

  function transferFrom(
    address,
    address,
    uint256
  ) public virtual returns (bool);

  function deposit() public payable virtual;

  function withdraw(uint256) public virtual;

  function allowance(address, address) public virtual returns (uint256);
}// MIT

pragma solidity ^0.7.0;


abstract contract IJoin {
  bytes32 public ilk;

  function dec() public view virtual returns (uint256);

  function gem() public view virtual returns (IGem);

  function join(address, uint256) public payable virtual;

  function exit(address, uint256) public virtual;
}// MIT

pragma solidity ^0.7.0;

abstract contract IManager {
  function last(address) public virtual returns (uint256);

  function cdpCan(
    address,
    uint256,
    address
  ) public view virtual returns (uint256);

  function ilks(uint256) public view virtual returns (bytes32);

  function owns(uint256) public view virtual returns (address);

  function urns(uint256) public view virtual returns (address);

  function vat() public view virtual returns (address);

  function open(bytes32, address) public virtual returns (uint256);

  function give(uint256, address) public virtual;

  function cdpAllow(
    uint256,
    address,
    uint256
  ) public virtual;

  function urnAllow(address, uint256) public virtual;

  function frob(
    uint256,
    int256,
    int256
  ) public virtual;

  function flux(
    uint256,
    address,
    uint256
  ) public virtual;

  function move(
    uint256,
    address,
    uint256
  ) public virtual;

  function exit(
    address,
    uint256,
    address,
    uint256
  ) public virtual;

  function quit(uint256, address) public virtual;

  function enter(address, uint256) public virtual;

  function shift(uint256, uint256) public virtual;
}// MIT

pragma solidity ^0.7.0;

abstract contract IVat {
  struct Urn {
    uint256 ink; // Locked Collateral  [wad]
    uint256 art; // Normalised Debt    [wad]
  }

  struct Ilk {
    uint256 Art; // Total Normalised Debt     [wad]
    uint256 rate; // Accumulated Rates         [ray]
    uint256 spot; // Price with Safety Margin  [ray]
    uint256 line; // Debt Ceiling              [rad]
    uint256 dust; // Urn Debt Floor            [rad]
  }

  mapping(bytes32 => mapping(address => Urn)) public urns;
  mapping(bytes32 => Ilk) public ilks;
  mapping(bytes32 => mapping(address => uint256)) public gem; // [wad]

  function can(address, address) public view virtual returns (uint256);

  function dai(address) public view virtual returns (uint256);

  function frob(
    bytes32,
    address,
    address,
    address,
    int256,
    int256
  ) public virtual;

  function hope(address) public virtual;

  function move(
    address,
    address,
    uint256
  ) public virtual;

  function fork(
    bytes32,
    address,
    address,
    int256,
    int256
  ) public virtual;
}// MIT

pragma solidity ^0.7.0;

abstract contract IJug {
  struct Ilk {
    uint256 duty;
    uint256 rho;
  }

  mapping(bytes32 => Ilk) public ilks;

  function drip(bytes32) public virtual returns (uint256);
}// MIT

pragma solidity ^0.7.0;


abstract contract IDaiJoin {
  function vat() public virtual returns (IVat);

  function dai() public virtual returns (IGem);

  function join(address, uint256) public payable virtual;

  function exit(address, uint256) public virtual;
}// MIT

pragma solidity ^0.7.0;

abstract contract IUniPool {
  function slot0()
    public view virtual
    returns (
      uint160,
      int24,
      uint16,
      uint16,
      uint16,
      uint8,
      bool
    );

  function swap(
    address,
    bool,
    int256,
    uint160,
    bytes calldata
  ) public view virtual;

  function positions(bytes32)
    public view virtual
    returns (
      uint128,
      uint256,
      uint256,
      uint128,
      uint128
    );
}// MIT

pragma solidity ^0.7.0;

abstract contract IGUNIRouter {
  function addLiquidity(
    address _pool,
    uint256 _amount0Max,
    uint256 _amount1Max,
    uint256 _amount0Min,
    uint256 _amount1Min,
    address _receiver
  )
    public virtual
    returns (
      uint256 amount0,
      uint256 amount1,
      uint256 mintAmount
    );

  function removeLiquidity(
    address _pool,
    uint256 _burnAmount,
    uint256 _amount0Min,
    uint256 _amount1Min,
    address _receiver
  )
    public virtual
    returns (
      uint256 amount0,
      uint256 amount1,
      uint256 liquidityBurned
    );
}// MIT

pragma solidity ^0.7.0;


abstract contract  IGUNIResolver {
  function getRebalanceParams(
    address pool,
    uint256 amount0In,
    uint256 amount1In,
    uint256 price18Decimals
  ) external view virtual returns (bool zeroForOne, uint256 swapAmount);
}// MIT

pragma solidity ^0.7.0;


abstract contract IGUNIToken is IERC20 {
  function mint(uint256 mintAmount, address receiver)
    public virtual
    returns (
      uint256 amount0,
      uint256 amount1,
      uint128 liquidityMinted
    );

  function burn(uint256 burnAmount, address receiver)
    public virtual
    returns (
      uint256 amount0,
      uint256 amount1,
      uint128 liquidityBurned
    );

  function getMintAmounts(uint256 amount0Max, uint256 amount1Max)
    public virtual
    view
    returns (
      uint256 amount0,
      uint256 amount1,
      uint256 mintAmount
    );

  function token0() public virtual view returns (address);

  function token1() public virtual view returns (address);

  function pool() public virtual view returns (address);

  function getUnderlyingBalances() public virtual view returns (uint256, uint256);
}pragma solidity >=0.7.0;

abstract contract IExchange {
  function swapDaiForToken(
    address asset,
    uint256 amount,
    uint256 receiveAtLeast,
    address callee,
    bytes calldata withData
  ) external virtual;

  function swapTokenForDai(
    address asset,
    uint256 amount,
    uint256 receiveAtLeast,
    address callee,
    bytes calldata withData
  ) external virtual;
}// AGPL-3.0-or-later

pragma solidity >=0.6.12;

interface IERC3156FlashBorrower {


    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);

}// AGPL-3.0-or-later

pragma solidity >=0.6.12;


interface IERC3156FlashLender {


    function maxFlashLoan(
        address token
    ) external view returns (uint256);


    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);


    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

}// AGPL-3.0-or-later

pragma solidity >=0.7.6;
pragma abicoder v2;

struct CdpData {
  address gemJoin;
  address payable fundsReceiver;
  uint256 cdpId;
  bytes32 ilk;
  uint256 requiredDebt;
  uint256 token0Amount;
  string methodName;
}

struct GuniAddressRegistry {
  address guni;
  address router;
  address resolver;
  address guniProxyActions;
  address otherToken;
  address exchange;
  address jug;
  address manager;
  address lender;
}

contract GuniMultiplyProxyActions is IERC3156FlashBorrower {

  using SafeMath for uint256;
  uint256 constant RAY = 10**27;
  address public constant DAIJOIN = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
  address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  IERC20 public constant daiContract = IERC20(DAI);

  modifier logMethodName(
    string memory name,
    CdpData memory data,
    address destination
  ) {

    if (bytes(data.methodName).length == 0) {
      data.methodName = name;
    }
    _;
    data.methodName = "";
  }

  function openMultiplyGuniVault(
    ExchangeData calldata exchangeData,
    CdpData memory cdpData,
    GuniAddressRegistry calldata guniAddressRegistry
  ) public logMethodName("openMultiplyGuniVault", cdpData, guniAddressRegistry.guniProxyActions) {

    cdpData.ilk = IJoin(cdpData.gemJoin).ilk();
    cdpData.cdpId = IManager(guniAddressRegistry.manager).open(cdpData.ilk, address(this));

    increaseMultipleGuni(exchangeData, cdpData, guniAddressRegistry);
  }

  function increaseMultipleGuni(
    ExchangeData calldata exchangeData,
    CdpData memory cdpData,
    GuniAddressRegistry calldata guniAddressRegistry
  ) public logMethodName("increaseMultipleGuni", cdpData, guniAddressRegistry.guniProxyActions) {

    daiContract.transferFrom(
      msg.sender,
      guniAddressRegistry.guniProxyActions,
      cdpData.token0Amount
    );
    takeAFlashLoan(exchangeData, cdpData, guniAddressRegistry, 1);
  }

  function closeGuniVaultExitDai(
    ExchangeData calldata exchangeData,
    CdpData memory cdpData,
    GuniAddressRegistry calldata guniAddressRegistry
  ) public logMethodName("closeGuniVaultExitDai", cdpData, guniAddressRegistry.guniProxyActions) {

    cdpData.ilk = IJoin(cdpData.gemJoin).ilk();

    address urn = IManager(guniAddressRegistry.manager).urns(cdpData.cdpId);
    address vat = IManager(guniAddressRegistry.manager).vat();

    uint256 wadD = _getWipeAllWad(vat, urn, urn, cdpData.ilk);
    cdpData.requiredDebt = wadD;

    takeAFlashLoan(exchangeData, cdpData, guniAddressRegistry, 0);
  }

  function takeAFlashLoan(
    ExchangeData calldata exchangeData,
    CdpData memory cdpData,
    GuniAddressRegistry calldata guniAddressRegistry,
    uint256 action
  ) internal {

    bytes memory paramsData = abi.encode(action, exchangeData, cdpData, guniAddressRegistry);

    IManager(guniAddressRegistry.manager).cdpAllow(
      cdpData.cdpId,
      guniAddressRegistry.guniProxyActions,
      1
    );

    IERC3156FlashLender(guniAddressRegistry.lender).flashLoan(
      IERC3156FlashBorrower(guniAddressRegistry.guniProxyActions),
      DAI,
      cdpData.requiredDebt,
      paramsData
    );

    IManager(guniAddressRegistry.manager).cdpAllow(
      cdpData.cdpId,
      guniAddressRegistry.guniProxyActions,
      0
    );
  }

  function _increaseMPGuni(
    ExchangeData memory exchangeData,
    CdpData memory cdpData,
    GuniAddressRegistry memory guniAddressRegistry,
    uint256 borrowedDaiAmount
  ) internal {

    IGUNIToken guni = IGUNIToken(guniAddressRegistry.guni);
    IERC20 otherToken = IERC20(guniAddressRegistry.otherToken);

    uint256 bal0 = daiContract.balanceOf(address(this));

    {
      IExchange exchange = IExchange(guniAddressRegistry.exchange);

      daiContract.approve(address(exchange), exchangeData.fromTokenAmount);

      exchange.swapDaiForToken(
        exchangeData.toTokenAddress,
        exchangeData.fromTokenAmount,
        exchangeData.minToTokenAmount,
        exchangeData.exchangeAddress,
        exchangeData._exchangeCalldata
      );
    }

    uint256 guniBalance;
    uint256 bal1 = otherToken.balanceOf(address(this));
    bal0 = daiContract.balanceOf(address(this));

    {
      IGUNIRouter router = IGUNIRouter(guniAddressRegistry.router);
      daiContract.approve(address(router), bal0);
      otherToken.approve(address(router), bal1);

      (, , guniBalance) = router.addLiquidity(address(guni), bal0, bal1, 0, 0, address(this));
    }

    guni.approve(guniAddressRegistry.guniProxyActions, guniBalance);
    joinDrawDebt(
      cdpData,
      borrowedDaiAmount.sub(IERC20(DAI).balanceOf(address(this))),
      guniAddressRegistry.manager,
      guniAddressRegistry.jug
    );

    uint256 daiLeft = IERC20(DAI).balanceOf(address(this)).sub(borrowedDaiAmount);
    uint256 otherTokenLeft = otherToken.balanceOf(address(this));

    emit MultipleActionCalled(
      cdpData.methodName,
      cdpData.cdpId,
      exchangeData.minToTokenAmount,
      exchangeData.toTokenAmount,
      0,
      daiLeft
    );

    if (daiLeft > 0) {
      IERC20(DAI).transfer(cdpData.fundsReceiver, daiLeft);
    }
    if (otherTokenLeft > 0) {
      otherToken.transfer(cdpData.fundsReceiver, otherTokenLeft);
    }
  }

  function _closeToDaiMPGuni(
    ExchangeData memory exchangeData,
    CdpData memory cdpData,
    GuniAddressRegistry memory guniAddressRegistry,
    uint256 borrowedDaiAmount
  ) internal {

    IExchange exchange = IExchange(guniAddressRegistry.exchange);
    IERC20 otherToken = IERC20(guniAddressRegistry.otherToken);
    uint256 ink = getInk(guniAddressRegistry.manager, cdpData);

    wipeAndFreeGem(
      guniAddressRegistry.manager,
      cdpData.gemJoin,
      cdpData.cdpId,
      cdpData.requiredDebt,
      ink
    );

    IGUNIToken guni = IGUNIToken(guniAddressRegistry.guni);

    uint256 guniBalance = guni.balanceOf(address(this));

    {
      IGUNIRouter router = IGUNIRouter(guniAddressRegistry.router);
      guni.approve(address(router), guniBalance);
      router.removeLiquidity(address(guni), guniBalance, 0, 0, address(this));
    }

    otherToken.approve(address(exchange), otherToken.balanceOf(address(this)));
    exchange.swapTokenForDai(
      exchangeData.toTokenAddress,
      otherToken.balanceOf(address(this)),
      exchangeData.minToTokenAmount,
      exchangeData.exchangeAddress,
      exchangeData._exchangeCalldata
    );

    uint256 daiLeft = IERC20(DAI).balanceOf(address(this)).sub(borrowedDaiAmount);
    uint256 otherTokenLeft = otherToken.balanceOf(address(this));

    emit MultipleActionCalled(
      cdpData.methodName,
      cdpData.cdpId,
      exchangeData.minToTokenAmount,
      exchangeData.toTokenAmount,
      0,
      daiLeft
    );

    if (daiLeft > 0) {
      IERC20(DAI).transfer(cdpData.fundsReceiver, daiLeft);
    }
    if (otherTokenLeft > 0) {
      otherToken.transfer(cdpData.fundsReceiver, otherTokenLeft);
    }
  }

  function onFlashLoan(
    address initiator,
    address token,
    uint256 amount,
    uint256 fee,
    bytes calldata params
  ) public override returns (bytes32) {

    (
      uint256 mode,
      ExchangeData memory exchangeData,
      CdpData memory cdpData,
      GuniAddressRegistry memory guniAddressRegistry
    ) = abi.decode(params, (uint256, ExchangeData, CdpData, GuniAddressRegistry));

    require(msg.sender == address(guniAddressRegistry.lender), "mpa-untrusted-lender");
    uint256 borrowedDaiAmount;
    {
      borrowedDaiAmount = amount.add(fee);
    }
    emit FLData(IERC20(DAI).balanceOf(address(this)).sub(cdpData.token0Amount), borrowedDaiAmount);

    require(
      cdpData.requiredDebt.add(cdpData.token0Amount) <= IERC20(DAI).balanceOf(address(this)),
      "mpa-receive-requested-amount-mismatch"
    );

    if (mode == 1) {
      _increaseMPGuni(exchangeData, cdpData, guniAddressRegistry, borrowedDaiAmount);
    }
    if (mode == 0) {
      _closeToDaiMPGuni(exchangeData, cdpData, guniAddressRegistry, borrowedDaiAmount);
    }

    IERC20(token).approve(guniAddressRegistry.lender, borrowedDaiAmount);

    return keccak256("ERC3156FlashBorrower.onFlashLoan");
  }

  function getOtherTokenAmount(
    IGUNIToken guni,
    IGUNIResolver resolver,
    uint256 bal0,
    uint256 otherTokenDecimals
  ) public view returns (uint256 amount) {

    (uint256 sqrtPriceX96, , , , , , ) = IUniPool(guni.pool()).slot0();

    uint256 otherTokenTo18Conv = 10**(18 - otherTokenDecimals);

    (, amount) = resolver.getRebalanceParams(
      address(guni),
      guni.token0() == DAI ? bal0 : 0,
      guni.token1() == DAI ? bal0 : 0,
      ((((sqrtPriceX96 * sqrtPriceX96) >> 96) * 1e18) >> 96) * otherTokenTo18Conv
    );
  }

  function getInk(address manager, CdpData memory cdpData) internal view returns (uint256) {

    address urn = IManager(manager).urns(cdpData.cdpId);
    address vat = IManager(manager).vat();

    (uint256 ink, ) = IVat(vat).urns(cdpData.ilk, urn);
    return ink;
  }

  function wipeAndFreeGem(
    address manager,
    address gemJoin,
    uint256 cdp,
    uint256 borrowedDai,
    uint256 collateralDraw
  ) internal {

    address vat = IManager(manager).vat();
    address urn = IManager(manager).urns(cdp);
    bytes32 ilk = IManager(manager).ilks(cdp);

    IERC20(DAI).approve(DAIJOIN, borrowedDai);
    IDaiJoin(DAIJOIN).join(urn, borrowedDai);

    uint256 wadC = convertTo18(gemJoin, collateralDraw);

    IManager(manager).frob(cdp, -toInt256(wadC), _getWipeDart(vat, IVat(vat).dai(urn), urn, ilk));

    IManager(manager).flux(cdp, address(this), wadC);
    IJoin(gemJoin).exit(address(this), collateralDraw);
  }

  function convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {

    wad = amt.mul(10**(18 - IJoin(gemJoin).dec()));
  }

  function _getWipeDart(
    address vat,
    uint256 dai,
    address urn,
    bytes32 ilk
  ) internal view returns (int256 dart) {

    (, uint256 rate, , , ) = IVat(vat).ilks(ilk);
    (, uint256 art) = IVat(vat).urns(ilk, urn);

    dart = toInt256(dai / rate);
    dart = uint256(dart) <= art ? -dart : -toInt256(art);
  }

  function joinDrawDebt(
    CdpData memory cdpData,
    uint256 borrowedDai,
    address manager,
    address jug
  ) private {

    IGem gem = IJoin(cdpData.gemJoin).gem();

    uint256 balance = IERC20(address(gem)).balanceOf(address(this));
    gem.approve(address(cdpData.gemJoin), balance);

    address urn = IManager(manager).urns(cdpData.cdpId);
    address vat = IManager(manager).vat();

    IJoin(cdpData.gemJoin).join(urn, balance);

    IManager(manager).frob(
      cdpData.cdpId,
      toInt256(convertTo18(cdpData.gemJoin, balance)),
      _getDrawDart(vat, jug, urn, cdpData.ilk, borrowedDai)
    );
    IManager(manager).move(cdpData.cdpId, address(this), borrowedDai.mul(RAY));

    IVat(vat).hope(DAIJOIN);

    IJoin(DAIJOIN).exit(address(this), borrowedDai);
  }

  function _getDrawDart(
    address vat,
    address jug,
    address urn,
    bytes32 ilk,
    uint256 wad
  ) internal returns (int256 dart) {

    uint256 rate = IJug(jug).drip(ilk);

    uint256 dai = IVat(vat).dai(urn);

    if (dai < wad.mul(RAY)) {
      dart = toInt256(wad.mul(RAY).sub(dai) / rate);
      dart = uint256(dart).mul(rate) < wad.mul(RAY) ? dart + 1 : dart;
    }
  }

  function toRad(uint256 wad) internal pure returns (uint256 rad) {

    rad = wad.mul(10**27);
  }

  function toInt256(uint256 x) internal pure returns (int256 y) {

    y = int256(x);
    require(y >= 0, "int256-overflow");
  }

  function _getWipeAllWad(
    address vat,
    address usr,
    address urn,
    bytes32 ilk
  ) internal view returns (uint256 wad) {

    (, uint256 rate, , , ) = IVat(vat).ilks(ilk);
    (, uint256 art) = IVat(vat).urns(ilk, urn);
    uint256 dai = IVat(vat).dai(usr);

    uint256 rad = art.mul(rate).sub(dai);
    wad = rad / RAY;

    wad = wad.mul(RAY) < rad ? wad + 1 : wad;
  }

  event FLData(uint256 borrowed, uint256 due);
  event MultipleActionCalled(
    string methodName,
    uint256 indexed cdpId,
    uint256 swapMinAmount,
    uint256 swapOptimistAmount,
    uint256 collateralLeft,
    uint256 daiLeft
  );
}