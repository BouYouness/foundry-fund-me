//1. deploy mocks when we are on a local anvil chain
//2.keep track of contract address across different chains 
// Sepolia Eth/Usd
//Mainnet ETH/USD
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // if we are on a local anvil we deploy mocks
    // otherways, grab the existing address from the live network
    NetWorkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS=8;
    int256 public constant INITIAL_PRICE=2000e8;

    struct  NetWorkConfig {
        address priceFeed; //ETH/USD price feed address
    }
    
    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else if(block.chainid==1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
             activeNetworkConfig = getOrCreatedAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetWorkConfig memory){
        //price feed address
        NetWorkConfig  memory  sepoliaConfig = NetWorkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

     function getMainnetEthConfig() public pure returns (NetWorkConfig memory){
        //price feed address
        NetWorkConfig memory ethconfig = NetWorkConfig({priceFeed:0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012});//AAVE/USD
        return ethconfig;
    }

    function getOrCreatedAnvilEthConfig() public returns (NetWorkConfig memory){
        if(activeNetworkConfig.priceFeed != address(0)){
        return activeNetworkConfig;
        }
         //price feed address
         //1.deploy the mocks 
         //2.return the mocks address
         vm.startBroadcast();
          MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
         vm.stopBroadcast();
         NetWorkConfig memory anvilConfig = NetWorkConfig({priceFeed:address(mockPriceFeed)});
         return anvilConfig;
    }   

}