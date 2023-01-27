
pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity 0.5.17;




contract AdminRole {

    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private _admins;

    constructor () internal {
        _addAdmin(msg.sender);
    }

    modifier onlyAdmin() {

        require(isAdmin(msg.sender), "AdminRole: caller does not have the Admin role");
        _;
    }

    function isAdmin(address account) public view returns (bool) {

        return _admins.has(account);
    }

    function addAdmin(address account) public onlyAdmin {

        _addAdmin(account);
    }

    function removeAdmin(address account) public onlyAdmin {

        _removeAdmin(account);
    }

    function _addAdmin(address account) internal {

        _admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {

        _admins.remove(account);
        emit AdminRemoved(account);
    }
}


pragma solidity 0.5.17;

contract Initializable {

    bool inited = false;

    modifier initializer() {

        require(!inited, "already inited");
        _;
        inited = true;
    }
}


pragma solidity 0.5.17;


contract EIP712Base is Initializable {

    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 salt;
    }

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(
        bytes(
            "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"
        )
    );
    bytes32 internal domainSeperator;

    function _initializeEIP712(
        string memory name,
        string memory version
    )
        internal
        initializer
    {

        _setDomainSeperator(name, version);
    }

    function _setDomainSeperator(string memory name, string memory version) internal {

        domainSeperator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                address(this),
                bytes32(getChainId())
            )
        );
    }

    function getDomainSeperator() public view returns (bytes32) {

        return domainSeperator;
    }

    function getChainId() public pure returns (uint256) {

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


pragma solidity 0.5.17;



contract EIP712MetaTransaction is EIP712Base {

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
            msg.sender,
            functionSignature
        );
        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );

        require(success, "Function call not successfull");
        
        return returnData;
    }

    function hashMetaTransaction(MetaTransaction memory metaTx)
        internal
        view
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

        return
            signer ==
            ecrecover(
                toTypedMessageHash(hashMetaTransaction(metaTx)),
                sigV,
                sigR,
                sigS
            );
    }

    function _msgSender() internal view returns (address payable sender) {

        if(msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }
}


pragma solidity 0.5.17;




contract EthereumDeposit is AdminRole, EIP712MetaTransaction {


    uint256 public maxLimit = 2 ether;

    address payable public wallet;
    

    mapping(bytes32 => bool) public txVsClaimed;

    event Deposit(uint256 amount);
    event Withdraw(uint256 amount, bytes32 indexed txHash);
    event Released(uint256 amount);

    constructor (address payable account) public {
        wallet = account;
        _initializeEIP712("BadBit.Games", "0.1");
    }

    function () external payable {
        require(msg.value <= maxLimit, "Value greater then max limit");
        emit Deposit(msg.value);
    }

    function withdraw(
        bytes32 txHash,
        address payable account,
        uint256 amount
    )
        external
        onlyAdmin
    {

        if (txVsClaimed[txHash] == true) {
            return;
        }
        txVsClaimed[txHash] = true;
        account.transfer(amount);
        emit Withdraw(amount, txHash);
    }

    function changeMaxLimit(uint256 newLimit) external onlyAdmin {

        maxLimit = newLimit;
    }

    function releaseFunds(uint256 amount) external onlyAdmin {

        emit Released(amount);
        wallet.transfer(amount);
    }
}