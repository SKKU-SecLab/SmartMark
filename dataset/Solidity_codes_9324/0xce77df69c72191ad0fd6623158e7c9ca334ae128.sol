
pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library StringsUpgradeable {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}pragma experimental ABIEncoderV2;
pragma solidity 0.6.0;


contract Files is OwnableUpgradeable {




    struct FileOutput {
		string separator;
		string title;
		string media_type;
		string album_series;
		string copyright;
		string website;
		string ipfs_hash;
		string comment;
		string blockchain_date;
		string sha_hash;
    }

    uint256 private size;


    mapping(uint256 => string) filesIpfsHashIndex;
    mapping(string => uint256[]) filesByIpfsHash;

	mapping(uint256 => string) filesShaHashIndex;
    mapping(string => uint256[]) filesByShaHash;

  
	mapping(uint256 => string) filesTitleIndex;
	mapping(uint256 => string) filesMediaTypeIndex;
    mapping(uint256 => string) filesAlbumSeriesIndex;
	mapping(uint256 => string) filesCopyrightIndex;
	mapping(uint256 => string) filesWebsiteIndex;
	mapping(uint256 => string) filesCommentIndex;
	mapping(uint256 => uint256) filesBlockchainDateIndex;
    
    function initialize() initializer public {

        __Ownable_init();
    }

    function addFile(string[] memory metadata) public onlyOwner returns (uint256) {


        require( metadata.length == 8);


        string memory _title = metadata[0];
	    string memory _media_type = metadata[1];
        string memory _album_series = metadata[2];
		string memory _copyright = metadata[3];
        string memory _website = metadata[4];
	    string memory _ipfs_hash = metadata[5];
        string memory _comment = metadata[6];
		string memory _sha_hash = metadata[7];
 

        filesTitleIndex[size] = _title;
        filesMediaTypeIndex[size] = _media_type;
        filesAlbumSeriesIndex[size] = _album_series;
        filesCopyrightIndex[size] = _copyright;
        filesWebsiteIndex[size] = _website;
        filesIpfsHashIndex[size] = _ipfs_hash;
        filesCommentIndex[size] = _comment;
        filesBlockchainDateIndex[size] = block.timestamp;
		filesShaHashIndex[size] = _sha_hash;


        filesByIpfsHash[_ipfs_hash].push(size);
        filesByShaHash[_sha_hash].push(size);

        size = size + 1;
        return size;
    }

    function findFilesByIpfsHash(string calldata ipfs_hash) view external returns (FileOutput[] memory) {

        return findFilesByKey(1, ipfs_hash);
    }

    function findFilesByShaHash(string calldata sha_hash) view external returns (FileOutput[] memory) {

        return findFilesByKey(2, sha_hash);
    }

    function findFilesByKey(int key, string memory hash) view internal returns (FileOutput[] memory) {

        uint256 len;

        if(key == 1){
            len = filesByIpfsHash[hash].length;
        } else {
            len = filesByShaHash[hash].length;
        }

        string[] memory _title = new string[](len);
        string[] memory _media_type = new string[](len);
        string[] memory _album_series = new string[](len);
        string[] memory _copyright = new string[](len);
        string[] memory _website = new string[](len);
        string[] memory _ipfs_hash = new string[](len);
        string[] memory _comment = new string[](len);
        string[] memory _blockchain_date = new string[](len);		
		string[] memory _sha_hash = new string[](len);	

        for (uint256 index = 0; index < len; index++){
            uint256 id;
            if(key == 1){
                id = filesByIpfsHash[hash][index];
            } else {
                id = filesByShaHash[hash][index];
            }

			(uint year, uint month, uint day) = timestampToDate(filesBlockchainDateIndex[id]);

            _title[index] = filesTitleIndex[id];
            _media_type[index] = filesMediaTypeIndex[id];
            _album_series[index] = filesAlbumSeriesIndex[id];
            _copyright[index] = filesCopyrightIndex[id];
            _website[index] = filesWebsiteIndex[id];
            _ipfs_hash[index] = filesIpfsHashIndex[id];
            _comment[index] = filesCommentIndex[id];
			_blockchain_date[index] = concat( StringsUpgradeable.toString(day),  "-",  StringsUpgradeable.toString(month), "-", StringsUpgradeable.toString(year) );
			_sha_hash[index] = filesShaHashIndex[id];	

        }

        
		FileOutput[] memory outputs = new FileOutput[](_ipfs_hash.length);
		for (uint256 index = 0; index < _ipfs_hash.length; index++) {

            FileOutput memory output;
            if (keccak256(abi.encodePacked(_media_type[index])) == keccak256(abi.encodePacked("Audio/mp3"))) {
                output = FileOutput(
                            "****",
                            concat("Title: ", _title[index]),
                            concat("Type: ", _media_type[index]),
                            concat("Album: ", _album_series[index]),
                            concat("Copyright: ", _copyright[index]),
                            concat("Website: ", _website[index]),
                            concat("IPFS URL: https://ipfs.io/ipfs/", _ipfs_hash[index]),
                            concat("Comment: ", _comment[index]),
                            concat("Blockchain Date: ", _blockchain_date[index]),
                            concat("SHA256: ", _sha_hash[index])
                        );
            } else {
                output = FileOutput(
                            "****",
                            concat("Title: ", _title[index]),
                            concat("Type: ", _media_type[index]),
                            concat("Series: ", _album_series[index]),
                            concat("Copyright: ", _copyright[index]),
                            concat("Website: ", _website[index]),
                            concat("IPFS URL: https://ipfs.io/ipfs/", _ipfs_hash[index]),
                            concat("Comment: ", _comment[index]),
                            concat("Blockchain Date: ", _blockchain_date[index]),
                            concat("SHA256: ", _sha_hash[index])
                        );
            }

			outputs[index] = output;
		}
		return outputs;

	}

	function concat(string memory a, string memory b) private pure returns (string memory) {

		return string(abi.encodePacked(a, b));
	}

	function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {

        (year, month, day) = _daysToDate(timestamp / (24 * 60 * 60));
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {

        int __days = int(_days);

        int L = __days + 68569 + 2440588;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

	function concat(string memory a, string memory b, string memory c, string memory d, string memory e) private pure returns (string memory) {

		return string(abi.encodePacked(a, b, c, d, e));
	}

}