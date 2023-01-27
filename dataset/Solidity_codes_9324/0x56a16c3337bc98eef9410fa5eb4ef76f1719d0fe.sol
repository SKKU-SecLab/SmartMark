pragma solidity 0.4.25;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'mul');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, 'div');
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, 'sub');
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, 'add');

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}
pragma solidity 0.4.25;


interface ISettings {

    function oracleAddress() external view returns(address);

    function minDeposit() external view returns(uint256);

    function sysFee() external view returns(uint256);

    function userFee() external view returns(uint256);

    function ratio() external view returns(uint256);

    function globalTargetCollateralization() external view returns(uint256);

    function tmvAddress() external view returns(uint256);

    function maxStability() external view returns(uint256);

    function minStability() external view returns(uint256);

    function gasPriceLimit() external view returns(uint256);

    function isFeeManager(address account) external view returns (bool);

    function tBoxManager() external view returns(address);

}
pragma solidity 0.4.25;


interface IToken {

    function burnLogic(address from, uint256 value) external;

    function approve(address spender, uint256 value) external;

    function balanceOf(address who) external view returns (uint256);

    function mint(address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) external;

}

pragma solidity 0.4.25;


interface IOracle {

    function ethUsdPrice() external view returns(uint256);

}
pragma solidity 0.4.25;


interface ITBoxManager {

    function create(uint256 withdraw) external payable returns (uint256);

    function precision() external view returns (uint256);

    function rate() external view returns (uint256);

    function transferFrom(address from, address to, uint256 tokenId) external;

    function close(uint256 id) external;

    function withdrawPercent(uint256 _collateral) external view returns(uint256);

    function boxes(uint256 id) external view returns(uint256, uint256);

    function withdrawEth(uint256 _id, uint256 _amount) external;

    function withdrawTmv(uint256 _id, uint256 _amount) external;

    function withdrawableEth(uint256 id) external view returns(uint256);

    function withdrawableTmv(uint256 collateral) external view returns(uint256);

    function maxCapAmount(uint256 _id) external view returns (uint256);

    function collateralPercent(uint256 _id) external view returns (uint256);

    function capitalize(uint256 _id, uint256 _tmv) external;

    function boxWithdrawableTmv(uint256 _id) external view returns(uint256);

    function addEth(uint256 _id) external payable;

    function capitalizeMax(uint256 _id) external payable;

    function withdrawTmvMax(uint256 _id) external payable;

    function addTmv(uint256 _id, uint256 _amount) external payable;

}
pragma solidity 0.4.25;



