
pragma solidity ^0.4.24;

library SortitionSumTreeFactory {


    struct SortitionSumTree {
        uint K; // The maximum number of childs per node.
        uint[] stack;
        uint[] nodes;
        mapping(bytes32 => uint) IDsToNodeIndexes;
        mapping(uint => bytes32) nodeIndexesToIDs;
    }


    struct SortitionSumTrees {
        mapping(bytes32 => SortitionSumTree) sortitionSumTrees;
    }


    function createTree(SortitionSumTrees storage self, bytes32 _key, uint _K) public {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        require(tree.K == 0, "Tree already exists.");
        require(_K > 1, "K must be greater than one.");
        tree.K = _K;
        tree.stack.length = 0;
        tree.nodes.length = 0;
        tree.nodes.push(0);
    }

    function set(SortitionSumTrees storage self, bytes32 _key, uint _value, bytes32 _ID) public {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToNodeIndexes[_ID];

        if (treeIndex == 0) { // No existing node.
            if (_value != 0) { // Non zero value.
                if (tree.stack.length == 0) { // No vacant spots.
                    treeIndex = tree.nodes.length;
                    tree.nodes.push(_value);

                    if (treeIndex != 1 && (treeIndex - 1) % tree.K == 0) { // Is first child.
                        uint parentIndex = treeIndex / tree.K;
                        bytes32 parentID = tree.nodeIndexesToIDs[parentIndex];
                        uint newIndex = treeIndex + 1;
                        tree.nodes.push(tree.nodes[parentIndex]);
                        delete tree.nodeIndexesToIDs[parentIndex];
                        tree.IDsToNodeIndexes[parentID] = newIndex;
                        tree.nodeIndexesToIDs[newIndex] = parentID;
                    }
                } else { // Some vacant spot.
                    treeIndex = tree.stack[tree.stack.length - 1];
                    tree.stack.length--;
                    tree.nodes[treeIndex] = _value;
                }

                tree.IDsToNodeIndexes[_ID] = treeIndex;
                tree.nodeIndexesToIDs[treeIndex] = _ID;

                updateParents(self, _key, treeIndex, true, _value);
            }
        } else { // Existing node.
            if (_value == 0) { // Zero value.
                uint value = tree.nodes[treeIndex];
                tree.nodes[treeIndex] = 0;

                tree.stack.push(treeIndex);

                delete tree.IDsToNodeIndexes[_ID];
                delete tree.nodeIndexesToIDs[treeIndex];

                updateParents(self, _key, treeIndex, false, value);
            } else if (_value != tree.nodes[treeIndex]) { // New, non zero value.
                bool plusOrMinus = tree.nodes[treeIndex] <= _value;
                uint plusOrMinusValue = plusOrMinus ? _value - tree.nodes[treeIndex] : tree.nodes[treeIndex] - _value;
                tree.nodes[treeIndex] = _value;

                updateParents(self, _key, treeIndex, plusOrMinus, plusOrMinusValue);
            }
        }
    }


    function queryLeafs(
        SortitionSumTrees storage self,
        bytes32 _key,
        uint _cursor,
        uint _count
    ) public view returns(uint startIndex, uint[] values, bool hasMore) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        for (uint i = 0; i < tree.nodes.length; i++) {
            if ((tree.K * i) + 1 >= tree.nodes.length) {
                startIndex = i;
                break;
            }
        }

        uint loopStartIndex = startIndex + _cursor;
        values = new uint[](loopStartIndex + _count > tree.nodes.length ? tree.nodes.length - loopStartIndex : _count);
        uint valuesIndex = 0;
        for (uint j = loopStartIndex; j < tree.nodes.length; j++) {
            if (valuesIndex < _count) {
                values[valuesIndex] = tree.nodes[j];
                valuesIndex++;
            } else {
                hasMore = true;
                break;
            }
        }
    }

    function draw(SortitionSumTrees storage self, bytes32 _key, uint _drawnNumber) public view returns(bytes32 ID) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = 0;
        uint currentDrawnNumber = _drawnNumber % tree.nodes[0];

        while ((tree.K * treeIndex) + 1 < tree.nodes.length)  // While it still has children.
            for (uint i = 1; i <= tree.K; i++) { // Loop over children.
                uint nodeIndex = (tree.K * treeIndex) + i;
                uint nodeValue = tree.nodes[nodeIndex];

                if (currentDrawnNumber >= nodeValue) currentDrawnNumber -= nodeValue; // Go to the next child.
                else { // Pick this child.
                    treeIndex = nodeIndex;
                    break;
                }
            }

        ID = tree.nodeIndexesToIDs[treeIndex];
    }

    function stakeOf(SortitionSumTrees storage self, bytes32 _key, bytes32 _ID) public view returns(uint value) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToNodeIndexes[_ID];

        if (treeIndex == 0) value = 0;
        else value = tree.nodes[treeIndex];
    }


    function updateParents(SortitionSumTrees storage self, bytes32 _key, uint _treeIndex, bool _plusOrMinus, uint _value) private {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        uint parentIndex = _treeIndex;
        while (parentIndex != 0) {
            parentIndex = (parentIndex - 1) / tree.K;
            tree.nodes[parentIndex] = _plusOrMinus ? tree.nodes[parentIndex] + _value : tree.nodes[parentIndex] - _value;
        }
    }
}pragma solidity ^0.4.24;


