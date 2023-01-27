pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}pragma solidity >=0.5.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}//Unlicense
pragma solidity ^0.8.0;


library CalldataLoader {

  using SafeMath for uint;

  function loadUint8(uint self) pure internal returns (uint x) {

    assembly {
      x := shr(248, calldataload(self))
    }
  }
  function loadUint16(uint self) pure internal returns (uint x) {

    assembly {
      x := shr(240, calldataload(self))
    }
  }
  function loadAddress(uint self) pure internal returns (address x) {

    assembly {
      x := shr(96, calldataload(self)) // 12 * 8 = 96
    }
  }
  function loadTokenFromArray(uint self) pure internal returns (address x) {

    assembly {
      x := shr(96, calldataload(add(73, mul(20, self)))) // 73 = 68 + 5
    }
  }
  function loadVariableUint(uint self, uint len) pure internal returns (uint x) {

    uint extra = uint(32).sub(len) << 3;
    assembly {
      x := shr(extra, calldataload(self))
    }
  }
}//Unlicense
pragma solidity ^0.8.0;

library Addrs {

  address internal constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // ON ETHER OR EVERYWHERE ?
  address internal constant SUSHI_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac; // ON ETHER
}

library Selectors {

  bytes4 internal constant UNISWAP_V2_GETPAIR_SELECTOR = bytes4(keccak256("getPair(address,address)"));
  bytes4 internal constant UNISWAP_V2_GETRESERVES_SELECTOR = bytes4(keccak256("getReserves()"));

  bytes4 internal constant UNISWAP_V2_PAIR_SWAP_SELECTOR = bytes4(keccak256("swap(uint256,uint256,address,bytes)"));

  uint internal constant SLIPPAGE_LIMIT = 200;

  bytes4 internal constant TRANSFER_SELECTOR = bytes4(keccak256("transfer(address,uint256)"));
  bytes4 internal constant TRANSFERFROM_SELECTOR = bytes4(keccak256("transferFrom(address,address,uint256)"));
  bytes4 internal constant BALANCEOF_SELECTOR = bytes4(keccak256("balanceOf(address)"));
}//Unlicense
pragma solidity ^0.8.0;





