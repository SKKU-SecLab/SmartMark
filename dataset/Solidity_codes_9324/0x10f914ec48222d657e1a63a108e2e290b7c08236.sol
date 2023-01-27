


pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

interface IDODOApprove {

    function claimTokens(address token,address who,address dest,uint256 amount) external;

    function getDODOProxy() external view returns (address);

}



contract InitializableOwnable {

    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier notInitialized() {

        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    function initOwner(address newOwner) public notInitialized {

        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}



interface IDODOApproveProxy {

    function isAllowedProxy(address _proxy) external view returns (bool);

    function claimTokens(address token,address who,address dest,uint256 amount) external;

}

contract DODOApproveProxy is InitializableOwnable {

    
    uint256 private constant _TIMELOCK_DURATION_ = 3 days;
    mapping (address => bool) public _IS_ALLOWED_PROXY_;
    uint256 public _TIMELOCK_;
    address public _PENDING_ADD_DODO_PROXY_;
    address public immutable _DODO_APPROVE_;

    modifier notLocked() {

        require(
            _TIMELOCK_ <= block.timestamp,
            "SetProxy is timelocked"
        );
        _;
    }

    constructor(address dodoApporve) public {
        _DODO_APPROVE_ = dodoApporve;
    }

    function init(address owner, address[] memory proxies) external {

        initOwner(owner);
        for(uint i = 0; i < proxies.length; i++) 
            _IS_ALLOWED_PROXY_[proxies[i]] = true;
    }

    function unlockAddProxy(address newDodoProxy) public onlyOwner {

        _TIMELOCK_ = block.timestamp + _TIMELOCK_DURATION_;
        _PENDING_ADD_DODO_PROXY_ = newDodoProxy;
    }

    function lockAddProxy() public onlyOwner {

       _PENDING_ADD_DODO_PROXY_ = address(0);
       _TIMELOCK_ = 0;
    }


    function addDODOProxy() external onlyOwner notLocked() {

        _IS_ALLOWED_PROXY_[_PENDING_ADD_DODO_PROXY_] = true;
        lockAddProxy();
    }

    function removeDODOProxy (address oldDodoProxy) public onlyOwner {
        _IS_ALLOWED_PROXY_[oldDodoProxy] = false;
    }
    
    function claimTokens(
        address token,
        address who,
        address dest,
        uint256 amount
    ) external {

        require(_IS_ALLOWED_PROXY_[msg.sender], "DODOApproveProxy:Access restricted");
        IDODOApprove(_DODO_APPROVE_).claimTokens(
            token,
            who,
            dest,
            amount
        );
    }

    function isAllowedProxy(address _proxy) external view returns (bool) {

        return _IS_ALLOWED_PROXY_[_proxy];
    }
}



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}




interface IWETH {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);


    function deposit() external payable;


    function withdraw(uint256 wad) external;

}



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}



library SafeERC20 {

    using SafeMath for uint256;

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

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {



        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(
        IERC20 token,
        address payable to,
        uint256 amount
    ) internal {

        if (amount > 0) {
            if (isETH(token)) {
                to.transfer(amount);
            } else {
                token.safeTransfer(to, amount);
            }
        }
    }

    function universalApproveMax(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        uint256 allowance = token.allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                token.safeApprove(to, 0);
            }
            token.safeApprove(to, uint256(-1));
        }
    }

    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {

        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function tokenBalanceOf(IERC20 token, address who) internal view returns (uint256) {

        return token.balanceOf(who);
    }

    function isETH(IERC20 token) internal pure returns (bool) {

        return token == ETH_ADDRESS;
    }
}



interface IDODOAdapter {

    
    function sellBase(address to, address pool, bytes memory data) external;


    function sellQuote(address to, address pool, bytes memory data) external;

}