contract ExposedSortitionSumTreeFactory {


    using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees;
    SortitionSumTreeFactory.SortitionSumTrees internal sortitionSumTrees;

    function _sortitionSumTrees(bytes32 _key) public view returns(uint K, uint[] stack, uint[] nodes) {

        return (
            sortitionSumTrees.sortitionSumTrees[_key].K,
            sortitionSumTrees.sortitionSumTrees[_key].stack,
            sortitionSumTrees.sortitionSumTrees[_key].nodes
        );
    }


    function _createTree(bytes32 _key, uint _K) public {

        sortitionSumTrees.createTree(_key, _K);
    }

    function _set(bytes32 _key, uint _value, bytes32 _ID) public {

        sortitionSumTrees.set(_key, _value, _ID);
    }


    function _queryLeafs(bytes32 _key, uint _cursor, uint _count) public view returns(uint startIndex, uint[] values, bool hasMore) {

        return sortitionSumTrees.queryLeafs(_key, _cursor, _count);
    }

    function _draw(bytes32 _key, uint _drawnNumber) public view returns(bytes32 ID) {

        return sortitionSumTrees.draw(_key, _drawnNumber);
    }

    function _stakeOf(bytes32 _key, bytes32 _ID) public view returns(uint value) {

        return sortitionSumTrees.stakeOf(_key, _ID);
    }
}/**
*  @title Random Number Generator Standard
*  @author Clément Lesaege - <[email protected]>
*
*/

pragma solidity ^0.4.15;

contract RNG{


    function contribute(uint _block) public payable;


    function requestRN(uint _block) public payable {

        contribute(_block);
    }

    function getRN(uint _block) public returns (uint RN);


    function getUncorrelatedRN(uint _block) public returns (uint RN) {

        uint baseRN = getRN(_block);
        if (baseRN == 0)
        return 0;
        else
        return uint(keccak256(msg.sender,baseRN));
    }

}/**
*  @title Constant Number Generator
*  @author Clément Lesaege - <[email protected]>
*  @dev A Random Number Generator which always return the same number. Usefull in order to make tests.
*/

pragma solidity ^0.4.15;

contract ConstantNG is RNG {


    uint public number;

    constructor(uint _number) public {
        number = _number;
    }

    function contribute(uint _block) public payable {}



    function getRN(uint _block) public returns (uint RN) {

        return number;
    }

}/**
 *  @title IArbitrable
 *  @author Enrique Piqueras - <[email protected]>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */

pragma solidity ^0.4.15;


interface IArbitrable {

    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

