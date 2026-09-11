# Data Quality Assessment

## Overview

Before starting the main analysis, I reviewed the dataset to understand the main data quality issues and how they could affect the results.

I did not want to remove records only because they contained a missing value, zero price, or negative quantity. Some unusual records may represent real business activities such as cancellations, inventory adjustments, or financial corrections.

For this reason, I investigated the main issues across both periods, 2009–2010 and 2010–2011, before deciding how they should be handled.

The main areas reviewed were:

- Negative quantities
- Negative prices
- Zero prices
- Missing Customer IDs
- Missing product descriptions
- Potential duplicate records

---

## 1. Negative Quantities

The dataset documentation states that invoices beginning with `C` represent cancellations. Most negative quantities followed this pattern, but I also found negative quantities on invoices that were not marked as cancellations.

Across both years, 3,457 negative-quantity rows were found outside C-prefixed invoices.

Further investigation showed that these records consistently had:

- Zero price
- Missing Customer ID
- A non-cancellation invoice number

I also reviewed the available descriptions. Many contained terms related to damaged or missing stock, broken items, corrections, giveaways, and other non-standard activities.

### Interpretation

These records do not behave like normal customer sales. Their structure and descriptions suggest that they may be related to inventory or operational adjustments.

However, the dataset does not provide enough information to confirm the exact business process behind every record.

I will therefore keep these records separate from normal sales and confirmed cancellations rather than automatically removing them.

---

## 2. Negative Prices

Negative prices were uncommon. Only five records with negative prices were found across both years.

All five followed the same pattern:

- StockCode: `B`
- Description: `Adjust bad debt`
- Quantity: 1
- Missing Customer ID
- Negative price

### Interpretation

These records appear to represent bad-debt or financial adjustments rather than product sales.

Because of this, they should not be included in normal merchandise sales or product-performance calculations.

They will be kept as a separate type of transaction rather than treated as data-entry errors.

---

## 3. Zero Prices

Zero-price records required more investigation because they did not all follow the same pattern.

There were 6,202 zero-price rows across both periods:

- 2009–2010: 3,687
- 2010–2011: 2,515

I compared these records using quantity, Customer ID availability, product description, invoice structure, and other transaction information.

Several different patterns appeared.

Some zero-price records were negative-quantity transactions with missing Customer IDs. These were part of the non-standard operational records identified during the negative-quantity investigation.

Other zero-price records had positive quantities but were missing customer or product information.

I also found several large invoices containing many normal-looking product lines recorded with zero prices. In some of these invoices, the zero-priced product lines appeared together with a single `Manual` line carrying a non-zero value.

A smaller number of zero-price product lines were linked to identified customers and appeared within otherwise normal-looking customer invoices.

### Interpretation

The main finding from this investigation is that a zero price does not represent one single data quality issue.

Different zero-price records appear to be associated with different transaction patterns. Removing all of them would potentially remove useful information, while treating all of them as normal product sales could also produce misleading results.

For this reason, zero-price records will be handled according to their transaction pattern rather than using one rule for every record.

---

## 4. Missing Customer IDs

Missing Customer IDs were relatively common in both periods:

- 2009–2010: 107,927 rows
- 2010–2011: 135,080 rows

I first checked whether missing Customer IDs were mainly associated with cancellations, negative quantities, or other unusual transactions.

The results showed that most were not.

A large number of records with missing Customer IDs had non-negative quantities, positive prices, and valid product descriptions.

Positive-price, non-negative transaction lines with missing Customer IDs included:

- 103,902 rows in 2009–2010
- 132,220 rows in 2010–2011

For 2009–2010, I also checked the country distribution of these records. Most were associated with the United Kingdom.

### Interpretation

A missing Customer ID does not automatically make the transaction unusable.

The product, quantity, price, date, and other transaction information can still be useful for several types of analysis.

I will therefore retain these records where customer identity is not required.

They can still contribute to:

- Revenue analysis
- Product analysis
- Quantity analysis
- Sales trends over time
- Geographic analysis

However, they cannot be reliably used for analyses that require an identified customer, including:

- Unique customer counts
- Repeat-customer analysis
- Customer segmentation
- Customer-level purchasing behavior

