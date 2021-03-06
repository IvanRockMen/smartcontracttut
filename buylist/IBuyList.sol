
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'Buy.sol';

interface IBuyList
{
    function addItem(string name, uint count) external;
    function deleteItem(uint buy_id) external;
    function makeBuy(uint buy_id, uint price) external;
}
