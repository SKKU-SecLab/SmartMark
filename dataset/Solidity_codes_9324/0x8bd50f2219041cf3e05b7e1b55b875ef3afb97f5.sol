
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// BUSL-1.1

pragma solidity 0.8.4;



contract MarketRegistry is Ownable {


    struct TradeDetails {
        uint256 marketId;
        uint256 value;
        bytes tradeData;
    }

    struct Market {
        address proxy;
        bool isLib;
        bool isActive;
    }

    Market[] public markets;

    constructor(address[] memory proxies, bool[] memory isLibs) {
        for (uint256 i = 0; i < proxies.length; i++) {
            markets.push(Market(proxies[i], isLibs[i], true));
        }
    }

    function addMarket(address proxy, bool isLib) external onlyOwner {

        markets.push(Market(proxy, isLib, true));
    }

    function setMarketStatus(uint256 marketId, bool newStatus) external onlyOwner {

        Market storage market = markets[marketId];
        market.isActive = newStatus;
    }

    function setMarketProxy(uint256 marketId, address newProxy, bool isLib) external onlyOwner {

        Market storage market = markets[marketId];
        market.proxy = newProxy;
        market.isLib = isLib;
    }
}// BUSL-1.1

pragma solidity 0.8.4;

contract UserProxy {


    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function transfer(address punkContract, uint256 punkIndex)
        external
        returns (bool)
    {

        if (_owner != msg.sender) {
            return false;
        }

        (bool result,) = punkContract.call(abi.encodeWithSignature("transferPunk(address,uint256)", _owner, punkIndex));

        return result;
    }

}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// BUSL-1.1

pragma solidity 0.8.4;


contract EIP1271 {

  
  using ECDSA for bytes32;


  function isValidSignature(
    bytes32 hash, 
    bytes memory signature
  ) external view returns (bytes4 magicValue) {

      address signer = hash.recover(signature);
      if (signer == tx.origin) {
        return 0x1626ba7e;
      } else {
        return 0xffffffff;
      }
    }
}// BUSL-1.1

pragma solidity 0.8.4;

interface ICryptoPunks {

    function punkIndexToAddress(uint index) external view returns(address owner);

    function offerPunkForSaleToAddress(uint punkIndex, uint minSalePriceInWei, address toAddress) external;

    function buyPunk(uint punkIndex) external payable;

    function transferPunk(address to, uint punkIndex) external;

}// BUSL-1.1

pragma solidity 0.8.4;

interface IWrappedPunk {

    function mint(uint256 punkIndex) external;


    function burn(uint256 punkIndex) external;

    
    function registerProxy() external;


    function proxyInfo(address user) external view returns (address);

}// BUSL-1.1

pragma solidity 0.8.4;

interface IMoonCatsRescue {

    function acceptAdoptionOffer(bytes5 catId) payable external;

    function makeAdoptionOfferToAddress(bytes5 catId, uint price, address to) external;

    function giveCat(bytes5 catId, address to) external;

    function catOwners(bytes5 catId) external view returns(address);

    function rescueOrder(uint256 rescueIndex) external view returns(bytes5 catId);

}// BUSL-1.1

pragma solidity 0.8.4;


contract SpecialTransferHelper is Context {


    struct ERC721Details {
        address tokenAddr;
        address[] to;
        uint256[] ids;
    }

    function _uintToBytes5(uint256 id)
        internal
        pure
        returns (bytes5 slicedDataBytes5)
    {

        bytes memory _bytes = new bytes(32);
        assembly {
            mstore(add(_bytes, 32), id)
        }

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let lengthmod := and(5, 31)

            let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
            let end := add(mc, 5)

            for {
                let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), 27)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(tempBytes, 5)

            mstore(0x40, and(add(mc, 31), not(31)))
        }

        assembly {
            slicedDataBytes5 := mload(add(tempBytes, 32))
        }
    }


    function _acceptMoonCat(ERC721Details memory erc721Details) internal {

        for (uint256 i = 0; i < erc721Details.ids.length; i++) {
            bytes5 catId = _uintToBytes5(erc721Details.ids[i]);
            address owner = IMoonCatsRescue(erc721Details.tokenAddr).catOwners(catId);
            require(owner == _msgSender(), "_acceptMoonCat: invalid mooncat owner");
            IMoonCatsRescue(erc721Details.tokenAddr).acceptAdoptionOffer(catId);
        }
    }

    function _transferMoonCat(ERC721Details memory erc721Details) internal {

        for (uint256 i = 0; i < erc721Details.ids.length; i++) {
            IMoonCatsRescue(erc721Details.tokenAddr).giveCat(_uintToBytes5(erc721Details.ids[i]), erc721Details.to[i]);
        }
    }

    function _acceptCryptoPunk(ERC721Details memory erc721Details) internal {

        for (uint256 i = 0; i < erc721Details.ids.length; i++) {    
            address owner = ICryptoPunks(erc721Details.tokenAddr).punkIndexToAddress(erc721Details.ids[i]);
            require(owner == _msgSender(), "_acceptCryptoPunk: invalid punk owner");
            ICryptoPunks(erc721Details.tokenAddr).buyPunk(erc721Details.ids[i]);
        }
    }

    function _transferCryptoPunk(ERC721Details memory erc721Details) internal {

        for (uint256 i = 0; i < erc721Details.ids.length; i++) {
            ICryptoPunks(erc721Details.tokenAddr).transferPunk(erc721Details.to[i], erc721Details.ids[i]);
        }
    }
}// BUSL-1.1

