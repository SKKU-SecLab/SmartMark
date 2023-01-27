
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.2;

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

    function decimals() external view returns (uint8);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// MIT

pragma solidity ^0.8.2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a <= b ? a : b;
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a < b) {
            return b - a;
        }
        return a - b;
    }
}// MIT

pragma solidity ^0.8.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

pragma solidity ^0.8.2;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}// MIT
pragma solidity ^0.8.2;


contract LiquidityMining is Initializable{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct PoolInfo{
        address xToken;
        address collection;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accPerShare;
        uint256 amount;
    }

    struct UserInfo{
        uint256 amount;
        mapping(uint256 /* orderId */ => uint256 /* amount */) orders;
        uint256 rewardDebt;
        uint256 rewardToClaim;
    }

    bool internal _notEntered;

    IERC20 public erc20Token;

    address public controller;
    address public admin;
    address public pendingAdmin;

    uint256 public borrowPerBlockReward;
    uint256 public borrowTotalAllocPoint;

    mapping(address /* xToken */ => mapping(address /* collection */ => PoolInfo)) public borrowPoolInfoMap;
    mapping(address /* xToken */ => mapping(address /* collection */ => mapping(address /* user */ => UserInfo))) public borrowUserInfoMap;
    mapping(address /* xToken */ => uint256) public supplyPerBlockRewardMap;
    mapping(address /* xToken */ => PoolInfo) public supplyPoolInfoMap;
    mapping(address /* xToken */ => mapping(address /* user */ => UserInfo)) public supplyUserInfoMap;

    event Deposit(address xToken, address collection, bool isBorrow, uint256 amount, address account);
    event Withdraw(address xToken, address collection, bool isBorrow, uint256 amount, address account);
    event Claim(address xToken, address collection, bool isBorrow, uint256 amount, address account);

    function initialize() public initializer {

        admin = msg.sender;
        _notEntered = true;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "require admin auth");
        _;
    }

    modifier onlyController() {

        require(msg.sender == controller || msg.sender == admin, "require controller auth");
        _;
    }

    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    function setPendingAdmin(address payable newPendingAdmin) external onlyAdmin{

        pendingAdmin = newPendingAdmin;
    }

    function acceptAdmin() public{

        require(msg.sender == pendingAdmin, "only pending admin could accept");
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function setController(address _controller) external onlyAdmin{

        controller = _controller;
    }

    function setErc20Token(IERC20 _erc20Token) external onlyAdmin{

        erc20Token = _erc20Token;
    }

    function setBorrowPerBlockReward(uint256 _borrowPerBlockReward) external onlyAdmin{

        borrowPerBlockReward = _borrowPerBlockReward;
    }

    function setSupplyPerBlockRewardMap(address xToken, uint256 perBlockReward) external onlyAdmin{

        supplyPerBlockRewardMap[xToken] = perBlockReward;
    }

    function addPool(address xToken, address collection, uint256 allocPoint, bool isBorrow) external onlyAdmin{

        PoolInfo memory poolInfo;
        if(isBorrow){
            poolInfo = borrowPoolInfoMap[xToken][collection];
            require(poolInfo.xToken == address(0), "pool already exists!");
            poolInfo.xToken = xToken;
            poolInfo.collection = collection;
            poolInfo.allocPoint = allocPoint;
            poolInfo.lastRewardBlock = block.number;
            borrowPoolInfoMap[xToken][collection] = poolInfo;

            borrowTotalAllocPoint += allocPoint;
        }else{
            poolInfo = supplyPoolInfoMap[xToken];
            require(poolInfo.xToken == address(0), "pool already exists!");
            poolInfo.xToken = xToken;
            poolInfo.lastRewardBlock = block.number;
            supplyPoolInfoMap[xToken] = poolInfo;
        }
    }

    function setPool(address xToken, address collection, uint256 allocPoint, bool isBorrow) external onlyAdmin{

        if(isBorrow){
            PoolInfo storage poolInfo = borrowPoolInfoMap[xToken][collection];
            require(poolInfo.xToken != address(0), "pool not exists!");

            borrowTotalAllocPoint = borrowTotalAllocPoint.sub(poolInfo.allocPoint).add(allocPoint);

            poolInfo.xToken = xToken;
            poolInfo.collection = collection;
            poolInfo.allocPoint = allocPoint;
        }else{
            PoolInfo storage poolInfo = supplyPoolInfoMap[xToken];
            require(poolInfo.xToken != address(0), "pool not exists!");
            poolInfo.xToken = xToken;
        }
    }

    function updatePool(address xToken, address collection, bool isBorrow) public{

        if(isBorrow){
            updateBorrowPool(xToken, collection);
        }else{
            updateSupplyPool(xToken);
        }
    }

    function updateBorrowPool(address xToken, address collection) internal{

        PoolInfo storage poolInfo = borrowPoolInfoMap[xToken][collection];
        if(poolInfo.xToken != address(0)){
            if (block.number <= poolInfo.lastRewardBlock) {
                return;
            }
            uint256 supply = poolInfo.amount;
            if (supply == 0) {
                poolInfo.lastRewardBlock = block.number;
                return;
            }
            uint256 multiplier = (block.number.sub(poolInfo.lastRewardBlock)).mul(borrowPerBlockReward);
            uint256 reward = multiplier.mul(poolInfo.allocPoint).div(borrowTotalAllocPoint);
            poolInfo.accPerShare = poolInfo.accPerShare.add(reward.mul(1e18).div(supply));
            poolInfo.lastRewardBlock = block.number;
        }
    }

    function updateSupplyPool(address xToken) internal{

        PoolInfo storage poolInfo = supplyPoolInfoMap[xToken];
        if(poolInfo.xToken != address(0)){
            if (block.number <= poolInfo.lastRewardBlock) {
                return;
            }
            uint256 supply = poolInfo.amount;
            if (supply == 0) {
                poolInfo.lastRewardBlock = block.number;
                return;
            }
            uint256 reward = (block.number.sub(poolInfo.lastRewardBlock)).mul(supplyPerBlockRewardMap[xToken]);
            poolInfo.accPerShare = poolInfo.accPerShare.add(reward.mul(1e18).div(supply));
            poolInfo.lastRewardBlock = block.number;
        }
    }

    function massUpdatePools(address[] calldata xToken, address[] calldata collection) external{

        for (uint256 i=0; i<xToken.length; ++i) {
            for(uint256 j=0; j<collection.length; ++j){
                updatePool(xToken[i], collection[j], true);
            }
            updatePool(xToken[i], address(0), false);
        }
    }

    function updateBorrow(address xToken, address collection, uint256 amount, address account, uint256 orderId, bool isDeposit) external onlyController nonReentrant{

        PoolInfo storage poolInfo = borrowPoolInfoMap[xToken][collection];
        if(poolInfo.xToken == address(0)) return;
        UserInfo storage user = borrowUserInfoMap[xToken][collection][account];
        if(!isDeposit && user.amount == 0) return;
        updatePool(xToken, collection, true);
        if((isDeposit && user.amount > 0) || !isDeposit){
            uint256 pending = user.amount.mul(poolInfo.accPerShare).div(1e18).sub(user.rewardDebt);
            user.rewardToClaim = user.rewardToClaim.add(pending);
        }
        poolInfo.amount = poolInfo.amount.sub(user.orders[orderId]).add(amount);
        user.amount = user.amount.sub(user.orders[orderId]).add(amount);
        user.rewardDebt = user.amount.mul(poolInfo.accPerShare).div(1e18);
        user.orders[orderId] = amount;
    }

    function updateSupply(address xToken, uint256 amount, address account, bool isDeposit) external onlyController nonReentrant{

        PoolInfo storage poolInfo = supplyPoolInfoMap[xToken];
        if(poolInfo.xToken == address(0)) return;
        UserInfo storage user = supplyUserInfoMap[xToken][account];
        if(!isDeposit && user.amount == 0) return;
        updatePool(xToken, address(0), false);
        if((isDeposit && user.amount > 0) || !isDeposit){
            uint256 pending = user.amount.mul(poolInfo.accPerShare).div(1e18).sub(user.rewardDebt);
            user.rewardToClaim = user.rewardToClaim.add(pending);
        }
        poolInfo.amount = poolInfo.amount.sub(user.amount).add(amount);
        user.amount = amount;
        user.rewardDebt = user.amount.mul(poolInfo.accPerShare).div(1e18);
    }

    function claim(address xToken, address collection, bool isBorrow, address account) internal{

        if(isBorrow){
            claimBorrowInternal(xToken, collection, account);
        }else{
            claimSupplyInternal(xToken, account);
        }
    }

    function claimBorrowInternal(address xToken, address collection, address account) internal{

        PoolInfo storage poolInfo = borrowPoolInfoMap[xToken][collection];
        if(poolInfo.xToken == address(0)) return;
        UserInfo storage user = borrowUserInfoMap[xToken][collection][account];
        updatePool(xToken, collection, true);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(poolInfo.accPerShare).div(1e18).sub(user.rewardDebt);
            user.rewardToClaim = user.rewardToClaim.add(pending);
        }
        user.rewardDebt = user.amount.mul(poolInfo.accPerShare).div(1e18);
        erc20Token.safeTransfer(account, user.rewardToClaim);
        
        emit Claim(xToken, collection, true, user.rewardToClaim, account);
        user.rewardToClaim = 0;
    }

    function claimBorrow(address xToken, address collection, address account) external nonReentrant{

        claimBorrowInternal(xToken, collection, account);
    }

    function claimSupplyInternal(address xToken, address account) internal{

        PoolInfo storage poolInfo = supplyPoolInfoMap[xToken];
        if(poolInfo.xToken == address(0)) return;
        UserInfo storage user = supplyUserInfoMap[xToken][account];
        updatePool(xToken, address(0), false);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(poolInfo.accPerShare).div(1e18).sub(user.rewardDebt);
            user.rewardToClaim = user.rewardToClaim.add(pending);
        }
        user.rewardDebt = user.amount.mul(poolInfo.accPerShare).div(1e18);
        erc20Token.safeTransfer(account, user.rewardToClaim);
        
        emit Claim(xToken, address(0), false, user.rewardToClaim, account);
        user.rewardToClaim = 0;
    }

    function claimSupply(address xToken, address account) external nonReentrant{

        claimSupplyInternal(xToken, account);
    }

    function claimAll(address[] calldata xToken, address[] calldata collection) external nonReentrant{

        for(uint256 i=0; i<xToken.length; ++i){
            for(uint256 j=0; j<collection.length; ++j){
                if(getPendingAmount(xToken[i], collection[j], msg.sender, true) > 0){
                    claim(xToken[i], collection[j], true, msg.sender);
                }
            }
            if(getPendingAmount(xToken[i], address(0), msg.sender, false) > 0){
                claim(xToken[i], address(0), false, msg.sender);
            }
        }
    }

    function getPendingAmountOfBorrow(address[] memory xToken, address[] memory collection, address account) external view returns(uint256){

        uint256 allAmount = 0;
        for(uint256 i=0; i<xToken.length; i++){
            for(uint256 j=0; j<collection.length; j++){
                allAmount = allAmount.add(getPendingAmount(xToken[i], collection[j], account, true));
            }
        }
        return allAmount;
    }

    function getPendingAmountOfSupply(address[] memory xToken, address account) external view returns(uint256){

        uint256 allAmount = 0;
        for(uint256 i=0; i<xToken.length; i++){
            allAmount = allAmount.add(getPendingAmount(xToken[i], address(0), account, false));
        }
        return allAmount;
    }

    function getPendingAmount(address xToken, address collection, address account, bool isBorrow) internal view returns(uint256){

        PoolInfo memory poolInfo;
        UserInfo storage user;
        if(isBorrow){
            poolInfo = borrowPoolInfoMap[xToken][collection];
            user = borrowUserInfoMap[xToken][collection][account];
        }else{
            poolInfo = supplyPoolInfoMap[xToken];
            user = supplyUserInfoMap[xToken][account];
        }
        if(poolInfo.xToken == address(0)) return 0;
        uint256 accPerShare = poolInfo.accPerShare;
        uint256 supply = poolInfo.amount;
        if(block.number > poolInfo.lastRewardBlock && supply != 0){
            uint256 reward;
            if(isBorrow){
                uint256 multiplier = (block.number.sub(poolInfo.lastRewardBlock)).mul(borrowPerBlockReward);
                reward = multiplier.mul(poolInfo.allocPoint).div(borrowTotalAllocPoint);
            }else{
                reward = (block.number.sub(poolInfo.lastRewardBlock)).mul(supplyPerBlockRewardMap[xToken]);
            }
            accPerShare = accPerShare.add(reward.mul(1e18).div(supply));
        }
        uint256 pending = user.amount.mul(accPerShare).div(1e18).sub(user.rewardDebt);
        uint256 totalPendingAmount = user.rewardToClaim.add(pending);
        return totalPendingAmount;
    }

    function getAllPendingAmount(address[] calldata xToken, address[] calldata collection, address account) external view returns (uint256){

        uint256 allAmount = 0;
        for (uint256 i=0; i<xToken.length; ++i) {
            for(uint256 j=0; j<collection.length; ++j){
                allAmount = allAmount.add(getPendingAmount(xToken[i], collection[j], account, true));
            }
            allAmount = allAmount.add(getPendingAmount(xToken[i], address(0), account, false));
        }
        return allAmount;
    }

    function getOrderIdAmount(address xToken, address collection, address account, uint256 orderId) external view returns(uint256){

        UserInfo storage user = borrowUserInfoMap[xToken][collection][account];
        return user.orders[orderId];
    }
}