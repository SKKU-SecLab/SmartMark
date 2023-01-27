
pragma solidity ^0.8.0;

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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


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

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}//Unlicense

pragma solidity ^0.8.0;

interface INFT20Pair {

    function withdraw(
        uint256[] calldata _tokenIds,
        uint256[] calldata amounts,
        address recipient
    ) external;


    function withdraw(uint256[] calldata _tokenIds, uint256[] calldata amounts)
        external;


    function track1155(uint256 _tokenId) external returns (uint256);


    function swap721(uint256 _in, uint256 _out) external;


    function swap1155(
        uint256[] calldata in_ids,
        uint256[] calldata in_amounts,
        uint256[] calldata out_ids,
        uint256[] calldata out_amounts
    ) external;

}//Unlicense

pragma solidity ^0.8.0;

interface INFT20Factory {


    function nftToToken(address pair) external returns (address);


}pragma solidity ^0.8.0;





interface Uni {

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}

interface UniV3 {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);


    function refundETH() external payable;


    function unwrapWETH9(uint256 amountMinimum, address recipient)
        external
        payable;


    function multicall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results);

}

interface weth {

    function withdraw(uint256 wad) external;

}

contract NFT20CasUpgreadableV1 is OwnableUpgradeable {

    using AddressUpgradeable for address;

    address public UNIV2;
    address public UNIV3;
    address public WETH;
    address public ETH;

    INFT20Factory public NFT20;

    function initialize() public initializer {

        __Ownable_init();
        UNIV2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        UNIV3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
        WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        NFT20 = INFT20Factory(0x0f4676178b5c53Ae0a655f1B19A96387E4b8B5f2);
    }

    receive() external payable {}

    function setNFT20(address _registry) public onlyOwner {

        NFT20 = INFT20Factory(_registry);
    }

    function withdrawEth() public payable {

        address payable _to = payable(
            0x6fBa46974b2b1bEfefA034e236A32e1f10C5A148
        ); //multisig
        (bool sent, ) = _to.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function ethForNft(
        address _nft,
        uint256[] memory _toIds,
        uint256[] memory _toAmounts,
        address _receipient,
        uint24 _fee,
        bool isV3
    ) public payable {

        uint256 balance_before = address(this).balance > msg.value
            ? address(this).balance - msg.value
            : 0;

        address token20 = NFT20.nftToToken(_nft);

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _toAmounts.length; i++) {
            totalAmount += _toAmounts[i];
        }


        if (isV3) {
            swapETHForExactERC20V3(token20, totalAmount * 100 ether, _fee);
        } else {
            swapETHForExactERC20(
                token20,
                address(this),
                totalAmount * 100 ether
            );
        }

        INFT20Pair(token20).withdraw(_toIds, _toAmounts, _receipient);

        uint256 balance_after = address(this).balance;

        uint256 dust = balance_after - balance_before;
        uint256 fees = ((msg.value - dust) * 5) / 100;

        if (dust - fees > 0) {
            (bool success, ) = _receipient.call{value: dust - fees}("");
            require(success, "swapEthForERC721: ETH dust transfer failed.");
        }
    }

    function nftForEth(
        address _nft,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bool isErc721,
        uint24 _fee,
        bool isV3
    ) external {

        address token20 = NFT20.nftToToken(_nft);

        if (isErc721) {
            for (uint256 i = 0; i < _ids.length; i++) {
                IERC721(_nft).safeTransferFrom(
                    msg.sender,
                    token20,
                    _ids[i],
                    abi.encodePacked(address(this))
                );
            }
        } else {
            if (_ids.length == 1) {
                IERC1155(_nft).safeTransferFrom(
                    msg.sender,
                    token20,
                    _ids[0],
                    _amounts[0],
                    abi.encodePacked(address(this))
                );
            } else {
                IERC1155(_nft).safeBatchTransferFrom(
                    msg.sender,
                    token20,
                    _ids,
                    _amounts,
                    abi.encodePacked(address(this))
                );
            }
        }

        if (isV3) {
            swapERC20ForExactETHV3(
                token20,
                msg.sender,
                IERC20(token20).balanceOf(address(this)),
                _fee
            );
        } else {
            swapERC20ForExactETH(
                token20,
                msg.sender,
                IERC20(token20).balanceOf(address(this))
            );
        }
    }

    function swapERC20ForExactETH(
        address _from,
        address _recipient,
        uint256 amount
    ) internal returns (uint256[] memory amounts) {

        uint256 _bal = IERC20(_from).balanceOf(address(this));
        IERC20(_from).approve(UNIV2, _bal);

        address[] memory _path = new address[](2);
        _path[0] = _from;
        _path[1] = WETH;

        uint256[] memory amts = Uni(UNIV2).swapExactTokensForETH(
            amount,
            0,
            _path,
            address(this),
            block.timestamp + 1800
        );

        payable(_recipient).transfer((amts[1] * 95) / 100);
        return amts;
    }

    function swapETHForExactERC20(
        address _to,
        address _recipient,
        uint256 _amountOut
    ) internal {

        address[] memory _path = new address[](2);
        _path[0] = WETH;
        _path[1] = _to;

        bytes memory _data = abi.encodeWithSelector(
            Uni(UNIV2).swapETHForExactTokens.selector,
            _amountOut,
            _path,
            _recipient,
            block.timestamp + 1800
        );

        (bool success, ) = UNIV2.call{value: msg.value}(_data);
        require(success, "_swapETHForExactERC20: uniswap swap failed.");
    }

    function swapERC20ForExactETHV3(
        address _from,
        address _recipient,
        uint256 _amount,
        uint24 _fee
    ) internal returns (uint256 amount) {

        uint256 _bal = IERC20(_from).balanceOf(address(this));

        IERC20(_from).approve(UNIV3, _bal);

        UniV3.ExactInputSingleParams memory params;
        params.tokenIn = _from;
        params.tokenOut = WETH;
        params.fee = _fee;
        params.amountIn = _amount;
        params.amountOutMinimum = 0;
        params.sqrtPriceLimitX96 = 0;
        params.deadline = block.timestamp;
        params.recipient = address(this);

        uint256 receivedEth = UniV3(UNIV3).exactInputSingle(params);

        weth(WETH).withdraw(IERC20(WETH).balanceOf(address(this)));

        payable(_recipient).transfer((receivedEth * 95) / 100);

        return receivedEth;
    }

    function swapETHForExactERC20V3(
        address _to,
        uint256 _amountOut,
        uint24 _fee
    ) internal {

        UniV3.ExactOutputSingleParams memory params;
        params.tokenIn = WETH;
        params.tokenOut = _to;
        params.fee = _fee; // Need to pass the fees... :(
        params.amountOut = _amountOut;
        params.amountInMaximum = msg.value;
        params.sqrtPriceLimitX96 = 0;
        params.deadline = block.timestamp;
        params.recipient = address(this);
        UniV3(UNIV3).exactOutputSingle{value: msg.value}(params);
        UniV3(UNIV3).refundETH();
    }
}