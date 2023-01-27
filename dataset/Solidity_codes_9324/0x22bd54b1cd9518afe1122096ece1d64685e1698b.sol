


pragma solidity 0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library ECDSA {

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }
}

abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Configurations is Ownable {

    using SafeMath for uint256;
    uint256 public minFee;
    uint256 public maxFee;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public percentageFee;

    address public feeAccount;
    address public middleware;

    string[] public pairs;
    uint256[] public minRate;
    uint256[] public maxRate;

    uint256 public rateDecimals = 18;
    string public baseCurrency = "GSU";

    mapping(string => uint256) public collectedFee;
    mapping(string => uint8) public pairIndex;

    event MiddlewareChanged(address middleware);
    event FeeAccountUpdated(address feeAccount);
    event RateUpdated(uint8 pair, uint256 minRate, uint256 maxRate);
    event AmountUpdated(uint256 minAmount, uint256 maxAmount);
    event FeeUpdated(uint256 minFee, uint256 maxFee, uint256 percentageFee);

    constructor(
        uint256 _minFee,
        uint256 _maxFee,
        uint256 _percentageFee,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256[] memory _minRate,
        uint256[] memory _maxRate,
        address _feeAccount,
        address _middleware
    ) public {
        require(_feeAccount != address(0x0), "[Conf] Fee account is ZERO");
        require(_middleware != address(0x0), "[Conf] middleware is ZERO");
        minFee = _minFee;
        maxFee = _maxFee;
        minRate = _minRate;
        maxRate = _maxRate;
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        percentageFee = _percentageFee;

        middleware = _middleware;
        feeAccount = _feeAccount;

        pairs.push("GSU/ETH");
        pairs.push("ETH/GSU");
        pairs.push("GSU/USDT");
        pairs.push("USDT/GSU");
        pairIndex["GSU/ETH"] = 0;
        pairIndex["ETH/GSU"] = 1;
        pairIndex["GSU/USDT"] = 2;
        pairIndex["USDT/GSU"] = 3;
    }

    function setMinFee(uint256 _minFee) external onlyOwner returns (bool) {

        require(_minFee <= maxFee);
        minFee = _minFee;
        emit FeeUpdated(minFee, maxFee, percentageFee);
        return true;
    }

    function setMaxFee(uint256 _maxFee) external onlyOwner returns (bool) {

        require(_maxFee >= minFee);
        maxFee = _maxFee;
        emit FeeUpdated(minFee, maxFee, percentageFee);
        return true;
    }

    function setPercentageFee(uint256 _percentageFee)
        external
        onlyOwner
        returns (bool)
    {

        percentageFee = _percentageFee;
        emit FeeUpdated(minFee, maxFee, percentageFee);
        return true;
    }

    function setfeeAccount(address _feeAccount)
        public
        onlyOwner
        returns (bool)
    {

        require(_feeAccount != address(0x0));

        feeAccount = _feeAccount;
        emit FeeAccountUpdated(feeAccount);
        return true;
    }

    function setMiddleware(address _middleware)
        public
        onlyOwner
        returns (bool)
    {

        require(
            _middleware != address(0x0),
            "[Dex] middleware is ZERO Address"
        );
        middleware = _middleware;
        emit MiddlewareChanged(middleware);
        return true;
    }

    function collectFee(string memory currency, uint256 _fee)
        internal
        returns (bool)
    {

        collectedFee[currency] = collectedFee[currency].add(_fee);
        return true;
    }

    function claimFee(string memory currency, uint256 _fee)
        internal
        returns (bool)
    {

        collectedFee[currency] = collectedFee[currency].sub(_fee);
        return true;
    }

    function setMinRate(uint8 pair, uint256 rate)
        public
        onlyOwner
        returns (bool)
    {

        require(rate != 0);
        minRate[pair] = rate;
        emit RateUpdated(pair, minRate[pair], maxRate[pair]);
        return true;
    }

    function setMaxRate(uint8 pair, uint256 rate)
        public
        onlyOwner
        returns (bool)
    {

        require(rate >= minRate[pair]);
        maxRate[pair] = rate;
        emit RateUpdated(pair, minRate[pair], maxRate[pair]);
        return true;
    }

    function setMinAmount(uint256 amount) public onlyOwner returns (bool) {

        require(amount != 0);
        minAmount = amount;
        emit AmountUpdated(minAmount, maxAmount);
        return true;
    }

    function setMaxAmount(uint256 amount) public onlyOwner returns (bool) {

        require(amount >= minAmount);
        maxAmount = amount;
        emit AmountUpdated(minAmount, maxAmount);
        return true;
    }
}

interface ILIQUIDITY {

    function balanceOf(string calldata symbol) external view returns (uint256);


    function contractAddress(string calldata symbol)
        external
        view
        returns (address);


