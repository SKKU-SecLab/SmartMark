pragma solidity 0.8.6;

interface IOperatorStore {

    event SetOperator(
        address indexed operator,
        address indexed account,
        uint256 indexed domain,
        uint256[] permissionIndexes,
        uint256 packed
    );

    function permissionsOf(
        address _operator,
        address _account,
        uint256 _domain
    ) external view returns (uint256);


    function hasPermission(
        address _operator,
        address _account,
        uint256 _domain,
        uint256 _permissionIndex
    ) external view returns (bool);


    function hasPermissions(
        address _operator,
        address _account,
        uint256 _domain,
        uint256[] calldata _permissionIndexes
    ) external view returns (bool);


    function setOperator(
        address _operator,
        uint256 _domain,
        uint256[] calldata _permissionIndexes
    ) external;


    function setOperators(
        address[] calldata _operators,
        uint256[] calldata _domains,
        uint256[][] calldata _permissionIndexes
    ) external;

}// MIT
pragma solidity 0.8.6;


contract OperatorStore is IOperatorStore {


    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public
        override permissionsOf;


    function hasPermission(
        address _operator,
        address _account,
        uint256 _domain,
        uint256 _permissionIndex
    ) external view override returns (bool) {

        require(
            _permissionIndex <= 255,
            "OperatorStore::hasPermission: INDEX_OUT_OF_BOUNDS"
        );
        return
            ((permissionsOf[_operator][_account][_domain] >> _permissionIndex) &
                1) == 1;
    }

    function hasPermissions(
        address _operator,
        address _account,
        uint256 _domain,
        uint256[] calldata _permissionIndexes
    ) external view override returns (bool) {

        for (uint256 _i = 0; _i < _permissionIndexes.length; _i++) {
            uint256 _permissionIndex = _permissionIndexes[_i];

            require(
                _permissionIndex <= 255,
                "OperatorStore::hasPermissions: INDEX_OUT_OF_BOUNDS"
            );

            if (
                ((permissionsOf[_operator][_account][_domain] >>
                    _permissionIndex) & 1) == 0
            ) return false;
        }
        return true;
    }


    function setOperator(
        address _operator,
        uint256 _domain,
        uint256[] calldata _permissionIndexes
    ) external override {

        uint256 _packed = _packedPermissions(_permissionIndexes);

        permissionsOf[_operator][msg.sender][_domain] = _packed;

        emit SetOperator(
            _operator,
            msg.sender,
            _domain,
            _permissionIndexes,
            _packed
        );
    }

    function setOperators(
        address[] calldata _operators,
        uint256[] calldata _domains,
        uint256[][] calldata _permissionIndexes
    ) external override {

        require(
            _operators.length == _permissionIndexes.length &&
                _operators.length == _domains.length,
            "OperatorStore::setOperators: BAD_ARGS"
        );
        for (uint256 _i = 0; _i < _operators.length; _i++) {
            uint256 _packed = _packedPermissions(_permissionIndexes[_i]);
            permissionsOf[_operators[_i]][msg.sender][_domains[_i]] = _packed;
            emit SetOperator(
                _operators[_i],
                msg.sender,
                _domains[_i],
                _permissionIndexes[_i],
                _packed
            );
        }
    }


    function _packedPermissions(uint256[] calldata _indexes)
        private
        pure
        returns (uint256 packed)
    {

        for (uint256 _i = 0; _i < _indexes.length; _i++) {
            uint256 _permissionIndex = _indexes[_i];
            require(
                _permissionIndex <= 255,
                "OperatorStore::_packedPermissions: INDEX_OUT_OF_BOUNDS"
            );
            packed |= 1 << _permissionIndex;
        }
    }
}