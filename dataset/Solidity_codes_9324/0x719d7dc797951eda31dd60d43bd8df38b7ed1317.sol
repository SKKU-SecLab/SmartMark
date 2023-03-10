
pragma solidity ^0.4.24;





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

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {

        authority = authority_;
        emit LogSetAuthority(authority);
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








contract DSRoles is DSAuth, DSAuthority
{

    mapping(address=>bool) _root_users;
    mapping(address=>bytes32) _user_roles;
    mapping(address=>mapping(bytes4=>bytes32)) _capability_roles;
    mapping(address=>mapping(bytes4=>bool)) _public_capabilities;

    function getUserRoles(address who)
        public
        view
        returns (bytes32)
    {

        return _user_roles[who];
    }

    function getCapabilityRoles(address code, bytes4 sig)
        public
        view
        returns (bytes32)
    {

        return _capability_roles[code][sig];
    }

    function isUserRoot(address who)
        public
        view
        returns (bool)
    {

        return _root_users[who];
    }

    function isCapabilityPublic(address code, bytes4 sig)
        public
        view
        returns (bool)
    {

        return _public_capabilities[code][sig];
    }

    function hasUserRole(address who, uint8 role)
        public
        view
        returns (bool)
    {

        bytes32 roles = getUserRoles(who);
        bytes32 shifted = bytes32(uint256(uint256(2) ** uint256(role)));
        return bytes32(0) != roles & shifted;
    }

    function canCall(address caller, address code, bytes4 sig)
        public
        view
        returns (bool)
    {

        if( isUserRoot(caller) || isCapabilityPublic(code, sig) ) {
            return true;
        } else {
            bytes32 has_roles = getUserRoles(caller);
            bytes32 needs_one_of = getCapabilityRoles(code, sig);
            return bytes32(0) != has_roles & needs_one_of;
        }
    }

    function BITNOT(bytes32 input) internal pure returns (bytes32 output) {

        return (input ^ bytes32(uint(-1)));
    }

    function setRootUser(address who, bool enabled)
        public
        auth
    {

        _root_users[who] = enabled;
    }

    function setUserRole(address who, uint8 role, bool enabled)
        public
        auth
    {

        bytes32 last_roles = _user_roles[who];
        bytes32 shifted = bytes32(uint256(uint256(2) ** uint256(role)));
        if( enabled ) {
            _user_roles[who] = last_roles | shifted;
        } else {
            _user_roles[who] = last_roles & BITNOT(shifted);
        }
    }

    function setPublicCapability(address code, bytes4 sig, bool enabled)
        public
        auth
    {

        _public_capabilities[code][sig] = enabled;
    }

    function setRoleCapability(uint8 role, address code, bytes4 sig, bool enabled)
        public
        auth
    {

        bytes32 last_roles = _capability_roles[code][sig];
        bytes32 shifted = bytes32(uint256(uint256(2) ** uint256(role)));
        if( enabled ) {
            _capability_roles[code][sig] = last_roles | shifted;
        } else {
            _capability_roles[code][sig] = last_roles & BITNOT(shifted);
        }

    }

}






contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint x, uint n) internal pure returns (uint z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
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

        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}








contract DSThing is DSAuth, DSNote, DSMath {


    function S(string s) internal pure returns (bytes4) {

        return bytes4(keccak256(abi.encodePacked(s)));
    }

}








contract DSStop is DSNote, DSAuth {


    bool public stopped;

    modifier stoppable {

        require(!stopped);
        _;
    }
    function stop() public auth note {

        stopped = true;
    }
    function start() public auth note {

        stopped = false;
    }

}





contract ERC20Events {

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {

    function totalSupply() public view returns (uint);

    function balanceOf(address guy) public view returns (uint);

    function allowance(address src, address guy) public view returns (uint);


    function approve(address guy, uint wad) public returns (bool);

    function transfer(address dst, uint wad) public returns (bool);

    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);

}








