
pragma solidity 0.6.12;

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

abstract contract Ownable {
  address s_owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    s_owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == s_owner, "Ownable: not owner");
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner virtual {
    require(newOwner != address(0), "Ownable: 0 cannot be owner");
    emit OwnershipTransferred(s_owner, newOwner);
    s_owner = newOwner;
  }

}

abstract contract Claimable is Ownable {
  address s_pendingOwner;

  modifier onlyPendingOwner() {
    require(msg.sender == s_pendingOwner, "Claimable: not pending owner");
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner override {
    s_pendingOwner = newOwner;
  }

  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(s_owner, s_pendingOwner);
    s_owner = s_pendingOwner;
    s_pendingOwner = address(0);
  }
}

struct Account {
    uint256 nonce;  
    uint256 balance;
    uint256 issueBlock;
    uint256 pending;
    uint256 withdrawal;
    uint256 releaseBlock;
    bytes32 secretHash;
}

library AccountUtils {

    using SafeMath for uint256;

    function initNonce(Account storage self) internal {

        if (self.nonce == 0) {
            self.nonce =
                uint256(1) << 240 |
                uint256(blockhash(block.number-1)) << 80 >> 32 |
                now;
        }
    }

    function updateNonce(Account storage self) internal {

        uint256 count = self.nonce >> 240;
        uint256 nonce = 
            ++count << 240 |
            uint256(blockhash(block.number-1)) << 80 >> 32 |
            now;
        require(uint16(self.nonce) != uint16(nonce), "Pool: too soon");
        self.nonce = nonce;
    }
    
    function acceptPending(Account storage self, uint256 value) internal {

        uint256 pending = self.pending;
        require(pending > 0, "Pool: no pending tokens");
        require(pending == value, "Pool: value must equal issued tokens");
        self.secretHash = 0;
        self.pending = 0;
        self.balance = self.balance.add(pending);
    }

    function take(Account storage self, uint256 value) internal {

        self.balance = self.balance.add(value);
    }

    function payment(Account storage self, uint256 value) internal {

        self.balance = self.balance.sub(value);
    }

    function deposit(Account storage self, uint256 value) internal {

        self.balance = self.balance.add(value);
    }

    function withdraw(Account storage self, uint256 value) internal {

        self.withdrawal = 0;
        self.releaseBlock = 0;
        self.balance = self.balance.sub(value);
    }
}

struct Supply {
    uint256 total;
    uint256 minimum;
    uint256 pending;
}

library SupplyUtils {

    using SafeMath for uint256;


    modifier checkAvailability(Supply storage self) {

        _;
        require(self.total >= self.minimum.add(self.pending), "Pool: not enough available tokens");
    }


    function updatePending(Supply storage self, uint256 from, uint256 to) internal checkAvailability(self) { 

        self.pending = self.pending.add(to).sub(from, "Pool: not enough available tokens");       
    }

    function acceptPending(Supply storage self, uint256 value) internal {

        self.pending = self.pending.sub(value, "Pool: not enough pending");
        self.minimum = self.minimum.add(value);
    }

    function give(Supply storage self, uint256 value) internal checkAvailability(self) {

        self.minimum = self.minimum.add(value);
    }

    function payment(Supply storage self, uint256 value) internal /*safeReduceMinimum(self, value)*/ {

        self.minimum = self.minimum.sub(value); // this line should be remove if using safeReduceMinimum modifier
    }

    function deposit(Supply storage self, uint256 value) internal {

        self.minimum = self.minimum.add(value);
        self.total = self.total.add(value);
    }

    function widthdraw(Supply storage self, uint256 value) internal /*safeReduceMinimum(self, value)*/ checkAvailability(self) {

        self.minimum = self.minimum.sub(value); // this line should be remove if using safeReduceMinimum modifier
        self.total = self.total.sub(value);
    }

    function decrease(Supply storage self, uint256 value) internal checkAvailability(self) {

        self.total = self.total.sub(value, "Pool: value larger than total");
    }

    function update(Supply storage self, uint256 value) internal checkAvailability(self) {

        self.total = value;
    }

    function available(Supply storage self) internal view returns (uint256) {

        return self.total.sub(self.minimum.add(self.pending));
    }
}

