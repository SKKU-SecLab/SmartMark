


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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.0;

interface ENS {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed nodeOwner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address nodeOwner, address resolver, uint64 ttl) external;

    function setSubnodeRecord(bytes32 node, bytes32 label, address nodeOwner, address resolver, uint64 ttl) external;

    function setSubnodeOwner(bytes32 node, bytes32 label, address nodeOwner) external returns(bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address nodeOwner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address nodeOwner, address operator) external view returns (bool);

}


pragma solidity ^0.6.0;

interface ENSSimpleRegistrarI {

    function registerAddr(bytes32 label, address target) external;

}


pragma solidity ^0.6.0;

interface ENSRegistryOwnerI {

    function owner(bytes32 node) external view returns (address);

}

interface ENSReverseRegistrarI {

    function setName(string calldata name) external returns (bytes32 node);

}


pragma solidity ^0.6.0;

interface ENSAddrResolverI {

    function setAddr(bytes32 node, address a) external;

}


pragma solidity ^0.6.0;








contract CryptostampENSRegistrar is ENSSimpleRegistrarI {

    using SafeMath for uint256;

    address public subdomainControl;
    address public tokenAssignmentControl;

    ENS public ens;
    ENSAddrResolverI public resolver;
    bytes32 public rootNode;

    event SubdomainControlTransferred(address indexed previousSubdomainControl, address indexed newSubdomainControl);
    event TokenAssignmentControlTransferred(address indexed previousTokenAssignmentControl, address indexed newTokenAssignmentControl);
    event DefaultResolverChanged(address indexed previousResolverAddress, address indexed newResolverAddress);
    event Registered(bytes32 indexed label, bytes32 subnode, address indexed target);
    event Unregistered(bytes32 indexed label, bytes32 subnode);
    event Blocked(bytes32 indexed label, bytes32 subnode);

    constructor(address _ensAddress, address _ensResolverAddress, bytes32 _rootNode, address _subdomainControl, address _tokenAssignmentControl)
    public
    {
        require(_ensAddress != address(0), "ENS cannot be the zero address.");
        ens = ENS(_ensAddress);
        require(_ensResolverAddress != address(0), "Resolver cannot be the zero address.");
        resolver = ENSAddrResolverI(_ensResolverAddress);
        rootNode = _rootNode;
        subdomainControl = _subdomainControl;
        require(subdomainControl != address(0), "subdomainControl cannot be the zero address.");
        tokenAssignmentControl = _tokenAssignmentControl;
        require(tokenAssignmentControl != address(0), "tokenAssignmentControl cannot be the zero address.");
    }

    modifier onlySubdomainControl()
    {

        require(msg.sender == subdomainControl, "subdomainControl key required for this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {

        require(msg.sender == tokenAssignmentControl, "tokenAssignmentControl key required for this function.");
        _;
    }


    function transferTokenAssignmentControl(address _newTokenAssignmentControl)
    public
    onlyTokenAssignmentControl
    {

        require(_newTokenAssignmentControl != address(0), "tokenAssignmentControl cannot be the zero address.");
        emit TokenAssignmentControlTransferred(tokenAssignmentControl, _newTokenAssignmentControl);
        tokenAssignmentControl = _newTokenAssignmentControl;
    }

    function transferSubdomainControl(address _newSubdomainControl)
    public
    onlySubdomainControl
    {

        require(_newSubdomainControl != address(0), "subdomainControl cannot be the zero address.");
        emit SubdomainControlTransferred(subdomainControl, _newSubdomainControl);
        subdomainControl = _newSubdomainControl;
    }

    function setDefaultResolver(address _newResolverAddress)
    public
    onlySubdomainControl
    {

        require(_newResolverAddress != address(0), "resolver cannot be the zero address.");
        emit DefaultResolverChanged(address(resolver), _newResolverAddress);
        resolver = ENSAddrResolverI(_newResolverAddress);
    }


    function registerAddr(bytes32 _label, address _target)
    external override
    {

        bytes32 node = keccak256(abi.encodePacked(rootNode, _label));
        address currentOwner = ens.owner(node);

        require(currentOwner == address(0) || currentOwner == msg.sender, "Already registered, but not to caller.");

        emit Registered(_label, node, _target);
        ens.setSubnodeOwner(rootNode, _label, address(this));
        ens.setResolver(node, address(resolver));
        resolver.setAddr(node, _target);
    }

    function unregister(bytes32 _label)
    external
    onlySubdomainControl
    {

        bytes32 node = keccak256(abi.encodePacked(rootNode, _label));
        address currentOwner = ens.owner(node);
        require(currentOwner == address(this), "Not registered.");

        emit Unregistered(_label, node);
        resolver.setAddr(node, address(0));
        ens.setSubnodeOwner(rootNode, _label, address(0));
    }

    function blockRegistration(bytes32 _label)
    external
    onlySubdomainControl
    {

        bytes32 node = keccak256(abi.encodePacked(rootNode, _label));
        address currentOwner = ens.owner(node);
        emit Blocked(_label, node);
        if (currentOwner != address(this)) {
            ens.setSubnodeOwner(rootNode, _label, address(this));
        }
        address existingResolverAddress = ens.resolver(node);
        if (existingResolverAddress != address(0)) {
            ENSAddrResolverI(existingResolverAddress).setAddr(node, address(0));
        }
    }


    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name)
    external
    onlySubdomainControl
    {

       require(_reverseRegistrarAddress != address(0), "need a valid reverse registrar");
       ENSReverseRegistrarI(_reverseRegistrarAddress).setName(_name);
    }


    function rescueToken(address _foreignToken, address _to)
    external
    onlyTokenAssignmentControl
    {

        IERC20 erc20Token = IERC20(_foreignToken);
        erc20Token.transfer(_to, erc20Token.balanceOf(address(this)));
    }

    function approveNFTrescue(IERC721 _foreignNFT, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignNFT.setApprovalForAll(_to, true);
    }

}