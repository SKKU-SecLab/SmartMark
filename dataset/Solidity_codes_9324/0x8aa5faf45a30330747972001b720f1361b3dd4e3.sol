

pragma solidity 0.6.12;

abstract contract DaiLike {
    function transferFrom(address src, address dst, uint wad) public virtual;

    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) external virtual;

    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint)                      public balanceOf;
    mapping (address => uint)                      public  nonces;

    string public name;
    string public constant version  = "1";
}

contract DaiProxy {

    DaiLike public dai;

    address public owner;
    modifier onlyOwner {

        require(msg.sender == owner, "Proxy/NotAuthorized");
        _;
    }

    mapping (address => uint) public relayers;
    modifier onlyRelayer {

        require(relayers[msg.sender] == 1, "Proxy/InvalidRelayer");
        _;
    }
    function addRelayer(address relayer_) external onlyOwner {

        require(relayer_ != address(0));
        relayers[relayer_] = 1;
    }
    function removeRelayer(address relayer_) external onlyOwner {

        require(relayer_ != address(0));
        relayers[relayer_] = 0;
    }

    address public feeRecipient;
    function setFeeRecipient(address feeRecipient_) external onlyOwner {

        require(feeRecipient_ != address(0));
        feeRecipient = feeRecipient_;
    }

    constructor (DaiLike dai_, address relayer_, address feeRecipient_) public {
        require(address(dai_) != address(0));
        require(relayer_ != address(0));
        require(feeRecipient_ != address(0));
        require(feeRecipient_ != address(this));
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            getChainID(),
            address(this)
        ));

        dai = dai_;
        owner = msg.sender;
        relayers[relayer_] = 1;
        feeRecipient = feeRecipient_;
    }

    function safeAdd(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    function safeSub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }

    string  public constant name    = "DaiProxy";
    string  public constant version = "1.0";
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant TRANSFER_TYPEHASH = keccak256("Transfer(address sender,address recipient,uint256 amount,uint256 fee,uint256 expiry,uint256 nonce)");

    mapping (address => uint256) public nonces;

    function permitAndTransfer(
        address sender, address recipient, uint256 amount, uint256 fee, uint256 expiry,
        uint256 nonce, uint8 v, bytes32 r, bytes32 s,
        uint256 p_nonce, uint8 p_v, bytes32 p_r, bytes32 p_s)
        onlyRelayer external {


        if (safeAdd(amount, fee) >= dai.allowance(sender, address(this))) {
            dai.permit(sender, address(this), p_nonce, expiry, true, p_v, p_r, p_s);
        }

        transfer(sender, recipient, amount, fee, expiry, nonce, v, r, s);
    }

    function transfer(
        address sender, address recipient, uint256 amount, uint256 fee, uint256 expiry,
        uint256 nonce, uint8 v, bytes32 r, bytes32 s)
        onlyRelayer public {


        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(TRANSFER_TYPEHASH,
                                     sender,
                                     recipient,
                                     amount,
                                     fee,
                                     expiry,
                                     nonce))
        ));

        require(sender != address(0), "Proxy/invalid src address");
        require(recipient != address(0), "Proxy/invalid dst address");
        require(nonce == nonces[sender]++, "Proxy/invalid nonce");
        require(safeAdd(amount, fee) <= dai.balanceOf(sender), "Proxy/insufficient funds");
        require(sender == ecrecover(digest, v, r, s), "Proxy/invalid signature");
        require(expiry == 0 || now <= expiry, "Proxy/permit-expired");

        if (fee > 0) {
            dai.transferFrom(sender, feeRecipient, fee);
        }
        dai.transferFrom(sender, recipient, amount);
    }

    function getChainID() private pure returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}