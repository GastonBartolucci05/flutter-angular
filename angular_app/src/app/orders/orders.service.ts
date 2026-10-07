import { HttpClient } from "@angular/common/http";
import { inject, Injectable } from "@angular/core";
import { map, Observable } from "rxjs";
import { Order, OrderResponse } from "./order.model";

const ORDERS_URL = 'https://dummyjson.com/carts';

@Injectable({
    providedIn: 'root'
})
export class OrdersService {
    private readonly http = inject(HttpClient);
    getOrders(): Observable<Order[]> {
        return this.http.get<OrderResponse>(ORDERS_URL).pipe(map((response) => response.carts));
    }
}