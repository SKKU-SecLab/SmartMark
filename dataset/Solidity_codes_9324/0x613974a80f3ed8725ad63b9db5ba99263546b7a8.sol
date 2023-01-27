
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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


pragma solidity 0.6.12;
interface IGoaldDAO {
    function getGoaldCount() external view returns (uint256);

    function getProxyAddress() external view returns (address);

    function initializeDecreasesHolders() external;

    function issuanceIncreasesHolders() external;
    
    function makeReady(uint256 governanceStage, uint256 idOffset) external;

    function preTransfer(address sender, address recipient) external;

    function postTransfer(address sender, uint256 senderBefore, uint256 senderAfter, uint256 recipientBefore, uint256 recipientAfter) external;

    function updateGovernanceStage() external;
}

contract GoaldToken is ERC20 {
    address public _manager = msg.sender;

    address[] private _daoAddresses;
    mapping(address => uint256) private _isValidDAO;
    uint256 private constant UNTRACKED_DAO = 0;
    uint256 private constant VALID_DAO     = 1;
    uint256 private constant INVALID_DAO   = 2;

    uint8   private constant DECIMALS = 2;

    uint256 private constant REWARD_THRESHOLD = 10**uint256(DECIMALS);

    uint256 private constant MAX_SUPPLY = 210000 * REWARD_THRESHOLD;

    string  private _baseTokenURI;

    uint256 private _goaldCount;

    uint256 private constant STAGE_INITIAL               = 0;
    uint256 private constant STAGE_ISSUANCE_CLAIMED      = 1;
    uint256 private constant STAGE_DAO_INITIATED         = 2;
    uint256 private constant STAGE_ALL_GOVERNANCE_ISSUED = 3;
    uint256 private _governanceStage;

    uint256 private constant RE_NOT_ENTERED = 1;
    uint256 private constant RE_ENTERED     = 2;
    uint256 private constant RE_FROZEN      = 3;
    uint256 private _status;

    uint256 private _daoStatus;

    constructor() ERC20("Goald", "GOALD") public {
        _setupDecimals(DECIMALS);
        _status    = RE_FROZEN;
        _daoStatus = RE_NOT_ENTERED;
    }

    
    event DAOStatusChanged(address daoAddress, uint256 status);

    event DAOUpgraded(address daoAddress);

    event GoaldDeployed(address goaldAddress);

    event ManagerChanged(address newManager);


    function freeze() external {
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _manager, "Not manager");

        _status = RE_FROZEN;
    }

    function setDAOStatus(address daoAddress, uint256 index, uint256 status) external {
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _manager, "Not manager");

        require(_daoAddresses[index] == daoAddress, "Non-matching DAO index");

        require(status == VALID_DAO || status == INVALID_DAO, "Invalid status");
        uint256 currentStatus = _isValidDAO[daoAddress];
        require(currentStatus != status && (currentStatus == VALID_DAO || currentStatus == INVALID_DAO), "Invalid current status");

        _isValidDAO[daoAddress] = status;

        emit DAOStatusChanged(daoAddress, status);
    }

    function setManager(address newManager) external {
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _manager,      "Not manager");
        require(newManager != address(0),    "Can't be zero address");
        require(newManager != address(this), "Can't be this address");

        require((_governanceStage != STAGE_ISSUANCE_CLAIMED) || (balanceOf(newManager) > 110000 * REWARD_THRESHOLD), "New manager can't init DAO");

        _manager = newManager;

        emit ManagerChanged(newManager);
    }

    function unfreeze() external {
        require(_status == RE_FROZEN);
        require(msg.sender == _manager, "Not manager");

        _status = RE_NOT_ENTERED;
    }

    function upgradeDAO(address daoAddress) external {
        require(_status == RE_FROZEN);
        _status = RE_ENTERED;

        uint256 codeSize;
        assembly { codeSize := extcodesize(daoAddress) }
        require(codeSize > 0, "Not a contract");

        require(_isValidDAO[daoAddress] == UNTRACKED_DAO, "DAO already tracked");

        _daoAddresses.push(daoAddress);
        _isValidDAO[daoAddress] = VALID_DAO;

        IGoaldDAO(daoAddress).makeReady(_governanceStage, _goaldCount);

        emit DAOUpgraded(daoAddress);

        _status = RE_FROZEN;
    }


    function getBaseTokenURI() external view returns (string memory) {
        return _baseTokenURI;
    }

    function getGoaldCount() external view returns (uint256) {
        return _goaldCount;
    }

    function getGoaldDAO(uint256 id) external view returns (address) {
        require(id < _goaldCount, "ID too large");

        uint256 addressesCount = _daoAddresses.length;
        uint256 index;
        uint256 goaldCount;
        address goaldAddress;

        for (; index < addressesCount; index ++) {
            goaldAddress = _daoAddresses[index];
            goaldCount += IGoaldDAO(goaldAddress).getGoaldCount();
            if (id <= goaldCount) {
                return goaldAddress;
            }
        }

        revert("Unknown DAO");
    }

    function goaldDeployed(address recipient, address goaldAddress) external returns (uint256) {
        require(_daoStatus == RE_NOT_ENTERED);

        require(msg.sender == _daoAddresses[_daoAddresses.length - 1], "Caller not latest DAO");
        require(_isValidDAO[msg.sender] == VALID_DAO, "Caller not valid DAO");

        emit GoaldDeployed(goaldAddress);

        uint256 goaldCount = _goaldCount++;
        if (_governanceStage == STAGE_ALL_GOVERNANCE_ISSUED) {
            return 0;
        }

        uint256 amount;
        if        (goaldCount <   10) {
            amount = 1000;
        } else if (goaldCount <   20) {
            amount =  900;
        } else if (goaldCount <   30) {
            amount =  800;
        } else if (goaldCount <   40) {
            amount =  700;
        } else if (goaldCount <   50) {
            amount =  600;
        } else if (goaldCount <   60) {
            amount =  500;
        } else if (goaldCount <   70) {
            amount =  400;
        } else if (goaldCount <   80) {
            amount =  300;
        } else if (goaldCount <   90) {
            amount =  200;
        } else if (goaldCount <  100) {
            amount =  100;
        } else if (goaldCount < 3600) {
            amount =   10;
        }
        
        else if (_governanceStage == STAGE_DAO_INITIATED) {
            _governanceStage = STAGE_ALL_GOVERNANCE_ISSUED;
        }

        if (amount == 0) {
            return 0;
        }

        require(_isValidDAO[recipient] == UNTRACKED_DAO, "Can't be DAO");
        require(recipient != address(0), "Can't be zero address");
        require(recipient != address(this), "Can't be Goald token");

        uint256 totalSupply = totalSupply();
        require(amount + totalSupply > totalSupply, "Overflow error");
        require(amount + totalSupply < MAX_SUPPLY, "Exceeds supply");
        
        _mint(recipient, amount * REWARD_THRESHOLD);

        return amount;
    }

    function setBaseTokenURI(string calldata baseTokenURI) external {
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _manager, "Not manager");

        _baseTokenURI = baseTokenURI;
    }


    function claimIssuance() external {
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _manager,            "Not manager");
        require(_governanceStage == STAGE_INITIAL, "Already claimed");

        if (balanceOf(_manager) < REWARD_THRESHOLD) {
            uint256 index;
            uint256 count = _daoAddresses.length;
            for (; index < count; index ++) {
                IGoaldDAO(_daoAddresses[index]).issuanceIncreasesHolders();
            }
        }

        _mint(_manager, 120000 * REWARD_THRESHOLD);

        _governanceStage = STAGE_ISSUANCE_CLAIMED;
    }

    function getDAOAddressAt(uint256 index) external view returns (address) {
        return _daoAddresses[index];
    }

    function getDAOCount() external view returns (uint256) {
        return _daoAddresses.length;
    }

    function getDAOStatus(address daoAddress) external view returns (uint256) {
        return _isValidDAO[daoAddress];
    }

    function getLatestDAO() external view returns (address) {
        address daoAddress = _daoAddresses[_daoAddresses.length - 1];
        require(_isValidDAO[daoAddress] == VALID_DAO, "Latest DAO invalid");

        return daoAddress;
    }

    function getGovernanceStage() external view returns (uint256) {
        return _governanceStage;
    }

    function initializeDAO() external {
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        require(msg.sender == _manager,                     "Not manager");
        require(_governanceStage == STAGE_ISSUANCE_CLAIMED, "Issuance unclaimed");

        uint256 startingBalance = balanceOf(_manager);
        require(startingBalance >= 110000 * REWARD_THRESHOLD, "Not enough tokens");
        _burn(_manager, 110000 * REWARD_THRESHOLD);

        _governanceStage = STAGE_DAO_INITIATED;

        uint256 count = _daoAddresses.length;

        if (count > 0 && startingBalance - (110000 * REWARD_THRESHOLD) < REWARD_THRESHOLD) {
            IGoaldDAO(_daoAddresses[count - 1]).initializeDecreasesHolders();
        }

        uint256 index;
        for (; index < count; index++) {
            IGoaldDAO(_daoAddresses[index]).updateGovernanceStage();
        }

        _status = RE_NOT_ENTERED;
    }

    function safeCallDAO(address daoAddress, bytes calldata encodedData) external returns (bytes memory) {
        require(_status    == RE_NOT_ENTERED);
        require(_daoStatus == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        _daoStatus = RE_ENTERED;

        require(msg.sender == _manager, "Not manager");
        require(_isValidDAO[daoAddress] == VALID_DAO, "Not a valid DAO");

        (bool success, bytes memory returnData) = daoAddress.call(encodedData);

        _status = RE_NOT_ENTERED;
        _daoStatus = RE_NOT_ENTERED;

        if (success) {
            return returnData;
        } else {
            if (returnData.length > 0) {

                assembly {
                    let returnData_size := mload(returnData)
                    revert(add(32, returnData), returnData_size)
                }
            } else {
                revert();
            }
        }
    }

    function unsafeCallDAO(address daoAddress, bytes calldata encodedData) external returns (bytes memory) {
        require(_daoStatus == RE_NOT_ENTERED);
        _daoStatus = RE_ENTERED;

        require(msg.sender == _manager, "Not manager");
        require(_isValidDAO[daoAddress] != UNTRACKED_DAO, "DAO not tracked");

        (bool success, bytes memory returnData) = daoAddress.call(encodedData);

        _daoStatus = RE_NOT_ENTERED;
        
        if (success) {
            return returnData;
        } else {
            if (returnData.length > 0) {

                assembly {
                    let returnData_size := mload(returnData)
                    revert(add(32, returnData), returnData_size)
                }
            } else {
                revert();
            }
        }
    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        uint256 senderBefore = balanceOf(msg.sender);
        uint256 recipientBefore = balanceOf(recipient);

        uint256 count = _daoAddresses.length;
        uint256 index;
        for (; index < count; index ++) {
            IGoaldDAO(_daoAddresses[index]).preTransfer(msg.sender, recipient);
        }
        
        super.transfer(recipient, amount);
        
        index = 0;
        for (; index < count; index ++) {
            IGoaldDAO(_daoAddresses[index]).postTransfer(msg.sender, senderBefore, balanceOf(msg.sender), recipientBefore, balanceOf(recipient));
        }

        _status = RE_NOT_ENTERED;

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        uint256 senderBefore = balanceOf(sender);
        uint256 recipientBefore = balanceOf(recipient);

        uint256 count = _daoAddresses.length;
        uint256 index;
        for (; index < count; index ++) {
            IGoaldDAO(_daoAddresses[index]).preTransfer(sender, recipient);
        }
        
        super.transferFrom(sender, recipient, amount);
        
        index = 0;
        for (; index < count; index ++) {
            IGoaldDAO(_daoAddresses[index]).postTransfer(sender, senderBefore, balanceOf(sender), recipientBefore, balanceOf(recipient));
        }

        _status = RE_NOT_ENTERED;

        return true;
    }
}