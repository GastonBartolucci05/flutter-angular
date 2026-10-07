import { provideHttpClient } from '@angular/common/http';
import {
  HttpTestingController,
  provideHttpClientTesting,
} from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { Order } from './order.model';
import { OrdersService } from './orders.service';

const mockOrder: Order = {
  id: 1,
  userId: 7,
  products: [],
  total: 100,
  totalProducts: 2,
  totalQuantity: 3,
};

describe('OrdersService', () => {
  let service: OrdersService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    service = TestBed.inject(OrdersService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => httpMock.verify());

  it('returns the carts from the API response', () => {
    let result: Order[] | undefined;

    service.getOrders().subscribe((orders) => (result = orders));

    const req = httpMock.expectOne('https://dummyjson.com/carts');
    expect(req.request.method).toBe('GET');
    req.flush({ carts: [mockOrder] });

    expect(result).toEqual([mockOrder]);
  });
});