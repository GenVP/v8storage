
#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать v8runner
#Использовать json

Перем Лог;
Перем ЭтоWindows;
Перем КаталогХранилища;
Перем УправлениеКонфигураторомХранилища;
Перем ПараметрыАвторитизации;
Перем ТаблицаВерсий;
Перем МассивАвторов;
Перем ПарсерJSON;
Перем ПутьКОбработкеКонвертации;
Перем ЧтениеХранилищаВыполнено;
Перем ОбработкаКонвертацииОтчетаСобрана;

// Установка каталога файлового хранилища конфигурации
//
// Параметры:
//   НовыйКаталогХранилища - Строка - путь к папке с хранилищем конфигурации 1С
//
Процедура УстановитьКаталогХранилища(Знач НовыйКаталогХранилища) Экспорт
    КаталогХранилища = НовыйКаталогХранилища;
КонецПроцедуры

// Установка авторитизации в хранилище конфигурации
//
// Параметры:
//   Пользователь - Строка - пользователь хранилищем конфигурации 1С
//   Пароль - Строка - пароль пользователя хранилищем конфигурации 1С (по умолчанию пустая строка)
//
Процедура УстановитьПараметрыАвторитизации(Знач Пользователь, Знач Пароль = "") Экспорт

    ПараметрыАвторитизации.Вставить("Пользователь", Пользователь);
    ПараметрыАвторитизации.Вставить("Пароль", Пароль);

КонецПроцедуры

// Установка управления конфигуратором в класс менеджер хранилища конфигурации
//
// Параметры:
//   НовыйУправлениеКонфигуратором - класс - инстанс класс УправлениеКонфигуратором из библиотеке v8runner
//
Процедура УстановитьУправлениеКонфигуратором(НовыйУправлениеКонфигуратором) Экспорт

    УправлениеКонфигураторомХранилища = НовыйУправлениеКонфигуратором;

КонецПроцедуры

// Получает управления конфигуратором используемое в менеджере хранилища конфигурации
//
Функция ПолучитьУправлениеКонфигуратором() Экспорт

    Возврат УправлениеКонфигураторомХранилища;

КонецФункции

// Захват объектов для редактирования в хранилище конфигурации
//
// Параметры:
//  ПутьКФайлуСоСпискомОбъектов - Строка - Строка путь к файлу xml c содержанием в формате http://its.1c.ru/db/v839doc#bookmark:adm:TI000000712
// 									 путь к файлу формата XML со списком объектов. Если опция используется, будет выполнена попытка захватить только объекты,
//									 указанные в файле. Если опция не используется, будут захвачены все объекты конфигурации.
//									 Если в списке указаны объекты, захваченные другим пользователем, эти объекты не будут захвачены и будет выдана ошибка.
//									 При этом доступные для захвата объекта будут захвачены. Подробнее о формате файла см в документации.
//  ПолучатьЗахваченныеОбъекты  - булево - Флаг получения захваченных объектов (По умолчанию равно "Ложь")
//
Процедура ЗахватитьОбъектыВХранилище(Знач ПутьКФайлуСоСпискомОбъектов = "",
                                    Знач ПолучатьЗахваченныеОбъекты = Ложь) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryLock ");

    Если Не ПустаяСтрока(ПутьКФайлуСоСпискомОбъектов) Тогда
        Параметры.Добавить(СтрШаблон("-objects ""%1""", ПутьКФайлуСоСпискомОбъектов));
    КонецЕсли;

    Если ПолучатьЗахваченныеОбъекты Тогда
        Параметры.Добавить("-revised");
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);
    ВыводКоманды = УправлениеКонфигураторомХранилища.ВыводКоманды();

КонецПроцедуры // ЗахватитьОбъектыВХранилище()

