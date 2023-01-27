

pragma solidity 0.5.7;

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




contract IBrokerRegistry {

    event BrokerRegistered(
        address owner,
        address broker,
        address interceptor
    );

    event BrokerUnregistered(
        address owner,
        address broker,
        address interceptor
    );

    event AllBrokersUnregistered(
        address owner
    );

    function getBroker(
        address owner,
        address broker
        )
        external
        view
        returns(
            bool registered,
            address interceptor
        );


    function getBrokers(
        address owner,
        uint    start,
        uint    count
        )
        external
        view
        returns (
            address[] memory brokers,
            address[] memory interceptors
        );


    function registerBroker(
        address broker,
        address interceptor
        )
        external;


    function unregisterBroker(
        address broker
        )
        external;


    function unregisterAllBrokers(
        )
        external;

}





contract NoDefaultFunc is Errors {

    function ()
        external
        payable
    {
        revert(UNSUPPORTED);
    }
}







contract BrokerRegistry is IBrokerRegistry, NoDefaultFunc {

    struct Broker {
        address owner;
        address addr;
        address interceptor;
    }

    mapping (address => Broker[]) public brokersMap;
    mapping (address => mapping (address => uint)) public positionMap;

    function getBroker(
        address owner,
        address addr
        )
        external
        view
        returns(
            bool registered,
            address interceptor
        )
    {

        uint pos = positionMap[owner][addr];
        if (pos == 0) {
            registered = false;
        } else {
            registered = true;
            Broker storage broker = brokersMap[owner][pos - 1];
            interceptor = broker.interceptor;
        }
    }

    function getBrokers(
        address owner,
        uint    start,
        uint    count
        )
        external
        view
        returns (
            address[] memory brokers,
            address[] memory interceptors
        )
    {

        Broker[] storage _brokers = brokersMap[owner];
        uint size = _brokers.length;

        if (start >= size) {
            return (brokers, interceptors);
        }

        uint end = start + count;
        if (end > size) {
            end = size;
        }

        brokers = new address[](end - start);
        interceptors = new address[](end - start);

        for (uint i = start; i < end; i++) {
            brokers[i - start] = _brokers[i].addr;
            interceptors[i - start] = _brokers[i].interceptor;
        }
    }

    function registerBroker(
        address broker,
        address interceptor  // 0x0 allowed
        )
        external
    {

        require(address(0x0) != broker, ZERO_ADDRESS);
        require(
            0 == positionMap[msg.sender][broker],
            ALREADY_EXIST
        );

        if (interceptor != address(0x0)) {
            require(isContract(interceptor), INVALID_ADDRESS);
        }

        Broker[] storage brokers = brokersMap[msg.sender];
        Broker memory b = Broker(
            msg.sender,
            broker,
            interceptor
        );

        brokers.push(b);
        positionMap[msg.sender][broker] = brokers.length;

        emit BrokerRegistered(
            msg.sender,
            broker,
            interceptor
        );
    }

    function unregisterBroker(
        address addr
        )
        external
    {

        require(address(0x0) != addr, ZERO_ADDRESS);

        uint pos = positionMap[msg.sender][addr];
        require(pos != 0, NOT_FOUND);

        Broker[] storage brokers = brokersMap[msg.sender];
        uint size = brokers.length;

        address interceptor = brokers[pos - 1].interceptor;
        if (pos != size) {
            Broker storage lastOne = brokers[size - 1];
            brokers[pos - 1] = lastOne;
            positionMap[lastOne.owner][lastOne.addr] = pos;
        }

        brokers.length -= 1;
        delete positionMap[msg.sender][addr];

        emit BrokerUnregistered(
            msg.sender,
            addr,
            interceptor
        );
    }

    function unregisterAllBrokers(
        )
        external
    {

        Broker[] storage brokers = brokersMap[msg.sender];

        for (uint i = 0; i < brokers.length; i++) {
            delete positionMap[msg.sender][brokers[i].addr];
        }
        delete brokersMap[msg.sender];

        emit AllBrokersUnregistered(msg.sender);
    }

    function isContract(
        address addr
        )
        public
        view
        returns (bool)
    {

        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}