pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "BuyList.sol";
import 'ABuyList.sol';
import "base/Terminal.sol";
import "base/Sdk.sol";
import "base/Debot.sol";
import "ITransactable.sol";

// This is class that describes you smart contract.
abstract contract DebotInitializer {


    TvmCell buyListCode;
    uint masterPubkey;
    address contractAddress;
    BuyList buylist;
    address userWalletAddress;

    uint32 INITIAL_BALANCE =  200000000;

    // Contract can have a `constructor` – function that will be called when contract will be deployed to the blockchain.
    // In this example constructor adds current time to the instance variable.
    // All contracts need call tvm.accept(); for succeeded deploy
    constructor() public {
        // Check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and
        // message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        // The current smart contract agrees to buy some gas to finish the
        // current transaction. This actions required to process external
        // messages, which bring no value (henceno gas) with themselves.
        tvm.accept();
    }

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        _;
    }

    function deploy() private view
    {
        TvmCell image = tvm.insertPubkey(buyListCode, masterPubkey);
        optional(uint256) none;
        TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: contractAddress,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError),
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: image,
            call: {ABuylist, masterPubkey}
        });
        tvm.sendrawmsg(deployMsg, 1);    
    }

    function setBuyListCode(TvmCell code) public checkOwnerAndAccept
    {
        buyListCode = code;
    }

    function savePubKey(string value) public 
    {
        (uint res, bool status) = stoi("0x" + value);
        if(status)
        {
            masterPubkey = res;
            Terminal.print(0, "Checking if you already have BuyList ...");
            TvmCell deployState = tvm.insertPubkey(buyListCode, masterPubkey);
            contractAddress = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(tvm.functionId(checkStatus), contractAddress);
        }
        else
        {
            Terminal.input(tvm.functionId(savePublicKey), "Wrong public key. Try again!\nPlease enter your public key", false);
        }
    }

    function checkStatus(int8 accountType) public
    {
        if(accountType == 1)
        {
            _getStats(tvm.functionId(setStats));
        }
        else if(accountType == -1)
        {
            Terminal.print(0, "You don't have a TODO list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount), "Select a wallet for payment. We will ask you to sign two transactions");
        }
        else if(accountType == 0)
        {
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your TODO contract has enough tokens on its balance"
            ));
            deploy();
        }
        else if (accountType == 2)
        {
            Terminal.print(0, format("Can not continue: account {} is frozen", contractAddress));
        }
    }

    function creditAccount(address value) public
    {
        userWalletAddress = value;
        optional(uint) pubkey = 0;
        TvmCell empty;
        ITransactable(userWalletAddress).sendTransaction
        {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(contractAddress, INITAIL_BALANCE, false, 3, empty);
    }

    function onError(uint32 sdkError, uint32 exitCode) public
    {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
    }

    function onSuccess() public view
    {
        _getStat(tvm.functionId(getStat));
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 errorCode) public
    {
        sdkError;
        exitCode;
        creditAccount(userWalletAddress);
    }

    function waitBeforeDeploy() public
    {
        Sdk.getAccountType(tvm.functionId(checkIfStatusIs0), contractAddress);
    }

    function checkIfStatusIs0(int8 accountType) public
    {
        if(accountType == 0)
        {
            deploy();
        }
        else
        {
            waitBeforeDeploy();
        }
    }

}
