
pragma solidity ^0.5.0;

library BN256 {

    struct G1Point {
        uint x;
        uint y;
    }

    struct G2Point {
        uint[2] x;
        uint[2] y;
    }

    function P1() internal pure returns (G1Point memory) {

        return G1Point(1, 2);
    }

    function P2() internal pure returns (G2Point memory) {

        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
            10857046999023057135944570762232829481370756359578518086990519993285655852781],

            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
            8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }

    function pointAdd(G1Point memory p1, G1Point memory p2) internal returns (G1Point memory r) {

        uint[4] memory input;
        input[0] = p1.x;
        input[1] = p1.y;
        input[2] = p2.x;
        input[3] = p2.y;
        assembly {
            if iszero(call(sub(gas, 2000), 0x6, 0, input, 0x80, r, 0x40)) {
                revert(0, 0)
            }
        }
    }

    function scalarMul(G1Point memory p, uint s) internal returns (G1Point memory r) {

        uint[3] memory input;
        input[0] = p.x;
        input[1] = p.y;
        input[2] = s;
        assembly {
            if iszero(call(sub(gas, 2000), 0x7, 0, input, 0x60, r, 0x40)) {
                revert(0, 0)
            }
        }
    }

    function negate(G1Point memory p) internal pure returns (G1Point memory) {

        if (p.x == 0 && p.y == 0) {
            return p;
        }
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        return G1Point(p.x, q - p.y % q);
    }

    function hashToG1(bytes memory data) internal returns (G1Point memory) {

        uint256 h = uint256(keccak256(data));
        return scalarMul(P1(), h);
    }

    function G2Equal(G2Point memory p1, G2Point memory p2) internal pure returns (bool) {

        return p1.x[0] == p2.x[0] && p1.x[1] == p2.x[1] && p1.y[0] == p2.y[0] && p1.y[1] == p2.y[1];
    }

    function pairingCheck(G1Point[] memory p1, G2Point[] memory p2) internal returns (bool) {

        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);

        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].x;
            input[i * 6 + 1] = p1[i].y;
            input[i * 6 + 2] = p2[i].x[0];
            input[i * 6 + 3] = p2[i].x[1];
            input[i * 6 + 4] = p2[i].y[0];
            input[i * 6 + 5] = p2[i].y[1];
        }

        uint[1] memory out;
        bool success;
        assembly {
            success := call(
                sub(gas, 2000),
                0x8,
                0,
                add(input, 0x20),
                mul(inputSize, 0x20),
                out, 0x20
            )
        }
        return success && (out[0] != 0);
    }
}

contract UserContractInterface {

    function __callback__(uint, bytes calldata) external;

    function __callback__(uint, uint) external;

}

contract CommitRevealInterface {

    function startCommitReveal(uint, uint, uint, uint) public returns(uint);

    function getRandom(uint) public returns(uint);

}

contract DOSAddressBridgeInterface {

    function getCommitRevealAddress() public view returns(address);

    function getPaymentAddress() public view returns(address);

    function getStakingAddress() public view returns(address);

}

contract DOSPaymentInterface {

    function hasServiceFee(address, uint) public view returns (bool);

    function chargeServiceFee(address, uint, uint) public;

    function recordServiceFee(uint, address, address[] memory) public;

    function claimGuardianReward(address) public;

    function setPaymentMethod(address, address) public;

}

contract DOSStakingInterface {

    function nodeStart(address _nodeAddr) public;

    function nodeStop(address _nodeAddr) public;

    function isValidStakingNode(address _nodeAddr) public view returns(bool);

}

