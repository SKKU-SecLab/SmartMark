
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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
}// MIT

pragma solidity ^0.8.1;

library Address {

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
}// MIT

pragma solidity ^0.8.0;


pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
pragma solidity 0.8.11;

interface IBalancerStructs {

    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    enum JoinKind {
        INIT,
        EXACT_TOKENS_IN_FOR_BPT_OUT,
        TOKEN_IN_FOR_EXACT_BPT_OUT,
        ALL_TOKENS_IN_FOR_EXACT_BPT_OUT
    }

    enum ExitKind {
        EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
        EXACT_BPT_IN_FOR_TOKENS_OUT,
        BPT_IN_FOR_EXACT_TOKENS_OUT,
        MANAGEMENT_FEE_TOKENS_OUT // for InvestmentPool
    }

    enum PoolSpecialization {
        GENERAL,
        MINIMAL_SWAP_INFO,
        TWO_TOKEN
    }

    struct Reward {
        address token;
        address distributor;
        uint256 period_finish;
        uint256 rate;
        uint256 last_update;
        uint256 integral;
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    struct JoinPoolRequest {
        address[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    struct ExitPoolRequest {
        address[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }
}// MIT
pragma solidity 0.8.11;


interface IBalancer is IBalancerStructs {

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;


    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );


    function getPool(bytes32 poolId)
        external
        view
        returns (address, PoolSpecialization);


    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;

}// MIT
pragma solidity 0.8.11;


interface ILiquidityGauge is IBalancerStructs {

    function deposit(uint256 _value) external;


    function deposit(uint256 _value, address _addr) external;


    function deposit(
        uint256 _value,
        address _addr,
        bool _claim_rewards
    ) external;


    function withdraw(uint256 _value) external;


    function withdraw(uint256 _value, bool _claim_rewards) external;


    function claim_rewards() external;


    function claim_rewards(address _addr) external;


    function claim_rewards(address _addr, address _receiver) external;


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);


    function transfer(address _to, uint256 _value) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);


    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (bool);


    function increaseAllowance(address _spender, uint256 _added_value)
        external
        returns (bool);


    function decreaseAllowance(address _spender, uint256 _subtracted_value)
        external
        returns (bool);


    function user_checkpoint(address addr) external returns (bool);


    function set_rewards_receiver(address _receiver) external;


    function kick(address addr) external;


    function deposit_reward_token(address _reward_token, uint256 _amount)
        external;


    function add_reward(address _reward_token, address _distributor) external;


    function set_reward_distributor(address _reward_token, address _distributor)
        external;


    function killGauge() external;


    function unkillGauge() external;


    function claimed_reward(address _addr, address _token)
        external
        view
        returns (uint256);


    function claimable_reward(address _user, address _reward_token)
        external
        view
        returns (uint256);


    function claimable_tokens(address addr) external returns (uint256);


    function integrate_checkpoint() external view returns (uint256);


    function future_epoch_time() external view returns (uint256);


    function inflation_rate() external view returns (uint256);


    function decimals() external view returns (uint256);


    function version() external view returns (string memory);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function initialize(address _lp_token) external;


    function balanceOf(address arg0) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function nonces(address arg0) external view returns (uint256);


    function lp_token() external view returns (address);


    function is_killed() external view returns (bool);


    function reward_count() external view returns (uint256);


    function reward_data(address arg0) external view returns (Reward memory);


    function rewards_receiver(address arg0) external view returns (address);


    function reward_integral_for(address arg0, address arg1)
        external
        view
        returns (uint256);


    function working_balances(address arg0) external view returns (uint256);


    function working_supply() external view returns (uint256);


    function integrate_inv_supply_of(address arg0)
        external
        view
        returns (uint256);


    function integrate_checkpoint_of(address arg0)
        external
        view
        returns (uint256);


    function integrate_fraction(address arg0) external view returns (uint256);


    function period() external view returns (int128);


    function reward_tokens(uint256 arg0) external view returns (address);


    function period_timestamp(uint256 arg0) external view returns (uint256);


    function integrate_inv_supply(uint256 arg0) external view returns (uint256);

}// MIT
pragma solidity 0.8.11;


interface IBalancerGaugeFactory {

    function getPoolGauge(address pool) external view returns (ILiquidityGauge);

}// MIT
pragma solidity 0.8.11;

interface IExchange {

    function exchange(
        address from,
        address to,
        uint256 amountIn,
        uint256 minAmountOut
    ) external payable returns (uint256);

}// MIT
pragma solidity 0.8.11;

interface IAlluoStrategy {

    function invest(bytes calldata data, uint256 amount)
        external
        returns (bytes memory);


    function exitAll(
        bytes calldata data,
        uint256 unwindPercent,
        address outputCoin,
        address receiver,
        bool swapRewards
    ) external;


    function exitOnlyRewards(
        bytes calldata data,
        address outputCoin,
        address receiver,
        bool swapRewards
    ) external;


