

pragma solidity =0.6.12;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract ERC20BurnableMaxSupply is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        if (_totalSupply.add(amount) > 13e21) {
            amount = uint256(13e21).sub(_totalSupply);

            if (amount == 0)
                return;
        }

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract Administrable is Context {
    address private _admin;

    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    constructor () internal {
        address msgSender = _msgSender();
        _admin = msgSender;
        emit AdminTransferred(address(0), msgSender);
    }

    function admin() public view returns (address) {
        return _admin;
    }

    modifier onlyAdmin() {
        require(_admin == _msgSender(), "Administrable: caller is not the admin");
        _;
    }

    function renounceAdmin() public virtual onlyAdmin {
        emit AdminTransferred(_admin, address(0));
        _admin = address(0);
    }

    function transferAdmin(address newAdmin) public virtual onlyAdmin {
        require(newAdmin != address(0), "Administrable: new admin is the zero address");
        emit AdminTransferred(_admin, newAdmin);
        _admin = newAdmin;
    }
}

abstract contract ERC20Payable {

    event Received(address indexed sender, uint256 amount);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}

interface ISecondaryToken {

    function mint(
        address account,
        uint256 amount
    ) external;
}

interface IProtocolAdapter {
    function getBurnDivisor(address _user, uint256 _currentBurnDivisor) external view returns (uint256);

    function getRewardsMultiplier(address _user, uint256 _currentRewardsMultiplier) external view returns (uint256);
}

abstract contract ERC20Burnable is Context, ERC20BurnableMaxSupply {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
}

