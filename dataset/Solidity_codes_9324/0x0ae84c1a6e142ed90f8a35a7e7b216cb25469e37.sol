
pragma solidity >=0.8.0;





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
}





interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}







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

}






abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}





abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}





interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}





library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}





interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}





abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}








abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}




contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor (address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}









contract ERC20PermissionedMint is ERC20, ERC20Burnable, Owned {

    address public timelock_address;

    address[] public minters_array; // Allowed to mint
    mapping(address => bool) public minters; // Mapping is also used for faster verification


    constructor(
        address _creator_address,
        address _timelock_address,
        string memory _name,
        string memory _symbol
    ) 
    ERC20(_name, _symbol) 
    Owned(_creator_address)
    {
      timelock_address = _timelock_address;
    }



    modifier onlyByOwnGov() {
        require(msg.sender == timelock_address || msg.sender == owner, "Not owner or timelock");
        _;
    }

    modifier onlyMinters() {
       require(minters[msg.sender] == true, "Only minters");
        _;
    } 


    function minter_burn_from(address b_address, uint256 b_amount) public onlyMinters {
        super.burnFrom(b_address, b_amount);
        emit TokenMinterBurned(b_address, msg.sender, b_amount);
    }

    function minter_mint(address m_address, uint256 m_amount) public onlyMinters {
        super._mint(m_address, m_amount);
        emit TokenMinterMinted(msg.sender, m_address, m_amount);
    }

    function addMinter(address minter_address) public onlyByOwnGov {
        require(minter_address != address(0), "Zero address detected");

        require(minters[minter_address] == false, "Address already exists");
        minters[minter_address] = true; 
        minters_array.push(minter_address);

        emit MinterAdded(minter_address);
    }

    function removeMinter(address minter_address) public onlyByOwnGov {
        require(minter_address != address(0), "Zero address detected");
        require(minters[minter_address] == true, "Address nonexistant");
        
        delete minters[minter_address];

        for (uint i = 0; i < minters_array.length; i++){ 
            if (minters_array[i] == minter_address) {
                minters_array[i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
        }

        emit MinterRemoved(minter_address);
    }

    
    event TokenMinterBurned(address indexed from, address indexed to, uint256 amount);
    event TokenMinterMinted(address indexed from, address indexed to, uint256 amount);
    event MinterAdded(address minter_address);
    event MinterRemoved(address minter_address);
}







contract FPI is ERC20PermissionedMint {


    constructor(
      address _creator_address,
      address _timelock_address
    ) 
    ERC20PermissionedMint(_creator_address, _timelock_address, "Frax Price Index", "FPI") 
    {
      _mint(_creator_address, 100000000e18); // Genesis mint
    }

}




interface IFrax {
  function COLLATERAL_RATIO_PAUSER() external view returns (bytes32);
  function DEFAULT_ADMIN_ADDRESS() external view returns (address);
  function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
  function addPool(address pool_address ) external;
  function allowance(address owner, address spender ) external view returns (uint256);
  function approve(address spender, uint256 amount ) external returns (bool);
  function balanceOf(address account ) external view returns (uint256);
  function burn(uint256 amount ) external;
  function burnFrom(address account, uint256 amount ) external;
  function collateral_ratio_paused() external view returns (bool);
  function controller_address() external view returns (address);
  function creator_address() external view returns (address);
  function decimals() external view returns (uint8);
  function decreaseAllowance(address spender, uint256 subtractedValue ) external returns (bool);
  function eth_usd_consumer_address() external view returns (address);
  function eth_usd_price() external view returns (uint256);
  function frax_eth_oracle_address() external view returns (address);
  function frax_info() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);
  function frax_pools(address ) external view returns (bool);
  function frax_pools_array(uint256 ) external view returns (address);
  function frax_price() external view returns (uint256);
  function frax_step() external view returns (uint256);
  function fxs_address() external view returns (address);
  function fxs_eth_oracle_address() external view returns (address);
  function fxs_price() external view returns (uint256);
  function genesis_supply() external view returns (uint256);
  function getRoleAdmin(bytes32 role ) external view returns (bytes32);
  function getRoleMember(bytes32 role, uint256 index ) external view returns (address);
  function getRoleMemberCount(bytes32 role ) external view returns (uint256);
  function globalCollateralValue() external view returns (uint256);
  function global_collateral_ratio() external view returns (uint256);
  function grantRole(bytes32 role, address account ) external;
  function hasRole(bytes32 role, address account ) external view returns (bool);
  function increaseAllowance(address spender, uint256 addedValue ) external returns (bool);
  function last_call_time() external view returns (uint256);
  function minting_fee() external view returns (uint256);
  function name() external view returns (string memory);
  function owner_address() external view returns (address);
  function pool_burn_from(address b_address, uint256 b_amount ) external;
  function pool_mint(address m_address, uint256 m_amount ) external;
  function price_band() external view returns (uint256);
  function price_target() external view returns (uint256);
  function redemption_fee() external view returns (uint256);
  function refreshCollateralRatio() external;
  function refresh_cooldown() external view returns (uint256);
  function removePool(address pool_address ) external;
  function renounceRole(bytes32 role, address account ) external;
  function revokeRole(bytes32 role, address account ) external;
  function setController(address _controller_address ) external;
  function setETHUSDOracle(address _eth_usd_consumer_address ) external;
  function setFRAXEthOracle(address _frax_oracle_addr, address _weth_address ) external;
  function setFXSAddress(address _fxs_address ) external;
  function setFXSEthOracle(address _fxs_oracle_addr, address _weth_address ) external;
  function setFraxStep(uint256 _new_step ) external;
  function setMintingFee(uint256 min_fee ) external;
  function setOwner(address _owner_address ) external;
  function setPriceBand(uint256 _price_band ) external;
  function setPriceTarget(uint256 _new_price_target ) external;
  function setRedemptionFee(uint256 red_fee ) external;
  function setRefreshCooldown(uint256 _new_cooldown ) external;
  function setTimelock(address new_timelock ) external;
  function symbol() external view returns (string memory);
  function timelock_address() external view returns (address);
  function toggleCollateralRatio() external;
  function totalSupply() external view returns (uint256);
  function transfer(address recipient, uint256 amount ) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
  function weth_address() external view returns (address);
}




interface IFraxAMOMinter {
  function FRAX() external view returns(address);
  function FXS() external view returns(address);
  function acceptOwnership() external;
  function addAMO(address amo_address, bool sync_too) external;
  function allAMOAddresses() external view returns(address[] memory);
  function allAMOsLength() external view returns(uint256);
  function amos(address) external view returns(bool);
  function amos_array(uint256) external view returns(address);
  function burnFraxFromAMO(uint256 frax_amount) external;
  function burnFxsFromAMO(uint256 fxs_amount) external;
  function col_idx() external view returns(uint256);
  function collatDollarBalance() external view returns(uint256);
  function collatDollarBalanceStored() external view returns(uint256);
  function collat_borrow_cap() external view returns(int256);
  function collat_borrowed_balances(address) external view returns(int256);
  function collat_borrowed_sum() external view returns(int256);
  function collateral_address() external view returns(address);
  function collateral_token() external view returns(address);
  function correction_offsets_amos(address, uint256) external view returns(int256);
  function custodian_address() external view returns(address);
  function dollarBalances() external view returns(uint256 frax_val_e18, uint256 collat_val_e18);
  function fraxDollarBalanceStored() external view returns(uint256);
  function fraxTrackedAMO(address amo_address) external view returns(int256);
  function fraxTrackedGlobal() external view returns(int256);
  function frax_mint_balances(address) external view returns(int256);
  function frax_mint_cap() external view returns(int256);
  function frax_mint_sum() external view returns(int256);
  function fxs_mint_balances(address) external view returns(int256);
  function fxs_mint_cap() external view returns(int256);
  function fxs_mint_sum() external view returns(int256);
  function giveCollatToAMO(address destination_amo, uint256 collat_amount) external;
  function min_cr() external view returns(uint256);
  function mintFraxForAMO(address destination_amo, uint256 frax_amount) external;
  function mintFxsForAMO(address destination_amo, uint256 fxs_amount) external;
  function missing_decimals() external view returns(uint256);
  function nominateNewOwner(address _owner) external;
  function nominatedOwner() external view returns(address);
  function oldPoolCollectAndGive(address destination_amo) external;
  function oldPoolRedeem(uint256 frax_amount) external;
  function old_pool() external view returns(address);
  function owner() external view returns(address);
  function pool() external view returns(address);
  function receiveCollatFromAMO(uint256 usdc_amount) external;
  function recoverERC20(address tokenAddress, uint256 tokenAmount) external;
  function removeAMO(address amo_address, bool sync_too) external;
  function setAMOCorrectionOffsets(address amo_address, int256 frax_e18_correction, int256 collat_e18_correction) external;
  function setCollatBorrowCap(uint256 _collat_borrow_cap) external;
  function setCustodian(address _custodian_address) external;
  function setFraxMintCap(uint256 _frax_mint_cap) external;
  function setFraxPool(address _pool_address) external;
  function setFxsMintCap(uint256 _fxs_mint_cap) external;
  function setMinimumCollateralRatio(uint256 _min_cr) external;
  function setTimelock(address new_timelock) external;
  function syncDollarBalances() external;
  function timelock_address() external view returns(address);
}




interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}




