


pragma solidity 0.8.10;

interface INFTOracle {

    function getAssetPrice(address _nftContract)
        external
        view
        returns (uint256);

}



pragma solidity 0.8.10;

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

}



pragma solidity 0.8.10;

interface IUniswapV2Router01 {

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

}



pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

}




pragma solidity 0.8.10;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity 0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity 0.8.10;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



pragma solidity 0.8.10;

library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        unchecked {
            require((z = x + y) >= x);
        }
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        unchecked {
            require((z = x - y) <= x);
        }
    }

    function sub(
        uint256 x,
        uint256 y,
        string memory message
    ) internal pure returns (uint256 z) {

        unchecked {
            require((z = x - y) <= x, message);
        }
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        unchecked {
            require(x == 0 || (z = x * y) / x == y);
        }
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x / y;
    }
}



pragma solidity 0.8.10;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
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




pragma solidity 0.8.10;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}



pragma solidity 0.8.10;






contract OmniFallbackOracle {
    address public immutable BEND_DAO;
    address public immutable UNISWAP_FACTORY;
    address public immutable UNISWAP_ROUTER;
    address public immutable WETH;
    address public immutable USDC;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

    constructor(
        address bendDAO,
        address uniswapFactory,
        address uniswapRouter,
        address weth,
        address usdc
    ) {
        BEND_DAO = bendDAO;
        UNISWAP_FACTORY = uniswapFactory;
        UNISWAP_ROUTER = uniswapRouter;
        WETH = weth;
        USDC = usdc;
    }

    function getAssetPrice(address asset) public view returns (uint256) {
        try IERC165(asset).supportsInterface(_InterfaceId_ERC721) returns (
            bool supported
        ) {
            if (supported == true) {
                return INFTOracle(BEND_DAO).getAssetPrice(asset);
            }
        } catch (
            bytes memory /*lowLevelData*/
        ) {
            address pairAddress = IUniswapV2Factory(UNISWAP_FACTORY).getPair(
                WETH,
                asset
            );
            require(pairAddress != address(0x00), "pair not found");
            IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
            (uint256 left, uint256 right, ) = pair.getReserves();
            (uint256 tokenReserves, uint256 ethReserves) = (asset < WETH)
                ? (left, right)
                : (right, left);
            uint8 decimals = ERC20(asset).decimals();
            return
                IUniswapV2Router01(UNISWAP_ROUTER).getAmountOut(
                    10**decimals,
                    tokenReserves,
                    ethReserves
                );
        }
    }

    function getEthUsdPrice() public view returns (uint256) {
        address pairAddress = IUniswapV2Factory(UNISWAP_FACTORY).getPair(
            USDC,
            WETH
        );
        require(pairAddress != address(0x00), "pair not found");
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint256 left, uint256 right, ) = pair.getReserves();
        (uint256 usdcReserves, uint256 ethReserves) = (USDC < WETH)
            ? (left, right)
            : (right, left);
        uint8 ethDecimals = ERC20(WETH).decimals();
        uint8 usdcDecimals = ERC20(USDC).decimals();
        return
            IUniswapV2Router01(UNISWAP_ROUTER).getAmountOut(
                10**ethDecimals,
                ethReserves,
                usdcReserves
            );
    }
}