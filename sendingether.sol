//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;


// even if a contract has no payable function (and no fallback) still ether can be forcrfully sent to the contract
// in some ways.


contract sendingEther{
// 1) self destruct

function Sendether(address payable _addr) public payable  {
    selfdestruct(_addr);     // this function deletes the contract and sends the ether to adress _addr without calling any function
}

/* 2)
    Pre-sent ether
    Since contract addresses are deterministic, anyone can calculate what a contract address will be before it is 
    created and thus send ether to that address. When the contract does get created it will have a non-zero ether balance.
    address = keccack256(rlp.encode([account_address , transaction_nonce]))
  */  
}