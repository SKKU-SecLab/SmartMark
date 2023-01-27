pragma solidity ^0.8.9;

contract Governance {


    enum Actions { Vote, Configure, SetOwnerAddress, TriggerOwnerWithdraw, ManageDeaths, StopPayouts, Bootstrap }

    struct Permissions {
        bool canVote;
        bool canConfigure;
        bool canSetOwnerAddress;
        bool canTriggerOwnerWithdraw;
        bool canManageDeaths;
        bool canStopPayouts;

        bool canBootstrap;
    }

    struct CallForVote {

        address subject;

        Permissions permissions;

        uint128 yeas;
        uint128 nays;
    }

    struct Vote {
        uint64 callForVoteIndex;
        bool yeaOrNay;
    }

    mapping(address => Permissions) private permissions;

    mapping(uint => CallForVote) private callsForVote;

    mapping(address => uint64) private lastRegisteredCallForVote;

    mapping(address => Vote) private votes;

    uint64 public resolvedCallsForVote;
    uint64 public totalCallsForVote;
    uint64 public totalVoters;

    event CallForVoteRegistered(
        uint64 indexed callForVoteIndex,
        address indexed caller,
        address indexed subject,
        bool canVote,
        bool canConfigure,
        bool canSetOwnerAddress,
        bool canTriggerOwnerWithdraw,
        bool canManageDeaths,
        bool canStopPayouts
    );

    event CallForVoteResolved(
        uint64 indexed callForVoteIndex,
        uint128 yeas,
        uint128 nays
    );

    event VoteCasted(
        uint64 indexed callForVoteIndex,
        address indexed voter,
        bool yeaOrNay,
        uint64 totalVoters,
        uint128 yeas,
        uint128 nays
    );

    constructor() {
        _setPermissions(msg.sender, Permissions({
            canVote: true,
            canConfigure: true,
            canSetOwnerAddress: true,
            canTriggerOwnerWithdraw: true,
            canManageDeaths: true,
            canStopPayouts: true,
            canBootstrap: true
        }));
    }

    function hasPermission(address subject, Actions action) public view returns (bool) {

        if (action == Actions.ManageDeaths) {
            return permissions[subject].canManageDeaths;
        }

        if (action == Actions.Vote) {
            return permissions[subject].canVote;
        }

        if (action == Actions.SetOwnerAddress) {
            return permissions[subject].canSetOwnerAddress;
        }

        if (action == Actions.TriggerOwnerWithdraw) {
            return permissions[subject].canTriggerOwnerWithdraw;
        }

        if (action == Actions.Configure) {
            return permissions[subject].canConfigure;
        }

        if (action == Actions.StopPayouts) {
            return permissions[subject].canStopPayouts;
        }

        if (action == Actions.Bootstrap) {
            return permissions[subject].canBootstrap;
        }

        return false;
    }

    function _setPermissions(address subject, Permissions memory _permissions) private {


        if (permissions[subject].canVote != _permissions.canVote) {
            if (_permissions.canVote) {
                totalVoters += 1;
            } else {
                totalVoters -= 1;

                delete votes[subject];
                delete lastRegisteredCallForVote[subject];
            }
        }

        permissions[subject] = _permissions;
    }

    function callForVote(
        address subject,
        bool canVote,
        bool canConfigure,
        bool canSetOwnerAddress,
        bool canTriggerOwnerWithdraw,
        bool canManageDeaths,
        bool canStopPayouts
    ) external {

        require(
            hasPermission(msg.sender, Actions.Vote),
            "Only addresses with vote permission can register a call for vote"
        );

        require(
            lastRegisteredCallForVote[msg.sender] <= resolvedCallsForVote,
            "Only one active call for vote per address is allowed"
        );

        totalCallsForVote++;

        lastRegisteredCallForVote[msg.sender] = totalCallsForVote;

        callsForVote[totalCallsForVote] = CallForVote({
            subject: subject,
            permissions: Permissions({
                canVote: canVote,
                canConfigure: canConfigure,
                canSetOwnerAddress: canSetOwnerAddress,
                canTriggerOwnerWithdraw: canTriggerOwnerWithdraw,
                canManageDeaths: canManageDeaths,
                canStopPayouts: canStopPayouts,
                canBootstrap: false
            }),
            yeas: 0,
            nays: 0
        });

        emit CallForVoteRegistered(
            totalCallsForVote,
            msg.sender,
            subject,
            canVote,
            canConfigure,
            canSetOwnerAddress,
            canTriggerOwnerWithdraw,
            canManageDeaths,
            canStopPayouts
        );
    }

    function vote(uint64 callForVoteIndex, bool yeaOrNay) external {

        require(hasUnresolvedCallForVote(), "No unresolved call for vote exists");
        require(
            callForVoteIndex == _getCurrenCallForVoteIndex(),
            "Call for vote does not exist or is not active"
        );
        require(
            hasPermission(msg.sender, Actions.Vote),
            "Sender address does not have vote permission"
        );

        uint128 yeas = callsForVote[callForVoteIndex].yeas;
        uint128 nays = callsForVote[callForVoteIndex].nays;

        if (votes[msg.sender].callForVoteIndex == callForVoteIndex) {
            if (votes[msg.sender].yeaOrNay) {
                yeas -= 1;
            } else {
                nays -= 1;
            }
        }

        if (yeaOrNay) {
            yeas += 1;
        } else {
            nays += 1;
        }

        emit VoteCasted(callForVoteIndex, msg.sender, yeaOrNay, totalVoters, yeas, nays);

        if (yeas == (totalVoters / 2 + 1) || nays == (totalVoters - totalVoters / 2)) {

            if (yeas > nays) {
                _setPermissions(
                    callsForVote[callForVoteIndex].subject,
                    callsForVote[callForVoteIndex].permissions
                );
            }

            resolvedCallsForVote += 1;

            delete callsForVote[callForVoteIndex];
            delete votes[msg.sender];

            emit CallForVoteResolved(callForVoteIndex, yeas, nays);

            return;
        }

        votes[msg.sender] = Vote({
            callForVoteIndex: callForVoteIndex,
            yeaOrNay: yeaOrNay
        });

        callsForVote[callForVoteIndex].yeas = yeas;
        callsForVote[callForVoteIndex].nays = nays;
    }

    function getCurrentCallForVote() public view returns (
        uint64 callForVoteIndex,
        uint128 yeas,
        uint128 nays
    ) {

        require(hasUnresolvedCallForVote(), "No unresolved call for vote exists");
        uint64 index = _getCurrenCallForVoteIndex();
        return (index, callsForVote[index].yeas, callsForVote[index].nays);
    }

    function hasUnresolvedCallForVote() public view returns (bool) {

        return totalCallsForVote > resolvedCallsForVote;
    }

    function _getCurrenCallForVoteIndex() private view returns (uint64) {

        return resolvedCallsForVote + 1;
    }
}