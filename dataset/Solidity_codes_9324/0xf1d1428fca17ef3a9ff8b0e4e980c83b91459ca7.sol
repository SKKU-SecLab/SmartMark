


pragma solidity ^0.8.3;

contract StaticCaller {


    function staticCall(address target, bytes memory data) internal view returns (bool result)
    {

        assembly {
            result := staticcall(gas(), target, add(data, 0x20), mload(data), mload(0x40), 0)
        }
        return result;
    }

    function staticCallUint(address target, bytes memory data) internal view returns (uint ret)
    {

        bool result;
        assembly {
            let size := 0x20
            let free := mload(0x40)
            result := staticcall(gas(), target, add(data, 0x20), mload(data), free, size)
            ret := mload(free)
        }
        require(result, "Static call failed");
        return ret;
    }

}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.3;


contract TokenRecipient{

    event ReceivedEther(address indexed sender, uint amount);
    event ReceivedTokens(address indexed from, uint256 value, address indexed token, bytes extraData);

    function receiveApproval(address from, uint256 value, address token, bytes memory extraData) public {

        IERC20 t = IERC20(token);
        require(t.transferFrom(from, address(this), value), "ERC20 token transfer failed");
        emit ReceivedTokens(from, value, token, extraData);
    }
   
    fallback () payable external {
        emit ReceivedEther(msg.sender, msg.value);
    }
    receive () payable external {
        emit ReceivedEther(msg.sender, msg.value);
    }
}


pragma solidity ^0.8.3;

contract OwnedUpgradeabilityStorage {


    address internal _implementation;
    address private _upgradeabilityOwner;
    
    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;
    }

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}



pragma solidity ^0.8.3;


abstract contract Proxy {
  
    function implementation() virtual public view returns (address);
    function proxyType() virtual public pure returns (uint256 proxyTypeId);
    
    function _fallback() private{
        
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
    
    
    fallback () payable external{
      _fallback();
    }
    
    receive() payable external{
        _fallback();
    }
    
}



pragma solidity ^0.8.3;



contract OwnedUpgradeabilityProxy is Proxy, OwnedUpgradeabilityStorage {

    
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);
    event Upgraded(address indexed implementation);
    
    function implementation() override public view returns (address) {

        return _implementation;
    }
   
    function proxyType() override public pure returns (uint256 proxyTypeId) {

        return 2;
    }
    
    function _upgradeTo(address implem) internal {

        require(_implementation != implem, "Proxy already uses this implementation");
        _implementation = implem;
        emit Upgraded(implem);
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
   
   
    function upgradeTo(address implem) public onlyProxyOwner {

        _upgradeTo(implem);
    }
   
    function upgradeToAndCall(address implem, bytes memory data) payable public onlyProxyOwner {

        upgradeTo(implem);
        (bool success,) = address(this).delegatecall(data);
        require(success, "Call failed after proxy upgrade");
    }
}



pragma solidity ^0.8.3;


contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {



    constructor(address owner, address initialImplementation, bytes memory data)  {
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool success,) = initialImplementation.delegatecall(data);
        require(success, "OwnableDelegateProxy failed implementation");
    }
    

}


pragma solidity ^0.8.3;


interface ProxyRegistryInterface {

    function delegateProxyImplementation() external returns (address);

