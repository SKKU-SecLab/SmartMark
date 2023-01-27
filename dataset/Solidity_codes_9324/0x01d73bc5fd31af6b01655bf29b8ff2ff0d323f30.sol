
pragma solidity =0.8.9 >=0.8.0;


interface IJob {


    function work(bytes32 network, bytes calldata args) external;


    function workable(bytes32 network) external returns (bool canWork, bytes memory args);


}



interface SequencerLike_3 {

    function isMaster(bytes32 network) external view returns (bool);

}

interface IlkRegistryLike_2 {

    function list() external view returns (bytes32[] memory);

    function info(bytes32 ilk) external view returns (
        string memory name,
        string memory symbol,
        uint256 class,
        uint256 dec,
        address gem,
        address pip,
        address join,
        address xlip
    );

}

interface ClipperMomLike {

    function tripBreaker(address clip) external;

}

contract ClipperMomJob is IJob {

    
    SequencerLike_3 public immutable sequencer;
    IlkRegistryLike_2 public immutable ilkRegistry;
    ClipperMomLike public immutable clipperMom;

    error NotMaster(bytes32 network);

    constructor(address _sequencer, address _ilkRegistry, address _clipperMom) {
        sequencer = SequencerLike_3(_sequencer);
        ilkRegistry = IlkRegistryLike_2(_ilkRegistry);
        clipperMom = ClipperMomLike(_clipperMom);
    }

    function work(bytes32 network, bytes calldata args) external override {

        if (!sequencer.isMaster(network)) revert NotMaster(network);

        clipperMom.tripBreaker(abi.decode(args, (address)));
    }

    function workable(bytes32 network) external override returns (bool, bytes memory) {

        if (!sequencer.isMaster(network)) return (false, bytes("Network is not master"));
        
        bytes32[] memory ilks = ilkRegistry.list();
        for (uint256 i = 0; i < ilks.length; i++) {
            (,, uint256 class,,,,, address clip) = ilkRegistry.info(ilks[i]);
            if (class != 1) continue;
            if (clip == address(0)) continue;

            try clipperMom.tripBreaker(clip) {
                return (true, abi.encode(clip));
            } catch {
            }
        }

        return (false, bytes("No ilks ready"));
    }

}