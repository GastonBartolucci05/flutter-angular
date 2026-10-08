# Respuestas

## Parte 1 - Preguntas conceptuales

### Dart y Flutter

**1. ¿Qué diferencia hay entre `final` y `const` en Dart? ¿Por qué importa usar `const` en constructores de widgets?**

`final` significa que una variable solo puede asignarse una vez, pero su valor puede conocerse durante la ejecución del programa, por ejemplo `final fecha = DateTime.now();`.
`const` es un valor constante en tiempo de compilación: se conoce antes de ejecutar el programa y nunca cambia, por ejemplo `const SizedBox(height: 12);`.
Importa usar `const` en los constructores de widgets porque Flutter reutiliza la misma instancia y puede saltarse la reconstrucción de ese widget cuando el padre se redibuja. Así se hace menos trabajo y se usa menos memoria.

**2. Explica el null safety de Dart. ¿Cuándo usarías `?`, `!`, `??` y `late`? ¿Por qué abusar de `!` es una mala práctica?**

El null safety evita errores por acceder a valores que podrían ser `null`: una variable no puede contener `null` a menos que se indique explícitamente con `?`.
- `?` se usa cuando una variable puede ser `null` (`String? apodo`). Con `?.` se accede a sus miembros solo si no es `null`.
- `!` se usa cuando se está seguro de que el valor no es `null` y se lo indicamos a Dart.
- `??` da un valor alternativo cuando algo es `null` (`apodo ?? 'Sin apodo'`).
- `late` es para variables que se inicializan antes de usarse pero no al declararlas, por ejemplo `late ProviderContainer container;` que se asigna en el `setUp` de un test.

Abusar de `!` es mala práctica porque fuerza a Dart a asumir que el valor no es `null`, y si la suposición es incorrecta el error aparece en tiempo de ejecución en lugar de en compilación. En mi repositorio tenía `Dio? _dio` con `_dio!` en cada llamada, cuando alcanzaba con `final Dio _dio`.

**3. ¿Cuál es la diferencia entre `StatelessWidget` y `StatefulWidget`? ¿Qué aportan `ConsumerWidget` y `ConsumerStatefulWidget`?**

`StatelessWidget` se usa cuando el widget no necesita mantener un estado interno que cambie: su interfaz depende de los datos que recibe.
`StatefulWidget` se usa cuando el widget necesita mantener y modificar estado durante su ciclo de vida. Tiene una clase `State` asociada, donde se guarda el estado y se usa `setState()` para reconstruirlo.
`ConsumerWidget` es como un `StatelessWidget`, pero recibe un `ref` en `build()` para leer o escuchar providers. `ConsumerStatefulWidget` es como un `StatefulWidget` con acceso a Riverpod: su `State` puede usar `ref`.

**4. ¿Qué es un `Future` y qué es un `Stream`? Da un caso de uso real de cada uno.**

Un `Future` es un resultado que estará disponible una sola vez en el futuro, después de una operación asíncrona. Por ejemplo, pedir a la API el detalle de un producto, como hace mi `ProductsRepository`.
Un `Stream` es una secuencia de datos que puede llegar varias veces a lo largo del tiempo y permite escuchar cambios continuamente. Por ejemplo, escuchar en tiempo real una colección de la base de datos.

**5. ¿Por qué es preferible extraer un widget a una clase propia en lugar de un método `_buildAlgo()` que retorna un `Widget`?**

Una clase puede tener constructor `const`, así que Flutter puede saltarse su reconstrucción si sus datos no cambiaron. Un método, en cambio, se vuelve a ejecutar completo cada vez que se reconstruye el widget padre.
Además, una clase tiene su propio `BuildContext` y ciclo de vida, y se puede testear por separado, cosa que un método no permite.
Por eso en mi proyecto `ProductTile` y `ErrorView` son clases propias y no métodos de `ProductsScreen`.

**6. ¿Qué problema resuelve Riverpod frente a `setState` o frente a `Provider` (el paquete)?**

