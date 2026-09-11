# Insight Log

This document records the key validated findings from the Retail Sales & Customer Performance Analytics project. Findings are based on the cleaned and classified transaction dataset and are written conservatively to distinguish evidence from interpretation.

## 1. Sales Performance

After removing exact duplicate records and classifying the different transaction types, gross sales from valid positive-price Sale transactions were approximately **20.48M**.

Standard cancellations accounted for approximately **1.46M**, bringing net sales after cancellations to approximately **19.01M**.

Monthly performance varied considerably across the dataset. **November 2011 recorded the highest monthly gross sales value at approximately 1.50M**.

The dataset does not contain complete calendar years at both boundaries. Records begin in December 2009 and end on 9 December 2011, so 2009 and 2011 should not be compared directly with the complete 2010 period.

### What this means

Gross sales alone can overstate business performance when cancellation activity is significant. For this reason, I used net sales alongside gross sales when evaluating overall performance and trends.

---

## 2. Cancellation Impact

Cancellations had a meaningful financial impact on the business.

Across the dataset:

- Gross Sale value: **20.48M**
- Cancellation value: **1.46M**
- Net sales after cancellations: **19.01M**
- Cancellation value was approximately **7.14% of gross Sale value**

Cancellation behavior also changed substantially from month to month.

Among complete months, **January 2011 had the highest cancellation impact**, with cancellation value equivalent to approximately **19.04% of gross sales**.

An important observation was that cancellation frequency, quantity, and financial value did not always move together. A month with many cancellation invoices was not necessarily the month with the largest financial impact.

### What this means

Cancellation performance should not be monitored using a single metric. Looking at cancellation value, cancelled quantity, and invoice count together provides a more useful view of the operational and financial impact.

---

## 3. Product Performance

Product performance was evaluated using **net sales rather than gross positive sales**, because several products had significant cancellation activity.

This became particularly important when investigating StockCode `23843`. The dataset contained a Sale transaction for **80,995 units** with a value of approximately **168.47K**, followed only 12 minutes later by a cancellation for the same quantity, price, and customer.

The two transactions fully offset each other.

Using the original Sale transaction alone would therefore have incorrectly presented this product as one of the strongest products in the dataset.

After accounting for cancellations, the leading merchandise product by net sales was StockCode `22423`, with approximately **314.05K** in net sales.

### Product concentration

Total merchandise net sales were approximately **18.96M**, while the Top 10 products generated approximately **1.44M**.

This means the Top 10 products represented only **7.59% of merchandise net sales**.

### What this means

Sales are relatively distributed across the product range rather than being heavily dependent on a small number of top products.

It also shows why transaction context matters. A large transaction should not automatically be treated as strong product performance without checking whether it was later reversed.

---

## 4. Product Data Quality

During product analysis, I found that **648 StockCodes were associated with more than one description**.

Because descriptions were not completely consistent, I used `StockCode` as the main product identifier instead of relying on product descriptions.

I also identified several codes that do not represent normal merchandise, including:

- `M` — Manual
- `DOT` — DOTCOM Postage
- `POST` — Postage
- `AMAZONFEE` — Amazon Fee
- `BANK CHARGES` — Bank Charges
- `D` — Discount
- `CRUK` — CRUK Commission

These records were retained in the dataset because they may be relevant to the overall financial activity, but they were excluded from merchandise product rankings.

### What this means

Separating merchandise from fees, discounts, postage, and other non-product activity prevents financial or administrative records from distorting product-performance rankings.

---

## 5. Geographic Performance

The business is highly concentrated in the **United Kingdom**.

Total net sales were approximately **19.01M**, of which approximately **16.14M** came from the UK.

The UK therefore represented approximately **84.91% of total net sales**.

Some smaller international markets showed higher average order values, but these figures need to be interpreted carefully because several of these markets have much smaller customer and transaction bases.

### What this means

The UK is clearly the core market in this dataset. The high concentration also means that overall business performance is strongly influenced by the domestic market.

