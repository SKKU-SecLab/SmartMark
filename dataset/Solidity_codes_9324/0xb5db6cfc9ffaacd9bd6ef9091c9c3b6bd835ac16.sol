
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
}pragma solidity ^0.8.0;

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




pragma solidity ^0.8.11;

contract split {


    address private constant metavateAddress = 0x8DFdD0FF4661abd44B06b1204C6334eACc8575af;
    address private constant artistAddress1 = 0x6553FD0Ed4f4Bd4B87aed74E95DcC049f5F11A78;
    address private constant artistAddress2 = 0xc7204Fd6A370e9f577e8f9533Fc687f3108A70B2;
    address private constant artistAddress3 = 0xb211499e20c19063f99249B14239a77e0A44408b;
    address private wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 public metavateReceived = 0 ether;
    uint256 private constant metavateCap = 19.998 ether;
    
    modifier onlyTeam {

        require(msg.sender == metavateAddress || msg.sender == artistAddress1 || msg.sender == artistAddress2 || msg.sender == artistAddress3, "Not team" );
        _;
    }

    function withdrawETH() public onlyTeam{

        uint256 initialBalance = address(this).balance;

        require(initialBalance > 0, "Empty balance");
        if (metavateReceived >= metavateCap) { //if metavate already got their cut
            uint256 third = address(this).balance / 3;
            payable(artistAddress1).transfer(third);
            payable(artistAddress2).transfer(third);
            payable(artistAddress3).transfer(third);
        } else if(metavateReceived + (initialBalance * 15 / 100) > metavateCap) { // if this withdraw would put metavate over their cut
            payable(metavateAddress).transfer(metavateCap - metavateReceived); 
            metavateReceived = metavateCap;
            uint256 third = address(this).balance / 3;
            payable(artistAddress1).transfer(third);
            payable(artistAddress2).transfer(third);
            payable(artistAddress3).transfer(third);
        } else {
            payable(metavateAddress).transfer(initialBalance * 15 / 100);
            metavateReceived = metavateReceived + initialBalance * 15 / 100;
            uint256 third = address(this).balance / 3;
            payable(artistAddress1).transfer(third);
            payable(artistAddress2).transfer(third);
            payable(artistAddress3).transfer(third);
        }
    }

    function withdrawWETH() public onlyTeam{

        IERC20 weth = IERC20(wethAddress);
        uint256 initialBalance = weth.balanceOf(address(this));
        require(initialBalance > 0, "Empty balance");
        if (metavateReceived >= metavateCap) { 
            uint256 third = initialBalance / 3;
            weth.transfer(artistAddress1, third);
            weth.transfer(artistAddress2, third);
            weth.transfer(artistAddress3, third);
        } else if(metavateReceived + (initialBalance * 15 / 100) > metavateCap) { 
            payable(metavateAddress).transfer(metavateCap - metavateReceived); 
            metavateReceived = metavateCap;
            uint256 third = weth.balanceOf(address(this)) / 3;
            weth.transfer(artistAddress1, third);
            weth.transfer(artistAddress2, third);
            weth.transfer(artistAddress3, third);
        } else {
            weth.transfer(metavateAddress, initialBalance * 15 / 100);
            metavateReceived = metavateReceived + initialBalance * 15 / 100;
            uint256 third = weth.balanceOf(address(this)) / 3;
            weth.transfer(artistAddress1, third);
            weth.transfer(artistAddress2, third);
            weth.transfer(artistAddress3, third);
        }
    }


    function balanceETH() external view returns(uint256){

        return address(this).balance;
    }

    function balanceWETH() external view returns(uint256){

        return IERC20(wethAddress).balanceOf(address(this));
    }


    fallback() external payable {}
    receive() external payable {}

    }