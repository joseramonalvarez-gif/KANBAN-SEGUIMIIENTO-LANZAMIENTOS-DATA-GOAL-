# Sube a GitHub el tablero que se edita en la unidad compartida (D-023).
# Lo lanza cada 15 minutos la tarea programada "DataGoal\SubirTablero" en el PC de JR.
# Fuente de verdad: H:\...\01_EMPRESA\Estrategia\TABLERO_DATA_GOAL.html
# Si el fichero ha cambiado, lo copia como index.html, hace commit y push.
# Si el repositorio va por delante de GitHub (un push anterior falló), reintenta el push.

$fuente = 'H:\Unidades compartidas\Data Goal\01_EMPRESA\Estrategia\TABLERO_DATA_GOAL.html'
$repo   = 'C:\Users\joser\KANBAN-SEGUIMIIENTO-LANZAMIENTOS-DATA-GOAL-'
$destino = Join-Path $repo 'index.html'
$dirLog = Join-Path $env:LOCALAPPDATA 'DataGoal'
$log    = Join-Path $dirLog 'subida_tablero.log'
if (-not (Test-Path $dirLog)) { New-Item -ItemType Directory -Path $dirLog | Out-Null }
function Anota($m) { Add-Content -Path $log -Value ("{0:yyyy-MM-dd HH:mm:ss}  {1}" -f (Get-Date), $m) -Encoding UTF8 }

if (-not (Test-Path $fuente)) { Anota 'No encuentro el fichero en la unidad compartida (¿Drive sin montar?).'; exit 0 }

$texto = [IO.File]::ReadAllText($fuente, [Text.Encoding]::UTF8)
# Defensa contra copias a medio sincronizar por Drive
if ($texto.Length -lt 150000 -or $texto -notmatch '<script id="datos"' -or $texto.TrimEnd() -notmatch '</html>$') {
  Anota ('Fichero incompleto o raro ({0} caracteres). Espero a la siguiente vuelta.' -f $texto.Length); exit 0
}

Set-Location $repo
$cambio = (Get-FileHash $fuente).Hash -ne (Get-FileHash $destino).Hash
if ($cambio) {
  $pub = [regex]::Match($texto, '"pub":\s*"([^"]+)"').Groups[1].Value
  Copy-Item $fuente $destino -Force
  git add index.html 2>&1 | Out-Null
  $c = git commit -m ("Tablero: guardado en la unidad compartida (pub {0})" -f $pub) 2>&1 | Out-String
  Anota ('Commit: ' + ($c -split "`n")[0])
}

git fetch origin main 2>&1 | Out-Null
$delante = (git rev-list --count origin/main..HEAD 2>$null)
if ([int]$delante -gt 0) {
  $p = git push origin main 2>&1 | Out-String
  if ($LASTEXITCODE -eq 0) { Anota ("Push hecho ({0} commit)." -f $delante) } else { Anota ('Push FALLIDO: ' + $p.Trim()) }
}
