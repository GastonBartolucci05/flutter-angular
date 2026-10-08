# Prueba técnica: Desarrollador Jr Flutter (Riverpod) + Angular

Repositorio con las dos aplicaciones de la prueba y las respuestas escritas.

```
.
├── flutter_app/     # Mini Catálogo (Flutter + Riverpod)
├── angular_app/     # Panel de pedidos (Angular)
├── RESPUESTAS.md    # Partes 1 y 4 (preguntas conceptuales y code review)
└── .github/workflows/ci.yml
```

## Cómo ejecutar

### Flutter (`flutter_app/`)

Requisitos: Flutter SDK instalado y un emulador o dispositivo conectado.

```bash
cd flutter_app
flutter pub get
flutter run
```

Análisis estático y tests:

```bash
flutter analyze
flutter test
```

### Angular (`angular_app/`)

Requisitos: Node.js 24.15 o superior (o 22.22.3+), que es lo que pide la CLI actual.

```bash
cd angular_app
npm install
npm start
```

La app queda disponible en `http://localhost:4200`.

Build y tests:

```bash
npm run build
npm test -- --no-watch
```

### Integración continua

Un workflow de GitHub Actions (`.github/workflows/ci.yml`) corre `flutter analyze` y `flutter test` para Flutter, y `npm run build` y `npm test` para Angular, en cada push.

## Flutter: Mini Catálogo

Consume la API de DummyJSON Products.

**Qué incluye:**
- Listado de productos con imagen, título, precio y rating, con estados de carga, error (con botón de reintentar) y lista vacía.
- Búsqueda por texto con debounce de 400 ms.
- Pantalla de detalle cargada con un provider `family`.
- Carrito local: agregar, quitar y cambiar cantidad, con el total y un contador en el AppBar visible desde las pantallas de lista y detalle.
- Tests: pruebas unitarias del carrito (`CartNotifier` y el total) y un test de widget de `ProductsScreen` con un repositorio falso.
- `flutter analyze` sin warnings, con `flutter_lints`.

### Decisiones de arquitectura

**Capas por feature.** Sigo la estructura sugerida:

```
lib/
├── core/                      # cliente HTTP (dio), widgets compartidos
└── features/
    ├── products/
    │   ├── data/              # DTO y implementación del repositorio
    │   ├── domain/            # entidad Product y contrato del repositorio
    │   └── presentation/      # pantallas, widgets, notifiers y providers
    └── cart/
        ├── domain/            # CartItem
        └── presentation/      # CartNotifier, pantalla y widgets del carrito
```

**La UI nunca habla con `dio`.** Las pantallas leen providers; los providers usan un `ProductsRepository` (clase abstracta), y la implementación con `dio` se expone con `productsRepositoryProvider`. Así el repositorio se puede reemplazar con un `override` en los tests, sin internet.

**Entidad y DTO separados.** `Product` (dominio) no sabe nada de JSON. `ProductDto` conoce el formato de la API y lo convierte con `toDomain()`. Si la API cambia, solo se toca el DTO.

**`fromJson` manual en lugar de `freezed` o `json_serializable`.** Son pocos modelos y con campos simples, así que `final` + constructor `const` alcanza para la inmutabilidad sin sumar `build_runner` ni dependencias de generación de código. Prioricé entender cada línea.

**Riverpod 100 % para el estado de negocio.**
- `AsyncNotifier` (`ProductsNotifier`) para el listado: observa el texto de búsqueda y, si hay uno, espera 400 ms antes de pedir los datos. Si el usuario sigue escribiendo, `ref.onDispose` marca la ejecución anterior como cancelada y no se hace la petición.
- `Notifier` (`CartNotifier`) para el carrito, con estado inmutable: cada operación asigna una lista nueva, nunca muta la existente.
- Providers derivados (`cartTotalProvider`, `cartCountProvider`) para el total y el contador, así ningún widget calcula lógica de negocio.
- `FutureProvider.autoDispose.family` para el detalle: un estado por `id`, que se descarta al salir de la pantalla.
- `ref.watch` solo en `build()` y `ref.read` solo en callbacks.

