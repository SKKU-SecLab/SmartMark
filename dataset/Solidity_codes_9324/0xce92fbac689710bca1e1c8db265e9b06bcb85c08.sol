

pragma solidity ^0.5.0;


interface IPool {

    function totalSupply( ) external view returns (uint256);

    function balanceOf( address player ) external view returns (uint256);

}


pragma solidity ^0.5.0;

contract Governance {


    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {

        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {

        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


}


pragma solidity ^0.5.5;



contract DegoVoterProxy is Governance {

    
    struct info{
        IPool poolAddr;
        uint256 weight;
    }
    mapping(address => uint256) public _addr2Id;  
    mapping(uint256 => info) public _pools;  
    uint256 public _pID;       
    
    function decimals() external pure returns (uint8) {

        return uint8(18);
    }
    
    function name() external pure returns (string memory) {

        return "dego.voteproxy";
    }
    
    function symbol() external pure returns (string memory) {

        return "DEGOVOTE";
    }
    
    function totalSupply() external view returns (uint) {


        uint256 total = 0;
        for(uint256 i=1; i<=_pID; i++){
            if(_pools[i].weight>0){
                total  +=  _pools[i].poolAddr.totalSupply()*_pools[i].weight;
            }
        }
        return total; 
    }
    
    function balanceOf(address voter) external view returns (uint) {


        uint256 votes = 0;
        for(uint256 i=1; i<=_pID; i++){
            if(_pools[i].weight>0){
                votes  +=  _pools[i].poolAddr.balanceOf(voter)*_pools[i].weight;
            }
        }
        return votes;

    }

    function setPool(address pool, uint256 weight)  public  onlyGovernance{


        uint256 pID= _addr2Id[pool];
        if(pID == 0){
            _pID++;
            pID = _pID;
            _addr2Id[pool] = pID;
            _pools[pID].weight=weight;
            _pools[pID].poolAddr=IPool(pool);
        }
        else{
            _pools[pID].weight=weight;
        }

    }


    constructor() public {}
}