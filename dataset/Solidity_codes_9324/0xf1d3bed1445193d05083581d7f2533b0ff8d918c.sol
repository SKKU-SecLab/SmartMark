
pragma solidity ^0.5.4;// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>





interface Module {


    function init(BaseWallet _wallet) external;


    function addModule(BaseWallet _wallet, Module _module) external;


    function recoverToken(address _token) external;

}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>





contract BaseWallet {


    address public implementation;
    address public owner;
    mapping (address => bool) public authorised;
    mapping (bytes4 => address) public enabled;
    uint public modules;

    event AuthorisedModule(address indexed module, bool value);
    event EnabledStaticCall(address indexed module, bytes4 indexed method);
    event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);
    event Received(uint indexed value, address indexed sender, bytes data);
    event OwnerChanged(address owner);

    modifier moduleOnly {

        require(authorised[msg.sender], "BW: msg.sender not an authorized module");
        _;
    }

    function init(address _owner, address[] calldata _modules) external {

        require(owner == address(0) && modules == 0, "BW: wallet already initialised");
        require(_modules.length > 0, "BW: construction requires at least 1 module");
        owner = _owner;
        modules = _modules.length;
        for (uint256 i = 0; i < _modules.length; i++) {
            require(authorised[_modules[i]] == false, "BW: module is already added");
            authorised[_modules[i]] = true;
            Module(_modules[i]).init(this);
            emit AuthorisedModule(_modules[i], true);
        }
        if (address(this).balance > 0) {
            emit Received(address(this).balance, address(0), "");
        }
    }

    function authoriseModule(address _module, bool _value) external moduleOnly {

        if (authorised[_module] != _value) {
            emit AuthorisedModule(_module, _value);
            if (_value == true) {
                modules += 1;
                authorised[_module] = true;
                Module(_module).init(this);
            } else {
                modules -= 1;
                require(modules > 0, "BW: wallet must have at least one module");
                delete authorised[_module];
            }
        }
    }

    function enableStaticCall(address _module, bytes4 _method) external moduleOnly {

        require(authorised[_module], "BW: must be an authorised module for static call");
        enabled[_method] = _module;
        emit EnabledStaticCall(_module, _method);
    }

    function setOwner(address _newOwner) external moduleOnly {

        require(_newOwner != address(0), "BW: address cannot be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }

    function invoke(address _target, uint _value, bytes calldata _data) external moduleOnly returns (bytes memory _result) {

        bool success;
        (success, _result) = _target.call.value(_value)(_data);
        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize)
                revert(0, returndatasize)
            }
        }
        emit Invoked(msg.sender, _target, _value, _data);
    }

    function() external payable {
        if (msg.data.length > 0) {
            address module = enabled[msg.sig];
            if (module == address(0)) {
                emit Received(msg.value, msg.sender, msg.data);
            } else {
                require(authorised[module], "BW: must be an authorised module for static call");
                assembly {
                    calldatacopy(0, 0, calldatasize())
                    let result := staticcall(gas, module, 0, calldatasize(), 0, 0)
                    returndatacopy(0, 0, returndatasize())
                    switch result
                    case 0 {revert(0, returndatasize())}
                    default {return (0, returndatasize())}
                }
            }
        }
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>






contract Owned {


    address public owner;

    event OwnerChanged(address indexed _newOwner);

    modifier onlyOwner {

        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

contract ERC20 {

    function totalSupply() public view returns (uint);

    function decimals() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>






contract ModuleRegistry is Owned {


    mapping (address => Info) internal modules;
    mapping (address => Info) internal upgraders;

    event ModuleRegistered(address indexed module, bytes32 name);
    event ModuleDeRegistered(address module);
    event UpgraderRegistered(address indexed upgrader, bytes32 name);
    event UpgraderDeRegistered(address upgrader);

    struct Info {
        bool exists;
        bytes32 name;
    }

    function registerModule(address _module, bytes32 _name) external onlyOwner {

        require(!modules[_module].exists, "MR: module already exists");
        modules[_module] = Info({exists: true, name: _name});
        emit ModuleRegistered(_module, _name);
    }

    function deregisterModule(address _module) external onlyOwner {

        require(modules[_module].exists, "MR: module does not exist");
        delete modules[_module];
        emit ModuleDeRegistered(_module);
    }

    function registerUpgrader(address _upgrader, bytes32 _name) external onlyOwner {

        require(!upgraders[_upgrader].exists, "MR: upgrader already exists");
        upgraders[_upgrader] = Info({exists: true, name: _name});
        emit UpgraderRegistered(_upgrader, _name);
    }

    function deregisterUpgrader(address _upgrader) external onlyOwner {

        require(upgraders[_upgrader].exists, "MR: upgrader does not exist");
        delete upgraders[_upgrader];
        emit UpgraderDeRegistered(_upgrader);
    }

    function recoverToken(address _token) external onlyOwner {

        uint total = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(msg.sender, total);
    }

    function moduleInfo(address _module) external view returns (bytes32) {

        return modules[_module].name;
    }

    function upgraderInfo(address _upgrader) external view returns (bytes32) {

        return upgraders[_upgrader].name;
    }

    function isRegisteredModule(address _module) external view returns (bool) {

        return modules[_module].exists;
    }

    function isRegisteredModule(address[] calldata _modules) external view returns (bool) {

        for (uint i = 0; i < _modules.length; i++) {
            if (!modules[_modules[i]].exists) {
                return false;
            }
        }
        return true;
    }

    function isRegisteredUpgrader(address _upgrader) external view returns (bool) {

        return upgraders[_upgrader].exists;
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>





contract Storage {


    modifier onlyModule(BaseWallet _wallet) {

        require(_wallet.authorised(msg.sender), "TS: must be an authorized module to call this method");
        _;
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>





interface IGuardianStorage{


    function addGuardian(BaseWallet _wallet, address _guardian) external;


    function revokeGuardian(BaseWallet _wallet, address _guardian) external;


    function isGuardian(BaseWallet _wallet, address _guardian) external view returns (bool);

}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>







contract GuardianStorage is IGuardianStorage, Storage {


    struct GuardianStorageConfig {
        address[] guardians;
        mapping (address => GuardianInfo) info;
        uint256 lock;
        address locker;
    }

    struct GuardianInfo {
        bool exists;
        uint128 index;
    }

    mapping (address => GuardianStorageConfig) internal configs;


    function addGuardian(BaseWallet _wallet, address _guardian) external onlyModule(_wallet) {

        GuardianStorageConfig storage config = configs[address(_wallet)];
        config.info[_guardian].exists = true;
        config.info[_guardian].index = uint128(config.guardians.push(_guardian) - 1);
    }

    function revokeGuardian(BaseWallet _wallet, address _guardian) external onlyModule(_wallet) {

        GuardianStorageConfig storage config = configs[address(_wallet)];
        address lastGuardian = config.guardians[config.guardians.length - 1];
        if (_guardian != lastGuardian) {
            uint128 targetIndex = config.info[_guardian].index;
            config.guardians[targetIndex] = lastGuardian;
            config.info[lastGuardian].index = targetIndex;
        }
        config.guardians.length--;
        delete config.info[_guardian];
    }

    function guardianCount(BaseWallet _wallet) external view returns (uint256) {

        return configs[address(_wallet)].guardians.length;
    }

    function getGuardians(BaseWallet _wallet) external view returns (address[] memory) {

        GuardianStorageConfig storage config = configs[address(_wallet)];
        address[] memory guardians = new address[](config.guardians.length);
        for (uint256 i = 0; i < config.guardians.length; i++) {
            guardians[i] = config.guardians[i];
        }
        return guardians;
    }

    function isGuardian(BaseWallet _wallet, address _guardian) external view returns (bool) {

        return configs[address(_wallet)].info[_guardian].exists;
    }

    function setLock(BaseWallet _wallet, uint256 _releaseAfter) external onlyModule(_wallet) {

        configs[address(_wallet)].lock = _releaseAfter;
        if (_releaseAfter != 0 && msg.sender != configs[address(_wallet)].locker) {
            configs[address(_wallet)].locker = msg.sender;
        }
    }

    function isLocked(BaseWallet _wallet) external view returns (bool) {

        return configs[address(_wallet)].lock > now;
    }

    function getLock(BaseWallet _wallet) external view returns (uint256) {

        return configs[address(_wallet)].lock;
    }

    function getLocker(BaseWallet _wallet) external view returns (address) {

        return configs[address(_wallet)].locker;
    }
}/* The MIT License (MIT)

Copyright (c) 2016 Smart Contract Solutions, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */



library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }

    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        if(a % b == 0) {
            return c;
        }
        else {
            return c + 1;
        }
    }


    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;
    }
}










contract BaseModule is Module {


    bytes constant internal EMPTY_BYTES = "";

    ModuleRegistry internal registry;
    GuardianStorage internal guardianStorage;

    modifier onlyWhenUnlocked(BaseWallet _wallet) {

        require(!guardianStorage.isLocked(_wallet), "BM: wallet must be unlocked");
        _;
    }

    event ModuleCreated(bytes32 name);
    event ModuleInitialised(address wallet);

    constructor(ModuleRegistry _registry, GuardianStorage _guardianStorage, bytes32 _name) public {
        registry = _registry;
        guardianStorage = _guardianStorage;
        emit ModuleCreated(_name);
    }

    modifier onlyWallet(BaseWallet _wallet) {

        require(msg.sender == address(_wallet), "BM: caller must be wallet");
        _;
    }

    modifier onlyWalletOwner(BaseWallet _wallet) {

        require(msg.sender == address(this) || isOwner(_wallet, msg.sender), "BM: must be an owner for the wallet");
        _;
    }

    modifier strictOnlyWalletOwner(BaseWallet _wallet) {

        require(isOwner(_wallet, msg.sender), "BM: msg.sender must be an owner for the wallet");
        _;
    }

    function init(BaseWallet _wallet) public onlyWallet(_wallet) {

        emit ModuleInitialised(address(_wallet));
    }

    function addModule(BaseWallet _wallet, Module _module) external strictOnlyWalletOwner(_wallet) {

        require(registry.isRegisteredModule(address(_module)), "BM: module is not registered");
        _wallet.authoriseModule(address(_module), true);
    }

    function recoverToken(address _token) external {

        uint total = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(address(registry), total);
    }

    function isOwner(BaseWallet _wallet, address _addr) internal view returns (bool) {

        return _wallet.owner() == _addr;
    }

    function invokeWallet(address _wallet, address _to, uint256 _value, bytes memory _data) internal returns (bytes memory _res) {

        bool success;
        (success, _res) = _wallet.call(abi.encodeWithSignature("invoke(address,uint256,bytes)", _to, _value, _data));
        if (success && _res.length > 0) { //_res is empty if _wallet is an "old" BaseWallet that can't return output values
            (_res) = abi.decode(_res, (bytes));
        } else if (_res.length > 0) {
            assembly {
                returndatacopy(0, 0, returndatasize)
                revert(0, returndatasize)
            }
        } else if (!success) {
            revert("BM: wallet invoke reverted");
        }
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>






contract RelayerModule is BaseModule {


    uint256 constant internal BLOCKBOUND = 10000;

    mapping (address => RelayerConfig) public relayer;

    struct RelayerConfig {
        uint256 nonce;
        mapping (bytes32 => bool) executedTx;
    }

    event TransactionExecuted(address indexed wallet, bool indexed success, bytes32 signedHash);

    modifier onlyExecute {

        require(msg.sender == address(this), "RM: must be called via execute()");
        _;
    }


    function getRequiredSignatures(BaseWallet _wallet, bytes memory _data) internal view returns (uint256);


    function validateSignatures(
        BaseWallet _wallet,
        bytes memory _data,
        bytes32 _signHash,
        bytes memory _signatures) internal view returns (bool);



    function execute(
        BaseWallet _wallet,
        bytes calldata _data,
        uint256 _nonce,
        bytes calldata _signatures,
        uint256 _gasPrice,
        uint256 _gasLimit
    )
        external
        returns (bool success)
    {

        uint startGas = gasleft();
        bytes32 signHash = getSignHash(address(this), address(_wallet), 0, _data, _nonce, _gasPrice, _gasLimit);
        require(checkAndUpdateUniqueness(_wallet, _nonce, signHash), "RM: Duplicate request");
        require(verifyData(address(_wallet), _data), "RM: the wallet authorized is different then the target of the relayed data");
        uint256 requiredSignatures = getRequiredSignatures(_wallet, _data);
        if ((requiredSignatures * 65) == _signatures.length) {
            if (verifyRefund(_wallet, _gasLimit, _gasPrice, requiredSignatures)) {
                if (requiredSignatures == 0 || validateSignatures(_wallet, _data, signHash, _signatures)) {
                    (success,) = address(this).call(_data);
                    refund(_wallet, startGas - gasleft(), _gasPrice, _gasLimit, requiredSignatures, msg.sender);
                }
            }
        }
        emit TransactionExecuted(address(_wallet), success, signHash);
    }

    function getNonce(BaseWallet _wallet) external view returns (uint256 nonce) {

        return relayer[address(_wallet)].nonce;
    }

    function getSignHash(
        address _from,
        address _to,
        uint256 _value,
        bytes memory _data,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit
    )
        internal
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(byte(0x19), byte(0), _from, _to, _value, _data, _nonce, _gasPrice, _gasLimit))
        ));
    }

    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 /* _nonce */, bytes32 _signHash) internal returns (bool) {

        if (relayer[address(_wallet)].executedTx[_signHash] == true) {
            return false;
        }
        relayer[address(_wallet)].executedTx[_signHash] = true;
        return true;
    }

    function checkAndUpdateNonce(BaseWallet _wallet, uint256 _nonce) internal returns (bool) {

        if (_nonce <= relayer[address(_wallet)].nonce) {
            return false;
        }
        uint256 nonceBlock = (_nonce & 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000) >> 128;
        if (nonceBlock > block.number + BLOCKBOUND) {
            return false;
        }
        relayer[address(_wallet)].nonce = _nonce;
        return true;
    }

    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint _index) internal pure returns (address) {

        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))
            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))
            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)
        }
        require(v == 27 || v == 28); // solium-disable-line error-reason
        return ecrecover(_signedHash, v, r, s);
    }

    function refund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _gasLimit, uint _signatures, address _relayer) internal {

        uint256 amount = 29292 + _gasUsed; // 21000 (transaction) + 7620 (execution of refund) + 672 to log the event + _gasUsed
        if (_gasPrice > 0 && _signatures > 1 && amount <= _gasLimit) {
            if (_gasPrice > tx.gasprice) {
                amount = amount * tx.gasprice;
            } else {
                amount = amount * _gasPrice;
            }
            invokeWallet(address(_wallet), _relayer, amount, EMPTY_BYTES);
        }
    }

    function verifyRefund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _signatures) internal view returns (bool) {

        if (_gasPrice > 0 &&
            _signatures > 1 &&
            (address(_wallet).balance < _gasUsed * _gasPrice || _wallet.authorised(address(this)) == false)) {
            return false;
        }
        return true;
    }

    function verifyData(address _wallet, bytes memory _data) private pure returns (bool) {

        require(_data.length >= 36, "RM: Invalid dataWallet");
        address dataWallet;
        assembly {
            dataWallet := mload(add(_data, 0x24))
        }
        return dataWallet == _wallet;
    }

    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {

        require(_data.length >= 4, "RM: Invalid functionPrefix");
        assembly {
            prefix := mload(add(_data, 0x20))
        }
    }
}// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>







