pragma solidity >=0.8.0;

abstract contract Auth {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

interface Authority {

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);

}// MIT
pragma solidity ^0.8.11;



library Base64 {

    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        uint len = data.length;
        if (len == 0) return "";

        uint encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint balance);


    function ownerOf(uint tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;


    function approve(address to, uint tokenId) external;


    function getApproved(uint tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint tokenId) external view returns (string memory);

}

interface IERC20 {

    function transfer(address recipient, uint amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

}

    struct Point {
        int128 bias;
        int128 slope; // # -dweight / dt
        uint ts;
        uint blk; // block
    }

    struct LockedBalance {
        int128 amount;
        uint end;
    }

contract veAPHRA is Auth, IERC721, IERC721Metadata {

    enum DepositType {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME,
        MERGE_TYPE
    }

    event Deposit(
        address indexed provider,
        uint tokenId,
        uint value,
        uint indexed locktime,
        DepositType deposit_type,
        uint ts
    );
    event Withdraw(address indexed provider, uint tokenId, uint value, uint ts);
    event Supply(uint prevSupply, uint supply);

    uint internal constant WEEK = 1 weeks;
    uint internal constant MAXTIME = 2 * 365 * 86400;
    int128 internal constant iMAXTIME = 2 * 365 * 86400;
    uint internal constant MULTIPLIER = 1 ether;

    address immutable public token;
    uint public supply;
    mapping(uint => LockedBalance) public locked;

    mapping(uint => uint) public ownership_change;

    uint public epoch;
    mapping(uint => Point) public point_history; // epoch -> unsigned point
    mapping(uint => Point[1000000000]) public user_point_history; // user -> Point[user_epoch]

    mapping(uint => uint) public user_point_epoch;
    mapping(uint => int128) public slope_changes; // time -> signed slope change

    mapping(uint => uint) public attachments;
    mapping(uint => bool) public voted;
    address public voter;

    string constant public name = "veAPHRA";
    string constant public symbol = "veAPHRA";
    string constant public version = "1.0.0";
    uint8 constant public decimals = 18;

    string public badgeDescription;
    uint internal tokenId;

    mapping(uint => address) internal idToOwner;

    mapping(uint => address) internal idToApprovals;

    mapping(address => uint) internal ownerToNFTokenCount;

    mapping(address => mapping(uint => uint)) internal ownerToNFTokenIdList;

    mapping(uint => uint) internal tokenToOwnerIndex;

    mapping(address => mapping(address => bool)) internal ownerToOperators;

    mapping(bytes4 => bool) internal supportedInterfaces;

    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;

    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;

    bool internal _unlocked;
    uint8 internal constant _not_entered = 1;
    uint8 internal constant _entered = 2;
    uint8 internal _entered_state = 1;
    modifier nonreentrant() {

        require(_entered_state == _not_entered);
        _entered_state = _entered;
        _;
        _entered_state = _not_entered;
    }

    constructor(
        address TOKEN_ADDR_,
        address GOVERNANCE_,
        address AUTHORITY_
    ) Auth(GOVERNANCE_, Authority(AUTHORITY_)) {
        token = TOKEN_ADDR_;
        voter = msg.sender;
        point_history[0].blk = block.number;
        point_history[0].ts = block.timestamp;
        _unlocked = false;
        supportedInterfaces[ERC165_INTERFACE_ID] = true;
        supportedInterfaces[ERC721_INTERFACE_ID] = true;
        supportedInterfaces[ERC721_METADATA_INTERFACE_ID] = true;
        badgeDescription = string("APHRA Badges, can be used to boost gauge yields, vote on new token emissions, receive protocol bribes and participate in governance");
        emit Transfer(address(0), address(this), tokenId);
        emit Transfer(address(this), address(0), tokenId);
    }

    function isUnlocked() public view returns (bool) {

        return _unlocked;
    }

    function setBadgeDescription(string memory _newDescription) requiresAuth external {

        badgeDescription = _newDescription;
    }

    function unlock() public requiresAuth {

        require(_unlocked == false, "unlock already happened");
        _unlocked = true;
    }

    modifier unlocked() {

        require(_unlocked, "contract must be unlocked");
        _;
    }

    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {

        return supportedInterfaces[_interfaceID];
    }

    function get_last_user_slope(uint _tokenId) external view returns (int128) {

        uint uepoch = user_point_epoch[_tokenId];
        return user_point_history[_tokenId][uepoch].slope;
    }

    function user_point_history__ts(uint _tokenId, uint _idx) external view returns (uint) {

        return user_point_history[_tokenId][_idx].ts;
    }

    function locked__end(uint _tokenId) external view returns (uint) {

        return locked[_tokenId].end;
    }

    function _balance(address _owner) internal view returns (uint) {

        return ownerToNFTokenCount[_owner];
    }

    function balanceOf(address _owner) external view returns (uint) {

        return _balance(_owner);
    }

    function ownerOf(uint _tokenId) public view returns (address) {

        return idToOwner[_tokenId];
    }

    function getApproved(uint _tokenId) external view returns (address) {

        return idToApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {

        return (ownerToOperators[_owner])[_operator];
    }

    function tokenOfOwnerByIndex(address _owner, uint _tokenIndex) external view returns (uint) {

        return ownerToNFTokenIdList[_owner][_tokenIndex];
    }

    function _isApprovedOrOwner(address _spender, uint _tokenId) internal view returns (bool) {

        address owner = idToOwner[_tokenId];
        bool spenderIsOwner = owner == _spender;
        bool spenderIsApproved = _spender == idToApprovals[_tokenId];
        bool spenderIsApprovedForAll = (ownerToOperators[owner])[_spender];
        return spenderIsOwner || spenderIsApproved || spenderIsApprovedForAll;
    }

    function isApprovedOrOwner(address _spender, uint _tokenId) external view returns (bool) {

        return _isApprovedOrOwner(_spender, _tokenId);
    }

    function _addTokenToOwnerList(address _to, uint _tokenId) internal {

        uint current_count = _balance(_to);

        ownerToNFTokenIdList[_to][current_count] = _tokenId;
        tokenToOwnerIndex[_tokenId] = current_count;
    }

    function _removeTokenFromOwnerList(address _from, uint _tokenId) internal {

        uint current_count = _balance(_from) - 1;
        uint current_index = tokenToOwnerIndex[_tokenId];

        if (current_count == current_index) {
            ownerToNFTokenIdList[_from][current_count] = 0;
            tokenToOwnerIndex[_tokenId] = 0;
        } else {
            uint lastTokenId = ownerToNFTokenIdList[_from][current_count];

            ownerToNFTokenIdList[_from][current_index] = lastTokenId;
            tokenToOwnerIndex[lastTokenId] = current_index;

            ownerToNFTokenIdList[_from][current_count] = 0;
            tokenToOwnerIndex[_tokenId] = 0;
        }
    }

    function _addTokenTo(address _to, uint _tokenId) internal {

        assert(idToOwner[_tokenId] == address(0));
        idToOwner[_tokenId] = _to;
        _addTokenToOwnerList(_to, _tokenId);
        ownerToNFTokenCount[_to] += 1;
    }

    function _removeTokenFrom(address _from, uint _tokenId) internal {

        assert(idToOwner[_tokenId] == _from);
        idToOwner[_tokenId] = address(0);
        _removeTokenFromOwnerList(_from, _tokenId);
        ownerToNFTokenCount[_from] -= 1;
    }

    function _clearApproval(address _owner, uint _tokenId) internal {

        assert(idToOwner[_tokenId] == _owner);
        if (idToApprovals[_tokenId] != address(0)) {
            idToApprovals[_tokenId] = address(0);
        }
    }

    function _transferFrom(
        address _from,
        address _to,
        uint _tokenId,
        address _sender
    ) internal {

        require(attachments[_tokenId] == 0 && !voted[_tokenId], "attached");
        require(_isApprovedOrOwner(_sender, _tokenId));
        _clearApproval(_from, _tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);
        ownership_change[_tokenId] = block.number;
        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint _tokenId
    ) unlocked external {

        _transferFrom(_from, _to, _tokenId, msg.sender);
    }

    function _isContract(address account) internal view returns (bool) {

        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint _tokenId,
        bytes memory _data
    ) unlocked public {

        _transferFrom(_from, _to, _tokenId, msg.sender);

        if (_isContract(_to)) {
            try IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) returns (bytes4) {} catch (
                bytes memory reason
            ) {
                if (reason.length == 0) {
                    revert('ERC721: transfer to non ERC721Receiver implementer');
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint _tokenId
    ) unlocked external {

        safeTransferFrom(_from, _to, _tokenId, '');
    }

    function approve(address _approved, uint _tokenId) unlocked public {

        address owner = idToOwner[_tokenId];
        require(owner != address(0));
        require(_approved != owner);
        bool senderIsOwner = (idToOwner[_tokenId] == msg.sender);
        bool senderIsApprovedForAll = (ownerToOperators[owner])[msg.sender];
        require(senderIsOwner || senderIsApprovedForAll);
        idToApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) unlocked external {

        assert(_operator != msg.sender);
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function _mint(address _to, uint _tokenId) internal returns (bool) {

        assert(_to != address(0));
        _addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
        return true;
    }

    function _checkpoint(
        uint _tokenId,
        LockedBalance memory old_locked,
        LockedBalance memory new_locked
    ) internal {

        Point memory u_old;
        Point memory u_new;
        int128 old_dslope = 0;
        int128 new_dslope = 0;
        uint _epoch = epoch;

        if (_tokenId != 0) {
            if (old_locked.end > block.timestamp && old_locked.amount > 0) {
                u_old.slope = old_locked.amount / iMAXTIME;
                u_old.bias = u_old.slope * int128(int256(old_locked.end - block.timestamp));
            }
            if (new_locked.end > block.timestamp && new_locked.amount > 0) {
                u_new.slope = new_locked.amount / iMAXTIME;
                u_new.bias = u_new.slope * int128(int256(new_locked.end - block.timestamp));
            }

            old_dslope = slope_changes[old_locked.end];
            if (new_locked.end != 0) {
                if (new_locked.end == old_locked.end) {
                    new_dslope = old_dslope;
                } else {
                    new_dslope = slope_changes[new_locked.end];
                }
            }
        }

        Point memory last_point = Point({bias : 0, slope : 0, ts : block.timestamp, blk : block.number});
        if (_epoch > 0) {
            last_point = point_history[_epoch];
        }
        uint last_checkpoint = last_point.ts;
        Point memory initial_last_point = last_point;
        uint block_slope = 0;
        if (block.timestamp > last_point.ts) {
            block_slope = (MULTIPLIER * (block.number - last_point.blk)) / (block.timestamp - last_point.ts);
        }

        {
            uint t_i = (last_checkpoint / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {
                t_i += WEEK;
                int128 d_slope = 0;
                if (t_i > block.timestamp) {
                    t_i = block.timestamp;
                } else {
                    d_slope = slope_changes[t_i];
                }
                last_point.bias -= last_point.slope * int128(int256(t_i - last_checkpoint));
                last_point.slope += d_slope;
                if (last_point.bias < 0) {
                    last_point.bias = 0;
                }
                if (last_point.slope < 0) {
                    last_point.slope = 0;
                }
                last_checkpoint = t_i;
                last_point.ts = t_i;
                last_point.blk = initial_last_point.blk + (block_slope * (t_i - initial_last_point.ts)) / MULTIPLIER;
                _epoch += 1;
                if (t_i == block.timestamp) {
                    last_point.blk = block.number;
                    break;
                } else {
                    point_history[_epoch] = last_point;
                }
            }
        }

        epoch = _epoch;

        if (_tokenId != 0) {
            last_point.slope += (u_new.slope - u_old.slope);
            last_point.bias += (u_new.bias - u_old.bias);
            if (last_point.slope < 0) {
                last_point.slope = 0;
            }
            if (last_point.bias < 0) {
                last_point.bias = 0;
            }
        }

        point_history[_epoch] = last_point;

        if (_tokenId != 0) {
            if (old_locked.end > block.timestamp) {
                old_dslope += u_old.slope;
                if (new_locked.end == old_locked.end) {
                    old_dslope -= u_new.slope;
                }
                slope_changes[old_locked.end] = old_dslope;
            }

            if (new_locked.end > block.timestamp) {
                if (new_locked.end > old_locked.end) {
                    new_dslope -= u_new.slope;
                    slope_changes[new_locked.end] = new_dslope;
                }
            }
            uint user_epoch = user_point_epoch[_tokenId] + 1;

            user_point_epoch[_tokenId] = user_epoch;
            u_new.ts = block.timestamp;
            u_new.blk = block.number;
            user_point_history[_tokenId][user_epoch] = u_new;
        }
    }

    function _deposit_for(
        uint _tokenId,
        uint _value,
        uint unlock_time,
        LockedBalance memory locked_balance,
        DepositType deposit_type
    ) internal {

        LockedBalance memory _locked = locked_balance;
        uint supply_before = supply;

        supply = supply_before + _value;
        LockedBalance memory old_locked;
        (old_locked.amount, old_locked.end) = (_locked.amount, _locked.end);
        _locked.amount += int128(int256(_value));
        if (unlock_time != 0) {
            _locked.end = unlock_time;
        }
        locked[_tokenId] = _locked;

        _checkpoint(_tokenId, old_locked, _locked);

        address from = msg.sender;
        if (_value != 0 && deposit_type != DepositType.MERGE_TYPE) {
            assert(IERC20(token).transferFrom(from, address(this), _value));
        }

        emit Deposit(from, _tokenId, _value, _locked.end, deposit_type, block.timestamp);
        emit Supply(supply_before, supply_before + _value);
    }

    function setVoter(address _voter) external {

        require(msg.sender == voter);
        voter = _voter;
    }

    function voting(uint _tokenId) external {

        require(msg.sender == voter);
        voted[_tokenId] = true;
    }

    function abstain(uint _tokenId) external {

        require(msg.sender == voter);
        voted[_tokenId] = false;
    }

    function attach(uint _tokenId) external {

        require(msg.sender == voter);
        attachments[_tokenId] = attachments[_tokenId] + 1;
    }

    function detach(uint _tokenId) external {

        require(msg.sender == voter);
        attachments[_tokenId] = attachments[_tokenId] - 1;
    }

    function merge(uint _from, uint _to) unlocked external {

        require(attachments[_from] == 0 && !voted[_from], "attached");
        require(_from != _to);
        require(_isApprovedOrOwner(msg.sender, _from));
        require(_isApprovedOrOwner(msg.sender, _to));

        LockedBalance memory _locked0 = locked[_from];
        LockedBalance memory _locked1 = locked[_to];
        uint value0 = uint(int256(_locked0.amount));
        uint end = _locked0.end >= _locked1.end ? _locked0.end : _locked1.end;

        locked[_from] = LockedBalance(0, 0);
        _checkpoint(_from, _locked0, LockedBalance(0, 0));
        _burn(_from);
        _deposit_for(_to, value0, end, _locked1, DepositType.MERGE_TYPE);
    }

    function block_number() external view returns (uint) {

        return block.number;
    }

    function checkpoint() external {

        _checkpoint(0, LockedBalance(0, 0), LockedBalance(0, 0));
    }

    function deposit_for(uint _tokenId, uint _value) external nonreentrant {

        LockedBalance memory _locked = locked[_tokenId];

        require(_value > 0);
        require(_locked.amount > 0 || !isUnlocked(), 'No existing lock found');
        require(_locked.end > block.timestamp, 'Cannot add to expired lock. Withdraw');
        _deposit_for(_tokenId, _value, 0, _locked, DepositType.DEPOSIT_FOR_TYPE);
    }

    function _create_lock(uint _value, uint _lock_duration, address _to) internal returns (uint) {

        uint unlock_time = (block.timestamp + _lock_duration) / WEEK * WEEK;

        require(_value > 0 || !isUnlocked());
        require(unlock_time > block.timestamp, 'Can only lock until time in the future');
        require(unlock_time <= block.timestamp + MAXTIME, 'Voting lock can be 2 years max');

        ++tokenId;
        uint _tokenId = tokenId;
        _mint(_to, _tokenId);

        _deposit_for(_tokenId, _value, unlock_time, locked[_tokenId], DepositType.CREATE_LOCK_TYPE);
        return _tokenId;
    }

    function create_lock_for(uint _value, uint _lock_duration, address _to) external nonreentrant returns (uint) {

        return _create_lock(_value, _lock_duration, _to);
    }

    function create_lock(uint _value, uint _lock_duration) external nonreentrant returns (uint) {

        return _create_lock(_value, _lock_duration, msg.sender);
    }

    function increase_amount(uint _tokenId, uint _value) external nonreentrant {

        assert(_isApprovedOrOwner(msg.sender, _tokenId));

        LockedBalance memory _locked = locked[_tokenId];

        assert(_value > 0 || !isUnlocked());
        require(_locked.amount > 0 || !isUnlocked(), 'No existing lock found');
        require(_locked.end > block.timestamp, 'Cannot add to expired lock. Withdraw');

        _deposit_for(_tokenId, _value, 0, _locked, DepositType.INCREASE_LOCK_AMOUNT);
    }

    function increase_unlock_time(uint _tokenId, uint _lock_duration) external nonreentrant {

        assert(_isApprovedOrOwner(msg.sender, _tokenId));

        LockedBalance memory _locked = locked[_tokenId];
        uint unlock_time = (block.timestamp + _lock_duration) / WEEK * WEEK;

        require(_locked.end > block.timestamp, 'Lock expired');
        require(_locked.amount > 0, 'Nothing is locked');
        require(unlock_time > _locked.end, 'Can only increase lock duration');
        require(unlock_time <= block.timestamp + MAXTIME, 'Voting lock can be 4 years max');

        _deposit_for(_tokenId, 0, unlock_time, _locked, DepositType.INCREASE_UNLOCK_TIME);
    }

    function withdraw(uint _tokenId) unlocked external nonreentrant {

        assert(_isApprovedOrOwner(msg.sender, _tokenId));
        require(attachments[_tokenId] == 0 && !voted[_tokenId], "attached");

        LockedBalance memory _locked = locked[_tokenId];
        require(block.timestamp >= _locked.end, "The lock didn't expire");
        uint value = uint(int256(_locked.amount));

        locked[_tokenId] = LockedBalance(0, 0);
        uint supply_before = supply;
        supply = supply_before - value;

        _checkpoint(_tokenId, _locked, LockedBalance(0, 0));

        assert(IERC20(token).transfer(msg.sender, value));

        _burn(_tokenId);

        emit Withdraw(msg.sender, _tokenId, value, block.timestamp);
        emit Supply(supply_before, supply_before - value);
    }


    function _find_block_epoch(uint _block, uint max_epoch) internal view returns (uint) {

        uint _min = 0;
        uint _max = max_epoch;
        for (uint i = 0; i < 128; ++i) {
            if (_min >= _max) {
                break;
            }
            uint _mid = (_min + _max + 1) / 2;
            if (point_history[_mid].blk <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }
        return _min;
    }

    function _balanceOfNFT(uint _tokenId, uint _t) internal view returns (uint) {

        uint _epoch = user_point_epoch[_tokenId];
        if (_epoch == 0) {
            return 0;
        } else {
            Point memory last_point = user_point_history[_tokenId][_epoch];
            last_point.bias -= last_point.slope * int128(int256(_t) - int256(last_point.ts));
            if (last_point.bias < 0) {
                last_point.bias = 0;
            }
            return uint(int256(last_point.bias));
        }
    }

    function tokenURI(uint _tokenId) external view returns (string memory) {

        require(idToOwner[_tokenId] != address(0), "Query for nonexistent token");
        LockedBalance memory _locked = locked[_tokenId];
        return
        _tokenURI(
            _tokenId,
            _balanceOfNFT(_tokenId, block.timestamp),
            _locked.end,
            uint(int256(_locked.amount)),
            badgeDescription
        );
    }

    function balanceOfNFT(uint _tokenId) external view returns (uint) {

        if (ownership_change[_tokenId] == block.number) return 0;
        return _balanceOfNFT(_tokenId, block.timestamp);
    }

    function balanceOfNFTAt(uint _tokenId, uint _t) external view returns (uint) {

        return _balanceOfNFT(_tokenId, _t);
    }

    function _balanceOfAtNFT(uint _tokenId, uint _block) internal view returns (uint) {

        assert(_block <= block.number);

        uint _min = 0;
        uint _max = user_point_epoch[_tokenId];
        for (uint i = 0; i < 128; ++i) {
            if (_min >= _max) {
                break;
            }
            uint _mid = (_min + _max + 1) / 2;
            if (user_point_history[_tokenId][_mid].blk <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }

        Point memory upoint = user_point_history[_tokenId][_min];

        uint max_epoch = epoch;
        uint _epoch = _find_block_epoch(_block, max_epoch);
        Point memory point_0 = point_history[_epoch];
        uint d_block = 0;
        uint d_t = 0;
        if (_epoch < max_epoch) {
            Point memory point_1 = point_history[_epoch + 1];
            d_block = point_1.blk - point_0.blk;
            d_t = point_1.ts - point_0.ts;
        } else {
            d_block = block.number - point_0.blk;
            d_t = block.timestamp - point_0.ts;
        }
        uint block_time = point_0.ts;
        if (d_block != 0) {
            block_time += (d_t * (_block - point_0.blk)) / d_block;
        }

        upoint.bias -= upoint.slope * int128(int256(block_time - upoint.ts));
        if (upoint.bias >= 0) {
            return uint(uint128(upoint.bias));
        } else {
            return 0;
        }
    }

    function balanceOfAtNFT(uint _tokenId, uint _block) external view returns (uint) {

        return _balanceOfAtNFT(_tokenId, _block);
    }

    function _supply_at(Point memory point, uint t) internal view returns (uint) {

        Point memory last_point = point;
        uint t_i = (last_point.ts / WEEK) * WEEK;
        for (uint i = 0; i < 255; ++i) {
            t_i += WEEK;
            int128 d_slope = 0;
            if (t_i > t) {
                t_i = t;
            } else {
                d_slope = slope_changes[t_i];
            }
            last_point.bias -= last_point.slope * int128(int256(t_i - last_point.ts));
            if (t_i == t) {
                break;
            }
            last_point.slope += d_slope;
            last_point.ts = t_i;
        }

        if (last_point.bias < 0) {
            last_point.bias = 0;
        }
        return uint(uint128(last_point.bias));
    }

    function totalSupplyAtT(uint t) public view returns (uint) {

        uint _epoch = epoch;
        Point memory last_point = point_history[_epoch];
        return _supply_at(last_point, t);
    }

    function totalSupply() external view returns (uint) {

        return totalSupplyAtT(block.timestamp);
    }

    function totalSupplyAt(uint _block) external view returns (uint) {

        assert(_block <= block.number);
        uint _epoch = epoch;
        uint target_epoch = _find_block_epoch(_block, _epoch);

        Point memory point = point_history[target_epoch];
        uint dt = 0;
        if (target_epoch < _epoch) {
            Point memory point_next = point_history[target_epoch + 1];
            if (point.blk != point_next.blk) {
                dt = ((_block - point.blk) * (point_next.ts - point.ts)) / (point_next.blk - point.blk);
            }
        } else {
            if (point.blk != block.number) {
                dt = ((_block - point.blk) * (block.timestamp - point.ts)) / (block.number - point.blk);
            }
        }
        return _supply_at(point, point.ts + dt);
    }

    function _tokenURI(uint _tokenId, uint _balanceOf, uint _locked_end, uint _value, string memory description) internal pure returns (string memory output) {

        output = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        output = string(abi.encodePacked(output, "token ", toString(_tokenId), '</text><text x="10" y="40" class="base">'));
        output = string(abi.encodePacked(output, "balanceOf ", toString(_balanceOf), '</text><text x="10" y="60" class="base">'));
        output = string(abi.encodePacked(output, "locked_end ", toString(_locked_end), '</text><text x="10" y="80" class="base">'));
        output = string(abi.encodePacked(output, "value ", toString(_value), '</text></svg>'));

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Badge #', toString(_tokenId), '", "description": "', description, '", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
    }

    function toString(uint value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function _burn(uint _tokenId) internal {

        require(_isApprovedOrOwner(msg.sender, _tokenId), "caller is not owner nor approved");

        address owner = ownerOf(_tokenId);

        approve(address(0), _tokenId);
        _removeTokenFrom(msg.sender, _tokenId);
        emit Transfer(owner, address(0), _tokenId);
    }
}