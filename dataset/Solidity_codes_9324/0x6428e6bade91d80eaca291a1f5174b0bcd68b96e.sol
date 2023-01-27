pragma solidity ^0.8.9;

interface IERC20 {

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
}// MIT
pragma solidity ^0.8.9;

contract Context {

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }
}

contract Ownable is Context {

    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address tokenOwner) {
        _transferOwnership(tokenOwner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner returns(bool) {

        _transferOwnership(address(0));
        return true;
    }
    
    function transferOwnership(address newOwner) public onlyOwner returns(bool){

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
        return true;
    }

    function _transferOwnership(address newOwner) internal {

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.9;

contract Token is IERC20, Ownable {


    string private _name;
    string private _symbol;

    uint8 private _decimals;
    uint8 constant MAX_TAX_FEE_RATE = 6;
    uint8[4] private taxPercentages;
    uint8 public taxFee;
    uint256 public _totalSupply;
    uint256 public whaleAmount;
    uint256 public totalVestings;


    bool public antiWhale;
    bool public _enableTax;

    address[4] public taxAddresses;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(uint256 => VestingDetails) public vestingID;
    mapping(address => uint256[]) receiverIDs;
    mapping(address => bool) isWhitelistedFromWhaleAmount;

    enum taxAddressType {
        taxAddressNewMovies,
        taxAddressProfit,
        taxAddressDevelopment,
        taxAddressUserCredit
    }

    event whaleAmountUpdated(
        uint256 oldAmount,
        uint256 newAmount,
        uint256 time
    );
    event antiWhaleUpdated(bool status, uint256 time);
    event taxAddressUpdated(address taxAddress, uint256 time, string info);
    event UpdatedWhitelistedAddress(address _address, bool isWhitelisted);
    event TaxTransfer(
        address indexed from,
        address[4] indexed to,
        uint256[4] indexed value
    );

    struct VestingDetails {
        address receiver;
        uint256 amount;
        uint256 release;
        bool expired;
    }

    constructor(
        string memory __name,
        string memory __symbol,
        uint8 __decimals,
        uint8 _taxPercent,
        uint256 __totalSupply,
        bool _antiWhale,
        uint256 _whaleAmount,
        address owner,
        address[4] memory _taxAddresses,
        uint8[4] memory _taxPercentages
    ) Ownable(owner) {
        require(owner != address(0), "Owner can't be zero address");
        require(
            _taxAddresses[0] != address(0) &&
                _taxAddresses[1] != address(0) &&
                _taxAddresses[2] != address(0) &&
                _taxAddresses[3] != address(0),
            "Tax addresses cannot be zero address"
        );
        require(_taxPercent <= MAX_TAX_FEE_RATE, "Exceeded max tax rate limit");
        require(
            _taxPercentages[0] +
                _taxPercentages[1] +
                _taxPercentages[2] +
                _taxPercentages[3] ==
                100,
            "Total percentages must equal 100"
        );
        require(_whaleAmount < __totalSupply, "Whale amount must be lower than total supply");

        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
        _owner = owner;
        whaleAmount = _whaleAmount * 10**__decimals;
        antiWhale = _antiWhale;
        _totalSupply = __totalSupply * 10**__decimals;
        taxFee = _taxPercent;
        _enableTax = true;

        _balances[_owner] = _totalSupply;

        taxAddresses[uint256(taxAddressType.taxAddressDevelopment)] = _taxAddresses[uint256(taxAddressType.taxAddressDevelopment)];
        taxAddresses[uint256(taxAddressType.taxAddressNewMovies)] = _taxAddresses[uint256(taxAddressType.taxAddressNewMovies)];
        taxAddresses[uint256(taxAddressType.taxAddressProfit)] = _taxAddresses[uint256(taxAddressType.taxAddressProfit)];
        taxAddresses[uint256(taxAddressType.taxAddressUserCredit)] = _taxAddresses[uint256(taxAddressType.taxAddressUserCredit)];

        taxPercentages[uint256(taxAddressType.taxAddressDevelopment)] = _taxPercentages[uint256(taxAddressType.taxAddressDevelopment)];
        taxPercentages[uint256(taxAddressType.taxAddressNewMovies)] = _taxPercentages[uint256(taxAddressType.taxAddressNewMovies)];
        taxPercentages[uint256(taxAddressType.taxAddressProfit)] = _taxPercentages[uint256(taxAddressType.taxAddressProfit)];
        taxPercentages[uint256(taxAddressType.taxAddressUserCredit)] = _taxPercentages[uint256(taxAddressType.taxAddressUserCredit)];

        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[taxAddresses[uint256(taxAddressType.taxAddressDevelopment)]] = true;
        _isExcludedFromFee[taxAddresses[uint256(taxAddressType.taxAddressNewMovies)]] = true;
        _isExcludedFromFee[taxAddresses[uint256(taxAddressType.taxAddressProfit)]] = true;
        _isExcludedFromFee[taxAddresses[uint256(taxAddressType.taxAddressUserCredit)]] = true;

        isWhitelistedFromWhaleAmount[_owner] = true;
        isWhitelistedFromWhaleAmount[address(this)] = true;
        isWhitelistedFromWhaleAmount[taxAddresses[uint256(taxAddressType.taxAddressDevelopment)]] = true;
        isWhitelistedFromWhaleAmount[taxAddresses[uint256(taxAddressType.taxAddressNewMovies)]] = true;
        isWhitelistedFromWhaleAmount[taxAddresses[uint256(taxAddressType.taxAddressProfit)]] = true;
        isWhitelistedFromWhaleAmount[taxAddresses[uint256(taxAddressType.taxAddressUserCredit)]] = true;


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

    function updateWhaleAmount(uint256 _amount)
        external
        onlyOwner
        returns (bool _success)
    {

        require(antiWhale, "Anti whale is turned off");
        uint256 oldAmount = whaleAmount;
        whaleAmount = _amount;
        emit whaleAmountUpdated(oldAmount, whaleAmount, block.timestamp);
        return true;    
    }

    function updateAntiWhale(bool status) external onlyOwner returns (bool _success) {

        antiWhale = status;
        emit antiWhaleUpdated(antiWhale, block.timestamp);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool _success) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal returns (bool _success) {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool _success)
    {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool _success)
    {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] - subtractedValue
        );
        return true;
    }

    function updateWhitelistedAddressFromWhale(address _address, bool _isWhitelisted) public onlyOwner
    returns(bool success){

        isWhitelistedFromWhaleAmount[_address] = _isWhitelisted;
        emit UpdatedWhitelistedAddress(_address, _isWhitelisted);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool _success) {

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external returns (bool _success) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function multiSend(
        address[] memory users,
        uint256[] memory amounts,
        uint256 totalSum
    ) external returns (bool _success) {

        require(users.length == amounts.length, "Length mismatch");
        require(totalSum <= balanceOf(msg.sender), "Not enough balance");

        for (uint256 i = 0; i < users.length; i++) {
            _transfer(msg.sender, users[i], amounts[i]);
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool _success) {

        
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool isTaxed = _enableTax &&
            (!(_isExcludedFromFee[from] || _isExcludedFromFee[to]));

        if (antiWhale) {
            uint256 tax_amount = 0;
            if (isTaxed) tax_amount = (amount * taxFee) / 10**2;
            require(
                (amount - tax_amount) <= whaleAmount,
                "Transfer amount exceeds max amount"
            );
            if(!isWhitelistedFromWhaleAmount[to]){
                require(
                    balanceOf(to) + amount - tax_amount <= whaleAmount,
                    "Recipient amount exceeds max amount"
                );
            }
        }
        unchecked {
            require(balanceOf(from) >= amount, "Amount exceeds balance");
            _balances[from] = _balances[from] - amount;
        }

        if (!isTaxed) {
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        } else {
            uint256 tax_amount = (amount * taxFee) / (10**2);

            _transferFee(tax_amount);

            _balances[to] += amount - tax_amount;
            emit Transfer(from, to, amount - tax_amount);
        }
        return true;
    }

    function _transferFee(uint256 tax) private returns (bool _success) {

        uint8[4] storage taxRatios = taxPercentages;
        address[4] storage _taxAddresses = taxAddresses;
        uint256 taxAmountDevelopment = (tax * taxRatios[uint256(taxAddressType.taxAddressDevelopment)]) / (100);
        uint256 taxAmountNewMovies = (tax * taxRatios[uint256(taxAddressType.taxAddressNewMovies)]) / (100);
        uint256 taxAmountProfit = (tax * taxRatios[uint256(taxAddressType.taxAddressProfit)]) / (100);
        uint256 taxAmountUserCredit = (tax * taxRatios[uint256(taxAddressType.taxAddressUserCredit)]) / (100);

        _balances[_taxAddresses[uint256(taxAddressType.taxAddressDevelopment)]] += taxAmountDevelopment ;
        _balances[_taxAddresses[uint256(taxAddressType.taxAddressNewMovies)]] += taxAmountNewMovies;
        _balances[_taxAddresses[uint256(taxAddressType.taxAddressProfit)]] += taxAmountProfit;

        uint256 totalDivided = taxAmountDevelopment + taxAmountNewMovies + taxAmountProfit + taxAmountUserCredit;

        _balances[_taxAddresses[uint256(taxAddressType.taxAddressUserCredit)]] += taxAmountUserCredit + tax - (totalDivided);

        return true;
    }

    function isExcludedFromFee(address account) public view returns (bool _success) {

        return _isExcludedFromFee[account];
    }

    function isTaxApplicable(bool applicable)
        external
        onlyOwner
        returns (bool _success)
    {

        if (_enableTax != applicable) {
            _enableTax = applicable;
            return true;
        }
        return false;
    }

    function changeTaxAddress(address newAddress, taxAddressType _type)
        external
        onlyOwner
        returns (bool _success)
    {   

        includeInFee(taxAddresses[uint256(_type)]);
        updateWhitelistedAddressFromWhale(taxAddresses[uint256(_type)], false);
        updateWhitelistedAddressFromWhale(newAddress, true);
        excludeFromFee(newAddress);
        taxAddresses[uint256(_type)] = newAddress;
        
        return true;

    }

    function changeTaxPercentages(uint8[4] calldata _taxPercentages)
        external
        onlyOwner
        returns (bool _success)
    {

        require(
            _taxPercentages[0] +
                _taxPercentages[1] +
                _taxPercentages[2] +
                _taxPercentages[3] ==
                100,
            "Total percentages must equal 100"
        );
        taxPercentages[uint256(taxAddressType.taxAddressDevelopment)] = _taxPercentages[uint256(taxAddressType.taxAddressDevelopment)];
        taxPercentages[uint256(taxAddressType.taxAddressNewMovies)] = _taxPercentages[uint256(taxAddressType.taxAddressNewMovies)];
        taxPercentages[uint256(taxAddressType.taxAddressProfit)] = _taxPercentages[uint256(taxAddressType.taxAddressProfit)];
        taxPercentages[uint256(taxAddressType.taxAddressUserCredit)] = _taxPercentages[uint256(taxAddressType.taxAddressUserCredit)];
        return true;
    }

    function changeTaxFeePercent(uint8 _taxFee) external onlyOwner returns (bool _success) {

        require(_taxFee <= MAX_TAX_FEE_RATE, "Exceeded max tax rate");
        taxFee = _taxFee;
        return true;
    }

    function excludeFromFee(address account) public onlyOwner returns (bool _success) {

        _isExcludedFromFee[account] = true;
        return true;
    }

    function includeInFee(address account) public onlyOwner returns (bool _success) {

        _isExcludedFromFee[account] = false;
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function createVesting(
        address _receiver,
        uint256 _amount,
        uint256 _release
    ) public returns (bool _success) {

        require(_receiver != address(0), "Zero receiver address");
        require(_amount > 0, "Zero amount");
        require(_release > block.timestamp, "Incorrect release time");

        totalVestings++;
        vestingID[totalVestings] = VestingDetails(
            _receiver,
            _amount,
            _release,
            false
        );
        receiverIDs[_receiver].push(totalVestings);
        require(_transfer(msg.sender, address(this), _amount));
        return true;
    }

    function createMultipleVesting(
        address[] memory _receivers,
        uint256[] memory _amounts,
        uint256[] memory _releases
    ) external returns (bool _success) {

        require(
            _receivers.length == _amounts.length &&
                _amounts.length == _releases.length,
            "Invalid data"
        );
        for (uint256 i = 0; i < _receivers.length; i++) {
            bool success = createVesting(
                _receivers[i],
                _amounts[i],
                _releases[i]
            );
            require(success, "Creation of vesting failed");
        }
        return true;
    }

    function getReleaseTime(uint256 id) public view returns(uint256){

        require(id > 0 && id <= totalVestings, "Id out of bounds");
        VestingDetails storage vestingDetail = vestingID[id];
        require(!vestingDetail.expired, "ID expired");
        return vestingDetail.release;
    }

    function claim(uint256 id) external returns (bool _success) {

        require(id > 0 && id <= totalVestings, "Id out of bounds");
        VestingDetails storage vestingDetail = vestingID[id];
        require(msg.sender == vestingDetail.receiver, "Caller is not the receiver");
        require(!vestingDetail.expired, "ID expired");
        require(
            block.timestamp >= vestingDetail.release,
            "Release time not reached"
        );
        vestingID[id].expired = true;
        require(_transfer(
            address(this),
            vestingDetail.receiver,
            vestingDetail.amount
        ));
        return true;
    }

    function getReceiverIDs(address user)
        external
        view
        returns (uint256[] memory)
    {

        return receiverIDs[user];
    }
}