contract OnlyOwnerModule is BaseModule, RelayerModule {



    function isOnlyOwnerModule() external pure returns (bytes4) {

        return this.isOnlyOwnerModule.selector;
    }

    function addModule(BaseWallet _wallet, Module _module) external onlyWalletOwner(_wallet) {

        require(registry.isRegisteredModule(address(_module)), "BM: module is not registered");
        _wallet.authoriseModule(address(_module), true);
    }


    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 /* _signHash */) internal returns (bool) {

        return checkAndUpdateNonce(_wallet, _nonce);
    }

    function validateSignatures(
        BaseWallet _wallet,
        bytes memory /* _data */,
        bytes32 _signHash,
        bytes memory _signatures
    )
        internal
        view
        returns (bool)
    {

        address signer = recoverSigner(_signHash, _signatures, 0);
        return isOwner(_wallet, signer); // "OOM: signer must be owner"
    }

    function getRequiredSignatures(BaseWallet /* _wallet */, bytes memory /* _data */) internal view returns (uint256) {

        return 1;
    }
}

contract GemLike {

    function balanceOf(address) public view returns (uint);

    function transferFrom(address, address, uint) public returns (bool);

    function approve(address, uint) public returns (bool success);

    function decimals() public view returns (uint);

    function transfer(address,uint) external returns (bool);

}

