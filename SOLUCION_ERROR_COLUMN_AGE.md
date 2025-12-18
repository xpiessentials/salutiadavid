# ?? SOLUCIÓN: Error "Invalid name for column Age"

## ? El Problema
Al intentar guardar el test psicosomático, aparece el error:
```
Invalid name for column Age
```

Esto significa que **la columna `Age` no existe en la tabla `TestMatrices`** de la base de datos, aunque el código C# espera que exista.

---

## ? Solución Rápida

### **Opción 1: Usar PowerShell (RECOMENDADO)**

1. Abrir PowerShell en la raíz del proyecto
2. Ejecutar:
```powershell
.\verificar-y-corregir-age.ps1
```

Este script:
- ? Verifica si la columna `Age` existe
- ? Si no existe, la crea automáticamente
- ? Si existe pero está mal configurada, la corrige
- ? Muestra el estado de la columna

---

### **Opción 2: Usar SQL Server Management Studio (SSMS)**

1. Abrir **SQL Server Management Studio**
2. Conectarse a: `LAPTOP-DAVID\SQLEXPRESS`
3. Abrir el archivo: `Salutia Wep App\Data\Migrations\FixAgeColumn.sql`
4. Ejecutar el script (F5)

---

### **Opción 3: Usar sqlcmd desde CMD**

1. Abrir **CMD** o PowerShell en la raíz del proyecto
2. Ejecutar:
```cmd
sqlcmd -S LAPTOP-DAVID\SQLEXPRESS -d Salutia -E -i "Salutia Wep App\Data\Migrations\FixAgeColumn.sql"
```

---

## ?? Verificar la Solución

Después de aplicar cualquiera de las opciones anteriores, ejecutar este comando SQL para confirmar:

```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'TestMatrices' AND COLUMN_NAME = 'Age';
```

**Resultado esperado:**
```
COLUMN_NAME    DATA_TYPE    CHARACTER_MAXIMUM_LENGTH    IS_NULLABLE
Age            nvarchar     50                          NO
```

---

## ?? Probar la Aplicación

Una vez corregida la columna:

1. Ejecutar la aplicación:
```powershell
dotnet run --project ".\Salutia Wep App\Salutia Wep App.csproj"
```

2. Abrir el navegador en **modo incógnito** (ya sabemos que funciona ahí)

3. Navegar a la ruta del test psicosomático

4. Completar el test y guardarlo

---

## ?? ¿Por qué pasó esto?

El script de actualización `UpdatePsychosomaticTestAddAge.sql` debió crear:

1. ? La tabla `TestAges` - **Creada correctamente**
2. ? La columna `Age` en `TestMatrices` - **No se creó o falló**

El script tiene verificaciones `IF NOT EXISTS`, pero si hay un error de sintaxis o permisos, puede que no se haya ejecutado correctamente.

---

## ?? Estructura Correcta de TestMatrices

Después de la corrección, la tabla `TestMatrices` debe tener estas columnas:

| Columna | Tipo | Tamaño | Permite NULL |
|---------|------|--------|--------------|
| Id | int | - | NO |
| PsychosomaticTestId | int | - | NO |
| WordNumber | int | - | NO |
| Word | nvarchar | 100 | NO |
| Phrase | nvarchar | 500 | NO |
| Emotion | nvarchar | 100 | NO |
| DiscomfortLevel | int | - | NO |
| **Age** | **nvarchar** | **50** | **NO** |
| BodyPart | nvarchar | 100 | NO |
| AssociatedPerson | nvarchar | 200 | NO |
| CreatedAt | datetime2 | - | NO |

---

## ?? Si el Problema Persiste

1. **Verificar que el script se ejecutó:**
   ```powershell
   .\verificar-y-corregir-age.ps1
   ```

2. **Ver los errores en la base de datos:**
   - Abrir SSMS
   - Conectarse a `LAPTOP-DAVID\SQLEXPRESS`
   - Ver los logs de SQL Server

3. **Limpiar y reconstruir:**
   ```powershell
   dotnet clean
   dotnet build
   ```

4. **Reiniciar SQL Server:**
   - Abrir **Servicios de Windows**
   - Buscar `SQL Server (SQLEXPRESS)`
   - Clic derecho ? Reiniciar

---

## ? Resumen

1. Ejecutar: `.\verificar-y-corregir-age.ps1`
2. Confirmar que la columna `Age` existe
3. Ejecutar la aplicación
4. Probar el test en modo incógnito

El script automáticamente detecta y corrige el problema.
