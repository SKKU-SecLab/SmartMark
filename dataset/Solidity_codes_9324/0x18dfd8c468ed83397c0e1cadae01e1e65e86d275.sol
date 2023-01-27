

pragma solidity ^0.4.15;

contract Owned {

  address public ownerA; // Contract owner
  bool    public pausedB;

  function Owned() {

    ownerA = msg.sender;
  }

  modifier IsOwner {

    require(msg.sender == ownerA);
    _;
  }

  modifier IsActive {

    require(!pausedB);
    _;
  }

  event LogOwnerChange(address indexed PreviousOwner, address NewOwner);
  event LogPaused();
  event LogResumed();

  function ChangeOwner(address vNewOwnerA) IsOwner {

    require(vNewOwnerA != address(0)
         && vNewOwnerA != ownerA);
    LogOwnerChange(ownerA, vNewOwnerA);
    ownerA = vNewOwnerA;
  }

  function Pause() IsOwner {

    pausedB = true; // contract has been paused
    LogPaused();
  }

  function Resume() IsOwner {

    pausedB = false; // contract has been resumed
    LogResumed();
  }
} // End Owned contract







contract DSMath {


  function add(uint256 x, uint256 y) constant internal returns (uint256 z) {

    assert((z = x + y) >= x);
  }

  function sub(uint256 x, uint256 y) constant internal returns (uint256 z) {

    assert((z = x - y) <= x);
  }

  function mul(uint256 x, uint256 y) constant internal returns (uint256 z) {

    z = x * y;
    assert(x == 0 || z / x == y);
  }


  function subMaxZero(uint256 x, uint256 y) constant internal returns (uint256 z) {

    if (y > x)
      z = 0;
    else
      z = x - y;
  }
}




contract ERC20Token is Owned, DSMath {

  bool public constant isEIP20Token = true; // Interface declaration
  uint public totalSupply;     // Total tokens minted
  bool public saleInProgressB; // when true stops transfers

  mapping(address => uint) internal iTokensOwnedM;                 // Tokens owned by an account
  mapping(address => mapping (address => uint)) private pAllowedM; // Owner of account approves the transfer of an amount to another account

  event Transfer(address indexed src, address indexed dst, uint wad);

  event Approval(address indexed Sender, address indexed Spender, uint Wad);

  function balanceOf(address guy) public constant returns (uint) {

    return iTokensOwnedM[guy];
  }

  function allowance(address guy, address spender) public constant returns (uint) {

    return pAllowedM[guy][spender];
  }

  modifier IsTransferOK(address src, address dst, uint wad) {

    require(!saleInProgressB          // Sale not in progress
         && !pausedB                  // IsActive
         && iTokensOwnedM[src] >= wad // Source has the tokens available
         && dst != src                // Destination is different from source
         && dst != address(this)      // Not transferring to this token contract
         && dst != ownerA);           // Not transferring to the owner of this contract - the token sale contract
    _;
  }

  function transfer(address dst, uint wad) IsTransferOK(msg.sender, dst, wad) returns (bool) {

    iTokensOwnedM[msg.sender] -= wad; // There is no need to check this for underflow via a sub() call given the IsTransferOK iTokensOwnedM[src] >= wad check
    iTokensOwnedM[dst] = add(iTokensOwnedM[dst], wad);
    Transfer(msg.sender, dst, wad);
    return true;
  }

  function transferFrom(address src, address dst, uint wad) IsTransferOK(src, dst, wad) returns (bool) {

    require(pAllowedM[src][msg.sender] >= wad); // Transfer is approved
    iTokensOwnedM[src]         -= wad; // There is no need to check this for underflow given the require above
    pAllowedM[src][msg.sender] -= wad; // There is no need to check this for underflow given the require above
    iTokensOwnedM[dst] = add(iTokensOwnedM[dst], wad);
    Transfer(src, dst, wad);
    return true;
  }

  function approve(address spender, uint wad) IsActive returns (bool) {

    pAllowedM[msg.sender][spender] = wad;
    Approval(msg.sender, spender, wad);
    return true;
  }
} // End ERC20Token contracts



