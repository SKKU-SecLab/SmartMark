
pragma solidity >=0.5.0 <0.6.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface INMR {



    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


    function withdraw(address _from, address _to, uint256 _value) external returns(bool ok);


    function destroyStake(address _staker, bytes32 _tag, uint256 _tournamentID, uint256 _roundID) external returns (bool ok);


    function createRound(uint256, uint256, uint256, uint256) external returns (bool ok);


    function createTournament(uint256 _newDelegate) external returns (bool ok);


    function mint(uint256 _value) external returns (bool ok);


    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);


    function contractUpgradable() external view returns (bool);


    function getTournament(uint256 _tournamentID) external view returns (uint256, uint256[] memory);


    function getRound(uint256 _tournamentID, uint256 _roundID) external view returns (uint256, uint256, uint256);


    function getStake(uint256 _tournamentID, uint256 _roundID, address _staker, bytes32 _tag) external view returns (uint256, uint256, bool, bool);


}


contract NMRUser {


    address internal constant _TOKEN = address(0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671);

    function _burn(uint256 _value) internal {

        if (INMR(_TOKEN).contractUpgradable())
            require(INMR(_TOKEN).transfer(address(0), _value));
        else
            require(INMR(_TOKEN).mint(_value), "burn not successful");
    }

    function _burnFrom(address _from, uint256 _value) internal {

        if (INMR(_TOKEN).contractUpgradable())
            require(INMR(_TOKEN).transferFrom(_from, address(0), _value));
        else
            require(INMR(_TOKEN).numeraiTransfer(_from, _value), "burnFrom not successful");
    }

}


contract SpankJar is NMRUser {

    
    using SafeMath for uint256;
    
    address public owner;
    uint256 public ratio;
    bool public isActive = true;
    
    constructor(uint256 _ratio) public {
        ratio = _ratio;
        owner = msg.sender;
    }
    
    function() external payable {
        require(isActive, 'already ended');
    }
    
    event Ended(uint256 nmrBurned, uint256 ethBurned);
    
    function end() public {

        require(msg.sender == owner, 'not sender');
        require(isActive, 'already ended');
        
        uint256 punishment = getTotalPunishment();
        uint256 balance = getRemainingBalance();
        
        _burn(punishment);
        
        require(INMR(_TOKEN).transfer(msg.sender, balance));
        
        isActive = false;
        
        emit Ended(punishment, address(this).balance);
    }
    
    function getTotalPunishment() public view returns (uint256 punishment) {

        return address(this).balance.mul(ratio);
    }
    
    function getRemainingBalance() public view returns (uint256 balance) {

        balance = INMR(_TOKEN).balanceOf(address(this));
        uint256 punishment = getTotalPunishment();
        balance = (punishment > balance) ? 0 : balance.sub(punishment);
    }
}