
pragma solidity ^0.8.0;


abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(),"Not Owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface ISwapFactory {

    function swap(address tokenA, address tokenB, uint256 amount, address user, uint256 crossOrderType, uint256 dexId, uint256 deadline) 
    external payable returns (bool);

}

library TransferHelper {

    function safeApprove(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

}

interface IUni {


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable
    returns (uint[] memory amounts);

    
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) 
    external 
    returns (uint[] memory amounts);


    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);


    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);


    function WETH() external pure returns (address);


}

interface IReimbursement {

    function getLicenseeFee(address licenseeVault, address projectContract) external view returns(uint256); // return fee percentage with 2 decimals

    function getVaultOwner(address vault) external view returns(address);

    function requestReimbursement(address user, uint256 feeAmount, address licenseeVault) external returns(address);

}

contract Degen is Ownable {

    using TransferHelper for address;
    enum OrderType {EthForTokens, TokensForEth, TokensForTokens, EthForEth}
    
    IUni public Uni = IUni(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //mainnet network address for uniswap (valid for Ropsten as well)
    IUni public Sushi = IUni(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // Mainnet network address for sushiswap
    address public USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT Token Address
    address public system;
    uint256 public processingFee = 0 ;
    
    uint256 private deadlineLimit = 20*60;      // 20 minutes by default 
    
    uint256 private collectedFees = 1; // amount of collected fee (starts from 1 to avoid additional gas usage)
    address public feeReceiver; // address which receive the fee (by default is validator)


    IReimbursement public reimbursementContract;      // reimbursement contract address

    address public companyVault;    // the vault address of our company registered in reimbursement contract

    ISwapFactory public swapFactory;
   
    modifier onlySystem() {

        require(msg.sender == system || owner() == msg.sender,"Caller is not the system");
        _;
    }
    
    constructor(address _swapFactory, address _system) 
    {
        swapFactory = ISwapFactory(_swapFactory);
        system = _system;
    }
    

    function setCompanyVault(address _comapnyVault) external onlyOwner {

        companyVault = _comapnyVault;
    }

    function setReimbursementContract(address _reimbursementContarct) external onlyOwner {

        reimbursementContract = IReimbursement(_reimbursementContarct);
    }

    function setProcessingFee(uint256 _processingFees) external onlySystem {

        processingFee = _processingFees;
    }

    function setSwapFactory(address _swapFactory) external onlyOwner {

        swapFactory = ISwapFactory(_swapFactory);
    }
    
    function setSystem(address _system) external onlyOwner {

        system = _system;
    }
    
    function setFeeReceiver(address _addr) external onlyOwner {

        feeReceiver = _addr;
    }
    
    function getDeadlineLimit() public view returns(uint256) {

        return deadlineLimit;
    }
    
    function setDeadlineLimit(uint256 limit) external onlyOwner {

        deadlineLimit = limit;
    }

    function getColletedFees() external view returns (uint256) {

        return collectedFees - 1;
    }

    function claimFee() external returns (uint256 feeAmount) {

        require(msg.sender == feeReceiver, "This fee can be claimed only by fee receiver!!");
        feeAmount = collectedFees - 1;
        collectedFees = 1;        
        TransferHelper.safeTransferETH(msg.sender, feeAmount);
    }
    
    

    function processFee(uint256 txGas, uint256 feeAmount, uint256 processing, address licenseeVault, address user) internal {

        if (address(reimbursementContract) == address(0)) {
            payable(user).transfer(feeAmount); // return fee to sender if no reimbursement contract
            return;
        }
        
        uint256 licenseeFeeAmount;
        if (licenseeVault != address(0)) {
            uint256 companyFeeRate = reimbursementContract.getLicenseeFee(companyVault, address(this));
            uint256 licenseeFeeRate = reimbursementContract.getLicenseeFee(licenseeVault, address(this));
            if (licenseeFeeRate != 0)
                licenseeFeeAmount = (feeAmount * licenseeFeeRate)/(licenseeFeeRate + companyFeeRate);
            if (licenseeFeeAmount != 0) {
                address licenseeFeeTo = reimbursementContract.requestReimbursement(user, licenseeFeeAmount, licenseeVault);
                if (licenseeFeeTo == address(0)) {
                    payable(user).transfer(licenseeFeeAmount);    // refund to user
                } else {
                    payable(licenseeFeeTo).transfer(licenseeFeeAmount);  // transfer to fee receiver
                }
            }
        }
        feeAmount -= licenseeFeeAmount; // company's part of fee
        collectedFees += feeAmount; 
        
        if (processing != 0) 
            payable(system).transfer(processing);  // transfer to fee receiver
        
        txGas -= gasleft(); // get gas amount that was spent on Licensee fee
        txGas = txGas * tx.gasprice;
        reimbursementContract.requestReimbursement(user, feeAmount+txGas+processing, companyVault);
    }
    
    
    function _swap( 
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered,
        uint256 minExpectedAmount, 
        address to,
        uint256 dexId,
        uint256 deadline
    ) internal returns(uint256 amountOut) {

         
        require(dexId < 2, "Invalid DEX Id!");
        require(deadline >= block.timestamp, "EXPIRED: Deadline for transaction already passed.");

       if(dexId == 0){
            uint[] memory swapResult;
            if(orderType == OrderType.EthForTokens) {
                 path[0] = Uni.WETH();
                 swapResult = Uni.swapExactETHForTokens{value:assetInOffered}(0, path, to,block.timestamp);
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = Uni.WETH();
                TransferHelper.safeApprove(path[0], address(Uni), assetInOffered);
                swapResult = Uni.swapExactTokensForETH(assetInOffered, 0, path,to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForTokens) {
                TransferHelper.safeApprove(path[0], address(Uni), assetInOffered);
                swapResult = Uni.swapExactTokensForTokens(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
            amountOut = swapResult[swapResult.length - 1];
        } else if(dexId == 1) {
            uint[] memory swapResult;
            if(orderType == OrderType.EthForTokens) {
                 path[0] = Sushi.WETH();
                 swapResult = Sushi.swapExactETHForTokens{value:assetInOffered}(minExpectedAmount, path, to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = Sushi.WETH();
                TransferHelper.safeApprove(path[0], address(Sushi), assetInOffered);
                swapResult = Sushi.swapExactTokensForETH(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForTokens) {
                TransferHelper.safeApprove(path[0], address(Sushi), assetInOffered);
                swapResult = Sushi.swapExactTokensForTokens(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
            amountOut = swapResult[swapResult.length - 1];
        }
    }
    
    function executeSwap(
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered, 
        uint256 fees, 
        uint256 minExpectedAmount,
        address licenseeVault,
        uint256 dexId,
        uint256 deadline
    ) external payable {

        uint256 gasA = gasleft();
        uint256 receivedFees = 0;
        if(deadline == 0) {
            deadline = block.timestamp + deadlineLimit;
        }
        
        if(orderType == OrderType.EthForTokens){
            require(msg.value >= (assetInOffered + fees), "Payment = assetInOffered + fees");
            receivedFees = receivedFees + msg.value - assetInOffered;
        } else {
            require(msg.value >= fees, "fees not received");
            receivedFees = receivedFees + msg.value;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
        }
        
        _swap(orderType, path, assetInOffered, minExpectedAmount, msg.sender, dexId, deadline);
   
        processFee(gasA, receivedFees, 0, licenseeVault, msg.sender);
    }
    
    function executeCrossExchange(
        address[] memory path, 
        OrderType orderType,
        uint256 crossOrderType,
        uint256 assetInOffered,
        uint256 fees, 
        uint256 minExpectedAmount,
        address licenseeVault,
        uint256[3] memory dexId_deadline // dexId_deadline[0] - native swap dexId, dexId_deadline[1] - foreign swap dexId, dexId_deadline[2] - deadline
    ) public payable {

        uint256[2] memory feesPrice;
        feesPrice[0] = gasleft();       // equivalent to gasA
        feesPrice[1] = 0;               // processing fees
        
        if (dexId_deadline[2] == 0) {   // if deadline == 0, set deadline to deadlineLimit
            dexId_deadline[2] = block.timestamp + deadlineLimit;
        }

        if(orderType == OrderType.EthForTokens){
            require(msg.value >= (assetInOffered + fees + processingFee), "Payment = assetInOffered + fees + processingFee");
            feesPrice[1] = msg.value - assetInOffered - fees;
        } else {
            require(msg.value >= (fees + processingFee), "fees not received");
            feesPrice[1] = msg.value - fees;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
        }
        
        if(path[0] == USDT) {
            TransferHelper.safeApprove(USDT, address(swapFactory), assetInOffered);
            swapFactory.swap(USDT, path[path.length-1], assetInOffered, msg.sender, crossOrderType, dexId_deadline[1], dexId_deadline[2]);
        }
        else {
            address tokenB = path[path.length-1];
            path[path.length-1] = USDT;
            uint256 minAmountExpected = _swap(orderType, path, assetInOffered, minExpectedAmount, address(this), dexId_deadline[0], dexId_deadline[2]);
                
            TransferHelper.safeApprove(USDT, address(swapFactory),minAmountExpected);
            swapFactory.swap(USDT, tokenB, minAmountExpected, msg.sender, crossOrderType, dexId_deadline[1], dexId_deadline[2]);
        }        

        processFee(feesPrice[0], fees, feesPrice[1], licenseeVault, msg.sender);
    }

    function callbackCrossExchange( 
        uint256 orderType, 
        address[] memory path, 
        uint256 assetInOffered, 
        address user,
        uint256 dexId,
        uint256 deadline
    ) public returns(bool) {

        require(msg.sender == address(swapFactory) , "Degen : caller is not SwapFactory");
        if(deadline==0) {
            deadline = block.timestamp + deadlineLimit;
        }
        _swap(OrderType(orderType), path, assetInOffered, uint256(0), user, dexId, deadline);
        return true;
    }

    function executeSwap1Inch(
        address[2] memory path, // path[0] - from token, path[1] - to token
        OrderType orderType, 
        uint256 assetInOffered, // token amount or value of ETH (Form API response).
        uint256 fees, 
        address licenseeVault,
        address to, // 1Inch router. Form API response.
        bytes memory data   // Form API response.
    ) external payable {

        uint256 gasA = gasleft();
        uint256 receivedFees;
        uint256 value;
        
        if(orderType == OrderType.EthForTokens){
            require(msg.value >= (assetInOffered + fees), "Payment = assetInOffered + fees");
            receivedFees = msg.value - assetInOffered;
            value = assetInOffered;
        } else {
            require(msg.value >= fees, "fees not received");
            receivedFees = msg.value;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
            TransferHelper.safeApprove(path[0],to,assetInOffered);
        }
        
        callTo(to, value, data);
   
        processFee(gasA, receivedFees, 0, licenseeVault, msg.sender);
    }
    
    function executeCrossExchange1Inch(
        address[2] memory path, // path[0] - from token, path[1] - to token
        OrderType crossOrderType, 
        uint256 assetInOffered, // token amount or value of ETH (Form API response).
        uint256 fees, 
        address licenseeVault,
        address to, // 1Inch router. Form API response.
        bytes memory data,   // Form API response.
        uint256 toDEX,  // destination dex that will be used on foreign chain.
        uint256 deadline
    ) external payable {

        uint256 gasA = gasleft();
        uint256 _crossOrderType = uint256(crossOrderType);
        uint256 value;
        
        if(deadline==0) {
            deadline = block.timestamp + deadlineLimit;
        }
        
        if(crossOrderType == OrderType.EthForTokens || crossOrderType == OrderType.EthForEth){
            require(msg.value >= (assetInOffered + fees), "Payment = assetInOffered + fees");
            fees = msg.value - assetInOffered;
            value = assetInOffered;
        } else {
            require(msg.value >= fees, "fees not received");
            fees = msg.value;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
            TransferHelper.safeApprove(path[0],to,assetInOffered);
        }
               
        uint256 balanceUSDT = IERC20(USDT).balanceOf(address(this));
        callTo(to, value, data);
        balanceUSDT = IERC20(USDT).balanceOf(address(this)) - balanceUSDT;  // USDT amount that received from 1Inch swap
        TransferHelper.safeApprove(USDT, address(swapFactory), balanceUSDT);
        
        swapFactory.swap(USDT, path[1], balanceUSDT, msg.sender, _crossOrderType, toDEX, deadline);

        processFee(gasA, fees, 0, licenseeVault, msg.sender);
    }

    function callTo(address to, uint256 value, bytes memory data) internal {

        (bool success,) = to.call{value: value}(data);
        require(success, "call to contract error");
    }

    function rescueTokens(address _token) external onlyOwner {

        if (address(0) == _token) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            uint256 available = IERC20(_token).balanceOf(address(this));
            TransferHelper.safeTransfer(_token, msg.sender, available);
        }
    }

}