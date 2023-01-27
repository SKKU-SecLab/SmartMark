
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity 0.8.11;

abstract contract ReentrancyGuard {
    uint256 private reentrancyStatus = 1;

    modifier nonReentrant() {
        require(reentrancyStatus == 1, "REENTRANCY");

        reentrancyStatus = 2;

        _;

        reentrancyStatus = 1;
    }
}// MIT

pragma solidity 0.8.11;

interface ICryptoPunks {

    function punkIndexToAddress(uint index) external view returns(address owner);

    function offerPunkForSaleToAddress(uint punkIndex, uint minSalePriceInWei, address toAddress) external;

    function buyPunk(uint punkIndex) external payable;

    function transferPunk(address to, uint punkIndex) external;

}// MIT

pragma solidity 0.8.11;

interface IWrappedPunk {

    function mint(uint256 punkIndex) external;


    function burn(uint256 punkIndex) external;

    
    function registerProxy() external;


    function proxyInfo(address user) external view returns (address);

}// BUSL-1.1

pragma solidity 0.8.11;

interface IMoonCatsRescue {

    function acceptAdoptionOffer(bytes5 catId) payable external;

    function makeAdoptionOfferToAddress(bytes5 catId, uint price, address to) external;

    function giveCat(bytes5 catId, address to) external;

    function catOwners(bytes5 catId) external view returns(address);

    function rescueOrder(uint256 rescueIndex) external view returns(bytes5 catId);

}// MIT

pragma solidity 0.8.11;


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
}// MIT

pragma solidity 0.8.11;

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

}// MIT

pragma solidity 0.8.11;

interface IERC721 {

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external;


    function setApprovalForAll(address operator, bool approved) external;


    function approve(address to, uint256 tokenId) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function balanceOf(address _owner) external view returns (uint256);

}// MIT

pragma solidity 0.8.11;
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


    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

}// MIT
pragma solidity 0.8.11;


