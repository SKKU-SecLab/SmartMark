


pragma solidity 0.6.9;

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




interface IDODOIncentive {

    function triggerIncentive(
        address fromToken,
        address toToken,
        address assetTo
    ) external;

}

contract DODOIncentive is InitializableOwnable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable _DODO_TOKEN_;
    address public _DODO_PROXY_;
    uint256 public dodoPerBlock;
    uint256 public defaultRate = 10;
    mapping(address => uint256) public boosts;

    uint32 public lastRewardBlock;
    uint112 public totalReward;
    uint112 public totalDistribution;


    event SetBoost(address token, uint256 boostRate);
    event SetNewProxy(address dodoProxy);
    event SetPerReward(uint256 dodoPerBlock);
    event SetDefaultRate(uint256 defaultRate);
    event Incentive(address user, uint256 reward);

    constructor(address _dodoToken) public {
        _DODO_TOKEN_ = _dodoToken;
    }


    function changeBoost(address _token, uint256 _boostRate) public onlyOwner {

        require(_token != address(0));
        require(_boostRate + defaultRate <= 1000);
        boosts[_token] = _boostRate;
        emit SetBoost(_token, _boostRate);
    }

    function changePerReward(uint256 _dodoPerBlock) public onlyOwner {

        _updateTotalReward();
        dodoPerBlock = _dodoPerBlock;
        emit SetPerReward(dodoPerBlock);
    }

    function changeDefaultRate(uint256 _defaultRate) public onlyOwner {

        defaultRate = _defaultRate;
        emit SetDefaultRate(defaultRate);
    }

    function changeDODOProxy(address _dodoProxy) public onlyOwner {

        _DODO_PROXY_ = _dodoProxy;
        emit SetNewProxy(_DODO_PROXY_);
    }

    function emptyReward(address assetTo) public onlyOwner {

        uint256 balance = IERC20(_DODO_TOKEN_).balanceOf(address(this));
        IERC20(_DODO_TOKEN_).transfer(assetTo, balance);
    }


    function triggerIncentive(
        address fromToken,
        address toToken,
        address assetTo
    ) external {

        require(msg.sender == _DODO_PROXY_, "DODOIncentive:Access restricted");

        uint256 curTotalDistribution = totalDistribution;
        uint256 fromRate = boosts[fromToken];
        uint256 toRate = boosts[toToken];
        uint256 rate = (fromRate >= toRate ? fromRate : toRate) + defaultRate;
        require(rate <= 1000, "RATE_INVALID");
        
        uint256 _totalReward = _getTotalReward();
        uint256 reward = ((_totalReward - curTotalDistribution) * rate) / 1000;
        uint256 _totalDistribution = curTotalDistribution + reward;

        _update(_totalReward, _totalDistribution);
        if (reward != 0) {
            IERC20(_DODO_TOKEN_).transfer(assetTo, reward);
            emit Incentive(assetTo, reward);
        }
    }

    function _updateTotalReward() internal {

        uint256 _totalReward = _getTotalReward();
        require(_totalReward < uint112(-1), "OVERFLOW");
        totalReward = uint112(_totalReward);
        lastRewardBlock = uint32(block.number);
    }

    function _update(uint256 _totalReward, uint256 _totalDistribution) internal {

        require(
            _totalReward < uint112(-1) && _totalDistribution < uint112(-1) && block.number < uint32(-1),
            "OVERFLOW"
        );
        lastRewardBlock = uint32(block.number);
        totalReward = uint112(_totalReward);
        totalDistribution = uint112(_totalDistribution);
    }

    function _getTotalReward() internal view returns (uint256) {

        if (lastRewardBlock == 0) {
            return totalReward;
        } else {
            return totalReward + (block.number - lastRewardBlock) * dodoPerBlock;
        }
    }


    function incentiveStatus(address fromToken, address toToken)
        external
        view
        returns (
            uint256 reward,
            uint256 baseRate,
            uint256 totalRate,
            uint256 curTotalReward,
            uint256 perBlockReward
        )
    {

        baseRate = defaultRate;
        uint256 fromRate = boosts[fromToken];
        uint256 toRate = boosts[toToken];
        totalRate = (fromRate >= toRate ? fromRate : toRate) + defaultRate;
        uint256 _totalReward = _getTotalReward();
        reward = ((_totalReward - totalDistribution) * totalRate) / 1000;
        curTotalReward = _totalReward - totalDistribution;
        perBlockReward = dodoPerBlock;
    }
}