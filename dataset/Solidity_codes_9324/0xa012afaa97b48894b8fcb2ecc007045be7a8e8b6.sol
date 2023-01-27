

pragma solidity =0.8.10;




interface IBooster {

    struct PoolInfo {
        address lpToken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    function poolInfo(uint256) external view returns (PoolInfo memory);

    function deposit(uint256, uint256, bool) external returns (bool);

    function withdraw(uint256, uint256) external returns(bool);

}




interface IBaseRewardPool {

    function extraRewardsLength() external view returns (uint256);

    function extraRewards(uint256) external view returns (address);


    function earned(address) external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    
    function getReward(address, bool) external returns (bool);

    function stakeFor(address, uint256) external;


    function withdraw(uint256, bool) external returns (bool);

    function withdrawAndUnwrap(uint256, bool) external returns (bool);

}




interface IRewardPool {

    function rewardToken() external view returns (address);

    function earned(address) external view returns (uint256);

}





interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256 digits);

    function totalSupply() external view returns (uint256 supply);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}





abstract contract IWETH {
    function allowance(address, address) public virtual view returns (uint256);

    function balanceOf(address) public virtual view returns (uint256);

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;
}





library Address {

    error InsufficientBalance(uint256 available, uint256 required);
    error SendingValueFail();
    error InsufficientBalanceForCall(uint256 available, uint256 required);
    error NonContractCall();
    
    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        uint256 balance = address(this).balance;
        if (balance < amount){
            revert InsufficientBalance(balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!(success)){
            revert SendingValueFail();
        }
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

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
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        uint256 balance = address(this).balance;
        if (balance < value){
            revert InsufficientBalanceForCall(balance, value);
        }
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        if (!(isContract(target))){
            revert NonContractCall();
        }

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
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
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}






library TokenUtils {

    using SafeERC20 for IERC20;

    address public constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function approveToken(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) internal {

        if (_tokenAddr == ETH_ADDR) return;

        if (IERC20(_tokenAddr).allowance(address(this), _to) < _amount) {
            IERC20(_tokenAddr).safeApprove(_to, _amount);
        }
    }

    function pullTokensIfNeeded(
        address _token,
        address _from,
        uint256 _amount
    ) internal returns (uint256) {

        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, _from);
        }

        if (_from != address(0) && _from != address(this) && _token != ETH_ADDR && _amount != 0) {
            IERC20(_token).safeTransferFrom(_from, address(this), _amount);
        }

        return _amount;
    }

    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (uint256) {

        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, address(this));
        }

        if (_to != address(0) && _to != address(this) && _amount != 0) {
            if (_token != ETH_ADDR) {
                IERC20(_token).safeTransfer(_to, _amount);
            } else {
                (bool success, ) = _to.call{value: _amount}("");
                require(success, "Eth send fail");
            }
        }

        return _amount;
    }

    function depositWeth(uint256 _amount) internal {

        IWETH(WETH_ADDR).deposit{value: _amount}();
    }

    function withdrawWeth(uint256 _amount) internal {

        IWETH(WETH_ADDR).withdraw(_amount);
    }

    function getBalance(address _tokenAddr, address _acc) internal view returns (uint256) {

        if (_tokenAddr == ETH_ADDR) {
            return _acc.balance;
        } else {
            return IERC20(_tokenAddr).balanceOf(_acc);
        }
    }

    function getTokenDecimals(address _token) internal view returns (uint256) {

        if (_token == ETH_ADDR) return 18;

        return IERC20(_token).decimals();
    }
}




interface IConvexToken is IERC20 {

    function reductionPerCliff() external view returns (uint256);

    function totalCliffs() external view returns (uint256);

    function maxSupply() external view returns (uint256);

}




contract MainnetConvexAddresses {

    address internal constant CRV_ADDR = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address internal constant CVX_ADDR = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address internal constant BOOSTER_ADDR = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31; 
}









