pragma solidity 0.8.7;

interface KeeperCompatibleInterface {

    function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external;

}


contract OusdKeeper is KeeperCompatibleInterface {


    event ConfigUpdated(bytes32 config);

    address constant vault = 0xE75D77B1865Ae93c7eaa3040B038D7aA7BC02F70;
    address constant dripper = 0x80C898ae5e56f888365E235CeB8CEa3EB726CB58;
    address constant owner = 0xF14BBdf064E3F67f51cd9BD646aE3716aD938FDC;
    uint24 immutable windowStart; // seconds after start of day
    uint24 immutable windowEnd; // seconds after start of day
    uint256 lastRunDay = 0;
    bytes32 public config;
    

    constructor(
        uint24 windowStart_,
        uint24 windowEnd_,
        bytes32 config_
    ) {
        windowStart = windowStart_;
        windowEnd = windowEnd_;
        config = config_;
    }

    function setConfig(bytes32 config_) external {

        require(msg.sender == owner);
        config = config_;
        emit ConfigUpdated(config);
    }

    function checkUpkeep(bytes calldata checkData)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {

        (bool runRebase, bool runAllocate) = _shouldRun();
        upkeepNeeded = (runRebase || runAllocate);
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {

        (bool runRebase, bool runAllocate) = _shouldRun();
        if (runRebase || runAllocate) {
            lastRunDay = (block.timestamp / 86400);
        }
        
    

        if (runRebase) {
            dripper.call(abi.encodeWithSignature("collectAndRebase()"));
        }

        if (runAllocate) {
            vault.call(abi.encodeWithSignature("allocate()"));
        }
        
    }

    function _shouldRun()
        internal
        view
        returns (bool runRebase, bool runAllocate)
    {

        bytes32 _config = config; // Gas savings

        uint256 day = block.timestamp / 86400;
        if (lastRunDay >= day) {
            return (false, false);
        }

        uint256 daySeconds = block.timestamp % 86400;
        if (daySeconds < windowStart || daySeconds > windowEnd) {
            return (false, false);
        }

        uint8 rebaseDays = uint8(_config[0]); // day of week bits
        uint8 allocateDays = uint8(_config[1]); // day of week bits

        uint8 weekday = uint8((day + 4) % 7);

        if (((rebaseDays >> weekday) & 1) != 0) {
            runRebase = true;
        }

        if (((allocateDays >> weekday) & 1) != 0) {
            runAllocate = true;
        }
    }
}