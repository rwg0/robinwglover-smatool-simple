#!/bin/sh

cd /home/robin/cc
{
rrdtool graph graphs/power-60min.png --start end-60m --width 1000 --height 500  --end now \
--slope-mode --vertical-label Watts --lower-limit 0 --alt-autoscale-max \
DEF:Power=powertemp.rrd:GridAbs:AVERAGE LINE1:Power#0000FF:"NetFlow" \
DEF:Import=powertemp.rrd:GridImport:AVERAGE LINE3:Import#FF0000:"Import" \
DEF:Generation=powertemp.rrd:Generation:AVERAGE LINE1:Generation#00FFFF:"Generation" \
DEF:Export=powertemp.rrd:GridExport:AVERAGE LINE1:Export#00FF00:"Export" \
DEF:Panel2=powertemp.rrd:Panel2:AVERAGE LINE1:Panel2#FF00FF:"Panel 2" \
DEF:Usage=powertemp.rrd:Usage:AVERAGE CDEF:CUsage=Usage,0,MAX LINE1:CUsage#FFFF00:"Usage"

rrdtool graph graphs/power-6h.png --start end-6h --width 1000 --height 500  --end now \
--slope-mode --vertical-label Watts --lower-limit 0 --alt-autoscale-max \
DEF:Power=powertemp.rrd:GridAbs:AVERAGE LINE1:Power#0000FF:"NetFlow" \
DEF:Import=powertemp.rrd:GridImport:AVERAGE LINE3:Import#FF0000:"Import" \
DEF:Generation=powertemp.rrd:Generation:AVERAGE LINE1:Generation#00FFFF:"Generation" \
DEF:Export=powertemp.rrd:GridExport:AVERAGE LINE1:Export#00FF00:"Export" \
DEF:Panel2=powertemp.rrd:Panel2:AVERAGE LINE1:Panel2#FF00FF:"Panel 2" \
DEF:Usage=powertemp.rrd:Usage:AVERAGE CDEF:CUsage=Usage,0,MAX LINE1:CUsage#FFFF00:"Usage"

rrdtool graph graphs/power-24h.png --start end-24h --width 1000 --height 500  --end now \
--slope-mode --vertical-label Watts --lower-limit 0 --alt-autoscale-max \
DEF:Power=powertemp.rrd:GridAbs:AVERAGE LINE1:Power#0000FF:"NetFlow" \
DEF:Import=powertemp.rrd:GridImport:AVERAGE LINE3:Import#FF0000:"Import" \
DEF:Generation=powertemp.rrd:Generation:AVERAGE LINE1:Generation#00FFFF:"Generation" \
DEF:Export=powertemp.rrd:GridExport:AVERAGE LINE1:Export#00FF00:"Export" \
DEF:Panel2=powertemp.rrd:Panel2:AVERAGE LINE1:Panel2#FF00FF:"Panel 2" \
DEF:Usage=powertemp.rrd:Usage:AVERAGE CDEF:CUsage=Usage,0,MAX LINE1:CUsage#FFFF00:"Usage"

rrdtool graph graphs/power-48h.png --start end-48h --width 1000 --height 500  --end now \
--slope-mode --vertical-label Watts --lower-limit 0 --alt-autoscale-max \
DEF:Power=powertemp.rrd:GridAbs:AVERAGE LINE1:Power#0000FF:"NetFlow" \
DEF:Import=powertemp.rrd:GridImport:AVERAGE LINE3:Import#FF0000:"Import" \
DEF:Generation=powertemp.rrd:Generation:AVERAGE LINE1:Generation#00FFFF:"Generation" \
DEF:Export=powertemp.rrd:GridExport:AVERAGE LINE1:Export#00FF00:"Export" \
DEF:Panel2=powertemp.rrd:Panel2:AVERAGE LINE1:Panel2#FF00FF:"Panel 2" \
DEF:Usage=powertemp.rrd:Usage:AVERAGE CDEF:CUsage=Usage,0,MAX LINE1:CUsage#FFFF00:"Usage"

rrdtool graph graphs/kwh-day.png --end 23:00  --start end-2d  --width 1000 --height 500  --end now \
--slope-mode --vertical-label kWh --lower-limit 0 --alt-autoscale-max \
DEF:Import=powertemp.rrd:GridImport:AVERAGE:step=3600 CDEF:CI=Import,1000,/ LINE2:CI#FF0000:"Import" \
DEF:Generation=powertemp.rrd:Generation:AVERAGE:step=3600 CDEF:CG=Generation,UN,0,Generation,IF,1000,/ LINE2:CG#00FFFF:"Generation" \
DEF:Export=powertemp.rrd:GridExport:AVERAGE:step=3600 CDEF:CGE=Export,1000,/ LINE2:CGE#00FF00:"Export" \
DEF:Panel2=powertemp.rrd:Panel2:AVERAGE:step=3600 CDEF:CP2=Panel2,1000,/ LINE2:CP2#FF00FF:"Panel 2" \
DEF:Usage=powertemp.rrd:Usage:AVERAGE:step=3600 CDEF:CUsage=Usage,0,MAX,1000,/ LINE2:CUsage#000000:"Usage"

rrdtool graph graphs/kwh-month.png --end 00:00  --start end-30d  --width 1000 --height 500  --end now \
--slope-mode --vertical-label kWh --lower-limit 0 --alt-autoscale-max \
DEF:Import=powertemp.rrd:GridImport:AVERAGE:step=86400 CDEF:CI=Import,24,*,1000,/ LINE2:CI#FF0000:"Import" \
DEF:Generation=powertemp.rrd:Generation:AVERAGE:step=86400 CDEF:CG=Generation,UN,0,Generation,IF,24,*,1000,/ LINE2:CG#00FFFF:"Generation" \
DEF:Export=powertemp.rrd:GridExport:AVERAGE:step=86400 CDEF:CGE=Export,24,*,1000,/ LINE2:CGE#00FF00:"Export" \
DEF:Panel2=powertemp.rrd:Panel2:AVERAGE:step=86400 CDEF:CP2=Panel2,24,*,1000,/ LINE2:CP2#FF00FF:"Panel 2" \
DEF:Usage=powertemp.rrd:Usage:AVERAGE:step=86400 CDEF:CUsage=Usage,0,MAX,24,*,1000,/ LINE2:CUsage#000000:"Usage"

} > /dev/null


ncftpput -u <username> -p <password> <ftpsite.somewhere.com> <destfolder> graphs/*.png 2>/dev/null
