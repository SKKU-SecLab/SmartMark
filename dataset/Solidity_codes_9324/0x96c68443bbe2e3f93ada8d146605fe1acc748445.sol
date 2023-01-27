

pragma solidity ^0.4.24;


contract ISaleConfig {


  struct Tokensale {
    uint256 lotId;
    uint256 tokenPriceCHFCent;
  }

  function tokenSupply() public pure returns (uint256);

  function tokensaleLotSupplies() public view returns (uint256[]);


  function tokenizedSharePercent() public pure returns (uint256); 

  function tokenPriceCHF() public pure returns (uint256);


  function minimalCHFInvestment() public pure returns (uint256);

  function maximalCHFInvestment() public pure returns (uint256);


  function tokensalesCount() public view returns (uint256);

  function lotId(uint256 _tokensaleId) public view returns (uint256);

  function tokenPriceCHFCent(uint256 _tokensaleId)
    public view returns (uint256);

}


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract MPSSaleConfig is ISaleConfig, Ownable {


  uint256 constant public TOKEN_SUPPLY = 10 ** 7;
 
  uint256 constant public TOKENSALE_LOT1_SHARE_PERCENT = 5;
  uint256 constant public TOKENSALE_LOT2_SHARE_PERCENT = 95;
  uint256 constant public TOKENIZED_SHARE_PERCENT
  = TOKENSALE_LOT1_SHARE_PERCENT + TOKENSALE_LOT2_SHARE_PERCENT;

  uint256 constant public TOKENSALE_LOT1_SUPPLY
  = TOKEN_SUPPLY * TOKENSALE_LOT1_SHARE_PERCENT / 100;
  uint256 constant public TOKENSALE_LOT2_SUPPLY
  = TOKEN_SUPPLY * TOKENSALE_LOT2_SHARE_PERCENT / 100;

  uint256[] private tokensaleLotSuppliesArray
  = [ TOKENSALE_LOT1_SUPPLY, TOKENSALE_LOT2_SUPPLY ];

  uint256 constant public TOKEN_PRICE_CHF_CENT = 500;

  uint256 constant public MINIMAL_CHF_CENT_INVESTMENT = 10 ** 4;

  uint256 constant public MAXIMAL_CHF_CENT_INVESTMENT = 10 ** 10;

  Tokensale[] public tokensales;

  constructor() public {
    tokensales.push(Tokensale(
      0,
      TOKEN_PRICE_CHF_CENT * 80 / 100
    ));

    tokensales.push(Tokensale(
      0,
      TOKEN_PRICE_CHF_CENT
    ));
  }

  function tokenSupply() public pure returns (uint256) {

    return TOKEN_SUPPLY;
  }

  function tokensaleLotSupplies() public view returns (uint256[]) {

    return tokensaleLotSuppliesArray;
  }

  function tokenizedSharePercent() public pure returns (uint256) {

    return TOKENIZED_SHARE_PERCENT;
  }

  function tokenPriceCHF() public pure returns (uint256) {

    return TOKEN_PRICE_CHF_CENT;
  }

  function minimalCHFInvestment() public pure returns (uint256) {

    return MINIMAL_CHF_CENT_INVESTMENT;
  }

  function maximalCHFInvestment() public pure returns (uint256) {

    return MAXIMAL_CHF_CENT_INVESTMENT;
  }

  function tokensalesCount() public view returns (uint256) {

    return tokensales.length;
  }

  function lotId(uint256 _tokensaleId) public view returns (uint256) {

    return tokensales[_tokensaleId].lotId;
  }

  function tokenPriceCHFCent(uint256 _tokensaleId)
    public view returns (uint256)
  {

    return tokensales[_tokensaleId].tokenPriceCHFCent;
  }
}