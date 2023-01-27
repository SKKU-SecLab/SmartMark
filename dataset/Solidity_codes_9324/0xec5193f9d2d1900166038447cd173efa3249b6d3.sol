
pragma solidity ^0.4.25;



contract Kopilka {

    uint constant ADV_PERCENT = 2; //2%
    uint constant TEAM_PERCENT = 2; //2%
    uint constant MAX_LEVEL = 45; //Максимальный уровень, который можно достичь
    uint constant PERIOD = 1 days; //Регулярность внесения взносов
    uint constant MAX_ONE_TIME_PERIODS = 7; //Максимальный размер взноса (за сколько дней)
    uint constant MIN_DEPOSIT = 0.01 ether; //Минимальный депозит
    uint constant MAX_DEPOSIT = 5 ether;    //Максимальный депозит
    uint constant RETURN_DEPOSIT_PERCENT = 70; //70% - процент возврата депозита
    uint constant MAX_LEVEL_TO_RETURN_DEPOSIT = 10; //Уровень, до которого можно вернуть депозит

    struct User {
        uint dep;   //Размер ежедневного взноса
        uint value; //Сумма всех взносов
        uint atTime;//Когда был сделан последний взнос (если бы они делались максимально равномерно)
    }

    mapping (address => User) public users;

    address constant TEAM_ADDRESS = 0xF996A4e45E2f32F6BC5827A2448f7c2e54F69845;
    address constant ADV_ADDRESS = 0x18d84B54b6b1AEC9cdb2ef9B60E669FAD12Bb778;

    function () public payable {
        User storage user = users[msg.sender]; // это вы

        if (msg.value != 0.00000112 ether) { //Если внесли взнос, то
            ADV_ADDRESS.transfer(msg.value * ADV_PERCENT / 100);
            TEAM_ADDRESS.transfer(msg.value * TEAM_PERCENT / 100);

            if (user.value == 0) { //Если пользователя ещё не было
                require(MIN_DEPOSIT <= msg.value && msg.value <= MAX_DEPOSIT);

                user.dep = msg.value;
                user.value = msg.value;
                user.atTime = now;
            } else { //Это повторый взнос

                uint allowed = getAllowedInvestmentAmount(msg.sender);

                uint investment = msg.value;
                uint sendback = 0; //Сколько мы должны ему отправить обратно

                if(investment > allowed){
                    sendback = investment - allowed;
                    investment = allowed;
                }

                user.atTime = now - (allowed - investment)*PERIOD/user.dep;

                uint dep = user.dep;  //Размер первого взноса
                uint amount = user.value; //Сколько пользователь уже всего внес
                uint level = amount/dep; //На каком уровне пользователь
                uint endLevel = (amount+investment)/dep; //На каком уровне он окажется после этого взноса

                for(uint l=level; l<=endLevel; ++l){
                    uint levelInvestment = dep*(l+1) - amount;
                    if(levelInvestment > investment) levelInvestment = investment;

                    sendback += calcReturn(levelInvestment, l);
                    amount += levelInvestment;
                    investment -= levelInvestment;
                }

                user.value = amount;

                if(endLevel > MAX_LEVEL)
                    delete users[msg.sender];

                msg.sender.transfer(sendback);
            }
        } else if(user.dep > 0){ //Если пользователь вообще что-то вносил
            require(user.value/user.dep <= MAX_LEVEL_TO_RETURN_DEPOSIT, "It's too late to request a refund at this point");

            msg.sender.transfer(user.value * RETURN_DEPOSIT_PERCENT / 100);

            delete users[msg.sender];
        }

    }

    function getAllowedInvestmentAmount(address addr) public view returns (uint) {

        User storage user = users[addr]; // пользователь
        uint allowed = user.dep * (now - user.atTime) / PERIOD;
        if(allowed > MAX_ONE_TIME_PERIODS*user.dep)
            allowed = MAX_ONE_TIME_PERIODS*user.dep;
        uint max_investment = user.dep*MAX_LEVEL;
        if(user.value + allowed > max_investment)
            allowed = max_investment > user.value ? max_investment - user.value : 0;
        return allowed;
    }

    function calcReturn(uint investment, uint level) public pure returns (uint){

        if(level > MAX_LEVEL)
            level = 0;
        require(investment <= MAX_DEPOSIT);
        return investment * level * level * (24400 - 500 * investment / 1 ether) / 10000000;
    }

    function calcReturnPercent(uint dep, uint level) public pure returns(uint) {

        return calcReturn(dep, level)*1000000/dep;
    }

    function calcReturnPercents(uint dep) public pure returns (uint[] percents){

        percents = new uint[](MAX_LEVEL);
        for(uint i=0; i<MAX_LEVEL; ++i){
            percents[i] = calcReturnPercent(dep, i);
        }
    }

}