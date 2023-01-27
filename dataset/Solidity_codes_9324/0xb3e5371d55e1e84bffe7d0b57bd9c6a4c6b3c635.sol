
pragma solidity =0.7.6;  
pragma experimental ABIEncoderV2;


abstract contract ILendingPool {
    function flashLoan(
        address payable _receiver,
        address _reserve,
        uint256 _amount,
        bytes calldata _params
    ) external virtual;

    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable virtual;

    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral)
        external
        virtual;

    function borrow(
        address _reserve,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode
    ) external virtual;

    function repay(
        address _reserve,
        uint256 _amount,
        address payable _onBehalfOf
    ) external payable virtual;

    function swapBorrowRateMode(address _reserve) external virtual;

    function getReserves() external view virtual returns (address[] memory);

    function getReserveData(address _reserve)
        external
        view
        virtual
        returns (
            uint256 totalLiquidity, // reserve total liquidity
            uint256 availableLiquidity, // reserve available liquidity for borrowing
            uint256 totalBorrowsStable, // total amount of outstanding borrows at Stable rate
            uint256 totalBorrowsVariable, // total amount of outstanding borrows at Variable rate
            uint256 liquidityRate, // current deposit APY of the reserve for depositors, in Ray units.
            uint256 variableBorrowRate, // current variable rate APY of the reserve pool, in Ray units.
            uint256 stableBorrowRate, // current stable rate APY of the reserve pool, in Ray units.
            uint256 averageStableBorrowRate, // current average stable borrow rate
            uint256 utilizationRate, // expressed as total borrows/total liquidity.
            uint256 liquidityIndex, // cumulative liquidity index
            uint256 variableBorrowIndex, // cumulative variable borrow index
            address aTokenAddress, // aTokens contract address for the specific _reserve
            uint40 lastUpdateTimestamp // timestamp of the last update of reserve data
        );

    function getUserAccountData(address _user)
        external
        view
        virtual
        returns (
            uint256 totalLiquidityETH, // user aggregated deposits across all the reserves. In Wei
            uint256 totalCollateralETH, // user aggregated collateral across all the reserves. In Wei
            uint256 totalBorrowsETH, // user aggregated outstanding borrows across all the reserves. In Wei
            uint256 totalFeesETH, // user aggregated current outstanding fees in ETH. In Wei
            uint256 availableBorrowsETH, // user available amount to borrow in ETH
            uint256 currentLiquidationThreshold, // user current average liquidation threshold across all the collaterals deposited
            uint256 ltv, // user average Loan-to-Value between all the collaterals
            uint256 healthFactor // user current Health Factor
        );

    function getUserReserveData(address _reserve, address _user)
        external
        view
        virtual
        returns (
            uint256 currentATokenBalance, // user current reserve aToken balance
            uint256 currentBorrowBalance, // user current reserve outstanding borrow balance
            uint256 principalBorrowBalance, // user balance of borrowed asset
            uint256 borrowRateMode, // user borrow rate mode either Stable or Variable
            uint256 borrowRate, // user current borrow rate APY
            uint256 liquidityRate, // user current earn rate on _reserve
            uint256 originationFee, // user outstanding loan origination fee
            uint256 variableBorrowIndex, // user variable cumulative index
            uint256 lastUpdateTimestamp, // Timestamp of the last data update
            bool usageAsCollateralEnabled // Whether the user's current reserve is enabled as a collateral
        );

    function getReserveConfigurationData(address _reserve)
        external
        view
        virtual
        returns (
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            address rateStrategyAddress,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive
        );

    function getReserveATokenAddress(address _reserve) public view virtual returns (address);

    function getReserveConfiguration(address _reserve)
        external
        view
        virtual
        returns (
            uint256,
            uint256,
            uint256,
            bool
        );

    function getUserUnderlyingAssetBalance(address _reserve, address _user)
        public
        view
        virtual
        returns (uint256);

    function getReserveCurrentLiquidityRate(address _reserve) public view virtual returns (uint256);

    function getReserveCurrentVariableBorrowRate(address _reserve)
        public
        view
        virtual
        returns (uint256);

    function getReserveTotalLiquidity(address _reserve) public view virtual returns (uint256);

    function getReserveAvailableLiquidity(address _reserve) public view virtual returns (uint256);

    function getReserveTotalBorrowsVariable(address _reserve) public view virtual returns (uint256);

    function calculateUserGlobalData(address _user)
        public
        view
        virtual
        returns (
            uint256 totalLiquidityBalanceETH,
            uint256 totalCollateralBalanceETH,
            uint256 totalBorrowBalanceETH,
            uint256 totalFeesETH,
            uint256 currentLtv,
            uint256 currentLiquidationThreshold,
            uint256 healthFactor,
            bool healthFactorBelowThreshold
        );
}  



