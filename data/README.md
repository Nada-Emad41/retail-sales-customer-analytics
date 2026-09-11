# Data

This project uses the **Online Retail II** dataset from the UCI Machine Learning Repository.

## Source

UCI Machine Learning Repository — Online Retail II

The dataset contains transaction-level retail data from a UK-based non-store online retailer covering the period from December 2009 to December 2011.

The original workbook contains two reporting periods:

- 2009–2010
- 2010–2011

Together, the source files contain **1,067,371 transaction rows** before cleaning.

## Dataset Structure

The original fields used in this project are:

- Invoice
- StockCode
- Description
- Quantity
- InvoiceDate
- Price
- Customer ID
- Country

Each row represents a product line within an invoice rather than a complete customer order.

## Data Availability

The raw dataset is not stored directly in this repository.

Instead, the original data can be obtained from the UCI Machine Learning Repository. Keeping the source data separate avoids duplicating a large public dataset while allowing the analysis to remain reproducible through the SQL scripts provided in this repository.

## Processing

The original data was imported into PostgreSQL and validated before analysis.

The processing workflow includes:

1. Source row-count validation
2. Cross-period overlap investigation
3. Exact duplicate detection
4. Deduplication
5. Transaction classification
6. Sales, product, market, customer, and cancellation analysis

The SQL used for these steps is available in the [`sql`](../sql/) folder.
