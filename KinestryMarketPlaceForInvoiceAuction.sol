pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract KinestryIOMarketPlace {

    struct Invoice{
        uint256 number;
        uint256 amount;
        string description;
    }

    
    uint256 public invoiceNumber = 0;
    uint256 public invoiceSetForAuction;
    Invoice[] public invoices;

    address[] public  sellers;
    address[] public funders;

    mapping(address => bool) public sellersRegisteredList;
    mapping(address => bool) public fundersRegisteredList;
    mapping(uint256 => Invoice) public idToInvoice;
    mapping(uint256 => address) public whoseInvoiceisThis;
    mapping(address => bool) public invoiceOwnersList;
        
    bool public started;
    bool public ended;
    uint public endAt;

    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;


    //uint256 timestamp = 120 seconds;

    event InvoiceCreated(uint256 invoicenumber);
    event invoiceSold(uint256 invoiceNumber);
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount);

    modifier onlyInvoiceCreator(){
        require(invoiceOwnersList[tx.origin], "only invoice creator can call this");
        _;
    }

    modifier inVoiceExists(uint256 _inVoiceNumber){
        bool exists = false;
        uint256 invoiceLength = invoices.length;
        console.log("");
        console.log(invoiceLength);
        console.log("");
        

        for(uint256 i=0; i< invoiceLength; i++) {
            if (invoices[i].number == _inVoiceNumber) exists = true;
        }
        
        require(exists, " invoice do not exist in the list");
        _;
    }

    constructor() payable {

    }

    modifier onlySeller() {
        require(sellersRegisteredList[tx.origin], "Not registered as seller");
        _;
    }

    modifier onlyFunder() {
        require(fundersRegisteredList[tx.origin], "Not registered as funder");
        _;
    }

    function registerAsSeller() external {        
        require(!fundersRegisteredList[tx.origin], "Buyer/Funder can not be a seller at the sametime");
        sellersRegisteredList[tx.origin] = true;
    }   

    function registerAsFunder() external {        
        require(!sellersRegisteredList[tx.origin], "Seller can not be a buyer at the same time");
        fundersRegisteredList[tx.origin] = true;
    }

    function unregisterAsSeller() external {
        sellersRegisteredList[tx.origin] = false;
    }

    function unregisterAsFunder() external {
        fundersRegisteredList[tx.origin] = false;
    }

    function createInvoice(uint _amount, string memory _desc) onlySeller external {
        require(sellersRegisteredList[tx.origin], "only Registered sellers can create an invoice");
        require(_amount > 0, "Zero amount invoice is not allowed");
        require(bytes(_desc).length != 0, "Description of invoice needed");

        uint256 _number = invoiceNumber++;
        invoices.push(Invoice(_number,_amount,_desc));  
        
        invoiceOwnersList[tx.origin] = true;
        whoseInvoiceisThis[_number] = tx.origin;
        emit InvoiceCreated(_number);
    }


    function setInvoiceForAuction(uint256 _inVoiceNumber) public onlyInvoiceCreator() inVoiceExists(_inVoiceNumber) {
        invoiceSetForAuction = _inVoiceNumber;
        highestBid = 1000000000 gwei;
        startAuction();

    }
    function startAuction() internal {
        require(!started, "started");        
        started = true;
        endAt = block.timestamp + 180 seconds;

        emit Start();
    }

    function bidForInvoice() onlyFunder() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest");

        uint256 minimum5percent = highestBid + 50000000000000000;
        console.log("");
        console.log(minimum5percent);
        console.log("");
        require(msg.value >= minimum5percent, "Minimum 5% more than last bid value");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder =tx.origin;
        highestBid = msg.value;

        emit Bid(tx.origin, msg.value);
    }

    function withDrawfromBid() external {
        uint bal = bids[tx.origin];
        bids[tx.origin] = 0;
        payable(tx.origin).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    function endBid() external onlyInvoiceCreator() {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;
        started = false;

        transferInvoice();
        emit End(highestBidder, highestBid);
    }

    function transferInvoice() internal {
        invoiceOwnersList[highestBidder] = true;
        payable(whoseInvoiceisThis[invoiceSetForAuction]).transfer(highestBid);
        whoseInvoiceisThis[invoiceSetForAuction]= highestBidder;
    }

}

