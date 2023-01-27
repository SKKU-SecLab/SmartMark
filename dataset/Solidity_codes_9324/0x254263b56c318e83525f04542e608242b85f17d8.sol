
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// UNLICENSED
pragma solidity 0.8.9;


contract Withdrawable is Ownable {


    function withdrawToken(address _token, uint256 _amount) external onlyOwner {

        SafeERC20.safeTransfer(IERC20(_token), owner(), _amount);
    }

    function withdrawETH(uint256 _amount) external onlyOwner {

        payable(owner()).transfer(_amount);
    }
}// UNLICENSED

pragma solidity 0.8.9;


contract TokenTransferProxy is Ownable {


    modifier onlyAuthorized {

        require(authorized[msg.sender]);
        _;
    }

    modifier targetAuthorized(address target) {

        require(authorized[target]);
        _;
    }

    modifier targetNotAuthorized(address target) {

        require(!authorized[target]);
        _;
    }

    mapping (address => bool) public authorized;

    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);
    event LogAuthorizedAddressRemoved(address indexed target, address indexed caller);


    function addAuthorizedAddress(address target)
        public
        onlyOwner
        targetNotAuthorized(target)
    {

        authorized[target] = true;
        emit LogAuthorizedAddressAdded(target, msg.sender);
    }

    function removeAuthorizedAddress(address target)
        public
        onlyOwner
        targetAuthorized(target)
    {

        authorized[target] = false;

        emit LogAuthorizedAddressRemoved(target, msg.sender);
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint value)
        public
        onlyAuthorized
    {

        SafeERC20.safeTransferFrom(IERC20(token), from, to, value);
    }
}// UNLICENSED
pragma solidity 0.8.9;



