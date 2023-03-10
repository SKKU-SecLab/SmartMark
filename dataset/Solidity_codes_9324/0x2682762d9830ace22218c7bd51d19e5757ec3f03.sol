
pragma solidity 0.4.15;

contract IAccessPolicy {



    function allowed(
        address subject,
        bytes32 role,
        address object,
        bytes4 verb
    )
        public
        returns (bool);

}

contract IAccessControlled {



    event LogAccessPolicyChanged(
        address controller,
        IAccessPolicy oldPolicy,
        IAccessPolicy newPolicy
    );


    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)
        public;


    function accessPolicy()
        public
        constant
        returns (IAccessPolicy);


}

contract StandardRoles {



    bytes32 internal constant ROLE_ACCESS_CONTROLLER = 0xac42f8beb17975ed062dcb80c63e6d203ef1c2c335ced149dc5664cc671cb7da;
}

contract AccessControlled is IAccessControlled, StandardRoles {



    IAccessPolicy private _accessPolicy;


    modifier only(bytes32 role) {

        require(_accessPolicy.allowed(msg.sender, role, this, msg.sig));
        _;
    }


    function AccessControlled(IAccessPolicy policy) internal {

        require(address(policy) != 0x0);
        _accessPolicy = policy;
    }



    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)
        public
        only(ROLE_ACCESS_CONTROLLER)
    {

        require(newPolicy.allowed(newAccessController, ROLE_ACCESS_CONTROLLER, this, msg.sig));

        IAccessPolicy oldPolicy = _accessPolicy;
        _accessPolicy = newPolicy;

        LogAccessPolicyChanged(msg.sender, oldPolicy, newPolicy);
    }

    function accessPolicy()
        public
        constant
        returns (IAccessPolicy)
    {

        return _accessPolicy;
    }
}

contract IMigrationTarget {



    function currentMigrationSource()
        public
        constant
        returns (address);

}

contract MigrationTarget is
    IMigrationTarget
{


    modifier onlyMigrationSource() {

        require(msg.sender == currentMigrationSource());
        _;
    }
}

contract EuroTokenMigrationTarget is
    MigrationTarget
{


    function migrateEuroTokenOwner(address owner, uint256 amount)
        public
        onlyMigrationSource();

}

contract IMigrationSource {



    event LogMigrationEnabled(
        address target
    );


    function migrate()
        public;


    function enableMigration(IMigrationTarget migration)
        public;


    function currentMigrationTarget()
        public
        constant
        returns (IMigrationTarget);

}

contract MigrationSource is
    IMigrationSource,
    AccessControlled
{


    bytes32 private MIGRATION_ADMIN;


    IMigrationTarget internal _migration;


    modifier onlyMigrationEnabledOnce() {

        require(address(_migration) == 0);
        _;
    }

    modifier onlyMigrationEnabled() {

        require(address(_migration) != 0);
        _;
    }


    function MigrationSource(
        IAccessPolicy policy,
        bytes32 migrationAdminRole
    )
        AccessControlled(policy)
        internal
    {

        MIGRATION_ADMIN = migrationAdminRole;
    }


    function migrate()
        onlyMigrationEnabled()
        public;


    function enableMigration(IMigrationTarget migration)
        public
        onlyMigrationEnabledOnce()
        only(MIGRATION_ADMIN)
    {

        require(migration.currentMigrationSource() == address(this));
        _migration = migration;
        LogMigrationEnabled(_migration);
    }

    function currentMigrationTarget()
        public
        constant
        returns (IMigrationTarget)
    {

        return _migration;
    }
}

contract AccessRoles {




    bytes32 internal constant ROLE_LOCKED_ACCOUNT_ADMIN = 0x4675da546d2d92c5b86c4f726a9e61010dce91cccc2491ce6019e78b09d2572e;

    bytes32 internal constant ROLE_WHITELIST_ADMIN = 0xaef456e7c864418e1d2a40d996ca4febf3a7e317fe3af5a7ea4dda59033bbe5c;

    bytes32 internal constant ROLE_NEUMARK_ISSUER = 0x921c3afa1f1fff707a785f953a1e197bd28c9c50e300424e015953cbf120c06c;

    bytes32 internal constant ROLE_NEUMARK_BURNER = 0x19ce331285f41739cd3362a3ec176edffe014311c0f8075834fdd19d6718e69f;

    bytes32 internal constant ROLE_SNAPSHOT_CREATOR = 0x08c1785afc57f933523bc52583a72ce9e19b2241354e04dd86f41f887e3d8174;

    bytes32 internal constant ROLE_TRANSFER_ADMIN = 0xb6527e944caca3d151b1f94e49ac5e223142694860743e66164720e034ec9b19;

    bytes32 internal constant ROLE_RECLAIMER = 0x0542bbd0c672578966dcc525b30aa16723bb042675554ac5b0362f86b6e97dc5;

    bytes32 internal constant ROLE_PLATFORM_OPERATOR_REPRESENTATIVE = 0xb2b321377653f655206f71514ff9f150d0822d062a5abcf220d549e1da7999f0;

    bytes32 internal constant ROLE_EURT_DEPOSIT_MANAGER = 0x7c8ecdcba80ce87848d16ad77ef57cc196c208fc95c5638e4a48c681a34d4fe7;
}

