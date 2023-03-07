package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.Orders;

@Repository
public interface OrdersRepository extends JpaRepository<Orders, String> {

    @Query(value = "SELECT m.* FROM orders m WHERE ((gecko_id like '%HOUR%') or (gecko_id like '%MINUTE_30%')) AND (TO_CHAR(created_at, 'YYYY-MM-DD HH24:mm') < TO_CHAR(NOW() - interval '2 hours', 'YYYY-MM-DD HH24:mm'))  ", nativeQuery = true)
    public List<Orders> clearTrash();

    @Query(value = "SELECT * FROM public.orders mst where (mst.gecko_id like '%DAY%')    ORDER BY mst.insert_time  ", nativeQuery = true)
    public List<Orders> getTrend_DayList();

    @Query(value = "SELECT * FROM public.orders mst where (mst.gecko_id like '%DAY%')        AND (COALESCE(mst.note, '') <> '')  ORDER BY mst.insert_time ", nativeQuery = true)
    public List<Orders> getSwitchTrend_DayList();

    @Query(value = "SELECT * FROM public.orders det where (det.gecko_id like '%MINUTE%')  AND (COALESCE(det.note, '') <> '') AND (COALESCE(det.trend, '') <> '') ORDER BY det.insert_time ", nativeQuery = true)
    public List<Orders> getTrend_30mList();

    // -------------------------------------------------------------
    //, 'GOLD_HOUR_4', 'SILVER_HOUR_4', 'FR40_HOUR_4', 'US30_HOUR_4', 'US500_HOUR_4', 'UK100_HOUR_4', 'AU200_HOUR_4', 'J225_HOUR_4'
    @Query(value = " SELECT * FROM ( "
            + "     SELECT * FROM orders det  "
            + "      WHERE (COALESCE(det.note, '') LIKE '%Ma34568%')  "
            + "      AND det.gecko_id IN ('GOLD_HOUR', 'SILVER_HOUR', 'FR40_HOUR', 'US30_HOUR', 'US500_HOUR', 'UK100_HOUR', 'AU200_HOUR', 'J225_HOUR') "
            + " ) abc  "
            + " ORDER BY abc.gecko_id ", nativeQuery = true)
    public List<Orders> getH1ListNo1();

