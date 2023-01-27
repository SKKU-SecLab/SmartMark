pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;


interface ICurvePool {

  function coins(uint256 n) external view returns (address);

  function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);

  function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy) external returns (uint256);

}// MIT

pragma solidity >=0.6.11;

interface IHarvestForwarder {

  function distribute(
    address token,
    uint256 amount,
    address beneficiary
  ) external;

  function badger_tree() external view returns(address);

}// MIT

pragma solidity >=0.6.11;

interface ISettV4 {

    function deposit(uint256 _amount) external;


    function depositFor(address _recipient, uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    function balance() external view returns (uint256);


    function getPricePerFullShare() external view returns (uint256);


    function balanceOf(address) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function approveContractAccess(address) external;

    function governance() external view returns (address);

    
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.1;

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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT
pragma solidity >=0.5.0;

interface IUniswapRouterV2 {

    function factory() external view returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}// MIT
pragma solidity >=0.5.0;


interface ICurveRouter {

  function get_best_rate(
    address from, address to, uint256 _amount) external view returns (address, uint256);

  
  function exchange_with_best_rate(
    address _from,
    address _to,
    uint256 _amount,
    uint256 _expected
  ) external returns (uint256);

}// MIT
pragma solidity >=0.5.0;


interface ICowSettlement {

  function setPreSignature(bytes calldata orderUid, bool signed) external;

  function preSignature(bytes calldata orderUid) external view returns (uint256);

  function domainSeparator() external view returns (bytes32);

}// MIT
pragma solidity 0.8.10;





struct Quote {
    string name;
    uint256 amountOut;
}
interface OnChainPricing {

  function findOptimalSwap(address tokenIn, address tokenOut, uint256 amountIn) external view returns (Quote memory);

}

contract CowSwapSeller is ReentrancyGuard {

    using SafeERC20 for IERC20;
    OnChainPricing public pricer; // Contract we will ask for a fair price of before accepting the cowswap order

    address public manager;

    address public constant DEV_MULTI = 0xB65cef03b9B89f99517643226d76e286ee999e77;

    address public constant RELAYER = 0xC92E8bdf79f0507f65a392b0ab4667716BFE0110;

    ICowSettlement public constant SETTLEMENT = ICowSettlement(0x9008D19f58AAbD9eD0D60971565AA8510560ab41);

    bytes32 private constant TYPE_HASH =
        hex"d5a25ba2e97094ad7d83dc28a6572da797d6b3e7fc6663bd93efb789fc17e489";

    bytes32 public constant KIND_SELL =
        hex"f3b277728b3fee749481eb3e0b3b48980dbbab78658fc419025cb16eee346775";
    bytes32 public constant BALANCE_ERC20 =
        hex"5a28e9363bb942b639270062aa6bb295f434bcdfc42c97267bf003f272060dc9";

    bytes32 public immutable domainSeparator;
    uint256 constant UID_LENGTH = 56;

    struct Data {
        IERC20 sellToken;
        IERC20 buyToken;
        address receiver;
        uint256 sellAmount;
        uint256 buyAmount;
        uint32 validTo;
        bytes32 appData;
        uint256 feeAmount;
        bytes32 kind;
        bool partiallyFillable;
        bytes32 sellTokenBalance;
        bytes32 buyTokenBalance;
    }
        

    function packOrderUidParams(
        bytes memory orderUid,
        bytes32 orderDigest,
        address owner,
        uint32 validTo
    ) pure public {

        require(orderUid.length == UID_LENGTH, "GPv2: uid buffer overflow");

        assembly {
            mstore(add(orderUid, 56), validTo)
            mstore(add(orderUid, 52), owner)
            mstore(add(orderUid, 32), orderDigest)
        }
    }
    constructor(address _pricer) {
        pricer = OnChainPricing(_pricer);
        manager = msg.sender;

        domainSeparator = SETTLEMENT.domainSeparator();
    }

    function setPricer(OnChainPricing newPricer) external {

        require(msg.sender == DEV_MULTI);
        pricer = newPricer;
    }

    function setManager(address newManager) external {

        require(msg.sender == manager);
        manager = newManager;
    }

    function getHash(Data memory order, bytes32 separator)
        public
        pure
        returns (bytes32 orderDigest)
    {

        bytes32 structHash;

        assembly {
            let dataStart := sub(order, 32)
            let temp := mload(dataStart)
            mstore(dataStart, TYPE_HASH)
            structHash := keccak256(dataStart, 416)
            mstore(dataStart, temp)
        }

        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, "\x19\x01")
            mstore(add(freeMemoryPointer, 2), separator)
            mstore(add(freeMemoryPointer, 34), structHash)
            orderDigest := keccak256(freeMemoryPointer, 66)
        }
    }

