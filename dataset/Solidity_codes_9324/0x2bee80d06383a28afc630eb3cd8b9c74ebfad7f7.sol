
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity ^0.8.0;

contract ProxyStorage {

    address public veTokenImplementation;

    address public pendingVeTokenImplementation;
}

contract VeTokenStorage is  ProxyStorage {

    address public token;  // token
    uint256 public supply; // veToken

    string public name;
    string public symbol;
    string public version;
    uint256 constant decimals = 18;

    uint256 public scorePerBlk;
    uint256 public totalStaked;

    mapping (address => UserInfo) internal userInfo;
    PoolInfo public poolInfo;
    uint256 public startBlk;  // start Blk
    uint256 public clearBlk;  // set annually
    
    struct UserInfo {
        uint256 amount;        // How many tokens the user has provided.
        uint256 score;         // score exclude pending amount
        uint256 scoreDebt;     // score debt
        uint256 lastUpdateBlk; // last user's tx Blk
    }

    struct PoolInfo {      
        uint256 lastUpdateBlk;     // Last block number that score distribution occurs.
        uint256 accScorePerToken;   // Accumulated socres per token, times 1e12. 
    }

    address public smartWalletChecker;
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


contract AccessControl is Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    event SetProxy(address proxy);
    event AdminTransferred(address oldAdmin, address newAdmin);
    event FlipStakableState(bool stakeIsActive);
    event FlipClaimableState(bool claimIsActive);
    event TransferAdmin(address oldAdmin, address newAdmin);

    address private _admin;
    address public proxy;
    bool public stakeIsActive = true;
    bool public claimIsActive = true;

    address public constant ZERO_ADDRESS = address(0);

    constructor() {
        _setAdmin(_msgSender());
    }


    function admin() public view virtual returns (address) {

        return _admin;
    }

    modifier onlyAdmin() {

        require(admin() == _msgSender(), "Invalid Admin: caller is not the admin");
        _;
    }

    function _setAdmin(address newAdmin) private {

        address oldAdmin = _admin;
        _admin = newAdmin;
        emit AdminTransferred(oldAdmin, newAdmin);
    }

    function setProxy(address _proxy) external onlyOwner {

        require(_proxy != address(0), "Invalid Address");
        proxy = _proxy;

        emit SetProxy(_proxy);
    }

    modifier onlyProxy() {

        require(proxy == _msgSender(), "Not Permit: caller is not the proxy"); 
        _;
    }


    modifier activeStake() {

        require(stakeIsActive, "Unstakable");
        _;
    } 

    modifier activeClaim() {

        require(claimIsActive, "Unclaimable");
        _;
    } 
    
    modifier notZeroAddr(address addr_) {

        require(addr_ != ZERO_ADDRESS, "Zero address");
        _;
    }

    function transferAdmin(address newAdmin) external virtual onlyOwner {

        require(newAdmin != address(0), "Invalid Admin: new admin is the zero address");
        address oldAdmin = admin();
        _setAdmin(newAdmin);

        emit TransferAdmin(oldAdmin, newAdmin);
    }

    function flipStakableState() external onlyOwner {

        stakeIsActive = !stakeIsActive;

        emit FlipStakableState(stakeIsActive);
    }

    function flipClaimableState() external onlyOwner {

        claimIsActive = !claimIsActive;

        emit FlipClaimableState(claimIsActive);
    }
}// MIT
pragma solidity ^0.8.0;


contract VeTokenProxy is AccessControl, ProxyStorage {

    function setPendingImplementation(
        address newPendingImplementation_
    ) public onlyOwner 
    {

        address oldPendingImplementation = pendingVeTokenImplementation;

        pendingVeTokenImplementation = newPendingImplementation_;

        emit NewPendingImplementation(oldPendingImplementation, pendingVeTokenImplementation);
    }

    function acceptImplementation() public {

        require (msg.sender == pendingVeTokenImplementation && pendingVeTokenImplementation != address(0),
                "Invalid veTokenImplementation");

        address oldImplementation = veTokenImplementation;
        address oldPendingImplementation = pendingVeTokenImplementation;

        veTokenImplementation = oldPendingImplementation;

        pendingVeTokenImplementation = address(0);

        emit NewImplementation(oldImplementation, veTokenImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingVeTokenImplementation);
    }
    
    fallback () external payable {
        (bool success, ) = veTokenImplementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize())

              switch success
              case 0 { revert(free_mem_ptr, returndatasize()) }
              default { return(free_mem_ptr, returndatasize()) }
        }
    }

    receive () external payable {}

    function claim (address receiver) external onlyOwner nonReentrant {
        payable(receiver).transfer(address(this).balance);

        emit Claim(receiver);
    }

    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    event NewImplementation(address oldImplementation, address newImplementation);
   
    event Claim(address receiver);
}// MIT
pragma solidity ^0.8.0;


