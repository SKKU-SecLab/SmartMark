

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

    address internal constant exchange = 0x179117cfD46D8D7e2EA873A63A113B0e0136C45D;
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





contract LoihiExchange is LoihiRoot, LoihiDelegators {


    function executeOriginTrade (address _origin, address _target, uint256 _oAmt, uint256 _minTAmt, uint256 _deadline, address _recipient) external returns (uint256) {

        Flavor memory _o = flavors[_origin]; // origin adapter + weight
        Flavor memory _t = flavors[_target]; // target adapter + weight

        require(_o.adapter != address(0), "origin flavor not supported");
        require(_t.adapter != address(0), "target flavor not supported");

        ( uint256 _NAmt,
          uint256 _oBal,
          uint256 _tBal,
          uint256 _grossLiq ) = getOriginTradeVariables(_o, _t, _oAmt);

        _NAmt = calculateOriginTradeOriginAmount(_o.weight, _oBal, _NAmt, _grossLiq);
        _NAmt = calculateOriginTradeTargetAmount(_t.weight, _tBal, _NAmt, _grossLiq);

        require(dViewRawAmount(_t.adapter, _NAmt) >= _minTAmt, "target amount is less than minimum target amount");

        dIntakeRaw(_o.adapter, _oAmt);
        uint256 tAmt_ = dOutputNumeraire(_t.adapter, _recipient, _NAmt);

        emit Trade(msg.sender, _origin, _target, _oAmt, tAmt_);

        return tAmt_;

    }

    function getOriginTradeVariables (Flavor memory _o, Flavor memory _t, uint256 _oAmt) private returns (uint, uint, uint, uint) {

        uint oNAmt_ = dGetNumeraireAmount(_o.adapter, _oAmt);
        uint oBal_ = dGetNumeraireBalance(_o.adapter);
        uint tBal_ = dGetNumeraireBalance(_t.adapter);
        uint grossLiq_ = add(oBal_, tBal_);
        oBal_ = add(oBal_, oNAmt_);

        for (uint i = 0; i < reserves.length; i++) {
            if (reserves[i] != _o.reserve && reserves[i] != _t.reserve){
                grossLiq_ += dGetNumeraireBalance(reserves[i]);
            }
        }

        return (oNAmt_, oBal_, tBal_, grossLiq_);

    }

    function calculateOriginTradeOriginAmount (uint256 _oWeight, uint256 _oBal, uint256 _oNAmt, uint256 _grossLiq) private view returns (uint256) {

        require(_oBal <= wmul(_oWeight, wmul(_grossLiq, alpha + WAD)), "origin swap origin halt check");

        uint256 oNAmt_;

        uint256 _feeThreshold = wmul(_oWeight, wmul(_grossLiq, beta + WAD));
        if (_oBal <= _feeThreshold) {

            oNAmt_ = _oNAmt;

        } else if (sub(_oBal, _oNAmt) >= _feeThreshold) {

            uint256 _fee = wdiv(
                sub(_oBal, _feeThreshold),
                wmul(_oWeight, _grossLiq)
            );
            _fee = wmul(_fee, feeDerivative);
            oNAmt_ = wmul(_oNAmt, WAD - _fee);

        } else {

            uint256 _fee = wmul(feeDerivative, wdiv(
                sub(_oBal, _feeThreshold),
                wmul(_oWeight, _grossLiq)
            ));

            oNAmt_ = add(
                sub(_feeThreshold, sub(_oBal, _oNAmt)),
                wmul(sub(_oBal, _feeThreshold), WAD - _fee)
            );

        }

        return oNAmt_;

    }

    function calculateOriginTradeTargetAmount (uint256 _tWeight, uint256 _tBal, uint256 _tNAmt, uint256 _grossLiq) private view returns (uint256 tNAmt_) {


        uint256 _feeThreshold = wmul(_tWeight, wmul(_grossLiq, WAD - beta));
        if (sub(_tBal, _tNAmt) >= _feeThreshold) {

            tNAmt_ = wmul(_tNAmt, WAD - feeBase);

        } else if (_tBal <= _feeThreshold) {

            uint256 _fee = wdiv(
                sub(_feeThreshold, sub(_tBal, _tNAmt)),
                wmul(_tWeight, _grossLiq)
            );

            _fee = wmul(_fee, feeDerivative);
            _tNAmt = wmul(_tNAmt, WAD - _fee);
            tNAmt_ = wmul(_tNAmt, WAD - feeBase);

        } else {

            uint256 _fee = wmul(feeDerivative, wdiv(
                sub(_feeThreshold, sub(_tBal, _tNAmt)),
                wmul(_tWeight, _grossLiq)
            ));
            tNAmt_ = wmul(add(
                sub(_tBal, _feeThreshold),
                wmul(sub(_feeThreshold, sub(_tBal, _tNAmt)), WAD - _fee)
            ), WAD - feeBase);

        }

        require(sub(_tBal, tNAmt_) >= wmul(_tWeight, wmul(_grossLiq, WAD - alpha)), "origin swap target halt check");

        return tNAmt_;

    }

    function executeTargetTrade (address _origin, address _target, uint256 _maxOAmt, uint256 _tAmt, uint256 _deadline, address _recipient) external returns (uint256) {
        require(_deadline >= now, "deadline has passed for this trade");

        Flavor memory _o = flavors[_origin];
        Flavor memory _t = flavors[_target];

        require(_o.adapter != address(0), "origin flavor not supported");
        require(_t.adapter != address(0), "target flavor not supported");

        ( uint256 _NAmt,
          uint256 _oBal,
          uint256 _tBal,
          uint256 _grossLiq ) = getTargetTradeVariables(_o, _t, _tAmt) ;

        _NAmt = calculateTargetTradeTargetAmount(_t.weight, _tBal, _NAmt, _grossLiq);
        _NAmt = calculateTargetTradeOriginAmount(_o.weight, _oBal, _NAmt, _grossLiq);
        
        require(dViewRawAmount(_o.adapter, _NAmt) <= _maxOAmt, "origin amount is greater than max origin amount");

        dOutputRaw(_t.adapter, _recipient, _tAmt);
        uint256 oAmt_ = dIntakeNumeraire(_o.adapter, _NAmt);

        emit Trade(msg.sender, _origin, _target, oAmt_, _tAmt);

        return oAmt_;

    }

    function getTargetTradeVariables (Flavor memory _o, Flavor memory _t, uint256 _tAmt) private returns (uint, uint, uint, uint) {

        uint tNAmt_ = dGetNumeraireAmount(_t.adapter, _tAmt);
        uint tBal_ = dGetNumeraireBalance(_t.adapter);
        uint oBal_ = dGetNumeraireBalance(_o.adapter);
        uint grossLiq_ = add(tBal_, oBal_);
        tBal_ = sub(tBal_, tNAmt_);

        for (uint i = 0; i < reserves.length; i++) {
            if (reserves[i] != _o.reserve && reserves[i] != _t.reserve) {
                grossLiq_ += dGetNumeraireBalance(reserves[i]);
            }
        }

        return (tNAmt_, oBal_, tBal_, grossLiq_);

    }

    function calculateTargetTradeTargetAmount(uint256 _tWeight, uint256 _tBal, uint256 _tNAmt, uint256 _grossLiq) private view returns (uint256 tNAmt_) {


        require(_tBal >= wmul(_tWeight, wmul(_grossLiq, WAD - alpha)), "target halt check for target trade");

        uint256 _feeThreshold = wmul(_tWeight, wmul(_grossLiq, WAD - beta));

        if (_tBal >= _feeThreshold) {

            tNAmt_ = wmul(_tNAmt, WAD + feeBase);

        } else if (add(_tBal, _tNAmt) <= _feeThreshold) {

            uint256 _fee = wdiv(sub(_feeThreshold, _tBal), wmul(_tWeight, _grossLiq));
            _fee = wmul(_fee, feeDerivative);
            _tNAmt = wmul(_tNAmt, WAD + _fee);
            tNAmt_ = wmul(_tNAmt, WAD + feeBase);

        } else {

            uint256 _fee = wmul(feeDerivative, wdiv(
                    sub(_feeThreshold, _tBal),
                    wmul(_tWeight, _grossLiq)
            ));

            _tNAmt = add(
                sub(add(_tBal, _tNAmt), _feeThreshold),
                wmul(sub(_feeThreshold, _tBal), WAD + _fee)
            );

            tNAmt_ = wmul(_tNAmt, WAD + feeBase);

        }

        return tNAmt_;

    }

    function calculateTargetTradeOriginAmount (uint256 _oWeight, uint256 _oBal, uint256 _oNAmt, uint256 _grossLiq) private view returns (uint256 oNAmt_) {


        uint256 _feeThreshold = wmul(_oWeight, wmul(_grossLiq, WAD + beta));
        if (_oBal + _oNAmt <= _feeThreshold) {

            oNAmt_ = _oNAmt;

        } else if (_oBal >= _feeThreshold) {

            uint256 _fee = wdiv(
                sub(add(_oNAmt, _oBal), _feeThreshold),
                wmul(_oWeight, _grossLiq)
            );
            _fee = wmul(_fee, feeDerivative);
            oNAmt_ = wmul(_oNAmt, WAD + _fee);

        } else {

            uint256 _fee = wmul(feeDerivative, wdiv(
                sub(add(_oBal, _oNAmt), _feeThreshold),
                wmul(_oWeight, _grossLiq)
            ));

            oNAmt_ = add(
                sub(_feeThreshold, _oBal),
                wmul(sub(add(_oBal, _oNAmt), _feeThreshold), WAD + _fee)
            );

        }

        require(add(_oBal, oNAmt_) <= wmul(_oWeight, wmul(_grossLiq, WAD + alpha)), "origin halt check for target trade");

        return oNAmt_;

    }

}