contract DSTokenLike {

    function mint(address,uint) external;

    function burn(address,uint) external;

}

contract VatLike {

    function can(address, address) public view returns (uint);

    function dai(address) public view returns (uint);

    function hope(address) public;

    function wards(address) public view returns (uint);

    function ilks(bytes32) public view returns (uint Art, uint rate, uint spot, uint line, uint dust);

    function urns(bytes32, address) public view returns (uint ink, uint art);

    function frob(bytes32, address, address, address, int, int) public;

    function slip(bytes32,address,int) external;

    function move(address,address,uint) external;

}

contract JoinLike {

    function ilk() public view returns (bytes32);

    function gem() public view returns (GemLike);

    function dai() public view returns (GemLike);

    function join(address, uint) public;

    function exit(address, uint) public;

    VatLike public vat;
    uint    public live;
}

contract ManagerLike {

    function vat() public view returns (address);

    function urns(uint) public view returns (address);

    function open(bytes32, address) public returns (uint);

    function frob(uint, int, int) public;

    function give(uint, address) public;

    function move(uint, address, uint) public;

    function flux(uint, address, uint) public;

    function shift(uint, uint) public;

    mapping (uint => bytes32) public ilks;
    mapping (uint => address) public owns;
}

contract ScdMcdMigrationLike {

    function swapSaiToDai(uint) public;

    function swapDaiToSai(uint) public;

    function migrate(bytes32) public returns (uint);

    JoinLike public saiJoin;
    JoinLike public wethJoin;
    JoinLike public daiJoin;
    ManagerLike public cdpManager;
    SaiTubLike public tub;
}

