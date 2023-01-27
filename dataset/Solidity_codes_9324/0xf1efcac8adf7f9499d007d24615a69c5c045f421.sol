pragma solidity ^0.5.0;



















library SafeMath {


    function add(uint a, uint b) internal pure returns (uint c) {


        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {


        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {


        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {


        require(b > 0);

        c = a / b;

    }

}







contract ERC20Interface {


    function totalSupply() public view returns (uint);


    function balanceOf(address tokenOwner) public view returns (uint balance);


    function allowance(address tokenOwner, address spender) public view returns (uint remaining);


    function transfer(address to, uint tokens) public returns (bool success);


    function approve(address spender, uint tokens) public returns (bool success);


    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}








contract ApproveAndCallFallBack {


    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;


}






contract Owned {


    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);


    constructor() public {

        owner = msg.sender;

    }


    modifier onlyOwner {


        require(msg.sender == owner);

        _;

    }


    function transferOwnership(address newOwner) public onlyOwner {


        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);

    }

}



contract Tokenlock is Owned {

    
    uint8 isLocked = 0;       //flag indicates if token is locked

    event Freezed();
    event UnFreezed();

    modifier validLock {

        require(isLocked == 0);
        _;
    }
    
    function freeze() public onlyOwner {

        isLocked = 1;
        
        emit Freezed();
    }

    function unfreeze() public onlyOwner {

        isLocked = 0;
        
        emit UnFreezed();
    }
}



contract UserLock is Owned {

    
    mapping(address => bool) blacklist;
        
    event LockUser(address indexed who);
    event UnlockUser(address indexed who);

    modifier permissionCheck {

        require(!blacklist[msg.sender]);
        _;
    }
    
    function lockUser(address who) public onlyOwner {

        blacklist[who] = true;
        
        emit LockUser(who);
    }

    function unlockUser(address who) public onlyOwner {

        blacklist[who] = false;
        
        emit UnlockUser(who);
    }
}






contract SwipeToken is ERC20Interface, Tokenlock, UserLock {


    using SafeMath for uint;


    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalSupply;


    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;






    constructor() public {

        symbol = "SXP";

        name = "Swipe";

        decimals = 18;

        _totalSupply = 300000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);

    }






    function totalSupply() public view returns (uint) {


        return _totalSupply.sub(balances[address(0)]);

    }






    function balanceOf(address tokenOwner) public view returns (uint balance) {


        return balances[tokenOwner];

    }








    function transfer(address to, uint tokens) public validLock permissionCheck returns (bool success) {


        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }











    function approve(address spender, uint tokens) public validLock permissionCheck returns (bool success) {


        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }












    function transferFrom(address from, address to, uint tokens) public validLock permissionCheck returns (bool success) {


        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(from, to, tokens);

        return true;

    }







    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {


        return allowed[tokenOwner][spender];

    }


     
     
     
     
    function burn(uint256 value) public validLock permissionCheck returns (bool success) {

        require(msg.sender != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        balances[msg.sender] = balances[msg.sender].sub(value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }






    function approveAndCall(address spender, uint tokens, bytes memory data) public validLock permissionCheck returns (bool success) {


        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);

        return true;

    }


    
    function burnForAllowance(address account, address feeAccount, uint256 amount) public onlyOwner returns (bool success) {

        require(account != address(0), "burn from the zero address");
        require(balanceOf(account) >= amount, "insufficient balance");

        uint feeAmount = amount.mul(2).div(10);
        uint burnAmount = amount.sub(feeAmount);
        
        _totalSupply = _totalSupply.sub(burnAmount);
        balances[account] = balances[account].sub(amount);
        balances[feeAccount] = balances[feeAccount].add(feeAmount);
        emit Transfer(account, address(0), burnAmount);
        emit Transfer(account, msg.sender, feeAmount);
        return true;
    }





    function () external payable {

        revert();

    }






    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {


        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}
pragma solidity ^0.5.0;





contract Ownable {


    address owner;
    address admin;

    event OwnershipTransferred(address indexed _from, address indexed _to);




    constructor() public {
        owner = msg.sender;
        admin = address(0);
    }

    modifier onlyAdmin {

        require(msg.sender == owner || msg.sender == admin);

        _;
    }

    modifier onlyOwner {

        require(msg.sender == owner);

        _;
    }




    function viewOwner() external view returns(address) {

        return owner;
    }




    function setOwner(address newOwner) external onlyOwner {

        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }




    function viewAdmin() external view returns(address) {

        return admin;
    }




    function setAdmin(address newAdmin) external onlyOwner {

        admin = newAdmin;
    }

}



contract SwipeNetwork is Ownable {

    using SafeMath for uint;

    SwipeToken public token;

    uint transferFee = 1000000000000000000;
    uint networkFee = 80;
    uint oracleFee = 20;
    uint activationFee = 1000000000000000000;
    uint protocolRate = 100;



    constructor(address payable _token) public {
        token = SwipeToken(_token);
    }



    function viewTrsansferFee() external view returns(uint) {

        return transferFee;
    }




    function setTransferFee(uint fee) external onlyAdmin {

        transferFee = fee;
    }



    function viewNetworkFee() external view returns(uint) {

        return networkFee;
    }




    function setNetworkFee(uint fee) external onlyAdmin {

        networkFee = fee;
    }




    function viewOracleFee() external view returns(uint) {

        return oracleFee;
    }




    function setOracleFee(uint fee) external onlyAdmin {

        oracleFee = fee;
    }




    function viewActivationFee() external view returns(uint) {

        return activationFee;
    }




    function setActivationFee(uint fee) external onlyAdmin {

        activationFee = fee;
    }

    function viewProtocolRate() external view returns(uint) {

        return protocolRate;
    }

    function setProtocolRate(uint rate) external onlyAdmin {

        protocolRate = rate;
    }

    function getBalance() public view returns(uint) {

        return token.balanceOf(address(this));
    }

    function buySXP(address to, uint amount) external onlyAdmin returns (bool success) {

        require(getBalance() >= amount, 'not enough reserve balance');

        if (token.transfer(to, amount)) {
            return true;
        }

        return false;
    }

    function buySXPMultiple(address[] memory to, uint[] memory amount) public onlyAdmin returns (bool success) {

        uint total = 0;
        for (uint i = 0; i < amount.length; i ++) {
            total = total.add(amount[i]);
        }

        require(getBalance() >= total, 'not enough reserve balance');

        for (uint j = 0; j < to.length; j ++) {
            require(to[j] != address(0), 'invalid address');
            if (!token.transfer(to[j], amount[j])) {
                return false;
            }
        }

        return true;
    }

    function rewardSXP(address to, uint amount) external onlyAdmin returns (bool success) {

        require(getBalance() >= amount, 'not enough reserve balance');

        if (token.transfer(to, amount)) {
            return true;
        }

        return false;
    }
    
    function secureDeposit(address to, uint amount) external onlyAdmin returns (bool success) {

        require(getBalance() >= amount, 'not enough reserve balance');

        if (token.transfer(to, amount)) {
            return true;
        }

        return false;
    }
}