library CallType_1_lib {

  using SafeMath for uint;
  using CalldataLoader for uint;

  struct CallType_1_vars {
    uint flags;
    uint token_source_ind;
    uint token_target_ind;
    address token_source;
    address token_target;
    uint amount_in_expected;
    uint amount_out_expected;
    uint amount_to_be_sent;
    address v2pair;
    uint amount_out;
    uint minus_source;
    uint plus_target;
  }

  using CallType_1_lib for CallType_1_vars;

  uint internal constant CT_1_FROM_SENDER = 1;
  uint internal constant CT_1_TO_SENDER = 2;
  uint internal constant CT_1_UNISWAP_OR_SUSHISWAP = 4; // false == uniswap, true == sushiswap
  uint internal constant CT_1_SUSHISWAP = 4;

  function load(CallType_1_vars memory self, uint ind, uint tokens_num) internal pure returns (uint new_ind) {

    self.flags = ind.loadUint8();
    ind++;

    self.token_source_ind = ind.loadUint8();// = uint8(data[ind]);
    ind++;
    require(self.token_source_ind < tokens_num, "1SI");
    self.token_source = self.token_source_ind.loadTokenFromArray();

    self.token_target_ind = ind.loadUint8(); //= uint8(data[ind]);
    ind++;
    require(self.token_target_ind < tokens_num, "1TI");
    self.token_target = self.token_target_ind.loadTokenFromArray();

    {
      uint amount_in_len = ind.loadUint8();// = uint(uint8(data[ind]));
      ind++;
      self.amount_in_expected = ind.loadVariableUint(amount_in_len);
      ind += amount_in_len;
    }

    {
      uint amount_out_len = ind.loadUint8();
      ind++;
      self.amount_out_expected = ind.loadVariableUint(amount_out_len);
      ind += amount_out_len;
    }
    return ind;
  }

  function doIt(CallType_1_vars memory self) internal {

    if (self.token_source < self.token_target) {
      self.getUniV2Pair_direct_order();
      self.UniV2CalcAmount1();
      if (self.amount_out == 0) {
        return;
      }
      self.transferToUniV2Pair();
      self.fetchFromUniV2Pair_1();
    } else {
      self.getUniV2Pair_reverse_order();
      self.UniV2CalcAmount0();
      if (self.amount_out == 0) {
        return;
      }
      self.transferToUniV2Pair();
      self.fetchFromUniV2Pair_0();
    }
  }

  function getFactory(CallType_1_vars memory self) internal pure returns(address) {

    address factory;
    uint switcher = self.flags & CT_1_UNISWAP_OR_SUSHISWAP;
    if (switcher == 0) {
      factory = Addrs.UNISWAP_V2_FACTORY;
    } else if (switcher != 0) {
      factory = Addrs.SUSHI_FACTORY;
    } else {
      revert("UOS");
    }
    return factory;
  }

  function getUniV2Pair_direct_order(CallType_1_vars memory self) internal view {

    (bool success, bytes memory res) = self.getFactory().staticcall(abi.encodeWithSelector(Selectors.UNISWAP_V2_GETPAIR_SELECTOR, self.token_source, self.token_target));
    require(success, "1GPDO");
    address v2pair;
    assembly {
      v2pair := mload(add(res, 32))
    }
    require(v2pair != address(0), "1PRDO");
    self.v2pair = v2pair;
  }

  function getUniV2Pair_reverse_order(CallType_1_vars memory self) internal view {

    (bool success, bytes memory res) = self.getFactory().staticcall(abi.encodeWithSelector(Selectors.UNISWAP_V2_GETPAIR_SELECTOR, self.token_target, self.token_source));
    require(success, "1GPRO");
    address v2pair;
    assembly {
      v2pair := mload(add(res, 32))
    }
    require(v2pair != address(0), "1PRRO");
    self.v2pair = v2pair;
  }

  function transferToUniV2Pair(CallType_1_vars memory self) internal {

    if (self.flags & CT_1_FROM_SENDER != 0) {
      self.transferToUniV2Pair_from_sender();
      self.minus_source = 0;
    } else {
      self.transferToUniV2Pair_from_this();
      self.minus_source = self.amount_to_be_sent;
    }
  }

  function transferToUniV2Pair_from_this(CallType_1_vars memory self) internal {

    (bool success, ) = self.token_source.call(abi.encodeWithSelector(Selectors.TRANSFER_SELECTOR, self.v2pair, self.amount_to_be_sent));
    require(success, "1TTUV2");
  }

  function transferToUniV2Pair_from_sender(CallType_1_vars memory self) internal {

    (bool success, ) = self.token_source.call(abi.encodeWithSelector(Selectors.TRANSFERFROM_SELECTOR, msg.sender, self.v2pair, self.amount_to_be_sent));
    require(success, "1TTUV2F");
  }

  function fetchFromUniV2Pair_0(CallType_1_vars memory self) internal {

    if (self.flags & CT_1_TO_SENDER != 0) {
      self.fetchFromUniV2Pair_0_to_sender();
      self.plus_target = 0;
    } else {
      self.fetchFromUniV2Pair_0_to_this();
      self.plus_target = self.amount_out;
    }
  }

  function fetchFromUniV2Pair_1(CallType_1_vars memory self) internal {

    if (self.flags & CT_1_TO_SENDER != 0) {
      self.fetchFromUniV2Pair_1_to_sender();
      self.plus_target = 0;
    } else {
      self.fetchFromUniV2Pair_1_to_this();
      self.plus_target = self.amount_out;
    }
  }

  function fetchFromUniV2Pair_0_to_this(CallType_1_vars memory self) internal {

    (bool success, ) = self.v2pair.call(abi.encodeWithSelector(Selectors.UNISWAP_V2_PAIR_SWAP_SELECTOR, self.amount_out, 0, address(this), new bytes(0)));
    require(success, "1F0FUV2");
  }

  function fetchFromUniV2Pair_1_to_this(CallType_1_vars memory self) internal {

    (bool success, ) = self.v2pair.call(abi.encodeWithSelector(Selectors.UNISWAP_V2_PAIR_SWAP_SELECTOR, 0, self.amount_out, address(this), new bytes(0)));
    require(success, "1F1FUV2");
  }

  function fetchFromUniV2Pair_0_to_sender(CallType_1_vars memory self) internal {

    (bool success, ) = self.v2pair.call(abi.encodeWithSelector(Selectors.UNISWAP_V2_PAIR_SWAP_SELECTOR, self.amount_out, 0, msg.sender, new bytes(0)));
    require(success, "1F0FUV2L");
  }

  function fetchFromUniV2Pair_1_to_sender(CallType_1_vars memory self) internal {

    (bool success, ) = self.v2pair.call(abi.encodeWithSelector(Selectors.UNISWAP_V2_PAIR_SWAP_SELECTOR, 0, self.amount_out, msg.sender, new bytes(0)));
    require(success, "1F1FUV2L");
  }

  function UniV2CalcAmount0(CallType_1_vars memory self) view internal {

    (bool success, bytes memory res) = self.v2pair.staticcall(abi.encodeWithSelector(Selectors.UNISWAP_V2_GETRESERVES_SELECTOR));
    require(success, "1GR0");
    (uint112 reserve_0, uint112 reserve_1, ) = abi.decode(res, (uint112, uint112, uint32));
    self.amount_out = calcUniswapV2Out(reserve_1, reserve_0, self.amount_to_be_sent);
  }

  function UniV2CalcAmount1(CallType_1_vars memory self) view internal {

    (bool success, bytes memory res) = self.v2pair.staticcall(abi.encodeWithSelector(Selectors.UNISWAP_V2_GETRESERVES_SELECTOR));
    require(success, "1GR1");
    (uint112 reserve_0, uint112 reserve_1, ) = abi.decode(res, (uint112, uint112, uint32));
    self.amount_out = calcUniswapV2Out(reserve_0, reserve_1, self.amount_to_be_sent);
  }

  function calcUniswapV2Out(uint r0, uint r1, uint a0) pure private returns (uint a1) {

    uint numer = r1.mul(a0).mul(997);
    uint denom = r0.mul(1000).add(a0.mul(997));
    a1 = numer.div(denom);
  }
}//UNLICENSE
pragma solidity ^0.8.0;





