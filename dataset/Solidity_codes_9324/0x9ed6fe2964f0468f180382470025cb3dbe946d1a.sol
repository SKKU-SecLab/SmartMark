
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}pragma experimental ABIEncoderV2;
pragma solidity ^0.8.10;


contract ETHDubaiTicket {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;

    Counters.Counter private _tokenIds;
    address payable public owner;

    uint256[20] public ticketOptions;
    Settings public settings;
    event Log(address indexed sender, string message);
    event Lint(uint256 indexed tokenId, string message);
    event LDiscount(address indexed sender, Discount discount, string message);
    event LMint(address indexed sender, MintInfo[] mintInfo, string message);
    enum Ticket {
        CONFERENCE,
        HOTEL_CONFERENCE,
        WORKSHOP1_AND_PRE_PARTY,
        WORKSHOP2_AND_PRE_PARTY,
        WORKSHOP3_AND_PRE_PARTY,
        HOTEL_WORKSHOP1_AND_PRE_PARTY,
        HOTEL_WORKSHOP2_AND_PRE_PARTY,
        HOTEL_WORKSHOP3_AND_PRE_PARTY
    }
    EnumerableSet.AddressSet private daosAddresses;
    mapping(address => uint256) public daosQty;
    mapping(address => Counters.Counter) public daosUsed;
    mapping(address => uint256) public daosMinBalance;
    mapping(address => uint256) public daosDiscount;
    mapping(address => uint256) public daosMinTotal;
    mapping(address => Discount) public discounts;

    event LTicketSettings(
        TicketSettings indexed ticketSettings,
        string message
    );
    uint256[] private initDiscounts;

    constructor() {
        emit Log(msg.sender, "created");
        owner = payable(msg.sender);
        settings.maxMint = 50;

        settings.ticketSettings = TicketSettings("early");

        ticketOptions[uint256(Ticket.CONFERENCE)] = 0.07 ether;
        ticketOptions[uint256(Ticket.HOTEL_CONFERENCE)] = 0.17 ether;
        ticketOptions[uint256(Ticket.WORKSHOP1_AND_PRE_PARTY)] = 0.12 ether;
        ticketOptions[uint256(Ticket.WORKSHOP2_AND_PRE_PARTY)] = 0.12 ether;
        ticketOptions[uint256(Ticket.WORKSHOP3_AND_PRE_PARTY)] = 0.12 ether;
        ticketOptions[
            uint256(Ticket.HOTEL_WORKSHOP1_AND_PRE_PARTY)
        ] = 0.32 ether;
        ticketOptions[
            uint256(Ticket.HOTEL_WORKSHOP2_AND_PRE_PARTY)
        ] = 0.32 ether;
        ticketOptions[
            uint256(Ticket.HOTEL_WORKSHOP3_AND_PRE_PARTY)
        ] = 0.32 ether;
        initDiscounts = [0, 2, 3, 4];
        setDiscount(
            0x114f2661D4eE895AE65cbbD302B7EdB32c5667e3,
            initDiscounts,
            15
        );
        setDiscount(
            0xe32bAC6E393199bb3881187F4feb52e28e973870,
            initDiscounts,
            15
        );
        setDiscount(
            0x3955Fc91B098db549947c3c646Cf1223aE4E08b5,
            initDiscounts,
            15
        );
        setDiscount(
            0x402A5F0e42B0134aBeC851b2656F31F7ee7A0ee4,
            initDiscounts,
            15
        );
        setDiscount(
            0x4C8418E3f8c1390dBc72314b642d5255FDa14dd8,
            initDiscounts,
            15
        );
        setDiscount(
            0x8588Be209727C471d31d77B844ED411BA068f73B,
            initDiscounts,
            15
        );
        setDiscount(
            0xc840D0A9bb73e1C76915c013804B7b6Cb67462ec,
            initDiscounts,
            15
        );
        setDiscount(
            0xF1E1F290A7167132725FAA917b119e16F2BC5fA3,
            initDiscounts,
            15
        );
        setDiscount(
            0x434Aa19BE9925388B114C8c814F74E93761Ed682,
            initDiscounts,
            15
        );
        setDiscount(
            0x43b30c00AA87967eB665Ed8d5558e06f55611344,
            initDiscounts,
            15
        );
        setDiscount(
            0x1A0d4d5b4F7F51e71A88Bf2b70177836ac893225,
            initDiscounts,
            15
        );
        setDiscount(
            0x6B703a7FD20efe6F5BADfdd57cc8Ec97FA3A1910,
            initDiscounts,
            15
        );
        setDiscount(
            0x524aD4d7da566383d993073193f81bB596aC6639,
            initDiscounts,
            15
        );
        setDiscount(
            0xC8F78497C72A2940Ca5bC1795c79d48d42B246A4,
            initDiscounts,
            15
        );
        setDiscount(
            0x1fa4aA8476D547f83EcC7f817CBA662f1F58F807,
            initDiscounts,
            15
        );
        setDiscount(
            0x98cdbFee2C5b945be3AdCA4A1815622c64E07D7e,
            initDiscounts,
            15
        );
        setDiscount(
            0x858989924f72DdeB80526a68EfB15677E8Cfad64,
            initDiscounts,
            15
        );
        setDiscount(
            0xc3F4DC5D0c288f2b83b63c44A810baBCe6d69dA4,
            initDiscounts,
            15
        );
    }

    struct Discount {
        uint256[] ticketOptions;
        uint256 amount;
    }

    struct TicketSettings {
        string name;
    }
    struct MintInfo {
        string ticketCode;
        uint256 ticketOption;
        string specialStatus;
    }
    struct Settings {
        TicketSettings ticketSettings;
        uint256 maxMint;
    }

    function setDiscount(
        address buyer,
        uint256[] memory newDiscounts,
        uint256 amount
    ) public returns (bool) {
        require(msg.sender == owner, "only owner");

        Discount memory d = Discount(newDiscounts, amount);
        emit LDiscount(buyer, d, "set discount buyer");
        discounts[buyer] = d;
        return true;
    }

    function setMaxMint(uint256 max) public returns (uint256) {
        require(msg.sender == owner, "only owner");
        settings.maxMint = max;
        emit Lint(max, "setMaxMint");
        return max;
    }

    function setTicketOptions(uint256 ticketOptionId, uint256 amount)
        public
        returns (bool)
    {
        require(msg.sender == owner, "only owner");
        ticketOptions[ticketOptionId] = amount;
        return true;
    }

    function setDao(
        address dao,
        uint256 qty,
        uint256 discount,
        uint256 minBalance,
        uint256 minTotal
    ) public returns (bool) {
        require(msg.sender == owner, "only owner");
        require(Address.isContract(dao), "nc");
        if (!daosAddresses.contains(dao)) {
            daosAddresses.add(dao);
        }
        daosQty[dao] = qty;
        daosMinBalance[dao] = minBalance;
        daosDiscount[dao] = discount;
        daosMinTotal[dao] = minTotal;
        return true;
    }

    function setTicketSettings(string memory name) public returns (bool) {
        require(msg.sender == owner, "only owner");
        settings.ticketSettings.name = name;
        emit LTicketSettings(settings.ticketSettings, "setTicketSettings");
        return true;
    }

    function cmpStr(string memory idopt, string memory opt)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((idopt))) ==
            keccak256(abi.encodePacked((opt))));
    }

    function getDiscount(address sender, uint256 ticketOption)
        public
        view
        returns (uint256[2] memory)
    {
        Discount memory discount = discounts[sender];
        uint256 amount = discounts[sender].amount;
        uint256 total = 0;
        bool hasDiscount = false;
        total = total + ticketOptions[ticketOption];

        if (amount > 0) {
            for (uint256 j = 0; j < discount.ticketOptions.length; j++) {
                if (discount.ticketOptions[j] == ticketOption) {
                    hasDiscount = true;
                }
            }
            if (!hasDiscount) {
                amount = 0;
            }
        }
        return [amount, total];
    }

    function getDaoDiscountView(uint256 amount)
        internal
        view
        returns (uint256[2] memory)
    {
        uint256 minTotal = 0;
        if (amount == 0) {
            uint256 b = 0;

            for (uint256 j = 0; j < daosAddresses.length(); j++) {
                address dao = daosAddresses.at(j);
                if (daosDiscount[dao] > 0) {
                    ERC20 token = ERC20(dao);
                    b = token.balanceOf(msg.sender);
                    if (
                        b > daosMinBalance[dao] &&
                        daosUsed[dao].current() < daosQty[dao] &&
                        amount == 0
                    ) {
                        amount = daosDiscount[dao];
                        minTotal = daosMinTotal[dao];
                    }
                }
            }
        }
        return [amount, minTotal];
    }

    function getDaoDiscount(uint256 amount)
        internal
        returns (uint256[2] memory)
    {
        uint256 minTotal = 0;
        if (amount == 0) {
            uint256 b = 0;

            for (uint256 j = 0; j < daosAddresses.length(); j++) {
                address dao = daosAddresses.at(j);
                if (daosDiscount[dao] > 0) {
                    ERC20 token = ERC20(dao);
                    b = token.balanceOf(msg.sender);
                    if (
                        b > daosMinBalance[dao] &&
                        daosUsed[dao].current() < daosQty[dao] &&
                        amount == 0
                    ) {
                        amount = daosDiscount[dao];
                        daosUsed[dao].increment();
                        minTotal = daosMinTotal[dao];
                    }
                }
            }
        }
        return [amount, minTotal];
    }

    function getPrice(address sender, uint256 ticketOption)
        public
        returns (uint256)
    {
        uint256[2] memory amountAndTotal = getDiscount(sender, ticketOption);
        uint256 total = amountAndTotal[1];
        uint256[2] memory amountAndMinTotal = getDaoDiscount(amountAndTotal[0]);
        require(total > 0, "total = 0");
        if (amountAndMinTotal[0] > 0 && total >= amountAndMinTotal[1]) {
            total = total - ((total * amountAndMinTotal[0]) / 100);
        }

        return total;
    }

    function getPriceView(address sender, uint256 ticketOption)
        public
        view
        returns (uint256)
    {
        uint256[2] memory amountAndTotal = getDiscount(sender, ticketOption);
        uint256 total = amountAndTotal[1];
        uint256[2] memory amountAndMinTotal = getDaoDiscountView(
            amountAndTotal[0]
        );
        require(total > 0, "total = 0");
        if (amountAndMinTotal[0] > 0 && total >= amountAndMinTotal[1]) {
            total = total - ((total * amountAndMinTotal[0]) / 100);
        }

        return total;
    }

    function totalPrice(MintInfo[] memory mIs) public view returns (uint256) {
        uint256 t = 0;
        for (uint256 i = 0; i < mIs.length; i++) {
            t += getPriceView(msg.sender, mIs[i].ticketOption);
        }
        return t;
    }

    function totalPriceInternal(MintInfo[] memory mIs)
        internal
        returns (uint256)
    {
        uint256 t = 0;
        for (uint256 i = 0; i < mIs.length; i++) {
            t += getPrice(msg.sender, mIs[i].ticketOption);
        }
        return t;
    }

    function mintItem(MintInfo[] memory mintInfos)
        public
        payable
        returns (string memory)
    {
        require(
            _tokenIds.current() + mintInfos.length <= settings.maxMint,
            "sold out"
        );
        uint256 total = 0;

        string memory ids = "";
        for (uint256 i = 0; i < mintInfos.length; i++) {
            require(
                keccak256(abi.encodePacked(mintInfos[i].specialStatus)) ==
                    keccak256(abi.encodePacked("")) ||
                    msg.sender == owner,
                "only owner"
            );
            total += getPrice(msg.sender, mintInfos[i].ticketOption);
            _tokenIds.increment();
        }

        require(msg.value >= total, "price too low");
        return ids;
    }

    function mintItemNoDiscount(MintInfo[] memory mintInfos)
        public
        payable
        returns (string memory)
    {
        require(
            _tokenIds.current() + mintInfos.length <= settings.maxMint,
            "sold out"
        );
        uint256 total = 0;

        string memory ids = "";
        for (uint256 i = 0; i < mintInfos.length; i++) {
            require(
                keccak256(abi.encodePacked(mintInfos[i].specialStatus)) ==
                    keccak256(abi.encodePacked("")) ||
                    msg.sender == owner,
                "only owner"
            );
            total += ticketOptions[mintInfos[i].ticketOption];
            _tokenIds.increment();
        }

        require(msg.value >= total, "price too low");
        return ids;
    }

    function withdraw() public {
        uint256 amount = address(this).balance;

        (bool ok, ) = owner.call{value: amount}("");
        require(ok, "Failed");
        emit Lint(amount, "withdraw");
    }
}pragma solidity ^0.8.10;


contract Unlimited is ERC20 {
    constructor() ERC20("Unlimited", "UNLIPP") {
        mintTokens();
    }

    function mintTokens() public {
        _mint(msg.sender, 100000000000000000000000);
    }
}