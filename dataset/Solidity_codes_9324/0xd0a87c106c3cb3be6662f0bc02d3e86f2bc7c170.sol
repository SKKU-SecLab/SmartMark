
pragma solidity 0.5.6;

interface XcertMutable // is Xcert
{

  
  function updateTokenImprint(
    uint256 _tokenId,
    bytes32 _imprint
  )
    external;


}

library SafeMath
{


  string constant OVERFLOW = "008001";
  string constant SUBTRAHEND_GREATER_THEN_MINUEND = "008002";
  string constant DIVISION_BY_ZERO = "008003";

  function mul(
    uint256 _factor1,
    uint256 _factor2
  )
    internal
    pure
    returns (uint256 product)
  {

    if (_factor1 == 0)
    {
      return 0;
    }

    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2, OVERFLOW);
  }

  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {

    require(_divisor > 0, DIVISION_BY_ZERO);
    quotient = _dividend / _divisor;
  }

  function sub(
    uint256 _minuend,
    uint256 _subtrahend
  )
    internal
    pure
    returns (uint256 difference)
  {

    require(_subtrahend <= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);
    difference = _minuend - _subtrahend;
  }

  function add(
    uint256 _addend1,
    uint256 _addend2
  )
    internal
    pure
    returns (uint256 sum)
  {

    sum = _addend1 + _addend2;
    require(sum >= _addend1, OVERFLOW);
  }

  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder) 
  {

    require(_divisor != 0, DIVISION_BY_ZERO);
    remainder = _dividend % _divisor;
  }

}

contract Abilitable
{

  using SafeMath for uint;

  string constant NOT_AUTHORIZED = "017001";
  string constant CANNOT_REVOKE_OWN_SUPER_ABILITY = "017002";
  string constant INVALID_INPUT = "017003";

  uint8 constant SUPER_ABILITY = 1;

  mapping(address => uint256) public addressToAbility;

  event GrantAbilities(
    address indexed _target,
    uint256 indexed _abilities
  );

  event RevokeAbilities(
    address indexed _target,
    uint256 indexed _abilities
  );

  modifier hasAbilities(
    uint256 _abilities
  ) 
  {

    require(_abilities > 0, INVALID_INPUT);
    require(
      addressToAbility[msg.sender] & _abilities == _abilities,
      NOT_AUTHORIZED
    );
    _;
  }

  constructor()
    public
  {
    addressToAbility[msg.sender] = SUPER_ABILITY;
    emit GrantAbilities(msg.sender, SUPER_ABILITY);
  }

  function grantAbilities(
    address _target,
    uint256 _abilities
  )
    external
    hasAbilities(SUPER_ABILITY)
  {

    addressToAbility[_target] |= _abilities;
    emit GrantAbilities(_target, _abilities);
  }

  function revokeAbilities(
    address _target,
    uint256 _abilities,
    bool _allowSuperRevoke
  )
    external
    hasAbilities(SUPER_ABILITY)
  {

    if (!_allowSuperRevoke && msg.sender == _target)
    {
      require((_abilities & 1) == 0, CANNOT_REVOKE_OWN_SUPER_ABILITY);
    }
    addressToAbility[_target] &= ~_abilities;
    emit RevokeAbilities(_target, _abilities);
  }

  function isAble(
    address _target,
    uint256 _abilities
  )
    external
    view
    returns (bool)
  {

    require(_abilities > 0, INVALID_INPUT);
    return (addressToAbility[_target] & _abilities) == _abilities;
  }
  
}

contract XcertUpdateProxy is
  Abilitable
{


  uint8 constant ABILITY_TO_EXECUTE = 2;

  function update(
    address _xcert,
    uint256 _id,
    bytes32 _imprint
  )
    external
    hasAbilities(ABILITY_TO_EXECUTE)
  {

    XcertMutable(_xcert).updateTokenImprint(_id, _imprint);
  }

}