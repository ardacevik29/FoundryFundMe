// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundmeTest is Test{
     FundMe fundMe; 

    address USER = makeAddr("ARDAAA"); //cant be constant
    uint256 constant SEND_VALUE = 0.1 ether; 
    uint256 constant STARTING_BALANCE = 10 ether; 
    uint256 constant GAS_PRICE = 1; 

    function setUp() external {
       DeployFundMe deployFundme = new DeployFundMe(); 
       fundMe = deployFundme.run(); 
        vm.deal(USER,STARTING_BALANCE); 

    }
    function testMinimumDollarIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(),5e18); 
    }
 function testOwnwerIsMsgSender() public view {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(),msg.sender);

 
    }
    function testPriceFeedVerisonIsAccurate() public view{
        uint256 verison = fundMe.getVersion(); 
        assertEq(verison,4); 
    }
    /*     function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
*/
    function testFundFailsWithoutEnoughEth() public { // if we do sent it enough next line 
        vm.expectRevert(); //hey nesxt line should be revert
        fundMe.fund(); // send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
       vm.prank(USER); //th next text will be sent by user
       
       
       fundMe.fund{value: SEND_VALUE}(); // bu syntacı i fonkisyona ether göndermek için kullanılyoruz
       uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); 
       assertEq(amountFunded,SEND_VALUE); 
    }
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); 
        fundMe.fund{value:SEND_VALUE}(); 

        address funder = fundMe.getFunder(0); 
        assertEq(funder, USER); 


    }
    modifier funded(){
        vm.prank(USER); 
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithDraw() public funded{
        vm.prank(USER); 
        vm.expectRevert(); 
        fundMe.withdraw(); 

    }
    function testWithDrawWithASingleFunder() public funded{
       //Arange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMEBalance = address(fundMe).balance;
        //Act
       // uint256 gasStart = gasleft(); //1000
        //vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); //200
        fundMe.withdraw(); // should have spent gas ? 
        //uint256 gasEnd = gasleft(); //800
        //uint256 gasUsed = (gasStart -gasEnd)*tx.gasprice;
        //console.log(gasUsed); 

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; 
        uint256 endingFundMeBalance = address(fundMe).balance; 
        assertEq(endingFundMeBalance,0); 
        assertEq(
            startingFundMEBalance+startingOwnerBalance,
            endingOwnerBalance
        );

}
    function testWithdrawFromMultipleFunders() public funded{
        uint160 numverOfFunders = 10;
        uint160 startingFunderIndex = 1; 
        for(uint160 i= startingFunderIndex;i<numverOfFunders;i++){
            //vm.prank
            //vm.default
            hoax(address(i),SEND_VALUE); 
            fundMe.fund{value : SEND_VALUE}(); 
            //fund the fundMe

        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        uint256 startingFundMeBalance = address(fundMe).balance; 

        //Act
        vm.startPrank(fundMe.getOwner()); 
        fundMe.withdraw(); 
        vm.stopPrank(); 
        //assert
        assert(address(fundMe).balance == 0);
         assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); 



    }
    function testWithdrawFromMultipleFunderscheaper() public {
        uint160 numverOfFunders = 10;
        uint160 startingFunderIndex = 1; 
        for(uint160 i= startingFunderIndex;i<numverOfFunders;i++){
            //vm.prank
            //vm.default
            hoax(address(i),SEND_VALUE); 
            fundMe.fund{value : SEND_VALUE}(); 
            //fund the fundMe

        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        uint256 startingFundMeBalance = address(fundMe).balance; 

        //Act
        vm.startPrank(fundMe.getOwner()); 
        fundMe.cheaperWithDraw(); 
        vm.stopPrank(); 
        //assert
        assert(address(fundMe).balance == 0);
         assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); 

    }

}