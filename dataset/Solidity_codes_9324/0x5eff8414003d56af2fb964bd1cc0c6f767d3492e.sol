
pragma solidity ^0.6.6;


interface AggregatorInterface {

  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}


interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}


interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{

}

contract Owned {


  address public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransferred(
    address indexed from,
    address indexed to
  );

  constructor() public {
    owner = msg.sender;
  }

  function transferOwnership(address _to)
    external
    onlyOwner()
  {

    pendingOwner = _to;

    emit OwnershipTransferRequested(owner, _to);
  }

  function acceptOwnership()
    external
  {

    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "Only callable by owner");
    _;
  }

}


contract AggregatorProxy is AggregatorV2V3Interface, Owned {


  struct Phase {
    uint16 id;
    AggregatorV2V3Interface aggregator;
  }
  Phase private currentPhase;
  AggregatorV2V3Interface public proposedAggregator;
  mapping(uint16 => AggregatorV2V3Interface) public phaseAggregators;

  uint256 constant private PHASE_OFFSET = 64;
  uint256 constant private PHASE_SIZE = 16;
  uint256 constant private MAX_ID = 2**(PHASE_OFFSET+PHASE_SIZE) - 1;

  constructor(address _aggregator) public Owned() {
    setAggregator(_aggregator);
  }

  function latestAnswer()
    public
    view
    virtual
    override
    returns (int256 answer)
  {

    return currentPhase.aggregator.latestAnswer();
  }

  function latestTimestamp()
    public
    view
    virtual
    override
    returns (uint256 updatedAt)
  {

    return currentPhase.aggregator.latestTimestamp();
  }

  function getAnswer(uint256 _roundId)
    public
    view
    virtual
    override
    returns (int256 answer)
  {

    if (_roundId > MAX_ID) return 0;

    (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(_roundId);
    AggregatorV2V3Interface aggregator = phaseAggregators[phaseId];
    if (address(aggregator) == address(0)) return 0;

    return aggregator.getAnswer(aggregatorRoundId);
  }

  function getTimestamp(uint256 _roundId)
    public
    view
    virtual
    override
    returns (uint256 updatedAt)
  {

    if (_roundId > MAX_ID) return 0;

    (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(_roundId);
    AggregatorV2V3Interface aggregator = phaseAggregators[phaseId];
    if (address(aggregator) == address(0)) return 0;

    return aggregator.getTimestamp(aggregatorRoundId);
  }

  function latestRound()
    public
    view
    virtual
    override
    returns (uint256 roundId)
  {

    Phase memory phase = currentPhase; // cache storage reads
    return addPhase(phase.id, uint64(phase.aggregator.latestRound()));
  }

  function getRoundData(uint80 _roundId)
    public
    view
    virtual
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(_roundId);

    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 ansIn
    ) = phaseAggregators[phaseId].getRoundData(aggregatorRoundId);

    return addPhaseIds(roundId, answer, startedAt, updatedAt, ansIn, phaseId);
  }

  function latestRoundData()
    public
    view
    virtual
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    Phase memory current = currentPhase; // cache storage reads

    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 ansIn
    ) = current.aggregator.latestRoundData();

    return addPhaseIds(roundId, answer, startedAt, updatedAt, ansIn, current.id);
  }

  function proposedGetRoundData(uint80 _roundId)
    public
    view
    virtual
    hasProposal()
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return proposedAggregator.getRoundData(_roundId);
  }

  function proposedLatestRoundData()
    public
    view
    virtual
    hasProposal()
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return proposedAggregator.latestRoundData();
  }

  function aggregator()
    external
    view
    returns (address)
  {

    return address(currentPhase.aggregator);
  }

  function phaseId()
    external
    view
    returns (uint16)
  {

    return currentPhase.id;
  }

  function decimals()
    external
    view
    override
    returns (uint8)
  {

    return currentPhase.aggregator.decimals();
  }

  function version()
    external
    view
    override
    returns (uint256)
  {

    return currentPhase.aggregator.version();
  }

  function description()
    external
    view
    override
    returns (string memory)
  {

    return currentPhase.aggregator.description();
  }

  function proposeAggregator(address _aggregator)
    external
    onlyOwner()
  {

    proposedAggregator = AggregatorV2V3Interface(_aggregator);
  }

  function confirmAggregator(address _aggregator)
    external
    onlyOwner()
  {

    require(_aggregator == address(proposedAggregator), "Invalid proposed aggregator");
    delete proposedAggregator;
    setAggregator(_aggregator);
  }



  function setAggregator(address _aggregator)
    internal
  {

    uint16 id = currentPhase.id + 1;
    currentPhase = Phase(id, AggregatorV2V3Interface(_aggregator));
    phaseAggregators[id] = AggregatorV2V3Interface(_aggregator);
  }

  function addPhase(
    uint16 _phase,
    uint64 _originalId
  )
    internal
    view
    returns (uint80)
  {

    return uint80(uint256(_phase) << PHASE_OFFSET | _originalId);
  }

  function parseIds(
    uint256 _roundId
  )
    internal
    view
    returns (uint16, uint64)
  {

    uint16 phaseId = uint16(_roundId >> PHASE_OFFSET);
    uint64 aggregatorRoundId = uint64(_roundId);

    return (phaseId, aggregatorRoundId);
  }

  function addPhaseIds(
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound,
      uint16 phaseId
  )
    internal
    view
    returns (uint80, int256, uint256, uint256, uint80)
  {

    return (
      addPhase(phaseId, uint64(roundId)),
      answer,
      startedAt,
      updatedAt,
      addPhase(phaseId, uint64(answeredInRound))
    );
  }


  modifier hasProposal() {

    require(address(proposedAggregator) != address(0), "No proposed aggregator present");
    _;
  }

}


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
interface IEBOP20 is IERC20 {


    function bet(int256 latestPrice, uint256 amount) external virtual returns (uint256, uint256);

    function unlockAndPayExpirer(uint256 lockValue , uint256 purchaseValue, address expirer) external virtual returns (bool);

