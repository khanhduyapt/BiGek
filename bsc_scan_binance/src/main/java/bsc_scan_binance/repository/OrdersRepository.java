package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.Orders;

@Repository
public interface OrdersRepository extends JpaRepository<Orders, String> {

    @Query(value = "SELECT m.* FROM orders m WHERE ((gecko_id like '%HOUR%') or (gecko_id like '%MINUTE_30%') ) AND (TO_CHAR(created_at, 'YYYY-MM-DD HH24:mm') < TO_CHAR(NOW() - interval '2 hours', 'YYYY-MM-DD HH24:mm'))  ", nativeQuery = true)
    public List<Orders> clearTrash();

    @Query(value = "SELECT * FROM public.orders mst where (gecko_id like '%DAY') ORDER BY trend, gecko_id  ", nativeQuery = true)
    public List<Orders> getTrend_DayList();

    @Query(value = "SELECT * FROM public.orders det where (det.gecko_id like '%HOUR_4') and (det.note <> '') and det.gecko_id = (select REPLACE(mst.gecko_id, 'DAY', 'HOUR_4') from orders mst where det.trend=mst.trend and mst.gecko_id=REPLACE(det.gecko_id, 'HOUR_4', 'DAY')) ORDER BY det.trend, det.gecko_id ", nativeQuery = true)
    public List<Orders> getTrend_H4List();

    @Query(value = "SELECT * FROM public.orders det where (det.gecko_id like '%MINUTE_30')   and (det.note <> '') and det.gecko_id = (select REPLACE(mst.gecko_id, 'DAY', 'MINUTE_30')   from orders mst where det.trend=mst.trend and mst.gecko_id=REPLACE(det.gecko_id, 'MINUTE_30'  , 'DAY')) ORDER BY det.trend, det.gecko_id  ", nativeQuery = true)
    public List<Orders> getTrend_30mList();
}
