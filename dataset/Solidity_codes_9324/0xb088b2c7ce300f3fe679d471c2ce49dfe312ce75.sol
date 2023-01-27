

pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;



contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract Pausable is Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}


pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


pragma solidity ^0.5.0;

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.15;


contract Whitelist is Ownable {

	mapping(address => bool) whitelist;
	event AddedToWhitelist(address indexed account);
	event RemovedFromWhitelist(address indexed account);

	function addToWhitelist(address _address) public onlyOwner {

		whitelist[_address] = true;
		emit AddedToWhitelist(_address);
	}

	function removefromWhitelist(address _address) public onlyOwner {

		whitelist[_address] = false;
		emit RemovedFromWhitelist(_address);
	}

	function isWhitelisted(address _address) public view returns (bool) {

		return whitelist[_address];
	}
}


pragma solidity 0.5.15;


contract IKyberNetworkProxy {

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view returns (uint expectedRate, uint slippageRate);

    function swapEtherToToken(ERC20 token, uint minConversionRate) external payable returns(uint);

    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) external payable returns(uint);

    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minRate) external returns(uint);

}


pragma solidity 0.5.15;

contract IKyberStaking {

    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function getLatestStakeBalance(address staker) external view returns(uint);

}


pragma solidity 0.5.15;

contract IKyberDAO {

    function vote(uint256 campaignID, uint256 option) external;

}


pragma solidity 0.5.15;

contract IKyberFeeHandler {

    function claimStakerReward(
        address staker,
        uint256 epoch
    ) external returns(uint256 amountWei);

}


pragma solidity 0.5.15;













