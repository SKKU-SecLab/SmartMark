
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


contract ERC20 is Context {

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;
    string internal _symbol;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public view virtual returns (string memory) {

        return _name;
    }


    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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

}

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
}

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool status) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
pragma solidity ^0.8.0;


contract Aggregate is ERC20, Pausable, Ownable {



    struct FeeValues {
          uint256 Amount;
          uint256 TransferAmount;
          uint256 ReflectFee;
          uint256 MarketingFee;
          uint256 AcquisitionFee;
      }
    enum MarketSide {
      NONE,
      BUY,
      SELL
    }

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    address private _marketingWallet;
    address[5] private _acquisitionWallets;
    mapping (address => bool) private _isExchange;

    uint8 private _buyFeeReflect;
    uint8 private _buyFeeMarketing;
    uint8 private _buyFeeAcquisition;
    uint8 private _sellFeeReflect;
    uint8 private _sellFeeMarketing;
    uint8 private _sellFeeAcquisition;


    constructor (
      string memory name_,
      string memory symbol_,
      uint256 supply_,
      address marketing_,
      address[] memory acquisition_
      ) {

      _name = name_;
      _symbol = symbol_;
      _tTotal = supply_ * 10**4;
      _rTotal = (~uint256(0) - (~uint256(0) % _tTotal));
      _buyFeeReflect = 1;
      _buyFeeMarketing = 1;
      _buyFeeAcquisition = 7;
      _sellFeeReflect = 5;
      _sellFeeMarketing = 1;
      _sellFeeAcquisition = 3;
      _marketingWallet = marketing_;
      for(uint i = 0; i < _acquisitionWallets.length; i++) {
        _acquisitionWallets[i] = acquisition_[i];
      }

      _tOwned[_msgSender()] += _tTotal * 95 / 100;
      _rOwned[_msgSender()] += _rTotal / 100 * 95;
      emit Transfer(address(0), _msgSender(), _tOwned[_msgSender()]);

      _tOwned[_marketingWallet] += _tTotal * 2 / 100;
      _rOwned[_marketingWallet] += _rTotal / 100 * 2;
      emit Transfer(address(0), _marketingWallet, _tTotal * 2 / 100);

      for(uint i = 0; i < _acquisitionWallets.length; i++){
        _tOwned[_acquisitionWallets[i]] +=
          _tTotal * 3 / 100 / _acquisitionWallets.length;
        _rOwned[_acquisitionWallets[i]] +=
          _rTotal / 100 * 3 / _acquisitionWallets.length;

        emit Transfer(
          address(0),
          _acquisitionWallets[i],
          _tTotal * 3 / 100 / _acquisitionWallets.length
          );
      }

    }


    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function decimals() public pure override returns (uint8) {

        return 4;
    }

    function _transfer(
      address sender,
      address recipient,
      uint256 amount
      ) internal override whenNotPaused {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        MarketSide _side;
        if(_isExchange[sender]){
            _side = MarketSide.BUY;
        } else if(_isExchange[recipient]) {
            _side = MarketSide.SELL;
        } else {
            _side = MarketSide.NONE;
        }

        _transferStandard(sender, recipient, amount, _side);
    }


    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total supply");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function isExcluded(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function getMarketingWallet() public view returns (address){

      return _marketingWallet;
    }

    function getAcquisitionWallet(uint256 index) public view returns (address){

      require(index < _acquisitionWallets.length, "Invalid index");
      return _acquisitionWallets[index];
    }

    function totalFees() public view returns (uint256) {

        return _tFeeTotal;
    }


    function _transferStandard(
      address sender,
      address recipient,
      uint256 tAmount,
      MarketSide _side
      ) private {


        (
          FeeValues memory _tValues,
          FeeValues memory _rValues
          ) = _getValues(tAmount, _side);

        if(_isExcluded[sender]){
          _tOwned[sender] -= _tValues.Amount;
          _rOwned[sender] -= _rValues.Amount;
        } else {
          _rOwned[sender] -= _rValues.Amount;
        }

        if(_isExcluded[recipient]){
          _tOwned[recipient] += _tValues.TransferAmount;
          _rOwned[recipient] += _rValues.TransferAmount;
        } else {
          _rOwned[recipient] += _rValues.TransferAmount;
        }
        emit Transfer(sender, recipient, _tValues.TransferAmount);

        if(_side != MarketSide.NONE){
          _reflectFee(_rValues.ReflectFee, _tValues.ReflectFee);
          if(_tValues.MarketingFee > 0) {
            if(_isExcluded[_marketingWallet]){
              _tOwned[_marketingWallet] += _tValues.MarketingFee;
              _rOwned[_marketingWallet] += _rValues.MarketingFee;
            } else {
              _rOwned[_marketingWallet] += _rValues.MarketingFee;
            }
            emit Transfer(sender, _marketingWallet, _tValues.MarketingFee);
          }

          if(_tValues.AcquisitionFee > 0) {
            _acquisitionWalletAlloc(
              sender, _tValues.AcquisitionFee,
              _rValues.AcquisitionFee
              );
          }
        }
    }

    function _acquisitionWalletAlloc(
      address sender,
      uint256 tAmount,
      uint256 rAmount
      ) private {

        uint256 _tAllocation = tAmount / _acquisitionWallets.length;
        uint256 _rAllocation = rAmount / _acquisitionWallets.length;

        for(uint i = 0; i < _acquisitionWallets.length; i++){
          if(_isExcluded[_acquisitionWallets[i]]){
            _tOwned[_acquisitionWallets[i]] += _tAllocation;
            _rOwned[_acquisitionWallets[i]] += _rAllocation;
          } else {
            _rOwned[_acquisitionWallets[i]] += _rAllocation;
          }
          emit Transfer(sender, _acquisitionWallets[i], _tAllocation);
        }
    }


    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(
      uint256 tAmount,
      MarketSide _side
      ) private view returns (
        FeeValues memory tValues_,
        FeeValues memory rValues_
        ) {


        uint256 currentRate =  _getRate();
        FeeValues memory _tValues = _getTValues(tAmount, _side);
        FeeValues memory _rValues = _getRValues(_tValues, currentRate);

        return (_tValues, _rValues);
    }

    function _getTValues(
      uint256 tAmount,
      MarketSide _side
      ) private view returns (FeeValues memory) {

        (
          uint8 feeReflect_,
          uint8 feeMarketing_,
          uint8 feeAcquisition_
          ) = _getFeeValues(_side);

        FeeValues memory _tValues;
        _tValues.Amount = tAmount;
        _tValues.ReflectFee = tAmount * feeReflect_ / 100;
        _tValues.MarketingFee = tAmount * feeMarketing_ / 100;
        _tValues.AcquisitionFee = tAmount * feeAcquisition_ / 100;
        _tValues.TransferAmount =
          _tValues.Amount
          - _tValues.ReflectFee
          - _tValues.MarketingFee
          - _tValues.AcquisitionFee;

        return (_tValues);
    }

    function _getRValues(
      FeeValues memory _tValues,
      uint256 currentRate
      ) private pure returns (FeeValues memory) {


        FeeValues memory _rValues;
        _rValues.Amount = _tValues.Amount * currentRate;
        _rValues.ReflectFee = _tValues.ReflectFee * currentRate;
        _rValues.MarketingFee = _tValues.MarketingFee * currentRate;
        _rValues.AcquisitionFee = _tValues.AcquisitionFee * currentRate;
        _rValues.TransferAmount =
          _rValues.Amount
          - _rValues.ReflectFee
          - _rValues.MarketingFee
          - _rValues.AcquisitionFee;

        return (_rValues);
    }

    function _getRate() private view returns (uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getFeeValues(MarketSide _side) private view returns (
      uint8,
      uint8,
      uint8
      ) {

        if(_side == MarketSide.BUY){
            return (_buyFeeReflect, _buyFeeMarketing, _buyFeeAcquisition);
        } else if(_side == MarketSide.SELL){
            return (_sellFeeReflect, _sellFeeMarketing, _sellFeeAcquisition);
        } else {
            return (0, 0, 0);
        }
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
          if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
          return (_rTotal, _tTotal);

          rSupply = rSupply - _rOwned[_excluded[i]];
          tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }


    function setExchange(address exchangePair) external onlyOwner {

        require(!_isExchange[exchangePair], "Address already Exchange");
        _isExchange[exchangePair] = true;
    }

    function removeExchange(address exchangePair) external onlyOwner {

        require(_isExchange[exchangePair], "Address not Exchange");
        _isExchange[exchangePair] = false;
    }

    function changeMarketing(address newAddress) external onlyOwner {

        require(newAddress != address(0), "Address cannot be zero address");
        _marketingWallet = newAddress;
    }

    function changeAcquisition(
      uint256 index,
      address newAddress
      ) external onlyOwner {

        require(index < _acquisitionWallets.length, "Invalid index value");
        require(newAddress != address(0), "Address cannot be zero address");
        _acquisitionWallets[index] = newAddress;
    }

    function setBuyFees(
      uint8 reflectFee,
      uint8 marketingFee,
      uint8 acquisitionFee
      ) external onlyOwner {

        require(reflectFee + marketingFee + acquisitionFee < 100,
          "Total fee percentage must be less than 100%"
          );

        _buyFeeReflect = reflectFee;
        _buyFeeMarketing = marketingFee;
        _buyFeeAcquisition = acquisitionFee;
    }

    function setSellFees(
      uint8 reflectFee,
      uint8 marketingFee,
      uint8 acquisitionFee
      ) external onlyOwner {

        require(reflectFee + marketingFee + acquisitionFee < 100,
          "Total fee percentage must be less than 100%"
          );

        _sellFeeReflect = reflectFee;
        _sellFeeMarketing = marketingFee;
        _sellFeeAcquisition = acquisitionFee;
    }

    function excludeAccount(address account) external onlyOwner {

        require(!_isExcluded[account], "Account already excluded");
        require(balanceOf(account) < _tTotal, "Cannot exclude total supply");
         _tOwned[account] = balanceOf(account);
         _excluded.push(account);
        _isExcluded[account] = true;
    }

    function includeAccount(address account) external onlyOwner {

      require(_isExcluded[account], "Account already included");

      for (uint256 i = 0; i < _excluded.length; i++) {
        if (_excluded[i] == account) {
          _excluded[i] = _excluded[_excluded.length - 1];
          _excluded.pop();
          _isExcluded[account] = false;
          break;
        }
      }
    }

    function lockToken() external onlyOwner {

        _pause();
    }

    function unlockToken() external onlyOwner {

        _unpause();
    }
}
