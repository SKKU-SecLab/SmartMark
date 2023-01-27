

pragma solidity ^0.8.4;
interface IERC20 {

  function totalSupply() external view returns (uint256);


  function decimals() external view returns (uint8);


  function symbol() external view returns (string memory);


  function name() external view returns (string memory);


  function getOwner() external view returns (address);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address _owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract BridgeBase {

    address public admin;
    IERC20 public token;
    event Deposit(address indexed from, address indexed to, uint256 amount);
    event Withdraw(address indexed from, address indexed to, uint256 amount);

    mapping(bytes32 => bool) private txList;

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    constructor(address _token) {
        admin = msg.sender;
        token = IERC20(_token);
    }

    function verifySign(bytes32 txId, address to, uint256 amount, Sign memory sign) internal view {

        bytes32 hash = keccak256(abi.encodePacked(txId,to,amount));
        require(admin == ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), sign.v, sign.r, sign.s), "Owner sign verification failed");
    }

    function deposit(uint256 amount) public returns(bool) {

        require(amount != 0,"Bridge: amount shouldn't be zero");
        bool transferred = token.transferFrom(msg.sender, address(this), amount);
        require(transferred,"Bridge: token transfer is not done");
        emit Deposit(msg.sender, address(this), amount);
        return true;   
    }

    function withdraw(bytes32 txID, uint256 amount, Sign memory sign) public returns (bool) {

        require(token.balanceOf(address(this)) > amount, "Bridge: amount exceeds the balance");
        require(!txList[txID],"Bridge: withdraw Transaction is already done");
        verifySign(txID, msg.sender, amount, sign);
        token.transfer(msg.sender, amount);
        txList[txID] = true;
        emit Withdraw(address(this), msg.sender, amount);
        return true;
    }

    function getTxdetails (bytes32 txID) public view returns(bool) {
        return txList[txID];
    }

}
contract CELADONBRIDGE is BridgeBase {

    constructor(address token) BridgeBase(token) {}
}