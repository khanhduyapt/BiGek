package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.Orders;

@Repository
public interface OrdersRepository extends JpaRepository<Orders, String> {

    @Query(value = "SELECT m.* FROM orders m WHERE gecko_id like '%HOUR%' ", nativeQuery = true)
    public List<Orders> clearTrash();

    @Query(value = "SELECT m.* FROM ( "
            + "    SELECT * FROM public.orders mst where (gecko_id like '%DAY%') and gecko_id = (select REPLACE(gecko_id, 'HOUR_4', 'DAY') from orders where gecko_id= REPLACE(mst.gecko_id, 'DAY', 'HOUR_4') and (note <> '') )   "
            + "    UNION "
            + "    SELECT * FROM public.orders where (gecko_id like '%HOUR_4') and (note <> '') "
            + " ) m "
            + " ORDER BY gecko_id ", nativeQuery = true)
    public List<Orders> swithTrendDayList();

    @Query(value = "SELECT m.* FROM orders m where (gecko_id like '%HOUR_4') order by gecko_id ", nativeQuery = true)
    public List<Orders> swithTrendH4List();

    @Query(value = "SELECT m.* FROM orders m where (gecko_id like '%HOUR') and (note <> '') order by gecko_id ", nativeQuery = true)
    public List<Orders> swithTrendH1List();
}
