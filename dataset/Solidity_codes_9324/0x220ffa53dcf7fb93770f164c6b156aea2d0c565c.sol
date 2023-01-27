pragma solidity ^0.8.0;

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

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// GPL-2.0-or-later
pragma solidity 0.8.9;


contract LendingPoolToken is ERC20, Ownable {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _receiver, uint256 _amount) external onlyOwner {
        require(_amount > 0, "LendingPoolToken: invalidAmount");
        _mint(_receiver, _amount);
    }

    function burn(uint256 _amount) external {
        require(_amount > 0, "LendingPoolToken: invalidAmount");
        _burn(msg.sender, _amount);
    }
}// GPL-2.0-or-later
pragma solidity 0.8.9;


library Util {
    function getERC20Decimals(IERC20 _token) internal view returns (uint8) {
        return IERC20Metadata(address(_token)).decimals();
    }

    function checkedTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        require(amount > 0, "checkedTransferFrom: amount zero");
        uint256 balanceBefore = token.balanceOf(to);
        token.transferFrom(from, to, amount);
        uint256 receivedAmount = token.balanceOf(to) - balanceBefore;
        require(receivedAmount == amount, "checkedTransferFrom: not amount");
        return receivedAmount;
    }

    function checkedTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        require(amount > 0, "checkedTransfer: amount zero");
        uint256 balanceBefore = token.balanceOf(to);
        token.transfer(to, amount);
        uint256 receivedAmount = token.balanceOf(to) - balanceBefore;
        require(receivedAmount == amount, "checkedTransfer: not amount");
        return receivedAmount;
    }

    function convertDecimals(
        uint256 _number,
        uint256 _currentDecimals,
        uint256 _targetDecimals
    ) internal pure returns (uint256) {
        uint256 diffDecimals;

        uint256 amountCorrected = _number;

        if (_targetDecimals < _currentDecimals) {
            diffDecimals = _currentDecimals - _targetDecimals;
            amountCorrected = _number / (uint256(10)**diffDecimals);
        } else if (_targetDecimals > _currentDecimals) {
            diffDecimals = _targetDecimals - _currentDecimals;
            amountCorrected = _number * (uint256(10)**diffDecimals);
        }

        return (amountCorrected);
    }

    function convertDecimalsERC20(
        uint256 _number,
        IERC20 _sourceToken,
        IERC20 _targetToken
    ) internal view returns (uint256) {
        return convertDecimals(_number, getERC20Decimals(_sourceToken), getERC20Decimals(_targetToken));
    }

    function removeValueFromArray(IERC20 value, IERC20[] storage array) internal {
        bool shift = false;
        uint256 i = 0;
        while (i < array.length - 1) {
            if (array[i] == value) shift = true;
            if (shift) {
                array[i] = array[i + 1];
            }
            i++;
        }
        array.pop();
    }
}// GPL-2.0-or-later
pragma solidity 0.8.9;



