

pragma solidity 0.5.16;

contract DSAuthEvents {

    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {

    address public owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) external auth {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    modifier auth {

        require(isAuthorized(msg.sender), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src) internal view returns (bool) {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else {
            return false;
        }
    }
}

contract DSMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {

        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {

        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract ERC20 {

    function totalSupply() public view returns (uint256);


    function balanceOf(address guy) public view returns (uint256);


    function allowance(address src, address guy) public view returns (uint256);


    function approve(address guy, uint256 wad) public returns (bool);


    function transfer(address dst, uint256 wad) public returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public returns (bool);

}

contract EventfulMarket {

    event LogItemUpdate(uint256 id);
    event LogTrade(
        uint256 pay_amt,
        address indexed pay_gem,
        uint256 buy_amt,
        address indexed buy_gem
    );

    event LogMake(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );

    event LogBump(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );

    event LogTake(
        bytes32 id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        address indexed taker,
        uint128 take_amt,
        uint128 give_amt,
        uint64 timestamp
    );

    event LogKill(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );

    event LogInt(string lol, uint256 input);

    event FeeTake(
        bytes32 id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        address indexed taker,
        uint128 take_amt,
        uint128 give_amt,
        uint256 feeAmt,
        address feeTo,
        uint64 timestamp
    );
}

contract SimpleMarket is EventfulMarket, DSMath {

    uint256 public last_offer_id;

    mapping(uint256 => OfferInfo) public offers;

    bool locked;

    uint256 internal feeBPS;

    address internal feeTo;

    struct OfferInfo {
        uint256 pay_amt;
        ERC20 pay_gem;
        uint256 buy_amt;
        ERC20 buy_gem;
        address owner;
        uint64 timestamp;
    }

    constructor(address _feeTo) public {
        feeTo = _feeTo;

        feeBPS = 20;
    }

    modifier can_buy(uint256 id) {

        require(isActive(id));
        _;
    }

    modifier can_cancel(uint256 id) {

        require(isActive(id));
        require(getOwner(id) == msg.sender);
        _;
    }

    modifier can_offer {

        _;
    }

    modifier synchronized {

        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    function isActive(uint256 id) public view returns (bool active) {

        return offers[id].timestamp > 0;
    }

    function getOwner(uint256 id) public view returns (address owner) {

        return offers[id].owner;
    }

    function getOffer(uint256 id)
        public
        view
        returns (
            uint256,
            ERC20,
            uint256,
            ERC20
        )
    {

        OfferInfo memory offer = offers[id];
        return (offer.pay_amt, offer.pay_gem, offer.buy_amt, offer.buy_gem);
    }


    function bump(bytes32 id_) external can_buy(uint256(id_)) {

        uint256 id = uint256(id_);
        emit LogBump(
            id_,
            keccak256(abi.encodePacked(offers[id].pay_gem, offers[id].buy_gem)),
            offers[id].owner,
            offers[id].pay_gem,
            offers[id].buy_gem,
            uint128(offers[id].pay_amt),
            uint128(offers[id].buy_amt),
            offers[id].timestamp
        );
    }

    function buy(uint256 id, uint256 quantity)
        public
        can_buy(id)
        synchronized
        returns (bool)
    {

        OfferInfo memory offer = offers[id];
        uint256 spend = mul(quantity, offer.buy_amt) / offer.pay_amt;

        require(uint128(spend) == spend, "spend is not an int");
        require(uint128(quantity) == quantity, "quantity is not an int");

        if (
            quantity == 0 ||
            spend == 0 ||
            quantity > offer.pay_amt ||
            spend > offer.buy_amt
        ) {
            return false;
        }

        uint256 fee = mul(spend, feeBPS) / 10000;
        require(
            offer.buy_gem.transferFrom(msg.sender, feeTo, fee),
            "Insufficient funds to cover fee"
        );

        offers[id].pay_amt = sub(offer.pay_amt, quantity);
        offers[id].buy_amt = sub(offer.buy_amt, spend);
        require(
            offer.buy_gem.transferFrom(msg.sender, offer.owner, spend),
            "offer.buy_gem.transferFrom(msg.sender, offer.owner, spend) failed"
        );
        require(
            offer.pay_gem.transfer(msg.sender, quantity),
            "offer.pay_gem.transfer(msg.sender, quantity) failed"
        );

        emit LogItemUpdate(id);
        emit LogTake(
            bytes32(id),
            keccak256(abi.encodePacked(offer.pay_gem, offer.buy_gem)),
            offer.owner,
            offer.pay_gem,
            offer.buy_gem,
            msg.sender,
            uint128(quantity),
            uint128(spend),
            uint64(now)
        );
        emit FeeTake(
            bytes32(id),
            keccak256(abi.encodePacked(offer.pay_gem, offer.buy_gem)),
            offer.owner,
            offer.pay_gem,
            offer.buy_gem,
            msg.sender,
            uint128(quantity),
            uint128(spend),
            fee,
            feeTo,
            uint64(now)
        );
        emit LogTrade(
            quantity,
            address(offer.pay_gem),
            spend,
            address(offer.buy_gem)
        );

        if (offers[id].pay_amt == 0) {
            delete offers[id];
        }

        return true;
    }

    function cancel(uint256 id)
        public
        can_cancel(id)
        synchronized
        returns (bool success)
    {

        OfferInfo memory offer = offers[id];
        delete offers[id];

        require(offer.pay_gem.transfer(offer.owner, offer.pay_amt));

        emit LogItemUpdate(id);
        emit LogKill(
            bytes32(id),
            keccak256(abi.encodePacked(offer.pay_gem, offer.buy_gem)),
            offer.owner,
            offer.pay_gem,
            offer.buy_gem,
            uint128(offer.pay_amt),
            uint128(offer.buy_amt),
            uint64(now)
        );

        success = true;
    }

    function kill(bytes32 id) external {

        require(cancel(uint256(id)));
    }

    function make(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    ) external returns (bytes32 id) {

        return bytes32(offer(pay_amt, pay_gem, buy_amt, buy_gem));
    }

    function offer(
        uint256 pay_amt,
        ERC20 pay_gem,
        uint256 buy_amt,
        ERC20 buy_gem
    ) public can_offer synchronized returns (uint256 id) {

        require(uint128(pay_amt) == pay_amt);
        require(uint128(buy_amt) == buy_amt);
        require(pay_amt > 0);
        require(pay_gem != ERC20(0x0));
        require(buy_amt > 0);
        require(buy_gem != ERC20(0x0));
        require(pay_gem != buy_gem);

        OfferInfo memory info;
        info.pay_amt = pay_amt;
        info.pay_gem = pay_gem;
        info.buy_amt = buy_amt;
        info.buy_gem = buy_gem;
        info.owner = msg.sender;
        info.timestamp = uint64(now);
        id = _next_id();
        offers[id] = info;

        require(pay_gem.transferFrom(msg.sender, address(this), pay_amt));

        emit LogItemUpdate(id);
        emit LogMake(
            bytes32(id),
            keccak256(abi.encodePacked(pay_gem, buy_gem)),
            msg.sender,
            pay_gem,
            buy_gem,
            uint128(pay_amt),
            uint128(buy_amt),
            uint64(now)
        );
    }

    function take(bytes32 id, uint128 maxTakeAmount) external {

        require(buy(uint256(id), maxTakeAmount));
    }

    function _next_id() internal returns (uint256) {

        last_offer_id++;
        return last_offer_id;
    }

    function getFeeBPS() internal view returns (uint256) {

        return feeBPS;
    }
}

contract ExpiringMarket is DSAuth, SimpleMarket {

    uint64 public close_time;
    bool public stopped;

    modifier can_offer {

        require(!isClosed());
        _;
    }

    modifier can_buy(uint256 id) {

        require(isActive(id));
        require(!isClosed());
        _;
    }

    modifier can_cancel(uint256 id) {

        require(isActive(id));
        require((msg.sender == getOwner(id)) || isClosed());
        _;
    }

    constructor(uint64 _close_time) public {
        close_time = _close_time;
    }

    function isClosed() public view returns (bool closed) {

        return stopped || getTime() > close_time;
    }

    function getTime() public view returns (uint64) {

        return uint64(now);
    }

    function stop() external auth {

        stopped = true;
    }
}

contract DSNote {

    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 indexed bar,
        uint256 wad,
        bytes fax
    ) anonymous;

    modifier note {

        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);

        _;
    }
}

contract MatchingEvents {

    event LogBuyEnabled(bool isEnabled);
    event LogMinSell(address pay_gem, uint256 min_amount);
    event LogMatchingEnabled(bool isEnabled);
    event LogUnsortedOffer(uint256 id);
    event LogSortedOffer(uint256 id);
    event LogInsert(address keeper, uint256 id);
    event LogDelete(address keeper, uint256 id);
}

contract RubiconMarket is MatchingEvents, ExpiringMarket, DSNote {

    bool public buyEnabled = true; //buy enabled
    bool public matchingEnabled = true; //true: enable matching,
    struct sortInfo {
        uint256 next; //points to id of next higher offer
        uint256 prev; //points to id of previous lower offer
        uint256 delb; //the blocknumber where this entry was marked for delete
    }
    mapping(uint256 => sortInfo) public _rank; //doubly linked lists of sorted offer ids
    mapping(address => mapping(address => uint256)) public _best; //id of the highest offer for a token pair
    mapping(address => mapping(address => uint256)) public _span; //number of offers stored for token pair in sorted orderbook
    mapping(address => uint256) public _dust; //minimum sell amount for a token to avoid dust offers
    mapping(uint256 => uint256) public _near; //next unsorted offer id
    uint256 _head; //first unsorted offer id
    uint256 public dustId; // id of the latest offer marked as dust
    address public AqueductAddress;
    bool public AqueductDistributionLive;

    address public WETHAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(
        uint64 close_time,
        bool RBCNDist,
        address _feeTo
    ) public ExpiringMarket(close_time) SimpleMarket(_feeTo) {
        AqueductDistributionLive = RBCNDist;
    }

    modifier can_cancel(uint256 id) {

        require(isActive(id), "Offer was deleted or taken, or never existed.");
        require(
            isClosed() || msg.sender == getOwner(id) || id == dustId,
            "Offer can not be cancelled because user is not owner, and market is open, and offer sells required amount of tokens."
        );
        _;
    }


    function make(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    ) public returns (bytes32) {

        return bytes32(offer(pay_amt, pay_gem, buy_amt, buy_gem));
    }

    function take(bytes32 id, uint128 maxTakeAmount) public {

        require(buy(uint256(id), maxTakeAmount));
    }

    function kill(bytes32 id) external {

        require(cancel(uint256(id)));
    }

    function offerInETH(
        uint256 buy_amt, //taker (ask) buy how much
        ERC20 buy_gem //taker (ask) buy which token
    ) external payable returns (uint256) {

        require(!locked, "Reentrancy attempt");

        IWETH(WETHAddress).deposit.value(msg.value)();
        IWETH(WETHAddress).transfer(msg.sender, msg.value);

        ERC20 WETH = ERC20(WETHAddress);

        if (matchingEnabled) {
            return _matcho(msg.value, WETH, buy_amt, buy_gem, 0, true);
        }
        return super.offer(msg.value, WETH, buy_amt, buy_gem);
    }

    function buyInETH(uint256 id) external payable can_buy(id) returns (bool) {

        require(!locked, "Reentrancy attempt");
        ERC20 WETH = ERC20(WETHAddress);
        require(offers[id].buy_gem == WETH, "offer you buy must be in WETH");
        IWETH(WETHAddress).deposit.value(msg.value)();
        IWETH(WETHAddress).transfer(msg.sender, msg.value);

        super.buy(id, msg.value);
    }

    function offer(
        uint256 pay_amt, //maker (ask) sell how much
        ERC20 pay_gem, //maker (ask) sell which token
        uint256 buy_amt, //taker (ask) buy how much
        ERC20 buy_gem //taker (ask) buy which token
    ) public returns (uint256) {

        require(!locked, "Reentrancy attempt");
        function(uint256, ERC20, uint256, ERC20) returns (uint256) fn =
            matchingEnabled ? _offeru : super.offer;
        return fn(pay_amt, pay_gem, buy_amt, buy_gem);
    }

    function offer(
        uint256 pay_amt, //maker (ask) sell how much
        ERC20 pay_gem, //maker (ask) sell which token
        uint256 buy_amt, //maker (ask) buy how much
        ERC20 buy_gem, //maker (ask) buy which token
        uint256 pos //position to insert offer, 0 should be used if unknown
    ) external can_offer returns (uint256) {

        return offer(pay_amt, pay_gem, buy_amt, buy_gem, pos, true);
    }

    function offer(
        uint256 pay_amt, //maker (ask) sell how much
        ERC20 pay_gem, //maker (ask) sell which token
        uint256 buy_amt, //maker (ask) buy how much
        ERC20 buy_gem, //maker (ask) buy which token
        uint256 pos, //position to insert offer, 0 should be used if unknown
        bool matching //match "close enough" orders?
    ) public can_offer returns (uint256) {

        require(!locked, "Reentrancy attempt");
        require(_dust[address(pay_gem)] <= pay_amt);

        if (matchingEnabled) {
            return _matcho(pay_amt, pay_gem, buy_amt, buy_gem, pos, matching);
        }
        return super.offer(pay_amt, pay_gem, buy_amt, buy_gem);
    }

    function buy(uint256 id, uint256 amount) public can_buy(id) returns (bool) {

        require(!locked, "Reentrancy attempt");

        if (AqueductDistributionLive) {
            IAqueduct(AqueductAddress).distributeToMakerAndTaker(
                getOwner(id),
                msg.sender
            );
        }
        function(uint256, uint256) returns (bool) fn =
            matchingEnabled ? _buys : super.buy; 

        return fn(id, amount);
    }

    function cancel(uint256 id) public can_cancel(id) returns (bool success) {

        require(!locked, "Reentrancy attempt");
        if (matchingEnabled) {
            if (isOfferSorted(id)) {
                require(_unsort(id));
            } else {
                require(_hide(id));
            }
        }
        return super.cancel(id); //delete the offer.
    }

    function insert(
        uint256 id, //maker (ask) id
        uint256 pos //position to insert into
    ) public returns (bool) {

        require(!locked, "Reentrancy attempt");
        require(!isOfferSorted(id)); //make sure offers[id] is not yet sorted
        require(isActive(id)); //make sure offers[id] is active

        _hide(id); //remove offer from unsorted offers list
        _sort(id, pos); //put offer into the sorted offers list
        emit LogInsert(msg.sender, id);
        return true;
    }

    function del_rank(uint256 id) external returns (bool) {

        require(!locked, "Reentrancy attempt");
        require(
            !isActive(id) &&
                _rank[id].delb != 0 &&
                _rank[id].delb < block.number - 10
        );
        delete _rank[id];
        emit LogDelete(msg.sender, id);
        return true;
    }

    function setMinSell(
        ERC20 pay_gem, //token to assign minimum sell amount to
        uint256 dust //maker (ask) minimum sell amount
    ) external auth note returns (bool) {

        _dust[address(pay_gem)] = dust;
        emit LogMinSell(address(pay_gem), dust);
        return true;
    }

    function getMinSell(
        ERC20 pay_gem //token for which minimum sell amount is queried
    ) external view returns (uint256) {

        return _dust[address(pay_gem)];
    }

    function setBuyEnabled(bool buyEnabled_) external auth returns (bool) {

        buyEnabled = buyEnabled_;
        emit LogBuyEnabled(buyEnabled);
        return true;
    }

    function setMatchingEnabled(bool matchingEnabled_)
        external
        auth
        returns (bool)
    {

        matchingEnabled = matchingEnabled_;
        emit LogMatchingEnabled(matchingEnabled);
        return true;
    }

    function getBestOffer(ERC20 sell_gem, ERC20 buy_gem)
        public
        view
        returns (uint256)
    {

        return _best[address(sell_gem)][address(buy_gem)];
    }

    function getWorseOffer(uint256 id) public view returns (uint256) {

        return _rank[id].prev;
    }

    function getBetterOffer(uint256 id) external view returns (uint256) {

        return _rank[id].next;
    }

    function getOfferCount(ERC20 sell_gem, ERC20 buy_gem)
        public
        view
        returns (uint256)
    {

        return _span[address(sell_gem)][address(buy_gem)];
    }

    function getFirstUnsortedOffer() public view returns (uint256) {

        return _head;
    }

    function getNextUnsortedOffer(uint256 id) public view returns (uint256) {

        return _near[id];
    }

    function isOfferSorted(uint256 id) public view returns (bool) {

        return
            _rank[id].next != 0 ||
            _rank[id].prev != 0 ||
            _best[address(offers[id].pay_gem)][address(offers[id].buy_gem)] ==
            id;
    }

    function sellAllAmount(
        ERC20 pay_gem,
        uint256 pay_amt,
        ERC20 buy_gem,
        uint256 min_fill_amount
    ) external returns (uint256 fill_amt) {

        require(!locked, "Reentrancy attempt");
        uint256 offerId;
        while (pay_amt > 0) {
            offerId = getBestOffer(buy_gem, pay_gem); //Get the best offer for the token pair
            require(offerId != 0); //Fails if there are not more offers

            if (
                pay_amt * 1 ether <
                wdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
            ) {
                break; //We consider that all amount is sold
            }
            if (pay_amt >= offers[offerId].buy_amt) {
                fill_amt = add(fill_amt, offers[offerId].pay_amt); //Add amount bought to acumulator
                pay_amt = sub(pay_amt, offers[offerId].buy_amt); //Decrease amount to sell
                take(bytes32(offerId), uint128(offers[offerId].pay_amt)); //We take the whole offer
            } else {
                uint256 baux =
                    rmul(
                        pay_amt * 10**9,
                        rdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
                    ) / 10**9;
                fill_amt = add(fill_amt, baux); //Add amount bought to acumulator
                take(bytes32(offerId), uint128(baux)); //We take the portion of the offer that we need
                pay_amt = 0; //All amount is sold
            }
        }
        require(fill_amt >= min_fill_amount);
    }

    function buyAllAmount(
        ERC20 buy_gem,
        uint256 buy_amt,
        ERC20 pay_gem,
        uint256 max_fill_amount
    ) external returns (uint256 fill_amt) {

        require(!locked, "Reentrancy attempt");
        uint256 offerId;
        while (buy_amt > 0) {
            offerId = getBestOffer(buy_gem, pay_gem); //Get the best offer for the token pair
            require(offerId != 0);

            if (
                buy_amt * 1 ether <
                wdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
            ) {
                break; //We consider that all amount is sold
            }
            if (buy_amt >= offers[offerId].pay_amt) {
                fill_amt = add(fill_amt, offers[offerId].buy_amt); //Add amount sold to acumulator
                buy_amt = sub(buy_amt, offers[offerId].pay_amt); //Decrease amount to buy
                take(bytes32(offerId), uint128(offers[offerId].pay_amt)); //We take the whole offer
            } else {
                fill_amt = add(
                    fill_amt,
                    rmul(
                        buy_amt * 10**9,
                        rdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
                    ) / 10**9
                ); //Add amount sold to acumulator
                take(bytes32(offerId), uint128(buy_amt)); //We take the portion of the offer that we need
                buy_amt = 0; //All amount is bought
            }
        }
        require(fill_amt <= max_fill_amount);
    }

    function getBuyAmount(
        ERC20 buy_gem,
        ERC20 pay_gem,
        uint256 pay_amt
    ) external view returns (uint256 fill_amt) {

        uint256 offerId = getBestOffer(buy_gem, pay_gem); //Get best offer for the token pair
        while (pay_amt > offers[offerId].buy_amt) {
            fill_amt = add(fill_amt, offers[offerId].pay_amt); //Add amount to buy accumulator
            pay_amt = sub(pay_amt, offers[offerId].buy_amt); //Decrease amount to pay
            if (pay_amt > 0) {
                offerId = getWorseOffer(offerId); //We look for the next best offer
                require(offerId != 0); //Fails if there are not enough offers to complete
            }
        }
        fill_amt = add(
            fill_amt,
            rmul(
                pay_amt * 10**9,
                rdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
            ) / 10**9
        ); //Add proportional amount of last offer to buy accumulator
    }

    function getPayAmount(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint256 buy_amt
    ) external view returns (uint256 fill_amt) {

        uint256 offerId = getBestOffer(buy_gem, pay_gem); //Get best offer for the token pair
        while (buy_amt > offers[offerId].pay_amt) {
            fill_amt = add(fill_amt, offers[offerId].buy_amt); //Add amount to pay accumulator
            buy_amt = sub(buy_amt, offers[offerId].pay_amt); //Decrease amount to buy
            if (buy_amt > 0) {
                offerId = getWorseOffer(offerId); //We look for the next best offer
                require(offerId != 0); //Fails if there are not enough offers to complete
            }
        }
        fill_amt = add(
            fill_amt,
            rmul(
                buy_amt * 10**9,
                rdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
            ) / 10**9
        ); //Add proportional amount of last offer to pay accumulator
    }


    function _buys(uint256 id, uint256 amount) internal returns (bool) {

        require(buyEnabled);
        if (amount == offers[id].pay_amt) {
            if (isOfferSorted(id)) {
                _unsort(id);
            } else {
                _hide(id);
            }
        }

        require(super.buy(id, amount));

        if (
            isActive(id) &&
            offers[id].pay_amt < _dust[address(offers[id].pay_gem)]
        ) {
            dustId = id; //enable current msg.sender to call cancel(id)
            cancel(id);
        }
        return true;
    }

    function _find(uint256 id) internal view returns (uint256) {

        require(id > 0);

        address buy_gem = address(offers[id].buy_gem);
        address pay_gem = address(offers[id].pay_gem);
        uint256 top = _best[pay_gem][buy_gem];
        uint256 old_top = 0;

        while (top != 0 && _isPricedLtOrEq(id, top)) {
            old_top = top;
            top = _rank[top].prev;
        }
        return old_top;
    }

    function _findpos(uint256 id, uint256 pos) internal view returns (uint256) {

        require(id > 0);

        while (pos != 0 && !isActive(pos)) {
            pos = _rank[pos].prev;
        }

        if (pos == 0) {
            return _find(id);
        } else {
            if (_isPricedLtOrEq(id, pos)) {
                uint256 old_pos;

                while (pos != 0 && _isPricedLtOrEq(id, pos)) {
                    old_pos = pos;
                    pos = _rank[pos].prev;
                }
                return old_pos;

            } else {
                while (pos != 0 && !_isPricedLtOrEq(id, pos)) {
                    pos = _rank[pos].next;
                }
                return pos;
            }
        }
    }

    function _isPricedLtOrEq(
        uint256 low, //lower priced offer's id
        uint256 high //higher priced offer's id
    ) internal view returns (bool) {

        return
            mul(offers[low].buy_amt, offers[high].pay_amt) >=
            mul(offers[high].buy_amt, offers[low].pay_amt);
    }


    function _matcho(
        uint256 t_pay_amt, //taker sell how much
        ERC20 t_pay_gem, //taker sell which token
        uint256 t_buy_amt, //taker buy how much
        ERC20 t_buy_gem, //taker buy which token
        uint256 pos, //position id
        bool rounding //match "close enough" orders?
    ) internal returns (uint256 id) {

        uint256 best_maker_id; //highest maker id
        uint256 t_buy_amt_old; //taker buy how much saved
        uint256 m_buy_amt; //maker offer wants to buy this much token
        uint256 m_pay_amt; //maker offer wants to sell this much token

        while (_best[address(t_buy_gem)][address(t_pay_gem)] > 0) {
            best_maker_id = _best[address(t_buy_gem)][address(t_pay_gem)];
            m_buy_amt = offers[best_maker_id].buy_amt;
            m_pay_amt = offers[best_maker_id].pay_amt;

            if (
                mul(m_buy_amt, t_buy_amt) >
                mul(t_pay_amt, m_pay_amt) +
                    (
                        rounding
                            ? m_buy_amt + t_buy_amt + t_pay_amt + m_pay_amt
                            : 0
                    )
            ) {
                break;
            }
            buy(best_maker_id, min(m_pay_amt, t_buy_amt));
            t_buy_amt_old = t_buy_amt;
            t_buy_amt = sub(t_buy_amt, min(m_pay_amt, t_buy_amt));
            t_pay_amt = mul(t_buy_amt, t_pay_amt) / t_buy_amt_old;

            if (t_pay_amt == 0 || t_buy_amt == 0) {
                break;
            }
        }

        if (
            t_buy_amt > 0 &&
            t_pay_amt > 0 &&
            t_pay_amt >= _dust[address(t_pay_gem)]
        ) {
            id = super.offer(t_pay_amt, t_pay_gem, t_buy_amt, t_buy_gem);
            _sort(id, pos);
        }
    }

    function _offeru(
        uint256 pay_amt, //maker (ask) sell how much
        ERC20 pay_gem, //maker (ask) sell which token
        uint256 buy_amt, //maker (ask) buy how much
        ERC20 buy_gem //maker (ask) buy which token
    ) internal returns (uint256 id) {

        require(_dust[address(pay_gem)] <= pay_amt);
        id = super.offer(pay_amt, pay_gem, buy_amt, buy_gem);
        _near[id] = _head;
        _head = id;
        emit LogUnsortedOffer(id);
    }

    function _sort(
        uint256 id, //maker (ask) id
        uint256 pos //position to insert into
    ) internal {

        require(isActive(id));

        ERC20 buy_gem = offers[id].buy_gem;
        ERC20 pay_gem = offers[id].pay_gem;
        uint256 prev_id; //maker (ask) id

        pos = pos == 0 ||
            offers[pos].pay_gem != pay_gem ||
            offers[pos].buy_gem != buy_gem ||
            !isOfferSorted(pos)
            ? _find(id)
            : _findpos(id, pos);

        if (pos != 0) {
            prev_id = _rank[pos].prev;
            _rank[pos].prev = id;
            _rank[id].next = pos;
        } else {
            prev_id = _best[address(pay_gem)][address(buy_gem)];
            _best[address(pay_gem)][address(buy_gem)] = id;
        }

        if (prev_id != 0) {
            _rank[prev_id].next = id;
            _rank[id].prev = prev_id;
        }

        _span[address(pay_gem)][address(buy_gem)]++;
        emit LogSortedOffer(id);
    }

    function _unsort(
        uint256 id //id of maker (ask) offer to remove from sorted list
    ) internal returns (bool) {

        address buy_gem = address(offers[id].buy_gem);
        address pay_gem = address(offers[id].pay_gem);
        require(_span[pay_gem][buy_gem] > 0);

        require(
            _rank[id].delb == 0 && //assert id is in the sorted list
                isOfferSorted(id)
        );

        if (id != _best[pay_gem][buy_gem]) {
            require(_rank[_rank[id].next].prev == id);
            _rank[_rank[id].next].prev = _rank[id].prev;
        } else {
            _best[pay_gem][buy_gem] = _rank[id].prev;
        }

        if (_rank[id].prev != 0) {
            require(_rank[_rank[id].prev].next == id);
            _rank[_rank[id].prev].next = _rank[id].next;
        }

        _span[pay_gem][buy_gem]--;
        _rank[id].delb = block.number; //mark _rank[id] for deletion
        return true;
    }

    function _hide(
        uint256 id //id of maker offer to remove from unsorted list
    ) internal returns (bool) {

        uint256 uid = _head; //id of an offer in unsorted offers list
        uint256 pre = uid; //id of previous offer in unsorted offers list

        require(!isOfferSorted(id)); //make sure offer id is not in sorted offers list

        if (_head == id) {
            _head = _near[id]; //set head to new first unsorted offer
            _near[id] = 0; //delete order from unsorted order list
            return true;
        }
        while (uid > 0 && uid != id) {
            pre = uid;
            uid = _near[uid];
        }
        if (uid != id) {
            return false;
        }
        _near[pre] = _near[id]; //set previous unsorted offer to point to offer after offer id
        _near[id] = 0; //delete order from unsorted order list
        return true;
    }

    function setFeeBPS(uint256 _newFeeBPS) external auth returns (bool) {

        feeBPS = _newFeeBPS;
        return true;
    }

    function setAqueductDistributionLive(bool live)
        external
        auth
        returns (bool)
    {

        AqueductDistributionLive = live;
        return true;
    }

    function setAqueductAddress(address _Aqueduct)
        external
        auth
        returns (bool)
    {

        AqueductAddress = _Aqueduct;
        return true;
    }

    function setFeeTo(address newFeeTo) external auth returns (bool) {

        feeTo = newFeeTo;
        return true;
    }
}

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;


    function approve(address guy, uint256 wad) external returns (bool);

}

interface IAqueduct {

    function distributeToMakerAndTaker(address maker, address taker)
        external
        returns (bool);

}