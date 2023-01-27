

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


contract ExseTokenSale {

    
    uint public ethPrice = 0.0004 ether;
    address payable public owner;
    IERC20 public token;

    struct Sale {
        uint startTime;
        uint finishTime;
    }

    Sale[] public sales;

    modifier onlyOwner() { 

        require(msg.sender == owner, "onlyOwner");
        _; 
    }
    
    constructor(address tokenAddress) public {
        owner = msg.sender;
        token = IERC20(tokenAddress);

        _newSaleStage(1607428800, 1608897600);
    }

    function newSaleStage(uint _startTime, uint _finishTime) public onlyOwner {

        require(block.timestamp > sales[sales.length-1].finishTime, "wait for previous stage finish");
        _newSaleStage(_startTime, _finishTime);
    }

    receive() external payable {
        buy();
    }
    
    function buy() public payable {

        require(block.timestamp >= sales[sales.length-1].startTime, "sale is not open yet");
        require(block.timestamp < sales[sales.length-1].finishTime, "sale closed");
        require(msg.value > 0, "msg value can't be zero");

        uint forMint = msg.value*(1e18)/(ethPrice);

        token.transfer(msg.sender, forMint);
        owner.transfer(address(this).balance);
    }

    function setPrice(uint _ethPrice) public onlyOwner {

        ethPrice = _ethPrice;
    }

    function withdrawUnsoldTokens() public onlyOwner {

        require(block.timestamp > sales[sales.length-1].finishTime, "sale still open");
        token.transfer(owner, token.balanceOf(address(this)));
    }
    
    function withdraw() public onlyOwner {

        owner.transfer(address(this).balance);
    }
    
    
    function _newSaleStage(uint _startTime, uint _finishTime) internal {

        Sale memory sale = Sale({
            startTime: _startTime,
            finishTime: _finishTime
        });

        sales.push(sale);
    }
}