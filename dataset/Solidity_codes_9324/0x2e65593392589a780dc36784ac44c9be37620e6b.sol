

pragma solidity >=0.6.0;

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}



pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

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



pragma solidity ^0.6.0;




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



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

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

    function totalSupply() public view override virtual returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override virtual returns (uint256) {

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



pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;







interface IUniswapOracle {
    function changeInterval(uint256 seconds_) external;
    function update() external;
    function consult(address token, uint amountIn) external view returns (uint amountOut);
}

interface OneToken {
    function getOneTokenUsd() external view returns (uint256);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract oneETH is ERC20("oneETH", "oneETH"), Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 constant public MAX_RESERVE_RATIO = 100 * 10 ** 9; // At 100% reserve ratio, each oneETH is backed 1-to-1 by $1 of existing stable coins
    uint256 private constant DECIMALS = 9;
    uint256 public lastRefreshReserve; // The last time the reserve ratio was updated by the contract
    uint256 public minimumRefreshTime; // The time between reserve ratio refreshes

    address public stimulus; // oneETH builds a stimulus fund in ETH.
    uint256 public stimulusDecimals; // used to calculate oracle rate of Uniswap Pair

    AggregatorV3Interface internal chainlinkStimulusOracle;
    AggregatorV3Interface internal ethPrice;


    address public oneTokenOracle; // oracle for the oneETH stable coin
    address public stimulusOracle;  // oracle for a stimulus cryptocurrency that isn't on chainLink
    bool public chainLink;         // true means it is a chainLink oracle

    uint256 public MIN_RESERVE_RATIO;
    uint256 public MIN_DELAY;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint256 private _totalSupply;
    mapping(address => uint256) private _oneBalances;
    mapping(address => uint256) private _lastCall;  // used as a record to prevent flash loan attacks
    mapping (address => mapping (address => uint256)) private _allowedOne; // allowance to spend one

    address public wethAddress; // used for uniswap oracle consults
    address public ethUsdcUniswapOracle; // used to get the base price of USDC and ETH
    address public gov; // who has admin rights over certain functions
    address public pendingGov;  // allows you to transfer the governance to a different user - they must accept it!
    uint256 public reserveStepSize; // step size of update of reserve rate (e.g. 5 * 10 ** 8 = 0.5%)
    uint256 public reserveRatio;    // a number between 0 and 100 * 10 ** 9.

    mapping (address => bool) public acceptedCollateral;
    mapping (address => uint256) public collateralMintFee; // minting fee for different collaterals (100 * 10 ** 9 = 100% fee)
    address[] public collateralArray; // array of collateral - used to iterate while updating certain things like oracle intervals for TWAP

    modifier updateProtocol() {
        if (address(oneTokenOracle) != address(0)) {
            if (!chainLink) IUniswapOracle(stimulusOracle).update();

            IUniswapOracle(oneTokenOracle).update();

            for (uint i = 0; i < collateralArray.length; i++){
                if (acceptedCollateral[collateralArray[i]] && !oneCoinCollateralOracle[collateralArray[i]]) IUniswapOracle(collateralOracle[collateralArray[i]]).update();
            }

            if (block.timestamp - lastRefreshReserve >= minimumRefreshTime) {
                if (getOneTokenUsd() > 1 * 10 ** 9) {
                    setReserveRatio(reserveRatio.sub(reserveStepSize));
                } else {
                    setReserveRatio(reserveRatio.add(reserveStepSize));
                }

                lastRefreshReserve = block.timestamp;
            }
        }

        _;
    }

    event NewPendingGov(address oldPendingGov, address newPendingGov);
    event NewGov(address oldGov, address newGov);
    event NewReserveRate(uint256 reserveRatio);
    event Mint(address stimulus, address receiver, address collateral, uint256 collateralAmount, uint256 stimulusAmount, uint256 oneAmount);
    event Withdraw(address stimulus, address receiver, address collateral, uint256 collateralAmount, uint256 stimulusAmount, uint256 oneAmount);
    event NewMinimumRefreshTime(uint256 minimumRefreshTime);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data);

    modifier onlyIchiGov() {
        require(msg.sender == gov, "ACCESS: only Ichi governance");
        _;
    }

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));  // shortcut for calling transfer
    mapping (address => uint256) public collateralDecimals;     // needed to be able to convert from different collaterals
    mapping (address => bool) public oneCoinCollateralOracle;   // if true, we query the one token contract's usd price
    mapping (address => bool) public previouslySeenCollateral;  // used to allow users to withdraw collateral, even if the collateral has since been deprecated
    mapping (address => address) public collateralOracle;       // address of the Collateral-ETH Uniswap Price

    uint256 public mintFee;
    uint256 public withdrawFee;

    event MintFee(uint256 fee_);
    event WithdrawFee(uint256 fee_);

    modifier ethLPGov() {
        require(msg.sender == lpGov, "ACCESS: only ethLP governance");
        _;
    }

    address public lpGov;
    address public pendingLPGov;

    event NewPendingLPGov(address oldPendingLPGov, address newPendingLPGov);
    event NewLPGov(address oldLPGov, address newLPGov);
    event NewMintFee(address collateral, uint256 oldFee, uint256 newFee);

    mapping (address => uint256) private _burnedStablecoin; // maps user to burned oneETH

    function addCollateral(address collateral_, uint256 collateralDecimal_, address oracleAddress_, bool oneCoinOracle)
        external
        ethLPGov
    {
        if (!previouslySeenCollateral[collateral_]) collateralArray.push(collateral_);

        previouslySeenCollateral[collateral_] = true;
        acceptedCollateral[collateral_] = true;
        oneCoinCollateralOracle[collateral_] = oneCoinOracle;
        collateralDecimals[collateral_] = collateralDecimal_;
        collateralOracle[collateral_] = oracleAddress_;
        collateralMintFee[collateral_] = 0;
    }


    function setCollateralMintFee(address collateral_, uint256 fee_)
        external
        ethLPGov
    {
        require(acceptedCollateral[collateral_], "invalid collateral");
        require(fee_ <= 100 * 10 ** 9, "Fee must be valid");
        emit NewMintFee(collateral_, collateralMintFee[collateral_], fee_);
        collateralMintFee[collateral_] = fee_;
    }

    function setReserveStepSize(uint256 stepSize_)
        external
        ethLPGov
    {
        reserveStepSize = stepSize_;
    }

    function setCollateralOracle(address collateral_, address oracleAddress_, bool oneCoinOracle_)
        external
        ethLPGov
    {
        require(acceptedCollateral[collateral_], "invalid collateral");
        oneCoinCollateralOracle[collateral_] = oneCoinOracle_;
        collateralOracle[collateral_] = oracleAddress_;
    }

    function removeCollateral(address collateral_)
        external
        ethLPGov
    {
        acceptedCollateral[collateral_] = false;
    }

    function getBurnedStablecoin(address _user)
        public
        view
        returns (uint256)
    {
        return _burnedStablecoin[_user];
    }

    function getCollateralUsd(address collateral_) public view returns (uint256) {
        require(previouslySeenCollateral[collateral_], "must be an existing collateral");

        if (oneCoinCollateralOracle[collateral_]) return OneToken(collateral_).getOneTokenUsd();

        uint256 ethUsdcTWAP = IUniswapOracle(ethUsdcUniswapOracle).consult(wethAddress, 1 * 10 ** 18);  // 1 ETH = X USDC (10 ^ 6 decimals)
        return ethUsdcTWAP.mul(10 ** 3).mul(10 ** 9).div((IUniswapOracle(collateralOracle[collateral_]).consult(wethAddress, 10 ** 18)).mul(10 ** 9).div(10 ** collateralDecimals[collateral_]));
    }

    function globalCollateralValue() public view returns (uint256) {
        uint256 totalCollateralUsd = 0;

        for (uint i = 0; i < collateralArray.length; i++){
            if (collateralArray[i] != address(0)){
                totalCollateralUsd += IERC20(collateralArray[i]).balanceOf(address(this)).mul(10 ** 9).div(10 ** collateralDecimals[collateralArray[i]]).mul(getCollateralUsd(collateralArray[i])).div(10 ** 9); // add stablecoin balance
            }

        }
        return totalCollateralUsd;
    }

    function getOneTokenUsd()
        public
        view
        returns (uint256)
    {
        uint256 oneTokenPrice = IUniswapOracle(oneTokenOracle).consult(stimulus, 10 ** stimulusDecimals); // X one tokens (10 ** 9) / 1 stimulus token
        uint256 stimulusTWAP = getStimulusOracle(); // $Y / 1 stimulus (10 ** 9)

        uint256 oneTokenUsd = stimulusTWAP.mul(10 ** 9).div(oneTokenPrice); // 10 ** 9 decimals
        return oneTokenUsd;
    }

    function totalSupply()
        public
        override
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(address who)
        public
        override
        view
        returns (uint256)
    {
        return _oneBalances[who];
    }

    function setChainLinkStimulusOracle(address oracle_)
        external
        ethLPGov
        returns (bool)
    {
        chainlinkStimulusOracle = AggregatorV3Interface(oracle_);
        chainLink = true;

        return true;
    }

    function transfer(address to, uint256 value)
        public
        override
        validRecipient(to)
        updateProtocol()
        returns (bool)
    {
        _oneBalances[msg.sender] = _oneBalances[msg.sender].sub(value);
        _oneBalances[to] = _oneBalances[to].add(value);
        emit Transfer(msg.sender, to, value);

        return true;
    }

    function allowance(address owner_, address spender)
        public
        override
        view
        returns (uint256)
    {
        return _allowedOne[owner_][spender];
    }

    function transferFrom(address from, address to, uint256 value)
        public
        override
        validRecipient(to)
        updateProtocol()
        returns (bool)
    {
        _allowedOne[from][msg.sender] = _allowedOne[from][msg.sender].sub(value);

        _oneBalances[from] = _oneBalances[from].sub(value);
        _oneBalances[to] = _oneBalances[to].add(value);
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value)
        public
        override
        validRecipient(spender)
        updateProtocol()
        returns (bool)
    {
        _allowedOne[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _allowedOne[msg.sender][spender] = _allowedOne[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedOne[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        uint256 oldValue = _allowedOne[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedOne[msg.sender][spender] = 0;
        } else {
            _allowedOne[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedOne[msg.sender][spender]);
        return true;
    }

    function setOneOracle(address oracle_)
        external
        ethLPGov
        returns (bool)
    {
        oneTokenOracle = oracle_;

        return true;
    }

    function setEthUsdcUniswapOracle(address oracle_)
        external
        ethLPGov
        returns (bool)
    {
        ethUsdcUniswapOracle = oracle_;

        return true;
    }

    function setStimulusUniswapOracle(address oracle_)
        external
        ethLPGov
        returns (bool)
    {
        stimulusOracle = oracle_;
        chainLink = false;

        return true;
    }

    function getStimulusOracle()
        public
        view
        returns (uint256)
    {
        if (chainLink) {
            (
                uint80 roundID,
                int price,
                uint startedAt,
                uint timeStamp,
                uint80 answeredInRound
            ) = chainlinkStimulusOracle.latestRoundData();

            require(timeStamp > 0, "Rounds not complete");

            return uint256(price).mul(10); // 10 ** 9 price
        } else {
            uint256 stimulusTWAP = IUniswapOracle(stimulusOracle).consult(wethAddress, 1 * 10 ** 18);       // 1 ETH = X Stimulus, or X Stimulus / ETH
            uint256 ethUsdcTWAP = IUniswapOracle(ethUsdcUniswapOracle).consult(wethAddress, 1 * 10 ** 18);  // 1 ETH = X USDC

            return ethUsdcTWAP.mul(10 ** 3).mul(10 ** stimulusDecimals).div(stimulusTWAP); // 10 ** 9 price
        }
    }

    function setMinimumRefreshTime(uint256 val_)
        external
        ethLPGov
        returns (bool)
    {
        require(val_ != 0, "minimum refresh time must be valid");

        minimumRefreshTime = val_;

        for (uint i = 0; i < collateralArray.length; i++){
            if (acceptedCollateral[collateralArray[i]] && !oneCoinCollateralOracle[collateralArray[i]]) IUniswapOracle(collateralOracle[collateralArray[i]]).changeInterval(val_);
        }

        IUniswapOracle(ethUsdcUniswapOracle).changeInterval(val_);
        IUniswapOracle(oneTokenOracle).changeInterval(val_);
        if (!chainLink) IUniswapOracle(stimulusOracle).changeInterval(val_);


        emit NewMinimumRefreshTime(val_);
        return true;
    }

    constructor(
        uint256 reserveRatio_,
        address stimulus_,
        uint256 stimulusDecimals_,
        address wethAddress_,
        address ethOracleChainLink_,
        address ethUsdcUniswap_
    )
        public
    {
        _setupDecimals(uint8(9));
        stimulus = stimulus_;
        minimumRefreshTime = 3600 * 1; // 1 hour by default
        stimulusDecimals = stimulusDecimals_;
        reserveStepSize = 2 * 10 ** 8;  // 0.2% by default
        ethPrice = AggregatorV3Interface(ethOracleChainLink_);
        ethUsdcUniswapOracle = ethUsdcUniswap_;
        MIN_RESERVE_RATIO = 90 * 10 ** 9;
        wethAddress = wethAddress_;
        MIN_DELAY = 3;             // 3 blocks
        withdrawFee = 1 * 10 ** 8; // 0.1% fee at first, remains in collateral
        gov = msg.sender;
        lpGov = msg.sender;
        reserveRatio = reserveRatio_;
        _totalSupply = 10 ** 9;

        _oneBalances[msg.sender] = 10 ** 9;
        emit Transfer(address(0x0), msg.sender, 10 ** 9);
    }

    function setMinimumReserveRatio(uint256 val_)
        external
        ethLPGov
    {
        MIN_RESERVE_RATIO = val_;
    }

    function setMinimumDelay(uint256 val_)
        external
        ethLPGov
    {
        MIN_DELAY = val_;
    }

    function setPendingLPGov(address pendingLPGov_)
        external
        ethLPGov
    {
        address oldPendingLPGov = pendingLPGov;
        pendingLPGov = pendingLPGov_;
        emit NewPendingLPGov(oldPendingLPGov, pendingLPGov_);
    }

    function acceptLPGov()
        external
    {
        require(msg.sender == pendingLPGov, "!pending");
        address oldLPGov = lpGov; // that
        lpGov = pendingLPGov;
        pendingLPGov = address(0);
        emit NewGov(oldLPGov, lpGov);
    }

    function setPendingGov(address pendingGov_)
        external
        onlyIchiGov
    {
        address oldPendingGov = pendingGov;
        pendingGov = pendingGov_;
        emit NewPendingGov(oldPendingGov, pendingGov_);
    }

    function acceptGov()
        external
    {
        require(msg.sender == pendingGov, "!pending");
        address oldGov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldGov, gov);
    }

    function consultOneDeposit(uint256 oneAmount, address collateral)
        public
        view
        returns (uint256, uint256)
    {
        require(oneAmount != 0, "must use valid oneAmount");
        require(acceptedCollateral[collateral], "must be an accepted collateral");

        uint256 collateralAmount = oneAmount.mul(reserveRatio).div(MAX_RESERVE_RATIO).mul(10 ** collateralDecimals[collateral]).div(10 ** DECIMALS);
        collateralAmount = collateralAmount.mul(10 ** 9).div(getCollateralUsd(collateral));

        if (address(oneTokenOracle) == address(0)) return (collateralAmount, 0);

        uint256 stimulusUsd = getStimulusOracle();     // 10 ** 9

        uint256 stimulusAmountInOneStablecoin = oneAmount.mul(MAX_RESERVE_RATIO.sub(reserveRatio)).div(MAX_RESERVE_RATIO);

        uint256 stimulusAmount = stimulusAmountInOneStablecoin.mul(10 ** 9).div(stimulusUsd).mul(10 ** stimulusDecimals).div(10 ** DECIMALS); // must be 10 ** stimulusDecimals

        return (collateralAmount, stimulusAmount);
    }

    function consultOneWithdraw(uint256 oneAmount, address collateral)
        public
        view
        returns (uint256, uint256)
    {
        require(oneAmount != 0, "must use valid oneAmount");
        require(previouslySeenCollateral[collateral], "must be an accepted collateral");

        uint256 collateralAmount = oneAmount.sub(oneAmount.mul(withdrawFee).div(100 * 10 ** DECIMALS)).mul(10 ** collateralDecimals[collateral]).div(10 ** DECIMALS);
        collateralAmount = collateralAmount.mul(10 ** 9).div(getCollateralUsd(collateral));

        return (collateralAmount, 0);
    }

    function mint(
        uint256 oneAmount,
        address collateral
    )
        public
        payable
        nonReentrant
    {
        require(acceptedCollateral[collateral], "must be an accepted collateral");
        require(oneAmount != 0, "must mint non-zero amount");

        require((_lastCall[msg.sender] + MIN_DELAY) <= block.number, "action too soon - please wait a few more blocks");

        (uint256 collateralAmount, uint256 stimulusAmount) = consultOneDeposit(oneAmount, collateral);
        require(collateralAmount <= IERC20(collateral).balanceOf(msg.sender), "sender has insufficient collateral balance");
        
        bool convertedWeth = false;
        if (stimulus == wethAddress && IERC20(stimulus).balanceOf(msg.sender) < stimulusAmount) {
            if (address(msg.sender).balance >= msg.value && msg.value >= stimulusAmount) {
                uint256 currentwETHBalance = IERC20(stimulus).balanceOf(address(this));
                IWETH(wethAddress).deposit{value: msg.value}();
                require(IERC20(stimulus).balanceOf(address(this)) == currentwETHBalance.add(msg.value),"insufficient stimulus deposited");
                assert(IWETH(wethAddress).transfer(msg.sender, msg.value.sub(stimulusAmount)));
                convertedWeth = true;
            } else {
                require(stimulusAmount <= IERC20(stimulus).balanceOf(msg.sender), "sender has insufficient stimulus balance");
            }
        }

        SafeERC20.safeTransferFrom(IERC20(collateral), msg.sender, address(this), collateralAmount);
        if (!convertedWeth) {
            SafeERC20.safeTransferFrom(IERC20(stimulus), msg.sender, address(this), stimulusAmount);

            (bool success,) = address(msg.sender).call{value:msg.value}(new bytes(0));
            require(success, 'ETH_TRANSFER_FAILED');
        }

        oneAmount = oneAmount.sub(oneAmount.mul(mintFee).div(100 * 10 ** DECIMALS));                            // apply mint fee
        oneAmount = oneAmount.sub(oneAmount.mul(collateralMintFee[collateral]).div(100 * 10 ** DECIMALS));      // apply collateral fee

        _totalSupply = _totalSupply.add(oneAmount);
        _oneBalances[msg.sender] = _oneBalances[msg.sender].add(oneAmount);

        emit Transfer(address(0x0), msg.sender, oneAmount);

        _lastCall[msg.sender] = block.number;

        emit Mint(stimulus, msg.sender, collateral, collateralAmount, stimulusAmount, oneAmount);
    }

    function editMintFee(uint256 fee_)
        external
        onlyIchiGov
    {
        require(fee_ <= 100 * 10 ** 9, "Fee must be valid");
        mintFee = fee_;
        emit MintFee(fee_);
    }

    function editWithdrawFee(uint256 fee_)
        external
        onlyIchiGov
    {
        withdrawFee = fee_;
        emit WithdrawFee(fee_);
    }

    function withdraw(
        uint256 oneAmount,
        address collateral
    )
        public
        nonReentrant
        updateProtocol()
    {
        require(oneAmount != 0, "must withdraw non-zero amount");
        require(oneAmount <= _oneBalances[msg.sender], "insufficient balance");
        require(previouslySeenCollateral[collateral], "must be an existing collateral");
        require((_lastCall[msg.sender] + MIN_DELAY) <= block.number, "action too soon - please wait a few blocks");

        _totalSupply = _totalSupply.sub(oneAmount);
        _oneBalances[msg.sender] = _oneBalances[msg.sender].sub(oneAmount);

        _burnedStablecoin[msg.sender] = _burnedStablecoin[msg.sender].add(oneAmount);

        _lastCall[msg.sender] = block.number;
        emit Transfer(msg.sender, address(0x0), oneAmount);
    }


    function withdrawFinal(address collateral, uint256 amount)
        public
        nonReentrant
        updateProtocol()
    {
        require(previouslySeenCollateral[collateral], "must be an existing collateral");
        require((_lastCall[msg.sender] + MIN_DELAY) <= block.number, "action too soon - please wait a few blocks");

        uint256 oneAmount = _burnedStablecoin[msg.sender];
        require(oneAmount != 0, "insufficient oneETH to redeem");
        require(amount <= oneAmount, "insufficient oneETH to redeem");

        _burnedStablecoin[msg.sender] = _burnedStablecoin[msg.sender].sub(amount);

        uint256 collateralAmount = amount.sub(amount.mul(withdrawFee).div(100 * 10 ** DECIMALS)).mul(10 ** collateralDecimals[collateral]).div(10 ** DECIMALS);
        collateralAmount = collateralAmount.mul(10 ** 9).div(getCollateralUsd(collateral));

        uint256 stimulusAmount = 0;

        require(collateralAmount <= IERC20(collateral).balanceOf(address(this)), "insufficient collateral reserves - try another collateral");

        SafeERC20.safeTransfer(IERC20(collateral), msg.sender, collateralAmount);

        _lastCall[msg.sender] = block.number;

        emit Withdraw(stimulus, msg.sender, collateral, collateralAmount, stimulusAmount, amount);
    }

    function setReserveRatio(uint256 newRatio_)
        internal
    {
        require(newRatio_ >= 0, "positive reserve ratio");

        if (newRatio_ <= MAX_RESERVE_RATIO && newRatio_ >= MIN_RESERVE_RATIO) {
            reserveRatio = newRatio_;
            emit NewReserveRate(reserveRatio);
        }
    }

    function safeTransferETH(address to, uint value)
        public
        ethLPGov
    {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'ETH_TRANSFER_FAILED');
    }

    function moveStimulus(
        address location,
        uint256 amount
    )
        public
        ethLPGov
    {
        SafeERC20.safeTransfer(IERC20(stimulus), location, amount);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data) public payable ethLPGov returns (bytes memory) {
        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call.value(value)(callData);
        require(success, "oneETH::executeTransaction: Transaction execution reverted.");

        return returnData;
    }

}