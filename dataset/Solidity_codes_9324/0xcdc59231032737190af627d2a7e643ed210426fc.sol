pragma solidity >=0.7.5;

interface IBlackDAOAuthority {


    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);


    function governor() external view returns (address);


    function guardian() external view returns (address);


    function policy() external view returns (address);


    function vault() external view returns (address);

}// AGPL-3.0-only
pragma solidity >=0.7.5;


abstract contract BlackDAOAccessControlled {

    event AuthorityUpdated(IBlackDAOAuthority indexed authority);

    string UNAUTHORIZED = "UNAUTHORIZED"; // save gas


    IBlackDAOAuthority public authority;


    constructor(IBlackDAOAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }


    modifier onlyGovernor() {
        require(msg.sender == authority.governor(), UNAUTHORIZED);
        _;
    }

    modifier onlyGuardian() {
        require(msg.sender == authority.guardian(), UNAUTHORIZED);
        _;
    }

    modifier onlyPolicy() {
        require(msg.sender == authority.policy(), UNAUTHORIZED);
        _;
    }

    modifier onlyVault() {
        require(msg.sender == authority.vault(), UNAUTHORIZED);
        _;
    }


    function setAuthority(IBlackDAOAuthority _newAuthority) external onlyGovernor {
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }
}// AGPL-3.0
pragma solidity >=0.7.5;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// AGPL-3.0-only
pragma solidity ^0.8.10;


abstract contract FrontEndRewarder is BlackDAOAccessControlled {

    uint256 public daoReward; // % reward for dao (3 decimals: 100 = 1%)
    uint256 public refReward; // % reward for referrer (3 decimals: 100 = 1%)
    mapping(address => uint256) public rewards; // front end operator rewards
    mapping(address => bool) public whitelisted; // whitelisted status for operators

    IERC20 internal immutable blkd; // reward token

    constructor(IBlackDAOAuthority _authority, IERC20 _blkd) BlackDAOAccessControlled(_authority) {
        blkd = _blkd;
    }


    function getReward() external {
        uint256 reward = rewards[msg.sender];

        rewards[msg.sender] = 0;
        blkd.transfer(msg.sender, reward);
    }


    function _giveRewards(uint256 _payout, address _referral) internal returns (uint256) {
        uint256 toDAO = (_payout * daoReward) / 1e4;
        uint256 toRef = (_payout * refReward) / 1e4;

        if (whitelisted[_referral]) {
            rewards[_referral] += toRef;
            rewards[authority.guardian()] += toDAO;
        } else {
            rewards[authority.guardian()] += toDAO + toRef;
        }
        return toDAO + toRef;
    }

    function setRewards(uint256 _toFrontEnd, uint256 _toDAO) external onlyGovernor {
        refReward = _toFrontEnd;
        daoReward = _toDAO;
    }

    function whitelist(address _operator) external onlyPolicy {
        whitelisted[_operator] = !whitelisted[_operator];
    }
}// AGPL-3.0
pragma solidity >=0.7.5;


interface IgBLKD is IERC20 {

    function mint(address _to, uint256 _amount) external;


    function burn(address _from, uint256 _amount) external;


    function index() external view returns (uint256);


    function balanceFrom(uint256 _amount) external view returns (uint256);


    function balanceTo(uint256 _amount) external view returns (uint256);


    function migrate(address _staking, address _sBLKD) external;

}// AGPL-3.0
pragma solidity >=0.7.5;

interface IStaking {

    function stake(
        address _to,
        uint256 _amount,
        bool _rebasing,
        bool _claim
    ) external returns (uint256);


    function claim(address _recipient, bool _rebasing) external returns (uint256);


    function forfeit() external returns (uint256);


    function toggleLock() external;


    function unstake(
        address _to,
        uint256 _amount,
        bool _trigger,
        bool _rebasing
    ) external returns (uint256);


    function wrap(address _to, uint256 _amount) external returns (uint256 gBalance_);


    function unwrap(address _to, uint256 _amount) external returns (uint256 sBalance_);


    function rebase() external;


    function index() external view returns (uint256);


    function contractBalance() external view returns (uint256);


    function totalStaked() external view returns (uint256);


    function supplyInWarmup() external view returns (uint256);

}// AGPL-3.0
pragma solidity >=0.7.5;

interface ITreasury {

    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (uint256);


    function withdraw(uint256 _amount, address _token) external;


