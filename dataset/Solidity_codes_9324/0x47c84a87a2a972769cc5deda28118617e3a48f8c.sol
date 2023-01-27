
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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
}// MIT

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
}// UNLICENSED
pragma solidity ^0.8.0;

interface IBatcher {

    struct VaultInfo {
        address vaultAddress;
        address tokenAddress;
        uint256 maxAmount;
    }

    event DepositRequest(
        address indexed sender,
        address indexed vault,
        uint256 amountIn
    );

    event WithdrawRequest(
        address indexed sender,
        address indexed vault,
        uint256 amountOut
    );

    event BatchDepositSuccessful(uint256 amountIn, uint256 totalUsers);

    event BatchWithdrawSuccessful(uint256 amountOut, uint256 totalUsers);

    event WithdrawComplete(
        address indexed sender,
        address indexed vault,
        uint256 amountOut
    );

    event VerificationAuthorityUpdated(
        address indexed oldVerificationAuthority,
        address indexed newVerificationAuthority
    );

    function depositFunds(
        uint256 amountIn,
        bytes memory signature,
        address recipient
    ) external payable;


    function claimTokens(uint256 amount, address recipient) external;


    function initiateWithdrawal(uint256 amountIn) external;


    function completeWithdrawal(uint256 amountOut, address recipient) external;


    function batchDeposit(address[] memory users) external;


    function batchWithdraw(address[] memory users) external;


    function setVaultLimit(uint256 maxLimit) external;

}/// GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IVault {

    function keeper() external view returns (address);


    function governance() external view returns (address);


    function wantToken() external view returns (address);


    function deposit(uint256 amountIn, address receiver)
        external
        returns (uint256 shares);


    function withdraw(uint256 sharesIn, address receiver)
        external
        returns (uint256 amountOut);

}// GPL-3.0-only
pragma solidity ^0.8.0;


interface IWETH9 is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 _amount) external;

}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.0;


contract EIP712 {

    function verifySignatureAgainstAuthority(
        address recipient,
        bytes memory signature,
        address authority
    ) internal view returns (bool) {

        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Batcher")),
                keccak256(bytes("1")),
                1,
                address(this)
            )
        );

        bytes32 hashStruct = keccak256(
            abi.encode(keccak256("deposit(address owner)"), recipient)
        );

        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct)
        );

        address signer = ECDSA.recover(hash, signature);
        require(signer == authority, "ECDSA: Invalid authority");
        require(signer != address(0), "ECDSA: invalid signature");
        return true;
    }
}/// GPL-3.0-or-later
pragma solidity ^0.8.4;


