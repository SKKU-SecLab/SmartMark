
pragma solidity >=0.8.4;

interface IKaliShareManager {

    function mintShares(address to, uint256 amount) external payable;


    function burnShares(address from, uint256 amount) external payable;

}

abstract contract ReentrancyGuard {
    error Reentrancy();
    
    uint256 private locked = 1;

    modifier nonReentrant() {
        if (locked != 1) revert Reentrancy();
        
        locked = 2;
        _;
        locked = 1;
    }
}

contract KaliShareManager is ReentrancyGuard {


    event ExtensionSet(address indexed dao, address[] managers, bool[] approvals);
    event ExtensionCalled(address indexed dao, address indexed manager, Update[] updates);


    error NoArrayParity();
    error Forbidden();


    mapping(address => mapping(address => bool)) public management;

    struct Update {
        address account;
        uint256 amount;
        bool mint;
    }


    function setExtension(bytes calldata extensionData) external {

        (
            address[] memory managers, 
            bool[] memory approvals
        ) 
            = abi.decode(extensionData, (address[], bool[]));
        
        if (managers.length != approvals.length) revert NoArrayParity();

        for (uint256 i; i < managers.length; ) {
            management[msg.sender][managers[i]] = approvals[i];
            unchecked {
                ++i;
            }
        }

        emit ExtensionSet(msg.sender, managers, approvals);
    }


    function callExtension(address dao, Update[] calldata updates) external nonReentrant {

        if (!management[dao][msg.sender]) revert Forbidden();

        for (uint256 i; i < updates.length; ) {
            if (updates[i].mint) {
                IKaliShareManager(dao).mintShares(updates[i].account, updates[i].amount);
            } else {
                IKaliShareManager(dao).burnShares(updates[i].account, updates[i].amount);
            }
            unchecked {
                ++i;
            }
        }

        emit ExtensionCalled(dao, msg.sender, updates);
    }
}