
pragma solidity 0.6.8;

contract Initializable {

    mapping (string => uint256) public initBlocks;

    event Initialized(string indexed key);

    modifier onlyInit(string memory key) {

        require(initBlocks[key] == 0, "initializable: already initialized");
        initBlocks[key] = block.number;
        _;
        emit Initialized(key);
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

interface IACLOracle {

    function willPerform(bytes4 role, address who, bytes calldata data) external returns (bool allowed);

}/*
 *    MIT
 */

pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;



library ACLData {

    enum BulkOp { Grant, Revoke, Freeze }

    struct BulkItem {
        BulkOp op;
        bytes4 role;
        address who;
    }
}

contract ACL is Initializable {

    bytes4 public constant ROOT_ROLE =
        this.grant.selector
        ^ this.revoke.selector
        ^ this.freeze.selector
        ^ this.bulk.selector
    ;

    address internal constant ANY_ADDR = address(-1);

    address internal constant UNSET_ROLE = address(0);
    address internal constant FREEZE_FLAG = address(1); // Also used as "who"
    address internal constant ALLOW_FLAG = address(2);

    mapping (bytes4 => mapping (address => address)) public roles;

    event Granted(bytes4 indexed role, address indexed actor, address indexed who, IACLOracle oracle);
    event Revoked(bytes4 indexed role, address indexed actor, address indexed who);
    event Frozen(bytes4 indexed role, address indexed actor);

    modifier auth(bytes4 _role) {

        require(willPerform(_role, msg.sender, msg.data), "acl: auth");
        _;
    }

    modifier initACL(address _initialRoot) {

        if (initBlocks["acl"] == 0) {
            _initializeACL(_initialRoot);
        } else {
            require(roles[ROOT_ROLE][_initialRoot] == ALLOW_FLAG, "acl: initial root misaligned");
        }
        _;
    }

    constructor(address _initialRoot) public initACL(_initialRoot) { }

    function grant(bytes4 _role, address _who) external auth(ROOT_ROLE) {

        _grant(_role, _who);
    }

    function grantWithOracle(bytes4 _role, address _who, IACLOracle _oracle) external auth(ROOT_ROLE) {

        _grantWithOracle(_role, _who, _oracle);
    }

    function revoke(bytes4 _role, address _who) external auth(ROOT_ROLE) {

        _revoke(_role, _who);
    }

    function freeze(bytes4 _role) external auth(ROOT_ROLE) {

        _freeze(_role);
    }

    function bulk(ACLData.BulkItem[] calldata items) external auth(ROOT_ROLE) {

        for (uint256 i = 0; i < items.length; i++) {
            ACLData.BulkItem memory item = items[i];

            if (item.op == ACLData.BulkOp.Grant) _grant(item.role, item.who);
            else if (item.op == ACLData.BulkOp.Revoke) _revoke(item.role, item.who);
            else if (item.op == ACLData.BulkOp.Freeze) _freeze(item.role);
        }
    }

    function willPerform(bytes4 _role, address _who, bytes memory _data) internal returns (bool) {

        return _checkRole(_role, _who, _data) || _checkRole(_role, ANY_ADDR, _data);
    }

    function isFrozen(bytes4 _role) public view returns (bool) {

        return roles[_role][FREEZE_FLAG] == FREEZE_FLAG;
    }

    function _initializeACL(address _initialRoot) internal onlyInit("acl") {

        _grant(ROOT_ROLE, _initialRoot);
    }

    function _grant(bytes4 _role, address _who) internal {

        _grantWithOracle(_role, _who, IACLOracle(ALLOW_FLAG));
    }

    function _grantWithOracle(bytes4 _role, address _who, IACLOracle _oracle) internal {

        require(!isFrozen(_role), "acl: frozen");
        require(_who != FREEZE_FLAG, "acl: bad freeze");

        roles[_role][_who] = address(_oracle);
        emit Granted(_role, msg.sender, _who, _oracle);
    }

    function _revoke(bytes4 _role, address _who) internal {

        require(!isFrozen(_role), "acl: frozen");

        roles[_role][_who] = UNSET_ROLE;
        emit Revoked(_role, msg.sender, _who);
    }

    function _freeze(bytes4 _role) internal {

        require(!isFrozen(_role), "acl: frozen");

        roles[_role][FREEZE_FLAG] = FREEZE_FLAG;
        emit Frozen(_role, msg.sender);
    }

    function _checkRole(bytes4 _role, address _who, bytes memory _data) internal returns (bool) {

        address accessFlagOrAclOracle = roles[_role][_who];
        if (accessFlagOrAclOracle != UNSET_ROLE) {
            if (accessFlagOrAclOracle == ALLOW_FLAG) return true;

            try IACLOracle(accessFlagOrAclOracle).willPerform(_role, _who, _data) returns (bool allowed) {
                if (allowed) return true;
            } catch { }
        }

        return false;
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

library AddressUtils {

    
    function toPayable(address addr) internal pure returns (address payable) {

        return address(bytes20(addr));
    }

    function isContract(address addr) internal view returns (bool result) {

        assembly {
            result := iszero(iszero(extcodesize(addr)))
        }
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

interface ERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);



    function totalSupply() external view returns (uint256);


    function balanceOf(address _who) external view returns (uint256);


    function allowance(address _owner, address _spender) external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}/*
 *    MIT
 */



pragma solidity ^0.6.8;



library SafeERC20 {

    using AddressUtils for address;

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata)
        private
        returns (bool ret)
    {

        if (!_addr.isContract()) {
            return false;
        }

        assembly {
            let ptr := mload(0x40)    // free memory pointer

            let success := call(
                gas(),                // forward all
                _addr,                // address
                0,                    // no value
                add(_calldata, 0x20), // calldata start
                mload(_calldata),     // calldata length
                ptr,                  // write output over free memory
                0x20                  // uint256 return
            )

            if gt(success, 0) {
                switch returndatasize()

                case 0 {
                    ret := 1
                }

                case 0x20 {
                    ret := iszero(iszero(mload(ptr)))
                }

                default { }
            }
        }
    }

    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferCallData = abi.encodeWithSelector(
            _token.transfer.selector,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferCallData);
    }

    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferFromCallData);
    }

    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {

        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), approveCallData);
    }
}/*
 *    MIT
 */