    function proxies(address owner) external returns (OwnableDelegateProxy);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



pragma solidity ^0.8.3;




contract ProxyRegistry is Ownable, ProxyRegistryInterface {

    
    address public override delegateProxyImplementation;
    mapping(address => OwnableDelegateProxy) public override proxies;
    mapping(address => uint) public pending;
    mapping(address => bool) public contracts;
    uint public DELAY_PERIOD = 2 weeks;

    function startGrantAuthentication (address addr) public onlyOwner{
        require(!contracts[addr] && pending[addr] == 0, "Contract is already allowed in registry, or pending");
        pending[addr] = block.timestamp;
    }

    function endGrantAuthentication (address addr) public onlyOwner{
        require(!contracts[addr] && pending[addr] != 0 && ((pending[addr] + DELAY_PERIOD) < block.timestamp), "Contract is no longer pending or has already been approved by registry");
        pending[addr] = 0;
        contracts[addr] = true;
    }

    function revokeAuthentication (address addr) public onlyOwner{
        contracts[addr] = false;
    }
    
     function grantAuthentication (address addr) public onlyOwner{
        contracts[addr] = true;
    }
   
    function registerProxyOverride() public returns (OwnableDelegateProxy proxy){

        proxy = new OwnableDelegateProxy(msg.sender, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", msg.sender, address(this)));
        proxies[msg.sender] = proxy;
        return proxy;
    }
    
    function registerProxyFor(address user) public returns (OwnableDelegateProxy proxy){

        require(address(proxies[user]) == address(0), "User already has a proxy");
        proxy = new OwnableDelegateProxy(user, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", user, address(this)));
        proxies[user] = proxy;
        return proxy;
    }
    
     function registerProxy() public returns (OwnableDelegateProxy proxy){

        return registerProxyFor(msg.sender);
    }

    function transferAccessTo(address from, address to) public{

        OwnableDelegateProxy proxy = proxies[from];
        require(msg.sender == from, "Proxy transfer can only be called by the proxy");
        require(address(proxies[to]) == address(0), "Proxy transfer has existing proxy as destination");
        delete proxies[from];
        proxies[to] = proxy;
    }

}


pragma solidity ^0.8.3;




contract AuthenticatedProxy is TokenRecipient, OwnedUpgradeabilityStorage {


    bool initialized = false;
    address public user;
    ProxyRegistry public registry;
    bool public revoked;
    enum HowToCall { Call, DelegateCall }
    event Revoked(bool revoked);
    function initialize (address addrUser, ProxyRegistry addrRegistry) public {
        require(!initialized, "Authenticated proxy already initialized");
        initialized = true;
        user = addrUser;
        registry = addrRegistry;
    }
    function setRevoke(bool revoke) public{

        require(msg.sender == user, "Authenticated proxy can only be revoked by its user");
        revoked = revoke;
        emit Revoked(revoke);
    }
    function proxy(address dest, HowToCall howToCall, bytes memory data) public  returns (bool result){

        require(msg.sender == user || (!revoked && registry.contracts(msg.sender)), "Authenticated proxy can only be called by its user, or by a contract authorized by the registry as long as the user has not revoked access");
        bytes memory ret;
        if (howToCall == HowToCall.Call) {
            (result, ret) = dest.call(data);
        } else if (howToCall == HowToCall.DelegateCall) {
            (result, ret) = dest.delegatecall(data);
        }
        return result;
    }
    function proxyAssert(address dest, HowToCall howToCall, bytes memory data) public{

        require(proxy(dest, howToCall, data), "Proxy assertion failed");
    }

}




pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity ^0.8.3;


library ArrayUtils {


    function guardedArrayReplace(bytes memory array, bytes memory desired, bytes memory mask)  internal  pure{

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

    function arrayEq(bytes memory a, bytes memory b) internal  pure  returns (bool){

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

    function arrayDrop(bytes memory _bytes, uint _start) internal  pure  returns (bytes memory){


        uint _length = SafeMath.sub(_bytes.length, _start);
        return arraySlice(_bytes, _start, _length);
    }

    function arrayTake(bytes memory _bytes, uint _length) internal pure returns (bytes memory){


        return arraySlice(_bytes, 0, _length);
    }

    function arraySlice(bytes memory _bytes, uint _start, uint _length) internal pure returns (bytes memory){


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

    function unsafeWriteBytes(uint index, bytes memory source) internal pure returns (uint){

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
    
     function unsafeWriteAddress(uint index, address source) internal pure returns (uint){
        uint conv = uint(uint160(source)) << 0x60;
        assembly {
            mstore(index, conv)
            index := add(index, 0x14)
        }
        return index;
    }

    function unsafeWriteUint(uint index, uint source) internal  pure returns (uint){
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }
   
    function unsafeWriteUint8(uint index, uint8 source) internal pure  returns (uint){
        assembly {
            mstore8(index, source)
            index := add(index, 0x1)
        }
        return index;
    }

}




pragma solidity ^0.8.3;




contract StaticUtil is StaticCaller {


    address public atomicizer;

    function any(bytes memory, address[7] memory, AuthenticatedProxy.HowToCall[2] memory, uint[6] memory, bytes memory, bytes memory)
        public
        pure
        returns (uint)
    {


        return 1;
    }

    function anySingle(bytes memory,  address[7] memory, AuthenticatedProxy.HowToCall, uint[6] memory, bytes memory)
        public
        pure
    {

    }

    function anyNoFill(bytes memory, address[7] memory, AuthenticatedProxy.HowToCall[2] memory, uint[6] memory, bytes memory, bytes memory)
        public
        pure
        returns (uint)
    {


        return 0;
    }

    function anyAddOne(bytes memory, address[7] memory, AuthenticatedProxy.HowToCall[2] memory, uint[6] memory uints, bytes memory, bytes memory)
        public
        pure
        returns (uint)
    {


        return uints[5] + 1;
    }

    function split(bytes memory extra,
                   address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
                   bytes memory data, bytes memory counterdata)
        public
        view
        returns (uint)
    {

        (address[2] memory targets, bytes4[2] memory selectors, bytes memory firstExtradata, bytes memory secondExtradata) = abi.decode(extra, (address[2], bytes4[2], bytes, bytes));


        require(staticCall(targets[0], abi.encodeWithSelector(selectors[0], firstExtradata, addresses, howToCalls[0], uints, data)));

        require(staticCall(targets[1], abi.encodeWithSelector(selectors[1], secondExtradata, [addresses[3], addresses[4], addresses[5], addresses[0], addresses[1], addresses[2], addresses[6]], howToCalls[1], uints, counterdata)));

        return 1;
    }

    function splitAddOne(bytes memory extra,
                   address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
                   bytes memory data, bytes memory counterdata)
        public
        view
        returns (uint)
    {

        split(extra,addresses,howToCalls,uints,data,counterdata);
        return uints[5] + 1;
    }

    function and(bytes memory extra,
                 address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
                 bytes memory data, bytes memory counterdata)
        public
        view
    {

        (address[] memory addrs, bytes4[] memory selectors, uint[] memory extradataLengths, bytes memory extradatas) = abi.decode(extra, (address[], bytes4[], uint[], bytes));

        require(addrs.length == extradataLengths.length);
        
        uint j = 0;
        for (uint i = 0; i < addrs.length; i++) {
            bytes memory extradata = new bytes(extradataLengths[i]);
            for (uint k = 0; k < extradataLengths[i]; k++) {
                extradata[k] = extradatas[j];
                j++;
            }
            require(staticCall(addrs[i], abi.encodeWithSelector(selectors[i], extradata, addresses, howToCalls, uints, data, counterdata)));
        }
    }

    function or(bytes memory extra,
                address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
                bytes memory data, bytes memory counterdata)
        public
        view
    {

        (address[] memory addrs, bytes4[] memory selectors, uint[] memory extradataLengths, bytes memory extradatas) = abi.decode(extra, (address[], bytes4[], uint[], bytes));

        require(addrs.length == extradataLengths.length, "Different number of static call addresses and extradatas");
        
        uint j = 0;
        for (uint i = 0; i < addrs.length; i++) {
            bytes memory extradata = new bytes(extradataLengths[i]);
            for (uint k = 0; k < extradataLengths[i]; k++) {
                extradata[k] = extradatas[j];
                j++;
            }
            if (staticCall(addrs[i], abi.encodeWithSelector(selectors[i], extradata, addresses, howToCalls, uints, data, counterdata))) {
                return;
            }
        }

        revert("No static calls succeeded");
    }

    function sequenceExact(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall howToCall, uint[6] memory uints,
        bytes memory cdata)
        public
        view
    {

        (address[] memory addrs, uint[] memory extradataLengths, bytes4[] memory selectors, bytes memory extradatas) = abi.decode(extra, (address[], uint[], bytes4[], bytes));


        require(addrs.length == extradataLengths.length);

        (address[] memory caddrs, uint[] memory cvals, uint[] memory clengths, bytes memory calldatas) = abi.decode(ArrayUtils.arrayDrop(cdata, 4), (address[], uint[], uint[], bytes));

        require(addresses[2] == atomicizer);
        require(howToCall == AuthenticatedProxy.HowToCall.DelegateCall);
        require(addrs.length == caddrs.length); // Exact calls only

        for (uint i = 0; i < addrs.length; i++) {
            require(cvals[i] == 0);
        }

        sequence(caddrs, clengths, calldatas, addresses, uints, addrs, extradataLengths, selectors, extradatas);
    }

    function dumbSequenceExact(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory cdata, bytes memory)
        public
        view
        returns (uint)
    {

        sequenceExact(extra, addresses, howToCalls[0], uints, cdata);

        return 1;
    }

    function sequenceAnyAfter(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall howToCall, uint[6] memory uints,
        bytes memory cdata)
        public
        view
    {

        (address[] memory addrs, uint[] memory extradataLengths, bytes4[] memory selectors, bytes memory extradatas) = abi.decode(extra, (address[], uint[], bytes4[], bytes));


        require(addrs.length == extradataLengths.length);

        (address[] memory caddrs, uint[] memory cvals, uint[] memory clengths, bytes memory calldatas) = abi.decode(ArrayUtils.arrayDrop(cdata, 4), (address[], uint[], uint[], bytes));

        require(addresses[2] == atomicizer);
        require(howToCall == AuthenticatedProxy.HowToCall.DelegateCall);
        require(addrs.length <= caddrs.length); // Extra calls OK

        for (uint i = 0; i < addrs.length; i++) {
            require(cvals[i] == 0);
        }

        sequence(caddrs, clengths, calldatas, addresses, uints, addrs, extradataLengths, selectors, extradatas);
    }

    function sequence(
        address[] memory caddrs, uint[] memory clengths, bytes memory calldatas,
        address[7] memory addresses, uint[6] memory uints,
        address[] memory addrs, uint[] memory extradataLengths, bytes4[] memory selectors, bytes memory extradatas)
        internal
        view
    {

        uint j = 0;
        uint l = 0;
        for (uint i = 0; i < addrs.length; i++) {
            bytes memory extradata = new bytes(extradataLengths[i]);
            for (uint k = 0; k < extradataLengths[i]; k++) {
                extradata[k] = extradatas[j];
                j++;
            }
            bytes memory data = new bytes(clengths[i]);
            for (uint m = 0; m < clengths[i]; m++) {
                data[m] = calldatas[l];
                l++;
            }
            addresses[2] = caddrs[i];
            require(staticCall(addrs[i], abi.encodeWithSelector(selectors[i], extradata, addresses, AuthenticatedProxy.HowToCall.Call, uints, data)));
        }
        require(j == extradatas.length);
    }

}



pragma solidity ^0.8.3;




contract StaticERC1155 {


function transferERC1155Exact(bytes memory extra,
	address[7] memory addresses, AuthenticatedProxy.HowToCall howToCall, uint[6] memory,
	bytes memory data)
	public
	pure
{

	(address token, uint256 tokenId, uint256 amount) = abi.decode(extra, (address, uint256, uint256));

	require(addresses[2] == token);
	require(howToCall == AuthenticatedProxy.HowToCall.Call);
	require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", addresses[1], addresses[4], tokenId, amount, "")));
}

function swapOneForOneERC1155(bytes memory extra,
	address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
	bytes memory data, bytes memory counterdata)
	public
	pure
	returns (uint)
{

	require(uints[0] == 0);

	(address[2] memory tokenGiveGet, uint256[2] memory nftGiveGet, uint256[2] memory nftAmounts) = abi.decode(extra, (address[2], uint256[2], uint256[2]));

	require(addresses[2] == tokenGiveGet[0], "ERC1155: call target must equal address of token to give");
	require(nftAmounts[0] > 0,"ERC1155: give amount must be larger than zero");
	require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "ERC1155: call must be a direct call");
	require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", addresses[1], addresses[4], nftGiveGet[0], nftAmounts[0], "")));

	require(addresses[5] == tokenGiveGet[1], "ERC1155: countercall target must equal address of token to get");
	require(nftAmounts[1] > 0,"ERC1155: take amount must be larger than zero");
	require(howToCalls[1] == AuthenticatedProxy.HowToCall.Call, "ERC1155: countercall must be a direct call");
	require(ArrayUtils.arrayEq(counterdata, abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", addresses[4], addresses[1], nftGiveGet[1], nftAmounts[1], "")));

	return 1;
}

function swapOneForOneERC1155Decoding(bytes memory extra,
	address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
	bytes memory data, bytes memory counterdata)
	public
	pure
	returns (uint)
{

	bytes memory sig = ArrayUtils.arrayTake(abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)"), 4);

	require(uints[0] == 0);

	(address[2] memory tokenGiveGet, uint256[2] memory nftGiveGet, uint256[2] memory nftAmounts) = abi.decode(extra, (address[2],uint256[2],uint256[2]));

	require(addresses[2] == tokenGiveGet[0], "ERC1155: call target must equal address of token to give");
	require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "ERC1155: call must be a direct call");
	require(ArrayUtils.arrayEq(sig, ArrayUtils.arrayTake(data, 4)));
	require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", addresses[1], addresses[4], nftGiveGet[0], nftAmounts[0], "")));
	require(ArrayUtils.arrayEq(counterdata, abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", addresses[4], addresses[1], nftGiveGet[1], nftAmounts[1], "")));

	return 1;
}

}



pragma solidity ^0.8.3;




contract StaticERC721 {


    function transferERC721Exact(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall howToCall, uint[6] memory,
        bytes memory data)
        public
        pure
    {

        (address token, uint tokenId) = abi.decode(extra, (address, uint));

        require(addresses[2] == token);
        require(howToCall == AuthenticatedProxy.HowToCall.Call);
        require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("transferFrom(address,address,uint256)", addresses[1], addresses[4], tokenId)));
    }

    function swapOneForOneERC721(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata)
        public
        pure
        returns (uint)
    {

        require(uints[0] == 0);

        (address[2] memory tokenGiveGet, uint[2] memory nftGiveGet) = abi.decode(extra, (address[2],uint[2]));

        require(addresses[2] == tokenGiveGet[0], "ERC721: call target must equal address of token to give");
        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "ERC721: call must be a direct call");
        require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("transferFrom(address,address,uint256)", addresses[1], addresses[4], nftGiveGet[0])));

        require(addresses[5] == tokenGiveGet[1], "ERC721: countercall target must equal address of token to get");
        require(howToCalls[1] == AuthenticatedProxy.HowToCall.Call, "ERC721: countercall must be a direct call");
        require(ArrayUtils.arrayEq(counterdata, abi.encodeWithSignature("transferFrom(address,address,uint256)", addresses[4], addresses[1], nftGiveGet[1])));

        return 1;
    }

    function swapOneForOneERC721Decoding(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata)
        public
        pure
        returns (uint)
    {

        bytes memory sig = ArrayUtils.arrayTake(abi.encodeWithSignature("transferFrom(address,address,uint256)"), 4);

        require(uints[0] == 0);

        (address[2] memory tokenGiveGet, uint[2] memory nftGiveGet) = abi.decode(extra, (address[2],uint[2]));

        require(addresses[2] == tokenGiveGet[0], "ERC721: call target must equal address of token to give");
        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call, "ERC721: call must be a direct call");
        require(ArrayUtils.arrayEq(sig, ArrayUtils.arrayTake(data, 4)));
        (address callFrom, address callTo, uint256 nftGive) = abi.decode(ArrayUtils.arrayDrop(data, 4), (address, address, uint256));
        require(callFrom == addresses[1]);
        require(callTo == addresses[4]);
        require(nftGive == nftGiveGet[0]);

        require(addresses[5] == tokenGiveGet[1], "ERC721: countercall target must equal address of token to get");
        require(howToCalls[1] == AuthenticatedProxy.HowToCall.Call, "ERC721: countercall must be a direct call");
        require(ArrayUtils.arrayEq(sig, ArrayUtils.arrayTake(counterdata, 4)));
        (address countercallFrom, address countercallTo, uint256 nftGet) = abi.decode(ArrayUtils.arrayDrop(counterdata, 4), (address, address, uint256));
        require(countercallFrom == addresses[4]);
        require(countercallTo == addresses[1]);
        require(nftGet == nftGiveGet[1]);

        return 1;
    }

}



pragma solidity ^0.8.3;




contract StaticERC20 {


    function transferERC20Exact(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall howToCall, uint[6] memory,
        bytes memory data)
        public
        pure
    {

        (address token, uint amount) = abi.decode(extra, (address, uint));

        require(addresses[2] == token);
        require(howToCall == AuthenticatedProxy.HowToCall.Call);
        require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("transferFrom(address,address,uint256)", addresses[1], addresses[4], amount)));
    }

    function swapExact(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata)
        public
        pure
        returns (uint)
    {

        require(uints[0] == 0);

        (address[2] memory tokenGiveGet, uint[2] memory amountGiveGet) = abi.decode(extra, (address[2], uint[2]));

        require(addresses[2] == tokenGiveGet[0]);
        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call);
        require(ArrayUtils.arrayEq(data, abi.encodeWithSignature("transferFrom(address,address,uint256)", addresses[1], addresses[4], amountGiveGet[0])));

        require(addresses[5] == tokenGiveGet[1]);
        require(howToCalls[1] == AuthenticatedProxy.HowToCall.Call);
        require(ArrayUtils.arrayEq(counterdata, abi.encodeWithSignature("transferFrom(address,address,uint256)", addresses[4], addresses[1], amountGiveGet[1])));

        return 1;
    }

