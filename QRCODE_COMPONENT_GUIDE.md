# Componente QrCodeDisplay - Guía de Uso

## Descripción

`QrCodeDisplay` es un componente Blazor reutilizable que facilita la generación y visualización de códigos QR en cualquier parte de la aplicación Salutia.

## Ubicación

```
Salutia Wep App\Components\Shared\QrCodeDisplay.razor
```

## Importar el Componente

Asegúrate de tener la importación en tu archivo `_Imports.razor`:

```razor
@using Salutia_Wep_App.Components.Shared
```

## Uso Básico

### Ejemplo 1: Código QR Simple

```razor
<QrCodeDisplay Text="https://salutia.com" />
```

### Ejemplo 2: Con Título y Descripción

```razor
<QrCodeDisplay 
    Text="https://salutia.com/verify?token=abc123"
    Title="Escanea este código para verificar tu cuenta"
    Description="Este código QR expira en 15 minutos"
    AltText="Código QR de verificación" />
```

### Ejemplo 3: QR Personalizado

```razor
<QrCodeDisplay 
    Text="@qrContent"
    PixelsPerModule="15"
  MaxWidth="400"
    Title="Comparte este código"
    CssClass="my-4 p-3 border rounded shadow"
    ImageCssClass="border border-primary"
    ShowError="true" />
```

### Ejemplo 4: QR para WiFi

```razor
@code {
    private string wifiQrCode = "WIFI:T:WPA;S:SalutiaGuest;P:Password123;;";
}

<QrCodeDisplay 
    Text="@wifiQrCode"
    Title="Conectarse a la red WiFi"
    Description="Escanea con la cámara de tu teléfono"
MaxWidth="250" />
```

### Ejemplo 5: QR para vCard (Tarjeta de Contacto)

```razor
@code {
    private string GetVCardQr()
    {
        return @"BEGIN:VCARD
VERSION:3.0
FN:Dr. Juan Pérez
TEL:+34-123-456-789
EMAIL:juan.perez@salutia.com
ORG:Salutia Clinic
END:VCARD";
    }
}

<QrCodeDisplay 
    Text="@GetVCardQr()"
    Title="Guardar contacto"
    PixelsPerModule="12"
    MaxWidth="300" />
```

## Parámetros

| Parámetro | Tipo | Requerido | Valor por Defecto | Descripción |
|-----------|------|-----------|-------------------|-------------|
| `Text` | `string` | ? Sí | - | Texto o URI a codificar en el QR |
| `PixelsPerModule` | `int` | No | `10` | Tamaño de los módulos del QR en píxeles |
| `MaxWidth` | `int` | No | `300` | Ancho máximo del código QR en píxeles |
| `Title` | `string?` | No | `null` | Título opcional encima del QR |
| `Description` | `string?` | No | `null` | Descripción opcional debajo del QR |
| `AltText` | `string` | No | `"Código QR"` | Texto alternativo para accesibilidad |
| `CssClass` | `string` | No | `""` | Clases CSS adicionales para el contenedor |
| `ImageCssClass` | `string` | No | `""` | Clases CSS adicionales para la imagen |
| `ShowError` | `bool` | No | `true` | Mostrar mensaje de error si falla |
| `ErrorMessage` | `string` | No | Mensaje por defecto | Mensaje de error personalizado |

## Ejemplos de Uso Avanzado

### En un Formulario de Pago

```razor
@page "/payment/{orderId}"

<h3>Pagar Orden #@orderId</h3>

@if (!string.IsNullOrEmpty(paymentQr))
{
    <div class="card">
        <div class="card-body">
  <QrCodeDisplay 
    Text="@paymentQr"
     Title="Escanea para pagar"
 Description="Total: $@totalAmount"
  PixelsPerModule="12"
       MaxWidth="350"
 CssClass="payment-qr"
       AltText="Código QR de pago" />
        </div>
    </div>
}

@code {
    [Parameter]
    public string OrderId { get; set; } = string.Empty;
    
    private string? paymentQr;
    private decimal totalAmount;

  protected override async Task OnInitializedAsync()
    {
 // Generar link de pago
      paymentQr = $"https://salutia.com/pay?order={OrderId}&amount={totalAmount}";
        totalAmount = 99.99m;
    }
}
```

### En una Página de Compartir Perfil

```razor
@page "/profile/share"

<h3>Compartir mi Perfil Médico</h3>

<QrCodeDisplay 
    Text="@GetProfileShareUrl()"
    Title="Escanea para ver mi perfil"
    Description="Válido por 7 días"
    PixelsPerModule="15"
    MaxWidth="400"
    CssClass="mb-4" />

<button class="btn btn-primary" @onclick="GenerateNewQr">
    <i class="bi bi-arrow-clockwise"></i> Generar Nuevo Código
</button>

@code {
    private string shareToken = Guid.NewGuid().ToString();

    private string GetProfileShareUrl()
    {
     return $"https://salutia.com/profile/view?token={shareToken}";
    }

    private void GenerateNewQr()
    {
        shareToken = Guid.NewGuid().ToString();
    }
}
```

### Con Descarga de Imagen

