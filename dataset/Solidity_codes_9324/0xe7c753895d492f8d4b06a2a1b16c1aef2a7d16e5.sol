
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

pragma solidity 0.8.9;

interface IOnchainVaults {

    function depositERC20ToVault(
        uint256 assetId,
        uint256 vaultId,
        uint256 quantizedAmount
    ) external;


    function depositEthToVault(
        uint256 assetId, 
        uint256 vaultId) 
    external payable;


    function withdrawFromVault(
        uint256 assetId,
        uint256 vaultId,
        uint256 quantizedAmount
    ) external;


    function getQuantizedVaultBalance(
        address ethKey,
        uint256 assetId,
        uint256 vaultId
    ) external view returns (uint256);


    function getVaultBalance(
        address ethKey,
        uint256 assetId,
        uint256 vaultId
    ) external view returns (uint256);


    function getQuantum(uint256 presumedAssetType) external view returns (uint256);


    function orderRegistryAddress() external view returns (address);


    function isAssetRegistered(uint256 assetType) external view returns (bool);


    function getAssetInfo(uint256 assetType) external view returns (bytes memory assetInfo);

}// MIT

pragma solidity 0.8.9;

interface IOrderRegistry {


    function registerLimitOrder(
        address exchangeAddress,
        uint256 tokenIdSell,
        uint256 tokenIdBuy,
        uint256 tokenIdFee,
        uint256 amountSell,
        uint256 amountBuy,
        uint256 amountFee,
        uint256 vaultIdSell,
        uint256 vaultIdBuy,
        uint256 vaultIdFee,
        uint256 nonce,
        uint256 expirationTimestamp
    ) external;

}// GPL-3.0-only

pragma solidity 0.8.9;

interface IShareToken {

    function mint(address _to, uint256 _amount) external;


    function burn(address _from, uint256 _amount) external;

}// GPL-3.0-only

pragma solidity 0.8.9;

interface IStrategyPool {

    function sellErc(address inputToken, address outputToken, uint256 inputAmt) external returns (uint256 outputAmt);


    function sellEth(address outputToken) external payable returns (uint256 outputAmt);

}// MIT

pragma solidity 0.8.9;



