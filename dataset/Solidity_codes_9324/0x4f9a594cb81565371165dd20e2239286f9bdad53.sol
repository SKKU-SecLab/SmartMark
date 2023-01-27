



pragma solidity ^0.5.16;

contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


interface IRewardsDistribution {

    struct DistributionData {
        address destination;
        uint amount;
    }

    function authority() external view returns (address);


    function distributions(uint index) external view returns (address destination, uint amount); // DistributionData


    function distributionsLength() external view returns (uint);


    function distributeRewards(uint amount) external returns (bool);

}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}




library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }
}


interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


interface IFeePool {


    function FEE_ADDRESS() external view returns (address);


    function feesAvailable(address account) external view returns (uint, uint);


    function feePeriodDuration() external view returns (uint);


    function isFeesClaimable(address account) external view returns (bool);


    function targetThreshold() external view returns (uint);


    function totalFeesAvailable() external view returns (uint);


    function totalRewardsAvailable() external view returns (uint);


    function claimFees() external returns (bool);


    function claimOnBehalf(address claimingForAddress) external returns (bool);


    function closeCurrentFeePeriod() external;


    function appendAccountIssuanceRecord(
        address account,
        uint lockedAmount,
        uint debtEntryIndex,
        bytes32 currencyKey
    ) external;


    function recordFeePaid(uint pUSDAmount) external;


    function setRewardsToDistribute(uint amount) external;

}








contract RewardsDistribution is Owned, IRewardsDistribution {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    address public authority;

    address public periFinanceProxy;

    address public rewardEscrow;

    address public feePoolProxy;

    DistributionData[] public distributions;

    constructor(
        address _owner,
        address _authority,
        address _periFinanceProxy,
        address _rewardEscrow,
        address _feePoolProxy
    ) public Owned(_owner) {
        authority = _authority;
        periFinanceProxy = _periFinanceProxy;
        rewardEscrow = _rewardEscrow;
        feePoolProxy = _feePoolProxy;
    }


    function setPeriFinanceProxy(address _periFinanceProxy) external onlyOwner {

        periFinanceProxy = _periFinanceProxy;
    }

    function setRewardEscrow(address _rewardEscrow) external onlyOwner {

        rewardEscrow = _rewardEscrow;
    }

    function setFeePoolProxy(address _feePoolProxy) external onlyOwner {

        feePoolProxy = _feePoolProxy;
    }

    function setAuthority(address _authority) external onlyOwner {

        authority = _authority;
    }


    function addRewardDistribution(address destination, uint amount) external onlyOwner returns (bool) {

        require(destination != address(0), "Cant add a zero address");
        require(amount != 0, "Cant add a zero amount");

        DistributionData memory rewardsDistribution = DistributionData(destination, amount);
        distributions.push(rewardsDistribution);

        emit RewardDistributionAdded(distributions.length - 1, destination, amount);
        return true;
    }

    function removeRewardDistribution(uint index) external onlyOwner {

        require(index <= distributions.length - 1, "index out of bounds");

        for (uint i = index; i < distributions.length - 1; i++) {
            distributions[i] = distributions[i + 1];
        }
        distributions.length--;

    }

    function editRewardDistribution(
        uint index,
        address destination,
        uint amount
    ) external onlyOwner returns (bool) {

        require(index <= distributions.length - 1, "index out of bounds");

        distributions[index].destination = destination;
        distributions[index].amount = amount;

        return true;
    }

    function distributeRewards(uint amount) external returns (bool) {

        require(amount > 0, "Nothing to distribute");
        require(msg.sender == authority, "Caller is not authorised");
        require(rewardEscrow != address(0), "RewardEscrow is not set");
        require(periFinanceProxy != address(0), "PeriFinanceProxy is not set");
        require(feePoolProxy != address(0), "FeePoolProxy is not set");
        require(
            IERC20(periFinanceProxy).balanceOf(address(this)) >= amount,
            "RewardsDistribution contract does not have enough tokens to distribute"
        );

        uint remainder = amount;

        for (uint i = 0; i < distributions.length; i++) {
            if (distributions[i].destination != address(0) || distributions[i].amount != 0) {
                remainder = remainder.sub(distributions[i].amount);

                IERC20(periFinanceProxy).transfer(distributions[i].destination, distributions[i].amount);

                bytes memory payload = abi.encodeWithSignature("notifyRewardAmount(uint256)", distributions[i].amount);

                (bool success, ) = distributions[i].destination.call(payload);

                if (!success) {
                }
            }
        }

        IERC20(periFinanceProxy).transfer(rewardEscrow, remainder);

        IFeePool(feePoolProxy).setRewardsToDistribute(remainder);

        emit RewardsDistributed(amount);
        return true;
    }


    function distributionsLength() external view returns (uint) {

        return distributions.length;
    }


    event RewardDistributionAdded(uint index, address destination, uint amount);
    event RewardsDistributed(uint amount);
}