



pragma solidity 0.6.7;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

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

interface DSAuthority {

    function canCall(
        address src, address dst, bytes4 sig
    ) external view returns (bool);

}

abstract contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {

    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        virtual
        public
        auth
    {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        virtual
        public
        auth
    {

        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) virtual internal view returns (bool) {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

abstract contract CollateralLike {
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public;
    function transferFrom(address, address, uint) virtual public;
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
}

abstract contract ManagerLike {
    function safeCan(address, uint, address) virtual public view returns (uint);
    function collateralTypes(uint) virtual public view returns (bytes32);
    function ownsSAFE(uint) virtual public view returns (address);
    function safes(uint) virtual public view returns (address);
    function safeEngine() virtual public view returns (address);
    function openSAFE(bytes32, address) virtual public returns (uint);
    function transferSAFEOwnership(uint, address) virtual public;
    function allowSAFE(uint, address, uint) virtual public;
    function allowHandler(address, uint) virtual public;
    function modifySAFECollateralization(uint, int, int) virtual public;
    function transferCollateral(uint, address, uint) virtual public;
    function transferInternalCoins(uint, address, uint) virtual public;
    function quitSystem(uint, address) virtual public;
    function enterSystem(address, uint) virtual public;
    function moveSAFE(uint, uint) virtual public;
    function protectSAFE(uint, address, address) virtual public;
}

abstract contract SAFEEngineLike {
    function canModifySAFE(address, address) virtual public view returns (uint);
    function collateralTypes(bytes32) virtual public view returns (uint, uint, uint, uint, uint);
    function coinBalance(address) virtual public view returns (uint);
    function safes(bytes32, address) virtual public view returns (uint, uint);
    function modifySAFECollateralization(bytes32, address, address, address, int, int) virtual public;
    function approveSAFEModification(address) virtual public;
    function transferInternalCoins(address, address, uint) virtual public;
}

abstract contract CollateralJoinLike {
    function decimals() virtual public returns (uint);
    function collateral() virtual public returns (CollateralLike);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract GNTJoinLike {
    function bags(address) virtual public view returns (address);
    function make(address) virtual public returns (address);
}

abstract contract DSTokenLike {
    function balanceOf(address) virtual public view returns (uint);
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public returns (bool);
    function transferFrom(address, address, uint) virtual public returns (bool);
}

abstract contract WethLike {
    function balanceOf(address) virtual public view returns (uint);
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public;
    function transferFrom(address, address, uint) virtual public;
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
}

abstract contract CoinJoinLike {
    function safeEngine() virtual public returns (SAFEEngineLike);
    function systemCoin() virtual public returns (DSTokenLike);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract ApproveSAFEModificationLike {
    function approveSAFEModification(address) virtual public;
    function denySAFEModification(address) virtual public;
}

abstract contract GlobalSettlementLike {
    function collateralCashPrice(bytes32) virtual public view returns (uint);
    function redeemCollateral(bytes32, uint) virtual public;
    function freeCollateral(bytes32) virtual public;
    function prepareCoinsForRedeeming(uint) virtual public;
    function processSAFE(bytes32, address) virtual public;
}

abstract contract TaxCollectorLike {
    function taxSingle(bytes32) virtual public returns (uint);
}

abstract contract CoinSavingsAccountLike {
    function savings(address) virtual public view returns (uint);
    function updateAccumulatedRate() virtual public returns (uint);
    function deposit(uint) virtual public;
    function withdraw(uint) virtual public;
}

abstract contract ProxyRegistryLike {
    function proxies(address) virtual public view returns (address);
    function build(address) virtual public returns (address);
}

abstract contract ProxyLike {
    function owner() virtual public view returns (address);
}


contract Common {

    uint256 constant RAY = 10 ** 27;

    function multiply(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function _coinJoin_join(address apt, address safeHandler, uint wad) internal {

        CoinJoinLike(apt).systemCoin().approve(apt, wad);
        CoinJoinLike(apt).join(safeHandler, wad);
    }

    function coinJoin_join(address apt, address safeHandler, uint wad) public {

        CoinJoinLike(apt).systemCoin().transferFrom(msg.sender, address(this), wad);

        _coinJoin_join(apt, safeHandler, wad);
    }
}

contract BasicActions is Common {


    function subtract(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "sub-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {

        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {

        rad = multiply(wad, 10 ** 27);
    }

    function convertTo18(address collateralJoin, uint256 amt) internal returns (uint256 wad) {

        uint decimals = CollateralJoinLike(collateralJoin).decimals();
        wad = amt;
        if (decimals < 18) {
          wad = multiply(
              amt,
              10 ** (18 - decimals)
          );
        } else if (decimals > 18) {
          wad = amt / 10 ** (decimals - 18);
        }
    }

    function _getGeneratedDeltaDebt(
        address safeEngine,
        address taxCollector,
        address safeHandler,
        bytes32 collateralType,
        uint wad
    ) internal returns (int deltaDebt) {

        uint rate = TaxCollectorLike(taxCollector).taxSingle(collateralType);
        require(rate > 0, "invalid-collateral-type");

        uint coin = SAFEEngineLike(safeEngine).coinBalance(safeHandler);

        if (coin < multiply(wad, RAY)) {
            deltaDebt = toInt(subtract(multiply(wad, RAY), coin) / rate);
            deltaDebt = multiply(uint(deltaDebt), rate) < multiply(wad, RAY) ? deltaDebt + 1 : deltaDebt;
        }
    }

    function _getRepaidDeltaDebt(
        address safeEngine,
        uint coin,
        address safe,
        bytes32 collateralType
    ) internal view returns (int deltaDebt) {

        (, uint rate,,,) = SAFEEngineLike(safeEngine).collateralTypes(collateralType);
        require(rate > 0, "invalid-collateral-type");

        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safe);

        deltaDebt = toInt(coin / rate);
        deltaDebt = uint(deltaDebt) <= generatedDebt ? - deltaDebt : - toInt(generatedDebt);
    }

    function _getRepaidAlDebt(
        address safeEngine,
        address usr,
        address safe,
        bytes32 collateralType
    ) internal view returns (uint wad) {

        (, uint rate,,,) = SAFEEngineLike(safeEngine).collateralTypes(collateralType);
        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safe);
        uint coin = SAFEEngineLike(safeEngine).coinBalance(usr);

        uint rad = subtract(multiply(generatedDebt, rate), coin);
        wad = rad / RAY;

        wad = multiply(wad, RAY) < rad ? wad + 1 : wad;
    }

    function _generateDebt(address manager, address taxCollector, address coinJoin, uint safe, uint wad, address to) internal {

        address safeHandler = ManagerLike(manager).safes(safe);
        address safeEngine = ManagerLike(manager).safeEngine();
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);
        modifySAFECollateralization(manager, safe, 0, _getGeneratedDeltaDebt(safeEngine, taxCollector, safeHandler, collateralType, wad));
        transferInternalCoins(manager, safe, address(this), toRad(wad));
        if (SAFEEngineLike(safeEngine).canModifySAFE(address(this), address(coinJoin)) == 0) {
            SAFEEngineLike(safeEngine).approveSAFEModification(coinJoin);
        }
        CoinJoinLike(coinJoin).exit(to, wad);
    }

    function _lockETH(
        address manager,
        address ethJoin,
        uint safe,
        uint value
    ) internal {

        ethJoin_join(ethJoin, address(this), value);
        SAFEEngineLike(ManagerLike(manager).safeEngine()).modifySAFECollateralization(
            ManagerLike(manager).collateralTypes(safe),
            ManagerLike(manager).safes(safe),
            address(this),
            address(this),
            toInt(value),
            0
        );
    }

    function _repayDebt(
        address manager,
        address coinJoin,
        uint safe,
        uint wad,
        bool transferFromCaller
    ) internal {

        address safeEngine = ManagerLike(manager).safeEngine();
        address safeHandler = ManagerLike(manager).safes(safe);
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);

        address own = ManagerLike(manager).ownsSAFE(safe);
        if (own == address(this) || ManagerLike(manager).safeCan(own, safe, address(this)) == 1) {
            if (transferFromCaller) coinJoin_join(coinJoin, safeHandler, wad);
            else _coinJoin_join(coinJoin, safeHandler, wad);
            modifySAFECollateralization(manager, safe, 0, _getRepaidDeltaDebt(safeEngine, SAFEEngineLike(safeEngine).coinBalance(safeHandler), safeHandler, collateralType));
        } else {
            if (transferFromCaller) coinJoin_join(coinJoin, address(this), wad);
            else _coinJoin_join(coinJoin, address(this), wad);
            SAFEEngineLike(safeEngine).modifySAFECollateralization(
                collateralType,
                safeHandler,
                address(this),
                address(this),
                0,
                _getRepaidDeltaDebt(safeEngine, wad * RAY, safeHandler, collateralType)
            );
        }
    }

    function _repayDebtAndFreeETH(
        address manager,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint collateralWad,
        uint deltaWad,
        bool transferFromCaller
    ) internal {

        address safeHandler = ManagerLike(manager).safes(safe);
        if (transferFromCaller) coinJoin_join(coinJoin, safeHandler, deltaWad);
        else _coinJoin_join(coinJoin, safeHandler, deltaWad);
        modifySAFECollateralization(
            manager,
            safe,
            -toInt(collateralWad),
            _getRepaidDeltaDebt(ManagerLike(manager).safeEngine(), SAFEEngineLike(ManagerLike(manager).safeEngine()).coinBalance(safeHandler), safeHandler, ManagerLike(manager).collateralTypes(safe))
        );
        transferCollateral(manager, safe, address(this), collateralWad);
        CollateralJoinLike(ethJoin).exit(address(this), collateralWad);
        CollateralJoinLike(ethJoin).collateral().withdraw(collateralWad);
    }


    function transfer(address collateral, address dst, uint amt) external {

        CollateralLike(collateral).transfer(dst, amt);
    }

    function ethJoin_join(address apt, address safe) external payable {

        ethJoin_join(apt, safe, msg.value);
    }

    function ethJoin_join(address apt, address safe, uint value) public payable {

        CollateralJoinLike(apt).collateral().deposit{value: value}();
        CollateralJoinLike(apt).collateral().approve(address(apt), value);
        CollateralJoinLike(apt).join(safe, value);
    }

    function approveSAFEModification(
        address safeEngine,
        address usr
    ) external {

        ApproveSAFEModificationLike(safeEngine).approveSAFEModification(usr);
    }

    function denySAFEModification(
        address safeEngine,
        address usr
    ) external {

        ApproveSAFEModificationLike(safeEngine).denySAFEModification(usr);
    }

    function openSAFE(
        address manager,
        bytes32 collateralType,
        address usr
    ) public returns (uint safe) {

        safe = ManagerLike(manager).openSAFE(collateralType, usr);
    }

    function transferSAFEOwnership(
        address manager,
        uint safe,
        address usr
    ) public {

        ManagerLike(manager).transferSAFEOwnership(safe, usr);
    }

    function transferSAFEOwnershipToProxy(
        address proxyRegistry,
        address manager,
        uint safe,
        address dst
    ) external {

        address proxy = ProxyRegistryLike(proxyRegistry).proxies(dst);
        if (proxy == address(0) || ProxyLike(proxy).owner() != dst) {
            uint csize;
            assembly {
                csize := extcodesize(dst)
            }
            require(csize == 0, "dst-is-a-contract");
            proxy = ProxyRegistryLike(proxyRegistry).build(dst);
        }
        transferSAFEOwnership(manager, safe, proxy);
    }

    function allowSAFE(
        address manager,
        uint safe,
        address usr,
        uint ok
    ) external {

        ManagerLike(manager).allowSAFE(safe, usr, ok);
    }

    function allowHandler(
        address manager,
        address usr,
        uint ok
    ) external {

        ManagerLike(manager).allowHandler(usr, ok);
    }

    function transferCollateral(
        address manager,
        uint safe,
        address dst,
        uint wad
    ) public {

        ManagerLike(manager).transferCollateral(safe, dst, wad);
    }

    function transferInternalCoins(
        address manager,
        uint safe,
        address dst,
        uint rad
    ) public {

        ManagerLike(manager).transferInternalCoins(safe, dst, rad);
    }


    function modifySAFECollateralization(
        address manager,
        uint safe,
        int deltaCollateral,
        int deltaDebt
    ) public {

        ManagerLike(manager).modifySAFECollateralization(safe, deltaCollateral, deltaDebt);
    }

    function quitSystem(
        address manager,
        uint safe,
        address dst
    ) external {

        ManagerLike(manager).quitSystem(safe, dst);
    }

    function enterSystem(
        address manager,
        address src,
        uint safe
    ) external {

        ManagerLike(manager).enterSystem(src, safe);
    }

    function moveSAFE(
        address manager,
        uint safeSrc,
        uint safeDst
    ) external {

        ManagerLike(manager).moveSAFE(safeSrc, safeDst);
    }

    function lockETH(
        address manager,
        address ethJoin,
        uint safe
    ) public payable {

        _lockETH(manager, ethJoin, safe, msg.value);
    }

    function freeETH(
        address manager,
        address ethJoin,
        uint safe,
        uint wad
    ) public {

        modifySAFECollateralization(manager, safe, -toInt(wad), 0);
        transferCollateral(manager, safe, address(this), wad);
        CollateralJoinLike(ethJoin).exit(address(this), wad);
        CollateralJoinLike(ethJoin).collateral().withdraw(wad);
        msg.sender.transfer(wad);
    }


    function exitETH(
        address manager,
        address ethJoin,
        uint safe,
        uint wad
    ) external {

        transferCollateral(manager, safe, address(this), wad);
        CollateralJoinLike(ethJoin).exit(address(this), wad);
        CollateralJoinLike(ethJoin).collateral().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function generateDebt(
        address manager,
        address taxCollector,
        address coinJoin,
        uint safe,
        uint wad
    ) public {

        _generateDebt(manager, taxCollector, coinJoin, safe, wad, msg.sender);
    }

    function repayDebt(
        address manager,
        address coinJoin,
        uint safe,
        uint wad
    ) public {

        _repayDebt(manager, coinJoin, safe, wad, true);
    }

    function lockETHAndGenerateDebt(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint deltaWad
    ) public payable {

        _lockETH(manager, ethJoin, safe, msg.value);
        _generateDebt(manager, taxCollector, coinJoin, safe, deltaWad, msg.sender);
    }

    function openLockETHAndGenerateDebt(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        bytes32 collateralType,
        uint deltaWad
    ) external payable returns (uint safe) {

        safe = openSAFE(manager, collateralType, address(this));
        lockETHAndGenerateDebt(manager, taxCollector, ethJoin, coinJoin, safe, deltaWad);
    }

    function repayDebtAndFreeETH(
        address manager,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint collateralWad,
        uint deltaWad
    ) external {

        _repayDebtAndFreeETH(manager, ethJoin, coinJoin, safe, collateralWad, deltaWad, true);
        msg.sender.transfer(collateralWad);
    }    
}

contract GebProxyActions is BasicActions {


    function tokenCollateralJoin_join(address apt, address safe, uint amt, bool transferFrom) public {

        if (transferFrom) {
            CollateralJoinLike(apt).collateral().transferFrom(msg.sender, address(this), amt);
            CollateralJoinLike(apt).collateral().approve(apt, amt);
        }
        CollateralJoinLike(apt).join(safe, amt);
    }

    function protectSAFE(
        address manager,
        uint safe,
        address liquidationEngine,
        address saviour
    ) public {

        ManagerLike(manager).protectSAFE(safe, liquidationEngine, saviour);
    }

    function makeCollateralBag(
        address collateralJoin
    ) public returns (address bag) {

        bag = GNTJoinLike(collateralJoin).make(address(this));
    }

    function safeLockETH(
        address manager,
        address ethJoin,
        uint safe,
        address owner
    ) public payable {

        require(ManagerLike(manager).ownsSAFE(safe) == owner, "owner-missmatch");
        lockETH(manager, ethJoin, safe);
    }

    function lockTokenCollateral(
        address manager,
        address collateralJoin,
        uint safe,
        uint amt,
        bool transferFrom
    ) public {

        tokenCollateralJoin_join(collateralJoin, address(this), amt, transferFrom);
        SAFEEngineLike(ManagerLike(manager).safeEngine()).modifySAFECollateralization(
            ManagerLike(manager).collateralTypes(safe),
            ManagerLike(manager).safes(safe),
            address(this),
            address(this),
            toInt(convertTo18(collateralJoin, amt)),
            0
        );
    }

    function safeLockTokenCollateral(
        address manager,
        address collateralJoin,
        uint safe,
        uint amt,
        bool transferFrom,
        address owner
    ) public {

        require(ManagerLike(manager).ownsSAFE(safe) == owner, "owner-missmatch");
        lockTokenCollateral(manager, collateralJoin, safe, amt, transferFrom);
    }

    function freeTokenCollateral(
        address manager,
        address collateralJoin,
        uint safe,
        uint amt
    ) public {

        uint wad = convertTo18(collateralJoin, amt);
        modifySAFECollateralization(manager, safe, -toInt(wad), 0);
        transferCollateral(manager, safe, address(this), wad);
        CollateralJoinLike(collateralJoin).exit(msg.sender, amt);
    }

    function exitTokenCollateral(
        address manager,
        address collateralJoin,
        uint safe,
        uint amt
    ) public {

        transferCollateral(manager, safe, address(this), convertTo18(collateralJoin, amt));

        CollateralJoinLike(collateralJoin).exit(msg.sender, amt);
    }

    function generateDebtAndProtectSAFE(
        address manager,
        address taxCollector,
        address coinJoin,
        uint safe,
        uint wad,
        address liquidationEngine,
        address saviour
    ) external {

        generateDebt(manager, taxCollector, coinJoin, safe, wad);
        protectSAFE(manager, safe, liquidationEngine, saviour);
    }

    function safeRepayDebt(
        address manager,
        address coinJoin,
        uint safe,
        uint wad,
        address owner
    ) public {

        require(ManagerLike(manager).ownsSAFE(safe) == owner, "owner-missmatch");
        repayDebt(manager, coinJoin, safe, wad);
    }

    function repayAllDebt(
        address manager,
        address coinJoin,
        uint safe
    ) public {

        address safeEngine = ManagerLike(manager).safeEngine();
        address safeHandler = ManagerLike(manager).safes(safe);
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);
        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safeHandler);

        address own = ManagerLike(manager).ownsSAFE(safe);
        if (own == address(this) || ManagerLike(manager).safeCan(own, safe, address(this)) == 1) {
            coinJoin_join(coinJoin, safeHandler, _getRepaidAlDebt(safeEngine, safeHandler, safeHandler, collateralType));
            modifySAFECollateralization(manager, safe, 0, -int(generatedDebt));
        } else {
            coinJoin_join(coinJoin, address(this), _getRepaidAlDebt(safeEngine, address(this), safeHandler, collateralType));
            SAFEEngineLike(safeEngine).modifySAFECollateralization(
                collateralType,
                safeHandler,
                address(this),
                address(this),
                0,
                -int(generatedDebt)
            );
        }
    }

    function safeRepayAllDebt(
        address manager,
        address coinJoin,
        uint safe,
        address owner
    ) public {

        require(ManagerLike(manager).ownsSAFE(safe) == owner, "owner-missmatch");
        repayAllDebt(manager, coinJoin, safe);
    }

    function openLockETHGenerateDebtAndProtectSAFE(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        bytes32 collateralType,
        uint deltaWad,
        address liquidationEngine,
        address saviour
    ) public payable returns (uint safe) {

        safe = openSAFE(manager, collateralType, address(this));
        lockETHAndGenerateDebt(manager, taxCollector, ethJoin, coinJoin, safe, deltaWad);
        protectSAFE(manager, safe, liquidationEngine, saviour);
    }

    function lockTokenCollateralAndGenerateDebt(
        address manager,
        address taxCollector,
        address collateralJoin,
        address coinJoin,
        uint safe,
        uint collateralAmount,
        uint deltaWad,
        bool transferFrom
    ) public {

        address safeHandler = ManagerLike(manager).safes(safe);
        address safeEngine = ManagerLike(manager).safeEngine();
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);
        tokenCollateralJoin_join(collateralJoin, safeHandler, collateralAmount, transferFrom);
        modifySAFECollateralization(manager, safe, toInt(convertTo18(collateralJoin, collateralAmount)), _getGeneratedDeltaDebt(safeEngine, taxCollector, safeHandler, collateralType, deltaWad));
        transferInternalCoins(manager, safe, address(this), toRad(deltaWad));
        if (SAFEEngineLike(safeEngine).canModifySAFE(address(this), address(coinJoin)) == 0) {
            SAFEEngineLike(safeEngine).approveSAFEModification(coinJoin);
        }
        CoinJoinLike(coinJoin).exit(msg.sender, deltaWad);
    }

    function lockTokenCollateralGenerateDebtAndProtectSAFE(
        address manager,
        address taxCollector,
        address collateralJoin,
        address coinJoin,
        uint safe,
        uint collateralAmount,
        uint deltaWad,
        bool transferFrom,
        address liquidationEngine,
        address saviour
    ) public {

        lockTokenCollateralAndGenerateDebt(
          manager,
          taxCollector,
          collateralJoin,
          coinJoin,
          safe,
          collateralAmount,
          deltaWad,
          transferFrom
        );
        protectSAFE(manager, safe, liquidationEngine, saviour);
    }

    function openLockTokenCollateralAndGenerateDebt(
        address manager,
        address taxCollector,
        address collateralJoin,
        address coinJoin,
        bytes32 collateralType,
        uint collateralAmount,
        uint deltaWad,
        bool transferFrom
    ) public returns (uint safe) {

        safe = openSAFE(manager, collateralType, address(this));
        lockTokenCollateralAndGenerateDebt(manager, taxCollector, collateralJoin, coinJoin, safe, collateralAmount, deltaWad, transferFrom);
    }

    function openLockTokenCollateralGenerateDebtAndProtectSAFE(
        address manager,
        address taxCollector,
        address collateralJoin,
        address coinJoin,
        bytes32 collateralType,
        uint collateralAmount,
        uint deltaWad,
        bool transferFrom,
        address liquidationEngine,
        address saviour
    ) public returns (uint safe) {

        safe = openSAFE(manager, collateralType, address(this));
        lockTokenCollateralAndGenerateDebt(manager, taxCollector, collateralJoin, coinJoin, safe, collateralAmount, deltaWad, transferFrom);
        protectSAFE(manager, safe, liquidationEngine, saviour);
    }

    function openLockGNTAndGenerateDebt(
        address manager,
        address taxCollector,
        address gntJoin,
        address coinJoin,
        bytes32 collateralType,
        uint collateralAmount,
        uint deltaWad
    ) public returns (address bag, uint safe) {

        bag = GNTJoinLike(gntJoin).bags(address(this));
        if (bag == address(0)) {
            bag = makeCollateralBag(gntJoin);
        }
        CollateralLike(CollateralJoinLike(gntJoin).collateral()).transfer(bag, collateralAmount);
        safe = openLockTokenCollateralAndGenerateDebt(manager, taxCollector, gntJoin, coinJoin, collateralType, collateralAmount, deltaWad, false);
    }

    function openLockGNTGenerateDebtAndProtectSAFE(
        address manager,
        address taxCollector,
        address gntJoin,
        address coinJoin,
        bytes32 collateralType,
        uint collateralAmount,
        uint deltaWad,
        address liquidationEngine,
        address saviour
    ) public returns (address bag, uint safe) {

        (bag, safe) = openLockGNTAndGenerateDebt(
          manager,
          taxCollector,
          gntJoin,
          coinJoin,
          collateralType,
          collateralAmount,
          deltaWad
        );
        protectSAFE(manager, safe, liquidationEngine, saviour);
    }

    function repayAllDebtAndFreeETH(
        address manager,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint collateralWad
    ) public {

        address safeEngine = ManagerLike(manager).safeEngine();
        address safeHandler = ManagerLike(manager).safes(safe);
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);
        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safeHandler);

        coinJoin_join(coinJoin, safeHandler, _getRepaidAlDebt(safeEngine, safeHandler, safeHandler, collateralType));
        modifySAFECollateralization(
            manager,
            safe,
            -toInt(collateralWad),
            -int(generatedDebt)
        );
        transferCollateral(manager, safe, address(this), collateralWad);
        CollateralJoinLike(ethJoin).exit(address(this), collateralWad);
        CollateralJoinLike(ethJoin).collateral().withdraw(collateralWad);
        msg.sender.transfer(collateralWad);
    }

    function repayDebtAndFreeTokenCollateral(
        address manager,
        address collateralJoin,
        address coinJoin,
        uint safe,
        uint collateralAmount,
        uint deltaWad
    ) external {

        address safeHandler = ManagerLike(manager).safes(safe);
        coinJoin_join(coinJoin, safeHandler, deltaWad);
        uint collateralWad = convertTo18(collateralJoin, collateralAmount);
        modifySAFECollateralization(
            manager,
            safe,
            -toInt(collateralWad),
            _getRepaidDeltaDebt(ManagerLike(manager).safeEngine(), SAFEEngineLike(ManagerLike(manager).safeEngine()).coinBalance(safeHandler), safeHandler, ManagerLike(manager).collateralTypes(safe))
        );
        transferCollateral(manager, safe, address(this), collateralWad);
        CollateralJoinLike(collateralJoin).exit(msg.sender, collateralAmount);
    }

    function repayAllDebtAndFreeTokenCollateral(
        address manager,
        address collateralJoin,
        address coinJoin,
        uint safe,
        uint collateralAmount
    ) public {

        address safeEngine = ManagerLike(manager).safeEngine();
        address safeHandler = ManagerLike(manager).safes(safe);
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);
        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safeHandler);

        coinJoin_join(coinJoin, safeHandler, _getRepaidAlDebt(safeEngine, safeHandler, safeHandler, collateralType));
        uint collateralWad = convertTo18(collateralJoin, collateralAmount);
        modifySAFECollateralization(
            manager,
            safe,
            -toInt(collateralWad),
            -int(generatedDebt)
        );
        transferCollateral(manager, safe, address(this), collateralWad);
        CollateralJoinLike(collateralJoin).exit(msg.sender, collateralAmount);
    }
}

