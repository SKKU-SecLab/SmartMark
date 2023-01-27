

pragma solidity 0.6.12;

library SafeMath256 {

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


pragma solidity 0.6.12;

interface ILockSend {

    event Locksend(address indexed from,address indexed to,address token,uint amount,uint32 unlockTime);
    event Unlock(address indexed from,address indexed to,address token,uint amount,uint32 unlockTime);

    function lockSend(address to, uint amount, address token, uint32 unlockTime) external ;

    function unlock(address from, address to, address token, uint32 unlockTime) external ;

}


pragma solidity 0.6.12;




contract LockSend is ILockSend {

    using SafeMath256 for uint;

    bytes4 private constant _SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 private constant _SELECTOR2 = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

    mapping(bytes32 => uint) public lockSendInfos;

    modifier afterUnlockTime(uint32 unlockTime) {

        require(uint(unlockTime) * 3600 < block.timestamp, "LockSend: NOT_ARRIVING_UNLOCKTIME_YET");
        _;
    }

    modifier beforeUnlockTime(uint32 unlockTime) {

        require(uint(unlockTime) * 3600 > block.timestamp, "LockSend: ALREADY_UNLOCKED");
        _;
    }

    function lockSend(address to, uint amount, address token, uint32 unlockTime) public override beforeUnlockTime(unlockTime) {

        require(amount != 0, "LockSend: LOCKED_AMOUNT_SHOULD_BE_NONZERO");
        bytes32 key = _getLockedSendKey(msg.sender, to, token, unlockTime);
        _safeTransferToMe(token, msg.sender, amount);
        lockSendInfos[key] = lockSendInfos[key].add(amount);
        emit Locksend(msg.sender, to, token, amount, unlockTime);
    }

    function unlock(address from, address to, address token, uint32 unlockTime) public override afterUnlockTime(unlockTime) {

        bytes32 key = _getLockedSendKey(from, to, token, unlockTime);
        uint amount = lockSendInfos[key];
        require(amount != 0, "LockSend: UNLOCK_AMOUNT_SHOULD_BE_NONZERO");
        delete lockSendInfos[key];
        _safeTransfer(token, to, amount);
        emit Unlock(from, to, token, amount, unlockTime);
    }

    function _getLockedSendKey(address from, address to, address token, uint32 unlockTime) private pure returns (bytes32) {

        return keccak256(abi.encodePacked(from, to, token, unlockTime));
    }

    function _safeTransferToMe(address token, address from, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(_SELECTOR2, from, address(this), value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "LockSend: TRANSFER_TO_ME_FAILED");
    }

    function _safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(_SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "LockSend: TRANSFER_FAILED");
    }
}