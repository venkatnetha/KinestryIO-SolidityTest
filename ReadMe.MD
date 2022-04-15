This is a solidity task given by Kinestry

The task is to create a marketplace for Invoice


There are 2 actors in the smart contract. Seller and Funder/buyer.


Seller and buyer needs to register with the market place contract before they could do any buying or selling


Buyer and seller have the option of unregistering themselves after registering.


Buyer cannot be a seller and seller cannot be a buyer. Dual actions prohibited.


Seller creates a Invoice using CreateInvoice function by passing the invoice amount and invoice description


After creating, sets the invoice for the Auction


The auction followed in smart contract is of English auction where the auction starts with a base price and 


subsequently the buyers will bid more than the current highest bid.


A restrictio in place where every next bid should be minimum of 5% of the current highest bid.


There is a time limit for the auction to end and at the end of the auction, the ownership of the invoice is transferred to the highest bidder and the highest bid amount to be tranferred to the invoice creator.