pragma solidity ^0.6.8;

library ERC1167ProxyFactory {

    function clone(address _implementation) internal returns (address cloneAddr) {

        bytes memory createData = generateCreateData(_implementation);

        assembly {
            cloneAddr := create(0, add(createData, 0x20), 55)
        }

        require(cloneAddr != address(0), "proxy-factory: bad create");
    }

    function clone(address _implementation, bytes memory _initData) internal returns (address cloneAddr) {

        cloneAddr = clone(_implementation);
        (bool ok, bytes memory ret) = cloneAddr.call(_initData);

        require(ok, _getRevertMsg(ret));
    }

    function clone2(address _implementation, bytes32 _salt) internal returns (address cloneAddr) {

        bytes memory createData = generateCreateData(_implementation);

        assembly {
            cloneAddr := create2(0, add(createData, 0x20), 55, _salt)
        }

        require(cloneAddr != address(0), "proxy-factory: bad create2");
    }

    function clone2(address _implementation, bytes32 _salt, bytes memory _initData) internal returns (address cloneAddr) {

        cloneAddr = clone2(_implementation, _salt);
        (bool ok, bytes memory ret) = cloneAddr.call(_initData);

        require(ok, _getRevertMsg(ret));
    }

    function generateCreateData(address _implementation) internal pure returns (bytes memory) {

        return abi.encodePacked(
            bytes10(0x3d602d80600a3d3981f3),
            bytes10(0x363d3d373d3d3d363d73),
            _implementation,
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );
    }

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return '';

        assembly {
            _returnData := add(_returnData, 0x04) // Slice the sighash.
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }
}/*
 *    GPL-3.0
 */

pragma solidity ^0.6.8;

library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "math: overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "math: underflow");
    }
}/*
 *    GPL-3.0
 */

pragma solidity ^0.6.8;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}/*
 *    GPL-3.0
 */

pragma solidity ^0.6.8;