    @Query(value = " SELECT * FROM ( "
            + "     SELECT * FROM orders det  "
            + "      WHERE (COALESCE(det.note, '') like '%Ma34568%') and (det.gecko_id like '%_HOUR')  "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_DAY'   ) AND (COALESCE(mst.note, '') like '%Ma34568%')  ) "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_HOUR_4') AND (COALESCE(mst.note, '') like '%Ma34568%')  ) "
            + " ) abc  "
            + " ORDER BY abc.gecko_id ", nativeQuery = true)
    public List<Orders> getH1ListNo5();

    @Query(value = " SELECT * FROM ( "
            + "     SELECT * FROM orders det  "
            + "      WHERE (COALESCE(det.note, '') like '%Ma34568%') and (det.gecko_id like '%_HOUR')  "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_DAY'))   "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_HOUR_4') AND (COALESCE(mst.note, '') like '%Ma34568%')  )   "
            + " ) abc  "
            + " ORDER BY abc.gecko_id ", nativeQuery = true)
    public List<Orders> getH1ListNo6();

    @Query(value = " SELECT * FROM ( "
            + "     SELECT * FROM orders det  "
            + "      WHERE (COALESCE(det.note, '') like '%Ma34568%') and (det.gecko_id like '%_HOUR')  "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_DAY'))   "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_HOUR_4') AND (COALESCE(mst.note, '') <> '')  )   "
            + " ) abc  "
            + " ORDER BY abc.gecko_id ", nativeQuery = true)
    public List<Orders> getH1ListNo7();

    @Query(value = " SELECT * FROM ( "
            + "     SELECT * FROM orders det  "
            + "      WHERE (COALESCE(det.note, '') like '%Ma34568%') and (det.gecko_id like '%_HOUR')  "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_DAY'))   "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_HOUR_4'))   "
            + " ) abc  "
            + " ORDER BY abc.gecko_id ", nativeQuery = true)
    public List<Orders> getH1ListNo8();

    @Query(value = " SELECT * FROM ( "
            + "     SELECT * FROM orders det  "
            + "      WHERE (COALESCE(det.note, '') like '%Ma34568%') and (det.gecko_id like '%_HOUR')  "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_DAY'))   "
            + " ) abc  "
            + " ORDER BY abc.gecko_id ", nativeQuery = true)
    public List<Orders> getH1ListNo9();

    @Query(value = " SELECT * FROM orders det  "
            + " WHERE ((COALESCE(det.note, '') like '%Reversal%') or (COALESCE(det.note, '') like '%Adjustingand%')) and (det.gecko_id like '%_HOUR') "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR', '_DAY'))   "
            + " ORDER BY gecko_id ", nativeQuery = true)
    public List<Orders> getH1ListNo10();

    @Query(value = " SELECT * FROM ( "
            + "     SELECT * FROM orders det  "
            + "      WHERE (COALESCE(det.note, '') like '%Ma34568%') and (det.gecko_id like '%_HOUR_4')  "
            + "      AND det.trend = (SELECT mst.trend FROM orders mst WHERE mst.gecko_id = REPLACE(det.gecko_id, '_HOUR_4', '_DAY'))   "
            + " ) abc  "
            + " ORDER BY abc.gecko_id ", nativeQuery = true)
    public List<Orders> getH4ByMa34568List();

    @Query(value = " SELECT * FROM orders det  "
            + " WHERE (COALESCE(det.note, '') like '%Ma34568%') and (det.gecko_id like '%_DAY') "
            + " ORDER BY gecko_id ", nativeQuery = true)
    public List<Orders> getD1List();

    @Query(value = "SELECT * FROM public.orders det where (det.gecko_id like '%_HOUR_4')     ORDER BY det.gecko_id ", nativeQuery = true)
    public List<Orders> getAllH4();
    // =======================================================================

    @Query(value = "  SELECT * FROM orders det  "
            + "  WHERE (det.gecko_id like 'CRYPTO_%_1h') AND (COALESCE(det.note, '') like '%Ma34568%') AND det.trend = 'BUY' "
            + "   AND det.trend = (SELECT trend FROM orders mst WHERE mst.gecko_id = REPLACE (det.gecko_id, '_1h', '_1d')) "
            + "   AND det.trend = (SELECT trend FROM orders mst WHERE mst.gecko_id = REPLACE (det.gecko_id, '_1h', '_4h')) "
            + "  ORDER BY (case when (select count(symbol) from binance_futures where symbol = REPLACE(REPLACE(REPLACE(REPLACE(det.gecko_id, '_1h', ''), '_4h', ''), '_1d', ''), 'CRYPTO_', '')) > 0 then 1 else 2 end) asc ", nativeQuery = true)
    public List<Orders> getCrypto_H1();

    @Query(value = "  SELECT * FROM orders det  "
            + "  WHERE (det.gecko_id like 'CRYPTO_%_4h') AND (COALESCE(det.note, '') like '%Ma34568%') AND det.trend = 'BUY' "
            + "   AND det.trend = (SELECT trend FROM orders mst WHERE mst.gecko_id = REPLACE (det.gecko_id, '_4h', '_1d')) "
            + "  ORDER BY (case when (select count(symbol) from binance_futures where symbol = REPLACE(REPLACE(REPLACE(REPLACE(det.gecko_id, '_1h', ''), '_4h', ''), '_1d', ''), 'CRYPTO_', '')) > 0 then 1 else 2 end) asc ", nativeQuery = true)
    public List<Orders> getCrypto_H4();

    @Query(value = "  SELECT * FROM orders det  "
            + "  WHERE (det.gecko_id like 'CRYPTO_%_1d') AND (COALESCE(det.note, '') like '%Ma34568%') AND det.trend = 'BUY' "
            + "  ORDER BY (case when (select count(symbol) from binance_futures where symbol = REPLACE(REPLACE(REPLACE(REPLACE(det.gecko_id, '_1h', ''), '_4h', ''), '_1d', ''), 'CRYPTO_', '')) > 0 then 1 else 2 end) asc ", nativeQuery = true)
    public List<Orders> getCrypto_D1();

    // =======================================================================
    // delete:
    @Query(value = " SELECT * FROM orders det "
            + " WHERE (det.gecko_id like '%HOUR') AND (COALESCE(det.note, '') <> '') "
            + "       AND det.trend = (SELECT trend FROM orders mst WHERE mst.gecko_id = REPLACE (det.gecko_id, '_HOUR', '_HOUR_4')) "
            + " ORDER BY det.gecko_id ", nativeQuery = true)
    public List<Orders> getTrend_H1EqualH4List();

    @Query(value = " SELECT * FROM orders det "
            + "WHERE (det.gecko_id like '%HOUR') AND (COALESCE(det.note, '') <> '') "
            + " AND det.gecko_id in (SELECT REPLACE(mst.gecko_id, '_HOUR_4', '_HOUR') FROM orders mst WHERE (COALESCE(mst.note, '') <> '') and ((mst.gecko_id like '%_HOUR_4') or (mst.gecko_id like '%_DAY')))  "
            + " order by det.gecko_id ", nativeQuery = true)
    public List<Orders> getTrend_Reversal_Today();

    @Query(value = " SELECT * FROM orders det where 1=1 "
            + " and det.gecko_id in (SELECT symbol FROM prepare_orders where (gecko_id like concat(TO_CHAR(NOW(), 'yyyyMMdd'), '%CRYPTO_%'))) "
            + " order by det.gecko_id ", nativeQuery = true)
    public List<Orders> getCrypto_Reversal_Today();

    // --------------------------------------------------------

    @Query(value = " SELECT * FROM orders det "
            + " WHERE (det.gecko_id like '%HOUR_4') AND (COALESCE(det.note, '') <> '') "
            + "       AND det.trend = (SELECT trend FROM orders mst WHERE mst.gecko_id = REPLACE (det.gecko_id, '_HOUR_4', '_DAY')) "
            + " ORDER BY det.gecko_id ", nativeQuery = true)
    public List<Orders> getTrend_Reversal_H4today();

}