// Отмена захват объектов для редактирования в хранилище конфигурации
//
// Параметры:
//  СписокОбъектов  	  - Строка - Строка путь к файлу xml c содержанием в формате http://its.1c.ru/db/v839doc#bookmark:adm:TI000000712
// 									 Если опция используется, будет выполнена попытка отменить захват только для объектов, указанных в файле.
//									 Если опция не используется, захват будет отменен для всех объектов конфигурации.
//									 При наличии в списке объектов, не захваченных текущим пользователем или захваченных другим пользователем, ошибка выдана не будет
//  ИгнорироватьИзменения - булево - Флаг игнорирования локальных изменений (По умолчанию равно "Ложь")
//									 Локально измененные объекты будут получены из хранилища, и внесенные изменения будут потеряны.
//									 Если опция не указана, то при наличии локально измененных объектов операция будет отменена и будет выдана ошибка.
//
Процедура ОтменитьЗахватОбъектовВХранилище(Знач СписокОбъектов = Неопределено,
                                    Знач ИгнорироватьИзменения = Ложь) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryUnlock ");

    Если Не ПустаяСтрока(СписокОбъектов) Тогда
        Параметры.Добавить(СтрШаблон("-objects ""%1""", СписокОбъектов));
    КонецЕсли;

    Если ИгнорироватьИзменения Тогда
        Параметры.Добавить("-force");
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);
    ВыводКоманды = УправлениеКонфигураторомХранилища.ВыводКоманды();
КонецПроцедуры // ВыполнитьОтменуЗахватаВХранилище()

// Помещение изменений объектов в хранилище конфигурации
//
// Параметры:
//  СписокОбъектов  	  - Строка - Строка путь к файлу xml c содержанием в формате http://its.1c.ru/db/v839doc#bookmark:adm:TI000000712
//                                   Если опция используется, будет выполнена попытка поместить только объекты, указанные в файле.
//                                   Если опция не используется, будут помещены изменения всех объектов конфигурации.
//                                   При наличии в списке объектов, не захваченных текущим пользователем или захваченных другим пользователем, ошибка выдана не будет
//  Комментарий	 	      - Строка - Комментарий к помещаемым. Чтобы установить многострочный комментарий, для каждой строки следует использовать свою опцию comment.
//  ОставитьОбъектыЗахваченными  - булево - оставлять захват для помещенных объектов.
//  ИгнорироватьУдаленные - булево - Флаг игнорирования удаления объектов. По умолчанию = Ложь
//                                   Если опция используется, при обнаружении ссылок на удаленные объекты будет выполнена попытка их очистить.
//                                   Если опция не указана, при обнаружении ссылок на удаленные объекты будет выдана ошибка.
//
Процедура ПоместитьИзмененияОбъектовВХранилище(Знач СписокОбъектов = Неопределено,
                                    Знач Комментарий = "",
                                    Знач ОставитьОбъектыЗахваченными = Ложь,
                                    Знач ИгнорироватьУдаленные = Ложь) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryCommit ");

    Если Не ПустаяСтрока(СписокОбъектов) Тогда
        Параметры.Добавить(СтрШаблон("-objects ""%1""", СписокОбъектов));
    КонецЕсли;

    МассивСтрок = СтрРазделить(Комментарий, Символы.ПС);

    Для Каждого СтрокаКомментария Из МассивСтрок Цикл

        Параметры.Добавить(СтрШаблон("-comment ""%1""", СтрокаКомментария));

    КонецЦикла;

    Если ОставитьОбъектыЗахваченными Тогда
        Параметры.Добавить("-keepLocked");
    КонецЕсли;

    Если ИгнорироватьУдаленные Тогда
        Параметры.Добавить("-force");
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры // ПоместитьИзмененияОбъектовВХранилище()

// Возвращает вывод выполнения команды конфигуратора
//
Функция ПолучитьВыводКоманды() Экспорт

    Возврат УправлениеКонфигураторомХранилища.ВыводКоманды();

КонецФункции

// Создание файлового хранилища конфигурации используя контекст конфигуратора
//
// Параметры:
//  ПодключитьБазуКхранилищу  - булево - признак необходимости подключения базы контекста к хранилищу (по умолчанию ложь)
Процедура СоздатьФайловоеХранилищеКонфигурации(знач ПодключитьБазуКхранилищу = Ложь) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryCreate ");

    Параметры.Добавить("-AllowConfigurationChanges");
    Параметры.Добавить("-ChangesAllowedRule ObjectNotSupported");
    Параметры.Добавить("-ChangesNotRecommendedRule ObjectNotSupported");

    Если ПодключитьБазуКхранилищу = Ложь Тогда
        Параметры.Добавить("-NoBind");
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Установка метки для версии хранилища
//
// Параметры:
//  Метка  	  			  - Строка - текст метки
//  Комментарий  	  	  - Строка - текст комментария к устанавливаемой метки.
//  Версия  	  	   	  - Строка - номер версии хранилища, для которого устанавливается метка.
//									Если версия не указана, метка ставится для самой последнее версии хранилища.
//									Если указана несуществующая версия, выдается ошибка
//
Процедура УстановитьМеткуДляВерсииВХранилище(Знач Метка,
                                    Знач Комментарий = "",
                                       Знач Версия = "") Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositorySetLabel ");

    Параметры.Добавить(СтрШаблон("-name ""%1""", Метка));

    МассивСтрок = СтрРазделить(Комментарий, Символы.ПС);

    Для Каждого СтрокаКомментария Из МассивСтрок Цикл

       Параметры.Добавить(СтрШаблон("-comment ""%1""", СтрокаКомментария));

    КонецЦикла;

    Если Не ПустаяСтрока(Версия) Тогда
        Параметры.Добавить("-v " + Версия);
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры // УстановитьМеткуДляВерсииВХранилище()

