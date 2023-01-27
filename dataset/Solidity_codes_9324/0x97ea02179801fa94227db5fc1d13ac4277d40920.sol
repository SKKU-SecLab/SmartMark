


pragma solidity 0.4.24;


contract Restricted {


    mapping (address => mapping (bytes32 => bool)) public permissions;

    event PermissionGranted(address indexed agent, bytes32 grantedPermission);
    event PermissionRevoked(address indexed agent, bytes32 revokedPermission);

    modifier restrict(bytes32 requiredPermission) {

        require(permissions[msg.sender][requiredPermission], "msg.sender must have permission");
        _;
    }

    constructor(address permissionGranterContract) public {
        require(permissionGranterContract != address(0), "permissionGranterContract must be set");
        permissions[permissionGranterContract]["PermissionGranter"] = true;
        emit PermissionGranted(permissionGranterContract, "PermissionGranter");
    }

    function grantPermission(address agent, bytes32 requiredPermission) public {

        require(permissions[msg.sender]["PermissionGranter"],
            "msg.sender must have PermissionGranter permission");
        permissions[agent][requiredPermission] = true;
        emit PermissionGranted(agent, requiredPermission);
    }

    function grantMultiplePermissions(address agent, bytes32[] requiredPermissions) public {

        require(permissions[msg.sender]["PermissionGranter"],
            "msg.sender must have PermissionGranter permission");
        uint256 length = requiredPermissions.length;
        for (uint256 i = 0; i < length; i++) {
            grantPermission(agent, requiredPermissions[i]);
        }
    }

    function revokePermission(address agent, bytes32 requiredPermission) public {

        require(permissions[msg.sender]["PermissionGranter"],
            "msg.sender must have PermissionGranter permission");
        permissions[agent][requiredPermission] = false;
        emit PermissionRevoked(agent, requiredPermission);
    }

    function revokeMultiplePermissions(address agent, bytes32[] requiredPermissions) public {

        uint256 length = requiredPermissions.length;
        for (uint256 i = 0; i < length; i++) {
            revokePermission(agent, requiredPermissions[i]);
        }
    }

}


pragma solidity 0.4.24;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        require(a == 0 || c / a == b, "mul overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "sub underflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "add overflow");
        return c;
    }

    function roundedDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason
        uint256 halfB = (b % 2 == 0) ? (b / 2) : (b / 2 + 1);
        return (a % b >= halfB) ? (a / b + 1) : (a / b);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason
        return (a % b != 0) ? (a / b + 1) : (a / b);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? b : a;
    }    
}



pragma solidity 0.4.24;




contract PreToken is Restricted {

    using SafeMath for uint256;

    string constant public name = "Augmint pretokens"; // solhint-disable-line const-name-snakecase
    string constant public symbol = "APRE"; // solhint-disable-line const-name-snakecase
    uint8 constant public decimals = 0; // solhint-disable-line const-name-snakecase

    uint public totalSupply;

    struct Agreement {
        address owner;
        uint balance;
        uint32 discount; //  discountRate in parts per million , ie. 10,000 = 1%
        uint32 valuationCap; // in USD (no decimals)
    }

    mapping(address => bytes32) public agreementOwners; // to lookup agrement by owner
    mapping(bytes32 => Agreement) public agreements;

    bytes32[] public allAgreements; // all agreements to able to iterate over

    event Transfer(address indexed from, address indexed to, uint amount);

    event NewAgreement(address owner, bytes32 agreementHash, uint32 discount, uint32 valuationCap);

    constructor(address permissionGranterContract)
    public Restricted(permissionGranterContract) {} // solhint-disable-line no-empty-blocks

    function addAgreement(address owner, bytes32 agreementHash, uint32 discount, uint32 valuationCap)
    external restrict("PreTokenSigner") {

        require(owner != address(0), "owner must not be 0x0");
        require(agreementOwners[owner] == 0x0, "owner must not have an aggrement yet");
        require(agreementHash != 0x0, "agreementHash must not be 0x0");
        require(discount > 0, "discount must be > 0");
        require(agreements[agreementHash].discount == 0, "agreement must not exist yet");

        agreements[agreementHash] = Agreement(owner, 0, discount, valuationCap);
        agreementOwners[owner] = agreementHash;
        allAgreements.push(agreementHash);

        emit NewAgreement(owner, agreementHash, discount, valuationCap);
    }

    function issueTo(bytes32 agreementHash, uint amount) external restrict("PreTokenSigner") {

        Agreement storage agreement = agreements[agreementHash];
        require(agreement.discount > 0, "agreement must exist");

        agreement.balance = agreement.balance.add(amount);
        totalSupply = totalSupply.add(amount);

        emit Transfer(0x0, agreement.owner, amount);
    }

    function burnFrom(bytes32 agreementHash, uint amount)
    public restrict("PreTokenSigner") returns (bool) {

        Agreement storage agreement = agreements[agreementHash];
        require(agreement.discount > 0, "agreement must exist");
        require(amount > 0, "burn amount must be > 0");
        require(agreement.balance >= amount, "must not burn more than balance");

        agreement.balance = agreement.balance.sub(amount);
        totalSupply = totalSupply.sub(amount);

        emit Transfer(agreement.owner, 0x0, amount);
        return true;
    }

    function balanceOf(address owner) public view returns (uint) {

        return agreements[agreementOwners[owner]].balance;
    }

    function transfer(address to, uint amount) public returns (bool) { // solhint-disable-line no-simple-event-func-name

        require(amount == agreements[agreementOwners[msg.sender]].balance, "must transfer full balance");
        _transfer(msg.sender, to);
        return true;
    }

    function transferAgreement(bytes32 agreementHash, address to)
    public restrict("PreTokenSigner") returns (bool) {

        _transfer(agreements[agreementHash].owner, to);
        return true;
    }

    function _transfer(address from, address to) private {

        Agreement storage agreement = agreements[agreementOwners[from]];
        require(agreementOwners[from] != 0x0, "from agreement must exists");
        require(agreementOwners[to] == 0, "to must not have an agreement");
        require(to != 0x0, "must not transfer to 0x0");

        agreement.owner = to;

        agreementOwners[to] = agreementOwners[from];
        agreementOwners[from] = 0x0;

        emit Transfer(from, to, agreement.balance);
    }

    function getAgreementsCount() external view returns (uint agreementsCount) {

        return allAgreements.length;
    }

    function getAgreements(uint offset, uint16 chunkSize)
    external view returns(uint[6][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), allAgreements.length);
        uint[6][] memory response = new uint[6][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {
            bytes32 agreementHash = allAgreements[i];
            Agreement storage agreement = agreements[agreementHash];

            response[i - offset] = [i, uint(agreement.owner), agreement.balance,
                uint(agreementHash), uint(agreement.discount), uint(agreement.valuationCap)];
        }
        return response;
    }
}