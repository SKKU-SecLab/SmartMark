
pragma solidity 0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
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

interface IController {
    function getClusterAmountFromEth(uint256 _ethAmount, address _cluster) external view returns (uint256);

    function addClusterToRegister(address indexAddr) external;

    function getDHVPriceInETH(address _cluster) external view returns (uint256);

    function getUnderlyingsInfo(address _cluster, uint256 _ethAmount)
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256,
            uint256
        );

    function getUnderlyingsAmountsFromClusterAmount(uint256 _clusterAmount, address _clusterAddress) external view returns (uint256[] memory);

    function getEthAmountFromUnderlyingsAmounts(uint256[] memory _underlyingsAmounts, address _cluster) external view returns (uint256);

    function adapters(address _cluster) external view returns (address);

    function dhvTokenInstance() external view returns (address);

    function getDepositComission(address _cluster, uint256 _ethValue) external view returns (uint256);

    function getRedeemComission(address _cluster, uint256 _ethValue) external view returns (uint256);

    function getClusterPrice(address _cluster) external view returns (uint256);
}

interface IDexAdapter {
    function swapETHToUnderlying(address underlying, uint256 underlyingAmount) external payable;

    function swapUnderlyingsToETH(uint256[] memory underlyingAmounts, address[] memory underlyings) external;

    function swapTokenToToken(
        uint256 _amountToSwap,
        address _tokenToSwap,
        address _tokenToReceive
    ) external returns (uint256);

    function getUnderlyingAmount(
        uint256 _amount,
        address _tokenToSwap,
        address _tokenToReceive
    ) external view returns (uint256);

    function getPath(address _tokenToSwap, address _tokenToReceive) external view returns (address[] memory);

    function getTokensPrices(address[] memory _tokens) external view returns (uint256[] memory);

    function getEthPrice() external view returns (uint256);

    function getDHVPriceInETH(address _dhvToken) external view returns (uint256);

    function WETH() external view returns (address);

    function getEthAmountWithSlippage(uint256 _amount, address _tokenToSwap) external view returns (uint256);
}

interface IClusterToken {
    function assemble(uint256 clusterAmount, bool coverDhvWithEth) external payable returns (uint256);

    function disassemble(uint256 indexAmount, bool coverDhvWithEth) external;

    function withdrawToAccumulation(uint256 _clusterAmount) external;

    function refundFromAccumulation(uint256 _clusterAmount) external;

    function returnDebtFromAccumulation(uint256[] calldata _amounts, uint256 _clusterAmount) external;

    function optimizeProportion(uint256[] memory updatedShares) external returns (uint256[] memory debt);

    function getUnderlyingInCluster() external view returns (uint256[] calldata);

    function getUnderlyings() external view returns (address[] calldata);

    function getUnderlyingBalance(address _underlying) external view returns (uint256);

    function getUnderlyingsAmountsFromClusterAmount(uint256 _clusterAmount) external view returns (uint256[] calldata);

    function clusterTokenLock() external view returns (uint256);

    function clusterLock(address _token) external view returns (uint256);

    function controllerChange(address) external;

    function assembleByAdapter(uint256 _clusterAmount) external;

    function disassembleByAdapter(uint256 _clusterAmount) external;
}

interface IClusterTokenEvents {
    event ClusterAssembledInETH(address indexed clusterAddress, address indexed buyer, uint256 ethDeposited, uint256 clusterAmountBought);
    event ClusterDisassembledInETH(address indexed clusterAddress, address indexed redeemer, uint256 clusterAmountRedeemed);

    event ClusterAssembled(address indexed clusterAddress, address indexed buyer, uint256 clusterAmountBought);
    event ClusterDisassembled(address indexed clusterAddress, address indexed redeemer, uint256 clusterAmountRedeemed);

    event ClusterWithdrawnToAcc(
        address indexed clusterAddress,
        address indexed farmer,
        uint256 clusterAmount,
        uint256[] underlyingsAmounts,
        address[] tokens
    );
    event ClusterRefundedFromAcc(
        address indexed clusterAddress,
        address indexed farmer,
        uint256 clusterAmount,
        uint256[] underlyingsAmounts,
        address[] tokens
    );
    event ProportionsOptimized(address indexed clusterAddress, address indexed delegate, uint256[] updatedShares);
}