library BufferChainlink {
  struct buffer {
    bytes buf;
    uint256 capacity;
  }

  function init(buffer memory buf, uint256 capacity) internal pure returns (buffer memory) {
    if (capacity % 32 != 0) {
      capacity += 32 - (capacity % 32);
    }
    buf.capacity = capacity;
    assembly {
      let ptr := mload(0x40)
      mstore(buf, ptr)
      mstore(ptr, 0)
      mstore(0x40, add(32, add(ptr, capacity)))
    }
    return buf;
  }

  function fromBytes(bytes memory b) internal pure returns (buffer memory) {
    buffer memory buf;
    buf.buf = b;
    buf.capacity = b.length;
    return buf;
  }

  function resize(buffer memory buf, uint256 capacity) private pure {
    bytes memory oldbuf = buf.buf;
    init(buf, capacity);
    append(buf, oldbuf);
  }

  function max(uint256 a, uint256 b) private pure returns (uint256) {
    if (a > b) {
      return a;
    }
    return b;
  }

  function truncate(buffer memory buf) internal pure returns (buffer memory) {
    assembly {
      let bufptr := mload(buf)
      mstore(bufptr, 0)
    }
    return buf;
  }

  function write(
    buffer memory buf,
    uint256 off,
    bytes memory data,
    uint256 len
  ) internal pure returns (buffer memory) {
    require(len <= data.length);

    if (off + len > buf.capacity) {
      resize(buf, max(buf.capacity, len + off) * 2);
    }

    uint256 dest;
    uint256 src;
    assembly {
      let bufptr := mload(buf)
      let buflen := mload(bufptr)
      dest := add(add(bufptr, 32), off)
      if gt(add(len, off), buflen) {
        mstore(bufptr, add(len, off))
      }
      src := add(data, 32)
    }

    for (; len >= 32; len -= 32) {
      assembly {
        mstore(dest, mload(src))
      }
      dest += 32;
      src += 32;
    }

    unchecked {
      uint256 mask = (256**(32 - len)) - 1;
      assembly {
        let srcpart := and(mload(src), not(mask))
        let destpart := and(mload(dest), mask)
        mstore(dest, or(destpart, srcpart))
      }
    }

    return buf;
  }

  function append(
    buffer memory buf,
    bytes memory data,
    uint256 len
  ) internal pure returns (buffer memory) {
    return write(buf, buf.buf.length, data, len);
  }

  function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {
    return write(buf, buf.buf.length, data, data.length);
  }

  function writeUint8(
    buffer memory buf,
    uint256 off,
    uint8 data
  ) internal pure returns (buffer memory) {
    if (off >= buf.capacity) {
      resize(buf, buf.capacity * 2);
    }

    assembly {
      let bufptr := mload(buf)
      let buflen := mload(bufptr)
      let dest := add(add(bufptr, off), 32)
      mstore8(dest, data)
      if eq(off, buflen) {
        mstore(bufptr, add(buflen, 1))
      }
    }
    return buf;
  }

  function appendUint8(buffer memory buf, uint8 data) internal pure returns (buffer memory) {
    return writeUint8(buf, buf.buf.length, data);
  }

  function write(
    buffer memory buf,
    uint256 off,
    bytes32 data,
    uint256 len
  ) private pure returns (buffer memory) {
    if (len + off > buf.capacity) {
      resize(buf, (len + off) * 2);
    }

    unchecked {
      uint256 mask = (256**len) - 1;
      data = data >> (8 * (32 - len));
      assembly {
        let bufptr := mload(buf)
        let dest := add(add(bufptr, off), len)
        mstore(dest, or(and(mload(dest), not(mask)), data))
        if gt(add(off, len), mload(bufptr)) {
          mstore(bufptr, add(off, len))
        }
      }
    }
    return buf;
  }

  function writeBytes20(
    buffer memory buf,
    uint256 off,
    bytes20 data
  ) internal pure returns (buffer memory) {
    return write(buf, off, bytes32(data), 20);
  }

  function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {
    return write(buf, buf.buf.length, bytes32(data), 20);
  }

  function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {
    return write(buf, buf.buf.length, data, 32);
  }

  function writeInt(
    buffer memory buf,
    uint256 off,
    uint256 data,
    uint256 len
  ) private pure returns (buffer memory) {
    if (len + off > buf.capacity) {
      resize(buf, (len + off) * 2);
    }

    uint256 mask = (256**len) - 1;
    assembly {
      let bufptr := mload(buf)
      let dest := add(add(bufptr, off), len)
      mstore(dest, or(and(mload(dest), not(mask)), data))
      if gt(add(off, len), mload(bufptr)) {
        mstore(bufptr, add(off, len))
      }
    }
    return buf;
  }

  function appendInt(
    buffer memory buf,
    uint256 data,
    uint256 len
  ) internal pure returns (buffer memory) {
    return writeInt(buf, buf.buf.length, data, len);
  }
}




library CBORChainlink {
  using BufferChainlink for BufferChainlink.buffer;

  uint8 private constant MAJOR_TYPE_INT = 0;
  uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
  uint8 private constant MAJOR_TYPE_BYTES = 2;
  uint8 private constant MAJOR_TYPE_STRING = 3;
  uint8 private constant MAJOR_TYPE_ARRAY = 4;
  uint8 private constant MAJOR_TYPE_MAP = 5;
  uint8 private constant MAJOR_TYPE_TAG = 6;
  uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

  uint8 private constant TAG_TYPE_BIGNUM = 2;
  uint8 private constant TAG_TYPE_NEGATIVE_BIGNUM = 3;

  function encodeFixedNumeric(BufferChainlink.buffer memory buf, uint8 major, uint64 value) private pure {
    if(value <= 23) {
      buf.appendUint8(uint8((major << 5) | value));
    } else if (value <= 0xFF) {
      buf.appendUint8(uint8((major << 5) | 24));
      buf.appendInt(value, 1);
    } else if (value <= 0xFFFF) {
      buf.appendUint8(uint8((major << 5) | 25));
      buf.appendInt(value, 2);
    } else if (value <= 0xFFFFFFFF) {
      buf.appendUint8(uint8((major << 5) | 26));
      buf.appendInt(value, 4);
    } else {
      buf.appendUint8(uint8((major << 5) | 27));
      buf.appendInt(value, 8);
    }
  }

  function encodeIndefiniteLengthType(BufferChainlink.buffer memory buf, uint8 major) private pure {
    buf.appendUint8(uint8((major << 5) | 31));
  }

  function encodeUInt(BufferChainlink.buffer memory buf, uint value) internal pure {
    if(value > 0xFFFFFFFFFFFFFFFF) {
      encodeBigNum(buf, value);
    } else {
      encodeFixedNumeric(buf, MAJOR_TYPE_INT, uint64(value));
    }
  }

  function encodeInt(BufferChainlink.buffer memory buf, int value) internal pure {
    if(value < -0x10000000000000000) {
      encodeSignedBigNum(buf, value);
    } else if(value > 0xFFFFFFFFFFFFFFFF) {
      encodeBigNum(buf, uint(value));
    } else if(value >= 0) {
      encodeFixedNumeric(buf, MAJOR_TYPE_INT, uint64(uint256(value)));
    } else {
      encodeFixedNumeric(buf, MAJOR_TYPE_NEGATIVE_INT, uint64(uint256(-1 - value)));
    }
  }

  function encodeBytes(BufferChainlink.buffer memory buf, bytes memory value) internal pure {
    encodeFixedNumeric(buf, MAJOR_TYPE_BYTES, uint64(value.length));
    buf.append(value);
  }

  function encodeBigNum(BufferChainlink.buffer memory buf, uint value) internal pure {
    buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_BIGNUM));
    encodeBytes(buf, abi.encode(value));
  }

  function encodeSignedBigNum(BufferChainlink.buffer memory buf, int input) internal pure {
    buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_NEGATIVE_BIGNUM));
    encodeBytes(buf, abi.encode(uint256(-1 - input)));
  }

  function encodeString(BufferChainlink.buffer memory buf, string memory value) internal pure {
    encodeFixedNumeric(buf, MAJOR_TYPE_STRING, uint64(bytes(value).length));
    buf.append(bytes(value));
  }

  function startArray(BufferChainlink.buffer memory buf) internal pure {
    encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
  }

  function startMap(BufferChainlink.buffer memory buf) internal pure {
    encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
  }

  function endSequence(BufferChainlink.buffer memory buf) internal pure {
    encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
  }
}