    function payout(uint256 lockValue,uint256 purchaseValue, address sender, address buyer) external virtual returns (bool);


}

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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
contract BIOPToken is ERC20 {
    using SafeMath for uint256;
    address public binaryOptions = 0x0000000000000000000000000000000000000000;
    address public gov;
    address public owner;
    uint256 public earlyClaimsAvailable = 450000000000000000000000000000;
    uint256 public totalClaimsAvailable = 750000000000000000000000000000;
    bool public earlyClaims = true;
    bool public binaryOptionsSet = false;

    constructor(string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
      owner = msg.sender;
    }
    
    modifier onlyBinaryOptions() {
        require(binaryOptions == msg.sender, "Ownable: caller is not the Binary Options Contract");
        _;
    }
    modifier onlyOwner() {
        require(binaryOptions == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function updateEarlyClaim(uint256 amount) external onlyBinaryOptions {
        require(totalClaimsAvailable.sub(amount) >= 0, "insufficent claims available");
        if (earlyClaims) {
            earlyClaimsAvailable = earlyClaimsAvailable.sub(amount);
            _mint(tx.origin, amount);
            if (earlyClaimsAvailable <= 0) {
                earlyClaims = false;
            }
        } else {
            updateClaim(amount.div(4));
        }
    }

     function updateClaim( uint256 amount) internal {
        require(totalClaimsAvailable.sub(amount) >= 0, "insufficent claims available");
        totalClaimsAvailable.sub(amount);
        _mint(tx.origin, amount);
    }

    function setupBinaryOptions(address payable options_) external {
        require(binaryOptionsSet != true, "binary options is already set");
        binaryOptions = options_;
    }

    function setupGovernance(address payable gov_) external onlyOwner {
        _mint(owner, 100000000000000000000000000000);
        _mint(gov_, 450000000000000000000000000000);
        owner = 0x0000000000000000000000000000000000000000;
    }
}


contract Power {
    string public version = "0.3";

    uint256 private constant ONE = 1;
    uint32 private constant MAX_WEIGHT = 1000000;
    uint8 private constant MIN_PRECISION = 32;
    uint8 private constant MAX_PRECISION = 127;

    uint256 private constant FIXED_1 = 0x080000000000000000000000000000000;
    uint256 private constant FIXED_2 = 0x100000000000000000000000000000000;
    uint256 private constant MAX_NUM = 0x200000000000000000000000000000000;

    uint256 private constant LN2_NUMERATOR   = 0x3f80fe03f80fe03f80fe03f80fe03f8;
    uint256 private constant LN2_DENOMINATOR = 0x5b9de1d10bf4103d647b0955897ba80;

    uint256 private constant OPT_LOG_MAX_VAL = 0x15bf0a8b1457695355fb8ac404e7a79e3;
    uint256 private constant OPT_EXP_MAX_VAL = 0x800000000000000000000000000000000;

    uint256[128] private maxExpArray;

    constructor() public {
        maxExpArray[32] = 0x1c35fedd14ffffffffffffffffffffffff;
        maxExpArray[33] = 0x1b0ce43b323fffffffffffffffffffffff;
        maxExpArray[34] = 0x19f0028ec1ffffffffffffffffffffffff;
        maxExpArray[35] = 0x18ded91f0e7fffffffffffffffffffffff;
        maxExpArray[36] = 0x17d8ec7f0417ffffffffffffffffffffff;
        maxExpArray[37] = 0x16ddc6556cdbffffffffffffffffffffff;
        maxExpArray[38] = 0x15ecf52776a1ffffffffffffffffffffff;
        maxExpArray[39] = 0x15060c256cb2ffffffffffffffffffffff;
        maxExpArray[40] = 0x1428a2f98d72ffffffffffffffffffffff;
        maxExpArray[41] = 0x13545598e5c23fffffffffffffffffffff;
        maxExpArray[42] = 0x1288c4161ce1dfffffffffffffffffffff;
        maxExpArray[43] = 0x11c592761c666fffffffffffffffffffff;
        maxExpArray[44] = 0x110a688680a757ffffffffffffffffffff;
        maxExpArray[45] = 0x1056f1b5bedf77ffffffffffffffffffff;
        maxExpArray[46] = 0x0faadceceeff8bffffffffffffffffffff;
        maxExpArray[47] = 0x0f05dc6b27edadffffffffffffffffffff;
        maxExpArray[48] = 0x0e67a5a25da4107fffffffffffffffffff;
        maxExpArray[49] = 0x0dcff115b14eedffffffffffffffffffff;
        maxExpArray[50] = 0x0d3e7a392431239fffffffffffffffffff;
        maxExpArray[51] = 0x0cb2ff529eb71e4fffffffffffffffffff;
        maxExpArray[52] = 0x0c2d415c3db974afffffffffffffffffff;
        maxExpArray[53] = 0x0bad03e7d883f69bffffffffffffffffff;
        maxExpArray[54] = 0x0b320d03b2c343d5ffffffffffffffffff;
        maxExpArray[55] = 0x0abc25204e02828dffffffffffffffffff;
        maxExpArray[56] = 0x0a4b16f74ee4bb207fffffffffffffffff;
        maxExpArray[57] = 0x09deaf736ac1f569ffffffffffffffffff;
        maxExpArray[58] = 0x0976bd9952c7aa957fffffffffffffffff;
        maxExpArray[59] = 0x09131271922eaa606fffffffffffffffff;
        maxExpArray[60] = 0x08b380f3558668c46fffffffffffffffff;
        maxExpArray[61] = 0x0857ddf0117efa215bffffffffffffffff;
        maxExpArray[62] = 0x07ffffffffffffffffffffffffffffffff;
        maxExpArray[63] = 0x07abbf6f6abb9d087fffffffffffffffff;
        maxExpArray[64] = 0x075af62cbac95f7dfa7fffffffffffffff;
        maxExpArray[65] = 0x070d7fb7452e187ac13fffffffffffffff;
        maxExpArray[66] = 0x06c3390ecc8af379295fffffffffffffff;
        maxExpArray[67] = 0x067c00a3b07ffc01fd6fffffffffffffff;
        maxExpArray[68] = 0x0637b647c39cbb9d3d27ffffffffffffff;
        maxExpArray[69] = 0x05f63b1fc104dbd39587ffffffffffffff;
        maxExpArray[70] = 0x05b771955b36e12f7235ffffffffffffff;
        maxExpArray[71] = 0x057b3d49dda84556d6f6ffffffffffffff;
        maxExpArray[72] = 0x054183095b2c8ececf30ffffffffffffff;
        maxExpArray[73] = 0x050a28be635ca2b888f77fffffffffffff;
        maxExpArray[74] = 0x04d5156639708c9db33c3fffffffffffff;
        maxExpArray[75] = 0x04a23105873875bd52dfdfffffffffffff;
        maxExpArray[76] = 0x0471649d87199aa990756fffffffffffff;
        maxExpArray[77] = 0x04429a21a029d4c1457cfbffffffffffff;
        maxExpArray[78] = 0x0415bc6d6fb7dd71af2cb3ffffffffffff;
        maxExpArray[79] = 0x03eab73b3bbfe282243ce1ffffffffffff;
        maxExpArray[80] = 0x03c1771ac9fb6b4c18e229ffffffffffff;
        maxExpArray[81] = 0x0399e96897690418f785257fffffffffff;
        maxExpArray[82] = 0x0373fc456c53bb779bf0ea9fffffffffff;
        maxExpArray[83] = 0x034f9e8e490c48e67e6ab8bfffffffffff;
        maxExpArray[84] = 0x032cbfd4a7adc790560b3337ffffffffff;
        maxExpArray[85] = 0x030b50570f6e5d2acca94613ffffffffff;
        maxExpArray[86] = 0x02eb40f9f620fda6b56c2861ffffffffff;
        maxExpArray[87] = 0x02cc8340ecb0d0f520a6af58ffffffffff;
        maxExpArray[88] = 0x02af09481380a0a35cf1ba02ffffffffff;
        maxExpArray[89] = 0x0292c5bdd3b92ec810287b1b3fffffffff;
        maxExpArray[90] = 0x0277abdcdab07d5a77ac6d6b9fffffffff;
        maxExpArray[91] = 0x025daf6654b1eaa55fd64df5efffffffff;
        maxExpArray[92] = 0x0244c49c648baa98192dce88b7ffffffff;
        maxExpArray[93] = 0x022ce03cd5619a311b2471268bffffffff;
        maxExpArray[94] = 0x0215f77c045fbe885654a44a0fffffffff;
        maxExpArray[95] = 0x01ffffffffffffffffffffffffffffffff;
        maxExpArray[96] = 0x01eaefdbdaaee7421fc4d3ede5ffffffff;
        maxExpArray[97] = 0x01d6bd8b2eb257df7e8ca57b09bfffffff;
        maxExpArray[98] = 0x01c35fedd14b861eb0443f7f133fffffff;
        maxExpArray[99] = 0x01b0ce43b322bcde4a56e8ada5afffffff;
        maxExpArray[100] = 0x019f0028ec1fff007f5a195a39dfffffff;
        maxExpArray[101] = 0x018ded91f0e72ee74f49b15ba527ffffff;
        maxExpArray[102] = 0x017d8ec7f04136f4e5615fd41a63ffffff;
        maxExpArray[103] = 0x016ddc6556cdb84bdc8d12d22e6fffffff;
        maxExpArray[104] = 0x015ecf52776a1155b5bd8395814f7fffff;
        maxExpArray[105] = 0x015060c256cb23b3b3cc3754cf40ffffff;
        maxExpArray[106] = 0x01428a2f98d728ae223ddab715be3fffff;
        maxExpArray[107] = 0x013545598e5c23276ccf0ede68034fffff;
        maxExpArray[108] = 0x01288c4161ce1d6f54b7f61081194fffff;
        maxExpArray[109] = 0x011c592761c666aa641d5a01a40f17ffff;
        maxExpArray[110] = 0x0110a688680a7530515f3e6e6cfdcdffff;
        maxExpArray[111] = 0x01056f1b5bedf75c6bcb2ce8aed428ffff;
        maxExpArray[112] = 0x00faadceceeff8a0890f3875f008277fff;
        maxExpArray[113] = 0x00f05dc6b27edad306388a600f6ba0bfff;
        maxExpArray[114] = 0x00e67a5a25da41063de1495d5b18cdbfff;
        maxExpArray[115] = 0x00dcff115b14eedde6fc3aa5353f2e4fff;
        maxExpArray[116] = 0x00d3e7a3924312399f9aae2e0f868f8fff;
        maxExpArray[117] = 0x00cb2ff529eb71e41582cccd5a1ee26fff;
        maxExpArray[118] = 0x00c2d415c3db974ab32a51840c0b67edff;
        maxExpArray[119] = 0x00bad03e7d883f69ad5b0a186184e06bff;
        maxExpArray[120] = 0x00b320d03b2c343d4829abd6075f0cc5ff;
        maxExpArray[121] = 0x00abc25204e02828d73c6e80bcdb1a95bf;
        maxExpArray[122] = 0x00a4b16f74ee4bb2040a1ec6c15fbbf2df;
        maxExpArray[123] = 0x009deaf736ac1f569deb1b5ae3f36c130f;
        maxExpArray[124] = 0x00976bd9952c7aa957f5937d790ef65037;
        maxExpArray[125] = 0x009131271922eaa6064b73a22d0bd4f2bf;
        maxExpArray[126] = 0x008b380f3558668c46c91c49a2f8e967b9;
        maxExpArray[127] = 0x00857ddf0117efa215952912839f6473e6;
    }

    function power(
        uint256 _baseN,
        uint256 _baseD,
        uint32 _expN,
        uint32 _expD
    ) internal view returns (uint256, uint8)
    {
        require(_baseN < MAX_NUM, "baseN exceeds max value.");
        require(_baseN >= _baseD, "Bases < 1 are not supported.");

        uint256 baseLog;
        uint256 base = _baseN * FIXED_1 / _baseD;
        if (base < OPT_LOG_MAX_VAL) {
            baseLog = optimalLog(base);
        } else {
            baseLog = generalLog(base);
        }

        uint256 baseLogTimesExp = baseLog * _expN / _expD;
        if (baseLogTimesExp < OPT_EXP_MAX_VAL) {
            return (optimalExp(baseLogTimesExp), MAX_PRECISION);
        } else {
            uint8 precision = findPositionInMaxExpArray(baseLogTimesExp);
            return (generalExp(baseLogTimesExp >> (MAX_PRECISION - precision), precision), precision);
        }
    }

    function generalLog(uint256 _x) internal pure returns (uint256) {
        uint256 res = 0;
        uint256 x = _x;

        if (x >= FIXED_2) {
            uint8 count = floorLog2(x / FIXED_1);
            x >>= count; // now x < 2
            res = count * FIXED_1;
        }

        if (x > FIXED_1) {
            for (uint8 i = MAX_PRECISION; i > 0; --i) {
                x = (x * x) / FIXED_1; // now 1 < x < 4
                if (x >= FIXED_2) {
                    x >>= 1; // now 1 < x < 2
                    res += ONE << (i - 1);
                }
            }
        }

        return res * LN2_NUMERATOR / LN2_DENOMINATOR;
    }

    function floorLog2(uint256 _n) internal pure returns (uint8) {
        uint8 res = 0;
        uint256 n = _n;

        if (n < 256) {
            while (n > 1) {
                n >>= 1;
                res += 1;
            }
        } else {
            for (uint8 s = 128; s > 0; s >>= 1) {
                if (n >= (ONE << s)) {
                    n >>= s;
                    res |= s;
                }
            }
        }

        return res;
    }

    function findPositionInMaxExpArray(uint256 _x)
    internal view returns (uint8)
    {
        uint8 lo = MIN_PRECISION;
        uint8 hi = MAX_PRECISION;

        while (lo + 1 < hi) {
            uint8 mid = (lo + hi) / 2;
            if (maxExpArray[mid] >= _x)
                lo = mid;
            else
                hi = mid;
        }

        if (maxExpArray[hi] >= _x)
            return hi;
        if (maxExpArray[lo] >= _x)
            return lo;

        assert(false);
        return 0;
    }

    function generalExp(uint256 _x, uint8 _precision) internal pure returns (uint256) {
        uint256 xi = _x;
        uint256 res = 0;

        xi = (xi * _x) >> _precision; res += xi * 0x3442c4e6074a82f1797f72ac0000000; // add x^02 * (33! / 02!)
        xi = (xi * _x) >> _precision; res += xi * 0x116b96f757c380fb287fd0e40000000; // add x^03 * (33! / 03!)
        xi = (xi * _x) >> _precision; res += xi * 0x045ae5bdd5f0e03eca1ff4390000000; // add x^04 * (33! / 04!)
        xi = (xi * _x) >> _precision; res += xi * 0x00defabf91302cd95b9ffda50000000; // add x^05 * (33! / 05!)
        xi = (xi * _x) >> _precision; res += xi * 0x002529ca9832b22439efff9b8000000; // add x^06 * (33! / 06!)
        xi = (xi * _x) >> _precision; res += xi * 0x00054f1cf12bd04e516b6da88000000; // add x^07 * (33! / 07!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000a9e39e257a09ca2d6db51000000; // add x^08 * (33! / 08!)
        xi = (xi * _x) >> _precision; res += xi * 0x000012e066e7b839fa050c309000000; // add x^09 * (33! / 09!)
        xi = (xi * _x) >> _precision; res += xi * 0x000001e33d7d926c329a1ad1a800000; // add x^10 * (33! / 10!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000002bee513bdb4a6b19b5f800000; // add x^11 * (33! / 11!)
        xi = (xi * _x) >> _precision; res += xi * 0x00000003a9316fa79b88eccf2a00000; // add x^12 * (33! / 12!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000048177ebe1fa812375200000; // add x^13 * (33! / 13!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000005263fe90242dcbacf00000; // add x^14 * (33! / 14!)
        xi = (xi * _x) >> _precision; res += xi * 0x000000000057e22099c030d94100000; // add x^15 * (33! / 15!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000057e22099c030d9410000; // add x^16 * (33! / 16!)
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000052b6b54569976310000; // add x^17 * (33! / 17!)
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000004985f67696bf748000; // add x^18 * (33! / 18!)
        xi = (xi * _x) >> _precision; res += xi * 0x000000000000003dea12ea99e498000; // add x^19 * (33! / 19!)
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000031880f2214b6e000; // add x^20 * (33! / 20!)
        xi = (xi * _x) >> _precision; res += xi * 0x000000000000000025bcff56eb36000; // add x^21 * (33! / 21!)
        xi = (xi * _x) >> _precision; res += xi * 0x000000000000000001b722e10ab1000; // add x^22 * (33! / 22!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000001317c70077000; // add x^23 * (33! / 23!)
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000000000cba84aafa00; // add x^24 * (33! / 24!)
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000000000082573a0a00; // add x^25 * (33! / 25!)
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000000000005035ad900; // add x^26 * (33! / 26!)
        xi = (xi * _x) >> _precision; res += xi * 0x000000000000000000000002f881b00; // add x^27 * (33! / 27!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000001b29340; // add x^28 * (33! / 28!)
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000000000000000efc40; // add x^29 * (33! / 29!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000000007fe0; // add x^30 * (33! / 30!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000000000420; // add x^31 * (33! / 31!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000000000021; // add x^32 * (33! / 32!)
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000000000001; // add x^33 * (33! / 33!)

        return res / 0x688589cc0e9505e2f2fee5580000000 + _x + (ONE << _precision); // divide by 33! and then add x^1 / 1! + x^0 / 0!
    }

    function optimalLog(uint256 x) internal pure returns (uint256) {
        uint256 res = 0;

        uint256 y;
        uint256 z;
        uint256 w;

        if (x >= 0xd3094c70f034de4b96ff7d5b6f99fcd8) {res += 0x40000000000000000000000000000000; x = x * FIXED_1 / 0xd3094c70f034de4b96ff7d5b6f99fcd8;}
        if (x >= 0xa45af1e1f40c333b3de1db4dd55f29a7) {res += 0x20000000000000000000000000000000; x = x * FIXED_1 / 0xa45af1e1f40c333b3de1db4dd55f29a7;}
        if (x >= 0x910b022db7ae67ce76b441c27035c6a1) {res += 0x10000000000000000000000000000000; x = x * FIXED_1 / 0x910b022db7ae67ce76b441c27035c6a1;}
        if (x >= 0x88415abbe9a76bead8d00cf112e4d4a8) {res += 0x08000000000000000000000000000000; x = x * FIXED_1 / 0x88415abbe9a76bead8d00cf112e4d4a8;}
        if (x >= 0x84102b00893f64c705e841d5d4064bd3) {res += 0x04000000000000000000000000000000; x = x * FIXED_1 / 0x84102b00893f64c705e841d5d4064bd3;}
        if (x >= 0x8204055aaef1c8bd5c3259f4822735a2) {res += 0x02000000000000000000000000000000; x = x * FIXED_1 / 0x8204055aaef1c8bd5c3259f4822735a2;}
        if (x >= 0x810100ab00222d861931c15e39b44e99) {res += 0x01000000000000000000000000000000; x = x * FIXED_1 / 0x810100ab00222d861931c15e39b44e99;}
        if (x >= 0x808040155aabbbe9451521693554f733) {res += 0x00800000000000000000000000000000; x = x * FIXED_1 / 0x808040155aabbbe9451521693554f733;}

        z = y = x - FIXED_1;
        w = y * y / FIXED_1;
        res += z * (0x100000000000000000000000000000000 - y) / 0x100000000000000000000000000000000; z = z * w / FIXED_1;
        res += z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y) / 0x200000000000000000000000000000000; z = z * w / FIXED_1;
        res += z * (0x099999999999999999999999999999999 - y) / 0x300000000000000000000000000000000; z = z * w / FIXED_1;
        res += z * (0x092492492492492492492492492492492 - y) / 0x400000000000000000000000000000000; z = z * w / FIXED_1;
        res += z * (0x08e38e38e38e38e38e38e38e38e38e38e - y) / 0x500000000000000000000000000000000; z = z * w / FIXED_1;
        res += z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b - y) / 0x600000000000000000000000000000000; z = z * w / FIXED_1;
        res += z * (0x089d89d89d89d89d89d89d89d89d89d89 - y) / 0x700000000000000000000000000000000; z = z * w / FIXED_1;
        res += z * (0x088888888888888888888888888888888 - y) / 0x800000000000000000000000000000000;

        return res;
    }

    function optimalExp(uint256 x) internal pure returns (uint256) {
        uint256 res = 0;

        uint256 y;
        uint256 z;

        z = y = x % 0x10000000000000000000000000000000;
        z = z * y / FIXED_1; res += z * 0x10e1b3be415a0000; // add y^02 * (20! / 02!)
        z = z * y / FIXED_1; res += z * 0x05a0913f6b1e0000; // add y^03 * (20! / 03!)
        z = z * y / FIXED_1; res += z * 0x0168244fdac78000; // add y^04 * (20! / 04!)
        z = z * y / FIXED_1; res += z * 0x004807432bc18000; // add y^05 * (20! / 05!)
        z = z * y / FIXED_1; res += z * 0x000c0135dca04000; // add y^06 * (20! / 06!)
        z = z * y / FIXED_1; res += z * 0x0001b707b1cdc000; // add y^07 * (20! / 07!)
        z = z * y / FIXED_1; res += z * 0x000036e0f639b800; // add y^08 * (20! / 08!)
        z = z * y / FIXED_1; res += z * 0x00000618fee9f800; // add y^09 * (20! / 09!)
        z = z * y / FIXED_1; res += z * 0x0000009c197dcc00; // add y^10 * (20! / 10!)
        z = z * y / FIXED_1; res += z * 0x0000000e30dce400; // add y^11 * (20! / 11!)
        z = z * y / FIXED_1; res += z * 0x000000012ebd1300; // add y^12 * (20! / 12!)
        z = z * y / FIXED_1; res += z * 0x0000000017499f00; // add y^13 * (20! / 13!)
        z = z * y / FIXED_1; res += z * 0x0000000001a9d480; // add y^14 * (20! / 14!)
        z = z * y / FIXED_1; res += z * 0x00000000001c6380; // add y^15 * (20! / 15!)
        z = z * y / FIXED_1; res += z * 0x000000000001c638; // add y^16 * (20! / 16!)
        z = z * y / FIXED_1; res += z * 0x0000000000001ab8; // add y^17 * (20! / 17!)
        z = z * y / FIXED_1; res += z * 0x000000000000017c; // add y^18 * (20! / 18!)
        z = z * y / FIXED_1; res += z * 0x0000000000000014; // add y^19 * (20! / 19!)
        z = z * y / FIXED_1; res += z * 0x0000000000000001; // add y^20 * (20! / 20!)
        res = res / 0x21c3677c82b40000 + y + FIXED_1; // divide by 20! and then add y^1 / 1! + y^0 / 0!

        if ((x & 0x010000000000000000000000000000000) != 0) res = res * 0x1c3d6a24ed82218787d624d3e5eba95f9 / 0x18ebef9eac820ae8682b9793ac6d1e776;
        if ((x & 0x020000000000000000000000000000000) != 0) res = res * 0x18ebef9eac820ae8682b9793ac6d1e778 / 0x1368b2fc6f9609fe7aceb46aa619baed4;
        if ((x & 0x040000000000000000000000000000000) != 0) res = res * 0x1368b2fc6f9609fe7aceb46aa619baed5 / 0x0bc5ab1b16779be3575bd8f0520a9f21f;
        if ((x & 0x080000000000000000000000000000000) != 0) res = res * 0x0bc5ab1b16779be3575bd8f0520a9f21e / 0x0454aaa8efe072e7f6ddbab84b40a55c9;
        if ((x & 0x100000000000000000000000000000000) != 0) res = res * 0x0454aaa8efe072e7f6ddbab84b40a55c5 / 0x00960aadc109e7a3bf4578099615711ea;
        if ((x & 0x200000000000000000000000000000000) != 0) res = res * 0x00960aadc109e7a3bf4578099615711d7 / 0x0002bf84208204f5977f9a8cf01fdce3d;
        if ((x & 0x400000000000000000000000000000000) != 0) res = res * 0x0002bf84208204f5977f9a8cf01fdc307 / 0x0000003c6ab775dd0b95b4cbee7e65d11;

        return res;
    }
}


