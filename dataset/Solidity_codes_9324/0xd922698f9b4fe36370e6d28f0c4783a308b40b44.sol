pragma solidity ^0.7.0;
pragma experimental SMTChecker;

abstract contract MemberMgrIf {
    function requireMerchant(address _who) virtual public view;

    function requireCustodian(address _who) virtual public view;
}

pragma solidity ^0.7.0;


abstract contract OwnableIf {

    modifier onlyOwner() {
        require(msg.sender == _owner(), "not owner......");
        _;
    }

    function _owner() view virtual public returns (address);
}

pragma solidity ^0.7.0;




contract Ownable is OwnableIf {

    address public owner;

    function _owner() view override public returns (address){

        return owner;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {
        owner = msg.sender;
    }



    function transferOwnership(address _newOwner) virtual public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0), "invalid _newOwner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}



pragma solidity ^0.7.0;




contract Claimable is Ownable {

    address public pendingOwner;

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner, "no permission");
        _;
    }

    function transferOwnership(address newOwner) override public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

pragma solidity ^0.7.0;

abstract contract ERC20If {
    function totalSupply() virtual public view returns (uint256);

    function balanceOf(address _who) virtual public view returns (uint256);

    function transfer(address _to, uint256 _value) virtual public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address _owner, address _spender) virtual public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool);

    function approve(address _spender, uint256 _value) virtual public returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.7.0;



abstract contract CanReclaimToken is OwnableIf {

    function reclaimToken(ERC20If _token) external onlyOwner {
        uint256 balance = _token.balanceOf((address)(this));
        require(_token.transfer(_owner(), balance));
    }

}

pragma solidity ^0.7.0;



contract MemberMgr is Claimable, MemberMgrIf, CanReclaimToken {

    address public custodian;
    enum MerchantStatus {STOPPED, VALID}
    struct MerchantStatusData {
        MerchantStatus status;
        bool _exist;
    }

    function getStatusString(MerchantStatusData memory data) internal pure returns (string memory) {

        if (!data._exist) return "not-exist";
        if (data.status == MerchantStatus.STOPPED) {
            return "stopped";
        } else if (data.status == MerchantStatus.VALID) {
            return "valid";
        } else {
            return "not-exist";
        }
    }

    mapping(address => MerchantStatusData) public merchantStatus;
    address[] merchantList;

    function getMerchantNumber() public view returns (uint){

        return merchantList.length;
    }

    function getMerchantState(uint index) public view returns (address _addr, string memory _status){

        require(index < merchantList.length, "invalid index");
        address addr = merchantList[index];
        MerchantStatusData memory data = merchantStatus[addr];
        _addr = addr;
        _status = getStatusString(data);
    }

    function requireMerchant(address _who) override public view {

        MerchantStatusData memory merchantState = merchantStatus[_who];
        require (merchantState._exist, "not a merchant");

        require (merchantState.status != MerchantStatus.STOPPED, "merchant has been stopped");

        require(merchantState.status == MerchantStatus.VALID, "merchant not valid");
    }


    function requireCustodian(address _who) override public view {

        require(_who == custodian, "not custodian");
    }

    event CustodianSet(address indexed custodian);

    function setCustodian(address _custodian) external onlyOwner returns (bool) {

        require(_custodian != address(0), "invalid custodian address");
        custodian = _custodian;

        emit CustodianSet(_custodian);
        return true;
    }

    event NewMerchant(address indexed merchant);

    function addMerchant(address merchant) external onlyOwner returns (bool) {

        require(merchant != address(0), "invalid merchant address");
        MerchantStatusData memory data = merchantStatus[merchant];
        require(!data._exist, "merchant exists");
        merchantStatus[merchant] = MerchantStatusData({
            status : MerchantStatus.VALID,
            _exist : true
            });

        merchantList.push(merchant);
        emit NewMerchant(merchant);
        return true;
    }

    event MerchantStopped(address indexed merchant);

    function stopMerchant(address merchant) external onlyOwner returns (bool) {

        require(merchant != address(0), "invalid merchant address");
        MerchantStatusData memory data = merchantStatus[merchant];
        require(data._exist, "merchant not exists");
        require(data.status == MerchantStatus.VALID, "invalid status");
        merchantStatus[merchant].status = MerchantStatus.STOPPED;

        emit MerchantStopped(merchant);
        return true;
    }

    event MerchantResumed(address indexed merchant);

    function resumeMerchant(address merchant) external onlyOwner returns (bool) {

        require(merchant != address(0), "invalid merchant address");
        MerchantStatusData memory data = merchantStatus[merchant];
        require(data._exist, "merchant not exists");
        require(data.status == MerchantStatus.STOPPED, "invalid status");
        merchantStatus[merchant].status = MerchantStatus.VALID;

        emit MerchantResumed(merchant);
        return true;
    }

    function isCustodian(address addr) external view returns (bool) {

        return (addr == custodian);
    }

    function isMerchant(address addr) external view returns (bool) {

        return merchantStatus[addr]._exist && merchantStatus[addr].status == MerchantStatus.VALID;
    }
}
