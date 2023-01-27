
pragma solidity 0.8.10;

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

contract AgroToken is IERC20 {

    event Mint(address indexed _to, uint256 _amount, uint256 _newTotalSupply);
    event Burn(address indexed _from, uint256 _amount, uint256 _newTotalSupply);

    event BlockLockSet(uint256 _value);
    event NewAdmin(address _newAdmin);
    event NewManager(address _newManager);
    event GrainStockChanged(
        uint256 indexed contractId,
        string grainCategory,
        string grainContractInfo,
        uint256 amount,
        uint8 status,
        uint256 newTotalSupplyAmount
    );

    modifier onlyAdmin {

        require(msg.sender == admin, "Only admin can perform this operation");
        _;
    }    

    modifier boardOrAdmin {

        require(
            msg.sender == board || msg.sender == admin,
            "Only admin or board can perform this operation"
        );
        _;
    }

    modifier blockLock(address _sender) {

        require(
            !isLocked() || _sender == admin,
            "Contract is locked except for the admin"
        );
        _;
    }

    struct Grain {
        string category;
        string contractInfo;
        uint256 amount;
        uint8 status;
    }

    uint256 override public totalSupply;
    string public name;
    uint8 public decimals;
    string public symbol;
    address public admin;
    address public board;    
    uint256 public lockedUntilBlock;
    uint256 public tokenizationFee;
    uint256 public deTokenizationFee;
    uint256 public transferFee;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    Grain[] public grains;

    constructor() {
        name = "AgroToken Wheat Argentina";
        decimals = 4;
        symbol = "WHEA";
        lockedUntilBlock = 0;
        admin = msg.sender;
        board = 0xA01cD92f06f60b9fdcCCdF6280CE9A10803bA720;
        totalSupply = 0;
        balances[address(this)] = totalSupply;
    }
    

    function addNewGrainContract(        
        string memory _grainCategory,
        string memory _grainContractInfo,
        uint256 _grainAmount
    ) public onlyAdmin returns (bool success) {

        Grain memory newGrain = Grain(
            _grainCategory,
            _grainContractInfo,
            _grainAmount,
            1
        );
        grains.push(newGrain);
        _mint(address(this), _grainAmount);
        emit GrainStockChanged(
            grains.length-1,
            _grainCategory,
            _grainContractInfo,
            _grainAmount,
            1,
            totalSupply
        );
        success = true;
        return success;
    }

    function removeGrainContract(uint256 _contractIndex) public onlyAdmin returns (bool) {

        require(
            _contractIndex < grains.length,
            "Invalid contract index number. Greater than total grain contracts"
        );
        Grain storage grain = grains[_contractIndex];
        require(grain.status == 1, "This contract is no longer active");
        require(_burn(address(this), grain.amount), "Could not to burn tokens");
        grain.status = 0;
        emit GrainStockChanged( 
            _contractIndex,           
            grain.category,
            grain.contractInfo,
            grain.amount,
            grain.status,
            totalSupply
        );
        return true;
    }

    function updateGrainContract(
        uint256 _contractIndex,
        string memory _grainCategory,
        string memory _grainContractInfo,
        uint256 _grainAmount
    ) public onlyAdmin returns (bool) {

        require(
            _contractIndex < grains.length,
            "Invalid contract index number. Greater than total grain contracts"
        );
        require(_grainAmount > 0, "Cannot set zero asset amount");
        Grain storage grain = grains[_contractIndex];
        require(grain.status == 1, "This contract is no longer active");
        grain.category = _grainCategory;
        grain.contractInfo = _grainContractInfo;
        if (grain.amount > _grainAmount) {
            _burn(address(this), grain.amount - _grainAmount);
        } else if (grain.amount < _grainAmount) {
            _mint(address(this), _grainAmount - grain.amount);           
        }
        grain.amount = _grainAmount;
        emit GrainStockChanged(
            _contractIndex,
            grain.category,
            grain.contractInfo,
            grain.amount,
            grain.status,
            totalSupply
        );
        return true;
    }

    function totalContracts() public view returns (uint256) {

        return grains.length;
    }

    function transfer(address _to, uint256 _value)
        override
        external
        blockLock(msg.sender)
        returns (bool)
    {

        address from = (admin == msg.sender) ? address(this) : msg.sender;
        require(
            isTransferValid(from, _to, _value),
            "Invalid Transfer Operation"
        );
        balances[from] = balances[from] - _value;
        uint256 serviceAmount = 0;
        uint256 netAmount = _value;      
        (serviceAmount, netAmount) = calcFees(transferFee, _value); 
        balances[_to] = balances[_to] + netAmount;
        balances[address(this)] = balances[address(this)] + serviceAmount;
        emit Transfer(from, _to, netAmount);
        emit Transfer(from, address(this), serviceAmount);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value)
        override
        external
        blockLock(_from)
        returns (bool)
    {

        require(
            _value <= allowed[_from][msg.sender],
            "Value informed is invalid"
        );
        require(
            isTransferValid(_from, _to, _value),
            "Invalid Transfer Operation"
        );
        balances[_from] = balances[_from] - _value;
        uint256 serviceAmount = 0;
        uint256 netAmount = _value;      
        (serviceAmount, netAmount) = calcFees(transferFee, _value); 
        balances[_to] = balances[_to] + netAmount;
        balances[address(this)] = balances[address(this)] + serviceAmount;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;

        emit Transfer(_from, _to, netAmount);
        emit Transfer(_from, address(this), serviceAmount);
        return true;
    }

    function approve(address _spender, uint256 _value)
        override
        external
        blockLock(msg.sender)
        returns (bool)
    {

        require(_spender != address(0), "ERC20: approve to the zero address");

        address from = (admin == msg.sender) ? address(this) : msg.sender;
        require((_value == 0) || (allowed[from][_spender] == 0), "Allowance cannot be increased or decreased if value is different from zero");
        allowed[from][_spender] = _value;
        emit Approval(from, _spender, _value);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public virtual returns (bool) {

        require(_spender != address(0), "ERC20: decreaseAllowance to the zero address");

        address from = (admin == msg.sender) ? address(this) : msg.sender;
        require(allowed[from][_spender] >= _subtractedValue, "ERC20: decreased allowance below zero");
        _approve(from, _spender, allowed[from][_spender] - _subtractedValue);

        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public virtual returns (bool) {

        require(_spender != address(0), "ERC20: decreaseAllowance to the zero address");

        address from = (admin == msg.sender) ? address(this) : msg.sender;
        _approve(from, _spender, allowed[from][_spender] + _addedValue);
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _amount) internal virtual {

        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowed[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function withdraw(address _to, uint256 _value)
        external
        boardOrAdmin
        returns (bool)
    {

        address from = address(this);
        require(
            isTransferValid(from, _to, _value),
            "Invalid Transfer Operation"
        );
        balances[from] = balances[from] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(from, _to, _value);
        return true;
    }

    function _mint(address _to, uint256 _value)
        internal
        onlyAdmin        
        returns (bool)
    {

        require(_to != address(0), "ERC20: mint to the zero address");
        require(_to != admin, "Admin cannot mint tokens to herself");
        uint256 serviceAmount;
        uint256 netAmount;
        (serviceAmount, netAmount) = calcFees(tokenizationFee, _value);

        balances[_to] = balances[_to] + netAmount;
        balances[address(this)] = balances[address(this)] + serviceAmount;
        totalSupply = totalSupply + _value;

        emit Mint(_to, netAmount, totalSupply);
        emit Mint(address(this), serviceAmount, totalSupply);
        emit Transfer(address(0), _to, netAmount);
        emit Transfer(address(0), address(this), serviceAmount);

        return true;
    }

    function _burn(address _account, uint256 _value)
        internal        
        onlyAdmin
        returns (bool)
    {

        require(_account != address(0), "ERC20: burn from the zero address");
        uint256 serviceAmount;
        uint256 netAmount;
        (serviceAmount, netAmount) = calcFees(deTokenizationFee, _value);
        totalSupply = totalSupply - netAmount;
        balances[_account] = balances[_account] - _value;
        balances[address(this)] = balances[address(this)] + serviceAmount;
        emit Transfer(_account, address(0), netAmount);
        emit Transfer(_account, address(this), serviceAmount);
        emit Burn(_account, netAmount, totalSupply);        
        return true;
    }

    function setBlockLock(uint256 _lockedUntilBlock)
        public
        boardOrAdmin
        returns (bool)
    {

        lockedUntilBlock = _lockedUntilBlock;
        emit BlockLockSet(_lockedUntilBlock);
        return true;
    }

    function replaceAdmin(address _newAdmin)
        public
        boardOrAdmin
        returns (bool)
    {

        require(_newAdmin != address(0x0), "Null address");
        admin = _newAdmin;
        emit NewAdmin(_newAdmin);
        return true;
    }

    function changeFee(uint8 _feeType, uint256 _newAmount) external boardOrAdmin returns (bool) {

        require(_newAmount<=2, "Invalid or exceed white paper definition");
        require(_feeType >0 && _feeType<=3, "Invalid fee type");
        if (_feeType == 1) {
            tokenizationFee = _newAmount;
        } else if (_feeType == 2) {
            deTokenizationFee = _newAmount;
        } else if (_feeType == 3) {
            transferFee = _newAmount;
        }
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256) {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender)
        override
        external
        view
        returns (uint256)
    {

        return allowed[_owner][_spender];
    }

    function isLocked() public view returns (bool) {

        return lockedUntilBlock > block.number;
    }

    function isTransferValid(address _from, address _to, uint256 _amount)
        public
        view
        returns (bool)
    {

        if (_from == address(0)) {
            return false;
        }

        if (_to == address(0) || _to == admin) {
            return false;
        }

        bool fromOK = true;
        bool toOK = true;

        return
            balances[_from] >= _amount && // sufficient balance
            fromOK && // a seller holder within the whitelist
            toOK; // a buyer holder within the whitelist
    }

    function calcFees(uint256 _fee, uint256 _amount) public pure returns(uint256 serviceAmount, uint256 netAmount ) {

        serviceAmount = (_amount * _fee) / 100;
        netAmount = _amount - serviceAmount;
        return (serviceAmount, netAmount);
    }
}