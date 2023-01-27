

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64) {

        uint64 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {

        require(b <= a, errorMessage);
        uint64 c = a - b;

        return c;
    }

    function mul(uint64 a, uint64 b) internal pure returns (uint64) {

        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



pragma solidity 0.5.7;


contract IMemberRoles {


    event MemberRole(uint256 indexed roleId, bytes32 roleName, string roleDescription);
    
    enum Role {UnAssigned, AdvisoryBoard, TokenHolder, DisputeResolution}

    function setInititorAddress(address _initiator) external;


    function addRole(bytes32 _roleName, string memory _roleDescription, address _authorized) public;


    function updateRole(address _memberAddress, uint _roleId, bool _active) public;


    function changeAuthorized(uint _roleId, address _authorized) public;


    function totalRoles() public view returns(uint256);


    function members(uint _memberRoleId) public view returns(uint, address[] memory allMemberAddress);


    function numberOfMembers(uint _memberRoleId) public view returns(uint);

    
    function authorized(uint _memberRoleId) public view returns(address);


    function roles(address _memberAddress) public view returns(uint[] memory assignedRoles);


    function checkRole(address _memberAddress, uint _roleId) public view returns(bool);   

}



pragma solidity 0.5.7;


contract IMaster {

    mapping(address => bool) public whitelistedSponsor;
    function dAppToken() public view returns(address);

    function isInternal(address _address) public view returns(bool);

    function getLatestAddress(bytes2 _module) public view returns(address);

    function isAuthorizedToGovern(address _toCheck) public view returns(bool);

}


contract Governed {


    address public masterAddress; // Name of the dApp, needs to be set by contracts inheriting this contract

    modifier onlyAuthorizedToGovern() {

        IMaster ms = IMaster(masterAddress);
        require(ms.getLatestAddress("GV") == msg.sender, "Not authorized");
        _;
    }

    function isAuthorizedToGovern(address _toCheck) public view returns(bool) {

        IMaster ms = IMaster(masterAddress);
        return (ms.getLatestAddress("GV") == _toCheck);
    } 

}


pragma solidity 0.5.7;


contract Proxy {

    function () external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
            }
    }

    function implementation() public view returns (address);

}


pragma solidity 0.5.7;



contract UpgradeabilityProxy is Proxy {

    event Upgraded(address indexed implementation);

    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.govblocks.proxy.implementation");

    constructor() public {}

    function implementation() public view returns (address impl) {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    function _setImplementation(address _newImplementation) internal {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
        sstore(position, _newImplementation)
        }
    }

    function _upgradeTo(address _newImplementation) internal {

        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation);
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }
}


pragma solidity 0.5.7;



contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");

    constructor(address _implementation) public {
        _setUpgradeabilityOwner(msg.sender);
        _upgradeTo(_implementation);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address owner) {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {

        require(_newOwner != address(0));
        _setUpgradeabilityOwner(_newOwner);
        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
    }

    function upgradeTo(address _implementation) public onlyProxyOwner {

        _upgradeTo(_implementation);
    }

    function _setUpgradeabilityOwner(address _newProxyOwner) internal {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }
}


pragma solidity 0.5.7;

contract Iupgradable {


    function setMasterAddress() public;

}


pragma solidity 0.5.7;

contract ITokenController {

	address public token;
    address public bLOTToken;

    function swapBLOT(address _of, address _to, uint256 amount) public;


    function totalBalanceOf(address _of)
        public
        view
        returns (uint256 amount);


    function transferFrom(address _token, address _of, address _to, uint256 amount) public;


    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount);


    function burnCommissionTokens(uint256 amount) external returns(bool);

 
    function initiateVesting(address _vesting) external;


    function lockForGovernanceVote(address _of, uint _days) public;


    function totalSupply() public view returns (uint256);


    function mint(address _member, uint _amount) public;


}



pragma solidity 0.5.7;







