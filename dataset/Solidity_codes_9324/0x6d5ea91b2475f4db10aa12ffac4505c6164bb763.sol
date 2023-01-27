

pragma solidity ^0.8.4;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

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

library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance =
        token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract BridgeX is Ownable, Pausable, ReentrancyGuard {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    struct Project {
        address tokenAddress;
        uint balance;
        bool active;
        address owner;
        uint max_amount;
        uint swapCommissionPercent;
        address swapCommissionReceiver;
        uint minOracleFee;
        bool ownerVerified;

        mapping(uint => Chain) chains; //ChainID => chainData
        mapping(bytes32 => Swap) swaps; //SwapID => swapData
    }

    struct Chain {
        address tokenAddress;
        bool active;
        uint swapCount;
        uint minOracleFee;
    }

    struct Swap {
        uint swapCount;
        uint chainID;
        address from;
        address to;
        uint amount;
        bool isCompleted;
    }

    mapping(bytes32 => Project) public projects; //UniquePRojectID => projectdata
    uint public totalProjects = 0; //Total number of projects
    uint public totalSwaps = 0; //Total number of swaps performed in this contract

    address payable public oracleAddress;

    uint public PROJECT_CREATION_COST;
    address payable public SERVICE_PROVIDER_ADDRESS;

    event SwapStart (
        bytes32 indexed projectId,
        bytes32 indexed swapId,
        uint swapCount,
        uint toChainID,
        address indexed fromAddr, 
        address toAddr, 
        uint amount
    );
    
    event SwapEnd (
        bytes32 indexed projectId,
        bytes32 indexed swapId,
        uint swapCount,
        uint fromChainID,
        address indexed fromAddr, 
        address toAddr,
        uint amount
    );
    
    event SwapCompleted(
        bytes32 indexed projectId,
        bytes32 indexed swapId
    );

    event newProjectCreated(
        bytes32 indexed projectId, 
        address indexed tokenAddress, 
        address indexed owner,
        uint initialSupply
    );

    event newProjectChainCreated(
        bytes32 indexed projectId, 
        uint chainId, 
        address tokenAddress
    );

    event commissionReceived(
        bytes32 indexed projectId, 
        bytes32 indexed swapId,
        uint amount
    );

    event projectStatusChanged(
        bytes32 indexed projectId, 
        bool newStatus
    );

    modifier onlyActiveChains(bytes32 projectId, uint chainID){

        require(chainID != _getChainID(), "BRIDGEX: Swap must be created to different chain ID");
        require(projects[projectId].chains[chainID].active == true, "BRIDGEX: Only active chains");
        _;
    }

    modifier notContract() {

        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    modifier onlyTokenOwner(bytes32 projectId) {

        require(projects[projectId].owner == _msgSender(), "ERROR: caller is not the Token Owner");
        _;
    }

    modifier OnlyOracle() {

        require(oracleAddress == _msgSender(), "ERROR: caller is not the Oracle");
        _;
    }

    constructor(address payable _oracleAddress, address payable _serviceProvider, uint _projectCreationCost) {
        oracleAddress = _oracleAddress;
        SERVICE_PROVIDER_ADDRESS = _serviceProvider;
        PROJECT_CREATION_COST = _projectCreationCost;
    }

    function swapStart(bytes32 projectId, uint toChainID, address to, uint amount) public payable onlyActiveChains(projectId, toChainID) whenNotPaused notContract nonReentrant {

        require(projects[projectId].active == true, "BRIDGE: Bridge Pool is inactive");
        require(msg.value.mul(1 gwei) >= projects[projectId].minOracleFee.add(projects[projectId].chains[toChainID].minOracleFee), "BRIDGE: Insufficient Oracle Fee");
        require(amount <= projects[projectId].max_amount, "BRIDGEX: Amount must be within max range");
        require(to == msg.sender, "BRIDGEX: Swaps allowed between same address only");
        require(IERC20(projects[projectId].tokenAddress).allowance(msg.sender, address(this)) >= amount, "BRIDGEX: Not enough allowance");
        _depositToken(projectId, amount);

        uint commission;
        if(projects[projectId].swapCommissionPercent > 0 && msg.sender != projects[projectId].swapCommissionReceiver){
            commission = calculateCommission(projectId, amount);
            amount = amount.sub(commission);
            _withdrawCommission(projectId, commission);
            emit commissionReceived(projectId, projectId, commission);
        }

        projects[projectId].chains[toChainID].swapCount = projects[projectId].chains[toChainID].swapCount.add(1);
        uint _swapCount = projects[projectId].chains[toChainID].swapCount;
        uint _chainID = _getChainID();
        Swap memory swap = Swap({
            swapCount: _swapCount,
            chainID: _chainID,
            from: msg.sender,
            to: to,
            amount: amount,
            isCompleted: false
        });

        bytes32 swapId = keccak256(abi.encode(projectId, _swapCount, _chainID, toChainID, msg.sender, to, amount));
        require(projects[projectId].swaps[swapId].swapCount == 0, "BRIDGEX: It's available just 1 swap with same: projectId, chainID, swapCount, from, to, amount");
        projects[projectId].swaps[swapId] = swap;

        if(msg.value > 0) {
            if (!oracleAddress.send(msg.value)) {
                oracleAddress.transfer(msg.value);
            }
        }

        emit SwapStart(projectId, swapId, _swapCount, toChainID, msg.sender, to, amount);
    }

    function swapEnd(bytes32 projectId, bytes32 swapId, uint swapCount, uint fromChainID, address from, address to, uint amount) public OnlyOracle onlyActiveChains(projectId, fromChainID) whenNotPaused {

        require(amount > 0 && to != address(0), "BRIDGEX: Primary Swap condition fail!");
        require(amount <= projects[projectId].balance, "BRIDGEX: Not enough token balance in bridge contract");
        uint _chainID = _getChainID();

        bytes32 processedSwapId = keccak256(abi.encode(projectId, swapCount, fromChainID, _chainID, from, to, amount));
        require(processedSwapId == swapId, "BRIDGEX: Swap ID Arguments do not match");
        require(projects[projectId].swaps[processedSwapId].isCompleted == false, "BRIDGEX: Swap already completed!");
        
        Swap memory swap = Swap({
            swapCount: swapCount,
            chainID: fromChainID,
            from: from,
            to: to,
            amount: amount,
            isCompleted: true
        });
        projects[projectId].swaps[processedSwapId] = swap;
        totalSwaps = totalSwaps.add(1);

        _transferToken(projectId, to, amount);
        emit SwapEnd(projectId, processedSwapId, swapCount, fromChainID, from, to, amount);
    }

    function setSwapComplete(bytes32 projectId, bytes32 swapId) external OnlyOracle{

        require(projects[projectId].swaps[swapId].isCompleted == false, "BRIDGEX: Swap already completed!");
        require(projects[projectId].swaps[swapId].swapCount != 0, "BRIDGEX: Event ID not found");
        require(projects[projectId].swaps[swapId].chainID == _getChainID(), "BRIDGEX: Swap from another chain should be completed from swapEnd()");
        projects[projectId].swaps[swapId].isCompleted = true;
        totalSwaps = totalSwaps.add(1);
        emit SwapCompleted(projectId, swapId);
    }

    function configureAddSupply(bytes32 projectId, uint _supplyTokens) external onlyTokenOwner(projectId) {

        require(IERC20(projects[projectId].tokenAddress).allowance(msg.sender, address(this)) >= _supplyTokens, "BRIDGEX: Not enough allowance");
        IERC20(projects[projectId].tokenAddress).safeTransferFrom(msg.sender, address(this), _supplyTokens);
        projects[projectId].balance = projects[projectId].balance.add(_supplyTokens);
    }

    function configureRemoveSupply(bytes32 projectId, uint _pullOutTokens) external onlyTokenOwner(projectId) {

        require(projects[projectId].active == false, "BRIDGEX: Project status must be inactive.");
        require(_pullOutTokens <= projects[projectId].balance,  "BRIDGEX: Project not enough balance.");
        _transferToken(projectId, msg.sender, _pullOutTokens);
    }
    
    function configureProjectSettings(bytes32 projectId, uint _maxAmount, bool _enableCommission, uint _swapCommissionPercent, address _swapCommissionReceiver) external onlyTokenOwner(projectId) {

        require(_swapCommissionReceiver != address(0), "BRIDGEX: Receiver address cannot be null");
        require(_swapCommissionPercent < 10000, "BRIDGEX: Commission must be less than 10000");        
        require(projects[projectId].owner != address(0), "BRIDGEX: Project Not Found!");

        projects[projectId].max_amount = _maxAmount;
        if(_enableCommission) {
            projects[projectId].swapCommissionPercent = _swapCommissionPercent;
            projects[projectId].swapCommissionReceiver = _swapCommissionReceiver;
        } else {
            projects[projectId].swapCommissionPercent = 0;
            projects[projectId].swapCommissionReceiver = address(0);
        }
    }

    function configureProjectStatus(bytes32 projectId, bool _status) external onlyTokenOwner(projectId) {

        require(projects[projectId].owner != address(0), "BRIDGEX: Project Not Found!");
        projects[projectId].active = _status;
        emit projectStatusChanged(projectId, _status);
    }

    function configureTransferProjectOwner(bytes32 projectId, address _newOwner) external onlyTokenOwner(projectId) {

        require(projects[projectId].owner != address(0), "BRIDGEX: Project Not Found!");
        projects[projectId].owner = _newOwner;
    }

    function sudoSetMultipleProjectsOracleFee(bytes32[] memory projectIds, uint[] memory chainIds, uint[] memory bridge_minOracleFee, uint[] memory chain_minOracleFee) external onlyOwner {

        for(uint i = 0; i < projectIds.length; i++) {
            if(projects[projectIds[i]].owner != address(0)) {
                projects[projectIds[i]].minOracleFee = bridge_minOracleFee[i];
            } else {
                continue;
            }

            for(uint j = 0; j < chainIds.length; j++) {
                if(projects[projectIds[i]].chains[chainIds[j]].tokenAddress != address(0)) {
                    projects[projectIds[i]].chains[chainIds[j]].minOracleFee = chain_minOracleFee[j];
                }
            }
        }
    }

    function sudoSetMultipleProjectsStatus(bytes32[] memory projectIds, bool[] memory _status) external onlyOwner {

        for(uint i = 0; i < projectIds.length; i++) {
            if(projects[projectIds[i]].owner != address(0)) {
                projects[projectIds[i]].active = _status[i];
                emit projectStatusChanged(projectIds[i], _status[i]);
            }
        }
    }

    function sudoConfigureTokenOwner(bytes32 projectId, address _owner) external onlyOwner {

        projects[projectId].owner = _owner;
    }

    function sudoConfigureChain(bytes32 projectId, uint chainID, address token_address, bool status, uint minOracleFee) external onlyOwner {

        require(chainID != _getChainID(), "BRIDGEX: Can`t change chain to current Chain ID");
        require(projects[projectId].chains[chainID].tokenAddress != address(0), "BRIDGEX: Chain is not registered");
        projects[projectId].chains[chainID].tokenAddress = token_address;
        projects[projectId].chains[chainID].active = status;
        projects[projectId].chains[chainID].minOracleFee = minOracleFee;
    }

    function sudoVerifyProjectWithOwner(bytes32 projectId) external onlyOwner {

        projects[projectId].ownerVerified = true;
    }

    function sudoAdjustProjectBalance(bytes32 projectId, uint _correctedAmount) external onlyOwner {

        projects[projectId].balance = _correctedAmount;
    }

    function sudoDeleteProject(bytes32 projectId) external onlyOwner {

        delete projects[projectId]; 
        totalProjects--;
    }

    function sudoChangeProviderAddress(address payable _newAddress) external onlyOwner {

        SERVICE_PROVIDER_ADDRESS = _newAddress;
    }

    function changeCreationCost(uint _newCost) public OnlyOracle {

        PROJECT_CREATION_COST = _newCost;
    }

    function createNewProject(bytes32 projectId, bool firstTimeChain, address[] calldata addressArray, uint[] calldata uintArray, uint _addSupply) external payable returns(bytes32) {

        
        require(msg.sender == owner() || msg.value.mul(1 gwei) >= PROJECT_CREATION_COST, "BRIDGEX: Insufficient amount sent to create project.");
        
        bytes32 newProjectId;
        if(firstTimeChain) {
            newProjectId = keccak256(abi.encode(addressArray[0], addressArray[1]));
        } else {
            newProjectId = projectId;
        }

        require(projects[newProjectId].tokenAddress == address(0), "BRIDGEX: Project already created!");
        
        Project storage project = projects[newProjectId];
        project.tokenAddress = addressArray[0];
        project.active = true;
        project.owner = addressArray[1];
        project.max_amount = uintArray[0];
        project.swapCommissionPercent = uintArray[1];
        project.swapCommissionReceiver = addressArray[2];
        project.minOracleFee = uintArray[2];

        totalProjects++;

        if(msg.value > 0) {
            if (!SERVICE_PROVIDER_ADDRESS.send(msg.value)) {
                SERVICE_PROVIDER_ADDRESS.transfer(msg.value);
            }
        }
        
        require(IERC20(projects[newProjectId].tokenAddress).allowance(msg.sender, address(this)) >= _addSupply, "BRIDGEX: Not enough allowance");
        
        IERC20(projects[newProjectId].tokenAddress).safeTransferFrom(msg.sender, address(this), _addSupply);
        projects[newProjectId].balance = projects[newProjectId].balance.add(_addSupply);

        emit newProjectCreated(newProjectId, addressArray[0], addressArray[1], _addSupply);

        return newProjectId;
    }

    function addNewChainToProject(bytes32 projectId, uint _chainID, address _tokenAddress, uint _minOracleFee) public onlyTokenOwner(projectId) returns(bool){

        require(_chainID != _getChainID(), "ORACLE: Can`t add current chain ID");
        require(projects[projectId].chains[_chainID].tokenAddress == address(0), "ORACLE: ChainID has already been registered");

        Chain memory chain = Chain({
            tokenAddress: _tokenAddress,
            active: true,
            swapCount: 0,
            minOracleFee: _minOracleFee
        });
        projects[projectId].chains[_chainID] = chain;

        emit newProjectChainCreated(projectId, _chainID, _tokenAddress);
        return true;
    }

    function pause() external onlyOwner whenNotPaused {

        _pause();
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {

        _unpause();
        emit Unpaused(msg.sender);
    }

    function _transferToken(bytes32 projectId, address to, uint amount) private {

        IERC20(projects[projectId].tokenAddress).safeTransfer(to, amount);
        projects[projectId].balance = projects[projectId].balance.sub(amount);
    }

    function _depositToken(bytes32 projectId, uint amount) private {

        IERC20(projects[projectId].tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        projects[projectId].balance = projects[projectId].balance.add(amount);
    }

    function calculateCommission(bytes32 projectId, uint amount) public view returns(uint fee){

        fee = projects[projectId].swapCommissionReceiver != address(0) ? amount.mul(projects[projectId].swapCommissionPercent).div(10000) : 0;
    }

    function _withdrawCommission(bytes32 projectId, uint commission) internal{

        if(commission > 0 && projects[projectId].swapCommissionReceiver != address(0)){
            _transferToken(projectId, projects[projectId].swapCommissionReceiver, commission);
        }
    }

    function _getChainID() internal view returns (uint) {

        uint id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function _isContract(address addr) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function seeProjectTokenBalance(bytes32 projectId) public view returns(uint balanceOf){

        return projects[projectId].balance;
    }

    function seeAnyTokenBalance(address tokenAddress) public view returns(uint balanceOf){

        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function seeSwapData(bytes32 projectId, bytes32 swapId) public view returns(uint counter, uint chainID, address from, uint amount, bool isCompleted){

        return (
            projects[projectId].swaps[swapId].swapCount,
            projects[projectId].swaps[swapId].chainID,
            projects[projectId].swaps[swapId].from,
            projects[projectId].swaps[swapId].amount,
            projects[projectId].swaps[swapId].isCompleted
        );
    }

    function seeChainData(bytes32 projectId, uint chainId) public view returns(address tokenAddress, bool active, uint swapCount, uint minOracleFee){

        return (
            projects[projectId].chains[chainId].tokenAddress,
            projects[projectId].chains[chainId].active,
            projects[projectId].chains[chainId].swapCount,
            projects[projectId].chains[chainId].minOracleFee
        );
    }

    function emergencyWithdrawTokens(address _tokenAddress, address _toAddress, uint256 _amount) external onlyOwner {

        IERC20(_tokenAddress).safeTransfer(_toAddress, _amount);
    }

    function emergencyWithdrawAsset(address payable toAddress) external onlyOwner {

        if(!toAddress.send(address(this).balance)) {
            return toAddress.transfer(address(this).balance);
        }
    }
}