pragma solidity 0.8.4;

interface IConverter {


    struct MoonCatDetails {
        bytes5[] catIds;
        uint256[] oldTokenIds;
        uint256[] rescueOrders;
    }

    function mooncatToAcclimated(MoonCatDetails memory moonCatDetails) external;


    function wrappedToAcclimated(MoonCatDetails memory moonCatDetails) external;


    function mooncatToWrapped(MoonCatDetails memory moonCatDetails) external;


    function acclimatedToWrapped(MoonCatDetails memory moonCatDetails) external;


    function cryptopunkToWrapped(address punkProxy, uint256[] memory tokenIds) external;


    function wrappedToCryptopunk(uint256[] memory tokenIds) external;

}// BUSL-1.1

pragma solidity 0.8.4;

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

}// BUSL-1.1

pragma solidity 0.8.4;

interface IERC721 {

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external;

    
    function setApprovalForAll(address operator, bool approved) external;


    function approve(address to, uint256 tokenId) external;

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// BUSL-1.1

pragma solidity 0.8.4;
interface IERC1155 {

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

}// BUSL-1.1

pragma solidity 0.8.4;



contract GenieSwap is SpecialTransferHelper, Ownable, EIP1271, ReentrancyGuard {


    struct ERC20Details {
        address[] tokenAddrs;
        uint256[] amounts;
    }

    struct ERC1155Details {
        address tokenAddr;
        uint256[] ids;
        uint256[] amounts;
    }

    struct ConverstionDetails {
        bytes conversionData;
    }

    struct AffiliateDetails {
        address affiliate;
        bool isActive;
    }

    struct SponsoredMarket {
        uint256 marketId;
        bool isActive;
    }

    address public constant GOV = 0xE43aA28716b0B7531293557D5397F8b12f3F5aBc;
    address public guardian;
    address public converter;
    address public punkProxy;
    uint256 public baseFees;
    bool public openForTrades;
    bool public openForFreeTrades;
    MarketRegistry public marketRegistry;
    AffiliateDetails[] public affiliates;
    SponsoredMarket[] public sponsoredMarkets;

    modifier isOpenForTrades() {

        require(openForTrades, "trades not allowed");
        _;
    }

    modifier isOpenForFreeTrades() {

        require(openForFreeTrades, "free trades not allowed");
        _;
    }

    constructor(address _marketRegistry, address _converter, address _guardian) {
        marketRegistry = MarketRegistry(_marketRegistry);
        converter = _converter;
        guardian = _guardian;
        baseFees = 0;
        openForTrades = true;
        openForFreeTrades = true;
        affiliates.push(AffiliateDetails(GOV, true));
    }

    function setUp() external onlyOwner {

        IWrappedPunk(0xb7F7F6C52F2e2fdb1963Eab30438024864c313F6).registerProxy();
        punkProxy = IWrappedPunk(0xb7F7F6C52F2e2fdb1963Eab30438024864c313F6).proxyInfo(address(this));

        IERC721(0x7C40c393DC0f283F318791d746d894DdD3693572).setApprovalForAll(0xc3f733ca98E0daD0386979Eb96fb1722A1A05E69, true);
    }

    function setOneTimeApproval(IERC20 token, address operator, uint256 amount) external onlyOwner {

        token.approve(operator, amount);
    }

    function updateGuardian(address _guardian) external onlyOwner {

        guardian = _guardian;
    }

    function addAffiliate(address _affiliate) external onlyOwner {

        affiliates.push(AffiliateDetails(_affiliate, true));
    }

    function updateAffiliate(uint256 _affiliateIndex, address _affiliate, bool _IsActive) external onlyOwner {

        affiliates[_affiliateIndex] = AffiliateDetails(_affiliate, _IsActive);
    }

    function addSponsoredMarket(uint256 _marketId) external onlyOwner {

        sponsoredMarkets.push(SponsoredMarket(_marketId, true));
    }

    function updateSponsoredMarket(uint256 _marketIndex, uint256 _marketId, bool _isActive) external onlyOwner {

        sponsoredMarkets[_marketIndex] = SponsoredMarket(_marketId, _isActive);
    }

    function setBaseFees(uint256 _baseFees) external onlyOwner {

        baseFees = _baseFees;
    }

    function setOpenForTrades(bool _openForTrades) external onlyOwner {

        openForTrades = _openForTrades;
    }

    function setOpenForFreeTrades(bool _openForFreeTrades) external onlyOwner {

        openForFreeTrades = _openForFreeTrades;
    }

    function closeAllTrades() external {

        require(_msgSender() == guardian);
        openForTrades = false;
        openForFreeTrades = false;
    }

    function setConverter(address _converter) external onlyOwner {

        converter = _converter;
    }

    function setMarketRegistry(MarketRegistry _marketRegistry) external onlyOwner {

        marketRegistry = _marketRegistry;
    }

    function _transferEth(address _to, uint256 _amount) internal {

        (bool success, ) = _to.call{value: _amount}('');
        require(success, "_transferEth: Eth transfer failed");
    }

    function _collectFee(uint256[2] memory feeDetails) internal {

        require(feeDetails[1] >= baseFees, "Insufficient fee");
        if (feeDetails[1] > 0) {
            AffiliateDetails memory affiliateDetails = affiliates[feeDetails[0]];
            affiliateDetails.isActive
                ? _transferEth(affiliateDetails.affiliate, feeDetails[1])
                : _transferEth(GOV, feeDetails[1]);
        }
    }

    function _checkCallResult(bool _success) internal pure {

        if (!_success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    function _transferFromHelper(
        ERC20Details memory erc20Details,
        SpecialTransferHelper.ERC721Details[] memory erc721Details,
        ERC1155Details[] memory erc1155Details
    ) internal {

        for (uint256 i = 0; i < erc20Details.tokenAddrs.length; i++) {
            require(
                IERC20(erc20Details.tokenAddrs[i]).transferFrom(
                    _msgSender(),
                    address(this),
                    erc20Details.amounts[i]
                ),
                "_transferHelper: transfer failed"
            );
        }

        for (uint256 i = 0; i < erc721Details.length; i++) {
            if (erc721Details[i].tokenAddr == 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB) {
                _acceptCryptoPunk(erc721Details[i]);
            }
            else if (erc721Details[i].tokenAddr == 0x60cd862c9C687A9dE49aecdC3A99b74A4fc54aB6) {
                _acceptMoonCat(erc721Details[i]);
            }
            else {
                for (uint256 j = 0; j < erc721Details[i].ids.length; j++) {
                    IERC721(erc721Details[i].tokenAddr).transferFrom(
                        _msgSender(),
                        address(this),
                        erc721Details[i].ids[j]
                    );
                }
            }
        }

        for (uint256 i = 0; i < erc1155Details.length; i++) {
            IERC1155(erc1155Details[i].tokenAddr).safeBatchTransferFrom(
                _msgSender(),
                address(this),
                erc1155Details[i].ids,
                erc1155Details[i].amounts,
                ""
            );
        }
    }

    function _conversionHelper(
        ConverstionDetails[] memory _converstionDetails
    ) internal {

        for (uint256 i = 0; i < _converstionDetails.length; i++) {
            (bool success, ) = converter.delegatecall(_converstionDetails[i].conversionData);
            _checkCallResult(success);
        }
    }

    function _trade(
        MarketRegistry.TradeDetails[] memory _tradeDetails
    ) internal {

        for (uint256 i = 0; i < _tradeDetails.length; i++) {
            (address _proxy, bool _isLib, bool _isActive) = marketRegistry.markets(_tradeDetails[i].marketId);
            require(_isActive, "_trade: InActive Market");
            (bool success, ) = _isLib
                ? _proxy.delegatecall(_tradeDetails[i].tradeData)
                : _proxy.call{value:_tradeDetails[i].value}(_tradeDetails[i].tradeData);
            _checkCallResult(success);
        }
    }

    function _tradeSponsored(
        MarketRegistry.TradeDetails[] memory _tradeDetails,
        uint256 sponsoredMarketId
    ) internal returns (bool isSponsored) {

        for (uint256 i = 0; i < _tradeDetails.length; i++) {
            if (_tradeDetails[i].marketId == sponsoredMarketId) {
                isSponsored = true;
            }
            (address _proxy, bool _isLib, bool _isActive) = marketRegistry.markets(_tradeDetails[i].marketId);
            require(_isActive, "_trade: InActive Market");
            (bool success, ) = _isLib
                ? _proxy.delegatecall(_tradeDetails[i].tradeData)
                : _proxy.call{value:_tradeDetails[i].value}(_tradeDetails[i].tradeData);
            _checkCallResult(success);
        }
    }

    function _returnDust(address[] memory _tokens) internal {

        for (uint256 i = 0; i < _tokens.length; i++) {
            if(_tokens[i] == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                _transferEth(_msgSender(), address(this).balance);
            }
            else {
                IERC20(_tokens[i]).transfer(_msgSender(), IERC20(_tokens[i]).balanceOf(address(this)));
            }
        }
    }

    function multiAssetSwap(
        ERC20Details memory erc20Details,
        SpecialTransferHelper.ERC721Details[] memory erc721Details,
        ERC1155Details[] memory erc1155Details,
        ConverstionDetails[] memory converstionDetails,
        MarketRegistry.TradeDetails[] memory tradeDetails,
        address[] memory dustTokens,
        uint256[2] memory feeDetails    // [affiliateIndex, ETH fee in Wei]
    ) payable external isOpenForTrades nonReentrant {

        _collectFee(feeDetails);

        _transferFromHelper(
            erc20Details,
            erc721Details,
            erc1155Details
        );

        _conversionHelper(converstionDetails);

        _trade(tradeDetails);

        _returnDust(dustTokens);
    }

    function multiAssetSwapWithoutFee(
        ERC20Details memory erc20Details,
        SpecialTransferHelper.ERC721Details[] memory erc721Details,
        ERC1155Details[] memory erc1155Details,
        ConverstionDetails[] memory converstionDetails,
        MarketRegistry.TradeDetails[] memory tradeDetails,
        address[] memory dustTokens,
        uint256 sponsoredMarketIndex
    ) payable external isOpenForFreeTrades nonReentrant {

        SponsoredMarket memory sponsoredMarket = sponsoredMarkets[sponsoredMarketIndex];
        require(sponsoredMarket.isActive, "multiAssetSwapWithoutFee: InActive sponsored market");

        _transferFromHelper(
            erc20Details,
            erc721Details,
            erc1155Details
        );

        _conversionHelper(converstionDetails);

        bool isSponsored = _tradeSponsored(tradeDetails, sponsoredMarket.marketId);

        require(isSponsored, "multiAssetSwapWithoutFee: trades do not include sponsored market");

        _returnDust(dustTokens);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) public virtual returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) public virtual returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {

        return 0x150b7a02;
    }

    function onERC721Received(
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {

        return 0xf0b9e5ba;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        virtual
        view
        returns (bool)
    {

        return interfaceId == this.supportsInterface.selector;
    }

    receive() external payable {}

    function rescueETH(address recipient) onlyOwner external {

        _transferEth(recipient, address(this).balance);
    }

    function rescueERC20(address asset, address recipient) onlyOwner external { 

        IERC20(asset).transfer(recipient, IERC20(asset).balanceOf(address(this)));
    }

    function rescueERC721(address asset, uint256[] calldata ids, address recipient) onlyOwner external {

        for (uint256 i = 0; i < ids.length; i++) {
            IERC721(asset).transferFrom(address(this), recipient, ids[i]);
        }
    }

    function rescueERC1155(address asset, uint256[] calldata ids, uint256[] calldata amounts, address recipient) onlyOwner external {

        for (uint256 i = 0; i < ids.length; i++) {
            IERC1155(asset).safeTransferFrom(address(this), recipient, ids[i], amounts[i], "");
        }
    }
}