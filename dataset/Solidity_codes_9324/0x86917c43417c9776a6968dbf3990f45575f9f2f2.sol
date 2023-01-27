
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
}// MIT
pragma solidity ^0.6.0;




contract FounderPool {

    IERC20 public Token;
    uint256 public blocklock;
    address public bucket;

    constructor(
        IERC20 Tokent,
        address buckt
    ) public {
        Token = Tokent;
        bucket = buckt;
    }
    uint256 public balmin;
    function tap() public {

        require(blocklock <= now, "block");
          if (balmin < Token.balanceOf(address(this))/24) {
          balmin = Token.balanceOf(address(this))/24;
          }
          if (balmin >Token.balanceOf(address(this))){
               Token.transfer(bucket, Token.balanceOf(address(this)));
           } else{
Token.transfer(bucket, balmin);
          }
        blocklock = now + 14 days;
    }
}