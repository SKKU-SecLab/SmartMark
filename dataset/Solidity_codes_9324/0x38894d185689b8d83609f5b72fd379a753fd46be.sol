pragma solidity ^0.8.0;

library Base64 {

    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity >=0.8.0;

library DynamicBuffer {

    function allocate(uint256 capacity)
        internal
        pure
        returns (bytes memory buffer)
    {

        assembly {
            let container := mload(0x40)

            {
                let size := add(capacity, 0x60)
                let newNextFree := add(container, size)
                mstore(0x40, newNextFree)
            }

            {
                let length := add(capacity, 0x40)
                mstore(container, length)
            }

            buffer := add(container, 0x20)

            mstore(buffer, 0)
        }

        return buffer;
    }

    function appendUnchecked(bytes memory buffer, bytes memory data)
        internal
        pure
    {

        assembly {
            let length := mload(data)
            for {
                data := add(data, 0x20)
                let dataEnd := add(data, length)
                let copyTo := add(buffer, add(mload(buffer), 0x20))
            } lt(data, dataEnd) {
                data := add(data, 0x20)
                copyTo := add(copyTo, 0x20)
            } {
                mstore(copyTo, mload(data))
            }

            mstore(buffer, add(mload(buffer), length))
        }
    }

    function appendSafe(bytes memory buffer, bytes memory data) internal pure {

        uint256 capacity;
        uint256 length;
        assembly {
            capacity := sub(mload(sub(buffer, 0x20)), 0x40)
            length := mload(buffer)
        }

        require(
            length + data.length <= capacity,
            "DynamicBuffer: Appending out of bounds."
        );
        appendUnchecked(buffer, data);
    }
}//Unlicense
pragma solidity ^0.8.8;

interface IOKPC {

  enum Phase {
    INIT,
    EARLY_BIRDS,
    FRIENDS,
    PUBLIC
  }
  struct Art {
    address artist;
    bytes16 title;
    uint256 data1;
    uint256 data2;
  }
  struct Commission {
    address artist;
    uint256 amount;
  }
  struct ClockSpeedXP {
    uint256 savedSpeed;
    uint256 lastSaveBlock;
    uint256 transferCount;
    uint256 artLastChanged;
  }

  function getPaintArt(uint256) external view returns (Art memory);


  function getGalleryArt(uint256) external view returns (Art memory);


  function activeArtForOKPC(uint256) external view returns (uint256);


  function useOffchainMetadata(uint256) external view returns (bool);


  function clockSpeed(uint256) external view returns (uint256);


  function artCountForOKPC(uint256) external view returns (uint256);

}//Unlicense
pragma solidity ^0.8.7;

interface IOKPCParts {

  error IndexOutOfBounds(uint256 index, uint256 maxIndex);

  struct Color {
    bytes6 light;
    bytes6 regular;
    bytes6 dark;
    string name;
  }

  struct Vector {
    string data;
    string name;
  }

  function getColor(uint256 index) external view returns (Color memory);


  function getHeadband(uint256 index) external view returns (Vector memory);


  function getSpeaker(uint256 index) external view returns (Vector memory);


  function getWord(uint256 index) external view returns (string memory);

}// MIT
pragma solidity ^0.8.0;


library Bytecode {

  error InvalidCodeAtRange(uint256 _size, uint256 _start, uint256 _end);

  function creationCodeFor(bytes memory _code) internal pure returns (bytes memory) {


    return abi.encodePacked(
      hex"63",
      uint32(_code.length),
      hex"80_60_0E_60_00_39_60_00_F3",
      _code
    );
  }

  function codeSize(address _addr) internal view returns (uint256 size) {

    assembly { size := extcodesize(_addr) }
  }

  function codeAt(address _addr, uint256 _start, uint256 _end) internal view returns (bytes memory oCode) {

    uint256 csize = codeSize(_addr);
    if (csize == 0) return bytes("");

    if (_start > csize) return bytes("");
    if (_end < _start) revert InvalidCodeAtRange(csize, _start, _end); 

    unchecked {
      uint256 reqSize = _end - _start;
      uint256 maxSize = csize - _start;

      uint256 size = maxSize < reqSize ? maxSize : reqSize;

      assembly {
        oCode := mload(0x40)
        mstore(0x40, add(oCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
        mstore(oCode, size)
        extcodecopy(_addr, add(oCode, 0x20), _start, size)
      }
    }
  }
}// MIT
pragma solidity ^0.8.0;


library SSTORE2 {

  error WriteError();

  function write(bytes memory _data) internal returns (address pointer) {

    bytes memory code = Bytecode.creationCodeFor(
      abi.encodePacked(
        hex'00',
        _data
      )
    );

    assembly { pointer := create(0, add(code, 32), mload(code)) }

    if (pointer == address(0)) revert WriteError();
  }

  function read(address _pointer) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, 1, type(uint256).max);
  }

  function read(address _pointer, uint256 _start) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, _start + 1, type(uint256).max);
  }

  function read(address _pointer, uint256 _start, uint256 _end) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, _start + 1, _end + 1);
  }
}/*
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░███░░████████░░███░░████████░░███░░░░░███░░███████░░███░░████████░░███░░░░░
  ░░░░░███░░░░░░░███░░███░░░░░░░███░░███░░░░░███░░███░░░░░░███░░███░░░░░░░███░░░░░
  ░░░░░████████░░███░░████████░░███░░███████████░░███░░███████░░███░░████████░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ████████████████████████████████████████████████████████████████████████████████
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░░░░░░                                                            ░░░░░░░░░░
  ░░░░░███░░          ██████████                    ██████████          ░░░░░███░░
  ░░░█████░░        ██          ███               ██          ███       ░░░██░░░░░
  ░░░░░░░░░░     ███  █████        ██          ███               ██     ░░░░░░░░░░
  ░░░░░░░░░░     ███  ███          ██          ███       █████   ██     ░░░░░░░░░░
  ░░░░░███░░     ███  █████        ██   █████  ███          ██   ██     ░░░░░███░░
  ░░░█████░░     ███  █████        ██          ███       █████   ██     ░░░██░░░░░
  ░░░░░░░░░░     ███               ██   █████  ███       █████   ██     ░░░░░░░░░░
  ░░░░░░░░░░        ██          ███               ██          ███       ░░░░░░░░░░
  ░░░█████░░          ██████████        █████       ██████████          ░░░░░███░░
  ░░░░░███░░                                                            ░░░██░░░░░
  ░░░░░░░░░░     █████          █████          █████          █████     ░░░░░░░░░░
  ░░░░░░░░░░     █████   █████  █████   █████     ██   █████  █████     ░░░░░░░░░░
  ░░░█████░░             █████          █████          █████            ░░░░░███░░
  ░░░░░███░░                                                            ░░░██░░░░░
  ░░░░░░░░░░                                                            ░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ████████████████████████████████████████████████████████████████████████████████
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░████████░░████████░░████████░░░░░░░░░░░░░░░██░░░██░░░██░░░██░░░██░░░██░░░░░
  ░░░░░███░░░░░░░███░░███░░████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░███░░░░░░░████████░░███░░███░░░░░░░░░░░░░░░██░░░██░░░██░░░██░░░██░░░██░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
*/

