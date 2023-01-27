

pragma solidity 0.6.12;

library BoringMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function to128(uint256 a) internal pure returns (uint128 c) {

        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}

library BoringMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

pragma solidity 0.6.12;


contract Domain {

    bytes32 private constant DOMAIN_SEPARATOR_SIGNATURE_HASH = keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");
    string private constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA = "\x19\x01";

    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint256 private immutable DOMAIN_SEPARATOR_CHAIN_ID;    

    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {

        return keccak256(
            abi.encode(
                DOMAIN_SEPARATOR_SIGNATURE_HASH,
                chainId,
                address(this)
            )
        );
    }

    constructor() public {
        uint256 chainId; assembly {chainId := chainid()}
        _DOMAIN_SEPARATOR = _calculateDomainSeparator(DOMAIN_SEPARATOR_CHAIN_ID = chainId);
    }

    function _domainSeparator() internal view returns (bytes32) {

        uint256 chainId; assembly {chainId := chainid()}
        return chainId == DOMAIN_SEPARATOR_CHAIN_ID ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(chainId);
    }

    function _getDigest(bytes32 dataHash) internal view returns (bytes32 digest) {

        digest =
            keccak256(
                abi.encodePacked(
                    EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA,
                    _domainSeparator(),
                    dataHash
                )
            );
    }
}

pragma solidity ^0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address to, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;