contract Batcher is IBatcher, EIP712, ReentrancyGuard {

    using SafeERC20 for IERC20;

    IWETH9 public immutable WETH;

    VaultInfo public vaultInfo;

    bool public checkValidDepositSignature;

    constructor(
        address _verificationAuthority,
        address vaultAddress,
        uint256 maxAmount
    ) {
        verificationAuthority = _verificationAuthority;
        checkValidDepositSignature = true;

        require(vaultAddress != address(0), "NULL_ADDRESS");
        vaultInfo = VaultInfo({
            vaultAddress: vaultAddress,
            tokenAddress: IVault(vaultAddress).wantToken(),
            maxAmount: maxAmount
        });

        WETH = IWETH9(vaultInfo.tokenAddress);

        IERC20(vaultInfo.tokenAddress).approve(vaultAddress, type(uint256).max);
    }


    mapping(address => uint256) public depositLedger;

    mapping(address => uint256) public withdrawLedger;

    address public verificationAuthority;

    uint256 public pendingDeposit;

    uint256 public pendingWithdrawal;

    function depositFunds(
        uint256 amountIn,
        bytes memory signature,
        address recipient
    ) external payable override nonReentrant {

        validDeposit(recipient, signature);

        uint256 wethBalanceBeforeTransfer = WETH.balanceOf(address(this));

        uint256 ethSent = msg.value;

        if (ethSent > 0) {
            amountIn = ethSent;
            WETH.deposit{value: ethSent}();
        }
        else {
            IERC20(vaultInfo.tokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
        }

        uint256 wethBalanceAfterTransfer = WETH.balanceOf(address(this));

        assert(
            wethBalanceAfterTransfer - wethBalanceBeforeTransfer == amountIn
        );

        require(
            IERC20(vaultInfo.vaultAddress).totalSupply() +
                pendingDeposit -
                pendingWithdrawal +
                amountIn <=
                vaultInfo.maxAmount,
            "MAX_LIMIT_EXCEEDED"
        );

        depositLedger[recipient] = depositLedger[recipient] + (amountIn);
        pendingDeposit = pendingDeposit + amountIn;

        emit DepositRequest(recipient, vaultInfo.vaultAddress, amountIn);
    }

    function initiateWithdrawal(uint256 amountIn)
        external
        override
        nonReentrant
    {

        require(depositLedger[msg.sender] == 0, "DEPOSIT_PENDING");

        require(amountIn > 0, "AMOUNT_IN_ZERO");

        if (amountIn > userLPTokens[msg.sender]) {
            IERC20(vaultInfo.vaultAddress).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn - userLPTokens[msg.sender]
            );
            userLPTokens[msg.sender] = 0;
        } else {
            userLPTokens[msg.sender] = userLPTokens[msg.sender] - amountIn;
        }

        withdrawLedger[msg.sender] = withdrawLedger[msg.sender] + (amountIn);

        pendingWithdrawal = pendingWithdrawal + amountIn;

        emit WithdrawRequest(msg.sender, vaultInfo.vaultAddress, amountIn);
    }

    function completeWithdrawal(uint256 amountOut, address recipient)
        external
        override
        nonReentrant
    {

        require(amountOut != 0, "INVALID_AMOUNTOUT");

        userWantTokens[recipient] = userWantTokens[recipient] - amountOut;
        IERC20(vaultInfo.tokenAddress).safeTransfer(recipient, amountOut);

        emit WithdrawComplete(recipient, vaultInfo.vaultAddress, amountOut);
    }

    function claimTokens(uint256 amount, address recipient)
        public
        override
        nonReentrant
    {

        require(userLPTokens[recipient] >= amount, "NO_FUNDS");
        userLPTokens[recipient] = userLPTokens[recipient] - amount;
        IERC20(vaultInfo.vaultAddress).safeTransfer(recipient, amount);
    }


    mapping(address => uint256) public userLPTokens;

    mapping(address => uint256) public userWantTokens;

    function batchDeposit(address[] memory users)
        external
        override
        nonReentrant
    {

        onlyKeeper();
        IVault vault = IVault(vaultInfo.vaultAddress);

        uint256 amountToDeposit = 0;
        uint256 oldLPBalance = IERC20(address(vault)).balanceOf(address(this));

        uint256[] memory depositValues = new uint256[](users.length);

        for (uint256 i = 0; i < users.length; i++) {
            uint256 userDeposit = depositLedger[users[i]];
            amountToDeposit = amountToDeposit + userDeposit;
            depositValues[i] = userDeposit;

            depositLedger[users[i]] = 0;
        }

        require(amountToDeposit > 0, "NO_DEPOSITS");

        uint256 lpTokensReportedByVault = vault.deposit(
            amountToDeposit,
            address(this)
        );

        uint256 lpTokensReceived = IERC20(address(vault)).balanceOf(
            address(this)
        ) - (oldLPBalance);

        require(
            lpTokensReceived == lpTokensReportedByVault,
            "LP_TOKENS_MISMATCH"
        );

        uint256 totalUsersProcessed = 0;

        for (uint256 i = 0; i < users.length; i++) {
            uint256 userAmount = depositValues[i];

            if (userAmount > 0) {
                uint256 userShare = (userAmount * (lpTokensReceived)) /
                    (amountToDeposit);

                userLPTokens[users[i]] = userLPTokens[users[i]] + userShare;
                ++totalUsersProcessed;
            }
        }

        pendingDeposit = pendingDeposit - amountToDeposit;

        emit BatchDepositSuccessful(lpTokensReceived, totalUsersProcessed);
    }

    function batchWithdraw(address[] memory users)
        external
        override
        nonReentrant
    {

        onlyKeeper();
        IVault vault = IVault(vaultInfo.vaultAddress);

        IERC20 token = IERC20(vaultInfo.tokenAddress);

        uint256 amountToWithdraw = 0;
        uint256 oldWantBalance = token.balanceOf(address(this));

        uint256[] memory withdrawValues = new uint256[](users.length);

        for (uint256 i = 0; i < users.length; i++) {
            uint256 userWithdraw = withdrawLedger[users[i]];
            amountToWithdraw = amountToWithdraw + userWithdraw;
            withdrawValues[i] = userWithdraw;

            withdrawLedger[users[i]] = 0;
        }

        require(amountToWithdraw > 0, "NO_WITHDRAWS");

        uint256 wantTokensReportedByVault = vault.withdraw(
            amountToWithdraw,
            address(this)
        );

        uint256 wantTokensReceived = token.balanceOf(address(this)) -
            (oldWantBalance);

        require(
            wantTokensReceived == wantTokensReportedByVault,
            "WANT_TOKENS_MISMATCH"
        );

        uint256 totalUsersProcessed = 0;

        for (uint256 i = 0; i < users.length; i++) {
            uint256 userAmount = withdrawValues[i];

            if (userAmount > 0) {
                uint256 userShare = (userAmount * wantTokensReceived) /
                    amountToWithdraw;

                userWantTokens[users[i]] = userWantTokens[users[i]] + userShare;
                ++totalUsersProcessed;
            }
        }

        pendingWithdrawal = pendingWithdrawal - amountToWithdraw;

        emit BatchWithdrawSuccessful(wantTokensReceived, totalUsersProcessed);
    }


    function validDeposit(address recipient, bytes memory signature)
        internal
        view
    {

        if (checkValidDepositSignature) {
            require(
                verifySignatureAgainstAuthority(
                    recipient,
                    signature,
                    verificationAuthority
                ),
                "INVALID_SIGNATURE"
            );
        }

        require(withdrawLedger[msg.sender] == 0, "WITHDRAW_PENDING");
    }


    function setAuthority(address authority) public {

        onlyGovernance();

        emit VerificationAuthorityUpdated(verificationAuthority, authority);
        verificationAuthority = authority;
    }

    function setVaultLimit(uint256 maxAmount) external override {

        onlyGovernance();
        vaultInfo.maxAmount = maxAmount;
    }

    function setDepositSignatureCheck(bool enabled) public {

        onlyGovernance();
        checkValidDepositSignature = enabled;
    }

    function sweep(address _token) public nonReentrant {

        onlyGovernance();
        IERC20(_token).transfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }


    function governance() public view returns (address) {

        return IVault(vaultInfo.vaultAddress).governance();
    }

    function keeper() public view returns (address) {

        return IVault(vaultInfo.vaultAddress).keeper();
    }

    function onlyKeeper() internal view {

        require(msg.sender == keeper(), "ONLY_KEEPER");
    }

    function onlyGovernance() internal view {

        require(governance() == msg.sender, "ONLY_GOV");
    }
}