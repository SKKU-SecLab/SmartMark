
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
}//Unlicense
pragma solidity ^0.8.9;

interface IDaoDepositManager {

    function dealManager() external returns (address);


    function initialize(address _dao) external;


    function setDealManager(address _newDealManager) external;


    function deposit(
        address _dealModule,
        uint32 _dealId,
        address _token,
        uint256 _amount
    ) external payable;


    function multipleDeposits(
        address _dealModule,
        uint32 _dealId,
        address[] calldata _tokens,
        uint256[] calldata _amounts
    ) external payable;


    function registerDeposit(
        address _dealModule,
        uint32 _dealId,
        address _token
    ) external;


    function registerDeposits(
        address _dealModule,
        uint32 _dealId,
        address[] calldata _tokens
    ) external;


    function withdraw(
        address _dealModule,
        uint32 _dealId,
        uint32 _depositId,
        address _sender
    )
        external
        returns (
            address,
            address,
            uint256
        );


    function sendToModule(
        uint32 _dealId,
        address _token,
        uint256 _amount
    ) external;


    function startVesting(
        uint32 _dealId,
        address _token,
        uint256 _amount,
        uint32 _vestingCliff,
        uint32 _vestingDuration
    ) external payable;


    function claimVestings() external;


    function verifyBalance(address _token) external view;


    function getDeposit(
        address _dealModule,
        uint32 _dealId,
        uint32 _depositId
    )
        external
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256
        );


    function getAvailableDealBalance(
        address _dealModule,
        uint32 _dealId,
        address _token
    ) external view returns (uint256);


    function getTotalDepositCount(address _dealModule, uint32 _dealId)
        external
        view
        returns (uint256);


    function getWithdrawableAmountOfDepositor(
        address _dealModule,
        uint32 _dealId,
        address _user,
        address _token
    ) external view returns (uint256);


    function getBalance(address _token) external view returns (uint256);


    function getVestedBalance(address _token) external view returns (uint256);

}// Unlicense
pragma solidity ^0.8.9;

interface IDealManager {

    function createDaoDepositManager(address _dao) external;


    function hasDaoDepositManager(address _dao) external view returns (bool);


    function getDaoDepositManager(address _dao) external view returns (address);


    function owner() external view returns (address);


    function weth() external view returns (address);


    function isModule(address who) external view returns (bool);

}// GPL-3.0-or-later
pragma solidity ^0.8.9;


contract ModuleBase {

    IDealManager public immutable dealManager;

    constructor(address _dealManager) {
        require(_dealManager != address(0), "ModuleBase: Error 100");
        dealManager = IDealManager(_dealManager);
    }

    function _pullTokensIntoModule(
        uint32 _dealId,
        address[] memory _daos,
        address[] memory _tokens,
        uint256[][] memory _path
    ) internal returns (uint256[] memory amountsIn) {

        amountsIn = new uint256[](_tokens.length);
        require(_path.length == _tokens.length, "ModuleBase: Error 102");
        uint256 tokenArrayLength = _tokens.length;
        for (uint256 i; i < tokenArrayLength; ++i) {
            uint256[] memory tokenPath = _path[i];
            require(tokenPath.length == _daos.length, "ModuleBase: Error 102");
            uint256 tokenPathArrayLength = tokenPath.length;
            for (uint256 j; j < tokenPathArrayLength; ++j) {
                uint256 daoAmount = tokenPath[j];
                if (daoAmount > 0) {
                    amountsIn[i] += daoAmount;
                    IDaoDepositManager(
                        dealManager.getDaoDepositManager(_daos[j])
                    ).sendToModule(_dealId, _tokens[i], daoAmount);
                }
            }
        }
    }

    function _approveToken(
        address _token,
        address _to,
        uint256 _amount
    ) internal {

        require(IERC20(_token).approve(_to, _amount), "ModuleBase: Error 243");
    }

    function _approveDaoDepositManager(
        address _token,
        address _dao,
        uint256 _amount
    ) internal {

        _approveToken(_token, dealManager.getDaoDepositManager(_dao), _amount);
    }

    function _transfer(
        address _token,
        address _to,
        uint256 _amount
    ) internal {

        if (_token != address(0)) {
            try IERC20(_token).transfer(_to, _amount) returns (bool success) {
                require(success, "ModuleBase: Error 241");
            } catch {
                revert("ModuleBase: Error 241");
            }
        } else {
            (bool sent, ) = _to.call{value: _amount}("");
            require(sent, "ModuleBase: Error 242");
        }
    }

    function _transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal {

        require(_token != address(0), "ModuleBase: Error 263");

        try IERC20(_token).transferFrom(_from, _to, _amount) returns (
            bool success
        ) {
            require(success, "ModuleBase: Error 241");
        } catch {
            revert("ModuleBase: Error 241");
        }
    }

    function hasDealExpired(uint32 _dealId)
        public
        view
        virtual
        returns (bool)
    {


    }
}// GPL-3.0-or-later
pragma solidity ^0.8.9;


