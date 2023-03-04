package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.FundingHistory;
import bsc_scan_binance.entity.FundingHistoryKey;

@Repository
public interface FundingHistoryRepository extends JpaRepository<FundingHistory, FundingHistoryKey> {

    @Query(value = "SELECT m.* FROM funding_history m WHERE event_time like 'FIBO%' and note like '%Short%' and pumpdump", nativeQuery = true)
    public List<FundingHistory> findAllFiboShort();

    @Query(value = "SELECT m.* FROM funding_history m WHERE event_time like 'FIBO%' and note like '%Long2%' and pumpdump", nativeQuery = true)
    public List<FundingHistory> findAllFiboLong();

    public List<FundingHistory> findAllByPumpdump(boolean pumpdump);

    @Query(value = "select (case when count(gecko_id)> 0 then true else false end) from funding_history where gecko_id = :geckoid AND event_time = :event ", nativeQuery = true)
    boolean existsPumDump(@Param("geckoid") String geckoid, @Param("event") String event);

    @Query(value = "SELECT m.* FROM funding_history m WHERE (event_time not like '%1W1D%') and (event_time not like '%Pump_%') and (event_time not like '%DH4H1%') and (event_time not like concat('%CZ_KILL_LONG%', TO_CHAR(CURRENT_DATE, 'yyyy.mm.dd'), '%')) ", nativeQuery = true)
    public List<FundingHistory> clearTrash();

    @Query(value = "SELECT m.* FROM funding_history m WHERE event_time like '%DH4H1%STR%FX'", nativeQuery = true)
    public List<FundingHistory> findAllStartFX();

}