
pragma solidity ^0.5.11;
contract mazzafakka {

 
      uint256 constant prime = 14474011154664525231415395255581126252639794253786371766033694892385558855681;
      uint constant r = 2;
      uint constant c = 1;
      uint constant nRounds = 326;
      uint constant m = r + c;
      uint outputSize = c;
     
      function LoadAuxdata()
        internal pure
        returns (uint256[] memory roundConstants)
    {

        roundConstants = new uint256[](nRounds);
    }
 function submod(uint a, uint b, uint _prime) public pure returns (uint){

      uint a_nn;

      if(a>b) {
        a_nn = a;
      } else {
        a_nn = a+_prime;
      }

      uint cdd = addmod(a_nn - b,0,_prime);

      return cdd;
  }
function permutation_func(uint256[] memory roundConstants, uint256[] memory elements)
        internal pure
        returns (uint256[] memory)
    {

        uint256 length = elements.length;
        require(length == m, "elements length is not equal to m.");
        for (uint256 i = 0; i < roundConstants.length; i++) {
            uint256 element0Old = elements[0];
            uint256 step1 = addmod(elements[0], roundConstants[i], prime);
            uint256 mask = mulmod(mulmod(step1, step1, prime), step1, prime);
            for (uint256 j = 0; j < length - 1; j++) {
                elements[j] = addmod(elements[j + 1], mask, prime);
            }
            elements[length - 1] = element0Old;
        }
        return elements;
    }
 function sponge(uint256[] memory inputs)
        internal view
        returns (uint256[] memory outputElements)
    {

        uint256 inputLength = inputs.length;
        for (uint256 i = 0; i < inputLength; i++) {
            require(inputs[i] < prime, "elements do not belong to the field");
        }
 
        require(inputLength % r == 0, "Number of field elements is not divisible by r.");
 
        uint256[] memory state = new uint256[](m);
        for (uint256 i = 0; i < m; i++) {
            state[i] = 0; // fieldZero.
        }
 
        uint256[] memory auxData = LoadAuxdata();
        uint256 n_columns = inputLength / r;
        for (uint256 i = 0; i < n_columns; i++) {
            for (uint256 j = 0; j < r; j++) {
                state[j] = addmod(state[j], inputs[i * r + j], prime);
            }
            state = permutation_func(auxData, state);
        }
 
        require(outputSize <= r, "No support for more than r output elements.");
        outputElements = new uint256[](outputSize);
        for (uint256 i = 0; i < outputSize; i++) {
            outputElements[i] = state[i];
        }
    }
     function spongefuck(uint256[] memory inputs, uint256[] memory inputs2)
        internal pure
        returns (uint256[] memory outputElements)
    {

        uint256 inputLength = inputs.length;
        uint256[] memory state = new uint256[](m);
        for (uint256 i = 0; i < m; i++) {
            state[i] = 0; // fieldZero.
        }
       
        uint256[] memory state2 = new uint256[](m);
        for (uint256 i = 0; i < m; i++) {
            state2[i] = 0; // fieldZero.
        }
       
                             outputElements = new uint256[](r);

 
        uint256[] memory auxData = LoadAuxdata();
        uint256 n_columns = inputLength / r;
       
        for (uint256 i = 0; i < n_columns; i++) {
            for (uint256 j = 0; j < r; j++) {
                if (i==n_columns-1){
                    state[j] = addmod(state[j], inputs[i * r + j], prime);
                     outputElements[j] = submod(state[j], state2[j], prime);
                     require(addmod(state2[j], outputElements[j],prime) == state[j], "NOT WORKING");
                }else{
                    state[j] = addmod(state[j], inputs[i * r + j], prime);
                    state2[j] = addmod(state2[j], inputs2[i * r + j], prime);
                }
            }
            if (i==n_columns-1){
           
            }else{
             state = permutation_func(auxData, state);
             state2 = permutation_func(auxData, state2);
            }
        }
        
       
    }
 
function applyHash(uint256[] memory elements)
        public view
        returns (uint256[] memory elementsHash)
    {

        elementsHash = sponge(elements);
    }
   
    function fuckHash(uint256[] memory elements, uint256[] memory elements2)
        public pure
        returns (uint256[] memory elementsHash)
    {

        elementsHash = spongefuck(elements, elements2);
    }
}