

pragma solidity >=0.4.23 >=0.4.24 <0.7.0 >=0.6.7 <0.7.0;





interface DSAuthority {

    function canCall(
        address src, address dst, bytes4 sig
    ) external view returns (bool);

}

contract DSAuthEvents {

    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {

    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {

        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}




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
}


contract FurnaceSettingIds {

	uint256 public constant PREFER_GOLD = 1 << 1;
	uint256 public constant PREFER_WOOD = 1 << 2;
	uint256 public constant PREFER_WATER = 1 << 3;
	uint256 public constant PREFER_FIRE = 1 << 4;
	uint256 public constant PREFER_SOIL = 1 << 5;

	uint8 public constant DRILL_OBJECT_CLASS = 4; // Drill
	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item
	uint8 public constant DARWINIA_OBJECT_CLASS = 254; // Darwinia

	bytes32 public constant FURNACE_APP = "FURNACE_APP";

	bytes32 public constant FURNACE_ITEM_MINE_FEE = "FURNACE_ITEM_MINE_FEE";

	uint128 public constant RATE_PRECISION = 10**8;

	bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	bytes32 public constant CONTRACT_LAND_ITEM_BAR = "CONTRACT_LAND_ITEM_BAR";

	bytes32 public constant CONTRACT_APOSTLE_ITEM_BAR =
		"CONTRACT_APOSTLE_ITEM_BAR";

	bytes32 public constant CONTRACT_ITEM_BASE = "CONTRACT_ITEM_BASE";

	bytes32 public constant CONTRACT_DRILL_BASE = "CONTRACT_DRILL_BASE";

	bytes32 public constant CONTRACT_DARWINIA_ITO_BASE = "CONTRACT_DARWINIA_ITO_BASE";

	bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	bytes32 public constant CONTRACT_ERC721_GEGO = "CONTRACT_ERC721_GEGO";

	bytes32 public constant CONTRACT_FORMULA = "CONTRACT_FORMULA";

	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	bytes32 public constant CONTRACT_LP_ELEMENT_TOKEN = 
		"CONTRACT_LP_ELEMENT_TOKEN";

	bytes32 public constant CONTRACT_LP_GOLD_ERC20_TOKEN =
		"CONTRACT_LP_GOLD_ERC20_TOKEN";

	bytes32 public constant CONTRACT_LP_WOOD_ERC20_TOKEN =
		"CONTRACT_LP_WOOD_ERC20_TOKEN";

	bytes32 public constant CONTRACT_LP_WATER_ERC20_TOKEN =
		"CONTRACT_LP_WATER_ERC20_TOKEN";

	bytes32 public constant CONTRACT_LP_FIRE_ERC20_TOKEN =
		"CONTRACT_LP_FIRE_ERC20_TOKEN";

	bytes32 public constant CONTRACT_LP_SOIL_ERC20_TOKEN =
		"CONTRACT_LP_SOIL_ERC20_TOKEN";

	bytes32 public constant CONTRACT_RING_ERC20_TOKEN =
		"CONTRACT_RING_ERC20_TOKEN";

	bytes32 public constant CONTRACT_KTON_ERC20_TOKEN =
		"CONTRACT_KTON_ERC20_TOKEN";

	bytes32 public constant CONTRACT_ELEMENT_TOKEN = 
		"CONTRACT_ELEMENT_TOKEN";

	bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN =
		"CONTRACT_GOLD_ERC20_TOKEN";

	bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN =
		"CONTRACT_WOOD_ERC20_TOKEN";

	bytes32 public constant CONTRACT_WATER_ERC20_TOKEN =
		"CONTRACT_WATER_ERC20_TOKEN";

	bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN =
		"CONTRACT_FIRE_ERC20_TOKEN";

	bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN =
		"CONTRACT_SOIL_ERC20_TOKEN";
}


interface IFormula {

	struct FormulaEntry {
		bytes32 name;
		uint128 rate;
		uint16 objClassExt;
		uint16 class;
		uint16 grade;
		bool canDisenchant;

		bool disable;

		bytes32 minor;
		uint256 amount;
		address majorAddr;
		uint16 majorObjClassExt;
		uint16 majorClass;
		uint16 majorGrade;
	}

	event AddFormula(
		uint256 indexed index,
		bytes32 name,
		uint128 rate,
		uint16 objClassExt,
		uint16 class,
		uint16 grade,
		bool canDisenchant,
		bytes32 minor,
		uint256 amount,
		address majorAddr,
		uint16 majorObjClassExt,
		uint16 majorClass,
		uint16 majorGrade
	);
	event DisableFormula(uint256 indexed index);
	event EnableFormula(uint256 indexed index);

	function insert(
		bytes32 _name,
		uint128 _rate,
		uint16 _objClassExt,
		uint16 _class,
		uint16 _grade,
		bool _canDisenchant,
		bytes32 _minor,
		uint256 _amount,
		address _majorAddr,
		uint16 _majorObjClassExt,
		uint16 _majorClass,
		uint16 _majorGrade
	) external;


	function disable(uint256 _index) external;


	function enable(uint256 _index) external;


	function length() external view returns (uint256);


	function isDisable(uint256 _index) external view returns (bool);


	function getMinor(uint256 _index)
		external
		view
		returns (bytes32, uint256);


	function getMajorInfo(uint256 _index)
		external
		view	
		returns (
			address,
			uint16,
			uint16,
			uint16
		);


	function getMetaInfo(uint256 _index)
		external
		view
		returns (
			uint16,
			uint16,
			uint16,
			uint128
		);


	function canDisenchant(uint256 _index) external view returns (bool);

}


interface ISettingsRegistry {

    function uintOf(bytes32 _propertyName) external view returns (uint256);


    function stringOf(bytes32 _propertyName) external view returns (string memory);


    function addressOf(bytes32 _propertyName) external view returns (address);


    function bytesOf(bytes32 _propertyName) external view returns (bytes memory);


    function boolOf(bytes32 _propertyName) external view returns (bool);


    function intOf(bytes32 _propertyName) external view returns (int);


    function setUintProperty(bytes32 _propertyName, uint _value) external;


    function setStringProperty(bytes32 _propertyName, string calldata _value) external;


    function setAddressProperty(bytes32 _propertyName, address _value) external;


    function setBytesProperty(bytes32 _propertyName, bytes calldata _value) external;


    function setBoolProperty(bytes32 _propertyName, bool _value) external;


    function setIntProperty(bytes32 _propertyName, int _value) external;


    function getValueTypeOf(bytes32 _propertyName) external view returns (uint /* SettingsValueTypes */ );


    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}



contract Formula is Initializable, DSAuth, IFormula {

	event SetStrength(uint256 indexed inde, uint128 rate);

	event SetAmount(uint256 indexed index, uint256 amount);

	bytes32 public constant CONTRACT_ERC721_GEGO = "CONTRACT_ERC721_GEGO";

	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	bytes32 public constant CONTRACT_ELEMENT_TOKEN = 
		"CONTRACT_ELEMENT_TOKEN";

	bytes32 public constant CONTRACT_LP_ELEMENT_TOKEN = 
		"CONTRACT_LP_ELEMENT_TOKEN";

	uint128 public constant RATE_DECIMALS = 10 ** 6;
	uint256 public constant UNIT = 10 ** 18;


	ISettingsRegistry public registry;
	FormulaEntry[] public formulas;

	function initialize(address _registry) public initializer {

		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);

		_init();
	}

	function _init() internal {

		address gego = registry.addressOf(CONTRACT_ERC721_GEGO); 
		address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		insert("合金镐", uint128(5 * RATE_DECIMALS), uint16(256), uint16(1), uint16(1), true, CONTRACT_ELEMENT_TOKEN, 500 * UNIT, gego, 256, 0, 1);

		insert("人力铸铁钻机", uint128(5 * RATE_DECIMALS), uint16(4), uint16(1), uint16(1), true, CONTRACT_ELEMENT_TOKEN, 500 * UNIT, ownership, 4, 0, 1);

		insert("人力镍钢钻机", uint128(12 * RATE_DECIMALS), uint16(4), uint16(1), uint16(2), true, CONTRACT_ELEMENT_TOKEN, 500 * UNIT, ownership, 4, 0, 2);

		insert("人力金刚钻机", uint128(25 * RATE_DECIMALS), uint16(4), uint16(1), uint16(3), true, CONTRACT_ELEMENT_TOKEN, 500 * UNIT, ownership, 4, 0, 3);

		insert("高级合金镐", uint128(28 * RATE_DECIMALS), uint16(256), uint16(2), uint16(1), true, CONTRACT_LP_ELEMENT_TOKEN, 450 * UNIT, ownership, 256, 1, 1);

		insert("燃油铸铁钻机", uint128(28 * RATE_DECIMALS), uint16(4), uint16(2), uint16(1), true, CONTRACT_LP_ELEMENT_TOKEN, 450 * UNIT, ownership, 4, 1, 1);

		insert("燃油钨钢钻机", uint128(68 * RATE_DECIMALS), uint16(4), uint16(2), uint16(2), true, CONTRACT_LP_ELEMENT_TOKEN, 450 * UNIT, ownership, 4, 1, 2);

		insert("燃油金刚钻机", uint128(120 * RATE_DECIMALS), uint16(4), uint16(2), uint16(3), true, CONTRACT_LP_ELEMENT_TOKEN, 450 * UNIT, ownership, 4, 1, 3);
	}

	function insert(
		bytes32 _name,
		uint128 _rate,
		uint16 _objClassExt,
		uint16 _class,
		uint16 _grade,
		bool _canDisenchant,
		bytes32 _minor,
		uint256 _amount,
		address _majorAddr,
		uint16 _majorObjClassExt,
		uint16 _majorClass,
		uint16 _majorGrade
	) public override auth {

		FormulaEntry memory formula =
			FormulaEntry({
				name: _name,
				rate: _rate,
				objClassExt: _objClassExt,
				disable: false,
				class: _class,
				grade: _grade,
				canDisenchant: _canDisenchant,
				minor: _minor,
				amount: _amount,
				majorAddr: _majorAddr,
		        majorObjClassExt: _majorObjClassExt,
		        majorClass: _majorClass,
		        majorGrade:_majorGrade
			});
		formulas.push(formula);
		emit AddFormula(
			formulas.length - 1,
			formula.name,
			formula.rate,
			formula.objClassExt,
			formula.class,
			formula.grade,
			formula.canDisenchant,
			formula.minor,
			formula.amount,
			formula.majorAddr,
			formula.majorObjClassExt,
			formula.majorClass,
			formula.majorGrade
		);
	}

	function disable(uint256 _index) external override auth {

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		formulas[_index].disable = true;
		emit DisableFormula(_index);
	}

	function enable(uint256 _index) external override auth {

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		formulas[_index].disable = false;
		emit EnableFormula(_index);
	}

	function setStrengthRate(uint256 _index, uint128 _rate) external auth {

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		formula.rate = _rate;
		emit SetStrength(_index, formula.rate);
	}

	function setAmount(uint256 _index, uint256 _amount)
		external
		auth
	{

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		formula.amount = _amount;
		emit SetAmount(_index, formula.amount);
	}

	function length() external view override returns (uint256) {

		return formulas.length;
	}

	function isDisable(uint256 _index) external view override returns (bool) {

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return formulas[_index].disable;
	}

	function getMinor(uint256 _index)
		external
		view
		override
		returns (bytes32, uint256)
	{

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return (formulas[_index].minor, formulas[_index].amount);
	}

	function canDisenchant(uint256 _index)
		external
		view
		override
		returns (bool)
	{

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		return formulas[_index].canDisenchant;
	}

	function getMetaInfo(uint256 _index)
		external
		view
		override
		returns (
			uint16,
			uint16,
			uint16,
			uint128
		)
	{

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		return (
			formula.objClassExt,
			formula.class,
			formula.grade,
			formula.rate
		);
	}

	function getMajorInfo(uint256 _index)
		public
		view	
		override
		returns (
			address,
			uint16,
			uint16,
			uint16
		)
	{

		require(_index < formulas.length, "Formula: OUT_OF_RANGE");
		FormulaEntry storage formula = formulas[_index];
		return (
			formula.majorAddr,
			formula.majorObjClassExt,
			formula.majorClass,
			formula.majorGrade
		);
	}
}