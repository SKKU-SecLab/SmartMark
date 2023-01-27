
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
}// MIT

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
pragma solidity 0.8.11;

interface IFeeDistributor{
    function burn(address coin, uint256 amount) external returns (bool);
}// GPL-3.0
pragma solidity >=0.7.2;
pragma experimental ABIEncoderV2;

interface IChainlink {
  function decimals() external view returns (uint8);

  function latestAnswer() external view returns (int256);
}// MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;

    function balanceOf(address account) external view returns (uint256);
}// MIT
pragma solidity ^0.8.0;

interface IWSTETH {
  function unwrap(uint256 _amount) external returns (uint256);

  function getStETHByWstETH(uint256 _wstETHAmount)
    external
    view
    returns (uint256);
}// MIT
pragma solidity ^0.8.0;

interface ICRV {
  function exchange(
    int128 _indexIn,
    int128 _indexOut,
    uint256 _amountIn,
    uint256 _minAmountOut
  ) external payable returns (uint256);
}// MIT
pragma solidity ^0.8.0;

interface IYVUSDC {
  function withdraw(uint256 maxShares) external returns (uint256);

  function pricePerShare() external view returns (uint256);
}// GPL-2.0-or-later
pragma solidity ^0.8.0;

interface ISwapRouter {
  struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 amountIn;
    uint256 amountOutMinimum;
  }

  function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}// MIT
pragma solidity 0.8.11;