contract BancorFormula is Power {
    using SafeMath for uint256;
    uint32 private constant MAX_RESERVE_RATIO = 1000000;

    function calculatePurchaseReturn(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _depositAmount) public view returns (uint256)
    {
        require(_supply > 0 && _reserveBalance > 0 && _reserveRatio > 0 && _reserveRatio <= MAX_RESERVE_RATIO, "Invalid inputs.");
        if (_depositAmount == 0) {
            return 0;
        }
        if (_reserveRatio == MAX_RESERVE_RATIO) {
            return _supply.mul(_depositAmount).div(_reserveBalance);
        }
        uint256 result;
        uint8 precision;
        uint256 baseN = _depositAmount.add(_reserveBalance);
        (result, precision) = power(
            baseN, _reserveBalance, _reserveRatio, MAX_RESERVE_RATIO
        );
        uint256 newTokenSupply = _supply.mul(result) >> precision;
        return newTokenSupply.sub(_supply);
    }

    function calculateSaleReturn(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _sellAmount) public view returns (uint256)
    {
        require(_supply > 0 && _reserveBalance > 0 && _reserveRatio > 0 && _reserveRatio <= MAX_RESERVE_RATIO && _sellAmount <= _supply, "Invalid inputs.");
        if (_sellAmount == 0) {
            return 0;
        }
        if (_sellAmount == _supply) {
            return _reserveBalance;
        }
        if (_reserveRatio == MAX_RESERVE_RATIO) {
            return _reserveBalance.mul(_sellAmount).div(_supply);
        }
        uint256 result;
        uint8 precision;
        uint256 baseD = _supply.sub(_sellAmount);
        (result, precision) = power(
            _supply, baseD, MAX_RESERVE_RATIO, _reserveRatio
        );
        uint256 oldBalance = _reserveBalance.mul(result);
        uint256 newBalance = _reserveBalance << precision;
        return oldBalance.sub(newBalance).div(result);
    }
}