// Добавление пользователя хранилища конфигурации.
//	Пользователь, от имени которого выполняется подключение к хранилищу, должен обладать административными правами.
//	Если пользователь с указанным именем существует, то пользователь добавлен не будет.
// Параметры:
//   НовыйПользователь - Строка - Имя создаваемого пользователя.
//   ПарольПользователя - Строка - Пароль создаваемого пользователя.
//   Право - ПраваПользователяХранилища - Права пользователя. Возможные значения:
// 		ТолькоЧтение — право на просмотр, (по умолчанию)
// 		ПравоЗахватаОбъектов — право на захват объектов,
// 		ПравоИзмененияВерсий — право на изменение состава версий,
// 		Администрирование — право на административные функции.
// 	 ВосстановитьУдаленного - Булево - флаг небходимости востановления удаленного пользователя
//								       Если обнаружен удаленный пользователь с таким же именем, он будет восстановлен.
//
Процедура ДобавитьПользователяВХранилище(Знач НовыйПользователь,
                                        Знач ПарольПользователя = "",
                                        Знач Право = Неопределено,
                                        Знач ВосстановитьУдаленного = Ложь) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryAddUser ");
    Параметры.Добавить(СтрШаблон("-User ""%1""",НовыйПользователь));
    Если Не ПустаяСтрока(ПарольПользователя) Тогда
        Параметры.Добавить(СтрШаблон("-Pwd ""%1""",ПарольПользователя));
    КонецЕсли;

    Если Не ЗначениеЗаполнено(Право) ТОгда
        Право = ПраваПользователяХранилища().ТолькоЧтение;
    КонецЕсли;

    Параметры.Добавить(СтрШаблон("-Rights %1",Право));

    Если ВосстановитьУдаленного Тогда
        Параметры.Добавить("-RestoreDeletedUser");
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Копирование пользователей из хранилища конфигурации. Копирование удаленных пользователей не выполняется.
//   Если пользователь с указанным именем существует, то пользователь не будет добавлен.
//
//Параметры:
//   СтрокаСоединенияХранилищаКопии - Строка - Путь к хранилищу, из которого выполняется копирование пользователей.
//   ПользовательХранилищаКопии - Строка - Имя пользователя хранилища, из которого выполняется копирование пользователей.
//   ПарольХранилищаКопии - Строка - Пароль пользователя хранилища, из которого выполняется копирование пользователей.
//   ВосстановитьУдаленного - Булево - флаг небходимости востановления удаленных пользователей
//
Процедура КопироватьПользователейИзХранилища(Знач СтрокаСоединенияХранилищаКопии,
                                        Знач ПользовательХранилищаКопии,
                                        Знач ПарольХранилищаКопии = "",
                                        Знач ВосстановитьУдаленного = Ложь) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryCopyUsers ");
    Параметры.Добавить(СтрШаблон("-Path ""%1""",СтрокаСоединенияХранилищаКопии));
    Параметры.Добавить(СтрШаблон("-User ""%1""",ПользовательХранилищаКопии));
    Если Не ПустаяСтрока(ПарольХранилищаКопии) Тогда
        Параметры.Добавить(СтрШаблон("-Pwd ""%1""",ПарольХранилищаКопии));
    КонецЕсли;

    Если ВосстановитьУдаленного Тогда
        Параметры.Добавить("-RestoreDeletedUser");
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Сохранение в файл версии конфигурации из хранилища
//
// Параметры:
//   НомерВерсии - число/строка - номер версии в хранилище
//   ИмяФайлаКофигурации - строка - путь к файлу в который будет сохранена версия конфигурации из хранилища
//
Процедура СохранитьВерсиюКонфигурацииВФайл(Знач НомерВерсии, Знач ИмяФайлаКофигурации) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить(СтрШаблон("/ConfigurationRepositoryDumpCfg ""%1""", ИмяФайлаКофигурации));

    Если Не ПустаяСтрока(НомерВерсии) Тогда
        Параметры.Добавить("-v "+НомерВерсии);
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Сохранение в файл последней версии конфигурации из хранилища
// (обертка над процедурой "СохранитьВерсиюКонфигурацииВФайл")
// Параметры:
//   ИмяФайлаКофигурации - строка - путь к файлу в который будет сохранена версия конфигурации из хранилища
//
Процедура ПоследняяВерсияКонфигурацииВФайл(Знач ИмяФайлаКофигурации) Экспорт

   СохранитьВерсиюКонфигурацииВФайл("", ИмяФайлаКофигурации);

