
contract SerializableOrder {

    using SafeMath for uint256;
    using BytesLib for bytes;

    uint constant public ORDER_SIZE = 206;
    uint constant public UNSIGNED_ORDER_SIZE = 141;
    uint8 constant internal _MASK_IS_BUY = 0x01;
    uint8 constant internal _MASK_IS_MAIN = 0x02;

    function _getOrderUserID(bytes memory ser_data) internal pure returns (uint256 userID) {

        userID = ser_data.toUint32(ORDER_SIZE - 4);
    }

    function _getOrderTokenIDTarget(bytes memory ser_data) internal pure returns (uint256 tokenTarget) {

        tokenTarget = ser_data.toUint16(ORDER_SIZE - 6);
    }

    function _getOrderAmountTarget(bytes memory ser_data) internal pure returns (uint256 amountTarget) {

        amountTarget = ser_data.toUint(ORDER_SIZE - 38);
    }

    function _getOrderTokenIDTrade(bytes memory ser_data) internal pure returns (uint256 tokenTrade) {

        tokenTrade = ser_data.toUint16(ORDER_SIZE - 40);
    }

    function _getOrderAmountTrade(bytes memory ser_data) internal pure returns (uint256 amountTrade) {

        amountTrade = ser_data.toUint(ORDER_SIZE - 72);
    }

    function _isOrderBuy(bytes memory ser_data) internal pure returns (bool fBuy) {

        fBuy = (ser_data.toUint8(ORDER_SIZE - 73) & _MASK_IS_BUY != 0);
    }

    function _isOrderFeeMain(bytes memory ser_data) internal pure returns (bool fMain) {

        fMain = (ser_data.toUint8(ORDER_SIZE - 73) & _MASK_IS_MAIN != 0);
    }

    function _getOrderNonce(bytes memory ser_data) internal pure returns (uint256 nonce) {

        nonce = ser_data.toUint32(ORDER_SIZE - 77);
    }

    function _getOrderTradeFee(bytes memory ser_data) internal pure returns (uint256 tradeFee) {

        tradeFee = ser_data.toUint(ORDER_SIZE - 109);
    }

    function _getOrderGasFee(bytes memory ser_data) internal pure returns (uint256 gasFee) {

        gasFee = ser_data.toUint(ORDER_SIZE - 141);
    }

    function _getOrderV(bytes memory ser_data) internal pure returns (uint8 v) {

        v = ser_data.toUint8(ORDER_SIZE - 142);
    }

    function _getOrderR(bytes memory ser_data) internal pure returns (bytes32 r) {

        r = ser_data.toBytes32(ORDER_SIZE - 174);
    }

    function _getOrderS(bytes memory ser_data) internal pure returns (bytes32 s) {

        s = ser_data.toBytes32(ORDER_SIZE - 206);
    }

    function _getOrderHash(bytes memory ser_data) internal pure returns (bytes32 hash) {

        hash = keccak256(ser_data.slice(65, UNSIGNED_ORDER_SIZE));
    }

    function _getOrder(bytes memory ser_data, uint index) internal pure returns (bytes memory order_data) {

        require(index < _getOrderCount(ser_data));
        order_data = ser_data.slice(ORDER_SIZE.mul(index), ORDER_SIZE);
    }

    function _getOrderCount(bytes memory ser_data) internal pure returns (uint256 amount) {

        amount = ser_data.length.div(ORDER_SIZE);
    }
}

