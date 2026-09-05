# Data Understanding

## 1. Dataset Overview

This project uses the Online Retail II dataset from the UCI Machine Learning Repository.

The dataset contains transaction records from a UK-based non-store online retailer and covers approximately two years of activity.

The original Excel workbook contains two worksheets:

| Worksheet | Transaction Rows |
|---|---:|
| Year 2009-2010 | 525,461 |
| Year 2010-2011 | 541,910 |
| **Total** | **1,067,371** |

The raw data is being investigated before defining cleaning or exclusion rules.

---

## 2. Dataset Structure

The dataset contains eight original fields:

| Field | Initial Interpretation |
|---|---|
| Invoice | Identifier assigned to a transaction/invoice |
| StockCode | Identifier associated with a product/item |
| Description | Product/item description |
| Quantity | Quantity of the item recorded on the transaction line |
| InvoiceDate | Date and time associated with the transaction |
| Price | Unit price of the item |
| Customer ID | Identifier associated with a customer |
| Country | Customer's country |

### Transaction Grain

Initial inspection showed that the same Invoice can appear across multiple rows with different StockCodes.

Therefore, a repeated Invoice number does not by itself indicate a duplicate.

The working interpretation of the dataset grain is:

> **One row represents a product/item line within a transaction or invoice.**

This distinction will be important when calculating invoice-level metrics and investigating potential duplicate records.

---

## 3. Initial Data Profiling

The following checks were performed on the two raw worksheets before applying any cleaning rules.

| Metric | 2009-2010 | 2010-2011 |
|---|---:|---:|
| Total Rows | 525,461 | 541,910 |
| Missing Customer ID | 107,927 | 135,080 |
| Missing Description | 2,928 | 1,455 |
| Quantity = 0 | 0 | 0 |
| Quantity < 0 | 12,326 | 10,624 |
| Price = 0 | 3,687 | 2,515 |
| Price < 0 | 3 | 2 |
| Cancellation Rows | 10,206 | 9,288 |
| Unique Invoices | 28,816 | 25,900 |
| Unique Customers | 4,383 | 4,372 |
| Unique StockCodes | 4,481 | 3,958 |

### Missing-Value Rates

| Metric | 2009-2010 | 2010-2011 |
|---|---:|---:|
| Missing Customer ID | 20.54% | 24.93% |
| Missing Description | 0.56% | 0.27% |
| Quantity < 0 | 2.35% | 1.96% |
| Price = 0 | 0.70% | 0.46% |
| Cancellation Rows | 1.94% | 1.71% |

Customer ID has substantial missingness in both years. This may have an important effect on customer-level analysis and will therefore be investigated separately rather than automatically removing the affected transactions.

---

## 4. Cancellation Pattern Investigation

According to the dataset documentation, invoice numbers beginning with `C` indicate cancellations.

The relationship between cancellation status and negative Quantity was tested rather than assuming that every negative quantity represented a cancellation.

### 2009-2010

| Cancellation Status | Negative Quantity | Non-Negative Quantity | Total |
|---|---:|---:|---:|
| Cancellation | 10,205 | 1 | 10,206 |
| Not Cancellation | 2,121 | 513,134 | 515,255 |
| **Total** | **12,326** | **513,135** | **525,461** |

One unusual C-prefixed transaction was identified with a positive quantity:

- Invoice: `C496350`
- StockCode: `M`
- Description: `Manual`
- Quantity: `1`
- Price: `373.57`
- Customer ID: Missing

This record is retained as an exception requiring further investigation.

### 2010-2011

| Cancellation Status | Negative Quantity | Non-Negative Quantity | Total |
|---|---:|---:|---:|
| Cancellation | 9,288 | 0 | 9,288 |
| Not Cancellation | 1,336 | 531,286 | 532,622 |
| **Total** | **10,624** | **531,286** | **541,910** |

All C-prefixed cancellation rows identified in the second worksheet had negative quantities.

---

## 5. Negative Non-Cancellation Transactions

Negative quantities were also found on invoices that did not begin with `C`.

This pattern appeared in both years:

| Year | Negative Non-Cancellation Rows |
|---|---:|
| 2009-2010 | 2,121 |
| 2010-2011 | 1,336 |
| **Total** | **3,457** |

Further profiling identified a consistent pattern.

### 2009-2010

Among all 2,121 negative non-cancellation records:

- 2,121 had missing Customer IDs
- 2,121 had a Price of zero
- none had a populated Customer ID
- none had a positive or negative non-zero Price

### 2010-2011

Among all 1,336 negative non-cancellation records:

- 1,336 had missing Customer IDs
- 1,336 had a Price of zero
- none had a populated Customer ID
- none had a positive or negative non-zero Price

The same structural pattern therefore occurs across both years.

---

## 6. Investigation of Transaction Descriptions

Manual inspection of the negative non-cancellation population identified descriptions associated with unusual operational activity, including examples referring to:

- damaged or broken items,
- missing stock,
- items being given away,
- correction or mistake-related notes,
- non-standard sales references,
- and blank descriptions.

The records are distributed across many StockCodes rather than being explained by one dominant product code.

For example, in the 2009-2010 investigation, the most frequent StockCode within this population occurred only nine times.

These observations suggest that at least part of this population may represent operational or inventory adjustments rather than ordinary customer purchases.

However, the exact business meaning of these records has not yet been confirmed. They will therefore not be automatically classified as invalid or removed.

---

## 7. Initial Data Quality Concerns

The initial investigation identified several areas requiring further analysis:

1. Missing Customer IDs may limit customer-level analysis.
2. Missing product descriptions require investigation before deciding whether affected rows remain useful.
3. Negative quantities include both documented cancellations and a separate non-cancellation pattern.
4. Zero-price transactions require classification before revenue analysis.
5. A very small number of negative-price records require individual investigation.
6. Potential duplicate records require analysis at the transaction-line grain rather than using Invoice alone.
7. Non-standard StockCodes and transaction descriptions may represent operational transaction types rather than ordinary merchandise.
8. A single unusual positive-quantity C-prefixed transaction was identified in the first year.

---

## 8. Current Analytical Interpretation

The profiling results show that unusual records should not be treated with a single blanket cleaning rule.

In particular, negative quantities cannot automatically be removed because they occur under different transaction patterns.

The negative non-cancellation population shows a repeatable structure across both years: missing Customer ID, zero Price, and negative Quantity. Descriptions observed within this population also include terms associated with damage, missing stock, corrections, and other non-standard activity.

At this stage, these records are treated as a separate population requiring further investigation rather than as confirmed data errors.

---

## 9. Open Questions

The next stage of the project will investigate:

- How should cancellations be treated when calculating sales performance?
- What do the negative non-cancellation records represent operationally?
- What business meaning should be assigned to zero-price transactions?
- What caused the small number of negative-price transactions?
- Can transactions with missing Customer IDs still be used for sales and product analysis?
- Which fields should define a potential duplicate transaction line?
- How should non-standard StockCodes be classified?
- Should different analytical populations be used for sales, product, and customer analysis?

No final cleaning or exclusion rules have been applied at this stage.                                                                                              

## Next Stage

The questions identified during this initial exploration were investigated further in the data quality assessment.

The next stage examines the unusual transaction patterns in more detail and documents how missing values, cancellations, pricing anomalies, and other non-standard records should be handled before the main analysis.

See: [Data Quality Assessment](data_quality_report.md)
