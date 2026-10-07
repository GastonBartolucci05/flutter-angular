import { ProductsLabelPipe } from './products-label.pipe';

describe('ProductsLabelPipe', () => {
  const pipe = new ProductsLabelPipe();

  it('uses the singular for one product', () => {
    expect(pipe.transform(1)).toBe('1 Product');
  });

  it('uses the plural otherwise', () => {
    expect(pipe.transform(3)).toBe('3 Products');
  });
});