contract MemberRoles is IMemberRoles, Governed, Iupgradable {


    using SafeMath for uint256;

    ITokenController internal tokenController;
    struct MemberRoleDetails {
        uint256 memberCounter;
        mapping(address => uint256) memberIndex;
        address[] memberAddress;
        address authorized;
    }

    MemberRoleDetails[] internal memberRoleData;
    bool internal constructorCheck;
    address internal initiator;
    uint256 internal minLockAmountForDR;
    uint256 internal lockTimeForDR;

    modifier checkRoleAuthority(uint256 _memberRoleId) {

        if (memberRoleData[_memberRoleId].authorized != address(0))
            require(
                msg.sender == memberRoleData[_memberRoleId].authorized,
                "Not authorized"
            );
        else require(isAuthorizedToGovern(msg.sender), "Not Authorized");
        _;
    }

    function swapABMember(address _newABAddress, address _removeAB)
        external
        checkRoleAuthority(uint256(Role.AdvisoryBoard))
    {

        _updateRole(_newABAddress, uint256(Role.AdvisoryBoard), true);
        _updateRole(_removeAB, uint256(Role.AdvisoryBoard), false);
    }

    function setMasterAddress() public {

        OwnedUpgradeabilityProxy proxy = OwnedUpgradeabilityProxy(
            address(uint160(address(this)))
        );
        require(msg.sender == proxy.proxyOwner(), "Sender is not proxy owner.");

        require(masterAddress == address(0), "Master address already set");
        masterAddress = msg.sender;
        IMaster masterInstance = IMaster(masterAddress);
        tokenController = ITokenController(
            masterInstance.getLatestAddress("TC")
        );
        minLockAmountForDR = 500 ether;
        lockTimeForDR = 15 days;
    }

    function setInititorAddress(address _initiator) external {

        OwnedUpgradeabilityProxy proxy = OwnedUpgradeabilityProxy(
            address(uint160(address(this)))
        );
        require(msg.sender == proxy.proxyOwner(), "Sender is not proxy owner.");
        require(initiator == address(0), "Already Set");
        initiator = _initiator;
    }

    function memberRolesInitiate(
        address[] calldata _abArray
    ) external {

        require(msg.sender == initiator);
        require(!constructorCheck, "Already constructed");
        _addInitialMemberRoles();
        for (uint256 i = 0; i < _abArray.length; i++) {
            _updateRole(_abArray[i], uint256(Role.AdvisoryBoard), true);
        }
        constructorCheck = true;
    }

    function addRole(
        bytes32 _roleName,
        string memory _roleDescription,
        address _authorized
    ) public onlyAuthorizedToGovern {

        _addRole(_roleName, _roleDescription, _authorized);
    }

    function updateRole(
        address _memberAddress,
        uint256 _roleId,
        bool _active
    ) public checkRoleAuthority(_roleId) {

        _updateRole(_memberAddress, _roleId, _active);
    }

    function totalRoles() public view returns (uint256) {

        return memberRoleData.length;
    }

    function changeAuthorized(uint256 _roleId, address _newAuthorized)
        public
        checkRoleAuthority(_roleId)
    {

        memberRoleData[_roleId].authorized = _newAuthorized;
    }

    function members(uint256 _memberRoleId)
        public
        view
        returns (uint256, address[] memory memberArray)
    {

        return (_memberRoleId, memberRoleData[_memberRoleId].memberAddress);
    }

    function numberOfMembers(uint256 _memberRoleId)
        public
        view
        returns (uint256)
    {

        return memberRoleData[_memberRoleId].memberCounter;
    }

    function authorized(uint256 _memberRoleId) public view returns (address) {

        return memberRoleData[_memberRoleId].authorized;
    }

    function roles(address _memberAddress)
        public
        view
        returns (uint256[] memory)
    {

        uint256 length = memberRoleData.length;
        uint256[] memory assignedRoles = new uint256[](length);
        uint256 counter = 0;
        for (uint256 i = 1; i < length; i++) {
            if (memberRoleData[i].memberIndex[_memberAddress] > 0) {
                assignedRoles[counter] = i;
                counter++;
            }
        }
        if (tokenController.totalBalanceOf(_memberAddress) > 0) {
            assignedRoles[counter] = uint256(Role.TokenHolder);
            counter++;
        }
        if (tokenController.tokensLockedAtTime(_memberAddress, "DR", (lockTimeForDR).add(now)) >= minLockAmountForDR) {
            assignedRoles[counter] = uint256(Role.DisputeResolution);
        }
        return assignedRoles;
    }

    function updateUintParameters(bytes8 code, uint val) public onlyAuthorizedToGovern {

        if(code == "MNLOCKDR") { //Minimum lock amount to consider user as DR member
            minLockAmountForDR = val;
        } else if (code == "TLOCDR") { // Lock period required for DR
            lockTimeForDR = val * (1 days);
        } 
    }

    function getUintParameters(bytes8 code) external view returns(bytes8 codeVal, uint val) {

        codeVal = code;
        if(code == "MNLOCKDR") {
            val = minLockAmountForDR;
        } else if (code == "TLOCDR") { // Lock period required for DR
            val = lockTimeForDR / (1 days);
        } 
    }


    function checkRole(address _memberAddress, uint256 _roleId)
        public
        view
        returns (bool)
    {

        if (_roleId == uint256(Role.UnAssigned)) {
            return true;
        } else if (_roleId == uint256(Role.TokenHolder)) {
            if (tokenController.totalBalanceOf(_memberAddress) > 0) {
                return true;
            }
        } else if (_roleId == uint256(Role.DisputeResolution)) {
            if (tokenController.tokensLockedAtTime(_memberAddress, "DR", (lockTimeForDR).add(now)) >= minLockAmountForDR) {
                return true;
            }
        } else if (memberRoleData[_roleId].memberIndex[_memberAddress] > 0) {
            return true;
        }
        return false;
    }

    function getMemberLengthForAllRoles()
        public
        view
        returns (uint256[] memory totalMembers)
    {

        totalMembers = new uint256[](memberRoleData.length);
        for (uint256 i = 0; i < memberRoleData.length; i++) {
            totalMembers[i] = numberOfMembers(i);
        }
    }

    function _updateRole(
        address _memberAddress,
        uint256 _roleId,
        bool _active
    ) internal {

        require(
            _roleId != uint256(Role.TokenHolder) && _roleId != uint256(Role.DisputeResolution),
            "Membership to this role is detected automatically"
        );
        if (_active) {
            require(
                memberRoleData[_roleId].memberIndex[_memberAddress] == 0,
                "already active"
            );

            memberRoleData[_roleId].memberCounter = SafeMath.add(
                memberRoleData[_roleId].memberCounter,
                1
            );
            memberRoleData[_roleId]
                .memberIndex[_memberAddress] = memberRoleData[_roleId]
                .memberAddress
                .length;
            memberRoleData[_roleId].memberAddress.push(_memberAddress);
        } else {
            require(
                memberRoleData[_roleId].memberIndex[_memberAddress] > 0,
                "not active"
            );
            uint256 _memberIndex = memberRoleData[_roleId]
                .memberIndex[_memberAddress];
            address _topElement = memberRoleData[_roleId]
                .memberAddress[memberRoleData[_roleId].memberCounter];
            memberRoleData[_roleId].memberIndex[_topElement] = _memberIndex;
            memberRoleData[_roleId].memberCounter = SafeMath.sub(
                memberRoleData[_roleId].memberCounter,
                1
            );
            memberRoleData[_roleId].memberAddress[_memberIndex] = _topElement;
            memberRoleData[_roleId].memberAddress.length--;
            delete memberRoleData[_roleId].memberIndex[_memberAddress];
        }
    }

    function _addRole(
        bytes32 _roleName,
        string memory _roleDescription,
        address _authorized
    ) internal {

        emit MemberRole(memberRoleData.length, _roleName, _roleDescription);
        memberRoleData.push(
            MemberRoleDetails(0, new address[](1), _authorized)
        );
    }

    function _addInitialMemberRoles() internal {

        _addRole("Unassigned", "Unassigned", address(0));
        _addRole(
            "Advisory Board",
            "Selected few members that are deeply entrusted by the dApp. An ideal advisory board should be a mix of skills of domain, governance, research, technology, consulting etc to improve the performance of the dApp.", //solhint-disable-line
            address(0)
        );
        _addRole(
            "Token Holder",
            "Represents all users who hold dApp tokens. This is the most general category and anyone holding token balance is a part of this category by default.", //solhint-disable-line
            address(0)
        );
        _addRole(
            "DisputeResolution",
            "Represents members who are assigned to vote on resolving disputes", //solhint-disable-line
            address(0)
        );
    }
}