abstract contract DSGuard {
    function canCall(
        address src_,
        address dst_,
        bytes4 sig
    ) public view virtual returns (bool);

    function permit(
        bytes32 src,
        bytes32 dst,
        bytes32 sig
    ) public virtual;

    function forbid(
        bytes32 src,
        bytes32 dst,
        bytes32 sig
    ) public virtual;

    function permit(
        address src,
        address dst,
        bytes32 sig
    ) public virtual;

    function forbid(
        address src,
        address dst,
        bytes32 sig
    ) public virtual;
}

abstract contract DSGuardFactory {
    function newGuard() public virtual returns (DSGuard guard);
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
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}  






contract ProxyPermission {

    address public constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;

    function givePermission(address _contractAddr) public {

        address currAuthority = address(DSAuth(address(this)).authority());
        DSGuard guard = DSGuard(currAuthority);

        if (currAuthority == address(0)) {
            guard = DSGuardFactory(FACTORY_ADDRESS).newGuard();
            DSAuth(address(this)).setAuthority(DSAuthority(address(guard)));
        }

        guard.permit(_contractAddr, address(this), bytes4(keccak256("execute(address,bytes)")));
    }

    function removePermission(address _contractAddr) public {

        address currAuthority = address(DSAuth(address(this)).authority());

        if (currAuthority == address(0)) {
            return;
        }

        DSGuard guard = DSGuard(currAuthority);
        guard.forbid(_contractAddr, address(this), bytes4(keccak256("execute(address,bytes)")));
    }

    function proxyOwner() internal view returns (address) {

        return DSAuth(address(this)).owner();
    }
}  



