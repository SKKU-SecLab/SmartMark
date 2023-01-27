
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity ^0.8.12;


interface IFancyBears is IERC721, IERC721Enumerable {


    function tokensInWallet(address _owner) external view returns(uint256[] memory);


}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT
pragma solidity ^0.8.12;


abstract contract IFancyBearTraits is IERC1155 {

    mapping(string => bool) public categoryValidation;
    uint256 public categoryPointer;
    string[] public categories;
    function getTrait(uint256 _tokenId) public virtual returns (string memory, string memory, uint256);
    function getCategories() public virtual returns (string[] memory);
    function mint(address _account, uint256 _id, uint256 _amount, bytes memory _data) public virtual;
    function mintBatch(address _account, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) public virtual;
}// MIT
pragma solidity ^0.8.12;

abstract contract IFancyBearHoneyConsumption {

    mapping(uint256 => uint256) public honeyConsumed;
    function consumeHoney(uint256 _tokenId, uint256 _honeyAmount) public virtual;
    
}// MIT
pragma solidity ^0.8.12;


contract FancyTraitStaking is ERC1155Holder {

    
    using SafeMath for uint256;
    using Address for address;

    IFancyBears fancyBearsContract;
    IFancyBearTraits fancyTraitContract;
    IFancyBearHoneyConsumption fancyBearHoneyConsumptionContract;

    mapping(uint256 => mapping(string => uint256))
        public stakedTraitsByCategoryByFancyBear;

    event TraitStaked(
        uint256 indexed _fancyBear,
        uint256 _traitId,
        string category,
        address _address
    );
    event TraitUnstaked(
        uint256 indexed _fancyBear,
        uint256 _traitId,
        string category,
        address _address
    );
    event TraitSwapped(
        uint256 indexed _fancyBear,
        string category,
        uint256 _oldTrait,
        uint256 _newTriat
    );

    constructor(
        IFancyBears _fancyBearsContract,
        IFancyBearTraits _fancyTraitContract,
        IFancyBearHoneyConsumption _fancyBearHoneyConsumptionContract
    ) {
        fancyBearsContract = _fancyBearsContract;
        fancyTraitContract = _fancyTraitContract;
        fancyBearHoneyConsumptionContract = _fancyBearHoneyConsumptionContract;
    }

    function stakeTraits(uint256 _fancyBear, uint256[] calldata _traitIds) public {


        require(
            fancyBearsContract.ownerOf(_fancyBear) == msg.sender,
            "stakeTraits: caller does not own fancy bear"
        );

        string memory category;
        uint256 honeyConsumptionRequirement;

        for (uint256 i = 0; i < _traitIds.length; i++) {

            require(
                fancyTraitContract.balanceOf(msg.sender, _traitIds[i]) > 0,
                "stakeTraits: caller does not own trait"
            );

            (, category, honeyConsumptionRequirement) = fancyTraitContract.getTrait(_traitIds[i]);

            require(
                fancyBearHoneyConsumptionContract.honeyConsumed(_fancyBear) >=
                    honeyConsumptionRequirement,
                "stakeTraits: fancy bear has not consumed enough honey"
            );

            uint256 currentTrait = stakedTraitsByCategoryByFancyBear[_fancyBear][category];

            if (currentTrait != 0) {

                fancyTraitContract.safeTransferFrom(
                    address(this),
                    msg.sender,
                    stakedTraitsByCategoryByFancyBear[_fancyBear][category],
                    1,
                    ""
                );
                
                delete (
                    stakedTraitsByCategoryByFancyBear[_fancyBear][category]
                );
            }

            fancyTraitContract.safeTransferFrom(
                msg.sender,
                address(this),
                _traitIds[i],
                1,
                ""
            );

            stakedTraitsByCategoryByFancyBear[_fancyBear][category] = _traitIds[i];

            if (currentTrait == 0) {
                emit TraitStaked(_fancyBear, _traitIds[i], category, msg.sender);
            }
            else {
                emit TraitSwapped(
                    _fancyBear,
                    category,
                    currentTrait,
                    _traitIds[i]
                );
            }
        }
    }

    function unstakeTraits(
        uint256 _fancyBear,
        string[] calldata _categoriesToUnstake
    ) public {

        require(
            fancyBearsContract.ownerOf(_fancyBear) == msg.sender,
            "unstakeTraits: caller does not own fancy bear"
        );

        uint256 trait;

        for (uint256 i = 0; i < _categoriesToUnstake.length; i++) {
            require(
                fancyTraitContract.categoryValidation(_categoriesToUnstake[i]),
                "unstakeTraits: invalid trait category"
            );

            trait = stakedTraitsByCategoryByFancyBear[_fancyBear][_categoriesToUnstake[i]];

            require(trait != 0, "unstakeTraits: no trait staked in category");

            fancyTraitContract.safeTransferFrom(
                address(this),
                msg.sender,
                trait,
                1,
                ""
            );
            delete (stakedTraitsByCategoryByFancyBear[_fancyBear][_categoriesToUnstake[i]]);

            emit TraitUnstaked(
                _fancyBear,
                trait,
                _categoriesToUnstake[i],
                msg.sender
            );
        }
    }

    function getStakedTraits(uint256 _fancyBear)
        public
        view
        returns (uint256[] memory, string[] memory)
    {

        uint256[] memory traitArray = new uint256[](fancyTraitContract.categoryPointer());
        string[] memory categories = new string[](fancyTraitContract.categoryPointer());

        for (uint256 i = 0; i < traitArray.length; i++) {
            categories[i] = fancyTraitContract.categories(i);
            traitArray[i] = stakedTraitsByCategoryByFancyBear[_fancyBear][categories[i]];
        }
        return (traitArray, categories);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Receiver)
        returns (bool)
    {

        return super.supportsInterface(interfaceId);
    }
}