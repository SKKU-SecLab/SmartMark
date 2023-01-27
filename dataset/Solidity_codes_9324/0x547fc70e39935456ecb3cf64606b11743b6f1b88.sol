



pragma solidity ^0.8.6;

interface IFortFutures {

    
    struct FutureView {
        uint index;
        address tokenAddress;
        uint lever;
        bool orientation;
        
        uint balance;
        uint basePrice;
        uint baseBlock;
    }

    event New(
        address tokenAddress, 
        uint lever,
        bool orientation,
        uint index
    );

    event Buy(
        uint index,
        uint dcuAmount,
        address owner
    );

    event Sell(
        uint index,
        uint amount,
        address owner,
        uint value
    );

    event Settle(
        uint index,
        address addr,
        address sender,
        uint reward
    );
    
    function balanceOf(uint index, uint oraclePrice, address addr) external view returns (uint);


    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (FutureView[] memory futureArray);


    function list(uint offset, uint count, uint order) external view returns (FutureView[] memory futureArray);


    function create(address tokenAddress, uint[] calldata levers, bool orientation) external;


    function getFutureCount() external view returns (uint);


    function getFutureInfo(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) external view returns (FutureView memory);


    function buy(
        address tokenAddress,
        uint lever,
        bool orientation,
        uint dcuAmount
    ) external payable;


    function buyDirect(uint index, uint dcuAmount) external payable;


    function sell(uint index, uint amount) external payable;


    function settle(uint index, address[] calldata addresses) external payable;


    function calcRevisedK(uint sigmaSQ, uint p0, uint bn0, uint p, uint bn) external view returns (uint k);


    function impactCost(uint vol) external pure returns (uint);

}




pragma solidity ^0.8.6;

contract ChainParameter {


    uint constant BLOCK_TIME = 14;

    uint constant MIN_PERIOD = 180000;

    uint constant MIN_EXERCISE_BLOCK = 180000;
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




pragma solidity ^0.8.6;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value,gas:5000}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}




pragma solidity ^0.8.6;

interface IHedgeDAO {


    event ApplicationChanged(address addr, uint flag);
    
    function setApplication(address addr, uint flag) external;


    function checkApplication(address addr) external view returns (uint);


    function addETHReward(address pool) external payable;


    function totalETHRewards(address pool) external view returns (uint);


    function settle(address pool, address tokenAddress, address to, uint value) external payable;

}




pragma solidity ^0.8.6;

interface IHedgeMapping {


    function setBuiltinAddress(
        address dcuToken,
        address hedgeDAO,
        address hedgeOptions,
        address hedgeFutures,
        address hedgeVaultForStaking,
        address nestPriceFacade
    ) external;


    function getBuiltinAddress() external view returns (
        address dcuToken,
        address hedgeDAO,
        address hedgeOptions,
        address hedgeFutures,
        address hedgeVaultForStaking,
        address nestPriceFacade
    );


    function getDCUTokenAddress() external view returns (address);


    function getHedgeDAOAddress() external view returns (address);


    function getHedgeOptionsAddress() external view returns (address);


    function getHedgeFuturesAddress() external view returns (address);


    function getHedgeVaultForStakingAddress() external view returns (address);


    function getNestPriceFacade() external view returns (address);


    function registerAddress(string calldata key, address addr) external;


    function checkAddress(string calldata key) external view returns (address);

}




pragma solidity ^0.8.6;
interface IHedgeGovernance is IHedgeMapping {


    function setGovernance(address addr, uint flag) external;


    function getGovernance(address addr) external view returns (uint);


    function checkGovernance(address addr, uint flag) external view returns (bool);

}




pragma solidity ^0.8.6;
contract HedgeBase {


    address public _governance;

    function initialize(address governance) public virtual {

        require(_governance == address(0), "Hedge:!initialize");
        _governance = governance;
    }

    function update(address newGovernance) public virtual {


        address governance = _governance;
        require(governance == msg.sender || IHedgeGovernance(governance).checkGovernance(msg.sender, 0), "Hedge:!gov");
        _governance = newGovernance;
    }


    modifier onlyGovernance() {

        require(IHedgeGovernance(_governance).checkGovernance(msg.sender, 0), "Hedge:!gov");
        _;
    }
}




