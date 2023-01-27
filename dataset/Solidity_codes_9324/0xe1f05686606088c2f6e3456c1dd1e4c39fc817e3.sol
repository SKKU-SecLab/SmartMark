





pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.16;

contract LibEIP712 {

    struct EIP712Domain {
        string  name;
        string  version;
        address verifyingContract;
    }

    bytes32 constant internal EIP712DOMAIN_TYPEHASH = keccak256(abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "address verifyingContract",
        ")"
    ));

    bytes32 internal DOMAIN_SEPARATOR;

    constructor () public {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256("Opium Network"),
            keccak256("1"),
            address(this)
        ));
    }

    function hashEIP712Message(bytes32 hashStruct) internal view returns (bytes32 result) {

        bytes32 domainSeparator = DOMAIN_SEPARATOR;

        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header
            mstore(add(memPtr, 2), domainSeparator)                                            // EIP712 domain hash
            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct

            result := keccak256(memPtr, 66)
        }
        return result;
    }
}


pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


contract LibSwaprateOrder is LibEIP712 {

    struct SwaprateOrder {
        address syntheticId;
        address oracleId;
        address token;

        address makerAddress;
        address takerAddress;

        address senderAddress;

        address relayerAddress;
        address affiliateAddress;

        address feeTokenAddress;

        uint256 endTime;

        uint256 quantity;
        uint256 partialFill;

        uint256 param0;
        uint256 param1;
        uint256 param2;
        uint256 param3;
        uint256 param4;
        uint256 param5;
        uint256 param6;
        uint256 param7;
        uint256 param8;
        uint256 param9;

        uint256 relayerFee;
        uint256 affiliateFee;

        uint256 nonce;

        bytes signature;
    }

    bytes32 constant internal EIP712_ORDER_TYPEHASH = keccak256(abi.encodePacked(
        "Order(",
        "address syntheticId,",
        "address oracleId,",
        "address token,",

        "address makerAddress,",
        "address takerAddress,",

        "address senderAddress,",

        "address relayerAddress,",
        "address affiliateAddress,",

        "address feeTokenAddress,",

        "uint256 endTime,",

        "uint256 quantity,",
        "uint256 partialFill,",

        "uint256 param0,",
        "uint256 param1,",
        "uint256 param2,",
        "uint256 param3,",
        "uint256 param4,",
        "uint256 param5,",
        "uint256 param6,",
        "uint256 param7,",
        "uint256 param8,",
        "uint256 param9,",

        "uint256 relayerFee,",
        "uint256 affiliateFee,",

        "uint256 nonce",
        ")"
    ));

    function hashOrder(SwaprateOrder memory _order) public pure returns (bytes32 hash) {

        hash = keccak256(
            abi.encodePacked(
                abi.encodePacked(
                    EIP712_ORDER_TYPEHASH,
                    uint256(_order.syntheticId),
                    uint256(_order.oracleId),
                    uint256(_order.token),

                    uint256(_order.makerAddress),
                    uint256(_order.takerAddress),

                    uint256(_order.senderAddress),

                    uint256(_order.relayerAddress),
                    uint256(_order.affiliateAddress),

                    uint256(_order.feeTokenAddress)
                ),
                abi.encodePacked(
                    _order.endTime,
                    _order.quantity,
                    _order.partialFill
                ),
                abi.encodePacked(
                    _order.param0,
                    _order.param1,
                    _order.param2,
                    _order.param3,
                    _order.param4
                ),
                abi.encodePacked(
                    _order.param5,
                    _order.param6,
                    _order.param7,
                    _order.param8,
                    _order.param9
                ),
                abi.encodePacked(
                    _order.relayerFee,
                    _order.affiliateFee,

                    _order.nonce
                )
            )
        );
    }

    function verifySignature(bytes32 _hash, bytes memory _signature, address _address) internal view returns (bool) {

        require(_signature.length == 65, "ORDER:INVALID_SIGNATURE_LENGTH");

        bytes32 digest = hashEIP712Message(_hash);
        address recovered = retrieveAddress(digest, _signature);
        return _address == recovered;
    }

    function retrieveAddress(bytes32 _hash, bytes memory _signature) private pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(_hash, v, r, s);
        }
    }
}


