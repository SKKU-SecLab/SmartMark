
pragma solidity ^0.7.0;
pragma experimental SMTChecker;


abstract contract OwnableIf {

    modifier onlyOwner() {
        require(msg.sender == _owner(), "not owner......");
        _;
    }

    function _owner() view virtual public returns (address);
}

pragma solidity ^0.7.0;




contract Ownable is OwnableIf {

    address public owner;

    function _owner() view override public returns (address){

        return owner;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {
        owner = msg.sender;
    }



    function transferOwnership(address _newOwner) virtual public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0), "invalid _newOwner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}



pragma solidity ^0.7.0;




contract Claimable is Ownable {

    address public pendingOwner;

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner, "no permission");
        _;
    }

    function transferOwnership(address newOwner) override public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

pragma solidity ^0.7.0;

abstract contract ERC20If {
    function totalSupply() virtual public view returns (uint256);

    function balanceOf(address _who) virtual public view returns (uint256);

    function transfer(address _to, uint256 _value) virtual public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address _owner, address _spender) virtual public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool);

    function approve(address _spender, uint256 _value) virtual public returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.7.0;



abstract contract CanReclaimToken is OwnableIf {

    function reclaimToken(ERC20If _token) external onlyOwner {
        uint256 balance = _token.balanceOf((address)(this));
        require(_token.transfer(_owner(), balance));
    }

}


pragma solidity ^0.7.0;

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
pragma solidity ^0.7.0;

