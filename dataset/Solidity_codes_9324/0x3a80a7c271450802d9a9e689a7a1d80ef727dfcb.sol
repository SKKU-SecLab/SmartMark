


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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
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


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}





pragma solidity ^0.8.0;




interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



pragma solidity ^0.8.0;

interface TokenInterface{

    function burnFrom(address _from, uint _amount) external;

    function mintTo(address _to, uint _amount) external;

}



pragma solidity ^0.8.0;







contract LiquidityMining is Ownable, AccessControl {

    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    TokenInterface private fundamenta;
    

    bytes32 public constant _ADMIN = keccak256("_ADMIN");
    bytes32 public constant _REMOVAL = keccak256("_REMOVAL");
    bytes32 public constant _MOVE = keccak256("_MOVE");
    bytes32 public constant _RESCUE = keccak256("_RESCUE");
    
    
    bool public paused;
    bool public addDisabled;
    bool public removePositionOnly;
    
    uint private lockPeriod0;
    uint private lockPeriod1;
    uint private lockPeriod2;
    
    uint private lockPeriodBPScale;
    
    uint private preYieldDivisor;
    
    address private defaultAdmin = 0x82Ab0c69b6548e6Fd61365FeCc3256BcF70dc448;
    
     
    uint public periodCalc;
    
    
    
    struct LiquidityProviders {
        address Provider;
        uint UnlockHeight;
        uint LockedAmount;
        uint Days;
        uint UserBP;
        uint TotalRewardsPaid;
    }
    
    
    struct PoolInfo {
        IERC20 ContractAddress;
        uint TotalRewardsPaidByPool;
        uint TotalLPTokensLocked;
        uint PoolBonus;
        uint lockPeriod0BasisPoint;
        uint lockPeriod1BasisPoint;
        uint lockPeriod2BasisPoint;
        uint compYield0;
        uint compYield1;
        uint compYield2;
        uint maxPoolBP;
    }
    
    
    PoolInfo[] public poolInfo;
    
    
    mapping (uint => mapping (address => LiquidityProviders)) public provider;


    event PositionAdded (address _account, uint _amount, uint _blockHeight);
    event PositionRemoved (address _account, uint _amount, uint _blockHeight);
    event PositionForceRemoved (address _account, uint _amount, uint _blockHeight);
    event PositionCompounded (address _account, uint _amountAdded, uint _blockHeight);
    event ETHRescued (address _movedBy, address _movedTo, uint _amount, uint _blockHeight);
    event ERC20Movement (address _movedBy, address _movedTo, uint _amount, uint _blockHeight);
    
    
    
    constructor() {
        periodCalc = 6500;
        lockPeriodBPScale = 10000;
        preYieldDivisor = 2;
        lockPeriod0 = 5;
        lockPeriod1 = 10;
        lockPeriod2 = 15;
        removePositionOnly = false;
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin); //God Mode. DEFAULT_ADMIN_ROLE Must Require _ADMIN ROLE Still to execute _ADMIN functions.
    }
     
     
      modifier unpaused() {

        require(!paused, "LiquidityMining: Contract is Paused");
        _;
    }
    
     modifier addPositionNotDisabled() {

        require(!addDisabled, "LiquidityMining: Adding a Position is currently disabled");
        _;
    }
    
    modifier remPosOnly() {

        require(!removePositionOnly, "LiquidityMining: Only Removing a position is allowed at the moment");
        _;
    }
    

    function setPaused(bool _paused) external {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        paused = _paused;
    }
    
    function setRemovePosOnly(bool _removeOnly) external {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        removePositionOnly = _removeOnly;
    }
    
      function disableAdd(bool _addDisabled) external {

          require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        addDisabled = _addDisabled;
    }
    
    
    
    function addLiquidityPoolToken(
        IERC20 _lpTokenAddress, 
        uint _bonus, 
        uint _lpbp0, 
        uint _lpbp1, 
        uint _lpbp2, 
        uint _cy0, 
        uint _cy1, 
        uint _cy2,
        uint _mbp) public {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        poolInfo.push(PoolInfo({
            ContractAddress: _lpTokenAddress,
            TotalRewardsPaidByPool: 0,
            TotalLPTokensLocked: 0,
            PoolBonus: _bonus,
            lockPeriod0BasisPoint: _lpbp0,
            lockPeriod1BasisPoint: _lpbp1,
            lockPeriod2BasisPoint: _lpbp2,
            compYield0: _cy0,
            compYield1: _cy1,
            compYield2: _cy2,
            maxPoolBP: _mbp
        }));
  
    }

    
    function removeLiquidityPoolToken(uint _pid) public {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        delete poolInfo[_pid];
        
    }
    
    
    
     function poolLength() external view returns (uint) {

        return poolInfo.length;
    }
    

    function contractBalanceByPoolID(uint _pid) public view returns (uint _balance) {

        PoolInfo memory pool = poolInfo[_pid];
        address ca = address(this);
        return pool.ContractAddress.balanceOf(ca);
    }
    
    
    function accountPosition(address _account, uint _pid) public view returns (
        address _accountAddress, 
        uint _unlockHeight, 
        uint _lockedAmount, 
        uint _lockPeriodInDays, 
        uint _userDPY, 
        IERC20 _lpTokenAddress,
        uint _totalRewardsPaidFromPool
    ) {

        LiquidityProviders memory p = provider[_pid][_account];
        PoolInfo memory pool = poolInfo[_pid];
        return (
            p.Provider, 
            p.UnlockHeight, 
            p.LockedAmount, 
            p.Days, 
            p.UserBP, 
            pool.ContractAddress,
            pool.TotalRewardsPaidByPool
        );
    }
    
    
    function hasPosition(address _userAddress, uint _pid) public view returns (bool _hasPosition) {

        LiquidityProviders memory p = provider[_pid][_userAddress];
        if(p.LockedAmount == 0)
        return false;
        else 
        return true;
    }
    
    
    function showCurrentLockPeriods() external view returns (
        uint _lockPeriod0, 
        uint _lockPeriod1, 
        uint _lockPeriod2
    ) {

        return (
            lockPeriod0, 
            lockPeriod1, 
            lockPeriod2
        );
    }
    
    
    
    function setTokenContract(TokenInterface _fmta) public {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        fundamenta = _fmta;
    }
    
    
    function setLockPeriods(uint _newPeriod0, uint _newPeriod1, uint _newPeriod2) public {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        require(_newPeriod2 > _newPeriod1 && _newPeriod1 > _newPeriod0);
        lockPeriod0 = _newPeriod0;
        lockPeriod1 = _newPeriod1;
        lockPeriod2 = _newPeriod2;
    }
    
    
    function setPeriodCalc(uint _newPeriodCalc) public {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        periodCalc = _newPeriodCalc;
    }

    
    function setLockPeriodBasisPoints (
        uint _newLockPeriod0BasisPoint, 
        uint _newLockPeriod1BasisPoint, 
        uint _newLockPeriod2BasisPoint,
        uint _pid) public {
        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        poolInfo[_pid].lockPeriod0BasisPoint = _newLockPeriod0BasisPoint;
        poolInfo[_pid].lockPeriod1BasisPoint = _newLockPeriod1BasisPoint;
        poolInfo[_pid].lockPeriod2BasisPoint = _newLockPeriod2BasisPoint;
    }
    
    function setLockPeriodBPScale(uint _newLockPeriodScale) public {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        lockPeriodBPScale = _newLockPeriodScale;
    
    }

    function setMaxUserBP(uint _newMaxPoolBP, uint _pid) public {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        PoolInfo storage pool = poolInfo[_pid];
        pool.maxPoolBP = _newMaxPoolBP;
    }
    
    function setCompoundYield (
        uint _newCompoundYield0, 
        uint _newCompoundYield1, 
        uint _newCompoundYield2,
        uint _pid) public {
        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        poolInfo[_pid].compYield0 = _newCompoundYield0;
        poolInfo[_pid].compYield1 = _newCompoundYield1;
        poolInfo[_pid].compYield2 = _newCompoundYield2;
        
    }
    
    function setPoolBonus(uint _pid, uint _bonus) public {

        require(hasRole(_ADMIN, msg.sender));
        poolInfo[_pid].PoolBonus = _bonus;
    }

    function setPreYieldDivisor(uint _newDivisor) public {

        require(hasRole(_ADMIN, msg.sender),"LiquidityMining: Message Sender must be _ADMIN");
        preYieldDivisor = _newDivisor;
    }
    
    
    
    function addPosition(uint _lpTokenAmount, uint _lockPeriod, uint _pid) public addPositionNotDisabled unpaused{

        LiquidityProviders storage p = provider[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        address ca = address(this);
        require(p.LockedAmount == 0, "LiquidityMining: This account already has a position");
        if(_lockPeriod == lockPeriod0) {
            pool.ContractAddress.safeTransferFrom(msg.sender, ca, _lpTokenAmount);
            uint _preYield = _lpTokenAmount.mul(pool.lockPeriod0BasisPoint.add(pool.PoolBonus)).div(lockPeriodBPScale).mul(_lockPeriod);
            provider[_pid][msg.sender] = LiquidityProviders (
                msg.sender, 
                block.number.add(periodCalc.mul(lockPeriod0)), 
                _lpTokenAmount, 
                lockPeriod0, 
                pool.lockPeriod0BasisPoint,
                p.TotalRewardsPaid.add(_preYield.div(preYieldDivisor))
            );
            fundamenta.mintTo(msg.sender, _preYield.div(preYieldDivisor));
            pool.TotalLPTokensLocked = pool.TotalLPTokensLocked.add(_lpTokenAmount);
            pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(_preYield.div(preYieldDivisor));
        } else if (_lockPeriod == lockPeriod1) {
            pool.ContractAddress.safeTransferFrom(msg.sender, ca, _lpTokenAmount);
            uint _preYield = _lpTokenAmount.mul(pool.lockPeriod1BasisPoint.add(pool.PoolBonus)).div(lockPeriodBPScale).mul(_lockPeriod);
            provider[_pid][msg.sender] = LiquidityProviders (
                msg.sender, 
                block.number.add(periodCalc.mul(lockPeriod1)), 
                _lpTokenAmount, 
                lockPeriod1, 
                pool.lockPeriod1BasisPoint,
                p.TotalRewardsPaid.add(_preYield.div(preYieldDivisor))
            );
            fundamenta.mintTo(msg.sender, _preYield.div(preYieldDivisor));
            pool.TotalLPTokensLocked = pool.TotalLPTokensLocked.add(_lpTokenAmount);
            pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(_preYield.div(preYieldDivisor));
        } else if (_lockPeriod == lockPeriod2) {
            pool.ContractAddress.safeTransferFrom(msg.sender, ca, _lpTokenAmount);
            uint _preYield = _lpTokenAmount.mul(pool.lockPeriod2BasisPoint.add(pool.PoolBonus)).div(lockPeriodBPScale).mul(_lockPeriod);
            provider[_pid][msg.sender] = LiquidityProviders (
                msg.sender, 
                block.number.add(periodCalc.mul(lockPeriod2)), 
                _lpTokenAmount, 
                lockPeriod2, 
                pool.lockPeriod2BasisPoint,
                p.TotalRewardsPaid.add(_preYield.div(preYieldDivisor))
            );
            fundamenta.mintTo(msg.sender, _preYield.div(preYieldDivisor));
            pool.TotalLPTokensLocked = pool.TotalLPTokensLocked.add(_lpTokenAmount);
            pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(_preYield.div(preYieldDivisor));
        }else revert("LiquidityMining: Incompatible Lock Period");
      emit PositionAdded (
          msg.sender,
          _lpTokenAmount,
          block.number
      );
    }
    
    
    function removePosition(uint _pid) external unpaused {

        LiquidityProviders storage p = provider[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        require(p.UnlockHeight < block.number, "LiquidityMining: Not Long Enough");
            pool.ContractAddress.safeTransfer(msg.sender, p.LockedAmount);
            uint yield = calculateUserDailyYield(_pid);
            fundamenta.mintTo(msg.sender, yield);
            provider[_pid][msg.sender] = LiquidityProviders (
                msg.sender, 
                0, 
                p.LockedAmount.sub(p.LockedAmount),
                0, 
                0,
                p.TotalRewardsPaid.add(yield)
            );
        pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(yield);
        pool.TotalLPTokensLocked = pool.TotalLPTokensLocked.sub(p.LockedAmount);
        emit PositionRemoved(
        msg.sender,
        p.LockedAmount,
        block.number
      );
    }

    
    function forcePositionRemoval(uint _pid, address _account) public {

        require(hasRole(_REMOVAL, msg.sender));
        LiquidityProviders storage p = provider[_pid][_account];
        PoolInfo storage pool = poolInfo[_pid];
        uint yield = p.LockedAmount.mul(p.UserBP.add(pool.PoolBonus)).div(lockPeriodBPScale).mul(p.Days);
        fundamenta.mintTo(_account, yield);
        uint _lpTokenAmount = p.LockedAmount;
        pool.ContractAddress.safeTransfer(_account, _lpTokenAmount);
        uint _newLpTokenAmount = p.LockedAmount.sub(_lpTokenAmount);
        provider[_pid][_account] = LiquidityProviders (
            _account, 
            0, 
            _newLpTokenAmount, 
            0, 
            0,
            p.TotalRewardsPaid.add(yield)
        );
        pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(yield);
        pool.TotalLPTokensLocked = pool.TotalLPTokensLocked.sub(_lpTokenAmount);
        emit PositionForceRemoved(
        msg.sender,
        _lpTokenAmount,
        block.number
      );
    
    }

    
    function calculateUserDailyYield(uint _pid) public view returns (uint _dailyYield) {

        LiquidityProviders memory p = provider[_pid][msg.sender];
        PoolInfo memory pool = poolInfo[_pid];
        uint dailyYield = p.LockedAmount.mul(p.UserBP.add(pool.PoolBonus)).div(lockPeriodBPScale).mul(p.Days);
        return dailyYield;
    }
    
    
    function withdrawAccruedYieldAndAdd(uint _pid, uint _lpTokenAmount) public remPosOnly unpaused{

        LiquidityProviders storage p = provider[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        uint yield = calculateUserDailyYield(_pid);
        require(removePositionOnly == false);
        require(p.UnlockHeight < block.number);
        if (_lpTokenAmount != 0) {
            if(p.Days == lockPeriod0) {
                fundamenta.mintTo(msg.sender, yield);
                pool.ContractAddress.safeTransferFrom(msg.sender, address(this), _lpTokenAmount);
                provider[_pid][msg.sender] = LiquidityProviders (
                msg.sender, 
                    block.number.add(periodCalc.mul(lockPeriod0)), 
                    _lpTokenAmount.add(p.LockedAmount), 
                    lockPeriod0, 
                    p.UserBP.add(p.UserBP >= pool.maxPoolBP ? 0 : pool.compYield0),
                    p.TotalRewardsPaid.add(yield)
                );
                pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(yield);
                pool.TotalLPTokensLocked = pool.TotalLPTokensLocked.add(_lpTokenAmount);
            } else if (p.Days == lockPeriod1) {
                fundamenta.mintTo(msg.sender, yield);
                pool.ContractAddress.safeTransferFrom(msg.sender, address(this), _lpTokenAmount);
                provider[_pid][msg.sender] = LiquidityProviders (
                    msg.sender, 
                    block.number.add(periodCalc.mul(lockPeriod1)),
                    _lpTokenAmount.add(p.LockedAmount), 
                    lockPeriod1, 
                    p.UserBP.add(p.UserBP >= pool.maxPoolBP ? 0 : pool.compYield1),
                    p.TotalRewardsPaid.add(yield)
                );
                pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(yield);
                pool.TotalLPTokensLocked = pool.TotalLPTokensLocked.add(_lpTokenAmount);
            } else if (p.Days == lockPeriod2) {
                fundamenta.mintTo(msg.sender, yield);
                pool.ContractAddress.safeTransferFrom(msg.sender, address(this), _lpTokenAmount);
                provider[_pid][msg.sender] = LiquidityProviders (
                    msg.sender, 
                    block.number.add(periodCalc.mul(lockPeriod2)), 
                    _lpTokenAmount.add(p.LockedAmount), 
                    lockPeriod2, 
                    p.UserBP.add(p.UserBP >= pool.maxPoolBP ? 0 : pool.compYield2),
                    p.TotalRewardsPaid.add(yield)
                );
                pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(yield);
                pool.TotalLPTokensLocked = pool.TotalLPTokensLocked.add(_lpTokenAmount);
            } else revert("LiquidityMining: Incompatible Lock Period");
        } else if (_lpTokenAmount == 0) {
            if(p.Days == lockPeriod0) {
                fundamenta.mintTo(msg.sender, yield);
                provider[_pid][msg.sender] = LiquidityProviders (
                    msg.sender, 
                    block.number.add(periodCalc.mul(lockPeriod0)), 
                    p.LockedAmount, 
                    lockPeriod0, 
                    p.UserBP.add(p.UserBP >= pool.maxPoolBP ? 0 : pool.compYield0),
                    p.TotalRewardsPaid.add(yield)
                );
                pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(yield);
            } else if (p.Days == lockPeriod1) {
                fundamenta.mintTo(msg.sender, yield);
                provider[_pid][msg.sender] = LiquidityProviders (
                    msg.sender, 
                    block.number.add(periodCalc.mul(lockPeriod1)), 
                    p.LockedAmount, 
                    lockPeriod1, 
                    p.UserBP.add(p.UserBP >= pool.maxPoolBP ? 0 : pool.compYield1),
                    p.TotalRewardsPaid.add(yield)
                );
                pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(yield);
            } else if (p.Days == lockPeriod2) {
                fundamenta.mintTo(msg.sender, yield);
                provider[_pid][msg.sender] = LiquidityProviders (
                    msg.sender, 
                    block.number.add(periodCalc.mul(lockPeriod2)), 
                    p.LockedAmount, 
                    lockPeriod2, 
                    p.UserBP.add(p.UserBP >= pool.maxPoolBP ? 0 : pool.compYield2),
                    p.TotalRewardsPaid.add(yield)
                );
                pool.TotalRewardsPaidByPool = pool.TotalRewardsPaidByPool.add(yield);
            }else revert("LiquidityMining: Incompatible Lock Period");
        }else revert("LiquidityMining: ?" );
         emit PositionRemoved (
             msg.sender,
             _lpTokenAmount,
             block.number
         );
    }
    

    
    function moveERC20(address _ERC20, address _dest, uint _ERC20Amount) public {

        require(hasRole(_MOVE, msg.sender));
        IERC20(_ERC20).safeTransfer(_dest, _ERC20Amount);
        emit ERC20Movement (
            msg.sender,
            _dest,
            _ERC20Amount,
            block.number
        );

    }

    function ethRescue(address payable _dest, uint _etherAmount) public {

        require(hasRole(_RESCUE, msg.sender));
        _dest.transfer(_etherAmount);
        emit ETHRescued (
            msg.sender,
            _dest,
            _etherAmount,
            block.number
        );
    }
    
}