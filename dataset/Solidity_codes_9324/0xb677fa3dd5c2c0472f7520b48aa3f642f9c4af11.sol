
pragma solidity >=0.8.4;

library SafeTransferLib {


    error ETHtransferFailed();
    error TransferFailed();
    error TransferFromFailed();


    function _safeTransferETH(address to, uint256 amount) internal {

        bool success;

        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        if (!success) revert ETHtransferFailed();
    }


    function _safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // append the 'to' argument
            mstore(add(freeMemoryPointer, 36), amount) // append the 'amount' argument

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success) revert TransferFailed();
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // append the 'from' argument
            mstore(add(freeMemoryPointer, 36), to) // append the 'to' argument
            mstore(add(freeMemoryPointer, 68), amount) // append the 'amount' argument

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success) revert TransferFromFailed();
    }
}

interface IKaliAccessManager {

    function balanceOf(address account, uint256 id) external returns (uint256);


    function joinList(
        address account,
        uint256 id,
        bytes32[] calldata merkleProof
    ) external payable;

}

interface IKaliShareManager {

    function mintShares(address to, uint256 amount) external payable;


    function burnShares(address from, uint256 amount) external payable;

}

interface IERC20Permit {

    function permit(
        address owner, 
        address spender, 
        uint256 value, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external;

}

abstract contract KaliOwnable {
    event OwnershipTransferred(address indexed from, address indexed to);
    event ClaimTransferred(address indexed from, address indexed to);

    error NotOwner();
    error NotPendingOwner();

    address public owner;
    address public pendingOwner;

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function _init(address owner_) internal {
        owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function claimOwner() external payable {
        if (msg.sender != pendingOwner) revert NotPendingOwner();

        emit OwnershipTransferred(owner, msg.sender);

        owner = msg.sender;
        delete pendingOwner;
    }

    function transferOwner(address to, bool direct) external payable onlyOwner {
        if (direct) {
            owner = to;
            emit OwnershipTransferred(msg.sender, to);
        } else {
            pendingOwner = to;
            emit ClaimTransferred(msg.sender, to);
        }
    }
}

abstract contract Multicall {
    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        
        for (uint256 i; i < data.length; ) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                    
                assembly {
                    result := add(result, 0x04)
                }
                    
                revert(abi.decode(result, (string)));
            }

            results[i] = result;

            unchecked {
                ++i;
            }
        }
    }
}

abstract contract ReentrancyGuard {
    error Reentrancy();
    
    uint256 private locked = 1;

    modifier nonReentrant() {
        if (locked != 1) revert Reentrancy();
        
        locked = 2;
        _;
        locked = 1;
    }
}

contract KaliDAOcrowdsale is KaliOwnable, Multicall, ReentrancyGuard {


    using SafeTransferLib for address;


    event ExtensionSet(
        address indexed dao, 
        uint256 listId, 
        uint8 purchaseMultiplier, 
        address purchaseAsset, 
        uint32 saleEnds, 
        uint96 purchaseLimit, 
        uint96 personalLimit,
        string details
    );
    event ExtensionCalled(address indexed dao, address indexed purchaser, uint256 amountOut);
    event KaliRateSet(uint8 kaliRate);


    error NullMultiplier();
    error SaleEnded();
    error NotListed();
    error PurchaseLimit();
    error PersonalLimit();
    error RateLimit();

 
    uint8 private kaliRate;
    IKaliAccessManager private immutable accessManager;
    address private immutable wETH;

    mapping(address => Crowdsale) public crowdsales;

    struct Crowdsale {
        uint256 listId;
        uint8 purchaseMultiplier;
        address purchaseAsset;
        uint32 saleEnds;
        uint96 purchaseLimit;
        uint96 personalLimit;
        uint256 purchaseTotal;
        string details;
        mapping(address => uint256) personalPurchased;
    }

    function checkPersonalPurchased(address account, address dao) external view returns (uint256) {

        return crowdsales[dao].personalPurchased[account];
    }


    constructor(IKaliAccessManager accessManager_, address wETH_) {
        accessManager = accessManager_;
        KaliOwnable._init(msg.sender);
        wETH = wETH_;
    }


    function joinList(uint256 id, bytes32[] calldata merkleProof) external payable {

        accessManager.joinList(
            msg.sender,
            id,
            merkleProof
        );
    }

    function setPermit(
        IERC20Permit token, 
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r, 
        bytes32 s
    ) external payable {

        token.permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
    }


    function setExtension(bytes calldata extensionData) external payable {

        (
            uint256 listId, 
            uint8 purchaseMultiplier,
            address purchaseAsset, 
            uint32 saleEnds, 
            uint96 purchaseLimit, 
            uint96 personalLimit,
            string memory details
        ) 
            = abi.decode(extensionData, (uint256, uint8, address, uint32, uint96, uint96, string));
        
        if (purchaseMultiplier == 0) revert NullMultiplier();

        Crowdsale storage sale = crowdsales[msg.sender];
        sale.listId = listId;
        sale.purchaseMultiplier = purchaseMultiplier;
        sale.purchaseAsset = purchaseAsset;
        sale.saleEnds = saleEnds;
        sale.purchaseLimit = purchaseLimit;
        sale.personalLimit = personalLimit;
        sale.details = details;

        emit ExtensionSet(msg.sender, listId, purchaseMultiplier, purchaseAsset, saleEnds, purchaseLimit, personalLimit, details);
    }


    function callExtension(address dao, uint256 amount) external payable nonReentrant returns (uint256 amountOut) {

        Crowdsale storage sale = crowdsales[dao];

        if (block.timestamp > sale.saleEnds) revert SaleEnded();

        if (sale.listId != 0) 
            if (accessManager.balanceOf(msg.sender, sale.listId) == 0) revert NotListed();

        uint256 total;
        uint256 payment;

        if (sale.purchaseAsset == address(0) || sale.purchaseAsset == address(0xDead)) {
            total = msg.value;
        } else {
            total = amount;
        }

        if (kaliRate != 0) {
            uint256 fee = (total * kaliRate) / 100;
            unchecked { 
                payment = total - fee;
            }
        } else {
            payment = total;
        }

        amountOut = total * sale.purchaseMultiplier;

        if (sale.purchaseTotal + amountOut > sale.purchaseLimit) revert PurchaseLimit();
        if (sale.personalPurchased[msg.sender] + amountOut > sale.personalLimit) revert PersonalLimit();
    
        if (sale.purchaseAsset == address(0)) {
            dao._safeTransferETH(payment);
        } else if (sale.purchaseAsset == address(0xDead)) {
            wETH._safeTransferETH(payment);
            wETH._safeTransfer(dao, payment);
        } else {
            sale.purchaseAsset._safeTransferFrom(msg.sender, dao, payment);
        }
        
        sale.purchaseTotal += amountOut;
        sale.personalPurchased[msg.sender] += amountOut;
            
        IKaliShareManager(dao).mintShares(msg.sender, amountOut);

        emit ExtensionCalled(dao, msg.sender, amountOut);
    }


    function setKaliRate(uint8 kaliRate_) external payable onlyOwner {

        if (kaliRate_ > 100) revert RateLimit();
        kaliRate = kaliRate_;
        emit KaliRateSet(kaliRate_);
    }

    function claimKaliFees(
        address to, 
        address asset, 
        uint256 amount
    ) external payable onlyOwner {

        if (asset == address(0)) {
            to._safeTransferETH(amount);
        } else {
            asset._safeTransfer(to, amount);
        }
    }
}