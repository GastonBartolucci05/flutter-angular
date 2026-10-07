import { Component, signal } from '@angular/core';
import { OrdersPageComponent } from './orders/order-page.components';

@Component({
  imports: [OrdersPageComponent],
  selector: 'app-root',
  styleUrl: './app.css',
  templateUrl: './app.html',
})
export class App {
  protected readonly title = signal('angular_app');
}
