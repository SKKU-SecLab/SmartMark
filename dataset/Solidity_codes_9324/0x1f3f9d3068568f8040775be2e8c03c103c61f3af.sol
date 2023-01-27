pragma solidity ^0.7.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}/************************************************************************
 ~~~ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\ ~~~~
 ~~~ @@@@@@ ░█████╗░██████╗░░█████╗░██╗░░██╗███████╗██████╗░ @@@@@@ | ~~~
 ~~~ @@@@@  ██╔══██╗██╔══██╗██╔══██╗██║░░██║██╔════╝██╔══██╗  @@@@@ | ~~~
 ~~~ @@@@@  ███████║██████╔╝██║░░╚═╝███████║█████╗░░██████╔╝ @@@@@@ | ~~~
 ~~~ @@@@@  ██╔══██║██╔══██╗██║░░██╗██╔══██║██╔══╝░░██╔══██╗  @@@@@ | ~~~
 ~~~ @@@@@  ██║░░██║██║░░██║╚█████╔╝██║░░██║███████╗██║░░██║  @@@@@ | ~~~
 ~~~ @@@@@  ╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝  @@@@@ | ~~~
 ~~~ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ | ~~~
 ~~~ \_____________________________________________________________\| ~~~
 ************************************************************************/


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


contract ArchToken {

    using SafeMath for uint256;

    string public name = "Archer DAO Governance Token";

    string public symbol = "ARCH";

    uint8 public constant decimals = 18;

    uint256 public totalSupply = 100_000_000e18; // 100 million

    address public supplyManager;

    address public metadataManager;

    uint256 public supplyChangeAllowedAfter;

    uint32 public supplyChangeWaitingPeriod = 1 days * 365;

    uint32 public constant supplyChangeWaitingPeriodMinimum = 1 days * 90;

    uint16 public mintCap = 20_000;

    mapping (address => mapping (address => uint256)) internal allowances;

    mapping (address => uint256) internal balances;

    bytes32 public constant DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    
    bytes32 public constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

    bytes32 public constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH = 0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8;

    mapping (address => uint) public nonces;

    mapping (address => mapping (bytes32 => bool)) public authorizationState;

    event MintCapChanged(uint16 indexed oldMintCap, uint16 indexed newMintCap);

    event SupplyManagerChanged(address indexed oldManager, address indexed newManager);

    event SupplyChangeWaitingPeriodChanged(uint32 indexed oldWaitingPeriod, uint32 indexed newWaitingPeriod);

    event MetadataManagerChanged(address indexed oldManager, address indexed newManager);

    event TokenMetaUpdated(string indexed name, string indexed symbol);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);

    constructor(address _metadataManager, address _supplyManager, uint256 _firstSupplyChangeAllowed) {
        require(_firstSupplyChangeAllowed >= block.timestamp, "Arch::constructor: minting can only begin after deployment");

        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        supplyChangeAllowedAfter = _firstSupplyChangeAllowed;
        supplyManager = _supplyManager;
        emit SupplyManagerChanged(address(0), _supplyManager);

        metadataManager = _metadataManager;
        emit MetadataManagerChanged(address(0), metadataManager);
    }

    function setSupplyManager(address newSupplyManager) external returns (bool) {

        require(msg.sender == supplyManager, "Arch::setSupplyManager: only SM can change SM");
        emit SupplyManagerChanged(supplyManager, newSupplyManager);
        supplyManager = newSupplyManager;
        return true;
    }

    function setMetadataManager(address newMetadataManager) external returns (bool) {

        require(msg.sender == metadataManager, "Arch::setMetadataManager: only MM can change MM");
        emit MetadataManagerChanged(metadataManager, newMetadataManager);
        metadataManager = newMetadataManager;
        return true;
    }

    function mint(address dst, uint256 amount) external returns (bool) {

        require(msg.sender == supplyManager, "Arch::mint: only the supplyManager can mint");
        require(dst != address(0), "Arch::mint: cannot transfer to the zero address");
        require(amount <= totalSupply.mul(mintCap).div(1000000), "Arch::mint: exceeded mint cap");
        require(block.timestamp >= supplyChangeAllowedAfter, "Arch::mint: minting not allowed yet");

        supplyChangeAllowedAfter = block.timestamp.add(supplyChangeWaitingPeriod);

        _mint(dst, amount);
        return true;
    }

    function burn(address src, uint256 amount) external returns (bool) {

        address spender = msg.sender;
        require(spender == supplyManager, "Arch::burn: only the supplyManager can burn");
        require(src != address(0), "Arch::burn: cannot transfer from the zero address");
        require(block.timestamp >= supplyChangeAllowedAfter, "Arch::burn: burning not allowed yet");
        
        uint256 spenderAllowance = allowances[src][spender];
        if (spender != src && spenderAllowance != uint256(-1)) {
            uint256 newAllowance = spenderAllowance.sub(
                amount,
                "Arch::burn: burn amount exceeds allowance"
            );
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        supplyChangeAllowedAfter = block.timestamp.add(supplyChangeWaitingPeriod);

        _burn(src, amount);
        return true;
    }

    function setMintCap(uint16 newCap) external returns (bool) {

        require(msg.sender == supplyManager, "Arch::setMintCap: only SM can change mint cap");
        emit MintCapChanged(mintCap, newCap);
        mintCap = newCap;
        return true;
    }

    function setSupplyChangeWaitingPeriod(uint32 period) external returns (bool) {

        require(msg.sender == supplyManager, "Arch::setSupplyChangeWaitingPeriod: only SM can change waiting period");
        require(period >= supplyChangeWaitingPeriodMinimum, "Arch::setSupplyChangeWaitingPeriod: waiting period must be > minimum");
        emit SupplyChangeWaitingPeriodChanged(supplyChangeWaitingPeriod, period);
        supplyChangeWaitingPeriod = period;
        return true;
    }

    function updateTokenMetadata(string memory tokenName, string memory tokenSymbol) external returns (bool) {

        require(msg.sender == metadataManager, "Arch::updateTokenMeta: only MM can update token metadata");
        name = tokenName;
        symbol = tokenSymbol;
        emit TokenMetaUpdated(name, symbol);
        return true;
    }

    function allowance(address account, address spender) external view returns (uint) {

        return allowances[account][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {

        _increaseAllowance(msg.sender, spender, addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {

        _decreaseAllowance(msg.sender, spender, subtractedValue);
        return true;
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {

        require(deadline >= block.timestamp, "Arch::permit: signature expired");

        bytes32 encodeData = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline));
        _validateSignedData(owner, encodeData, v, r, s);

        _approve(owner, spender, value);
    }

    function balanceOf(address account) external view returns (uint) {

        return balances[account];
    }

    function transfer(address dst, uint256 amount) external returns (bool) {

        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {

        address spender = msg.sender;
        uint256 spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != uint256(-1)) {
            uint256 newAllowance = spenderAllowance.sub(
                amount,
                "Arch::transferFrom: transfer amount exceeds allowance"
            );
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
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

        require(block.timestamp > validAfter, "Arch::transferWithAuth: auth not yet valid");
        require(block.timestamp < validBefore, "Arch::transferWithAuth: auth expired");
        require(!authorizationState[from][nonce],  "Arch::transferWithAuth: auth already used");

        bytes32 encodeData = keccak256(abi.encode(TRANSFER_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce));
        _validateSignedData(from, encodeData, v, r, s);

        authorizationState[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);

        _transferTokens(from, to, value);
    }

    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        require(to == msg.sender, "Arch::receiveWithAuth: caller must be the payee");
        require(block.timestamp > validAfter, "Arch::receiveWithAuth: auth not yet valid");
        require(block.timestamp < validBefore, "Arch::receiveWithAuth: auth expired");
        require(!authorizationState[from][nonce],  "Arch::receiveWithAuth: auth already used");

        bytes32 encodeData = keccak256(abi.encode(RECEIVE_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce));
        _validateSignedData(from, encodeData, v, r, s);

        authorizationState[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);

        _transferTokens(from, to, value);
    }

    function getDomainSeparator() public view returns (bytes32) {

        return keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                VERSION_HASH,
                _getChainId(),
                address(this)
            )
        );
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
        require(recoveredAddress != address(0) && recoveredAddress == signer, "Arch::validateSig: invalid signature");
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "Arch::_approve: approve from the zero address");
        require(spender != address(0), "Arch::_approve: approve to the zero address");
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _increaseAllowance(
        address owner,
        address spender,
        uint256 addedValue
    ) internal {

        _approve(owner, spender, allowances[owner][spender].add(addedValue));
    }

    function _decreaseAllowance(
        address owner,
        address spender,
        uint256 subtractedValue
    ) internal {

        _approve(
            owner,
            spender,
            allowances[owner][spender].sub(
                subtractedValue,
                "Arch::_decreaseAllowance: decreased allowance below zero"
            )
        );
    }

    function _transferTokens(address from, address to, uint256 value) internal {

        require(to != address(0), "Arch::_transferTokens: cannot transfer to the zero address");

        balances[from] = balances[from].sub(
            value,
            "Arch::_transferTokens: transfer exceeds from balance"
        );
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address to, uint256 value) internal {

        totalSupply = totalSupply.add(value);
        balances[to] = balances[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {

        balances[from] = balances[from].sub(
            value,
            "Arch::_burn: burn amount exceeds from balance"
        );
        totalSupply = totalSupply.sub(
            value,
            "Arch::_burn: burn amount exceeds total supply"
        );
        emit Transfer(from, address(0), value);
    }

    function _getChainId() internal pure returns (uint) {

        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}