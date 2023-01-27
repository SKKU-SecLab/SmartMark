


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


pragma solidity ^0.6.0;

interface IAllowanceTarget {

    function setSpenderWithTimelock(address _newSpender) external;

    function completeSetSpender() external;

    function executeCall(address payable _target, bytes calldata _callData) external returns (bytes memory resultData);

    function teardown() external;

}



pragma solidity ^0.6.5;



contract AllowanceTarget is IAllowanceTarget {

    using Address for address;

    uint256 constant private TIME_LOCK_DURATION = 1 days;

    address public spender;
    address public newSpender;
    uint256 public timelockExpirationTime;

    modifier onlySpender() {

        require(spender == msg.sender, "AllowanceTarget: not the spender");
        _;
    }


    constructor(address _spender) public {
        require(_spender != address(0), "AllowanceTarget: _spender should not be 0");

        spender = _spender;
    }


    function setSpenderWithTimelock(address _newSpender) override external onlySpender {

        require(_newSpender.isContract(), "AllowanceTarget: new spender not a contract");
        require(newSpender == address(0) && timelockExpirationTime == 0, "AllowanceTarget: SetSpender in progress");

        timelockExpirationTime = now + TIME_LOCK_DURATION;
        newSpender = _newSpender;
    }

    function completeSetSpender() override external {

        require(timelockExpirationTime != 0, "AllowanceTarget: no pending SetSpender");
        require(now >= timelockExpirationTime, "AllowanceTarget: time lock not expired yet");

        spender = newSpender;
        timelockExpirationTime = 0;
        newSpender = address(0);
    }


    function teardown() override external onlySpender {

        selfdestruct(payable(spender));
    }


    function executeCall(
        address payable target,
        bytes calldata callData
    )
        override
        external
        onlySpender
        returns (bytes memory resultData)
    {

        bool success;
        (success, resultData) = target.call(callData);
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }
    }
}