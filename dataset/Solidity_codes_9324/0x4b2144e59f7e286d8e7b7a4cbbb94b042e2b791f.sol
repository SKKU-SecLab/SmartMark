
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

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

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}pragma solidity ^0.8.0;

interface SkeletonCrew {

    function mintCards(uint256 numberOfCards, address recipient) external;

}pragma solidity ^0.8.0;




contract metaZooSale is Ownable {

    using SafeMath for uint256;

    event WhiteListSale(uint256 tokenCount, address receiver, uint256 role);
    event PurchaseSale(uint256 tokenCount, address buyer);


    uint256 public startingPrice = 5 ether;
    uint256 public whitelist_sales;
    uint256 public whitelist_sales_end;
    uint256 public sales_start;
    uint256 public sales_end;

    address public nft_sales;
    uint256 public sales_duration = 12 hours;
    bool public setupStatus = true;
    uint256 public maxDecreaseSold = 0;
    uint256 public maxDecreaseNFTs = 500;

    uint256 public whiteListSold = 0;
    uint256 public maxWhiteListNFTs = 4300;

    address public presigner;
    uint256 public whiteListPrice = 0.1 ether;
    mapping(address => uint256) public whitelist_claimed;

    address payable[] _wallets = [
        payable(0xA3cB071C94b825471E230ff42ca10094dEd8f7bB), 
        payable(0xA807a452e20a766Ea36019bF5bE5c5f4cbDE7563), 
        payable(0x77b94A55684C95D59A8F56a234B6e555fC79997c) 
    ];

    uint256[] _shares = [70, 180, 750];

    function _split(uint256 amount) internal {

        bool sent;
        uint256 _total;
        for (uint256 j = 0; j < _wallets.length; j++) {
            uint256 _amount = (amount * _shares[j]) / 1000;
            if (j == _wallets.length - 1) {
                _amount = amount - _total;
            } else {
                _total += _amount;
            }
            (sent, ) = _wallets[j].call{value: _amount}(""); // don't use send or xfer (gas)
            require(sent, "Failed to send Ether");
        }
    }
    function whiteListBySignature(
        address _recipient,
        uint256 _tokenCount,
        bytes memory signature,
        uint64 _role
    ) public payable {

        require(
            whiteListSalesActive(),
            "Sales has not started or ended , please chill sir."
        );
        require(_role == 1 || _role == 2, "One or Two none else will do");
        require(verify(_role, msg.sender, signature), "Unauthorised");
        require(msg.value >= _tokenCount * (whiteListPrice), "Price not met");
        uint256 this_taken = whitelist_claimed[msg.sender] + _tokenCount;

        whitelist_claimed[msg.sender] = this_taken;
        require(
            _role >= whitelist_claimed[msg.sender],
            "Too many tokens requested"
        );
        whiteListSold += _tokenCount;
        require(whiteListSold <= maxWhiteListNFTs, "sold out");
        SkeletonCrew(nft_sales).mintCards(_tokenCount, _recipient);
        _split(msg.value);
        emit WhiteListSale(_tokenCount, _recipient, _role);
    }

    function verify(
        uint64 _amount,
        address _user,
        bytes memory _signature
    ) public view returns (bool) {

        require(_user != address(0), "NativeMetaTransaction: INVALID__user");
        bytes32 _hash =
            ECDSA.toEthSignedMessageHash(
                keccak256(abi.encodePacked(_user, _amount))
            );
        require(_signature.length == 65, "Invalid signature length");
        address recovered = ECDSA.recover(_hash, _signature);
        return (presigner == recovered);
    }

    function currentPrice() public view returns (uint256) {

        uint256 gap = block.timestamp - sales_start;
        uint256 counts = gap / (15 minutes);
        if (gap >= sales_duration) {
            return 0.2 ether;
        }
        return startingPrice - (counts * 0.1 ether);
    }

    function whiteListRemainingTokens() public view returns (uint256) {

        return maxWhiteListNFTs - whiteListSold;
    }

    function decreaseRemainingTokens() public view returns (uint256) {

        return (maxDecreaseNFTs + whiteListRemainingTokens()) - maxDecreaseSold;
    }

    constructor(
        uint256 _whitelist_sales,
        uint256 _sales_start,
        address _nft_sales,
        address _presigner
    ) {
        whitelist_sales = _whitelist_sales;
        whitelist_sales_end = _whitelist_sales + 3 days;
        sales_start = _sales_start;
        sales_end = sales_start + 12 hours;
        nft_sales = _nft_sales;
        presigner = _presigner;
    }

    function purchase(uint256 _amount) public payable {

        require(
            salesActive(),
            "Sales has not started or ended , please chill sir."
        );
        require(msg.value >= _amount.mul(currentPrice()), "Price not met");
        require(decreaseRemainingTokens() >= _amount, "sold out");
        maxDecreaseSold += _amount;
        SkeletonCrew(nft_sales).mintCards(_amount, msg.sender);
        _split(msg.value);

        emit PurchaseSale(_amount, msg.sender);
    }

    function whiteListMint(uint64 _amount, address _receiver) public onlyOwner {

        SkeletonCrew(nft_sales).mintCards(_amount, _receiver);
    }

    function salesActive() public view returns (bool) {

        return (block.timestamp > sales_start && block.timestamp < sales_end);
    }

    function whiteListSalesActive() public view returns (bool) {

        return (block.timestamp > whitelist_sales &&
            block.timestamp < whitelist_sales_end);
    }

    function sales_how_long_more()
        public
        view
        returns (
            uint256 Days,
            uint256 Hours,
            uint256 Minutes,
            uint256 Seconds
        )
    {

        require(block.timestamp < sales_start, "Started");
        uint256 gap = sales_start - block.timestamp;
        Days = gap / (24 * 60 * 60);
        gap = gap % (24 * 60 * 60);
        Hours = gap / (60 * 60);
        gap = gap % (60 * 60);
        Minutes = gap / 60;
        Seconds = gap % 60;
        return (Days, Hours, Minutes, Seconds);
    }

    function whitelist_how_long_more()
        public
        view
        returns (
            uint256 Days,
            uint256 Hours,
            uint256 Minutes,
            uint256 Seconds
        )
    {

        require(block.timestamp < whitelist_sales, "Started");
        uint256 gap = whitelist_sales - block.timestamp;
        Days = gap / (24 * 60 * 60);
        gap = gap % (24 * 60 * 60);
        Hours = gap / (60 * 60);
        gap = gap % (60 * 60);
        Minutes = gap / 60;
        Seconds = gap % 60;
        return (Days, Hours, Minutes, Seconds);
    }

    function changePresigner(address _presigner) external onlyOwner {

        presigner = _presigner;
    }

    function resetSalesStatus(
        uint256 _whitelist_sales,
        uint256 _sales_start,
        address _nft_sales,
        bool _setupStatus
    ) external onlyOwner {

        whitelist_sales = _whitelist_sales;
        whitelist_sales_end = _whitelist_sales + 2 days;
        sales_start = _sales_start;
        sales_end = _sales_start + 12 hours;
        nft_sales = _nft_sales;
        setupStatus = _setupStatus;
    }

    function retrieveETH() external onlyOwner {

        payable(msg.sender).transfer(address(this).balance);
    }

    function retrieveERC20(address _tracker, uint256 amount)
        external
        onlyOwner
    {

        IERC20(_tracker).transfer(msg.sender, amount);
    }

    function retrieve721(address _tracker, uint256 id) external onlyOwner {

        IERC721(_tracker).transferFrom(address(this), msg.sender, id);
    }

    struct theKitchenSink {
        uint256 startingPrice;
        uint256 whitelist_sales;
        uint256 whitelist_sales_end;
        uint256 sales_start;
        uint256 sales_end;
        address nft_sales;
        uint256 sales_duration;
        bool setupStatus;
        uint256 maxDecreaseSold;
        uint256 maxDecreaseNFTs;
        uint256 whiteListSold;
        uint256 maxWhiteListNFTs;
        address presigner;
        uint256 whiteListPrice;
        uint256 whiteListRemaining;
        uint256 decreaseRemaining;
    }

    function tellEverything() external view returns (theKitchenSink memory) {

        return
            theKitchenSink(
                startingPrice,
                whitelist_sales,
                whitelist_sales_end,
                sales_start,
                sales_end,
                nft_sales,
                sales_duration,
                setupStatus,
                maxDecreaseSold,
                maxDecreaseNFTs,
                whiteListSold,
                maxWhiteListNFTs,
                presigner,
                whiteListPrice,
                whiteListRemainingTokens(),
                decreaseRemainingTokens()
            );
    }
}