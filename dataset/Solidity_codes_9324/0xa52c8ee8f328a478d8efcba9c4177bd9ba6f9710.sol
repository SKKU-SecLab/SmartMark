pragma solidity ^0.6.6;

library ACOAssetHelper {

    uint256 internal constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function _isEther(address _address) internal pure returns(bool) {

        return _address == address(0);
    }
    
    function _callApproveERC20(address token, address spender, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0x095ea7b3, spender, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "approve");
    }
    
    function _callTransferERC20(address token, address recipient, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0xa9059cbb, recipient, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "transfer");
    }
    
     function _callTransferFromERC20(address token, address sender, address recipient, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "transferFrom");
    }
    
    function _getAssetSymbol(address asset) internal view returns(string memory) {

        if (_isEther(asset)) {
            return "ETH";
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x95d89b41));
            require(success, "symbol");
            return abi.decode(returndata, (string));
        }
    }
    
    function _getAssetDecimals(address asset) internal view returns(uint8) {

        if (_isEther(asset)) {
            return uint8(18);
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x313ce567));
            require(success, "decimals");
            return abi.decode(returndata, (uint8));
        }
    }

    function _getAssetName(address asset) internal view returns(string memory) {

        if (_isEther(asset)) {
            return "Ethereum";
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x06fdde03));
            require(success, "name");
            return abi.decode(returndata, (string));
        }
    }
    
    function _getAssetBalanceOf(address asset, address account) internal view returns(uint256) {

        if (_isEther(asset)) {
            return account.balance;
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x70a08231, account));
            require(success, "balanceOf");
            return abi.decode(returndata, (uint256));
        }
    }
    
    function _getAssetAllowance(address asset, address owner, address spender) internal view returns(uint256) {

        if (_isEther(asset)) {
            return 0;
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0xdd62ed3e, owner, spender));
            require(success, "allowance");
            return abi.decode(returndata, (uint256));
        }
    }

    function _transferAsset(address asset, address to, uint256 amount) internal {

        if (_isEther(asset)) {
            (bool success,) = to.call{value:amount}(new bytes(0));
            require(success, "send");
        } else {
            _callTransferERC20(asset, to, amount);
        }
    }
    
    function _receiveAsset(address asset, uint256 amount) internal {

        if (_isEther(asset)) {
            require(msg.value == amount, "Invalid ETH amount");
        } else {
            require(msg.value == 0, "No payable");
            _callTransferFromERC20(asset, msg.sender, address(this), amount);
        }
    }

    function _setAssetInfinityApprove(address asset, address owner, address spender, uint256 amount) internal {

        if (_getAssetAllowance(asset, owner, spender) < amount) {
            _callApproveERC20(asset, spender, MAX_UINT);
        }
    }
}pragma solidity ^0.6.6;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;


contract ACOBuyerV2 {

    
    struct BuyACO {
        address from;
        uint256 ethValue;
        bytes data;
    }
    
    bool internal _notEntered;

    modifier nonReentrant() {

        require(_notEntered, "ACOBuyer::Reentry");
        _notEntered = false;
        _;
        _notEntered = true;
    }
    
    constructor() public {
        _notEntered = true;
    }

    receive() external payable {
        require(tx.origin != msg.sender, "ACOBuyer:: Not allowed");
    }
    
    function buy(
        address acoToken,
        address paymentToken, 
        uint256 paymentAmount, 
        BuyACO[] calldata data
    ) 
        nonReentrant
        external
        payable
    {

        require(paymentAmount > 0, "ACOBuyer::buy: Invalid amount");
        require(data.length > 0, "ACOBuyer::buy: Invalid data");
        require(acoToken != address(0), "ACOBuyer::buy: Invalid aco");
        
        bool isEther = ACOAssetHelper._isEther(paymentToken);
        
        uint256 previousEthBalance = SafeMath.sub(address(this).balance, msg.value);
        uint256 previousAcoBalance = ACOAssetHelper._getAssetBalanceOf(acoToken, address(this));
        uint256 previousTokenBalance;
        
        if (isEther) {
            require(msg.value >= paymentAmount, "ACOBuyer::buy:Invalid ETH amount");
        } else {
            previousTokenBalance = ACOAssetHelper._getAssetBalanceOf(paymentToken, address(this));
            ACOAssetHelper._callTransferFromERC20(paymentToken, msg.sender, address(this), paymentAmount);
        }
        
        for (uint256 i = 0; i < data.length; ++i) {
            if (!isEther) {
                ACOAssetHelper._setAssetInfinityApprove(paymentToken, address(this), data[i].from, paymentAmount);
            }
            (bool success,) = data[i].from.call{value:data[i].ethValue}(data[i].data);
            require(success, "ACOBuyer::buy:Error on order");
        }
        
        uint256 remainingEth = SafeMath.sub(address(this).balance, previousEthBalance);
        uint256 afterAcoBalance = ACOAssetHelper._getAssetBalanceOf(acoToken, address(this));
        uint256 remainingAco = SafeMath.sub(afterAcoBalance, previousAcoBalance);

        if (remainingAco > 0) {
            ACOAssetHelper._callTransferERC20(acoToken, msg.sender, remainingAco);
        }
        if (!isEther) {
            uint256 afterTokenBalance = ACOAssetHelper._getAssetBalanceOf(paymentToken, address(this));
            uint256 remainingToken = SafeMath.sub(afterTokenBalance, previousTokenBalance);
            if (remainingToken > 0) {
                ACOAssetHelper._callTransferERC20(paymentToken, msg.sender, remainingToken);
            }
        }
        if (remainingEth > 0) {
            msg.sender.transfer(remainingEth);
        }
    }
}