    function tokenValue(address _token, uint256 _amount) external view returns (uint256 value_);


    function mint(address _recipient, uint256 _amount) external;


    function manage(address _token, uint256 _amount) external;


    function incurDebt(uint256 amount_, address token_) external;


    function repayDebtWithReserve(uint256 amount_, address token_) external;


    function excessReserves() external view returns (uint256);


    function baseSupply() external view returns (uint256);

}// AGPL-3.0-only
pragma solidity >=0.7.5;

interface INoteKeeper {

    struct Note {
        uint256 payout; // gBLKD remaining to be paid
        uint48 created; // time market was created
        uint48 matured; // timestamp when market is matured
        uint48 redeemed; // time market was redeemed
        uint48 marketID; // market ID of deposit. uint48 to avoid adding a slot.
    }

    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _sendgBLKD
    ) external returns (uint256);


    function redeemAll(address _user, bool _sendgBLKD) external returns (uint256);


    function pushNote(address to, uint256 index) external;


    function pullNote(address from, uint256 index) external returns (uint256 newIndex_);


    function indexesFor(address _user) external view returns (uint256[] memory);


    function pendingFor(address _user, uint256 _index) external view returns (uint256 payout_, bool matured_);

}// AGPL-3.0-only
pragma solidity ^0.8.10;



abstract contract NoteKeeper is INoteKeeper, FrontEndRewarder {
    mapping(address => Note[]) public notes; // user deposit data
    mapping(address => mapping(uint256 => address)) private noteTransfers; // change note ownership

    IgBLKD internal immutable gBLKD;
    IStaking internal immutable staking;
    ITreasury internal treasury;

    constructor(
        IBlackDAOAuthority _authority,
        IERC20 _blkd,
        IgBLKD _gblkd,
        IStaking _staking,
        ITreasury _treasury
    ) FrontEndRewarder(_authority, _blkd) {
        gBLKD = _gblkd;
        staking = _staking;
        treasury = _treasury;
    }

    function updateTreasury() external {
        require(
            msg.sender == authority.governor() ||
                msg.sender == authority.guardian() ||
                msg.sender == authority.policy(),
            "Only authorized"
        );
        treasury = ITreasury(authority.vault());
    }


    function addNote(
        address _user,
        uint256 _payout,
        uint48 _expiry,
        uint48 _marketID,
        address _referral
    ) internal returns (uint256 index_) {
        index_ = notes[_user].length;

        notes[_user].push(
            Note({
                payout: gBLKD.balanceTo(_payout),
                created: uint48(block.timestamp),
                matured: _expiry,
                redeemed: 0,
                marketID: _marketID
            })
        );

        uint256 rewards = _giveRewards(_payout, _referral);

        treasury.mint(address(this), _payout + rewards);

        staking.stake(address(this), _payout, false, true);
    }


    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _sendgBLKD
    ) public override returns (uint256 payout_) {
        uint48 time = uint48(block.timestamp);

        for (uint256 i = 0; i < _indexes.length; i++) {
            (uint256 pay, bool matured) = pendingFor(_user, _indexes[i]);

            if (matured) {
                notes[_user][_indexes[i]].redeemed = time; // mark as redeemed
                payout_ += pay;
            }
        }

        if (_sendgBLKD) {
            gBLKD.transfer(_user, payout_); // send payout as gBLKD
        } else {
            staking.unwrap(_user, payout_); // unwrap and send payout as sBLKD
        }
    }

    function redeemAll(address _user, bool _sendgBLKD) external override returns (uint256) {
        return redeem(_user, indexesFor(_user), _sendgBLKD);
    }


    function pushNote(address _to, uint256 _index) external override {
        require(notes[msg.sender][_index].created != 0, "Depository: note not found");
        noteTransfers[msg.sender][_index] = _to;
    }

    function pullNote(address _from, uint256 _index) external override returns (uint256 newIndex_) {
        require(noteTransfers[_from][_index] == msg.sender, "Depository: transfer not found");
        require(notes[_from][_index].redeemed == 0, "Depository: note redeemed");

        newIndex_ = notes[msg.sender].length;
        notes[msg.sender].push(notes[_from][_index]);

        delete notes[_from][_index];
    }



    function indexesFor(address _user) public view override returns (uint256[] memory) {
        Note[] memory info = notes[_user];

        uint256 length;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].redeemed == 0 && info[i].payout != 0) length++;
        }

        uint256[] memory indexes = new uint256[](length);
        uint256 position;

        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].redeemed == 0 && info[i].payout != 0) {
                indexes[position] = i;
                position++;
            }
        }

        return indexes;
    }

    function pendingFor(address _user, uint256 _index) public view override returns (uint256 payout_, bool matured_) {
        Note memory note = notes[_user][_index];

        payout_ = note.payout;
        matured_ = note.redeemed == 0 && note.matured <= block.timestamp && note.payout != 0;
    }
}// AGPL-3.0-only
pragma solidity >=0.7.5;