contract ETHRouter_V2 { //is IUniswapV2Callee, IUniswapV3SwapCallback {

  using SafeMath for uint;
  using SafeMath for int;
  using CalldataLoader for uint;
  using CallType_1_lib for CallType_1_lib.CallType_1_vars;

  address public owner;
  uint public constant network = 1;

  uint public constant SLIPPAGE_LIMIT = 200;

  constructor() {
    owner = msg.sender;
  }

  modifier ownerOnly {

    require(owner == msg.sender);
    _;
  }

  function setOwner(address newOwner) external ownerOnly {

    owner = newOwner;
  }

  function exec(bytes calldata data) external returns (uint256) {

    uint ind = 68;// = 0
    {
      uint _network = ind.loadUint16();
      ind += 2;
      require(network == _network, "WRONGNETWORK");
      uint version = ind.loadUint8();
      ind++;
      require(version == 2, "WRONGVERSION");
    }
    uint slippage = ind.loadUint8();
    ind++;
    uint tokens_num = ind.loadUint8();
    ind++;
    ind += tokens_num.mul(20);
    uint[] memory balances = new uint[](tokens_num);
    uint num_of_calls = ind.loadUint8();// = uint8(data[ind]);
    ind++;
    for (uint i = 0; i < num_of_calls; i++) {
      uint calltype = ind.loadUint8();// = uint8(data[ind]);
      ind++;
      if (calltype == 1) { // transfer to univ2-like pair and swap
        CallType_1_lib.CallType_1_vars memory vars;
        ind = vars.load(ind, tokens_num);
        
        if (vars.flags & CallType_1_lib.CT_1_FROM_SENDER != 0) {
          vars.amount_to_be_sent = vars.amount_in_expected;
        } else {
          uint available_amount = balances[vars.token_source_ind];
          {
            uint limit = vars.amount_in_expected.mul(SLIPPAGE_LIMIT.sub(slippage));
            limit = limit.div(SLIPPAGE_LIMIT);
            if (vars.amount_in_expected > 1000) {
              require(available_amount > limit, "1S"); 
            } else {
              if (available_amount == 0) {
                continue; // skip since it's just dust
              }
            }
          }

          vars.amount_to_be_sent = available_amount > vars.amount_in_expected ? vars.amount_in_expected : available_amount;
        }

        vars.doIt();

        balances[vars.token_source_ind] -= vars.minus_source; 
        balances[vars.token_target_ind] += vars.plus_target;
      } else if (calltype == 2) { //transfer funds to msg.sender
        uint token_ind = ind.loadUint8();
        ind++;
        require(token_ind < tokens_num, "2TO");
        address token = token_ind.loadTokenFromArray();
        uint amount_expected;
        {
          uint amount_len = ind.loadUint8();
          ind++;
          amount_expected = ind.loadVariableUint(amount_len);
          ind += amount_len;
        }
        require(balances[token_ind] >= amount_expected.mul(SLIPPAGE_LIMIT.sub(slippage)).div(SLIPPAGE_LIMIT), "2S");
        (bool success, ) = token.call(abi.encodeWithSelector(Selectors.TRANSFER_SELECTOR, msg.sender, balances[token_ind]));
        require(success, "2TR");
        balances[token_ind] = 0; // the order is ok since it is not in storage
      } else if (calltype == 4) { //fetch funds from msg.sender
        uint token_ind = ind.loadUint8();
        ind++;
        require(token_ind < tokens_num, "4TO");
        address token = token_ind.loadTokenFromArray();
        uint amount;
        {
          uint amount_len = ind.loadUint8();
          ind++;
          amount = ind.loadVariableUint(amount_len);
          ind += amount_len;
        }
        (bool success, ) = token.call(abi.encodeWithSelector(Selectors.TRANSFERFROM_SELECTOR, msg.sender, address(this), amount));
        require(success, "4TR");
        balances[token_ind] += amount;
      } else if (calltype == 3) { // uniV2swap just swap
        revert("CT3"); // reserved for future
      } else if (calltype == 0) { // exec
        require(msg.sender == owner, "OWN");
        address addr = ind.loadAddress();
        ind += 20;
        uint len = ind.loadUint16();
        ind += 2;
        uint start = ind.sub(68);
        (bool success, ) = addr.call(data[start : start + len]);
        require(success);
      } else {
        revert("CT");
      }
    }
    return ind;
  }

  function calcUniswapV2Out(uint r0, uint r1, uint a0) pure private returns (uint a1) {

    uint numer = r1.mul(a0).mul(997);
    uint denom = r0.mul(1000).add(a0.mul(997));
    a1 = numer.div(denom);
  }
}