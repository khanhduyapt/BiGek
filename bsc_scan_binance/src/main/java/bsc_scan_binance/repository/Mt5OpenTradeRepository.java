package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.Mt5OpenTradeEntity;

@Repository
public interface Mt5OpenTradeRepository extends JpaRepository<Mt5OpenTradeEntity, String> {
    List<Mt5OpenTradeEntity> findAllBySymbolOrderByCompanyAsc(String symbol);

    List<Mt5OpenTradeEntity> findAllBySymbolAndTypeOrderBySymbolAsc(String symbol, String type);

    List<Mt5OpenTradeEntity> findAllByCompanyOrderBySymbolAscTicketAsc(String company);

    List<Mt5OpenTradeEntity> findAllByCompanyOrderByCommentAscSymbolAsc(String company);

    List<Mt5OpenTradeEntity> findAllByOrderByCompanyAscSymbolAsc();
}
