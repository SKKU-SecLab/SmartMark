
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity 0.7.6;


interface IPENDLE is IERC20 {

    function initiateConfigChanges(
        uint256 _emissionRateMultiplierNumerator,
        uint256 _terminalInflationRateNumerator,
        address _liquidityIncentivesRecipient,
        bool _isBurningAllowed
    ) external;


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function burn(uint256 amount) external returns (bool);


    function applyConfigChanges() external;


    function claimLiquidityEmissions() external returns (uint256 totalEmissions);


    function isPendleToken() external view returns (bool);


    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256);


    function startTime() external view returns (uint256);


    function configChangesInitiated() external view returns (uint256);


    function emissionRateMultiplierNumerator() external view returns (uint256);


    function terminalInflationRateNumerator() external view returns (uint256);


    function liquidityIncentivesRecipient() external view returns (address);


    function isBurningAllowed() external view returns (bool);


    function pendingEmissionRateMultiplierNumerator() external view returns (uint256);


    function pendingTerminalInflationRateNumerator() external view returns (uint256);


    function pendingLiquidityIncentivesRecipient() external view returns (address);


    function pendingIsBurningAllowed() external view returns (bool);

}
pragma solidity 0.7.6;


abstract contract Permissions {
    address public governance;
    address public pendingGovernance;
    address internal initializer;

    event GovernanceClaimed(address newGovernance, address previousGovernance);

    event TransferGovernancePending(address pendingGovernance);

    constructor(address _governance) {
        require(_governance != address(0), "ZERO_ADDRESS");
        initializer = msg.sender;
        governance = _governance;
    }

    modifier initialized() {
        require(initializer == address(0), "NOT_INITIALIZED");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "ONLY_GOVERNANCE");
        _;
    }

    function claimGovernance() public {
        require(pendingGovernance == msg.sender, "WRONG_GOVERNANCE");
        emit GovernanceClaimed(pendingGovernance, governance);
        governance = pendingGovernance;
        pendingGovernance = address(0);
    }

    function transferGovernance(address _governance) public onlyGovernance {
        require(_governance != address(0), "ZERO_ADDRESS");
        pendingGovernance = _governance;

        emit TransferGovernancePending(pendingGovernance);
    }
}

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.2 <0.8.0;

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
}

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity 0.7.6;


abstract contract Withdrawable is Permissions {
    using SafeERC20 for IERC20;

    event EtherWithdraw(uint256 amount, address sendTo);
    event TokenWithdraw(IERC20 token, uint256 amount, address sendTo);

    function withdrawEther(uint256 amount, address payable sendTo) external onlyGovernance {
        (bool success, ) = sendTo.call{value: amount}("");
        require(success, "WITHDRAW_FAILED");
        emit EtherWithdraw(amount, sendTo);
    }

    function withdrawToken(
        IERC20 token,
        uint256 amount,
        address sendTo
    ) external onlyGovernance {
        token.safeTransfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }
}
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


