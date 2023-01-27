
pragma solidity 0.8.4;

interface Erc20 {

  function decimals() external returns (uint8);

}

interface CErc20 {

	function exchangeRateCurrent() external returns (uint256);

  function underlying() external returns (address);

}

pragma solidity 0.8.4;


library Hash {

  bytes32 constant internal DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

  bytes32 constant internal PERMIT_TYPEHASH = 0x80772249b4aef1688b30651778f4249b05cb73b517d98482439b9d8999b30602;

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

  function permit(address o, address s, uint256 a, uint256 n, uint256 d) internal pure returns (bytes32) {

    return keccak256(abi.encode(PERMIT_TYPEHASH, o, s, a, n, d));
  }
}

pragma solidity 0.8.4;

interface IPErc20 {

    function balanceOf(address a) external view returns (uint256);


    function transfer(address r, uint256 a) external returns (bool);


    function allowance(address o, address s) external view returns (uint256);


    function approve(address s, uint256 a) external returns (bool);


    function transferFrom(address s, address r, uint256 a) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity 0.8.4;


contract PErc20 is IPErc20 {

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;

    uint8 public decimals;
    uint256 public totalSupply;
    string public name; // NOTE: cannot make strings immutable
    string public symbol; // NOTE: see above

    constructor (string memory n, string memory s, uint8 d) {
        name = n;
        symbol = s;
        decimals = d;
    }

    function balanceOf(address a) public view virtual override returns (uint256) {

        return balances[a];
    }

    function transfer(address r, uint256 a) public virtual override returns (bool) {

        _transfer(msg.sender, r, a);
        return true;
    }

    function allowance(address o, address s) public view virtual override returns (uint256) {

        return allowances[o][s];
    }

    function approve(address s, uint256 a) public virtual override returns (bool) {

        _approve(msg.sender, s, a);
        return true;
    }

    function transferFrom(address s, address r, uint256 a) public virtual override returns (bool) {

        _transfer(s, r, a);

        uint256 currentAllowance = allowances[s][msg.sender];
        require(currentAllowance >= a, "erc20 transfer amount exceeds allowance");
        _approve(s, msg.sender, currentAllowance - a);

        return true;
    }

    function increaseAllowance(address s, uint256 a) public virtual returns (bool) {

        _approve(msg.sender, s, allowances[msg.sender][s] + a);
        return true;
    }

    function decreaseAllowance(address s, uint256 a) public virtual returns (bool) {

        uint256 currentAllowance = allowances[msg.sender][s];
        require(currentAllowance >= a, "erc20 decreased allowance below zero");
        _approve(msg.sender, s, currentAllowance - a);

        return true;
    }

    function _transfer(address s, address r, uint256 a) internal virtual {

        require(s != address(0), "erc20 transfer from the zero address");
        require(r != address(0), "erc20 transfer to the zero address");

        uint256 senderBalance = balances[s];
        require(senderBalance >= a, "erc20 transfer amount exceeds balance");
        balances[s] = senderBalance - a;
        balances[r] += a;

        emit Transfer(s, r, a);
    }

    function _mint(address r, uint256 a) internal virtual {

        require(r != address(0), "erc20 mint to the zero address");

        totalSupply += a;
        balances[r] += a;
        emit Transfer(address(0), r, a);
    }

    function _burn(address o, uint256 a) internal virtual {

        require(o != address(0), "erc20 burn from the zero address");

        uint256 accountBalance = balances[o];
        require(accountBalance >= a, "erc20 burn amount exceeds balance");
        balances[o] = accountBalance - a;
        totalSupply -= a;

        emit Transfer(o, address(0), a);
    }

    function _approve(address o, address s, uint256 a) internal virtual {

        require(o != address(0), "erc20 approve from the zero address");
        require(s != address(0), "erc20 approve to the zero address");

        allowances[o][s] = a;
        emit Approval(o, s, a);
    }
}
pragma solidity 0.8.4;

interface IErc2612 {

    function permit(address o, address spender, uint256 a, uint256 d, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address o) external view returns (uint256);

}

pragma solidity 0.8.4;


contract Erc2612 is PErc20, IErc2612 {

  mapping (address => uint256) public override nonces;

  bytes32 public immutable domain;

  constructor(string memory n, string memory s, uint8 d) PErc20(n, s, d) {
    domain = Hash.domain(n, '1', block.chainid, address(this));
  }

  function permit(address o, address spender, uint256 a, uint256 d, uint8 v, bytes32 r, bytes32 s) public virtual override {

    require(d >= block.timestamp, 'erc2612 expired deadline');

    bytes32 hashStruct = Hash.permit(o, spender, a, nonces[o]++, d);
    bytes32 hash = Hash.message(domain, hashStruct); 
    address signer = ecrecover(hash, v, r, s);

    require(signer != address(0) && signer == o, 'erc2612 invalid signature');
    _approve(o, spender, a);
  }
}

pragma solidity 0.8.4;


interface IZcToken is IPErc20 {

