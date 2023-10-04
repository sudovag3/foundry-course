// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployCounter} from "../script/DeployCounter.s.sol";
import {UpgradeCounter} from "../script/UpgradeCounter.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {CounterV1} from "../src/CounterV1.sol";
import {CounterV2} from "../src/CounterV2.sol";
import {Helper} from "../script/Helper.s.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * Очень важно тестировать работу не только основных контрактов,
 * но и контрактов-скриптов, ведь они тоже будут принимать участие
 * в создании реальных транзакций
 * В рамках этого теста мы протестируем работу скриптов на деплой и апгрейд
 * контрактов
 */
contract DeployAndUpgradeTest is Test {
    DeployCounter public deployCounter;
    UpgradeCounter public upgradeCounter;

    function setUp() public {
        deployCounter = new DeployCounter();
        upgradeCounter = new UpgradeCounter();
    }

    /**
     * В этом тесте мы деплоим первую версию нашего контракта
     * и проверяем корректность работы через просмотр параметра
     * version
     */
    function testCounterWorks() public {
        address proxyAddress = deployCounter.deployCounter();
        uint256 expectedValue = 1;
        assertEq(expectedValue, CounterV1(proxyAddress).version());
    }

    /**
     * В этом тесте идёт дополнительная проверка засчёт
     * попытки вызова функции из другой версии
     * В Foundry работа с UUPS максимально тревиальна:
     * Для обращения к прокси мы просто оборачиваем его адрес
     * в интересующий нас контракт, т.е.
     * вся ответсвенность на корректность лежит на нас
     */
    function testDeploymentIsV1() public {
        address proxyAddress = deployCounter.deployCounter();
        vm.expectRevert();
        CounterV2(proxyAddress).increment();
    }

    /**
     * Аналогично здесь мы вызываем функцию upgradeCounter и после этого
     * обращаемся к адресу уже как ко второй версии и убеждаемся, что всё работает
     */
    function testUpgradeWorks() public {
        address proxyAddress = deployCounter.deployCounter();

        CounterV2 Counter2 = new CounterV2();

        address proxy = upgradeCounter.upgradeCounter(proxyAddress, address(Counter2));

        uint256 expectedValue = 2;
        assertEq(expectedValue, CounterV2(proxy).version());

        CounterV2(proxy).increment();
        assertEq(1, CounterV2(proxy).getValue());
    }
    /**
     * Данная тестовая функция не относится к тестирования прокси-контрактов,
     * однако она очень наглядно демонстрирует работу работы тестирования форков
     * В данном случае мы будет тестировать с форком тестнета Sepolia
     * Суть работы проста:
     * При работе с форком наши обращения будут идти к RPC-ноде нашего тестнета
     * При этом реально мы ничего не деплоим, а просто читаем информацию
     * Это позволяет тестировать сценарии с продакшна без надобности что-то
     * деплоить или вызывать в реальных транзакциях
     */

    function testForkTotalSupply() public {
        //За пример возьмём такой параметр токенов, как decimals
        //Это может быть абсолютно любой другой параметр
        //Главное, чтобы он хранился в какой-то сети и нам его нужно
        //прочитать
        uint256 decimals;
        //chainId - id цепи, в которой мы сечас работаем
        // 11155111 - это id от Sepolia
        // различные chainId можно без проблем найти в интернетах
        if (block.chainid == 11155111) {
            console.log("Fork testing!");
            //Если мы работаем с форком сеполии, то мы обращаемся к реально
            //существующему контракту на тестнете токена ERC20 и читаем параметр
            //его decimals
            decimals = ERC20(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8).decimals();
            assertEq(decimals, 6);
        } else {
            console.log("Standart testing!");
            //В противном случае нам нужно проверить, что такого контракта вообще
            //не существует - он даже не задеплоен
            //Хитрость: у адреса есть поле code, где
            //(в случае, если этот адрес относится к смарт-контракту) хранится код
            //контракта
            //В нашем случае он должен быть пустым
            assertEq(address(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8).code.length, 0);
        }
    }
}
