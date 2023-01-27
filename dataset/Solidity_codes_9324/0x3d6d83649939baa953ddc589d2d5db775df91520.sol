pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity 0.5.17;


interface CERC20 {

    function mint(uint256 mintAmount) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function borrow(uint256 borrowAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function exchangeRateCurrent() external returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint256);


    function underlying() external view returns (address);


    function exchangeRateStored() external view returns (uint256);

}pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;



contract PooledCDAI is ERC20, Ownable {

    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    uint256 internal constant PRECISION = 10**18;
    uint256 internal constant ERR_CODE_OK = 0;

    CERC20 public constant cDAI = CERC20(
        0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643
    );
    ERC20 public constant dai = ERC20(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );

    string private _name;
    string private _symbol;

    struct Beneficiary {
        address dest;
        uint256 weight;
    }
    Beneficiary[] public beneficiaries; // the accounts that will receive the interests from Compound
    uint256 public totalBeneficiaryWeight; // sum of all beneficiary weights
    bool public initialized;

    event Mint(address indexed sender, address indexed to, uint256 amount);
    event Burn(address indexed sender, address indexed to, uint256 amount);
    event WithdrawInterest(address indexed sender, uint256 amount);
    event SetBeneficiaries(address indexed sender);

    function init(
        string calldata name,
        string calldata symbol,
        Beneficiary[] calldata _beneficiaries
    ) external {

        require(!initialized, "Already initialized");
        initialized = true;

        _name = name;
        _symbol = symbol;

        _transferOwnership(msg.sender);

        uint256 totalWeight = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i = i.add(1)) {
            totalWeight = totalWeight.add(_beneficiaries[i].weight);
            beneficiaries.push(
                Beneficiary({
                    dest: _beneficiaries[i].dest,
                    weight: _beneficiaries[i].weight
                })
            );
        }
        totalBeneficiaryWeight = totalWeight;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return 18;
    }

    function mint(address to, uint256 amount) external returns (bool) {

        dai.safeTransferFrom(msg.sender, address(this), amount);

        dai.safeApprove(address(cDAI), amount);
        require(cDAI.mint(amount) == ERR_CODE_OK, "Failed to mint cDAI");

        _mint(to, amount);

        emit Mint(msg.sender, to, amount);

        return true;
    }

    function burn(address to, uint256 amount) external returns (bool) {

        _burn(msg.sender, amount);

        require(cDAI.redeemUnderlying(amount) == ERR_CODE_OK, "Failed to redeem");

        dai.safeTransfer(to, amount);

        emit Burn(msg.sender, to, amount);

        return true;
    }

    function accruedInterestCurrent() public returns (uint256) {

        return
            cDAI
                .exchangeRateCurrent()
                .mul(cDAI.balanceOf(address(this)))
                .div(PRECISION)
                .sub(totalSupply());
    }

    function accruedInterestStored() public view returns (uint256) {

        return
            cDAI
                .exchangeRateStored()
                .mul(cDAI.balanceOf(address(this)))
                .div(PRECISION)
                .sub(totalSupply());
    }

    function withdrawInterestInDAI() external returns (bool) {

        uint256 interestAmount = accruedInterestCurrent();

        require(cDAI.redeemUnderlying(interestAmount) == ERR_CODE_OK, "Failed to redeem");

        uint256 transferAmount = 0;
        for (uint256 i = 0; i < beneficiaries.length; i = i.add(1)) {
            transferAmount = interestAmount.mul(beneficiaries[i].weight).div(
                totalBeneficiaryWeight
            );
            dai.safeTransfer(beneficiaries[i].dest, transferAmount);
        }

        emit WithdrawInterest(msg.sender, interestAmount);

        return true;
    }

    function setBeneficiaries(Beneficiary[] calldata newBeneficiaries)
        external
        onlyOwner
        returns (bool)
    {

        emit SetBeneficiaries(msg.sender);

        delete beneficiaries;
        uint256 newTotalWeight = 0;
        for (uint256 i = 0; i < newBeneficiaries.length; i = i.add(1)) {
            newTotalWeight = newTotalWeight.add(newBeneficiaries[i].weight);
            beneficiaries.push(
                Beneficiary({
                    dest: newBeneficiaries[i].dest,
                    weight: newBeneficiaries[i].weight
                })
            );
        }
        totalBeneficiaryWeight = newTotalWeight;

        return true;
    }
}pragma solidity 0.5.17;