**Widgets pequeños.** `ProductTile`, `CartItemTile`, `SearchField`, `ErrorView`, etc. son clases propias con constructor `const` y sin lógica de negocio: reciben datos y callbacks.

**Nombres.** Clases, variables y archivos en inglés, de forma consistente en todo el proyecto.

## Angular: Panel de pedidos

Consume `https://dummyjson.com/carts` y lo muestra como un panel de pedidos. Creado con la CLI de Angular 22, componentes standalone y TypeScript en modo `strict`.

**Qué incluye:**
- `OrdersService` (`providedIn: 'root'`) que usa `HttpClient` y devuelve datos tipados con interfaces (`Order`, `OrderProduct`, `OrdersResponse`). Ningún componente llama a `HttpClient` directamente.
- `OrdersPageComponent` (contenedor) y `OrderCardComponent` (presentacional, con `input()` y `output()`).
- Filtro reactivo por total mínimo con un `FormControl`, convertido a `signal` y combinado con `computed`.
- Estados de carga y error.
- Sin fugas de memoria: no hay ningún `subscribe()` manual; uso `toSignal`.
- Tests: servicio con `HttpTestingController`, `OrderCardComponent` y el pipe propio.

**Deseables incluidos:**
- Ruta de detalle `/orders/:id` con lazy loading (`loadComponent`) y `withComponentInputBinding`.
- Signals (`signal`, `computed`) para el estado.
- Nuevo control flow (`@if`, `@for` con `track`).
- Un pipe propio (`productsLabel`, que pasa de un número a "1 producto" o "N productos").
- `ChangeDetectionStrategy.OnPush` en el componente presentacional.

### Paralelos con Flutter

| Flutter | Angular |
|---|---|
| `ProductsRepositoryImpl` (repositorio) | `OrdersService` (servicio) |
| Provider / `AsyncNotifier` de Riverpod | `signal` / `Observable` |
| `AsyncValue.when(...)` | Tipo de estado (`loading`, `error`, `success`) con `@if` |
| Widget sin estado que recibe datos y callbacks | `OrderCardComponent` con `input()` y `output()` |
| `ref.watch(productsRepositoryProvider)` | `inject(OrdersService)` |
| `ProviderScope(overrides: [...])` en tests | `HttpTestingController` en tests |
| `ListView.builder` | `@for (... ; track ...)` |

## Qué quedó pendiente

De los **deseables de Flutter** no llegué a implementar:
- Paginación infinita en el listado.
- Filtro por categoría combinable con la búsqueda.
- Persistencia del carrito (`shared_preferences` o `hive`).
- Navegación declarativa con `go_router`.
- Manejo de errores tipado (`Failure` o `Result`).
- Tema claro/oscuro controlado por un provider.

Tampoco hice la generación de código con `riverpod_generator` ni la prueba de integración del flujo "buscar → ver detalle → agregar al carrito". Preferí cerrar bien los requisitos obligatorios antes que sumar funcionalidades a medias.

## Qué mejoraría con más tiempo

- Implementar la paginación infinita y el filtro por categoría, que son las mejoras de más valor para el usuario.
- Reemplazar las excepciones crudas por un tipo de error propio (`Failure`), para que la UI muestre mensajes distintos según la causa (sin conexión, error del servidor, etc.).
- Persistir el carrito para que sobreviva al cierre de la app.
- Sumar un test de widget para el estado de error y un test de integración del flujo principal.
- En Angular, agregar tests de la ruta de detalle y del filtro, y paginar el listado de pedidos.
- Unificar los textos de la interfaz en un solo lugar (archivo de constantes o internacionalización).

## Uso de herramientas de IA

Usé un asistente de IA como guía y para revisar mi código, tal como permite la prueba. Puedo explicar cada parte del código en la entrevista de seguimiento.