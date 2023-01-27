
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}pragma solidity 0.7.5;

abstract contract Proxy {
    function implementation() virtual public view returns (address);

    function proxyType() virtual public pure returns (uint256 proxyTypeId);

    fallback () external payable {
        address _impl = implementation();
        require(_impl != address(0), "Proxy implementation required");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}pragma solidity 0.7.5;

contract OwnedUpgradeabilityStorage {


    address internal _implementation;

    address private _upgradeabilityOwner;

    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;
    }

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;
    }

}pragma solidity 0.7.5;


contract OwnedUpgradeabilityProxy is Proxy, OwnedUpgradeabilityStorage {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    event Upgraded(address indexed implementation);

    function implementation() override public view returns (address) {

        return _implementation;
    }

    function proxyType() override public pure returns (uint256 proxyTypeId) {

        return 2;
    }

    function _upgradeTo(address implementation) internal {

        require(_implementation != implementation, "Proxy already uses this implementation");
        _implementation = implementation;
        emit Upgraded(implementation);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner(), "Only the proxy owner can call this method");
        _;
    }

    function proxyOwner() public view returns (address) {

        return upgradeabilityOwner();
    }

    function transferProxyOwnership(address newOwner) public onlyProxyOwner {

        require(newOwner != address(0), "New owner cannot be the null address");
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    function upgradeTo(address implementation) public onlyProxyOwner {

        _upgradeTo(implementation);
    }

    function upgradeToAndCall(address implementation, bytes memory data) payable public onlyProxyOwner {

        upgradeTo(implementation);
        (bool success,) = address(this).delegatecall(data);
        require(success, "Call failed after proxy upgrade");
    }
}/*

  OwnableDelegateProxy

*/

pragma solidity 0.7.5;


contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {


    constructor(address owner, address initialImplementation, bytes memory data)
        public
    {
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool success,) = initialImplementation.delegatecall(data);
        require(success, "OwnableDelegateProxy failed implementation");
    }

}/*

  Proxy registry interface.

*/

pragma solidity 0.7.5;


interface ProxyRegistryInterface {


    function delegateProxyImplementation() external returns (address);


    function proxies(address owner) external returns (OwnableDelegateProxy);


}/*

  Proxy registry; keeps a mapping of AuthenticatedProxy contracts and mapping of contracts authorized to access them.

  Abstracted away from the Exchange (a) to reduce Exchange attack surface and (b) so that the Exchange contract can be upgraded without users needing to transfer assets to new proxies.

*/

pragma solidity 0.7.5;



