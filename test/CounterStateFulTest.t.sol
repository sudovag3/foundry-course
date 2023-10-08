// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
//Обязательный контракт для написание инвариантных тестов
//Наследуем его от нашего тест-контракта
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Counter} from "../src/Counter.sol";
import {Handler} from "./Handler.sol";

contract CounterTest is StdInvariant, Test {
    Counter public counter;
    Handler public handler;

    function setUp() public {
        counter = new Counter();
        handler = new Handler(counter);

        //Команда targetContract() указывает foundry на то
        //какой контракт должен подвергаться изменению состояния
        //для инвариантного тестирования
        targetContract(address(handler));
    }

    /**
     * Для инициализации инвариантного теста
     * добавляем соответсвующий префикс в название
     * функции
     */
    function invariant_testNeverReturnZero2() public {
        assert(counter.neverReturnZero2(10) != 0);
    }
}
