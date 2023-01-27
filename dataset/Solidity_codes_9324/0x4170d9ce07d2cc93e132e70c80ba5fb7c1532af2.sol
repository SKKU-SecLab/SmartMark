
pragma solidity 0.5.0;




contract IOrderCanceller {


    event OrdersCancelled(
        address indexed _broker,
        bytes32[]       _orderHashes
    );

    event AllOrdersCancelledForTradingPair(
        address indexed _broker,
        address         _token1,
        address         _token2,
        uint            _cutoff
    );

    event AllOrdersCancelled(
        address indexed _broker,
        uint            _cutoff
    );

    event AllOrdersCancelledForTradingPairByBroker(
        address indexed _broker,
        address indexed _owner,
        address         _token1,
        address         _token2,
        uint            _cutoff
    );

    event AllOrdersCancelledByBroker(
        address indexed _broker,
        address indexed _owner,
        uint            _cutoff
    );

    function cancelOrders(
        bytes calldata orderHashes
        )
        external;


    function cancelAllOrdersForTradingPair(
        address token1,
        address token2,
        uint    cutoff
        )
        external;


    function cancelAllOrders(
        uint    cutoff
        )
        external;


    function cancelAllOrdersForTradingPairOfOwner(
        address owner,
        address token1,
        address token2,
        uint    cutoff
        )
        external;


    function cancelAllOrdersOfOwner(
        address owner,
        uint    cutoff
        )
        external;

}




contract ITradeHistory {


    mapping (bytes32 => uint) public filled;

    mapping (address => mapping (bytes32 => bool)) public cancelled;

    mapping (address => uint) public cutoffs;

    mapping (address => mapping (bytes20 => uint)) public tradingPairCutoffs;

    mapping (address => mapping (address => uint)) public cutoffsOwner;

    mapping (address => mapping (address => mapping (bytes20 => uint))) public tradingPairCutoffsOwner;


    function batchUpdateFilled(
        bytes32[] calldata filledInfo
        )
        external;


    function setCancelled(
        address broker,
        bytes32 orderHash
        )
        external;


    function setCutoffs(
        address broker,
        uint cutoff
        )
        external;


    function setTradingPairCutoffs(
        address broker,
        bytes20 tokenPair,
        uint cutoff
        )
        external;


    function setCutoffsOfOwner(
        address broker,
        address owner,
        uint cutoff
        )
        external;


    function setTradingPairCutoffsOfOwner(
        address broker,
        address owner,
        bytes20 tokenPair,
        uint cutoff
        )
        external;


    function batchGetFilledAndCheckCancelled(
        bytes32[] calldata orderInfo
        )
        external
        view
        returns (uint[] memory fills);



    function authorizeAddress(
        address addr
        )
        external;


    function deauthorizeAddress(
        address addr
        )
        external;


    function isAddressAuthorized(
        address addr
        )
        public
        view
        returns (bool);



    function suspend()
        external;


    function resume()
        external;


    function kill()
        external;

}





