
pragma solidity >=0.8.0;

interface IRevest {

    event FNFTTimeLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        uint endTime,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTValueLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        address compareTo,
        address oracleDispatch,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTAddressLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        address trigger,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTWithdrawn(
        address indexed from,
        uint indexed fnftId,
        uint indexed quantity
    );

    event FNFTSplit(
        address indexed from,
        uint[] indexed newFNFTId,
        uint[] indexed proportions,
        uint quantity
    );

    event FNFTUnlocked(
        address indexed from,
        uint indexed fnftId
    );

    event FNFTMaturityExtended(
        address indexed from,
        uint indexed fnftId,
        uint indexed newExtendedTime
    );

    event FNFTAddionalDeposited(
        address indexed from,
        uint indexed newFNFTId,
        uint indexed quantity,
        uint amount
    );

    struct FNFTConfig {
        address asset; // The token being stored
        address pipeToContract; // Indicates if FNFT will pipe to another contract
        uint depositAmount; // How many tokens
        uint depositMul; // Deposit multiplier
        uint split; // Number of splits remaining
        uint depositStopTime; //
        bool maturityExtension; // Maturity extensions remaining
        bool isMulti; //
        bool nontransferrable; // False by default (transferrable) //
    }

    struct TokenTracker {
        uint lastBalance;
        uint lastMul;
    }

    enum LockType {
        DoesNotExist,
        TimeLock,
        ValueLock,
        AddressLock
    }

    struct LockParam {
        address addressLock;
        uint timeLockExpiry;
        LockType lockType;
        ValueLock valueLock;
    }

    struct Lock {
        address addressLock;
        LockType lockType;
        ValueLock valueLock;
        uint timeLockExpiry;
        uint creationTime;
        bool unlocked;
    }

    struct ValueLock {
        address asset;
        address compareTo;
        address oracle;
        uint unlockValue;
        bool unlockRisingEdge;
    }