contract GovernToken is IERC20, Initializable {

    using SafeMath for uint256;

    bytes32 private constant EIP712DOMAIN_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    bytes32 private constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

    string public name;
    string public symbol;
    uint8 public decimals;

    address public minter;
    uint256 override public totalSupply;
    mapping (address => uint256) override public balanceOf;
    mapping (address => mapping (address => uint256)) override public allowance;

    mapping (address => uint256) public nonces;
    mapping (address => mapping (bytes32 => bool)) public authorizationState;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event ChangeMinter(address indexed minter);

    modifier onlyMinter {

        require(msg.sender == minter, "token: not minter");
        _;
    }

    constructor(address _initialMinter, string memory _name, string memory _symbol, uint8 _decimals) public {
        initialize(_initialMinter, _name, _symbol, _decimals);
    }

    function initialize(address _initialMinter, string memory _name, string memory _symbol, uint8 _decimals) public onlyInit("token") {

        _changeMinter(_initialMinter);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function _validateSignedData(address signer, bytes32 encodeData, uint8 v, bytes32 r, bytes32 s) internal view {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                getDomainSeparator(),
                encodeData
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signer, "token: bad sig");
    }

    function _changeMinter(address newMinter) internal {

        minter = newMinter;
        emit ChangeMinter(newMinter);
    }

    function _mint(address to, uint256 value) internal {

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) private {

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) private {

        require(to != address(this) && to != address(0), "token: bad to");

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function getChainId() public pure returns (uint256 chainId) {

        assembly { chainId := chainid() }
    }

    function getDomainSeparator() public view returns (bytes32) {

        return keccak256(
            abi.encode(
                EIP712DOMAIN_HASH,
                keccak256(abi.encodePacked(name)),
                VERSION_HASH,
                getChainId(),
                address(this)
            )
        );
    }

    function mint(address to, uint256 value) external onlyMinter returns (bool) {

        _mint(to, value);
        return true;
    }

    function changeMinter(address newMinter) external onlyMinter {

        _changeMinter(newMinter);
    }

    function burn(uint256 value) external returns (bool) {

        _burn(msg.sender, value);
        return true;
    }

    function approve(address spender, uint256 value) override external returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) override external returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) override external returns (bool) {

        uint256 fromAllowance = allowance[from][msg.sender];
        if (fromAllowance != uint256(-1)) {
            allowance[from][msg.sender] = fromAllowance.sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {

        require(deadline >= block.timestamp, "token: auth expired");

        bytes32 encodeData = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline));
        _validateSignedData(owner, encodeData, v, r, s);

        _approve(owner, spender, value);
    }

    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {

        require(block.timestamp > validAfter, "token: auth wait");
        require(block.timestamp < validBefore, "token: auth expired");
        require(!authorizationState[from][nonce],  "token: auth used");

        bytes32 encodeData = keccak256(abi.encode(TRANSFER_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce));
        _validateSignedData(from, encodeData, v, r, s);

        authorizationState[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);

        _transfer(from, to, value);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}/*
 *    GPL-3.0
 */


pragma solidity ^0.6.8;



contract MerkleDistributor is Initializable {

    
    using SafeERC20 for ERC20;

    ERC20 public token;
    bytes32 public merkleRoot;

    mapping (uint256 => uint256) private claimedBitMap;

    event Claimed(uint256 indexed index, address indexed to, uint256 amount);

    constructor(ERC20 _token, bytes32 _merkleRoot) public {
        initialize(_token, _merkleRoot);
    }

    function initialize(ERC20 _token, bytes32 _merkleRoot) public onlyInit("distributor") {

        token = _token;
        merkleRoot = _merkleRoot;
    }

    function claim(uint256 _index, address _to, uint256 _amount, bytes32[] calldata _merkleProof) external {

        require(!isClaimed(_index), "dist: already claimed");
        require(_verifyBalanceOnTree(_index, _to, _amount, _merkleProof), "dist: proof failed");

        _setClaimed(_index);
        token.safeTransfer(_to, _amount);

        emit Claimed(_index, _to, _amount);
    }

    function unclaimedBalance(uint256 _index, address _to, uint256 _amount, bytes32[] memory _proof) public view returns (uint256) {

        if (isClaimed(_index)) return 0;
        return _verifyBalanceOnTree(_index, _to, _amount, _proof) ? _amount : 0;
    }

    function _verifyBalanceOnTree(uint256 _index, address _to, uint256 _amount, bytes32[] memory _proof) internal view returns (bool) {

        bytes32 node = keccak256(abi.encodePacked(_index, _to, _amount));
        return MerkleProof.verify(_proof, merkleRoot, node);
    }

    function isClaimed(uint256 _index) public view returns (bool) {

        uint256 claimedWord_index = _index / 256;
        uint256 claimedBit_index = _index % 256;
        uint256 claimedWord = claimedBitMap[claimedWord_index];
        uint256 mask = (1 << claimedBit_index);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 _index) private {

        uint256 claimedWord_index = _index / 256;
        uint256 claimedBit_index = _index % 256;
        claimedBitMap[claimedWord_index] = claimedBitMap[claimedWord_index] | (1 << claimedBit_index);
    }
}/*
 *    GPL-3.0
 */

pragma solidity ^0.6.8;



contract GovernMinter is ACL {

    using ERC1167ProxyFactory for address;

    bytes4 constant internal MINT_ROLE =
        this.mint.selector ^
        this.merkleMint.selector
    ;

    GovernToken public token;
    address public distributorBase;

    event MintedSingle(address indexed to, uint256 amount, bytes context);
    event MintedMerkle(address indexed distributor, bytes32 indexed merkleRoot, uint256 totalAmount, bytes tree, bytes context);

    constructor(GovernToken _token, address _initialMinter, MerkleDistributor _distributorBase) ACL(_initialMinter) public {
        initialize(_token, _initialMinter, _distributorBase);
    }

    function initialize(GovernToken _token, address _initialMinter, MerkleDistributor _distributorBase) public initACL(_initialMinter) onlyInit("minter") {

        token = _token;
        distributorBase = address(_distributorBase);
        _grant(MINT_ROLE, _initialMinter);
    }

    function mint(address _to, uint256 _amount, bytes calldata _context) external auth(MINT_ROLE) {

        token.mint(_to, _amount);
        emit MintedSingle(_to, _amount, _context);
    }

    function merkleMint(bytes32 _merkleRoot, uint256 _totalAmount, bytes calldata _tree, bytes calldata _context) external auth(MINT_ROLE) returns (MerkleDistributor distributor) {

        address distributorAddr = distributorBase.clone(abi.encodeWithSelector(distributor.initialize.selector, token, _merkleRoot));
        token.mint(distributorAddr, _totalAmount);

        emit MintedMerkle(distributorAddr, _merkleRoot, _totalAmount, _tree, _context);

        return MerkleDistributor(distributorAddr);
    }

    function eject(address _newMinter) external auth(this.eject.selector) {

        token.changeMinter(_newMinter);
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;


library TokenLib {

    
    struct TokenConfig {
        IERC20 tokenAddress;
        uint8  tokenDecimals;
        string tokenName;
        string tokenSymbol;
        address mintAddress; // initial minter address
        uint256 mintAmount; // how much to mint to initial minter address
        bytes32 merkleRoot; // merkle distribution root.
        uint256 merkleMintAmount; // how much to mint for the distributor.
        bytes merkleTree; // merkle tree object
        bytes merkleContext; // context/string what's the actual reason is...
    }
    
}/*
 *    MIT
 */

pragma solidity ^0.6.8;


library ERC3000Data {

    struct Container {
        Payload payload;
        Config config;
    }

    struct Payload {
        uint256 nonce;
        uint256 executionTime;
        address submitter;
        IERC3000Executor executor;
        Action[] actions;
        bytes32 allowFailuresMap;
        bytes proof;
    }

    struct Action {
        address to;
        uint256 value;
        bytes data;
    }

    struct Config {
        uint256 executionDelay; // how many seconds to wait before being able to call `execute`.
        Collateral scheduleDeposit; // fees for scheduling
        Collateral challengeDeposit; // fees for challenging
        address resolver;  // resolver that will rule the disputes
        bytes rules; // rules of how DAO should be managed
        uint256 maxCalldataSize; // max calldatasize for the schedule
    }

    struct Collateral {
        address token;
        uint256 amount;
    }

    function containerHash(bytes32 payloadHash, bytes32 configHash) internal view returns (bytes32) {

        uint chainId;
        assembly {
            chainId := chainid()
        }

        return keccak256(abi.encodePacked("erc3k-v1", address(this), chainId, payloadHash, configHash));
    }

    function hash(Container memory container) internal view returns (bytes32) {

        return containerHash(hash(container.payload), hash(container.config));
    }

    function hash(Payload memory payload) internal pure returns (bytes32) {

        return keccak256(
            abi.encode(
                payload.nonce,
                payload.executionTime,
                payload.submitter,
                payload.executor,
                keccak256(abi.encode(payload.actions)),
                payload.allowFailuresMap,
                keccak256(payload.proof)
            )
        );
    }

    function hash(Config memory config) internal pure returns (bytes32) {

        return keccak256(abi.encode(config));
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;


abstract contract IERC3000Executor {
    bytes4 internal constant ERC3000_EXEC_INTERFACE_ID = this.exec.selector;

    function exec(ERC3000Data.Action[] memory actions, bytes32 allowFailuresMap, bytes32 memo) virtual public returns (bytes32 failureMap, bytes[] memory execResults);
    event Executed(address indexed actor, ERC3000Data.Action[] actions, bytes32 memo, bytes32 failureMap, bytes[] execResults);
}/*
 *    GPL-3.0
 */

pragma solidity 0.6.8;




contract GovernTokenFactory {

    using ERC1167ProxyFactory for address;
    
    address public tokenBase;
    address public minterBase;
    address public distributorBase;

    event CreatedToken(GovernToken token, GovernMinter minter);

    constructor() public {
        setupBases();
    }

    function newToken(
        IERC3000Executor _governExecutor,
        TokenLib.TokenConfig calldata _token,
        bool _useProxies
    ) external returns (
        GovernToken token,
        GovernMinter minter
    ) {

        if (!_useProxies) {
            (token, minter) = _deployContracts(_token.tokenName, _token.tokenSymbol, _token.tokenDecimals);
        } else {
            token = GovernToken(tokenBase.clone(abi.encodeWithSelector(
                token.initialize.selector,
                address(this),
                _token.tokenName,
                _token.tokenSymbol,
                _token.tokenDecimals
            ))); 
            minter = GovernMinter(minterBase.clone(abi.encodeWithSelector(
                minter.initialize.selector,
                token,
                address(this),
                MerkleDistributor(distributorBase)
            )));
        }

        token.changeMinter(address(minter));
        
        if (_token.mintAmount > 0) {
            minter.mint(_token.mintAddress, _token.mintAmount, "initial mint");
        }

        if (_token.merkleRoot != bytes32(0)) {
            minter.merkleMint(_token.merkleRoot, _token.merkleMintAmount, _token.merkleTree, _token.merkleContext);
        }

        bytes4 mintRole = minter.mint.selector ^ minter.merkleMint.selector;
        bytes4 rootRole = minter.ROOT_ROLE();

        ACLData.BulkItem[] memory items = new ACLData.BulkItem[](4);

        items[0] = ACLData.BulkItem(ACLData.BulkOp.Grant, mintRole, address(_governExecutor));
        items[1] = ACLData.BulkItem(ACLData.BulkOp.Grant, rootRole, address(_governExecutor));
        items[2] = ACLData.BulkItem(ACLData.BulkOp.Revoke, mintRole, address(this));
        items[3] = ACLData.BulkItem(ACLData.BulkOp.Revoke, rootRole, address(this));

        minter.bulk(items);

        emit CreatedToken(token, minter);
    }

    function setupBases() private {

        distributorBase = address(new MerkleDistributor(ERC20(tokenBase), bytes32(0)));
        
        (GovernToken token, GovernMinter minter) = _deployContracts(
            "GovernToken base",
            "GTB",
            0
        );
        token.changeMinter(address(minter));

        minter.mint(msg.sender, 1, "test mint");
        minter.merkleMint(bytes32(0), 1, "no tree", "test merkle mint");

        tokenBase = address(token);
        minterBase = address(minter);
    }

    function _deployContracts(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) internal returns (
        GovernToken token,
        GovernMinter minter
    ) {

        token = new GovernToken(address(this), _tokenName, _tokenSymbol, _tokenDecimals);
        minter = new GovernMinter(GovernToken(token), address(this), MerkleDistributor(distributorBase));
    }
}