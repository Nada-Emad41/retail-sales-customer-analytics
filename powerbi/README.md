# Power BI Dashboard

This folder contains the Power BI reporting layer for the **Retail Sales & Customer Performance Analytics** project.

The dashboard was built after completing the data-quality investigation and SQL analysis so that the visuals are based on validated business definitions rather than raw transactional data alone.

## Dashboard Structure

The report is organized into three pages, each designed to answer a different set of business questions.

### 1. Executive Overview

Provides a high-level view of business performance, including:

- Gross Revenue
- Cancellation Value
- Net Revenue
- Cancellation Impact %
- Average Order Value
- Unique Customers
- Total Orders
- Monthly revenue and order trends
- Top countries by net revenue
- Top products by net revenue

Country and month filters allow the report to be explored across different markets and reporting periods.

### 2. Sales & Product Performance

Focuses on how revenue and product performance change over time.

The page includes:

- Monthly Net Revenue Trend
- Monthly Cancellation Impact %
- Top Products by Net Revenue
- Top Products by Sales Volume

Revenue and sales volume are shown separately because a high-volume product is not necessarily a high-revenue product.

December 2009 and December 2011 are identified as partial reporting periods and should therefore be interpreted carefully when comparing monthly performance.

### 3. Customer & Market Insights

Examines customer behavior and geographic performance.

The page includes:

- Unique Customers
- Repeat Customers
- Repeat Customer Rate
- UK Revenue Share
- Top 10 Customer Revenue Share
- Top Customers by Net Revenue
- Top International Markets by Net Revenue
- Cancellation Impact % by Major Market

Customer-level analysis uses identified customers only where customer identification is required. Transactions with missing customer IDs are retained where they remain valid for broader sales analysis.

## Data Model

The Power BI model follows a star-schema approach built around a central sales fact table and supporting dimensions for:

- Date
- Product
- Customer
- Country

This structure separates transactional measures from descriptive attributes and supports consistent filtering across the report.

## Key Measures

The report uses DAX measures for business KPIs including:

- Gross Revenue
- Cancellation Value
- Net Revenue
- Cancellation Impact %
- Total Orders
- Unique Customers
- Average Order Value
- Quantity Sold
- Repeat Customers
- Repeat Customer Rate
- UK Revenue Share
- Top 10 Customer Revenue Share

The KPI definitions were reconciled with the SQL analysis before being used in the final dashboard.

## Important Reporting Notes

The source data contains cancellations, missing customer identifiers, duplicate records, non-standard adjustments, zero-price transactions, and inconsistent product descriptions.

These records were investigated before analytical rules were applied. The dashboard therefore does not treat every raw transaction as an ordinary sale.

For the full investigation and validation process, see the project documentation and SQL scripts in the main repository.

## Dashboard Screenshots

### Executive Overview

![Executive Overview](/powerbi/screenshots/executive_overview.png)

### Sales & Product Performance

![Sales & Product Performance](/powerbi/screenshots/sales_product_performance.png)

### Customer & Market Insights

![Sales & Product Performance](/powerbi/screenshots/sales_product_performance.png)