contract ClusterToken is ERC20, Pausable, AccessControl, IClusterToken, IClusterTokenEvents {
    using SafeERC20 for IERC20;
    using Address for address;

    bytes32 public constant FARMER_ROLE = keccak256("FARMER_ROLE");
    bytes32 public constant DELEGATE_ROLE = keccak256("DELEGATE_ROLE");
    bytes32 public constant ADAPTER_ROLE = keccak256("ADAPTER_ROLE");

    uint256 public constant ACCURACY_DECIMALS = 10**6;
    uint256 public constant CLUSTER_TOKEN_DECIMALS = 10**18;

    uint256 public constant MAX_COOLDOWN = 2 days;

    uint256 public constant DUST_AMOUNT = 10**12;

    address public clusterControllerAddress;
    address internal treasuryAddress;
    IERC20 public dhvTokenInstance;
    uint256 public clusterHashId;

    uint256 public cooldownPeriod;
    address[] public underlyings;
    uint256[] public underlyingInCluster;

    uint256 public override clusterTokenLock;
    mapping(address => uint256) public override clusterLock;

    mapping(address => uint256) public cooldownTimestamps;

    mapping(address => uint256) public cooldownAmount;

    modifier checkCooldownPeriod(address _from, uint256 _amount) {
        if (cooldownTimestamps[_from] > block.timestamp) {
            uint256 allowedAmount = IERC20(address(this)).balanceOf(_from) - cooldownAmount[_from];
            require(allowedAmount >= _amount, "Cooldown in progress");
        }
        _;
    }

    modifier checkBuyer() {
        require(!_msgSender().isContract(), "Not allowed for contracts");
        _;
    }

    constructor(
        address _clusterControllerAddress,
        address _treasury,
        address[] memory _underlyings,
        uint256[] memory _underlyingInCluster,
        string memory _name,
        string memory _symbol,
        uint256 _hashId
    ) ERC20(_name, _symbol) {
        require(_clusterControllerAddress != address(0), "dev: Controller zero address");
        require(_treasury != address(0), "dev: Treasury zero address");
        require(_underlyings.length == _underlyingInCluster.length, "dev: Arrays' lengths must be equal");
        for (uint256 i = 0; i < _underlyings.length; i++) {
            require(_underlyings[i] != address(0), "dev: Underlying zero address");
            require(_underlyingInCluster[i] > 0, "dev: Share equals zero");
        }
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        underlyings = _underlyings;
        underlyingInCluster = _underlyingInCluster;
        clusterHashId = _hashId;
        clusterControllerAddress = _clusterControllerAddress;
        treasuryAddress = _treasury;

        dhvTokenInstance = IERC20(IController(_clusterControllerAddress).dhvTokenInstance());
    }

    receive() external payable {}


    function setCooldownPeriod(uint256 _cooldownPeriod) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_cooldownPeriod <= MAX_COOLDOWN, "Incorrect cooldown");
        cooldownPeriod = _cooldownPeriod;
    }

    function setTreasuryAddress(address _newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_newTreasury != address(0), "Incorrect address");
        treasuryAddress = _newTreasury;
    }

    function withdrawDust() external onlyRole(DEFAULT_ADMIN_ROLE) {
        Address.sendValue(payable(_msgSender()), address(this).balance);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function controllerChange(address _controller) external override {
        require(_msgSender() == clusterControllerAddress, "Controller only");
        require(_controller != address(0), "dev: Controller zero address");
        clusterControllerAddress = _controller;
    }


    function assemble(uint256 clusterAmount, bool coverDhvWithEth) external payable override whenNotPaused checkBuyer returns (uint256) {
        uint256 balanceBefore = address(this).balance;
        _swapEthToUnderlyings(msg.value, clusterAmount);
        uint256 balanceAfter = address(this).balance;

        uint256 ethSpent = balanceBefore - balanceAfter;

        uint256 _ethCommission = IController(clusterControllerAddress).getDepositComission(address(this), ethSpent);
        uint256 ethAmount = msg.value - ethSpent - _coverCommission(_ethCommission, coverDhvWithEth);

        if (ethAmount > DUST_AMOUNT) {
            Address.sendValue(payable(_msgSender()), ethAmount);
        }

        if (cooldownPeriod > 0) {
            if (cooldownTimestamps[_msgSender()] > block.timestamp) {
                cooldownAmount[_msgSender()] += clusterAmount;
            } else {
                cooldownAmount[_msgSender()] = clusterAmount;
            }
            cooldownTimestamps[_msgSender()] = block.timestamp + cooldownPeriod;
        }

        _mint(_msgSender(), clusterAmount);
        emit ClusterAssembledInETH(address(this), _msgSender(), ethSpent, clusterAmount);

        return clusterAmount;
    }

    function disassemble(uint256 _clusterAmount, bool coverDhvWithEth)
        external
        override
        whenNotPaused
        checkCooldownPeriod(_msgSender(), _clusterAmount)
        checkBuyer
    {
        require(_clusterAmount > 0 && _clusterAmount <= balanceOf(_msgSender()), "Not enough cluster");
        _burn(_msgSender(), _clusterAmount);

        uint256[] memory underlyingAmounts = getUnderlyingsAmountsFromClusterAmount(_clusterAmount);

        uint256 balanceBefore = address(this).balance;
        _swapUnderlyingsToEth(underlyingAmounts);
        uint256 balanceAfter = address(this).balance;

        uint256 ethEstimated = balanceAfter - balanceBefore;
        uint256 _ethCommission = IController(clusterControllerAddress).getRedeemComission(address(this), ethEstimated);
        uint256 ethAmount = ethEstimated - _coverCommission(_ethCommission, coverDhvWithEth);

        Address.sendValue(payable(_msgSender()), ethAmount);
        emit ClusterDisassembledInETH(address(this), _msgSender(), _clusterAmount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override checkCooldownPeriod(from, amount) {}


    function assembleByAdapter(uint256 _clusterAmount) external override onlyRole(ADAPTER_ROLE) {
        uint256[] memory underlyingAmounts = getUnderlyingsAmountsFromClusterAmount(_clusterAmount);

        for (uint256 i = 0; i < underlyingAmounts.length; i++) {
            IERC20(underlyings[i]).safeTransferFrom(_msgSender(), address(this), underlyingAmounts[i]);
        }

        _mint(_msgSender(), _clusterAmount);

        emit ClusterAssembled(address(this), _msgSender(), _clusterAmount);
    }

    function disassembleByAdapter(uint256 _clusterAmount) external override onlyRole(ADAPTER_ROLE) {
        uint256[] memory underlyingAmounts = getUnderlyingsAmountsFromClusterAmount(_clusterAmount);

        _burn(_msgSender(), _clusterAmount);

        for (uint256 i = 0; i < underlyingAmounts.length; i++) {
            IERC20(underlyings[i]).safeTransfer(_msgSender(), underlyingAmounts[i]);
        }

        emit ClusterDisassembled(address(this), _msgSender(), _clusterAmount);
    }

    function withdrawToAccumulation(uint256 _clusterAmount) external override onlyRole(FARMER_ROLE) {
        uint256[] memory _amounts = getUnderlyingsAmountsFromClusterAmount(_clusterAmount);

        clusterTokenLock += _clusterAmount;
        for (uint256 i = 0; i < underlyings.length; i++) {
            clusterLock[underlyings[i]] += _amounts[i];
            IERC20(underlyings[i]).safeTransfer(_msgSender(), _amounts[i]);
        }

        emit ClusterWithdrawnToAcc(address(this), _msgSender(), _clusterAmount, _amounts, underlyings);
    }

    function refundFromAccumulation(uint256 _clusterAmount) external override onlyRole(FARMER_ROLE) {
        uint256[] memory _amounts = getUnderlyingsAmountsFromClusterAmount(_clusterAmount);

        clusterTokenLock -= _clusterAmount;
        for (uint256 i = 0; i < underlyings.length; i++) {
            clusterLock[underlyings[i]] -= _amounts[i];
            IERC20(underlyings[i]).safeTransferFrom(_msgSender(), address(this), _amounts[i]);
        }

        emit ClusterRefundedFromAcc(address(this), _msgSender(), _clusterAmount, _amounts, underlyings);
    }

    function returnDebtFromAccumulation(uint256[] memory _amounts, uint256 _clusterAmount) external override onlyRole(FARMER_ROLE) {
        clusterTokenLock -= _clusterAmount;

        for (uint256 i = 0; i < underlyings.length; i++) {
            clusterLock[underlyings[i]] -= _amounts[i];
            IERC20(underlyings[i]).safeTransferFrom(_msgSender(), address(this), _amounts[i]);
        }

        emit ClusterRefundedFromAcc(address(this), _msgSender(), _clusterAmount, _amounts, underlyings);
    }

    function optimizeProportion(uint256[] memory updatedShares) external override onlyRole(DELEGATE_ROLE) returns (uint256[] memory debt) {
        require(updatedShares.length == underlyingInCluster.length, "Wrong array");
        debt = new uint256[](underlyings.length);

        uint256 clusterTokenLockMemo = clusterTokenLock;
        uint256[] memory curSharesAmounts = IController(clusterControllerAddress).getUnderlyingsAmountsFromClusterAmount(
            totalSupply() - clusterTokenLockMemo,
            address(this)
        );
        underlyingInCluster = updatedShares;
        uint256[] memory newSharesAmounts = getUnderlyingsAmountsFromClusterAmount(totalSupply() - clusterTokenLockMemo);
        uint256[] memory newLock = getUnderlyingsAmountsFromClusterAmount(clusterTokenLockMemo);

        for (uint256 i = 0; i < underlyings.length; i++) {
            address tkn = underlyings[i];

            if (newLock[i] > clusterLock[tkn]) {
                debt[i] = newLock[i] - clusterLock[tkn];
            } else {
                debt[i] = 0;
            }
            clusterLock[tkn] = newLock[i];

            if (curSharesAmounts[i] > newSharesAmounts[i]) {
                IERC20(tkn).safeTransfer(_msgSender(), curSharesAmounts[i] - newSharesAmounts[i]);
            } else if (curSharesAmounts[i] < newSharesAmounts[i]) {
                IERC20(tkn).safeTransferFrom(_msgSender(), address(this), newSharesAmounts[i] - curSharesAmounts[i]);
            }
        }
        emit ProportionsOptimized(address(this), _msgSender(), updatedShares);
    }


    function getUnderlyings() external view override returns (address[] memory) {
        return underlyings;
    }

    function getUnderlyingInCluster() external view override returns (uint256[] memory) {
        return underlyingInCluster;
    }

    function getUnderlyingsAmountsFromClusterAmount(uint256 _clusterAmount) public view override returns (uint256[] memory) {
        uint256[] memory underlyingAmounts = new uint256[](underlyings.length);
        for (uint256 i = 0; i < underlyings.length; i++) {
            underlyingAmounts[i] = (_clusterAmount * underlyingInCluster[i]) / ACCURACY_DECIMALS;
            uint8 decimals = IERC20Metadata(underlyings[i]).decimals();
            if (decimals < 18) {
                underlyingAmounts[i] /= 10**(18 - decimals);
            }
        }
        return underlyingAmounts;
    }

    function getUnderlyingBalance(address _underlyingAddress) external view override returns (uint256) {
        return IERC20(_underlyingAddress).balanceOf(address(this)) + clusterLock[_underlyingAddress];
    }


    function _coverCommission(uint256 _ethCommission, bool coverDhvWithEth) internal returns (uint256) {
        if (_ethCommission != 0) {
            if (coverDhvWithEth) {
                Address.sendValue(payable(treasuryAddress), _ethCommission);
                return _ethCommission;
            } else {
                uint256 _dhvCommission = (_ethCommission * 10**18) / IController(clusterControllerAddress).getDHVPriceInETH(address(this));
                dhvTokenInstance.safeTransferFrom(_msgSender(), treasuryAddress, _dhvCommission);
                return 0;
            }
        }
        return 0;
    }

    function _swapEthToUnderlyings(uint256 _ethAmount, uint256 _clusterAmount) internal {
        address adapter = IController(clusterControllerAddress).adapters(address(this));

        (uint256[] memory underlyingAmounts, uint256[] memory ethPortion, , uint256 ethCalculated) = IController(clusterControllerAddress)
            .getUnderlyingsInfo(address(this), _clusterAmount);

        require(_ethAmount >= ethCalculated, "Not enough ether sent");

        for (uint256 i = 0; i < underlyings.length; i++) {
            if (
                IERC20(underlyings[i]).balanceOf(treasuryAddress) >= underlyingAmounts[i] &&
                IERC20(underlyings[i]).allowance(treasuryAddress, address(this)) >= underlyingAmounts[i]
            ) {
                IERC20(underlyings[i]).safeTransferFrom(treasuryAddress, address(this), underlyingAmounts[i]);
                Address.sendValue(payable(treasuryAddress), ethPortion[i]);
            } else {
                IDexAdapter(adapter).swapETHToUnderlying{value: ethPortion[i]}(underlyings[i], underlyingAmounts[i]);
            }
        }
    }

    function _swapUnderlyingsToEth(uint256[] memory _underlyingAmounts) internal {
        address adapter = IController(clusterControllerAddress).adapters(address(this));
        for (uint256 i = 0; i < _underlyingAmounts.length; i++) {
            IERC20(underlyings[i]).safeApprove(adapter, 0);
            IERC20(underlyings[i]).safeApprove(adapter, _underlyingAmounts[i]);
        }

        IDexAdapter(adapter).swapUnderlyingsToETH(_underlyingAmounts, underlyings);
    }
}