contract ConvexHelper is MainnetConvexAddresses {

    using SafeMath for uint256;
    using TokenUtils for address;

    uint256 internal constant CVX_TOTAL_CLIFFS = 1000;
    uint256 internal constant CVX_REDUCTION_PER_CLIFF = 1e23;
    uint256 internal constant CVX_MAX_SUPPLY = 1e26;

    struct Reward {
        address token;
        uint256 earned;
    }

    enum DepositOption {
        WRAP,
        STAKE,
        WRAP_AND_STAKE
    }

    enum WithdrawOption {
        UNWRAP,
        UNSTAKE,
        UNSTAKE_AND_UNWRAP
    }

    function _cvxMintAmount(uint256 _amount) internal view returns (uint256) {

        uint256 supply = IERC20(CVX_ADDR).totalSupply();
        
        uint256 cliff = supply.div(CVX_REDUCTION_PER_CLIFF);
        uint256 totalCliffs = CVX_TOTAL_CLIFFS;
        if(cliff < totalCliffs){
            uint256 reduction = totalCliffs.sub(cliff);
            _amount = _amount.mul(reduction).div(totalCliffs);

            uint256 amtTillMax = CVX_MAX_SUPPLY.sub(supply);
            if(_amount > amtTillMax){
                _amount = amtTillMax;
            }
        }

        return _amount;
    }

    function _earnedRewards(address _account, address _rewardContract) internal view returns (
        Reward[] memory rewards
    ) {

        uint256 crvEarned = IBaseRewardPool(_rewardContract).earned(_account);
        uint256 cvxEarned = _cvxMintAmount(crvEarned);
    
        uint256 extraRewardsLength = IBaseRewardPool(_rewardContract).extraRewardsLength();
        rewards = new Reward[](extraRewardsLength + 2);

        uint256 c = 2;
        for (uint256 i = 0; i < extraRewardsLength; i++) {
            address rewardPool = IBaseRewardPool(_rewardContract).extraRewards(i);
            address token = IRewardPool(rewardPool).rewardToken();
            uint256 earned = IRewardPool(rewardPool).earned(_account);
            if (token == CRV_ADDR) {
                crvEarned += earned;
                continue;
            }
            if (token == CVX_ADDR) {
                cvxEarned += earned;
                continue;
            }
            rewards[c++] = Reward(token, earned);
        }

        rewards[0] = Reward(CRV_ADDR, crvEarned);
        rewards[1] = Reward(CVX_ADDR, cvxEarned);
    }

    function _transferRewards(
        address _from,
        address _to,
        Reward[] memory _rewards
    ) internal returns (uint256) {

        if (_from != _to) {
            for (uint256 i = 0; i < _rewards.length; i++) {
                address token = _rewards[i].token;
                if (token == address(0)) break;
                uint256 earned = _rewards[i].earned;
                earned = token.pullTokensIfNeeded(_from,earned);
                token.withdrawTokens(_to, earned);
            }
        }

        return _rewards[0].earned;
    }
}





abstract contract IDFSRegistry {
 
    function getAddr(bytes4 _id) public view virtual returns (address);

    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public virtual;

    function startContractChange(bytes32 _id, address _newContractAddr) public virtual;

    function approveContractChange(bytes32 _id) public virtual;

    function cancelContractChange(bytes32 _id) public virtual;

    function changeWaitPeriod(bytes32 _id, uint256 _newWaitPeriod) public virtual;
}





contract MainnetAuthAddresses {

    address internal constant ADMIN_VAULT_ADDR = 0xCCf3d848e08b94478Ed8f46fFead3008faF581fD;
    address internal constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;
    address internal constant ADMIN_ADDR = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9; // USED IN ADMIN VAULT CONSTRUCTOR
}





contract AuthHelper is MainnetAuthAddresses {

}





contract AdminVault is AuthHelper {

    address public owner;
    address public admin;

    error SenderNotAdmin();

    constructor() {
        owner = msg.sender;
        admin = ADMIN_ADDR;
    }

    function changeOwner(address _owner) public {

        if (admin != msg.sender){
            revert SenderNotAdmin();
        }
        owner = _owner;
    }

    function changeAdmin(address _admin) public {

        if (admin != msg.sender){
            revert SenderNotAdmin();
        }
        admin = _admin;
    }

}