contract Broker is Ownable {

    using Address for address;
    using SafeERC20 for IERC20;

    event PriceChanged(uint256 rideId, uint256 oldVal, uint256 newVal);
    event SlippageChanged(uint256 rideId, uint256 oldVal, uint256 newVal);
    event RideInfoRegistered(uint256 rideId, RideInfo rideInfo);
    event MintAndSell(uint256 rideId, uint256 mintShareAmt, uint256 price, uint256 slippage);
    event CancelSell(uint256 rideId, uint256 cancelShareAmt);
    event RideDeparted(uint256 rideId, uint256 usedInputTokenAmt);
    event SharesBurned(uint256 rideId, uint256 burnedShareAmt);
    event SharesRedeemed(uint256 rideId, uint256 redeemedShareAmt);
    event OnchainVaultsChanged(address oldAddr, address newAddr);

    address public onchainVaults;

    mapping (uint256=>uint256) public prices; // rideid=>price, price in decimal 1e18
    uint256 public constant PRICE_DECIMALS = 1e18;
    mapping (uint256=>uint256) public slippages; // rideid=>slippage, slippage in denominator 10000
    uint256 public constant SLIPPAGE_DENOMINATOR = 10000;

    bytes4 internal constant ERC20_SELECTOR = bytes4(keccak256("ERC20Token(address)"));
    bytes4 internal constant ETH_SELECTOR = bytes4(keccak256("ETH()"));
    uint256 internal constant SELECTOR_OFFSET = 0x20;


    struct RideInfo {
        address share;
        uint256 tokenIdShare;
        uint256 quantumShare; 
        address inputToken;
        uint256 tokenIdInput;
        uint256 quantumInput;
        address outputToken;
        uint256 tokenIdOutput;
        uint256 quantumOutput;

        address strategyPool; // 3rd defi pool
    }
    mapping (uint256 => RideInfo) public rideInfos; 

    mapping (uint256=>uint256) public ridesShares; // rideid=>amount
    mapping (uint256=>bool) public rideDeparted; // rideid=>bool
    
    uint256 public nonce;
    uint256 public constant EXP_TIME = 2e6; // expiration time stamp of the limit order 

    mapping (uint256=>uint256) public actualPrices; //rideid=>actual price

    struct OrderAssetInfo {
        uint256 tokenId;
        uint256 quantizedAmt;
        uint256 vaultId;
    }

    constructor(
        address _onchainVaults
    ) {
        onchainVaults = _onchainVaults;
    }

    function setPrice(uint256 _rideId, uint256 _price) external onlyOwner {

        require(ridesShares[_rideId] == 0, "change forbidden once share starting to sell");

        uint256 oldVal = prices[_rideId];
        prices[_rideId] = _price;
        emit PriceChanged(_rideId, oldVal, _price);
    }

    function setSlippage(uint256 _rideId, uint256 _slippage) external onlyOwner {

        require(_slippage <= 10000, "invalid slippage");
        require(ridesShares[_rideId] == 0, "change forbidden once share starting to sell");

        uint256 oldVal = slippages[_rideId];
        slippages[_rideId] = _slippage;
        emit SlippageChanged(_rideId, oldVal, _slippage);
    }

    function addRideInfo(uint256 _rideId, uint256[3] memory _tokenIds, address[3] memory _tokens, address _strategyPool) external onlyOwner {

        RideInfo memory rideInfo = rideInfos[_rideId];
        require(rideInfo.tokenIdInput == 0, "ride assets info registered already");

        require(_strategyPool.isContract(), "invalid strategy pool addr");
        _checkValidTokenIdAndAddr(_tokenIds[0], _tokens[0]);
        _checkValidTokenIdAndAddr(_tokenIds[1], _tokens[1]);
        _checkValidTokenIdAndAddr(_tokenIds[2], _tokens[2]);

        IOnchainVaults ocv = IOnchainVaults(onchainVaults);
        uint256 quantumShare = ocv.getQuantum(_tokenIds[0]);
        uint256 quantumInput = ocv.getQuantum(_tokenIds[1]);
        uint256 quantumOutput = ocv.getQuantum(_tokenIds[2]);
        rideInfo = RideInfo(_tokens[0], _tokenIds[0], quantumShare, _tokens[1], _tokenIds[1], 
            quantumInput,  _tokens[2], _tokenIds[2], quantumOutput, _strategyPool);
        rideInfos[_rideId] = rideInfo;
        emit RideInfoRegistered(_rideId, rideInfo);
    }

    function mintShareAndSell(uint256 _rideId, uint256 _amount, uint256 _tokenIdFee, uint256 _quantizedAmtFee, uint256 _vaultIdFee) external onlyOwner {

        RideInfo memory rideInfo = rideInfos[_rideId];
        require(rideInfo.tokenIdInput != 0, "ride assets info not registered");
        require(prices[_rideId] != 0, "price not set");
        require(slippages[_rideId] != 0, "slippage not set");
        require(ridesShares[_rideId] == 0, "already mint for this ride"); 
        if (_tokenIdFee != 0) {
            _checkValidTokenId(_tokenIdFee);
        }

        IShareToken(rideInfo.share).mint(address(this), _amount);

        IERC20(rideInfo.share).safeIncreaseAllowance(onchainVaults, _amount);
        IOnchainVaults(onchainVaults).depositERC20ToVault(rideInfo.tokenIdShare, _rideId, _amount / rideInfo.quantumShare);
        
        _submitOrder(OrderAssetInfo(rideInfo.tokenIdShare, _amount / rideInfo.quantumShare, _rideId), 
            OrderAssetInfo(rideInfo.tokenIdInput, _amount / rideInfo.quantumInput, _rideId), OrderAssetInfo(_tokenIdFee, _quantizedAmtFee, _vaultIdFee));
        
        ridesShares[_rideId] = _amount;

        emit MintAndSell(_rideId, _amount, prices[_rideId], slippages[_rideId]);
    }

    function cancelSell(uint256 _rideId, uint256 _amount, uint256 _tokenIdFee, uint256 _quantizedAmtFee, uint256 _vaultIdFee) external onlyOwner {

        uint256 amount = ridesShares[_rideId];
        require(amount >= _amount, "no enough shares to cancel sell"); 
        require(!rideDeparted[_rideId], "ride departed already");
        if (_tokenIdFee != 0) {
            _checkValidTokenId(_tokenIdFee);
        }

        RideInfo memory rideInfo = rideInfos[_rideId]; //amount > 0 implies that the rideAssetsInfo already registered
        _submitOrder(OrderAssetInfo(rideInfo.tokenIdInput, _amount / rideInfo.quantumInput, _rideId), 
            OrderAssetInfo(rideInfo.tokenIdShare, _amount / rideInfo.quantumShare, _rideId), OrderAssetInfo(_tokenIdFee, _quantizedAmtFee, _vaultIdFee));

        emit CancelSell(_rideId, _amount);
    }

    function departRide(uint256 _rideId, uint256 _tokenIdFee, uint256 _quantizedAmtFee, uint256 _vaultIdFee) external onlyOwner {

        require(!rideDeparted[_rideId], "ride departed already");
        if (_tokenIdFee != 0) {
            _checkValidTokenId(_tokenIdFee);
        }

        rideDeparted[_rideId] = true;

        burnRideShares(_rideId); //burn unsold shares
        uint256 amount = ridesShares[_rideId]; //get the left share amount
        require(amount > 0, "no shares to depart"); 
        
        RideInfo memory rideInfo = rideInfos[_rideId]; //amount > 0 implies that the rideAssetsInfo already registered
        IOnchainVaults ocv = IOnchainVaults(onchainVaults);

        uint256 inputTokenAmt;
        {
            uint256 inputTokenQuantizedAmt = ocv.getQuantizedVaultBalance(address(this), rideInfo.tokenIdInput, _rideId);
            assert(inputTokenQuantizedAmt > 0); 
            ocv.withdrawFromVault(rideInfo.tokenIdInput, _rideId, inputTokenQuantizedAmt);
            inputTokenAmt = inputTokenQuantizedAmt * rideInfo.quantumInput;
        }

        uint256 outputAmt;
        if (rideInfo.inputToken == address(0) /*ETH*/) {
            outputAmt = IStrategyPool(rideInfo.strategyPool).sellEth{value: inputTokenAmt}(rideInfo.outputToken);
        } else {
            IERC20(rideInfo.inputToken).safeIncreaseAllowance(rideInfo.strategyPool, inputTokenAmt);
            outputAmt = IStrategyPool(rideInfo.strategyPool).sellErc(rideInfo.inputToken, rideInfo.outputToken, inputTokenAmt);
        }

        {
            uint256 expectMinResult = amount * prices[_rideId] * (SLIPPAGE_DENOMINATOR - slippages[_rideId]) / PRICE_DECIMALS / SLIPPAGE_DENOMINATOR;
            require(outputAmt >= expectMinResult, "price and slippage not fulfilled");
            
            actualPrices[_rideId] = outputAmt * PRICE_DECIMALS / amount;

            if (rideInfo.outputToken != address(0) /*ERC20*/) {
                IERC20(rideInfo.outputToken).safeIncreaseAllowance(onchainVaults, outputAmt);
                ocv.depositERC20ToVault(rideInfo.tokenIdOutput, _rideId, outputAmt / rideInfo.quantumOutput);
            } else {
                ocv.depositEthToVault{value: outputAmt / rideInfo.quantumOutput * rideInfo.quantumOutput}(rideInfo.tokenIdOutput, _rideId);
            }
        }

        _submitOrder(OrderAssetInfo(rideInfo.tokenIdOutput, outputAmt / rideInfo.quantumOutput, _rideId), 
            OrderAssetInfo(rideInfo.tokenIdShare, amount / rideInfo.quantumShare, _rideId), OrderAssetInfo(_tokenIdFee, _quantizedAmtFee, _vaultIdFee));

        emit RideDeparted(_rideId, inputTokenAmt);
    }

    function burnRideShares(uint256 _rideId) public onlyOwner {

        uint256 amount = ridesShares[_rideId];
        require(amount > 0, "no shares to burn"); 
        
        RideInfo memory rideInfo = rideInfos[_rideId]; //amount > 0 implies that the rideAssetsInfo already registered
        IOnchainVaults ocv = IOnchainVaults(onchainVaults);
        uint256 quantizedAmountToBurn = ocv.getQuantizedVaultBalance(address(this), rideInfo.tokenIdShare, _rideId);
        require(quantizedAmountToBurn > 0, "no shares to burn");

        ocv.withdrawFromVault(rideInfo.tokenIdShare, _rideId, quantizedAmountToBurn);

        uint256 burnAmt = quantizedAmountToBurn * rideInfo.quantumShare;
        ridesShares[_rideId] = amount - burnAmt; // update to left amount
        IShareToken(rideInfo.share).burn(address(this), burnAmt);

        emit SharesBurned(_rideId, burnAmt);
    }

    function redeemShare(uint256 _rideId, uint256 _redeemAmount) external {

        uint256 amount = ridesShares[_rideId];
        require(amount > 0, "no shares to redeem");

        RideInfo memory rideInfo = rideInfos[_rideId]; //amount > 0 implies that the rideAssetsInfo already registered

        IERC20(rideInfo.share).safeTransferFrom(msg.sender, address(this), _redeemAmount);

        IOnchainVaults ocv = IOnchainVaults(onchainVaults);
        bool departed = rideDeparted[_rideId];
        if (departed) {
            uint256 boughtAmt = _redeemAmount * actualPrices[_rideId] / PRICE_DECIMALS;            
            ocv.withdrawFromVault(rideInfo.tokenIdOutput, _rideId, boughtAmt / rideInfo.quantumOutput);
            if (rideInfo.outputToken == address(0) /*ETH*/) {
                (bool success, ) = msg.sender.call{value: boughtAmt}(""); 
                require(success, "ETH_TRANSFER_FAILED");                
            } else {
                IERC20(rideInfo.outputToken).safeTransfer(msg.sender, boughtAmt);
            }
        } else {
            ocv.withdrawFromVault(rideInfo.tokenIdInput, _rideId, _redeemAmount / rideInfo.quantumInput);
            if (rideInfo.inputToken == address(0) /*ETH*/) {
                (bool success, ) = msg.sender.call{value: _redeemAmount}(""); 
                require(success, "ETH_TRANSFER_FAILED");
            } else {
                IERC20(rideInfo.inputToken).safeTransfer(msg.sender, _redeemAmount);
            }
        }

        ridesShares[_rideId] -= _redeemAmount;
        IShareToken(rideInfo.share).burn(address(this), _redeemAmount);

        emit SharesRedeemed(_rideId, _redeemAmount);
    }

    function _checkValidTokenIdAndAddr(uint256 tokenId, address token) view internal {

        bytes4 selector = _checkValidTokenId(tokenId);
        if (selector == ETH_SELECTOR) {
            require(token == address(0), "ETH addr should be 0");
        } else if (selector == ERC20_SELECTOR) {
            require(token.isContract(), "invalid token addr");
        }
    }

    function _checkValidTokenId(uint256 tokenId) view internal returns (bytes4 selector) {

        selector = extractTokenSelector(IOnchainVaults(onchainVaults).getAssetInfo(tokenId));
        require(selector == ETH_SELECTOR || selector == ERC20_SELECTOR, "unsupported token"); 
    }

    function extractTokenSelector(bytes memory assetInfo)
        internal
        pure
        returns (bytes4 selector)
    {

        assembly {
            selector := and(
                0xffffffff00000000000000000000000000000000000000000000000000000000,
                mload(add(assetInfo, SELECTOR_OFFSET))
            )
        }
    }

    function _submitOrder(OrderAssetInfo memory sellInfo, OrderAssetInfo memory buyInfo, OrderAssetInfo memory feeInfo) private {

        nonce += 1;
        address orderRegistryAddr = IOnchainVaults(onchainVaults).orderRegistryAddress();
        IOrderRegistry(orderRegistryAddr).registerLimitOrder(onchainVaults, sellInfo.tokenId, buyInfo.tokenId, feeInfo.tokenId, 
            sellInfo.quantizedAmt, buyInfo.quantizedAmt, feeInfo.quantizedAmt, sellInfo.vaultId, buyInfo.vaultId, feeInfo.vaultId, nonce, EXP_TIME);
    }

    function setOnchainVaults(address _newAddr) external onlyOwner {

        emit OnchainVaultsChanged(onchainVaults, _newAddr);
        onchainVaults = _newAddr;
    }

    receive() external payable {}
    fallback() external payable {}
}