contract IBasicToken {



    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount);


    function totalSupply()
        public
        constant
        returns (uint256);


    function balanceOf(address owner)
        public
        constant
        returns (uint256 balance);


    function transfer(address to, uint256 amount)
        public
        returns (bool success);


}

contract Reclaimable is AccessControlled, AccessRoles {



    IBasicToken constant internal RECLAIM_ETHER = IBasicToken(0x0);


    function reclaim(IBasicToken token)
        public
        only(ROLE_RECLAIMER)
    {

        address reclaimer = msg.sender;
        if(token == RECLAIM_ETHER) {
            reclaimer.transfer(this.balance);
        } else {
            uint256 balance = token.balanceOf(this);
            require(token.transfer(reclaimer, balance));
        }
    }
}

contract ITokenMetadata {



    function symbol()
        public
        constant
        returns (string);


    function name()
        public
        constant
        returns (string);


    function decimals()
        public
        constant
        returns (uint8);

}

contract TokenMetadata is ITokenMetadata {



    string private NAME;

    string private SYMBOL;

    uint8 private DECIMALS;

    string private VERSION;


    function TokenMetadata(
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        string version
    )
        public
    {

        NAME = tokenName;                                 // Set the name
        SYMBOL = tokenSymbol;                             // Set the symbol
        DECIMALS = decimalUnits;                          // Set the decimals
        VERSION = version;
    }


    function name()
        public
        constant
        returns (string)
    {

        return NAME;
    }

    function symbol()
        public
        constant
        returns (string)
    {

        return SYMBOL;
    }

    function decimals()
        public
        constant
        returns (uint8)
    {

        return DECIMALS;
    }

    function version()
        public
        constant
        returns (string)
    {

        return VERSION;
    }
}

contract IERC20Allowance {



    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount);


    function allowance(address owner, address spender)
        public
        constant
        returns (uint256 remaining);


    function approve(address spender, uint256 amount)
        public
        returns (bool success);


    function transferFrom(address from, address to, uint256 amount)
        public
        returns (bool success);


}

contract IERC20Token is IBasicToken, IERC20Allowance {


}

contract IERC677Callback {



    function receiveApproval(
        address from,
        uint256 amount,
        address token, // IERC667Token
        bytes data
    )
        public
        returns (bool success);


}

contract IERC677Allowance is IERC20Allowance {



    function approveAndCall(address spender, uint256 amount, bytes extraData)
        public
        returns (bool success);


}

contract IERC677Token is IERC20Token, IERC677Allowance {

}

