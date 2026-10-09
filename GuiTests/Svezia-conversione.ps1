param()
# Scenario Toto14ToText: conversione SCH -> file E/M per il totocalcio svedese, limiti, INI e regressione Quiniela.
# Gli SCH di prova vengono generati al volo in %TEMP%\Toto14ToText_test, ricreata a ogni giro e lasciata
# alla fine per controllare file e screenshot dei messaggi.
$ErrorActionPreference = 'Stop'
Import-Module 'E:\dati\common\DelphiGuiTest\DelphiGuiTest.psm1' -Force
Set-Location (Split-Path $PSScriptRoot -Parent)          # root del progetto

$exe = 'Win32\Debug\Toto14ToText.exe'
$ini = 'Win32\Debug\Toto14ToText.ini'
$lav = Join-Path $env:TEMP 'Toto14ToText_test'

# ---------------------------------------------------------------- utilita'
# una colonna = 13 o 14 gruppi separati da spazio (1, X, 2, 1X, 12, X2, 1X2, '-' = nessun segno)
function New-Sch([string]$Nome, [string[]]$Colonne) {
    $ms = New-Object System.IO.MemoryStream
    $bw = New-Object System.IO.BinaryWriter($ms)
    foreach ($c in $Colonne) {
        $m = @(0, 0, 0)
        $g = $c.Trim() -split '\s+'
        for ($i = 0; $i -lt $g.Count; $i++) {
            if ($g[$i].Contains('1')) { $m[0] = $m[0] -bor (1 -shl $i) }
            if ($g[$i].Contains('X')) { $m[1] = $m[1] -bor (1 -shl $i) }
            if ($g[$i].Contains('2')) { $m[2] = $m[2] -bor (1 -shl $i) }
        }
        foreach ($v in $m) { $bw.Write([uint16]$v) }
    }
    $bw.Write([byte[]](0, 0, 0, 0, 0, 0))                 # footer di 6 byte
    $bw.Flush()
    $p = Join-Path $lav $Nome
    [System.IO.File]::WriteAllBytes($p, $ms.ToArray())
    return $p
}

function Get-Righe([string]$Path) { return @([System.IO.File]::ReadAllLines($Path)) }

function Invoke-Conversione([string]$Sch, [string]$Tipo, [string]$Prono15 = '') {
    Select-DgtComboItem $Tipo -Index 1
    if ($Prono15) { Select-DgtComboItem $Prono15 -Index 0 }
    Set-DgtText -Class 'TJvFilenameEdit' -Value $Sch
    if ($Tipo -eq 'Conversione Svezia') { Invoke-DgtClick 'Esegui conversione per Svezia' }
    else { Invoke-DgtClick 'Esegui conversione per Quiniela ' }      # la caption ha uno spazio finale
    $d = Wait-DgtDialog -TimeoutSec 10
    Assert-DgtTrue ($d -ne $null) ('compare il messaggio dopo la conversione di ' + (Split-Path $Sch -Leaf)) -Fatal
    return $d
}

function Close-Messaggio([string]$Foto) {
    if ($Foto) { Save-DgtScreenshot -Hwnd (Wait-DgtDialog).Hwnd -Path (Join-Path $lav $Foto) | Out-Null }
    Close-DgtDialog 'OK'
    Start-Sleep -Milliseconds 300
}

$uno13 = '1 1 1 1 1 1 1 1 1 1 1 1 1'

