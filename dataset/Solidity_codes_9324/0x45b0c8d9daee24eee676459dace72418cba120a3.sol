
pragma solidity 0.6.12;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(
            msg.sender == nominatedOwner,
            "You must be nominated before you can accept ownership"
        );
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(
            msg.sender == owner,
            "Only the contract owner may perform this action"
        );
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

abstract contract Pausable is Owned {
    uint256 public lastPauseTime;
    bool public paused;

    constructor() internal {
        require(owner != address(0), "Owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }

        paused = _paused;

        if (paused) {
            lastPauseTime = now;
        }

        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(
            !paused,
            "This action cannot be performed while the contract is paused"
        );
        _;
    }
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20Lib {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

contract ERC20Lib is Context, IERC20Lib {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
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

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

library SafeERC20Lib {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20Lib token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20Lib token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20Lib token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20Lib token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20Lib token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20Lib token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IUSDv is IERC20Lib {
    function mint(address, uint256) external;

    function burn(address, uint256) external;
}


contract VoxSwapPlatform is ReentrancyGuard, Pausable {
    using SafeERC20Lib for IERC20Lib;
    using Address for address;
    using SafeMath for uint256;

    IUSDv internal usdv;
    IERC20Lib internal vox;

    address private usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private tusd = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address private susd = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;

    address[4] public coins;
    uint256[4] public decimals;
    uint256[4] public balances;
    uint256[4] public fees;

    uint256 public minimumVoxBalance = 0;
    uint256 public voxHolderDiscount = 25;

    uint256 public swapFee = 35;
    uint256 public swapFeeMax = 40;
    uint256 public swapFeeBase = 100000;

    uint256 public redeemFee = 15;
    uint256 public redeemFeeMax = 30;
    uint256 public redeemFeeBase = 100000;

    address public treasury;
    address public admin;

    uint256 private _redeemFees;
    mapping(address => uint8) private _supported;
    mapping(address => uint256) private _minted;
    mapping(address => uint256) private _redeemed;
    mapping(address => uint256) private _depositedAt;


    constructor(
        address _owner,
        address _usdv,
        address _vox
    ) public Owned(_owner) {
        usdv = IUSDv(_usdv);
        vox = IERC20Lib(_vox);

        coins[0] = usdc;
        coins[1] = usdt;
        coins[2] = tusd;
        coins[3] = susd;

        decimals[0] = 6;
        decimals[1] = 6;
        decimals[2] = 18;
        decimals[3] = 18;

        _supported[usdc] = 1;
        _supported[usdt] = 2;
        _supported[tusd] = 3;
        _supported[susd] = 4;
    }


    function shares() public view returns (uint256[4] memory _shares) {
        uint256[4] memory basket;
        uint256 total;

        for(uint256 i = 0; i < coins.length; i++) {
            uint256 balance = balanceOf(i);
            uint256 delta = uint256(18).sub(decimals[i]);
            basket[i] = balance.mul(10 ** delta);
            total = total.add(balance.mul(10 ** delta));
        }

        for(uint256 i = 0; i < basket.length; i++) {
            _shares[i] = basket[i].mul(1e18).div(total);
        }

        return _shares;
    }

    function mintedOf(address account) external view returns (uint256) {
        return _minted[account];
    }

    function redeemedOf(address account) external view returns (uint256) {
        return _redeemed[account];
    }

    function balanceOf(uint256 index) public view returns (uint256) {
        return balances[index];
    }


    function mint(uint256[4] memory amounts)
        external
        nonReentrant
        notPaused 
    {
        require(vox.balanceOf(msg.sender) > minimumVoxBalance, '!vox');
        _mint(amounts);
    }

    function _mint(uint256[4] memory amounts)
        internal
    {
        uint256 toMint;

        for(uint256 i = 0; i < coins.length; i++) {
            uint256 amount = amounts[i];
            if (amount > 0) {
                IERC20Lib token = IERC20Lib(coins[i]);
                require(token.balanceOf(msg.sender) >= amount, '!balance');
                token.safeTransferFrom(msg.sender, address(this), amount);

                uint256 delta = uint256(18).sub(decimals[i]);
                uint256 usdvAmount = amount.mul(10 ** delta);
                balances[i] = balances[i].add(amount);
                toMint = toMint.add(usdvAmount);
            }
        }

        if (toMint > 0) {
            _minted[msg.sender] = _minted[msg.sender].add(toMint);
            usdv.mint(msg.sender, toMint);
            _depositedAt[msg.sender] = block.number;
            emit Minted(msg.sender, toMint);
        }
    }

    function swap(address _from, address _to, uint256 amount)
        external
        nonReentrant
        notPaused 
    {
        require(amount > 0, '!amount');
        require(_supported[_from] > 0, '!from');
        require(_supported[_to] > 0, '!to');
        require(_to != address(usdv), '!usdv');

        IERC20Lib from = IERC20Lib(_from);
        IERC20Lib to = IERC20Lib(_to);
        require(from.balanceOf(msg.sender) >= amount, '!balance');

        uint256 indexFrom = _supported[_from] - 1;
        uint256 indexTo = _supported[_to] - 1;
        uint256 receiveAmount;
        uint256 fee;

        if (decimals[indexFrom] <= decimals[indexTo]) {
            uint256 delta = uint256(decimals[indexTo]).sub(decimals[indexFrom]);
            require(to.balanceOf(address(this)) >= amount.mul(10 ** delta), '!underlying');

            from.safeTransferFrom(msg.sender, address(this), amount);

            fee = amount.mul(swapFee).div(swapFeeBase);
            if (vox.balanceOf(msg.sender) > minimumVoxBalance) {
                fee = fee.mul(voxHolderDiscount).div(100);
            }
            fees[indexFrom] = fees[indexFrom].add(fee);
            
            uint256 leftover = amount.sub(fee);
            balances[indexFrom] = balances[indexFrom].add(leftover);

            receiveAmount = leftover.mul(10 ** delta);
        } else {
            uint256 delta = uint256(decimals[indexFrom]).sub(decimals[indexTo]);
            require(to.balanceOf(address(this)) >= amount.div(10 ** delta), '!underlying');

            from.safeTransferFrom(msg.sender, address(this), amount);

            fee = amount.mul(swapFee).div(swapFeeBase);
            if (vox.balanceOf(msg.sender) > minimumVoxBalance) {
                fee = fee.mul(voxHolderDiscount).div(100);
            }
            fees[indexFrom] = fees[indexFrom].add(fee);
            
            uint256 leftover = amount.sub(fee);
            balances[indexFrom] = balances[indexFrom].add(leftover);

            receiveAmount = leftover.div(10 ** delta);
        }

        if (receiveAmount > 0) {
            balances[indexTo] = balances[indexTo].sub(receiveAmount);
            IERC20Lib(_to).safeTransfer(msg.sender, receiveAmount);
            emit Swapped(msg.sender, _from, amount, _to, receiveAmount, fee);
        }
    }

    function swapToUSDv(address _from, uint256 amount)
        external
        nonReentrant
        notPaused 
    {
        require(amount > 0, '!amount');
        require(_supported[_from] > 0, '!from');
        
        IERC20Lib from = IERC20Lib(_from);
        uint256 indexFrom = _supported[_from] - 1;

        require(from.balanceOf(msg.sender) >= amount, '!balance');
        from.safeTransferFrom(msg.sender, address(this), amount);

        uint256 fee = amount.mul(swapFee).div(swapFeeBase);
        if (vox.balanceOf(msg.sender) > minimumVoxBalance) {
            fee = fee.mul(voxHolderDiscount).div(100);
        }
        fees[indexFrom] = fees[indexFrom].add(fee);
        uint256 leftover = amount.sub(fee);
        balances[indexFrom] = balances[indexFrom].add(leftover);

        uint256[4] memory amounts;
        amounts[indexFrom] = leftover;
        _mint(amounts);
        uint256 delta = uint256(18).sub(decimals[indexFrom]);
        uint256 usdvAmount = leftover.mul(10 ** delta);
        emit Swapped(msg.sender, _from, amount, address(usdv), usdvAmount, fee);
    }

    function redeemSingle(address _underlying, uint256 amount)
        external
        nonReentrant
    {
        require(amount > 0, '!amount');
        require(_supported[_underlying] > 0, '!underlying');
        require(block.number > _depositedAt[msg.sender], '!same_block');

        require(usdv.balanceOf(msg.sender) >= amount, '!balance');
        IERC20Lib(address(usdv)).safeTransferFrom(msg.sender, address(this), amount);

        uint256 fee = amount.mul(redeemFee).div(redeemFeeBase);
        _redeemFees = _redeemFees.add(fee);
        uint256 leftover = amount.sub(fee);
        usdv.burn(address(this), leftover);
        _redeemed[msg.sender] = _redeemed[msg.sender].add(amount);

        uint256 indexTo = _supported[_underlying] - 1;
        uint256 delta = uint256(18).sub(decimals[indexTo]);
        uint256 receiveAmount = leftover.div(10 ** delta);

        IERC20Lib underlying = IERC20Lib(_underlying);
        require(underlying.balanceOf(address(this)) >= receiveAmount, '!underlying');

        balances[indexTo] = balances[indexTo].sub(receiveAmount);
        underlying.safeTransfer(msg.sender, receiveAmount);
        uint256[4] memory amounts;
        amounts[indexTo] = receiveAmount;
        emit Redeemed(msg.sender, amount, amounts, fee);
    }

    function redeemProportional(uint256 amount)
        public
        nonReentrant
    {
        require(amount > 0, '!amount');
        require(block.number > _depositedAt[msg.sender], '!same_block');

        require(usdv.balanceOf(msg.sender) >= amount, '!balance');
        IERC20Lib(address(usdv)).safeTransferFrom(msg.sender, address(this), amount);

        uint256 fee = amount.mul(redeemFee).div(redeemFeeBase);
        _redeemFees = _redeemFees.add(fee);
        uint256 leftover = amount.sub(fee);
        usdv.burn(address(this), leftover);
        _redeemed[msg.sender] = _redeemed[msg.sender].add(amount);

        uint256[4] memory _shares = shares();
        uint256[4] memory receiveAmounts;

        for(uint256 i = 0; i < _shares.length; i++) {
            uint256 delta = uint256(18).sub(decimals[i]);
            uint256 _amount = leftover.mul(_shares[i]).div(1e18);
            receiveAmounts[i] = _amount.div(10 ** delta);
        }

        for(uint256 i = 0; i < receiveAmounts.length; i++) {
            IERC20Lib underlying = IERC20Lib(coins[i]);
            require(underlying.balanceOf(address(this)) >= receiveAmounts[i], '!underlying');
            balances[i] = balances[i].sub(receiveAmounts[i]);
            underlying.safeTransfer(msg.sender, receiveAmounts[i]);
        }

        emit Redeemed(msg.sender, amount, receiveAmounts, fee);
    }

    function redeemAll()
        external
    {
        uint256 balance = usdv.balanceOf(msg.sender);
        redeemProportional(balance);
    }


    function salvage(address _token, uint256 _amount)
        external
        onlyOwner
    {
        require(_token != tusd, '!tusd');
        require(_token != susd, '!susd');
        require(_token != usdc, '!usdc');
        require(_token != usdt, '!usdt');

        IERC20Lib(_token).safeTransfer(owner, _amount);
        emit Recovered(_token, _amount);
    }

    function setMinimumVoxBalance(uint256 _minimumVoxBalance)
        external
        onlyOwner
    {
        minimumVoxBalance = _minimumVoxBalance;
    }

    function setVoxHolderDiscount(uint256 _voxHolderDiscount)
        external
        onlyOwner
    {
        voxHolderDiscount = _voxHolderDiscount;
    }

    function setSwapFee(uint256 _swapFee)
        external
        onlyOwner
    {
        require(_swapFee <= swapFeeMax, '!max');
        swapFee = _swapFee;
    }

    function setRedeemFee(uint256 _redeemFee)
        external
        onlyOwner
    {
        require(_redeemFee <= redeemFeeMax, '!max');
        redeemFee = _redeemFee;
    }

    function setAdmin(address _admin)
        external
        onlyOwner
    {
        require (_admin != address(0), '!address');
        admin = _admin;
    }

    function setTreasury(address _treasury)
        external
        onlyOwner
    {
        require (_treasury != address(0), '!address');
        treasury = _treasury;
    }

    function collectFees()
        external
        onlyOwner
    {
        for(uint256 i = 0; i < coins.length; i++) {
            if (fees[i] > 0) {
                uint256 _admin = fees[i].div(2);
                uint256 _treasury = fees[i].sub(_admin);

                fees[i] = 0;

                IERC20Lib(coins[i]).safeTransfer(admin, _admin);
                IERC20Lib(coins[i]).safeTransfer(treasury, _treasury);
            }
        }

        uint256 balance = usdv.balanceOf(address(this));
        if (_redeemFees > balance) {
            _redeemFees = balance;
        }

        uint256 _treasury = _redeemFees;
        _redeemFees = 0;
        IERC20Lib(address(usdv)).safeTransfer(treasury, _treasury);
    }


    event Swapped(address beneficiary, address from, uint256 fromAmount, address to, uint256 toAmount, uint256 fee);
    event Minted(address beneficiary, uint256 amount);
    event Redeemed(address beneficiary, uint256 amount, uint256[4] receivedAmounts, uint256 fee);
    event Recovered(address token, uint256 amount);
}