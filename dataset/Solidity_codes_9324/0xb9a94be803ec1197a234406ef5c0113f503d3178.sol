
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


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
}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}// MIT

pragma solidity ^0.8.4;

contract ECDSAOffsetRecovery {

    function getHashPacked(
        address user,
        uint256 amountWithFee,
        bytes32 originalTxHash
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(user, amountWithFee, originalTxHash));
    }

    function toEthSignedMessageHash(bytes32 hash)
        public
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function ecOffsetRecover(
        bytes32 hash,
        bytes memory signature,
        uint256 offset
    ) public pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, add(offset, 0x20)))
            s := mload(add(signature, add(offset, 0x40)))
            v := byte(0, mload(add(signature, add(offset, 0x60))))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        }

        return ecrecover(toEthSignedMessageHash(hash), v, r, s);
    }
}// MIT
pragma solidity >=0.4.0;

library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = (type(uint256).max - denominator + 1) & denominator;
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }
}// MIT

pragma solidity ^0.8.4;


contract SwapContract is AccessControl, Pausable, ECDSAOffsetRecovery {

    using SafeERC20 for IERC20;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");

    uint128 public immutable numOfThisBlockchain;
    IUniswapV2Router02 public blockchainRouter;
    address public blockchainPool;
    mapping(uint256 => address) public RubicAddresses;
    mapping(uint256 => bool) public existingOtherBlockchain;
    mapping(uint256 => uint256) public feeAmountOfBlockchain;
    mapping(uint256 => uint256) public blockchainCryptoFee;

    uint256 public constant SIGNATURE_LENGTH = 65;

    struct processedTx {
        uint256 statusCode;
        bytes32 hashedParams;
    }

    mapping(bytes32 => processedTx) public processedTransactions;
    uint256 public minConfirmationSignatures = 3;

    uint256 public minTokenAmount;
    uint256 public maxTokenAmount;
    uint256 public maxGasPrice;
    uint256 public minConfirmationBlocks;
    uint256 public refundSlippage;

    event TransferFromOtherBlockchain(
        address user,
        uint256 amount,
        uint256 amountWithoutFee,
        bytes32 originalTxHash
    );
    event userRefunded(
        address user,
        uint256 amount,
        uint256 amountWithoutFee,
        bytes32 originalTxHash
    );
    event TransferCryptoToOtherBlockchainUser(
        uint256 blockchain,
        address sender,
        uint256 RBCAmountIn,
        uint256 amountSpent,
        string newAddress,
        uint256 cryptoOutMin,
        address[] path
    );
    event TransferTokensToOtherBlockchainUser(
        uint256 blockchain,
        address sender,
        uint256 RBCAmountIn,
        uint256 amountSpent,
        string newAddress,
        uint256 tokenOutMin,
        address[] path
    );

    struct swapToParams {
        uint256 blockchain;
        uint256 tokenInAmount;
        address[] firstPath;
        address[] secondPath;
        uint256 exactRBCtokenOut;
        uint256 tokenOutMin;
        string newAddress;
        bool swapToCrypto;
    }

    struct swapFromParams {
        address user;
        uint256 amountWithFee;
        uint256 amountOutMin;
        address[] path;
        bytes32 originalTxHash;
        bytes concatSignatures;
    }

    modifier onlyOwner() {

        require(
            hasRole(OWNER_ROLE, _msgSender()),
            "Caller is not in owner role"
        );
        _;
    }

    modifier onlyOwnerAndManager() {

        require(
            hasRole(OWNER_ROLE, _msgSender()) ||
                hasRole(MANAGER_ROLE, _msgSender()),
            "Caller is not in owner or manager role"
        );
        _;
    }

    modifier onlyRelayer() {

        require(
            hasRole(RELAYER_ROLE, _msgSender()),
            "swapContract: Caller is not in relayer role"
        );
        _;
    }

    modifier TransferTo(swapToParams memory params, uint256 value) {

        require(
            bytes(params.newAddress).length > 0,
            "swapContract: No destination address provided"
        );
        require(
            existingOtherBlockchain[params.blockchain] &&
                params.blockchain != numOfThisBlockchain,
            "swapContract: Wrong choose of blockchain"
        );
        require(
            params.firstPath.length > 0,
            "swapContract: firsPath length must be greater than 1"
        );
        require(
            params.secondPath.length > 0,
            "swapContract: secondPath length must be greater than 1"
        );
        require(
            params.firstPath[params.firstPath.length - 1] ==
                RubicAddresses[numOfThisBlockchain],
            "swapContract: the last address in the firstPath must be Rubic"
        );
        require(
            params.secondPath[0] == RubicAddresses[params.blockchain],
            "swapContract: the first address in the secondPath must be Rubic"
        );
        require(
            params.exactRBCtokenOut >= minTokenAmount,
            "swapContract: Not enough amount of tokens"
        );
        require(
            params.exactRBCtokenOut < maxTokenAmount,
            "swapContract: Too many RBC requested"
        );
        require(
            value >= blockchainCryptoFee[params.blockchain],
            "swapContract: Not enough crypto provided"
        );
        _;
        if (params.swapToCrypto) {
            emit TransferCryptoToOtherBlockchainUser(
                params.blockchain,
                _msgSender(),
                params.exactRBCtokenOut,
                params.tokenInAmount,
                params.newAddress,
                params.tokenOutMin,
                params.secondPath
            );
        } else {
            emit TransferTokensToOtherBlockchainUser(
                params.blockchain,
                _msgSender(),
                params.exactRBCtokenOut,
                params.tokenInAmount,
                params.newAddress,
                params.tokenOutMin,
                params.secondPath
            );
        }
    }

    modifier TransferFrom(swapFromParams memory params) {

        require(
            params.amountWithFee >= minTokenAmount,
            "swapContract: Not enough amount of tokens"
        );
        require(
            params.amountWithFee < maxTokenAmount,
            "swapContract: Too many RBC requested"
        );
        require(
            params.path.length > 0,
            "swapContract: path length must be greater than 1"
        );
        require(
            params.path[0] == RubicAddresses[numOfThisBlockchain],
            "swapContract: the first address in the path must be Rubic"
        );
        require(
            params.user != address(0),
            "swapContract: Address cannot be zero address"
        );
        require(
            params.concatSignatures.length % SIGNATURE_LENGTH == 0,
            "swapContract: Signatures lengths must be divisible by 65"
        );
        require(
            params.concatSignatures.length / SIGNATURE_LENGTH >=
                minConfirmationSignatures,
            "swapContract: Not enough signatures passed"
        );

        _processTransaction(
            params.user,
            params.amountWithFee,
            params.originalTxHash,
            params.concatSignatures
        );
        _;
    }

    constructor(
        uint128 _numOfThisBlockchain,
        uint128[] memory _numsOfOtherBlockchains,
        uint256[] memory tokenLimits,
        uint256 _maxGasPrice,
        uint256 _minConfirmationBlocks,
        uint256 _refundSlippage,
        IUniswapV2Router02 _blockchainRouter,
        address[] memory _RubicAddresses
    ) {
        for (uint256 i = 0; i < _numsOfOtherBlockchains.length; i++) {
            require(
                _numsOfOtherBlockchains[i] != _numOfThisBlockchain,
                "swapContract: Number of this blockchain is in array of other blockchains"
            );
            existingOtherBlockchain[_numsOfOtherBlockchains[i]] = true;
        }

        for (uint256 i = 0; i < _RubicAddresses.length; i++) {
            RubicAddresses[i + 1] = _RubicAddresses[i];
        }

        require(_maxGasPrice > 0, "swapContract: Gas price cannot be zero");

        numOfThisBlockchain = _numOfThisBlockchain;
        minTokenAmount = tokenLimits[0];
        maxTokenAmount = tokenLimits[1];
        maxGasPrice = _maxGasPrice;
        refundSlippage = _refundSlippage;
        minConfirmationBlocks = _minConfirmationBlocks;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OWNER_ROLE, _msgSender());
        blockchainRouter = _blockchainRouter;

        IERC20(RubicAddresses[_numOfThisBlockchain]).safeApprove(
            address(_blockchainRouter),
            type(uint256).max
        );
    }

    function getOtherBlockchainAvailableByNum(uint256 blockchain)
        external
        view
        returns (bool)
    {

        return existingOtherBlockchain[blockchain];
    }

    function _processTransaction(
        address user,
        uint256 amountWithFee,
        bytes32 originalTxHash,
        bytes memory concatSignatures
    ) private {

        bytes32 hashedParams = getHashPacked(
            user,
            amountWithFee,
            originalTxHash
        );
        uint256 statusCode = processedTransactions[originalTxHash].statusCode;
        bytes32 savedHash = processedTransactions[originalTxHash].hashedParams;
        require(
            statusCode == 0 && savedHash != hashedParams,
            "swapContract: Transaction already processed"
        );

        uint256 signaturesCount = concatSignatures.length /
            uint256(SIGNATURE_LENGTH);
        address[] memory validatorAddresses = new address[](signaturesCount);
        for (uint256 i = 0; i < signaturesCount; i++) {
            address validatorAddress = ecOffsetRecover(
                hashedParams,
                concatSignatures,
                i * SIGNATURE_LENGTH
            );
            require(
                isValidator(validatorAddress),
                "swapContract: Validator address not in whitelist"
            );
            for (uint256 j = 0; j < i; j++) {
                require(
                    validatorAddress != validatorAddresses[j],
                    "swapContract: Validator address is duplicated"
                );
            }
            validatorAddresses[i] = validatorAddress;
        }
        processedTransactions[originalTxHash].hashedParams = hashedParams;
        processedTransactions[originalTxHash].statusCode = 1;
    }

    function swapTokensToOtherBlockchain(swapToParams memory params)
        external
        payable
        whenNotPaused
        TransferTo(params, msg.value)
    {

        IERC20 tokenIn = IERC20(params.firstPath[0]);
        if (params.firstPath.length > 1) {
            tokenIn.safeTransferFrom(
                msg.sender,
                address(this),
                params.tokenInAmount
            );
            tokenIn.safeApprove(address(blockchainRouter), 0);
            tokenIn.safeApprove(
                address(blockchainRouter),
                params.tokenInAmount
            );
            uint256[] memory amounts = blockchainRouter
                .swapTokensForExactTokens(
                    params.exactRBCtokenOut,
                    params.tokenInAmount,
                    params.firstPath,
                    blockchainPool,
                    block.timestamp
                );
            tokenIn.safeTransfer(
                _msgSender(),
                params.tokenInAmount - amounts[0]
            );
            params.tokenInAmount = amounts[0];
        } else {
            tokenIn.safeTransferFrom(
                msg.sender,
                blockchainPool,
                params.exactRBCtokenOut
            );
        }
    }

    function swapCryptoToOtherBlockchain(swapToParams memory params)
        external
        payable
        whenNotPaused
        TransferTo(params, msg.value)
    {

        uint256 cryptoWithoutFee = msg.value -
            blockchainCryptoFee[params.blockchain];
        uint256[] memory amounts = blockchainRouter.swapETHForExactTokens{
            value: cryptoWithoutFee
        }(
            params.exactRBCtokenOut,
            params.firstPath,
            blockchainPool,
            block.timestamp
        );
        params.tokenInAmount = amounts[0];
        bool success = payable(_msgSender()).send(
            cryptoWithoutFee - amounts[0]
        );
        require(success, "swapContract: crypto transfer back to caller failed");
    }

    function swapTokensToUserWithFee(swapFromParams memory params)
        external
        onlyRelayer
        whenNotPaused
        TransferFrom(params)
    {

        uint256 amountWithoutFee = FullMath.mulDiv(
            params.amountWithFee,
            1e6 - feeAmountOfBlockchain[numOfThisBlockchain],
            1e6
        );

        IERC20 RBCToken = IERC20(params.path[0]);

        if (params.path.length == 1) {
            RBCToken.safeTransferFrom(
                blockchainPool,
                params.user,
                amountWithoutFee
            );
            RBCToken.safeTransferFrom(
                blockchainPool,
                address(this),
                params.amountWithFee - amountWithoutFee
            );
        } else {
            RBCToken.safeTransferFrom(
                blockchainPool,
                address(this),
                params.amountWithFee
            );
            blockchainRouter.swapExactTokensForTokens(
                amountWithoutFee,
                params.amountOutMin,
                params.path,
                params.user,
                block.timestamp
            );
        }
        emit TransferFromOtherBlockchain(
            params.user,
            params.amountWithFee,
            amountWithoutFee,
            params.originalTxHash
        );
    }

    function swapCryptoToUserWithFee(swapFromParams memory params)
        external
        onlyRelayer
        whenNotPaused
        TransferFrom(params)
    {

        uint256 amountWithoutFee = FullMath.mulDiv(
            params.amountWithFee,
            1e6 - feeAmountOfBlockchain[numOfThisBlockchain],
            1e6
        );

        IERC20 RBCToken = IERC20(params.path[0]);
        RBCToken.safeTransferFrom(
            blockchainPool,
            address(this),
            params.amountWithFee
        );
        blockchainRouter.swapExactTokensForETH(
            amountWithoutFee,
            params.amountOutMin,
            params.path,
            params.user,
            block.timestamp
        );
        emit TransferFromOtherBlockchain(
            params.user,
            params.amountWithFee,
            amountWithoutFee,
            params.originalTxHash
        );
    }

    function refundTokensToUser(swapFromParams memory params)
        external
        onlyRelayer
        whenNotPaused
        TransferFrom(params)
    {

        IERC20 RBCToken = IERC20(params.path[0]);

        if (params.path.length == 1) {
            RBCToken.safeTransferFrom(
                blockchainPool,
                params.user,
                params.amountOutMin
            );
            emit userRefunded(
                params.user,
                params.amountOutMin,
                params.amountOutMin,
                params.originalTxHash
            );
        } else {
            uint256 amountIn = FullMath.mulDiv(
                params.amountWithFee,
                1e6 + refundSlippage,
                1e6
            );

            RBCToken.safeTransferFrom(blockchainPool, address(this), amountIn);

            uint256 RBCSpent = blockchainRouter.swapTokensForExactTokens(
                params.amountOutMin,
                amountIn,
                params.path,
                params.user,
                block.timestamp
            )[0];

            RBCToken.safeTransfer(blockchainPool, amountIn - RBCSpent);
            emit userRefunded(
                params.user,
                RBCSpent,
                RBCSpent,
                params.originalTxHash
            );
        }
    }

    function refundCryptoToUser(swapFromParams memory params)
        external
        onlyRelayer
        whenNotPaused
        TransferFrom(params)
    {

        IERC20 RBCToken = IERC20(params.path[0]);

        uint256 amountIn = FullMath.mulDiv(
            params.amountWithFee,
            1e6 + refundSlippage,
            1e6
        );

        RBCToken.safeTransferFrom(blockchainPool, address(this), amountIn);

        uint256 RBCSpent = blockchainRouter.swapTokensForExactETH(
            params.amountOutMin,
            amountIn,
            params.path,
            params.user,
            block.timestamp
        )[0];

        RBCToken.safeTransfer(blockchainPool, amountIn - RBCSpent);
        emit userRefunded(
            params.user,
            RBCSpent,
            RBCSpent,
            params.originalTxHash
        );
    }

    function addOtherBlockchain(uint128 numOfOtherBlockchain)
        external
        onlyOwner
    {

        require(
            numOfOtherBlockchain != numOfThisBlockchain,
            "swapContract: Cannot add this blockchain to array of other blockchains"
        );
        require(
            !existingOtherBlockchain[numOfOtherBlockchain],
            "swapContract: This blockchain is already added"
        );
        existingOtherBlockchain[numOfOtherBlockchain] = true;
    }

    function removeOtherBlockchain(uint128 numOfOtherBlockchain)
        external
        onlyOwner
    {

        require(
            existingOtherBlockchain[numOfOtherBlockchain],
            "swapContract: This blockchain was not added"
        );
        existingOtherBlockchain[numOfOtherBlockchain] = false;
    }

    function changeOtherBlockchain(
        uint128 oldNumOfOtherBlockchain,
        uint128 newNumOfOtherBlockchain
    ) external onlyOwner {

        require(
            oldNumOfOtherBlockchain != newNumOfOtherBlockchain,
            "swapContract: Cannot change blockchains with same number"
        );
        require(
            newNumOfOtherBlockchain != numOfThisBlockchain,
            "swapContract: Cannot add this blockchain to array of other blockchains"
        );
        require(
            existingOtherBlockchain[oldNumOfOtherBlockchain],
            "swapContract: This blockchain was not added"
        );
        require(
            !existingOtherBlockchain[newNumOfOtherBlockchain],
            "swapContract: This blockchain is already added"
        );

        existingOtherBlockchain[oldNumOfOtherBlockchain] = false;
        existingOtherBlockchain[newNumOfOtherBlockchain] = true;
    }


    function setRouter(IUniswapV2Router02 _router)
        external
        onlyOwnerAndManager
    {

        blockchainRouter = _router;
    }


    function setPoolAddress(address _poolAddress) external onlyOwnerAndManager {

        blockchainPool = _poolAddress;
    }


    function collectCryptoFee() external onlyOwner {

        bool success = payable(msg.sender).send(address(this).balance);
        require(success, "swapContract: fail collecting fee");
    }

    function collectTokenFee() external onlyOwner {

        IERC20(RubicAddresses[numOfThisBlockchain]).safeTransfer(
            msg.sender,
            IERC20(RubicAddresses[numOfThisBlockchain]).balanceOf(address(this))
        );
    }

    function setFeeAmountOfBlockchain(uint128 _blockchainNum, uint256 feeAmount)
        external
        onlyOwnerAndManager
    {

        feeAmountOfBlockchain[_blockchainNum] = feeAmount;
    }

    function setCryptoFeeOfBlockchain(uint128 _blockchainNum, uint256 feeAmount)
        external
        onlyOwnerAndManager
    {

        blockchainCryptoFee[_blockchainNum] = feeAmount;
    }

    function setRubicAddressOfBlockchain(
        uint128 _blockchainNum,
        address _RubicAddress
    ) external onlyOwnerAndManager {

        RubicAddresses[_blockchainNum] = _RubicAddress;
        if (_blockchainNum == numOfThisBlockchain) {
            if (
                IERC20(_RubicAddress).allowance(
                    address(this),
                    address(blockchainRouter)
                ) != 0
            ) {
                IERC20(_RubicAddress).safeApprove(address(blockchainRouter), 0);
            }
            IERC20(_RubicAddress).safeApprove(
                address(blockchainRouter),
                type(uint256).max
            );
        }
    }


    function setMinConfirmationSignatures(uint256 _minConfirmationSignatures)
        external
        onlyOwner
    {

        require(
            _minConfirmationSignatures > 0,
            "swapContract: At least 1 confirmation can be set"
        );
        minConfirmationSignatures = _minConfirmationSignatures;
    }

    function setMinTokenAmount(uint256 _minTokenAmount)
        external
        onlyOwnerAndManager
    {

        minTokenAmount = _minTokenAmount;
    }

    function setMaxTokenAmount(uint256 _maxTokenAmount)
        external
        onlyOwnerAndManager
    {

        maxTokenAmount = _maxTokenAmount;
    }

    function setMaxGasPrice(uint256 _maxGasPrice) external onlyOwnerAndManager {

        require(_maxGasPrice > 0, "swapContract: Gas price cannot be zero");
        maxGasPrice = _maxGasPrice;
    }


    function setMinConfirmationBlocks(uint256 _minConfirmationBlocks)
        external
        onlyOwnerAndManager
    {

        minConfirmationBlocks = _minConfirmationBlocks;
    }

    function setRefundSlippage(uint256 _refundSlippage)
        external
        onlyOwnerAndManager
    {

        refundSlippage = _refundSlippage;
    }

    function transferOwnerAndSetManager(address newOwner, address newManager)
        external
        onlyOwner
    {

        require(
            newOwner != _msgSender(),
            "swapContract: New owner must be different than current"
        );
        require(
            newOwner != address(0x0),
            "swapContract: Owner cannot be zero address"
        );
        require(
            newManager != address(0x0),
            "swapContract: Owner cannot be zero address"
        );
        _setupRole(DEFAULT_ADMIN_ROLE, newOwner);
        _setupRole(OWNER_ROLE, newOwner);
        _setupRole(MANAGER_ROLE, newManager);
        renounceRole(OWNER_ROLE, _msgSender());
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function pauseExecution() external onlyOwner {

        _pause();
    }

    function continueExecution() external onlyOwner {

        _unpause();
    }

    function isOwner(address account) public view returns (bool) {

        return hasRole(OWNER_ROLE, account);
    }

    function isManager(address account) public view returns (bool) {

        return hasRole(MANAGER_ROLE, account);
    }

    function isRelayer(address account) public view returns (bool) {

        return hasRole(RELAYER_ROLE, account);
    }

    function isValidator(address account) public view returns (bool) {

        return hasRole(VALIDATOR_ROLE, account);
    }

    function changeTxStatus(
        bytes32 originalTxHash,
        uint256 statusCode,
        bytes32 hashedParams
    ) external onlyRelayer {

        require(
            statusCode != 0,
            "swapContract: you cannot set the statusCode to 0"
        );
        require(
            processedTransactions[originalTxHash].statusCode != 1,
            "swapContract: transaction with this originalTxHash has already been set as succeed"
        );
        processedTransactions[originalTxHash].statusCode = statusCode;
        processedTransactions[originalTxHash].hashedParams = hashedParams;
    }

    receive() external payable {}
}