pragma solidity ^0.8.8;


contract OKPCParts is IOKPCParts {


  uint256 public constant NUM_COLORS = 6;
  uint256 public constant NUM_HEADBANDS = 8;
  uint256 public constant NUM_SPEAKERS = 8;
  uint256 public constant NUM_WORDS = 128;


  Color[NUM_COLORS] public colors;
  Vector[NUM_HEADBANDS] public headbands;
  Vector[NUM_SPEAKERS] public speakers;
  bytes4[NUM_WORDS] public words;


  constructor() {
    _initColors();
    _initHeadbands();
    _initSpeakers();
    _initWords();
  }


  function getColor(uint256 index) public view override returns (Color memory) {

    if (index > NUM_COLORS - 1) revert IndexOutOfBounds(index, NUM_COLORS - 1);
    return colors[index];
  }

  function getHeadband(uint256 index)
    public
    view
    override
    returns (Vector memory)
  {

    if (index > NUM_HEADBANDS - 1)
      revert IndexOutOfBounds(index, NUM_HEADBANDS - 1);
    return headbands[index];
  }

  function getSpeaker(uint256 index)
    public
    view
    override
    returns (Vector memory)
  {

    if (index > NUM_SPEAKERS - 1)
      revert IndexOutOfBounds(index, NUM_SPEAKERS - 1);
    return speakers[index];
  }

  function getWord(uint256 index) public view override returns (string memory) {

    if (index > NUM_WORDS - 1) revert IndexOutOfBounds(index, NUM_WORDS - 1);
    return _toString(words[index]);
  }



  function _initColors() internal {

    colors[0] = Color(
      bytes6('CCCCCC'),
      bytes6('838383'),
      bytes6('4D4D4D'),
      'Gray'
    );
    colors[1] = Color(
      bytes6('54F8B5'),
      bytes6('00DC82'),
      bytes6('037245'),
      'Green'
    );
    colors[2] = Color(
      bytes6('80B3FF'),
      bytes6('2E82FF'),
      bytes6('003D99'),
      'Blue'
    );
    colors[3] = Color(
      bytes6('DF99FF'),
      bytes6('C13CFF'),
      bytes6('750DA5'),
      'Purple'
    );
    colors[4] = Color(
      bytes6('FBDA9D'),
      bytes6('F8B73E'),
      bytes6('795106'),
      'Yellow'
    );
    colors[5] = Color(
      bytes6('FF99D8'),
      bytes6('FF44B7'),
      bytes6('99005E'),
      'Pink'
    );
  }

  function _initHeadbands() internal {

    headbands[0] = Vector(
      'M2 3H1V0H2V2H4V3H2ZM3 0H5H6V3H5V1H3V0ZM11 0H9V1H11V3H12V0H11ZM14 0H13V3H14H16H17V0H16V2H14V0ZM19 0H21V1H19V3H18V0H19ZM27 0H25H24V3H25V1H27V0ZM20 3V2H22V0H23V3H22H20ZM26 2V3H28H29V0H28V2H26ZM8 3H10V2H8V0H7V3H8Z',
      'Crest'
    );
    headbands[1] = Vector(
      'M11 1H12V0H11V1ZM11 2H10V1H11V2ZM13 2H11V3H13V2ZM14 1H13V2H14V1ZM16 1V0H14V1H16ZM17 2H16V1H17V2ZM19 2V3H17V2H19ZM19 1H20V2H19V1ZM19 1V0H18V1H19ZM0 1H1V2H0V1ZM1 2H2V3H1V2ZM3 1V0H1V1H3ZM4 2V1H3V2H4ZM5 2H4V3H5V2ZM6 1H5V2H6V1ZM8 1V0H6V1H8ZM8 2H9V1H8V2ZM8 2H7V3H8V2ZM24 1H25V2H24V1ZM22 1V0H24V1H22ZM22 2H21V1H22V2ZM22 2H23V3H22V2ZM26 2V3H25V2H26ZM27 1V2H26V1H27ZM29 1H27V0H29V1ZM29 2V1H30V2H29ZM29 2V3H28V2H29Z',
      'Ornate'
    );
    headbands[2] = Vector(
      'M3 0H1V1H3V2H1V3H3V2H4V3H6V2H4V1H6V0H4V1H3V0ZM27 0H29V1H27V0ZM27 2V1H26V0H24V1H26V2H24V3H26V2H27ZM27 2H29V3H27V2ZM10 0H12V1H10V0ZM10 2V1H9V0H7V1H9V2H7V3H9V2H10ZM10 2H12V3H10V2ZM18 0H20V1H18V0ZM21 1H20V2H18V3H20V2H21V3H23V2H21V1ZM21 1V0H23V1H21ZM16 0H15V1H14V3H15V2H16V0Z',
      'Power'
    );
    headbands[3] = Vector(
      'M1 3H2H3V2H2V1H4V3H5H7H8V1H10V3H11H14V2V1H16V2V3H19H20V1H22V3H23H25H26V1H28V2H27V3H28H29V0H28H26H25V2H23V0H22H20H19V2H17V1H18V0H12V1H13V2H11V0H10H8H7V2H5V0H4H2H1V3Z',
      'Temple'
    );
    headbands[4] = Vector(
      'M2 1H1V0H2V1ZM2 2V1H3V2H2ZM2 2V3H1V2H2ZM28 1H29V0H28V1ZM28 2V1H27V2H28ZM28 2H29V3H28V2ZM4 1H5V2H4V3H5V2H6V1H5V0H4V1ZM25 1H26V0H25V1ZM25 2V1H24V2H25ZM25 2H26V3H25V2ZM7 1H8V2H7V3H8V2H9V1H8V0H7V1ZM22 1H23V0H22V1ZM22 2V1H21V2H22ZM22 2H23V3H22V2ZM10 1H11V2H10V3H11V2H12V1H11V0H10V1ZM16 1H14V0H16V1ZM16 2V1H17V2H16ZM14 2H16V3H14V2ZM14 2V1H13V2H14ZM19 1H20V0H19V1ZM19 2V1H18V2H19ZM19 2H20V3H19V2Z',
      'Wreath'
    );
    headbands[5] = Vector(
      'M1 1H10V0H1V1ZM12 1H13V2H14V3H16V2H17V1H18V0H16V1V2H14V1V0H12V1ZM11 3H1V2H11V3ZM29 1H20V0H29V1ZM19 3H29V2H19V3Z',
      'Valiant'
    );
    headbands[6] = Vector(
      'M2 1H3V2H2V1ZM2 1H1V2H2V3H3V2H4V1H3V0H2V1ZM6 1H7V2H6V1ZM6 1H5V2H6V3H7V2H8V1H7V0H6V1ZM11 1H10V0H11V1ZM11 2V1H12V2H11ZM10 2H11V3H10V2ZM10 2V1H9V2H10ZM28 1H27V0H28V1ZM28 2V1H29V2H28ZM27 2H28V3H27V2ZM27 2V1H26V2H27ZM24 1H23V0H24V1ZM24 2V1H25V2H24ZM23 2H24V3H23V2ZM23 2V1H22V2H23ZM20 1H19V0H20V1ZM20 2V1H21V2H20ZM19 2H20V3H19V2ZM19 2V1H18V2H19ZM16 2H14V1H16V2ZM16 2V3H17V2H16ZM16 1V0H17V1H16ZM14 1H13V0H14V1ZM14 2V3H13V2H14Z',
      'Tainia'
    );
    headbands[7] = Vector(
      'M10 0H14V1H13V2H17V1H16V0H20V1H18V2H19V3H11V2H12V1H10V0ZM3 2H5V3H1V2H2V1H1V0H9V1H8V2H10V3H6V2H7V1H3V2ZM25 2H27V1H23V2H24V3H20V2H22V1H21V0H29V1H28V2H29V3H25V2Z',
      'Colossus'
    );
  }

  function _initSpeakers() internal {

    speakers[0] = Vector(
      'M1 1H0V2H1V3H2V2H1V1ZM1 5H0V6H1V7H2V6H1V5ZM0 9H1V10H0V9ZM1 10H2V11H1V10ZM1 13H0V14H1V15H2V14H1V13Z',
      'Piezo'
    );
    speakers[1] = Vector(
      'M1 1L1 0H0V1H1ZM1 2H2V1H1V2ZM1 2H0V3H1V2ZM1 10L1 11H0V10H1ZM1 9H2V10H1L1 9ZM1 9H0V8H1L1 9ZM1 4L1 5H0V6H1L1 7H2L2 6H1L1 5H2L2 4H1ZM1 13L1 12H2L2 13H1ZM1 14L1 13H0V14H1ZM1 14H2L2 15H1L1 14Z',
      'Ambient'
    );
    speakers[2] = Vector(
      'M0 2H1V3H2L2 1H1L1 0H0V2ZM1 5H2L2 7H1V6H0V4H1L1 5ZM2 14H1L1 15H0V13H1V12H2L2 14ZM2 10L2 8H1V9H0V11H1L1 10H2Z',
      'Hyper'
    );
    speakers[3] = Vector(
      'M1 1L1 0H0V1H1ZM1 1H2V2V3H1H0V2H1V1ZM1 5L1 4H2V5H1ZM1 5L1 6H2V7H1H0V6V5H1ZM1 13H0V12H1H2V13V14H1L1 13ZM1 14L1 15H0V14H1ZM2 9V8H1H0V9V10H1V11H2V10H1V9H2Z',
      'Crystal'
    );
    speakers[4] = Vector(
      'M2 0H1V1H0V2H1V3H2V0ZM2 5H1V4H0V7H1V6H2V5ZM2 9H1V8H0V11H1V10H2V9ZM0 13H1V12H2V15H1V14H0V13Z',
      'Taser'
    );
    speakers[5] = Vector(
      'M2 0V1V2V3H0V2H1V1V0H2ZM0 4V5V6V7H2V6H1L1 5H2V4H0ZM2 10V11H0V10H1V9H0V8H2V9V10ZM0 12V13H1V14V15H2V14L2 13V12H0Z',
      'Buster'
    );
    speakers[6] = Vector(
      'M0 0V1L2 1V0H0ZM1 3V2H2V3H1ZM2 5V4H0V5H2ZM1 11V10H2V11H1ZM2 13V12H0V13H2ZM2 15V14H1V15H2ZM2 7V6H1V7H2ZM0 8V9H2V8H0Z',
      'Tower'
    );
    speakers[7] = Vector(
      'M2 1V2V3H0V2L1 2V1H2ZM1 11V10H0V9H2L2 10V11H1ZM2 14V13H0V14H1V15H2V14ZM1 5V6H0V7H2L2 6V5H1Z',
      'Blaster'
    );
  }

  function _initWords() internal {

    words = [
      bytes4('WAIT'),
      'OK',
      'INFO',
      'HELP',
      'WARN',
      'ERR',
      'OOF',
      'WHAT',
      'RARE',
      '200%',
      'GATO',
      'ABRA',
      'POOF',
      'FUN',
      'BYTE',
      'POLY',
      'FANG',
      'PAIN',
      'BOOT',
      'DRAW',
      'MINT',
      'WORM',
      'PUP',
      'PLUS',
      'DOC',
      'QUIT',
      'BEAT',
      'MIDI',
      'UPUP',
      'HUSH',
      'ACK',
      'MOON',
      'GHST',
      'UFO',
      'SEE',
      'MON',
      'TRIP',
      'NICE',
      'YUP',
      'EXIT',
      'CUTE',
      'OHNO',
      'GROW',
      'DEAD',
      'OPEN',
      'THEM',
      'DRIP',
      'ESC',
      '404',
      'PSA',
      'BGS',
      'BOMB',
      'NOUN',
      'SKY',
      'SK8',
      'CATS',
      'CT',
      'GAME',
      'DAO',
      'BRAP',
      'LOOK',
      'MYTH',
      'ZERO',
      'QI',
      '5000',
      'LORD',
      'DUEL',
      'SWRD',
      'MEME',
      'SAD',
      'ORB',
      'LIFE',
      'PRTY',
      'DEF',
      'AIR',
      'ISLE',
      'ROSE',
      'ANON',
      'OKOK',
      'MEOW',
      'KING',
      'WISE',
      'ROZE',
      'NOBU',
      'DAMN',
      'HUNT',
      'BETA',
      'FORT',
      'SWIM',
      'HALO',
      'UP',
      'YUM',
      'SNAP',
      'APES',
      'BIRD',
      'NOON',
      'VIBE',
      'MAKE',
      'CRWN',
      'PLAY',
      'JOY',
      'FREN',
      'DING',
      'GAZE',
      'HACK',
      'CRY',
      'SEER',
      'OWL',
      'LOUD',
      'RISE',
      'LOVE',
      'SKRT',
      'QTPI',
      'WAND',
      'REKT',
      'BEAR',
      'CODA',
      'ILY',
      'SNKE',
      'FLY',
      'ZKP',
      'LUSH',
      'SUP',
      'GOWN',
      'BAG',
      'BALM',
      'LIVE',
      'LVL'
    ];
  }


  function _toString(bytes4 b) private pure returns (string memory) {

    uint256 numChars = 0;

    for (uint256 i; i < 4; i++) {
      if (b[i] == bytes1(0)) break;
      numChars++;
    }

    bytes memory result = new bytes(numChars);
    for (uint256 i; i < numChars; i++) result[i] = b[i];

    return string(abi.encodePacked(result));
  }
}//Unlicense
pragma solidity ^0.8.7;

