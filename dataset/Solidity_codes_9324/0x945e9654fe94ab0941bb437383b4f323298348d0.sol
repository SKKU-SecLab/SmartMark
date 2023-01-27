



pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




library Storage {


    function load(
        bytes32 slot
    )
        internal
        view
        returns (bytes32)
    {

        bytes32 result;
        assembly {
            result := sload(slot)
        }
        return result;
    }

    function store(
        bytes32 slot,
        bytes32 value
    )
        internal
    {

        assembly {
            sstore(slot, value)
        }
    }
}


contract Adminable {

    bytes32 internal constant ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier onlyAdmin() {

        require(
            msg.sender == getAdmin(),
            "Adminable: caller is not admin"
        );
        _;
    }

    function getAdmin()
        public
        view
        returns (address)
    {

        return address(uint160(uint256(Storage.load(ADMIN_SLOT))));
    }
}


contract SkillsetMetadataStorageV1 {


    mapping (address => bool) public approvedSkillsets;

    address[] public skillsetsArray;

    mapping (address => uint256) public maxLevel;

}

contract SkillsetMetadata is Adminable, SkillsetMetadataStorageV1 {



    event SkillsetStatusUpdated(address _token, bool _status);
    event SkillsetMaxLevelSet(address _token, uint256 _level);


    function getSkillsetBalance(
        address _token,
        address _user
    )
        public
        view
        returns (uint256)
    {

        return IERC20(_token).balanceOf(_user);
    }

    function isValidSkillset(
        address _token
    )
        public
        view
        returns (bool)
    {

        return approvedSkillsets[_token];
    }

    function getAllSkillsets()
        public
        view
        returns (address[] memory)
    {

        return skillsetsArray;
    }


    function addSkillsetToken(
        address _token
    )
        public
        onlyAdmin
    {

        require(
            approvedSkillsets[_token] != true,
            "Skillset has already been added"
        );

        skillsetsArray.push(_token);
        approvedSkillsets[_token] = true;

        emit SkillsetStatusUpdated(_token, true);
    }

    function removeSkillsetToken(
        address _token
    )
        public
        onlyAdmin
    {

        require(
            approvedSkillsets[_token] == true,
            "Skillset does not exist"
        );

        for (uint i = 0; i < skillsetsArray.length; i++) {
            if (skillsetsArray[i] == _token) {
                delete skillsetsArray[i];
                skillsetsArray[i] = skillsetsArray[skillsetsArray.length - 1];
                skillsetsArray.length--;
                break;
            }
        }

        delete approvedSkillsets[_token];

        emit SkillsetStatusUpdated(_token, false);
    }

    function setMaxLevel(
        address _token,
        uint256 _level
    )
        public
        onlyAdmin
    {

        maxLevel[_token] = _level;

        emit SkillsetMaxLevelSet(_token, _level);

    }

}