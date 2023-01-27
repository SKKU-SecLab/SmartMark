
pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity 0.7.6;


contract Ownable
{

  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner()
  {

    require(isOwner(), "!owner");
    _;
  }

  constructor()
  {
    _owner = msg.sender;

    emit OwnershipTransferred(address(0), msg.sender);
  }

  function owner() public view returns (address)
  {

    return _owner;
  }

  function isOwner() public view returns (bool)
  {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner
  {

    emit OwnershipTransferred(_owner, address(0));

    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner
  {

    require(newOwner != address(0), "0 addy");

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;
  }
}// MIT
pragma solidity 0.7.6;




interface ITokenManager
{

  function isWhitelisted(address token) external view returns (bool);


  function isStableToken(address token) external view returns (bool);


  function isDynamicToken(address token) external view returns (bool);


  function isBothStable(address tokenA, address tokenB) external view returns (bool);


  function isBothWhitelisted(address tokenA, address tokenB) external view returns (bool);

}

contract TokenManager is ITokenManager, Ownable
{

  using SafeMath for uint256;


  address[] private _stableTokens;
  address[] private _dynamicTokens;
  address[] private _whitelistedTokens;

  uint256 private _tokenID;
  uint256 private _stableTokenID;
  uint256 private _dynamicTokenID;
  mapping(address => uint256) private _tokenIDOf;
  mapping(address => bool) private _whitelistedToken;
  mapping(address => bool) private _stableToken;
  mapping(address => uint256) private _stableTokenIDOf;
  mapping(address => bool) private _dynamicToken;
  mapping(address => uint256) private _dynamicTokenIDOf;


  constructor ()
  {
    _handleAddition(0x6B175474E89094C44Da98b954EedeAC495271d0F, false);
    _handleAddition(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, false);

    _handleAddition(0x111111111117dC0aa78b770fA6A738034120C302, false);
    _handleAddition(0xD46bA6D942050d489DBd938a2C909A5d5039A161, false);
    _handleAddition(0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C, false);
    _handleAddition(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9, false);
    _handleAddition(0xa117000000f279D81A1D3cc75430fAA017FA5A2e, false);
    _handleAddition(0xba100000625a3754423978a60c9317c58a424e3D, false);
    _handleAddition(0xBA11D00c5f74255f56a5E366F4F77f5A186d7f55, false);
    _handleAddition(0x0D8775F648430679A709E98d2b0Cb6250d2887EF, false);
    _handleAddition(0xc00e94Cb662C3520282E6f5717214004A7f26888, false);
    _handleAddition(0x2ba592F78dB6436527729929AAf6c908497cB200, false);
    _handleAddition(0xA0b73E1Ff0B80914AB6fe0444E65848C4C34450b, false);
    _handleAddition(0xD533a949740bb3306d119CC777fa900bA034cd52, false);
    _handleAddition(0xF629cBd94d3791C9250152BD8dfBDF380E2a3B9c, false);
    _handleAddition(0xc944E90C64B2c07662A292be6244BDf05Cda44a7, false);
    _handleAddition(0xdd974D5C2e2928deA5F71b9825b8b646686BD200, false);
    _handleAddition(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44, false);
    _handleAddition(0x514910771AF9Ca656af840dff83E8264EcF986CA, false);
    _handleAddition(0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD, false);
    _handleAddition(0x0F5D2fB29fb7d3CFeE444a200298f468908cC942, false);
    _handleAddition(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2, false);
    _handleAddition(0x408e41876cCCDC0F92210600ef50372656052a38, false);
    _handleAddition(0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F, false);

    _handleAddition(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51, false);
    _handleAddition(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51, true);

    _handleAddition(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2, false);

    _handleAddition(0x0000000000085d4780B73119b644AE5ecd22b376, false);
    _handleAddition(0x0000000000085d4780B73119b644AE5ecd22b376, true);

    _handleAddition(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984, false);

    _handleAddition(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, false);
    _handleAddition(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, true);

    _handleAddition(0xdAC17F958D2ee523a2206206994597C13D831ec7, false);
    _handleAddition(0xdAC17F958D2ee523a2206206994597C13D831ec7, true);

    _handleAddition(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, false);
    _handleAddition(0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e, false);
    _handleAddition(0xE41d2489571d322189246DaFA5ebDe1F4699F498, false);
  }


  function isWhitelisted(address token) public view override returns (bool)
  {

    return token != address(0) && _whitelistedToken[token];
  }

  function isStableToken(address token) public view override returns (bool)
  {

    return token != address(0) && _stableToken[token];
  }

  function isDynamicToken(address token) public view override returns (bool)
  {

    return token != address(0) && _dynamicToken[token];
  }

  function isBothStable(address tokenA, address tokenB) external view override returns (bool)
  {

    return _stableToken[tokenA] && _stableToken[tokenB];
  }

  function isBothWhitelisted(address tokenA, address tokenB) external view override returns (bool)
  {

    return _whitelistedToken[tokenA] && _whitelistedToken[tokenB];
  }

  function getDynamicTokens() external view returns (address[] memory)
  {

    return _dynamicTokens;
  }

  function getStableTokens() external view returns (address[] memory)
  {

    return _stableTokens;
  }

  function getWhitelistedTokens() external view returns (address[] memory)
  {

    return _whitelistedTokens;
  }


  function whitelistToken(address token) external onlyOwner
  {

    require(!isWhitelisted(token), "Whitelisted");

    _handleAddition(token, false);
  }

  function whitelistTokens(address[] calldata tokens) external onlyOwner
  {

    for (uint256 i = 0; i < tokens.length; i++)
    {
      if (!isWhitelisted(tokens[i]))
      {
        _handleAddition(tokens[i], false);
      }
    }
  }

  function unwhitelistToken(address token) external onlyOwner
  {

    require(isWhitelisted(token), "!whitelisted");

    _handleRemoval(token, false);

    if (isStableToken(token))
    {
      _handleRemoval(token, true);
    }

    if (isDynamicToken(token))
    {
      _handleDynamicRemoval(token);
    }
  }

  function setAsStableToken(address token) external onlyOwner
  {

    require(!isStableToken(token), "Set");
    require(isWhitelisted(token), "!whitelisted");

    _handleAddition(token, true);
  }

  function unsetAsStableToken(address token) external onlyOwner
  {

    require(isStableToken(token), "!stabletoken");

    _handleRemoval(token, true);
  }

  function setAsDynamicToken(address token) external onlyOwner
  {

    require(!isDynamicToken(token), "Set");
    require(isWhitelisted(token), "!whitelisted");

    _dynamicTokenID = _dynamicTokenID.add(1);
    _dynamicTokenIDOf[token] = _dynamicTokenID;
    _dynamicToken[token] = true;
    _dynamicTokens.push(token);
  }

  function unsetAsDynamicToken(address token) external onlyOwner
  {

    require(isDynamicToken(token), "!dynamic");

    _handleDynamicRemoval(token);
  }


  function _handleAddition(address token, bool forStableToken) private
  {

    if (!forStableToken)
    {
      _tokenID = _tokenID.add(1);
      _tokenIDOf[token] = _tokenID;
      _whitelistedToken[token] = true;
      _whitelistedTokens.push(token);
    }
    else
    {
      _stableTokenID = _stableTokenID.add(1);
      _stableTokenIDOf[token] = _stableTokenID;
      _stableToken[token] = true;
      _stableTokens.push(token);
    }
  }

  function _handleRemoval(address token, bool forStableToken) private
  {

    if (!forStableToken)
    {
      uint256 tokenIndex = _tokenIDOf[token].sub(1);

      _tokenIDOf[token] = 0;
      _whitelistedToken[token] = false;
      delete _whitelistedTokens[tokenIndex];
    }
    else
    {
      uint256 stableTokenIndex = _stableTokenIDOf[token].sub(1);

      _stableTokenIDOf[token] = 0;
      _stableToken[token] = false;
      delete _stableTokens[stableTokenIndex];
    }
  }

  function _handleDynamicRemoval(address token) private
  {

    uint256 dynamicTokenIndex = _dynamicTokenIDOf[token].sub(1);

    _dynamicTokenIDOf[token] = 0;
    _dynamicToken[token] = false;
    delete _dynamicTokens[dynamicTokenIndex];
  }
}