

pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

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
}


pragma solidity ^0.6.0;




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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;




interface IGateway {

    function mint(bytes32 _pHash, uint256 _amount, bytes32 _nHash, bytes calldata _sig) external returns (uint256);

    function burn(bytes calldata _to, uint256 _amount) external returns (uint256);

}

interface IGatewayRegistry {

    function getGatewayBySymbol(string calldata _tokenSymbol) external view returns (IGateway);

    function getTokenBySymbol(string calldata _tokenSymbol) external view returns (IERC20);

}

contract RenEscrow {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    event FundsDeposited(address indexed buyer, uint256 amount);
    event FundsRefunded();
    event FundsReleased(address indexed seller, uint256 amount);
    event DisputeResolved();
    event OwnershipTransferred(address indexed oldOwner, address newOwner);
    event MediatorChanged(address indexed oldMediator, address newMediator);

    enum Status { AWAITING_PAYMENT, PAID, REFUNDED, MEDIATED, COMPLETE }

    struct RenEscrowConfig {
        bytes id;
        IERC20 token;
        address mediator;
        address buyer;
        address seller;
        uint256 amount;
        uint256 fee;
        string symbol; // e.g. BTC, BCH, etc
        IGatewayRegistry registry;
    }

    Status public status;
    bytes32 escrowID;
    address public owner;
    RenEscrowConfig public config;
    bool public initialized = false;
    bool public funded = false;
    bool public completed = false;
    bytes32 public releaseMsgHash;
    bytes32 public refundMsgHash;
    bytes32 public resolveMsgHash;
    bytes  buyerOffChainAddr;
    bytes  sellerOffChainAddr;

    modifier onlyBuyer() {

        require(msg.sender == config.buyer, "Only the buyer can call this function.");
        _;
    }

    modifier onlyWithBuyerSignature(bytes32 hash, bytes memory signature) {

        require(
            hash.toEthSignedMessageHash()
                .recover(signature) == config.buyer,
            "Must be signed by buyer."
        );
        _;
    }

    modifier onlyWithSellerSignature(bytes32 hash, bytes memory signature) {

        require(
            hash.toEthSignedMessageHash()
                .recover(signature) == config.buyer,
            "Must be signed by buyer."
        );
        _;
    }

    modifier onlyWithParticipantSignature(bytes32 hash, bytes memory signature) {

        address signer = hash.toEthSignedMessageHash()
            .recover(signature);
        require(
            signer == config.buyer || signer == config.seller,
            "Must be signed by either buyer or seller."
        );
        _;
    }

    modifier onlySeller() {

        require(msg.sender == config.seller, "Only the seller can call this function.");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyMediator() {

        require(msg.sender == config.mediator, "Only the mediator can call this function.");
        _;
    }

    modifier onlyUninitialized() {

        require(initialized == false, "Escrow already initialized.");
        initialized = true;
        _;
    }

    modifier onlyUnfunded() {

        require(funded == false, "Escrow already funded.");
        funded = true;
        _;
    }

    modifier onlyFunded() {

        require(funded == true, "Escrow not funded.");
        _;
    }

    modifier onlyIncompleted() {

        require(completed == false, "Escrow already completed.");
        completed = true;
        _;
    }

    function init(
        bytes32 _escrowID,
        address _owner,
        bytes memory _buyerOffChainAddr,
        bytes memory _sellerOffChainAddr,
        RenEscrowConfig memory _cfg
    )
        public
        onlyUninitialized
    {

        status = Status.AWAITING_PAYMENT;
        escrowID = _escrowID;
        owner = _owner;
        buyerOffChainAddr = _buyerOffChainAddr;
        sellerOffChainAddr = _sellerOffChainAddr;
        config = _cfg;
        releaseMsgHash = keccak256(
            abi.encodePacked("releaseFunds()", escrowID, address(this))
        );
        refundMsgHash = keccak256(
            abi.encodePacked("refund()", escrowID, address(this))
        );
        resolveMsgHash = keccak256(
            abi.encodePacked("resolveDispute()", escrowID, address(this))
        );
        emit OwnershipTransferred(address(0), _owner);
        emit MediatorChanged(address(0), _owner);
    }

    function depositAmount() public view returns (uint256) {

        return config.amount.add(config.fee);
    }

    function deposit(
        bytes calldata _msg,
        uint256        _amount,
        bytes32        _nHash,
        bytes calldata _sig
    )
        external
        onlyUnfunded
    {

        bytes32 pHash = keccak256(abi.encode(_msg));
        uint256 mintedAmount = config.registry.getGatewayBySymbol(config.symbol).mint(pHash, _amount, _nHash, _sig);
        require(mintedAmount == depositAmount(), "Amount needs to be exact.");
        status = Status.PAID;
        emit FundsDeposited(msg.sender, mintedAmount);
    }

    function _releaseFees() private {

        config.token.safeTransfer(config.mediator, config.fee.mul(2));
    }

    function refund(
        bytes calldata _signature
    )
        external
        onlyFunded
        onlyIncompleted
        onlyWithSellerSignature(refundMsgHash, _signature)
    {

        uint256 releaseAmount = depositAmount().sub(config.fee.mul(2));
        config.registry.getGatewayBySymbol(config.symbol).burn(buyerOffChainAddr, releaseAmount);
        _releaseFees();
        status = Status.REFUNDED;
        emit FundsRefunded();
    }

    function releaseFunds(
        bytes calldata _signature
    )
        external
        onlyFunded
        onlyIncompleted
        onlyWithBuyerSignature(releaseMsgHash, _signature)
    {

        uint256 releaseAmount = depositAmount().sub(config.fee.mul(2));
        config.registry.getGatewayBySymbol(config.symbol).burn(sellerOffChainAddr, releaseAmount);

        _releaseFees();

        status = Status.COMPLETE;
        emit FundsReleased(config.seller, releaseAmount);
    }

    function resolveDispute(
        bytes calldata _signature,
        uint8 _buyerPercent
    )
        external
        onlyFunded
        onlyMediator
        onlyIncompleted
        onlyWithParticipantSignature(resolveMsgHash, _signature)
    {

        require(_buyerPercent <= 100, "_buyerPercent must be 100 or lower");
        uint256 releaseAmount = depositAmount().sub(config.fee.mul(2));

        status = Status.MEDIATED;
        emit DisputeResolved();

        if (_buyerPercent > 0)
            config.registry.getGatewayBySymbol(config.symbol).burn(buyerOffChainAddr, releaseAmount.mul(uint256(_buyerPercent)).div(100));
        if (_buyerPercent < 100)
            config.registry.getGatewayBySymbol(config.symbol).burn(sellerOffChainAddr, releaseAmount.mul(uint256(100).sub(_buyerPercent)).div(100));

        _releaseFees();
    }

    function setOwner(address _newOwner) external onlyOwner {

        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function setMediator(address _newMediator) external onlyOwner {

        emit MediatorChanged(config.mediator, _newMediator);
        config.mediator = _newMediator;
    }
}