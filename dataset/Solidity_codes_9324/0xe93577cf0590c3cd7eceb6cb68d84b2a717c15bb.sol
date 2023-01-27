



pragma solidity 0.6.12;




library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function name() external view returns (string memory);


    function getOwner() external view returns (address);


    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x < y ? x : y;
    }
}


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract LuckyMoney is Context, Initializable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    struct Record {
        address collector;
        bytes32 seed;
    }

    struct LuckyMoneyData {
        address creator;
        uint256 expireTime;
        uint8 mode;
        address tokenAddr;
        uint256 tokenAmount;
        uint256 collectorCount;
        uint256 nonce;
        uint256 refundAmount;
        mapping (address => bool) collectStatus;
        mapping (uint256 => Record) records;
    }

    mapping (bytes32 => LuckyMoneyData) public luckyMoneys;

    struct RewardConfig {
        uint256 forSender;
        uint256 forReceiver;
    }

    address[] public rewards;
    mapping (address => RewardConfig) public rewardConfigs;
    mapping (address => uint256) public rewardBalances;

    event Disperse(
        address indexed _sender,
        address _tokenAddr,
        uint256 _tokenAmount,
        uint256 _fee
    );
    event Create(
        bytes32 indexed _id,
        address _tokenAddr,
        uint256 _tokenAmount,
        uint256 _expireTime,
        uint256 _collectorCount,
        uint256 _fee,
        uint256 _gasRefund
    );
    event Collect(
        address indexed _collector,
        address indexed _tokenAddress,
        uint8 _mode,
        uint256 _tokenAmount,
        bytes32 _id
    );
    event Distribute(
        bytes32 indexed _id,
        address indexed _caller,
        uint256 _remainCollector,
        uint256 _remainTokenAmount
    );
    event RewardCollect(
        address indexed _collector,
        address indexed _tokenAddr,
        uint8 _mode,
        uint256 amount);
    event FeeRateUpdate(uint16 feeRate);
    event FeeReceiverUpdate(address receiver);
    event OwnershipUpdate(address oldOwner, address newOwner);

    address public owner;
    uint256 public refundAmount = 1e15; // 0.001

    uint16 public feeRate = 10;
    uint16 public feeBase = 10000;
    address public feeReceiver;

    constructor() public {}

    function initialize(address _owner, address _feeReceiver) external initializer {

        owner = _owner;
        feeReceiver = _feeReceiver;

        feeRate = 10;
        feeBase = 10000;
        refundAmount = 1e15;

    }


    function disperseEther(address payable[] memory recipients, uint256[] memory values) external payable {

        address sender = msg.sender;
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            total += values[i];
        }
        uint256 fee = takeFeeAndValidate(sender, msg.value, address(0), total);
        giveReward(sender, 0);
        emit Disperse(sender, address(0), total, fee);

        for (uint256 i = 0; i < recipients.length; i++) {
            recipients[i].transfer(values[i]);
            emit Collect(recipients[i], address(0), 1, values[i], 0);
            giveReward(recipients[i], 1);
        }
    }

    function disperseToken(IERC20 token, address[] memory recipients, uint256[] memory values) external {

        address sender = msg.sender;
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            total += values[i];
        }
        uint256 fee = takeFeeAndValidate(sender, 0, address(token), total);
        giveReward(sender, 0);
        emit Disperse(sender, address(token), total, fee);

        for (uint256 i = 0; i < recipients.length; i++) {
            token.safeTransfer(recipients[i], values[i]);
            emit Collect(recipients[i], address(token), 1, values[i], 0);
            giveReward(recipients[i], 1);
        }
    }

    function create(
        uint256 expireTime,
        uint8 mode,
        address tokenAddr,
        uint256 tokenAmount,
        uint256 collectorCount)
        external payable returns (bytes32) {


        address sender = msg.sender;
        uint256 value = msg.value;

        require(value >= refundAmount, "not enough to refund later");
        uint256 fee = takeFeeAndValidate(sender, msg.value - refundAmount, tokenAddr, tokenAmount);

        bytes32 luckyMoneyId = getLuckyMoneyId(sender, block.timestamp, tokenAddr, tokenAmount, collectorCount);
        LuckyMoneyData storage l = luckyMoneys[luckyMoneyId];
        l.creator = sender;
        l.expireTime = expireTime;
        l.mode = mode;
        l.tokenAddr = tokenAddr;
        l.tokenAmount = tokenAmount;
        l.collectorCount = collectorCount;
        l.refundAmount = refundAmount;
        emit Create(luckyMoneyId, tokenAddr, tokenAmount, expireTime, collectorCount, fee, refundAmount);
        giveReward(sender, 0);

        return luckyMoneyId;
    }

    function submit(bytes32 luckyMoneyId, bytes memory signature) external {

        address sender = msg.sender;
        LuckyMoneyData storage l = luckyMoneys[luckyMoneyId];
        require(!hasCollected(luckyMoneyId, sender), "collected before");
        require(l.nonce < l.collectorCount, "collector count exceed");

        bytes32 hash = getEthSignedMessageHash(luckyMoneyId, sender);
        require(recoverSigner(hash, signature) == l.creator, "signature not signed by creator");
        l.records[l.nonce] = Record(sender, getBlockAsSeed(sender));
        l.nonce += 1;
        l.collectStatus[sender] = true;
    }

    function distribute(bytes32 luckyMoneyId) external {

        LuckyMoneyData storage l = luckyMoneys[luckyMoneyId];
        require(l.nonce == l.collectorCount || block.timestamp > l.expireTime, "luckyMoney not fully collected or expired");
        address payable[] memory recipients = new address payable[](l.nonce);
        uint256[] memory values = new uint256[](l.nonce);
        uint256 remainCollectorCount = l.collectorCount;
        uint256 remainTokenAmount = l.tokenAmount;

        if (l.mode == 1) {
            uint256 avgAmount = l.tokenAmount / l.collectorCount;
            remainCollectorCount = l.collectorCount - l.nonce;
            remainTokenAmount = l.tokenAmount - avgAmount * l.nonce;
            for (uint256 i = 0; i < l.nonce; i++) {
                recipients[i] = payable(l.records[i].collector);
                values[i] = avgAmount;
            }
        } else if (l.mode == 0) {

            bytes32 seed;
            for (uint256 i = 0; i < l.nonce; i++) {
                seed = seed ^ l.records[i].seed;
            }

            for (uint256 i = 0; i < l.nonce; i++) {
                recipients[i] = payable(l.records[i].collector);
                values[i] = calculateRandomAmount(seed, l.records[i].seed, remainTokenAmount, remainCollectorCount);
                remainCollectorCount -= 1;
                remainTokenAmount -= values[i];
            }
        }

        address tokenAddr = l.tokenAddr;
        address creator = l.creator;
        uint256 _refundAmount = l.refundAmount;
        delete luckyMoneys[luckyMoneyId];

        if (tokenAddr == address(0)) {
            for (uint256 i = 0; i < recipients.length; i++) {
                recipients[i].transfer(values[i]);
                emit Collect(recipients[i], tokenAddr, 2, values[i], luckyMoneyId);
                giveReward(recipients[i], 1);
            }
            payable(creator).transfer(remainTokenAmount);
        } else {

            IERC20 token = IERC20(tokenAddr);
            for (uint256 i = 0; i < recipients.length; i++) {
                token.safeTransfer(recipients[i], values[i]);
                emit Collect(recipients[i], tokenAddr, 2, values[i], luckyMoneyId);
                giveReward(recipients[i], 1);
            }
            token.transfer(creator, remainTokenAmount);
        }

        address sender = msg.sender;
        payable(sender).transfer(_refundAmount);
        emit Distribute(luckyMoneyId, sender, remainCollectorCount, remainTokenAmount);
    }


    function setOwner(address _owner) external {

        require(msg.sender == owner, "priviledged action");

        emit OwnershipUpdate(owner, _owner);
        owner = _owner;
    }

    function setRefundAmount(uint256 _amount) external {

        require(msg.sender == owner, "priviledged action");

        refundAmount = _amount;
    }

    function setFeeRate(uint16 _feeRate) external {

        require(msg.sender == owner, "priviledged action");
        require(_feeRate <= 10000, "fee rate greater than 100%");

        feeRate = _feeRate;
        emit FeeRateUpdate(_feeRate);
    }

    function setFeeReceiver(address _receiver) external {

        require(msg.sender == owner, "priviledged action");
        require(_receiver != address(0), "fee receiver can't be zero address");

        feeReceiver = _receiver;
        emit FeeReceiverUpdate(_receiver);
    }

    function setRewardTokens(address[] calldata rewardTokens) external {

        require(msg.sender == owner, "priviledged action");

        rewards = rewardTokens;
    }

    function configRewardRate(address rewardToken, uint256 forSender, uint256 forReceiver) external {

        require(msg.sender == owner, "priviledged action");

        rewardConfigs[rewardToken] = RewardConfig(forSender, forReceiver);
    }

    function addReward(address tokenAddr, uint256 amount) external {

        IERC20(tokenAddr).safeTransferFrom(msg.sender, address(this), amount);
        rewardBalances[tokenAddr] += amount;
    }

    function withdrawReward(address tokenAddr, uint256 amount) external {

        require(msg.sender == owner, "priviledged action");
        require(rewardBalances[tokenAddr] >= amount, "remain reward not enough to withdraw");

        IERC20(tokenAddr).safeTransfer(owner, amount);
        rewardBalances[tokenAddr] -= amount;
    }


    function hasCollected(bytes32 luckyMoneyId, address collector) public view returns (bool) {

        return luckyMoneys[luckyMoneyId].collectStatus[collector];
    }

    function expireTime(bytes32 luckyMoneyId) public view returns (uint256) {

        return luckyMoneys[luckyMoneyId].expireTime;
    }

    function feeOf(uint256 amount) public view returns (uint256) {

        return amount * feeRate / feeBase;
    }


    function takeFeeAndValidate(address sender, uint256 value, address tokenAddr, uint256 tokenAmount) internal returns (uint256 fee) {

        fee = feeOf(tokenAmount);
        if (tokenAddr == address(0)) {
            require(value == tokenAmount + fee, "incorrect amount of eth transferred");
            payable(feeReceiver).transfer(fee);
        } else {
            require(IERC20(tokenAddr).balanceOf(msg.sender) >= tokenAmount + fee, "incorrect amount of token transferred");
            IERC20(tokenAddr).safeTransferFrom(msg.sender, address(this), tokenAmount);
            IERC20(tokenAddr).safeTransferFrom(msg.sender, address(feeReceiver), fee);
        }
    }

    function giveReward(address target, uint8 mode) internal {

        for (uint256 i = 0; i < rewards.length; i++) {
            address token = rewards[i];
            RewardConfig storage config = rewardConfigs[token];
            uint256 amount = mode == 0 ? config.forSender : config.forReceiver;
            if (amount > 0 && rewardBalances[token] > amount) {
                rewardBalances[token] -= amount;
                IERC20(token).safeTransfer(target, amount);
                emit RewardCollect(target, token, mode, amount);
            }
        }
    }

    function getLuckyMoneyId(
        address _creator,
        uint256 _startTime,
        address _tokenAddr,
        uint256 _tokenAmount,
        uint256 _collectorCount
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(_creator, _startTime, _tokenAddr, _tokenAmount, _collectorCount));
    }

    function getBlockAsSeed(address addr) public view returns (bytes32) {

        return keccak256(abi.encode(addr, block.timestamp, block.difficulty, block.number));
    }

    function calculateRandomAmount(bytes32 rootSeed, bytes32 seed, uint256 remainAmount, uint remainCount) public pure returns (uint256) {

        uint256 amount = 0;
        if (remainCount == 1) {
            amount = remainAmount;
        } else if (remainCount == remainAmount) {
            amount = 1;
        } else if (remainCount < remainAmount) {
            amount = uint256(keccak256(abi.encode(rootSeed, seed))) % (remainAmount / remainCount * 2) + 1;
        }
        return amount;
    }

    function getMessageHash(
        bytes32 _luckyMoneyId,
        address _collector
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(_luckyMoneyId, _collector));
    }

  function getEthSignedMessageHash(
        bytes32 _luckyMoneyId,
        address _collector
  )
        public
        pure
        returns (bytes32)
    {

        bytes32 _messageHash = getMessageHash(_luckyMoneyId, _collector);
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        require(sig.length == 65, "invalid signature length");

        assembly {

            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function GetInitializeData(address _owner, address _feeReceiver) public pure returns(bytes memory){

        return abi.encodeWithSignature("initialize(address,address)", _owner,_feeReceiver);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}