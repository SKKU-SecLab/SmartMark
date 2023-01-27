







pragma solidity ^0.4.25;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract LikeChainRelayLogicInterface {

    function commitWithdrawHash(uint64 height, uint64 round, bytes _payload) public;

    function updateValidator(address[] _newValidators, bytes _proof) public;

    function withdraw(bytes _withdrawInfo, bytes _proof) public;

    function upgradeLogicContract(address _newLogicContract, bytes _proof) public;

    event Upgraded(uint256 _newLogicContractIndex, address _newLogicContract);
}

contract LikeChainRelayState {

    uint256 public logicContractIndex;
    address public logicContract;

    IERC20 public tokenContract;

    address[] public validators;
    
    struct ValidatorInfo {
        uint8 index;
        uint32 power;
    }
    
    mapping(address => ValidatorInfo) public validatorInfo;
    uint256 public totalVotingPower;
    uint public lastValidatorUpdateTime;

    uint public latestBlockHeight;
    bytes32 public latestWithdrawHash;

    mapping(bytes32 => bool) public consumedIds;
    mapping(bytes32 => bytes32) public reserved;
}

contract LikeChainRelayLogic is LikeChainRelayState, LikeChainRelayLogicInterface {

    constructor(address[] _validators, uint32[] _votingPowers, address _tokenContract) public {
        uint len = _validators.length;
        require(len > 0);
        require(len < 256);
        require(_votingPowers.length == len);

        for (uint8 i = 0; i < len; i += 1) {
            address v = _validators[i];
            require(validatorInfo[v].power == 0);
            uint32 power = _votingPowers[i];
            require(power > 0);
            validators.push(v);
            validatorInfo[v] = ValidatorInfo({
                index: i,
                power: power
            });
            totalVotingPower += power;
        }
        
        tokenContract = IERC20(_tokenContract);
    }
    
    function _proofRootHash(bytes32 _key, bytes32 _value, bytes _proof) internal view returns (bytes32 rootHash) {

        assembly {
            let start := mload(0x40)
            let p := start
            let curHashStart := add(start, 128)
            let data := add(_proof, 33) // 32 byte length + 1 byte reserved
            
            let len := and(mload(sub(data, 31)), 0xff) // version length
            if gt(len, 9) { revert(0, 0) } // version is uint64, so the varint encoded should never longer than 9 bytes
            data := add(data, 1)
            mstore(p, hex"0002")
            p := add(p, 2)
            mstore(p, mload(data))
            data := add(data, len)
            p := add(p, len)
            mstore8(p, 32) // amino length-prefixed encoding for []byte (length 32)
            p := add(p, 1)
            mstore(p, _key)
            p := add(p, 32)
            mstore8(p, 32) // amino length-prefixed encoding for []byte (length 32)
            p := add(p, 1)
            mstore(p, _value)
            p := add(p, 32)
            let _ := staticcall(gas, 2, start, sub(p, start), curHashStart, 32)
            
            len := and(mload(sub(data, 31)), 0xff) // number of path nodes
            data := add(data, 1)
            for { let i := len } gt(i, 0) { i := sub(i, 1) } {
                p := start
                len := and(mload(sub(data, 31)), 0xff) // 1 bit left-right indicator, 7 bits length
                let order := and(len, 0x80)
                len := and(len, 0x7f)
                if gt(len, 19) { revert(0, 0) } // 1-byte height (< 128) + 9-byte 64-bit varint-encoded numbers * 2
                data := add(data, 1)
                mstore(p, mload(data))
                p := add(p, len)
                data := add(data, len)
                switch order
                case 0 {
                    mstore8(p, 32) // amino length-prefixed encoding for []byte
                    p := add(p, 1)
                    mstore(p, mload(curHashStart))
                    p := add(p, 32)
                    mstore8(p, 32) // amino length-prefixed encoding for []byte
                    p := add(p, 1)
                    mstore(p, mload(data))
                    p := add(p, 32)
                } default {
                    mstore8(p, 32) // amino length-prefixed encoding for []byte
                    p := add(p, 1)
                    mstore(p, mload(data))
                    p := add(p, 32)
                    mstore8(p, 32) // amino length-prefixed encoding for []byte
                    p := add(p, 1)
                    mstore(p, mload(curHashStart))
                    p := add(p, 32)
                }
                data := add(data, 32)
                _ := staticcall(gas, 2, start, sub(p, start), curHashStart, 32)
            }
            len := mload(_proof)
            if gt(sub(data, add(_proof, 32)), len) {
                revert(0, 0)
            }
            rootHash := mload(curHashStart)
        }
        return rootHash;
    }
    
    function commitWithdrawHash(uint64 height, uint64 round, bytes _payload) public {
        assembly {
            function getNByte(p, n) -> bs {
                if gt(n, 32) {
                    revert(0, 0)
                }
                let numberOfOnes := mul(n, 8)
                let numberOfZeros := sub(256, numberOfOnes)
                let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                mask := xor(mask, sub(exp(2, numberOfZeros), 1))
                bs := and(mload(p), mask)
            }
            
            function getOneByte(p) -> b {
                b := byte(0, mload(p))
            }
            
            function reconstructPrefix(p, height, round) -> next {
                mstore8(p, 0x00) // place-holder for length prefix
                p := add(p, 1)
                mstore8(p, 0x08) // field number for `type`
                p := add(p, 1)
                mstore8(p, 0x02) // value for `precommit` type
                p := add(p, 1)
                if gt(height, 0) {
                    mstore8(p, 0x11) // field number for `height`
                    p := add(p, 1)
                    for { let i := 0 } lt(i, 8) { i := add(i, 1) } {
                        mstore8(p, mod(height, 0x100))
                        height := div(height, 0x100)
                        p := add(p, 1)
                    }
                }
                if gt(round, 0) {
                    mstore8(p, 0x19) // field number for `round`
                    p := add(p, 1)
                    for { let i := 0 } lt(i, 8) { i := add(i, 1) } {
                        mstore8(p, mod(round, 0x100))
                        height := div(round, 0x100)
                        p := add(p, 1)
                    }
                }
                next := p
            }
            
            function extractBlockHash(suffix) -> blockHash {
                blockHash := mload(add(suffix, 4))
            }
            
            function memcpy(dst, src, len) {
                let dstEnd := add(dst, len)
                for { } lt(dst, dstEnd) { dst := add(dst, 32) src := add(src, 32) } {
                    mstore(dst, mload(src))
                }
            }
            
            function reconstructSignBytes(p, timeStart, time, timeLen, suffixSrc, suffixLen) -> end {
                let start := p
                mstore(timeStart, time)
                p := add(timeStart, timeLen)
                memcpy(p, suffixSrc, suffixLen)
                end := add(p, suffixLen)
                let len := sub(end, add(start, 1))
                mstore8(start, len)
            }
            
            function getVoter(p, timeStart, suffixSrc, suffixLen) -> voter, next {
                let msgStart := mload(0x40)
                let timeLen := getOneByte(p)
                if gt(timeLen, 15) { revert(0, 0) }
                p := add(p, 1)
                let time := getNByte(p, timeLen)
                p := add(p, timeLen)
                let msgEnd := reconstructSignBytes(msgStart, timeStart, time, timeLen, suffixSrc, suffixLen)
                

                let buf := add(msgStart, 128)
                let _ := staticcall(gas, 2, msgStart, sub(msgEnd, msgStart), buf, 32) // SHA-256 hash, at buf[0:32]
                mstore(add(buf, 32), getOneByte(p)) // v at buf[32:64]
                p := add(p, 1)
                mstore(add(buf, 64), mload(p)) // r at buf[64:96]
                p := add(p, 32)
                mstore(add(buf, 96), mload(p)) // s at buf[96:128]
                p := add(p, 32)
                let succ := staticcall(gas, 1, buf, 128, buf, 32)
                if iszero(succ) {
                    revert(0, 0)
                }
                voter := mload(buf)
                next := p
            }
            
            function getVoterInfo(addr) -> index, power {
                let buf := add(mload(0x40), 128)
                mstore(buf, addr)
                mstore(add(buf, 32), validatorInfo_slot)
                let slot := keccak256(buf, 64)
                let votingInfo := sload(slot)
                if eq(votingInfo, 0) {
                    revert(0, 0)
                }
                index := and(votingInfo, 0xFF)
                power := and(div(votingInfo, 0x100), 0xFFFFFFFF)
            }
            
            function accumulateVoterPower(voter, votedSet, power) -> newVotedSet, newPower {
                let voterIndex, voterPower := getVoterInfo(voter)
                let mask := exp(2, voterIndex)
                if iszero(eq(0, and(votedSet, mask))) {
                    revert(0, 0)
                }
                newVotedSet := or(votedSet, mask)
                newPower := add(power, voterPower)
            }
            
            function checkVotes(p, height, round) -> blockHash, next {
                let votedSet := 0
                let voterPower := 0
                
                let suffixLen := getOneByte(p)
                if gt(suffixLen, 92) { revert(0, 0) }
                p := add(p, 1)
                let suffixSrc := p
                p := add(p, suffixLen)
                blockHash := extractBlockHash(suffixSrc)
                
                let msgStart := mload(0x40)
                let timeStart := reconstructPrefix(msgStart, height, round)
                
                let votesCount := getOneByte(p)
                p := add(p, 1)
                for {} gt(votesCount, 0) { votesCount := sub(votesCount, 1) } {
                    let voter
                    voter, p := getVoter(p, timeStart, suffixSrc, suffixLen)
                    votedSet, voterPower := accumulateVoterPower(voter, votedSet, voterPower)
                }
                if iszero(gt(mul(voterPower, 3), mul(sload(totalVotingPower_slot), 2))) {
                    revert(0, 0)
                }
                next := p
            }
            
            function extractAndProofWithdrawHash(p, blockHash) -> withdrawHash {
                let buf := mload(0x40)
                let aminoEncodedAppHashLen := add(getOneByte(p), 1)
                memcpy(buf, p, aminoEncodedAppHashLen)
                withdrawHash := mload(add(p, 1))
                p := add(p, aminoEncodedAppHashLen)
                
                let left := add(buf, 1)
                let right := add(buf, 34)
                let _ := staticcall(gas, 2, buf, aminoEncodedAppHashLen, left, 32)
                mstore8(sub(left, 1), 32)
                mstore8(sub(right, 1), 32)
                mstore(right, mload(p))
                p := add(p, 32)
                _ := staticcall(gas, 2, buf, 66, left, 32)
                mstore(right, mload(p))
                p := add(p, 32)
                _ := staticcall(gas, 2, buf, 66, right, 32)
                mstore(left, mload(p))
                p := add(p, 32)
                _ := staticcall(gas, 2, buf, 66, right, 32)
                mstore(left, mload(p))
                p := add(p, 32)
                _ := staticcall(gas, 2, buf, 66, buf, 32)
                if iszero(eq(blockHash, mload(buf))) {
                    revert(0, 0)
                }
            }
            
            if iszero(gt(height, sload(latestBlockHeight_slot))) {
                revert(0, 0)
            }
            let blockHash
            let p := add(_payload, 32)
            blockHash, p := checkVotes(p, height, round)
            let withdrawHash := extractAndProofWithdrawHash(p, blockHash)
            sstore(latestBlockHeight_slot, height)
            sstore(latestWithdrawHash_slot, withdrawHash)
        }
    }

    
    function _proofAndExtractWithdraw(bytes _withdrawInfo, bytes _proof) internal returns (address to, uint256 value, uint256 fee) {
        bytes32 id = sha256(_withdrawInfo);
        require(!consumedIds[id]);
        consumedIds[id] = true;
        bytes32 proofValueHash = hex"4bf5122f344554c53bde2ebb8cd2b7e3d1600ad631c385a5d7cce23c7785459a"; // sha256 of hex"01"
        bytes32 rootHash = _proofRootHash(id, proofValueHash, _proof);
        require(rootHash == latestWithdrawHash);
        assembly {
            to := mload(add(_withdrawInfo, 40))
            value := mload(add(_withdrawInfo, 72))
            fee := mload(add(_withdrawInfo, 104))
        }
        return (to, value, fee);
    }

    function withdraw(bytes _withdrawInfo, bytes _proof) public {
        address to;
        uint256 value;
        uint256 fee;
        (to, value, fee) = _proofAndExtractWithdraw(_withdrawInfo, _proof);
        tokenContract.transfer(msg.sender, fee);
        tokenContract.transfer(to, value);
    }

    function updateValidator(address[] _newValidators, bytes _proof) public {
    }
    
    function upgradeLogicContract(address _newLogicContract, bytes _proof) public {
        logicContractIndex += 1;
        bytes12 keyBeforeHash = bytes12(uint96(bytes12("exec")) | uint96(logicContractIndex));
        bytes32 key = sha256(abi.encodePacked(keyBeforeHash));
        bytes32 proofValueHash = sha256(abi.encodePacked(_newLogicContract));
        bytes32 rootHash = _proofRootHash(key, proofValueHash, _proof);
        require(rootHash == latestWithdrawHash);
        logicContract = _newLogicContract;
        emit Upgraded(logicContractIndex, _newLogicContract);
    }
}