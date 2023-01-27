
pragma solidity 0.4.25;


interface IModelDataSource {

    function getInterval(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);


    function getIntervalCoefs(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256);


    function getRequiredMintAmount(uint256 _rowNum) external view returns (uint256);

}


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract Claimable is Ownable {

  address public pendingOwner;

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    pendingOwner = newOwner;
  }

  function claimOwnership() public onlyPendingOwner {

    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}



contract ModelDataSource is IModelDataSource, Claimable {

    string public constant VERSION = "1.0.0";

    struct Interval {
        uint256 minN;
        uint256 maxN;
        uint256 minR;
        uint256 maxR;
        uint256 alpha;
        uint256 beta;
    }

    bool public intervalListsLocked;
    Interval[11][95] public intervalLists;

    function lock() external onlyOwner {

        intervalListsLocked = true;
    }

    function setInterval(uint256 _rowNum, uint256 _colNum, uint256 _minN, uint256 _maxN, uint256 _minR, uint256 _maxR, uint256 _alpha, uint256 _beta) external onlyOwner {

        require(!intervalListsLocked, "interval lists are already locked");
        intervalLists[_rowNum][_colNum] = Interval({minN: _minN, maxN: _maxN, minR: _minR, maxR: _maxR, alpha: _alpha, beta: _beta});
    }

    function getInterval(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        Interval storage interval = intervalLists[_rowNum][_colNum];
        return (interval.minN, interval.maxN, interval.minR, interval.maxR, interval.alpha, interval.beta);
    }

    function getIntervalCoefs(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256) {

        Interval storage interval = intervalLists[_rowNum][_colNum];
        return (interval.alpha, interval.beta);
    }

    function getRequiredMintAmount(uint256 _rowNum) external view returns (uint256) {

        uint256 currMaxN = intervalLists[_rowNum + 0][0].maxN;
        uint256 nextMinN = intervalLists[_rowNum + 1][0].minN;
        assert(nextMinN >= currMaxN);
        return nextMinN - currMaxN;
    }
}



contract BatchSetModelDataSource is Claimable {

    string public constant VERSION = "1.0.0";

    uint256 public constant MAX_INTERVAL_INPUT_LENGTH = 32;

    ModelDataSource public modelDataSource;

    constructor(address _modelDataSourceAddress) public {
        require(_modelDataSourceAddress != address(0), "model data source address is illegal");
        modelDataSource = ModelDataSource(_modelDataSourceAddress);
    }

    function setIntervals(uint256 _intervalsCount,
        uint256[MAX_INTERVAL_INPUT_LENGTH] _rowNum,
        uint256[MAX_INTERVAL_INPUT_LENGTH] _colNum,
        uint256[MAX_INTERVAL_INPUT_LENGTH] _minN,
        uint256[MAX_INTERVAL_INPUT_LENGTH] _maxN,
        uint256[MAX_INTERVAL_INPUT_LENGTH] _minR,
        uint256[MAX_INTERVAL_INPUT_LENGTH] _maxR,
        uint256[MAX_INTERVAL_INPUT_LENGTH] _alpha,
        uint256[MAX_INTERVAL_INPUT_LENGTH] _beta) external onlyOwner {

        require(_intervalsCount < MAX_INTERVAL_INPUT_LENGTH, "intervals count must be lower than MAX_INTERVAL_INPUT_LENGTH");

        for (uint256 i = 0; i < _intervalsCount; i++) {
            modelDataSource.setInterval(_rowNum[i], _colNum[i], _minN[i], _maxN[i], _minR[i], _maxR[i], _alpha[i], _beta[i]);
        }
    }

    function claimOwnershipModelDataSource() external onlyOwner {

        modelDataSource.claimOwnership();
    }

    function renounceOwnershipModelDataSource() external onlyOwner {

        modelDataSource.renounceOwnership();
    }

    function lockModelDataSource() external onlyOwner {

        modelDataSource.lock();
    }
}