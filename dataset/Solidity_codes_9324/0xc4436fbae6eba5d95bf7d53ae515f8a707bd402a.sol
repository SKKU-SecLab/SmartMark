


pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

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


library DecimalMath {

    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d).divCeil(10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(10**18).divCeil(d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {

        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {

        return uint256(10**36).divCeil(target);
    }
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



interface IDODOApprove {

    function claimTokens(address token,address who,address dest,uint256 amount) external;

    function getDODOProxy() external view returns (address);

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




interface IGovernance {

    function getLockedvDODO(address account) external view returns (uint256);

}

interface IDODOCirculationHelper {

    function getCirculation() external view returns (uint256);


    function getDodoWithdrawFeeRatio() external view returns (uint256);

}

contract vDODOToken is InitializableOwnable {

    using SafeMath for uint256;


    string public name = "vDODO Membership Token";
    string public symbol = "vDODO";
    uint8 public decimals = 18;
    mapping(address => mapping(address => uint256)) internal _ALLOWED_;


    address public immutable _DODO_TOKEN_;
    address public immutable _DODO_APPROVE_PROXY_;
    address public immutable _DODO_TEAM_;
    address public _DOOD_GOV_;
    address public _DODO_CIRCULATION_HELPER_;

    bool public _CAN_TRANSFER_;

    uint256 public _DODO_PER_BLOCK_;
    uint256 public constant _SUPERIOR_RATIO_ = 10**17; // 0.1
    uint256 public constant _DODO_RATIO_ = 100; // 100
    uint256 public _DODO_FEE_BURN_RATIO_;

    uint112 public alpha = 10**18; // 1
    uint112 public _TOTAL_BLOCK_DISTRIBUTION_;
    uint32 public _LAST_REWARD_BLOCK_;

    uint256 public _TOTAL_BLOCK_REWARD_;
    uint256 public _TOTAL_STAKING_POWER_;
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint128 stakingPower;
        uint128 superiorSP;
        address superior;
        uint256 credit;
    }


    event MintVDODO(address user, address superior, uint256 mintDODO);
    event RedeemVDODO(address user, uint256 receiveDODO, uint256 burnDODO, uint256 feeDODO);
    event DonateDODO(address user, uint256 donateDODO);
    event SetCantransfer(bool allowed);

    event PreDeposit(uint256 dodoAmount);
    event ChangePerReward(uint256 dodoPerBlock);
    event UpdateDODOFeeBurnRatio(uint256 dodoFeeBurnRatio);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);


    modifier canTransfer() {

        require(_CAN_TRANSFER_, "vDODOToken: not allowed transfer");
        _;
    }

    modifier balanceEnough(address account, uint256 amount) {

        require(availableBalanceOf(account) >= amount, "vDODOToken: available amount not enough");
        _;
    }


    constructor(
        address dodoGov,
        address dodoToken,
        address dodoApproveProxy,
        address dodoTeam
    ) public {
        _DOOD_GOV_ = dodoGov;
        _DODO_TOKEN_ = dodoToken;
        _DODO_APPROVE_PROXY_ = dodoApproveProxy;
        _DODO_TEAM_ = dodoTeam;
    }


    function setCantransfer(bool allowed) public onlyOwner {

        _CAN_TRANSFER_ = allowed;
        emit SetCantransfer(allowed);
    }

    function changePerReward(uint256 dodoPerBlock) public onlyOwner {

        _updateAlpha();
        _DODO_PER_BLOCK_ = dodoPerBlock;
        emit ChangePerReward(dodoPerBlock);
    }

    function updateDODOFeeBurnRatio(uint256 dodoFeeBurnRatio) public onlyOwner {

        _DODO_FEE_BURN_RATIO_ = dodoFeeBurnRatio;
        emit UpdateDODOFeeBurnRatio(_DODO_FEE_BURN_RATIO_);
    }

    function updateDODOCirculationHelper(address helper) public onlyOwner {

        _DODO_CIRCULATION_HELPER_ = helper;
    }

    function updateGovernance(address governance) public onlyOwner {

        _DOOD_GOV_ = governance;
    }

    function emergencyWithdraw() public onlyOwner {

        uint256 dodoBalance = IERC20(_DODO_TOKEN_).balanceOf(address(this));
        IERC20(_DODO_TOKEN_).transfer(_OWNER_, dodoBalance);
    }


    function mint(uint256 dodoAmount, address superiorAddress) public {

        require(
            superiorAddress != address(0) && superiorAddress != msg.sender,
            "vDODOToken: Superior INVALID"
        );
        require(dodoAmount > 0, "vDODOToken: must mint greater than 0");

        UserInfo storage user = userInfo[msg.sender];

        if (user.superior == address(0)) {
            require(
                superiorAddress == _DODO_TEAM_ || userInfo[superiorAddress].superior != address(0),
                "vDODOToken: INVALID_SUPERIOR_ADDRESS"
            );
            user.superior = superiorAddress;
        }

        _updateAlpha();

        IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(
            _DODO_TOKEN_,
            msg.sender,
            address(this),
            dodoAmount
        );

        uint256 newStakingPower = DecimalMath.divFloor(dodoAmount, alpha);

        _mint(user, newStakingPower);

        emit MintVDODO(msg.sender, superiorAddress, dodoAmount);
    }

    function redeem(uint256 vdodoAmount, bool all) public balanceEnough(msg.sender, vdodoAmount) {

        _updateAlpha();
        UserInfo storage user = userInfo[msg.sender];

        uint256 dodoAmount;
        uint256 stakingPower;

        if (all) {
            stakingPower = uint256(user.stakingPower).sub(DecimalMath.divFloor(user.credit, alpha));
            dodoAmount = DecimalMath.mulFloor(stakingPower, alpha);
        } else {
            dodoAmount = vdodoAmount.mul(_DODO_RATIO_);
            stakingPower = DecimalMath.divFloor(dodoAmount, alpha);
        }

        _redeem(user, stakingPower);

        (uint256 dodoReceive, uint256 burnDodoAmount, uint256 withdrawFeeDodoAmount) = getWithdrawResult(dodoAmount);

        IERC20(_DODO_TOKEN_).transfer(msg.sender, dodoReceive);
        
        if (burnDodoAmount > 0) {
            IERC20(_DODO_TOKEN_).transfer(address(0), burnDodoAmount);
        }
        
        if (withdrawFeeDodoAmount > 0) {
            alpha = uint112(
                uint256(alpha).add(
                    DecimalMath.divFloor(withdrawFeeDodoAmount, _TOTAL_STAKING_POWER_)
                )
            );
        }

        emit RedeemVDODO(msg.sender, dodoReceive, burnDodoAmount, withdrawFeeDodoAmount);
    }

    function donate(uint256 dodoAmount) public {

        IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(
            _DODO_TOKEN_,
            msg.sender,
            address(this),
            dodoAmount
        );
        alpha = uint112(
            uint256(alpha).add(DecimalMath.divFloor(dodoAmount, _TOTAL_STAKING_POWER_))
        );
        emit DonateDODO(msg.sender, dodoAmount);
    }

    function preDepositedBlockReward(uint256 dodoAmount) public {

        IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(
            _DODO_TOKEN_,
            msg.sender,
            address(this),
            dodoAmount
        );
        _TOTAL_BLOCK_REWARD_ = _TOTAL_BLOCK_REWARD_.add(dodoAmount);
        emit PreDeposit(dodoAmount);
    }


    function totalSupply() public view returns (uint256 vDODOSupply) {

        uint256 totalDODO = IERC20(_DODO_TOKEN_).balanceOf(address(this));
        (,uint256 curDistribution) = getLatestAlpha();
        uint256 actualDODO = totalDODO.sub(_TOTAL_BLOCK_REWARD_.sub(curDistribution.add(_TOTAL_BLOCK_DISTRIBUTION_)));
        vDODOSupply = actualDODO / _DODO_RATIO_;
    }
    
    function balanceOf(address account) public view returns (uint256 vDODOAmount) {

        vDODOAmount = dodoBalanceOf(account) / _DODO_RATIO_;
    }

    function transfer(address to, uint256 vDODOAmount) public returns (bool) {

        _updateAlpha();
        _transfer(msg.sender, to, vDODOAmount);
        return true;
    }

    function approve(address spender, uint256 vDODOAmount) canTransfer public returns (bool) {

        _ALLOWED_[msg.sender][spender] = vDODOAmount;
        emit Approval(msg.sender, spender, vDODOAmount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 vDODOAmount
    ) public returns (bool) {

        require(vDODOAmount <= _ALLOWED_[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");
        _updateAlpha();
        _transfer(from, to, vDODOAmount);
        _ALLOWED_[from][msg.sender] = _ALLOWED_[from][msg.sender].sub(vDODOAmount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _ALLOWED_[owner][spender];
    }


    function getLatestAlpha() public view returns (uint256 newAlpha, uint256 curDistribution) {

        if (_LAST_REWARD_BLOCK_ == 0) {
            curDistribution = 0;
        } else {
            curDistribution = _DODO_PER_BLOCK_ * (block.number - _LAST_REWARD_BLOCK_);
        }
        if (_TOTAL_STAKING_POWER_ > 0) {
            newAlpha = uint256(alpha).add(DecimalMath.divFloor(curDistribution, _TOTAL_STAKING_POWER_));
        } else {
            newAlpha = alpha;
        }
    }

    function availableBalanceOf(address account) public view returns (uint256 vDODOAmount) {

        if (_DOOD_GOV_ == address(0)) {
            vDODOAmount = balanceOf(account);
        } else {
            uint256 lockedvDODOAmount = IGovernance(_DOOD_GOV_).getLockedvDODO(account);
            vDODOAmount = balanceOf(account).sub(lockedvDODOAmount);
        }
    }

    function dodoBalanceOf(address account) public view returns (uint256 dodoAmount) {

        UserInfo memory user = userInfo[account];
        (uint256 newAlpha,) = getLatestAlpha();
        uint256 nominalDodo =  DecimalMath.mulFloor(uint256(user.stakingPower), newAlpha);
        if(nominalDodo > user.credit) {
            dodoAmount = nominalDodo - user.credit;
        }else {
            dodoAmount = 0;
        }
    }

    function getWithdrawResult(uint256 dodoAmount)
        public
        view
        returns (
            uint256 dodoReceive,
            uint256 burnDodoAmount,
            uint256 withdrawFeeDodoAmount
        )
    {

        uint256 feeRatio =
            IDODOCirculationHelper(_DODO_CIRCULATION_HELPER_).getDodoWithdrawFeeRatio();

        withdrawFeeDodoAmount = DecimalMath.mulFloor(dodoAmount, feeRatio);
        dodoReceive = dodoAmount.sub(withdrawFeeDodoAmount);

        burnDodoAmount = DecimalMath.mulFloor(withdrawFeeDodoAmount, _DODO_FEE_BURN_RATIO_);
        withdrawFeeDodoAmount = withdrawFeeDodoAmount.sub(burnDodoAmount);
    }

    function getDODOWithdrawFeeRatio() public view returns (uint256 feeRatio) {

        feeRatio = IDODOCirculationHelper(_DODO_CIRCULATION_HELPER_).getDodoWithdrawFeeRatio();
    }

    function getSuperior(address account) public view returns (address superior) {

        return userInfo[account].superior;
    }


    function _updateAlpha() internal {

        (uint256 newAlpha, uint256 curDistribution) = getLatestAlpha();
        uint256 newTotalDistribution = curDistribution.add(_TOTAL_BLOCK_DISTRIBUTION_);
        require(newAlpha <= uint112(-1) && newTotalDistribution <= uint112(-1), "OVERFLOW");
        alpha = uint112(newAlpha);
        _TOTAL_BLOCK_DISTRIBUTION_ = uint112(newTotalDistribution);
        _LAST_REWARD_BLOCK_ = uint32(block.number);
    }

    function _mint(UserInfo storage to, uint256 stakingPower) internal {

        require(stakingPower <= uint128(-1), "OVERFLOW");
        UserInfo storage superior = userInfo[to.superior];
        uint256 superiorIncreSP = DecimalMath.mulFloor(stakingPower, _SUPERIOR_RATIO_);
        uint256 superiorIncreCredit = DecimalMath.mulFloor(superiorIncreSP, alpha);

        to.stakingPower = uint128(uint256(to.stakingPower).add(stakingPower));
        to.superiorSP = uint128(uint256(to.superiorSP).add(superiorIncreSP));

        superior.stakingPower = uint128(uint256(superior.stakingPower).add(superiorIncreSP));
        superior.credit = uint128(uint256(superior.credit).add(superiorIncreCredit));

        _TOTAL_STAKING_POWER_ = _TOTAL_STAKING_POWER_.add(stakingPower).add(superiorIncreSP);
    }

    function _redeem(UserInfo storage from, uint256 stakingPower) internal {

        from.stakingPower = uint128(uint256(from.stakingPower).sub(stakingPower));

        uint256 superiorDecreSP = DecimalMath.mulFloor(stakingPower, _SUPERIOR_RATIO_);
        superiorDecreSP = from.superiorSP <= superiorDecreSP ? from.superiorSP : superiorDecreSP;
        from.superiorSP = uint128(uint256(from.superiorSP).sub(superiorDecreSP));

        UserInfo storage superior = userInfo[from.superior];
        uint256 creditSP = DecimalMath.divFloor(superior.credit, alpha);

        if (superiorDecreSP >= creditSP) {
            superior.credit = 0;
            superior.stakingPower = uint128(uint256(superior.stakingPower).sub(creditSP));
        } else {
            superior.credit = uint128(
                uint256(superior.credit).sub(DecimalMath.mulFloor(superiorDecreSP, alpha))
            );
            superior.stakingPower = uint128(uint256(superior.stakingPower).sub(superiorDecreSP));
        }

        _TOTAL_STAKING_POWER_ = _TOTAL_STAKING_POWER_.sub(stakingPower).sub(superiorDecreSP);
    }

    function _transfer(
        address from,
        address to,
        uint256 vDODOAmount
    ) internal canTransfer balanceEnough(from, vDODOAmount) {

        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(from != to, "transfer from same with to");

        uint256 stakingPower = DecimalMath.divFloor(vDODOAmount * _DODO_RATIO_, alpha);

        UserInfo storage fromUser = userInfo[from];
        UserInfo storage toUser = userInfo[to];

        _redeem(fromUser, stakingPower);
        _mint(toUser, stakingPower);

        emit Transfer(from, to, vDODOAmount);
    }
}