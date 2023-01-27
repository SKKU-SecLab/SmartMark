
pragma solidity >=0.8.4;

interface IPRBProxy {


    event Execute(address indexed target, bytes data, bytes response);

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);


    function getPermission(
        address envoy,
        address target,
        bytes4 selector
    ) external view returns (bool);


    function owner() external view returns (address);


    function minGasReserve() external view returns (uint256);



    function execute(address target, bytes calldata data) external payable returns (bytes memory response);


    function setPermission(
        address envoy,
        address target,
        bytes4 selector,
        bool permission
    ) external;


    function transferOwnership(address newOwner) external;

}
interface IPRBProxyFactory {


    event DeployProxy(
        address indexed origin,
        address indexed deployer,
        address indexed owner,
        bytes32 seed,
        bytes32 salt,
        address proxy
    );


    function getNextSeed(address eoa) external view returns (bytes32 result);


    function isProxy(address proxy) external view returns (bool result);


    function version() external view returns (uint256);



    function deploy() external returns (address payable proxy);


    function deployFor(address owner) external returns (address payable proxy);

}












interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}





abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)






interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}
error PRBProxy__ExecutionNotAuthorized(address owner, address caller, address target, bytes4 selector);

error PRBProxy__ExecutionReverted();

error PRBProxy__NotOwner(address owner, address caller);

error PRBProxy__OwnerChanged(address originalOwner, address newOwner);

error PRBProxy__TargetInvalid(address target);

contract PRBProxy is IPRBProxy, ERC1155Holder, ERC721Holder {


    address public override owner;

    uint256 public override minGasReserve;


    mapping(address => mapping(address => mapping(bytes4 => bool))) internal permissions;


    constructor() {
        minGasReserve = 5_000;
        owner = msg.sender;
        emit TransferOwnership(address(0), msg.sender);
    }


    receive() external payable {}


    function getPermission(
        address envoy,
        address target,
        bytes4 selector
    ) external view override returns (bool) {

        return permissions[envoy][target][selector];
    }


    function execute(address target, bytes calldata data) external payable override returns (bytes memory response) {

        if (owner != msg.sender) {
            bytes4 selector;
            assembly {
                selector := calldataload(data.offset)
            }
            if (!permissions[msg.sender][target][selector]) {
                revert PRBProxy__ExecutionNotAuthorized(owner, msg.sender, target, selector);
            }
        }

        if (target.code.length == 0) {
            revert PRBProxy__TargetInvalid(target);
        }

        address owner_ = owner;

        uint256 stipend = gasleft() - minGasReserve;

        bool success;
        (success, response) = target.delegatecall{ gas: stipend }(data);

        if (owner_ != owner) {
            revert PRBProxy__OwnerChanged(owner_, owner);
        }

        emit Execute(target, data, response);

        if (!success) {
            if (response.length > 0) {
                assembly {
                    let returndata_size := mload(response)
                    revert(add(32, response), returndata_size)
                }
            } else {
                revert PRBProxy__ExecutionReverted();
            }
        }
    }

    function setPermission(
        address envoy,
        address target,
        bytes4 selector,
        bool permission
    ) external override {

        if (owner != msg.sender) {
            revert PRBProxy__NotOwner(owner, msg.sender);
        }
        permissions[envoy][target][selector] = permission;
    }

    function transferOwnership(address newOwner) external override {

        address oldOwner = owner;
        if (oldOwner != msg.sender) {
            revert PRBProxy__NotOwner(oldOwner, msg.sender);
        }
        owner = newOwner;
        emit TransferOwnership(oldOwner, newOwner);
    }
}

contract PRBProxyFactory is IPRBProxyFactory {


    uint256 public constant override version = 2;


    mapping(address => bool) internal proxies;

    mapping(address => bytes32) internal nextSeeds;


    function getNextSeed(address eoa) external view override returns (bytes32 nextSeed) {

        nextSeed = nextSeeds[eoa];
    }

    function isProxy(address proxy) external view override returns (bool result) {

        result = proxies[proxy];
    }


    function deploy() external override returns (address payable proxy) {

        proxy = deployFor(msg.sender);
    }

    function deployFor(address owner) public override returns (address payable proxy) {

        bytes32 seed = nextSeeds[tx.origin];

        bytes32 salt = keccak256(abi.encode(tx.origin, seed));

        proxy = payable(new PRBProxy{ salt: salt }());

        IPRBProxy(proxy).transferOwnership(owner);

        proxies[proxy] = true;

        unchecked {
            nextSeeds[tx.origin] = bytes32(uint256(seed) + 1);
        }

        emit DeployProxy(tx.origin, msg.sender, owner, seed, salt, address(proxy));
    }
}