contract AdminAuth is AuthHelper {

    using SafeERC20 for IERC20;

    AdminVault public constant adminVault = AdminVault(ADMIN_VAULT_ADDR);

    error SenderNotOwner();
    error SenderNotAdmin();

    modifier onlyOwner() {

        if (adminVault.owner() != msg.sender){
            revert SenderNotOwner();
        }
        _;
    }

    modifier onlyAdmin() {

        if (adminVault.admin() != msg.sender){
            revert SenderNotAdmin();
        }
        _;
    }

    function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {

        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(_receiver).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    function kill() public onlyAdmin {

        selfdestruct(payable(msg.sender));
    }
}





contract DFSRegistry is AdminAuth {

    error EntryAlreadyExistsError(bytes4);
    error EntryNonExistentError(bytes4);
    error EntryNotInChangeError(bytes4);
    error ChangeNotReadyError(uint256,uint256);
    error EmptyPrevAddrError(bytes4);
    error AlreadyInContractChangeError(bytes4);
    error AlreadyInWaitPeriodChangeError(bytes4);

    event AddNewContract(address,bytes4,address,uint256);
    event RevertToPreviousAddress(address,bytes4,address,address);
    event StartContractChange(address,bytes4,address,address);
    event ApproveContractChange(address,bytes4,address,address);
    event CancelContractChange(address,bytes4,address,address);
    event StartWaitPeriodChange(address,bytes4,uint256);
    event ApproveWaitPeriodChange(address,bytes4,uint256,uint256);
    event CancelWaitPeriodChange(address,bytes4,uint256,uint256);

    struct Entry {
        address contractAddr;
        uint256 waitPeriod;
        uint256 changeStartTime;
        bool inContractChange;
        bool inWaitPeriodChange;
        bool exists;
    }

    mapping(bytes4 => Entry) public entries;
    mapping(bytes4 => address) public previousAddresses;

    mapping(bytes4 => address) public pendingAddresses;
    mapping(bytes4 => uint256) public pendingWaitTimes;

    function getAddr(bytes4 _id) public view returns (address) {

        return entries[_id].contractAddr;
    }

    function isRegistered(bytes4 _id) public view returns (bool) {

        return entries[_id].exists;
    }


    function addNewContract(
        bytes4 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public onlyOwner {

        if (entries[_id].exists){
            revert EntryAlreadyExistsError(_id);
        }

        entries[_id] = Entry({
            contractAddr: _contractAddr,
            waitPeriod: _waitPeriod,
            changeStartTime: 0,
            inContractChange: false,
            inWaitPeriodChange: false,
            exists: true
        });

        emit AddNewContract(msg.sender, _id, _contractAddr, _waitPeriod);
    }

    function revertToPreviousAddress(bytes4 _id) public onlyOwner {

        if (!(entries[_id].exists)){
            revert EntryNonExistentError(_id);
        }
        if (previousAddresses[_id] == address(0)){
            revert EmptyPrevAddrError(_id);
        }

        address currentAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = previousAddresses[_id];

        emit RevertToPreviousAddress(msg.sender, _id, currentAddr, previousAddresses[_id]);
    }

    function startContractChange(bytes4 _id, address _newContractAddr) public onlyOwner {

        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (entries[_id].inWaitPeriodChange){
            revert AlreadyInWaitPeriodChangeError(_id);
        }

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inContractChange = true;

        pendingAddresses[_id] = _newContractAddr;

        emit StartContractChange(msg.sender, _id, entries[_id].contractAddr, _newContractAddr);
    }

    function approveContractChange(bytes4 _id) public onlyOwner {

        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inContractChange){
            revert EntryNotInChangeError(_id);
        }
        if (block.timestamp < (entries[_id].changeStartTime + entries[_id].waitPeriod)){// solhint-disable-line
            revert ChangeNotReadyError(block.timestamp, (entries[_id].changeStartTime + entries[_id].waitPeriod));
        }

        address oldContractAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = pendingAddresses[_id];
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        pendingAddresses[_id] = address(0);
        previousAddresses[_id] = oldContractAddr;

        emit ApproveContractChange(msg.sender, _id, oldContractAddr, entries[_id].contractAddr);
    }

    function cancelContractChange(bytes4 _id) public onlyOwner {

        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inContractChange){
            revert EntryNotInChangeError(_id);
        }

        address oldContractAddr = pendingAddresses[_id];

        pendingAddresses[_id] = address(0);
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        emit CancelContractChange(msg.sender, _id, oldContractAddr, entries[_id].contractAddr);
    }

    function startWaitPeriodChange(bytes4 _id, uint256 _newWaitPeriod) public onlyOwner {

        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (entries[_id].inContractChange){
            revert AlreadyInContractChangeError(_id);
        }

        pendingWaitTimes[_id] = _newWaitPeriod;

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inWaitPeriodChange = true;

        emit StartWaitPeriodChange(msg.sender, _id, _newWaitPeriod);
    }

    function approveWaitPeriodChange(bytes4 _id) public onlyOwner {

        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inWaitPeriodChange){
            revert EntryNotInChangeError(_id);
        }
        if (block.timestamp < (entries[_id].changeStartTime + entries[_id].waitPeriod)){ // solhint-disable-line
            revert ChangeNotReadyError(block.timestamp, (entries[_id].changeStartTime + entries[_id].waitPeriod));
        }

        uint256 oldWaitTime = entries[_id].waitPeriod;
        entries[_id].waitPeriod = pendingWaitTimes[_id];
        
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        pendingWaitTimes[_id] = 0;

        emit ApproveWaitPeriodChange(msg.sender, _id, oldWaitTime, entries[_id].waitPeriod);
    }

    function cancelWaitPeriodChange(bytes4 _id) public onlyOwner {

        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inWaitPeriodChange){
            revert EntryNotInChangeError(_id);
        }

        uint256 oldWaitPeriod = pendingWaitTimes[_id];

        pendingWaitTimes[_id] = 0;
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        emit CancelWaitPeriodChange(msg.sender, _id, oldWaitPeriod, entries[_id].waitPeriod);
    }
}





