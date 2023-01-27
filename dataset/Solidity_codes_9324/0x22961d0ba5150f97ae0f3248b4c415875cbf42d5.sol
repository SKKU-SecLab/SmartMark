pragma solidity 0.6.12;

contract Ownable {

    address payable public owner;

    address payable public pendingOwner;

    event NewOwner(address indexed previousOwner, address indexed newOwner);
    event NewPendingOwner(
        address indexed oldPendingOwner,
        address indexed newPendingOwner
    );

    modifier onlyOwner() {

        require(owner == msg.sender, "onlyOwner: caller is not the owner");
        _;
    }

    function __Ownable_init() internal {

        owner = msg.sender;
        emit NewOwner(address(0), msg.sender);
    }

    function _setPendingOwner(address payable newPendingOwner)
        external
        onlyOwner
    {

        require(
            newPendingOwner != address(0) && newPendingOwner != pendingOwner,
            "_setPendingOwner: New owenr can not be zero address and owner has been set!"
        );

        address oldPendingOwner = pendingOwner;

        pendingOwner = newPendingOwner;

        emit NewPendingOwner(oldPendingOwner, newPendingOwner);
    }

    function _acceptOwner() external {

        require(
            msg.sender == pendingOwner,
            "_acceptOwner: Only for pending owner!"
        );

        address oldOwner = owner;
        address oldPendingOwner = pendingOwner;

        owner = pendingOwner;

        pendingOwner = address(0);

        emit NewOwner(oldOwner, owner);
        emit NewPendingOwner(oldPendingOwner, pendingOwner);
    }

    uint256[50] private __gap;
}// MIT
pragma solidity 0.6.12;


interface IInterestRateModelClient {

    function updateInterest() external returns (bool);

}

contract FixedInterestRateModel is Ownable {

    uint256 internal constant ratePerBlockMax = 0.001e18;

    uint256 public constant blocksPerYear = 2425846;

    mapping(address => uint256) public borrowRatesPerBlock;

    mapping(address => uint256) public supplyRatesPerBlock;

    event BorrowRateSet(address target, uint256 rate);

    event SupplyRateSet(address target, uint256 rate);

    constructor() public {
        __Ownable_init();
    }


    function isInterestRateModel() external pure returns (bool) {

        return true;
    }

    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) public view returns (uint256) {

        cash;
        borrows;
        reserves;
        return borrowRatesPerBlock[msg.sender];
    }

    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveRatio
    ) external view returns (uint256) {

        cash;
        borrows;
        reserves;
        reserveRatio;
        return supplyRatesPerBlock[msg.sender];
    }

    function _setBorrowRate(address _target, uint256 _rate) public onlyOwner {

        require(_rate <= ratePerBlockMax, "Borrow rate invalid");

        IInterestRateModelClient(_target).updateInterest();

        borrowRatesPerBlock[_target] = _rate;

        emit BorrowRateSet(_target, _rate);
    }

    function _setSupplyRate(address _target, uint256 _rate) public onlyOwner {

        require(_rate <= ratePerBlockMax, "Supply rate invalid");

        IInterestRateModelClient(_target).updateInterest();

        supplyRatesPerBlock[_target] = _rate;

        emit SupplyRateSet(_target, _rate);
    }

    function _setBorrowRates(
        address[] calldata _targets,
        uint256[] calldata _rates
    ) external onlyOwner {

        require(
            _targets.length == _rates.length,
            "Targets and rates length mismatch!"
        );

        uint256 _len = _targets.length;
        for (uint256 i = 0; i < _len; i++) {
            _setBorrowRate(_targets[i], _rates[i]);
        }
    }

    function _setSupplyRates(
        address[] calldata _targets,
        uint256[] calldata _rates
    ) external onlyOwner {

        require(
            _targets.length == _rates.length,
            "Targets and rates length mismatch!"
        );

        uint256 _len = _targets.length;
        for (uint256 i = 0; i < _len; i++) {
            _setSupplyRate(_targets[i], _rates[i]);
        }
    }
}