pragma solidity 0.5.16;

contract Whitelisted {

    address[] internal whitelist;

    modifier onlyWhitelisted() {

        bool allowed = false;

        uint256 whitelistLength = whitelist.length;
        for (uint256 i = 0; i < whitelistLength; i++) {
            if (whitelist[i] == msg.sender) {
                allowed = true;
                break;
            }
        }

        require(allowed, "Only whitelisted allowed");
        _;
    }

    function getWhitelist() public view returns (address[] memory) {

        return whitelist;
    }
}


pragma solidity 0.5.16;


contract WhitelistedWithGovernance is Whitelisted {

    event GovernorSet(address governor);

    event Proposed(address[] whitelist);
    event Committed(address[] whitelist);

    uint256 public timeLockInterval;

    address public governor;

    uint256 public proposalTime;

    address[] public proposedWhitelist;

    modifier onlyGovernor() {

        require(msg.sender == governor, "Only governor allowed");
        _;
    }

    constructor(uint256 _timeLockInterval, address _governor) public {
        timeLockInterval = _timeLockInterval;
        governor = _governor;
        emit GovernorSet(governor);
    }

    function proposeWhitelist(address[] memory _whitelist) public onlyGovernor {

        require(_whitelist.length != 0, "Can't be empty");

        if (whitelist.length == 0) {
            whitelist = _whitelist;
            emit Committed(_whitelist);

        } else {
            proposalTime = now;
            proposedWhitelist = _whitelist;
            emit Proposed(_whitelist);
        }
    }

    function commitWhitelist() public onlyGovernor {

        require(proposalTime != 0, "Didn't proposed yet");

        require((proposalTime + timeLockInterval) < now, "Can't commit yet");
        
        whitelist = proposedWhitelist;
        emit Committed(whitelist);

        proposalTime = 0;
    }

    function setGovernor(address _governor) public onlyGovernor {

        require(_governor != address(0), "Can't set zero address");
        governor = _governor;
        emit GovernorSet(governor);
    }
}


pragma solidity 0.5.16;


contract WhitelistedWithGovernanceAndChangableTimelock is WhitelistedWithGovernance {

    event Proposed(uint256 timelock);
    event Committed(uint256 timelock);

    uint256 public timeLockProposalTime;
    uint256 public proposedTimeLock;

    function proposeTimelock(uint256 _timelock) public onlyGovernor {

        timeLockProposalTime = now;
        proposedTimeLock = _timelock;
        emit Proposed(_timelock);
    }

    function commitTimelock() public onlyGovernor {

        require(timeLockProposalTime != 0, "Didn't proposed yet");
        require((timeLockProposalTime + timeLockInterval) < now, "Can't commit yet");
        
        timeLockInterval = proposedTimeLock;
        emit Committed(proposedTimeLock);

        timeLockProposalTime = 0;
    }
}


pragma solidity ^0.5.4;


interface IAggregator {

    function execute(bytes calldata _command, LibSwaprateOrder.SwaprateOrder calldata _order) external returns (bool);

}


pragma solidity ^0.5.4;

contract ICToken {

    address public underlying;
    function mint(uint256 mintAmount) external returns (uint);

    function exchangeRateCurrent() external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

}

contract IERC20Detailed is IERC20 {

    uint public decimals;
}

