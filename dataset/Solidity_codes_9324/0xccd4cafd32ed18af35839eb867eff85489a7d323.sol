
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

    function swap(address tokenA, address tokenB, uint256 amount, address user, uint256 OrderType, uint256 dexId, uint256[] memory distribution, uint256 deadline) 
    external payable returns (bool);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    function mint(address to, uint256 amount) external returns(bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface I1inch {


    function swap(IERC20 fromToken, IERC20 destToken, uint256 amount, uint256 minReturn, uint256[] calldata distribution, uint256 flags)
    external payable returns(uint256);

    
    function getExpectedReturn(IERC20 fromToken, IERC20 toToken, uint256 amount, uint256 parts, uint256 featureFlags) 
    external view returns(uint256, uint256[] calldata);


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


interface IGatewayVault {

    function vaultTransfer(address token, address recipient, uint256 amount) external returns (bool);

    function vaultApprove(address token, address spender, uint256 amount) external returns (bool);

}

library DisableFlags {

    function enabled(uint256 disableFlags, uint256 flag) internal pure returns(bool) {

        return (disableFlags & flag) == 0;
    }

    function disabledReserve(uint256 disableFlags, uint256 flag) internal pure returns(bool) {

        return enabled(disableFlags, flag);
    }

    function disabled(uint256 disableFlags, uint256 flag) internal pure returns(bool) {

        return (disableFlags & flag) != 0;
    }
}

interface IReimbursement {

    function getLicenseeFee(address licenseeVault, address projectContract) external view returns(uint256); // return fee percentage with 2 decimals

    function getVaultOwner(address vault) external view returns(address);

    function requestReimbursement(address user, uint256 feeAmount, address licenseeVault) external returns(address);

}


abstract contract Router {
    using DisableFlags for uint256;
     
    uint256 public constant FLAG_UNISWAP = 0x01;
    uint256 public constant FLAG_SUSHI = 0x02;
    uint256 public constant FLAG_1INCH = 0x04;

    uint256 public constant totalDEX = 3;            // Total no of DEX aggregators or exchanges used
    
    mapping (address => uint256) _disabledDEX;
    enum OrderType {EthForTokens, TokensForEth, TokensForTokens}

    event Received(address, uint);
    event Error(address);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        revert();
    }
    
    event Caught(string stringFailure,uint index,uint256 amount);

    I1inch OneSplit;
    IUni Uni;
    IUni Sushi;
    IUni public uniV2Router;            // uniswap compatible router where we have to feed company token pair
    
    address constant ETH = address(0);


    constructor(address _Uni, address _sushi, address _oneSplit) payable {
        OneSplit = I1inch(_oneSplit);
        Uni = IUni(_Uni);
        Sushi = IUni(_sushi);
    }
    
    function setDisabledDEX(uint256 _disableFlag) external returns(bool) {
        _disabledDEX[msg.sender] = _disableFlag;
        return true;
    }
    
    function getDisabledDEX(address account) public view returns(uint256) {
        return _disabledDEX[account];
    }
    
    function calculateUniswapReturn( uint256 amountIn, address[] memory path, OrderType orderType,uint256 /*disableFlags*/) public view returns(uint256, uint256[] memory) {
        uint256[] memory uniAmounts =new uint[](path.length);
        uint256[] memory distribution;

        uniAmounts[path.length-1] = uint256(0);
        
        if(orderType == OrderType.EthForTokens){
            path[0] = Uni.WETH();
            try Uni.getAmountsOut(amountIn, path)returns(uint256[] memory _amounts) {
                uniAmounts = _amounts;
            }
            catch{}
        } 
        else if(orderType == OrderType.TokensForEth){
            path[path.length-1] = Uni.WETH();
            try Uni.getAmountsOut(amountIn, path)returns(uint256[] memory _amounts) {
                uniAmounts = _amounts;
            }catch{}
        } 
        else{
            try Uni.getAmountsOut(amountIn, path)returns(uint256[] memory _amounts) {
                uniAmounts = _amounts;
            }catch{}
        }
        
        return (uniAmounts[path.length-1],distribution);

    }
    
    function calculateSushiReturn( uint256 amountIn, address[] memory path, OrderType orderType,uint256 /*disableFlags*/) public view returns(uint256, uint256[] memory) {
        uint256[] memory sushiAmounts =new uint[](path.length);
        uint256[] memory distribution;

        sushiAmounts[path.length-1] = uint256(0);
        
        if(orderType == OrderType.EthForTokens){
            try Sushi.getAmountsOut(amountIn, path) returns(uint256[] memory _amounts) {
                sushiAmounts = _amounts;
            }catch{}
        } 
        else if(orderType == OrderType.TokensForEth){
            try Sushi.getAmountsOut(amountIn, path) returns(uint256[] memory _amounts) {
                sushiAmounts = _amounts;
            }catch{}
        } 
        else{
            try Sushi.getAmountsOut(amountIn, path) returns(uint256[] memory _amounts) {
                sushiAmounts = _amounts;
            }catch{}
        }
        
        return (sushiAmounts[path.length-1],distribution);

    }
    
    function calculate1InchReturn( uint256 amountIn, address[] memory path, OrderType orderType,uint256 /*disableFlags*/) public view returns(uint256,uint256[] memory) {
        uint256 returnAmount;
        uint256[] memory distribution;

        if(orderType == OrderType.EthForTokens){
            path[0] = ETH;
            try OneSplit.getExpectedReturn(IERC20(path[0]), IERC20(path[path.length-1]), amountIn, 100, 0) returns(uint256 _amount, uint256[] memory _distribution){
                returnAmount = _amount;
                distribution = _distribution;
            }catch{}
        }
        else if(orderType == OrderType.TokensForEth){
            path[path.length-1] = ETH;
            try OneSplit.getExpectedReturn(IERC20(path[0]), IERC20(path[path.length-1]), amountIn, 100, 0) returns(uint256 _amount, uint256[] memory _distribution){
                returnAmount = _amount;
                distribution = _distribution;
            }catch{}
        } 
        else{
            try OneSplit.getExpectedReturn(IERC20(path[0]), IERC20(path[path.length-1]), amountIn, 100, 0) returns(uint256 _amount, uint256[] memory _distribution){
                returnAmount = _amount;
                distribution = _distribution;
            }catch{}
        }
        
        return (returnAmount,distribution);

    }

    function _calculateNoReturn( uint256/* amountIn*/, address[] memory /*path*/, OrderType /*orderType*/,uint256 /*disableFlags*/) internal pure returns(uint256, uint256[] memory) {
        uint256[] memory distribution;
        return (uint256(0), distribution);
    }
    
    function getBestQuote(address[] memory path, uint256 amountIn, OrderType orderType, uint256 disableFlags) public view returns (uint256, uint256,uint256[] memory) {
        
        function(uint256, address[] memory, OrderType ,uint256 ) view returns(uint256,uint256[]memory)[3] memory reserves = [
            disableFlags.disabled(FLAG_1INCH)    ? _calculateNoReturn : _calculateNoReturn,
            disableFlags.disabled(FLAG_UNISWAP)  ? _calculateNoReturn : calculateUniswapReturn,
            disableFlags.disabled(FLAG_SUSHI)    ? _calculateNoReturn : calculateSushiReturn
        ];
        
        uint256[3] memory rates;
        uint256[][3] memory distribution;
        
        for (uint256 i = 0; i < rates.length; i++) {
            (rates[i],distribution[i]) = reserves[i](amountIn,path,orderType,disableFlags);
        }
        
        uint256 temp = 0;
        for(uint256 i = 1; i < rates.length; i++) {
            if(rates[i] > rates[temp]) {
                temp = i;
            }
        }
        return(temp, rates[temp], distribution[temp]);   
    
    }
 
    function oneInchSwap(address _fromToken, address _toToken, uint256 amountIn, uint256 minReturn, uint256[] memory distribution, uint256 flags)
    internal {
        if (_fromToken == ETH) {
            try OneSplit.swap{value: amountIn}(IERC20(ETH), IERC20(_toToken), amountIn, minReturn, distribution, flags)
             returns (uint256 amountOut){
                 TransferHelper.safeTransferFrom(_toToken, address(this), msg.sender, amountOut);
            } catch {
                emit Error(msg.sender);
                revert("Error");
            }
        } else {
             try OneSplit.swap(IERC20(_fromToken), IERC20(_toToken), amountIn, minReturn, distribution, flags)
              returns (uint256 amountOut){
                  if(_toToken == ETH){
                      payable(msg.sender).transfer(amountOut);
                  } else {
                      TransferHelper.safeTransferFrom(_toToken, address(this), msg.sender, amountOut);
                  }
             } catch {
                emit Error(msg.sender);
                revert("Error");
            }
        }
    }
}

 
contract Degen is Router, Ownable {

    using DisableFlags for uint256;
    
    address public _Uni = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //mainnet network address for uniswap (valid for Ropsten as well)
    address public _oneSplit = address(0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E); //INCORRECT! mainnet network address for oneInch
    address public _sushi = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // Mainnet network address for sushiswap
    address public USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT Token Address
    address public system;
    address public gatewayVault;
    uint256 public proccessingFee = 0 ;
    
    uint256 private deadlineLimit = 20*60;      // 20 minutes by default 
    
    uint256 private collectedFees = 1; // amount of collected fee (starts from 1 to avoid additional gas usage)
    address public feeReceiver; // address which receive the fee (by default is validator)


    IReimbursement public reimbursementContract;      // reimbursement contract address

    address public companyToken;        // company reimbursement token (BSWAP, DEGEN, SMART)
    address public companyVault;    // the vault address of our company registered in reimbursement contract

    ISwapFactory public swapFactory;
   
   modifier onlySystem() {

        require(msg.sender == system || owner() == msg.sender,"Caller is not the system");
        _;
    }
    
    
    constructor(address _companyToken, address _swapFactory, address _system, address _gatewayVault /*, address _companyVault, address _reimbursementContract*/) 
    Router( _Uni, _sushi, _oneSplit) {
        companyToken = _companyToken;
        swapFactory = ISwapFactory(_swapFactory);
        system = _system;
        gatewayVault = _gatewayVault;
    }
    
    

    function setCompanyToken(address _companyToken) external onlyOwner {

        companyToken = _companyToken;
    }

    function setCompanyVault(address _comapnyVault) external onlyOwner returns(bool){

        companyVault = _comapnyVault;
        return true;
    }

    function setReimbursementContract(address _reimbursementContarct) external onlyOwner returns(bool){

        reimbursementContract = IReimbursement(_reimbursementContarct);
        return true;
    }

    function setProccessingFee(uint256 _processingFees) external onlySystem {

        proccessingFee = _processingFees;
    }

    function setSwapFactory(address _swapFactory) external onlyOwner {

        swapFactory = ISwapFactory(_swapFactory);

    }
    
    function setGatewayVault(address _gatewayVault) external onlyOwner returns(bool) {

        gatewayVault = _gatewayVault;
        return true;
    }
    
    function setSystem (address _system) external onlyOwner returns(bool) {
        system = _system;
        return true;
    }
    
    function setFeeReceiver(address _addr) external onlyOwner returns(bool) {

        feeReceiver = _addr;
        return true;
    }
    
    function getDeadlineLimit() public view returns(uint256) {

        return deadlineLimit;
    }
    
    function setDeadlineLimit(uint256 limit) external onlyOwner returns(bool) {

        deadlineLimit = limit;
        return true;
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
        address user,
        address to,
        uint256 dexId,
        uint256[] memory distribution,
        uint256 deadline
    ) internal returns(uint256) {

         
        require(dexId < totalDEX, "Invalid DEX Id!");
        require(deadline >= block.timestamp, "EXPIRED: Deadline for transaction already passed.");
        
        uint256 disableFlags = getDisabledDEX(user);
         
        if( disableFlags.disabled(FLAG_1INCH) || disableFlags.disabled(FLAG_UNISWAP) || disableFlags.disabled(FLAG_SUSHI) ) {
            minExpectedAmount = uint256(0);
        }
        
        if(dexId == 0){
            if(orderType == OrderType.EthForTokens) {
                 path[0] = ETH;
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = ETH;
            }
            oneInchSwap(path[0], path[path.length-1], assetInOffered, 0, distribution, 0);
        }

        
        else if(dexId == 1){
            uint[] memory swapResult;
            if(orderType == OrderType.EthForTokens) {
                 path[0] = Uni.WETH();
                 swapResult = Uni.swapExactETHForTokens{value:assetInOffered}(0, path, to,block.timestamp);
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = Uni.WETH();
                TransferHelper.safeApprove(path[0], address(_Uni), assetInOffered);
                swapResult = Uni.swapExactTokensForETH(assetInOffered, 0, path,to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForTokens) {
                TransferHelper.safeApprove(path[0], address(_Uni), assetInOffered);
                swapResult = Uni.swapExactTokensForTokens(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
        } 
        
        else if(dexId == 2){
            uint[] memory swapResult;
            if(orderType == OrderType.EthForTokens) {
                 path[0] = Sushi.WETH();
                 swapResult = Sushi.swapExactETHForTokens{value:assetInOffered}(minExpectedAmount, path, to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = Sushi.WETH();
                TransferHelper.safeApprove(path[0], address(_sushi), assetInOffered);
                swapResult = Sushi.swapExactTokensForETH(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForTokens) {
                TransferHelper.safeApprove(path[0], address(_sushi), assetInOffered);
                swapResult = Sushi.swapExactTokensForTokens(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
        }

        return minExpectedAmount;
    }
    
    
    function executeSwap(
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered, 
        uint256 fees, 
        uint256 minExpectedAmount,
        address licenseeVault,
        uint256 dexId,
        uint256[] memory distribution,
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
        
        _swap(orderType, path, assetInOffered, minExpectedAmount, msg.sender, msg.sender, dexId, distribution, deadline);
   
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
        uint256[3] memory dexId_deadline, // dexId_deadline[0] - native swap dexId, dexId_deadline[1] - foreign swap dexId, dexId_deadline[2] - deadline
        uint256[] memory distribution
    ) external payable {

        uint256[2] memory feesPrice; 
        feesPrice[0] = gasleft();       // equivalent to gasA
        feesPrice[1] = 0;               // processing fees
        
        if (dexId_deadline[2] == 0) {   // if deadline == 0, set deadline to deadlineLimit
            dexId_deadline[2] = block.timestamp + deadlineLimit;
        }

        if(orderType == OrderType.EthForTokens){
            require(msg.value >= (assetInOffered + fees + proccessingFee), "Payment = assetInOffered + fees + proccessingFee");
            feesPrice[1] = msg.value - assetInOffered - fees;
        } else {
            require(msg.value >= (fees + proccessingFee), "fees not received");
            feesPrice[1] = msg.value - fees;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
        }
        
        if(path[0] == USDT) {
            IERC20(USDT).approve(address(swapFactory), assetInOffered);
            swapFactory.swap(USDT, path[path.length-1], assetInOffered, msg.sender, crossOrderType, dexId_deadline[1], distribution, dexId_deadline[2]);
        }
        else {
            address tokenB = path[path.length-1];
            path[path.length-1] = USDT;
            uint256 minAmountExpected = _swap(orderType, path, assetInOffered, minExpectedAmount, msg.sender, address(this), dexId_deadline[0], distribution, dexId_deadline[2]);
                
            IERC20(USDT).approve(address(swapFactory),minAmountExpected);
            swapFactory.swap(USDT, tokenB, minAmountExpected, msg.sender, crossOrderType, dexId_deadline[1], distribution, dexId_deadline[2]);
        }        

        processFee(feesPrice[0], fees, feesPrice[1], licenseeVault, msg.sender);
    }

    function callbackCrossExchange( 
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered, 
        address user,
        uint256 dexId,
        uint256[] memory distribution,
        uint256 deadline
    ) external returns(bool) {

        require(msg.sender == address(swapFactory) , "Degen : caller is not SwapFactory");
        if(deadline==0) {
            deadline = block.timestamp + deadlineLimit;
        }
        _swap(orderType, path, assetInOffered, uint256(0), user, user, dexId, distribution, deadline);
        return true;
    }

}