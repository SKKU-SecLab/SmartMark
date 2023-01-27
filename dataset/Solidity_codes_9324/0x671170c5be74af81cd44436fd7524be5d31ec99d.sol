pragma solidity 0.8.4;


library Address {


    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

}//MIT
pragma solidity 0.8.4;

interface IERC20 {


    function totalSupply() external view returns (uint256);

    
    function symbol() external view returns(string memory);

    
    function name() external view returns(string memory);


    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//MIT
pragma solidity 0.8.4;

interface IELONphantStaking {

    function deposit(uint256 amount) external;

}//MIT
pragma solidity 0.8.4;


contract ELONphantFundingReceiver {

    
    using Address for address;
    
    address public farm;
    address public stake;
    address public multisig;
    address public foundation;
    address public constant ELONphant = 0xB7E29bD8A0D34d9eb41FC654eA1C6633ed59DD64;
    
    uint256 public farmFee;
    uint256 public stakeFee;
    uint256 public multisigFee;
    uint256 public foundationFee;
    
    address public _master;
    modifier onlyMaster(){require(_master == msg.sender, 'Sender Not Master'); _;}

    
    constructor() {
    
        _master = 0x156fb36ffD41fCBb76DaEfbFC0b1fF263E944AC8;
        multisig = 0x156fb36ffD41fCBb76DaEfbFC0b1fF263E944AC8;
        farm = 0x156fb36ffD41fCBb76DaEfbFC0b1fF263E944AC8;
        stake = 0x3Bc217cbBB234F5fe0D04A94C9dEf13bED1E423D;
        foundation = 0x156fb36ffD41fCBb76DaEfbFC0b1fF263E944AC8;
        stakeFee = 15;
        farmFee = 50;
        foundationFee = 30;
        multisigFee = 5;

    }
    
    event SetFarm(address farm);
    event SetStaker(address staker);
    event SetMultisig(address multisig);
    event SetFoundation(address foundation);
    event SetFundPercents(uint256 farmPercentage, uint256 stakePercent, uint256 multisigPercent, uint256 foundationPercent);
    event Withdrawal(uint256 amount);
    event OwnershipTransferred(address newOwner);
    
    
    function setFarm(address _farm) external onlyMaster {

        farm = _farm;
        emit SetFarm(_farm);
    }
    
    function setStake(address _stake) external onlyMaster {

        stake = _stake;
        emit SetStaker(_stake);
    }
     function setFoundation(address _foundation) external onlyMaster {

        foundation = _foundation;

        emit SetFoundation(_foundation);
    }
    function setMultisig(address _multisig) external onlyMaster {

        multisig = _multisig;
        emit SetMultisig(_multisig);
    }
    
    function setFundPercents(uint256 farmPercentage, uint256 stakePercent, uint256 multisigPercent, uint256 foundationPercent) external onlyMaster {

        farmFee = farmPercentage;
        stakeFee = stakePercent;
        multisigFee = multisigPercent;
        foundationFee = foundationPercent;
        emit SetFundPercents(farmPercentage, stakePercent, multisigPercent,foundationPercent);
    }
    
    function manualWithdraw(address token) external onlyMaster {

        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0);
        IERC20(token).transfer(_master, bal);
        emit Withdrawal(bal);
    }
    
    function ETHWithdrawal() external onlyMaster returns (bool s){

        uint256 bal = address(this).balance;
        require(bal > 0);
        (s,) = payable(_master).call{value: bal}("");
        emit Withdrawal(bal);
    }
    
    function transferMaster(address newMaster) external onlyMaster {

        _master = newMaster;
        emit OwnershipTransferred(newMaster);
    }
    
    
    
    function distribute() external {

        _distributeYield();
    }

    
    function _distributeYield() private {

        
        uint256 ELONphantBal = IERC20(ELONphant).balanceOf(address(this));
        
        uint256 farmBal = (ELONphantBal * farmFee) / 10**2;
        uint256 sigBal = (ELONphantBal * multisigFee) / 10**2;
        uint256 stakeBal = ELONphantBal - (farmBal + sigBal);
        uint256 foundationBal = (ELONphantBal * foundationFee) / 10**2;

        if (farmBal > 0 && farm != address(0)) {
            IERC20(ELONphant).approve(farm, farmBal);
            IELONphantStaking(farm).deposit(farmBal);
        }
        
        if (stakeBal > 0 && stake != address(0)) {
            IERC20(ELONphant).approve(stake, stakeBal);
            IELONphantStaking(stake).deposit(stakeBal);
        }
        
        if (sigBal > 0 && multisig != address(0)) {
            IERC20(ELONphant).transfer(multisig, sigBal);
        }

        if (foundationBal > 0 && foundation != address(0)) {
            IERC20(ELONphant).approve(foundation, foundationBal);
            IELONphantStaking(foundation).deposit(foundationBal);
            
        }
    }
    
    receive() external payable {
        (bool s,) = payable(ELONphant).call{value: msg.value}("");
        require(s, 'Failure on Token Purchase');
        _distributeYield();
    }
    
}