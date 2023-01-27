

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

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;



contract ERC20 is IERC20 {

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

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
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


contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}


pragma solidity ^0.5.0;

contract Secondary {

    address private _primary;

    event PrimaryTransferred(
        address recipient
    );

    constructor () internal {
        _primary = msg.sender;
        emit PrimaryTransferred(_primary);
    }

    modifier onlyPrimary() {

        require(msg.sender == _primary, "Secondary: caller is not the primary account");
        _;
    }

    function primary() public view returns (address) {

        return _primary;
    }

    function transferPrimary(address recipient) public onlyPrimary {

        require(recipient != address(0), "Secondary: new primary is the zero address");
        _primary = recipient;
        emit PrimaryTransferred(_primary);
    }
}


pragma solidity ^0.5.0;

contract Controlled {

    modifier onlyController { require(msg.sender == controller, "Controlled: caller is not the controller"); _; }


    address payable public controller;

    constructor () public { controller = msg.sender;}

    function changeController(address payable _newController) public onlyController {

        controller = _newController;
    }
}


pragma solidity ^0.5.0;

contract TokenController {

    function proxyPayment(address _owner) public payable returns(bool);


    function onTransfer(address _from, address _to, uint _amount) public returns(bool);


    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);

}


pragma solidity ^0.5.0;





contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 _amount, address _token, bytes memory _data) public;

}

