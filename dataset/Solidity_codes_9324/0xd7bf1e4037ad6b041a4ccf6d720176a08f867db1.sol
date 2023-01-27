
pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}/*
 * Copyright (C) 2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 *
 * Apache-2.0
 * See the file LICENSES/README.md for more information.
 */

pragma solidity >=0.7.0 <0.8.0;


interface IERC1155BurnMintable is IERC1155 {

  function mint(
    address to,
    uint256 tokenId,
    uint256 amount,
    bytes memory data
  ) external;


  function mintBatch(
    address to,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    bytes memory data
  ) external;


  function burn(
    address account,
    uint256 tokenId,
    uint256 value
  ) external;


  function burnBatch(
    address account,
    uint256[] memory tokenIds,
    uint256[] memory values
  ) external;

}/*
 * Copyright (C) 2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 *
 * Apache-2.0
 * See the file LICENSES/README.md for more information.
 */

pragma solidity >=0.7.0 <0.8.0;

interface IWOWSCryptofolio {


  function initialize() external;



  function getCryptofolio(address tradefloor)
    external
    view
    returns (uint256[] memory tokenIds, uint256 idsLength);



  function setOwner(address owner) external;


  function setApprovalForAll(address operator, bool allow) external;


  function burn() external;

}/*
 * Copyright (C) 2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 *
 * Apache-2.0
 * See the file LICENSES/README.md for more information.
 */

pragma solidity >=0.7.0 <0.8.0;

interface IWOWSERC1155 {


  function isTradeFloor(address account) external view returns (bool);


  function addressToTokenId(address tokenAddress)
    external
    view
    returns (uint256);


  function tokenIdToAddress(uint256 tokenId) external view returns (address);


  function getNextMintableTokenId(uint8 level, uint8 cardId)
    external
    view
    returns (bool, uint256);


  function getNextMintableCustomToken() external view returns (uint256);



  function setURI(uint256 tokenId, string memory _uri) external;


  function setCustomDefaultURI(string memory _uri) external;


  function setCustomCardLevel(uint256 tokenId, uint8 cardLevel) external;

}/*
 * Copyright (C) 2020-2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 *
 * Apache-2.0
 * See the file LICENSES/README.md for more information.
 */

pragma solidity >=0.7.0 <0.8.0;


contract WOWSCryptofolio is IWOWSCryptofolio {

  IWOWSERC1155 private _deployer;
  address private _owner;
  mapping(address => uint256[]) private _cryptofolios;
  address[] public _tradefloors;


  event CryptoFolioAdded(
    address indexed sft,
    address indexed operator,
    uint256[] tokenIds,
    uint256[] amounts
  );


  function initialize() external override {

    require(address(_deployer) == address(0), 'CF: Already initialized');
    _deployer = IWOWSERC1155(msg.sender);
  }


  function getCryptofolio(address tradefloor)
    external
    view
    override
    returns (uint256[] memory tokenIds, uint256 idsLength)
  {

    uint256[] storage opIds = _cryptofolios[tradefloor];
    uint256[] memory result = new uint256[](opIds.length);
    uint256 newLength = 0;

    if (opIds.length > 0) {
      address[] memory accounts = new address[](opIds.length);
      for (uint256 i = 0; i < opIds.length; ++i) accounts[i] = address(this);
      uint256[] memory balances =
        IERC1155(tradefloor).balanceOfBatch(accounts, opIds);

      for (uint256 i = 0; i < opIds.length; ++i)
        if (balances[i] > 0) result[newLength++] = opIds[i];
    }
    return (result, newLength);
  }

  function setOwner(address newOwner) external override {

    require(msg.sender == address(_deployer), 'CF: Only deployer');
    for (uint256 i = 0; i < _tradefloors.length; ++i) {
      if (_owner != address(0))
        IERC1155(_tradefloors[i]).setApprovalForAll(_owner, false);
      if (newOwner != address(0))
        IERC1155(_tradefloors[i]).setApprovalForAll(newOwner, true);
    }
    _owner = newOwner;
  }

  function setApprovalForAll(address operator, bool allow) external override {

    require(msg.sender == _owner, 'CF: Only owner');
    for (uint256 i = 0; i < _tradefloors.length; ++i) {
      IERC1155(_tradefloors[i]).setApprovalForAll(operator, allow);
    }
  }

  function burn() external override {

    require(msg.sender == address(_deployer), 'CF: Only deployer');
    for (uint256 i = 0; i < _tradefloors.length; ++i) {
      IERC1155BurnMintable tradefloor = IERC1155BurnMintable(_tradefloors[i]);
      uint256[] storage opIds = _cryptofolios[address(tradefloor)];
      if (opIds.length > 0) {
        address[] memory accounts = new address[](opIds.length);
        for (uint256 j = 0; j < opIds.length; ++j) accounts[j] = address(this);
        uint256[] memory balances = tradefloor.balanceOfBatch(accounts, opIds);
        tradefloor.burnBatch(address(this), opIds, balances);
      }
      delete _cryptofolios[address(tradefloor)];
    }
    delete _tradefloors;
  }


  function onERC1155Received(
    address,
    address,
    uint256 tokenId,
    uint256 amount,
    bytes memory
  ) external returns (bytes4) {

    uint256[] memory tokenIds = new uint256[](1);
    tokenIds[0] = tokenId;
    uint256[] memory amounts = new uint256[](1);
    amounts[0] = amount;
    _onTokensReceived(tokenIds, amounts);
    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address,
    address,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    bytes memory
  ) external returns (bytes4) {

    _onTokensReceived(tokenIds, amounts);
    return this.onERC1155BatchReceived.selector;
  }


  function _onTokensReceived(
    uint256[] memory tokenIds,
    uint256[] memory amounts
  ) internal {

    address tradefloor = msg.sender;
    require(_deployer.isTradeFloor(tradefloor), 'CF: Only tradefloor');
    require(tokenIds.length == amounts.length, 'CF: Input lengths differ');

    uint256[] storage currentIds = _cryptofolios[tradefloor];
    if (currentIds.length == 0) {
      IERC1155(tradefloor).setApprovalForAll(_owner, true);
      _tradefloors.push(tradefloor);
    }

    for (uint256 iIds = 0; iIds < tokenIds.length; ++iIds) {
      if (amounts[iIds] > 0) {
        uint256 tokenId = tokenIds[iIds];
        uint256 i = 0;
        for (; i < currentIds.length && currentIds[i] != tokenId; ++i) i;
        if (i == currentIds.length) currentIds.push(tokenId);
      }
    }
    emit CryptoFolioAdded(address(this), tradefloor, tokenIds, amounts);
  }
}