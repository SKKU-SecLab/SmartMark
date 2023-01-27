
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

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// UNLICENSED
pragma solidity ^0.8.0;

interface IBatcher {

  function depositFunds(
    uint256 amountIn,
    address routerAddress,
    bytes memory signature
  ) external;


  function depositFundsInCurveLpToken(
    uint256 amountIn,
    address routerAddress,
    bytes memory signature
  ) external;


  function withdrawFunds(uint256 amountOut, address routerAddress) external;


  function batchDeposit(address routerAddress, address[] memory users) external;


  function batchWithdraw(address routerAddress, address[] memory users)
    external;


  function setRouterParams(address routerAddress, address token, uint256 maxLimit) external;



  function setSlippage(uint256 slippage) external;

}/// GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IMetaRouter {

  function keeper() external view returns (address);


  function governance() external view returns (address);


  function wantToken() external view returns (address);


  function deposit(uint256 amountIn, address receiver)
    external
    returns (uint256 shares);


  function withdraw(uint256 sharesIn, address receiver)
    external
    returns (uint256 amountOut);

}/// GPL-3.0-or-later
pragma solidity ^0.8.0;

interface ICurvePool {

  function exchange(
    int128 i,
    int128 j,
    uint256 _dx,
    uint256 _min_dy,
    address _receiver
  ) external returns (uint256);


  function remove_liquidity_one_coin(
    uint256 _token_amount,
    int128 i,
    uint256 min_amount
  ) external returns (uint256);


  function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount)
    external
    returns (uint256);


  function get_dy(
    int128 i,
    int128 j,
    uint256 _dx
  ) external view returns (uint256);


  function get_virtual_price() external view returns (uint256);


  function balanceOf(address) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


}/// GPL-3.0-or-later
pragma solidity ^0.8.0;

interface ICurveDepositZapper {

  function calc_withdraw_one_coin(
    address _pool,
    uint256 _token_amount,
    int128 i
  ) external returns (uint256);


  function calc_token_amount(
    address _pool,
    uint256[4] memory _amounts,
    bool _is_deposit
  ) external returns (uint256);


  function remove_liquidity_one_coin(
    address _pool,
    uint256 _burn_amount,
    int128 i,
    uint256 _min_amount
  ) external returns (uint256);


  function add_liquidity(
    address _pool,
    uint256[4] memory _deposit_amounts,
    uint256 _min_mint_amount
  ) external returns (uint256);

}// MIT
pragma solidity ^0.8.0;

contract EIP712 {


    function verifySignatureAgainstAuthority(
        bytes memory signature,
        address authority
    ) internal returns (bool){

        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Batcher")),
                keccak256(bytes("1")),
                1, 
                address(this)
            )
        );

        bytes32 hashStruct = keccak256(
            abi.encode(
                keccak256("deposit(address owner)"),
                msg.sender
            )
        );

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
        address signer = ecrecover(hash, v, r, s);
        require(signer == authority, "Invalid authority");
        require(signer != address(0), "ECDSA: invalid signature");
        return true;
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        require(sig.length == 65, "invalid signature length");

        assembly {

            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }

    
}// UNLICENSED
pragma solidity ^0.8.4;




