
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

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}


interface IGoaldDAO721 {

    function setGoaldOwner(uint256 id) external;

}


contract Goald721 {

    
    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;


    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);


    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    address _approvedTransferer;

    mapping(address => bool) _approveForAllAddresses;
    
    string  private _name;

    string  private _symbol;
    
    address internal _owner;

    uint256 internal _tokenId;

    
    address internal _daoAddress;

    constructor (string memory name, string memory symbol, uint256 tokenId) public {
        
        _supportedInterfaces[INTERFACE_ID_ERC165] = true;

        _supportedInterfaces[INTERFACE_ID_ERC721] = true;

        _supportedInterfaces[INTERFACE_ID_ERC721_METADATA] = true;



        _name    = name;
        _symbol  = symbol;
        _tokenId = tokenId;
    }


    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }


    function balanceOf(address owner) external view returns (uint256) {

        return owner == _owner ? 1 : 0;
    }

    function getApproved(uint256 tokenId) external view returns (address) {

        require(tokenId == _tokenId, "Wrong token id");

        return _approvedTransferer;
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {

        require(owner == _owner, "Not owner");

        return _approveForAllAddresses[operator];
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {

        return tokenId == _tokenId ? _owner : address(0);
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }


    function approve(address to, uint256 tokenId) external {

        require(
               tokenId == _tokenId
            && (
                   msg.sender == _owner
                || _approveForAllAddresses[msg.sender]
               )
        , "Wrong token or not authorized");

        _approvedTransferer = to;

        emit Approval(_owner, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, ""), "ERC721: not ERC721Receiver");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: not ERC721Receiver");
    }

    function setApprovalForAll(address operator, bool approved) external {

        require(msg.sender == _owner, "Not owner");

        _approveForAllAddresses[operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) external {

        _transfer(from, to, tokenId);
    }

    
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {

        uint256 size;
        assembly { size := extcodesize(to) }
        if (size == 0) {
            return true;
        }

        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            msg.sender,
            from,
            tokenId,
            _data
        ));
        if (success) {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == ERC721_RECEIVED);
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: not ERC721Receiver");
            }
        }
    }
    
    function _toString(uint256 value) internal pure returns (string memory) {


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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(
               to != address(0)
            && tokenId == _tokenId

            && from == _owner
            && (msg.sender == _owner || msg.sender ==_approvedTransferer || _approveForAllAddresses[msg.sender])
        , "Not authorized");

        _approvedTransferer = address(0);

        _owner = to;

        emit Transfer(from, to, tokenId);

        IGoaldDAO721(_daoAddress).setGoaldOwner(tokenId - 1);
    }
}


pragma solidity 0.6.12;


interface IGoaldDAO {

    function getNextGoaldId() external view returns (uint256);


    function getProxyAddress() external view returns (address);


    function getTokenURI(uint256 tokenId) external view returns (string memory);


    function getUniswapRouterAddress() external view returns (address);


    function isAllowedDeployer(address deployer) external view returns (bool);


    function notifyGoaldCreated(address creator, address goaldAddress) external;


    function setGoaldOwner(uint256 id) external;

}

contract GoaldFlexibleDeployer {

    address constant DAO_ADDRESS = 0x544664F896eD703Afa025c8465903249D8f1C65A;

    event GoaldDeployed(address goaldAddress);

    function deploy(
        address collateralToken,
        address paymentToken,
        uint96  fee,
        uint8   feeIntervalDays,
        uint16  totalIntervals,
        string memory name
    ) external returns (address) {

        IGoaldDAO latestDAO = IGoaldDAO(IGoaldDAO(DAO_ADDRESS).getProxyAddress());
        require(latestDAO.getProxyAddress() == address(latestDAO), "DAO address mismatch");
        require(latestDAO.isAllowedDeployer(address(this)), "Not allowed deployer");

        GoaldFlexible goald = new GoaldFlexible(
            address(latestDAO),
            msg.sender,
            name,
            latestDAO.getNextGoaldId(),
            collateralToken,
            paymentToken,
            latestDAO.getUniswapRouterAddress(),
            fee,
            feeIntervalDays,
            totalIntervals
        );
        address goaldAddress = address(goald);

        latestDAO.notifyGoaldCreated(msg.sender, goaldAddress);

        emit GoaldDeployed(goaldAddress);

        return goaldAddress;
    }
}

