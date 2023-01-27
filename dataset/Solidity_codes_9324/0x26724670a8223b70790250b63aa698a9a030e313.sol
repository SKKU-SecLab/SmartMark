
pragma solidity ^0.6.2;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }


    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




contract TrueCrt is Ownable {

    
    struct Cert {
        uint256 certId; 
        bytes32  certHash;
        uint64  certExpires; 
        uint64  issuedOn;
    }
    
    mapping (uint256 => Cert) certs;
   
    mapping (uint256 => bool) certIds;
 
    event NewCert(uint256 certId);
    event CertExists(uint256 certId);
    
    constructor() public {}
    
    function addCert(uint256 _certId, bytes32  _certHash, uint64 _certExpires, uint64 _issuedOn)  onlyOwner  public{ 

        if(!certIds[_certId]){
            certIds[_certId] = true;
            certs[_certId] = Cert(_certId,_certHash,_certExpires,_issuedOn);
            emit NewCert(_certId);
        }else{
            emit CertExists(_certId);
        }
    }
    
    function addManyCerts(uint256[] memory _certId, bytes32[] memory _certHash, uint64[] memory _certExpires, uint64[] memory _issuedOn)  onlyOwner  public{ 

        for (uint256 i = 0; i < _certId.length; i++) {
          addCert(_certId[i],_certHash[i],_certExpires[i],_issuedOn[i]);
        } 
    }
    
    function getCert(uint256 _certId) public view returns (bytes32,uint64,uint64) {

        require(certIds[_certId], "CertIds: _certId is not found");
        return (certs[_certId].certHash,certs[_certId].certExpires,certs[_certId].issuedOn);
    }
    
    function getCertHash(uint256 _certId) public view returns (bytes32) {

        require(certIds[_certId], "CertIds: _certId is not found");
        return certs[_certId].certHash;
    }
    
    function getCertCertExpires(uint256 _certId) public view returns (uint64) {

        require(certIds[_certId], "CertIds: _certId is not found");
        return certs[_certId].certExpires;
    }
    
    function getCertIssuedOn(uint256 _certId) public view returns (uint64) {

        require(certIds[_certId], "CertIds: _certId is not found");
        return certs[_certId].issuedOn;
    }    
}