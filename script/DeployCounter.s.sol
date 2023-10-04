// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//Данный контракт отвечает за имплементацию скриптов, он обязательно должен наследоваться
// в любом скрипте
import {Script} from "forge-std/Script.sol";
import {CounterV1} from "../src/CounterV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * Контракты по структур практически ничем не отличаются от тестов
 */
contract DeployCounter is Script {
    /**
     * Задача функции run() максимально проста:
     * Задеплоить наш контракт
     * Она будет запускаться автоматически при вызове
     * скрипта, что-то вроде конструктора
     */
    function run() external returns (address) {
        address proxy = deployCounter();
        return proxy;
    }

    /**
     * Здесь мы встречаем интересный метод: vm.startBroadcast()
     * Данный метод позволяет контракту создать
     * настоящую транзакцию в он-чейне
     * Здесь не будут работать чит-коды и транзакция будет цепочке
     * В данном случае мы хотим, чтобы настоящей транзакцией у нас задеплоился
     * контракт и прокси к нему
     */
    function deployCounter() public returns (address) {
        vm.startBroadcast();
        //Деплоим контракт первой версии
        CounterV1 counter = new CounterV1();
        //Определяем селектор функции инициализации с нужными аргументами
        //В нашем случае аргументов в функции нет, поэтому ()
        bytes memory data = abi.encodeCall(CounterV1.initialize, ());
        //Деплоим прокси-контракт указывая адрес имплементации и данные
        //об инициализирующей функции
        ERC1967Proxy proxy = new ERC1967Proxy(address(counter), data);
        vm.stopBroadcast();
        return address(proxy);
    }
}
