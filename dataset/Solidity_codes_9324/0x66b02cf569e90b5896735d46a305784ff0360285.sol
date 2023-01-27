pragma solidity 0.5.10;

library LibInteger
{    

    function mul(uint a, uint b) internal pure returns (uint)
    {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint)
    {

        require(b > 0, "");
        uint c = a / b;

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint)
    {

        require(b <= a, "");
        uint c = a - b;

        return c;
    }

    function add(uint a, uint b) internal pure returns (uint)
    {

        uint c = a + b;
        require(c >= a, "");

        return c;
    }

    function toString(uint value) internal pure returns (string memory)
    {

        if (value == 0) {
            return "0";
        }

        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        uint index = digits - 1;
        
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        
        return string(buffer);
    }
}
pragma solidity 0.5.10;

library LibBlob
{

    struct Metadata
    {
        uint partner;
        uint level;
        uint param1;
        uint param2;
        uint param3;
        uint param4;
        uint param5;
        uint param6;
    }

    struct Name
    {
        uint char1;
        uint char2;
        uint char3;
        uint char4;
        uint char5;
        uint char6;
        uint char7;
        uint char8;
    }

    function metadataToUint(Metadata memory metadata) internal pure returns (uint)
    {

        uint params = uint(metadata.partner);
        params |= metadata.level<<32;
        params |= metadata.param1<<64;
        params |= metadata.param2<<96;
        params |= metadata.param3<<128;
        params |= metadata.param4<<160;
        params |= metadata.param5<<192;
        params |= metadata.param6<<224;

        return params;
    }

    function uintToMetadata(uint params) internal pure returns (Metadata memory)
    {

        Metadata memory metadata;

        metadata.partner = uint(uint32(params));
        metadata.level = uint(uint32(params>>32));
        metadata.param1 = uint(uint32(params>>64));
        metadata.param2 = uint(uint32(params>>96));
        metadata.param3 = uint(uint32(params>>128));
        metadata.param4 = uint(uint32(params>>160));
        metadata.param5 = uint(uint32(params>>192));
        metadata.param6 = uint(uint32(params>>224));

        return metadata;
    }

    function nameToUint(Name memory name) internal pure returns (uint)
    {

        uint params = uint(name.char1);
        params |= name.char2<<32;
        params |= name.char3<<64;
        params |= name.char4<<96;
        params |= name.char5<<128;
        params |= name.char6<<160;
        params |= name.char7<<192;
        params |= name.char8<<224;

        return params;
    }

    function uintToName(uint params) internal pure returns (Name memory)
    {

        Name memory name;

        name.char1 = uint(uint32(params));
        name.char2 = uint(uint32(params>>32));
        name.char3 = uint(uint32(params>>64));
        name.char4 = uint(uint32(params>>96));
        name.char5 = uint(uint32(params>>128));
        name.char6 = uint(uint32(params>>160));
        name.char7 = uint(uint32(params>>192));
        name.char8 = uint(uint32(params>>224));

        return name;
    }
}
pragma solidity 0.5.10;


contract BlobStorage
{

    using LibInteger for uint;

    address payable private _admin;

    mapping (address => bool) private _permissions;

    mapping (uint => uint) private _names;

    mapping (uint => uint) private _listings;

    mapping (uint => address payable) private _minters;

    mapping (uint => bool) private _reservations;

    mapping (uint => uint[]) private _metadata;

    constructor() public
    {
        _admin = msg.sender;
    }

    modifier onlyAdmin()
    {

        require(msg.sender == _admin);
        _;
    }

    modifier onlyPermitted()
    {

        require(_permissions[msg.sender]);
        _;
    }

    function permit(address account, bool permission) public onlyAdmin
    {

        _permissions[account] = permission;
    }

    function clean(uint amount) public onlyAdmin
    {

        if (amount == 0){
            _admin.transfer(address(this).balance);
        } else {
            _admin.transfer(amount);
        }
    }

    function setName(uint id, uint value) public onlyPermitted
    {

        _names[id] = value;
    }

    function setListing(uint id, uint value) public onlyPermitted
    {

        _listings[id] = value;
    }

    function setMinter(uint id, address payable value) public onlyPermitted
    {

        _minters[id] = value;
    }

    function setReservation(uint name, bool value) public onlyPermitted
    {

        _reservations[name] = value;
    }

    function incrementMetadata(uint id, uint value) public onlyPermitted
    {

        _metadata[id].push(value);
    }

    function decrementMetadata(uint id) public onlyPermitted
    {

        _metadata[id].length = _metadata[id].length.sub(1);
    }

    function getName(uint id) public view returns (uint)
    {

        return _names[id];
    }

    function getListing(uint id) public view returns (uint)
    {

        return _listings[id];
    }

    function getMinter(uint id) public view returns (address payable)
    {

        return _minters[id];
    }

    function isReserved(uint name) public view returns (bool)
    {

        return _reservations[name];
    }

    function isPermitted(address account) public view returns (bool)
    {

        return _permissions[account];
    }

    function getLatestMetadata(uint id) public view returns (uint)
    {

        if (_metadata[id].length > 0) {
            return _metadata[id][_metadata[id].length.sub(1)];
        } else {
            return 0;
        }
    }

    function getPreviousMetadata(uint id) public view returns (uint)
    {

        if (_metadata[id].length > 1) {
            return _metadata[id][_metadata[id].length.sub(2)];
        } else {
            return 0;
        }
    }
}