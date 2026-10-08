CREATE OR REPLACE VIEW `data-analytics-mate.Students.final_metrics_view` AS
WITH
-- account_items це CTE в якій я зібрав основну частину значень та розрахував метрику account_cnt 
account_items AS (
  SELECT
    s.date,
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed,
    COUNT(DISTINCT acs.account_id) AS account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg
  FROM `data-analytics-mate.DA.account_session` acs
  JOIN `data-analytics-mate.DA.session` s
    ON acs.ga_session_id = s.ga_session_id
  JOIN `data-analytics-mate.DA.session_params` sp
    ON acs.ga_session_id = sp.ga_session_id
  JOIN `data-analytics-mate.DA.account` ac
    ON acs.account_id = ac.id
  GROUP BY date, country, send_interval, is_verified, is_unsubscribed
),
-- email_items тут я зробив базовий розрахунок для подальшої роботи з значеннями
email_items AS (
  SELECT
    DATE_ADD(s.date, INTERVAL ems.sent_date DAY) AS date,
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed,
    0 AS account_cnt,
    COUNT(DISTINCT ems.id_message) AS sent_msg,
    COUNT(DISTINCT emo.id_message) AS open_msg,
    COUNT(DISTINCT emv.id_message) AS visit_msg
  FROM `data-analytics-mate.DA.account_session` acs
  JOIN `data-analytics-mate.DA.session` s
    ON acs.ga_session_id = s.ga_session_id
  JOIN `data-analytics-mate.DA.session_params` sp
    ON acs.ga_session_id = sp.ga_session_id
  JOIN `data-analytics-mate.DA.account` ac
    ON acs.account_id = ac.id
  JOIN `data-analytics-mate.DA.email_sent` ems
    ON acs.account_id = ems.id_account
  LEFT JOIN `data-analytics-mate.DA.email_open` emo
    ON ems.id_message = emo.id_message
  LEFT JOIN `data-analytics-mate.DA.email_visit` emv
    ON ems.id_message = emv.id_message
  GROUP BY date, country, send_interval, is_verified, is_unsubscribed
),
-- тут я об'єднав всі зібрані дані з таблиць account_items та email_items, це було зроблено для зручності і подальшої роботи з основними показниками
combined_metrics AS (
  SELECT *
  FROM account_items
  UNION ALL
  SELECT *
  FROM email_items
),
-- тут іде агрегація після UNION
aggregated_metrics AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg
  FROM combined_metrics
  GROUP BY date, country, send_interval, is_verified, is_unsubscribed
),
-- тут знайшов перші показники total, виділив їх в окремий CTE для зручної роботи з rank_total
totals_metrics AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt
  FROM aggregated_metrics
),
-- тут зробив rank_total, для того щоб в основному запросі було зручно зробити WHERE з булевими параметрами
ranked_metrics AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    total_country_account_cnt,
    total_country_sent_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
  FROM totals_metrics
)




SELECT *
FROM ranked_metrics
WHERE rank_total_country_account_cnt <= 10 OR rank_total_country_sent_cnt <= 10


