# The Qubes OS Project, https://www.qubes-os.org/
#
# Copyright (C) 2018 Marek Marczykowski-Górecki <marmarek@invisiblethingslab.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

package installedtest;
use base 'basetest';
use strict;
use testapi;
use networking;

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{network_up} = 0;
    return $self;
}

sub save_and_upload_log {
    my ($self, $cmd, $file, $args) = @_;
    script_run("$cmd | tee $file", $args->{timeout});
    upload_logs($file) unless $args->{noupload};
    save_screenshot if $args->{screenshot};
}

sub post_fail_hook {
    my $self = shift;

    select_console('root-virtio-terminal');
    script_run "xl info";
    script_run "xl list";
    enable_dom0_network_netvm() unless $self->{network_up};
    upload_logs('/var/log/libvirt/libxl/libxl-driver.log');
    $self->save_and_upload_log('journalctl -b', 'journalctl.log');
    upload_logs('/var/lib/qubes/qubes.xml');
    #my $logs = script_output('ls -1 /var/log/xen/console/*.log');
    #foreach (split(/\n/, $logs)) {
    #    next unless m/\/var\/log/;
    #    chop if /\.log./;
    #    upload_logs($_);
    #}
    # Upload /var/log
    unless (script_run "tar czf /tmp/var_log.tar.gz /var/log") {
        upload_logs "/tmp/var_log.tar.gz";
    }

    $self->save_and_upload_log('qvm-prefs sys-net', 'qvm-prefs-sys-net.log');
    $self->save_and_upload_log('qvm-prefs sys-firewall', 'qvm-prefs-sys-firewall.log');
    $self->save_and_upload_log('qvm-prefs sys-usb', 'qvm-prefs-sys-usb.log');
    $self->save_and_upload_log('xl dmesg', 'xl-dmesg.log');
}


sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { };
}

1;
# vim: sw=4 et ts=4: