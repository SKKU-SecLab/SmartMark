pragma solidity 0.8.9;

contract NonReceivableInitializedProxy {

    address public immutable logic;


    constructor(address _logic, bytes memory _initializationCalldata) {
        logic = _logic;
        (bool _ok, bytes memory returnData) = _logic.delegatecall(
            _initializationCalldata
        );
        require(_ok, string(returnData));
    }


    fallback() external payable {
        address _impl = logic;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal initializer {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal initializer {

    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}//MIT
pragma solidity 0.8.9;

interface IERC721VaultFactory {

    function vaults(uint256) external returns (address);


    function mint(string memory _name, string memory _symbol, address _token, uint256 _id, uint256 _supply, uint256 _listPrice, uint256 _fee) external returns(uint256);

}//MIT
pragma solidity 0.8.9;

interface ITokenVault {

    function updateCurator(address _curator) external;


    function transfer(address recipient, uint256 amount) external returns (bool);


    function balanceOf(address account) external view returns (uint256);

}// MIT
pragma solidity 0.8.9;

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);

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


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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
pragma solidity 0.8.9;

interface Structs {

    struct AddressAndAmount {
        address addr;
        uint256 amount;
    }
}/*
__/\\\\\\\\\\\\\_____________________________________________________________/\\\\\\\\\\\\________/\\\\\\\\\__________/\\\\\______
 _\/\\\/////////\\\__________________________________________________________\/\\\////////\\\____/\\\\\\\\\\\\\______/\\\///\\\____
  _\/\\\_______\/\\\__________________________________/\\\_________/\\\__/\\\_\/\\\______\//\\\__/\\\/////////\\\___/\\\/__\///\\\__
   _\/\\\\\\\\\\\\\/___/\\\\\\\\\_____/\\/\\\\\\\___/\\\\\\\\\\\___\//\\\/\\\__\/\\\_______\/\\\_\/\\\_______\/\\\__/\\\______\//\\\_
    _\/\\\/////////____\////////\\\___\/\\\/////\\\_\////\\\////_____\//\\\\\___\/\\\_______\/\\\_\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_
     _\/\\\_______________/\\\\\\\\\\__\/\\\___\///_____\/\\\__________\//\\\____\/\\\_______\/\\\_\/\\\/////////\\\_\//\\\______/\\\__
      _\/\\\______________/\\\/////\\\__\/\\\____________\/\\\_/\\___/\\_/\\\_____\/\\\_______/\\\__\/\\\_______\/\\\__\///\\\__/\\\____
       _\/\\\_____________\//\\\\\\\\/\\_\/\\\____________\//\\\\\___\//\\\\/______\/\\\\\\\\\\\\/___\/\\\_______\/\\\____\///\\\\\/_____
        _\///_______________\////////\//__\///______________\/////_____\////________\////////////_____\///________\///_______\/////_______

Anna Carroll for PartyDAO
*/

pragma solidity 0.8.9;


contract Party is ReentrancyGuardUpgradeable, ERC721HolderUpgradeable {


    enum PartyStatus {
        ACTIVE,
        WON,
        LOST
    }


    struct Contribution {
        uint256 amount;
        uint256 previousTotalContributedToParty;
    }


    uint16 internal constant TOKEN_SCALE = 1000;
    uint16 internal constant ETH_FEE_BASIS_POINTS = 250;
    uint16 internal constant TOKEN_FEE_BASIS_POINTS = 250;
    uint8 internal constant RESALE_MULTIPLIER = 2;


    address public immutable partyFactory;
    address public immutable partyDAOMultisig;
    IERC721VaultFactory public immutable tokenVaultFactory;
    IWETH public immutable weth;


    IERC721Metadata public nftContract;
    uint256 public tokenId;
    ITokenVault public tokenVault;
    address public splitRecipient;
    uint256 public splitBasisPoints;
    IERC20 public gatedToken;
    uint256 public gatedTokenAmount;
    string public name;
    string public symbol;


    PartyStatus public partyStatus;
    uint256 public totalContributedToParty;
    uint256 public totalSpent;
    mapping(address => Contribution[]) public contributions;
    mapping(address => uint256) public totalContributed;
    mapping(address => bool) public claimed;


    event Contributed(
        address indexed contributor,
        uint256 amount,
        uint256 previousTotalContributedToParty,
        uint256 totalFromContributor
    );

    event Claimed(
        address indexed contributor,
        uint256 totalContributed,
        uint256 excessContribution,
        uint256 tokenAmount
    );


    modifier onlyPartyDAO() {

        require(
            msg.sender == partyDAOMultisig,
            "Party:: only PartyDAO multisig"
        );
        _;
    }


    constructor(
        address _partyDAOMultisig,
        address _tokenVaultFactory,
        address _weth
    ) {
        partyFactory = msg.sender;
        partyDAOMultisig = _partyDAOMultisig;
        tokenVaultFactory = IERC721VaultFactory(_tokenVaultFactory);
        weth = IWETH(_weth);
    }


    function __Party_init(
        address _nftContract,
        Structs.AddressAndAmount calldata _split,
        Structs.AddressAndAmount calldata _tokenGate,
        string memory _name,
        string memory _symbol
    ) internal {

        require(
            msg.sender == partyFactory,
            "Party::__Party_init: only factory can init"
        );
        if (_split.addr != address(0) && _split.amount != 0) {
            uint256 _remainingBasisPoints = 10000 - TOKEN_FEE_BASIS_POINTS;
            require(
                _split.amount < _remainingBasisPoints,
                "Party::__Party_init: basis points can't take 100%"
            );
            splitBasisPoints = _split.amount;
            splitRecipient = _split.addr;
        }
        if (_tokenGate.addr != address(0) && _tokenGate.amount != 0) {
            IERC20(_tokenGate.addr).totalSupply();
            gatedToken = IERC20(_tokenGate.addr);
            gatedTokenAmount = _tokenGate.amount;
        }
        __ReentrancyGuard_init();
        __ERC721Holder_init();
        nftContract = IERC721Metadata(_nftContract);
        name = _name;
        symbol = _symbol;
    }


    function _contribute() internal {

        require(
            partyStatus == PartyStatus.ACTIVE,
            "Party::contribute: party not active"
        );
        address _contributor = msg.sender;
        uint256 _amount = msg.value;
        if (address(gatedToken) != address(0)) {
            require(
                gatedToken.balanceOf(_contributor) >= gatedTokenAmount,
                "Party::contribute: must hold tokens to contribute"
            );
        }
        require(_amount > 0, "Party::contribute: must contribute more than 0");
        uint256 _previousTotalContributedToParty = totalContributedToParty;
        Contribution memory _contribution = Contribution({
            amount: _amount,
            previousTotalContributedToParty: _previousTotalContributedToParty
        });
        contributions[_contributor].push(_contribution);
        totalContributed[_contributor] =
            totalContributed[_contributor] +
            _amount;
        totalContributedToParty = _previousTotalContributedToParty + _amount;
        emit Contributed(
            _contributor,
            _amount,
            _previousTotalContributedToParty,
            totalContributed[_contributor]
        );
    }


    function claim(address _contributor) external nonReentrant {

        require(
            partyStatus != PartyStatus.ACTIVE,
            "Party::claim: party not finalized"
        );
        require(
            totalContributed[_contributor] != 0,
            "Party::claim: not a contributor"
        );
        require(
            !claimed[_contributor],
            "Party::claim: contribution already claimed"
        );
        claimed[_contributor] = true;
        (uint256 _tokenAmount, uint256 _ethAmount) = getClaimAmounts(
            _contributor
        );
        _transferTokens(_contributor, _tokenAmount);
        _transferETHOrWETH(_contributor, _ethAmount);
        emit Claimed(
            _contributor,
            totalContributed[_contributor],
            _ethAmount,
            _tokenAmount
        );
    }


    function emergencyWithdrawEth(uint256 _value) external onlyPartyDAO {

        _transferETHOrWETH(partyDAOMultisig, _value);
    }

    function emergencyCall(address _contract, bytes memory _calldata)
        external
        onlyPartyDAO
        returns (bool _success, bytes memory _returnData)
    {

        (_success, _returnData) = _contract.call(_calldata);
        require(_success, string(_returnData));
    }

    function emergencyForceLost() external onlyPartyDAO {

        partyStatus = PartyStatus.LOST;
    }


    function valueToTokens(uint256 _value)
        public
        pure
        returns (uint256 _tokens)
    {

        _tokens = _value * TOKEN_SCALE;
    }

    function getMaximumSpend() public view returns (uint256 _maxSpend) {

        _maxSpend =
            (totalContributedToParty * 10000) /
            (10000 + ETH_FEE_BASIS_POINTS);
    }

    function getClaimAmounts(address _contributor)
        public
        view
        returns (uint256 _tokenAmount, uint256 _ethAmount)
    {

        require(
            partyStatus != PartyStatus.ACTIVE,
            "Party::getClaimAmounts: party still active; amounts undetermined"
        );
        uint256 _totalContributed = totalContributed[_contributor];
        if (partyStatus == PartyStatus.WON) {
            uint256 _totalEthUsed = totalEthUsed(_contributor);
            if (_totalEthUsed > 0) {
                _tokenAmount = valueToTokens(_totalEthUsed);
            }
            _ethAmount = _totalContributed - _totalEthUsed;
        } else {
            _ethAmount = _totalContributed;
        }
    }

    function totalEthUsed(address _contributor)
        public
        view
        returns (uint256 _total)
    {

        require(
            partyStatus != PartyStatus.ACTIVE,
            "Party::totalEthUsed: party still active; amounts undetermined"
        );
        uint256 _totalSpent = totalSpent;
        Contribution[] memory _contributions = contributions[_contributor];
        for (uint256 i = 0; i < _contributions.length; i++) {
            uint256 _amount = _ethUsed(_totalSpent, _contributions[i]);
            if (_amount == 0) break;
            _total = _total + _amount;
        }
    }


    function _closeSuccessfulParty(uint256 _nftCost)
        internal
        returns (uint256 _ethFee)
    {

        _ethFee = _getEthFee(_nftCost);
        totalSpent = _nftCost + _ethFee;
        _transferETHOrWETH(partyDAOMultisig, _ethFee);
        _fractionalizeNFT(_nftCost);
    }

    function _getEthFee(uint256 _amount) internal pure returns (uint256 _fee) {

        _fee = (_amount * ETH_FEE_BASIS_POINTS) / 10000;
    }

    function _getTokenInflationAmounts(uint256 _amountSpent)
        internal
        view
        returns (
            uint256 _totalSupply,
            uint256 _partyDAOAmount,
            uint256 _splitRecipientAmount
        )
    {

        uint256 inflationBasisPoints = TOKEN_FEE_BASIS_POINTS +
            splitBasisPoints;
        _totalSupply = valueToTokens(
            (_amountSpent * 10000) / (10000 - inflationBasisPoints)
        );
        _partyDAOAmount = (_totalSupply * TOKEN_FEE_BASIS_POINTS) / 10000;
        _splitRecipientAmount = (_totalSupply * splitBasisPoints) / 10000;
    }

    function _getOwner() internal view returns (address _owner) {

        (bool _success, bytes memory _returnData) = address(nftContract)
            .staticcall(abi.encodeWithSignature("ownerOf(uint256)", tokenId));
        if (_success && _returnData.length > 0) {
            _owner = abi.decode(_returnData, (address));
        }
    }

    function _fractionalizeNFT(uint256 _amountSpent) internal {

        nftContract.approve(address(tokenVaultFactory), tokenId);
        uint256 _listPrice = RESALE_MULTIPLIER * _amountSpent;
        (
            uint256 _tokenSupply,
            uint256 _partyDAOAmount,
            uint256 _splitRecipientAmount
        ) = _getTokenInflationAmounts(totalSpent);
        uint256 vaultNumber = tokenVaultFactory.mint(
            name,
            symbol,
            address(nftContract),
            tokenId,
            _tokenSupply,
            _listPrice,
            0
        );
        tokenVault = ITokenVault(tokenVaultFactory.vaults(vaultNumber));
        tokenVault.updateCurator(address(0));
        _transferTokens(partyDAOMultisig, _partyDAOAmount);
        if (splitRecipient != address(0)) {
            _transferTokens(splitRecipient, _splitRecipientAmount);
        }
    }


    function _ethUsed(uint256 _totalSpent, Contribution memory _contribution)
        internal
        pure
        returns (uint256)
    {

        if (
            _contribution.previousTotalContributedToParty +
                _contribution.amount <=
            _totalSpent
        ) {
            return _contribution.amount;
        } else if (
            _contribution.previousTotalContributedToParty < _totalSpent
        ) {
            return _totalSpent - _contribution.previousTotalContributedToParty;
        }
        return 0;
    }


    function _transferTokens(address _to, uint256 _value) internal {

        if (_value == 0) {
            return;
        }
        uint256 _partyBalance = tokenVault.balanceOf(address(this));
        if (_value > _partyBalance) {
            _value = _partyBalance;
        }
        tokenVault.transfer(_to, _value);
    }


    function _transferETHOrWETH(address _to, uint256 _value) internal {

        if (_value == 0) {
            return;
        }
        if (_value > address(this).balance) {
            _value = address(this).balance;
        }
        if (!_attemptETHTransfer(_to, _value)) {
            weth.deposit{value: _value}();
            weth.transfer(_to, _value);
        }
    }

    function _attemptETHTransfer(address _to, uint256 _value)
        internal
        returns (bool)
    {

        (bool success, ) = _to.call{value: _value, gas: 30000}("");
        return success;
    }
}// MIT
pragma solidity 0.8.9;

interface IAllowList {

    function allowed(address _addr) external view returns (bool _bool);

}/*
                                                                                     .-'''-.
                                                             _______                '   _    \
_________   _...._                                           \  ___ `'.           /   /` '.   \
\        |.'      '-.                          .-.          .-' |--.\  \         .   |     \  '
 \        .'```'.    '.          .-,.--.      .|\ \        / /| |    \  '        |   '      |  '
  \      |       \     \   __    |  .-. |   .' |_\ \      / / | |     |  '    __ \    \     / /
   |     |        |    |.:--.'.  | |  | | .'     |\ \    / /  | |     |  | .:--.'.`.   ` ..' /
   |      \      /    ./ |   \ | | |  | |'--.  .-' \ \  / /   | |     ' .'/ |   \ |  '-...-'`
   |     |\`'-.-'   .' `" __ | | | |  '-    |  |    \ `  /    | |___.' /' `" __ | |
   |     | '-....-'`    .'.''| | | |        |  |     \  /    /_______.'/   .'.''| |
  .'     '.            / /   | |_| |        |  '.'   / /     \_______|/   / /   | |_
'-----------'          \ \._,\ '/|_|        |   /|`-' /                   \ \._,\ '/
                        `--'  `"            `'-'  '..'                     `--'  `"
Anna Carroll for PartyDAO
*/

pragma solidity 0.8.9;


contract CollectionParty is Party {



    uint16 public constant VERSION = 1;
    string public constant PARTY_TYPE = "Collection";


    IAllowList public immutable allowList;


    uint256 public expiresAt;
    uint256 public maxPrice;
    mapping(address => bool) public isDecider;


    event Bought(
        uint256 tokenId,
        address triggeredBy,
        address targetAddress,
        uint256 ethSpent,
        uint256 ethFeePaid,
        uint256 totalContributed
    );

    event Expired(address triggeredBy);


    constructor(
        address _partyDAOMultisig,
        address _tokenVaultFactory,
        address _weth,
        address _allowList
    ) Party(_partyDAOMultisig, _tokenVaultFactory, _weth) {
        allowList = IAllowList(_allowList);
    }


    function initialize(
        address _nftContract,
        uint256 _maxPrice,
        uint256 _secondsToTimeout,
        address[] calldata _deciders,
        Structs.AddressAndAmount calldata _split,
        Structs.AddressAndAmount calldata _tokenGate,
        string memory _name,
        string memory _symbol
    ) external initializer {

        __Party_init(_nftContract, _split, _tokenGate, _name, _symbol);
        expiresAt = block.timestamp + _secondsToTimeout;
        maxPrice = _maxPrice;
        getMaximumContributions();
        require(
            _deciders.length > 0,
            "PartyBuy::initialize: set at least one decider"
        );
        for (uint256 i = 0; i < _deciders.length; i++) {
            isDecider[_deciders[i]] = true;
        }
    }


    function contribute() external payable nonReentrant {

        require(
            totalContributedToParty + msg.value <= getMaximumContributions(),
            "PartyBuy::contribute: cannot contribute more than max"
        );
        _contribute();
    }


    function buy(
        uint256 _tokenId,
        uint256 _value,
        address _targetContract,
        bytes calldata _calldata
    ) external nonReentrant {

        require(
            partyStatus == PartyStatus.ACTIVE,
            "PartyBuy::buy: party not active"
        );
        require(isDecider[msg.sender], "PartyBuy::buy: caller not a decider");
        require(
            allowList.allowed(_targetContract),
            "PartyBuy::buy: targetContract not on AllowList"
        );
        require(_value > 0, "PartyBuy::buy: can't spend zero");
        require(
            maxPrice == 0 || _value <= maxPrice,
            "PartyBuy::buy: can't spend over max price"
        );
        require(
            _value <= getMaximumSpend(),
            "PartyBuy::buy: insuffucient funds to buy token plus fee"
        );
        tokenId = _tokenId;
        require(
            _getOwner() != address(this),
            "PartyBuy::buy: own token before call"
        );
        (bool _success, bytes memory _returnData) = address(_targetContract)
            .call{value: _value}(_calldata);
        require(_success, string(_returnData));
        require(
            _getOwner() == address(this),
            "PartyBuy::buy: failed to buy token"
        );
        partyStatus = PartyStatus.WON;
        uint256 _ethFee = _closeSuccessfulParty(_value);
        emit Bought(
            _tokenId,
            msg.sender,
            _targetContract,
            _value,
            _ethFee,
            totalContributedToParty
        );
    }


    function expire() external nonReentrant {

        require(
            partyStatus == PartyStatus.ACTIVE,
            "PartyBuy::expire: party not active"
        );
        require(
            expiresAt <= block.timestamp,
            "PartyBuy::expire: party has not timed out"
        );
        partyStatus = PartyStatus.LOST;
        emit Expired(msg.sender);
    }


    function getMaximumContributions()
        public
        view
        returns (uint256 _maxContributions)
    {

        uint256 _price = maxPrice;
        if (_price == 0) {
            return 2**256 - 1; // max-int
        }
        _maxContributions = _price + _getEthFee(_price);
    }
}// MIT
pragma solidity 0.8.9;


contract CollectionPartyFactory {


    event CollectionPartyDeployed(
        address indexed partyProxy,
        address indexed creator,
        address indexed nftContract,
        uint256 maxPrice,
        uint256 secondsToTimeout,
        address[] deciders,
        address splitRecipient,
        uint256 splitBasisPoints,
        address gatedToken,
        uint256 gatedTokenAmount,
        string name,
        string symbol
    );


    address public immutable logic;
    address public immutable partyDAOMultisig;
    address public immutable tokenVaultFactory;
    address public immutable weth;


    mapping(address => uint256) public deployedAt;


    constructor(
        address _partyDAOMultisig,
        address _tokenVaultFactory,
        address _weth,
        address _allowList
    ) {
        partyDAOMultisig = _partyDAOMultisig;
        tokenVaultFactory = _tokenVaultFactory;
        weth = _weth;
        CollectionParty _logicContract = new CollectionParty(
            _partyDAOMultisig,
            _tokenVaultFactory,
            _weth,
            _allowList
        );
        logic = address(_logicContract);
    }


    function startParty(
        address _nftContract,
        uint256 _maxPrice,
        uint256 _secondsToTimeout,
        address[] calldata _deciders,
        Structs.AddressAndAmount calldata _split,
        Structs.AddressAndAmount calldata _tokenGate,
        string memory _name,
        string memory _symbol
    ) external returns (address partyProxy) {

        bytes memory _initializationCalldata = abi.encodeWithSelector(
            CollectionParty.initialize.selector,
            _nftContract,
            _maxPrice,
            _secondsToTimeout,
            _deciders,
            _split,
            _tokenGate,
            _name,
            _symbol
        );

        partyProxy = address(
            new NonReceivableInitializedProxy(logic, _initializationCalldata)
        );

        deployedAt[partyProxy] = block.number;

        emit CollectionPartyDeployed(
            partyProxy,
            msg.sender,
            _nftContract,
            _maxPrice,
            _secondsToTimeout,
            _deciders,
            _split.addr,
            _split.amount,
            _tokenGate.addr,
            _tokenGate.amount,
            _name,
            _symbol
        );
    }
}