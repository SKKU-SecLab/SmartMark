
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


library SafeMathUpgradeable {

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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}//GPL-2.0
pragma solidity ^0.8.7;


interface Vault {

    function deposit(uint256 _amount) external;

}

contract Wido is Initializable, OwnableUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            )
        );
    bytes32 private constant DEPOSIT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Deposit(address user,address token,address vault,uint256 amount,uint32 nonce,uint32 expiration)"
            )
        );

    bytes32 public DOMAIN_SEPARATOR;

    uint256 private estGasPerTransfer;
    uint256 public firstUserTakeRate;

    struct Deposit {
        address user;
        address token;
        address vault;
        uint256 amount;
        uint32 nonce;
        uint32 expiration;
    }

    struct DepositTx {
        Deposit deposit;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    mapping(address => mapping(address => mapping(address => uint256)))
        public nonces;

    mapping(address => AggregatorV3Interface) public priceOracles;
    mapping(address => bool) public approvedTransactors;

    modifier onlyApprovedTransactors() {

        require(
            approvedTransactors[_msgSender()],
            "Not an approved transactor"
        );
        _;
    }

    function initialize(uint256 _chainId) public initializer {

        __Ownable_init();

        addApprovedTransactor(_msgSender());

        priceOracles[ // USDC
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        ] = AggregatorV3Interface(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4);
        priceOracles[ // DAI
            0x6B175474E89094C44Da98b954EedeAC495271d0F
        ] = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);

        estGasPerTransfer = 30000;
        firstUserTakeRate = 10000;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256("Wido"),
                keccak256("1"),
                _chainId,
                address(this)
            )
        );
    }

    function setEstGasPerTransfer(uint256 _newValue) external onlyOwner {

        estGasPerTransfer = _newValue;
    }

    function setFirstUserTakeRate(uint256 _newValue) external onlyOwner {

        require(_newValue >= 0 && _newValue <= 10000);
        firstUserTakeRate = _newValue;
    }

    function addApprovedTransactor(address _transactor) public onlyOwner {

        approvedTransactors[_transactor] = true;
    }

    function removeApprovedTransactor(address _transactor) public onlyOwner {

        delete approvedTransactors[_transactor];
    }

    function addPriceOracle(address _token, address _priceAggregator)
        external
        onlyOwner
    {

        priceOracles[_token] = AggregatorV3Interface(_priceAggregator);
    }

    function _getDepositDigest(Deposit memory deposit)
        private
        view
        returns (bytes32)
    {

        bytes32 data = keccak256(abi.encode(DEPOSIT_TYPEHASH, deposit));
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, data));
    }

    function _getLatestPrice(AggregatorV3Interface priceFeed)
        internal
        view
        returns (int256)
    {

        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function verifyDepositRequest(
        address signer,
        Deposit memory deposit,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bool) {

        address recoveredAddress = ecrecover(
            _getDepositDigest(deposit),
            v,
            r,
            s
        );
        require(
            recoveredAddress != address(0) && signer == recoveredAddress,
            "Invalid signature"
        );
        require(
            deposit.nonce == nonces[signer][deposit.token][deposit.vault]++,
            "Invalid nonce"
        );
        require(
            deposit.expiration == 0 || block.timestamp <= deposit.expiration,
            "Expired request"
        );
        require(deposit.amount > 0, "Deposit Amount should be greater than 0");
        return true;
    }

    function _approveToken(
        address token,
        address spender,
        uint256 amount
    ) internal {

        IERC20Upgradeable _token = IERC20Upgradeable(token);
        if (_token.allowance(address(this), spender) >= amount) return;
        else {
            _token.safeApprove(spender, type(uint256).max);
        }
    }

    function _pullTokens(DepositTx[] memory depositTx)
        internal
        returns (uint256)
    {

        uint256 totalDeposit = 0;
        for (uint256 i = 0; i < depositTx.length; i++) {
            Deposit memory deposit = depositTx[i].deposit;
            IERC20Upgradeable(deposit.token).safeTransferFrom(
                deposit.user,
                address(this),
                deposit.amount
            );
            totalDeposit = totalDeposit.add(deposit.amount);
        }
        return totalDeposit;
    }

    function verifyDepositPoolRequest(DepositTx[] memory depositTx) public {

        require(
            depositTx.length > 0,
            "DepositTx length should be greater than 0"
        );
        address prevVault = depositTx[0].deposit.vault;
        address prevToken = depositTx[0].deposit.token;
        for (uint256 i = 0; i < depositTx.length; i++) {
            Deposit memory deposit = depositTx[i].deposit;
            require(prevVault == depositTx[i].deposit.vault);
            require(prevToken == depositTx[i].deposit.token);
            require(
                verifyDepositRequest(
                    deposit.user,
                    deposit,
                    depositTx[i].v,
                    depositTx[i].r,
                    depositTx[i].s
                ) == true
            );
        }
    }

    function _distributeTokens(
        DepositTx[] memory depositTx,
        address vaultAddr,
        uint256 totalDeposit,
        uint256 receivedYTokens,
        uint256 feeYToken
    ) private {

        receivedYTokens = receivedYTokens.sub(feeYToken);

        for (uint256 i = 0; i < depositTx.length; i++) {
            Deposit memory deposit = depositTx[i].deposit;
            uint256 v = deposit.amount.mul(receivedYTokens).div(totalDeposit);
            if (i == 0) {
                uint256 feeDeducted = feeYToken.div(depositTx.length);
                v = v.add(
                    feeDeducted.sub(
                        feeDeducted.mul(firstUserTakeRate).div(10000)
                    )
                );
            }
            IERC20Upgradeable(vaultAddr).transfer(deposit.user, v);
        }
    }

    function depositPool(
        DepositTx[] memory depositTx,
        address payable ZapContract,
        bytes calldata zapCallData
    ) external onlyApprovedTransactors {

        uint256 initGas = gasleft();

        verifyDepositPoolRequest(depositTx);

        uint256 totalDeposit = _pullTokens(depositTx);

        address tokenAddr = depositTx[0].deposit.token;
        address vaultAddr = depositTx[0].deposit.vault;

        if (ZapContract != address(0)) {
            _approveToken(tokenAddr, ZapContract, totalDeposit);
        } else {
            _approveToken(tokenAddr, vaultAddr, totalDeposit);
        }

        uint256 initToken = IERC20Upgradeable(vaultAddr).balanceOf(
            address(this)
        );
        {
            if (ZapContract != address(0)) {
                (bool success, ) = ZapContract.call(zapCallData);
                require(success, "Zap In Failed");
            } else {
                Vault(vaultAddr).deposit(totalDeposit);
            }
        }
        uint256 newToken = IERC20Upgradeable(vaultAddr)
            .balanceOf(address(this))
            .sub(initToken);

        uint256 pETH = uint256(_getLatestPrice(priceOracles[tokenAddr]));
        uint256 afterDepositGas = gasleft();
        uint256 estTotalGas = initGas.sub(afterDepositGas).add(
            estGasPerTransfer.mul(depositTx.length)
        );
        uint256 estTxFees = estTotalGas.mul(block.basefee + 5e9).div(pETH).mul(
            10**uint256(IERC20MetadataUpgradeable(tokenAddr).decimals())
        );

        _distributeTokens(
            depositTx,
            vaultAddr,
            totalDeposit,
            newToken,
            estTxFees.mul(newToken).div(totalDeposit)
        );
    }

    function withdraw() external onlyOwner {

        address payable to = payable(_msgSender());
        to.transfer(address(this).balance);
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {

        IERC20Upgradeable(token).safeTransfer(_msgSender(), amount);
    }

    function withdrawTokenTo(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {

        IERC20Upgradeable(token).safeTransfer(to, amount);
    }
}