struct Limits {
    uint256 releaseDelay;
    uint256 maxTokensPerIssue;
    uint256 maxTokensPerBlock;
}

struct Entities {
    address manager;
    address token;
    address wallet;
}

contract Pool is Claimable {

    using AccountUtils for Account;
    using SupplyUtils for Supply;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 private s_uid;
    Supply private s_supply;
    Limits private s_limits;
    Entities private s_entities;
    uint256 private s_lastIssuedBlock;
    uint256 private s_totalIssuedInBlock;

    mapping(address => Account) private s_accounts;

    uint8 public constant VERSION_NUMBER = 0x1;
    uint256 public constant MAX_RELEASE_DELAY = 11_520; // about 48h
    string public constant NAME = "Kirobo Pool";
    string public constant VERSION = "1";
    bytes32 public DOMAIN_SEPARATOR;
    bytes public DOMAIN_SEPARATOR_ASCII;
    uint256 public CHAIN_ID;

    bytes32 public constant ACCEPT_TYPEHASH = 0xf728cfc064674dacd2ced2a03acd588dfd299d5e4716726c6d5ec364d16406eb;

    bytes32 public constant PAYMENT_TYPEHASH = 0x841d82f71fa4558203bb763733f6b3326ecaf324143e12fb9b6a9ed958fc4ee0;

    bytes32 public constant BUY_TYPEHASH = 0x866880cdfbc2380b3f4581d70707601f3d190bc04c3ee9cfcdac070a5f87b758;

    event TokensIssued(address indexed account, uint256 value, bytes32 secretHash);
    event TokensAccepted(address indexed account, bool directCall);
    event TokensDistributed(address indexed account, uint256 value);
    event Payment(address indexed account, uint256 value);
    event Deposit(address indexed account, uint256 value);
    event WithdrawalRequested(address indexed account, uint256 value);
    event WithdrawalCanceled(address indexed account);
    event Withdrawal(address indexed account, uint256 value);
    event EtherTransfered(address indexed to, uint256 value);
    event TokensTransfered(address indexed to, uint256 value);
    event ManagerChanged(address from, address to);
    event WalletChanged(address from, address to);
    event ReleaseDelayChanged(uint256 from, uint256 to);
    event MaxTokensPerIssueChanged(uint256 from, uint256 to);
    event MaxTokensPerBlockChanged(uint256 from, uint256 to);

    modifier onlyAdmins() {

        require(msg.sender == s_owner || msg.sender == s_entities.manager, "Pool: not owner or manager");
        _;
    }

    constructor(address tokenContract) public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
     
        s_entities.token = tokenContract;
        s_limits = Limits({releaseDelay: 240, maxTokensPerIssue: 10*1000*(10**18), maxTokensPerBlock: 50*1000*(10**18)});
        s_uid = bytes32(
          uint256(VERSION_NUMBER) << 248 |
          uint256(blockhash(block.number-1)) << 192 >> 16 |
          uint256(address(this))
        );

        CHAIN_ID = chainId;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"),
                keccak256(bytes(NAME)),
                keccak256(bytes(VERSION)),
                chainId,
                address(this),
                s_uid
            )
        );
        DOMAIN_SEPARATOR_ASCII = _hashToAscii(
            DOMAIN_SEPARATOR
        );
    }

    receive () external payable {
        require(false, "Pool: not accepting ether");
    }




    function setManager(address manager) external onlyOwner() {

        require(manager != address(this), "Pool: self cannot be mananger");
        require(manager != s_entities.token, "Pool: token cannot be manager");
        emit ManagerChanged(s_entities.manager, manager);
        s_entities.manager = manager;
    }

    function setWallet(address wallet) external onlyOwner() {

        require(wallet != address(this), "Pool: self cannot be wallet");
        require(wallet != s_entities.token, "Pool: token cannot be wallt");
        emit WalletChanged(s_entities.wallet, wallet);
        s_entities.wallet = wallet;
    }

    function setReleaseDelay(uint256 blocks) external onlyOwner() {

        require(blocks <= MAX_RELEASE_DELAY, "Pool: exeeds max release delay");
        emit ReleaseDelayChanged(s_limits.releaseDelay, blocks);
        s_limits.releaseDelay = blocks;
    }

    function setMaxTokensPerIssue(uint256 tokens) external onlyOwner() {

        emit MaxTokensPerIssueChanged(s_limits.maxTokensPerIssue, tokens);
        s_limits.maxTokensPerIssue = tokens;
    }

    function setMaxTokensPerBlock(uint256 tokens) external onlyOwner() {

        emit MaxTokensPerBlockChanged(s_limits.maxTokensPerBlock, tokens);
        s_limits.maxTokensPerBlock = tokens;
    }

    function resyncTotalSupply(uint256 value) external onlyAdmins() returns (uint256) {

        uint256 tokens = ownedTokens();
        require(tokens >= s_supply.total, "Pool: internal error, check contract logic"); 
        require(value >= s_supply.total, "Pool: only transferTokens can decrease total supply");
        require(value <= tokens, "Pool: not enough tokens");
        s_supply.update(value);
    }




    function transferEther(uint256 value) external onlyAdmins() {

        require(s_entities.wallet != address(0), "Pool: wallet not set");
        payable(s_entities.wallet).transfer(value);
        emit EtherTransfered(s_entities.wallet, value);
    }

    function transferTokens(uint256 value) external onlyAdmins() {

        require(s_entities.wallet != address(0), "Pool: wallet not set");
        s_supply.decrease(value);
        IERC20(s_entities.token).safeTransfer(s_entities.wallet, value);
        emit TokensTransfered(s_entities.wallet, value);
    }

    function distributeTokens(address to, uint256 value) external onlyAdmins() {

        _distributeTokens(to, value);
    }
    
    function _distributeTokens(address to, uint256 value) private {

        require(value <= s_limits.maxTokensPerIssue, "Pool: exeeds max tokens per call");
        require(s_accounts[to].issueBlock < block.number, "Pool: too soon");
        _validateTokensPerBlock(value);
        Account storage sp_account = s_accounts[to];
        sp_account.issueBlock = block.number;
        sp_account.initNonce();
        s_supply.give(value);
        sp_account.take(value);
        emit TokensDistributed(to, value);
    }

    function issueTokens(address to, uint256 value, bytes32 secretHash) external onlyAdmins() {

        require(value <= s_limits.maxTokensPerIssue, "Pool: exeeds max tokens per call");
        _validateTokensPerBlock(value);
        Account storage sp_account = s_accounts[to];
        uint256 prevPending = sp_account.pending;
        sp_account.initNonce();
        sp_account.secretHash = secretHash;
        sp_account.pending = value;
        sp_account.issueBlock = block.number;
        s_supply.updatePending(prevPending, value);
        emit TokensIssued(to, value, secretHash);
    }

    function executeAcceptTokens(
        address recipient,
        uint256 value,
        bytes calldata c_secret,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool eip712
    )
        external 
        onlyAdmins()
    {

        require(s_accounts[recipient].secretHash == keccak256(c_secret), "Pool: wrong secret");
        require(
            validateAcceptTokens(recipient, value, keccak256(c_secret), v, r ,s, eip712),
            "Pool: wrong signature or data"
        );
        _acceptTokens(recipient, value);
        emit TokensAccepted(recipient, false);
    }

    function executePayment(address from, uint256 value, uint8 v, bytes32 r, bytes32 s, bool eip712)
        external
        onlyAdmins()
    {

        require(validatePayment(from, value, v, r, s, eip712), "Pool: wrong signature or data");
        Account storage sp_account = s_accounts[from];
        sp_account.updateNonce();
        sp_account.payment(value);
        s_supply.payment(value);
        emit Payment(from, value);
    }
  



    function executeBuyTokens(uint256 kiro, uint256 expires, uint8 v, bytes32 r, bytes32 s, bool eip712) 
        external
        payable
    {

        require(validateBuyTokens(msg.sender, msg.value, kiro, expires, v, r, s, eip712), "Pool: wrong signature or data");
        require(now <= expires, "Pool: too late");
        _distributeTokens(msg.sender, kiro);
    }

    function acceptTokens(uint256 value, bytes calldata c_secret) external {

        require(s_accounts[msg.sender].secretHash == keccak256(c_secret), "Pool: wrong secret");
        _acceptTokens(msg.sender, value);
        emit TokensAccepted(msg.sender, true);
    }

    function depositTokens(uint256 value) external {

        Account storage sp_account = s_accounts[msg.sender]; 
        sp_account.initNonce();
        sp_account.deposit(value);
        s_supply.deposit(value);
        IERC20(s_entities.token).safeTransferFrom(msg.sender, address(this), value);
        emit Deposit(msg.sender, value);
    }

    function requestWithdrawal(uint256 value) external {

        require(s_accounts[msg.sender].balance >= value, "Pool: not enough tokens");
        require(value > 0, "Pool: withdrawal value must be larger then 0");
        s_accounts[msg.sender].withdrawal = value;
        s_accounts[msg.sender].releaseBlock = block.number + s_limits.releaseDelay;
        emit WithdrawalRequested(msg.sender, value);
    }

    function cancelWithdrawal() external {

        s_accounts[msg.sender].withdrawal = 0;
        s_accounts[msg.sender].releaseBlock = 0;
        emit WithdrawalCanceled(msg.sender);
    }

    function withdrawTokens() external {

        Account storage sp_account = s_accounts[msg.sender];   
        require(sp_account.withdrawal > 0, "Pool: no withdraw request");
        require(sp_account.releaseBlock <= block.number, "Pool: too soon");
        uint256 value = sp_account.withdrawal > sp_account.balance ? sp_account.balance : sp_account.withdrawal;
        sp_account.withdraw(value);
        s_supply.widthdraw(value);
        IERC20(s_entities.token).safeTransfer(msg.sender, value);
        emit Withdrawal(msg.sender, value);
    }

    function account(address addr) external view
        returns (
            uint256 nonce,  
            uint256 balance,
            uint256 issueBlock,
            uint256 pending,
            uint256 withdrawal,
            uint256 releaseBlock,
            bytes32 secretHash,
            uint256 externalBalance
        ) 
    {

        Account storage sp_account = s_accounts[addr];
        uint256 extBalance = IERC20(s_entities.token).balanceOf(addr);
        return (
            sp_account.nonce,
            sp_account.balance,
            sp_account.issueBlock,
            sp_account.pending,
            sp_account.withdrawal,
            sp_account.releaseBlock,
            sp_account.secretHash,
            extBalance
        );
    }

    function entities() view external
        returns (
            address manager,
            address token,
            address wallet
        )
    {

        return (
            s_entities.manager,
            s_entities.token,
            s_entities.wallet
        );
    }

    function limits() external view
        returns (
            uint256 releaseDelay, 
            uint256 maxTokensPerIssue,
            uint256 maxTokensPerBlock
        )
    {

        return (
            s_limits.releaseDelay,
            s_limits.maxTokensPerIssue,
            s_limits.maxTokensPerBlock
        );
    }

    function supply() view external 
        returns (
            uint256 total,
            uint256 minimum,
            uint256 pending,
            uint256 available
        ) 
    {

        return (
            s_supply.total,
            s_supply.minimum,
            s_supply.pending,
            s_supply.available()
        );
    }

    function uid() view external returns (bytes32) {

        return s_uid;
    }

    function totalSupply() view external returns (uint256) {

        return s_supply.total;
    }

    function availableSupply() view external returns (uint256) {

        return s_supply.available();
    }




    function generateBuyTokensMessage(address recipient, uint256 eth, uint256 kiro, uint256 expires)
        public view
        returns (bytes memory)
    {

        Account storage sp_account = s_accounts[recipient]; 
    
        return abi.encode(
            BUY_TYPEHASH,
            recipient,
            eth,
            kiro,
            expires,
            sp_account.issueBlock
        );
    }

    function generateAcceptTokensMessage(address recipient, uint256 value, bytes32 secretHash)
        public view 
        returns (bytes memory)
    {

        require(s_accounts[recipient].secretHash == secretHash, "Pool: wrong secret hash");
        require(s_accounts[recipient].pending == value, "Pool: value must equal pending(issued tokens)");
            
        return abi.encode(
            ACCEPT_TYPEHASH,
            recipient,
            value,
            secretHash
        );
    }

    function generatePaymentMessage(address from, uint256 value)
        public view
        returns (bytes memory)
    {

        Account storage sp_account = s_accounts[from]; 
        require(sp_account.balance >= value, "Pool: account balnace too low");
        
        return abi.encode(
            PAYMENT_TYPEHASH,
            from,
            value,
            sp_account.nonce
        );
    }

    function validateBuyTokens(
        address from,
        uint256 eth,
        uint256 kiro,
        uint256 expires,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool eip712
    )
        public view 
        returns (bool)
    {

        bytes32 message = _messageToRecover(
            keccak256(generateBuyTokensMessage(from, eth, kiro, expires)),
            eip712
        );
        address addr = ecrecover(message, v, r, s);
        return addr == s_entities.manager;      
    }

    function validateAcceptTokens(
        address recipient,
        uint256 value,
        bytes32 secretHash,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool eip712
    )
        public view 
        returns (bool)
    {

        bytes32 message = _messageToRecover(
            keccak256(generateAcceptTokensMessage(recipient, value, secretHash)),
            eip712
        );
        address addr = ecrecover(message, v, r, s);
        return addr == recipient;
    }

    function validatePayment(address from, uint256 value, uint8 v, bytes32 r, bytes32 s, bool eip712)
        public view 
        returns (bool)
    {

        bytes32 message = _messageToRecover(
            keccak256(generatePaymentMessage(from, value)),
            eip712
        );
        address addr = ecrecover(message, v, r, s);
        return addr == from;      
    }

    function ownedTokens() view public returns (uint256) {

        return IERC20(s_entities.token).balanceOf(address(this));
    }




    function _validateTokensPerBlock(uint256 value) private {

        if (s_lastIssuedBlock < block.number) {
            s_lastIssuedBlock = block.number;
            s_totalIssuedInBlock = value;
        } else {
            s_totalIssuedInBlock.add(value);
        }
        require(s_totalIssuedInBlock <= s_limits.maxTokensPerBlock, "Pool: exeeds max tokens per block");
    }

    function _acceptTokens(address recipient, uint256 value) private {

        require(s_accounts[recipient].issueBlock < block.number, "Pool: too soon");
        s_accounts[recipient].acceptPending(value);
        s_supply.acceptPending(value);
    }

    function _messageToRecover(bytes32 hashedUnsignedMessage, bool eip712)
        private view 
        returns (bytes32)
    {

        if (eip712) {
            return keccak256(abi.encodePacked
            (
                "\x19\x01",
                DOMAIN_SEPARATOR,
                hashedUnsignedMessage
            ));
        }
        return keccak256(abi.encodePacked
        (
            "\x19Ethereum Signed Message:\n128",
            DOMAIN_SEPARATOR_ASCII,
            _hashToAscii(hashedUnsignedMessage)
        ));
    }

    function _hashToAscii(bytes32 hash) private pure returns (bytes memory) {

        bytes memory s = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            byte  b = hash[i];
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = _char(hi);
            s[2*i+1] = _char(lo);
        }
        return s;
    }

    function _char(byte b) private pure returns (byte c) {

        if (b < byte(uint8(10))) {
            return byte(uint8(b) + 0x30);
        } else {
            return byte(uint8(b) + 0x57);
        }
    }

}