```razor
<QrCodeDisplay 
    @ref="qrDisplay"
    Text="@qrContent"
    Title="Tu código de acceso"
    MaxWidth="350" />

<button class="btn btn-secondary mt-3" @onclick="DownloadQr">
    <i class="bi bi-download"></i> Descargar QR
</button>

@code {
    private QrCodeDisplay? qrDisplay;
    private string qrContent = "https://salutia.com/access";

    private void DownloadQr()
    {
        // Nota: Para implementar descarga real, necesitarías JavaScript interop
        // Este es un ejemplo conceptual
        Console.WriteLine("Descargando QR...");
    }
}
```

## Personalización con CSS

### Ejemplo de Estilos Personalizados

```css
/* En tu archivo CSS */

/* Contenedor del QR con sombra */
.qr-code-container {
    background: white;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

/* QR con borde */
.qr-with-border {
    border: 3px solid #1b6ec2;
    border-radius: 8px;
    padding: 10px;
}

/* QR para imprimir */
@media print {
    .qr-code-container {
     page-break-inside: avoid;
    }
}

/* Animación de aparición */
.qr-fade-in {
    animation: fadeIn 0.5s ease-in;
}

@keyframes fadeIn {
    from {
  opacity: 0;
        transform: scale(0.9);
    }
  to {
        opacity: 1;
        transform: scale(1);
    }
}
```

### Uso con Clases Personalizadas

```razor
<QrCodeDisplay 
 Text="@content"
    CssClass="qr-fade-in shadow-lg"
    ImageCssClass="qr-with-border"
    Title="Código de Verificación" />
```

## Manejo de Errores

El componente maneja automáticamente los errores de generación:

```razor
<!-- Si Text está vacío o la generación falla -->
<QrCodeDisplay 
    Text="@maybeEmptyText"
    ShowError="true"
    ErrorMessage="Por favor, genera un código válido primero." />
```

Para ocultar el mensaje de error:

```razor
<QrCodeDisplay 
    Text="@content"
ShowError="false" />
```

## Casos de Uso Comunes

### 1. URL de Verificación de Email

```razor
<QrCodeDisplay 
    Text="https://salutia.com/verify-email?token=@emailToken"
    Title="Verifica tu email"
    Description="Escanea o haz clic en el enlace del correo" />
```

### 2. Código de Cita Médica

```razor
<QrCodeDisplay 
    Text="APPT:@appointmentId|@patientId|@DateTime.Now.ToString("yyyyMMddHHmm")"
    Title="Tu Cita - @appointmentDate.ToString("d")"
    Description="Muestra este código en recepción"
    PixelsPerModule="12" />
```

### 3. Link de Descarga de Aplicación

```razor
<QrCodeDisplay 
    Text="https://salutia.com/app/download"
    Title="Descarga la App Móvil"
    Description="Disponible para iOS y Android"
    MaxWidth="250" />
```

### 4. Información de Medicamento

```razor
<QrCodeDisplay 
    Text="MED:@medicationCode|DOSE:@dosage|FREQ:@frequency"
    Title="Información del Medicamento"
    Description="Escanea para ver instrucciones completas" />
```

## Integración con Servicios Externos

### Con API de Pagos

```csharp
// Generar QR para MercadoPago, PayPal, etc.
var paymentData = new
{
    merchant_id = "12345",
    amount = 100.00,
    currency = "USD",
    order_id = orderId
};

var qrText = JsonSerializer.Serialize(paymentData);
```

```razor
<QrCodeDisplay 
    Text="@qrText"
    Title="Pagar con QR"
    PixelsPerModule="15" />
```

## Accesibilidad

El componente incluye soporte para accesibilidad:

- ? Atributo `alt` configurable
- ? Estructura semántica HTML
- ? Compatible con lectores de pantalla
- ? Textos descriptivos opcionales

```razor
<QrCodeDisplay 
    Text="@content"
    AltText="Código QR para acceder a tu historial médico"
    Title="Historial Médico"
    Description="Escanea este código para acceder de forma segura" />
```

## Rendimiento

- El componente genera el QR **solo cuando cambian los parámetros**
- Usa `OnParametersSet` para regeneración eficiente
- Imágenes en formato Base64 (sin archivos adicionales)
- Carga sincrónica (sin awaits innecesarios)

## Troubleshooting

### El QR no se muestra

**Verificar**:
1. ¿El parámetro `Text` tiene valor?
2. ¿El servicio `QrCodeService` está registrado en `Program.cs`?
3. ¿Hay errores en el log?

### QR muy pixelado

**Solución**: Aumentar `PixelsPerModule`

```razor
<QrCodeDisplay Text="@content" PixelsPerModule="20" />
```

### QR demasiado grande

**Solución**: Reducir `MaxWidth` o `PixelsPerModule`

```razor
<QrCodeDisplay 
 Text="@content" 
    PixelsPerModule="8"
    MaxWidth="200" />
```

## Recursos Adicionales

- [Especificación QR Code](https://www.qrcode.com/en/about/standards.html)
- [QRCoder GitHub](https://github.com/codebude/QRCoder)
- [TWO_FACTOR_AUTH_QR.md](TWO_FACTOR_AUTH_QR.md) - Guía completa de 2FA

---

**Última actualización**: 2025  
**Componente versión**: 1.0
