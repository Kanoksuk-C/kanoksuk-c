WITH oms AS (
  SELECT 
  Airport_Tag,
  Business_Type,
  order_booking_at_MYT AS Booking_Date,
  order_id,
  order_status,
  order_item_booking_status,
  Order_MYR_GMV,
  unique_user,
  unique_booking,
  order_item_pickup_longitude AS longitude,
  order_item_pickup_latitude AS latitude,
  CAST(order_item_ride_distance AS INT64)/1000 AS order_item_ride_distance
  FROM `airasia-oms-prd.oms_master.oms_MasterTransactionData_Ride`
  WHERE Market = 'my'
    -- AND Airport_Tag = 'No'
    AND Country = 'Malaysia'
    -- AND business_type = 'B2C'
    AND order_item_business_type = 'e-hailing'
    AND order_booking_at_MYT BETWEEN '2024-01-01' and CURRENT_DATE()
),

final as (
  SELECT oms.*, name AS ZoneName,
  CASE WHEN order_item_ride_distance between 0 and 5 then 'a.0-5km'
    WHEN order_item_ride_distance between 6 and 10 then 'b.6-10km'
    WHEN order_item_ride_distance between 11 and 15 then 'c.11-15km'
    WHEN order_item_ride_distance between 16 and 20 then 'd.16-20km'
    WHEN order_item_ride_distance between 21 and 25 then 'e.21-25km'
    WHEN order_item_ride_distance between 26 and 30 then 'f.26-30km'
    WHEN order_item_ride_distance between 31 and 35 then 'g.31-35km'
    WHEN order_item_ride_distance between 36 and 40 then 'h.36-40km'
    WHEN order_item_ride_distance between 41 and 45 then 'i.41-45km'
    WHEN order_item_ride_distance between 46 and 50 then 'j.46-50km'
    WHEN order_item_ride_distance >50 then 'k.More than 50km'
    ELSE null END AS Distance_Range,
  CASE WHEN order_myr_gmv BETWEEN 0 AND 5 THEN 'a.MYR 0-5'
	  WHEN order_myr_gmv BETWEEN 6 AND 10 THEN 'b.MYR 6-10'
    WHEN order_myr_gmv BETWEEN 11 AND 15 THEN 'c.MYR 11-15'
    WHEN order_myr_gmv BETWEEN 16 AND 20 THEN 'd.MYR 16-20'
    WHEN order_myr_gmv BETWEEN 21 AND 25 THEN 'e.MYR 21-25'
    WHEN order_myr_gmv BETWEEN 26 AND 30 THEN 'f.MYR 26-30'
    WHEN order_myr_gmv BETWEEN 31 AND 35 THEN 'g.MYR 31-35'
    WHEN order_myr_gmv BETWEEN 36 AND 40 THEN 'h.MYR 36-40'
    WHEN order_myr_gmv BETWEEN 41 AND 45 THEN 'i.MYR 41-45'
    WHEN order_myr_gmv BETWEEN 46 AND 50 THEN 'j.MYR 46-50'
    WHEN order_myr_gmv > 50 THEN 'k.More than MYR 50'
    ELSE NULL END AS GMV_Range
  FROM oms
  INNER JOIN `airasia-ecomdata-dev.GEOSPATIAL_COMMON.my_autosurge_zones`
  ON ST_CONTAINS(geometry, ST_GEOGPOINT(longitude, latitude))
  WHERE zonegroup = 'KV2_Hotspot'
)

SELECT *
FROM final
ORDER BY Booking_Date