library SafeERC20 {

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 amount) internal {

        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}// AGPL-3.0
pragma solidity >=0.7.5;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// AGPL-3.0
pragma solidity >=0.7.5;


interface IBondDepository {

    struct Market {
        uint256 capacity; // capacity remaining
        IERC20 quoteToken; // token to accept as payment
        bool capacityInQuote; // capacity limit is in payment token (true) or in BLKD (false, default)
        uint64 totalDebt; // total debt from market
        uint64 maxPayout; // max tokens in/out (determined by capacityInQuote false/true, respectively)
        uint64 sold; // base tokens out
        uint256 purchased; // quote tokens in
    }

    struct Terms {
        bool fixedTerm; // fixed term or fixed expiration
        uint64 controlVariable; // scaling variable for price
        uint48 vesting; // length of time from deposit to maturity if fixed-term
        uint48 conclusion; // timestamp when market no longer offered (doubles as time when market matures if fixed-expiry)
        uint64 maxDebt; // 9 decimal debt maximum in BLKD
    }

    struct Metadata {
        uint48 lastTune; // last timestamp when control variable was tuned
        uint48 lastDecay; // last timestamp when market was created and debt was decayed
        uint48 length; // time from creation to conclusion. used as speed to decay debt.
        uint48 depositInterval; // target frequency of deposits
        uint48 tuneInterval; // frequency of tuning
        uint8 quoteDecimals; // decimals of quote token
    }

    struct Adjustment {
        uint64 change;
        uint48 lastAdjustment;
        uint48 timeToAdjusted;
        bool active;
    }

    function deposit(
        uint256 _bid,
        uint256 _amount,
        uint256 _maxPrice,
        address _user,
        address _referral
    )
        external
        returns (
            uint256 payout_,
            uint256 expiry_,
            uint256 index_
        );


    function create(
        IERC20 _quoteToken, // token used to deposit
        uint256[3] memory _market, // [capacity, initial price]
        bool[2] memory _booleans, // [capacity in quote, fixed term]
        uint256[2] memory _terms, // [vesting, conclusion]
        uint32[2] memory _intervals // [deposit interval, tune interval]
    ) external returns (uint256 id_);


    function close(uint256 _id) external;


    function isLive(uint256 _bid) external view returns (bool);


    function liveMarkets() external view returns (uint256[] memory);


    function liveMarketsFor(address _quoteToken) external view returns (uint256[] memory);


    function payoutFor(uint256 _amount, uint256 _bid) external view returns (uint256);


    function marketPrice(uint256 _bid) external view returns (uint256);


    function currentDebt(uint256 _bid) external view returns (uint256);


    function debtRatio(uint256 _bid) external view returns (uint256);


    function debtDecay(uint256 _bid) external view returns (uint64);

}// AGPL-3.0-or-later
pragma solidity ^0.8.10;





