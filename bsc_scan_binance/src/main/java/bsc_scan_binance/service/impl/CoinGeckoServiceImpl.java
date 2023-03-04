package bsc_scan_binance.service.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Objects;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import bsc_scan_binance.BscScanBinanceApplication;
import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.BinanceVolumnDayKey;
import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.entity.GeckoVolumeMonth;
import bsc_scan_binance.entity.GeckoVolumeMonthKey;
import bsc_scan_binance.entity.GeckoVolumnDay;
import bsc_scan_binance.entity.GeckoVolumnDayKey;
import bsc_scan_binance.repository.CandidateCoinRepository;
import bsc_scan_binance.repository.GeckoVolumeMonthRepository;
import bsc_scan_binance.repository.GeckoVolumnDayRepository;
import bsc_scan_binance.request.CoinGeckoTokenRequest;
import bsc_scan_binance.service.CoinGeckoService;
import bsc_scan_binance.utils.Response;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CoinGeckoServiceImpl implements CoinGeckoService {

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private CandidateCoinRepository candidateCoinRepository;

    @Autowired
    private GeckoVolumeMonthRepository geckoVolumeMonthRepository;

    @Autowired
    private GeckoVolumnDayRepository geckoVolumnDayRepository;

    @Override
    public List<CandidateCoin> getList(String formBinance) {

        if ((BscScanBinanceApplication.app_flag == Utils.const_app_flag_all_coin)
                || (BscScanBinanceApplication.app_flag == Utils.const_app_flag_all_and_msg)) {

            return candidateCoinRepository.findAllByOrderBySymbolAsc();

        } else {

            return candidateCoinRepository.findCandidateCoinInBinanceFutures();

        }
    }

    public CandidateCoin loadData(String gecko_id) {
        try {
            final String url = "https://api.coingecko.com/api/v3/coins/" + gecko_id
                    + "?localization=false&tickers=true&market_data=true&community_data=false&developer_data=false&sparkline=false";

            RestTemplate restTemplate = new RestTemplate();

            @SuppressWarnings("unchecked")
            LinkedHashMap<String, Object> result = restTemplate.getForObject(url, LinkedHashMap.class);

            CandidateCoin coin = new CandidateCoin();
            GeckoVolumnDay geckoDay = new GeckoVolumnDay();

            Object id = Utils.getLinkedHashMapValue(result, Arrays.asList("id"));
            Object symbol = Utils.getLinkedHashMapValue(result, Arrays.asList("symbol"));
            Object name = Utils.getLinkedHashMapValue(result, Arrays.asList("name"));

            coin.setGeckoid(String.valueOf(id).toLowerCase());
            coin.setSymbol(String.valueOf(symbol).toUpperCase());
            coin.setName(String.valueOf(name));

            BigDecimal market_cap = Utils.getBigDecimal(
                    Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "market_cap", "usd")));
            BigDecimal total_volume = Utils.getBigDecimal(
                    Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "total_volume", "usd")));
            Object current_price = Utils.getLinkedHashMapValue(result,
                    Arrays.asList("market_data", "current_price", "usd"));
            Object priceChangePercentage24h = Utils.getLinkedHashMapValue(result,
                    Arrays.asList("market_data", "price_change_percentage_24h"));
            Object priceChangePercentage7d = Utils.getLinkedHashMapValue(result,
                    Arrays.asList("market_data", "price_change_percentage_7d"));
            Object priceChangePercentage14d = Utils.getLinkedHashMapValue(result,
                    Arrays.asList("market_data", "price_change_percentage_14d"));
            Object priceChangePercentage30d = Utils.getLinkedHashMapValue(result,
                    Arrays.asList("market_data", "price_change_percentage_30d"));

            Object ath_date = Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "ath_date"));

            coin.setMarketCap(market_cap);
            coin.setTotalVolume(total_volume);
            coin.setCurrentPrice(Utils.getBigDecimal(current_price));
            coin.setPriceChangePercentage24H(Utils.getBigDecimal(priceChangePercentage24h));
            coin.setPriceChangePercentage7D(Utils.getBigDecimal(priceChangePercentage7d));
            coin.setPriceChangePercentage14D(Utils.getBigDecimal(priceChangePercentage14d));
            coin.setPriceChangePercentage30D(Utils.getBigDecimal(priceChangePercentage30d));

            @SuppressWarnings("unchecked")
            LinkedHashMap<String, Object> ath_date_map = (LinkedHashMap<String, Object>) ath_date;
            int min_year = 2022;
            if (!Objects.equals(null, ath_date_map) && !CollectionUtils.isEmpty(ath_date_map)) {
                for (Object key : ath_date_map.keySet()) {
                    String value = String.valueOf(ath_date_map.get(key));
                    int year = Utils.getIntValue(value.substring(0, 4));
                    if (min_year > year && year > 0) {
                        min_year = year;
                    }
                }
            }

            if (Objects.equals(BigDecimal.ZERO, market_cap)) {
                coin.setVolumnDivMarketcap(BigDecimal.valueOf(0));

            } else {
                coin.setVolumnDivMarketcap(total_volume.divide(market_cap, 3, java.math.RoundingMode.CEILING));
            }

            Calendar calendar = Calendar.getInstance();
            String hh = Utils.convertDateToString("HH", calendar.getTime());
            geckoDay.setId(
                    new GeckoVolumnDayKey(String.valueOf(id).toLowerCase(), String.valueOf(symbol).toUpperCase(), hh));
            geckoDay.setTotalVolume(total_volume);
            geckoVolumnDayRepository.save(geckoDay);

            GeckoVolumeMonth month = new GeckoVolumeMonth();
            month.setId(new GeckoVolumeMonthKey(String.valueOf(id).toLowerCase(), "GECKO",
                    Utils.convertDateToString("dd", calendar.getTime())));
            month.setTotalVolume(total_volume);
            geckoVolumeMonthRepository.save(month);

            {
                Object total_supply = Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "total_supply"));
                Object max_supply = Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "max_supply"));
                Object circulating_supply = Utils.getLinkedHashMapValue(result,
                        Arrays.asList("market_data", "circulating_supply"));

                Object categories = Utils.getLinkedHashMapValue(result, Arrays.asList("categories"));
                String str_categories = "";
                if (categories instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<Object> ct = (List<Object>) categories;
                    for (Object obj : ct) {

                        String str_obj = String.valueOf(obj);
                        if (str_obj.toLowerCase().contains("ecosystem")) {
                            continue;
                        }

                        if (!Objects.equals("", str_categories)) {
                            str_categories += "; ";
                        }
                        str_categories += str_obj;
                    }
                }

                Object tickers = Utils.getLinkedHashMapValue(result, Arrays.asList("tickers"));
                String str_trade_url = "";
                if (tickers instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<Object> tk = (List<Object>) tickers;
                    for (Object obj : tk) {
                        Object trade_url = Utils.getLinkedHashMapValue(obj, Arrays.asList("trade_url"));
                        if (String.valueOf(trade_url).toLowerCase().contains("binance.com/en")) {
                            str_trade_url = String.valueOf(trade_url);
                            break;
                        }
                    }
                }

                coin.setCategory(str_categories);
                if (symbol.equals("juv")) {
                    boolean a = true;
                }
                // DeFi
                // Fan Token
                // L/B
                // Platform
                // Game
                // Web3
                String trend = "";
                String str_categories_low = String.valueOf(str_categories).toLowerCase();
                if (str_categories_low.contains("gaming")) {
                    trend = "Game";
                } else if (str_categories_low.contains("earn")) {
                    trend = "Earn";
                } else if (str_categories_low.contains("nft")) {
                    trend = "NFT";
                } else if (str_categories_low.contains("fan")) {
                    trend = "Fan";
                } else if (str_categories_low.contains("sports")) {
                    trend = "Fan";
                } else if (str_categories_low.contains("lending")) {
                    trend = "L/B";
                } else if (str_categories_low.contains("borrowing")) {
                    trend = "L/B";
                } else if (str_categories_low.contains("defi")) {
                    trend = "DeFi";
                } else if (str_categories_low.contains("dex")) {
                    trend = "DeFi";
                } else if (str_categories_low.contains("finance")) {
                    trend = "DeFi";
                } else if (str_categories_low.contains("network")) {
                    // trend = "Platform";
                } else if (str_categories_low.contains("platform")) {
                    // trend = "Platform";
                } else if (str_categories_low.contains("infrastructure")) {
                    // trend = "Platform";
                } else if (str_categories_low.contains("oracle")) {
                    trend = "DB";
                } else if (str_categories_low.contains("storage")) {
                    trend = "DB";
                } else if (str_categories_low.contains("protocol")) {
                    // trend = "Platform";
                } else if (str_categories_low.contains("web3")) {
                    trend = "Web3";
                } else if (str_categories_low.contains("metaverse")) {
                    // trend = "Metaverse";
                }

                String backer = "";
                if (String.valueOf(str_categories).toLowerCase().indexOf("launchpool") > 0) {
                    backer = "Binance";
                }
                coin.setTrend(trend + " (" + min_year + ")");
                coin.setUsdt(String.valueOf(symbol).toUpperCase() + "_USDT");
                coin.setBusd(String.valueOf(symbol).toUpperCase() + "_BUSD");
                coin.setTotalSupply(Utils.getBigDecimal(total_supply));
                coin.setMaxSupply(Utils.getBigDecimal(max_supply));
                coin.setCirculatingSupply(Utils.getBigDecimal(circulating_supply));
                coin.setBinanceTrade(str_trade_url);
                coin.setCoinGeckoLink("https://www.coingecko.com/en/coins/" + String.valueOf(id));
                coin.setBacker(backer);
            }

            candidateCoinRepository.save(coin);

            return coin;
        } catch (Exception e) {
        }

        return null;
    }

    @Override
    @Transactional
    public List<CandidateCoin> initCandidateCoin() {
        try {
            System.out.println("start CoinGeckoServiceImpl.initCandidateCoin   --->");

            // gecko_id symbol name

            List<CandidateCoin> list = new ArrayList<CandidateCoin>();
            list.add(new CandidateCoin("akropolis", "AKRO", "Akropolis"));
            list.add(new CandidateCoin("bella-protocol", "BEL", "Bella Protocol"));
            list.add(new CandidateCoin("unifi-protocol-dao", "UNFI", "Unifi Protocol DAO"));
            list.add(new CandidateCoin("auto", "AUTO", "Auto"));
            list.add(new CandidateCoin("moviebloc", "MBL", "MovieBloc"));
            list.add(new CandidateCoin("dodo", "DODO", "DODO"));
            list.add(new CandidateCoin("my-neighbor-alice", "ALICE", "My Neighbor Alice"));
            list.add(new CandidateCoin("stepn", "GMT", "STEPN"));
            list.add(new CandidateCoin("arpa-chain", "ARPA", "ARPA Chain"));
            list.add(new CandidateCoin("anchor-protocol", "ANC", "Anchor Protocol"));
            list.add(new CandidateCoin("reserve-rights-token", "RSR", "Reserve Rights Token"));
            list.add(new CandidateCoin("jasmycoin", "JASMY", "JasmyCoin"));
            list.add(new CandidateCoin("bakerytoken", "BAKE", "BakerySwap"));
            list.add(new CandidateCoin("og-fan-token", "OG", "OG Fan Token"));
            list.add(new CandidateCoin("as-roma-fan-token", "ASR", "AS Roma Fan Token"));
            list.add(new CandidateCoin("litentry", "LIT", "Litentry"));
            list.add(new CandidateCoin("alien-worlds", "TLM", "Alien Worlds"));
            list.add(new CandidateCoin("constitutiondao", "PEOPLE", "ConstitutionDAO"));
            list.add(new CandidateCoin("juventus-fan-token", "JUV", "Juventus Fan Token"));
            list.add(new CandidateCoin("mask-network", "MASK", "Mask Network"));
            list.add(new CandidateCoin("barnbridge", "BOND", "BarnBridge"));
            list.add(new CandidateCoin("linear", "LINA", "Linear"));
            list.add(new CandidateCoin("paris-saint-germain-fan-token", "PSG", "Paris Saint-Germain Fan Token"));
            list.add(new CandidateCoin("clover-finance", "CLV", "Clover Finance"));
            list.add(new CandidateCoin("mirror-protocol", "MIR", "Mirror Protocol"));
            list.add(new CandidateCoin("harvest-finance", "FARM", "Harvest Finance"));
            list.add(new CandidateCoin("wink", "WIN", "WINkLink"));
            list.add(new CandidateCoin("santos-fc-fan-token", "SANTOS", "Santos FC Fan Token"));
            list.add(new CandidateCoin("waves", "WAVES", "Waves"));
            list.add(new CandidateCoin("dydx", "DYDX", "dYdX"));
            list.add(new CandidateCoin("nuls", "NULS", "Nuls"));
            list.add(new CandidateCoin("tokocrypto", "TKO", "Tokocrypto"));
            list.add(new CandidateCoin("safepal", "SFP", "SafePal"));
            list.add(new CandidateCoin("troy", "TROY", "Troy"));
            list.add(new CandidateCoin("dforce-token", "DF", "dForce Token"));
            list.add(new CandidateCoin("dego-finance", "DEGO", "Dego Finance"));
            list.add(new CandidateCoin("wing-finance", "WING", "Wing Finance"));
            list.add(new CandidateCoin("aragon", "ANT", "Aragon"));
            list.add(new CandidateCoin("pnetwork", "PNT", "pNetwork"));
            list.add(new CandidateCoin("dia-data", "DIA", "DIA"));
            list.add(new CandidateCoin("waltonchain", "WTC", "Waltonchain"));
            list.add(new CandidateCoin("v-id-blockchain", "VIDT", "VIDT Datalink"));
            list.add(new CandidateCoin("tranchess", "CHESS", "Tranchess"));
            list.add(new CandidateCoin("chromaway", "CHR", "Chromia"));
            list.add(new CandidateCoin("origin-protocol", "OGN", "Origin Protocol"));
            list.add(new CandidateCoin("sushi", "SUSHI", "Sushi"));
            list.add(new CandidateCoin("celer-network", "CELR", "Celer Network"));
            list.add(new CandidateCoin("bluzelle", "BLZ", "Bluzelle"));
            list.add(new CandidateCoin("voxies", "VOXEL", "Voxies"));
            list.add(new CandidateCoin("keep3rv1", "KP3R", "Keep3rV1"));
            list.add(new CandidateCoin("league-of-kingdoms", "LOKA", "League of Kingdoms"));
            list.add(new CandidateCoin("tornado-cash", "TORN", "Tornado Cash"));
            list.add(new CandidateCoin("immutable-x", "IMX", "Immutable X"));
            list.add(new CandidateCoin("ramp", "RAMP", "RAMP"));
            list.add(new CandidateCoin("ampleforth-governance-token", "FORTH", "Ampleforth Governance"));
            list.add(new CandidateCoin("tellor", "TRB", "Tellor"));
            list.add(new CandidateCoin("frontier-token", "FRONT", "Frontier"));
            list.add(new CandidateCoin("dent", "DENT", "Dent"));
            list.add(new CandidateCoin("superfarm", "SUPER", "SuperFarm"));
            list.add(new CandidateCoin("just", "JST", "JUST"));
            list.add(new CandidateCoin("tokenclub", "TCT", "TokenClub"));
            list.add(new CandidateCoin("beta-finance", "BETA", "Beta Finance"));
            list.add(new CandidateCoin("aurora-dao", "IDEX", "IDEX"));
            list.add(new CandidateCoin("concentrated-voting-power", "CVP", "PowerPool Concentrated Voting Power"));
            list.add(new CandidateCoin("bonfida", "FIDA", "Bonfida"));
            list.add(new CandidateCoin("force-protocol", "FOR", "ForTube"));
            list.add(new CandidateCoin("terra-virtua-kolect", "TVK", "Terra Virtua Kolect"));
            list.add(new CandidateCoin("mainframe", "MFT", "Hifi Finance"));
            list.add(new CandidateCoin("yield-guild-games", "YGG", "Yield Guild Games"));
            list.add(new CandidateCoin("mithril", "MITH", "Mithril"));
            list.add(new CandidateCoin("automata", "ATA", "Automata"));
            list.add(new CandidateCoin("marlin", "POND", "Marlin"));
            list.add(new CandidateCoin("cortex", "CTXC", "Cortex"));
            list.add(new CandidateCoin("benqi", "QI", "BENQI"));
            list.add(new CandidateCoin("storj", "STORJ", "Storj"));
            list.add(new CandidateCoin("melon", "MLN", "Enzyme"));
            list.add(new CandidateCoin("ocean-protocol", "OCEAN", "Ocean Protocol"));
            list.add(new CandidateCoin("omisego", "OMG", "OMG Network"));
            list.add(new CandidateCoin("raydium", "RAY", "Raydium"));
            list.add(new CandidateCoin("lazio-fan-token", "LAZIO", "Lazio Fan Token"));
            list.add(new CandidateCoin("yearn-finance", "YFI", "yearn.finance"));
            list.add(new CandidateCoin("curve-dao-token", "CRV", "Curve DAO"));
            list.add(new CandidateCoin("selfkey", "KEY", "SelfKey"));
            list.add(new CandidateCoin("republic-protocol", "REN", "REN"));
            list.add(new CandidateCoin("adventure-gold", "AGLD", "Adventure Gold"));
            list.add(new CandidateCoin("balancer", "BAL", "Balancer"));
            list.add(new CandidateCoin("oasis-network", "ROSE", "Oasis Network"));
            list.add(new CandidateCoin("metal", "MTL", "Metal"));
            list.add(new CandidateCoin("fetch-ai", "FET", "Fetch.ai"));
            list.add(new CandidateCoin("kava-lend", "HARD", "Kava Lend"));
            list.add(new CandidateCoin("coin98", "C98", "Coin98"));
            list.add(new CandidateCoin("ethernity-chain", "ERN", "Ethernity Chain"));
            list.add(new CandidateCoin("fc-barcelona-fan-token", "BAR", "FC Barcelona Fan Token"));
            list.add(new CandidateCoin("reef-finance", "REEF", "Reef Finance"));
            list.add(new CandidateCoin("iotex", "IOTX", "IoTeX"));
            list.add(new CandidateCoin("tomochain", "TOMO", "TomoChain"));
            list.add(new CandidateCoin("alpine-f1-team-fan-token", "ALPINE", "Alpine F1 Team Fan Token"));
            list.add(new CandidateCoin("aelf", "ELF", "aelf"));
            list.add(new CandidateCoin("dexe", "DEXE", "DeXe"));
            list.add(new CandidateCoin("coti", "COTI", "COTI"));
            list.add(new CandidateCoin("ooki", "OOKI", "Ooki"));
            list.add(new CandidateCoin("gitcoin", "GTC", "Gitcoin"));
            list.add(new CandidateCoin("contentos", "COS", "Contentos"));
            list.add(new CandidateCoin("swipe", "SXP", "SXP"));
            list.add(new CandidateCoin("api3", "API3", "API3"));
            list.add(new CandidateCoin("qtum", "QTUM", "Qtum"));
            list.add(new CandidateCoin("radicle", "RAD", "Radicle"));
            list.add(new CandidateCoin("alpha-finance", "ALPHA", "Alpha Venture DAO"));
            list.add(new CandidateCoin("superrare", "RARE", "SuperRare"));
            list.add(new CandidateCoin("cartesi", "CTSI", "Cartesi"));
            list.add(new CandidateCoin("unlend-finance", "UFT", "UniLend Finance"));
            list.add(new CandidateCoin("measurable-data-token", "MDT", "Measurable Data Token"));
            list.add(new CandidateCoin("beam", "BEAM", "BEAM"));
            list.add(new CandidateCoin("perpetual-protocol", "PERP", "Perpetual Protocol"));
            list.add(new CandidateCoin("lisk", "LSK", "Lisk"));
            list.add(new CandidateCoin("spell-token", "SPELL", "Spell"));
            list.add(new CandidateCoin("compound-governance-token", "COMP", "Compound"));
            list.add(new CandidateCoin("uma", "UMA", "UMA"));
            list.add(new CandidateCoin("dock", "DOCK", "Dock"));
            list.add(new CandidateCoin("atletico-madrid", "ATM", "Atletico Madrid Fan Token"));
            list.add(new CandidateCoin("gifto", "GTO", "Gifto"));
            list.add(new CandidateCoin("serum", "SRM", "Serum"));
            list.add(new CandidateCoin("manchester-city-fan-token", "CITY", "Manchester City Fan Token"));
            list.add(new CandidateCoin("bitshares", "BTS", "BitShares"));
            list.add(new CandidateCoin("injective-protocol", "INJ", "Injective"));
            list.add(new CandidateCoin("illuvium", "ILV", "Illuvium"));
            list.add(new CandidateCoin("alchemy-pay", "ACH", "Alchemy Pay"));
            list.add(new CandidateCoin("woo-network", "WOO", "WOO Network"));
            list.add(new CandidateCoin("joe", "JOE", "JOE"));
            list.add(new CandidateCoin("biconomy", "BICO", "Biconomy"));
            list.add(new CandidateCoin("venus", "XVS", "Venus"));
            list.add(new CandidateCoin("new-bitshares", "NBS", "New BitShares"));
            list.add(new CandidateCoin("truefi", "TRU", "TrueFi"));
            list.add(new CandidateCoin("dusk-network", "DUSK", "DUSK Network"));
            list.add(new CandidateCoin("pha", "PHA", "Phala Network"));
            list.add(new CandidateCoin("kyber-network-crystal", "KNC", "Kyber Network Crystal"));
            list.add(new CandidateCoin("cocos-bcx", "COCOS", "COCOS BCX"));
            list.add(new CandidateCoin("mobox", "MBOX", "Mobox"));
            list.add(new CandidateCoin("biswap", "BSW", "Biswap"));
            list.add(new CandidateCoin("orchid-protocol", "OXT", "Orchid Protocol"));
            list.add(new CandidateCoin("mantra-dao", "OM", "MANTRA DAO"));
            list.add(new CandidateCoin("aion", "AION", "Aion"));
            list.add(new CandidateCoin("wax", "WAXP", "WAX"));
            list.add(new CandidateCoin("lto-network", "LTO", "LTO Network"));
            list.add(new CandidateCoin("orion-protocol", "ORN", "Orion Protocol"));
            list.add(new CandidateCoin("band-protocol", "BAND", "Band Protocol"));
            list.add(new CandidateCoin("vulcan-forged", "PYR", "Vulcan Forged"));
            list.add(new CandidateCoin("kava", "KAVA", "Kava"));
            list.add(new CandidateCoin("livepeer", "LPT", "Livepeer"));
            list.add(new CandidateCoin("nkn", "NKN", "NKN"));
            list.add(new CandidateCoin("flamingo-finance", "FLM", "Flamingo Finance"));
            list.add(new CandidateCoin("zencash", "ZEN", "Horizen"));
            list.add(new CandidateCoin("skale", "SKL", "SKALE"));
            list.add(new CandidateCoin("stratis", "STRAX", "Stratis"));
            list.add(new CandidateCoin("audius", "AUDIO", "Audius"));
            list.add(new CandidateCoin("steem", "STEEM", "Steem"));
            list.add(new CandidateCoin("moonriver", "MOVR", "Moonriver"));
            list.add(new CandidateCoin("zcoin", "FIRO", "Firo"));
            list.add(new CandidateCoin("playdapp", "PLA", "PlayDapp"));
            list.add(new CandidateCoin("request-network", "REQ", "Request"));
            list.add(new CandidateCoin("iostoken", "IOST", "IOST"));
            list.add(new CandidateCoin("ankr", "ANKR", "Ankr"));
            list.add(new CandidateCoin("iris-network", "IRIS", "IRISnet"));
            list.add(new CandidateCoin("vite", "VITE", "Vite"));
            list.add(new CandidateCoin("astar", "ASTR", "Astar"));
            list.add(new CandidateCoin("ontology", "ONT", "Ontology"));
            list.add(new CandidateCoin("badger-dao", "BADGER", "Badger DAO"));
            list.add(new CandidateCoin("holotoken", "HOT", "Holo"));
            list.add(new CandidateCoin("cream-2", "CREAM", "Cream"));
            list.add(new CandidateCoin("aergo", "AERGO", "Aergo"));
            list.add(new CandidateCoin("power-ledger", "POWR", "Power Ledger"));
            list.add(new CandidateCoin("moonbeam", "GLMR", "Moonbeam"));
            list.add(new CandidateCoin("digibyte", "DGB", "DigiByte"));
            list.add(new CandidateCoin("syscoin", "SYS", "Syscoin"));
            list.add(new CandidateCoin("iexec-rlc", "RLC", "iExec RLC"));
            list.add(new CandidateCoin("auction", "AUCTION", "Bounce"));
            list.add(new CandidateCoin("utrust", "UTK", "Utrust"));
            list.add(new CandidateCoin("fio-protocol", "FIO", "FIO Protocol"));
            list.add(new CandidateCoin("acala", "ACA", "Acala"));
            list.add(new CandidateCoin("alpaca-finance", "ALPACA", "Alpaca Finance"));
            list.add(new CandidateCoin("concierge-io", "AVA", "Travala.com"));
            list.add(new CandidateCoin("adex", "ADX", "Ambire AdEx"));
            list.add(new CandidateCoin("render-token", "RNDR", "Render Token"));
            list.add(new CandidateCoin("hive", "HIVE", "Hive"));
            list.add(new CandidateCoin("district0x", "DNT", "district0x"));
            list.add(new CandidateCoin("pundi-x-2", "PUNDIX", "Pundi X"));
            list.add(new CandidateCoin("everipedia", "IQ", "Everipedia"));
            list.add(new CandidateCoin("alchemix", "ALCX", "Alchemix"));
            list.add(new CandidateCoin("polkastarter", "POLS", "Polkastarter"));
            list.add(new CandidateCoin("tribe-2", "TRIBE", "Tribe"));
            list.add(new CandidateCoin("kadena", "KDA", "Kadena"));
            list.add(new CandidateCoin("wanchain", "WAN", "Wanchain"));
            list.add(new CandidateCoin("zelcash", "FLUX", "Flux"));
            list.add(new CandidateCoin("btc-standard-hashrate-token", "BTCST", "BTC Standard Hashrate Token"));
            list.add(new CandidateCoin("icon", "ICX", "ICON"));
            list.add(new CandidateCoin("bancor", "BNT", "Bancor Network Token"));
            list.add(new CandidateCoin("numeraire", "NMR", "Numeraire"));
            list.add(new CandidateCoin("ravencoin", "RVN", "Ravencoin"));
            list.add(new CandidateCoin("wazirx", "WRX", "WazirX"));
            list.add(new CandidateCoin("beefy-finance", "BIFI", "Beefy.Finance"));
            list.add(new CandidateCoin("nem", "XEM", "NEM"));
            list.add(new CandidateCoin("mdex", "MDX", "Mdex"));
            list.add(new CandidateCoin("multichain", "MULTI", "Multichain"));
            list.add(new CandidateCoin("komodo", "KMD", "Komodo"));
            list.add(new CandidateCoin("wrapped-nxm", "WNXM", "Wrapped NXM"));
            list.add(new CandidateCoin("vethor-token", "VTHO", "VeThor Token"));
            list.add(new CandidateCoin("verge", "XVG", "Verge"));
            list.add(new CandidateCoin("storm", "STMX", "StormX"));
            list.add(new CandidateCoin("frax-share", "FXS", "Frax Share"));
            list.add(new CandidateCoin("nervos-network", "CKB", "Nervos Network"));
            list.add(new CandidateCoin("ardor", "ARDR", "Ardor"));
            list.add(new CandidateCoin("secret", "SCRT", "Secret"));
            list.add(new CandidateCoin("rif-token", "RIF", "RSK Infrastructure Framework"));
            list.add(new CandidateCoin("prometeus", "PROM", "Prometeus"));
            list.add(new CandidateCoin("funfair", "FUN", "FUNToken"));
            list.add(new CandidateCoin("thorchain-erc20", "RUNE", "THORChain (ERC20)"));
            list.add(new CandidateCoin("ethos", "VGX", "Voyager Token"));
            list.add(new CandidateCoin("gnosis", "GNO", "Gnosis"));
            list.add(new CandidateCoin("lition", "LIT", "Lition"));
            list.add(new CandidateCoin("project-galaxy", "GAL", "Project Galaxy"));
            list.add(new CandidateCoin("burger-swap", "BURGER", "Burger Swap"));
            list.add(new CandidateCoin("drep-new", "DREP", "Drep [new]"));
            list.add(new CandidateCoin("ellipsis-x", "EPX", "Ellipsis X"));
            list.add(new CandidateCoin("fc-porto", "PORTO", "FC Porto"));
            list.add(new CandidateCoin("highstreet", "HIGH", "Highstreet"));
            list.add(new CandidateCoin("mines-of-dalarnia", "DAR", "Mines of Dalarnia"));
            list.add(new CandidateCoin("mobilecoin", "MOB", "MobileCoin"));
            list.add(new CandidateCoin("ong", "ONG", "Ontology Gas"));
            list.add(new CandidateCoin("perlin", "PERL", "PERL.eco"));
            list.add(new CandidateCoin("rei-network", "REI", "REI Network"));
            list.add(new CandidateCoin("streamr", "DATA", "Streamr"));
            list.add(new CandidateCoin("threshold-network-token", "T", "Threshold Network"));
            list.add(new CandidateCoin("tycoon-global", "TCT", "Tycoon Global"));

            candidateCoinRepository.saveAll(list);
            System.out.println("end CoinGeckoServiceImpl.initCandidateCoin success -->");

            return list;

        } catch (Exception e) {
            System.out.println("end CoinGeckoServiceImpl.initCandidateCoin error --->");
            System.out.println(e.getMessage());
            return new ArrayList<CandidateCoin>();
        }
    }

    @Override
    @Transactional
    public void delete(String gecko_id) {

        try {
            System.out.println("Start delete  --->");
            if (!Objects.equals(null, gecko_id)) {
                String sql = " DELETE FROM candidate_coin WHERE gecko_id=:gecko_id ;"
                        + " DELETE FROM gecko_volumn_day WHERE gecko_id=:gecko_id ;"
                        + " DELETE FROM binance_volumn_week WHERE gecko_id=:gecko_id ;"
                        + " DELETE FROM binance_volumn_day WHERE gecko_id=:gecko_id ;"
                        + " DELETE FROM priority_coin WHERE gecko_id=:gecko_id ;"
                        + " DELETE FROM priority_coin_history WHERE gecko_id=:gecko_id ;";

                Query query = entityManager.createNativeQuery(sql);
                query.setParameter("gecko_id", gecko_id);
                query.executeUpdate();
            }

            System.out.println("End delete success <---");
        } catch (Exception e) {
            System.out.println("Add token  error --->");
            System.out.println(e.getMessage());
        }
    }

    @Override
    @Transactional
    public Response add(CoinGeckoTokenRequest request) {
        try {
            System.out.println("Start add  --->");

            List<BinanceVolumnDay> days = new ArrayList<BinanceVolumnDay>();
            for (int index = 1; index < 24; index++) {
                String dd = String.valueOf(index);
                if (dd.length() < 2) {
                    dd = "0" + dd;
                }
                BinanceVolumnDayKey id = new BinanceVolumnDayKey(request.getId(), request.getSymbol(), dd);
                days.add(new BinanceVolumnDay(id));
            }

        } catch (

        Exception e) {
            System.out.println("Add token  error --->");
            System.out.println(e.getMessage());
            return new Response("500", "Error", e.toString());
        }

        return new Response("200", "add", null, request.getId());
    }

    @Override
    @Transactional
    public Response delete(CoinGeckoTokenRequest request) {
        try {
            if (!Objects.equals(null, request.getId())) {
                String sql = " DELETE FROM candidate_coin WHERE gecko_id=:gecko_id ;"
                        + " DELETE FROM gecko_volumn_day WHERE gecko_id=:gecko_id ;"
                        + " DELETE FROM binance_volumn_week WHERE gecko_id=:gecko_id ;"
                        + " DELETE FROM priority_coin_history WHERE gecko_id=:gecko_id ;";

                Query query = entityManager.createNativeQuery(sql);
                query.setParameter("gecko_id", request.getId());
                query.executeUpdate();
            }

            System.out.println("delete success--->" + request.getId());
            return new Response("200", "Delete", null, request.getId());
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return new Response("500", "Error", e.toString());
        }
    }

    @Override
    @Transactional
    public Response note(CoinGeckoTokenRequest request) {
        try {
            System.out.println("Start note  --->");

            if (!Objects.equals("", Utils.getStringValue(request.getId()))
                    && !Objects.equals("", Utils.getStringValue(request.getNote()))) {

                String sql = " Update candidate_coin set note=:note WHERE gecko_id=:gecko_id ;";
                String note = request.getNote();
                if (note.length() > 200) {
                    note = note.substring(0, 200);
                }
                Query query = entityManager.createNativeQuery(sql);
                query.setParameter("note", note);
                query.setParameter("gecko_id", request.getId());
                query.executeUpdate();

                System.out.println(request.getId() + "=" + request.getNote());
            }
            System.out.println("End note success <---");
            return new Response("200", "Ok");
        } catch (Exception e) {
            System.out.println("Add note error --->");
            System.out.println(e.getMessage());
            return new Response("500", "Error", e.toString());
        }
    }

    @Override
    @Transactional
    public Response priority(CoinGeckoTokenRequest request) {
        try {
            System.out.println("Start priority  --->");

            if (!Objects.equals("", Utils.getStringValue(request.getId()))) {
                String sql = " Update candidate_coin set priority=:priority WHERE gecko_id=:gecko_id ;";
                Query query = entityManager.createNativeQuery(sql);
                query.setParameter("priority", request.getPriority());
                query.setParameter("gecko_id", request.getId());
                query.executeUpdate();

                System.out.println(request.getId() + "=" + request.getNote());
            }
            System.out.println("End priority success <---");
            return new Response("200", "Ok");
        } catch (Exception e) {
            System.out.println("Priority error --->");
            System.out.println(e.getMessage());
            return new Response("500", "Error", e.toString());
        }
    }

}
