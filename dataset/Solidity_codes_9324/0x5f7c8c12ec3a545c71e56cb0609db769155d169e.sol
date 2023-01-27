

pragma solidity ^0.6.5;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

interface ITokenController {

    function proxyPayment(address _owner) external payable returns (bool);

    function onTransfer(address _from, address _to, uint256 _amount) external returns (bool);

    function onApprove(address _owner, address _spender, uint256 _amount) external returns (bool);

}

interface IMiniMeToken is IERC20 {

    function changeController(address _governor) external;

    function controller() external view returns (address); // Getter

}

interface IBPool is IERC20 {

    function getBalance(address token) external view returns (uint256);

    function getSwapFee() external view returns (uint256);

    function gulp(address token) external;

    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);

    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;

}

contract BalancerPoolRecoverer is ITokenController {


    uint256 constant public ITERATION_COUNT = 32; // The number of swaps to make.

    IMiniMeToken immutable public pnkToken;
    IERC20 immutable public wethToken;
    IBPool immutable public bpool;
    address immutable public controller;
    address immutable public beneficiary;

    bool recoveryOngoing; // Control TokenController functionality (block transfers by default).
    uint256 initiateRestoreControllerTimestamp;



    constructor(
        IMiniMeToken _pnkToken,
        IERC20 _wethToken,
        IBPool _bpool,
        address _controller,
        address _beneficiary
    ) public {
        pnkToken = _pnkToken;
        wethToken = _wethToken;
        bpool = _bpool;
        controller = _controller;
        beneficiary = _beneficiary;
    }

    function initiateRestoreController() external {

        require(initiateRestoreControllerTimestamp == 0);
        require(pnkToken.controller() == address(this));
        initiateRestoreControllerTimestamp = block.timestamp;
    }

    function restoreController() external {

        require(initiateRestoreControllerTimestamp != 0);
        require(initiateRestoreControllerTimestamp + 1 hours < block.timestamp);
        pnkToken.changeController(address(controller));
    }

    function recover() external {

        recoveryOngoing = true;

        uint256 poolBalancePNK = pnkToken.balanceOf(address(bpool));
        uint256 balancePNK = poolBalancePNK;
        uint256 balanceWETH;

        pnkToken.transferFrom(address(bpool), address(this), poolBalancePNK - 2); // Need to be the controller.
        bpool.gulp(address(pnkToken));
        pnkToken.approve(address(bpool), poolBalancePNK - 2);
        poolBalancePNK = 2;


        for (uint256 i = 0; i < ITERATION_COUNT; i++) {
            uint256 tokenAmountIn = poolBalancePNK / 2;
            (uint256 tokenAmoutOut, ) = bpool.swapExactAmountIn(
                address(pnkToken), // tokenIn
                tokenAmountIn, // tokenAmountIn
                address(wethToken), // tokenOut
                0, // minAmountOut
                uint256(-1) // maxPrice
            );

            balanceWETH += tokenAmoutOut;
            poolBalancePNK += tokenAmountIn;
        }

        pnkToken.transferFrom(address(bpool), address(this), poolBalancePNK); // Need to be the controller.

        wethToken.transfer(beneficiary, balanceWETH);
        pnkToken.transfer(beneficiary, balancePNK);

        pnkToken.changeController(address(controller));
    }

    function proxyPayment(address _owner) override public payable returns (bool) {

        return false;
    }
    function onTransfer(address _from, address _to, uint256 _amount) override public returns (bool) {

        return recoveryOngoing;
    }
    function onApprove(address _owner, address _spender, uint256 _amount) override public returns (bool) {

        return true;
    }
}