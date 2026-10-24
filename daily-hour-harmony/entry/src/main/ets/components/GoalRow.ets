import { DayCell, GoalItem } from '../model/Models';
import { DIMENSION_SHORT_NAMES, dimensionColor } from '../utils/Dimensions';

@Component
export struct GoalRow {
  @ObjectLink goal: GoalItem;
  @Prop nameWidth: number = 160;
  @Prop visibleCount: number = 7;
  @Prop today: string = '';
  onToggle: (goal: GoalItem, cellIndex: number) => void = () => {
  };
  onEdit: (goal: GoalItem) => void = () => {
  };

  build() {
    Row() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Progress({
            value: this.goal.ringProgress * 100,
            total: 100,
            type: ProgressType.Ring
          })
            .width(15)
            .height(15)
            .color(dimensionColor(this.goal.dimension))
            .style({ strokeWidth: 3 })
        }
        .width(15)
        .height(15)
        .margin({ left: 8, right: 8 })

        Column() {
          Text(this.goal.name)
            .fontSize(16)
            .fontColor(dimensionColor(this.goal.dimension))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${DIMENSION_SHORT_NAMES[this.goal.dimension]} · ${this.goal.defaultMinutes}分`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(1)
            .margin({ top: 1 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width(this.nameWidth)
      .height('100%')
      .padding({ right: 4 })
      .onClick(() => this.onEdit(this.goal))

      ForEach(this.goal.cells.slice(7 - this.visibleCount), (cell: DayCell, index: number) => {
        Stack({ alignContent: Alignment.Center }) {
          if (cell.checked) {
            Circle()
              .width(28)
              .height(28)
              .fill(dimensionColor(this.goal.dimension))
              .opacity(0.14)
            Text('✓')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(dimensionColor(this.goal.dimension))
          } else {
            Circle()
              .width(26)
              .height(26)
              .fill(Color.Transparent)
              .stroke(cell.date === this.today
                ? dimensionColor(this.goal.dimension)
                : $r('app.color.track'))
              .strokeWidth(2)
              .opacity(cell.date === this.today ? 0.7 : 1)
          }
        }
        .width(48)
        .height(48)
        .borderRadius(8)
        .backgroundColor(cell.date === this.today
          ? $r('app.color.today_bg')
          : Color.Transparent)
        .onClick(() => {
          this.onToggle(this.goal, 7 - this.visibleCount + index);
        })
      }, (cell: DayCell) => `${this.goal.id}-${cell.date}-${cell.checked ? '1' : '0'}`)
    }
    .width('100%')
    .height(48)
    .backgroundColor($r('app.color.card_bg'))
    .margin({ top: 1.5, bottom: 1.5, left: 3, right: 3 })
  }
}
