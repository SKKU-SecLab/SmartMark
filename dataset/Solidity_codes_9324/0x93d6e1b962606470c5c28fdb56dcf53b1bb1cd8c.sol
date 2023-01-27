
pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
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
pragma solidity 0.8.9;

enum IngredientType {
    Base,
    Sauce,
    Cheese,
    Meat,
    Topping
}

struct Ingredient {
    string name;
    IngredientType ingredientType;
    address artist;
    uint256 price;
    uint256 supply;
    uint256 initialSupply;
}

struct Pizza {
    uint16 base;
    uint16 sauce;
    uint16[3] cheeses;
    uint16[4] meats;
    uint16[4] toppings;
}

interface ILazlosIngredients {

    function getNumIngredients() external view returns (uint256);

    function getIngredient(uint256 tokenId) external view returns (Ingredient memory);

    function increaseIngredientSupply(uint256 tokenId, uint256 amount) external;

    function decreaseIngredientSupply(uint256 tokenId, uint256 amount) external;

    function mintIngredients(address addr, uint256[] memory tokenIds, uint256[] memory amounts) external;

    function burnIngredients(address addr, uint256[] memory tokenIds, uint256[] memory amounts) external;

    function balanceOfAddress(address addr, uint256 tokenId) external view returns (uint256);

}

interface ILazlosPizzas {

    function bake(address baker, Pizza memory pizza) external returns (uint256);

    function rebake(address baker, uint256 pizzaTokenId, Pizza memory pizza) external;

    function pizza(uint256 tokenId) external view returns (Pizza memory);

    function burn(uint256 tokenId) external;

}

interface ILazlosRendering {

    function ingredientTokenMetadata(uint256 id) external view returns (string memory); 

    function pizzaTokenMetadata(uint256 id) external view returns (string memory); 

}// MIT
pragma solidity 0.8.9;



