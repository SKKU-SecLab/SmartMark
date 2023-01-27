
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT

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
        return !AddressUpgradeable.isContract(address(this));
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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.8.0;



contract Files is OwnableUpgradeable {





    struct FileOutput {
		string separator;
        string file_number;
		string title;
		string album;
		string website;
		string ipfs_hash;
		string comment;
		string copyright;
        string submission_date;
		string blockchain_date;
        string md_hash;
    }

    struct FileOutputCollection {
		string[] separator;
        string[] file_number;
		string[] title;
		string[] album;
		string[] website;
		string[] ipfs_hash;
		string[] comment;
		string[] copyright;
        string[] submission_date;
		string[] blockchain_date;
        string[] md_hash;
    }

    uint256 private size;


    mapping(uint256 => string) filesNumberIndex;
    mapping(string => uint256[]) filesByNumber;

    mapping(uint256 => string) filesIpfsHashIndex;
    mapping(string => uint256[]) filesByIpfsHash;

	mapping(uint256 => string) filesMDHashIndex;
    mapping(string => uint256[]) filesByMDHash;

  
	mapping(uint256 => string) filesTitleIndex;
    mapping(uint256 => string) filesAlbumSeriesIndex;
	mapping(uint256 => string) filesWebsiteIndex;
	mapping(uint256 => string) filesCommentIndex;
	mapping(uint256 => string) filesCopyrightIndex;
    mapping(uint256 => string) filesSubmissionDateIndex;
	mapping(uint256 => uint256) filesBlockchainDateIndex;
    
    function initialize() initializer public {

        __Ownable_init();
    }

    function addFile(string[] memory metadata) public onlyOwner returns (uint256) {


        require( metadata.length == 9);


        string memory _file_number = metadata[0];
        string memory _title = metadata[1];
        string memory _album = metadata[2];
        string memory _website = metadata[3];
	    string memory _ipfs_hash = metadata[4];
        string memory _comment = metadata[5];
		string memory _copyright = metadata[6];
        string memory _submission_date = metadata[7];
		string memory _md_hash = metadata[8];
 

        filesNumberIndex[size] = _file_number;
        filesTitleIndex[size] = _title;
        filesAlbumSeriesIndex[size] = _album;
        filesWebsiteIndex[size] = _website;
        filesIpfsHashIndex[size] = _ipfs_hash;
        filesCommentIndex[size] = _comment;
        filesCopyrightIndex[size] = _copyright;
        filesSubmissionDateIndex[size] = _submission_date;
        filesBlockchainDateIndex[size] = block.timestamp;
		filesMDHashIndex[size] = _md_hash;


        filesByNumber[_file_number].push(size);
        filesByIpfsHash[_ipfs_hash].push(size);
        filesByMDHash[_md_hash].push(size);

        size = size + 1;
        return size;
    }

    function Find_Files_by_QI_Audio_Catalogue_Number(uint256 QI_Audio_Catalogue) view external returns (FileOutput[] memory) {

        return findFilesByKey(1, StringsUpgradeable.toString(QI_Audio_Catalogue));
    }

    function Find_Files_by_IPFS_Hash(string calldata IPFS_Hash) view external returns (FileOutput[] memory) {

        return findFilesByKey(2, IPFS_Hash);
    }

    function Find_Files_by_MD5_Hash(string calldata MD5_Hash) view external returns (FileOutput[] memory) {

        return findFilesByKey(3, MD5_Hash);
    }

    function findFilesByKey(int key, string memory hash) view internal returns (FileOutput[] memory) {

        uint256 len;


        if(key == 1){
            len = filesByNumber[hash].length;
        } 

        if(key == 2){
            len = filesByIpfsHash[hash].length;
        } 

        if(key == 3){
            len = filesByMDHash[hash].length;
        } 

        FileOutputCollection memory outputsCollection;

        outputsCollection.separator = new string[](len);
        outputsCollection.file_number = new string[](len);
        outputsCollection.title = new string[](len);
        outputsCollection.album = new string[](len);
        outputsCollection.website = new string[](len);
        outputsCollection.ipfs_hash = new string[](len);
        outputsCollection.comment = new string[](len);
        outputsCollection.copyright = new string[](len);
        outputsCollection.submission_date = new string[](len);
        outputsCollection.blockchain_date = new string[](len);	
		outputsCollection.md_hash = new string[](len);	

        for (uint256 index = 0; index < len; index++){
            uint256 id;

            if(key == 1){
                id = filesByNumber[hash][index];
            } 

            if(key == 2){
                id = filesByIpfsHash[hash][index];
            } 

            if(key == 3){
                id = filesByMDHash[hash][index];
            } 

            (uint year, uint month, uint day) = timestampToDate(filesBlockchainDateIndex[id]);

            outputsCollection.file_number[index] = filesNumberIndex[id];
            outputsCollection.title[index] = filesTitleIndex[id];
            outputsCollection.album[index] = filesAlbumSeriesIndex[id];
            outputsCollection.website[index] = filesWebsiteIndex[id];
            outputsCollection.ipfs_hash[index] = filesIpfsHashIndex[id];
            outputsCollection.comment[index] = filesCommentIndex[id];
            outputsCollection.copyright[index] = filesCopyrightIndex[id];
            outputsCollection.submission_date[index] = filesSubmissionDateIndex[id];
            outputsCollection.blockchain_date[index] =  concat( _convertVaalue(day),  ".",  _convertVaalue(month), ".", _convertVaalue(year) );
			outputsCollection.md_hash[index] = filesMDHashIndex[id];	

        }

        
		FileOutput[] memory outputs = new FileOutput[](len);
		for (uint256 index = 0; index < len; index++) {

            FileOutput memory output;

            output = FileOutput(
                "****",
                concat("File Number: ", outputsCollection.file_number[index]),
                concat("Title: ", outputsCollection.title[index]),
                concat("Album: ", outputsCollection.album[index]),
                concat("Website: ", outputsCollection.website[index]),
                concat("IPFS URL: https://ipfs.io/ipfs/", outputsCollection.ipfs_hash[index]),
                concat("Comment: ", outputsCollection.comment[index]),
                concat("Copyright: ", outputsCollection.copyright[index]),
                concat("Submission Date: ", outputsCollection.submission_date[index]),
                concat("Blockchain Write Date: ", outputsCollection.blockchain_date[index]),
                concat("MD5 Hash: ", outputsCollection.md_hash[index])
            );

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


    function _convertVaalue(uint _value) internal pure returns (string memory value) {

        if( _value <10) {
            value = concat("0", StringsUpgradeable.toString(_value));
        } else {
            value = StringsUpgradeable.toString(_value);
        }
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
        _year = _year % 100;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

	function concat(string memory a, string memory b, string memory c, string memory d, string memory e) private pure returns (string memory) {

		return string(abi.encodePacked(a, b, c, d, e));
	}

}