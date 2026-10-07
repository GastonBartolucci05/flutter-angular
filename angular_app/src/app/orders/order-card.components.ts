import { CurrencyPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { Order } from './order.model';

@Component({
  selector: 'app-order-card',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [CurrencyPipe],
  template: `
    <article class="card">
      <h3>Order #{{ order().id }}</h3>
      <p>Users: {{ order().userId }}</p>
      <p>Products: {{ order().totalProducts }}</p>
      <p>Total: {{ order().total | currency }}</p>
      <button type="button" (click)="viewDetail.emit(order().id)">
        View Details
      </button>
    </article>
  `,
  styles: `
    .card {
      border: 1px solid #ccc;
      border-radius: 8px;
      padding: 12px;
      margin-bottom: 12px;
    }
  `,
})
export class OrderCardComponent {
  readonly order = input.required<Order>();
  readonly viewDetail = output<number>();
}