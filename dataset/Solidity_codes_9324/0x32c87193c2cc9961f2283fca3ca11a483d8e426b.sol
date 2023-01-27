
pragma solidity ^0.7.4;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}//MIT

pragma solidity ^0.7.4;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity ^0.7.4;


abstract contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity ^0.7.4;

interface IEthItem {


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function burnBatch(
        uint256[] calldata objectIds,
        uint256[] calldata amounts
    ) external;

}// MIT

pragma solidity ^0.7.4;


contract WhereIsMyDragonTreasure is IERC1155Receiver, ERC165 {


    address private _source;
    uint256 private _legendaryCard;

    uint256 private _singleReward;
    uint256 private _legendaryCardAmount;
    uint256 private _startBlock;

    uint256 private _redeemed;

    constructor(address source, uint256 legendaryCard, uint256 legendaryCardAmount, uint256 startBlock) {
        _source = source;
        _legendaryCard = legendaryCard;
        _legendaryCardAmount = legendaryCardAmount;
        _startBlock = startBlock;
        _registerInterfaces();
    }

    function _registerInterfaces() private {

        _registerInterface(this.onERC1155Received.selector);
        _registerInterface(this.onERC1155BatchReceived.selector);
    }

    receive() external payable {
        if(block.number >= _startBlock) {
            payable(msg.sender).transfer(msg.value);
            return;
        }
        _singleReward = address(this).balance / _legendaryCardAmount;
    }

    function data() public view returns(uint256 balance, uint256 singleReward, uint256 startBlock, uint256 redeemed) {

        balance = address(this).balance;
        singleReward = _singleReward;
        startBlock = _startBlock;
        redeemed = _redeemed;
    }

    function onERC1155Received(
        address,
        address from,
        uint256 objectId,
        uint256 amount,
        bytes memory
    )
        public override
        returns(bytes4) {

        uint256[] memory objectIds = new uint256[](1);
        objectIds[0] = objectId;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        _checkBurnAndTransfer(from, objectIds, amounts);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] memory objectIds,
        uint256[] memory amounts,
        bytes memory
    )
        public override
        returns(bytes4) {

        _checkBurnAndTransfer(from, objectIds, amounts);
        return this.onERC1155BatchReceived.selector;
    }

    function _checkBurnAndTransfer(address from, uint256[] memory objectIds, uint256[] memory amounts) private {

        require(msg.sender == _source, "Unauthorized Action");
        require(block.number >= _startBlock, "Redeem Period still not started");
        for(uint256 i = 0; i < objectIds.length; i++) {
            require(objectIds[i] == _legendaryCard, "Wrong Card!");
            _redeemed += amounts[i];
            payable(from).transfer(_singleReward * amounts[i]);
        }
        IEthItem(_source).burnBatch(objectIds, amounts);
    }
}