abstract contract IDFSRegistry {
 
    function getAddr(bytes32 _id) public view virtual returns (address);

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



interface IERC20 {

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


    function decimals() external view returns (uint256 digits);


    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}  



library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

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



contract AdminVault {

    address public owner;
    address public admin;

    constructor() {
        owner = msg.sender;
        admin = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
    }

    function changeOwner(address _owner) public {

        require(admin == msg.sender, "msg.sender not admin");
        owner = _owner;
    }

    function changeAdmin(address _admin) public {

        require(admin == msg.sender, "msg.sender not admin");
        admin = _admin;
    }

}  








contract AdminAuth {

    using SafeERC20 for IERC20;

    AdminVault public constant adminVault = AdminVault(0xCCf3d848e08b94478Ed8f46fFead3008faF581fD);

    modifier onlyOwner() {

        require(adminVault.owner() == msg.sender, "msg.sender not owner");
        _;
    }

    modifier onlyAdmin() {

        require(adminVault.admin() == msg.sender, "msg.sender not admin");
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



contract DefisaverLogger {

    event LogEvent(
        address indexed contractAddress,
        address indexed caller,
        string indexed logName,
        bytes data
    );

    function Log(
        address _contract,
        address _caller,
        string memory _logName,
        bytes memory _data
    ) public {

        emit LogEvent(_contract, _caller, _logName, _data);
    }
}  






contract DFSRegistry is AdminAuth {

    DefisaverLogger public constant logger = DefisaverLogger(
        0x5c55B921f590a89C1Ebe84dF170E655a82b62126
    );

    string public constant ERR_ENTRY_ALREADY_EXISTS = "Entry id already exists";
    string public constant ERR_ENTRY_NON_EXISTENT = "Entry id doesn't exists";
    string public constant ERR_ENTRY_NOT_IN_CHANGE = "Entry not in change process";
    string public constant ERR_WAIT_PERIOD_SHORTER = "New wait period must be bigger";
    string public constant ERR_CHANGE_NOT_READY = "Change not ready yet";
    string public constant ERR_EMPTY_PREV_ADDR = "Previous addr is 0";
    string public constant ERR_ALREADY_IN_CONTRACT_CHANGE = "Already in contract change";
    string public constant ERR_ALREADY_IN_WAIT_PERIOD_CHANGE = "Already in wait period change";

    struct Entry {
        address contractAddr;
        uint256 waitPeriod;
        uint256 changeStartTime;
        bool inContractChange;
        bool inWaitPeriodChange;
        bool exists;
    }

    mapping(bytes32 => Entry) public entries;
    mapping(bytes32 => address) public previousAddresses;

    mapping(bytes32 => address) public pendingAddresses;
    mapping(bytes32 => uint256) public pendingWaitTimes;

    function getAddr(bytes32 _id) public view returns (address) {

        return entries[_id].contractAddr;
    }

    function isRegistered(bytes32 _id) public view returns (bool) {

        return entries[_id].exists;
    }


    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public onlyOwner {

        require(!entries[_id].exists, ERR_ENTRY_ALREADY_EXISTS);

        entries[_id] = Entry({
            contractAddr: _contractAddr,
            waitPeriod: _waitPeriod,
            changeStartTime: 0,
            inContractChange: false,
            inWaitPeriodChange: false,
            exists: true
        });

        previousAddresses[_id] = _contractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "AddNewContract",
            abi.encode(_id, _contractAddr, _waitPeriod)
        );
    }

    function revertToPreviousAddress(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(previousAddresses[_id] != address(0), ERR_EMPTY_PREV_ADDR);

        address currentAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = previousAddresses[_id];

        logger.Log(
            address(this),
            msg.sender,
            "RevertToPreviousAddress",
            abi.encode(_id, currentAddr, previousAddresses[_id])
        );
    }

    function startContractChange(bytes32 _id, address _newContractAddr) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(!entries[_id].inWaitPeriodChange, ERR_ALREADY_IN_WAIT_PERIOD_CHANGE);

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inContractChange = true;

        pendingAddresses[_id] = _newContractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "StartContractChange",
            abi.encode(_id, entries[_id].contractAddr, _newContractAddr)
        );
    }

    function approveContractChange(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inContractChange, ERR_ENTRY_NOT_IN_CHANGE);
        require(
            block.timestamp >= (entries[_id].changeStartTime + entries[_id].waitPeriod), // solhint-disable-line
            ERR_CHANGE_NOT_READY
        );

        address oldContractAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = pendingAddresses[_id];
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        pendingAddresses[_id] = address(0);
        previousAddresses[_id] = oldContractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "ApproveContractChange",
            abi.encode(_id, oldContractAddr, entries[_id].contractAddr)
        );
    }

    function cancelContractChange(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inContractChange, ERR_ENTRY_NOT_IN_CHANGE);

        address oldContractAddr = pendingAddresses[_id];

        pendingAddresses[_id] = address(0);
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        logger.Log(
            address(this),
            msg.sender,
            "CancelContractChange",
            abi.encode(_id, oldContractAddr, entries[_id].contractAddr)
        );
    }

    function startWaitPeriodChange(bytes32 _id, uint256 _newWaitPeriod) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(!entries[_id].inContractChange, ERR_ALREADY_IN_CONTRACT_CHANGE);

        pendingWaitTimes[_id] = _newWaitPeriod;

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inWaitPeriodChange = true;

        logger.Log(
            address(this),
            msg.sender,
            "StartWaitPeriodChange",
            abi.encode(_id, _newWaitPeriod)
        );
    }

    function approveWaitPeriodChange(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inWaitPeriodChange, ERR_ENTRY_NOT_IN_CHANGE);
        require(
            block.timestamp >= (entries[_id].changeStartTime + entries[_id].waitPeriod), // solhint-disable-line
            ERR_CHANGE_NOT_READY
        );

        uint256 oldWaitTime = entries[_id].waitPeriod;
        entries[_id].waitPeriod = pendingWaitTimes[_id];
        
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        pendingWaitTimes[_id] = 0;

        logger.Log(
            address(this),
            msg.sender,
            "ApproveWaitPeriodChange",
            abi.encode(_id, oldWaitTime, entries[_id].waitPeriod)
        );
    }

    function cancelWaitPeriodChange(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inWaitPeriodChange, ERR_ENTRY_NOT_IN_CHANGE);

        uint256 oldWaitPeriod = pendingWaitTimes[_id];

        pendingWaitTimes[_id] = 0;
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        logger.Log(
            address(this),
            msg.sender,
            "CancelWaitPeriodChange",
            abi.encode(_id, oldWaitPeriod, entries[_id].waitPeriod)
        );
    }
}  


 




