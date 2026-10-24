import { DayHeader } from '../model/Models';

@Component
export struct WeekdayHeader {
  @Prop nameWidth: number = 160;
  @Prop headers: DayHeader[] = [];
  @Prop visibleCount: number = 4;

  build() {
    Row() {
      Row()
        .width(this.nameWidth)

      ForEach(this.headers.slice(7 - this.visibleCount), (header: DayHeader) => {
        Column() {
          Text(header.weekday)
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor(header.isToday
              ? $r('app.color.accent')
              : $r('app.color.text_secondary'))
          Text(header.dayOfMonth)
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor(header.isToday
              ? $r('app.color.accent')
              : $r('app.color.text_secondary'))
            .margin({ top: 1 })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
      }, (header: DayHeader) => `${header.weekday}-${header.dayOfMonth}-${header.isToday ? '1' : '0'}`)
    }
    .width('100%')
    .height(48)
    .padding({ left: 3, right: 3 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.header_bg'))
    .border({ width: { bottom: 1 }, color: $r('app.color.divider') })
  }
}