contract MiniMeToken is Controlled {


    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.2'; //An arbitrary versioning scheme


    struct  Checkpoint {

        uint128 fromBlock;

        uint128 value;
    }

    MiniMeToken public parentToken;

    uint public parentSnapShotBlock;

    uint public creationBlock;

    mapping (address => Checkpoint[]) balances;

    mapping (address => mapping (address => uint256)) allowed;

    Checkpoint[] totalSupplyHistory;

    bool public transfersEnabled;

    MiniMeTokenFactory public tokenFactory;


    constructor (
        address _tokenFactory,
        address payable _parentToken,
        uint _parentSnapShotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory  _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }



    function transfer(address _to, uint256 _amount) public returns (bool success) {

        require(transfersEnabled, "MiniMeToken: transfer is not enable");
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {


        if (msg.sender != controller) {
            require(transfersEnabled, "MiniMeToken: transfer is not enable");

            require(allowed[_from][msg.sender] >= _amount);
            allowed[_from][msg.sender] -= _amount;
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

    function doTransfer(address _from, address _to, uint _amount
    ) internal {


           if (_amount == 0) {
               emit Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0
               return;
           }

           require(parentSnapShotBlock < block.number);

           require((_to != address(0)) && (_to != address(this)));

           uint previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           uint previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           emit Transfer(_from, _to, _amount);

    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {

        require(transfersEnabled, "MiniMeToken: transfer is not enable");

        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender
    ) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function approveAndCall(address _spender, uint256 _amount, bytes memory _extraData
    ) public returns (bool success) {

        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            address(this),
            _extraData
        );

        return true;
    }

    function totalSupply() public view returns (uint) {

        return totalSupplyAt(block.number);
    }



    function balanceOfAt(address _owner, uint _blockNumber) public view
        returns (uint) {


        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != address(0)) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    function totalSupplyAt(uint _blockNumber) public view returns(uint) {


        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != address(0)) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }


    function createCloneToken(
        string memory _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string memory _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {

        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            address(this),
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        emit NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }


    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {

        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        emit Transfer(address(0), _owner, _amount);
        return true;
    }


    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {

        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        emit Transfer(_owner, address(0), _amount);
        return true;
    }



    function enableTransfers(bool _transfersEnabled) public onlyController {

        transfersEnabled = _transfersEnabled;
    }


    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) view internal returns (uint) {

        if (checkpoints.length == 0) return 0;

        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {

        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    function isContract(address _addr) view internal returns(bool) {

        uint size;
        if (_addr == address(0)) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    function min(uint a, uint b) pure internal returns (uint) {

        return a < b ? a : b;
    }

    function () external payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }


    function claimTokens(address payable _token) public onlyController {

        if (_token == address(0)) {
            controller.transfer(address(this).balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(controller, balance);
        emit ClaimedTokens(_token, controller, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);	
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(	
        address indexed _owner,	
        address indexed _spender,	
        uint256 _amount	
        );
}



contract MiniMeTokenFactory {


    function createCloneToken(
        address payable _parentToken,
        uint _snapshotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {

        MiniMeToken newToken = new MiniMeToken(
            address(this),
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}


pragma solidity ^0.5.0;



contract VestingTokenStep is MiniMeToken {

    using SafeMath for uint256;

    bool public initiated;

    uint256 public cliff;
    uint256 public start;
    uint256 public duration;
    uint256 public constant UNIT_IN_SECONDS = 60 * 60 * 24 * 30;

    mapping (address => uint256) public released;

    constructor (
        address tokenFactory,
        address payable parentToken,
        uint parentSnapShotBlock,
        string memory tokenName,
        uint8 decimalUnits,
        string memory tokenSymbol,
        bool transfersEnabled
    )
        public
        MiniMeToken(tokenFactory, parentToken, parentSnapShotBlock, tokenName, decimalUnits, tokenSymbol, transfersEnabled)
    {
    }

    modifier beforeInitiated() {

        require(!initiated, "VestingTokenStep: cannot execute after initiation");
        _;
    }

    modifier afterInitiated() {

        require(initiated, "VestingTokenStep: cannot execute before initiation");
        _;
    }

    function initiate(uint256 _start, uint256 cliffDuration, uint256 _duration) public beforeInitiated onlyController {

        initiated = true;

        enableTransfers(false);

        require(cliffDuration <= _duration, "VestingTokenStep: cliff is longer than duration");
        require(_duration != 0, "VestingTokenStep: duration is 0");
        require(_start.add(_duration.mul(UNIT_IN_SECONDS)) > block.timestamp, "VestingTokenStep: final time is before current time");

        duration = _duration;
        start = _start;
        cliff = start.add(cliffDuration.mul(UNIT_IN_SECONDS));
    }

    function doTransfer(address from, address to, uint amount) internal beforeInitiated {

        super.doTransfer(from, to, amount);
    }

    function destroyReleasableTokens(address beneficiary) public afterInitiated onlyController returns (uint256 unreleased) {

        unreleased = releasableAmount(beneficiary);

        require(unreleased != 0, "VestingTokenStep: no tokens are due");

        released[beneficiary] = released[beneficiary].add(unreleased);

        require(destroyTokens(beneficiary, unreleased), "VestingTokenStep: failed to destroy tokens");
    }

    function releasableAmount(address beneficiary) public view returns (uint256) {

        return _vestedAmount(beneficiary).sub(released[beneficiary]);
    }

    function _vestedAmount(address beneficiary) private view returns (uint256) {

        if (!initiated) {
            return 0;
        }

        uint256 currentVestedAmount = balanceOf(beneficiary);
        uint256 totalVestedAmount = currentVestedAmount.add(released[beneficiary]);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= cliff.add(duration.mul(UNIT_IN_SECONDS))) {
            return totalVestedAmount;
        } else {
            uint256 currenUnit = block.timestamp.sub(cliff).div(UNIT_IN_SECONDS).add(1);
            return totalVestedAmount.mul(currenUnit).div(duration);
        }
    }
}


pragma solidity ^0.5.0;




contract TONVault is Secondary {

    using SafeMath for uint256;

    ERC20Mintable public ton;

    constructor (ERC20Mintable tonToken) public {
        ton = tonToken;
    }

    function setApprovalAmount(address approval, uint256 amount) public onlyPrimary {

        ton.approve(approval, amount);
    }
    
    function withdraw(uint256 amount, address recipient) public onlyPrimary {

        ton.transfer(recipient, amount);
    }
}


pragma solidity ^0.5.0;

contract Burner {

    constructor () public {
    }
}


pragma solidity ^0.5.0;








contract Swapper is Secondary {

    using SafeMath for uint256;

    mapping(address => uint256) public ratio;

    ERC20Mintable public _token;
    IERC20 public mton;
    TONVault public vault;
    address public constant burner = 0x0000000000000000000000000000000000000001;
    uint256 public startTimestamp;

    event Swapped(address account, uint256 unreleased, uint256 transferred);
    event Withdrew(address recipient, uint256 amount);
    event UpdateRatio(address vestingToken, uint256 tokenRatio);
    event SetVault(address vaultAddress);

    modifier onlyBeforeStart() {

        require(block.timestamp < startTimestamp || startTimestamp == 0, "Swapper: cannot execute after start");
        _;
    }

    constructor (ERC20Mintable token, address mtonAddress) public {
        _token = token;
        mton = IERC20(mtonAddress);
    }

    function updateRatio(address vestingToken, uint256 tokenRatio) external onlyPrimary onlyBeforeStart {

        ratio[vestingToken] = tokenRatio;
        emit UpdateRatio(vestingToken, tokenRatio);
    }

    function setStart(uint256 _startTimestamp) external onlyPrimary {

        require(startTimestamp == 0, "Swapper: the starttime is already set");
        startTimestamp = _startTimestamp;
    }

    function swap(address payable vestingToken) external returns (bool) {

        uint256 tokenRatio = ratio[vestingToken];
        require(tokenRatio != 0, "VestingSwapper: not valid sale token address");

        uint256 unreleased = releasableAmount(vestingToken, msg.sender);
        if (unreleased == 0) {
            return true;
        }

        if (vestingToken == address(mton)) {
            mton.transferFrom(msg.sender, address(this), unreleased);
            mton.transfer(burner, unreleased);
        } else {
            unreleased = VestingTokenStep(vestingToken).destroyReleasableTokens(msg.sender);
        }
        uint256 ton_amount = unreleased.mul(tokenRatio);
        _token.transferFrom(address(vault), address(this), ton_amount);
        _token.transfer(msg.sender, ton_amount);
        
        emit Swapped(msg.sender, unreleased, ton_amount);
        return true;
    }


    function proxyPayment(address _owner) public payable returns(bool) {

        return true;
    }

    function onTransfer(address _from, address _to, uint _amount) public returns(bool) {

        return true;
    }

    function onApprove(address _owner, address _spender, uint _amount) public returns(bool) {

        return true;
    }

    function releasableAmount(address payable vestingToken, address beneficiary) public view returns (uint256) {

        if (vestingToken == address(mton)) {
            return mton.balanceOf(beneficiary);
        } else {
            return VestingTokenStep(vestingToken).releasableAmount(beneficiary);
        }
    }

    function changeController(VestingTokenStep vestingToken, address payable newController) external onlyPrimary {

        vestingToken.changeController(newController);
    }

    function setVault(TONVault vaultAddress) external onlyPrimary {

        vault = vaultAddress;
        emit SetVault(address(vaultAddress));
    }
}