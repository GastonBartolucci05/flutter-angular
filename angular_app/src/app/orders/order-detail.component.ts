import { CurrencyPipe } from '@angular/common';
import { Component, computed, inject, input } from '@angular/core';
import { toObservable, toSignal } from '@angular/core/rxjs-interop';
import { RouterLink } from '@angular/router';
import { catchError, map, of, switchMap } from 'rxjs';
import { Order } from './order.model';
import { OrdersService } from './orders.service';
import { ProductsLabelPipe } from './products-label.pipe';

type DetailState =
  | { status: 'loading' }
  | { status: 'error' }
  | { status: 'success'; order: Order };

@Component({
  selector: 'app-order-detail',
  imports: [CurrencyPipe, RouterLink, ProductsLabelPipe],
  template: `
    <a routerLink="/orders">← Back to orders</a>

    @if (order(); as order) {
      <h1>Order #{{ order.id }}</h1>
      <p>User: {{ order.userId }}</p>
      <p>{{ order.totalProducts | productsLabel }}</p>
      <p>Total: {{ order.total | currency }}</p>

      <ul>
        @for (product of order.products; track product.id) {
          <li>
            {{ product.title }} x{{ product.quantity }} -
            {{ product.total | currency }}
          </li>
        }
      </ul>
    } @else if (state().status === 'error') {
      <p>No se pudo cargar el pedido.</p>
    } @else {
      <p>Loading order...</p>
    }
  `,
})
export class OrderDetailComponent {
  private readonly ordersService = inject(OrdersService);

  readonly id = input.required<string>();

  protected readonly state = toSignal(
    toObservable(this.id).pipe(
      switchMap((id) =>
        this.ordersService.getOrder(Number(id)).pipe(
          map((order): DetailState => ({ status: 'success', order })),
          catchError(() => of<DetailState>({ status: 'error' })),
        ),
      ),
    ),
    { initialValue: { status: 'loading' } as DetailState },
  );

  protected readonly order = computed(() => {
    const current = this.state();
    return current.status === 'success' ? current.order : null;
  });
}