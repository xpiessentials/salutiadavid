# ?? SOLUCIÓN AL ERROR DE MIGRACIÓN

## ? El Error que Tienes

```
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Login failed for user 'LAPTOP-DAVID\elpec'..
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Cannot open database "Salutia" requested by the login. The login failed..
```

## ? LA SOLUCIÓN (3 opciones)

---

### ?? OPCIÓN 1: Ejecutar el Script Definitivo (RECOMENDADO)

Este script soluciona todos los problemas automáticamente:

```powershell
.\EJECUTAR_ESTO.ps1
```

**Lo que hace:**
- ? Inicia LocalDB si no está corriendo
- ? Crea la base de datos `Salutia` si no existe
- ? Verifica que el script SQL existe
- ? Ejecuta la migración
- ? Verifica que las tablas se crearon correctamente

---

### ?? OPCIÓN 2: Script Simple Alternativo

Si el anterior da problemas:

```powershell
.\simple-migration.ps1
```

---

### ?? OPCIÓN 3: Pasos Manuales (Si los scripts no funcionan)

#### Paso 1: Abrir PowerShell como Administrador

Clic derecho en PowerShell ? "Ejecutar como administrador"

#### Paso 2: Navegar al proyecto

```powershell
cd D:\Desarrollos\Repos\Salutia\
```

#### Paso 3: Iniciar LocalDB

```powershell
sqllocaldb start MSSQLLocalDB
```

#### Paso 4: Crear la Base de Datos

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -Q "CREATE DATABASE Salutia"
```

#### Paso 5: Ejecutar la Migración

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -E -i ".\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"
```

#### Paso 6: Verificar

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -E -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'Test%' OR TABLE_NAME = 'PsychosomaticTests'"
```

**Deberías ver:**
```
PsychosomaticTests
TestAssociatedPersons
TestBodyParts
TestDiscomfortLevels
TestEmotions
TestMatrices
TestPhrases
TestWords
```

---

## ?? Si Sigue Sin Funcionar

### Problema: LocalDB no responde

```powershell
# Detener
sqllocaldb stop MSSQLLocalDB

# Eliminar (si está corrupto)
sqllocaldb delete MSSQLLocalDB

# Crear nueva instancia
sqllocaldb create MSSQLLocalDB

# Iniciar
sqllocaldb start MSSQLLocalDB
```

### Problema: No tienes sqlcmd instalado

Descarga e instala: [SQL Server Command Line Utilities](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility)

O usa SQL Server Management Studio (SSMS):
1. Descarga: [SSMS Download](https://aka.ms/ssmsfullsetup)
2. Conecta a: `(localdb)\MSSQLLocalDB`
3. Ejecuta el script manualmente

---

## ?? ¿Qué Archivos Ejecutar?

| Archivo | Cuándo Usarlo | Descripción |
|---------|--------------|-------------|
| `EJECUTAR_ESTO.ps1` | ? **PRIMERO** | Script completo y robusto |
| `simple-migration.ps1` | Si el anterior falla | Versión simplificada |
| `fix-and-apply-migration.ps1` | Alternativa | Otra opción con más verificaciones |
| Pasos manuales | Último recurso | Si los scripts no funcionan |

---

## ? Una Vez que Funcione

```powershell
# Compilar
dotnet build

# Ejecutar
dotnet run --project ".\Salutia Wep App\Salutia Wep App.csproj"
```

Navegar a: `https://localhost:[puerto]/test-psicosomatico`

---

## ?? Archivos de Ayuda

- **TROUBLESHOOTING_MIGRATION.md** - Guía completa de solución de problemas
- **PSYCHOSOMATIC_TEST_QUICKSTART.md** - Guía rápida del test
- **TEST_PSYCHOSOMATIC_COMPLETE.md** - Documentación completa

---

## ?? RESUMEN: ¿Qué Hacer AHORA?

### OPCIÓN A: Ejecutar Script (5 segundos)

```powershell
.\EJECUTAR_ESTO.ps1
```

### OPCIÓN B: Pasos Manuales (2 minutos)

```powershell
# 1. Iniciar LocalDB
sqllocaldb start MSSQLLocalDB

# 2. Crear BD
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -Q "CREATE DATABASE Salutia"

# 3. Ejecutar migración
sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -E -i ".\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"
```

---

**Una vez que veas el mensaje de éxito, ¡estás listo!** ??
