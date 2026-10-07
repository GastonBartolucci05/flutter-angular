import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'productsLabel' })
export class ProductsLabelPipe implements PipeTransform {
  transform(count: number): string {
    return count === 1 ? '1 Product' : `${count} Products`;
  }
}