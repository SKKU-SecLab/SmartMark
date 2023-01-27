
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// GPL-3.0
pragma solidity ^0.8.0;

struct LockOption {
    uint256 minAmount; // e.g. 0QSTK, 100QSTK, 200QSTK, 300QSTK
    uint256 maxAmount; // e.g. 0QSTK, 100QSTK, 200QSTK, 300QSTK
    uint32 lockDuration; // e.g. 3 months, 6 months, 1 year
    uint8 discount; // percent e.g. 10%, 20%, 30%
}

struct NFTData {
    uint32 characterId;
    uint32 favCoinId;
    uint32 metaId;
    uint32 unlockTime;
    uint256 lockAmount;
}// GPL-3.0
pragma solidity ^0.8.0;

interface IQNFTSettings {

    function favCoinsCount() external view returns (uint256);


    function lockOptionsCount() external view returns (uint256);


    function characterCount() external view returns (uint256);


    function characterPrice(uint32 characterId) external view returns (uint256);


    function favCoinPrices(uint32 favCoinId) external view returns (uint256);


    function lockOptionLockDuration(uint32 lockOptionId)
        external
        view
        returns (uint32);


    function characterMaxSupply(uint32 characterId)
        external
        view
        returns (uint256);


    function calcMintPrice(
        uint32 _characterId,
        uint32 _favCoinId,
        uint32 _lockOptionId,
        uint256 _lockAmount,
        uint256 _freeAmount
    )
        external
        view
        returns (
            uint256 totalPrice,
            uint256 tokenPrice,
            uint256 nonTokenPrice
        );


    function mintStarted() external view returns (bool);


    function mintPaused() external view returns (bool);


    function mintStartTime() external view returns (uint256);


    function mintEndTime() external view returns (uint256);


    function mintFinished() external view returns (bool);


    function onlyAirdropUsers() external view returns (bool);


    function transferAllowedAfterRedeem() external view returns (bool);


    function upgradePriceMultiplier() external view returns (uint256);

}// GPL-3.0
pragma solidity ^0.8.0;

interface IQSettings {

    function getManager() external view returns (address);


    function getFoundationWallet() external view returns (address);


    function getQStk() external view returns (address);


    function getQAirdrop() external view returns (address);


    function getQNftSettings() external view returns (address);


    function getQNftGov() external view returns (address);


    function getQNft() external view returns (address);

}// GPL-3.0
pragma solidity ^0.8.0;



