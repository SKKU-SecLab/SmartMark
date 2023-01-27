



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
}





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
}





abstract contract ContextMixin {
    function msgSender()
        internal
        view
        returns (address payable sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}






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
}





contract Initializable {

    bool inited = false;

    modifier initializer() {

        require(!inited, "already inited");
        _;
        inited = true;
    }
}






contract EIP712Base is Initializable {

    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 salt;
    }

    string constant public ERC712_VERSION = "1";

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(
        bytes(
            "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"
        )
    );
    bytes32 internal domainSeperator;

    function _initializeEIP712(
        string memory name
    )
        internal
        initializer
    {

        _setDomainSeperator(name);
    }

    function _setDomainSeperator(string memory name) internal {

        domainSeperator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(ERC712_VERSION)),
                address(this),
                bytes32(getChainId())
            )
        );
    }

    function getDomainSeperator() public view returns (bytes32) {

        return domainSeperator;
    }

    function getChainId() public view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function toTypedMessageHash(bytes32 messageHash)
        internal
        view
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19\x01", getDomainSeperator(), messageHash)
            );
    }
}





contract NativeMetaTransaction is EIP712Base {

    using SafeMath for uint256;
    bytes32 private constant META_TRANSACTION_TYPEHASH = keccak256(
        bytes(
            "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
        )
    );
    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );
    mapping(address => uint256) nonces;

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public payable returns (bytes memory) {

        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        require(
            verify(userAddress, metaTx, sigR, sigS, sigV),
            "Signer and signature do not match"
        );

        nonces[userAddress] = nonces[userAddress].add(1);

        emit MetaTransactionExecuted(
            userAddress,
            payable(msg.sender),
            functionSignature
        );

        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call not successful");

        return returnData;
    }

    function hashMetaTransaction(MetaTransaction memory metaTx)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    META_TRANSACTION_TYPEHASH,
                    metaTx.nonce,
                    metaTx.from,
                    keccak256(metaTx.functionSignature)
                )
            );
    }

    function getNonce(address user) public view returns (uint256 nonce) {

        nonce = nonces[user];
    }

    function verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {

        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");
        return
            signer ==
            ecrecover(
                toTypedMessageHash(hashMetaTransaction(metaTx)),
                sigV,
                sigR,
                sigS
            );
    }
}





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
}





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






abstract contract WithdrawalElement {
    using SafeERC20 for IERC20;
    using Address for address;

    event WithdrawToken(address token, address recipient, uint256 amount);
    event Withdraw(address recipient, uint256 amount);

    function _deliverFunds(
        address _recipient,
        uint256 _value,
        string memory _message
    ) internal {
        (bool sent, ) = payable(_recipient).call{value: _value}("");

        require(sent, _message);
    }

    function _deliverTokens(
        address _token,
        address _recipient,
        uint256 _value
    ) internal {
        IERC20(_token).safeTransfer(_recipient, _value);
    }

    function _withdraw(address _recipient, uint256 _amount) internal virtual {
        require(_recipient != address(0x0), "CryptoDrop Loto: address is zero");
        require(
            _amount <= address(this).balance,
            "CryptoDrop Loto: not enought BNB balance"
        );

        _afterWithdraw(_recipient, _amount);

        _deliverFunds(_recipient, _amount, "CryptoDrop Loto: Can't send BNB");
        emit Withdraw(_recipient, _amount);
    }

    function _afterWithdraw(address _recipient, uint256 _amount)
        internal
        virtual
    {}

    function _withdrawToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        require(_recipient != address(0x0), "CryptoDrop Loto: address is zero");
        require(
            _amount <= IERC20(_token).balanceOf(address(this)),
            "CryptoDrop Loto: not enought token balance"
        );

        IERC20(_token).safeTransfer(_recipient, _amount);

        _afterWithdrawToken(_token, _recipient, _amount);

        emit WithdrawToken(_token, _recipient, _amount);
    }

    function _afterWithdrawToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal virtual {}
}





interface ISNC {

    function mint(address _to, uint256 _tokenId) external;

}




pragma solidity ^0.8.9;




