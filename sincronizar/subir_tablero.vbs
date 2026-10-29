' Lanza subir_tablero.ps1 sin abrir ventana (lo usa la tarea programada DataGoal\SubirTablero)
CreateObject("WScript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""C:\Users\joser\KANBAN-SEGUIMIIENTO-LANZAMIENTOS-DATA-GOAL-\sincronizar\subir_tablero.ps1""", 0, True
