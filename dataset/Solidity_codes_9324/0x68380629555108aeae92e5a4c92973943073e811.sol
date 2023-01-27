


// Adapted to use pragma ^0.5.8 and satisfy our linter rules

pragma solidity ^0.5.8;


contract ERC20 {

    function totalSupply() public view returns (uint256);


    function balanceOf(address _who) public view returns (uint256);


    function allowance(address _owner, address _spender) public view returns (uint256);


    function transfer(address _to, uint256 _value) public returns (bool);


    function approve(address _spender, uint256 _value) public returns (bool);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



pragma solidity ^0.5.8;



library SafeERC20 {

    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferCallData = abi.encodeWithSelector(
            TRANSFER_SELECTOR,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferCallData);
    }

    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferFromCallData);
    }

    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {

        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), approveCallData);
    }

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata) private returns (bool) {

        bool ret;
        assembly {
            let ptr := mload(0x40)    // free memory pointer

            let success := call(
                gas,                  // forward all gas
                _addr,                // address
                0,                    // no value
                add(_calldata, 0x20), // calldata start
                mload(_calldata),     // calldata length
                ptr,                  // write output over free memory
                0x20                  // uint256 return
            )

            if gt(success, 0) {
                switch returndatasize

                case 0 {
                    ret := 1
                }

                case 0x20 {
                    ret := eq(mload(ptr), 1)
                }

                default { }
            }
        }
        return ret;
    }
}



pragma solidity >=0.4.24 <0.6.0;


library SafeMath {

    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}


pragma solidity ^0.5.8;



interface IJurorsRegistry {


    function assignTokens(address _juror, uint256 _amount) external;


    function burnTokens(uint256 _amount) external;


    function draft(uint256[7] calldata _params) external returns (address[] memory jurors, uint256 length);


    function slashOrUnlock(uint64 _termId, address[] calldata _jurors, uint256[] calldata _lockedAmounts, bool[] calldata _rewardedJurors)
        external
        returns (uint256 collectedTokens);


    function collectTokens(address _juror, uint256 _amount, uint64 _termId) external returns (bool);


    function lockWithdrawals(address _juror, uint64 _termId) external;


    function activeBalanceOfAt(address _juror, uint64 _termId) external view returns (uint256);


    function totalActiveBalanceAt(uint64 _termId) external view returns (uint256);

}


pragma solidity ^0.5.8;


library BytesHelpers {

    function toBytes4(bytes memory _self) internal pure returns (bytes4 result) {

        if (_self.length < 4) {
            return bytes4(0);
        }

        assembly { result := mload(add(_self, 0x20)) }
    }
}


pragma solidity ^0.5.8;


library Checkpointing {

    uint256 private constant MAX_UINT192 = uint256(uint192(-1));

    string private constant ERROR_VALUE_TOO_BIG = "CHECKPOINT_VALUE_TOO_BIG";
    string private constant ERROR_CANNOT_ADD_PAST_VALUE = "CHECKPOINT_CANNOT_ADD_PAST_VALUE";

    struct Checkpoint {
        uint64 time;
        uint192 value;
    }

    struct History {
        Checkpoint[] history;
    }

    function add(History storage self, uint64 _time, uint256 _value) internal {

        require(_value <= MAX_UINT192, ERROR_VALUE_TOO_BIG);
        _add192(self, _time, uint192(_value));
    }

    function getLast(History storage self) internal view returns (uint256) {

        uint256 length = self.history.length;
        if (length > 0) {
            return uint256(self.history[length - 1].value);
        }

        return 0;
    }

    function get(History storage self, uint64 _time) internal view returns (uint256) {

        return _binarySearch(self, _time);
    }

    function getRecent(History storage self, uint64 _time) internal view returns (uint256) {

        return _backwardsLinearSearch(self, _time);
    }

    function _add192(History storage self, uint64 _time, uint192 _value) private {

        uint256 length = self.history.length;
        if (length == 0 || self.history[self.history.length - 1].time < _time) {
            self.history.push(Checkpoint(_time, _value));
        } else {
            Checkpoint storage currentCheckpoint = self.history[length - 1];
            require(_time == currentCheckpoint.time, ERROR_CANNOT_ADD_PAST_VALUE);
            currentCheckpoint.value = _value;
        }
    }

    function _backwardsLinearSearch(History storage self, uint64 _time) private view returns (uint256) {

        uint256 length = self.history.length;
        if (length == 0) {
            return 0;
        }

        uint256 index = length - 1;
        Checkpoint storage checkpoint = self.history[index];
        while (index > 0 && checkpoint.time > _time) {
            index--;
            checkpoint = self.history[index];
        }

        return checkpoint.time > _time ? 0 : uint256(checkpoint.value);
    }

    function _binarySearch(History storage self, uint64 _time) private view returns (uint256) {

        uint256 length = self.history.length;
        if (length == 0) {
            return 0;
        }

        uint256 lastIndex = length - 1;
        if (_time >= self.history[lastIndex].time) {
            return uint256(self.history[lastIndex].value);
        }

        if (_time < self.history[0].time) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = lastIndex;

        while (high > low) {
            uint256 mid = (high + low + 1) / 2;
            Checkpoint storage checkpoint = self.history[mid];
            uint64 midTime = checkpoint.time;

            if (_time > midTime) {
                low = mid;
            } else if (_time < midTime) {
                high = mid - 1;
            } else {
                return uint256(checkpoint.value);
            }
        }

        return uint256(self.history[low].value);
    }
}


pragma solidity ^0.5.8;




library HexSumTree {

    using SafeMath for uint256;
    using Checkpointing for Checkpointing.History;

    string private constant ERROR_UPDATE_OVERFLOW = "SUM_TREE_UPDATE_OVERFLOW";
    string private constant ERROR_KEY_DOES_NOT_EXIST = "SUM_TREE_KEY_DOES_NOT_EXIST";
    string private constant ERROR_SEARCH_OUT_OF_BOUNDS = "SUM_TREE_SEARCH_OUT_OF_BOUNDS";
    string private constant ERROR_MISSING_SEARCH_VALUES = "SUM_TREE_MISSING_SEARCH_VALUES";

    uint256 private constant CHILDREN = 16;
    uint256 private constant BITS_IN_NIBBLE = 4;

    uint256 private constant ITEMS_LEVEL = 0;

    uint256 private constant BASE_KEY = 0;

    uint64 private constant INITIALIZATION_INITIAL_TIME = uint64(0);

    struct Tree {
        uint256 nextKey;
        Checkpointing.History height;
        mapping (uint256 => mapping (uint256 => Checkpointing.History)) nodes;
    }

    struct SearchParams {
        uint64 time;
        uint256 level;
        uint256 parentKey;
        uint256 foundValues;
        uint256 visitedTotal;
    }

    function init(Tree storage self) internal {

        self.height.add(INITIALIZATION_INITIAL_TIME, ITEMS_LEVEL + 1);
        self.nextKey = BASE_KEY;
    }

    function insert(Tree storage self, uint64 _time, uint256 _value) internal returns (uint256) {

        uint256 key = self.nextKey++;
        _addLevelIfNecessary(self, key, _time);

        if (_value > 0) {
            _add(self, ITEMS_LEVEL, key, _time, _value);
            _updateSums(self, key, _time, _value, true);
        }
        return key;
    }

    function set(Tree storage self, uint256 _key, uint64 _time, uint256 _value) internal {

        require(_key < self.nextKey, ERROR_KEY_DOES_NOT_EXIST);

        uint256 lastValue = getItem(self, _key);
        _add(self, ITEMS_LEVEL, _key, _time, _value);

        if (_value > lastValue) {
            _updateSums(self, _key, _time, _value - lastValue, true);
        } else if (_value < lastValue) {
            _updateSums(self, _key, _time, lastValue - _value, false);
        }
    }

    function update(Tree storage self, uint256 _key, uint64 _time, uint256 _delta, bool _positive) internal {

        require(_key < self.nextKey, ERROR_KEY_DOES_NOT_EXIST);

        uint256 lastValue = getItem(self, _key);
        uint256 newValue = _positive ? lastValue.add(_delta) : lastValue.sub(_delta);
        _add(self, ITEMS_LEVEL, _key, _time, newValue);

        _updateSums(self, _key, _time, _delta, _positive);
    }

    function search(Tree storage self, uint256[] memory _values, uint64 _time) internal view
        returns (uint256[] memory keys, uint256[] memory values)
    {

        require(_values.length > 0, ERROR_MISSING_SEARCH_VALUES);

        uint256 total = getRecentTotalAt(self, _time);
        require(total > 0 && total > _values[_values.length - 1], ERROR_SEARCH_OUT_OF_BOUNDS);

        uint256 rootLevel = getRecentHeightAt(self, _time);
        SearchParams memory searchParams = SearchParams(_time, rootLevel.sub(1), BASE_KEY, 0, 0);

        uint256 length = _values.length;
        keys = new uint256[](length);
        values = new uint256[](length);
        _search(self, _values, searchParams, keys, values);
    }

    function getTotal(Tree storage self) internal view returns (uint256) {

        uint256 rootLevel = getHeight(self);
        return getNode(self, rootLevel, BASE_KEY);
    }

    function getTotalAt(Tree storage self, uint64 _time) internal view returns (uint256) {

        uint256 rootLevel = getRecentHeightAt(self, _time);
        return getNodeAt(self, rootLevel, BASE_KEY, _time);
    }

    function getRecentTotalAt(Tree storage self, uint64 _time) internal view returns (uint256) {

        uint256 rootLevel = getRecentHeightAt(self, _time);
        return getRecentNodeAt(self, rootLevel, BASE_KEY, _time);
    }

    function getItem(Tree storage self, uint256 _key) internal view returns (uint256) {

        return getNode(self, ITEMS_LEVEL, _key);
    }

    function getItemAt(Tree storage self, uint256 _key, uint64 _time) internal view returns (uint256) {

        return getNodeAt(self, ITEMS_LEVEL, _key, _time);
    }

    function getNode(Tree storage self, uint256 _level, uint256 _key) internal view returns (uint256) {

        return self.nodes[_level][_key].getLast();
    }

    function getNodeAt(Tree storage self, uint256 _level, uint256 _key, uint64 _time) internal view returns (uint256) {

        return self.nodes[_level][_key].get(_time);
    }

    function getRecentNodeAt(Tree storage self, uint256 _level, uint256 _key, uint64 _time) internal view returns (uint256) {

        return self.nodes[_level][_key].getRecent(_time);
    }

    function getHeight(Tree storage self) internal view returns (uint256) {

        return self.height.getLast();
    }

    function getRecentHeightAt(Tree storage self, uint64 _time) internal view returns (uint256) {

        return self.height.getRecent(_time);
    }

    function _updateSums(Tree storage self, uint256 _key, uint64 _time, uint256 _delta, bool _positive) private {

        uint256 mask = uint256(-1);
        uint256 ancestorKey = _key;
        uint256 currentHeight = getHeight(self);
        for (uint256 level = ITEMS_LEVEL + 1; level <= currentHeight; level++) {
            mask = mask << BITS_IN_NIBBLE;

            ancestorKey = ancestorKey & mask;

            uint256 lastValue = getNode(self, level, ancestorKey);
            uint256 newValue = _positive ? lastValue.add(_delta) : lastValue.sub(_delta);
            _add(self, level, ancestorKey, _time, newValue);
        }

        require(!_positive || getNode(self, currentHeight, ancestorKey) >= _delta, ERROR_UPDATE_OVERFLOW);
    }

    function _addLevelIfNecessary(Tree storage self, uint256 _newKey, uint64 _time) private {

        uint256 currentHeight = getHeight(self);
        if (_shouldAddLevel(currentHeight, _newKey)) {
            uint256 newHeight = currentHeight + 1;
            uint256 rootValue = getNode(self, currentHeight, BASE_KEY);
            _add(self, newHeight, BASE_KEY, _time, rootValue);
            self.height.add(_time, newHeight);
        }
    }

    function _add(Tree storage self, uint256 _level, uint256 _key, uint64 _time, uint256 _value) private {

        self.nodes[_level][_key].add(_time, _value);
    }

    function _search(
        Tree storage self,
        uint256[] memory _values,
        SearchParams memory _params,
        uint256[] memory _resultKeys,
        uint256[] memory _resultValues
    )
        private
        view
    {

        uint256 levelKeyLessSignificantNibble = _params.level.mul(BITS_IN_NIBBLE);

        for (uint256 childNumber = 0; childNumber < CHILDREN; childNumber++) {
            if (_params.foundValues >= _values.length) {
                break;
            }

            uint256 childNodeKey = _params.parentKey.add(childNumber << levelKeyLessSignificantNibble);
            uint256 childNodeValue = getRecentNodeAt(self, _params.level, childNodeKey, _params.time);

            uint256 newVisitedTotal = _params.visitedTotal.add(childNodeValue);
            uint256 subtreeIncludedValues = _getValuesIncludedInSubtree(_values, _params.foundValues, newVisitedTotal);

            if (subtreeIncludedValues > 0) {
                if (_params.level == ITEMS_LEVEL) {
                    _copyFoundNode(_params.foundValues, subtreeIncludedValues, childNodeKey, _resultKeys, childNodeValue, _resultValues);
                } else {
                    SearchParams memory nextLevelParams = SearchParams(
                        _params.time,
                        _params.level - 1, // No need for SafeMath: we already checked above that the level being checked is greater than zero
                        childNodeKey,
                        _params.foundValues,
                        _params.visitedTotal
                    );
                    _search(self, _values, nextLevelParams, _resultKeys, _resultValues);
                }
                _params.foundValues = _params.foundValues.add(subtreeIncludedValues);
            }
            _params.visitedTotal = newVisitedTotal;
        }
    }

    function _shouldAddLevel(uint256 _currentHeight, uint256 _newKey) private pure returns (bool) {

        uint256 shift = _currentHeight.mul(BITS_IN_NIBBLE);
        uint256 mask = uint256(-1) << shift;

        return (_newKey & mask) != 0;
    }

    function _getValuesIncludedInSubtree(uint256[] memory _values, uint256 _foundValues, uint256 _subtreeTotal) private pure returns (uint256) {

        uint256 i = _foundValues;
        while (i < _values.length && _values[i] < _subtreeTotal) {
            i++;
        }
        return i - _foundValues;
    }

    function _copyFoundNode(
        uint256 _from,
        uint256 _times,
        uint256 _key,
        uint256[] memory _resultKeys,
        uint256 _value,
        uint256[] memory _resultValues
    )
        private
        pure
    {

        for (uint256 i = 0; i < _times; i++) {
            _resultKeys[_from + i] = _key;
            _resultValues[_from + i] = _value;
        }
    }
}


pragma solidity ^0.5.8;



library PctHelpers {

    using SafeMath for uint256;

    uint256 internal constant PCT_BASE = 10000; // ‱ (1 / 10,000)

    function isValid(uint16 _pct) internal pure returns (bool) {

        return _pct <= PCT_BASE;
    }

    function pct(uint256 self, uint16 _pct) internal pure returns (uint256) {

        return self.mul(uint256(_pct)) / PCT_BASE;
    }

    function pct256(uint256 self, uint256 _pct) internal pure returns (uint256) {

        return self.mul(_pct) / PCT_BASE;
    }

    function pctIncrease(uint256 self, uint16 _pct) internal pure returns (uint256) {

        return self.mul(PCT_BASE + uint256(_pct)) / PCT_BASE;
    }
}


pragma solidity ^0.5.8;




library JurorsTreeSortition {

    using SafeMath for uint256;
    using HexSumTree for HexSumTree.Tree;

    string private constant ERROR_INVALID_INTERVAL_SEARCH = "TREE_INVALID_INTERVAL_SEARCH";
    string private constant ERROR_SORTITION_LENGTHS_MISMATCH = "TREE_SORTITION_LENGTHS_MISMATCH";

    function batchedRandomSearch(
        HexSumTree.Tree storage tree,
        bytes32 _termRandomness,
        uint256 _disputeId,
        uint64 _termId,
        uint256 _selectedJurors,
        uint256 _batchRequestedJurors,
        uint256 _roundRequestedJurors,
        uint256 _sortitionIteration
    )
        internal
        view
        returns (uint256[] memory jurorsIds, uint256[] memory jurorsBalances)
    {

        (uint256 low, uint256 high) = getSearchBatchBounds(tree, _termId, _selectedJurors, _batchRequestedJurors, _roundRequestedJurors);
        uint256[] memory balances = _computeSearchRandomBalances(
            _termRandomness,
            _disputeId,
            _sortitionIteration,
            _batchRequestedJurors,
            low,
            high
        );

        (jurorsIds, jurorsBalances) = tree.search(balances, _termId);

        require(jurorsIds.length == jurorsBalances.length, ERROR_SORTITION_LENGTHS_MISMATCH);
        require(jurorsIds.length == _batchRequestedJurors, ERROR_SORTITION_LENGTHS_MISMATCH);
    }

    function getSearchBatchBounds(
        HexSumTree.Tree storage tree,
        uint64 _termId,
        uint256 _selectedJurors,
        uint256 _batchRequestedJurors,
        uint256 _roundRequestedJurors
    )
        internal
        view
        returns (uint256 low, uint256 high)
    {

        uint256 totalActiveBalance = tree.getRecentTotalAt(_termId);
        low = _selectedJurors.mul(totalActiveBalance).div(_roundRequestedJurors);

        uint256 newSelectedJurors = _selectedJurors.add(_batchRequestedJurors);
        high = newSelectedJurors.mul(totalActiveBalance).div(_roundRequestedJurors);
    }

    function _computeSearchRandomBalances(
        bytes32 _termRandomness,
        uint256 _disputeId,
        uint256 _sortitionIteration,
        uint256 _batchRequestedJurors,
        uint256 _lowBatchBound,
        uint256 _highBatchBound
    )
        internal
        pure
        returns (uint256[] memory)
    {

        require(_highBatchBound > _lowBatchBound, ERROR_INVALID_INTERVAL_SEARCH);
        uint256 interval = _highBatchBound - _lowBatchBound;

        uint256[] memory balances = new uint256[](_batchRequestedJurors);
        for (uint256 batchJurorNumber = 0; batchJurorNumber < _batchRequestedJurors; batchJurorNumber++) {
            bytes32 seed = keccak256(abi.encodePacked(_termRandomness, _disputeId, _sortitionIteration, batchJurorNumber));

            balances[batchJurorNumber] = _lowBatchBound.add(uint256(seed) % interval);

            for (uint256 i = batchJurorNumber; i > 0 && balances[i] < balances[i - 1]; i--) {
                uint256 tmp = balances[i - 1];
                balances[i - 1] = balances[i];
                balances[i] = tmp;
            }
        }
        return balances;
    }
}


pragma solidity ^0.5.8;


interface ERC900 {

    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    function stake(uint256 _amount, bytes calldata _data) external;


    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external;


    function unstake(uint256 _amount, bytes calldata _data) external;


    function totalStakedFor(address _addr) external view returns (uint256);


    function totalStaked() external view returns (uint256);


    function token() external view returns (address);


    function supportsHistory() external pure returns (bool);

}


pragma solidity ^0.5.8;


interface ApproveAndCallFallBack {

    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external;

}



pragma solidity ^0.5.8;


contract IsContract {

    function isContract(address _target) internal view returns (bool) {

        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}



pragma solidity ^0.5.8;


library SafeMath64 {

    string private constant ERROR_ADD_OVERFLOW = "MATH64_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH64_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH64_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH64_DIV_ZERO";

    function mul(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint256 c = uint256(_a) * uint256(_b);
        require(c < 0x010000000000000000, ERROR_MUL_OVERFLOW); // 2**64 (less gas this way)

        return uint64(c);
    }

    function div(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint64 c = _a / _b;

        return c;
    }

    function sub(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint64 c = _a - _b;

        return c;
    }

    function add(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint64 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}



pragma solidity ^0.5.8;


library Uint256Helpers {

    uint256 private constant MAX_UINT8 = uint8(-1);
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_UINT8_NUMBER_TOO_BIG = "UINT8_NUMBER_TOO_BIG";
    string private constant ERROR_UINT64_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint8(uint256 a) internal pure returns (uint8) {

        require(a <= MAX_UINT8, ERROR_UINT8_NUMBER_TOO_BIG);
        return uint8(a);
    }

    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_UINT64_NUMBER_TOO_BIG);
        return uint64(a);
    }
}



pragma solidity ^0.5.8;



contract TimeHelpers {

    using Uint256Helpers for uint256;

    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }

    function getBlockNumber64() internal view returns (uint64) {

        return getBlockNumber().toUint64();
    }

    function getTimestamp() internal view returns (uint256) {

        return block.timestamp; // solium-disable-line security/no-block-members
    }

    function getTimestamp64() internal view returns (uint64) {

        return getTimestamp().toUint64();
    }
}


pragma solidity ^0.5.8;


interface IClock {

    function ensureCurrentTerm() external returns (uint64);


    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64);


    function ensureCurrentTermRandomness() external returns (bytes32);


    function getLastEnsuredTermId() external view returns (uint64);


    function getCurrentTermId() external view returns (uint64);


    function getNeededTermTransitions() external view returns (uint64);


    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness);


    function getTermRandomness(uint64 _termId) external view returns (bytes32);

}


pragma solidity ^0.5.8;





contract CourtClock is IClock, TimeHelpers {

    using SafeMath64 for uint64;

    string private constant ERROR_TERM_DOES_NOT_EXIST = "CLK_TERM_DOES_NOT_EXIST";
    string private constant ERROR_TERM_DURATION_TOO_LONG = "CLK_TERM_DURATION_TOO_LONG";
    string private constant ERROR_TERM_RANDOMNESS_NOT_YET = "CLK_TERM_RANDOMNESS_NOT_YET";
    string private constant ERROR_TERM_RANDOMNESS_UNAVAILABLE = "CLK_TERM_RANDOMNESS_UNAVAILABLE";
    string private constant ERROR_BAD_FIRST_TERM_START_TIME = "CLK_BAD_FIRST_TERM_START_TIME";
    string private constant ERROR_TOO_MANY_TRANSITIONS = "CLK_TOO_MANY_TRANSITIONS";
    string private constant ERROR_INVALID_TRANSITION_TERMS = "CLK_INVALID_TRANSITION_TERMS";
    string private constant ERROR_CANNOT_DELAY_STARTED_COURT = "CLK_CANNOT_DELAY_STARTED_COURT";
    string private constant ERROR_CANNOT_DELAY_PAST_START_TIME = "CLK_CANNOT_DELAY_PAST_START_TIME";

    uint64 internal constant MAX_AUTO_TERM_TRANSITIONS_ALLOWED = 1;

    uint64 internal constant MAX_TERM_DURATION = 365 days;

    uint64 internal constant MAX_FIRST_TERM_DELAY_PERIOD = 2 * MAX_TERM_DURATION;

    struct Term {
        uint64 startTime;              // Timestamp when the term started
        uint64 randomnessBN;           // Block number for entropy
        bytes32 randomness;            // Entropy from randomnessBN block hash
    }

    uint64 private termDuration;

    uint64 private termId;

    mapping (uint64 => Term) private terms;

    event Heartbeat(uint64 previousTermId, uint64 currentTermId);
    event StartTimeDelayed(uint64 previousStartTime, uint64 currentStartTime);

    modifier termExists(uint64 _termId) {

        require(_termId <= termId, ERROR_TERM_DOES_NOT_EXIST);
        _;
    }

    constructor(uint64[2] memory _termParams) public {
        uint64 _termDuration = _termParams[0];
        uint64 _firstTermStartTime = _termParams[1];

        require(_termDuration < MAX_TERM_DURATION, ERROR_TERM_DURATION_TOO_LONG);
        require(_firstTermStartTime >= getTimestamp64() + _termDuration, ERROR_BAD_FIRST_TERM_START_TIME);
        require(_firstTermStartTime <= getTimestamp64() + MAX_FIRST_TERM_DELAY_PERIOD, ERROR_BAD_FIRST_TERM_START_TIME);

        termDuration = _termDuration;

        terms[0].startTime = _firstTermStartTime - _termDuration;
    }

    function ensureCurrentTerm() external returns (uint64) {

        return _ensureCurrentTerm();
    }

    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64) {

        return _heartbeat(_maxRequestedTransitions);
    }

    function ensureCurrentTermRandomness() external returns (bytes32) {

        uint64 currentTermId = termId;
        Term storage term = terms[currentTermId];
        bytes32 termRandomness = term.randomness;
        if (termRandomness != bytes32(0)) {
            return termRandomness;
        }

        bytes32 newRandomness = _computeTermRandomness(currentTermId);
        require(newRandomness != bytes32(0), ERROR_TERM_RANDOMNESS_UNAVAILABLE);
        term.randomness = newRandomness;
        return newRandomness;
    }

    function getTermDuration() external view returns (uint64) {

        return termDuration;
    }

    function getLastEnsuredTermId() external view returns (uint64) {

        return _lastEnsuredTermId();
    }

    function getCurrentTermId() external view returns (uint64) {

        return _currentTermId();
    }

    function getNeededTermTransitions() external view returns (uint64) {

        return _neededTermTransitions();
    }

    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness) {

        Term storage term = terms[_termId];
        return (term.startTime, term.randomnessBN, term.randomness);
    }

    function getTermRandomness(uint64 _termId) external view termExists(_termId) returns (bytes32) {

        return _computeTermRandomness(_termId);
    }

    function _ensureCurrentTerm() internal returns (uint64) {

        uint64 requiredTransitions = _neededTermTransitions();
        require(requiredTransitions <= MAX_AUTO_TERM_TRANSITIONS_ALLOWED, ERROR_TOO_MANY_TRANSITIONS);

        if (uint256(requiredTransitions) == 0) {
            return termId;
        }

        return _heartbeat(requiredTransitions);
    }

    function _heartbeat(uint64 _maxRequestedTransitions) internal returns (uint64) {

        uint64 neededTransitions = _neededTermTransitions();
        uint256 transitions = uint256(_maxRequestedTransitions < neededTransitions ? _maxRequestedTransitions : neededTransitions);
        require(transitions > 0, ERROR_INVALID_TRANSITION_TERMS);

        uint64 blockNumber = getBlockNumber64();
        uint64 previousTermId = termId;
        uint64 currentTermId = previousTermId;
        for (uint256 transition = 1; transition <= transitions; transition++) {
            Term storage previousTerm = terms[currentTermId++];
            Term storage currentTerm = terms[currentTermId];
            _onTermTransitioned(currentTermId);

            currentTerm.startTime = previousTerm.startTime.add(termDuration);

            currentTerm.randomnessBN = blockNumber + 1;
        }

        termId = currentTermId;
        emit Heartbeat(previousTermId, currentTermId);
        return currentTermId;
    }

    function _delayStartTime(uint64 _newFirstTermStartTime) internal {

        require(_currentTermId() == 0, ERROR_CANNOT_DELAY_STARTED_COURT);

        Term storage term = terms[0];
        uint64 currentFirstTermStartTime = term.startTime.add(termDuration);
        require(_newFirstTermStartTime > currentFirstTermStartTime, ERROR_CANNOT_DELAY_PAST_START_TIME);

        term.startTime = _newFirstTermStartTime - termDuration;
        emit StartTimeDelayed(currentFirstTermStartTime, _newFirstTermStartTime);
    }

    function _onTermTransitioned(uint64 _termId) internal;


    function _lastEnsuredTermId() internal view returns (uint64) {

        return termId;
    }

    function _currentTermId() internal view returns (uint64) {

        return termId.add(_neededTermTransitions());
    }

    function _neededTermTransitions() internal view returns (uint64) {

        uint64 currentTermStartTime = terms[termId].startTime;
        if (getTimestamp64() < currentTermStartTime) {
            return uint64(0);
        }

        return (getTimestamp64() - currentTermStartTime) / termDuration;
    }

    function _computeTermRandomness(uint64 _termId) internal view returns (bytes32) {

        Term storage term = terms[_termId];
        require(getBlockNumber64() > term.randomnessBN, ERROR_TERM_RANDOMNESS_NOT_YET);
        return blockhash(term.randomnessBN);
    }
}


pragma solidity ^0.5.8;



interface IConfig {


    function getConfig(uint64 _termId) external view
        returns (
            ERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        );


    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct);


    function getMinActiveBalance(uint64 _termId) external view returns (uint256);


    function areWithdrawalsAllowedFor(address _holder) external view returns (bool);

}


pragma solidity ^0.5.8;



contract CourtConfigData {

    struct Config {
        FeesConfig fees;                        // Full fees-related config
        DisputesConfig disputes;                // Full disputes-related config
        uint256 minActiveBalance;               // Minimum amount of tokens jurors have to activate to participate in the Court
    }

    struct FeesConfig {
        ERC20 token;                            // ERC20 token to be used for the fees of the Court
        uint16 finalRoundReduction;             // Permyriad of fees reduction applied for final appeal round (‱ - 1/10,000)
        uint256 jurorFee;                       // Amount of tokens paid to draft a juror to adjudicate a dispute
        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting jurors
        uint256 settleFee;                      // Amount of tokens paid per round to cover the costs of slashing jurors
    }

    struct DisputesConfig {
        uint64 evidenceTerms;                   // Max submitting evidence period duration in terms
        uint64 commitTerms;                     // Committing period duration in terms
        uint64 revealTerms;                     // Revealing period duration in terms
        uint64 appealTerms;                     // Appealing period duration in terms
        uint64 appealConfirmTerms;              // Confirmation appeal period duration in terms
        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)
        uint64 firstRoundJurorsNumber;          // Number of jurors drafted on first round
        uint64 appealStepFactor;                // Factor in which the jurors number is increased on each appeal
        uint64 finalRoundLockTerms;             // Period a coherent juror in the final round will remain locked
        uint256 maxRegularAppealRounds;         // Before the final appeal
        uint256 appealCollateralFactor;         // Permyriad multiple of dispute fees required to appeal a preliminary ruling (‱ - 1/10,000)
        uint256 appealConfirmCollateralFactor;  // Permyriad multiple of dispute fees required to confirm appeal (‱ - 1/10,000)
    }

    struct DraftConfig {
        ERC20 feeToken;                         // ERC20 token to be used for the fees of the Court
        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)
        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting jurors
    }
}


pragma solidity ^0.5.8;







