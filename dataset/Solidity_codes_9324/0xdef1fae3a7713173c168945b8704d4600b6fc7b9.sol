
pragma solidity ^0.8.0;


interface IDefiFactoryToken {

    function mintHumanAddress(address to, uint desiredAmountToMint) external;


    function burnHumanAddress(address from, uint desiredAmountToBurn) external;


    function mintUniswapContract(address to, uint realAmountToMint) external;


    function burnUniswapContract(address from, uint realAmountBurn) external;

    
    function getUtilsContractAtPos(uint pos)
        external
        view
        returns (address);

        
    function transferFromTeamVestingContract(address recipient, uint256 amount) external;

}

struct TaxAmountsInput {
    address sender;
    address recipient;
    uint transferAmount;
    uint senderRealBalance;
    uint recipientRealBalance;
}
struct TaxAmountsOutput {
    uint senderRealBalance;
    uint recipientRealBalance;
    uint burnAndRewardAmount;
    uint recipientGetsAmount;
}
struct TemporaryReferralRealAmountsBulk {
    address addr;
    uint realBalance;
}

interface INoBotsTech {

    function prepareTaxAmounts(
        TaxAmountsInput calldata taxAmountsInput
    ) 
        external
        returns(TaxAmountsOutput memory taxAmountsOutput);

    
    function getTemporaryReferralRealAmountsBulk(address[] calldata addrs)
        external
        view
        returns (TemporaryReferralRealAmountsBulk[] memory);

        
    function prepareHumanAddressMintOrBurnRewardsAmounts(bool isMint, address account, uint desiredAmountToMintOrBurn)
        external
        returns (uint realAmountToMintOrBurn);

        
    function getBalance(address account, uint accountBalance)
        external
        view
        returns(uint);

        
    function getRealBalance(address account, uint accountBalance)
        external
        view
        returns(uint);

        
    function getRealBalanceTeamVestingContract(uint accountBalance)
        external
        view
        returns(uint);

        
    function getTotalSupply()
        external
        view
        returns (uint);

        
    function grantRole(bytes32 role, address account) 
        external;

        
    function getCalculatedReferrerRewards(address addr, address[] calldata referrals)
        external
        view
        returns (uint);

        
    function getCachedReferrerRewards(address addr)
        external
        view
        returns (uint);

    
    function updateReferrersRewards(address[] calldata referrals)
        external;

    
    function clearReferrerRewards(address addr)
        external;

    
    function chargeCustomTax(uint taxAmount, uint accountBalance)
        external
        returns (uint);

    
    function chargeCustomTaxTeamVestingContract(uint taxAmount, uint accountBalance)
        external
        returns (uint);

        
    function registerReferral(address referral, address referrer)
        external;

        
    function filterNonZeroReferrals(address[] calldata referrals)
        external
        view
        returns (address[] memory);

        
    function publicForcedUpdateCacheMultiplier()
        external;

    
    event MultiplierUpdated(uint newMultiplier);
    event BotTransactionDetected(address from, address to, uint transferAmount, uint taxedAmount);
    event ReferrerRewardUpdated(address referrer, uint amount);
    event ReferralRegistered(address referral, address referrer);
    event ReferrerReplaced(address referral, address referrerFrom, address referrerTo);
}

interface IUniswapV2Factory {

    
    function getPair(
        address tokenA,
        address tokenB
    )
        external
        view
        returns (address);

        
    function createPair(
        address tokenA,
        address tokenB
    ) 
        external
        returns (address);

        
}

interface IUniswapV2Pair {

    
    function sync()
        external;

        
    function getReserves()
        external
        view
        returns (uint, uint, uint32);

        
    function token0()
        external
        view
        returns (address);

        
    function token1()
        external
        view
        returns (address);

        
    function mint(address to) 
        external
        returns (uint);       

    
    function swap(
        uint amount0Out, 
        uint amount1Out, 
        address to, 
        bytes calldata data
    ) external;

}

interface IWeth {


    function balanceOf(
        address account
    )
        external
        view
        returns (uint);

        
    function decimals()
        external
        view
        returns (uint);