library Chainlink {
  uint256 internal constant defaultBufferSize = 256; // solhint-disable-line const-name-snakecase

  using CBORChainlink for BufferChainlink.buffer;

  struct Request {
    bytes32 id;
    address callbackAddress;
    bytes4 callbackFunctionId;
    uint256 nonce;
    BufferChainlink.buffer buf;
  }

  function initialize(
    Request memory self,
    bytes32 jobId,
    address callbackAddr,
    bytes4 callbackFunc
  ) internal pure returns (Chainlink.Request memory) {
    BufferChainlink.init(self.buf, defaultBufferSize);
    self.id = jobId;
    self.callbackAddress = callbackAddr;
    self.callbackFunctionId = callbackFunc;
    return self;
  }

  function setBuffer(Request memory self, bytes memory data) internal pure {
    BufferChainlink.init(self.buf, data.length);
    BufferChainlink.append(self.buf, data);
  }

  function add(
    Request memory self,
    string memory key,
    string memory value
  ) internal pure {
    self.buf.encodeString(key);
    self.buf.encodeString(value);
  }

  function addBytes(
    Request memory self,
    string memory key,
    bytes memory value
  ) internal pure {
    self.buf.encodeString(key);
    self.buf.encodeBytes(value);
  }

  function addInt(
    Request memory self,
    string memory key,
    int256 value
  ) internal pure {
    self.buf.encodeString(key);
    self.buf.encodeInt(value);
  }

  function addUint(
    Request memory self,
    string memory key,
    uint256 value
  ) internal pure {
    self.buf.encodeString(key);
    self.buf.encodeUInt(value);
  }

  function addStringArray(
    Request memory self,
    string memory key,
    string[] memory values
  ) internal pure {
    self.buf.encodeString(key);
    self.buf.startArray();
    for (uint256 i = 0; i < values.length; i++) {
      self.buf.encodeString(values[i]);
    }
    self.buf.endSequence();
  }
}




interface ENSInterface {
  event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

  event Transfer(bytes32 indexed node, address owner);

  event NewResolver(bytes32 indexed node, address resolver);

  event NewTTL(bytes32 indexed node, uint64 ttl);

  function setSubnodeOwner(
    bytes32 node,
    bytes32 label,
    address owner
  ) external;

  function setResolver(bytes32 node, address resolver) external;

  function setOwner(bytes32 node, address owner) external;

  function setTTL(bytes32 node, uint64 ttl) external;

  function owner(bytes32 node) external view returns (address);

  function resolver(bytes32 node) external view returns (address);

  function ttl(bytes32 node) external view returns (uint64);
}




interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}




interface ChainlinkRequestInterface {
  function oracleRequest(
    address sender,
    uint256 requestPrice,
    bytes32 serviceAgreementID,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 nonce,
    uint256 dataVersion,
    bytes calldata data
  ) external;

  function cancelOracleRequest(
    bytes32 requestId,
    uint256 payment,
    bytes4 callbackFunctionId,
    uint256 expiration
  ) external;
}




interface OracleInterface {
  function fulfillOracleRequest(
    bytes32 requestId,
    uint256 payment,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 expiration,
    bytes32 data
  ) external returns (bool);

  function isAuthorizedSender(address node) external view returns (bool);

  function withdraw(address recipient, uint256 amount) external;

  function withdrawable() external view returns (uint256);
}





interface OperatorInterface is OracleInterface, ChainlinkRequestInterface {
  function operatorRequest(
    address sender,
    uint256 payment,
    bytes32 specId,
    bytes4 callbackFunctionId,
    uint256 nonce,
    uint256 dataVersion,
    bytes calldata data
  ) external;

  function fulfillOracleRequest2(
    bytes32 requestId,
    uint256 payment,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 expiration,
    bytes calldata data
  ) external returns (bool);

  function ownerTransferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function distributeFunds(address payable[] calldata receivers, uint256[] calldata amounts) external payable;

  function getAuthorizedSenders() external returns (address[] memory);

  function setAuthorizedSenders(address[] calldata senders) external;

  function getForwarder() external returns (address);
}




interface PointerInterface {
  function getAddress() external view returns (address);
}




abstract contract ENSResolver_Chainlink {
  function addr(bytes32 node) public view virtual returns (address);
}