`setState` sirve para manejar estados locales y simples dentro de un `StatefulWidget`, pero se vuelve incómodo cuando el mismo estado debe ser utilizado por varios widgets.
`Provider` permite compartir estado y separar parte de la lógica, pero depende del árbol de widgets y del `BuildContext`.
Riverpod busca resolver estos problemas ofreciendo una gestión de estado más centralizada, segura y separada de la UI. Los providers se declaran fuera del árbol de widgets y se acceden mediante `ref`, lo que además permite reemplazarlos fácilmente en los tests.

**7. Explica la diferencia entre `ref.watch`, `ref.read` y `ref.listen`. ¿Dónde es incorrecto usar `ref.read`?**

- `ref.watch`: escucha un provider y reconstruye el widget cuando su estado cambia. Se usa dentro de `build()`, como `ref.watch(productsProvider)` en mi `ProductsScreen`.
- `ref.read`: obtiene el valor actual de un provider una sola vez, sin escuchar cambios. Se usa en callbacks, como `ref.read(cartProvider.notifier).add(product)` en el `onPressed` de mi botón de agregar al carrito.
- `ref.listen`: escucha los cambios de un provider y ejecuta una acción como consecuencia, sin reconstruir la UI, por ejemplo mostrar un `SnackBar`.

Es incorrecto usar `ref.read` dentro de `build()` para obtener datos que la interfaz necesita mostrar: si el provider cambia después, el widget no reacciona. No se puede usar `read` en reemplazo de `watch`.

**8. ¿Cuándo usarías un `Provider`, un `FutureProvider`, un `Notifier` y un `AsyncNotifier`?**

- `Provider`: cuando necesito exponer un valor o una dependencia que no cambia por sí misma. En mi proyecto, `productsRepositoryProvider` y `dioProvider`.
- `FutureProvider`: cuando necesito obtener datos de forma asíncrona y el resultado viene de un `Future`. En mi proyecto, `productDetailProvider`.
- `Notifier`: cuando tengo estado síncrono que puede cambiar y quiero encapsular la lógica que lo modifica. En mi proyecto, `CartNotifier`.
- `AsyncNotifier`: cuando tengo estado que puede cambiar y además necesito operaciones asíncronas, como llamadas a una API o a Firebase, donde el estado pasa por loading, data y error. En mi proyecto, `ProductsNotifier`, que carga el listado y reacciona a la búsqueda.

**9. ¿Qué hace el modificador `autoDispose` y qué problema evita? ¿Y `family`?**

`autoDispose` hace que Riverpod elimine el estado de un provider cuando ya no tiene listeners, en lugar de mantenerlo en memoria indefinidamente. Evita conservar estado y recursos innecesarios, sobre todo en pantallas que se visitan y se abandonan con frecuencia.
`family` permite crear distintas instancias de un mismo provider según un parámetro, así que no hace falta un provider diferente para cada ID. Es muy útil para detalles de usuarios, productos o documentos.
En mi proyecto, `productDetailProvider` usa los dos: `family` crea un estado por cada `id` de producto, y `autoDispose` lo descarta al salir de la pantalla de detalle.

**10. ¿Cómo manejas los estados de carga, error y datos con `AsyncValue`? Escribe un ejemplo con `.when` o pattern matching.**

`AsyncValue` representa los tres estados principales de una operación asíncrona: `loading` (la operación está en curso), `data` (terminó correctamente y recibimos los datos) y `error` (ocurrió un fallo). Con `.when` resuelvo los tres casos en un solo lugar.

```dart
productsAsync.when(
  data: (products) {
    if (products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles'));
    }
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductTile(
          product: products[index],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                productId: products[index].id,
              ),
            ),
          ),
        );
      },
    );
  },
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, _) => ErrorView(
    message: 'No se pudieron cargar los productos',
    onRetry: () => ref.invalidate(productsProvider),
  ),
),
```

**11. ¿Cómo sobrescribirías un provider en un test para inyectar un repositorio falso?**

Se usa el parámetro `overrides` de `ProviderScope` (en tests de widgets) o de `ProviderContainer` (en tests unitarios). Primero creo una clase falsa que implementa el contrato del repositorio (`ProductsRepository`) y devuelve datos fijos. Después reemplazo el provider real por ese falso.
Esto funciona porque la pantalla depende de la abstracción, no de la implementación con `dio`: no sabe si el repositorio es real o falso. Así el test no necesita internet y es rápido y predecible.