    function getOrderID(Data calldata orderData) public view returns (bytes memory) {

        bytes memory orderUid = new bytes(UID_LENGTH);

        bytes32 digest = getHash(orderData, domainSeparator);
        packOrderUidParams(orderUid, digest, address(this), orderData.validTo);

        return orderUid;
    }

    function checkCowswapOrder(Data calldata orderData, bytes memory orderUid) public virtual view returns(bool) {

        bytes memory derivedOrderID = getOrderID(orderData);
        require(keccak256(derivedOrderID) == keccak256(orderUid));

        require(orderData.validTo > block.timestamp);
        require(orderData.receiver == address(this));
        require(keccak256(abi.encodePacked(orderData.kind)) == keccak256(abi.encodePacked(KIND_SELL)));

        require(orderData.feeAmount <= orderData.sellAmount / 10); // Fee can be at most 1/10th of order

        address tokenIn = address(orderData.sellToken);
        address tokenOut = address(orderData.buyToken);

        uint256 amountIn = orderData.sellAmount;
        uint256 amountOut = orderData.buyAmount;

        Quote memory result = pricer.findOptimalSwap(tokenIn, tokenOut, amountIn);

        return(result.amountOut <= amountOut);
    }


    function _doCowswapOrder(Data calldata orderData, bytes memory orderUid) internal nonReentrant {

        require(msg.sender == manager);

        require(checkCowswapOrder(orderData, orderUid));

        orderData.sellToken.safeApprove(RELAYER, 0); // Set to 0 just in case
        orderData.sellToken.safeApprove(RELAYER, orderData.sellAmount + orderData.feeAmount);

        SETTLEMENT.setPreSignature(orderUid, true);
    }

    function _cancelCowswapOrder(bytes memory orderUid) internal nonReentrant {

        require(msg.sender == manager);

        SETTLEMENT.setPreSignature(orderUid, false);
    }
}// MIT
pragma solidity 0.8.10;