    function swapForever(bytes memory extra,
        address[7] memory addresses, AuthenticatedProxy.HowToCall[2] memory howToCalls, uint[6] memory uints,
        bytes memory data, bytes memory counterdata)
        public
        pure
        returns (uint)
    {

        bytes memory sig = ArrayUtils.arrayTake(abi.encodeWithSignature("transferFrom(address,address,uint256)"), 4);

        require(uints[0] == 0);

        (address[2] memory tokenGiveGet, uint[2] memory numeratorDenominator) = abi.decode(extra, (address[2], uint[2]));

        require(addresses[2] == tokenGiveGet[0]);
        require(howToCalls[0] == AuthenticatedProxy.HowToCall.Call);
        require(ArrayUtils.arrayEq(sig, ArrayUtils.arrayTake(data, 4)));
        (address callFrom, address callTo, uint256 amountGive) = abi.decode(ArrayUtils.arrayDrop(data, 4), (address, address, uint256));
        require(callFrom == addresses[1]);
        require(callTo == addresses[4]);

        require(addresses[5] == tokenGiveGet[1]);
        require(howToCalls[1] == AuthenticatedProxy.HowToCall.Call);
        require(ArrayUtils.arrayEq(sig, ArrayUtils.arrayTake(counterdata, 4)));
        (address countercallFrom, address countercallTo, uint256 amountGet) = abi.decode(ArrayUtils.arrayDrop(counterdata, 4), (address, address, uint256));
        require(countercallFrom == addresses[4]);
        require(countercallTo == addresses[1]);

        require(SafeMath.mul(amountGet, numeratorDenominator[1]) >= SafeMath.mul(amountGive, numeratorDenominator[0]));

        return 1;
    }


}



pragma solidity ^0.8.3;





contract WyvernStatic is StaticERC20, StaticERC721, StaticERC1155, StaticUtil {


    string public constant name = "Wyvern Static";

    constructor (address atomicizerAddress){
        atomicizer = atomicizerAddress;
    }

    function test () 
        public
        pure
    {
    }
}