Garmin file:

<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
 <trk>
  <name>ACTIVE LOG082658</name>
  <trkseg>
   <trkpt lat="33.812228" lon="-118.383842">
    <ele>-54.379</ele>
    <time>2013-01-14T16:26:58Z</time>
   </trkpt>
   

What a MotionX file looks like. Note has local time in <desc>. Only has one <name> AFAIK

<gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" creator="MotionXGPSFull 21.1 Build 4789R">
<trk>
<name>Training 25 Nov 13</name>
<desc>Nov 25, 2013 10:04 am</desc>
<trkseg>
<trkpt lat="33.8121850" lon="-118.3835869">
<ele>52.311</ele>
<time>2013-11-25T18:04:36.022Z</time>
</trkpt>
<trkpt lat="33.8121850" lon="-118.3835869">
<ele>52.294</ele>

Strava file. Note time is GMT <time>. Only one occurrence of name.

<?xml version="1.0" encoding="UTF-8"?> 
<gpx creator="strava.com iPhone" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd">
 <metadata>
  <time>2013-11-27T00:03:08Z</time>
 </metadata>
 <trk>
  <name>Test walk 26 Nov 13</name>
  <trkseg>
   <trkpt lat="33.8121680" lon="-118.3836510">
    <ele>51.9</ele>
    <time>2013-11-27T00:03:08Z</time>
   </trkpt>
   <trkpt lat="33.8122000" lon="-118.3836380">
    <ele>51.6</ele>

# ======================== How I'm doing it now:

<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
 <trk>
<name>,  United States ::  2013-11-23 07:10:02 GMT-8. (1)</name>
<desc>America/Los_Angeles. GMT -8. Is ST</desc>
  <trkseg>
   <trkpt lat="33.887196" lon="-118.378594">
    <ele>5.192</ele>
    <time>2013-11-23T15:10:02Z</time>
   </trkpt>
   <trkpt lat="33.887191" lon="-118.378597">
    <ele>2.391</ele>
    <time>2013-11-23T15:10:05Z</time>
   </trkpt>
   <trkpt lat="33.887189" lon="-118.378597">
    <ele>5.655</ele>
    <time>2013-11-23T15:10:09Z</time>
    
If DST

<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
 <trk>
<name>Santa Martha, Mexico ::  2013-04-16 09:27:01 GMT-6. (1)</name>
<desc>America/Mazatlan. GMT -7, DST -6.0. Is DST</desc>
  <trkseg>
   <trkpt lat="25.470948" lon="-111.020738">
    <ele>-10.453</ele>
    <time>2013-04-16T15:27:01Z</time>
   </trkpt>
   <trkpt lat="25.470951" lon="-111.020738">
   
========================
