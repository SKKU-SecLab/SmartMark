
pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.4;


interface ITokenDecimals {

    function decimals() external view returns (uint8);

}

interface InterfaceCurve {

    function getShares(
        uint256 supply,
        uint256 pool,
        uint256 stake,
        uint256 reducer,
        uint256 minPrice
    ) external view returns (uint256);


    function getUnitPrice(
        uint256 supply,
        uint256 pool,
        uint256 reducer,
        uint256 minPrice
    ) external view returns (uint256);

}

contract LaunchPool is Initializable {

    using SafeERC20 for IERC20;
    address private _sponsor;
    string public metadata;
    address private _token;
    address private _curve;
    uint256 private _curveReducer;
    uint256 private _curveMinPrice;
    uint256 private _startTimestamp;
    uint256 private _endTimestamp;
    uint256 private _stakesMax;
    uint256 private _stakesMin;
    uint256 private _stakesTotal;
    uint256 private _stakesCount;
    uint256 private _stakeAmountMin;
    uint256 private _stakeClamp;
    enum Stages {
        NotInitialized,
        Initialized,
        Paused,
        Calculating,
        Distributing,
        Finalized,
        Aborted
    }
    Stages public stage = Stages.NotInitialized;

    address[] private _tokenList;
    mapping(address => bool) private _allowedTokens;
    mapping(address => uint8) private _tokenDecimals;

    struct TokenStake {
        address investor;
        address token;
        uint256 amount;
        uint256 shares;
    }

    mapping(uint256 => TokenStake) private _stakes;
    mapping(address => uint256[]) private _stakesByAccount;

    uint256 private _stakesCalculated = 0;
    uint256 private _stakesCalculatedBalance = 0;
    uint256 private _stakesDistributed = 0;


    event Staked(
        uint256 index,
        address indexed investor,
        address indexed token,
        uint256 amount
    );
    event Unstaked(
        uint256 index,
        address indexed investor,
        address indexed token,
        uint256 amount
    );
    event Distributed(
        uint256 index,
        address indexed investor,
        uint256 amount,
        uint256 shares
    );
    event MetadataUpdated(string newHash);


    function initialize(
        address[] memory allowedTokens,
        uint256[] memory uintArgs,
        string memory _metadata,
        address _owner,
        address _sharesAddress,
        address _curveAddress
    ) public initializer {

        require(
            allowedTokens.length >= 1 && allowedTokens.length <= 3,
            "There must be at least 1 and at most 3 tokens"
        );
        _stakesMin = uintArgs[0];
        _stakesMax = uintArgs[1];
        _startTimestamp = uintArgs[2];
        _endTimestamp = uintArgs[3];
        _curveReducer = uintArgs[4];
        _stakeAmountMin = uintArgs[5];
        _curveMinPrice = uintArgs[6];
        _stakeClamp = uintArgs[7];
        require(
            IERC20(_sharesAddress).totalSupply() >=
                InterfaceCurve(_curveAddress).getShares(
                    _stakesMax,
                    0,
                    _stakesMax,
                    _curveReducer,
                    _curveMinPrice
                ),
            "Shares token has not enough supply for staking distribution"
        );
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            require(
                ITokenDecimals(allowedTokens[i]).decimals() <= 18,
                "Token allowed has more than 18 decimals"
            );
            _tokenDecimals[allowedTokens[i]] = ITokenDecimals(allowedTokens[i])
                .decimals();
            _allowedTokens[allowedTokens[i]] = true;
            _tokenList.push(allowedTokens[i]);
        }
        _curve = _curveAddress;
        _sponsor = _owner;
        _token = _sharesAddress;
        metadata = _metadata;
        stage = Stages.Initialized;
    }


    modifier isTokenAllowed(address _tokenAddr) {

        require(_allowedTokens[_tokenAddr], "Cannot deposit that token");
        _;
    }

    modifier isStaking() {

        require(
            block.timestamp > _startTimestamp,
            "Launch Pool has not started"
        );
        require(stage == Stages.Initialized, "Launch Pool is not staking");
        _;
    }

    modifier isPaused() {

        require(stage == Stages.Paused, "LaunchPool is not paused");
        _;
    }

    modifier isConcluded() {

        require(
            block.timestamp >= _endTimestamp,
            "LaunchPool end timestamp not reached"
        );
        require(
            _stakesTotal >= _stakesMin,
            "LaunchPool not reached minimum stake"
        );
        _;
    }

    modifier isCalculating() {

        require(
            stage == Stages.Calculating,
            "Tokens are not yet ready to calculate"
        );
        _;
    }

    modifier isDistributing() {

        require(
            stage == Stages.Distributing,
            "Tokens are not yet ready to distribute"
        );
        _;
    }

    modifier isFinalized() {

        require(stage == Stages.Finalized, "Launch pool not finalized yet");
        _;
    }

    modifier hasStakeClamped(uint256 amount, address token) {

        require(
            amount * (10**(18 - _tokenDecimals[token])) <= _stakeClamp,
            "Stake maximum amount exceeded"
        );
        _;
    }

    modifier hasMaxStakeReached(uint256 amount, address token) {

        require(
            _stakesTotal + amount * (10**(18 - _tokenDecimals[token])) <=
                _stakesMax,
            "Maximum staked amount exceeded"
        );
        _;
    }

    modifier onlySponsor() {

        require(sponsor() == msg.sender, "Sponsor: caller is not the sponsor");
        _;
    }


    function sponsor() public view virtual returns (address) {

        return _sponsor;
    }

    function tokenList() public view returns (address[] memory) {

        return _tokenList;
    }

    function sharesAddress() public view returns (address) {

        return _token;
    }

    function stakesDetailedOf(address investor_)
        public
        view
        returns (uint256[] memory)
    {

        uint256[] memory stakes =
            new uint256[](_stakesByAccount[investor_].length * 2);
        for (uint256 i = 0; i < _stakesByAccount[investor_].length; i++) {
            stakes[i * 2] = _tokenDecimals[
                _stakes[_stakesByAccount[investor_][i]].token
            ];
            stakes[i * 2 + 1] = _stakes[_stakesByAccount[investor_][i]].amount;
        }
        return stakes;
    }

    function stakesOf(address investor_) public view returns (uint256[] memory) {

        return _stakesByAccount[investor_];
    }

    function stakesList() public view returns (uint256[] memory) {

        uint256[] memory stakes = new uint256[](_stakesCount);
        for (uint256 i = 0; i < _stakesCount; i++) {
            stakes[i] = _stakes[i].amount;
        }
        return stakes;
    }

    function getStakeShares(uint256 amount, uint256 balance)
        public
        view
        returns (uint256)
    {

        return
            InterfaceCurve(_curve).getShares(
                _stakesMax,
                balance,
                amount,
                _curveReducer,
                _curveMinPrice
            );
    }

    function getGeneralInfos() public view returns (uint256[] memory values) {

        values = new uint256[](11);
        values[0] = _startTimestamp;
        values[1] = _endTimestamp;
        values[2] = _stakesMin;
        values[3] = _stakesMax;
        values[4] = _stakesTotal;
        values[5] = _stakesCount;
        values[6] = _curveReducer;
        values[7] = uint256(stage);
        values[8] = _stakeAmountMin;
        values[9] = _curveMinPrice;
        values[10] = _stakeClamp;
        return values;
    }


    function updateMetadata(string memory _hash) external onlySponsor {

        metadata = _hash;
        emit MetadataUpdated(_hash);
    }


    function stake(address token, uint256 amount)
        external
        isStaking
        isTokenAllowed(token)
        hasMaxStakeReached(amount, token)
        hasStakeClamped(amount, token)
    {

        uint256 normalizedAmount = amount * (10**(18 - _tokenDecimals[token]));
        require(
            normalizedAmount >= _stakeAmountMin,
            "Stake below minimum amount"
        );
        uint256 prevBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender,address(this),amount);
        uint256 resultAmount = IERC20(token).balanceOf(address(this))-prevBalance;
        normalizedAmount = resultAmount * (10**(18 - _tokenDecimals[token]));
        TokenStake storage s = _stakes[_stakesCount];
        s.investor = msg.sender;
        s.token = token;
        s.amount = normalizedAmount;

        _stakesTotal += s.amount;
        _stakesByAccount[msg.sender].push(_stakesCount);
        emit Staked(_stakesCount, msg.sender, token, resultAmount);
        _stakesCount += 1;
    }

    function unstake(uint256 stakeId) external {

        require(
            stage == Stages.Initialized ||
            stage == Stages.Aborted ||
            stage == Stages.Paused,
            "No Staking/Paused/Aborted stage."
        );
        if (stage == Stages.Initialized) {
            require(block.timestamp <= _endTimestamp, "Launch Pool is closed");
        }
        require(
            _stakesByAccount[msg.sender].length > stakeId,
            "Stake index out of bounds"
        );

        uint256 globalId = _stakesByAccount[msg.sender][stakeId];
        TokenStake memory _stake = _stakes[globalId];
        require(_stake.amount > 0, "Stake already unstaked");
        IERC20(_stake.token).safeTransfer(
            msg.sender,
            _stake.amount / (10**(18 - _tokenDecimals[_stake.token]))
        );

        _stakesTotal -= _stake.amount;
        _stakes[globalId].amount = 0;
        emit Unstaked(globalId, msg.sender, _stake.token, _stake.amount);
    }

    function pause() external onlySponsor isStaking {

        stage = Stages.Paused;
    }

    function unpause() external onlySponsor isPaused {

        stage = Stages.Initialized;
    }

    function extendEndTimestamp(uint256 extension)
        external
        onlySponsor
        isStaking
    {

        require(extension < 365 days, "Extensions must be small than 1 year");
        _endTimestamp += extension;
    }

    function lock() external onlySponsor isConcluded {

        stage = Stages.Calculating;
    }


    function calculateSharesChunk() external onlySponsor isCalculating {

        InterfaceCurve curve = InterfaceCurve(_curve);
        while (_stakesCalculated < _stakesCount) {
            if (gasleft() < 100000) break;
            if (_stakes[_stakesCalculated].amount > 0) {
                _stakes[_stakesCalculated].shares = curve.getShares(
                    _stakesMax,
                    _stakesCalculatedBalance,
                    _stakes[_stakesCalculated].amount,
                    _curveReducer,
                    _curveMinPrice
                );
                _stakesCalculatedBalance += _stakes[_stakesCalculated].amount;
            }
            _stakesCalculated++;
        }
        if (_stakesCalculated >= _stakesCount) {
            stage = Stages.Distributing;
        }
    }


    function distributeSharesChunk() external onlySponsor isDistributing {

        IERC20 token = IERC20(_token);
        TokenStake memory _stake;
        while (_stakesDistributed < _stakesCount) {
            if (gasleft() < 100000) break;
            _stake = _stakes[_stakesDistributed];
            if (_stake.amount > 0) {
                token.safeTransferFrom(_sponsor, _stake.investor, _stake.shares);
                emit Distributed(
                    _stakesDistributed,
                    _stake.investor,
                    _stake.amount,
                    _stake.shares
                );
                _stakes[_stakesDistributed].shares = 0;
            }
            _stakesDistributed++;
        }
        if (_stakesDistributed >= _stakesCount) {
            stage = Stages.Finalized;
        }
    }


    function withdrawStakes(address token) external onlySponsor isFinalized {

        IERC20 instance = IERC20(token);
        uint256 tokenBalance = instance.balanceOf(address(this));
        instance.safeTransfer(msg.sender, tokenBalance);
    }


    function abort() external onlySponsor {

        stage = Stages.Aborted;
    }
}