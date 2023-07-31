// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else if (block.chainid == 42161) {
            activeNetworkConfig = getArbitrumEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory netWorkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return netWorkConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory netWorkConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return netWorkConfig;
    }

    function getArbitrumEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory netWorkConfig = NetworkConfig({
            priceFeed: 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
        });

        return netWorkConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //1- Desplegar el mock
        //2- Retornar el mock address

        //Esto me valida si ya no he desplegado el mock, preguntando si address es diferente de 0x00, si lo es me hara el deploy, de lo contrario, me retornara el que ya existe.
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast(); //--> iniciamos una transaccion en Anvil
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        //Simulamos el mock, pasandole los decimales que tendra el precio, que son 8 y el precio de la moneda que son 2000 USD, seguido de 8 ceros, por los decimales.

        vm.stopBroadcast(); //--> terminarmos la transaccion en Anvil

        //Ahora simplemente le damos la direccion de nuestro mock al networkConfig
        NetworkConfig memory netWorkConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return netWorkConfig;
    }
}