abstract contract ChainlinkClient {
  using Chainlink for Chainlink.Request;

  uint256 internal constant LINK_DIVISIBILITY = 10**18;
  uint256 private constant AMOUNT_OVERRIDE = 0;
  address private constant SENDER_OVERRIDE = address(0);
  uint256 private constant ORACLE_ARGS_VERSION = 1;
  uint256 private constant OPERATOR_ARGS_VERSION = 2;
  bytes32 private constant ENS_TOKEN_SUBNAME = keccak256("link");
  bytes32 private constant ENS_ORACLE_SUBNAME = keccak256("oracle");
  address private constant LINK_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

  ENSInterface private s_ens;
  bytes32 private s_ensNode;
  LinkTokenInterface private s_link;
  OperatorInterface private s_oracle;
  uint256 private s_requestCount = 1;
  mapping(bytes32 => address) private s_pendingRequests;

  event ChainlinkRequested(bytes32 indexed id);
  event ChainlinkFulfilled(bytes32 indexed id);
  event ChainlinkCancelled(bytes32 indexed id);

  function buildChainlinkRequest(
    bytes32 specId,
    address callbackAddr,
    bytes4 callbackFunctionSignature
  ) internal pure returns (Chainlink.Request memory) {
    Chainlink.Request memory req;
    return req.initialize(specId, callbackAddr, callbackFunctionSignature);
  }

  function buildOperatorRequest(bytes32 specId, bytes4 callbackFunctionSignature)
    internal
    view
    returns (Chainlink.Request memory)
  {
    Chainlink.Request memory req;
    return req.initialize(specId, address(this), callbackFunctionSignature);
  }

  function sendChainlinkRequest(Chainlink.Request memory req, uint256 payment) internal returns (bytes32) {
    return sendChainlinkRequestTo(address(s_oracle), req, payment);
  }

  function sendChainlinkRequestTo(
    address oracleAddress,
    Chainlink.Request memory req,
    uint256 payment
  ) internal returns (bytes32 requestId) {
    uint256 nonce = s_requestCount;
    s_requestCount = nonce + 1;
    bytes memory encodedRequest = abi.encodeWithSelector(
      ChainlinkRequestInterface.oracleRequest.selector,
      SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
      AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of LINK sent
      req.id,
      address(this),
      req.callbackFunctionId,
      nonce,
      ORACLE_ARGS_VERSION,
      req.buf.buf
    );
    return _rawRequest(oracleAddress, nonce, payment, encodedRequest);
  }

  function sendOperatorRequest(Chainlink.Request memory req, uint256 payment) internal returns (bytes32) {
    return sendOperatorRequestTo(address(s_oracle), req, payment);
  }

  function sendOperatorRequestTo(
    address oracleAddress,
    Chainlink.Request memory req,
    uint256 payment
  ) internal returns (bytes32 requestId) {
    uint256 nonce = s_requestCount;
    s_requestCount = nonce + 1;
    bytes memory encodedRequest = abi.encodeWithSelector(
      OperatorInterface.operatorRequest.selector,
      SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
      AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of LINK sent
      req.id,
      req.callbackFunctionId,
      nonce,
      OPERATOR_ARGS_VERSION,
      req.buf.buf
    );
    return _rawRequest(oracleAddress, nonce, payment, encodedRequest);
  }

  function _rawRequest(
    address oracleAddress,
    uint256 nonce,
    uint256 payment,
    bytes memory encodedRequest
  ) private returns (bytes32 requestId) {
    requestId = keccak256(abi.encodePacked(this, nonce));
    s_pendingRequests[requestId] = oracleAddress;
    emit ChainlinkRequested(requestId);
    require(s_link.transferAndCall(oracleAddress, payment, encodedRequest), "unable to transferAndCall to oracle");
  }

  function cancelChainlinkRequest(
    bytes32 requestId,
    uint256 payment,
    bytes4 callbackFunc,
    uint256 expiration
  ) internal {
    OperatorInterface requested = OperatorInterface(s_pendingRequests[requestId]);
    delete s_pendingRequests[requestId];
    emit ChainlinkCancelled(requestId);
    requested.cancelOracleRequest(requestId, payment, callbackFunc, expiration);
  }

  function getNextRequestCount() internal view returns (uint256) {
    return s_requestCount;
  }

  function setChainlinkOracle(address oracleAddress) internal {
    s_oracle = OperatorInterface(oracleAddress);
  }

  function setChainlinkToken(address linkAddress) internal {
    s_link = LinkTokenInterface(linkAddress);
  }

  function setPublicChainlinkToken() internal {
    setChainlinkToken(PointerInterface(LINK_TOKEN_POINTER).getAddress());
  }

  function chainlinkTokenAddress() internal view returns (address) {
    return address(s_link);
  }

  function chainlinkOracleAddress() internal view returns (address) {
    return address(s_oracle);
  }

  function addChainlinkExternalRequest(address oracleAddress, bytes32 requestId) internal notPendingRequest(requestId) {
    s_pendingRequests[requestId] = oracleAddress;
  }

  function useChainlinkWithENS(address ensAddress, bytes32 node) internal {
    s_ens = ENSInterface(ensAddress);
    s_ensNode = node;
    bytes32 linkSubnode = keccak256(abi.encodePacked(s_ensNode, ENS_TOKEN_SUBNAME));
    ENSResolver_Chainlink resolver = ENSResolver_Chainlink(s_ens.resolver(linkSubnode));
    setChainlinkToken(resolver.addr(linkSubnode));
    updateChainlinkOracleWithENS();
  }

  function updateChainlinkOracleWithENS() internal {
    bytes32 oracleSubnode = keccak256(abi.encodePacked(s_ensNode, ENS_ORACLE_SUBNAME));
    ENSResolver_Chainlink resolver = ENSResolver_Chainlink(s_ens.resolver(oracleSubnode));
    setChainlinkOracle(resolver.addr(oracleSubnode));
  }

  function validateChainlinkCallback(bytes32 requestId)
    internal
    recordChainlinkFulfillment(requestId)
  {

  }

  modifier recordChainlinkFulfillment(bytes32 requestId) {
    require(msg.sender == s_pendingRequests[requestId], "Source must be the oracle of the request");
    delete s_pendingRequests[requestId];
    emit ChainlinkFulfilled(requestId);
    _;
  }

  modifier notPendingRequest(bytes32 requestId) {
    require(s_pendingRequests[requestId] == address(0), "Request is already pending");
    _;
  }
}





library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}





contract BokkyPooBahsDateTimeContract {
    uint public constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint public constant SECONDS_PER_HOUR = 60 * 60;
    uint public constant SECONDS_PER_MINUTE = 60;
    int public constant OFFSET19700101 = 2440588;

    uint public constant DOW_MON = 1;
    uint public constant DOW_TUE = 2;
    uint public constant DOW_WED = 3;
    uint public constant DOW_THU = 4;
    uint public constant DOW_FRI = 5;
    uint public constant DOW_SAT = 6;
    uint public constant DOW_SUN = 7;

    function _now() public view returns (uint timestamp) {
        timestamp = block.timestamp;
    }
    function _nowDateTime() public view returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day, hour, minute, second) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(block.timestamp);
    }
    function _daysFromDate(uint year, uint month, uint day) public pure returns (uint _days) {
        return BokkyPooBahsDateTimeLibrary._daysFromDate(year, month, day);
    }
    function _daysToDate(uint _days) public pure returns (uint year, uint month, uint day) {
        return BokkyPooBahsDateTimeLibrary._daysToDate(_days);
    }
    function timestampFromDate(uint year, uint month, uint day) public pure returns (uint timestamp) {
        return BokkyPooBahsDateTimeLibrary.timestampFromDate(year, month, day);
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp) {
        return BokkyPooBahsDateTimeLibrary.timestampFromDateTime(year, month, day, hour, minute, second);
    }
    function timestampToDate(uint timestamp) public pure returns (uint year, uint month, uint day) {
        (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
    }
    function timestampToDateTime(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day, hour, minute, second) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(timestamp);
    }

    function isValidDate(uint year, uint month, uint day) public pure returns (bool valid) {
        valid = BokkyPooBahsDateTimeLibrary.isValidDate(year, month, day);
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (bool valid) {
        valid = BokkyPooBahsDateTimeLibrary.isValidDateTime(year, month, day, hour, minute, second);
    }
    function isLeapYear(uint timestamp) public pure returns (bool leapYear) {
        leapYear = BokkyPooBahsDateTimeLibrary.isLeapYear(timestamp);
    }
    function _isLeapYear(uint year) public pure returns (bool leapYear) {
        leapYear = BokkyPooBahsDateTimeLibrary._isLeapYear(year);
    }
    function isWeekDay(uint timestamp) public pure returns (bool weekDay) {
        weekDay = BokkyPooBahsDateTimeLibrary.isWeekDay(timestamp);
    }
    function isWeekEnd(uint timestamp) public pure returns (bool weekEnd) {
        weekEnd = BokkyPooBahsDateTimeLibrary.isWeekEnd(timestamp);
    }

    function getDaysInMonth(uint timestamp) public pure returns (uint daysInMonth) {
        daysInMonth = BokkyPooBahsDateTimeLibrary.getDaysInMonth(timestamp);
    }
    function _getDaysInMonth(uint year, uint month) public pure returns (uint daysInMonth) {
        daysInMonth = BokkyPooBahsDateTimeLibrary._getDaysInMonth(year, month);
    }
    function getDayOfWeek(uint timestamp) public pure returns (uint dayOfWeek) {
        dayOfWeek = BokkyPooBahsDateTimeLibrary.getDayOfWeek(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint year) {
        year = BokkyPooBahsDateTimeLibrary.getYear(timestamp);
    }
    function getMonth(uint timestamp) public pure returns (uint month) {
        month = BokkyPooBahsDateTimeLibrary.getMonth(timestamp);
    }
    function getDay(uint timestamp) public pure returns (uint day) {
        day = BokkyPooBahsDateTimeLibrary.getDay(timestamp);
    }
    function getHour(uint timestamp) public pure returns (uint hour) {
        hour = BokkyPooBahsDateTimeLibrary.getHour(timestamp);
    }
    function getMinute(uint timestamp) public pure returns (uint minute) {
        minute = BokkyPooBahsDateTimeLibrary.getMinute(timestamp);
    }
    function getSecond(uint timestamp) public pure returns (uint second) {
        second = BokkyPooBahsDateTimeLibrary.getSecond(timestamp);
    }

    function addYears(uint timestamp, uint _years) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addYears(timestamp, _years);
    }
    function addMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addMonths(timestamp, _months);
    }
    function addDays(uint timestamp, uint _days) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addDays(timestamp, _days);
    }
    function addHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addHours(timestamp, _hours);
    }
    function addMinutes(uint timestamp, uint _minutes) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addMinutes(timestamp, _minutes);
    }
    function addSeconds(uint timestamp, uint _seconds) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addSeconds(timestamp, _seconds);
    }

    function subYears(uint timestamp, uint _years) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subYears(timestamp, _years);
    }
    function subMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subMonths(timestamp, _months);
    }
    function subDays(uint timestamp, uint _days) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subDays(timestamp, _days);
    }
    function subHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subHours(timestamp, _hours);
    }
    function subMinutes(uint timestamp, uint _minutes) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subMinutes(timestamp, _minutes);
    }
    function subSeconds(uint timestamp, uint _seconds) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subSeconds(timestamp, _seconds);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) public pure returns (uint _years) {
        _years = BokkyPooBahsDateTimeLibrary.diffYears(fromTimestamp, toTimestamp);
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) public pure returns (uint _months) {
        _months = BokkyPooBahsDateTimeLibrary.diffMonths(fromTimestamp, toTimestamp);
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) public pure returns (uint _days) {
        _days = BokkyPooBahsDateTimeLibrary.diffDays(fromTimestamp, toTimestamp);
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) public pure returns (uint _hours) {
        _hours = BokkyPooBahsDateTimeLibrary.diffHours(fromTimestamp, toTimestamp);
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) public pure returns (uint _minutes) {
        _minutes = BokkyPooBahsDateTimeLibrary.diffMinutes(fromTimestamp, toTimestamp);
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) public pure returns (uint _seconds) {
        _seconds = BokkyPooBahsDateTimeLibrary.diffSeconds(fromTimestamp, toTimestamp);
    }
}