contract Gate {

    using SafeMath for uint256;

    address public admin;

    uint256 public feePercentTMV;

    uint256 public feePercentETH;

    uint256 public minOrder;

    address public timviWallet;

    ISettings public settings;

    Order[] public orders;

    struct Order {
        address owner;
        uint256 amount;
    }

    event OrderCreated(uint256 id, address owner, uint256 tmv);

    event OrderCancelled(uint256 id, address owner, uint256 tmv);

    event OrderFilled(uint256 id, address owner, uint256 tmvTotal, uint256 tmvExecution, uint256 ethTotal, uint256 ethExecution);

    event OrderFilledPool(uint256 id, address owner, uint256 tmv, uint256 eth);

    event Converted(address owner, uint256 tmv, uint256 eth);

    event Funded(uint256 eth);

    event AdminChanged(address admin);

    event GateTmvFeeUpdated(uint256 value);
    event GateEthFeeUpdated(uint256 value);
    event GateMinOrderUpdated(uint256 value);
    event TimviWalletChanged(address wallet);
    event GateFundsWithdrawn(uint256 value);

    modifier onlyAdmin() {

        require(admin == msg.sender, "You have no access");
        _;
    }

    modifier validTx() {

        require(tx.gasprice <= settings.gasPriceLimit(), "Gas price is greater than allowed");
        _;
    }

    constructor(ISettings _settings) public {
        admin = msg.sender;
        timviWallet = msg.sender;
        settings = ISettings(_settings);

        feePercentTMV = 500; // 0.5%
        feePercentETH = 500; // 0.5%
        minOrder = 10 ** 18; // 1 TMV by default

        emit GateTmvFeeUpdated(feePercentTMV);
        emit GateEthFeeUpdated(feePercentETH);
        emit GateMinOrderUpdated(minOrder);
        emit TimviWalletChanged(timviWallet);
        emit AdminChanged(admin);
    }

    function fundAdmin() external payable {

        emit Funded(msg.value);
    }

    function withdraw(address _beneficiary, uint256 _amount) external onlyAdmin {

        require(_beneficiary != address(0), "Zero address, be careful");
        require(address(this).balance >= _amount, "Insufficient funds");
        _beneficiary.transfer(_amount);
        emit GateFundsWithdrawn(_amount);
    }

    function setTmvFee(uint256 _value) external onlyAdmin {

        require(_value <= 10000, "Too much");
        feePercentTMV = _value;
        emit GateTmvFeeUpdated(_value);
    }

    function setEthFee(uint256 _value) external onlyAdmin {

        require(_value <= 10000, "Too much");
        feePercentETH = _value;
        emit GateEthFeeUpdated(_value);
    }

    function setMinOrder(uint256 _value) external onlyAdmin {

        require(_value <= 100 ether, "Too much");

        minOrder = _value;
        emit GateMinOrderUpdated(_value);
    }

    function setTimviWallet(address _wallet) external onlyAdmin {

        require(_wallet != address(0), "Zero address, be careful");

        timviWallet = _wallet;
        emit TimviWalletChanged(_wallet);
    }

    function changeAdmin(address _newAdmin) external onlyAdmin {

        require(_newAdmin != address(0), "Zero address, be careful");
        admin = _newAdmin;
        emit AdminChanged(msg.sender);
    }

    function convert(uint256 _amount) external validTx {

        require(_amount >= minOrder, "Too small amount");
        require(IToken(settings.tmvAddress()).allowance(msg.sender, address(this)) >= _amount, "Gate is not approved to transfer enough tokens");
        uint256 eth = tmv2eth(_amount);
        if (address(this).balance >= eth) {
            IToken(settings.tmvAddress()).transferFrom(msg.sender, timviWallet, _amount);
            msg.sender.transfer(eth);
            emit Converted(msg.sender, _amount, eth);
        } else {
            IToken(settings.tmvAddress()).transferFrom(msg.sender, address(this), _amount);
            uint256 id = orders.push(Order(msg.sender, _amount)).sub(1);
            emit OrderCreated(id, msg.sender, _amount);
        }
    }

    function cancel(uint256 _id) external {

        require(orders[_id].owner == msg.sender, "Order isn't yours");

        uint256 tmv = orders[_id].amount;
        delete orders[_id];
        IToken(settings.tmvAddress()).transfer(msg.sender, tmv);
        emit OrderCancelled(_id, msg.sender, tmv);
    }

    function multiFill(uint256[] _ids) external onlyAdmin() payable {


        if (msg.value > 0) {
            emit Funded(msg.value);
        }

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];

            require(orders[id].owner != address(0), "Order doesn't exist");

            uint256 tmv = orders[id].amount;
            uint256 eth = tmv2eth(tmv);

            require(address(this).balance >= eth, "Not enough funds");

            address owner = orders[id].owner;
            if (owner.send(eth)) {
                delete orders[id];
                IToken(settings.tmvAddress()).transfer(timviWallet, tmv);
                emit OrderFilledPool(id, owner, tmv, eth);
            }
        }
    }

    function fill(uint256 _id) external payable validTx {

        require(orders[_id].owner != address(0), "Order doesn't exist");

        uint256 tmv = orders[_id].amount;
        address owner = orders[_id].owner;

        uint256 eth = tmv.mul(precision()).div(rate());

        require(msg.value >= eth, "Not enough funds");

        emit Funded(eth);

        uint256 tmvFee = tmv.mul(feePercentTMV).div(precision());
        uint256 ethFee = eth.mul(feePercentETH).div(precision());

        uint256 tmvExecution = tmv.sub(tmvFee);
        uint256 ethExecution = eth.sub(ethFee);

        delete orders[_id];

        owner.transfer(ethExecution);
        IToken(settings.tmvAddress()).transfer(msg.sender, tmvExecution);
        IToken(settings.tmvAddress()).transfer(timviWallet, tmvFee);

        msg.sender.transfer(msg.value.sub(eth));

        emit OrderFilled(_id, owner, tmv, tmvExecution, eth, ethExecution);
    }

    function rate() public view returns(uint256) {

        return IOracle(settings.oracleAddress()).ethUsdPrice();
    }

    function precision() public view returns(uint256) {

        return ITBoxManager(settings.tBoxManager()).precision();
    }

    function tmv2eth(uint256 _amount) public view returns(uint256) {

        uint256 equivalent = _amount.mul(precision()).div(rate());
        return chargeFee(equivalent, feePercentETH);
    }

    function chargeFee(uint256 _amount, uint256 _percent) public view returns(uint256) {

        uint256 fee = _amount.mul(_percent).div(precision());
        return _amount.sub(fee);
    }
}
