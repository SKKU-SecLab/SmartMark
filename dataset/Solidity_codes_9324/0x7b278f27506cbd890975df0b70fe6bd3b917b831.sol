
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// UNLICENSED

pragma solidity =0.6.12;


interface ILiquidityGauge {

    function updateReward(address _for) external;


    function totalAccrued(address _for) external view returns (uint256);

}

interface ILendFlareToken {

    function mint(address _for, uint256 amount) external;

}

contract LendFlareTokenMinter is ReentrancyGuard {

    using SafeMath for uint256;

    address public token;
    address public supplyPoolExtraRewardFactory;
    uint256 public launchTime;

    mapping(address => mapping(address => uint256)) public minted; // user -> gauge -> value

    event Minted(address user, address gauge, uint256 amount);

    constructor(
        address _token,
        address _supplyPoolExtraRewardFactory,
        uint256 _launchTime
    ) public {
        require(_launchTime > block.timestamp, "!_launchTime");
        launchTime = _launchTime;
        token = _token;
        supplyPoolExtraRewardFactory = _supplyPoolExtraRewardFactory;
    }

    function _mintFor(address gauge_addr, address _for) internal {

        if (block.timestamp >= launchTime) {
            ILiquidityGauge(gauge_addr).updateReward(_for);

            uint256 total_mint = ILiquidityGauge(gauge_addr).totalAccrued(_for);
            uint256 to_mint = total_mint.sub(minted[_for][gauge_addr]);

            if (to_mint > 0) {
                ILendFlareToken(token).mint(_for, to_mint);
                minted[_for][gauge_addr] = total_mint;

                emit Minted(_for, gauge_addr, total_mint);
            }
        }
    }

    function mintFor(address gauge_addr, address _for) public nonReentrant {

        require(
            msg.sender == supplyPoolExtraRewardFactory,
            "LendFlareTokenMinter: !authorized mintFor"
        );

        _mintFor(gauge_addr, _for);
    }
}