interface KyberNetworkProxy {

    function getExpectedRate(ERC20 src, ERC20 dest, uint256 srcQty)
        external
        view
        returns (uint256 expectedRate, uint256 slippageRate);


    function tradeWithHint(
        ERC20 src,
        uint256 srcAmount,
        ERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId,
        bytes calldata hint
    ) external payable returns (uint256);

}pragma solidity 0.5.17;



contract PooledCDAIKyberExtension {

    using SafeERC20 for ERC20;
    using SafeERC20 for PooledCDAI;
    using SafeMath for uint256;

    address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    address public constant KYBER_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    ERC20 internal constant ETH_TOKEN_ADDRESS = ERC20(
        0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
    );
    bytes internal constant PERM_HINT = "PERM"; // Only use permissioned reserves from Kyber
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens

    function mintWithETH(PooledCDAI pcDAI, address to)
        public
        payable
        returns (bool)
    {

        ERC20 dai = ERC20(DAI_ADDRESS);
        (uint256 actualDAIAmount, uint256 actualETHAmount) = _kyberTrade(
            ETH_TOKEN_ADDRESS,
            msg.value,
            dai
        );

        _mint(pcDAI, to, actualDAIAmount);

        if (actualETHAmount < msg.value) {
            msg.sender.transfer(msg.value.sub(actualETHAmount));
        }

        return true;
    }

    function mintWithToken(
        PooledCDAI pcDAI,
        address tokenAddress,
        address to,
        uint256 amount
    ) public returns (bool) {

        require(
            tokenAddress != address(ETH_TOKEN_ADDRESS),
            "Use mintWithETH() instead"
        );
        require(tokenAddress != DAI_ADDRESS, "Use mint() instead");

        ERC20 token = ERC20(tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), amount);

        ERC20 dai = ERC20(DAI_ADDRESS);
        (uint256 actualDAIAmount, uint256 actualTokenAmount) = _kyberTrade(
            token,
            amount,
            dai
        );

        _mint(pcDAI, to, actualDAIAmount);

        if (actualTokenAmount < amount) {
            token.safeTransfer(msg.sender, amount.sub(actualTokenAmount));
        }

        return true;
    }

    function burnToETH(PooledCDAI pcDAI, address payable to, uint256 amount)
        public
        returns (bool)
    {

        _burn(pcDAI, amount);

        ERC20 dai = ERC20(DAI_ADDRESS);
        (uint256 actualETHAmount, uint256 actualDAIAmount) = _kyberTrade(
            dai,
            amount,
            ETH_TOKEN_ADDRESS
        );

        to.transfer(actualETHAmount);

        if (actualDAIAmount < amount) {
            dai.safeTransfer(msg.sender, amount.sub(actualDAIAmount));
        }

        return true;
    }

    function burnToToken(
        PooledCDAI pcDAI,
        address tokenAddress,
        address to,
        uint256 amount
    ) public returns (bool) {

        require(
            tokenAddress != address(ETH_TOKEN_ADDRESS),
            "Use burnToETH() instead"
        );
        require(tokenAddress != DAI_ADDRESS, "Use burn() instead");

        _burn(pcDAI, amount);

        ERC20 dai = ERC20(DAI_ADDRESS);
        ERC20 token = ERC20(tokenAddress);
        (uint256 actualTokenAmount, uint256 actualDAIAmount) = _kyberTrade(
            dai,
            amount,
            token
        );

        token.safeTransfer(to, actualTokenAmount);

        if (actualDAIAmount < amount) {
            dai.safeTransfer(msg.sender, amount.sub(actualDAIAmount));
        }

        return true;
    }

    function _mint(PooledCDAI pcDAI, address to, uint256 actualDAIAmount)
        internal
    {

        ERC20 dai = ERC20(DAI_ADDRESS);
        dai.safeApprove(address(pcDAI), 0);
        dai.safeApprove(address(pcDAI), actualDAIAmount);
        require(pcDAI.mint(to, actualDAIAmount), "Failed to mint pcDAI");
    }

    function _burn(PooledCDAI pcDAI, uint256 amount) internal {

        pcDAI.safeTransferFrom(msg.sender, address(this), amount);

        require(pcDAI.burn(address(this), amount), "Failed to burn pcDAI");
    }

    function _getBalance(ERC20 _token, address _addr)
        internal
        view
        returns (uint256)
    {

        if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
            return uint256(_addr.balance);
        }
        return uint256(_token.balanceOf(_addr));
    }

    function _toPayableAddr(address _addr)
        internal
        pure
        returns (address payable)
    {

        return address(uint160(_addr));
    }

    function _kyberTrade(ERC20 _srcToken, uint256 _srcAmount, ERC20 _destToken)
        internal
        returns (uint256 _actualDestAmount, uint256 _actualSrcAmount)
    {

        KyberNetworkProxy kyber = KyberNetworkProxy(KYBER_ADDRESS);
        (, uint256 rate) = kyber.getExpectedRate(
            _srcToken,
            _destToken,
            _srcAmount
        );
        require(rate > 0, "Price for token is 0 on Kyber");

        uint256 beforeSrcBalance = _getBalance(_srcToken, address(this));
        uint256 msgValue;
        if (_srcToken != ETH_TOKEN_ADDRESS) {
            msgValue = 0;
            _srcToken.safeApprove(KYBER_ADDRESS, 0);
            _srcToken.safeApprove(KYBER_ADDRESS, _srcAmount);
        } else {
            msgValue = _srcAmount;
        }
        _actualDestAmount = kyber.tradeWithHint.value(msgValue)(
            _srcToken,
            _srcAmount,
            _destToken,
            _toPayableAddr(address(this)),
            MAX_QTY,
            rate,
            address(0),
            PERM_HINT
        );
        require(_actualDestAmount > 0, "Received 0 dest token");
        if (_srcToken != ETH_TOKEN_ADDRESS) {
            _srcToken.safeApprove(KYBER_ADDRESS, 0);
        }

        _actualSrcAmount = beforeSrcBalance.sub(
            _getBalance(_srcToken, address(this))
        );
    }

    function() external payable {}
}pragma solidity 0.5.17;



