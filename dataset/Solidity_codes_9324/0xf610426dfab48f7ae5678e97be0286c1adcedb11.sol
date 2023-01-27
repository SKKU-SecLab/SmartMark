
pragma solidity >=0.6.7 <0.7.0;




interface PauseAbstract {

    function delay() external view returns (uint256);

    function plot(address, bytes32, bytes calldata, uint256) external;

    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);

}

interface Changelog {

    function getAddress(bytes32) external view returns (address);

}

interface SpellAction {

    function officeHours() external view returns (bool);

}

contract DssExec {


    Changelog      constant public log   = Changelog(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    uint256                 public eta;
    bytes                   public sig;
    bool                    public done;
    bytes32       immutable public tag;
    address       immutable public action;
    uint256       immutable public expiration;
    PauseAbstract immutable public pause;

    string                  public description;

    function officeHours() external view returns (bool) {

        return SpellAction(action).officeHours();
    }

    function nextCastTime() external view returns (uint256 castTime) {

        require(eta != 0, "DssExec/spell-not-scheduled");
        castTime = block.timestamp > eta ? block.timestamp : eta; // Any day at XX:YY

        if (SpellAction(action).officeHours()) {
            uint256 day    = (castTime / 1 days + 3) % 7;
            uint256 hour   = castTime / 1 hours % 24;
            uint256 minute = castTime / 1 minutes % 60;
            uint256 second = castTime % 60;

            if (day >= 5) {
                castTime += (6 - day) * 1 days;                 // Go to Sunday XX:YY
                castTime += (24 - hour + 14) * 1 hours;         // Go to 14:YY UTC Monday
                castTime -= minute * 1 minutes + second;        // Go to 14:00 UTC
            } else {
                if (hour >= 21) {
                    if (day == 4) castTime += 2 days;           // If Friday, fast forward to Sunday XX:YY
                    castTime += (24 - hour + 14) * 1 hours;     // Go to 14:YY UTC next day
                    castTime -= minute * 1 minutes + second;    // Go to 14:00 UTC
                } else if (hour < 14) {
                    castTime += (14 - hour) * 1 hours;          // Go to 14:YY UTC same day
                    castTime -= minute * 1 minutes + second;    // Go to 14:00 UTC
                }
            }
        }
    }

    constructor(string memory _description, uint256 _expiration, address _spellAction) public {
        pause       = PauseAbstract(log.getAddress("MCD_PAUSE"));
        description = _description;
        expiration  = _expiration;
        action      = _spellAction;

        sig = abi.encodeWithSignature("execute()");
        bytes32 _tag;                    // Required for assembly access
        address _action = _spellAction;  // Required for assembly access
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
    }

    function schedule() public {

        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + PauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {

        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}



contract DssExecFactory {


    function newExec(string memory description, uint256 expiration, address spellAction) public returns (address exec) {

        exec = address(new DssExec(description, expiration, spellAction));
    }

    function newWeeklyExec(string memory description, address spellAction) public returns (address exec) {

        exec = newExec(description, now + 30 days, spellAction);
    }

    function newMonthlyExec(string memory description, address spellAction) public returns (address exec) {

        exec = newExec(description, now + 4 days, spellAction);
    }
}