    function mint(address, uint256) external returns(bool);


    function burn(address, uint256) external returns(bool);

}


pragma solidity 0.8.4;


contract ZcToken is Erc2612, IZcToken {

  address public immutable admin;
  address public immutable underlying;
  uint256 public immutable maturity;

  constructor(address u, uint256 m, string memory n, string memory s, uint8 d) Erc2612(n, s, d) {
    admin = msg.sender;  
    underlying = u;
    maturity = m;
  }
  
  function burn(address f, uint256 a) external onlyAdmin(admin) override returns(bool) {

      _burn(f, a);
      return true;
  }

  function mint(address t, uint256 a) external onlyAdmin(admin) override returns(bool) {

      _mint(t, a);
      return true;
  }

  modifier onlyAdmin(address a) {

    require(msg.sender == a, 'sender must be admin');
    _;
  }
}

pragma solidity 0.8.4;


contract VaultTracker {

  struct Vault {
    uint256 notional;
    uint256 redeemable;
    uint256 exchangeRate;
  }

  mapping(address => Vault) public vaults;

  address public immutable admin;
  address public immutable cTokenAddr;
  address public immutable swivel;
  uint256 public immutable maturity;
  uint256 public maturityRate;

  constructor(uint256 m, address c, address s) {
    admin = msg.sender;
    maturity = m;
    cTokenAddr = c;
    swivel = s;

    vaults[s] = Vault({
      notional: 0,
      redeemable: 0,
      exchangeRate: CErc20(c).exchangeRateCurrent()
    });
  }

  function addNotional(address o, uint256 a) external authorized(admin) returns (bool) {

    uint256 exchangeRate = CErc20(cTokenAddr).exchangeRateCurrent();

    Vault memory vlt = vaults[o];

    if (vlt.notional > 0) {
      uint256 yield;

      if (maturityRate > 0) { // Calculate marginal interest
        yield = ((maturityRate * 1e26) / vlt.exchangeRate) - 1e26;
      } else {
        yield = ((exchangeRate * 1e26) / vlt.exchangeRate) - 1e26;
      }

      uint256 interest = (yield * vlt.notional) / 1e26;
      vlt.redeemable += interest;
      vlt.notional += a;
    } else {
      vlt.notional = a;
    }

    vlt.exchangeRate = exchangeRate;
    vaults[o] = vlt;

    return true;
  }

  function removeNotional(address o, uint256 a) external authorized(admin) returns (bool) {


    Vault memory vlt = vaults[o];

    require(vlt.notional >= a, "amount exceeds vault balance");

    uint256 yield;
    uint256 exchangeRate = CErc20(cTokenAddr).exchangeRateCurrent();

    if (maturityRate > 0) { // Calculate marginal interest
      yield = ((maturityRate * 1e26) / vlt.exchangeRate) - 1e26;
    } else {
      yield = ((exchangeRate * 1e26) / vlt.exchangeRate) - 1e26;
    }

    uint256 interest = (yield * vlt.notional) / 1e26;
    vlt.redeemable += interest;
    vlt.notional -= a;
    vlt.exchangeRate = exchangeRate;

    vaults[o] = vlt;

    return true;
  }

  function redeemInterest(address o) external authorized(admin) returns (uint256) {


    Vault memory vlt = vaults[o];

    uint256 redeemable = vlt.redeemable;
    uint256 yield;
    uint256 exchangeRate = CErc20(cTokenAddr).exchangeRateCurrent();

    if (maturityRate > 0) { // Calculate marginal interest
      yield = ((maturityRate * 1e26) / vlt.exchangeRate) - 1e26;
    } else {
      yield = ((exchangeRate * 1e26) / vlt.exchangeRate) - 1e26;
    }

    uint256 interest = (yield * vlt.notional) / 1e26;

    vlt.exchangeRate = exchangeRate;
    vlt.redeemable = 0;

    vaults[o] = vlt;

    return (redeemable + interest);
  }

  function matureVault(uint256 c) external authorized(admin) returns (bool) {

    maturityRate = c;
    return true;
  }

  function transferNotionalFrom(address f, address t, uint256 a) external authorized(admin) returns (bool) {

    require(f != t, 'cannot transfer notional to self');

    Vault memory from = vaults[f];
    Vault memory to = vaults[t];

    require(from.notional >= a, "amount exceeds available balance");

    uint256 yield;
    uint256 exchangeRate = CErc20(cTokenAddr).exchangeRateCurrent();

    if (maturityRate > 0) { 
      yield = ((maturityRate * 1e26) / from.exchangeRate) - 1e26;
    } else {
      yield = ((exchangeRate * 1e26) / from.exchangeRate) - 1e26;
    }

    uint256 interest = (yield * from.notional) / 1e26;
    from.redeemable += interest;
    from.notional -= a;
    from.exchangeRate = exchangeRate;

    vaults[f] = from;

    if (to.notional > 0) {
      if (maturityRate > 0) { 
        yield = ((maturityRate * 1e26) / to.exchangeRate) - 1e26;
      } else {
        yield = ((exchangeRate * 1e26) / to.exchangeRate) - 1e26;
      }

      uint256 newVaultInterest = (yield * to.notional) / 1e26;
      to.redeemable += newVaultInterest;
      to.notional += a;
    } else {
      to.notional = a;
    }

    to.exchangeRate = exchangeRate;
    vaults[t] = to;

    return true;
  }

  function transferNotionalFee(address f, uint256 a) external authorized(admin) returns(bool) {

    Vault memory oVault = vaults[f];
    Vault memory sVault = vaults[swivel];

    oVault.notional -= a;

    uint256 exchangeRate = CErc20(cTokenAddr).exchangeRateCurrent();
    uint256 yield;

    if (sVault.exchangeRate != exchangeRate) {
      if (maturityRate > 0) { 
          yield = ((maturityRate * 1e26) / sVault.exchangeRate) - 1e26;
      } else {
          yield = ((exchangeRate * 1e26) / sVault.exchangeRate) - 1e26;
      }
      uint256 interest = (yield * sVault.notional) / 1e26;
      sVault.redeemable += interest;
      sVault.exchangeRate = exchangeRate;
    }
    sVault.notional += a;
    vaults[swivel] = sVault;
    vaults[f] = oVault;
    return true;
  }

  function balancesOf(address o) external view returns (uint256, uint256) {

    Vault memory vault = vaults[o];
    return (vault.notional, vault.redeemable);
  }

  modifier authorized(address a) {

    require(msg.sender == a, 'sender must be authorized');
    _;
  }
}

pragma solidity 0.8.4;


contract MarketPlace {

  struct Market {
    address cTokenAddr;
    address zcTokenAddr;
    address vaultAddr;
    uint256 maturityRate;
  }

  mapping (address => mapping (uint256 => Market)) public markets;

  address public admin;
  address public swivel;
  bool public paused;

  event Create(address indexed underlying, uint256 indexed maturity, address cToken, address zcToken, address vaultTracker);
  event Mature(address indexed underlying, uint256 indexed maturity, uint256 maturityRate, uint256 matured);
  event RedeemZcToken(address indexed underlying, uint256 indexed maturity, address indexed sender, uint256 amount);
  event RedeemVaultInterest(address indexed underlying, uint256 indexed maturity, address indexed sender);
  event CustodialInitiate(address indexed underlying, uint256 indexed maturity, address zcTarget, address nTarget, uint256 amount);
  event CustodialExit(address indexed underlying, uint256 indexed maturity, address zcTarget, address nTarget, uint256 amount);
  event P2pZcTokenExchange(address indexed underlying, uint256 indexed maturity, address from, address to, uint256 amount);
  event P2pVaultExchange(address indexed underlying, uint256 indexed maturity, address from, address to, uint256 amount);
  event TransferVaultNotional(address indexed underlying, uint256 indexed maturity, address from, address to, uint256 amount);

  constructor() {
    admin = msg.sender;
  }

  function setSwivelAddress(address s) external authorized(admin) returns (bool) {

    require(swivel == address(0), 'swivel contract address already set');
    swivel = s;
    return true;
  }

  function transferAdmin(address a) external authorized(admin) returns (bool) {

    admin = a;
    return true;
  }

  function createMarket(
    uint256 m,
    address c,
    string memory n,
    string memory s
  ) external authorized(admin) unpaused() returns (bool) {

    address swivelAddr = swivel;
    require(swivelAddr != address(0), 'swivel contract address not set');

    address underAddr = CErc20(c).underlying();
    require(markets[underAddr][m].vaultAddr == address(0), 'market already exists');

    uint8 decimals = Erc20(underAddr).decimals();
    address zcTokenAddr = address(new ZcToken(underAddr, m, n, s, decimals));
    address vaultAddr = address(new VaultTracker(m, c, swivelAddr));
    markets[underAddr][m] = Market(c, zcTokenAddr, vaultAddr, 0);

    emit Create(underAddr, m, c, zcTokenAddr, vaultAddr);

    return true;
  }

  function matureMarket(address u, uint256 m) public unpaused() returns (bool) {

    Market memory mkt = markets[u][m];

    require(mkt.maturityRate == 0, 'market already matured');
    require(block.timestamp >= m, "maturity not reached");

    uint256 currentExchangeRate = CErc20(mkt.cTokenAddr).exchangeRateCurrent();
    markets[u][m].maturityRate = currentExchangeRate;

    require(VaultTracker(mkt.vaultAddr).matureVault(currentExchangeRate), 'mature vault failed');

    emit Mature(u, m, currentExchangeRate, block.timestamp);

    return true;
  }

  function mintZcTokenAddingNotional(address u, uint256 m, address t, uint256 a) external authorized(swivel) unpaused() returns (bool) {

    Market memory mkt = markets[u][m];
    require(ZcToken(mkt.zcTokenAddr).mint(t, a), 'mint zcToken failed');
    require(VaultTracker(mkt.vaultAddr).addNotional(t, a), 'add notional failed');
    
    return true;
  }

  function burnZcTokenRemovingNotional(address u, uint256 m, address t, uint256 a) external authorized(swivel) unpaused() returns(bool) {

    Market memory mkt = markets[u][m];
    require(ZcToken(mkt.zcTokenAddr).burn(t, a), 'burn failed');
    require(VaultTracker(mkt.vaultAddr).removeNotional(t, a), 'remove notional failed');
    
    return true;
  }

  function redeemZcToken(address u, uint256 m, address t, uint256 a) external authorized(swivel) unpaused() returns (uint256) {

    Market memory mkt = markets[u][m];

    if (mkt.maturityRate == 0) {
      require(matureMarket(u, m), 'failed to mature the market');
    }

    require(ZcToken(mkt.zcTokenAddr).burn(t, a), 'could not burn');

    emit RedeemZcToken(u, m, t, a);

    if (mkt.maturityRate == 0) {
      return a;
    } else { 
      return calculateReturn(u, m, a);
    }
  }

  function redeemVaultInterest(address u, uint256 m, address t) external authorized(swivel) unpaused() returns (uint256) {

    uint256 interest = VaultTracker(markets[u][m].vaultAddr).redeemInterest(t);

    emit RedeemVaultInterest(u, m, t);

    return interest;
  }

  function calculateReturn(address u, uint256 m, uint256 a) internal returns (uint256) {

    Market memory mkt = markets[u][m];
    uint256 rate = CErc20(mkt.cTokenAddr).exchangeRateCurrent();

    return (a * rate) / mkt.maturityRate;
  }

  function cTokenAddress(address u, uint256 m) external view returns (address) {

    return markets[u][m].cTokenAddr;
  }

  function custodialInitiate(address u, uint256 m, address z, address n, uint256 a) external authorized(swivel) unpaused() returns (bool) {

    Market memory mkt = markets[u][m];
    require(ZcToken(mkt.zcTokenAddr).mint(z, a), 'mint failed');
    require(VaultTracker(mkt.vaultAddr).addNotional(n, a), 'add notional failed');
    emit CustodialInitiate(u, m, z, n, a);
    return true;
  }

  function custodialExit(address u, uint256 m, address z, address n, uint256 a) external authorized(swivel) unpaused() returns (bool) {

    Market memory mkt = markets[u][m];
    require(ZcToken(mkt.zcTokenAddr).burn(z, a), 'burn failed');
    require(VaultTracker(mkt.vaultAddr).removeNotional(n, a), 'remove notional failed');
    emit CustodialExit(u, m, z, n, a);
    return true;
  }

  function p2pZcTokenExchange(address u, uint256 m, address f, address t, uint256 a) external authorized(swivel) unpaused() returns (bool) {

    Market memory mkt = markets[u][m];
    require(ZcToken(mkt.zcTokenAddr).burn(f, a), 'zcToken burn failed');
    require(ZcToken(mkt.zcTokenAddr).mint(t, a), 'zcToken mint failed');
    emit P2pZcTokenExchange(u, m, f, t, a);
    return true;
  }

  function p2pVaultExchange(address u, uint256 m, address f, address t, uint256 a) external authorized(swivel) unpaused() returns (bool) {

    require(VaultTracker(markets[u][m].vaultAddr).transferNotionalFrom(f, t, a), 'transfer notional failed');
    emit P2pVaultExchange(u, m, f, t, a);
    return true;
  }

  function transferVaultNotional(address u, uint256 m, address t, uint256 a) external unpaused() returns (bool) {

    require(VaultTracker(markets[u][m].vaultAddr).transferNotionalFrom(msg.sender, t, a), 'vault transfer failed');
    emit TransferVaultNotional(u, m, msg.sender, t, a);
    return true;
  }

  function transferVaultNotionalFee(address u, uint256 m, address f, uint256 a) external authorized(swivel) returns (bool) {

    VaultTracker(markets[u][m].vaultAddr).transferNotionalFee(f, a);
    return true;
  }

  function pause(bool b) external authorized(admin) returns (bool) {

    paused = b;
    return true;
  }

  modifier authorized(address a) {

    require(msg.sender == a, 'sender must be authorized');
    _;
  }

  modifier unpaused() {

    require(!paused, 'markets are paused');
    _;
  }
}
