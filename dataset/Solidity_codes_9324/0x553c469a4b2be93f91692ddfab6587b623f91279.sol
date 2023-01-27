
pragma solidity 0.6.8;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity 0.6.8;


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.6.8;


contract Pausable is Ownable {

    bool private isPaused = false;

    event Paused();
    event Unpaused();

    function getIsPaused() public view returns (bool) {

        return isPaused;
    }

    function pause() public onlyOwner {

        isPaused = true;
    }

    function unpause() public onlyOwner {

        isPaused = false;
    }

    modifier whenPaused {

        require(isPaused, "Contract is not paused");
        _;
    }

    modifier whenNotPaused {

        require(!isPaused, "Contract is paused");
        _;
    }
}

pragma solidity 0.6.8;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity 0.6.8;

interface IPunkToken is IERC20 {

    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;


    function mint(address to, uint256 amount) external;


    function changeName(string calldata name) external;


    function changeSymbol(string calldata symbol) external;


    function setVaultAddress(address vaultAddress) external;


    function transferOwnership(address newOwner) external;

}

pragma solidity 0.6.8;

interface ICryptoPunksMarket {

    struct Offer {
        bool isForSale;
        uint256 punkIndex;
        address seller;
        uint256 minValue;
        address onlySellTo;
    }

    struct Bid {
        bool hasBid;
        uint256 punkIndex;
        address bidder;
        uint256 value;
    }

    event Assign(address indexed to, uint256 punkIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event PunkTransfer(
        address indexed from,
        address indexed to,
        uint256 punkIndex
    );
    event PunkOffered(
        uint256 indexed punkIndex,
        uint256 minValue,
        address indexed toAddress
    );
    event PunkBidEntered(
        uint256 indexed punkIndex,
        uint256 value,
        address indexed fromAddress
    );
    event PunkBidWithdrawn(
        uint256 indexed punkIndex,
        uint256 value,
        address indexed fromAddress
    );
    event PunkBought(
        uint256 indexed punkIndex,
        uint256 value,
        address indexed fromAddress,
        address indexed toAddress
    );
    event PunkNoLongerForSale(uint256 indexed punkIndex);

    function setInitialOwner(address to, uint256 punkIndex) external;


    function setInitialOwners(
        address[] calldata addresses,
        uint256[] calldata indices
    ) external;


    function allInitialOwnersAssigned() external;


    function getPunk(uint256 punkIndex) external;


    function transferPunk(address to, uint256 punkIndex) external;


    function punkNoLongerForSale(uint256 punkIndex) external;


    function offerPunkForSale(uint256 punkIndex, uint256 minSalePriceInWei)
        external;


    function offerPunkForSaleToAddress(
        uint256 punkIndex,
        uint256 minSalePriceInWei,
        address toAddress
    ) external;


    function buyPunk(uint256 punkIndex) external;


    function withdraw() external;


    function enterBidForPunk(uint256 punkIndex) external;


    function acceptBidForPunk(uint256 punkIndex, uint256 minPrice) external;


    function withdrawBidForPunk(uint256 punkIndex) external;


    function punkIndexToAddress(uint256 punkIndex) external returns (address);

    function punksOfferedForSale(uint256 punkIndex)
        external
        returns (
            bool isForSale,
            uint256 _punkIndex,
            address seller,
            uint256 minValue,
            address onlySellTo
        );


    function balanceOf(address user) external returns (uint256);

}

pragma solidity 0.6.8;


contract PunkVaultBase is Pausable {

    address private erc20Address;
    address private cpmAddress;

    IPunkToken private erc20;
    ICryptoPunksMarket private cpm;

    function getERC20Address() public view returns (address) {

        return erc20Address;
    }

    function getCpmAddress() public view returns (address) {

        return cpmAddress;
    }

    function getERC20() internal view returns (IPunkToken) {

        return erc20;
    }

    function getCPM() internal view returns (ICryptoPunksMarket) {

        return cpm;
    }

    function setERC20Address(address newAddress) internal {

        require(erc20Address == address(0), "Already initialized ERC20");
        erc20Address = newAddress;
        erc20 = IPunkToken(erc20Address);
    }

    function setCpmAddress(address newAddress) internal {

        require(cpmAddress == address(0), "Already initialized CPM");
        cpmAddress = newAddress;
        cpm = ICryptoPunksMarket(cpmAddress);
    }
}

pragma solidity 0.6.8;

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


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {

        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return address(uint256(_at(set._inner, index)));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {

        return uint256(_at(set._inner, index));
    }
}

pragma solidity 0.6.8;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

pragma solidity 0.6.8;


contract PunkVaultSafe is PunkVaultBase, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet private reserves;
    bool private inSafeMode = true;

