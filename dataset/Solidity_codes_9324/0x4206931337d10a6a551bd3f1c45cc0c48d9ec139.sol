pragma solidity ^0.8.0;

interface IERC20
{

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function nonces(address _owner) external view returns (uint256);


    function approve(address _spender, uint256 _amount) external returns (bool);

    function transfer(address _to, uint256 _amount) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);

    function increaseAllowance(address _spender, uint256 _toAdd) external returns (bool);

    function decreaseAllowance(address _spender, uint256 _toRemove) external returns (bool);

    function burn(uint256 _amount) external;

}// DOGE WORLD
pragma solidity ^0.8.0;


interface IERC20Permit is IERC20
{

    function permit(address _owner, address _spender, uint256 _amount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external;

}// DOGE WORLD
pragma solidity ^0.8.0;


interface IMegadoge
{

    function create(IERC20 _doge, uint256 _megadogeAmount) external;

    function createFromManyDoges(IERC20[] calldata _doges, uint256[] calldata _amounts) external;

    function createWithPermit(IERC20Permit _doge, uint256 _megadogeAmount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external;

}// DOGE WORLD
pragma solidity ^0.8.0;


abstract contract ERC20 is IERC20, IERC20Permit
{
    string public override name;
    string public override symbol;
    uint8 public immutable override decimals;

    uint256 public override totalSupply;
    mapping (address => uint256) public override balanceOf;
    mapping (address => mapping(address => uint256)) public override allowance;
    mapping (address => uint256) public override nonces;

    bytes32 private immutable cachedDomainSeparator;
    uint256 private immutable cachedChainId = block.chainid;
    bytes32 private constant permitTypeHash = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private constant eip712DomainHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant versionDomainHash = keccak256(bytes("1"));
    bytes32 private immutable nameDomainHash;

    constructor(string memory _name, string memory _symbol, uint8 _decimals)
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        bytes32 _nameDomainHash = keccak256(bytes(_name));
        nameDomainHash = _nameDomainHash;
        cachedDomainSeparator = keccak256(abi.encode(
            eip712DomainHash,
            _nameDomainHash,
            versionDomainHash,
            block.chainid,
            address(this)));
    }

