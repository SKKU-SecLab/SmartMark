


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
}



pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}



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
}



pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.8.0;


library UniversalERC20 {

    using SafeERC20 for IERC20;

    function universalTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {

        if (amount == 0) {
            return;
        }

        token.safeTransferFrom(from, to, amount);
    }

    function universalTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(
        IERC20 token,
        address to,
        uint256 amount,
        bool mayFail
    ) internal returns(bool) {

        if (amount == 0) {
            return true;
        }

        token.safeTransfer(to, amount);
        return true;
    }
}



pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


interface IBridge {

    function isRelay(address candidate) external view returns (bool);

    function countRelaysSignatures(
        bytes calldata payload,
        bytes[] calldata signatures
    ) external view returns(uint);


    struct BridgeConfiguration {
        uint16 nonce;
        uint16 bridgeUpdateRequiredConfirmations;
    }

    struct BridgeRelay {
        uint16 nonce;
        address account;
        bool action;
    }

    function getConfiguration() external view returns (BridgeConfiguration memory);

}



pragma solidity ^0.8.0;


interface IProxy {

    struct TONEvent {
        uint eventTransaction;
        uint64 eventTransactionLt;
        uint32 eventTimestamp;
        uint32 eventIndex;
        bytes eventData;
        int8 tonEventConfigurationWid;
        uint tonEventConfigurationAddress;
        uint16 requiredConfirmations;
        uint16 requiredRejects;
        address proxy;
    }
}



pragma solidity ^0.8.0;

contract RedButton {

    address public admin;

    function _setAdmin(address _admin) internal {

        admin = _admin;
    }

    function transferAdmin(address _newAdmin) public onlyAdmin {

        require(_newAdmin != address(0), 'Cant set admin to zero address');
        _setAdmin(_newAdmin);
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, 'Sender not admin');
        _;
    }

    function externalCallEth(
        address payable[] memory  _to,
        bytes[] memory _data,
        uint256[] memory weiAmount
    ) onlyAdmin public payable {

        require(
            _to.length == _data.length && _data.length == weiAmount.length,
            "Parameters should be equal length"
        );

        for (uint16 i = 0; i < _to.length; i++) {
            _cast(_to[i], _data[i], weiAmount[i]);
        }
    }

    function _cast(
        address payable _to,
        bytes memory _data,
        uint256 weiAmount
    ) internal {

        bytes32 response;

        assembly {
            let succeeded := call(sub(gas(), 5000), _to, weiAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }
}



pragma solidity ^0.8.0;





contract ProxyTokenLock is Initializable, IProxy, RedButton {

    using UniversalERC20 for IERC20;

    struct Fee {
        uint128 numerator;
        uint128 denominator;
    }

    struct Configuration {
        address token;
        address bridge;
        bool active;
        uint16 requiredConfirmations;
        Fee fee;
    }

    Configuration public configuration;
    mapping(uint256 => bool) public alreadyProcessed;

    function getFeeAmount(uint128 amount) public view returns(uint128) {

        return configuration.fee.numerator * amount / configuration.fee.denominator;
    }

    function initialize(
        Configuration memory _configuration,
        address _admin
    ) public initializer {

        _setConfiguration(_configuration);
        _setAdmin(_admin);
    }

    function _setConfiguration(
        Configuration memory _configuration
    ) internal {

        configuration = _configuration;
    }

    function setConfiguration(
        Configuration memory _configuration
    ) public onlyAdmin {

        _setConfiguration(_configuration);
    }

    event TokenLock(uint128 amount, int8 wid, uint256 addr, uint256 pubkey);
    event TokenUnlock(uint256 indexed eventTransaction, uint128 amount, address addr);

    modifier onlyActive() {

        require(configuration.active, 'Configuration not active');
        _;
    }

    function lockTokens(
        uint128 amount,
        int8 wid,
        uint256 addr,
        uint256 pubkey
    ) public onlyActive {

        require(
            IERC20(configuration.token).allowance(
                msg.sender,
                address(this)
            ) >= amount,
            "Allowance insufficient"
        );

        IERC20(configuration.token).universalTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        emit TokenLock(amount, wid, addr, pubkey);
    }

    function broxusBridgeCallback(
        bytes memory payload,
        bytes[] memory signatures
    ) public onlyActive {

        require(
            IBridge(configuration.bridge).countRelaysSignatures(
                payload,
                signatures
            ) >= configuration.requiredConfirmations,
            'Not enough relays signed'
        );

        (TONEvent memory _event) = abi.decode(
            payload,
            (TONEvent)
        );

        require(address(this) == _event.proxy, 'Wrong proxy');
        require(!alreadyProcessed[_event.eventTransaction], 'Already processed');
        alreadyProcessed[_event.eventTransaction] = true;

        (int8 ton_wid, uint256 ton_addr, uint128 amount, uint160 addr_n) = abi.decode(
            _event.eventData,
            (int8, uint256, uint128, uint160)
        );

        address addr = address(addr_n);

        uint128 fee = getFeeAmount(amount);

        IERC20(configuration.token).universalTransfer(addr, amount - fee);

        emit TokenUnlock(_event.eventTransaction, amount - fee, addr);
    }
}