abstract contract GebIncentivesLike {
    function stakingToken() virtual public returns (address);
    function rewardsToken() virtual public returns (address);
    function stake(uint256) virtual public;
    function withdraw(uint256) virtual public;
    function exit() virtual public;
    function balanceOf(address) virtual public view returns (uint256);
    function getReward() virtual public;
}


contract GebProxyIncentivesActions is BasicActions {


    function _provideLiquidityUniswap(address coinJoin, address uniswapRouter, uint tokenWad, uint ethWad, address to, uint[2] memory minTokenAmounts) internal {

        CoinJoinLike(coinJoin).systemCoin().approve(uniswapRouter, tokenWad);
        IUniswapV2Router02(uniswapRouter).addLiquidityETH{value: ethWad}(
            address(CoinJoinLike(coinJoin).systemCoin()),
            tokenWad,
            minTokenAmounts[0],
            minTokenAmounts[1],
            to,
            block.timestamp
        );
    }

    function _stakeInMine(address incentives) internal {

        DSTokenLike lpToken = DSTokenLike(GebIncentivesLike(incentives).stakingToken());
        lpToken.approve(incentives, uint(0 - 1));
        GebIncentivesLike(incentives).stake(lpToken.balanceOf(address(this)));
    }

    function _removeLiquidityUniswap(address uniswapRouter, address systemCoin, uint value, address to, uint[2] memory minTokenAmounts) internal returns (uint amountA, uint amountB) {

        DSTokenLike(getWethPair(uniswapRouter, systemCoin)).approve(uniswapRouter, value);
        return IUniswapV2Router02(uniswapRouter).removeLiquidityETH(
            systemCoin,
            value,
            minTokenAmounts[0],
            minTokenAmounts[1],
            to,
            block.timestamp
        );
    }

    function openLockETHGenerateDebtProvideLiquidityUniswap(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        address uniswapRouter,
        bytes32 collateralType,
        uint deltaWad,
        uint liquidityWad,
        uint[2] calldata minTokenAmounts
    ) external payable returns (uint safe) {

        safe = openSAFE(manager, collateralType, address(this));
        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());

        _lockETH(manager, ethJoin, safe, subtract(msg.value, liquidityWad));

        _generateDebt(manager, taxCollector, coinJoin, safe, deltaWad, address(this));

        _provideLiquidityUniswap(coinJoin, uniswapRouter, deltaWad, liquidityWad, msg.sender, minTokenAmounts);

        msg.sender.call{value: address(this).balance}("");
        systemCoin.transfer(msg.sender, systemCoin.balanceOf(address(this)));
    }

    function lockETHGenerateDebtProvideLiquidityUniswap(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        address uniswapRouter,
        uint safe,
        uint deltaWad,
        uint liquidityWad,
        uint[2] calldata minTokenAmounts
    ) external payable {

        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());

        _lockETH(manager, ethJoin, safe, subtract(msg.value, liquidityWad));

        _generateDebt(manager, taxCollector, coinJoin, safe, deltaWad, address(this));

        _provideLiquidityUniswap(coinJoin, uniswapRouter, deltaWad, liquidityWad, msg.sender, minTokenAmounts);

        msg.sender.call{value: address(this).balance}("");
        systemCoin.transfer(msg.sender, systemCoin.balanceOf(address(this)));
    }

    function openLockETHGenerateDebtProvideLiquidityStake(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        address uniswapRouter,
        address incentives,
        bytes32 collateralType,
        uint256 deltaWad,
        uint256 liquidityWad,
        uint256[2] calldata minTokenAmounts
    ) external payable returns (uint safe) {

        safe = openSAFE(manager, collateralType, address(this));
        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());

        _lockETH(manager, ethJoin, safe, subtract(msg.value, liquidityWad));

        _generateDebt(manager, taxCollector, coinJoin, safe, deltaWad, address(this));

        _provideLiquidityUniswap(coinJoin, uniswapRouter, deltaWad, liquidityWad, address(this), minTokenAmounts);

        _stakeInMine(incentives);

        msg.sender.call{value: address(this).balance}("");
        systemCoin.transfer(msg.sender, systemCoin.balanceOf(address(this)));
    }

    function lockETHGenerateDebtProvideLiquidityStake(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        address uniswapRouter,
        address incentives,
        uint safe,
        uint deltaWad,
        uint liquidityWad,
        uint[2] memory minTokenAmounts
    ) public payable {

        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());

        _lockETH(manager, ethJoin, safe, subtract(msg.value, liquidityWad));

        _generateDebt(manager, taxCollector, coinJoin, safe, deltaWad, address(this));

        _provideLiquidityUniswap(coinJoin, uniswapRouter, deltaWad, liquidityWad, address(this), minTokenAmounts);

        _stakeInMine(incentives);

        msg.sender.call{value: address(this).balance}("");
        systemCoin.transfer(msg.sender, systemCoin.balanceOf(address(this)));
    }

    function provideLiquidityUniswap(address coinJoin, address uniswapRouter, uint wad, uint[2] calldata minTokenAmounts) external payable {

        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());
        systemCoin.transferFrom(msg.sender, address(this), wad);
        _provideLiquidityUniswap(coinJoin, uniswapRouter, wad, msg.value, msg.sender, minTokenAmounts);

        msg.sender.call{value: address(this).balance}("");
        systemCoin.transfer(msg.sender, systemCoin.balanceOf(address(this)));
    }

    function provideLiquidityStake(
        address coinJoin,
        address uniswapRouter,
        address incentives,
        uint wad,
        uint[2] memory minTokenAmounts
    ) public payable {

        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());
        systemCoin.transferFrom(msg.sender, address(this), wad);
        _provideLiquidityUniswap(coinJoin, uniswapRouter, wad, msg.value, address(this), minTokenAmounts);

        _stakeInMine(incentives);

        msg.sender.call{value: address(this).balance}("");
        systemCoin.transfer(msg.sender, systemCoin.balanceOf(address(this)));
    }

    function generateDebtAndProvideLiquidityUniswap(
        address manager,
        address taxCollector,
        address coinJoin,
        address uniswapRouter,
        uint safe,
        uint wad,
        uint[2] calldata minTokenAmounts
    ) external payable {

        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());
        _generateDebt(manager, taxCollector, coinJoin, safe, wad, address(this));

        _provideLiquidityUniswap(coinJoin, uniswapRouter, wad, msg.value, msg.sender, minTokenAmounts);

        msg.sender.call{value: address(this).balance}("");
        systemCoin.transfer(msg.sender, systemCoin.balanceOf(address(this)));
    }

    function stakeInMine(address incentives, uint wad) external {

        DSTokenLike(GebIncentivesLike(incentives).stakingToken()).transferFrom(msg.sender, address(this), wad);
        _stakeInMine(incentives);
    }

    function generateDebtAndProvideLiquidityStake(
        address manager,
        address taxCollector,
        address coinJoin,
        address uniswapRouter,
        address incentives,
        uint safe,
        uint wad,
        uint[2] calldata minTokenAmounts
    ) external payable {

        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());
        _generateDebt(manager, taxCollector, coinJoin, safe, wad, address(this));
        _provideLiquidityUniswap(coinJoin, uniswapRouter, wad, msg.value, address(this), minTokenAmounts);
        _stakeInMine(incentives);

        msg.sender.call{value: address(this).balance}("");
        systemCoin.transfer(msg.sender, systemCoin.balanceOf(address(this)));
    }

    function getRewards(address incentives) public {

        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        DSTokenLike rewardToken = DSTokenLike(incentivesContract.rewardsToken());
        incentivesContract.getReward();
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function exitMine(address incentives) external {

        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        DSTokenLike rewardToken = DSTokenLike(incentivesContract.rewardsToken());
        DSTokenLike lpToken = DSTokenLike(incentivesContract.stakingToken());
        incentivesContract.exit();
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
        lpToken.transfer(msg.sender, lpToken.balanceOf(address(this)));
    }

    function migrateCampaign(address _oldIncentives, address _newIncentives) external {

        GebIncentivesLike incentives = GebIncentivesLike(_oldIncentives);
        GebIncentivesLike newIncentives = GebIncentivesLike(_newIncentives);
        require(incentives.stakingToken() == newIncentives.stakingToken(), "geb-incentives/mismatched-staking-tokens");
        DSTokenLike rewardToken = DSTokenLike(incentives.rewardsToken());
        DSTokenLike lpToken = DSTokenLike(incentives.stakingToken());
        incentives.exit();

        _stakeInMine(_newIncentives);

        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function withdrawFromMine(address incentives, uint value) external {

        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        DSTokenLike lpToken = DSTokenLike(incentivesContract.stakingToken());
        incentivesContract.withdraw(value);
        lpToken.transfer(msg.sender, lpToken.balanceOf(address(this)));
    }

    function withdrawAndHarvest(address incentives, uint value) external {

        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        DSTokenLike rewardToken = DSTokenLike(incentivesContract.rewardsToken());
        DSTokenLike lpToken = DSTokenLike(incentivesContract.stakingToken());
        incentivesContract.withdraw(value);
        getRewards(incentives);
        lpToken.transfer(msg.sender, lpToken.balanceOf(address(this)));
    }

    function withdrawHarvestRemoveLiquidity(address incentives, address uniswapRouter, address systemCoin, uint value, uint[2] memory minTokenAmounts) public returns (uint amountA, uint amountB) {

        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        DSTokenLike rewardToken = DSTokenLike(incentivesContract.rewardsToken());
        DSTokenLike lpToken = DSTokenLike(incentivesContract.stakingToken());
        incentivesContract.withdraw(value);
        getRewards(incentives);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
        return _removeLiquidityUniswap(uniswapRouter, systemCoin, lpToken.balanceOf(address(this)), msg.sender, minTokenAmounts);
    }

    function removeLiquidityUniswap(address uniswapRouter, address systemCoin, uint value, uint[2] calldata minTokenAmounts) external returns (uint amountA, uint amountB) {

        DSTokenLike(getWethPair(uniswapRouter, systemCoin)).transferFrom(msg.sender, address(this), value);
        return _removeLiquidityUniswap(uniswapRouter, systemCoin, value, msg.sender, minTokenAmounts);
    }

    function withdrawAndRemoveLiquidity(address coinJoin, address incentives, uint value, address uniswapRouter, uint[2] calldata minTokenAmounts) external returns (uint amountA, uint amountB) {

        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        incentivesContract.withdraw(value);
        return _removeLiquidityUniswap(uniswapRouter, address(CoinJoinLike(coinJoin).systemCoin()), value, msg.sender, minTokenAmounts);
    }

    function withdrawRemoveLiquidityRepayDebt(address manager, address coinJoin, uint safe, address incentives, uint value, address uniswapRouter, uint[2] calldata minTokenAmounts) external {

        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        DSTokenLike rewardToken = DSTokenLike(incentivesContract.rewardsToken());
        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());
        incentivesContract.withdraw(value);

        _removeLiquidityUniswap(uniswapRouter, address(systemCoin), value, address(this), minTokenAmounts);
        _repayDebt(manager, coinJoin, safe, systemCoin.balanceOf(address(this)), false);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
        msg.sender.call{value: address(this).balance}("");
    }

    function exitAndRemoveLiquidity(address coinJoin, address incentives, address uniswapRouter, uint[2] calldata minTokenAmounts) external returns (uint amountA, uint amountB) {

        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        DSTokenLike rewardToken = DSTokenLike(incentivesContract.rewardsToken());
        DSTokenLike lpToken = DSTokenLike(incentivesContract.stakingToken());
        incentivesContract.exit();
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
        return _removeLiquidityUniswap(uniswapRouter, address(CoinJoinLike(coinJoin).systemCoin()), lpToken.balanceOf(address(this)), msg.sender, minTokenAmounts);
    }

    function exitRemoveLiquidityRepayDebt(address manager, address coinJoin, uint safe, address incentives, address uniswapRouter, uint[2] calldata minTokenAmounts) external {


        GebIncentivesLike incentivesContract = GebIncentivesLike(incentives);
        DSTokenLike rewardToken = DSTokenLike(incentivesContract.rewardsToken());
        DSTokenLike lpToken = DSTokenLike(incentivesContract.stakingToken());
        DSTokenLike systemCoin = DSTokenLike(CoinJoinLike(coinJoin).systemCoin());
        incentivesContract.exit();
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));

        _removeLiquidityUniswap(uniswapRouter, address(systemCoin), lpToken.balanceOf(address(this)), address(this), minTokenAmounts);

        _repayDebt(manager, coinJoin, safe, systemCoin.balanceOf(address(this)), false);
        msg.sender.call{value: address(this).balance}("");
    }

    function getWethPair(address uniswapRouter, address token) public view returns (address) {

        IUniswapV2Router02 router = IUniswapV2Router02(uniswapRouter);
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());
        return factory.getPair(token, router.WETH());
    }
}