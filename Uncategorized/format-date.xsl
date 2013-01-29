<?xml version="1.0" encoding="UTF-8" ?>
<!--
    Formatting Dates in XSLT
    2008-09-25 Created by Ross Williams
    2013-01-29 Updated by Charlie Holder
    Copyright (c) 2008 Hannon Hill Corp. All rights reserved.
    
    ====================
    EXAMPLE USAGE
    ====================
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:include href="site://Site Name/path/to/format-date"/>
        <xsl:template match="/system-index-block/calling-page/system-page">
            <xsl:text>Last updated: </xsl:text>
            <xsl:call-template name="format-date">
                <xsl:with-param name="date" select="last-modified"/>
                <xsl:with-param name="mask">medium</xsl:with-param>
            </xsl:call-template>
        </xsl:template>
    </xsl:stylesheet>
    
    ====================
    FORMATTING
    ====================
    You can omit the mask parameter (will use 'default') or use one of the following:
    
    default:            mmm d, yyyy h:mm:ss TT              Jun 1, 2012 1:37:00 PM
    shortDate:          mm/dd/yy                            06/01/12
    mediumDate:         mmm d, yyyy                         Jun 1, 2012
    longDate:           mmmm d, yyyy                        June 1, 2012
    fullDate:           dddd, mmmm d, yyyy                  Friday, June 1, 2012
    shortTime:          h:MM TT                             1:37 PM
    mediumTime:         h:MM:ss TT                          1:37:00 PM
    longTime:           h:MM:ss TT Z                        1:37:00 PM EDT
    isoDate:            yyyy-mm-dd                          2012-06-01
    isoTime:            HH:MM:ss                            13:37:00
    isoDateTime:        yyyy-mm-dd'T'HH:MM:ss               2012-06-01T13:37:00
    isoUtcDateTime:     UTC:yyyy-mm-dd'T'HH:MM:ss'Z'
    rfc822:             ddd, d mmm yyyy HH:MM:ss o
    rss:                ddd, d mmm yyyy HH:MM:ss o
    
    
    Or create your own:
    
    Example:
    <xsl:with-param name="mask">dddd, mmmm dd, yyyy h:mm:ss TT Z</xsl:with-param>
    
    Gives:
    Friday, June 01, 2012 1:37:00 PM EDT
    
    Mask Reference:
    For the full description of mask characters,
    visit <http://blog.stevenlevithan.com/archives/date-time-format>.
    
    Letter      Date or Time Component
    =============================================================
    d           Day of the month as digits. No leading zero for single-digit days.
    dd          Day of the month as digits. Leading zero for single-digit days.
    ddd         Day of the week as a three-letter abbreviation.
    dddd        Day of the week as full name.
    m           Month as digits. No leading zero for single-digit months.
    mm          Month as digits. Leading zero for single-digit months.
    mmm         Month as a three-letter abbreviation.
    mmmm        Month as full name.
    yy          Year as last two digits. Leading zero for years less than 10.
    yyyy        Year represented by four digits.
    h           Hours. No leading zero for single-digit hours (12-hour clock).
    hh          Hours. Leading zero for single-digit hours (12-hour clock).
    H           Hours. No leading zero for single-digit hours (24-hour clock).
    HH          Hours. Leading zero for single-digit hours (24-hour clock).
    M           Minutes. No leading zero for single-digit minutes.
    MM          Minutes. Leading zero for single-digit minutes.
    s           Seconds. No leading zero for single-digit seconds.
    ss          Seconds. Leading zero for single-digit seconds.
    l or L      Milliseconds. Gives 3 digits (l) or 2 digits (L).
    t           Lowercase, single-character time marker string: a or p.
    tt          Lowercase, two-character time marker string: am or pm.
    T           Uppercase, single-character time marker string: A or P.
    TT          Uppercase, two-character time marker string: AM or PM.
    Z           US timezone abbreviation: EST or MDT.
    o           GMT/UTC timezone offset: -0500 or +0230.
    S           Ordinal suffix (st, nd, rd, or th).
    '...'       Literal character sequence. Surrounding quotes are removed.
    
    Special considerations:
    To include a literal string in the date mask, you must use single quotes in the mask:
    <xsl:with-param name="mask">'Today is' mmmm d, yyyy</xsl:with-param>
    
    To include a literal single quote, you two single quotes back to back:
    <xsl:with-param name="mask">dddd, mmmm d, ''yy</xsl:with-param>
    
