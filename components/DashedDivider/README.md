# DashedDivider

The dashed hairline between the top-level sections of a page: `border`, 1pt, 4 on and 4 off. In Swift: `DashedDivider()`.

- Use it only between page sections such as Needs attention, Running now and Recent activity. The page's `space-24` spacing puts it 24 from each section.
- Inside a card or a list, use a solid 1pt `border` line (`Rectangle().fill(K.border).frame(height: 1)`).
