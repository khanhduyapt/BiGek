package bsc_scan_geckko.utils;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;

import org.springframework.context.MessageSource;
import org.springframework.web.servlet.LocaleResolver;

public class Utils {

    public static final int const_app_flag_msg_on = 1; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin
    public static final int const_app_flag_msg_off = 2;
    public static final int const_app_flag_webonly = 3;
    public static final int const_app_flag_all_coin = 4;

    public static boolean isNotBlank(String value) {
        if (Objects.equals(null, value) || Objects.equals("", value)) {
            return false;
        }
        return true;
    }

    public static Integer getIntValue(Object value) {
        try {
            if (Objects.equals(null, value)) {
                return 0;
            }

            return Integer.valueOf(value.toString().trim());
        } catch (Exception e) {
            return 0;
        }
    }

    public static BigDecimal getBigDecimal(Object value) {
        if (Objects.equals(null, value)) {
            return BigDecimal.ZERO;
        }

        if (Objects.equals("", value.toString())) {
            return BigDecimal.ZERO;
        }

        BigDecimal ret = null;
        if (value != null) {
            if (value instanceof BigDecimal) {
                ret = (BigDecimal) value;
            } else if (value instanceof String) {
                ret = new BigDecimal((String) value);
            } else if (value instanceof BigInteger) {
                ret = new BigDecimal((BigInteger) value);
            } else if (value instanceof Number) {
                ret = new BigDecimal(((Number) value).doubleValue());
            } else {
                throw new ClassCastException("Not possible to coerce [" + value + "] from class " + value.getClass()
                        + " into a BigDecimal.");
            }
        }
        return ret;
    }

    public static String getValue(Object value) {
        if (Objects.equals(null, value)) {
            return "";
        }
        if (Objects.equals("", value.toString())) {
            return "";
        }

        return value.toString();
    }

    public static String getTextCss(String value) {
        if (Objects.equals(null, value)) {
            return "";
        }

        if (value.contains("-")) {
            return "text-danger";
        } else {
            return "text-primary";
        }
    }

    public static Date getDate(String unix_time) {
        String temp = unix_time.substring(0, unix_time.length() - 3);

        Instant instant = Instant.ofEpochSecond(Long.valueOf(temp));
        Date date = Date.from(instant);

        return date;
    }

    public static Object getLinkedHashMapValue(Object root, List<String> childs) {
        int index = 0;
        Object obj_key = root;

        for (String key : childs) {
            @SuppressWarnings("unchecked")
            LinkedHashMap<String, Object> linkedHashMap = (LinkedHashMap<String, Object>) obj_key;
            obj_key = linkedHashMap.get(key);
            index += 1;

            if (index == childs.size()) {
                return obj_key;
            }
        }

        return null;
    }

    public static String getMessage(HttpServletRequest request, LocaleResolver localeResolver, MessageSource messages,
            String key) {
        final Locale locale = localeResolver.resolveLocale(request);
        String message = messages.getMessage(key, null, locale);
        return message;
    }

    public static String getMessage2(MessageSource messages, String key, String lang) {
        String message = messages.getMessage(key, null, Locale.forLanguageTag(lang));
        return message;
    }

    public static final String generateCollectionString(List<?> list) {
        if (list == null || list.isEmpty())
            return "()";
        StringBuilder result = new StringBuilder();
        result.append("(");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'");
            result.append(ob.toString());
            result.append("'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append(")");
        return result.toString();
    }

    public static final String generateCollectionStringLikeArray(List<?> list) {
        if (list == null || list.isEmpty())
            return "[]";
        StringBuilder result = new StringBuilder();
        result.append("[");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append("]");
        return result.toString();
    }

    public static final String generateCollectionNumber(List<?> list) {
        if (list == null || list.isEmpty())
            return "()";
        StringBuilder result = new StringBuilder();
        result.append("(");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append(ob.toString());
            if (it.hasNext())
                result.append(" , ");
        }
        result.append(")");
        return result.toString();
    }

    public static String convertDateToString(String pattern, Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat(pattern);
        return sdf.format(date);
    }

    public static Date convertStringToDate(String pattern, String date) {
        try {
            return new SimpleDateFormat(pattern).parse(date);
        } catch (Exception e) {
            return null;
        }
    }

    public static String convertStringISOToString(String patternIn, String dateIso, String patternOut) {
        //        IN :yyyy-MM-dd'T'HH:mm:ss.SSSXXX
        //        OUT : yyyy-MM-dd
        try {
            DateFormat dateFormat = new SimpleDateFormat(patternIn);
            dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date date = dateFormat.parse(dateIso);
            DateFormat formatter = new SimpleDateFormat(patternOut);
            return formatter.format(date);
        } catch (Exception e) {
            return null;
        }
    }

    public static Timestamp convertStringToTimeStamp(String pattern, String date) {
        try {
            DateFormat df = new SimpleDateFormat(pattern);
            Date dates = df.parse(date);
            long time = dates.getTime();
            Timestamp ts = new Timestamp(time);
            return ts;
        } catch (Exception e) {
            return null;
        }
    }

    public static final String generateCollectionStringLikeArray(List<?> list, String columnName) {
        StringBuilder result = new StringBuilder();
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append(" LOWER(").append(columnName).append(")")
                    .append(" LIKE '%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext()) {
                result.append(" OR ");
            }
        }
        return result.toString();
    }

    public static final String generateCollectionStringToArray(List<?> list) {
        StringBuilder result = new StringBuilder();
        result.append("[");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append("]");
        return result.toString();
    }

}
