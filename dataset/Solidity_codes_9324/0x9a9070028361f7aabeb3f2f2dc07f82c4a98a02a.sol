
pragma solidity ^0.5.10;

contract CheckpointOracle {


    event NewCheckpointVote(uint64 indexed index, bytes32 checkpointHash, uint8 v, bytes32 r, bytes32 s);

    constructor(address[] memory _adminlist, uint _sectionSize, uint _processConfirms, uint _threshold) public {
        for (uint i = 0; i < _adminlist.length; i++) {
            admins[_adminlist[i]] = true;
            adminList.push(_adminlist[i]);
        }
        sectionSize = _sectionSize;
        processConfirms = _processConfirms;
        threshold = _threshold;
    }

    function GetLatestCheckpoint()
    view
    public
    returns(uint64, bytes32, uint) {

        return (sectionIndex, hash, height);
    }

    function SetCheckpoint(
        uint _recentNumber,
        bytes32 _recentHash,
        bytes32 _hash,
        uint64 _sectionIndex,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s)
        public
        returns (bool)
    {

        require(admins[msg.sender]);

        require(blockhash(_recentNumber) == _recentHash);

        require(v.length == r.length);
        require(v.length == s.length);

        if (block.number < (_sectionIndex+1)*sectionSize+processConfirms) {
            return false;
        }
        if (_sectionIndex < sectionIndex) {
            return false;
        }
        if (_sectionIndex == sectionIndex && (_sectionIndex != 0 || height != 0)) {
            return false;
        }
        if (_hash == ""){
            return false;
        }

        bytes32 signedHash = keccak256(abi.encodePacked(byte(0x19), byte(0), this, _sectionIndex, _hash));

        address lastVoter = address(0);

        for (uint idx = 0; idx < v.length; idx++){
            address signer = ecrecover(signedHash, v[idx], r[idx], s[idx]);
            require(admins[signer]);
            require(uint256(signer) > uint256(lastVoter));
            lastVoter = signer;
            emit NewCheckpointVote(_sectionIndex, _hash, v[idx], r[idx], s[idx]);

            if (idx+1 >= threshold){
                hash = _hash;
                height = block.number;
                sectionIndex = _sectionIndex;
                return true;
            }
        }
        revert();
    }

    function GetAllAdmin()
    public
    view
    returns(address[] memory)
    {

        address[] memory ret = new address[](adminList.length);
        for (uint i = 0; i < adminList.length; i++) {
            ret[i] = adminList[i];
        }
        return ret;
    }

    mapping(address => bool) admins;

    address[] adminList;

    uint64 sectionIndex;

    uint height;

    bytes32 hash;

    uint sectionSize;

    uint processConfirms;

    uint threshold;
}