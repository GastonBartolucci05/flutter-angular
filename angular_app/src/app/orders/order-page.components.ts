import { Component, computed, Inject, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { catchError, map, of } from 'rxjs';
import { Order } from './order.model';
import { OrdersService } from './orders.service';
import { OrderCardComponent } from './order-card.components';
import { Router } from '@angular/router';

type OrdersState =
  | { status: 'loading' }
  | { status: 'error' }
  | { status: 'success'; orders: Order[] };

@Component({
  selector: 'app-orders-page',
  imports: [ReactiveFormsModule, OrderCardComponent],
  template: `
    <h1>Orders Panel</h1>

    <label>
      Minimun total
      <input type="number" [formControl]="minTotal" />
    </label>

    @if (state().status === 'loading') {
      <p>Loafing orders...</p>
    } @else if (state().status === 'error') {
      <p>The orders could not be loaded.</p>
    } @else {
      @for (order of filteredOrders(); track order.id) {
        <app-order-card
          [order]="order"
          (viewDetail)="openDetail($event)"
        />
      } @empty {
        <p>There are no orders matching that filter.</p>
      }
    }
  `,
})
export class OrdersPageComponent {
  private readonly ordersService = inject(OrdersService);
  private readonly router = inject(Router);

  protected readonly minTotal = new FormControl<number | null>(null);
  protected readonly selectedOrderId = signal<number | null>(null);

  private readonly minTotalValue = toSignal(this.minTotal.valueChanges, {
    initialValue: null,
  });

  protected readonly state = toSignal(
    this.ordersService.getOrders().pipe(
      map((orders): OrdersState => ({ status: 'success', orders })),
      catchError(() => of<OrdersState>({ status: 'error' })),
    ),
    { initialValue: { status: 'loading' } as OrdersState },
  );

  protected readonly filteredOrders = computed(() => {
    const current = this.state();
    if (current.status !== 'success') return [];
    const min = this.minTotalValue() ?? 0;
    return current.orders.filter((order) => order.total >= min);
  });

  protected openDetail(orderId: number): void {
    void this.router.navigate(['/orders', orderId]);
  }
}