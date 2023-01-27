pragma solidity 0.8.6;


contract CloneFactory {


  function createClone(address target) internal returns (address result) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;


interface ITokenLock {

    enum Revocability { NotSet, Enabled, Disabled }


    function currentBalance() external view returns (uint256);



    function currentTime() external view returns (uint256);


    function duration() external view returns (uint256);


    function sinceStartTime() external view returns (uint256);


    function amountPerPeriod() external view returns (uint256);


    function periodDuration() external view returns (uint256);


    function currentPeriod() external view returns (uint256);


    function passedPeriods() external view returns (uint256);



    function availableAmount() external view returns (uint256);


    function vestedAmount() external view returns (uint256);


    function releasableAmount() external view returns (uint256);


    function totalOutstandingAmount() external view returns (uint256);


    function surplusAmount() external view returns (uint256);



    function release() external;


    function withdrawSurplus(uint256 _amount) external;


    function revoke() external;

}// MIT
pragma solidity 0.8.6;


interface ITokenLockFactory {

    function setMasterCopy(address _masterCopy) external;


    function createTokenLock(
        address _token,
        address _owner,
        address _beneficiary,
        uint256 _managedAmount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _periods,
        uint256 _releaseStartTime,
        uint256 _vestingCliffTime,
        ITokenLock.Revocability _revocable,
        bool _canDelegate
    ) external returns(address contractAddress);

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity 0.8.6;



contract TokenLockFactory is CloneFactory, ITokenLockFactory, Ownable {


    address public masterCopy;


    event MasterCopyUpdated(address indexed masterCopy);

    event TokenLockCreated(
        address indexed contractAddress,
        bytes32 indexed initHash,
        address indexed beneficiary,
        address token,
        uint256 managedAmount,
        uint256 startTime,
        uint256 endTime,
        uint256 periods,
        uint256 releaseStartTime,
        uint256 vestingCliffTime,
        ITokenLock.Revocability revocable,
        bool canDelegate
    );

    constructor(address _masterCopy) {
        setMasterCopy(_masterCopy);
    }

    function createTokenLock(
        address _token,
        address _owner,
        address _beneficiary,
        uint256 _managedAmount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _periods,
        uint256 _releaseStartTime,
        uint256 _vestingCliffTime,
        ITokenLock.Revocability _revocable,
        bool _canDelegate
    ) external override returns(address contractAddress) {

        bytes memory initializer = abi.encodeWithSignature(
            "initialize(address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,uint8,bool)",
            _owner,
            _beneficiary,
            _token,
            _managedAmount,
            _startTime,
            _endTime,
            _periods,
            _releaseStartTime,
            _vestingCliffTime,
            _revocable,
            _canDelegate
        );

        contractAddress = deployProxyPrivate(initializer,
        _beneficiary,
        _token,
        _managedAmount,
        _startTime,
        _endTime,
        _periods,
        _releaseStartTime,
        _vestingCliffTime,
        _revocable,
        _canDelegate);
    }

    function setMasterCopy(address _masterCopy) public override onlyOwner {

        require(_masterCopy != address(0), "MasterCopy cannot be zero");
        masterCopy = _masterCopy;
        emit MasterCopyUpdated(_masterCopy);
    }

    function  deployProxyPrivate(
        bytes memory _initializer,
        address _beneficiary,
        address _token,
        uint256 _managedAmount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _periods,
        uint256 _releaseStartTime,
        uint256 _vestingCliffTime,
        ITokenLock.Revocability _revocable,
        bool _canDelegate
    ) private returns (address contractAddress) {

        contractAddress = createClone(masterCopy);

        Address.functionCall(contractAddress, _initializer);

        emit TokenLockCreated(
            contractAddress,
            keccak256(_initializer),
            _beneficiary,
            _token,
            _managedAmount,
            _startTime,
            _endTime,
            _periods,
            _releaseStartTime,
            _vestingCliffTime,
            _revocable,
            _canDelegate
        );
    }
}