    event TokenBurnedSafely(uint256 punkId, address indexed to);

    function getReserves()
        internal
        view
        returns (EnumerableSet.UintSet storage)
    {

        return reserves;
    }

    function getInSafeMode() public view returns (bool) {

        return inSafeMode;
    }

    function turnOffSafeMode() public onlyOwner {

        inSafeMode = false;
    }

    function turnOnSafeMode() public onlyOwner {

        inSafeMode = true;
    }

    modifier whenNotInSafeMode {

        require(!inSafeMode, "Contract is in safe mode");
        _;
    }

    function simpleRedeem() public whenPaused nonReentrant {

        require(
            getERC20().balanceOf(msg.sender) >= 10**18,
            "ERC20 balance too small"
        );
        require(
            getERC20().allowance(msg.sender, address(this)) >= 10**18,
            "ERC20 allowance too small"
        );
        uint256 tokenId = reserves.at(0);
        getERC20().burnFrom(msg.sender, 10**18);
        reserves.remove(tokenId);
        getCPM().transferPunk(msg.sender, tokenId);
        emit TokenBurnedSafely(tokenId, msg.sender);
    }
}

pragma solidity 0.6.8;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

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

    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.6.8;


contract Timelocked is PunkVaultSafe {

    using SafeMath for uint256;
    enum Timelock {Short, Medium, Long}

    uint256 private securityLevel;

    function getSecurityLevel() public view returns (string memory) {

        if (securityLevel == 0) {
            return "red";
        } else if (securityLevel == 1) {
            return "orange";
        } else if (securityLevel == 2) {
            return "yellow";
        } else {
            return "green";
        }
    }

    function increaseSecurityLevel() public onlyOwner {

        require(securityLevel < 3, "Already max");
        securityLevel = securityLevel + 1;
    }

    function timeInDays(uint256 num) internal pure returns (uint256) {

        return num * 60 * 60 * 24;
    }

    function getDelay(Timelock lockId) public view returns (uint256) {

        if (securityLevel == 0) {
            return 2; // for testing
        }
        if (lockId == Timelock.Short) {
            if (securityLevel == 1) {
                return timeInDays(1);
            } else if (securityLevel == 2) {
                return timeInDays(2);
            } else {
                return timeInDays(3);
            }
        } else if (lockId == Timelock.Medium) {
            if (securityLevel == 1) {
                return timeInDays(2);
            } else if (securityLevel == 2) {
                return timeInDays(3);
            } else {
                return timeInDays(5);
            }
        } else {
            if (securityLevel == 1) {
                return timeInDays(3);
            } else if (securityLevel == 2) {
                return timeInDays(5);
            } else {
                return timeInDays(10);
            }
        }
    }

    mapping(Timelock => uint256) private releaseTimes;

    event Locked(Timelock lockId);

    event UnlockInitiated(Timelock lockId, uint256 whenUnlocked);

    function getReleaseTime(Timelock lockId) public view returns (uint256) {

        return releaseTimes[lockId];
    }

    function initiateUnlock(Timelock lockId) public onlyOwner {

        uint256 newReleaseTime = now.add(getDelay(lockId));
        releaseTimes[lockId] = newReleaseTime;
        emit UnlockInitiated(lockId, newReleaseTime);
    }

    function lock(Timelock lockId) public onlyOwner {

        releaseTimes[lockId] = 0;
        emit Locked(lockId);
    }

    modifier whenNotLockedS {

        uint256 releaseTime = releaseTimes[Timelock.Short];
        require(releaseTime > 0, "Locked");
        require(now > releaseTime, "Not unlocked");
        _;
    }
    modifier whenNotLockedM {

        uint256 releaseTime = releaseTimes[Timelock.Medium];
        require(releaseTime > 0, "Locked");
        require(now > releaseTime, "Not unlocked");
        _;
    }
    modifier whenNotLockedL {

        uint256 releaseTime = releaseTimes[Timelock.Long];
        require(releaseTime > 0, "Locked");
        require(now > releaseTime, "Not unlocked");
        _;
    }
}

pragma solidity >=0.6.0 <0.7.0;


