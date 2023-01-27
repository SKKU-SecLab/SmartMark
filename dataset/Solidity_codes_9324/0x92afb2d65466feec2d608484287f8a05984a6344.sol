

pragma solidity ^0.5.0;

library SafeMath {

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


pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


pragma solidity 0.5.17;

library AddressHelper {

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferEther(address to, uint256 value) internal {

        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "ETH_TRANSFER_FAILED");
    }

    function isContract(address token) internal view returns (bool) {

        if (token == address(0x0)) {
            return false;
        }
        uint256 size;
        assembly {
            size := extcodesize(token)
        }
        return size > 0;
    }

    function ethAddress() internal pure returns (address) {

        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}


pragma solidity 0.5.17;

library XNum {

    uint256 public constant BONE = 10**18;
    uint256 public constant MIN_BPOW_BASE = 1 wei;
    uint256 public constant MAX_BPOW_BASE = (2 * BONE) - 1 wei;
    uint256 public constant BPOW_PRECISION = BONE / 10**10;

    function btoi(uint256 a) internal pure returns (uint256) {

        return a / BONE;
    }

    function bfloor(uint256 a) internal pure returns (uint256) {

        return btoi(a) * BONE;
    }

    function badd(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint256 a, uint256 b) internal pure returns (uint256) {

        (uint256 c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint256 a, uint256 b)
        internal
        pure
        returns (uint256, bool)
    {

        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    function bmul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint256 c1 = c0 + (BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint256 c2 = c1 / BONE;
        return c2;
    }

    function bdiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL"); // bmul overflow
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require
        uint256 c2 = c1 / b;
        return c2;
    }

    function bpowi(uint256 a, uint256 n) internal pure returns (uint256) {

        uint256 z = n % 2 != 0 ? a : BONE;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

    function bpow(uint256 base, uint256 exp) internal pure returns (uint256) {

        require(base >= MIN_BPOW_BASE, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= MAX_BPOW_BASE, "ERR_BPOW_BASE_TOO_HIGH");

        uint256 whole = bfloor(exp);
        uint256 remain = bsub(exp, whole);

        uint256 wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint256 partialResult = bpowApprox(base, remain, BPOW_PRECISION);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(
        uint256 base,
        uint256 exp,
        uint256 precision
    ) internal pure returns (uint256) {

        uint256 a = exp;
        (uint256 x, bool xneg) = bsubSign(base, BONE);
        uint256 term = BONE;
        uint256 sum = term;
        bool negative = false;

        for (uint256 i = 1; term >= precision; i++) {
            uint256 bigK = i * BONE;
            (uint256 c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }
}


pragma solidity 0.5.17;

interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _to, uint256 _value)
        external
        returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function approve(address _spender, uint256 _value)
        external
        returns (bool success);


    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

}


pragma solidity 0.5.17;






contract XHalfLife is ReentrancyGuard {

    using SafeMath for uint256;
    using AddressHelper for address;

    uint256 private constant ONE = 10**18;

    uint256 public nextStreamId = 1;

    mapping(uint256 => uint256) public effectiveValues;

    struct Stream {
        uint256 depositAmount; // total deposited amount, must >= 0.0001 TOKEN
        uint256 remaining; // un-withdrawable balance
        uint256 withdrawable; // withdrawable balance
        uint256 startBlock; // when should start
        uint256 kBlock; // interval K blocks
        uint256 unlockRatio; // must be between [1-999], which means 0.1% to 99.9%
        uint256 denom; // one readable coin represent
        uint256 lastRewardBlock; // update by create(), fund() and withdraw()
        address token; // ERC20 token address or 0xEe for Ether
        address recipient;
        address sender;
        bool cancelable; // can be cancelled or not
        bool isEntity;
    }

    mapping(uint256 => Stream) public streams;

    modifier streamExists(uint256 streamId) {

        require(streams[streamId].isEntity, "stream does not exist");
        _;
    }

    modifier createStreamPreflight(
        address recipient,
        uint256 depositAmount,
        uint256 startBlock,
        uint256 kBlock
    ) {

        require(recipient != address(0), "stream to the zero address");
        require(recipient != address(this), "stream to the contract itself");
        require(recipient != msg.sender, "stream to the caller");
        require(depositAmount > 0, "deposit amount is zero");
        require(startBlock >= block.number, "start block before block.number");
        require(kBlock > 0, "k block is zero");
        _;
    }

    event StreamCreated(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        address token,
        uint256 depositAmount,
        uint256 startBlock,
        uint256 kBlock,
        uint256 unlockRatio,
        bool cancelable
    );

    event WithdrawFromStream(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 amount
    );

    event StreamCanceled(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );

    event StreamFunded(uint256 indexed streamId, uint256 amount);

    function createStream(
        address token,
        address recipient,
        uint256 depositAmount,
        uint256 startBlock,
        uint256 kBlock,
        uint256 unlockRatio,
        bool cancelable
    )
        external
        createStreamPreflight(recipient, depositAmount, startBlock, kBlock)
        returns (uint256 streamId)
    {

        require(unlockRatio < 1000, "unlockRatio must < 1000");
        require(unlockRatio > 0, "unlockRatio must > 0");

        require(token.isContract(), "not contract");
        token.safeTransferFrom(msg.sender, address(this), depositAmount);

        streamId = nextStreamId;
        {
            uint256 denom = 10**uint256(IERC20(token).decimals());
            require(denom >= 10**6, "token decimal too small");

            effectiveValues[streamId] = denom.div(10**4);
            require(
                depositAmount >= effectiveValues[streamId],
                "deposit too small"
            );

            streams[streamId] = Stream({
                token: token,
                remaining: depositAmount,
                withdrawable: 0,
                depositAmount: depositAmount,
                startBlock: startBlock,
                kBlock: kBlock,
                unlockRatio: unlockRatio,
                denom: denom,
                lastRewardBlock: startBlock,
                recipient: recipient,
                sender: msg.sender,
                isEntity: true,
                cancelable: cancelable
            });
        }

        nextStreamId = nextStreamId.add(1);
        emit StreamCreated(
            streamId,
            msg.sender,
            recipient,
            token,
            depositAmount,
            startBlock,
            kBlock,
            unlockRatio,
            cancelable
        );
    }

    function createEtherStream(
        address recipient,
        uint256 startBlock,
        uint256 kBlock,
        uint256 unlockRatio,
        bool cancelable
    )
        external
        payable
        createStreamPreflight(recipient, msg.value, startBlock, kBlock)
        returns (uint256 streamId)
    {

        require(unlockRatio < 1000, "unlockRatio must < 1000");
        require(unlockRatio > 0, "unlockRatio must > 0");
        require(msg.value >= 10**14, "deposit too small");

        streamId = nextStreamId;
        streams[streamId] = Stream({
            token: AddressHelper.ethAddress(),
            remaining: msg.value,
            withdrawable: 0,
            depositAmount: msg.value,
            startBlock: startBlock,
            kBlock: kBlock,
            unlockRatio: unlockRatio,
            denom: 10**18,
            lastRewardBlock: startBlock,
            recipient: recipient,
            sender: msg.sender,
            isEntity: true,
            cancelable: cancelable
        });

        nextStreamId = nextStreamId.add(1);
        emit StreamCreated(
            streamId,
            msg.sender,
            recipient,
            AddressHelper.ethAddress(),
            msg.value,
            startBlock,
            kBlock,
            unlockRatio,
            cancelable
        );
    }

    function hasStream(uint256 streamId) external view returns (bool) {

        return streams[streamId].isEntity;
    }

    function getStream(uint256 streamId)
        external
        view
        streamExists(streamId)
        returns (
            address sender,
            address recipient,
            address token,
            uint256 depositAmount,
            uint256 startBlock,
            uint256 kBlock,
            uint256 remaining,
            uint256 withdrawable,
            uint256 unlockRatio,
            uint256 lastRewardBlock,
            bool cancelable
        )
    {

        Stream memory stream = streams[streamId];
        sender = stream.sender;
        recipient = stream.recipient;
        token = stream.token;
        depositAmount = stream.depositAmount;
        startBlock = stream.startBlock;
        kBlock = stream.kBlock;
        remaining = stream.remaining;
        withdrawable = stream.withdrawable;
        unlockRatio = stream.unlockRatio;
        lastRewardBlock = stream.lastRewardBlock;
        cancelable = stream.cancelable;
    }

    function singleFundStream(uint256 streamId, uint256 amount)
        external
        payable
        nonReentrant
        streamExists(streamId)
        returns (bool)
    {

        Stream storage stream = streams[streamId];
        require(
            msg.sender == stream.sender,
            "caller must be the sender of the stream"
        );
        require(amount > effectiveValues[streamId], "amount not effective");
        if (stream.token == AddressHelper.ethAddress()) {
            require(amount == msg.value, "bad ether fund");
        } else {
            stream.token.safeTransferFrom(msg.sender, address(this), amount);
        }

        (uint256 withdrawable, uint256 remaining) = balanceOf(streamId);

        stream.lastRewardBlock = block.number;
        stream.remaining = remaining.add(amount); // = remaining + amount
        stream.withdrawable = withdrawable; // = withdrawable

        stream.depositAmount = stream.depositAmount.add(amount);
        emit StreamFunded(streamId, amount);
        return true;
    }

    function lazyFundStream(
        uint256 streamId,
        uint256 amount,
        uint256 blockHeightDiff
    ) external payable nonReentrant streamExists(streamId) returns (bool) {

        Stream storage stream = streams[streamId];
        require(
            msg.sender == stream.sender,
            "caller must be the sender of the stream"
        );
        require(amount > effectiveValues[streamId], "amount not effective");
        if (stream.token == AddressHelper.ethAddress()) {
            require(amount == msg.value, "bad ether fund");
        } else {
            stream.token.safeTransferFrom(msg.sender, address(this), amount);
        }

        (uint256 withdrawable, uint256 remaining) = balanceOf(streamId);

        uint256 m = amount.mul(ONE).div(blockHeightDiff);
        uint256 noverk = blockHeightDiff.mul(ONE);
        uint256 mu = stream.unlockRatio.mul(ONE).div(1000).div(stream.kBlock);
        uint256 onesubmu = ONE.sub(mu);
        uint256 s =
            m.mul(ONE.sub(XNum.bpow(onesubmu, noverk))).div(mu).div(ONE);

        stream.lastRewardBlock = block.number;
        stream.remaining = remaining.add(s); // = remaining + s
        stream.withdrawable = withdrawable.add(amount).sub(s); // = withdrawable + (amount - s)

        stream.depositAmount = stream.depositAmount.add(amount);
        emit StreamFunded(streamId, amount);
        return true;
    }

    function balanceOf(uint256 streamId)
        public
        view
        streamExists(streamId)
        returns (uint256 withdrawable, uint256 remaining)
    {

        Stream memory stream = streams[streamId];

        if (block.number < stream.startBlock) {
            return (0, stream.depositAmount);
        }

        uint256 lastBalance = stream.withdrawable;

        uint256 n =
            block.number.sub(stream.lastRewardBlock).mul(ONE).div(
                stream.kBlock
            );
        uint256 k = stream.unlockRatio.mul(ONE).div(1000);
        uint256 mu = ONE.sub(k);
        uint256 r = stream.remaining.mul(XNum.bpow(mu, n)).div(ONE);
        uint256 w = stream.remaining.sub(r); // withdrawable, if n is float this process will be smooth and slightly

        if (lastBalance > 0) {
            w = w.add(lastBalance);
        }

        require(
            r.add(w) <= stream.depositAmount,
            "balanceOf: remaining or withdrawable amount is bad"
        );

        if (w >= effectiveValues[streamId]) {
            withdrawable = w;
        } else {
            withdrawable = 0;
        }

        if (r >= effectiveValues[streamId]) {
            remaining = r;
        } else {
            remaining = 0;
        }
    }

    function withdrawFromStream(uint256 streamId, uint256 amount)
        external
        nonReentrant
        streamExists(streamId)
        returns (bool)
    {

        Stream storage stream = streams[streamId];

        require(
            msg.sender == stream.recipient,
            "caller must be the recipient of the stream"
        );

        require(
            amount >= effectiveValues[streamId],
            "amount is zero or not effective"
        );

        (uint256 withdrawable, uint256 remaining) = balanceOf(streamId);

        require(
            withdrawable >= amount,
            "withdraw amount exceeds the available balance"
        );

        if (stream.token == AddressHelper.ethAddress()) {
            stream.recipient.safeTransferEther(amount);
        } else {
            stream.token.safeTransfer(stream.recipient, amount);
        }

        stream.lastRewardBlock = block.number;
        stream.remaining = remaining;
        stream.withdrawable = withdrawable.sub(amount);

        emit WithdrawFromStream(streamId, stream.recipient, amount);
        return true;
    }

    function cancelStream(uint256 streamId)
        external
        nonReentrant
        streamExists(streamId)
        returns (bool)
    {

        Stream memory stream = streams[streamId];

        require(stream.cancelable, "non cancelable stream");
        require(
            msg.sender == streams[streamId].sender ||
                msg.sender == streams[streamId].recipient,
            "caller must be the sender or the recipient"
        );

        (uint256 withdrawable, uint256 remaining) = balanceOf(streamId);

        delete streams[streamId];
        delete effectiveValues[streamId];

        if (withdrawable > 0) {
            if (stream.token == AddressHelper.ethAddress()) {
                stream.recipient.safeTransferEther(withdrawable);
            } else {
                stream.token.safeTransfer(stream.recipient, withdrawable);
            }
        }

        if (remaining > 0) {
            if (stream.token == AddressHelper.ethAddress()) {
                stream.sender.safeTransferEther(remaining);
            } else {
                stream.token.safeTransfer(stream.sender, remaining);
            }
        }

        emit StreamCanceled(
            streamId,
            stream.sender,
            stream.recipient,
            remaining,
            withdrawable
        );
        return true;
    }

    function getVersion() external pure returns (bytes32) {

        return bytes32("APOLLO");
    }
}