contract xKNC is ERC20, ERC20Detailed, Whitelist, Pausable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    ERC20 public knc;
    IKyberDAO public kyberDao;
    IKyberStaking public kyberStaking;
    IKyberNetworkProxy public kyberProxy;
    IKyberFeeHandler[] public kyberFeeHandlers;

    address[] private kyberFeeTokens;

    uint256 constant PERCENT = 100;
    uint256 constant MAX_UINT = 2**256 - 1;
    uint256 constant INITIAL_SUPPLY_MULTIPLIER = 10;

    uint256[] public feeDivisors;
    uint256 private withdrawableEthFees;
    uint256 private withdrawableKncFees;

    string public mandate;

    mapping(address => bool) fallbackAllowedAddress;

    struct FeeStructure {
        uint mintFee;
        uint burnFee;
        uint claimFee;
    }

    FeeStructure public feeStructure;

    event MintWithEth(
        address indexed user,
        uint256 ethPayable,
        uint256 mintAmount,
        uint256 timestamp
    );
    event MintWithKnc(
        address indexed user,
        uint256 kncPayable,
        uint256 mintAmount,
        uint256 timestamp
    );
    event Burn(
        address indexed user,
        bool redeemedForKnc,
        uint256 burnAmount,
        uint256 timestamp
    );
    event FeeWithdraw(uint256 ethAmount, uint256 kncAmount, uint256 timestamp);
    event FeeDivisorsSet(uint256 mintFee, uint256 burnFee, uint256 claimFee);
    event EthRewardClaimed(uint256 amount, uint256 timestamp);
    event TokenRewardClaimed(uint256 amount, uint256 timestamp);

    enum FeeTypes {MINT, BURN, CLAIM}

    constructor(
        string memory _mandate,
        address _kyberStakingAddress,
        address _kyberProxyAddress,
        address _kyberTokenAddress,
        address _kyberDaoAddress
    ) public ERC20Detailed("xKNC", "xKNCa", 18) {
        mandate = _mandate;
        kyberStaking = IKyberStaking(_kyberStakingAddress);
        kyberProxy = IKyberNetworkProxy(_kyberProxyAddress);
        knc = ERC20(_kyberTokenAddress);
        kyberDao = IKyberDAO(_kyberDaoAddress);

        _addFallbackAllowedAddress(_kyberProxyAddress);
    }

    function mint(uint256 minRate) external payable whenNotPaused {

        require(msg.value > 0, "Must send eth with tx");
        uint256 ethBalBefore = getFundEthBalanceWei().sub(msg.value);
        uint256 fee = _administerEthFee(FeeTypes.MINT, ethBalBefore);

        uint256 ethValueForKnc = msg.value.sub(fee);
        uint256 kncBalanceBefore = getFundKncBalanceTwei();

        _swapEtherToKnc(ethValueForKnc, minRate);
        _deposit(getAvailableKncBalanceTwei());

        uint256 mintAmount = _calculateMintAmount(kncBalanceBefore);

        emit MintWithEth(msg.sender, msg.value, mintAmount, block.timestamp);
        return super._mint(msg.sender, mintAmount);
    }

    function mintWithKnc(uint256 kncAmountTwei) external whenNotPaused {

        require(kncAmountTwei > 0, "Must contribute KNC");
        knc.safeTransferFrom(msg.sender, address(this), kncAmountTwei);

        uint256 kncBalanceBefore = getFundKncBalanceTwei();
        _administerKncFee(kncAmountTwei, FeeTypes.MINT);

        _deposit(getAvailableKncBalanceTwei());

        uint256 mintAmount = _calculateMintAmount(kncBalanceBefore);

        emit MintWithKnc(msg.sender, kncAmountTwei, mintAmount, block.timestamp);
        return super._mint(msg.sender, mintAmount);
    }

    function burn(
        uint256 tokensToRedeemTwei,
        bool redeemForKnc,
        uint256 minRate
    ) external nonReentrant {

        require(
            balanceOf(msg.sender) >= tokensToRedeemTwei,
            "Insufficient balance"
        );

        uint256 proRataKnc = getFundKncBalanceTwei().mul(tokensToRedeemTwei).div(
            totalSupply()
        );
        _withdraw(proRataKnc);
        super._burn(msg.sender, tokensToRedeemTwei);

        if (redeemForKnc) {
            uint256 fee = _administerKncFee(proRataKnc, FeeTypes.BURN);
            knc.safeTransfer(msg.sender, proRataKnc.sub(fee));
        } else {
            uint256 ethBalBefore = getFundEthBalanceWei();
            kyberProxy.swapTokenToEther(
                knc,
                getAvailableKncBalanceTwei(),
                minRate
            );

            _administerEthFee(FeeTypes.BURN, ethBalBefore);

            uint256 valToSend = getFundEthBalanceWei().sub(ethBalBefore);
            (bool success, ) = msg.sender.call.value(valToSend)("");
            require(success, "Burn transfer failed");
        }

        emit Burn(msg.sender, redeemForKnc, tokensToRedeemTwei, block.timestamp);
    }

    function _calculateMintAmount(uint256 kncBalanceBefore)
        private
        view
        returns (uint256 mintAmount)
    {

        uint256 kncBalanceAfter = getFundKncBalanceTwei();
        if (totalSupply() == 0)
            return kncBalanceAfter.mul(INITIAL_SUPPLY_MULTIPLIER);

        mintAmount = (kncBalanceAfter.sub(kncBalanceBefore))
            .mul(totalSupply())
            .div(kncBalanceBefore);
    }

    function _deposit(uint256 amount) private {

        kyberStaking.deposit(amount);
    }

    function _withdraw(uint256 amount) private {

        kyberStaking.withdraw(amount);
    }

    function vote(uint256 campaignID, uint256 option) external onlyOwner {

        kyberDao.vote(campaignID, option);
    }

    function claimReward(
        uint256 epoch,
        uint256[] calldata feeHandlerIndices,
        uint256[] calldata maxAmountsToSell,
        uint256[] calldata minRates
    ) external onlyOwner {

        require(
            feeHandlerIndices.length == maxAmountsToSell.length,
            "Arrays must be equal length"
        );
        require(
            maxAmountsToSell.length == minRates.length,
            "Arrays must be equal length"
        );

        uint256 ethBalBefore = getFundEthBalanceWei();
        for (uint256 i = 0; i < feeHandlerIndices.length; i++) {
            kyberFeeHandlers[i].claimStakerReward(address(this), epoch);

            if (kyberFeeTokens[i] == ETH_ADDRESS) {
                emit EthRewardClaimed(
                    getFundEthBalanceWei().sub(ethBalBefore),
                    block.timestamp
                );
                _administerEthFee(FeeTypes.CLAIM, ethBalBefore);
            } else {
                uint256 tokenBal = IERC20(kyberFeeTokens[i]).balanceOf(
                    address(this)
                );
                emit TokenRewardClaimed(tokenBal, block.timestamp);
            }

            _unwindRewards(
                feeHandlerIndices[i],
                maxAmountsToSell[i],
                minRates[i]
            );
        }

        _deposit(getAvailableKncBalanceTwei());
    }

    function unwindRewards(
        uint256[] calldata feeHandlerIndices,
        uint256[] calldata maxAmountsToSell,
        uint256[] calldata minRates
    ) external onlyOwner {

        for (uint256 i = 0; i < feeHandlerIndices.length; i++) {
            _unwindRewards(
                feeHandlerIndices[i],
                maxAmountsToSell[i],
                minRates[i]
            );
        }

        _deposit(getAvailableKncBalanceTwei());
    }

    function _unwindRewards(
        uint256 feeHandlerIndex,
        uint256 maxAmountToSell,
        uint256 minRate
    ) private {

        address rewardTokenAddress = kyberFeeTokens[feeHandlerIndex];

        uint256 amountToSell;
        if (rewardTokenAddress == ETH_ADDRESS) {
            uint256 ethBal = getFundEthBalanceWei();
            if (maxAmountToSell < ethBal) {
                amountToSell = maxAmountToSell;
            } else {
                amountToSell = ethBal;
            }

            _swapEtherToKnc(amountToSell, minRate);
        } else {
            uint256 tokenBal = IERC20(rewardTokenAddress).balanceOf(
                address(this)
            );
            if (maxAmountToSell < tokenBal) {
                amountToSell = maxAmountToSell;
            } else {
                amountToSell = tokenBal;
            }

            uint256 kncBalanceBefore = getAvailableKncBalanceTwei();

            _swapTokenToKnc(
                rewardTokenAddress,
                amountToSell,
                minRate
            );

            uint256 kncBalanceAfter = getAvailableKncBalanceTwei();
            _administerKncFee(
                kncBalanceAfter.sub(kncBalanceBefore),
                FeeTypes.CLAIM
            );
        }
    }

    function _swapEtherToKnc(
        uint256 amount,
        uint256 minRate
    ) private {

        kyberProxy.swapEtherToToken.value(amount)(knc, minRate);
    }

    function _swapTokenToKnc(
        address fromAddress,
        uint256 amount,
        uint256 minRate
    ) private {

        kyberProxy.swapTokenToToken(
            ERC20(fromAddress),
            amount,
            knc,
            minRate
        );
    }

    function getFundEthBalanceWei() public view returns (uint256) {

        return address(this).balance.sub(withdrawableEthFees);
    }

    function getFundKncBalanceTwei() public view returns (uint256) {

        return kyberStaking.getLatestStakeBalance(address(this));
    }

    function getAvailableKncBalanceTwei() public view returns (uint256) {

        return knc.balanceOf(address(this)).sub(withdrawableKncFees);
    }

    function _administerEthFee(FeeTypes _type, uint256 ethBalBefore)
        private
        returns (uint256 fee)
    {

        if (!isWhitelisted(msg.sender)) {
            uint256 feeRate = getFeeRate(_type);
            if (feeRate == 0) return 0;

            fee = (getFundEthBalanceWei().sub(ethBalBefore)).div(feeRate);
            withdrawableEthFees = withdrawableEthFees.add(fee);
        }
    }

    function _administerKncFee(uint256 _kncAmount, FeeTypes _type)
        private
        returns (uint256 fee)
    {

        if (!isWhitelisted(msg.sender)) {
            uint256 feeRate = getFeeRate(_type);
            if (feeRate == 0) return 0;

            fee = _kncAmount.div(feeRate);
            withdrawableKncFees = withdrawableKncFees.add(fee);
        }
    }

    function getFeeRate(FeeTypes _type) public view returns (uint256) {

        if (_type == FeeTypes.MINT) return feeStructure.mintFee;
        if (_type == FeeTypes.BURN) return feeStructure.burnFee;
        if (_type == FeeTypes.CLAIM) return feeStructure.claimFee;
    }

    function addKyberFeeHandler(
        address _kyberfeeHandlerAddress,
        address _tokenAddress
    ) external onlyOwner {

        kyberFeeHandlers.push(IKyberFeeHandler(_kyberfeeHandlerAddress));
        kyberFeeTokens.push(_tokenAddress);

        if (_tokenAddress != ETH_ADDRESS) {
            _approveKyberProxyContract(_tokenAddress, false);
        } else {
            _addFallbackAllowedAddress(_kyberfeeHandlerAddress);
        }
    }


    function approveStakingContract(bool _reset) external onlyOwner {

        uint256 amount = _reset ? 0 : MAX_UINT;
        knc.approve(address(kyberStaking), amount);
    }

    function approveKyberProxyContract(address _token, bool _reset)
        external
        onlyOwner
    {

        _approveKyberProxyContract(_token, _reset);
    }

    function _approveKyberProxyContract(address _token, bool _reset) private {

        uint256 amount = _reset ? 0 : MAX_UINT;
        IERC20(_token).approve(address(kyberProxy), amount);
    }

    function setFeeDivisors(uint256 _mintFee, uint256 _burnFee, uint256 _claimFee)
        external
        onlyOwner
    {

        require(
            _mintFee >= 100 || _mintFee == 0,
            "Mint fee must be zero or equal to or less than 1%"
        );
        require(
            _burnFee >= 100,
            "Burn fee must be equal to or less than 1%"
        );
        require(_claimFee >= 10, "Claim fee must be less than 10%");
        feeStructure.mintFee = _mintFee;
        feeStructure.burnFee = _burnFee;
        feeStructure.claimFee = _claimFee;

        emit FeeDivisorsSet(_mintFee, _burnFee, _claimFee);
    }

    function withdrawFees() external onlyOwner {

        uint256 ethFees = withdrawableEthFees;
        uint256 kncFees = withdrawableKncFees;

        withdrawableEthFees = 0;
        withdrawableKncFees = 0;

        (bool success, ) = msg.sender.call.value(ethFees)("");
        require(success, "Burn transfer failed");

        knc.safeTransfer(owner(), kncFees);
        emit FeeWithdraw(ethFees, kncFees, block.timestamp);
    }

    function addFallbackAllowedAddress(address _address) external onlyOwner {

        _addFallbackAllowedAddress(_address);
    }

    function _addFallbackAllowedAddress(address _address) private {

        fallbackAllowedAddress[_address] = true;
    }

    function() external payable {
        require(
            fallbackAllowedAddress[msg.sender],
            "Only approved address can use fallback"
        );
    }
}