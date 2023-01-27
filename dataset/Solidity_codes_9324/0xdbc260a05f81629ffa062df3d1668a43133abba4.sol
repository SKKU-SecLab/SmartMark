
pragma solidity ^0.4.21;


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}






contract StrikersPlayerList is Ownable {


  event PlayerAdded(uint8 indexed id, string name);

  uint8 public playerCount;

  constructor() public {
    addPlayer("Lionel Messi"); // 0
    addPlayer("Cristiano Ronaldo"); // 1
    addPlayer("Neymar"); // 2
    addPlayer("Mohamed Salah"); // 3
    addPlayer("Robert Lewandowski"); // 4
    addPlayer("Kevin De Bruyne"); // 5
    addPlayer("Luka Modrić"); // 6
    addPlayer("Eden Hazard"); // 7
    addPlayer("Sergio Ramos"); // 8
    addPlayer("Toni Kroos"); // 9
    addPlayer("Luis Suárez"); // 10
    addPlayer("Harry Kane"); // 11
    addPlayer("Sergio Agüero"); // 12
    addPlayer("Kylian Mbappé"); // 13
    addPlayer("Gonzalo Higuaín"); // 14
    addPlayer("David de Gea"); // 15
    addPlayer("Antoine Griezmann"); // 16
    addPlayer("N'Golo Kanté"); // 17
    addPlayer("Edinson Cavani"); // 18
    addPlayer("Paul Pogba"); // 19
    addPlayer("Isco"); // 20
    addPlayer("Marcelo"); // 21
    addPlayer("Manuel Neuer"); // 22
    addPlayer("Dries Mertens"); // 23
    addPlayer("James Rodríguez"); // 24
    addPlayer("Paulo Dybala"); // 25
    addPlayer("Christian Eriksen"); // 26
    addPlayer("David Silva"); // 27
    addPlayer("Gabriel Jesus"); // 28
    addPlayer("Thiago"); // 29
    addPlayer("Thibaut Courtois"); // 30
    addPlayer("Philippe Coutinho"); // 31
    addPlayer("Andrés Iniesta"); // 32
    addPlayer("Casemiro"); // 33
    addPlayer("Romelu Lukaku"); // 34
    addPlayer("Gerard Piqué"); // 35
    addPlayer("Mats Hummels"); // 36
    addPlayer("Diego Godín"); // 37
    addPlayer("Mesut Özil"); // 38
    addPlayer("Son Heung-min"); // 39
    addPlayer("Raheem Sterling"); // 40
    addPlayer("Hugo Lloris"); // 41
    addPlayer("Radamel Falcao"); // 42
    addPlayer("Ivan Rakitić"); // 43
    addPlayer("Leroy Sané"); // 44
    addPlayer("Roberto Firmino"); // 45
    addPlayer("Sadio Mané"); // 46
    addPlayer("Thomas Müller"); // 47
    addPlayer("Dele Alli"); // 48
    addPlayer("Keylor Navas"); // 49
    addPlayer("Thiago Silva"); // 50
    addPlayer("Raphaël Varane"); // 51
    addPlayer("Ángel Di María"); // 52
    addPlayer("Jordi Alba"); // 53
    addPlayer("Medhi Benatia"); // 54
    addPlayer("Timo Werner"); // 55
    addPlayer("Gylfi Sigurðsson"); // 56
    addPlayer("Nemanja Matić"); // 57
    addPlayer("Kalidou Koulibaly"); // 58
    addPlayer("Bernardo Silva"); // 59
    addPlayer("Vincent Kompany"); // 60
    addPlayer("João Moutinho"); // 61
    addPlayer("Toby Alderweireld"); // 62
    addPlayer("Emil Forsberg"); // 63
    addPlayer("Mario Mandžukić"); // 64
    addPlayer("Sergej Milinković-Savić"); // 65
    addPlayer("Shinji Kagawa"); // 66
    addPlayer("Granit Xhaka"); // 67
    addPlayer("Andreas Christensen"); // 68
    addPlayer("Piotr Zieliński"); // 69
    addPlayer("Fyodor Smolov"); // 70
    addPlayer("Xherdan Shaqiri"); // 71
    addPlayer("Marcus Rashford"); // 72
    addPlayer("Javier Hernández"); // 73
    addPlayer("Hirving Lozano"); // 74
    addPlayer("Hakim Ziyech"); // 75
    addPlayer("Victor Moses"); // 76
    addPlayer("Jefferson Farfán"); // 77
    addPlayer("Mohamed Elneny"); // 78
    addPlayer("Marcus Berg"); // 79
    addPlayer("Guillermo Ochoa"); // 80
    addPlayer("Igor Akinfeev"); // 81
    addPlayer("Sardar Azmoun"); // 82
    addPlayer("Christian Cueva"); // 83
    addPlayer("Wahbi Khazri"); // 84
    addPlayer("Keisuke Honda"); // 85
    addPlayer("Tim Cahill"); // 86
    addPlayer("John Obi Mikel"); // 87
    addPlayer("Ki Sung-yueng"); // 88
    addPlayer("Bryan Ruiz"); // 89
    addPlayer("Maya Yoshida"); // 90
    addPlayer("Nawaf Al Abed"); // 91
    addPlayer("Lee Chung-yong"); // 92
    addPlayer("Gabriel Gómez"); // 93
    addPlayer("Naïm Sliti"); // 94
    addPlayer("Reza Ghoochannejhad"); // 95
    addPlayer("Mile Jedinak"); // 96
    addPlayer("Mohammad Al-Sahlawi"); // 97
    addPlayer("Aron Gunnarsson"); // 98
    addPlayer("Blas Pérez"); // 99
    addPlayer("Dani Alves"); // 100
    addPlayer("Zlatan Ibrahimović"); // 101
  }

  function addPlayer(string _name) public onlyOwner {

    require(playerCount < 255, "You've already added the maximum amount of players.");
    emit PlayerAdded(playerCount, _name);
    playerCount++;
  }
}