abstract contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view virtual returns (bool);
}





contract DSAuthEvents {

    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {

    DSAuthority public authority;
    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {

        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig), "Not authorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(address(0))) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}





contract DSNote {

    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 indexed bar,
        uint256 wad,
        bytes fax
    ) anonymous;

    modifier note {

        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}






abstract contract DSProxy is DSAuth, DSNote {
    DSProxyCache public cache; // global cache for contracts

    constructor(address _cacheAddr) {
        if (!(setCache(_cacheAddr))){
            require(isAuthorized(msg.sender, msg.sig), "Not authorized");
        }
    }

    receive() external payable {}

    function execute(bytes memory _code, bytes memory _data)
        public
        payable
        virtual
        returns (address target, bytes32 response);

    function execute(address _target, bytes memory _data)
        public
        payable
        virtual
        returns (bytes32 response);

    function setCache(address _cacheAddr) public payable virtual returns (bool);
}

contract DSProxyCache {

    mapping(bytes32 => address) cache;

    function read(bytes memory _code) public view returns (address) {

        bytes32 hash = keccak256(_code);
        return cache[hash];
    }

    function write(bytes memory _code) public returns (address target) {

        assembly {
            target := create(0, add(_code, 0x20), mload(_code))
            switch iszero(extcodesize(target))
                case 1 {
                    revert(0, 0)
                }
        }
        bytes32 hash = keccak256(_code);
        cache[hash] = target;
    }
}





contract DefisaverLogger {

    event RecipeEvent(
        address indexed caller,
        string indexed logName
    );

    event ActionDirectEvent(
        address indexed caller,
        string indexed logName,
        bytes data
    );

    function logRecipeEvent(
        string memory _logName
    ) public {

        emit RecipeEvent(msg.sender, _logName);
    }

    function logActionDirectEvent(
        string memory _logName,
        bytes memory _data
    ) public {

        emit ActionDirectEvent(msg.sender, _logName, _data);
    }
}





contract MainnetActionsUtilAddresses {

    address internal constant DFS_REG_CONTROLLER_ADDR = 0xF8f8B3C98Cf2E63Df3041b73f80F362a4cf3A576;
    address internal constant REGISTRY_ADDR = 0x287778F121F134C66212FB16c9b53eC991D32f5b;
    address internal constant DFS_LOGGER_ADDR = 0xcE7a977Cac4a481bc84AC06b2Da0df614e621cf3;
    address internal constant SUB_STORAGE_ADDR = 0x1612fc28Ee0AB882eC99842Cde0Fc77ff0691e90;
}





contract ActionsUtilHelper is MainnetActionsUtilAddresses {

}








abstract contract ActionBase is AdminAuth, ActionsUtilHelper {
    event ActionEvent(
        string indexed logName,
        bytes data
    );

    DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);

    DefisaverLogger public constant logger = DefisaverLogger(
        DFS_LOGGER_ADDR
    );

    error SubIndexValueError();
    error ReturnIndexValueError();

    uint8 public constant SUB_MIN_INDEX_VALUE = 128;
    uint8 public constant SUB_MAX_INDEX_VALUE = 255;

    uint8 public constant RETURN_MIN_INDEX_VALUE = 1;
    uint8 public constant RETURN_MAX_INDEX_VALUE = 127;

    uint8 public constant NO_PARAM_MAPPING = 0;

    enum ActionType { FL_ACTION, STANDARD_ACTION, FEE_ACTION, CHECK_ACTION, CUSTOM_ACTION }

    function executeAction(
        bytes memory _callData,
        bytes32[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable virtual returns (bytes32);

    function executeActionDirect(bytes memory _callData) public virtual payable;

    function actionType() public pure virtual returns (uint8);



    function _parseParamUint(
        uint _param,
        uint8 _mapType,
        bytes32[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (uint) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = uint(_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = uint256(_subData[getSubIndex(_mapType)]);
            }
        }

        return _param;
    }


    function _parseParamAddr(
        address _param,
        uint8 _mapType,
        bytes32[] memory _subData,
        bytes32[] memory _returnValues
    ) internal view returns (address) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = address(bytes20((_returnValues[getReturnIndex(_mapType)])));
            } else {
                if (_mapType == 254) return address(this); //DSProxy address
                if (_mapType == 255) return DSProxy(payable(address(this))).owner(); // owner of DSProxy

                _param = address(uint160(uint256(_subData[getSubIndex(_mapType)])));
            }
        }

        return _param;
    }

    function _parseParamABytes32(
        bytes32 _param,
        uint8 _mapType,
        bytes32[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (bytes32) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = (_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = _subData[getSubIndex(_mapType)];
            }
        }

        return _param;
    }

    function isReplaceable(uint8 _type) internal pure returns (bool) {
        return _type != NO_PARAM_MAPPING;
    }

    function isReturnInjection(uint8 _type) internal pure returns (bool) {
        return (_type >= RETURN_MIN_INDEX_VALUE) && (_type <= RETURN_MAX_INDEX_VALUE);
    }

    function getReturnIndex(uint8 _type) internal pure returns (uint8) {
        if (!(isReturnInjection(_type))){
            revert SubIndexValueError();
        }

        return (_type - RETURN_MIN_INDEX_VALUE);
    }

    function getSubIndex(uint8 _type) internal pure returns (uint8) {
        if (_type < SUB_MIN_INDEX_VALUE){
            revert ReturnIndexValueError();
        }
        return (_type - SUB_MIN_INDEX_VALUE);
    }
}