contract CloneFactory {

    function createClone(address target) internal returns (address result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }

    function isClone(address target, address query)
        internal
        view
        returns (bool result)
    {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
            )
            mstore(add(clone, 0xa), targetBytes)
            mstore(
                add(clone, 0x1e),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}pragma solidity 0.5.17;



contract PooledCDAIFactory is CloneFactory {

    address public libraryAddress;

    event CreatePool(
        address sender,
        address pool,
        bool indexed renounceOwnership
    );

    constructor(address _libraryAddress) public {
        libraryAddress = _libraryAddress;
    }

    function createPCDAI(
        string calldata name,
        string calldata symbol,
        PooledCDAI.Beneficiary[] calldata beneficiaries,
        bool renounceOwnership
    ) external returns (PooledCDAI) {

        PooledCDAI pcDAI = _createPCDAI(
            name,
            symbol,
            beneficiaries,
            renounceOwnership
        );
        emit CreatePool(msg.sender, address(pcDAI), renounceOwnership);
        return pcDAI;
    }

    function _createPCDAI(
        string memory name,
        string memory symbol,
        PooledCDAI.Beneficiary[] memory beneficiaries,
        bool renounceOwnership
    ) internal returns (PooledCDAI) {

        address payable clone = _toPayableAddr(createClone(libraryAddress));
        PooledCDAI pcDAI = PooledCDAI(clone);
        pcDAI.init(name, symbol, beneficiaries);
        if (renounceOwnership) {
            pcDAI.renounceOwnership();
        } else {
            pcDAI.transferOwnership(msg.sender);
        }
        return pcDAI;
    }

    function _toPayableAddr(address _addr)
        internal
        pure
        returns (address payable)
    {

        return address(uint160(_addr));
    }
}pragma solidity 0.5.17;



contract MetadataPooledCDAIFactory is PooledCDAIFactory {

    event CreatePoolWithMetadata(
        address sender,
        address pool,
        bool indexed renounceOwnership,
        bytes metadata
    );

    constructor(address _libraryAddress)
        public
        PooledCDAIFactory(_libraryAddress)
    {}

    function createPCDAIWithMetadata(
        string calldata name,
        string calldata symbol,
        PooledCDAI.Beneficiary[] calldata beneficiaries,
        bool renounceOwnership,
        bytes calldata metadata
    ) external returns (PooledCDAI) {

        PooledCDAI pcDAI = _createPCDAI(
            name,
            symbol,
            beneficiaries,
            renounceOwnership
        );
        emit CreatePoolWithMetadata(
            msg.sender,
            address(pcDAI),
            renounceOwnership,
            metadata
        );
    }
}pragma solidity 0.5.17;



contract PooledCSAI is ERC20, Ownable {

    uint256 internal constant PRECISION = 10**18;

    address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;
    address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;

    string private _name;
    string private _symbol;

    address public beneficiary; // the account that will receive the interests from Compound

    event Mint(address indexed sender, address indexed to, uint256 amount);
    event Burn(address indexed sender, address indexed to, uint256 amount);
    event WithdrawInterest(
        address indexed sender,
        address beneficiary,
        uint256 amount,
        bool indexed inDAI
    );
    event SetBeneficiary(address oldBeneficiary, address newBeneficiary);

    function init(
        string memory name,
        string memory symbol,
        address _beneficiary
    ) public {

        require(beneficiary == address(0), "Already initialized");

        _name = name;
        _symbol = symbol;

        require(_beneficiary != address(0), "Beneficiary can't be zero");
        beneficiary = _beneficiary;
        emit SetBeneficiary(address(0), _beneficiary);

        _transferOwnership(msg.sender);
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return 18;
    }

    function mint(address to, uint256 amount) public returns (bool) {

        ERC20 dai = ERC20(DAI_ADDRESS);
        require(
            dai.transferFrom(msg.sender, address(this), amount),
            "Failed to transfer DAI from msg.sender"
        );

        CERC20 cDAI = CERC20(CDAI_ADDRESS);
        require(dai.approve(CDAI_ADDRESS, 0), "Failed to clear DAI allowance");
        require(
            dai.approve(CDAI_ADDRESS, amount),
            "Failed to set DAI allowance"
        );
        require(cDAI.mint(amount) == 0, "Failed to mint cDAI");

        _mint(to, amount);

        emit Mint(msg.sender, to, amount);

        return true;
    }

    function burn(address to, uint256 amount) public returns (bool) {

        _burn(msg.sender, amount);

        CERC20 cDAI = CERC20(CDAI_ADDRESS);
        require(cDAI.redeemUnderlying(amount) == 0, "Failed to redeem");

        ERC20 dai = ERC20(DAI_ADDRESS);
        require(dai.transfer(to, amount), "Failed to transfer DAI to target");

        emit Burn(msg.sender, to, amount);

        return true;
    }

    function accruedInterestCurrent() public returns (uint256) {

        CERC20 cDAI = CERC20(CDAI_ADDRESS);
        return
            cDAI
                .exchangeRateCurrent()
                .mul(cDAI.balanceOf(address(this)))
                .div(PRECISION)
                .sub(totalSupply());
    }

    function accruedInterestStored() public view returns (uint256) {

        CERC20 cDAI = CERC20(CDAI_ADDRESS);
        return
            cDAI
                .exchangeRateStored()
                .mul(cDAI.balanceOf(address(this)))
                .div(PRECISION)
                .sub(totalSupply());
    }

    function withdrawInterestInDAI() public returns (bool) {

        uint256 interestAmount = accruedInterestCurrent();

        CERC20 cDAI = CERC20(CDAI_ADDRESS);
        require(cDAI.redeemUnderlying(interestAmount) == 0, "Failed to redeem");

        ERC20 dai = ERC20(DAI_ADDRESS);
        require(
            dai.transfer(beneficiary, interestAmount),
            "Failed to transfer DAI to beneficiary"
        );

        emit WithdrawInterest(msg.sender, beneficiary, interestAmount, true);

        return true;
    }

    function withdrawInterestInCDAI() public returns (bool) {

        CERC20 cDAI = CERC20(CDAI_ADDRESS);
        uint256 interestAmountInCDAI = accruedInterestCurrent()
            .mul(PRECISION)
            .div(cDAI.exchangeRateCurrent());

        require(
            cDAI.transfer(beneficiary, interestAmountInCDAI),
            "Failed to transfer cDAI to beneficiary"
        );

        emit WithdrawInterest(
            msg.sender,
            beneficiary,
            interestAmountInCDAI,
            false
        );

        return true;
    }

    function setBeneficiary(address newBeneficiary)
        public
        onlyOwner
        returns (bool)
    {

        require(newBeneficiary != address(0), "Beneficiary can't be zero");
        emit SetBeneficiary(beneficiary, newBeneficiary);

        beneficiary = newBeneficiary;

        return true;
    }

    function() external payable {
        revert("Contract doesn't support receiving Ether");
    }
}pragma solidity 0.5.17;


interface ScdMcdMigration {

    function swapSaiToDai(uint256 wad) external;

}pragma solidity 0.5.17;


contract Sai2Dai is Ownable {

    using SafeERC20 for IERC20;
    using SafeERC20 for PooledCSAI;

    uint256 public constant DEV_WEIGHT = 5;
    uint256 public constant BENEFICIARY_WEIGHT = 95;

    mapping (address => address) pSAI2pDAI;
    address public dev;

    MetadataPooledCDAIFactory public factory;
    IERC20 public constant sai = IERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    IERC20 public constant dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ScdMcdMigration public constant mcdaiMigration = ScdMcdMigration(0xc73e0383F3Aff3215E6f04B0331D58CeCf0Ab849);

    constructor (address factoryAddress) public {
        dev = 0x332D87209f7c8296389C307eAe170c2440830A47;
        factory = MetadataPooledCDAIFactory(factoryAddress);
    }

    function migrate(address payable pSAIAddress, uint256 amount) public {

        PooledCSAI pSAI = PooledCSAI(pSAIAddress);
        pSAI.safeTransferFrom(msg.sender, address(this), amount);

        pSAI.burn(address(this), amount);

        sai.safeApprove(address(mcdaiMigration), amount);
        mcdaiMigration.swapSaiToDai(amount);

        PooledCDAI pDAI;
        if (pSAI2pDAI[pSAIAddress] == address(0)) {
            PooledCDAI.Beneficiary[] memory beneficiaries = new PooledCDAI.Beneficiary[](2);
            beneficiaries[0] = PooledCDAI.Beneficiary({
                dest: pSAI.beneficiary(),
                weight: BENEFICIARY_WEIGHT
            });
            beneficiaries[1] = PooledCDAI.Beneficiary({
                dest: dev,
                weight: DEV_WEIGHT
            });
            pDAI = factory.createPCDAI(pSAI.name(), pSAI.symbol(), beneficiaries, false);
            pDAI.transferOwnership(pSAI.owner());
            pSAI2pDAI[pSAIAddress] = address(pDAI);
        } else {
            pDAI = PooledCDAI(pSAI2pDAI[pSAIAddress]);
        }

        dai.safeApprove(address(pDAI), amount);
        pDAI.mint(msg.sender, amount);
    }

    function setDev(address newDev) external onlyOwner {

        dev = newDev;
    }
}