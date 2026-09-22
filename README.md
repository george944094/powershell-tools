# AD Computer Toolbox

A lightweight PowerShell tool for system administrators to quickly find an Active Directory user and identify the computer associated with that user.

## Features

* Connect to a selected Active Directory domain
* Search users by:

  * surname
  * first name
  * display name
  * login (`SamAccountName`)
* Select a user when multiple results are found
* Display user information:

  * full name
  * login
  * account status
  * phone numbers
  * company
  * department
  * job title
  * password last changed
  * Organizational Unit (OU)
* Search for the user's computer in Active Directory
* Check whether the computer is reachable over the network
* Display computer information:

  * computer name
  * operating system
  * last logon date
  * description
  * Organizational Unit (OU)

## Requirements

* Windows
* PowerShell 5.1 or PowerShell 7+
* Active Directory PowerShell module
* Network access to the Active Directory domain
* Permission to read Active Directory information

The Active Directory module is available through RSAT (Remote Server Administration Tools) on supported Windows systems.

## Usage

Run the script:

```powershell
.\AD-ComputerToolbox.ps1
```

The script will ask for the DNS name of the Active Directory domain.

Example:

```text
Введите DNS-имя домена: example.local
```

Then enter a user's surname, first name, display name or login.

If multiple users are found, the script displays a numbered list so the administrator can select the required account.

## How computer search works

The script searches Active Directory computer objects using the `Description` attribute.

It looks for either:

* the user's display name
* the user's `SamAccountName`

For example, if the user is:

```text
John Smith
```

and the computer object contains:

```text
Description: John Smith
```

the computer will be identified as the user's assigned workstation.

## Limitations

Computer identification depends on the information stored in the Active Directory `Description` attribute.

If the user's name or login is not stored in the computer description, the script may not find the associated computer.

The tool currently performs read-only Active Directory operations and does not modify users, computers or other AD objects.

## Example

```text
==================================================
             AD USER / COMPUTER TOOL
==================================================

Введите DNS-имя домена: example.local

Проверка домена example.local...
Домен доступен.

Введите фамилию, имя или логин: smith

Найдено пользователей: 1

==================================================
                  ПОЛЬЗОВАТЕЛЬ
==================================================

ФИО             : John Smith
Логин           : jsmith
Статус          : Включен
Компания        : Example Company
Подразделение   : IT
Должность       : System Administrator
OU              : OU=Users,DC=example,DC=local

==================================================
             КОМПЬЮТЕР ПОЛЬЗОВАТЕЛЯ
==================================================

Поиск компьютеров...

ПК              : PC-123
Состояние       : В СЕТИ
ОС              : Windows 11
```

## Project status

This project is being developed as a practical collection of PowerShell tools for system administrators.

More administration and automation utilities will be added over time.

## License

MIT License