contract ConvexClaim is ConvexHelper, ActionBase {

    using TokenUtils for address;

    struct Params {
        address from;
        address to;
        address rewardContract;
    }

    function executeAction(
        bytes calldata _callData,
        bytes32[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable override returns (bytes32) {

        Params memory params = parseInputs(_callData);
        params.from = _parseParamAddr(params.from, _paramMapping[0], _subData, _returnValues);
        params.to = _parseParamAddr(params.to, _paramMapping[1], _subData, _returnValues);
        params.rewardContract = _parseParamAddr(params.rewardContract, _paramMapping[2], _subData, _returnValues);
        
        (uint256 crvEarned, bytes memory logData) = _claim(params);
        emit ActionEvent("ConvexClaim", logData);
        return bytes32(crvEarned);
    }

    function executeActionDirect(bytes calldata _callData) public payable override {

        Params memory params = parseInputs(_callData);
        (, bytes memory logData) = _claim(params);
        logger.logActionDirectEvent("ConvexClaim", logData);
    }

    function actionType() public pure virtual override returns (uint8) {

        return uint8(ActionType.STANDARD_ACTION);
    }

    function _claim(Params memory _params) internal returns (uint256 crvEarned, bytes memory logData) {

        Reward[] memory rewards = _earnedRewards(_params.from, _params.rewardContract);
        IBaseRewardPool(_params.rewardContract).getReward(_params.from, true);

        crvEarned = _transferRewards(_params.from, _params.to, rewards);
        logData = abi.encode(_params, rewards);
    }

    function parseInputs(bytes calldata _callData) internal pure returns (Params memory params) {

        params = abi.decode(_callData, (Params));
    }
}