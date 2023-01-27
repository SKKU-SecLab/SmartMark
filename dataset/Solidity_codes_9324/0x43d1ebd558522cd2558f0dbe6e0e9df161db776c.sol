
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

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT




pragma solidity ^0.8.0;

interface IERC20 {

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}/*





 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄            ▄▄▄▄▄▄▄▄▄▄▄ 
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░█▀▀▀▀▀▀▀▀▀ 
▐░▌          ▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌          ▐░▌          
▐░▌ ▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░▌ ▄▄▄▄▄▄▄▄ ▐░▌ ▄▄▄▄▄▄▄▄ ▐░▌          ▐░█▄▄▄▄▄▄▄▄▄ 
▐░▌▐░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌▐░░░░░░░░▌▐░▌▐░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌
▐░▌ ▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌ ▀▀▀▀▀▀█░▌▐░▌ ▀▀▀▀▀▀█░▌▐░▌          ▐░█▀▀▀▀▀▀▀▀▀ 
▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌          
▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ 
▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌











*/

pragma solidity ^0.8.0;


contract GAGGLE is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    address public tokenPairAddress;
    address public teamAddress = 0x02D7E6bC55Bcf210bc7f79F4e15F7E439FF2425d;
    address public treasuryAddress = 0x1534854fE07d619ce3A2c4c5c03eb35A49A9E652;
    address public psWallet = 0x5Fcb81060feeA737902033F0411AcFd0aCE1448C;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public gaggle = 0x8Ff3c88B369AC869DA3b6f4eC510A37E2E848ce8;
    address public cso = 0x14d21E48FEC43Cd683eE607c61C13ebB4151EFAB;
    address public coc = 0xf27d0d5Bd9C750F0CC147d8f4760101970D30cc9;
    address public cko = 0xBa4bB65000F555A6E3f78196Aa73cC374D18DEc1;
    address public vex = 0x99990Ab0E073Ecf018ad5d6C4D1D0815Aa3D33A1;
    address public cmo = 0xed564EF21C2A46FcA92fB9fF29cb5b53a10C90B0;

    mapping(address => uint256) private _reserveTokenBalance;
    mapping(address => uint256) private _circulatingTokenBalance;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _totalSupply = 10000000000 * 10**9;
    uint256 private _totalReserve = (MAX - (MAX % _totalSupply));
    uint256 private _transactionFeeTotal;
    uint256 public _gag = 5;

    bool private initialSellTaxActive = false;
    bool private initialSellTaxSet = false;
    bool public waxing = false;

    uint8 private _decimals = 9;
    string private _symbol = "$GAG";
    string private _name = "Gaggle";

    struct ReserveValues {
        uint256 reserveAmount;
        uint256 reserveTransferAmountMarketing;
        uint256 reserveTransferAmount;
        uint256 reserveTransferAmountTeam;
        uint256 reserveTransferAmountBurnEm;
    }

    struct TransactionValues {
        uint256 transactionFee;
        uint256 transferAmount;
        uint256 netTransferAmount;
        uint256 marketingFee;
        uint256 teamTax;
        uint256 burnEm;
    }


    constructor() {
        uint256 blackHole = _totalSupply;
        uint256 _presale = blackHole.mul(23).div(100);
        uint256 _lp = blackHole.mul(30).div(100);
        uint256 _treasury = blackHole.mul(28).div(100);
        uint256 _gaggle = blackHole.mul(36).div(1000);
        uint256 _cmo = blackHole.mul(10).div(1000);

        uint256 rate = getRate();

      
        _reserveTokenBalance[_msgSender()] = _presale.mul(rate) + _lp.mul(rate);
        _reserveTokenBalance[treasuryAddress] = _treasury.mul(rate);
        _reserveTokenBalance[vex] = _gaggle.mul(rate);
        _reserveTokenBalance[cso] = _gaggle.mul(rate);
        _reserveTokenBalance[coc] = _gaggle.mul(rate);
        _reserveTokenBalance[cko] = _gaggle.mul(rate);
        _reserveTokenBalance[gaggle] = _gaggle.mul(rate);
        _reserveTokenBalance[cmo] = _cmo.mul(rate);

       
        emit Transfer(address(0), _msgSender(), _presale);
        emit Transfer(address(0), _msgSender(), _lp);
        emit Transfer(address(0), treasuryAddress, _treasury);
        emit Transfer(address(0), vex, _gaggle);
        emit Transfer(address(0), cso, _gaggle);
        emit Transfer(address(0), coc, _gaggle);
        emit Transfer(address(0), cko, _gaggle);
        emit Transfer(address(0), gaggle, _gaggle);
        emit Transfer(address(0), cmo, _cmo);
    }


    function deathTaxOn() public onlyOwner {

        initialSellTaxActive = true;
    }

    function deathTaxOff() public onlyOwner {

        initialSellTaxActive = false;
    }

    function setTeamAddress(address _teamAddress) public onlyOwner {

        teamAddress = _teamAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {

        treasuryAddress = _treasuryAddress;
    }

    function setpsWallet(address _psWallet) public onlyOwner {

        psWallet = _psWallet;
    }

    function setCmoAddress(address _cmoAddress) public onlyOwner {

        cmo = _cmoAddress;
    }

    function setVexAddress(address _vexAddress) public onlyOwner {

        vex = _vexAddress;
    }

    function setCsoAddress(address _csoAddress) public onlyOwner {

        cso = _csoAddress;
    }

    function setCocAddress(address _cocAddress) public onlyOwner {

        coc = _cocAddress;
    }

    function setCkoAddress(address _ckoAddress) public onlyOwner {

        cko = _ckoAddress;
    }

    function setGaggleAddress(address _gaggleAddress) public onlyOwner {

        gaggle = _gaggleAddress;
    }

    function setGag(uint256 newGag) public onlyOwner {

        _gag = newGag;
    }

    function setTokenPairAddress(address _tokenPairAddress) public onlyOwner {

        tokenPairAddress = _tokenPairAddress;
    }
    function setWaxing (bool _waxing) public onlyOwner {
        waxing = _waxing;
    }
    
    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function decimals() public view override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _circulatingTokenBalance[account];
        return tokenBalanceFromReserveAmount(_reserveTokenBalance[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
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
    ) public override returns (bool) {

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

    function getOwner() external view override returns (address) {

        return owner();
    }

    function isExcluded(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {

        return _transactionFeeTotal;
    }

    function distributeToAllHolders(uint256 transferAmount) public {

        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (, ReserveValues memory reserveValues, ) = _getValues(transferAmount);
        _reserveTokenBalance[sender] = _reserveTokenBalance[sender].sub(
            reserveValues.reserveAmount
        );
        _totalReserve = _totalReserve.sub(reserveValues.reserveAmount);
        _transactionFeeTotal = _transactionFeeTotal.add(transferAmount);
    }

    function reserveBalanceFromTokenAmount(
        uint256 transferAmount,
        bool deductTransferReserveFee
    ) public view returns (uint256) {

        (, ReserveValues memory reserveValues, ) = _getValues(transferAmount);
        require(
            transferAmount <= _totalSupply,
            "Amount must be less than supply"
        );
        if (!deductTransferReserveFee) {
            return reserveValues.reserveAmount;
        } else {
            return reserveValues.reserveTransferAmount;
        }
    }

    function tokenBalanceFromReserveAmount(uint256 reserveAmount)
        public
        view
        returns (uint256)
    {

        require(
            reserveAmount <= _totalReserve,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = getRate();
        return reserveAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner {

        require(!_isExcluded[account], "Account is already excluded");
        if (_reserveTokenBalance[account] > 0) {
            _circulatingTokenBalance[account] = tokenBalanceFromReserveAmount(
                _reserveTokenBalance[account]
            );
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner {

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _circulatingTokenBalance[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function applyExternalTransactionTax(
        ReserveValues memory reserveValues,
        TransactionValues memory transactionValues,
        address sender
    ) private {

        _reserveTokenBalance[teamAddress] = _reserveTokenBalance[teamAddress]
            .add(reserveValues.reserveTransferAmountTeam);
        _reserveTokenBalance[treasuryAddress] = _reserveTokenBalance[
            treasuryAddress
        ].add(reserveValues.reserveTransferAmountMarketing);
        _reserveTokenBalance[burnAddress] = _reserveTokenBalance[burnAddress]
            .add(reserveValues.reserveTransferAmountBurnEm);

        emit Transfer(sender, teamAddress, transactionValues.teamTax);
        emit Transfer(sender, treasuryAddress, transactionValues.teamTax);
        emit Transfer(sender, burnAddress, transactionValues.burnEm);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }


    function _transferStandard(
        address sender,
        address recipient,
        uint256 transferAmount
    ) private {

        (
            TransactionValues memory transactionValues,
            ReserveValues memory reserveValues,

        ) = _getValues(transferAmount);
        _reserveTokenBalance[sender] = _reserveTokenBalance[sender].sub(
            reserveValues.reserveAmount
        );
        _reserveTokenBalance[recipient] = _reserveTokenBalance[recipient].add(
            reserveValues.reserveTransferAmount
        );
        emit Transfer(sender, recipient, transactionValues.netTransferAmount);
        if (waxing == true) {
            applyExternalTransactionTax(
                reserveValues,
                transactionValues,
                sender
            );
        }
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 transferAmount
    ) private {

        (
            TransactionValues memory transactionValues,
            ReserveValues memory reserveValues,

        ) = _getValues(transferAmount);

        _reserveTokenBalance[sender] = _reserveTokenBalance[sender].sub(
            reserveValues.reserveAmount
        );

        if (recipient == tokenPairAddress) {
            _reserveTokenBalance[recipient] = _reserveTokenBalance[recipient]
                .add(reserveValues.reserveAmount);
            _circulatingTokenBalance[recipient] = _circulatingTokenBalance[
                recipient
            ].add(transferAmount);

            emit Transfer(sender, recipient, transferAmount);
        } else {
            _reserveTokenBalance[recipient] = _reserveTokenBalance[recipient]
                .add(reserveValues.reserveTransferAmount);
            _circulatingTokenBalance[recipient] = _circulatingTokenBalance[
                recipient
            ].add(transactionValues.netTransferAmount);
            emit Transfer(
                sender,
                recipient,
                transactionValues.netTransferAmount
            );
            if (waxing == true) {
                applyExternalTransactionTax(
                    reserveValues,
                    transactionValues,
                    sender
                );
            }
        }
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 transferAmount
    ) private {

        (
            TransactionValues memory transactionValues,
            ReserveValues memory reserveValues,

        ) = _getValues(transferAmount);
        _circulatingTokenBalance[sender] = _circulatingTokenBalance[sender].sub(
            transferAmount
        );
        _reserveTokenBalance[sender] = _reserveTokenBalance[sender].sub(
            reserveValues.reserveAmount
        );

        if (!initialSellTaxActive) {
            _reserveTokenBalance[recipient] = _reserveTokenBalance[recipient]
                .add(reserveValues.reserveTransferAmount);
            emit Transfer(
                sender,
                recipient,
                transactionValues.netTransferAmount
            );
            if (waxing == true) {
                applyExternalTransactionTax(
                    reserveValues,
                    transactionValues,
                    sender
                );
            }
        } else {

            _reserveTokenBalance[recipient] = _reserveTokenBalance[recipient]
                .add(reserveValues.reserveAmount.div(10));
            emit Transfer(sender, recipient, transferAmount.div(10));
        }
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 transferAmount
    ) private {

        (
            TransactionValues memory transactionValues,
            ReserveValues memory reserveValues,

        ) = _getValues(transferAmount);
        _circulatingTokenBalance[sender] = _circulatingTokenBalance[sender].sub(
            transferAmount
        );
        _reserveTokenBalance[sender] = _reserveTokenBalance[sender].sub(
            reserveValues.reserveAmount
        );
        _reserveTokenBalance[recipient] = _reserveTokenBalance[recipient].add(
            reserveValues.reserveTransferAmount
        );
        _circulatingTokenBalance[recipient] = _circulatingTokenBalance[
            recipient
        ].add(transactionValues.netTransferAmount);

        emit Transfer(sender, recipient, transactionValues.netTransferAmount);
        if (waxing == true) {
            applyExternalTransactionTax(
                reserveValues,
                transactionValues,
                sender
            );
        }
    }

    function _getValues(uint256 transferAmount)
        private
        view
        returns (
            TransactionValues memory,
            ReserveValues memory,
            uint256
        )
    {

        TransactionValues memory transactionValues = _getTValues(
            transferAmount
        );
        uint256 currentRate = getRate();
        ReserveValues memory reserveValues = _getRValues(
            transferAmount,
            transactionValues,
            currentRate
        );

        return (transactionValues, reserveValues, currentRate);
    }

    function _getTValues(uint256 transferAmount)
        private
        view
        returns (TransactionValues memory)
    {

        TransactionValues memory transactionValues;

        transactionValues.transactionFee = transferAmount.mul(_gag).div(100);

        transactionValues.teamTax = transferAmount.mul(_gag).div(100);

        transactionValues.netTransferAmount = transferAmount
            .sub(transactionValues.transactionFee)
            .sub(transactionValues.teamTax)
            .sub(transactionValues.burnEm);

        return transactionValues;
    }

    function _getRValues(
        uint256 transferAmount,
        TransactionValues memory transactionValues,
        uint256 currentRate
    ) private pure returns (ReserveValues memory) {

        ReserveValues memory reserveValues;
        reserveValues.reserveAmount = transferAmount.mul(currentRate);
        reserveValues.reserveTransferAmountMarketing = transactionValues
            .transactionFee
            .mul(currentRate);
        reserveValues.reserveTransferAmountTeam = transactionValues.teamTax.mul(
            currentRate
        );
        reserveValues.reserveTransferAmountBurnEm = transactionValues
            .burnEm
            .mul(currentRate);

        reserveValues.reserveTransferAmount = reserveValues
            .reserveAmount
            .sub(reserveValues.reserveTransferAmountMarketing)
            .sub(reserveValues.reserveTransferAmountTeam)
            .sub(reserveValues.reserveTransferAmountBurnEm);

        return reserveValues;
    }

    function getRate() public view returns (uint256) {

        (uint256 reserveSupply, uint256 totalTokenSupply) = getCurrentSupply();
        return reserveSupply.div(totalTokenSupply);
    }

    function getCurrentSupply() public view returns (uint256, uint256) {

        uint256 reserveSupply = _totalReserve;
        uint256 totalTokenSupply = _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reserveTokenBalance[_excluded[i]] > reserveSupply ||
                _circulatingTokenBalance[_excluded[i]] > totalTokenSupply
            ) return (_totalReserve, _totalSupply);
            reserveSupply = reserveSupply.sub(
                _reserveTokenBalance[_excluded[i]]
            );
            totalTokenSupply = totalTokenSupply.sub(
                _circulatingTokenBalance[_excluded[i]]
            );
        }
        if (reserveSupply < _totalReserve.div(_totalSupply))
            return (_totalReserve, _totalSupply);
        return (reserveSupply, totalTokenSupply);
    }
}