contract GoaldFlexible is Goald721 {

    uint256 private constant FEE_MASK                     = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant FEE_SHIFT                    = 0;

    uint256 private constant FEE_INTERVAL_DAYS_MASK       = 0x1FF000000000000000000000000000000000000000000;
    uint256 private constant FEE_INTERVAL_DAYS_SHIFT      = 168;

    uint256 private constant TOTAL_INTERVALS_MASK         = 0x1FFFFE00000000000000000000000000000000000000000000;
    uint256 private constant TOTAL_INTERVALS_SHIFT        = 177;

    uint256 private constant FINALIZATION_TIMESTAMP_MASK  = 0x1FFFFFFFFFFFE0000000000000000000000000000000000000000000000000;
    uint256 private constant FINALIZATION_TIMESTAMP_SHIFT = 197;

    uint256 private constant FINALIZED_MASK               = 0x20000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant FINALIZED_SHIFT              = 245;

    uint256 private constant FEE_DIVISOR = 400;


    address private _collateralAddress;

    address private _paymentAddress;

    address private _uniswapRouterAddress;

    address private _steward;

    uint256 private _staticValues;

    uint256 private _requiredTotalFeePaid;

    uint256 private _totalFeePaid;

    uint256 private constant RE_NOT_ENTERED = 1;
    uint256 private constant RE_ENTERED     = 2;
    uint256 private _status;


    event FeePaid(address paymentToken, uint256 feePaid, uint256 feeTokensSpent, uint256 collateralTokensReceived);

    event Withdrawal(uint256 amount);

    event RouterAddressChanged(address newAddress);

    event StewardChanged(address newSteward);


    modifier nonReentrant_OnlyOwnerSteward {

        require(_status == RE_NOT_ENTERED && (msg.sender == _owner || msg.sender == _steward));
        _status = RE_ENTERED;

        _;

        _status = RE_NOT_ENTERED;
    }

    modifier nonReentrant_OnlyOwnerSteward_InternalCallsOnly {

        require(_status == RE_NOT_ENTERED && (msg.sender == _owner || msg.sender == _steward));

        _;
    }

    modifier nonReentrant_Public {

        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        _;

        _status = RE_NOT_ENTERED;
    }


    constructor(
        address daoAddress,
        address owner,
        string memory name,
        uint256 goaldId,
        address collateralToken,
        address paymentToken,
        address uniswapRouterAddress,
        uint256 fee,
        uint256 feeIntervalDays,
        uint256 totalIntervals
    ) Goald721(name, "GOALD", goaldId) public {
        require(
               daoAddress      != address(0)
            && daoAddress      != address(this)
            && owner           != address(0)
            && owner           != address(this)
            && owner           != collateralToken
            && owner           != paymentToken
            && collateralToken != address(0)
            && collateralToken != address(this)
            && collateralToken != paymentToken
            && paymentToken    != address(0)
            && paymentToken    != address(this)

            && fee             > 0 && fee             <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF // uint168
            && feeIntervalDays > 0 && feeIntervalDays <= 0x1FF                                        // uint9
            && totalIntervals  > 0 && totalIntervals  <= 0xFFFFF                                      // uint20
        , "Invalid parameters");

        fee             = fee             & (FEE_MASK               >> FEE_SHIFT);
        feeIntervalDays = feeIntervalDays & (FEE_INTERVAL_DAYS_MASK >> FEE_INTERVAL_DAYS_SHIFT);
        totalIntervals  = totalIntervals  & (TOTAL_INTERVALS_MASK   >> TOTAL_INTERVALS_SHIFT);
        uint256 finalizationTimestamp = block.timestamp + (totalIntervals * feeIntervalDays * 1 days);

        _daoAddress           = daoAddress;
        _collateralAddress    = collateralToken;
        _paymentAddress       = paymentToken;
        _owner                = owner;
        _uniswapRouterAddress = uniswapRouterAddress;

        _requiredTotalFeePaid = fee * totalIntervals;
        _staticValues = 0
            | (fee                   << FEE_SHIFT)
            | (feeIntervalDays       << FEE_INTERVAL_DAYS_SHIFT)
            | (totalIntervals        << TOTAL_INTERVALS_SHIFT)
            | (finalizationTimestamp << FINALIZATION_TIMESTAMP_SHIFT);

        _status = RE_NOT_ENTERED;
    }


    function getDetails() external view returns (uint256[10] memory details) {

        address collateralAddress = _collateralAddress;

        details[0] = uint256(_daoAddress);
        details[1] = uint256(collateralAddress);
        details[2] = uint256(_paymentAddress);
        details[3] = uint256(_uniswapRouterAddress);
        details[4] = uint256(_steward);
        details[5] = uint256(_owner);

        details[6] = _tokenId;

        details[7] = _totalFeePaid;

        details[8] = IERC20(collateralAddress).balanceOf(address(this));

        details[9] = _staticValues;
    }


    function withdrawFromGoald(uint256 amount) external {

        uint256 values = _staticValues;
        uint256 finalized             = (values & FINALIZED_MASK)              >> FINALIZED_SHIFT;
        uint256 finalizationTimestamp = (values & FINALIZATION_TIMESTAMP_MASK) >> FINALIZATION_TIMESTAMP_SHIFT;

        address owner = _owner;
        require(
               _status == RE_NOT_ENTERED
            && msg.sender == owner
            && (
                   finalized > 0
                || block.timestamp >= finalizationTimestamp
            )
        , "Not authorized");
        _status = RE_ENTERED;

        IERC20 collateralToken = IERC20(_collateralAddress);
        uint256 currentGoaldBalance = collateralToken.balanceOf(address(this));
        uint256 currentOwnerBalance = collateralToken.balanceOf(owner);
        require(
               amount > 0
            && amount <= currentGoaldBalance
            && currentOwnerBalance + amount > currentOwnerBalance
        , "Invalid amount");

        require(collateralToken.transfer(owner, amount));

        require(
               collateralToken.balanceOf(address(this)) == currentGoaldBalance - amount
            && collateralToken.balanceOf(owner)         == currentOwnerBalance + amount
        , "Post transfer balance wrong");

        emit Withdrawal(amount);

        _status = RE_NOT_ENTERED;
    }
 

    function payFee(uint256 amount, address[] calldata swapPath, uint256 deadline) external nonReentrant_Public {

        require(swapPath.length > 1 && swapPath[swapPath.length - 1] == _collateralAddress, "Invalid swap path");

        amount = amount & (FEE_MASK >> FEE_SHIFT);

        address daoAddress = IGoaldDAO(_daoAddress).getProxyAddress();
        if (address(daoAddress) != daoAddress) {
            _daoAddress = daoAddress;
        }

        uint256[] memory amounts;
        uint256 receivedAmount;
        { // Scoped to prevent stack too deep error.
            IERC20 paymentContract = IERC20(swapPath[0]);
            uint256 fee = amount / FEE_DIVISOR;
            amount -= fee;
            require(paymentContract.transferFrom(msg.sender, address(this), amount)); 
            if (fee > 0) {
                require(paymentContract.transferFrom(msg.sender, daoAddress, fee));
            }

            IERC20 collateralContract = IERC20(_collateralAddress);
            uint256 currentCollateralBalance = collateralContract.balanceOf(address(this));

            address uniswapRouterAddress = _uniswapRouterAddress;
            require(paymentContract.approve(uniswapRouterAddress, amount));
            
            amounts = IUniswapV2Router02(uniswapRouterAddress).swapExactTokensForTokens(amount, 1, swapPath, address(this), deadline);

            receivedAmount = amounts[swapPath.length - 1];
            require(currentCollateralBalance + receivedAmount > currentCollateralBalance, "UNI: Overflow error");
            require(collateralContract.balanceOf(address(this)) == currentCollateralBalance + receivedAmount, "UNI: Wrong balance");

            require(paymentContract.approve(uniswapRouterAddress, 0));
        }

        if ((_staticValues & FINALIZED_MASK) >> FINALIZED_SHIFT == 0) {
            uint256 totalFeePaid = _totalFeePaid;
            uint256 newTotalFeePaid = totalFeePaid + amount;

            if (newTotalFeePaid < totalFeePaid) {
                _staticValues |= FINALIZED_MASK;
            } else if (newTotalFeePaid >= _requiredTotalFeePaid) {
                _staticValues |= FINALIZED_MASK;
            } else {
                _totalFeePaid = newTotalFeePaid;
            }
        }

        emit FeePaid(swapPath[0], amount, amounts[0], receivedAmount);
    }

    function transferERC20(address tokenAddress, uint256 amount) external nonReentrant_OnlyOwnerSteward {

        require(tokenAddress != _collateralAddress, "Invalid address");
        require(IERC20(tokenAddress).transfer(_owner, amount));
    }

    function updateRouterAddress(address newAddress) external nonReentrant_OnlyOwnerSteward_InternalCallsOnly {


        _uniswapRouterAddress = newAddress;

        emit RouterAddressChanged(newAddress);
    }

    function updateSteward(address newSteward) external nonReentrant_OnlyOwnerSteward_InternalCallsOnly {


        _steward = newSteward;

        emit StewardChanged(newSteward);
    }


    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(tokenId == _tokenId, "Wrong token");

        return IGoaldDAO(_daoAddress).getTokenURI(tokenId);
    }
}