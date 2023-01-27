
pragma solidity >=0.4.22 <0.9.0;

interface ENS {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external ;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns(bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address internal fappablo = 0xD915246cE4430cb893757bC5908990921344F02d; 
    address internal rms = 0xD73250F6c4a1cd2b604D59636edE5D1D3312AF83;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        
    }

    function owners() public view virtual returns (address [2] memory ) {
        return [fappablo,rms];
    }

    modifier onlyOwner() {
        require((owners()[0] == _msgSender()) || (owners()[1] == _msgSender()), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _msgSender();
        if(oldOwner == fappablo){
            fappablo = newOwner;
        }else{
            rms = newOwner;
        }
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity >=0.4.22 <0.9.0;

interface Resolver {

  function supportsInterface(bytes4 interfaceID) external pure returns (bool);

  function addr(bytes32 node) external view returns (address);

  function setAddr(bytes32 node, address addr) external;

  function setText(bytes32 node, string calldata key, string calldata value) external;

  function setContenthash(bytes32 node, bytes calldata hash) external;

  function setAddr(bytes32 node, uint coinType, bytes memory a) external;

}

abstract contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) virtual public;
}

contract SubdomainStore is IERC721Receiver, Ownable, ApproveAndCallFallBack {


  struct Domain {
    string name;
    uint price;
  }

  bytes32 constant internal TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

  address internal xbtc = 0xB6eD7644C69416d67B522e20bC294A9a9B405B31;

  address internal guild = 0x167152A46E8616D4a6892A6AfD8E52F060151C70;

  ENS internal ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

  uint256 internal devFunds = 0;
  uint256 internal guildFunds = 0;

  uint256 internal devShare = 25;
  uint256 internal guildShare = 75;
  
  mapping (bytes32 => Domain) internal domains;
  
  constructor() {
    
  }
  
  function configureDomain(string memory name, uint price) public onlyOwner {

    bytes32 label = keccak256(bytes(name));
    Domain storage domain = domains[label];

    if (keccak256(abi.encodePacked(domain.name)) != label) {
      domain.name = name;
    }

    domain.price = price;
  }

  function setShares(uint256 _devShare, uint256 _guildShare) external onlyOwner {

    require(_devShare+_guildShare==100 && _devShare >= 0 && _guildShare >= 0, "Invalid share values");
    devShare = _devShare;
    guildShare = _guildShare;
  }

  function setResidentAddress(string calldata name, address addr, Resolver resolver) external onlyOwner{  

    bytes32 label = keccak256(bytes(name));
    bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));
    resolver.setAddr(domainNode, addr);
  }

  function setResidentAddress(string calldata name, uint coinType, bytes memory a, Resolver resolver) external onlyOwner{  

    bytes32 label = keccak256(bytes(name));
    bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));
    resolver.setAddr(domainNode, coinType, a);
  }

  function setResidentText(string calldata name, string calldata key, string calldata value, Resolver resolver) external onlyOwner{ 

    bytes32 label = keccak256(bytes(name)); 
    bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));
    resolver.setText(domainNode, key, value);
  }

  function setResidentContenthash(string calldata name, bytes calldata hash, Resolver resolver) external onlyOwner{  

    bytes32 label = keccak256(bytes(name));
    bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));
    resolver.setContenthash(domainNode, hash);
  }
  
  function setResidentResolver(string calldata name, address resolver) external onlyOwner {

    bytes32 label = keccak256(bytes(name));
    bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));
    ens.setResolver(domainNode, resolver);
  }
  
  function doRegistration(bytes32 node, bytes32 label, address subdomainOwner, Resolver resolver) internal {

    ens.setSubnodeOwner(node, label, address(this));

    bytes32 subnode = keccak256(abi.encodePacked(node, label));
    ens.setResolver(subnode, address(resolver));

    resolver.setAddr(subnode, subdomainOwner);

    ens.setOwner(subnode, subdomainOwner);    
  }

  function register(bytes32 label, string memory subdomain, address subdomainOwner, address resolver) public {

    bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));

    bytes32 subdomainLabel = keccak256(bytes(subdomain));

    require(ens.owner(keccak256(abi.encodePacked(domainNode, subdomainLabel))) == address(0), "Subdomain must not be registered already");
    Domain storage domain = domains[label];

    require(keccak256(abi.encodePacked(domain.name)) == label, "Domain must be available for registration");

    require(IERC20(xbtc).transferFrom(subdomainOwner, address(this), domain.price), "User must have paid");

    devFunds = devFunds + (domain.price * devShare / 100);
    guildFunds = guildFunds + (domain.price * guildShare / 100);

    doRegistration(domainNode, subdomainLabel, subdomainOwner, Resolver(resolver));
  }

  function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

    return this.onERC721Received.selector;
  }

  function receiveApproval(address from, uint256, address token, bytes memory data) public override {

    require(token == xbtc, "Must pay in 0xBTC");

    bytes32 label; 
    string memory subdomain;
    address resolver;

    (label, subdomain, resolver) = abi.decode(data, (bytes32, string, address));

    register(label, subdomain, from, resolver);
  }

  function withdrawAndShare() public virtual {

    require(devFunds > 0 || guildFunds > 0 ,'nothing to withdraw');

    uint256 devFee = devFunds;
    devFunds = 0;

    uint256 guildFee = guildFunds;
    guildFunds = 0;

    require(IERC20(xbtc).transfer(fappablo, devFee/2),'transfer failed');
    require(IERC20(xbtc).transfer(rms, devFee/2),'transfer failed');
    require(IERC20(xbtc).transfer(guild, guildFee),'transfer failed');
  }

  function encodeData(bytes32 label, string calldata subdomain, address resolver) external pure returns (bytes memory data) {

    return abi.encode(label, subdomain, resolver);
  }

  function encodeLabel(string calldata label) external pure returns (bytes32 encodedLabel) {

    return keccak256(bytes(label));
  }

  function getPrice (bytes32 label) external view returns (uint256 price){
    Domain storage data = domains[label];
    return data.price;
  }

}