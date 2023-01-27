


pragma solidity ^0.6.0;

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



pragma solidity ^0.6.10;



interface IWeth is IERC20 {

    function deposit() external payable;

    function withdraw(uint) external;

}



pragma solidity ^0.6.10;


interface IDai is IERC20 { // Doesn't conform to IERC2612

    function nonces(address user) external view returns (uint256);

    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) external;

}



pragma solidity ^0.6.0;

interface IERC2612 {

    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);

}



pragma solidity ^0.6.10;



interface IFYDai is IERC20, IERC2612 {

    function isMature() external view returns(bool);

    function maturity() external view returns(uint);

    function chi0() external view returns(uint);

    function rate0() external view returns(uint);

    function chiGrowth() external view returns(uint);

    function rateGrowth() external view returns(uint);

    function mature() external;

    function unlocked() external view returns (uint);

    function mint(address, uint) external;

    function burn(address, uint) external;

    function flashMint(uint, bytes calldata) external;

    function redeem(address, address, uint256) external returns (uint256);

}



pragma solidity ^0.6.10;


interface IVat {

    function can(address, address) external view returns (uint);

    function wish(address, address) external view returns (uint);

    function hope(address) external;

    function nope(address) external;

    function live() external view returns (uint);

    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);

    function urns(bytes32, address) external view returns (uint, uint);

    function gem(bytes32, address) external view returns (uint);

    function frob(bytes32, address, address, address, int, int) external;

    function fork(bytes32, address, address, int, int) external;

    function move(address, address, uint) external;

    function flux(bytes32, address, address, uint) external;

}



pragma solidity ^0.6.10;


interface IGemJoin {

    function rely(address usr) external;

    function deny(address usr) external;

    function cage() external;

    function join(address usr, uint WAD) external;

    function exit(address usr, uint WAD) external;

}



pragma solidity ^0.6.10;


interface IDaiJoin {

    function rely(address usr) external;

    function deny(address usr) external;

    function cage() external;

    function join(address usr, uint WAD) external;

    function exit(address usr, uint WAD) external;

}



pragma solidity ^0.6.10;


interface IPot {

    function chi() external view returns (uint256);

    function pie(address) external view returns (uint256); // Not a function, but a public variable.

    function rho() external returns (uint256);

    function drip() external returns (uint256);

    function join(uint256) external;

    function exit(uint256) external;

}



pragma solidity ^0.6.10;



interface IChai is IERC20, IERC2612 {

    function move(address src, address dst, uint wad) external returns (bool);

    function dai(address usr) external returns (uint wad);

    function join(address dst, uint wad) external;

    function exit(address src, uint wad) external;

    function draw(address src, uint wad) external;

}



pragma solidity ^0.6.10;








interface ITreasury {

    function debt() external view returns(uint256);

    function savings() external view returns(uint256);

    function pushDai(address user, uint256 dai) external;

    function pullDai(address user, uint256 dai) external;

    function pushChai(address user, uint256 chai) external;

    function pullChai(address user, uint256 chai) external;

    function pushWeth(address to, uint256 weth) external;

    function pullWeth(address to, uint256 weth) external;

    function shutdown() external;

    function live() external view returns(bool);


    function vat() external view returns (IVat);

    function weth() external view returns (IWeth);

    function dai() external view returns (IDai);

    function daiJoin() external view returns (IDaiJoin);

    function wethJoin() external view returns (IGemJoin);

    function pot() external view returns (IPot);

    function chai() external view returns (IChai);

}



pragma solidity ^0.6.10;


interface IDelegable {

    function addDelegate(address) external;

    function addDelegateBySignature(address, address, uint, uint8, bytes32, bytes32) external;

    function delegated(address, address) external view returns (bool);

}



pragma solidity ^0.6.10;





interface IController is IDelegable {

    function treasury() external view returns (ITreasury);

    function series(uint256) external view returns (IFYDai);

    function seriesIterator(uint256) external view returns (uint256);

    function totalSeries() external view returns (uint256);

    function containsSeries(uint256) external view returns (bool);

    function posted(bytes32, address) external view returns (uint256);

    function locked(bytes32, address) external view returns (uint256);

    function debtFYDai(bytes32, uint256, address) external view returns (uint256);