    event Evidence(Arbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    function rule(uint _disputeID, uint _ruling) external;

}/**
 *  @title Arbitrable
 *  @author Clément Lesaege - <[email protected]>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */

pragma solidity ^0.4.15;


contract Arbitrable is IArbitrable {

    Arbitrator public arbitrator;
    bytes public arbitratorExtraData; // Extra data to require particular dispute and appeal behaviour.

    modifier onlyArbitrator {require(msg.sender == address(arbitrator), "Can only be called by the arbitrator."); _;}


    constructor(Arbitrator _arbitrator, bytes _arbitratorExtraData) public {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }

    function rule(uint _disputeID, uint _ruling) public onlyArbitrator {

        emit Ruling(Arbitrator(msg.sender),_disputeID,_ruling);

        executeRuling(_disputeID,_ruling);
    }


    function executeRuling(uint _disputeID, uint _ruling) internal;

}/**
 *  @title Arbitrator
 *  @author Clément Lesaege - <[email protected]>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */

pragma solidity ^0.4.15;


contract Arbitrator {


    enum DisputeStatus {Waiting, Appealable, Solved}

    modifier requireArbitrationFee(bytes _extraData) {

        require(msg.value >= arbitrationCost(_extraData), "Not enough ETH to cover arbitration costs.");
        _;
    }
    modifier requireAppealFee(uint _disputeID, bytes _extraData) {

        require(msg.value >= appealCost(_disputeID, _extraData), "Not enough ETH to cover appeal costs.");
        _;
    }

    event DisputeCreation(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    event AppealPossible(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    event AppealDecision(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    function createDispute(uint _choices, bytes _extraData) public requireArbitrationFee(_extraData) payable returns(uint disputeID) {}


    function arbitrationCost(bytes _extraData) public view returns(uint fee);


    function appeal(uint _disputeID, bytes _extraData) public requireAppealFee(_disputeID,_extraData) payable {

        emit AppealDecision(_disputeID, Arbitrable(msg.sender));
    }

    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint fee);


    function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {}


    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status);


    function currentRuling(uint _disputeID) public view returns(uint ruling);

}/**
 *  @authors: [@clesaege, @n1c01a5, @epiqueras, @ferittuncer]
 *  @reviewers: [@clesaege*, @unknownunknown1*]
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */

pragma solidity ^0.4.15;


contract CentralizedArbitrator is Arbitrator {


    address public owner = msg.sender;
    uint arbitrationPrice; // Not public because arbitrationCost already acts as an accessor.
    uint constant NOT_PAYABLE_VALUE = (2**256-2)/2; // High value to be sure that the appeal is too expensive.

    struct DisputeStruct {
        Arbitrable arbitrated;
        uint choices;
        uint fee;
        uint ruling;
        DisputeStatus status;
    }

    modifier onlyOwner {require(msg.sender==owner, "Can only be called by the owner."); _;}


    DisputeStruct[] public disputes;

    constructor(uint _arbitrationPrice) public {
        arbitrationPrice = _arbitrationPrice;
    }

    function setArbitrationPrice(uint _arbitrationPrice) public onlyOwner {

        arbitrationPrice = _arbitrationPrice;
    }

    function arbitrationCost(bytes _extraData) public view returns(uint fee) {

        return arbitrationPrice;
    }

    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint fee) {

        return NOT_PAYABLE_VALUE;
    }

    function createDispute(uint _choices, bytes _extraData) public payable returns(uint disputeID)  {

        super.createDispute(_choices, _extraData);
        disputeID = disputes.push(DisputeStruct({
            arbitrated: Arbitrable(msg.sender),
            choices: _choices,
            fee: msg.value,
            ruling: 0,
            status: DisputeStatus.Waiting
            })) - 1; // Create the dispute and return its number.
        emit DisputeCreation(disputeID, Arbitrable(msg.sender));
    }

    function _giveRuling(uint _disputeID, uint _ruling) internal {

        DisputeStruct storage dispute = disputes[_disputeID];
        require(_ruling <= dispute.choices, "Invalid ruling.");
        require(dispute.status != DisputeStatus.Solved, "The dispute must not be solved already.");

        dispute.ruling = _ruling;
        dispute.status = DisputeStatus.Solved;

        msg.sender.send(dispute.fee); // Avoid blocking.
        dispute.arbitrated.rule(_disputeID,_ruling);
    }

    function giveRuling(uint _disputeID, uint _ruling) public onlyOwner {

        return _giveRuling(_disputeID, _ruling);
    }

    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status) {

        return disputes[_disputeID].status;
    }