contract DODORouteProxy {

    using SafeMath for uint256;
    using UniversalERC20 for IERC20;


    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable _WETH_;
    address public immutable _DODO_APPROVE_PROXY_;

    struct PoolInfo {
        uint256 direction;
        uint256 poolEdition;
        uint256 weight;
        address pool;
        address adapter;
        bytes moreInfo;
    }


     event OrderHistory(
        address fromToken,
        address toToken,
        address sender,
        uint256 fromAmount,
        uint256 returnAmount
    );


    modifier judgeExpired(uint256 deadLine) {

        require(deadLine >= block.timestamp, "DODORouteProxy: EXPIRED");
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    constructor (
        address payable weth,
        address dodoApproveProxy
    ) public {
        _WETH_ = weth;
        _DODO_APPROVE_PROXY_ = dodoApproveProxy;
    }

    function mixSwap(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory mixAdapters,
        address[] memory mixPairs,
        address[] memory assetTo,
        uint256 directions,
        bytes[] memory moreInfos,
        uint256 deadLine
    ) external payable judgeExpired(deadLine) returns (uint256 returnAmount) {

        require(mixPairs.length > 0, "DODORouteProxy: PAIRS_EMPTY");
        require(mixPairs.length == mixAdapters.length, "DODORouteProxy: PAIR_ADAPTER_NOT_MATCH");
        require(mixPairs.length == assetTo.length - 1, "DODORouteProxy: PAIR_ASSETTO_NOT_MATCH");
        require(minReturnAmount > 0, "DODORouteProxy: RETURN_AMOUNT_ZERO");

        if(fromToken == _ETH_ADDRESS_) {
            require(msg.value == fromTokenAmount, "DODORouteProxy: MSG_VALUE_NOT_MATCH");
        }

        address _fromToken = fromToken;
        address _toToken = toToken;
        uint256 _fromTokenAmount = fromTokenAmount;
        
        uint256 toTokenOriginBalance = IERC20(_toToken).universalBalanceOf(msg.sender);
        
        _deposit(msg.sender, assetTo[0], _fromToken, _fromTokenAmount, _fromToken == _ETH_ADDRESS_);

        for (uint256 i = 0; i < mixPairs.length; i++) {
            if (directions & 1 == 0) {
                IDODOAdapter(mixAdapters[i]).sellBase(assetTo[i + 1],mixPairs[i], moreInfos[i]);
            } else {
                IDODOAdapter(mixAdapters[i]).sellQuote(assetTo[i + 1],mixPairs[i], moreInfos[i]);
            }
            directions = directions >> 1;
        }

        if(_toToken == _ETH_ADDRESS_) {
            returnAmount = IWETH(_WETH_).balanceOf(address(this));
            IWETH(_WETH_).withdraw(returnAmount);
            msg.sender.transfer(returnAmount);
        }else {
            returnAmount = IERC20(_toToken).tokenBalanceOf(msg.sender).sub(toTokenOriginBalance);
        }

        require(returnAmount >= minReturnAmount, "DODORouteProxy: Return amount is not enough");

        emit OrderHistory(
            _fromToken,
            _toToken,
            msg.sender,
            _fromTokenAmount,
            returnAmount
        );
    }

    function dodoMutliSwap(
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        uint256[] memory totalWeight,
        uint256[] memory splitNumber,
        address[] memory midToken,
        address[] memory assetFrom,
        bytes[] memory sequence,
        uint256 deadLine
    ) external payable judgeExpired(deadLine) returns (uint256 returnAmount) {

        require(assetFrom.length == splitNumber.length, 'DODORouteProxy: PAIR_ASSETTO_NOT_MATCH');        
        require(minReturnAmount > 0, "DODORouteProxy: RETURN_AMOUNT_ZERO");
        
        uint256 _fromTokenAmount = fromTokenAmount;
        address fromToken = midToken[0];
        address toToken = midToken[midToken.length - 1];

        if(fromToken == _ETH_ADDRESS_) {
            require(msg.value == _fromTokenAmount, "DODORouteProxy: MSG_VALUE_NOT_MATCH");
        }

        uint256 toTokenOriginBalance = IERC20(toToken).universalBalanceOf(msg.sender);
        _deposit(msg.sender, assetFrom[0], fromToken, _fromTokenAmount, fromToken == _ETH_ADDRESS_);

        _multiSwap(totalWeight, midToken, splitNumber, sequence, assetFrom);
    
        if(toToken == _ETH_ADDRESS_) {
            returnAmount = IWETH(_WETH_).balanceOf(address(this));
            IWETH(_WETH_).withdraw(returnAmount);
            msg.sender.transfer(returnAmount);
        }else {
            returnAmount = IERC20(toToken).tokenBalanceOf(msg.sender).sub(toTokenOriginBalance);
        }

        require(returnAmount >= minReturnAmount, "DODORouteProxy: Return amount is not enough");
    
        emit OrderHistory(
            fromToken,
            toToken,
            msg.sender,
            _fromTokenAmount,
            returnAmount
        );    
    }

    

    function _multiSwap(
        uint256[] memory totalWeight,
        address[] memory midToken,
        uint256[] memory splitNumber,
        bytes[] memory swapSequence,
        address[] memory assetFrom
    ) internal { 

        for(uint256 i = 1; i < splitNumber.length; i++) { 
            uint256 curTotalAmount = IERC20(midToken[i]).tokenBalanceOf(assetFrom[i-1]);
            uint256 curTotalWeight = totalWeight[i-1];
            
            for(uint256 j = splitNumber[i-1]; j < splitNumber[i]; j++) {
                PoolInfo memory curPoolInfo;
                {
                    (address pool, address adapter, uint256 mixPara, bytes memory moreInfo) = abi.decode(swapSequence[j], (address, address, uint256, bytes));
                
                    curPoolInfo.direction = mixPara >> 17;
                    curPoolInfo.weight = (0xffff & mixPara) >> 9;
                    curPoolInfo.poolEdition = (0xff & mixPara);
                    curPoolInfo.pool = pool;
                    curPoolInfo.adapter = adapter;
                    curPoolInfo.moreInfo = moreInfo;
                }

                if(assetFrom[i-1] == address(this)) {
                    uint256 curAmount = curTotalAmount.mul(curPoolInfo.weight).div(curTotalWeight);
            
                    if(curPoolInfo.poolEdition == 1) {   
                        IERC20(midToken[i]).transfer(curPoolInfo.adapter, curAmount);
                    } else {
                        IERC20(midToken[i]).transfer(curPoolInfo.pool, curAmount);
                    }
                }
                
                if(curPoolInfo.direction == 0) {
                    IDODOAdapter(curPoolInfo.adapter).sellBase(assetFrom[i], curPoolInfo.pool, curPoolInfo.moreInfo);
                } else {
                    IDODOAdapter(curPoolInfo.adapter).sellQuote(assetFrom[i], curPoolInfo.pool, curPoolInfo.moreInfo);
                }
            }
        }
    }

    function _deposit(
        address from,
        address to,
        address token,
        uint256 amount,
        bool isETH
    ) internal {

        if (isETH) {
            if (amount > 0) {
                IWETH(_WETH_).deposit{value: amount}();
                if (to != address(this)) SafeERC20.safeTransfer(IERC20(_WETH_), to, amount);
            }
        } else {
            IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(token, from, to, amount);
        }
    }
}