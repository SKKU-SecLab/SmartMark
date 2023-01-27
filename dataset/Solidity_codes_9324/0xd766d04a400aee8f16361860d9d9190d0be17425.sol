
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT
pragma solidity 0.7.6;



library CloneLibrary {


    function createClone(address target) internal returns (address result) {

        bytes memory cloneBuffer = new bytes(72);
        assembly {
            let clone := add(cloneBuffer, 32)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), shl(96, target))
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }


    function isClone(address target, address query) internal view returns (bool result) {

        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), shl(96, target))
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}// MIT
pragma solidity ^0.7.6;



contract AlchemyFactory {

    using CloneLibrary for address;

    event NewAlchemy(address alchemy, address governor, address timelock);

    address payable public factoryOwner;
    address payable public alchemyRouter;
    address public alchemyImplementation;
    address public governorAlphaImplementation;
    address public timelockImplementation;

    constructor(
        address _alchemyImplementation,
        address _governorAlphaImplementation,
        address _timelockImplementation,
        address payable _alchemyRouter
    )
    {
        factoryOwner = msg.sender;
        alchemyImplementation = _alchemyImplementation;
        governorAlphaImplementation = _governorAlphaImplementation;
        timelockImplementation = _timelockImplementation;
        alchemyRouter =_alchemyRouter;
    }

    function NFTDAOMint(
        IERC721[] memory nftAddresses_,
        address owner_,
        uint256[] memory tokenIds_,
        uint256 totalSupply_,
        string memory name_,
        string memory symbol_,
        uint256 buyoutPrice_,
        uint256 votingPeriod_,
        uint256 timelockDelay_
    ) external returns (address alchemy, address governor, address timelock) {

        alchemy = alchemyImplementation.createClone();
        governor = governorAlphaImplementation.createClone();
        timelock = timelockImplementation.createClone();

        emit NewAlchemy(alchemy, governor, timelock);

        for (uint i = 0; i < nftAddresses_.length; i++) {
            nftAddresses_[i].transferFrom(msg.sender, alchemy, tokenIds_[i]);
        }

        IGovernorAlpha(governor).initialize(
            alchemy,
            timelock,
            totalSupply_,
            votingPeriod_
        );

        ITimelock(timelock).initialize(governor, timelockDelay_);

        IAlchemy(alchemy).initialize(
            nftAddresses_,
            owner_,
            tokenIds_,
            totalSupply_,
            name_,
            symbol_,
            buyoutPrice_,
            address(this),
            governor,
            timelock
        );
    }

    function newFactoryOwner(address payable newOwner) external {

        require(msg.sender == factoryOwner, "Only owner");
        factoryOwner = newOwner;
    }

    function newAlchemyImplementation(address newAlchemyImplementation_) external {

        require(msg.sender == factoryOwner, "Only owner");
        alchemyImplementation = newAlchemyImplementation_;
    }

    function newGovernorAlphaImplementation(address newGovernorAlphaImplementation_) external {

        require(msg.sender == factoryOwner, "Only owner");
        governorAlphaImplementation = newGovernorAlphaImplementation_;
    }

    function newTimelockImplementation(address newTimelockImplementation_) external {

        require(msg.sender == factoryOwner, "Only owner");
        timelockImplementation = newTimelockImplementation_;
    }

    function newAlchemyRouter(address payable newRouter) external {

        require(msg.sender == factoryOwner, "Only owner");
        alchemyRouter = newRouter;
    }

    function getAlchemyRouter() public view returns (address payable) {

        return alchemyRouter;
    }
}


interface IAlchemy {

    function initialize(
        IERC721[] memory nftAddresses_,
        address owner_,
        uint256[] memory tokenIds_,
        uint256 totalSupply_,
        string memory name_,
        string memory symbol_,
        uint256 buyoutPrice_,
        address factoryContract,
        address governor_,
        address timelock_
    ) external;

}


interface IGovernorAlpha {

    function initialize(
        address nft_,
        address timelock_,
        uint supply_,
        uint votingPeriod_
    ) external;

}


interface ITimelock {

    function initialize(address admin_, uint delay_) external;

}