library Funding {
    event FundingRequestAdded(uint256 fundingRequestId, address borrower, uint256 amount, uint256 durationDays, uint256 interestRate);

    event FundingRequestCancelled(uint256 fundingRequestId);

    event Funded(address indexed funder, IERC20 fundingToken, uint256 fundingTokenAmount, uint256 lendingPoolTokenAmount);

    event FundingTokenUpdated(IERC20 token, bool accepted);

    event PrimaryFunderUpdated(address primaryFunder, bool accepted);

    event BorrowerUpdated(address borrower, bool accepted);

    struct FundingStorage {
        mapping(uint256 => FundingRequest) fundingRequests; //FundingRequest.id => FundingRequest
        uint256 currentFundingRequestId; //id of the next FundingRequest to be proccessed
        uint256 lastFundingRequestId; //id of the last FundingRequest in the
        mapping(address => bool) primaryFunders; //address => whether its allowed to fund loans
        mapping(IERC20 => bool) fundingTokens; //token => whether it can be used to fund loans
        IERC20[] _fundingTokens; //all fundingTokens that can be used to fund loans
        mapping(address => bool) borrowers; //address => whether its allowed to act as borrower / create FundingRequests
        mapping(IERC20 => AggregatorV3Interface) fundingTokenChainLinkFeeds; //fudingToken => ChainLink feed which provides a conversion rate for the fundingToken to the pools loans base currency (e.g. USDC => EURSUD)
        mapping(IERC20 => bool) invertChainLinkFeedAnswer; //fudingToken => whether the data provided by the ChainLink feed should be inverted (not all ChainLink feeds are Token->BaseCurrency, some could be BaseCurrency->Token)
        bool disablePrimaryFunderCheck;
    }
    struct FundingRequest {
        uint256 id; //id of the funding request
        address borrower; //the borrower who created the funding request
        uint256 amount; //the amount to be raised denominated in LendingPoolTokens
        uint256 durationDays; //duration of the underlying loan in days
        uint256 interestRate; //interest rate of the underlying  loan (2 decimals)
        uint256 amountFilled; //amount that has already been filled by primary funders
        FundingRequestState state; //state of the funding request
        uint256 next; //id of the next funding request
        uint256 prev; //id of the previous funding request
    }

    enum FundingRequestState {
        OPEN, //the funding request is open and ready to be filled
        FILLED, //the funding request has been filled completely
        CANCELLED //the funding request has been cancelled
    }

    modifier onlyBorrower(FundingStorage storage fundingStorage) {
        require(fundingStorage.borrowers[msg.sender], "caller address is no borrower");
        _;
    }

    function getOpenFundingRequests(FundingStorage storage fundingStorage) external view returns (FundingRequest[] memory) {
        FundingRequest[] memory fundingRequests = new FundingRequest[](fundingStorage.lastFundingRequestId - fundingStorage.currentFundingRequestId + 1);
        uint256 i = fundingStorage.currentFundingRequestId;
        for (; i <= fundingStorage.lastFundingRequestId; i++) {
            fundingRequests[i - fundingStorage.currentFundingRequestId] = fundingStorage.fundingRequests[i];
        }
        return fundingRequests;
    }

    function addFundingRequest(
        FundingStorage storage fundingStorage,
        uint256 amount,
        uint256 durationDays,
        uint256 interestRate
    ) public onlyBorrower(fundingStorage) {
        require(amount > 0 && durationDays > 0 && interestRate > 0, "invalid funding request data");

        uint256 previousFundingRequestId = fundingStorage.lastFundingRequestId;

        uint256 fundingRequestId = ++fundingStorage.lastFundingRequestId;

        if (previousFundingRequestId != 0) {
            fundingStorage.fundingRequests[previousFundingRequestId].next = fundingRequestId;
        }

        emit FundingRequestAdded(fundingRequestId, msg.sender, amount, durationDays, interestRate);

        fundingStorage.fundingRequests[fundingRequestId] = FundingRequest(
            fundingRequestId,
            msg.sender,
            amount,
            durationDays,
            interestRate,
            0,
            FundingRequestState.OPEN,
            0,
            previousFundingRequestId
        );

        if (fundingStorage.currentFundingRequestId == 0) {
            fundingStorage.currentFundingRequestId = fundingStorage.lastFundingRequestId;
        }
    }

    function cancelFundingRequest(FundingStorage storage fundingStorage, uint256 fundingRequestId) public onlyBorrower(fundingStorage) {
        require(fundingStorage.fundingRequests[fundingRequestId].id != 0, "funding request not found");
        require(fundingStorage.fundingRequests[fundingRequestId].state == FundingRequestState.OPEN, "funding request already processing");

        emit FundingRequestCancelled(fundingRequestId);

        fundingStorage.fundingRequests[fundingRequestId].state = FundingRequestState.CANCELLED;

        FundingRequest storage currentRequest = fundingStorage.fundingRequests[fundingRequestId];

        if (currentRequest.prev != 0) {
            fundingStorage.fundingRequests[currentRequest.prev].next = currentRequest.next;
        }

        if (currentRequest.next != 0) {
            fundingStorage.fundingRequests[currentRequest.next].prev = currentRequest.prev;
        }

        uint256 saveNext = fundingStorage.fundingRequests[fundingRequestId].next;
        fundingStorage.fundingRequests[fundingRequestId].prev = 0;
        fundingStorage.fundingRequests[fundingRequestId].next = 0;

        if (fundingStorage.currentFundingRequestId == fundingRequestId) {
            fundingStorage.currentFundingRequestId = saveNext; // can be zero which is fine
        }
    }

    function fund(
        FundingStorage storage fundingStorage,
        IERC20 fundingToken,
        uint256 fundingTokenAmount,
        LendingPoolToken lendingPoolToken
    ) public {
        require(fundingStorage.primaryFunders[msg.sender] || fundingStorage.disablePrimaryFunderCheck, "address is not primary funder");
        require(fundingStorage.fundingTokens[fundingToken], "unrecognized funding token");
        require(fundingStorage.currentFundingRequestId != 0, "no active funding request");

        (uint256 exchangeRate, uint256 exchangeRateDecimals) = getExchangeRate(fundingStorage, fundingToken);

        FundingRequest storage currentFundingRequest = fundingStorage.fundingRequests[fundingStorage.currentFundingRequestId];
        uint256 currentFundingNeedInLPT = currentFundingRequest.amount - currentFundingRequest.amountFilled;

        uint256 currentFundingNeedInFundingToken = (Util.convertDecimalsERC20(currentFundingNeedInLPT, lendingPoolToken, fundingToken) * exchangeRate) /
            (uint256(10)**exchangeRateDecimals);

        if (fundingTokenAmount > currentFundingNeedInFundingToken) {
            fundingTokenAmount = currentFundingNeedInFundingToken;
        }

        uint256 lendingPoolTokenAmount = ((Util.convertDecimalsERC20(fundingTokenAmount, fundingToken, lendingPoolToken) * (uint256(10)**exchangeRateDecimals)) / exchangeRate);

        Util.checkedTransferFrom(fundingToken, msg.sender, currentFundingRequest.borrower, fundingTokenAmount);
        currentFundingRequest.amountFilled += lendingPoolTokenAmount;

        if (currentFundingRequest.amount == currentFundingRequest.amountFilled) {
            currentFundingRequest.state = FundingRequestState.FILLED;

            fundingStorage.currentFundingRequestId = currentFundingRequest.next; // this can be zero which is ok
        }

        lendingPoolToken.mint(msg.sender, lendingPoolTokenAmount);
        emit Funded(msg.sender, fundingToken, fundingTokenAmount, lendingPoolTokenAmount);
    }

    function getExchangeRate(FundingStorage storage fundingStorage, IERC20 fundingToken) public view returns (uint256, uint8) {
        require(address(fundingStorage.fundingTokenChainLinkFeeds[fundingToken]) != address(0), "no exchange rate available");

        (, int256 exchangeRate, , , ) = fundingStorage.fundingTokenChainLinkFeeds[fundingToken].latestRoundData();
        require(exchangeRate != 0, "zero exchange rate");

        uint8 exchangeRateDecimals = fundingStorage.fundingTokenChainLinkFeeds[fundingToken].decimals();

        if (fundingStorage.invertChainLinkFeedAnswer[fundingToken]) {
            exchangeRate = int256(10**(exchangeRateDecimals * 2)) / exchangeRate;
        }

        return (uint256(exchangeRate), exchangeRateDecimals);
    }

    function setFundingTokenChainLinkFeed(
        FundingStorage storage fundingStorage,
        IERC20 fundingToken,
        AggregatorV3Interface fundingTokenChainLinkFeed,
        bool invertChainLinkFeedAnswer
    ) external {
        fundingStorage.fundingTokenChainLinkFeeds[fundingToken] = fundingTokenChainLinkFeed;
        fundingStorage.invertChainLinkFeedAnswer[fundingToken] = invertChainLinkFeedAnswer;
    }

    function setFundingToken(
        FundingStorage storage fundingStorage,
        IERC20 fundingToken,
        bool accepted
    ) public {
        if (fundingStorage.fundingTokens[fundingToken] != accepted) {
            fundingStorage.fundingTokens[fundingToken] = accepted;
            emit FundingTokenUpdated(fundingToken, accepted);
            if (accepted) {
                fundingStorage._fundingTokens.push(fundingToken);
            } else {
                Util.removeValueFromArray(fundingToken, fundingStorage._fundingTokens);
            }
        }
    }

    function setPrimaryFunder(
        FundingStorage storage fundingStorage,
        address primaryFunder,
        bool accepted
    ) public {
        if (fundingStorage.primaryFunders[primaryFunder] != accepted) {
            fundingStorage.primaryFunders[primaryFunder] = accepted;
            emit PrimaryFunderUpdated(primaryFunder, accepted);
        }
    }

    function setBorrower(
        FundingStorage storage fundingStorage,
        address borrower,
        bool accepted
    ) public {
        if (fundingStorage.borrowers[borrower] != accepted) {
            fundingStorage.borrowers[borrower] = accepted;
            emit BorrowerUpdated(borrower, accepted);
            if (fundingStorage.borrowers[msg.sender]) {
                fundingStorage.borrowers[msg.sender] = false;
            }
        }
    }
}