
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

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
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
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


contract Alchemy is IERC20 {


    using SafeMath for uint256;
    using Address for address;

    uint256 internal _totalSupply;

    string internal _name;

    string internal _symbol;

    uint8 internal constant _decimals = 18;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public _sharesForSale;

    struct _raisedNftStruct {
        IERC721 nftaddress;
        bool forSale;
        uint256 tokenid;
        uint256 price;
    }

    uint256 public _nftCount;

    _raisedNftStruct[] public _raisedNftArray;

    mapping (address => mapping( uint256 => bool)) public _ownedAlready;

    uint256 public _buyoutPrice;

    address public _buyoutAddress;

    address public _governor;

    address public _timelock;

    address public _factoryContract;

    mapping (address => address) public delegates;

    struct Checkpoint {
        uint256 votes;
        uint32 fromBlock;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
    event Buyout(address buyer, uint256 price);
    event BuyoutTransfer(address nftaddress, uint256 nftid);
    event BurnedForEth(address account, uint256 reward);
    event SharesBought(address account, uint256 amount);
    event SharesBurned(uint256 amount);
    event SharesMinted(uint256 amount);
    event NewBuyoutPrice(uint256 price);
    event NftSaleChanged(uint256 nftid, uint256 price, bool sale);
    event SingleNftBought(address account, uint256 nftid, uint256 price);
    event NftAdded(address nftaddress, uint256 nftid);
    event NftTransferredAndAdded(address nftaddress, uint256 nftid);
    event TransactionExecuted(address target, uint256 value, string signature, bytes data);

    constructor() {
        _factoryContract = address(1);
    }

    function initialize(
        IERC721[] memory nftAddresses_,
        address owner_,
        uint256[] memory tokenIds_,
        uint256 totalSupply_,
        string memory name_,
        string memory symbol_,
        uint256 buyoutPrice_,
        address factoryContract,
        address governor_,
        address timelock_
    ) external {

        require(_factoryContract == address(0), "already initialized");
        require(factoryContract != address(0), "factory can not be null");

        _factoryContract = factoryContract;
        _governor = governor_;
        _timelock = timelock_;

        for (uint i = 0; i < nftAddresses_.length; i++) {
            _raisedNftArray.push(_raisedNftStruct({
                nftaddress: nftAddresses_[i],
                tokenid: tokenIds_[i],
                forSale: false,
                price: 0
            }));

            _ownedAlready[address(nftAddresses_[i])][tokenIds_[i]] = true;
            _nftCount++;
        }

        _totalSupply = totalSupply_;
        _name = name_;
        _symbol = symbol_;
        _buyoutPrice = buyoutPrice_;
        _balances[owner_] = _totalSupply;
        emit Transfer(address(0), owner_, _totalSupply);
    }

    modifier onlyTimeLock() {

        require(msg.sender == _timelock, "ALC:Only Timelock can call");
        _;
    }

    modifier onlyTimeLockOrBuyer() {

        require(msg.sender == _timelock || msg.sender == _buyoutAddress, "ALC:Only Timelock or Buyer can call");
        _;
    }

    modifier stillToBuy() {

        require(_buyoutAddress == address(0), "ALC:Already bought out");
        _;
    }

    function _burn(uint256 amount) internal {

        _totalSupply = _totalSupply.sub(amount);
    }

    function burnForETH() external {

        uint256 balance = balanceOf(msg.sender);
        _balances[msg.sender] = 0;
        uint256 contractBalance = address(this).balance;
        uint256 cashOut = contractBalance.mul(balance).div(_totalSupply);
        _burn(balance);
        msg.sender.transfer(cashOut);

        emit BurnedForEth(msg.sender, cashOut);
        emit Transfer(msg.sender, address(0), balance);
    }

    function buyShares(uint256 amount) external payable {

        require(_sharesForSale >= amount, "low shares");
        require(msg.value == amount.mul(_buyoutPrice).div(_totalSupply), "low value");

        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _sharesForSale = _sharesForSale.sub(amount);

        emit SharesBought(msg.sender, amount);
        emit Transfer(address(0), msg.sender, amount);
    }

    function getBuyoutPriceWithDiscount(address account) public view returns (uint256) {

        uint256 balance = _balances[account];
        return _buyoutPrice.mul((_totalSupply.sub(balance)).mul(10**18).div(_totalSupply)).div(10**18);
    }

    function buyout() external payable stillToBuy {

        uint256 buyoutPriceWithDiscount = getBuyoutPriceWithDiscount(msg.sender);
        require(msg.value == buyoutPriceWithDiscount, "buy value not met");

        uint256 balance = _balances[msg.sender];
        _balances[msg.sender] = 0;
        _burn(balance);

        address payable alchemyRouter = IAlchemyFactory(_factoryContract).getAlchemyRouter();
        IAlchemyRouter(alchemyRouter).deposit{value:buyoutPriceWithDiscount / 200}();

        _buyoutAddress = msg.sender;

        emit Buyout(msg.sender, buyoutPriceWithDiscount);
        emit Transfer(msg.sender, address(0), balance);
    }

    function buyoutWithdraw(uint[] memory nftids) external {

        require(msg.sender == _buyoutAddress, "can only be called by the buyer");

        _raisedNftStruct[] memory raisedNftArray = _raisedNftArray;

        for (uint i=0; i < nftids.length; i++) {
            raisedNftArray[nftids[i]].nftaddress.safeTransferFrom(address(this), msg.sender, raisedNftArray[nftids[i]].tokenid);
            emit BuyoutTransfer(address(raisedNftArray[nftids[i]].nftaddress), raisedNftArray[nftids[i]].tokenid);
        }
    }

    function burnSharesForSale(uint256 amount) onlyTimeLock external {

        require(_sharesForSale >= amount, "Low shares");

        _burn(amount);
        _sharesForSale = _sharesForSale.sub(amount);

        emit SharesBurned(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function mintSharesForSale(uint256 amount) onlyTimeLock external {

        _totalSupply = _totalSupply.add(amount);
        _sharesForSale = _sharesForSale.add(amount);

        emit SharesMinted(amount);
        emit Transfer(address(0), address(this), amount);
    }

    function changeBuyoutPrice(uint256 amount) onlyTimeLock external {

        _buyoutPrice = amount;
        emit NewBuyoutPrice(amount);
    }

    function setNftSale(uint256 nftarrayid, uint256 price, bool sale) onlyTimeLock external {

        _raisedNftArray[nftarrayid].forSale = sale;
        _raisedNftArray[nftarrayid].price = price;

        emit NftSaleChanged(nftarrayid, price, sale);
    }

    function buySingleNft(uint256 nftarrayid) stillToBuy external payable {

        _raisedNftStruct memory singleNft = _raisedNftArray[nftarrayid];

        require(singleNft.forSale, "Not for sale");
        require(msg.value == singleNft.price, "Price too low");

        address payable alchemyRouter = IAlchemyFactory(_factoryContract).getAlchemyRouter();
        IAlchemyRouter(alchemyRouter).deposit{value:singleNft.price / 200}();

        _ownedAlready[address(singleNft.nftaddress)][singleNft.tokenid] = false;
        _nftCount--;

        for (uint i = nftarrayid; i < _raisedNftArray.length - 1; i++) {
            _raisedNftArray[i] = _raisedNftArray[i+1];
        }
        _raisedNftArray.pop();

        singleNft.nftaddress.safeTransferFrom(address(this), msg.sender, singleNft.tokenid);

        emit SingleNftBought(msg.sender, nftarrayid, singleNft.price);
    }

    function addNft(address new_nft, uint256 tokenid) onlyTimeLockOrBuyer public {

        require(_ownedAlready[new_nft][tokenid] == false, "ALC: Cant add duplicate NFT");
        _raisedNftStruct memory temp_struct;
        temp_struct.nftaddress = IERC721(new_nft);
        temp_struct.tokenid = tokenid;
        _raisedNftArray.push(temp_struct);
        _nftCount++;

        _ownedAlready[new_nft][tokenid] = true;
        emit NftAdded(new_nft, tokenid);
    }

    function transferFromAndAdd(address new_nft, uint256 tokenid) onlyTimeLockOrBuyer public {

        IERC721(new_nft).transferFrom(IERC721(new_nft).ownerOf(tokenid), address(this), tokenid);
        addNft(new_nft, tokenid);

        emit NftTransferredAndAdded(new_nft, tokenid);
    }

    function addNftCollection(address[] memory new_nft_array, uint256[] memory tokenid_array) onlyTimeLockOrBuyer public {

        for (uint i = 0; i <= new_nft_array.length - 1; i++) {
            addNft(new_nft_array[i], tokenid_array[i]);
        }
    }

    function transferFromAndAddCollection(address[] memory new_nft_array, uint256[] memory tokenid_array) onlyTimeLockOrBuyer public {

        for (uint i = 0; i <= new_nft_array.length - 1; i++) {
            transferFromAndAdd(new_nft_array[i], tokenid_array[i]);
        }
    }

    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data) onlyTimeLock external payable returns (bytes memory) {

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value:value}(callData);
        require(success, "ALC:exec reverted");

        emit TransactionExecuted(target, value, signature, data);
        return returnData;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address dst, uint256 rawAmount) external override returns (bool) {

        uint256 amount = rawAmount;
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    fallback() external payable {}

    receive() external payable {}

    function allowance(address owner, address spender)
    public
    override
    view
    returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
    {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 rawAmount) external override returns (bool) {

        address spender = msg.sender;
        uint256 spenderAllowance = _allowances[src][spender];
        uint256 amount = rawAmount;

        if (spender != src && spenderAllowance != uint256(-1)) {
            uint256 newAllowance = spenderAllowance.sub(amount, "NFTDAO:amount exceeds");
            _allowances[src][spender] = newAllowance;
        }

        _transferTokens(src, dst, amount);
        return true;
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "ERC20: approve from 0");
        require(spender != address(0), "ERC20: approve to 0");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), "ERC20: transfer from 0");
        require(recipient != address(0), "ERC20: transfer to 0");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function delegate(address delegatee) public {

        return _delegate(msg.sender, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber) public view returns (uint256) {

        require(blockNumber < block.number, "ALC:getPriorVotes");

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
        uint256 delegatorBalance = _balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _transferTokens(address src, address dst, uint256 amount) internal {

        require(src != address(0), "ALC: cannot transfer 0");
        require(dst != address(0), "ALC: cannot transfer 0");

        _balances[src] = _balances[src].sub( amount, "ALC:_transferTokens");
        _balances[dst] = _balances[dst].add( amount);
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub( amount, "ALC:_moveVotes");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {

        uint32 blockNumber = safe32(block.number, "ALC:_writeCheck");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(newVotes, blockNumber);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }


    function getChainId() internal pure returns (uint) {

        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}


interface IAlchemyFactory {

    function getAlchemyRouter() external view returns (address payable);

}

interface IAlchemyRouter {

    function deposit() external payable;

}