contract StrikersChecklist is StrikersPlayerList {


  enum DeployStep {
    WaitingForStepOne,
    WaitingForStepTwo,
    WaitingForStepThree,
    WaitingForStepFour,
    DoneInitialDeploy
  }

  enum RarityTier {
    IconicReferral,
    IconicInsert,
    Diamond,
    Gold,
    Silver,
    Bronze
  }

  uint16[] public tierLimits = [
    0,    // Iconic - Referral Bonus (uncapped)
    100,  // Iconic Inserts ("Card of the Day")
    1000, // Diamond
    1664, // Gold
    3328, // Silver
    4352  // Bronze
  ];

  struct ChecklistItem {
    uint8 playerId;
    RarityTier tier;
  }

  DeployStep public deployStep;

  ChecklistItem[] public originalChecklistItems;

  ChecklistItem[] public iconicChecklistItems;

  ChecklistItem[] public unreleasedChecklistItems;

  function _addOriginalChecklistItem(uint8 _playerId, RarityTier _tier) internal {

    originalChecklistItems.push(ChecklistItem({
      playerId: _playerId,
      tier: _tier
    }));
  }

  function _addIconicChecklistItem(uint8 _playerId, RarityTier _tier) internal {

    iconicChecklistItems.push(ChecklistItem({
      playerId: _playerId,
      tier: _tier
    }));
  }

  function addUnreleasedChecklistItem(uint8 _playerId, RarityTier _tier) external onlyOwner {

    require(deployStep == DeployStep.DoneInitialDeploy, "Finish deploying the Originals and Iconics sets first.");
    require(unreleasedCount() < 56, "You can't add any more checklist items.");
    require(_playerId < playerCount, "This player doesn't exist in our player list.");
    unreleasedChecklistItems.push(ChecklistItem({
      playerId: _playerId,
      tier: _tier
    }));
  }

  function originalsCount() external view returns (uint256) {

    return originalChecklistItems.length;
  }

  function iconicsCount() public view returns (uint256) {

    return iconicChecklistItems.length;
  }

  function unreleasedCount() public view returns (uint256) {

    return unreleasedChecklistItems.length;
  }


  function deployStepOne() external onlyOwner {

    require(deployStep == DeployStep.WaitingForStepOne, "You're not following the steps in order...");

    _addOriginalChecklistItem(0, RarityTier.Diamond); // 000 Messi
    _addOriginalChecklistItem(1, RarityTier.Diamond); // 001 Ronaldo
    _addOriginalChecklistItem(2, RarityTier.Diamond); // 002 Neymar
    _addOriginalChecklistItem(3, RarityTier.Diamond); // 003 Salah

    _addOriginalChecklistItem(4, RarityTier.Gold); // 004 Lewandowski
    _addOriginalChecklistItem(5, RarityTier.Gold); // 005 De Bruyne
    _addOriginalChecklistItem(6, RarityTier.Gold); // 006 Modrić
    _addOriginalChecklistItem(7, RarityTier.Gold); // 007 Hazard
    _addOriginalChecklistItem(8, RarityTier.Gold); // 008 Ramos
    _addOriginalChecklistItem(9, RarityTier.Gold); // 009 Kroos
    _addOriginalChecklistItem(10, RarityTier.Gold); // 010 Suárez
    _addOriginalChecklistItem(11, RarityTier.Gold); // 011 Kane
    _addOriginalChecklistItem(12, RarityTier.Gold); // 012 Agüero
    _addOriginalChecklistItem(13, RarityTier.Gold); // 013 Mbappé
    _addOriginalChecklistItem(14, RarityTier.Gold); // 014 Higuaín
    _addOriginalChecklistItem(15, RarityTier.Gold); // 015 de Gea
    _addOriginalChecklistItem(16, RarityTier.Gold); // 016 Griezmann
    _addOriginalChecklistItem(17, RarityTier.Gold); // 017 Kanté
    _addOriginalChecklistItem(18, RarityTier.Gold); // 018 Cavani
    _addOriginalChecklistItem(19, RarityTier.Gold); // 019 Pogba

    _addOriginalChecklistItem(20, RarityTier.Silver); // 020 Isco
    _addOriginalChecklistItem(21, RarityTier.Silver); // 021 Marcelo
    _addOriginalChecklistItem(22, RarityTier.Silver); // 022 Neuer
    _addOriginalChecklistItem(23, RarityTier.Silver); // 023 Mertens
    _addOriginalChecklistItem(24, RarityTier.Silver); // 024 James
    _addOriginalChecklistItem(25, RarityTier.Silver); // 025 Dybala
    _addOriginalChecklistItem(26, RarityTier.Silver); // 026 Eriksen
    _addOriginalChecklistItem(27, RarityTier.Silver); // 027 David Silva
    _addOriginalChecklistItem(28, RarityTier.Silver); // 028 Gabriel Jesus
    _addOriginalChecklistItem(29, RarityTier.Silver); // 029 Thiago
    _addOriginalChecklistItem(30, RarityTier.Silver); // 030 Courtois
    _addOriginalChecklistItem(31, RarityTier.Silver); // 031 Coutinho
    _addOriginalChecklistItem(32, RarityTier.Silver); // 032 Iniesta

    deployStep = DeployStep.WaitingForStepTwo;
  }

  function deployStepTwo() external onlyOwner {

    require(deployStep == DeployStep.WaitingForStepTwo, "You're not following the steps in order...");

    _addOriginalChecklistItem(33, RarityTier.Silver); // 033 Casemiro
    _addOriginalChecklistItem(34, RarityTier.Silver); // 034 Lukaku
    _addOriginalChecklistItem(35, RarityTier.Silver); // 035 Piqué
    _addOriginalChecklistItem(36, RarityTier.Silver); // 036 Hummels
    _addOriginalChecklistItem(37, RarityTier.Silver); // 037 Godín
    _addOriginalChecklistItem(38, RarityTier.Silver); // 038 Özil
    _addOriginalChecklistItem(39, RarityTier.Silver); // 039 Son
    _addOriginalChecklistItem(40, RarityTier.Silver); // 040 Sterling
    _addOriginalChecklistItem(41, RarityTier.Silver); // 041 Lloris
    _addOriginalChecklistItem(42, RarityTier.Silver); // 042 Falcao
    _addOriginalChecklistItem(43, RarityTier.Silver); // 043 Rakitić
    _addOriginalChecklistItem(44, RarityTier.Silver); // 044 Sané
    _addOriginalChecklistItem(45, RarityTier.Silver); // 045 Firmino
    _addOriginalChecklistItem(46, RarityTier.Silver); // 046 Mané
    _addOriginalChecklistItem(47, RarityTier.Silver); // 047 Müller
    _addOriginalChecklistItem(48, RarityTier.Silver); // 048 Alli
    _addOriginalChecklistItem(49, RarityTier.Silver); // 049 Navas

    _addOriginalChecklistItem(50, RarityTier.Bronze); // 050 Thiago Silva
    _addOriginalChecklistItem(51, RarityTier.Bronze); // 051 Varane
    _addOriginalChecklistItem(52, RarityTier.Bronze); // 052 Di María
    _addOriginalChecklistItem(53, RarityTier.Bronze); // 053 Alba
    _addOriginalChecklistItem(54, RarityTier.Bronze); // 054 Benatia
    _addOriginalChecklistItem(55, RarityTier.Bronze); // 055 Werner
    _addOriginalChecklistItem(56, RarityTier.Bronze); // 056 Sigurðsson
    _addOriginalChecklistItem(57, RarityTier.Bronze); // 057 Matić
    _addOriginalChecklistItem(58, RarityTier.Bronze); // 058 Koulibaly
    _addOriginalChecklistItem(59, RarityTier.Bronze); // 059 Bernardo Silva
    _addOriginalChecklistItem(60, RarityTier.Bronze); // 060 Kompany
    _addOriginalChecklistItem(61, RarityTier.Bronze); // 061 Moutinho
    _addOriginalChecklistItem(62, RarityTier.Bronze); // 062 Alderweireld
    _addOriginalChecklistItem(63, RarityTier.Bronze); // 063 Forsberg
    _addOriginalChecklistItem(64, RarityTier.Bronze); // 064 Mandžukić
    _addOriginalChecklistItem(65, RarityTier.Bronze); // 065 Milinković-Savić

    deployStep = DeployStep.WaitingForStepThree;
  }

  function deployStepThree() external onlyOwner {

    require(deployStep == DeployStep.WaitingForStepThree, "You're not following the steps in order...");

    _addOriginalChecklistItem(66, RarityTier.Bronze); // 066 Kagawa
    _addOriginalChecklistItem(67, RarityTier.Bronze); // 067 Xhaka
    _addOriginalChecklistItem(68, RarityTier.Bronze); // 068 Christensen
    _addOriginalChecklistItem(69, RarityTier.Bronze); // 069 Zieliński
    _addOriginalChecklistItem(70, RarityTier.Bronze); // 070 Smolov
    _addOriginalChecklistItem(71, RarityTier.Bronze); // 071 Shaqiri
    _addOriginalChecklistItem(72, RarityTier.Bronze); // 072 Rashford
    _addOriginalChecklistItem(73, RarityTier.Bronze); // 073 Hernández
    _addOriginalChecklistItem(74, RarityTier.Bronze); // 074 Lozano
    _addOriginalChecklistItem(75, RarityTier.Bronze); // 075 Ziyech
    _addOriginalChecklistItem(76, RarityTier.Bronze); // 076 Moses
    _addOriginalChecklistItem(77, RarityTier.Bronze); // 077 Farfán
    _addOriginalChecklistItem(78, RarityTier.Bronze); // 078 Elneny
    _addOriginalChecklistItem(79, RarityTier.Bronze); // 079 Berg
    _addOriginalChecklistItem(80, RarityTier.Bronze); // 080 Ochoa
    _addOriginalChecklistItem(81, RarityTier.Bronze); // 081 Akinfeev
    _addOriginalChecklistItem(82, RarityTier.Bronze); // 082 Azmoun
    _addOriginalChecklistItem(83, RarityTier.Bronze); // 083 Cueva
    _addOriginalChecklistItem(84, RarityTier.Bronze); // 084 Khazri
    _addOriginalChecklistItem(85, RarityTier.Bronze); // 085 Honda
    _addOriginalChecklistItem(86, RarityTier.Bronze); // 086 Cahill
    _addOriginalChecklistItem(87, RarityTier.Bronze); // 087 Mikel
    _addOriginalChecklistItem(88, RarityTier.Bronze); // 088 Sung-yueng
    _addOriginalChecklistItem(89, RarityTier.Bronze); // 089 Ruiz
    _addOriginalChecklistItem(90, RarityTier.Bronze); // 090 Yoshida
    _addOriginalChecklistItem(91, RarityTier.Bronze); // 091 Al Abed
    _addOriginalChecklistItem(92, RarityTier.Bronze); // 092 Chung-yong
    _addOriginalChecklistItem(93, RarityTier.Bronze); // 093 Gómez
    _addOriginalChecklistItem(94, RarityTier.Bronze); // 094 Sliti
    _addOriginalChecklistItem(95, RarityTier.Bronze); // 095 Ghoochannejhad
    _addOriginalChecklistItem(96, RarityTier.Bronze); // 096 Jedinak
    _addOriginalChecklistItem(97, RarityTier.Bronze); // 097 Al-Sahlawi
    _addOriginalChecklistItem(98, RarityTier.Bronze); // 098 Gunnarsson
    _addOriginalChecklistItem(99, RarityTier.Bronze); // 099 Pérez

    deployStep = DeployStep.WaitingForStepFour;
  }

  function deployStepFour() external onlyOwner {

    require(deployStep == DeployStep.WaitingForStepFour, "You're not following the steps in order...");

    _addIconicChecklistItem(0, RarityTier.IconicInsert); // 100 Messi
    _addIconicChecklistItem(1, RarityTier.IconicInsert); // 101 Ronaldo
    _addIconicChecklistItem(2, RarityTier.IconicInsert); // 102 Neymar
    _addIconicChecklistItem(3, RarityTier.IconicInsert); // 103 Salah
    _addIconicChecklistItem(4, RarityTier.IconicInsert); // 104 Lewandowski
    _addIconicChecklistItem(5, RarityTier.IconicInsert); // 105 De Bruyne
    _addIconicChecklistItem(6, RarityTier.IconicInsert); // 106 Modrić
    _addIconicChecklistItem(7, RarityTier.IconicInsert); // 107 Hazard
    _addIconicChecklistItem(8, RarityTier.IconicInsert); // 108 Ramos
    _addIconicChecklistItem(9, RarityTier.IconicInsert); // 109 Kroos
    _addIconicChecklistItem(10, RarityTier.IconicInsert); // 110 Suárez
    _addIconicChecklistItem(11, RarityTier.IconicInsert); // 111 Kane
    _addIconicChecklistItem(12, RarityTier.IconicInsert); // 112 Agüero
    _addIconicChecklistItem(15, RarityTier.IconicInsert); // 113 de Gea
    _addIconicChecklistItem(16, RarityTier.IconicInsert); // 114 Griezmann
    _addIconicChecklistItem(17, RarityTier.IconicReferral); // 115 Kanté
    _addIconicChecklistItem(18, RarityTier.IconicReferral); // 116 Cavani
    _addIconicChecklistItem(19, RarityTier.IconicInsert); // 117 Pogba
    _addIconicChecklistItem(21, RarityTier.IconicInsert); // 118 Marcelo
    _addIconicChecklistItem(24, RarityTier.IconicInsert); // 119 James
    _addIconicChecklistItem(26, RarityTier.IconicInsert); // 120 Eriksen
    _addIconicChecklistItem(29, RarityTier.IconicReferral); // 121 Thiago
    _addIconicChecklistItem(36, RarityTier.IconicReferral); // 122 Hummels
    _addIconicChecklistItem(38, RarityTier.IconicReferral); // 123 Özil
    _addIconicChecklistItem(39, RarityTier.IconicInsert); // 124 Son
    _addIconicChecklistItem(46, RarityTier.IconicInsert); // 125 Mané
    _addIconicChecklistItem(48, RarityTier.IconicInsert); // 126 Alli
    _addIconicChecklistItem(49, RarityTier.IconicReferral); // 127 Navas
    _addIconicChecklistItem(73, RarityTier.IconicInsert); // 128 Hernández
    _addIconicChecklistItem(85, RarityTier.IconicInsert); // 129 Honda
    _addIconicChecklistItem(100, RarityTier.IconicReferral); // 130 Alves
    _addIconicChecklistItem(101, RarityTier.IconicReferral); // 131 Zlatan

    deployStep = DeployStep.DoneInitialDeploy;
  }

  function limitForChecklistId(uint8 _checklistId) external view returns (uint16) {

    RarityTier rarityTier;
    uint8 index;
    if (_checklistId < 100) { // Originals = #000 to #099
      rarityTier = originalChecklistItems[_checklistId].tier;
    } else if (_checklistId < 200) { // Iconics = #100 to #131
      index = _checklistId - 100;
      require(index < iconicsCount(), "This Iconics checklist item doesn't exist.");
      rarityTier = iconicChecklistItems[index].tier;
    } else { // Unreleased = #200 to max #255
      index = _checklistId - 200;
      require(index < unreleasedCount(), "This Unreleased checklist item doesn't exist.");
      rarityTier = unreleasedChecklistItems[index].tier;
    }
    return tierLimits[uint8(rarityTier)];
  }
}