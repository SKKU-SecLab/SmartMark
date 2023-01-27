


pragma solidity 0.8.0;

library VeloxTransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        require(token != address(0), 'VeloxTransferHelper: ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');


        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        require(token != address(0), 'VeloxTransferHelper: ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        require(token != address(0), 'VeloxTransferHelper: TOKEN_ZERO_ADDRESS');
        require(from != address(0), 'VeloxTransferHelper: FROM_ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');
        
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

pragma solidity >=0.8.0;


interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}

pragma solidity >=0.8.0;


abstract contract IERC20NONStandard {

    uint256 public totalSupply;
    function balanceOf(address owner) virtual public view returns (uint256 balance);

    function transfer(address to, uint256 value) virtual public;

    function transferFrom(address from, address to, uint256 value) virtual public;


    function approve(address spender, uint256 value) virtual public returns (bool success);
    function allowance(address owner, address spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.8.0;

contract SwapExceptions {



    event SwapException(uint exception, uint info, uint detail);

    enum Exception {
        NO_ERROR,
        GENERIC_ERROR,
        UNAUTHORIZED,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW,
        DIVISION_BY_ZERO,
        BAD_INPUT,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_TRANSFER_FAILED,
        MARKET_NOT_SUPPORTED,
        SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_RATE_CALCULATION_FAILED,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_OUT_FAILED,
        INSUFFICIENT_LIQUIDITY,
        INSUFFICIENT_BALANCE,
        INVALID_COLLATERAL_RATIO,
        MISSING_ASSET_PRICE,
        EQUITY_INSUFFICIENT_BALANCE,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        ASSET_NOT_PRICED,
        INVALID_LIQUIDATION_DISCOUNT,
        INVALID_COMBINED_RISK_PARAMETERS,
        ZERO_ORACLE_ADDRESS,
        CONTRACT_PAUSED
    }

    enum Reason {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        BORROW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        BORROW_ACCOUNT_SHORTFALL_PRESENT,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_AMOUNT_LIQUIDITY_SHORTFALL,
        BORROW_AMOUNT_VALUE_CALCULATION_FAILED,
        BORROW_CONTRACT_PAUSED,
        BORROW_MARKET_NOT_SUPPORTED,
        BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        BORROW_ORIGINATION_FEE_CALCULATION_FAILED,
        BORROW_TRANSFER_OUT_FAILED,
        EQUITY_WITHDRAWAL_AMOUNT_VALIDATION,
        EQUITY_WITHDRAWAL_CALCULATE_EQUITY,
        EQUITY_WITHDRAWAL_MODEL_OWNER_CHECK,
        EQUITY_WITHDRAWAL_TRANSFER_OUT_FAILED,
        LIQUIDATE_ACCUMULATED_BORROW_BALANCE_CALCULATION_FAILED,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_AMOUNT_SEIZE_CALCULATION_FAILED,
        LIQUIDATE_BORROW_DENOMINATED_COLLATERAL_CALCULATION_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_TOO_HIGH,
        LIQUIDATE_CONTRACT_PAUSED,
        LIQUIDATE_DISCOUNTED_REPAY_TO_EVEN_AMOUNT_CALCULATION_FAILED,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_BORROW_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_SUPPLY_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_BORROW_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_CASH_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_FETCH_ASSET_PRICE_FAILED,
        LIQUIDATE_TRANSFER_IN_FAILED,
        LIQUIDATE_TRANSFER_IN_NOT_POSSIBLE,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_CONTRACT_PAUSED,
        REPAY_BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_ASSET_PRICE_CHECK_ORACLE,
        SET_MARKET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_ORACLE_OWNER_CHECK,
        SET_ORIGINATION_FEE_OWNER_CHECK,
        SET_PAUSED_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RISK_PARAMETERS_OWNER_CHECK,
        SET_RISK_PARAMETERS_VALIDATION,
        SUPPLY_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        SUPPLY_CONTRACT_PAUSED,
        SUPPLY_MARKET_NOT_SUPPORTED,
        SUPPLY_NEW_BORROW_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_BORROW_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_CASH_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        SUPPLY_TRANSFER_IN_FAILED,
        SUPPLY_TRANSFER_IN_NOT_POSSIBLE,
        SUPPORT_MARKET_FETCH_PRICE_FAILED,
        SUPPORT_MARKET_OWNER_CHECK,
        SUPPORT_MARKET_PRICE_CHECK,
        SUSPEND_MARKET_OWNER_CHECK,
        WITHDRAW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        WITHDRAW_ACCOUNT_SHORTFALL_PRESENT,
        WITHDRAW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        WITHDRAW_AMOUNT_LIQUIDITY_SHORTFALL,
        WITHDRAW_AMOUNT_VALUE_CALCULATION_FAILED,
        WITHDRAW_CAPACITY_CALCULATION_FAILED,
        WITHDRAW_CONTRACT_PAUSED,
        WITHDRAW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_BORROW_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        WITHDRAW_TRANSFER_OUT_FAILED,
        WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE
    }

    function raiseException(Exception exception, Reason reason) internal returns (uint) {

        emit SwapException(uint(exception), uint(reason), 0);
        return uint(exception);
    }

    function raiseGenericException(Reason reason, uint genericException) internal returns (uint) {

        emit SwapException(uint(Exception.GENERIC_ERROR), uint(reason), genericException);
        return uint(Exception.GENERIC_ERROR);
    }

}

pragma solidity 0.8.0;





contract Swappable is SwapExceptions {

    function checkTransferIn(address asset, address from, uint amount) internal view returns (Exception) {


        IERC20 token = IERC20(asset);

        if (token.allowance(from, address(this)) < amount) {
            return Exception.TOKEN_INSUFFICIENT_ALLOWANCE;
        }

        if (token.balanceOf(from) < amount) {
            return Exception.TOKEN_INSUFFICIENT_BALANCE;
        }

        return Exception.NO_ERROR;
    }

    function doTransferIn(address asset, address from, uint amount) internal returns (Exception) {

        IERC20NONStandard token = IERC20NONStandard(asset);
        bool result;
        require(token.allowance(from, address(this)) >= amount, 'Not enough allowance from client');
        token.transferFrom(from, address(this), amount);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        if (!result) {
            return Exception.TOKEN_TRANSFER_FAILED;
        }

        return Exception.NO_ERROR;
    }

    function getCash(address asset) internal view returns (uint) {

        IERC20 token = IERC20(asset);
        return token.balanceOf(address(this));
    }

    function getBalanceOf(address asset, address from) internal view returns (uint) {

        IERC20 token = IERC20(asset);
        return token.balanceOf(from);
    }

    function doTransferOut(address asset, address to, uint amount) internal returns (Exception) {

        IERC20NONStandard token = IERC20NONStandard(asset);
        bool result;
        token.transfer(to, amount);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        if (!result) {
            return Exception.TOKEN_TRANSFER_OUT_FAILED;
        }

        return Exception.NO_ERROR;
    }
}

pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.8.0;


abstract contract Ownable is Context {
    address private _owner;//proxy storage slot 4

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity >=0.8.0;


interface IVeloxSwapV4 {


    function withdrawToken(address token, uint256 amount) external;

    
    function withdrawETH(uint256 amount) external;


    function sellExactTokensForTokens(
        bytes memory signature,
        bytes memory secureData,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline
    ) external returns (uint256 amountOut);


    function sellExactTokensForTokens(
        bytes memory signature,
        bytes memory secureData,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost) external returns (uint256 amountOut);


    function fundGasCost(string memory  strategyId, address seller, bytes32 txHash, uint256 wethAmount) external;


}

pragma solidity >=0.8.0;

abstract contract BackingStore {
    address public MAIN_CONTRACT;//slot storage 0
    address public UNISWAP_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;//slot storage 1
    address public UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;//slot storage 2
    address public ADMIN_ADDRESS;//slot storage 3
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

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

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

pragma solidity 0.8.0;


contract AccessManager is AccessControl{


    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");//proxy storage slot 5
    modifier hasAdminRole() {

        require(hasRole(ADMIN_ROLE, _msgSender()), "VELOXSWAP: NOT_ADMIN");
        _;
    } 
    
}

pragma solidity 0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

pragma solidity 0.8.0;


abstract contract VeloxSwapV4 is BackingStore, Ownable, Swappable, IVeloxSwapV4, AccessManager {
    uint constant FEE_SCALE = 10000;

    address private gasFundingTokenAddress;//proxy storage slot 6
    bool private bypassSignatures;//proxy storage slot 7
    mapping(string => bool) public executedStrategies;//does not take a proxy slot
    uint public lifetimeGasWithrawn;//proxy storage slot 8
    uint public maxLifetimeGasWithdrawl;//proxy storage slot 9
    uint128 public gasFundingEstimatedGas;//proxy storage slot 10 first part
    uint128 public gasFundingEstimatedGasDiscounted;//proxy storage slot 10 second part
    function setDefaultGasEstimates(uint128 _gasFundingEstimatedGas, uint128 _gasFundingEstimatedGasDiscounted) public onlyOwner{
        gasFundingEstimatedGas = _gasFundingEstimatedGas;
        gasFundingEstimatedGasDiscounted = _gasFundingEstimatedGasDiscounted;
    }

    function setMaxLifetimeGasWithdrawl(uint _maxLifetimeGasWithdrawl) public onlyOwner {
        maxLifetimeGasWithdrawl = _maxLifetimeGasWithdrawl;
    }
    function setBypassSignature(bool _setBypassSignature) public onlyOwner {
        bypassSignatures = _setBypassSignature;
    }
    function setUpAdminRole(address _c) public onlyOwner returns (bool succeeded) {
        require(_c != owner(), "VELOXPROXY_ADMIN_OWNER");
        _setupRole(ADMIN_ROLE, _c);
        return true;
    }
    function setRootRole() public onlyOwner returns (bool succeeded) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        return true;
    }
    function grantAdminRole(address _c) public onlyOwner returns (bool succeeded) {
        require(_c != owner(), "VELOXPROXY_ADMIN_OWNER");
        grantRole(ADMIN_ROLE, _c);
        return true;
    }
    function revokeAdminRole(address _c) public onlyOwner returns (bool succeeded) {
        require(_c != owner(), "VELOXPROXY_ADMIN_OWNER");
        revokeRole(ADMIN_ROLE, _c);
        return true;
    }

    struct SignedData {
        uint chainId;
        string exchange;
        string identifier;
        address seller;
        address tokenInAddress;
        address tokenOutAddress;
        uint tokenInAmount;
    }

    event ValueSwapped(string indexed strategyId, address indexed seller, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event GasFunded(string indexed strategyId, address indexed seller, bytes32 indexed txHash, uint256 gasCost);
    event GasFundingTokenChanged(address oldValue, address newValue);
    event ExchangeRegistered(string indexed exchange, address indexed routerAddress);

    function setGasFundingTokenAddress(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "VELOXSWAP: ZERO_GAS_FUNDING_TOKEN_ADDRESS");

        address oldValue = gasFundingTokenAddress;

        gasFundingTokenAddress = tokenAddress;

        emit GasFundingTokenChanged(oldValue, gasFundingTokenAddress);
    }

    function getGasFundingTokenAddress() public view returns (address) {
        return gasFundingTokenAddress;
    }

    function setKnownExchange(string memory exchangeName, address routerAddress) onlyOwner external virtual {
        require(routerAddress != address(0), "VELOXSWAP: INVALID_ROUTER_ZERO_ADDRESS");

        _setKnownExchange(exchangeName, routerAddress);
        
        emit ExchangeRegistered(exchangeName, routerAddress);
    }

    function withdrawToken(address token, uint256 amount) onlyOwner override external {
        VeloxTransferHelper.safeTransfer(token, msg.sender, amount);
    }

    function withdrawETH(uint256 amount) onlyOwner override external {
        VeloxTransferHelper.safeTransferETH(msg.sender, amount);
    }

    function fundGasCost(string memory strategyId, address seller, bytes32 txHash, uint256 wethAmount) hasAdminRole override external {
        require(txHash.length > 0, "VELOXSWAP: INVALID_TX_HASH");

        _fundGasCost(strategyId, seller, txHash, wethAmount);
    }

    function _fundGasCost(string memory strategyId, address seller, bytes32 txHash, uint256 wethAmount) private {
        lifetimeGasWithrawn += wethAmount;
        require(lifetimeGasWithrawn < maxLifetimeGasWithdrawl,"Reached the max gas withdrawn; Admin must increase allowance");
        VeloxTransferHelper.safeTransferFrom(gasFundingTokenAddress, seller, _msgSender(), wethAmount);
        
        emit GasFunded(strategyId, seller, txHash, wethAmount);
    }

    function _decodeAndDedupe(bytes memory secureData, bytes memory signature) private returns (SignedData memory signedData) {
        {
            uint chainId;
            string memory exchange;
            string memory identifier;
            address seller;
            address tokenInAddress;
            address tokenOutAddress;
            uint tokenInAmount;
            (
                chainId,
                exchange,
                identifier,
                seller,
                tokenInAddress,
                tokenOutAddress,
                tokenInAmount
            ) = abi.decode(secureData, (
                uint,
                string,
                string,
                address,
                address,
                address,
                uint
            ));
            signedData = SignedData(
            chainId,
            exchange,
            identifier,
            seller,
            tokenInAddress,
            tokenOutAddress,
            tokenInAmount
            );
        }
        executedStrategies[signedData.identifier] = true;
        if (!bypassSignatures){
            require(signedData.chainId == block.chainid, "Invalid chainid");
            bytes32 eip712DomainHash = 0x6192106f129ce05c9075d319c1fa6ea9b3ae37cbd0c1ef92e2be7137bb07baa1;//keccak256(abi.encode(keccak256("EIP712Domain()")));
            bytes32 hashStruct = keccak256(
                abi.encode(
                    0x2b803e05594cddd16e135b36b9f02d2b361090caece35ef508187601a90012e7, //keccak256("Strategy(uint chainId,string exchange,string identifier,address userAddress,address tokenInAddress,address tokenOutAddress,uint tokenInAmount)"),
                    signedData.chainId,
                    keccak256(bytes(signedData.exchange)),
                    keccak256(bytes(signedData.identifier)),
                    signedData.seller,
                    signedData.tokenInAddress,
                    signedData.tokenOutAddress,
                    signedData.tokenInAmount
                )
            );
            bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
            address signer = ECDSA.recover(hash, signature);
            require(signer == signedData.seller,"Invalid signature");
        }
    }

    function sellExactTokensForTokens(
        bytes memory signature,
        bytes memory secureData,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost
    ) override hasAdminRole public returns (uint256 amountOut) {
        uint256 initialGas = gasleft();
        SignedData memory signedData = _decodeAndDedupe(secureData, signature);

        amountOut = swapTokens(signedData, minTokenOutAmount, feeFactor, takeFeeFromInput, deadline);

        if (isTakingOutputFeeInGasToken(takeFeeFromInput, signedData.tokenOutAddress)) {
            estimatedGasFundingCost = gasFundingEstimatedGasDiscounted;
        }

        uint256 gasCost = (initialGas - gasleft() + estimatedGasFundingCost) * tx.gasprice;

        bytes32 txHash;
        _fundGasCost(signedData.identifier, signedData.seller, txHash, gasCost);
    }

    function sellExactTokensForTokens(
        bytes memory signature,
        bytes memory secureData,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline
    ) override hasAdminRole public returns (uint256 amountOut) {
        amountOut = sellExactTokensForTokens(signature, secureData, minTokenOutAmount, feeFactor, takeFeeFromInput, deadline, gasFundingEstimatedGas);
    }

    function swapTokens(SignedData memory signedData, uint minTokenOutAmount, uint16 feeFactor, bool takeFeeFromInput, uint deadline) private returns (uint256 actualAmountOutAfterFee) {
        uint256 amountInForSwap;
        uint256 amountOutForSwap;
        address swapTargetAddress;

        (amountInForSwap, amountOutForSwap , swapTargetAddress)
            = prepareSwap(signedData, feeFactor, deadline, minTokenOutAmount, takeFeeFromInput);

        uint originalOutTokenBalance = getBalanceOf(signedData.tokenOutAddress, address(this))+getBalanceOf(signedData.tokenOutAddress, address(signedData.seller));
        doSwap(signedData.exchange, signedData.tokenInAddress, signedData.tokenOutAddress, amountInForSwap, amountOutForSwap, swapTargetAddress, deadline);
        uint256 actualAmountOut = getBalanceOf(signedData.tokenOutAddress, address(this))+getBalanceOf(signedData.tokenOutAddress, address(signedData.seller))  - originalOutTokenBalance;

        actualAmountOutAfterFee = actualAmountOut;
        if (!takeFeeFromInput) {
            actualAmountOutAfterFee = withdrawToUser(actualAmountOut, feeFactor, signedData.tokenOutAddress, signedData.seller);
        }

        emit ValueSwapped(signedData.identifier, signedData.seller, signedData.tokenInAddress, signedData.tokenOutAddress, signedData.tokenInAmount, actualAmountOutAfterFee);
    }

    function prepareSwap(SignedData memory signedData, uint16 feeFactor, uint deadline, uint minTokenOutAmount, bool takeFeeFromInput
    ) private returns (uint256 amountInForSwap, uint256 amountOutForSwap, address targetAddress) {
        validateInput(signedData, minTokenOutAmount, feeFactor, deadline);

        uint originalBalance;
        uint transferResult;

        {
            originalBalance = getBalanceOf(signedData.tokenInAddress, address(this));
            Exception exception = doTransferIn(signedData.tokenInAddress, signedData.seller, signedData.tokenInAmount);
            transferResult = getBalanceOf(signedData.tokenInAddress, address(this)) - originalBalance;
            require(exception == Exception.NO_ERROR, 'VELOXSWAP: ALLOWANCE_TOO_LOW');
            require(transferResult > 0, 'VELOXSWAP: FAILED_TO_TRANSFER_IN');
        }
        uint reducedTokenOutAmount = minTokenOutAmount*transferResult/signedData.tokenInAmount;
        (amountInForSwap, amountOutForSwap, targetAddress) = adjustInputBasedOnFee(takeFeeFromInput, feeFactor, transferResult, reducedTokenOutAmount, signedData.seller);
        checkLiquidity(signedData.exchange, signedData.tokenInAddress, signedData.tokenOutAddress, amountOutForSwap);
    }

    function validateInput(SignedData memory signedData, uint256 minTokenOutAmount, uint16 feeFactor, uint256 deadline) private view {

        require(deadline >= block.timestamp, 'VELOXSWAP: EXPIRED');
        require(feeFactor <= 30, 'VELOXSWAP: FEE_OVER_03_PERCENT');

        require(gasFundingTokenAddress != address(0), 'VELOXSWAP: GAS_FUNDING_ADDRESS_NOT_FOUND');

        require (signedData.seller != address(0) &&
            signedData.tokenInAddress != address(0) &&
            signedData.tokenOutAddress != address(0) &&
            signedData.tokenInAmount > 0 &&
                minTokenOutAmount > 0,
        'VELOXSWAP: ZERO_DETECTED');
    }

    function adjustInputBasedOnFee(bool takeFeeFromInput, uint16 feeFactor, uint256 amountIn, uint256 amountOut, address sellerAddress) private view
    returns (uint256 amountInForSwap, uint256 amountOutForSwap, address targetAddress) {
        if (takeFeeFromInput) {
            amountInForSwap = deductFee(amountIn, feeFactor);
            amountOutForSwap = deductFee(amountOut, feeFactor);

            targetAddress = sellerAddress;
        } else {
            amountInForSwap = amountIn;
            amountOutForSwap = amountOut;
            targetAddress = address(this);
        }
    }

    function doSwap(string memory exchange, address tokenInAddress, address tokenOutAddress, uint256 tokenInAmount, uint256 minTokenOutAmount, address targetAddress, uint256 deadline) private {
        safeApproveExchangeRouter(exchange, tokenInAddress, tokenInAmount);

        address[] memory path = new address[](2);
        path[0] = tokenInAddress;
        path[1] = tokenOutAddress;

        swapExactTokensForTokensSupportingFeeOnTransferTokens(
            exchange,
            tokenInAmount,
            minTokenOutAmount,
            path,
            targetAddress,
            deadline
        );
    }

    function checkLiquidity(string memory exchange, address tokenInAddress, address tokenOutAddress, uint256 minTokenOutAmount) private view {
        (uint reserveIn, uint reserveOut) = getLiquidityForPair(exchange, tokenInAddress, tokenOutAddress);
        require(reserveIn > 0 && reserveOut > 0, 'VELOXSWAP: ZERO_RESERVE_DETECTED');
        require(reserveOut > minTokenOutAmount, 'VELOXSWAP: NOT_ENOUGH_LIQUIDITY');
    }

    function withdrawToUser(uint256 amountOut, uint16 feeFactor, address tokenOutAddress,
        address from) private returns (uint256 transferredAmount) {

        transferredAmount = deductFee(amountOut, feeFactor);
        Exception exception = doTransferOut(tokenOutAddress, from, transferredAmount);
        require (exception == Exception.NO_ERROR, 'VELOXSWAP: ERROR_GETTING_OUTPUT_FEE');
    }

    function deductFee(uint256 amount, uint16 feeFactor) private pure returns (uint256 deductedAmount) {
        deductedAmount = (amount * (FEE_SCALE - feeFactor)) / FEE_SCALE;
    }
    
    function isTakingOutputFeeInGasToken(bool takeFeeFromInput, address tokenOutAddress) private view returns (bool) {
        return !takeFeeFromInput && tokenOutAddress == gasFundingTokenAddress;
    }


    function _setKnownExchange(string memory exchangeName, address routerAddress) internal virtual;

    function safeApproveExchangeRouter(string memory exchange, address tokenInAddress, uint256 tokenInAmount) internal virtual;

    function getLiquidityForPair(string memory exchange, address tokenInAddress, address tokenOutAddress) view internal virtual returns (uint reserveIn, uint reserveOut);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        string memory exchange,
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) internal virtual;
}

pragma solidity >=0.8.0;


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

}

pragma solidity >=0.8.0;


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

}