    function currentRuling(uint _disputeID) public view returns(uint ruling) {

        return disputes[_disputeID].ruling;
    }
}/**
*  https://contributing.kleros.io/smart-contract-workflow
*  @authors: [@epiqueras, @ferittuncer]
*  @reviewers: []
*  @auditors: []
*  @bounties: []
*  @deployments: []
*/

pragma solidity ^0.4.24;


contract AppealableArbitrator is CentralizedArbitrator, Arbitrable {


    struct AppealDispute {
        uint rulingTime;
        Arbitrator arbitrator;
        uint appealDisputeID;
    }


    uint public timeOut;
    mapping(uint => AppealDispute) public appealDisputes;
    mapping(uint => uint) public appealDisputeIDsToDisputeIDs;


    constructor(
        uint _arbitrationPrice,
        Arbitrator _arbitrator,
        bytes _arbitratorExtraData,
        uint _timeOut
    ) public CentralizedArbitrator(_arbitrationPrice) Arbitrable(_arbitrator, _arbitratorExtraData) {
        timeOut = _timeOut;
    }


    function changeArbitrator(Arbitrator _arbitrator) external onlyOwner {

        arbitrator = _arbitrator;
    }

    function changeTimeOut(uint _timeOut) external onlyOwner {

        timeOut = _timeOut;
    }


    function getAppealDisputeID(uint _disputeID) external view returns(uint disputeID) {

        if (appealDisputes[_disputeID].arbitrator != Arbitrator(address(0)))
            disputeID = AppealableArbitrator(appealDisputes[_disputeID].arbitrator).getAppealDisputeID(appealDisputes[_disputeID].appealDisputeID);
        else disputeID = _disputeID;
    }


    function appeal(uint _disputeID, bytes _extraData) public payable requireAppealFee(_disputeID, _extraData) {

        super.appeal(_disputeID, _extraData);
        if (appealDisputes[_disputeID].arbitrator != Arbitrator(address(0)))
            appealDisputes[_disputeID].arbitrator.appeal.value(msg.value)(appealDisputes[_disputeID].appealDisputeID, _extraData);
        else {
            appealDisputes[_disputeID].arbitrator = arbitrator;
            appealDisputes[_disputeID].appealDisputeID = arbitrator.createDispute.value(msg.value)(disputes[_disputeID].choices, _extraData);
            appealDisputeIDsToDisputeIDs[appealDisputes[_disputeID].appealDisputeID] = _disputeID;
        }
    }

    function giveRuling(uint _disputeID, uint _ruling) public {

        require(disputes[_disputeID].status != DisputeStatus.Solved, "The specified dispute is already resolved.");
        if (appealDisputes[_disputeID].arbitrator != Arbitrator(address(0))) {
            require(Arbitrator(msg.sender) == appealDisputes[_disputeID].arbitrator, "Appealed disputes must be ruled by their back up arbitrator.");
            super._giveRuling(_disputeID, _ruling);
        } else {
            require(msg.sender == owner, "Not appealed disputes must be ruled by the owner.");
            if (disputes[_disputeID].status == DisputeStatus.Appealable) {
                if (now - appealDisputes[_disputeID].rulingTime > timeOut)
                    super._giveRuling(_disputeID, disputes[_disputeID].ruling);
                else revert("Time out time has not passed yet.");
            } else {
                disputes[_disputeID].ruling = _ruling;
                disputes[_disputeID].status = DisputeStatus.Appealable;
                appealDisputes[_disputeID].rulingTime = now;
                emit AppealPossible(_disputeID, disputes[_disputeID].arbitrated);
            }
        }
    }


    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint cost) {

        if (appealDisputes[_disputeID].arbitrator != Arbitrator(address(0)))
            cost = appealDisputes[_disputeID].arbitrator.appealCost(appealDisputes[_disputeID].appealDisputeID, _extraData);
        else if (disputes[_disputeID].status == DisputeStatus.Appealable) cost = arbitrator.arbitrationCost(_extraData);
        else cost = NOT_PAYABLE_VALUE;
    }

    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status) {

        if (appealDisputes[_disputeID].arbitrator != Arbitrator(address(0)))
            status = appealDisputes[_disputeID].arbitrator.disputeStatus(appealDisputes[_disputeID].appealDisputeID);
        else status = disputes[_disputeID].status;
    }

    function currentRuling(uint _disputeID) public view returns(uint ruling) {

        if (appealDisputes[_disputeID].arbitrator != Arbitrator(address(0))) // Appealed.
            ruling = appealDisputes[_disputeID].arbitrator.currentRuling(appealDisputes[_disputeID].appealDisputeID); // Retrieve ruling from the arbitrator whom the dispute is appealed to.
        else ruling = disputes[_disputeID].ruling; //  Not appealed, basic case.
    }


    function executeRuling(uint _disputeID, uint _ruling) internal {

        require(
            appealDisputes[appealDisputeIDsToDisputeIDs[_disputeID]].arbitrator != Arbitrator(address(0)),
            "The dispute must have been appealed."
        );
        giveRuling(appealDisputeIDsToDisputeIDs[_disputeID], _ruling);
    }
}pragma solidity ^0.4.24;


