
pragma solidity ^0.5.8;



contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(
            msg.sender == owner,
            "The function can only be called by the owner"
        );
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
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


    function burn(uint256 amount) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



contract DepositLockerInterface {

    function slash(address _depositorToBeSlashed) public;

}



contract BaseDepositLocker is DepositLockerInterface, Ownable {

    bool public initialized = false;
    bool public deposited = false;


    address public slasher;
    address public depositorsProxy;
    uint public releaseTimestamp;

    mapping(address => bool) public canWithdraw;
    uint numberOfDepositors = 0;
    uint valuePerDepositor;

    event DepositorRegistered(
        address depositorAddress,
        uint numberOfDepositors
    );
    event Deposit(
        uint totalValue,
        uint valuePerDepositor,
        uint numberOfDepositors
    );
    event Withdraw(address withdrawer, uint value);
    event Slash(address slashedDepositor, uint slashedValue);

    modifier isInitialised() {

        require(initialized, "The contract was not initialized.");
        _;
    }

    modifier isDeposited() {

        require(deposited, "no deposits yet");
        _;
    }

    modifier isNotDeposited() {

        require(!deposited, "already deposited");
        _;
    }

    modifier onlyDepositorsProxy() {

        require(
            msg.sender == depositorsProxy,
            "Only the depositorsProxy can call this function."
        );
        _;
    }

    function() external {}

    function registerDepositor(address _depositor)
        public
        isInitialised
        isNotDeposited
        onlyDepositorsProxy
    {

        require(
            canWithdraw[_depositor] == false,
            "can only register Depositor once"
        );
        canWithdraw[_depositor] = true;
        numberOfDepositors += 1;
        emit DepositorRegistered(_depositor, numberOfDepositors);
    }

    function deposit(uint _valuePerDepositor)
        public
        payable
        isInitialised
        isNotDeposited
        onlyDepositorsProxy
    {

        require(numberOfDepositors > 0, "no depositors");
        require(_valuePerDepositor > 0, "_valuePerDepositor must be positive");

        uint depositAmount = numberOfDepositors * _valuePerDepositor;
        require(
            _valuePerDepositor == depositAmount / numberOfDepositors,
            "Overflow in depositAmount calculation"
        );

        valuePerDepositor = _valuePerDepositor;
        deposited = true;
        _receive(depositAmount);
        emit Deposit(depositAmount, valuePerDepositor, numberOfDepositors);
    }

    function withdraw() public isInitialised isDeposited {

        require(
            now >= releaseTimestamp,
            "The deposit cannot be withdrawn yet."
        );
        require(canWithdraw[msg.sender], "cannot withdraw from sender");

        canWithdraw[msg.sender] = false;
        _transfer(msg.sender, valuePerDepositor);
        emit Withdraw(msg.sender, valuePerDepositor);
    }

    function slash(address _depositorToBeSlashed)
        public
        isInitialised
        isDeposited
    {

        require(
            msg.sender == slasher,
            "Only the slasher can call this function."
        );
        require(canWithdraw[_depositorToBeSlashed], "cannot slash address");
        canWithdraw[_depositorToBeSlashed] = false;
        _burn(valuePerDepositor);
        emit Slash(_depositorToBeSlashed, valuePerDepositor);
    }

    function _init(
        uint _releaseTimestamp,
        address _slasher,
        address _depositorsProxy
    ) internal {

        require(!initialized, "The contract is already initialised.");
        require(
            _releaseTimestamp > now,
            "The release timestamp must be in the future"
        );

        releaseTimestamp = _releaseTimestamp;
        slasher = _slasher;
        depositorsProxy = _depositorsProxy;
        initialized = true;
        owner = address(0);
    }

    function _receive(uint amount) internal;


    function _transfer(address payable recipient, uint amount) internal;


    function _burn(uint amount) internal;

}



contract TokenDepositLocker is BaseDepositLocker {

    IERC20 public token;

    function init(
        uint _releaseTimestamp,
        address _slasher,
        address _depositorsProxy,
        IERC20 _token
    ) external onlyOwner {

        BaseDepositLocker._init(_releaseTimestamp, _slasher, _depositorsProxy);
        require(
            address(_token) != address(0),
            "Token contract can not be on the zero address!"
        );
        token = _token;
    }

    function _receive(uint amount) internal {

        require(msg.value == 0, "Token locker contract does not accept ETH");
        token.transferFrom(msg.sender, address(this), amount);
    }

    function _transfer(address payable recipient, uint amount) internal {

        token.transfer(recipient, amount);
    }

    function _burn(uint amount) internal {

        token.burn(amount);
    }
}