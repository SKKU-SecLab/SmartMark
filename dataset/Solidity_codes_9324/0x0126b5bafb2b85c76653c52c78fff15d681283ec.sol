
pragma solidity ^0.5.0;

contract Owned {

    address public owner;
    address public newOwner;
    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }
    function acceptOwnership() public {

        require(msg.sender == newOwner);
        owner = newOwner;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);

  
    function allowance(address owner, address spender)
    external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value)
    external returns (bool);


    function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract TokenVendor is Owned {

    uint256 public priceInWei = 40000000000000000;
    address public tokenAddress = 0x9F34Ad564c5Cc5137726Fca8fA87Ac44f7866F39;
    uint256 public tokenDecimals = 4;

    constructor() public {
        owner = 0xc7a1Bd7a0A7eF23cb2544641CF6d7D14157A71bb;
    }
    
    event Buy(address to, uint256 amount);
    
    function setTokenAddress(address _tokenAddress) public onlyOwner {

        tokenAddress = _tokenAddress;
    }
    
    function setPrice(uint256 _priceInWei) public onlyOwner {

        require(_priceInWei > 0);
        priceInWei = _priceInWei;
    }
    
    function setTokenDecimals(uint256 _tokenDecimals) public onlyOwner {

        tokenDecimals = _tokenDecimals;
    }
    
    function () external payable {
        require(msg.value >= priceInWei && msg.value > 0);
        require(IERC20(tokenAddress).allowance(owner,address(this)) >= (msg.value / priceInWei) /  10 ** tokenDecimals);
        require(IERC20(tokenAddress).balanceOf(owner) >= (msg.value / priceInWei) /  10 ** tokenDecimals);
        uint256 amount = ((msg.value / priceInWei) /  10 ** tokenDecimals);
        IERC20(tokenAddress).transferFrom(owner, address(this), amount);
        IERC20(tokenAddress).transfer(msg.sender, amount);
        emit Buy(msg.sender, amount);
    }
    function buy() public payable {

        require(msg.value >= priceInWei && msg.value > 0);
        require(IERC20(tokenAddress).allowance(owner,address(this)) >= (msg.value / priceInWei) /  10 ** tokenDecimals);
        require(IERC20(tokenAddress).balanceOf(owner) >= (msg.value / priceInWei) /  10 ** tokenDecimals);
        uint256 amount = ((msg.value / priceInWei) /  10 ** tokenDecimals);
        IERC20(tokenAddress).transferFrom(owner, address(this), amount);
        IERC20(tokenAddress).transfer(msg.sender, amount);
        emit Buy(msg.sender, amount);
    }
}