
pragma solidity 0.5.12;



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


library Blocklock {

  using SafeMath for uint256;

  struct State {
    uint256 lockedAt;
    uint256 unlockedAt;
    uint256 lockDuration;
    uint256 cooldownDuration;
  }

  function setLockDuration(State storage self, uint256 lockDuration) public {

    require(lockDuration > 0, "Blocklock/lock-min");
    self.lockDuration = lockDuration;
  }

  function setCooldownDuration(State storage self, uint256 cooldownDuration) public {

    require(cooldownDuration > 0, "Blocklock/cool-min");
    self.cooldownDuration = cooldownDuration;
  }

  function isLocked(State storage self, uint256 blockNumber) public view returns (bool) {

    uint256 endAt = lockEndAt(self);
    return (
      self.lockedAt != 0 &&
      blockNumber >= self.lockedAt &&
      blockNumber < endAt
    );
  }

  function lock(State storage self, uint256 blockNumber) public {

    require(canLock(self, blockNumber), "Blocklock/no-lock");
    self.lockedAt = blockNumber;
  }

  function unlock(State storage self, uint256 blockNumber) public {

    self.unlockedAt = blockNumber;
  }

  function canLock(State storage self, uint256 blockNumber) public view returns (bool) {

    uint256 endAt = lockEndAt(self);
    return (
      self.lockedAt == 0 ||
      blockNumber >= endAt.add(self.cooldownDuration)
    );
  }

  function cooldownEndAt(State storage self) internal view returns (uint256) {

    return lockEndAt(self).add(self.cooldownDuration);
  }

  function lockEndAt(State storage self) internal view returns (uint256) {

    uint256 endAt = self.lockedAt.add(self.lockDuration);
    if (self.unlockedAt >= self.lockedAt && self.unlockedAt < endAt) {
      endAt = self.unlockedAt;
    }
    return endAt;
  }
}