contract Profitable is Timelocked {

    mapping(address => bool) private verifiedIntegrators;
    uint256 private numIntegrators = 0;
    uint256[] private mintFees = [0, 0, 0];
    uint256[] private burnFees = [0, 0, 0];
    uint256[] private dualFees = [0, 0, 0];
    uint256[] private supplierBounty = [(5 * 10**17), 10];

    event MintFeesSet(uint256[] mintFees);
    event BurnFeesSet(uint256[] burnFees);
    event DualFeesSet(uint256[] dualFees);
    event SupplierBountySet(uint256[] supplierBounty);
    event IntegratorSet(address account, bool isVerified);
    event Withdrawal(address to, uint256 amount);

    function getMintFees() public view returns (uint256[] memory) {

        return mintFees;
    }

    function getBurnFees() public view returns (uint256[] memory) {

        return burnFees;
    }

    function getDualFees() public view returns (uint256[] memory) {

        return dualFees;
    }

    function getSupplierBounty() public view returns (uint256[] memory) {

        return supplierBounty;
    }

    function _getMintFees() internal view returns (uint256[] storage) {

        return mintFees;
    }

    function _getBurnFees() internal view returns (uint256[] storage) {

        return burnFees;
    }

    function _getDualFees() internal view returns (uint256[] storage) {

        return dualFees;
    }

    function setMintFees(uint256[] memory newMintFees)
        public
        onlyOwner
        whenNotLockedM
    {

        require(newMintFees.length == 3, "Wrong length");
        mintFees = newMintFees;
        emit MintFeesSet(newMintFees);
    }

    function setBurnFees(uint256[] memory newBurnFees)
        public
        onlyOwner
        whenNotLockedL
    {

        require(newBurnFees.length == 3, "Wrong length");
        burnFees = newBurnFees;
        emit BurnFeesSet(newBurnFees);
    }

    function setDualFees(uint256[] memory newDualFees)
        public
        onlyOwner
        whenNotLockedM
    {

        require(newDualFees.length == 3, "Wrong length");
        dualFees = newDualFees;
        emit DualFeesSet(newDualFees);
    }

    function setSupplierBounty(uint256[] memory newSupplierBounty)
        public
        onlyOwner
        whenNotLockedL
    {

        require(newSupplierBounty.length == 2, "Wrong length");
        supplierBounty = newSupplierBounty;
        emit SupplierBountySet(newSupplierBounty);
    }

    function isIntegrator(address account) public view returns (bool) {

        return verifiedIntegrators[account];
    }

    function getNumIntegrators() public view returns (uint256) {

        return numIntegrators;
    }

    function setIntegrator(address account, bool isVerified)
        public
        onlyOwner
        whenNotLockedM
    {

        require(isVerified != verifiedIntegrators[account], "Already set");
        if (isVerified) {
            numIntegrators = numIntegrators.add(1);
        } else {
            numIntegrators = numIntegrators.sub(1);
        }
        verifiedIntegrators[account] = isVerified;
        emit IntegratorSet(account, isVerified);
    }

    function getFee(address account, uint256 numTokens, uint256[] storage fees)
        internal
        view
        returns (uint256)
    {

        uint256 fee = 0;
        if (verifiedIntegrators[account]) {
            return 0;
        } else if (numTokens == 1) {
            fee = fees[0];
        } else {
            fee = fees[1] + numTokens * fees[2];
        }
        return fee;
    }

    function getBurnBounty(uint256 numTokens) internal view returns (uint256) {

        uint256 bounty = 0;
        uint256 reservesLength = getReserves().length();
        uint256 padding = supplierBounty[1];
        if (reservesLength - numTokens <= padding) {
            uint256 addedAmount = 0;
            for (uint256 i = 0; i < numTokens; i++) {
                if (reservesLength - i <= padding && reservesLength - i > 0) {
                    addedAmount += (supplierBounty[0] *
                        (padding - (reservesLength - i) + 1));
                }
            }
            bounty += addedAmount;
        }
        return bounty;
    }

    function getMintBounty(uint256 numTokens) internal view returns (uint256) {

        uint256 bounty = 0;
        uint256 reservesLength = getReserves().length();
        uint256 padding = supplierBounty[1];
        if (reservesLength <= padding) {
            uint256 addedAmount = 0;
            for (uint256 i = 0; i < numTokens; i++) {
                if (reservesLength + i <= padding) {
                    addedAmount += (supplierBounty[0] *
                        (padding - (reservesLength + i)));
                }
            }
            bounty += addedAmount;
        }
        return bounty;
    }

    function withdraw(address payable to) public onlyOwner whenNotLockedM {

        uint256 balance = address(this).balance;
        to.transfer(balance);
        emit Withdrawal(to, balance);
    }
}

pragma solidity 0.6.8;


