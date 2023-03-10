pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.8.0;


interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

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

}
pragma solidity ^0.8.0;


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

interface IReimbursement {

    function getLicenseeFee(address licenseeVault, address projectContract) external view returns(uint256); // return fee percentage with 2 decimals

    function getVaultOwner(address vault) external view returns(address);

    function requestReimbursement(address user, uint256 feeAmount, address licenseeVault) external returns(address);

}

interface IBEP20 {

    function balanceOf(address account) external view returns (uint256);

}

contract UniswapIntermediateAgent is Ownable{

    using TransferHelper for address;
    
    IReimbursement public reimbursementContract;
    address public companyVault;    // the vault address of our company registered in reimbursement contract
    mapping(address => uint256) public routerInterface; // type on router interface: 0 = uniswap, 1 = BSCswap
    address public feeReceiver; // address which receive the fee (by default is validator)

    constructor(address _reimbursementContract) {      
        reimbursementContract = IReimbursement(_reimbursementContract);
    }

    function getColletedFees() external view returns (uint256) {

        return address(this).balance;
    }

    function claimFee() external returns (uint256 feeAmount)
    {

        require(msg.sender == feeReceiver);
        feeAmount = address(this).balance;
        TransferHelper.safeTransferETH(msg.sender, feeAmount);
    }

    function setFeeReceiver(address _addr) external onlyOwner {

        feeReceiver = _addr;
    }

    function rescueTokens(address someToken) external onlyOwner {

        uint256 available = IBEP20(someToken).balanceOf(address(this));
        TransferHelper.safeTransfer(someToken, msg.sender, available);
    }

    function setReimbursement(address _reimbursement)external onlyOwner{

        require(_reimbursement != address(0), "Invalid address");
        reimbursementContract = IReimbursement(_reimbursement);
    }

    function setCompanyVault(address _vault) external onlyOwner{

        companyVault = _vault;
    }

    function setRouterInterface(address _router, uint256 _type) external onlyOwner {

        routerInterface[_router] = _type;
    }

    event Swap(
        address indexed user,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    );
        
    function getFee(
        address fromToken,  // address(0) means native coin (ETH, BNB)
        uint256 amountIn, 
        address licensee,
        address uniV2Router   // Uniswap-compatible router address
    ) 
    external
    view
    returns(uint256) 
    {

        uint256 feeLicensee;
        uint256 feeBswap;
        address[] memory tempPath = new address[](2);
        uint256 licenseeFeeRate = reimbursementContract.getLicenseeFee(licensee, address(this));
        uint256 feeRate = reimbursementContract.getLicenseeFee(companyVault, address(this));
        if (routerInterface[uniV2Router] == 1) {
        } else {
            tempPath[1] = IUniswapV2Router02(uniV2Router).WETH();
        }
        if(fromToken == address(0) || fromToken == tempPath[1]) {
            feeLicensee = amountIn * licenseeFeeRate / 10000;
            feeBswap = amountIn * feeRate / 10000;
        }
        else {
                tempPath[0] = fromToken;
                uint256[] memory totalFeeAmt = IUniswapV2Router02(uniV2Router).getAmountsOut(amountIn, tempPath); 
                feeBswap = totalFeeAmt[1] * feeRate / 10000;
                
                if(licenseeFeeRate>0){
                    feeLicensee = totalFeeAmt[1] * licenseeFeeRate / 10000;
                }
        }
        return feeBswap + feeLicensee;
    }

    function swap(
        address payable licensee,
        uint256 amountIn,                                                       // amount of token to swap
        uint256 amountOut,                                                      // minimum amount of token to receive
        address[] memory path,                                                  // address(0) means native coin (ETH, BNB)
        uint256 deadline,
        uint256 swapType,                                                        // allow to choose the correct swap function: 
        address uniV2Router   // Uniswap-compatible router address
    ) 
        external
        payable
        returns (uint256[] memory amounts) 
    {

        if (routerInterface[uniV2Router] == 1) {
        } else {
            return swapUni(licensee, amountIn, amountOut, path, deadline, swapType, IUniswapV2Router02(uniV2Router));
        }
    }

    function swapUni(
        address payable licensee,
        uint256 amountIn,                                                       // amount of token to swap
        uint256 amountOut,                                                      // minimum amount of token to receive
        address[] memory path,                                                  // address(0) means native coin (ETH, BNB)
        uint256 deadline,
        uint256 swapType,                                                        // allow to choose the correct swap function: 
        IUniswapV2Router02 uniV2Router   // Uniswap-compatible router address
    ) 
        internal
        returns (uint256[] memory amounts) 
    {

        bool toETH;
        bool fromETH;
        uint256 totalGas = gasleft();
        uint256 totalFee;
        totalFee = msg.value;                                                   // assume that all coins that user send is a fee
    
        if (path[0] == address(0)) {                                             // swap from native coin (ETH, BNB)
            totalFee = totalFee - amountIn;                                   // separate fee from swapping value
            path[0] = uniV2Router.WETH();
            fromETH = true;
        } else {                                                                 // transfer token from user and approve to Router
            path[0].safeTransferFrom(msg.sender, address(this), amountIn);
            path[0].safeApprove(address(uniV2Router), amountIn);        
        }
    
        if (path[path.length-1] == address(0)) {                                 // swap to native coin (ETH, BNB)
            path[path.length-1] = uniV2Router.WETH();
            toETH = true;
        }
        
        require (!fromETH || !toETH, "Swapping from ETH to ETH is forbidden");

        if (swapType == 0) {                    
            if (fromETH) {
                amounts = uniV2Router.swapExactETHForTokens{value: amountIn}(
                    0,
                    path,
                    msg.sender,
                    deadline
                );
            } else if (toETH) {
                amounts = uniV2Router.swapExactTokensForETH(
                    amountIn,
                    amountOut,
                    path,
                    payable(msg.sender),
                    deadline
                );            
            } else {
                amounts = uniV2Router.swapExactTokensForTokens(
                    amountIn,
                    amountOut,
                    path,
                    msg.sender,
                    deadline
                );
            }
        } else if (swapType == 1) {
            if (fromETH) {
                uniV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(
                    0,
                    path,
                    msg.sender,
                    deadline
                );
            } else if (toETH) {
                uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    amountIn,
                    amountOut,
                    path,
                    payable(msg.sender),
                    deadline
                );            
            } else {
                uniV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amountIn,
                    amountOut,
                    path,
                    msg.sender,
                    deadline
                );
            }
        } else if (swapType == 2) {
            if (fromETH) {
                amounts = uniV2Router.swapETHForExactTokens{value: amountIn}(
                    amountOut,
                    path,
                    msg.sender,
                    deadline
                );
                
                if(amountIn - amounts[0] > 0){
                    payable(msg.sender).transfer(amountIn - amounts[0]);
                }

            } else if (toETH) {
                amounts = uniV2Router.swapTokensForExactETH(
                    amountOut,
                    amountIn,
                    path,
                    payable(msg.sender),
                    deadline
                );
                
                if(amountIn - amounts[0] > 0){
                    path[0].safeTransfer(msg.sender, (amountIn - amounts[0]));
                }
            } else {
                amounts = uniV2Router.swapTokensForExactTokens(
                    amountOut,
                    amountIn,
                    path,
                    msg.sender,
                    deadline
                );
                
                if(amountIn - amounts[0] > 0){
                    path[0].safeTransfer(msg.sender, (amountIn - amounts[0]));
                }
            }
        }else { 
            revert("Wrong type");
        }
    
        processFee(totalGas, totalFee, licensee, msg.sender);

        emit Swap(msg.sender, path[0], path[1], amountIn, amounts[1]);      // emit swap event
    }


    function processFee(uint256 txGas, uint256 feeAmount, address licenseeVault, address user) internal {

        if (address(reimbursementContract) == address(0)) {
            payable(user).transfer(feeAmount); // return fee to sender if no reimbursement contract
            return;
        }

        uint256 licenseeFeeRate = reimbursementContract.getLicenseeFee(licenseeVault, address(this));
        uint256 companyFeeRate = reimbursementContract.getLicenseeFee(companyVault, address(this));
        uint256 licenseeFeeAmount = (feeAmount * licenseeFeeRate)/(licenseeFeeRate + companyFeeRate);
        if (licenseeFeeAmount != 0) {
            address licenseeFeeTo = reimbursementContract.requestReimbursement(user, licenseeFeeAmount, licenseeVault);
            if (licenseeFeeTo == address(0)) {
                payable(user).transfer(licenseeFeeAmount);    // refund to user
            } else {
                payable(licenseeFeeTo).transfer(licenseeFeeAmount);  // transfer to fee receiver
            }
        }
        feeAmount -= licenseeFeeAmount; // company's part of fee

        txGas -= gasleft(); // get gas amount that was spent on Licensee fee
        txGas = txGas * tx.gasprice;
        reimbursementContract.requestReimbursement(user, feeAmount+txGas, companyVault);
    }
    
    receive() external payable {}
}