contract DOSProxy {

    using BN256 for *;

    struct PendingRequest {
        uint requestId;
        uint groupId;
        BN256.G2Point handledGroupPubKey;
        address callbackAddr;
    }

    struct Group {
        uint groupId;
        BN256.G2Point groupPubKey;
        uint life;
        uint birthBlkN;
        address[] members;
    }

    struct PendingGroup {
        uint groupId;
        uint startBlkNum;
        mapping(bytes32 => uint) pubKeyCounts;
        mapping(address => address) memberList;
    }

    address private owner;
    uint public initBlkN;
    mapping(uint => PendingRequest) PendingRequests;

    uint public relayRespondLimit = 100; // in blocks
    uint public refreshSystemRandomHardLimit = 1440; // in blocks, ~6 hour
    uint public groupMaturityPeriod = refreshSystemRandomHardLimit * 28; // in blocks, ~7days
    uint public lifeDiversity = refreshSystemRandomHardLimit * 12; // in blocks, ~3days
    uint public loopLimit = 50;

    uint public bootstrapGroups = 4;
    uint public groupToPick = 2;
    uint public groupSize = 3;

    uint public bootstrapCommitDuration = 40;
    uint public bootstrapRevealDuration = 40;
    uint public bootstrapStartThreshold = groupSize * bootstrapGroups;
    uint public bootstrapRound;
    uint public bootstrapEndBlk;

    DOSAddressBridgeInterface public addressBridge;
    address public proxyFundsAddr;
    address public proxyFundsTokenAddr;

    uint private constant UINTMAX = uint(-1);
    uint private constant HEAD_I = 0x1;
    address private constant HEAD_A = address(0x1);

    mapping(address => address) public pendingNodeList;
    address public pendingNodeTail;
    uint public numPendingNodes;

    mapping(address => mapping(uint => uint)) public nodeToGroupIdList;

    mapping(uint => Group) workingGroups;
    uint[] public workingGroupIds;
    uint[] public expiredWorkingGroupIds;

    mapping(uint => PendingGroup) public pendingGroups;
    uint public pendingGroupMaxLife = 20;  // in blocks

    mapping(uint => uint) public pendingGroupList;
    uint public pendingGroupTail;
    uint public numPendingGroups;

    uint public cachedUpdatedBlock;
    uint public lastUpdatedBlock;
    uint public lastRandomness;
    uint public lastFormGrpReqId;
    Group lastHandledGroup;

    mapping(address => bool) public guardianListed;
    enum TrafficType {
        SystemRandom,
        UserRandom,
        UserQuery
    }

    event LogUrl(uint queryId, uint timeout, string dataSource, string selector, uint randomness, uint dispatchedGroupId);
    event LogRequestUserRandom(uint requestId, uint lastSystemRandomness, uint userSeed, uint dispatchedGroupId);
    event LogNonSupportedType(string invalidSelector);
    event LogNonContractCall(address from);
    event LogCallbackTriggeredFor(address callbackAddr);
    event LogRequestFromNonExistentUC();
    event LogUpdateRandom(uint lastRandomness, uint dispatchedGroupId);
    event LogValidationResult(uint8 trafficType, uint trafficId, bytes message, uint[2] signature, uint[4] pubKey, bool pass);
    event LogInsufficientPendingNode(uint numPendingNodes);
    event LogInsufficientWorkingGroup(uint numWorkingGroups, uint numPendingGroups);
    event LogGrouping(uint groupId, address[] nodeId);
    event LogPublicKeyAccepted(uint groupId, uint[4] pubKey, uint numWorkingGroups);
    event LogPublicKeySuggested(uint groupId, uint pubKeyCount);
    event LogGroupDissolve(uint groupId);
    event LogRegisteredNewPendingNode(address node);
    event LogUnRegisteredNewPendingNode(address node, uint8 unregisterFrom);
    event LogGroupingInitiated(uint pendingNodePool, uint groupsize);
    event LogNoPendingGroup(uint groupId);
    event LogPendingGroupRemoved(uint groupId);
    event LogMessage(string info);
    event GuardianReward(uint blkNum, address guardian);

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    modifier fromValidStakingNode {

        require(DOSStakingInterface(addressBridge.getStakingAddress()).isValidStakingNode(msg.sender),
                "invalid-staking-node");
        _;
    }

    modifier hasOracleFee(address from, uint serviceType) {

        require(
            DOSPaymentInterface(addressBridge.getPaymentAddress()).hasServiceFee(from, serviceType),
            "not-enough-fee-to-oracle");
        _;
    }

    modifier onlyGuardianListed {

        require(guardianListed[msg.sender], "not-guardian");
        _;
    }

    constructor(address _bridgeAddr, address _proxyFundsAddr, address _proxyFundsTokenAddr) public {
        owner = msg.sender;
        initBlkN = block.number;
        pendingNodeList[HEAD_A] = HEAD_A;
        pendingNodeTail = HEAD_A;
        pendingGroupList[HEAD_I] = HEAD_I;
        pendingGroupTail = HEAD_I;
        addressBridge = DOSAddressBridgeInterface(_bridgeAddr);
        proxyFundsAddr = _proxyFundsAddr;
        proxyFundsTokenAddr = _proxyFundsTokenAddr;
        DOSPaymentInterface(addressBridge.getPaymentAddress()).setPaymentMethod(proxyFundsAddr, proxyFundsTokenAddr);
    }

    function addToGuardianList(address _addr) public onlyOwner {

        guardianListed[_addr] = true;
    }

    function removeFromGuardianList(address _addr) public onlyOwner {

        delete guardianListed[_addr];
    }

    function setProxyFund(address newFund, address newFundToken) public onlyOwner {

        require(newFund != proxyFundsAddr && newFund != address(0x0), "invalid-parameter");
        require(newFundToken != proxyFundsTokenAddr && newFundToken != address(0x0), "invalid-parameter");
        proxyFundsAddr = newFund;
        proxyFundsTokenAddr = newFundToken;
        DOSPaymentInterface(addressBridge.getPaymentAddress()).setPaymentMethod(proxyFundsAddr, proxyFundsTokenAddr);
    }

    function setGroupSize(uint newSize) public onlyOwner {

        require(newSize != groupSize && newSize % 2 != 0, "invalid-parameter");
        groupSize = newSize;
    }

    function setBootstrapStartThreshold(uint newThreshold) public onlyOwner {

        require(newThreshold != bootstrapStartThreshold, "invalid-parameter");
        bootstrapStartThreshold = newThreshold;
    }

    function setBootstrapCommitDuration(uint newDuration) public onlyOwner {

        require(newDuration != bootstrapCommitDuration && newDuration != 0, "invalid-parameter");
        bootstrapCommitDuration = newDuration;
    }

    function setBootstrapRevealDuration(uint newDuration) public onlyOwner {

        require(newDuration != bootstrapRevealDuration && newDuration != 0, "invalid-parameter");
        bootstrapRevealDuration = newDuration;
    }

    function setGroupMaturityPeriod(uint newPeriod) public onlyOwner {

        require(newPeriod != groupMaturityPeriod && newPeriod != 0, "invalid-parameter");
        groupMaturityPeriod = newPeriod;
    }

    function setLifeDiversity(uint newDiversity) public onlyOwner {

        require(newDiversity != lifeDiversity && newDiversity != 0, "invalid-parameter");
        lifeDiversity = newDiversity;
    }

    function setPendingGroupMaxLife(uint newLife) public onlyOwner {

        require(newLife != pendingGroupMaxLife && newLife != 0, "invalid-parameter");
        pendingGroupMaxLife = newLife;
    }

    function setRelayRespondLimit(uint newLimit) public onlyOwner {

        require(newLimit != relayRespondLimit, "invalid-parameter");
        relayRespondLimit = newLimit;
    }

    function setSystemRandomHardLimit(uint newLimit) public onlyOwner {

        require(newLimit != refreshSystemRandomHardLimit && newLimit != 0, "invalid-parameter");
        refreshSystemRandomHardLimit = newLimit;
    }

    function resetOnRecovery(uint cap) public onlyOwner {

        uint len = numPendingNodes + groupSize * (numPendingGroups + workingGroupIds.length + expiredWorkingGroupIds.length);
        cap = cap < len ? cap : len;

        address n = pendingNodeList[HEAD_A];
        uint prevCap = cap;
        while (cap > 0 && pendingNodeList[HEAD_A] != HEAD_A) {
            nodeToGroupIdList[n][HEAD_I] = 0;
            n = pendingNodeList[n];
            cap--;
        }
        if (prevCap - cap < numPendingNodes) return;
        prevCap = cap;
        pendingNodeList[HEAD_A] = HEAD_A;
        pendingNodeTail = HEAD_A;
        numPendingNodes = 0;

        uint gid = pendingGroupList[HEAD_I];
        while (cap > 0 && gid != HEAD_I) {
            PendingGroup storage pgrp = pendingGroups[gid];
            address m = pgrp.memberList[HEAD_A];
            while (cap > 0 && m != HEAD_A) {
                nodeToGroupIdList[m][HEAD_I] = 0;
                m = pgrp.memberList[m];
                cap--;
            }
            gid = pendingGroupList[gid];
        }
        if (prevCap - cap < groupSize * numPendingGroups) return;
        prevCap = cap;
        pendingGroupList[HEAD_I] = HEAD_I;
        pendingGroupTail = HEAD_I;
        numPendingGroups = 0;

        for (uint i = 0; cap > 0 && i < workingGroupIds.length; i++) {
            address[] storage members = workingGroups[workingGroupIds[i]].members;
            for (uint j = 0; cap > 0 && j < members.length; j++) {
                nodeToGroupIdList[members[j]][HEAD_I] = 0;
                cap--;
            }
        }
        if (prevCap - cap < groupSize * workingGroupIds.length) return;
        prevCap = cap;
        workingGroupIds.length = 0;
        for (uint i = 0; cap > 0 && i < expiredWorkingGroupIds.length; i++) {
            address[] storage members = workingGroups[expiredWorkingGroupIds[i]].members;
            for (uint j = 0; cap > 0 && j < members.length; j++) {
                nodeToGroupIdList[members[j]][HEAD_I] = 0;
                cap--;
            }
        }
        if (prevCap - cap < groupSize * expiredWorkingGroupIds.length) return;
        expiredWorkingGroupIds.length = 0;

        bootstrapRound = 0;
        cachedUpdatedBlock = 0;
        lastUpdatedBlock = 0;
        lastRandomness = 0;
        lastFormGrpReqId = 0;

    }

    function getCodeSize(address addr) private view returns (uint size) {

        assembly {
            size := extcodesize(addr)
        }
    }

    function dispatchJobCore(TrafficType trafficType, uint pseudoSeed) private returns(uint idx) {

        uint dissolveIdx = 0;
        do {
            if (workingGroupIds.length == 0) {
                return UINTMAX;
            }
            if (dissolveIdx >= workingGroupIds.length ||
                dissolveIdx >= loopLimit) {
                uint rnd = uint(keccak256(abi.encodePacked(trafficType, pseudoSeed, lastRandomness, block.number)));
                return rnd % workingGroupIds.length;
            }
            Group storage group = workingGroups[workingGroupIds[dissolveIdx]];
            if (groupMaturityPeriod + group.birthBlkN + group.life <= block.number) {
                expiredWorkingGroupIds.push(workingGroupIds[dissolveIdx]);
                workingGroupIds[dissolveIdx] = workingGroupIds[workingGroupIds.length - 1];
                workingGroupIds.length--;
            }
            dissolveIdx++;
        } while (true);
    }

    function dispatchJob(TrafficType trafficType, uint pseudoSeed) private returns(uint) {

        kickoffRandomOnCondition();
        return dispatchJobCore(trafficType, pseudoSeed);
    }

    function kickoffRandomOnCondition() private returns (bool) {

        if (lastUpdatedBlock + refreshSystemRandomHardLimit > block.number || cachedUpdatedBlock + relayRespondLimit > block.number) {
            return false;
        }

        uint idx = dispatchJobCore(TrafficType.SystemRandom, uint(blockhash(block.number - 1)));
        if (idx == UINTMAX) {
            emit LogMessage("no-live-wgrp,try-bootstrap");
            return false;
        }

        cachedUpdatedBlock = block.number;
        lastHandledGroup = workingGroups[workingGroupIds[idx]];
        emit LogUpdateRandom(lastRandomness, lastHandledGroup.groupId);
        DOSPaymentInterface(addressBridge.getPaymentAddress()).chargeServiceFee(proxyFundsAddr, /*requestId=*/lastRandomness, uint(TrafficType.SystemRandom));
        return true;
    }

    function insertToPendingGroupListTail(uint groupId) private {

        pendingGroupList[groupId] = pendingGroupList[pendingGroupTail];
        pendingGroupList[pendingGroupTail] = groupId;
        pendingGroupTail = groupId;
        numPendingGroups++;
    }

    function insertToPendingNodeListTail(address node) private {

        pendingNodeList[node] = pendingNodeList[pendingNodeTail];
        pendingNodeList[pendingNodeTail] = node;
        pendingNodeTail = node;
        numPendingNodes++;
    }

    function insertToPendingNodeListHead(address node) private {

        pendingNodeList[node] = pendingNodeList[HEAD_A];
        pendingNodeList[HEAD_A] = node;
        numPendingNodes++;
    }

    function insertToListHead(mapping(uint => uint) storage list, uint id) private {

        list[id] = list[HEAD_I];
        list[HEAD_I] = id;
    }

    function removeNodeFromList(mapping(address => address) storage list, address node) private returns(address, bool) {

        (address prev, bool found) = findNodeFromList(list, node);
        if (found) {
            list[prev] = list[node];
            delete list[node];
        }
        return (prev, found);
    }

    function findNodeFromList(mapping(address => address) storage list, address node) private view returns(address, bool) {

        address prev = HEAD_A;
        address curr = list[prev];
        while (curr != HEAD_A && curr != node) {
            prev = curr;
            curr = list[prev];
        }
        if (curr == HEAD_A) {
            return (HEAD_A, false);
        } else {
            return (prev, true);
        }
    }

    function removeIdFromList(mapping(uint => uint) storage list, uint id) private returns(uint, bool) {

        uint prev = HEAD_I;
        uint curr = list[prev];
        while (curr != HEAD_I && curr != id) {
            prev = curr;
            curr = list[prev];
        }
        if (curr == HEAD_I) {
            return (HEAD_I, false);
        } else {
            list[prev] = list[curr];
            delete list[curr];
            return (prev, true);
        }
    }

    function checkAndRemoveFromPendingGroup(address node) private returns(bool) {

        uint prev = HEAD_I;
        uint curr = pendingGroupList[prev];
        while (curr != HEAD_I) {
            PendingGroup storage pgrp = pendingGroups[curr];
            (, bool found) = findNodeFromList(pgrp.memberList, node);
            if (found) {
                cleanUpPendingGroup(curr, node);
                return true;
            }
            prev = curr;
            curr = pendingGroupList[prev];
        }
        return false;
    }

    function dissolveWorkingGroup(uint groupId, bool backToPendingPool, address skipNode) private {

        Group storage grp = workingGroups[groupId];
        for (uint i = 0; i < grp.members.length; i++) {
            address member = grp.members[i];
            (uint prev, bool removed) = removeIdFromList(nodeToGroupIdList[member], grp.groupId);
            if (removed && prev == HEAD_I) {
                if (backToPendingPool && member != skipNode && pendingNodeList[member] == address(0)) {
                    insertToPendingNodeListTail(member);
                }
            }
        }
        delete workingGroups[groupId];
        emit LogGroupDissolve(groupId);
    }

    function query(
        address from,
        uint timeout,
        string calldata dataSource,
        string calldata selector
    )
        external
        hasOracleFee(from, uint(TrafficType.UserQuery))
        returns (uint)
    {

        if (getCodeSize(from) > 0) {
            bytes memory bs = bytes(selector);
            if (bs.length == 0 || bs[0] == '$' || bs[0] == '/') {
                uint queryId = uint(keccak256(abi.encode(block.timestamp, from, timeout, dataSource, selector)));
                uint idx = dispatchJob(TrafficType.UserQuery, queryId);
                if (idx == UINTMAX) {
                    emit LogMessage("skipped-user-query-no-live-wgrp");
                    return 0;
                }
                Group storage grp = workingGroups[workingGroupIds[idx]];
                PendingRequests[queryId] = PendingRequest(queryId, grp.groupId, grp.groupPubKey, from);
                emit LogUrl(
                    queryId,
                    timeout,
                    dataSource,
                    selector,
                    lastRandomness,
                    grp.groupId
                );
                DOSPaymentInterface(addressBridge.getPaymentAddress()).chargeServiceFee(from, queryId, uint(TrafficType.UserQuery));
                return queryId;
            } else {
                emit LogNonSupportedType(selector);
                return 0;
            }
        } else {
            emit LogNonContractCall(from);
            return 0;
        }
    }

    function requestRandom(address from, uint userSeed)
        public
        hasOracleFee(from, uint(TrafficType.UserRandom))
        returns (uint)
    {

        uint requestId = uint(keccak256(abi.encode(block.timestamp, from, userSeed)));
        uint idx = dispatchJob(TrafficType.UserRandom, requestId);
        if (idx == UINTMAX) {
            emit LogMessage("skipped-user-rnd-no-live-wgrp");
            return 0;
        }
        Group storage grp = workingGroups[workingGroupIds[idx]];
        PendingRequests[requestId] = PendingRequest(requestId, grp.groupId, grp.groupPubKey, from);
        emit LogRequestUserRandom(
            requestId,
            lastRandomness,
            userSeed,
            grp.groupId
        );
        DOSPaymentInterface(addressBridge.getPaymentAddress()).chargeServiceFee(
            from == address(this) ? proxyFundsAddr : from,
            requestId,
            uint(TrafficType.UserRandom)
        );
        return requestId;
    }

    function validateAndVerify(
        uint8 trafficType,
        uint trafficId,
        bytes memory data,
        BN256.G1Point memory signature,
        BN256.G2Point memory grpPubKey
    )
        private
        returns (bool)
    {

        bytes memory message = abi.encodePacked(data, msg.sender);

        BN256.G1Point[] memory p1 = new BN256.G1Point[](2);
        BN256.G2Point[] memory p2 = new BN256.G2Point[](2);
        p1[0] = BN256.negate(signature);
        p1[1] = BN256.hashToG1(message);
        p2[0] = BN256.P2();
        p2[1] = grpPubKey;
        bool passVerify = BN256.pairingCheck(p1, p2);
        emit LogValidationResult(
            trafficType,
            trafficId,
            message,
            [signature.x, signature.y],
            [grpPubKey.x[0], grpPubKey.x[1], grpPubKey.y[0], grpPubKey.y[1]],
            passVerify
        );
        return passVerify;
    }

    function triggerCallback(
        uint requestId,
        uint8 trafficType,
        bytes calldata result,
        uint[2] calldata sig
    )
        external
        fromValidStakingNode
    {

        address ucAddr = PendingRequests[requestId].callbackAddr;
        if (ucAddr == address(0x0)) {
            emit LogRequestFromNonExistentUC();
            return;
        }

        if (!validateAndVerify(
                trafficType,
                requestId,
                result,
                BN256.G1Point(sig[0], sig[1]),
                PendingRequests[requestId].handledGroupPubKey))
        {
            return;
        }

        emit LogCallbackTriggeredFor(ucAddr);
        delete PendingRequests[requestId];
        if (trafficType == uint8(TrafficType.UserQuery)) {
            UserContractInterface(ucAddr).__callback__(requestId, result);
        } else if (trafficType == uint8(TrafficType.UserRandom)) {
            emit LogMessage("UserRandom");
            UserContractInterface(ucAddr).__callback__(
                requestId, uint(keccak256(abi.encodePacked(sig[0], sig[1]))));
        } else {
            revert("unsupported-traffic-type");
        }
        Group memory grp = workingGroups[PendingRequests[requestId].groupId];
        DOSPaymentInterface(addressBridge.getPaymentAddress()).recordServiceFee(requestId, msg.sender, grp.members);
    }

    function toBytes(uint x) private pure returns (bytes memory b) {

        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }

    function updateRandomness(uint[2] calldata sig) external fromValidStakingNode {

        if (!validateAndVerify(
                uint8(TrafficType.SystemRandom),
                lastRandomness,
                toBytes(lastRandomness),
                BN256.G1Point(sig[0], sig[1]),
                lastHandledGroup.groupPubKey))
        {
            return;
        }

        cachedUpdatedBlock = 0;
        lastUpdatedBlock = block.number;
        uint claimFeeId = lastRandomness;
        lastRandomness = uint(keccak256(abi.encodePacked(sig[0], sig[1])));
        DOSPaymentInterface(addressBridge.getPaymentAddress()).recordServiceFee(claimFeeId, msg.sender, lastHandledGroup.members);
    }

    function cleanUpPendingGroup(uint gid, address skipNode) private {

        PendingGroup storage pgrp = pendingGroups[gid];
        address member = pgrp.memberList[HEAD_A];
        while (member != HEAD_A) {
            if (nodeToGroupIdList[member][HEAD_I] == HEAD_I && member != skipNode && pendingNodeList[member] == address(0)) {
                insertToPendingNodeListHead(member);
            }
            member = pgrp.memberList[member];
        }
        (uint prev, bool removed) = removeIdFromList(pendingGroupList, gid);
        if (removed && pendingGroupTail == gid) {
            pendingGroupTail = prev;
        }

        delete pendingGroups[gid];
        numPendingGroups--;
        emit LogPendingGroupRemoved(gid);
    }

    function signalRandom() public {

        if (kickoffRandomOnCondition()) {
            emit GuardianReward(block.number, msg.sender);
            DOSPaymentInterface(addressBridge.getPaymentAddress()).claimGuardianReward(msg.sender);
        } else {
            emit LogMessage("sys-random-not-expired");
        }
    }

    function signalGroupDissolve() public {

        uint gid = pendingGroupList[HEAD_I];
        if (gid != HEAD_I && pendingGroups[gid].startBlkNum + pendingGroupMaxLife < block.number) {
            cleanUpPendingGroup(gid, HEAD_A);
            emit GuardianReward(block.number, msg.sender);
            DOSPaymentInterface(addressBridge.getPaymentAddress()).claimGuardianReward(msg.sender);
        } else {
            emit LogMessage("no-expired-pgrp-to-clean");
        }
    }
    function signalGroupFormation() public {

        if (formGroup()) {
            emit GuardianReward(block.number, msg.sender);
            DOSPaymentInterface(addressBridge.getPaymentAddress()).claimGuardianReward(msg.sender);
        } else {
            emit LogMessage("no-grp-formation");
        }
    }
    function signalBootstrap(uint _cid) public {

        require(bootstrapRound == _cid, "not-in-bootstrap");

        if (block.number <= bootstrapEndBlk) {
            emit LogMessage("wait-to-collect-more-entropy");
            return;
        }
        if (numPendingNodes < bootstrapStartThreshold) {
            emit LogMessage("not-enough-p-node-to-bootstrap");
            return;
        }
        bootstrapRound = 0;
        bootstrapEndBlk = 0;
        uint rndSeed = CommitRevealInterface(addressBridge.getCommitRevealAddress()).getRandom(_cid);
        if (rndSeed == 0) {
            emit LogMessage("bootstrap-commit-reveal-failure");
            return;
        }
        cachedUpdatedBlock = 0;
        lastUpdatedBlock = block.number;
        lastRandomness = uint(keccak256(abi.encodePacked(lastRandomness, rndSeed)));

        uint arrSize = bootstrapStartThreshold / groupSize * groupSize;
        address[] memory candidates = new address[](arrSize);

        pick(arrSize, 0, candidates);
        shuffle(candidates, lastRandomness);
        regroup(candidates, arrSize / groupSize);
        emit GuardianReward(block.number, msg.sender);
        DOSPaymentInterface(addressBridge.getPaymentAddress()).claimGuardianReward(msg.sender);
    }
    function signalUnregister(address member) public onlyGuardianListed {

        if (unregister(member)) {
            emit GuardianReward(block.number, msg.sender);
            DOSPaymentInterface(addressBridge.getPaymentAddress()).claimGuardianReward(msg.sender);
        } else {
            emit LogMessage("nothing-to-unregister");
        }
    }

    function unregisterNode() public fromValidStakingNode returns (bool) {

        return unregister(msg.sender);
    }

    function unregister(address node) private returns (bool) {

        uint groupId = nodeToGroupIdList[node][HEAD_I];
        bool removed = false;
        uint8 unregisteredFrom = 0;
        if (groupId != 0 && groupId != HEAD_I) {
            dissolveWorkingGroup(groupId, true, node);
            for (uint idx = 0; idx < workingGroupIds.length; idx++) {
                if (workingGroupIds[idx] == groupId) {
                    if (idx != (workingGroupIds.length - 1)) {
                        workingGroupIds[idx] = workingGroupIds[workingGroupIds.length - 1];
                    }
                    workingGroupIds.length--;
                    removed = true;
                    unregisteredFrom |= 0x1;
                    break;
                }
            }
            if (!removed) {
                for (uint idx = 0; idx < expiredWorkingGroupIds.length; idx++) {
                    if (expiredWorkingGroupIds[idx] == groupId) {
                        if (idx != (expiredWorkingGroupIds.length - 1)) {
                            expiredWorkingGroupIds[idx] = expiredWorkingGroupIds[expiredWorkingGroupIds.length - 1];
                        }
                        expiredWorkingGroupIds.length--;
                        removed = true;
                        unregisteredFrom |= 0x2;
                        break;
                    }
                }
            }
        }

        if (!removed && checkAndRemoveFromPendingGroup(node)) {
            unregisteredFrom |= 0x4;
        }

        if (pendingNodeList[node] != address(0)) {
            address prev;
            (prev, removed) = removeNodeFromList(pendingNodeList, node);
            if (removed) {
                numPendingNodes--;
                nodeToGroupIdList[node][HEAD_I] = 0;
                if (pendingNodeTail == node) {
                    pendingNodeTail = prev;
                }
                unregisteredFrom |= 0x8;
            }
        }
        emit LogUnRegisteredNewPendingNode(node, unregisteredFrom);
        DOSStakingInterface(addressBridge.getStakingAddress()).nodeStop(node);
        return (unregisteredFrom != 0);
    }

    function getWorkingGroupSize() public view returns (uint) {

        return workingGroupIds.length;
    }

    function getExpiredWorkingGroupSize() public view returns (uint) {

        return expiredWorkingGroupIds.length;
    }

    function registerNewNode() public fromValidStakingNode {

        if (pendingNodeList[msg.sender] != address(0)) {
            return;
        }
        if (nodeToGroupIdList[msg.sender][HEAD_I] != 0) {
            return;
        }
        nodeToGroupIdList[msg.sender][HEAD_I] = HEAD_I;
        insertToPendingNodeListTail(msg.sender);
        emit LogRegisteredNewPendingNode(msg.sender);
        DOSStakingInterface(addressBridge.getStakingAddress()).nodeStart(msg.sender);
        formGroup();
    }

    function formGroup() private returns(bool) {

        if (numPendingNodes < groupSize ||
            (workingGroupIds.length == 0 && numPendingNodes < bootstrapStartThreshold)) {
            if (expiredWorkingGroupIds.length > 0) {
                dissolveWorkingGroup(expiredWorkingGroupIds[0], true, HEAD_A);
                expiredWorkingGroupIds[0] = expiredWorkingGroupIds[expiredWorkingGroupIds.length - 1];
                expiredWorkingGroupIds.length--;
            }
        }

        if (numPendingNodes < groupSize) {
            emit LogInsufficientPendingNode(numPendingNodes);
            return false;
        }

        if (workingGroupIds.length > 0) {
            if (expiredWorkingGroupIds.length >= groupToPick) {
                if (lastFormGrpReqId == 0) {
                    lastFormGrpReqId = requestRandom(address(this), block.number);
                    if (lastFormGrpReqId == 0) return false;
                    emit LogGroupingInitiated(numPendingNodes, groupSize);
                    return true;
                } else {
                    emit LogMessage("already-in-formation");
                    return false;
                }
            } else {
                emit LogMessage("skipped-formation-not-enough-expired-wgrp");
            }
        } else if (numPendingNodes >= bootstrapStartThreshold) { // No working group alive and satisfies system re-bootstrap condition.
            if (bootstrapRound == 0) {
                bootstrapRound = CommitRevealInterface(addressBridge.getCommitRevealAddress()).startCommitReveal(
                    block.number,
                    bootstrapCommitDuration,
                    bootstrapRevealDuration,
                    bootstrapStartThreshold
                );
                bootstrapEndBlk = block.number + bootstrapCommitDuration + bootstrapRevealDuration;
                return true;
            } else {
                emit LogMessage("already-in-bootstrap");
            }
        }
        return false;
    }

    function __callback__(uint requestId, uint rndSeed) external {

        require(msg.sender == address(this), "unauthenticated-resp");
        require(expiredWorkingGroupIds.length >= groupToPick, "regroup-not-enough-expired-wgrp");
        require(numPendingNodes >= groupSize, "regroup-not-enough-p-node");

        lastFormGrpReqId = 0;
        uint arrSize = groupSize * (groupToPick + 1);
        address[] memory candidates = new address[](arrSize);
        for (uint i = 0; i < groupToPick; i++) {
            uint idx = uint(keccak256(abi.encodePacked(rndSeed, requestId, i))) % expiredWorkingGroupIds.length;
            Group storage grpToDissolve = workingGroups[expiredWorkingGroupIds[idx]];
            for (uint j = 0; j < groupSize; j++) {
                candidates[i * groupSize + j] = grpToDissolve.members[j];
            }
            dissolveWorkingGroup(grpToDissolve.groupId, false, HEAD_A);
            expiredWorkingGroupIds[idx] = expiredWorkingGroupIds[expiredWorkingGroupIds.length - 1];
            expiredWorkingGroupIds.length--;
        }

        pick(groupSize, groupSize * groupToPick, candidates);
        shuffle(candidates, rndSeed);
        regroup(candidates, groupToPick + 1);
    }

    function pick(uint num, uint startIndex, address[] memory candidates) private {

        for (uint i = 0; i < num; i++) {
            address curr = pendingNodeList[HEAD_A];
            pendingNodeList[HEAD_A] = pendingNodeList[curr];
            delete pendingNodeList[curr];
            candidates[startIndex + i] = curr;
        }
        numPendingNodes -= num;
        if (numPendingNodes == 0) {
            pendingNodeTail = HEAD_A;
        }
    }

    function shuffle(address[] memory arr, uint rndSeed) private pure {

        for (uint i = arr.length - 1; i > 0; i--) {
            uint j = uint(keccak256(abi.encodePacked(rndSeed, i, arr[i]))) % (i + 1);
            address tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
        }
    }

    function regroup(address[] memory candidates, uint num) private {

        require(candidates.length == groupSize * num, "candidate-length-mismatch");

        address[] memory members = new address[](groupSize);
        uint groupId;
        for (uint i = 0; i < num; i++) {
            groupId = 0;
            for (uint j = 0; j < groupSize; j++) {
                members[j] = candidates[i * groupSize + j];
                groupId = uint(keccak256(abi.encodePacked(groupId, members[j])));
            }
            groupId = uint(keccak256(abi.encodePacked(groupId, block.timestamp)));
            pendingGroups[groupId] = PendingGroup(groupId, block.number);
            mapping(address => address) storage memberList = pendingGroups[groupId].memberList;
            memberList[HEAD_A] = HEAD_A;
            for (uint j = 0; j < groupSize; j++) {
                memberList[members[j]] = memberList[HEAD_A];
                memberList[HEAD_A] = members[j];
            }
            insertToPendingGroupListTail(groupId);
            emit LogGrouping(groupId, members);
        }
    }

    function registerGroupPubKey(uint groupId, uint[4] calldata suggestedPubKey)
        external
        fromValidStakingNode
    {

        PendingGroup storage pgrp = pendingGroups[groupId];
        if (pgrp.groupId == 0) {
            emit LogNoPendingGroup(groupId);
            return;
        }

        require(pgrp.memberList[msg.sender] != address(0), "not-from-authorized-grp-member");

        bytes32 hashedPubKey = keccak256(abi.encodePacked(
            suggestedPubKey[0], suggestedPubKey[1], suggestedPubKey[2], suggestedPubKey[3]));
        pgrp.pubKeyCounts[hashedPubKey]++;
        emit LogPublicKeySuggested(groupId, pgrp.pubKeyCounts[hashedPubKey]);
        if (pgrp.pubKeyCounts[hashedPubKey] > groupSize / 2) {
            address[] memory memberArray = new address[](groupSize);
            uint idx = 0;
            address member = pgrp.memberList[HEAD_A];
            while (member != HEAD_A) {
                memberArray[idx++] = member;
                insertToListHead(nodeToGroupIdList[member], groupId);
                member = pgrp.memberList[member];
            }

            workingGroupIds.push(groupId);
            workingGroups[groupId] = Group(
                groupId,
                BN256.G2Point([suggestedPubKey[0], suggestedPubKey[1]], [suggestedPubKey[2], suggestedPubKey[3]]),
                numPendingGroups * lifeDiversity,
                block.number,
                memberArray
            );
            (uint prev, bool removed) = removeIdFromList(pendingGroupList, groupId);
            if (removed && pendingGroupTail == groupId) {
                pendingGroupTail = prev;
            }
            delete pendingGroups[groupId];
            numPendingGroups--;
            emit LogPendingGroupRemoved(groupId);
            emit LogPublicKeyAccepted(groupId, suggestedPubKey, workingGroupIds.length);
        }
    }
}