
pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.6.2;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.6.2;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.6.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.2;

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
}// MIT

pragma solidity ^0.6.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri) public {
        _setURI(uri);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: batch balance query for the zero address");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal virtual
    { }


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.6.0;

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
}pragma solidity 0.6.12;


interface IYouBet is IERC20 {

  function burnFromPool (uint amount) external;
}

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}

contract SalePoolV1 is Ownable {

  using SafeMath for uint;
  using SafeERC20 for IERC20;
  using SafeERC20 for IYouBet;

  IYouBet public YouBetToken;
  address public WETH;
  uint public minPoolCost = 100 ether;

  uint64 public perOrderCommissionRate=1e3; // over1e5
  uint64 public contestRewardRate=1e3; // over1e5

  address private feeTo;

  struct PoolInfo {
    IERC20 token;
    address currencyToken;
    address owner;
    address winnerCandidate;
    uint pid;
    uint112 balance;
    uint112 reward;
    uint112 weight;
    uint112 exchangeRate; // exchangeRate*amountInToken/1e18 = amountInCurrency
    uint112 winnerCandidateSales;
    uint64 expiry;
    PoolStatus status;
  }

  enum PoolStatus {
    CANCELED,
    OPEN,
    CLOSED
  }

  modifier tokenLock(address _token) {

    uint16 state = tokenLocks[_token];
    require(state != 2, 'TOKEN LOCKED');
    if(state==0) tokenLocks[_token] = 2;
    _;
    if(state==0) tokenLocks[_token] = 0;
  }

  mapping (uint => PoolInfo) public pools;
  mapping (address => uint16) tokenLocks; // 0=open, 1=whitelisted, 2=locked, 
  
  uint public poolLength=0;

  mapping (uint => mapping(address => uint)) public poolReferrerSales;

  event Purchase(uint indexed poolId, address indexed user,  
        uint amount, address indexed token, address currencyToken, uint cost);

  event PoolNameChange(uint indexed poolId, bytes32 name);

  event PoolProfileImageChange(uint indexed poolId, bytes32 imageUrl);

  event WinnerAnnounced(uint indexed poolId, address indexed winner, 
        uint salesAmount, address token, 
        address currencyToken, uint rewardAmount);

  event PoolCreated(uint indexed poolId, address indexed token, 
    address indexed currencyToken, uint exchangeRate, 
    uint amount,
    uint weight, uint64 expiry);  

  event PoolOwnershipChange(uint indexed poolId, address indexed from, address indexed to);

  event Commission(address indexed referrer, address indexed customer, 
    address indexed currency, uint commission);

  constructor(IYouBet _YouBetToken, address _weth) public {
    YouBetToken = _YouBetToken;
    WETH = _weth;
  }

  receive() external payable {
    require(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
  }

  function setFeeTo (address _feeTo) onlyOwner external {
    feeTo = _feeTo;
  }  

  function setMinPoolCost (uint _minPoolCost) onlyOwner external {
    minPoolCost = _minPoolCost;
  } 

  function setPerOrderCommissionRate (uint64 _r) onlyOwner external {
    perOrderCommissionRate = _r;
  } 

  function setContestRewardRate (uint64 _r) onlyOwner external {
    contestRewardRate = _r;
  } 
  
  
  function setTokenLock (address _token, uint16 state) onlyOwner external {
    tokenLocks[_token] = state;
  }

  function _newPool (address _poolOwner, IERC20 _token, 
    address _currencyToken, uint112 _exchangeRate, 
    uint _reward, 
    uint _weight, uint64 _expiry) internal returns (uint _pid){
    require(_reward <= uint112(-1) && _weight <= uint112(-1), 'OVERFLOW');
    _pid = poolLength;
    pools[_pid] = PoolInfo({
      token: _token,
      currencyToken: _currencyToken,
      exchangeRate: _exchangeRate,
      pid: _pid,
      balance: 0,
      reward: uint112(_reward),
      weight: uint112(_weight),
      owner: _poolOwner,
      expiry: _expiry,
      status: PoolStatus.OPEN,
      winnerCandidate: _poolOwner,
      winnerCandidateSales: 0
    });

    emit PoolCreated(_pid, address(_token), 
      address(_currencyToken), _exchangeRate, _reward, _weight, _expiry); 

    emit PoolOwnershipChange(_pid, address(0), _poolOwner);

    poolLength = poolLength.add(1);
  } 

  function _openNewPool (address _poolOwner, IERC20 _token, 
    address _currencyToken, uint112 _exchangeRate,
    uint _reward, uint _weight, uint64 _expiry) internal returns (uint pid){

    _expiry = uint64(_expiry>now?Math.min(_expiry, now + 4 weeks):now + 4 weeks);
    pid = _newPool(_poolOwner, _token, 
      _currencyToken, _exchangeRate,
      _reward, _weight, _expiry);
  }

  function renewPool (uint _pid, uint _weight, uint64 _expiry) external returns(uint64) {

    require (pools[_pid].status == PoolStatus.OPEN, "lottery pool not open");
    require (msg.sender == pools[_pid].owner || msg.sender == owner(), 
      "only pool owner and contract owner are allowed");
    
    require (now < pools[_pid].expiry + 4 weeks, "lottery pool expired more than 4 weeks ago");
    require (_weight >= minPoolCost, "Need more YouBetToken");
    _expiry = uint64(_expiry>now?Math.min(_expiry, now + 4 weeks):now + 4 weeks);
    pools[_pid].expiry = _expiry;

    YouBetToken.safeTransferFrom(msg.sender, address(this), _weight); 
    YouBetToken.safeTransfer(feeTo, _weight); 
    require(_weight <= uint112(-1), 'OVERFLOW');
    pools[_pid].weight = uint112(_weight);
    return _expiry;
  }
  

  function openNewPoolByOwner (IERC20 _token, address _currencyToken, uint112 _exchangeRate,
    uint _reward, uint _weight, uint64 _expiry) onlyOwner external returns (uint pid){
    pid = _openNewPool(owner(), _token, _currencyToken, _exchangeRate,
      _reward, _weight, _expiry);

  }

  function transferPoolOwnership (uint _pid, address to) external {
    PoolInfo memory pool = pools[_pid];
    require (pool.status == PoolStatus.OPEN, "Only open pool can have ownership change");    

    address from = msg.sender;
    require (from == pool.owner, "Forbidden");
    pools[_pid].owner = to;

    emit PoolOwnershipChange(_pid, from, to);    
  }

  function _renamePool (uint _pid, bytes32 name) internal returns(bool res) {
    emit PoolNameChange(_pid, name);
    res = true;
  }
  
  function renamePoolByOwner (uint _pid, bytes32 name) onlyOwner external returns(bool res) {
    res = _renamePool(_pid, name);
  }

  function _setPoolProfileImage (uint _pid, bytes32 imageUrl)  internal returns(bool res) {
    emit PoolProfileImageChange(_pid, imageUrl);
    res = true;
  }
  
  function setPoolProfileImage (uint _pid, bytes32 imageUrl) external returns(bool res) {
    PoolInfo memory pool = pools[_pid];
    require (pool.status==PoolStatus.OPEN, "pool is not open");
    require (msg.sender == pools[_pid].owner || msg.sender == owner(), 
      "only pool owner and contract owner are allowed");
    uint weight = pool.weight;
    YouBetToken.safeTransferFrom(msg.sender, address(this), weight);    
    YouBetToken.safeTransfer(feeTo, weight/2);
    YouBetToken.burnFromPool(weight-weight/2);
    res = _setPoolProfileImage(_pid, imageUrl);
  }

  function withdrawBalanceFromExpiredPool (uint _pid) onlyOwner external returns(bool res) {
    require (now > pools[_pid].expiry + 4 weeks, "lottery pool not dead yet");
    IERC20 _token = pools[_pid].token;
    IERC20 _currencyToken = IERC20(pools[_pid].currencyToken);
    uint _balance = pools[_pid].balance;
    uint _reward = pools[_pid].reward;
    _currencyToken.safeTransfer(owner(), _balance);
    _token.safeTransfer(owner(), _reward);
    pools[_pid].balance = 0;
    res = true;
  }
  

  function setPoolProfileImageByOwner (uint _pid, bytes32 imageUrl) onlyOwner external returns(bool res) {
    res = _setPoolProfileImage(_pid, imageUrl);
  } 
  


  function openNewPool (IERC20 _token, address _currencyToken, uint112 _exchangeRate,
    uint _reward, uint _weight, uint64 _expiry, bytes32 name) external returns (uint pid){


    address poolOwner = msg.sender;

    _reward = _safeTokenTransfer(poolOwner, address(_token), _reward, address(0));

    if(_weight>0) {
      YouBetToken.safeTransferFrom(poolOwner, address(this), _weight);
      YouBetToken.safeTransfer(feeTo, _weight);
    }    
    
    pid = _openNewPool(poolOwner, _token, _currencyToken, _exchangeRate,
      _reward, _weight, _expiry);
    if(name != ''){
      _renamePool(pid, name);
    }
  }

  function _safeTokenTransfer (address _from, 
    address _tokenAddress, 
    uint cost, address referrer) tokenLock(_tokenAddress) internal returns(uint balanceDelta) {

    IERC20 _token = IERC20(_tokenAddress);
    if(tokenLocks[_tokenAddress]==1){
      _token.safeTransferFrom(_from, address(this), cost);
      if(referrer != address(0)){
        uint commission = cost.mul(perOrderCommissionRate)/1e5;
        _token.safeTransfer(referrer, commission);
        balanceDelta = cost - commission;
      }else{
        balanceDelta = cost;
      }      
    }else{
      uint balance0 = _token.balanceOf(address(this));
      _token.safeTransferFrom(_from, address(this), cost);
      if(referrer != address(0)){
        uint commission = cost.mul(perOrderCommissionRate)/1e5;
        _token.safeTransfer(referrer, commission);
        emit Commission(referrer, _from, _tokenAddress, commission);
      }
      uint balance1 = _token.balanceOf(address(this));
      balanceDelta = balance1.sub(balance0);
    }
  }

  function buyTokenWithETH (uint _pid, uint _purchaseAmount, 
    address referrer) external payable {
    address _customer = msg.sender;
    require (pools[_pid].status == PoolStatus.OPEN, "lottery pool not open");
    require (now < pools[_pid].expiry, "lottery pool expired");

    IERC20 _pooltoken = IERC20(pools[_pid].token);
    address _poolCurrencyToken = pools[_pid].currencyToken;

    require (_poolCurrencyToken==WETH);    

    uint cost = _purchaseAmount.mul(pools[_pid].exchangeRate)/1e18;

    IWETH(WETH).deposit{value: cost}();

    if(referrer != address(0)){
      uint commission = cost.mul(perOrderCommissionRate)/1e5;
      IERC20(WETH).safeTransfer(referrer, commission);
      cost -= commission;
      emit Commission(referrer, _customer, WETH, commission);
    }

    uint _balance = cost.add(pools[_pid].balance);
    uint _rewardBalance = _pooltoken.balanceOf(address(this));
    require(_balance <= uint112(-1) && _rewardBalance <= uint112(-1), 'OVERFLOW');
    pools[_pid].balance = uint112(_balance);

    _pooltoken.safeTransfer(_customer, _purchaseAmount);

    uint112 _newReward = uint112(uint(pools[_pid].reward).sub(_purchaseAmount));
    uint112 _rewardRealBalance = uint112(_rewardBalance);
    pools[_pid].reward = _newReward<_rewardRealBalance?_newReward:_rewardRealBalance;

    if(referrer != address(0)) {
      uint newReferrarSales = _purchaseAmount.add(poolReferrerSales[_pid][referrer]);
      require(newReferrarSales <= uint112(-1), 'OVERFLOW');
      poolReferrerSales[_pid][referrer] = newReferrarSales;
      if(newReferrarSales > pools[_pid].winnerCandidateSales){
        pools[_pid].winnerCandidateSales = uint112(newReferrarSales);
        pools[_pid].winnerCandidate = referrer;
      }

    }

    emit Purchase(_pid, _customer, _purchaseAmount, 
      address(_pooltoken), _poolCurrencyToken, cost);
  }
  
  
  function buyToken (uint _pid, uint _purchaseAmount, address referrer) external {
    address _customer = msg.sender;
    require (pools[_pid].status == PoolStatus.OPEN, "lottery pool not open");
    require (now < pools[_pid].expiry, "lottery pool expired");

    IERC20 _pooltoken = IERC20(pools[_pid].token);
    address _poolCurrencyToken = pools[_pid].currencyToken;

    uint cost = _purchaseAmount.mul(pools[_pid].exchangeRate)/1e18;
    uint balanceDelta = _safeTokenTransfer(_customer, _poolCurrencyToken, cost, referrer);

    uint _balance = balanceDelta.add(pools[_pid].balance);
    uint _rewardBalance = _pooltoken.balanceOf(address(this));
    require(_balance <= uint112(-1) && _rewardBalance <= uint112(-1), 'OVERFLOW');
    pools[_pid].balance = uint112(_balance);

    _pooltoken.safeTransfer(_customer, _purchaseAmount);

    uint112 _newReward = uint112(uint(pools[_pid].reward).sub(_purchaseAmount));
    uint112 _rewardRealBalance = uint112(_rewardBalance);
    pools[_pid].reward = _newReward<_rewardRealBalance?_newReward:_rewardRealBalance;

    if(referrer != address(0)) {
      uint newReferrarSales = _purchaseAmount.add(poolReferrerSales[_pid][referrer]);
      require(newReferrarSales <= uint112(-1), 'OVERFLOW');
      poolReferrerSales[_pid][referrer] = newReferrarSales;
      if(newReferrarSales > pools[_pid].winnerCandidateSales){
        pools[_pid].winnerCandidateSales = uint112(newReferrarSales);
        pools[_pid].winnerCandidate = referrer;
      }
      
    }

    emit Purchase(_pid, _customer, _purchaseAmount, 
      address(_pooltoken), _poolCurrencyToken, cost);
  }


  function processContestWinner (uint _pid, uint _contestReward) internal {

    address winner = pools[_pid].winnerCandidate;

    IERC20 _poolCurrencyToken = IERC20(pools[_pid].currencyToken);

    _poolCurrencyToken.safeTransfer(winner, _contestReward);

    pools[_pid].status = PoolStatus.CLOSED;

    emit WinnerAnnounced(_pid, winner, 
      pools[_pid].winnerCandidateSales, address(pools[_pid].token),
      address(_poolCurrencyToken), _contestReward);

  }
  
  function closePool (uint _pid) external {
    address _poolOwner = pools[_pid].owner;

    require (pools[_pid].status==PoolStatus.OPEN, "Pool must be open");

    require (_poolOwner==msg.sender||msg.sender==owner(), "unauthorized");

    IERC20 _pooltoken = IERC20(pools[_pid].token);
    IERC20 _poolCurrencyToken = IERC20(pools[_pid].currencyToken);
    uint _poolReward = pools[_pid].reward;
    uint _poolExchangeRate = pools[_pid].exchangeRate;
    uint _poolBalance = pools[_pid].balance;

    uint _fees = _poolBalance/100;
    uint _contestReward = _poolBalance.mul(contestRewardRate)/1e5;
    uint _poolOwnerRevenue = _poolBalance - _fees - _contestReward;

    _poolCurrencyToken.safeTransfer(_poolOwner, _poolOwnerRevenue);
    _pooltoken.safeTransfer(_poolOwner, _poolReward);

    _poolCurrencyToken.safeTransfer(feeTo, _fees);

    processContestWinner(_pid, _contestReward);

  }
  
}