pragma solidity ^0.8.6;
contract HedgeFrequentlyUsed is HedgeBase {


    address constant DCU_TOKEN_ADDRESS = 0xf56c6eCE0C0d6Fbb9A53282C0DF71dBFaFA933eF;

    address constant NEST_OPEN_PRICE = 0xE544cF993C7d477C7ef8E91D28aCA250D135aa03;
    
    uint constant USDT_BASE = 1 ether;
}




pragma solidity ^0.8.6;

interface INestBatchPrice2 {


    function triggeredPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        address payback
    ) external payable returns (uint[] memory prices);


    function triggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        address payback
    ) external payable returns (uint[] memory prices);


    function findPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        uint height, 
        address payback
    ) external payable returns (uint[] memory prices);


    function lastPriceList(
        uint channelId, 
        uint[] calldata pairIndices, 
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);


    function lastPriceListAndTriggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);

}




pragma solidity ^0.8.6;
contract FortPriceAdapter is HedgeFrequentlyUsed {

    
    struct TokenConfig {
        uint16 channelId;
        uint16 pairIndex;

        uint64 sigmaSQ;
        uint64 miuLong;
        uint64 miuShort;
    }

    uint constant POST_UNIT = 2000 * USDT_BASE;

    function _pairIndices(uint pairIndex) private pure returns (uint[] memory pairIndices) {

        pairIndices = new uint[](1);
        pairIndices[0] = pairIndex;
    }

    function _lastPriceList(
        TokenConfig memory tokenConfig, 
        uint fee, 
        address payback
    ) internal returns (uint[] memory prices) {

        prices = INestBatchPrice2(NEST_OPEN_PRICE).lastPriceList {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), 2, payback);

        prices[1] = _toUSDTPrice(prices[1]);
        prices[3] = _toUSDTPrice(prices[3]);
    }

    function _latestPrice(
        TokenConfig memory tokenConfig, 
        uint fee, 
        address payback
    ) internal returns (uint oraclePrice) {

        uint[] memory prices = INestBatchPrice2(NEST_OPEN_PRICE).lastPriceList {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), 1, payback);

        oraclePrice = _toUSDTPrice(prices[1]);
    }

    function _findPrice(
        TokenConfig memory tokenConfig, 
        uint blockNumber, 
        uint fee, 
        address payback
    ) internal returns (uint oraclePrice) {

        uint[] memory prices = INestBatchPrice2(NEST_OPEN_PRICE).findPrice {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), blockNumber, payback);

        oraclePrice = _toUSDTPrice(prices[1]);
    }

    function _toUSDTPrice(uint rawPrice) internal pure returns (uint) {

        return POST_UNIT * 1 ether / rawPrice;
    }
}




pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}




pragma solidity ^0.8.6;
contract DCU is HedgeBase, ERC20("Decentralized Currency Unit", "DCU") {

    mapping(address=>uint) _minters;

    constructor() {
    }

    modifier onlyMinter {
        require(_minters[msg.sender] == 1, "DCU:not minter");
        _;
    }

    function setMinter(address account, uint flag) external onlyGovernance {
        _minters[account] = flag;
    }

    function checkMinter(address account) external view returns (uint) {
        return _minters[account];
    }

    function mint(address to, uint value) external onlyMinter {
        _mint(to, value);
    }

    function burn(address from, uint value) external onlyMinter {
        _burn(from, value);
    }
}




