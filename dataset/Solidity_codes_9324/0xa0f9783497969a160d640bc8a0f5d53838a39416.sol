
pragma solidity ^0.5.8;




library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "Addition overflow");
        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {

        require(b <= a, "Subtraction overflow");
        uint c = a - b;
        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {

        if (a==0){
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "Multiplication overflow");
        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {

        require(b > 0,"Division by 0");
        uint c = a / b;
        return c;
    }
    function mod(uint a, uint b) internal pure returns (uint) {

        require(b != 0, "Modulo by 0");
        return a % b;
    }
}



interface ERC20Interface {

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);


    event Transfer(address indexed sender, address indexed recipient, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}



library SafeERC20 {

    using SafeMath for uint;

    function safeTransferFrom(ERC20Interface token, address from, address recipient, uint value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, recipient, value));
    }

    function callOptionalReturn(ERC20Interface token, bytes memory data) private {

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



contract ReentrancyGuard {

    uint private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}



contract IFXCrowdsale is ReentrancyGuard {

    using SafeMath for uint;
    using SafeERC20 for ERC20Interface;

    ERC20Interface private _IFX = ERC20Interface(0x2CF588136b15E47b555331d2f5258063AE6D01ed);
    address payable private _fundingWallet = 0x1bD99BA31f1056F962e017410c9514dD4d6da4c6;
    address payable private _tokenSaleWallet = 0x6924E015c192C0f1839a432B49e1e96e06571227;

    uint private _rate = 2000;
    uint private _weiRaised;
    uint private _ifxSold;
    uint private _bonus = 40;
    uint private _rateCurrent = 2800;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint ethValue, uint ifxAmount);



    function () external payable {
        buyTokens(msg.sender);
    }

    function token() public view returns (ERC20Interface) {

        return _IFX;
    }

    function fundingWallet() public view returns (address payable) {

        return _fundingWallet;
    }

    function rate() public view returns (uint) {

        return _rate;
    }

    function rateWithBonus() public view returns (uint){

        return _rateCurrent;
    }

    function bonus() public view returns (uint) {

        return _bonus;
    }

    function weiRaised() public view returns (uint) {

        return _weiRaised;
    }

    function ifxSold() public view returns (uint) {

        return _ifxSold;
    }



    function buyTokens(address beneficiary) public nonReentrant payable {


        require(beneficiary != address(0), "Beneficiary is zero address");
        require(msg.value != 0, "Value is 0");

        uint tokenAmount = msg.value.mul(_rateCurrent);

        require(_ifxSold + tokenAmount < 400000000 * 10**18, "Hard cap reached");

        _weiRaised = _weiRaised.add(msg.value);
        _ifxSold = _ifxSold.add(tokenAmount);

        _currentBonus();

        _IFX.safeTransferFrom(_tokenSaleWallet, beneficiary, tokenAmount);
        _fundingWallet.transfer(msg.value);

        emit TokensPurchased(msg.sender, beneficiary, msg.value, tokenAmount);
    }



    function _currentBonus() internal {

        if(_ifxSold < 80000000 * 10**18){
            _bonus = 40;
        } else if(_ifxSold >= 80000000 * 10**18 && _ifxSold < 160000000 * 10**18){
            _bonus = 30;
        } else if(_ifxSold >= 160000000 * 10**18 && _ifxSold < 240000000 * 10**18){
            _bonus = 20;
        } else if(_ifxSold >= 240000000 * 10**18 && _ifxSold < 320000000 * 10**18){
            _bonus = 10;
        } else if(_ifxSold >= 320000000 * 10**18){
            _bonus = 0;
        }

        _rateCurrent = _bonus * 20 + 2000;
    }
}