contract PacioToken is ERC20Token {

  string public constant name   = "Pacio Token";
  string public constant symbol = "PIOE";
  uint8  public constant decimals = 12;
  uint   public tokensIssued;           // Tokens issued - tokens in circulation
  uint   public tokensAvailable;        // Tokens available = total supply less allocated and issued tokens
  uint   public contributors;           // Number of contributors
  uint   public founderTokensAllocated; // Founder tokens allocated
  uint   public founderTokensVested;    // Founder tokens vested. Same as iTokensOwnedM[pFounderToksA] until tokens transferred. Unvested tokens = founderTokensAllocated - founderTokensVested
  uint   public foundationTokensAllocated; // Foundation tokens allocated
  uint   public foundationTokensVested;    // Foundation tokens vested. Same as iTokensOwnedM[pFoundationToksA] until tokens transferred. Unvested tokens = foundationTokensAllocated - foundationTokensVested
  bool   public icoCompleteB;           // Is set to true when both presale and full ICO are complete. Required for vesting of founder and foundation tokens and transfers of PIOEs to PIOs
  address private pFounderToksA;        // Address for Founder tokens issued
  address private pFoundationToksA;     // Address for Foundation tokens issued

  event LogIssue(address indexed Dst, uint Picos);
  event LogSaleCapReached(uint TokensIssued); // not tokensIssued just to avoid compiler Warning: This declaration shadows an existing declaration
  event LogIcoCompleted();
  event LogBurn(address Src, uint Picos);
  event LogDestroy(uint Picos);



  function Initialise(address vNewOwnerA) { // IsOwner c/o the super.ChangeOwner() call

    require(totalSupply == 0);          // can only be called once
    super.ChangeOwner(vNewOwnerA);      // includes an IsOwner check so don't need to repeat it here
    founderTokensAllocated    = 10**20; // 10% or 100 million = 1e20 Picos
    foundationTokensAllocated = 10**20; // 10% or 100 million = 1e20 Picos This call sets tokensAvailable
    totalSupply           = 10**21; // 1 Billion PIOEs    = 1e21 Picos, all minted)
    iTokensOwnedM[ownerA] = 10**21;
    tokensAvailable       = 8*(10**20); // 800 million [String: '800000000000000000000'] s: 1, e: 20, c: [ 8000000 ] }
    Transfer(0x0, ownerA, 10**21); // log event 0x0 from == minting
  }

  function Mint(uint picos) IsOwner {
    totalSupply           = add(totalSupply,           picos);
    iTokensOwnedM[ownerA] = add(iTokensOwnedM[ownerA], picos);
    tokensAvailable = subMaxZero(totalSupply, tokensIssued + founderTokensAllocated + foundationTokensAllocated);
    Transfer(0x0, ownerA, picos); // log event 0x0 from == minting
  }

  function PrepareForSale() IsOwner {
    require(!icoCompleteB); // Cannot start selling again once ICO has been set to completed
    saleInProgressB = true; // stops transfers
  }

  function ChangeOwner(address vNewOwnerA) { // IsOwner c/o the super.ChangeOwner() call
    transfer(vNewOwnerA, iTokensOwnedM[ownerA]); // includes checks
    super.ChangeOwner(vNewOwnerA); // includes an IsOwner check so don't need to repeat it here
  }


  function Issue(address dst, uint picos) IsOwner IsActive returns (bool) {
    require(saleInProgressB      // Sale is in progress
         && iTokensOwnedM[ownerA] >= picos // Owner has the tokens available
         && dst != address(this) // Not issuing to this token contract
         && dst != ownerA);      // Not issuing to the owner of this contract - the token sale contract
    if (iTokensOwnedM[dst] == 0)
      contributors++;
    iTokensOwnedM[ownerA] -= picos; // There is no need to check this for underflow via a sub() call given the iTokensOwnedM[ownerA] >= picos check
    iTokensOwnedM[dst]     = add(iTokensOwnedM[dst], picos);
    tokensIssued           = add(tokensIssued,       picos);
    tokensAvailable    = subMaxZero(tokensAvailable, picos); // subMaxZero() in case a sale goes over, only possible for full ICO, when cap is for all available tokens.
    LogIssue(dst, picos);                                    // If that should happen,may need to mint some more PIOEs to allow founder and foundation vesting to complete.
    return true;
  }

  function SaleCapReached() IsOwner IsActive {
    saleInProgressB = false; // allows transfers
    LogSaleCapReached(tokensIssued);
  }

  function IcoCompleted() IsOwner IsActive {
    require(!icoCompleteB);
    saleInProgressB = false; // allows transfers
    icoCompleteB    = true;
    LogIcoCompleted();
  }

  function SetFFSettings(address vFounderTokensA, address vFoundationTokensA, uint vFounderTokensAllocation, uint vFoundationTokensAllocation) IsOwner {
    if (vFounderTokensA    != address(0)) pFounderToksA    = vFounderTokensA;
    if (vFoundationTokensA != address(0)) pFoundationToksA = vFoundationTokensA;
    if (vFounderTokensAllocation > 0)    assert((founderTokensAllocated    = vFounderTokensAllocation)    >= founderTokensVested);
    if (vFoundationTokensAllocation > 0) assert((foundationTokensAllocated = vFoundationTokensAllocation) >= foundationTokensVested);
    tokensAvailable = totalSupply - founderTokensAllocated - foundationTokensAllocated - tokensIssued;
  }

  function VestFFTokens(uint vFounderTokensVesting, uint vFoundationTokensVesting) IsOwner IsActive {
    require(icoCompleteB); // ICO must be completed before vesting can occur. djh?? Add other time restriction?
    if (vFounderTokensVesting > 0) {
      assert(pFounderToksA != address(0)); // Founders token address must have been set
      assert((founderTokensVested  = add(founderTokensVested,          vFounderTokensVesting)) <= founderTokensAllocated);
      iTokensOwnedM[ownerA]        = sub(iTokensOwnedM[ownerA],        vFounderTokensVesting);
      iTokensOwnedM[pFounderToksA] = add(iTokensOwnedM[pFounderToksA], vFounderTokensVesting);
      LogIssue(pFounderToksA,          vFounderTokensVesting);
      tokensIssued = add(tokensIssued, vFounderTokensVesting);
    }
    if (vFoundationTokensVesting > 0) {
      assert(pFoundationToksA != address(0)); // Foundation token address must have been set
      assert((foundationTokensVested  = add(foundationTokensVested,          vFoundationTokensVesting)) <= foundationTokensAllocated);
      iTokensOwnedM[ownerA]           = sub(iTokensOwnedM[ownerA],           vFoundationTokensVesting);
      iTokensOwnedM[pFoundationToksA] = add(iTokensOwnedM[pFoundationToksA], vFoundationTokensVesting);
      LogIssue(pFoundationToksA,       vFoundationTokensVesting);
      tokensIssued = add(tokensIssued, vFoundationTokensVesting);
    }
  }

  function Burn(address src, uint picos) IsOwner IsActive {
    require(icoCompleteB);
    iTokensOwnedM[src] = subMaxZero(iTokensOwnedM[src], picos);
    tokensIssued       = subMaxZero(tokensIssued, picos);
    totalSupply        = subMaxZero(totalSupply,  picos);
    LogBurn(src, picos);
  }

  function Destroy(uint picos) IsOwner IsActive {
    require(icoCompleteB);
    totalSupply     = subMaxZero(totalSupply,     picos);
    tokensAvailable = subMaxZero(tokensAvailable, picos);
    LogDestroy(picos);
  }

  function() {
    revert(); // reject any attempt to access the token contract other than via the defined methods with their testing for valid access
  }
} // End PacioToken contract