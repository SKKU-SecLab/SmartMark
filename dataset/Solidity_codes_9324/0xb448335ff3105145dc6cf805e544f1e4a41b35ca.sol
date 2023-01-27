
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
}// Unlicense
pragma solidity ^0.8.9;

interface IDealManager {

    function createDaoDepositManager(address _dao) external;


    function hasDaoDepositManager(address _dao) external view returns (bool);


    function getDaoDepositManager(address _dao) external view returns (address);


    function owner() external view returns (address);


    function weth() external view returns (address);


    function isModule(address who) external view returns (bool);

}// Unlicense
pragma solidity ^0.8.9;

interface IModuleBase {

    function moduleIdentifier() external view returns (bytes32);


    function dealManager() external view returns (address);


    function hasDealExpired(uint32 _dealId) external view returns (bool);

}// GPL-3.0-or-later
pragma solidity ^0.8.9;


contract DaoDepositManager {

    address public dao;
    IDealManager public dealManager;
    mapping(address => uint256) public tokenBalances;
    mapping(address => mapping(address => mapping(uint32 => uint256)))
        public availableDealBalances;
    mapping(address => uint256) public vestedBalances;
    mapping(address => mapping(uint256 => Deposit[])) public deposits;
    Vesting[] public vestings;
    address[] public vestedTokenAddresses;
    mapping(address => uint256) public vestedTokenAmounts;
    mapping(address => mapping(uint256 => uint256)) public tokensPerDeal;

    struct Deposit {
        address depositor;
        address token;
        uint256 amount;
        uint256 used;
        uint32 depositedAt;
    }

    struct Vesting {
        address dealModule;
        uint32 dealId;
        address token;
        uint256 totalVested;
        uint256 totalClaimed;
        uint32 startTime;
        uint32 cliff;
        uint32 duration;
    }

    event Deposited(
        address indexed dealModule,
        uint32 indexed dealId,
        address indexed depositor,
        uint32 depositId,
        address token,
        uint256 amount
    );

    event Withdrawn(
        address indexed dealModule,
        uint32 indexed dealId,
        address indexed depositor,
        uint32 depositId,
        address token,
        uint256 amount
    );

    event VestingStarted(
        address indexed dealModule,
        uint32 indexed dealId,
        uint256 indexed vestingStart,
        uint32 vestingCliff,
        uint32 vestingDuration,
        address token,
        uint256 amount
    );

    event VestingClaimed(
        address indexed dealModule,
        uint32 indexed dealId,
        address indexed dao,
        address token,
        uint256 claimed
    );

    function initialize(address _dao) external {

        require(dao == address(0), "DaoDepositManager: Error 001");
        require(
            _dao != address(0) && _dao != address(this),
            "DaoDepositManager: Error 100"
        );
        dao = _dao;
        dealManager = IDealManager(msg.sender);
    }

    function setDealManager(address _newDealManager) external onlyDealManager {

        require(
            _newDealManager != address(0) && _newDealManager != address(this),
            "DaoDepositManager: Error 100"
        );
        dealManager = IDealManager(_newDealManager);
    }

    function deposit(
        address _module,
        uint32 _dealId,
        address _token,
        uint256 _amount
    ) public payable {

        require(_amount != 0, "DaoDepositManager: Error 101");
        if (_token != address(0)) {
            _transferFrom(_token, msg.sender, address(this), _amount);
        } else {
            require(_amount == msg.value, "DaoDepositManager: Error 202");
        }

        tokenBalances[_token] += _amount;
        availableDealBalances[_token][_module][_dealId] += _amount;
        verifyBalance(_token);
        deposits[_module][_dealId].push(
            Deposit(msg.sender, _token, _amount, 0, uint32(block.timestamp))
        );

        emit Deposited(
            _module,
            _dealId,
            msg.sender,
            uint32(deposits[_module][_dealId].length - 1),
            _token,
            _amount
        );
    }

    function multipleDeposits(
        address _module,
        uint32 _dealId,
        address[] calldata _tokens,
        uint256[] calldata _amounts
    ) external payable {

        require(
            _tokens.length == _amounts.length,
            "DaoDepositManager: Error 102"
        );
        uint256 tokenArrayLength = _tokens.length;
        for (uint256 i; i < tokenArrayLength; ++i) {
            deposit(_module, _dealId, _tokens[i], _amounts[i]);
        }
    }

    function withdraw(
        address _module,
        uint32 _dealId,
        uint32 _depositId
    )
        external
        returns (
            address,
            address,
            uint256
        )
    {

        require(
            deposits[_module][_dealId].length > _depositId,
            "DaoDepositManager: Error 200"
        );
        Deposit storage d = deposits[_module][_dealId][_depositId];

        require(d.depositor == msg.sender, "DaoDepositManager: Error 222");

        uint256 freeAmount = d.amount - d.used;
        require(freeAmount != 0, "DaoDepositManager: Error 240");
        d.used = d.amount;
        availableDealBalances[d.token][_module][_dealId] -= freeAmount;
        tokenBalances[d.token] -= freeAmount;
        _transfer(d.token, d.depositor, freeAmount);

        emit Withdrawn(
            _module,
            _dealId,
            d.depositor,
            _depositId,
            d.token,
            freeAmount
        );
        return (d.depositor, d.token, freeAmount);
    }

    function sendToModule(
        uint32 _dealId,
        address _token,
        uint256 _amount
    ) external onlyModule {

        uint256 amountLeft = _amount;
        uint256 depositArrayLength = deposits[msg.sender][_dealId].length;
        for (uint256 i; i < depositArrayLength; ++i) {
            Deposit storage d = deposits[msg.sender][_dealId][i];
            if (d.token == _token) {
                uint256 freeAmount = d.amount - d.used;
                if (freeAmount > amountLeft) {
                    freeAmount = amountLeft;
                }
                amountLeft -= freeAmount;
                d.used += freeAmount;

                if (amountLeft == 0) {
                    _transfer(_token, msg.sender, _amount);
                    tokenBalances[_token] -= _amount;
                    availableDealBalances[_token][msg.sender][
                        _dealId
                    ] -= _amount;
                    break;
                }
            }
        }
        require(amountLeft == 0, "DaoDepositManager: Error 262");
    }

    function startVesting(
        uint32 _dealId,
        address _token,
        uint256 _amount,
        uint32 _vestingCliff,
        uint32 _vestingDuration
    ) external payable onlyModule {

        require(_amount != 0, "DaoDepositManager: Error 101");
        require(
            _vestingCliff <= _vestingDuration,
            "DaoDepositManager: Error 201"
        );

        if (_token != address(0)) {
            _transferFrom(_token, msg.sender, address(this), _amount);
        } else {
            require(_amount == msg.value, "DaoDepositManager: Error 202");
        }

        vestedBalances[_token] += _amount;

        verifyBalance(_token);

        vestings.push(
            Vesting(
                msg.sender,
                _dealId,
                _token,
                _amount,
                0,
                uint32(block.timestamp),
                _vestingCliff,
                _vestingDuration
            )
        );

        if (vestedTokenAmounts[_token] == 0) {
            vestedTokenAddresses.push(_token);
        }

        vestedTokenAmounts[_token] += _amount;

        ++tokensPerDeal[msg.sender][_dealId];

        emit VestingStarted(
            msg.sender,
            _dealId,
            uint32(block.timestamp),
            _vestingCliff,
            _vestingDuration,
            _token,
            _amount
        );
    }

    function claimVestings()
        external
        returns (address[] memory tokens, uint256[] memory amounts)
    {

        uint256 vestingCount = vestedTokenAddresses.length;
        tokens = new address[](vestingCount);
        amounts = new uint256[](vestingCount);

        for (uint256 i; i < vestingCount; ++i) {
            tokens[i] = vestedTokenAddresses[i];
        }

        uint256 vestingArrayLength = vestings.length;
        for (uint256 i; i < vestingArrayLength; ++i) {
            (address token, uint256 amount) = sendReleasableClaim(vestings[i]);
            for (uint256 j; j < vestingCount; ++j) {
                if (token == tokens[j]) {
                    amounts[j] += amount;
                }
            }
        }
        return (tokens, amounts);
    }

    function claimDealVestings(address _module, uint32 _dealId)
        external
        returns (address[] memory tokens, uint256[] memory amounts)
    {

        uint256 amountOfTokens = tokensPerDeal[_module][_dealId];

        tokens = new address[](amountOfTokens);
        amounts = new uint256[](amountOfTokens);
        uint256 counter;
        if (amountOfTokens != 0) {
            for (uint256 i; i < vestings.length; ++i) {
                Vesting storage v = vestings[i];
                if (v.dealModule == _module && v.dealId == _dealId) {
                    (tokens[counter], amounts[counter]) = sendReleasableClaim(
                        v
                    );
                    ++counter;
                }
            }
        }
        return (tokens, amounts);
    }

    function sendReleasableClaim(Vesting storage vesting)
        private
        returns (address token, uint256 amount)
    {

        if (vesting.totalClaimed < vesting.totalVested) {
            uint32 elapsedSeconds = uint32(block.timestamp) - vesting.startTime;

            if (elapsedSeconds < vesting.cliff) {
                return (vesting.token, 0);
            }
            if (elapsedSeconds >= vesting.duration) {
                amount = vesting.totalVested - vesting.totalClaimed;
                vesting.totalClaimed = vesting.totalVested;
                tokensPerDeal[vesting.dealModule][vesting.dealId]--;
            } else {
                amount =
                    (vesting.totalVested * uint256(elapsedSeconds)) /
                    uint256(vesting.duration);
                amount -= vesting.totalClaimed;
                vesting.totalClaimed += amount;
            }

            token = vesting.token;
            vestedTokenAmounts[token] -= amount;

            if (vestedTokenAmounts[token] == 0) {
                uint256 arrLen = vestedTokenAddresses.length;
                for (uint256 i; i < arrLen; ++i) {
                    if (vestedTokenAddresses[i] == token) {
                        if (i != arrLen - 1) {
                            vestedTokenAddresses[i] = vestedTokenAddresses[
                                arrLen - 1
                            ];
                        }
                        vestedTokenAddresses.pop();
                        --arrLen;
                    }
                }
            }

            require(
                vesting.totalClaimed <= vesting.totalVested,
                "DaoDepositManager: Error 244"
            );
            vestedBalances[token] -= amount;
            _transfer(token, dao, amount);

            emit VestingClaimed(
                vesting.dealModule,
                vesting.dealId,
                dao,
                token,
                amount
            );
        }
    }

    function verifyBalance(address _token) public view {

        require(
            getBalance(_token) >=
                tokenBalances[_token] + vestedBalances[_token],
            "DaoDepositManager: Error 245"
        );
    }

    function getDeposit(
        address _module,
        uint32 _dealId,
        uint32 _depositId
    )
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint32
        )
    {

        Deposit memory d = deposits[_module][_dealId][_depositId];
        return (d.depositor, d.token, d.amount, d.used, d.depositedAt);
    }

    function getDepositRange(
        address _module,
        uint32 _dealId,
        uint32 _fromDepositId,
        uint32 _toDepositId
    )
        external
        view
        returns (
            address[] memory depositors,
            address[] memory tokens,
            uint256[] memory amounts,
            uint256[] memory usedAmounts,
            uint256[] memory times
        )
    {

        uint32 range = 1 + _toDepositId - _fromDepositId; // inclusive range
        depositors = new address[](range);
        tokens = new address[](range);
        amounts = new uint256[](range);
        usedAmounts = new uint256[](range);
        times = new uint256[](range);
        uint256 index; // needed since the ids can start at > 0
        for (uint32 i = _fromDepositId; i <= _toDepositId; ++i) {
            (
                depositors[index],
                tokens[index],
                amounts[index],
                usedAmounts[index],
                times[index]
            ) = getDeposit(_module, _dealId, i);
            ++index;
        }
        return (depositors, tokens, amounts, usedAmounts, times);
    }

    function getAvailableDealBalance(
        address _module,
        uint32 _dealId,
        address _token
    ) external view returns (uint256) {

        return availableDealBalances[_token][_module][_dealId];
    }

    function getTotalDepositCount(address _module, uint32 _dealId)
        external
        view
        returns (uint32)
    {

        return uint32(deposits[_module][_dealId].length);
    }

    function getWithdrawableAmountOfDepositor(
        address _module,
        uint32 _dealId,
        address _depositor,
        address _token
    ) external view returns (uint256) {

        uint256 freeAmount;
        for (uint256 i; i < deposits[_module][_dealId].length; ++i) {
            if (
                deposits[_module][_dealId][i].depositor == _depositor &&
                deposits[_module][_dealId][i].token == _token
            ) {
                freeAmount += (deposits[_module][_dealId][i].amount -
                    deposits[_module][_dealId][i].used);
            }
        }
        return freeAmount;
    }

    function getBalance(address _token) public view returns (uint256) {

        if (_token == address(0)) {
            return address(this).balance;
        }
        return IERC20(_token).balanceOf(address(this));
    }

    function _transfer(
        address _token,
        address _to,
        uint256 _amount
    ) internal {

        if (_token != address(0)) {
            try IERC20(_token).transfer(_to, _amount) returns (bool success) {
                require(success, "DaoDepositManager: Error 241");
            } catch {
                revert("DaoDepositManager: Error 241");
            }
        } else {
            (bool sent, ) = _to.call{value: _amount}("");
            require(sent, "DaoDepositManager: Error 242");
        }
    }

    function _transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal {

        try IERC20(_token).transferFrom(_from, _to, _amount) returns (
            bool success
        ) {
            require(success, "DaoDepositManager: Error 241");
        } catch {
            revert("DaoDepositManager: Error 241");
        }
    }

    modifier onlyDealManager() {

        require(
            msg.sender == address(dealManager),
            "DaoDepositManager: Error 221"
        );
        _;
    }

    modifier onlyModule() {

        require(
            dealManager.isModule(msg.sender),
            "DaoDepositManager: Error 220"
        );
        _;
    }

    fallback() external payable {}

    receive() external payable {}
}