
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}//*~~~> MIT
pragma solidity 0.8.7;

interface IRoleProvider {

  function hasTheRole(bytes32 role, address theaddress) external returns(bool);

  function fetchAddress(bytes32 thevar) external returns(address);

  function hasContractRole(address theaddress) external view returns(bool);

}//*~~~> MIT
pragma solidity 0.8.7;

interface IRewardsController {

  function createNftHodler(uint tokenId) external returns (bool);

  function depositERC20Rewards(uint amount, address tokenAddress) external returns(bool);

  function getFee() external view returns(uint);

  function setFee(uint fee) external returns (bool);

  function depositEthRewards(uint reward) external payable returns(bool);

  function createUser(address userAddress) external returns(bool);

  function setUser(bool canClaim, address userAddress) external returns(bool);

}//*~~~> MIT make it better, stronger, faster


pragma solidity  0.8.7;


interface NFT {

  function grantRole(bytes32 role, address account) external;

  function revokeRole(bytes32 role, address account) external;

}
interface MarketMint {

  function setDeployAmnt(uint deplyAmnt) external;

  function setNewRedemption(uint redeemAmount, address contractAdd) external;

  function resetRedemptionToken(uint64 redeemAmount, address contractAdd) external;

}
interface RoleProvider is IRoleProvider {

  function setMarketMintAdd(address newmintAdd) external returns(bool);

  function setNftAdd(address newnftAdd) external returns(bool);

  function setOffersAdd(address newoffAdd) external returns(bool);

  function setTradesAdd(address newtradAdd) external returns(bool);

  function setBidsAdd(address newbidsAdd) external returns(bool);

  function setRwdsAdd(address newrwdsAdd) external returns(bool);

  function setProxyRoleAddress(address newrole) external returns(bool);

  function setOwnerProxyAdd(address newproxyAdd) external returns(bool);

  function setPhunkyAdd(address newphunky) external returns(bool);

  function setDevSigAddress(address newsig) external returns(bool);

  function setMarketAdd(address newmrktAdd) external returns(bool);

}

contract OwnerProxy is ReentrancyGuard {

  bytes32 public constant REWARDS = keccak256("REWARDS");
  
  bytes32 public constant BIDS = keccak256("BIDS");
  
  bytes32 public constant OFFERS = keccak256("OFFERS");
  
  bytes32 public constant TRADES = keccak256("TRADES");

  bytes32 public constant NFTADD = keccak256("NFT");

  bytes32 public constant MINT = keccak256("MINT");

  bytes32 public constant MARKET = keccak256("MARKET");

  bytes32 public constant PROXY = keccak256("PROXY");

  address public roleAdd;

  bytes32 public constant PROXY_ROLE = keccak256("PROXY_ROLE"); 
  bytes32 public constant DEV = keccak256("DEV");
  modifier hasAdmin(){

    require(RoleProvider(roleAdd).hasTheRole(PROXY_ROLE, msg.sender), "DOES NOT HAVE ADMIN ROLE");
    _;
  }
  modifier hasDevAdmin(){

    require(RoleProvider(roleAdd).hasTheRole(DEV, msg.sender), "DOES NOT HAVE DEV ROLE");
    _;
  }

  constructor(address role){
    roleAdd = role;
  }

  function setFee(uint newFee) public hasAdmin returns (bool) {

    address rewardsAdd = RoleProvider(roleAdd).fetchAddress(REWARDS);
    IRewardsController(rewardsAdd).setFee(newFee);
    return true;
  }

  function setMarketAdd(address mrktAdd) hasDevAdmin public returns(bool){

    RoleProvider(roleAdd).setMarketAdd(mrktAdd);
    return true;
  }
  function setNftAdd(address nft) hasDevAdmin public returns(bool){

    RoleProvider(roleAdd).setNftAdd(nft);
    return true;
  }
  function setMarketMintAdd(address mintAdd) hasDevAdmin public returns(bool){

    RoleProvider(roleAdd).setMarketMintAdd(mintAdd);
    return true;
  }
  function setOffersAdd(address offAdd) hasDevAdmin public returns(bool){

    RoleProvider(roleAdd).setOffersAdd(offAdd);
    return true;
  }
  function setTradesAdd(address tradAdd) hasDevAdmin public returns(bool){

    RoleProvider(roleAdd).setTradesAdd(tradAdd);
    return true;
  }
  function setBidsAdd(address bidsAdd) hasDevAdmin public returns(bool){

    RoleProvider(roleAdd).setBidsAdd(bidsAdd);
    return true;
  }
  function setRwdsAdd(address rwdsAdd) hasDevAdmin public returns(bool){

    RoleProvider(roleAdd).setRwdsAdd(rwdsAdd);
    return true;
  }
  function setRoleAdd(address role) hasDevAdmin public returns(bool){

    roleAdd = role;
    return true;
  }

  function setProxyRole(address sig) hasDevAdmin public returns(bool){

    RoleProvider(roleAdd).setProxyRoleAddress(sig);
    return true;
  }
  
  function setNewMintRedemption(uint redeemAmount, address contractAdd) hasAdmin public returns(bool){

    address marketMintAdd = RoleProvider(roleAdd).fetchAddress(MINT);
    MarketMint(marketMintAdd).setNewRedemption(redeemAmount, contractAdd);
    return true;
  }
  function resetMintRedemptionToken(uint64 redeemAmount, address contractAdd) hasAdmin public returns(bool){

    address marketMintAdd = RoleProvider(roleAdd).fetchAddress(MINT);
    MarketMint(marketMintAdd).resetRedemptionToken(redeemAmount, contractAdd);
    return true;
  }
  function setMintDeployAmnt(uint dplyAmnt) hasAdmin public returns(bool){

    address marketMintAdd = RoleProvider(roleAdd).fetchAddress(MINT);
    MarketMint(marketMintAdd).setDeployAmnt(dplyAmnt);
    return true;
  }

  function grantNFTRoles(bytes32 role, address account) hasDevAdmin public returns(bool) {

    address nftAdd = RoleProvider(roleAdd).fetchAddress(NFTADD);
    NFT(nftAdd).grantRole(role, account);
    return true;
  }
  function revokeNFTRoles(bytes32 role, address account) hasDevAdmin public returns(bool) {

    address nftAdd = RoleProvider(roleAdd).fetchAddress(NFTADD);
    NFT(nftAdd).revokeRole(role, account);
    return true;
  }

  function sendEther(address recipient, uint ethvalue) internal returns (bool){

    (bool success, bytes memory data) = address(recipient).call{value: ethvalue}("");
    return(success);
  }

  event FundsForwarded(uint value, address from, address to);
  receive() external payable {
    require(sendEther(roleAdd, msg.value));
      emit FundsForwarded(msg.value, msg.sender, roleAdd);
  }
}