// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {CounterV1} from "../src/CounterV1.sol";
import {CounterV2} from "../src/CounterV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Helper} from "./Helper.s.sol";

//Импортируем данный контракт, он поможет нам в работе с недавно задеплоенными контрактами
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

/**
 * Мы создаём контракт, у которого будет лишь одна функция:
 * Обновлять наш проксируемый контракт
 */
contract UpgradeCounter is Helper {
    function run() external returns (address) {
        // Метод get_most_recent_deployment()
        // позволяет достать адрес последнего задеплоенного контракта
        // по заданным требованиям: Название контракта и id цепи,
        // где данный контракт деплоился
        address mostRecentlyDeployedProxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);

        //Мы хотим по-настоящему задеплоить новую версию контракта,
        //поэтому startBroadcast()
        vm.startBroadcast();
        CounterV2 newCounter = new CounterV2();
        vm.stopBroadcast();
        //Обновляем контракт
        address proxy = upgradeCounter(mostRecentlyDeployedProxy, address(newCounter));

        return proxy;
    }

    function upgradeCounter(address proxyAddress, address newCounter) public returns (address) {
        vm.startBroadcast();
        //payable - это важный параметр, не забываем про него
        //(нюанс проки-контрактов)
        CounterV1 proxy = CounterV1(payable(proxyAddress));
        proxy.upgradeTo(address(newCounter));
        vm.stopBroadcast();
        return address(proxy);
    }
}
