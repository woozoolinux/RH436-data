#!/bin/sh
#
#
#       High-Availability MySAP control script
#
#
#
#
# This program is distributed in the hope that it would be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Further, this software is distributed without any warranty that it is
# free of the rightful claim of any third person regarding infringement
# or the like.  Any license provided herein, whether implied or
# otherwise, applies only to this software file.  Patent licenses, if
# any, provided herein do not apply to combinations of this program with
# other software, or any other product whatsoever.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
#

#######################################################################
# Initialization:

: ${OCF_FUNCTIONS=${OCF_ROOT}/resource.d/heartbeat/.ocf-shellfuncs}
. ${OCF_FUNCTIONS}
: ${__OCF_ACTION=$1}

#######################################################################

meta_data() {
        cat <<END
<?xml version="1.0"?>
<!DOCTYPE resource-agent SYSTEM "ra-api-1.dtd">
<resource-agent name="MySAP" version="1.0">
<version>1.0</version>

<longdesc lang="en">
This is a specific agent to handle customized scripts for SAP.
This agent runs customzied script given by a user and returns the result
from customized scripts.

User can indicate whether each action is run or ignored.
</longdesc>
<shortdesc lang="en">MySAP agent to handle customized scripts for user's SAP application.</shortdesc>

<parameters>

<parameter name="start" unique="1">
<longdesc lang="en">
Customized script to start SAP application. User set the path of start-script
for SAP application. If this is NOT set, then this always return SUCCESS.
User script should return 0 if success.
</longdesc>
<shortdesc lang="en">start script for SAP application.</shortdesc>
<content type="string" default="" />
</parameter>

<parameter name="stop" unique="1">
<longdesc lang="en">
Customized script to stop SAP application. User set the path of stop-script
for SAP application. If this is NOT set, then this always return SUCCESS.
User script should return 0 if success.
</longdesc>
<shortdesc lang="en">stop script for SAP application.</shortdesc>
<content type="string" default="" />
</parameter>

<parameter name="monitor" unique="1">
<longdesc lang="en">
Customized script to monitor SAP application. User set the path of monitor-script
for SAP application. If this is NOT set, then this always return SUCCESS.
User script should return 0 if success.
</longdesc>
<shortdesc lang="en">monitor script for SAP application.</shortdesc>
<content type="string" default="" />
</parameter>


</parameters>

<actions>
<action name="start"        timeout="60" />
<action name="stop"         timeout="60" />
<action name="status"       timeout="60" interval="60" depth="0"/>
<action name="monitor"      timeout="60" interval="60" depth="0"/>
<action name="validate-all" timeout="20" />
<action name="meta-data"    timeout="5" />
</actions>
</resource-agent>
END
}

#######################################################################

# don't exit on TERM, to test that lrmd makes sure that we do exit
trap sigterm_handler TERM
sigterm_handler() {
        ocf_log info "They use TERM to bring us down. No such luck."
        return
}

swing_usage() {
        cat <<END
usage: $0 {start|stop|status|monitor|validate-all|meta-data}

Expects to have a fully populated OCF RA-compliant environment set.
END
}

swing_start() {

        start_path=${OCF_RESKEY_start}

        if [ "x${start_path}" = "x" ]; then
                ocf_log info "swing_start: start-script is NOT defined. OCF_SUCCSS($OCF_SUCCESS) is returned."
                return $OCF_SUCCESS
        fi

        if [ ! -f ${start_path} ]; then
                ocf_log err "swing_start: $start_path is NOT a regular file."
                return $OCF_ERR_CONFIGURED
        fi

        if [ ! -s ${start_path} ]; then
                ocf_log err "swing_start: $start_path is a empty file."
                return $OCF_ERR_CONFIGURED
        fi

        if [ ! -x ${start_path} ]; then
                ocf_log err "swing_start: $start_path can't be executable."
                return $OCF_ERR_PERM
        fi

        ocf_run -q "${start_path}" || return $OCF_ERR_GENERIC
        #"${start_path}" || return $OCF_ERR_GENERIC

        return $OCF_SUCCESS
}

swing_stop() {

        stop_path=${OCF_RESKEY_stop}

        if [ "x${stop_path}" = "x" ]; then
                ocf_log info "swing_stop: stop-script is NOT defined. OCF_SUCCSS($OCF_SUCCESS) is returned."
                return $OCF_SUCCESS
        fi

        if [ ! -f ${stop_path} ]; then
                ocf_log err "swing_stop: $stop_path is NOT a regular file."
                return $OCF_ERR_CONFIGURED
        fi

        if [ ! -s ${stop_path} ]; then
                ocf_log err "swing_stop: $stop_path is a empty file."
                return $OCF_ERR_CONFIGURED
        fi

        if [ ! -x ${stop_path} ]; then
                ocf_log err "swing_stop: $stop_path can't be executable."
                return $OCF_ERR_PERM
        fi

        ocf_run -q "${stop_path}" || return $OCF_ERR_GENERIC
        #"${stop_path}" || return $OCF_ERR_GENERIC

        return $OCF_SUCCESS
}

swing_monitor() {

        monitor_path=${OCF_RESKEY_monitor}

        if [ "x${monitor_path}" = "x" ]; then
                ocf_log info "swing_monitor: monitor-script is NOT defined. OCF_SUCCSS($OCF_SUCCESS) is returned."
                return $OCF_SUCCESS
        fi

        if [ ! -f ${monitor_path} ]; then
                ocf_log err "swing_monitor: $monitor_path is NOT a regular file."
                return $OCF_ERR_CONFIGURED
        fi

        if [ ! -s ${monitor_path} ]; then
                ocf_log err "swing_monitor: $monitor_path is a empty file."
                return $OCF_ERR_CONFIGURED
        fi

        if [ ! -x ${monitor_path} ]; then
                ocf_log err "swing_monitor: $monitor_path can't be executable."
                return $OCF_ERR_GENERIC
        fi

        ocf_run -q "${monitor_path}" || return $OCF_NOT_RUNNING

        return $OCF_SUCCESS
}

swing_validate() {

    return $OCF_SUCCESS
}

 


: ${OCF_RESKEY_CRM_meta_interval=0}
: ${OCF_RESKEY_CRM_meta_globally_unique:="true"}

case $__OCF_ACTION in
meta-data)      meta_data
                exit $OCF_SUCCESS # Must exit with $OCF_SUCCESS.
                ;;
start)          swing_start
                ;;
stop)           swing_stop
                ;;
monitor|status) swing_monitor
                ;;
validate-all)   swing_validate
                ;;
usage|help)     swing_usage
                exit $OCF_SUCCESS # Must exit with $OCF_SUCCESS.
                ;;
*)              swing_usage
                exit $OCF_ERR_UNIMPLEMENTED
                ;;
esac
rc=$?
ocf_log debug "${OCF_RESOURCE_INSTANCE} $__OCF_ACTION : $rc"
exit $rc

 