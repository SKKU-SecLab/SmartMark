pragma solidity >=0.8.8;



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

        return _functionCallWithValue(target, data, 0, errorMessage);
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

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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
}// UNLICENSED
pragma solidity >=0.8.9;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}// UNLICENSED
pragma solidity >=0.8.9;






interface ISutd is IERC20 {


  function rebase(uint256 utdProfit_, uint256 epoch_)
    external
    returns (uint256);


  function circulatingSupply() external view returns (uint256);


  function gonsForBalance(uint256 amount) external view returns (uint256);


  function balanceForGons(uint256 gons) external view returns (uint256);


  function index() external view returns (uint256);


  function toG(uint256 amount) external view returns (uint256);


  function fromG(uint256 amount) external view returns (uint256);


  function changeDebt(
    uint256 amount,
    address debtor,
    bool add
  ) external;


  function debtBalances(address _address) external view returns (uint256);


}// UNLICENSED
pragma solidity >=0.8.9;






interface IAutd is IERC20 {


  function mint(address _to, uint256 _amount) external;


  function burn(address _from, uint256 _amount) external;


  function index() external view returns (uint256);


  function balanceFrom(uint256 _amount) external view returns (uint256);


  function balanceTo(uint256 _amount) external view returns (uint256);


}// UNLICENSED
pragma solidity ^0.8.9;


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
        assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {

        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

}// AGPL-3.0-or-later
pragma solidity >=0.8.9;




abstract contract ERC20 is IERC20 {

    using SafeMath for uint256;

    bytes32 constant private ERC20TOKEN_ERC1820_INTERFACE_ID = keccak256( "ERC20Token" );
    
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;
    
    string internal _symbol;
    
    uint8 internal immutable _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);

    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer( address from_, address to_, uint256 amount_ ) internal virtual { }
    function _afterTokenTransfer( address from_, address to_, uint256 amount_ ) internal virtual { }
}// AGPL-3.0
pragma solidity >=0.8.9;

interface IUnitedAuthority {


    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);


    function governor() external view returns (address);


    function guardian() external view returns (address);


    function policy() external view returns (address);


    function vault() external view returns (address);

}// AGPL-3.0-only
pragma solidity >=0.8.9;


abstract contract UnitedAccessControl {

    event AuthorityUpdated(IUnitedAuthority indexed authority);

    string private constant UNAUTHORIZED = "UNAUTHORIZED";


    IUnitedAuthority public authority;


    constructor(IUnitedAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }


    modifier onlyGovernor() {
        require(msg.sender == authority.governor(), UNAUTHORIZED);
        _;
    }

    modifier onlyGuardian() {
        require(msg.sender == authority.guardian(), UNAUTHORIZED);
        _;
    }

    modifier onlyPolicy() {
        require(msg.sender == authority.policy(), UNAUTHORIZED);
        _;
    }

    modifier onlyVault() {
        require(msg.sender == authority.vault(), UNAUTHORIZED);
        _;
    }


    function setAuthority(IUnitedAuthority _newAuthority) external onlyGovernor {
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }
}// UNLICENSED
pragma solidity ^0.8.9;






contract Autd is IAutd, ERC20, UnitedAccessControl {



    using Address for address;
    using SafeMath for uint256;


    modifier onlyStaking() {

        require(msg.sender == staking, "Only staking");
        _;
    }


    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);


    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }


    ISutd public immutable sUTD;
    address public immutable initializer; // minter
    address public staking; // minter

    mapping(address => mapping(uint256 => Checkpoint)) public checkpoints;
    mapping(address => uint256) public numCheckpoints;
    mapping(address => address) public delegates;


    constructor(address _initializer, address _sUTD, address authority, uint256 _pledgeLockupDuration)
        ERC20("Allies UTD", "aUTD", 18)
        UnitedAccessControl(IUnitedAuthority(authority))
    {
        require(_initializer != address(0), "Zero address: Initializer");
        initializer = _initializer;
        require(_sUTD != address(0), "Zero address: sUTD");
        sUTD = ISutd(_sUTD);

        pledgeLockupDuration = _pledgeLockupDuration;
        emit SetPledgeLockupDuration(_pledgeLockupDuration);
    }

    function setStaking(address _staking) external {

        require(msg.sender == initializer, "not initializer");
        require(_staking != address(0), "Zero address: Staking");
        staking = _staking;
    }


    function delegate(address delegatee) external {

        return _delegate(msg.sender, delegatee);
    }

    function mint(address _to, uint256 _amount) external override onlyStaking {

        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external override onlyStaking {

        _burn(_from, _amount);
    }


    function index() public view override returns (uint256) {

        return sUTD.index();
    }

    function balanceFrom(uint256 _amount) public view override returns (uint256) {

        return _amount.mul(index()).div(10**decimals());
    }

    function balanceTo(uint256 _amount) public view override returns (uint256) {

        return _amount.mul(10**decimals()).div(index());
    }

    function getCurrentVotes(address account) external view returns (uint256) {

        uint256 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {

        require(blockNumber < block.number, "aUTD::getPriorVotes: not yet determined");

        uint256 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint256 lower = 0;
        uint256 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint256 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }


    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = _balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint256 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint256 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint256 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == block.number) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(block.number, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(IERC20, ERC20) returns (bool) {

        if (msg.sender == staking) {
            _transfer(sender, recipient, amount);
            return true;
        } else {
            _transfer(sender, recipient, amount);
            _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        _moveDelegates(delegates[from], delegates[to], amount);
    }

    function _afterTokenTransfer(
        address from,
        address,
        uint256
    ) internal view override {

        if (from != address(0)) {
            require (pledgeAccountData[from].amount <= _balances[from], "balance less than pledged");
        }
    }


    struct AutdPledgeAccountData {
        uint96 amount;
        uint48 lockupExpiry;
    }
    uint256 public pledgeLockupDuration;
    mapping(address => AutdPledgeAccountData) public pledgeAccountData;

    event SetPledgeLockupDuration(uint256 newPledgeLockupDuration);
    event Pledge(address account, uint256 amount);
    event Claim(address account, uint256 amount);

    function setPledgeLockupDuration(uint256 newPledgeLockupDuration) external onlyPolicy {

        pledgeLockupDuration = newPledgeLockupDuration;
        emit SetPledgeLockupDuration(newPledgeLockupDuration);
    }

    function pledge(uint256 amount) external {

        emit Pledge(msg.sender, amount);
        pledgeAccountData[msg.sender].amount += uint96(amount);
        require(pledgeAccountData[msg.sender].amount <= balanceOf(msg.sender), "autd balance too low");
        pledgeAccountData[msg.sender].lockupExpiry = uint48(block.timestamp + pledgeLockupDuration);
    }

    function claim(uint256 amount) external {

        require(block.timestamp >= pledgeAccountData[msg.sender].lockupExpiry, "autd is locked up");
        emit Claim(msg.sender, amount);
        pledgeAccountData[msg.sender].amount -= uint96(amount);
    }
}