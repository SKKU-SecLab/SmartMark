



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

interface ICoFiXPool {



    event Mint(address token, address to, uint amountETH, uint amountToken, uint liquidity);
    
    event Burn(address token, address to, uint liquidity, uint amountETHOut, uint amountTokenOut);

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
interface ICoFiXPair is ICoFiXPool {


    event SwapForToken(uint amountIn, address to, uint amountTokenOut, uint mined);

    event SwapForETH(uint amountIn, address to, uint amountETHOut, uint mined);

    function getInitialAssetRatio() external view returns (uint initToken0Amount, uint initToken1Amount);


    function estimate(
        uint newBalance0, 
        uint newBalance1, 
        uint ethAmount, 
        uint tokenAmount
    ) external view returns (uint mined);

    
    function settle() external;


    function ethBalance() external view returns (uint);


    function totalFee() external view returns (uint);

    
    function getNAVPerShare(
        uint ethAmount, 
        uint tokenAmount
    ) external view returns (uint navps);


    function impactCostForBuyInETH(uint vol) external view returns (uint impactCost);


    function impactCostForSellOutETH(uint vol) external view returns (uint impactCost);

}




pragma solidity ^0.8.6;

interface INestPriceFacade {

    







    function latestPrice(address tokenAddress, address payback) external payable returns (uint blockNumber, uint price);



    function latestPriceAndTriggeredPriceInfo(address tokenAddress, address payback) 
    external 
    payable 
    returns (
        uint latestPriceBlockNumber, 
        uint latestPriceValue,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );


    function lastPriceListAndTriggeredPriceInfo(
        address tokenAddress, 
        uint count, 
        address payback
    ) external payable 
    returns (
        uint[] memory prices,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );




}




pragma solidity ^0.8.6;
interface ICoFiXController {



    function queryPrice(
        address tokenAddress,
        address payback
    ) external payable returns (
        uint ethAmount, 
        uint tokenAmount, 
        uint blockNumber
    );


    function queryOracle(
        address tokenAddress,
        address payback
    ) external payable returns (
        uint k, 
        uint ethAmount, 
        uint tokenAmount, 
        uint blockNumber
    );

    
    function calcRevisedK(uint sigmaSQ, uint p0, uint bn0, uint p, uint bn) external view returns (uint k);


