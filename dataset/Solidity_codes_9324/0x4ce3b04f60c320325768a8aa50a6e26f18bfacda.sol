
pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


contract DetailedERC20 is ERC20 {

  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}


contract IBasicMultiToken is ERC20 {

    event Bundle(address indexed who, address indexed beneficiary, uint256 value);
    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);

    ERC20[] public tokens;

    function tokensCount() public view returns(uint256);


    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public;

    function bundle(address _beneficiary, uint256 _amount) public;


    function unbundle(address _beneficiary, uint256 _value) public;

    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public;


    function disableBundling() public;

    function enableBundling() public;

}


contract IMultiToken is IBasicMultiToken {

    event Update();
    event Change(address indexed _fromToken, address indexed _toToken, address indexed _changer, uint256 _amount, uint256 _return);

    mapping(address => uint256) public weights;

    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256 returnAmount);

    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 returnAmount);


    function disableChanges() public;

}


contract IMultiTokenInfo {

    function allTokens(IBasicMultiToken _mtkn) public view returns(ERC20[] _tokens);


    function allBalances(IBasicMultiToken _mtkn) public view returns(uint256[] _balances);


    function allDecimals(IBasicMultiToken _mtkn) public view returns(uint8[] _decimals);


    function allNames(IBasicMultiToken _mtkn) public view returns(bytes32[] _names);


    function allSymbols(IBasicMultiToken _mtkn) public view returns(bytes32[] _symbols);


    function allTokensBalancesDecimalsNamesSymbols(IBasicMultiToken _mtkn) public view returns(
        ERC20[] _tokens,
        uint256[] _balances,
        uint8[] _decimals,
        bytes32[] _names,
        bytes32[] _symbols
        );



    function allWeights(IMultiToken _mtkn) public view returns(uint256[] _weights);


    function allTokensBalancesDecimalsNamesSymbolsWeights(IMultiToken _mtkn) public view returns(
        ERC20[] _tokens,
        uint256[] _balances,
        uint8[] _decimals,
        bytes32[] _names,
        bytes32[] _symbols,
        uint256[] _weights
        );

}


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


library CheckedERC20 {

    using SafeMath for uint;

    function isContract(address addr) internal view returns(bool result) {

        assembly {
            result := gt(extcodesize(addr), 0)
        }
    }

    function handleReturnBool() internal pure returns(bool result) {

        assembly {
            switch returndatasize()
            case 0 { // not a std erc20
                result := 1
            }
            case 32 { // std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function handleReturnBytes32() internal pure returns(bytes32 result) {

        assembly {
            if eq(returndatasize(), 32) { // not a std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            if gt(returndatasize(), 32) { // std erc20
                returndatacopy(0, 64, 32)
                result := mload(0)
            }
            if lt(returndatasize(), 32) { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function asmTransfer(address _token, address _to, uint256 _value) internal returns(bool) {

        require(isContract(_token));
        require(_token.call(bytes4(keccak256("transfer(address,uint256)")), _to, _value));
        return handleReturnBool();
    }

    function asmTransferFrom(address _token, address _from, address _to, uint256 _value) internal returns(bool) {

        require(isContract(_token));
        require(_token.call(bytes4(keccak256("transferFrom(address,address,uint256)")), _from, _to, _value));
        return handleReturnBool();
    }

    function asmApprove(address _token, address _spender, uint256 _value) internal returns(bool) {

        require(isContract(_token));
        require(_token.call(bytes4(keccak256("approve(address,uint256)")), _spender, _value));
        return handleReturnBool();
    }


    function checkedTransfer(ERC20 _token, address _to, uint256 _value) internal {

        if (_value > 0) {
            uint256 balance = _token.balanceOf(this);
            asmTransfer(_token, _to, _value);
            require(_token.balanceOf(this) == balance.sub(_value), "checkedTransfer: Final balance didn't match");
        }
    }

    function checkedTransferFrom(ERC20 _token, address _from, address _to, uint256 _value) internal {

        if (_value > 0) {
            uint256 toBalance = _token.balanceOf(_to);
            asmTransferFrom(_token, _from, _to, _value);
            require(_token.balanceOf(_to) == toBalance.add(_value), "checkedTransfer: Final balance didn't match");
        }
    }


    function asmName(address _token) internal view returns(bytes32) {

        require(isContract(_token));
        require(_token.call(bytes4(keccak256("name()"))));
        return handleReturnBytes32();
    }

    function asmSymbol(address _token) internal view returns(bytes32) {

        require(isContract(_token));
        require(_token.call(bytes4(keccak256("symbol()"))));
        return handleReturnBytes32();
    }
}


contract MultiTokenInfo is IMultiTokenInfo {

    using CheckedERC20 for DetailedERC20;


    function allTokens(IBasicMultiToken _mtkn) public view returns(ERC20[] _tokens) {

        _tokens = new ERC20[](_mtkn.tokensCount());
        for (uint i = 0; i < _tokens.length; i++) {
            _tokens[i] = _mtkn.tokens(i);
        }
    }

    function allBalances(IBasicMultiToken _mtkn) public view returns(uint256[] _balances) {

        _balances = new uint256[](_mtkn.tokensCount());
        for (uint i = 0; i < _balances.length; i++) {
            _balances[i] = _mtkn.tokens(i).balanceOf(_mtkn);
        }
    }

    function allDecimals(IBasicMultiToken _mtkn) public view returns(uint8[] _decimals) {

        _decimals = new uint8[](_mtkn.tokensCount());
        for (uint i = 0; i < _decimals.length; i++) {
            _decimals[i] = DetailedERC20(_mtkn.tokens(i)).decimals();
        }
    }

    function allNames(IBasicMultiToken _mtkn) public view returns(bytes32[] _names) {

        _names = new bytes32[](_mtkn.tokensCount());
        for (uint i = 0; i < _names.length; i++) {
            _names[i] = DetailedERC20(_mtkn.tokens(i)).asmName();
        }
    }

    function allSymbols(IBasicMultiToken _mtkn) public view returns(bytes32[] _symbols) {

        _symbols = new bytes32[](_mtkn.tokensCount());
        for (uint i = 0; i < _symbols.length; i++) {
            _symbols[i] = DetailedERC20(_mtkn.tokens(i)).asmSymbol();
        }
    }

    function allTokensBalancesDecimalsNamesSymbols(IBasicMultiToken _mtkn) public view returns(
        ERC20[] _tokens,
        uint256[] _balances,
        uint8[] _decimals,
        bytes32[] _names,
        bytes32[] _symbols
    ) {

        _tokens = allTokens(_mtkn);
        _balances = allBalances(_mtkn);
        _decimals = allDecimals(_mtkn);
        _names = allNames(_mtkn);
        _symbols = allSymbols(_mtkn);
    }


    function allWeights(IMultiToken _mtkn) public view returns(uint256[] _weights) {

        _weights = new uint256[](_mtkn.tokensCount());
        for (uint i = 0; i < _weights.length; i++) {
            _weights[i] = _mtkn.weights(_mtkn.tokens(i));
        }
    }

    function allTokensBalancesDecimalsNamesSymbolsWeights(IMultiToken _mtkn) public view returns(
        ERC20[] _tokens,
        uint256[] _balances,
        uint8[] _decimals,
        bytes32[] _names,
        bytes32[] _symbols,
        uint256[] _weights
    ) {

        (_tokens, _balances, _decimals, _names, _symbols) = allTokensBalancesDecimalsNamesSymbols(_mtkn);
        _weights = allWeights(_mtkn);
    }
}