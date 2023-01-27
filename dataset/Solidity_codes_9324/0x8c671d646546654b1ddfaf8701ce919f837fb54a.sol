pragma solidity 0.8.0;

interface IAutoGamma {

    struct Order {
        address owner;
        address otoken;
        uint256 amount;
        uint256 vaultId;
        bool isSeller;
        address toToken;
        uint256 fee;
        bool finished;
    }

    struct ProcessOrderArgs {
        uint256 swapAmountOutMin;
        address[] swapPath;
    }

    event OrderCreated(
        uint256 indexed orderId,
        address indexed owner,
        address indexed otoken
    );
    event OrderFinished(uint256 indexed orderId, bool indexed cancelled);

    function createOrder(
        address _otoken,
        uint256 _amount,
        uint256 _vaultId,
        address _toToken
    ) external;


    function cancelOrder(uint256 _orderId) external;


    function shouldProcessOrder(uint256 _orderId) external view returns (bool);


    function processOrder(uint256 _orderId, ProcessOrderArgs calldata _orderArg)
        external;


    function processOrders(
        uint256[] calldata _orderIds,
        ProcessOrderArgs[] calldata _orderArgs
    ) external;


    function getOrdersLength() external view returns (uint256);


    function getOrders() external view returns (Order[] memory);


    function getOrder(uint256 _orderId) external view returns (Order memory);


    function isPairAllowed(address _token0, address _token1)
        external
        view
        returns (bool);

}// MIT
pragma solidity 0.8.0;


interface IGammaOperator {

    function isValidVaultId(address _owner, uint256 _vaultId)
        external
        view
        returns (bool);


    function getExcessCollateral(
        MarginVault.Vault memory _vault,
        uint256 _typeVault
    ) external view returns (uint256, bool);


    function getVaultOtokenByVault(MarginVault.Vault memory _vault)
        external
        pure
        returns (address);


    function getVaultOtoken(address _owner, uint256 _vaultId)
        external
        view
        returns (address);


    function getVaultWithDetails(address _owner, uint256 _vaultId)
        external
        view
        returns (
            MarginVault.Vault memory,
            uint256,
            uint256
        );


    function getOtokenCollateral(address _otoken)
        external
        pure
        returns (address);


    function getRedeemPayout(address _otoken, uint256 _amount)
        external
        view
        returns (uint256);


    function getRedeemableAmount(
        address _owner,
        address _otoken,
        uint256 _amount
    ) external view returns (uint256);


    function isSettlementAllowed(address _otoken) external view returns (bool);


    function isOperatorOf(address _owner) external view returns (bool);


    function hasExpiredAndSettlementAllowed(address _otoken)
        external
        view
        returns (bool);

}// UNLICENSED
pragma solidity 0.8.0;

interface IResolver {

    function getProcessableOrders()
        external
        returns (bool canExec, bytes memory execPayload);

}// UNLICENSED
pragma solidity 0.8.0;

interface IUniswapRouter {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

}// MIT
pragma solidity 0.8.0;