pragma solidity >=0.8.0;


interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

pragma solidity >=0.8.0;


interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}

pragma solidity 0.8.0;



contract UniswapV2VeloxSwapV4 is VeloxSwapV4 {


    mapping (string=>IUniswapV2Router02) routersByName;

function _setKnownExchange(string memory exchangeName, address uniswapLikeRouterAddress) onlyOwner override internal {

        require(uniswapLikeRouterAddress != address(0), "VELOXSWAP: INVALID_ROUTER_ADDRESS");

        IUniswapV2Router02 newRouter = IUniswapV2Router02(uniswapLikeRouterAddress);

        require(address(newRouter.factory()) != address(0), "VELOXSWAP: INVALID_ROUTER");

        routersByName[exchangeName] = newRouter;
    }

    function safeApproveExchangeRouter(string memory exchange, address tokenInAddress, uint256 tokenInAmount) override internal {

        IUniswapV2Router02 router = getRouter(exchange);

        VeloxTransferHelper.safeApprove(tokenInAddress, address(router), tokenInAmount);
    }


    function getLiquidityForPair(string memory exchange, address tokenInAddress, address tokenOutAddress) view internal override returns (uint reserveIn, uint reserveOut) {


        IUniswapV2Router02 router = getRouter(exchange);
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());

        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(tokenInAddress, tokenOutAddress));
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();

        if (pair.token0() == tokenOutAddress) {
            reserveIn = reserve1;
            reserveOut = reserve0;
        } else {
            reserveIn = reserve0;
            reserveOut = reserve1;
        }
    }

    function getRouter(string memory exchange) private view returns (IUniswapV2Router02 router) {

        router = routersByName[exchange];

        require(address(router) != address(0), "VELOXSWAP: UNKNOWN_EXCHANGE");
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        string memory exchange,
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) override internal virtual {

        IUniswapV2Router02 router = getRouter(exchange);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }
}