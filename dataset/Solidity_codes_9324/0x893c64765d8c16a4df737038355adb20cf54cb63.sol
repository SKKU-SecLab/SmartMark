

pragma solidity ^0.6.6;

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
}

pragma solidity ^0.6.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

contract TimeLockTokenEscrow is ReentrancyGuard {


    event Lockup(
        uint256 indexed _depositId,
        address indexed _creator,
        address indexed _beneficiary,
        uint256 _amount,
        uint256 _lockedUntil
    );

    event Withdrawal(
        uint256 indexed _depositId,
        address indexed _beneficiary,
        address indexed _caller,
        uint256 _amount
    );

    struct TimeLock {
        address creator;
        uint256 amount;
        uint256 lockedUntil;
    }

    IERC20 public token;

    mapping(uint256 => mapping(address => TimeLock)) public beneficiaryToTimeLock;

    mapping(address => uint256[]) beneficiaryToDepositIds;

    uint256 public depositIdPointer = 0;

    constructor(IERC20 _token) public {
        token = _token;
    }

    function lock(address _beneficiary, uint256 _amount, uint256 _lockedUntil) external nonReentrant {

        require(_beneficiary != address(0), "You cannot lock up tokens for the zero address");
        require(_amount > 0, "Lock up amount of zero tokens is invalid");
        require(token.allowance(msg.sender, address(this)) >= _amount, "The contract does not have enough of an allowance to escrow");

        depositIdPointer = depositIdPointer + 1;

        beneficiaryToDepositIds[_beneficiary].push(depositIdPointer);

        beneficiaryToTimeLock[depositIdPointer][_beneficiary] = TimeLock({
            creator : msg.sender,
            amount : _amount,
            lockedUntil : _lockedUntil
            });

        emit Lockup(depositIdPointer, msg.sender, _beneficiary, _amount, _lockedUntil);

        bool transferSuccess = token.transferFrom(msg.sender, address(this), _amount);
        require(transferSuccess, "Failed to escrow tokens into the contract");
    }

    function withdrawal(uint256 _depositId, address _beneficiary) external nonReentrant {

        TimeLock storage lockup = beneficiaryToTimeLock[_depositId][_beneficiary];
        require(lockup.amount > 0, "There are no tokens locked up for this address");
        require(now >= lockup.lockedUntil, "Tokens are still locked up");

        uint256 transferAmount = lockup.amount;
        lockup.amount = 0;

        emit Withdrawal(_depositId, _beneficiary, msg.sender, transferAmount);

        bool transferSuccess = token.transfer(_beneficiary, transferAmount);
        require(transferSuccess, "Failed to send tokens to the beneficiary");
    }

    function getDepositIdsForBeneficiary(address _beneficiary) external view returns (uint256[] memory depositIds) {

        return beneficiaryToDepositIds[_beneficiary];
    }

    function getLockForDepositIdAndBeneficiary(uint256 _depositId, address _beneficiary)
    external view returns (address _creator, uint256 _amount, uint256 _lockedUntil) {

        TimeLock storage lockup = beneficiaryToTimeLock[_depositId][_beneficiary];
        return (
        lockup.creator,
        lockup.amount,
        lockup.lockedUntil
        );
    }

}