contract CourtConfig is IConfig, CourtConfigData {

    using SafeMath64 for uint64;
    using PctHelpers for uint256;

    string private constant ERROR_TOO_OLD_TERM = "CONF_TOO_OLD_TERM";
    string private constant ERROR_INVALID_PENALTY_PCT = "CONF_INVALID_PENALTY_PCT";
    string private constant ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT = "CONF_INVALID_FINAL_ROUND_RED_PCT";
    string private constant ERROR_INVALID_MAX_APPEAL_ROUNDS = "CONF_INVALID_MAX_APPEAL_ROUNDS";
    string private constant ERROR_LARGE_ROUND_PHASE_DURATION = "CONF_LARGE_ROUND_PHASE_DURATION";
    string private constant ERROR_BAD_INITIAL_JURORS_NUMBER = "CONF_BAD_INITIAL_JURORS_NUMBER";
    string private constant ERROR_BAD_APPEAL_STEP_FACTOR = "CONF_BAD_APPEAL_STEP_FACTOR";
    string private constant ERROR_ZERO_COLLATERAL_FACTOR = "CONF_ZERO_COLLATERAL_FACTOR";
    string private constant ERROR_ZERO_MIN_ACTIVE_BALANCE = "CONF_ZERO_MIN_ACTIVE_BALANCE";

    uint64 internal constant MAX_ADJ_STATE_DURATION = 8670;

    uint256 internal constant MAX_REGULAR_APPEAL_ROUNDS_LIMIT = 10;

    uint64 private configChangeTermId;

    Config[] private configs;

    mapping (uint64 => uint256) private configIdByTerm;

    mapping (address => bool) private withdrawalsAllowed;

    event NewConfig(uint64 fromTermId, uint64 courtConfigId);
    event AutomaticWithdrawalsAllowedChanged(address indexed holder, bool allowed);

    constructor(
        ERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
    {
        configs.length = 1;
        _setConfig(
            0,
            0,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        );
    }

    function setAutomaticWithdrawals(bool _allowed) external {

        withdrawalsAllowed[msg.sender] = _allowed;
        emit AutomaticWithdrawalsAllowedChanged(msg.sender, _allowed);
    }

    function getConfig(uint64 _termId) external view
        returns (
            ERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        );


    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct);


    function getMinActiveBalance(uint64 _termId) external view returns (uint256);


    function areWithdrawalsAllowedFor(address _holder) external view returns (bool) {

        return withdrawalsAllowed[_holder];
    }

    function getConfigChangeTermId() external view returns (uint64) {

        return configChangeTermId;
    }

    function _ensureTermConfig(uint64 _termId) internal {

        uint256 currentConfigId = configIdByTerm[_termId];
        if (currentConfigId == 0) {
            uint256 previousConfigId = configIdByTerm[_termId.sub(1)];
            configIdByTerm[_termId] = previousConfigId;
        }
    }

    function _setConfig(
        uint64 _termId,
        uint64 _fromTermId,
        ERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        internal
    {

        require(_termId == 0 || _fromTermId > _termId, ERROR_TOO_OLD_TERM);

        require(_appealCollateralParams[0] > 0 && _appealCollateralParams[1] > 0, ERROR_ZERO_COLLATERAL_FACTOR);

        require(PctHelpers.isValid(_pcts[0]), ERROR_INVALID_PENALTY_PCT);
        require(PctHelpers.isValid(_pcts[1]), ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT);

        require(_roundParams[0] > 0, ERROR_BAD_INITIAL_JURORS_NUMBER);

        require(_roundParams[1] > 0, ERROR_BAD_APPEAL_STEP_FACTOR);

        uint256 _maxRegularAppealRounds = _roundParams[2];
        bool isMaxAppealRoundsValid = _maxRegularAppealRounds > 0 && _maxRegularAppealRounds <= MAX_REGULAR_APPEAL_ROUNDS_LIMIT;
        require(isMaxAppealRoundsValid, ERROR_INVALID_MAX_APPEAL_ROUNDS);

        for (uint i = 0; i < _roundStateDurations.length; i++) {
            require(_roundStateDurations[i] > 0 && _roundStateDurations[i] < MAX_ADJ_STATE_DURATION, ERROR_LARGE_ROUND_PHASE_DURATION);
        }

        require(_minActiveBalance > 0, ERROR_ZERO_MIN_ACTIVE_BALANCE);

        if (configChangeTermId > _termId) {
            configIdByTerm[configChangeTermId] = 0;
        } else {
            configs.length++;
        }

        uint64 courtConfigId = uint64(configs.length - 1);
        Config storage config = configs[courtConfigId];

        config.fees = FeesConfig({
            token: _feeToken,
            jurorFee: _fees[0],
            draftFee: _fees[1],
            settleFee: _fees[2],
            finalRoundReduction: _pcts[1]
        });

        config.disputes = DisputesConfig({
            evidenceTerms: _roundStateDurations[0],
            commitTerms: _roundStateDurations[1],
            revealTerms: _roundStateDurations[2],
            appealTerms: _roundStateDurations[3],
            appealConfirmTerms: _roundStateDurations[4],
            penaltyPct: _pcts[0],
            firstRoundJurorsNumber: _roundParams[0],
            appealStepFactor: _roundParams[1],
            maxRegularAppealRounds: _maxRegularAppealRounds,
            finalRoundLockTerms: _roundParams[3],
            appealCollateralFactor: _appealCollateralParams[0],
            appealConfirmCollateralFactor: _appealCollateralParams[1]
        });

        config.minActiveBalance = _minActiveBalance;

        configIdByTerm[_fromTermId] = courtConfigId;
        configChangeTermId = _fromTermId;

        emit NewConfig(_fromTermId, courtConfigId);
    }

    function _getConfigAt(uint64 _termId, uint64 _lastEnsuredTermId) internal view
        returns (
            ERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        )
    {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);

        FeesConfig storage feesConfig = config.fees;
        feeToken = feesConfig.token;
        fees = [feesConfig.jurorFee, feesConfig.draftFee, feesConfig.settleFee];

        DisputesConfig storage disputesConfig = config.disputes;
        roundStateDurations = [
            disputesConfig.evidenceTerms,
            disputesConfig.commitTerms,
            disputesConfig.revealTerms,
            disputesConfig.appealTerms,
            disputesConfig.appealConfirmTerms
        ];
        pcts = [disputesConfig.penaltyPct, feesConfig.finalRoundReduction];
        roundParams = [
            disputesConfig.firstRoundJurorsNumber,
            disputesConfig.appealStepFactor,
            uint64(disputesConfig.maxRegularAppealRounds),
            disputesConfig.finalRoundLockTerms
        ];
        appealCollateralParams = [disputesConfig.appealCollateralFactor, disputesConfig.appealConfirmCollateralFactor];

        minActiveBalance = config.minActiveBalance;
    }

    function _getDraftConfig(uint64 _termId,  uint64 _lastEnsuredTermId) internal view
        returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct)
    {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);
        return (config.fees.token, config.fees.draftFee, config.disputes.penaltyPct);
    }

    function _getMinActiveBalance(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);
        return config.minActiveBalance;
    }

    function _getConfigFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (Config storage) {

        uint256 id = _getConfigIdFor(_termId, _lastEnsuredTermId);
        return configs[id];
    }

    function _getConfigIdFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {

        if (_termId <= _lastEnsuredTermId) {
            return configIdByTerm[_termId];
        }

        uint64 scheduledChangeTermId = configChangeTermId;
        if (scheduledChangeTermId <= _termId) {
            return configIdByTerm[scheduledChangeTermId];
        }

        return configIdByTerm[_lastEnsuredTermId];
    }
}


pragma solidity ^0.5.8;