contract FeeCustody is Ownable {
  using SafeERC20 for IERC20;

  address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
  address public constant STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
  address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public yvUSDC = 0xa354F35829Ae975e850e23e9615b11Da1B3dC4DE;

  IERC20 public distributionToken = IERC20(WETH);
  address public protocolRevenueRecipient;
  IFeeDistributor public feeDistributor;

  uint256 public pctAllocationForRBNLockers;

  uint256 public constant TOTAL_PCT = 10000; // Equals 100%
  ISwapRouter public constant UNIV3_SWAP_ROUTER =
    ISwapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
  ICRV public constant STETH_ETH_CRV_POOL =
    ICRV(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);

  mapping(address => bytes) public intermediaryPath;

  mapping(address => address) public oracles;

  address[] public assets;

  address public keeper;

  event NewAsset(address asset, bytes intermediaryPath);
  event RecoveredAsset(address asset);
  event NewFeeDistributor(address feeDistributor);
  event NewYVUSDC(address yvUSDC);
  event NewRBNLockerAllocation(uint256 pctAllocationForRBNLockers);
  event NewDistributionToken(address distributionToken);
  event NewProtocolRevenueRecipient(address protocolRevenueRecipient);
  event NewKeeper(address keeper);

  constructor(
    uint256 _pctAllocationForRBNLockers,
    address _feeDistributor,
    address _protocolRevenueRecipient,
    address _admin,
    address _keeper
  ) {
    require(_feeDistributor != address(0), "!_feeDistributor");
    require(
      _protocolRevenueRecipient != address(0),
      "!_protocolRevenueRecipient"
    );
    require(_admin != address(0), "!_admin");
    require(_keeper != address(0), "!_keeper");

    pctAllocationForRBNLockers = _pctAllocationForRBNLockers;
    feeDistributor = IFeeDistributor(_feeDistributor);
    protocolRevenueRecipient = _protocolRevenueRecipient;
    keeper = _keeper;
  }

  receive() external payable {}

  function distributeProtocolRevenue(uint256[] calldata _minAmountOut)
    external
    returns (uint256 toDistribute)
  {
    require(msg.sender == keeper, "!keeper");

    if (address(distributionToken) == WETH) {
      IWETH(address(distributionToken)).deposit{value: address(this).balance}();
    }

    uint256 len = assets.length;
    for (uint256 i; i < len; i++) {
      IERC20 asset = IERC20(assets[i]);
      uint256 assetBalance = asset.balanceOf(address(this));

      if (assetBalance == 0) {
        continue;
      }

      uint256 multiSigRevenue = (assetBalance *
        (TOTAL_PCT - pctAllocationForRBNLockers)) / TOTAL_PCT;

      if (address(asset) != address(distributionToken)) {
        uint256 amountIn = assetBalance - multiSigRevenue;
        _swap(address(asset), amountIn, _minAmountOut[i]);
      }

      asset.safeTransfer(protocolRevenueRecipient, multiSigRevenue);
    }

    toDistribute = distributionToken.balanceOf(address(this));
    distributionToken.safeApprove(address(feeDistributor), toDistribute);

    feeDistributor.burn(address(distributionToken), toDistribute);
  }

  function claimableByRBNLockersOfAsset(address _asset)
    external
    view
    returns (uint256)
  {
    uint256 allocPCT = pctAllocationForRBNLockers;
    uint256 balance = _asset == address(0)
      ? address(this).balance
      : IERC20(_asset).balanceOf(address(this));
    return (balance * allocPCT) / TOTAL_PCT;
  }

  function claimableByProtocolOfAsset(address _asset)
    external
    view
    returns (uint256)
  {
    uint256 allocPCT = TOTAL_PCT - pctAllocationForRBNLockers;
    uint256 balance = _asset == address(0)
      ? address(this).balance
      : IERC20(_asset).balanceOf(address(this));
    return (balance * allocPCT) / TOTAL_PCT;
  }

  function totalClaimableByRBNLockersInUSD() external view returns (uint256) {
    uint256 allocPCT = pctAllocationForRBNLockers;
    return _getTotalAssetValue(allocPCT);
  }

  function totalClaimableByProtocolInUSD() external view returns (uint256) {
    uint256 allocPCT = TOTAL_PCT - pctAllocationForRBNLockers;
    return _getTotalAssetValue(allocPCT);
  }

  function _getTotalAssetValue(uint256 _allocPCT)
    internal
    view
    returns (uint256 claimable)
  {
    uint256 len = assets.length;
    for (uint256 i; i < len; i++) {
      IChainlink oracle = IChainlink(oracles[assets[i]]);

      ERC20 asset = ERC20(assets[i]);

      uint256 bal = asset.balanceOf(address(this));

      if (assets[i] == WSTETH) {
        bal = IWSTETH(assets[i]).getStETHByWstETH(bal);
      } else if (assets[i] == yvUSDC) {
        bal = (bal * IYVUSDC(assets[i]).pricePerShare()) / 10**6;
      }

      uint256 balance = bal * (10**(18 - asset.decimals()));

      if (assets[i] == WETH) {
        balance += address(this).balance;
      }

      claimable +=
        (balance * uint256(oracle.latestAnswer()) * _allocPCT) /
        10**8 /
        TOTAL_PCT;
    }
  }

  function _swap(
    address _asset,
    uint256 _amountIn,
    uint256 _minAmountOut
  ) internal {
    if (_asset == WSTETH) {
      uint256 _stethAmountIn = IWSTETH(_asset).unwrap(_amountIn);
      TransferHelper.safeApprove(
        STETH,
        address(STETH_ETH_CRV_POOL),
        _stethAmountIn
      );

      STETH_ETH_CRV_POOL.exchange(1, 0, _stethAmountIn, _minAmountOut);

      IWETH(address(distributionToken)).deposit{value: address(this).balance}();
      return;
    }

    if (_asset == yvUSDC) {
      TransferHelper.safeApprove(_asset, yvUSDC, _amountIn);
      _amountIn = IYVUSDC(yvUSDC).withdraw(_amountIn);
    }

    TransferHelper.safeApprove(
      _asset != yvUSDC ? _asset : USDC,
      address(UNIV3_SWAP_ROUTER),
      _amountIn
    );

    ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
      path: intermediaryPath[_asset],
      recipient: address(this),
      amountIn: _amountIn,
      amountOutMinimum: _minAmountOut
    });

    UNIV3_SWAP_ROUTER.exactInput(params);
  }

  function setAsset(
    address _asset,
    address _oracle,
    address[] calldata _intermediaryPath,
    uint24[] calldata _poolFees
  ) external onlyOwner {
    require(_asset != address(0), "!_asset");
    uint256 _pathLen = _intermediaryPath.length;
    uint256 _swapFeeLen = _poolFees.length;

    require(IChainlink(_oracle).decimals() == 8, "!ASSET/USD");
    require(_pathLen < 2, "invalid intermediary path");
    require(_swapFeeLen == _pathLen + 1, "invalid pool fees array length");

    if (oracles[_asset] == address(0)) {
      assets.push(_asset);
    }

    oracles[_asset] = _oracle;

    if (_pathLen > 0) {
      intermediaryPath[_asset] = abi.encodePacked(
        _asset != yvUSDC ? _asset : USDC,
        _poolFees[0],
        _intermediaryPath[0],
        _poolFees[1],
        address(distributionToken)
      );
    } else {
      intermediaryPath[_asset] = abi.encodePacked(
        _asset != yvUSDC ? _asset : USDC,
        _poolFees[0],
        address(distributionToken)
      );
    }

    emit NewAsset(_asset, intermediaryPath[_asset]);
  }

  function recoverAllAssets() external onlyOwner {
    uint256 len = assets.length;
    for (uint256 i = 0; i < len; i++) {
      _recoverAsset(assets[i]);
    }
  }

  function recoverAsset(address _asset) external onlyOwner {
    require(_asset != address(0), "!asset");
    _recoverAsset(_asset);
  }

  function _recoverAsset(address _asset) internal {
    IERC20 asset = IERC20(_asset);
    uint256 bal = asset.balanceOf(address(this));
    if (bal > 0) {
      asset.safeTransfer(protocolRevenueRecipient, bal);
      emit RecoveredAsset(_asset);
    }

    if (_asset == WETH) {
      uint256 ethBal = address(this).balance;
      if (ethBal > 0) {
        payable(protocolRevenueRecipient).transfer(ethBal);
      }
    }
  }

  function setFeeDistributor(address _feeDistributor) external onlyOwner {
    require(_feeDistributor != address(0), "!_feeDistributor");
    feeDistributor = IFeeDistributor(_feeDistributor);
    emit NewFeeDistributor(_feeDistributor);
  }

  function setYVUSDC(address _yvUSDC) external onlyOwner {
    require(_yvUSDC != address(0), "!_yvUSDC");
    yvUSDC = _yvUSDC;
    emit NewYVUSDC(_yvUSDC);
  }

  function setRBNLockerAllocPCT(uint256 _pctAllocationForRBNLockers)
    external
    onlyOwner
  {
    require(
      _pctAllocationForRBNLockers <= TOTAL_PCT,
      "!_pctAllocationForRBNLockers"
    );
    pctAllocationForRBNLockers = _pctAllocationForRBNLockers;
    emit NewRBNLockerAllocation(_pctAllocationForRBNLockers);
  }

  function setDistributionToken(address _distributionToken) external onlyOwner {
    require(_distributionToken != address(0), "!_distributionToken");
    distributionToken = IERC20(_distributionToken);
    emit NewDistributionToken(_distributionToken);
  }

  function setProtocolRevenueRecipient(address _protocolRevenueRecipient)
    external
    onlyOwner
  {
    require(
      _protocolRevenueRecipient != address(0),
      "!_protocolRevenueRecipient"
    );
    protocolRevenueRecipient = _protocolRevenueRecipient;
    emit NewProtocolRevenueRecipient(_protocolRevenueRecipient);
  }

  function setKeeper(address _keeper) external onlyOwner {
    require(_keeper != address(0), "!_keeper");
    keeper = _keeper;
    emit NewKeeper(_keeper);
  }
}