
pragma solidity 0.8.4;

interface Erc20 {

	function approve(address, uint256) external returns (bool);

	function transfer(address, uint256) external returns (bool);

	function balanceOf(address) external returns (uint256);

	function transferFrom(address, address, uint256) external returns (bool);

}

interface CErc20 {

	function mint(uint256) external returns (uint256);

	function redeemUnderlying(uint256) external returns (uint256);

}

interface MarketPlace {

  function mintZcTokenAddingNotional(address, uint256, address, uint256) external returns (bool);

  function burnZcTokenRemovingNotional(address, uint256, address, uint256) external returns (bool);

  function redeemZcToken(address, uint256, address, uint256) external returns (uint256);

  function redeemVaultInterest(address, uint256, address) external returns (uint256);

  function cTokenAddress(address, uint256) external returns (address);

  function custodialExit(address, uint256, address, address, uint256) external returns (bool);

  function custodialInitiate(address, uint256, address, address, uint256) external returns (bool);

  function p2pZcTokenExchange(address, uint256, address, address, uint256) external returns (bool);

  function p2pVaultExchange(address, uint256, address, address, uint256) external returns (bool);

  function transferVaultNotionalFee(address, uint256, address, uint256) external returns (bool);

}

pragma solidity 0.8.4;


library Hash {

  struct Order {
    bytes32 key;
    address maker;
    address underlying;
    bool vault;
    bool exit;
    uint256 principal;
    uint256 premium;
    uint256 maturity;
    uint256 expiry;
  }

  bytes32 constant internal DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

  bytes32 constant internal ORDER_TYPEHASH = 0x7ddd38ab5ed1c16b61ca90eeb9579e29da1ba821cf42d8cdef8f30a31a6a4146;

  function domain(string memory n, string memory version, uint256 i, address verifier) internal pure returns (bytes32) {

    bytes32 hash;

    assembly {
      let nameHash := keccak256(add(n, 32), mload(n))
      let versionHash := keccak256(add(version, 32), mload(version))
      let pointer := mload(64)
      mstore(pointer, DOMAIN_TYPEHASH)
      mstore(add(pointer, 32), nameHash)
      mstore(add(pointer, 64), versionHash)
      mstore(add(pointer, 96), i)
      mstore(add(pointer, 128), verifier)
      hash := keccak256(pointer, 160)
    }

    return hash;
  }

  function message(bytes32 d, bytes32 h) internal pure returns (bytes32) {

    bytes32 hash;

    assembly {
      let pointer := mload(64)
      mstore(pointer, 0x1901000000000000000000000000000000000000000000000000000000000000)
      mstore(add(pointer, 2), d)
      mstore(add(pointer, 34), h)
      hash := keccak256(pointer, 66)
    }

    return hash;
  }

  function order(Order calldata o) internal pure returns (bytes32) {

    return keccak256(abi.encode(
      ORDER_TYPEHASH,
      o.key,
      o.maker,
      o.underlying,
      o.vault,
      o.exit,
      o.principal,
      o.premium,
      o.maturity,
      o.expiry
    ));
  }
}

pragma solidity 0.8.4;