    function debtDai(bytes32, uint256, address) external view returns (uint256);

    function totalDebtDai(bytes32, address) external view returns (uint256);

    function isCollateralized(bytes32, address) external view returns (bool);

    function inDai(bytes32, uint256, uint256) external view returns (uint256);

    function inFYDai(bytes32, uint256, uint256) external view returns (uint256);

    function erase(bytes32, address) external returns (uint256, uint256);

    function shutdown() external;

    function post(bytes32, address, address, uint256) external;

    function withdraw(bytes32, address, address, uint256) external;

    function borrow(bytes32, uint256, address, address, uint256) external;

    function repayFYDai(bytes32, uint256, address, address, uint256) external returns (uint256);

    function repayDai(bytes32, uint256, address, address, uint256) external returns (uint256);

}



pragma solidity ^0.6.10;





interface IPool is IDelegable, IERC20, IERC2612 {

    function dai() external view returns(IERC20);

    function fyDai() external view returns(IFYDai);

    function getDaiReserves() external view returns(uint128);

    function getFYDaiReserves() external view returns(uint128);

    function sellDai(address from, address to, uint128 daiIn) external returns(uint128);

    function buyDai(address from, address to, uint128 daiOut) external returns(uint128);

    function sellFYDai(address from, address to, uint128 fyDaiIn) external returns(uint128);

    function buyFYDai(address from, address to, uint128 fyDaiOut) external returns(uint128);

    function sellDaiPreview(uint128 daiIn) external view returns(uint128);

    function buyDaiPreview(uint128 daiOut) external view returns(uint128);

    function sellFYDaiPreview(uint128 fyDaiIn) external view returns(uint128);

    function buyFYDaiPreview(uint128 fyDaiOut) external view returns(uint128);

    function mint(address from, address to, uint256 daiOffered) external returns (uint256);

    function burn(address from, address to, uint256 tokensBurned) external returns (uint256, uint256);

}



pragma solidity ^0.6.10;


library SafeCast {

    function toUint128(uint256 x) internal pure returns(uint128) {

        require(
            x <= type(uint128).max,
            "SafeCast: Cast overflow"
        );
        return uint128(x);
    }

    function toInt256(uint256 x) internal pure returns(int256) {

        require(
            x <= uint256(type(int256).max),
            "SafeCast: Cast overflow"
        );
        return int256(x);
    }
}



pragma solidity ^0.6.10;




library YieldAuth {


    function unpack(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) {

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }

    function addDelegatePacked(IDelegable target, bytes memory signature) internal {

        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = unpack(signature);
        target.addDelegateBySignature(msg.sender, address(this), type(uint256).max, v, r, s);
    }

    function addDelegatePacked(IDelegable target, address user, address delegate, bytes memory signature) internal {

        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = unpack(signature);
        target.addDelegateBySignature(user, delegate, type(uint256).max, v, r, s);
    }

    function permitPackedDai(IDai dai, address spender, bytes memory signature) internal {

        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = unpack(signature);
        dai.permit(msg.sender, spender, dai.nonces(msg.sender), type(uint256).max, true, v, r, s);
    }

    function permitPacked(IERC2612 token, address spender, bytes memory signature) internal {

        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = unpack(signature);
        token.permit(msg.sender, spender, type(uint256).max, type(uint256).max, v, r, s);
    }
}



pragma solidity ^0.6.10;