contract ElementExSwap is SpecialTransferHelper, Ownable, ReentrancyGuard {


    struct SimpleTrades {
        uint256 value;
        bytes tradeData;
    }

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

    struct TradeDetails {
        uint256 marketId;
        uint256 value;
        bytes tradeData;
    }

    struct Market {
        address proxy;
        bool isLib;
        bool isActive;
        bool partialFill; // support partial Fill
    }

    event TradeNotFilled(uint256 tradeInfo); // marketId << 248 | index << 240 | value
    event TradeNotFilledSingleMarket(address market, uint256 tradeInfo); // tradeInfo = index << 240 | value

    address public guardian;
    address public converter;
    address public punkProxy;
    bool public openForTrades;

    Market[] public markets;

    modifier isOpenForTrades() {

        require(openForTrades, "trades not allowed");
        _;
    }

    constructor(address[] memory _proxies, bool[] memory _isLibs, bool[] memory _partialFill) {
        openForTrades = false;
        for (uint256 i = 0; i < _proxies.length; i++) {
            markets.push(Market(_proxies[i], _isLibs[i], true, _partialFill[i]));
        }
    }

    function setOpenForTrades(bool _openForTrades) external onlyOwner {

        openForTrades = _openForTrades;
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

    function closeAllTrades() external {

        require(_msgSender() == guardian);
        openForTrades = false;
    }

    function setConverter(address _converter) external onlyOwner {

        converter = _converter;
    }

    function addMarket(address _proxy, bool _isLib, bool _partialFill) external onlyOwner {

        markets.push(Market(_proxy, _isLib, true, _partialFill));
    }

    function setMarketStatus(uint256 _marketId, bool _newStatus) external onlyOwner {

        Market storage market = markets[_marketId];
        market.isActive = _newStatus;
    }

    function setMarketProxy(uint256 _marketId, address _newProxy, bool _isLib, bool _partialFill) external onlyOwner {

        Market storage market = markets[_marketId];
        market.proxy = _newProxy;
        market.isLib = _isLib;
        market.partialFill = _partialFill;
    }

    function _transferEth(address _to, uint256 _amount) internal {

        bool callStatus;
        assembly {
            callStatus := call(gas(), _to, _amount, 0, 0, 0, 0)
        }
        require(callStatus, "_transferEth: Eth transfer failed");
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
        ERC20Details calldata erc20Details,
        SpecialTransferHelper.ERC721Details[] calldata erc721Details,
        ERC1155Details[] calldata erc1155Details
    ) internal {

        for (uint256 i = 0; i < erc20Details.tokenAddrs.length; i++) {
            erc20Details.tokenAddrs[i].call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), erc20Details.amounts[i]));
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
        ConverstionDetails[] calldata _converstionDetails
    ) internal {

        for (uint256 i = 0; i < _converstionDetails.length; i++) {
            (bool success,) = converter.delegatecall(_converstionDetails[i].conversionData);
            _checkCallResult(success);
        }
    }

    function _trade(
        TradeDetails[] calldata _tradeDetails
    ) internal {

        for (uint256 i = 0; i < _tradeDetails.length; i++) {

            Market memory market = markets[_tradeDetails[i].marketId];

            require(market.isActive, "_trade: InActive Market");

            (bool success,) = market.isLib
            ? market.proxy.delegatecall(_tradeDetails[i].tradeData)
            : market.proxy.call{value : _tradeDetails[i].value}(_tradeDetails[i].tradeData);

            if (!success) {
                if (!market.partialFill) {
                    _checkCallResult(success);
                }
                emit TradeNotFilled(_tradeDetails[i].marketId << 248 | i << 240 | _tradeDetails[i].value);
            }
        }
    }

    function _returnDust(address[] memory _tokens) internal {

        assembly {
            if gt(selfbalance(), 0) {
                let callStatus := call(
                gas(),
                caller(),
                selfbalance(),
                0,
                0,
                0,
                0
                )
            }
        }
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (IERC20(_tokens[i]).balanceOf(address(this)) > 0) {
                _tokens[i].call(abi.encodeWithSelector(0xa9059cbb, msg.sender, IERC20(_tokens[i]).balanceOf(address(this))));
            }
        }
    }

    function buyOneWithETH(
        address marketProxy,
        SimpleTrades calldata tradeDetail
    ) payable external nonReentrant {

        (bool success,) = address(marketProxy).call{value : tradeDetail.value}(tradeDetail.tradeData);
        _checkCallResult(success);
    }

    function batchBuyFromSingleMarketWithETH(
        address marketProxy,
        SimpleTrades[] calldata tradeDetails
    ) payable external nonReentrant {


        for (uint256 i = 0; i < tradeDetails.length; i++) {

            (bool success,) = marketProxy.call{value : tradeDetails[i].value}(tradeDetails[i].tradeData);

            if (!success) {
                emit TradeNotFilledSingleMarket(marketProxy, i << 240 | tradeDetails[i].value);
            }
        }

        assembly {
            if gt(selfbalance(), 0) {
                let callStatus := call(
                gas(),
                caller(),
                selfbalance(),
                0,
                0,
                0,
                0
                )
            }
        }
    }

    function batchBuyWithETH(
        TradeDetails[] calldata tradeDetails
    ) payable external nonReentrant {

        _trade(tradeDetails);

        assembly {
            if gt(selfbalance(), 0) {
                let callStatus := call(
                gas(),
                caller(),
                selfbalance(),
                0,
                0,
                0,
                0
                )
            }
        }
    }


    function batchBuyWithETHSimulate(
        TradeDetails[] calldata tradeDetails
    ) payable external {

        uint256 result = _simulateTrade(tradeDetails);

        bytes memory errorData = abi.encodePacked(result);
        assembly {
            if gt(selfbalance(), 0) {
                let callStatus := call(
                gas(),
                caller(),
                selfbalance(),
                0,
                0,
                0,
                0
                )
            }

            revert(add(errorData, 0x20), mload(errorData))
        }
    }

    function buyOneWithERC20s(
        address marketProxy,
        ERC20Details calldata erc20Details,
        SimpleTrades calldata tradeDetails,
        ConverstionDetails[] calldata converstionDetails,
        address[] calldata dustTokens
    ) payable external nonReentrant {

        for (uint256 i = 0; i < erc20Details.tokenAddrs.length; i++) {
            erc20Details.tokenAddrs[i].call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), erc20Details.amounts[i]));
        }

        _conversionHelper(converstionDetails);

        (bool success,) = marketProxy.call{value : tradeDetails.value}(tradeDetails.tradeData);

        _checkCallResult(success);

        _returnDust(dustTokens);
    }


    function batchBuyWithERC20s(
        ERC20Details calldata erc20Details,
        TradeDetails[] calldata tradeDetails,
        ConverstionDetails[] calldata converstionDetails,
        address[] calldata dustTokens
    ) payable external nonReentrant {

        for (uint256 i = 0; i < erc20Details.tokenAddrs.length; i++) {
            erc20Details.tokenAddrs[i].call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), erc20Details.amounts[i]));
        }

        _conversionHelper(converstionDetails);

        _trade(tradeDetails);

        _returnDust(dustTokens);
    }


    function batchBuyWithERC20sSimulate(
        ERC20Details calldata erc20Details,
        TradeDetails[] calldata tradeDetails,
        ConverstionDetails[] calldata converstionDetails,
        address[] calldata dustTokens
    ) payable external {

        for (uint256 i = 0; i < erc20Details.tokenAddrs.length; i++) {
            erc20Details.tokenAddrs[i].call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), erc20Details.amounts[i]));
        }

        _conversionHelper(converstionDetails);

        uint256 result = _simulateTrade(tradeDetails);

        _returnDust(dustTokens);

        bytes memory errorData = abi.encodePacked(result);
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }


    function multiAssetSwapEx(
        ERC20Details calldata erc20Details,
        SpecialTransferHelper.ERC721Details[] calldata erc721Details,
        ERC1155Details[] calldata erc1155Details,
        ConverstionDetails[] calldata converstionDetails,
        TradeDetails[] calldata tradeDetails,
        address[] calldata dustTokens
    ) payable external isOpenForTrades nonReentrant {


        _transferFromHelper(
            erc20Details,
            erc721Details,
            erc1155Details
        );

        _conversionHelper(converstionDetails);

        _trade(tradeDetails);

        _returnDust(dustTokens);
    }


    function _simulateTrade(
        TradeDetails[] calldata _tradeDetails
    ) internal returns (uint256) {

        uint256 result;
        for (uint256 i = 0; i < _tradeDetails.length; i++) {
            Market memory market = markets[_tradeDetails[i].marketId];

            require(market.isActive, "Simulate: InActive Market");

            (bool success,) = market.isLib
            ? market.proxy.delegatecall(_tradeDetails[i].tradeData)
            : market.proxy.call{value : _tradeDetails[i].value}(_tradeDetails[i].tradeData);

            if (success) {
                result |= 1 << i;
            }
        }
        return result;
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

        asset.call(abi.encodeWithSelector(0xa9059cbb, recipient, IERC20(asset).balanceOf(address(this))));
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