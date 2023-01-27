
pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract KyberNetworkProxyInterface {

  function maxGasPrice() public view returns(uint);

  function getUserCapInWei(address user) public view returns(uint);

  function getUserCapInTokenWei(address user, IERC20 token) public view returns(uint);

  function enabled() public view returns(bool);

  function info(bytes32 id) public view returns(uint);


  function getExpectedRate(IERC20 src, IERC20 dest, uint srcQty) public view returns (uint expectedRate, uint slippageRate);


  function tradeWithHint(IERC20 src, uint srcAmount, IERC20 dest, address payable destAddress, uint maxDestAmount, uint minConversionRate, address walletId, bytes memory hint) public payable returns (uint);

}

interface ERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);


    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);

}

contract CommonConstants {


    bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract IERC1155 is IERC165 {

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;


    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;


    function balanceOf(address _owner, uint256 _id) external view returns (uint256);


    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


    function setApprovalForAll(address _operator, bool _approved) external;


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}

contract KyberNetwork1155Wrapper is ERC1155TokenReceiver, CommonConstants {


    event TokenChange(address token, uint change);
    event ETHReceived(address indexed sender, uint amount);

    IERC20 constant internal ETH_TOKEN_ADDRESS = IERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    function() payable external {
        emit ETHReceived(msg.sender, msg.value);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external returns(bytes4) {

        return ERC1155_ACCEPTED;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external returns(bytes4) {

        return ERC1155_BATCH_ACCEPTED;
    }

    function tradeAndBuy(
        IERC1155 nft,
        uint nftId,
        bytes memory buyData,
        uint256 buying,
        uint amount,
        KyberNetworkProxyInterface _kyberProxy,
        address sale,
        IERC20 token,
        uint tokenQty,
        uint minRate
    ) public {

        uint startTokenBalance = token.balanceOf(address(this));
        require(token.transferFrom(msg.sender, address(this), tokenQty));
        require(token.approve(address(_kyberProxy), tokenQty));
        uint userETH = _kyberProxy.tradeWithHint(token, tokenQty, ETH_TOKEN_ADDRESS, address(uint160(address(this))), amount, minRate, address(0x0), "");
        require(userETH >= amount, "not enough eth to buy nft");

        (bool success,) = sale.call.value(amount)(buyData);
        require(success, "buy error");
        nft.safeTransferFrom(address(this), msg.sender, nftId, buying, "");

        if (userETH > amount) {
            msg.sender.transfer(userETH - amount);
            emit TokenChange(address(ETH_TOKEN_ADDRESS), userETH - amount);
        }
        uint endTokenBalance = token.balanceOf(address(this));
        if (endTokenBalance > startTokenBalance) {
            token.transfer(msg.sender, endTokenBalance - startTokenBalance);
            emit TokenChange(address(token), endTokenBalance - startTokenBalance);
        }
    }
}