contract EnhancedAppealableArbitrator is AppealableArbitrator {


    constructor(
        uint _arbitrationPrice,
        Arbitrator _arbitrator,
        bytes _arbitratorExtraData,
        uint _timeOut
    ) public AppealableArbitrator(_arbitrationPrice, _arbitrator, _arbitratorExtraData, _timeOut) {}


    function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {

        if (appealDisputes[_disputeID].arbitrator != Arbitrator(address(0)))
            (start, end) = appealDisputes[_disputeID].arbitrator.appealPeriod(appealDisputes[_disputeID].appealDisputeID);
        else {
            start = appealDisputes[_disputeID].rulingTime;
            require(start != 0, "The specified dispute is not appealable.");
            end = start + timeOut;
        }
    }
}/**
 *  @title Two-Party Arbitrable
 *  @author Clément Lesaege - <[email protected]>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */


pragma solidity ^0.4.15;


contract TwoPartyArbitrable is Arbitrable {

    uint public timeout; // Time in second a party can take before being considered unresponding and lose the dispute.
    uint8 public amountOfChoices;
    address public partyA;
    address public partyB;
    uint public partyAFee; // Total fees paid by the partyA.
    uint public partyBFee; // Total fees paid by the partyB.
    uint public lastInteraction; // Last interaction for the dispute procedure.
    uint public disputeID;
    enum Status {NoDispute, WaitingPartyA, WaitingPartyB, DisputeCreated, Resolved}
    Status public status;

    uint8 constant PARTY_A_WINS = 1;
    uint8 constant PARTY_B_WINS = 2;
    string constant RULING_OPTIONS = "Party A wins;Party B wins"; // A plain English of what rulings do. Need to be redefined by the child class.

    modifier onlyPartyA{require(msg.sender == partyA, "Can only be called by party A."); _;}

    modifier onlyPartyB{require(msg.sender == partyB, "Can only be called by party B."); _;}

    modifier onlyParty{require(msg.sender == partyA || msg.sender == partyB, "Can only be called by party A or party B."); _;}


    enum Party {PartyA, PartyB}

    event HasToPayFee(Party _party);

    constructor(
        Arbitrator _arbitrator,
        uint _timeout,
        address _partyB,
        uint8 _amountOfChoices,
        bytes _arbitratorExtraData,
        string _metaEvidence
    )
        Arbitrable(_arbitrator,_arbitratorExtraData)
        public
    {
        timeout = _timeout;
        partyA = msg.sender;
        partyB = _partyB;
        amountOfChoices = _amountOfChoices;
        emit MetaEvidence(0, _metaEvidence);
    }


    function payArbitrationFeeByPartyA() public payable onlyPartyA {

        uint arbitrationCost = arbitrator.arbitrationCost(arbitratorExtraData);
        partyAFee += msg.value;
        require(
            partyAFee >= arbitrationCost,
            "Not enough ETH to cover arbitration costs."
        ); // Require that the total pay at least the arbitration cost.
        require(status < Status.DisputeCreated, "Dispute has already been created."); // Make sure a dispute has not been created yet.

        lastInteraction = now;
        if (partyBFee < arbitrationCost) {
            status = Status.WaitingPartyB;
            emit HasToPayFee(Party.PartyB);
        } else { // The partyB has also paid the fee. We create the dispute
            raiseDispute(arbitrationCost);
        }
    }


    function payArbitrationFeeByPartyB() public payable onlyPartyB {

        uint arbitrationCost = arbitrator.arbitrationCost(arbitratorExtraData);
        partyBFee += msg.value;
        require(
            partyBFee >= arbitrationCost,
            "Not enough ETH to cover arbitration costs."
        ); // Require that the total pay at least the arbitration cost.
        require(status < Status.DisputeCreated, "Dispute has already been created."); // Make sure a dispute has not been created yet.

        lastInteraction = now;
        if (partyAFee < arbitrationCost) {
            status = Status.WaitingPartyA;
            emit HasToPayFee(Party.PartyA);
        } else { // The partyA has also paid the fee. We create the dispute
            raiseDispute(arbitrationCost);
        }
    }

    function raiseDispute(uint _arbitrationCost) internal {

        status = Status.DisputeCreated;
        disputeID = arbitrator.createDispute.value(_arbitrationCost)(amountOfChoices,arbitratorExtraData);
        emit Dispute(arbitrator, disputeID, 0, 0);
    }

    function timeOutByPartyA() public onlyPartyA {

        require(status == Status.WaitingPartyB, "Not waiting for party B.");
        require(now >= lastInteraction + timeout, "The timeout time has not passed.");

        executeRuling(disputeID,PARTY_A_WINS);
    }

    function timeOutByPartyB() public onlyPartyB {

        require(status == Status.WaitingPartyA, "Not waiting for party A.");
        require(now >= lastInteraction + timeout, "The timeout time has not passed.");

        executeRuling(disputeID,PARTY_B_WINS);
    }

    function submitEvidence(string _evidence) public onlyParty {

        require(status >= Status.DisputeCreated, "The dispute has not been created yet.");
        emit Evidence(arbitrator, 0, msg.sender, _evidence);
    }

    function appeal(bytes _extraData) public onlyParty payable {

        arbitrator.appeal.value(msg.value)(disputeID,_extraData);
    }

    function executeRuling(uint _disputeID, uint _ruling) internal {

        require(_disputeID == disputeID, "Wrong dispute ID.");
        require(_ruling <= amountOfChoices, "Invalid ruling.");

        if (_ruling==PARTY_A_WINS)
            partyA.send(partyAFee > partyBFee ? partyAFee : partyBFee);
        else if (_ruling==PARTY_B_WINS)
            partyB.send(partyAFee > partyBFee ? partyAFee : partyBFee);

        status = Status.Resolved;
    }

}pragma solidity ^0.4.4;


contract Migrations {

    address public owner;
    uint public last_completed_migration;

    modifier isOwner() {

        if (msg.sender == owner) _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setCompleted(uint completed) public isOwner {

        last_completed_migration = completed;
    }

    function upgrade(address newAddress) public isOwner {

        Migrations upgraded = Migrations(newAddress);
        upgraded.setCompleted(last_completed_migration);
    }
}