contract Math {



    function absDiff(uint256 v1, uint256 v2)
        internal
        constant
        returns(uint256)
    {

        return v1 > v2 ? v1 - v2 : v2 - v1;
    }

    function divRound(uint256 v, uint256 d)
        internal
        constant
        returns(uint256)
    {

        return add(v, d/2) / d;
    }

    function decimalFraction(uint256 amount, uint256 frac)
        internal
        constant
        returns(uint256)
    {

        return proportion(amount, frac, 10**18);
    }

    function proportion(uint256 amount, uint256 part, uint256 total)
        internal
        constant
        returns(uint256)
    {

        return divRound(mul(amount, part), total);
    }


    function mul(uint256 a, uint256 b)
        internal
        constant
        returns (uint256)
    {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        constant
        returns (uint256)
    {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        constant
        returns (uint256)
    {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b)
        internal
        constant
        returns (uint256)
    {

        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b)
        internal
        constant
        returns (uint256)
    {

        return a > b ? a : b;
    }
}

contract BasicToken is IBasicToken, Math {



    mapping(address => uint256) internal _balances;

    uint256 internal _totalSupply;


    function transfer(address to, uint256 amount)
        public
        returns (bool)
    {

        transferInternal(msg.sender, to, amount);
        return true;
    }

    function totalSupply()
        public
        constant
        returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(address owner)
        public
        constant
        returns (uint256 balance)
    {

        return _balances[owner];
    }


    function transferInternal(address from, address to, uint256 amount)
        internal
    {

        require(to != address(0));

        _balances[from] = sub(_balances[from], amount);
        _balances[to] = add(_balances[to], amount);
        Transfer(from, to, amount);
    }
}

contract StandardToken is
    IERC20Token,
    BasicToken,
    IERC677Token
{



    mapping (address => mapping (address => uint256)) private _allowed;



    function transferFrom(address from, address to, uint256 amount)
        public
        returns (bool)
    {

        var allowance = _allowed[from][msg.sender];
        _allowed[from][msg.sender] = sub(allowance, amount);
        transferInternal(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        returns (bool)
    {


        require((amount == 0) || (_allowed[msg.sender][spender] == 0));

        _allowed[msg.sender][spender] = amount;
        Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        constant
        returns (uint256 remaining)
    {

        return _allowed[owner][spender];
    }


    function approveAndCall(
        address spender,
        uint256 amount,
        bytes extraData
    )
        public
        returns (bool)
    {

        require(approve(spender, amount));

        bool success = IERC677Callback(spender).receiveApproval(
            msg.sender,
            amount,
            this,
            extraData
        );
        require(success);

        return true;
    }
}

contract EuroToken is
    IERC677Token,
    AccessControlled,
    StandardToken,
    TokenMetadata,
    MigrationSource,
    Reclaimable
{


    string private constant NAME = "Euro Token";

    string private constant SYMBOL = "EUR-T";

    uint8 private constant DECIMALS = 18;


    mapping(address => bool) private _allowedTransferTo;

    mapping(address => bool) private _allowedTransferFrom;


    event LogDeposit(
        address indexed to,
        uint256 amount
    );

    event LogWithdrawal(
        address indexed from,
        uint256 amount
    );

    event LogAllowedFromAddress(
        address indexed from,
        bool allowed
    );

    event LogAllowedToAddress(
        address indexed to,
        bool allowed
    );

    event LogEuroTokenOwnerMigrated(
        address indexed owner,
        uint256 amount
    );


    modifier onlyAllowedTransferFrom(address from) {

        require(_allowedTransferFrom[from]);
        _;
    }

    modifier onlyAllowedTransferTo(address to) {

        require(_allowedTransferTo[to]);
        _;
    }


    function EuroToken(IAccessPolicy accessPolicy)
        AccessControlled(accessPolicy)
        StandardToken()
        TokenMetadata(NAME, DECIMALS, SYMBOL, "")
        MigrationSource(accessPolicy, ROLE_EURT_DEPOSIT_MANAGER)
        Reclaimable()
        public
    {

    }


    function deposit(address to, uint256 amount)
        public
        only(ROLE_EURT_DEPOSIT_MANAGER)
        returns (bool)
    {

        require(to != address(0));
        _balances[to] = add(_balances[to], amount);
        _totalSupply = add(_totalSupply, amount);
        setAllowedTransferTo(to, true);
        LogDeposit(to, amount);
        Transfer(address(0), to, amount);
        return true;
    }

    function withdraw(uint256 amount)
        public
    {

        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] = sub(_balances[msg.sender], amount);
        _totalSupply = sub(_totalSupply, amount);
        LogWithdrawal(msg.sender, amount);
        Transfer(msg.sender, address(0), amount);
    }

    function setAllowedTransferTo(address to, bool allowed)
        public
        only(ROLE_EURT_DEPOSIT_MANAGER)
    {

        _allowedTransferTo[to] = allowed;
        LogAllowedToAddress(to, allowed);
    }

    function setAllowedTransferFrom(address from, bool allowed)
        public
        only(ROLE_EURT_DEPOSIT_MANAGER)
    {

        _allowedTransferFrom[from] = allowed;
        LogAllowedFromAddress(from, allowed);
    }

    function allowedTransferTo(address to)
        public
        constant
        returns (bool)
    {

        return _allowedTransferTo[to];
    }

    function allowedTransferFrom(address from)
        public
        constant
        returns (bool)
    {

        return _allowedTransferFrom[from];
    }


    function transfer(address to, uint256 amount)
        public
        onlyAllowedTransferFrom(msg.sender)
        onlyAllowedTransferTo(to)
        returns (bool success)
    {

        return BasicToken.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount)
        public
        onlyAllowedTransferFrom(msg.sender)
        onlyAllowedTransferTo(to)
        returns (bool success)
    {

        return StandardToken.transferFrom(from, to, amount);
    }


    function migrate()
        public
        onlyMigrationEnabled()
        onlyAllowedTransferTo(msg.sender)
    {

        uint256 amount = _balances[msg.sender];
        if (amount > 0) {
            _balances[msg.sender] = 0;
            _totalSupply = sub(_totalSupply, amount);
        }
        _allowedTransferTo[msg.sender] = false;
        _allowedTransferFrom[msg.sender] = false;
        EuroTokenMigrationTarget(_migration).migrateEuroTokenOwner(msg.sender, amount);
        LogEuroTokenOwnerMigrated(msg.sender, amount);
    }
}