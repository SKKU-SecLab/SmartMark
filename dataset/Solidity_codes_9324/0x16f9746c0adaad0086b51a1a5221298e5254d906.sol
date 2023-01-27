
pragma solidity 0.8.13;




interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}
abstract contract Owned {

    event OwnerUpdated(address indexed user, address indexed newOwner);


    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }


    constructor(address _owner) {
        owner = _owner;

        emit OwnerUpdated(address(0), _owner);
    }


    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}
interface ICNV is IERC20 {

    function mint(address account, uint256 amount) external;

}

contract RedeemBBT is Owned {




    event Paused(
        bool _paused
    );

    event Redemption(
        address indexed _from,
        address indexed _who,
        uint256 indexed _amount
    );


    bool public paused;
    address public immutable bbtCNV;
    address public immutable CNV;
    mapping(address => uint256) public redeemed;



    constructor(
        address _bbtCNV,
        address _CNV
    ) Owned(msg.sender) {
        bbtCNV = _bbtCNV;
        CNV = _CNV;
    }


    function setPause(bool _paused) external onlyOwner {

        paused = _paused;

        emit Paused(_paused);
    }


    function redeem(
        uint256 _amount,
        address _who,
        address _to,
        bool _max
    ) external returns (uint256 amountOut) {

        require(!paused, "PAUSED");
        uint256 bbtCNVBalance = IERC20(bbtCNV).balanceOf(_who);
        uint256 amountRedeemed = redeemed[_who];
        require(bbtCNVBalance > amountRedeemed, "NONE_LEFT");

        if (_who != msg.sender)
            require(
                IERC20(bbtCNV).allowance(_who,msg.sender) >= bbtCNVBalance,
                "!ALLOWED"
            );

        uint256 currentTime = block.timestamp;
        require(currentTime >= 1654041600,"!VESTING");
        uint256 amountVested;
        if (currentTime > 1679961600) {
            amountVested = bbtCNVBalance;
        } else {
            uint256 vpct = vestedPercent(currentTime);
            amountVested = bbtCNVBalance * vpct / 1e18;
        }
        require(amountVested > amountRedeemed, "NONE_LEFT");

        uint256 amountRedeemable = amountVested - amountRedeemed;
        amountOut = amountRedeemable;
        if (!_max) {
            require(amountRedeemable >= _amount,"EXCEEDS");
            amountOut = _amount;
        }

        redeemed[_who] = amountRedeemed + amountOut;

        ICNV(CNV).transfer(_to, amountOut);

        emit Redemption(
            msg.sender,
            _who,
            amountOut
        );
    }


    function redeemable(
        address _who
    ) external view returns (uint256) {

        uint256 bbtCNVBalance = IERC20(bbtCNV).balanceOf(_who);
        uint256 amountRedeemed = redeemed[_who];
        if (bbtCNVBalance == amountRedeemed) return 0;

        uint256 currentTime = block.timestamp;
        if (currentTime < 1654041600) return 0;

        uint256 amountVested;
        if (currentTime > 1679961600) {
            amountVested = bbtCNVBalance;
        } else {
            uint256 vpct = vestedPercent(currentTime);
            amountVested = bbtCNVBalance * vpct / 1e18;
        }
        if (amountVested <= amountRedeemed) return 0;

        return amountVested - amountRedeemed;
    }

    function vestedPercent(
        uint256 _time
    ) public pure returns(uint256 vpct) {


        uint256 vestingTimeStart    = 1654041600;
        uint256 vestingTimeLength   = 25920000;
        uint256 vestingAmountStart  = 2e16;
        uint256 vestingAmountLength = 98e16;

        uint256 pctOf = _percentOf(vestingTimeStart, _time, vestingTimeLength);
        vpct = _linearMapping(vestingAmountStart, pctOf, vestingAmountLength);
    }


    function _percentOf(
        uint256 _start,
        uint256 _point,
        uint256 _length
    ) internal pure returns (uint256 elapsedPct) {

        uint256 elapsed             = _point - _start;
                elapsedPct          = elapsed * 1e18 / _length;
    }

    function _linearMapping(
        uint256 _start,
        uint256 _pct,
        uint256 _length
    ) internal pure returns(uint256 point) {

        uint256 elapsed             = _length * _pct / 1e18;
                point               = _start + elapsed;
    }
}