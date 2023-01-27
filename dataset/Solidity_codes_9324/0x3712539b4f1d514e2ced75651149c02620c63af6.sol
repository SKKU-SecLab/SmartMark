

pragma solidity 0.5.10;




library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


contract ICurvePool {

    function deposit(uint256 _amount) public;

    function withdraw(uint256 _amount) public;

    function earnReward(address[] memory yieldtokens) public;


    function get_virtual_price() public view returns(uint256);

    function get_lp_token_balance() public view returns(uint256);

    function get_lp_token_addr() public view returns(address);


    function setController(address, address) public;

}


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ownable {

    address private _contract_owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = msg.sender;
        _contract_owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _contract_owner;
    }

    modifier onlyOwner() {

        require(_contract_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_contract_owner, newOwner);
        _contract_owner = newOwner;
    }
}


contract IController is Ownable{

    function deposit(uint256) public;

    function withdraw(uint256) public;

    function setVault(address) public;

    function get_current_pool() public view returns(ICurvePool);

}


contract IVault is Ownable{

    function changeController(address) public;

}


contract Upgrader is Ownable {

    using Address for address;

    address new_owner;
    IVault vault;
    IController old_controller;
    IController new_controller;
    ICurvePool new_pool;
    ICurvePool old_pool;

    constructor(address owner) public  {
        transferOwnership(owner);
    }

    function prepare_upgrade(address _vault, address _old_controller, address _new_controller) public onlyOwner() {

        vault = IVault(_vault.toPayable());
        old_controller = IController(_old_controller.toPayable());
        old_pool = old_controller.get_current_pool();
        new_controller = IController(_new_controller.toPayable());
        new_pool = new_controller.get_current_pool();
        new_owner = this.owner();
    }

    event withdrawn(uint256 tt_amount);
    event minted(uint256 lp_amount);
    function upgrade() public onlyOwner() {

        IERC20 target_token = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        
        old_pool.setController(address(old_controller), address(this)); //actually set vault
        old_controller.setVault(address(this));
        old_controller.withdraw(old_pool.get_lp_token_balance());

        uint256 target_token_amount = target_token.balanceOf(address(this));
        emit withdrawn(target_token_amount);

        new_pool.setController(address(new_controller), address(this));
        new_controller.setVault(address(this));
        target_token.transfer(address(new_pool), target_token_amount);
        new_controller.deposit(target_token_amount);
        emit minted(new_pool.get_lp_token_balance());
        

        new_pool.setController(address(new_controller), address(vault));
        new_controller.setVault(address(vault));
        vault.changeController(address(new_controller));
        releaseOwnership(new_owner);
    }

    function releaseOwnership(address _owner) public onlyOwner() {

        vault.transferOwnership(_owner);
        new_controller.transferOwnership(_owner);
        Ownable(address(new_pool)).transferOwnership(_owner);
        old_controller.transferOwnership(_owner);
        Ownable(address(old_pool)).transferOwnership(_owner);
    }
}