contract ValueLike {

    function peek() public returns (uint, bool);

}

contract SaiTubLike {

    function skr() public view returns (GemLike);

    function gem() public view returns (GemLike);

    function gov() public view returns (GemLike);

    function sai() public view returns (GemLike);

    function pep() public view returns (ValueLike);

    function bid(uint) public view returns (uint);

    function ink(bytes32) public view returns (uint);

    function tab(bytes32) public returns (uint);

    function rap(bytes32) public returns (uint);

    function shut(bytes32) public;

    function exit(uint) public;

}

contract VoxLike {

    function par() public returns (uint);

}

contract JugLike {

    function drip(bytes32) external;

}

contract PotLike {

    function chi() public view returns (uint);

    function pie(address) public view returns (uint);

    function drip() public;

}


contract MakerRegistry is Owned {


    VatLike public vat;
    address[] public tokens;
    mapping (address => Collateral) public collaterals;
    mapping (bytes32 => address) public collateralTokensByIlks;

    struct Collateral {
        bool exists;
        uint128 index;
        JoinLike join;
        bytes32 ilk;
    }

    event CollateralAdded(address indexed _token);
    event CollateralRemoved(address indexed _token);

    constructor(VatLike _vat) public {
        vat = _vat;
    }

    function addCollateral(JoinLike _joinAdapter) external onlyOwner {

        require(vat.wards(address(_joinAdapter)) == 1, "MR: _joinAdapter not authorised in vat");
        address token = address(_joinAdapter.gem());
        require(!collaterals[token].exists, "MR: collateral already added");
        collaterals[token].exists = true;
        collaterals[token].index = uint128(tokens.push(token) - 1);
        collaterals[token].join = _joinAdapter;
        bytes32 ilk = _joinAdapter.ilk();
        collaterals[token].ilk = ilk;
        collateralTokensByIlks[ilk] = token;
        emit CollateralAdded(token);
    }

    function removeCollateral(address _token) external onlyOwner {

        require(collaterals[_token].exists, "MR: collateral does not exist");
        delete collateralTokensByIlks[collaterals[_token].ilk];

        address last = tokens[tokens.length - 1];
        if (_token != last) {
            uint128 targetIndex = collaterals[_token].index;
            tokens[targetIndex] = last;
            collaterals[last].index = targetIndex;
        }
        tokens.length --;
        delete collaterals[_token];
        emit CollateralRemoved(_token);
    }

    function getCollateralTokens() external view returns (address[] memory _tokens) {

        _tokens = new address[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            _tokens[i] = tokens[i];
        }
        return _tokens;
    }

    function getIlk(address _token) external view returns (bytes32 _ilk) {

        _ilk = collaterals[_token].ilk;
    }

    function getCollateral(bytes32 _ilk) external view returns (JoinLike _join, GemLike _token) {

        _token = GemLike(collateralTokensByIlks[_ilk]);
        _join = collaterals[address(_token)].join;
    }
}// Copyright (C) 2019  Argent Labs Ltd. <https://argent.xyz>