library Utils {


    uint256 constant internal PRECISION = (10**18);
    uint256 constant internal MAX_QTY   = (10**28); // 10B tokens
    uint256 constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
    uint256 constant internal MAX_DECIMALS = 18;
    uint256 constant internal ETH_DECIMALS = 18;
    uint256 constant internal MAX_UINT = 2**256-1;
    address constant internal ETH_ADDRESS = address(0x0);

    function precision() internal pure returns (uint256) { return PRECISION; }

    function max_qty() internal pure returns (uint256) { return MAX_QTY; }

    function max_rate() internal pure returns (uint256) { return MAX_RATE; }

    function max_decimals() internal pure returns (uint256) { return MAX_DECIMALS; }

    function eth_decimals() internal pure returns (uint256) { return ETH_DECIMALS; }

    function max_uint() internal pure returns (uint256) { return MAX_UINT; }

    function eth_address() internal pure returns (address) { return ETH_ADDRESS; }


    function getDecimals(address token)
        internal
        returns (uint256 decimals)
    {

        bytes4 functionSig = bytes4(keccak256("decimals()"));

        assembly {
            let ptr := mload(0x40)
            mstore(ptr,functionSig)
            let functionSigLength := 0x04
            let wordLength := 0x20

            let success := call(
                                gas(), // Amount of gas
                                token, // Address to call
                                0, // ether to send
                                ptr, // ptr to input data
                                functionSigLength, // size of data
                                ptr, // where to store output data (overwrite input)
                                wordLength // size of output data (32 bytes)
                               )

            switch success
            case 0 {
                decimals := 0 // If the token doesn't implement `decimals()`, return 0 as default
            }
            case 1 {
                decimals := mload(ptr) // Set decimals to return data from call
            }
            mstore(0x40,add(ptr,0x04)) // Reset the free memory pointer to the next known free location
        }
    }

    function tokenAllowanceAndBalanceSet(
        address tokenOwner,
        address tokenAddress,
        uint256 tokenAmount,
        address addressToAllow
    )
        internal
        view
        returns (bool)
    {

        return (
            IERC20(tokenAddress).allowance(tokenOwner, addressToAllow) >= tokenAmount &&
            IERC20(tokenAddress).balanceOf(tokenOwner) >= tokenAmount
        );
    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns (uint) {

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns (uint) {


        uint numerator;
        uint denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcDestAmount(IERC20 src, IERC20 dest, uint srcAmount, uint rate) internal returns (uint) {

        return calcDstQty(srcAmount, getDecimals(address(src)), getDecimals(address(dest)), rate);
    }

    function calcSrcAmount(IERC20 src, IERC20 dest, uint destAmount, uint rate) internal returns (uint) {

        return calcSrcQty(destAmount, getDecimals(address(src)), getDecimals(address(dest)), rate);
    }

    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
        internal pure returns (uint)
    {

        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
        }
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
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
}// UNLICENSED
pragma solidity 0.8.9;



contract PartnerRegistry is Ownable, Pausable {

    address target;
    mapping(address => bool) partnerContracts;
    address payable public companyBeneficiary;
    uint256 public basePercentage;
    PartnerRegistry public previousRegistry;

    event PartnerRegistered(
        address indexed creator,
        address indexed beneficiary,
        address partnerContract
    );

    constructor(
        PartnerRegistry _previousRegistry,
        address _target,
        address payable _companyBeneficiary,
        uint256 _basePercentage
    ) {
        previousRegistry = _previousRegistry;
        target = _target;
        companyBeneficiary = _companyBeneficiary;
        basePercentage = _basePercentage;
    }


    function registerPartner(
        address payable partnerBeneficiary,
        uint256 partnerPercentage
    ) external whenNotPaused {

        Partner newPartner = Partner(createClone());
        newPartner.init(
            this,
            payable(0x0),
            0,
            partnerBeneficiary,
            partnerPercentage
        );
        partnerContracts[address(newPartner)] = true;
        emit PartnerRegistered(
            address(msg.sender),
            partnerBeneficiary,
            address(newPartner)
        );
    }

    function overrideRegisterPartner(
        address payable _companyBeneficiary,
        uint256 _companyPercentage,
        address payable partnerBeneficiary,
        uint256 partnerPercentage
    ) external onlyOwner {

        Partner newPartner = Partner(createClone());
        newPartner.init(
            PartnerRegistry(0x0000000000000000000000000000000000000000),
            _companyBeneficiary,
            _companyPercentage,
            partnerBeneficiary,
            partnerPercentage
        );
        partnerContracts[address(newPartner)] = true;
        emit PartnerRegistered(
            address(msg.sender),
            partnerBeneficiary,
            address(newPartner)
        );
    }

    function deletePartner(address partnerContract) external onlyOwner {

        partnerContracts[partnerContract] = false;
    }


    function createClone() internal returns (address payable result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }

    function isValidPartner(address partnerContract)
        external
        view
        returns (bool)
    {

        return
            partnerContracts[partnerContract] ||
            previousRegistry.isValidPartner(partnerContract);
    }

    function updateCompanyInfo(
        address payable newCompanyBeneficiary,
        uint256 newBasePercentage
    ) external onlyOwner {

        companyBeneficiary = newCompanyBeneficiary;
        basePercentage = newBasePercentage;
    }
}// MIT

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

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
}// UNLICENSED
pragma solidity 0.8.9;



contract Partner is ReentrancyGuard {

    address payable public partnerBeneficiary;
    uint256 public partnerPercentage; //This is out of 1 ETH, e.g. 0.5 ETH is 50% of the fee

    uint256 public overrideCompanyPercentage;
    address payable public overrideCompanyBeneficiary;

    PartnerRegistry public registry;

    event LogPayout(address[] tokens, uint256[] amount);

    function init(
        PartnerRegistry _registry,
        address payable _overrideCompanyBeneficiary,
        uint256 _overrideCompanyPercentage,
        address payable _partnerBeneficiary,
        uint256 _partnerPercentage
    ) public {

        require(
            registry ==
                PartnerRegistry(0x0000000000000000000000000000000000000000) &&
                overrideCompanyBeneficiary == address(0x0) &&
                partnerBeneficiary == address(0x0)
        );
        overrideCompanyBeneficiary = _overrideCompanyBeneficiary;
        overrideCompanyPercentage = _overrideCompanyPercentage;
        partnerBeneficiary = _partnerBeneficiary;
        partnerPercentage = _partnerPercentage;
        overrideCompanyPercentage = _overrideCompanyPercentage;
        registry = _registry;
    }

    function payout(address[] memory tokens) public nonReentrant {

        uint256 totalFeePercentage = getTotalFeePercentage();
        address payable _companyBeneficiary = companyBeneficiary();
        uint256[] memory amountsPaidOut = new uint256[](tokens.length);
        for (uint256 index = 0; index < tokens.length; index++) {
            uint256 balance = tokens[index] == Utils.eth_address()
                ? address(this).balance
                : IERC20(tokens[index]).balanceOf(address(this));
            amountsPaidOut[index] = balance;
            uint256 partnerAmount = SafeMath.div(
                SafeMath.mul(balance, partnerPercentage),
                totalFeePercentage
            );
            uint256 companyAmount = balance - partnerAmount;
            if (tokens[index] == Utils.eth_address()) {
                bool success;
                (success,) = partnerBeneficiary.call{value: partnerAmount, gas: 5000}("");
                require(success,"Transfer failed");
                (success,) =_companyBeneficiary.call{value: companyAmount, gas: 5000}("");
                require(success,"Transfer failed");

            } else {
                SafeERC20.safeTransfer(
                    IERC20(tokens[index]),
                    partnerBeneficiary,
                    partnerAmount
                );
                SafeERC20.safeTransfer(
                    IERC20(tokens[index]),
                    _companyBeneficiary,
                    companyAmount
                );
            }
        }
        emit LogPayout(tokens, amountsPaidOut);
    }

    function getTotalFeePercentage() public view returns (uint256) {

        return partnerPercentage + companyPercentage();
    }

    function companyPercentage() public view returns (uint256) {

        if (
            registry !=
            PartnerRegistry(0x0000000000000000000000000000000000000000)
        ) {
            return Math.max(registry.basePercentage(), partnerPercentage);
        } else {
            return overrideCompanyPercentage;
        }
    }

    function companyBeneficiary() public view returns (address payable) {

        if (
            registry !=
            PartnerRegistry(0x0000000000000000000000000000000000000000)
        ) {
            return registry.companyBeneficiary();
        } else {
            return overrideCompanyBeneficiary;
        }
    }

    receive() external payable {}
}// UNLICENSED
pragma solidity 0.8.9;

library TokenBalanceLibrary {

    struct TokenBalance {
        address tokenAddress;
        uint256 balance;
    }

     

    function findToken(TokenBalance[] memory balances, address token)
        internal
        pure
        returns (uint256 tokenEntry)
    {

        for (uint256 index = 0; index < balances.length; index++) {
            if (balances[index].tokenAddress == token) {
                return index;
            } else if (
                index != 0 && balances[index].tokenAddress == address(0x0)
            ) {
                balances[index] = TokenBalance(token, 0);
                return index;
            }
        }
    }

    function addBalance(
        TokenBalance[] memory balances,
        address token,
        uint256 amountToAdd
    ) internal pure {

        uint256 tokenIndex = findToken(balances, token);
        addBalance(balances, tokenIndex, amountToAdd);
    }

    function addBalance(
        TokenBalance[] memory balances,
        uint256 tokenIndex,
        uint256 amountToAdd
    ) internal pure {

        balances[tokenIndex].balance += amountToAdd;
    }

    function removeBalance(
        TokenBalance[] memory balances,
        address token,
        uint256 amountToRemove
    ) internal pure {

        uint256 tokenIndex = findToken(balances, token);
        removeBalance(balances, tokenIndex, amountToRemove);
    }

    function removeBalance(
        TokenBalance[] memory balances,
        uint256 tokenIndex,
        uint256 amountToRemove
    ) internal pure {

        balances[tokenIndex].balance -= amountToRemove;
    }
}// UNLICENSED
pragma solidity 0.8.9;



abstract contract ExchangeHandler is Withdrawable {


    function performOrder(
        bytes memory genericPayload,
        uint256 availableToSpend,
        uint256 targetAmount
    )
        external
        payable
        virtual
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder);


    receive() external payable {
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        require(size > 0);
    }


    function getMaxToSpend(uint256 targetAmount, uint256 availableToSpend)
        internal
        pure
        returns (uint256 max)
    {
        max = Math.min(availableToSpend, targetAmount);
        return max;
    }
}// UNLICENSED
pragma solidity 0.8.9;



contract TotlePrimary is Withdrawable, Pausable {


    TokenTransferProxy public tokenTransferProxy;
    mapping(address => bool) public signers;


    struct Order {
        address payable exchangeHandler;
        bytes encodedPayload;
    }

    struct Trade {
        address sourceToken;
        address destinationToken;
        uint256 amount;
        Order[] orders;
    }

    struct Swap {
        Trade[] trades;
        uint256 minimumDestinationAmount;
        uint256 minimumExchangeRate;
        uint256 sourceAmount;
        uint256 tradeToTakeFeeFrom;
        bool takeFeeFromSource; //Takes the fee before the trade if true, takes it after if false
        address payable redirectAddress;
    }

    struct SwapCollection {
        Swap[] swaps;
        uint256 expirationBlock;
        bytes32 id;
        uint256 maxGasPrice;
        address payable partnerContract;
        uint8 tokenCount;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }


    event LogSwapCollection(
        bytes32 indexed id,
        address indexed partnerContract,
        address indexed user
    );

    event LogSwap(
        bytes32 indexed id,
        address sourceAsset,
        address destinationAsset,
        uint256 sourceAmount,
        uint256 destinationAmount,
        address feeAsset,
        uint256 feeAmount
    );

    constructor(address _tokenTransferProxy, address _signer) {
        tokenTransferProxy = TokenTransferProxy(_tokenTransferProxy);
        signers[_signer] = true;
    }


    modifier notExpired(SwapCollection memory swaps) {

        require(swaps.expirationBlock > block.number, "Expired");
        _;
    }

    modifier validSignature(SwapCollection memory swaps) {

        uint256 chainId = block.chainid;
        bytes32 hash = keccak256(
            abi.encode(
                chainId,
                swaps.swaps,
                swaps.partnerContract,
                swaps.expirationBlock,
                swaps.id,
                swaps.maxGasPrice,
                msg.sender
            )
        );
        require(
            signers[
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    swaps.v,
                    swaps.r,
                    swaps.s
                )
            ],
            "Invalid signature"
        );
        _;
    }

    modifier notAboveMaxGas(SwapCollection memory swaps) {

        require(tx.gasprice <= swaps.maxGasPrice, "Gas price too high");
        _;
    }


    function performSwapCollection(SwapCollection memory swaps)
        public
        payable
        whenNotPaused
        notExpired(swaps)
        validSignature(swaps)
        notAboveMaxGas(swaps)
    {

        TokenBalanceLibrary.TokenBalance[]
            memory balances = new TokenBalanceLibrary.TokenBalance[](
                swaps.tokenCount
            );
        balances[0] = TokenBalanceLibrary.TokenBalance(
            address(Utils.eth_address()),
            msg.value
        );
        for (
            uint256 swapIndex = 0;
            swapIndex < swaps.swaps.length;
            swapIndex++
        ) {
            performSwap(
                swaps.id,
                swaps.swaps[swapIndex],
                balances,
                swaps.partnerContract
            );
        }
        emit LogSwapCollection(swaps.id, swaps.partnerContract, msg.sender);
        transferAllTokensToUser(balances);
    }

    function addSigner(address newSigner) public onlyOwner {

        require(newSigner != address(0x0), "");
        signers[newSigner] = true;
    }

    function removeSigner(address signer) public onlyOwner {

        signers[signer] = false;
    }


    function performSwap(
        bytes32 swapCollectionId,
        Swap memory swap,
        TokenBalanceLibrary.TokenBalance[] memory balances,
        address payable partnerContract
    ) internal {

        transferFromSenderDifference(
            balances,
            swap.trades[0].sourceToken,
            swap.sourceAmount
        );

        uint256 amountSpentFirstTrade = 0;
        uint256 amountReceived = 0;
        uint256 feeAmount = 0;
        for (
            uint256 tradeIndex = 0;
            tradeIndex < swap.trades.length;
            tradeIndex++
        ) {
            if (
                tradeIndex == swap.tradeToTakeFeeFrom && swap.takeFeeFromSource
            ) {
                feeAmount = takeFee(
                    balances,
                    swap.trades[tradeIndex].sourceToken,
                    partnerContract,
                    tradeIndex == 0 ? swap.sourceAmount : amountReceived
                );
            }
            uint256 tempSpent;
            (tempSpent, amountReceived) = performTrade(
                swap.trades[tradeIndex],
                balances,
                Utils.min(
                    tradeIndex == 0 ? swap.sourceAmount : amountReceived,
                    balances[
                        TokenBalanceLibrary.findToken(
                            balances,
                            swap.trades[tradeIndex].sourceToken
                        )
                    ].balance
                )
            );
            if (tradeIndex == 0) {
                amountSpentFirstTrade = tempSpent + feeAmount;
                if (feeAmount != 0) {
                    amountSpentFirstTrade += feeAmount;
                }
            }
            if (
                tradeIndex == swap.tradeToTakeFeeFrom && !swap.takeFeeFromSource
            ) {
                feeAmount = takeFee(
                    balances,
                    swap.trades[tradeIndex].destinationToken,
                    partnerContract,
                    amountReceived
                );
                amountReceived -= feeAmount;
            }
        }
        emit LogSwap(
            swapCollectionId,
            swap.trades[0].sourceToken,
            swap.trades[swap.trades.length - 1].destinationToken,
            amountSpentFirstTrade,
            amountReceived,
            swap.takeFeeFromSource
                ? swap.trades[swap.tradeToTakeFeeFrom].sourceToken
                : swap.trades[swap.tradeToTakeFeeFrom].destinationToken,
            feeAmount
        );
        require(
            amountReceived >= swap.minimumDestinationAmount,
            "Get less than minimumDestinationAmount"
        );
        require(
            !minimumRateFailed(
                swap.trades[0].sourceToken,
                swap.trades[swap.trades.length - 1].destinationToken,
                swap.sourceAmount,
                amountReceived,
                swap.minimumExchangeRate
            ),
            "minimumExchangeRate not met"
        );
        if (
            swap.redirectAddress != msg.sender &&
            swap.redirectAddress != address(0x0)
        ) {
            uint256 destinationTokenIndex = TokenBalanceLibrary.findToken(
                balances,
                swap.trades[swap.trades.length - 1].destinationToken
            );
            uint256 amountToSend = Math.min(
                amountReceived,
                balances[destinationTokenIndex].balance
            );
            transferTokens(
                balances,
                destinationTokenIndex,
                swap.redirectAddress,
                amountToSend
            );
            TokenBalanceLibrary.removeBalance(
                balances,
                swap.trades[swap.trades.length - 1].destinationToken,
                amountToSend
            );
        }
    }

    function performTrade(
        Trade memory trade,
        TokenBalanceLibrary.TokenBalance[] memory balances,
        uint256 availableToSpend
    ) internal returns (uint256 totalSpent, uint256 totalReceived) {

        uint256 tempSpent = 0;
        uint256 tempReceived = 0;
        for (
            uint256 orderIndex = 0;
            orderIndex < trade.orders.length;
            orderIndex++
        ) {
            if (tempSpent >= trade.amount) {
                break;
            }
            (tempSpent, tempReceived) = performOrder(
                trade.orders[orderIndex],
                availableToSpend - totalSpent,
                trade.sourceToken,
                balances
            );
            totalSpent += tempSpent;
            totalReceived += tempReceived;
        }
        TokenBalanceLibrary.addBalance(
            balances,
            trade.destinationToken,
            totalReceived
        );
        TokenBalanceLibrary.removeBalance(
            balances,
            trade.sourceToken,
            totalSpent
        );
    }

    function performOrder(
        Order memory order,
        uint256 targetAmount,
        address tokenToSpend,
        TokenBalanceLibrary.TokenBalance[] memory balances
    ) internal returns (uint256 spent, uint256 received) {

        if (tokenToSpend == Utils.eth_address()) {
            (spent, received) = ExchangeHandler(order.exchangeHandler)
                .performOrder{value: targetAmount}(
                order.encodedPayload,
                targetAmount,
                targetAmount
            );
        } else {
            transferTokens(
                balances,
                TokenBalanceLibrary.findToken(balances, tokenToSpend),
                order.exchangeHandler,
                targetAmount
            );
            (spent, received) = ExchangeHandler(order.exchangeHandler)
                .performOrder(order.encodedPayload, targetAmount, targetAmount);
        }
    }

    function minimumRateFailed(
        address sourceToken,
        address destinationToken,
        uint256 sourceAmount,
        uint256 destinationAmount,
        uint256 minimumExchangeRate
    ) internal returns (bool failed) {

        uint256 sourceDecimals = sourceToken == Utils.eth_address()
            ? 18
            : Utils.getDecimals(sourceToken);
        uint256 destinationDecimals = destinationToken == Utils.eth_address()
            ? 18
            : Utils.getDecimals(destinationToken);
        uint256 rateGot = Utils.calcRateFromQty(
            sourceAmount,
            destinationAmount,
            sourceDecimals,
            destinationDecimals
        );
        return rateGot < minimumExchangeRate;
    }

    function takeFee(
        TokenBalanceLibrary.TokenBalance[] memory balances,
        address token,
        address payable partnerContract,
        uint256 amountTraded
    ) internal returns (uint256 feeAmount) {

        Partner partner = Partner(partnerContract);
        uint256 feePercentage = partner.getTotalFeePercentage();
        feeAmount = calculateFee(amountTraded, feePercentage);
        uint256 tokenIndex = TokenBalanceLibrary.findToken(balances, token);
        TokenBalanceLibrary.removeBalance(
            balances,
            tokenIndex,
            feeAmount
        );
        transferTokens(
            balances,
            tokenIndex,
            partnerContract,
            feeAmount
        );
        return feeAmount;
    }

    function transferFromSenderDifference(
        TokenBalanceLibrary.TokenBalance[] memory balances,
        address token,
        uint256 sourceAmount
    ) internal {

        if (token == Utils.eth_address()) {
            require(
                sourceAmount >= balances[0].balance,
                "Not enough ETH to perform swap"
            );
        } else {
            uint256 tokenIndex = TokenBalanceLibrary.findToken(balances, token);
            if (sourceAmount > balances[tokenIndex].balance) {
                SafeERC20.safeTransferFrom(
                    IERC20(token),
                    msg.sender,
                    address(this),
                    sourceAmount - balances[tokenIndex].balance
                );
            }
        }
    }

    function transferAllTokensToUser(
        TokenBalanceLibrary.TokenBalance[] memory balances
    ) internal {

        for (
            uint256 balanceIndex = 0;
            balanceIndex < balances.length;
            balanceIndex++
        ) {
            if (
                balanceIndex != 0 &&
                balances[balanceIndex].tokenAddress == address(0x0)
            ) {
                return;
            }
            transferTokens(
                balances,
                balanceIndex,
                payable(msg.sender),
                balances[balanceIndex].balance
            );
        }
    }

    function transferTokens(
        TokenBalanceLibrary.TokenBalance[] memory balances,
        uint256 tokenIndex,
        address payable destination,
        uint256 tokenAmount
    ) internal {

        if (tokenAmount > 0) {
            if (balances[tokenIndex].tokenAddress == Utils.eth_address()) {
                destination.transfer(tokenAmount);
            } else {
                SafeERC20.safeTransfer(
                    IERC20(balances[tokenIndex].tokenAddress),
                    destination,
                    tokenAmount
                );
            }
        }
    }

    function calculateFee(uint256 amount, uint256 fee)
        internal
        pure
        returns (uint256)
    {

        return SafeMath.div(SafeMath.mul(amount, fee), 1 * (10**18));
    }


    receive() external payable whenNotPaused {
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        if (size == 0) {
            revert("EOA cannot send ether to primary receive function");
        }
    }
}