interface SmartWalletChecker {

    function isAllowed(address addr) external returns (bool);

}

contract VeToken is AccessControl, VeTokenStorage {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    function initialize(
        address tokenAddr_,
        string memory name_,
        string memory symbol_,
        string memory version_,
        uint256 scorePerBlk_,
        uint256 startBlk_
    ) external onlyOwner 
    {

        token = tokenAddr_;
        
        name = name_;
        symbol = symbol_;
        version = version_;

        scorePerBlk = scorePerBlk_;
        startBlk = startBlk_;

        poolInfo.lastUpdateBlk = startBlk > block.number ? startBlk : block.number;
    
        emit Initialize(tokenAddr_, name_, symbol_, version_, scorePerBlk_, startBlk_);
    }


    function getPoolInfo() external view returns (PoolInfo memory) 
    {

        return poolInfo;
    }

    function getUserInfo(
        address user_
    ) external view returns (UserInfo memory) 
    {

        return userInfo[user_];
    }

    function getTotalScore() public view returns(uint256) 
    {

        uint256 startBlk = (clearBlk > startBlk) && (block.number > clearBlk) ? clearBlk : startBlk;
        return block.number.sub(startBlk).mul(scorePerBlk);
    }

    function getUserRatio(
        address user_
    ) public view returns (uint256) 
    {

        return currentScore(user_).mul(1e12).div(getTotalScore());
    }

    function getMultiplier(
        uint256 from_, 
        uint256 to_
    ) internal view returns (uint256) 
    {

        require(from_ <= to_, "from_ must less than to_");

        from_ = from_ >= startBlk ? from_ : startBlk;

        return to_.sub(from_);
    }
    
    function clearUserScore(
        address user_
    ) internal view returns(bool isClearScore)
    {

        if ((block.number > clearBlk) && 
            (userInfo[user_].lastUpdateBlk < clearBlk)) {
                isClearScore = true;
            }
    } 

    function clearPoolScore() internal returns(bool isClearScore)
    {

        if ((block.number > clearBlk) && (poolInfo.lastUpdateBlk < clearBlk)) {
                isClearScore = true;
                startBlk = clearBlk;
            }     
    }

    function accScorePerToken() internal returns (uint256 updated)
    {

        bool isClearPoolScore = clearPoolScore();
        uint256 scoreReward =  getMultiplier(poolInfo.lastUpdateBlk, block.number)
                                            .mul(scorePerBlk);

        if (isClearPoolScore) {
            updated = scoreReward.mul(1e12).div(totalStaked)
                                 .mul(block.number.sub(clearBlk))
                                 .div(block.number.sub(poolInfo.lastUpdateBlk));
        } else {
            updated = poolInfo.accScorePerToken.add(scoreReward.mul(1e12)
                                               .div(totalStaked));
        }
    }

    function accScorePerTokenStatic() internal view returns (uint256 updated)
    {

        uint256 scoreReward =  getMultiplier(poolInfo.lastUpdateBlk, block.number)
                                            .mul(scorePerBlk);

        updated = poolInfo.accScorePerToken.add(scoreReward.mul(1e12)
                                            .div(totalStaked));
        
    }

    function pendingScore(
        address user_
    ) internal view returns (uint256 pending) 
    {

        if (userInfo[user_].amount == 0) {
            return 0;
        }
        if (clearUserScore(user_)) {
            pending = userInfo[user_].amount.mul(accScorePerTokenStatic()).div(1e12);
        } else {
            pending = userInfo[user_].amount.mul(accScorePerTokenStatic()).div(1e12)
                                            .sub(userInfo[user_].scoreDebt);  
        }
    }

    function currentScore(
        address user_
    ) internal view returns(uint256)
    {

        uint256 pending = pendingScore(user_);

        if (clearUserScore(user_)) {
            return pending;
        } else {
            return pending.add(userInfo[user_].score);
        }
    }

    function isClaimable() external view returns(bool) 
    {

        return claimIsActive;
    }

    function isStakable() external view returns(bool) 
    {

        return stakeIsActive;
    }

    function balanceOf(
        address addr_
    ) external view notZeroAddr(addr_) returns(uint256)
    {

        return userInfo[addr_].amount;
    }

    function totalSupply() external view returns(uint256) 
    {

        return supply;
    }

    function assertNotContract(
        address addr_
    ) internal 
    {

        if (addr_ != tx.origin) {
            address checker = smartWalletChecker;
            if (checker != ZERO_ADDRESS){
                if (SmartWalletChecker(checker).isAllowed(addr_)){
                    return;
                }
            }
            revert("Smart contract depositors not allowed");
        }
    }


    function updateStakingPool() internal
    {

        if (block.number <= poolInfo.lastUpdateBlk || block.number <= startBlk) { 
            poolInfo.lastUpdateBlk = block.number; 
            return;
        }

        if (totalStaked == 0) {
            poolInfo.lastUpdateBlk = block.number; 
            return;
        }  

        poolInfo.accScorePerToken = accScorePerToken();
        poolInfo.lastUpdateBlk = block.number; 

        emit UpdateStakingPool(block.number);
    }

    function depositFor(
        address user_,
        uint256 value_
    ) external nonReentrant activeStake notZeroAddr(user_) 
    {

        require (value_ > 0, "Need non-zero value");

        if (userInfo[user_].amount == 0) {
            assertNotContract(msg.sender);
        }
    
        updateStakingPool();
        userInfo[user_].score = currentScore(user_);
        userInfo[user_].amount = userInfo[user_].amount.add(value_);
        userInfo[user_].scoreDebt = userInfo[user_].amount.mul(poolInfo.accScorePerToken).div(1e12);
        userInfo[user_].lastUpdateBlk = block.number;

        IERC20(token).safeTransferFrom(msg.sender, address(this), value_);
        totalStaked = totalStaked.add(value_);
        supply = supply.add(value_);

        emit DepositFor(user_, value_);
    }

    function withdraw(
        uint256 value_
    ) public nonReentrant activeClaim
    {

        require (value_ > 0, "Need non-zero value");
        require (userInfo[msg.sender].amount >= value_, "Exceed staked value");
        
        updateStakingPool();
        userInfo[msg.sender].score = currentScore(msg.sender);
        userInfo[msg.sender].amount = userInfo[msg.sender].amount.sub(value_);
        userInfo[msg.sender].scoreDebt = userInfo[msg.sender].amount.mul(poolInfo.accScorePerToken).div(1e12);
        userInfo[msg.sender].lastUpdateBlk = block.number;

        IERC20(token).safeTransfer(msg.sender, value_);
        totalStaked = totalStaked.sub(value_);
        supply = supply.sub(value_);

        emit Withdraw(value_);
    }


    function become(
        VeTokenProxy veTokenProxy
    ) public 
    {

        require(msg.sender == veTokenProxy.owner(), "only MultiSigner can change brains");
        veTokenProxy.acceptImplementation();

        emit Become(address(veTokenProxy), address(this));
    }

    function applySmartWalletChecker(
        address smartWalletChecker_
    ) external onlyOwner notZeroAddr(smartWalletChecker_) 
    {

        smartWalletChecker = smartWalletChecker_;

        emit ApplySmartWalletChecker(smartWalletChecker_);
    }

    function recoverERC20(
        address tokenAddress, 
        uint256 tokenAmount
    ) external onlyOwner notZeroAddr(tokenAddress) 
    {

        require(tokenAddress != token, "Not in migration");
        IERC20(tokenAddress).transfer(owner(), tokenAmount);

        emit Recovered(tokenAddress, tokenAmount);
    }

    function setScorePerBlk(
        uint256 scorePerBlk_
    ) external onlyOwner 
    {

        scorePerBlk = scorePerBlk_;

        emit SetScorePerBlk(scorePerBlk_);
    }

    function setClearBlk(
        uint256 clearBlk_
    ) external onlyOwner 
    {

        clearBlk = clearBlk_;

        emit SetClearBlk(clearBlk_);
    }

    receive () external payable {}

    function claim (address receiver) external onlyOwner nonReentrant {
        payable(receiver).transfer(address(this).balance);
    
        emit Claim(receiver);
    }
    
    event Initialize(address tokenAddr, string name, string symbol, string version, uint scorePerBlk, uint startBlk);
    event DepositFor(address depositor, uint256 value);
    event Withdraw(uint256 value);
    event ApplySmartWalletChecker(address smartWalletChecker);
    event Recovered(address tokenAddress, uint256 tokenAmount);
    event UpdateStakingPool(uint256 blockNumber);
    event SetScorePerBlk(uint256 scorePerBlk);
    event SetClearBlk(uint256 clearBlk);
    event Become(address proxy, address impl);
    event Claim(address receiver);
}