contract Controllable is Profitable {

    mapping(address => bool) private verifiedControllers;
    uint256 private numControllers = 0;

    event ControllerSet(address account, bool isVerified);
    event DirectRedemption(uint256 punkId, address by, address indexed to);

    function isController(address account) public view returns (bool) {

        return verifiedControllers[account];
    }

    function getNumControllers() public view returns (uint256) {

        return numControllers;
    }

    function setController(address account, bool isVerified)
        public
        onlyOwner
        whenNotLockedM
    {

        require(isVerified != verifiedControllers[account], "Already set");
        if (isVerified) {
            numControllers++;
        } else {
            numControllers--;
        }
        verifiedControllers[account] = isVerified;
        emit ControllerSet(account, isVerified);
    }

    modifier onlyController() {

        require(isController(_msgSender()), "Not a controller");
        _;
    }

    function directRedeem(uint256 tokenId, address to) public onlyController {

        require(getERC20().balanceOf(to) >= 10**18, "ERC20 balance too small");
        bool toSelf = (to == address(this));
        require(
            toSelf || (getERC20().allowance(to, address(this)) >= 10**18),
            "ERC20 allowance too small"
        );
        require(getReserves().contains(tokenId), "Not in holdings");
        getERC20().burnFrom(to, 10**18);
        getReserves().remove(tokenId);
        if (!toSelf) {
            getCPM().transferPunk(to, tokenId);
        }
        emit DirectRedemption(tokenId, _msgSender(), to);
    }
}

pragma solidity 0.6.8;


contract Randomizable is Controllable {

    uint256 private randNonce = 0;

    function getPseudoRand(uint256 modulus) internal returns (uint256) {

        randNonce = randNonce.add(1);
        return
            uint256(keccak256(abi.encodePacked(now, _msgSender(), randNonce))) %
            modulus;
    }
}

pragma solidity 0.6.8;


contract Manageable is Randomizable {

    event MigrationComplete(address to);
    event TokenNameChange(string name);
    event TokenSymbolChange(string symbol);

    function migrate(address to, uint256 max) public onlyOwner whenNotLockedL {

        uint256 count = 0;
        uint256 reservesLength = getReserves().length();
        for (uint256 i = 0; i < reservesLength; i++) {
            if (count >= max) {
                return;
            }
            uint256 tokenId = getReserves().at(0);
            getCPM().transferPunk(to, tokenId);
            getReserves().remove(tokenId);
            count = count.add(1);
        }
        getERC20().transferOwnership(to);
        emit MigrationComplete(to);
    }

    function changeTokenName(string memory newName)
        public
        onlyOwner
        whenNotLockedM
    {

        getERC20().changeName(newName);
        emit TokenNameChange(newName);
    }

    function changeTokenSymbol(string memory newSymbol)
        public
        onlyOwner
        whenNotLockedM
    {

        getERC20().changeSymbol(newSymbol);
        emit TokenSymbolChange(newSymbol);
    }

    function setReverseLink() public onlyOwner {

        getERC20().setVaultAddress(address(this));
    }
}

pragma solidity 0.6.8;


