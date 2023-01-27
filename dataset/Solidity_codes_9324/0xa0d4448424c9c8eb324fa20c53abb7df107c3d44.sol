
pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity >=0.4.22 <0.8.0;


contract Byx88Payment {

    address payable public owner;
    IERC20 public usdt;

    constructor(address usdtAddress_) public {
        owner = msg.sender;
        usdt = IERC20(usdtAddress_);
    }

    struct Deposit {
        address sender;
        uint256 amount;
        bool reverted;
    }

    Deposit[] deposits;

    function fill() public payable restricted returns (bool) {

        emit FillBalance(msg.value);
        return true;
    }

    function take(uint256 amount) public restricted returns (bool) {

        require(
            address(this).balance >= amount,
            "Payment:Take: InsufficientBalance"
        );
        owner.transfer(amount);
        emit Take(owner, amount);
    }

    function deposit(address source, uint256 amount)
        public
        restricted
        returns (uint256)
    {

        uint256 id = deposits.length;
        bool result = usdt.transferFrom(source, address(this), amount);
        require(result, "Payment: FailedToDeposit");
        deposits.push(Deposit(source, amount, false));
        emit DepositInit(id, amount);
        return id;
    }

    function revert(uint256 id) public restricted returns (bool) {

        deposits[id].reverted = true;
        usdt.transfer(deposits[id].sender, deposits[id].amount);
        emit Revert(id);
        return true;
    }

    function withdraw(
        uint256 ref,
        address to,
        uint256 amount
    ) public restricted returns (bool) {

        usdt.transfer(to, amount);
        emit Withdraw(ref, to, amount);
        return true;
    }

    function getDeposit(uint256 id)
        public
        view
        returns (
            address sender,
            uint256 amount, // in wei
            bool reverted
        )
    {

        Deposit storage d = deposits[id];
        return (d.sender, d.amount, d.reverted);
    }

    function transferOwnership(address payable target) public restricted {

        owner = target;
    }

    modifier restricted() {

        require(msg.sender == owner, "Payment: Forbidden actions");
        _;
    }

    event DepositInit(uint256 id, uint256 amount);

    event Revert(uint256 id);

    event Withdraw(uint256 ref, address to, uint256 amount);

    event FillBalance(uint256 amount);

    event Take(address payable to, uint256 amount);

    event ChangeOwner(address from, address to);
}