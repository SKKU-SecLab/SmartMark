



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
}




pragma solidity ^0.8.6;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}




pragma solidity ^0.8.6;

interface ICoFiXRouter {


    function registerPair(address token0, address token1, address pool) external;


    function pairFor(address token0, address token1) external view returns (address pool);


    function registerRouterPath(address src, address dest, address[] calldata path) external;


    function getRouterPath(address src, address dest) external view returns (address[] memory path);


    function addLiquidity(
        address pool,
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external payable returns (address xtoken, uint liquidity);


    function addLiquidityAndStake(
        address pool,
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external payable returns (address xtoken, uint liquidity);


    function removeLiquidityGetTokenAndETH(
        address pool,
        address token,
        uint liquidity,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountETH, uint amountToken);


    function swapExactTokensForTokens(
        address[] calldata path,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint amountOut);


    function getTradeReward(address xtoken) external view returns (uint);

}




pragma solidity ^0.8.6;

interface ICoFiXPool {



    

    function setConfig(uint16 theta, uint96 impactCostVOL, uint96 nt) external;


    function getConfig() external view returns (uint16 theta, uint96 impactCostVOL, uint96 nt);


    function mint(
        address token,
        address to, 
        uint amountETH, 
        uint amountToken,
        address payback
    ) external payable returns (
        address xtoken,
        uint liquidity
    );


    function burn(
        address token,
        address to, 
        uint liquidity, 
        address payback
    ) external payable returns (
        uint amountETHOut,
        uint amountTokenOut 
    );

    
    function swap(
        address src, 
        address dest, 
        uint amountIn, 
        address to, 
        address payback
    ) external payable returns (
        uint amountOut, 
        uint mined
    );


    function getXToken(address token) external view returns (address);

}




pragma solidity ^0.8.6;

interface ICoFiXVaultForStaking {


    function setConfig(uint cofiUnit) external;


    function getConfig() external view returns (uint cofiUnit);


    function batchSetPoolWeight(address[] calldata xtokens, uint[] calldata weights) external;


    function getChannelInfo(address xtoken) external view returns (uint totalStaked, uint cofiPerBlock);


    function balanceOf(address xtoken, address addr) external view returns (uint);


    function earned(address xtoken, address addr) external view returns (uint);


    function routerStake(address xtoken, address to, uint amount) external;

    
    function stake(address xtoken, uint amount) external;


    function withdraw(address xtoken, uint amount) external;


    function getReward(address xtoken) external;


    function calcReward(address xtoken) external view returns (
        uint newReward, 
        uint rewardPerToken
    );

}




pragma solidity ^0.8.6;

interface ICoFiXDAO {


    event ApplicationChanged(address addr, uint flag);
    
    struct Config {
        uint8 status;

        uint16 cofiPerBlock;

        uint32 cofiLimit;

        uint16 priceDeviationLimit;
    }

    function setConfig(Config calldata config) external;


    function getConfig() external view returns (Config memory);


    function setApplication(address addr, uint flag) external;


    function checkApplication(address addr) external view returns (uint);


    function setTokenExchange(address token, address target, uint exchange) external;


    function getTokenExchange(address token) external view returns (address target, uint exchange);


    function addETHReward(address pool) external payable;


    function totalETHRewards(address pool) external view returns (uint);


    function settle(address pool, address tokenAddress, address to, uint value) external payable;


    function redeem(uint amount, address payback) external payable;


    function redeemToken(address token, uint amount, address payback) external payable;


    function quotaOf() external view returns (uint);

}




pragma solidity ^0.8.6;

interface ICoFiXMapping {


    function setBuiltinAddress(
        address cofiToken,
        address cofiNode,
        address cofixDAO,
        address cofixRouter,
        address cofixController,
        address cofixVaultForStaking
    ) external;


    function getBuiltinAddress() external view returns (
        address cofiToken,
        address cofiNode,
        address cofixDAO,
        address cofixRouter,
        address cofixController,
        address cofixVaultForStaking
    );


    function getCoFiTokenAddress() external view returns (address);


    function getCoFiNodeAddress() external view returns (address);


    function getCoFiXDAOAddress() external view returns (address);


    function getCoFiXRouterAddress() external view returns (address);


    function getCoFiXControllerAddress() external view returns (address);


    function getCoFiXVaultForStakingAddress() external view returns (address);


    function registerAddress(string calldata key, address addr) external;


    function checkAddress(string calldata key) external view returns (address);

}




pragma solidity ^0.8.6;
interface ICoFiXGovernance is ICoFiXMapping {


    function setGovernance(address addr, uint flag) external;


    function getGovernance(address addr) external view returns (uint);


    function checkGovernance(address addr, uint flag) external view returns (bool);

}




pragma solidity ^0.8.6;
contract CoFiXBase {


    address constant COFI_TOKEN_ADDRESS = 0x1a23a6BfBAdB59fa563008c0fB7cf96dfCF34Ea1;

    address constant CNODE_TOKEN_ADDRESS = 0x558201DC4741efc11031Cdc3BC1bC728C23bF512;

    uint constant COFI_GENESIS_BLOCK = 11040688;

    address public _governance;

    function initialize(address governance) public virtual {

        require(_governance == address(0), "CoFiX:!initialize");
        _governance = governance;
    }

    function update(address newGovernance) public virtual {


        address governance = _governance;
        require(governance == msg.sender || ICoFiXGovernance(governance).checkGovernance(msg.sender, 0), "CoFiX:!gov");
        _governance = newGovernance;
    }

    function migrate(address tokenAddress, uint value) external onlyGovernance {


        address to = ICoFiXGovernance(_governance).getCoFiXDAOAddress();
        if (tokenAddress == address(0)) {
            ICoFiXDAO(to).addETHReward { value: value } (address(0));
        } else {
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    }


    modifier onlyGovernance() {

        require(ICoFiXGovernance(_governance).checkGovernance(msg.sender, 0), "CoFiX:!gov");
        _;
    }

    modifier noContract() {

        require(msg.sender == tx.origin, "CoFiX:!contract");
        _;
    }
}




pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.8.6;
contract CoFiToken is ERC20("CoFi Token", "CoFi") {

    address public governance;
    mapping (address => bool) public minters;


    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint nonce,uint expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    event NewGovernance(address _new);

    event MinterAdded(address _minter);

    event MinterRemoved(address _minter);

    modifier onlyGovernance() {
        require(msg.sender == governance, "CoFi: !governance");
        _;
    }

    constructor() {
        governance = msg.sender;
    }

    function setGovernance(address _new) external onlyGovernance {
        require(_new != address(0), "CoFi: zero addr");
        require(_new != governance, "CoFi: same addr");
        governance = _new;
        emit NewGovernance(_new);
    }

    function addMinter(address _minter) external onlyGovernance {
        minters[_minter] = true;
        emit MinterAdded(_minter);
    }

    function removeMinter(address _minter) external onlyGovernance {
        minters[_minter] = false;
        emit MinterRemoved(_minter);
    }

    function mint(address _to, uint _amount) external {
        require(minters[msg.sender], "CoFi: !minter");
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function transfer(address _recipient, uint _amount) public override returns (bool) {
        super.transfer(_recipient, _amount);
        _moveDelegates(_delegates[msg.sender], _delegates[_recipient], _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint _amount) public override returns (bool) {
        super.transferFrom(_sender, _recipient, _amount);
        _moveDelegates(_delegates[_sender], _delegates[_recipient], _amount);
        return true;
    }

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CoFi::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CoFi::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "CoFi::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint)
    {
        require(blockNumber < block.number, "CoFi::getPriorVotes: not yet determined");

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

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint delegatorBalance = balanceOf(delegator); // balance of underlying CoFis (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint srcRepNew = srcRepOld - (amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint dstRepNew = dstRepOld + (amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint oldVotes,
        uint newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "CoFi::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}




pragma solidity ^0.8.6;
contract CoFiXRouter is CoFiXBase, ICoFiXRouter {


    address _cofixVaultForStaking;

    mapping(bytes32=>address) _pairs;

    mapping(bytes32=>address[]) _paths;

    uint _cnodeReward;

    constructor () {
    }

    modifier ensure(uint deadline) {
        require(block.timestamp <= deadline, "CoFiXRouter: EXPIRED");
        _;
    }

    function update(address newGovernance) public override {
        super.update(newGovernance);
        _cofixVaultForStaking = ICoFiXGovernance(newGovernance).getCoFiXVaultForStakingAddress();
    }

    function registerPair(address token0, address token1, address pool) public override onlyGovernance {
        _pairs[_getKey(token0, token1)] = pool;
    }

    function pairFor(address token0, address token1) external view override returns (address pool) {
        return _pairFor(token0, token1);
    }

    function registerRouterPath(address src, address dest, address[] calldata path) external override onlyGovernance {
        require(src == path[0], "CoFiXRouter: first token error");
        require(dest == path[path.length - 1], "CoFiXRouter: last token error");
        _paths[_getKey(src, dest)] = path;
    }

    function getRouterPath(address src, address dest) external view override returns (address[] memory path) {
        path = _paths[_getKey(src, dest)];
        uint j = path.length;

        require(j > 0, "CoFiXRouter: path not exist");
        if (src == path[--j] && dest == path[0]) {
            for (uint i = 0; i < j;) {
                address tmp = path[i];
                path[i++] = path[j];
                path[j--] = tmp;
            }
        } else {
            require(src == path[0] && dest == path[j], "CoFiXRouter: path error");
        }
    }
    
    function _pairFor(address token0, address token1) private view returns (address pool) {
        return _pairs[_getKey(token0, token1)];
    }

    function _getKey(address token0, address token1) private pure returns (bytes32) {
        (token0, token1) = _sort(token0, token1);
        return keccak256(abi.encodePacked(token0, token1));
    }

    function _sort(address token0, address token1) private pure returns (address min, address max) {
        if (token0 < token1) {
            min = token0;
            max = token1;
        } else {
            min = token1;
            max = token0;
        }
    }

    function addLiquidity(
        address pool,
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external payable override ensure(deadline) returns (address xtoken, uint liquidity) {
        if (token != address(0)) {
            TransferHelper.safeTransferFrom(token, msg.sender, pool, amountToken);
        }

        (xtoken, liquidity) = ICoFiXPool(pool).mint { 
            value: msg.value 
        } (token, to, amountETH, amountToken, to);

        require(liquidity >= liquidityMin, "CoFiXRouter: less liquidity than expected");
    }

    function addLiquidityAndStake(
        address pool,
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external payable override ensure(deadline) returns (address xtoken, uint liquidity) {
        if (token != address(0)) {
            TransferHelper.safeTransferFrom(token, msg.sender, pool, amountToken);
        }

        address cofixVaultForStaking = _cofixVaultForStaking;
        (xtoken, liquidity) = ICoFiXPool(pool).mint { 
            value: msg.value 
        } (token, address(this), amountETH, amountToken, to);

        require(liquidity >= liquidityMin, "CoFiXRouter: less liquidity than expected");

        ICoFiXVaultForStaking(cofixVaultForStaking).routerStake(xtoken, to, liquidity);
        TransferHelper.safeTransfer(xtoken, cofixVaultForStaking, liquidity);
    }

    function removeLiquidityGetTokenAndETH(
        address pool,
        address token,
        uint liquidity,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable override ensure(deadline) returns (uint amountETH, uint amountToken) {
        address xtoken = ICoFiXPool(pool).getXToken(token);

        TransferHelper.safeTransferFrom(xtoken, msg.sender, pool, liquidity);

        (amountETH, amountToken) = ICoFiXPool(pool).burn {
            value: msg.value
        } (token, to, liquidity, to);

        require(amountETH >= amountETHMin, "CoFiXRouter: less eth than expected");
    }

    function swapExactTokensForTokens(
        address[] calldata path,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable override ensure(deadline) returns (uint amountOut) {
        uint mined;
        if (path.length == 2) {
            address src = path[0];
            address dest = path[1];

            address pool = _pairFor(src, dest);

            if (src != address(0)) {
                TransferHelper.safeTransferFrom(src, msg.sender, pool, amountIn);
            }

            (amountOut, mined) = ICoFiXPool(pool).swap {
                value: msg.value
            } (src, dest, amountIn, to, to);
        } else {
            (amountOut, mined) = _swap(path, amountIn, to);

            uint balance = address(this).balance;
            if (balance > 0) {
                payable(to).transfer(balance);
            } 
        }

        require(amountOut >= amountOutMin, "CoFiXRouter: got less than expected");
        
        _mint(mined, rewardTo);
    }

    function _swap(
        address[] calldata path,
        uint amountIn,
        address to
    ) private returns (
        uint amountOut, 
        uint totalMined
    ) {
        totalMined = 0;
        
        address token0 = path[0];
        address token1 = path[1];
        address pool = _pairFor(token0, token1);
        if (token0 != address(0)) {
            TransferHelper.safeTransferFrom(token0, to, pool, amountIn);
        }

        uint mined;
        for (uint i = 1; ; ) {
            address recv = to;

            address next = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
            if (++i < path.length) {
                next = path[i];
                recv = _pairFor(token1, next);
            }

            (amountIn, mined) = ICoFiXPool(pool).swap {
                value: address(this).balance
            } (token0, token1, amountIn, token1 == address(0) ? address(this) : recv, address(this));

            totalMined += mined;

            if (next == 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF) {
                break;
            }

            token0 = token1;
            token1 = next;
            pool = recv;
        }

        amountOut = amountIn;
    }

    function _mint(uint mined, address rewardTo) private {
        if (mined > 0) {
            uint cnodeReward = mined / 10;
            CoFiToken(COFI_TOKEN_ADDRESS).mint(rewardTo, mined - cnodeReward);
            _cnodeReward += cnodeReward;
        }
    }

    function getTradeReward(address xtoken) external view override returns (uint) {
        if (xtoken == CNODE_TOKEN_ADDRESS) {
            return _cnodeReward;
        }
        return 0;
    }

    receive() external payable {
    }
}