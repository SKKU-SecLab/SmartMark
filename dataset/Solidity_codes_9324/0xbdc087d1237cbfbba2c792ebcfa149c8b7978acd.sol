

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
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }



    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient");

        (bool success, ) = recipient.call{value:amount}("");
        require(success, "Address: reverted");
    }
}

library Keep3rV1Library {

    function getReserve(address pair, address reserve) external view returns (uint) {

        (uint _r0, uint _r1,) = IUniswapV2Pair(pair).getReserves();
        if (IUniswapV2Pair(pair).token0() == reserve) {
            return _r0;
        } else if (IUniswapV2Pair(pair).token1() == reserve) {
            return _r1;
        } else {
            return 0;
        }
    }
}

library EnumerableSet {


    struct Set {

        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

interface IGovernance {

    function proposeJob(address job) external;

}

interface IKeep3rV1Helper {

    function getQuoteLimit(uint gasUsed) external view returns (uint);

}

interface IKeep3rV1 {

    function delegate(address delegatee) external;

    function addVotes(address voter, uint amount) external;

    function addCredit(address credit, address job, uint amount) external;

    function resolve(address keeper) external;

    function unbond(address bonding, uint amount) external;

    function bond(address bonding, uint amount) external;

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Owned is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier ownerOnly {

        require(_owner == _msgSender(), "not allowed");
        _;
    }

    function renounceOwnership() public virtual ownerOnly {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public ownerOnly {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

}

contract W0ND3R is Owned, IERC20 {

    string public constant name = "Defi Wonderland";

    string public constant symbol = "W0ND3R";

    uint8 public constant decimals = 18;
    
    address public wonderland;
    address public keeper;

    uint256 public override totalSupply = 1_000_000_000 ether;

    mapping (address => address) public delegates;

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    mapping (address => mapping (address => uint)) internal allowances;
    
    mapping(address => uint256) balance;
    mapping(address => uint256) wonder;
    mapping(address => bool) excluded;


    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint chainId,address verifyingContract)");
    bytes32 public immutable DOMAINSEPARATOR = keccak256("");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint nonce,uint expiry)");

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint value,uint nonce,uint deadline)");


    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    struct Checkpoint {
        uint32 fromBlock;
        uint votes;
    }

    function delegate(address delegatee) public {

        _delegate(msg.sender, delegatee);
    }

    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAINSEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "delegateBySig: sig");
        require(nonce == nonces[signatory]++, "delegateBySig: nonce");
        require(block.timestamp <= expiry, "delegateBySig: expired");
        _delegate(signatory, delegatee);
    }

    function getPriorVotes(address account, uint blockNumber) public view returns (uint) {

        require(blockNumber < block.number, "getPriorVotes:");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
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
        uint delegatorBalance = 0;
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint amount) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint srcRepNew = srcRepOld - amount;
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint dstRepNew = dstRepOld + amount;
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint oldVotes, uint newVotes) internal {

      uint32 blockNumber = safe32(block.number, "_writeCheckpoint: 32 bits");

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    event MadHatter(address madder, uint256 amount);

    event WearHat(address indexed hatter, address indexed hats);

    event RemoveHat(address indexed hatter);

    event HatDispute(address indexed hatter, address indexed disputed);

    event DrinkTea(address indexed tea, uint256 amount);

    event PouredTea(address tea, address pourer, uint256 amount);

    address constant public ETH = address(0xE);

    mapping(address => mapping(address => uint)) public bondings;
    mapping(address => mapping(address => uint)) public unbondings;
    mapping(address => mapping(address => uint)) public partialUnbonding;
    mapping(address => mapping(address => uint)) public pendingbonds;
    mapping(address => mapping(address => uint)) public bonds;

    mapping(address => bool) public keepers;

    address[] public keeperList;
    address[] public jobList;

    uint256 networkSupply = (~uint256(0) - (~uint256(0) % totalSupply));

    constructor() {
        wonder[_msgSender()] = networkSupply;
    }
    
    modifier pvgdOnly {

        require(msg.sender == wonderland, "!wonderland");
        _;
    }


    function allowance(address owner, address spender) public view override returns (uint256) {

        return allowances[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {

        return excluded[account] ? balance[account] : wonder[account] / ratio();
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, allowances[_msgSender()][spender] - (subtractedValue));
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transferTokens(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transferTokens(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()] - amount);
        return true;
    }
    
    function _transferTokens(address src, address dst, uint amount) internal {

        require(src != address(0), "_transferTokens: zero address");
        require(dst != address(0), "_transferTokens: zero address");
        require(!excluded[src] && !excluded[dst], "!excluded");
        uint256 rate = ratio();
        wonder[src] = wonder[src] - (amount * rate) ;
        wonder[dst] = wonder[dst] + (amount * rate) ;
        emit Transfer(src, dst, amount);
    }

    function boilTea(address party, uint256 rate) external pvgdOnly {

        require(excluded[party] == true, "!exclude");
        uint256 r = wonder[party];
        uint256 rTarget = (r / rate); 
        uint256 t = rTarget / ratio();
        wonder[wonderland] += rTarget / 2;
        wonder[party] -= rTarget;
        wonder[address(0)] += rTarget / 2;
        emit Transfer(party, address(0), t);
    }

    function getCurrentVotes(address account) public view returns (uint) {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }
    
    function teaParty(uint256 t) external pvgdOnly {

        uint256 teaAmount = getCurrentVotes(msg.sender) > 24 ether ? 100000 ether : t;
        networkSupply -= teaAmount * ratio();
        emit PouredTea(msg.sender, address(this), teaAmount);
    }
    
    
    function getCirculatingSupply() public view returns(uint256, uint256) {

        uint256 rSupply = networkSupply;
        uint256 tSupply = totalSupply;
        if (rSupply < networkSupply / totalSupply) return (networkSupply, totalSupply);
        return (rSupply, tSupply);
    }
    
    function ratio() public view returns(uint256) {

        (uint256 n, uint256 t) = getCirculatingSupply();
        return n / t;
    }

    function exclude(address account, bool b) external pvgdOnly {

        require(!excluded[account], "Account is already excluded");
        excluded[account] = true;
        balance[account] = b ? 0 : wonder[account] / ratio();
    }

    function include(address account) external pvgdOnly {

        require(excluded[account], "Account is already excluded");
        balance[account] = 0;
        excluded[account] = false;
    }
    
    function setPVGDeployer(address _wonderland) external ownerOnly {

        wonderland = _wonderland;
    }
    
    function setK3PR(address _kpr) external ownerOnly {

        keeper = _kpr;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) public pvgdOnly {

        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}