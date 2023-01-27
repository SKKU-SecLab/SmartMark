

pragma solidity ^0.5.2;

contract Token {

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function transfer(address to, uint value) public returns (bool);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    function balanceOf(address owner) public view returns (uint);

    function allowance(address owner, address spender) public view returns (uint);

    function totalSupply() public view returns (uint);

}


pragma solidity ^0.5.8;



contract Disbursement {


    address public owner;
    address public receiver;
    address public wallet;
    uint public disbursementPeriod;
    uint public startDate;
    uint public withdrawnTokens;
    Token public token;

    modifier isOwner() {

        if (msg.sender != owner)
            revert("Only owner is allowed to proceed");
        _;
    }

    modifier isReceiver() {

        if (msg.sender != receiver)
            revert("Only receiver is allowed to proceed");
        _;
    }

    modifier isWallet() {

        if (msg.sender != wallet)
            revert("Only wallet is allowed to proceed");
        _;
    }

    modifier isSetUp() {

        if (address(token) == address(0))
            revert("Contract is not set up");
        _;
    }

    constructor(address _receiver, address _wallet, uint _disbursementPeriod, uint _startDate)
        public
    {
        if (_receiver == address(0) || _wallet == address(0) || _disbursementPeriod == 0)
            revert("Arguments are null");
        owner = msg.sender;
        receiver = _receiver;
        wallet = _wallet;
        disbursementPeriod = _disbursementPeriod;
        startDate = _startDate;
        if (startDate == 0){
          startDate = now;
        }
    }

    function setup(Token _token)
        public
        isOwner
    {

        if (address(token) != address(0) || address(_token) == address(0))
            revert("Setup was executed already or address is null");
        token = _token;
    }

    function withdraw(address _to, uint256 _value)
        public
        isReceiver
        isSetUp
    {

        uint maxTokens = calcMaxWithdraw();
        if (_value > maxTokens){
          revert("Withdraw amount exceeds allowed tokens");
        }
        withdrawnTokens += _value;
        token.transfer(_to, _value);
    }

    function walletWithdraw()
        public
        isWallet
        isSetUp
    {

        uint balance = token.balanceOf(address(this));
        withdrawnTokens += balance;
        token.transfer(wallet, balance);
    }

    function calcMaxWithdraw()
        public
        view
        returns (uint)
    {

        uint maxTokens = (token.balanceOf(address(this)) + withdrawnTokens) * (now - startDate) / disbursementPeriod;
        if (withdrawnTokens >= maxTokens || startDate > now){
          return 0;
        }
        return maxTokens - withdrawnTokens;
    }
}