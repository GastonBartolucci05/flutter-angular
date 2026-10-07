import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Order } from './order.model';
import { OrderCardComponent } from './order-card.components'

const mockOrder: Order = {
  id: 5,
  userId: 7,
  products: [],
  total: 100,
  totalProducts: 2,
  totalQuantity: 3,
};

describe('OrderCardComponent', () => {
  let fixture: ComponentFixture<OrderCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [OrderCardComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(OrderCardComponent);
    fixture.componentRef.setInput('order', mockOrder);
    fixture.detectChanges();
  });

  it('shows the order id', () => {
    expect(fixture.nativeElement.textContent).toContain('Order #5');
  });

  it('emits the order id when the detail button is clicked', () => {
    let emittedId: number | undefined;
    fixture.componentInstance.viewDetail.subscribe((id) => (emittedId = id));

    fixture.nativeElement.querySelector('button').click();

    expect(emittedId).toBe(5);
  });
});