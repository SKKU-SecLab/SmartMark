
pragma solidity 0.8.10;

contract MirrorProxy {

    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address implementation, bytes memory initializationData) {
        (bool ok, ) = implementation.delegatecall(initializationData);

        if (!ok) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        assembly {
            sstore(_IMPLEMENTATION_SLOT, implementation)
        }
    }

    fallback() external payable {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(
                gas(),
                sload(_IMPLEMENTATION_SLOT),
                ptr,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
}

interface IOwnableEvents {

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}

interface IMirrorAllocatedEditionsFactory {

    function deploy(
        IMirrorAllocatedEditionsLogic.NFTMetadata memory metadata,
        address operator_,
        address payable fundingRecipient_,
        address payable royaltyRecipient_,
        uint256 royaltyPercentage_,
        uint256 price,
        bool list,
        bool open,
        uint256 feePercentage
    ) external returns (address proxy);

}

interface IMirrorAllocatedEditionsFactoryEvents {

    event EditionsProxyDeployed(address proxy, address operator, address logic);
}

interface IMirrorAllocatedEditionsLogic {

    event RoyaltyChange(
        address indexed oldRoyaltyRecipient,
        uint256 oldRoyaltyPercentage,
        address indexed newRoyaltyRecipient,
        uint256 newRoyaltyPercentage
    );

    struct NFTMetadata {
        string name;
        string symbol;
        string baseURI;
        bytes32 contentHash;
        uint256 quantity;
    }

    function initialize(
        NFTMetadata memory metadata,
        address operator_,
        address payable fundingRecipient_,
        address payable royaltyRecipient_,
        uint256 royaltyPercentage_,
        uint256 price,
        bool list,
        bool open,
        uint256 feePercentage
    ) external;


    function setRoyaltyInfo(
        address payable royaltyRecipient_,
        uint256 royaltyPercentage_
    ) external;

}

interface IMirrorOpenSaleV0Events {

    event RegisteredSale(
        bytes32 h,
        address indexed token,
        uint256 startTokenId,
        uint256 endTokenId,
        address indexed operator,
        address indexed recipient,
        uint256 price,
        bool open,
        uint256 feePercentage
    );

    event Purchase(
        bytes32 h,
        address indexed token,
        uint256 tokenId,
        address indexed buyer,
        address indexed recipient
    );

    event Withdraw(
        bytes32 h,
        uint256 amount,
        uint256 fee,
        address indexed recipient
    );

    event OpenSale(bytes32 h);

    event CloseSale(bytes32 h);
}

interface IERC2309 {

    event ConsecutiveTransfer(
        uint256 indexed fromTokenId,
        uint256 toTokenId,
        address indexed fromAddress,
        address indexed toAddress
    );
}

interface IERC721Events {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
}

contract MirrorAllocatedEditionsFactory is
    IMirrorAllocatedEditionsFactory,
    IMirrorAllocatedEditionsFactoryEvents,
    IMirrorOpenSaleV0Events,
    IERC2309,
    IOwnableEvents,
    IERC721Events
{

    address public immutable tributaryRegistry;

    address public logic;

    constructor(address tributaryRegistry_, address logic_) {
        tributaryRegistry = tributaryRegistry_;
        logic = logic_;
    }


    function deploy(
        IMirrorAllocatedEditionsLogic.NFTMetadata memory metadata,
        address operator_,
        address payable fundingRecipient_,
        address payable royaltyRecipient_,
        uint256 royaltyPercentage_,
        uint256 price,
        bool list,
        bool open,
        uint256 feePercentage
    ) external override returns (address proxy) {

        bytes memory initializationData = abi.encodeWithSelector(
            IMirrorAllocatedEditionsLogic.initialize.selector,
            metadata,
            operator_,
            fundingRecipient_,
            royaltyRecipient_,
            royaltyPercentage_,
            price,
            list,
            open,
            feePercentage
        );

        proxy = address(
            new MirrorProxy{
                salt: keccak256(
                    abi.encode(
                        operator_,
                        metadata.name,
                        metadata.symbol,
                        metadata.baseURI
                    )
                )
            }(logic, initializationData)
        );

        emit EditionsProxyDeployed(proxy, operator_, logic);
    }
}