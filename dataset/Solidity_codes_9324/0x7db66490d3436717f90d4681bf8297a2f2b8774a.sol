

pragma solidity >0.4.13 >=0.4.23 >=0.5.0 <0.6.0 >=0.5.12 <0.6.0 >=0.5.15 <0.6.0;





/* pragma solidity >0.4.13; */

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint x, uint n) internal pure returns (uint z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}





contract LoihiDelegators {


    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {

        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }

    function staticTo(address callee, bytes memory data) internal view returns (bytes memory) {

        (bool success, bytes memory returnData) = callee.staticcall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }


    function dViewRawAmount (address addr, uint256 amount) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSelector(0x049ca270, amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dViewNumeraireAmount (address addr, uint256 amount) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSelector(0xf5e6c0ca, amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dViewNumeraireBalance (address addr, address _this) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSelector(0xac969a73, _this)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dGetNumeraireAmount (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0xb2e87f0f, amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dGetNumeraireBalance (address addr) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0x10df6430)); // encoded selector of "getNumeraireBalance()";
        return abi.decode(result, (uint256));
    }

    function dIntakeRaw (address addr, uint256 amount) internal {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0xfa00102a, amount)); // encoded selector of "intakeRaw(uint256)";
    }

    function dIntakeNumeraire (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0x7695ab51, amount)); // encoded selector of "intakeNumeraire(uint256)";
        return abi.decode(result, (uint256));
    }

    function dOutputRaw (address addr, address dst, uint256 amount) internal {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0xf09a3fc3, dst, amount)); // encoded selector of "outputRaw(address,uint256)";
    }

    function dOutputNumeraire (address addr, address dst, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0xef40df22, dst, amount)); // encoded selector of "outputNumeraire(address,uint256)";
        return abi.decode(result, (uint256));
    }
}





