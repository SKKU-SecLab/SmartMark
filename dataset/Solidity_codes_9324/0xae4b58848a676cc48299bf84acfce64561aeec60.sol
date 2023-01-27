

pragma solidity 0.5.12;

contract LibNote {

    event LogNote(
        bytes4   indexed  sig,
        address  indexed  usr,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes             data
    ) anonymous;

    modifier note {

        _;
        assembly {
            let mark := msize                         // end of memory ensures zero
            mstore(0x40, add(mark, 288))              // update free memory pointer
            mstore(mark, 0x20)                        // bytes type data offset
            mstore(add(mark, 0x20), 224)              // bytes size (padded)
            calldatacopy(add(mark, 0x40), 0, 224)     // bytes payload
            log4(mark, 288,                           // calldata
                 shl(224, shr(224, calldataload(0))), // msg.sig
                 caller,                              // msg.sender
                 calldataload(4),                     // arg1
                 calldataload(36)                     // arg2
                )
        }
    }
}

contract PitchLike {

    function transfer(address,uint) external returns (bool);

    function transferFrom(address,address,uint) external returns (bool);

}


contract Pitch2Like {

    function mint(address,uint) external;

    function burn(address,uint) external;

}



contract PitchSwap is LibNote {

    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }

    function deny(address usr) external note auth { wards[usr] = 0; }

    modifier auth {

        require(wards[msg.sender] == 1, "PitchSwap/not-authorized");
        _;
    }

    Pitch2Like public pitch2;
    PitchLike public pitch;
    uint    public live;  // Access Flag

    constructor(address pitch2_, address pitch_) public {
        wards[msg.sender] = 1;
        live = 1;
        pitch2 = Pitch2Like(pitch2_);
        pitch = PitchLike(pitch_);
    }

    function cage() external note auth {

        live = 0;
    }

	uint constant ONE = 10 ** 9; //10 ** 18;
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }

    function join(address usr, uint wad) external note {

        require(live == 1, "PitchSwap/not-live");
        require(int(wad) >= 0, "PitchSwap/overflow");
        pitch2.mint(usr, mul(ONE, wad));
        require(pitch.transferFrom(msg.sender, address(this), wad), "PitchSwap/failed-transfer");
    }

    function exit(address usr, uint wad) external note {

        require(wad <= 2 ** 255, "PitchSwap/overflow");
        pitch2.burn(usr, mul(ONE, wad));
        require(pitch.transfer(usr, wad), "PitchSwap/failed-transfer");
    }
}