I will not attempt to create or estimate missing Customer IDs because there is not enough information to identify the customers reliably.

---

## 5. Missing Product Descriptions

Missing product descriptions were less common than missing Customer IDs.

In 2009–2010, there were 2,928 records with missing descriptions. All of them also had a zero price and a missing Customer ID.

In 2010–2011, there were 1,455 records with missing descriptions. Of these, 1,454 followed the same zero-price and missing-customer pattern.

Only one record was different. It had:

- A positive price
- A positive quantity
- A valid Customer ID
- A valid StockCode
- A non-cancellation invoice
- A missing Description

This record otherwise looked similar to a normal transaction.

### Interpretation

Missing Description alone is not enough reason to remove a transaction.

For the single normal-looking transaction, the StockCode still provides a product identifier and the remaining transaction information can still contribute to the analysis.

I will therefore keep missing descriptions as missing rather than filling them with an unsupported product name.

Where appropriate, `StockCode` will be used as the main product identifier.

---

## 6. Exact Duplicate Records

Exact duplicate validation was performed in PostgreSQL using all eight original transaction fields:

- Invoice
- StockCode
- Description
- Quantity
- InvoiceDate
- Price
- Customer ID
- Country

A record was considered an exact duplicate only when all eight fields matched. Repeated invoice numbers or StockCodes alone were not treated as duplicates because an invoice can legitimately contain multiple product lines.

### Initial within-period checks

When the two source periods were checked separately:

- **2009–2010:** 6,865 additional exact copies
- **2010–2011:** 5,268 additional exact copies

This initially suggested **12,133 additional repeated rows** across the two periods.

However, this was not the final duplicate count.

### Cross-period overlap

The date ranges of the two source sheets were then checked:

- **2009–2010:** 1 December 2009 to 9 December 2010
- **2010–2011:** 1 December 2010 to 9 December 2011

This revealed that the two sheets overlap during part of **December 2010**.

An exact comparison across all eight original fields identified **22,523 rows occurring in both source tables**.

Because some records can be duplicated both within an individual sheet and across the overlapping sheets, the within-sheet duplicate counts and cross-sheet overlap cannot simply be added together.

### Final combined duplicate validation

Both source tables were combined using `UNION ALL`, and `ROW_NUMBER()` was applied across all eight original fields.

This identified:

- **Combined raw rows:** 1,067,371
- **Excess exact copies:** 34,335
- **Deduplicated rows:** 1,033,036

The final authoritative duplicate count is therefore **34,335 excess exact copies** across the combined dataset.

### Treatment

The raw source tables were preserved unchanged.

A separate cleaned table was created in SQL, retaining one copy of each exact transaction record and excluding only the additional exact copies.

This produced the `retail_clean` table containing **1,033,036 rows**.

This approach preserves the original data while preventing exact repeated records, including those caused by the overlapping source periods, from inflating the analysis.

---


## Current Data Quality Decisions

| Issue | Status | Current Approach |
|---|---|---|
| Negative quantities | Investigated | Separate confirmed cancellations from non-standard negative adjustments |
| Negative prices | Investigated | Keep financial adjustments separate from merchandise sales |
| Zero prices | Investigated | Handle according to transaction pattern rather than applying one rule |
| Missing Customer ID | Investigated | Retain where customer identity is not required |
| Missing Description | Investigated | Retain where useful and do not fill missing descriptions without evidence |
| Exact duplicates | Validated in SQL | Preserve raw data but exclude additional exact copies from the analysis-ready dataset |
---

## Next Step

The main data quality issues have now been investigated and documented.

The next stage will define the SQL transformation rules used to create an analysis-ready dataset while preserving the original raw tables.

The transformation stage will include:

- Removing additional exact duplicate copies while retaining one occurrence
- Classifying standard sales, confirmed cancellations, and non-standard adjustment records
- Keeping financial adjustments separate from merchandise sales
- Preserving records with missing Customer IDs where customer-level analysis is not required
- Creating a consistent base for sales, product, customer, market, and time-based analysis

These transformation rules will be implemented in SQL so the preparation process remains reproducible and traceable.
