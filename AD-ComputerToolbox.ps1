#requires -Modules ActiveDirectory

Clear-Host

# ============================================================
# AD COMPUTER TOOLBOX
# Search Active Directory users and their assigned computers
# ============================================================

Write-Host ""
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host "             AD USER / COMPUTER TOOL" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host ""

# ============================================================
# DOMAIN
# ============================================================

$Domain = Read-Host "Введите DNS-имя домена"

if ([string]::IsNullOrWhiteSpace($Domain)) {
    Write-Host ""
    Write-Host "Домен не указан." -ForegroundColor Red
    Pause
    exit
}

Write-Host ""
Write-Host "Проверка домена $Domain..." -ForegroundColor Yellow

try {
    Get-ADDomain -Server $Domain -ErrorAction Stop | Out-Null
}
catch {
    Write-Host ""
    Write-Host "Не удалось подключиться к домену: $Domain" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    Write-Host ""
    Pause
    exit
}

Write-Host "Домен доступен." -ForegroundColor Green
Write-Host ""

# ============================================================
# USER SEARCH
# ============================================================

$Search = Read-Host "Введите фамилию, имя или логин"

if ([string]::IsNullOrWhiteSpace($Search)) {
    Write-Host ""
    Write-Host "Поисковая строка не указана." -ForegroundColor Red
    Pause
    exit
}

Write-Host ""
Write-Host "Поиск пользователей..." -ForegroundColor Yellow

$UserFilter = "Surname -like '*$Search*' -or GivenName -like '*$Search*' -or DisplayName -like '*$Search*' -or SamAccountName -like '*$Search*'"

try {
    $Users = @(
        Get-ADUser `
            -Server $Domain `
            -Filter $UserFilter `
            -Properties `
                DisplayName,
                GivenName,
                Surname,
                SamAccountName,
                UserPrincipalName,
                Enabled,
                OfficePhone,
                MobilePhone,
                Department,
                Title,
                Company,
                PasswordLastSet,
                DistinguishedName
    )
}
catch {
    Write-Host ""
    Write-Host "Ошибка поиска пользователя." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    Pause
    exit
}

if ($Users.Count -eq 0) {
    Write-Host ""
    Write-Host "Пользователи не найдены." -ForegroundColor Red
    Write-Host ""
    Pause
    exit
}

# ============================================================
# USER SELECTION
# ============================================================

Write-Host ""
Write-Host "Найдено пользователей: $($Users.Count)" -ForegroundColor Cyan
Write-Host ""

if ($Users.Count -eq 1) {

    $User = $Users[0]

}
else {

    $Number = 1

    foreach ($Item in $Users) {

        if ($Item.Enabled) {
            $Status = "Включен"
        }
        else {
            $Status = "ОТКЛЮЧЕН"
        }

        Write-Host "$Number. $($Item.DisplayName) | $($Item.SamAccountName) | $Status"

        $Number++
    }

    Write-Host ""

    do {
        $Selection = Read-Host "Введите номер пользователя"

        $SelectionNumber = 0

        $ValidSelection = [int]::TryParse(
            $Selection,
            [ref]$SelectionNumber
        )
    }
    until (
        $ValidSelection -and
        $SelectionNumber -ge 1 -and
        $SelectionNumber -le $Users.Count
    )

    $User = $Users[$SelectionNumber - 1]
}

# ============================================================
# USER OU
# ============================================================

$UserOU = $User.DistinguishedName

if ($UserOU -match "^[^,]+,(.+)$") {
    $UserOU = $Matches[1]
}

# ============================================================
# USER INFORMATION
# ============================================================

Clear-Host

Write-Host ""
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host "                  ПОЛЬЗОВАТЕЛЬ" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host ""

if ($User.Enabled) {
    $UserStatus = "Включен"
}
else {
    $UserStatus = "ОТКЛЮЧЕН"
}

Write-Host "ФИО             : $($User.DisplayName)"
Write-Host "Логин           : $($User.SamAccountName)"
Write-Host "Статус          : $UserStatus"
Write-Host "Телефон         : $($User.OfficePhone)"
Write-Host "Мобильный       : $($User.MobilePhone)"
Write-Host "Компания        : $($User.Company)"
Write-Host "Подразделение   : $($User.Department)"
Write-Host "Должность       : $($User.Title)"
Write-Host "Пароль изменен  : $($User.PasswordLastSet)"
Write-Host "OU              : $UserOU"

# ============================================================
# COMPUTER SEARCH
# ============================================================

Write-Host ""
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host "             КОМПЬЮТЕР ПОЛЬЗОВАТЕЛЯ" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host ""

Write-Host "Поиск компьютеров..." -ForegroundColor Yellow

# Search for the user's display name or login
# in the Description attribute of AD computers.

$ComputerFilter = "Description -like '*$($User.DisplayName)*' -or Description -like '*$($User.SamAccountName)*'"

try {
    $Computers = @(
        Get-ADComputer `
            -Server $Domain `
            -Filter $ComputerFilter `
            -Properties `
                Description,
                OperatingSystem,
                LastLogonDate,
                DistinguishedName
    )
}
catch {
    Write-Host ""
    Write-Host "Ошибка поиска компьютеров." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    Pause
    exit
}

# ============================================================
# COMPUTER INFORMATION
# ============================================================

if ($Computers.Count -eq 0) {

    Write-Host ""
    Write-Host "Компьютер пользователя не найден." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Поиск выполнялся по Description:" -ForegroundColor Gray
    Write-Host "  $($User.DisplayName)" -ForegroundColor White
    Write-Host "  $($User.SamAccountName)" -ForegroundColor White
    Write-Host ""

}
else {

    foreach ($Computer in $Computers) {

        Write-Host ""
        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

        Write-Host "ПК              : $($Computer.Name)" -ForegroundColor White

        $Online = Test-Connection `
            -ComputerName $Computer.Name `
            -Count 1 `
            -Quiet `
            -ErrorAction SilentlyContinue

        if ($Online) {
            Write-Host "Состояние       : В СЕТИ" -ForegroundColor Green
        }
        else {
            Write-Host "Состояние       : НЕ ДОСТУПЕН" -ForegroundColor Red
        }

        Write-Host "ОС              : $($Computer.OperatingSystem)"
        Write-Host "Последний вход   : $($Computer.LastLogonDate)"
        Write-Host "Description     : $($Computer.Description)"

        $ComputerOU = $Computer.DistinguishedName

        if ($ComputerOU -match "^[^,]+,(.+)$") {
            $ComputerOU = $Matches[1]
        }

        Write-Host "OU              : $ComputerOU"
    }
}

# ============================================================
# END
# ============================================================

Write-Host ""
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host "Домен: $Domain" -ForegroundColor DarkGray
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host ""

Pause
