
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "WarUnit.sol";
import "Base.sol";

// This is class that describes you smart contract.
contract Archer is WarUnit{

    constructor(Base _base) public WarUnit(_base) {}

    function getAttack() public virtual override  returns (uint)
    {
        return 2;
    }

    function getDefence() external virtual override returns (uint)
    {
        return 2;
    }
}