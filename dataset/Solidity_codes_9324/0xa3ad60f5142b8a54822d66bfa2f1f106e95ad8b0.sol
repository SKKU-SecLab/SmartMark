
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// Unlicense

pragma solidity ^0.8.2;

interface IChainLinkFeed
{


    function latestAnswer() external view returns (int256);


}

contract GasPrice {


    IChainLinkFeed public constant ChainLinkFeed = IChainLinkFeed(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C);

    modifier validGasPrice()
    {

        require(tx.gasprice <= maxGasPrice()); // dev: incorrect gas price
        _;
    }

    function maxGasPrice()
    public
    view
    returns (uint256 fastGas)
    {

        return fastGas = uint256(ChainLinkFeed.latestAnswer());
    }
}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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
}// Unlicense

pragma solidity ^0.8.2;



contract ArrayRolesStorage is Initializable {


    bytes32 internal constant _STORAGE_SLOT = 0x7a90f6c545a08ef8e125aa088f88bee6937d2426935a3bd35718900e7e0b18b7;

    modifier onlyDev() {


        require(IAccessControl(getRoles()).hasRole(keccak256('DEVELOPER'), msg.sender));
        _;
    }
    modifier onlyGov() {

        require(IAccessControl(getRoles()).hasRole(keccak256('GOVERNANCE'), msg.sender));
        _;
    }

    modifier onlyDAOMSIG() {

        require(IAccessControl(getRoles()).hasRole(keccak256('DAO_MULTISIG'), msg.sender));
        _;
    }

    modifier onlyDEVMSIG() {

        require(IAccessControl(getRoles()).hasRole(keccak256('DEV_MULTISIG'), msg.sender));
        _;
    }

    modifier onlyTimelock() {

        require(IAccessControl(getRoles()).hasRole(keccak256('TIMELOCK'), msg.sender));
        _;
    }

    function initialize(address _access)
    public
    initializer
    {

        assert(_STORAGE_SLOT == bytes32(uint256(keccak256("eip1967.accesscontrol.storage")) - 1));
        StorageSlot.getAddressSlot(_STORAGE_SLOT).value = _access;

    }

    function getRoles()
    internal
    view
    returns (address)
    {

        return StorageSlot.getAddressSlot(_STORAGE_SLOT).value;
    }
}// MIT

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
}// Unlicense
pragma solidity ^0.8.2;


interface IArray is IERC20 {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

}// Unlicense

pragma solidity ^0.8.2;

interface IBancorFormula {

    function purchaseTargetAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveWeight,
        uint256 _amount
    ) external view returns (uint256);


    function saleTargetAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveWeight,
        uint256 _amount
    ) external view returns (uint256);


    function crossReserveTargetAmount(
        uint256 _sourceReserveBalance,
        uint32 _sourceReserveWeight,
        uint256 _targetReserveBalance,
        uint32 _targetReserveWeight,
        uint256 _amount
    ) external view returns (uint256);


    function fundCost(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _amount
    ) external view returns (uint256);


    function fundSupplyAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _amount
    ) external view returns (uint256);


    function liquidateReserveAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _amount
    ) external view returns (uint256);


    function balancedWeights(
        uint256 _primaryReserveStakedBalance,
        uint256 _primaryReserveBalance,
        uint256 _secondaryReserveBalance,
        uint256 _reserveRateNumerator,
        uint256 _reserveRateDenominator
    ) external view returns (uint32, uint32);

}// Unlicense

pragma solidity ^0.8.2;

interface ISmartPool {


    function totalSupply() external view returns (uint);


    function transfer(address dst, uint amt) external returns (bool);


    function transferFrom(
        address src, address dst, uint amt
    ) external returns (bool);


    function bPool() external view returns (address);


    function joinswapExternAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        uint minPoolAmountOut
    ) external returns (uint poolAmountOut);

}// Unlicense

pragma solidity ^0.8.2;

interface IBPool {


    function MAX_IN_RATIO() external view returns (uint);


    function getCurrentTokens() external view returns (address[] memory tokens);


    function getDenormalizedWeight(address token) external view returns (uint);


    function getTotalDenormalizedWeight() external view returns (uint);


    function getBalance(address token) external view returns (uint);


    function getSwapFee() external view returns (uint);


    function calcPoolOutGivenSingleIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountIn,
        uint swapFee
    ) external pure returns (uint poolAmountOut);


}// Unlicense

pragma solidity ^0.8.2;





