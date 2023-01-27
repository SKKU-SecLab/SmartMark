
pragma solidity >=0.6.2 <0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// AGPL-3.0-only

pragma solidity 0.7.5;

interface IPoolEscrow {

    event Withdrawn(address indexed sender, address indexed payee, uint256 amount);

    event OwnershipTransferCommitted(address indexed currentOwner, address indexed futureOwner);

    event OwnershipTransferApplied(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function futureOwner() external view returns (address);


    function commitOwnershipTransfer(address newOwner) external;


    function applyOwnershipTransfer() external;


    function withdraw(address payable payee, uint256 amount) external;

}// AGPL-3.0-only

pragma solidity 0.7.5;


contract PoolEscrow is IPoolEscrow {

    using Address for address payable;

    address public override owner;

    address public override futureOwner;

    constructor(address _owner) {
        owner = _owner;
        emit OwnershipTransferApplied(address(0), _owner);
    }

    modifier onlyOwner() {

        require(owner == msg.sender, "PoolEscrow: caller is not the owner");
        _;
    }

    function commitOwnershipTransfer(address newOwner) external override onlyOwner {

        futureOwner = newOwner;
        emit OwnershipTransferCommitted(msg.sender, newOwner);
    }

    function applyOwnershipTransfer() external override {

        address newOwner = futureOwner;
        require(newOwner == msg.sender, "PoolEscrow: caller is not the future owner");

        emit OwnershipTransferApplied(owner, newOwner);
        (owner, futureOwner) = (newOwner, address(0));
    }

    function withdraw(address payable payee, uint256 amount) external override onlyOwner {

        require(payee != address(0), "PoolEscrow: payee is the zero address");
        emit Withdrawn(msg.sender, payee, amount);
        payee.sendValue(amount);
    }

    receive() external payable { }
}