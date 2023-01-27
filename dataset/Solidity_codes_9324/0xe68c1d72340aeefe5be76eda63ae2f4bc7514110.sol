pragma solidity ^0.8.6;

interface IDeFiPlaza {

  function swap(
    address inputToken,
    address outputToken,
    uint256 inputAmount,
    uint256 minOutputAmount
  ) external payable returns (uint256 outputAmount);


  function addLiquidity(
    address inputToken,
    uint256 inputAmount,
    uint256 minLP
  ) external payable returns (uint256 deltaLP);


  function addMultiple(
    address[] calldata tokens,
    uint256[] calldata maxAmounts
  ) external payable returns (uint256 actualLP);


  function removeLiquidity(
    uint256 LPamount,
    address outputToken,
    uint256 minOutputAmount
  ) external returns (uint256 actualOutput);


  function removeMultiple(
    uint256 LPamount,
    address[] calldata tokens
  ) external returns (bool success);


  function bootstrapNewToken(
    address inputToken,
    uint256 maxInputAmount,
    address outputToken
  ) external returns (uint64 fractionBootstrapped);


  function bootstrapNewTokenWithBonus(
    address inputToken,
    uint256 maxInputAmount,
    address outputToken,
    address bonusToken
  ) external returns (uint256 bonusAmount);


  event Swapped(
    address sender,
    address inputToken,
    address outputToken,
    uint256 inputAmount,
    uint256 outputAmount
  );

  event LiquidityAdded(
    address sender,
    address token,
    uint256 tokenAmount,
    uint256 LPs
  );

  event MultiLiquidityAdded(
    address sender,
    uint256 LPs,
    uint256 totalLPafter
  );

  event LiquidityRemoved(
    address recipient,
    address token,
    uint256 tokenAmount,
    uint256 LPs
  );

  event MultiLiquidityRemoved(
    address sender,
    uint256 LPs,
    uint256 totalLPafter
  );

  event Bootstrapped(
    address sender,
    address inputToken,
    uint256 inputAmount,
    address outputToken,
    uint256 outputAmount
  );

  event BootstrapBonus(
    address sender,
    address bonusToken,
    uint256 bonusAmount
  );