КонецПроцедуры

// Чтение данных по истории версий и авторов из хранилища
//
// Параметры:
//   НомерНачальнойВерсии - число - номер версии хранилища,
//                                  с которой производиться получение истории (по умолчанию 1)
//
Процедура ПрочитатьХранилище(Знач НомерНачальнойВерсии = 1) Экспорт

    ПутьКФайлуОтчета = ВременныеФайлы.НовоеИмяФайла("mxl");
    ПутьКФайлуОтчетаJSON = ВременныеФайлы.НовоеИмяФайла("json");

    ПолучитьОтчетПоВерсиям(ПутьКФайлуОтчета, НомерНачальнойВерсии);
    СконвертироватьОтчет(ПутьКФайлуОтчета, ПутьКФайлуОтчетаJSON);

    ТекстJSON = ПрочитатьФайл(ПутьКФайлуОтчетаJSON);
    Результат = ПарсерJSON.ПрочитатьJSON(ТекстJSON);

    МассивАвторов = Результат["Авторы"];
    ПрочитатьТаблицуВерсий(Результат["Версии"]);

    ЧтениеХранилищаВыполнено = Истина;

КонецПроцедуры

// Получение таблицы истории версий из хранилища
// (выполняет ПрочитатьХранилище(1), если еще не было чтения)
//
// Возвращаемое значение таблица значений:
//   Колонки:
//      Номер   - число - номер версии
//      Дата    - Дата - Дата версии
//      Автор   - строка - автор версии
//      Комментарий   - Строка - многострочная строка с комментарием к версии
//
Функция ПолучитьТаблицуВерсий() Экспорт

    ПроверитьЗагрузкуДанныхХранилища();

    Возврат ТаблицаВерсий;


КонецФункции // ПолучитьТаблицуВерсий() Экспорт

// Получение массива авторов версий из хранилища
// (выполняет ПрочитатьХранилище(1), если еще не было чтения)
//
// Возвращаемое значение массив:
//      Автор - строка - используемые авторы в хранилище
//
Функция ПолучитьАвторов() Экспорт

    ПроверитьЗагрузкуДанныхХранилища();

    Возврат МассивАвторов;


КонецФункции // ПолучитьТаблицаВерсий() Экспорт

// Получение отчет по истории версий  из хранилища
//
// Параметры:
//   ПутьКФайлуРезультата - Строка - путь к файлу в который будет выгружен отчет,
//   НомерНачальнойВерсии - число - номер начальной версии хранилища,
//                                  с которой производиться получение истории (по умолчанию 1)
//   НомерКонечнойВерсии  - число - номер конечной версии хранилища. (по умолчанию - Неопределено)
//
Процедура ПолучитьОтчетПоВерсиям(Знач ПутьКФайлуРезультата,
                                Знач НомерНачальнойВерсии = 1,
                                Знач НомерКонечнойВерсии = Неопределено) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryReport """+ПутьКФайлуРезультата + """");

    Параметры.Добавить("-NBegin "+НомерНачальнойВерсии);

    Если ЗначениеЗаполнено(НомерКонечнойВерсии) Тогда

        Параметры.Добавить("-NEnd "+НомерКонечнойВерсии);

    КонецЕслИ;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Выполняет подключение ранее неподключенной информационной базы к хранилищу конфигурации.