contract ProxyRegistry is Ownable, ProxyRegistryInterface {


    address public override delegateProxyImplementation;

    mapping(address => OwnableDelegateProxy) public override proxies;

    mapping(address => uint) public pending;

    mapping(address => bool) public contracts;

    uint public DELAY_PERIOD = 2 weeks;

    function startGrantAuthentication (address addr)
        public
        onlyOwner
    {
        require(!contracts[addr] && pending[addr] == 0, "Contract is already allowed in registry, or pending");
        pending[addr] = block.timestamp;
    }

    function endGrantAuthentication (address addr)
        public
        onlyOwner
    {
        require(!contracts[addr] && pending[addr] != 0 && ((pending[addr] + DELAY_PERIOD) < block.timestamp), "Contract is no longer pending or has already been approved by registry");
        pending[addr] = 0;
        contracts[addr] = true;
    }

    function revokeAuthentication (address addr)
        public
        onlyOwner
    {
        contracts[addr] = false;
    }

    function registerProxy()
        public
        returns (OwnableDelegateProxy proxy)
    {

        return registerProxyFor(msg.sender);
    }

    function registerProxyOverride()
        public
        returns (OwnableDelegateProxy proxy)
    {

        proxy = new OwnableDelegateProxy(msg.sender, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", msg.sender, address(this)));
        proxies[msg.sender] = proxy;
        return proxy;
    }

    function registerProxyFor(address user)
        public
        returns (OwnableDelegateProxy proxy)
    {

        require(proxies[user] == OwnableDelegateProxy(0), "User already has a proxy");
        proxy = new OwnableDelegateProxy(user, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", user, address(this)));
        proxies[user] = proxy;
        return proxy;
    }

    function registerProxyForMultiple(address[] calldata users)
        external
        returns (OwnableDelegateProxy[] memory)
    {

        OwnableDelegateProxy[] memory userProxies = new OwnableDelegateProxy[](users.length);
        for (uint i = 0; i < users.length; i++) {
            require(proxies[users[i]] == OwnableDelegateProxy(0), "User already has a proxy");
            OwnableDelegateProxy proxy = new OwnableDelegateProxy(users[i], delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", users[i], address(this)));
            proxies[users[i]] = proxy;
            userProxies[i] = proxy;
        }
        return userProxies;
    }

    function transferAccessTo(address from, address to)
        public
    {

        OwnableDelegateProxy proxy = proxies[from];

        require(OwnableDelegateProxy(msg.sender) == proxy, "Proxy transfer can only be called by the proxy");
        require(proxies[to] == OwnableDelegateProxy(0), "Proxy transfer has existing proxy as destination");

        delete proxies[from];
        proxies[to] = proxy;
    }

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

pragma solidity >=0.6.0 <0.8.0;


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
}/*

  Token recipient. Modified very slightly from the example on http://ethereum.org/dao (just to index log parameters).

*/

pragma solidity 0.7.5;

contract TokenRecipient {


    using SafeERC20 for IERC20;

    event ReceivedEther(address indexed sender, uint amount);
    event ReceivedTokens(address indexed from, uint256 value, address indexed token, bytes extraData);

    function receiveApproval(address from, uint256 value, address token, bytes memory extraData) public {

        IERC20 t = IERC20(token);
        t.safeTransferFrom(from, address(this), value);
        emit ReceivedTokens(from, value, token, extraData);
    }

    fallback () payable external {
        emit ReceivedEther(msg.sender, msg.value);
    }
}/*

  Proxy contract to hold access to assets on behalf of a user (e.g. ERC20 approve) and execute calls under particular conditions.

*/

pragma solidity 0.7.5;


contract AuthenticatedProxy is TokenRecipient, OwnedUpgradeabilityStorage {


    bool initialized = false;

    address public user;

    ProxyRegistry public registry;

    bool public revoked;

    enum HowToCall { Call, DelegateCall }

    event Revoked(bool revoked);

    function initialize (address addrUser, ProxyRegistry addrRegistry)
        public
    {
        require(!initialized, "Authenticated proxy already initialized");
        initialized = true;
        user = addrUser;
        registry = addrRegistry;
    }

    function setRevoke(bool revoke)
        public
    {

        require(msg.sender == user, "Authenticated proxy can only be revoked by its user");
        revoked = revoke;
        emit Revoked(revoke);
    }

    function proxy(address dest, HowToCall howToCall, bytes memory data)
        public payable
        returns (bool result)
    {

        require(msg.sender == user || (!revoked && registry.contracts(msg.sender)), "Authenticated proxy can only be called by its user, or by a contract authorized by the registry as long as the user has not revoked access");
        bytes memory ret;
        if (howToCall == HowToCall.Call) {
            (result, ret) = dest.call(data);
        } else if (howToCall == HowToCall.DelegateCall) {
            (result, ret) = dest.delegatecall(data);
        }
        return result;
    }

    function proxyAssert(address dest, HowToCall howToCall, bytes memory data)
        public
    {

        require(proxy(dest, howToCall, data), "Proxy assertion failed");
    }

}/*

  << ArrayUtils >>

  Various functions for manipulating arrays in Solidity.
  This library is completely inlined and does not need to be deployed or linked.

*/

pragma solidity 0.7.5;


library ArrayUtils {


    function guardedArrayReplace(bytes memory array, bytes memory desired, bytes memory mask)
        internal
        pure
    {

        require(array.length == desired.length, "Arrays have different lengths");
        require(array.length == mask.length, "Array and mask have different lengths");

        uint words = array.length / 0x20;
        uint index = words * 0x20;
        assert(index / 0x20 == words);
        uint i;

        for (i = 0; i < words; i++) {
            assembly {
                let commonIndex := mul(0x20, add(1, i))
                let maskValue := mload(add(mask, commonIndex))
                mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
            }
        }

        if (words > 0) {
            i = words;
            assembly {
                let commonIndex := mul(0x20, add(1, i))
                let maskValue := mload(add(mask, commonIndex))
                mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
            }
        } else {
            for (i = index; i < array.length; i++) {
                array[i] = ((mask[i] ^ 0xff) & array[i]) | (mask[i] & desired[i]);
            }
        }
    }

    function arrayEq(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {

        bool success = true;

        assembly {
            let length := mload(a)

            switch eq(length, mload(b))
            case 1 {
                let cb := 1

                let mc := add(a, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(b, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function arrayDrop(bytes memory _bytes, uint _start)
        internal
        pure
        returns (bytes memory)
    {


        uint _length = SafeMath.sub(_bytes.length, _start);
        return arraySlice(_bytes, _start, _length);
    }

    function arrayTake(bytes memory _bytes, uint _length)
        internal
        pure
        returns (bytes memory)
    {


        return arraySlice(_bytes, 0, _length);
    }

    function arraySlice(bytes memory _bytes, uint _start, uint _length)
        internal
        pure
        returns (bytes memory)
    {


        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function unsafeWriteBytes(uint index, bytes memory source)
        internal
        pure
        returns (uint)
    {

        if (source.length > 0) {
            assembly {
                let length := mload(source)
                let end := add(source, add(0x20, length))
                let arrIndex := add(source, 0x20)
                let tempIndex := index
                for { } eq(lt(arrIndex, end), 1) {
                    arrIndex := add(arrIndex, 0x20)
                    tempIndex := add(tempIndex, 0x20)
                } {
                    mstore(tempIndex, mload(arrIndex))
                }
                index := add(index, length)
            }
        }
        return index;
    }

    function unsafeWriteAddress(uint index, address source)
        internal
        pure
        returns (uint)
    {
        uint conv = uint(source) << 0x60;
        assembly {
            mstore(index, conv)
            index := add(index, 0x14)
        }
        return index;
    }

    function unsafeWriteUint(uint index, uint source)
        internal
        pure
        returns (uint)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }

    function unsafeWriteUint8(uint index, uint8 source)
        internal
        pure
        returns (uint)
    {
        assembly {
            mstore8(index, source)
            index := add(index, 0x1)
        }
        return index;
    }

}/*

  << Static Check ERC20 contract >>

*/


pragma solidity 0.7.5;

contract StaticCheckERC20{

    function checkERC20Side(bytes memory data, address from, address to, uint256 amount)
        internal
        pure
    {

        require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount)));
    }

    function checkERC20SideWithOneFee(bytes memory data, address from, address to, address feeRecipient, uint256 amount, uint256 fee)
        internal
        pure
    {

        require(ArrayUtils.arrayEq(ArrayUtils.arraySlice(data, 356, 100), abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount)));
        require(ArrayUtils.arrayEq(ArrayUtils.arraySlice(data, 516, 100), abi.encodeWithSignature("transferFrom(address,address,uint256)", from, feeRecipient, fee)));
    }

    function checkERC20SideWithTwoFees(bytes memory data, address from, address to, address feeRecipient, address royaltyFeeRecipient, uint256 amount, uint256 fee, uint256 royaltyFee)
        internal
        pure
    {

        require(ArrayUtils.arrayEq(ArrayUtils.arraySlice(data, 452, 100), abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount)));
        require(ArrayUtils.arrayEq(ArrayUtils.arraySlice(data, 612, 100), abi.encodeWithSignature("transferFrom(address,address,uint256)", from, feeRecipient, fee)));
        require(ArrayUtils.arrayEq(ArrayUtils.arraySlice(data, 772, 100), abi.encodeWithSignature("transferFrom(address,address,uint256)", from, royaltyFeeRecipient, royaltyFee)));
    }
}/*

  << Static Check ERC721 contract >>

*/


pragma solidity 0.7.5;

contract StaticCheckERC721 {

    function checkERC721Side(bytes memory data, address from, address to, uint256 tokenId)
        internal
        pure
    {

        require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, tokenId)));
    }

    function checkERC721SideForCollection(bytes memory data, address from, address to)
        internal
        pure
    {

        (uint256 tokenId) = abi.decode(ArrayUtils.arraySlice(data, 68, 32), (uint256));
        require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, tokenId)));
    }
}/*

  << Static Check ERC1155 contract >>

*/