abstract contract ActionBase is AdminAuth {
    address public constant REGISTRY_ADDR = 0xD6049E1F5F3EfF1F921f5532aF1A1632bA23929C;
    DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);

    DefisaverLogger public constant logger = DefisaverLogger(
        0x5c55B921f590a89C1Ebe84dF170E655a82b62126
    );

    string public constant ERR_SUB_INDEX_VALUE = "Wrong sub index value";
    string public constant ERR_RETURN_INDEX_VALUE = "Wrong return index value";

    uint8 public constant SUB_MIN_INDEX_VALUE = 128;
    uint8 public constant SUB_MAX_INDEX_VALUE = 255;

    uint8 public constant RETURN_MIN_INDEX_VALUE = 1;
    uint8 public constant RETURN_MAX_INDEX_VALUE = 127;

    uint8 public constant NO_PARAM_MAPPING = 0;

    enum ActionType { FL_ACTION, STANDARD_ACTION, CUSTOM_ACTION }

    function executeAction(
        bytes[] memory _callData,
        bytes[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable virtual returns (bytes32);

    function executeActionDirect(bytes[] memory _callData) public virtual payable;

    function actionType() public pure virtual returns (uint8);



    function _parseParamUint(
        uint _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (uint) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = uint(_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = abi.decode(_subData[getSubIndex(_mapType)], (uint));
            }
        }

        return _param;
    }


    function _parseParamAddr(
        address _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (address) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = address(bytes20((_returnValues[getReturnIndex(_mapType)])));
            } else {
                _param = abi.decode(_subData[getSubIndex(_mapType)], (address));
            }
        }

        return _param;
    }

    function _parseParamABytes32(
        bytes32 _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (bytes32) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = (_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = abi.decode(_subData[getSubIndex(_mapType)], (bytes32));
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
        require(isReturnInjection(_type), ERR_SUB_INDEX_VALUE);

        return (_type - RETURN_MIN_INDEX_VALUE);
    }

    function getSubIndex(uint8 _type) internal pure returns (uint8) {
        require(_type >= SUB_MIN_INDEX_VALUE, ERR_RETURN_INDEX_VALUE);

        return (_type - SUB_MIN_INDEX_VALUE);
    }
}  



abstract contract IDSProxy {

    function execute(address _target, bytes memory _data) public payable virtual returns (bytes32);

    function setCache(address _cacheAddr) public payable virtual returns (bool);

    function owner() public view virtual returns (address);
}  


 

contract StrategyData {

    struct Template {
        string name;
        bytes32[] triggerIds;
        bytes32[] actionIds;
        uint8[][] paramMapping;
    }

    struct Task {
        string name;
        bytes[][] callData;
        bytes[][] subData;
        bytes32[] actionIds;
        uint8[][] paramMapping;
    }

    struct Strategy {
        uint templateId;
        address proxy;
        bytes[][] subData;
        bytes[][] triggerData;
        bool active;

        uint posInUserArr;
    }
}  


 






