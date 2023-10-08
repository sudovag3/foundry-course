// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
    }

    /**
     * В параметры функции тестирования добавляем аргумент
     * который должен генерироваться случайным образом
     *
     * Таким образом у нас получается простой пример фаззинга
     */
    function testNeverReturnZero(uint256 x) public view {
        assert(counter.neverReturnZero(x) != 0);
    }
}