//
// Параметры:
//  ИгнорироватьНаличиеПодключеннойБД  - Булево - Флаг игнорирования наличия уже у пользователя уже подключенной базы данных. По умолчанию = Ложь
//								 	 Выполняет подключение даже в том случае, если для данного пользователя уже есть конфигурация, связанная с данным хранилищем..
//  ЗаменитьКонфигурациюБД - Булево - Флаг замены конфигурации БД на конфигурацию хранилища  (По умолчанию Истина)
//									 Если конфигурация непустая, данный ключ подтверждает замену конфигурации на конфигурацию из хранилища.
//
Процедура ПодключитьсяКХранилищу(Знач ИгнорироватьНаличиеПодключеннойБД = Ложь, Знач ЗаменитьКонфигурациюБД = Истина) Экспорт

    Если Не ЗначениеЗаполнено(КаталогХранилища) Тогда
        ВызватьИсключение "Не установлен каталог хранилища 1С";
    КонецЕсли;

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryBindCfg ");

    Если ИгнорироватьНаличиеПодключеннойБД Тогда
        Параметры.Добавить("-forceBindAlreadyBindedUser ");
    КонецЕсли;
    Если ЗаменитьКонфигурациюБД Тогда
        Параметры.Добавить("-forceReplaceCfg ");
    КонецЕсли;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Выполняет отключение ранее подключенной информационной базы (база контекста) к хранилищу конфигурации.
//
Процедура ОтключитьсяОтХранилища() Экспорт
    Параметры = СтандартныеПараметрыЗапуска();
    Параметры.Добавить("/ConfigurationRepositoryUnbindCfg -force ");

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);
КонецПроцедуры

// Выполняет оптимизацию хранения базы данных хранилища конфигурации.
//
Процедура ОптимизироватьБазуХранилища() Экспорт
    Параметры = СтандартныеПараметрыЗапуска();
    Параметры.Добавить("/ConfigurationRepositoryOptimizeData ");

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);
КонецПроцедуры

// Получение отчет по истории версий  из хранилища
//
// Параметры:
//   ПутьКФайлуРезультата - Строка - путь к файлу отчета в формате mxl
//   ПутьКФайлуОтчетаJSON - Строка - путь к файлу в который будет выгружен отчет в формате json,
//
Процедура СконвертироватьОтчет(Знач ПутьКФайлуОтчета, Знач ПутьКФайлуОтчетаJSON) Экспорт

    КлючЗапуска = СтрШаблон("""%1;%2""", ПутьКФайлуОтчета, ПутьКФайлуОтчетаJSON);
    ПараметрыЗапускаОбработки = СтрШаблон("/Execute ""%1""", ПолучитьОбработкуКонвертацииОтчета());
    УправлениеКонфигураторомХранилища.ЗапуститьВРежимеПредприятия(КлючЗапуска, Ложь, ПараметрыЗапускаОбработки);

КонецПроцедуры

// Возвращает структура возможных прав пользователя в хранилище конфигурации
//   Ключи структуры:
// 		ТолькоЧтение — право на просмотр, (по умолчанию)
// 		ПравоЗахватаОбъектов — право на захват объектов,
// 		ПравоИзмененияВерсий — право на изменение состава версий,
// 		Администрирование — право на административные функции.
//
Функция ПраваПользователяХранилища() Экспорт

    Права = Новый Структура;

    Права.Вставить("ТолькоЧтение", "ReadOnly");
    Права.Вставить("ПравоЗахватаОбъектов", "LockObjects");
    Права.Вставить("ПравоИзмененияВерсий", "ManageConfigurationVersions");
    Права.Вставить("Администрирование", "Administration");

    Возврат Права;

КонецФункции // ПраваПользователяХранилища()


//////////////////////////////
// Вспомогательные процедуры и функции


Процедура ПроверитьЗагрузкуДанныхХранилища()

    Если Не ЧтениеХранилищаВыполнено Тогда
       ПрочитатьХранилище();
    КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьТаблицуВерсий(Знач МассивВерсий)

    ТаблицаВерсий = Новый ТаблицаЗначений;
    ТаблицаВерсий.Колонки.Добавить("Номер");
    ТаблицаВерсий.Колонки.Добавить("Дата");
    ТаблицаВерсий.Колонки.Добавить("Автор");
    ТаблицаВерсий.Колонки.Добавить("Комментарий");

    Для Каждого ВерсияМассива из МассивВерсий Цикл

         НоваяСтрока = ТаблицаВерсий.Добавить();
         НоваяСтрока.Номер = ВерсияМассива["Номер"];
         НоваяСтрока.Дата = ВерсияМассива["Дата"];
         НоваяСтрока.Автор = ВерсияМассива["Автор"];
         НоваяСтрока.Комментарий = ВерсияМассива["Комментарий"];

    КонецЦикла

