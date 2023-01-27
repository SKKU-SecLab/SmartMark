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


interface IOracle {

    function ethUsdPrice() external view returns(uint256);

}
pragma solidity 0.4.25;



contract BondService {

    using SafeMath for uint256;

    address public admin;

    uint256 private systemETH;

    uint256 public issuerFee;

    uint256 public holderFee;

    uint256 public divider = 100000;

    uint256 public minEther;

    ISettings public settings;

    Bond[] public bonds;

    struct Bond {
        address issuer;
        address         holder;
        uint256         deposit;
        uint256         percent;
        uint256         tmv;
        uint256         expiration;
        uint256         yearFee;
        uint256         sysFee;
        uint256         tBoxId;
        uint256         createdAt;
    }


    event BondCreated(uint256 id, address who, uint256 deposit, uint256 percent, uint256 expiration, uint256 yearFee);

    event BondChanged(uint256 id, uint256 deposit, uint256 percent, uint256 expiration, uint256 yearFee, address who);

    event BondClosed(uint256 id, address who);

    event BondMatched(uint256 id, address who, uint256 tBox, uint256 tmv, uint256 sysFee, address counteragent);

    event BondFinished(uint256 id, address issuer, address holder);

    event BondExpired(uint256 id, address issuer, address holder);

    event BondHolderFeeUpdated(uint256 _value);
    event BondIssuerFeeUpdated(uint256 _value);
    event BondMinEtherUpdated(uint256 _value);
    event IssuerRightsTransferred(address indexed from, address indexed to, uint indexed id);
    event HolderRightsTransferred(address indexed from, address indexed to, uint indexed id);

    modifier validTx() {

        require(tx.gasprice <= settings.gasPriceLimit(), "Gas price is greater than allowed");
        _;
    }

    modifier onlyAdmin() {

        require(admin == msg.sender, "You have no access");
        _;
    }

    modifier onlyIssuer(uint256 _id) {

        require(bonds[_id].issuer == msg.sender, "You are not the issuer");
        _;
    }

    modifier onlyHolder(uint256 _id) {

        require(bonds[_id].holder == msg.sender, "You are not the holder");
        _;
    }

    modifier singleOwner(uint256 _id) {

        bool _a = bonds[_id].issuer == msg.sender && bonds[_id].holder == address(0);
        bool _b = bonds[_id].holder == msg.sender && bonds[_id].issuer == address(0);
        require(_a || _b, "You are not the single owner");
        _;
    }

    modifier issueRequest(uint256 _id) {

        require(bonds[_id].issuer != address(0) && bonds[_id].holder == address(0), "The bond isn't an emit request");
        _;
    }

    modifier buyRequest(uint256 _id) {

        require(bonds[_id].holder != address(0) && bonds[_id].issuer == address(0), "The bond isn't a buy request");
        _;
    }

    modifier matched(uint256 _id) {

        require(bonds[_id].issuer != address(0) && bonds[_id].holder != address(0), "Bond isn't matched");
        _;
    }

    constructor(ISettings _settings) public {
        admin = msg.sender;
        settings = _settings;

        issuerFee = 500; // 0.5%
        emit BondIssuerFeeUpdated(issuerFee);

        holderFee = 10000; // 10%
        emit BondHolderFeeUpdated(holderFee);

        minEther = 0.1 ether;
        emit BondMinEtherUpdated(minEther);
    }

    function leverage(uint256 _percent, uint256 _expiration, uint256 _yearFee) public payable returns (uint256) {

        require(msg.value >= minEther, "Too small funds");
        require(_percent >= ITBoxManager(settings.tBoxManager()).withdrawPercent(msg.value), "Collateralization is not enough");
        require(_expiration >= 1 days && _expiration <= 365 days, "Expiration out of range");
        require(_yearFee <= 25000, "Fee out of range");

        return createBond(msg.sender, address(0), _percent, _expiration, _yearFee);
    }

    function exchange(uint256 _expiration, uint256 _yearFee) public payable returns (uint256) {

        require(msg.value >= minEther, "Too small funds");
        require(_expiration >= 1 days && _expiration <= 365 days, "Expiration out of range");
        require(_yearFee <= 25000, "Fee out of range");

        return createBond(address(0), msg.sender, 0, _expiration, _yearFee);
    }

    function createBond(
        address _issuer,
        address _holder,
        uint256 _percent,
        uint256 _expiration,
        uint256 _yearFee
    )
    internal
    returns(uint256)
    {

        Bond memory _bond = Bond(
            _issuer,
            _holder,
            msg.value,
            _percent,
            0,
            _expiration,
            _yearFee,
            0,
            0,
            0
        );
        uint256 _id = bonds.push(_bond).sub(1);
        emit BondCreated(_id, msg.sender, msg.value, _percent, _expiration, _yearFee);
        return _id;
    }

    function close(uint256 _id) external singleOwner(_id) {

        uint256 _eth = bonds[_id].deposit;
        delete bonds[_id];
        msg.sender.transfer(_eth);
        emit BondClosed(_id, msg.sender);
    }

    function issuerChange(uint256 _id, uint256 _deposit, uint256 _percent, uint256 _expiration, uint256 _yearFee)
        external
        payable
        singleOwner(_id)
        onlyIssuer(_id)
    {

        changeDeposit(_id, _deposit);
        changePercent(_id, _percent);
        changeExpiration(_id, _expiration);
        changeYearFee(_id, _yearFee);

        emit BondChanged(_id, _deposit, _percent, _expiration, _yearFee, msg.sender);
    }

    function holderChange(uint256 _id, uint256 _deposit, uint256 _expiration, uint256 _yearFee)
        external
        payable
    {

        require(bonds[_id].holder == msg.sender && bonds[_id].issuer == address(0), "You are not the holder or bond is matched");
        changeDeposit(_id, _deposit);
        changeExpiration(_id, _expiration);
        changeYearFee(_id, _yearFee);
        emit BondChanged(_id, _deposit, 0, _expiration, _yearFee, msg.sender);
    }

    function changeDeposit(uint256 _id, uint256 _deposit) internal {

        uint256 _oldDeposit = bonds[_id].deposit;
        if (_deposit != 0 && _oldDeposit != _deposit) {
            require(_deposit >= minEther, "Too small funds");
            bonds[_id].deposit = _deposit;
            if (_oldDeposit > _deposit) {
                msg.sender.transfer(_oldDeposit.sub(_deposit));
            } else {
                require(msg.value == _deposit.sub(_oldDeposit), "Incorrect value");
            }
        }
    }

    function changePercent(uint256 _id, uint256 _percent) internal {

        uint256 _oldPercent = bonds[_id].percent;
        if (_percent != 0 && _oldPercent != _percent) {
            require(_percent >= ITBoxManager(settings.tBoxManager()).withdrawPercent(bonds[_id].deposit), "Collateralization is not enough");
            bonds[_id].percent = _percent;
        }
    }

    function changeExpiration(uint256 _id, uint256 _expiration) internal {

        uint256 _oldExpiration = bonds[_id].expiration;
        if (_oldExpiration != _expiration) {
            require(_expiration >= 1 days && _expiration <= 365 days, "Expiration out of range");
            bonds[_id].expiration = _expiration;
        }
    }

    function changeYearFee(uint256 _id, uint256 _yearFee) internal {

        uint256 _oldYearFee = bonds[_id].yearFee;
        if (_oldYearFee != _yearFee) {
            require(_yearFee <= 25000, "Fee out of range");
            bonds[_id].yearFee = _yearFee;
        }
    }

    function takeIssueRequest(uint256 _id) external payable issueRequest(_id) validTx {


        address _issuer = bonds[_id].issuer;
        uint256 _eth = bonds[_id].deposit.mul(divider).div(bonds[_id].percent);

        require(msg.value == _eth, "Incorrect ETH value");

        uint256 _sysEth = _eth.mul(issuerFee).div(divider);
        systemETH = systemETH.add(_sysEth);

        uint256 _tmv = _eth.mul(rate()).div(precision());
        uint256 _box = ITBoxManager(settings.tBoxManager()).create.value(bonds[_id].deposit)(_tmv);

        bonds[_id].holder = msg.sender;
        bonds[_id].tmv = _tmv;
        bonds[_id].expiration = bonds[_id].expiration.add(now);
        bonds[_id].sysFee = holderFee;
        bonds[_id].tBoxId = _box;
        bonds[_id].createdAt = now;

        _issuer.transfer(_eth.sub(_sysEth));
        IToken(settings.tmvAddress()).transfer(msg.sender, _tmv);
        emit BondMatched(_id, msg.sender, _box, _tmv, holderFee, _issuer);
    }

    function takeBuyRequest(uint256 _id) external payable buyRequest(_id) validTx {


        address _holder = bonds[_id].holder;

        uint256 _sysEth = bonds[_id].deposit.mul(issuerFee).div(divider);
        systemETH = systemETH.add(_sysEth);

        uint256 _tmv = bonds[_id].deposit.mul(rate()).div(precision());
        uint256 _box = ITBoxManager(settings.tBoxManager()).create.value(msg.value)(_tmv);

        bonds[_id].issuer = msg.sender;
        bonds[_id].tmv = _tmv;
        bonds[_id].expiration = bonds[_id].expiration.add(now);
        bonds[_id].sysFee = holderFee;
        bonds[_id].tBoxId = _box;
        bonds[_id].createdAt = now;

        msg.sender.transfer(bonds[_id].deposit.sub(_sysEth));
        IToken(settings.tmvAddress()).transfer(_holder, _tmv);
        emit BondMatched(_id, msg.sender, _box, _tmv, holderFee, _holder);
    }

    function finish(uint256 _id) external onlyIssuer(_id) validTx {


        Bond memory bond = bonds[_id];

        require(now < bond.expiration, "Bond expired");

        uint256 _secondsPast = now.sub(bond.createdAt);
        (uint256 _eth, uint256 _debt) = getBox(bond.tBoxId);

        uint256 _commission = bond.tmv
            .mul(_secondsPast)
            .mul(bond.yearFee)
            .div(365 days)
            .div(divider);
        uint256 _sysTMV = _commission.mul(bond.sysFee).div(divider);

        address _holder = bond.holder;

        if (_sysTMV.add(_debt) > 0) {
            IToken(settings.tmvAddress()).transferFrom(
                msg.sender,
                address(this),
                _sysTMV.add(_debt)
            );
        }
        if (_commission > 0) {
            IToken(settings.tmvAddress()).transferFrom(
                msg.sender,
                _holder,
                _commission.sub(_sysTMV)
            );
        }

        if (_eth > 0) {
            ITBoxManager(settings.tBoxManager()).close(bond.tBoxId);
            delete bonds[_id];
            msg.sender.transfer(_eth);
        } else {
            delete bonds[_id];
        }

        emit BondFinished(_id, msg.sender, _holder);
    }

    function expire(uint256 _id) external matched(_id) validTx {

        require(now > bonds[_id].expiration, "Bond hasn't expired");

        (uint256 _eth, uint256 _tmv) = getBox(bonds[_id].tBoxId);

        if (_eth == 0) {
            emit BondExpired(_id, bonds[_id].issuer, bonds[_id].holder);
            delete bonds[_id];
            return;
        }

        uint256 _collateralPercent = ITBoxManager(settings.tBoxManager()).collateralPercent(bonds[_id].tBoxId);
        uint256 _targetCollateralPercent = settings.globalTargetCollateralization();
        if (_collateralPercent > _targetCollateralPercent) {
            uint256 _ethTarget = _tmv.mul(_targetCollateralPercent).div(rate()); // mul and div by precision are omitted
            uint256 _issuerEth = _eth.sub(_ethTarget);
            uint256 _withdrawableEth = ITBoxManager(settings.tBoxManager()).withdrawableEth(
                bonds[_id].tBoxId
            );
            if (_issuerEth > _withdrawableEth) {
                _issuerEth = _withdrawableEth;
            }
            ITBoxManager(settings.tBoxManager()).withdrawEth(
                bonds[_id].tBoxId,
                _issuerEth
            );
            bonds[_id].issuer.transfer(_issuerEth);
        }

        _eth = ITBoxManager(settings.tBoxManager()).withdrawableEth(
            bonds[_id].tBoxId
        );

        uint256 _commission = _eth.mul(bonds[_id].sysFee).div(divider);

        if (_commission > 0) {
            ITBoxManager(settings.tBoxManager()).withdrawEth(
                bonds[_id].tBoxId,
                _commission
            );
            systemETH = systemETH.add(_commission);
        }

        ITBoxManager(settings.tBoxManager()).transferFrom(
            address(this),
            bonds[_id].holder,
            bonds[_id].tBoxId
        );

        emit BondExpired(_id, bonds[_id].issuer, bonds[_id].holder);

        delete bonds[_id];
    }

    function getBox(uint256 _id) public view returns(uint256, uint256) {

        return ITBoxManager(settings.tBoxManager()).boxes(_id);
    }

    function() external payable {}

    function withdrawSystemETH(address _beneficiary) external onlyAdmin {

        require(_beneficiary != address(0), "Zero address, be careful");
        require(systemETH > 0, "There is no available ETH");

        uint256 _systemETH = systemETH;
        systemETH = 0;
        _beneficiary.transfer(_systemETH);
    }

    function reclaimERC20(address _token, address _beneficiary) external onlyAdmin {

        require(_beneficiary != address(0), "Zero address, be careful");

        uint256 _amount = IToken(_token).balanceOf(address(this));
        require(_amount > 0, "There are no tokens");
        IToken(_token).transfer(_beneficiary, _amount);
    }

    function setIssuerFee(uint256 _value) external onlyAdmin {

        require(_value <= 10000, "Too much");
        issuerFee = _value;
        emit BondIssuerFeeUpdated(_value);
    }

    function setHolderFee(uint256 _value) external onlyAdmin {

        require(_value <= 50000, "Too much");
        holderFee = _value;
        emit BondHolderFeeUpdated(_value);
    }

    function setMinEther(uint256 _value) external onlyAdmin {

        require(_value <= 100 ether, "Too much");
        minEther = _value;
        emit BondMinEtherUpdated(_value);
    }

    function changeAdmin(address _newAdmin) external onlyAdmin {

        require(_newAdmin != address(0), "Zero address, be careful");
        admin = _newAdmin;
    }

    function precision() public view returns(uint256) {

        return ITBoxManager(settings.tBoxManager()).precision();
    }

    function rate() public view returns(uint256) {

        return IOracle(settings.oracleAddress()).ethUsdPrice();
    }

    function transferIssuerRights(address _to, uint256 _id) external onlyIssuer(_id) {

        require(_to != address(0), "Zero address, be careful");
        bonds[_id].issuer = _to;
        emit IssuerRightsTransferred(msg.sender, _to, _id);
    }

    function transferHolderRights(address _to, uint256 _id) external onlyHolder(_id) {

        require(_to != address(0), "Zero address, be careful");
        bonds[_id].holder = _to;
        emit HolderRightsTransferred(msg.sender, _to, _id);
    }
}