contract ModuleBaseWithFee is ModuleBase {

    address public feeWallet;
    uint32 public feeInBasisPoints;
    uint32 public immutable MAX_FEE = 2_000;

    uint256 public immutable BPS = 10_000;

    constructor(address _dealManager) ModuleBase(_dealManager) {}

    event FeeWalletChanged(
        address indexed oldFeeWallet,
        address indexed newFeeWallet
    );

    event FeeChanged(uint32 indexed oldFee, uint32 indexed newFee);

    function setFeeWallet(address _feeWallet)
        external
        onlyDealManagerOwner(msg.sender)
    {

        require(
            _feeWallet != address(0) && _feeWallet != address(this),
            "ModuleBaseWithFee: Error 100"
        );
        if (feeWallet != _feeWallet) {
            feeWallet = _feeWallet;
            emit FeeWalletChanged(feeWallet, _feeWallet);
        }
    }

    function setFee(uint32 _feeInBasisPoints)
        external
        onlyDealManagerOwner(msg.sender)
    {

        require(_feeInBasisPoints <= MAX_FEE, "ModuleBaseWithFee: Error 264");
        if (feeInBasisPoints != _feeInBasisPoints) {
            feeInBasisPoints = _feeInBasisPoints;
            emit FeeChanged(feeInBasisPoints, _feeInBasisPoints);
        }
    }

    function _payFeeAndReturnRemainder(address _token, uint256 _amount)
        internal
        returns (uint256)
    {

        if (feeWallet != address(0) && feeInBasisPoints > 0) {
            uint256 fee = (_amount * feeInBasisPoints) / BPS;
            _transfer(_token, feeWallet, fee);

            return _amount - fee;
        }
        return _amount;
    }

    function _transferWithFee(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (uint256 amountAfterFee) {

        amountAfterFee = _payFeeAndReturnRemainder(_token, _amount);
        _transfer(_token, _to, amountAfterFee);
    }

    function _transferFromWithFee(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (uint256 amountAfterFee) {

        if (_to != address(this)) {
            _transferFrom(_token, _from, address(this), _amount);
            amountAfterFee = _transferWithFee(_token, _to, _amount);
        } else {
            _transferFrom(_token, _from, _to, _amount);
            amountAfterFee = _payFeeAndReturnRemainder(_token, _amount);
        }
    }

    modifier onlyDealManagerOwner(address _sender) {

        require(_sender == dealManager.owner(), "ModuleBaseWithFee: Error 221");
        _;
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.9;


contract TokenSwapModule is ModuleBaseWithFee {

    uint32 public lastDealId;
    mapping(uint32 => TokenSwap) public tokenSwaps;
    mapping(bytes32 => uint32) public metadataToDealId;

    struct TokenSwap {
        address[] daos;
        address[] tokens;
        uint256[][] pathFrom;
        uint256[][] pathTo;
        uint32 deadline;
        uint32 executionDate;
        bytes32 metadata;
        bool isExecuted;
    }

    event TokenSwapCreated(
        address indexed module,
        uint32 indexed dealId,
        bytes32 indexed metadata,
        address[] daos,
        address[] tokens,
        uint256[][] pathFrom,
        uint256[][] pathTo,
        uint32 deadline
    );

    event TokenSwapExecuted(
        address indexed module,
        uint32 indexed dealId,
        bytes32 indexed metadata
    );

    constructor(address _dealManager) ModuleBaseWithFee(_dealManager) {}

    function _createSwap(
        address[] memory _daos,
        address[] memory _tokens,
        uint256[][] memory _pathFrom,
        uint256[][] memory _pathTo,
        bytes32 _metadata,
        uint32 _deadline
    ) internal returns (uint32) {

        require(_metadata != "", "TokenSwapModule: Error 101");
        require(_metadataDoesNotExist(_metadata), "TokenSwapModule: Error 203");
        require(_daos.length >= 2, "TokenSwapModule: Error 204");
        require(_tokens.length != 0, "TokenSwapModule: Error 205");
        require(_deadline != 0, "TokenSwapModule: Error 101");

        uint256 pathFromLen = _pathFrom.length;
        require(
            _tokens.length == pathFromLen && pathFromLen == _pathTo.length,
            "TokenSwapModule: Error 102"
        );

        for (uint256 i; i < _tokens.length; ++i) {
            for (uint256 j = i + 1; j < _tokens.length; ++j)
                require(_tokens[i] != _tokens[j], "TokenSwapModule: Error 104");
        }

        uint256 daosLen = _daos.length;
        for (uint256 i; i < pathFromLen; ++i) {
            require(
                _pathFrom[i].length == daosLen &&
                    _pathTo[i].length == daosLen << 2,
                "TokenSwapModule: Error 102"
            );
        }

        TokenSwap memory ts = TokenSwap(
            _daos,
            _tokens,
            _pathFrom,
            _pathTo,
            uint32(block.timestamp) + _deadline,
            0,
            _metadata,
            false
        );

        ++lastDealId;

        tokenSwaps[lastDealId] = ts;

        metadataToDealId[_metadata] = lastDealId;

        emit TokenSwapCreated(
            address(this),
            lastDealId,
            _metadata,
            _daos,
            _tokens,
            _pathFrom,
            _pathTo,
            _deadline
        );
        return lastDealId;
    }

    function createSwap(
        address[] calldata _daos,
        address[] calldata _tokens,
        uint256[][] calldata _pathFrom,
        uint256[][] calldata _pathTo,
        bytes32 _metadata,
        uint32 _deadline
    ) external returns (uint32) {

        for (uint256 i; i < _daos.length; ++i) {
            address dao = _daos[i];
            if (!dealManager.hasDaoDepositManager(dao)) {
                dealManager.createDaoDepositManager(dao);
            }
        }
        return (
            _createSwap(
                _daos,
                _tokens,
                _pathFrom,
                _pathTo,
                _metadata,
                _deadline
            )
        );
    }

    function checkExecutability(uint32 _dealId)
        public
        view
        validDealId(_dealId)
        returns (bool)
    {

        TokenSwap memory ts = tokenSwaps[_dealId];
        if (hasDealExpired(_dealId)) {
            return false;
        }

        address[] memory t = ts.tokens;
        uint256 tokenArrayLength = t.length;
        for (uint256 i; i < tokenArrayLength; ++i) {
            uint256[] memory p = ts.pathFrom[i];
            uint256 pathArrayLength = p.length;
            for (uint256 j; j < pathArrayLength; ++j) {
                if (p[j] == 0) {
                    continue;
                }
                uint256 bal = IDaoDepositManager(
                    dealManager.getDaoDepositManager(ts.daos[j])
                ).getAvailableDealBalance(address(this), _dealId, t[i]);
                if (bal < p[j]) {
                    return false;
                }
            }
        }
        return true;
    }

    function executeSwap(uint32 _dealId)
        external
        validDealId(_dealId)
        isNotExecuted(_dealId)
    {

        TokenSwap storage ts = tokenSwaps[_dealId];

        require(checkExecutability(_dealId), "TokenSwapModule: Error 265");

        ts.isExecuted = true;
        ts.executionDate = uint32(block.timestamp);

        uint256[] memory amountsIn = _pullTokensIntoModule(
            _dealId,
            ts.daos,
            ts.tokens,
            ts.pathFrom
        );

        uint256[] memory amountsOut = _distributeTokens(ts, _dealId);

        uint256 tokenArrayLength = ts.tokens.length;
        for (uint256 i; i < tokenArrayLength; ++i) {
            require(
                amountsIn[i] == amountsOut[i],
                "TokenSwapModule: Error 103"
            );
        }

        emit TokenSwapExecuted(address(this), _dealId, ts.metadata);
    }

    function _distributeTokens(TokenSwap memory _ts, uint32 _dealId)
        internal
        returns (uint256[] memory amountsOut)
    {

        amountsOut = new uint256[](_ts.tokens.length);
        uint256 tokenArrayLength = _ts.tokens.length;
        for (uint256 i; i < tokenArrayLength; ++i) {
            uint256[] memory pt = _ts.pathTo[i];
            address token = _ts.tokens[i];
            uint256 pathArrayLength = pt.length >> 2;
            for (uint256 k; k < pathArrayLength; ++k) {
                uint256 instant = pt[k << 2];
                uint256 vested = pt[(k << 2) + 1];

                if (instant > 0) {
                    amountsOut[i] += instant;
                    _transferWithFee(token, _ts.daos[k], instant);
                }

                if (vested > 0) {
                    amountsOut[i] += vested;
                    uint256 amount = _payFeeAndReturnRemainder(token, vested);
                    address daoDepositManager = dealManager
                        .getDaoDepositManager(_ts.daos[k]);
                    if (token != address(0)) {
                        _approveDaoDepositManager(token, _ts.daos[k], amount);
                    }

                    uint256 callValue = token == address(0) ? amount : 0;
                    IDaoDepositManager(daoDepositManager).startVesting{
                        value: callValue
                    }(
                        _dealId,
                        token,
                        amount, // amount
                        uint32(pt[(k << 2) + 2]), // cliff
                        uint32(pt[(k << 2) + 3]) // duration
                    );
                }
            }
        }
    }

    function getTokenswapFromMetadata(bytes32 _metadata)
        public
        view
        returns (TokenSwap memory swap)
    {

        return tokenSwaps[metadataToDealId[_metadata]];
    }

    function hasDealExpired(uint32 _dealId)
        public
        view
        override
        validDealId(_dealId)
        returns (bool)
    {

        TokenSwap memory swap = tokenSwaps[_dealId];
        return
            swap.isExecuted ||
            swap.deadline < uint32(block.timestamp);
    }

    function _metadataDoesNotExist(bytes32 _metadata)
        internal
        view
        returns (bool)
    {

        TokenSwap memory ts = getTokenswapFromMetadata(_metadata);
        return ts.metadata == 0;
    }

    modifier validDealId(uint32 _dealId) {

        require(
            tokenSwaps[_dealId].metadata != 0,
            "TokenSwapModule: Error 207"
        );
        _;
    }

    modifier isNotExecuted(uint32 _dealId) {

        require(!tokenSwaps[_dealId].isExecuted, "TokenSwapModule: Error 266");
        _;
    }

    fallback() external payable {}

    receive() external payable {}
}