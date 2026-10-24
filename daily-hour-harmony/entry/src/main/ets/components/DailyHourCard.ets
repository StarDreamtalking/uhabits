import { DailySummary } from '../model/Models';
import { DIMENSION_SHORT_NAMES, dimensionColor } from '../utils/Dimensions';

@Component
export struct DailyHourCard {
  @ObjectLink summary: DailySummary;

  private statusText(): string {
    if (this.summary.totalMinutes === 0) {
      return '今天还没有投入';
    }
    if (this.summary.totalMinutes < this.summary.targetMinutes) {
      return `还差 ${this.summary.remaining} 分钟`;
    }
    if (this.summary.totalMinutes === this.summary.targetMinutes) {
      return '今日目标已完成';
    }
    return `已超出 ${this.summary.over} 分钟`;
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Progress({
          value: this.summary.progress * 100,
          total: 100,
          type: ProgressType.Ring
        })
          .width(40)
          .height(40)
          .color(this.summary.progress >= 1
            ? $r('app.color.success')
            : $r('app.color.accent'))
          .style({ strokeWidth: 4 })
        Text(`${Math.round(this.summary.progress * 100)}%`)
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
      }
      .width(40)
      .height(40)

      Column() {
        Row() {
          Column() {
            Text('今日一小时')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
            Text(this.statusText())
              .fontSize(11)
              .fontColor($r('app.color.text_tertiary'))
              .margin({ top: 1 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Row() {
            Text(`${this.summary.totalMinutes} / ${this.summary.targetMinutes}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text(' 分钟')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 2 })
          }
          .alignItems(VerticalAlign.Bottom)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          ForEach([0, 1, 2, 3], (dimension: number) => {
            Row() {
              Circle()
                .width(6)
                .height(6)
                .fill(dimensionColor(dimension))
                .opacity(this.summary.dimensionMinutes[dimension] > 0 ? 1 : 0.3)
              Text(`${DIMENSION_SHORT_NAMES[dimension]} ${this.summary.dimensionMinutes[dimension]}`)
                .fontSize(11)
                .fontColor(this.summary.dimensionMinutes[dimension] > 0
                  ? $r('app.color.text_secondary')
                  : $r('app.color.text_tertiary'))
                .margin({ left: 3 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
          }, (dimension: number) => dimension.toString())
        }
        .width('100%')
        .margin({ top: 5 })

        Row() {
          ForEach([0, 1, 2, 3], (dimension: number) => {
            if (this.summary.dimensionMinutes[dimension] > 0) {
              Row()
                .layoutWeight(this.summary.dimensionMinutes[dimension])
                .height(4)
                .backgroundColor(dimensionColor(dimension))
            }
          }, (dimension: number) => `segment-${dimension}`)
          if (this.summary.totalMinutes < this.summary.targetMinutes) {
            Row()
              .layoutWeight(this.summary.targetMinutes - this.summary.totalMinutes)
              .height(4)
              .backgroundColor($r('app.color.track'))
          }
        }
        .width('100%')
        .height(4)
        .borderRadius(2)
        .clip(true)
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_bg'))
    .borderRadius(12)
    .shadow({ radius: 2, color: '#14000000', offsetY: 1 })
  }
}
