export const DIMENSION_COUNT: number = 4;

export const DIMENSION_SHORT_NAMES: string[] = ['身体', '精神', '智力', '社会'];

export const DIMENSION_FULL_NAMES: string[] = ['身体', '精神', '智力', '社会情感'];

export function dimensionColor(index: number): Resource {
  if (index === 1) {
    return $r('app.color.dimension_1');
  }
  if (index === 2) {
    return $r('app.color.dimension_2');
  }
  if (index === 3) {
    return $r('app.color.dimension_3');
  }
  return $r('app.color.dimension_0');
}