contract AutoGammaResolver is IResolver {

    address public redeemer;
    address public uniRouter;

    uint256 public maxSlippage = 50; // 0.5%
    address public owner;

    constructor(address _redeemer, address _uniRouter) {
        redeemer = _redeemer;
        uniRouter = _uniRouter;
        owner = msg.sender;
    }

    function setMaxSlippage(uint256 _maxSlippage) public {

        require(msg.sender == owner && _maxSlippage <= 500); // sanity check max slippage under 5%
        maxSlippage = _maxSlippage;
    }

    function canProcessOrder(uint256 _orderId) public view returns (bool) {

        IAutoGamma.Order memory order = IAutoGamma(redeemer).getOrder(_orderId);

        if (order.isSeller) {
            if (
                !IGammaOperator(redeemer).isValidVaultId(
                    order.owner,
                    order.vaultId
                ) || !IGammaOperator(redeemer).isOperatorOf(order.owner)
            ) return false;

            (
                MarginVault.Vault memory vault,
                uint256 typeVault,

            ) = IGammaOperator(redeemer).getVaultWithDetails(
                order.owner,
                order.vaultId
            );

            try IGammaOperator(redeemer).getVaultOtokenByVault(vault) returns (
                address otoken
            ) {
                if (
                    !IGammaOperator(redeemer).hasExpiredAndSettlementAllowed(
                        otoken
                    )
                ) return false;

                (uint256 payout, bool isValidVault) = IGammaOperator(redeemer)
                    .getExcessCollateral(vault, typeVault);
                if (!isValidVault || payout == 0) return false;

                if (order.toToken != address(0)) {
                    address collateral = IGammaOperator(redeemer)
                        .getOtokenCollateral(otoken);
                    if (
                        !IAutoGamma(redeemer).isPairAllowed(
                            collateral,
                            order.toToken
                        )
                    ) return false;
                }
            } catch {
                return false;
            }
        } else {
            if (
                !IGammaOperator(redeemer).hasExpiredAndSettlementAllowed(
                    order.otoken
                )
            ) return false;

            if (order.toToken != address(0)) {
                address collateral = IGammaOperator(redeemer)
                    .getOtokenCollateral(order.otoken);
                if (
                    !IAutoGamma(redeemer).isPairAllowed(
                        collateral,
                        order.toToken
                    )
                ) return false;
            }
        }

        return true;
    }

    function getOrderPayout(uint256 _orderId)
        public
        view
        returns (address payoutToken, uint256 payoutAmount)
    {

        IAutoGamma.Order memory order = IAutoGamma(redeemer).getOrder(_orderId);

        if (order.isSeller) {
            (
                MarginVault.Vault memory vault,
                uint256 typeVault,

            ) = IGammaOperator(redeemer).getVaultWithDetails(
                order.owner,
                order.vaultId
            );

            address otoken = IGammaOperator(redeemer).getVaultOtokenByVault(
                vault
            );
            payoutToken = IGammaOperator(redeemer).getOtokenCollateral(otoken);

            (payoutAmount, ) = IGammaOperator(redeemer).getExcessCollateral(
                vault,
                typeVault
            );
        } else {
            payoutToken = IGammaOperator(redeemer).getOtokenCollateral(
                order.otoken
            );

            uint256 actualAmount = IGammaOperator(redeemer).getRedeemableAmount(
                order.owner,
                order.otoken,
                order.amount
            );
            payoutAmount = IGammaOperator(redeemer).getRedeemPayout(
                order.otoken,
                actualAmount
            );
        }
    }

    function getProcessableOrders()
        public
        view
        override
        returns (bool canExec, bytes memory execPayload)
    {

        IAutoGamma.Order[] memory orders = IAutoGamma(redeemer).getOrders();

        bytes32[] memory preCheckHashes = new bytes32[](orders.length);
        bytes32[] memory postCheckHashes = new bytes32[](orders.length);

        uint256 orderIdsLength;
        for (uint256 i = 0; i < orders.length; i++) {
            if (
                IAutoGamma(redeemer).shouldProcessOrder(i) &&
                canProcessOrder(i) &&
                !containDuplicateOrderType(orders[i], preCheckHashes)
            ) {
                preCheckHashes[i] = getOrderHash(orders[i]);
                orderIdsLength++;
            }
        }

        if (orderIdsLength > 0) {
            canExec = true;
        }

        uint256 counter;
        uint256[] memory orderIds = new uint256[](orderIdsLength);


            IAutoGamma.ProcessOrderArgs[] memory orderArgs
         = new IAutoGamma.ProcessOrderArgs[](orderIdsLength);
        for (uint256 i = 0; i < orders.length; i++) {
            if (
                IAutoGamma(redeemer).shouldProcessOrder(i) &&
                canProcessOrder(i) &&
                !containDuplicateOrderType(orders[i], postCheckHashes)
            ) {
                postCheckHashes[i] = getOrderHash(orders[i]);
                orderIds[counter] = i;

                if (orders[i].toToken != address(0)) {
                    (
                        address payoutToken,
                        uint256 payoutAmount
                    ) = getOrderPayout(i);

                    payoutAmount =
                        payoutAmount -
                        ((orders[i].fee * payoutAmount) / 10_000);

                    address[] memory path = new address[](2);
                    path[0] = payoutToken;
                    path[1] = orders[i].toToken;

                    uint256[] memory amounts = IUniswapRouter(uniRouter)
                        .getAmountsOut(payoutAmount, path);
                    uint256 amountOutMin = amounts[1] -
                        ((amounts[1] * maxSlippage) / 10_000);

                    orderArgs[counter].swapAmountOutMin = amountOutMin;
                    orderArgs[counter].swapPath = path;
                }

                counter++;
            }
        }

        execPayload = abi.encodeWithSelector(
            IAutoGamma.processOrders.selector,
            orderIds,
            orderArgs
        );
    }

    function containDuplicateOrderType(
        IAutoGamma.Order memory order,
        bytes32[] memory hashes
    ) public pure returns (bool containDuplicate) {

        bytes32 orderHash = getOrderHash(order);

        for (uint256 j = 0; j < hashes.length; j++) {
            if (hashes[j] == orderHash) {
                containDuplicate = true;
                break;
            }
        }
    }

    function getOrderHash(IAutoGamma.Order memory order)
        public
        pure
        returns (bytes32 orderHash)
    {

        if (order.isSeller) {
            orderHash = keccak256(abi.encode(order.owner, order.vaultId));
        } else {
            orderHash = keccak256(abi.encode(order.owner, order.otoken));
        }
    }
}/**
 * UNLICENSED
 */
pragma solidity 0.8.0;

library MarginVault {

    struct Vault {
        address[] shortOtokens;
        address[] longOtokens;
        address[] collateralAssets;
        uint256[] shortAmounts;
        uint256[] longAmounts;
        uint256[] collateralAmounts;
    }
}