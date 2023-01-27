
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
}// UNLICENSED

pragma solidity 0.6.12;


contract LendFlareGaugeModel {

    using SafeMath for uint256;

    struct GaugeModel {
        address gauge;
        uint256 weight;
        bool shutdown;
    }

    address[] public gauges;
    address public owner;
    address public supplyExtraReward;

    mapping(address => GaugeModel) public gaugeWeights;

    event AddGaguge(address indexed gauge, uint256 weight);
    event ToggleGauge(address indexed gauge, bool enabled);
    event UpdateGaugeWeight(address indexed gauge, uint256 weight);
    event SetOwner(address owner);

    modifier onlyOwner() {

        require(
            owner == msg.sender,
            "LendFlareGaugeModel: caller is not the owner"
        );
        _;
    }

    function setOwner(address _owner) public onlyOwner {

        owner = _owner;

        emit SetOwner(_owner);
    }

    constructor() public {
        owner = msg.sender;
    }

    function setSupplyExtraReward(address _v) public onlyOwner {

        require(_v != address(0), "!_v");

        supplyExtraReward = _v;
    }

    function addGauge(address _gauge, uint256 _weight) public {

        require(
            msg.sender == supplyExtraReward,
            "LendFlareGaugeModel: !authorized addGauge"
        );

        gauges.push(_gauge);

        gaugeWeights[_gauge] = GaugeModel({
            gauge: _gauge,
            weight: _weight,
            shutdown: false
        });
    }

    function updateGaugeWeight(address _gauge, uint256 _newWeight)
        public
        onlyOwner
    {

        require(_gauge != address(0), "LendFlareGaugeModel:: !_gauge");
        require(
            gaugeWeights[_gauge].gauge == _gauge,
            "LendFlareGaugeModel: !found"
        );

        gaugeWeights[_gauge].weight = _newWeight;

        emit UpdateGaugeWeight(_gauge, gaugeWeights[_gauge].weight);
    }

    function toggleGauge(address _gauge, bool _state) public {

        require(
            msg.sender == supplyExtraReward,
            "LendFlareGaugeModel: !authorized toggleGauge"
        );

        gaugeWeights[_gauge].shutdown = _state;

        emit ToggleGauge(_gauge, _state);
    }

    function getGaugeWeightShare(address _gauge) public view returns (uint256) {

        uint256 totalWeight;

        for (uint256 i = 0; i < gauges.length; i++) {
            if (!gaugeWeights[gauges[i]].shutdown) {
                totalWeight = totalWeight.add(gaugeWeights[gauges[i]].weight);
            }
        }

        return gaugeWeights[_gauge].weight.mul(1e18).div(totalWeight);
    }

    function gaugesLength() public view returns (uint256) {

        return gauges.length;
    }
}