contract MTokenWrap is Ownable, CanReclaimToken {

    using SafeMath for uint256;
    ERC20If public mtoken;
    string public nativeCoinType;
    address public mtokenRepository;
    uint256 public wrapSeq;
    mapping(bytes32 => uint256) public wrapSeqMap;


    uint256 constant rate_precision = 1e10;


    function _mtokenRepositorySet(address newMtokenRepository)
        public
        onlyOwner
    {

        require(newMtokenRepository != (address)(0), "invalid addr");
        mtokenRepository = newMtokenRepository;
    }

    function wrapHash(string memory nativeCoinAddress, string memory nativeTxId)
        public
        pure
        returns (bytes32)
    {

        return keccak256(abi.encode(nativeCoinAddress, nativeTxId));
    }

    event SETUP(
        address _mtoken,
        string _nativeCoinType,
        address _mtokenRepository
    );

    function setup(
        address _mtoken,
        string memory _nativeCoinType,
        address _mtokenRepository,
        address _initOwner
    )
        public
        returns (
            bool
        )
    {

        if (wrapSeq <= 0) {
            wrapSeq = 1;
            mtoken = (ERC20If)(_mtoken);
            nativeCoinType = _nativeCoinType;
            mtokenRepository = _mtokenRepository;
            owner = _initOwner;
            emit SETUP(_mtoken, _nativeCoinType, _mtokenRepository);
            emit OwnershipTransferred(_owner(), _initOwner);
            return true;
        }
        return false;
    }

    function uintToString(uint256 _i) public pure returns (string memory) {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    function toHexString(bytes memory data)
        public
        pure
        returns (string memory)
    {

        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function toHexString(address account) public pure returns (string memory) {

        return toHexString(abi.encodePacked(account));
    }

    function calcMTokenAmount(
        uint256 amt,
        uint256 fee,
        uint256 rate
    ) public pure returns (uint256) {

        return amt.sub(fee).mul(rate).div(rate_precision);
    }

    function encode(
        address receiveMTokenAddress,
        string memory nativeCoinAddress,
        uint256 amt,
        uint256 fee,
        uint256 rate,
        uint64 deadline //TODO  暂时设置为public
    ) public view returns (bytes memory) {

        return
            abi.encodePacked(
                "wrap ",
                nativeCoinType,
                "\nto:",
                toHexString(receiveMTokenAddress),
                "\namt:",
                uintToString(amt),
                "\nfee:",
                uintToString(fee),
                "\nrate:",
                uintToString(rate),
                "\ndeadline:",
                uintToString(deadline),
                "\naddr:",
                nativeCoinAddress
            );
    }

    function personalMessage(bytes memory _msg)
        public
        pure
        returns (bytes memory)
    {

        return
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n",
                uintToString(_msg.length),
                _msg
            );
    }

    function recoverPersonalSignature(
        bytes32 r,
        bytes32 s,
        uint8 v,
        bytes memory text
    ) public pure returns (address) {

        bytes32 h = keccak256(personalMessage(text));
        return ecrecover(h, v, r, s);
    }

    function wrap(
        address ethAccount,
        address receiveMTokenAddress,
        string memory nativeCoinAddress,
        string memory nativeTxId,
        uint256 amt,
        uint256 fee,
        uint256 rate,
        uint64 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public onlyOwner returns (bool) {

        uint256 mtokenAmount = calcMTokenAmount(amt, fee, rate);
        {
            bytes memory text =
                encode(
                    receiveMTokenAddress,
                    nativeCoinAddress,
                    amt,
                    fee,
                    rate,
                    deadline
                );

            address addr = recoverPersonalSignature(r, s, v, text);
            require(addr == ethAccount, "invalid signature");
        }
        require(
            wrapSeqMap[wrapHash(nativeCoinAddress, nativeTxId)] <= 0,
            "wrap dup."
        );
        wrapSeqMap[wrapHash(nativeCoinAddress, nativeTxId)] = wrapSeq;
        wrapSeq = wrapSeq + 1;

        require(
            mtoken.transferFrom(
                mtokenRepository,
                receiveMTokenAddress,
                mtokenAmount
            ),
            "transferFrom failed"
        );
        emit WRAP_EVENT(
            wrapSeq,
            ethAccount,
            receiveMTokenAddress,
            nativeCoinAddress,
            nativeTxId,
            amt,fee,rate,
            deadline,
            r,
            s,
            v
        );

        return true;
    }

    event WRAP_EVENT(
        uint256 indexed wrapSeq,
        address ethAccount,
        address receiveMTokenAddress,
        string nativeCoinAddress,
        string nativeTxId,
        uint256 amt,
        uint256 fee,
        uint256 rate,
        uint64 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    );
}
pragma solidity ^0.7.0;
// pragma experimental SMTChecker;

contract MTokenDeSwap is MTokenWrap {

    using SafeMath for uint256;

    enum OrderStatus {PENDING, CANCELED, APPROVED, FINISHED}

    function getStatusString(OrderStatus status)
        internal
        pure
        returns (string memory)
    {

        if (status == OrderStatus.PENDING) {
            return "pending";
        } else if (status == OrderStatus.CANCELED) {
            return "canceled";
        } else if (status == OrderStatus.APPROVED) {
            return "approved";
        } else if (status == OrderStatus.FINISHED) {
            return "finished";
        } else {
            return "unknown";
        }
    }

    struct UnWrapOrder {
        address ethAccount;
        uint256 nativeCoinAmount;
        uint256 mtokenAmount;
        string nativeCoinAddress;
        string nativeTxId;
        uint256 requestBlockNo;
        uint256 confirmedBlockNo;
        OrderStatus status;
        uint256 fee;
        uint256 rate;
    }

    UnWrapOrder[] public unWrapOrders;
    bool public paused = false;
    modifier notPaused() {

        require(!paused, "paused");
        _;
    }

    function pause(bool _paused) public onlyOwner returns (bool) {

        paused = _paused;
        return true;
    }

    function getUnWrapOrderNum() public view returns (uint256) {

        return unWrapOrders.length;
    }

    function getUnWrapOrderInfo(uint256 seq)
        public
        view
        returns (
            address ethAccount,
            uint256 nativeCoinAmount,
            uint256 mtokenAmount,
            string memory nativeCoinAddress,
            string memory nativeTxId,
            uint256 requestBlockNo,
            uint256 confirmedBlockNo,
            string memory status
        )
    {

        require(seq < unWrapOrders.length, "invalid seq");
        UnWrapOrder memory order = unWrapOrders[seq];
        ethAccount = order.ethAccount;
        nativeCoinAmount = order.nativeCoinAmount;
        mtokenAmount = order.mtokenAmount;
        nativeCoinAddress = order.nativeCoinAddress;
        nativeTxId = order.nativeTxId;
        requestBlockNo = order.requestBlockNo;
        confirmedBlockNo = order.confirmedBlockNo;
        status = getStatusString(order.status);
    }

    function calcUnWrapAmount(
        uint256 amt,
        uint256 fee,
        uint256 rate
    ) public pure returns (uint256) {

        return amt.sub(fee).mul(rate).div(rate_precision);
    }

    function unWrap(
        uint256 amt,
        uint256 fee,
        uint256 rate,
        string memory nativeCoinAddress
    ) public notPaused returns (bool) {

        address ethAccount = msg.sender;
        uint256 mtokenAmount = amt;
        uint256 nativeCoinAmount = calcUnWrapAmount(amt, fee, rate);
        require(
            mtoken.transferFrom(ethAccount, mtokenRepository, mtokenAmount),
            "transferFrom failed"
        );
        uint256 seq = unWrapOrders.length;
        unWrapOrders.push(
            UnWrapOrder({
                ethAccount: ethAccount,
                nativeCoinAmount: nativeCoinAmount,
                mtokenAmount: mtokenAmount,
                nativeCoinAddress: nativeCoinAddress,
                requestBlockNo: block.number,
                status: OrderStatus.PENDING,
                nativeTxId: "",
                confirmedBlockNo: 0,
                fee: fee,
                rate: rate
            })
        );
        emit UNWRAP_REQUEST(seq, ethAccount, nativeCoinAddress, amt, fee, rate);

        return true;
    }

    event UNWRAP_REQUEST(
        uint256 indexed seq,
        address ethAccount,
        string nativeCoinAddress,
        uint256 amt,
        uint256 fee,
        uint256 rate
    );

    event UNWRAP_APPROVE(uint256 indexed seq);

    function approveUnWrapOrder(
        uint256 seq,
        address ethAccount,
        uint256 nativeCoinAmount,
        uint256 mtokenAmount,
        string memory nativeCoinAddress
    ) public onlyOwner returns (bool) {

        require(unWrapOrders.length > seq, "invalid seq");
        UnWrapOrder memory order = unWrapOrders[seq];
        require(order.status == OrderStatus.PENDING, "status not pending");
        require(ethAccount == order.ethAccount, "invalid param1");
        require(mtokenAmount == order.mtokenAmount, "invalid param2");
        require(nativeCoinAmount == order.nativeCoinAmount, "invalid param3");
        require(
            stringEquals(nativeCoinAddress, order.nativeCoinAddress),
            "invalid param4"
        );

        unWrapOrders[seq].status = OrderStatus.APPROVED;
        emit UNWRAP_APPROVE(seq);
        return true;
    }

    event UNWRAP_CANCEL(uint256 indexed seq);

    function cancelUnWrapOrder(uint256 seq) public returns (bool) {

        require(unWrapOrders.length > seq, "invalid seq");
        UnWrapOrder memory order = unWrapOrders[seq];
        require(msg.sender == order.ethAccount, "invalid auth.");
        require(order.status == OrderStatus.PENDING, "status not pending");
        unWrapOrders[seq].status = OrderStatus.CANCELED;

        require(
            mtoken.transferFrom(
                mtokenRepository,
                order.ethAccount,
                order.mtokenAmount
            ),
            "transferFrom failed"
        );

        emit UNWRAP_CANCEL(seq);
        return true;
    }

    function stringEquals(string memory s1, string memory s2)
        public
        pure
        returns (bool)
    {

        return (keccak256(abi.encodePacked(s1)) ==
            keccak256(abi.encodePacked(s2)));
    }

    event UNWRAP_FINISH(uint256 indexed seq, string nativeTxId);

    function finishUnWrapOrder(uint256 seq, string memory nativeTxId)
        public
        onlyOwner
        returns (bool)
    {

        require(unWrapOrders.length > seq, "invalid seq");
        UnWrapOrder memory order = unWrapOrders[seq];
        require(order.status == OrderStatus.APPROVED, "status not approved");

        unWrapOrders[seq].status = OrderStatus.FINISHED;
        unWrapOrders[seq].nativeTxId = nativeTxId;
        unWrapOrders[seq].confirmedBlockNo = block.number;
        emit UNWRAP_FINISH(seq, nativeTxId);
        return true;
    }
}

pragma solidity ^0.7.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
}

pragma solidity ^0.7.0;


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal view virtual override returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal virtual {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

pragma solidity ^0.7.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address admin_, bytes memory _data) payable UpgradeableProxy(_logic, "") {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);

         if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _admin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external virtual ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable virtual ifAdmin {

        _upgradeTo(newImplementation);
        Address.functionDelegateCall(newImplementation, data);
    }

    function _admin() internal view virtual returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}
