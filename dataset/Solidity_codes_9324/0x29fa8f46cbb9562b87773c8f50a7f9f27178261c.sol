
pragma solidity 0.5.17;

interface IBondedECDSAKeepFactory {

    function openKeep(
        uint256 _groupSize,
        uint256 _honestThreshold,
        address _owner,
        uint256 _bond,
        uint256 _stakeLockDuration
    ) external payable returns (address keepAddress);


    function openKeepFeeEstimate() external view returns (uint256);


    function getSortitionPoolWeight(
        address _application
    ) external view returns (uint256);


    function setMinimumBondableValue(
        uint256 _minimumBondableValue,
        uint256 _groupSize,
        uint256 _honestThreshold
    ) external;

}pragma solidity 0.5.17;


interface KeepFactorySelector {


    function selectFactory(
        uint256 _seed,
        IBondedECDSAKeepFactory _keepStakedFactory,
        IBondedECDSAKeepFactory _fullyBackedFactory
    ) external view returns (IBondedECDSAKeepFactory);

}

library KeepFactorySelection {


    struct Storage {
        uint256 requestCounter;

        IBondedECDSAKeepFactory selectedFactory;

        KeepFactorySelector factorySelector;

        IBondedECDSAKeepFactory keepStakedFactory;

        IBondedECDSAKeepFactory fullyBackedFactory;
    }

    function initialize(
        Storage storage _self,
        IBondedECDSAKeepFactory _defaultFactory
    ) public {

        require(
            address(_self.keepStakedFactory) == address(0),
            "Already initialized"
        );

        _self.keepStakedFactory = IBondedECDSAKeepFactory(_defaultFactory);
        _self.selectedFactory = _self.keepStakedFactory;
    }

    function selectFactory(
        Storage storage _self
    ) public view returns (IBondedECDSAKeepFactory) {

        return _self.selectedFactory;
    }

    function selectFactoryAndRefresh(
        Storage storage _self
    ) external returns (IBondedECDSAKeepFactory) {

        IBondedECDSAKeepFactory factory = selectFactory(_self);
        refreshFactory(_self);

        return factory;
    }

    function setMinimumBondableValue(
        Storage storage _self,
        uint256 _minimumBondableValue,
        uint256 _groupSize,
        uint256 _honestThreshold
    ) external {

        if (address(_self.keepStakedFactory) != address(0)) {
            _self.keepStakedFactory.setMinimumBondableValue(
                _minimumBondableValue,
                _groupSize,
                _honestThreshold
            );
        }
        if (address(_self.fullyBackedFactory) != address(0)) {
            _self.fullyBackedFactory.setMinimumBondableValue(
                _minimumBondableValue,
                _groupSize,
                _honestThreshold
            );
        }
    }

    function refreshFactory(Storage storage _self) internal {

        if (
            address(_self.fullyBackedFactory) == address(0) ||
            address(_self.factorySelector) == address(0)
        ) {
            _self.selectedFactory = _self.keepStakedFactory;
            return;
        }

        _self.requestCounter++;
        uint256 seed = uint256(
            keccak256(abi.encodePacked(address(this), _self.requestCounter))
        );
        _self.selectedFactory = _self.factorySelector.selectFactory(
            seed,
            _self.keepStakedFactory,
            _self.fullyBackedFactory
        );

        require(
            _self.selectedFactory == _self.keepStakedFactory ||
                _self.selectedFactory == _self.fullyBackedFactory,
            "Factory selector returned unknown factory"
        );
    }

    function setFactories(
        Storage storage _self,
        address _keepStakedFactory,
        address _fullyBackedFactory,
        address _factorySelector
    ) internal {

        require(
            address(_keepStakedFactory) != address(0),
            "Invalid KEEP-staked factory address"
        );

        _self.keepStakedFactory = IBondedECDSAKeepFactory(_keepStakedFactory);
        _self.fullyBackedFactory = IBondedECDSAKeepFactory(_fullyBackedFactory);
        _self.factorySelector = KeepFactorySelector(_factorySelector);
    }
}/**
▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓▌        ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
  ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓

                           Trust math, not hardware.
*/

pragma solidity 0.5.17;

contract IBondedECDSAKeep {

    function getPublicKey() external view returns (bytes memory);


    function checkBondAmount() external view returns (uint256);


    function sign(bytes32 _digest) external;


    function distributeETHReward() external payable;


    function distributeERC20Reward(address _tokenAddress, uint256 _value)
        external;


    function seizeSignerBonds() external;


    function returnPartialSignerBonds() external payable;


    function submitSignatureFraud(
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        bytes32 _signedDigest,
        bytes calldata _preimage
    )
        external returns (bool _isFraud);


    function closeKeep() external;

}