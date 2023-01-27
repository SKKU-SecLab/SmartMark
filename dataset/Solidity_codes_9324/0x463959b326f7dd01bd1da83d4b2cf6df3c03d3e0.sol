
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

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
}// MIT
pragma solidity >=0.7.6 <=0.8.9;

interface IOracle {

  function price(address[] memory tokenPath, address[] memory quotePools, uint8 fromDecimals, uint32 period) external view returns (uint256);

}// MIT
pragma solidity 0.8.9;

interface ITreasury {

  function isSupportedAsset(address token) external view returns (bool);
  function assetReserveDetails(address token) external view returns (uint256 price, uint256 reserves, uint256 totalReserves, uint256 assetRatioPoints);
  function mint(uint256 amount, address token) external returns (address vault);
  function getVault(address token) external view returns (address);

}// MIT
pragma solidity 0.8.9;

interface IVault {

  function deposit() external;

  function withdraw(address to, uint256 amount) external;

  function vaultBalance() external returns (uint256 reserves);

  function vaultExec() external;

  function reserveAsset() external view returns (address asset);

}// MIT
pragma solidity 0.8.9;


contract ApeTreasury is ITreasury, Ownable, ERC20, ReentrancyGuard {
  using EnumerableSet for EnumerableSet.AddressSet;

  constructor(uint256 startEpoch, address oracle) ERC20("ApeDAO Token", "APE") {
    lastEpoch = startEpoch;
    oracleAddress = oracle;
  }


  address public stakingAddress;
  address public bondAddress;
  address public oracleAddress;

  mapping(address => bool) public canRedeem;
  mapping(address => bool) public isVault;

  struct Asset {
    bool isStable;
    address vault;
    uint256 price;
    uint256 reserveValue;
    address[] quotePools;
    address[] quotePath;
    uint256 assetRatioPoints;
    uint8 decimals;
  }

  EnumerableSet.AddressSet private supportedAsset;
  mapping(address => Asset) public assetDetails;
  uint256 public stableReserves;
  uint256 public totalReserves;

  uint256 public totalAssetRatio;
 
  uint128 public epochAPRTarget;
  uint128 public epochLength = 21600; // 6 Hrs
  uint256 public lastEpoch;

  function isSupportedAsset(address token) public override view returns (bool) {
    return supportedAsset.contains(token);
  }


  function transferFrom(address from, address to, uint256 amount) public override(ERC20) returns (bool) {
    address spender = _msgSender();
    if (spender != stakingAddress) {
      _spendAllowance(from, spender, amount);
    }
    _transfer(from, to, amount);
    return true;
  }
 

  function setRedeemStatus(address _account, bool _status) public onlyOwner {
    canRedeem[_account] = _status;
  }

  function setStakingAddress(address _stakingAddress) public onlyOwner {
    stakingAddress = _stakingAddress;
  }
  
  function setOracleAddress(address _oracleAddress) public onlyOwner {
    oracleAddress = _oracleAddress;
  }

  function setBondAddress(address _bondAddress) public onlyOwner {
    bondAddress = _bondAddress;
  }

  function addAsset(address _token, bool _isStable, address _vault, address[] memory _quotePools, address[] memory _quotePath, uint256 _ratioPts, uint8 _decimals) public onlyOwner {
    require(_token != address(0), "ApeTreasury: Token address is 0");
    require(_ratioPts > 0, "ApeTreasury: Ratio value must be > 0");
    require(isSupportedAsset(_token) == false, "ApeTreasury: Asset already added");
    require(_isStable || _quotePath.length == _quotePools.length + 1, "ApeTreasury: Invalid pool path lengths");
    if (_vault != address(0)) {
      isVault[_vault] = true;
    }
    uint256 price = 0;
    if (_isStable) {
      require(_decimals <= 18, "ApeTreasury: Max stable decimals is 18");
      price = 1e18 / (10 ** _decimals);
    }
    supportedAsset.add(_token);
    totalAssetRatio = totalAssetRatio + _ratioPts;
    assetDetails[_token] = Asset(_isStable, _vault, price, 0, _quotePools, _quotePath, _ratioPts, _decimals);
  }

  function setEpochAPRTarget(uint128 target) public onlyOwner {
    epochAPRTarget = target;
  }

  function setAssetRatio(address token, uint256 points) public onlyOwner {
    require(isSupportedAsset(token) == true, "ApeTreasury: Asset not supported");
    totalAssetRatio = totalAssetRatio - assetDetails[token].assetRatioPoints + points;
    assetDetails[token].assetRatioPoints = points; 
  }


  function mint(uint256 apeAmount, address token) external returns (address) {
    require(msg.sender == bondAddress, "ApeTreasury: Only bond can mint");
    require(isSupportedAsset(token) == true, "ApeTreasury: Asset not supported");
    Asset storage asset = assetDetails[token];
    uint256 value;
    uint256 balance;
    if (asset.vault == address(0)) {
      balance = IERC20(token).balanceOf(address(this));
    } else {
      IVault(asset.vault).deposit();
      balance = IVault(asset.vault).vaultBalance();
    } 
    if (asset.isStable == true) {
      value = asset.price * balance;
      stableReserves = stableReserves - asset.reserveValue;
      stableReserves = stableReserves + value;
    } else {
      value = (asset.price * balance) / (10 ** asset.decimals);
    }
    totalReserves = totalReserves - asset.reserveValue;
    totalReserves = totalReserves + value;
    asset.reserveValue = value;
    require(totalSupply() + apeAmount <= stableReserves, "ApeTreasury: Insufficent backing");
    _mint(msg.sender, apeAmount);
    return asset.vault == address(0) ? address(this) : asset.vault;
  }

  function getVault(address token) external view returns (address) {
    Asset storage asset = assetDetails[token];
    return asset.vault == address(0) ? address(this) : asset.vault;
  }


  function rebase() public {
    require(block.timestamp >= lastEpoch + epochLength, "ApeTreasury: To early for rebase");
    _updatePrices();
    uint256 _totalSupply = totalSupply();
    uint256 stakedSupply = balanceOf(stakingAddress);
    uint256 targetAmount = (stakedSupply * epochAPRTarget) / 100000;
    if (_totalSupply + targetAmount <= stableReserves) {
      _mint(stakingAddress, targetAmount);
    } else {
      _mint(stakingAddress, stableReserves - _totalSupply);
    }
    lastEpoch = block.timestamp;
  }


  function assetReserveDetails(address token) public view returns (uint256 price, uint256 reserves, uint256 _totalReserves, uint256 assetRatio) {
    Asset storage asset = assetDetails[token];
    price = asset.isStable ? 1e18 / asset.price : asset.price;
    reserves = asset.reserveValue;
    _totalReserves = totalReserves;
    assetRatio = (asset.assetRatioPoints * 100000) / totalAssetRatio;
  }

  function _updatePrices() internal {
    uint256 length = supportedAsset.length();
    for (uint i; i < length; i++) {
      updateAssetPrice(supportedAsset.at(i)); 
    }
  }
  
  uint256 public lastPriceUpdate;

  function updatePrices() public {
    require(lastPriceUpdate + 3600 <= block.timestamp, "ApeTreasury: To early for price update");
    lastPriceUpdate = block.timestamp;
    _updatePrices();
  }

  function updateAssetPrice(address token) internal {
    require(isSupportedAsset(token) == true, "ApeTreasury: Asset not supported");
    Asset storage asset = assetDetails[token];
    uint256 value;
    uint256 balance = asset.vault == address(0) ? IERC20(token).balanceOf(address(this)) : IVault(asset.vault).vaultBalance();
    if (asset.isStable == true) {
      value = asset.price * balance;
      stableReserves = stableReserves - asset.reserveValue;
      stableReserves = stableReserves + value;
    } else {
      try IOracle(oracleAddress).price(asset.quotePath, asset.quotePools, asset.decimals, 3600) returns (uint256 price) {
        asset.price = price;
        value = (price * balance) / (10 ** asset.decimals);
      } catch (bytes memory) {
        uint256 price = IOracle(oracleAddress).price(asset.quotePath, asset.quotePools, asset.decimals, 1);
        asset.price = price;
        value = (price * balance) / (10 ** asset.decimals);
      }
    }
    totalReserves = totalReserves - asset.reserveValue;
    totalReserves = totalReserves + value;
    asset.reserveValue = value;
  }

  function setAssetVault(address token, address _vault) external onlyOwner {
    require(isSupportedAsset(token) == true, "ApeTreasury: Asset not supported");
    Asset storage asset = assetDetails[token];
    require(_vault != asset.vault, "ApeTreasury: Vault already set");
    
    if (_vault == address(0)) {
      IVault(asset.vault).withdraw(address(this), IVault(asset.vault).vaultBalance());
    } else if (asset.vault == address(0)) {
      uint256 treasuryBalance = IERC20(token).balanceOf(address(this));
      IERC20(token).transfer(_vault, treasuryBalance);
      IVault(_vault).deposit();
    } else {
      IVault(asset.vault).withdraw(_vault, IVault(asset.vault).vaultBalance());
      IVault(_vault).deposit();
    }
    asset.vault = _vault;
    updateAssetPrice(token);
  }

  function updateReserves(address token) internal {
    Asset storage asset = assetDetails[token];
    uint256 value;
    uint256 balance = asset.vault == address(0) ? IERC20(token).balanceOf(address(this)) : IVault(asset.vault).vaultBalance();
    if (asset.isStable == true) {
      value = asset.price * balance;
      stableReserves = stableReserves - asset.reserveValue;
      stableReserves = stableReserves + value;
    } else {
      value = (asset.price * balance) / (10 ** asset.decimals);
    }
    totalReserves = totalReserves - asset.reserveValue;
    totalReserves = totalReserves + value;
    asset.reserveValue = value;
  }

  struct Call {
    address target;
    bytes callData;
  }

  function convertAssets(Call[] calldata calls) external onlyOwner nonReentrant {
    _updatePrices();
    uint256 startReserves = totalReserves;
    for(uint256 i = 0; i < calls.length; i++) {
      (bool success, bytes memory data) = calls[i].target.call(calls[i].callData);
      require(success, string(abi.encodePacked("ApeTreasury: Convert multicall failed, ", data)));
    }
    uint256 length = supportedAsset.length();
    for (uint i; i < length; i++) {
      updateReserves(supportedAsset.at(i)); 
    }
    require(startReserves >= totalSupply(), "ApeTreasury: Excessive stable convert");
    require(totalReserves >= (startReserves * 99) / 100, "ApeTreasury: Convert lost < 1%");
  }

  function redeem(address[] memory tokens, uint256[] memory tokenAmounts) external {
    require(canRedeem[msg.sender], "ApeTreasury: No redeem auth");
    require(tokens.length == tokenAmounts.length, "ApeTreasury: Invalid data");
    uint256 stableValue;
    uint256 totalValue;
    uint256 apeAmount;
    for (uint i = 0; i < tokens.length; i++) {
      Asset storage asset = assetDetails[tokens[i]];
      if (asset.isStable == true) {
        stableValue = stableValue + (asset.price * tokenAmounts[i]);
        totalValue = totalValue + (asset.price * tokenAmounts[i]);
      } else {
        totalValue = totalValue + ((asset.price * tokenAmounts[i]) / (10 ** asset.decimals));
      }
    }

    if (stableValue == totalValue) {
      apeAmount = (totalValue * totalSupply()) / stableReserves;
    } else {
      apeAmount =  (totalValue * totalSupply()) / totalReserves;
      require((apeAmount * stableReserves) / totalSupply() >= stableValue, "ApeTreasury: Stable ratio too high");
    }

    for (uint i = 0; i < tokens.length; i++) {
      Asset storage asset = assetDetails[tokens[i]];
      if (asset.vault == address(0)) {
        IERC20(tokens[i]).transfer(msg.sender, tokenAmounts[i]);
      } else {
        IVault(asset.vault).withdraw(msg.sender, tokenAmounts[i]);
      }
      updateReserves(tokens[i]);
    }
    _burn(msg.sender, apeAmount);
  }

}