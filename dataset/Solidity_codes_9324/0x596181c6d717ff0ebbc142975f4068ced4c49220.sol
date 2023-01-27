
pragma solidity ^0.4.23;

contract ZethrUtils {

  using SafeMath for uint;

  Zethr constant internal              ZETHR = Zethr(0xD48B633045af65fF636F3c6edd744748351E020D);


  uint8 constant public                decimals              = 18;

  uint constant internal               tokenPriceInitial_    = 0.000653 ether;
  uint constant internal               magnitude             = 2**64;

  uint constant internal               icoHardCap            = 250 ether;
  uint constant internal               addressICOLimit       = 1   ether;
  uint constant internal               icoMinBuyIn           = 0.1 finney;
  uint constant internal               icoMaxGasPrice        = 50000000000 wei;

  uint constant internal               MULTIPLIER            = 9615;

  uint constant internal               MIN_ETH_BUYIN         = 0.0001 ether;
  uint constant internal               MIN_TOKEN_SELL_AMOUNT = 0.0001 ether;
  uint constant internal               MIN_TOKEN_TRANSFER    = 1e10;
  uint constant internal               referrer_percentage   = 25;


  function tokensToEthereum_1(uint _tokens, uint tokenSupply)
  public
  view
  returns(uint, uint)
  {

    uint tokensToSellAtICOPrice = 0;
    uint tokensToSellAtVariablePrice = 0;

    uint tokensMintedDuringICO = ZETHR.tokensMintedDuringICO();

    if (tokenSupply <= tokensMintedDuringICO) {
      tokensToSellAtICOPrice = _tokens;

    } else if (tokenSupply > tokensMintedDuringICO && tokenSupply - _tokens >= tokensMintedDuringICO) {
      tokensToSellAtVariablePrice = _tokens;

    } else if (tokenSupply > tokensMintedDuringICO && tokenSupply - _tokens < tokensMintedDuringICO) {
      tokensToSellAtVariablePrice = tokenSupply.sub(tokensMintedDuringICO);
      tokensToSellAtICOPrice      = _tokens.sub(tokensToSellAtVariablePrice);

    } else {
      revert();
    }

    assert(tokensToSellAtVariablePrice + tokensToSellAtICOPrice == _tokens);

    return (tokensToSellAtICOPrice, tokensToSellAtVariablePrice);
  }

  function tokensToEthereum_2(uint tokensToSellAtICOPrice)
  public
  pure
  returns(uint)
  {

    uint ethFromICOPriceTokens = 0;


    if (tokensToSellAtICOPrice != 0) {


      ethFromICOPriceTokens = tokensToSellAtICOPrice.mul(tokenPriceInitial_).div(1e18);
    }

    return ethFromICOPriceTokens;
  }

  function tokensToEthereum_3(uint tokensToSellAtVariablePrice, uint tokenSupply)
  public
  pure
  returns(uint)
  {

    uint ethFromVarPriceTokens = 0;


    if (tokensToSellAtVariablePrice != 0) {


      uint investmentBefore = toPowerOfThreeHalves(tokenSupply.div(MULTIPLIER * 1e6)).mul(2).div(3);
      uint investmentAfter  = toPowerOfThreeHalves((tokenSupply - tokensToSellAtVariablePrice).div(MULTIPLIER * 1e6)).mul(2).div(3);

      ethFromVarPriceTokens = investmentBefore.sub(investmentAfter);
    }

    return ethFromVarPriceTokens;
  }

  function tokensToEthereum_(uint _tokens, uint tokenSupply)
  public
  view
  returns(uint)
  {

    require (_tokens >= MIN_TOKEN_SELL_AMOUNT, "Tried to sell too few tokens.");


    uint tokensToSellAtICOPrice;
    uint tokensToSellAtVariablePrice;

    (tokensToSellAtICOPrice, tokensToSellAtVariablePrice) = tokensToEthereum_1(_tokens, tokenSupply);

    uint ethFromICOPriceTokens = tokensToEthereum_2(tokensToSellAtICOPrice);
    uint ethFromVarPriceTokens = tokensToEthereum_3(tokensToSellAtVariablePrice, tokenSupply);

    uint totalEthReceived = ethFromVarPriceTokens + ethFromICOPriceTokens;

    assert(totalEthReceived > 0);
    return totalEthReceived;
  }


  function toPowerOfThreeHalves(uint x) public pure returns (uint) {

    return sqrt(x**3);
  }

  function toPowerOfTwoThirds(uint x) public pure returns (uint) {

    return cbrt(x**2);
  }

  function sqrt(uint x) public pure returns (uint y) {

    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
  }

  function cbrt(uint x) public pure returns (uint y) {

    uint z = (x + 1) / 3;
    y = x;
    while (z < y) {
      y = z;
      z = (x / (z*z) + 2 * z) / 3;
    }
  }
}


contract Zethr {

  uint public                          stakingRequirement;
  uint public                          tokensMintedDuringICO;
}


library SafeMath {


  function mul(uint a, uint b) internal pure returns (uint) {

    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {

    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {

    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {

    uint c = a + b;
    assert(c >= a);
    return c;
  }
}