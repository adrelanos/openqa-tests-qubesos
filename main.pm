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

use strict;
use testapi;
use autotest;

require 'qubesdistribution.pm';
testapi::set_distribution(qubesdistribution->new());

if (get_var('ISO')) {
    autotest::loadtest "tests/isosize.pm";
    if (get_var('INSTALL_OVER_EXISTING')) {
        autotest::loadtest "tests/install_preexisting_system.pm";
    }
    autotest::loadtest "tests/install_startup.pm";
    autotest::loadtest "tests/install_welcome.pm";
    if (get_var('KEYBOARD_LAYOUT')) {
        autotest::loadtest "tests/install_keyboard.pm";
    }
    if (get_var('PARTITIONING')) {
        autotest::loadtest "tests/install_partitioning_" . get_var('PARTITIONING') . ".pm";
    } else {
        autotest::loadtest "tests/install_partitioning_default.pm";
    }
    if (check_var("VERSION", "4.0")) {
        autotest::loadtest "tests/install_templates.pm";
    }
    autotest::loadtest "tests/install_do_user.pm";
    autotest::loadtest "tests/install_fixups.pm";
    autotest::loadtest "tests/firstboot.pm";
} else {
    autotest::loadtest "tests/startup.pm";
    autotest::loadtest "tests/startup_fixup.pm";
    if (get_var('DO_UPDATE')) {
        autotest::loadtest "tests/whonix_firstrun.pm";
        if (get_var('UPDATE_TEMPLATES')) {
            autotest::loadtest "tests/update_templates.pm";
        }
        if (get_var('UPDATE') || get_var('SALT_SYSTEM_TESTS')) {
            autotest::loadtest "tests/update.pm";
        }
        if (get_var('GUIVM')) {
            autotest::loadtest "tests/update_guivm.pm";
        }
    }
}

if (check_var('RELEASE_UPGRADE', '1')) {
    autotest::loadtest "tests/release_upgrade.pm";
    autotest::loadtest "tests/startup_fixup.pm";
}

# do not execute same tests before each system tests run
if (check_var('TEST_GENERIC', '1') and
        (!get_var('DO_UPDATE') or check_var('RESTART_AFTER_UPDATE', '1'))) {
    autotest::loadtest "tests/mount_and_boot_options.pm";
    autotest::loadtest "tests/usbvm.pm";
}

if (check_var('TEST_GUIVM', '1')) {
    die "GUIVM not configured" if !check_var('GUIVM', '1');
    autotest::loadtest "tests/guivm_startup.pm";
    autotest::loadtest "tests/guivm_manager.pm";
}

if (check_var('TEST_SUSPEND', '1')) {
    autotest::loadtest "tests/suspend.pm";
}

if (get_var("WHONIXCHECK")) {
    autotest::loadtest "tests/whonixcheck.pm";
}

if (get_var('SYSTEM_TESTS')) {
    autotest::loadtest "tests/system_tests.pm";
}

if (get_var('TEST_GUI_INTERACTIVE')) {
    autotest::loadtest "tests/simple_gui_apps.pm";
    autotest::loadtest "tests/screenlocker_leaks.pm";
    autotest::loadtest "tests/gui_keyboard_layout.pm";
}

if (get_var("GUI_TESTS")) {
        autotest::loadtest "tests/qui_widgets_clipboard.pm";
        autotest::loadtest "tests/qui_widgets_devices.pm";
        autotest::loadtest "tests/qui_widgets_disk_space.pm";
        autotest::loadtest "tests/qui_widgets_domains.pm";
        autotest::loadtest "tests/qui_widgets_notifications.pm";
        autotest::loadtest "tests/qui_widgets_update.pm";

        autotest::loadtest "tests/qubesmanager_backuprestore.pm";
        autotest::loadtest "tests/qubesmanager_createnewvm.pm";
        autotest::loadtest "tests/qubesmanager_globalsettings.pm";
        autotest::loadtest "tests/qubesmanager_manager.pm";
        autotest::loadtest "tests/qubesmanager_templatemanager.pm";
        autotest::loadtest "tests/qubesmanager_vmsettings.pm";
}

if (get_var("STORE_HDD_1") || get_var("PUBLISH_HDD_1")) {
    autotest::loadtest "tests/shutdown.pm";
}

1;

# vim: set sw=4 et:
