
pragma solidity 0.5.10;

contract CXTContract {


    function newArt(string calldata _id, string calldata _regReport) external returns (bool);

    function setArtIdt(string calldata _id, string calldata _idtReport) external returns (bool);

    function setArtEvt(string calldata _id, string calldata _evtReport) external returns (bool);

    function setArtEsc(string calldata _id, string calldata _escReport) external returns (bool);

    function issue(address _addr, uint256 _amount, uint256 _timestamp) external returns (bool);

    function release(address[] calldata _addressLst, uint256[] calldata _amountLst) external returns (bool);

    function bonus(uint256 _sum, address[] calldata _addressLst, uint256[] calldata _amountLst) external returns (bool);

}

contract CXTCManager {

    
    address public systemAcc;
    CXTContract public CXTCInstance;
    event UpdateSystemAcc(address indexed previousAcc, address indexed newAcc);

    modifier onlySys() {

        require(msg.sender == systemAcc, "CXTCManager: the caller must be systemAcc");
        _;
    }

    function updateSysAcc(address _newAcc) public onlySys {

        require(_newAcc != address(0), "CXTCManager: the new system account cannot be a zero address");
        emit UpdateSystemAcc(systemAcc, _newAcc);
        systemAcc = _newAcc;
    }

    constructor(address _systemAcc, address _cxtcAddr) public {
        systemAcc = _systemAcc;
        CXTCInstance = CXTContract(_cxtcAddr);
    }


    function newArt(string memory _id, string memory _regReport) public onlySys returns (bool) {

        return CXTCInstance.newArt(_id, _regReport);
    }
    
    function setArtIdt(string memory _id, string memory _idtReport) public onlySys returns (bool) {

        return CXTCInstance.setArtIdt(_id, _idtReport);
    }
    
    function setArtEvt(string memory _id, string memory _evtReport) public onlySys returns (bool) {

        return CXTCInstance.setArtEvt(_id, _evtReport);
    }
    
    function setArtEsc(string memory _id, string memory _escReport) public onlySys returns (bool) {

        return CXTCInstance.setArtEsc(_id, _escReport);
    }
    
    function issue(address _addr, uint256 _amount, uint256 _timestamp) public onlySys returns (bool) {

        return CXTCInstance.issue(_addr, _amount, _timestamp);
    }
        
    
    function release(address[] memory _addressLst, uint256[] memory _amountLst) public onlySys returns (bool) {

        return CXTCInstance.release(_addressLst, _amountLst);
    }
    
    function bonus(uint256 _sum, address[] memory _addressLst, uint256[] memory _amountLst) public onlySys returns (bool) {

        return CXTCInstance.bonus(_sum, _addressLst, _amountLst);
    }
}