
pragma solidity ^0.4.23;

contract disburseERC20v11 {

    event Disbursement(address indexed _tokenContract,  address[] indexed _contributors, uint256[] _contributions, uint256 _amount);
    event AdminSet(address indexed _tokenContract, address indexed _admin);
    event OwnerSet(address _owner);

    address owner;
    mapping(address => address) tokenAdmins;
    
    constructor() public {
        owner = msg.sender;
        emit OwnerSet(owner);
    }  

    function disburseToken(address _tokenContract, address[] _contributors, uint256[] _contributions) public {


        require(msg.sender == tokenAdmins[_tokenContract]);

        uint256 balance = ERC20Token(_tokenContract).balanceOf(address(this));

        uint256 totalContributions;
        for(uint16 i = 0; i < _contributions.length; i++){
            totalContributions = totalContributions + _contributions[i];
        }

        for(i = 0; i < _contributors.length; i++){
            uint256 disbursement = (balance * _contributions[i]) / totalContributions;
            
            require(ERC20Token(_tokenContract).transfer(_contributors[i], disbursement));
        }
        emit Disbursement(_tokenContract, _contributors, _contributions, balance);
    }
    
    function setAdmin(address _tokenContract, address _admin) public {

        require(_admin != address(0));
        
        require(msg.sender == tokenAdmins[_tokenContract] || msg.sender == owner);
        
        tokenAdmins[_tokenContract] = _admin;
        
        emit AdminSet(_tokenContract, _admin);
    }
    
    function setOwner(address _owner) public {

        require(_owner != address(0));
        
        require(msg.sender == owner);
        
        owner = _owner;
        
        emit OwnerSet(_owner);
    }
}

interface ERC20Token {

    function balanceOf(address _holder) external returns(uint256 tokens);

    function transfer(address _to, uint256 amount) external returns(bool success);

}