contract QNFTSettings is IQNFTSettings, ContextUpgradeable {

    event SetPriceMultipliers(
        uint256 tokenPriceMultiplier,
        uint256 nonTokenPriceMultiplier,
        uint256 upgradePriceMultiplier
    );
    event AddLockOption(
        uint256 minAmount,
        uint256 maxAmount,
        uint32 lockDuration,
        uint8 discount // percent
    );
    event UpdateLockOption(
        uint32 indexed lockOptionId,
        uint256 minAmount,
        uint256 maxAmount,
        uint32 lockDuration,
        uint8 discount // percent
    );
    event AddCharacters(uint256[] prices, uint256 maxSupply);
    event UpdateCharacterPrice(uint32 indexed characterId, uint256 price);
    event UpdateCharacterPrices(
        uint32 startIndex,
        uint32 length,
        uint256 price
    );
    event UpdateCharacterPricesFromArray(uint32[] indexes, uint256[] prices);
    event UpdateCharacterMaxSupply(
        uint32 indexed characterId,
        uint256 maxSupply
    );
    event UpdateCharacterMaxSupplies(
        uint32 startIndex,
        uint32 length,
        uint256 supply
    );
    event UpdateCharacterMaxSuppliesFromArray(
        uint32[] indexes,
        uint256[] supplies
    );
    event AddFavCoinPrices(uint256[] mintPrices);
    event UpdateFavCoinPrice(uint32 favCoinId, uint256 price);
    event StartMint(uint256 startedAt);
    event EndMint();
    event PauseMint(uint256 pausedAt);
    event UnpauseMint(uint256 unPausedAt);

    uint32 public NFT_SALE_DURATION; // default: 2 weeks

    uint256 public qstkPrice; // qstk price
    uint256 public nonTokenPriceMultiplier; // percentage - should be multiplied to non token price - image + favorite coin
    uint256 public tokenPriceMultiplier; // percentage - should be multiplied to token price - qstk
    uint256 public override upgradePriceMultiplier; // percentage - should be multiplied to coin mint price - favorite coin - used for favorite coin upgrade price calculation

    LockOption[] public lockOptions; // array of lock options
    uint256[] private _characterPrices; // array of character purchase prices
    uint256[] private _characterMaxSupply; // limitation count for the given character
    uint256[] private _favCoinPrices; // array of favorite coin purchase prices

    uint256 public override mintStartTime;
    bool public override mintStarted;
    bool public override mintPaused;
    bool public override onlyAirdropUsers;

    bool public override transferAllowedAfterRedeem;

    IQSettings public settings; // QSettings contract address

    modifier onlyManager() {

        require(
            settings.getManager() == msg.sender,
            "QNFTSettings: caller is not the manager"
        );
        _;
    }

    function initialize(
        address _settings,
        uint256 _qstkPrice,
        uint256 _tokenPriceMultiplier,
        uint256 _nonTokenPriceMultiplier,
        uint256 _upgradePriceMultiplier,
        uint32 _nftSaleDuration
    ) external initializer {

        __Context_init();

        settings = IQSettings(_settings);
        qstkPrice = _qstkPrice;
        nonTokenPriceMultiplier = _nonTokenPriceMultiplier;
        tokenPriceMultiplier = _tokenPriceMultiplier;
        upgradePriceMultiplier = _upgradePriceMultiplier;
        NFT_SALE_DURATION = _nftSaleDuration;

        onlyAirdropUsers = true;
    }

    function lockOptionsCount() public view override returns (uint256) {

        return lockOptions.length;
    }

    function lockOptionLockDuration(uint32 _lockOptionId)
        external
        view
        override
        returns (uint32)
    {

        require(
            _lockOptionId < lockOptions.length,
            "QNFTSettings: invalid lock option"
        );

        return lockOptions[_lockOptionId].lockDuration;
    }

    function addLockOption(
        uint256 _minAmount,
        uint256 _maxAmount,
        uint32 _lockDuration,
        uint8 _discount
    ) external onlyManager {

        require(_discount <= 100, "QNFTSettings: invalid discount");
        lockOptions.push(
            LockOption(_minAmount, _maxAmount, _lockDuration, _discount)
        );

        emit AddLockOption(_minAmount, _maxAmount, _lockDuration, _discount);
    }

    function updateLockOption(
        uint32 _lockOptionId,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint32 _lockDuration,
        uint8 _discount
    ) external onlyManager {

        require(
            lockOptions.length > _lockOptionId,
            "QNFTSettings: invalid lock option id"
        );
        require(_discount <= 100, "QNFTSettings: invalid discount");

        lockOptions[_lockOptionId] = LockOption(
            _minAmount,
            _maxAmount,
            _lockDuration,
            _discount
        );

        emit UpdateLockOption(
            _lockOptionId,
            _minAmount,
            _maxAmount,
            _lockDuration,
            _discount
        );
    }

    function characterPrice(uint32 _characterId)
        external
        view
        override
        returns (uint256)
    {

        return _characterPrices[_characterId];
    }

    function characterCount() public view override returns (uint256) {

        return _characterPrices.length;
    }

    function addCharacters(uint256[] memory _prices, uint256 _maxSupply)
        external
        onlyManager
    {

        for (uint256 i = 0; i < _prices.length; i++) {
            _characterPrices.push(_prices[i]);
            _characterMaxSupply.push(_maxSupply);
        }

        emit AddCharacters(_prices, _maxSupply);
    }

    function updateCharacterPrice(uint32 _characterId, uint256 _price)
        external
        onlyManager
    {

        require(
            _characterPrices.length > _characterId,
            "QNFTSettings: invalid character id"
        );

        _characterPrices[_characterId] = _price;

        emit UpdateCharacterPrice(_characterId, _price);
    }

    function updateCharacterPrices(
        uint32 _startIndex,
        uint32 _length,
        uint256 _price
    ) external onlyManager {

        require(
            _characterPrices.length >= _startIndex + _length,
            "QNFTSettings: invalid character ids range"
        );

        for (uint256 i = 0; i < _length; i++) {
            _characterPrices[_startIndex + i] = _price;
        }

        emit UpdateCharacterPrices(_startIndex, _length, _price);
    }

    function updateCharacterPricesFromArray(
        uint32[] memory _indexes,
        uint256[] memory _prices
    ) external onlyManager {

        require(
            _indexes.length == _prices.length,
            "QNFTSettings: length doesn't match"
        );

        for (uint256 i = 0; i < _indexes.length; i++) {
            require(
                _indexes[i] < _characterPrices.length,
                "QNFTSettings: invalid index"
            );
            _characterPrices[_indexes[i]] = _prices[i];
        }

        emit UpdateCharacterPricesFromArray(_indexes, _prices);
    }

    function characterMaxSupply(uint32 _characterId)
        external
        view
        override
        returns (uint256)
    {

        return _characterMaxSupply[_characterId];
    }

    function updateCharacterMaxSupply(uint32 _characterId, uint256 _maxSupply)
        external
        onlyManager
    {

        require(
            _characterMaxSupply.length > _characterId,
            "QNFTSettings: invalid character id"
        );

        _characterMaxSupply[_characterId] = _maxSupply;

        emit UpdateCharacterMaxSupply(_characterId, _maxSupply);
    }

    function updateCharacterMaxSupplies(
        uint32 _startIndex,
        uint32 _length,
        uint256 _supply
    ) external onlyManager {

        require(
            _characterMaxSupply.length >= _startIndex + _length,
            "QNFTSettings: invalid character ids range"
        );

        for (uint256 i = 0; i < _length; i++) {
            _characterMaxSupply[_startIndex + i] = _supply;
        }

        emit UpdateCharacterMaxSupplies(_startIndex, _length, _supply);
    }

    function updateCharacterMaxSuppliesFromArray(
        uint32[] memory _indexes,
        uint256[] memory _supplies
    ) external onlyManager {

        require(
            _indexes.length == _supplies.length,
            "QNFTSettings: length doesn't match"
        );

        for (uint256 i = 0; i < _indexes.length; i++) {
            require(
                _indexes[i] < _characterMaxSupply.length,
                "QNFTSettings: invalid index"
            );
            _characterMaxSupply[_indexes[i]] = _supplies[i];
        }

        emit UpdateCharacterMaxSuppliesFromArray(_indexes, _supplies);
    }

    function favCoinPrices(uint32 _favCoinId)
        external
        view
        override
        returns (uint256)
    {

        return _favCoinPrices[_favCoinId];
    }

    function favCoinsCount() public view override returns (uint256) {

        return _favCoinPrices.length;
    }

    function addFavCoinPrices(uint256[] memory _prices) external onlyManager {

        for (uint16 i = 0; i < _prices.length; i++) {
            _favCoinPrices.push(_prices[i]);
        }

        emit AddFavCoinPrices(_prices);
    }

    function updateFavCoinPrice(uint32 _favCoinId, uint256 _price)
        external
        onlyManager
    {

        require(_favCoinPrices.length > _favCoinId, "QNFTSettings: invalid id");

        _favCoinPrices[_favCoinId] = _price;

        emit UpdateFavCoinPrice(_favCoinId, _price);
    }

    function calcMintPrice(
        uint32 _characterId,
        uint32 _favCoinId,
        uint32 _lockOptionId,
        uint256 _lockAmount,
        uint256 _freeAmount
    )
        external
        view
        override
        returns (
            uint256 totalPrice,
            uint256 tokenPrice,
            uint256 nonTokenPrice
        )
    {

        require(
            characterCount() > _characterId,
            "QNFTSettings: invalid character option"
        );
        require(
            lockOptionsCount() > _lockOptionId,
            "QNFTSettings: invalid lock option"
        );
        require(favCoinsCount() > _favCoinId, "QNFTSettings: invalid fav coin");

        LockOption memory lockOption = lockOptions[_lockOptionId];

        require(
            lockOption.minAmount <= _lockAmount + _freeAmount &&
                _lockAmount <= lockOption.maxAmount,
            "QNFTSettings: invalid mint amount"
        );


        uint256 decimal =
            IERC20MetadataUpgradeable(settings.getQStk()).decimals();
        tokenPrice =
            (qstkPrice *
                _lockAmount *
                (100 - lockOption.discount) *
                tokenPriceMultiplier) /
            (10**decimal) /
            10000;

        nonTokenPrice =
            ((_characterPrices[_characterId] + _favCoinPrices[_favCoinId]) *
                nonTokenPriceMultiplier) /
            100;

        totalPrice = tokenPrice + nonTokenPrice;
    }

    function setPriceMultipliers(
        uint256 _tokenPriceMultiplier,
        uint256 _nonTokenPriceMultiplier,
        uint256 _upgradePriceMultiplier
    ) external onlyManager {

        tokenPriceMultiplier = _tokenPriceMultiplier;
        nonTokenPriceMultiplier = _nonTokenPriceMultiplier;
        upgradePriceMultiplier = _upgradePriceMultiplier;

        emit SetPriceMultipliers(
            _tokenPriceMultiplier,
            _nonTokenPriceMultiplier,
            _upgradePriceMultiplier
        );
    }

    function startMint() external onlyManager {

        mintStarted = true;
        mintStartTime = block.timestamp;
        mintPaused = false;

        emit StartMint(mintStartTime);
    }

    function endMint() external onlyManager {

        require(
            mintStarted == true && !mintFinished(),
            "QNFTSettings: mint not in progress"
        );
        mintStartTime = block.timestamp - NFT_SALE_DURATION;

        emit EndMint();
    }

    function pauseMint() external onlyManager {

        require(
            mintStarted == true && !mintFinished(),
            "QNFTSettings: mint not in progress"
        );
        require(mintPaused == false, "QNFTSettings: mint already paused");

        mintPaused = true;

        emit PauseMint(block.timestamp);
    }

    function unPauseMint() external onlyManager {

        require(
            mintStarted == true && !mintFinished(),
            "QNFTSettings: mint not in progress"
        );
        require(mintPaused == true, "QNFTSettings: mint not paused");

        mintPaused = false;

        emit UnpauseMint(block.timestamp);
    }

    function mintEndTime() public view override returns (uint256) {

        return mintStartTime + NFT_SALE_DURATION;
    }

    function mintFinished() public view override returns (bool) {

        return mintStarted && mintEndTime() <= block.timestamp;
    }

    function setOnlyAirdropUsers(bool _onlyAirdropUsers) external onlyManager {

        onlyAirdropUsers = _onlyAirdropUsers;
    }

    function setTransferAllowedAfterRedeem(bool _allow) external onlyManager {

        transferAllowedAfterRedeem = _allow;
    }

    function setSettings(IQSettings _settings) external onlyManager {

        settings = _settings;
    }
}