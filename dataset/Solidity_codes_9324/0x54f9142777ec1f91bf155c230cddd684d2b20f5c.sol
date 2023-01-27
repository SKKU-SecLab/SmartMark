

pragma solidity ^0.5.12;

contract Context {

    constructor() internal {}

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address payable public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address payable msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address payable newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
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

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ReentrancyGuard {

    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call.value(amount)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
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
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface ICurveSwap {

    function coins(int128 arg0) external view returns (address);


    function underlying_coins(int128 arg0) external view returns (address);


    function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount)
        external;


    function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amount)
        external;


    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount,
        bool isUnderLying
    ) external;


    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external;

}

interface ICurveEthSwap {

    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external
        payable
        returns (uint256);

}

interface yERC20 {

    function deposit(uint256 _amount) external;

}

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}

interface ICurveRegistry {

    function metaPools(address tokenAddress)
        external
        view
        returns (address swapAddress);


    function getTokenAddress(address swapAddress)
        external
        view
        returns (address tokenAddress);


    function getPoolTokens(address swapAddress)
        external
        view
        returns (address[4] memory poolTokens);


    function isMetaPool(address swapAddress) external view returns (bool);


    function getNumTokens(address swapAddress)
        external
        view
        returns (uint8 numTokens);


    function isBtcPool(address swapAddress) external view returns (bool);


    function isUnderlyingToken(
        address swapAddress,
        address tokenContractAddress
    ) external view returns (bool, uint8);

}

