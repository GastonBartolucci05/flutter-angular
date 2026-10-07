import { CurrencyPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { Order } from './order.model';
import { ProductsLabelPipe } from './products-label.pipe';

@Component({
    selector: 'app-order-card',
    changeDetection: ChangeDetectionStrategy.OnPush,
    imports: [CurrencyPipe, ProductsLabelPipe],
    template: `
    <article class="card">
      <h3>Order #{{ order().id }}</h3>
      <p>Users: {{ order().userId }}</p>
      <p>{{ order().totalProducts | productsLabel }}</p>
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