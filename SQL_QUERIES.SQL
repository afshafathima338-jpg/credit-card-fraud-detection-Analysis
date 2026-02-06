CREDIT CARD FRAUD DETECTION - SQL ANALYSIS
 5 Production Queries for Pattern Detection
QUERY 1: TRANSACTION VELOCITY & RISK FLAGGING
Purpose: Identifies suspicious rapid transaction patterns
SELECT 
  Transaction_id,
  Time,
  Amount,
  Is_Fraud,
  Hour,
  Amount_Bin,
  CASE 
   WHEN Hour  BETWEEN 2 AND 5 AND Amount > 200 THEN 'HIGH_VELOCITY_RISK'
    WHEN  Hour BETWEEN 2 AND 5 THEN 'ELEVATED_RISK'
    WHEN Amount > 500 THEN 'HIGH_AMOUNT_RISK'
    ELSE 'NORMAL'
  END AS risk_flag
FROM "Transaction"
WHERE Hour BETWEEN 0 AND 5 OR Amount > 300
ORDER BY Time
LIMIT 100;
QUERY 2: AMOUNT ANOMALY DETECTION
Purpose: Flags unusually high transaction amounts
SELECT 
  Transaction_id,
  Time,
  Is_Fraud,
  Hour,
  Amount_Bin,
  CASE 
    WHEN Amount_Bin = '$1000+' THEN 'EXTREME_RISK'
    WHEN Amount_Bin = '$501-1000' THEN 'HIGH_RISK'
    WHEN Amount_Bin = '$251-500' THEN 'ELEVATED_RISK'
    ELSE 'NORMAL'
  END as risk_level,
  CASE 
    WHEN Is_Fraud = 1 THEN 'FRAUD'
    ELSE 'LEGITIMATE'
  END as actual_Fraud
FROM "Transaction"
WHERE Amount_Bin IN ('$501-1000', '$1000+')
ORDER BY Transaction_id
LIMIT 100;
QUERY 3: TEMPORAL FRAUD PATTERN ANALYSIS
 Purpose: Calculate fraud rate by hour of day
SELECT 
  Hour,
  COUNT(*) as total_transactions,
  SUM(Is_Fraud) as fraud_count,
  COUNT(*) - SUM(Is_Fraud) as legitimate_count,
  ROUND((SUM(Is_Fraud) * 100.0) / COUNT(*), 2) as fraud_rate_pct,
  CASE 
    WHEN (SUM(Is_Fraud) * 1.0) / COUNT(*) > 0.015 THEN 'HIGH_RISK_HOUR'
    WHEN (SUM(Is_Fraud) * 1.0) / COUNT(*) > 0.0025 THEN 'ELEVATED_RISK'
    ELSE 'NORMAL_RISK'
  END as risk_category
FROM "Transaction"
GROUP BY Hour
ORDER BY fraud_rate_pct DESC;
QUERY 4: AMOUNT-BASED RISK SEGMENTATION
Purpose: Analyze fraud rates across amount ranges
SELECT 
  Amount_Bin,
  COUNT(*) as total_transactions,
  SUM(Is_Fraud) as fraud_count,
  COUNT(*) - SUM(Is_Fraud) as legitimate_count,
  ROUND((SUM(Is_Fraud) * 100.0) / COUNT(*), 3) as fraud_rate_pct,
  CASE 
    WHEN (SUM(Is_Fraud) * 1.0) / COUNT(*) > 0.003 THEN 'HIGH_RISK'
    WHEN (SUM(Is_Fraud) * 1.0) / COUNT(*) > 0.002 THEN 'ELEVATED_RISK'
    ELSE 'NORMAL_RISK'
  END as risk_tier
FROM "Transaction"
GROUP BY Amount_Bin
ORDER BY fraud_rate_pct DESC;
QUERY 5: FRAUD FINANCIAL IMPACT SUMMARY
Purpose: Calculate comprehensive business metrics
SELECT 
  'Overall Statistics' as metric_category,
  COUNT(*) as total_transactions,
  SUM(Is_Fraud) as total_fraud_cases,
  COUNT(*) - SUM(Is_Fraud) as total_legitimate,
  ROUND((SUM(Is_Fraud) * 100.0) / COUNT(*), 3) as fraud_rate_pct
FROM "Transaction";

RESULTS SUMMARY:
-- - 284,807 transactions analyzed
-- - 492 fraud cases identified (0.17% rate)
-- - Hour 2 shows 10x elevated fraud rate
-- - $501-1000 range exhibits 2.5x higher risk
-- - $60,128 total fraud loss (2-day period)