contract Subscriptions is StrategyData, AdminAuth {

    DefisaverLogger public constant logger = DefisaverLogger(0x5c55B921f590a89C1Ebe84dF170E655a82b62126);

    string public constant ERR_EMPTY_STRATEGY = "Strategy does not exist";
    string public constant ERR_SENDER_NOT_OWNER = "Sender is not strategy owner";
    string public constant ERR_USER_POS_EMPTY = "No user positions";

    Strategy[] public strategies;

    Template[] public templates;

    mapping (address => uint[]) public usersPos;

    uint public updateCounter;

    function createStrategy(
        uint _templateId,
        bool _active,
        bytes[][] memory _subData,
        bytes[][] memory _triggerData
    ) public returns (uint) {

        strategies.push(
            Strategy({
                templateId: _templateId,
                proxy: msg.sender,
                active: _active,
                subData: _subData,
                triggerData: _triggerData,
                posInUserArr: (usersPos[msg.sender].length - 1)
            })
        );

        usersPos[msg.sender].push(strategies.length - 1);

        updateCounter++;

        logger.Log(address(this), msg.sender, "CreateStrategy", abi.encode(strategies.length - 1));

        return strategies.length - 1;
    }

    function createTemplate(
        string memory _name,
        bytes32[] memory _triggerIds,
        bytes32[] memory _actionIds,
        uint8[][] memory _paramMapping
    ) public returns (uint) {

        
        templates.push(
            Template({
                name: _name,
                triggerIds: _triggerIds,
                actionIds: _actionIds,
                paramMapping: _paramMapping
            })
        );

        updateCounter++;

        logger.Log(address(this), msg.sender, "CreateTemplate", abi.encode(templates.length - 1));

        return templates.length - 1;
    }

    function updateStrategy(
        uint _strategyId,
        uint _templateId,
        bool _active,
        bytes[][] memory _subData,
        bytes[][] memory _triggerData
    ) public {

        Strategy storage s = strategies[_strategyId];

        require(s.proxy != address(0), ERR_EMPTY_STRATEGY);
        require(msg.sender == s.proxy, ERR_SENDER_NOT_OWNER);

        s.templateId = _templateId;
        s.active = _active;
        s.subData = _subData;
        s.triggerData = _triggerData;

        updateCounter++;

        logger.Log(address(this), msg.sender, "UpdateStrategy", abi.encode(_strategyId));
    }

    function removeStrategy(uint256 _subId) public {

        Strategy memory s = strategies[_subId];
        require(s.proxy != address(0), ERR_EMPTY_STRATEGY);
        require(msg.sender == s.proxy, ERR_SENDER_NOT_OWNER);

        uint lastSub = strategies.length - 1;

        _removeUserPos(msg.sender, s.posInUserArr);

        strategies[_subId] = strategies[lastSub]; // last strategy put in place of the deleted one
        strategies.pop(); // delete last strategy, because it moved

        logger.Log(address(this), msg.sender, "Unsubscribe", abi.encode(_subId));
    }

    function _removeUserPos(address _user, uint _index) internal {

        require(usersPos[_user].length > 0, ERR_USER_POS_EMPTY);
        uint lastPos = usersPos[_user].length - 1;

        usersPos[_user][_index] = usersPos[_user][lastPos];
        usersPos[_user].pop();
    }


    function getTemplateFromStrategy(uint _strategyId) public view returns (Template memory) {

        uint templateId = strategies[_strategyId].templateId;
        return templates[templateId];
    }

    function getStrategy(uint _strategyId) public view returns (Strategy memory) {

        return strategies[_strategyId];
    }

    function getTemplate(uint _templateId) public view returns (Template memory) {

        return templates[_templateId];
    }

    function getStrategyCount() public view returns (uint256) {

        return strategies.length;
    }

    function getTemplateCount() public view returns (uint256) {

        return templates.length;
    }

    function getStrategies() public view returns (Strategy[] memory) {

        return strategies;
    }

    function getTemplates() public view returns (Template[] memory) {

        return templates;
    }

    function userHasStrategies(address _user) public view returns (bool) {

        return usersPos[_user].length > 0;
    }

    function getUserStrategies(address _user) public view returns (Strategy[] memory) {

        Strategy[] memory userStrategies = new Strategy[](usersPos[_user].length);
        
        for (uint i = 0; i < usersPos[_user].length; ++i) {
            userStrategies[i] = strategies[usersPos[_user][i]];
        }

        return userStrategies;
    }

    function getPaginatedStrategies(uint _page, uint _perPage) public view returns (Strategy[] memory) {

        Strategy[] memory strategiesPerPage = new Strategy[](_perPage);

        uint start = _page * _perPage;
        uint end = start + _perPage;

        end = (end > strategiesPerPage.length) ? strategiesPerPage.length : end;

        uint count = 0;
        for (uint i = start; i < end; i++) {
            strategiesPerPage[count] = strategies[i];
            count++;
        }

        return strategiesPerPage;
    }

    function getPaginatedTemplates(uint _page, uint _perPage) public view returns (Template[] memory) {

        Template[] memory templatesPerPage = new Template[](_perPage);

        uint start = _page * _perPage;
        uint end = start + _perPage;

        end = (end > templatesPerPage.length) ? templatesPerPage.length : end;

        uint count = 0;
        for (uint i = start; i < end; i++) {
            templatesPerPage[count] = templates[i];
            count++;
        }

        return templatesPerPage;
    }
}  


 