    function mintTimeLock(
        uint endTime,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function mintValueLock(
        address primaryAsset,
        address compareTo,
        uint unlockValue,
        bool unlockRisingEdge,
        address oracleDispatch,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function mintAddressLock(
        address trigger,
        bytes memory arguments,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function withdrawFNFT(uint tokenUID, uint quantity) external;


    function unlockFNFT(uint tokenUID) external;


    function splitFNFT(
        uint fnftId,
        uint[] memory proportions,
        uint quantity
    ) external returns (uint[] memory newFNFTIds);


    function depositAdditionalToFNFT(
        uint fnftId,
        uint amount,
        uint quantity
    ) external returns (uint);


    function setFlatWeiFee(uint wethFee) external;


    function setERC20Fee(uint erc20) external;


    function getFlatWeiFee() external returns (uint);


    function getERC20Fee() external returns (uint);



}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IAddressRegistry {


    function initialize(
        address lock_manager_,
        address liquidity_,
        address revest_token_,
        address token_vault_,
        address revest_,
        address fnft_,
        address metadata_,
        address admin_,
        address rewards_
    ) external;


    function getAdmin() external view returns (address);


    function setAdmin(address admin) external;


    function getLockManager() external view returns (address);


    function setLockManager(address manager) external;


    function getTokenVault() external view returns (address);


    function setTokenVault(address vault) external;


    function getRevestFNFT() external view returns (address);


    function setRevestFNFT(address fnft) external;


    function getMetadataHandler() external view returns (address);


    function setMetadataHandler(address metadata) external;


    function getRevest() external view returns (address);


    function setRevest(address revest) external;


    function getDEX(uint index) external view returns (address);


    function setDex(address dex) external;


    function getRevestToken() external view returns (address);


    function setRevestToken(address token) external;


    function getRewardsHandler() external view returns(address);


    function setRewardsHandler(address esc) external;


    function getAddress(bytes32 id) external view returns (address);


    function getLPs() external view returns (address);


    function setLPs(address liquidToken) external;


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface IFeeReporter {


    function getFlatWeiFee(address asset) external view returns (uint);


    function getERC20Fee(address asset) external view returns (uint);


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IRewardsHandler {


    struct UserBalance {
        uint allocPoint; // Allocation points
        uint lastMul;
    }

    function receiveFee(address token, uint amount) external;


    function updateLPShares(uint fnftId, uint newShares) external;


    function updateBasicShares(uint fnftId, uint newShares) external;


    function getAllocPoint(uint fnftId, address token, bool isBasic) external view returns (uint);


    function claimRewards(uint fnftId, address caller) external returns (uint);


    function setStakingContract(address stake) external;


    function getRewards(uint fnftId, address token) external view returns (uint);

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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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
}// UNLICENSED

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external view returns (address);

    function WETH() external view returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}// UNLICENSED

pragma solidity >=0.8;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}// GNU-GPL v3.0 or later
pragma solidity ^0.8.0;




interface IWETH {

    function deposit() external payable;

}

contract CashFlowManagement is Ownable, IFeeReporter, ReentrancyGuard {

    
    using SafeERC20 for IERC20;

    address private immutable UNISWAP_V2_ROUTER;
    address private immutable WETH;

    uint private constant MAX_INT = 2**256 - 1;

    address public addressRegistry;
    uint public constant PRECISION = 1 ether;

    uint internal erc20Fee = 2;
    uint internal weiFee;

    mapping(uint => uint) private approved;

    mapping(address => mapping(address => bool)) private approvedContracts;

    constructor(address registry_, address router_, address weth_) {
        UNISWAP_V2_ROUTER = router_;
        addressRegistry = registry_;
        WETH = weth_;
    }

    function mintTimeLock(
        uint[] memory endTimes,
        uint[] memory amountPerPeriod,
        address[] memory pathToSwaps,
        uint slippage // slippage / PRECISION = fraction that represents actual slippage
    ) external payable nonReentrant returns (uint[] memory fnftIds) {

        require(endTimes.length == amountPerPeriod.length, "Invalid arrays");
        require(pathToSwaps.length > 1, "Path to swap should be greater than 1");
        require(msg.value >= weiFee, 'Insufficient fees!');

        bool upfrontPayment = endTimes[0] == 0; // This is the easiest way to indicate immediate payment
        uint totalAmountReceived;
        uint mul;
        {
            uint totalAmountToSwap;
            for (uint i; i < amountPerPeriod.length; i++) {
                totalAmountToSwap += amountPerPeriod[i];
            }
            
            IERC20(pathToSwaps[0]).safeTransferFrom(
                msg.sender,
                address(this),
                totalAmountToSwap
            );

            
            {
                uint[] memory amountsOut = IUniswapV2Router02(UNISWAP_V2_ROUTER).getAmountsOut(totalAmountToSwap, pathToSwaps);
                uint amtOut = amountsOut[amountsOut.length - 1];


                if(!_isApproved(pathToSwaps[0])) {
                    IERC20(pathToSwaps[0]).approve(UNISWAP_V2_ROUTER, MAX_INT);
                    _setIsApproved(pathToSwaps[0], true);
                }

                IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        totalAmountToSwap,
                        amtOut * (PRECISION - slippage) / PRECISION,
                        pathToSwaps,
                        address(this),
                        block.timestamp
                    );
            }
            totalAmountReceived = IERC20(pathToSwaps[pathToSwaps.length - 1]).balanceOf(address(this)) * (1000 - erc20Fee) / 1000;
            mul = PRECISION * totalAmountReceived / totalAmountToSwap;
        }
        

        IRevest.FNFTConfig memory fnftConfig;

        fnftConfig.asset = pathToSwaps[pathToSwaps.length - 1];

        address[] memory recipients = new address[](1);
        recipients[0] = msg.sender;

        uint[] memory quantities = new uint[](1);
        quantities[0] = 1;

        if(upfrontPayment) {
            fnftIds = new uint[](endTimes.length - 1);

        } else {
            fnftIds = new uint[](endTimes.length);
        }
        
        
        {
            address revest = IAddressRegistry(addressRegistry).getRevest();
            if (!approvedContracts[revest][fnftConfig.asset]) {
                IERC20(fnftConfig.asset).approve(revest, MAX_INT);
                approvedContracts[revest][fnftConfig.asset] = true;
            }
            
            for (uint i; i < endTimes.length; i++) {
                if(i == 0 && upfrontPayment) {
                    uint payAmt;
                    if(i == endTimes.length - 1 ) {
                        payAmt = totalAmountReceived;
                    } else {
                        payAmt = amountPerPeriod[i] * mul / PRECISION;
                    }
                    IERC20(fnftConfig.asset).safeTransfer(msg.sender, payAmt);
                    totalAmountReceived -= payAmt;
                } else {
                    if(i == endTimes.length - 1 ) {
                        fnftConfig.depositAmount = totalAmountReceived;
                    } else {
                        fnftConfig.depositAmount = amountPerPeriod[i] * mul / PRECISION;
                    }

                    fnftIds[(upfrontPayment && i > 0) ? i - 1 : i] = IRevest(revest).mintTimeLock{value: (msg.value - weiFee) / endTimes.length}(endTimes[i], recipients, quantities, fnftConfig);
                    totalAmountReceived -= fnftConfig.depositAmount;
                }
            }

            if(erc20Fee > 0) {
                address admin = IAddressRegistry(addressRegistry).getAdmin();
                uint bal = IERC20(fnftConfig.asset).balanceOf(address(this));
                IERC20(fnftConfig.asset).safeTransfer(admin, bal);
            }
            if(weiFee > 0) {
                address rewards = IAddressRegistry(addressRegistry).getRewardsHandler();
                IWETH(WETH).deposit{value:weiFee}();
                if(!approvedContracts[rewards][WETH]) {
                    IERC20(WETH).approve(rewards, MAX_INT);
                    approvedContracts[rewards][WETH] = true;
                }
                IRewardsHandler(rewards).receiveFee(WETH, weiFee);
            }
        }
    }

    function setERC20Fee(uint fee) external onlyOwner {

        erc20Fee = fee;
    }

    function setWeiFee(uint weiFee_) external onlyOwner {

        weiFee = weiFee_;
    }

    function setAddressRegistry(address _registry) external onlyOwner {

        addressRegistry = _registry;
    }

    function _isApproved(address _owner) internal view returns (bool) {

        uint _id = uint(uint160(_owner));
        uint _mask = 1 << _id % 256;
        return (approved[_id / 256] & _mask) != 0;
    }

    function _setIsApproved(address _owner, bool _isApprove) internal {

        uint _id = uint(uint160(_owner));
        if (_isApprove) {
            approved[_id / 256] |= 1 << _id % 256;
        } else {
            approved[_id / 256] &= 0 << _id % 256;
        }
    }

    function getERC20Fee(address) external view override returns (uint) {

        return erc20Fee;
    }

    function getFlatWeiFee(address) external view override returns (uint) {

        return weiFee;
    }

}