interface IBondingCurve {
    function getContinuousMintReward(uint _reserveTokenAmount) external view returns (uint);

    function getContinuousBurnRefund(uint _continuousTokenAmount) external view returns (uint);
}


abstract contract BancorBondingCurve is IBondingCurve, BancorFormula {
    uint32 public reserveRatio;

    constructor(uint32 _reserveRatio) public {
        reserveRatio = _reserveRatio;
    }

    function getContinuousMintReward(uint _reserveTokenAmount) public override view returns (uint) {
        return calculatePurchaseReturn(continuousSupply(), reserveBalance(), reserveRatio, _reserveTokenAmount);
    }

    function getContinuousBurnRefund(uint _continuousTokenAmount) public override view returns (uint) {
        return calculateSaleReturn(continuousSupply(), reserveBalance(), reserveRatio, _continuousTokenAmount);
    }

    function continuousSupply() public virtual view returns (uint);

    function reserveBalance() public virtual view returns (uint);
}

contract BIOPTokenV3 is BancorBondingCurve, ERC20 {
    using SafeMath for uint256;
    address public bO = 0x0000000000000000000000000000000000000000;//binary options
    address payable gov = 0x0000000000000000000000000000000000000000;
    address payable owner;
    address public v2;
    uint256 lEnd;//launch end
    uint256 public tCA = 750000000000000000000000000000;//total claims available
    uint256 public tbca =                 400000000000000000000000000000;//total bonding curve available
                             
    bool public binaryOptionsSet = false;

    uint256 public soldAmount = 0;
    uint256 public buyFee = 2;//10th of percent
    uint256 public sellFee = 0;//10th of percent

    constructor(string memory name_, string memory symbol_, address v2_,  uint32 _reserveRatio) public ERC20(name_, symbol_) BancorBondingCurve(_reserveRatio) {
      owner = msg.sender;
      v2 = v2_;
      lEnd = block.timestamp + 3 days;
      _mint(msg.sender, 100000);
      soldAmount = 100000;
    }


    
    modifier onlyBinaryOptions() {
        require(bO == msg.sender, "Ownable: caller is not the Binary Options Contract");
        _;
    }
    modifier onlyGov() {
        if (gov == 0x0000000000000000000000000000000000000000) {
            require(owner == msg.sender, "Ownable: caller is not the owner");
        } else {
            require(gov == msg.sender, "Ownable: caller is not the owner");
        }
        _;
    }

    function transferGovernance(address payable g_) external onlyGov {
        require(gov == 0x0000000000000000000000000000000000000000);
        require(g_ != 0x0000000000000000000000000000000000000000);
        gov = g_;
    }

    function updateBuyFee(uint256 newFee_) external onlyGov {
        require(newFee_ > 0 && newFee_ < 40, "invalid fee");
        buyFee = newFee_;
    }

    function updateSellFee(uint256 newFee_) external onlyGov {
        require(newFee_ > 0 && newFee_ < 40, "invalid fee");
        sellFee = newFee_;
    } 

    function updateEarlyClaim(uint256 amount) external onlyBinaryOptions {
        require(tCA.sub(amount) >= 0, "insufficent claims available");
        if (lEnd < block.timestamp) {
            tCA = tCA.sub(amount);
            _mint(tx.origin, amount.mul(4));
        } else {
            tCA.sub(amount);
            _mint(tx.origin, amount);
        }
    }
    function setupBinaryOptions(address payable options_) external {
        require(binaryOptionsSet != true, "binary options is already set");
        bO = options_;
        binaryOptionsSet = true;
    }

    function swapv2v3() external {
        BIOPToken b2 = BIOPToken(v2);
        uint256 balance = b2.balanceOf(msg.sender);
        require(balance >= 0, "insufficent biopv2 balance");
        require(b2.transferFrom(msg.sender, address(this), balance), "staking failed");
        _mint(msg.sender, balance);
    }


    



    function continuousSupply() public override view returns (uint) {
        return soldAmount;
    }

    function reserveBalance() public override view returns (uint) {
        return address(this).balance;
    }

     function buy() public payable {
        uint256 purchaseAmount = msg.value;
        
         if (buyFee > 0) {
            uint256 fee = purchaseAmount.div(buyFee).div(100);
            if (gov == 0x0000000000000000000000000000000000000000) {
                require(owner.send(fee), "buy fee transfer failed");
            } else {
                require(gov.send(fee), "buy fee transfer failed");
            }
            purchaseAmount = purchaseAmount.sub(fee);
        } 
        uint rewardAmount = getContinuousMintReward(purchaseAmount);
        require(soldAmount.add(rewardAmount) <= tbca, "maximum curve minted");
        
        _mint(msg.sender, rewardAmount);
        soldAmount = soldAmount.add(rewardAmount);
    }

    
     function sell(uint256 amount) public returns (uint256){
        require(balanceOf(msg.sender) >= amount, "insufficent BIOP balance");

        uint256 ethToSend = getContinuousBurnRefund(amount);
        if (sellFee > 0) {
            uint256 fee = ethToSend.div(buyFee).div(100);
            if (gov == 0x0000000000000000000000000000000000000000) {
                require(owner.send(fee), "buy fee transfer failed");
            } else {
                require(gov.send(fee), "buy fee transfer failed");
            }
            ethToSend = ethToSend.sub(fee);
        }
        soldAmount = soldAmount.sub(amount);
        _burn(msg.sender, amount);
        require(msg.sender.send(ethToSend), "transfer failed");
        return ethToSend;
        }
}
interface IRCD {
    function rate(uint256 amount, uint256 maxAvailable, uint256 oldPrice, uint256 newPrice) external view returns (uint256);

}

