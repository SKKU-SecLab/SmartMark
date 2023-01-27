

pragma solidity ^0.7.0;

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

}


contract Proxiable {

    function updateCodeAddress(address newAddress) internal {

        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }
    function proxiableUUID() public pure returns (bytes32) {

        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}


interface iLANDID {

    function adminRightsOf(address _admin) external view returns(int16);

}


contract Storage {


    address public owner;
    bytes32 internal relinquishmentToken;
    bool public standalone = false;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    uint256 internal _cap;

    iLANDID landid;
    address public landidNftAddress;
    address internal landRegistration;
    bool public landRegistryOpened = false;
    uint[] public recordRightsOffers;
    struct RecordRight {
        uint time;
        uint tokenId;
        uint right;
    }
    mapping (address => RecordRight[]) public registryRecordRights;

    bool _mintingFinished = false;

    bool public initialized = false;
    address public team;
    address public reserve;
}


contract Context is Storage {

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }
}


contract Ownable is Context {


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {

        require(!standalone, 'denied : owner actions are locked when contract is running standalone');
        require(_msgSender() != address(0), "denied : zero address has no rights");
        require(_msgSender() == owner, "denied : method access is restricted to the contract owner");
        _;
    }

    function getRelinquishmentToken() public onlyOwner view returns (bytes32 _relinquishmentToken) {

        return relinquishmentToken;
    }

    function renounceOwnership(bytes32 _relinquishmentToken) public onlyOwner {

        require(
            ((relinquishmentToken != bytes32(0)) && (relinquishmentToken == _relinquishmentToken)), 
            'denied : a relinquishment token must be pre-set calling the preRenounceOwnership method');
        emit OwnershipRenounced(owner);
        standalone = true;
        owner = address(0);
    }

    function preRenounceOwnership() public onlyOwner returns(bytes32 _relinquishmentToken) {

        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, uint8(_msgSender()))));
        bytes32 salt = bytes32(rand);
        relinquishmentToken = salt;
        _relinquishmentToken = salt;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0), "the new owner can't be the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
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


contract ERC20 is Ownable, IERC20 {

    using SafeMath for uint256;

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

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: can't burn from the zero address");

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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { 

        bool hasFrom = from != address(0);
        bool hasTo = to != address(0);
        require((hasFrom || hasTo), 'Must provide at least one address to transfer');
        if(hasFrom && hasTo) {
            require(_balances[from] >= amount, 'not enough funds to transfer');
        }
        else if (!hasFrom) {
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");

        }
        else if (!hasTo) {
            require(_balances[from] >= amount, 'not enough funds to burn');
        }
    }
}