contract SerializableWithdrawal {

    using SafeMath for uint256;
    using BytesLib for bytes;

    uint constant public WITHDRAWAL_SIZE = 140;
    uint constant public UNSIGNED_WITHDRAWAL_SIZE = 75;
    uint8 constant internal _MASK_IS_ETH = 0x01;

    function _getWithdrawalUserID(bytes memory ser_data) internal pure returns (uint256 userID) {

        userID = ser_data.toUint32(WITHDRAWAL_SIZE - 4);
    }

    function _getWithdrawalTokenID(bytes memory ser_data) internal pure returns (uint256 tokenID) {

        tokenID = ser_data.toUint16(WITHDRAWAL_SIZE - 6);
    }

    function _getWithdrawalAmount(bytes memory ser_data) internal pure returns (uint256 amount) {

        amount = ser_data.toUint(WITHDRAWAL_SIZE - 38);
    }

    function _isWithdrawalFeeETH(bytes memory ser_data) internal pure returns (bool fFeeETH) {

        fFeeETH = (ser_data.toUint8(WITHDRAWAL_SIZE - 39) & _MASK_IS_ETH != 0);
    }

    function _getWithdrawalNonce(bytes memory ser_data) internal pure returns (uint256 nonce) {

        nonce = ser_data.toUint32(WITHDRAWAL_SIZE - 43);
    }

    function _getWithdrawalFee(bytes memory ser_data) internal pure returns (uint256 fee) {

        fee = ser_data.toUint(WITHDRAWAL_SIZE - 75);
    }

    function _getWithdrawalV(bytes memory ser_data) internal pure returns (uint8 v) {

        v = ser_data.toUint8(WITHDRAWAL_SIZE - 76);
    }

    function _getWithdrawalR(bytes memory ser_data) internal pure returns (bytes32 r) {

        r = ser_data.toBytes32(WITHDRAWAL_SIZE - 108);
    }

    function _getWithdrawalS(bytes memory ser_data) internal pure returns (bytes32 s) {

        s = ser_data.toBytes32(WITHDRAWAL_SIZE - 140);
    }

    function _getWithdrawalHash(bytes memory ser_data) internal pure returns (bytes32 hash) {

        hash = keccak256(ser_data.slice(65, UNSIGNED_WITHDRAWAL_SIZE));
    }
}

