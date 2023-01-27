
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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal initializer {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal initializer {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
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
}//MIT
pragma solidity ^0.8.3;

interface IERC721VaultFactory {

    function vaults(uint256) external returns (address);


    function mint(
        string memory _name,
        string memory _symbol,
        address _token,
        uint256 _id,
        uint256 _supply,
        uint256 _listPrice,
        uint256 _fee
    ) external returns (uint256);

}//MIT
pragma solidity ^0.8.3;

interface ITokenVault {

    function updateCurator(address _curator) external;


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function balanceOf(address account) external view returns (uint256);

}// MIT
pragma solidity ^0.8.3;


interface IBounty {

    function redeemBounty(
        IBountyRedeemer redeemer,
        uint256 amount,
        bytes calldata data
    ) external;

}

interface IBountyRedeemer {

    function onRedeemBounty(address initiator, bytes calldata data)
        external
        payable
        returns (bytes32);

}

contract Bounty is
    ReentrancyGuardUpgradeable,
    ERC721HolderUpgradeable,
    IBounty
{

    using Counters for Counters.Counter;

    enum BountyStatus {
        ACTIVE,
        ACQUIRED,
        EXPIRED
    }

    struct Contribution {
        uint256 priorTotalContributed;
        uint256 amount;
    }

    uint16 internal constant TOKEN_SCALE = 1000;
    uint8 internal constant RESALE_MULTIPLIER = 2;

    address public immutable gov;
    IERC721VaultFactory public immutable tokenVaultFactory;

    IERC721 public nftContract;
    uint256 public nftTokenID;
    string public name;
    string public symbol;
    uint256 public contributionCap;
    uint256 public expiryTimestamp;

    mapping(address => Contribution[]) public contributions;
    mapping(address => uint256) public totalContributedByAddress;
    mapping(address => bool) public claimed;
    uint256 public totalContributed;
    uint256 public totalSpent;
    ITokenVault public tokenVault;
    Counters.Counter public contributors;

    event Contributed(address indexed contributor, uint256 amount);

    event Acquired(uint256 amount);

    event Claimed(
        address indexed contributor,
        uint256 tokenAmount,
        uint256 ethAmount
    );

    modifier onlyGov() {

        require(msg.sender == gov, "Bounty:: only callable by gov");
        _;
    }

    constructor(address _gov, IERC721VaultFactory _tokenVaultFactory) {
        gov = _gov;
        tokenVaultFactory = _tokenVaultFactory;
    }

    function initialize(
        IERC721 _nftContract,
        uint256 _nftTokenID,
        string memory _name,
        string memory _symbol,
        uint256 _contributionCap,
        uint256 _duration
    ) external initializer {

        __ReentrancyGuard_init();
        __ERC721Holder_init();

        nftContract = _nftContract;
        nftTokenID = _nftTokenID;
        name = _name;
        symbol = _symbol;
        contributionCap = _contributionCap;
        expiryTimestamp = block.timestamp + _duration;

        require(
            IERC721(nftContract).ownerOf(nftTokenID) != address(0),
            "Bounty::initialize: Token does not exist"
        );
    }

    function contribute() external payable nonReentrant {

        require(
            status() == BountyStatus.ACTIVE,
            "Bounty::contribute: bounty not active"
        );
        address _contributor = msg.sender;
        uint256 _amount = msg.value;
        require(_amount > 0, "Bounty::contribute: must contribute more than 0");
        require(
            contributionCap == 0 || totalContributed < contributionCap,
            "Bounty::contribute: at max contributions"
        );

        if (contributions[_contributor].length == 0) {
            contributors.increment();
        }

        Contribution memory _contribution = Contribution({
            amount: _amount,
            priorTotalContributed: totalContributed
        });
        contributions[_contributor].push(_contribution);
        totalContributedByAddress[_contributor] =
            totalContributedByAddress[_contributor] +
            _amount;
        totalContributed = totalContributed + _amount;
        emit Contributed(_contributor, _amount);
    }

    function redeemBounty(
        IBountyRedeemer _redeemer,
        uint256 _amount,
        bytes calldata _data
    ) external override nonReentrant {

        require(
            status() == BountyStatus.ACTIVE,
            "Bounty::redeemBounty: bounty isn't active"
        );
        require(totalSpent == 0, "Bounty::redeemBounty: already acquired");
        require(_amount > 0, "Bounty::redeemBounty: cannot redeem for free");
        require(
            _amount <= totalContributed && _amount <= contributionCap,
            "Bounty::redeemBounty: not enough funds"
        );
        totalSpent = _amount;
        require(
            _redeemer.onRedeemBounty{value: _amount}(msg.sender, _data) ==
                keccak256("IBountyRedeemer.onRedeemBounty"),
            "Bounty::redeemBounty: callback failed"
        );
        require(
            IERC721(nftContract).ownerOf(nftTokenID) == address(this),
            "Bounty::redeemBounty: NFT not delivered"
        );
        emit Acquired(_amount);
    }

    function fractionalize() external nonReentrant {

        require(
            status() == BountyStatus.ACQUIRED,
            "Bounty::fractionalize: NFT not yet acquired"
        );
        _fractionalizeNFTIfNeeded();
    }

    function claim(address _contributor) external nonReentrant {

        BountyStatus _status = status();
        require(
            _status != BountyStatus.ACTIVE,
            "Bounty::claim: bounty still active"
        );
        require(
            totalContributedByAddress[_contributor] != 0,
            "Bounty::claim: not a contributor"
        );
        require(
            !claimed[_contributor],
            "Bounty::claim: bounty already claimed"
        );
        claimed[_contributor] = true;

        if (_status == BountyStatus.ACQUIRED) {
            _fractionalizeNFTIfNeeded();
        }

        (uint256 _tokenAmount, uint256 _ethAmount) = claimAmounts(_contributor);

        if (_ethAmount > 0) {
            _transferETH(_contributor, _ethAmount);
        }
        if (_tokenAmount > 0) {
            _transferTokens(_contributor, _tokenAmount);
        }
        emit Claimed(_contributor, _tokenAmount, _ethAmount);
    }

    function emergencyWithdrawETH(uint256 _value) external onlyGov {

        _transferETH(gov, _value);
    }

    function emergencyCall(address _contract, bytes memory _calldata)
        external
        onlyGov
        returns (bool _success, bytes memory _returnData)
    {

        (_success, _returnData) = _contract.call(_calldata);
        require(_success, string(_returnData));
    }

    function emergencyExpire() external onlyGov {

        expiryTimestamp = block.timestamp;
    }

    function claimAmounts(address _contributor)
        public
        view
        returns (uint256 _tokenAmount, uint256 _ethAmount)
    {

        require(
            status() != BountyStatus.ACTIVE,
            "Bounty::claimAmounts: bounty still active"
        );
        if (totalSpent > 0) {
            uint256 _ethUsed = ethUsedForAcquisition(_contributor);
            if (_ethUsed > 0) {
                _tokenAmount = valueToTokens(_ethUsed);
            }
            _ethAmount = totalContributedByAddress[_contributor] - _ethUsed;
        } else {
            _ethAmount = totalContributedByAddress[_contributor];
        }
    }

    function ethUsedForAcquisition(address _contributor)
        public
        view
        returns (uint256 _total)
    {

        require(
            totalSpent > 0,
            "Bounty::ethUsedForAcquisition: NFT not acquired yet"
        );
        uint256 _totalSpent = totalSpent;
        Contribution[] memory _contributions = contributions[_contributor];
        for (uint256 _i = 0; _i < _contributions.length; _i++) {
            Contribution memory _contribution = _contributions[_i];
            if (
                _contribution.priorTotalContributed + _contribution.amount <=
                _totalSpent
            ) {
                _total = _total + _contribution.amount;
            } else if (_contribution.priorTotalContributed < _totalSpent) {
                uint256 _amountUsed = _totalSpent -
                    _contribution.priorTotalContributed;
                _total = _total + _amountUsed;
                break;
            } else {
                break;
            }
        }
    }

    function status() public view returns (BountyStatus) {

        if (totalSpent > 0) {
            return BountyStatus.ACQUIRED;
        } else if (block.timestamp >= expiryTimestamp) {
            return BountyStatus.EXPIRED;
        } else {
            return BountyStatus.ACTIVE;
        }
    }

    function valueToTokens(uint256 _value)
        public
        pure
        returns (uint256 _tokens)
    {

        _tokens = _value * TOKEN_SCALE;
    }

    function _transferETH(address _to, uint256 _value) internal {

        uint256 _balance = address(this).balance;
        if (_value > _balance) {
            _value = _balance;
        }
        payable(_to).transfer(_value);
    }

    function _transferTokens(address _to, uint256 _value) internal {

        uint256 _balance = tokenVault.balanceOf(address(this));
        if (_value > _balance) {
            _value = _balance;
        }
        tokenVault.transfer(_to, _value);
    }

    function _fractionalizeNFTIfNeeded() internal {

        if (address(tokenVault) != address(0)) {
            return;
        }
        IERC721(nftContract).approve(address(tokenVaultFactory), nftTokenID);
        uint256 _vaultNumber = tokenVaultFactory.mint(
            name,
            symbol,
            address(nftContract),
            nftTokenID,
            valueToTokens(totalSpent),
            totalSpent * RESALE_MULTIPLIER,
            0 // fees
        );
        tokenVault = ITokenVault(tokenVaultFactory.vaults(_vaultNumber));
        tokenVault.updateCurator(address(0));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT
pragma solidity ^0.8.3;


contract BountyFactory is ReentrancyGuard {

    event BountyDeployed(
        address indexed addressDeployed,
        address indexed creator,
        address nftContract,
        uint256 nftTokenID,
        string name,
        string symbol,
        uint256 contributionCap,
        bool indexed isPrivate
    );

    address public immutable logic;

    constructor(
        address _gov,
        IERC721VaultFactory _tokenVaultFactory,
        IERC721 _logicNftContract,
        uint256 _logicTokenID
    ) {
        Bounty _bounty = new Bounty(_gov, _tokenVaultFactory);
        _bounty.initialize(
            _logicNftContract,
            _logicTokenID,
            "BOUNTY",
            "BOUNTY",
            0, // contribution cap
            0 // duration (expired right away)
        );
        logic = address(_bounty);
    }

    function startBounty(
        IERC721 _nftContract,
        uint256 _nftTokenID,
        string memory _name,
        string memory _symbol,
        uint256 _contributionCap,
        uint256 _duration,
        bool _isPrivate
    ) external nonReentrant returns (address bountyAddress) {

        bountyAddress = Clones.clone(logic);
        Bounty(bountyAddress).initialize(
            _nftContract,
            _nftTokenID,
            _name,
            _symbol,
            _contributionCap,
            _duration
        );
        emit BountyDeployed(
            bountyAddress,
            msg.sender,
            address(_nftContract),
            _nftTokenID,
            _name,
            _symbol,
            _contributionCap,
            _isPrivate
        );
    }
}