contract SNCSale is
    Ownable,
    Pausable,
    ReentrancyGuard,
    WithdrawalElement
{

    using SafeERC20 for IERC20;
    using Address for address;

    enum STATUS {
        QUED,
        ACTIVE,
        FINISHED,
        FAILED
    }

    struct Round {
        uint256 startTime;
        uint256 endTime;
        uint256 mintFee;
        uint256 supply;
        uint256 collected;
        uint256 maxTokensPerWallet;
        bool whitelistOnly;
    }

    Round[] public rounds;


    uint256 public lastRoundIndex;

    uint256 public tokenMinted;

    uint256 public requestsReceived;
      
    mapping(address => bool) public whitelistAddresses;

    mapping(uint256 => mapping(address => uint256)) public tokensPerWallet;


    mapping(uint256 => uint256[]) public requests;

    mapping(address => uint256[]) public userRequests;

    address public sncAddress;
    address public teamAddress;

    event UpdateSncAddress(address sncAddress);
    event UpdateTeamAddress(address teamAddress);
   
    event AddRound(
        uint256 startTime,
        uint256 endTime,
        uint256 mintFee,
        uint256 supply,
        uint256 maxTokensPerWallet,
        bool whitelistOnly
    );

    event ChangeRound(
        uint256 startTime,
        uint256 endTime,
        uint256 mintFee,
        uint256 supply,
        uint256 maxTokensPerWallet,
        bool whitelistOnly
    );

    event MintToken(
        uint256 roundId,
        address account,
        uint256 requestId,
        uint256 tokenId
    );

    event RequestReceived(
        address user, 
        uint256 requestId
    );
    
    receive() external payable {
        mint();
    }

    constructor(address _sncAddress, address _teamAddress) {

        sncAddress = _sncAddress;
        teamAddress = _teamAddress;
    }


    function addRound(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _mintFee,
        uint256 _supply,
        uint256 _maxTokensPerWallet,
        bool _whitelistOnly
    ) external onlyOwner {

        Round memory round = Round(
            _startTime,
            _endTime,
            _mintFee,
            _supply,
            0,
            _maxTokensPerWallet,
            _whitelistOnly
        );

        rounds.push(round);

        emit AddRound(
            _startTime,
            _endTime,
            _mintFee,
            _supply,
            _maxTokensPerWallet,
            _whitelistOnly
        );
    }

    function changeRound(
        uint256 _roundId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _mintFee,
        uint256 _supply,
        uint256 _maxTokensPerWallet,
        bool _whitelistOnly
    ) external onlyOwner {

        require(_roundId < rounds.length, "NFT Sale: round id invalid");

        Round storage round = rounds[_roundId];

        round.startTime = _startTime;
        round.endTime = _endTime;
        round.mintFee = _mintFee;
        round.supply = _supply;
        round.maxTokensPerWallet = _maxTokensPerWallet;
        round.whitelistOnly = _whitelistOnly;

        emit ChangeRound(
            _startTime,
            _endTime,
            _mintFee,
            _supply,
            _maxTokensPerWallet,
            _whitelistOnly
        );
    }

    function changeTimeForRound(
        uint256 _roundId,
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {

        require(_roundId < rounds.length, "NFT Sale: round id invalid");

        Round storage round = rounds[_roundId];

        round.startTime = _startTime;
        round.endTime = _endTime;

        emit ChangeRound(
            round.startTime,
            round.endTime,
            round.mintFee,
            round.supply,
            round.maxTokensPerWallet,
            round.whitelistOnly
        );
    }

    function changeMintFeeForRound(uint256 _roundId, uint256 _mintFee)
        external
        onlyOwner
    {

        require(_roundId < rounds.length, "NFT Sale: round id invalid");

        Round storage round = rounds[_roundId];

        round.mintFee = _mintFee;

        emit ChangeRound(
            round.startTime,
            round.endTime,
            round.mintFee,
            round.supply,
            round.maxTokensPerWallet,
            round.whitelistOnly
        );
    }

    function changeSupplyForRound(uint256 _roundId, uint256 _supply)
        external
        onlyOwner
    {

        require(_roundId < rounds.length, "NFT Sale: round id invalid");

        Round storage round = rounds[_roundId];

        round.supply = _supply;

        emit ChangeRound(
            round.startTime,
            round.endTime,
            round.mintFee,
            round.supply,
            round.maxTokensPerWallet,
            round.whitelistOnly
        );
    }

    function changeMaxTokensPerWalletForRound(
        uint256 _roundId,
        uint256 _maxTokensPerWallet
    ) external onlyOwner {

        require(_roundId < rounds.length, "NFT Sale: round id invalid");

        Round storage round = rounds[_roundId];

        round.maxTokensPerWallet = _maxTokensPerWallet;

        emit ChangeRound(
            round.startTime,
            round.endTime,
            round.mintFee,
            round.supply,
            round.maxTokensPerWallet,
            round.whitelistOnly
        );
    }

    function changeWhiteListStatusForRound(
        uint256 _roundId,
        bool _whitelistOnly
    ) external onlyOwner {

        require(_roundId < rounds.length, "NFT Sale: round id invalid");

        Round storage round = rounds[_roundId];

        round.whitelistOnly = _whitelistOnly;

        emit ChangeRound(
            round.startTime,
            round.endTime,
            round.mintFee,
            round.supply,
            round.maxTokensPerWallet,
            round.whitelistOnly
        );
    }

    function mint() public payable whenNotPaused nonReentrant {

        _calculateRound();

        require(
            _status(lastRoundIndex) == STATUS.ACTIVE,
            "SNCSale: sale is not started yet or ended"
        );

        Round storage round = rounds[lastRoundIndex];

        require(
            tokensPerWallet[lastRoundIndex][_msgSender()] <
                round.maxTokensPerWallet,
            "NFT Sale: max tokens per wallet reached"
        );

        
        uint256 requestId = requestsReceived;

        _mint(msg.sender, requestId, msg.value, lastRoundIndex);
        
        userRequests[_msgSender()].push(requestId);

        emit RequestReceived(_msgSender(), requestId);

        requestsReceived += 1;
    }

    function _mint(address _user, uint256 _requestId, uint256 _amount, uint256 _roundId) internal {


        Round storage round = rounds[_roundId];
    
        uint256 maxTokens = round.maxTokensPerWallet - tokensPerWallet[_roundId][_user];

        uint256 mintFee = round.mintFee;
        uint256 rest = _amount;

        require(
            _amount >= round.mintFee,
            "SNCSale: cannot enough ETH for mint"
        );

        for (uint8 i = 0; i < maxTokens; i++) {

            if (rest >= mintFee) {
                tokenMinted += 1;
                ISNC(sncAddress).mint(_user, tokenMinted);
                requests[_requestId].push(tokenMinted);
                rest = rest - mintFee;
                round.collected += 1;
                tokensPerWallet[lastRoundIndex][_msgSender()] += 1;
            }
        }

        if (rest > 0) {
             _deliverFunds(
                _user,
                rest,
                "SNCSale: failed transfer ETH to address"
            );
        }

        if (address(this).balance > 0) {
            _deliverFunds(
                teamAddress,
                address(this).balance,
                "SNCSale: failed transfer ETH to address"
            );
        }
    }

    function getUserRequestsLength(address _account)
        external
        view
        returns (uint256 length)
    {

        length = userRequests[_account].length;
    }
    
    function getTokenIds(address _account, uint256 _requestIndex) external view returns (uint256[] memory ids) {

        uint256 requestId = userRequests[_account][_requestIndex];

        ids = requests[requestId];
    }

    function _calculateRound() internal {

        Round memory round = rounds[lastRoundIndex];

        if (
            (block.timestamp > round.endTime) &&
            (lastRoundIndex + 1 < rounds.length)
        ) {
            lastRoundIndex += 1;
        }
    }

    function getLastRoundIndex()
        external
        view
        returns (uint256 _lastRoundIndex)
    {

        Round memory round = rounds[lastRoundIndex];

        _lastRoundIndex = lastRoundIndex;
        if (
            (block.timestamp > round.endTime) &&
            (lastRoundIndex + 1 < rounds.length)
        ) {
            _lastRoundIndex += 1;
        }
    }

    function getRoundSupply(uint256 _roundIndex)
        public
        view
        returns (uint256 supply)
    {

        if (_roundIndex == 0) {

            Round memory round = rounds[0];

            supply = round.supply;

        } else {

            Round memory round = rounds[_roundIndex];

            supply = round.supply;

            for (uint256 j = _roundIndex - 1; j > 0; j--) {
                Round memory prevRound = rounds[j];
                supply += prevRound.supply - prevRound.collected;
            }

            Round memory firstRound = rounds[0];

            supply += firstRound.supply - firstRound.collected;
        }
    }

   
    function status(uint256 _roundId) external view returns (STATUS) {

        return _status(_roundId);
    }

    function _status(uint256 _roundIndex) internal view returns (STATUS) {

        Round memory round = rounds[_roundIndex];

        if (
            (block.timestamp >= round.startTime) &&
            (block.timestamp <= round.endTime)
        ) {
            if (round.collected == getRoundSupply(_roundIndex)) {
                return STATUS.FINISHED;
            }

            if (!round.whitelistOnly) {
                return STATUS.ACTIVE; // ACTIVE - mint enabled
            } else {
                if (whitelistAddresses[_msgSender()]) {
                    return STATUS.ACTIVE;
                } else {
                    return STATUS.FAILED;
                }
            }
        }

        if (block.timestamp > round.endTime) {
            return STATUS.FINISHED;
        }

        return STATUS.QUED; // QUED - awaiting start time
    }

    function withdrawToken(address _token, address _recipient)
        external
        virtual
        whenPaused
        onlyOwner
    {

        uint256 amount = IERC20(_token).balanceOf(address(this));

        _withdrawToken(_token, _recipient, amount);
        _afterWithdrawToken(_token, _recipient, amount);
    }

    function withdrawSomeToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) public virtual whenPaused onlyOwner {

        _withdrawToken(_token, _recipient, _amount);
        _afterWithdrawToken(_token, _recipient, _amount);
    }

    function withdraw() external virtual whenPaused onlyOwner {

        _withdraw(_msgSender(), address(this).balance);
    }

    function withdrawSome(address _recipient, uint256 _amount)
        external
        virtual
        onlyOwner
    {

        _withdraw(_recipient, _amount);
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    function addToWhitelist(address[] memory _accounts) external onlyOwner {

        for (uint256 i = 0; i < _accounts.length; i++) {
            whitelistAddresses[_accounts[i]] = true;
        }
    }

    function removeFromWhitelist(address[] memory _accounts)
        external
        onlyOwner
    {

        for (uint256 i = 0; i < _accounts.length; i++) {
            whitelistAddresses[_accounts[i]] = false;
        }
    }

    function updateSncAddress(address _sncAddress) external onlyOwner {

        sncAddress = _sncAddress;
        emit UpdateSncAddress(_sncAddress);
    }

    function updateTeamAddress(address _teamAddress) external onlyOwner {

        teamAddress = _teamAddress;
        emit UpdateTeamAddress(_teamAddress);
    }
}