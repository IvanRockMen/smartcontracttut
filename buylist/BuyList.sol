
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "IBuyList.sol";
import 'Buy.sol';
import 'BuySummury.sol';

contract BuyList is IBuyList{

    Buy[] public buylist;
    BuySummury public statistic;

    constructor() public {
        require(tvm.pubkey() != 0, 101);

        require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();
    }

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 102);
        _;
    }

    function addItem(string name, uint count) public override checkOwnerAndAccept
    {
        Buy b = Buy(buylist.length, name, count, now, false, 0);
        buylist.push(b);
    }

    function deleteItem(uint id) public override checkOwnerAndAccept
    {

        if(buylist[id].bought)
        {
            statistic.payed--;
            statistic.paySum -= buylist[id].buyPrice;
        }
        else
        {
            statistic.notPayed--;
        }

        for(uint i = id; i + 1 < buylist.length; ++i)
        {
            buylist[i] = buylist[i+1];
            buylist[i].id = i;
        }

        buylist.pop();


    }

    function makeBuy(uint id, uint price) public override checkOwnerAndAccept
    {
        if(!buylist[id].bought)
        {
            statistic.notPayed -= buylist[id].count;
            statistic.payed += buylist[id].count;
            statistic.paySum += price;
            buylist[id].bought = true;
            buylist[id].buyPrice = price;
        }
        else
        {
            revert(102, "Item already bought");
        }
    }

}