Start-DgtTest 'Toto14ToText - conversione Svezia (file E/M), limiti e regressione Quiniela'
$esito = 1
try {
    Backup-DgtFiles $ini
    if (Test-Path $lav) { Remove-Item $lav -Recurse -Force }
    New-Item -ItemType Directory -Path $lav | Out-Null

    # INI con i default (percorso assoluto: il file potrebbe non esistere ancora)
    $iniFull = Join-Path (Get-Location) $ini
    [System.IO.File]::WriteAllText($iniFull, "[Svezia]`r`nMaxRigheE=2200`r`nMaxRigheM=950`r`nMaxColonne=20000`r`nNomeGioco=`r`n")

    Start-DgtApp -Path $exe -WindowClass 'TMain' | Out-Null

    # ---- 1) interfaccia: con Svezia la combo del 15mo si disattiva e il bottone cambia
    Select-DgtComboItem 'Conversione Svezia' -Index 1
    Start-Sleep -Milliseconds 300
    $combo15 = @(Get-DgtControls | Where-Object { $_.Class -eq 'TComboBox' -and $_.Text -notlike 'Conversione*' })[0]
    Assert-DgtTrue (-not $combo15.Enabled) 'con Svezia la combo del 15mo e'' disattivata'
    Assert-DgtTrue ((Find-DgtControl -Text 'Esegui conversione per Svezia' -NoThrow) -ne $null) 'con Svezia il bottone dice "Esegui conversione per Svezia"'
    Select-DgtComboItem 'Conversione Quiniela' -Index 1
    Start-Sleep -Milliseconds 300
    $combo15 = @(Get-DgtControls | Where-Object { $_.Class -eq 'TComboBox' -and $_.Text -notlike 'Conversione*' })[0]
    Assert-DgtTrue $combo15.Enabled 'tornando a Quiniela la combo del 15mo si riattiva'

    # ---- 2) solo colonne singole: file E, il 14mo segno viene ignorato, il vecchio file M viene cancellato
    $sch = New-Sch 'singole.sch' @('1 1 1 1 1 1 1 1 1 1 1 1 1 X', 'X 2 1 X 2 1 X 2 1 X 2 1 X 1')
    Set-Content -Path (Join-Path $lav 'singole-M.txt') -Value 'vecchio'
    Invoke-Conversione $sch 'Conversione Svezia' | Out-Null
    Close-Messaggio 'msg_singole.png'
    $e = Join-Path $lav 'singole-E.txt'
    Assert-DgtTrue (Test-Path $e) 'creato singole-E.txt'
    Assert-DgtEqual ((Get-Righe $e) -join '|') 'E,1,1,1,1,1,1,1,1,1,1,1,1,1|E,X,2,1,X,2,1,X,2,1,X,2,1,X' 'contenuto di singole-E.txt'
    Assert-DgtTrue (-not (Test-Path (Join-Path $lav 'singole-M.txt'))) 'cancellato il vecchio singole-M.txt'
    $b = [System.IO.File]::ReadAllBytes($e)
    Assert-DgtTrue (($b[0] -eq [byte][char]'E') -and ($b[$b.Length - 2] -eq 13) -and ($b[$b.Length - 1] -eq 10)) 'singole-E.txt senza BOM e con righe CR+LF'
    Save-DgtScreenshot -Path (Join-Path $lav 'finestra_dopo_singole.png') | Out-Null

    # ---- 3) singole + sistemini: file E ed M, gruppi sempre in ordine 1 X 2
    $sch = New-Sch 'misto.sch' @('1 X 2 1 X 2 1 X 2 1 X 2 1 1', '1X X2 12 1 1 1 1 1 1 1 1 1 1 2', '1X2 1 1 1 1 1 1 1 1 1 1 1 1 1')
    Invoke-Conversione $sch 'Conversione Svezia' | Out-Null
    Close-Messaggio 'msg_misto.png'
    Assert-DgtEqual ((Get-Righe (Join-Path $lav 'misto-E.txt')) -join '|') 'E,1,X,2,1,X,2,1,X,2,1,X,2,1' 'contenuto di misto-E.txt'
    Assert-DgtEqual ((Get-Righe (Join-Path $lav 'misto-M.txt')) -join '|') 'M8,1X,X2,12,1,1,1,1,1,1,1,1,1,1|M3,1X2,1,1,1,1,1,1,1,1,1,1,1,1' 'contenuto di misto-M.txt'

    # ---- 4) oltre 20.000 colonne (3^10 = 59.049): rifiutato, nessun file
    $sch = New-Sch 'troppe.sch' @('1X2 1X2 1X2 1X2 1X2 1X2 1X2 1X2 1X2 1X2 1 1 1', $uno13)
    Invoke-Conversione $sch 'Conversione Svezia' | Out-Null
    Close-Messaggio 'msg_troppe.png'
    Assert-DgtTrue (-not (Test-Path (Join-Path $lav 'troppe-E.txt')) -and -not (Test-Path (Join-Path $lav 'troppe-M.txt'))) 'oltre 20.000 colonne: nessun file creato'

    # ---- 5) partita senza segni: rifiutato
    $sch = New-Sch 'vuota.sch' @('1 1 1 1 - 1 1 1 1 1 1 1 1')
    Invoke-Conversione $sch 'Conversione Svezia' | Out-Null
    Close-Messaggio 'msg_vuota.png'
    Assert-DgtTrue (-not (Test-Path (Join-Path $lav 'vuota-E.txt'))) 'partita senza segni: nessun file creato'

    # ---- 6) 951 sistemini + 1 singola: supera MaxRigheM=950
    $cols = @($uno13) + @(1..951 | ForEach-Object { '1X 1 1 1 1 1 1 1 1 1 1 1 1' })
    $sch = New-Sch 'righeM.sch' $cols
    Invoke-Conversione $sch 'Conversione Svezia' | Out-Null
    Close-Messaggio 'msg_righeM.png'
    Assert-DgtTrue (-not (Test-Path (Join-Path $lav 'righeM-M.txt'))) '951 righe M con anche righe E: rifiutato'

    # ---- 7) 951 sistemini da soli: il limite delle righe M vale sempre, rifiutato
    $cols = @(1..951 | ForEach-Object { '1X 1 1 1 1 1 1 1 1 1 1 1 1' })
    $sch = New-Sch 'soloM.sch' $cols
    Invoke-Conversione $sch 'Conversione Svezia' | Out-Null
    Close-Messaggio 'msg_soloM.png'
    Assert-DgtTrue (-not (Test-Path (Join-Path $lav 'soloM-M.txt'))) 'solo sistemini: 951 righe M rifiutate anche senza file E'

    # ---- 8) regressione Quiniela: 14 segni (solo il primo di ogni partita) + 15mo
    $sch = Join-Path $lav 'singole.sch'
    Invoke-Conversione $sch 'Conversione Quiniela' '2 - 1' | Out-Null
    Close-Messaggio ''
    Assert-DgtEqual ((Get-Righe (Join-Path $lav 'singole_QUINIELA.TXT')) -join '|') '1,1,1,1,1,1,1,1,1,1,1,1,1,X,2,1|X,2,1,X,2,1,X,2,1,X,2,1,X,1,2,1' 'contenuto di singole_QUINIELA.TXT'
    Save-DgtScreenshot -Path (Join-Path $lav 'finestra_dopo_quiniela.png') | Out-Null
    Stop-DgtApp

    # ---- 9) limite letto dall'INI alla partenza: MaxRigheM=1, misto (1 E + 2 M) viene rifiutato
    [System.IO.File]::WriteAllText($iniFull, "[Svezia]`r`nMaxRigheE=2200`r`nMaxRigheM=1`r`nMaxColonne=20000`r`nNomeGioco=`r`n")
    Remove-Item (Join-Path $lav 'misto-*.txt')
    Start-DgtApp -Path $exe -WindowClass 'TMain' | Out-Null
    Invoke-Conversione (Join-Path $lav 'misto.sch') 'Conversione Svezia' | Out-Null
    Close-Messaggio 'msg_ini.png'
    Assert-DgtTrue (-not (Test-Path (Join-Path $lav 'misto-M.txt'))) 'MaxRigheM=1 dall''INI: misto rifiutato'
    Stop-DgtApp

    # ---- 10) massimo colonne letto dall'INI: MaxColonne=11, misto ha 12 colonne (1 + 8 + 3) e viene rifiutato
    [System.IO.File]::WriteAllText($iniFull, "[Svezia]`r`nMaxRigheE=2200`r`nMaxRigheM=950`r`nMaxColonne=11`r`nNomeGioco=`r`n")
    Start-DgtApp -Path $exe -WindowClass 'TMain' | Out-Null
    Invoke-Conversione (Join-Path $lav 'misto.sch') 'Conversione Svezia' | Out-Null
    Close-Messaggio 'msg_maxcolonne.png'
    Assert-DgtTrue (-not (Test-Path (Join-Path $lav 'misto-E.txt')) -and -not (Test-Path (Join-Path $lav 'misto-M.txt'))) 'MaxColonne=11 dall''INI: misto (12 colonne) rifiutato'
    Stop-DgtApp

    # ---- 11) INI senza le chiavi MaxColonne e NomeGioco: alla partenza vengono aggiunte con i default
    [System.IO.File]::WriteAllText($iniFull, "[Svezia]`r`nMaxRigheE=2200`r`nMaxRigheM=950`r`n")
    Start-DgtApp -Path $exe -WindowClass 'TMain' | Out-Null
    Assert-DgtTrue ((Get-Content $iniFull) -contains 'MaxColonne=20000') 'chiave MaxColonne mancante: aggiunta con 20000'
    Assert-DgtTrue ((Get-Content $iniFull) -contains 'NomeGioco=') 'chiave NomeGioco mancante: aggiunta vuota'
    Stop-DgtApp

    # ---- 12) NomeGioco=Stryktipset nell'INI: diventa la prima riga di entrambi i file
    [System.IO.File]::WriteAllText($iniFull, "[Svezia]`r`nMaxRigheE=2200`r`nMaxRigheM=950`r`nMaxColonne=20000`r`nNomeGioco=Stryktipset`r`n")
    Start-DgtApp -Path $exe -WindowClass 'TMain' | Out-Null
    Invoke-Conversione (Join-Path $lav 'misto.sch') 'Conversione Svezia' | Out-Null
    Close-Messaggio ''
    Assert-DgtEqual ((Get-Righe (Join-Path $lav 'misto-E.txt')) -join '|') 'Stryktipset|E,1,X,2,1,X,2,1,X,2,1,X,2,1' 'NomeGioco dall''INI: intestazione in misto-E.txt'
    Assert-DgtEqual ((Get-Righe (Join-Path $lav 'misto-M.txt')) -join '|') 'Stryktipset|M8,1X,X2,12,1,1,1,1,1,1,1,1,1,1|M3,1X2,1,1,1,1,1,1,1,1,1,1,1,1' 'NomeGioco dall''INI: intestazione in misto-M.txt'
    Stop-DgtApp

    # ---- 13) gioco normale (non di gruppo): MaxRigheM=1000 nell'INI, i 951 sistemini passano
    [System.IO.File]::WriteAllText($iniFull, "[Svezia]`r`nMaxRigheE=10000`r`nMaxRigheM=1000`r`nMaxColonne=20000`r`nNomeGioco=`r`n")
    Start-DgtApp -Path $exe -WindowClass 'TMain' | Out-Null
    Invoke-Conversione (Join-Path $lav 'soloM.sch') 'Conversione Svezia' | Out-Null
    Close-Messaggio ''
    Assert-DgtEqual ((Get-Righe (Join-Path $lav 'soloM-M.txt')).Count) 951 'MaxRigheM=1000 dall''INI: 951 sistemini convertiti'
}
catch { Assert-DgtTrue $false ('errore: ' + $_.Exception.Message) }
finally {
    Stop-DgtApp
    Restore-DgtFiles
    Write-DgtStep ('file e screenshot della prova in ' + $lav)
    $esito = Complete-DgtTest
}
exit $esito
