
pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

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
}//MIT

pragma solidity 0.6.12;

interface IGateway {


    function claimRoot() external view returns (bytes32);


    function relayRoot() external view returns (bytes32);


    function chainId() external view returns (uint256);


}// MIT
pragma solidity ^0.6.12;



contract Gateway is ReentrancyGuard, IGateway {

    using Address for address;

    enum Role {
        UNAUTHORIZED,
        ADMIN,
        RELAYER,
        VALIDATOR
    }

    struct RelayMessage {
        bytes32 root;
        uint256 timestamp;
    }

    struct ClaimMessage {
        bytes32 root;
        uint256 timestamp;
    }

    mapping(address => Role) private permissions;
    uint256 public override chainId;
    mapping(uint256 => RelayMessage) public relayMessages;
    uint256 public relayMessageCount;
    mapping(uint256 => ClaimMessage) public claimMessages;
    uint256 public claimMessageCount;

    constructor(address _devAddress, uint256 _chainId) public {
        permissions[_devAddress] = Role.ADMIN;

        if (_devAddress != msg.sender) {
            permissions[msg.sender] = Role.ADMIN;
        }

        chainId = _chainId;
    }

    function claimRoot() external view override returns (bytes32) {

        return claimMessages[claimMessageCount].root;
    }

    function relayRoot() external view override returns (bytes32) {

        return relayMessages[relayMessageCount].root;
    }

    function updateRelayMessage(bytes32 _root)
        external
        onlyRelayer
        nonReentrant
    {

        relayMessageCount += 1;
        relayMessages[relayMessageCount].root = _root;
        relayMessages[relayMessageCount].timestamp = now;
    }

    function updateClaimMessage(bytes32 _root)
        external
        onlyValidator
        nonReentrant
    {

        claimMessageCount += 1;
        claimMessages[claimMessageCount].root = _root;
        claimMessages[claimMessageCount].timestamp = now;
    }

    function grant(address _address, Role _role) external onlyAdmin {

        require(_address != msg.sender, "You cannot grant yourself");
        permissions[_address] = _role;
    }

    function revoke(address _address) external onlyAdmin {

        require(_address != msg.sender, "You cannot revoke yourself");
        permissions[_address] = Role.UNAUTHORIZED;
    }


    modifier onlyAdmin() {

        require(
            permissions[msg.sender] == Role.ADMIN,
            "Caller is not the admin"
        );
        _;
    }

    modifier onlyRelayer() {

        require(
            permissions[msg.sender] == Role.RELAYER,
            "Caller is not the relayer"
        );
        _;
    }

    modifier onlyValidator() {

        require(
            permissions[msg.sender] == Role.VALIDATOR,
            "Caller is not the validator"
        );
        _;
    }
}