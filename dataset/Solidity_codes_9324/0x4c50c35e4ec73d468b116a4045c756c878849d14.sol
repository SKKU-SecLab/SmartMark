

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint bountyValue) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint bountyValue) external returns (bool);

    function transferFrom(address sender, address recipient, uint bountyValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface UniswapRouter {

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory);

}

interface YCrvGauge {

    function deposit(uint256 bountyValue) external;

    function withdraw(uint256 bountyValue) external;

}

interface TokenMinter {

    function mint(address account) external;

}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
   

contract pseudo_svault {


    using SafeMath for uint256;

    IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    UniswapRouter constant UNIROUTER = UniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);  //UniswapV2Router02 is deployed here; https://uniswap.org/docs/v2/smart-contracts/router02/
    YCrvGauge constant YCRVGAUGE = YCrvGauge(0xFA712EE4788C042e2B7BB55E6cb8ec569C4530c1);
    IERC20 constant CRV = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
    TokenMinter constant TOKENMINTER = TokenMinter(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);

    struct Bounty {
        uint256 bountyValue;
        uint256 bountyTimeStamp;
        uint256 totalBountyDeposit;
    }

    mapping(address => uint) public _rewardedBalancePerUser;
    mapping(address => uint) public _lastTimestampPerUser;
    mapping(address => uint) public _depositBalancePerUser;

    uint256 public _totalBountyDeposit;

    Bounty[] public _bounties;

    string public vaultName;
    address public vaultAddress;

    IERC20 public token0;
    IERC20 public token1; // PF deployer address

    address public feeAddress;
    uint32 public feeRate;
    address public treasury;

    bool public isWithdrawable;

    uint256 public rewardUserRate = 7000;
    uint32 public rewardTreasuryRate = 3000;
    uint256 public totalRate = 10000;
    
    uint256 public crv_0;
    uint256 public token_0;
    
    address public gov;

    event Deposited(address indexed user, uint256 bountyValue);
    event ClaimedReward(address indexed user, uint256 bountyValue);
    event Withdrawn(address indexed user, uint256 bountyValue);
    event DistributedBounty(address indexed, uint256 bountyValue);

    constructor (address _token0, address _token1, address _feeAddress, string memory name, address _treasury) payable {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        feeAddress = _feeAddress;
        vaultName = name;
        gov = msg.sender;
        treasury = _treasury;
        token0.approve(address(YCRVGAUGE), type(uint).max);
        CRV.approve(address(UNIROUTER), type(uint).max);
    }

    modifier onlyGov() {

        require(msg.sender == gov, "!governance");
        _;
    }

    function setGovernance(address _gov)
        external
        onlyGov
    {

        gov = _gov;
    }

    function setToken0(address _token)
        external
        onlyGov
    {

        token0 = IERC20(_token);
    }

    function setToken1(address _token)
        external
        onlyGov
    {

        token1 = IERC20(_token);
    }

    function setTreasury(address _treasury)
        external
        onlyGov
    {

        treasury = _treasury;
    }

    function setUserRate(uint256 _rewardUserRate)
        external
        onlyGov
    {

        rewardUserRate = _rewardUserRate;
    }

    function setTreasuryRate(uint32 _rewardTreasuryRate)
        external
        onlyGov
    {

        rewardTreasuryRate = _rewardTreasuryRate;
    }

    function setFeeAddress(address _feeAddress)
        external
        onlyGov
    {

        feeAddress = _feeAddress;
    }

    function setFeeRate(uint32 _feeRate)
        external
        onlyGov
    {

        feeRate = _feeRate;
    }

    function setWithdrawable(bool _isWithdrawable)
        external
        onlyGov
    {

        isWithdrawable = _isWithdrawable;
    }

    function setVaultName(string memory name)
        external
        onlyGov
    {

        vaultName = name;
    }

    function setTotalRate(uint256 _totalRate)
        external
        onlyGov
    {

        totalRate = _totalRate;
    }
    

    function getReward(address userAddress) internal {


        uint256 rewardedBalance = _rewardedBalancePerUser[userAddress];
        uint256 lastTimestamp = _lastTimestampPerUser[userAddress];

        if (lastTimestamp > 0 && _bounties.length > 0) {
            for (uint k = _bounties.length - 1; lastTimestamp < _bounties[k].bountyTimeStamp; k--) {
                rewardedBalance = rewardedBalance.add(_bounties[k].bountyValue.mul(_depositBalancePerUser[userAddress]).div(_bounties[k].totalBountyDeposit));
                if (k == 0) break; // break for loop if k is 0 to avoid unnessecary runtime
            }
        }
        _rewardedBalancePerUser[userAddress] = rewardedBalance;
        _lastTimestampPerUser[msg.sender] = block.timestamp;
    }

    
    function deposit(uint256 bountyValue) external {

        getReward(msg.sender);

        uint256 feebountyValue = bountyValue.mul(feeRate).div(totalRate); 
       
        uint256 realbountyValue = bountyValue.sub(feebountyValue);
        
        if (feebountyValue > 0) {
            token0.transferFrom(msg.sender, feeAddress, feebountyValue);
        }


        if (realbountyValue > 0) {
            token0.transferFrom(msg.sender, address(this), realbountyValue);
            YCRVGAUGE.deposit(realbountyValue); // -> does this need to be done here or will vaultAddress handle depositing this to ycrvguage?
            _depositBalancePerUser[msg.sender] = _depositBalancePerUser[msg.sender].add(realbountyValue);  // use _depositBalancePerUser from mapping
            _totalBountyDeposit = _totalBountyDeposit.add(realbountyValue); // update _totalBountyDeposit
            emit Deposited(msg.sender, realbountyValue);
        }
    }

    function withdraw(uint256 bountyValue) external {


        require(isWithdrawable, "not withdrawable");

        getReward(msg.sender);

        if (bountyValue > _depositBalancePerUser[msg.sender]) {
            bountyValue = _depositBalancePerUser[msg.sender];
        }

        require(bountyValue > 0, "withdraw amount is 0");

        YCRVGAUGE.withdraw(bountyValue);

        token0.transfer(msg.sender, bountyValue);

        _depositBalancePerUser[msg.sender] = _depositBalancePerUser[msg.sender].sub(bountyValue);
        _totalBountyDeposit = _totalBountyDeposit.sub(bountyValue);  // seems like full amount should be withdrawn

        emit Withdrawn(msg.sender, bountyValue);
    }


    function _distributeBounty(uint256 maxBountyValue) internal returns (uint256, uint256) {

        require(maxBountyValue > 0, "bountyValue can't be 0");
        require(_totalBountyDeposit > 0, "totalDeposit must bigger than 0");


        uint256 treasuryBountyValue; 
        uint256 bountyValueUser = maxBountyValue.mul(rewardUserRate).div(totalRate);  // bountyValueUser == rewardCRVTokenAmountForUsers in original contract (i.e. rewardAmountForCRVToken * rewardUserRate / TOTALRATE)
        treasuryBountyValue = maxBountyValue.sub(bountyValueUser);  // update bountyValue (amountWithdrawForYCRV) by subtracting bountyValueUser (rewardCRVTokenAmountForUsers)
        

        address[] memory tokens = new address[](3);
        tokens[0] = address(CRV);
        tokens[1] = address(WETH);
        tokens[2] = address(token1);

        uint256 pylon_before;
        uint256 pylon_after;

        pylon_before = token1.balanceOf(address(this));

        if (bountyValueUser > 0) {
            UNIROUTER.swapExactTokensForTokens(bountyValueUser, 0, tokens, address(this), type(uint).max);
        }

        pylon_after = token1.balanceOf(address(this));

        

        address[] memory tokens1 = new address[](2);
        tokens1[0] = address(CRV);
        tokens1[1] = address(WETH);

        if (treasuryBountyValue > 0) {
            UNIROUTER.swapExactTokensForTokens(treasuryBountyValue, 0, tokens1, address(this), type(uint).max);
        }

        uint wethBalance;
        wethBalance = WETH.balanceOf(address(this));
        WETH.transfer(treasury, wethBalance);

        Bounty memory bounty;
        bounty = Bounty(bountyValueUser, block.timestamp, _totalBountyDeposit);
        _bounties.push(bounty); // push bounty struct object to _bounties array
        emit DistributedBounty(msg.sender, bountyValueUser);

        return (pylon_before, pylon_after);

    }

    function claimReward() external {

        getReward(msg.sender);


        uint256 maxBounty = getBountyValue(msg.sender);

        _rewardedBalancePerUser[msg.sender] = _rewardedBalancePerUser[msg.sender].sub(maxBounty); // adjusts the _rewardedBalancePerUser for the claim call
        




        uint256 finalPylonUserBounty;
        uint256 previousPylonUserBounty;

        (previousPylonUserBounty, finalPylonUserBounty) = _distributeBounty(maxBounty);

        token1.transfer(msg.sender, finalPylonUserBounty);
        emit ClaimedReward(msg.sender, finalPylonUserBounty);
    }


    function getBountyValue(address userAddress) public view returns (uint256) {


        uint256 rewardedBalance = _rewardedBalancePerUser[userAddress];
        uint256 lastTimestamp = _lastTimestampPerUser[userAddress];

        if (_bounties.length > 0) {
            if (lastTimestamp > 0) {
                for (uint l = _bounties.length - 1; lastTimestamp < _bounties[l].bountyTimeStamp; l--) {
                    rewardedBalance = rewardedBalance.add(_bounties[l].bountyValue.mul(_depositBalancePerUser[userAddress]).div(_bounties[l].totalBountyDeposit));


                    if (l == 0) break;
                }
            }

        }
        return rewardedBalance;
    }

    function seize(address token, address to) external onlyGov {

        require(IERC20(token) != token0 && IERC20(token) != token1, "main tokens");
        if (token != address(0)) {
            uint256 amount = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(to, amount);
        }
        else {
            uint256 amount = address(this).balance;
            payable(to).transfer(amount);
        }
    }
        
    fallback () external payable { }
    receive () external payable { }
}