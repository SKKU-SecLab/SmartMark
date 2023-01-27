
pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function _initialize(string memory name_, string memory symbol_) internal virtual {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
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

    function burn(uint256 amount) public virtual {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {

        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

interface IGovernance
{
    function isModule(address, address) external view returns (bool);
    function isAuthorized(address, address) external view returns (bool);
    function getModule(address, bytes4) external view returns (address);
    function getConfig(address, bytes32) external view returns (uint256);
    function getNiftexWallet() external view returns (address);
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _setOwner(address owner_) internal {
        emit OwnershipTransferred(_owner, owner_);
        _owner = owner_;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC1363Transfer {

    function transferAndCall(address to, uint256 value) external returns (bool);

    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);


    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);
}

interface IERC1363Approve {
  function approveAndCall(address spender, uint256 value) external returns (bool);

  function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

interface IERC1363 is IERC1363Transfer, IERC1363Approve {
}// MIT

pragma solidity ^0.8.0;

interface IERC1363Receiver {

  function onTransferReceived(address operator, address from, uint256 value, bytes calldata data) external returns (bytes4);
}// MIT

pragma solidity ^0.8.0;

interface IERC1363Spender {

  function onApprovalReceived(address owner, uint256 value, bytes calldata data) external returns (bytes4);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1363Transfer is ERC20, IERC1363Transfer {
    function transferAndCall(address to, uint256 value) public override returns (bool) {
        return transferAndCall(to, value, bytes(""));
    }

    function transferAndCall(address to, uint256 value, bytes memory data) public override returns (bool) {
        require(transfer(to, value));
        try IERC1363Receiver(to).onTransferReceived(_msgSender(), _msgSender(), value, data) returns (bytes4 selector) {
            require(selector == IERC1363Receiver(to).onTransferReceived.selector, "ERC1363: onTransferReceived invalid result");
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("ERC1363: onTransferReceived reverted without reason");
        }
        return true;
    }

    function transferFromAndCall(address from, address to, uint256 value) public override returns (bool) {
        return transferFromAndCall(from, to, value, bytes(""));
    }

    function transferFromAndCall(address from, address to, uint256 value, bytes memory data) public override returns (bool) {
        require(transferFrom(from, to, value));
        try IERC1363Receiver(to).onTransferReceived(_msgSender(), from, value, data) returns (bytes4 selector) {
            require(selector == IERC1363Receiver(to).onTransferReceived.selector, "ERC1363: onTransferReceived invalid result");
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("ERC1363: onTransferReceived reverted without reason");
        }
        return true;
    }
}

abstract contract ERC1363Approve is ERC20, IERC1363Approve {
    function approveAndCall(address spender, uint256 value) public override returns (bool) {
        return approveAndCall(spender, value, bytes(""));
    }

    function approveAndCall(address spender, uint256 value, bytes memory data) public override returns (bool) {
        require(approve(spender, value));
        try IERC1363Spender(spender).onApprovalReceived(_msgSender(), value, data) returns (bytes4 selector) {
            require(selector == IERC1363Spender(spender).onApprovalReceived.selector, "ERC1363: onApprovalReceived invalid result");
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("ERC1363: onApprovalReceived reverted without reason");
        }
        return true;
    }
}

abstract contract ERC1363 is ERC1363Transfer, ERC1363Approve {}// MIT

pragma solidity ^0.8.0;


contract ShardedWallet is Ownable, ERC20, ERC1363Approve
{
    bytes32 public constant ALLOW_GOVERNANCE_UPGRADE = 0xedde61aea0459bc05d70dd3441790ccfb6c17980a380201b00eca6f9ef50452a;

    IGovernance public governance;
    address public artistWallet;

    event Received(address indexed sender, uint256 value, bytes data);
    event Execute(address indexed to, uint256 value, bytes data);
    event ModuleExecute(address indexed module, address indexed to, uint256 value, bytes data);
    event GovernanceUpdated(address indexed oldGovernance, address indexed newGovernance);
    event ArtistUpdated(address indexed oldArtist, address indexed newArtist);

    modifier onlyModule()
    {
        require(_isModule(msg.sender), "Access restricted to modules");
        _;
    }

    constructor()
    {
        governance = IGovernance(address(0xdead));
    }

    receive()
    external payable
    {
        emit Received(msg.sender, msg.value, bytes(""));
    }

    fallback()
    external payable
    {
        address module = governance.getModule(address(this), msg.sig);
        if (module != address(0) && _isModule(module))
        {
            (bool success, /*bytes memory returndata*/) = module.staticcall(msg.data);
            assembly {
                returndatacopy(0, 0, returndatasize())
                switch success
                case 0 { revert(0, returndatasize()) }
                default { return (0, returndatasize()) }
            }
        }
        else
        {
            emit Received(msg.sender, msg.value, msg.data);
        }
    }

    function initialize(
        address         governance_,
        address         minter_,
        string calldata name_,
        string calldata symbol_,
        address         artistWallet_
    )
    external
    {
        require(address(governance) == address(0));

        governance = IGovernance(governance_);
        Ownable._setOwner(minter_);
        ERC20._initialize(name_, symbol_);
        artistWallet = artistWallet_;

        emit GovernanceUpdated(address(0), governance_);
    }

    function _isModule(address module)
    internal view returns (bool)
    {
        return governance.isModule(address(this), module);
    }

    function execute(address to, uint256 value, bytes calldata data)
    external onlyOwner()
    {
        Address.functionCallWithValue(to, data, value);
        emit Execute(to, value, data);
    }

    function retrieve(address newOwner)
    external
    {
        ERC20._burn(msg.sender, Math.max(ERC20.totalSupply(), 1));
        Ownable._setOwner(newOwner);
    }

    function moduleExecute(address to, uint256 value, bytes calldata data)
    external onlyModule()
    {
        if (Address.isContract(to))
        {
            Address.functionCallWithValue(to, data, value);
        }
        else
        {
            Address.sendValue(payable(to), value);
        }
        emit ModuleExecute(msg.sender, to, value, data);
    }

    function moduleMint(address to, uint256 value)
    external onlyModule()
    {
        ERC20._mint(to, value);
    }

    function moduleBurn(address from, uint256 value)
    external onlyModule()
    {
        ERC20._burn(from, value);
    }

    function moduleTransfer(address from, address to, uint256 value)
    external onlyModule()
    {
        ERC20._transfer(from, to, value);
    }

    function moduleTransferOwnership(address to)
    external onlyModule()
    {
        Ownable._setOwner(to);
    }

    function updateGovernance(address newGovernance)
    external onlyModule()
    {
        emit GovernanceUpdated(address(governance), newGovernance);

        require(governance.getConfig(address(this), ALLOW_GOVERNANCE_UPGRADE) > 0);
        require(Address.isContract(newGovernance));
        governance = IGovernance(newGovernance);
    }

    function updateArtistWallet(address newArtistWallet)
    external onlyModule()
    {
        emit ArtistUpdated(artistWallet, newArtistWallet);

        artistWallet = newArtistWallet;
    }
}// MIT

pragma solidity ^0.8.0;


contract LiquidityToken is ERC20 {
    address public controler;

    modifier onlyControler() {
        require(msg.sender == controler);
        _;
    }

    constructor() {
        controler = address(0xdead);
    }

    function initialize(address controler_, string memory name_, string memory symbol_) public {
        require(controler == address(0));
        controler = controler_;
        _initialize(name_, symbol_);
    }

    function controllerTransfer(address sender, address recipient, uint256 amount) public onlyControler {
        _transfer(sender, recipient, amount);
    }

    function controllerMint(address account, uint256 amount) public onlyControler {
        _mint(account, amount);
    }

    function controllerBurn(address account, uint256 amount) public onlyControler {
        _burn(account, amount);
    }
}

contract DefaultPricingCurve is IERC1363Spender {
    struct CurveCoordinates {
        uint256 x;
        uint256 k;
    }

    struct Asset {
        uint256 underlyingSupply;
        uint256 feeToNiftex;
        uint256 feeToArtist;
    }

    LiquidityToken immutable internal _template;

    bytes32 public constant PCT_FEE_SUPPLIERS  = 0xe4f5729eb40e38b5a39dfb36d76ead9f9bc286f06852595980c5078f1af7e8c9;
    bytes32 public constant PCT_FEE_ARTIST     = 0xdd0618e2e2a17ff193a933618181c8f8909dc169e9707cce1921893a88739ca0;
    bytes32 public constant PCT_FEE_NIFTEX     = 0xcfb1dd89e6f4506eca597e7558fbcfe22dbc7e0b9f2b3956e121d0e344d6f7aa;
    bytes32 public constant LIQUIDITY_TIMELOCK = 0x4babff57ebd34f251a515a845400ed950a51f0a64c92e803a3e144fc40623fa8;
    bytes32 public constant CURVE_STRETCH = 0x93dd957c7b5128fa849cb38b3ebc75f4cb0ed832255ea21c35a997582634caa4;

    LiquidityToken   public   etherLPToken;
    LiquidityToken   public   shardLPToken;
    CurveCoordinates public   curve;
    Asset            internal _etherLPExtra;
    Asset            internal _shardLPExtra;
    address          public   wallet;
    address          public   recipient;
    uint256          public   deadline;

    event Initialized(address wallet);
    event ShardsBought(address indexed account, uint256 amount, uint256 cost);
    event ShardsSold(address indexed account, uint256 amount, uint256 payout);
    event ShardsSupplied(address indexed provider, uint256 amount);
    event EtherSupplied(address indexed provider, uint256 amount);
    event ShardsWithdrawn(address indexed provider, uint256 payout, uint256 shards, uint256 amountLPToken);
    event EtherWithdrawn(address indexed provider, uint256 value, uint256 payout, uint256 amountLPToken);
    event KUpdated(uint256 newK, uint256 newX);

    constructor() {
        _template = new LiquidityToken();
        wallet = address(0xdead);
    }

    function initialize(
        uint256 supply,
        address wallet_,
        address recipient_,
        uint256 price
    )
    public payable
    {
        require(wallet == address(0));
        uint256 totalSupply   = ShardedWallet(payable(wallet_)).totalSupply();
        string memory name_   = ShardedWallet(payable(wallet_)).name();
        string memory symbol_ = ShardedWallet(payable(wallet_)).symbol();

        etherLPToken = LiquidityToken(Clones.clone(address(_template)));
        shardLPToken = LiquidityToken(Clones.clone(address(_template)));
        etherLPToken.initialize(address(this), string(abi.encodePacked(name_, "-EtherLP")), string(abi.encodePacked(symbol_, "-ELP")));
        shardLPToken.initialize(address(this), string(abi.encodePacked(name_, "-ShardLP")), string(abi.encodePacked(symbol_, "-SLP")));

        wallet    = wallet_;
        recipient = recipient_;
        deadline  = block.timestamp + ShardedWallet(payable(wallet_)).governance().getConfig(wallet_, LIQUIDITY_TIMELOCK);
        emit Initialized(wallet_);

        if (supply > 0) {
            require(ShardedWallet(payable(wallet_)).transferFrom(msg.sender, address(this), supply));
        }

        {
            uint256 decimals = ShardedWallet(payable(wallet_)).decimals();
            IGovernance governance = ShardedWallet(payable(wallet_)).governance();

            uint256 curveStretch = governance.getConfig(wallet_, CURVE_STRETCH);
            curveStretch = Math.min(Math.max(1, curveStretch), 10); // curveStretch ranges from 1 to 10.

            curve.k = totalSupply * totalSupply * price / 10**decimals * curveStretch * curveStretch / 100;
            curve.x = totalSupply * curveStretch / 10;
        }

        address mintTo = deadline == block.timestamp ? recipient_ : address(this);
        etherLPToken.controllerMint(mintTo, msg.value);
        shardLPToken.controllerMint(mintTo, supply);
        _etherLPExtra.underlyingSupply = msg.value;
        _shardLPExtra.underlyingSupply = supply;
        emit EtherSupplied(mintTo, msg.value);
        emit ShardsSupplied(mintTo, supply);
    }

    function buyShards(uint256 amount, uint256 maxCost) public payable {
        uint256 cost = _buyShards(msg.sender, amount, maxCost);

        require(cost <= msg.value);
        if (msg.value > cost) {
            Address.sendValue(payable(msg.sender), msg.value - cost);
        }
    }

    function sellShards(uint256 amount, uint256 minPayout) public {
        require(ShardedWallet(payable(wallet)).transferFrom(msg.sender, address(this), amount));
        _sellShards(msg.sender, amount, minPayout);
    }

    function supplyEther() public payable {
        _supplyEther(msg.sender, msg.value);
    }

    function supplyShards(uint256 amount) public {
        require(ShardedWallet(payable(wallet)).transferFrom(msg.sender, address(this), amount));
        _supplyShards(msg.sender, amount);
    }

    function onApprovalReceived(address owner, uint256 amount, bytes calldata data) public override returns (bytes4) {
        require(msg.sender == wallet);
        require(ShardedWallet(payable(wallet)).transferFrom(owner, address(this), amount));

        bytes4 selector = abi.decode(data, (bytes4));
        if (selector == this.sellShards.selector) {
            (,uint256 minPayout) = abi.decode(data, (bytes4, uint256));
            _sellShards(owner, amount, minPayout);
        } else if (selector == this.supplyShards.selector) {
            _supplyShards(owner, amount);
        } else {
            revert("invalid selector in onApprovalReceived data");
        }

        return this.onApprovalReceived.selector;
    }

    function _buyShards(address buyer, uint256 amount, uint256 maxCost) internal returns (uint256) {
        IGovernance governance = ShardedWallet(payable(wallet)).governance();
        address     owner      = ShardedWallet(payable(wallet)).owner();
        address     artist     = ShardedWallet(payable(wallet)).artistWallet();

        require(owner == address(0) || governance.isModule(wallet, owner));

        uint256[3] memory fees;
        fees[0] =                            governance.getConfig(wallet, PCT_FEE_SUPPLIERS);
        fees[1] =                            governance.getConfig(wallet, PCT_FEE_NIFTEX);
        fees[2] = artist == address(0) ? 0 : governance.getConfig(wallet, PCT_FEE_ARTIST);

        uint256 amountWithFee = amount * (10**18 + fees[0] + fees[1] + fees[2]) / 10**18;

        uint256 newX = curve.x - amountWithFee;
        uint256 newY = curve.k / newX;
        require(newX > 0 && newY > 0);

        uint256 cost = newY - curve.k / curve.x;
        require(cost <= maxCost);

        require(ShardedWallet(payable(wallet)).balanceOf(address(this)) - _shardLPExtra.feeToNiftex - _shardLPExtra.feeToArtist >= amount * (10**18 + fees[1] + fees[2]) / 10**18);

        curve.x = curve.x - amount * (10**18 + fees[1] + fees[2]) / 10**18;

        _shardLPExtra.underlyingSupply += amount * fees[0] / 10**18;
        _shardLPExtra.feeToNiftex      += amount * fees[1] / 10**18;
        _shardLPExtra.feeToArtist      += amount * fees[2] / 10**18;

        ShardedWallet(payable(wallet)).transfer(buyer, amount);

        emit ShardsBought(buyer, amount, cost);
        return cost;
    }

    function _sellShards(address seller, uint256 amount, uint256 minPayout) internal returns (uint256) {
        IGovernance governance = ShardedWallet(payable(wallet)).governance();
        address     owner      = ShardedWallet(payable(wallet)).owner();
        address     artist     = ShardedWallet(payable(wallet)).artistWallet();

        require(owner == address(0) || governance.isModule(wallet, owner));

        uint256[3] memory fees;
        fees[0] =                            governance.getConfig(wallet, PCT_FEE_SUPPLIERS);
        fees[1] =                            governance.getConfig(wallet, PCT_FEE_NIFTEX);
        fees[2] = artist == address(0) ? 0 : governance.getConfig(wallet, PCT_FEE_ARTIST);

        uint256 newX = curve.x + amount;
        uint256 newY = curve.k / newX;
        require(newX > 0 && newY > 0);

        uint256 payout = curve.k / curve.x - newY;
        require(payout <= address(this).balance - _etherLPExtra.feeToNiftex - _etherLPExtra.feeToArtist);
        uint256 value = payout * (10**18 - fees[0] - fees[1] - fees[2]) / 10**18;
        require(value >= minPayout);

        curve.x = newX;

        _etherLPExtra.underlyingSupply += payout * fees[0] / 10**18;
        _etherLPExtra.feeToNiftex      += payout * fees[1] / 10**18;
        _etherLPExtra.feeToArtist      += payout * fees[2] / 10**18;

        Address.sendValue(payable(seller), value);

        emit ShardsSold(seller, amount, value);
        return value;
    }

    function _supplyEther(address supplier, uint256 amount) internal {
        etherLPToken.controllerMint(supplier, calcNewEthLPTokensToIssue(amount));
        _etherLPExtra.underlyingSupply += amount;

        emit EtherSupplied(supplier, amount);
    }


    function _supplyShards(address supplier, uint256 amount) internal {
        shardLPToken.controllerMint(supplier, calcNewShardLPTokensToIssue(amount));
        _shardLPExtra.underlyingSupply += amount;

        emit ShardsSupplied(supplier, amount);
    }

    function calcNewShardLPTokensToIssue(uint256 amount) public view returns (uint256) {
        uint256 pool = _shardLPExtra.underlyingSupply;
        if (pool == 0) { return amount; }
        uint256 proportion = amount * 10**18 / (pool + amount);
        return proportion * shardLPToken.totalSupply() / (10**18 - proportion);
    }

    function calcNewEthLPTokensToIssue(uint256 amount) public view returns (uint256) {
        uint256 pool = _etherLPExtra.underlyingSupply;
        if (pool == 0) { return amount; }
        uint256 proportion = amount * 10**18 / (pool + amount);
        return proportion * etherLPToken.totalSupply() / (10**18 - proportion);
    }

    function calcShardsForEthSuppliers() public view returns (uint256) {
        uint256 balance = ShardedWallet(payable(wallet)).balanceOf(address(this)) - _shardLPExtra.feeToNiftex - _shardLPExtra.feeToArtist;
        return balance < _shardLPExtra.underlyingSupply ? 0 : balance - _shardLPExtra.underlyingSupply;
    }

    function calcEthForShardSuppliers() public view returns (uint256) {
        uint256 balance = address(this).balance - _etherLPExtra.feeToNiftex - _etherLPExtra.feeToArtist;
        return balance < _etherLPExtra.underlyingSupply ? 0 : balance - _etherLPExtra.underlyingSupply;
    }

    function withdrawSuppliedEther(uint256 amount) external returns (uint256, uint256) {
        require(amount > 0);

        uint256 etherLPTokenSupply = etherLPToken.totalSupply();

        uint256 balance = address(this).balance - _etherLPExtra.feeToNiftex - _etherLPExtra.feeToArtist;

        uint256 value = (balance <= _etherLPExtra.underlyingSupply)
        ? balance * amount / etherLPTokenSupply
        : _etherLPExtra.underlyingSupply * amount / etherLPTokenSupply;

        uint256 payout = calcShardsForEthSuppliers() * amount / etherLPTokenSupply;

        _etherLPExtra.underlyingSupply *= etherLPTokenSupply - amount;
        _etherLPExtra.underlyingSupply /= etherLPTokenSupply;
        etherLPToken.controllerBurn(msg.sender, amount);

        Address.sendValue(payable(msg.sender), value);
        if (payout > 0) {
            ShardedWallet(payable(wallet)).transfer(msg.sender, payout);
        }

        emit EtherWithdrawn(msg.sender, value, payout, amount);

        return (value, payout);
    }

    function withdrawSuppliedShards(uint256 amount) external returns (uint256, uint256) {
        require(amount > 0);

        uint256 shardLPTokenSupply = shardLPToken.totalSupply();

        uint256 balance = ShardedWallet(payable(wallet)).balanceOf(address(this)) - _shardLPExtra.feeToNiftex - _shardLPExtra.feeToArtist;

        uint256 shards = (balance <= _shardLPExtra.underlyingSupply)
        ? balance * amount / shardLPTokenSupply
        : _shardLPExtra.underlyingSupply * amount / shardLPTokenSupply;

        uint256 payout = calcEthForShardSuppliers() * amount / shardLPTokenSupply;

        _shardLPExtra.underlyingSupply *= shardLPTokenSupply - amount;
        _shardLPExtra.underlyingSupply /= shardLPTokenSupply;
        shardLPToken.controllerBurn(msg.sender, amount);

        ShardedWallet(payable(wallet)).transfer(msg.sender, shards);
        if (payout > 0) {
            Address.sendValue(payable(msg.sender), payout);
        }

        emit ShardsWithdrawn(msg.sender, payout, shards, amount);

        return (payout, shards);
    }

    function withdrawNiftexOrArtistFees(address to) public {
        uint256 etherFees = 0;
        uint256 shardFees = 0;

        if (msg.sender == ShardedWallet(payable(wallet)).artistWallet()) {
            etherFees += _etherLPExtra.feeToArtist;
            shardFees += _shardLPExtra.feeToArtist;
            delete _etherLPExtra.feeToArtist;
            delete _shardLPExtra.feeToArtist;
        }

        if (msg.sender == ShardedWallet(payable(wallet)).governance().getNiftexWallet()) {
            etherFees += _etherLPExtra.feeToNiftex;
            shardFees += _shardLPExtra.feeToNiftex;
            delete _etherLPExtra.feeToNiftex;
            delete _shardLPExtra.feeToNiftex;
        }

        Address.sendValue(payable(to), etherFees);
        ShardedWallet(payable(wallet)).transfer(to, shardFees);
    }

    function transferTimelockLiquidity() public {
        require(deadline < block.timestamp);
        etherLPToken.controllerTransfer(address(this), recipient, getEthLPTokens(address(this)));
        shardLPToken.controllerTransfer(address(this), recipient, getShardLPTokens(address(this)));
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function updateK(uint256 newK_) public {
        require(msg.sender == wallet);
        curve.x = curve.x * sqrt(newK_ * 10**12 / curve.k) / 10**6;
        curve.k = newK_;
        assert(curve.k > 0);
        assert(curve.x > 0);
        emit KUpdated(curve.k, curve.x);
    }

    function updateKAndX(uint256 newK_, uint256 newX_) public {
        ShardedWallet sw = ShardedWallet(payable(wallet));
        uint256 effectiveShardBal = sw.balanceOf(msg.sender) + shardLPToken.balanceOf(msg.sender) * sw.balanceOf(address(this)) / shardLPToken.totalSupply();
        require(effectiveShardBal == sw.totalSupply());
        curve.x = newX_;
        curve.k = newK_;
        assert(curve.k > 0);
        assert(curve.x > 0);
        emit KUpdated(curve.k, curve.x);
    }

    function getEthLPTokens(address owner) public view returns (uint256) {
        return etherLPToken.balanceOf(owner);
    }

    function getShardLPTokens(address owner) public view returns (uint256) {
        return shardLPToken.balanceOf(owner);
    }

    function transferEthLPTokens(address to, uint256 amount) public {
        etherLPToken.controllerTransfer(msg.sender, to, amount);
    }

    function transferShardLPTokens(address to, uint256 amount) public {
        shardLPToken.controllerTransfer(msg.sender, to, amount);
    }

    function getCurrentPrice() external view returns (uint256) {
        return curve.k * 10**18 / curve.x / curve.x;
    }

    function getEthSuppliers() external view returns (uint256, uint256, uint256, uint256) {
        return (_etherLPExtra.underlyingSupply, etherLPToken.totalSupply(), _etherLPExtra.feeToNiftex, _etherLPExtra.feeToArtist);
    }

    function getShardSuppliers() external view returns (uint256, uint256, uint256, uint256) {
        return (_shardLPExtra.underlyingSupply, shardLPToken.totalSupply(), _shardLPExtra.feeToNiftex, _shardLPExtra.feeToArtist);
    }
}