```dart
class FakeProductsRepository implements ProductsRepository {
  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async =>
      [_product];
  // ...los otros métodos del contrato
}

await tester.pumpWidget(
  ProviderScope(
    overrides: [
      productsRepositoryProvider.overrideWithValue(FakeProductsRepository()),
    ],
    child: const MaterialApp(home: ProductsScreen()),
  ),
);
```

### Angular

**12. ¿Qué diferencia hay entre un componente standalone y uno declarado en un `NgModule`?**

Un componente standalone no necesita pertenecer a un `NgModule`: importa directamente los componentes, directivas y pipes que usa mediante `imports`. En uno declarado en un `NgModule`, las dependencias y componentes se gestionan desde el módulo.
Standalone hace más claro qué usa cada componente y permite cargarlo de forma perezosa con `loadComponent`, sin módulos de por medio. En mi proyecto, `OrderCardComponent` declara `imports: [CurrencyPipe, ProductsLabelPipe]` y el detalle del pedido se carga con lazy loading.

**13. Explica la diferencia entre un `Observable` (RxJS) y un `Signal`. ¿Cuándo preferirías cada uno?**

Un `Observable` es un flujo de valores que pueden llegar a lo largo del tiempo. Sirve para operaciones asíncronas, eventos, HTTP, WebSockets y transformaciones mediante operadores como `map`, `filter` o `switchMap`.
Un `Signal` es un valor reactivo: cuando cambia, Angular sabe qué partes de la interfaz dependen de él y las actualiza de forma eficiente.
Preferiría `Signal` para valores reactivos simples y estado de la UI. Preferiría `Observable` para HTTP, WebSockets o eventos, y cuando necesito combinar o transformar flujos complejos.
En mi proyecto, `OrdersService` devuelve un `Observable` y en el componente lo convierto con `toSignal` para usarlo como estado.

**14. ¿Para qué sirven `@Input()` / `input()` y `@Output()` / `output()`? ¿Cómo se comunican dos componentes hermanos?**

`@Input()` / `input()` sirven para que un componente padre le pase datos a un hijo. El Angular moderno permite usar `input()` como alternativa a `@Input()`.
`@Output()` / `output()` sirven para que el hijo notifique al padre que ocurrió un evento, por ejemplo un click en un botón.
En mi proyecto, `OrderCardComponent` recibe `order = input.required<Order>()` y emite `viewDetail = output<number>()`.
Dos componentes hermanos se comunican a través del padre: por ejemplo, si uno permite seleccionar un animal y otro muestra sus detalles, el primero emite el animal al padre, el padre actualiza su variable y se la pasa al segundo mediante `input()`. También pueden compartir un servicio con el estado.

**15. ¿Qué es la inyección de dependencias en Angular y para qué sirve `providedIn: 'root'`?**

La inyección de dependencias es un mecanismo por el cual una clase recibe de Angular los servicios u objetos que necesita, en lugar de crearlos manualmente. Por ejemplo, si un componente necesita un servicio para obtener usuarios, Angular se lo proporciona mediante el constructor o la función `inject()`. Eso desacopla las clases y facilita reemplazar las dependencias en los tests.
`providedIn: 'root'` indica que Angular debe registrar el servicio en el inyector raíz, así que hay una única instancia compartida en toda la aplicación, siempre que no se registre otra en un ámbito más específico.
En mi proyecto, `OrdersPageComponent` hace `inject(OrdersService)` y el servicio hace `inject(HttpClient)`.

**16. ¿Por qué hay que preocuparse por las suscripciones a Observables? Menciona dos formas de evitar fugas de memoria.**

Hay que preocuparse porque algunos `Observable` no finalizan por sí solos y pueden seguir ejecutándose cuando el componente ya no existe, causando fugas de memoria y trabajo innecesario.
Dos formas de evitarlo son el `async` pipe en las plantillas, que gestiona la suscripción automáticamente, y `takeUntilDestroyed()`, que la cancela cuando se destruye el componente. En mi proyecto uso `toSignal`, que también se desuscribe solo, así que no hay ningún `subscribe()` manual.

### Código limpio y buenas prácticas