contract Curve is ReentrancyGuard, ArrayRolesStorage, GasPrice{


    address private owner;
    address private DAO_MULTISIG_ADDR = address(0xB60eF661cEdC835836896191EDB87CC025EFd0B7);
    address private DEV_MULTISIG_ADDR = address(0x3c25c256E609f524bf8b35De7a517d5e883Ff81C);
    uint256 private PRECISION = 10 ** 18;

    uint256 private STARTING_DAI_BALANCE = 700000 * PRECISION;

    uint256 private STARTING_ARRAY_MINTED = 10000 * PRECISION;

    uint32 public reserveRatio = 33333;

    uint256 private devPctToken = 10 * 10 ** 16;
    uint256 private daoPctToken = 20 * 10 ** 16;

    uint256 public virtualBalance;

    uint256 public virtualSupply;

    uint256 public maxSupply = 100000 * PRECISION;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private virtualLpTokens;

    IArray public arrayToken;
    IBancorFormula private bancorFormula = IBancorFormula(0xA049894d5dcaD406b7C827D6dc6A0B58CA4AE73a);
    ISmartPool public arraySmartPool = ISmartPool(0xA800cDa5f3416A6Fb64eF93D84D6298a685D190d);
    IBPool public arrayBalancerPool = IBPool(0x02e1300A7E6c3211c65317176Cf1795f9bb1DaAb);


    event Buy(
        address from,
        address token,
        uint256 amount,
        uint256 amountLPTokenDeposited,
        uint256 amountArrayMinted
    );

    event Sell(
        address from,
        uint256 amountArray,
        uint256 amountReturnedLP
    );

    constructor() {
        owner = msg.sender;
    }


    function initialize(
        address _roles,
        address _arrayToken,
        uint256 initialAmountLPToken
    )
    public initializer
    {

        require(msg.sender == owner, "!owner");
        arrayToken = IArray(_arrayToken);

        require(arraySmartPool.transferFrom(DAO_MULTISIG_ADDR, address(this), initialAmountLPToken), "Transfer failed");
        ArrayRolesStorage.initialize(_roles);

        arrayToken.mint(DAO_MULTISIG_ADDR, STARTING_ARRAY_MINTED);

        virtualBalance = initialAmountLPToken;
        virtualSupply = STARTING_ARRAY_MINTED;
    }


    function buy(IERC20 token, uint256 amount, uint256 slippage )
    public
    nonReentrant
    validGasPrice
    returns (uint256 returnAmount)
    {

        require(slippage < 100, "slippage too high");
        require(this.isTokenInLP(address(token)), 'token not in lp');
        require(amount > 0, 'amount is 0');
        require(token.allowance(msg.sender, address(this)) >= amount, 'user allowance < amount');
        require(token.balanceOf(msg.sender) >= amount, 'user balance < amount');

        uint256 max_in_balance = (arrayBalancerPool.getBalance(address(token)) / 2) + 5;
        require(amount <= max_in_balance, 'ratio in too high');

        uint256 amountTokenForDao = amount * daoPctToken / PRECISION;
        uint256 amountTokenForDev = amount * devPctToken / PRECISION;

        uint256 amountTokenAfterFees = amount - amountTokenForDao - amountTokenForDev;
        require(
            token.approve(address(arraySmartPool), amountTokenAfterFees),
            "token approve for contract to balancer pool failed"
        );

        uint256 amountLPReturned = _calculateLPTokensGivenERC20Tokens(address(token), amountTokenAfterFees);
        uint256 amountArrayToMint = _calculateArrayGivenLPTokenAmount(amountLPReturned);

        require(amountArrayToMint + virtualSupply <= maxSupply, 'minted array > total supply');

        require(token.transferFrom(msg.sender, address(this), amount), 'transfer from user to contract failed');
        require(token.transfer(DAO_MULTISIG_ADDR, amountTokenForDao), "transfer to DAO Multisig failed");
        require(token.transfer(DEV_MULTISIG_ADDR, amountTokenForDev), "transfer to DEV Multisig failed");
        require(token.balanceOf(address(this)) >= amountTokenAfterFees, 'contract did not receive the right amount of tokens');

        uint256 minLpTokenAmount = amountLPReturned * slippage * 10**16 / PRECISION;
        uint256 lpTokenReceived = arraySmartPool.joinswapExternAmountIn(address(token), amountTokenAfterFees, minLpTokenAmount);

        arrayToken.mint(msg.sender, amountArrayToMint);

        virtualBalance = virtualBalance + lpTokenReceived;
        virtualSupply = virtualSupply + amountArrayToMint;

        emit Buy(msg.sender, address(token), amount, lpTokenReceived, amountArrayToMint);
        return returnAmount = amountArrayToMint;
    }


    function sell(uint256 amountArray)
    public
    nonReentrant
    validGasPrice
    returns (uint256 amountReturnedLP)
    {

        amountReturnedLP = _sell(amountArray);
    }

    function sell(bool max)
    public
    nonReentrant
    returns (uint256 amountReturnedLP)
    {

        require(max, 'sell function not called correctly');

        uint256 amountArray = arrayToken.balanceOf(msg.sender);
        amountReturnedLP = _sell(amountArray);
    }

    function _sell(uint256 amountArray)
    internal
    returns (uint256 amountReturnedLP)
    {


        require(amountArray <= arrayToken.balanceOf(msg.sender), 'user balance < amount');

        amountReturnedLP = calculateLPtokensGivenArrayTokens(amountArray);

        arrayToken.burn(msg.sender, amountArray);

        require(arraySmartPool.transfer(msg.sender, amountReturnedLP), 'transfer of lp token to user failed');

        virtualBalance -= amountReturnedLP;
        virtualSupply -= amountArray;

        emit Sell(msg.sender, amountArray, amountReturnedLP);
    }

    function calculateArrayMintedFromToken(address token, uint256 amount)
    public
    view
    returns (uint256 expectedAmountArrayToMint)
    {

        require(this.isTokenInVirtualLP(token), 'token not in virtual LP');
        require(this.isTokenInLP(token), 'token not in balancer LP');

        uint256 amountTokenForDao = amount * daoPctToken / PRECISION;
        uint256 amountTokenForDev = amount * devPctToken / PRECISION;

        uint256 amountTokenAfterFees = amount - amountTokenForDao - amountTokenForDev;

        expectedAmountArrayToMint = _calculateArrayMintedFromToken(token, amountTokenAfterFees);
    }

    function _calculateArrayMintedFromToken(address token, uint256 amount)
    private
    view
    returns (uint256 expectedAmountArrayToMint)
    {

        uint256 amountLPReturned = _calculateLPTokensGivenERC20Tokens(token, amount);
        expectedAmountArrayToMint = _calculateArrayGivenLPTokenAmount(amountLPReturned);
    }


    function calculateLPtokensGivenArrayTokens(uint256 amount)
    public
    view
    returns (uint256 amountLPToken)
    {


        return amountLPToken = bancorFormula.saleTargetAmount(
            virtualSupply,
            virtualBalance,
            reserveRatio,
            amount
        );

    }

    function _calculateLPTokensGivenERC20Tokens(address token, uint256 amount)
    private
    view
    returns (uint256 amountLPToken)
    {


        uint256 balance = arrayBalancerPool.getBalance(token);
        uint256 weight = arrayBalancerPool.getDenormalizedWeight(token);
        uint256 totalWeight = arrayBalancerPool.getTotalDenormalizedWeight();
        uint256 fee = arrayBalancerPool.getSwapFee();
        uint256 supply = arraySmartPool.totalSupply();

        return arrayBalancerPool.calcPoolOutGivenSingleIn(balance, weight, supply, totalWeight, amount, fee);
    }

    function _calculateArrayGivenLPTokenAmount(uint256 amount)
    private
    view
    returns (uint256 amountArrayToken)
    {

        return amountArrayToken = bancorFormula.purchaseTargetAmount(
            virtualSupply,
            virtualBalance,
            reserveRatio,
            amount
        );
    }


    function isTokenInLP(address token)
    external
    view
    returns (bool)
    {

        address[] memory lpTokens = arrayBalancerPool.getCurrentTokens();
        for (uint256 i = 0; i < lpTokens.length; i++) {
            if (token == lpTokens[i]) {
                return true;
            }
        }
        return false;
    }


    function isTokenInVirtualLP(address token) external view returns (bool contains) {

        return contains = virtualLpTokens.contains(token);
    }

    function addTokenToVirtualLP(address token)
    public
    onlyDAOMSIG
    returns (bool success){

        require(this.isTokenInLP(token), "Token not in Balancer LP");
        return success = virtualLpTokens.add(token);
    }

    function removeTokenFromVirtualLP(address token)
    public
    onlyDAOMSIG
    returns (bool success) {

        require(this.isTokenInVirtualLP(token), "Token not in Virtual LP");
        return success = virtualLpTokens.remove(token);
    }

    function setDaoPct(uint256 amount)
    public
    onlyDAOMSIG
    returns (bool success) {

        devPctToken = amount;
        success = true;
    }

    function setDevPct(uint256 amount)
    public
    onlyDAOMSIG
    returns (bool success) {

        devPctToken = amount;
        success = true;
    }

    function setMaxSupply(uint256 amount)
    public
    onlyDAOMSIG
    returns (bool success)
    {

        maxSupply = amount;
        success = true;
    }
}