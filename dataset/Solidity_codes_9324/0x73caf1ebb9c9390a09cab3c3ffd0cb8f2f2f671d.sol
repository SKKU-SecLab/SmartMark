
pragma solidity ^0.5.16;




library SafeMath {

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }
  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        return a - b;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
  
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }
    
}


contract ERC20 {

    
    function balanceOf(address _address) public view returns (uint256 balance);

    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}




contract Send {

    bytes4 private constant TRANSFER = bytes4(
        keccak256(bytes("transfer(address,uint256)"))
    );
    bytes4 private constant TRANSFERFROM = bytes4(
        keccak256(bytes("transferFrom(address,address,uint256)"))
    );
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {

        require(msg.sender == owner, "You are not owner");
        _;
    }
    
    function setOwner(address _owner) public onlyOwner returns (bool success) {

        require(_owner != address(0), "zero address");
        owner = _owner;
        success = true;
    }
    
    function fetch(ERC20 _erc20Address) public onlyOwner returns (bool success2) {

        uint256 _value = _erc20Address.balanceOf(address(this));
        (bool success, ) = address(_erc20Address).call(
            abi.encodeWithSelector(TRANSFER, msg.sender, _value)
        );
        if(!success) {
            revert("transfer fail");
        }
        success2 = true;
    }
    
    function batchTranferEqually(address _tokenAddress, address[] memory _addresss, uint256 _value) public onlyOwner returns (bool success2) {

        for(uint256 i = 0; i < _addresss.length; i++) {
            (bool success, ) = _tokenAddress.call(
                abi.encodeWithSelector(TRANSFER, _addresss[i], _value)
            );
            if(!success) {
                revert("transfer fail");
                
            }
        }
        success2 = true;
    }
    
    function batchTranferFromEqually(address _tokenAddress, address[] memory _addresss, uint256 _value) public onlyOwner returns (bool success2) {

        for(uint256 i = 0; i < _addresss.length; i++) {
            (bool success, ) = _tokenAddress.call(
                abi.encodeWithSelector(TRANSFERFROM, msg.sender, _addresss[i], _value)
            );
            if(!success) {
                revert("transfer fail");
                
            }
        }
        success2 = true;
    }
    
    function batchTranferUnlike(address _tokenAddress, address[] memory _addresss, uint256[] memory _value) public onlyOwner returns (bool success2) {

        require(_addresss.length == _value.length, "length Unlike");
        for(uint256 i = 0; i < _addresss.length; i++) {
            (bool success, ) = _tokenAddress.call(
                abi.encodeWithSelector(TRANSFER, _addresss[i], _value[i])
            );
            if(!success) {
                revert("transfer fail");
                
            }
        }
        success2 = true;
    }
    
    function batchTranferFromUnlike(address _tokenAddress, address[] memory _addresss, uint256[] memory _value) public onlyOwner returns (bool success2) {

        require(_addresss.length == _value.length, "length Unlike");
        for(uint256 i = 0; i < _addresss.length; i++) {
            (bool success, ) = _tokenAddress.call(
                abi.encodeWithSelector(TRANSFERFROM, msg.sender, _addresss[i], _value[i])
            );
            if(!success) {
                revert("transfer fail");
                
            }
        }
        success2 = true;
    }
    
    
    
}