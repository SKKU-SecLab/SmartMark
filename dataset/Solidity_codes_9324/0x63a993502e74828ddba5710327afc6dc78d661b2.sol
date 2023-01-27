pragma solidity ^0.8.0;
pragma abicoder v2;

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

        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity ^0.8.0;

library MultisigUtils {

    function parseSignature(bytes memory signatures, uint256 index)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {

        uint256 offset = index * 65;
        assembly {
            r := mload(add(signatures, add(32, offset)))
            s := mload(add(signatures, add(64, offset)))
            v := and(mload(add(signatures, add(65, offset))), 0xff)
        }

        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "invalid v of signature(r, s, v)");
    }
}// MIT
pragma solidity ^0.8.0;



library SafeMath {


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        require(c / _a == _b, "Overflow during multiplication.");
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return _a / _b;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, "Underflow during subtraction.");
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        c = _a + _b;
        require(c >= _a, "Overflow during addition.");
        return c;
    }
}// MIT
pragma solidity ^0.8.0;


contract ForceBridge {

    using Address for address;
    using SafeERC20 for IERC20;

    uint256 public constant SIGNATURE_SIZE = 65;
    uint256 public constant VALIDATORS_SIZE_LIMIT = 50;
    string public constant NAME_712 = "Force Bridge";
    uint256 public multisigThreshold_;
    address[] validators_;

    bytes32 public constant UNLOCK_TYPEHASH =
        0xf1c18f82536658c0cb1a208d4a52b9915dc9e75640ed0daf3a6be45d02ca5c9f;
    bytes32 public constant CHANGE_VALIDATORS_TYPEHASH =
        0xd2cedd075bf1780178b261ac9c9000261e7fd88d66f6309124bddf24f5d953f8;

    bytes32 private _CACHED_DOMAIN_SEPARATOR;
    uint256 private _CACHED_CHAIN_ID;
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private _TYPE_HASH;

    uint256 public latestUnlockNonce_;
    uint256 public latestChangeValidatorsNonce_;

    event Locked(
        address indexed token,
        address indexed sender,
        uint256 lockedAmount,
        bytes recipientLockscript,
        bytes sudtExtraData
    );

    event Unlocked(
        address indexed token,
        address indexed recipient,
        address indexed sender,
        uint256 receivedAmount,
        bytes ckbTxHash
    );

    struct UnlockRecord {
        address token;
        address recipient;
        uint256 amount;
        bytes ckbTxHash;
    }

    constructor(address[] memory validators, uint256 multisigThreshold) {
        bytes32 hashedName = keccak256(bytes(NAME_712));
        bytes32 hashedVersion = keccak256(bytes("1"));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = _getChainId();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;

        require(
            validators.length > 0,
            "validators are none"
        );
        require(
            multisigThreshold > 0,
            "invalid multisigThreshold"
        );
        require(
            validators.length <= VALIDATORS_SIZE_LIMIT,
            "number of validators exceeds the limit"
        );
        validators_ = validators;
        require(
            multisigThreshold <= validators.length,
            "invalid multisigThreshold"
        );
        multisigThreshold_ = multisigThreshold;
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {

        return _domainSeparator();
    }

    function _domainSeparator() internal view virtual returns (bytes32) {

        if (_getChainId() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {

        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    function _getChainId() private view returns (uint256 chainId) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }

    function changeValidators(
        address[] memory validators,
        uint256 multisigThreshold,
        uint256 nonce,
        bytes memory signatures
    ) public {

        require(nonce == latestChangeValidatorsNonce_, "changeValidators nonce invalid");
        latestChangeValidatorsNonce_ = SafeMath.add(nonce, 1);

        require(
            validators.length > 0,
            "validators are none"
        );
        require(
            multisigThreshold > 0,
            "invalid multisigThreshold"
        );
        require(
            validators.length <= VALIDATORS_SIZE_LIMIT,
            "number of validators exceeds the limit"
        );
        require(
            multisigThreshold <= validators.length,
            "invalid multisigThreshold"
        );

        for (uint256 i = 0; i < validators.length; i++) {
            for (uint256 j = i + 1; j < validators.length; j ++) {
                require(
                    validators[i] != validators[j],
                    "repeated validators"
                );
            }
        }

        bytes32 msgHash =
            keccak256(
                abi.encodePacked(
                    "\x19\x01", // solium-disable-line
                    _domainSeparator(),
                    keccak256(
                        abi.encode(
                            CHANGE_VALIDATORS_TYPEHASH,
                            validators,
                            multisigThreshold,
                            nonce
                        )
                    )
                )
            );

        validatorsApprove(msgHash, signatures, multisigThreshold_);

        validators_ = validators;
        multisigThreshold_ = multisigThreshold;
    }

    function _getIndexOfValidators(address user)
        internal
        view
        returns (uint256)
    {

        for (uint256 i = 0; i < validators_.length; i++) {
            if (validators_[i] == user) {
                return i;
            }
        }
        return validators_.length;
    }

    function validatorsApprove(
        bytes32 msgHash,
        bytes memory signatures,
        uint256 threshold
    ) public view {

        require(signatures.length % SIGNATURE_SIZE == 0, "invalid signatures");

        uint256 length = signatures.length / SIGNATURE_SIZE;
        require(
            length >= threshold,
            "length of signatures must greater than threshold"
        );

        uint256 verifiedNum = 0;
        uint256 i = 0;

        uint8 v;
        bytes32 r;
        bytes32 s;
        address recoveredAddress;
        bool[] memory validatorIndexVisited = new bool[](validators_.length);
        uint256 validatorIndex;
        while (i < length) {
            (v, r, s) = MultisigUtils.parseSignature(signatures, i);
            i++;

            recoveredAddress = ecrecover(msgHash, v, r, s);
            require(recoveredAddress != address(0), "invalid signature");

            validatorIndex = _getIndexOfValidators(recoveredAddress);

            if (
                validatorIndex >= validators_.length ||
                validatorIndexVisited[validatorIndex]
            ) {
                continue;
            }

            validatorIndexVisited[validatorIndex] = true;
            verifiedNum++;
            if (verifiedNum >= threshold) {
                return;
            }
        }
        require(verifiedNum >= threshold, "signatures not verified");
    }

    function unlock(UnlockRecord[] calldata records, uint256 nonce, bytes calldata signatures)
        public
    {

        require(latestUnlockNonce_ == nonce, "unlock nonce invalid");
        latestUnlockNonce_ = SafeMath.add(nonce, 1);

        bytes32 msgHash =
            keccak256(
                abi.encodePacked(
                    "\x19\x01", // solium-disable-line
                    _domainSeparator(),
                    keccak256(abi.encode(UNLOCK_TYPEHASH, records, nonce))
                )
            );

        validatorsApprove(msgHash, signatures, multisigThreshold_);

        for (uint256 i = 0; i < records.length; i++) {
            UnlockRecord calldata r = records[i];
            if (r.amount == 0) continue;
            if (r.token == address(0)) {
                payable(r.recipient).transfer(r.amount);
            } else {
                IERC20(r.token).safeTransfer(r.recipient, r.amount);
            }
            emit Unlocked(
                r.token,
                r.recipient,
                msg.sender,
                r.amount,
                r.ckbTxHash
            );
        }
    }

    function lockETH(
        bytes memory recipientLockscript,
        bytes memory sudtExtraData
    ) public payable {

        require (msg.value > 0, "amount should be greater than 0");
        emit Locked(
            address(0),
            msg.sender,
            msg.value,
            recipientLockscript,
            sudtExtraData
        );
    }

    function lockToken(
        address token,
        uint256 amount,
        bytes memory recipientLockscript,
        bytes memory sudtExtraData
    ) public {

        require (amount > 0, "amount should be greater than 0");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit Locked(
            token,
            msg.sender,
            amount,
            recipientLockscript,
            sudtExtraData
        );
    }
}