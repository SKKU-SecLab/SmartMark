



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





interface IERC3156FlashBorrower {


    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);

}





interface IERC3156FlashLender {


    function maxFlashLoan(
        address token
    ) external view returns (uint256);


    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);


    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

}


pragma solidity >=0.6.5 <0.8.0;


contract FlashBorrower is IERC3156FlashBorrower {

    enum Action {NORMAL, STEAL, REENTER}

    IERC3156FlashLender lender;

    uint256 public flashBalance;
    address public flashInitiator;
    address public flashToken;
    uint256 public flashAmount;
    uint256 public flashFee;

    address public admin;

    constructor(address lender_) public {
        admin = msg.sender;
        lender = IERC3156FlashLender(lender_);
    }
    
    function setLender(address _lender) external{

        require(msg.sender == admin,'!admin');
        lender = IERC3156FlashLender(_lender);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {

        require(
            msg.sender == address(lender),
            "FlashBorrower: Untrusted lender"
        );
        require(
            initiator == address(this),
            "FlashBorrower: External loan initiator"
        );
        Action action = abi.decode(data, (Action)); // Use this to unpack arbitrary data
        flashInitiator = initiator;
        flashToken = token;
        flashAmount = amount;
        flashFee = fee;
        if (action == Action.NORMAL) {
            flashBalance = IERC20(token).balanceOf(address(this));
        } else if (action == Action.STEAL) {
        } else if (action == Action.REENTER) {
            flashBorrow(token, amount * 2);
        }
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function flashBorrow(address token, uint256 amount) public {

        bytes memory data = abi.encode(Action.NORMAL);
        approveRepayment(token, amount);
        lender.flashLoan(this, token, amount, data);
    }

    function flashBorrowAndSteal(address token, uint256 amount) public {

        bytes memory data = abi.encode(Action.STEAL);
        lender.flashLoan(this, token, amount, data);
    }

    function flashBorrowAndReenter(address token, uint256 amount) public {

        bytes memory data = abi.encode(Action.REENTER);
        approveRepayment(token, amount);
        lender.flashLoan(this, token, amount, data);
    }

    function approveRepayment(address token, uint256 amount) public {

        uint256 _allowance =
            IERC20(token).allowance(address(this), address(lender));
        uint256 _fee = lender.flashFee(token, amount);
        uint256 _repayment = amount + _fee;
        IERC20(token).approve(address(lender), 0);
        IERC20(token).approve(address(lender), _allowance + _repayment);
    }

    function transferFromAdmin(
		address _token,
		address _receiver,
		uint256 _amount
	) external  {

        require(msg.sender == admin,'!admin');
		IERC20(_token).transfer(_receiver, _amount);
	}
}