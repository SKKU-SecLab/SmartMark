

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    
    function decimals() external view returns (uint8);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


pragma solidity ^0.6.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function governance() public view returns (address) {

        return _owner;
    }

    modifier onlyGovernance() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferGovernance(address newOwner) internal virtual onlyGovernance {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ReentrancyGuard {


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
}


pragma solidity =0.6.6;


interface Staker {

    function getLPBalance(address) external view returns (uint256);

    function getSTBZBalance(address) external view returns (uint256);

    function getDepositTime(address) external view returns (uint256);

    function getSTOLInLP(address) external view returns (uint256);

    function claimerAddress() external view returns (address);

}

interface StabinolToken {

    function getMaxSupply() external pure returns (uint256);

    function mint(address, uint256) external returns (bool);

}

interface PriceOracle {

    function getLatestSTOLUSD() external view returns (uint256);

    function getETHUSD() external view returns (uint256);

    function updateSTOLPrice() external;

}

interface SpentOracle {

    function getUserETHSpent(address) external view returns (uint256); // Gets the cumulative eth spent by user

    function addUserETHSpent(address, uint256) external returns (bool); // Send spent data to oracle

}

contract StabinolClaimerV2 is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    address public stolAddress; // The address for the STOL tokens
    uint256 public minPercentClaim = 4000; // Initial conditions are 4% of USD value of STOL holdings can be claimed
    uint256 public minClaimWindow = 3 days; // User must wait at least 3 days after last deposit action to claim
    uint256 public maxAccumulatedClaim = 96000; // The maximum claim percent after the accumulation period has expired
    uint256 public accumulationWindow = 177 days; // Window when accumulation will grow
    bool public usingEthSpentOracle = false; // Governance can switch to ETH oracle or not to determine eth balances
    uint256 private _minSTBZStaked = 50e18; // Initially requires 50 STBZ to stake in order to be eligible
    address public stakerAddress; // The address for the staker
    address public priceOracleAddress; // The address of the price oracle
    address public ethSpentOracleAddress; // Address of the eth spent oracle
    
    uint256 constant DIVISION_FACTOR = 100000;
    uint256 constant CLAIM_STIPEND = 250000; // The amount of stipend we will give to the user for claiming in gas units
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH address
    address constant PREVIOUS_CLAIMER = address(0x71Ce0fb59f17894A70f1D1b4F6eb03cA93E96858); // Address of last claimer
    
    mapping(address => UserInfo) private allUsersInfo;
    
    struct UserInfo {
        bool existing; // This becomes true once the user interacts with the new claimer
        uint256 ethBalance; // The balance of ETH and WETH the last time the claim was made or a deposit was made in staker
        uint256 totalEthSpent; // Stores the total amount of eth spent by user, based on oracle
        uint256 lastClaimTime; // Time at last claim
    }

    event ClaimedSTOL(address indexed user, uint256 amount, uint256 expectedAmount);
    
    constructor(
        address _stol,
        address _staker,
        address _oracle,
        address _ethspent
    ) public {
        stolAddress = _stol;
        stakerAddress = _staker;
        priceOracleAddress = _oracle;
        ethSpentOracleAddress = _ethspent;
    }
    
    modifier onlyStaker() {

        require(_msgSender() == stakerAddress, "Only staker can call this function");
        _;
    }
    
    function getETHSpentSinceClaim(address _user) public view returns (uint256) {

        uint256 total = SpentOracle(ethSpentOracleAddress).getUserETHSpent(_user);
        if(total > allUsersInfo[_user].totalEthSpent){
            return total.sub(allUsersInfo[_user].totalEthSpent);
        }else{
            return 0;
        }
    }
    
    function getTotalETHSpent(address _user) external view returns (uint256) {

        return allUsersInfo[_user].totalEthSpent;
    }
    
    function getETHBalance(address _user) public view returns (uint256){

        if(allUsersInfo[_user].existing == false){
            return StabinolClaimerV2(PREVIOUS_CLAIMER).getETHBalance(_user); // Get data from previous claimer
        }else{
            return allUsersInfo[_user].ethBalance;
        }
    }
    
    function getLastClaimTime(address _user) public view returns (uint256){

        if(allUsersInfo[_user].existing == false){
            return StabinolClaimerV2(PREVIOUS_CLAIMER).getLastClaimTime(_user); // Get data from previous claimer
        }else{
            return allUsersInfo[_user].lastClaimTime;
        }
    }
    
    function getMinSTBZStake() external view returns (uint256){

        return _minSTBZStaked;
    }
    
    function stakerUpdateBalance(address _user, uint256 gasLimit) external onlyStaker {

        if(allUsersInfo[_user].existing == false){
           updateUserData(_user);
        }
        allUsersInfo[_user].ethBalance = _user.balance.add(IERC20(WETH_ADDRESS).balanceOf(_user)).add(gasLimit); // ETH balance + WETH balance + Gas Limit
    }
    
    function updateUserData(address _user) internal {

        allUsersInfo[_user].lastClaimTime = getLastClaimTime(_user);
        allUsersInfo[_user].ethBalance = getETHBalance(_user);
        allUsersInfo[_user].existing = true;
    }
    
    function getClaimBackPercent(address _user) public view returns (uint256) {

        Staker _stake = Staker(stakerAddress);
        if(_stake.claimerAddress() != address(this)){
            return 0;
        }
        uint256 lastTime = _stake.getDepositTime(_user);
        uint256 lastClaimTime = getLastClaimTime(_user);
        if(lastClaimTime > lastTime){
            lastTime = lastClaimTime;
        }
        if(lastTime == 0){
            return 0; // No deposits ever
        }
        if(now < lastTime + minClaimWindow){
            return 0; // Too soon to claim
        }
        lastTime = lastTime + minClaimWindow; // This is the start of the accumulation time
        uint256 timeDiff = now - lastTime; // Will be at least 0
        uint256 maxPercent = timeDiff * maxAccumulatedClaim / accumulationWindow;
        if(maxPercent > maxAccumulatedClaim){maxPercent = maxAccumulatedClaim;}
        return minPercentClaim + maxPercent;
    }
    
    function claim() external nonReentrant
    {

        uint256 gasLimit = gasleft().mul(tx.gasprice);
        
        address _user = _msgSender();
        if(allUsersInfo[_user].existing == false){
            updateUserData(_user);
        }
        
        require(stakerAddress != address(0), "Staker not set yet");
        require(priceOracleAddress != address(0), "Price oracle not set yet");
        require(PriceOracle(priceOracleAddress).getLatestSTOLUSD() > 0, "There is no price yet determined for STOL");
        Staker _stake = Staker(stakerAddress);
        require(_stake.claimerAddress() == address(this), "Staker doesn't have this as the claimer");
        require(_stake.getSTBZBalance(_user) >= _minSTBZStaked, "User doesn't have enough STBZ staked to qualify");
        require(_stake.getLPBalance(_user) > 0, "User hasn't staked any LP tokens into the contract");
        require(now >= allUsersInfo[_user].lastClaimTime + minClaimWindow, "Previous claim was too recent to claim again");
        require(now >= _stake.getDepositTime(_user) + minClaimWindow, "Deposit time was too recent to claim");
        uint256 claimPercent = getClaimBackPercent(_user);
        require(claimPercent > 0, "Unable to determine the percentage eligible to claim");
        allUsersInfo[_user].lastClaimTime = now; // Set the claim time to now
        uint256 claimedAmount = 0;
        uint256 spent = 0;
        
        if(usingEthSpentOracle == true){
            spent = getETHSpentSinceClaim(_user);
            allUsersInfo[_user].totalEthSpent = SpentOracle(ethSpentOracleAddress).getUserETHSpent(_user);
            
            SpentOracle(ethSpentOracleAddress).addUserETHSpent(_user, CLAIM_STIPEND.mul(tx.gasprice));
        }else{
            uint256 currentBalance = _user.balance.add(IERC20(WETH_ADDRESS).balanceOf(_user)).add(gasLimit);
            if(currentBalance < allUsersInfo[_user].ethBalance){
                spent = allUsersInfo[_user].ethBalance.sub(currentBalance);
            }else{
                spent = 0;
            }
            allUsersInfo[_user].ethBalance = currentBalance;
        }
        
        if(spent > 0){
            spent = spent.mul(PriceOracle(priceOracleAddress).getETHUSD()).div(1e18); // Normalize USD price into wei units
            PriceOracle(priceOracleAddress).updateSTOLPrice(); // This will force update the price oracle
            uint256 stolPrice = PriceOracle(priceOracleAddress).getLatestSTOLUSD();
            require(stolPrice > 0, "STOL price cannot be determined");
            uint256 maxSTOL = spent.mul(1e18).div(stolPrice); // This will give use maximum amount of STOL redeemable based on spent ETH
            claimedAmount = _stake.getSTOLInLP(_user).mul(claimPercent).div(DIVISION_FACTOR); // Returns STOL in user's LP share, then takes percent
            if(claimedAmount > maxSTOL){
                claimedAmount = maxSTOL;
            }
            if(claimedAmount > 0){
                IERC20 stol = IERC20(stolAddress);
                uint256 maxSupply = StabinolToken(stolAddress).getMaxSupply();
                if(stol.totalSupply() < maxSupply){
                    if(claimedAmount.add(stol.totalSupply()) > maxSupply){
                        uint256 overage = claimedAmount.add(stol.totalSupply()).sub(maxSupply);
                        claimedAmount = claimedAmount.sub(overage); // Reduce the amount
                        StabinolToken(stolAddress).mint(_user, claimedAmount);
                        if(stol.balanceOf(address(this)) >= overage){
                            stol.safeTransfer(_user, overage);
                            emit ClaimedSTOL(_user, claimedAmount.add(overage), claimedAmount.add(overage));
                        }else if(stol.balanceOf(address(this)) > 0){
                            emit ClaimedSTOL(_user, claimedAmount.add(stol.balanceOf(address(this))), claimedAmount.add(overage));
                            stol.safeTransfer(_user, stol.balanceOf(address(this)));
                        }else{
                            emit ClaimedSTOL(_user, claimedAmount, claimedAmount.add(overage));
                        }
                        return;
                    }else{
                        StabinolToken(stolAddress).mint(_user, claimedAmount);
                        emit ClaimedSTOL(_user, claimedAmount, claimedAmount);
                    }
                }else{
                    if(stol.balanceOf(address(this)) >= claimedAmount){
                        stol.safeTransfer(_user, claimedAmount);
                        emit ClaimedSTOL(_user, claimedAmount, claimedAmount);
                    }else if(stol.balanceOf(address(this)) > 0){
                        emit ClaimedSTOL(_user, stol.balanceOf(address(this)), claimedAmount);
                        stol.safeTransfer(_user, stol.balanceOf(address(this)));
                    }else{
                        emit ClaimedSTOL(_user, 0, claimedAmount);
                    }
                }                
            }
        }
    }
    
    
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant TIMELOCK_DURATION = 86400; // Timelock is 24 hours
    
    address private _timelock_address;
    uint256[2] private _timelock_data;
    
    modifier timelockConditionsMet(uint256 _type) {

        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        require(now >= _timelockStart + TIMELOCK_DURATION, "Timelock time not met");
        _;
    }
    
    function startGovernanceChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {

        transferGovernance(_timelock_address);
    }
    
    function startStakerChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;       
    }
    
    function finishStakerChange() external onlyGovernance timelockConditionsMet(2) {

        stakerAddress = _timelock_address;
    }
    
    function startPriceOracleChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;       
    }
    
    function finishPriceOracleChange() external onlyGovernance timelockConditionsMet(3) {

        priceOracleAddress = _timelock_address;
    }
    
    function startETHSpentOracleChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;       
    }
    
    function finishETHSpentOracleChange() external onlyGovernance timelockConditionsMet(4) {

        ethSpentOracleAddress = _timelock_address;
    }
    
    function startChangeInitialPercentAndTime(uint256 _percent, uint256 _time) external onlyGovernance {

        require(_percent <= 100000, "Percent too high");
        _timelockStart = now;
        _timelockType = 5;
        _timelock_data[0] = _percent;
        _timelock_data[1] = _time;
    }
    
    function finishChangeInitialPercentAndTime() external onlyGovernance timelockConditionsMet(5) {

        minPercentClaim = _timelock_data[0];
        minClaimWindow = _timelock_data[1];
    }
    
    function startChangeMaxPercentAndTime(uint256 _percent, uint256 _time) external onlyGovernance {

        require(_percent <= 100000, "Percent too high");
        _timelockStart = now;
        _timelockType = 6;
        _timelock_data[0] = _percent;
        _timelock_data[1] = _time;
    }
    
    function finishChangeMaxPercentAndTime() external onlyGovernance timelockConditionsMet(6) {

        maxAccumulatedClaim = _timelock_data[0];
        accumulationWindow = _timelock_data[1];
    }
    
    function startChangeMinSTBZ(uint256 _stbz) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 7;
        _timelock_data[0] = _stbz;
    }
    
    function finishChangeMinSTBZ() external onlyGovernance timelockConditionsMet(7) {

        _minSTBZStaked = _timelock_data[0];
    }

    function startTransferVaultToNewClaimer(address _address) external onlyGovernance {

        require(IERC20(stolAddress).balanceOf(address(this)) > 0, "No STOL in Claimer yet");
        _timelockStart = now;
        _timelockType = 8;
        _timelock_address = _address;       
    }
    
    function finishTransferVaultToNewClaimer() external onlyGovernance timelockConditionsMet(8) {

        IERC20(stolAddress).safeTransfer(_timelock_address, IERC20(stolAddress).balanceOf(address(this)));
    }
    
    function startChangeETHSpentOracleUse(uint256 _use) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 9;
        _timelock_data[0] = _use;
    }
    
    function finishChangeETHSpentOracleUse() external onlyGovernance timelockConditionsMet(9) {

        if(_timelock_data[0] == 0){
            usingEthSpentOracle = false;
        }else{
            usingEthSpentOracle = true;
        }
    }
   
}