**17. Explica con tus palabras el principio de responsabilidad única (SRP) y cómo lo aplicarías en una app Flutter.**

El principio de responsabilidad única (SRP) establece que una clase tiene una sola responsabilidad, es decir, un único motivo para cambiar.
En Flutter lo aplico separando la interfaz, la lógica de negocio y el acceso a los datos, en lugar de poner todo junto en un solo widget. En mi proyecto, `ProductTile` solo muestra un producto, `CartNotifier` solo maneja el estado del carrito y `ProductsRepositoryImpl` solo habla con la API.

**18. ¿Por qué separar la app en capas (presentación, dominio, datos)? ¿Qué va en cada una?**

Separar en capas permite organizar el código, reducir el acoplamiento y facilitar el mantenimiento y las pruebas. Así, un cambio en una parte de la aplicación no obliga a modificar todas las demás.
- **Presentación:** las pantallas, los widgets y los providers o notifiers que usa la interfaz. En mi proyecto, `ProductsScreen` y `ProductsNotifier`.
- **Dominio:** las entidades y el contrato del repositorio, es decir, lo que la aplicación debe hacer sin saber cómo. En mi proyecto, `Product` y `ProductsRepository`.
- **Datos:** obtener, guardar y actualizar información: repositorios concretos, DTOs y comunicación con servicios externos. En mi proyecto, `ProductsRepositoryImpl` y `ProductDto`.

**19. ¿Qué diferencia hay entre una prueba unitaria, una de widget y una de integración?**

Una prueba unitaria verifica la lógica de una función o clase de forma aislada, como los tests de mi `CartNotifier`.
Una prueba de widget comprueba que la interfaz se renderice y responda correctamente a las interacciones, como mi test de `ProductsScreen` con un repositorio falso.
Una prueba de integración verifica que varias partes de la aplicación funcionen juntas en un dispositivo o emulador, por ejemplo el flujo de buscar un producto, ver el detalle y agregarlo al carrito.
Intentaría tener muchas pruebas unitarias, pruebas de widget para las pantallas importantes y pruebas de integración para los flujos críticos.

**20. Menciona tres convenciones que sigues al hacer commits y abrir un pull request.**

1. **Commits claros y descriptivos:** mensajes cortos que expliquen qué cambié, siguiendo una convención como Conventional Commits (`feat:`, `fix:`, `test:`, `chore:`), como en el historial de este repositorio.
2. **Cambios pequeños y enfocados:** cada commit resuelve un problema o agrega una funcionalidad concreta. Evito mezclar cambios no relacionados, porque así es más fácil revisar el código y detectar errores.
3. **Pull requests claros y verificables:** al abrir un pull request describo qué cambios hice, por qué los hice y cómo probarlos. También verifico que el código compile y que las pruebas pasen antes de solicitar una revisión.


## Parte 4 - Code review

### Fragmento A - Flutter / Riverpod

**1. La petición HTTP se ejecuta dentro de `build()`**

- **Qué está mal:** `http.get(...)` está escrito en `build()` y, al responder, llama a `setState`.
- **Por qué importa:** `setState` provoca otro `build()`, que lanza otra petición, y así en un bucle infinito: la pantalla se reconstruye sin parar y se satura la API.
- **Cómo lo corregiría:** moviendo la carga a un `FutureProvider` (o `AsyncNotifier`) y leyéndolo con `ref.watch` en `build()`.

**2. El carrito se muta en lugar de crear una lista nueva**

- **Qué está mal:** `ref.read(cartProvider).add(p)` modifica la lista existente. Un `StateProvider` solo notifica cuando se le asigna un valor nuevo, no cuando se muta el actual.
- **Por qué importa:** la interfaz no se entera del cambio y el contador del carrito queda desactualizado.
- **Cómo lo corregiría:** usaría un `Notifier` con un método `add` que asigne una lista nueva (`state = [...state, product]`).

**3. `ref.read(cartProvider)` dentro de `build()`**

- **Qué está mal:** `read` lee el valor una sola vez y no escucha cambios.
- **Por qué importa:** el contador del AppBar nunca se actualiza cuando cambia el carrito.
- **Cómo lo corregiría:** usando `ref.watch(cartProvider)` en `build()`. `ref.read` queda solo para callbacks como `onTap`.

