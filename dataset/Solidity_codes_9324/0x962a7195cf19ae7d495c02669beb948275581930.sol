


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


pragma solidity ^0.6.10;


contract Auditable {

    using Address for address;

    address public auditor;
    address public auditedContract;

    bool public audited;

    modifier isAudited() {

        require(audited == true, "Not audited");
        _;
    }

    event ApprovedAudit(address _auditor, address _contract, string _message);
    event OpposedAudit(address _auditor, address _contract, string _message);

    constructor(address _auditor, address _auditedContract) public {
        auditor = _auditor;
        auditedContract = _auditedContract;
    }

    function setAuditor(address _auditor) public {

        require(msg.sender == auditor, "Only the auditor ???");
        require(audited == false, "Cannot change auditor post audit");
        auditor = _auditor;
    }

    function approveAudit() public {

        require(msg.sender == auditor, "Auditor only");

        audited = true;

        emit ApprovedAudit(auditor, auditedContract, "Contract approved, functionality unlocked");
    }

    function opposeAudit() public {

        require(msg.sender == auditor, "Auditor only");
        require(audited != true, "Cannot destroy an approved contract");
        
        audited = false;

        emit OpposedAudit(auditor, auditedContract, "Contract has failed the audit");
    }
}


pragma solidity ^0.6.10;

contract Ownable {


    address payable public owner;

    event TransferredOwnership(address _previous, address _next, uint256 _time);

    modifier onlyOwner() {

        require(msg.sender == owner, "Owner only");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address payable _owner) public onlyOwner() {

        address previousOwner = owner;
        owner = _owner;
        emit TransferredOwnership(previousOwner, owner, now);
    }
}


pragma solidity ^0.6.10;



contract Donations is Ownable, Auditable {


    address public NFT;

    event ChangedNFT(address _previous, address _next, uint256 _time);

    constructor(address _auditor, address _NFT) Ownable() Auditable(_auditor, address(this)) public {
        address previousNFT = NFT;
        NFT = _NFT;
        emit ChangedNFT(previousNFT, NFT, now);
    }

    function donate() public payable isAudited() {

        if(msg.value >= 100000000000000000) 
        {
            NFT.call(abi.encodeWithSignature("mint(address)", msg.sender));
        }

        owner.transfer(msg.value);
    }

    function setNFT(address _NFT) public onlyOwner() isAudited() {


        address previousNFT = NFT;
        NFT = _NFT;
        emit ChangedNFT(previousNFT, NFT, now);
    }

    function destroyContract() public onlyOwner() {

        require(audited == false, "Cannot destroy an audited contract");
        selfdestruct(owner);
    }

}