    function latestPriceInfo(address tokenAddress, address payback) 
    external 
    payable 
    returns (
        uint blockNumber, 
        uint priceEthAmount,
        uint priceTokenAmount,
        uint avgPriceEthAmount,
        uint avgPriceTokenAmount,
        uint sigmaSQ
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

    function initialize(address governance) virtual public {

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

interface ICoFiXERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);


}




pragma solidity ^0.8.6;
contract CoFiXERC20 is ICoFiXERC20 {

    uint8 public override constant decimals = 18;
    uint  public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;



    constructor() {
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply + (value);
        balanceOf[to] = balanceOf[to] + (value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from] - (value);
        totalSupply = totalSupply - (value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from] - (value);
        balanceOf[to] = balanceOf[to] + (value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
           allowance[from][msg.sender] = allowance[from][msg.sender] - (value);
        }
        _transfer(from, to, value);
        return true;
    }

}




pragma solidity ^0.8.6;
contract CoFiXPair is CoFiXBase, CoFiXERC20, ICoFiXPair {


    uint constant MINIMUM_LIQUIDITY = 1e9; 

    address _tokenAddress; 
    uint48 _initToken0Amount;
    uint48 _initToken1Amount;

    string public name;
    
    string public symbol;

    address _cofixDAO;
    uint96 _nt;

    address _cofixRouter;
    bool _locked;
    uint16 _theta;
    uint72 _totalFee;

    address _cofixController;
    uint96 _impactCostVOL;

    uint112 _Y;
    uint112 _D;
    uint32 _lastblock;

    constructor() {
    }

    function init(
        address governance,
        string calldata name_, 
        string calldata symbol_, 
        address tokenAddress, 
        uint48 initToken0Amount, 
        uint48 initToken1Amount
    ) external {
        super.initialize(governance);
        name = name_;
        symbol = symbol_;
        _tokenAddress = tokenAddress;
        _initToken0Amount = initToken0Amount;
        _initToken1Amount = initToken1Amount;
    }

    modifier check() {
        require(_cofixRouter == msg.sender, "CoFiXPair: Only for CoFiXRouter");
        require(!_locked, "CoFiXPair: LOCKED");
        _locked = true;
        _;
        _locked = false;
    }

    function setConfig(uint16 theta, uint96 impactCostVOL, uint96 nt) external override onlyGovernance {
        _theta = theta;
        _impactCostVOL = impactCostVOL;
        _nt = nt;
    }

    function getConfig() external override view returns (uint16 theta, uint96 impactCostVOL, uint96 nt) {
        return (_theta, _impactCostVOL, _nt);
    }

    function getInitialAssetRatio() public override view returns (
        uint initToken0Amount, 
        uint initToken1Amount
    ) {
        return (uint(_initToken0Amount), uint(_initToken1Amount));
    }

    function update(address newGovernance) public override {
        super.update(newGovernance);
        (
            ,//cofiToken,
            ,//cofiNode,
            _cofixDAO,
            _cofixRouter,
            _cofixController,
        ) = ICoFiXGovernance(newGovernance).getBuiltinAddress();
    }

    function mint(
        address token,
        address to,
        uint amountETH, 
        uint amountToken,
        address payback
    ) external payable override check returns (
        address xtoken,
        uint liquidity
    ) {
        require(token == _tokenAddress, "CoFiXPair: invalid token address");
        uint initToken0Amount = uint(_initToken0Amount);
        uint initToken1Amount = uint(_initToken1Amount);
        require(amountETH * initToken1Amount == amountToken * initToken0Amount, "CoFiXPair: invalid asset ratio");

        uint total = totalSupply;
        if (total > 0) {
            (
                ,//uint blockNumber, 
                uint ethAmount,
                uint tokenAmount,
                ,//uint avgPriceEthAmount,
                ,//uint avgPriceTokenAmount,
            ) = ICoFiXController(_cofixController).latestPriceInfo { 
                value: msg.value - amountETH
            } (
                token,
                payback
            );

            uint balance0 = ethBalance();
            uint balance1 = IERC20(token).balanceOf(address(this));

            liquidity = amountETH * total / _calcTotalValue(

                balance0 - amountETH, 
                balance1 - amountToken,
                ethAmount, 
                tokenAmount,
                initToken0Amount,
                initToken1Amount
            );

            _updateMiningState(balance0, balance1, ethAmount, tokenAmount);
        } else {
            payable(payback).transfer(msg.value - amountETH);
            liquidity = amountETH - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); 
        }

        _mint(to, liquidity);
        xtoken = address(this);
        emit Mint(token, to, amountETH, amountToken, liquidity);
    }

    function burn(
        address token,
        address to, 
        uint liquidity, 
        address payback
    ) external payable override check returns (
        uint amountETHOut,
        uint amountTokenOut 
    ) { 
        require(token == _tokenAddress, "CoFiXPair: invalid token address");
        (
            ,//uint blockNumber, 
            uint ethAmount,
            uint tokenAmount,
            ,//uint avgPriceEthAmount,
            ,//uint avgPriceTokenAmount,
        ) = ICoFiXController(_cofixController).latestPriceInfo { 
            value: msg.value 
        } (
            token,
            payback
        );

        uint balance0 = ethBalance();
        uint balance1 = IERC20(token).balanceOf(address(this));
        uint navps = 1 ether;
        uint total = totalSupply;
        uint initToken0Amount = uint(_initToken0Amount);
        uint initToken1Amount = uint(_initToken1Amount);
        if (total > 0) {
            navps = _calcTotalValue(
                balance0, 
                balance1, 
                ethAmount, 
                tokenAmount,
                initToken0Amount,
                initToken1Amount
            ) * 1 ether / total;
        }

        amountETHOut = navps * liquidity / 1 ether;
        amountTokenOut = amountETHOut * initToken1Amount / initToken0Amount;

        _burn(address(this), liquidity);

        if (amountETHOut > balance0) {
            amountTokenOut += (amountETHOut - balance0) * tokenAmount / ethAmount;
            amountETHOut = balance0;
        } 
        else if (amountTokenOut > balance1) {
            amountETHOut += (amountTokenOut - balance1) * ethAmount / tokenAmount;
            amountTokenOut = balance1;
        }

        payable(to).transfer(amountETHOut);
        TransferHelper.safeTransfer(token, to, amountTokenOut);

        emit Burn(token, to, liquidity, amountETHOut, amountTokenOut);

        _updateMiningState(balance0 - amountETHOut, balance1 - amountTokenOut, ethAmount, tokenAmount);
    }