interface IOKPCFont {

  error CharacterNotFound();
  error NotSingleCharacter();

  function getChar(string memory char) external view returns (string memory);


  function getChar(bytes1) external view returns (string memory);

}//Unlicense
pragma solidity ^0.8.8;


interface IOKPCMetadata {

  error InvalidTokenID();
  error NotEnoughPixelData();

  struct Parts {
    IOKPCParts.Vector headband;
    IOKPCParts.Vector rightSpeaker;
    IOKPCParts.Vector leftSpeaker;
    IOKPCParts.Color color;
    string word;
  }

  function tokenURI(uint256 tokenId) external view returns (string memory);


  function drawOKPC(uint256 tokenId) external view returns (string memory);


  function drawOKPC(
    uint256 speed,
    bytes memory art,
    Parts memory parts
  ) external view returns (string memory);


  function renderArt(bytes memory art, uint256 colorIndex)
    external
    view
    returns (string memory);


  function getParts(uint256 tokenId) external view returns (Parts memory);


  function drawArt(bytes memory artData) external pure returns (string memory);

}//Unlicense
pragma solidity ^0.8.8;


interface IOKPCGenesisArtwork {

  function getGenesisArtwork(uint256)
    external
    view
    returns (uint256, IOKPC.Art memory);

}//Unlicense
pragma solidity ^0.8.0;