contract RateCalc is IRCD {
    using SafeMath for uint256;
    function rate(uint256 amount, uint256 maxAvailable, uint256 oldPrice, uint256 newPrice) external view override returns (uint256)  {
        require(amount <= maxAvailable, "greater then pool funds available");
        
        uint256 oneTenth = amount.div(10);
        uint256 halfMax = maxAvailable.div(2);
        if (amount > halfMax) {
            return amount.mul(2).add(oneTenth).add(oneTenth);
        } else {
            if(oneTenth > 0) {
                return amount.mul(2).sub(oneTenth);
            } else {
                uint256 oneThird = amount.div(4);
                require(oneThird > 0, "invalid bet amount");
                return amount.mul(2).sub(oneThird);
            }
        }
        
    }
}



contract BinaryOptions is ERC20 {
    using SafeMath for uint256;
    address payable devFund;
    address payable owner;
    address public biop;
    address public defaultRCAddress;//address of default rate calculator
    mapping(address=>uint256) public nW; //next withdraw (used for pool lock time)
    mapping(address=>address) public ePairs;//enabled pairs. price provider mapped to rate calc
    mapping(address=>int256) public pLP; //pair last price. the last recorded price for this pair
    mapping(address=>uint256) public lW;//last withdraw.used for rewards calc
    mapping(address=>uint256) private pClaims;//pending claims
    mapping(address=>uint256) public iAL;//interchange at last claim 
    mapping(address=>uint256) public lST;//last stake time

    mapping(address=>bool) public ePools;//enabled pools
    mapping(address=>uint256) public altLockedAmount;



    uint256 public minT;//min time
    uint256 public maxT;//max time
    address public defaultPair;
    uint256 public lockedAmount;
    uint256 public exerciserFee = 50;//in tenth percent
    uint256 public expirerFee = 50;//in tenth percent
    uint256 public devFundBetFee = 2;//tenth of percent
    uint256 public poolLockSeconds = 7 days;
    uint256 public contractCreated;
    bool public open = true;
    Option[] public options;
    
    uint256 public tI = 0;//total interchange
    uint256 public fGS =400000000000000;//first gov stake reward
    uint256 public reward =       200000000000000;
    bool public rewEn = true;//rewards enabled


    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    enum OptionType {Put, Call}
    struct Option {
        address payable holder;
        int256 sPrice;//strike
        uint256 pValue;//purchase 
        uint256 lValue;//purchaseAmount+possible reward for correct bet
        uint256 exp;//expiration
        OptionType dir;//direction
        address pP;//price provider
        address altPA;//alt pool address 
    }

     event Create(
        uint256 indexed id,
        address payable account,
        int256 sPrice,//strike
        uint256 lValue,//locked value
        OptionType dir,
        bool alt
    );
    event Payout(uint256 poolLost, address winner);
    event Exercise(uint256 indexed id);
    event Expire(uint256 indexed id);

      constructor(string memory name_, string memory symbol_, address pp_, address biop_, address rateCalc_) public ERC20(name_, symbol_){
        devFund = msg.sender;
        owner = msg.sender;
        biop = biop_;
        defaultRCAddress = rateCalc_;
        lockedAmount = 0;
        contractCreated = block.timestamp;
        ePairs[pp_] = defaultRCAddress; //default pair ETH/USD
        defaultPair = pp_;
        minT = 900;//15 minutes
        maxT = 60 minutes;
    }


    function getMaxAvailable() public view returns(uint256) {
        uint256 balance = address(this).balance;
        if (balance > lockedAmount) {
            return balance.sub(lockedAmount);
        } else {
            return 0;
        }
    }

    function getAltMaxAvailable(address erc20PoolAddress_) public view returns(uint256) {
        ERC20 alt = ERC20(erc20PoolAddress_);
        uint256 balance = alt.balanceOf(address(this));
        if (balance >  altLockedAmount[erc20PoolAddress_]) {
            return balance.sub( altLockedAmount[erc20PoolAddress_]);
        } else {
            return 0;
        }
    }

    function getOptionCount() public view returns(uint256) {
        return options.length;
    }

    function getStakingTimeBonus(address account) public view returns(uint256) {
        uint256 dif = block.timestamp.sub(lST[account]);
        uint256 bonus = dif.div(777600);//9 days
        if (dif < 777600) {
            return 1;
        }
        return bonus;
    }

    function getPoolBalanceBonus(address account) public view returns(uint256) {
        uint256 balance = balanceOf(account);
        if (balance > 0) {

            if (totalSupply() < 100) { //guard
                return 1;
            }
            

            if (balance >= totalSupply().div(2)) {//50th percentile
                return 20;
            }

            if (balance >= totalSupply().div(4)) {//25th percentile
                return 14;
            }

            if (balance >= totalSupply().div(5)) {//20th percentile
                return 10;
            }

            if (balance >= totalSupply().div(10)) {//10th percentile
                return 8;
            }

            if (balance >= totalSupply().div(20)) {//5th percentile
                return 6;
            }

            if (balance >= totalSupply().div(50)) {//2nd percentile
                return 4;
            }

            if (balance >= totalSupply().div(100)) {//1st percentile
                return 3;
            }
           
           return 2;
        } 
        return 1; 
    }

    function getOptionValueBonus(address account) public view returns(uint256) {
        uint256 dif = tI.sub(iAL[account]);
        uint256 bonus = dif.div(1000000000000000000);//1ETH
        if(bonus > 0){
            return bonus;
        }
        return 0;
    }

    function getBetSizeBonus(uint256 amount, uint256 base) public view returns(uint256) {
        uint256 betPercent = totalSupply().mul(100).div(amount);
        if(base.mul(betPercent).div(10) > 0){
            return base.mul(betPercent).div(10);
        }
        return base.div(1000);
    }

    function getCombinedStakingBonus(address account) public view returns(uint256) {
        return reward
                .mul(getStakingTimeBonus(account))
                .mul(getPoolBalanceBonus(account))
                .mul(getOptionValueBonus(account));
    }

    function getPendingClaims(address account) public view returns(uint256) {
        if (balanceOf(account) > 1) {
            return pClaims[account].add(
                getCombinedStakingBonus(account)
            );
        } else {
            return pClaims[account];
        }
    }

    function updateLPmetrics() internal {
        lST[msg.sender] = block.timestamp;
        iAL[msg.sender] = tI;
    }
    function claimRewards() external {
        
        BIOPTokenV3 b = BIOPTokenV3(biop);
        uint256 claims = getPendingClaims(msg.sender);
        if (balanceOf(msg.sender) > 1) {
            updateLPmetrics();
        }
        pClaims[msg.sender] = 0;
        b.updateEarlyClaim(claims);
    }

    

  

    function defaultPriceProvider() public view returns (address) {
        return defaultPair;
    }


    function addAltPool(address newPool_) external onlyOwner {
        ePools[newPool_] = true; 
    }

    function enableRewards(bool nx_) external onlyOwner {
        rewEn = nx_;
    }

    function removeAltPool(address oldPool_) external onlyOwner {
        ePools[oldPool_] = false; 
    }

    function addPP(address newPP_, address rateCalc_) external onlyOwner {
        ePairs[newPP_] = rateCalc_; 
    }

   

    function removePP(address oldPP_) external onlyOwner {
        ePairs[oldPP_] = 0x0000000000000000000000000000000000000000;
    }

    function setMaxT(uint256 newMax_) external onlyOwner {
        maxT = newMax_;
    }

    function setMinT(uint256 newMin_) external onlyOwner {
        minT = newMin_;
    }

    function thisAddress() public view returns (address){
        return address(this);
    }

    function updateExerciserFee(uint256 exerciserFee_) external onlyOwner {
        require(exerciserFee_ > 1 && exerciserFee_ < 500, "invalid fee");
        exerciserFee = exerciserFee_;
    }

    function updateExpirerFee(uint256 expirerFee_) external onlyOwner {
        require(expirerFee_ > 1 && expirerFee_ < 50, "invalid fee");
        expirerFee = expirerFee_;
    }

    function updateDevFundBetFee(uint256 devFundBetFee_) external onlyOwner {
        require(devFundBetFee_ >= 0 && devFundBetFee_ < 50, "invalid fee");
        devFundBetFee = devFundBetFee_;
    }

    function updatePoolLockSeconds(uint256 newLockSeconds_) external onlyOwner {
        require(newLockSeconds_ >= 0 && newLockSeconds_ < 14 days, "invalid fee");
        poolLockSeconds = newLockSeconds_;
    }

    function transferOwner(address payable newOwner_) external onlyOwner {
        owner = newOwner_;
    }

    function transferDevFund(address payable newDevFund) external onlyOwner {
        devFund = newDevFund;
    }


    function closeStaking() external onlyOwner {
        open = false;
    }

   
    

    function stake() external payable {
        require(open == true, "pool deposits has closed");
        require(msg.value >= 100, "stake to small");
        if (balanceOf(msg.sender) == 0) {
            lW[msg.sender] = block.timestamp;
            pClaims[msg.sender] = pClaims[msg.sender].add(fGS);
        }
        updateLPmetrics();
        nW[msg.sender] = block.timestamp + poolLockSeconds;//this one is seperate because it isn't updated on reward claim
        
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
       require (balanceOf(msg.sender) >= amount, "Insufficent Share Balance");
        lW[msg.sender] = block.timestamp;
        uint256 valueToRecieve = amount.mul(address(this).balance).div(totalSupply());
        _burn(msg.sender, amount);
        if (block.timestamp <= nW[msg.sender]) {
            uint256 penalty = valueToRecieve.div(100);
            require(devFund.send(penalty), "transfer failed");
            require(msg.sender.send(valueToRecieve.sub(penalty)), "transfer failed");
        } else {
            require(msg.sender.send(valueToRecieve), "transfer failed");
        }
    }

    function getRate(address pair,uint256 max, uint256 deposit, int256 currentPrice) public view returns (uint256) {
        RateCalc rc = RateCalc(ePairs[pair]);
        
        return rc.rate(deposit, max.sub(deposit), uint256(pLP[pair]), uint256(currentPrice));
    }

    function bet(OptionType type_, address pp_, uint256 time_, address altPA_,  uint256 altA_) external payable {
        require(
            type_ == OptionType.Call || type_ == OptionType.Put,
            "Wrong option type"
        );
        require(
            time_ >= minT && time_ <= maxT,
            "Invalid time"
        );
        require(ePairs[pp_] != 0x0000000000000000000000000000000000000000, "Invalid  price provider");
        
        AggregatorProxy priceProvider = AggregatorProxy(pp_);
        int256 latestPrice = priceProvider.latestAnswer();
        uint256 depositValue;
        uint256 lockTotal;
        uint256 optionID = options.length;

        if (altPA_ != address(this)) {
            
            require(ePools[altPA_], "invalid pool");
            IEBOP20 altPool = IEBOP20(altPA_);
            require(altPool.balanceOf(msg.sender) >= altA_, "invalid pool");
            (depositValue, lockTotal) = altPool.bet(latestPrice, altA_);
        } else {
            require(msg.value >= 100, "bet to small");
            require(msg.value <= getMaxAvailable(), "bet to big");


            if (devFundBetFee > 0) {
                    uint256 fee = msg.value.div(devFundBetFee).div(100);
                    require(devFund.send(fee), "devFund fee transfer failed");
                    depositValue = msg.value.sub(fee);
            } else {
                    depositValue = msg.value;
                
            }


            uint256 lockValue = getRate(pp_, getMaxAvailable(), depositValue, latestPrice);
            
            if (rewEn) {
                pClaims[msg.sender] = pClaims[msg.sender].add(getBetSizeBonus(depositValue, reward));
            }
            lockTotal = lockValue.add(depositValue);
            lock(lockTotal);
        }

        if (latestPrice != pLP[pp_]) {
            pLP[pp_] = latestPrice;
        }

        Option memory op = Option(
            msg.sender,
            latestPrice,//*
            depositValue,
            lockTotal,//*
            block.timestamp + time_,//time till expiration
            type_,
            pp_,
            altPA_
        );

        options.push(op);
        tI = tI.add(lockTotal);
        emit Create(optionID, msg.sender, latestPrice, lockTotal, type_, altPA_ == address(this));
    }


    

    function exercise(uint256 optionID)
        external
    {
        Option memory option = options[optionID];
        require(block.timestamp <= option.exp, "expiration date margin has passed");
        AggregatorProxy priceProvider = AggregatorProxy(option.pP);
        int256 latestPrice = priceProvider.latestAnswer();
        if (option.dir == OptionType.Call) {
            require(latestPrice > option.sPrice, "price is to low");
        } else {
            require(latestPrice < option.sPrice, "price is to high");
        }


        if (option.altPA != address(this)) {
            IEBOP20 alt = IEBOP20(option.altPA);
            require(alt.payout(option.lValue,option.pValue, msg.sender, option.holder), "erc20 pool exercise failed");
        } else {
            payout(option.lValue, msg.sender, option.holder);
            lockedAmount = lockedAmount.sub(option.lValue);
        }
        
        emit Exercise(optionID);
        if (rewEn) {
            pClaims[msg.sender] = pClaims[msg.sender].add(getBetSizeBonus(option.lValue, reward));
        }
    }

    function expire(uint256 optionID)
        external
    {
        Option memory option = options[optionID];
        require(block.timestamp > option.exp, "expiration date has not passed");


        if (option.altPA != address(this)) {
            IEBOP20 alt = IEBOP20(option.altPA);
            require(alt.unlockAndPayExpirer(option.lValue,option.pValue, msg.sender), "erc20 pool exercise failed");
        } else {
            unlock(option.lValue, msg.sender);
            lockedAmount = lockedAmount.sub(option.lValue);
        }
        emit Expire(optionID);
        if (rewEn) {
            pClaims[msg.sender] = pClaims[msg.sender].add(getBetSizeBonus(option.pValue, reward));
        }
    }

    function lock(uint256 amount) internal {
        lockedAmount = lockedAmount.add(amount);
    }

    function unlock(uint256 amount, address payable goodSamaritan) internal {
        require(amount <= lockedAmount, "insufficent locked pool balance to unlock");
        uint256 fee;
        if (amount <= 10000000000000000) {//small options give bigger fee %
            fee = amount.div(exerciserFee.mul(4)).div(100);
        } else {
            fee = amount.div(exerciserFee).div(100);
        } 
        if (fee > 0) {
            require(goodSamaritan.send(fee), "good samaritan transfer failed");
        }
    }

    function payout(uint256 amount, address payable exerciser, address payable winner) internal {
        require(amount <= lockedAmount, "insufficent pool balance available to payout");
        require(amount <= address(this).balance, "insufficent balance in pool");
        if (exerciser != winner) {
            uint256 fee;
            if (amount <= 10000000000000000) {//small options give bigger fee %
                fee = amount.div(exerciserFee.mul(4)).div(100);
            } else {
                fee = amount.div(exerciserFee).div(100);
            } 
            if (fee > 0) {
                require(exerciser.send(fee), "exerciser transfer failed");
                require(winner.send(amount.sub(fee)), "winner transfer failed");
            }
        } else {  
            require(winner.send(amount), "winner transfer failed");
        }
        emit Payout(amount, winner);
    }

}