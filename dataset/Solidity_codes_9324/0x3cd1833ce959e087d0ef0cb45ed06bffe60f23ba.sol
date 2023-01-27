
pragma solidity >=0.6.0 <0.8.0;

interface IERC777 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(address recipient, uint256 amount, bytes calldata data) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC777Recipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 _interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC777Sender {

    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


contract ERC777 is Context, IERC777, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    IERC1820Registry constant internal _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    bytes32 constant private _TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    address[] private _defaultOperatorsArray;

    mapping(address => bool) private _defaultOperators;

    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    mapping (address => mapping (address => uint256)) private _allowances;

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) public {
        _name = name_;
        _symbol = symbol_;

        _defaultOperatorsArray = defaultOperators_;
        for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
            _defaultOperators[_defaultOperatorsArray[i]] = true;
        }

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return 18;
    }

    function granularity() public view override returns (uint256) {

        return 1;
    }

    function totalSupply() public view override(IERC20, IERC777) returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address tokenHolder) public view override(IERC20, IERC777) returns (uint256) {

        return _balances[tokenHolder];
    }

    function send(address recipient, uint256 amount, bytes memory data) public override  {

        _send(_msgSender(), recipient, amount, data, "", true);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = _msgSender();

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    function burn(uint256 amount, bytes memory data) public override  {

        _burn(_msgSender(), amount, data, "");
    }

    function isOperatorFor(
        address operator,
        address tokenHolder
    ) public view override returns (bool) {

        return operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

    function authorizeOperator(address operator) public override  {

        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

    function revokeOperator(address operator) public override  {

        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

    function defaultOperators() public view override returns (address[] memory) {

        return _defaultOperatorsArray;
    }

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
    public override
    {

        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(sender, recipient, amount, data, operatorData, true);
    }

    function operatorBurn(address account, uint256 amount, bytes memory data, bytes memory operatorData) public override {

        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(account, amount, data, operatorData);
    }

    function allowance(address holder, address spender) public view override returns (uint256) {

        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {

        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

    function transferFrom(address holder, address recipient, uint256 amount) public override returns (bool) {

        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = _msgSender();

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");
        _approve(holder, spender, _allowances[holder][spender].sub(amount, "ERC777: transfer amount exceeds allowance"));

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
    internal virtual
    {

        require(account != address(0), "ERC777: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        internal
    {

        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    function _burn(
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        internal virtual
    {

        require(from != address(0), "ERC777: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), amount);

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        _balances[from] = _balances[from].sub(amount, "ERC777: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {

        _beforeTokenTransfer(operator, from, to, amount);

        _balances[from] = _balances[from].sub(amount, "ERC777: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _approve(address holder, address spender, uint256 value) internal {

        require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {

        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        private
    {

        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity 0.6.9;


struct Farm {
    uint256 amount;
    uint256 compostedAmount;
    uint256 blockNumber;
    uint256 lastHarvestedBlockNumber;
    address harvesterAddress;
}

contract Corn is ERC777, IERC777Recipient, ReentrancyGuard {
    using SafeMath for uint256;

    modifier preventSameBlock(address targetAddress) {
        require(
            farms[targetAddress].blockNumber != block.number &&
                farms[targetAddress].lastHarvestedBlockNumber != block.number,
            "You can not allocate/release or harvest in the same block"
        );
        _; // Call the actual code
    }

    modifier requireFarm(address targetAddress, bool requiredState) {
        if (requiredState) {
            require(
                farms[targetAddress].amount != 0,
                "You must have allocated land to grow crops on your farm"
            );
        } else {
            require(
                farms[targetAddress].amount == 0,
                "You must have released your land"
            );
        }
        _; // Call the actual code
    }

    IERC777 private immutable _token;
    IERC1820Registry private _erc1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH =
        keccak256("ERC777TokensRecipient");

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata,
        bytes calldata
    ) external override {
        require(amount > 0, "You must receive a positive number of tokens");
        require(
            _msgSender() == address(_token),
            "You can only build farms on LAND"
        );

        require(
            operator == address(this),
            "Only CORN contract can send itself LAND tokens"
        );
        require(to == address(this), "Funds must be coming into a CORN token");
        require(from != to, "Why would CORN contract send tokens to itself?");
    }

    uint256 private immutable _startMaturityBoost;

    uint256 private immutable _endMaturityBoost;

    uint256 private immutable _failsafeTargetBlock;

    constructor(
        address token,
        uint256 startMaturityBoost,
        uint256 endMaturityBoost,
        uint256 failsafeBlockDuration
    ) public ERC777("Corn", "CORN", new address[](0)) {
        require(
            endMaturityBoost > 0,
            "endMaturityBoost must be at least 1 block (min 24 hours before time farm maturation starts)"
        ); // to avoid division by 0

        _token = IERC777(token);
        _startMaturityBoost = startMaturityBoost;
        _endMaturityBoost = endMaturityBoost;
        _failsafeTargetBlock = block.number.add(failsafeBlockDuration);

        _erc1820.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

    uint256 private constant _harvestPerBlockDivisor = 10**8;

    uint256 private constant _ratioMultiplier = 10**10;

    uint256 private constant _percentMultiplier = 10000;

    uint256 public constant failsafeMaxAmount = 1000 * (10**18);

    uint256 public constant maxCompostBoost = 100000;

    uint256 public constant maxMaturityBoost = 30000;

    uint256 public constant maxGrowthCycle = 268800;

    uint256 public constant maturityBoostExtension = 20000;

    mapping(address => Farm) public farms;

    uint256 public globalAllocatedAmount;

    uint256 public globalCompostedAmount;

    uint256 public globalTotalFarms;

    event Allocated(
        address sender,
        uint256 blockNumber,
        address farmerAddress,
        uint256 amount,
        uint256 burnedAmountIncrease
    );
    event Released(
        address sender,
        uint256 amount,
        uint256 burnedAmountDecrease
    );
    event Composted(
        address sender,
        address targetAddress,
        uint256 amount
    );
    event Harvested(
        address sender,
        uint256 blockNumber,
        address sourceAddress,
        address targetAddress,
        uint256 targetBlock,
        uint256 amount
    );


    function allocate(address farmerAddress, uint256 amount)
        public
        nonReentrant()
        preventSameBlock(_msgSender())
        requireFarm(_msgSender(), false) // Ensure LAND is not already in a farm
    {
        require(
            amount > 0,
            "You must provide a positive amount of LAND to build a farm"
        );

        if (block.number < _failsafeTargetBlock) {
            require(
                amount <= failsafeMaxAmount,
                "You can only allocate a maximum of 1000 LAND during failsafe."
            );
        }

        Farm storage senderFarm = farms[_msgSender()]; // Shortcut accessor

        senderFarm.amount = amount;
        senderFarm.blockNumber = block.number;
        senderFarm.lastHarvestedBlockNumber = block.number; // Reset the last harvest height to the new LAND allocation height
        senderFarm.harvesterAddress = farmerAddress;

        globalAllocatedAmount = globalAllocatedAmount.add(amount);
        globalCompostedAmount = globalCompostedAmount.add(
            senderFarm.compostedAmount
        );
        globalTotalFarms += 1;

        emit Allocated(
            _msgSender(),
            block.number,
            farmerAddress,
            amount,
            senderFarm.compostedAmount
        );

        IERC777(_token).operatorSend(
            _msgSender(),
            address(this),
            amount,
            "",
            ""
        ); // [RE-ENTRANCY WARNING] external call, must be at the end
    }

    function release()
        public
        nonReentrant()
        preventSameBlock(_msgSender())
        requireFarm(_msgSender(), true) // Ensure the address you are releasing has a farm on the LAND
    {
        Farm storage senderFarm = farms[_msgSender()]; // Shortcut accessor

        uint256 amount = senderFarm.amount;
        senderFarm.amount = 0;

        globalAllocatedAmount = globalAllocatedAmount.sub(amount);
        globalCompostedAmount = globalCompostedAmount.sub(
            senderFarm.compostedAmount
        );
        globalTotalFarms = globalTotalFarms.sub(1);

        emit Released(_msgSender(), amount, senderFarm.compostedAmount);

        IERC777(_token).send(_msgSender(), amount, ""); // [RE-ENTRANCY WARNING] external call, must be at the end
    }

    function compost(address targetAddress, uint256 amount)
        public
        nonReentrant()
        requireFarm(targetAddress, true) // Ensure the address you are composting to has a farm on the LAND
    {
        require(amount > 0, "Nothing to compost");

        Farm storage targetFarm = farms[targetAddress]; // Shortcut accessor, pay attention to targetAddress here

        targetFarm.compostedAmount = targetFarm.compostedAmount.add(amount);

        globalCompostedAmount = globalCompostedAmount.add(amount);

        emit Composted(_msgSender(), targetAddress, amount);

        _burn(_msgSender(), amount, "", ""); // [RE-ENTRANCY WARNING] external call, must be at the end
    }

    function harvest(
        address sourceAddress,
        address targetAddress,
        uint256 targetBlock
    )
        public
        nonReentrant()
        preventSameBlock(sourceAddress)
        requireFarm(sourceAddress, true) // Ensure the adress that is being harvested has a farm on the LAND
    {
        require(
            targetBlock <= block.number,
            "You can only harvest up to current block"
        );

        Farm storage sourceFarm = farms[sourceAddress]; // Shortcut accessor, pay attention to sourceAddress here

        require(
            sourceFarm.lastHarvestedBlockNumber < targetBlock,
            "You can only harvest ahead of last harvested block"
        );
        require(
            sourceFarm.harvesterAddress == _msgSender(),
            "You must be the delegated harvester of the sourceAddress"
        );

        uint256 mintAmount = getHarvestAmount(sourceAddress, targetBlock);
        require(mintAmount > 0, "Nothing to harvest");

        sourceFarm.lastHarvestedBlockNumber = targetBlock; // Reset the last harvested height

        emit Harvested(
            _msgSender(),
            block.number,
            sourceAddress,
            targetAddress,
            targetBlock,
            mintAmount
        );

        _mint(targetAddress, mintAmount, "", ""); // [RE-ENTRANCY WARNING] external call, must be at the end
    }


    function getHarvestAmount(address targetAddress, uint256 targetBlock)
        public
        view
        returns (uint256)
    {
        Farm storage targetFarm = farms[targetAddress]; // Shortcut accessor

        if (targetFarm.amount == 0) {
            return 0;
        }

        require(
            targetBlock <= block.number,
            "You can only calculate up to current block"
        );
        require(
            targetFarm.lastHarvestedBlockNumber <= targetBlock,
            "You can only specify blocks at or ahead of last harvested block"
        );

        uint256 lastBlockInGrowthCycle =
            targetFarm.lastHarvestedBlockNumber.add(maxGrowthCycle); // end of growth cycle last allowed block
        uint256 blocksMinted = maxGrowthCycle;

        if (targetBlock < lastBlockInGrowthCycle) {
            blocksMinted = targetBlock.sub(targetFarm.lastHarvestedBlockNumber);
        }

        uint256 amount = targetFarm.amount; // Total of size of the farm in LAND for this address
        uint256 blocksMintedByAmount = amount.mul(blocksMinted);

        uint256 compostMultiplier = getAddressCompostMultiplier(targetAddress);
        uint256 maturityMultipler = getAddressMaturityMultiplier(targetAddress);
        uint256 afterMultiplier =
            blocksMintedByAmount
                .mul(compostMultiplier)
                .div(_percentMultiplier)
                .mul(maturityMultipler)
                .div(_percentMultiplier);

        uint256 actualMinted = afterMultiplier.div(_harvestPerBlockDivisor);

        return actualMinted;
    }

    function getAddressMaturityMultiplier(address targetAddress)
        public
        view
        returns (uint256)
    {
        Farm storage targetFarm = farms[targetAddress]; // Shortcut accessor

        if (targetFarm.amount == 0) {
            return _percentMultiplier;
        }

        uint256 targetBlockNumber =
            targetFarm.blockNumber.add(_startMaturityBoost);
        if (block.number < targetBlockNumber) {
            return _percentMultiplier;
        }

        uint256 blockDiff =
            block.number
            .sub(targetBlockNumber)
            .mul(maturityBoostExtension)
            .div(_endMaturityBoost)
            .add(_percentMultiplier);

        uint256 timeMultiplier = Math.min(maxMaturityBoost, blockDiff); // Min 1x, Max 3x
        return timeMultiplier;
    }

    function getAddressCompostMultiplier(address targetAddress)
        public
        view
        returns (uint256)
    {
        uint256 myRatio = getAddressRatio(targetAddress);
        uint256 globalRatio = getGlobalRatio();

        if (globalRatio == 0 || myRatio == 0) {
            return _percentMultiplier;
        }

        uint256 compostMultiplier =
            Math.min(
                maxCompostBoost,
                myRatio.mul(_percentMultiplier).div(globalRatio).add(
                    _percentMultiplier
                )
            ); // Min 1x, Max 10x
        return compostMultiplier;
    }

    function getAddressRatio(address targetAddress)
        public
        view
        returns (uint256)
    {
        Farm storage targetFarm = farms[targetAddress]; // Shortcut accessor

        uint256 addressLockedAmount = targetFarm.amount;
        uint256 addressBurnedAmount = targetFarm.compostedAmount;

        if (addressLockedAmount == 0) {
            return 0;
        }

        uint256 myRatio =
            addressBurnedAmount.mul(_ratioMultiplier).div(addressLockedAmount);
        return myRatio;
    }

    function getGlobalRatio() public view returns (uint256) {
        if (globalAllocatedAmount == 0) {
            return 0;
        }

        uint256 globalRatio =
            globalCompostedAmount.mul(_ratioMultiplier).div(globalAllocatedAmount);
        return globalRatio;
    }

    function getGlobalAverageRatio() public view returns (uint256) {
        if (globalAllocatedAmount == 0) {
            return 0;
        }

        uint256 globalAverageRatio =
            globalCompostedAmount
                .mul(_ratioMultiplier)
                .div(globalAllocatedAmount)
                .div(globalTotalFarms);
        return globalAverageRatio;
    }

    function getAddressDetails(address targetAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 cropBalance = balanceOf(targetAddress);
        uint256 harvestAmount = getHarvestAmount(targetAddress, block.number);

        uint256 addressMaturityMultiplier = getAddressMaturityMultiplier(targetAddress);
        uint256 addressCompostMultiplier = getAddressCompostMultiplier(targetAddress);

        return (
            block.number,
            cropBalance,
            harvestAmount,
            addressMaturityMultiplier,
            addressCompostMultiplier
        );
    }

    function getAddressTokenDetails(address targetAddress)
        public
        view
        returns (
            uint256,
            bool,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        bool isOperator =
            IERC777(_token).isOperatorFor(address(this), targetAddress);
        uint256 landBalance = IERC777(_token).balanceOf(targetAddress);
        uint256 myRatio = getAddressRatio(targetAddress);
        uint256 globalRatio = getGlobalRatio();
        uint256 globalAverageRatio = getGlobalAverageRatio();

        return (
            block.number,
            isOperator,
            landBalance,
            myRatio,
            globalRatio,
            globalAverageRatio
        );
    }

    function getGlobalDetails()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 globalRatio = getGlobalRatio();
        uint256 globalAverageRatio = getGlobalAverageRatio();

        return (
            globalTotalFarms,
            globalRatio,
            globalAverageRatio,
            globalAllocatedAmount,
            globalCompostedAmount
        );
    }

    function getConstantDetails()
        public
        pure
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            maxCompostBoost,
            maxMaturityBoost,
            maxGrowthCycle,
            maturityBoostExtension
        );
    }
}