contract DSTokenBase is ERC20, DSMath {

    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {

        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {

        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {

        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {

        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {

        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {

        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}









contract DSToken is DSTokenBase(0), DSStop {


    bytes32  public  symbol;
    uint256  public  decimals = 18; // standard token precision. override to customize

    constructor(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function approve(address guy) public stoppable returns (bool) {

        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {

        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {

        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) public {

        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {

        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {

        transferFrom(src, dst, wad);
    }

    function mint(uint wad) public {

        mint(msg.sender, wad);
    }
    function burn(uint wad) public {

        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {

        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        emit Mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {

        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        emit Burn(guy, wad);
    }

    bytes32   public  name = "";

    function setName(bytes32 name_) public auth {

        name = name_;
    }
}








contract DSChiefApprovals is DSThing {

    mapping(bytes32=>address[]) public slates;
    mapping(address=>bytes32) public votes;
    mapping(address=>uint256) public approvals;
    mapping(address=>uint256) public deposits;
    DSToken public GOV; // voting token that gets locked up
    DSToken public IOU; // non-voting representation of a token, for e.g. secondary voting mechanisms
    address public hat; // the chieftain's hat

    uint256 public MAX_YAYS;

    event Etch(bytes32 indexed slate);

    constructor(DSToken GOV_, DSToken IOU_, uint MAX_YAYS_) public
    {
        GOV = GOV_;
        IOU = IOU_;
        MAX_YAYS = MAX_YAYS_;
    }

    function lock(uint wad)
        public
        note
    {

        GOV.pull(msg.sender, wad);
        IOU.mint(msg.sender, wad);
        deposits[msg.sender] = add(deposits[msg.sender], wad);
        addWeight(wad, votes[msg.sender]);
    }

    function free(uint wad)
        public
        note
    {

        deposits[msg.sender] = sub(deposits[msg.sender], wad);
        subWeight(wad, votes[msg.sender]);
        IOU.burn(msg.sender, wad);
        GOV.push(msg.sender, wad);
    }

    function etch(address[] yays)
        public
        note
        returns (bytes32 slate)
    {

        require( yays.length <= MAX_YAYS );
        requireByteOrderedSet(yays);

        bytes32 hash = keccak256(abi.encodePacked(yays));
        slates[hash] = yays;
        emit Etch(hash);
        return hash;
    }

    function vote(address[] yays) public returns (bytes32)
    {

        bytes32 slate = etch(yays);
        vote(slate);
        return slate;
    }

    function vote(bytes32 slate)
        public
        note
    {

        uint weight = deposits[msg.sender];
        subWeight(weight, votes[msg.sender]);
        votes[msg.sender] = slate;
        addWeight(weight, votes[msg.sender]);
    }

    function lift(address whom)
        public
        note
    {

        require(approvals[whom] > approvals[hat]);
        hat = whom;
    }

    function addWeight(uint weight, bytes32 slate)
        internal
    {

        address[] storage yays = slates[slate];
        for( uint i = 0; i < yays.length; i++) {
            approvals[yays[i]] = add(approvals[yays[i]], weight);
        }
    }

    function subWeight(uint weight, bytes32 slate)
        internal
    {

        address[] storage yays = slates[slate];
        for( uint i = 0; i < yays.length; i++) {
            approvals[yays[i]] = sub(approvals[yays[i]], weight);
        }
    }

    function requireByteOrderedSet(address[] yays)
        internal
        pure
    {

        if( yays.length == 0 || yays.length == 1 ) {
            return;
        }
        for( uint i = 0; i < yays.length - 1; i++ ) {
            require(uint(bytes32(yays[i])) < uint256(bytes32(yays[i+1])));
        }
    }
}


contract DSChief is DSRoles, DSChiefApprovals {


    constructor(DSToken GOV, DSToken IOU, uint MAX_YAYS)
             DSChiefApprovals (GOV, IOU, MAX_YAYS)
        public
    {
        authority = this;
        owner = 0;
    }

    function setOwner(address owner_) public {

        owner_;
        revert();
    }

    function setAuthority(DSAuthority authority_) public {

        authority_;
        revert();
    }

    function isUserRoot(address who)
        public
        constant
        returns (bool)
    {

        return (who == hat);
    }
    function setRootUser(address who, bool enabled) public {

        who; enabled;
        revert();
    }
}

contract DSChiefFab {

    function newChief(DSToken gov, uint MAX_YAYS) public returns (DSChief chief) {

        DSToken iou = new DSToken('IOU');
        chief = new DSChief(gov, iou, MAX_YAYS);
        iou.setOwner(chief);
    }
}



contract VoteProxy {

    address public cold;
    address public hot;
    DSToken public gov;
    DSToken public iou;
    DSChief public chief;

    constructor(DSChief _chief, address _cold, address _hot) public {
        chief = _chief;
        cold = _cold;
        hot = _hot;
        
        gov = chief.GOV();
        iou = chief.IOU();
        gov.approve(chief, uint256(-1));
        iou.approve(chief, uint256(-1));
    }

    modifier auth() {

        require(msg.sender == hot || msg.sender == cold, "Sender must be a Cold or Hot Wallet");
        _;
    }
    
    function lock(uint256 wad) public auth {

        gov.pull(cold, wad);   // mkr from cold
        chief.lock(wad);       // mkr out, ious in
    }

    function free(uint256 wad) public auth {

        chief.free(wad);       // ious out, mkr in
        gov.push(cold, wad);   // mkr to cold
    }

    function freeAll() public auth {

        chief.free(chief.deposits(this));            
        gov.push(cold, gov.balanceOf(this)); 
    }

    function vote(address[] yays) public auth returns (bytes32) {

        return chief.vote(yays);
    }

    function vote(bytes32 slate) public auth {

        chief.vote(slate);
    }
}



contract VoteProxyFactory {

    DSChief public chief;
    mapping(address => VoteProxy) public hotMap;
    mapping(address => VoteProxy) public coldMap;
    mapping(address => address) public linkRequests;

    event LinkRequested(address indexed cold, address indexed hot);
    event LinkConfirmed(address indexed cold, address indexed hot, address indexed voteProxy);
    
    constructor(DSChief chief_) public { chief = chief_; }

    function hasProxy(address guy) public view returns (bool) {

        return (coldMap[guy] != address(0) || hotMap[guy] != address(0));
    }

    function initiateLink(address hot) public {

        require(!hasProxy(msg.sender), "Cold wallet is already linked to another Vote Proxy");
        require(!hasProxy(hot), "Hot wallet is already linked to another Vote Proxy");

        linkRequests[msg.sender] = hot;
        emit LinkRequested(msg.sender, hot);
    }

    function approveLink(address cold) public returns (VoteProxy voteProxy) {

        require(linkRequests[cold] == msg.sender, "Cold wallet must initiate a link first");
        require(!hasProxy(msg.sender), "Hot wallet is already linked to another Vote Proxy");

        voteProxy = new VoteProxy(chief, cold, msg.sender);
        hotMap[msg.sender] = voteProxy;
        coldMap[cold] = voteProxy;
        delete linkRequests[cold];
        emit LinkConfirmed(cold, msg.sender, voteProxy);
    }

    function breakLink() public {

        require(hasProxy(msg.sender), "No VoteProxy found for this sender");

        VoteProxy voteProxy = coldMap[msg.sender] != address(0)
            ? coldMap[msg.sender] : hotMap[msg.sender];
        address cold = voteProxy.cold();
        address hot = voteProxy.hot();
        require(chief.IOU().balanceOf(voteProxy) == 0, "VoteProxy still has funds attached to it");

        delete coldMap[cold];
        delete hotMap[hot];
    }

    function linkSelf() public returns (VoteProxy voteProxy) {

        initiateLink(msg.sender);
        return approveLink(msg.sender);
    }
}