library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}














contract CPITrackerOracle is Owned, ChainlinkClient {
    using Chainlink for Chainlink.Request;
  
    BokkyPooBahsDateTimeContract public time_contract;
    address public timelock_address;
    address public bot_address;

    uint256 public cpi_last = 28012600000; // Dec 2021 CPI-U, 280.126 * 100000000
    uint256 public cpi_target = 28193300000; // Jan 2022 CPI-U, 281.933 * 100000000
    uint256 public peg_price_last = 1e18; // Use currPegPrice(). Will always be in Dec 2021 dollars
    uint256 public peg_price_target = 1006450668627688968; // Will always be in Dec 2021 dollars

    address public oracle; // Chainlink CPI oracle address
    bytes32 public jobId; // Job ID for the CPI-U date
    uint256 public fee; // LINK token fee

    uint256 public stored_year = 2022; // Last time (year) the stored CPI data was updated
    uint256 public stored_month = 1; // Last time (month) the stored CPI data was updated
    uint256 public lastUpdateTime = 1644886800; // Last time the stored CPI data was updated.
    uint256 public ramp_period = 28 * 86400; // Apply the CPI delta to the peg price over a set period
    uint256 public future_ramp_period = 28 * 86400;
    CPIObservation[] public cpi_observations; // Historical tracking of CPI data

    uint256 public max_delta_frac = 25000; // 2.5%. Max month-to-month CPI delta. 

    string[13] public month_names; // English names of the 12 months
    uint256 public fulfill_ready_day = 15; // Date of the month that CPI data is expected to by ready by


    
    struct CPIObservation {
        uint256 result_year;
        uint256 result_month;
        uint256 cpi_target;
        uint256 peg_price_target;
        uint256 timestamp;
    }


    modifier onlyByOwnGov() {
        require(msg.sender == owner || msg.sender == timelock_address, "Not owner or timelock");
        _;
    }

    modifier onlyByOwnGovBot() {
        require(msg.sender == owner || msg.sender == timelock_address || msg.sender == bot_address, "Not owner, tlck, or bot");
        _;
    }


    constructor (
        address _creator_address,
        address _timelock_address
    ) Owned(_creator_address) {
        timelock_address = _timelock_address;

        month_names = [
            '',
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
        ];



        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        time_contract = BokkyPooBahsDateTimeContract(0x2Dd1B4D4548aCCeA497050619965f91f78b3b532);
        oracle = 0x3c30c5c415B2410326297F0f65f5Cbb32f3aefCc;
        jobId = "32c3e7b12fe44665a4e2bb87aa9779af";
        fee = 1e17; // 0.1 LINK

        cpi_observations.push(CPIObservation(
            2021,
            12,
            cpi_last,
            peg_price_last,
            1642208400 // Dec data observed on Jan 15 2021
        ));

        cpi_observations.push(CPIObservation(
            2022,
            1,
            cpi_target,
            peg_price_target,
            1644886800 // Jan data observed on Feb 15 2022
        ));
    }

    function upcomingCPIParams() public view returns (
        uint256 upcoming_year,
        uint256 upcoming_month, 
        uint256 upcoming_timestamp
    ) {
        if (stored_month == 12) {
            upcoming_year = stored_year + 1;
            upcoming_month = 1;
        }
        else {
            upcoming_year = stored_year;
            upcoming_month = stored_month + 1;
        }

        upcoming_timestamp = time_contract.timestampFromDate(upcoming_year, upcoming_month, fulfill_ready_day);
    }

    function upcomingSerie() external view returns (string memory serie_name) {
        (uint256 upcoming_year, uint256 upcoming_month, ) = upcomingCPIParams();

        return string(abi.encodePacked("CUSR0000SA0", " ", month_names[upcoming_month], " ", Strings.toString(upcoming_year)));
    }

    function currDeltaFracE6() public view returns (int256) {
        return int256(((peg_price_target - peg_price_last) * 1e6) / peg_price_last);
    }

    function currDeltaFracAbsE6() public view returns (uint256) {
        int256 curr_delta_frac = currDeltaFracE6();
        if (curr_delta_frac > 0) return uint256(curr_delta_frac);
        else return uint256(-curr_delta_frac);
    }

    function currPegPrice() external view returns (uint256) {
        uint256 elapsed_time = block.timestamp - lastUpdateTime;
        if (elapsed_time >= ramp_period) {
            return peg_price_target;
        }
        else {
            int256 fractional_price_delta = (int256(peg_price_target - peg_price_last) * int256(elapsed_time)) / int256(ramp_period);
            return uint256(int256(peg_price_last) + int256(fractional_price_delta));
        }
    }


    function requestCPIData() external onlyByOwnGovBot returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        (uint256 upcoming_year, uint256 upcoming_month, uint256 upcoming_timestamp) = upcomingCPIParams();

        require(block.timestamp >= upcoming_timestamp, "Too early");

        request.add("serie", "CUSR0000SA0"); // CPI-U: https://data.bls.gov/timeseries/CUSR0000SA0
        request.add("month", month_names[upcoming_month]);
        request.add("year", Strings.toString(upcoming_year)); 
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function fulfill(bytes32 _requestId, uint256 result) public recordChainlinkFulfillment(_requestId)
    {
        cpi_last = cpi_target;
        peg_price_last = peg_price_target;

        cpi_target = result;
        peg_price_target = (peg_price_last * cpi_target) / cpi_last;

        require(currDeltaFracAbsE6() <= max_delta_frac, "Delta too high");

        lastUpdateTime = block.timestamp;

        (uint256 result_year, uint256 result_month, ) = upcomingCPIParams();
        stored_year = result_year;
        stored_month = result_month;

        ramp_period = future_ramp_period;

        cpi_observations.push(CPIObservation(
            result_year,
            result_month,
            cpi_target,
            peg_price_target,
            block.timestamp
        ));

        emit CPIUpdated(result_year, result_month, result, peg_price_target, ramp_period);
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunc,
        uint256 _expiration
    ) external onlyByOwnGovBot {
        cancelChainlinkRequest(_requestId, _payment, _callbackFunc, _expiration);
    }
    

    function setTimelock(address _new_timelock_address) external onlyByOwnGov {
        timelock_address = _new_timelock_address;
    }

    function setBot(address _new_bot_address) external onlyByOwnGov {
        bot_address = _new_bot_address;
    }

    function setOracleInfo(address _oracle, bytes32 _jobId, uint256 _fee) external onlyByOwnGov {
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
    }

    function setMaxDeltaFrac(uint256 _max_delta_frac) external onlyByOwnGov {
        max_delta_frac = _max_delta_frac; 
    }

    function setFulfillReadyDay(uint256 _fulfill_ready_day) external onlyByOwnGov {
        fulfill_ready_day = _fulfill_ready_day; 
    }

    function setFutureRampPeriod(uint256 _future_ramp_period) external onlyByOwnGov {
        future_ramp_period = _future_ramp_period; // In sec
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyByOwnGov {
        TransferHelper.safeTransfer(tokenAddress, owner, tokenAmount);
    }

    
    event CPIUpdated(uint256 year, uint256 month, uint256 result, uint256 peg_price_target, uint256 ramp_period);
}




interface IUniswapV2PairV5 {
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
}








interface IUniV2TWAMMPair is IUniswapV2PairV5 {

    event LongTermSwap0To1(address indexed addr, uint256 orderId, uint256 amount0In, uint256 numberOfTimeIntervals);
    event LongTermSwap1To0(address indexed addr, uint256 orderId, uint256 amount1In, uint256 numberOfTimeIntervals);
    event CancelLongTermOrder(address indexed addr, uint256 orderId, address sellToken, uint256 unsoldAmount, address buyToken, uint256 purchasedAmount);
    event WithdrawProceedsFromLongTermOrder(address indexed addr, uint256 orderId, address indexed proceedToken, uint256 proceeds, bool orderExpired);

    function longTermSwapFrom0To1(uint256 amount0In, uint256 numberOfTimeIntervals) external returns (uint256 orderId);
    function longTermSwapFrom1To0(uint256 amount1In, uint256 numberOfTimeIntervals) external returns (uint256 orderId);
    function cancelLongTermSwap(uint256 orderId) external;
    function withdrawProceedsFromLongTermSwap(uint256 orderId) external returns (bool is_expired);
    function executeVirtualOrders(uint256 blockTimestamp) external;

    function orderTimeInterval() external returns (uint256);
    function getTWAPHistoryLength() external view returns (uint);
    function getTwammReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast, uint112 _twammReserve0, uint112 _twammReserve1);
    function getReserveAfterTwamm(uint256 blockTimestamp) external view returns (uint112 _reserve0, uint112 _reserve1, uint256 lastVirtualOrderTimestamp, uint112 _twammReserve0, uint112 _twammReserve1);
    function getNextOrderID() external view returns (uint256);
    function getOrderIDsForUser(address user) external view returns (uint256[] memory);
    function getOrderIDsForUserLength(address user) external view returns (uint256);
    function twammUpToDate() external view returns (bool);
    function getTwammState() external view returns (uint256 token0Rate, uint256 token1Rate, uint256 lastVirtualOrderTimestamp, uint256 orderTimeInterval_rtn, uint256 rewardFactorPool0, uint256 rewardFactorPool1);
    function getTwammSalesRateEnding(uint256 _blockTimestamp) external view returns (uint256 orderPool0SalesRateEnding, uint256 orderPool1SalesRateEnding);
    function getTwammRewardFactor(uint256 _blockTimestamp) external view returns (uint256 rewardFactorPool0AtTimestamp, uint256 rewardFactorPool1AtTimestamp);
    function getTwammOrder(uint256 orderId) external view returns (uint256 id, uint256 expirationTimestamp, uint256 saleRate, address owner, address sellTokenAddr, address buyTokenAddr);
    function getTwammOrderProceeds(uint256 orderId, uint256 blockTimestamp) external view returns (bool orderExpired, uint256 totalReward);

    function togglePauseNewSwaps() external;
}




