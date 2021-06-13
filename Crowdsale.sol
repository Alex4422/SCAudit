pragma solidity 0.8.4;

contract Crowdsale {

    //@dev I decided to comment the use of SafeMath because the SafeMath.sol is not found
    //anymore with the new version of compiler. In Solidity 0.8+ you don't need to use
    //SafeMath anymore, because the integer underflow/overflow check is performed on a
    //lower level.
    //using SafeMath for uint256;

    //@dev Put the owner in "private visibility" : nothing outside this smart contract (= SC) can change the variable owner
    address private owner; // the owner of the contract
    address payable public escrow; // wallet to collect raised ETH
    uint256 public savedBalance = 0; // Total amount raised in ETH
    mapping (address => uint256) public balances; // Balances in incoming Ether

    //@dev We create a modifier to be sure that only the owner of the SC can withdraw the Payments for example
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }


    // Initialization
    //@dev a function can't have the same name than the smart contract itself. To initialize, write constructor ...
    constructor (address payable _escrow) public{
        owner = tx.origin;
        // add address of the specific contract
        escrow = _escrow;
    }

    // function to receive ETH
    //@dev anyone outside the SC can receive ETH
    fallback() payable external{
        //@dev We don't use SafeMath.sol now (deprecated) so we can use +
        balances[msg.sender] = balances[msg.sender] + msg.value;
        savedBalance = savedBalance + msg.value;
        escrow.transfer(msg.value);
    }

    // refund investisor
    //@dev There is, maybe here, a possible attack by reetrance, particularly in L.44 but I am not sure
    function withdrawPayments() public payable onlyOwner{
        address payable payee = payable(msg.sender);
        uint256 payment = balances[payee];

        payee.send(payment);

        //@dev We don't use SafeMath.sol now (deprecated) so we can use -
        savedBalance = savedBalance - payment;

        balances[payee] = 0;
    }
}