contract CurveAddLiquidity is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    bool public stopped = false; 
    uint16 public goodwill;

    mapping(address => bool) public feeWhitelist;// if true, goodwill is not deducted
    uint16 affiliateSplit; // % share of goodwill (0-100 %)
    mapping(address => bool) public affiliates; // restrict affiliates
    mapping(address => mapping(address => uint256)) public affiliateBalance; // affiliate => token => amount
    mapping(address => uint256) public totalAffiliateBalance; // token => amount
    address private constant ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    ICurveRegistry public curveReg;

    address private Aave = 0xDeBF20617708857ebe4F679508E7b7863a8A8EeE;

    modifier stopInEmergency {

        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    constructor(
        ICurveRegistry _curveRegistry,
        uint16 _goodwill,
        uint16 _affiliateSplit
    ) public {
        curveReg = _curveRegistry;
        goodwill = _goodwill;
        affiliateSplit = _affiliateSplit;
    }

    event addLiquidity(address sender, address pool, uint256 crvTokens);

    function AddLiquidity(
        address _fromTokenAddress,
        address _toTokenAddress,
        address _swapAddress,
        uint256 _incomingTokenQty,
        uint256 _minPoolTokens,
        address _swapTarget,
        bytes calldata _swapCallData,
        address affiliate
    )
        external
        payable
        stopInEmergency
        nonReentrant
        returns (uint256 crvTokensBought)
    {

        uint256 toInvest = _pullTokens(
            _fromTokenAddress,
            _incomingTokenQty,
            affiliate
        );
        if (_fromTokenAddress == address(0)) {
            _fromTokenAddress = ETHAddress;
        }

        crvTokensBought = _performAddLiquidity(
            _fromTokenAddress,
            _toTokenAddress,
            _swapAddress,
            toInvest,
            _swapTarget,
            _swapCallData
        );

        require(crvTokensBought > _minPoolTokens,"Received less than minPoolTokens");

        address poolTokenAddress = curveReg.getTokenAddress(_swapAddress);

        emit addLiquidity(msg.sender, poolTokenAddress, crvTokensBought);

        IERC20(poolTokenAddress).transfer(msg.sender, crvTokensBought);
    }

    function _performAddLiquidity(
        address _fromTokenAddress,
        address _toTokenAddress,
        address _swapAddress,
        uint256 toInvest,
        address _swapTarget,
        bytes memory _swapCallData
    ) internal returns (uint256 crvTokensBought) {

        (bool isUnderlying, uint8 underlyingIndex) = curveReg.isUnderlyingToken(
            _swapAddress,
            _fromTokenAddress
        );

        if (isUnderlying) {
            crvTokensBought = _enterCurve(
                _swapAddress,
                toInvest,
                underlyingIndex
            );
        } else {
            uint256 tokensBought = _fillQuote(
                _fromTokenAddress,
                _toTokenAddress,
                toInvest,
                _swapTarget,
                _swapCallData
            );
            if (_toTokenAddress == address(0)) _toTokenAddress = ETHAddress;

            (isUnderlying, underlyingIndex) = curveReg.isUnderlyingToken(
                _swapAddress,
                _toTokenAddress
            );

            if (isUnderlying) {
                crvTokensBought = _enterCurve(
                    _swapAddress,
                    tokensBought,
                    underlyingIndex
                );
            } else {
                (uint256 tokens, uint8 metaIndex) = _enterMetaPool(
                    _swapAddress,
                    _toTokenAddress,
                    tokensBought
                );

                crvTokensBought = _enterCurve(_swapAddress, tokens, metaIndex);
            }
        }
    }

    function _pullTokens(
        address token,
        uint256 amount,
        address affiliate
    ) internal returns (uint256) {

        uint256 totalGoodwillPortion;

        if (token == address(0)) {
            require(msg.value > 0, "No eth sent");

            totalGoodwillPortion = _subtractGoodwill(
                ETHAddress,
                msg.value,
                affiliate
            );

            return msg.value.sub(totalGoodwillPortion);
        }
        require(amount > 0, "Invalid token amount");
        require(msg.value == 0, "Eth sent with token");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        totalGoodwillPortion = _subtractGoodwill(token, amount, affiliate);

        return amount.sub(totalGoodwillPortion);
    }

    function _subtractGoodwill(
        address token,
        uint256 amount,
        address affiliate
    ) internal returns (uint256 totalGoodwillPortion) {

        bool whitelisted = feeWhitelist[msg.sender];
        if (!whitelisted && goodwill > 0) {
            totalGoodwillPortion = SafeMath.div(SafeMath.mul(amount, goodwill), 10000);

            if (affiliates[affiliate]) {
                uint256 affiliatePortion = totalGoodwillPortion.mul(affiliateSplit).div(100);
                affiliateBalance[affiliate][token] = affiliateBalance[affiliate][token].add(affiliatePortion);
                totalAffiliateBalance[token] = totalAffiliateBalance[token].add(affiliatePortion);  
            }
        }
    }

    function _enterMetaPool(
        address _swapAddress,
        address _toTokenAddress,
        uint256 swapTokens
    ) internal returns (uint256 tokensBought, uint8 index) {

        address[4] memory poolTokens = curveReg.getPoolTokens(_swapAddress);
        for (uint8 i = 0; i < 4; i++) {
            address intermediateSwapAddress = curveReg.metaPools(poolTokens[i]);
            if (intermediateSwapAddress != address(0)) {
                (, index) = curveReg.isUnderlyingToken(
                    intermediateSwapAddress,
                    _toTokenAddress
                );

                tokensBought = _enterCurve(
                    intermediateSwapAddress,
                    swapTokens,
                    index
                );

                return (tokensBought, i);
            }
        }
    }

    function _fillQuote(
        address _fromTokenAddress,
        address _toTokenAddress,
        uint256 _amount,
        address _swapTarget,
        bytes memory _swapCallData
    ) internal returns (uint256 amountBought) {

        uint256 valueToSend;

        if (_fromTokenAddress == _toTokenAddress) {
            return _amount;
        }

        if (_fromTokenAddress == ETHAddress) {
            valueToSend = _amount;
        } else {
            IERC20 fromToken = IERC20(_fromTokenAddress);

            require(fromToken.balanceOf(address(this)) >= _amount, "Insufficient Balance" );

            fromToken.safeApprove(address(_swapTarget), 0);
            fromToken.safeApprove(address(_swapTarget), _amount);
        }

        uint256 initialBalance = _toTokenAddress == address(0)
            ? address(this).balance
            : IERC20(_toTokenAddress).balanceOf(address(this));

        (bool success, ) = _swapTarget.call.value(valueToSend)(_swapCallData);
        require(success, "Error Swapping Tokens");

        amountBought = _toTokenAddress == address(0)
            ? (address(this).balance).sub(initialBalance)
            : IERC20(_toTokenAddress).balanceOf(address(this)).sub(initialBalance);
                

        require(amountBought > 0, "Swapped To Invalid Intermediate");
    }

    function _enterCurve(address _swapAddress, uint256 amount, uint8 index) internal returns (uint256 crvTokensBought) {

        address tokenAddress = curveReg.getTokenAddress(_swapAddress);
        uint256 initialBalance = IERC20(tokenAddress).balanceOf(address(this));
        address entryToken = curveReg.getPoolTokens(_swapAddress)[index];

        if (entryToken != ETHAddress) {
            IERC20(entryToken).safeIncreaseAllowance(address(_swapAddress), amount);
        }

        uint256 numTokens = curveReg.getNumTokens(_swapAddress);

        if (numTokens == 4) {
            uint256[4] memory amounts;
            amounts[index] = amount;
            ICurveSwap(_swapAddress).add_liquidity(amounts, 0);
        } else if (numTokens == 3) {
            uint256[3] memory amounts;
            amounts[index] = amount;
            if (_swapAddress == Aave) {
                ICurveSwap(_swapAddress).add_liquidity(amounts, 0, true);
            } else {
                ICurveSwap(_swapAddress).add_liquidity(amounts, 0);
            }
        } else {
            uint256[2] memory amounts;
            amounts[index] = amount;
            if (isETHUnderlying(_swapAddress)) {
                ICurveEthSwap(_swapAddress).add_liquidity.value(amount)(amounts,0 );
            } else {
                ICurveSwap(_swapAddress).add_liquidity(amounts, 0);
            }
        }
        crvTokensBought = (IERC20(tokenAddress).balanceOf(address(this))).sub(initialBalance);
    }

    function isETHUnderlying(address _swapAddress) internal view returns (bool){

        address[4] memory poolTokens = curveReg.getPoolTokens(_swapAddress);
        for (uint8 i = 0; i < 4; i++) {
            if (poolTokens[i] == ETHAddress) {
                return true;
            }
        }
        return false;
    }

    function updateAaveAddress(address _newAddress) external onlyOwner {

        require(_newAddress != address(0), "Zero Address");
        Aave = _newAddress;
    }

    function set_new_goodwill(uint16 _new_goodwill) external onlyOwner {

        require(
            _new_goodwill >= 0 && _new_goodwill < 100,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_feeWhitelist(address _address, bool status) external onlyOwner{

        feeWhitelist[_address] = status;
    }

    function updateCurveRegistry(ICurveRegistry newCurveRegistry) external onlyOwner {

        require(newCurveRegistry != curveReg, "Already using this Registry");
        curveReg = newCurveRegistry;
    }

    function toggleContractActive() external onlyOwner {

        stopped = !stopped;
    }

    function set_new_affiliateSplit(uint16 _new_affiliateSplit) external onlyOwner {

        require(_new_affiliateSplit <= 100, "Affiliate Split Value not allowed");
        affiliateSplit = _new_affiliateSplit;
    }

    function set_affiliate(address _affiliate, bool _status) external onlyOwner{

        affiliates[_affiliate] = _status;
    }

    function ownerWithdraw(address[] calldata tokens) external onlyOwner {

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 qty;

            if (tokens[i] == ETHAddress) {
                qty = address(this).balance.sub(totalAffiliateBalance[tokens[i]]);
                Address.sendValue(Address.toPayable(owner()), qty);
            } else {
                qty = IERC20(tokens[i]).balanceOf(address(this)).sub(totalAffiliateBalance[tokens[i]]);
                IERC20(tokens[i]).safeTransfer(owner(), qty);
            }
        }
    }

    function affilliateWithdraw(address[] calldata tokens) external {

        uint256 tokenBal;
        for (uint256 i = 0; i < tokens.length; i++) {
            tokenBal = affiliateBalance[msg.sender][tokens[i]];
            affiliateBalance[msg.sender][tokens[i]] = 0;
            totalAffiliateBalance[tokens[i]] = totalAffiliateBalance[tokens[i]].sub(tokenBal);
                
            if (tokens[i] == ETHAddress) {
                Address.sendValue(msg.sender, tokenBal);
            } else {
                IERC20(tokens[i]).safeTransfer(msg.sender, tokenBal);
            }
        }
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}