interface IUniswapV2FactoryV5 {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}





library Babylonian {
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}





library FullMath {
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
    unchecked {
        uint256 prod0; // Least significant 256 bits of the product.
        uint256 prod1; // Most significant 256 bits of the product.
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }
        require(denominator > prod1);
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }
        uint256 twos = uint256(-int256(denominator)) & denominator;
        assembly {
            denominator := div(denominator, twos)
        }
        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;
        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // Inverse mod 2**8.
        inv *= 2 - denominator * inv; // Inverse mod 2**16.
        inv *= 2 - denominator * inv; // Inverse mod 2**32.
        inv *= 2 - denominator * inv; // Inverse mod 2**64.
        inv *= 2 - denominator * inv; // Inverse mod 2**128.
        inv *= 2 - denominator * inv; // Inverse mod 2**256.
        result = prod0 * inv;
        return result;
    }
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
    unchecked {
        if (mulmod(a, b, denominator) != 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
    }
}







library UniswapV2LiquidityMathLibraryMini {

    function computeProfitMaximizingTrade(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB,
        bool aToB_to_use
    ) pure internal returns (uint256 amountIn) {
        bool aToB = ((reserveA * truePriceTokenB) / reserveB) < truePriceTokenA;

        uint256 invariant = reserveA * reserveB;

        require(truePriceTokenA != 0 && truePriceTokenB != 0, "CPMT: ZERO_PRICE");

        uint256 leftSide = Babylonian.sqrt(
            FullMath.mulDiv(
                (invariant * 1000),
                aToB ? truePriceTokenA : truePriceTokenB,
                (aToB ? truePriceTokenB : truePriceTokenA) * 997
            )
        );
        uint256 rightSide = (aToB ? reserveA * 1000 : reserveB * 1000) / 997;

        if (leftSide < rightSide) return (0);

        amountIn = leftSide - rightSide;
    }

}














