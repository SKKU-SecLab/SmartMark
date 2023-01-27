
pragma solidity 0.8.3;

struct ReleaseSchedule {
    uint releaseCount;
    uint delayUntilFirstReleaseInSeconds;
    uint initialReleasePortionInBips;
    uint periodBetweenReleasesInSeconds;
}

struct Timelock {
    uint scheduleId;
    uint commencementTimestamp;
    uint tokensTransferred;
    uint totalAmount;
}

library ScheduleCalc {

    uint constant BIPS_PRECISION = 10000;

    function calculateUnlocked(uint commencedTimestamp, uint currentTimestamp, uint amount, ReleaseSchedule memory releaseSchedule) external pure returns (uint unlocked) {

        if(commencedTimestamp > currentTimestamp) {
            return 0;
        }
        uint secondsElapsed = currentTimestamp - commencedTimestamp;

        if (secondsElapsed >= releaseSchedule.delayUntilFirstReleaseInSeconds +
        (releaseSchedule.periodBetweenReleasesInSeconds * (releaseSchedule.releaseCount - 1))) {
            return amount;
        }

        if (secondsElapsed >= releaseSchedule.delayUntilFirstReleaseInSeconds) {
            unlocked = (amount * releaseSchedule.initialReleasePortionInBips) / BIPS_PRECISION;

            if (secondsElapsed - releaseSchedule.delayUntilFirstReleaseInSeconds
                >= releaseSchedule.periodBetweenReleasesInSeconds) {

                uint additionalUnlockedPeriods =
                (secondsElapsed - releaseSchedule.delayUntilFirstReleaseInSeconds) /
                releaseSchedule.periodBetweenReleasesInSeconds;

                unlocked += ((amount - unlocked) * additionalUnlockedPeriods) / (releaseSchedule.releaseCount - 1);
            }
        }

        return unlocked;
    }
}