pragma solidity ^0.7.0;

contract MTokenDeSwapFactory is Claimable, CanReclaimToken {

    mapping(bytes32 => address) public deSwaps;

    function getDeSwap(string memory _nativeCoinType)
        public
        view
        returns (address)
    {

        bytes32 nativeCoinTypeHash =
            keccak256(abi.encodePacked(_nativeCoinType));
        return deSwaps[nativeCoinTypeHash];
    }

    function deployDeSwap(
        address _mtoken,
        string memory _nativeCoinType,
        address _mtokenRepository,
        address _operator
    ) public onlyOwner returns (bool) {

        bytes32 nativeCoinTypeHash =
            keccak256(abi.encodePacked(_nativeCoinType));
        require(_operator!=_owner(), "owner same as _operator");
        require(deSwaps[nativeCoinTypeHash] == (address)(0), "deEx exists.");
        MTokenDeSwap mtokenDeSwap = new MTokenDeSwap();
        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(
                (address)(mtokenDeSwap),
                (address)(this),
                abi.encodeWithSignature(
                    "setup(address,string,address,address)",
                    _mtoken,
                    _nativeCoinType,
                    _mtokenRepository,
                    _operator
                )
            );

        proxy.changeAdmin(_owner());
        deSwaps[nativeCoinTypeHash] = (address)(proxy);

        return true;
    }
}
