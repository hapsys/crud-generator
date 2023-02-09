# CRUD generator for aeroflot services

Генерация основных классов для обеспечения CRUD манипуляцией с сущностями БД на основе мета-данных таблиц БД и/или
дополнительного описания.

### Пояснения

Генерация происходит в 6 этапов:

1. Генерация классов сущностей в БД (шаг entities)
2. Генерация интерфейсов репозитария (шаг repository)
3. Генерация классов транспорта DTO (шаг model)
4. Генерация классов отображения (шаг mapping)
5. Генерация классов сервисного слоя (шаг service)
6. Генерация контроллеров манипуляции с сущностями (шаг controller)

#### Конфигурация

Глобальные праметры конфигурации:

| Параметр                 | Назначение                                                                           |
|--------------------------|--------------------------------------------------------------------------------------|
| generator.root           | Путь для генерации получившихся классов.                                             |
| generator.export         | Путь XML файла для сохранения структуры.                                             |
| generator.schemas        | Схемы в БД для которых генерируется метадата.                                        |
| generator.tables.include | Имена таблиц (через запятую), для которых будет генерироваться метадата. Пусто: все. |
| generator.tables.exclude | Имена таблиц (через запятую), которые будут исключены из генерации метадаты.         |
| generator.entities       | Секция конфигурации генерации entities (см. поянения).                               |
| generator.repository       | Секция конфигурации генерации repository (см. поянения).                               |
| generator.model       | Секция конфигурации генерации model (см. поянения).                               |
| generator.mapping       | Секция конфигурации генерации mapping (см. поянения).                               |
| generator.service       | Секция конфигурации генерации service (см. поянения).                               |
| generator.controller       | Секция конфигурации генерации controller (см. поянения).                               |

Для каждой секции применяются следующие параметры:

| Параметр | Тип    | Назначение                                                                          |
|----------|--------|-------------------------------------------------------------------------------------|
| enable | bool   | Ключение генерации классов соотвествующей секции.                                   |
| packages | String | Название пакета генерируемых классов.                                               |
| template | String | XSLT шаблон, используемый ждя генерации классов.                                    |
| suffix | String | Суффикс генерируемых классов.                                                       |
| generate-data | bool   | Генерировать доп. класс.                                                            |
| suffix-data | String | Суффикс доп. генерируемых классов.                                                  |
| save-part-start | String | Регулярное выражение, для обнаруженя существующего дополнительного кода (костыль). |


#### Пояснения

1. Чтобы лишний раз не перекомпилировать генератор, пути всех шаблонов используют пути OS.
2. Дополнительно, в качестве примера, в проекте есть XML файл **meta-info.xml**, который покдлючается к шаблонам XSLT и может нести дополнительную мета-информацию для генерации. 

### Компиляция и запуск

Проект построен на Spring Boot 3.0.2 со сброщиком Maven, соответственно скоппилировать и запустить его можно строкой:

**mvn spring-boot:run**

### Дополнения

(опишу позже)