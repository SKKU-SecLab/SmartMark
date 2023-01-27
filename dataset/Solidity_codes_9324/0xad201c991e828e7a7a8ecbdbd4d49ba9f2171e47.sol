
pragma solidity >=0.7.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}

pragma solidity >=0.7.0 <0.8.0;

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
}
pragma solidity >=0.7.0 <0.8.0;


interface IERC721 {

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

interface IERC1155 {

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

}

contract Popswap is ReentrancyGuard {

    using SafeMath for uint256;

    event TradeOpened(
        uint256 indexed tradeId,
        address indexed tradeOpener
    );

    event TradeCancelled(
        uint256 indexed tradeId,
        address indexed tradeCloser
    );

    event TradeExecuted(
        uint256 indexed tradeId,
        address indexed tradeOpener,
        address indexed tradeCloser
    );

    struct Trade {
        uint256 tradeId;
        address openingTokenAddress;
        uint256 openingTokenId;
        address closingTokenAddress;
        uint256 closingTokenId;
        uint256 expiryDate;
        uint256 successDate;
        address tradeOpener;
        address tradeCloser;
        bool active;
    }

    Trade[] public trades;

    mapping (uint256 => address) private _tradeIdToTradeCloser;
  
    address private _devFund;

    constructor(address devFund_) {
        _devFund = devFund_;
    }

    function devFund() public view virtual returns (address) {

        return _devFund;
    }

    function openNewTrade(
        address _openingTokenAddress,
        uint256 _openingTokenId,
        address _closingTokenAddress,
        uint256 _closingTokenId,
        uint256 _expiryDate
    ) public nonReentrant returns (uint256) {

        require(
            _expiryDate > block.timestamp,
            "Popswap::openNewTrade: _expiryDate must be after current block.timestamp"
        );
        uint256 tradeId = trades.length;
        trades.push(Trade(
            tradeId,
            _openingTokenAddress,
            _openingTokenId,
            _closingTokenAddress,
            _closingTokenId,
            _expiryDate,
            0,
            msg.sender,
            0x0000000000000000000000000000000000000000,
            true
        ));
        emit TradeOpened(tradeId, msg.sender);
        return tradeId;
    }

    function getTradeByTradeId(uint256 _tradeId) public view returns(
        uint256,
        address,
        uint256,
        address,
        uint256,
        uint256,
        uint256,
        address,
        address,
        bool
    ) {

        Trade memory trade = trades[_tradeId];
        return(
            trade.tradeId,
            trade.openingTokenAddress,
            trade.openingTokenId,
            trade.closingTokenAddress,
            trade.closingTokenId,
            trade.expiryDate,
            trade.successDate,
            trade.tradeOpener,
            trade.tradeCloser,
            trade.active
        );
    }

    function getTradeCount() public view returns(uint256) {

        return trades.length;
    }

    function cancelTrade(
        uint256 _tradeId
    ) public {

        Trade memory trade = trades[_tradeId];
        require(
            trade.tradeOpener == msg.sender,
            "Popswap::cancelTrade: _tradeId must be trade created by msg.sender"
        );
        require(
            trade.tradeCloser == 0x0000000000000000000000000000000000000000,
            "Popswap::cancelTrade: _tradeCloser can't already be non-zero address"
        );
        require(
            trade.expiryDate > block.timestamp,
            "Popswap::cancelTrade: trade.expiryDate must be after current block.timestamp"
        );
        trades[_tradeId] = Trade(
            trade.tradeId,
            trade.openingTokenAddress,
            trade.openingTokenId,
            trade.closingTokenAddress,
            trade.closingTokenId,
            trade.expiryDate,
            trade.successDate,
            trade.tradeOpener,
            msg.sender,
            false
        );
        _tradeIdToTradeCloser[_tradeId] = msg.sender;
        emit TradeCancelled(trade.tradeId, msg.sender);
    }

    function isTradeExecutable(uint256 _tradeId, uint8 _openingTokenType, uint8 _closingTokenType) public view returns (bool) {

        require(
            _openingTokenType <= 1,
            "Popswap::isTradeExecutable: _openingTokenType must be either 0 or 1"
        );
        require(
            _closingTokenType <= 1,
            "Popswap::isTradeExecutable: _closingTokenType must be either 0 or 1"
        );
        Trade memory trade = trades[_tradeId];
        if(trade.expiryDate < block.timestamp) {
            return false;
        }
        if(trade.active != true) {
            return false;
        }
        if(_openingTokenType == 0) {
            IERC721 openingToken = IERC721(trade.openingTokenAddress);
            if(openingToken.isApprovedForAll(trade.tradeOpener, address(this)) != true) {
                return false;
            }
            if(openingToken.ownerOf(trade.openingTokenId) != trade.tradeOpener) {
                return false;
            }
        }else if(_openingTokenType == 1) {
            IERC1155 openingToken = IERC1155(trade.openingTokenAddress);
            if(openingToken.isApprovedForAll(trade.tradeOpener, address(this)) != true) {
                return false;
            }
            if(openingToken.balanceOf(trade.tradeOpener, trade.openingTokenId) < 1) {
                return false;
            }
        }
        if(_closingTokenType == 0) {
            IERC721 closingToken = IERC721(trade.closingTokenAddress);
            if(closingToken.isApprovedForAll(msg.sender, address(this)) != true) {
                return false;
            }
            if(closingToken.ownerOf(trade.closingTokenId) != msg.sender) {
                return false;
            }
        }else if(_closingTokenType == 1) {
            IERC1155 closingToken = IERC1155(trade.closingTokenAddress);
            if(closingToken.isApprovedForAll(msg.sender, address(this)) != true) {
                return false;
            }
            if(closingToken.balanceOf(msg.sender, trade.closingTokenId) < 1) {
                return false;
            }
        }
        return true;
    }

    function executeTrade(uint256 _tradeId, uint8 _openingTokenType, uint8 _closingTokenType) public nonReentrant returns (uint256) {

        require(
            _openingTokenType <= 1,
            "Popswap::executeTrade: _openingTokenType must be either 0 or 1"
        );
        require(
            _closingTokenType <= 1,
            "Popswap::executeTrade: _closingTokenType must be either 0 or 1"
        );
        Trade memory trade = trades[_tradeId];
        require(
            trade.active == true,
            "Popswap::executeTrade: trade is no longer active"
        );
        require(
            trade.expiryDate > block.timestamp,
            "Popswap::executeTrade: trade has expired"
        );
        if(_openingTokenType == 0) {
            IERC721 openingToken = IERC721(trade.openingTokenAddress);
            openingToken.safeTransferFrom(trade.tradeOpener, msg.sender, trade.openingTokenId);
        }else if(_openingTokenType == 1) {
            IERC1155 openingToken = IERC1155(trade.openingTokenAddress);
            openingToken.safeTransferFrom(trade.tradeOpener, msg.sender, trade.openingTokenId, 1, "0000000000000000000000000000000000000000000000000000000000000000");
        }
        if(_closingTokenType == 0) {
            IERC721 closingToken = IERC721(trade.closingTokenAddress);
            closingToken.safeTransferFrom(msg.sender, trade.tradeOpener, trade.closingTokenId);
        }else if(_closingTokenType == 1) {
            IERC1155 closingToken = IERC1155(trade.closingTokenAddress);
            closingToken.safeTransferFrom(msg.sender, trade.tradeOpener, trade.closingTokenId, 1, "0000000000000000000000000000000000000000000000000000000000000000");
        }
        trades[_tradeId] = Trade(
            trade.tradeId,
            trade.openingTokenAddress,
            trade.openingTokenId,
            trade.closingTokenAddress,
            trade.closingTokenId,
            trade.expiryDate,
            block.timestamp,
            trade.tradeOpener,
            msg.sender,
            false
        );
        _tradeIdToTradeCloser[_tradeId] = msg.sender;
        emit TradeExecuted(trade.tradeId, trade.tradeOpener, msg.sender);
        return trade.tradeId;
    }
}
