import { Routes } from '@angular/router';
import { OrdersPageComponent } from './orders/order-page.components';


export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'orders' },
  { path: 'orders', component: OrdersPageComponent },
  {
    path: 'orders/:id',
    loadComponent: () =>
      import('./orders/order-detail.component').then(
        (m) => m.OrderDetailComponent,
      ),
  },
];