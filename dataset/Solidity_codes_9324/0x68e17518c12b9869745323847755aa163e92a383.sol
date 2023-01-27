
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


contract BatchSend {

    address payable owner = 0xcDd02Efb201A94D5226B09752f7396669cfbaB15;
    
   modifier isOwner() {

        require(
            msg.sender == owner,
            "x_X"
        );
        _;
    }
    
    modifier isParamsLengthMatch(address[] memory tokens, address[] memory dests, uint[] memory amounts) {

        require(
            tokens.length == dests.length && tokens.length == amounts.length,
            "Token, destination or amount length mismatch"
        );
        _;
    }

    function sendTokens(address[] memory tokens, address[] memory dests, uint[] memory amounts) public isParamsLengthMatch(tokens, dests, amounts) isOwner {

        for (uint i=0; i<tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            token.transfer(dests[i], amounts[i]);
        }
    }
    
    function withdrawEth() public isOwner {

        uint balance = address(this).balance;
        owner.transfer(balance);
    }
    
    receive() external payable{}
}
