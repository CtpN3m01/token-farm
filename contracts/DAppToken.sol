// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


/**
* @title DAppToken
* @notice Token ERC20 usado como recompensa en la Token Farm.
*/
contract DAppToken is ERC20, Ownable {
    constructor(address initialOwner) ERC20("DApp Token", "DAPP") Ownable(initialOwner) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}