library Sig {

  struct Components {
    uint8 v;  
    bytes32 r;
    bytes32 s;
  }

  function recover(bytes32 h, Components calldata c) internal pure returns (address) {

    require(uint256(c.s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, 'invalid signature "s" value');
    require(c.v == 27 || c.v == 28, 'invalid signature "v" value');

    return ecrecover(h, c.v, c.r, c.s);
  }

  function splitAndRecover(bytes32 h, bytes memory sig) internal pure returns (address) {

    (uint8 v, bytes32 r, bytes32 s) = split(sig);

    return ecrecover(h, v, r, s);
  }

  function split(bytes memory sig) internal pure returns (uint8, bytes32, bytes32) {

    require(sig.length == 65, 'invalid signature length');

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    return (v, r, s);
  }
}
pragma solidity 0.8.4;


library Safe {

  function approve(Erc20 e, address t, uint256 a) internal {

    bool result;

    assembly {
      let pointer := mload(0x40)

      mstore(pointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
      mstore(add(pointer, 4), and(t, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
      mstore(add(pointer, 36), a) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

      result := call(gas(), e, 0, pointer, 68, 0, 0)
    }

    require(success(result), "approve failed");
  }

  function transfer(Erc20 e, address t, uint256 a) internal {

    bool result;

    assembly {
      let pointer := mload(0x40)

      mstore(pointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
      mstore(add(pointer, 4), and(t, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
      mstore(add(pointer, 36), a) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

      result := call(gas(), e, 0, pointer, 68, 0, 0)
    }

    require(success(result), "transfer failed");
  }

  function transferFrom(Erc20 e, address f, address t, uint256 a) internal {

    bool result;

    assembly {
      let pointer := mload(0x40)

      mstore(pointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
      mstore(add(pointer, 4), and(f, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
      mstore(add(pointer, 36), and(t, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
      mstore(add(pointer, 68), a) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

      result := call(gas(), e, 0, pointer, 100, 0, 0)
    }

    require(success(result), "transfer from failed");
  }

  function success(bool r) private pure returns (bool) {

    bool result;

    assembly {
      let returnDataSize := returndatasize()

      if iszero(r) {
        returndatacopy(0, 0, returnDataSize)

        revert(0, returnDataSize)
      }

      switch returnDataSize
      case 32 {
        returndatacopy(0, 0, returnDataSize)

        result := iszero(iszero(mload(0)))
      }
      case 0 {
        result := 1
      }
      default {
        result := 0
      }
    }

    return result;
  }
}

pragma solidity 0.8.4;


contract Swivel {

  mapping (bytes32 => bool) public cancelled;
  mapping (bytes32 => uint256) public filled;
  mapping (address => uint256) public withdrawals;

  string constant public NAME = 'Swivel Finance';
  string constant public VERSION = '2.0.0';
  uint256 constant public HOLD = 3 days;
  bytes32 public immutable domain;
  address public immutable marketPlace;
  address public admin;
  uint16 constant public MIN_FEENOMINATOR = 33;
  uint16[4] public feenominators;

  event Cancel (bytes32 indexed key, bytes32 hash);
  event Initiate(bytes32 indexed key, bytes32 hash, address indexed maker, bool vault, bool exit, address indexed sender, uint256 amount, uint256 filled);
  event Exit(bytes32 indexed key, bytes32 hash, address indexed maker, bool vault, bool exit, address indexed sender, uint256 amount, uint256 filled);
  event ScheduleWithdrawal(address indexed token, uint256 hold);
  event BlockWithdrawal(address indexed token);
  event SetFee(uint256 indexed index, uint256 indexed feenominator);

  constructor(address m) {
    admin = msg.sender;
    domain = Hash.domain(NAME, VERSION, block.chainid, address(this));
    marketPlace = m;
    feenominators = [200, 600, 400, 200];
  }


  function initiate(Hash.Order[] calldata o, uint256[] calldata a, Sig.Components[] calldata c) external returns (bool) {

    uint256 len = o.length;
    for (uint256 i; i < len; i++) {
      Hash.Order memory order = o[i];
      if (!order.exit) {
        if (!order.vault) {
          initiateVaultFillingZcTokenInitiate(o[i], a[i], c[i]);
        } else {
          initiateZcTokenFillingVaultInitiate(o[i], a[i], c[i]);
        }
      } else {
        if (!order.vault) {
          initiateZcTokenFillingZcTokenExit(o[i], a[i], c[i]);
        } else {
          initiateVaultFillingVaultExit(o[i], a[i], c[i]);
        }
      }
    }

    return true;
  }

  function initiateVaultFillingZcTokenInitiate(Hash.Order calldata o, uint256 a, Sig.Components calldata c) internal {

    bytes32 hash = validOrderHash(o, c);

    require((a + filled[hash]) <= o.premium, 'taker amount > available volume');
    
    filled[hash] += a;

    Erc20 uToken = Erc20(o.underlying);
    Safe.transferFrom(uToken, msg.sender, o.maker, a);

    uint256 principalFilled = (a * o.principal) / o.premium;
    Safe.transferFrom(uToken, o.maker, address(this), principalFilled);

    MarketPlace mPlace = MarketPlace(marketPlace);
    require(CErc20(mPlace.cTokenAddress(o.underlying, o.maturity)).mint(principalFilled) == 0, 'minting CToken failed');
    require(mPlace.custodialInitiate(o.underlying, o.maturity, o.maker, msg.sender, principalFilled), 'custodial initiate failed');

    uint256 fee = principalFilled / feenominators[2];
    require(mPlace.transferVaultNotionalFee(o.underlying, o.maturity, msg.sender, fee), 'notional fee transfer failed');

    emit Initiate(o.key, hash, o.maker, o.vault, o.exit, msg.sender, a, principalFilled);
  }

  function initiateZcTokenFillingVaultInitiate(Hash.Order calldata o, uint256 a, Sig.Components calldata c) internal {

    bytes32 hash = validOrderHash(o, c);

    require((a + filled[hash]) <= o.principal, 'taker amount > available volume');

    filled[hash] += a;

    Erc20 uToken = Erc20(o.underlying);

    uint256 premiumFilled = (a * o.premium) / o.principal;
    Safe.transferFrom(uToken, o.maker, msg.sender, premiumFilled);

    uint256 fee = premiumFilled / feenominators[0];
    Safe.transferFrom(uToken, msg.sender, address(this), (a + fee));

    MarketPlace mPlace = MarketPlace(marketPlace);
    require(CErc20(mPlace.cTokenAddress(o.underlying, o.maturity)).mint(a) == 0, 'minting CToken Failed');
    require(mPlace.custodialInitiate(o.underlying, o.maturity, msg.sender, o.maker, a), 'custodial initiate failed');

    emit Initiate(o.key, hash, o.maker, o.vault, o.exit, msg.sender, a, premiumFilled);
  }

  function initiateZcTokenFillingZcTokenExit(Hash.Order calldata o, uint256 a, Sig.Components calldata c) internal {

    bytes32 hash = validOrderHash(o, c);

    require((a + filled[hash]) <= o.principal, 'taker amount > available volume');

    filled[hash] += a;

    uint256 premiumFilled = (a * o.premium) / o.principal;

    Erc20 uToken = Erc20(o.underlying);
    Safe.transferFrom(uToken, msg.sender, o.maker, a - premiumFilled);

    uint256 fee = premiumFilled / feenominators[0];
    Safe.transferFrom(uToken, msg.sender, address(this), fee);

    require(MarketPlace(marketPlace).p2pZcTokenExchange(o.underlying, o.maturity, o.maker, msg.sender, a), 'zcToken exchange failed');
            
    emit Initiate(o.key, hash, o.maker, o.vault, o.exit, msg.sender, a, premiumFilled);
  }

  function initiateVaultFillingVaultExit(Hash.Order calldata o, uint256 a, Sig.Components calldata c) internal {

    bytes32 hash = validOrderHash(o, c);

    require((a + filled[hash]) <= o.premium, 'taker amount > available volume');

    filled[hash] += a;

    Safe.transferFrom(Erc20(o.underlying), msg.sender, o.maker, a);

    MarketPlace mPlace = MarketPlace(marketPlace);
    uint256 principalFilled = (a * o.principal) / o.premium;
    require(mPlace.p2pVaultExchange(o.underlying, o.maturity, o.maker, msg.sender, principalFilled), 'vault exchange failed');

    uint256 fee = principalFilled / feenominators[2];
    require(mPlace.transferVaultNotionalFee(o.underlying, o.maturity, msg.sender, fee), "notional fee transfer failed");

    emit Initiate(o.key, hash, o.maker, o.vault, o.exit, msg.sender, a, principalFilled);
  }


  function exit(Hash.Order[] calldata o, uint256[] calldata a, Sig.Components[] calldata c) external returns (bool) {

    uint256 len = o.length;
    for (uint256 i; i < len; i++) {
      Hash.Order memory order = o[i];
      if (!order.exit) {
          if (!order.vault) {
            exitZcTokenFillingZcTokenInitiate(o[i], a[i], c[i]);
          } else {
            exitVaultFillingVaultInitiate(o[i], a[i], c[i]);
          }
      } else {
        if (!order.vault) {
          exitVaultFillingZcTokenExit(o[i], a[i], c[i]);
        } else {
          exitZcTokenFillingVaultExit(o[i], a[i], c[i]);
        }   
      }   
    }

    return true;
  }

  function exitZcTokenFillingZcTokenInitiate(Hash.Order calldata o, uint256 a, Sig.Components calldata c) internal {

    bytes32 hash = validOrderHash(o, c);

    require((a + filled[hash]) <= o.premium, 'taker amount > available volume');

    filled[hash] += a;       

    Erc20 uToken = Erc20(o.underlying);

    uint256 principalFilled = (a * o.principal) / o.premium;
    Safe.transferFrom(uToken, o.maker, msg.sender, principalFilled - a);

    uint256 fee = principalFilled / feenominators[1];
    Safe.transferFrom(uToken, o.maker, address(this), fee);

    require(MarketPlace(marketPlace).p2pZcTokenExchange(o.underlying, o.maturity, msg.sender, o.maker, principalFilled), 'zcToken exchange failed');

    emit Exit(o.key, hash, o.maker, o.vault, o.exit, msg.sender, a, principalFilled);
  }
  
  function exitVaultFillingVaultInitiate(Hash.Order calldata o, uint256 a, Sig.Components calldata c) internal {

    bytes32 hash = validOrderHash(o, c);

    require((a + filled[hash]) <= o.principal, 'taker amount > available volume');
    
    filled[hash] += a;
        
    Erc20 uToken = Erc20(o.underlying);

    uint256 premiumFilled = (a * o.premium) / o.principal;
    Safe.transferFrom(uToken, o.maker, msg.sender, premiumFilled);

    uint256 fee = premiumFilled / feenominators[3];
    Safe.transferFrom(uToken, msg.sender, address(this), fee);

    require(MarketPlace(marketPlace).p2pVaultExchange(o.underlying, o.maturity, msg.sender, o.maker, a), 'vault exchange failed');

    emit Exit(o.key, hash, o.maker, o.vault, o.exit, msg.sender, a, premiumFilled);
  }

  function exitVaultFillingZcTokenExit(Hash.Order calldata o, uint256 a, Sig.Components calldata c) internal {

    bytes32 hash = validOrderHash(o, c);

    require((a + filled[hash]) <= o.principal, 'taker amount > available volume');

    filled[hash] += a;

    MarketPlace mPlace = MarketPlace(marketPlace);
    address cTokenAddr = mPlace.cTokenAddress(o.underlying, o.maturity);
    require((CErc20(cTokenAddr).redeemUnderlying(a) == 0), "compound redemption error");

    Erc20 uToken = Erc20(o.underlying);
    uint256 premiumFilled = (a * o.premium) / o.principal;
    Safe.transfer(uToken, o.maker, a - premiumFilled);

    uint256 fee = premiumFilled / feenominators[3];
    Safe.transfer(uToken, msg.sender, premiumFilled - fee);

    require(mPlace.custodialExit(o.underlying, o.maturity, o.maker, msg.sender, a), 'custodial exit failed');

    emit Exit(o.key, hash, o.maker, o.vault, o.exit, msg.sender, a, premiumFilled);
  }

  function exitZcTokenFillingVaultExit(Hash.Order calldata o, uint256 a, Sig.Components calldata c) internal {

    bytes32 hash = validOrderHash(o, c);

    require((a + filled[hash]) <= o.premium, 'taker amount > available volume');
    
    filled[hash] += a;

    MarketPlace mPlace = MarketPlace(marketPlace);

    address cTokenAddr = mPlace.cTokenAddress(o.underlying, o.maturity);
    uint256 principalFilled = (a * o.principal) / o.premium;
    require((CErc20(cTokenAddr).redeemUnderlying(principalFilled) == 0), "compound redemption error");

    Erc20 uToken = Erc20(o.underlying);
    uint256 fee = principalFilled / feenominators[1];
    Safe.transfer(uToken, msg.sender, principalFilled - a - fee);
    Safe.transfer(uToken, o.maker, a);

    require(mPlace.custodialExit(o.underlying, o.maturity, msg.sender, o.maker, principalFilled), 'custodial exit failed');

    emit Exit(o.key, hash, o.maker, o.vault, o.exit, msg.sender, a, principalFilled);
  }

  function cancel(Hash.Order calldata o, Sig.Components calldata c) external returns (bool) {

    bytes32 hash = validOrderHash(o, c);

    require(msg.sender == o.maker, 'sender must be maker');

    cancelled[hash] = true;

    emit Cancel(o.key, hash);

    return true;
  }


  function transferAdmin(address a) external authorized(admin) returns (bool) {

    admin = a;

    return true;
  }

  function scheduleWithdrawal(address e) external authorized(admin) returns (bool) {

    uint256 when = block.timestamp + HOLD;
    withdrawals[e] = when;

    emit ScheduleWithdrawal(e, when);

    return true;
  }

  function blockWithdrawal(address e) external authorized(admin) returns (bool) {

      withdrawals[e] = 0;

      emit BlockWithdrawal(e);

      return true;
  }

  function withdraw(address e) external authorized(admin) returns (bool) {

    uint256 when = withdrawals[e];
    require (when != 0, 'no withdrawal scheduled');

    require (block.timestamp >= when, 'withdrawal still on hold');

    withdrawals[e] = 0;

    Erc20 token = Erc20(e);
    Safe.transfer(token, admin, token.balanceOf(address(this)));

    return true;
  }

  function setFee(uint16 i, uint16 d) external authorized(admin) returns (bool) {

    require(d >= MIN_FEENOMINATOR, 'fee too high');

    feenominators[i] = d;

    emit SetFee(i, d);

    return true;
  }

  function approveUnderlying(address[] calldata u, address[] calldata c) external authorized(admin) returns (bool) {

    uint256 len = u.length;
    require (len == c.length, 'array length mismatch');

    uint256 max = 2**256 - 1;

    for (uint256 i; i < len; i++) {
      Erc20 uToken = Erc20(u[i]);
      Safe.approve(uToken, c[i], max);
    }

    return true;
  }


  function splitUnderlying(address u, uint256 m, uint256 a) external returns (bool) {

    Erc20 uToken = Erc20(u);
    Safe.transferFrom(uToken, msg.sender, address(this), a);
    MarketPlace mPlace = MarketPlace(marketPlace);
    require(CErc20(mPlace.cTokenAddress(u, m)).mint(a) == 0, 'minting CToken Failed');
    require(mPlace.mintZcTokenAddingNotional(u, m, msg.sender, a), 'mint ZcToken adding Notional failed');

    return true;
  }

  function combineTokens(address u, uint256 m, uint256 a) external returns (bool) {

    MarketPlace mPlace = MarketPlace(marketPlace);
    require(mPlace.burnZcTokenRemovingNotional(u, m, msg.sender, a), 'burn ZcToken removing Notional failed');
    address cTokenAddr = mPlace.cTokenAddress(u, m);
    require((CErc20(cTokenAddr).redeemUnderlying(a) == 0), "compound redemption error");
    Safe.transfer(Erc20(u), msg.sender, a);

    return true;
  }

  function redeemZcToken(address u, uint256 m, uint256 a) external returns (bool) {

    MarketPlace mPlace = MarketPlace(marketPlace);
    uint256 redeemed = mPlace.redeemZcToken(u, m, msg.sender, a);
    require(CErc20(mPlace.cTokenAddress(u, m)).redeemUnderlying(redeemed) == 0, 'compound redemption failed');
    Safe.transfer(Erc20(u), msg.sender, redeemed);

    return true;
  }

  function redeemVaultInterest(address u, uint256 m) external returns (bool) {

    MarketPlace mPlace = MarketPlace(marketPlace);
    uint256 redeemed = mPlace.redeemVaultInterest(u, m, msg.sender);
    require(CErc20(mPlace.cTokenAddress(u, m)).redeemUnderlying(redeemed) == 0, 'compound redemption failed');
    Safe.transfer(Erc20(u), msg.sender, redeemed);

    return true;
  }

  function validOrderHash(Hash.Order calldata o, Sig.Components calldata c) internal view returns (bytes32) {

    bytes32 hash = Hash.order(o);

    require(!cancelled[hash], 'order cancelled');
    require(o.expiry >= block.timestamp, 'order expired');
    require(o.maker == Sig.recover(Hash.message(domain, hash), c), 'invalid signature');

    return hash;
  }

  modifier authorized(address a) {

    require(msg.sender == a, 'sender must be authorized');
    _;
  }
}