contract FPIControllerPool is Owned {

    address public timelock_address;
    FPI public FPI_TKN;
    IFrax public FRAX;
    IUniV2TWAMMPair public TWAMM;

    AggregatorV3Interface public priceFeedFRAXUSD;
    AggregatorV3Interface public priceFeedFPIUSD;
    uint256 public chainlink_frax_usd_decimals;
    uint256 public chainlink_fpi_usd_decimals;
    CPITrackerOracle public cpiTracker;

    uint256 public last_order_id_twamm; // Last TWAMM order ID that was used

    address[] public amos_array;
    mapping(address => bool) public amos; // Mapping is also used for faster verification

    mapping(address => int256) public frax_borrowed_balances; // Amount of FRAX the contract borrowed, by AMO
    int256 public frax_borrowed_sum = 0; // Across all AMOs
    int256 public frax_borrow_cap = int256(10000000e18); // Max amount of FRAX the contract can borrow from this contract

    bool public use_manual_mint_fee = false;
    uint256 public mint_fee_manual = 3000; // E6
    uint256 public mint_fee_multiplier = 1000000; // E6
    
    bool public use_manual_redeem_fee = false;
    uint256 public redeem_fee_manual = 3000; // E6
    uint256 public redeem_fee_multiplier = 1000000; // E6
    
    uint256 public fpi_mint_cap = 101000000e18;
    uint256 public peg_band_mint_redeem = 50000; // 5%
    uint256 public peg_band_twamm = 100000; // 10%
    uint256 public max_swap_frax_amt_in = 10000000e18; // 10M
    uint256 public max_swap_fpi_amt_in = 10000000e18; // 10M
    bool public mints_paused = false;
    bool public redeems_paused = false;

    uint256 public constant PRICE_PRECISION = 1e18;
    uint256 public constant FEE_PRECISION = 1e6;
    uint256 public constant PEG_BAND_PRECISION = 1e6;

    bool frax_is_token0;
    bool pending_twamm_order = false;
    uint256 public num_twamm_intervals = 168;
    uint256 public swap_period = 7 * 86400; // 7 days


    modifier onlyByOwnGov() {
        require(msg.sender == owner || msg.sender == timelock_address, "Not owner or timelock");
        _;
    }

    modifier validAMO(address amo_address) {
        require(amos[amo_address], "Invalid AMO");
        _;
    }


    constructor (
        address _creator_address,
        address _timelock_address,
        address[6] memory _address_pack
    ) Owned(_creator_address) {
        timelock_address = _timelock_address;

        FRAX = IFrax(_address_pack[0]);
        FPI_TKN = FPI(_address_pack[1]);
        TWAMM = IUniV2TWAMMPair(_address_pack[2]);
        priceFeedFRAXUSD = AggregatorV3Interface(_address_pack[3]);
        priceFeedFPIUSD = AggregatorV3Interface(_address_pack[4]);
        cpiTracker = CPITrackerOracle(_address_pack[5]);

        chainlink_frax_usd_decimals = priceFeedFRAXUSD.decimals();
        chainlink_fpi_usd_decimals = priceFeedFPIUSD.decimals();

        address token0 = TWAMM.token0();
        if (token0 == address(FRAX)) frax_is_token0 = true;
        else frax_is_token0 = false;

        num_twamm_intervals = swap_period / TWAMM.orderTimeInterval();
    }



    function dollarBalances() public view returns (uint256 frax_val_e18, uint256 collat_val_e18) {
        frax_val_e18 = FRAX.balanceOf(address(this));
        collat_val_e18 = (frax_val_e18 * 1e6) / FRAX.global_collateral_ratio();
    }

    function getFRAXPriceE18() public view returns (uint256) {
        (uint80 roundID, int price, , uint256 updatedAt, uint80 answeredInRound) = priceFeedFRAXUSD.latestRoundData();
        require(price >= 0 && updatedAt!= 0 && answeredInRound >= roundID, "Invalid chainlink price");

        return ((uint256(price) * 1e18) / (10 ** chainlink_frax_usd_decimals));
    }

    function getFPIPriceE18() public view returns (uint256) {
        (uint80 roundID, int price, , uint256 updatedAt, uint80 answeredInRound) = priceFeedFPIUSD.latestRoundData();
        require(price >= 0 && updatedAt!= 0 && answeredInRound >= roundID, "Invalid chainlink price");

        return ((uint256(price) * 1e18) / (10 ** chainlink_fpi_usd_decimals));
    }

    function mint_fee() public view returns (uint256 fee) {
        if (use_manual_mint_fee) fee = mint_fee_manual;
        else {
            fee = cpiTracker.currDeltaFracAbsE6();
        }

        fee = (fee * mint_fee_multiplier) / 1e6;
    }

    function redeem_fee() public view returns (uint256 fee) {
        if (use_manual_redeem_fee) fee = redeem_fee_manual;
        else {
            fee = cpiTracker.currDeltaFracAbsE6();
        }

        fee = (fee * redeem_fee_multiplier) / 1e6;
    }

    function pegStatusMntRdm() public view returns (uint256 cpi_peg_price, uint256 diff_frac_abs, bool within_range) {
        uint256 fpi_price = getFPIPriceE18();
        cpi_peg_price = cpiTracker.currPegPrice();

        if (fpi_price > cpi_peg_price){
            diff_frac_abs = ((fpi_price - cpi_peg_price) * PEG_BAND_PRECISION) / fpi_price;
        }
        else {
            diff_frac_abs = ((cpi_peg_price - fpi_price) * PEG_BAND_PRECISION) / fpi_price;
        }

        within_range = (diff_frac_abs <= peg_band_mint_redeem);
    }

    function price_info() public view returns (
        int256 collat_imbalance, 
        uint256 cpi_peg_price,
        uint256 fpi_price,
        uint256 price_diff_frac_abs
    ) {
        fpi_price = getFPIPriceE18();
        cpi_peg_price = cpiTracker.currPegPrice();
        uint256 fpi_supply = FPI_TKN.totalSupply();

        if (fpi_price > cpi_peg_price){
            collat_imbalance = int256(((fpi_price - cpi_peg_price) * fpi_supply) / PRICE_PRECISION);
            price_diff_frac_abs = ((fpi_price - cpi_peg_price) * PEG_BAND_PRECISION) / fpi_price;
        }
        else {
            collat_imbalance = -1 * int256(((cpi_peg_price - fpi_price) * fpi_supply) / PRICE_PRECISION);
            price_diff_frac_abs = ((cpi_peg_price - fpi_price) * PEG_BAND_PRECISION) / fpi_price;
        }
    }


    function calcMintFPI(uint256 frax_in, uint256 min_fpi_out) public view returns (uint256 fpi_out) {
        require(!mints_paused, "Mints paused");

        (uint256 cpi_peg_price, , bool within_range) = pegStatusMntRdm();

        require(within_range, "Peg band [Mint]");

        fpi_out = (frax_in * PRICE_PRECISION) / cpi_peg_price;

        fpi_out -= (fpi_out * mint_fee()) / FEE_PRECISION;

        require(fpi_out >= min_fpi_out, "Slippage [Mint]");

        require(FPI_TKN.totalSupply() + fpi_out <= fpi_mint_cap, "FPI mint cap");
    }

    function mintFPI(uint256 frax_in, uint256 min_fpi_out) external returns (uint256 fpi_out) {
        fpi_out = calcMintFPI(frax_in, min_fpi_out);

        TransferHelper.safeTransferFrom(address(FRAX), msg.sender, address(this), frax_in);

        FPI_TKN.minter_mint(msg.sender, fpi_out);

        emit FPIMinted(frax_in, fpi_out);
    }

    function calcRedeemFPI(uint256 fpi_in, uint256 min_frax_out) public view returns (uint256 frax_out) {
        require(!redeems_paused, "Redeems paused");

        (uint256 cpi_peg_price, , bool within_range) = pegStatusMntRdm();

        require(within_range, "Peg band [Redeem]");

        frax_out = (fpi_in * cpi_peg_price) / PRICE_PRECISION;

        frax_out -= (frax_out * redeem_fee()) / FEE_PRECISION;

        require(frax_out >= min_frax_out, "Slippage [Redeem]");
    }

    function redeemFPI(uint256 fpi_in, uint256 min_frax_out) external returns (uint256 frax_out) {
        frax_out = calcRedeemFPI(fpi_in, min_frax_out);

        TransferHelper.safeTransferFrom(address(FPI_TKN), msg.sender, address(this), fpi_in);

        TransferHelper.safeTransfer(address(FRAX), msg.sender, frax_out);

        emit FPIRedeemed(fpi_in, frax_out);
    }

    function getTwammToPegAmt(bool fpi_to_frax) public view returns (uint256) {
        (uint256 reserveA, uint256 reserveB, ) = TWAMM.getReserves();

        uint256 cpi_peg_price = cpiTracker.currPegPrice();

        uint256 truePriceTokenA;
        uint256 truePriceTokenB;
        if (frax_is_token0){
            truePriceTokenA = cpi_peg_price; // X FRAX per 1 CPI
            truePriceTokenB = 1e18;
        }
        else {
            truePriceTokenA = 1e18;
            truePriceTokenB = cpi_peg_price; // X FRAX per 1 CPI
        }

        if (fpi_to_frax) {
            return UniswapV2LiquidityMathLibraryMini.computeProfitMaximizingTrade(
                truePriceTokenA, truePriceTokenB,
                reserveA, reserveB,
                !frax_is_token0
            );
        }
        else {
            return UniswapV2LiquidityMathLibraryMini.computeProfitMaximizingTrade(
                truePriceTokenA, truePriceTokenB,
                reserveA, reserveB,
                frax_is_token0
            );
        }

    }

    function twammToPeg(uint256 override_amt) external onlyByOwnGov returns (uint256 frax_to_use, uint256 fpi_to_use) {
        if (pending_twamm_order) TWAMM.cancelLongTermSwap(last_order_id_twamm);

        (int256 collat_imbalance, , uint256 curr_fpi_price, uint256 price_diff_abs) = price_info();

        require(price_diff_abs <= peg_band_twamm, "Peg band [TWAMM]");

        last_order_id_twamm = TWAMM.getNextOrderID(); 
        {
            if (collat_imbalance > 0) {

                uint256 fpi_max = (uint256(collat_imbalance) * PRICE_PRECISION) / curr_fpi_price;

                fpi_to_use = getTwammToPegAmt(true);

                if (fpi_to_use > fpi_max) fpi_to_use = fpi_max;

                if (override_amt > 0) fpi_to_use = override_amt;

                require(fpi_to_use <= max_swap_fpi_amt_in, "Too much FPI sold");

                FPI_TKN.minter_mint(address(this), fpi_to_use);

                FPI_TKN.approve(address(TWAMM), fpi_to_use);

                if (frax_is_token0) {
                    TWAMM.longTermSwapFrom1To0(fpi_to_use, num_twamm_intervals);
                }
                else {
                    TWAMM.longTermSwapFrom0To1(fpi_to_use, num_twamm_intervals);
                }
            }
            else {

                uint256 frax_max = uint256(-1 * collat_imbalance); // collat_imbalance will always be negative here

                frax_to_use = getTwammToPegAmt(false);

                if (frax_to_use > frax_max) frax_to_use = frax_max;

                if (override_amt > 0) frax_to_use = override_amt;

                require(frax_to_use <= max_swap_frax_amt_in, "Too much FRAX sold");

                FRAX.approve(address(TWAMM), frax_to_use);

                if (frax_is_token0) {
                    TWAMM.longTermSwapFrom0To1(frax_to_use, num_twamm_intervals);
                }
                else {
                    TWAMM.longTermSwapFrom1To0(frax_to_use, num_twamm_intervals);
                }
            }
        }

        pending_twamm_order = true;

        emit TWAMMedToPeg(last_order_id_twamm, frax_to_use, fpi_to_use, block.timestamp);
    }

    function cancelCurrTWAMMOrder(uint256 order_id_override) public onlyByOwnGov {
        TWAMM.cancelLongTermSwap(order_id_override == 0 ? last_order_id_twamm : order_id_override);

        pending_twamm_order = false;
    }

    function collectCurrTWAMMProceeds(uint256 order_id_override) external onlyByOwnGov {
        bool is_expired = TWAMM.withdrawProceedsFromLongTermSwap(order_id_override == 0 ? last_order_id_twamm : order_id_override);
        
        if (is_expired && (order_id_override == 0)) pending_twamm_order = false;
    }


    function burnFPI(bool burn_all, uint256 fpi_amount) public onlyByOwnGov {
        if (burn_all) {
            FPI_TKN.burn(FPI_TKN.balanceOf(address(this)));
        }
        else FPI_TKN.burn(fpi_amount);
    }


    function giveFRAXToAMO(address destination_amo, uint256 frax_amount) external onlyByOwnGov validAMO(destination_amo) {
        int256 frax_amount_i256 = int256(frax_amount);

        require((frax_borrowed_sum + frax_amount_i256) <= frax_borrow_cap, "Borrow cap");
        frax_borrowed_balances[destination_amo] += frax_amount_i256;
        frax_borrowed_sum += frax_amount_i256;

        TransferHelper.safeTransfer(address(FRAX), destination_amo, frax_amount);
    }

    function receiveFRAXFromAMO(uint256 frax_amount) external validAMO(msg.sender) {
        int256 frax_amt_i256 = int256(frax_amount);

        TransferHelper.safeTransferFrom(address(FRAX), msg.sender, address(this), frax_amount);

        frax_borrowed_balances[msg.sender] -= frax_amt_i256;
        frax_borrowed_sum -= frax_amt_i256;
    }


    function addAMO(address amo_address) public onlyByOwnGov {
        require(amo_address != address(0), "Zero address detected");

        require(amos[amo_address] == false, "Address already exists");
        amos[amo_address] = true; 
        amos_array.push(amo_address);

        emit AMOAdded(amo_address);
    }

    function removeAMO(address amo_address) public onlyByOwnGov {
        require(amo_address != address(0), "Zero address detected");
        require(amos[amo_address] == true, "Address nonexistant");
        
        delete amos[amo_address];

        for (uint i = 0; i < amos_array.length; i++){ 
            if (amos_array[i] == amo_address) {
                amos_array[i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
        }

        emit AMORemoved(amo_address);
    }

    function setOracles(address _frax_oracle, address _fpi_oracle, address _cpi_oracle) external onlyByOwnGov {
        priceFeedFRAXUSD = AggregatorV3Interface(_frax_oracle);
        priceFeedFPIUSD = AggregatorV3Interface(_fpi_oracle);
        cpiTracker = CPITrackerOracle(_cpi_oracle);

        chainlink_frax_usd_decimals = priceFeedFRAXUSD.decimals();
        chainlink_fpi_usd_decimals = priceFeedFPIUSD.decimals();
    }

    function setTWAMMAndSwapPeriod(address _twamm_addr, uint256 _swap_period) external onlyByOwnGov {
        if (pending_twamm_order) cancelCurrTWAMMOrder(last_order_id_twamm);
        
        TWAMM = IUniV2TWAMMPair(_twamm_addr);
        swap_period = _swap_period;
        num_twamm_intervals = _swap_period / TWAMM.orderTimeInterval();
    }

    function toggleMints() external onlyByOwnGov {
        mints_paused = !mints_paused;
    }

    function toggleRedeems() external onlyByOwnGov {
        redeems_paused = !redeems_paused;
    }

    function setFraxBorrowCap(int256 _frax_borrow_cap) external onlyByOwnGov {
        frax_borrow_cap = _frax_borrow_cap;
    }

    function setMintCap(uint256 _fpi_mint_cap) external onlyByOwnGov {
        fpi_mint_cap = _fpi_mint_cap;
    }

    function setPegBands(uint256 _peg_band_mint_redeem, uint256 _peg_band_twamm) external onlyByOwnGov {
        peg_band_mint_redeem = _peg_band_mint_redeem;
        peg_band_twamm = _peg_band_twamm;
    }

    function setMintRedeemFees(
        bool _use_manual_mint_fee,
        uint256 _mint_fee_manual, 
        uint256 _mint_fee_multiplier, 
        bool _use_manual_redeem_fee,
        uint256 _redeem_fee_manual, 
        uint256 _redeem_fee_multiplier
    ) external onlyByOwnGov {
        use_manual_mint_fee = _use_manual_mint_fee;
        mint_fee_manual = _mint_fee_manual;
        mint_fee_multiplier = _mint_fee_multiplier;
        use_manual_redeem_fee = _use_manual_redeem_fee;
        redeem_fee_manual = _redeem_fee_manual;
        redeem_fee_multiplier = _redeem_fee_multiplier;
    }

    function setTWAMMMaxSwapIn(uint256 _max_swap_frax_amt_in, uint256 _max_swap_fpi_amt_in) external onlyByOwnGov {
        max_swap_frax_amt_in = _max_swap_frax_amt_in;
        max_swap_fpi_amt_in = _max_swap_fpi_amt_in;
    }

    function setTimelock(address _new_timelock_address) external onlyByOwnGov {
        timelock_address = _new_timelock_address;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyByOwnGov {
        TransferHelper.safeTransfer(tokenAddress, owner, tokenAmount);
        emit RecoveredERC20(tokenAddress, tokenAmount);
    }

    event AMOAdded(address amo_address);
    event AMORemoved(address amo_address);
    event RecoveredERC20(address token, uint256 amount);
    event FPIMinted(uint256 frax_in, uint256 fpi_out);
    event FPIRedeemed(uint256 fpi_in, uint256 frax_out);
    event TWAMMedToPeg(uint256 order_id, uint256 frax_amt, uint256 fpi_amt, uint256 timestamp);
}