contract DictatorDAO is IERC20, Domain {

    using BoringMath for uint256;
    using BoringMath128 for uint128;

    string public symbol;
    string public name;
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    IERC20 public immutable token;
    address public operator;

    mapping(address => address) public userVote;
    mapping(address => uint256) public votes;

    constructor(
        string memory sharesSymbol,
        string memory sharesName,
        IERC20 token_,
        address initialOperator
    ) public {
        symbol = sharesSymbol;
        name = sharesName;
        token = token_;
        operator = initialOperator;
    }

    struct User {
        uint128 balance;
        uint128 lockedUntil;
    }

    mapping(address => User) public users;
    mapping(address => mapping(address => uint256)) public override allowance;
    mapping(address => uint256) public nonces;

    function balanceOf(address user)
        public
        view
        override
        returns (uint256 balance)
    {

        return users[user].balance;
    }

    function _transfer(
        address from,
        address to,
        uint256 shares
    ) internal {

        User memory fromUser = users[from];
        require(block.timestamp >= fromUser.lockedUntil, "Locked");
        if (shares != 0) {
            require(fromUser.balance >= shares, "Low balance");
            if (from != to) {
                require(to != address(0), "Zero address"); // Moved down so other failed calls save some gas
                User memory toUser = users[to];

                address userVoteTo = userVote[to];
                address userVoteFrom = userVote[from];

                users[from].balance = fromUser.balance - shares.to128(); // Underflow is checked
                users[to].balance = toUser.balance + shares.to128(); // Can't overflow because totalSupply would be greater than 2^256-1

                votes[userVoteFrom] -= shares;

                votes[userVoteTo] += shares;
            }
        }
        emit Transfer(from, to, shares);
    }

    function _useAllowance(address from, uint256 shares) internal {

        if (msg.sender == from) {
            return;
        }
        uint256 spenderAllowance = allowance[from][msg.sender];
        if (spenderAllowance != type(uint256).max) {
            require(spenderAllowance >= shares, "Low allowance");
            allowance[from][msg.sender] = spenderAllowance - shares; // Underflow is checked
        }
    }

    function transfer(address to, uint256 shares)
        external
        override
        returns (bool)
    {

        _transfer(msg.sender, to, shares);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 shares
    ) external override returns (bool) {

        _useAllowance(from, shares);
        _transfer(from, to, shares);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {

        return _domainSeparator();
    }

    bytes32 private constant PERMIT_SIGNATURE_HASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    function permit(
        address owner_,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {

        require(owner_ != address(0), "Zero owner");
        require(block.timestamp < deadline, "Expired");
        require(
            ecrecover(
                _getDigest(
                    keccak256(
                        abi.encode(
                            PERMIT_SIGNATURE_HASH,
                            owner_,
                            spender,
                            value,
                            nonces[owner_]++,
                            deadline
                        )
                    )
                ),
                v,
                r,
                s
            ) == owner_,
            "Invalid Sig"
        );
        allowance[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }

    address public pendingOperator;
    uint256 public pendingOperatorTime;

    function setOperator(address newOperator) public {

        require(newOperator != address(0), "Zero operator");
        uint256 netVotes = totalSupply - votes[address(0)];
        if (newOperator != pendingOperator) {
            require(votes[newOperator] * 2 > netVotes, "Not enough votes");
            pendingOperator = newOperator;
            pendingOperatorTime = block.timestamp + 7 days;
        } else {
            if (votes[newOperator] * 2 > netVotes) {
                require(block.timestamp >= pendingOperatorTime, "Wait longer");
                operator = pendingOperator;
            }
            pendingOperator = address(0);
            pendingOperatorTime = 0;
        }
    }

    function mint(uint256 amount, address operatorVote) public returns (bool) {

        require(msg.sender != address(0), "Zero address");
        User memory user = users[msg.sender];

        uint256 totalTokens = token.balanceOf(address(this));
        uint256 shares =
            totalSupply == 0 ? amount : (amount * totalSupply) / totalTokens;

        address currentVote = userVote[msg.sender];
        uint256 extraVotes = shares;
        if (currentVote != operatorVote) {
            if (user.balance > 0) {
                votes[currentVote] -= user.balance;
                extraVotes += user.balance;
            }
            userVote[msg.sender] = operatorVote;
        }
        votes[operatorVote] += extraVotes;

        user.balance += shares.to128();
        user.lockedUntil = (block.timestamp + 24 hours).to128();
        users[msg.sender] = user;
        totalSupply += shares;

        token.transferFrom(msg.sender, address(this), amount);

        emit Transfer(address(0), msg.sender, shares);
        return true;
    }

    function vote(address operatorVote) public returns (bool) {

        address currentVote = userVote[msg.sender];
        if (currentVote != operatorVote) {
            User memory user = users[msg.sender];
            if (user.balance > 0) {
                votes[currentVote] -= user.balance;
                votes[operatorVote] += user.balance;
            }
            userVote[msg.sender] = operatorVote;
        }
        return true;
    }

    function _burn(
        address from,
        address to,
        uint256 shares
    ) internal {

        require(to != address(0), "Zero address");
        User memory user = users[from];
        require(block.timestamp >= user.lockedUntil, "Locked");
        uint256 amount =
            (shares * token.balanceOf(address(this))) / totalSupply;
        users[from].balance = user.balance.sub(shares.to128()); // Must check underflow
        totalSupply -= shares;
        votes[userVote[from]] -= shares;

        token.transfer(to, amount);

        emit Transfer(from, address(0), shares);
    }

    function burn(address to, uint256 shares) public returns (bool) {

        _burn(msg.sender, to, shares);
        return true;
    }

    function burnFrom(
        address from,
        address to,
        uint256 shares
    ) public returns (bool) {

        _useAllowance(from, shares);
        _burn(from, to, shares);
        return true;
    }

    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        bytes data,
        uint256 eta
    );
    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        bytes data
    );
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        bytes data
    );

    uint256 public constant GRACE_PERIOD = 14 days;
    uint256 public constant DELAY = 2 days;
    mapping(bytes32 => uint256) public queuedTransactions;

    function queueTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public returns (bytes32) {

        require(msg.sender == operator, "Operator only");
        require(votes[operator] * 2 > totalSupply, "Not enough votes");

        bytes32 txHash = keccak256(abi.encode(target, value, data));
        uint256 eta = block.timestamp + DELAY;
        queuedTransactions[txHash] = eta;

        emit QueueTransaction(txHash, target, value, data, eta);
        return txHash;
    }

    function cancelTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public {

        require(msg.sender == operator, "Operator only");

        bytes32 txHash = keccak256(abi.encode(target, value, data));
        queuedTransactions[txHash] = 0;

        emit CancelTransaction(txHash, target, value, data);
    }

    function executeTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public payable returns (bytes memory) {

        require(msg.sender == operator, "Operator only");
        require(votes[operator] * 2 > totalSupply, "Not enough votes");

        bytes32 txHash = keccak256(abi.encode(target, value, data));
        uint256 eta = queuedTransactions[txHash];
        require(block.timestamp >= eta, "Too early");
        require(block.timestamp <= eta + GRACE_PERIOD, "Tx stale");

        queuedTransactions[txHash] = 0;

        (bool success, bytes memory returnData) =
            target.call{value: value}(data);
        require(success, "Tx reverted :(");

        emit ExecuteTransaction(txHash, target, value, data);

        return returnData;
    }
}