contract BorrowProxy {

    using SafeCast for uint256;
    using YieldAuth for IDai;
    using YieldAuth for IFYDai;
    using YieldAuth for IController;
    using YieldAuth for IPool;

    IWeth public immutable weth;
    IDai public immutable dai;
    IController public immutable controller;
    address public immutable treasury;

    bytes32 public constant WETH = "ETH-A";

    constructor(IController _controller) public {
        ITreasury _treasury = _controller.treasury();
        weth = _treasury.weth();
        dai = _treasury.dai();
        treasury = address(_treasury);
        controller = _controller;
    }

    receive() external payable { }

    function post(address to)
        external payable {

        if (weth.allowance(address(this), treasury) < type(uint256).max) weth.approve(treasury, type(uint256).max);

        weth.deposit{ value: msg.value }();
        controller.post(WETH, address(this), to, msg.value);
    }

    function withdraw(address payable to, uint256 amount)
        public {

        controller.withdraw(WETH, msg.sender, address(this), amount);
        weth.withdraw(amount);
        to.transfer(amount);
    }

    function borrowDaiForMaximumFYDai(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 daiToBorrow,
        uint256 maximumFYDai
    )
        public
        returns (uint256)
    {

        uint256 fyDaiToBorrow = pool.buyDaiPreview(daiToBorrow.toUint128());
        require (fyDaiToBorrow <= maximumFYDai, "BorrowProxy: Too much fyDai required");

        controller.borrow(collateral, maturity, msg.sender, address(this), fyDaiToBorrow);
        pool.buyDai(address(this), to, daiToBorrow.toUint128());

        return fyDaiToBorrow;
    }

    function repayMinimumFYDaiDebtForDai(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 minimumFYDaiRepayment,
        uint256 repaymentInDai
    )
        public
        returns (uint256)
    {

        uint256 fyDaiRepayment = pool.sellDaiPreview(repaymentInDai.toUint128());
        uint256 fyDaiDebt = controller.debtFYDai(collateral, maturity, to);
        if(fyDaiRepayment <= fyDaiDebt) { // Sell no more Dai than needed to cancel all the debt
            pool.sellDai(msg.sender, address(this), repaymentInDai.toUint128());
        } else { // If we have too much Dai, then don't sell it all and buy the exact amount of fyDai needed instead.
            pool.buyFYDai(msg.sender, address(this), fyDaiDebt.toUint128());
            fyDaiRepayment = fyDaiDebt;
        }
        require (fyDaiRepayment >= minimumFYDaiRepayment, "BorrowProxy: Not enough fyDai debt repaid");
        controller.repayFYDai(collateral, maturity, address(this), to, fyDaiRepayment);

        return fyDaiRepayment;
    }

    function sellFYDai(IPool pool, address to, uint128 fyDaiIn, uint128 minDaiOut)
        public
        returns(uint256)
    {

        uint256 daiOut = pool.sellFYDai(msg.sender, to, fyDaiIn);
        require(
            daiOut >= minDaiOut,
            "BorrowProxy: Limit not reached"
        );
        return daiOut;
    }

    function sellDai(IPool pool, address to, uint128 daiIn, uint128 minFYDaiOut)
        public
        returns(uint256)
    {

        uint256 fyDaiOut = pool.sellDai(msg.sender, to, daiIn);
        require(
            fyDaiOut >= minFYDaiOut,
            "BorrowProxy: Limit not reached"
        );
        return fyDaiOut;
    }

    function buyDai(IPool pool, address to, uint128 daiOut, uint128 maxFYDaiIn)
        public
        returns(uint256)
    {

        uint256 fyDaiIn = pool.buyDai(msg.sender, to, daiOut);
        require(
            maxFYDaiIn >= fyDaiIn,
            "BorrowProxy: Limit exceeded"
        );
        return fyDaiIn;
    }


    function withdrawCheck() public view returns (bool, bool) {

        bool approvals = true; // sellFYDai doesn't need proxy approvals
        bool controllerSig = controller.delegated(msg.sender, address(this));
        return (approvals, controllerSig);
    }

    function withdrawWithSignature(address payable to, uint256 amount, bytes memory controllerSig)
        public {

        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        withdraw(to, amount);
    }

    function borrowDaiForMaximumFYDaiCheck(IPool pool) public view returns (bool, bool) {

        bool approvals = pool.fyDai().allowance(address(this), address(pool)) >= type(uint112).max;
        bool controllerSig = controller.delegated(msg.sender, address(this));
        return (approvals, controllerSig);
    }

    function borrowDaiForMaximumFYDaiApprove(IPool pool) public {

        if (pool.fyDai().allowance(address(this), address(pool)) < type(uint112).max)
            pool.fyDai().approve(address(pool), type(uint256).max);
    }

    function borrowDaiForMaximumFYDaiWithSignature(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 daiToBorrow,
        uint256 maximumFYDai,
        bytes memory controllerSig
    )
        public
        returns (uint256)
    {

        borrowDaiForMaximumFYDaiApprove(pool);
        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        return borrowDaiForMaximumFYDai(pool, collateral, maturity, to, daiToBorrow, maximumFYDai);
    }

    function repayDaiCheck() public view returns (bool, bool, bool) {

        bool approvals = true; // repayDai doesn't need proxy approvals
        bool daiSig = dai.allowance(msg.sender, treasury) == type(uint256).max;
        bool controllerSig = controller.delegated(msg.sender, address(this));
        return (approvals, daiSig, controllerSig);
    }

    function repayDaiWithSignature(
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 daiAmount,
        bytes memory daiSig,
        bytes memory controllerSig
    )
        external
        returns(uint256)
    {

        if (daiSig.length > 0) dai.permitPackedDai(treasury, daiSig);
        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        controller.repayDai(collateral, maturity, msg.sender, to, daiAmount);
    }

    function repayMinimumFYDaiDebtForDaiApprove(IPool pool) public {

        if (pool.fyDai().allowance(address(this), treasury) < type(uint112).max)
            pool.fyDai().approve(treasury, type(uint256).max);
    }

    function repayMinimumFYDaiDebtForDaiCheck(IPool pool) public view returns (bool, bool, bool) {

        bool approvals = pool.fyDai().allowance(address(this), treasury) >= type(uint112).max;
        bool controllerSig = controller.delegated(msg.sender, address(this));
        bool poolSig = pool.delegated(msg.sender, address(this));
        return (approvals, controllerSig, poolSig);
    }

    function repayMinimumFYDaiDebtForDaiWithSignature(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 minimumFYDaiRepayment,
        uint256 repaymentInDai,
        bytes memory controllerSig,
        bytes memory poolSig
    )
        public
        returns (uint256)
    {

        repayMinimumFYDaiDebtForDaiApprove(pool);
        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        if (poolSig.length > 0) pool.addDelegatePacked(poolSig);
        return repayMinimumFYDaiDebtForDai(pool, collateral, maturity, to, minimumFYDaiRepayment, repaymentInDai);
    }

    function sellFYDaiCheck(IPool pool) public view returns (bool, bool, bool) {

        bool approvals = true; // sellFYDai doesn't need proxy approvals
        bool fyDaiSig = pool.fyDai().allowance(msg.sender, address(pool)) >= type(uint112).max;
        bool poolSig = pool.delegated(msg.sender, address(this));
        return (approvals, fyDaiSig, poolSig);
    }

    function sellFYDaiWithSignature(
        IPool pool,
        address to,
        uint128 fyDaiIn,
        uint128 minDaiOut,
        bytes memory fyDaiSig,
        bytes memory poolSig
    )
        public
        returns(uint256)
    {

        if (fyDaiSig.length > 0) pool.fyDai().permitPacked(address(pool), fyDaiSig);
        if (poolSig.length > 0) pool.addDelegatePacked(poolSig);
        return sellFYDai(pool, to, fyDaiIn, minDaiOut);
    }

    function sellDaiCheck(IPool pool) public view returns (bool, bool, bool) {

        bool approvals = true; // sellDai doesn't need proxy approvals
        bool daiSig = dai.allowance(msg.sender, address(pool)) == type(uint256).max;
        bool poolSig = pool.delegated(msg.sender, address(this));
        return (approvals, daiSig, poolSig);
    }

    function sellDaiWithSignature(
        IPool pool,
        address to,
        uint128 daiIn,
        uint128 minFYDaiOut,
        bytes memory daiSig,
        bytes memory poolSig
    )
        external
        returns(uint256)
    {

        if (daiSig.length > 0) dai.permitPackedDai(address(pool), daiSig);
        if (poolSig.length > 0) pool.addDelegatePacked(poolSig);
        return sellDai(pool, to, daiIn, minFYDaiOut);
    }

    function buyDaiCheck(IPool pool) public view returns (bool, bool, bool) {

        return sellFYDaiCheck(pool);
    }

    function buyDaiWithSignature(
        IPool pool,
        address to,
        uint128 daiOut,
        uint128 maxFYDaiIn,
        bytes memory fyDaiSig,
        bytes memory poolSig
    )
        external
        returns(uint256)
    {

        if (fyDaiSig.length > 0) pool.fyDai().permitPacked(address(pool), fyDaiSig);
        if (poolSig.length > 0) pool.addDelegatePacked(poolSig);
        return buyDai(pool, to, daiOut, maxFYDaiIn);
    }

}