contract Dinngo is SerializableOrder, SerializableWithdrawal {

    address private _owner;
    mapping (address => bool) private admins;
    uint256 private _nAdmin;
    uint256 private _nLimit;
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public processTime;

    mapping (address => mapping (address => uint256)) public balances;
    mapping (bytes32 => uint256) public orderFills;
    mapping (uint256 => address payable) public userID_Address;
    mapping (uint256 => address) public tokenID_Address;
    mapping (address => uint256) public userRanks;
    mapping (address => uint256) public tokenRanks;
    mapping (address => uint256) public lockTimes;

    event AddUser(uint256 userID, address indexed user);
    event AddToken(uint256 tokenID, address indexed token);
    event Deposit(address token, address indexed user, uint256 amount, uint256 balance);
    event Withdraw(address token, address indexed user, uint256 amount, uint256 balance);
    event Trade(
        address indexed user,
        bool isBuy,
        address indexed tokenTarget,
        uint256 amountTarget,
        address indexed tokenTrade,
        uint256 amountTrade
    );
    event Lock(address indexed user, uint256 lockTime);
    event Unlock(address indexed user);

    function() external payable {
        revert();
    }

    function addUser(uint256 id, address payable user) external {

        require(user != address(0));
        require(userRanks[user] == 0);
        require(id < 2**32);
        if (userID_Address[id] == address(0))
            userID_Address[id] = user;
        else
            require(userID_Address[id] == user);
        userRanks[user] = 1;
        emit AddUser(id, user);
    }

    function removeUser(address user) external {

        require(user != address(0));
        require(userRanks[user] != 0);
        userRanks[user] = 0;
    }

    function updateUserRank(address user, uint256 rank) external {

        require(user != address(0));
        require(rank != 0);
        require(userRanks[user] != 0);
        require(userRanks[user] != rank);
        userRanks[user] = rank;
    }

    function addToken(uint256 id, address token) external {

        require(token != address(0));
        require(tokenRanks[token] == 0);
        require(id < 2**16);
        if (tokenID_Address[id] == address(0))
            tokenID_Address[id] = token;
        else
            require(tokenID_Address[id] == token);
        tokenRanks[token] = 1;
        emit AddToken(id, token);
    }

    function removeToken(address token) external {

        require(token != address(0));
        require(tokenRanks[token] != 0);
        tokenRanks[token] = 0;
    }

    function updateTokenRank(address token, uint256 rank) external {

        require(token != address(0));
        require(rank != 0);
        require(tokenRanks[token] != 0);
        require(tokenRanks[token] != rank);
        tokenRanks[token] = rank;
    }

    function deposit() external payable {

        require(!_isLocking(msg.sender));
        require(msg.value > 0);
        balances[address(0)][msg.sender] = balances[address(0)][msg.sender].add(msg.value);
        emit Deposit(address(0), msg.sender, msg.value, balances[address(0)][msg.sender]);
    }

    function depositToken(address token, uint256 amount) external {

        require(token != address(0));
        require(!_isLocking(msg.sender));
        require(_isValidToken(token));
        require(amount > 0);
        balances[token][msg.sender] = balances[token][msg.sender].add(amount);
        emit Deposit(token, msg.sender, amount, balances[token][msg.sender]);
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external {

        require(_isLocked(msg.sender));
        require(_isValidUser(msg.sender));
        require(amount > 0);
        balances[address(0)][msg.sender] = balances[address(0)][msg.sender].sub(amount);
        emit Withdraw(address(0), msg.sender, amount, balances[address(0)][msg.sender]);
        msg.sender.transfer(amount);
    }

    function withdrawToken(address token, uint256 amount) external {

        require(token != address(0));
        require(_isLocked(msg.sender));
        require(_isValidUser(msg.sender));
        require(_isValidToken(token));
        require(amount > 0);
        balances[token][msg.sender] = balances[token][msg.sender].sub(amount);
        emit Withdraw(token, msg.sender, amount, balances[token][msg.sender]);
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function withdrawByAdmin(bytes calldata withdrawal) external {

        address payable user = userID_Address[_getWithdrawalUserID(withdrawal)];
        address token = tokenID_Address[_getWithdrawalTokenID(withdrawal)];
        uint256 amount = _getWithdrawalAmount(withdrawal);
        uint256 amountFee = _getWithdrawalFee(withdrawal);
        address tokenFee = _isWithdrawalFeeETH(withdrawal)? address(0) : tokenID_Address[1];
        uint256 balance = balances[token][user].sub(amount);
        require(_isValidUser(user));
        _verifySig(
            user,
            _getWithdrawalHash(withdrawal),
            _getWithdrawalR(withdrawal),
            _getWithdrawalS(withdrawal),
            _getWithdrawalV(withdrawal)
        );
        if (tokenFee == token) {
            balance = balance.sub(amountFee);
        } else {
            balances[tokenFee][user] = balances[tokenFee][user].sub(amountFee);
        }
        balances[tokenFee][userID_Address[0]] =
            balances[tokenFee][userID_Address[0]].add(amountFee);
        balances[token][user] = balance;
        emit Withdraw(token, user, amount, balance);
        if (token == address(0)) {
            user.transfer(amount);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }

    function settle(bytes calldata orders) external {

        uint256 nOrder = _getOrderCount(orders);
        bytes memory takerOrder = _getOrder(orders, 0);
        bytes32 takerHash = _getOrderHash(takerOrder);
        uint256 takerAmountTarget = _getOrderAmountTarget(takerOrder).sub(orderFills[takerHash]);
        uint256 fillAmountTrade = 0;
        uint256 restAmountTarget = takerAmountTarget;
        for (uint i = 1; i < nOrder; i++) {
            bytes memory makerOrder = _getOrder(orders, i);
            require(_isOrderBuy(takerOrder) != _isOrderBuy(makerOrder));
            uint256 makerAmountTrade = _getOrderAmountTrade(makerOrder);
            uint256 makerAmountTarget = _getOrderAmountTarget(makerOrder);
            bytes32 makerHash = _getOrderHash(makerOrder);
            uint256 amountTarget = makerAmountTarget.sub(orderFills[makerHash]);
            amountTarget = amountTarget <= restAmountTarget? amountTarget : restAmountTarget;
            uint256 amountTrade = makerAmountTrade.mul(amountTarget).div(makerAmountTarget);
            restAmountTarget = restAmountTarget.sub(amountTarget);
            fillAmountTrade = fillAmountTrade.add(amountTrade);
            _trade(amountTarget, amountTrade, makerOrder);
        }
        restAmountTarget = takerAmountTarget.sub(restAmountTarget);
        if (_isOrderBuy(takerOrder)) {
            require(fillAmountTrade.mul(_getOrderAmountTarget(takerOrder))
                <= _getOrderAmountTrade(takerOrder).mul(restAmountTarget));
        } else {
            require(fillAmountTrade.mul(_getOrderAmountTarget(takerOrder))
                >= _getOrderAmountTrade(takerOrder).mul(restAmountTarget));
        }
        _trade(restAmountTarget, fillAmountTrade, takerOrder);
    }

    function lock() external {

        require(!_isLocking(msg.sender));
        lockTimes[msg.sender] = now.add(processTime);
        emit Lock(msg.sender, lockTimes[msg.sender]);
    }

    function unlock() external {

        require(_isLocking(msg.sender));
        lockTimes[msg.sender] = 0;
        emit Unlock(msg.sender);
    }

    function changeProcessTime(uint256 time) external {

        require(processTime != time);
        processTime = time;
    }

    function _trade(uint256 amountTarget, uint256 amountTrade, bytes memory order) internal {

        require(amountTarget != 0);
        address user = userID_Address[_getOrderUserID(order)];
        bytes32 hash = _getOrderHash(order);
        address tokenTrade = tokenID_Address[_getOrderTokenIDTrade(order)];
        address tokenTarget = tokenID_Address[_getOrderTokenIDTarget(order)];
        uint256 balanceTrade;
        uint256 balanceTarget;
        require(_isValidUser(user));
        if (_isOrderBuy(order)) {
            balanceTrade = balances[tokenTrade][user].sub(amountTrade);
            balanceTarget = balances[tokenTarget][user].add(amountTarget);
        } else {
            balanceTrade = balances[tokenTrade][user].add(amountTrade);
            balanceTarget = balances[tokenTarget][user].sub(amountTarget);
        }
        address tokenFee = _isOrderFeeMain(order)? tokenTrade : tokenID_Address[1];
        uint256 amountFee = _getOrderTradeFee(order).mul(amountTarget).div(_getOrderAmountTarget(order));
        if (orderFills[hash] == 0) {
            _verifySig(user, hash, _getOrderR(order), _getOrderS(order), _getOrderV(order));
            amountFee = amountFee.add(_getOrderGasFee(order));
        }
        orderFills[hash] = orderFills[hash].add(amountTarget);
        if (tokenFee == tokenTarget) {
            balanceTarget = balanceTarget.sub(amountFee);
        } else if (tokenFee == tokenTrade) {
            balanceTrade = balanceTrade.sub(amountFee);
        } else {
            balances[tokenFee][user] = balances[tokenFee][user].sub(amountFee);
        }
        balances[tokenFee][userID_Address[0]] = balances[tokenFee][userID_Address[0]].add(amountFee);
        balances[tokenTarget][user] = balanceTarget;
        balances[tokenTrade][user] = balanceTrade;
        emit Trade
        (
            user,
            _isOrderBuy(order),
            tokenTarget,
            amountTarget,
            tokenTrade,
            amountTrade
        );
    }

    function _isValidUser(address user) internal view returns (bool) {

        return userRanks[user] != 0;
    }


    function _isValidToken(address token) internal view returns (bool) {

        return tokenRanks[token] != 0;
    }

    function _verifySig(address user, bytes32 hash, bytes32 r, bytes32 s, uint8 v) internal pure {

        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);

        address sigAddr = ecrecover(hash.toEthSignedMessageHash(), v, r, s);
        require(user == sigAddr);
    }

    function _isLocking(address user) internal view returns (bool) {

        return lockTimes[user] > 0;
    }

    function _isLocked(address user) internal view returns (bool) {

        return _isLocking(user) && lockTimes[user] < now;
    }
}

library BytesLib {

    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes memory) {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
                    add(
                        fslot,
                        add(
                            mul(
                                div(
                                    mload(add(_postBytes, 0x20)),
                                    exp(0x100, sub(32, mlength))
                                ),
                                exp(0x100, sub(32, newlength))
                            ),
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                
                for { 
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(bytes memory _bytes, uint _start, uint _length) internal  pure returns (bytes memory) {

        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }
}

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {



        require(address(token).isContract());

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}