
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function deposit() external payable;

    function withdraw(uint256 amount) external;


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface DydxFlashInterface {

    function initiateFlashLoan(address[] calldata tokens, uint256[] calldata amts, uint route, bytes calldata data) external;

    function fee() external view returns(uint);

}

interface TokenInterface {

    function allowance(address, address) external view returns (uint);

    function balanceOf(address) external view returns (uint);

    function approve(address, uint) external;

    function transfer(address, uint) external returns (bool);

    function transferFrom(address, address, uint) external returns (bool);

}

interface MemoryInterface {

    function getUint(uint _id) external returns (uint _num);

    function setUint(uint _id, uint _val) external;

}

interface AccountInterface {

    function enable(address) external;

    function disable(address) external;

}

contract DSMath {


    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "sub-overflow");
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
}

contract Helpers is DSMath {


    using SafeERC20 for IERC20;

    function getAddressETH() internal pure returns (address) {

        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }

    function getMemoryAddr() internal pure returns (address) {

        return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; // InstaMemory Address
    }

    function getUint(uint getId, uint val) internal returns (uint returnVal) {

        returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
    }

    function setUint(uint setId, uint val) internal {

        if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
    }

    function connectorID() public pure returns(uint _type, uint _id) {

        (_type, _id) = (1, 46);
    }

    function _transfer(address payable to, IERC20 token, uint _amt) internal {

        address(token) == getAddressETH() ?
            to.transfer(_amt) :
            token.safeTransfer(to, _amt);
    }

    function _getBalance(IERC20 token) internal view returns (uint256) {

        return address(token) == getAddressETH() ?
            address(this).balance :
            token.balanceOf(address(this));
    }
}


contract DydxFlashHelpers is Helpers {

    function getDydxFlashAddr() internal pure returns (address) {

        return 0x1753758423D19d5ba583e99294B51C86B3F7E512;
    }

    function calculateTotalFeeAmt(DydxFlashInterface dydxContract, uint amt) internal view returns (uint totalAmt) {

        uint fee = dydxContract.fee();
        if (fee == 0) {
            totalAmt = amt;
        } else {
            uint feeAmt = wmul(amt, fee);
            totalAmt = add(amt, feeAmt);
        }
    }
}

contract LiquidityAccessHelper is DydxFlashHelpers {

    function addFeeAmount(uint amt, uint getId, uint setId) external payable {

        uint _amt = getUint(getId, amt);
        require(_amt != 0, "amt-is-0");
        DydxFlashInterface dydxContract = DydxFlashInterface(getDydxFlashAddr());

        uint totalFee = calculateTotalFeeAmt(dydxContract, _amt);

        setUint(setId, totalFee);
    }

}

contract LiquidityAccess is LiquidityAccessHelper {


    event LogDydxFlashBorrow(address[] token, uint256[] tokenAmt);
    event LogDydxFlashPayback(address[] token, uint256[] tokenAmt, uint256[] totalAmtFee);

    function flashBorrowAndCast(address token, uint amt, uint route, bytes memory data) public payable {

        AccountInterface(address(this)).enable(getDydxFlashAddr());

        address[] memory tokens = new address[](1);
        uint[] memory amts = new uint[](1);
        tokens[0] = token;
        amts[0] = amt;

        emit LogDydxFlashBorrow(tokens, amts);

        DydxFlashInterface(getDydxFlashAddr()).initiateFlashLoan(tokens, amts, route, data);

        AccountInterface(address(this)).disable(getDydxFlashAddr());

    }

    function payback(address token, uint amt, uint getId, uint setId) external payable {

        uint _amt = getUint(getId, amt);
        
        DydxFlashInterface dydxContract = DydxFlashInterface(getDydxFlashAddr());
        IERC20 tokenContract = IERC20(token);

        (uint totalFeeAmt) = calculateTotalFeeAmt(dydxContract, _amt);

        _transfer(payable(address(getDydxFlashAddr())), tokenContract, totalFeeAmt);

        setUint(setId, totalFeeAmt);

        address[] memory tokens = new address[](1);
        uint[] memory amts = new uint[](1);
        uint[] memory totalFeeAmts = new uint[](1);
        tokens[0] = token;
        amts[0] = amt;
        totalFeeAmts[0] = totalFeeAmt;

        emit LogDydxFlashPayback(tokens, amts, totalFeeAmts);
    }
}

contract LiquidityAccessMulti is LiquidityAccess {

    function flashMultiBorrowAndCast(address[] calldata tokens, uint[] calldata amts, uint route, bytes calldata data) external payable {

        AccountInterface(address(this)).enable(getDydxFlashAddr());

        emit LogDydxFlashBorrow(tokens, amts);

        DydxFlashInterface(getDydxFlashAddr()).initiateFlashLoan(tokens, amts, route, data);

        AccountInterface(address(this)).disable(getDydxFlashAddr());

    }

    function flashMultiPayback(address[] calldata tokens, uint[] calldata amts, uint[] calldata getId, uint[] calldata setId) external payable {

        uint _length = tokens.length;
        DydxFlashInterface dydxContract = DydxFlashInterface(getDydxFlashAddr());

        uint[] memory totalAmtFees = new uint[](_length);
        for (uint i = 0; i < _length; i++) {
            uint _amt = getUint(getId[i], amts[i]);
            IERC20 tokenContract = IERC20(tokens[i]);

            
            (totalAmtFees[i]) = calculateTotalFeeAmt(dydxContract, _amt);

            _transfer(payable(address(getDydxFlashAddr())), tokenContract, totalAmtFees[i]);

            setUint(setId[i], totalAmtFees[i]);
        }

        emit LogDydxFlashPayback(tokens, amts, totalAmtFees);
    }

}

contract ConnectDydxFlashloan is LiquidityAccessMulti {

    string public name = "dYdX-flashloan-v2.0";
}