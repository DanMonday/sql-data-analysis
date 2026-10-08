# SQL Data Analysis

## Project Description

Analysis of e-commerce data using SQL in Google BigQuery.

The project focuses on analyzing account creation and email activity across different countries and user segments.

## Objectives

- Analyze account creation dynamics
- Analyze email activity, including sent, opened, and visited emails
- Compare user activity across countries
- Segment users by email sending interval, account verification status, and subscription status
- Identify countries with the highest number of created accounts and sent emails

## Data Dimensions

The analysis is performed across the following dimensions:

- `date`
- `country`
- `send_interval`
- `is_verified`
- `is_unsubscribed`

## Metrics

### Account Metrics

- `account_cnt` — number of created accounts

### Email Metrics

- `sent_msg` — number of sent emails
- `open_msg` — number of opened emails
- `visit_msg` — number of email visits

### Additional Metrics

- `total_country_account_cnt` — total number of created accounts by country
- `total_country_sent_cnt` — total number of sent emails by country
- `rank_total_country_account_cnt` — country ranking by total created accounts
- `rank_total_country_sent_cnt` — country ranking by total sent emails

## SQL Techniques

- Common Table Expressions (CTEs)
- JOINs
- UNION ALL
- Aggregate Functions
- Window Functions
- DENSE_RANK()
- Data Aggregation
- GROUP BY

## Project Structure

- `analysis.sql` — SQL query used to create the final dataset and calculate analytical metrics.

## Tools

- SQL
- Google BigQuery

## Visualization

The results were visualized in Looker Studio.

[View the Looker Studio dashboard](https://datastudio.google.com/u/0/reporting/dae3180c-3b23-4864-b516-22d3125ffb72/page/tEnnC)