pragma solidity ^0.8.6;
contract FortFutures is ChainParameter, HedgeFrequentlyUsed, FortPriceAdapter, IFortFutures {

    struct Account {
        uint128 balance;
        uint64 basePrice;
        uint32 baseBlock;
    }

    struct FutureInfo {
        address tokenAddress; 
        uint32 lever;
        bool orientation;

        uint16 tokenIndex;
        
        mapping(address=>Account) accounts;
    }

    uint constant MIN_VALUE = 10 ether;

    mapping(uint=>uint) _futureMapping;

    mapping(address=>uint) _bases;

    FutureInfo[] _futures;

    mapping(address=>uint) _tokenMapping;

    TokenConfig[] _tokenConfigs;

    constructor() {
    }

    function initialize(address governance) public override {
        super.initialize(governance);
        _futures.push();
    }

    function register(address tokenAddress, TokenConfig calldata tokenConfig) external onlyGovernance {

        uint index = _tokenMapping[tokenAddress];
        
        if (index == 0) {
            _tokenConfigs.push(tokenConfig);
            index = _tokenConfigs.length;
            require(index < 0x10000, "FO:too much tokenConfigs");
            _tokenMapping[tokenAddress] = index;
        } else {
            _tokenConfigs[index - 1] = tokenConfig;
        }
    }

    function balanceOf(uint index, uint oraclePrice, address addr) external view override returns (uint) {
        FutureInfo storage fi = _futures[index];
        Account memory account = fi.accounts[addr];
        return _balanceOf(
            _tokenConfigs[fi.tokenIndex],
            uint(account.balance), 
            _decodeFloat(account.basePrice), 
            uint(account.baseBlock),
            oraclePrice, 
            fi.orientation, 
            uint(fi.lever)
        );
    }

    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view override returns (FutureView[] memory futureArray) {
        
        futureArray = new FutureView[](count);
        
        FutureInfo[] storage futures = _futures;
        uint i = futures.length;
        uint end = 0;
        if (start > 0) {
            i = start;
        }
        if (i > maxFindCount) {
            end = i - maxFindCount;
        }
        
        for (uint index = 0; index < count && i > end;) {
            FutureInfo storage fi = futures[--i];
            if (uint(fi.accounts[owner].balance) > 0) {
                futureArray[index++] = _toFutureView(fi, i, owner);
            }
        }
    }

    function list(
        uint offset, 
        uint count, 
        uint order
    ) external view override returns (FutureView[] memory futureArray) {

        FutureInfo[] storage futures = _futures;
        futureArray = new FutureView[](count);
        uint length = futures.length;
        uint i = 0;

        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                FutureInfo storage fi = futures[--index];
                futureArray[i++] = _toFutureView(fi, index, msg.sender);
            }
        } 
        else {
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                futureArray[i++] = _toFutureView(futures[index], index, msg.sender);
                ++index;
            }
        }
    }

    function create(address tokenAddress, uint[] calldata levers, bool orientation) external override onlyGovernance {

        uint16 tokenIndex = uint16(_tokenMapping[tokenAddress] - 1);

        for (uint i = 0; i < levers.length; ++i) {
            uint lever = levers[i];

            uint key = _getKey(tokenAddress, lever, orientation);
            uint index = _futureMapping[key];
            require(index == 0, "HF:exists");

            index = _futures.length;
            FutureInfo storage fi = _futures.push();
            fi.tokenAddress = tokenAddress;
            fi.lever = uint32(lever);
            fi.orientation = orientation;
            fi.tokenIndex = tokenIndex;

            _futureMapping[key] = index;

            emit New(tokenAddress, lever, orientation, index);
        }
    }

    function getFutureCount() external view override returns (uint) {
        return _futures.length;
    }

    function getFutureInfo(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) external view override returns (FutureView memory) {
        uint index = _futureMapping[_getKey(tokenAddress, lever, orientation)];
        return _toFutureView(_futures[index], index, msg.sender);
    }

    function buy(
        address tokenAddress,
        uint lever,
        bool orientation,
        uint dcuAmount
    ) external payable override {
        return buyDirect(_futureMapping[_getKey(tokenAddress, lever, orientation)], dcuAmount);
    }

    function buyDirect(uint index, uint dcuAmount) public payable override {

        require(index != 0, "HF:not exist");
        require(dcuAmount >= 50 ether, "HF:at least 50 dcu");

        DCU(DCU_TOKEN_ADDRESS).burn(msg.sender, dcuAmount);

        FutureInfo storage fi = _futures[index];
        bool orientation = fi.orientation;
        
        TokenConfig memory tokenConfig = _tokenConfigs[uint(fi.tokenIndex)];
        uint oraclePrice = _queryPrice(dcuAmount, tokenConfig, orientation, msg.sender);

        Account memory account = fi.accounts[msg.sender];
        uint basePrice = _decodeFloat(account.basePrice);
        uint balance = uint(account.balance);
        uint newPrice = oraclePrice;
        
        if (uint(account.baseBlock) > 0) {
            newPrice = (balance + dcuAmount) * oraclePrice * basePrice / (
                basePrice * dcuAmount + (balance << 64) * oraclePrice / _expMiuT(
                    uint(orientation ? tokenConfig.miuLong : tokenConfig.miuShort), 
                    uint(account.baseBlock)
                )
            );
        }
        
        account.balance = _toUInt128(balance + dcuAmount);
        account.basePrice = _encodeFloat(newPrice);
        account.baseBlock = uint32(block.number);
        fi.accounts[msg.sender] = account;

        emit Buy(index, dcuAmount, msg.sender);
    }

    function sell(uint index, uint amount) external payable override {

        require(index != 0, "HF:not exist");
        
        FutureInfo storage fi = _futures[index];
        bool orientation = fi.orientation;

        TokenConfig memory tokenConfig = _tokenConfigs[uint(fi.tokenIndex)];
        uint oraclePrice = _queryPrice(0, tokenConfig, !orientation, msg.sender);

        Account memory account = fi.accounts[msg.sender];
        account.balance -= _toUInt128(amount);
        fi.accounts[msg.sender] = account;

        uint value = _balanceOf(
            tokenConfig,
            amount, 
            _decodeFloat(account.basePrice), 
            uint(account.baseBlock),
            oraclePrice, 
            orientation, 
            uint(fi.lever)
        );
        DCU(DCU_TOKEN_ADDRESS).mint(msg.sender, value);

        emit Sell(index, amount, msg.sender, value);
    }

    function settle(uint index, address[] calldata addresses) external payable override {

        require(index != 0, "HF:not exist");

        FutureInfo storage fi = _futures[index];
        uint lever = uint(fi.lever);

        if (lever > 1) {

            bool orientation = fi.orientation;
            TokenConfig memory tokenConfig = _tokenConfigs[uint(fi.tokenIndex)];
            uint oraclePrice = _queryPrice(0, tokenConfig, !orientation, msg.sender);

            uint reward = 0;
            for (uint i = addresses.length; i > 0;) {
                address acc = addresses[--i];

                Account memory account = fi.accounts[acc];
                uint balance = _balanceOf(
                    tokenConfig,
                    uint(account.balance), 
                    _decodeFloat(account.basePrice), 
                    uint(account.baseBlock),
                    oraclePrice, 
                    orientation, 
                    lever
                );

                uint minValue = uint(account.balance) * lever / 50;
                if (balance < (minValue < MIN_VALUE ? MIN_VALUE : minValue)) {
                    fi.accounts[acc] = Account(uint128(0), uint64(0), uint32(0));
                    reward += balance;
                    emit Settle(index, acc, msg.sender, balance);
                }
            }

            if (reward > 0) {
                DCU(DCU_TOKEN_ADDRESS).mint(msg.sender, reward);
            }
        } else {
            if (msg.value > 0) {
                payable(msg.sender).transfer(msg.value);
            }
        }
    }

    function _getKey(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) private pure returns (uint) {
        require(lever < 0x100000000, "HF:lever too large");
        return (uint(uint160(tokenAddress)) << 96) | (lever << 8) | (orientation ? 1 : 0);
    }

    function _queryPrice(
        uint dcuAmount, 
        TokenConfig memory tokenConfig, 
        bool enlarge, 
        address payback
    ) private returns (uint oraclePrice) {

        uint[] memory prices = _lastPriceList(tokenConfig, msg.value, payback);
        
        oraclePrice = prices[1];
        uint k = calcRevisedK(uint(tokenConfig.sigmaSQ), prices[3], prices[2], oraclePrice, prices[0]);

        if (enlarge) {
            oraclePrice = oraclePrice * (1 ether + k + impactCost(dcuAmount)) / 1 ether;
        } else {
            oraclePrice = oraclePrice * 1 ether / (1 ether + k + impactCost(dcuAmount));
        }
    }

    function impactCost(uint vol) public pure override returns (uint) {
        return vol / 10000000;
    }

    function calcRevisedK(uint sigmaSQ, uint p0, uint bn0, uint p, uint bn) public view override returns (uint k) {
        uint sigmaISQ = p * 1 ether / p0;
        if (sigmaISQ > 1 ether) {
            sigmaISQ -= 1 ether;
        } else {
            sigmaISQ = 1 ether - sigmaISQ;
        }

        if (sigmaISQ > 0.002 ether) {
            k = sigmaISQ;
        } else {
            k = 0.002 ether;
        }

        sigmaISQ = sigmaISQ * sigmaISQ / (bn - bn0) / BLOCK_TIME / 1 ether;

        if (sigmaISQ > sigmaSQ) {
            k += _sqrt(1 ether * BLOCK_TIME * sigmaISQ * (block.number - bn));
        } else {
            k += _sqrt(1 ether * BLOCK_TIME * sigmaSQ * (block.number - bn));
        }
    }

    function _sqrt(uint256 x) private pure returns (uint256) {
        unchecked {
            if (x == 0) return 0;
            else {
                uint256 xx = x;
                uint256 r = 1;
                if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
                if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
                if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
                if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
                if (xx >= 0x100) { xx >>= 8; r <<= 4; }
                if (xx >= 0x10) { xx >>= 4; r <<= 2; }
                if (xx >= 0x8) { r <<= 1; }
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1; // Seven iterations should be enough
                uint256 r1 = x / r;
                return (r < r1 ? r : r1);
            }
        }
    }

    function _encodeFloat(uint value) private pure returns (uint64) {

        uint exponent = 0; 
        while (value > 0x3FFFFFFFFFFFFFF) {
            value >>= 4;
            ++exponent;
        }
        return uint64((value << 6) | exponent);
    }

    function _decodeFloat(uint64 floatValue) private pure returns (uint) {
        return (uint(floatValue) >> 6) << ((uint(floatValue) & 0x3F) << 2);
    }

    function _toUInt128(uint value) private pure returns (uint128) {
        require(value < 0x100000000000000000000000000000000, "FEO:can't convert to uint128");
        return uint128(value);
    }

    function _toInt128(uint v) private pure returns (int128) {
        require(v < 0x80000000000000000000000000000000, "FEO:can't convert to int128");
        return int128(int(v));
    }

    function _toUInt(int128 v) private pure returns (uint) {
        require(v >= 0, "FEO:can't convert to uint");
        return uint(int(v));
    }
    
    function _balanceOf(
        TokenConfig memory tokenConfig,
        uint balance,
        uint basePrice,
        uint baseBlock,
        uint oraclePrice, 
        bool ORIENTATION, 
        uint LEVER
    ) private view returns (uint) {

        if (balance > 0) {
            uint left;
            uint right;
            if (ORIENTATION) {
                left = balance + (LEVER << 64) * balance * oraclePrice / basePrice
                        / _expMiuT(uint(tokenConfig.miuLong), baseBlock);
                right = balance * LEVER;
            } 
            else {
                left = balance * (1 + LEVER);
                right = (LEVER << 64) * balance * oraclePrice / basePrice 
                        / _expMiuT(uint(tokenConfig.miuShort), baseBlock);
            }

            if (left > right) {
                balance = left - right;
            } else {
                balance = 0;
            }
        }

        return balance;
    }

    function _expMiuT(uint miu, uint baseBlock) private view returns (uint) {

        return miu * (block.number - baseBlock) * BLOCK_TIME + 0x10000000000000000;
    }

    function _toFutureView(FutureInfo storage fi, uint index, address owner) private view returns (FutureView memory) {
        Account memory account = fi.accounts[owner];
        return FutureView(
            index,
            fi.tokenAddress,
            uint(fi.lever),
            fi.orientation,
            uint(account.balance),
            _decodeFloat(account.basePrice),
            uint(account.baseBlock)
        );
    }
}