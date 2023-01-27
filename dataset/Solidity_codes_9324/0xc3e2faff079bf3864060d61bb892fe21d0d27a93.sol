pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;


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
}pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity ^0.5.0;

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}pragma solidity 0.5.16;

interface StationConfig {

    function minDebtSize() external view returns (uint256);


    function getInterestRate(uint256 debt, uint256 floating) external view returns (uint256);


    function getStarGateBps() external view returns (uint256);


    function getTerminateBps() external view returns (uint256);


    function isOrbit(address orbit) external view returns (bool);


    function acceptDebt(address orbit) external view returns (bool);


    function launcher(address orbit, uint256 debt) external view returns (uint256);


    function terminator(address orbit, uint256 debt) external view returns (uint256);

}pragma solidity 0.5.16;

interface Orbit {

    function launch(uint256 id, address user, uint256 debt, bytes calldata data) external payable;


    function refuel() external;


    function condition(uint256 id) external view returns (uint256);


    function destroy(uint256 id, address user) external;

}pragma solidity 0.5.16;

interface ERC20Interface {

    function balanceOf(address user) external view returns (uint256);

}

library SafeToken {

    function myBalance(address token) internal view returns (uint256) {

        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {

        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "!safeTransferETH");
    }
}pragma solidity 0.5.16;

interface IUniverse {

    function depositETH() external payable;

    function getHQBase() external view returns (address);

    function getUniverseShare() external view returns (uint256);

    function getPlanetETHShare() external view returns (uint256);

    function getHQBaseShare() external view returns (uint256);

    function getRefferral() external view returns (address payable);

}pragma solidity 0.5.16;


