# Copyright 2026 José A. García Tenorio  
# derived from wns.py by Johanna Roedenbeck, which was
# derived from the Windy driver by Matthew Wall
# thanks to Gary and Tom Keffer from Weewx development group

"""
This is a weewx extension that uploads data to Meteoclimatic (v3 API)

https://www.meteoclimatic.net

Data is sent as a JSON payload in a HTTP POST request to

    https://api.m11c.net/v3/station/wxupdate

The station code travels inside the JSON payload (field 'stationcode'),
together with the current timestamp in ISO-8601 UTC format (field 'TS')
and all the weather values. The user's APIkey is NOT sent in the
payload; it goes in the 'APIkey' HTTP header instead.

Tested with Weewx 5.5, Simulator driver and GW1000 driver

Minimal configuration of Weewx config file

[StdRESTful]
    [[MeteoclimaticV3]]
        enable = true
        station_id = your Meteoclimatic station code
        api_key = your Meteoclimatic APIkey

[Engine]
    [[Services]]
        restful_services = {append ", user.meteoclimatic_v3.MeteoclimaticV3" to the end of line
        

This file must be placed in the directory containing the drivers and extensions used by WeeWX.
On a DEB installation, this is usually /etc/weewx/bin/user

You must restart WeeWX once all modifications are complete.
 
"""

# deal with differences between python 2 and python 3
try:
    # Python 3
    import queue
except ImportError:
    # Python 2
    # noinspection PyUnresolvedReferences
    import Queue as queue

from distutils.version import StrictVersion
import datetime
import json
import sys
import time

import weedb
import weewx
import weewx.manager
import weewx.restx
import weewx.units
import weewx.xtypes
from weeutil.weeutil import to_bool, TimeSpan
import weeutil.weeutil

VERSION = "0.1"

REQUIRED_WEEWX = "3.8.0"
if StrictVersion(weewx.__version__) < StrictVersion(REQUIRED_WEEWX):
    raise weewx.UnsupportedFeature("weewx %s or greater is required, found %s"
                                   % (REQUIRED_WEEWX, weewx.__version__))

try:
    # Test for new-style weewx logging by trying to import weeutil.logger
    import weeutil.logger
    import logging
    log = logging.getLogger(__name__)

    def logdbg(msg):
        log.debug(msg)

    def loginf(msg):
        log.info(msg)

    def logerr(msg):
        log.error(msg)

except ImportError:
    # Old-style weewx logging
    import syslog

    def logmsg(level, msg):
        syslog.syslog(level, 'meteoclimaticv3: %s' % msg)

    def logdbg(msg):
        logmsg(syslog.LOG_DEBUG, msg)

    def loginf(msg):
        logmsg(syslog.LOG_INFO, msg)

    def logerr(msg):
        logmsg(syslog.LOG_ERR, msg)


class MeteoclimaticV3(weewx.restx.StdRESTful):
    """Upload data to Meteoclimatic using the v3 JSON API"""

    DEFAULT_URL = 'https://api.m11c.net/v3/station/wxupdate'

    def __init__(self, engine, cfg_dict):
        super(MeteoclimaticV3, self).__init__(engine, cfg_dict)
        loginf("version is %s" % VERSION)
        site_dict = weewx.restx.get_site_dict(
            cfg_dict, 'MeteoclimaticV3', 'api_key', 'station_id')
        if site_dict is None:
            return

        try:
            site_dict['manager_dict'] = weewx.manager.get_manager_dict_from_config(
                cfg_dict, 'wx_binding')
        except weewx.UnknownBinding:
            pass

        # register the particulate matter data types with a unit group,
        # in case they are not already known to weewx (they are typically
        # provided by a driver/extension such as an air-quality sensor)
        weewx.units.obs_group_dict.setdefault('pm1_0', 'group_concentration')
        weewx.units.obs_group_dict.setdefault('pm2_5', 'group_concentration')
        weewx.units.obs_group_dict.setdefault('pm10_0', 'group_concentration')

        self.archive_queue = queue.Queue(5)
        self.archive_thread = MeteoclimaticV3Thread(self.archive_queue, **site_dict)

        self.archive_thread.start()
        self.bind(weewx.NEW_ARCHIVE_RECORD, self.new_archive_record)

    def new_archive_record(self, event):
        try:
            self.archive_queue.put(event.record, timeout=10)
        except queue.Full:
            logerr('Queue is full. Thread died?')