pragma solidity 0.7.5;

contract StaticCheckERC1155 {

    function getERC1155AmountFromCalldata(bytes memory data)
        internal
        pure
        returns (uint256)
    {

        (uint256 amount) = abi.decode(ArrayUtils.arraySlice(data, 100, 32), (uint256));
        return amount;
    }

    function checkERC1155Side(bytes memory data, address from, address to, uint256 tokenId, uint256 amount)
        internal
        pure
    {

        require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", from, to, tokenId, amount, "")));
    }
}/*

  << Static Check ETH contract >>

*/

pragma solidity 0.7.5;

contract StaticCheckETH {

    function checkETHSideWithOffset(address to, uint256 value, uint price, bytes memory data) internal pure {

        require(value > 0 && value == price, "checkETHSideWithOffset: Price must be same and greater than 0");
        address[] memory addrs = new address[](1);
        addrs[0] = to;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = price;
        require(ArrayUtils.arrayEq(ArrayUtils.arraySlice(data, 132, 196), abi.encodeWithSignature("transferETH(address[],uint256[])", addrs, amounts)));
    }

    function checkETHSideOneFeeWithOffset(address to, address feeRecipient, uint256 value, uint price, uint fee, bytes memory data) internal pure {

        require(value > 0 && value == SafeMath.add(price, fee), "checkETHSideOneFeeWithOffset: Price must be same and greater than 0");
        address[] memory addrs = new address[](2);
        addrs[0] = to;
        addrs[1] = feeRecipient;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = price;
        amounts[1] = fee;
        require(ArrayUtils.arrayEq(ArrayUtils.arraySlice(data, 132, 260), abi.encodeWithSignature("transferETH(address[],uint256[])", addrs, amounts)));
    }

    function checkETHSideTwoFeesWithOffset(address to, address feeRecipient, address royaltyFeeRecipient, uint256 value, uint price, uint fee, uint royaltyFee, bytes memory data) internal pure {

        require(value > 0 && value == SafeMath.add(SafeMath.add(price, fee), royaltyFee), "checkETHSideTwoFeesWithOffset: Price must be same and greater than 0");
        address[] memory addrs = new address[](3);
        addrs[0] = to;
        addrs[1] = feeRecipient;
        addrs[2] = royaltyFeeRecipient;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = price;
        amounts[1] = fee;
        amounts[2] = royaltyFee;
        require(ArrayUtils.arrayEq(ArrayUtils.arraySlice(data, 132, 324), abi.encodeWithSignature("transferETH(address[],uint256[])", addrs, amounts)));
    }
}/*

  << Static Atomicizer Base >>

*/

