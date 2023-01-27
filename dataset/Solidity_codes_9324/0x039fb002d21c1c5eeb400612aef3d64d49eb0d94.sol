
pragma solidity ^0.4.21;


contract DSAuthority {

    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);

}

contract DSAuthEvents {

    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {

    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() public {

        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {

        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {

        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}


contract DSMath {

    

    function add(uint256 x, uint256 y) constant internal returns (uint256 z) {

        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) constant internal returns (uint256 z) {

        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) constant internal returns (uint256 z) {

        assert((z = x * y) >= x);
    }

    function div(uint256 x, uint256 y) constant internal returns (uint256 z) {

        z = x / y;
    }

    function min(uint256 x, uint256 y) constant internal returns (uint256 z) {

        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) constant internal returns (uint256 z) {

        return x >= y ? x : y;
    }



    function hadd(uint128 x, uint128 y) constant internal returns (uint128 z) {

        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) constant internal returns (uint128 z) {

        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) constant internal returns (uint128 z) {

        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {

        z = x / y;
    }

    function hmin(uint128 x, uint128 y) constant internal returns (uint128 z) {

        return x <= y ? x : y;
    }
    function hmax(uint128 x, uint128 y) constant internal returns (uint128 z) {

        return x >= y ? x : y;
    }



    function imin(int256 x, int256 y) constant internal returns (int256 z) {

        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) constant internal returns (int256 z) {

        return x >= y ? x : y;
    }


    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) constant internal returns (uint128) {

        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) constant internal returns (uint128) {

        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) constant internal returns (uint128 z) {

        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {

        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) constant internal returns (uint128) {

        return hmin(x, y);
    }
    function wmax(uint128 x, uint128 y) constant internal returns (uint128) {

        return hmax(x, y);
    }


    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) constant internal returns (uint128) {

        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) constant internal returns (uint128) {

        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) constant internal returns (uint128 z) {

        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {

        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) constant internal returns (uint128 z) {


        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) constant internal returns (uint128) {

        return hmin(x, y);
    }
    function rmax(uint128 x, uint128 y) constant internal returns (uint128) {

        return hmax(x, y);
    }

    function cast(uint256 x) constant internal returns (uint128 z) {

        assert((z = uint128(x)) == x);
    }

}


contract DSNote {

    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {

        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}


contract DSThing is DSAuth, DSNote, DSMath {

}


contract DSValue is DSThing {

    bool    has;
    bytes32 val;
    function peek() constant returns (bytes32, bool) {

        return (val,has);
    }
    function read() constant returns (bytes32) {

        var (wut, has) = peek();
        assert(has);
        return wut;
    }
    function poke(bytes32 wut) note auth {

        val = wut;
        has = true;
    }
    function void() note auth { // unset the value

        has = false;
    }
}


contract Medianizer is DSValue {

    mapping (bytes12 => address) public values;
    mapping (address => bytes12) public indexes;
    bytes12 public next = 0x1;

    uint96 public min = 0x1;

    function set(address wat) auth {

        bytes12 nextId = bytes12(uint96(next) + 1);
        assert(nextId != 0x0);
        set(next, wat);
        next = nextId;
    }

    function set(bytes12 pos, address wat) note auth {

        if (pos == 0x0) throw;

        if (wat != 0 && indexes[wat] != 0) throw;

        indexes[values[pos]] = 0; // Making sure to remove a possible existing address in that position

        if (wat != 0) {
            indexes[wat] = pos;
        }

        values[pos] = wat;
    }

    function setMin(uint96 min_) note auth {

        if (min_ == 0x0) throw;
        min = min_;
    }

    function setNext(bytes12 next_) note auth {

        if (next_ == 0x0) throw;
        next = next_;
    }

    function unset(bytes12 pos) {

        set(pos, 0);
    }

    function unset(address wat) {

        set(indexes[wat], 0);
    }

    function poke() {

        poke(0);
    }

    function poke(bytes32) note {

        (val, has) = compute();
    }

    function compute() constant returns (bytes32, bool) {

        bytes32[] memory wuts = new bytes32[](uint96(next) - 1);
        uint96 ctr = 0;
        for (uint96 i = 1; i < uint96(next); i++) {
            if (values[bytes12(i)] != 0) {
                var (wut, wuz) = DSValue(values[bytes12(i)]).peek();
                if (wuz) {
                    if (ctr == 0 || wut >= wuts[ctr - 1]) {
                        wuts[ctr] = wut;
                    } else {
                        uint96 j = 0;
                        while (wut >= wuts[j]) {
                            j++;
                        }
                        for (uint96 k = ctr; k > j; k--) {
                            wuts[k] = wuts[k - 1];
                        }
                        wuts[j] = wut;
                    }
                    ctr++;
                }
            }
        }

        if (ctr < min) return (val, false);

        bytes32 value;
        if (ctr % 2 == 0) {
            uint128 val1 = uint128(wuts[(ctr / 2) - 1]);
            uint128 val2 = uint128(wuts[ctr / 2]);
            value = bytes32(wdiv(hadd(val1, val2), 2 ether));
        } else {
            value = wuts[(ctr - 1) / 2];
        }

        return (value, true);
    }
}








contract PriceFeed is DSThing {


    uint128 val;
    uint32 public zzz;

    function peek() public view
        returns (bytes32, bool)
    {

        return (bytes32(val), now < zzz);
    }

    function read() public view
        returns (bytes32)
    {

        assert(now < zzz);
        return bytes32(val);
    }

    function post(uint128 val_, uint32 zzz_, address med_) public note auth
    {

        val = val_;
        zzz = zzz_;
        bool ret = med_.call(bytes4(keccak256("poke()")));
        ret;
    }

    function void() public note auth
    {

        zzz = 0;
    }

}





contract PriceOracleInterface {


    address public priceFeedSource;
    address public owner;
    bool public emergencyMode;

    event NonValidPriceFeed(address priceFeedSource);

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function PriceOracleInterface(
        address _owner,
        address _priceFeedSource
    )
        public
    {

        owner = _owner;
        priceFeedSource = _priceFeedSource;
    }
    function raiseEmergency(bool _emergencyMode)
        public
        onlyOwner()
    {

        emergencyMode = _emergencyMode;
    }

    function updateCurator(
        address _owner
    )
        public
        onlyOwner()
    {

        owner = _owner;
    }

    function getUSDETHPrice() 
        public
        returns (uint256)
    {

        if(emergencyMode){
            return 600;
        }

        bytes32 price;
        bool valid=true;
        (price, valid) = Medianizer(priceFeedSource).peek();
        if (!valid) {
            NonValidPriceFeed(priceFeedSource);
        }
        uint priceUint = uint256(price)/(1 ether);
        if (priceUint == 0) return 1;
        if (priceUint > 1000000) return 1000000; 
        return priceUint;
    }  
}


library Math {


    uint public constant ONE =  0x10000000000000000;
    uint public constant LN2 = 0xb17217f7d1cf79ac;
    uint public constant LOG2_E = 0x171547652b82fe177;

    function exp(int x)
        public
        pure
        returns (uint)
    {

        require(x <= 2454971259878909886679);
        if (x < -818323753292969962227)
            return 0;
        x = x * int(ONE) / int(LN2);
        int shift;
        uint z;
        if (x >= 0) {
            shift = x / int(ONE);
            z = uint(x % int(ONE));
        }
        else {
            shift = x / int(ONE) - 1;
            z = ONE - uint(-x % int(ONE));
        }
        uint zpow = z;
        uint result = ONE;
        result += 0xb17217f7d1cf79ab * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x3d7f7bff058b1d50 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0xe35846b82505fc5 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x276556df749cee5 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x5761ff9e299cc4 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0xa184897c363c3 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0xffe5fe2c4586 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x162c0223a5c8 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1b5253d395e * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1e4cf5158b * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1e8cac735 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1c3bd650 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1816193 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x131496 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0xe1b7 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x9c7 * zpow / ONE;
        if (shift >= 0) {
            if (result >> (256-shift) > 0)
                return (2**256-1);
            return result << shift;
        }
        else
            return result >> (-shift);
    }

    function ln(uint x)
        public
        pure
        returns (int)
    {

        require(x > 0);
        int ilog2 = floorLog2(x);
        int z;
        if (ilog2 < 0)
            z = int(x << uint(-ilog2));
        else
            z = int(x >> uint(ilog2));
        int term = (z - int(ONE)) * int(ONE) / (z + int(ONE));
        int halflnz = term;
        int termpow = term * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 3;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 5;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 7;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 9;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 11;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 13;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 15;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 17;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 19;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 21;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 23;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 25;
        return (ilog2 * int(ONE)) * int(ONE) / int(LOG2_E) + 2 * halflnz;
    }

    function floorLog2(uint x)
        public
        pure
        returns (int lo)
    {

        lo = -64;
        int hi = 193;
        int mid = (hi + lo) >> 1;
        while((lo + 1) < hi) {
            if (mid < 0 && x << uint(-mid) < ONE || mid >= 0 && x >> uint(mid) < ONE)
                hi = mid;
            else
                lo = mid;
            mid = (hi + lo) >> 1;
        }
    }

    function max(int[] nums)
        public
        pure
        returns (int maxNum)
    {

        require(nums.length > 0);
        maxNum = -2**255;
        for (uint i = 0; i < nums.length; i++)
            if (nums[i] > maxNum)
                maxNum = nums[i];
    }

    function safeToAdd(uint a, uint b)
        internal
        pure
        returns (bool)
    {

        return a + b >= a;
    }

    function safeToSub(uint a, uint b)
        internal
        pure
        returns (bool)
    {

        return a >= b;
    }

    function safeToMul(uint a, uint b)
        internal
        pure
        returns (bool)
    {

        return b == 0 || a * b / b == a;
    }

    function add(uint a, uint b)
        internal
        pure
        returns (uint)
    {

        require(safeToAdd(a, b));
        return a + b;
    }

    function sub(uint a, uint b)
        internal
        pure
        returns (uint)
    {

        require(safeToSub(a, b));
        return a - b;
    }

    function mul(uint a, uint b)
        internal
        pure
        returns (uint)
    {

        require(safeToMul(a, b));
        return a * b;
    }

    function safeToAdd(int a, int b)
        internal
        pure
        returns (bool)
    {

        return (b >= 0 && a + b >= a) || (b < 0 && a + b < a);
    }

    function safeToSub(int a, int b)
        internal
        pure
        returns (bool)
    {

        return (b >= 0 && a - b <= a) || (b < 0 && a - b > a);
    }

    function safeToMul(int a, int b)
        internal
        pure
        returns (bool)
    {

        return (b == 0) || (a * b / b == a);
    }

    function add(int a, int b)
        internal
        pure
        returns (int)
    {

        require(safeToAdd(a, b));
        return a + b;
    }

    function sub(int a, int b)
        internal
        pure
        returns (int)
    {

        require(safeToSub(a, b));
        return a - b;
    }

    function mul(int a, int b)
        internal
        pure
        returns (int)
    {

        require(safeToMul(a, b));
        return a * b;
    }
}


contract Proxied {

    address public masterCopy;
}

contract Proxy is Proxied {

    function Proxy(address _masterCopy)
        public
    {

        require(_masterCopy != 0);
        masterCopy = _masterCopy;
    }

    function ()
        external
        payable
    {
        address _masterCopy = masterCopy;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}


pragma solidity ^0.4.21;


contract Token {


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function transfer(address to, uint value) public returns (bool);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    function balanceOf(address owner) public view returns (uint);

    function allowance(address owner, address spender) public view returns (uint);

    function totalSupply() public view returns (uint);

}


contract StandardTokenData {


    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;
    uint totalTokens;
}

contract StandardToken is Token, StandardTokenData {

    using Math for *;

    function transfer(address to, uint value)
        public
        returns (bool)
    {

        if (   !balances[msg.sender].safeToSub(value)
            || !balances[to].safeToAdd(value))
            return false;
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value)
        public
        returns (bool)
    {

        if (   !balances[from].safeToSub(value)
            || !allowances[from][msg.sender].safeToSub(value)
            || !balances[to].safeToAdd(value))
            return false;
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value)
        public
        returns (bool)
    {

        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint)
    {

        return allowances[owner][spender];
    }

    function balanceOf(address owner)
        public
        view
        returns (uint)
    {

        return balances[owner];
    }

    function totalSupply()
        public
        view
        returns (uint)
    {

        return totalTokens;
    }
}


contract TokenFRT is StandardToken {

    string public constant symbol = "MGN";
    string public constant name = "Magnolia Token";
    uint8 public constant decimals = 18;

    struct unlockedToken {
        uint amountUnlocked;
        uint withdrawalTime;
    }


    address public owner;
    address public minter;

    mapping (address => unlockedToken) public unlockedTokens;

    mapping (address => uint) public lockedTokenBalances;


    function TokenFRT(
        address _owner
    )
        public
    {

        require(_owner != address(0));
        owner = _owner;
    }

    function updateMinter(
        address _minter
    )
        public
    {

        require(msg.sender == owner);
        require(_minter != address(0));

        minter = _minter;
    }

    function updateOwner(   
        address _owner
    )
        public
    {

        require(msg.sender == owner);
        require(_owner != address(0));
        owner = _owner;
    }

    function mintTokens(
        address user,
        uint amount
    )
        public
    {

        require(msg.sender == minter);

        lockedTokenBalances[user] = add(lockedTokenBalances[user], amount);
        totalTokens = add(totalTokens, amount);
    }

    function lockTokens(
        uint amount
    )
        public
        returns (uint totalAmountLocked)
    {

        amount = min(amount, balances[msg.sender]);
        
        balances[msg.sender] = sub(balances[msg.sender], amount);
        lockedTokenBalances[msg.sender] = add(lockedTokenBalances[msg.sender], amount);

        totalAmountLocked = lockedTokenBalances[msg.sender];
    }

    function unlockTokens(
        uint amount
    )
        public
        returns (uint totalAmountUnlocked, uint withdrawalTime)
    {

        amount = min(amount, lockedTokenBalances[msg.sender]);

        if (amount > 0) {
            lockedTokenBalances[msg.sender] = sub(lockedTokenBalances[msg.sender], amount);
            unlockedTokens[msg.sender].amountUnlocked =  add(unlockedTokens[msg.sender].amountUnlocked, amount);
            unlockedTokens[msg.sender].withdrawalTime = now + 24 hours;
        }

        totalAmountUnlocked = unlockedTokens[msg.sender].amountUnlocked;
        withdrawalTime = unlockedTokens[msg.sender].withdrawalTime;
    }

    function withdrawUnlockedTokens()
        public
    {

        require(unlockedTokens[msg.sender].withdrawalTime < now);
        balances[msg.sender] = add(balances[msg.sender], unlockedTokens[msg.sender].amountUnlocked);
        unlockedTokens[msg.sender].amountUnlocked = 0;
    }

    function min(uint a, uint b) 
        public
        pure
        returns (uint)
    {

        if (a < b) {
            return a;
        } else {
            return b;
        }
    }
    function safeToAdd(uint a, uint b)
        public
        constant
        returns (bool)
    {

        return a + b >= a;
    }

    function safeToSub(uint a, uint b)
        public
        constant
        returns (bool)
    {

        return a >= b;
    }


    function add(uint a, uint b)
        public
        constant
        returns (uint)
    {

        require(safeToAdd(a, b));
        return a + b;
    }

    function sub(uint a, uint b)
        public
        constant
        returns (uint)
    {

        require(safeToSub(a, b));
        return a - b;
    }
}


contract TokenOWL is Proxied, StandardToken {

    using Math for *;

    string public constant name = "OWL Token";
    string public constant symbol = "OWL";
    uint8 public constant decimals = 18;

    struct masterCopyCountdownType {
        address masterCopy;
        uint timeWhenAvailable;
    }

    masterCopyCountdownType masterCopyCountdown;

    address public creator;
    address public minter;

    event Minted(address indexed to, uint256 amount);
    event Burnt(address indexed from, address indexed user, uint256 amount);

    modifier onlyCreator() {

        require(msg.sender == creator);
        _;
    }
    function startMasterCopyCountdown (
        address _masterCopy
     )
        public
        onlyCreator()
    {
        require(address(_masterCopy) != 0);

        masterCopyCountdown.masterCopy = _masterCopy;
        masterCopyCountdown.timeWhenAvailable = now + 30 days;
    }

    function updateMasterCopy()
        public
        onlyCreator()
    {   

        require(address(masterCopyCountdown.masterCopy) != 0);
        require(now >= masterCopyCountdown.timeWhenAvailable);

        masterCopy = masterCopyCountdown.masterCopy;
    }

    function getMasterCopy()
        public
        view
        returns (address)
    {

        return masterCopy;
    }

    function setMinter(address newMinter)
        public
        onlyCreator()
    {

        minter = newMinter;
    }


    function setNewOwner(address newOwner)
        public
        onlyCreator()
    {

        creator = newOwner;
    }

    function mintOWL(address to, uint amount)
        public
    {

        require(minter != 0 && msg.sender == minter);
        balances[to] = balances[to].add(amount);
        totalTokens = totalTokens.add(amount);
        emit Minted(to, amount);
    }

    function burnOWL(address user, uint amount)
        public
    {

        allowances[user][msg.sender] = allowances[user][msg.sender].sub(amount);
        balances[user] = balances[user].sub(amount);
        totalTokens = totalTokens.sub(amount);
        emit Burnt(msg.sender, user, amount);
    }
}



contract DutchExchange is Proxied {


    struct fraction {
        uint num;
        uint den;
    }

    uint constant WAITING_PERIOD_NEW_TOKEN_PAIR = 6 hours;
    uint constant WAITING_PERIOD_NEW_AUCTION = 10 minutes;
    uint constant WAITING_PERIOD_CHANGE_MASTERCOPY_OR_ORACLE = 30 days;
    uint constant AUCTION_START_WAITING_FOR_FUNDING = 1;

    address public newMasterCopy;
    uint public masterCopyCountdown;

    address public auctioneer;
    address public ethToken;
    PriceOracleInterface public ethUSDOracle;
    PriceOracleInterface public newProposalEthUSDOracle;
    uint public oracleInterfaceCountdown;
    uint public thresholdNewTokenPair;
    uint public thresholdNewAuction;
    TokenFRT public frtToken;
    TokenOWL public owlToken;

    mapping (address => bool) public approvedTokens;

    mapping (address => mapping (address => uint)) public latestAuctionIndices;
    mapping (address => mapping (address => uint)) public auctionStarts;

    mapping (address => mapping (address => mapping (uint => fraction))) public closingPrices;

    mapping (address => mapping (address => uint)) public sellVolumesCurrent;
    mapping (address => mapping (address => uint)) public sellVolumesNext;
    mapping (address => mapping (address => uint)) public buyVolumes;

    mapping (address => mapping (address => uint)) public balances;

    mapping (address => mapping (address => mapping (uint => uint))) public extraTokens;

    mapping (address => mapping (address => mapping (uint => mapping (address => uint)))) public sellerBalances;
    mapping (address => mapping (address => mapping (uint => mapping (address => uint)))) public buyerBalances;
    mapping (address => mapping (address => mapping (uint => mapping (address => uint)))) public claimedAmounts;

    modifier onlyAuctioneer() {

        require(msg.sender == auctioneer);
        _;
    }

    function setupDutchExchange(
        TokenFRT _frtToken,
        TokenOWL _owlToken,
        address _auctioneer, 
        address _ethToken,
        PriceOracleInterface _ethUSDOracle,
        uint _thresholdNewTokenPair,
        uint _thresholdNewAuction
    )
        public
    {

        require(ethToken == 0);

        require(address(_owlToken) != address(0));
        require(address(_frtToken) != address(0));
        require(_auctioneer != 0);
        require(_ethToken != 0);
        require(address(_ethUSDOracle) != address(0));

        frtToken = _frtToken;
        owlToken = _owlToken;
        auctioneer = _auctioneer;
        ethToken = _ethToken;
        ethUSDOracle = _ethUSDOracle;
        thresholdNewTokenPair = _thresholdNewTokenPair;
        thresholdNewAuction = _thresholdNewAuction;
    }

    function updateAuctioneer(
        address _auctioneer
    )
        public
        onlyAuctioneer
    {

        require(_auctioneer != address(0));
        auctioneer = _auctioneer;
    }

    function initiateEthUsdOracleUpdate(
        PriceOracleInterface _ethUSDOracle
    )
        public
        onlyAuctioneer
    {         

        require(address(_ethUSDOracle) != address(0));
        newProposalEthUSDOracle = _ethUSDOracle;
        oracleInterfaceCountdown = add(now, WAITING_PERIOD_CHANGE_MASTERCOPY_OR_ORACLE);
        NewOracleProposal(_ethUSDOracle);
    }

    function updateEthUSDOracle()
        public
        onlyAuctioneer
    {

        require(address(newProposalEthUSDOracle) != address(0));
        require(oracleInterfaceCountdown < now);
        ethUSDOracle = newProposalEthUSDOracle;
        newProposalEthUSDOracle = PriceOracleInterface(0);
    }

    function updateThresholdNewTokenPair(
        uint _thresholdNewTokenPair
    )
        public
        onlyAuctioneer
    {

        thresholdNewTokenPair = _thresholdNewTokenPair;
    }

    function updateThresholdNewAuction(
        uint _thresholdNewAuction
    )
        public
        onlyAuctioneer
    {

        thresholdNewAuction = _thresholdNewAuction;
    }

    function updateApprovalOfToken(
        address[] token,
        bool approved
    )
        public
        onlyAuctioneer
     {  

        for(uint i = 0; i < token.length; i++) {
            approvedTokens[token[i]] = approved;
            Approval(token[i], approved);
        }
     }

     function startMasterCopyCountdown (
        address _masterCopy
     )
        public
        onlyAuctioneer
    {
        require(_masterCopy != address(0));

        newMasterCopy = _masterCopy;
        masterCopyCountdown = add(now, WAITING_PERIOD_CHANGE_MASTERCOPY_OR_ORACLE);
        NewMasterCopyProposal(_masterCopy);
    }

    function updateMasterCopy()
        public
        onlyAuctioneer
    {

        require(newMasterCopy != address(0));
        require(now >= masterCopyCountdown);

        masterCopy = newMasterCopy;
        newMasterCopy = address(0);
    }

    function addTokenPair(
        address token1,
        address token2,
        uint token1Funding,
        uint token2Funding,
        uint initialClosingPriceNum,
        uint initialClosingPriceDen 
    )
        public
    {

        require(token1 != token2);

        require(initialClosingPriceNum != 0);

        require(initialClosingPriceDen != 0);

        require(getAuctionIndex(token1, token2) == 0);

        require(initialClosingPriceNum < 10 ** 18);

        require(initialClosingPriceDen < 10 ** 18);

        setAuctionIndex(token1, token2);

        token1Funding = min(token1Funding, balances[token1][msg.sender]);
        token2Funding = min(token2Funding, balances[token2][msg.sender]);

        require(token1Funding < 10 ** 30);

        require(token2Funding < 10 ** 30);

        uint fundedValueUSD;
        uint ethUSDPrice = ethUSDOracle.getUSDETHPrice();

        address ethTokenMem = ethToken;
        if (token1 == ethTokenMem) {
            fundedValueUSD = mul(token1Funding, ethUSDPrice);
        } else if (token2 == ethTokenMem) {
            fundedValueUSD = mul(token2Funding, ethUSDPrice);
        } else {
            fundedValueUSD = calculateFundedValueTokenToken(token1, token2, 
                token1Funding, token2Funding, ethTokenMem, ethUSDPrice);
        }

        require(fundedValueUSD >= thresholdNewTokenPair);

        closingPrices[token1][token2][0] = fraction(initialClosingPriceNum, initialClosingPriceDen);
        closingPrices[token2][token1][0] = fraction(initialClosingPriceDen, initialClosingPriceNum);

        addTokenPairSecondPart(token1, token2, token1Funding, token2Funding);
    }

    function calculateFundedValueTokenToken(
        address token1,
        address token2,
        uint token1Funding,
        uint token2Funding,
        address ethTokenMem,
        uint ethUSDPrice
    )
        internal
        view
        returns (uint fundedValueUSD)
    {

        require(getAuctionIndex(token1, ethTokenMem) > 0);

        require(getAuctionIndex(token2, ethTokenMem) > 0);

        uint priceToken1Num;
        uint priceToken1Den;
        (priceToken1Num, priceToken1Den) = getPriceOfTokenInLastAuction(token1);

        uint priceToken2Num;
        uint priceToken2Den;
        (priceToken2Num, priceToken2Den) = getPriceOfTokenInLastAuction(token2);

        uint fundedValueETH = add(mul(token1Funding, priceToken1Num) / priceToken1Den,
            token2Funding * priceToken2Num / priceToken2Den);

        fundedValueUSD = mul(fundedValueETH, ethUSDPrice);
    }

    function addTokenPairSecondPart(
        address token1,
        address token2,
        uint token1Funding,
        uint token2Funding
    )
        internal
    {

        balances[token1][msg.sender] = sub(balances[token1][msg.sender], token1Funding);
        balances[token2][msg.sender] = sub(balances[token2][msg.sender], token2Funding);

        uint token1FundingAfterFee = settleFee(token1, token2, 1, token1Funding);
        uint token2FundingAfterFee = settleFee(token2, token1, 1, token2Funding);

        sellVolumesCurrent[token1][token2] = token1FundingAfterFee;
        sellVolumesCurrent[token2][token1] = token2FundingAfterFee;
        sellerBalances[token1][token2][1][msg.sender] = token1FundingAfterFee;
        sellerBalances[token2][token1][1][msg.sender] = token2FundingAfterFee;
        
        setAuctionStart(token1, token2, WAITING_PERIOD_NEW_TOKEN_PAIR);
        NewTokenPair(token1, token2);
    }

    function deposit(
        address tokenAddress,
        uint amount
    )
        public
        returns (uint)
    {

        require(Token(tokenAddress).transferFrom(msg.sender, this, amount));

        uint newBal = add(balances[tokenAddress][msg.sender], amount);

        balances[tokenAddress][msg.sender] = newBal;

        NewDeposit(tokenAddress, amount);

        return newBal;
    }

    function withdraw(
        address tokenAddress,
        uint amount
    )
        public
        returns (uint)
    {

        uint usersBalance = balances[tokenAddress][msg.sender];
        amount = min(amount, usersBalance);

        require(amount > 0);

        require(Token(tokenAddress).transfer(msg.sender, amount));

        uint newBal = sub(usersBalance, amount);
        balances[tokenAddress][msg.sender] = newBal;

        NewWithdrawal(tokenAddress, amount);

        return newBal;
    }

    function postSellOrder(
        address sellToken,
        address buyToken,
        uint auctionIndex,
        uint amount
    )
        public
        returns (uint, uint)
    {


        amount = min(amount, balances[sellToken][msg.sender]);

        require(amount > 0);
        
        uint latestAuctionIndex = getAuctionIndex(sellToken, buyToken);
        require(latestAuctionIndex > 0);
      
        uint auctionStart = getAuctionStart(sellToken, buyToken);
        if (auctionStart == AUCTION_START_WAITING_FOR_FUNDING || auctionStart > now) {
            if (auctionIndex == 0) {
                auctionIndex = latestAuctionIndex;
            } else {
                require(auctionIndex == latestAuctionIndex);
            }

            require(add(sellVolumesCurrent[sellToken][buyToken], amount) < 10 ** 30);
        } else {
            if (auctionIndex == 0) {
                auctionIndex = latestAuctionIndex + 1;
            } else {
                require(auctionIndex == latestAuctionIndex + 1);
            }

            require(add(sellVolumesNext[sellToken][buyToken], amount) < 10 ** 30);
        }

        uint amountAfterFee = settleFee(sellToken, buyToken, auctionIndex, amount);

        balances[sellToken][msg.sender] = sub(balances[sellToken][msg.sender], amount);
        uint newSellerBal = add(sellerBalances[sellToken][buyToken][auctionIndex][msg.sender], amountAfterFee);
        sellerBalances[sellToken][buyToken][auctionIndex][msg.sender] = newSellerBal;

        if (auctionStart == AUCTION_START_WAITING_FOR_FUNDING || auctionStart > now) {
            uint sellVolumeCurrent = sellVolumesCurrent[sellToken][buyToken];
            sellVolumesCurrent[sellToken][buyToken] = add(sellVolumeCurrent, amountAfterFee);
        } else {
            uint sellVolumeNext = sellVolumesNext[sellToken][buyToken];
            sellVolumesNext[sellToken][buyToken] = add(sellVolumeNext, amountAfterFee);
        }

        if (auctionStart == AUCTION_START_WAITING_FOR_FUNDING) {
            scheduleNextAuction(sellToken, buyToken);
        }

        NewSellOrder(sellToken, buyToken, msg.sender, auctionIndex, amountAfterFee);

        return (auctionIndex, newSellerBal);
    }

    function postBuyOrder(
        address sellToken,
        address buyToken,
        uint auctionIndex,
        uint amount
    )
        public
        returns (uint)
    {

        require(closingPrices[sellToken][buyToken][auctionIndex].den == 0);

        uint auctionStart = getAuctionStart(sellToken, buyToken);

        require(auctionStart <= now);

        require(auctionIndex == getAuctionIndex(sellToken, buyToken));
        
        require(auctionStart > AUCTION_START_WAITING_FOR_FUNDING);
        
        require(sellVolumesCurrent[sellToken][buyToken] > 0);
        
        uint buyVolume = buyVolumes[sellToken][buyToken];
        amount = min(amount, balances[buyToken][msg.sender]);

        require(add(buyVolume, amount) < 10 ** 30);
        
        uint sellVolume = sellVolumesCurrent[sellToken][buyToken];

        uint num;
        uint den;
        (num, den) = getCurrentAuctionPrice(sellToken, buyToken, auctionIndex);
        uint outstandingVolume = atleastZero(int(mul(sellVolume, num) / den - buyVolume));

        uint amountAfterFee;
        if (amount < outstandingVolume) {
            if (amount > 0) {
                amountAfterFee = settleFee(buyToken, sellToken, auctionIndex, amount);
            }
        } else {
            amount = outstandingVolume;
            amountAfterFee = outstandingVolume;
        }

        if (amount > 0) {
            balances[buyToken][msg.sender] = sub(balances[buyToken][msg.sender], amount);
            uint newBuyerBal = add(buyerBalances[sellToken][buyToken][auctionIndex][msg.sender], amountAfterFee);
            buyerBalances[sellToken][buyToken][auctionIndex][msg.sender] = newBuyerBal;
            buyVolumes[sellToken][buyToken] = add(buyVolumes[sellToken][buyToken], amountAfterFee);
            NewBuyOrder(sellToken, buyToken, msg.sender, auctionIndex, amountAfterFee);
        }

        if (amount >= outstandingVolume) {
            clearAuction(sellToken, buyToken, auctionIndex, sellVolume);
        }

        return (newBuyerBal);
    }
    
    function claimSellerFunds(
        address sellToken,
        address buyToken,
        address user,
        uint auctionIndex
    )
        public
        returns (uint returned, uint frtsIssued)
    {

        closeTheoreticalClosedAuction(sellToken, buyToken, auctionIndex);
        uint sellerBalance = sellerBalances[sellToken][buyToken][auctionIndex][user];

        require(sellerBalance > 0);

        fraction memory closingPrice = closingPrices[sellToken][buyToken][auctionIndex];
        uint num = closingPrice.num;
        uint den = closingPrice.den;

        require(den > 0);

        returned = mul(sellerBalance, num) / den;

        frtsIssued = issueFrts(sellToken, buyToken, returned, auctionIndex, sellerBalance, user);

        sellerBalances[sellToken][buyToken][auctionIndex][user] = 0;
        if (returned > 0) {
            balances[buyToken][user] = add(balances[buyToken][user], returned);
        }
        NewSellerFundsClaim(sellToken, buyToken, user, auctionIndex, returned, frtsIssued);
    }

    function claimBuyerFunds(
        address sellToken,
        address buyToken,
        address user,
        uint auctionIndex
    )
        public
        returns (uint returned, uint frtsIssued)
    {

        closeTheoreticalClosedAuction(sellToken, buyToken, auctionIndex);
        
        uint num;
        uint den;
        (returned, num, den) = getUnclaimedBuyerFunds(sellToken, buyToken, user, auctionIndex);

        if (closingPrices[sellToken][buyToken][auctionIndex].den == 0) {
            claimedAmounts[sellToken][buyToken][auctionIndex][user] = add(claimedAmounts[sellToken][buyToken][auctionIndex][user], returned);
        } else {

            uint extraTokensTotal = extraTokens[sellToken][buyToken][auctionIndex];
            uint buyerBalance = buyerBalances[sellToken][buyToken][auctionIndex][user];

            uint tokensExtra = mul(buyerBalance, extraTokensTotal) / closingPrices[sellToken][buyToken][auctionIndex].num;
            returned = add(returned, tokensExtra);

            frtsIssued = issueFrts(buyToken, sellToken, mul(buyerBalance, den) / num, auctionIndex, buyerBalance, user);

            buyerBalances[sellToken][buyToken][auctionIndex][user] = 0;
            claimedAmounts[sellToken][buyToken][auctionIndex][user] = 0; 
        }

        if (returned > 0) {
            balances[sellToken][user] = add(balances[sellToken][user], returned);
        }
        
        NewBuyerFundsClaim(sellToken, buyToken, user, auctionIndex, returned, frtsIssued);
    }

    function issueFrts(
        address primaryToken,
        address secondaryToken,
        uint x,
        uint auctionIndex,
        uint bal,
        address user
    )
        internal
        returns (uint frtsIssued)
    {

        if (approvedTokens[primaryToken] && approvedTokens[secondaryToken]) {
            address ethTokenMem = ethToken;
            if (primaryToken == ethTokenMem) {
                frtsIssued = bal;
            } else if (secondaryToken == ethTokenMem) {
                frtsIssued = x;
            } else {
                uint pastNum;
                uint pastDen;
                (pastNum, pastDen) = getPriceInPastAuction(primaryToken, ethTokenMem, auctionIndex - 1);
                frtsIssued = mul(bal, pastNum) / pastDen;
            }

            if (frtsIssued > 0) {
                frtToken.mintTokens(user, frtsIssued);
            }
        }
    }

    function closeTheoreticalClosedAuction(
        address sellToken,
        address buyToken,
        uint auctionIndex
    )
        public
    {

        if(auctionIndex == getAuctionIndex(buyToken, sellToken) && closingPrices[sellToken][buyToken][auctionIndex].num == 0) {
            uint buyVolume = buyVolumes[sellToken][buyToken];
            uint sellVolume = sellVolumesCurrent[sellToken][buyToken];
            uint num;
            uint den;
            (num, den) = getCurrentAuctionPrice(sellToken, buyToken, auctionIndex);
            uint outstandingVolume = atleastZero(int(mul(sellVolume, num) / den - buyVolume));
            
            if(outstandingVolume == 0) {
                postBuyOrder(sellToken, buyToken, auctionIndex, 0);
            }
        }
    }

    function getUnclaimedBuyerFunds(
        address sellToken,
        address buyToken,
        address user,
        uint auctionIndex
    )
        public
        view
        returns (uint unclaimedBuyerFunds, uint num, uint den)
    {

        require(auctionIndex <= getAuctionIndex(sellToken, buyToken));

        (num, den) = getCurrentAuctionPrice(sellToken, buyToken, auctionIndex);

        if (num == 0) {
            unclaimedBuyerFunds = 0;
        } else {
            uint buyerBalance = buyerBalances[sellToken][buyToken][auctionIndex][user];
            unclaimedBuyerFunds = atleastZero(int(
                mul(buyerBalance, den) / num - 
                claimedAmounts[sellToken][buyToken][auctionIndex][user]
            ));
        }
    }

    function settleFee(
        address primaryToken,
        address secondaryToken,
        uint auctionIndex,
        uint amount
    )
        internal
        returns (uint amountAfterFee)
    {

        uint feeNum;
        uint feeDen;
        (feeNum, feeDen) = getFeeRatio(msg.sender);
        uint fee = mul(amount, feeNum) / feeDen;

        if (fee > 0) {
            fee = settleFeeSecondPart(primaryToken, fee);
            
            uint usersExtraTokens = extraTokens[primaryToken][secondaryToken][auctionIndex + 1];
            extraTokens[primaryToken][secondaryToken][auctionIndex + 1] = add(usersExtraTokens, fee);

            Fee(primaryToken, secondaryToken, msg.sender, auctionIndex, fee);
        }
        
        amountAfterFee = sub(amount, fee);
    }

    function settleFeeSecondPart(
        address primaryToken,
        uint fee
    )
        internal
        returns (uint newFee)
    {

        uint num;
        uint den;
        (num, den) = getPriceOfTokenInLastAuction(primaryToken);

        uint feeInETH = mul(fee, num) / den;

        uint ethUSDPrice = ethUSDOracle.getUSDETHPrice();
        uint feeInUSD = mul(feeInETH, ethUSDPrice);
        uint amountOfowlTokenBurned = min(owlToken.allowance(msg.sender, this), feeInUSD / 2);
        amountOfowlTokenBurned = min(owlToken.balanceOf(msg.sender), amountOfowlTokenBurned);


        if (amountOfowlTokenBurned > 0) {
            owlToken.burnOWL(msg.sender, amountOfowlTokenBurned);
            uint adjustment = mul(amountOfowlTokenBurned, fee) / feeInUSD;
            newFee = sub(fee, adjustment);
        } else {
            newFee = fee;
        }
    }
    
    function getFeeRatio(
        address user
    )
        public
        view
        returns (uint num, uint den)
    {

        uint t = frtToken.totalSupply();
        uint b = frtToken.lockedTokenBalances(user);

        if (b * 100000 < t || t == 0) {
            num = 1;
            den = 200;
        } else if (b * 10000 < t) {
            num = 1;
            den = 250;
        } else if (b * 1000 < t) {
            num = 3;
            den = 1000;
        } else if (b * 100 < t) {
            num = 1;
            den = 500;
        } else if (b * 10 < t) {
            num = 1;
            den = 1000;
        } else {
            num = 0; 
            den = 1;
        }
    }

    function clearAuction(
        address sellToken,
        address buyToken,
        uint auctionIndex,
        uint sellVolume
    )
        internal
    {

        uint buyVolume = buyVolumes[sellToken][buyToken];
        uint sellVolumeOpp = sellVolumesCurrent[buyToken][sellToken];
        uint closingPriceOppDen = closingPrices[buyToken][sellToken][auctionIndex].den;
        uint auctionStart = getAuctionStart(sellToken, buyToken);

        if (sellVolume > 0) {
            closingPrices[sellToken][buyToken][auctionIndex] = fraction(buyVolume, sellVolume);
        }

        if (sellVolumeOpp == 0 || now >= auctionStart + 86400 || closingPriceOppDen > 0) {
            uint buyVolumeOpp = buyVolumes[buyToken][sellToken];
            if (closingPriceOppDen == 0 && sellVolumeOpp > 0) {
                closingPrices[buyToken][sellToken][auctionIndex] = fraction(buyVolumeOpp, sellVolumeOpp);
            }

            uint sellVolumeNext = sellVolumesNext[sellToken][buyToken];
            uint sellVolumeNextOpp = sellVolumesNext[buyToken][sellToken];

            sellVolumesCurrent[sellToken][buyToken] = sellVolumeNext;
            if (sellVolumeNext > 0) {
                sellVolumesNext[sellToken][buyToken] = 0;
            }
            if (buyVolume > 0) {
                buyVolumes[sellToken][buyToken] = 0;
            }

            sellVolumesCurrent[buyToken][sellToken] = sellVolumeNextOpp;
            if (sellVolumeNextOpp > 0) {
                sellVolumesNext[buyToken][sellToken] = 0;
            }
            if (buyVolumeOpp > 0) {
                buyVolumes[buyToken][sellToken] = 0;
            }

            setAuctionIndex(sellToken, buyToken);
            scheduleNextAuction(sellToken, buyToken);
        }

        AuctionCleared(sellToken, buyToken, sellVolume, buyVolume, auctionIndex);
    }

    function scheduleNextAuction(
        address sellToken,
        address buyToken
    )
        internal
    {

        uint ethUSDPrice = ethUSDOracle.getUSDETHPrice();

        uint sellNum;
        uint sellDen;
        (sellNum, sellDen) = getPriceOfTokenInLastAuction(sellToken);

        uint buyNum;
        uint buyDen;
        (buyNum, buyDen) = getPriceOfTokenInLastAuction(buyToken);


        uint sellVolume = mul(mul(sellVolumesCurrent[sellToken][buyToken], sellNum), ethUSDPrice) / sellDen;
        uint sellVolumeOpp = mul(mul(sellVolumesCurrent[buyToken][sellToken], buyNum), ethUSDPrice) / buyDen;
        if (sellVolume >= thresholdNewAuction || sellVolumeOpp >= thresholdNewAuction) {
            setAuctionStart(sellToken, buyToken, WAITING_PERIOD_NEW_AUCTION);
        } else {
            resetAuctionStart(sellToken, buyToken);
        }
    }

    function getPriceInPastAuction(
        address token1,
        address token2,
        uint auctionIndex
    )
        public
        view
        returns (uint num, uint den)
    {

        if (token1 == token2) {
            num = 1;
            den = 1;
        } else {
            require(auctionIndex >= 0);


            require(auctionIndex <= getAuctionIndex(token1, token2));

            uint i = 0;
            bool correctPair = false;
            fraction memory closingPriceToken1;
            fraction memory closingPriceToken2;

            while (!correctPair) {
                closingPriceToken2 = closingPrices[token2][token1][auctionIndex - i];
                closingPriceToken1 = closingPrices[token1][token2][auctionIndex - i];
                
                if (closingPriceToken1.num > 0 && closingPriceToken1.den > 0 || 
                    closingPriceToken2.num > 0 && closingPriceToken2.den > 0)
                {
                    correctPair = true;
                }
                i++;
            }

            if (closingPriceToken1.num == 0 || closingPriceToken1.den == 0) {
                num = closingPriceToken2.den;
                den = closingPriceToken2.num;
            } else if (closingPriceToken2.num == 0 || closingPriceToken2.den == 0) {
                num = closingPriceToken1.num;
                den = closingPriceToken1.den;
            } else {
                num = closingPriceToken2.den + closingPriceToken1.num;
                den = closingPriceToken2.num + closingPriceToken1.den;
            }
        } 
    }

    function getPriceOfTokenInLastAuction(
        address token
    )
        public
        view
        returns (uint num, uint den)
    {

        uint latestAuctionIndex = getAuctionIndex(token, ethToken);
        (num, den) = getPriceInPastAuction(token, ethToken, latestAuctionIndex - 1);
    }

    function getCurrentAuctionPrice(
        address sellToken,
        address buyToken,
        uint auctionIndex
    )
        public
        view
        returns (uint num, uint den)
    {

        fraction memory closingPrice = closingPrices[sellToken][buyToken][auctionIndex];

        if (closingPrice.den != 0) {
            (num, den) = (closingPrice.num, closingPrice.den);
        } else if (auctionIndex > getAuctionIndex(sellToken, buyToken)) {
            (num, den) = (0, 0);
        } else {
            uint pastNum;
            uint pastDen;
            (pastNum, pastDen) = getPriceInPastAuction(sellToken, buyToken, auctionIndex - 1);

            uint timeElapsed = atleastZero(int(now - getAuctionStart(sellToken, buyToken)));


            num = atleastZero(int((86400 - timeElapsed) * pastNum));
            den = mul((timeElapsed + 43200), pastDen);

            if (mul(num, sellVolumesCurrent[sellToken][buyToken]) <= mul(den, buyVolumes[sellToken][buyToken])) {
                num = buyVolumes[sellToken][buyToken];
                den = sellVolumesCurrent[sellToken][buyToken];
            }
        }
    }

    function depositAndSell(
        address sellToken,
        address buyToken,
        uint amount
    )
        external
        returns (uint newBal, uint auctionIndex, uint newSellerBal)
    {

        newBal = deposit(sellToken, amount);
        (auctionIndex, newSellerBal) = postSellOrder(sellToken, buyToken, 0, amount);
    }

    function claimAndWithdraw(
        address sellToken,
        address buyToken,
        address user,
        uint auctionIndex,
        uint amount
    )
        external
        returns (uint returned, uint frtsIssued, uint newBal)
    {

        (returned, frtsIssued) = claimSellerFunds(sellToken, buyToken, user, auctionIndex);
        newBal = withdraw(buyToken, amount);
    }

    function getTokenOrder(
        address token1,
        address token2
    )
        public
        pure
        returns (address, address)
    {

        if (token2 < token1) {
            (token1, token2) = (token2, token1);
        }

        return (token1, token2);
    }

    function setAuctionStart(
        address token1,
        address token2,
        uint value
    )
        internal
    {

        (token1, token2) = getTokenOrder(token1, token2);        
        uint auctionStart = now + value;
        uint auctionIndex = latestAuctionIndices[token1][token2];
        auctionStarts[token1][token2] = auctionStart;
        AuctionStartScheduled(token1, token2, auctionIndex, auctionStart);
    }

    function resetAuctionStart(
        address token1,
        address token2
    )
        internal
    {

        (token1, token2) = getTokenOrder(token1, token2);
        if (auctionStarts[token1][token2] != AUCTION_START_WAITING_FOR_FUNDING) {
            auctionStarts[token1][token2] = AUCTION_START_WAITING_FOR_FUNDING;
        }
    }

    function getAuctionStart(
        address token1,
        address token2
    )
        public
        view
        returns (uint auctionStart)
    {

        (token1, token2) = getTokenOrder(token1, token2);
        auctionStart = auctionStarts[token1][token2];
    }

    function setAuctionIndex(
        address token1,
        address token2
    )
        internal
    {

        (token1, token2) = getTokenOrder(token1, token2);
        latestAuctionIndices[token1][token2] += 1;
    }


    function getAuctionIndex(
        address token1,
        address token2
    )
        public
        view
        returns (uint auctionIndex) 
    {

        (token1, token2) = getTokenOrder(token1, token2);
        auctionIndex = latestAuctionIndices[token1][token2];
    }

    function min(uint a, uint b) 
        public
        pure
        returns (uint)
    {

        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function atleastZero(int a)
        public
        pure
        returns (uint)
    {

        if (a < 0) {
            return 0;
        } else {
            return uint(a);
        }
    }
    function safeToAdd(uint a, uint b)
        public
        pure
        returns (bool)
    {

        return a + b >= a;
    }

    function safeToSub(uint a, uint b)
        public
        pure
        returns (bool)
    {

        return a >= b;
    }

    function safeToMul(uint a, uint b)
        public
        pure
        returns (bool)
    {

        return b == 0 || a * b / b == a;
    }

    function add(uint a, uint b)
        public
        pure
        returns (uint)
    {

        require(safeToAdd(a, b));
        return a + b;
    }

    function sub(uint a, uint b)
        public
        pure
        returns (uint)
    {

        require(safeToSub(a, b));
        return a - b;
    }

    function mul(uint a, uint b)
        public
        pure
        returns (uint)
    {

        require(safeToMul(a, b));
        return a * b;
    }

    function getRunningTokenPairs(
        address[] tokens
    )
        external
        view
        returns (address[] tokens1, address[] tokens2)
    {

        uint arrayLength;

        for (uint k = 0; k < tokens.length - 1; k++) {
            for (uint l = k + 1; l < tokens.length; l++) {
                if (getAuctionIndex(tokens[k], tokens[l]) > 0) {
                    arrayLength++;
                }
            }
        }

        tokens1 = new address[](arrayLength);
        tokens2 = new address[](arrayLength);

        uint h;

        for (uint i = 0; i < tokens.length - 1; i++) {
            for (uint j = i + 1; j < tokens.length; j++) {
                if (getAuctionIndex(tokens[i], tokens[j]) > 0) {
                    tokens1[h] = tokens[i];
                    tokens2[h] = tokens[j];
                    h++;
                }
            }
        }
    }
    
    function getIndicesWithClaimableTokensForSellers(
        address auctionSellToken,
        address auctionBuyToken,
        address user,
        uint lastNAuctions
    )
        external
        view
        returns(uint[] indices, uint[] usersBalances)
    {

        uint runningAuctionIndex = getAuctionIndex(auctionSellToken, auctionBuyToken);

        uint arrayLength;
        
        uint startingIndex = lastNAuctions == 0 ? 1 : runningAuctionIndex - lastNAuctions + 1;

        for (uint j = startingIndex; j <= runningAuctionIndex; j++) {
            if (sellerBalances[auctionSellToken][auctionBuyToken][j][user] > 0) {
                arrayLength++;
            }
        }

        indices = new uint[](arrayLength);
        usersBalances = new uint[](arrayLength);

        uint k;

        for (uint i = startingIndex; i <= runningAuctionIndex; i++) {
            if (sellerBalances[auctionSellToken][auctionBuyToken][i][user] > 0) {
                indices[k] = i;
                usersBalances[k] = sellerBalances[auctionSellToken][auctionBuyToken][i][user];
                k++;
            }
        }
    }    

    function getSellerBalancesOfCurrentAuctions(
        address[] auctionSellTokens,
        address[] auctionBuyTokens,
        address user
    )
        external
        view
        returns (uint[])
    {

        uint length = auctionSellTokens.length;
        uint length2 = auctionBuyTokens.length;
        require(length == length2);

        uint[] memory sellersBalances = new uint[](length);

        for (uint i = 0; i < length; i++) {
            uint runningAuctionIndex = getAuctionIndex(auctionSellTokens[i], auctionBuyTokens[i]);
            sellersBalances[i] = sellerBalances[auctionSellTokens[i]][auctionBuyTokens[i]][runningAuctionIndex][user];
        }

        return sellersBalances;
    }

    function getIndicesWithClaimableTokensForBuyers(
        address auctionSellToken,
        address auctionBuyToken,
        address user,
        uint lastNAuctions
    )
        external
        view
        returns(uint[] indices, uint[] usersBalances)
    {

        uint runningAuctionIndex = getAuctionIndex(auctionSellToken, auctionBuyToken);

        uint arrayLength;
        
        uint startingIndex = lastNAuctions == 0 ? 1 : runningAuctionIndex - lastNAuctions + 1;

        for (uint j = startingIndex; j <= runningAuctionIndex; j++) {
            if (buyerBalances[auctionSellToken][auctionBuyToken][j][user] > 0) {
                arrayLength++;
            }
        }

        indices = new uint[](arrayLength);
        usersBalances = new uint[](arrayLength);

        uint k;

        for (uint i = startingIndex; i <= runningAuctionIndex; i++) {
            if (buyerBalances[auctionSellToken][auctionBuyToken][i][user] > 0) {
                indices[k] = i;
                usersBalances[k] = buyerBalances[auctionSellToken][auctionBuyToken][i][user];
                k++;
            }
        }
    }    

    function getBuyerBalancesOfCurrentAuctions(
        address[] auctionSellTokens,
        address[] auctionBuyTokens,
        address user
    )
        external
        view
        returns (uint[])
    {

        uint length = auctionSellTokens.length;
        uint length2 = auctionBuyTokens.length;
        require(length == length2);

        uint[] memory buyersBalances = new uint[](length);

        for (uint i = 0; i < length; i++) {
            uint runningAuctionIndex = getAuctionIndex(auctionSellTokens[i], auctionBuyTokens[i]);
            buyersBalances[i] = buyerBalances[auctionSellTokens[i]][auctionBuyTokens[i]][runningAuctionIndex][user];
        }

        return buyersBalances;
    }

    function getApprovedAddressesOfList(
        address[] addressToCheck
    )
        external
        view
        returns (bool[])
    {

        uint length = addressToCheck.length;

        bool[] memory isApproved = new bool[](length);

        for (uint i = 0; i < length; i++) {
            isApproved[i] = approvedTokens[addressToCheck[i]];
        }

        return isApproved;
    }

    function claimTokensFromSeveralAuctionsAsSeller(
        address[] auctionSellTokens,
        address[] auctionBuyTokens,
        uint[] auctionIndices,
        address user
    )
        external
    {

        uint length = auctionSellTokens.length;
        uint length2 = auctionBuyTokens.length;
        require(length == length2);

        uint length3 = auctionIndices.length;
        require(length2 == length3);

        for (uint i = 0; i < length; i++)
            claimSellerFunds(auctionSellTokens[i], auctionBuyTokens[i], user, auctionIndices[i]);
    }
    function claimTokensFromSeveralAuctionsAsBuyer(
        address[] auctionSellTokens,
        address[] auctionBuyTokens,
        uint[] auctionIndices,
        address user
    )
        external
    {

        uint length = auctionSellTokens.length;
        uint length2 = auctionBuyTokens.length;
        require(length == length2);

        uint length3 = auctionIndices.length;
        require(length2 == length3);

        for (uint i = 0; i < length; i++)
            claimBuyerFunds(auctionSellTokens[i], auctionBuyTokens[i], user, auctionIndices[i]);
    }

    function getMasterCopy()
        external
        view 
        returns (address)
    {

        return masterCopy;
    }

    event NewDeposit(
         address indexed token,
         uint amount
    );

    event NewOracleProposal(
         PriceOracleInterface priceOracleInterface
    );


    event NewMasterCopyProposal(
         address newMasterCopy
    );

    event NewWithdrawal(
        address indexed token,
        uint amount
    );
    
    event NewSellOrder(
        address indexed sellToken,
        address indexed buyToken,
        address indexed user,
        uint auctionIndex,
        uint amount
    );

    event NewBuyOrder(
        address indexed sellToken,
        address indexed buyToken,
        address indexed user,
        uint auctionIndex,
        uint amount
    );

    event NewSellerFundsClaim(
        address indexed sellToken,
        address indexed buyToken,
        address indexed user,
        uint auctionIndex,
        uint amount,
        uint frtsIssued
    );

    event NewBuyerFundsClaim(
        address indexed sellToken,
        address indexed buyToken,
        address indexed user,
        uint auctionIndex,
        uint amount,
        uint frtsIssued
    );

    event NewTokenPair(
        address indexed sellToken,
        address indexed buyToken
    );

    event AuctionCleared(
        address indexed sellToken,
        address indexed buyToken,
        uint sellVolume,
        uint buyVolume,
        uint indexed auctionIndex
    );

    event Approval(
        address indexed token,
        bool approved
    );

    event AuctionStartScheduled(
        address indexed sellToken,
        address indexed buyToken,
        uint indexed auctionIndex,
        uint auctionStart
    );

    event Fee(
        address indexed primaryToken,
        address indexed secondarToken,
        address indexed user,
        uint auctionIndex,
        uint fee
    );
}