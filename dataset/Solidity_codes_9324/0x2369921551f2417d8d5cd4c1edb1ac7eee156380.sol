
pragma solidity 0.6.12;


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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity 0.6.12;

contract Vesting {

    IERC20 private _token;

    struct VestingStruct {
        uint256 vestedTokens;
        uint256 cliffPeriod;
        uint256 vestingPeriod;
        uint256 vestingStartTime;
        uint256 withdrawalPerDay;
    }

    mapping(address => VestingStruct) public addressInfo;

    mapping(address => uint256) public tokensAlreadyWithdrawn;

    event TokenVested(
        address beneficary,
        uint256 amount,
        uint256 cliffPeriod,
        uint256 vestingPeriod,
        uint256 vestingStartTime,
        uint256 withdrawalPerDay
    );

    event TokenReleased(address beneficary, uint256 amount);

    constructor(IERC20 token_) public {
        _token = token_;
    }

    function token() external view returns (IERC20) {

        return _token;
    }

    function totalTokensVested() external view returns (uint256) {

        return _token.balanceOf(address(this));
    }

    function deposit(
        address beneficiary,
        uint256 amount,
        uint256 cliffPeriod,
        uint256 vestingPeriod
    ) external returns (bool success) {

        VestingStruct memory result = addressInfo[msg.sender];

        require(
            result.vestedTokens == 0,
            "Vesting: Beneficiary already have vested token. Use another address"
        );

        require(
            _token.transferFrom(msg.sender, address(this), amount),
            "Vesting: Please approve token first"
        );

        addressInfo[beneficiary] = VestingStruct(
            amount,
            cliffPeriod,
            vestingPeriod,
            block.timestamp,
            amount / vestingPeriod
        );

        emit TokenVested(
            beneficiary,
            amount,
            cliffPeriod,
            vestingPeriod,
            block.timestamp,
            amount / vestingPeriod
        );

        return true;
    }

    function withdraw() external virtual {

        VestingStruct memory result = addressInfo[msg.sender];

        require(
            result.vestedTokens > 0,
            "Vesting: You don't have any vested token"
        );

        require(
            block.timestamp >=
                (result.vestingStartTime + (result.cliffPeriod * 1 days)),
            "Vesting: Cliff period is not over yet"
        );

        uint256 tokensAvailable = getAvailableTokens(msg.sender);
        uint256 alreadyWithdrawn = tokensAlreadyWithdrawn[msg.sender];

        require(
            tokensAvailable + alreadyWithdrawn <= result.vestedTokens,
            "Vesting: Can't withdraw more than vested token amount"
        );

        if (tokensAvailable + alreadyWithdrawn == result.vestedTokens) {
            tokensAlreadyWithdrawn[msg.sender] = 0;
            addressInfo[msg.sender] = VestingStruct(0, 0, 0, 0, 0);
        } else {
            tokensAlreadyWithdrawn[msg.sender] += tokensAvailable;
        }

        emit TokenReleased(msg.sender, tokensAvailable);

        _token.transfer(msg.sender, tokensAvailable);
    }

    function getAvailableTokens(address beneficiary)
        public
        view
        returns (uint256)
    {

        VestingStruct memory result = addressInfo[beneficiary];

        if (result.vestedTokens > 0) {
            uint256 vestingEndTime =
                (result.vestingStartTime + (result.vestingPeriod * 1 days));

            if (block.timestamp >= vestingEndTime) {
                return
                    result.vestedTokens - tokensAlreadyWithdrawn[beneficiary];
            } else {
                uint256 totalDays =
                    ((
                        block.timestamp > vestingEndTime
                            ? vestingEndTime
                            : block.timestamp
                    ) - result.vestingStartTime) / 1 days;

                return
                    (totalDays * result.withdrawalPerDay) -
                    tokensAlreadyWithdrawn[beneficiary];
            }
        } else {
            return 0;
        }
    }
}