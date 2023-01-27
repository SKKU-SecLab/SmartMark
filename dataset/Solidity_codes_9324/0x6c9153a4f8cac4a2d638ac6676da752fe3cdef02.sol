
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
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
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

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity ^0.8.0;

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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
}

pragma solidity ^0.8.3;

interface Uniswap {

  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function factory() external pure returns (address);

  function WETH() external pure returns (address);

}

pragma solidity >=0.5.0;

interface IUniswapV3Pool {

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees() external view returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );


    function token0() external view returns (address);


    function token1() external view returns (address);

}

pragma solidity >=0.5.0;

interface IUniswapV3Factory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);


    function feeAmountTickSpacing(uint24 fee) external view returns (int24);


    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);


    function setOwner(address _owner) external;


    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;

}


pragma solidity ^0.8.3;

contract MainnetMultiBridgePool is AccessControl, ReentrancyGuard {

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  using SafeMath  for uint256;
  using SafeERC20 for IERC20;

  event Deposited(address indexed token, address outToken, address indexed spender, address recipient, uint256 amount, uint256 requestId);
  event Withdrawn(address indexed token, address indexed owner, uint256 amount, uint256 requestId);
  event EthWithdrawn(uint256 amount);

  event FeeSet(address token, uint256 fee, uint256 percentFee, uint256 percentFeeDecimals, uint256 tokenToEth);
  event TokenConfigSet(address token, address outAddress, uint256 maxTxsCount, uint256 txsCount);
  event Initialized(address token, address outAddress, uint256 maxTxsCount, uint256 fee, uint256 percentFee, uint256 percentFeeDecimals, uint256 tokenToEth);
  event Removed(address token);

  event AutoWithdrawFeeSet(bool autoWithdraw);
  event TreasuryAddressSet(address treasuryAddress);
  event ConfigSet(address uniV2Router, address uniV3Factory);

  struct TokenInfo {
    address outAddress;
    uint256 maxTxsCount;
    uint256 txsCount;
    bool exists;
    uint256 fee;
    uint256 percentFee;
    uint256 percentFeeDecimals;
    uint256 tokenToEth;
  }

  mapping(address => TokenInfo) private tokens;

  uint256 private requestId;

  bool    private autoWithdrawFee;
  address private treasuryAddress;

  address private UniV2Router;
  address private UniV3Factory;
  address private WETH;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(MINTER_ROLE, _msgSender());

    treasuryAddress = _msgSender();
  }

  modifier onlyMinter() {

    require(hasRole(MINTER_ROLE, _msgSender()), "MainnetMultiBridgePool: caller is not a minter");
    _;
  }

  modifier onlyOwner() {

    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "MainnetMultiBridgePool: caller is not an owner");
    _;
  }

  function _getUniV3TokenInEth(address _token, uint256 _amount) 
    internal view returns (uint256) {

      address lp;
      lp = IUniswapV3Factory(UniV3Factory).getPool(WETH, _token, 10000);
      if (lp == address(0)) {
        lp = IUniswapV3Factory(UniV3Factory).getPool(WETH, _token, 3000);
        if (lp == address(0)) { 
          lp = IUniswapV3Factory(UniV3Factory).getPool(WETH, _token, 500);
          if (lp == address(0)) {
            return 0;
          }
        }
      }

      (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(lp).slot0();
      if (IUniswapV3Pool(lp).token0() == _token) {
        return (_amount * sqrtPriceX96 * sqrtPriceX96) >> (96 * 2);
      } else {
        return _amount / ((sqrtPriceX96 * sqrtPriceX96) >> (96 * 2));
      }
  }

  function _getUniV2TokenInEth(address _token, uint256 _amount) 
    internal view returns (uint256) {

      address lp = Uniswap(Uniswap(UniV2Router).factory()).getPair(_token, WETH);
      if (lp == address(0)) {
         return 0;
      }

      (uint reserve0, uint reserve1, ) = Uniswap(lp).getReserves();

      if (Uniswap(lp).token0() == _token) {
        return reserve1.mul(_amount).div(reserve0);
      } else {
        return reserve0.mul(_amount).div(reserve1);
      }
  }

  function getFee(address _token, uint256 _amount) 
    public view returns (uint256) {

      TokenInfo memory info = tokens[_token];
      if (!info.exists) {
        return 0;
      }

      if (info.percentFee == 0) {
        return info.fee;
      }

      uint256 _tokenInEth = _getUniV3TokenInEth(_token, _amount);
      if (_tokenInEth == 0) {
        _tokenInEth = _getUniV2TokenInEth(_token, _amount);
        if (_tokenInEth == 0) {
          _tokenInEth = _amount.div(info.tokenToEth);
        }
      }

      uint256 decimals = IERC20Metadata(_token).decimals();

      return info.fee.add(_tokenInEth.mul(1e18).mul(info.percentFee).div(10 ** info.percentFeeDecimals).div(10 ** decimals)); 
  }

  function getTokenInfo(address _token)
    public view returns (TokenInfo memory) {

      return tokens[_token];
  }

  function setFee(address _token, uint256 _fee, uint256 _percentFee, uint256 _percentFeeDecimals, uint256 _tokenToEth)
    external onlyOwner {

      require(tokens[_token].exists, "MainnetMultiBridgePool: token unsupported");

      tokens[_token].fee = _fee;
      tokens[_token].percentFee = _percentFee;
      tokens[_token].percentFeeDecimals = _percentFeeDecimals;
      tokens[_token].tokenToEth = _tokenToEth;

      emit FeeSet(_token, _fee, _percentFee, _percentFeeDecimals, _tokenToEth);
  }

  function setTokenConfig(address _token, address _outAddress, uint256 _maxTxsCount, uint256 _txsCount) 
    external onlyOwner {

      require(tokens[_token].exists, "MainnetMultiBridgePool: token unsupported");

      tokens[_token].outAddress = _outAddress;
      tokens[_token].maxTxsCount = _maxTxsCount;
      tokens[_token].txsCount = _txsCount;

      emit TokenConfigSet(_token, _outAddress, _maxTxsCount, _txsCount);      
  }

  function init(address _token, address _outAddress, uint256 _maxTxsCount, uint256 _fee, uint256 _percentFee, uint256 _percentFeeDecimals, uint256 _tokenToEth) 
    external onlyOwner {

      require(!tokens[_token].exists, "MainnetMultiBridgePool: token already exists");
      
      tokens[_token] = TokenInfo({
         outAddress: _outAddress,
         maxTxsCount: _maxTxsCount,
         txsCount: 0,
         exists: true,
         fee: _fee,
         percentFee: _percentFee,
         percentFeeDecimals: _percentFeeDecimals,
         tokenToEth: _tokenToEth
      });

      emit Initialized({
        token: _token,
        outAddress: _outAddress,
        maxTxsCount: _maxTxsCount,
        fee: _fee,
        percentFee: _percentFee,
        percentFeeDecimals: _percentFeeDecimals,
        tokenToEth: _tokenToEth
      });
  }

  function remove(address _token) 
    external onlyOwner {

      delete tokens[_token];
      emit Removed(_token);
  }

  function setAutoWithdrawFee(bool _autoWithdrawFee)
    external onlyOwner {

      autoWithdrawFee = _autoWithdrawFee;
      emit AutoWithdrawFeeSet(autoWithdrawFee);
  }

  function setTreasuryAddress(address _treasuryAddress)
    external onlyOwner {

      treasuryAddress = _treasuryAddress;
      emit TreasuryAddressSet(_treasuryAddress);
  } 

  function setConfig(address _uniV2Router, address _uniV3Factory)
    external onlyOwner {

      UniV2Router = _uniV2Router;
      UniV3Factory = _uniV3Factory;
      WETH = Uniswap(_uniV2Router).WETH();

      emit ConfigSet(_uniV2Router, _uniV3Factory);
  } 

  function deposit(address _token, address _recipient, uint256 _amount) 
    external payable nonReentrant {

      require(tokens[_token].exists, "MainnetMultiBridgePool: token unsupported");
      require(tokens[_token].maxTxsCount > tokens[_token].txsCount, "MainnetMultiBridgePool: max transactions count reached");

      uint256 depositFee = getFee(_token, _amount);
      require(msg.value >= depositFee, "MainnetMultiBridgePool: not enough eth");

      uint256 balanceBefore = IERC20(_token).balanceOf(address(this));
      IERC20(_token).safeTransferFrom(_msgSender(), address(this), _amount);
      uint256 balanceAfter = IERC20(_token).balanceOf(address(this));

      uint256 refund = msg.value.sub(depositFee);
      if(refund > 0) {
        (bool refundSuccess, ) = _msgSender().call{ value: refund }("");
        require(refundSuccess, "MainnetMultiBridgePool: refund transfer failed");
      }

      if (autoWithdrawFee) {
        (bool withdrawSuccess, ) = treasuryAddress.call{ value: depositFee }("");
        require(withdrawSuccess, "MainnetMultiBridgePool: withdraw transfer failed");
      }

      requestId++;
      tokens[_token].txsCount++;
      emit Deposited(_token, tokens[_token].outAddress, _msgSender(), _recipient, balanceAfter - balanceBefore, requestId);
  }

  function withdraw(address[] calldata _tokens, address[] calldata _owners, uint256[] calldata _amounts, uint256[] calldata _requestsIds) 
    external onlyMinter {

      require(_owners.length == _amounts.length && _owners.length == _requestsIds.length && _owners.length == _tokens.length, "MainnetMultiBridgePool: Arrays length not equal");

      for (uint256 i; i < _owners.length; i++) {
        IERC20(_tokens[i]).safeTransfer(_owners[i], _amounts[i]);
        emit Withdrawn(_tokens[i], _owners[i], _amounts[i], _requestsIds[i]);
      }
  }

  function withdrawEth(uint256 _amount)
    external onlyOwner {

      require(_amount <= address(this).balance, "MainnetMultiBridgePool: not enough balance");
      
      (bool success, ) = _msgSender().call{ value: _amount }("");
      require(success, "MainnetMultiBridgePool: transfer failed");

      emit EthWithdrawn(_amount);
  }
}