class MeteoclimaticV3Thread(weewx.restx.RESTThread):

    # Mapping of Meteoclimatic JSON field -> (weewx observation, time span,
    # aggregation, number of decimals).
    # An empty time span/aggregation means "current value", taken directly
    # from the archive record.
    _DATA_MAP = [
        # ---- Temperatura (Celsius, 1 decimal) ----
        ('TMP',    'outTemp', '',      '',    1),
        ('DHTM',   'outTemp', 'Day',   'max', 1),
        ('DLTM',   'outTemp', 'Day',   'min', 1),
        ('MHTM',   'outTemp', 'Month', 'max', 1),
        ('MLTM',   'outTemp', 'Month', 'min', 1),
        ('YHTM',   'outTemp', 'Year',  'max', 1),
        ('LHTM',   'outTemp', 'Year',  'min', 1),

        # ---- Humedad (%, sin decimales) ----
        ('HUM',    'outHumidity', '',      '',    0),
        ('DHHM',   'outHumidity', 'Day',   'max', 0),
        ('DLHM',   'outHumidity', 'Day',   'min', 0),
        ('MHHM',   'outHumidity', 'Month', 'max', 0),
        ('MLHM',   'outHumidity', 'Month', 'min', 0),
        ('YHHM',   'outHumidity', 'Year',  'max', 0),
        ('YLHM',   'outHumidity', 'Year',  'min', 0),

        # ---- Barometro (hPa a nivel del mar / QFF, 1 decimal) ----
        ('BAR',    'barometer', '',      '',    1),
        ('DHBR',   'barometer', 'Day',   'max', 1),
        ('DLBR',   'barometer', 'Day',   'min', 1),
        ('MHBR',   'barometer', 'Month', 'max', 1),
        ('MLBR',   'barometer', 'Month', 'min', 1),
        ('YHBR',   'barometer', 'Year',  'max', 1),
        ('YLBR',   'barometer', 'Year',  'min', 1),

        # ---- Direccion de viento (grados, sin decimales) ----
        ('AZI',    'windDir', '', '', 0),

        # ---- Velocidad de viento (km/h, 1 decimal) ----
        ('WND',    'windSpeed', '',      '',    1),
        ('DGST',  'windGust',  'Day',   'max', 1),
        ('MGST',  'windGust',  'Month', 'max', 1),
        ('YGST',  'windGust',  'Year',  'max', 1),

        # ---- Precipitacion (mm, 1 decimal) ----
        ('DPCP',   'rain', 'Day',   'sum', 1),
        ('MPCP',   'rain', 'Month', 'sum', 1),
        ('YPCP',   'rain', 'Year',  'sum', 1),

        # ---- Radiacion solar (W/m2, sin decimales) ----
        ('SUN',    'radiation', '',      '',    0),
        ('DSUN',   'radiation', 'Day',   'max', 0),
        ('MSUN',   'radiation', 'Month', 'max', 0),
        ('YSUN',   'radiation', 'Year',  'max', 0),

        # ---- Indice UV (entero, sin decimales) ----
        ('UVI',    'UV', '',      '',    0),
        ('DUVI',   'UV', 'Day',   'max', 0),
        ('MUVI',   'UV', 'Month', 'max', 0),
        ('YUVI',   'UV', 'Year',  'max', 0),

        # ---- Particulas PM1 (ug/m3, sin decimales) ----
        ('PM1',     'pm1_0', '',      '',    0),
        ('DHPM1',   'pm1_0', 'Day',   'max', 0),
        ('DLPM1',   'pm1_0', 'Day',   'min', 0),
        ('MHPM1',   'pm1_0', 'Month', 'max', 0),
        ('MLPM1',   'pm1_0', 'Month', 'min', 0),
        ('YHPM1',   'pm1_0', 'Year',  'max', 0),
        ('YLPM1',   'pm1_0', 'Year',  'min', 0),

        # ---- Particulas PM2.5 (ug/m3, sin decimales) ----
        ('PM25',    'pm2_5', '',      '',    0),
        ('DHPM25',  'pm2_5', 'Day',   'max', 0),
        ('DLPM25',  'pm2_5', 'Day',   'min', 0),
        ('MHPM25',  'pm2_5', 'Month', 'max', 0),
        ('MLPM25',  'pm2_5', 'Month', 'min', 0),
        ('YHPM25',  'pm2_5', 'Year',  'max', 0),
        ('YLPM25',  'pm2_5', 'Year',  'min', 0),

        # ---- Particulas PM10 (ug/m3, sin decimales) ----
        ('PM10',    'pm10_0', '',      '',    0),
        ('DHPM10',  'pm10_0', 'Day',   'max', 0),
        ('DLPM10',  'pm10_0', 'Day',   'min', 0),
        ('MHPM10',  'pm10_0', 'Month', 'max', 0),
        ('MLPM10',  'pm10_0', 'Month', 'min', 0),
        ('YHPM10',  'pm10_0', 'Year',  'max', 0),
        ('YLPM10',  'pm10_0', 'Year',  'min', 0),
    ]

    def __init__(self, q, api_key, station_id, server_url=MeteoclimaticV3.DEFAULT_URL,
                 skip_upload=False, manager_dict=None,
                 post_interval=None, max_backlog=sys.maxsize, stale=None,
                 log_success=True, log_failure=True,
                 timeout=60, max_tries=3, retry_wait=5,
                 log_url=False):
        super(MeteoclimaticV3Thread, self).__init__(
            q,
            protocol_name='MeteoclimaticV3',
            manager_dict=manager_dict,
            post_interval=post_interval,
            max_backlog=max_backlog,
            stale=stale,
            log_success=log_success,
            log_failure=log_failure,
            max_tries=max_tries,
            timeout=timeout,
            retry_wait=retry_wait)
        self.api_key = api_key
        self.station_id = station_id
        loginf("Station %s" % self.station_id)
        self.server_url = server_url
        loginf("Data will be uploaded to %s" % self.server_url)
        self.skip_upload = to_bool(skip_upload)
        self.log_url = to_bool(log_url)

        loginf("Fields: %s" % ';'.join(v[0] for v in self._DATA_MAP))

    def get_record(self, record, dbmanager):
        """Augment record data with daily/monthly/yearly aggregates.

        returns: A dictionary of weather values, in the same unit system
        as the original archive record."""

        _datadict = super(MeteoclimaticV3Thread, self).get_record(record, dbmanager)

        _time_ts = _datadict['dateTime']

        # midnight-to-midnight, month and year spans containing _time_ts
        daytimespan = weeutil.weeutil.archiveDaySpan(_time_ts)
        monthtimespan = weeutil.weeutil.archiveMonthSpan(_time_ts)
        yeartimespan = weeutil.weeutil.archiveYearSpan(_time_ts)

        for key, obs, tim, agg, _decimals in self._DATA_MAP:
            if tim == '' or agg == '':
                # current value, taken directly from the record -
                # nothing to aggregate
                continue

            rkey = "%s%s%s" % (obs, tim.capitalize(), agg.capitalize())
            if rkey in _datadict:
                continue

            if tim == 'Day':
                _tts = daytimespan
            elif tim == 'Month':
                _tts = monthtimespan
            elif tim == 'Year':
                _tts = yeartimespan
            else:
                continue

            try:
                _result = weewx.xtypes.get_aggregate(obs, _tts, agg.lower(), dbmanager)
                weewx.units.obs_group_dict.setdefault(rkey, _result[2])
                _datadict[rkey] = weewx.units.convertStd(_result, _datadict['usUnits'])[0]
            except weedb.OperationalError as e:
                log.debug("%s: Database OperationalError '%s'", self.protocol_name, e)
            except Exception as e:
                logdbg("%s.%s.%s %s" % (obs, tim, agg, e))

        return _datadict

    # Unit groups that METRICWX does NOT already express the way
    # Meteoclimatic wants them, so they need an explicit conversion.
    # Note: METRICWX uses meter_per_second for group_speed (not km/h,
    # that is the METRIC system), so wind speed/gust must be converted
    # here or they get sent to Meteoclimatic in the wrong unit.
    _UNIT_MAP = {'group_speed': 'km_per_hour'}

    def __build_payload(self, record):
        """Build the Meteoclimatic JSON payload (without the api key)"""

        # convert to metric units: this gives us degree_C, mbar (== hPa),
        # mm and W/m2 directly, matching what Meteoclimatic expects.
        # Wind speed/gust still need an explicit conversion - see
        # _UNIT_MAP and the as_value_tuple()/convert() call below.
        record_m = weewx.units.to_METRICWX(record)

        _payload = {
            'stationcode': self.station_id,
            'TS': datetime.datetime.utcfromtimestamp(
                record_m['dateTime']).strftime('%Y-%m-%dT%H:%M:%SZ'),
        }

        for key, obs, tim, agg, decimals in self._DATA_MAP:
            rkey = "%s%s%s" % (obs, tim.capitalize(), agg.capitalize())

            if rkey in record_m and record_m[rkey] is not None:
                try:
                    # get the value together with its unit/unit group
                    __vt = weewx.units.as_value_tuple(record_m, rkey)
                    # convert to the unit Meteoclimatic expects, if the
                    # unit group needs an explicit conversion (e.g. wind
                    # speed/gust: m/s -> km/h)
                    if __vt[2] in self._UNIT_MAP:
                        __vt = weewx.units.convert(__vt, self._UNIT_MAP[__vt[2]])

                    _value = float(__vt[0])
                    if decimals == 0:
                        _payload[key] = int(round(_value))
                    else:
                        _payload[key] = round(_value, decimals)
                except (TypeError, ValueError, IndexError, KeyError) as e:
                    logerr("%s:%s: %s" % (key, rkey, e))

        return _payload

    def format_url(self, record):
        """Return the URL to POST to. The station code is not part of
        the URL, it travels inside the JSON payload."""

        if self.log_url:
            loginf("url %s" % self.server_url)
        elif weewx.debug >= 2:
            logdbg("url: %s" % self.server_url)

        return self.server_url

    def get_post_body(self, record):
        """Return the JSON payload to POST to Meteoclimatic"""

        _payload = self.__build_payload(record)
        _body = json.dumps(_payload)

        if weewx.debug >= 2:
            logdbg("payload: %s" % _body)

        return _body.encode('utf-8'), 'application/json'

    def post_request(self, request, payload=None):
        """Add the APIkey header (never sent as part of the payload)
        before handing the request off to weewx for posting."""

        request.add_header('APIkey', self.api_key)
        return super(MeteoclimaticV3Thread, self).post_request(request, payload)

    def check_response(self, response):
        """Check the response from a HTTP post.

        check_response() is called in case the http call returned
        success, only. That is for 200 <= response.code <= 299"""

        super(MeteoclimaticV3Thread, self).check_response(response)


# Use this hook to test the uploader:
#   PYTHONPATH=bin python bin/user/meteoclimaticv3.py

if __name__ == "__main__":
    weewx.debug = 2

    try:
        # WeeWX V4 logging
        weeutil.logger.setup('meteoclimaticv3', {})
    except NameError:
        # WeeWX V3 logging
        syslog.openlog('meteoclimaticv3', syslog.LOG_PID | syslog.LOG_CONS)
        syslog.setlogmask(syslog.LOG_UPTO(syslog.LOG_DEBUG))

    q = queue.Queue()
    t = MeteoclimaticV3Thread(q, api_key='TESTKEY', station_id='TESTSTATION')
    t.start()
    r = {'dateTime': int(time.time() + 0.5),
         'usUnits': weewx.US,
         'outTemp': 72.5,
         'outHumidity': 55,
         'barometer': 29.92,
         'windSpeed': 6.2,
         'windGust': 9.4,
         'windDir': 180,
         'rain': 0.0,
         'radiation': 350,
         'UV': 4}
    print(t.get_post_body(t.get_record(r, None)))
    q.put(r)
    q.put(None)
    t.join(30)