contract PunkVault is Manageable {

    event TokenMinted(uint256 tokenId, address indexed to);
    event TokensMinted(uint256[] tokenIds, address indexed to);
    event TokenBurned(uint256 tokenId, address indexed to);
    event TokensBurned(uint256[] tokenIds, address indexed to);

    constructor(address erc20Address, address cpmAddress) public {
        setERC20Address(erc20Address);
        setCpmAddress(cpmAddress);
    }

    function getCryptoPunkAtIndex(uint256 index) public view returns (uint256) {

        return getReserves().at(index);
    }

    function getReservesLength() public view returns (uint256) {

        return getReserves().length();
    }

    function isCryptoPunkDeposited(uint256 tokenId) public view returns (bool) {

        return getReserves().contains(tokenId);
    }

    function mintPunk(uint256 tokenId)
        public
        payable
        nonReentrant
        whenNotPaused
    {

        uint256 fee = getFee(_msgSender(), 1, _getMintFees());
        uint256 bounty = getMintBounty(1);
        if (fee > bounty) {
            uint256 differnce = fee.sub(bounty);
            require(msg.value >= differnce, "Value too low");
        }
        bool success = _mintPunk(tokenId, false);
        if (success && bounty > fee) {
            uint256 difference = bounty.sub(fee);
            uint256 balance = address(this).balance;
            address payable sender = _msgSender();
            if (balance >= difference) {
                sender.transfer(difference);
            } else {
                sender.transfer(balance);
            }
        }
    }

    function _mintPunk(uint256 tokenId, bool partOfDualOp)
        private
        returns (bool)
    {

        address msgSender = _msgSender();

        require(tokenId < 10000, "tokenId too high");
        (bool forSale, uint256 _tokenId, address seller, uint256 minVal, address buyer) = getCPM()
            .punksOfferedForSale(tokenId);
        require(_tokenId == tokenId, "Wrong punk");
        require(forSale, "Punk not available");
        require(buyer == address(this), "Transfer not approved");
        require(minVal == 0, "Min value not zero");
        require(msgSender == seller, "Sender is not seller");
        require(
            msgSender == getCPM().punkIndexToAddress(tokenId),
            "Sender is not owner"
        );
        getCPM().buyPunk(tokenId);
        getReserves().add(tokenId);
        if (!partOfDualOp) {
            uint256 tokenAmount = 10**18;
            getERC20().mint(msgSender, tokenAmount);
        }
        emit TokenMinted(tokenId, _msgSender());
        return true;
    }

    function mintPunkMultiple(uint256[] memory tokenIds)
        public
        payable
        nonReentrant
        whenNotPaused
        whenNotInSafeMode
    {

        uint256 fee = getFee(_msgSender(), tokenIds.length, _getMintFees());
        uint256 bounty = getMintBounty(tokenIds.length);
        require(bounty >= fee || msg.value >= fee.sub(bounty), "Value too low");
        uint256 numTokens = _mintPunkMultiple(tokenIds, false);
        require(numTokens > 0, "No tokens minted");
        require(numTokens == tokenIds.length, "Untransferable punks");
        if (fee > bounty) {
            uint256 differnce = fee.sub(bounty);
            require(msg.value >= differnce, "Value too low");
        }
        if (bounty > fee) {
            uint256 difference = bounty.sub(fee);
            uint256 balance = address(this).balance;
            address payable sender = _msgSender();
            if (balance >= difference) {
                sender.transfer(difference);
            } else {
                sender.transfer(balance);
            }
        }

    }

    function _mintPunkMultiple(uint256[] memory tokenIds, bool partOfDualOp)
        private
        returns (uint256)
    {

        require(tokenIds.length > 0, "No tokens");
        require(tokenIds.length <= 100, "Over 100 tokens");
        uint256[] memory newTokenIds = new uint256[](tokenIds.length);
        uint256 numNewTokens = 0;
        address msgSender = _msgSender();
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(tokenId < 10000, "tokenId too high");
            (bool forSale, uint256 _tokenId, address seller, uint256 minVal, address buyer) = getCPM()
                .punksOfferedForSale(tokenId);
            bool rightToken = _tokenId == tokenId;
            bool isApproved = buyer == address(this);
            bool priceIsZero = minVal == 0;
            bool isSeller = msgSender == seller;
            bool isOwner = msgSender == getCPM().punkIndexToAddress(tokenId);
            if (
                forSale &&
                rightToken &&
                isApproved &&
                priceIsZero &&
                isSeller &&
                isOwner
            ) {
                getCPM().buyPunk(tokenId);
                getReserves().add(tokenId);
                newTokenIds[numNewTokens] = tokenId;
                numNewTokens = numNewTokens.add(1);
            }
        }
        if (numNewTokens > 0) {
            if (!partOfDualOp) {
                uint256 tokenAmount = numNewTokens * (10**18);
                getERC20().mint(msgSender, tokenAmount);
            }
            emit TokensMinted(newTokenIds, msgSender);
        }
        return numNewTokens;
    }

    function redeemPunk() public payable nonReentrant whenNotPaused {

        uint256 fee = getFee(_msgSender(), 1, _getBurnFees()) +
            getBurnBounty(1);
        require(msg.value >= fee, "Value too low");
        _redeemPunk(false);
    }

    function _redeemPunk(bool partOfDualOp) private {

        address msgSender = _msgSender();
        uint256 tokenAmount = 10**18;
        require(
            partOfDualOp || (getERC20().balanceOf(msgSender) >= tokenAmount),
            "ERC20 balance too small"
        );
        require(
            partOfDualOp ||
                (getERC20().allowance(msgSender, address(this)) >= tokenAmount),
            "ERC20 allowance too small"
        );
        uint256 reservesLength = getReserves().length();
        uint256 randomIndex = getPseudoRand(reservesLength);
        uint256 tokenId = getReserves().at(randomIndex);
        if (!partOfDualOp) {
            getERC20().burnFrom(msgSender, tokenAmount);
        }
        getReserves().remove(tokenId);
        getCPM().transferPunk(msgSender, tokenId);
        emit TokenBurned(tokenId, msgSender);
    }

    function redeemPunkMultiple(uint256 numTokens)
        public
        payable
        nonReentrant
        whenNotPaused
        whenNotInSafeMode
    {

        uint256 fee = getFee(_msgSender(), numTokens, _getBurnFees()) +
            getBurnBounty(numTokens);
        require(msg.value >= fee, "Value too low");
        _redeemPunkMultiple(numTokens, false);
    }

    function _redeemPunkMultiple(uint256 numTokens, bool partOfDualOp) private {

        require(numTokens > 0, "No tokens");
        require(numTokens <= 100, "Over 100 tokens");
        address msgSender = _msgSender();
        uint256 tokenAmount = numTokens * (10**18);
        require(
            partOfDualOp || (getERC20().balanceOf(msgSender) >= tokenAmount),
            "ERC20 balance too small"
        );
        require(
            partOfDualOp ||
                (getERC20().allowance(msgSender, address(this)) >= tokenAmount),
            "ERC20 allowance too small"
        );
        if (!partOfDualOp) {
            getERC20().burnFrom(msgSender, tokenAmount);
        }
        uint256[] memory tokenIds = new uint256[](numTokens);
        for (uint256 i = 0; i < numTokens; i++) {
            uint256 reservesLength = getReserves().length();
            uint256 randomIndex = getPseudoRand(reservesLength);
            uint256 tokenId = getReserves().at(randomIndex);
            tokenIds[i] = tokenId;
            getReserves().remove(tokenId);
            getCPM().transferPunk(msgSender, tokenId);
        }
        emit TokensBurned(tokenIds, msgSender);
    }

    function mintAndRedeem(uint256 tokenId)
        public
        payable
        nonReentrant
        whenNotPaused
        whenNotInSafeMode
    {

        uint256 fee = getFee(_msgSender(), 1, _getDualFees());
        require(msg.value >= fee, "Value too low");
        require(_mintPunk(tokenId, true), "Minting failed");
        _redeemPunk(true);
    }

    function mintAndRedeemMultiple(uint256[] memory tokenIds)
        public
        payable
        nonReentrant
        whenNotPaused
        whenNotInSafeMode
    {

        uint256 numTokens = tokenIds.length;
        require(numTokens > 0, "No tokens");
        require(numTokens <= 20, "Over 20 tokens");
        uint256 fee = getFee(_msgSender(), numTokens, _getDualFees());
        require(msg.value >= fee, "Value too low");
        uint256 numTokensMinted = _mintPunkMultiple(tokenIds, true);
        if (numTokensMinted > 0) {
            _redeemPunkMultiple(numTokens, true);
        }
    }

    function mintRetroactively(uint256 tokenId, address to)
        public
        onlyOwner
        whenNotLockedS
    {

        require(
            getCPM().punkIndexToAddress(tokenId) == address(this),
            "Not owner"
        );
        require(!getReserves().contains(tokenId), "Already in reserves");
        uint256 cryptoPunkBalance = getCPM().balanceOf(address(this));
        require(
            (getERC20().totalSupply() / (10**18)) < cryptoPunkBalance,
            "No excess NFTs"
        );
        getReserves().add(tokenId);
        getERC20().mint(to, 10**18);
        emit TokenMinted(tokenId, _msgSender());
    }

    function redeemRetroactively(address to) public onlyOwner whenNotLockedS {

        require(
            getERC20().balanceOf(address(this)) >= (10**18),
            "Not enough PUNK"
        );
        getERC20().burn(10**18);
        uint256 reservesLength = getReserves().length();
        uint256 randomIndex = getPseudoRand(reservesLength);

        uint256 tokenId = getReserves().at(randomIndex);
        getReserves().remove(tokenId);
        getCPM().transferPunk(to, tokenId);
        emit TokenBurned(tokenId, _msgSender());
    }
}