International markets may still be worth investigating for growth opportunities, but high average order values alone are not enough to conclude that a market is more attractive without considering its customer base, order volume, and consistency over time.

---

## 6. Customer Behavior

Customer analysis was limited to transactions with an available Customer ID.

Among identified customers who made Sale transactions:

- Total customers: **5,878**
- Repeat customers: **4,255**
- One-time customers: **1,623**
- Repeat customer rate: **72.39%**

This suggests that repeat purchasing is common among customers who can be identified in the dataset.

### Customer concentration

The Top 10 identified customers generated approximately **16.30% of identified-customer net sales**.

This indicates some dependence on high-value customers, but sales are not concentrated entirely within a very small customer group.

### Important limitation

Approximately **22.67% of Sale rows have no Customer ID**.

These transactions represent approximately **3.10M in gross Sale value**, or around **15.15% of total gross Sale value**.

I kept these transactions in sales, product, time, and market analysis because they still contain useful transaction information. However, I excluded them from customer-level measures such as unique customer counts and repeat-purchase behavior because the customers cannot be identified reliably.

No Customer IDs were imputed.

---

## 7. Data Quality Findings

The raw dataset contained several issues that could materially affect the analysis if handled without investigation.

The two source sheets contained **1,067,371 rows** in total.

During validation, I found that their date ranges overlap in December 2010. An exact comparison across all original fields identified **22,523 rows occurring in both source tables**.

After combining both periods and checking exact duplicates across the full dataset, **34,335 excess exact copies** were identified.

The resulting deduplicated dataset contains **1,033,036 rows**.

The duplicate count was calculated across the combined dataset rather than by simply adding within-sheet duplicates and cross-sheet overlap, because some records belong to both categories.

### Other transaction patterns

The data also contained:

- Standard C-prefixed cancellations
- Negative-quantity records outside standard cancellations
- Zero-price transactions
- Negative-price bad-debt adjustments
- Missing Customer IDs
- Missing product descriptions
- A small number of unusual transaction exceptions

These patterns were investigated separately rather than being removed automatically.

For example, negative quantities outside C-prefixed cancellations consistently appeared with zero price and missing Customer IDs. Many descriptions referred to damaged, missing, broken, corrected, or other non-standard stock activity.

I therefore classified these records as **Non-standard adjustments** rather than treating them as ordinary customer sales.

Their exact operational meaning is not documented in the source dataset, so the classification remains intentionally conservative.

---

## 8. Key Business Takeaways

The analysis highlights several points that would be useful for further business investigation:

1. **Net sales should be monitored alongside gross sales.** Cancellations represent a meaningful share of transaction value and can materially change product and monthly performance.

2. **Cancellation monitoring should combine value, quantity, and frequency.** These measures reveal different types of cancellation behavior.

3. **The business is geographically concentrated.** Approximately 84.91% of net sales come from the UK.

4. **Product sales are relatively distributed.** The Top 10 merchandise products account for only 7.59% of merchandise net sales.

5. **Repeat purchasing is common among identifiable customers.** Approximately 72.39% of identified purchasing customers placed more than one Sale order.

6. **Missing Customer IDs limit customer analysis.** Customer-level conclusions should not be generalized to all transactions because a meaningful portion of sales cannot be linked to an identified customer.

7. **Transaction classification materially affects the results.** Cancellations, adjustments, fees, postage, discounts, and unusual zero-price transactions should not automatically be treated as ordinary merchandise sales.

---

## 9. Recommended Next Analysis

Based on these findings, the next useful areas to investigate would be:

- Monitor monthly net sales and cancellation impact together.
- Investigate months with unusually high cancellation value or quantity.
- Review high-performing products together with their cancellation activity.
- Explore international markets using both sales value and customer/order volume rather than AOV alone.
- Examine customer value and retention in more detail where Customer ID is available.
- Investigate the operational meaning of non-standard adjustments if additional business documentation becomes available.

These recommendations are intended as areas for further investigation rather than conclusions about the causes of the observed patterns.