--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="hh" version="1.0" xmlns:hh="http://www.hannonhill.com/XSL/Functions" xmlns:xalan="http://xml.apache.org/xalan">
    <xsl:output encoding="UTF-8" method="xml"/>
    <xsl:template name="format-date">
        <xsl:param name="date"/>
        <xsl:param name="mask" select="'default'"/>
        <xsl:value-of select="hh:dateFormat(number($date),$mask)"/>
    </xsl:template>
    <xsl:template name="format-date-string">
        <xsl:param name="date"/>
        <xsl:param name="mask" select="'default'"/>
        <xsl:value-of select="hh:dateFormat(string($date),$mask)"/>
    </xsl:template>
    <xsl:template name="format-calendar-string">
        <xsl:param name="date"/>
        <xsl:param name="mask" select="'default'"/>
        <xsl:value-of select="hh:calendarFormat(string($date),$mask)"/>
    </xsl:template>
    <xalan:component functions="dateFormat calendarFormat" prefix="hh">
        <xalan:script lang="javascript">
            <![CDATA[
                /*
                 * Cascade 'calendar' field type helper function
                 */
                 
                function calendarFormat(dateString, mask) {
                    var dateArray = dateString.split("-");
                    var timeStamp = new Number(new Date(parseFloat(dateArray[2]),parseFloat(dateArray[0])-1,parseFloat(dateArray[1])));
                    var formattedString = dateFormat(timeStamp, mask);
                    return formattedString;
                }
             
                /*
                 * Date Format 1.2.2
                 * (c) 2007-2008 Steven Levithan <stevenlevithan.com>
                 * MIT license
                 * Includes enhancements by Scott Trenda <scott.trenda.net> and Kris Kowal <cixar.com/~kris.kowal/>
                 *
                 * Accepts a date, a mask, or a date and a mask.
                 * Returns a formatted version of the given date.
                 * The date defaults to the current date/time.
                 * The mask defaults to dateFormat.masks.default.
                 */
                 
                var dateFormat = function () {
                    var token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
                    timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
                    timezoneClip = /[^-+\dA-Z]/g,
                    pad = function (val, len) {
                        val = String(val);
                        len = len || 2;
                        while (val.length < len) val = "0" + val;
                        return val;
                    };

                    // Regexes and supporting functions are cached through closure
                    return function (date, mask, utc) {
                        var dF = dateFormat;
    
                        // You can't provide utc if you skip other args (use the "UTC:" mask prefix)
                        if (arguments.length == 1 && (typeof date == "string" || date instanceof String) && !/\d/.test(date)) {
                            mask = date;
                            date = undefined;
                        }
                        
                        // If the date "string" is nothing but digits, cast it to a number
                        if ((typeof date == "string" || date instanceof String) && /^\d+$/.test(date)) {
                            date = parseInt(date);
                        }
    
                        // Passing date through Date applies Date.parse, if necessary
                        date = date ? new Date(date) : new Date();
                        if (isNaN(date)) throw new SyntaxError("invalid date");
    
                        mask = String(dF.masks[mask] || mask || dF.masks["default"]);
    
                        // Allow setting the utc argument via the mask
                        if (mask.slice(0, 4) == "UTC:") {
                            mask = mask.slice(4);
                            utc = true;
                        }
    
                        var _ = utc ? "getUTC" : "get",
                            d = date[_ + "Date"](),
                            D = date[_ + "Day"](),
                            m = date[_ + "Month"](),
                            y = date[_ + "FullYear"](),
                            H = date[_ + "Hours"](),
                            M = date[_ + "Minutes"](),
                            s = date[_ + "Seconds"](),
                            L = date[_ + "Milliseconds"](),
                            o = utc ? 0 : date.getTimezoneOffset(),
                            flags = {
                                d:    d,
                                dd:   pad(d),
                                ddd:  dF.i18n.dayNames[D],
                                dddd: dF.i18n.dayNames[D + 7],
                                m:    m + 1,
                                mm:   pad(m + 1),
                                mmm:  dF.i18n.monthNames[m],
                                mmmm: dF.i18n.monthNames[m + 12],
                                yy:   String(y).slice(2),
                                yyyy: y,
                                h:    H % 12 || 12,
                                hh:   pad(H % 12 || 12),
                                H:    H,
                                HH:   pad(H),
                                M:    M,
                                MM:   pad(M),
                                s:    s,
                                ss:   pad(s),
                                l:    pad(L, 3),
                                L:    pad(L > 99 ? Math.round(L / 10) : L),
                                t:    H < 12 ? "a"  : "p",
                                tt:   H < 12 ? "am" : "pm",
                                T:    H < 12 ? "A"  : "P",
                                TT:   H < 12 ? "AM" : "PM",
                                Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
                                o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
                                S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
                            };
    
                        return mask.replace(token, function ($0) {
                            return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
                        });
                    };
                }();
    
                // Some common format strings
                dateFormat.masks = {
                    "default":      "mmm d, yyyy h:mm:ss TT",
                    shortDate:      "mm/dd/yy",
                    mediumDate:     "mmm d, yyyy",
                    longDate:       "mmmm d, yyyy",
                    fullDate:       "dddd, mmmm d, yyyy",
                    shortTime:      "h:MM TT",
                    mediumTime:     "h:MM:ss TT",
                    longTime:       "h:MM:ss TT Z",
                    isoDate:        "yyyy-mm-dd",
                    isoTime:        "HH:MM:ss",
                    isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
                    isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'",
                    rfc822:         "ddd, d mmm yyyy HH:MM:ss o",
                    rss:            "ddd, d mmm yyyy HH:MM:ss o"
                };
    
                // Internationalization strings
                dateFormat.i18n = {
                    dayNames: [
                        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
                        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
                    ],
                    monthNames: [
                        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
                        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
                    ]
                };
    
                // For convenience...
                Date.prototype.format = function (mask, utc) {
                    return dateFormat(this, mask, utc);
                }; 
            ]]>
        </xalan:script>
    </xalan:component>
</xsl:stylesheet>
