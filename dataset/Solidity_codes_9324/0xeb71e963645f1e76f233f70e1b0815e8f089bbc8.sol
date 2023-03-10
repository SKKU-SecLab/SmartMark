
pragma solidity ^0.4.21;


contract ERC20Token {

    function transfer(address to, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

}

contract SimplePHXExchange {

    
    uint public ScaleFactor = 10 ** 18;  
    
    address[] public tknOfferors;
	mapping(address => uint256) public tknAddrNdx;

	mapping(address => uint256) public tknTokensOffered;
	mapping(address => uint256) public tknPricePerToken; // In qWeiPerRise (need to multiply by 10 ** 36 to get it to ETH / PHX)

    address[] public ethOfferors;
	mapping(address => uint256) public ethAddrNdx;

	mapping(address => uint256) public ethEtherOffered;
	mapping(address => uint256) public ethPricePerToken; // In qRisePerWei (need to multiply by 10 ** 36 to get it to PHX / ETH)

    ERC20Token public phxCoin;

    function SimplePHXExchange() public {

        phxCoin = ERC20Token(0x14b759A158879B133710f4059d32565b4a66140C); // Initiates a PHX Coin !important -- Make sure this is the PHX contract!
        tknOfferors.push(0x0); // This is because all IDs in tknAddrNdx will initialize to zero
        ethOfferors.push(0x0); // This is because all IDs in ethAddrNdx will initialize to zero
    }

    function offerTkn(uint _tokensOffered, uint _tokenPrice) public {

        require(_humanSender(msg.sender));
        require(tknAddrNdx[msg.sender] == 0); // Make sure that this offeror has cancelled all previous offers
        require(0 < _tokensOffered); // Make sure some number of tokens are offered
        require(phxCoin.transferFrom(msg.sender, this, _tokensOffered)); // Require that transfer can be and is made
        tknTokensOffered[msg.sender] = _tokensOffered;
        tknPricePerToken[msg.sender] = _tokenPrice; // in qWeiPerRise
        tknOfferors.push(msg.sender);
        tknAddrNdx[msg.sender] = tknOfferors.length - 1;
    }
    
    function offerEth(uint _tokenPrice) public payable {

        require(_humanSender(msg.sender));
        require(ethAddrNdx[msg.sender] == 0); // Make sure that this offeror has cancelled all previous offers
        require(0 < msg.value); // Make sure some amount of eth is offered
        ethEtherOffered[msg.sender]  = msg.value;
        ethPricePerToken[msg.sender] = _tokenPrice; // in qRisesPerWei
        ethOfferors.push(msg.sender);
        ethAddrNdx[msg.sender] = ethOfferors.length - 1;
    }

    function cancelTknOffer() public {

        if(tknAddrNdx[msg.sender] == 0) return; // No need to cancel non-existent offer
        phxCoin.transfer(msg.sender, tknTokensOffered[msg.sender]); // Return the Tokens
        _cancelTknOffer(msg.sender);
    }

    function _cancelTknOffer(address _offeror) internal {

        delete tknTokensOffered[_offeror];
        delete tknPricePerToken[_offeror];

        uint ndx = tknAddrNdx[_offeror];

        tknOfferors[ndx] = tknOfferors[tknOfferors.length - 1];
        tknAddrNdx[tknOfferors[tknOfferors.length - 1]] = ndx;
        delete tknOfferors[tknOfferors.length - 1];
        delete tknAddrNdx[_offeror]; // !important
    }

    function cancelEthOffer() public {

        if(ethAddrNdx[msg.sender] == 0) return; // No need to cancel non-existent offer
        msg.sender.transfer(ethEtherOffered[msg.sender]); // Return the Tokens
        _cancelEthOffer(msg.sender);
    }

    function _cancelEthOffer(address _offeror) internal {

        delete ethEtherOffered[_offeror];
        delete ethPricePerToken[_offeror];
        
        uint ndx = ethAddrNdx[_offeror];

        ethOfferors[ndx] = ethOfferors[ethOfferors.length - 1];
        ethAddrNdx[ethOfferors[ethOfferors.length - 1]] = ndx;
        delete ethOfferors[ethOfferors.length - 1];
        delete ethAddrNdx[_offeror]; // !important
    }
    
    function buyTkn(uint _ndx) payable public {

        require(_humanSender(msg.sender));
        address _offeror = tknOfferors[_ndx];
        uint _purchasePrice = tknTokensOffered[_offeror] * tknPricePerToken[_offeror] / ScaleFactor; // i.e. # of Wei Required = Rises * (qWei/Rise) / 10**18
        require(msg.value >= _purchasePrice);
        require(phxCoin.transfer(msg.sender, tknTokensOffered[_offeror])); // Successful transfer of tokens to purchaser
        _offeror.transfer(_purchasePrice);
        _cancelTknOffer(_offeror);
    }
    
    function buyEth(uint _ndx) public {

        require(_humanSender(msg.sender));
        address _offeror = ethOfferors[_ndx];
        uint _purchasePrice = ethEtherOffered[_offeror] * ethPricePerToken[_offeror] / ScaleFactor;  // i.e. # of Rises Required = Wei * (qTRs/Wei) / 10**18
        require(phxCoin.transferFrom(msg.sender, _offeror, _purchasePrice)); // Successful transfer of tokens to offeror
        msg.sender.transfer(ethEtherOffered[_offeror]);
        _cancelEthOffer(_offeror);
    }
    
    function updateTknPrice(uint _newPrice) public {

        require(tknTokensOffered[msg.sender] != 0); 
        tknPricePerToken[msg.sender] = _newPrice;
    }
    
    function updateEthPrice(uint _newPrice) public {

        require(ethEtherOffered[msg.sender] != 0); 
        ethPricePerToken[msg.sender] = _newPrice;
    }
    
    
    function getNumTknOfferors() public constant returns (uint _numOfferors) {

        return tknOfferors.length; // !important:  This is always 1 more than the number of actual offers
    }
    
    function getTknOfferor(uint _ndx) public constant returns (address _offeror) {

        return tknOfferors[_ndx];
    }
    
    function getTknOfferPrice(uint _ndx) public constant returns (uint _tokenPrice) {

        return tknPricePerToken[tknOfferors[_ndx]];
    }
    
    function getTknOfferAmount(uint _ndx) public constant returns (uint _tokensOffered) {

        return tknTokensOffered[tknOfferors[_ndx]];
    }
    
    function getNumEthOfferors() public constant returns (uint _numOfferors) {

        return ethOfferors.length; // !important:  This is always 1 more than the number of actual offers
    }
    
    function getEthOfferor(uint _ndx) public constant returns (address _offeror) {

        return ethOfferors[_ndx];
    }
    
    function getEthOfferPrice(uint _ndx) public constant returns (uint _etherPrice) {

        return ethPricePerToken[ethOfferors[_ndx]];
    }
    
    function getEthOfferAmount(uint _ndx) public constant returns (uint _etherOffered) {

        return ethEtherOffered[ethOfferors[_ndx]];
    }
    
    
    function _humanSender(address _from) private view returns (bool) {

      uint codeLength;
      assembly {
          codeLength := extcodesize(_from)
      }
      return (codeLength == 0); // If this is "true" sender is most likely a Wallet
    }
}