    function multicall(
        address[] calldata destinations,
        bytes[] calldata calldatas
    ) external;

}// MIT
pragma solidity 0.8.11;




contract BalancerStrategy is AccessControl, IAlluoStrategy, IBalancerStructs {

    using Address for address;
    using SafeERC20 for IERC20;

    IBalancer public constant balancer =
        IBalancer(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IBalancerGaugeFactory public constant gaugeFactory =
        IBalancerGaugeFactory(0x4E7bBd911cf1EFa442BC1b2e9Ea01ffE785412EC);
    IExchange public constant exchange =
        IExchange(0x29c66CF57a03d41Cfe6d9ecB6883aa0E2AbA21Ec);
    uint8 public constant unwindDecimals = 2;

    constructor(
        address voteExecutor,
        address gnosis,
        bool isTesting
    ) {
        if (isTesting) _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        else {
            require(voteExecutor.isContract(), "BalancerStrategy: 1!contract");
            require(gnosis.isContract(), "BalancerStrategy: 2!contract");
            _grantRole(DEFAULT_ADMIN_ROLE, gnosis);
            _grantRole(DEFAULT_ADMIN_ROLE, voteExecutor);
        }
    }

    function invest(bytes calldata data, uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bytes memory)
    {

        (bytes32 poolId, uint8 tokenIndex, bool stake) = decodeEntryParams(
            data
        );
        (data);
        (address[] memory tokens, , ) = balancer.getPoolTokens(poolId);

        IERC20 token = IERC20(tokens[tokenIndex]);
        token.safeApprove(address(balancer), amount);

        uint256[] memory amounts = new uint256[](tokens.length);
        amounts[tokenIndex] = amount;

        bytes memory userData = abi.encode(
            uint256(JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT),
            amounts,
            0
        );

        JoinPoolRequest memory request = JoinPoolRequest(
            tokens,
            amounts,
            userData,
            false
        );

        balancer.joinPool(poolId, address(this), address(this), request);

        if (stake) {
            (address lp, ) = balancer.getPool(poolId);
            ILiquidityGauge gauge = gaugeFactory.getPoolGauge(lp);
            uint256 lpAmount = IERC20(lp).balanceOf(address(this));
            IERC20(lp).approve(address(gauge), lpAmount);

            gauge.deposit(lpAmount, address(this), false);
        }

        return abi.encode(poolId, tokenIndex, stake);
    }

    function exitAll(
        bytes calldata data,
        uint256 unwindPercent,
        address outputCoin,
        address receiver,
        bool
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        (bytes32 poolId, uint8 tokenIndex, bool stake) = decodeExitParams(data);
        (address[] memory tokens, , ) = balancer.getPoolTokens(poolId);
        (address lp, ) = balancer.getPool(poolId);

        uint256 lpAmount;
        if (stake) {
            ILiquidityGauge gauge = gaugeFactory.getPoolGauge(lp);
            lpAmount =
                (gauge.balanceOf(address(this)) * unwindPercent) /
                (10**(2 + unwindDecimals));
            gauge.withdraw(lpAmount, true);
        } else {
            lpAmount =
                (IERC20(lp).balanceOf(address(this)) * unwindPercent) /
                (10**(2 + unwindDecimals));
        }

        uint256[] memory amounts = new uint256[](tokens.length);

        {
            bytes memory exitData = abi.encode(
                uint256(ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT),
                lpAmount,
                tokenIndex
            );

            ExitPoolRequest memory request = ExitPoolRequest(
                tokens,
                amounts,
                exitData,
                false
            );

            balancer.exitPool(
                poolId,
                address(this),
                payable(address(this)),
                request
            );
        }

        address tokenAddress = tokens[tokenIndex];
        exchangeAll(IERC20(tokenAddress), IERC20(outputCoin));

        IERC20(outputCoin).safeTransfer(
            receiver,
            IERC20(outputCoin).balanceOf(address(this))
        );
    }

    function exitOnlyRewards(
        bytes calldata,
        address,
        address,
        bool
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        return;
    }

    function encodeEntryParams(
        bytes32 poolId,
        uint8 tokenId,
        bool stake
    ) external pure returns (bytes memory) {

        return abi.encode(poolId, tokenId, stake);
    }

    function encodeExitParams(
        bytes32 poolId,
        uint8 tokenId,
        bool stake
    ) external pure returns (bytes memory) {

        return abi.encode(poolId, tokenId, stake);
    }

    function decodeEntryParams(bytes calldata data)
        public
        pure
        returns (
            bytes32,
            uint8,
            bool
        )
    {

        require(data.length == 32 * 3, "BalancerStrategy: length en");
        return abi.decode(data, (bytes32, uint8, bool));
    }

    function decodeExitParams(bytes calldata data)
        public
        pure
        returns (
            bytes32,
            uint8,
            bool
        )
    {

        require(data.length == 32 * 3, "BalancerStrategy: length ex");
        return abi.decode(data, (bytes32, uint8, bool));
    }

    function multicall(
        address[] calldata destinations,
        bytes[] calldata calldatas
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 length = destinations.length;
        require(length == calldatas.length, "BalancerStrategy: lengths");
        for (uint256 i = 0; i < length; i++) {
            destinations[i].functionCall(calldatas[i]);
        }
    }

    function exchangeAll(IERC20 fromCoin, IERC20 toCoin) private {

        if (fromCoin == toCoin) return;
        uint256 amount = IERC20(fromCoin).balanceOf(address(this));
        if (amount == 0) return;

        fromCoin.safeApprove(address(exchange), amount);
        exchange.exchange(address(fromCoin), address(toCoin), amount, 0);
    }
}