contract BytesToTypes {

    function bytesToUint256(bytes memory _input, uint _offst) internal pure returns (uint256 _output) {

        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToUint8(bytes memory  _input, uint _offst) internal pure returns (uint8 _output) {

        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToAddress(bytes memory  _input, uint _offst) internal pure returns (address _output) {

        assembly {
            _output := mload(add(_input, _offst))
        }
    }
}

contract CompoundSupplyAggregator is BytesToTypes, WhitelistedWithGovernanceAndChangableTimelock, Ownable, IAggregator, LibSwaprateOrder {

    using SafeMath for uint256;
    using SafeERC20 for IERC20Detailed;

    event Deposit(uint256 id, address sender, address cToken, uint256 cTokenAmount);
    event EmergencyWithdraw(uint256 id, address sender, address cToken, uint256 cTokenAmount);
    event Withdraw(uint256 id, address sender, address cToken, uint256 cTokenAmount);

    uint256 constant public BASE = 1e18;

    address public sendHelper;

    mapping(address => mapping(uint256 => mapping(address => uint256))) public balances;

    mapping(address => uint256) public nonces;

    modifier onlySendHelper() {

        require(msg.sender == sendHelper, "ONLY_SEND_HELPER");
        _;
    }

    uint256 public constant WHITELIST_TIMELOCK = 1 hours;

    constructor(address _sendHelper) public WhitelistedWithGovernance(WHITELIST_TIMELOCK, msg.sender) {
        sendHelper = _sendHelper;
    }

    function execute(bytes calldata _command, SwaprateOrder calldata _order) external onlySendHelper returns (bool) {

        require(_command.length == 21, "NOT_VALID_COMMAND");
        require(_order.partialFill == 0, "ONLY_ALL_OR_NOTHING");

        uint8 command = bytesToUint8(_command, 1);

        ICToken cToken = ICToken(bytesToAddress(_command, 21));

        _verifyCToken(address(cToken));

        IERC20Detailed token = IERC20Detailed(_order.token);

        uint256 tokenBase = 10 ** token.decimals();
        uint256 nominal = _order.quantity.mul(tokenBase); // TODO: Implement multiplier later when it's done on BE

        if (command != uint8(1)) {
            revert("UNKNOWN_COMMAND_CODE");
        }

        require(token.allowance(_order.makerAddress, address(this)) >= nominal, "NOT_APPROVED_AMOUNT");
        token.safeTransferFrom(_order.makerAddress, address(this), nominal);
        token.safeApprove(address(cToken), nominal);

        uint256 error = cToken.mint(nominal);
        if (error != 0) {
            return false;
        }

        uint256 id = ++nonces[_order.makerAddress];

        uint256 cTokens = nominal.mul(BASE).div(cToken.exchangeRateCurrent());
        balances[_order.makerAddress][id][address(cToken)] = balances[_order.makerAddress][id][address(cToken)].add(cTokens);

        emit Deposit(id, _order.makerAddress, address(cToken), cTokens);
        return true;
    }

    function withdraw(uint256 _id, address _sender, ICToken _cToken, uint256 _cTokenAmount) external onlyOwner {

        require(balances[_sender][_id][address(_cToken)] >= _cTokenAmount, "NOT_ENOUGH_CTOKENS");

        uint256 error = _cToken.redeem(_cTokenAmount);
        if (error != 0) {
            revert("Error while redeem");
        }

        uint256 redeemedAmount = _cTokenAmount.mul(_cToken.exchangeRateCurrent()).div(BASE);

        IERC20Detailed(_cToken.underlying()).safeTransfer(_sender, redeemedAmount);

        balances[_sender][_id][address(_cToken)] = balances[_sender][_id][address(_cToken)].sub(_cTokenAmount);

        emit Withdraw(_id, _sender, address(_cToken), _cTokenAmount);
    }

    function emergencyWithdraw(uint256 _id, address _cToken, uint256 _amount) external {

        require(balances[msg.sender][_id][_cToken] >= _amount, "NOT_ENOUGH_CTOKENS");

        balances[msg.sender][_id][_cToken] = balances[msg.sender][_id][_cToken].sub(_amount);
        IERC20Detailed(_cToken).safeTransfer(msg.sender, _amount);

        emit EmergencyWithdraw(_id, msg.sender, _cToken, _amount);
    }

    function setSendHelper(address _sendHelper) external onlyOwner {

        sendHelper = _sendHelper;
    }

    function _verifyCToken(address _cToken) view private {

        bool valid = false;

        uint256 whitelistLength = whitelist.length;
        for (uint256 i = 0; i < whitelistLength; i++) {
            if (whitelist[i] == _cToken) {
                valid = true;
                break;
            }
        }

        require(valid, "Only whitelisted cTokens are valid");
    }
}