contract LoihiRoot is DSMath {



    string  public constant name = "Shells";
    string  public constant symbol = "SHL";
    uint8   public constant decimals = 18;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowances;
    uint256 public totalSupply;

    mapping(address => Flavor) public flavors;
    address[] public reserves;
    address[] public numeraires;
    struct Flavor { address adapter; address reserve; uint256 weight; }

    address public owner;
    bool internal notEntered = true;
    bool internal frozen = false;

    uint256 alpha;
    uint256 beta;
    uint256 feeBase;
    uint256 feeDerivative;

    bytes4 constant internal ERC20ID = 0x36372b07;
    bytes4 constant internal ERC165ID = 0x01ffc9a7;

    address internal constant exchange = 0xb40B60cD9687DAe6FE7043e8C62bb8Ec692632A3;
    address internal constant views = 0xdB264f3b85F838b1E1cAC5F160E9eb1dD8644BA7;
    address internal constant liquidity = 0x1C0024bDeA446F82a2Eb3C6DC9241AAFe2Cbbc0B;
    address internal constant erc20 = 0x2d5cBAB179Be33Ade692A1C95908AD5d556E2c65;

    event ShellsMinted(address indexed minter, uint256 amount, address[] indexed coins, uint256[] amounts);
    event ShellsBurned(address indexed burner, uint256 amount, address[] indexed coins, uint256[] amounts);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Trade(address indexed trader, address indexed origin, address indexed target, uint256 originAmount, uint256 targetAmount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier nonReentrant() {

        require(notEntered, "re-entered");
        notEntered = false;
        _;
        notEntered = true;
    }

    modifier notFrozen () {

        require(!frozen, "swaps, selective deposits and selective withdraws have been frozen.");
        _;
    }

}





contract LoihiLiquidity is LoihiRoot, LoihiDelegators {


    function getBalancesTokenAmountsAndWeights (address[] memory _flvrs, uint256[] memory _amts) private returns (uint256[] memory, uint256[] memory, uint256[] memory) {

        uint256[] memory balances_ = new uint256[](reserves.length);
        uint256[] memory tokenAmounts_ = new uint256[](reserves.length);
        uint256[] memory weights_ = new uint[](reserves.length);

        for (uint i = 0; i < _flvrs.length; i++) {

            Flavor memory _f = flavors[_flvrs[i]]; // withdrawing adapter + weight
            require(_f.adapter != address(0), "flavor not supported");

            for (uint j = 0; j < reserves.length; j++) {
                if (balances_[j] == 0) balances_[j] = dGetNumeraireBalance(reserves[j]);
                if (reserves[j] == _f.reserve && _amts[i] > 0) {
                    tokenAmounts_[j] += dGetNumeraireAmount(_f.adapter, _amts[i]);
                    weights_[j] = _f.weight;
                }
            }

        }

        return (balances_, tokenAmounts_, weights_);

    }

    function selectiveDeposit (address[] calldata _flvrs, uint256[] calldata _amts, uint256 _minShells, uint256 _deadline) external returns (uint256 shellsToMint_) {
        require(_deadline >= now, "deadline has passed for this transaction");

        ( uint256[] memory _balances,
          uint256[] memory _deposits,
          uint256[] memory _weights ) = getBalancesTokenAmountsAndWeights(_flvrs, _amts);

        shellsToMint_ = calculateShellsToMint(_balances, _deposits, _weights);

        require(shellsToMint_ >= _minShells, "minted shells less than minimum shells");

        _mint(msg.sender, shellsToMint_);

        for (uint i = 0; i < _flvrs.length; i++) if (_amts[i] > 0) dIntakeRaw(flavors[_flvrs[i]].adapter, _amts[i]);

        emit ShellsMinted(msg.sender, shellsToMint_, _flvrs, _amts);

        return shellsToMint_;

    }

    function calculateShellsToMint (uint256[] memory _balances, uint256[] memory _deposits, uint256[] memory _weights) private returns (uint256) {

        uint256 _newSum;
        uint256 _oldSum;
        for (uint i = 0; i < _balances.length; i++) {
            _oldSum = add(_oldSum, _balances[i]);
            _newSum = add(_newSum, add(_balances[i], _deposits[i]));
        }

        uint256 shellsToMint_;

        for (uint i = 0; i < _balances.length; i++) {
            if (_deposits[i] == 0) continue;
            uint256 _depositAmount = _deposits[i];
            uint256 _weight = _weights[i];
            uint256 _oldBalance = _balances[i];
            uint256 _newBalance = add(_oldBalance, _depositAmount);

            require(_newBalance <= wmul(_weight, wmul(_newSum, alpha + WAD)), "halt check deposit");

            uint256 _feeThreshold = wmul(_weight, wmul(_newSum, beta + WAD));
            if (_newBalance <= _feeThreshold) {

                shellsToMint_ += _depositAmount;

            } else if (_oldBalance >= _feeThreshold) {

                uint256 _feePrep = wmul(feeDerivative, wdiv(
                    sub(_newBalance, _feeThreshold),
                    wmul(_weight, _newSum)
                ));

                shellsToMint_ = add(shellsToMint_, wmul(_depositAmount, WAD - _feePrep));

            } else {

                uint256 _feePrep = wmul(feeDerivative, wdiv(
                    sub(_newBalance, _feeThreshold),
                    wmul(_weight, _newSum)
                ));

                shellsToMint_ += add(
                    sub(_feeThreshold, _oldBalance),
                    wmul(sub(_newBalance, _feeThreshold), WAD - _feePrep)
                );

            }
        }

        if (totalSupply == 0) return shellsToMint_;
        else return wmul(totalSupply, wdiv(shellsToMint_, _oldSum));

    }

    function selectiveWithdraw (address[] calldata _flvrs, uint256[] calldata _amts, uint256 _maxShells, uint256 _deadline) external returns (uint256 shellsBurned_) {
        require(_deadline >= now, "deadline has passed for this transaction");

        ( uint256[] memory _balances,
          uint256[] memory _withdrawals,
          uint256[] memory _weights ) = getBalancesTokenAmountsAndWeights(_flvrs, _amts);

        shellsBurned_ = calculateShellsToBurn(_balances, _withdrawals, _weights);

        require(shellsBurned_ <= _maxShells, "withdrawal exceeds max shells limit");
        require(shellsBurned_ <= balances[msg.sender], "withdrawal amount exceeds balance");

        for (uint i = 0; i < _flvrs.length; i++) if (_amts[i] > 0) dOutputRaw(flavors[_flvrs[i]].adapter, msg.sender, _amts[i]);

        _burn(msg.sender, shellsBurned_);

        emit ShellsBurned(msg.sender, shellsBurned_, _flvrs, _amts);

        return shellsBurned_;

    }

    function calculateShellsToBurn (uint256[] memory _balances, uint256[] memory _withdrawals, uint256[] memory _weights) internal returns (uint256) {

        uint256 _newSum;
        uint256 _oldSum;
        for (uint i = 0; i < _balances.length; i++) {
            _oldSum = add(_oldSum, _balances[i]);
            _newSum = add(_newSum, sub(_balances[i], _withdrawals[i]));
        }

        uint256 _numeraireShellsToBurn;

        for (uint i = 0; i < reserves.length; i++) {
            if (_withdrawals[i] == 0) continue;
            uint256 _withdrawal = _withdrawals[i];
            uint256 _weight = _weights[i];
            uint256 _oldBal = _balances[i];
            uint256 _newBal = sub(_oldBal, _withdrawal);

            require(_newBal >= wmul(_weight, wmul(_newSum, WAD - alpha)), "withdraw halt check");

            uint256 _feeThreshold = wmul(_weight, wmul(_newSum, WAD - beta));

            if (_newBal >= _feeThreshold) {

                _numeraireShellsToBurn += wmul(_withdrawal, WAD + feeBase);

            } else if (_oldBal <= _feeThreshold) {

                uint256 _feePrep = wdiv(sub(_feeThreshold, _newBal), wmul(_weight, _newSum));

                _feePrep = wmul(_feePrep, feeDerivative);

                _numeraireShellsToBurn += wmul(wmul(_withdrawal, WAD + _feePrep), WAD + feeBase);

            } else {

                uint256 _feePrep = wdiv(sub(_feeThreshold, _newBal), wmul(_weight, _newSum));

                _feePrep = wmul(feeDerivative, _feePrep);

                _numeraireShellsToBurn += wmul(add(
                    sub(_oldBal, _feeThreshold),
                    wmul(sub(_feeThreshold, _newBal), WAD + _feePrep)
                ), WAD + feeBase);

            }
        }

        return wmul(totalSupply, wdiv(_numeraireShellsToBurn, _oldSum));

    }

    function proportionalDeposit (uint256 _deposit) public returns (uint256) {

        uint256 _totalBalance;
        uint256 _totalSupply = totalSupply;

        uint256[] memory _amounts = new uint256[](numeraires.length);

        if (_totalSupply == 0) {

            for (uint i = 0; i < reserves.length; i++) {
                Flavor memory _f = flavors[numeraires[i]];
                _amounts[i] = dIntakeNumeraire(_f.adapter, wmul(_f.weight, _deposit));
            }

            emit ShellsMinted(msg.sender, _deposit, numeraires, _amounts);

            _mint(msg.sender, _deposit);

            return _deposit;

        } else {

            for (uint i = 0; i < reserves.length; i++) {
                Flavor memory _f = flavors[numeraires[i]];
                _amounts[i] = wmul(_f.weight, _deposit);
                _totalBalance += dGetNumeraireBalance(reserves[i]);
            }

            uint256 shellsToMint_ = wmul(_totalSupply, wdiv(_deposit, _totalBalance));

            _mint(msg.sender, shellsToMint_);

            for (uint i = 0; i < reserves.length; i++) {
                Flavor memory d = flavors[numeraires[i]];
                _amounts[i] = dIntakeNumeraire(d.adapter, _amounts[i]);
            }

            emit ShellsMinted(msg.sender, shellsToMint_, numeraires, _amounts);

            return shellsToMint_;
        }

    }

    function proportionalWithdraw (uint256 _withdrawal) public returns (uint256[] memory) {

        require(_withdrawal <= balances[msg.sender], "withdrawal amount exceeds your balance");

        uint256 _withdrawMultiplier = wdiv(_withdrawal, totalSupply);

        _burn(msg.sender, _withdrawal);

        uint256[] memory withdrawalAmts_ = new uint256[](reserves.length);
        for (uint i = 0; i < reserves.length; i++) {
            uint256 amount = dGetNumeraireBalance(reserves[i]);
            uint256 proportionateValue = wmul(wmul(amount, _withdrawMultiplier), WAD - feeBase);
            Flavor memory _f = flavors[numeraires[i]];
            withdrawalAmts_[i] = dOutputNumeraire(_f.adapter, msg.sender, proportionateValue);
        }

        emit ShellsBurned(msg.sender, _withdrawal, numeraires, withdrawalAmts_);

        return withdrawalAmts_;

    }


    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");
        balances[account] = sub(balances[account], amount);
        totalSupply = sub(totalSupply, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply = add(totalSupply, amount);
        balances[account] = add(balances[account], amount);
    }

}