interface IReverseRegistrar {

  function node(address addr) external view returns (bytes32);

}

interface IReverseResolver {

  function name(bytes32 node) external view returns (string memory);

}

contract ENSNameResolver {

  IReverseRegistrar constant registrar =
    IReverseRegistrar(0x084b1c3C81545d370f3634392De611CaaBFf8148);
  IReverseResolver constant resolver =
    IReverseResolver(0xA2C122BE93b0074270ebeE7f6b7292C7deB45047);

  function getENSName(address addr) public view returns (string memory) {

    try resolver.name(registrar.node(addr)) {
      return resolver.name(registrar.node(addr));
    } catch {
      return '';
    }
  }
}/*
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░█████░░░░░░░░█████░░░░░░░███░░░░░█████░░░░░██░░░░░░░░█████░░░░░░░█████░░░░░
  ░░░██░░░░░███░░███░░░░░██░░░██░░░░░███░░░░░██░░░░░███░░███░░░░░██░░░██░░░░░███░░
  ░░░░░███░░░░░██░░░░░███░░░░░░░█████░░░░░░░░░░█████░░░░░░░░██░░░░░███░░░░░██░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ████████████████████████████████████████████████████████████████████████████████
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░██░░░░░                                                            ░░░░░███░░
  ░░░░░███░░                                                            ░░░██░░░░░
  ░░░█████░░          ██████████                    ██████████          ░░░░░███░░
  ░░░░░░░░░░        ██          ███               ██          ███       ░░░░░░░░░░
  ░░░░░███░░     ███       █████   ██          ███       █████   ██     ░░░██░░░░░
  ░░░██░░░░░     ███          ██   ██   █████  ███          ██   ██     ░░░░░███░░
  ░░░█████░░     ███       █████   ██          ███       █████   ██     ░░░██░░░░░
  ░░░░░░░░░░     ███       █████   ██   █████  ███       █████   ██     ░░░░░░░░░░
  ░░░█████░░     ███               ██          ███               ██     ░░░░░███░░
  ░░░██░░░░░        ███████████████     █████     ███████████████       ░░░██░░░░░
  ░░░░░███░░                                                            ░░░░░███░░
  ░░░░░░░░░░     █████                                        █████     ░░░░░░░░░░
  ░░░█████░░     █████   █████  █████   █████  █████   █████  █████     ░░░██░░░░░
  ░░░░░███░░             █████  █████   █████     ██   █████            ░░░░░███░░
  ░░░██░░░░░                                                            ░░░██░░░░░
  ░░░░░░░░░░                                                            ░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ████████████████████████████████████████████████████████████████████████████████
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░█████░░░░░████████░░███░░███░░░░░░░░░░░░░░░██░░░██░░░██░░░██░░░██░░░██░░░░░
  ░░░░░███░░███░░█████░░░░░░░░██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░████████░░███░░░░░░░███░░███░░░░░░░░░░░░░░░██░░░██░░░██░░░██░░░██░░░██░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
*/

