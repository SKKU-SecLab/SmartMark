




pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

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




abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
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



interface IERC20Extended is IERC20 {

    function burn(uint256 amount) external;


    function decimals() external view returns (uint8);

}

interface IRedactedTreasury {

    function manage(address _token, uint256 _amount) external;

}

interface ICurveCryptoPool {

    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external
        payable;


    function calc_token_amount(uint256[2] calldata amounts)
        external
        view
        returns (uint256);


    function price_oracle() external view returns (uint256);


    function token() external view returns (address);

}

contract ThecosomataETH is AccessControl {

    using SafeERC20 for IERC20;

    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

    address public immutable BTRFLY;
    address public immutable WETH;
    address public immutable CURVEPOOL;
    address public immutable TREASURY;

    uint256 private immutable _btrflyDecimals;
    uint256 private immutable _wethDecimals;

    uint256 public slippage = 5; // in 1000th

    event AddLiquidity(
        uint256 wethLiquidity,
        uint256 btrflyLiquidity,
        uint256 btrflyBurned
    );
    event Withdraw(
        address token,
        uint256 amount,
        address recipient
    );
    event GrantKeeperRole(address keeper);
    event RevokeKeeperRole(address keeper);
    event SetSlippage(uint256 slippage);

    constructor(
        address _BTRFLY,
        address _WETH,
        address _TREASURY,
        address _CURVEPOOL
    ) {
        require(_BTRFLY != address(0), "Invalid BTRFLY address");
        BTRFLY = _BTRFLY;

        require(_WETH != address(0), "Invalid WETH address");
        WETH = _WETH;

        require(_CURVEPOOL != address(0), "Invalid POOL address");
        CURVEPOOL = _CURVEPOOL;

        require(_TREASURY != address(0), "Invalid TREASURY address");
        TREASURY = _TREASURY;

        IERC20(_BTRFLY).approve(_CURVEPOOL, type(uint256).max);
        IERC20(_WETH).approve(_CURVEPOOL, type(uint256).max);

        _btrflyDecimals = IERC20Extended(_BTRFLY).decimals();
        _wethDecimals = IERC20Extended(_WETH).decimals();

         _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setSlippage(uint256 _slippage)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(_slippage <= 50, "Slippage too high");
        slippage = _slippage;

        emit SetSlippage(_slippage);
    }

    function grantKeeperRole(address keeper)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(keeper != address(0), "Invalid address");
        _grantRole(KEEPER_ROLE, keeper);

        emit GrantKeeperRole(keeper);
    }

    function revokeKeeperRole(address keeper)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(hasRole(KEEPER_ROLE, keeper), "Invalid address");
        _revokeRole(KEEPER_ROLE, keeper);

        emit RevokeKeeperRole(keeper);
    }

    function _calculateAmountRequiredForLP(uint256 amount, bool isBTRFLY)
        private
        view
        returns (uint256)
    {

        uint256 priceOracle = ICurveCryptoPool(CURVEPOOL).price_oracle();
        uint256 baseExp = 10**18;
        uint256 wethExp = 10**_wethDecimals;
        uint256 btrflyExp = 10**_btrflyDecimals;

        require(priceOracle != 0, "Invalid price oracle");

        if (isBTRFLY) {
            return (((amount * priceOracle) / baseExp) * wethExp) / btrflyExp;
        }

        return (((amount * baseExp) / priceOracle) * btrflyExp) / wethExp;
    }

    function _getAvailableLiquidity()
        private
        view
        returns (
            uint256 wethLiquidity,
            uint256 btrflyLiquidity
        )
    {

        uint256 btrfly = IERC20Extended(BTRFLY).balanceOf(address(this));
        uint256 wethAmount = _calculateAmountRequiredForLP(btrfly, true);
        uint256 wethCap = IERC20(WETH).balanceOf(TREASURY);
        wethLiquidity = wethCap > wethAmount ? wethAmount : wethCap;

        btrflyLiquidity = wethCap > wethAmount
            ? btrfly
            : _calculateAmountRequiredForLP(wethLiquidity, false);
    }

    function performUpkeep() external onlyRole(KEEPER_ROLE) {

        uint256 wethLiquidity;
        uint256 btrflyLiquidity;
        (wethLiquidity, btrflyLiquidity) = _getAvailableLiquidity();

        require(
            wethLiquidity != 0 && btrflyLiquidity != 0,
            "Insufficient amounts"
        );

        uint256[2] memory amounts = [wethLiquidity, btrflyLiquidity];
        uint256 minimumLPAmount = ICurveCryptoPool(CURVEPOOL).calc_token_amount(
            amounts
        );
        minimumLPAmount -= ((minimumLPAmount * slippage) / 1000);
        require(minimumLPAmount != 0, "Invalid slippage");

        IRedactedTreasury(TREASURY).manage(WETH, wethLiquidity);

        ICurveCryptoPool(CURVEPOOL).add_liquidity(amounts, minimumLPAmount);

        address token = ICurveCryptoPool(CURVEPOOL).token();
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(TREASURY, tokenBalance);

        uint256 unusedBTRFLY = IERC20Extended(BTRFLY).balanceOf(address(this));
        if (unusedBTRFLY != 0) {
            IERC20Extended(BTRFLY).burn(unusedBTRFLY);
        }

        emit AddLiquidity(wethLiquidity, btrflyLiquidity, unusedBTRFLY);
    }

    function withdraw(
        address token,
        uint256 amount,
        address recipient
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(token != address(0), "Invalid token");
        require(recipient != address(0), "Invalid recipient");
        require(amount != 0, "Invalid amount");

        IERC20(token).safeTransfer(recipient, amount);

        emit Withdraw(token, amount, recipient);
    }
}