library BytesUtil {

    function bytesToBytes32(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (bytes32)
    {

        return bytes32(bytesToUintX(b, offset, 32));
    }

    function bytesToUint(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (uint)
    {

        return bytesToUintX(b, offset, 32);
    }

    function bytesToAddress(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (address)
    {

        return address(bytesToUintX(b, offset, 20) & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    function bytesToUint16(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (uint16)
    {

        return uint16(bytesToUintX(b, offset, 2) & 0xFFFF);
    }

    function bytesToUintX(
        bytes memory b,
        uint offset,
        uint numBytes
        )
        private
        pure
        returns (uint data)
    {

        require(b.length >= offset + numBytes, "INVALID_SIZE");
        assembly {
            data := mload(add(add(b, numBytes), offset))
        }
    }

    function subBytes(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (bytes memory data)
    {

        require(b.length >= offset + 32, "INVALID_SIZE");
        assembly {
            data := add(add(b, 32), offset)
        }
    }
}






contract Errors {

    string constant ZERO_VALUE                 = "ZERO_VALUE";
    string constant ZERO_ADDRESS               = "ZERO_ADDRESS";
    string constant INVALID_VALUE              = "INVALID_VALUE";
    string constant INVALID_ADDRESS            = "INVALID_ADDRESS";
    string constant INVALID_SIZE               = "INVALID_SIZE";
    string constant INVALID_SIG                = "INVALID_SIG";
    string constant INVALID_STATE              = "INVALID_STATE";
    string constant NOT_FOUND                  = "NOT_FOUND";
    string constant ALREADY_EXIST              = "ALREADY_EXIST";
    string constant REENTRY                    = "REENTRY";
    string constant UNAUTHORIZED               = "UNAUTHORIZED";
    string constant UNIMPLEMENTED              = "UNIMPLEMENTED";
    string constant UNSUPPORTED                = "UNSUPPORTED";
    string constant TRANSFER_FAILURE           = "TRANSFER_FAILURE";
    string constant WITHDRAWAL_FAILURE         = "WITHDRAWAL_FAILURE";
    string constant BURN_FAILURE               = "BURN_FAILURE";
    string constant BURN_RATE_FROZEN           = "BURN_RATE_FROZEN";
    string constant BURN_RATE_MINIMIZED        = "BURN_RATE_MINIMIZED";
    string constant UNAUTHORIZED_ONCHAIN_ORDER = "UNAUTHORIZED_ONCHAIN_ORDER";
    string constant INVALID_CANDIDATE          = "INVALID_CANDIDATE";
    string constant ALREADY_VOTED              = "ALREADY_VOTED";
    string constant NOT_OWNER                  = "NOT_OWNER";
}



contract NoDefaultFunc is Errors {

    function ()
        external
        payable
    {
        revert(UNSUPPORTED);
    }
}



contract OrderCanceller is IOrderCanceller, NoDefaultFunc {

    using BytesUtil       for bytes;

    address public constant tradeHistoryAddress = 0xBF5a37670B3DE1E606EC68bE3558c536b2008669;



    function cancelOrders(
        bytes calldata orderHashes
        )
        external
    {

        uint size = orderHashes.length;
        require(size > 0 && size % 32 == 0, INVALID_SIZE);

        size /= 32;
        bytes32[] memory hashes = new bytes32[](size);

        ITradeHistory tradeHistory = ITradeHistory(tradeHistoryAddress);

        for (uint i = 0; i < size; i++) {
            hashes[i] = orderHashes.bytesToBytes32(i * 32);
            tradeHistory.setCancelled(msg.sender, hashes[i]);
        }

        emit OrdersCancelled(
            msg.sender,
            hashes
        );
    }

    function cancelAllOrdersForTradingPair(
        address token1,
        address token2,
        uint    cutoff
        )
        external
    {

        uint t = (cutoff == 0) ? block.timestamp : cutoff;

        bytes20 tokenPair = bytes20(token1) ^ bytes20(token2);

        ITradeHistory(tradeHistoryAddress).setTradingPairCutoffs(
            msg.sender,
            tokenPair,
            t
        );

        emit AllOrdersCancelledForTradingPair(
            msg.sender,
            token1,
            token2,
            t
        );
    }

    function cancelAllOrders(
        uint   cutoff
        )
        external
    {

        uint t = (cutoff == 0) ? block.timestamp : cutoff;

        ITradeHistory(tradeHistoryAddress).setCutoffs(msg.sender, t);

        emit AllOrdersCancelled(
            msg.sender,
            t
        );
    }

    function cancelAllOrdersForTradingPairOfOwner(
        address owner,
        address token1,
        address token2,
        uint    cutoff
        )
        external
    {

        uint t = (cutoff == 0) ? block.timestamp : cutoff;

        bytes20 tokenPair = bytes20(token1) ^ bytes20(token2);

        ITradeHistory(tradeHistoryAddress).setTradingPairCutoffsOfOwner(
            msg.sender,
            owner,
            tokenPair,
            t
        );

        emit AllOrdersCancelledForTradingPairByBroker(
            msg.sender,
            owner,
            token1,
            token2,
            t
        );
    }

    function cancelAllOrdersOfOwner(
        address owner,
        uint    cutoff
        )
        external
    {

        uint t = (cutoff == 0) ? block.timestamp : cutoff;

        ITradeHistory(tradeHistoryAddress).setCutoffsOfOwner(
            msg.sender,
            owner,
            t
        );

        emit AllOrdersCancelledByBroker(
            msg.sender,
            owner,
            t
        );
    }

}