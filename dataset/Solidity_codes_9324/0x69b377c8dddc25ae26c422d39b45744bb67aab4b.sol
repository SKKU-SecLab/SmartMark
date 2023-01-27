pragma solidity ^0.8.12;

library utils {

    string internal constant NULL = '';

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return '0';
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
pragma solidity ^0.8.12;

library svg {


    function circle(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('circle', _props, _children);
    }

    function circle(string memory _props)
        internal
        pure
        returns (string memory)
    {

        return el('circle', _props);
    }

    function rect(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('rect', _props, _children);
    }

    function rect(string memory _props)
        internal
        pure
        returns (string memory)
    {

        return el('rect', _props);
    }


    function radialGradient(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('radialGradient', _props, _children);
    }

    function gradientStop(
        uint256 offset,
        string memory stopColor,
        string memory _props
    ) internal pure returns (string memory) {

        return
            el(
                'stop',
                string.concat(
                    prop('stop-color', stopColor),
                    ' ',
                    prop('offset', string.concat(utils.uint2str(offset), '%')),
                    ' ',
                    _props
                )
            );
    }



    function el(
        string memory _tag,
        string memory _props,
        string memory _children
    ) internal pure returns (string memory) {

        return
            string.concat(
                '<',
                _tag,
                ' ',
                _props,
                '>',
                _children,
                '</',
                _tag,
                '>'
            );
    }

    function el(
        string memory _tag,
        string memory _props
    ) internal pure returns (string memory) {

        return
            string.concat(
                '<',
                _tag,
                ' ',
                _props,
                '/>'
            );
    }

    function prop(string memory _key, string memory _val)
        internal
        pure
        returns (string memory)
    {

        return string.concat(_key, '=', '"', _val, '" ');
    }
}
pragma solidity ^0.8.11;



interface SphereInterface {

    function balanceOf(address owner) external view returns (uint256 balance);

}
interface KarmicInterface {

    function allBalancesOf(address holder) external view returns (uint256[] memory balances);

}

contract Renderer {

    address sphereNFTAddress = address(0x2346358D22b8b59f25A1Cf05BbE86FE762db6134);
    address karmicAddress = address(0xe323C27212F34fCEABBBd98A5f43505dDeC266Dc); 
    SphereInterface sphereInterface = SphereInterface(sphereNFTAddress);
    KarmicInterface karmicInterface = KarmicInterface(karmicAddress);

    struct SphereProps {
        uint stop1;
        string color1;
        string color2;
        uint16 radius;
        uint posY;
        uint ind;
    }

    function _render(uint256 _tokenId, address _owner, uint256 _birthdate) internal view returns (string memory) {

        uint elapsed = (block.timestamp - _birthdate) /  1 weeks;
        uint age = _sqrtu(2 * elapsed) + 3;
        string[2][2] memory colors = _setColors(_tokenId, _owner);
        string memory bgColPick = _bgColor(_owner);
        string memory bordCol;
        if ((keccak256(abi.encodePacked(bgColPick))) == (keccak256(abi.encodePacked('#FFFFFF')))) { 
            bordCol = 'black'; 
            } else {
                bordCol = 'white'; 
        } 

        return
            string.concat(
                string.concat('<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="2400" style="background:', _bgColor(_owner),'">'),
                _sphereGen(_tokenId, _owner, age, colors),
                _drawBorder(bordCol),                
                '</svg>'
            );
    }

    function _setColors(uint256 _tokenId, address _owner) internal pure returns(string[2][2] memory) {

        string[2][2] memory randClr;
        randClr[0][0] = string.concat('hsl(', utils.uint2str(_random(_tokenId, 1, _owner,  'clrs') % 360), ', 36%, 65%, 0%)');
        randClr[0][1] = string.concat('hsl(', utils.uint2str(_random(_tokenId, 1, _owner,  'clrs') % 360), ', 36%, 65%, 78%)');
        randClr[1][0] = string.concat('hsl(', utils.uint2str(_random(_tokenId, 2, _owner,  'clrs') % 360), ', 36%, 65%, 0%)');
        randClr[1][1] = string.concat('hsl(', utils.uint2str(_random(_tokenId, 2, _owner,  'clrs') % 360), ', 36%, 65%, 78%)');
        return randClr;
    }

    function _sphereGen(uint _tokenId, address _owner, uint _age, string[2][2] memory _colors) internal pure returns (string memory) {

        string memory spheresSVG;
        for (uint i = 0; i < _age; i++) {
            SphereProps memory sphereProp;
            uint colorPick = _random(_tokenId, i, _owner, 'r') % 2;
            sphereProp.ind = i;
            sphereProp.stop1 = _random(_tokenId, i, _owner, 'stop1') % 90;
            sphereProp.color1 = _colors[colorPick][0];
            sphereProp.color2 = _colors[colorPick][1];
            sphereProp.radius = uint16(_random(_tokenId, i, _owner, 'r') % ((800) -(186+45)) +45);
            uint16[3] memory yPositions = [
                uint16(sphereProp.radius + 186), 
                uint16(1200), 
                uint16(2400 - 186 -sphereProp.radius)]; //possible sphere positions for top,center, bottom
            sphereProp.posY = yPositions[_random(_tokenId, i, _owner, 'pY') % 3];
            spheresSVG = string.concat(spheresSVG, _spheres(sphereProp));

        }
        return spheresSVG;
    }

    function _spheres(SphereProps memory _sphereProp) internal pure returns(string memory) {

        return string.concat(
            
            svg.radialGradient(
                string.concat(
                    svg.prop('id', string.concat('sphereGradient', utils.uint2str(_sphereProp.ind)))
                ),
                string.concat(
                    svg.gradientStop(80, _sphereProp.color1, utils.NULL), //first stop amount should be random
                    svg.gradientStop(100,_sphereProp.color2,utils.NULL)

                )
            ),

            svg.circle(
                string.concat(
                    svg.prop('cx', utils.uint2str(800)),
                    svg.prop('cy', utils.uint2str(_sphereProp.posY)),
                    svg.prop('r', utils.uint2str(_sphereProp.radius)),
                    svg.prop('fill', string.concat("url('#sphereGradient", utils.uint2str(_sphereProp.ind), "')"))
                ),
                utils.NULL
            )
        );
    }

    function _random(uint _tokenId, uint _ind, address _owner, string memory _prop) internal pure returns (uint) {

        return uint(keccak256(abi.encodePacked(_ind, _owner, _tokenId, _prop)));
    }

    function _bgColor(address _owner) internal view returns (string memory) {

        bool sphereHolder = (sphereInterface.balanceOf(_owner) > 0);
        uint256[] memory karmics = karmicInterface.allBalancesOf(_owner);
        bool karmicHolder = false;
        
        for(uint i = 0; i < karmics.length; i++) {
            if (karmics[i] > 0) { karmicHolder = true; }
        }
        
        if (karmicHolder && sphereHolder) {
            return '#FFFFFF';
        } else if (karmicHolder) {
            return '#733700';
        } else if (sphereHolder) {
            return '#000957';
        } else {
            return '#000000';
        }
    }

    function _drawBorder(string memory _bordCol) internal pure returns(string memory) {

        return 
        string.concat(
            _rects(80,80,1440,2240,_bordCol),
            _rects(106,106,1388,2188,_bordCol),
            _rects(80,80,68,52,_bordCol),
            _rects(1452,80,68,52,_bordCol),
            _rects(80,2268,68,52,_bordCol),
            _rects(1452,2268,68,52,_bordCol)
        );

    }

    function _rects(uint _x, uint _y,uint  _width,uint _height, string memory _bordCol) internal pure returns(string memory) {

        return svg.rect(
            string.concat(
                svg.prop('x', utils.uint2str(_x)),
                svg.prop('y', utils.uint2str(_y)),
                svg.prop('width', utils.uint2str(_width)),
                svg.prop('height', utils.uint2str(_height)),
                svg.prop('stroke', _bordCol),
                svg.prop('fill-opacity', utils.uint2str(0)),
                svg.prop('stroke-width', utils.uint2str(3))
            ),
            utils.NULL
        );
    }

    function _sqrtu (uint256 x) internal pure returns (uint128) {
        unchecked {
        if (x == 0) return 0;
        else {
            uint256 xx = x;
            uint256 r = 1;
            if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
            if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
            if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
            if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
            if (xx >= 0x100) { xx >>= 8; r <<= 4; }
            if (xx >= 0x10) { xx >>= 4; r <<= 2; }
            if (xx >= 0x8) { r <<= 1; }
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1; // Seven iterations should be enough
            uint256 r1 = x / r;
            return uint128 (r < r1 ? r : r1);
        }
        }
    }

}
pragma solidity ^0.8.2;

library Base64 {

  bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

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
        out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
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
pragma solidity ^0.8.13;



contract Spherical is Renderer {

    error Soulbound();

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    string public constant symbol = "OOOO";

    string public constant name = "Spherical";

    address public immutable owner = msg.sender;
    address[2] public admins = [address(0xA6aF4168482CE3c40dedAb6A45F194a2B4a3FF33), address(0x2ac85F79d0FBE628594F7BC1d2311cDF700EF57A) ];

    address payable public constant sphereAdr = payable(0x2ac85F79d0FBE628594F7BC1d2311cDF700EF57A);
    address payable public constant espinaAdr = payable(0x5706542bb1e2eA5A10f820eA9E23AEfCe4858629);

    mapping(uint256 => address) public ownerOf;

    mapping(address => uint256) public balanceOf;

    mapping(uint256 => uint256) public birthOf;

    uint256 internal nextTokenId = 1;

    constructor() payable {}

    function approve(address, uint256) public virtual {

        revert Soulbound();
    }

    function isApprovedForAll(address, address) public pure {

        revert Soulbound();
    }

    function getApproved(uint256) public pure {

        revert Soulbound();
    }

    function setApprovalForAll(address, bool) public virtual {

        revert Soulbound();
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual {

        revert Soulbound();
    }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) public virtual {

        revert Soulbound();
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual {

        revert Soulbound();
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {

        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    function withdraw() public {

        uint256 espinaShare = address(this).balance / 10;
        uint256 sphereShare = address(this).balance - espinaShare;
        payable(espinaAdr).transfer(espinaShare);
        payable(sphereAdr).transfer(sphereShare);
    }

    function mint(address to) external payable {

        require(msg.value == 0.25 ether, 'Wrong amount of ETH sent');
        require(balanceOf[to] == 0, 'You can only mint one');

        unchecked {
            balanceOf[to]++;
        }

        ownerOf[nextTokenId] = to;
        birthOf[nextTokenId] = block.timestamp;

        emit Transfer(address(0), to, nextTokenId++);
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {

        require(ownerOf[_tokenId] != address(0), 'Token does not exist');
        address tokenOwner = ownerOf[_tokenId];
        uint256 birthdate = birthOf[_tokenId];
        string memory svgString = _render(_tokenId, tokenOwner, birthdate);
        return _metadata(_tokenId, svgString);
    }

    function _metadata(uint256 _tokenId, string memory _svgString) internal pure returns (string memory) {

        string memory tokenName = string(abi.encodePacked('Spherical #', utils.uint2str(_tokenId)));
        string memory tokenDescription = "The Sphere is a research-creation project developing new ecologies of funding for the performing arts. We envisage a world in which audiences co-own the artworks they love together with the artists, collectors and other stakeholders of a given project.\\nWebsite: [thesphere.as](https://thesphere.as)  Twitter: [@thesphere_as](https://twitter.com/thesphere_as)\\n\\nThe Spherical GeNFTs are dynamic on-chain generative artworks that evolve over time as an expression of membership in The Sphere. The particularities of the holder's wallet become the seed for an ongoing creation.";
        string memory json = string(
            abi.encodePacked('{"name":"', 
            tokenName, '","description":"', 
            tokenDescription, '","image": "data:image/svg+xml;base64,', 
            Base64.encode(bytes(_svgString)), '"}')
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function airdrop(address[] calldata _recipients) public {

        require((msg.sender == admins[0] || msg.sender == admins[1]), 'Not allowed to airdop');

        for (uint i = 0; i< _recipients.length; i++){
            
            unchecked {
                balanceOf[_recipients[i]]++;
            }

            ownerOf[nextTokenId] = _recipients[i];
            birthOf[nextTokenId] = block.timestamp;

            emit Transfer(address(0), _recipients[i], nextTokenId++);
        }
    }

    function changeAdmin(address _newAdmin, uint adminId) public {

        require(adminId <= 1, 'Only two admins');
        require((msg.sender == admins[0] || msg.sender == admins[1]), 'Only admin can change');
        admins[adminId] = _newAdmin;
    }

    function burn(uint256 _tokenId) public {

        require(msg.sender == ownerOf[_tokenId], 'Only owner can burn');
        balanceOf[msg.sender] = 0;
        ownerOf[_tokenId] = address(0);
        birthOf[_tokenId] = block.timestamp;

        emit Transfer(msg.sender, address(0), _tokenId);
    }
}