pragma solidity 0.7.5;

contract StaticAtomicizerBase {

    address public atomicizer;
    address public owner;

    function setAtomicizer(address addr) external {

        require(msg.sender == owner, "Atomicizer can only be set by owner");
        atomicizer = addr;
    }
}/*

  << Static Market contract >>

*/


pragma solidity 0.7.5;

contract StaticMarketPlatform is StaticCheckERC20, StaticCheckERC721, StaticCheckERC1155, StaticCheckETH, StaticAtomicizerBase {

    constructor (address addr)
        public
    {
        atomicizer = addr;
        owner = msg.sender;
    }

    function ERC721ForETH(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "call must be a direct call");

        (address[1] memory tokenGive, uint256[2] memory tokenIdAndPrice) = abi.decode(extra, (address[1], uint256[2]));

        require(tokenIdAndPrice[1] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == tokenGive[0], "call target must equal address of token to give");
        require(addresses[5] == atomicizer, "countercall target must equal address of atomicizer");

        checkERC721Side(data,addresses[1],addresses[4],tokenIdAndPrice[0]);

        checkETHSideWithOffset(addresses[1], uints[0], tokenIdAndPrice[1], counterdata);

        return 1;
    }

    function ETHForERC721(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[1] memory tokenGet, uint256[2] memory tokenIdAndPrice) = abi.decode(extra, (address[1], uint256[2]));

        require(tokenIdAndPrice[1] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == atomicizer, "call target must equal address of atomicizer");
        require(addresses[5] == tokenGet[0], "countercall target must equal address of token to get");

        checkERC721Side(counterdata,addresses[4],addresses[1],tokenIdAndPrice[0]);

        checkETHSideWithOffset(addresses[4], uints[0], tokenIdAndPrice[1], data);

        return tokenIdAndPrice[tokenIdAndPrice.length - 1];
    }

    function ERC721ForETHWithOneFee(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "call must be a direct call");

        (address[2] memory tokenGiveAndFeeRecipient, uint256[3] memory tokenIdAndPriceAndFee) = abi.decode(extra, (address[2], uint256[3]));

        require(tokenIdAndPriceAndFee[1] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == tokenGiveAndFeeRecipient[0], "call target must equal address of token to give");
        require(addresses[5] == atomicizer, "countercall target must equal address of atomicizer");

        checkERC721Side(data, addresses[1], addresses[4], tokenIdAndPriceAndFee[0]);

        checkETHSideOneFeeWithOffset(addresses[1], tokenGiveAndFeeRecipient[1], uints[0], tokenIdAndPriceAndFee[1], tokenIdAndPriceAndFee[2], counterdata);

        return 1;
    }

    function ETHForERC721WithOneFee(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata)
        public
        view
        returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[2] memory tokenGetAndFeeRecipient, uint256[3] memory tokenIdAndPriceAndFee) = abi.decode(extra, (address[2], uint256[3]));

        require(tokenIdAndPriceAndFee[1] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == atomicizer, "call target must equal address of atomicizer");
        require(addresses[5] == tokenGetAndFeeRecipient[0], "countercall target must equal address of token to get");

        checkERC721Side(counterdata, addresses[4], addresses[1], tokenIdAndPriceAndFee[0]);

        checkETHSideOneFeeWithOffset(addresses[4], tokenGetAndFeeRecipient[1], uints[0], tokenIdAndPriceAndFee[1], tokenIdAndPriceAndFee[2], data);

        return tokenIdAndPriceAndFee[tokenIdAndPriceAndFee.length - 2] + tokenIdAndPriceAndFee[tokenIdAndPriceAndFee.length - 1];
    }

    function ERC721ForETHWithTwoFees(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "call must be a direct call");

        (address[3] memory tokenGiveAndFeeRecipient, uint256[4] memory tokenIdAndPriceAndFee) = abi.decode(extra, (address[3], uint256[4]));

        require(tokenIdAndPriceAndFee[1] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == tokenGiveAndFeeRecipient[0], "call target must equal address of token to give");
        require(addresses[5] == atomicizer, "countercall target must equal address of atomicizer");

        checkERC721Side(data, addresses[1], addresses[4], tokenIdAndPriceAndFee[0]);

        checkETHSideTwoFeesWithOffset(addresses[1], tokenGiveAndFeeRecipient[1], tokenGiveAndFeeRecipient[2], uints[0], tokenIdAndPriceAndFee[1], tokenIdAndPriceAndFee[2], tokenIdAndPriceAndFee[3], counterdata);

        return 1;
    }

    function ETHForERC721WithTwoFees(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata)
        public
        view
        returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[3] memory tokenGetAndFeeRecipient, uint256[4] memory tokenIdAndPriceAndFee) = abi.decode(extra, (address[3], uint256[4]));

        require(tokenIdAndPriceAndFee[1] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == atomicizer, "call target must equal address of atomicizer");
        require(addresses[5] == tokenGetAndFeeRecipient[0], "countercall target must equal address of token to get");

        checkERC721Side(counterdata, addresses[4], addresses[1], tokenIdAndPriceAndFee[0]);

        checkETHSideTwoFeesWithOffset(addresses[4], tokenGetAndFeeRecipient[1], tokenGetAndFeeRecipient[2], uints[0], tokenIdAndPriceAndFee[1], tokenIdAndPriceAndFee[2], tokenIdAndPriceAndFee[3], data);

        return tokenIdAndPriceAndFee[tokenIdAndPriceAndFee.length - 3] + tokenIdAndPriceAndFee[tokenIdAndPriceAndFee.length - 2] + tokenIdAndPriceAndFee[tokenIdAndPriceAndFee.length - 1];
    }

    function ETHForAnyERC721(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[1] memory tokenGet, uint256[1] memory price) = abi.decode(extra, (address[1], uint256[1]));

        require(price[0] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == atomicizer, "call target must equal address of atomicizer");
        require(addresses[5] == tokenGet[0], "countercall target must equal address of token to get");

        checkERC721SideForCollection(counterdata,addresses[4],addresses[1]);

        checkETHSideWithOffset(addresses[4], uints[0], price[0], data);

        return price[0];
    }

    function ETHForAnyERC721WithOneFee(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata)
        public
        view
        returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[2] memory tokenGetAndFeeRecipient, uint256[2] memory priceAndFee) = abi.decode(extra, (address[2], uint256[2]));

        require(priceAndFee[0] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == atomicizer, "countercall target must equal address of atomicizer");
        require(addresses[5] == tokenGetAndFeeRecipient[0], "countercall target must equal address of token to get");

        checkERC721SideForCollection(counterdata, addresses[4], addresses[1]);

        checkETHSideOneFeeWithOffset(addresses[4], tokenGetAndFeeRecipient[1], uints[0], priceAndFee[0], priceAndFee[1], data);

        return priceAndFee[priceAndFee.length - 2] + priceAndFee[priceAndFee.length - 1];
    }

    function ETHForAnyERC721WithTwoFees(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata)
        public
        view
        returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[3] memory tokenGetAndFeeRecipient, uint256[3] memory priceAndFee) = abi.decode(extra, (address[3], uint256[3]));

        require(priceAndFee[0] > 0,"ERC721 price must be larger than zero");
        require(addresses[2] == atomicizer, "countercall target must equal address of atomicizer");
        require(addresses[5] == tokenGetAndFeeRecipient[0], "countercall target must equal address of token to get");

        checkERC721SideForCollection(counterdata, addresses[4], addresses[1]);

        checkETHSideTwoFeesWithOffset(addresses[4], tokenGetAndFeeRecipient[1], tokenGetAndFeeRecipient[2], uints[0], priceAndFee[0], priceAndFee[1], priceAndFee[2], data);

        return priceAndFee[priceAndFee.length - 3] + priceAndFee[priceAndFee.length - 2] + priceAndFee[priceAndFee.length - 1];
    }

    function ERC1155ForETH(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "call must be a direct call");

        (address[1] memory tokenGive, uint256[3] memory tokenIdAndNumeratorDenominator) = abi.decode(extra, (address[1], uint256[3]));

        require(tokenIdAndNumeratorDenominator[1] > 0, "numerator must be larger than zero");
        require(tokenIdAndNumeratorDenominator[2] > 0, "denominator must be larger than zero");

        require(addresses[2] == tokenGive[0], "call target must equal address of token to give");
        require(addresses[5] == atomicizer, "countercall target must equal address of atomicizer");

        uint256 erc1155Amount = getERC1155AmountFromCalldata(data);
        uint256 new_fill = SafeMath.add(uints[5], erc1155Amount);
        require(new_fill <= uints[1],"new fill exceeds maximum fill");
        require(SafeMath.mul(tokenIdAndNumeratorDenominator[1], uints[0]) == SafeMath.mul(tokenIdAndNumeratorDenominator[2], erc1155Amount), "wrong ratio");

        checkERC1155Side(data, addresses[1], addresses[4], tokenIdAndNumeratorDenominator[0], erc1155Amount);

        checkETHSideWithOffset(addresses[1], uints[0], tokenIdAndNumeratorDenominator[2], counterdata);

        return new_fill;
    }

    function ETHForERC1155(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[1] memory tokenGet, uint256[3] memory tokenIdAndNumeratorDenominator) = abi.decode(extra, (address[1], uint256[3]));

        require(tokenIdAndNumeratorDenominator[1] > 0,"numerator must be larger than zero");
        require(tokenIdAndNumeratorDenominator[2] > 0,"denominator must be larger than zero");

        require(addresses[2] == atomicizer, "call target must equal address of atomicizer");
        require(addresses[5] == tokenGet[0], "countercall target must equal address of token to give");

        uint256 erc1155Amount = getERC1155AmountFromCalldata(counterdata);
        uint256 new_fill = SafeMath.add(uints[5], uints[0]);
        require(new_fill <= uints[1],"new fill exceeds maximum fill");
        require(SafeMath.mul(tokenIdAndNumeratorDenominator[1], erc1155Amount) == SafeMath.mul(tokenIdAndNumeratorDenominator[2], uints[0]), "wrong ratio");

        checkERC1155Side(counterdata, addresses[4], addresses[1], tokenIdAndNumeratorDenominator[0], erc1155Amount);

        checkETHSideWithOffset(addresses[4], uints[0], tokenIdAndNumeratorDenominator[1], data);

        return new_fill;
    }

    function ERC1155ForETHWithOneFee(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "call must be a direct call");

        (address[2] memory tokenGiveAndFeeRecipient, uint256[4] memory tokenIdAndNumeratorDenominatorAndFee) = abi.decode(extra, (address[2], uint256[4]));

        require(tokenIdAndNumeratorDenominatorAndFee[1] > 0, "numerator must be larger than zero");
        require(tokenIdAndNumeratorDenominatorAndFee[2] > 0, "denominator must be larger than zero");

        require(addresses[2] == tokenGiveAndFeeRecipient[0], "call target must equal address of token to give");
        require(addresses[5] == atomicizer, "countercall target must equal address of atomicizer");

        uint256 erc1155Amount = getERC1155AmountFromCalldata(data);
        uint256 new_fill = SafeMath.add(uints[5], erc1155Amount);
        require(new_fill <= uints[1],"new fill exceeds maximum fill");
        require(SafeMath.mul(tokenIdAndNumeratorDenominatorAndFee[1], uints[0]) == SafeMath.mul(tokenIdAndNumeratorDenominatorAndFee[2] + tokenIdAndNumeratorDenominatorAndFee[3], erc1155Amount), "wrong ratio");

        checkERC1155Side(data, addresses[1], addresses[4], tokenIdAndNumeratorDenominatorAndFee[0], erc1155Amount);

        checkETHSideOneFeeWithOffset(addresses[1], tokenGiveAndFeeRecipient[1], uints[0], tokenIdAndNumeratorDenominatorAndFee[2], tokenIdAndNumeratorDenominatorAndFee[3], counterdata);

        return new_fill;
    }

    function ETHForERC1155WithOneFee(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[2] memory tokenGetAndFeeRecipient, uint256[4] memory tokenIdAndNumeratorDenominatorAndFee) = abi.decode(extra, (address[2], uint256[4]));

        require(tokenIdAndNumeratorDenominatorAndFee[1] > 0, "numerator must be larger than zero");
        require(tokenIdAndNumeratorDenominatorAndFee[2] > 0, "denominator must be larger than zero");

        require(addresses[2] == atomicizer, "call target must equal address of atomicizer");
        require(addresses[5] == tokenGetAndFeeRecipient[0], "countercall target must equal address of token to get");

        uint256 erc1155Amount = getERC1155AmountFromCalldata(counterdata);
        uint256 new_fill = SafeMath.add(uints[5], uints[0]);
        require(new_fill <= uints[1],"new fill exceeds maximum fill");
        require(SafeMath.mul(tokenIdAndNumeratorDenominatorAndFee[1] + tokenIdAndNumeratorDenominatorAndFee[3], erc1155Amount) == SafeMath.mul(tokenIdAndNumeratorDenominatorAndFee[2], uints[0]), "wrong ratio");

        checkERC1155Side(counterdata, addresses[4], addresses[1], tokenIdAndNumeratorDenominatorAndFee[0], erc1155Amount);

        checkETHSideOneFeeWithOffset(addresses[4], tokenGetAndFeeRecipient[1], uints[0], tokenIdAndNumeratorDenominatorAndFee[1], tokenIdAndNumeratorDenominatorAndFee[3], data);

        return new_fill;
    }

    function ERC1155ForETHWithTwoFees(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "call must be a direct call");

        (address[3] memory tokenGiveAndFeeRecipient, uint256[5] memory tokenIdAndNumeratorDenominatorAndFee) = abi.decode(extra, (address[3], uint256[5]));

        require(tokenIdAndNumeratorDenominatorAndFee[1] > 0, "numerator must be larger than zero");
        require(tokenIdAndNumeratorDenominatorAndFee[2] > 0, "denominator must be larger than zero");

        require(addresses[2] == tokenGiveAndFeeRecipient[0], "call target must equal address of token to give");
        require(addresses[5] == atomicizer, "countercall target must equal address of atomicizer");

        uint256 erc1155Amount = getERC1155AmountFromCalldata(data);
        uint256 new_fill = SafeMath.add(uints[5], erc1155Amount);
        require(new_fill <= uints[1],"new fill exceeds maximum fill");
        uint256 totalAmount = tokenIdAndNumeratorDenominatorAndFee[2] + tokenIdAndNumeratorDenominatorAndFee[3] + tokenIdAndNumeratorDenominatorAndFee[4];
        require(SafeMath.mul(tokenIdAndNumeratorDenominatorAndFee[1], uints[0]) == SafeMath.mul(totalAmount, erc1155Amount), "wrong ratio");

        checkERC1155Side(data, addresses[1], addresses[4], tokenIdAndNumeratorDenominatorAndFee[0], erc1155Amount);

        checkETHSideTwoFeesWithOffset(addresses[1], tokenGiveAndFeeRecipient[1], tokenGiveAndFeeRecipient[2], uints[0], tokenIdAndNumeratorDenominatorAndFee[2], tokenIdAndNumeratorDenominatorAndFee[3], tokenIdAndNumeratorDenominatorAndFee[4], counterdata);

        return 1;
    }

    function ETHForERC1155WithTwoFees(bytes memory extra, address[7] memory addresses,
        AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata) public view returns (uint)
    {

        require(howToCalls[0] == AuthenticatedProxy.HowToCall.DelegateCall, "call must be a delegate call");

        (address[3] memory tokenGetAndFeeRecipient, uint256[5] memory tokenIdAndNumeratorDenominatorAndFee) = abi.decode(extra, (address[3], uint256[5]));

        require(tokenIdAndNumeratorDenominatorAndFee[1] > 0, "numerator must be larger than zero");
        require(tokenIdAndNumeratorDenominatorAndFee[2] > 0, "denominator must be larger than zero");

        require(addresses[2] == atomicizer, "call target must equal address of atomicizer");
        require(addresses[5] == tokenGetAndFeeRecipient[0], "countercall target must equal address of token to get");

        uint256 erc1155Amount = getERC1155AmountFromCalldata(counterdata);
        uint256 new_fill = SafeMath.add(uints[5], uints[0]);
        require(new_fill <= uints[1],"new fill exceeds maximum fill");
        uint totalAmount = tokenIdAndNumeratorDenominatorAndFee[1] + tokenIdAndNumeratorDenominatorAndFee[3] + tokenIdAndNumeratorDenominatorAndFee[4];
        require(SafeMath.mul(totalAmount, erc1155Amount) == SafeMath.mul(tokenIdAndNumeratorDenominatorAndFee[2], uints[0]), "wrong ratio");

        checkERC1155Side(counterdata, addresses[4], addresses[1], tokenIdAndNumeratorDenominatorAndFee[0], erc1155Amount);

        checkETHSideTwoFeesWithOffset(addresses[4], tokenGetAndFeeRecipient[1], tokenGetAndFeeRecipient[2], uints[0], tokenIdAndNumeratorDenominatorAndFee[1], tokenIdAndNumeratorDenominatorAndFee[3], tokenIdAndNumeratorDenominatorAndFee[4], data);

        return new_fill;
    }
}