pragma solidity ^0.8.13;


contract OKPCMetadata is IOKPCMetadata, Ownable, ENSNameResolver {


  using DynamicBuffer for bytes;
  string public FALLBACK_URL = 'https://okpc.app/api/okpc/';
  string public DESCRIPTION_URL = 'https://okpc.app/gallery/';


  IOKPC private _okpc;
  OKPCParts private _parts;
  IOKPCFont private _font;
  IOKPCGenesisArtwork private _genesisArtwork;


  constructor(
    address okpcAddress,
    address partsAddress,
    address fontAddress,
    address genesisArtworkAddress
  ) {
    _okpc = IOKPC(okpcAddress);
    _parts = OKPCParts(partsAddress);
    _font = IOKPCFont(fontAddress);
    _genesisArtwork = IOKPCGenesisArtwork(genesisArtworkAddress);
  }


  function setParts(address partsAddress) public onlyOwner {

    _parts = OKPCParts(partsAddress);
  }

  function setFont(address fontAddress) public onlyOwner {

    _font = IOKPCFont(fontAddress);
  }

  function setGenesisArtworkAddress(address genesisArtworkAddress)
    public
    onlyOwner
  {

    _genesisArtwork = IOKPCGenesisArtwork(genesisArtworkAddress);
  }

  function setFallbackURL(string memory url) public onlyOwner {

    FALLBACK_URL = url;
  }

  function setDescriptionURL(string memory url) public onlyOwner {

    DESCRIPTION_URL = url;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {

    if (tokenId < 1 || tokenId > 8192) revert InvalidTokenID();

    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          _getMetadataJSON(tokenId)
        )
      );
  }

  function _getMetadataJSON(uint256 tokenId)
    internal
    view
    returns (string memory)
  {

    Parts memory parts = getParts(tokenId);
    uint256 artId = _okpc.activeArtForOKPC(tokenId);
    uint256 clockSpeed = _okpc.clockSpeed(tokenId);
    uint256 artCollected = _okpc.artCountForOKPC(tokenId);
    bool useOffChainRenderer = _okpc.useOffchainMetadata(tokenId);

    bool isCustomArt = artId == 0;
    IOKPC.Art memory art = isCustomArt
      ? _okpc.getPaintArt(tokenId)
      : _okpc.getGalleryArt(artId);

    bytes memory artData = abi.encodePacked(art.data1, art.data2);
    if (artData.length < 56) revert NotEnoughPixelData();

    (, IOKPC.Art memory shippedWithArt) = _genesisArtwork.getGenesisArtwork(
      tokenId
    );

    return
      Base64.encode(
        abi.encodePacked(
          _getMetadataHeader(tokenId, parts, art),
          useOffChainRenderer
            ? abi.encodePacked(FALLBACK_URL, toString(tokenId), '/img')
            : abi.encodePacked(
              'data:image/svg+xml;base64,',
              drawOKPC(clockSpeed, artData, parts)
            ),
          '", "attributes": ',
          _getAttributes(
            parts,
            clockSpeed,
            artCollected,
            art,
            shippedWithArt,
            useOffChainRenderer,
            isCustomArt
          ),
          '}'
        )
      );
  }

  function renderArt(bytes memory art, uint256 colorIndex)
    public
    view
    returns (string memory)
  {
    OKPCParts.Color memory color = _parts.getColor(colorIndex);

    return
      string(
        abi.encodePacked(
          '<svg viewBox="0 0 24 16" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges" height="512" width="512" fill="#',
          color.dark,
          '"><rect width="24" height="16" fill="#',
          color.light,
          '"/>',
          drawArt(art),
          '</svg>'
        )
      );
  }

  function getParts(uint256 tokenId)
    public
    view
    override
    returns (Parts memory)
  {
    if (tokenId < 1 || tokenId > 8192) revert InvalidTokenID();
    Parts memory parts;

    if (tokenId <= 128) {
      parts.color = _parts.getColor((tokenId - 1) % _parts.NUM_COLORS());
      parts.word = _parts.getWord(tokenId - 1);
    } else {
      parts.color = _parts.getColor(
        uint256(keccak256(abi.encodePacked('COLOR', tokenId))) %
          _parts.NUM_COLORS()
      );
      parts.word = _parts.getWord(
        uint256(keccak256(abi.encodePacked('WORD', tokenId))) %
          _parts.NUM_WORDS()
      );
    }

    parts.headband = _parts.getHeadband(
      uint256(keccak256(abi.encodePacked('HEADBAND', tokenId))) %
        _parts.NUM_HEADBANDS()
    );
    parts.rightSpeaker = _parts.getSpeaker(
      uint256(keccak256(abi.encodePacked('RIGHT SPEAKER', tokenId))) %
        _parts.NUM_SPEAKERS()
    );
    parts.leftSpeaker = _parts.getSpeaker(
      uint256(keccak256(abi.encodePacked('LEFT SPEAKER', tokenId))) %
        _parts.NUM_SPEAKERS()
    );

    return parts;
  }

  function drawOKPC(uint256 tokenId) public view returns (string memory) {
    uint256 artId = _okpc.activeArtForOKPC(tokenId);
    uint256 clockSpeed = _okpc.clockSpeed(tokenId);
    bool isCustomArt = artId == 0;
    IOKPC.Art memory art = isCustomArt
      ? _okpc.getPaintArt(tokenId)
      : _okpc.getGalleryArt(artId);
    bytes memory artData = abi.encodePacked(art.data1, art.data2);

    if (artData.length < 56) revert NotEnoughPixelData();
    Parts memory parts = getParts(tokenId);

    return drawOKPC(clockSpeed, artData, parts);
  }

  function drawOKPC(
    uint256 speed,
    bytes memory art,
    Parts memory parts
  ) public view returns (string memory) {
    bytes memory svg = abi.encodePacked(
      abi.encodePacked(
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges" fill="#',
        parts.color.dark,
        '" height="512" width="512"><rect width="32" height="32" fill="#',
        parts.color.regular,
        '"/><rect x="4" y="8" width="24" height="16" fill="#',
        parts.color.light,
        '"/><rect width="32" height="1" x="0" y="5" /><rect width="32" height="1" x="0" y="26" /><path transform="translate(1,1)" d="',
        parts.headband.data,
        '"/><path transform="translate(1, 8)" d="',
        parts.leftSpeaker.data,
        '"/><path transform="translate(31, 8) scale(-1,1)" d="',
        parts.rightSpeaker.data,
        '"/><g transform="translate(4, 8)" fill-rule="evenodd" clip-rule="evenodd">'
      ),
      drawArt(art),
      '</g>',
      _drawWord(parts.word),
      '<g transform="translate(19, 28)">',
      _drawClockSpeed(speed, parts),
      '</g></svg>'
    );

    return Base64.encode(svg);
  }

  function drawArt(bytes memory artData)
    public
    pure
    override
    returns (string memory)
  {
    bytes memory rects = DynamicBuffer.allocate(2**16); // Allocate 64KB of memory, we will not use this much, but it's safe.
    uint256 offset = 8;

    for (uint256 pixelNum = 0; pixelNum < 384; pixelNum += 8) {
      uint8 workingByte = uint8(artData[offset + (pixelNum / 8)]);
      uint256 y = uint256(pixelNum / 24);
      uint256 x = uint256(pixelNum % 24);

      for (uint256 i; i < 8; i++) {
        if ((workingByte >> (7 - i)) & 1 == 1) {
          rects.appendSafe(
            abi.encodePacked(
              '<rect width="1" height="1" x="',
              toString(x + i),
              '" y="',
              toString(y),
              '"/>'
            )
          );
        }
      }
    }

    return string(rects);
  }

  function _drawWord(string memory word) internal view returns (bytes memory) {
    bytes memory wordBytes = bytes(word);
    bytes memory path;

    for (uint256 i; i < wordBytes.length; i++) {
      if (wordBytes[i] != 0x0) {
        path = abi.encodePacked(
          path,
          '<path clip-rule="evenodd" fill-rule="evenodd" transform="translate(',
          toString(2 + i * 4),
          ',28)" d="',
          _font.getChar(wordBytes[i]),
          '"/>'
        );
      } else {
        break;
      }
    }

    return path;
  }

  function _drawClockSpeed(uint256 speed, Parts memory parts)
    internal
    pure
    returns (bytes memory)
  {
    bytes memory clockSpeedPixels = DynamicBuffer.allocate(2**16); // Allocate 64KB of memory, we will not use this much, but it's safe.
    bytes6 color;

    for (uint256 i; i < 12; i++) {
      uint256 x = 10 - ((i / 2) * 2);
      uint256 y = (i % 2 == 0) ? 2 : 0;
      if (i < speed / 128) color = parts.color.light;
      else color = parts.color.dark;

      clockSpeedPixels.appendSafe(
        abi.encodePacked(
          '<rect width="1" height="1" x="',
          toString(x),
          '" y="',
          toString(y),
          '" fill="#',
          color,
          '"/>'
        )
      );
    }

    return clockSpeedPixels;
  }

  function _getMetadataHeader(
    uint256 tokenId,
    Parts memory parts,
    IOKPC.Art memory art
  ) internal view returns (bytes memory) {
    string memory artistENS = ENSNameResolver.getENSName(art.artist);
    return
      abi.encodePacked(
        '{"name": "OKPC #',
        toString(tokenId),
        '", "description": "A ',
        parts.color.name,
        " OKPC displaying '",
        bytes16ToString(art.title),
        "' by [",
        bytes(artistENS).length > 0
          ? artistENS
          : string(abi.encodePacked('0x', toAsciiString(art.artist))),
        '](',
        DESCRIPTION_URL,
        string(abi.encodePacked('0x', toAsciiString(art.artist))),
        ')", "image": "'
      );
  }

  function _getAttributes(
    Parts memory parts,
    uint256 speed,
    uint256 artCollected,
    IOKPC.Art memory art,
    IOKPC.Art memory shippedWithArt,
    bool isFallbackRenderer,
    bool isCustomArt
  ) internal view returns (bytes memory) {
    return
      abi.encodePacked(
        _getAttributeSet1(parts, speed, artCollected),
        _getAttributeSet2(art, shippedWithArt, isFallbackRenderer, isCustomArt)
      );
  }

  function _getAttributeSet1(
    Parts memory parts,
    uint256 speed,
    uint256 artCollected
  ) internal pure returns (bytes memory) {
    string memory word = parts.word;
    if (keccak256(abi.encodePacked(word)) == keccak256('200%'))
      word = string(abi.encodePacked('200', '\xEF\xBC\x85'));

    return
      abi.encodePacked(
        '[{"trait_type":"Art Collected", "value": ',
        toString(artCollected),
        '}, {"trait_type":"Word", "value": "',
        word,
        '"}, {"trait_type": "Color", "value": "',
        parts.color.name,
        abi.encodePacked(
          '"}, {"trait_type": "Headband", "value": "',
          parts.headband.name,
          '"}, {"trait_type": "Right Speaker", "value": "',
          parts.rightSpeaker.name,
          '"}, {"trait_type": "Left Speaker", "value": "',
          parts.leftSpeaker.name,
          '"}, {"trait_type": "Clock Speed", "value": "',
          toString(speed)
        )
      );
  }

  function _getAttributeSet2(
    IOKPC.Art memory art,
    IOKPC.Art memory shippedWithArt,
    bool isFallbackRenderer,
    bool isCustomArt
  ) internal view returns (bytes memory) {
    string memory artistENS = ENSNameResolver.getENSName(art.artist);
    string memory shippedWithENS = ENSNameResolver.getENSName(
      shippedWithArt.artist
    );

    return
      abi.encodePacked(
        '"}, {"trait_type": "Art", "value": "',
        bytes16ToString(art.title),
        '"}, {"trait_type": "Renderer", "value": "',
        isFallbackRenderer ? 'Off Chain' : 'On Chain',
        '"}, {"trait_type": "Screen", "value": "',
        isCustomArt ? 'Custom Art' : 'Gallery Art',
        abi.encodePacked(
          '"}, {"trait_type": "Artist", "value": "',
          bytes(artistENS).length > 0
            ? artistENS
            : string(abi.encodePacked('0x', toAsciiString(art.artist))),
          '"}, {"trait_type": "Shipped With", "value": "',
          bytes16ToString(shippedWithArt.title),
          ' by ',
          bytes(shippedWithENS).length > 0
            ? shippedWithENS
            : string(
              abi.encodePacked('0x', toAsciiString(shippedWithArt.artist))
            ),
          '"}]'
        )
      );
  }

  function toString(uint256 value) internal pure returns (string memory) {

    if (value == 0) {
      return '0';
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  function bytes16ToString(bytes16 x) internal pure returns (string memory) {
    uint256 numChars = 0;

    for (uint256 i; i < 16; i++) {
      if (x[i] == bytes1(0)) break;
      numChars++;
    }

    bytes memory result = new bytes(numChars);
    for (uint256 i; i < numChars; i++) result[i] = x[i];

    return string(result);
  }

  function toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint256 i; i < 20; i++) {
      bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
      bytes1 hi = bytes1(uint8(b) / 16);
      bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
      s[2 * i] = char(hi);
      s[2 * i + 1] = char(lo);
    }
    return string(s);
  }

  function char(bytes1 b) internal pure returns (bytes1 c) {
    if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    else return bytes1(uint8(b) + 0x57);
  }
}