contract BooBankerResearchAssociation is ERC20BurnableMaxSupply("BooBanker Research Association", "BBRA"), ERC20Burnable, Ownable, Administrable, ERC20Payable {
    using SafeMath for uint256;

    address public uniswapV2Router;
    address public uniswapV2Pair;
    address public uniswapV2Factory;

    uint256 public burnDivisor;
    uint256 public liquidityDivisor;

    ISecondaryToken public burnToken;

    IProtocolAdapter public protocolAdapter;

    bool public rewardLiquidityLockCaller;

    bool public canPause;
    uint256 public pauseUntilBlock;

    uint256 public lastLiquidityLock;

    address public _devaddr;

    event LiquidityLock(uint256 tokenAmount, uint256 ethAmount);
    event LiquidityBurn(uint256 lpTokenAmount);
    event CallerReward(address caller, uint256 tokenAmount);
    event BuyBack(uint256 ethAmount, uint256 tokenAmount);
    event ProtocolAdapterChange(address _newProtocol);

    constructor(uint256 _burnDivisor, uint256 _liquidityDivisor) public {

        burnDivisor = _burnDivisor;
        liquidityDivisor = _liquidityDivisor;
        _devaddr = msg.sender;
        rewardLiquidityLockCaller = true;
        canPause = true;
        _mint(msg.sender, 13e21);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public checkRunning virtual override returns (bool) {
        uint256 onePct = amount.div(100);
        uint256 liquidityAmount = amount.div(liquidityDivisor);
        uint256 burnAmount = amount.div(
            ( address(protocolAdapter) != address(0)
                ? protocolAdapter.getBurnDivisor(pickHuman(sender, recipient), burnDivisor)
                : burnDivisor
            )
        );

        _burn(sender, burnAmount);

        if(address(burnToken) != address(0)) {
            burnToken.mint(recipient, burnAmount);
        }

        super.transferFrom(sender, _devaddr, onePct);
        super.transferFrom(sender, address(this), liquidityAmount);
        return super.transferFrom(sender, recipient, amount.sub(burnAmount).sub(liquidityAmount).sub(onePct));
    }

    function transfer(address recipient, uint256 amount) public checkRunning virtual override returns (bool) {
        uint256 onePct = amount.div(100);
        uint256 liquidityAmount = amount.div(liquidityDivisor);
        uint256 burnAmount = amount.div(
            ( address(protocolAdapter) != address(0)
                ? protocolAdapter.getBurnDivisor(pickHuman(msg.sender, recipient), burnDivisor)
                : burnDivisor
            )
        );

        _burn(msg.sender, burnAmount);

        if(address(burnToken) != address(0)) {
            burnToken.mint(recipient, burnAmount);
        }

        super.transfer(_devaddr, onePct);
        super.transfer(address(this), liquidityAmount);
        return super.transfer(recipient, amount.sub(burnAmount).sub(liquidityAmount).sub(onePct));
    }

    function pickHuman(address _from, address _to) public view returns (address) {
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_from)}
        return _codeLength == 0 ? _from : _to;
    }

    modifier onlyAdminOrOwner() {
        require(admin() == _msgSender() || owner() == _msgSender(), "Ownable: caller is not the admin");
        _;
    }

    modifier checkRunning(){
        require(block.number > pauseUntilBlock, "Go away bot");
        _;
    }

    function setPauseUntilBlock(uint256 _pauseUntilBlock) public onlyAdminOrOwner {
        require(canPause || _pauseUntilBlock == 0, 'Pause has already been used once. If disabling pause set block to 0');
        pauseUntilBlock = _pauseUntilBlock;
        canPause = false;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");
        _;
    }

    function lockLiquidity() public isHuman() {
        uint256 _bal = balanceOf(address(this));
        require(uniswapV2Pair != address(0), "UniswapV2Pair not set in contract yet");
        require(uniswapV2Router != address(0), "UniswapV2Router not set in contract yet");
        require(_bal >= 1e18, "Minimum of 1 BBRA before we can lock liquidity");
        require(balanceOf(msg.sender) >= 5e18, "You must own at least 5 BBra to call lock");

        uint256 _callerReward = 0;
        if (rewardLiquidityLockCaller) {
            _callerReward = _bal.div(50);
            _bal = _bal.sub(_callerReward);
        }

        uint256 bbraToEth = _bal.div(2);
        uint256 brraForLiq = _bal.sub(bbraToEth);

        uint256 startingBalance = address(this).balance;
        swapTokensForWeth(bbraToEth);

        uint256 ethFromBbra = address(this).balance.sub(startingBalance);
        addLiquidity(brraForLiq, ethFromBbra);

        emit LiquidityLock(brraForLiq, ethFromBbra);

        if (_callerReward != 0) {
            if(balanceOf(address(this)) >= _callerReward) {
                transfer(msg.sender, _callerReward);
            } else {
                transfer(msg.sender, balanceOf(address(this)));
            }
        }

        lastLiquidityLock = block.timestamp;
    }



    function swapTokensForWeth(uint256 tokenAmount) internal {
        address[] memory uniswapPairPath = new address[](2);
        uniswapPairPath[0] = address(this);
        uniswapPairPath[1] = IUniswapV2Router02(uniswapV2Router).WETH();

        _approve(address(this), uniswapV2Router, tokenAmount);

        IUniswapV2Router02(uniswapV2Router)
        .swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            uniswapPairPath,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), uniswapV2Router, tokenAmount);

        IUniswapV2Router02(uniswapV2Router)
        .addLiquidityETH{
            value: ethAmount
        }(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );

        uint256 _lpBalance = IERC20(uniswapV2Pair).balanceOf(address(this));
        if (_lpBalance != 0) {
            IERC20(uniswapV2Pair).transfer(address(0), _lpBalance);
            payable(_devaddr).transfer(address(this).balance);
            emit LiquidityBurn(_lpBalance);
        }
    }

    function lockedLpAmount() public view returns(uint256) {
        if (uniswapV2Pair == address(0)) {
            return 0;
        }

        return IERC20(uniswapV2Pair).balanceOf(address(0));
    }

    function setRewardLiquidityLockCaller(bool _rewardLiquidityLockCaller) public onlyAdminOrOwner {
        rewardLiquidityLockCaller = _rewardLiquidityLockCaller;
    }

    function setSecondaryBurnToken(ISecondaryToken _token) public onlyAdminOrOwner {
        require(address(_token) != address(this), 'Secondary token cannot be itself');
        burnToken = _token;
    }

    function setProtocolAdapter(IProtocolAdapter _contract) public onlyAdminOrOwner {
        protocolAdapter = _contract;
        emit ProtocolAdapterChange(address(_contract));
    }

    function setBurnRate(uint256 _burnDivisor) public onlyAdminOrOwner {
        require(_burnDivisor != 0, "Boo: burnDivisor must be bigger than 0");
        burnDivisor = _burnDivisor;
    }

    function setLiquidityDivisor(uint256 _liquidityDivisor) public onlyAdminOrOwner {
        require(_liquidityDivisor != 0, "Boo: _liquidityDivisor must be bigger than 0");
        liquidityDivisor = _liquidityDivisor;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function setDevAddr(address _dev) public onlyOwner {
        _devaddr = _dev;
    }

    function setUniswapAddresses(address _uniswapV2Factory, address _uniswapV2Router) public onlyAdminOrOwner {
        require(_uniswapV2Factory != address(0) && _uniswapV2Router != address(0), 'Uniswap addresses cannot be empty');
        uniswapV2Factory = _uniswapV2Factory;
        uniswapV2Router = _uniswapV2Router;

        if (uniswapV2Pair == address(0)) {
            createUniswapPair();
        }
    }

    function createUniswapPair() public {
        require(uniswapV2Pair == address(0), "Pair has already been created");
        require(uniswapV2Factory != address(0) && uniswapV2Router != address(0), "Uniswap addresses have not been set");

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Factory).createPair(
                IUniswapV2Router02(uniswapV2Router).WETH(),
                address(this)
        );
    }


    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

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
        require(signatory != address(0), "BOOB::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "BOOB::delegateBySig: invalid nonce");
        require(now <= expiry, "BOOB::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
    external
    view
    returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
    external
    view
    returns (uint256)
    {
        require(blockNumber < block.number, "BOOB::getPriorVotes: not yet determined");

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
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying BOOBs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
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
    )
    internal
    {
        uint32 blockNumber = safe32(block.number, "BOOB::_writeCheckpoint: block number exceeds 32 bits");

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

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}