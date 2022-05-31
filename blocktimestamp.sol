//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

/*
Miner's have the ability to adjust timestamps slightly which can prove to be quite dangerous if 
block timestamps are used incorrectly in smart contracts.

 block timestamps are monotonically increasing and so miners cannot choose arbitrary block timestamps 
 (they must be larger than their predecessors). They are also limited to setting blocktimes not too far 
 in the future as these blocks will likely be rejected by the network.

 Preventions --> Block timestamps should not be used for entropy or generating random numbers
             -->Time-sensitive logic is sometimes required; specifying a block number at which 
                to change a contract state can be more secure as miners are unable to manipulate 
                the block number as easily. 
 */