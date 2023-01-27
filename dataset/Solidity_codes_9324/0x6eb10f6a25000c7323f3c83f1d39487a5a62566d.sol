
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// UNLICENSED
pragma solidity ^0.8.2;


contract AirdropHelper {

    function dispatchERC721(
        address _token,
        address[] memory _receivers,
        uint256[] memory _ids
    ) public {

        IERC721 tokToken = IERC721(_token);
        for (uint256 i = 0; i < _receivers.length; i++) {
            tokToken.transferFrom(msg.sender, _receivers[i], _ids[i]);
        }
    }

    function dispatchERC1155(
        address _token,
        address[] memory _receivers,
        uint256[] memory _ids,
        uint256[] memory _qty
    ) public {

        IERC1155 tokToken = IERC1155(_token);
        for (uint256 i = 0; i < _receivers.length; i++) {
            tokToken.safeTransferFrom(msg.sender, _receivers[i], _ids[i], _qty[i], "");
        }
    }

    function dispatchERC20(
        address _token,
        address[] memory _receivers,
        uint256[] memory _values
    ) public {

        IERC20 tokToken = IERC20(_token);
        for (uint256 i = 0; i < _receivers.length; i++) {
            tokToken.transferFrom(msg.sender, _receivers[i], _values[i]);
        }
    }
}// UNLICENSED
pragma solidity ^0.8.2;

abstract contract ContractSafe {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function isSentViaEOA() internal view returns (bool) {
        return msg.sender == tx.origin;
    }
}// UNLICENSED
pragma solidity ^0.8.2;


contract LazyAirdrop is AirdropHelper, ContractSafe {

    function isTargetContract(address target) public view returns (bool) {

        return ContractSafe.isContract(target);
    }

    function isTargetsContract(address[] memory targets) public view returns (bool[] memory _res) {

        _res = new bool[](targets.length);
        for (uint256 i = 0; i < targets.length; i++) {
            _res[i] = isTargetContract(targets[i]);
        }
    }
}