contract ERC20Capped is ERC20 {

    using SafeMath for uint256;


    function setImmutableCap(uint256 cap_) internal {

        require(cap() == 0, 'cap value is immutable and is already set to 1 Billion ELAND');
        require(cap_ > 0, "cap must be higher than 0");
        _cap = cap_;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

}


contract ERC20Burnable is ERC20Capped {

    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {

        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


contract ERC20Mintable is ERC20Burnable {

    using SafeMath for uint256;

    event Mint(address indexed to, uint256 amount);

    function mintingFinished() public view returns(bool){

        return _mintingFinished;
    }

    function mint(
        address _to,
        uint256 _amount
    )
        internal
        returns (bool)
    {

        require(mintingFinished() == false, 'ERC20Mintable : Minting is finished');
        _mint(_to, _amount);
        Mint(_to, _amount);
        return true;
    }

}


contract LandRegistry is ERC20Mintable {


    modifier isNftAdmin() {

        landid = iLANDID(landidNftAddress);
        int16 adminRight = landid.adminRightsOf(_msgSender());
        require((adminRight > 0) && (adminRight < 3), 'denied : restricted to LANDID NFT admins');
        _;
    }

    function setRecordRightsOffers(uint[] memory _indexedRecordOffers) public isNftAdmin returns (bool) {

        recordRightsOffers = _indexedRecordOffers;
        return true;
    }

    function openLandRegistry() public isNftAdmin returns (bool) {

        landRegistryOpened = true;
        return true;
    }

    function closeLandRegistry() public isNftAdmin returns (bool) {

        landRegistryOpened = false;
        return true;
    }

    function registerLand(uint recordIndex) public returns (bool) {

        require(landRegistryOpened && (landRegistration != address(0)), "denied : can't register new land for now");

        uint recordPrice = recordRightsOffers[recordIndex];
        require(recordPrice > 0, 'denied : no preset price for provided record right');

        bool transferred = transfer(landRegistration, recordPrice);
        require(transferred, 'denied : value corresponding to requested record right price has not been transferred');

        RecordRight memory recordRight;
        recordRight.time = block.timestamp;
        recordRight.right = recordIndex;

        registryRecordRights[_msgSender()].push(recordRight);

        return true;
    }

    function validRecordRight(uint time, uint tokenId) internal pure returns(bool) {

        return(
            (time > 0)
            && (tokenId == 0)
        );
    }

    function consumeRecordRight(address _owner, uint recordIndex, uint tokenId) public isNftAdmin returns (bool) {

        RecordRight[] memory ownerRecordRights = registryRecordRights[_owner];
        require(ownerRecordRights.length > 0, 'denied : no record right found for provided address');

        bool consumed = false;

        for (uint i = 0; i < ownerRecordRights.length; i++) {
            RecordRight memory recordRight = ownerRecordRights[i];
            if (
                consumed == false
                && recordRight.right == recordIndex
                && validRecordRight(recordRight.time, recordRight.tokenId)
            ) {
                recordRight.tokenId = tokenId;
                registryRecordRights[_owner][i] = recordRight;
                consumed = true;
            }
        }

        if (consumed) return true;
        else revert('denied : no registry record right found for provided address');
    }

}


contract Etherland is LandRegistry, Proxiable {

    using SafeMath for uint256;

    function percentOf(uint _total, uint _percent) internal pure returns(uint amount) {

        amount = ((_total * _percent) / 100);
    }

    function init(
        string memory name_, 
        string memory symbol_, 
        uint8 decimals_, 
        address _owner, 
        address _reserve, 
        address _team
    ) public {

      
        if (initialized != true) {
            initialized = true;
            
            _transferOwnership(_owner);

            uint maximumSupply = 1e9 * 10 ** decimals_;

            setImmutableCap(maximumSupply);
            
            _name = name_;
            _symbol = symbol_;
            _decimals = decimals_;
            
            team = _team;
            reserve = _reserve;
            
            mint(_reserve, percentOf(maximumSupply, 20));
            mint(_team, percentOf(maximumSupply, 10));
            mint(_owner, percentOf(maximumSupply, 70));

            _mintingFinished = true;
            
        }
    }

    function updateCode(address newCode) public onlyOwner {

        updateCodeAddress(newCode);
    }
    
    function circulatingSupply() public view returns(uint) {

        return (totalSupply().sub(balanceOf(team)).sub(balanceOf(reserve)).sub(balanceOf(owner)));
    }

    function batchTransfer(address[] memory _to, uint _value) public returns(bool) {

        uint ttlRecipients = _to.length;
        require(ttlRecipients > 0, 'at least on recipient must be defined');
        require(balanceOf(_msgSender()) >= (_value.mul(ttlRecipients)), 'batch transfer denied : unsufficient balance');
        for (uint i = 0; i < ttlRecipients; i++) {
            address recipient = _to[i];
            transfer(recipient, _value);
        }
        return true;
    }

    function setLandidNftAddress(address _landidNftAddress) public onlyOwner returns (bool) {

        landidNftAddress = _landidNftAddress;
        return true;
    }

    function setLandRegistrationAddress(address _landRegistration) public onlyOwner returns(bool) {

        landRegistration = _landRegistration;
        return true;
    }
    

}