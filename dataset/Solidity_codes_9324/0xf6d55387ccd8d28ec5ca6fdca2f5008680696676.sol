
pragma solidity 0.7.5;

interface IRouter {


    function initialize(bytes calldata data) external;


    function getKey() external pure returns(bytes32);


    event Swapped2(
        bytes16 uuid,
        address partner,
        uint256 feePercent,
        address initiator,
        address indexed beneficiary,
        address indexed srcToken,
        address indexed destToken,
        uint256 srcAmount,
        uint256 receivedAmount,
        uint256 expectedAmount
    );

    event Bought2(
        bytes16 uuid,
        address partner,
        uint256 feePercent,
        address initiator,
        address indexed beneficiary,
        address indexed srcToken,
        address indexed destToken,
        uint256 srcAmount,
        uint256 receivedAmount
    );
}


pragma solidity 0.7.5;

interface IAugustusSwapperV5 {

    function hasRole(bytes32 role, address account) external view returns (bool);

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




pragma solidity >=0.6.0 <0.8.0;




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


pragma solidity 0.7.5;


interface ITokenTransferProxy {


    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        external;

}


pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;





interface IERC20Permit {

    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

}

interface IERC20PermitLegacy {

    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

}

library Utils {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    
    uint256 constant MAX_UINT = type(uint256).max;

    struct SellData {
        address fromToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        Utils.Path[] path;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    struct BuyData {
        address adapter;
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        address payable beneficiary;
        Utils.Route[] route;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    struct MegaSwapSellData {
        address fromToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        Utils.MegaSwapPath[] path;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    struct SimpleData {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address[] callees;
        bytes exchangeData;
        uint256[] startIndexes;
        uint256[] values;
        address payable beneficiary;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    struct Adapter {
        address payable adapter;
        uint256 percent;
        uint256 networkFee;//NOT USED
        Route[] route;
    }

    struct Route {
        uint256 index;//Adapter at which index needs to be used
        address targetExchange;
        uint percent;
        bytes payload;
        uint256 networkFee;//NOT USED - Network fee is associated with 0xv3 trades
    }

    struct MegaSwapPath {
        uint256 fromAmountPercent;
        Path[] path;
    }

    struct Path {
        address to;
        uint256 totalNetworkFee;//NOT USED - Network fee is associated with 0xv3 trades
        Adapter[] adapters;
    }

    function ethAddress() internal pure returns (address) {return ETH_ADDRESS;}


    function maxUint() internal pure returns (uint256) {return MAX_UINT;}


    function approve(
        address addressToApprove,
        address token,
        uint256 amount
    ) internal {

        if (token != ETH_ADDRESS) {
            IERC20 _token = IERC20(token);

            uint allowance = _token.allowance(address(this), addressToApprove);

            if (allowance < amount) {
                _token.safeApprove(addressToApprove, 0);
                _token.safeIncreaseAllowance(addressToApprove, MAX_UINT);
            }
        }
    }

    function transferTokens(
        address token,
        address payable destination,
        uint256 amount
    )
    internal
    {

        if (amount > 0) {
            if (token == ETH_ADDRESS) {
                (bool result, ) = destination.call{value: amount, gas: 10000}("");
                require(result, "Failed to transfer Ether");
            }
            else {
                IERC20(token).safeTransfer(destination, amount);
            }
        }

    }

    function tokenBalance(
        address token,
        address account
    )
    internal
    view
    returns (uint256)
    {

        if (token == ETH_ADDRESS) {
            return account.balance;
        } else {
            return IERC20(token).balanceOf(account);
        }
    }

    function permit(
        address token,
        bytes memory permit
    )
        internal
    {

        if (permit.length == 32 * 7) {
            (bool success,) = token.call(abi.encodePacked(IERC20Permit.permit.selector, permit));
            require(success, "Permit failed");
        }

        if (permit.length == 32 * 8) {
            (bool success,) = token.call(abi.encodePacked(IERC20PermitLegacy.permit.selector, permit));
            require(success, "Permit failed");
        }
    }

}


pragma solidity 0.7.5;



interface IAdapter {


    function initialize(bytes calldata data) external;


    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 networkFee,
        Utils.Route[] calldata route
    )
        external
        payable;

}


pragma solidity 0.7.5;



interface IBuyAdapter {


    function initialize(bytes calldata data) external;


    function buy(
        uint256 index,
        IERC20 fromToken,
        IERC20 toToken,
        uint256 maxFromAmount,
        uint256 toAmount,
        address targetExchange,
        bytes calldata payload
    )
        external
        payable;

}


pragma solidity 0.7.5;


contract AugustusStorage {


    struct FeeStructure {
        uint256 partnerShare;
        bool noPositiveSlippage;
        bool positiveSlippageToUser;
        uint16 feePercent;
        string partnerId;
        bytes data;
    }

    ITokenTransferProxy internal tokenTransferProxy;
    address payable internal feeWallet;
    
    mapping(address => FeeStructure) internal registeredPartners;

    mapping (bytes4 => address) internal selectorVsRouter;
    mapping (bytes32 => bool) internal adapterInitialized;
    mapping (bytes32 => bytes) internal adapterVsData;

    mapping (bytes32 => bytes) internal routerData;
    mapping (bytes32 => bool) internal routerInitialized;


    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    bytes32 public constant ROUTER_ROLE = keccak256("ROUTER_ROLE");

}


pragma solidity 0.7.5;





contract FeeModel is AugustusStorage {

    using SafeMath for uint256;

    uint256 public immutable partnerSharePercent;
    uint256 public immutable maxFeePercent;

    constructor(
        uint256 _partnerSharePercent,
        uint256 _maxFeePercent
    )
        public
    {
        partnerSharePercent = _partnerSharePercent;
        maxFeePercent = _maxFeePercent;
    }

    function takeFeeAndTransferTokens(
        address toToken,
        uint256 expectedAmount,
        uint256 receivedAmount,
        address payable beneficiary,
        address payable partner,
        uint256 feePercent

    )
        internal
    {

        uint256 fee = 0;

        if ( feePercent != 0 && partner != address(0) ) {
            uint256 version = feePercent >> 248;
            if (version == 0) {
                fee = _takeFee(
                    feePercent > maxFeePercent ? maxFeePercent : feePercent,
                    toToken,
                    receivedAmount,
                    expectedAmount,
                    partnerSharePercent,
                    true, //positiveSlippageToUser
                    partner
                );
            } else if (version == 1) {
                uint256 feeBps = feePercent & 0x3FFF;
                fee = _takeFee(
                    feeBps > maxFeePercent ? maxFeePercent : feeBps,
                    toToken,
                    receivedAmount,
                    expectedAmount,
                    partnerSharePercent,
                    (feePercent & (1 << 14)) != 0, //positiveSlippageToUser
                    partner
                );
            }
        }

        uint256 remainingAmount = receivedAmount;

        if (fee == 0) {
            if (remainingAmount > expectedAmount) {
                uint256 positiveSlippageShare =
                    remainingAmount.sub(expectedAmount).div(2);
                remainingAmount = remainingAmount.sub(positiveSlippageShare);
                Utils.transferTokens(toToken, feeWallet, positiveSlippageShare);
            }
        } else {
            remainingAmount = remainingAmount.sub(fee);
        }

        Utils.transferTokens(toToken, beneficiary, remainingAmount);
    }

    function _takeFee(
        uint256 feePercent,
        address toToken,
        uint256 receivedAmount,
        uint256 expectedAmount,
        uint256 partnerSharePercent,
        bool positiveSlippageToUser,
        address payable partner
    )
        private
        returns(uint256 fee)
    {

        uint256 partnerShare = 0;
        uint256 paraswapShare = 0;

        bool takeSlippage = feePercent <= 50 && receivedAmount > expectedAmount;

        if (feePercent > 0) {
            fee = (takeSlippage ? expectedAmount : receivedAmount)
                .mul(feePercent).div(10000);
            partnerShare = fee.mul(partnerSharePercent).div(10000);
            paraswapShare = fee.sub(partnerShare);
        }

        if (takeSlippage) {
            uint256 halfPositiveSlippage =
                receivedAmount.sub(expectedAmount).div(2);
            paraswapShare = paraswapShare.add(halfPositiveSlippage);
            fee = fee.add(halfPositiveSlippage);

            if (!positiveSlippageToUser) {
                partnerShare = partnerShare.add(halfPositiveSlippage);
                fee = fee.add(halfPositiveSlippage);
            }
        }

        Utils.transferTokens(toToken, partner, partnerShare);
        Utils.transferTokens(toToken, feeWallet, paraswapShare);

        return (fee);
    }
}


pragma solidity 0.7.5;







contract MultiPath is FeeModel, IRouter {

    using SafeMath for uint256;

    constructor(
        uint256 _partnerSharePercent,
        uint256 _maxFeePercent
    )
        FeeModel(
            _partnerSharePercent,
            _maxFeePercent
        )
        public
    {

    }

    function initialize(bytes calldata data) override external {

        revert("METHOD NOT IMPLEMENTED");
    }

    function getKey() override external pure returns(bytes32) {

        return keccak256(abi.encodePacked("MULTIPATH_ROUTER", "1.0.0"));
    }

    function multiSwap(
        Utils.SellData memory data
    )
        public
        payable
        returns (uint256)
    {   

        require(data.deadline >= block.timestamp, "Deadline breached");

        address fromToken = data.fromToken;
        uint256 fromAmount = data.fromAmount;
        require(msg.value == (fromToken == Utils.ethAddress() ? fromAmount : 0),
            "Incorrect msg.value");
        uint256 toAmount = data.toAmount;
        uint256 expectedAmount = data.expectedAmount;
        address payable beneficiary = data.beneficiary == address(0) ? msg.sender : data.beneficiary;
        Utils.Path[] memory path = data.path;
        address toToken = path[path.length - 1].to;

        require(toAmount > 0, "To amount can not be 0");

        transferTokensFromProxy(fromToken, fromAmount, data.permit);

        performSwap(
            fromToken,
            fromAmount,
            path
        );

        uint256 receivedAmount = Utils.tokenBalance(
            toToken,
            address(this)
        );

        require(
            receivedAmount >= toAmount,
            "Received amount of tokens are less then expected"
        );


        takeFeeAndTransferTokens(
            toToken,
            expectedAmount,
            receivedAmount,
            beneficiary,
            data.partner,
            data.feePercent
        );

        emit Swapped2(
            data.uuid,
            data.partner,
            data.feePercent,
            msg.sender,
            beneficiary,
            fromToken,
            toToken,
            fromAmount,
            receivedAmount,
            expectedAmount
        );

        return receivedAmount;
    }

    function buy(
        Utils.BuyData memory data
    )
        public
        payable
        returns (uint256)
    {

        require(data.deadline >= block.timestamp, "Deadline breached");

        address fromToken = data.fromToken;
        uint256 fromAmount = data.fromAmount;
        require(msg.value == (fromToken == Utils.ethAddress() ? fromAmount : 0),
            "Incorrect msg.value");
        uint256 toAmount = data.toAmount;
        address payable beneficiary = data.beneficiary == address(0) ? msg.sender : data.beneficiary;
        Utils.Route[] memory route = data.route;
        address toToken = data.toToken;

        require(toAmount > 0, "To amount can not be 0");
        
        transferTokensFromProxy(fromToken, fromAmount, data.permit);

        uint256 receivedAmount = performBuy(
            data.adapter,
            fromToken,
            toToken,
            fromAmount,
            toAmount,
            route
        );

        takeFeeAndTransferTokens(
            toToken,
            toAmount,
            receivedAmount,
            beneficiary,
            data.partner,
            data.feePercent
        );

        uint256 remainingAmount = Utils.tokenBalance(
            fromToken,
            address(this)
        );

        if (remainingAmount > 0) {
            Utils.transferTokens(fromToken, msg.sender, remainingAmount);
        }

        emit Bought2(
            data.uuid,
            data.partner,
            data.feePercent,
            msg.sender,
            beneficiary,
            fromToken,
            toToken,
            fromAmount,
            receivedAmount
        );

        return receivedAmount;
    }

    function megaSwap(
        Utils.MegaSwapSellData memory data
    )
        public
        payable
        returns (uint256)
    {

        require(data.deadline >= block.timestamp, "Deadline breached");
        address fromToken = data.fromToken;
        uint256 fromAmount = data.fromAmount;
        require(msg.value == (fromToken == Utils.ethAddress() ? fromAmount : 0),
            "Incorrect msg.value");
        uint256 toAmount = data.toAmount;
        uint256 expectedAmount = data.expectedAmount;
        address payable beneficiary = data.beneficiary == address(0) ? msg.sender : data.beneficiary;
        Utils.MegaSwapPath[] memory path = data.path;
        address toToken = path[0].path[path[0].path.length - 1].to;

        require(toAmount > 0, "To amount can not be 0");

        transferTokensFromProxy(fromToken, fromAmount, data.permit);

        for (uint8 i = 0; i < uint8(path.length); i++) {
            uint256 _fromAmount = fromAmount.mul(path[i].fromAmountPercent).div(10000);
            if (i == path.length - 1) {
                _fromAmount = Utils.tokenBalance(address(fromToken), address(this));
            }
            performSwap(
                fromToken,
                _fromAmount,
                path[i].path
            );
        }

        uint256 receivedAmount = Utils.tokenBalance(
            toToken,
            address(this)
        );

        require(
            receivedAmount >= toAmount,
            "Received amount of tokens are less then expected"
        );


        takeFeeAndTransferTokens(
            toToken,
            expectedAmount,
            receivedAmount,
            beneficiary,
            data.partner,
            data.feePercent
        );

        emit Swapped2(
            data.uuid,
            data.partner,
            data.feePercent,
            msg.sender,
            beneficiary,
            fromToken,
            toToken,
            fromAmount,
            receivedAmount,
            expectedAmount
        );

        return receivedAmount;
    }

    function performSwap(
        address fromToken,
        uint256 fromAmount,
        Utils.Path[] memory path
    )
        private
    {


        require(path.length > 0, "Path not provided for swap");

        for (uint i = 0; i < path.length; i++) {
            address _fromToken = i > 0 ? path[i - 1].to : fromToken;
            address _toToken = path[i].to;

            uint256 _fromAmount = i > 0 ? Utils.tokenBalance(_fromToken, address(this)) : fromAmount;

            for (uint j = 0; j < path[i].adapters.length; j++) {
                Utils.Adapter memory adapter = path[i].adapters[j];

                require(
                    IAugustusSwapperV5(address(this)).hasRole(WHITELISTED_ROLE, adapter.adapter),
                    "Exchange not whitelisted"
                );

                uint fromAmountSlice =
                    i > 0 && j == path[i].adapters.length.sub(1)
                    ? Utils.tokenBalance(address(_fromToken), address(this))
                    : _fromAmount.mul(adapter.percent).div(10000);

                (bool success,) = adapter.adapter.delegatecall(
                    abi.encodeWithSelector(
                        IAdapter.swap.selector,
                        _fromToken,
                        _toToken,
                        fromAmountSlice,
                        uint256(0), //adapter.networkFee,
                        adapter.route
                    )
                );

                require(success, "Call to adapter failed");
            }
        }
    }

    function performBuy(
        address adapter,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount,
        Utils.Route[] memory routes
    )
        private
        returns(uint256)
    {


        require(
            IAugustusSwapperV5(address(this)).hasRole(WHITELISTED_ROLE, adapter),
            "Exchange not whitelisted"
        );

        for (uint j = 0; j < routes.length; j++) {
            Utils.Route memory route = routes[j];

            uint fromAmountSlice;
            uint toAmountSlice;

            if (j == routes.length.sub(1)) {

                toAmountSlice = toAmount.sub(Utils.tokenBalance(address(toToken), address(this)));

                fromAmountSlice = Utils.tokenBalance(address(fromToken), address(this));
            }
            else {
                fromAmountSlice = fromAmount.mul(route.percent).div(10000);
                toAmountSlice = toAmount.mul(route.percent).div(10000);
            }

            (bool success,) = adapter.delegatecall(
                abi.encodeWithSelector(
                    IBuyAdapter.buy.selector,
                    route.index,
                    fromToken,
                    toToken,
                    fromAmountSlice,
                    toAmountSlice,
                    route.targetExchange,
                    route.payload
                )
            );
            require(success, "Call to adapter failed");
        }

        uint256 receivedAmount = Utils.tokenBalance(
            toToken,
            address(this)
        );
        require(
            receivedAmount >= toAmount,
            "Received amount of tokens are less then expected tokens"
        );

        return receivedAmount;
    }

    function transferTokensFromProxy(
        address token,
        uint256 amount,
        bytes memory permit
    )
      private
    {

        if (token != Utils.ethAddress()) {
            Utils.permit(token, permit);
            tokenTransferProxy.transferFrom(
                token,
                msg.sender,
                address(this),
                amount
            );
        }
    }
}