contract VotiumBribesProcessor is CowSwapSeller {

    using SafeERC20 for IERC20;


    event SentBribeToGovernance(address indexed token, uint256 amount);
    event SentBribeToTree(address indexed token, uint256 amount);
    event PerformanceFeeGovernance(address indexed token, uint256 amount);
    event BribeEmission(address indexed token, address indexed recipient, uint256 amount);


    uint256 public lastBribeAction;

    uint256 public constant MAX_MANAGER_IDLE_TIME = 10 days; // Because we have Strategy Notify, 10 days is enough

    IERC20 public constant BADGER = IERC20(0x3472A5A71965499acd81997a54BBA8D852C6E53d);
    IERC20 public constant CVX = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    IERC20 public constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public constant STRATEGY = 0x898111d1F4eB55025D0036568212425EE2274082;
    address public constant BADGER_TREE = 0x660802Fc641b154aBA66a62137e71f331B6d787A;
    address public constant B_BVECVX_CVX = 0x937B8E917d0F36eDEBBA8E459C5FB16F3b315551;

    uint256 public constant MAX_BPS = 10_000;
    uint256 public constant BADGER_SHARE = 2750; //27.50%
    uint256 public constant OPS_FEE = 500; // 5%
    uint256 public constant LP_FEE = 500; // 5%

    address public constant TREASURY = 0xD0A7A8B98957b9CD3cFB9c0425AbE44551158e9e;

    ISettV4 public constant BVE_CVX = ISettV4(0xfd05D3C7fe2924020620A8bE4961bBaA747e6305);
    ICurvePool public constant CVX_BVE_CVX_CURVE = ICurvePool(0x04c90C198b2eFF55716079bc06d7CCc4aa4d7512);

    IHarvestForwarder public constant HARVEST_FORWARDER = IHarvestForwarder(0xA84B663837D94ec41B0f99903f37e1d69af9Ed3E);

    constructor(address _pricer) CowSwapSeller(_pricer) {}

    function notifyNewRound() external {

        require(msg.sender == STRATEGY);

        lastBribeAction = block.timestamp;
    }



    function ragequit(IERC20 token, bool sendToGovernance) external nonReentrant {

        bool timeHasExpired = block.timestamp > lastBribeAction + MAX_MANAGER_IDLE_TIME;
        require(msg.sender == manager || timeHasExpired);

        token.safeApprove(address(RELAYER), 0);

        uint256 amount = token.balanceOf(address(this));
        if(sendToGovernance) {
            token.safeTransfer(DEV_MULTI, amount);

            emit SentBribeToGovernance(address(token), amount);
        } else {
            require(HARVEST_FORWARDER.badger_tree() == BADGER_TREE);
            
            if(!timeHasExpired && msg.sender == manager) {

                uint256 fee = amount * OPS_FEE / MAX_BPS;
                token.safeTransfer(TREASURY, fee);

                emit PerformanceFeeGovernance(address(token), fee);

                amount -= fee;
            }
            token.safeApprove(address(HARVEST_FORWARDER), amount);
            HARVEST_FORWARDER.distribute(address(token), amount, address(BVE_CVX));

            emit SentBribeToTree(address(token), amount);
        }
    }


    function sellBribeForWeth(Data calldata orderData, bytes memory orderUid) external {

        require(orderData.sellToken != CVX); // Can't sell CVX;
        require(orderData.sellToken != BADGER); // Can't sell BADGER either;
        require(orderData.sellToken != WETH); // Can't sell WETH
        require(orderData.buyToken == WETH); // Gotta Buy WETH;

        _doCowswapOrder(orderData, orderUid);
    }

    function swapWethForBadger(Data calldata orderData, bytes memory orderUid) external {

        require(orderData.sellToken == WETH);
        require(orderData.buyToken == BADGER);

        _doCowswapOrder(orderData, orderUid);
    }

    function swapWethForCVX(Data calldata orderData, bytes memory orderUid) external {

        require(orderData.sellToken == WETH);
        require(orderData.buyToken == CVX);

        _doCowswapOrder(orderData, orderUid);
    }

    function swapCVXTobveCVXAndEmit() external nonReentrant {

        require(msg.sender == manager);

        uint256 totalCVX = CVX.balanceOf(address(this));
        require(totalCVX > 0);
        require(HARVEST_FORWARDER.badger_tree() == BADGER_TREE);

        uint256 fromPurchase = CVX_BVE_CVX_CURVE.get_dy(0, 1, totalCVX);

        uint256 fromDeposit = totalCVX * BVE_CVX.totalSupply() / BVE_CVX.balance();

        uint256 ops_fee;
        uint256 toEmit;

        if(fromDeposit > fromPurchase) {

            ops_fee = totalCVX * OPS_FEE / (MAX_BPS - BADGER_SHARE);

            toEmit = totalCVX - ops_fee;

            CVX.safeApprove(address(BVE_CVX), totalCVX);

            uint256 treasuryPrevBalance = BVE_CVX.balanceOf(TREASURY);


            BVE_CVX.depositFor(TREASURY, ops_fee);

            uint256 initialBveCVXBalance = BVE_CVX.balanceOf((address(this)));
            BVE_CVX.deposit(toEmit);

            ops_fee = BVE_CVX.balanceOf(TREASURY) - treasuryPrevBalance;
            toEmit = BVE_CVX.balanceOf(address(this)) - initialBveCVXBalance;
        } else {

            CVX.safeApprove(address(CVX_BVE_CVX_CURVE), totalCVX);

            uint256 totalBveCVX = CVX_BVE_CVX_CURVE.exchange(0, 1, totalCVX, fromPurchase);

            ops_fee = totalBveCVX * OPS_FEE / (MAX_BPS - BADGER_SHARE);

            toEmit = totalBveCVX - ops_fee;

            IERC20(address(BVE_CVX)).safeTransfer(TREASURY, ops_fee);
        }

        IERC20(address(BVE_CVX)).safeApprove(address(HARVEST_FORWARDER), toEmit);
        HARVEST_FORWARDER.distribute(address(BVE_CVX), toEmit, address(BVE_CVX));

        emit PerformanceFeeGovernance(address(BVE_CVX), ops_fee);
        emit BribeEmission(address(BVE_CVX), address(BVE_CVX), toEmit);
    }

    function emitBadger() external nonReentrant {

        require(msg.sender == manager);
        require(HARVEST_FORWARDER.badger_tree() == BADGER_TREE);

        uint256 toEmitTotal = BADGER.balanceOf(address(this));
        require(toEmitTotal > 0);

        uint256 toEmitToLp = toEmitTotal * LP_FEE / BADGER_SHARE;
        uint256 toEmitToBveCvx = toEmitTotal - toEmitToLp;

        BADGER.safeApprove(address(HARVEST_FORWARDER), toEmitTotal);
        HARVEST_FORWARDER.distribute(address(BADGER), toEmitToLp, B_BVECVX_CVX);
        HARVEST_FORWARDER.distribute(address(BADGER), toEmitToBveCvx, address(BVE_CVX));

        emit BribeEmission(address(BADGER), B_BVECVX_CVX, toEmitToLp);
        emit BribeEmission(address(BADGER), address(BVE_CVX), toEmitToBveCvx);
    }



    function setCustomAllowance(address token, uint256 newAllowance) external nonReentrant {

        require(msg.sender == manager);

        IERC20(token).safeApprove(RELAYER, 0);
        IERC20(token).safeApprove(RELAYER, newAllowance); 
    }
}