    function transfer(
        address _to,
        uint _value
    )  external returns (
        bool success
    );

        
    function deposit()
        external
        payable;


    function withdraw(
        uint wad
    ) external;


    function approve(
        address _spender,
        uint _value
    )  external returns (
        bool success
    );

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant ROLE_ADMIN = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

interface IAccessControlEnumerable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}

contract TeamVestingContract is AccessControlEnumerable {

    bytes32 public constant ROLE_WHITELIST = keccak256("ROLE_WHITELIST");
    
    uint constant NOBOTS_TECH_CONTRACT_ID = 0;
    uint constant UNISWAP_V2_FACTORY_CONTRACT_ID = 2;

    struct Investor {
        address addr;
        uint wethValue;
        uint sentValue;
        uint startDelay;
        uint lockFor;
    }
    
    enum States { AcceptingPayments, ReachedGoal, PreparedAddLiqudity, CreatedPair, AddedLiquidity, DistributedTokens }
    States public state;
    
    mapping(address => uint) cachedIndex;
    Investor[] investors;
    uint public totalInvested;
    uint public totalSent;
    
    address public defiFactoryToken;
    
    uint public constant TOTAL_SUPPLY_CAP = 100 * 1e9 * 1e18; // 100B DEFT
    
    uint public percentForTheTeam = 30; // 5% - marketing; 10% - team; 15% - developer
    uint public percentForUniswap = 70; // 70% - to uniswap
    uint constant PERCENT_DENORM = 100;
    
    address public nativeToken;
    
    address public developerAddress;
    uint public developerCap;
    uint public constant DEVELOPER_STARTING_LOCK_DELAY = 0 days;
    uint public constant DEVELOPER_STARTING_LOCK_FOR = 730 days;
    
    address public teamAddress;
    uint public teamCap;
    uint public constant TEAM_STARTING_LOCK_DELAY = 0 days;
    uint public constant TEAM_STARTING_LOCK_FOR = 730 days;
    
    address public marketingAddress;
    uint public marketingCap;
    uint public constant MARKETING_STARTING_LOCK_DELAY = 0;
    uint public constant MARKETING_STARTING_LOCK_FOR = 365 days;
    
    uint public startedLocking;
    address public wethAndTokenPairContract;
    
    
    uint public amountOfTokensForInvestors;
    
    address constant BURN_ADDRESS = address(0x0);
    
    constructor() {
        _setupRole(ROLE_ADMIN, _msgSender());
        state = States.AcceptingPayments;
    }

    receive() external payable {
        require(state == States.AcceptingPayments, "TVC: Accepting payments has been stopped!");
        
        addInvestor(_msgSender(), msg.value);
    }

    function addInvestor(address addr, uint wethValue)
        internal
    {

        uint updMaxInvestAmount;
        uint lockFor;
        uint startDelay;
        if (addr == developerAddress)
        {
            updMaxInvestAmount = developerCap;
            lockFor = DEVELOPER_STARTING_LOCK_FOR;
            startDelay = DEVELOPER_STARTING_LOCK_DELAY;
        } else if (addr == teamAddress)
        {
            updMaxInvestAmount = teamCap;
            lockFor = TEAM_STARTING_LOCK_FOR;
            startDelay = TEAM_STARTING_LOCK_DELAY;
        } else if (addr == marketingAddress) 
        {
            updMaxInvestAmount = marketingCap;
            lockFor = MARKETING_STARTING_LOCK_FOR;
            startDelay = MARKETING_STARTING_LOCK_DELAY;
        } else
        {
            revert("TVC: Only team, dev and marketing addresses allowed!");
        }
        
        if (cachedIndex[addr] == 0)
        {
            investors.push(
                Investor(
                    addr, 
                    wethValue,
                    0,
                    startDelay,
                    lockFor
                )
            );
            cachedIndex[addr] = investors.length;
        } else
        {
            investors[cachedIndex[addr] - 1].wethValue += wethValue;
        }
        require(
            investors[cachedIndex[addr] - 1].wethValue <= updMaxInvestAmount,
            "TVC: Requires Investor max amount less than maxInvestAmount!"
        );
        
        totalInvested += wethValue;
    }
    
    function markGoalAsReachedAndPrepareLiqudity()
        public
        onlyRole(ROLE_ADMIN)
    {

        state = States.ReachedGoal;
        
        prepareAddLiqudity();
    }
    
    function prepareAddLiqudity()
        internal
    {

        require(state == States.ReachedGoal, "TVC: Preparing add liquidity is completed!");
        require(address(this).balance > 0, "TVC: Ether balance must be larger than zero!");
        
        IWeth iWeth = IWeth(nativeToken);
        iWeth.deposit{ value: address(this).balance }();
        
        state = States.PreparedAddLiqudity;
    }
    
    function createPairOnUniswapV2()
        public
        onlyRole(ROLE_ADMIN)
    {

        require(state == States.PreparedAddLiqudity, "TVC: Pair is already created!");

        IUniswapV2Factory iUniswapV2Factory = IUniswapV2Factory(
            IDefiFactoryToken(defiFactoryToken).
                getUtilsContractAtPos(UNISWAP_V2_FACTORY_CONTRACT_ID)
        );
        wethAndTokenPairContract = iUniswapV2Factory.getPair(defiFactoryToken, nativeToken);
        if (wethAndTokenPairContract == BURN_ADDRESS)
        {
            wethAndTokenPairContract = iUniswapV2Factory.createPair(nativeToken, defiFactoryToken);
        }
           
        INoBotsTech iNoBotsTech = INoBotsTech(
            IDefiFactoryToken(defiFactoryToken).
                getUtilsContractAtPos(NOBOTS_TECH_CONTRACT_ID)
        ); 
        iNoBotsTech.grantRole(ROLE_WHITELIST, wethAndTokenPairContract);
        
        state = States.CreatedPair;
    }
    
    function addLiquidityOnUniswapV2()
        public
        onlyRole(ROLE_ADMIN)
    {

        require(state == States.CreatedPair, "TVC: Liquidity is already added!");
        
        IWeth iWeth = IWeth(nativeToken);
        uint wethAmount = iWeth.balanceOf(address(this));
        iWeth.transfer(wethAndTokenPairContract, wethAmount);
        
        uint amountOfTokensForUniswap = (TOTAL_SUPPLY_CAP * percentForUniswap) / PERCENT_DENORM; // 70% for uniswap
        
        IDefiFactoryToken iDefiFactoryToken = IDefiFactoryToken(defiFactoryToken);
        iDefiFactoryToken.mintHumanAddress(wethAndTokenPairContract, amountOfTokensForUniswap);
        
        IUniswapV2Pair iPair = IUniswapV2Pair(wethAndTokenPairContract);
        iPair.mint(_msgSender());
    
        state = States.AddedLiquidity;
        
        distributeTokens();
    }

    function distributeTokens()
        internal
    {

        require(state == States.AddedLiquidity, "TVC: Tokens have already been distributed!");
        
        INoBotsTech iNoBotsTech = INoBotsTech(
            IDefiFactoryToken(defiFactoryToken).
                getUtilsContractAtPos(NOBOTS_TECH_CONTRACT_ID)
        );
        
        iNoBotsTech.grantRole(ROLE_WHITELIST, address(this));
        
        amountOfTokensForInvestors = (TOTAL_SUPPLY_CAP * percentForTheTeam) / PERCENT_DENORM; // 30% for the team
        IDefiFactoryToken iDefiFactoryToken = IDefiFactoryToken(defiFactoryToken);
        iDefiFactoryToken.mintHumanAddress(address(this), amountOfTokensForInvestors);
        
        startedLocking = block.timestamp;
        
        state = States.DistributedTokens;
    }
    
    function claimTeamVestingTokens(uint amount)
        public
    {

        address addr = _msgSender();
        
        uint claimableAmount = getClaimableTokenAmount(addr);
        require(claimableAmount > 0, "TVC: !claimable_amount");
        
        if (
            amount == 0 || 
            amount > claimableAmount
        ) {
            amount = claimableAmount;
        }
        
        investors[cachedIndex[addr] - 1].sentValue += amount;
        
        IDefiFactoryToken iDefiFactoryToken = IDefiFactoryToken(defiFactoryToken);
        iDefiFactoryToken.transferFromTeamVestingContract(addr, amount);
    }
    
    function burnVestingTokens(uint amount)
        public
        onlyRole(ROLE_ADMIN)
    {

        IDefiFactoryToken iDefiFactoryToken = IDefiFactoryToken(defiFactoryToken);
        iDefiFactoryToken.burnHumanAddress(address(this), amount);
        
        amountOfTokensForInvestors -= amount;
    }
    
    function taxVestingTokens(uint amount)
        public
        onlyRole(ROLE_ADMIN)
    {

        INoBotsTech iNoBotsTech = INoBotsTech(
            IDefiFactoryToken(defiFactoryToken).
                getUtilsContractAtPos(NOBOTS_TECH_CONTRACT_ID)
        );
        
        amountOfTokensForInvestors = iNoBotsTech.chargeCustomTaxTeamVestingContract(
            amount, 
            amountOfTokensForInvestors
        );
    }
    
    function getClaimableTokenAmount(address addr)
        public
        view
        returns(uint)
    {

        require(state == States.DistributedTokens, "TVC: Tokens aren't distributed yet!");
        
        require(cachedIndex[addr] > 0, "TVC: !exist");
        
        Investor memory investor = investors[cachedIndex[addr] - 1];
        
        uint realStartedLocking = startedLocking + investor.startDelay;
        if (block.timestamp < realStartedLocking) return 0;
        
        uint lockedUntil = realStartedLocking + investor.lockFor; 
        uint nominator = 1;
        uint denominator = 1;
        if (block.timestamp < lockedUntil)
        {
            nominator = block.timestamp - realStartedLocking;
            denominator = investor.lockFor;
        }
            
        uint claimableAmount = 
            (investor.wethValue * amountOfTokensForInvestors * nominator) / 
                (denominator * totalInvested);
                
        if (claimableAmount <= investor.sentValue) return 0;
        claimableAmount -= investor.sentValue;
        
        return claimableAmount;
    }
    
    function getLeftTokenAmount(address addr)
        public
        view
        returns(uint)
    {

        require(state == States.DistributedTokens, "TVC: Tokens aren't distributed yet!");
        
        Investor memory investor = investors[cachedIndex[addr] - 1];
        uint leftAmount = 
            (investor.wethValue * amountOfTokensForInvestors) / 
                (totalInvested);
                
        if (leftAmount <= investor.sentValue) return 0;
        leftAmount -= investor.sentValue;
        
        return leftAmount;
    }
    
    function getInvestorsCount()
        public
        view
        returns(uint)
    {

        return investors.length;
    }
    
    function getInvestorByAddr(address addr)
        external
        view
        returns(Investor memory)
    {

        return investors[cachedIndex[addr] - 1];
    }
    
    function getInvestorByPos(uint pos)
        external
        view
        returns(Investor memory)
    {

        return investors[pos];
    }
    
    function listInvestors(uint offset, uint limit)
        public
        view
        returns(Investor[] memory)
    {

        uint start = offset;
        uint end = offset + limit;
        end = (end > investors.length)? investors.length: end;
        uint numItems = (end > start)? end - start: 0;
        
        Investor[] memory listOfInvestors = new Investor[](numItems);
        for(uint i = start; i < end; i++)
        {
            listOfInvestors[i - start] = investors[i];
        }
        
        return listOfInvestors;
    }
    
    function updateDefiFactoryContract(address newContract)
        external
        onlyRole(ROLE_ADMIN)
    {

        defiFactoryToken = newContract;
    }
    
    function updateInvestmentSettings(
        address _nativeToken, 
        address _developerAddress, uint _developerCap,
        address _teamAddress, uint _teamCap,
        address _marketingAddress, uint _marketingCap
    )
        public
        onlyRole(ROLE_ADMIN)
    {

        nativeToken = _nativeToken;
        developerAddress = _developerAddress;
        developerCap = _developerCap;
        teamAddress = _teamAddress;
        teamCap = _teamCap;
        marketingAddress = _marketingAddress;
        marketingCap = _marketingCap;
    }
}