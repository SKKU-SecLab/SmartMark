
pragma solidity ^0.8.12;



interface IOwnershipInstructorRegisterV1 {

    struct Instructor{
        address _impl;
        string _name;
    }
  

    event NewInstructor(address indexed _instructor,string _name);
    event RemovedInstructor(address indexed _instructor,string _name);
    event UnlinkedImplementation(string indexed _name,address indexed _implementation);
    event LinkedImplementation(string indexed _name,address indexed _implementation);



    function name() external view returns (string memory);


    function getInstructorByName (string memory _name) external view returns(Instructor memory);

    function getImplementationsOf(string memory _name,uint256 page)
        external
        view
        returns (address[] memory _addresses,uint256 _nextpage);



    function getListOfInstructorNames(uint256 page)
        external
        view
        returns (string[] memory _names,uint256 _nextpage);


    function addInstructor(address _instructor,string memory _name) external;

    function addInstructorAndImplementation(address _instructor,string memory _name, address _implementation) external;


    function linkImplementationToInstructor(address _implementation,string memory _name) external;

    function unlinkImplementationToInstructor(address _impl) external;


    function removeInstructor(string memory _name) external;


    function instructorGivenImplementation(address _impl)external view returns (Instructor memory _instructor);

}



interface IOwnershipInstructor{


  function isValidInterface (address _impl) external view returns (bool);

    function ownerOfTokenOnImplementation(address _impl,uint256 _tokenId,address _potentialOwner) external view  returns (address);

}




interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




