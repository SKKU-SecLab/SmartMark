



pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}





pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity >= 0.8.0;

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
    ) payable external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) payable external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) payable external;

}





pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}





pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}





pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
}





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}





pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}





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
}





pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





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
}



pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}



pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}



pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}





pragma solidity >= 0.8.4;













contract SparkLink is Ownable, ERC165, IERC721, IERC721Metadata{

    using Address for address;
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    Counters.Counter private _issueIds;

    struct Edition {
        uint64 father_id;
        uint128 shill_price;
        uint16 remaining_shill_times;
        address owner;
        bytes32 ipfs_hash;
        uint128 transfer_price;
        uint128 profit;
    }

    event DeterminePrice(
        uint64 indexed NFT_id,
        uint128 transfer_price
    );

    event DeterminePriceAndApprove(
        uint64 indexed NFT_id,
        uint128 transfer_price,
        address indexed to
    );

    event Publish(
        address indexed publisher,
        uint64  indexed rootNFTId,
        address token_addr
    );

    event Claim(
        uint64 indexed NFT_id,
        address indexed receiver,
        uint128 amount
    );
    event SetURI(
        uint64 indexed NFT_id,
        bytes32 old_URI,
        bytes32 new_URI
    );

    event Label(
        uint64 indexed NFT_id,
        string content
    );

    event SetDAOFee(
        uint8 old_DAO_fee,
        uint8 new_DAO_fee
    );

    event SetLoosRatio(
        uint8 old_loss_ratio,
        uint8 new_loss_ratio
    );

    event SetDAORouter01(
        address old_router_address,
        address new_router_address
    );

    event SetDAORouter02(
        address old_router_address,
        address new_router_address
    );

    constructor(address DAO_router_address01,address DAO_router_address02, address uniswapRouterAddress, address factoryAddress) {
        uniswapV2Router =  IUniswapV2Router02(uniswapRouterAddress);
        uniswapV2Factory = IUniswapV2Factory(factoryAddress);
        DAO_router01 = DAO_router_address01;
        DAO_router02 = DAO_router_address02;
        _name = "SparkLink";
        _symbol = "SPL";
    } 
    
    function publish(
        uint128 _first_sell_price,
        uint8 _royalty_fee,
        uint16 _shill_times,
        bytes32 _ipfs_hash,
        address _token_addr,
        bool _is_free,
        bool _is_NC,
        bool _is_ND
    ) 
        external 
    {

        require(_royalty_fee <= 100, "SparkLink: Royalty fee should be <= 100%.");
        _issueIds.increment();
        require(_issueIds.current() <= type(uint32).max, "SparkLink: Value doesn't fit in 32 bits.");
        if (_token_addr != address(0))
            require(IERC20(_token_addr).totalSupply() > 0, "Not a valid ERC20 token address");
        uint32 new_issue_id = uint32(_issueIds.current());
        uint64 rootNFTId = getNftIdByEditionIdAndIssueId(new_issue_id, 1);
        require(
            _checkOnERC721Received(address(0), msg.sender, rootNFTId, ""),
            "SparkLink: Transfer to non ERC721Receiver implementer"
        );

        Edition storage new_NFT = editions_by_id[rootNFTId];
        uint64 information;
        information = reWriteUint8InUint64(56, _royalty_fee, information);
        information = reWriteUint16InUint64(40, _shill_times, information);
        information = reWriteBoolInUint64(37, _is_free, information);
        information = reWriteBoolInUint64(38, _is_NC, information);
        information = reWriteBoolInUint64(39, _is_ND, information);
        information += 1;
        token_addresses[new_issue_id] = _token_addr;
        new_NFT.father_id = information;
        new_NFT.remaining_shill_times = _shill_times;
        new_NFT.shill_price = _first_sell_price;
        new_NFT.owner = msg.sender;
        new_NFT.ipfs_hash = _ipfs_hash;
        _balances[msg.sender] += 1;
        emit Transfer(address(0), msg.sender, rootNFTId);
        emit Publish(
            msg.sender,
            rootNFTId,
            _token_addr
        );
    }

    function acceptShill(
        uint64 _NFT_id
    ) 
        external 
        payable 
    {

        require(isEditionExisting(_NFT_id), "SparkLink: This NFT does not exist");
        require(editions_by_id[_NFT_id].remaining_shill_times > 0, "SparkLink: There is no remaining shill time for this NFT");
        if (!isRootNFT(_NFT_id)||!getIsFreeByNFTId(_NFT_id)){
            address token_addr = getTokenAddrByNFTId(_NFT_id);
            if (token_addr == address(0)){
                require(msg.value == editions_by_id[_NFT_id].shill_price, "SparkLink: Wrong price");
                _addProfit( _NFT_id, editions_by_id[_NFT_id].shill_price);
            }
            else {
                uint256 before_balance = IERC20(token_addr).balanceOf(address(this));
                IERC20(token_addr).safeTransferFrom(msg.sender, address(this), editions_by_id[_NFT_id].shill_price);
                _addProfit( _NFT_id, uint256toUint128(IERC20(token_addr).balanceOf(address(this))-before_balance));
            }
        }
        editions_by_id[_NFT_id].remaining_shill_times -= 1;
        _mintNFT(_NFT_id, msg.sender);
        if (editions_by_id[_NFT_id].remaining_shill_times == 0)
            _mintNFT(_NFT_id, ownerOf(_NFT_id));
    }

    function transferFrom(address from, address to, uint256 tokenId) external payable override {

        _transfer(from, to, uint256toUint64(tokenId));
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable override{

       _safeTransfer(from, to, uint256toUint64(tokenId), "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata _data) external payable override {

        _safeTransfer(from, to, uint256toUint64(tokenId), _data);
    }
    
    function claimProfit(uint64 _NFT_id) public {

        require(isEditionExisting(_NFT_id), "SparkLink: This edition does not exist");
        
        if (editions_by_id[_NFT_id].profit != 0) {
            uint128 amount = editions_by_id[_NFT_id].profit;
            address token_addr = getTokenAddrByNFTId(_NFT_id);
            if (DAO_fee != 0) {
                uint128 DAO_amount = calculateFee(amount, DAO_fee);
                amount -= DAO_amount;
                if (token_addr == address(0)) {
                    payable(DAO_router01).transfer(DAO_amount);
                }
                else if (uniswapV2Factory.getPair(token_addr, uniswapV2Router.WETH()) == address(0)) {
                    IERC20(token_addr).safeTransfer(DAO_router02,DAO_amount);
                }
                else {
                    _swapTokensForEth(token_addr, DAO_amount);
                }
            }
            editions_by_id[_NFT_id].profit = 0;
            if (!isRootNFT(_NFT_id)) {
                uint128 _royalty_fee = calculateFee(amount, getRoyaltyFeeByNFTId(_NFT_id));
                _addProfit(getFatherByNFTId(_NFT_id), _royalty_fee);
                amount -= _royalty_fee;
            }
            if (token_addr == address(0)){
                payable(ownerOf(_NFT_id)).transfer(amount);
            }
            else {
                IERC20(token_addr).safeTransfer(ownerOf(_NFT_id), amount);
            }
            emit Claim(
                _NFT_id,
                ownerOf(_NFT_id),
                amount
            );
        }
    }

    function setURI(uint64 _NFT_id, bytes32 ipfs_hash) public {

        if (getIsNDByNFTId(_NFT_id)) {
            require(_NFT_id == getRootNFTIdByNFTId(_NFT_id), "SparkLink: NFT follows the ND protocol, only the root NFT's URI can be set.");
        }
        require(ownerOf(_NFT_id) == msg.sender, "SparkLink: Only owner can set the token URI");
        _setTokenURI(_NFT_id, ipfs_hash);
    }

    function updateURI(uint64 _NFT_id) public{

        require(ownerOf(_NFT_id) == msg.sender, "SparkLink: Only owner can update the token URI");
        editions_by_id[_NFT_id].ipfs_hash = editions_by_id[getRootNFTIdByNFTId(_NFT_id)].ipfs_hash;
    }

    function label(uint64 _NFT_id, string memory content) public {

        require(ownerOf(_NFT_id) == msg.sender, "SparkLink: Only owner can label this NFT");
        emit Label(_NFT_id, content);
    }
    function determinePrice(
        uint64 _NFT_id,
        uint128 _price
    ) 
        public 
    {

        require(isEditionExisting(_NFT_id), "SparkLink: This NFT does not exist");
        require(msg.sender == ownerOf(_NFT_id), "SparkLink: Only owner can set the price");
        editions_by_id[_NFT_id].transfer_price = _price;
        emit DeterminePrice(_NFT_id, _price);
    }

    function determinePriceAndApprove(
        uint64 _NFT_id,
        uint128 _price,
        address _to
    ) 
        public 
    {

        determinePrice(_NFT_id, _price);
        approve(_to, _NFT_id);
        emit DeterminePriceAndApprove(_NFT_id, _price, _to);
    }

    function setDAOFee(uint8 _DAO_fee) public onlyOwner {

        require(_DAO_fee <= MAX_DAO_FEE, "SparkLink: DAO fee can not exceed 5%");
        emit SetDAOFee(DAO_fee, _DAO_fee);
        DAO_fee = _DAO_fee;
    }

    function setDAORouter01(address _DAO_router01) public onlyOwner {

        emit SetDAORouter01(DAO_router01, _DAO_router01);
        DAO_router01 = _DAO_router01;
    }

    function setDAORouter02(address _DAO_router02) public onlyOwner {

        emit SetDAORouter01(DAO_router02, _DAO_router02);
        DAO_router02 = _DAO_router02;
    }

    function setUniswapV2Router(address _uniswapV2Router) public onlyOwner {

        uniswapV2Router =  IUniswapV2Router02(_uniswapV2Router);
    }
    function setUniswapV2Factory(address _uniswapV2Factory) public onlyOwner {

        uniswapV2Factory = IUniswapV2Factory(_uniswapV2Factory);
    }

    function setLoosRatio(uint8 _loss_ratio) public onlyOwner {

        require(_loss_ratio <= MAX_LOSS_RATIO, "SparkLink: Loss ratio can not below 50%");
        emit SetLoosRatio(loss_ratio, _loss_ratio);
        loss_ratio = _loss_ratio;
    }
    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "SparkLink: Approval to current owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "SparkLink: Approve caller is not owner nor approved for all"
        );

        _approve(to, uint256toUint64(tokenId));
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "SparkLink: Approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "SparkLink: Balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = editions_by_id[uint256toUint64(tokenId)].owner;
        require(owner != address(0), "SparkLink: Owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }
    

    function getNFTInfoByNFTID(uint64 _NFT_id) 
        public view  
        returns (
            uint64 issue_information,
            uint64 father_id,
            uint128 shill_price,
            uint16 remain_shill_times,
            uint128 profit,
            string memory metadata
            ) 
    {

        require(isEditionExisting(_NFT_id), "SparkLink: Approved query for nonexistent token");
        return(
            editions_by_id[getRootNFTIdByNFTId(_NFT_id)].father_id,
            getFatherByNFTId(_NFT_id),
            editions_by_id[_NFT_id].shill_price,
            getRemainShillTimesByNFTId(_NFT_id),
            getProfitByNFTId(_NFT_id),
            tokenURI(_NFT_id)
        );
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(isEditionExisting(uint256toUint64(tokenId)), "SparkLink: Approved query for nonexistent token");

        return _tokenApprovals[uint256toUint64(tokenId)];
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(isEditionExisting(uint256toUint64(tokenId)), "SparkLink: URI query for nonexistent token");
        bytes32 _ipfs_hash = editions_by_id[uint256toUint64(tokenId)].ipfs_hash;
        string memory encoded_hash = _toBase58String(_ipfs_hash);
        string memory base = _baseURI();
        return string(abi.encodePacked(base, encoded_hash));
    }

    function getIsFreeByNFTId(uint64 _NFT_id) public view returns (bool) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return getBoolFromUint64(37, editions_by_id[getRootNFTIdByNFTId(_NFT_id)].father_id);
    }

    function getIsNCByNFTId(uint64 _NFT_id) public view returns (bool) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return getBoolFromUint64(38, editions_by_id[getRootNFTIdByNFTId(_NFT_id)].father_id);
    }

    function getIsNDByNFTId(uint64 _NFT_id) public view returns (bool) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return getBoolFromUint64(39, editions_by_id[getRootNFTIdByNFTId(_NFT_id)].father_id);
    }

    function isEditionExisting(uint64 _NFT_id) public view returns (bool) {

        return (editions_by_id[_NFT_id].owner != address(0));
    }

    function getProfitByNFTId(uint64 _NFT_id) public view returns (uint128){

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        uint128 amount = editions_by_id[_NFT_id].profit;
         if (DAO_fee != 0) {
                uint128 DAO_amount = calculateFee(amount, DAO_fee);
                amount -= DAO_amount;
        }
        if (!isRootNFT(_NFT_id)) {
            uint128 _total_fee = calculateFee(amount, getRoyaltyFeeByNFTId(_NFT_id));            
            amount -= _total_fee;
        }
        return amount;
    }

    function getRoyaltyFeeByNFTId(uint64 _NFT_id) public view returns (uint8) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return getUint8FromUint64(56, editions_by_id[getRootNFTIdByNFTId(_NFT_id)].father_id);
    }

    function getShillTimesByNFTId(uint64 _NFT_id) public view returns (uint16) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return getUint16FromUint64(40, editions_by_id[getRootNFTIdByNFTId(_NFT_id)].father_id);
    }

    function getTotalAmountByNFTId(uint64 _NFT_id) public view returns (uint32) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return getBottomUint32FromUint64(editions_by_id[getRootNFTIdByNFTId(_NFT_id)].father_id);
    }

    function getTokenAddrByNFTId(uint64 _NFT_id) public view returns (address) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return token_addresses[uint32(_NFT_id>>32)];
    }

    function getFatherByNFTId(uint64 _NFT_id) public view returns (uint64) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        if (isRootNFT(_NFT_id)) {
            return 0;
        }
        return editions_by_id[_NFT_id].father_id;
    }    
    
    function getTransferPriceByNFTId(uint64 _NFT_id) public view returns (uint128) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return editions_by_id[_NFT_id].transfer_price;
    }

    function getShillPriceByNFTId(uint64 _NFT_id) public view returns (uint128) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        if (getIsFreeByNFTId(_NFT_id)&&isRootNFT(_NFT_id))
            return 0;
        else
            return editions_by_id[_NFT_id].shill_price;
    }

    function getRemainShillTimesByNFTId(uint64 _NFT_id) public view returns (uint16) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        return editions_by_id[_NFT_id].remaining_shill_times;
    }

    function getDepthByNFTId(uint64 _NFT_id) public view returns (uint64) {

        require(isEditionExisting(_NFT_id), "SparkLink: Edition is not exist.");
        uint64 depth = 0;
        for (depth = 0; !isRootNFT(_NFT_id); _NFT_id = getFatherByNFTId(_NFT_id)) {
            depth += 1;
        }
        return depth;
    }

    function isRootNFT(uint64 _NFT_id) public pure returns (bool) {

        return getBottomUint32FromUint64(_NFT_id) == uint32(1);
    }

    function getRootNFTIdByNFTId(uint64 _NFT_id) public pure returns (uint64) {

        return ((_NFT_id>>32)<<32 | uint64(1));
    }

    function getLossRatio() public view returns (uint8) {

        return loss_ratio;
    }
    
    function getEditionIdByNFTId(uint64 _NFT_id) public pure returns (uint32) {

        return getBottomUint32FromUint64(_NFT_id);
    }
    string private _name;

    string private _symbol;
    uint8 public loss_ratio = 62;
    uint8 public DAO_fee = 2;
    uint8 public constant MAX_DAO_FEE = 2;
    uint8 public constant MAX_LOSS_RATIO = 50;
    address public DAO_router01;
    address public DAO_router02;
    IUniswapV2Router02 public  uniswapV2Router;
    IUniswapV2Factory public  uniswapV2Factory;
    mapping(address => uint64) private _balances;
    mapping(uint64 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping (uint64 => Edition) private editions_by_id;
    mapping(uint32 => address) private token_addresses;

    bytes constant private sha256MultiHash = hex"1220"; 
    bytes constant private ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

    function _swapTokensForEth(address token_addr, uint128 token_amount) private {

        address[] memory path = new address[](2);
        path[0] = token_addr;
        path[1] = uniswapV2Router.WETH();

        IERC20(token_addr).approve(address(uniswapV2Router), token_amount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            token_amount,
            0, // accept any amount of ETH
            path,
            DAO_router01,
            block.timestamp
        );
    }


    function _checkOnERC721Received(
        address from,
        address to,
        uint64 tokenId,
        bytes memory _data
    ) 
        private 
        returns (bool) 
    {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("SparkLink: Transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _setTokenURI(uint64 tokenId, bytes32 ipfs_hash) internal virtual {

        bytes32 old_URI = editions_by_id[tokenId].ipfs_hash;
        editions_by_id[tokenId].ipfs_hash = ipfs_hash;
        emit SetURI(tokenId, old_URI, ipfs_hash);
    }
    
    function _mintNFT(
        uint64 _NFT_id,
        address _owner
    ) 
        internal 
        returns (uint64) 
    {

        _addTotalAmount(_NFT_id);
        uint32 new_edition_id = getTotalAmountByNFTId(_NFT_id);
        uint64 new_NFT_id = getNftIdByEditionIdAndIssueId(uint32(_NFT_id>>32), new_edition_id);
        require(
            _checkOnERC721Received(address(0), _owner, new_NFT_id, ""),
            "SparkLink: Transfer to non ERC721Receiver implementer"
        );
        Edition storage new_NFT = editions_by_id[new_NFT_id];
        new_NFT.remaining_shill_times = getShillTimesByNFTId(_NFT_id);
        new_NFT.father_id = _NFT_id;
        if (getIsFreeByNFTId(_NFT_id)&&isRootNFT(_NFT_id))
            new_NFT.shill_price = editions_by_id[_NFT_id].shill_price;
        else
            new_NFT.shill_price = calculateFee(editions_by_id[_NFT_id].shill_price, loss_ratio);
        if (new_NFT.shill_price == 0) {
            new_NFT.shill_price = editions_by_id[_NFT_id].shill_price;
        }
        new_NFT.owner = _owner;
        new_NFT.ipfs_hash = editions_by_id[_NFT_id].ipfs_hash;
        _balances[_owner] += 1;
        emit Transfer(address(0), _owner, new_NFT_id);
        return new_NFT_id;
    }

    function _afterTokenTransfer (uint64 _NFT_id) internal {
        _approve(address(0), _NFT_id);
        editions_by_id[_NFT_id].transfer_price = 0;
    }

    function _transfer(
        address from,
        address to,
        uint64 tokenId
    ) 
        internal 
        virtual 
    {

        require(ownerOf(tokenId) == from, "SparkLink: Transfer of token that is not own");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "SparkLink: Transfer caller is not owner nor approved");
        require(to != address(0), "SparkLink: Transfer to the zero address");
        if (msg.sender != ownerOf(tokenId)) {
            address token_addr = getTokenAddrByNFTId(tokenId);
            uint128 transfer_price = editions_by_id[tokenId].transfer_price;
            if (token_addr == address(0)){
                require(msg.value == transfer_price, "SparkLink: Price not met");
                _addProfit(tokenId, transfer_price);
            }
            else {
                uint256 before_balance = IERC20(token_addr).balanceOf(address(this));
                IERC20(token_addr).safeTransferFrom(msg.sender, address(this), transfer_price);
                _addProfit(tokenId, uint256toUint128(IERC20(token_addr).balanceOf(address(this))-before_balance));
            }
            claimProfit(tokenId);
        }
        else {
            claimProfit(tokenId);
        }
        _afterTokenTransfer(tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        editions_by_id[tokenId].owner = to;
        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(
        address from,
        address to,
        uint64 tokenId,
        bytes memory _data
    ) 
        internal 
        virtual 
    {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "SparkLink: Transfer to non ERC721Receiver implementer");
    }

    function _approve(address to, uint64 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _addProfit(uint64 _NFT_id, uint128 _increase) internal {

        editions_by_id[_NFT_id].profit = editions_by_id[_NFT_id].profit+_increase;
    }

    function _addTotalAmount(uint64 _NFT_Id) internal {

        require(getTotalAmountByNFTId(_NFT_Id) < type(uint32).max, "SparkLink: There is no left in this issue.");
        editions_by_id[getRootNFTIdByNFTId(_NFT_Id)].father_id += 1;
    }

    function _isApprovedOrOwner(address spender, uint64 tokenId) internal view virtual returns (bool) {

        require(isEditionExisting(tokenId), "SparkLink: Operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
        
    function _baseURI() internal pure returns (string memory) {

        return "https://ipfs.io/ipfs/";
    } 


    function getNftIdByEditionIdAndIssueId(uint32 _issue_id, uint32 _edition_id) internal pure returns (uint64) {

        return (uint64(_issue_id)<<32)|uint64(_edition_id);
    }

    function getBoolFromUint64(uint8 position, uint64 data64) internal pure returns (bool flag) {

        assembly {
            flag := and(1, shr(position, data64))
        }
    }

    function getUint8FromUint64(uint8 position, uint64 data64) internal pure returns (uint8 data8) {

        assembly {
            data8 := and(sub(shl(8, 1), 1), shr(position, data64))
        }
    }
    function getUint16FromUint64(uint8 position, uint64 data64) internal pure returns (uint16 data16) {

        assembly {
            data16 := and(sub(shl(16, 1), 1), shr(position, data64))
        }
    }
    function getBottomUint32FromUint64(uint64 data64) internal pure returns (uint32 data32) {

        assembly {
            data32 := and(sub(shl(32, 1), 1), data64)
        }
    }

    function reWriteBoolInUint64(uint8 position, bool flag, uint64 data64) internal pure returns (uint64 boxed) {

        assembly {
            boxed := or( and(data64, not(shl(position, 1))), shl(position, flag))
        }
    }

    
    function reWriteUint8InUint64(uint8 position, uint8 flag, uint64 data64) internal pure returns (uint64 boxed) {

        assembly {
            boxed := or(and(data64, not(shl(position, 1))), shl(position, flag))
        }
    }

    function reWriteUint16InUint64(uint8 position, uint16 data16, uint64 data64) internal pure returns (uint64 boxed) {

        assembly {
            boxed := or( and(data64, not(shl(position, sub(shl(16, 1), 1)))), shl(position, data16))
        }
    }

    function uint256toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SparkLink: Value doesn't fit in 64 bits");
        return uint64(value);
    }

    function uint256toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SparkLink: Value doesn't fit in 128 bits");
        return uint128(value);
    }
    
    function calculateFee(uint128 _amount, uint8 _fee_percent) internal pure returns (uint128) {

        return _amount*_fee_percent/10**2;
    }

    function _toBase58String(bytes32 con) internal pure returns (string memory) {

        
        bytes memory source = bytes.concat(sha256MultiHash,con);

        uint8[] memory digits = new uint8[](64); //TODO: figure out exactly how much is needed
        digits[0] = 0;
        uint8 digitlength = 1;
        for (uint256 i = 0; i<source.length; ++i) {
        uint carry = uint8(source[i]);
        for (uint256 j = 0; j<digitlength; ++j) {
            carry += uint(digits[j]) * 256;
            digits[j] = uint8(carry % 58);
            carry = carry / 58;
        }
        
        while (carry > 0) {
            digits[digitlength] = uint8(carry % 58);
            digitlength++;
            carry = carry / 58;
        }
        }
        return string(toAlphabet(reverse(truncate(digits, digitlength))));
    }

    function toAlphabet(uint8[] memory indices) internal pure returns (bytes memory) {

        bytes memory output = new bytes(indices.length);
        for (uint256 i = 0; i<indices.length; i++) {
            output[i] = ALPHABET[indices[i]];
        }
        return output;
    }
    
    function truncate(uint8[] memory array, uint8 length) internal pure returns (uint8[] memory) {

        uint8[] memory output = new uint8[](length);
        for (uint256 i = 0; i<length; i++) {
            output[i] = array[i];
        }
        return output;
    }
  
    function reverse(uint8[] memory input) internal pure returns (uint8[] memory) {

        uint8[] memory output = new uint8[](input.length);
        for (uint256 i = 0; i<input.length; i++) {
            output[i] = input[input.length-1-i];
        }
        return output;
    }
}