  event BootstrapCompleted(
    address delistedToken,
    address listedToken
  );
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity ^0.8.6;


contract DeFiPlaza is IDeFiPlaza, Ownable, ERC20 {
  using SafeERC20 for IERC20;

  enum State {Unlisted, PreListing, Delisting, Listed}

  struct TokenSettings {
    State state;                      // What state the token is currently in
    uint112 listingTarget;            // Amount of tokens needed to activate listing
  }

  struct Config {
    bool unlocked;                    // Locked for trading to prevent re-entrancy misery
    uint64 oneMinusTradingFee;        // One minus the swap fee (0.64 fixed point integer)
    uint64 delistingBonus;            // Amount of additional tokens to encourage immediate delisting (0.64 fixed point)
  }

  struct ListingUpdate {
    address tokenToDelist;            // Token to be removed
    address tokenToList;              // Token to be listed
  }

  mapping(address => TokenSettings) public listedTokens;
  Config public DFPconfig;
  ListingUpdate public listingUpdate;
  address public admin;

  constructor(address[] memory tokensToList, uint256 mintAmount, string memory name_, string memory symbol_) ERC20(name_, symbol_) {
    Config memory config;
    config.unlocked = false;
    config.oneMinusTradingFee = 0xffbe76c8b4395800;   // approximately 0.999
    config.delistingBonus = 0;
    DFPconfig = config;

    TokenSettings memory listed;
    listed.state = State.Listed;
    require(tokensToList.length == 15, "Incorrect number of tokens");
    address previous = address(0);
    address current = address(0);
    for (uint256 i = 0; i < 15; i++) {
      current = tokensToList[i];
      require(current > previous, "Require ordered list");
      listedTokens[current] = listed;
      previous = current;
    }

    _mint(msg.sender, mintAmount);
  }

  receive() external payable {}

  modifier onlyListedToken(address token) {
    require(
      token == address(0) || listedTokens[token].state > State.Delisting,
      "DFP: Token not listed"
    );
    _;
  }

  modifier onlyAdmin() {
    require(
      msg.sender == admin || msg.sender == owner(),
      "DFP: admin rights required"
    );
    _;
  }

  function swap(
    address inputToken,
    address outputToken,
    uint256 inputAmount,
    uint256 minOutputAmount
  )
    external
    payable
    onlyListedToken(inputToken)
    onlyListedToken(outputToken)
    override
    returns (uint256 outputAmount)
  {
    Config memory _config = DFPconfig;
    require(_config.unlocked, "DFP: Locked");

    uint256 initialInputBalance;
    if (inputToken == address(0)) {
      require(msg.value == inputAmount, "DFP: bad ETH amount");
      initialInputBalance = address(this).balance - inputAmount;
    } else {
      initialInputBalance = IERC20(inputToken).balanceOf(address(this));
      IERC20(inputToken).safeTransferFrom(msg.sender, address(this), inputAmount);
    }

    uint256 initialOutputBalance;
    if (outputToken == address(0)) {
      initialOutputBalance = address(this).balance;
    } else {
      initialOutputBalance = IERC20(outputToken).balanceOf(address(this));
    }

    uint256 netInputAmount = inputAmount * _config.oneMinusTradingFee;
    outputAmount = netInputAmount * initialOutputBalance / ((initialInputBalance << 64) + netInputAmount);
    require(outputAmount > minOutputAmount, "DFP: No deal");

    if (outputToken == address(0)) {
      address payable sender = payable(msg.sender);
      sender.transfer(outputAmount);
    } else {
      IERC20(outputToken).safeTransfer(msg.sender, outputAmount);
    }

    emit Swapped(msg.sender, inputToken, outputToken, inputAmount, outputAmount);
  }

  function addLiquidity(address inputToken, uint256 inputAmount, uint256 minLP)
    external
    payable
    onlyListedToken(inputToken)
    override
    returns (uint256 actualLP)
  {
    Config memory _config = DFPconfig;
    require(_config.unlocked, "DFP: Locked");

    uint256 initialBalance;
    if (inputToken == address(0)) {
      require(msg.value == inputAmount, "DFP: Incorrect amount of ETH");
      initialBalance = address(this).balance - inputAmount;
    } else {
      initialBalance = IERC20(inputToken).balanceOf(address(this));
      IERC20(inputToken).safeTransferFrom(msg.sender, address(this), inputAmount);
    }

    require(inputAmount < initialBalance, "DFP: Too much at once");

    uint256 X = (inputAmount * _config.oneMinusTradingFee) / initialBalance;  // 0.64 bits
    uint256 X_ = X * X;                                // X^2   0.128 bits
    uint256 R_ = (X >> 4) - (X_ * 15 >> 73);           // R2    0.64 bits
    X_ = X_ * X;                                       // X^3   0.192 bits
    R_ = R_ + (X_ * 155 >> 141);                       // R3    0.64 bits
    X_ = X_ * X >> 192;                                // X^4   0.64 bits
    R_ = R_ - (X_ * 7285 >> 19);                       // R4    0.64 bits
    X_ = X_ * X;                                       // X^5   0.128 bits
    R_ = R_ + (X_ * 91791 >> 87);                      // R5    0.64 bits
    X_ = X_ * X;                                       // X^6   0.192 bits
    R_ = R_ - (X_ * 2417163 >> 156);                   // R6    0.64 bits

    actualLP = R_ * totalSupply() >> 64;
    require(actualLP > minLP, "DFP: No deal");
    _mint(msg.sender, actualLP);

    emit LiquidityAdded(msg.sender, inputToken, inputAmount, actualLP);
  }

  function addMultiple(address[] calldata tokens, uint256[] calldata maxAmounts)
    external
    payable
    override
    returns (uint256 actualLP)
  {
    Config memory _config = DFPconfig;
    require(_config.unlocked, "DFP: Locked");
    require(tokens.length == 16, "DFP: Bad tokens array length");
    require(maxAmounts.length == 16, "DFP: Bad maxAmount array length");

    require(tokens[0] == address(0), "DFP: No ETH found");
    require(maxAmounts[0] == msg.value, "DFP: Incorrect ETH amount");
    uint256 dexBalance = address(this).balance - msg.value;
    uint256 actualRatio = msg.value * (1<<128) / dexBalance;

    uint256 currentRatio;
    address previous;
    address token;
    for (uint256 i = 1; i < 16; i++) {
      token = tokens[i];
      require(token > previous, "DFP: Require ordered list");
      require(
        listedTokens[token].state > State.Delisting,
        "DFP: Token not listed"
      );
      dexBalance = IERC20(token).balanceOf(address(this));
      currentRatio = maxAmounts[i] * (1 << 128) / dexBalance;
      if (currentRatio < actualRatio) {
        actualRatio = currentRatio;
      }
      previous = token;
    }

    actualLP = (actualRatio * totalSupply() >> 64) * DFPconfig.oneMinusTradingFee >> 128;

    for (uint256 i = 1; i < 16; i++) {
      token = tokens[i];
      dexBalance = IERC20(token).balanceOf(address(this));
      IERC20(token).safeTransferFrom(msg.sender, address(this), dexBalance * actualRatio >> 128);
    }

    _mint(msg.sender, actualLP);
    emit MultiLiquidityAdded(msg.sender, actualLP, totalSupply());

    dexBalance = address(this).balance - msg.value;
    address payable sender = payable(msg.sender);
    sender.transfer(msg.value - (dexBalance * actualRatio >> 128));
  }

  function removeLiquidity(uint256 LPamount, address outputToken, uint256 minOutputAmount)
    external
    onlyListedToken(outputToken)
    override
    returns (uint256 actualOutput)
  {
    uint256 initialBalance;
    if (outputToken == address(0)) {
      initialBalance = address(this).balance;
    } else {
      initialBalance = IERC20(outputToken).balanceOf(address(this));
    }

    uint256 F_;
    F_ = (1 << 64) - (LPamount << 64) / totalSupply();   // (1-R)      (0.64 bits)
    F_ = F_ * F_;                                       // (1-R)^2    (0.128 bits)
    F_ = F_ * F_ >> 192;                                // (1-R)^4    (0.64 bits)
    F_ = F_ * F_;                                       // (1-R)^8    (0.128 bits)
    F_ = F_ * F_ >> 192;                                // (1-R)^16   (0.64 bits)
    actualOutput = initialBalance * ((1 << 64) - F_) >> 64;
    require(actualOutput > minOutputAmount, "DFP: No deal");

    _burn(msg.sender, LPamount);
    if (outputToken == address(0)) {
      address payable sender = payable(msg.sender);
      sender.transfer(actualOutput);
    } else {
      IERC20(outputToken).safeTransfer(msg.sender, actualOutput);
    }

    emit LiquidityRemoved(msg.sender, outputToken, actualOutput, LPamount);
  }

  function removeMultiple(uint256 LPamount, address[] calldata tokens)
    external
    override
    returns (bool success)
  {
    require(tokens.length == 16, "DFP: Bad tokens array length");

    uint256 fraction = (LPamount << 128) / totalSupply();

    uint256 dexBalance = address(this).balance;
    address payable sender = payable(msg.sender);
    sender.transfer(fraction * dexBalance >> 128);

    address previous;
    for (uint256 i = 1; i < 16; i++) {
      address token = tokens[i];
      require(token > previous, "DFP: Require ordered list");
      require(
        listedTokens[token].state > State.Delisting,
        "DFP: Token not listed"
      );
      dexBalance = IERC20(token).balanceOf(address(this));
      IERC20(token).safeTransfer(msg.sender, fraction * dexBalance >> 128);
      previous = token;
    }

    _burn(msg.sender, LPamount);
    emit MultiLiquidityRemoved(msg.sender, LPamount, totalSupply());

    return true;
  }


  function bootstrapNewToken(
    address inputToken,
    uint256 maxInputAmount,
    address outputToken
  ) public override returns (uint64 fractionBootstrapped) {
    TokenSettings memory tokenToList = listedTokens[inputToken];
    require(
      tokenToList.state == State.PreListing,
      "DFP: Wrong token"
    );

    uint256 initialInputBalance = IERC20(inputToken).balanceOf(address(this));
    uint256 availableAmount;

    unchecked { availableAmount = tokenToList.listingTarget - initialInputBalance; }
    if (initialInputBalance >= tokenToList.listingTarget) { availableAmount = 1; }
    uint256 actualInputAmount = maxInputAmount > availableAmount ? availableAmount : maxInputAmount;

    IERC20(inputToken).safeTransferFrom(msg.sender, address(this), actualInputAmount);

    TokenSettings memory tokenToDelist = listedTokens[outputToken];
    require(
      tokenToDelist.state == State.Delisting,
      "DFP: Wrong token"
    );

    uint256 initialOutputBalance = IERC20(outputToken).balanceOf(address(this));
    uint256 outputAmount = actualInputAmount * initialOutputBalance / availableAmount;
    IERC20(outputToken).safeTransfer(msg.sender, outputAmount);
    fractionBootstrapped = uint64((actualInputAmount << 64) / tokenToList.listingTarget);

    emit Bootstrapped(
      msg.sender,
      inputToken,
      actualInputAmount,
      outputToken,
      outputAmount
    );

    if (actualInputAmount == availableAmount) {
      tokenToList.state = State.Listed;
      listedTokens[inputToken] = tokenToList;
      delete listedTokens[outputToken];
      delete listingUpdate;
      DFPconfig.delistingBonus = 0;
      emit BootstrapCompleted(outputToken, inputToken);
    }
  }

  function bootstrapNewTokenWithBonus(
    address inputToken,
    uint256 maxInputAmount,
    address outputToken,
    address bonusToken
  ) external onlyListedToken(bonusToken) override returns (uint256 bonusAmount) {
    TokenSettings memory tokenToDelist = listedTokens[outputToken];
    require(
      tokenToDelist.state == State.Delisting,
      "DFP: Wrong token"
    );

    uint256 bonusFactor = uint256(DFPconfig.delistingBonus);
    uint64 fractionBootstrapped = bootstrapNewToken(inputToken, maxInputAmount, outputToken);

    uint256 bonusBalance;
    if (bonusToken == address(0)) {
      bonusBalance = address(this).balance;
    } else {
      bonusBalance = IERC20(bonusToken).balanceOf(address(this));
    }

    bonusAmount = uint256(fractionBootstrapped) * bonusFactor * bonusBalance >> 128;

    if (bonusToken == address(0)) {
      address payable sender = payable(msg.sender);
      sender.transfer(bonusAmount);
    } else {
      IERC20(bonusToken).safeTransfer(msg.sender, bonusAmount);
    }

    emit BootstrapBonus(
      msg.sender,
      bonusToken,
      bonusAmount
    );
  }

  function changeListing(
    address tokenToDelist,              // Address of token to be delisted
    address tokenToList,                // Address of token to be listed
    uint112 listingTarget               // Amount of tokens needed to activate listing
  ) external onlyListedToken(tokenToDelist) onlyOwner() {
    require(tokenToDelist != address(0), "DFP: Cannot delist ETH");
    ListingUpdate memory update = listingUpdate;
    require(update.tokenToDelist == address(0), "DFP: Previous update incomplete");

    TokenSettings memory _token = listedTokens[tokenToList];
    require(_token.state == State.Unlisted, "DFP: Token already listed");

    update.tokenToDelist = tokenToDelist;
    update.tokenToList = tokenToList;
    listingUpdate = update;

    _token.state = State.PreListing;
    _token.listingTarget = listingTarget;
    listedTokens[tokenToList] = _token;
    listedTokens[tokenToDelist].state = State.Delisting;
  }

  function setTradingFee(uint64 oneMinusFee) external onlyOwner() {
    DFPconfig.oneMinusTradingFee = oneMinusFee;
  }

  function setDeListingBonus(uint64 delistingBonus) external onlyOwner() {
    ListingUpdate memory update = listingUpdate;
    require(update.tokenToDelist != address(0), "DFP: No active delisting");

    DFPconfig.delistingBonus = delistingBonus;
  }

  function setAdmin(address adminAddress) external onlyOwner() {
    admin = adminAddress;
  }

  function lockExchange() external onlyAdmin() {
    DFPconfig.unlocked = false;
  }

  function unlockExchange() external onlyAdmin() {
    DFPconfig.unlocked = true;
  }
}