pragma solidity 0.6.8;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

pragma solidity 0.6.8;

contract CryptoPunksMarket {

    address owner;

    string public standard = "CryptoPunks";
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    uint256 public nextPunkIndexToAssign = 0;

    bool public allPunksAssigned = false;
    uint256 public punksRemainingToAssign = 0;

    mapping(uint256 => address) public punkIndexToAddress;

    mapping(address => uint256) public balanceOf;

    struct Offer {
        bool isForSale;
        uint256 punkIndex;
        address seller;
        uint256 minValue; // in ether
        address onlySellTo; // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        uint256 punkIndex;
        address bidder;
        uint256 value;
    }

    mapping(uint256 => Offer) public punksOfferedForSale;

    mapping(uint256 => Bid) public punkBids;

    mapping(address => uint256) public pendingWithdrawals;

    event Assign(address indexed to, uint256 punkIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event PunkTransfer(
        address indexed from,
        address indexed to,
        uint256 punkIndex
    );
    event PunkOffered(
        uint256 indexed punkIndex,
        uint256 minValue,
        address indexed toAddress
    );
    event PunkBidEntered(
        uint256 indexed punkIndex,
        uint256 value,
        address indexed fromAddress
    );
    event PunkBidWithdrawn(
        uint256 indexed punkIndex,
        uint256 value,
        address indexed fromAddress
    );
    event PunkBought(
        uint256 indexed punkIndex,
        uint256 value,
        address indexed fromAddress,
        address indexed toAddress
    );
    event PunkNoLongerForSale(uint256 indexed punkIndex);

    constructor() public payable {
        owner = msg.sender;
        totalSupply = 10000; // Update total supply
        punksRemainingToAssign = totalSupply;
        name = "CRYPTOPUNKS"; // Set the name for display purposes
        symbol = "Ͼ"; // Set the symbol for display purposes
        decimals = 0; // Amount of decimals for display purposes
    }

    function setInitialOwner(address to, uint256 punkIndex) public {

        require(!allPunksAssigned);
        require(punkIndex < 10000);
        if (punkIndexToAddress[punkIndex] != to) {
            if (punkIndexToAddress[punkIndex] != address(0)) {
                balanceOf[punkIndexToAddress[punkIndex]]--;
            } else {
                punksRemainingToAssign--;
            }
            punkIndexToAddress[punkIndex] = to;
            balanceOf[to]++;
            emit PunkTransfer(address(0), to, punkIndex);
        }
    }

    function setInitialOwners(
        address[] memory addresses,
        uint256[] memory indices
    ) public {

        require(msg.sender == owner);
        uint256 n = addresses.length;
        for (uint256 i = 0; i < n; i++) {
            setInitialOwner(addresses[i], indices[i]);
        }
    }

    function allInitialOwnersAssigned() public {

        require(msg.sender == owner);
        allPunksAssigned = true;
    }

    function getPunk(uint256 punkIndex) public {

        require(punksRemainingToAssign != 0);
        require(punkIndexToAddress[punkIndex] == address(0));
        require(punkIndex < 10000);
        punkIndexToAddress[punkIndex] = msg.sender;
        balanceOf[msg.sender]++;
        punksRemainingToAssign--;
        emit Assign(msg.sender, punkIndex);
    }

    function transferPunk(address to, uint256 punkIndex) public {

        require(punkIndexToAddress[punkIndex] == msg.sender);
        require(punkIndex < 10000);
        if (punksOfferedForSale[punkIndex].isForSale) {
            punkNoLongerForSale(punkIndex);
        }
        punkIndexToAddress[punkIndex] = to;
        balanceOf[msg.sender]--;
        balanceOf[to]++;
        emit Transfer(msg.sender, to, 1);
        emit PunkTransfer(msg.sender, to, punkIndex);
        Bid storage bid = punkBids[punkIndex];
        if (bid.bidder == to) {
            pendingWithdrawals[to] += bid.value;
            punkBids[punkIndex] = Bid(false, punkIndex, address(0), 0);
        }
    }

    function punkNoLongerForSale(uint256 punkIndex) public {

        require(punkIndexToAddress[punkIndex] == msg.sender);
        require(punkIndex < 10000);
        punksOfferedForSale[punkIndex] = Offer(
            false,
            punkIndex,
            msg.sender,
            0,
            address(0)
        );
        emit PunkNoLongerForSale(punkIndex);
    }

    function offerPunkForSale(uint256 punkIndex, uint256 minSalePriceInWei)
        public
    {

        require(punkIndexToAddress[punkIndex] == msg.sender);
        require(punkIndex < 10000);
        punksOfferedForSale[punkIndex] = Offer(
            true,
            punkIndex,
            msg.sender,
            minSalePriceInWei,
            address(0)
        );
        emit PunkOffered(punkIndex, minSalePriceInWei, address(0));
    }

    function offerPunkForSaleToAddress(
        uint256 punkIndex,
        uint256 minSalePriceInWei,
        address toAddress
    ) public {

        require(punkIndexToAddress[punkIndex] == msg.sender);
        require(punkIndex < 10000);
        punksOfferedForSale[punkIndex] = Offer(
            true,
            punkIndex,
            msg.sender,
            minSalePriceInWei,
            toAddress
        );
        emit PunkOffered(punkIndex, minSalePriceInWei, toAddress);
    }

    function buyPunk(uint256 punkIndex) public payable {

        Offer storage offer = punksOfferedForSale[punkIndex];
        require(punkIndex < 10000);
        require(offer.isForSale); // punk not actually for sale
        (offer.onlySellTo == address(0) || offer.onlySellTo == msg.sender); // punk not supposed to be sold to this user
        require(msg.value >= offer.minValue); // Didn't send enough ETH
        require(offer.seller == punkIndexToAddress[punkIndex]); // Seller no longer owner of punk

        address seller = offer.seller;

        punkIndexToAddress[punkIndex] = msg.sender;
        balanceOf[seller]--;
        balanceOf[msg.sender]++;
        emit Transfer(seller, msg.sender, 1);

        punkNoLongerForSale(punkIndex);
        pendingWithdrawals[seller] += msg.value;
        emit PunkBought(punkIndex, msg.value, seller, msg.sender);

        Bid storage bid = punkBids[punkIndex];
        if (bid.bidder == msg.sender) {
            pendingWithdrawals[msg.sender] += bid.value;
            punkBids[punkIndex] = Bid(false, punkIndex, address(0), 0);
        }
    }

    function withdraw() public {

        uint256 amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function enterBidForPunk(uint256 punkIndex) public payable {

        require(punkIndex < 10000);
        require(punkIndexToAddress[punkIndex] != address(0));
        require(punkIndexToAddress[punkIndex] != msg.sender);
        require(msg.value != 0);
        Bid storage existing = punkBids[punkIndex];
        require(msg.value > existing.value);
        if (existing.value > 0) {
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        punkBids[punkIndex] = Bid(true, punkIndex, msg.sender, msg.value);
        emit PunkBidEntered(punkIndex, msg.value, msg.sender);
    }

    function acceptBidForPunk(uint256 punkIndex, uint256 minPrice) public {

        require(punkIndex < 10000);
        require(punkIndexToAddress[punkIndex] == msg.sender);
        address seller = msg.sender;
        Bid storage bid = punkBids[punkIndex];
        require(bid.value != 0);
        require(bid.value >= minPrice);

        punkIndexToAddress[punkIndex] = bid.bidder;
        balanceOf[seller]--;
        balanceOf[bid.bidder]++;
        emit Transfer(seller, bid.bidder, 1);

        punksOfferedForSale[punkIndex] = Offer(
            false,
            punkIndex,
            bid.bidder,
            0,
            address(0)
        );
        uint256 amount = bid.value;
        punkBids[punkIndex] = Bid(false, punkIndex, address(0), 0);
        pendingWithdrawals[seller] += amount;
        emit PunkBought(punkIndex, bid.value, seller, bid.bidder);
    }

    function withdrawBidForPunk(uint256 punkIndex) public {

        require(punkIndex < 10000);
        require(punkIndexToAddress[punkIndex] != address(0));
        require(punkIndexToAddress[punkIndex] != msg.sender);
        Bid storage bid = punkBids[punkIndex];
        require(bid.bidder == msg.sender);
        emit PunkBidWithdrawn(punkIndex, bid.value, msg.sender);
        uint256 amount = bid.value;
        punkBids[punkIndex] = Bid(false, punkIndex, address(0), 0);
        msg.sender.transfer(amount);
    }
}

pragma solidity 0.6.8;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal
        virtual
    {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount)
        internal
        virtual
    {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _changeName(string memory name_) internal {

        _name = name_;
    }

    function _changeSymbol(string memory symbol_) internal {

        _symbol = symbol_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
    {}

}

pragma solidity 0.6.8;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
            amount,
            "ERC20: burn amount exceeds allowance"
        );

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

pragma solidity 0.6.8;


contract PunkToken is Context, Ownable, ERC20Burnable {
    address private vaultAddress;

    constructor(string memory name, string memory symbol)
        public
        ERC20(name, symbol)
    {
        _mint(msg.sender, 0);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function changeName(string memory name) public onlyOwner {
        _changeName(name);
    }

    function changeSymbol(string memory symbol) public onlyOwner {
        _changeSymbol(symbol);
    }

    function getVaultAddress() public view returns (address) {
        return vaultAddress;
    }

    function setVaultAddress(address newAddress) public onlyOwner {
        vaultAddress = newAddress;
    }
}