КонецПроцедуры

Функция ПрочитатьФайл(ПутьКФайлу)


    ЧтениеТекстаФайла = Новый ЧтениеТекста(ПутьКФайлу, "utf-8");

    Текст = ЧтениеТекстаФайла.Прочитать();

    ЧтениеТекстаФайла.Закрыть();

    Если ПустаяСтрока(Текст) Тогда

        ВызватьИсключение "Из файла ничего не прочитано"

    Иначе

        Возврат Текст;

    КонецЕсли;

КонецФункции

Функция ПолучитьОбработкуКонвертацииОтчета()

    Если НЕ ОбработкаКонвертацииОтчетаСобрана Тогда

        СобратьОбработкуКонвертацииОтчета();

    КонецЕсли;

    Возврат ПутьКОбработкеКонвертации;

КонецФункции

Процедура СобратьОбработкуКонвертацииОтчета()

    ФайлОбработки = Новый Файл(ПутьКОбработкеКонвертации);
    
    Если ФайлОбработки.Существует() Тогда
        Лог.Отладка("Найдена готовая обработка по пути: %1", ПутьКОбработкеКонвертации );
        ОбработкаКонвертацииОтчетаСобрана = Истина;
        
        Возврат;

    КонецЕсли;
    Лог.Отладка("Не найдена готовая обработка по пути: %1
    | делаю попытку собрать временную обработку исходников", ПутьКОбработкеКонвертации );

    ПутьКОбработкеКонвертации = ВременныеФайлы.НовоеИмяФайла("epf");

    СобратьОбработкуКонвертации(ОбъединитьПути(ТекущийСценарий().Каталог,"../../epf/ОбработкаКонвертацииMXLJSON/ОбработкаКонвертацииMXLJSON.xml"), ПутьКОбработкеКонвертации);

    ОбработкаКонвертацииОтчетаСобрана = Истина;
    
КонецПроцедуры

Функция СтандартныеПараметрыЗапуска()

    УправлениеКонфигураторомХранилища.УстановитьКодЯзыка("ru");
    ПараметрыЗапуска = УправлениеКонфигураторомХранилища.ПолучитьПараметрыЗапуска();

    Если Не ПустаяСтрока(ПараметрыАвторитизации.Пользователь) Тогда
         ПараметрыЗапуска.Добавить(СтрШаблон("/ConfigurationRepositoryN ""%1""", ПараметрыАвторитизации.Пользователь));
    КонецЕсли;

    Если Не ПустаяСтрока(ПараметрыАвторитизации.Пароль) Тогда
         ПараметрыЗапуска.Добавить(СтрШаблон("/ConfigurationRepositoryP ""%1""", ПараметрыАвторитизации.Пароль));
    КонецЕсли;

    Если Не ПустаяСтрока(КаталогХранилища) Тогда
         ПараметрыЗапуска.Добавить(СтрШаблон("/ConfigurationRepositoryF ""%1""", КаталогХранилища));
    КонецЕсли;

    Возврат ПараметрыЗапуска;
КонецФункции // СтандартныеПараметрыЗапуска()

// Возвращает таблицу захваченных объектов объектов в хранилище, согласно тексту лога захвата
//
// Параметры:
//  ТекстЛога - строка - строка вывода результат выполенния команды захвата в хранилище
//
// Возвращаемое значение:
//  ТаблицаЗначений:
//    ПолноеИмя - строка - например, Документы.Документ1.Формы.ФормаДокумента1
//    ЗахваченДляРедактирования - булево - признак успешного захвата в хранилище
//
Функция ПолучитьТаблицуЗахваченныхОбъектов(ТекстЛога) Экспорт

    ЗахваченныеОбъекты = Новый ТаблицаЗначений;
    ЗахваченныеОбъекты.Колонки.Добавить("ПолноеИмя");
    ЗахваченныеОбъекты.Колонки.Добавить("ЗахваченДляРедактирования");

    ТекстОбъектЗахваченУспешно = НСтр("ru='Объект захвачен для редактирования:'en='Object locked for editing:");

    ДокументТекст = Новый ТекстовыйДокумент;
    ДокументТекст.УстановитьТекст(ТекстЛога);

    КоличествоСтрок = ДокументТекст.КоличествоСтрок();

    Для НомерСтроки = 1 По КоличествоСтрок Цикл

        СтрокаТекста = ДокументТекст.ПолучитьСтроку(НомерСтроки);

        Лог.Отладка(СтрШаблон("Обрабатываю строку: №%1 - %2", НомерСтроки, СтрокаТекста));

        // Пытаемся получить объект из строки лога.
        ПозицияПоиска = СтрНайти(СтрокаТекста, ":");
        Если ПозицияПоиска = 0 Тогда
            // Если в строке нет двоеточия, это не строка с объектом, пропускаем.
            Продолжить;
        КонецЕсли;

        ПутьОбъекта = Сред(СтрокаТекста, ПозицияПоиска + 1);

        // Если объект захвачен другим пользователем, то в конце строки будет имя пользователя в скобках, удаляем.
        ПозицияПоиска = СтрНайти(ПутьОбъекта, "(");
        Если ПозицияПоиска > 0 Тогда
            ПутьОбъекта = Лев(ПутьОбъекта, ПозицияПоиска - 1);
        КонецЕсли;

        ПутьОбъекта = СокрЛП(ПутьОбъекта);
        // Если в пути к объекту остались пробелы, значит, это не объект, пропускаем.
        Если СтрНайти(ПутьОбъекта, " ") > 0 Тогда
            Продолжить;
        КонецЕсли;

        ОбъектЗахваченУспешно = СтрНачинаетсяС(СтрокаТекста, ТекстОбъектЗахваченУспешно);


        // Если в пути к объекту нет точек, тогда это корень конфигурации, переименуем его.
        Если СтрНайти(ПутьОбъекта, ".") = 0 Тогда
            Лог.Отладка(СтрШаблон("Захвачен для редактирования корень конфигурации"));
            ПутьОбъекта = "Конфигурация";
        КонецЕсли;

        НовыйОбъект = ЗахваченныеОбъекты.Добавить();
        НовыйОбъект.ПолноеИмя = ПутьОбъекта;
        НовыйОбъект.ЗахваченДляРедактирования = ОбъектЗахваченУспешно;

    КонецЦикла;

    Возврат ЗахваченныеОбъекты;

КонецФункции

Процедура Инициализация()

    Лог = Логирование.ПолучитьЛог("oscript.lib.v8storage");
    ПараметрыАвторитизации = Новый Структура();
    УстановитьПараметрыАвторитизации("");

    УправлениеКонфигураторомХранилища = Новый УправлениеКонфигуратором();
    ВременныйКаталог = ВременныеФайлы.СоздатьКаталог();
    УправлениеКонфигураторомХранилища.КаталогСборки(ВременныйКаталог);
    УправлениеКонфигураторомХранилища.УстановитьКодЯзыкаСеанса("ru");
    ОбработкаКонвертацииОтчетаСобрана = Ложь;
    ПутьКОбработкеКонвертации = ОбъединитьПути(ТекущийСценарий().Каталог,"../../bin/ОбработкаКонвертацииMXLJSON.epf");

    СистемнаяИнформация = Новый СистемнаяИнформация;
    ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
    ПарсерJSON = Новый ПарсерJSON();
    ЧтениеХранилищаВыполнено = Ложь;
   
КонецПроцедуры

Процедура СобратьОбработкуКонвертации(Знач ПапкаИсходников, Знач ИмяФайлаОбъекта) Экспорт

    Лог.Отладка("Собираю файл из исходников <%1> в файл %2", ПапкаИсходников, ИмяФайлаОбъекта);
    Лог.Отладка("");

    Параметры = УправлениеКонфигураторомХранилища.ПолучитьПараметрыЗапуска();

    Параметры.Добавить("/LoadExternalDataProcessorOrReportFromFiles");
    Параметры.Добавить(СтрШаблон("""%1""", ПапкаИсходников));
    Параметры.Добавить(СтрШаблон("""%1""", ИмяФайлаОбъекта));

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

    Лог.Отладка("Вывод 1С:Предприятия - " + УправлениеКонфигураторомХранилища.ВыводКоманды());
    Лог.Отладка("");

КонецПроцедуры

Инициализация();