contract Controller is IsContract, CourtClock, CourtConfig {

    string private constant ERROR_SENDER_NOT_GOVERNOR = "CTR_SENDER_NOT_GOVERNOR";
    string private constant ERROR_INVALID_GOVERNOR_ADDRESS = "CTR_INVALID_GOVERNOR_ADDRESS";
    string private constant ERROR_IMPLEMENTATION_NOT_CONTRACT = "CTR_IMPLEMENTATION_NOT_CONTRACT";
    string private constant ERROR_INVALID_IMPLS_INPUT_LENGTH = "CTR_INVALID_IMPLS_INPUT_LENGTH";

    address private constant ZERO_ADDRESS = address(0);

    bytes32 internal constant DISPUTE_MANAGER = 0x14a6c70f0f6d449c014c7bbc9e68e31e79e8474fb03b7194df83109a2d888ae6;

    bytes32 internal constant TREASURY = 0x06aa03964db1f7257357ef09714a5f0ca3633723df419e97015e0c7a3e83edb7;

    bytes32 internal constant VOTING = 0x7cbb12e82a6d63ff16fe43977f43e3e2b247ecd4e62c0e340da8800a48c67346;

    bytes32 internal constant JURORS_REGISTRY = 0x3b21d36b36308c830e6c4053fb40a3b6d79dde78947fbf6b0accd30720ab5370;

    bytes32 internal constant SUBSCRIPTIONS = 0x2bfa3327fe52344390da94c32a346eeb1b65a8b583e4335a419b9471e88c1365;

    struct Governor {
        address funds;      // This address can be unset at any time. It is allowed to recover funds from the ControlledRecoverable modules
        address config;     // This address is meant not to be unset. It is allowed to change the different configurations of the whole system
        address modules;    // This address can be unset at any time. It is allowed to plug/unplug modules from the system
    }

    Governor private governor;

    mapping (bytes32 => address) internal modules;

    event ModuleSet(bytes32 id, address addr);
    event FundsGovernorChanged(address previousGovernor, address currentGovernor);
    event ConfigGovernorChanged(address previousGovernor, address currentGovernor);
    event ModulesGovernorChanged(address previousGovernor, address currentGovernor);

    modifier onlyFundsGovernor {

        require(msg.sender == governor.funds, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    modifier onlyConfigGovernor {

        require(msg.sender == governor.config, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    modifier onlyModulesGovernor {

        require(msg.sender == governor.modules, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    constructor(
        uint64[2] memory _termParams,
        address[3] memory _governors,
        ERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
        CourtClock(_termParams)
        CourtConfig(_feeToken, _fees, _roundStateDurations, _pcts, _roundParams, _appealCollateralParams, _minActiveBalance)
    {
        _setFundsGovernor(_governors[0]);
        _setConfigGovernor(_governors[1]);
        _setModulesGovernor(_governors[2]);
    }

    function setConfig(
        uint64 _fromTermId,
        ERC20 _feeToken,
        uint256[3] calldata _fees,
        uint64[5] calldata _roundStateDurations,
        uint16[2] calldata _pcts,
        uint64[4] calldata _roundParams,
        uint256[2] calldata _appealCollateralParams,
        uint256 _minActiveBalance
    )
        external
        onlyConfigGovernor
    {

        uint64 currentTermId = _ensureCurrentTerm();
        _setConfig(
            currentTermId,
            _fromTermId,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        );
    }

    function delayStartTime(uint64 _newFirstTermStartTime) external onlyConfigGovernor {

        _delayStartTime(_newFirstTermStartTime);
    }

    function changeFundsGovernor(address _newFundsGovernor) external onlyFundsGovernor {

        require(_newFundsGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setFundsGovernor(_newFundsGovernor);
    }

    function changeConfigGovernor(address _newConfigGovernor) external onlyConfigGovernor {

        require(_newConfigGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setConfigGovernor(_newConfigGovernor);
    }

    function changeModulesGovernor(address _newModulesGovernor) external onlyModulesGovernor {

        require(_newModulesGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setModulesGovernor(_newModulesGovernor);
    }

    function ejectFundsGovernor() external onlyFundsGovernor {

        _setFundsGovernor(ZERO_ADDRESS);
    }

    function ejectModulesGovernor() external onlyModulesGovernor {

        _setModulesGovernor(ZERO_ADDRESS);
    }

    function setModule(bytes32 _id, address _addr) external onlyModulesGovernor {

        _setModule(_id, _addr);
    }

    function setModules(bytes32[] calldata _ids, address[] calldata _addresses) external onlyModulesGovernor {

        require(_ids.length == _addresses.length, ERROR_INVALID_IMPLS_INPUT_LENGTH);

        for (uint256 i = 0; i < _ids.length; i++) {
            _setModule(_ids[i], _addresses[i]);
        }
    }

    function getConfig(uint64 _termId) external view
        returns (
            ERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        )
    {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getConfigAt(_termId, lastEnsuredTermId);
    }

    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct) {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getDraftConfig(_termId, lastEnsuredTermId);
    }

    function getMinActiveBalance(uint64 _termId) external view returns (uint256) {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getMinActiveBalance(_termId, lastEnsuredTermId);
    }

    function getFundsGovernor() external view returns (address) {

        return governor.funds;
    }

    function getConfigGovernor() external view returns (address) {

        return governor.config;
    }

    function getModulesGovernor() external view returns (address) {

        return governor.modules;
    }

    function getModule(bytes32 _id) external view returns (address) {

        return _getModule(_id);
    }

    function getDisputeManager() external view returns (address) {

        return _getDisputeManager();
    }

    function getTreasury() external view returns (address) {

        return _getModule(TREASURY);
    }

    function getVoting() external view returns (address) {

        return _getModule(VOTING);
    }

    function getJurorsRegistry() external view returns (address) {

        return _getModule(JURORS_REGISTRY);
    }

    function getSubscriptions() external view returns (address) {

        return _getSubscriptions();
    }

    function _setFundsGovernor(address _newFundsGovernor) internal {

        emit FundsGovernorChanged(governor.funds, _newFundsGovernor);
        governor.funds = _newFundsGovernor;
    }

    function _setConfigGovernor(address _newConfigGovernor) internal {

        emit ConfigGovernorChanged(governor.config, _newConfigGovernor);
        governor.config = _newConfigGovernor;
    }

    function _setModulesGovernor(address _newModulesGovernor) internal {

        emit ModulesGovernorChanged(governor.modules, _newModulesGovernor);
        governor.modules = _newModulesGovernor;
    }

    function _setModule(bytes32 _id, address _addr) internal {

        require(isContract(_addr), ERROR_IMPLEMENTATION_NOT_CONTRACT);
        modules[_id] = _addr;
        emit ModuleSet(_id, _addr);
    }

    function _onTermTransitioned(uint64 _termId) internal {

        _ensureTermConfig(_termId);
    }

    function _getDisputeManager() internal view returns (address) {

        return _getModule(DISPUTE_MANAGER);
    }

    function _getSubscriptions() internal view returns (address) {

        return _getModule(SUBSCRIPTIONS);
    }

    function _getModule(bytes32 _id) internal view returns (address) {

        return modules[_id];
    }
}


pragma solidity ^0.5.8;





contract ConfigConsumer is CourtConfigData {

    function _courtConfig() internal view returns (IConfig);


    function _getConfigAt(uint64 _termId) internal view returns (Config memory) {

        (ERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance) = _courtConfig().getConfig(_termId);

        Config memory config;

        config.fees = FeesConfig({
            token: _feeToken,
            jurorFee: _fees[0],
            draftFee: _fees[1],
            settleFee: _fees[2],
            finalRoundReduction: _pcts[1]
        });

        config.disputes = DisputesConfig({
            evidenceTerms: _roundStateDurations[0],
            commitTerms: _roundStateDurations[1],
            revealTerms: _roundStateDurations[2],
            appealTerms: _roundStateDurations[3],
            appealConfirmTerms: _roundStateDurations[4],
            penaltyPct: _pcts[0],
            firstRoundJurorsNumber: _roundParams[0],
            appealStepFactor: _roundParams[1],
            maxRegularAppealRounds: _roundParams[2],
            finalRoundLockTerms: _roundParams[3],
            appealCollateralFactor: _appealCollateralParams[0],
            appealConfirmCollateralFactor: _appealCollateralParams[1]
        });

        config.minActiveBalance = _minActiveBalance;

        return config;
    }

    function _getDraftConfig(uint64 _termId) internal view returns (DraftConfig memory) {

        (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct) = _courtConfig().getDraftConfig(_termId);
        return DraftConfig({ feeToken: feeToken, draftFee: draftFee, penaltyPct: penaltyPct });
    }

    function _getMinActiveBalance(uint64 _termId) internal view returns (uint256) {

        return _courtConfig().getMinActiveBalance(_termId);
    }
}


pragma solidity ^0.5.8;


interface ICRVotingOwner {

    function ensureCanCommit(uint256 _voteId) external;


    function ensureCanCommit(uint256 _voteId, address _voter) external;


    function ensureCanReveal(uint256 _voteId, address _voter) external returns (uint64);

}


pragma solidity ^0.5.8;



interface ICRVoting {

    function create(uint256 _voteId, uint8 _possibleOutcomes) external;


    function getWinningOutcome(uint256 _voteId) external view returns (uint8);


    function getOutcomeTally(uint256 _voteId, uint8 _outcome) external view returns (uint256);


    function isValidOutcome(uint256 _voteId, uint8 _outcome) external view returns (bool);


    function getVoterOutcome(uint256 _voteId, address _voter) external view returns (uint8);


    function hasVotedInFavorOf(uint256 _voteId, uint8 _outcome, address _voter) external view returns (bool);


    function getVotersInFavorOf(uint256 _voteId, uint8 _outcome, address[] calldata _voters) external view returns (bool[] memory);

}


pragma solidity ^0.5.8;



interface ITreasury {

    function assign(ERC20 _token, address _to, uint256 _amount) external;


    function withdraw(ERC20 _token, address _to, uint256 _amount) external;

}


pragma solidity ^0.5.8;



interface IArbitrator {

    function createDispute(uint256 _possibleRulings, bytes calldata _metadata) external returns (uint256);


    function closeEvidencePeriod(uint256 _disputeId) external;


    function executeRuling(uint256 _disputeId) external;


    function getDisputeFees() external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);


    function getSubscriptionFees(address _subscriber) external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);

}


pragma solidity ^0.5.8;


interface ERC165 {

    function supportsInterface(bytes4 _interfaceId) external pure returns (bool);

}


pragma solidity ^0.5.8;




contract IArbitrable is ERC165 {

    bytes4 internal constant ERC165_INTERFACE_ID = bytes4(0x01ffc9a7);
    bytes4 internal constant ARBITRABLE_INTERFACE_ID = bytes4(0x88f3ee69);

    event Ruled(IArbitrator indexed arbitrator, uint256 indexed disputeId, uint256 ruling);

    event EvidenceSubmitted(uint256 indexed disputeId, address indexed submitter, bytes evidence, bool finished);

    function submitEvidence(uint256 _disputeId, bytes calldata _evidence, bool _finished) external;


    function rule(uint256 _disputeId, uint256 _ruling) external;


    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {

        return _interfaceId == ARBITRABLE_INTERFACE_ID || _interfaceId == ERC165_INTERFACE_ID;
    }
}


pragma solidity ^0.5.8;




interface IDisputeManager {

    enum DisputeState {
        PreDraft,
        Adjudicating,
        Ruled
    }

    enum AdjudicationState {
        Invalid,
        Committing,
        Revealing,
        Appealing,
        ConfirmingAppeal,
        Ended
    }

    function createDispute(IArbitrable _subject, uint8 _possibleRulings, bytes calldata _metadata) external returns (uint256);


    function closeEvidencePeriod(IArbitrable _subject, uint256 _disputeId) external;


    function draft(uint256 _disputeId) external;


    function createAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external;


    function confirmAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external;


    function computeRuling(uint256 _disputeId) external returns (IArbitrable subject, uint8 finalRuling);


    function settlePenalties(uint256 _disputeId, uint256 _roundId, uint256 _jurorsToSettle) external;


    function settleReward(uint256 _disputeId, uint256 _roundId, address _juror) external;


    function settleAppealDeposit(uint256 _disputeId, uint256 _roundId) external;


    function getDisputeFees() external view returns (ERC20 feeToken, uint256 feeAmount);


    function getDispute(uint256 _disputeId) external view
        returns (IArbitrable subject, uint8 possibleRulings, DisputeState state, uint8 finalRuling, uint256 lastRoundId, uint64 createTermId);


    function getRound(uint256 _disputeId, uint256 _roundId) external view
        returns (
            uint64 draftTerm,
            uint64 delayedTerms,
            uint64 jurorsNumber,
            uint64 selectedJurors,
            uint256 jurorFees,
            bool settledPenalties,
            uint256 collectedTokens,
            uint64 coherentJurors,
            AdjudicationState state
        );


    function getAppeal(uint256 _disputeId, uint256 _roundId) external view
        returns (address maker, uint64 appealedRuling, address taker, uint64 opposedRuling);


    function getNextRoundDetails(uint256 _disputeId, uint256 _roundId) external view
        returns (
            uint64 nextRoundStartTerm,
            uint64 nextRoundJurorsNumber,
            DisputeState newDisputeState,
            ERC20 feeToken,
            uint256 totalFees,
            uint256 jurorFees,
            uint256 appealDeposit,
            uint256 confirmAppealDeposit
        );


    function getJuror(uint256 _disputeId, uint256 _roundId, address _juror) external view returns (uint64 weight, bool rewarded);

}


pragma solidity ^0.5.8;



interface ISubscriptions {

    function isUpToDate(address _subscriber) external view returns (bool);


    function getOwedFeesDetails(address _subscriber) external view returns (ERC20, uint256, uint256);

}


pragma solidity ^0.5.8;











contract Controlled is IsContract, ConfigConsumer {

    string private constant ERROR_CONTROLLER_NOT_CONTRACT = "CTD_CONTROLLER_NOT_CONTRACT";
    string private constant ERROR_SENDER_NOT_CONTROLLER = "CTD_SENDER_NOT_CONTROLLER";
    string private constant ERROR_SENDER_NOT_CONFIG_GOVERNOR = "CTD_SENDER_NOT_CONFIG_GOVERNOR";
    string private constant ERROR_SENDER_NOT_DISPUTES_MODULE = "CTD_SENDER_NOT_DISPUTES_MODULE";

    Controller internal controller;

    modifier onlyConfigGovernor {

        require(msg.sender == _configGovernor(), ERROR_SENDER_NOT_CONFIG_GOVERNOR);
        _;
    }

    modifier onlyController() {

        require(msg.sender == address(controller), ERROR_SENDER_NOT_CONTROLLER);
        _;
    }

    modifier onlyDisputeManager() {

        require(msg.sender == address(_disputeManager()), ERROR_SENDER_NOT_DISPUTES_MODULE);
        _;
    }

    constructor(Controller _controller) public {
        require(isContract(address(_controller)), ERROR_CONTROLLER_NOT_CONTRACT);
        controller = _controller;
    }

    function getController() external view returns (Controller) {

        return controller;
    }

    function _ensureCurrentTerm() internal returns (uint64) {

        return _clock().ensureCurrentTerm();
    }

    function _getLastEnsuredTermId() internal view returns (uint64) {

        return _clock().getLastEnsuredTermId();
    }

    function _getCurrentTermId() internal view returns (uint64) {

        return _clock().getCurrentTermId();
    }

    function _configGovernor() internal view returns (address) {

        return controller.getConfigGovernor();
    }

    function _disputeManager() internal view returns (IDisputeManager) {

        return IDisputeManager(controller.getDisputeManager());
    }

    function _treasury() internal view returns (ITreasury) {

        return ITreasury(controller.getTreasury());
    }

    function _voting() internal view returns (ICRVoting) {

        return ICRVoting(controller.getVoting());
    }

    function _votingOwner() internal view returns (ICRVotingOwner) {

        return ICRVotingOwner(address(_disputeManager()));
    }

    function _jurorsRegistry() internal view returns (IJurorsRegistry) {

        return IJurorsRegistry(controller.getJurorsRegistry());
    }

    function _subscriptions() internal view returns (ISubscriptions) {

        return ISubscriptions(controller.getSubscriptions());
    }

    function _clock() internal view returns (IClock) {

        return IClock(controller);
    }

    function _courtConfig() internal view returns (IConfig) {

        return IConfig(controller);
    }
}


pragma solidity ^0.5.8;





contract ControlledRecoverable is Controlled {

    using SafeERC20 for ERC20;

    string private constant ERROR_SENDER_NOT_FUNDS_GOVERNOR = "CTD_SENDER_NOT_FUNDS_GOVERNOR";
    string private constant ERROR_INSUFFICIENT_RECOVER_FUNDS = "CTD_INSUFFICIENT_RECOVER_FUNDS";
    string private constant ERROR_RECOVER_TOKEN_FUNDS_FAILED = "CTD_RECOVER_TOKEN_FUNDS_FAILED";

    event RecoverFunds(ERC20 token, address recipient, uint256 balance);

    modifier onlyFundsGovernor {

        require(msg.sender == controller.getFundsGovernor(), ERROR_SENDER_NOT_FUNDS_GOVERNOR);
        _;
    }

    constructor(Controller _controller) Controlled(_controller) public {
    }

    function recoverFunds(ERC20 _token, address _to) external onlyFundsGovernor {

        uint256 balance = _token.balanceOf(address(this));
        require(balance > 0, ERROR_INSUFFICIENT_RECOVER_FUNDS);
        require(_token.safeTransfer(_to, balance), ERROR_RECOVER_TOKEN_FUNDS_FAILED);
        emit RecoverFunds(_token, _to, balance);
    }
}


pragma solidity ^0.5.8;














contract JurorsRegistry is ControlledRecoverable, IJurorsRegistry, ERC900, ApproveAndCallFallBack {

    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using PctHelpers for uint256;
    using BytesHelpers for bytes;
    using HexSumTree for HexSumTree.Tree;
    using JurorsTreeSortition for HexSumTree.Tree;

    string private constant ERROR_NOT_CONTRACT = "JR_NOT_CONTRACT";
    string private constant ERROR_INVALID_ZERO_AMOUNT = "JR_INVALID_ZERO_AMOUNT";
    string private constant ERROR_INVALID_ACTIVATION_AMOUNT = "JR_INVALID_ACTIVATION_AMOUNT";
    string private constant ERROR_INVALID_DEACTIVATION_AMOUNT = "JR_INVALID_DEACTIVATION_AMOUNT";
    string private constant ERROR_INVALID_LOCKED_AMOUNTS_LENGTH = "JR_INVALID_LOCKED_AMOUNTS_LEN";
    string private constant ERROR_INVALID_REWARDED_JURORS_LENGTH = "JR_INVALID_REWARDED_JURORS_LEN";
    string private constant ERROR_ACTIVE_BALANCE_BELOW_MIN = "JR_ACTIVE_BALANCE_BELOW_MIN";
    string private constant ERROR_NOT_ENOUGH_AVAILABLE_BALANCE = "JR_NOT_ENOUGH_AVAILABLE_BALANCE";
    string private constant ERROR_CANNOT_REDUCE_DEACTIVATION_REQUEST = "JR_CANT_REDUCE_DEACTIVATION_REQ";
    string private constant ERROR_TOKEN_TRANSFER_FAILED = "JR_TOKEN_TRANSFER_FAILED";
    string private constant ERROR_TOKEN_APPROVE_NOT_ALLOWED = "JR_TOKEN_APPROVE_NOT_ALLOWED";
    string private constant ERROR_BAD_TOTAL_ACTIVE_BALANCE_LIMIT = "JR_BAD_TOTAL_ACTIVE_BAL_LIMIT";
    string private constant ERROR_TOTAL_ACTIVE_BALANCE_EXCEEDED = "JR_TOTAL_ACTIVE_BALANCE_EXCEEDED";
    string private constant ERROR_WITHDRAWALS_LOCK = "JR_WITHDRAWALS_LOCK";

    address internal constant BURN_ACCOUNT = address(0x000000000000000000000000000000000000dEaD);

    uint256 internal constant MAX_DRAFT_ITERATIONS = 10;

    struct Juror {
        uint256 id;                                 // Key in the jurors tree used for drafting
        uint256 lockedBalance;                      // Maximum amount of tokens that can be slashed based on the juror's drafts
        uint256 availableBalance;                   // Available tokens that can be withdrawn at any time
        uint64 withdrawalsLockTermId;               // Term ID until which the juror's withdrawals will be locked
        DeactivationRequest deactivationRequest;    // Juror's pending deactivation request
    }

    struct DeactivationRequest {
        uint256 amount;                             // Amount requested for deactivation
        uint64 availableTermId;                     // Term ID when jurors can withdraw their requested deactivation tokens
    }

    struct DraftParams {
        bytes32 termRandomness;                     // Randomness seed to be used for the draft
        uint256 disputeId;                          // ID of the dispute being drafted
        uint64 termId;                              // Term ID of the dispute's draft term
        uint256 selectedJurors;                     // Number of jurors already selected for the draft
        uint256 batchRequestedJurors;               // Number of jurors to be selected in the given batch of the draft
        uint256 roundRequestedJurors;               // Total number of jurors requested to be drafted
        uint256 draftLockAmount;                    // Amount of tokens to be locked to each drafted juror
        uint256 iteration;                          // Sortition iteration number
    }

    uint256 internal totalActiveBalanceLimit;

    ERC20 internal jurorsToken;

    mapping (address => Juror) internal jurorsByAddress;

    mapping (uint256 => address) internal jurorsAddressById;

    HexSumTree.Tree internal tree;

    event JurorActivated(address indexed juror, uint64 fromTermId, uint256 amount, address sender);
    event JurorDeactivationRequested(address indexed juror, uint64 availableTermId, uint256 amount);
    event JurorDeactivationProcessed(address indexed juror, uint64 availableTermId, uint256 amount, uint64 processedTermId);
    event JurorDeactivationUpdated(address indexed juror, uint64 availableTermId, uint256 amount, uint64 updateTermId);
    event JurorBalanceLocked(address indexed juror, uint256 amount);
    event JurorBalanceUnlocked(address indexed juror, uint256 amount);
    event JurorSlashed(address indexed juror, uint256 amount, uint64 effectiveTermId);
    event JurorTokensAssigned(address indexed juror, uint256 amount);
    event JurorTokensBurned(uint256 amount);
    event JurorTokensCollected(address indexed juror, uint256 amount, uint64 effectiveTermId);
    event TotalActiveBalanceLimitChanged(uint256 previousTotalActiveBalanceLimit, uint256 currentTotalActiveBalanceLimit);

    constructor(Controller _controller, ERC20 _jurorToken, uint256 _totalActiveBalanceLimit)
        ControlledRecoverable(_controller)
        public
    {
        require(isContract(address(_jurorToken)), ERROR_NOT_CONTRACT);

        jurorsToken = _jurorToken;
        _setTotalActiveBalanceLimit(_totalActiveBalanceLimit);

        tree.init();
        assert(tree.insert(0, 0) == 0);
    }

    function activate(uint256 _amount) external {

        _activateTokens(msg.sender, _amount, msg.sender);
    }

    function deactivate(uint256 _amount) external {

        uint64 termId = _ensureCurrentTerm();
        Juror storage juror = jurorsByAddress[msg.sender];
        uint256 unlockedActiveBalance = _lastUnlockedActiveBalanceOf(juror);
        uint256 amountToDeactivate = _amount == 0 ? unlockedActiveBalance : _amount;
        require(amountToDeactivate > 0, ERROR_INVALID_ZERO_AMOUNT);
        require(amountToDeactivate <= unlockedActiveBalance, ERROR_INVALID_DEACTIVATION_AMOUNT);

        uint256 futureActiveBalance = unlockedActiveBalance - amountToDeactivate;
        uint256 minActiveBalance = _getMinActiveBalance(termId);
        require(futureActiveBalance == 0 || futureActiveBalance >= minActiveBalance, ERROR_INVALID_DEACTIVATION_AMOUNT);

        _createDeactivationRequest(msg.sender, amountToDeactivate);
    }

    function stake(uint256 _amount, bytes calldata _data) external {

        _stake(msg.sender, msg.sender, _amount, _data);
    }

    function stakeFor(address _to, uint256 _amount, bytes calldata _data) external {

        _stake(msg.sender, _to, _amount, _data);
    }

    function unstake(uint256 _amount, bytes calldata _data) external {

        _unstake(msg.sender, _amount, _data);
    }

    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external {

        require(msg.sender == _token && _token == address(jurorsToken), ERROR_TOKEN_APPROVE_NOT_ALLOWED);
        _stake(_from, _from, _amount, _data);
    }

    function processDeactivationRequest(address _juror) external {

        uint64 termId = _ensureCurrentTerm();
        _processDeactivationRequest(_juror, termId);
    }

    function assignTokens(address _juror, uint256 _amount) external onlyDisputeManager {

        if (_amount > 0) {
            _updateAvailableBalanceOf(_juror, _amount, true);
            emit JurorTokensAssigned(_juror, _amount);
        }
    }

    function burnTokens(uint256 _amount) external onlyDisputeManager {

        if (_amount > 0) {
            _updateAvailableBalanceOf(BURN_ACCOUNT, _amount, true);
            emit JurorTokensBurned(_amount);
        }
    }

    function draft(uint256[7] calldata _params) external onlyDisputeManager returns (address[] memory jurors, uint256 length) {

        DraftParams memory draftParams = _buildDraftParams(_params);
        jurors = new address[](draftParams.batchRequestedJurors);


        for (draftParams.iteration = 0;
             length < draftParams.batchRequestedJurors && draftParams.iteration < MAX_DRAFT_ITERATIONS;
             draftParams.iteration++
        ) {
            (uint256[] memory jurorIds, uint256[] memory activeBalances) = _treeSearch(draftParams);

            for (uint256 i = 0; i < jurorIds.length && length < draftParams.batchRequestedJurors; i++) {
                address jurorAddress = jurorsAddressById[jurorIds[i]];
                Juror storage juror = jurorsByAddress[jurorAddress];

                uint256 newLockedBalance = juror.lockedBalance.add(draftParams.draftLockAmount);

                uint256 nextTermDeactivationRequestAmount = _deactivationRequestedAmountForTerm(juror, draftParams.termId + 1);

                uint256 currentActiveBalance = activeBalances[i];
                if (currentActiveBalance >= newLockedBalance) {

                    uint256 nextTermActiveBalance = currentActiveBalance.sub(nextTermDeactivationRequestAmount);
                    if (nextTermActiveBalance < newLockedBalance) {
                        _reduceDeactivationRequest(jurorAddress, newLockedBalance - nextTermActiveBalance, draftParams.termId);
                    }

                    juror.lockedBalance = newLockedBalance;
                    jurors[length++] = jurorAddress;
                    emit JurorBalanceLocked(jurorAddress, draftParams.draftLockAmount);
                }
            }
        }
    }

    function slashOrUnlock(uint64 _termId, address[] calldata _jurors, uint256[] calldata _lockedAmounts, bool[] calldata _rewardedJurors)
        external
        onlyDisputeManager
        returns (uint256)
    {

        require(_jurors.length == _lockedAmounts.length, ERROR_INVALID_LOCKED_AMOUNTS_LENGTH);
        require(_jurors.length == _rewardedJurors.length, ERROR_INVALID_REWARDED_JURORS_LENGTH);

        uint64 nextTermId = _termId + 1;
        uint256 collectedTokens;

        for (uint256 i = 0; i < _jurors.length; i++) {
            uint256 lockedAmount = _lockedAmounts[i];
            address jurorAddress = _jurors[i];
            Juror storage juror = jurorsByAddress[jurorAddress];
            juror.lockedBalance = juror.lockedBalance.sub(lockedAmount);

            if (_rewardedJurors[i]) {
                emit JurorBalanceUnlocked(jurorAddress, lockedAmount);
            } else {
                collectedTokens = collectedTokens.add(lockedAmount);
                tree.update(juror.id, nextTermId, lockedAmount, false);
                emit JurorSlashed(jurorAddress, lockedAmount, nextTermId);
            }
        }

        return collectedTokens;
    }

    function collectTokens(address _juror, uint256 _amount, uint64 _termId) external onlyDisputeManager returns (bool) {

        if (_amount == 0) {
            return true;
        }

        uint64 nextTermId = _termId + 1;
        Juror storage juror = jurorsByAddress[_juror];
        uint256 unlockedActiveBalance = _lastUnlockedActiveBalanceOf(juror);
        uint256 nextTermDeactivationRequestAmount = _deactivationRequestedAmountForTerm(juror, nextTermId);

        uint256 totalUnlockedActiveBalance = unlockedActiveBalance.add(nextTermDeactivationRequestAmount);
        if (_amount > totalUnlockedActiveBalance) {
            return false;
        }

        if (_amount > unlockedActiveBalance) {
            uint256 amountToReduce = _amount - unlockedActiveBalance;
            _reduceDeactivationRequest(_juror, amountToReduce, _termId);
        }
        tree.update(juror.id, nextTermId, _amount, false);

        emit JurorTokensCollected(_juror, _amount, nextTermId);
        return true;
    }

    function lockWithdrawals(address _juror, uint64 _termId) external onlyDisputeManager {

        Juror storage juror = jurorsByAddress[_juror];
        juror.withdrawalsLockTermId = _termId;
    }

    function setTotalActiveBalanceLimit(uint256 _totalActiveBalanceLimit) external onlyConfigGovernor {

        _setTotalActiveBalanceLimit(_totalActiveBalanceLimit);
    }

    function token() external view returns (address) {

        return address(jurorsToken);
    }

    function totalStaked() external view returns (uint256) {

        return jurorsToken.balanceOf(address(this));
    }

    function totalActiveBalance() external view returns (uint256) {

        return tree.getTotal();
    }

    function totalActiveBalanceAt(uint64 _termId) external view returns (uint256) {

        return _totalActiveBalanceAt(_termId);
    }

    function totalStakedFor(address _juror) external view returns (uint256) {

        return _totalStakedFor(_juror);
    }

    function balanceOf(address _juror) external view returns (uint256 active, uint256 available, uint256 locked, uint256 pendingDeactivation) {

        return _balanceOf(_juror);
    }

    function balanceOfAt(address _juror, uint64 _termId) external view
        returns (uint256 active, uint256 available, uint256 locked, uint256 pendingDeactivation)
    {

        Juror storage juror = jurorsByAddress[_juror];

        active = _existsJuror(juror) ? tree.getItemAt(juror.id, _termId) : 0;
        (available, locked, pendingDeactivation) = _getBalances(juror);
    }

    function activeBalanceOfAt(address _juror, uint64 _termId) external view returns (uint256) {

        return _activeBalanceOfAt(_juror, _termId);
    }

    function unlockedActiveBalanceOf(address _juror) external view returns (uint256) {

        Juror storage juror = jurorsByAddress[_juror];
        return _currentUnlockedActiveBalanceOf(juror);
    }

    function getDeactivationRequest(address _juror) external view returns (uint256 amount, uint64 availableTermId) {

        DeactivationRequest storage request = jurorsByAddress[_juror].deactivationRequest;
        return (request.amount, request.availableTermId);
    }

    function getWithdrawalsLockTermId(address _juror) external view returns (uint64) {

        return jurorsByAddress[_juror].withdrawalsLockTermId;
    }

    function getJurorId(address _juror) external view returns (uint256) {

        return jurorsByAddress[_juror].id;
    }

    function totalJurorsActiveBalanceLimit() external view returns (uint256) {

        return totalActiveBalanceLimit;
    }

    function supportsHistory() external pure returns (bool) {

        return false;
    }

    function _activateTokens(address _juror, uint256 _amount, address _sender) internal {

        uint64 termId = _ensureCurrentTerm();

        _processDeactivationRequest(_juror, termId);

        uint256 availableBalance = jurorsByAddress[_juror].availableBalance;
        uint256 amountToActivate = _amount == 0 ? availableBalance : _amount;
        require(amountToActivate > 0, ERROR_INVALID_ZERO_AMOUNT);
        require(amountToActivate <= availableBalance, ERROR_INVALID_ACTIVATION_AMOUNT);

        uint64 nextTermId = termId + 1;
        _checkTotalActiveBalance(nextTermId, amountToActivate);
        Juror storage juror = jurorsByAddress[_juror];
        uint256 minActiveBalance = _getMinActiveBalance(nextTermId);

        if (_existsJuror(juror)) {
            uint256 activeBalance = tree.getItem(juror.id);
            require(activeBalance.add(amountToActivate) >= minActiveBalance, ERROR_ACTIVE_BALANCE_BELOW_MIN);
            tree.update(juror.id, nextTermId, amountToActivate, true);
        } else {
            require(amountToActivate >= minActiveBalance, ERROR_ACTIVE_BALANCE_BELOW_MIN);
            juror.id = tree.insert(nextTermId, amountToActivate);
            jurorsAddressById[juror.id] = _juror;
        }

        _updateAvailableBalanceOf(_juror, amountToActivate, false);
        emit JurorActivated(_juror, nextTermId, amountToActivate, _sender);
    }

    function _createDeactivationRequest(address _juror, uint256 _amount) internal {

        uint64 termId = _ensureCurrentTerm();

        _processDeactivationRequest(_juror, termId);

        uint64 nextTermId = termId + 1;
        Juror storage juror = jurorsByAddress[_juror];
        DeactivationRequest storage request = juror.deactivationRequest;
        request.amount = request.amount.add(_amount);
        request.availableTermId = nextTermId;
        tree.update(juror.id, nextTermId, _amount, false);

        emit JurorDeactivationRequested(_juror, nextTermId, _amount);
    }

    function _processDeactivationRequest(address _juror, uint64 _termId) internal {

        Juror storage juror = jurorsByAddress[_juror];
        DeactivationRequest storage request = juror.deactivationRequest;
        uint64 deactivationAvailableTermId = request.availableTermId;

        if (deactivationAvailableTermId == uint64(0) || _termId < deactivationAvailableTermId) {
            return;
        }

        uint256 deactivationAmount = request.amount;
        request.availableTermId = uint64(0);
        request.amount = 0;
        _updateAvailableBalanceOf(_juror, deactivationAmount, true);

        emit JurorDeactivationProcessed(_juror, deactivationAvailableTermId, deactivationAmount, _termId);
    }

    function _reduceDeactivationRequest(address _juror, uint256 _amount, uint64 _termId) internal {

        Juror storage juror = jurorsByAddress[_juror];
        DeactivationRequest storage request = juror.deactivationRequest;
        uint256 currentRequestAmount = request.amount;
        require(currentRequestAmount >= _amount, ERROR_CANNOT_REDUCE_DEACTIVATION_REQUEST);

        uint256 newRequestAmount = currentRequestAmount - _amount;
        request.amount = newRequestAmount;

        tree.update(juror.id, _termId + 1, _amount, true);

        emit JurorDeactivationUpdated(_juror, request.availableTermId, newRequestAmount, _termId);
    }

    function _stake(address _from, address _juror, uint256 _amount, bytes memory _data) internal {

        require(_amount > 0, ERROR_INVALID_ZERO_AMOUNT);
        _updateAvailableBalanceOf(_juror, _amount, true);

        if (_data.toBytes4() == JurorsRegistry(this).activate.selector) {
            _activateTokens(_juror, _amount, _from);
        }

        emit Staked(_juror, _amount, _totalStakedFor(_juror), _data);
        require(jurorsToken.safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_TRANSFER_FAILED);
    }

    function _unstake(address _juror, uint256 _amount, bytes memory _data) internal {

        require(_amount > 0, ERROR_INVALID_ZERO_AMOUNT);

        uint64 lastEnsuredTermId = _getLastEnsuredTermId();

        uint64 withdrawalsLockTermId = jurorsByAddress[_juror].withdrawalsLockTermId;
        require(withdrawalsLockTermId == 0 || withdrawalsLockTermId < lastEnsuredTermId, ERROR_WITHDRAWALS_LOCK);

        _processDeactivationRequest(_juror, lastEnsuredTermId);

        _updateAvailableBalanceOf(_juror, _amount, false);
        emit Unstaked(_juror, _amount, _totalStakedFor(_juror), _data);
        require(jurorsToken.safeTransfer(_juror, _amount), ERROR_TOKEN_TRANSFER_FAILED);
    }

    function _updateAvailableBalanceOf(address _juror, uint256 _amount, bool _positive) internal {

        if (_amount == 0) {
            return;
        }

        Juror storage juror = jurorsByAddress[_juror];
        if (_positive) {
            juror.availableBalance = juror.availableBalance.add(_amount);
        } else {
            require(_amount <= juror.availableBalance, ERROR_NOT_ENOUGH_AVAILABLE_BALANCE);
            juror.availableBalance -= _amount;
        }
    }

    function _setTotalActiveBalanceLimit(uint256 _totalActiveBalanceLimit) internal {

        require(_totalActiveBalanceLimit > 0, ERROR_BAD_TOTAL_ACTIVE_BALANCE_LIMIT);
        emit TotalActiveBalanceLimitChanged(totalActiveBalanceLimit, _totalActiveBalanceLimit);
        totalActiveBalanceLimit = _totalActiveBalanceLimit;
    }

    function _totalStakedFor(address _juror) internal view returns (uint256) {

        (uint256 active, uint256 available, , uint256 pendingDeactivation) = _balanceOf(_juror);
        return available.add(active).add(pendingDeactivation);
    }

    function _balanceOf(address _juror) internal view returns (uint256 active, uint256 available, uint256 locked, uint256 pendingDeactivation) {

        Juror storage juror = jurorsByAddress[_juror];

        active = _existsJuror(juror) ? tree.getItem(juror.id) : 0;
        (available, locked, pendingDeactivation) = _getBalances(juror);
    }

    function _activeBalanceOfAt(address _juror, uint64 _termId) internal view returns (uint256) {

        Juror storage juror = jurorsByAddress[_juror];
        return _existsJuror(juror) ? tree.getItemAt(juror.id, _termId) : 0;
    }

    function _lastUnlockedActiveBalanceOf(Juror storage _juror) internal view returns (uint256) {

        return _existsJuror(_juror) ? tree.getItem(_juror.id).sub(_juror.lockedBalance) : 0;
    }

    function _currentUnlockedActiveBalanceOf(Juror storage _juror) internal view returns (uint256) {

        uint64 lastEnsuredTermId = _getLastEnsuredTermId();
        return _existsJuror(_juror) ? tree.getItemAt(_juror.id, lastEnsuredTermId).sub(_juror.lockedBalance) : 0;
    }

    function _existsJuror(Juror storage _juror) internal view returns (bool) {

        return _juror.id != 0;
    }

    function _deactivationRequestedAmountForTerm(Juror storage _juror, uint64 _termId) internal view returns (uint256) {

        DeactivationRequest storage request = _juror.deactivationRequest;
        return request.availableTermId == _termId ? request.amount : 0;
    }

    function _totalActiveBalanceAt(uint64 _termId) internal view returns (uint256) {

        bool recent = _termId >= _getLastEnsuredTermId();
        return recent ? tree.getRecentTotalAt(_termId) : tree.getTotalAt(_termId);
    }

    function _checkTotalActiveBalance(uint64 _termId, uint256 _amount) internal view {

        uint256 currentTotalActiveBalance = _totalActiveBalanceAt(_termId);
        uint256 newTotalActiveBalance = currentTotalActiveBalance.add(_amount);
        require(newTotalActiveBalance <= totalActiveBalanceLimit, ERROR_TOTAL_ACTIVE_BALANCE_EXCEEDED);
    }

    function _getBalances(Juror storage _juror) internal view returns (uint256 available, uint256 locked, uint256 pendingDeactivation) {

        available = _juror.availableBalance;
        locked = _juror.lockedBalance;
        pendingDeactivation = _juror.deactivationRequest.amount;
    }

    function _treeSearch(DraftParams memory _params) internal view returns (uint256[] memory ids, uint256[] memory activeBalances) {

        (ids, activeBalances) = tree.batchedRandomSearch(
            _params.termRandomness,
            _params.disputeId,
            _params.termId,
            _params.selectedJurors,
            _params.batchRequestedJurors,
            _params.roundRequestedJurors,
            _params.iteration
        );
    }

    function _buildDraftParams(uint256[7] memory _params) private view returns (DraftParams memory) {

        uint64 termId = uint64(_params[2]);
        uint256 minActiveBalance = _getMinActiveBalance(termId);

        return DraftParams({
            termRandomness: bytes32(_params[0]),
            disputeId: _params[1],
            termId: termId,
            selectedJurors: _params[3],
            batchRequestedJurors: _params[4],
            roundRequestedJurors: _params[5],
            draftLockAmount: minActiveBalance.pct(uint16(_params[6])),
            iteration: 0
        });
    }
}


pragma solidity ^0.5.8;






contract JurorsRegistryMigrator is IDisputeManager {

    string constant internal ERROR_TOKEN_DOES_NOT_MATCH = "JRM_TOKEN_DOES_NOT_MATCH";
    string constant internal ERROR_CONTROLLER_DOES_NOT_MATCH = "JRM_CONTROLLER_DOES_NOT_MATCH";
    string constant internal ERROR_BALANCE_TO_MIGRATE_ZERO = "JRM_BALANCE_TO_MIGRATE_ZERO";
    string constant internal ERROR_ANJ_APPROVAL_FAILED = "JRM_ANJ_APPROVAL_FAILED";
    string constant internal ERROR_MIGRATION_IN_PROGRESS = "JRM_MIGRATION_IN_PROGRESS";
    string constant internal ERROR_CLOSE_TRANSFER_FAILED = "JRM_CLOSE_TRANSFER_FAILED";
    string constant internal ERROR_COURT_TERM_HAS_PASSED = "JRM_COURT_TERM_HAS_PASSED";
    string constant internal ERROR_SENDER_NOT_FUNDS_GOVERNOR = "JRM_SENDER_NOT_FUNDS_GOVERNOR";

    ERC20 public token;
    uint64 public termId;
    Controller public controller;
    JurorsRegistry public oldRegistry;
    JurorsRegistry public newRegistry;

    event TokensMigrated(address indexed juror, uint256 amount);
    event MigrationClosed(uint256 amount);

    modifier onlyFundsGovernor() {

        address fundsGovernor = controller.getFundsGovernor();
        require(fundsGovernor == msg.sender, ERROR_SENDER_NOT_FUNDS_GOVERNOR);
        _;
    }

    constructor (JurorsRegistry _oldRegistry, JurorsRegistry _newRegistry) public {
        address oldRegistryToken = _oldRegistry.token();
        address newRegistryToken = _newRegistry.token();
        require(oldRegistryToken == newRegistryToken, ERROR_TOKEN_DOES_NOT_MATCH);

        Controller oldRegistryController = _oldRegistry.getController();
        Controller newRegistryController = _newRegistry.getController();
        require(oldRegistryController == newRegistryController, ERROR_CONTROLLER_DOES_NOT_MATCH);

        token = ERC20(oldRegistryToken);
        oldRegistry = _oldRegistry;
        newRegistry = _newRegistry;
        controller = oldRegistryController;
        termId = oldRegistryController.getCurrentTermId();
    }

    function migrate(address[] calldata _jurors) external {

        uint64 currentTermId = _ensureMigrationTerm();

        for (uint256 i = 0; i < _jurors.length; i++) {
            _migrate(_jurors[i], currentTermId);
        }
    }

    function migrate(address _juror) external {

        uint64 currentTermId = _ensureMigrationTerm();
        _migrate(_juror, currentTermId);
    }

    function close() external onlyFundsGovernor {

        uint256 balance = token.balanceOf(address(this));
        emit MigrationClosed(balance);

        if (balance > 0) {
            require(token.transfer(address(oldRegistry), balance), ERROR_CLOSE_TRANSFER_FAILED);
        }
    }

    function _migrate(address _juror, uint64 _currentTermId) internal {

        uint256 balanceToBeMigrated = oldRegistry.activeBalanceOfAt(_juror, _currentTermId + 1);
        require(balanceToBeMigrated > 0, ERROR_BALANCE_TO_MIGRATE_ZERO);

        oldRegistry.collectTokens(_juror, balanceToBeMigrated, _currentTermId);
        require(token.approve(address(newRegistry), balanceToBeMigrated), ERROR_ANJ_APPROVAL_FAILED);
        newRegistry.stakeFor(_juror, balanceToBeMigrated, abi.encodePacked(keccak256("activate(uint256)")));

        emit TokensMigrated(_juror, balanceToBeMigrated);
    }

    function _ensureMigrationTerm() internal view returns (uint64) {

        uint64 currentTerm = controller.getCurrentTermId();
        require(termId == currentTerm, ERROR_COURT_TERM_HAS_PASSED);
        return currentTerm;
    }


    function createDispute(IArbitrable /* _subject */, uint8 /* _possibleRulings */, bytes calldata /* _metadata */) external returns (uint256) {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function closeEvidencePeriod(IArbitrable /* _subject */, uint256 /* _disputeId */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function draft(uint256 /* _disputeId */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function createAppeal(uint256 /* _disputeId */, uint256 /* _roundId */, uint8 /* _ruling */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function confirmAppeal(uint256 /* _disputeId */, uint256 /* _roundId */, uint8 /* _ruling */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function computeRuling(uint256 /* _disputeId */) external returns (IArbitrable /* subject */, uint8 /* finalRuling */) {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function settlePenalties(uint256 /* _disputeId */, uint256 /* _roundId */, uint256 /* _jurorsToSettle */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function settleReward(uint256 /* _disputeId */, uint256 /* _roundId */, address /* _juror */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function settleAppealDeposit(uint256 /* _disputeId */, uint256 /* _roundId */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function getDisputeFees() external view returns (ERC20 /* feeToken */, uint256 /* feeAmount */) {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function getDispute(uint256 /* _disputeId */) external view
        returns (
            IArbitrable /* subject */,
            uint8 /* possibleRulings */,
            DisputeState /* state */,
            uint8 /* finalRuling */,
            uint256 /* lastRoundId */,
            uint64 /* createTermId */
        )
    {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function getRound(uint256 /* _disputeId */, uint256 /* _roundId */) external view
        returns (
            uint64 /* draftTerm */,
            uint64 /* delayedTerms */,
            uint64 /* jurorsNumber */,
            uint64 /* selectedJurors */,
            uint256 /* jurorFees */,
            bool /* settledPenalties */,
            uint256 /* collectedTokens */,
            uint64 /* coherentJurors */,
            AdjudicationState /* state */
        )
    {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function getAppeal(uint256 /* _disputeId */, uint256 /* _roundId */) external view
        returns (address /* maker */, uint64 /* appealedRuling */, address /* taker */, uint64 /* opposedRuling */)
    {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function getNextRoundDetails(uint256 /* _disputeId */, uint256 /* _roundId */) external view
        returns (
            uint64 /* nextRoundStartTerm */,
            uint64 /* nextRoundJurorsNumber */,
            DisputeState /* newDisputeState */,
            ERC20 /* feeToken */,
            uint256 /* totalFees */,
            uint256 /* jurorFees */,
            uint256 /* appealDeposit */,
            uint256 /* confirmAppealDeposit */
        )
    {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }

    function getJuror(uint256 /* _disputeId */, uint256 /* _roundId */, address /* _juror */) external view
        returns (uint64 /* weight */, bool /* rewarded */)
    {

        revert(ERROR_MIGRATION_IN_PROGRESS);
    }
}