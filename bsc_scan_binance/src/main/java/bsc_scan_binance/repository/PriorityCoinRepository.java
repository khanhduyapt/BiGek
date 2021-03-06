package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.PriorityCoin;

@Repository
public interface PriorityCoinRepository extends JpaRepository<PriorityCoin, String> {
    public List<PriorityCoin> findAllByCandidateOrderByVmcDesc(Boolean is_candidate);

    public List<PriorityCoin> findAllByMute(Boolean mute);

    public List<PriorityCoin> findAllByInspectModeAndGoodPriceAndMuteOrderByVmcDesc(Boolean inspectMode,
            Boolean goodPrice, Boolean mute);

    public List<PriorityCoin> findAllByPredictOrderByVmcDesc(Boolean predict);

    @Query("SELECT m FROM PriorityCoin m WHERE m.symbol = :symbol")
    List<PriorityCoin> searchBySymbol(@Param("symbol") String symbol);

}
