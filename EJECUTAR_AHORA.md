# ?? EJECUTAR AHORA - Test Psicosomático

## ?? Instrucción Inmediata

### Paso 1: Abrir PowerShell en la raíz del proyecto

```
Ubicación actual: D:\Desarrollos\Repos\Salutia\
```

### Paso 2: Ejecutar el script de migración

```powershell
.\apply-psychosomatic-test-migration.ps1
```

### Paso 3: Confirmar con "S"

Cuando veas esto:

```
¿Desea aplicar la migración del Test Psicosomático?
Esto creará las siguientes tablas:
  - PsychosomaticTests
  - TestWords
  - TestPhrases
  - TestEmotions
  - TestDiscomfortLevels
  - TestBodyParts
  - TestAssociatedPersons
  - TestMatrices

Continuar? (S/N)
```

**Escribe: S** y presiona Enter

---

## ? Verificación

Si todo salió bien, verás:

```
========================================
? Migración aplicada exitosamente
========================================

Las tablas del Test Psicosomático han sido creadas.

Próximos pasos:
1. Compile el proyecto: dotnet build
2. Ejecute la aplicación: dotnet run --project '.\Salutia Wep App\Salutia Wep App.csproj'
3. Navegue a: /test-psicosomatico
```

---

## ?? Acceso Rápido

### Para Pacientes
```
https://localhost:[puerto]/test-psicosomatico
```

### Para Profesionales
```
https://localhost:[puerto]/patient-tests
```

---

## ?? Verificar en Base de Datos

Abre SQL Server Management Studio o ejecuta:

```sql
USE Salutia;
GO

-- Verificar que las tablas existen
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE 'Test%' OR TABLE_NAME = 'PsychosomaticTests'
ORDER BY TABLE_NAME;
```

Deberías ver:

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

## ?? Si hay Error

### Error: "Script SQL no encontrado"

**Solución**: Asegúrate de estar en la raíz del proyecto
```powershell
cd D:\Desarrollos\Repos\Salutia\
```

### Error: "No se puede conectar a LocalDB"

**Solución**: Inicia LocalDB
```powershell
sqllocaldb start MSSQLLocalDB
```

### Error: "Base de datos Salutia no existe"

**Solución**: Crea la base de datos primero
```sql
CREATE DATABASE Salutia;
GO
```

---

## ?? Comandos Completos (Copy-Paste)

```powershell
# 1. Ir a la raíz del proyecto
cd D:\Desarrollos\Repos\Salutia\

# 2. Ejecutar migración
.\apply-psychosomatic-test-migration.ps1

# 3. Compilar
dotnet build

# 4. Ejecutar
dotnet run --project "Salutia Wep App\Salutia Wep App.csproj"
```

---

## ?? ¡Listo!

Una vez ejecutada la migración, el Test Psicosomático estará **100% funcional**.

**Archivos Creados:**
- ? 8 tablas en base de datos
- ? 3 páginas web funcionales
- ? 1 servicio backend completo
- ? Documentación completa

**Tiempo estimado:** 2 minutos

---

**?? EJECUTA AHORA: `.\apply-psychosomatic-test-migration.ps1`**
