

pragma solidity ^0.5.11;


interface IERC20 {

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);

}


pragma solidity ^0.5.11;



library SafeERC20 {

    function safeTransfer(IERC20 _token, address _to, uint256 _value) internal returns (bool) {

        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transfer(address,uint256)", _to, _value)
        );

        return prevBalance - _value == _token.balanceOf(address(this));
    }

    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool)
    {

        uint256 prevBalance = _token.balanceOf(_from);

        if (
          prevBalance < _value || // Insufficient funds
          _token.allowance(_from, address(this)) < _value // Insufficient allowance
        ) {
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _value)
        );

        return prevBalance - _value == _token.balanceOf(_from);
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _value) internal returns (bool) {

        address(_token).call(
            abi.encodeWithSignature("approve(address,uint256)",_spender, _value)
        );

        return _token.allowance(address(this), _spender) == _value;
    }

    function clearApprove(IERC20 _token, address _spender) internal returns (bool) {

        bool success = safeApprove(_token, _spender, 0);

        if (!success) {
            success = safeApprove(_token, _spender, 1);
        }

        return success;
    }
}


pragma solidity ^0.5.11;


library SafeMath {

    using SafeMath for uint256;

    function add(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 z = x + y;
        require(z >= x, "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {

        require(x >= y, "Sub overflow");
        return x - y;
    }

    function mult(uint256 x, uint256 y) internal pure returns (uint256) {

        if (x == 0) {
            return 0;
        }

        uint256 z = x * y;
        require(z/x == y, "Mult overflow");
        return z;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {

        require(y != 0, "Div by zero");
        return x / y;
    }

    function multdiv(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) {

        require(z != 0, "div by zero");
        return x.mult(y) / z;
    }
}


pragma solidity ^0.5.11;


library SafeCast {

    function toUint128(uint256 _a) internal pure returns (uint128) {

        require(_a < 2 ** 128, "cast overflow");
        return uint128(_a);
    }

    function toUint256(int256 _i) internal pure returns (uint256) {

        require(_i >= 0, "cast to unsigned must be positive");
        return uint256(_i);
    }

    function toInt256(uint256 _i) internal pure returns (int256) {

        require(_i < 2 ** 255, "cast overflow");
        return int256(_i);
    }

    function toUint32(uint256 _i) internal pure returns (uint32) {

        require(_i < 2 ** 32, "cast overdlow");
        return uint32(_i);
    }
}


pragma solidity ^0.5.11;


library IsContract {

    function isContract(address _addr) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }
}


pragma solidity ^0.5.11;


library Math {

    function min(int256 _a, int256 _b) internal pure returns (int256) {

        if (_a < _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function max(int256 _a, int256 _b) internal pure returns (int256) {

        if (_a > _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a < _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function max(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a > _b) {
            return _a;
        } else {
            return _b;
        }
    }
}


pragma solidity ^0.5.11;


contract IERC173 {

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);


    function transferOwnership(address _newOwner) external;

}


pragma solidity ^0.5.11;



contract Ownable is IERC173 {

    address internal _owner;

    modifier onlyOwner() {

        require(msg.sender == _owner, "The owner should be the sender");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0x0), msg.sender);
    }

    function owner() external view returns (address) {

        return _owner;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "0x0 Is not a valid owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}


pragma solidity ^0.5.11;


contract ReentrancyGuard {

    uint256 private _reentrantFlag;

    uint256 private constant FLAG_LOCKED = 1;
    uint256 private constant FLAG_UNLOCKED = 2;

    constructor() public {
        _reentrantFlag = FLAG_UNLOCKED;
    }

    modifier nonReentrant() {

        require(_reentrantFlag != FLAG_LOCKED, "ReentrancyGuard: reentrant call");

        _reentrantFlag = FLAG_LOCKED;
        _;
        _reentrantFlag = FLAG_UNLOCKED;
    }
}


pragma solidity ^0.5.11;


interface CollateralAuctionCallback {

    function auctionClosed(
        uint256 _id,
        uint256 _leftover,
        uint256 _received,
        bytes calldata _data
    ) external;

}


pragma solidity ^0.5.11;











contract CollateralAuction is ReentrancyGuard, Ownable {

    using IsContract for address payable;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeCast for uint256;

    uint256 private constant DELTA_TO_MARKET = 10 minutes;
    uint256 private constant DELTA_FINISH = 1 days;

    IERC20 public baseToken;
    Auction[] public auctions;

    struct Auction {
        IERC20 fromToken;    // Token that we are intending to sell
        uint64 startTime;    // Start time of the auction
        uint32 limitDelta;   // Limit time until all collateral is offered
        uint256 startOffer;  // Start offer of `fromToken` for the requested `amount`
        uint256 amount;      // Amount that we need to receive of `baseToken`
        uint256 limit;       // Limit of how much are willing to spend of `fromToken`
    }

    event CreatedAuction(
        uint256 indexed _id,
        IERC20 _fromToken,
        uint256 _startOffer,
        uint256 _refOffer,
        uint256 _amount,
        uint256 _limit
    );

    event Take(
        uint256 indexed _id,
        address _taker,
        uint256 _selling,
        uint256 _requesting
    );

    constructor(IERC20 _baseToken) public {
        baseToken = _baseToken;
        auctions.length++;
    }

    function getAuctionsLength() external view returns (uint256) {

        return auctions.length;
    }

    function create(
        IERC20 _fromToken,
        uint256 _start,
        uint256 _ref,
        uint256 _limit,
        uint256 _amount
    ) external nonReentrant() returns (uint256 id) {

        require(_start < _ref, "auction: offer should be below refence offer");
        require(_ref <= _limit, "auction: reference offer should be below or equal to limit");

        uint32 limitDelta = ((_limit - _start).mult(DELTA_TO_MARKET) / (_ref - _start)).toUint32();

        require(_fromToken.safeTransferFrom(msg.sender, address(this), _limit), "auction: error pulling _fromToken");

        id = auctions.push(Auction({
            fromToken: _fromToken,
            startTime: uint64(_now()),
            limitDelta: limitDelta,
            startOffer: _start,
            amount: _amount,
            limit: _limit
        })) - 1;

        emit CreatedAuction(
            id,
            _fromToken,
            _start,
            _ref,
            _amount,
            _limit
        );
    }

    function take(
        uint256 _id,
        bytes calldata _data,
        bool _callback
    ) external nonReentrant() {

        Auction memory auction = auctions[_id];
        require(auction.amount != 0, "auction: does not exists");
        IERC20 fromToken = auction.fromToken;

        (uint256 selling, uint256 requesting) = _offer(auction);
        address owner = _owner;

        uint256 leftOver = auction.limit - selling;

        delete auctions[_id];

        require(fromToken.safeTransfer(msg.sender, selling), "auction: error sending tokens");

        if (_callback) {
            (bool success, ) = msg.sender.call(abi.encodeWithSignature("onTake(address,uint256,uint256)", fromToken, selling, requesting));
            require(success, "auction: error during callback onTake()");
        }

        require(baseToken.transferFrom(msg.sender, owner, requesting), "auction: error pulling tokens");

        require(fromToken.safeTransfer(owner, leftOver), "auction: error sending leftover tokens");

        CollateralAuctionCallback(owner).auctionClosed(
            _id,
            leftOver,
            requesting,
            _data
        );

        emit Take(
            _id,
            msg.sender,
            selling,
            requesting
        );
    }

    function offer(
        uint256 _id
    ) external view returns (uint256 selling, uint256 requesting) {

        return _offer(auctions[_id]);
    }

    function _now() internal view returns (uint256) {

        return now;
    }

    function _offer(
        Auction memory _auction
    ) private view returns (uint256, uint256) {

        if (_auction.fromToken == baseToken) {
            uint256 min = Math.min(_auction.limit, _auction.amount);
            return (min, min);
        } else {
            return (_selling(_auction), _requesting(_auction));
        }
    }

    function _selling(
        Auction memory _auction
    ) private view returns (uint256 _amount) {

        uint256 deltaTime = _now() - _auction.startTime;

        if (deltaTime < _auction.limitDelta) {
            uint256 deltaAmount = _auction.limit - _auction.startOffer;
            _amount = _auction.startOffer.add(deltaAmount.mult(deltaTime) / _auction.limitDelta);
        } else {
            _amount = _auction.limit;
        }
    }

    function _requesting(
        Auction memory _auction
    ) private view returns (uint256 _amount) {

        uint256 ogDeltaTime = _now() - _auction.startTime;

        if (ogDeltaTime > _auction.limitDelta) {
            uint256 deltaTime = ogDeltaTime - _auction.limitDelta;
            return _auction.amount.sub(_auction.amount.mult(deltaTime % DELTA_FINISH) / DELTA_FINISH);
        } else {
            return _auction.amount;
        }
    }
}