contract LazlosPizzaShop is Ownable, ReentrancyGuard {

    using ECDSA for bytes32;
    using Counters for Counters.Counter;
    using Strings for uint256;

    bool public mintingOn = true;
    bool public bakeRandomPizzaOn = true;
    uint256 public bakePizzaPrice = 0.01 ether;
    uint256 public unbakePizzaPrice = 0.05 ether;
    uint256 public rebakePizzaPrice = 0.01 ether;
    uint256 public randomBakePrice = 0.05 ether;
    address public pizzaContractAddress;
    address public ingredientsContractAddress;
    address private systemAddress;
    mapping(address => uint256) artistWithdrawalAmount;
    mapping(uint256 => mapping(address => bool)) isPaidByBlockAndAddress;

    function setMintingOn(bool on) public onlyOwner {

        mintingOn = on;
    }

    function setBakeRandomPizzaOn(bool on) public onlyOwner {

        bakeRandomPizzaOn = on;
    }

    function setPizzaContractAddress(address addr) public onlyOwner {

        pizzaContractAddress = addr;
    }

    function setIngredientsContractAddress(address addr) public onlyOwner {

        ingredientsContractAddress = addr;
    }
    
    function setSystemAddress(address addr) public onlyOwner {

        systemAddress = addr;
    }

    function buyIngredients(uint256[] memory tokenIds, uint256[] memory amounts) public payable nonReentrant {

        require(mintingOn, 'minting must be on');
        
        uint256 expectedPrice;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 amount = amounts[i];

            Ingredient memory ingredient = ILazlosIngredients(ingredientsContractAddress).getIngredient(tokenId);
            require(bytes(ingredient.name).length != 0, 'Ingredient does not exist');
            require(ingredient.supply >= amount, 'Not enough ingredient leftover.');

            ILazlosIngredients(ingredientsContractAddress).decreaseIngredientSupply(tokenId, amount);

            unchecked {
                expectedPrice += ingredient.price * amount;
            }
        }
        
        require(expectedPrice == msg.value, 'Invalid price.');

        ILazlosIngredients(ingredientsContractAddress).mintIngredients(msg.sender, tokenIds, amounts);
    }

    function bakePizza(uint256[] memory tokenIds) public payable nonReentrant returns (uint256) {

        require(mintingOn, 'minting must be on');
        require(msg.value == bakePizzaPrice, 'Invalid price.');
        return _bakePizza(tokenIds, true);
    }

    function buyAndBakePizza(uint256[] memory tokenIds) public payable nonReentrant returns (uint256) {

        require(mintingOn, 'minting must be on');

        uint256 expectedPrice = bakePizzaPrice;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            Ingredient memory ingredient = ILazlosIngredients(ingredientsContractAddress).getIngredient(tokenId);
            require(ingredient.supply >= 1, 'Ingredient sold out.');

            ILazlosIngredients(ingredientsContractAddress).decreaseIngredientSupply(tokenId, 1);

            unchecked {
                expectedPrice += ingredient.price;
            }
        }

        require(expectedPrice == msg.value, 'Invalid price.');
        return _bakePizza(tokenIds, false);
    }
    
    struct NumIngredientsUsed {
        uint16 cheeses;
        uint16 meats;
        uint16 toppings;
    }

    function _bakePizza(uint256[] memory tokenIds, bool useBuyersIngredients) private returns (uint256) {

        Pizza memory pizza;
        return _addIngredientsToPizza(0, pizza, tokenIds, useBuyersIngredients);
    }

    function _addIngredientsToPizza(
        uint256 pizzaTokenId,
        Pizza memory pizza,
        uint256[] memory tokenIds,
        bool useBuyersIngredients
    ) private returns (uint256) {

        NumIngredientsUsed memory numIngredientsUsed;

        if (pizzaTokenId != 0) {
            for (uint256 i; i<pizza.cheeses.length;) {
                if (pizza.cheeses[i] == 0) {
                    break;
                }

                unchecked {
                    numIngredientsUsed.cheeses++;
                    i++;
                }
            }

            for (uint256 i; i<pizza.meats.length;) {
                if (pizza.meats[i] == 0) {
                    break;
                }

                unchecked {
                    numIngredientsUsed.meats++;
                    i++;
                }
            }

            for (uint256 i; i<pizza.toppings.length;) {
                if (pizza.toppings[i] == 0) {
                    break;
                }

                unchecked {
                    numIngredientsUsed.toppings++;
                    i++;
                }
            }
        }
        
        uint256[] memory amounts = new uint256[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length;) {
            uint256 tokenId = tokenIds[i];

            if (useBuyersIngredients) {
                uint256 balance = ILazlosIngredients(ingredientsContractAddress).balanceOfAddress(msg.sender, tokenId);
                require(balance > 0, 'Missing ingredient.');
            }
            
            Ingredient memory ingredient = ILazlosIngredients(ingredientsContractAddress).getIngredient(tokenId);
            
            if (ingredient.ingredientType == IngredientType.Base) {
                require(pizza.base == 0, 'Cannot use more than 1 base.');

                pizza.base = uint16(tokenId);
            
            } else if (ingredient.ingredientType == IngredientType.Sauce) {
                require(pizza.sauce == 0, 'Cannot use more than 1 sauce.');

                pizza.sauce = uint16(tokenId);
            
            } else if (ingredient.ingredientType == IngredientType.Cheese) {
                unchecked {
                    numIngredientsUsed.cheeses++;
                }
                
                require(numIngredientsUsed.cheeses <= 3, 'Cannot use more than 3 cheeses.');
                
                pizza.cheeses[numIngredientsUsed.cheeses - 1] = uint16(tokenId);
            
            } else if (ingredient.ingredientType == IngredientType.Meat) {
                unchecked {
                    numIngredientsUsed.meats++;
                }
                
                require(numIngredientsUsed.meats <= 4, 'Cannot use more than 4 meats.');
                
                pizza.meats[numIngredientsUsed.meats - 1] = uint16(tokenId);

            } else if (ingredient.ingredientType == IngredientType.Topping) {
                unchecked {
                    numIngredientsUsed.toppings++;
                }
                
                require(numIngredientsUsed.toppings <= 4, 'Cannot use more than 4 toppings.');
                
                pizza.toppings[numIngredientsUsed.toppings - 1] = uint16(tokenId);
            
            } else {
                revert('Invalid ingredient type.');
            }

            amounts[i] = 1;

            unchecked {
                i++;
            }
        }

        require(pizza.base != 0, 'A base is required.');
        require(pizza.sauce != 0, 'A sauce is required.');
        require(pizza.cheeses[0] != 0, 'At least one cheese is required.');
        validateNoDuplicateIngredients(pizza);

        if (useBuyersIngredients) {
            ILazlosIngredients(ingredientsContractAddress).burnIngredients(msg.sender, tokenIds, amounts);
        }

        if (pizzaTokenId == 0) {
            return ILazlosPizzas(pizzaContractAddress).bake(msg.sender, pizza);
        
        } else {
            ILazlosPizzas(pizzaContractAddress).rebake(msg.sender, pizzaTokenId, pizza);
            return pizzaTokenId;
        }
    }

    function validateNoDuplicateIngredients(Pizza memory pizza) internal pure {

        validateNoDuplicates3(pizza.cheeses);
        validateNoDuplicates4(pizza.meats);
        validateNoDuplicates4(pizza.toppings);
    }

    function validateNoDuplicates3(uint16[3] memory arr) internal pure {

        for (uint256 i; i<arr.length;) {
            if (arr[i] == 0) {
                break;
            }

            for (uint256 j; j<arr.length;) {
                if (arr[j] == 0) {
                    break;
                }

                if (i == j) {
                    unchecked {
                        j++;
                    }
                    continue;
                }

                require(arr[i] != arr[j], 'No duplicate ingredients.');      

                unchecked {
                    j++;
                }
            }

            unchecked {
                i++;
            }
        }
    }

    function validateNoDuplicates4(uint16[4] memory arr) internal pure {

        for (uint256 i; i<arr.length;) {
            if (arr[i] == 0) {
                break;
            }

            for (uint256 j; j<arr.length;) {
                if (arr[j] == 0) {
                    break;
                }

                if (i == j) {
                    unchecked {
                        j++;
                    }
                    continue;
                }

                require(arr[i] != arr[j], 'No duplicate ingredients.');      

                unchecked {
                    j++;
                }
            }

            unchecked {
                i++;
            }
        }
    }

    function unbakePizza(uint256 pizzaTokenId) public payable nonReentrant {

        require(mintingOn, 'minting must be on');
        require(msg.value == unbakePizzaPrice, 'Invalid price.');

        Pizza memory pizza = ILazlosPizzas(pizzaContractAddress).pizza(pizzaTokenId);

        uint256 numIngredientsInPizza = 3;
        for (uint256 i=1; i<3;) {
            if (pizza.cheeses[i] == 0) {
                break;
            }

            numIngredientsInPizza++;

            unchecked {
                i++;
            }
        }

        for (uint256 i; i<4;) {
            if (pizza.meats[i] == 0) {
                break;
            }

            numIngredientsInPizza++;

            unchecked {
                i++;
            }
        }

        for (uint256 i; i<4;) {
            if (pizza.toppings[i] == 0) {
                break;
            }

            numIngredientsInPizza++;

            unchecked {
                i++;
            }
        }

        uint256[] memory tokenIds = new uint256[](numIngredientsInPizza);
        tokenIds[0] = uint256(pizza.base);
        tokenIds[1] = uint256(pizza.sauce);
        uint256 tokenIdsIndex = 2;

        for (uint256 i=0; i<3;) {
            if (pizza.cheeses[i] == 0) {
                break;
            }

            tokenIds[tokenIdsIndex] = pizza.cheeses[i];
            unchecked {
                tokenIdsIndex++;
                i++;
            }
        }

        for (uint256 i; i<4;) {
            if (pizza.meats[i] == 0) {
                break;
            }

            tokenIds[tokenIdsIndex] = pizza.meats[i];
            unchecked {
                tokenIdsIndex++;
                i++;
            }
        }

        for (uint256 i; i<4;) {
            if (pizza.toppings[i] == 0) {
                break;
            }

            tokenIds[tokenIdsIndex] = pizza.toppings[i];
            unchecked {
                tokenIdsIndex++;
                i++;
            }
        }

        uint256[] memory amounts = new uint256[](numIngredientsInPizza);
        for (uint256 i; i<numIngredientsInPizza;) {
            amounts[i] = 1;

            unchecked {
                i++;
            }
        }

        ILazlosIngredients(ingredientsContractAddress).mintIngredients(msg.sender, tokenIds, amounts);
        ILazlosPizzas(pizzaContractAddress).burn(pizzaTokenId);
    }

    function rebakePizza(uint256 pizzaTokenId, uint256[] memory ingredientTokenIdsToAdd, uint256[] memory ingredientTokenIdsToRemove) public payable nonReentrant {

        require(mintingOn, 'minting must be on');
        require(msg.value == rebakePizzaPrice, 'Invalid price.');

        Pizza memory pizza = ILazlosPizzas(pizzaContractAddress).pizza(pizzaTokenId);

        for (uint256 i; i<ingredientTokenIdsToRemove.length;) {
            uint256 tokenIdToRemove = ingredientTokenIdsToRemove[i];

            Ingredient memory ingredient = ILazlosIngredients(ingredientsContractAddress).getIngredient(tokenIdToRemove);

            if (ingredient.ingredientType == IngredientType.Base) {
                pizza.base = 0;
            
            } else if (ingredient.ingredientType == IngredientType.Sauce) {
                pizza.sauce = 0;
            
            } else if (ingredient.ingredientType == IngredientType.Cheese) {
                bool foundCheese;
                uint16[3] memory updatedCheeses;
                uint256 updatedCheeseIndex;
                for (uint256 j; j<updatedCheeses.length;) {
                    uint256 existingCheese = pizza.cheeses[j];
                    if (existingCheese == 0) {
                        break;
                    }

                    if (existingCheese != tokenIdToRemove) {
                        updatedCheeses[updatedCheeseIndex] = uint16(existingCheese);

                        unchecked {
                            updatedCheeseIndex++;
                        }
                    
                    } else {
                        foundCheese = true;
                    }

                    unchecked {
                        j++;
                    }
                }

                require(foundCheese, 'Could not find cheese to be removed.');
                pizza.cheeses = updatedCheeses;
            
            } else if (ingredient.ingredientType == IngredientType.Meat) {
                bool foundMeat;
                uint16[4] memory updatedMeats;
                uint256 updatedMeatIndex;
                for (uint256 j; j<updatedMeats.length;) {
                    uint256 existingMeat = pizza.meats[j];
                    if (existingMeat == 0) {
                        break;
                    }

                    if (existingMeat != tokenIdToRemove) {
                        updatedMeats[updatedMeatIndex] = uint16(existingMeat);

                        unchecked {
                            updatedMeatIndex++;
                        }
                    
                    } else {
                        foundMeat = true;
                    }

                    unchecked {
                        j++;
                    }
                }

                require(foundMeat, 'Could not find meat to be removed.');
                pizza.meats = updatedMeats;

            } else if (ingredient.ingredientType == IngredientType.Topping) {
                bool foundTopping;
                uint16[4] memory updatedToppings;
                uint256 updatedToppingIndex;
                for (uint256 j; j<updatedToppings.length;) {
                    uint256 existingTopping = pizza.toppings[j];
                    if (existingTopping == 0) {
                        break;
                    }

                    if (existingTopping != tokenIdToRemove) {
                        updatedToppings[updatedToppingIndex] = uint16(existingTopping);

                        unchecked {
                            updatedToppingIndex++;
                        }
                    
                    } else {
                        foundTopping = true;
                    }

                    unchecked {
                        j++;
                    }
                }

                require(foundTopping, 'Could not find topping to be removed.');
                pizza.toppings = updatedToppings;
            
            } else {
                revert('Invalid ingredient type.');
            }

            unchecked {
                i++;
            }
        } 

        _addIngredientsToPizza(pizzaTokenId, pizza, ingredientTokenIdsToAdd, true);
    }

    function bakeRandomPizza(uint256[] memory tokenIds, uint256 timestamp, bytes32 r, bytes32 s, uint8 v) public payable nonReentrant returns (uint256) {

        require(mintingOn, 'minting must be on');
        require(bakeRandomPizzaOn, 'bakeRandomPizza must be on');
        require(randomBakePrice == msg.value, 'Invalid price.');
        require(block.timestamp - timestamp < 300, 'timestamp expired');

        bytes32 messageHash = keccak256(abi.encodePacked(
            msg.sender,
            timestamp,
            tokenIds
        ));

        address signerAddress = verifySignature(messageHash, r, s, v);
        bool validSignature = signerAddress == systemAddress;
        require(validSignature, 'Invalid signature.');

        uint256 expectedPrice = bakePizzaPrice;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            Ingredient memory ingredient = ILazlosIngredients(ingredientsContractAddress).getIngredient(tokenId);
            require(ingredient.supply >= 1, 'Ingredient sold out.');

            ILazlosIngredients(ingredientsContractAddress).decreaseIngredientSupply(tokenId, 1);

            unchecked {
                expectedPrice += ingredient.price;
            }
        }

        return _bakePizza(tokenIds, false);
    }

    function verifySignature(bytes32 messageHash, bytes32 r, bytes32 s, uint8 v) public pure returns (address) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes memory prefixedMessage = abi.encodePacked(prefix, messageHash);
        bytes32 hashedMessage = keccak256(prefixedMessage);
        return ecrecover(hashedMessage, v, r, s);
    }

    function artistWithdraw() public nonReentrant {

        uint256 amountToBePayed = artistAllowedWithdrawalAmount(msg.sender);
        artistWithdrawalAmount[msg.sender] += amountToBePayed;

        (bool success,) = msg.sender.call{value : amountToBePayed}('');
        require(success, "Withdrawal failed.");
    }

    function artistAllowedWithdrawalAmount(address artist) public view returns( uint256) {

        uint256 earnedCommission = artistTotalCommission(artist);
        uint256 amountWithdrawn = artistWithdrawalAmount[artist];

        require(earnedCommission > amountWithdrawn, "Hasn't earned any more commission.");
        uint256 withdrawalAmount = earnedCommission - amountWithdrawn;
        return withdrawalAmount;
    }

    function artistTotalCommission(address artist) public view returns (uint256) {

        uint256 numIngredients = ILazlosIngredients(ingredientsContractAddress).getNumIngredients();

        uint256 artistCommission;
        for (uint256 tokenId = 1; tokenId <= numIngredients; tokenId++) {
            Ingredient memory ingredient = ILazlosIngredients(ingredientsContractAddress).getIngredient(tokenId);

            if (ingredient.artist != artist) {
                continue;
            }

            uint256 numSold = ingredient.initialSupply - ingredient.supply;
            uint256 ingredientRevenue = numSold * ingredient.price;
            uint256 artistsIngredientCommission = ingredientRevenue / 10;
            artistCommission += artistsIngredientCommission;
        }

        return artistCommission;
    }

    struct Payout {
        uint256 payoutBlock;
        uint256 amount;
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    function redeemPayout(Payout[] memory payouts) public nonReentrant {

        uint256 totalPayout;
        for (uint256 i; i < payouts.length; i++) {
            Payout memory payout = payouts[i];

            bytes32 messageHash = keccak256(abi.encodePacked(
                payout.payoutBlock,
                msg.sender,
                payout.amount
            ));
            address signerAddress = verifySignature(messageHash, payout.r, payout.s, payout.v);
            bool validSignature = signerAddress == systemAddress;
            require(validSignature, 'Invalid signature.');

            require(!isPaidByBlockAndAddress[payout.payoutBlock][msg.sender], 'Address already been paid for this block.');

            isPaidByBlockAndAddress[payout.payoutBlock][msg.sender] = true;
            totalPayout += payout.amount;
        }

        if (totalPayout > 0) {
            (bool success,) = msg.sender.call{value : totalPayout}('');
            require(success, "Withdrawal failed.");
        }
    }

    function isPaidOutForBlock(address addr, uint256 payoutBlock) public view returns (bool) {

        return isPaidByBlockAndAddress[payoutBlock][addr];
    }
}