    function transfer(
        string calldata symbol,
        address payable recipient,
        uint256 amount
    ) external returns (bool);

}

interface IERC20 {

    function decimals() external view returns (uint8);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

contract Dex is Ownable, Pausable, Configurations {

    using SafeMath for uint256;
    using ECDSA for bytes32;

    string public version = "1.0.0";
    ILIQUIDITY public liquidityContract;

    event FeeWithdrawn(string currency, address to, uint256 amount);
    event LiquidityContractUpdated(ILIQUIDITY liquidityContract);
    event Swap(
        address indexed sender,
        string buy,
        string sell,
        uint256 buyAmount,
        uint256 sellAmount,
        uint256 rate,
        uint256 fee
    );

    constructor(
        uint256 _minFee,
        uint256 _maxFee,
        uint256 _percentageFee,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256[] memory _minRate,
        uint256[] memory _maxRate,
        address _feeAccount,
        address _middleware,
        ILIQUIDITY _liquidity
    )
        public
        Configurations(
            _minFee,
            _maxFee,
            _percentageFee,
            _minAmount,
            _maxAmount,
            _minRate,
            _maxRate,
            _feeAccount,
            _middleware
        )
    {
        setLiquidity(_liquidity);
    }

    receive() external payable {
        revert();
    }

    function swap(
        string calldata buy,
        string calldata sell,
        uint256 amount,
        uint256 rate,
        uint32 expireTime,
        bytes calldata signature
    ) external payable whenNotPaused returns (bool) {

        if (
            keccak256(bytes(buy)) == keccak256(bytes(baseCurrency)) &&
            keccak256(bytes(sell)) == keccak256(bytes("ETH"))
        ) {
            require(
                _beforeSwap(buy, sell, msg.value, rate, expireTime, signature)
            );
            return swapETHForGSU(rate);
        }

        require(msg.value == 0, "[Dex] ethers are not accepted");
        require(_beforeSwap(buy, sell, amount, rate, expireTime, signature));

        if (
            keccak256(bytes(buy)) == keccak256(bytes("ETH")) &&
            keccak256(bytes(sell)) == keccak256(bytes(baseCurrency))
        ) {
            return swapGSUForETH(amount, rate);
        } else {
            return swapTokens(buy, sell, amount, rate);
        }
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    function withdrawFee(string calldata currency, uint256 _fee)
        external
        onlyOwner
        returns (bool)
    {

        require(_fee <= collectedFee[currency]);

        require(
            liquidityContract.transfer(currency, payable(feeAccount), _fee)
        );

        require(
            claimFee(currency, _fee),
            "[Dex] unable to update collected fee"
        );

        emit FeeWithdrawn(currency, feeAccount, _fee);

        return true;
    }

    function setLiquidity(ILIQUIDITY _liquidity)
        public
        onlyOwner
        returns (bool)
    {

        require(
            _liquidity != ILIQUIDITY(address(0x0)),
            "[Dex] liquidityContract is ZERO Address"
        );
        liquidityContract = _liquidity;
        emit LiquidityContractUpdated(liquidityContract);
        return true;
    }

    function _beforeSwap(
        string memory buy,
        string memory sell,
        uint256 amount,
        uint256 rate,
        uint32 expireTime,
        bytes memory signature
    ) private view returns (bool) {

        require(verifySigner(buy, sell, amount, rate, expireTime, signature));
        require(verifySwap(buy, sell, amount, rate, expireTime));
        return true;
    }

    function swapETHForGSU(uint256 rate) private returns (bool) {

        payable(address(liquidityContract)).transfer(msg.value);
        uint256 amountBase = (swapAmount("GSU", "ETH", msg.value, rate));

        (uint256 fee, uint256 netAmount) = chargeFee("ETH", rate, amountBase);

        liquidityContract.transfer("GSU", _msgSender(), netAmount);
        emit Swap(_msgSender(), "GSU", "ETH", netAmount, msg.value, rate, fee);
        return true;
    }

    function swapGSUForETH(uint256 amount, uint256 rate)
        private
        returns (bool)
    {

        require(_moveTokensToLiquidity("GSU", amount));

        (uint256 fee, uint256 netAmount) = chargeFee("GSU", rate, amount);

        uint256 amountWei = (swapAmount("ETH", "GSU", netAmount, rate));

        require(
            liquidityContract.transfer("ETH", _msgSender(), amountWei),
            "[Dex] error in token tranfer"
        );

        emit Swap(_msgSender(), "ETH", "GSU", amountWei, amount, rate, fee);
        return true;
    }

    function swapTokens(
        string memory buy,
        string memory sell,
        uint256 amount,
        uint256 rate
    ) private returns (bool) {

        uint256 fee;
        uint256 buyAmount;

        require(_moveTokensToLiquidity(sell, amount));

        if (keccak256(bytes(sell)) == keccak256(bytes(baseCurrency))) {
            (uint256 _fee, uint256 netAmount) = chargeFee(sell, rate, amount);
            buyAmount = (swapAmount(buy, sell, netAmount, rate));
            fee = _fee;
        } else {
            (fee, buyAmount) = chargeFee(
                sell,
                rate,
                (swapAmount(buy, sell, amount, rate))
            );
        }

        require(
            liquidityContract.transfer(buy, _msgSender(), buyAmount),
            "[Dex] error in token tranfer"
        );

        emit Swap(_msgSender(), buy, sell, buyAmount, amount, rate, fee);

        return true;
    }

    function _moveTokensToLiquidity(string memory currency, uint256 amount)
        private
        returns (bool)
    {

        address _contractAddress = contractAddress(currency);
        require(
            IERC20(_contractAddress).transferFrom(
                _msgSender(),
                address(liquidityContract),
                amount
            ),
            "[Dex] error in tranferFrom"
        );
        return true;
    }

    function chargeFee(
        string memory sell,
        uint256 rate,
        uint256 amount
    ) internal returns (uint256 fee, uint256 netAmount) {

        (uint256 _feeBase, uint256 _fee) = calculateFee(sell, rate, amount);
        uint256 _amount = amount.sub(_feeBase);
        collectFee(sell, _fee);
        return (_fee, _amount);
    }

    function calculateFee(
        string memory sell,
        uint256 rate,
        uint256 baseAmount
    ) public view returns (uint256, uint256) {

        uint256 divisor = uint256(100).mul((10**decimals(baseCurrency)));
        uint256 feeExponent = 10 **
            (rateDecimals.add(decimals(baseCurrency)).sub(decimals(sell)));
        uint256 _fee = (baseAmount.mul(percentageFee)).div(divisor);

        if (_fee < minFee) {
            _fee = minFee;
        } else if (_fee > maxFee) {
            _fee = maxFee;
        }
        return (
            _fee,
            keccak256(bytes(sell)) == keccak256(bytes(baseCurrency))
                ? _fee
                : (_fee.mul(rate)).div(feeExponent)
        );
    }

    function verifySwap(
        string memory buy,
        string memory sell,
        uint256 amount,
        uint256 rate,
        uint32 expireTime
    ) public view whenNotPaused returns (bool) {

        require(expireTime > block.timestamp, "[Dex] rate is expired");
        require(
            rate >= minRate[pairId(buy, sell)],
            "[Dex] rate is less than minRate"
        );
        require(
            rate <= maxRate[pairId(buy, sell)],
            "[Dex] rate is greater than maxRate"
        );

        uint256 _amount = toBaseCurrency(sell, amount, rate);
        require(_amount >= minAmount, "[Dex] amount is less than minAmount");
        require(_amount <= maxAmount, "[Dex] amount is greater than maxAmount");
        require(liquidity(buy) >= _amount, "[Dex] Not enough liquidity");

        return true;
    }

    function pairId(string memory buy, string memory sell)
        private
        view
        returns (uint8)
    {

        string memory _pair = string(abi.encodePacked(buy, "/", sell));
        return pairIndex[_pair];
    }

    function toBaseCurrency(
        string memory from,
        uint256 amount,
        uint256 rate
    ) private view returns (uint256) {

        if (keccak256(bytes(from)) == keccak256(bytes(baseCurrency))) {
            return amount;
        } else {
            return swapAmount("GSU", from, amount, rate);
        }
    }

    function swapAmount(
        string memory buy,
        string memory sell,
        uint256 amount,
        uint256 rate
    ) private view returns (uint256) {

        uint256 exponent = (rateDecimals.add(decimals(buy))).sub(
            decimals(sell)
        );
        return (amount.mul(10**exponent)).div(rate);
    }

    function verifySigner(
        string memory buy,
        string memory sell,
        uint256 amount,
        uint256 rate,
        uint32 expireTime,
        bytes memory signature
    ) public view returns (bool) {

        address signer = keccak256(
            abi.encodePacked(buy, sell, amount, rate, expireTime)
        )
            .recover(signature);

        require(middleware == signer, "[Dex] signer is not middleware");

        return true;
    }

    function decimals(string memory symbol) public view returns (uint256) {

        if (keccak256(bytes(symbol)) == keccak256(bytes("ETH"))) return 18;
        else {
            address contractAddress = liquidityContract.contractAddress(symbol);
            return IERC20(contractAddress).decimals();
        }
    }

    function contractAddress(string memory symbol)
        public
        view
        returns (address)
    {

        return liquidityContract.contractAddress(symbol);
    }

    function liquidity(string memory symbol) public view returns (uint256) {

        return liquidityContract.balanceOf(symbol);
    }

    function destroy() external onlyOwner {

        selfdestruct(payable(owner()));
    }
}