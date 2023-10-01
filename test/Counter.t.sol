// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//Здесь мы импортируем самый важный контракт для тестирования в Foundry
//Его обязательно нужно добавить в наследование к нашему контракту
//для тестирования
import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

/**
 * Структура теста такая же, как и у обычного контракта
 * Мы создаём самый обычный контракт, только наследуем его от Test
 */
contract CounterTest is Test {
    Counter public counter;

    //Для дальнейшего тестирования события Incremented
    //копируем его в тестирующий контракт
    event Incremented(uint256 indexed number);

    //Первая тестировачная функция - создание адреса (makeAddr)
    //Данная функция принимает в аргументы некоторую строку
    //Которая служит, как источник энтропии для генерации адреса
    //Обычно, данный параметр называют также, как и переменную
    address owner = makeAddr("owner");

    /**
     * Стартовая функция setUp()
     * Она запускается в самом начале выполнения теста (аналог конструктора)
     * Изменения состояния, которые происходят в данной функции,
     * будут применены ко всем остальным функциям.
     * В данном тесте мы используем данную функцию для того,
     * чтобы инициализировать тестируемый контракт
     */
    function setUp() public {
        counter = new Counter();
        //В данный момент owner контракта - это контракт тестирования
        //Для дальнейшего тестирования следует заменить его на созданный
        //ранее адрес
        counter.transferOwnership(owner);
    }

    /**
     * Стандартная тестовая функция
     * Её название не важно, изменения, которые в ней происходят
     * никак не повлияют на общее состояние, то есть все тесты
     * работают в "вакууме"
     */
    function testIncrement() public {
        counter.increment();

        //Самая простая и тревиальная функция сравнения двух значений
        assertEq(counter.number(), 1);
    }

    /**
     * В примере по-умолчанию уже используется так называемое fuzz-тестирование
     * Это более сложный уровень, но на данном этапе погружения можно
     * понять это следующим образом: fuzz-тестирование в Foundry используется
     * для тестирования нетривиальных (случайных) ситуаций
     *
     * В данном примере мы поместили в параметры тестирующей функции
     * параметр x - это значит, что при тестировании будет сгенерировано
     * множество различных (случайных) чисел x
     * и с каждым из них будет проведено тестирование данной функции
     */
    function testSetNumber(uint256 x) public {
        if (x != 0) {
            //Очень важная и крутая функция startPrank используется для того,
            //чтобы следующий участок кода выполнялся
            //от имени заданного нам адреса
            //В данном примере мы хотим использовать owner, чтобы от его имени
            //вызвать функцию setNumber()
            vm.startPrank(owner);
            counter.setNumber(x);
            vm.stopPrank();
            assertEq(counter.number(), x);
        }
    }

    /**
     * В данной функции мы будет использовать метод для проверки появления
     * нужной ошибки - expectRevert()
     * Данный метод может не принимать никаких аргументов и будет срабатывать
     * при любой ошибке
     * Но чтобы сделать наше тестирование более проработанным,
     * в качестве аргумента можно добавить текст ошибки
     */

    function testRevertIfCallerIsNotOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        counter.setNumber(100);
    }

    /**
     * В случае, если контракт использует в качестве вызова
     * ошибок специальные объекты error, то в данном случае для
     * тестирования данной ошибки
     * в качестве аргумента к expectRevert() следует добавить
     * селектор нужной нам ошибки Counter.ZeroNumber.selector
     */
    function testRevertIfNumberIsZero() public {
        vm.expectRevert(Counter.ZeroNumber.selector);
        vm.startPrank(owner);
        counter.setNumber(0);
        vm.stopPrank();
    }

    /**
     * В данной функции мы рассмотрим метод для тестирования ивентов -
     * expectEmit()
     * На первый взгляд он мужет напугать, потому что имеет много
     * различных параметров, но на самом деле всё очень просто
     * Чтобы протестировать событие, нам нужно:
     * 1) Задать данные, которые будет проверять
     * 2) "Фиктивно" инициировать событие, которое мы собираемся проверять
     * 3) Вызвать функцию, в которой вызывается данное событие
     */
    function testEmitEventIncremented() public {
        //Это одна из простых форм вызова метода expectEmit,
        //где в качестве аргумента указывается только адрес того
        //от кого ожидаем получения события
        vm.expectEmit(address(counter));
        emit Incremented(1);
        counter.increment();
    }

    /**
     * Используем метод vm.deal()
     * которы устанавливает
     * соответсвующий баланс на соответсвующий адрес
     *
     * Метод deal() может также принимать три параметра
     * (address token, address to, uint256 give)
     * В таком случае мы отправим не нативную валюту,
     * а токены соответвующего адреса
     */
    function testSendEthWithDeal() public {
        address user = makeAddr("user");
        //Устанавливаем на user баланс со значением 1 ether
        vm.deal(user, 1 ether);
        assertEq(user.balance, 1 ether);

        //Отправляем на адрес контракта 1 ether от имени user и сверяем балансы
        vm.startPrank(user);
        (bool success,) = address(counter).call{value: 1 ether}("");
        vm.stopPrank();

        assertEq(success, true);
        assertEq(address(counter).balance, 1 ether);
        assertEq(user.balance, 0);
    }

    /**
     * метод hoax() или аналогичный startHoax()
     * объединяет в себе методы deal() и prank()
     * т.е. метод изменяет баланс выбранного адреса
     * и устанавливает его инициатором на ближайший вызов
     */
    function testSendEthWithHoax() public {
        address user = makeAddr("user");
        //Устанавливаем на user баланс со значением 1 ether и вызываем prank()
        hoax(user, 1 ether);
        (bool success,) = address(counter).call{value: 1 ether}("");

        assertEq(success, true);
        assertEq(address(counter).balance, 1 ether);
        assertEq(user.balance, 0);
    }

    /**
     * Проверяем временное ограничение, которое должно сработать
     * Если между последним и настоящим переводом прошло меньше
     * 1 дня
     */
    function testSendEth2timesWithoutWaiting() public {
        address user = makeAddr("user");
        //Устанавливаем на user баланс со значением 1 ether и вызываем prank()
        hoax(user, 1 ether);
        (bool success1,) = address(counter).call{value: 1 ether}("");

        hoax(user, 1 ether);
        (bool success2,) = address(counter).call{value: 1 ether}("");

        assertEq(success1, true);
        //Второй вызов должен закончится ошибкой
        assertEq(success2, false);
        assertEq(address(counter).balance, 1 ether);
        assertEq(user.balance, 1 ether);
    }

    /**
     * Специальный метод vm.warp() позволяет управлять временем
     * засчёт изменения параметра block.timestamp
     * В данном примере мы меняем время последнего блока
     * на 1 день вперёд и ещё раз делаем вызов, который
     * на этот раз должен пройти успешно
     */
    function testSendEth2timesWithWrap() public {
        address user = makeAddr("user");

        hoax(user, 1 ether);
        (bool success1,) = address(counter).call{value: 1 ether}("");

        //Устанавливаем значение block.timestamp
        vm.warp(block.timestamp + 1 days);
        hoax(user, 1 ether);
        (bool success2,) = address(counter).call{value: 1 ether}("");

        assertEq(success1, true);
        //Второй вызов должен пройти успешно
        assertEq(success2, true);
        assertEq(address(counter).balance, 2 ether);
        assertEq(user.balance, 0);
    }
}
