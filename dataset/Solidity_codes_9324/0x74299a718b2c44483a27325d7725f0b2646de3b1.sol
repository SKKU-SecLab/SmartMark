


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
}


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
}


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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}


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
}


pragma solidity 0.8.6;





contract LatticeStakingPool is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct StakingPool {
        uint256 maxStakingAmountPerUser;
        uint256 totalAmountStaked;
        address[] usersStaked;
    }
    
    struct Project {
        string name;
        uint256 totalAmountStaked;
        uint256 numberOfPools;
        uint256 startBlock; 
        uint256 endBlock;
    }
    
    struct UserInfo{
        address userAddress;
        uint256 poolId;
        uint256 percentageOfTokensStakedInPool;
        uint256 amountOfTokensStakedInPool;
    }
    
    IERC20 public stakingToken;
    
    address private owner;
    
    Project[] public projects;
    
    mapping(uint256 => mapping(address => bool)) public projectIdToWhitelistedAddress;
    
    mapping(uint256 => address[]) private projectIdToWhitelistedArray;
    
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) public userStakedAmount;
    
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public didUserWithdrawFunds;
    
    mapping(uint256 => mapping(uint256 => StakingPool)) public stakingPoolInfo;
    
    mapping(string=>bool) public isProjectNameTaken;
    
    mapping(string=>uint256) public projectNameToProjectId;
    
    event Deposit(
        address indexed _user, 
        uint256 indexed _projectId, 
        uint256 indexed _poolId, 
        uint256 _amount
    );
    event Withdraw(
        address indexed _user, 
        uint256 indexed _projectId, 
        uint256 indexed _poolId, 
        uint256 _amount
    );
    event PoolAdded(uint256 indexed _projectId, uint256 indexed _poolId);
    event ProjectDisabled(uint256 indexed _projectId);
    event ProjectAdded(uint256 indexed _projectId, string _projectName);
    
    constructor(IERC20 _stakingToken) {
        require(
            address(_stakingToken) != address(0),
            "constructor: _stakingToken must not be zero address"
        );
        
        owner = msg.sender;
        stakingToken = _stakingToken;
    }
    
    function addProject(string memory _name, uint256 _startBlock, uint256 _endBlock) external {

        require(msg.sender == owner, "addNewProject: Caller is not the owner");
        require(bytes(_name).length > 0 , "addNewProject: Project name cannot be empty string.");
        require(
            _startBlock >= block.number, 
            "addNewProject: startBlock is less than the current block number."
        );
        require(
            _startBlock < _endBlock, 
            "addNewProject: startBlock is greater than or equal to the endBlock."
        );
        require(!isProjectNameTaken[_name], "addNewProject: project name already taken.");
        
        Project memory project;
        project.name = _name;  
        project.startBlock = _startBlock;
        project.endBlock = _endBlock;
        project.numberOfPools = 0;        
        project.totalAmountStaked = 0;    
        
        uint256 projectsLength = projects.length;
        projects.push(project);
        projectNameToProjectId[_name] = projectsLength;
        isProjectNameTaken[_name] = true;
        
        emit ProjectAdded(projectsLength, _name);
    }
    
    function addStakingPool(uint256 _projectId, uint256 _maxStakingAmountPerUser) external {

        require(msg.sender == owner, "addStakingPool: Caller is not the owner.");
        require(_projectId < projects.length, "addStakingPool: Invalid project ID.");
    
        StakingPool memory stakingPool;
        stakingPool.maxStakingAmountPerUser = _maxStakingAmountPerUser;
        stakingPool.totalAmountStaked=0;
        
        uint256 numberOfPoolsInProject = projects[_projectId].numberOfPools;
        stakingPoolInfo[_projectId][numberOfPoolsInProject] = stakingPool;
        projects[_projectId].numberOfPools = projects[_projectId].numberOfPools+1;
        
        emit PoolAdded(_projectId,projects[_projectId].numberOfPools);
    }
    
    function disableProject(uint256 _projectId) external {

        require(msg.sender == owner, "disableProject: Caller is not the owner");
        require(_projectId < projects.length, "disableProject: Invalid project ID.");
        
        projects[_projectId].endBlock = block.number;
        
        emit ProjectDisabled(_projectId);
    }
    
    function deposit (uint256 _projectId, uint256 _poolId, uint256 _amount) external nonReentrant {
        require(
            projectIdToWhitelistedAddress[_projectId][msg.sender], 
            "deposit: Address is not whitelisted for this project."
        );
        require(_amount > 0, "deposit: Amount not specified.");
        require(_projectId < projects.length, "deposit: Invalid project ID.");
        require(_poolId < projects[_projectId].numberOfPools, "deposit: Invalid pool ID.");
        require(
            block.number <= projects[_projectId].endBlock, 
            "deposit: Staking no longer permitted for this project."
        );
        require(
            block.number >= projects[_projectId].startBlock, 
            "deposit: Staking is not yet permitted for this project."
        );
        
        uint256 _userStakedAmount = userStakedAmount[_projectId][_poolId][msg.sender];
        if(stakingPoolInfo[_projectId][_poolId].maxStakingAmountPerUser > 0){
            require(
                _userStakedAmount.add(_amount) <= stakingPoolInfo[_projectId][_poolId].maxStakingAmountPerUser, 
                "deposit: Cannot exceed max staking amount per user."
            );
        }
        
        if(userStakedAmount[_projectId][_poolId][msg.sender] == 0){
            stakingPoolInfo[_projectId][_poolId].usersStaked.push(msg.sender);
        }
        
        projects[_projectId].totalAmountStaked 
        = projects[_projectId].totalAmountStaked.add(_amount);
        
        stakingPoolInfo[_projectId][_poolId].totalAmountStaked 
        = stakingPoolInfo[_projectId][_poolId].totalAmountStaked.add(_amount);
        
        userStakedAmount[_projectId][_poolId][msg.sender] 
        = userStakedAmount[_projectId][_poolId][msg.sender].add(_amount);
        
        stakingToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        
        emit Deposit(msg.sender, _projectId, _poolId,  _amount);
    }
    
    function withdraw (uint256  _projectId, uint256 _poolId) external nonReentrant {
        require(
            projectIdToWhitelistedAddress[_projectId][msg.sender], 
            "withdraw: Address is not whitelisted for this project."
        );
        require(_projectId < projects.length, "withdraw: Invalid project ID.");
        require(_poolId < projects[_projectId].numberOfPools, "withdraw: Invalid pool ID.");
        require(block.number > projects[_projectId].endBlock, "withdraw: Not yet permitted.");
        require(
            !didUserWithdrawFunds[_projectId][_poolId][msg.sender], 
            "withdraw: User has already withdrawn funds for this pool."
        );
        
        uint256 _userStakedAmount = userStakedAmount[_projectId][_poolId][msg.sender];
        require(_userStakedAmount > 0, "withdraw: No stake to withdraw.");
        didUserWithdrawFunds[_projectId][_poolId][msg.sender] = true;
        
        stakingToken.safeTransfer(msg.sender, _userStakedAmount);
        
        emit Withdraw(msg.sender, _projectId, _poolId, _userStakedAmount);
    }
    
    function whitelistAddresses( 
        uint256 _projectId, 
        address[] memory _newAddressesToWhitelist
    ) external {

        require(msg.sender == owner, "whitelistAddresses: Caller is not the owner");
        require(_projectId < projects.length, "whitelistAddresses: Invalid project ID.");
        require(
            _newAddressesToWhitelist.length > 0, 
            "whitelistAddresses: Addresses array is empty."
        );
        
        for (uint i=0; i < _newAddressesToWhitelist.length; i++) {
            if(!projectIdToWhitelistedAddress[_projectId][_newAddressesToWhitelist[i]]){
                projectIdToWhitelistedAddress[_projectId][_newAddressesToWhitelist[i]] = true;
                projectIdToWhitelistedArray[_projectId].push(_newAddressesToWhitelist[i]);
            }
        }
    }
    
    function getWhitelistedAddressesForProject(
        uint256 _projectId
    ) external view returns(address[] memory){

        require(msg.sender == owner, "getWhitelistedAddressesForProject: Caller is not the owner");
        
        return projectIdToWhitelistedArray[_projectId];
    }
    
    function isAddressWhitelisted(
        uint256 _projectId,
        address _address
    ) external view returns(bool){

        require(_projectId < projects.length, "isAddressWhitelisted: Invalid project ID.");
        
        return projectIdToWhitelistedAddress[_projectId][_address];
    }
        
    function getTotalStakingInfoForProjectPerPool(
        uint256 _projectId,
        uint256 _poolId,
        uint256 _pageNumber,
        uint256 _pageSize
    )external view returns (UserInfo[] memory){

        require(msg.sender == owner, "getTotalStakingInfoForProjectPerPool: Caller is not the owner.");
        require(
            _projectId < projects.length, 
            "getTotalStakingInfoForProjectPerPool: Invalid project ID."
        );
        require(
            _poolId < projects[_projectId].numberOfPools, 
            "getTotalStakingInfoForProjectPerPool: Invalid pool ID."
        );
        uint256 _usersStakedInPool = stakingPoolInfo[_projectId][_poolId].usersStaked.length;
        require(
            _usersStakedInPool > 0, 
            "getTotalStakingInfoForProjectPerPool: Nobody staked in this pool."
        );
        require(
            _pageSize > 0, 
            "getTotalStakingInfoForProjectPerPool: Invalid page size."
        );
        require(
            _pageNumber > 0, 
            "getTotalStakingInfoForProjectPerPool: Invalid page number."
        );
        uint256 _startIndex = _pageNumber.sub(1).mul(_pageSize);

        if(_pageNumber > 1){
            require(
                _startIndex < _usersStakedInPool,
                "getTotalStakingInfoForProjectPerPool: Specified parameters exceed number of users in the pool."
            );
        }

        uint256 _endIndex = _pageNumber.mul(_pageSize);
        if(_endIndex > _usersStakedInPool){
            _endIndex = _usersStakedInPool;
        }
        
        UserInfo[] memory _result = new UserInfo[](_endIndex.sub(_startIndex));
        uint256 _resultIndex = 0;

        for(uint256 i=_startIndex; i < _endIndex; i++){
            UserInfo memory _userInfo;
            _userInfo.userAddress = stakingPoolInfo[_projectId][_poolId].usersStaked[i];
            _userInfo.poolId = _poolId;
            _userInfo.percentageOfTokensStakedInPool 
            = getPercentageAmountStakedByUserInPool(_projectId,_poolId,_userInfo.userAddress);
            
            _userInfo.amountOfTokensStakedInPool 
            = getAmountStakedByUserInPool(_projectId,_poolId,_userInfo.userAddress);
            
            _result[_resultIndex]=_userInfo;
            _resultIndex = _resultIndex + 1;
        }
        
        return _result;
    }
    
    function numberOfProjects() external view returns (uint256) {

        return projects.length;
    }
    
    function numberOfPools(uint256 _projectId) external view returns (uint256) {

        require(_projectId < projects.length, "numberOfPools: Invalid project ID.");
        return projects[_projectId].numberOfPools;
    }
    
    function getTotalAmountStakedInProject(uint256 _projectId) external view returns (uint256) {

        require(
            _projectId < projects.length, 
            "getTotalAmountStakedInProject: Invalid project ID."
        );
        
        return projects[_projectId].totalAmountStaked;
    }
    
    function getTotalAmountStakedInPool(
        uint256 _projectId,
        uint256 _poolId
    ) external view returns (uint256) {

        require(_projectId < projects.length, "getTotalAmountStakedInPool: Invalid project ID.");
        require(
            _poolId < projects[_projectId].numberOfPools, 
            "getTotalAmountStakedInPool: Invalid pool ID."
        );
        
        return stakingPoolInfo[_projectId][_poolId].totalAmountStaked;
    }
    
    function getAmountStakedByUserInPool(
        uint256 _projectId,
        uint256 _poolId, 
        address _address
    ) public view returns (uint256) {

        require(_projectId < projects.length, "getAmountStakedByUserInPool: Invalid project ID.");
        require(
            _poolId < projects[_projectId].numberOfPools, 
            "getAmountStakedByUserInPool: Invalid pool ID."
        );  
        
        return userStakedAmount[_projectId][_poolId][_address];
    }
    
    function getPercentageAmountStakedByUserInPool(
        uint256 _projectId,
        uint256 _poolId, 
        address _address
    ) public view returns (uint256) {

        require(
            _projectId < projects.length, 
            "getPercentageAmountStakedByUserInPool: Invalid project ID."
        );
        require(
            _poolId < projects[_projectId].numberOfPools, 
            "getPercentageAmountStakedByUserInPool: Invalid pool ID."
        );  
        
        return userStakedAmount[_projectId][_poolId][_address]
               .mul(1e8)
               .div(stakingPoolInfo[_projectId][_poolId]
               .totalAmountStaked);
    }
}