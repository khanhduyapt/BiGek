package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.Orders;

@Repository
public interface OrdersRepository extends JpaRepository<Orders, String> {

    @Query(value = "SELECT m.* FROM orders m WHERE (gecko_id like '%HOUR%') AND (TO_CHAR(created_at, 'YYYY-MM-DD HH24:mm') < TO_CHAR(NOW() - interval '1 hours', 'YYYY-MM-DD HH24:mm')) ", nativeQuery = true)
    public List<Orders> clearTrash();

    // and (note <> '')
    @Query(value = "SELECT m.* FROM ( "
            + "    SELECT * FROM public.orders mst where (gecko_id like '%DAY%') and gecko_id = (select REPLACE(gecko_id, 'HOUR_4', 'DAY') from orders where gecko_id= REPLACE(mst.gecko_id, 'DAY', 'HOUR_4') )   "
            + "    UNION                                                                                          "
            + "    SELECT * FROM public.orders where (gecko_id like '%HOUR_4') and (note <> '')                   "
            + " ) m                                                                                               "
            + " ORDER BY gecko_id     ", nativeQuery = true)
    public List<Orders> swithTrendDayAndH4List();

    @Query(value = "SELECT m.* FROM orders m where (gecko_id like '%HOUR_4') order by gecko_id ", nativeQuery = true)
    public List<Orders> getTrendH4List();

    @Query(value = "SELECT m.* FROM orders m where (gecko_id like '%DAY') order by gecko_id ", nativeQuery = true)
    public List<Orders> getTrendDayList();
}