    function swap(
        address src, 
        address dest, 
        uint amountIn, 
        address to, 
        address payback
    ) external payable override check returns (
        uint amountOut, 
        uint mined
    ) {
        address token = _tokenAddress;
        if (src == address(0) && dest == token) {
            (amountOut, mined) =  _swapForToken(token, amountIn, to, payback);
        } else if (src == token && dest == address(0)) {
            (amountOut, mined) = _swapForETH(token, amountIn, to, payback);
        } else {
            revert("CoFiXPair: pair error");
        }
    }

    function _swapForToken(
        address token,
        uint amountIn, 
        address to, 
        address payback
    ) private returns (
        uint amountTokenOut, 
        uint mined
    ) {
        (
            uint k, 
            uint ethAmount, 
            uint tokenAmount, 
        ) = ICoFiXController(_cofixController).queryOracle { 
            value: msg.value  - amountIn
        } (
            token,
            payback
        );

        uint fee = amountIn * uint(_theta) / 10000;
        amountTokenOut = (amountIn - fee) * tokenAmount * 1 ether / ethAmount / (
            1 ether + k + _impactCostForSellOutETH(amountIn, uint(_impactCostVOL))
        );

        fee = _collect(fee);

        mined = _cofiMint(_calcD(
            address(this).balance - fee, 
            IERC20(token).balanceOf(address(this)) - amountTokenOut, 
            ethAmount, 
            tokenAmount
        ), uint(_nt));
        
        TransferHelper.safeTransfer(token, to, amountTokenOut);

        emit SwapForToken(amountIn, to, amountTokenOut, mined);
    }

    function _swapForETH(
        address token,
        uint amountIn, 
        address to, 
        address payback
    ) private returns (
        uint amountETHOut, 
        uint mined
    ) {
        (
            uint k, 
            uint ethAmount, 
            uint tokenAmount, 
        ) = ICoFiXController(_cofixController).queryOracle { 
            value: msg.value
        } (
            token,
            payback
        );

        amountETHOut = amountIn * ethAmount / tokenAmount;
        amountETHOut = amountETHOut * 1 ether / (
            1 ether + k + _impactCostForBuyInETH(amountETHOut, uint(_impactCostVOL))
        ); 

        uint fee = amountETHOut * uint(_theta) / 10000;
        amountETHOut = amountETHOut - fee;

        fee = _collect(fee);

        mined = _cofiMint(_calcD(
            address(this).balance - fee - amountETHOut, 
            IERC20(token).balanceOf(address(this)), 
            ethAmount, 
            tokenAmount
        ), uint(_nt));

        payable(to).transfer(amountETHOut);

        emit SwapForETH(amountIn, to, amountETHOut, mined);
    }

    function _updateMiningState(uint balance0, uint balance1, uint ethAmount, uint tokenAmount) private {
        uint D1 = _calcD(
            balance0, //ethBalance(), 
            balance1, //IERC20(token).balanceOf(address(this)), 
            ethAmount, 
            tokenAmount
        );

        uint D0 = uint(_D);
        uint Y = uint(_Y) + D0 * uint(_nt) * (block.number - uint(_lastblock)) / 1 ether;

        _Y = uint112(Y);
        _D = uint112(D1);
        _lastblock = uint32(block.number);
    }

