
pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity 0.8.10;


contract InsureDAOERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    bool tokenInitialized;
    string private _name = "InsureDAO LP Token";
    string private _symbol = "iLP";
    uint8 private _decimals = 18;

    function initializeToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) internal {

        require(!tokenInitialized, "Token is already initialized");
        tokenInitialized = true;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() external view virtual override returns (string memory) {

        return _name;
    }

    function symbol() external view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {

        if (amount != 0) {
            uint256 currentAllowance = _allowances[sender][msg.sender];
            if (currentAllowance != type(uint256).max) {
                require(
                    currentAllowance >= amount,
                    "Transfer amount > allowance"
                );
                unchecked {
                    _approve(sender, msg.sender, currentAllowance - amount);
                }
            }
            
            _transfer(sender, recipient, amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {

        if (addedValue != 0) {
            _approve(
                msg.sender,
                spender,
                _allowances[msg.sender][spender] + addedValue
            );
        }
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {

        if (subtractedValue != 0) {
            uint256 currentAllowance = _allowances[msg.sender][spender];
            require(
                currentAllowance >= subtractedValue,
                "Decreased allowance below zero"
            );

            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        if (amount != 0) {
            require(sender != address(0), "Transfer from the zero address");
            require(recipient != address(0), "Transfer to the zero address");

            _beforeTokenTransfer(sender, recipient, amount);

            uint256 senderBalance = _balances[sender];
            require(
                senderBalance >= amount,
                "Transfer amount exceeds balance"
            );

            unchecked {
                _balances[sender] = senderBalance - amount;
            }

            _balances[recipient] += amount;

            emit Transfer(sender, recipient, amount);

            _afterTokenTransfer(sender, recipient, amount);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {

        if (amount != 0) {
            require(account != address(0), "Mint to the zero address");

            _beforeTokenTransfer(address(0), account, amount);

            _totalSupply += amount;
            _balances[account] += amount;
            emit Transfer(address(0), account, amount);

            _afterTokenTransfer(address(0), account, amount);
        }
    }

    function _burn(address account, uint256 amount) internal virtual {

        if (amount != 0) {
            require(account != address(0), "Burn from the zero address");

            _beforeTokenTransfer(account, address(0), amount);

            uint256 accountBalance = _balances[account];
            require(accountBalance >= amount, "Burn amount exceeds balance");
            unchecked {
                _balances[account] = accountBalance - amount;
            }

            _totalSupply -= amount;

            emit Transfer(account, address(0), amount);

            _afterTokenTransfer(account, address(0), amount);
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}pragma solidity 0.8.10;

abstract contract IPoolTemplate {

    enum MarketStatus {
        Trading,
        Payingout
    }
    function registerIndex(uint256 _index)external virtual;
    function allocateCredit(uint256 _credit)
        external
        virtual
        returns (uint256 _mintAmount);

    function pairValues(address _index)
        external
        view
        virtual
        returns (uint256, uint256);

    function withdrawCredit(uint256 _credit)
        external
        virtual
        returns (uint256 _retVal);

    function marketStatus() external view virtual returns(MarketStatus);
    function availableBalance() external view virtual returns (uint256 _balance);

    function utilizationRate() external view virtual returns (uint256 _rate);
    function totalLiquidity() public view virtual returns (uint256 _balance);
    function totalCredit() external view virtual returns (uint256);
    function lockedAmount() external view virtual returns (uint256);

    function valueOfUnderlying(address _owner)
        external
        view
        virtual
        returns (uint256);

    function pendingPremium(address _index)
        external
        view
        virtual
        returns (uint256);

    function paused() external view virtual returns (bool);

    function applyCover(
        uint256 _pending,
        uint256 _payoutNumerator,
        uint256 _payoutDenominator,
        uint256 _incidentTimestamp,
        bytes32 _merkleRoot,
        string calldata _rawdata,
        string calldata _memo
    ) external virtual;

    function applyBounty(
        uint256 _amount,
        address _contributor,
        uint256[] calldata _ids
    )external virtual;
}pragma solidity 0.8.10;

interface IUniversalMarket {
    function initialize(
        address _depositor,
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external;

    function setPaused(bool state) external;
    function changeMetadata(string calldata _metadata) external;
}pragma solidity 0.8.10;

abstract contract IParameters {
    function setVault(address _token, address _vault) external virtual;

    function setLockup(address _address, uint256 _target) external virtual;

    function setGrace(address _address, uint256 _target) external virtual;

    function setMinDate(address _address, uint256 _target) external virtual;

    function setUpperSlack(address _address, uint256 _target) external virtual;

    function setLowerSlack(address _address, uint256 _target) external virtual;

    function setWithdrawable(address _address, uint256 _target)
        external
        virtual;

    function setPremiumModel(address _address, address _target)
        external
        virtual;

    function setFeeRate(address _address, uint256 _target) external virtual;

    function setMaxList(address _address, uint256 _target) external virtual;

    function setCondition(bytes32 _reference, bytes32 _target) external virtual;

    function getOwner() external view virtual returns (address);

    function getVault(address _token) external view virtual returns (address);

    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount,
        address _target
    ) external view virtual returns (uint256);

    function getFeeRate(address _target) external view virtual returns (uint256);

    function getUpperSlack(address _target)
        external
        view
        virtual
        returns (uint256);

    function getLowerSlack(address _target)
        external
        view
        virtual
        returns (uint256);

    function getLockup(address _target) external view virtual returns (uint256);

    function getWithdrawable(address _target)
        external
        view
        virtual
        returns (uint256);

    function getGrace(address _target) external view virtual returns (uint256);

    function getMinDate(address _target) external view virtual returns (uint256);

    function getMaxList(address _target)
        external
        view
        virtual
        returns (uint256);

    function getCondition(bytes32 _reference)
        external
        view
        virtual
        returns (bytes32);
}pragma solidity 0.8.10;

interface IVault {
    function addValueBatch(
        uint256 _amount,
        address _from,
        address[2] memory _beneficiaries,
        uint256[2] memory _shares
    ) external returns (uint256[2] memory _allocations);

    function addValue(
        uint256 _amount,
        address _from,
        address _attribution
    ) external returns (uint256 _attributions);

    function withdrawValue(uint256 _amount, address _to)
        external
        returns (uint256 _attributions);

    function transferValue(uint256 _amount, address _destination)
        external
        returns (uint256 _attributions);

    function withdrawAttribution(uint256 _attribution, address _to)
        external
        returns (uint256 _retVal);

    function withdrawAllAttribution(address _to)
        external
        returns (uint256 _retVal);

    function transferAttribution(uint256 _amount, address _destination)
        external;

    function attributionOf(address _target) external view returns (uint256);

    function underlyingValue(address _target) external view returns (uint256);

    function attributionValue(uint256 _attribution)
        external
        view
        returns (uint256);

    function utilize() external returns (uint256 _amount);
    function valueAll() external view returns (uint256);


    function token() external returns (address);

    function borrowValue(uint256 _amount, address _to) external;


    function offsetDebt(uint256 _amount, address _target)
        external
        returns (uint256 _attributions);

    function repayDebt(uint256 _amount, address _target) external;

    function debts(address _debtor) external view returns (uint256);

    function transferDebt(uint256 _amount) external;

    function withdrawRedundant(address _token, address _to) external;

    function setController(address _controller) external;

    function setKeeper(address _keeper) external;
}pragma solidity 0.8.10;

interface IRegistry {
    function isListed(address _market) external view returns (bool);

    function getCDS(address _address) external view returns (address);

    function confirmExistence(address _template, address _target)
        external
        view
        returns (bool);

    function setFactory(address _factory) external;

    function supportMarket(address _market) external;

    function setExistence(address _template, address _target) external;

    function setCDS(address _address, address _cds) external;
}pragma solidity 0.8.10;

interface IIndexTemplate {
    function compensate(uint256) external returns (uint256 _compensated);

    function lock() external;

    function resume() external;

    function adjustAlloc() external;

    function setLeverage(uint256 _target) external;
    function set(
        uint256 _indexA,
        uint256 _indexB,
        address _pool,
        uint256 _allocPoint
    ) external;
}pragma solidity 0.8.10;




contract PoolTemplate is InsureDAOERC20, IPoolTemplate, IUniversalMarket {
    event Deposit(address indexed depositor, uint256 amount, uint256 mint);
    event WithdrawRequested(
        address indexed withdrawer,
        uint256 amount,
        uint256 unlockTime
    );
    event Withdraw(address indexed withdrawer, uint256 amount, uint256 retVal);
    event Unlocked(uint256 indexed id, uint256 amount);
    event Insured(
        uint256 indexed id,
        uint256 amount,
        bytes32 target,
        uint256 startTime,
        uint256 endTime,
        address insured,
        address agent,
        uint256 premium
    );
    event Redeemed(
        uint256 indexed id,
        address insured,
        bytes32 target,
        uint256 amount,
        uint256 payout
    );
    event CoverApplied(
        uint256 pending,
        uint256 payoutNumerator,
        uint256 payoutDenominator,
        uint256 incidentTimestamp,
        bytes32 merkleRoot,
        string rawdata,
        string memo
    );
    event BountyPaid(uint256 amount, address contributor, uint256[] ids);

    event CreditIncrease(address indexed depositor, uint256 credit);
    event CreditDecrease(address indexed withdrawer, uint256 credit);
    event MarketStatusChanged(MarketStatus statusValue);
    event Paused(bool paused);
    event MetadataChanged(string metadata);

    bool public initialized;
    bool public override paused;
    string public metadata;

    IParameters public parameters;
    IRegistry public registry;
    IVault public vault;

    uint256 public attributionDebt; //pool's attribution for indices
    uint256 public override lockedAmount; //Liquidity locked when utilized
    uint256 public override totalCredit; //Liquidity from index
    uint256 public rewardPerCredit; //Times MAGIC_SCALE_1E6. To avoid reward decimal truncation *See explanation below.
    uint256 public pendingEnd; //pending time when paying out

    struct IndexInfo {
        uint256 credit; //How many credit (equal to liquidity) the index has allocated
        uint256 rewardDebt; // Reward debt. *See explanation below.
        uint256 index; //index number
        bool exist; //true if the index has allocated credit
    }

    mapping(address => IndexInfo) public indices;
    address[] public indexList;


    MarketStatus public override marketStatus;

    struct Withdrawal {
        uint256 timestamp;
        uint256 amount;
    }
    mapping(address => Withdrawal) public withdrawalReq;

    struct Insurance {
        uint256 id; //each insuance has their own id
        uint48 startTime; //timestamp of starttime
        uint48 endTime; //timestamp of endtime
        uint256 amount; //insured amount
        bytes32 target; //target id in bytes32
        address insured; //the address holds the right to get insured
        address agent; //address have control. can be different from insured.
        bool status; //true if insurance is not expired or redeemed
    }
    mapping(uint256 => Insurance) public insurances;
    uint256 public allInsuranceCount;

    struct Incident {
        uint256 payoutNumerator;
        uint256 payoutDenominator;
        uint256 incidentTimestamp;
        bytes32 merkleRoot;
    }
    Incident public incident;
    uint256 private constant MAGIC_SCALE_1E6 = 1e6; //internal multiplication scale 1e6 to reduce decimal truncation

    modifier onlyOwner() {
        require(
            msg.sender == parameters.getOwner(),
            "Caller is not allowed to operate"
        );
        _;
    }

    constructor() {
        initialized = true;
    }


    function initialize(
        address _depositor,
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external override {
        require(
            !initialized &&
                bytes(_metaData).length != 0 &&
                _references[0] != address(0) &&
                _references[1] != address(0) &&
                _references[2] != address(0) &&
                _references[3] != address(0) &&
                _conditions[0] <= _conditions[1],
            "INITIALIZATION_BAD_CONDITIONS"
        );
        initialized = true;

        string memory _name = "InsureDAO Insurance LP";
        string memory _symbol = "iNsure";
        
        try this.getTokenMetadata(_references[0]) returns (string memory name_, string memory symbol_) {
            _name = name_;
            _symbol = symbol_;
        } catch {}

        uint8 _decimals = IERC20Metadata(_references[1]).decimals();

        initializeToken(_name, _symbol, _decimals);

        registry = IRegistry(_references[2]);
        parameters = IParameters(_references[3]);
        vault = IVault(parameters.getVault(_references[1]));

        metadata = _metaData;

        marketStatus = MarketStatus.Trading;

        if (_conditions[1] != 0) {
            _depositFrom(_conditions[1], _depositor);
        }
    }

    function getTokenMetadata(address _token) external view returns (string memory _name, string memory _symbol) {
        _name = string(abi.encodePacked("InsureDAO ", IERC20Metadata(_token).name(), " Insurance LP"));
        _symbol = string(abi.encodePacked("i", IERC20Metadata(_token).symbol()));
    }


    function deposit(uint256 _amount) external returns (uint256 _mintAmount) {
        _mintAmount = _depositFrom(_amount, msg.sender);
    }

    function _depositFrom(uint256 _amount, address _from)
        internal
        returns (uint256 _mintAmount)
    {
        require(_amount != 0, "ERROR: DEPOSIT_ZERO");
        require(
            marketStatus == MarketStatus.Trading,
            "ERROR: DEPOSIT_DISABLED(1)"
        );
        require(
            !paused,
            "ERROR: DEPOSIT_DISABLED(2)"
        );

        _mintAmount = worth(_amount);

        vault.addValue(_amount, _from, address(this));

        emit Deposit(_from, _amount, _mintAmount);

        _mint(_from, _mintAmount);
    }

    function requestWithdraw(uint256 _amount) external {
        require(_amount != 0, "ERROR: REQUEST_ZERO");
        require(balanceOf(msg.sender) >= _amount, "ERROR: REQUEST_EXCEED_BALANCE");
        
        uint256 _unlocksAt = block.timestamp + parameters.getLockup(address(this));

        withdrawalReq[msg.sender].timestamp = _unlocksAt;
        withdrawalReq[msg.sender].amount = _amount;
        emit WithdrawRequested(msg.sender, _amount, _unlocksAt);
    }

    function withdraw(uint256 _amount) external returns (uint256 _retVal) {
        require(
            marketStatus == MarketStatus.Trading,
            "ERROR: WITHDRAWAL_MARKET_PENDING"
        );

        Withdrawal memory request = withdrawalReq[msg.sender];

        require(
            request.timestamp < block.timestamp,
            "ERROR: WITHDRAWAL_QUEUE"
        );
        require(
            request.timestamp + parameters.getWithdrawable(address(this)) > block.timestamp,
            "WITHDRAWAL_NO_ACTIVE_REQUEST"
        );
        require(
            request.amount >= _amount,
            "WITHDRAWAL_EXCEEDED_REQUEST"
        );
        require(_amount != 0, "ERROR: WITHDRAWAL_ZERO");

        uint256 _supply = totalSupply();
        require(_supply != 0, "ERROR: NO_AVAILABLE_LIQUIDITY");

        uint256 _liquidity = originalLiquidity();
        _retVal = (_amount * _liquidity) / _supply;

        require(
            _retVal <= _availableBalance(),
            "WITHDRAW_INSUFFICIENT_LIQUIDITY"
        );

        unchecked {
            withdrawalReq[msg.sender].amount -= _amount;
        }

        _burn(msg.sender, _amount);

        vault.withdrawValue(_retVal, msg.sender);

        emit Withdraw(msg.sender, _amount, _retVal);
    }

    function unlockBatch(uint256[] calldata _ids) external {
        require(marketStatus == MarketStatus.Trading, "ERROR: UNLOCK_BAD_COINDITIONS");
        uint256 idsLength = _ids.length;
        for (uint256 i; i < idsLength;) {
            _unlock(_ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    function unlock(uint256 _id) external {
        require(marketStatus == MarketStatus.Trading, "ERROR: UNLOCK_BAD_COINDITIONS");
        _unlock(_id);
    }

    function _unlock(uint256 _id) internal {
        require(
            insurances[_id].status &&
                insurances[_id].endTime + parameters.getGrace(address(this)) <
                block.timestamp,
            "ERROR: UNLOCK_BAD_COINDITIONS"
        );
        insurances[_id].status = false;

        lockedAmount = lockedAmount - insurances[_id].amount;

        emit Unlocked(_id, insurances[_id].amount);
    }



    function registerIndex(uint256 _index)external override{
        require(
            IRegistry(registry).isListed(msg.sender),
            "ERROR: UNREGISTERED_INDEX"
        );
        require(
            _index <= parameters.getMaxList(address(this)),
            "ERROR: EXCEEEDED_MAX_LIST"
        );
        uint256 _length = indexList.length;
        if (_length <= _index) {
            require(_length == _index, "ERROR: BAD_INDEX");
            indexList.push(msg.sender);
            indices[msg.sender].exist = true;
            indices[msg.sender].index = _index;
        } else {
            address _indexAddress = indexList[_index];
            if (_indexAddress != address(0) && _indexAddress != msg.sender) {
                require(indices[msg.sender].credit == 0,"ERROR: ALREADY_ALLOCATED");
                require(indices[_indexAddress].credit == 0,"ERROR: WITHDRAW_CREDIT_FIRST");

                indices[_indexAddress].index = 0;
                indices[_indexAddress].exist = false;
                indices[msg.sender].index = _index;
                indices[msg.sender].exist = true;
                indexList[_index] = msg.sender;
            }
        }
    }


    function allocateCredit(uint256 _credit)
        external
        override
        returns (uint256 _pending)
    {
        IndexInfo storage _index = indices[msg.sender];
        require(
            _index.exist,
            "ALLOCATE_CREDIT_BAD_CONDITIONS"
        );

        uint256 _rewardPerCredit = rewardPerCredit;

        if (_index.credit != 0){
            _pending = _sub(
                (_index.credit * _rewardPerCredit) / MAGIC_SCALE_1E6,
                _index.rewardDebt
            );
            if (_pending != 0) {
                vault.transferAttribution(_pending, msg.sender);
                attributionDebt -= _pending;
            }
        }
        if (_credit != 0) {
            totalCredit += _credit;
            _index.credit += _credit;
            emit CreditIncrease(msg.sender, _credit);
        }
        _index.rewardDebt =
            (_index.credit * _rewardPerCredit) /
            MAGIC_SCALE_1E6;
    }

    function withdrawCredit(uint256 _credit)
        external
        override
        returns (uint256 _pending)
    {
        require(
            marketStatus == MarketStatus.Trading,
            "POOL_IS_IN_TRADING_STATUS"
        );

        IndexInfo storage _index = indices[msg.sender];

        require(
            _index.exist &&
            _index.credit >= _credit &&
            _credit <= _availableBalance(),
            "WITHDRAW_CREDIT_BAD_CONDITIONS"
        );

        uint256 _rewardPerCredit = rewardPerCredit;

        _pending = _sub(
            (_index.credit * _rewardPerCredit) / MAGIC_SCALE_1E6,
            _index.rewardDebt
        );

        if (_credit != 0) {
            totalCredit -= _credit;
            unchecked {
                _index.credit -= _credit;
            }
            emit CreditDecrease(msg.sender, _credit);
        }

        if (_pending != 0) {
            vault.transferAttribution(_pending, msg.sender);
            attributionDebt -= _pending;
        }
        
        _index.rewardDebt =
                (_index.credit * _rewardPerCredit) /
                MAGIC_SCALE_1E6;
    }


    function insure(
        uint256 _amount,
        uint256 _maxCost,
        uint256 _span,
        bytes32 _target,
        address _for,
        address _agent
    ) external returns (uint256) {
        require(!paused, "ERROR: INSURE_MARKET_PAUSED");
        require(_for != address(0), "ERROR: ZERO_ADDRESS");
        require(_agent != address(0), "ERROR: ZERO_ADDRESS");
        require(
            marketStatus == MarketStatus.Trading,
            "ERROR: INSURE_MARKET_PENDING"
        );
        require(
            _amount <= _availableBalance(),
            "INSURE_EXCEEDED_AVAIL_BALANCE"
        );

        require(_span <= 365 days, "ERROR: INSURE_EXCEEDED_MAX_SPAN");
        require(
            parameters.getMinDate(address(this)) <= _span,
            "ERROR: INSURE_SPAN_BELOW_MIN"
        );

        uint256 _premium = getPremium(_amount, _span);
        require(_premium <= _maxCost, "ERROR: INSURE_EXCEEDED_MAX_COST");
        
        uint256 _endTime = _span + block.timestamp;
        uint256 _fee = parameters.getFeeRate(address(this));
        
        uint256 _liquidity = totalLiquidity();
        uint256 _totalCredit = totalCredit;

        uint256[2] memory _newAttribution = vault.addValueBatch(
            _premium,
            msg.sender,
            [address(this), parameters.getOwner()],
            [MAGIC_SCALE_1E6 - _fee, _fee]
        );

        uint256 _id = allInsuranceCount;
        lockedAmount += _amount;
        insurances[_id] = Insurance(
            _id,
            (uint48)(block.timestamp),
            (uint48)(_endTime),
            _amount,
            _target,
            _for,
            _agent,
            true
        );
        
        unchecked {
            ++allInsuranceCount;
        }

        if (_totalCredit != 0 && _liquidity != 0) {
            uint256 _attributionForIndex = (_newAttribution[0] * _totalCredit) / _liquidity;
            attributionDebt += _attributionForIndex;
            rewardPerCredit += ((_attributionForIndex * MAGIC_SCALE_1E6) /
                _totalCredit);
        }

        emit Insured(
            _id,
            _amount,
            _target,
            block.timestamp,
            _endTime,
            _for,
            _agent,
            _premium
        );

        return _id;
    }

    function redeem(uint256 _id, uint256 _loss, bytes32[] calldata _merkleProof) external {
        require(
            marketStatus == MarketStatus.Payingout,
            "ERROR: NO_APPLICABLE_INCIDENT"
        );
        
        Insurance memory _insurance = insurances[_id];
        require(_insurance.status, "ERROR: INSURANCE_NOT_ACTIVE");
        require(_insurance.insured == msg.sender || _insurance.agent == msg.sender, "ERROR: NOT_YOUR_INSURANCE");
        uint48 _incidentTimestamp = (uint48)(incident.incidentTimestamp);
        require(
            _insurance.startTime <= _incidentTimestamp && _insurance.endTime >= _incidentTimestamp,
            "ERROR: INSURANCE_NOT_APPLICABLE"
        );

        bytes32 _targets = incident.merkleRoot;
        require(
            MerkleProof.verify(
                _merkleProof,
                _targets,
                keccak256(
                    abi.encodePacked(_insurance.target, _insurance.insured, _loss)
                )
            ) ||
                MerkleProof.verify(
                    _merkleProof,
                    _targets,
                    keccak256(abi.encodePacked(_insurance.target, address(0), _loss))
                ),
            "ERROR: INSURANCE_EXEMPTED"
        );
        insurances[_id].status = false;
        lockedAmount -= _insurance.amount;


        _loss = _loss * incident.payoutNumerator / incident.payoutDenominator;
        uint256 _payoutAmount = _insurance.amount > _loss ? _loss : _insurance.amount;

        vault.borrowValue(_payoutAmount, _insurance.insured);

        emit Redeemed(
            _id,
            _insurance.insured,
            _insurance.target,
            _insurance.amount,
            _payoutAmount
        );
    }

    function getPremium(uint256 _amount, uint256 _span)
        public
        view
        returns (uint256)
    {
        return
            parameters.getPremium(
                _amount,
                _span,
                totalLiquidity(),
                lockedAmount,
                address(this)
            );
    }


    function applyCover(
        uint256 _pending,
        uint256 _payoutNumerator,
        uint256 _payoutDenominator,
        uint256 _incidentTimestamp,
        bytes32 _merkleRoot,
        string calldata _rawdata,
        string calldata _memo
    ) external override onlyOwner {
        require(_incidentTimestamp < block.timestamp, "ERROR: INCIDENT_DATE");

        incident.payoutNumerator = _payoutNumerator;
        incident.payoutDenominator = _payoutDenominator;
        incident.incidentTimestamp = _incidentTimestamp;
        incident.merkleRoot = _merkleRoot;
        marketStatus = MarketStatus.Payingout;
        pendingEnd = block.timestamp + _pending;

        uint256 indexLength = indexList.length;
        for (uint256 i; i < indexLength;) {
            if (indices[indexList[i]].credit != 0) {
                IIndexTemplate(indexList[i]).lock();
            }
            unchecked {
                ++i;
            }
        }
        emit CoverApplied(
            _pending,
            _payoutNumerator,
            _payoutDenominator,
            _incidentTimestamp,
            _merkleRoot,
            _rawdata,
            _memo
        );
        emit MarketStatusChanged(MarketStatus.Payingout);
    }

    function applyBounty(
        uint256 _amount,
        address _contributor,
        uint256[] calldata _ids
    )external override onlyOwner {
        require(marketStatus == MarketStatus.Trading, "ERROR: NOT_TRADING_STATUS");

        vault.borrowValue(_amount, _contributor);

        _liquidation();

        uint256 totalAmountToUnlock;
        for (uint256 i; i < _ids.length; ++i) {
            uint _id = _ids[i];
            require(insurances[_id].status);

            uint unlockAmount = insurances[_id].amount;

            insurances[_id].status = false;
            totalAmountToUnlock += unlockAmount;
            emit Unlocked(_id, unlockAmount);
        }
        lockedAmount -= totalAmountToUnlock;

        emit BountyPaid(_amount, _contributor, _ids) ;
    }

    function resume() external {
        require(
            marketStatus == MarketStatus.Payingout &&
                pendingEnd < block.timestamp,
            "ERROR: UNABLE_TO_RESUME"
        );

        _liquidation();

        marketStatus = MarketStatus.Trading;

        uint256 indexLength = indexList.length;
        for (uint256 i; i < indexLength;) {
            IIndexTemplate(indexList[i]).adjustAlloc();
            unchecked {
                ++i;
            }
        }

        emit MarketStatusChanged(MarketStatus.Trading);
    }

    function _liquidation()internal{
        uint256 _totalLiquidity = totalLiquidity();
        uint256 _totalCredit = totalCredit;
        uint256 _debt = vault.debts(address(this));
        uint256 _deductionFromIndex;
        
        if (_totalLiquidity != 0) {
            _deductionFromIndex = _debt * _totalCredit / _totalLiquidity;
        }
        
        uint256 _actualDeduction;
        uint256 indexLength = indexList.length;
        for (uint256 i; i < indexLength;) {
            address _index = indexList[i];
            uint256 _credit = indices[_index].credit;

            if (_credit != 0) {
                uint256 _shareOfIndex = (_credit * MAGIC_SCALE_1E6) /
                    _totalCredit;
                uint256 _redeemAmount = _deductionFromIndex * _shareOfIndex / MAGIC_SCALE_1E6;
                _actualDeduction += IIndexTemplate(_index).compensate(
                    _redeemAmount
                );
            }
            unchecked {
                ++i;
            }
        }

        uint256 _deductionFromPool = _debt -
            _deductionFromIndex;
        uint256 _shortage = _deductionFromIndex  -
            _actualDeduction;
            
        if (_deductionFromPool != 0) {
            vault.offsetDebt(_deductionFromPool, address(this));
        }

        vault.transferDebt(_shortage);
    }


    function rate() external view returns (uint256) {
        uint256 _supply = totalSupply();
        uint256 originalLiquidity = originalLiquidity();
        
        if (originalLiquidity != 0 && _supply != 0) {
            return (originalLiquidity * MAGIC_SCALE_1E6) / _supply;
        } else {
            return 0;
        }
    }

    function valueOfUnderlying(address _owner)
        external
        view
        override
        returns (uint256)
    {
        uint256 _balance = balanceOf(_owner);
        uint256 _totalSupply = totalSupply();
        
        if (_balance != 0 || _totalSupply != 0) {
            return (_balance * originalLiquidity()) / _totalSupply;
        }
    }

    function pendingPremium(address _index)
        external
        view
        override
        returns (uint256)
    {
        uint256 _credit = indices[_index].credit;
        if (_credit != 0) {
            return
                _sub(
                    (_credit * rewardPerCredit) / MAGIC_SCALE_1E6,
                    indices[_index].rewardDebt
                );
        }
    }

    function worth(uint256 _value) public view returns (uint256 _amount) {
    
        uint256 _supply = totalSupply();
        uint256 _originalLiquidity = originalLiquidity();
        if (_supply != 0 && _originalLiquidity != 0) {
            _amount = (_value * _supply) / _originalLiquidity;
        } else if (_supply != 0 && _originalLiquidity == 0) {
            _amount = _value * _supply;
        } else {
            _amount = _value;
        }
    }

    function pairValues(address _index)
        external
        view
        override
        returns (uint256, uint256)
    {
        return (indices[_index].credit, _availableBalance());
    }

    function availableBalance()
        external
        view
        override
        returns (uint256)
    {
        return _availableBalance();
    }

    function _availableBalance()
        internal
        view
        returns (uint256)
    {
        uint256 _totalLiquidity = totalLiquidity();
        if (_totalLiquidity != 0) {
            return _totalLiquidity - lockedAmount;
        }
    }

    function utilizationRate() external view override returns (uint256) {
        uint256 _lockedAmount = lockedAmount;
        uint256 _totalLiquidity = totalLiquidity();
        
        if (_lockedAmount != 0 && _totalLiquidity != 0) {
            return (_lockedAmount * MAGIC_SCALE_1E6) / _totalLiquidity;
        }
    }

    function totalLiquidity() public view override returns (uint256) {
        return originalLiquidity() + totalCredit;
    }

    function originalLiquidity() public view returns (uint256) {
        return
            vault.underlyingValue(address(this)) -
            vault.attributionValue(attributionDebt);
    }


    function setPaused(bool _state) external override onlyOwner {
        if (paused != _state) {
            paused = _state;
            emit Paused(_state);
        }
    }

    function changeMetadata(string calldata _metadata)
        external
        override
        onlyOwner
    {
        metadata = _metadata;
        emit MetadataChanged(_metadata);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from != address(0)) {
            uint256 reqAmount = withdrawalReq[from].amount;
            if (reqAmount != 0){
                uint256 _after = balanceOf(from) - amount;
                if (_after < reqAmount) {
                    withdrawalReq[from].amount = _after;
                }
            } 
        }  
    }

    function _divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        uint256 c = a / b;
        if (a % b != 0) ++c;
        return c;
    }

    function _sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a >= b) {
            unchecked {return a - b;}
        }
    }
}