pragma solidity ^0.4.19;

contract ERC20Token {
     function totalSupply() public constant returns (uint);
     function balanceOf(address tokenOwner) public constant returns (uint balance);
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
     function transfer(address to, uint tokens) public returns (bool success);
     function approve(address spender, uint tokens) public returns (bool success);
     function transferFrom(address from, address to, uint tokens) public returns (bool success);

     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract SmartMortgage {

    //Passing of one month is approximated by assuming block time of 15 seconds.
    //(31 days x 24 hrs x 60 mins x 60 seconds) / 15 seconds = 178560 blocks.
    // uint256 constant blocksPerMonth = 178560;
    //31 days x 24 hrs x 60 mins x 60 seconds = 2678400
    uint256 secondsPerMonth = 2678400;

    //Next payment period
    uint blockHeight_nextEval;

    uint8 public decimals = 0;

    //DAI token
    address DAI_addresss = 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359;
    ERC20Token DAI = ERC20Token(DAI_addresss);

    address buyer;
    address seller;

    uint256 downPayment = 0;
    uint256 total_security= 0;
    uint256 monthlyPayment = 0;

    uint foreclose_limit;

    uint paymentFailures = 0;
    uint consecutivePaymentFailures = 0;

    mapping(address => uint256) public securityBalance;
    mapping(address => uint256) public dollarBalances;

    function SmartMortgage(
        address person,
        uint256 total_security,
        uint256 downPayment,
        uint256 foreclose_upper_limit
        ) public {

        require(downPayment < total_security);

        seller = msg.sender;
        buyer = person;
        foreclose_limit = foreclose_upper_limit;
        securityBalance[seller] = total_security - downPayment;
        securityBalance[buyer] = downPayment;
        blockHeight_nextEval = block.timestamp + secondsPerMonth;

    }



//-------------------- Methods for both Seller and Buyer

    //Check security balance
    function viewOwnership() returns (uint256) {

        return securityBalance[msg.sender];
    }



    //Contract can be terminated by the entity owning 100% of the security tokens by
    //transfering them to an Address other than the buyer and seller.

    function terminateContract (address TerminatingAddress) {

        if (securityBalance[msg.sender] == total_security) {

            securityBalance[buyer] = 0;
            securityBalance[seller] = 0;
            securityBalance[TerminatingAddress] = total_security;

        } else {
            throw;
        }
    }


//-------------------------- Methods for Seller

    //Claim collateral for a failed payment
    function claimCollateral () {

        require(securityBalance[buyer] > 0);
        if ((msg.sender == seller)
        && ((consecutivePaymentFailures >= 1)
           ||(block.timestamp > blockHeight_nextEval))) {

                securityBalance[seller] += 1;
                securityBalance[buyer] -= 1;
                blockHeight_nextEval += secondsPerMonth;

        } else {
            throw;
        }
    }

    //If consecutivePaymentFailures exceeds foreclose_limit, then seller can close the deal.
    function Foreclose () {

        if ((msg.sender == seller) && (consecutivePaymentFailures >= foreclose_limit)) {

                securityBalance[seller] = total_security;
                securityBalance[buyer] = 0;

        } else {
            throw;
        }

    }

//-----------------------Methods for Buyer

    //Make Monthly Payment
    function makePayment() returns (bool) {

        if ((msg.sender == buyer)
        && (DAI.balanceOf(msg.sender) >= monthlyPayment)) {

            DAI.transfer(seller, monthlyPayment);
            consecutivePaymentFailures = 0;
            blockHeight_nextEval += secondsPerMonth;

            return true;
        } else {

            throw;
            return false;
        }
    }
}