contract PENDLE is IPENDLE, Permissions, Withdrawable {

    using SafeMath for uint256;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    bool public constant override isPendleToken = true;
    string public constant name = "Pendle";
    string public constant symbol = "PENDLE";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    uint256 private constant TEAM_INVESTOR_ADVISOR_AMOUNT = 94917125 * 1e18;
    uint256 private constant ECOSYSTEM_FUND_TOKEN_AMOUNT = 46 * 1_000_000 * 1e18;
    uint256 private constant PUBLIC_SALES_TOKEN_AMOUNT = 16582875 * 1e18;
    uint256 private constant INITIAL_LIQUIDITY_EMISSION = 1200000 * 1e18;
    uint256 private constant CONFIG_DENOMINATOR = 1_000_000_000_000;
    uint256 private constant CONFIG_CHANGES_TIME_LOCK = 7 days;
    uint256 public override emissionRateMultiplierNumerator;
    uint256 public override terminalInflationRateNumerator;
    address public override liquidityIncentivesRecipient;
    bool public override isBurningAllowed;
    uint256 public override pendingEmissionRateMultiplierNumerator;
    uint256 public override pendingTerminalInflationRateNumerator;
    address public override pendingLiquidityIncentivesRecipient;
    bool public override pendingIsBurningAllowed;
    uint256 public override configChangesInitiated;
    uint256 public override startTime;
    uint256 public lastWeeklyEmission;
    uint256 public lastWeekEmissionSent;

    mapping(address => mapping(address => uint256)) internal allowances;
    mapping(address => uint256) internal balances;
    mapping(address => address) public delegates;

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => uint256) public nonces;

    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    event PendingConfigChanges(
        uint256 pendingEmissionRateMultiplierNumerator,
        uint256 pendingTerminalInflationRateNumerator,
        address pendingLiquidityIncentivesRecipient,
        bool pendingIsBurningAllowed
    );

    event ConfigsChanged(
        uint256 emissionRateMultiplierNumerator,
        uint256 terminalInflationRateNumerator,
        address liquidityIncentivesRecipient,
        bool isBurningAllowed
    );

    constructor(
        address _governance,
        address pendleTeamTokens,
        address pendleEcosystemFund,
        address salesMultisig,
        address _liquidityIncentivesRecipient
    ) Permissions(_governance) {
        require(
            pendleTeamTokens != address(0) &&
                pendleEcosystemFund != address(0) &&
                salesMultisig != address(0) &&
                _liquidityIncentivesRecipient != address(0),
            "ZERO_ADDRESS"
        );
        _mint(pendleTeamTokens, TEAM_INVESTOR_ADVISOR_AMOUNT);
        _mint(pendleEcosystemFund, ECOSYSTEM_FUND_TOKEN_AMOUNT);
        _mint(salesMultisig, PUBLIC_SALES_TOKEN_AMOUNT);
        _mint(_liquidityIncentivesRecipient, INITIAL_LIQUIDITY_EMISSION * 26);
        emissionRateMultiplierNumerator = (CONFIG_DENOMINATOR * 989) / 1000; // emission rate = 98.9% -> 1.1% decay
        terminalInflationRateNumerator = 379848538; // terminal inflation rate = 2% => weekly inflation = 0.0379848538%
        liquidityIncentivesRecipient = _liquidityIncentivesRecipient;
        startTime = block.timestamp;
        lastWeeklyEmission = INITIAL_LIQUIDITY_EMISSION;
        lastWeekEmissionSent = 26; // already done liquidity emissions for the first 26 weeks
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address dst, uint256 amount) external override returns (bool) {

        _transfer(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external override returns (bool) {

        _transfer(src, dst, amount);
        _approve(
            src,
            msg.sender,
            allowances[src][msg.sender].sub(amount, "TRANSFER_EXCEED_ALLOWANCE")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {

        _approve(msg.sender, spender, allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {

        _approve(
            msg.sender,
            spender,
            allowances[msg.sender][spender].sub(subtractedValue, "NEGATIVE_ALLOWANCE")
        );
        return true;
    }

    function burn(uint256 amount) public override returns (bool) {

        require(isBurningAllowed, "BURNING_NOT_ALLOWED");
        _burn(msg.sender, amount);
        return true;
    }

    function allowance(address account, address spender) external view override returns (uint256) {

        return allowances[account][spender];
    }

    function balanceOf(address account) external view override returns (uint256) {

        return balances[account];
    }

    function getCurrentVotes(address account) external view returns (uint256) {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function delegate(address delegatee) public {

        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        bytes32 domainSeparator =
            keccak256(
                abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))
            );
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "INVALID_SIGNATURE");
        require(nonce == nonces[signatory]++, "INVALID_NONCE");
        require(block.timestamp <= expiry, "SIGNATURE_EXPIRED");
        return _delegate(signatory, delegatee);
    }

    function getPriorVotes(address account, uint256 blockNumber)
        public
        view
        override
        returns (uint256)
    {

        require(blockNumber < block.number, "NOT_YET_DETERMINED");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _transfer(
        address src,
        address dst,
        uint256 amount
    ) internal {

        require(src != address(0), "SENDER_ZERO_ADDR");
        require(dst != address(0), "RECEIVER_ZERO_ADDR");
        require(dst != address(this), "SEND_TO_TOKEN_CONTRACT");

        balances[src] = balances[src].sub(amount, "TRANSFER_EXCEED_BALANCE");
        balances[dst] = balances[dst].add(amount);
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    function _approve(
        address src,
        address dst,
        uint256 amount
    ) internal virtual {

        require(src != address(0), "OWNER_ZERO_ADDR");
        require(dst != address(0), "SPENDER_ZERO_ADDR");

        allowances[src][dst] = amount;
        emit Approval(src, dst, amount);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {

        uint32 blockNumber = safe32(block.number, "BLOCK_NUM_EXCEED_32_BITS");

        if (
            nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint256) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function initiateConfigChanges(
        uint256 _emissionRateMultiplierNumerator,
        uint256 _terminalInflationRateNumerator,
        address _liquidityIncentivesRecipient,
        bool _isBurningAllowed
    ) external override onlyGovernance {

        require(_liquidityIncentivesRecipient != address(0), "ZERO_ADDRESS");
        pendingEmissionRateMultiplierNumerator = _emissionRateMultiplierNumerator;
        pendingTerminalInflationRateNumerator = _terminalInflationRateNumerator;
        pendingLiquidityIncentivesRecipient = _liquidityIncentivesRecipient;
        pendingIsBurningAllowed = _isBurningAllowed;
        emit PendingConfigChanges(
            _emissionRateMultiplierNumerator,
            _terminalInflationRateNumerator,
            _liquidityIncentivesRecipient,
            _isBurningAllowed
        );
        configChangesInitiated = block.timestamp;
    }

    function applyConfigChanges() external override {

        require(configChangesInitiated != 0, "UNINITIATED_CONFIG_CHANGES");
        require(
            block.timestamp > configChangesInitiated + CONFIG_CHANGES_TIME_LOCK,
            "TIMELOCK_IS_NOT_OVER"
        );

        _mintLiquidityEmissions(); // We must settle the pending liquidity emissions first, to make sure the weeks in the past follow the old configs

        emissionRateMultiplierNumerator = pendingEmissionRateMultiplierNumerator;
        terminalInflationRateNumerator = pendingTerminalInflationRateNumerator;
        liquidityIncentivesRecipient = pendingLiquidityIncentivesRecipient;
        isBurningAllowed = pendingIsBurningAllowed;
        configChangesInitiated = 0;
        emit ConfigsChanged(
            emissionRateMultiplierNumerator,
            terminalInflationRateNumerator,
            liquidityIncentivesRecipient,
            isBurningAllowed
        );
    }

    function claimLiquidityEmissions() external override returns (uint256 totalEmissions) {

        require(msg.sender == liquidityIncentivesRecipient, "NOT_INCENTIVES_RECIPIENT");
        totalEmissions = _mintLiquidityEmissions();
    }

    function _mintLiquidityEmissions() internal returns (uint256 totalEmissions) {

        uint256 _currentWeek = _getCurrentWeek();
        if (_currentWeek <= lastWeekEmissionSent) {
            return 0;
        }
        for (uint256 i = lastWeekEmissionSent + 1; i <= _currentWeek; i++) {
            if (i <= 259) {
                lastWeeklyEmission = lastWeeklyEmission.mul(emissionRateMultiplierNumerator).div(
                    CONFIG_DENOMINATOR
                );
            } else {
                lastWeeklyEmission = totalSupply.mul(terminalInflationRateNumerator).div(
                    CONFIG_DENOMINATOR
                );
            }
            _mint(liquidityIncentivesRecipient, lastWeeklyEmission);
            totalEmissions = totalEmissions.add(lastWeeklyEmission);
        }
        lastWeekEmissionSent = _currentWeek;
    }

    function _getCurrentWeek() internal view returns (uint256 weekId) {

        weekId = (block.timestamp - startTime) / (7 days) + 1;
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "MINT_TO_ZERO_ADDR");

        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "BURN_FROM_ZERO_ADDRESS");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "BURN_EXCEED_BALANCE");
        balances[account] = accountBalance.sub(amount);
        totalSupply = totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);
    }
}
