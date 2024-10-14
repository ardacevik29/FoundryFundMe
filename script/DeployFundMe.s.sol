// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/Fundme.sol";  // FundMe kontratının konumuna göre güncelle;
import {HelperConfig} from "./HelperConfig.s.sol";
contract DeployFundMe is Script {
    FundMe fundMe;
    function run() external returns(FundMe) {
        HelperConfig helperConfig = new HelperConfig();  
        
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        
        vm.startBroadcast(); // it makes deployfundme contract on test doing the deploying and know we  are the msg.sende agin
        //Mock 
        fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}