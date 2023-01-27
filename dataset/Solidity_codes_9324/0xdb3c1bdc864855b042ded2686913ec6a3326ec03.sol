
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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


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

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity >= 0.8.0;

abstract
contract IQLF {

    function version() virtual external view returns (uint32);


    function is_qualified(address account, bytes memory proof) virtual external view returns (bool, string memory);

}// MIT

pragma solidity >= 0.8.0;

contract MysteryBox is OwnableUpgradeable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct PaymentOption {
        address token_addr;
        uint256 price;
    }

    struct PaymentInfo {
        address token_addr;
        uint256 price;
        uint256 receivable_amount;
    }

    struct Box {
        uint32 personal_limit;
        uint32 start_time;
        uint32 end_time;
        address creator;
        bool canceled;
        bool sell_all;
        address nft_address;
        string name;
        PaymentInfo[] payment;

        uint256[] nft_id_list;
        address qualification;
        mapping(address => uint256[]) purchased_nft;
        uint256 total;

        address holder_token_addr;
        uint256 holder_min_token_amount;
    }

    event CreationSuccess (
        address indexed creator,
        address indexed nft_address,
        uint256 box_id,
        string name,
        uint32 start_time,
        uint32 end_time,
        bool sell_all
    );

    event OpenSuccess(
        uint256 indexed box_id,
        address indexed customer,
        address indexed nft_address,
        uint256 amount
    );

    event CancelSuccess(
        uint256 indexed box_id,
        address indexed creator
    );

    event ClaimPayment (
        address indexed creator,
        uint256 indexed box_id,
        address token_address,
        uint256 amount,
        uint256 timestamp
    );

    uint256 private _box_id;
    mapping(uint256 => Box) private box_by_id;
    mapping(address => bool) public admin;
    mapping(address => bool) public whitelist;

    function initialize() public initializer {

        __Ownable_init();
    }

    function createBox (
        address nft_address,
        string memory name,
        PaymentOption[] memory payment,
        uint32 personal_limit,
        uint32 start_time,
        uint32 end_time,
        bool sell_all,
        uint256[] memory nft_id_list,
        address qualification,
        address holder_token_addr,
        uint256 holder_min_token_amount
    )
        external
    {
        _box_id++;
        require(end_time > block.timestamp, "invalid end time");
        require(IERC721(nft_address).isApprovedForAll(msg.sender, address(this)), "not ApprovedForAll");
        require(payment.length > 0, "invalid payment");
        require(whitelist[msg.sender] || admin[msg.sender], "not whitelisted");

        Box storage box = box_by_id[_box_id];
        for (uint256 i = 0; i < payment.length; i++) {
            if (payment[i].token_addr != address(0)) {
                require(IERC20(payment[i].token_addr).totalSupply() > 0, "Not a valid ERC20 token address");
            }
            PaymentInfo memory paymentInfo = PaymentInfo(payment[i].token_addr, payment[i].price, 0);
            box.payment.push(paymentInfo);
        }

        box.creator = msg.sender;
        box.nft_address = nft_address;
        box.name = name;
        box.personal_limit = personal_limit;
        box.start_time = start_time;
        box.end_time = end_time;
        box.sell_all = sell_all;
        box.qualification = qualification;
        box.holder_token_addr = holder_token_addr;
        box.holder_min_token_amount = holder_min_token_amount;
        if (holder_token_addr != address(0)) {
            require(IERC20(holder_token_addr).totalSupply() > 0, "Not a valid ERC20 token address");
        }

        if (sell_all) {
            require(
                IERC721(nft_address).supportsInterface(type(IERC721EnumerableUpgradeable).interfaceId),
                "not enumerable nft");
            uint256 nftBalance = IERC721(nft_address).balanceOf(msg.sender);
            require(nftBalance > 0, "no nft owned");
            box.sell_all = true;
            box.total = nftBalance;
        }
        else {
            require(nft_id_list.length > 0, "empty nft list");
            require(_check_ownership(nft_id_list, nft_address), "now owner");
            box.nft_id_list = nft_id_list;
            box.total = nft_id_list.length;
        }
        emit CreationSuccess (
            msg.sender,
            nft_address,
            _box_id,
            name,
            start_time,
            end_time,
            sell_all
        );
    }

    function addNftIntoBox (
        uint256 box_id,
        uint256[] calldata nft_id_list
    )
        external
    {
        Box storage box = box_by_id[box_id];
        require(box.creator == msg.sender, "not box owner");
        require(box.sell_all == false, "can not add for sell_all");
        address nft_address = box.nft_address;
        address creator = box.creator;

        for (uint256 i = 0; i < nft_id_list.length; i++) {
            address nft_owner = IERC721(nft_address).ownerOf(nft_id_list[i]);
            require(creator == nft_owner, "not nft owner");
            box.nft_id_list.push(nft_id_list[i]);
        }
        box.total += nft_id_list.length;
    }

    function cancelBox (uint256 box_id)
        external
    {
        Box storage box = box_by_id[box_id];
        require(box.creator == msg.sender, "not box owner");
        require(block.timestamp <= box.start_time, "sale started");
        require(!(box.canceled), "sale canceled already");
        box.canceled = true;
        emit CancelSuccess(box_id, msg.sender);
    }

    function openBox(
        uint256 box_id,
        uint8 amount,
        uint8 payment_token_index,
        bytes memory proof
    )
        external
        payable
    {

        require(tx.origin == msg.sender, "no contracts");
        Box storage box = box_by_id[box_id];
        require(block.timestamp > box.start_time, "not started");
        require(box.end_time > block.timestamp, "expired");
        require(payment_token_index < box.payment.length, "invalid payment token");
        require((box.purchased_nft[msg.sender].length + amount) <= box.personal_limit, "exceeds personal limit");
        require(!(box.canceled), "sale canceled");

        if (box.holder_min_token_amount > 0 && box.holder_token_addr != address(0)) {
            require(
                IERC20(box.holder_token_addr).balanceOf(msg.sender) >= box.holder_min_token_amount,
                "not holding enough token"
            );
        }

        if (box.qualification != address(0)) {
            bool qualified;
            string memory error_msg;
            (qualified, error_msg) = IQLF(box.qualification).is_qualified(msg.sender, proof);
            require(qualified, error_msg);
        }

        address nft_address = box.nft_address;
        address creator = box.creator;
        uint256 total;
        if (box.sell_all) {
            total = IERC721(nft_address).balanceOf(creator);
        }
        else {
            total = box.nft_id_list.length;
        }
        require(total > 0, "no NFT left");
        if (amount > total) {
            amount = uint8(total);
        }

        uint256 rand = _random();
        if (box.sell_all) {
            for (uint256 i = 0; i < amount; i++) {
                uint256 token_index = rand % total;
                uint256 token_id = IERC721Enumerable(nft_address).tokenOfOwnerByIndex(creator, token_index);
                IERC721(nft_address).safeTransferFrom(creator, msg.sender, token_id);
                box.purchased_nft[msg.sender].push(token_id);
                rand = uint256(keccak256(abi.encodePacked(rand, i)));
                total--;
            }
        }
        else {
            uint8 nft_transfered;
            for (uint256 i = 0; i < amount; i++) {
                uint256 token_index = rand % total;
                uint256 token_id = box.nft_id_list[token_index];
                if (creator == IERC721(nft_address).ownerOf(token_id)) {
                    IERC721(nft_address).safeTransferFrom(creator, msg.sender, token_id);
                    box.purchased_nft[msg.sender].push(token_id);
                    nft_transfered++;
                }
                else {
                }
                _remove_nft_id(box, token_index);
                rand = uint256(keccak256(abi.encodePacked(rand, i)));
                total--;
            }
            amount = nft_transfered;
        }
        {
            uint256 total_payment = box.payment[payment_token_index].price;
            total_payment = total_payment.mul(amount);
            address payment_token_address = box.payment[payment_token_index].token_addr;
            if (payment_token_address == address(0)) {
                require(msg.value >= total_payment, "not enough ETH");
                uint256 eth_to_refund = msg.value.sub(total_payment);
                if (eth_to_refund > 0) {
                    address payable addr = payable(msg.sender);
                    addr.transfer(eth_to_refund);
                }
            }
            else {
                IERC20(payment_token_address).safeTransferFrom(msg.sender, address(this), total_payment);
            }
            box.payment[payment_token_index].receivable_amount += total_payment;
        }
        emit OpenSuccess(box_id, msg.sender, nft_address, amount);
    }

    function claimPayment(uint256[] calldata box_ids) external {

        for (uint256 asset_index = 0; asset_index < box_ids.length; asset_index++) {
            Box storage box = box_by_id[box_ids[asset_index]];
            require(box.creator == msg.sender, "not owner");
            uint256 total;
            if (box.sell_all) {
                total = IERC721(box.nft_address).balanceOf(msg.sender);
            }
            else {
                total = box.nft_id_list.length;
            }
            require(box.end_time <= block.timestamp || total == 0, "not expired/sold-out");

            for (uint256 token_index = 0; token_index < box.payment.length; token_index++) {
                address token_address = box.payment[token_index].token_addr;
                uint256 amount = box.payment[token_index].receivable_amount;
                if (amount == 0) {
                    continue;
                }
                box.payment[token_index].receivable_amount = 0;
                if (token_address == address(0)) {
                    address payable addr = payable(msg.sender);
                    addr.transfer(amount);
                }
                else {
                    IERC20(token_address).safeTransfer(msg.sender, amount);
                }
                emit ClaimPayment(msg.sender, box_ids[asset_index], token_address, amount, block.timestamp);
            }
        }
    }

    function getBoxInfo(uint256 box_id)
        external
        view
        returns (
            address creator,
            address nft_address,
            string memory name,
            uint32 personal_limit,
            address qualification,
            address holder_token_addr,
            uint256 holder_min_token_amount
        )
    {

        Box storage box = box_by_id[box_id];
        creator = box.creator;
        nft_address = box.nft_address;
        name = box.name;
        personal_limit = box.personal_limit;
        qualification = box.qualification;
        holder_token_addr = box.holder_token_addr;
        holder_min_token_amount = box.holder_min_token_amount;
    }

    function getBoxStatus(uint256 box_id)
        external
        view
        returns (
            PaymentInfo[] memory payment,
            bool started,
            bool expired,
            bool canceled,
            uint256 remaining,
            uint256 total
        )
    {

        Box storage box = box_by_id[box_id];
        payment = box.payment;
        started = block.timestamp > box.start_time;
        expired = block.timestamp > box.end_time;
        canceled = box.canceled;

        if (box.sell_all) {
            remaining = IERC721(box.nft_address).balanceOf(box.creator);
        }
        else {
            remaining = box.nft_id_list.length;
        }
        total = box.total;
    }

    function getPurchasedNft(uint256 box_id, address customer)
        external
        view
        returns(uint256[] memory nft_id_list)
    {

        Box storage box = box_by_id[box_id];
        nft_id_list = box.purchased_nft[customer];
    }

    function getNftListForSale(uint256 box_id, uint256 cursor, uint256 amount)
        external
        view
        returns(uint256[] memory nft_id_list)
    {

        Box storage box = box_by_id[box_id];
        address nft_address = box.nft_address;
        address creator = box.creator;
        uint256 total;
        if (box.sell_all) {
            total = IERC721(nft_address).balanceOf(creator);
        }
        else {
            total = box.nft_id_list.length;
        }
        if (cursor >= total) {
            return nft_id_list;
        }
        if (amount > (total - cursor)) {
            amount = total - cursor;
        }
        nft_id_list = new uint[](amount);

        if (box.sell_all) {
            for (uint256 i = 0; i < amount; i++) {
                uint256 token_index = i + cursor;
                nft_id_list[i] = IERC721Enumerable(nft_address).tokenOfOwnerByIndex(creator, token_index);
            }
        }
        else {
            for (uint256 i = 0; i < amount; i++) {
                uint256 token_index = i + cursor;
                nft_id_list[i] = box.nft_id_list[token_index];
            }
        }
    }

    function addAdmin(address[] memory addrs) external onlyOwner {

        for (uint256 i = 0; i < addrs.length; i++) {
            admin[addrs[i]] = true;
        }
    }

    function addWhitelist(address[] memory addrs) external {

        require(admin[msg.sender] || msg.sender == owner(), "not admin");
        for (uint256 i = 0; i < addrs.length; i++) {
            whitelist[addrs[i]] = true;
        }
    }

    function removeWhitelist(address[] memory addrs) external {

        require(admin[msg.sender] || msg.sender == owner(), "not admin");
        for (uint256 i = 0; i < addrs.length; i++) {
            whitelist[addrs[i]] = false;
        }
    }

    function _random() internal view returns (uint256 rand) {

        uint256 blocknumber = block.number;
        uint256 random_gap = uint256(keccak256(abi.encodePacked(blockhash(blocknumber-1), msg.sender))) % 255;
        uint256 random_block = blocknumber - 1 - random_gap;
        bytes32 sha = keccak256(abi.encodePacked(blockhash(random_block),
                                                msg.sender,
                                                block.coinbase,
                                                block.difficulty));
        return uint256(sha);
    }

    function _check_ownership(uint256[] memory nft_token_id_list, address nft_address)
        internal
        view
        returns(bool)
    {

        for (uint256 i = 0; i < nft_token_id_list.length; i++) {
            address nft_owner = IERC721(nft_address).ownerOf(nft_token_id_list[i]);
            if (nft_owner != msg.sender){
                return false;
            }
        }
        return true;
    }

    function _remove_nft_id(Box storage box, uint256 index) private {

        require(box.nft_id_list.length > index, "invalid index");
        uint256 lastTokenIndex = box.nft_id_list.length - 1;
        if (index != lastTokenIndex) {
            uint256 lastTokenId = box.nft_id_list[lastTokenIndex];
            box.nft_id_list[index] = lastTokenId;
        }
        box.nft_id_list.pop();
    }
}