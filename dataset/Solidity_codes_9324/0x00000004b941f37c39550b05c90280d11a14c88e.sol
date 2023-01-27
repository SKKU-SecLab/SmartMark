pragma solidity =0.7.5;


library SafeMath {

    function add(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    )
        internal
        pure
        returns (uint256)
    {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    )
        internal
        pure
        returns (uint256)
    {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    )
        internal
        pure
        returns (uint256)
    {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity =0.7.5;


library Roles {

    struct Role
    {
        mapping (address => bool) bearer;
    }

    function add(
        Role storage role,
        address account
    )
        internal
    {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(
        Role storage role,
        address account
    )
        internal
    {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(
        Role storage role,
        address account
    )
        internal
        view
        returns (bool)
    {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
pragma solidity =0.7.5;


interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity =0.7.5;



contract BaseAuth {

    using Roles for Roles.Role;

    Roles.Role private _agents;

    event AgentAdded(address indexed account);
    event AgentRemoved(address indexed account);

    constructor ()
    {
        _agents.add(msg.sender);
        emit AgentAdded(msg.sender);
    }

    modifier onlyAgent() {

        require(isAgent(msg.sender), "AgentRole: caller does not have the Agent role");
        _;
    }

    function rescueToken(
        address tokenAddr,
        address recipient,
        uint256 amount
    )
        external
        onlyAgent
    {

        IERC20 _token = IERC20(tokenAddr);
        require(recipient != address(0), "Rescue: recipient is the zero address");
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount, "Rescue: amount exceeds balance");
        _token.transfer(recipient, amount);
    }

    function withdrawEther(
        address payable recipient,
        uint256 amount
    )
        external
        onlyAgent
    {

        require(recipient != address(0), "Withdraw: recipient is the zero address");
        uint256 balance = address(this).balance;
        require(balance >= amount, "Withdraw: amount exceeds balance");
        recipient.transfer(amount);
    }

    function isAgent(address account)
        public
        view
        returns (bool)
    {

        return _agents.has(account);
    }

    function addAgent(address account)
        public
        onlyAgent
    {

        _agents.add(account);
        emit AgentAdded(account);
    }

    function removeAgent(address account)
        public
        onlyAgent
    {

        _agents.remove(account);
        emit AgentRemoved(account);
    }
}

pragma solidity =0.7.5;



contract AuthPause is BaseAuth {

    using Roles for Roles.Role;

    bool private _paused = false;

    event PausedON();
    event PausedOFF();


    modifier onlyNotPaused() {

        require(!_paused, "Paused");
        _;
    }

    function isPaused()
        public
        view
        returns (bool)
    {

        return _paused;
    }

    function setPaused(bool value)
        external
        onlyAgent
    {

        _paused = value;

        if (_paused) {
            emit PausedON();
        } else {
            emit PausedOFF();
        }
    }
}
pragma solidity =0.7.5;


interface IVesting {

    function vestingOf(address account) external view returns (uint256);

}
pragma solidity =0.7.5;


interface IVokenTB {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function cap() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    
    function mint(address account, uint256 amount) external returns (bool);

    function mintWithVesting(address account, uint256 amount, address vestingContract) external returns (bool);


    function referrer(address account) external view returns (address payable);

    function address2voken(address account) external view returns (uint160);

    function voken2address(uint160 voken) external view returns (address payable);

}
pragma solidity =0.7.5;

interface IVokenAudit {

    function getAccount(address account) external view
        returns (
            uint72 wei_purchased,
            uint72 wei_rewarded,
            uint72 wei_audit,
            uint16 txs_in,
            uint16 txs_out
        );

}
pragma solidity =0.7.5;




contract WithResaleOnly is BaseAuth {

    mapping (address => bool) private _resaleOnly;


    function setResaleOnlys(address[] memory accounts, bool[] memory values)
        external
        onlyAgent
    {

        for (uint8 i = 0; i < accounts.length; i++) {
            _resaleOnly[accounts[i]] = values[i];
        }
    }

    function isResaleOnly(address account)
        public
        view
        returns (bool)
    {

        return _resaleOnly[account];
    }
}
pragma solidity =0.7.5;




contract WithDeadline is BaseAuth {

    uint256 private _deadlineTimestamp;

    constructor ()
    {
        _deadlineTimestamp = 1617235199;  // Wed, 31 Mar 2021 23:59:59 +0000
    }

    modifier onlyBeforeDeadline()
    {

        require(block.timestamp <= _deadlineTimestamp, "later than deadline");
        _;
    }

    function setDeadline(
        uint256 deadlineTimestamp
    )
        external
        onlyAgent
    {

        _deadlineTimestamp = deadlineTimestamp;
    }

    function _deadline()
        internal
        view
        returns (uint256)
    {

        return _deadlineTimestamp;
    }
}
pragma solidity =0.7.5;




contract WithCoeff is BaseAuth {

    uint16 private _v1ClaimRatio;
    uint16 private _v2ClaimRatio;
    uint16 private _v1BonusCoeff;
    uint16 private _v2BonusCoeff;


    constructor ()
    {
        _v1ClaimRatio = 133;
        _v2ClaimRatio = 200;
        _v1BonusCoeff = 50;
        _v2BonusCoeff = 100;
    }

    function setCoeff(
        uint16 v1ClaimRatio_,
        uint16 v2ClaimRatio_,
        uint16 v1BonusCoeff_,
        uint16 v2BonusCoeff_
    )
        external
        onlyAgent
    {

        _v1ClaimRatio = v1ClaimRatio_;
        _v2ClaimRatio = v2ClaimRatio_;
        _v1BonusCoeff = v1BonusCoeff_;
        _v2BonusCoeff = v2BonusCoeff_;
    }

    function v1ClaimRatio()
        internal
        view
        returns (uint16)
    {

        return _v1ClaimRatio;
    }

    function v2ClaimRatio()
        internal
        view
        returns (uint16)
    {

        return _v2ClaimRatio;
    }

    function v1BonusCoeff()
        internal
        view
        returns (uint16)
    {

        return _v1BonusCoeff;
    }

    function v2BonusCoeff()
        internal
        view
        returns (uint16)
    {

        return _v2BonusCoeff;
    }
}
pragma solidity =0.7.5;

interface IEtherUSDPrice {

    function etherUSDPrice() external view returns (uint256);

}
pragma solidity =0.7.5;


interface IVokenSale {

    function vokenUSDPrice() external view returns (uint256);

}
pragma solidity =0.7.5;



contract WithUSDPrice is BaseAuth {

    uint256 private _resaleEtherUSDPrice;
    uint256 private _defaultEtherUSDPrice;
    uint256 private _defaultVokenUSDPrice;

    IEtherUSDPrice private _etherUSDPriceContract;
    IVokenSale private _vokenSaleContract;


    constructor ()
    {
        _resaleEtherUSDPrice = 350e6;
        _defaultEtherUSDPrice = 580e6;
        _defaultVokenUSDPrice = 0.5e6;
    }

    function setEtherUSDPriceContract(address etherUSDPriceContract_)
        external
        onlyAgent
    {

        _etherUSDPriceContract = IEtherUSDPrice(etherUSDPriceContract_);
    }

    function setVokenSaleContract(address vokenSaleContract_)
        external
        onlyAgent
    {

        _vokenSaleContract = IVokenSale(vokenSaleContract_);
    }

    function setDefaultUSDPrice(
        uint256 resaleEtherUSDPrice_,
        uint256 defaultEtherUSDPrice_,
        uint256 defaultVokenUSDPrice_
    )
        external
        onlyAgent
    {

        _resaleEtherUSDPrice = resaleEtherUSDPrice_;
        _defaultEtherUSDPrice = defaultEtherUSDPrice_;
        _defaultVokenUSDPrice = defaultVokenUSDPrice_;
    }

    function resaleEtherUSDPrice()
        internal
        view
        returns (uint256)
    {

        return _resaleEtherUSDPrice;
    }

    function _etherUSDPrice()
        internal
        view
        returns (uint256)
    {

        if (_etherUSDPriceContract != IEtherUSDPrice(0)) {
            try _etherUSDPriceContract.etherUSDPrice() returns (uint256 value) {
                return value;
            }
            
            catch {
                return _defaultEtherUSDPrice; 
            }
        }

        return _defaultEtherUSDPrice;
    }

    function vokenUSDPrice()
        internal
        view
        returns (uint256)
    {

        if (_vokenSaleContract != IVokenSale(0)) {
            try _vokenSaleContract.vokenUSDPrice() returns (uint256 value) {
                return value;
            }
            
            catch {
                return _defaultVokenUSDPrice;
            }
        }

        return _defaultVokenUSDPrice;
    }
}

pragma solidity =0.7.5;




contract WithUSDToken is BaseAuth {

    using SafeMath for uint256;
    
    IERC20 private _token;
    uint8 private _decimalsDiff;
    uint8 private constant DEFAULT_DECIMALS = 6;

    constructor ()
    {
        setUSDToken(address(0x6B175474E89094C44Da98b954EedeAC495271d0F), 18); // DAI Stablecoin
    }

    function setUSDToken(address tokenContract, uint8 decimals)
        public
        onlyAgent
    {

        require(decimals >= DEFAULT_DECIMALS, "Set USD Token: decimals less than 6");
        require(decimals <= 18, "Set USD Token: decimals greater than 18");

        _token = IERC20(tokenContract);
        _decimalsDiff = decimals - DEFAULT_DECIMALS;
    }

    function _getUSDBalance()
        internal
        view
        returns (uint256)
    {

        if (_decimalsDiff > 0) {
            return _token.balanceOf(address(this)).div(10 ** _decimalsDiff);
        } else {
            return _token.balanceOf(address(this));
        }
    }

    function _transferUSD(address recipient, uint256 amount)
        internal
    {

        if (_decimalsDiff > 0) {
            _token.transfer(recipient, amount.mul(10 ** _decimalsDiff));
        } else {
            _token.transfer(recipient, amount);
        }
    }
}
pragma solidity =0.7.5;


interface IPermille {

    function permille() external view returns (uint16);

}
pragma solidity =0.7.5;




contract WithVestingPermille is BaseAuth {

    using SafeMath for uint256;

    IPermille private _v1ClaimedVestingPermilleContract;
    IPermille private _v1BonusesVestingPermilleContract;
    IPermille private _v2ClaimedVestingPermilleContract;
    IPermille private _v2BonusesVestingPermilleContract;

    function setV1CRPC(address permilleContract)
        external
        onlyAgent
    {

        _v1ClaimedVestingPermilleContract = IPermille(permilleContract);
    }

    function setV1BRPC(address permilleContract)
        external
        onlyAgent
    {

        _v1BonusesVestingPermilleContract = IPermille(permilleContract);
    }

    function setV2CRPC(address permilleContract)
        external
        onlyAgent
    {

        _v2ClaimedVestingPermilleContract = IPermille(permilleContract);
    }

    function setV2BRPC(address permilleContract)
        external
        onlyAgent
    {

        _v2BonusesVestingPermilleContract = IPermille(permilleContract);
    }

    function VestingPermilleContracts()
        public
        view
        returns (
            IPermille v1ClaimedVestingPermilleContract,
            IPermille v1BonusesVestingPermilleContract,
            IPermille v2ClaimedVestingPermilleContract,
            IPermille v2BonusesVestingPermilleContract
        )
    {

        v1ClaimedVestingPermilleContract = _v1ClaimedVestingPermilleContract;
        v1BonusesVestingPermilleContract = _v1BonusesVestingPermilleContract;
        v2ClaimedVestingPermilleContract = _v2ClaimedVestingPermilleContract;
        v2BonusesVestingPermilleContract = _v2BonusesVestingPermilleContract;
    }

    function _getV1ClaimedVestingAmount(uint256 amount)
        internal
        view
        returns (uint256 Vesting)
    {

        if (amount > 0) {
            Vesting = _getVestingAmount(amount, _v1ClaimedVestingPermilleContract);
        }
    }

    function _getV1BonusesVestingAmount(uint256 amount)
        internal
        view
        returns (uint256 Vesting)
    {

        if (amount > 0) {
            Vesting = _getVestingAmount(amount, _v1BonusesVestingPermilleContract);
        }
    }

    function _getV2ClaimedVestingAmount(uint256 amount)
        internal
        view
        returns (uint256 Vesting)
    {

        if (amount > 0) {
            Vesting = _getVestingAmount(amount, _v2ClaimedVestingPermilleContract);
        }
    }

    function _getV2BonusesVestingAmount(uint256 amount)
        internal
        view
        returns (uint256 Vesting)
    {

        if (amount > 0) {
            Vesting = _getVestingAmount(amount, _v2BonusesVestingPermilleContract);
        }
    }
    
    
    function _getVestingAmount(uint256 amount, IPermille permilleContract)
        private
        view
        returns (uint256 Vesting)
    {

        Vesting = amount;
        
        if (permilleContract != IPermille(0)) {
            try permilleContract.permille() returns (uint16 permille) {
                if (permille == 0) {
                    Vesting = 0;
                }

                else if (permille < 1_000) {
                    Vesting = Vesting.mul(permille).div(1_000);
                }
            }

            catch {
            }
        }
    }
}
pragma solidity =0.7.5;





contract ResaleOrUpgradeToVokenTB is IVesting, AuthPause, WithResaleOnly, WithDeadline, WithCoeff, WithUSDPrice, WithUSDToken, WithVestingPermille {

    using SafeMath for uint256;

    struct Resale {
        uint256 usdAudit;
        uint256 usdClaimed;
        uint256 timestamp;
    }

    struct Upgraded {
        uint256 claimed;
        uint256 bonuses;
        uint256 etherUSDPrice;
        uint256 vokenUSDPrice;
        uint256 timestamp;
    }

    uint256 private immutable VOKEN_UPGRADED_CAP = 21_000_000e9;

    uint256 private _usdAudit;
    uint256 private _usdClaimed;

    uint256 private _v1Claimed;
    uint256 private _v1Bonuses;
    uint256 private _v2Claimed;
    uint256 private _v2Bonuses;

    IVokenTB private immutable VOKEN_TB = IVokenTB(0x1234567a022acaa848E7D6bC351d075dBfa76Dd4);

    IERC20 private immutable VOKEN_1 = IERC20(0x82070415FEe803f94Ce5617Be1878503e58F0a6a);  // Voken1.0
    IERC20 private immutable VOKEN_2 = IERC20(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);  // Voken2.0

    IVokenAudit private immutable VOKEN_1_AUDIT = IVokenAudit(0x11111eA590876f5E8416cD4a81A0CFb9DfA2b08E);
    IVokenAudit private immutable VOKEN_2_AUDIT = IVokenAudit(0x22222eA5b84E877A1790b4653a70ad0df8e3E890);

    mapping (address => Resale) private _v1ResaleApplied;
    mapping (address => Resale) private _v2ResaleApplied;
    mapping (address => Upgraded) private _v1UpgradeApplied;
    mapping (address => Upgraded) private _v2UpgradeApplied;


    receive()
        external
        payable
    {
    }

    function applyV1Resale()
        external
    {

        _v1Resale(msg.sender);
    }

    function applyV2Resale()
        external
    {

        _v2Resale(msg.sender);
    }

    function applyV1Upgrade()
        external
    {

        _v1Upgrade(msg.sender);
    }

    function applyV2Upgrade()
        external
    {

        _v2Upgrade(msg.sender);
    }

    function claimV1USD()
        external
    {

        _v1ClaimUSD();
    }

    function claimV2USD()
        external
    {

        _v2ClaimUSD();
    }

    function status()
        public
        view
        returns (
            uint256 deadline,

            uint256 usdAudit,
            uint256 usdClaimed,
            uint256 usdReceived,

            uint256 resaleEtherUSD,

            uint256 v1Claimed,
            uint256 v1Bonuses,
            uint256 v2Claimed,
            uint256 v2Bonuses,

            uint256 etherUSD,
            uint256 vokenUSD
        )
    {

        deadline = _deadline();
        
        usdAudit = _usdAudit;
        usdClaimed = _usdClaimed;
        usdReceived = _usdReceived();

        resaleEtherUSD = resaleEtherUSDPrice();

        v1Claimed = _v1Claimed;
        v1Bonuses = _v1Bonuses;
        v2Claimed =  _v2Claimed;
        v2Bonuses = _v2Bonuses;
        
        etherUSD = _etherUSDPrice();
        vokenUSD = vokenUSDPrice();
    }

    function getAccountStatus(address account)
        public
        view
        returns (
            bool canOnlyResale,
            uint256 v1ResaleAppliedTimestamp,
            uint256 v2ResaleAppliedTimestamp,
            uint256 v1UpgradeAppliedTimestamp,
            uint256 v2UpgradeAppliedTimestamp,

            uint256 v1Balance,
            uint256 v2Balance,
            
            uint256 etherBalance
        )
    {

        canOnlyResale = isResaleOnly(account);

        v1ResaleAppliedTimestamp = _v1ResaleApplied[account].timestamp;
        v1UpgradeAppliedTimestamp = _v1UpgradeApplied[account].timestamp;
        v1Balance = VOKEN_1.balanceOf(account);

        v2ResaleAppliedTimestamp = _v2ResaleApplied[account].timestamp;
        v2UpgradeAppliedTimestamp = _v2UpgradeApplied[account].timestamp;
        v2Balance = VOKEN_2.balanceOf(account);
        
        etherBalance = account.balance;
    }

    function v1ResaleStatus(address account)
        public
        view
        returns (
            uint256 usdQuota,
            uint256 usdAudit,
            uint256 usdClaimed,
            uint256 timestamp
        )
    {

        timestamp = _v1ResaleApplied[account].timestamp;
        if (timestamp > 0) {
            usdQuota = _v1USDQuota(account);
            usdAudit = _v1ResaleApplied[account].usdAudit;
            usdClaimed = _v1ResaleApplied[account].usdClaimed;
        }
    }

    function v2ResaleStatus(address account)
        public
        view
        returns (
            uint256 usdQuota,
            uint256 usdAudit,
            uint256 usdClaimed,
            uint256 timestamp
        )
    {

        timestamp = _v2ResaleApplied[account].timestamp;
        if (timestamp > 0) {
            usdQuota = _v2USDQuota(account);
            usdAudit = _v2ResaleApplied[account].usdAudit;
            usdClaimed = _v2ResaleApplied[account].usdClaimed;
        }
    }

    function v1UpgradeStatus(address account)
        public
        view
        returns (
            uint72 weiPurchased,
            uint72 weiRewarded,
            uint72 weiAudit,
            uint16 txsIn,
            uint16 txsOut,

            uint256 claim,
            uint256 bonus,
            uint256 etherUSD,
            uint256 vokenUSD,

            uint256 timestamp
        )
    {

        (weiPurchased, weiRewarded, weiAudit, txsIn, txsOut) = VOKEN_1_AUDIT.getAccount(account);
        (claim, bonus, etherUSD, vokenUSD, timestamp) = _v1UpgradeQuota(account);
    }

    function v2UpgradeStatus(address account)
        public
        view
        returns (
            uint72 weiPurchased,
            uint72 weiRewarded,
            uint72 weiAudit,
            uint16 txsIn,
            uint16 txsOut,

            uint256 claim,
            uint256 bonus,
            uint256 etherUSD,
            uint256 vokenUSD,
            uint256 timestamp
        )
    {

        (weiPurchased, weiRewarded, weiAudit, txsIn, txsOut) = VOKEN_2_AUDIT.getAccount(account);
        (claim, bonus, etherUSD, vokenUSD, timestamp) = _v2UpgradeQuota(account);
    }

    function vestingOf(address account)
        public
        override
        view
        returns (uint256 vesting)
    {

        vesting = vesting.add(_getV1ClaimedVestingAmount(_v1UpgradeApplied[account].claimed));
        vesting = vesting.add(_getV1BonusesVestingAmount(_v1UpgradeApplied[account].bonuses));
        vesting = vesting.add(_getV2ClaimedVestingAmount(_v2UpgradeApplied[account].claimed));
        vesting = vesting.add(_getV2BonusesVestingAmount(_v2UpgradeApplied[account].bonuses));
    }

    function _usdReceived()
        private
        view
        returns (uint256)
    {

        return _usdClaimed.add(_getUSDBalance());
    }

    function _v1Resale(address account)
        private
        onlyBeforeDeadline
        onlyNotPaused
    {

        require(_v1ResaleApplied[account].timestamp == 0, "Voken1 Resale: already applied before");
        require(_v1UpgradeApplied[account].timestamp == 0, "Voken1 Resale: already applied for upgrade");

        (, , uint256 weiAudit, ,) = VOKEN_1_AUDIT.getAccount(account);
        require(weiAudit > 0, "Voken1 Resale: audit ETH is zero");

        uint256 usdAudit = resaleEtherUSDPrice().mul(weiAudit).div(1 ether);
        _usdAudit = _usdAudit.add(usdAudit);
        _v1ResaleApplied[account].usdAudit = usdAudit;
        _v1ResaleApplied[account].timestamp = block.timestamp;
    }

    function _v2Resale(address account)
        private
        onlyBeforeDeadline
        onlyNotPaused
    {

        require(_v2ResaleApplied[account].timestamp == 0, "Voken2 Resale: already applied before");
        require(_v2UpgradeApplied[account].timestamp == 0, "Voken2 Resale: already applied for upgrade");

        (, , uint256 weiAudit, ,) = VOKEN_2_AUDIT.getAccount(account);
        require(weiAudit > 0, "Voken2 Resale: audit ETH is zero");

        uint256 usdAudit = resaleEtherUSDPrice().mul(weiAudit).div(1 ether);
        _usdAudit = _usdAudit.add(usdAudit);
        _v2ResaleApplied[account].usdAudit = usdAudit;
        _v2ResaleApplied[account].timestamp = block.timestamp;
    }

    function _v1Upgrade(address account)
        private
        onlyBeforeDeadline
        onlyNotPaused
    {

        require(!isResaleOnly(account), "Upgrade from Voken1: can only apply for resale");
        require(_v1ResaleApplied[account].timestamp == 0, "Upgrade from Voken1: already applied for resale");
        require(_v1UpgradeApplied[account].timestamp == 0, "Upgrade from Voken1: already applied before");

        (uint256 claim, uint256 bonus, uint256 etherUSD, uint256 vokenUSD,) = _v1UpgradeQuota(account);
        require(claim > 0 || bonus > 0, "Upgrade from Voken1: not upgradeable");


        uint256 vokenUpgraded = _v1Claimed.add(_v1Bonuses).add(_v2Claimed).add(_v2Bonuses);
        require(vokenUpgraded < VOKEN_UPGRADED_CAP, "Upgrade from Voken1: out of the cap");

        if (claim > 0) {
            VOKEN_TB.mintWithVesting(account, claim, address(this));
            _v1Claimed = _v1Claimed.add(claim);
            _v1UpgradeApplied[account].claimed = claim;
        }

        if (bonus > 0) {
            VOKEN_TB.mintWithVesting(account, bonus, address(this));
            _v1Bonuses = _v1Bonuses.add(bonus);
            _v1UpgradeApplied[account].bonuses = bonus;
        }

        _v1UpgradeApplied[account].etherUSDPrice = etherUSD;
        _v1UpgradeApplied[account].vokenUSDPrice = vokenUSD;
        _v1UpgradeApplied[account].timestamp = block.timestamp;
    }

    function _v2Upgrade(address account)
        private
        onlyBeforeDeadline
        onlyNotPaused
    {

        require(!isResaleOnly(account), "Upgrade from Voken2: can only apply for resale");
        require(_v2ResaleApplied[account].timestamp == 0, "Upgrade from Voken2: already applied for resale");
        require(_v2UpgradeApplied[account].timestamp == 0, "Upgrade from Voken2: already applied for upgrade");

        (uint256 claim, uint256 bonus, uint256 etherUSD, uint256 vokenUSD,) = _v2UpgradeQuota(account);
        require(claim > 0 || bonus > 0, "Upgrade from Voken2: not upgradeable");

        uint256 vokenUpgraded = _v1Claimed.add(_v1Bonuses).add(_v2Claimed).add(_v2Bonuses);
        require(vokenUpgraded < VOKEN_UPGRADED_CAP, "Upgrade from Voken2: out of the cap");

        if (claim > 0) {
            VOKEN_TB.mintWithVesting(account, claim, address(this));
            _v2Claimed = _v2Claimed.add(claim);
            _v2UpgradeApplied[account].claimed = claim;
        }

        if (bonus > 0) {
            VOKEN_TB.mintWithVesting(account, bonus, address(this));
            _v2Bonuses = _v2Bonuses.add(bonus);
            _v2UpgradeApplied[account].bonuses = bonus;
        }

        _v2UpgradeApplied[account].etherUSDPrice = etherUSD;
        _v2UpgradeApplied[account].vokenUSDPrice = vokenUSD;
        _v2UpgradeApplied[account].timestamp = block.timestamp;
    }

    function _v1ClaimUSD()
        private
    {

        require(_v1ResaleApplied[msg.sender].timestamp > 0, "Have not applied for resale yet");

        uint256 balance = _getUSDBalance();
        require(balance > 0, "USD balance is zero");

        uint256 quota = _v1USDQuota(msg.sender);
        require(quota > 0, "No USD quota to claim");

        if (quota < balance) {
            _usdClaimed = _usdClaimed.add(quota);
            _v1ResaleApplied[msg.sender].usdClaimed = _v1ResaleApplied[msg.sender].usdClaimed.add(quota);
            _transferUSD(msg.sender, quota);
        }

        else {
            _usdClaimed = _usdClaimed.add(balance);
            _v1ResaleApplied[msg.sender].usdClaimed = _v1ResaleApplied[msg.sender].usdClaimed.add(balance);
            _transferUSD(msg.sender, balance);
        }
    }

    function _v2ClaimUSD()
        private
    {

        require(_v2ResaleApplied[msg.sender].timestamp > 0, "Have not applied for resale yet");
        
        uint256 balance = _getUSDBalance();
        require(balance > 0, "USD balance is zero");

        uint256 quota = _v2USDQuota(msg.sender);
        require(quota > 0, "No USD quota to claim");

        if (quota < balance) {
            _usdClaimed = _usdClaimed.add(quota);
            _v2ResaleApplied[msg.sender].usdClaimed = _v2ResaleApplied[msg.sender].usdClaimed.add(quota);
            _transferUSD(msg.sender, quota);
        }

        else {
            _usdClaimed = _usdClaimed.add(balance);
            _v2ResaleApplied[msg.sender].usdClaimed = _v2ResaleApplied[msg.sender].usdClaimed.add(balance);
            _transferUSD(msg.sender, balance);
        }
    }

    function _v1USDQuota(address account)
        private
        view
        returns (uint256 quota)
    {

        if (_v1ResaleApplied[account].usdAudit > 0 && _usdAudit > 0) {
            uint256 amount = _usdReceived().mul(_v1ResaleApplied[account].usdAudit).div(_usdAudit);

            if (_v1ResaleApplied[account].usdClaimed <= amount) {
                quota = amount.sub(_v1ResaleApplied[account].usdClaimed);
            }

            uint256 balance = _getUSDBalance();
            if (balance < quota) {
                quota = balance;
            }

            uint256 diff = _v1ResaleApplied[account].usdAudit.sub(_v1ResaleApplied[account].usdClaimed);
            
            if (diff < quota) {
                quota = diff;
            }
        }
    }

    function _v2USDQuota(address account)
        private
        view
        returns (uint256 quota)
    {

        if (_v2ResaleApplied[account].usdAudit > 0 && _usdAudit > 0) {
            uint256 amount = _usdReceived().mul(_v2ResaleApplied[account].usdAudit).div(_usdAudit);

            if (_v2ResaleApplied[account].usdClaimed <= amount) {
                quota = amount.sub(_v2ResaleApplied[account].usdClaimed);
            }
            
            uint256 balance = _getUSDBalance();
            if (balance < quota) {
                quota = balance;
            }

            uint256 diff = _v2ResaleApplied[account].usdAudit.sub(_v2ResaleApplied[account].usdClaimed);
            
            if (diff < quota) {
                quota = diff;
            }
        }
    }

    function _v1UpgradeQuota(address account)
        private
        view
        returns (
            uint256 claim,
            uint256 bonus,
            uint256 etherUSD,
            uint256 vokenUSD,
            uint256 timestamp
        )
    {

        timestamp = _v1UpgradeApplied[account].timestamp;

        if (timestamp > 0) {
            claim = _v1UpgradeApplied[account].claimed;
            bonus = _v1UpgradeApplied[account].bonuses;
            etherUSD = _v1UpgradeApplied[account].etherUSDPrice;
            vokenUSD = _v1UpgradeApplied[account].vokenUSDPrice;
        }

        else {
            (, , uint256 wei_audit, ,) = VOKEN_1_AUDIT.getAccount(account);
            
            if (!isResaleOnly(account)) {
                etherUSD = _etherUSDPrice();
                vokenUSD = vokenUSDPrice();

                claim = wei_audit.mul(etherUSD).div(1e15).div(vokenUSD).mul(1e6);
                bonus = claim.mul(v1BonusCoeff()).div(1e3);

                uint256 shift = VOKEN_1.balanceOf(account).div(v1ClaimRatio()).div(1e3).mul(1e6);
                uint256 mint = claim.add(bonus);
        
                if (mint < shift) {
                    bonus = shift.sub(claim);
                }
            }
        }
    }

    function _v2UpgradeQuota(address account)
        private
        view
        returns (
            uint256 claim,
            uint256 bonus,
            uint256 etherUSD,
            uint256 vokenUSD,
            uint256 timestamp
        )
    {

        timestamp = _v2UpgradeApplied[account].timestamp;

        if (timestamp > 0) {
            claim = _v2UpgradeApplied[account].claimed;
            bonus = _v2UpgradeApplied[account].bonuses;
            etherUSD = _v2UpgradeApplied[account].etherUSDPrice;
            vokenUSD = _v2UpgradeApplied[account].vokenUSDPrice;
        }

        else {
            (, , uint256 wei_audit, ,) = VOKEN_2_AUDIT.getAccount(account);
            
            if (!isResaleOnly(account)) {
                etherUSD = _etherUSDPrice();
                vokenUSD = vokenUSDPrice();

                claim = wei_audit.mul(etherUSD).div(1e15).div(vokenUSD).mul(1e6);
                bonus = claim.mul(v2BonusCoeff()).div(1e3);

                uint256 shift = VOKEN_2.balanceOf(account).div(v2ClaimRatio()).div(1e3).mul(1e6);
                uint256 mint = claim.add(bonus);
        
                if (mint < shift) {
                    bonus = shift.sub(claim);
                }
            }
        }
    }

    function max(uint256 a, uint256 b)
        private
        pure
        returns (uint256)
    {

        return a > b ? a : b;
    }
}