contract MakerV2Base is BaseModule, RelayerModule, OnlyOwnerModule {


    bytes32 constant private NAME = "MakerV2Manager";

    GemLike internal daiToken;
    address internal scdMcdMigration;
    JoinLike internal daiJoin;
    VatLike internal vat;

    uint256 constant internal RAY = 10 ** 27;

    using SafeMath for uint256;


    constructor(
        ModuleRegistry _registry,
        GuardianStorage _guardianStorage,
        ScdMcdMigrationLike _scdMcdMigration
    )
        BaseModule(_registry, _guardianStorage, NAME)
        public
    {
        scdMcdMigration = address(_scdMcdMigration);
        daiJoin = _scdMcdMigration.daiJoin();
        daiToken = daiJoin.dai();
        vat = daiJoin.vat();
    }

}// Copyright (C) 2019  Argent Labs Ltd. <https://argent.xyz>





contract MakerV2Invest is MakerV2Base {


    PotLike internal pot;


    event InvestmentRemoved(address indexed _wallet, address _token, uint256 _amount);
    event InvestmentAdded(address indexed _wallet, address _token, uint256 _amount, uint256 _period);


    constructor(PotLike _pot) public {
        pot = _pot;
    }


    function joinDsr(
        BaseWallet _wallet,
        uint256 _amount
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        pot.drip();
        invokeWallet(address(_wallet), address(daiToken), 0, abi.encodeWithSignature("approve(address,uint256)", address(daiJoin), _amount));
        invokeWallet(address(_wallet), address(daiJoin), 0, abi.encodeWithSignature("join(address,uint256)", address(_wallet), _amount));
        grantVatAccess(_wallet, address(pot));
        uint256 pie = _amount.mul(RAY) / pot.chi();
        invokeWallet(address(_wallet), address(pot), 0, abi.encodeWithSignature("join(uint256)", pie));
        emit InvestmentAdded(address(_wallet), address(daiToken), _amount, 0);
    }

    function exitDsr(
        BaseWallet _wallet,
        uint256 _amount
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        pot.drip();
        uint256 pie = _amount.mul(RAY) / pot.chi();
        invokeWallet(address(_wallet), address(pot), 0, abi.encodeWithSignature("exit(uint256)", pie));
        grantVatAccess(_wallet, address(daiJoin));
        uint bal = vat.dai(address(_wallet));
        uint256 withdrawn = bal >= _amount.mul(RAY) ? _amount : bal / RAY;
        invokeWallet(address(_wallet), address(daiJoin), 0, abi.encodeWithSignature("exit(address,uint256)", address(_wallet), withdrawn));
        emit InvestmentRemoved(address(_wallet), address(daiToken), withdrawn);
    }

    function exitAllDsr(
        BaseWallet _wallet
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        pot.drip();
        uint256 pie = pot.pie(address(_wallet));
        invokeWallet(address(_wallet), address(pot), 0, abi.encodeWithSignature("exit(uint256)", pie));
        grantVatAccess(_wallet, address(daiJoin));
        uint256 withdrawn = pot.chi().mul(pie) / RAY;
        invokeWallet(address(_wallet), address(daiJoin), 0, abi.encodeWithSignature("exit(address,uint256)", address(_wallet), withdrawn));
        emit InvestmentRemoved(address(_wallet), address(daiToken), withdrawn);
    }

    function dsrBalance(BaseWallet _wallet) external view returns (uint256 _balance) {

        return pot.chi().mul(pot.pie(address(_wallet))) / RAY;
    }


    function grantVatAccess(BaseWallet _wallet, address _operator) internal {

        if (vat.can(address(_wallet), _operator) == 0) {
            invokeWallet(address(_wallet), address(vat), 0, abi.encodeWithSignature("hope(address)", _operator));
        }
    }
}// Copyright (C) 2019  Argent Labs Ltd. <https://argent.xyz>






interface IUniswapFactory {

    function getExchange(address _token) external view returns(IUniswapExchange);

}

interface IUniswapExchange {

    function getEthToTokenOutputPrice(uint256 _tokensBought) external view returns (uint256);

    function getEthToTokenInputPrice(uint256 _ethSold) external view returns (uint256);

    function getTokenToEthOutputPrice(uint256 _ethBought) external view returns (uint256);

    function getTokenToEthInputPrice(uint256 _tokensSold) external view returns (uint256);

}