contract Batcher is Ownable, IBatcher, EIP712 {

  using SafeERC20 for IERC20;

  uint256 DUST_LIMIT = 10000;

  struct Vault {
    address tokenAddress;
    uint256 maxAmount;
    uint256 currentAmount;
  }

  mapping(address => Vault) public vaults;

  mapping(address => mapping(address => uint256)) public depositLedger;
  mapping(address => mapping(address => uint256)) public withdrawLedger;

  event DepositRequest(
    address indexed sender,
    address indexed router,
    uint256 amountIn
  );
  event WithdrawRequest(
    address indexed sender,
    address indexed router,
    uint256 amountOut
  );

  address public verificationAuthority;
  address public governance;
  address public pendingGovernance;
  uint256 public slippageForCurveLp = 30;
  constructor(address _verificationAuthority, address _governance) {
    verificationAuthority = _verificationAuthority;
    governance = _governance;
  }

  function setAuthority(address authority) public onlyGovernance {

    verificationAuthority = authority;
  }

  function depositFunds(
    uint256 amountIn,
    address routerAddress,
    bytes memory signature
  ) external override validDeposit(routerAddress, signature) {

    require(
      IERC20(vaults[routerAddress].tokenAddress).allowance(
        msg.sender,
        address(this)
      ) >= amountIn,
      "No allowance"
    );

    IERC20(vaults[routerAddress].tokenAddress).safeTransferFrom(
      msg.sender,
      address(this),
      amountIn
    );

    vaults[routerAddress].currentAmount += amountIn;
    require(vaults[routerAddress].currentAmount <= vaults[routerAddress].maxAmount, "Exceeded deposit limit");

    _completeDeposit(routerAddress, amountIn);
  }

  function depositFundsInCurveLpToken(
    uint256 amountIn,
    address routerAddress,
    bytes memory signature
  ) external override validDeposit(routerAddress, signature) {

    IERC20 lpToken = IERC20(0xCEAF7747579696A2F0bb206a14210e3c9e6fB269);

    require(
      lpToken.allowance(msg.sender, address(this)) >= amountIn,
      "No allowance"
    );

    lpToken.safeTransferFrom(msg.sender, address(this), amountIn);

    uint256 usdcReceived = _convertLpTokenIntoUSDC(lpToken);

    _completeDeposit(routerAddress, usdcReceived);
  }

  function _completeDeposit(address routerAddress, uint256 amountIn) internal {

    depositLedger[routerAddress][msg.sender] =
      depositLedger[routerAddress][msg.sender] +
      (amountIn);

    emit DepositRequest(msg.sender, routerAddress, amountIn);
  }

  function withdrawFunds(uint256 amountIn, address routerAddress)
    external
    override
  {

    require(
      vaults[routerAddress].tokenAddress != address(0),
      "Invalid router address"
    );

    require(
      depositLedger[routerAddress][msg.sender] == 0,
      "Cannot withdraw funds from router while waiting to deposit"
    );


    IERC20(routerAddress).safeTransferFrom(msg.sender, address(this), amountIn);

    withdrawLedger[routerAddress][msg.sender] =
      withdrawLedger[routerAddress][msg.sender] +
      (amountIn);

    vaults[routerAddress].currentAmount -= amountIn;

    emit WithdrawRequest(msg.sender, routerAddress, amountIn);
  }

  function batchDeposit(address routerAddress, address[] memory users)
    external
    override
    onlyOwner
  {

    IMetaRouter router = IMetaRouter(routerAddress);

    uint256 amountToDeposit = 0;
    uint256 oldLPBalance = IERC20(address(router)).balanceOf(address(this));

    for (uint256 i = 0; i < users.length; i++) {
      amountToDeposit =
        amountToDeposit +
        (depositLedger[routerAddress][users[i]]);
    }

    require(amountToDeposit > 0, "no deposits to make");

    uint256 lpTokensReportedByRouter = router.deposit(
      amountToDeposit,
      address(this)
    );

    uint256 lpTokensReceived = IERC20(address(router)).balanceOf(
      address(this)
    ) - (oldLPBalance);

    require(
      lpTokensReceived == lpTokensReportedByRouter,
      "LP tokens received by router does not match"
    );

    for (uint256 i = 0; i < users.length; i++) {
      uint256 userAmount = depositLedger[routerAddress][users[i]];
      if (userAmount > 0) {
        uint256 userShare = (userAmount * (lpTokensReceived)) /
          (amountToDeposit);
        IERC20(address(router)).safeTransfer(users[i], userShare);
        depositLedger[routerAddress][users[i]] = 0;
      }
    }
  }

  function batchWithdraw(address routerAddress, address[] memory users)
    external
    override
    onlyOwner
  {

    IMetaRouter router = IMetaRouter(routerAddress);

    IERC20 token = IERC20(vaults[routerAddress].tokenAddress);

    uint256 amountToWithdraw = 0;
    uint256 oldWantBalance = token.balanceOf(address(this));

    for (uint256 i = 0; i < users.length; i++) {
      amountToWithdraw =
        amountToWithdraw +
        (withdrawLedger[routerAddress][users[i]]);
    }

    require(amountToWithdraw > 0, "no deposits to make");

    uint256 wantTokensReportedByRouter = router.withdraw(
      amountToWithdraw,
      address(this)
    );

    uint256 wantTokensReceived = token.balanceOf(address(this)) -
      (oldWantBalance);

    require(
      wantTokensReceived == wantTokensReportedByRouter,
      "Want tokens received by router does not match"
    );

    for (uint256 i = 0; i < users.length; i++) {
      uint256 userAmount = withdrawLedger[routerAddress][users[i]];
      if (userAmount > 0) {
        uint256 userShare = (userAmount * wantTokensReceived) /
          amountToWithdraw;
        token.safeTransfer(users[i], userShare);

        withdrawLedger[routerAddress][users[i]] = 0;
      }
    }
  }

  function setRouterParams(address routerAddress, address token, uint256 maxLimit)
    external
    override
    onlyOwner
  {

    require(routerAddress != address(0), "Invalid router address");
    require(token != address(0), "Invalid token address");
    vaults[routerAddress] = Vault({
      tokenAddress: token, 
      maxAmount: maxLimit,
      currentAmount: 0
    });

    IERC20(token).approve(routerAddress, type(uint256).max);
  }

  function _tokenBalance(IERC20Metadata token) internal view returns (uint256) {

    return token.balanceOf(address(this));
  }

  function sweep(address _token) public onlyGovernance {

    IERC20(_token).transfer(
      msg.sender,
      IERC20(_token).balanceOf(address(this))
    );
  }

  function setGovernance(address _governance) external onlyGovernance {

    pendingGovernance = _governance;
  }

  function acceptGovernance() external {

    require(
      msg.sender == pendingGovernance,
      "Only pending governance can accept"
    );
    governance = pendingGovernance;
  }

  function _convertLpTokenIntoUSDC(IERC20 lpToken)
    internal
    returns (uint256 receivedWantTokens)
  {

    uint256 MAX_BPS = 10000;

    ICurvePool ust3Pool = ICurvePool(
      0xCEAF7747579696A2F0bb206a14210e3c9e6fB269
    );
    ICurveDepositZapper curve3PoolZap = ICurveDepositZapper(
      0xA79828DF1850E8a3A3064576f380D90aECDD3359
    );

    uint256 _amount = lpToken.balanceOf(address(this));

    lpToken.safeApprove(address(curve3PoolZap), _amount);

    int128 usdcIndexInPool = int128(int256(uint256(2)));

    uint256 expectedWantTokensOut = curve3PoolZap.calc_withdraw_one_coin(
      address(ust3Pool),
      _amount,
      usdcIndexInPool
    );
    receivedWantTokens = curve3PoolZap.remove_liquidity_one_coin(
      address(ust3Pool),
      _amount,
      usdcIndexInPool,
      (expectedWantTokensOut * (MAX_BPS - slippageForCurveLp)) / (MAX_BPS)
    );
  }


  function setSlippage(uint256 _slippage) external override onlyOwner {

    require(
      _slippage >= 0 && _slippage <= 10000,
      "Slippage must be between 0 and 10000"
    );
    slippageForCurveLp = _slippage;
  }

  modifier onlyGovernance() {

    require(governance == msg.sender, "Only governance can call this");
    _;
  }

  modifier validDeposit(address routerAddress, bytes memory signature) {

    require(
      verifySignatureAgainstAuthority(signature, verificationAuthority),
      "Signature is not valid"
    );

    require(
      vaults[routerAddress].tokenAddress != address(0),
      "Invalid router address"
    );

    require(
      withdrawLedger[routerAddress][msg.sender] == 0,
      "Cannot deposit funds to router while waiting to withdraw"
    );

    _;
  }
}