contract BlackDAOBondDepositoryV2 is IBondDepository, NoteKeeper {


    using SafeERC20 for IERC20;


    event CreateMarket(uint256 indexed id, address indexed baseToken, address indexed quoteToken, uint256 initialPrice);
    event CloseMarket(uint256 indexed id);
    event Bond(uint256 indexed id, uint256 amount, uint256 price);
    event Tuned(uint256 indexed id, uint64 oldControlVariable, uint64 newControlVariable);


    Market[] public markets; // persistent market data
    Terms[] public terms; // deposit construction data
    Metadata[] public metadata; // extraneous market data
    mapping(uint256 => Adjustment) public adjustments; // control variable changes

    mapping(address => uint256[]) public marketsForQuote; // market IDs for quote token


    constructor(
        IBlackDAOAuthority _authority,
        IERC20 _blkd,
        IgBLKD _gblkd,
        IStaking _staking,
        ITreasury _treasury
    ) NoteKeeper(_authority, _blkd, _gblkd, _staking, _treasury) {
        _blkd.approve(address(_staking), 1e45);
    }


    function deposit(
        uint256 _id,
        uint256 _amount,
        uint256 _maxPrice,
        address _user,
        address _referral
    )
        external
        override
        returns (
            uint256 payout_,
            uint256 expiry_,
            uint256 index_
        )
    {

        Market storage market = markets[_id];
        Terms memory term = terms[_id];
        uint48 currentTime = uint48(block.timestamp);

        require(currentTime < term.conclusion, "Depository: market concluded");

        _decay(_id, currentTime);

        uint256 price = _marketPrice(_id);
        require(price <= _maxPrice, "Depository: more than max price");

        payout_ = ((_amount * 1e18) / price) / (10**metadata[_id].quoteDecimals);

        require(payout_ <= market.maxPayout, "Depository: max size exceeded");

        market.capacity -= market.capacityInQuote ? _amount : payout_;

        expiry_ = term.fixedTerm ? term.vesting + currentTime : term.vesting;

        market.purchased += _amount;
        market.sold += uint64(payout_);

        market.totalDebt += uint64(payout_);

        emit Bond(_id, _amount, price);

        index_ = addNote(_user, payout_, uint48(expiry_), uint48(_id), _referral);

        market.quoteToken.safeTransferFrom(msg.sender, address(treasury), _amount);

        if (term.maxDebt < market.totalDebt) {
            market.capacity = 0;
            emit CloseMarket(_id);
        } else {
            _tune(_id, currentTime);
        }
    }

    function _decay(uint256 _id, uint48 _time) internal {


        markets[_id].totalDebt -= debtDecay(_id);
        metadata[_id].lastDecay = _time;


        if (adjustments[_id].active) {
            Adjustment storage adjustment = adjustments[_id];

            (uint64 adjustBy, uint48 secondsSince, bool stillActive) = _controlDecay(_id);
            terms[_id].controlVariable -= adjustBy;

            if (stillActive) {
                adjustment.change -= adjustBy;
                adjustment.timeToAdjusted -= secondsSince;
                adjustment.lastAdjustment = _time;
            } else {
                adjustment.active = false;
            }
        }
    }

    function _tune(uint256 _id, uint48 _time) internal {

        Metadata memory meta = metadata[_id];

        if (_time >= meta.lastTune + meta.tuneInterval) {
            Market memory market = markets[_id];

            uint256 timeRemaining = terms[_id].conclusion - _time;
            uint256 price = _marketPrice(_id);

            uint256 capacity = market.capacityInQuote
                ? ((market.capacity * 1e18) / price) / (10**meta.quoteDecimals)
                : market.capacity;

            markets[_id].maxPayout = uint64((capacity * meta.depositInterval) / timeRemaining);

            uint256 targetDebt = (capacity * meta.length) / timeRemaining;

            uint64 newControlVariable = uint64((price * treasury.baseSupply()) / targetDebt);

            emit Tuned(_id, terms[_id].controlVariable, newControlVariable);

            if (newControlVariable >= terms[_id].controlVariable) {
                terms[_id].controlVariable = newControlVariable;
            } else {
                uint64 change = terms[_id].controlVariable - newControlVariable;
                adjustments[_id] = Adjustment(change, _time, meta.tuneInterval, true);
            }
            metadata[_id].lastTune = _time;
        }
    }


    function create(
        IERC20 _quoteToken,
        uint256[3] memory _market,
        bool[2] memory _booleans,
        uint256[2] memory _terms,
        uint32[2] memory _intervals
    ) external override onlyPolicy returns (uint256 id_) {

        uint256 secondsToConclusion = _terms[1] - block.timestamp;

        uint256 decimals = IERC20Metadata(address(_quoteToken)).decimals();

        uint64 targetDebt = uint64(_booleans[0] ? ((_market[0] * 1e18) / _market[1]) / 10**decimals : _market[0]);

        uint64 maxPayout = uint64((targetDebt * _intervals[0]) / secondsToConclusion);

        uint256 maxDebt = targetDebt + ((targetDebt * _market[2]) / 1e5); // 1e5 = 100,000. 10,000 / 100,000 = 10%.

        uint256 controlVariable = (_market[1] * treasury.baseSupply()) / targetDebt;

        id_ = markets.length;

        markets.push(
            Market({
                quoteToken: _quoteToken,
                capacityInQuote: _booleans[0],
                capacity: _market[0],
                totalDebt: targetDebt,
                maxPayout: maxPayout,
                purchased: 0,
                sold: 0
            })
        );

        terms.push(
            Terms({
                fixedTerm: _booleans[1],
                controlVariable: uint64(controlVariable),
                vesting: uint48(_terms[0]),
                conclusion: uint48(_terms[1]),
                maxDebt: uint64(maxDebt)
            })
        );

        metadata.push(
            Metadata({
                lastTune: uint48(block.timestamp),
                lastDecay: uint48(block.timestamp),
                length: uint48(secondsToConclusion),
                depositInterval: _intervals[0],
                tuneInterval: _intervals[1],
                quoteDecimals: uint8(decimals)
            })
        );

        marketsForQuote[address(_quoteToken)].push(id_);

        emit CreateMarket(id_, address(blkd), address(_quoteToken), _market[1]);
    }

    function close(uint256 _id) external override onlyPolicy {

        terms[_id].conclusion = uint48(block.timestamp);
        markets[_id].capacity = 0;
        emit CloseMarket(_id);
    }


    function marketPrice(uint256 _id) public view override returns (uint256) {

        return (currentControlVariable(_id) * debtRatio(_id)) / (10**metadata[_id].quoteDecimals);
    }

    function payoutFor(uint256 _amount, uint256 _id) external view override returns (uint256) {

        Metadata memory meta = metadata[_id];
        return (_amount * 1e18) / marketPrice(_id) / 10**meta.quoteDecimals;
    }

    function debtRatio(uint256 _id) public view override returns (uint256) {

        return (currentDebt(_id) * (10**metadata[_id].quoteDecimals)) / treasury.baseSupply();
    }

    function currentDebt(uint256 _id) public view override returns (uint256) {

        return markets[_id].totalDebt - debtDecay(_id);
    }

    function debtDecay(uint256 _id) public view override returns (uint64) {

        Metadata memory meta = metadata[_id];

        uint256 secondsSince = block.timestamp - meta.lastDecay;

        return uint64((markets[_id].totalDebt * secondsSince) / meta.length);
    }

    function currentControlVariable(uint256 _id) public view returns (uint256) {

        (uint64 decay, , ) = _controlDecay(_id);
        return terms[_id].controlVariable - decay;
    }

    function isLive(uint256 _id) public view override returns (bool) {

        return (markets[_id].capacity != 0 && terms[_id].conclusion > block.timestamp);
    }

    function liveMarkets() external view override returns (uint256[] memory) {

        uint256 num;
        for (uint256 i = 0; i < markets.length; i++) {
            if (isLive(i)) num++;
        }

        uint256[] memory ids = new uint256[](num);
        uint256 nonce;
        for (uint256 i = 0; i < markets.length; i++) {
            if (isLive(i)) {
                ids[nonce] = i;
                nonce++;
            }
        }
        return ids;
    }

    function liveMarketsFor(address _token) external view override returns (uint256[] memory) {

        uint256[] memory mkts = marketsForQuote[_token];
        uint256 num;

        for (uint256 i = 0; i < mkts.length; i++) {
            if (isLive(mkts[i])) num++;
        }

        uint256[] memory ids = new uint256[](num);
        uint256 nonce;

        for (uint256 i = 0; i < mkts.length; i++) {
            if (isLive(mkts[i])) {
                ids[nonce] = mkts[i];
                nonce++;
            }
        }
        return ids;
    }


    function _marketPrice(uint256 _id) internal view returns (uint256) {

        return (terms[_id].controlVariable * _debtRatio(_id)) / (10**metadata[_id].quoteDecimals);
    }

    function _debtRatio(uint256 _id) internal view returns (uint256) {

        return (markets[_id].totalDebt * (10**metadata[_id].quoteDecimals)) / treasury.baseSupply();
    }

    function _controlDecay(uint256 _id)
        internal
        view
        returns (
            uint64 decay_,
            uint48 secondsSince_,
            bool active_
        )
    {

        Adjustment memory info = adjustments[_id];
        if (!info.active) return (0, 0, false);

        secondsSince_ = uint48(block.timestamp) - info.lastAdjustment;

        active_ = secondsSince_ < info.timeToAdjusted;
        decay_ = active_ ? (info.change * secondsSince_) / info.timeToAdjusted : info.change;
    }
}