    function _calcD(
        uint balance0, 
        uint balance1, 
        uint ethAmount, 
        uint tokenAmount
    ) private view returns (uint) {
        uint initToken0Amount = uint(_initToken0Amount);
        uint initToken1Amount = uint(_initToken1Amount);

        uint left = balance0 * initToken1Amount;
        uint right = balance1 * initToken0Amount;
        uint numerator;
        if (left > right) {
            numerator = left - right;
        } else {
            numerator = right - left;
        }
        
        return numerator * ethAmount / (
            ethAmount * initToken1Amount + tokenAmount * initToken0Amount
        );
    }

    function _cofiMint(uint D1, uint nt) private returns (uint mined) {
        uint D0 = uint(_D);
        uint Y = uint(_Y) + D0 * nt * (block.number - uint(_lastblock)) / 1 ether;
        if (D0 > D1) {
            mined = Y * (D0 - D1) / D0;
            Y = Y - mined;
        }

        _Y = uint112(Y);
        _D = uint112(D1);
        _lastblock = uint32(block.number);
    }

    function estimate(
        uint newBalance0, 
        uint newBalance1, 
        uint ethAmount, 
        uint tokenAmount
    ) external view override returns (uint mined) {
        uint D1 = _calcD(newBalance0, newBalance1, ethAmount, tokenAmount);
        uint D0 = uint(_D);
        if (D0 > D1) {
            uint Y = uint(_Y) + D0 * uint(_nt) * (block.number - uint(_lastblock)) / 1 ether;
            mined = Y * (D0 - D1) / D0;
        }
    }

    function _collect(uint fee) private returns (uint total) {
        total = uint(_totalFee) + fee;
        if (total >= 1 ether) {
            ICoFiXDAO(_cofixDAO).addETHReward { value: total } (address(this));
            total = 0;
        } 
        _totalFee = uint72(total);
    }

    function settle() external override {
        ICoFiXDAO(_cofixDAO).addETHReward { value: uint(_totalFee) } (address(this));
        _totalFee = uint72(0);
    }

    function ethBalance() public view override returns (uint) {
        return address(this).balance - uint(_totalFee);
    }

    function totalFee() external view override returns (uint) {
        return uint(_totalFee);
    }

    function getNAVPerShare(
        uint ethAmount, 
        uint tokenAmount
    ) external view override returns (uint navps) {
        uint total = totalSupply;
        if (total > 0) {
            return _calcTotalValue(
                ethBalance(), 
                IERC20(_tokenAddress).balanceOf(address(this)), 
                ethAmount, 
                tokenAmount,
                _initToken0Amount,
                _initToken1Amount
            ) * 1 ether / total;
        }
        return 1 ether;
    }

    function _calcTotalValue(
        uint balance0, 
        uint balance1, 
        uint ethAmount, 
        uint tokenAmount,
        uint initToken0Amount,
        uint initToken1Amount
    ) private pure returns (uint totalValue) {
        totalValue = (
            balance0 * tokenAmount 
            + balance1 * ethAmount
        ) * initToken0Amount / (
            initToken0Amount * tokenAmount 
            + initToken1Amount * ethAmount
        );
    }


    function _impactCostForBuyInETH(uint vol, uint impactCostVOL) private pure returns (uint impactCost) {
        if (vol >= impactCostVOL) {
            impactCost = vol / 1000;
        }
    }

    function _impactCostForSellOutETH(uint vol, uint impactCostVOL) private pure returns (uint impactCost) {
        if (vol >= impactCostVOL) {
            impactCost = vol / 1000;
        }
    }

    function impactCostForBuyInETH(uint vol) public view override returns (uint impactCost) {
        return _impactCostForBuyInETH(vol, uint(_impactCostVOL));
    }

    function impactCostForSellOutETH(uint vol) public view override returns (uint impactCost) {
        return _impactCostForSellOutETH(vol, uint(_impactCostVOL));
    }

    function getXToken(address token) external view override returns (address) {
        if (token == _tokenAddress) {
            return address(this);
        }
        return address(0);
    }
}