contract MakerV2Loan is MakerV2Base {


    GemLike internal mkrToken;
    GemLike internal wethToken;
    JoinLike internal wethJoin;
    JugLike internal jug;
    ManagerLike internal cdpManager;
    SaiTubLike internal tub;
    MakerRegistry internal makerRegistry;
    IUniswapExchange internal daiUniswap;
    IUniswapExchange internal mkrUniswap;
    mapping(address => mapping(bytes32 => bytes32)) public loanIds;
    bool private _notEntered = true;

    address constant internal ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;


    event CdpMigrated(address indexed _wallet, bytes32 _oldCdpId, bytes32 _newVaultId);
    event LoanOpened(
        address indexed _wallet,
        bytes32 indexed _loanId,
        address _collateral,
        uint256 _collateralAmount,
        address _debtToken,
        uint256 _debtAmount
    );
    event LoanClosed(address indexed _wallet, bytes32 indexed _loanId);
    event CollateralAdded(address indexed _wallet, bytes32 indexed _loanId, address _collateral, uint256 _collateralAmount);
    event CollateralRemoved(address indexed _wallet, bytes32 indexed _loanId, address _collateral, uint256 _collateralAmount);
    event DebtAdded(address indexed _wallet, bytes32 indexed _loanId, address _debtToken, uint256 _debtAmount);
    event DebtRemoved(address indexed _wallet, bytes32 indexed _loanId, address _debtToken, uint256 _debtAmount);



    modifier onlyModule(BaseWallet _wallet) {

        require(_wallet.authorised(msg.sender), "MV2: sender unauthorized");
        _;
    }

    modifier nonReentrant() {

        require(_notEntered, "MV2: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }


    constructor(
        JugLike _jug,
        MakerRegistry _makerRegistry,
        IUniswapFactory _uniswapFactory
    )
        public
    {
        cdpManager = ScdMcdMigrationLike(scdMcdMigration).cdpManager();
        tub = ScdMcdMigrationLike(scdMcdMigration).tub();
        wethJoin = ScdMcdMigrationLike(scdMcdMigration).wethJoin();
        wethToken = wethJoin.gem();
        mkrToken = tub.gov();
        jug = _jug;
        makerRegistry = _makerRegistry;
        daiUniswap = _uniswapFactory.getExchange(address(daiToken));
        mkrUniswap = _uniswapFactory.getExchange(address(mkrToken));
        vat.hope(address(daiJoin));
    }



    function openLoan(
        BaseWallet _wallet,
        address _collateral,
        uint256 _collateralAmount,
        address _debtToken,
        uint256 _debtAmount
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
        returns (bytes32 _loanId)
    {

        verifySupportedCollateral(_collateral);
        require(_debtToken == address(daiToken), "MV2: debt token not DAI");
        _loanId = bytes32(openVault(_wallet, _collateral, _collateralAmount, _debtAmount));
        emit LoanOpened(address(_wallet), _loanId, _collateral, _collateralAmount, _debtToken, _debtAmount);
    }

    function addCollateral(
        BaseWallet _wallet,
        bytes32 _loanId,
        address _collateral,
        uint256 _collateralAmount
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        verifyLoanOwner(_wallet, _loanId);
        addCollateral(_wallet, uint256(_loanId), _collateralAmount);
        emit CollateralAdded(address(_wallet), _loanId, _collateral, _collateralAmount);
    }

    function removeCollateral(
        BaseWallet _wallet,
        bytes32 _loanId,
        address _collateral,
        uint256 _collateralAmount
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        verifyLoanOwner(_wallet, _loanId);
        removeCollateral(_wallet, uint256(_loanId), _collateralAmount);
        emit CollateralRemoved(address(_wallet), _loanId, _collateral, _collateralAmount);
    }

    function addDebt(
        BaseWallet _wallet,
        bytes32 _loanId,
        address _debtToken,
        uint256 _debtAmount
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        verifyLoanOwner(_wallet, _loanId);
        addDebt(_wallet, uint256(_loanId), _debtAmount);
        emit DebtAdded(address(_wallet), _loanId, _debtToken, _debtAmount);
    }

    function removeDebt(
        BaseWallet _wallet,
        bytes32 _loanId,
        address _debtToken,
        uint256 _debtAmount
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        verifyLoanOwner(_wallet, _loanId);
        updateStabilityFee(uint256(_loanId));
        removeDebt(_wallet, uint256(_loanId), _debtAmount);
        emit DebtRemoved(address(_wallet), _loanId, _debtToken, _debtAmount);
    }

    function closeLoan(
        BaseWallet _wallet,
        bytes32 _loanId
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        verifyLoanOwner(_wallet, _loanId);
        updateStabilityFee(uint256(_loanId));
        closeVault(_wallet, uint256(_loanId));
        emit LoanClosed(address(_wallet), _loanId);
    }


    function acquireLoan(
        BaseWallet _wallet,
        bytes32 _loanId
    )
        external
        nonReentrant
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        require(cdpManager.owns(uint256(_loanId)) == address(_wallet), "MV2: wrong vault owner");
        invokeWallet(
            address(_wallet),
            address(cdpManager),
            0,
            abi.encodeWithSignature("give(uint256,address)", uint256(_loanId), address(this))
        );
        require(cdpManager.owns(uint256(_loanId)) == address(this), "MV2: failed give");
        assignLoanToWallet(_wallet, _loanId);
    }

    function migrateCdp(
        BaseWallet _wallet,
        bytes32 _cup
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
        returns (bytes32 _loanId)
    {

        (uint daiPerMkr, bool ok) = tub.pep().peek();
        if (ok && daiPerMkr != 0) {
            uint mkrFee = tub.rap(_cup).wdiv(daiPerMkr);
            buyTokens(_wallet, mkrToken, mkrFee, mkrUniswap);
            invokeWallet(address(_wallet), address(mkrToken), 0, abi.encodeWithSignature("transfer(address,uint256)", address(scdMcdMigration), mkrFee));
        }
        invokeWallet(address(_wallet), address(tub), 0, abi.encodeWithSignature("give(bytes32,address)", _cup, address(scdMcdMigration)));
        jug.drip(wethJoin.ilk());
        _loanId = bytes32(ScdMcdMigrationLike(scdMcdMigration).migrate(_cup));
        _loanId = assignLoanToWallet(_wallet, _loanId);

        emit CdpMigrated(address(_wallet), _cup, _loanId);
    }

    function giveVault(
        BaseWallet _wallet,
        bytes32 _loanId
    )
        external
        onlyModule(_wallet)
        onlyWhenUnlocked(_wallet)
    {

        verifyLoanOwner(_wallet, _loanId);
        cdpManager.give(uint256(_loanId), msg.sender);
        clearLoanOwner(_wallet, _loanId);
    }


    function toInt(uint256 _x) internal pure returns (int _y) {

        _y = int(_x);
        require(_y >= 0, "MV2: int overflow");
    }

    function assignLoanToWallet(BaseWallet _wallet, bytes32 _loanId) internal returns (bytes32 _assignedLoanId) {

        bytes32 ilk = cdpManager.ilks(uint256(_loanId));
        bytes32 existingLoanId = loanIds[address(_wallet)][ilk];
        if (existingLoanId > 0) {
            cdpManager.shift(uint256(_loanId), uint256(existingLoanId));
            return existingLoanId;
        }
        loanIds[address(_wallet)][ilk] = _loanId;
        return _loanId;
    }

    function clearLoanOwner(BaseWallet _wallet, bytes32 _loanId) internal {

        delete loanIds[address(_wallet)][cdpManager.ilks(uint256(_loanId))];
    }

    function verifyLoanOwner(BaseWallet _wallet, bytes32 _loanId) internal view {

        require(loanIds[address(_wallet)][cdpManager.ilks(uint256(_loanId))] == _loanId, "MV2: unauthorized loanId");
    }

    function verifySupportedCollateral(address _collateral) internal view {

        if (_collateral != ETH_TOKEN_ADDRESS) {
            (bool collateralSupported,,,) = makerRegistry.collaterals(_collateral);
            require(collateralSupported, "MV2: unsupported collateral");
        }
    }

    function buyTokens(
        BaseWallet _wallet,
        GemLike _token,
        uint256 _tokenAmountRequired,
        IUniswapExchange _uniswapExchange
    )
        internal
    {

        uint256 tokenBalance = _token.balanceOf(address(_wallet));
        if (tokenBalance < _tokenAmountRequired) {
            uint256 etherValueOfTokens = _uniswapExchange.getEthToTokenOutputPrice(_tokenAmountRequired - tokenBalance);
            invokeWallet(address(_wallet), address(_uniswapExchange), etherValueOfTokens, abi.encodeWithSignature("ethToTokenSwapOutput(uint256,uint256)", _tokenAmountRequired - tokenBalance, now));
        }
    }

    function joinCollateral(
        BaseWallet _wallet,
        uint256 _cdpId,
        uint256 _collateralAmount,
        bytes32 _ilk
    )
        internal
    {

        (JoinLike gemJoin, GemLike collateral) = makerRegistry.getCollateral(_ilk);
        if (gemJoin == wethJoin) {
            invokeWallet(address(_wallet), address(wethToken), _collateralAmount, abi.encodeWithSignature("deposit()"));
        }
        invokeWallet(
            address(_wallet),
            address(collateral),
            0,
            abi.encodeWithSignature("transfer(address,uint256)", address(this), _collateralAmount)
        );
        collateral.approve(address(gemJoin), _collateralAmount);
        gemJoin.join(cdpManager.urns(_cdpId), _collateralAmount);
    }

    function joinDebt(
        BaseWallet _wallet,
        uint256 _cdpId,
        uint256 _debtAmount //  art.mul(rate).div(RAY) === [wad]*[ray]/[ray]=[wad]
    )
        internal
    {

        invokeWallet(address(_wallet), address(daiToken), 0, abi.encodeWithSignature("transfer(address,uint256)", address(this), _debtAmount));
        daiToken.approve(address(daiJoin), _debtAmount);
        daiJoin.join(cdpManager.urns(_cdpId), _debtAmount.sub(1));
    }

    function drawAndExitDebt(
        BaseWallet _wallet,
        uint256 _cdpId,
        uint256 _debtAmount,
        uint256 _collateralAmount,
        bytes32 _ilk
    )
        internal
    {

        (, uint rate,,,) = vat.ilks(_ilk);
        uint daiDebtInRad = _debtAmount.mul(RAY);
        cdpManager.frob(_cdpId, toInt(_collateralAmount), toInt(daiDebtInRad.div(rate) + 1));
        cdpManager.move(_cdpId, address(this), daiDebtInRad);
        daiJoin.exit(address(_wallet), _debtAmount);
    }

    function updateStabilityFee(
        uint256 _cdpId
    )
        internal
    {

        jug.drip(cdpManager.ilks(_cdpId));
    }

    function debt(
        uint256 _cdpId
    )
        internal
        view
        returns (uint256 _fullRepayment, uint256 _maxNonFullRepayment)
    {

        bytes32 ilk = cdpManager.ilks(_cdpId);
        (, uint256 art) = vat.urns(ilk, cdpManager.urns(_cdpId));
        if (art > 0) {
            (, uint rate,,, uint dust) = vat.ilks(ilk);
            _maxNonFullRepayment = art.mul(rate).sub(dust).div(RAY);
            _fullRepayment = art.mul(rate).div(RAY)
                .add(1) // the amount approved is 1 wei more than the amount repaid, to avoid rounding issues
                .add(art-art.mul(rate).div(RAY).mul(RAY).div(rate)); // adding 1 extra wei if further rounding issues are expected
        }
    }

    function collateral(
        uint256 _cdpId
    )
        internal
        view
        returns (uint256 _collateralAmount)
    {

        (_collateralAmount,) = vat.urns(cdpManager.ilks(_cdpId), cdpManager.urns(_cdpId));
    }

    function verifyValidRepayment(
        uint256 _cdpId,
        uint256 _debtAmount
    )
        internal
        view
    {

        (uint256 fullRepayment, uint256 maxRepayment) = debt(_cdpId);
        require(_debtAmount <= maxRepayment || _debtAmount == fullRepayment, "MV2: repay less or full");
    }

    function openVault(
        BaseWallet _wallet,
        address _collateral,
        uint256 _collateralAmount,
        uint256 _debtAmount
    )
        internal
        returns (uint256 _cdpId)
    {

        if (_collateral == ETH_TOKEN_ADDRESS) {
            _collateral = address(wethToken);
        }
        bytes32 ilk = makerRegistry.getIlk(_collateral);
        _cdpId = uint256(loanIds[address(_wallet)][ilk]);
        if (_cdpId == 0) {
            _cdpId = cdpManager.open(ilk, address(this));
            loanIds[address(_wallet)][ilk] = bytes32(_cdpId);
        }
        joinCollateral(_wallet, _cdpId, _collateralAmount, ilk);
        if (_debtAmount > 0) {
            drawAndExitDebt(_wallet, _cdpId, _debtAmount, _collateralAmount, ilk);
        }
    }

    function addCollateral(
        BaseWallet _wallet,
        uint256 _cdpId,
        uint256 _collateralAmount
    )
        internal
    {

        joinCollateral(_wallet, _cdpId, _collateralAmount, cdpManager.ilks(_cdpId));
        cdpManager.frob(_cdpId, toInt(_collateralAmount), 0);
    }

    function removeCollateral(
        BaseWallet _wallet,
        uint256 _cdpId,
        uint256 _collateralAmount
    )
        internal
    {

        cdpManager.frob(_cdpId, -toInt(_collateralAmount), 0);
        cdpManager.flux(_cdpId, address(this), _collateralAmount);
        (JoinLike gemJoin,) = makerRegistry.getCollateral(cdpManager.ilks(_cdpId));
        gemJoin.exit(address(_wallet), _collateralAmount);
        if (gemJoin == wethJoin) {
            invokeWallet(address(_wallet), address(wethToken), 0, abi.encodeWithSignature("withdraw(uint256)", _collateralAmount));
        }
    }

    function addDebt(
        BaseWallet _wallet,
        uint256 _cdpId,
        uint256 _amount
    )
        internal
    {

        drawAndExitDebt(_wallet, _cdpId, _amount, 0, cdpManager.ilks(_cdpId));
    }

    function removeDebt(
        BaseWallet _wallet,
        uint256 _cdpId,
        uint256 _amount
    )
        internal
    {

        verifyValidRepayment(_cdpId, _amount);
        buyTokens(_wallet, daiToken, _amount, daiUniswap);
        joinDebt(_wallet, _cdpId, _amount);
        (, uint rate,,,) = vat.ilks(cdpManager.ilks(_cdpId));
        cdpManager.frob(_cdpId, 0, -toInt(_amount.sub(1).mul(RAY).div(rate)));
    }

    function closeVault(
        BaseWallet _wallet,
        uint256 _cdpId
    )
        internal
    {

        (uint256 fullRepayment,) = debt(_cdpId);
        if (fullRepayment > 0) {
            removeDebt(_wallet, _cdpId, fullRepayment);
        }
        uint256 ink = collateral(_cdpId);
        if (ink > 0) {
            removeCollateral(_wallet, _cdpId, ink);
        }
    }

}// Copyright (C) 2019  Argent Labs Ltd. <https://argent.xyz>







contract MakerV2Manager is MakerV2Base, MakerV2Invest, MakerV2Loan {



    constructor(
        ModuleRegistry _registry,
        GuardianStorage _guardianStorage,
        ScdMcdMigrationLike _scdMcdMigration,
        PotLike _pot,
        JugLike _jug,
        MakerRegistry _makerRegistry,
        IUniswapFactory _uniswapFactory
    )
        MakerV2Base(_registry, _guardianStorage, _scdMcdMigration)
        MakerV2Invest(_pot)
        MakerV2Loan(_jug, _makerRegistry, _uniswapFactory)
        public
    {
    }

}