



pragma solidity ^0.8.0;

library Create2 {

    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {

        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {

        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}




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
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



pragma solidity ^0.8.0;




contract RecycleFactory is ReentrancyGuard {

    function recycle(address payable to,uint[] calldata uids, address[] calldata erc20) nonReentrant external {

        uint n=uids.length;
        for (uint i=0; i < n; i++) {
            uint uid=uids[i];
            address recycleContract = computeAddress(msg.sender,uid);
            if(!Address.isContract(recycleContract)){
                bytes32 salt = keccak256(abi.encode(msg.sender, uid));
                bytes memory bytecode = type(Recycle).creationCode;
                recycleContract=Create2.deploy(0,salt,bytecode);
                Recycle(recycleContract).init(address(this));
            }
            Recycle(recycleContract).recycle(to,erc20);
        }
    }

    function computeAddress(address sender,uint uid) public view returns(address) {

        bytes32 salt = keccak256(abi.encode(sender, uid));
        bytes32 bytecodeHash = keccak256(type(Recycle).creationCode);
        return Create2.computeAddress(salt,bytecodeHash);
    }
}

contract Recycle is ReentrancyGuard {

    address public factory;

    function init(address _factory) external {

        require(factory==address(0),"Recycle: cannot init");
        factory=_factory;
    }


    function recycle(address payable recycler, address[] calldata erc20) external nonReentrant {

        require(msg.sender==factory,"Recycle: must factory");
        uint n=erc20.length;
        for (uint i; i < n; i++) {
            RecyleHelper.transfer(erc20[i],recycler);
        }
        uint balance=address(this).balance;
        if(balance>0) {
            recycler.transfer(balance);
        }
    }
}

library RecyleHelper {

    function transfer(address token, address to) internal returns (bool) {

        uint value = balanceOf(token);
        if (value > 0){
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            return success && (data.length == 0 || abi.decode(data, (bool)));
        }
        return true;
    }
    
    function balanceOf(address token) internal returns (uint) {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x70a08231, address(this)));
        if (!success || data.length == 0) return 0;
        return abi.decode(data, (uint));
    }
}