contract TaskExecutor is StrategyData, ProxyPermission, AdminAuth {

    address public constant DEFISAVER_LOGGER = 0x5c55B921f590a89C1Ebe84dF170E655a82b62126;

    address public constant REGISTRY_ADDR = 0xD6049E1F5F3EfF1F921f5532aF1A1632bA23929C;
    DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);

    bytes32 constant SUBSCRIPTION_ID = keccak256("Subscriptions");

    function executeTask(Task memory _currTask) public payable   {

        _executeActions(_currTask);
    }

    function executeStrategyTask(uint256 _strategyId, bytes[][] memory _actionCallData)
        public
        payable
    {

        address subAddr = registry.getAddr(SUBSCRIPTION_ID);
        Strategy memory strategy = Subscriptions(subAddr).getStrategy(_strategyId);
        Template memory template = Subscriptions(subAddr).getTemplate(strategy.templateId);

        Task memory currTask =
            Task({
                name: template.name,
                callData: _actionCallData,
                subData: strategy.subData,
                actionIds: template.actionIds,
                paramMapping: template.paramMapping
            });

        _executeActions(currTask);
    }

    function _executeActionsFromFL(Task memory _currTask, bytes32 _flAmount) public payable {

        bytes32[] memory returnValues = new bytes32[](_currTask.actionIds.length);
        returnValues[0] = _flAmount; // set the flash loan action as first return value

        for (uint256 i = 1; i < _currTask.actionIds.length; ++i) {
            returnValues[i] = _executeAction(_currTask, i, returnValues);
        }
    }

    function _executeActions(Task memory _currTask) internal {

        address firstActionAddr = registry.getAddr(_currTask.actionIds[0]);

        bytes32[] memory returnValues = new bytes32[](_currTask.actionIds.length);

        if (isFL(firstActionAddr)) {
            _parseFLAndExecute(_currTask, firstActionAddr, returnValues);
        } else {
            for (uint256 i = 0; i < _currTask.actionIds.length; ++i) {
                returnValues[i] = _executeAction(_currTask, i, returnValues);
            }
        }

        DefisaverLogger(DEFISAVER_LOGGER).Log(address(this), msg.sender, _currTask.name, "");
    }

    function _executeAction(
        Task memory _currTask,
        uint256 _index,
        bytes32[] memory _returnValues
    ) internal returns (bytes32 response) {

        response = IDSProxy(address(this)).execute(
            registry.getAddr(_currTask.actionIds[_index]),
            abi.encodeWithSignature(
                "executeAction(bytes[],bytes[],uint8[],bytes32[])",
                _currTask.callData[_index],
                _currTask.subData[_index],
                _currTask.paramMapping[_index],
                _returnValues
            )
        );
    }

    function _parseFLAndExecute(
        Task memory _currTask,
        address _flActionAddr,
        bytes32[] memory _returnValues
    ) internal {

        givePermission(_flActionAddr);

        bytes memory taskData = abi.encode(_currTask, address(this));

        _currTask.callData[0][_currTask.callData[0].length - 1] = taskData;

        ActionBase(_flActionAddr).executeAction(
            _currTask.callData[0],
            _currTask.subData[0],
            _currTask.paramMapping[0],
            _returnValues
        );

        removePermission(_flActionAddr);
    }

    function isFL(address _actionAddr) internal pure returns (bool) {

        return ActionBase(_actionAddr).actionType() == uint8(ActionBase.ActionType.FL_ACTION);
    }
}