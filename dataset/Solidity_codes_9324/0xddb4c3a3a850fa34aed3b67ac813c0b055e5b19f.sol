
pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

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
contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

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

    function _burnFrom(address account, uint256 amount) internal virtual {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}
interface IEscrow {
    function balance() external returns (uint);
    function send(address payable addr, uint amt) external returns (bool);
}
abstract contract Escrow is IEscrow {

    address public escrowLibrary;

    modifier onlyLibrary() {
        require(msg.sender == escrowLibrary, "Only callable by library contract");
        _;
    }

    constructor(address _escrowLibrary) internal {
        escrowLibrary = _escrowLibrary;
    }
}


contract ETHEscrow is Escrow {

    constructor(address escrowLibrary) public Escrow(escrowLibrary) {}

    function send(address payable addr, uint amt) public override onlyLibrary returns (bool) {
        return addr.send(amt);
    }

    function balance() public override returns (uint) {
        return (address(this)).balance;
    }
}


contract ERC20Escrow is Escrow {

    ERC20 public token;

    constructor(address escrowLibrary, address tknAddr) public Escrow(escrowLibrary) {
        token = ERC20(tknAddr);
    }

    function send(address payable addr, uint amt) public override onlyLibrary returns (bool) {
        return token.transfer(addr, amt);
    }

    function balance() public override returns (uint) {
        return token.balanceOf(address(this));
    }
}
library Create2 {
    function deploy(bytes32 salt, bytes memory bytecode) internal returns (address) {
        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes memory bytecode) internal view returns (address) {
        return computeAddress(salt, bytecode, address(this));
    }

    function computeAddress(bytes32 salt, bytes memory bytecode, address deployer) internal pure returns (address) {
        return computeAddress(salt, keccak256(bytecode), deployer);
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(bytes20(_data << 96));
    }
}
contract EscrowLibrary {

    enum SettlementType {
        Claim,
        Refund
    }

    struct EscrowParams {
        bytes32 puzzleA;
        bytes32 puzzleB;
        address tokenAddress;
        uint escrowAmount;
        uint timeLockA;
        uint timeLockB;
        address payable claimAddress;
        address payable refundAddress;
    }

    struct PuzzleData {
        uint timeSolved;
    }

    event SolutionPosted(bytes32 indexed puzzle, bytes solution);
    event EscrowSettled(address indexed escrowAddress, SettlementType settlementType);

    mapping(bytes32 => PuzzleData) public puzzles;

    function postSolution(bytes32 puzzle, bytes calldata solution) external {
        PuzzleData storage puzzleData = puzzles[puzzle];
        require(puzzleData.timeSolved == 0, "Solution already posted");
        require(puzzle == sha256(solution), "Invalid solution");

        puzzleData.timeSolved = now;
        emit SolutionPosted(puzzle, solution);
    }

    function claimEscrow(
        bytes32 puzzleA,
        bytes32 puzzleB,
        address tokenAddress,
        uint escrowAmount,
        uint timeLockA,
        uint timeLockB,
        address payable claimAddress,
        address payable refundAddress
    )
        external
    {
        (bytes32 escrowParamsHash, bytes memory bytecode) = computeCreate2Params(
            EscrowParams(puzzleA, puzzleB, tokenAddress, escrowAmount, timeLockA, timeLockB, claimAddress, refundAddress)
        );

        address escrowAddress = Create2.deploy(escrowParamsHash, bytecode);
        IEscrow escrow = IEscrow(escrowAddress);

        uint balance = escrow.balance();
        require(balance >= escrowAmount, "Escrow not funded");

        PuzzleData memory puzzleAData = puzzles[puzzleA];
        PuzzleData memory puzzleBData = puzzles[puzzleB];

        require(puzzleAData.timeSolved != 0, "Solution A not posted");
        require(puzzleBData.timeSolved != 0, "Solution B not posted");

        uint finalTimelock = (puzzleBData.timeSolved < puzzleAData.timeSolved) ? timeLockB : timeLockA;
        require(now < finalTimelock, "After claim timelock");

        require(escrow.send(claimAddress, escrowAmount), "Claim send failed");
        emit EscrowSettled(escrowAddress, SettlementType.Claim);
    }

    function refundEscrow(
        bytes32 puzzleA,
        bytes32 puzzleB,
        address tokenAddress,
        uint escrowAmount,
        uint timeLockA,
        uint timeLockB,
        address payable claimAddress,
        address payable refundAddress
    )
        external
    {
        (bytes32 escrowParamsHash, bytes memory bytecode) = computeCreate2Params(
            EscrowParams(puzzleA, puzzleB, tokenAddress, escrowAmount, timeLockA, timeLockB, claimAddress, refundAddress)
        );

        address escrowAddress = Create2.computeAddress(escrowParamsHash, bytecode);

        if(! isContract(escrowAddress)) {
           Create2.deploy(escrowParamsHash, bytecode);
        }
        IEscrow escrow = IEscrow(escrowAddress);

        uint timeSolvedB = puzzles[puzzleB].timeSolved;
        uint timeSolvedA = puzzles[puzzleA].timeSolved;

        uint finalTimelock = (timeSolvedB != 0 && (timeSolvedA == 0 || timeSolvedB < timeSolvedA)) ? timeLockB : timeLockA;
        require(now >= finalTimelock, "Before refund timelock");

        uint balance = escrow.balance();
        require(balance > 0, "Refund balance must be > 0");
        require(escrow.send(refundAddress, balance), "Refund send failed");
        emit EscrowSettled(escrowAddress, SettlementType.Refund);
    }

    function computeCreate2Params(EscrowParams memory escrowParams) internal view
    returns (bytes32 salt, bytes memory bytecode)
    {
        bytes32 escrowParamsHash = keccak256(abi.encodePacked(
            escrowParams.puzzleA,
            escrowParams.puzzleB,
            escrowParams.tokenAddress,
            escrowParams.escrowAmount,
            escrowParams.timeLockA,
            escrowParams.timeLockB,
            escrowParams.claimAddress,
            escrowParams.refundAddress
        ));

        if(escrowParams.tokenAddress == address(0)) {
            bytes memory constructorArgs = abi.encode(address(this));
            bytecode = abi.encodePacked(type(ETHEscrow).creationCode, constructorArgs);
        } else {
            bytes memory constructorArgs = abi.encode(address(this), escrowParams.tokenAddress);
            bytecode = abi.encodePacked(type(ERC20Escrow).creationCode, constructorArgs);
        }

        return (escrowParamsHash, bytecode);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}