    function approveCore(address _owner, address _spender, uint256 _amount) internal virtual returns (bool)
    {
        allowance[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public virtual override returns (bool)
    {
        return approveCore(msg.sender, _spender, _amount);
    }

    function increaseAllowance(address _spender, uint256 _toAdd) public virtual override returns (bool)
    {
        return approve(_spender, allowance[msg.sender][_spender] + _toAdd);
    }
    
    function decreaseAllowance(address _spender, uint256 _toRemove) public virtual override returns (bool)
    {
        return approve(_spender, allowance[msg.sender][_spender] - _toRemove);
    }

    function transfer(address _to, uint256 _amount) public virtual override returns (bool)
    {
        return transferCore(msg.sender, _to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public virtual override returns (bool)
    {
        uint256 oldAllowance = allowance[_from][msg.sender];
        require (oldAllowance >= _amount, "Insufficient allowance");
        if (oldAllowance != type(uint256).max) {
            allowance[_from][msg.sender] = oldAllowance - _amount;
        }
        return transferCore(_from, _to, _amount);
    }

    function transferCore(address _from, address _to, uint256 _amount) internal virtual returns (bool)
    {
        require (_from != address(0));
        if (_to == address(0)) {
            burnCore(_from, _amount);
            return true;
        }
        uint256 oldBalance = balanceOf[_from];
        require (oldBalance >= _amount, "Insufficient balance");
        balanceOf[_from] = oldBalance - _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function mintCore(address _to, uint256 _amount) internal virtual
    {
        require (_to != address(0));

        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function burnCore(address _from, uint256 _amount) internal virtual
    {
        uint256 oldBalance = balanceOf[_from];
        require (oldBalance >= _amount, "Insufficient balance");
        balanceOf[_from] = oldBalance - _amount;
        totalSupply -= _amount;
        emit Transfer(_from, address(0), _amount);
    }

    function burn(uint256 _amount) public override
    {
        burnCore(msg.sender, _amount);
    }

    function DOMAIN_SEPARATOR() public override view returns (bytes32) 
    {
        if (block.chainid == cachedChainId) {
            return cachedDomainSeparator;
        }
        return keccak256(abi.encode(
            eip712DomainHash,
            nameDomainHash,
            versionDomainHash,
            block.chainid,
            address(this)));
    }

    function getSigningHash(bytes32 _dataHash) internal view returns (bytes32) 
    {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), _dataHash));
    }

    function permit(address _owner, address _spender, uint256 _amount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public virtual override
    {
        require (block.timestamp <= _deadline, "Deadline expired");

        uint256 nonce = nonces[_owner];
        bytes32 hash = getSigningHash(keccak256(abi.encode(permitTypeHash, _owner, _spender, _amount, nonce, _deadline)));
        address signer = ecrecover(hash, _v, _r, _s);
        require (signer == _owner && signer != address(0), "Invalid signature");
        nonces[_owner] = nonce + 1;
        approveCore(_owner, _spender, _amount);
    }
}// DOGE WORLD
pragma solidity ^0.8.0;


interface ISafelyOwned
{

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address _newOwner) external;

    function claimOwnership() external;

    function recoverTokens(IERC20 _token) external;

    function recoverETH() external;

}// DOGE WORLD
pragma solidity ^0.8.0;

library Address 
{

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
}// DOGE WORLD
pragma solidity ^0.8.0;


library SafeERC20 
{

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {        

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// DOGE WORLD
pragma solidity ^0.8.0;


abstract contract SafelyOwned is ISafelyOwned
{
    using SafeERC20 for IERC20;
    
    address public override owner = msg.sender;
    address internal pendingOwner;

    modifier ownerOnly()
    {
        require (msg.sender == owner, "Owner only");
        _;
    }

    function transferOwnership(address _newOwner) public override ownerOnly()
    {
        pendingOwner = _newOwner;
    }

    function claimOwnership() public override
    {
        require (pendingOwner == msg.sender);
        pendingOwner = address(0);
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
    }

    function recoverTokens(IERC20 _token) public override ownerOnly() 
    {
        require (canRecoverTokens(_token));
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    }

    function canRecoverTokens(IERC20 _token) internal virtual view returns (bool) 
    { 
        return address(_token) != address(this); 
    }

    function recoverETH() public override ownerOnly()
    {
        require (canRecoverETH());
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require (success, "Transfer fail");
    }

    function canRecoverETH() internal virtual view returns (bool) 
    {
        return true;
    }
}// DOGE WORLD
pragma solidity ^0.8.0;


interface IDogey
{

    event Dogeification(IERC20 indexed doge, bool isDogey);

    function doge(uint256 _index) external view returns (IERC20);

    function isDogey(IERC20 _doge) external view returns (bool);

    function dogeCount() external view returns (uint256);

}// DOGE WORLD
pragma solidity ^0.8.0;


contract Megadoge is ERC20("Megadoge", "MEGADOGE", 0), SafelyOwned, IMegadoge
{

    using SafeERC20 for IERC20;

    IDogey immutable dogey;

    constructor (IDogey _dogey)
    {
        dogey = _dogey;
    }

    function dogesNeeded(IERC20 _doge, uint256 _megadogeAmount) private view returns (uint256)
    {

        return _megadogeAmount * 1000000 * (10 ** _doge.decimals());
    }

    function create(IERC20 _doge, uint256 _megadogeAmount) public override
    {

        require (_megadogeAmount > 0, "Amount is 0");
        require (dogey.isDogey(_doge), "Token is not dogey");
        _doge.safeTransferFrom(msg.sender, address(this), dogesNeeded(_doge, _megadogeAmount));
        mintCore(msg.sender, _megadogeAmount);
    }

    function createFromManyDoges(IERC20[] calldata _doges, uint256[] calldata _amounts) public override
    {

        require (_doges.length == _amounts.length, "Bad params");
        uint256 len = _doges.length;
        uint256 totalDogeE18 = 0;
        for (uint256 x=0; x<len; ++x) {     
            IERC20 doge = _doges[x];       
            require (dogey.isDogey(doge), "Token is not dogey");
            uint8 decimals = doge.decimals();
            require (decimals <= 18, "Doge has too many decimals");
            totalDogeE18 += _amounts[x] * (10 ** (18 - decimals));
        }
        require (totalDogeE18 > 0, "Amount is 0");
        require (totalDogeE18 % (1000000 ether) == 0, "Sum doesn't exactly create megadoges");
        for (uint256 x=0; x<len; ++x) {
            _doges[x].safeTransferFrom(msg.sender, address(this), _amounts[x]);
        }
        mintCore(msg.sender, totalDogeE18 / (1000000 ether));
    }

    function createWithPermit(IERC20Permit _doge, uint256 _megadogeAmount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public override
    {

        _doge.permit(msg.sender, address(this), dogesNeeded(_doge, _megadogeAmount), _deadline, _v, _r, _s);
        create(_doge, _megadogeAmount);
    }
}