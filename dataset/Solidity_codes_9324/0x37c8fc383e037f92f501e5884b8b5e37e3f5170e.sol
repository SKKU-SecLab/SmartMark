
pragma solidity ^0.5.16;

interface Artd {

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

}

interface Nftfactory {

    function currentStore( uint256 nftId ) external view returns (uint256);

}

interface Validfactory {

    function isValidfactory( address _factory ) external returns (bool);

}


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


library SafeMath {

    int256 constant private INT256_MIN = -2**255;

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


contract ARTDfundpool is Governance{

    using SafeMath for uint256;
    using Address for address;

    address public ARTDaddress =  address(0xA23F8462d90dbc60a06B9226206bFACdEAD2A26F);
    address public valider = address(0x58F62d9B184BE5D7eE6881854DD16898Afe0cf90);
    address private _factory = address(0);
    
    event Approve(address newfactory, uint256 amount);
    event Newfactory(address newfactory);
      
    constructor() public {}

    function newfactory(address factory) public onlyGovernance
    {

        Validfactory _valid = Validfactory(valider);
        require( _valid.isValidfactory(factory), "Invalid factory");
        
        _factory = factory;
        
        emit Newfactory(factory);
    }

    function approve(address factory, uint256 amount) public 
    {

        Validfactory _valid = Validfactory(valider);
        require( _valid.isValidfactory(factory), "Invalid factory");

        Artd _artd =  Artd( ARTDaddress );
        _artd.approve( factory, amount );
        
        emit Approve(factory, amount);
    }
    
    function factory() external view returns (address) 
    {

        return _factory;   
    } 
    
    function storeOf(uint256 nftId) external view returns (uint256) 
    {

        Nftfactory factory_x =  Nftfactory( _factory );
        return factory_x.currentStore(nftId);
    }

    function totalBalance() external view returns (uint256) 
    {

        Artd _artd =  Artd( ARTDaddress );
        return _artd.balanceOf(address(this));
    }
    
}