contract Station is ERC20, ReentrancyGuard, Ownable {

    using SafeToken for address;
    using SafeMath for uint256;

    event AddDebt(uint256 indexed id, uint256 debtShare);
    event RemoveDebt(uint256 indexed id, uint256 debtShare);
    event Launch(uint256 indexed id, uint256 loan);
    event Terminate(uint256 indexed id, address indexed killer, uint256 prize, uint256 left);

    string public name = "Interest ETH";
    string public symbol = "jETH";
    uint8 public decimals = 18;

    IUniverse public universe;

    struct Position {
        address orbit;
        address owner;
        uint256 debtShare;
        uint256 leverageVal;
    }

    StationConfig public config;
    mapping (uint256 => Position) public positions;
    uint256 public nextPositionID = 1;

    uint256 public glbDebtShare;
    uint256 public glbDebtVal;
    uint256 public lastAccrueTime;
    uint256 public starGate;

    modifier onlyEOA() {

        require(msg.sender == tx.origin, "not eoa");
        _;
    }

    constructor(
        StationConfig _config, 
        IUniverse _universe
    ) public {
        config = _config;
        universe = _universe;
        lastAccrueTime = now;
    }

    modifier accrue(uint256 msgValue) {

        if (now > lastAccrueTime) {
            uint256 interest = pendingInterest(msgValue);
            uint256 toReserve = interest.mul(config.getStarGateBps()).div(10000);
            starGate = starGate.add(toReserve);
            glbDebtVal = glbDebtVal.add(interest);
            if(starGate > 0 && (universe.getHQBaseShare() > 0 || universe.getPlanetETHShare() > 0)){
                sendToOperator(starGate);
            }
            lastAccrueTime = now;
        }
        _;
    }

    function sendToOperator(uint256 _starGate) internal {

        uint256 hqBaseAmount = _starGate.mul(universe.getHQBaseShare()).div(10000);
        uint256 poolETHAmount = _starGate.mul(universe.getPlanetETHShare()).div(10000);

        SafeToken.safeTransferETH(universe.getHQBase(), hqBaseAmount);
        universe.depositETH.value(poolETHAmount)();
        starGate = starGate.sub(hqBaseAmount).sub(poolETHAmount);
    }

    function pendingInterest(uint256 msgValue) public view returns (uint256) {

        if (now > lastAccrueTime) {
            uint256 timePast = now.sub(lastAccrueTime);
            uint256 balance = address(this).balance.sub(msgValue);
            uint256 ratePerSec = config.getInterestRate(glbDebtVal, balance);
            return ratePerSec.mul(glbDebtVal).mul(timePast).div(1e18);
        } else {
            return 0;
        }
    }

    function debtShareToVal(uint256 debtShare) public view returns (uint256) {

        if (glbDebtShare == 0) return debtShare; // When there's no share, 1 share = 1 val.
        return debtShare.mul(glbDebtVal).div(glbDebtShare);
    }

    function debtValToShare(uint256 debtVal) public view returns (uint256) {

        if (glbDebtShare == 0) return debtVal; // When there's no share, 1 share = 1 val.
        return debtVal.mul(glbDebtShare).div(glbDebtVal);
    }

    function positionInfo(uint256 id) public view returns (uint256, uint256) {

        Position storage pos = positions[id];
        return (Orbit(pos.orbit).condition(id), debtShareToVal(pos.debtShare));
    }

    function totalETH() public view returns (uint256) {

        return address(this).balance.add(glbDebtVal).sub(starGate);
    }

    function deposit() external payable accrue(msg.value) nonReentrant {

        uint256 total = totalETH().sub(msg.value);
        uint256 share = total == 0 ? msg.value : msg.value.mul(totalSupply()).div(total);
        _mint(msg.sender, share);
    }

    function withdraw(uint256 share) external accrue(0) nonReentrant {

        uint256 amount = share.mul(totalETH()).div(totalSupply());
        _burn(msg.sender, share);
        uint256 profit = amount.sub(share);
        uint256 referralAmount = profit.mul(universe.getUniverseShare()).div(10000);
        address payable refferal = universe.getRefferral();
        (bool sent, bytes memory data) = refferal.call.value(referralAmount)("");
        require(sent, "Failed to transfer");
        SafeToken.safeTransferETH(msg.sender, amount.sub(referralAmount));
    }

    function launch(uint256 id, address orbit, uint256 loan, uint256 maxReturn, uint256 leverageVal, bytes calldata data)
        external payable
        onlyEOA accrue(msg.value) nonReentrant
    {

        if (id == 0) {
            id = nextPositionID++;
            positions[id].orbit = orbit;
            positions[id].owner = msg.sender;
            positions[id].leverageVal = leverageVal;
        } else {
            require(id < nextPositionID, "bad position id");
            require(positions[id].orbit == orbit, "bad position orbit");
            require(positions[id].owner == msg.sender, "not position owner");
        }
        emit Launch(id, loan);
        require(config.isOrbit(orbit), "not a orbit");
        require(loan == 0 || config.acceptDebt(orbit), "orbit not accept more debt");
        uint256 debt = _removeDebt(id).add(loan);
        uint256 back;
        {
            uint256 sendETH = msg.value.add(loan);
            require(sendETH <= address(this).balance, "insufficient ETH in the bank");
            uint256 beforeETH = address(this).balance.sub(sendETH);
            Orbit(orbit).launch.value(sendETH)(id, msg.sender, debt, data);
            back = address(this).balance.sub(beforeETH);
        }
        uint256 lessDebt = Math.min(debt, Math.min(back, maxReturn));
        debt = debt.sub(lessDebt);
        if (debt > 0) {
            require(debt >= config.minDebtSize(), "too small debt size");
            uint256 condition = Orbit(orbit).condition(id);
            uint256 launcher = config.launcher(orbit, debt);
            require(condition.mul(launcher) >= debt.mul(10000), "bad work factor");
            _addDebt(id, debt);
        }
        if (back > lessDebt) SafeToken.safeTransferETH(msg.sender, back - lessDebt);
    }

    function terminate(uint256 id) external onlyEOA accrue(0) nonReentrant {

        Position storage pos = positions[id];
        require(pos.debtShare > 0, "no debt");
        uint256 debt = _removeDebt(id);
        uint256 condition = Orbit(pos.orbit).condition(id);
        uint256 terminator = config.terminator(pos.orbit, debt);
        require(condition.mul(terminator) < debt.mul(10000), "can't liquidate");
        uint256 beforeETH = address(this).balance;
        Orbit(pos.orbit).destroy(id, msg.sender);
        uint256 back = address(this).balance.sub(beforeETH);
        uint256 prize = back.mul(config.getTerminateBps()).div(10000);
        uint256 rest = back.sub(prize);
        if (prize > 0) SafeToken.safeTransferETH(msg.sender, prize);
        uint256 left = rest > debt ? rest - debt : 0;
        if (left > 0) SafeToken.safeTransferETH(pos.owner, left);
        emit Terminate(id, msg.sender, prize, left);
    }

    function _addDebt(uint256 id, uint256 debtVal) internal {

        Position storage pos = positions[id];
        uint256 debtShare = debtValToShare(debtVal);
        pos.debtShare = pos.debtShare.add(debtShare);
        glbDebtShare = glbDebtShare.add(debtShare);
        glbDebtVal = glbDebtVal.add(debtVal);
        emit AddDebt(id, debtShare);
    }

    function _removeDebt(uint256 id) internal returns (uint256) {

        Position storage pos = positions[id];
        uint256 debtShare = pos.debtShare;
        if (debtShare > 0) {
            uint256 debtVal = debtShareToVal(debtShare);
            pos.debtShare = 0;
            glbDebtShare = glbDebtShare.sub(debtShare);
            glbDebtVal = glbDebtVal.sub(debtVal);
            emit RemoveDebt(id, debtShare);
            return debtVal;
        } else {
            return 0;
        }
    }

    function updateConfig(StationConfig _config) external onlyOwner {

        config = _config;
    }

    function withdrawReserve(address to, uint256 value) external onlyOwner nonReentrant {

        starGate = starGate.sub(value);
        SafeToken.safeTransferETH(to, value);
    }

    function reduceReserve(uint256 value) external onlyOwner {

        starGate = starGate.sub(value);
    }

    function recover(address token, address to, uint256 value) external onlyOwner nonReentrant {

        token.safeTransfer(to, value);
    }

    function() external payable {}
}