**4. Estado de negocio con `setState` y variables locales**

- **Qué está mal:** `data` y `loading` viven en el `State` del widget y se modifican con `setState`.
- **Por qué importa:** mezcla la lógica con la interfaz, el estado no se puede compartir ni testear, y el widget tiene demasiadas responsabilidades.
- **Cómo lo corregiría:** pasando el estado a Riverpod y convirtiendo el widget en un `ConsumerWidget`.

**5. La UI llama a `http` directamente**

- **Qué está mal:** la pantalla hace la petición y decodifica el JSON ella misma.
- **Por qué importa:** rompe la separación en capas y no se puede probar sin internet, porque no hay forma de reemplazar la fuente de datos.
- **Cómo lo corregiría:** creando un `ProductsRepository` expuesto con un provider, de modo que la UI solo dependa de él y en los tests se pueda reemplazar por uno falso.

**6. No se manejan errores ni se comprueba la respuesta HTTP**

- **Qué está mal:** si falla la conexión o el servidor devuelve un error, `loading` queda en `true` para siempre. Además se asume que el JSON siempre tiene la estructura esperada.
- **Por qué importa:** el usuario se queda con un spinner infinito, o la app falla al procesar los datos.
- **Cómo lo corregiría:** comprobando `statusCode`, lanzando una excepción si no es 200 y mostrando los estados de carga, error y datos con `AsyncValue.when`, con un botón de reintentar.

**7. Datos sin tipo y `var` en un provider**

- **Qué está mal:** `StateProvider<List<Map>>` y `List data` usan estructuras dinámicas (`p['title']`), y `cartProvider` está declarado con `var`.
- **Por qué importa:** un error de tipeo en una clave solo se descubre en ejecución, y un `var` permite reasignar el provider por accidente.
- **Cómo lo corregiría:** definiendo un modelo `Product` con `fromJson` y declarando los providers como `final`.

**8. Detalles menores**

- `print('agregado')` es código de depuración y no debe quedar en el código.
- `ListView(children: data.map(...))` construye todos los ítems de una vez; conviene `ListView.builder`.
- `'Productos (' + cart.length.toString() + ')'` se escribe mejor con interpolación: `'Productos (${cart.length})'`.
- La URL está suelta en el código; debería ser una constante.
- Los constructores no son `const` y falta `super.key`.

### Corrección del Fragmento A

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _productsUrl = 'https://dummyjson.com/products';

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
  });

  final int id;
  final String title;
  final double price;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class ProductsRepository {
  ProductsRepository(this._client);

  final http.Client _client;

  Future<List<Product>> getProducts() async {
    final response = await _client.get(Uri.parse(_productsUrl));

    if (response.statusCode != 200) {
      throw Exception('Error al cargar los productos');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = json['products'] as List<dynamic>;

    return items
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return ProductsRepository(client);
});

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productsRepositoryProvider).getProducts();
});

class CartNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => [];

  void add(Product product) {
    state = [...state, product];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<Product>>(
  CartNotifier.new,
);

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Productos (${cart.length})')),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No se pudieron cargar los productos'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(productsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];

            return ListTile(
              title: Text(product.title),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              onTap: () => ref.read(cartProvider.notifier).add(product),
            );
          },
        ),
      ),
    );
  }
}
```

En un proyecto real, cada clase iría en su propio archivo (entidad, repositorio, providers y pantalla), como en la estructura por capas de la Parte 2. Acá se dejan juntas solo para mostrar la corrección completa.

### Fragmento B - Angular

**1. `setInterval()` nunca se limpia**

- **Qué está mal:** el intervalo se crea en `ngOnInit()` y no se cancela nunca.
- **Por qué importa:** sigue ejecutándose cada cinco segundos aunque el componente ya se haya destruido, lo que provoca una fuga de memoria y peticiones innecesarias. Además, la primera carga recién ocurre a los cinco segundos, así que la pantalla arranca vacía.
- **Cómo lo corregiría:** usando `timer(0, 5000)` de RxJS junto con `takeUntilDestroyed(this.destroyRef)`, que cancela el flujo cuando se destruye el componente y hace la primera petición de inmediato.

**2. Las peticiones pueden solaparse**

- **Qué está mal:** cada tick del intervalo inicia una petición nueva y un `subscribe()` nuevo, sin cancelar el anterior.
- **Por qué importa:** si una petición tarda más de cinco segundos, las respuestas pueden llegar desordenadas y una respuesta vieja puede pisar datos más recientes.
- **Cómo lo corregiría:** con `switchMap()`, que cancela la petición anterior cuando llega el siguiente tick.

**3. Uso de `any`**

- **Qué está mal:** `orders: any` y `(r: any)` eliminan el tipado estricto de TypeScript.
- **Por qué importa:** un error en el nombre de una propiedad o en la estructura de los datos pasa inadvertido hasta la ejecución.
- **Cómo lo corregiría:** definiendo interfaces (`Order`, `CartsResponse`) para la respuesta de la API.

**4. `HttpClient` se usa directamente en el componente**

- **Qué está mal:** el componente hace la petición HTTP y conoce la URL.
- **Por qué importa:** mezcla lógica de datos con presentación y no se puede probar ni reutilizar fácilmente.
- **Cómo lo corregiría:** moviendo la petición a un servicio inyectable (`OrdersService`) que devuelva datos tipados.

**5. No hay estados de carga ni de error**

- **Qué está mal:** si la petición falla, no hay ninguna gestión del error, y mientras carga no se muestra nada.
- **Por qué importa:** el usuario no recibe información, y un error dentro del flujo de actualización periódica podría cortar las siguientes actualizaciones.
- **Cómo lo corregiría:** con `catchError()` dentro de cada petición, que muestre un mensaje y no termine el flujo, y con un indicador de carga.

**6. La plantilla usa `*ngFor` sin importar la directiva**

- **Qué está mal:** el componente es `standalone`, pero no importa `NgFor` (ni `CommonModule`), y `orders` empieza como `undefined`.
- **Por qué importa:** Angular no reconoce la directiva y el componente falla al compilar o al renderizar.
- **Cómo lo corregiría:** usando el control flow moderno `@for (order of orders(); track order.id)`, que no necesita imports, y dando un valor inicial a `orders`.

### Corrección del Fragmento B

```typescript
import { HttpClient } from '@angular/common/http';
import {
  Component,
  DestroyRef,
  Injectable,
  OnInit,
  inject,
  signal,
} from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { EMPTY, Observable, catchError, map, switchMap, timer } from 'rxjs';

const ORDERS_URL = 'https://dummyjson.com/carts';
const POLLING_INTERVAL_MS = 5000;

interface Order {
  id: number;
  total: number;
}

interface CartsResponse {
  carts: Order[];
}

@Injectable({ providedIn: 'root' })
export class OrdersService {
  private readonly http = inject(HttpClient);

  getOrders(): Observable<Order[]> {
    return this.http
      .get<CartsResponse>(ORDERS_URL)
      .pipe(map((response) => response.carts));
  }
}

@Component({
  selector: 'app-orders',
  template: `
    @if (loading()) {
      <p>Cargando pedidos...</p>
    }

    @if (errorMessage(); as message) {
      <p>{{ message }}</p>
    }

    @for (order of orders(); track order.id) {
      <div>{{ order.total }}</div>
    }
  `,
})
export class OrdersComponent implements OnInit {
  private readonly ordersService = inject(OrdersService);
  private readonly destroyRef = inject(DestroyRef);

  protected readonly orders = signal<Order[]>([]);
  protected readonly loading = signal(true);
  protected readonly errorMessage = signal<string | null>(null);

  ngOnInit(): void {
    timer(0, POLLING_INTERVAL_MS)
      .pipe(
        switchMap(() =>
          this.ordersService.getOrders().pipe(
            catchError(() => {
              this.errorMessage.set('No se pudieron cargar los pedidos');
              this.loading.set(false);
              return EMPTY;
            }),
          ),
        ),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe((orders) => {
        this.orders.set(orders);
        this.errorMessage.set(null);
        this.loading.set(false);
      });
  }
}
```

`takeUntilDestroyed` recibe el `DestroyRef` porque se usa dentro de `ngOnInit()`, que no es un contexto de inyección. Los estados usan `signal` para que la vista se actualice correctamente.