contract OwnershipInstructorRegisterV1 is Ownable,IOwnershipInstructorRegisterV1 {

    bytes4 public immutable INSTRUCTOR_ID = type(IOwnershipInstructor).interfaceId;
    using ERC165Checker for address;
    string internal __name;

    Instructor[] public instructorRegister;
    mapping(bytes32 => uint256) internal nameToinstructorIndex;

    mapping(address => string) public implementationToInstructorName;

    mapping(bytes32=>address[]) internal instructorNameToImplementationList;

    mapping(address => uint256) internal implementationIndex;

    mapping(bytes32=>bool) internal registeredHash;    
    mapping(bytes32=>bool) internal registeredName;


    constructor(){
        __name="OwnershipInstructorRegisterV1";
    }

    function hashInstructor(address _instructor) internal view returns (bytes32 _hash){

        return keccak256(_instructor.code);
    }

    function hashName(string memory _name) internal pure returns (bytes32 _hash){

        return keccak256(abi.encode(_name));
    }

    function name() public view returns (string memory){

        return __name;
    }

    function getInstructorByName (string memory _name) public view returns(Instructor memory){
        bytes32 _hash =hashName(_name);
        require(registeredName[_hash],"Name does not exist");
        return instructorRegister[nameToinstructorIndex[_hash]];
    }
    uint256 private constant _maxItemsPerPage = 150;
    function getImplementationsOf(string memory _name,uint256 page)
        public
        view
        returns (address[] memory _addresses,uint256 _nextpage)
    {

        bytes32 _nameHash =hashName(_name);
        require(registeredName[_nameHash],"Name does not exist");
        uint256 size = instructorNameToImplementationList[_nameHash].length;
        uint256 offset = page*_maxItemsPerPage;
        uint256 resultSize;
        if(size>= _maxItemsPerPage+offset){
            resultSize = _maxItemsPerPage;
        }else if (size< _maxItemsPerPage+offset){
            resultSize = size - offset;
        }
        address[] memory addresses = new address[](resultSize);
        uint256 index = 0;
        for (uint256 i = offset; i < resultSize+offset; i++) {
            addresses[index] = instructorNameToImplementationList[_nameHash][i];
            index++;
        }
        if(size<=(addresses.length+offset)){
            return (addresses,0);
        }else{
            return (addresses,page+1);
        }
        
    }

    function getListOfInstructorNames(uint256 page)
        public
        view
        returns (string[] memory _names,uint256 _nextpage)
    {


        uint256 size = instructorRegister.length;
        uint256 offset = page*_maxItemsPerPage;
        uint256 resultSize;
        if(size>= _maxItemsPerPage+offset){
            resultSize = _maxItemsPerPage;
        }else if (size< _maxItemsPerPage+offset){
            resultSize = size - offset;
        }
        string[] memory names = new string[](resultSize);
        uint256 index = 0;
        for (uint256 i = offset; i < resultSize+offset; i++) {
            names[index] = instructorRegister[i]._name;
            index++;
        }
        if(size<=(names.length+offset)){
            return (names,0);
        }else{
            return (names,page+1);
        }
        
    }

    function _safeAddInstructor(address _instructor,string memory _name) private {

        bytes32 _hash = hashInstructor(_instructor);
        bytes32 _nameHash = hashName(_name);
        require(!registeredHash[_hash],"Instructor has already been registered");
        require(!registeredName[_nameHash],"Instructor Name already taken");

        Instructor memory _inst = Instructor(_instructor,_name);

        instructorRegister.push(_inst);
        nameToinstructorIndex[_nameHash]=instructorRegister.length-1;

        registeredHash[_hash]=true;
        registeredName[_nameHash]=true;
    }

    function addInstructor(address _instructor,string memory _name) public onlyOwner {

        require(_instructor !=address(0),"Instructor address cannot be address zero");
        require(bytes(_name).length>4,"Name is too short");
        require(_instructor.supportsInterface(INSTRUCTOR_ID),"Contract does not support instructor interface");

        _safeAddInstructor( _instructor, _name);

        emit NewInstructor(_instructor, _name);
    }

    function addInstructorAndImplementation(address _instructor,string memory _name, address _implementation) public onlyOwner {

        addInstructor(_instructor,_name);
        
        linkImplementationToInstructor( _implementation, _name);
    }

    function linkImplementationToInstructor(address _implementation,string memory _name) public onlyOwner {

        require(bytes(implementationToInstructorName[_implementation]).length==0,"Implementation already linked to an instructor");
        bytes32 _hash =hashName(_name);
        require(registeredName[_hash],"Name does not exist");

        implementationToInstructorName[_implementation]=_name;
        instructorNameToImplementationList[_hash].push(_implementation);
        implementationIndex[_implementation] = instructorNameToImplementationList[hashName(_name)].length-1;
        emit LinkedImplementation(implementationToInstructorName[_implementation], _implementation);
        
    }

    function unlinkImplementationToInstructor(address _impl) public onlyOwner {

        require(bytes(implementationToInstructorName[_impl]).length!=0,"Implementation already not linked to any instructor.");
        bytes32 _hashName = hashName(implementationToInstructorName[_impl]);

        uint256 indexOfImplementation = implementationIndex[_impl];
        address lastImplementation = instructorNameToImplementationList[_hashName][instructorNameToImplementationList[_hashName].length-1];
        emit UnlinkedImplementation(implementationToInstructorName[_impl], _impl);

        implementationToInstructorName[_impl]="";
        instructorNameToImplementationList[_hashName][indexOfImplementation]=lastImplementation;
        instructorNameToImplementationList[_hashName].pop();
        
        implementationIndex[lastImplementation] = indexOfImplementation;
    }

    function _safeRemoveInstructor(bytes32 _nameHash) private {


        uint256 index = nameToinstructorIndex[_nameHash];
        Instructor memory current = instructorRegister[index];
        Instructor memory lastInstructor = instructorRegister[instructorRegister.length-1];

        bytes32 _byteCodeHash = hashInstructor(current._impl);

        registeredHash[_byteCodeHash]=false;
        registeredName[_nameHash]=false;

        instructorRegister[index] = lastInstructor;
        instructorRegister.pop();
        nameToinstructorIndex[_nameHash]=0;
    }

    function removeInstructor(string memory _name) public onlyOwner {

        bytes32 _hash =hashName(_name);
        Instructor memory _instructor = getInstructorByName(_name);
        require(registeredName[_hash],"Name does not exist");
        require(_instructor._impl!=address(0),"Instructor does not exist");

        uint256 size = instructorNameToImplementationList[_hash].length;
        for (uint256 i=0; i < size; i++) {  //for loop example
            unlinkImplementationToInstructor(instructorNameToImplementationList[_hash][i]);
        }

        _safeRemoveInstructor(_hash);
        emit RemovedInstructor(_instructor._impl, _name);
    }

    function instructorGivenImplementation(address _impl)public view returns (Instructor memory _instructor) {


        string memory _name = implementationToInstructorName[_impl];
        if(bytes(_name).length > 0){
            return getInstructorByName(_name);
        }
        uint256 size = instructorRegister.length;
        for(uint256 i; i<size;i++ ){
            if(IOwnershipInstructor(instructorRegister[i]._impl).isValidInterface(_impl)){
                _instructor =instructorRegister[i];
                break;
            }
        }
        return _instructor;
    }

}