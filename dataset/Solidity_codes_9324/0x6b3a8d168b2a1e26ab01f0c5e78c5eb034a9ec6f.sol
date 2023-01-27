
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



contract QSettings is IQSettings, Initializable {

    event SetAdmin(address indexed admin);
    event SetManager(address indexed executor, address indexed manager);
    event SetFoundationWallet(address indexed foundationWallet);
    event SetFoundation(address indexed foundation);

    address private admin; // should be the dao address who will set the manager address.
    address private manager; // manager address who will manage overall Quiver contracts.

    address private foundation; // foundation address who can change the foundationWallet address.
    address private foundationWallet; // foundation wallet to withdraw rewards to.

    address private qstk;
    address private qAirdrop;
    address private qNftSettings;
    address private qNftGov;
    address private qNft;

    modifier onlyAdmin() {

        require(msg.sender == admin, "QSettings: caller is not the admin");
        _;
    }

    modifier onlyManager() {

        require(msg.sender == manager, "QSettings: caller is not the manager");
        _;
    }

    modifier onlyFoundation() {

        require(
            msg.sender == foundation,
            "QSettings: caller is not the foundation"
        );
        _;
    }

    function initialize(
        address _admin,
        address _manager,
        address _foundation,
        address _foundationWallet
    ) external initializer {

        admin = _admin;
        manager = _manager;
        foundation = _foundation;
        foundationWallet = _foundationWallet;
    }

    function setAddresses(
        address _qstk,
        address _qAirdrop,
        address _qNftSettings,
        address _qNftGov,
        address _qNft
    ) external {

        qstk = _qstk;
        qAirdrop = _qAirdrop;
        qNftSettings = _qNftSettings;
        qNftGov = _qNftGov;
        qNft = _qNft;
    }

    function setAdmin(address _admin) external onlyAdmin {

        admin = _admin;

        emit SetAdmin(_admin);
    }

    function getAdmin() external view returns (address) {

        return admin;
    }

    function setManager(address _manager) external {

        require(
            msg.sender == admin || msg.sender == manager,
            "QSettings: caller is not the admin nor manager"
        );

        manager = _manager;

        emit SetManager(msg.sender, _manager);
    }

    function getManager() external view override returns (address) {

        return manager;
    }

    function setFoundation(address _foundation) external onlyFoundation {

        foundation = _foundation;

        emit SetFoundation(_foundation);
    }

    function getFoundation() external view returns (address) {

        return foundation;
    }

    function setFoundationWallet(address _foundationWallet)
        external
        onlyFoundation
    {

        foundationWallet = _foundationWallet;

        emit SetFoundationWallet(_foundationWallet);
    }

    function getFoundationWallet() external view override returns (address) {

        return foundationWallet;
    }

    function getQStk() external view override returns (address) {

        return qstk;
    }

    function setQAirdrop(address _qAirdrop) external onlyManager {

        qAirdrop = _qAirdrop;
    }

    function getQAirdrop() external view override returns (address) {

        return qAirdrop;
    }

    function setQNftSettings(address _qNftSettings) external onlyManager {

        qNftSettings = _qNftSettings;
    }

    function getQNftSettings() external view override returns (address) {

        return qNftSettings;
    }

    function setQNftGov(address _qNftGov) external onlyManager {

        qNftGov = _qNftGov;
    }

    function getQNftGov() external view override returns (address) {

        return qNftGov;
    }

    function setQNft(address _qNft) external onlyManager {

        qNft = _qNft;
    }

    function getQNft() external view override returns (address) {

        return qNft;
    }

    uint256[50] private __gap;
}